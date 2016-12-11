local K, C, L = unpack(select(2, ...))

-- Wow API
local FCF_StartAlertFlash = FCF_StartAlertFlash
local InCombatLockdown = InCombatLockdown
local ShowUIPanel = ShowUIPanel
local WorldMapFrame = WorldMapFrame
local WorldMapFrame_OnHide = WorldMapFrame_OnHide
local WorldMapLevelButton_OnClick = WorldMapLevelButton_OnClick

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: LFRBrowseFrame, ScriptErrorsFrame, C_ArtifactUI, ArtifactFrame, addon, ToggleFrame
-- GLOBALS: SpellBookFrame, build, PetJournal_LoadUI, UIParent, WorldMapFrame, event
-- GLOBALS: WorldMapLevelButton

-- Turns out we can avoid the spellbook taint
-- by opening it once before we login. Thanks TukUI! :)
-- NB! taiting the GameTooltip taints the spellbook too, so DON'T! o.O
local SpellBookTaint = CreateFrame("Frame")
SpellBookTaint:RegisterEvent("ADDON_LOADED")
SpellBookTaint:SetScript("OnEvent", function(self, _, what)
	if what ~= addon then return end
	ToggleFrame(SpellBookFrame)
end)

-- Fix RemoveTalent() taint
FCF_StartAlertFlash = K.Noop

-- Fix the scale on ScriptErrorsFrame
local ScriptErrorsScale = CreateFrame("Frame")
ScriptErrorsScale:RegisterEvent("ADDON_LOADED")
ScriptErrorsScale:SetScript("OnEvent", function(self, addon)
	if K.CheckAddOn("Blizzard_DebugTools") or addon == "Blizzard_DebugTools" then
		ScriptErrorsFrame:SetParent(UIParent)
	end
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

-- Fix C_ArtifactUI.GetTotalPurchasedRanks() (by Gnarfoz)
local oldOnShow
local newOnShow

local function newOnShow(self)
	if C_ArtifactUI.GetTotalPurchasedRanks() then
		oldOnShow(self)
	else
		ArtifactFrame:Hide()
	end
end

local function artifactHook()
	if not oldOnShow then
		oldOnShow = ArtifactFrame:GetScript("OnShow")
		ArtifactFrame:SetScript("OnShow", newOnShow)
	end
end
hooksecurefunc("ArtifactFrame_LoadUI", artifactHook)

-- Fix World Map taints (by Goldpaw)
local WorldMapTaint = CreateFrame("Frame", nil, UIParent)
WorldMapTaint:RegisterEvent("PLAYER_REGEN_ENABLED")
WorldMapTaint:RegisterEvent("PLAYER_REGEN_DISABLED")
WorldMapTaint:SetScript("OnEvent", function(self)
	if event == "PLAYER_REGEN_DISABLED" then
		WorldMapFrame:UnregisterEvent("WORLD_MAP_UPDATE")
		WorldMapFrame:SetScript("OnHide", nil)
		WorldMapLevelButton:SetScript("OnClick", nil)
	elseif event == "PLAYER_REGEN_ENABLED" then
		WorldMapFrame:RegisterEvent("WORLD_MAP_UPDATE")
		WorldMapFrame:SetScript("OnHide", WorldMapFrame_OnHide)
		WorldMapLevelButton:SetScript("OnClick", WorldMapLevelButton_OnClick)
	end
end)