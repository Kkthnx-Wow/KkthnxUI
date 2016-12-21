local K, C, L = unpack(select(2, ...))
if C.Misc.AFKCamera ~= true then return end

local AFKString = _G["AFK"]
local AFK = LibStub("AceAddon-3.0"):NewAddon("AFK", "AceEvent-3.0", "AceTimer-3.0")

-- WoW Lua
local _G = _G
local floor = floor
local format, strsub, gsub = string.format, string.sub, string.gsub
local GetTime = GetTime
local random = math.random
local tostring, pcall = tostring, pcall

-- Wow API
local CinematicFrame = CinematicFrame
local CloseAllWindows = CloseAllWindows
local CreateFrame = CreateFrame
local CUSTOM_CLASS_COLORS = CUSTOM_CLASS_COLORS
local DND = DND
local GetAchievementInfo = GetAchievementInfo
local GetBattlefieldStatus = GetBattlefieldStatus
local GetColoredName = GetColoredName
local GetGuildInfo = GetGuildInfo
local GetScreenHeight = GetScreenHeight
local GetScreenWidth = GetScreenWidth
local GetStatistic = GetStatistic
local InCombatLockdown = InCombatLockdown
local IsInGuild = IsInGuild
local IsShiftKeyDown = IsShiftKeyDown
local MoveViewLeftStart = MoveViewLeftStart
local MoveViewLeftStop = MoveViewLeftStop
local MovieFrame = MovieFrame
local PVEFrame_ToggleFrame = PVEFrame_ToggleFrame
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local RemoveExtraSpaces = RemoveExtraSpaces
local Screenshot = Screenshot
local SetCVar = SetCVar
local UnitFactionGroup = UnitFactionGroup
local UnitIsAFK = UnitIsAFK

-- Global variables that we don"t cache, list them here for mikk"s FindGlobals script
-- GLOBALS: UIParent, PVEFrame, ChatTypeInfo, NONE, KkthnxUIAFKPlayerModel, UIFrameFadeIn

local stats = {
	1042,	-- Number of hugs
	1045,	-- Total cheers
	1047,	-- Total facepalms
	1065,	-- Total waves
	1066,	-- Total times LOL"d
	107,	-- Creatures killed
	1088,	-- Kael"thas Sunstrider kills (Tempest Keep)
	1098,	-- Onyxia kills (Onyxia"s Lair)
	10981, -- Legion dungeons completed (final boss defeated)
	10984, -- Legion raids completed (final boss defeated)
	10986, -- Legion raid boss defeated the most
	112,	-- Deaths from drowning
	11236, -- ClassHall Missions completed
	11237, -- ClassHall Rare Missions completed
	114,	-- Deaths from falling
	11407, -- Odyn defeats (Raid Finder Trial of Valor)
	1149,	-- Talent tree respecs
	1197,	-- Total kills
	1198,	-- Total kills that grant experience or honor
	1487,	-- Killing Blows
	1491,	-- Battleground Killing Blows
	1518,	-- Fish caught
	1716,	-- Battleground with the most Killing Blows
	197, -- Total damage done
	2219, -- Total deaths in 5-player Heroic dungeons
	318, -- Total deaths from opposite faction
	319,	-- Duels won
	320,	-- Duels lost
	321,	-- Total raid and dungeon deaths
	326,	-- Gold from quest rewards
	328,	-- Total gold acquired
	333,	-- Gold looted
	334,	-- Most gold ever owned
	338,	-- Vanity pets owned
	339,	-- Mounts owned
	342,	-- Epic items acquired
	349,	-- Flight paths taken
	377,	-- Most factions at Exalted
	4687,	-- Victories over the Lich King (Icecrown 25 player)
	5692,	-- Rated battlegrounds played
	5694,	-- Rated battlegrounds won
	588,	-- Total Honorable Kills
	60,		-- Total deaths
	6167,	-- Deathwing kills (Dragon Soul)
	7399,	-- Challenge mode dungeons completed
	8278,	-- Pet Battles won at max level
	837,	-- Arenas won
	838,	-- Arenas played
	839,	-- Battlegrounds played
	840,	-- Battlegrounds won
	8632,	-- Garrosh Hellscream (LFR Siege of Orgrimmar)
	919,	-- Gold earned from auctions
	931,	-- Total factions encountered
	932,	-- Total 5-player dungeons entered
	933,	-- Total 10-player raids entered
	934,	-- Total 25-player raids entered
	97,		-- Daily quests completed
	98,		-- Quests completed
}

-- Create Time
local function createTime()
	local hour, hour24, minute, ampm = tonumber(date("%I")), tonumber(date("%H")), tonumber(date("%M")), date("%p"):lower()
	local sHour, sMinute = GetGameTime()

	local localTime = format("|cffb3b3b3%s|r %d:%02d|cffb3b3b3%s|r", TIMEMANAGER_TOOLTIP_LOCALTIME, hour, minute, ampm)
	local localTime24 = format("|cffb3b3b3%s|r %02d:%02d", TIMEMANAGER_TOOLTIP_LOCALTIME, hour24, minute)
	local realmTime = format("|cffb3b3b3%s|r %d:%02d|cffb3b3b3%s|r", TIMEMANAGER_TOOLTIP_REALMTIME, sHour, sMinute, ampm)
	local realmTime24 = format("|cffb3b3b3%s|r %02d:%02d", TIMEMANAGER_TOOLTIP_REALMTIME, sHour, sMinute)

	if C.DataText.LocalTime then
		if C.DataText.Time24Hr then
			return localTime24
		else
			return localTime
		end
	else
		if C.DataText.Time24Hr then
			return realmTime24
		else
			return realmTime
		end
	end
end

local monthAbr = {
	[1] = L.AFKScreen.Jan,
	[2] = L.AFKScreen.Feb,
	[3] = L.AFKScreen.Mar,
	[4] = L.AFKScreen.Apr,
	[5] = L.AFKScreen.May,
	[6] = L.AFKScreen.Jun,
	[7] = L.AFKScreen.Jul,
	[8] = L.AFKScreen.Aug,
	[9] = L.AFKScreen.Sep,
	[10] = L.AFKScreen.Oct,
	[11] = L.AFKScreen.Nov,
	[12] = L.AFKScreen.Dec,
}

local daysAbr = {
	[1] = L.AFKScreen.Sun,
	[2] = L.AFKScreen.Mon,
	[3] = L.AFKScreen.Tue,
	[4] = L.AFKScreen.Wed,
	[5] = L.AFKScreen.Thu,
	[6] = L.AFKScreen.Fri,
	[7] = L.AFKScreen.Sat,
}

-- </ Create Date > --
local function createDate()
	local curDayName, curMonth, curDay, curYear = CalendarGetDate()
	AFK.AFKMode.top.date:SetFormattedText("%s, %s %d, %d", daysAbr[curDayName], monthAbr[curMonth], curDay, curYear)
end

-- </ Create Random Stats > --
local function createStats()
	local id = stats[random( #stats )]
	local _, name = GetAchievementInfo(id)
	local result = GetStatistic(id)
	if result == "--" then result = NONE end
	return format("%s: |cfff0ff00%s|r", name, result)
end

local active
local function getSpec()
	local specIndex = GetSpecialization();
	if not specIndex then return end
	active = GetActiveSpecGroup()
	local talent = ""
	local i = GetSpecialization(false, false, active)
	if i then
		i = select(2, GetSpecializationInfo(i))
		if(i) then
			talent = format("%s", i)
		end
	end
	return format("%s", talent)
end

-- </ Simple-Timer for Stats > --
local showTime = 5
local total = 0
local function onUpdate(self, elapsed)
	total = total + elapsed
	if total >= showTime then
		local createdStat = createStats()
		self:AddMessage(createdStat)
		UIFrameFadeIn(self, 1, 0, 1)
		total = 0
	end
end

local CAMERA_SPEED = 0.035
local ignoreKeys = {
	LALT = true,
	LSHIFT = true,
	RSHIFT = true,
}

local printKeys = {
	["PRINTSCREEN"] = true,
}

if IsMacClient() then
	printKeys[_G["KEY_PRINTSCREEN_MAC"]] = true
end

function AFK:UpdateTimer()
	local time = GetTime() - self.startTime

	local createdTime = createTime()

	-- </ Set Time > --
	self.AFKMode.top.time:SetFormattedText(createdTime)

	-- </ Set Date > --
	createDate()

	self.AFKMode.bottom.time:SetFormattedText("%02d:%02d", floor(time/60), time % 60)
end

function AFK:SetAFK(status)
	if (InCombatLockdown() or CinematicFrame:IsShown() or MovieFrame:IsShown()) then return end
	if (status) then
		MoveViewLeftStart(CAMERA_SPEED)
		self.AFKMode:Show()
		CloseAllWindows()
		UIParent:Hide()
		if (IsInGuild()) then
			local guildName, guildRankName = GetGuildInfo("player")
			self.AFKMode.bottom.guild:SetFormattedText("%s-%s", guildName, guildRankName)
		else
			self.AFKMode.bottom.guild:SetText(L.AFKScreen.NoGuild)
		end
		self.AFKMode.bottom.model.curAnimation = "wave"
		self.AFKMode.bottom.model.startTime = GetTime()
		self.AFKMode.bottom.model.duration = 2.3
		self.AFKMode.bottom.model:SetUnit("player")
		self.AFKMode.bottom.model.isIdle = nil
		self.AFKMode.bottom.model:SetAnimation(67)
		self.AFKMode.bottom.model.idleDuration = 40
		self.startTime = GetTime()
		self.timer = self:ScheduleRepeatingTimer("UpdateTimer", 1)
		self.AFKMode.statMsginfo:Show()
		self.isAFK = true
	elseif (self.isAFK) then
		UIParent:Show()
		self.AFKMode:Hide()
		self.AFKMode.statMsginfo:Hide()
		MoveViewLeftStop()
		self:CancelTimer(self.timer)
		self:CancelTimer(self.animTimer)
		self.AFKMode.bottom.time:SetText("00:00")
		if (PVEFrame:IsShown()) then -- </ odd bug, frame is blank > --
			PVEFrame_ToggleFrame()
			PVEFrame_ToggleFrame()
		end
		self.isAFK = false
	end
end

function AFK:OnEvent(event, ...)
	if (event == "PLAYER_REGEN_DISABLED" or event == "LFG_PROPOSAL_SHOW" or event == "UPDATE_BATTLEFIELD_STATUS") then
		if (event == "UPDATE_BATTLEFIELD_STATUS") then
			local status = GetBattlefieldStatus(...)
			if (status == "confirm") then
				self:SetAFK(false)
			end
		else
			self:SetAFK(false)
		end
		if (event == "PLAYER_REGEN_DISABLED") then
			self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnEvent")
		end
		return
	end
	if (event == "PLAYER_REGEN_ENABLED") then
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	end
	if (UnitIsAFK("player")) then
		self:SetAFK(true)
	else
		self:SetAFK(false)
	end
end

function AFK:Toggle()
	if (C.Misc.AFKCamera) then
		self:RegisterEvent("PLAYER_FLAGS_CHANGED", "OnEvent")
		self:RegisterEvent("PLAYER_REGEN_DISABLED", "OnEvent")
		self:RegisterEvent("LFG_PROPOSAL_SHOW", "OnEvent")
		self:RegisterEvent("UPDATE_BATTLEFIELD_STATUS", "OnEvent")
		SetCVar("autoClearAFK", "1")
	else
		self:UnregisterEvent("PLAYER_FLAGS_CHANGED")
		self:UnregisterEvent("PLAYER_REGEN_DISABLED")
		self:UnregisterEvent("LFG_PROPOSAL_SHOW")
		self:UnregisterEvent("UPDATE_BATTLEFIELD_STATUS")
	end
end

local function OnKeyDown(self, key)
	if (ignoreKeys[key]) then return end
	if printKeys[key] then
		Screenshot()
	else
		AFK:SetAFK(false)
		AFK:ScheduleTimer("OnEvent", 60)
	end
end

function AFK:LoopAnimations()
	if (KkthnxUIAFKPlayerModel.curAnimation == "wave") then
		KkthnxUIAFKPlayerModel:SetAnimation(69)
		KkthnxUIAFKPlayerModel.curAnimation = "dance"
		KkthnxUIAFKPlayerModel.startTime = GetTime()
		KkthnxUIAFKPlayerModel.duration = 300
		KkthnxUIAFKPlayerModel.isIdle = false
		KkthnxUIAFKPlayerModel.idleDuration = 120
	end
end

function AFK:Initialize()
	local level = UnitLevel("player")
	local race = UnitRace("player")
	local localizedClass = UnitClass("player")
	local spec = getSpec()

	self.AFKMode = CreateFrame("Frame", "KkthnxUIAFKFrame")
	self.AFKMode:SetFrameLevel(1)
	self.AFKMode:SetScale(UIParent:GetScale())
	self.AFKMode:SetAllPoints(UIParent)
	self.AFKMode:Hide()
	self.AFKMode:EnableKeyboard(true)
	self.AFKMode:SetScript("OnKeyDown", OnKeyDown)

	-- </ Create Top frame > --
	self.AFKMode.top = CreateFrame("Frame", nil, self.AFKMode)
	self.AFKMode.top:SetFrameLevel(0)
	self.AFKMode.top:SetTemplate("Transparent")
	self.AFKMode.top:SetBackdropBorderColor(K.Color.r, K.Color.g, K.Color.b)
	self.AFKMode.top:ClearAllPoints()
	self.AFKMode.top:SetPoint("TOP", self.AFKMode, "TOP", 0, 4)
	self.AFKMode.top:SetWidth(GetScreenWidth() + (4 * 2))
	self.AFKMode.top:SetHeight(GetScreenHeight() * (1 / 9.6))

	-- </ Wow Logo > --
	self.AFKMode.top.wowlogo = CreateFrame("Frame", nil, self.AFKMode) -- </ need this to upper the logo layer > --
	self.AFKMode.top.wowlogo:SetPoint("TOP", self.AFKMode.top, "TOP", 0, -5)
	self.AFKMode.top.wowlogo:SetFrameStrata("MEDIUM")
	self.AFKMode.top.wowlogo:SetSize(300, 150)
	self.AFKMode.top.wowlogo.tex = self.AFKMode.top.wowlogo:CreateTexture(nil, "OVERLAY")
	self.AFKMode.top.wowlogo.tex:SetAtlas("Glues-WoW-LegionLogo")
	self.AFKMode.top.wowlogo.tex:SetInside()

	-- </ Server/Local Time text > --
	self.AFKMode.top.time = self.AFKMode.top:CreateFontString(nil, "OVERLAY")
	self.AFKMode.top.time:SetFont(C.Media.Font, 20, C.Media.Font_Style)
	self.AFKMode.top.time:SetText("")
	self.AFKMode.top.time:SetPoint("RIGHT", self.AFKMode.top, "RIGHT", -20, 0)
	self.AFKMode.top.time:SetJustifyH("LEFT")
	self.AFKMode.top.time:SetTextColor(K.Color.r, K.Color.g, K.Color.b)

	-- </ Date text > --
	self.AFKMode.top.date = self.AFKMode.top:CreateFontString(nil, "OVERLAY")
	self.AFKMode.top.date:SetFont(C.Media.Font, 20, C.Media.Font_Style)
	self.AFKMode.top.date:SetText("")
	self.AFKMode.top.date:SetPoint("LEFT", self.AFKMode.top, "LEFT", 20, 0)
	self.AFKMode.top.date:SetJustifyH("RIGHT")
	self.AFKMode.top.date:SetTextColor(K.Color.r, K.Color.g, K.Color.b)

	self.AFKMode.bottom = CreateFrame("Frame", nil, self.AFKMode)
	self.AFKMode.bottom:SetFrameLevel(0)
	self.AFKMode.bottom:SetTemplate("Transparent")
	self.AFKMode.bottom:SetBackdropBorderColor(K.Color.r, K.Color.g, K.Color.b)
	self.AFKMode.bottom:SetPoint("BOTTOM", self.AFKMode, "BOTTOM", 0, -4)
	self.AFKMode.bottom:SetWidth(GetScreenWidth() + (4 * 2))
	self.AFKMode.bottom:SetHeight(GetScreenHeight() * (1 / 9.6))
	self.AFKMode.bottom.logo = self.AFKMode:CreateTexture(nil, "OVERLAY")
	self.AFKMode.bottom.logo:SetSize(512 / 1.2, 256 / 1.2)
	self.AFKMode.bottom.logo:SetPoint("CENTER", self.AFKMode.bottom, "CENTER", 0, 40)
	self.AFKMode.bottom.logo:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\Logo")
	local factionGroup = UnitFactionGroup("player")

	-- </ factionGroup = "Alliance" > --
	local size, offsetX, offsetY = 140, -20, -16
	local nameOffsetX, nameOffsetY = -10, -28
	if factionGroup == "Neutral" then
		factionGroup = "Panda"
		size, offsetX, offsetY = 90, 15, 10
		nameOffsetX, nameOffsetY = 20, -5
	end

	-- </ KkthnxUI Name > --
	self.AFKMode.bottom.kkthnxui = self.AFKMode.bottom:CreateFontString(nil, "OVERLAY")
	self.AFKMode.bottom.kkthnxui:SetFont(C.Media.Font, 30, C.Media.Font_Style)
	self.AFKMode.bottom.kkthnxui:SetText(K.UIName)
	self.AFKMode.bottom.kkthnxui:SetPoint("RIGHT", self.AFKMode.bottom, "RIGHT", -25, 8)
	self.AFKMode.bottom.kkthnxui:SetTextColor(60/255, 155/255, 237/255)
	-- </ KkthnxUI Version > --
	self.AFKMode.bottom.ktext = self.AFKMode.bottom:CreateFontString(nil, "OVERLAY")
	self.AFKMode.bottom.ktext:SetFont(C.Media.Font, 17, C.Media.Font_Style)
	self.AFKMode.bottom.ktext:SetFormattedText("v%s", K.Version)
	self.AFKMode.bottom.ktext:SetPoint("TOP", self.AFKMode.bottom.kkthnxui, "BOTTOM")
	self.AFKMode.bottom.ktext:SetTextColor(0.7, 0.7, 0.7)

	-- </ Random stats frame > --
	self.AFKMode.statMsg = CreateFrame("Frame", nil, self.AFKMode)
	self.AFKMode.statMsg:SetSize(418, 72)
	self.AFKMode.statMsg:SetPoint("CENTER", 0, 200)

	self.AFKMode.statMsg.bg = self.AFKMode.statMsg:CreateTexture(nil, "BACKGROUND")
	self.AFKMode.statMsg.bg:SetTexture([[Interface\LevelUp\LevelUpTex]])
	self.AFKMode.statMsg.bg:SetPoint("BOTTOM")
	self.AFKMode.statMsg.bg:SetSize(326, 103)
	self.AFKMode.statMsg.bg:SetTexCoord(0.00195313, 0.63867188, 0.03710938, 0.23828125)
	self.AFKMode.statMsg.bg:SetVertexColor(1, 1, 1, 0.7)

	self.AFKMode.statMsg.lineTop = self.AFKMode.statMsg:CreateTexture(nil, "BACKGROUND")
	self.AFKMode.statMsg.lineTop:SetDrawLayer("BACKGROUND", 2)
	self.AFKMode.statMsg.lineTop:SetTexture([[Interface\LevelUp\LevelUpTex]])
	self.AFKMode.statMsg.lineTop:SetPoint("TOP")
	self.AFKMode.statMsg.lineTop:SetSize(418, 7)
	self.AFKMode.statMsg.lineTop:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)

	self.AFKMode.statMsg.lineBottom = self.AFKMode.statMsg:CreateTexture(nil, "BACKGROUND")
	self.AFKMode.statMsg.lineBottom:SetDrawLayer("BACKGROUND", 2)
	self.AFKMode.statMsg.lineBottom:SetTexture([[Interface\LevelUp\LevelUpTex]])
	self.AFKMode.statMsg.lineBottom:SetPoint("BOTTOM")
	self.AFKMode.statMsg.lineBottom:SetSize(418, 7)
	self.AFKMode.statMsg.lineBottom:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)

	self.AFKMode.statMsginfo = CreateFrame("ScrollingMessageFrame", "self.AFKModestatMsg.info", self.AFKMode.statMsg)
	self.AFKMode.statMsginfo:SetFont(C.Media.Font, 17, C.Media.Font_Style)
	self.AFKMode.statMsginfo:SetPoint("CENTER", self.AFKMode.statMsg, "CENTER", 0, 0)
	self.AFKMode.statMsginfo:SetSize(800, 24)
	self.AFKMode.statMsginfo:AddMessage(format("|cffb3b3b3%s|r", "Random Stats"))
	self.AFKMode.statMsginfo:SetFading(true)
	self.AFKMode.statMsginfo:SetFadeDuration(1)
	self.AFKMode.statMsginfo:SetTimeVisible(4)
	self.AFKMode.statMsginfo:SetJustifyH("CENTER")
	self.AFKMode.statMsginfo:SetTextColor(1, 1, 1)
	self.AFKMode.statMsginfo:SetScript("OnUpdate", onUpdate)
	self.AFKMode.statMsginfo:Hide()

	self.AFKMode.bottom.faction = self.AFKMode.bottom:CreateTexture(nil, "OVERLAY")
	self.AFKMode.bottom.faction:SetPoint("BOTTOMLEFT", self.AFKMode.bottom, "BOTTOMLEFT", offsetX, offsetY)
	self.AFKMode.bottom.faction:SetTexture("Interface\\Timer\\"..factionGroup.."-Logo")
	self.AFKMode.bottom.faction:SetSize(size, size)

	self.AFKMode.bottom.name = self.AFKMode.bottom:CreateFontString(nil, "OVERLAY")
	self.AFKMode.bottom.name:SetFont(C.Media.Font, 20)
	-- self.AFKMode.bottom.name:SetFormattedText("%s - %s".. "\n" .."%s %s %s %s %s", K.Name, K.Realm, LEVEL, level, race, spec, localizedClass)
	self.AFKMode.bottom.name:SetFormattedText("%s - %s", K.Name, K.Realm)
	self.AFKMode.bottom.name:SetPoint("TOPLEFT", self.AFKMode.bottom.faction, "TOPRIGHT", nameOffsetX, nameOffsetY)
	self.AFKMode.bottom.name:SetTextColor(K.Color.r, K.Color.g, K.Color.b)

	self.AFKMode.bottom.guild = self.AFKMode.bottom:CreateFontString(nil, "OVERLAY")
	self.AFKMode.bottom.guild:SetFont(C.Media.Font, 20)
	self.AFKMode.bottom.guild:SetText(L.AFKScreen.NoGuild)
	self.AFKMode.bottom.guild:SetPoint("TOPLEFT", self.AFKMode.bottom.name, "BOTTOMLEFT", 0, -6)
	self.AFKMode.bottom.guild:SetTextColor(0.7, 0.7, 0.7)
	self.AFKMode.bottom.time = self.AFKMode.bottom:CreateFontString(nil, "OVERLAY")
	self.AFKMode.bottom.time:SetFont(C.Media.Font, 20)
	self.AFKMode.bottom.time:SetText("00:00")
	self.AFKMode.bottom.time:SetPoint("TOPLEFT", self.AFKMode.bottom.guild, "BOTTOMLEFT", 0, -6)
	self.AFKMode.bottom.time:SetTextColor(0.7, 0.7, 0.7)

	-- </ Use this frame to control position of the model > --
	self.AFKMode.bottom.modelHolder = CreateFrame("Frame", nil, self.AFKMode.bottom)
	self.AFKMode.bottom.modelHolder:SetSize(150, 150)
	self.AFKMode.bottom.modelHolder:SetPoint("BOTTOMRIGHT", self.AFKMode.bottom, "BOTTOMRIGHT", -200, 220)
	self.AFKMode.bottom.model = CreateFrame("PlayerModel", "KkthnxUIAFKPlayerModel", self.AFKMode.bottom.modelHolder)
	self.AFKMode.bottom.model:SetPoint("CENTER", self.AFKMode.bottom.modelHolder, "CENTER")
	self.AFKMode.bottom.model:SetSize(GetScreenWidth() * 2, GetScreenHeight() * 2) -- </ YES, double screen size. This prevents clipping of models. Position is controlled with the helper frame. > --
	self.AFKMode.bottom.model:SetCamDistanceScale(4.5) -- </ Since the model frame is huge, we need to zoom out quite a bit > --
	self.AFKMode.bottom.model:SetFacing(6)
	self.AFKMode.bottom.model:SetScript("OnUpdateModel", function(self)
		local timePassed = GetTime() - self.startTime
		if (timePassed > self.duration) and self.isIdle ~= true then
			self:SetAnimation(0)
			self.isIdle = true
			AFK.animTimer = AFK:ScheduleTimer("LoopAnimations", self.idleDuration)
		end
	end)
	self:Toggle()
	self.isActive = false
end

local Loading = CreateFrame("Frame")

function Loading:OnEvent(event, addon)
	if (event == "PLAYER_LOGIN") then
		AFK:Initialize()
	end
end

Loading:RegisterEvent("PLAYER_LOGIN")
Loading:RegisterEvent("ADDON_LOADED")
Loading:SetScript("OnEvent", Loading.OnEvent)

if event == ("ADDON_LOADED") then
	Loading:UnregisterEvent("ADDON_LOADED")
end