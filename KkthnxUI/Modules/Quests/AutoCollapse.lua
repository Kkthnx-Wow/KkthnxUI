local K, C, L = unpack(select(2, ...))
if C["Quests"].AutoCollapse ~= true then return end

-- Sourced: ElvUI Shadow & Light (Darth_Predator, Repooc)

-- Wow Lua
local _G = _G

-- Wow API
local InCombatLockdown = _G.InCombatLockdown
local IsInInstance = _G.IsInInstance
local ObjectiveTracker_Expand, ObjectiveTracker_Collapse = _G.ObjectiveTracker_Expand, _G.ObjectiveTracker_Collapse

local minimizeButton = _G["ObjectiveTrackerFrame"].HeaderMenu.MinimizeButton

local AutoCollapse = CreateFrame("Frame")
AutoCollapse:RegisterEvent("LOADING_SCREEN_DISABLED")
AutoCollapse:RegisterEvent("ZONE_CHANGED_NEW_AREA")
AutoCollapse:RegisterEvent("PLAYER_REGEN_ENABLED")
AutoCollapse:RegisterEvent("PLAYER_REGEN_DISABLED")
AutoCollapse:SetScript("OnEvent", function(self, event)
	if InCombatLockdown() and event ~= "PLAYER_REGEN_DISABLED" then
		return
	end

	local instance, instanceType = IsInInstance()

	if instance then
		if instanceType == "party" or instanceType == "scenario" or instanceType == "raid" or instanceType == "pvp" or instanceType == "arena" then
			ObjectiveTracker_Collapse()
			minimizeButton:SetNormalTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\TrackerButton")
		elseif ObjectiveTrackerFrame.collapsed and not InCombatLockdown() then
			ObjectiveTracker_Expand()
			minimizeButton:SetNormalTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\TrackerButton")
		end
	end
end)