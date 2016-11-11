local K, C, L = select(2, ...):unpack()
if C.Misc.AFKCamera ~= true then return end

local AFKString = _G["AFK"]
local AFK = LibStub("AceAddon-3.0"):NewAddon("AFK", "AceEvent-3.0", "AceTimer-3.0")

-- WoW Lua
local _G = _G
local GetTime = GetTime
local tostring, pcall = tostring, pcall
local floor = floor
local format, strsub, gsub = string.format, string.sub, string.gsub
-- Wow API
local CinematicFrame = CinematicFrame
local CloseAllWindows = CloseAllWindows
local CreateFrame = CreateFrame
local GetBattlefieldStatus = GetBattlefieldStatus
local GetColoredName = GetColoredName
local GetGuildInfo = GetGuildInfo
local GetScreenHeight = GetScreenHeight
local GetScreenWidth = GetScreenWidth
local InCombatLockdown = InCombatLockdown
local IsInGuild = IsInGuild
local IsShiftKeyDown = IsShiftKeyDown
local MoveViewLeftStart = MoveViewLeftStart
local MoveViewLeftStop = MoveViewLeftStop
local MovieFrame = MovieFrame
local PVEFrame_ToggleFrame = PVEFrame_ToggleFrame
local RemoveExtraSpaces = RemoveExtraSpaces
local Screenshot = Screenshot
local SetCVar = SetCVar
local UnitFactionGroup = UnitFactionGroup
local UnitIsAFK = UnitIsAFK
local CUSTOM_CLASS_COLORS = CUSTOM_CLASS_COLORS
local DND = DND
local RAID_CLASS_COLORS = RAID_CLASS_COLORS

local stats = {
	60,		-- Total deaths
	97,		-- Daily quests completed
	98,		-- Quests completed
	107,	-- Creatures killed
	112,	-- Deaths from drowning
	114,	-- Deaths from falling
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
	588,	-- Total Honorable Kills
	837,	-- Arenas won
	838,	-- Arenas played
	839,	-- Battlegrounds played
	840,	-- Battlegrounds won
	919,	-- Gold earned from auctions
	931,	-- Total factions encountered
	932,	-- Total 5-player dungeons entered
	933,	-- Total 10-player raids entered
	934,	-- Total 25-player raids entered
	1042,	-- Number of hugs
	1045,	-- Total cheers
	1047,	-- Total facepalms
	1065,	-- Total waves
	1066,	-- Total times LOL'd
	1088,	-- Kael'thas Sunstrider kills (Tempest Keep)
	1149,	-- Talent tree respecs
	1197,	-- Total kills
	1098,	-- Onyxia kills (Onyxia's Lair)
	1198,	-- Total kills that grant experience or honor
	1487,	-- Killing Blows
	1491,	-- Battleground Killing Blows
	1518,	-- Fish caught
	1716,	-- Battleground with the most Killing Blows
	4687,	-- Victories over the Lich King (Icecrown 25 player)
	5692,	-- Rated battlegrounds played
	5694,	-- Rated battlegrounds won
	6167,	-- Deathwing kills (Dragon Soul)
	7399,	-- Challenge mode dungeons completed
	8278,	-- Pet Battles won at max level
	8632,	-- Garrosh Hellscream (LFR Siege of Orgrimmar)
	9430,	-- Draenor dungeons completed (final boss defeated)
	9561,	-- Draenor raid boss defeated the most
	9558,	-- Draenor raids completed (final boss defeated)
	9430,	-- Draenor dungeons completed (final boss defeated)
	9561,	-- Draenor raid boss defeated the most
	9558,	-- Draenor raids completed (final boss defeated)
	10060,	-- Garrison Followers recruited
	10181,	-- Garrision Missions completed
	10184,	-- Garrision Rare Missions completed
}

--Create Random Stats
local function createStats()
	local id = stats[random( #stats )]
	local _, name = GetAchievementInfo(id)
	local result = GetStatistic(id)
	if result == "--" then result = NONE end
	return format("%s: |cfff0ff00%s|r", name, result)
end

--Simple-Timer for Stats
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
	self.AFKMode.bottom.time:SetFormattedText("%02d:%02d", floor(time/60), time % 60)
end

function AFK:SetAFK(status)
	if(InCombatLockdown() or CinematicFrame:IsShown() or MovieFrame:IsShown()) then return end
	if(status) then
		MoveViewLeftStart(CAMERA_SPEED)
		self.AFKMode:Show()
		CloseAllWindows()
		UIParent:Hide()
		if(IsInGuild()) then
			local guildName, guildRankName = GetGuildInfo("player")
			self.AFKMode.bottom.guild:SetFormattedText("%s-%s", guildName, guildRankName)
		else
			self.AFKMode.bottom.guild:SetText(L_AFKSCREEN_NOGUILD)
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
	elseif(self.isAFK) then
		UIParent:Show()
		self.AFKMode:Hide()
		self.AFKMode.statMsginfo:Hide()
		MoveViewLeftStop()
		self:CancelTimer(self.timer)
		self:CancelTimer(self.animTimer)
		self.AFKMode.bottom.time:SetText("00:00")
		if(PVEFrame:IsShown()) then --odd bug, frame is blank
			PVEFrame_ToggleFrame()
			PVEFrame_ToggleFrame()
		end
		self.isAFK = false
	end
end

function AFK:OnEvent(event, ...)
	if(event == "PLAYER_REGEN_DISABLED" or event == "LFG_PROPOSAL_SHOW" or event == "UPDATE_BATTLEFIELD_STATUS") then
		if(event == "UPDATE_BATTLEFIELD_STATUS") then
			local status = GetBattlefieldStatus(...)
			if (status == "confirm") then
				self:SetAFK(false)
			end
		else
			self:SetAFK(false)
		end
		if(event == "PLAYER_REGEN_DISABLED") then
			self:RegisterEvent("PLAYER_REGEN_ENABLED", "OnEvent")
		end
		return
	end
	if(event == "PLAYER_REGEN_ENABLED") then
		self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	end
	if(UnitIsAFK("player")) then
		self:SetAFK(true)
	else
		self:SetAFK(false)
	end
end

function AFK:Toggle()
	if(C.Misc.AFKCamera) then
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
	if(ignoreKeys[key]) then return end
	if printKeys[key] then
		Screenshot()
	else
		AFK:SetAFK(false)
		AFK:ScheduleTimer("OnEvent", 60)
	end
end

function AFK:LoopAnimations()
	if(KkthnxUIAFKPlayerModel.curAnimation == "wave") then
		KkthnxUIAFKPlayerModel:SetAnimation(69)
		KkthnxUIAFKPlayerModel.curAnimation = "dance"
		KkthnxUIAFKPlayerModel.startTime = GetTime()
		KkthnxUIAFKPlayerModel.duration = 300
		KkthnxUIAFKPlayerModel.isIdle = false
		KkthnxUIAFKPlayerModel.idleDuration = 120
	end
end

function AFK:Initialize()
	local classColor = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[K.Class] or RAID_CLASS_COLORS[K.Class]

	self.AFKMode = CreateFrame("Frame", "KkthnxUIAFKFrame")
	self.AFKMode:SetFrameLevel(1)
	self.AFKMode:SetScale(UIParent:GetScale())
	self.AFKMode:SetAllPoints(UIParent)
	self.AFKMode:Hide()
	self.AFKMode:EnableKeyboard(true)
	self.AFKMode:SetScript("OnKeyDown", OnKeyDown)

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

	--factionGroup = "Alliance"
	local size, offsetX, offsetY = 140, -20, -16
	local nameOffsetX, nameOffsetY = -10, -28
	if factionGroup == "Neutral" then
		factionGroup = "Panda"
		size, offsetX, offsetY = 90, 15, 10
		nameOffsetX, nameOffsetY = 20, -5
	end

	-- Random stats frame
	self.AFKMode.statMsg = CreateFrame("Frame", nil, self.AFKMode)
	self.AFKMode.statMsg:SetSize(418, 72)
	self.AFKMode.statMsg:SetPoint("CENTER", 0, 200)

	self.AFKMode.statMsg.bg = self.AFKMode.statMsg:CreateTexture(nil, 'BACKGROUND')
	self.AFKMode.statMsg.bg:SetTexture([[Interface\LevelUp\LevelUpTex]])
	self.AFKMode.statMsg.bg:SetPoint('BOTTOM')
	self.AFKMode.statMsg.bg:SetSize(326, 103)
	self.AFKMode.statMsg.bg:SetTexCoord(0.00195313, 0.63867188, 0.03710938, 0.23828125)
	self.AFKMode.statMsg.bg:SetVertexColor(1, 1, 1, 0.7)

	self.AFKMode.statMsg.lineTop = self.AFKMode.statMsg:CreateTexture(nil, 'BACKGROUND')
	self.AFKMode.statMsg.lineTop:SetDrawLayer('BACKGROUND', 2)
	self.AFKMode.statMsg.lineTop:SetTexture([[Interface\LevelUp\LevelUpTex]])
	self.AFKMode.statMsg.lineTop:SetPoint("TOP")
	self.AFKMode.statMsg.lineTop:SetSize(418, 7)
	self.AFKMode.statMsg.lineTop:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)

	self.AFKMode.statMsg.lineBottom = self.AFKMode.statMsg:CreateTexture(nil, 'BACKGROUND')
	self.AFKMode.statMsg.lineBottom:SetDrawLayer('BACKGROUND', 2)
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
	self.AFKMode.statMsginfo:SetTextColor(0.9, 0.9, 0.9)
	self.AFKMode.statMsginfo:SetScript("OnUpdate", onUpdate)
	self.AFKMode.statMsginfo:Hide()

	self.AFKMode.bottom.faction = self.AFKMode.bottom:CreateTexture(nil, "OVERLAY")
	self.AFKMode.bottom.faction:SetPoint("BOTTOMLEFT", self.AFKMode.bottom, "BOTTOMLEFT", offsetX, offsetY)
	self.AFKMode.bottom.faction:SetTexture("Interface\\Timer\\"..factionGroup.."-Logo")
	self.AFKMode.bottom.faction:SetSize(size, size)

	self.AFKMode.bottom.name = self.AFKMode.bottom:CreateFontString(nil, "OVERLAY")
	self.AFKMode.bottom.name:SetFont(C.Media.Font, 20)
	self.AFKMode.bottom.name:SetFormattedText("%s-%s", K.Name, K.Realm)
	self.AFKMode.bottom.name:SetPoint("TOPLEFT", self.AFKMode.bottom.faction, "TOPRIGHT", nameOffsetX, nameOffsetY)
	self.AFKMode.bottom.name:SetTextColor(classColor.r, classColor.g, classColor.b)

	self.AFKMode.bottom.guild = self.AFKMode.bottom:CreateFontString(nil, "OVERLAY")
	self.AFKMode.bottom.guild:SetFont(C.Media.Font, 20)
	self.AFKMode.bottom.guild:SetText(L["No Guild"])
	self.AFKMode.bottom.guild:SetPoint("TOPLEFT", self.AFKMode.bottom.name, "BOTTOMLEFT", 0, -6)
	self.AFKMode.bottom.guild:SetTextColor(0.7, 0.7, 0.7)
	self.AFKMode.bottom.time = self.AFKMode.bottom:CreateFontString(nil, "OVERLAY")
	self.AFKMode.bottom.time:SetFont(C.Media.Font, 20)
	self.AFKMode.bottom.time:SetText("00:00")
	self.AFKMode.bottom.time:SetPoint("TOPLEFT", self.AFKMode.bottom.guild, "BOTTOMLEFT", 0, -6)
	self.AFKMode.bottom.time:SetTextColor(0.7, 0.7, 0.7)
	--Use this frame to control position of the model
	self.AFKMode.bottom.modelHolder = CreateFrame("Frame", nil, self.AFKMode.bottom)
	self.AFKMode.bottom.modelHolder:SetSize(150, 150)
	self.AFKMode.bottom.modelHolder:SetPoint("BOTTOMRIGHT", self.AFKMode.bottom, "BOTTOMRIGHT", -200, 220)
	self.AFKMode.bottom.model = CreateFrame("PlayerModel", "KkthnxUIAFKPlayerModel", self.AFKMode.bottom.modelHolder)
	self.AFKMode.bottom.model:SetPoint("CENTER", self.AFKMode.bottom.modelHolder, "CENTER")
	self.AFKMode.bottom.model:SetSize(GetScreenWidth() * 2, GetScreenHeight() * 2) --YES, double screen size. This prevents clipping of models. Position is controlled with the helper frame.
	self.AFKMode.bottom.model:SetCamDistanceScale(4.5) --Since the model frame is huge, we need to zoom out quite a bit.
	self.AFKMode.bottom.model:SetFacing(6)
	self.AFKMode.bottom.model:SetScript("OnUpdateModel", function(self)
		local timePassed = GetTime() - self.startTime
		if(timePassed > self.duration) and self.isIdle ~= true then
			self:SetAnimation(0)
			self.isIdle = true
			AFK.animTimer = AFK:ScheduleTimer("LoopAnimations", self.idleDuration)
		end
	end)
	self:Toggle()
	self.isActive = false
end

local Loading = CreateFrame("Frame")
Loading:RegisterEvent("PLAYER_LOGIN")
Loading:SetScript("OnEvent", function(self, event, ...)
	AFK:Initialize()
end)
