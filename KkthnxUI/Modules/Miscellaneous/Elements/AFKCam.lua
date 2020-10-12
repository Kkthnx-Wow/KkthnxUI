local K, C = unpack(select(2, ...))
local Module = K:GetModule("Miscellaneous")

-- Sourced: ElvUI (Elv)

local _G = _G
local math_floor = _G.math.floor
local string_format = _G.string.format
local tonumber = _G.tonumber
local math_random = _G.math.random

local C_Calendar_GetNumPendingInvites =_G.C_Calendar.GetNumPendingInvites
local C_DateAndTime_GetCurrentCalendarTime = _G.C_DateAndTime.GetCurrentCalendarTime
local C_PetBattles_IsInBattle = _G.C_PetBattles.IsInBattle
local CinematicFrame = _G.CinematicFrame
local CloseAllWindows = _G.CloseAllWindows
local CreateFrame = _G.CreateFrame
local GetAchievementInfo = _G.GetAchievementInfo
local GetBattlefieldStatus = _G.GetBattlefieldStatus
local GetCVarBool =_G.GetCVarBool
local GetGameTime =_G.GetGameTime
local GetGuildInfo = _G.GetGuildInfo
local GetScreenHeight = _G.GetScreenHeight
local GetScreenWidth = _G.GetScreenWidth
local GetStatistic = _G.GetStatistic
local GetTime = _G.GetTime
local InCombatLockdown = _G.InCombatLockdown
local IsInGuild = _G.IsInGuild
local IsMacClient = _G.IsMacClient
local IsPlayerAtEffectiveMaxLevel = _G.IsPlayerAtEffectiveMaxLevel
local IsXPUserDisabled = _G.IsXPUserDisabled
local MovieFrame = _G.MovieFrame
local NONE = _G.NONE
local PVEFrame_ToggleFrame = _G.PVEFrame_ToggleFrame
local Screenshot = _G.Screenshot
local SetCVar = _G.SetCVar
local TIMEMANAGER_TICKER_12HOUR = _G.TIMEMANAGER_TICKER_12HOUR
local TIMEMANAGER_TICKER_24HOUR = _G.TIMEMANAGER_TICKER_24HOUR
local UnitCastingInfo = _G.UnitCastingInfo
local UnitIsAFK = _G.UnitIsAFK
local UnitLevel = _G.UnitLevel
local UnitXP = _G.UnitXP
local UnitXPMax = _G.UnitXPMax

local ignoreKeys = {
	LALT = true,
	LSHIFT = true,
	RSHIFT = true,
}

local printKeys = {
	["PRINTSCREEN"] = true,
}

local monthAbr = {
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

local daysAbr = {
	[1] = "Sun",
	[2] = "Mon",
	[3] = "Tue",
	[4] = "Wed",
	[5] = "Thu",
	[6] = "Fri",
	[7] = "Sat",
}

-- Source wowhead.com
local stats = {
	60,		-- Total deaths
	94,		-- Quests abandoned
	97,		-- Daily quests completed
	98,		-- Quests completed
	107,	-- Creatures killed
	112,	-- Deaths from drowning
	114,	-- Deaths from falling
	115,	-- Deaths from fire and lava
	319,	-- Duels won
	320,	-- Duels lost
	326,	-- Gold from quest rewards
	328,	-- Total gold acquired
	329,	-- Auctions posted
	331,	-- Most expensive bid on auction
	332,	-- Most expensive auction sold
	333,	-- Gold looted
	334,	-- Most gold ever owned
	338,	-- Vanity pets owned
	345,	-- Health potions consumed
	349,	-- Flight paths taken
	353,	-- Number of times hearthed
	588,	-- Total Honorable Kills
	812,	-- Healthstones used
	837,	-- Arenas won
	838,	-- Arenas played
	839,	-- Battlegrounds played
	840,	-- Battlegrounds won
	919,	-- Gold earned from auctions
	932,	-- Total 5-player dungeons entered
	933,	-- Total 10-player raids entered
	934,	-- Total 25-player raids entered
	1042,	-- Number of hugs
	1045,	-- Total cheers
	1047,	-- Total facepalms
	1065,	-- Total waves
	1066,	-- Total times LOL'd
	1197,	-- Total kills
	1198,	-- Total kills that grant experience or honor
	1336,	-- Creature type killed the most
	1339,	-- Mage portal taken most
	1487,	-- Total Killing Blows
	1491,	-- Battleground Killing Blows
	1518,	-- Fish caught
	1776,	-- Food eaten most
	2277,	-- Summons accepted
	5692,	-- Rated battlegrounds played
	5693,	-- Rated battleground played the most
	5695,	-- Rated battleground won the most
	5694,	-- Rated battlegrounds won
	7399,	-- Challenge mode dungeons completed
	8278,	-- Pet Battles won at max level
}

if IsMacClient() then
	printKeys[_G.KEY_PRINTSCREEN_MAC] = true
end

-- Follow Time DataText Formatting
local function setupTime(color, hour, minute)
	if GetCVarBool("timeMgrUseMilitaryTime") then
		return string_format(color..TIMEMANAGER_TICKER_24HOUR, hour, minute)
	else
		local timerUnit = K.MyClassColor..(hour < 12 and " AM" or " PM")

		if hour >= 12 then
			if hour > 12 then
				hour = hour - 12
			end
		else
			if hour == 0 then
				hour = 12
			end
		end

		return string_format(color..TIMEMANAGER_TICKER_12HOUR..timerUnit, hour, minute)
	end
end

local function createTime()
	local color = C_Calendar_GetNumPendingInvites() > 0 and "|cffFF0000" or ""
	local hour, minute
	if GetCVarBool("timeMgrUseLocalTime") then
		hour, minute = tonumber(date("%H")), tonumber(date("%M"))
	else
		hour, minute = GetGameTime()
	end

	Module.AFKMode.top.time:SetText(setupTime(color, hour, minute))
end

-- Create Date
local function createDate()
	local date = C_DateAndTime_GetCurrentCalendarTime()
	local presentWeekday = date.weekday
	local presentMonth = date.month
	local presentDay = date.monthDay
	local presentYear = date.year

	Module.AFKMode.top.date:SetFormattedText("%s, %s %d, %d", daysAbr[presentWeekday], monthAbr[presentMonth], presentDay, presentYear)
end

-- Create random stats
local function createStats()
	local id = stats[math_random(#stats)]
	local _, name = GetAchievementInfo(id)
	local result = GetStatistic(id)
	if result == "--" then
		result = NONE
	end

	return string_format("%s: |cfff0ff00%s|r", name, result)
end

function Module:UpdateStatMessage()
	K.UIFrameFadeIn(Module.AFKMode.statMsg.info, 1, 1, 0)
	local createdStat = createStats()
	Module.AFKMode.statMsg.info:SetText(createdStat)
	K.UIFrameFadeIn(Module.AFKMode.statMsg.info, 1, 0, 1)
end

function Module:UpdateTimer()
	-- Set time
	createTime()
	-- Set Date
	createDate()

	local time = GetTime() - Module.startTime
	Module.AFKMode.bottom.time:SetFormattedText("%02d:%02d", math_floor(time / 60), time % 60)
end

-- XP string
local function GetXPinfo()
	if IsPlayerAtEffectiveMaxLevel() or IsXPUserDisabled() then
		return
	end

	local cur, max = UnitXP('player'), UnitXPMax('player')
	if max <= 0 then max = 1 end
	local curlvl = UnitLevel('player')

	return string_format("|cfff0ff00%d%%|r (%s) %s |cfff0ff00%d|r", (max - cur) / max * 100, K.ShortValue(max - cur), "remaining till level", curlvl + 1)
end

function Module:SetAFK(status)
	if status then
		Module.AFKMode:Show()
		CloseAllWindows()
		_G.UIParent:Hide()

		if IsInGuild() then
			local guildName, guildRankName = GetGuildInfo("player")
			Module.AFKMode.bottom.guild:SetFormattedText("%s - %s", guildName, guildRankName)
		else
			Module.AFKMode.bottom.guild:SetText("No Guild")
		end

		if GetXPinfo() then
			Module.AFKMode.top.xp:Show()
			Module.AFKMode.top.xp:SetText(GetXPinfo())
		else
			Module.AFKMode.top.xp:Show()
			Module.AFKMode.top.xp:SetText("")
		end

		Module.AFKMode.bottom.modelPlayer.curAnimation = "wave"
		Module.AFKMode.bottom.modelPlayer.startTime = GetTime()
		Module.AFKMode.bottom.modelPlayer.duration = 2.3
		Module.AFKMode.bottom.modelPlayer:SetUnit("player")
		Module.AFKMode.bottom.modelPlayer.isIdle = nil
		Module.AFKMode.bottom.modelPlayer:SetAnimation(67)
		Module.AFKMode.bottom.modelPlayer.idleDuration = 40

		Module.AFKMode.bottom.modelPet:SetUnit("pet")
		Module.AFKMode.bottom.modelPet:SetAnimation(0)

		Module.startTime = GetTime()
		K.ScheduleRepeatingTimer(Module.timer, Module.UpdateTimer, 1)
		K.ScheduleRepeatingTimer(Module.statsTimer, Module.UpdateStatMessage, 6)

		Module.isAFK = true
	elseif Module.isAFK then
		_G.UIParent:Show()
		Module.AFKMode:Hide()

		K.CancelTimer(Module, Module.timer)
		K.CancelTimer(Module, Module.statsTimer)
		K.CancelTimer(Module, Module.animTimer)

		Module.AFKMode.bottom.time:SetText("00:00")
		Module.AFKMode.statMsg.info:SetFormattedText("|cffb3b3b3%s|r", "Random Stats")

		if _G.PVEFrame:IsShown() then -- odd bug, frame is blank
			PVEFrame_ToggleFrame()
			PVEFrame_ToggleFrame()
		end

		Module.isAFK = false
	end
end

function Module:OnEvent(event, ...)
	if event == "PLAYER_REGEN_DISABLED" or event == "LFG_PROPOSAL_SHOW" or event == "UPDATE_BATTLEFIELD_STATUS" then
		if event ~= "UPDATE_BATTLEFIELD_STATUS" or (GetBattlefieldStatus(...) == "confirm") then
			Module:SetAFK(false)
		end

		if event == "PLAYER_REGEN_DISABLED" then
			Module:RegisterEvent("PLAYER_REGEN_ENABLED", Module.OnEvent)
		end

		return
	end

	if event == "PLAYER_REGEN_ENABLED" then
		K:UnregisterEvent("PLAYER_REGEN_ENABLED", Module.OnEvent)
	end

	if not C["Misc"].AFKCamera or (InCombatLockdown() or CinematicFrame:IsShown() or MovieFrame:IsShown()) then
		return
	end

	if UnitCastingInfo("player") then -- Don"t activate afk if player is crafting stuff, check back in 30 seconds
		K.ScheduleTimer(Module, Module.OnEvent, 30)
		return
	end

	Module:SetAFK(UnitIsAFK("player") and not C_PetBattles_IsInBattle())
end

function Module:AFKToggle()
	if (C["Misc"].AFKCamera) then
		K:RegisterEvent("PLAYER_FLAGS_CHANGED", Module.OnEvent)
		K:RegisterEvent("PLAYER_REGEN_DISABLED", Module.OnEvent)
		K:RegisterEvent("LFG_PROPOSAL_SHOW", Module.OnEvent)
		K:RegisterEvent("UPDATE_BATTLEFIELD_STATUS", Module.OnEvent)
		SetCVar("autoClearAFK", "1")
	else
		K:UnregisterEvent("PLAYER_FLAGS_CHANGED", Module.OnEvent)
		K:UnregisterEvent("PLAYER_REGEN_DISABLED", Module.OnEvent)
		K:UnregisterEvent("LFG_PROPOSAL_SHOW", Module.OnEvent)
		K:UnregisterEvent("UPDATE_BATTLEFIELD_STATUS", Module.OnEvent)
	end
end

local function OnKeyDown(_, key)
	if ignoreKeys[key] then
		return
	end

	if printKeys[key] then
		Screenshot()
	else
		Module:SetAFK(false)
		K.ScheduleTimer(Module, Module.OnEvent, 60)
	end
end

function Module:LoopAnimations()
	local KKUI_AFKPlayerModel = _G.KKUI_AFKPlayerModel
	if KKUI_AFKPlayerModel.curAnimation == "wave" then
		KKUI_AFKPlayerModel:SetAnimation(69)
		KKUI_AFKPlayerModel.curAnimation = "dance"
		KKUI_AFKPlayerModel.startTime = GetTime()
		KKUI_AFKPlayerModel.duration = 300
		KKUI_AFKPlayerModel.isIdle = false
		KKUI_AFKPlayerModel.idleDuration = 120
	end
end

function Module:CreateAFKCam()
	local classColor = K.MyClassColor
	local playerClass = UnitClass("player")

	Module.AFKMode = CreateFrame("Frame", "KKUI_AFKFrame")
	Module.AFKMode:SetFrameLevel(5)
	Module.AFKMode:SetScale(_G.UIParent:GetScale())
	Module.AFKMode:SetAllPoints(_G.UIParent)
	Module.AFKMode:Hide()
	Module.AFKMode:EnableKeyboard(true)
	Module.AFKMode:SetScript("OnKeyDown", OnKeyDown)

	Module.AFKMode.top = CreateFrame("Frame", nil, Module.AFKMode)
	Module.AFKMode.top:SetFrameLevel(Module.AFKMode:GetFrameLevel() - 1)
	Module.AFKMode.top:SetSize(UIParent:GetWidth() + 8, 54)
	Module.AFKMode.top:SetPoint("TOP", Module.AFKMode, 0, 6)
	Module.AFKMode.top:CreateBorder()

	Module.AFKMode.bottom = CreateFrame("Frame", nil, Module.AFKMode)
	Module.AFKMode.bottom:SetFrameLevel(Module.AFKMode:GetFrameLevel() - 1)
	Module.AFKMode.bottom:CreateBorder()
	Module.AFKMode.bottom:SetPoint("BOTTOM", Module.AFKMode, "BOTTOM", 0, -6)
	Module.AFKMode.bottom:SetSize(UIParent:GetWidth() + 12, 108)

	-- Server/Local Time text
	Module.AFKMode.top.time = Module.AFKMode.top:CreateFontString(nil, "OVERLAY")
	Module.AFKMode.top.time:FontTemplate(nil, 16)
	Module.AFKMode.top.time:SetText("")
	Module.AFKMode.top.time:SetPoint("RIGHT", Module.AFKMode.top, "RIGHT", -20, 0)
	Module.AFKMode.top.time:SetJustifyH("LEFT")
	Module.AFKMode.top.time:SetTextColor(0.7, 0.7, 0.7)

	-- Date text
	Module.AFKMode.top.date = Module.AFKMode.top:CreateFontString(nil, "OVERLAY")
	Module.AFKMode.top.date:FontTemplate(nil, 16)
	Module.AFKMode.top.date:SetText("")
	Module.AFKMode.top.date:SetPoint("LEFT", Module.AFKMode.top, "LEFT", 20, 0)
	Module.AFKMode.top.date:SetJustifyH("RIGHT")
	Module.AFKMode.top.date:SetTextColor(0.7, 0.7, 0.7)

	-- XP info
	Module.AFKMode.top.xp = Module.AFKMode:CreateFontString(nil, "OVERLAY")
	Module.AFKMode.top.xp:FontTemplate(nil, 16)
	Module.AFKMode.top.xp:SetPoint("CENTER", Module.AFKMode.top, "CENTER")
	Module.AFKMode.top.xp:SetJustifyH("CENTER")
	Module.AFKMode.top.xp:SetText(GetXPinfo())
	Module.AFKMode.top.xp:SetTextColor(0.7, 0.7, 0.7)

	Module.AFKMode.bottom.logo = Module.AFKMode:CreateTexture(nil, "OVERLAY")
	Module.AFKMode.bottom.logo:SetSize(320, 150)
	Module.AFKMode.bottom.logo:SetPoint("CENTER", Module.AFKMode.bottom, "CENTER", 0, 55)
	Module.AFKMode.bottom.logo:SetTexture(C["Media"].Logo)

	local factionGroup, size, offsetX, offsetY, nameOffsetX, nameOffsetY = K.Faction, 140, -20, -16, -10, -32
	if factionGroup == "Neutral" then
		factionGroup, size, offsetX, offsetY, nameOffsetX, nameOffsetY = "Panda", 90, 15, 10, 20, -5
	end

	Module.AFKMode.bottom.faction = Module.AFKMode.bottom:CreateTexture(nil, "OVERLAY")
	Module.AFKMode.bottom.faction:SetPoint("BOTTOMLEFT", Module.AFKMode.bottom, "BOTTOMLEFT", offsetX, offsetY)
	Module.AFKMode.bottom.faction:SetTexture(string_format([[Interface\Timer\%s-Logo]], factionGroup))
	Module.AFKMode.bottom.faction:SetSize(size, size)

	Module.AFKMode.bottom.name = Module.AFKMode.bottom:CreateFontString(nil, "OVERLAY")
	Module.AFKMode.bottom.name:FontTemplate(nil, 20)
	Module.AFKMode.bottom.name:SetFormattedText(classColor.."%s - %s", K.Name, K.Realm)
	Module.AFKMode.bottom.name:SetPoint("TOPLEFT", Module.AFKMode.bottom.faction, "TOPRIGHT", nameOffsetX, nameOffsetY)

	Module.AFKMode.bottom.playerInfo = Module.AFKMode.bottom:CreateFontString(nil, "OVERLAY")
	Module.AFKMode.bottom.playerInfo:FontTemplate(nil, 20)
	Module.AFKMode.bottom.playerInfo:SetText(K.SystemColor..LEVEL.." "..K.Level.."|r "..K.GreyColor..K.Race.."|r "..classColor..playerClass.."|r")
	Module.AFKMode.bottom.playerInfo:SetPoint("TOPLEFT", Module.AFKMode.bottom.name, "BOTTOMLEFT", 0, -6)

	Module.AFKMode.bottom.guild = Module.AFKMode.bottom:CreateFontString(nil, "OVERLAY")
	Module.AFKMode.bottom.guild:FontTemplate(nil, 20)
	Module.AFKMode.bottom.guild:SetText("No Guild")
	Module.AFKMode.bottom.guild:SetPoint("TOPLEFT", Module.AFKMode.bottom.playerInfo, "BOTTOMLEFT", 0, -6)
	Module.AFKMode.bottom.guild:SetTextColor(0.7, 0.7, 0.7)

	Module.AFKMode.bottom.time = Module.AFKMode.bottom:CreateFontString(nil, "OVERLAY")
	Module.AFKMode.bottom.time:FontTemplate(nil, 20)
	Module.AFKMode.bottom.time:SetText("00:00")
	Module.AFKMode.bottom.time:SetPoint("BOTTOM", Module.AFKMode.bottom, "BOTTOM", 0, 20)
	Module.AFKMode.bottom.time:SetTextColor(0.7, 0.7, 0.7)

	-- Random stats decor (taken from install routine)
	Module.AFKMode.statMsg = CreateFrame("Frame", nil, Module.AFKMode)
	Module.AFKMode.statMsg:SetSize(418, 72)
	Module.AFKMode.statMsg:SetPoint("CENTER", 0, 260)

	Module.AFKMode.statMsg.bg = Module.AFKMode.statMsg:CreateTexture(nil, "BACKGROUND")
	Module.AFKMode.statMsg.bg:SetTexture([[Interface\LevelUp\LevelUpTex]])
	Module.AFKMode.statMsg.bg:SetPoint("BOTTOM")
	Module.AFKMode.statMsg.bg:SetSize(326, 103)
	Module.AFKMode.statMsg.bg:SetTexCoord(0.00195313, 0.63867188, 0.03710938, 0.23828125)
	Module.AFKMode.statMsg.bg:SetVertexColor(1, 1, 1, 0.7)

	Module.AFKMode.statMsg.lineTop = Module.AFKMode.statMsg:CreateTexture(nil, "BACKGROUND")
	Module.AFKMode.statMsg.lineTop:SetDrawLayer("BACKGROUND", 2)
	Module.AFKMode.statMsg.lineTop:SetTexture([[Interface\LevelUp\LevelUpTex]])
	Module.AFKMode.statMsg.lineTop:SetPoint("TOP")
	Module.AFKMode.statMsg.lineTop:SetSize(418, 7)
	Module.AFKMode.statMsg.lineTop:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)

	Module.AFKMode.statMsg.lineBottom = Module.AFKMode.statMsg:CreateTexture(nil, "BACKGROUND")
	Module.AFKMode.statMsg.lineBottom:SetDrawLayer("BACKGROUND", 2)
	Module.AFKMode.statMsg.lineBottom:SetTexture([[Interface\LevelUp\LevelUpTex]])
	Module.AFKMode.statMsg.lineBottom:SetPoint("BOTTOM")
	Module.AFKMode.statMsg.lineBottom:SetSize(418, 7)
	Module.AFKMode.statMsg.lineBottom:SetTexCoord(0.00195313, 0.81835938, 0.01953125, 0.03320313)

	-- Random stats frame
	Module.AFKMode.statMsg.info = Module.AFKMode.statMsg:CreateFontString(nil, "OVERLAY")
	Module.AFKMode.statMsg.info:FontTemplate(nil, 18)
	Module.AFKMode.statMsg.info:SetPoint("CENTER", Module.AFKMode.statMsg, "CENTER", 0, -2)
	Module.AFKMode.statMsg.info:SetText(string_format("|cffb3b3b3%s|r", "Random Stats"))
	Module.AFKMode.statMsg.info:SetJustifyH("CENTER")
	Module.AFKMode.statMsg.info:SetTextColor(0.7, 0.7, 0.7)

	-- Use this frame to control position of the model
	Module.AFKMode.bottom.modelPlayerHolder = CreateFrame("Frame", nil, Module.AFKMode.bottom)
	Module.AFKMode.bottom.modelPlayerHolder:SetSize(150, 150)
	Module.AFKMode.bottom.modelPlayerHolder:SetPoint("BOTTOMRIGHT", Module.AFKMode.bottom, "BOTTOMRIGHT", -200, 220)

	Module.AFKMode.bottom.modelPlayer = CreateFrame("PlayerModel", "KKUI_AFKPlayerModel", Module.AFKMode.bottom.modelPlayerHolder)
	Module.AFKMode.bottom.modelPlayer:SetPoint("CENTER", Module.AFKMode.bottom.modelPlayerHolder, "CENTER")
	Module.AFKMode.bottom.modelPlayer:SetSize(GetScreenWidth() * 2, GetScreenHeight() * 2)
	Module.AFKMode.bottom.modelPlayer:SetCamDistanceScale(4.5)
	Module.AFKMode.bottom.modelPlayer:SetFacing(6)

	Module.AFKMode.bottom.modelPetHolder = CreateFrame("Frame", nil, Module.AFKMode.bottom)
	Module.AFKMode.bottom.modelPetHolder:SetSize(150, 150)
	Module.AFKMode.bottom.modelPetHolder:SetPoint("BOTTOMRIGHT", Module.AFKMode.bottom, "BOTTOMRIGHT", -500, 100)

	Module.AFKMode.bottom.modelPet = CreateFrame("PlayerModel", "KKUI_AFKPetModel", Module.AFKMode.bottom.modelPetHolder)
	Module.AFKMode.bottom.modelPet:SetPoint("CENTER", Module.AFKMode.bottom.modelPetHolder, "CENTER")
	Module.AFKMode.bottom.modelPet:SetSize(GetScreenWidth() * 2, GetScreenHeight() * 2)
	Module.AFKMode.bottom.modelPet:SetCamDistanceScale(9)
	Module.AFKMode.bottom.modelPet:SetFacing(6)

	Module.AFKMode.bottom.modelPlayer:SetScript("OnUpdate", function(model)
		local timePassed = GetTime() - model.startTime
		if (timePassed > model.duration) and model.isIdle ~= true then
			model:SetAnimation(0)
			model.isIdle = true
			K.ScheduleTimer(Module.animTimer, Module.LoopAnimations, model.idleDuration)
		end
	end)

	Module:AFKToggle()
	Module.isActive = false
end