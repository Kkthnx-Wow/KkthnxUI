--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Implements an immersive AFK camera mode with 3D models and character stats.
-- - Design: Overlays a custom UI, initiates camera rotation, and displays random achievements/stats.
-- - Events: PLAYER_FLAGS_CHANGED, PLAYER_REGEN_DISABLED, LFG_PROPOSAL_SHOW, UPDATE_BATTLEFIELD_STATUS
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Miscellaneous")

-- PERF: Localize global functions and environment for faster lookups.
local date = _G.date
local math_floor = _G.math.floor
local math_random = _G.math.random
local pcall = _G.pcall
local select = _G.select
local string_format = _G.string.format
local string_gsub = _G.string.gsub
local string_sub = _G.string.sub
local tonumber = _G.tonumber
local tostring = _G.tostring

local _G = _G
local C_Calendar = _G.C_Calendar
local C_DateAndTime = _G.C_DateAndTime
local C_PetBattles_IsInBattle = _G.C_PetBattles.IsInBattle
local C_Timer_NewTicker = _G.C_Timer.NewTicker
local C_Timer_NewTimer = _G.C_Timer.NewTimer
local CloseAllWindows = _G.CloseAllWindows
local CreateFrame = _G.CreateFrame
local GetAchievementInfo = _G.GetAchievementInfo
local GetBattlefieldStatus = _G.GetBattlefieldStatus
local GetCVarBool = _G.GetCVarBool
local GetExpansionDisplayInfo = _G.GetExpansionDisplayInfo
local GetClampedCurrentExpansionLevel = _G.GetClampedCurrentExpansionLevel
local GetGameTime = _G.GetGameTime
local GetGuildInfo = _G.GetGuildInfo
local GetScreenHeight = _G.GetScreenHeight
local GetScreenWidth = _G.GetScreenWidth
local GetStatistic = _G.GetStatistic
local GetTime = _G.GetTime
local InCombatLockdown = _G.InCombatLockdown
local IsInGuild = _G.IsInGuild
local IsMacClient = _G.IsMacClient
local IsShiftKeyDown = _G.IsShiftKeyDown
local MoveViewLeftStart = _G.MoveViewLeftStart
local MoveViewLeftStop = _G.MoveViewLeftStop
local Screenshot = _G.Screenshot
local SetCVar = _G.SetCVar
local UIParent = _G.UIParent
local UnitCastingInfo = _G.UnitCastingInfo
local UnitIsAFK = _G.UnitIsAFK

local IGNORE_KEYS = {
	LALT = true,
	LSHIFT = true,
	RSHIFT = true,
}

local PRINT_KEYS = {
	["PRINTSCREEN"] = true,
}

local MONTH_ABBREVIATIONS = {
	[1] = "Jan",
	[2] = "Feb",
	[3] = "Mar",
	[4] = "Apr",
	[5] = "May",
	[6] = "Jun",
	[7] = "Jul",
	[8] = "Aug",
	[9] = "Sep",
	[10] = "Oct",
	[11] = "Nov",
	[12] = "Dec",
}

local DAYS_ABBREVIATIONS = {
	[1] = "Sun",
	[2] = "Mon",
	[3] = "Tue",
	[4] = "Wed",
	[5] = "Thu",
	[6] = "Fri",
	[7] = "Sat",
}

-- REASON: List of achievement IDs to pull random statistics from while AFK.
local STAT_IDS = {
	60, -- Total deaths
	94, -- Quests abandoned
	97, -- Daily quests completed
	98, -- Quests completed
	107, -- Creatures killed
	112, -- Deaths from drowning
	114, -- Deaths from falling
	115, -- Deaths from fire and lava
	319, -- Duels won
	320, -- Duels lost
	326, -- Gold from quest rewards
	328, -- Total gold acquired
	329, -- Auctions posted
	331, -- Most expensive bid on auction
	332, -- Most expensive auction sold
	333, -- Gold looted
	334, -- Most gold ever owned
	338, -- Vanity pets owned
	345, -- Health potions consumed
	349, -- Flight paths taken
	353, -- Number of times hearthed
	588, -- Total Honorable Kills
	812, -- Healthstones used
	837, -- Arenas won
	838, -- Arenas played
	839, -- Battlegrounds played
	840, -- Battlegrounds won
	919, -- Gold earned from auctions
	932, -- Total 5-player dungeons entered
	933, -- Total 10-player raids entered
	934, -- Total 25-player raids entered
	1042, -- Number of hugs
	1045, -- Total cheers
	1047, -- Total facepalms
	1065, -- Total waves
	1066, -- Total times LOL"d
	1197, -- Total kills
	1198, -- Total kills that grant experience or honor
	1336, -- Creature type killed the most
	1339, -- Mage portal taken most
	1487, -- Total Killing Blows
	1491, -- Battleground Killing Blows
	1518, -- Fish caught
	1776, -- Food eaten most
	2277, -- Summons accepted
	5692, -- Rated battlegrounds played
	5693, -- Rated battleground played the most
	5695, -- Rated battleground won the most
	5694, -- Rated battlegrounds won
	7399, -- Challenge mode dungeons completed
	8278, -- Pet Battles won at max level
}

local function isValueInArgs(val, ...)
	for i = 1, select("#", ...) do
		if val == select(i, ...) then
			return true
		end
	end
	return false
end

local function setupTimeDisplay(color, hour, minute)
	local useMilitaryTime = GetCVarBool("timeMgrUseMilitaryTime")

	if useMilitaryTime then
		return string_format("%s" .. _G.TIMEMANAGER_TICKER_24HOUR, color, hour, minute)
	else
		local timerUnit = K.MyClassColor .. (hour < 12 and " AM" or " PM")

		if hour >= 12 then
			hour = hour - 12
		else
			if hour == 0 then
				hour = 12
			end
		end

		return string_format("%s" .. _G.TIMEMANAGER_TICKER_12HOUR .. timerUnit, color, hour, minute)
	end
end

local function updateAFKTimer(self)
	local hour, minute
	if GetCVarBool("timeMgrUseLocalTime") then
		hour, minute = tonumber(date("%H")), tonumber(date("%M"))
	else
		hour, minute = GetGameTime()
	end

	-- PERF: Throttle time and date UI updates to once per minute to prevent generating GC tables every second.
	if minute ~= self.lastMinute then
		self.lastMinute = minute

		local color = C_Calendar.GetNumPendingInvites() > 0 and "|cffFF0000" or ""
		self.topFrame.time:SetText(setupTimeDisplay(color, hour, minute))

		local calendarTime = C_DateAndTime.GetCurrentCalendarTime()
		self.topFrame.date:SetFormattedText("%s, %s %d, %d", DAYS_ABBREVIATIONS[calendarTime.weekday], MONTH_ABBREVIATIONS[calendarTime.month], calendarTime.monthDay, calendarTime.year)
	end
end

local function updateLogOff(self)
	local timePassed = GetTime() - self.startTime
	local timeLeft = 1800 - timePassed -- 30 minutes
	local minutes = math_floor(timeLeft / 60)
	local seconds = math_floor(timeLeft % 60)

	self.topFrame.Status:SetValue(math_floor(timeLeft))

	if minutes <= 0 and seconds <= 0 then
		self.logoffTimer:Cancel()
		self.countdownFrame.text:SetFormattedText("Logout Timer: |cfff0ff0000:00|r")
	else
		self.countdownFrame.text:SetFormattedText("Logout Timer: |cfff0ff00-%02d:%02d|r", minutes, seconds)
	end
end


local function createRandomStatMessage()
	local statID = STAT_IDS[math_random(#STAT_IDS)]
	local _, name = GetAchievementInfo(statID)
	local result = GetStatistic(statID)
	if result == "--" then
		result = _G.NONE
	end

	return string_format("%s: |cfff0ff00%s|r", name, result)
end

local function updateStatMessage(self)
	K.UIFrameFadeIn(self.statMsg.info, 1, 1, 0)
	local randomStat = createRandomStatMessage()
	self.statMsg.info:SetText(randomStat)
	K.UIFrameFadeIn(self.statMsg.info, 1, 0, 1)
end

-- REASON: Standardized function to toggle the AFK overlay and background activities.
local function setAFKMode(self, isEnabling)
	if isEnabling then
		MoveViewLeftStart(0.035) -- REASON: Rotates the camera for an immersive effect.
		self:Show()
		CloseAllWindows()
		UIParent:Hide()

		if IsInGuild() then
			local guildName, guildRankName = GetGuildInfo("player")
			self.bottomFrame.guild:SetFormattedText("%s - %s", guildName, guildRankName)
		else
			self.bottomFrame.guild:SetText(L["No Guild"])
		end

		self.bottomFrame.model.curAnimation = "wave"
		self.bottomFrame.model.startTime = GetTime()
		self.bottomFrame.model.duration = 2.3
		self.bottomFrame.model:SetUnit("player")
		self.bottomFrame.model.isIdle = nil
		self.bottomFrame.model:SetAnimation(67)
		self.bottomFrame.model.idleDuration = 30

		self.bottomFrame.modelPet:SetUnit("pet")
		self.bottomFrame.modelPet:SetAnimation(0)

		self.startTime = GetTime()

		self.lastMinute = -1
		self.timer = C_Timer_NewTicker(1, function()
			updateAFKTimer(self)
		end)

		if self.statsTimer then
			self.statsTimer:Cancel()
		end
		self.statsTimer = C_Timer_NewTicker(5, function()
			updateStatMessage(self)
		end)

		if self.logoffTimer then
			self.logoffTimer:Cancel()
		end
		self.logoffTimer = C_Timer_NewTicker(1, function()
			updateLogOff(self)
		end)

		self.chatFrame:RegisterEvent("CHAT_MSG_WHISPER")
		self.chatFrame:RegisterEvent("CHAT_MSG_BN_WHISPER")
		self.chatFrame:RegisterEvent("CHAT_MSG_GUILD")
		self.chatFrame:RegisterEvent("CHAT_MSG_PARTY")
		self.chatFrame:RegisterEvent("CHAT_MSG_RAID")

		self.isAFK = true
	elseif self.isAFK then
		UIParent:Show()
		self:Hide()
		MoveViewLeftStop()

		if self.startTime then
			self.startTime = nil
		end

		if self.timer then
			self.timer:Cancel()
		end

		if self.statsTimer then
			self.statsTimer:Cancel()
		end

		if self.logoffTimer then
			self.logoffTimer:Cancel()
		end

		if self.animTimer then
			self.animTimer:Cancel()
		end

		self.countdownFrame.text:SetFormattedText("Logout Timer: |cfff0ff00-30:00|r")
		self.statMsg.info:SetFormattedText("|cffb3b3b3Random Stats|r")

		self.chatFrame:UnregisterAllEvents()
		self.chatFrame:Clear()

		if _G.PVEFrame:IsShown() then -- REASON: Fixing a Blizzard bug where the PVE frame is sometimes blank after AFK.
			_G.PVEFrame_ToggleFrame()
			_G.PVEFrame_ToggleFrame()
		end

		self.isAFK = false
	end
end

local function afkModeOnEvent(self, event, ...)
	if isValueInArgs(event, "PLAYER_REGEN_DISABLED", "LFG_PROPOSAL_SHOW", "UPDATE_BATTLEFIELD_STATUS") then
		if event == "UPDATE_BATTLEFIELD_STATUS" then
			local status = GetBattlefieldStatus(...)
			if status == "confirm" then
				setAFKMode(self, false)
			end
		else
			setAFKMode(self, false)
		end

		if event == "PLAYER_REGEN_DISABLED" then
			self:RegisterEvent("PLAYER_REGEN_ENABLED")
		end
		return
	end

	if event == "PLAYER_REGEN_ENABLED" then
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	end

	if InCombatLockdown() or _G.CinematicFrame:IsShown() or _G.MovieFrame:IsShown() then
		return
	end

	if UnitCastingInfo("player") ~= nil then
		-- REASON: Do not activate AFK mode if the player is currently crafting/casting. Check again in 30 seconds.
		K.Delay(30, function()
			afkModeOnEvent(self, "PLAYER_FLAGS_CHANGED")
		end)
		return
	end

	if UnitIsAFK("player") and not C_PetBattles_IsInBattle() then
		setAFKMode(self, true)
	else
		setAFKMode(self, false)
	end
end

local function onKeyDown(self, key)
	if IGNORE_KEYS[key] then
		return
	end

	if PRINT_KEYS[key] then
		Screenshot()
	else
		setAFKMode(self, false)
		K.Delay(60, function()
			afkModeOnEvent(self, "PLAYER_FLAGS_CHANGED")
		end)
	end
end

local function chatOnMouseWheel(self, delta)
	if delta == 1 and IsShiftKeyDown() then
		self:ScrollToTop()
	elseif delta == -1 and IsShiftKeyDown() then
		self:ScrollToBottom()
	elseif delta == -1 then
		self:ScrollDown()
	else
		self:ScrollUp()
	end
end

local function chatOnEvent(self, event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14)
	local coloredName = _G.GetColoredName(event, arg1, arg2, arg3, arg4, arg5, arg6, arg7, arg8, arg9, arg10, arg11, arg12, arg13, arg14)
	local chatType = string_sub(event, 10)
	local chatInfo = _G.ChatTypeInfo[chatType]

	if event == "CHAT_MSG_BN_WHISPER" then
		coloredName = string_format("|c%s%s|r", _G.RAID_CLASS_COLORS.PRIEST.colorStr, arg2)
	end

	arg1 = _G.RemoveExtraSpaces(arg1)

	local chatGroup = _G.Chat_GetChatCategory(chatType)
	local chatTarget, body
	if chatGroup == "BN_CONVERSATION" then
		chatTarget = tostring(arg8)
	elseif chatGroup == "WHISPER" or chatGroup == "BN_WHISPER" then
		if string_sub(arg2, 1, 2) ~= "|K" then
			chatTarget = arg2:upper()
		else
			chatTarget = arg2
		end
	end

	local playerLink
	if chatType ~= "BN_WHISPER" and chatType ~= "BN_CONVERSATION" then
		playerLink = string_format("|Hplayer:%s:%s:%s%s|h", arg2, arg11, chatGroup, chatTarget and ":" .. chatTarget or "")
	else
		playerLink = string_format("|HBNplayer:%s:%s:%s:%s%s|h", arg2, arg13, arg11, chatGroup, chatTarget and ":" .. chatTarget or "")
	end

	local message = arg1
	if arg14 then -- isMobile
		message = _G.ChatFrame_GetMobileEmbeddedTexture(chatInfo.r, chatInfo.g, chatInfo.b) .. message
	end

	-- REASON: Escape '%' to prevent "invalid option in format" errors during string_format.
	message = string_gsub(message, "%%", "%%%%")

	_, body = pcall(string_format, _G["CHAT_" .. chatType .. "_GET"] .. message, playerLink .. "[" .. coloredName .. "]" .. "|h")

	local accessID = _G.ChatHistory_GetAccessID(chatGroup, chatTarget)
	local typeID = _G.ChatHistory_GetAccessID(chatType, chatTarget, arg12 == "" and arg13 or arg12)

	self:AddMessage(body, chatInfo.r, chatInfo.g, chatInfo.b, chatInfo.id, false, accessID, typeID)
end

local function loopAnimations(self)
	if self.curAnimation == "wave" then
		self:SetAnimation(69)
		self.curAnimation = "dance"
		self.startTime = GetTime()
		self.duration = 300
		self.isIdle = false
		self.idleDuration = 120
	end
end

function Module:CreateAFKCam()
	if not C["Misc"].AFKCamera then
		return
	end

	local afkModeFrame = CreateFrame("Frame")
	afkModeFrame:SetFrameLevel(1)
	afkModeFrame:SetScale(UIParent:GetScale())
	afkModeFrame:SetAllPoints(UIParent)
	afkModeFrame:Hide()
	afkModeFrame:EnableKeyboard(true)
	afkModeFrame:SetScript("OnKeyDown", onKeyDown)

	afkModeFrame.chatFrame = CreateFrame("ScrollingMessageFrame", nil, afkModeFrame)
	afkModeFrame.chatFrame:SetSize(500, 200)
	afkModeFrame.chatFrame:SetFontObject(K.UIFont)
	afkModeFrame.chatFrame:SetJustifyH("LEFT")
	afkModeFrame.chatFrame:SetMaxLines(100)
	afkModeFrame.chatFrame:EnableMouseWheel(true)
	afkModeFrame.chatFrame:SetFading(false)
	afkModeFrame.chatFrame:SetMovable(true)
	afkModeFrame.chatFrame:EnableMouse(true)
	afkModeFrame.chatFrame:RegisterForDrag("LeftButton")
	afkModeFrame.chatFrame:SetScript("OnDragStart", afkModeFrame.chatFrame.StartMoving)
	afkModeFrame.chatFrame:SetScript("OnDragStop", afkModeFrame.chatFrame.StopMovingOrSizing)
	afkModeFrame.chatFrame:SetScript("OnMouseWheel", chatOnMouseWheel)
	afkModeFrame.chatFrame:SetScript("OnEvent", chatOnEvent)

	afkModeFrame.topFrame = CreateFrame("Frame", nil, afkModeFrame)
	afkModeFrame.topFrame:SetFrameLevel(0)
	afkModeFrame.topFrame:CreateBorder(nil, nil, C["General"].BorderStyle ~= "KkthnxUI_Pixel" and 32, nil, C["General"].BorderStyle ~= "KkthnxUI_Pixel" and -10)
	afkModeFrame.topFrame:SetPoint("TOP", afkModeFrame, "TOP", 0, 6)
	afkModeFrame.topFrame:SetSize(UIParent:GetWidth() + 12, 54)

	afkModeFrame.chatFrame:SetPoint("TOPLEFT", afkModeFrame.topFrame, "BOTTOMLEFT", 10, -6)

	afkModeFrame.bottomFrame = CreateFrame("Frame", nil, afkModeFrame)
	afkModeFrame.bottomFrame:SetFrameLevel(0)
	afkModeFrame.bottomFrame:CreateBorder(nil, nil, C["General"].BorderStyle ~= "KkthnxUI_Pixel" and 32, nil, C["General"].BorderStyle ~= "KkthnxUI_Pixel" and -10)
	afkModeFrame.bottomFrame:SetPoint("BOTTOM", afkModeFrame, "BOTTOM", 0, -K.BorderSize)
	afkModeFrame.bottomFrame:SetWidth(K.ScreenWidth + (K.BorderSize * 2))
	afkModeFrame.bottomFrame:SetHeight(K.ScreenHeight * 0.08)

	afkModeFrame.bottomFrame.logo = afkModeFrame:CreateTexture(nil, "OVERLAY")
	afkModeFrame.bottomFrame.logo:SetSize(512 / 1.6, 256 / 1.6)
	afkModeFrame.bottomFrame.logo:SetPoint("CENTER", afkModeFrame.bottomFrame, "CENTER", 0, 60)
	afkModeFrame.bottomFrame.logo:SetTexture(C["Media"].Textures.LogoTexture)

	afkModeFrame.topFrame.time = afkModeFrame.topFrame:CreateFontString(nil, "OVERLAY")
	afkModeFrame.topFrame.time:SetFontObject(K.UIFont)
	afkModeFrame.topFrame.time:SetFont(select(1, afkModeFrame.topFrame.time:GetFont()), 16, select(3, afkModeFrame.topFrame.time:GetFont()))
	afkModeFrame.topFrame.time:SetText("")
	afkModeFrame.topFrame.time:SetPoint("RIGHT", afkModeFrame.topFrame, "RIGHT", -20, 0)
	afkModeFrame.topFrame.time:SetJustifyH("LEFT")
	afkModeFrame.topFrame.time:SetTextColor(0.7, 0.7, 0.7)

	-- WoW logo
	afkModeFrame.topFrame.wowlogo = CreateFrame("Frame", nil, afkModeFrame) -- REASON: Wraps the logo in a frame to control its layering independently.
	afkModeFrame.topFrame.wowlogo:SetPoint("TOP", afkModeFrame.topFrame, "TOP", 0, -5)
	afkModeFrame.topFrame.wowlogo:SetFrameStrata("MEDIUM")
	afkModeFrame.topFrame.wowlogo:SetSize(300, 150)
	afkModeFrame.topFrame.wowlogo.texture = afkModeFrame.topFrame.wowlogo:CreateTexture(nil, "OVERLAY")
	local expansionLevel = GetClampedCurrentExpansionLevel()
	local displayInfo = GetExpansionDisplayInfo(expansionLevel)
	if displayInfo then
		afkModeFrame.topFrame.wowlogo.texture:SetTexture(displayInfo.logo)
	end
	afkModeFrame.topFrame.wowlogo.texture:SetAllPoints()

	-- Date text
	afkModeFrame.topFrame.date = afkModeFrame.topFrame:CreateFontString(nil, "OVERLAY")
	afkModeFrame.topFrame.date:SetFontObject(K.UIFont)
	afkModeFrame.topFrame.date:SetFont(select(1, afkModeFrame.topFrame.date:GetFont()), 16, select(3, afkModeFrame.topFrame.date:GetFont()))
	afkModeFrame.topFrame.date:SetText("")
	afkModeFrame.topFrame.date:SetPoint("LEFT", afkModeFrame.topFrame, "LEFT", 20, 0)
	afkModeFrame.topFrame.date:SetJustifyH("RIGHT")
	afkModeFrame.topFrame.date:SetTextColor(0.7, 0.7, 0.7)

	-- Statusbar on Top frame decor showing time to log off (30mins)
	afkModeFrame.topFrame.Status = CreateFrame("StatusBar", nil, afkModeFrame.topFrame)
	afkModeFrame.topFrame.Status:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
	afkModeFrame.topFrame.Status:SetMinMaxValues(0, 1800)
	afkModeFrame.topFrame.Status:SetStatusBarColor(K.r, K.g, K.b, 1)
	afkModeFrame.topFrame.Status:SetFrameLevel(2)
	afkModeFrame.topFrame.Status:SetPoint("TOPRIGHT", afkModeFrame.topFrame, "BOTTOMRIGHT", 0, 6)
	afkModeFrame.topFrame.Status:SetPoint("BOTTOMLEFT", afkModeFrame.topFrame, "BOTTOMLEFT", 0, 1)
	afkModeFrame.topFrame.Status:SetValue(0)

	local factionGroup, factionSize, offsetX, offsetY, nameOffsetX, nameOffsetY = K.Faction, 140, -20, -8, -10, -36
	if factionGroup == "Neutral" then
		factionGroup, factionSize, offsetX, offsetY, nameOffsetX, nameOffsetY = "Panda", 90, 15, 10, 20, -5
	end

	-- REASON: Race-specific vertical offsets for the character model to ensure proper framing across different heights.
	local modelOffsetY = 205
	local playerRace = K.Race
	local playerSex = K.Sex
	if playerRace == "Human" then
		modelOffsetY = 195
	elseif playerRace == "Worgen" then
		modelOffsetY = 280
	elseif playerRace == "Tauren" or playerRace == "HighmountainTauren" then
		modelOffsetY = 250
	elseif playerRace == "Draenei" or playerRace == "LightforgedDraenei" then
		if playerSex == 2 then
			modelOffsetY = 250
		end
	elseif playerRace == "Pandaren" then
		if playerSex == 2 then
			modelOffsetY = 220
		elseif playerSex == 3 then
			modelOffsetY = 280
		end
	elseif playerRace == "KulTiran" then
		if playerSex == 2 then
			modelOffsetY = 220
		elseif playerSex == 3 then
			modelOffsetY = 240
		end
	elseif playerRace == "Goblin" then
		if playerSex == 2 then
			modelOffsetY = 240
		elseif playerSex == 3 then
			modelOffsetY = 220
		end
	elseif playerRace == "Troll" or playerRace == "ZandalariTroll" then
		if playerSex == 2 then
			modelOffsetY = 250
		elseif playerSex == 3 then
			modelOffsetY = 280
		end
	elseif playerRace == "Dwarf" or playerRace == "DarkIronDwarf" then
		if playerSex == 2 then
			modelOffsetY = 250
		end
	elseif playerRace == "Vulpera" then
		modelOffsetY = 220
	end

	afkModeFrame.bottomFrame.faction = afkModeFrame.bottomFrame:CreateTexture(nil, "OVERLAY")
	afkModeFrame.bottomFrame.faction:SetPoint("BOTTOMLEFT", afkModeFrame.bottomFrame, "BOTTOMLEFT", offsetX, offsetY)
	afkModeFrame.bottomFrame.faction:SetTexture("Interface/Timer/" .. factionGroup .. "-Logo")
	afkModeFrame.bottomFrame.faction:SetSize(factionSize, factionSize)

	afkModeFrame.bottomFrame.name = afkModeFrame.bottomFrame:CreateFontString(nil, "OVERLAY")
	afkModeFrame.bottomFrame.name:SetFontObject(K.UIFont)
	afkModeFrame.bottomFrame.name:SetFont(select(1, afkModeFrame.bottomFrame.name:GetFont()), 20, select(3, afkModeFrame.bottomFrame.name:GetFont()))
	afkModeFrame.bottomFrame.name:SetFormattedText("%s-%s", K.Name, K.Realm)
	afkModeFrame.bottomFrame.name:SetPoint("TOPLEFT", afkModeFrame.bottomFrame.faction, "TOPRIGHT", nameOffsetX, nameOffsetY)
	afkModeFrame.bottomFrame.name:SetTextColor(K.r, K.g, K.b)

	afkModeFrame.bottomFrame.playerInfo = afkModeFrame.bottomFrame:CreateFontString(nil, "OVERLAY")
	afkModeFrame.bottomFrame.playerInfo:SetFontObject(K.UIFont)
	afkModeFrame.bottomFrame.playerInfo:SetFont(select(1, afkModeFrame.bottomFrame.playerInfo:GetFont()), 20, select(3, afkModeFrame.bottomFrame.playerInfo:GetFont()))
	afkModeFrame.bottomFrame.playerInfo:SetText(K.SystemColor .. _G.LEVEL .. " " .. K.Level .. "|r " .. K.GreyColor .. playerRace .. "|r " .. K.MyClassColor .. _G.UnitClass("player") .. "|r")
	afkModeFrame.bottomFrame.playerInfo:SetPoint("TOPLEFT", afkModeFrame.bottomFrame.name, "BOTTOMLEFT", 0, -6)

	afkModeFrame.bottomFrame.guild = afkModeFrame.bottomFrame:CreateFontString(nil, "OVERLAY")
	afkModeFrame.bottomFrame.guild:SetFontObject(K.UIFont)
	afkModeFrame.bottomFrame.guild:SetFont(select(1, afkModeFrame.bottomFrame.guild:GetFont()), 20, select(3, afkModeFrame.bottomFrame.guild:GetFont()))
	afkModeFrame.bottomFrame.guild:SetText(L["No Guild"])
	afkModeFrame.bottomFrame.guild:SetPoint("TOPLEFT", afkModeFrame.bottomFrame.playerInfo, "BOTTOMLEFT", 0, -6)
	afkModeFrame.bottomFrame.guild:SetTextColor(0.7, 0.7, 0.7)

	-- Random stats decor
	afkModeFrame.statMsg = CreateFrame("Frame", nil, afkModeFrame)
	afkModeFrame.statMsg:SetSize(418, 72)
	afkModeFrame.statMsg:SetPoint("CENTER", 0, 260)

	afkModeFrame.statMsg.bg = afkModeFrame.statMsg:CreateTexture(nil, "BACKGROUND")
	afkModeFrame.statMsg.bg:SetTexture([[Interface\LevelUp\LevelUpTex]])
	afkModeFrame.statMsg.bg:SetPoint("BOTTOM")
	afkModeFrame.statMsg.bg:SetSize(326, 103)
	afkModeFrame.statMsg.bg:SetTexCoord(0.00195313, 0.63867188, 0.03710938, 0.23828125)
	afkModeFrame.statMsg.bg:SetVertexColor(1, 1, 1, 0.7)

	afkModeFrame.statMsg.lineTop = afkModeFrame.statMsg:CreateTexture(nil, "BACKGROUND")
	afkModeFrame.statMsg.lineTop:SetDrawLayer("BACKGROUND", 2)
	afkModeFrame.statMsg.lineTop:SetTexture([[Interface\LevelUp\LevelUpTex]])
	afkModeFrame.statMsg.lineTop:SetPoint("TOP")
	afkModeFrame.statMsg.lineTop:SetSize(418, 7)
	afkModeFrame.statMsg.lineTop:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)

	afkModeFrame.statMsg.lineBottom = afkModeFrame.statMsg:CreateTexture(nil, "BACKGROUND")
	afkModeFrame.statMsg.lineBottom:SetDrawLayer("BACKGROUND", 2)
	afkModeFrame.statMsg.lineBottom:SetTexture([[Interface\LevelUp\LevelUpTex]])
	afkModeFrame.statMsg.lineBottom:SetPoint("BOTTOM")
	afkModeFrame.statMsg.lineBottom:SetSize(418, 7)
	afkModeFrame.statMsg.lineBottom:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)

	afkModeFrame.statMsg.info = afkModeFrame.statMsg:CreateFontString(nil, "OVERLAY")
	afkModeFrame.statMsg.info:SetFontObject(K.UIFont)
	afkModeFrame.statMsg.info:SetFont(select(1, afkModeFrame.statMsg.info:GetFont()), 18, select(3, afkModeFrame.statMsg.info:GetFont()))
	afkModeFrame.statMsg.info:SetPoint("CENTER", afkModeFrame.statMsg, "CENTER", 0, -2)
	afkModeFrame.statMsg.info:SetText(string_format("|cffb3b3b3%s|r", "Random Stats"))
	afkModeFrame.statMsg.info:SetJustifyH("CENTER")
	afkModeFrame.statMsg.info:SetTextColor(0.7, 0.7, 0.7)

	-- Countdown decor
	afkModeFrame.countdownFrame = CreateFrame("Frame", nil, afkModeFrame)
	afkModeFrame.countdownFrame:SetSize(418, 36)
	afkModeFrame.countdownFrame:SetPoint("TOP", afkModeFrame.statMsg.lineBottom, "BOTTOM")

	afkModeFrame.countdownFrame.bg = afkModeFrame.countdownFrame:CreateTexture(nil, "BACKGROUND")
	afkModeFrame.countdownFrame.bg:SetTexture([[Interface\LevelUp\LevelUpTex]])
	afkModeFrame.countdownFrame.bg:SetPoint("BOTTOM")
	afkModeFrame.countdownFrame.bg:SetSize(326, 56)
	afkModeFrame.countdownFrame.bg:SetTexCoord(0.00195313, 0.63867188, 0.03710938, 0.23828125)
	afkModeFrame.countdownFrame.bg:SetVertexColor(1, 1, 1, 0.7)

	afkModeFrame.countdownFrame.lineBottom = afkModeFrame.countdownFrame:CreateTexture(nil, "BACKGROUND")
	afkModeFrame.countdownFrame.lineBottom:SetDrawLayer("BACKGROUND", 2)
	afkModeFrame.countdownFrame.lineBottom:SetTexture([[Interface\LevelUp\LevelUpTex]])
	afkModeFrame.countdownFrame.lineBottom:SetPoint("BOTTOM")
	afkModeFrame.countdownFrame.lineBottom:SetSize(418, 7)
	afkModeFrame.countdownFrame.lineBottom:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)

	afkModeFrame.countdownFrame.text = afkModeFrame.countdownFrame:CreateFontString(nil, "OVERLAY")
	afkModeFrame.countdownFrame.text:SetFontObject(K.UIFont)
	afkModeFrame.countdownFrame.text:SetPoint("CENTER", afkModeFrame.countdownFrame, "CENTER")
	afkModeFrame.countdownFrame.text:SetJustifyH("CENTER")
	afkModeFrame.countdownFrame.text:SetFormattedText("Logout Timer: |cfff0ff00-30:00|r")
	afkModeFrame.countdownFrame.text:SetTextColor(0.7, 0.7, 0.7)

	-- REASON: Holder frame to manage character model position and scaling relative to the bottom UI bar.
	afkModeFrame.bottomFrame.modelHolder = CreateFrame("Frame", nil, afkModeFrame.bottomFrame)
	afkModeFrame.bottomFrame.modelHolder:SetSize(150, 150)
	afkModeFrame.bottomFrame.modelHolder:SetPoint("BOTTOMRIGHT", afkModeFrame.bottomFrame, "BOTTOMRIGHT", -200, modelOffsetY)

	afkModeFrame.bottomFrame.model = CreateFrame("PlayerModel", nil, afkModeFrame.bottomFrame.modelHolder)
	afkModeFrame.bottomFrame.model:SetPoint("CENTER", afkModeFrame.bottomFrame.modelHolder, "CENTER")
	afkModeFrame.bottomFrame.model:SetSize(GetScreenWidth() * 2, GetScreenHeight() * 2)
	afkModeFrame.bottomFrame.model:SetCamDistanceScale(4.5)
	afkModeFrame.bottomFrame.model:SetFacing(6)
	afkModeFrame.bottomFrame.model:SetScript("OnUpdate", function(self)
		local timeSinceStart = GetTime() - self.startTime
		if timeSinceStart > self.duration and not self.isIdle then
			self:SetAnimation(0)
			self.isIdle = true
			afkModeFrame.animTimer = C_Timer_NewTimer(self.idleDuration, function()
				loopAnimations(self)
			end)
		end
	end)

	afkModeFrame.bottomFrame.modelPetHolder = CreateFrame("Frame", nil, afkModeFrame.bottomFrame)
	afkModeFrame.bottomFrame.modelPetHolder:SetSize(150, 150)
	afkModeFrame.bottomFrame.modelPetHolder:SetPoint("BOTTOMRIGHT", afkModeFrame.bottomFrame, "BOTTOMRIGHT", -500, 100)

	afkModeFrame.bottomFrame.modelPet = CreateFrame("PlayerModel", nil, afkModeFrame.bottomFrame.modelPetHolder)
	afkModeFrame.bottomFrame.modelPet:SetPoint("CENTER", afkModeFrame.bottomFrame.modelPetHolder, "CENTER")
	afkModeFrame.bottomFrame.modelPet:SetSize(GetScreenWidth() * 2, GetScreenHeight() * 2)
	afkModeFrame.bottomFrame.modelPet:SetCamDistanceScale(9)
	afkModeFrame.bottomFrame.modelPet:SetFacing(6)

	afkModeFrame:RegisterEvent("PLAYER_FLAGS_CHANGED")
	afkModeFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
	afkModeFrame:RegisterEvent("LFG_PROPOSAL_SHOW")
	afkModeFrame:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
	afkModeFrame:SetScript("OnEvent", afkModeOnEvent)
	SetCVar("autoClearAFK", "1")

	if IsMacClient() then
		PRINT_KEYS[_G.KEY_PRINTSCREEN_MAC] = true
	end
end

Module:RegisterMisc("AFKCam", Module.CreateAFKCam)
