local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("AFKCam", "AceEvent-3.0", "AceHook-3.0", "AceTimer-3.0")

-- Sourced: ElvUI (Elvz)

local _G = _G
local math_floor = math.floor
local string_format = string.format
local math_random = math.random

local CUSTOM_CLASS_COLORS = _G.CUSTOM_CLASS_COLORS
local CinematicFrame = _G.CinematicFrame
local CloseAllWindows = _G.CloseAllWindows
local CreateFrame = _G.CreateFrame
local GetAchievementInfo = _G.GetAchievementInfo
local GetBattlefieldStatus = _G.GetBattlefieldStatus
local GetGameTime = _G.GetGameTime
local GetGuildInfo = _G.GetGuildInfo
local GetScreenHeight = _G.GetScreenHeight
local GetScreenWidth = _G.GetScreenWidth
local GetStatistic = _G.GetStatistic
local GetTime = _G.GetTime
local InCombatLockdown = _G.InCombatLockdown
local IsInGuild = _G.IsInGuild
local IsMacClient = _G.IsMacClient
local MoveViewLeftStop = _G.MoveViewLeftStop
local MovieFrame = _G.MovieFrame
local NONE = _G.NONE
local PVEFrame_ToggleFrame = _G.PVEFrame_ToggleFrame
local RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS
local Screenshot = _G.Screenshot
local SetCVar = _G.SetCVar
local TIMEMANAGER_TOOLTIP_LOCALTIME = _G.TIMEMANAGER_TOOLTIP_LOCALTIME
local TIMEMANAGER_TOOLTIP_REALMTIME = _G.TIMEMANAGER_TOOLTIP_REALMTIME
local UIParent = _G.UIParent
local UnitCastingInfo = _G.UnitCastingInfo
local UnitIsAFK = _G.UnitIsAFK
local date = _G.date

local ignoreKeys = {
	LALT = true,
	LSHIFT = true,
	RSHIFT = true
}

local printKeys = {
	["PRINTSCREEN"] = true
}

if IsMacClient() then
	printKeys[_G["KEY_PRINTSCREEN_MAC"]] = true
end

-- Source wowhead.com
local stats = {
	10060,	-- Garrison Followers recruited
	10181,	-- Garrision Missions completed
	10184,	-- Garrision Rare Missions completed
	1042,	-- Number of hugs
	1043, 	-- Greed rolls made on loot
	1044, 	-- Need rolls made on loot
	1045,	-- Total cheers
	1047,	-- Total facepalms
	1057, 	-- Deaths in 2v2
	1065,	-- Total waves
	1066,	-- Total times LOL"d
	107,	-- Creatures killed
	108, 	-- Critters Killed
	1107, 	-- Deaths in 3v3
	1108, 	-- Deaths in 5v5
	112,	-- Deaths from drowning
	11234,	-- Class Hall Champions recruited
	11235,	-- Class Hall Troops recruited
	11236,	-- Class Hall Missions completed
	11237,	-- Class Hall Rare Missions completed
	113, 	-- Deaths from fatique
	114,	-- Deaths from falling
	1146, 	-- Gold spent on travel
	1147, 	-- Gold spent at barber shops
	1148, 	-- Gold spent on postage
	1149,	-- Talent tree respecs
	115, 	-- Deaths from fire and lava
	1150,	-- Gold spent on talent tree respecs
	1197,	-- Total kills
	1198,	-- Total kills that grant experience or honor
	1339,	-- Mage portal taken most
	1456, 	-- Fish and other things caught
	1487,	-- Killing Blows
	1491,	-- Battleground Killing Blows
	1518,	-- Fish caught
	1716,	-- Battleground with the most Killing Blows
	1745,	-- Cooking Recipes known
	2277,	-- Summons accepted
	2397, 	-- Battleground won the most
	319,	-- Duels won
	320,	-- Duels lost
	321,	-- Total raid and dungeon deaths
	326,	-- Gold from quest rewards
	328,	-- Total gold acquired
	329,	-- Auction Posted
	330, 	-- Auction Purchases
	331, 	-- Most Expensive bid on Auction
	333,	-- Gold looted
	334,	-- Most gold ever owned
	338,	-- Vanity pets owned
	339,	-- Mounts owned
	342,	-- Epic items acquired
	346, 	-- Beverages Consumed
	347, 	-- Food Eaten
	349,	-- Flight paths taken
	353,	-- Number of times hearthed
	370, 	-- Highest 2 man personal Rating
	374,	-- Highest 2 man Team Rating
	377,	-- Most factions at Exalted
	5692,	-- Rated battlegrounds played
	5694,	-- Rated battlegrounds won
	588,	-- Total Honorable Kills
	589, 	-- Highest 5 man Team Rating
	590, 	-- Highest 3 man Team Rating
	595, 	-- Highest 3 man Personal rating
	596,	-- Highest 5 man Personal rating
	60,		-- Total deaths
	7399,	-- Challenge mode dungeons completed
	8278,	-- Pet Battles won at max level
	837,	-- Arenas won
	838,	-- Arenas played
	839,	-- Battlegrounds played
	840,	-- Battlegrounds won
	919,	-- Gold earned from auctions
	921, 	-- Gold from vendors
	931,	-- Total factions encountered
	932,	-- Total 5-player dungeons entered
	933,	-- Total 10-player raids entered
	934,	-- Total 25-player raids entered
	94,		-- Quests abandoned
	97,		-- Daily quests completed
	98,		-- Quests completed
}

-- Create Time
local function createTime()
	local hour, hour24, minute, ampm = tonumber(date("%I")), tonumber(date("%H")), tonumber(date("%M")), date("%p"):lower()
	local sHour, sMinute = GetGameTime()

	local localTime = string_format("|cffb3b3b3%s|r %d:%02d|cffb3b3b3%s|r", TIMEMANAGER_TOOLTIP_LOCALTIME, hour, minute, ampm)
	local localTime24 = string_format("|cffb3b3b3%s|r %02d:%02d", TIMEMANAGER_TOOLTIP_LOCALTIME, hour24, minute)
	local realmTime = string_format("|cffb3b3b3%s|r %d:%02d|cffb3b3b3%s|r", TIMEMANAGER_TOOLTIP_REALMTIME, sHour, sMinute, ampm)
	local realmTime24 = string_format("|cffb3b3b3%s|r %02d:%02d", TIMEMANAGER_TOOLTIP_REALMTIME, sHour, sMinute)

	if C["DataText"].LocalTime then
		if C["DataText"].Time24Hr then
			return localTime24
		else
			return localTime
		end
	else
		if C["DataText"].Time24Hr then
			return realmTime24
		else
			return realmTime
		end
	end
end

-- Create random stats
local function createStats()
	local id = stats[math_random( #stats )]
	local _, name = GetAchievementInfo(id)
	local result = GetStatistic(id)

	if result == "--" then
		result = NONE
	end

	return string_format("%s: |cfff0ff00%s|r", name, result)
end

function Module:UpdateStatMessage()
	K.UIFrameFadeIn(self.AFKMode.statMsg.info, 1, 1, 0)
	local createdStat = createStats()
	self.AFKMode.statMsg.info:SetText(createdStat)
	K.UIFrameFadeIn(self.AFKMode.statMsg.info, 1, 0, 1)
end

function Module:UpdateTimer()
	local time = GetTime() - self.startTime
	local createdTime = createTime()
	self.AFKMode.top.time:SetFormattedText(createdTime)
	self.AFKMode.bottom.time:SetFormattedText("%02d:%02d", math_floor(time / 60), time % 60)
end

function Module:SetAFK(status)
	if (status) then
		self.AFKMode:Show()
		CloseAllWindows()
		UIParent:Hide()

		if (IsInGuild()) then
			local guildName, guildRankName = GetGuildInfo("player")
			self.AFKMode.bottom.guild:SetFormattedText("%s - %s", guildName, guildRankName)
		else
			self.AFKMode.bottom.guild:SetText(L["AFKCam"].NoGuild)
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
		self.statsTimer = self:ScheduleRepeatingTimer("UpdateStatMessage", 5)

		self.isAFK = true
	elseif (self.isAFK) then
		UIParent:Show()
		self.AFKMode:Hide()
		MoveViewLeftStop()

		HideUIPanel(WorldMapFrame) -- Avoid Lua errors on M keypress

		self:CancelTimer(self.timer)
		self:CancelTimer(self.animTimer)
		self:CancelTimer(self.statsTimer)
		self.AFKMode.bottom.time:SetText("00:00")

		if (PVEFrame:IsShown()) then -- odd bug, frame is blank
			PVEFrame_ToggleFrame()
			PVEFrame_ToggleFrame()
		end

		self.AFKMode.statMsg.info:SetFormattedText("|cffb3b3b3%s|r", "Random Stats")
		self.isAFK = false
	end
end

function Module:OnEvent(event, ...)
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

	if (not C["Misc"].AFKCamera) then
		return
	end

	if (InCombatLockdown() or CinematicFrame:IsShown() or MovieFrame:IsShown()) then
		return
	end

	if (UnitCastingInfo("player") ~= nil) then
		--Don"t activate afk if player is crafting stuff, check back in 30 seconds
		self:ScheduleTimer("OnEvent", 30)
		return
	end

	if (UnitIsAFK("player")) then
		self:SetAFK(true)
	else
		self:SetAFK(false)
	end
end

function Module:Toggle()
	if (C["Misc"].AFKCamera) then
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

local function OnKeyDown(_, key)
	if (ignoreKeys[key]) then
		return
	end
	if printKeys[key] then
		Screenshot()
	else
		Module:SetAFK(false)
		Module:ScheduleTimer("OnEvent", 60)
	end
end

function Module:LoopAnimations()
	if (AFKPlayerModel.curAnimation == "wave") then
		AFKPlayerModel:SetAnimation(69)
		AFKPlayerModel.curAnimation = "dance"
		AFKPlayerModel.startTime = GetTime()
		AFKPlayerModel.duration = 300
		AFKPlayerModel.isIdle = false
		AFKPlayerModel.idleDuration = 120
	end
end

function Module:OnInitialize()
	local classColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[K.Class] or RAID_CLASS_COLORS[K.Class]

	self.AFKMode = CreateFrame("Frame", "AFKFrame")
	self.AFKMode:SetFrameLevel(1)
	self.AFKMode:SetScale(UIParent:GetScale())
	self.AFKMode:SetAllPoints(UIParent)
	self.AFKMode:Hide()
	self.AFKMode:EnableKeyboard(true)
	self.AFKMode:SetScript("OnKeyDown", OnKeyDown)

	self.AFKMode.top = CreateFrame("Frame", nil, self.AFKMode)
	self.AFKMode.top:SetFrameLevel(0)
	self.AFKMode.top:CreateBorder()
	self.AFKMode.top:SetPoint("TOP", self.AFKMode, "TOP", 0, 2)
	self.AFKMode.top:SetWidth(GetScreenWidth() + (2 * 2)) -- Might be 2
	self.AFKMode.top:SetHeight(GetScreenHeight() * (1 / 18))

	self.AFKMode.bottom = CreateFrame("Frame", nil, self.AFKMode)
	self.AFKMode.bottom:SetFrameLevel(0)
	self.AFKMode.bottom:CreateBorder()
	self.AFKMode.bottom:SetPoint("BOTTOM", self.AFKMode, "BOTTOM", 0, -2) -- Might be 2
	self.AFKMode.bottom:SetWidth(GetScreenWidth() + (2 * 2)) -- Might be 2
	self.AFKMode.bottom:SetHeight(GetScreenHeight() * (1 / 10))

	-- WoW Logo
	self.AFKMode.top.wowlogo = CreateFrame("Frame", nil, self.AFKMode) -- need this to upper the logo layer
	self.AFKMode.top.wowlogo:SetPoint("TOP", self.AFKMode.top, "TOP", 0, -5)
	self.AFKMode.top.wowlogo:SetFrameStrata("MEDIUM")
	self.AFKMode.top.wowlogo:SetSize(300, 150)
	self.AFKMode.top.wowlogo.tex = self.AFKMode.top.wowlogo:CreateTexture(nil, "OVERLAY")
	local currentExpansionLevel = _G.GetClampedCurrentExpansionLevel()
	local expansionDisplayInfo = _G.GetExpansionDisplayInfo(currentExpansionLevel)
	if expansionDisplayInfo then
		self.AFKMode.top.wowlogo.tex:SetTexture(expansionDisplayInfo.logo)
	end
	self.AFKMode.top.wowlogo.tex:SetInside()

	self.AFKMode.top.vWoW = self.AFKMode.top:CreateFontString(nil, "OVERLAY")
	self.AFKMode.top.vWoW:FontTemplate(nil, 20)
	self.AFKMode.top.vWoW:SetFormattedText("Patch: |cffb3b3b3%s - %s|r", K.WowPatch, K.WowBuild)
	self.AFKMode.top.vWoW:SetPoint("LEFT", self.AFKMode.top, "LEFT", 20, 0)
	self.AFKMode.top.vWoW:SetTextColor(classColor.r, classColor.g, classColor.b)

	-- Server/Local Time text
	self.AFKMode.top.time = self.AFKMode.top:CreateFontString(nil, "OVERLAY")
	self.AFKMode.top.time:FontTemplate(nil, 20)
	self.AFKMode.top.time:SetText("")
	self.AFKMode.top.time:SetPoint("RIGHT", self.AFKMode.top, "RIGHT", -20, 0)
	self.AFKMode.top.time:SetJustifyH("LEFT")
	self.AFKMode.top.time:SetTextColor(classColor.r, classColor.g, classColor.b)

	self.AFKMode.bottom.logo = self.AFKMode:CreateTexture(nil, "OVERLAY")
	self.AFKMode.bottom.logo:SetSize(320, 150)
	self.AFKMode.bottom.logo:SetPoint("CENTER", self.AFKMode.bottom, "CENTER", 0, 54)
	self.AFKMode.bottom.logo:SetTexture(C["Media"].Logo)

	self.AFKMode.bottom.version = self.AFKMode:CreateFontString(nil, "OVERLAY")
	self.AFKMode.bottom.version:FontTemplate(nil, 20)
	self.AFKMode.bottom.version:SetText("v" .. K.Version, K.WoWBuild)
	self.AFKMode.bottom.version:SetPoint("TOP", self.AFKMode.bottom.logo, "BOTTOM", 0, 4)
	self.AFKMode.bottom.version:SetTextColor(0.7, 0.7, 0.7)

	-- Random stats decor (taken from install routine)
	self.AFKMode.statMsg = CreateFrame("Frame", nil, self.AFKMode)
	self.AFKMode.statMsg:SetSize(418, 72)
	self.AFKMode.statMsg:SetPoint("CENTER", 0, 200)

	self.AFKMode.statMsg.bg = self.AFKMode.statMsg:CreateTexture(nil, "BACKGROUND")
	self.AFKMode.statMsg.bg:SetTexture("Interface\\LevelUp\\LevelUpTex")
	self.AFKMode.statMsg.bg:SetPoint("BOTTOM")
	self.AFKMode.statMsg.bg:SetSize(326, 103)
	self.AFKMode.statMsg.bg:SetTexCoord(0.00195313, 0.63867188, 0.03710938, 0.23828125)
	self.AFKMode.statMsg.bg:SetVertexColor(1, 1, 1, 0.7)

	self.AFKMode.statMsg.lineTop = self.AFKMode.statMsg:CreateTexture(nil, "BACKGROUND")
	self.AFKMode.statMsg.lineTop:SetDrawLayer("BACKGROUND", 2)
	self.AFKMode.statMsg.lineTop:SetTexture("Interface\\LevelUp\\LevelUpTex")
	self.AFKMode.statMsg.lineTop:SetPoint("TOP")
	self.AFKMode.statMsg.lineTop:SetSize(418, 7)
	self.AFKMode.statMsg.lineTop:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)

	self.AFKMode.statMsg.lineBottom = self.AFKMode.statMsg:CreateTexture(nil, "BACKGROUND")
	self.AFKMode.statMsg.lineBottom:SetDrawLayer("BACKGROUND", 2)
	self.AFKMode.statMsg.lineBottom:SetTexture("Interface\\LevelUp\\LevelUpTex")
	self.AFKMode.statMsg.lineBottom:SetPoint("BOTTOM")
	self.AFKMode.statMsg.lineBottom:SetSize(418, 7)
	self.AFKMode.statMsg.lineBottom:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)

	local factionGroup, size, offsetX, offsetY, nameOffsetX, nameOffsetY = K.Faction, 140, -20, -16, -10, -28
	if factionGroup == "Neutral" then
		factionGroup, size, offsetX, offsetY, nameOffsetX, nameOffsetY = "Panda", 90, 15, 10, 20, -5
	end

	self.AFKMode.bottom.faction = self.AFKMode.bottom:CreateTexture(nil, "OVERLAY")
	self.AFKMode.bottom.faction:SetPoint("BOTTOMLEFT", self.AFKMode.bottom, "BOTTOMLEFT", offsetX, offsetY)
	self.AFKMode.bottom.faction:SetTexture("Interface\\Timer\\" .. factionGroup .. "-Logo")
	self.AFKMode.bottom.faction:SetSize(size, size)

	self.AFKMode.bottom.name = self.AFKMode.bottom:CreateFontString(nil, "OVERLAY")
	self.AFKMode.bottom.name:FontTemplate(nil, 20)
	self.AFKMode.bottom.name:SetFormattedText("%s - %s", K.Name, K.Realm)
	self.AFKMode.bottom.name:SetPoint("TOPLEFT", self.AFKMode.bottom.faction, "TOPRIGHT", nameOffsetX, nameOffsetY)
	self.AFKMode.bottom.name:SetTextColor(classColor.r, classColor.g, classColor.b)

	self.AFKMode.bottom.guild = self.AFKMode.bottom:CreateFontString(nil, "OVERLAY")
	self.AFKMode.bottom.guild:FontTemplate(nil, 20)
	self.AFKMode.bottom.guild:SetText(L["AFKCam"].NoGuild)
	self.AFKMode.bottom.guild:SetPoint("TOPLEFT", self.AFKMode.bottom.name, "BOTTOMLEFT", 0, -10)
	self.AFKMode.bottom.guild:SetTextColor(0.7, 0.7, 0.7)

	self.AFKMode.bottom.time = self.AFKMode.bottom:CreateFontString(nil, "OVERLAY")
	self.AFKMode.bottom.time:FontTemplate(nil, 20)
	self.AFKMode.bottom.time:SetText("00:00")
	self.AFKMode.bottom.time:SetPoint("TOPLEFT", self.AFKMode.bottom.guild, "BOTTOMLEFT", 0, -10)
	self.AFKMode.bottom.time:SetTextColor(0.7, 0.7, 0.7)

	self.AFKMode.bottom.modelHolder = CreateFrame("Frame", nil, self.AFKMode.bottom)
	self.AFKMode.bottom.modelHolder:SetSize(150, 150)
	self.AFKMode.bottom.modelHolder:SetPoint("BOTTOMRIGHT", self.AFKMode.bottom, "BOTTOMRIGHT", -200, 220)

	self.AFKMode.bottom.model = CreateFrame("PlayerModel", "AFKPlayerModel", self.AFKMode.bottom.modelHolder)
	self.AFKMode.bottom.model:SetPoint("CENTER", self.AFKMode.bottom.modelHolder, "CENTER")
	self.AFKMode.bottom.model:SetSize(GetScreenWidth() * 2, GetScreenHeight() * 2) -- YES, double screen size. This prevents clipping of models. Position is controlled with the helper frame.
	self.AFKMode.bottom.model:SetCamDistanceScale(4) -- Since the model frame is huge, we need to zoom out quite a bit.
	self.AFKMode.bottom.model:SetFacing(6)
	self.AFKMode.bottom.model:SetScript("OnUpdate", function(self)
		local timePassed = GetTime() - self.startTime
		if (timePassed > self.duration) and self.isIdle ~= true then
			self:SetAnimation(0)
			self.isIdle = true
			Module.animTimer = Module:ScheduleTimer("LoopAnimations", self.idleDuration)
		end
	end)

	-- Random stats frame
	self.AFKMode.statMsg.info = self.AFKMode.statMsg:CreateFontString(nil, "OVERLAY")
	self.AFKMode.statMsg.info:FontTemplate(nil, 18)
	self.AFKMode.statMsg.info:SetPoint("CENTER", self.AFKMode.statMsg, "CENTER", 0, -2)
	self.AFKMode.statMsg.info:SetText(string_format("|cffb3b3b3%s|r", "Random Stats"))
	self.AFKMode.statMsg.info:SetJustifyH("CENTER")
	self.AFKMode.statMsg.info:SetTextColor(0.7, 0.7, 0.7)

	self:Toggle()
	self.isActive = false
end