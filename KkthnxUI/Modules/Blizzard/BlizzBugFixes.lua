local K, C, L = unpack(select(2, ...))

-- Lua Wow
local _G = _G

-- Wow API
local GetCVar = _G.GetCVar
local HideUIPanel = _G.HideUIPanel
local InCombatLockdown = _G.InCombatLockdown
local SetCVar = _G.SetCVar
local ShowUIPanel = _G.ShowUIPanel
local ToggleFrame = _G.ToggleFrame

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: UIParent, SpellBookFrame, LFRBrowseFrame

-- Fix spellbook taint in combat
local SpellBookTaint = CreateFrame("Frame")
SpellBookTaint:RegisterEvent("PLAYER_LOGIN")
SpellBookTaint:SetScript("OnEvent", function()
	-- Fix SpellBookFrame taint
	ToggleFrame(SpellBookFrame)
	ShowUIPanel(SpellBookFrame)
	HideUIPanel(SpellBookFrame)
end)

local floatingCombatText = CreateFrame("Frame")
floatingCombatText:RegisterEvent("PLAYER_ENTERING_WORLD")
floatingCombatText:SetScript("OnEvent", function()
	if (K.CheckAddOn("MikScrollingBattleText")) then return end
	-- Fix floatingCombatText not being enabled after AddOns like MSBT
	-- print(GetCVar("floatingCombatTextCombatDamage"))
	if (GetCVar("floatingCombatTextCombatDamage") ~= 1) and (not InCombatLockdown()) then
		SetCVar("floatingCombatTextCombatHealing", 1)
		SetCVar("floatingCombatTextCombatDamage", 1)
	end

floatingCombatText:UnregisterEvent("PLAYER_ENTERING_WORLD")
end)

-- Fix SearchLFGLeave() taint
local LFRBrowseTaint = CreateFrame("Frame")
LFRBrowseTaint:SetScript("OnUpdate", function(self, elapsed)
	if LFRBrowseFrame.timeToClear then
		LFRBrowseFrame.timeToClear = nil
	end
end)

-- Misclicks for some popups
StaticPopupDialogs.RESURRECT.hideOnEscape = nil
StaticPopupDialogs.AREA_SPIRIT_HEAL.hideOnEscape = nil
StaticPopupDialogs.PARTY_INVITE.hideOnEscape = nil
StaticPopupDialogs.CONFIRM_SUMMON.hideOnEscape = nil
StaticPopupDialogs.ADDON_ACTION_FORBIDDEN.button1 = nil
StaticPopupDialogs.TOO_MANY_LUA_ERRORS.button1 = nil
PetBattleQueueReadyFrame.hideOnEscape = nil
if PVPReadyDialog then
	PVPReadyDialog.leaveButton:Hide()
	PVPReadyDialog.enterButton:ClearAllPoints()
	PVPReadyDialog.enterButton:SetPoint("BOTTOM", PVPReadyDialog, "BOTTOM", 0, 25)
	PVPReadyDialog.label:SetPoint("TOP", 0, -22)
end