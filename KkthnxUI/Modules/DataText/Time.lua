local K, C, L = unpack(select(2, ...))

-- Lua API
local _G = _G
local unpack = unpack
local next = next
local pairs = pairs
local date = date
local string_format = string.format
local string_join = string.join

-- Wow API
local GetDifficultyInfo = _G.GetDifficultyInfo
local GetGameTime = _G.GetGameTime
local GetNumSavedInstances = _G.GetNumSavedInstances
local GetNumSavedWorldBosses = _G.GetNumSavedWorldBosses
local GetNumWorldPVPAreas = _G.GetNumWorldPVPAreas
local GetSavedInstanceInfo = _G.GetSavedInstanceInfo
local GetSavedWorldBossInfo = _G.GetSavedWorldBossInfo
local GetWorldPVPAreaInfo = _G.GetWorldPVPAreaInfo
local QUEUE_TIME_UNAVAILABLE = _G.QUEUE_TIME_UNAVAILABLE
local RequestRaidInfo = _G.RequestRaidInfo
local SecondsToTime = _G.SecondsToTime
local TIMEMANAGER_TOOLTIP_LOCALTIME = _G.TIMEMANAGER_TOOLTIP_LOCALTIME
local TIMEMANAGER_TOOLTIP_REALMTIME = _G.TIMEMANAGER_TOOLTIP_REALMTIME
local VOICE_CHAT_BATTLEGROUND = _G.VOICE_CHAT_BATTLEGROUND
local WINTERGRASP_IN_PROGRESS = _G.WINTERGRASP_IN_PROGRESS

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: GameTimeFrame, GameTooltip, ToggleTimeManager

local DataTextTime = CreateFrame("Frame")

local NameColor = K.RGBToHex(K.Color.r, K.Color.g, K.Color.b)
local ValueColor = K.RGBToHex(1, 1, 1, 1)

local Text = Minimap:CreateFontString(nil, "OVERLAY")
Text:SetFont(C["Media"].Font, 13, "")
Text:SetShadowOffset(1.25, -1.25)
Text:SetPoint("BOTTOM", Minimap, "BOTTOM", 0, 2)

local WORLD_BOSSES_TEXT = RAID_INFO_WORLD_BOSS.."(s)"
local APM = {TIMEMANAGER_PM, TIMEMANAGER_AM}
local europeDisplayFormat = "%s%02d|r:%s%02d|r"
local ukDisplayFormat = "%s%d|r:%s%02d|r %s%s|r"
local europeDisplayFormat_nocolor = string_join("", "%02d", ":|r%02d")
local ukDisplayFormat_nocolor = string_join("", "", "%d", ":|r%02d", " %s|r")
local lockoutInfoFormat = "%s%s |cffaaaaaa(%s, %s/%s)"
local lockoutInfoFormatNoEnc = "%s%s |cffaaaaaa(%s)"
local formatBattleGroundInfo = "%s: "
local lockoutColorExtended, lockoutColorNormal = {r = 0.3, g = 1, b = 0.3}, {r = .8,g = .8,b = .8}
local curHr, curMin, curAmPm
local enteredFrame = false

local Update, lastPanel -- UpValue
local localizedName, isActive, startTime, canEnter, _
local name, reset, difficultyId, extended, maxPlayers, numEncounters, encounterProgress

if lastPanel ~= nil then
	Update(lastPanel, 20000)
end

local function ConvertTime(h, m)
	local AmPm
	if C["DataText"].Time24Hr == true then
		return h, m, -1
	else
		if h >= 12 then
			if h > 12 then h = h - 12 end
			AmPm = 1
		else
			if h == 0 then h = 12 end
			AmPm = 2
		end
	end
	return h, m, AmPm
end

local function CalculateTimeValues(tooltip)
	if (tooltip and C["DataText"].LocalTime) or (not tooltip and not C["DataText"].LocalTime) then
		return ConvertTime(GetGameTime())
	else
		local dateTable = date("*t")
		return ConvertTime(dateTable["hour"], dateTable["min"])
	end
end

local function Click(self, btn)
	GameTimeFrame:Click()
end

local function OnLeave()
	if not GameTooltip:IsForbidden() then
		GameTooltip:Hide()
	end
	enteredFrame = false
end

local function OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint(K.GetAnchors(self))
	GameTooltip:ClearLines()

	if (not enteredFrame) then
		enteredFrame = true
		RequestRaidInfo()
	end

	GameTooltip:AddLine(VOICE_CHAT_BATTLEGROUND)
	for i = 1, GetNumWorldPVPAreas() do
		_, localizedName, isActive, _, startTime, canEnter = GetWorldPVPAreaInfo(i)
		if canEnter then
			if isActive then
				startTime = WINTERGRASP_IN_PROGRESS
			elseif startTime == nil then
				startTime = QUEUE_TIME_UNAVAILABLE
			else
				startTime = SecondsToTime(startTime, false, nil, 3)
			end
			GameTooltip:AddDoubleLine(string_format(formatBattleGroundInfo, localizedName), startTime, 1, 1, 1, lockoutColorNormal.r, lockoutColorNormal.g, lockoutColorNormal.b)
		end
	end

	local lockedInstances = {raids = {}, dungeons = {}}
	for i = 1, GetNumSavedInstances() do
		local name, instanceId, _, difficulty, locked, extended, _, isRaid, _, _, _, _  = GetSavedInstanceInfo(i)
		if (locked or extended) and name then
			if isRaid then
				lockedInstances["raids"][instanceId] = {GetSavedInstanceInfo(i)}
			elseif not isRaid and difficulty == 23 then
				lockedInstances["dungeons"][instanceId] = {GetSavedInstanceInfo(i)}
			end
		end
	end

	if next(lockedInstances["raids"]) then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Saved Raid(s)")

        for pos,instance in pairs(lockedInstances["raids"]) do
            name, _, reset, difficultyId, _, extended, _, _, maxPlayers, _, numEncounters, encounterProgress = unpack(instance)

            local lockoutColor = extended and lockoutColorExtended or lockoutColorNormal
            local _, _, isHeroic, _, displayHeroic, displayMythic = GetDifficultyInfo(difficultyId)
            if (numEncounters and numEncounters > 0) and (encounterProgress and encounterProgress > 0) then
                GameTooltip:AddDoubleLine(string_format(lockoutInfoFormat, maxPlayers, (displayMythic and "M" or (isHeroic or displayHeroic) and "H" or "N"), name, encounterProgress, numEncounters), SecondsToTime(reset, false, nil, 3), 1, 1, 1, lockoutColor.r, lockoutColor.g, lockoutColor.b)
            else
                GameTooltip:AddDoubleLine(string_format(lockoutInfoFormatNoEnc, maxPlayers, (displayMythic and "M" or (isHeroic or displayHeroic) and "H" or "N"), name), SecondsToTime(reset, false, nil, 3), 1, 1, 1, lockoutColor.r, lockoutColor.g, lockoutColor.b)
            end
        end
    end

	if next(lockedInstances["dungeons"]) then
        GameTooltip:AddLine(" ")
        GameTooltip:AddLine("Saved Dungeon(s)")

        for pos,instance in pairs(lockedInstances["dungeons"]) do
            name, _, reset, difficultyId, _, extended, _, _, maxPlayers, _, numEncounters, encounterProgress = unpack(instance)

            local lockoutColor = extended and lockoutColorExtended or lockoutColorNormal
            local _, _, isHeroic, _, displayHeroic, displayMythic = GetDifficultyInfo(difficultyId)
            if (numEncounters and numEncounters > 0) and (encounterProgress and encounterProgress > 0) then
                GameTooltip:AddDoubleLine(string_format(lockoutInfoFormat, maxPlayers, (displayMythic and "M" or (isHeroic or displayHeroic) and "H" or "N"), name, encounterProgress, numEncounters), SecondsToTime(reset, false, nil, 3), 1, 1, 1, lockoutColor.r, lockoutColor.g, lockoutColor.b)
            else
                GameTooltip:AddDoubleLine(string_format(lockoutInfoFormatNoEnc, maxPlayers, (displayMythic and "M" or (isHeroic or displayHeroic) and "H" or "N"), name), SecondsToTime(reset, false, nil, 3), 1, 1, 1, lockoutColor.r, lockoutColor.g, lockoutColor.b)
            end
        end
    end

	local addedLine = false
	for i = 1, GetNumSavedWorldBosses() do
		name, _, reset = GetSavedWorldBossInfo(i)
		if (reset) then
			if (not addedLine) then
				GameTooltip:AddLine(" ")
				GameTooltip:AddLine(WORLD_BOSSES_TEXT)
				addedLine = true
			end
			GameTooltip:AddDoubleLine(name, SecondsToTime(reset, true, nil, 3), 1, 1, 1, 0.8, 0.8, 0.8)
		end
	end

	local Hr, Min, AmPm = CalculateTimeValues(true)

	GameTooltip:AddLine(" ")
	if AmPm == -1 then
		GameTooltip:AddDoubleLine(C["DataText"].LocalTime and TIMEMANAGER_TOOLTIP_REALMTIME or TIMEMANAGER_TOOLTIP_LOCALTIME,
		string_format(europeDisplayFormat_nocolor, Hr, Min), 1, 1, 1, lockoutColorNormal.r, lockoutColorNormal.g, lockoutColorNormal.b)
	else
		GameTooltip:AddDoubleLine(C["DataText"].LocalTime and TIMEMANAGER_TOOLTIP_REALMTIME or TIMEMANAGER_TOOLTIP_LOCALTIME,
		string_format(ukDisplayFormat_nocolor, Hr, Min, APM[AmPm]), 1, 1, 1, lockoutColorNormal.r, lockoutColorNormal.g, lockoutColorNormal.b)
	end

	GameTooltip:Show()
end

local function OnEvent(self, event)
	if event == "UPDATE_INSTANCE_INFO" and enteredFrame then
		OnEnter(self)
	end
end

local int = 3
function Update(self, t)
	int = int - t

	if int > 0 then return end

	if GameTimeFrame.flashInvite then
		K.UIFrameFlash(self, 0.53, true)
	else
		K.UIFrameStopFlash(self)
	end

	if enteredFrame then
		OnEnter(self)
	end

	local Hr, Min, AmPm = CalculateTimeValues(false)

	-- no update quick exit
	if (Hr == curHr and Min == curMin and AmPm == curAmPm) and not (int < -15000) then
		int = 5
		return
	end

	curHr = Hr
	curMin = Min
	curAmPm = AmPm

	if AmPm == -1 then
		Text:SetFormattedText(europeDisplayFormat, ValueColor, Hr, ValueColor, Min)
	else
		Text:SetFormattedText(ukDisplayFormat, ValueColor, Hr, ValueColor, Min, NameColor, APM[AmPm])
	end

	self:SetAllPoints(Text)

	lastPanel = self
	int = 5
end

DataTextTime:RegisterEvent("UPDATE_INSTANCE_INFO")
DataTextTime:SetScript("OnEvent", OnEvent)
DataTextTime:SetScript("OnMouseDown", Click)
DataTextTime:SetScript("OnUpdate", Update)
DataTextTime:SetScript("OnEnter", OnEnter)
DataTextTime:SetScript("OnLeave", OnLeave)
Update(DataTextTime, 1)