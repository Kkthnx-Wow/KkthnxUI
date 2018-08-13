local K, C = unpack(select(2, ...))
local Module = K:NewModule("AutoCollapse", "AceEvent-3.0")

local _G = _G

local InCombatLockdown = _G.InCombatLockdown
local IsInInstance = _G.IsInInstance
local ObjectiveTracker_Collapse = _G.ObjectiveTracker_Collapse
local ObjectiveTracker_Expand = _G.ObjectiveTracker_Expand

local trackerFrame = _G["ObjectiveTrackerFrame"]
local minimizeButton = _G["ObjectiveTrackerFrame"].HeaderMenu.MinimizeButton
function Module:ChangeState(event)
	if InCombatLockdown() and event ~= "PLAYER_REGEN_DISABLED" then
		return
	end

	if (not IsInInstance() and trackerFrame.collapsed) then
		ObjectiveTracker_Expand()
		minimizeButton:SetNormalTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\TrackerButton")
		return
	end

	if (IsInInstance() and not trackerFrame.collapsed) then
		ObjectiveTracker_Collapse()
		minimizeButton:SetNormalTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\TrackerButton")
	elseif (trackerFrame.collapsed) then
		ObjectiveTracker_Expand()
		minimizeButton:SetNormalTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\TrackerButton")
	end
end

function Module:OnEnable()
	if C["Quests"].AutoCollapse ~= true then
		return
	end

	self:RegisterEvent("LOADING_SCREEN_DISABLED", "ChangeState")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "ChangeState")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "ChangeState")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "ChangeState")
end