local K, C = unpack(select(2, ...))
local Module = K:NewModule("AutoCollapse", "AceEvent-3.0")

local _G = _G

local MAX_BOSS_FRAMES = _G.MAX_BOSS_FRAMES
local minimizeButton = _G["ObjectiveTrackerFrame"].HeaderMenu.MinimizeButton
local UnitExists = _G.UnitExists

local function BossExist()
	for i = 1, MAX_BOSS_FRAMES or 5 do
		if UnitExists("boss" .. i) then
			return true
		end
	end
end

local function ArenaExist()
	for i = 1, 5 do
		if UnitExists("arena" .. i) then
			return true
		end
	end
end

function Module:ChangeState(event)
	if (not IsInInstance()) then
		Module.trackerFrame:Show()
		minimizeButton:SetNormalTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\TrackerButton")
		return
	end

	if (event == "ENCOUNTER_START" or (event == "LOADING_SCREEN_DISABLED" and BossExist() or ArenaExist())) then
		Module.trackerFrame:Hide()
	else
		Module.trackerFrame:Show()
		minimizeButton:SetNormalTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\TrackerButton")
	end
end

function Module:OnEnable()
	if C["Automation"].AutoCollapse ~= true then
		return
	end

	Module.trackerFrame = _G["ObjectiveTrackerFrame"]

	self:RegisterEvent("ENCOUNTER_START", "ChangeState")
	self:RegisterEvent("ENCOUNTER_END", "ChangeState")
	self:RegisterEvent("LOADING_SCREEN_DISABLED", "ChangeState")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "ChangeState")

	Module:ChangeState()
end