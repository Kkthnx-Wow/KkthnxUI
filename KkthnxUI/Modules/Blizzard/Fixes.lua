local K, C, L = unpack(select(2, ...))

-- Lua Wow
local _G = _G

-- Wow API
local FCF_StartAlertFlash = FCF_StartAlertFlash
local HideUIPanel = HideUIPanel
local InCombatLockdown = InCombatLockdown
local IsAddOnLoaded = IsAddOnLoaded
local ShowUIPanel = ShowUIPanel
local WorldMapFrame = WorldMapFrame
local WorldMapFrame_OnHide = WorldMapFrame_OnHide
local WorldMapLevelButton_OnClick = WorldMapLevelButton_OnClick

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: LFRBrowseFrame, ScriptErrorsFrame, C_ArtifactUI, ArtifactFrame, addon, ToggleFrame
-- GLOBALS: SpellBookFrame, build, PetJournal_LoadUI, UIParent, WorldMapFrame, event
-- GLOBALS: WorldMapLevelButton

-- Open before login to stop taint
local SpellBookTaint = CreateFrame("Frame")
SpellBookTaint:RegisterEvent("ADDON_LOADED") -- We might need to fire PLAYER_LOGIN instead?
SpellBookTaint:SetScript("OnEvent", function(event, addon)
	if addon ~= "KkthnxUI" then return end
	--Fix spellbook taint
	ShowUIPanel(SpellBookFrame)
	HideUIPanel(SpellBookFrame)
end)

-- Fix RemoveTalent() taint
FCF_StartAlertFlash = K.Noop

-- Fix the scale on ScriptErrorsFrame
local ScriptErrorsScale = CreateFrame("Frame")
ScriptErrorsScale:RegisterEvent("ADDON_LOADED")
ScriptErrorsScale:SetScript("OnEvent", function(self, addon)
	if IsAddOnLoaded("Blizzard_DebugTools") or addon == "Blizzard_DebugTools" then
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
do
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
end

-- Fix World Map taints (by lightspark)
local old_ResetZoom = _G.WorldMapScrollFrame_ResetZoom

_G.WorldMapScrollFrame_ResetZoom = function()
	if _G.InCombatLockdown() then
		_G.WorldMapFrame_Update()
		_G.WorldMapScrollFrame_ReanchorQuestPOIs()
		_G.WorldMapFrame_ResetPOIHitTranslations()
		_G.WorldMapBlobFrame_DelayedUpdateBlobs()
	else
		old_ResetZoom()
	end
end

local old_QuestMapFrame_OpenToQuestDetails = _G.QuestMapFrame_OpenToQuestDetails

_G.QuestMapFrame_OpenToQuestDetails = function(questID)
	if _G.InCombatLockdown() then
		_G.ShowUIPanel(_G.WorldMapFrame);
		_G.QuestMapFrame_ShowQuestDetails(questID)
		_G.QuestMapFrame.DetailsFrame.mapID = nil
	else
		old_QuestMapFrame_OpenToQuestDetails(questID)
	end
end

if _G.WorldMapFrame.UIElementsFrame.BountyBoard.GetDisplayLocation == _G.WorldMapBountyBoardMixin.GetDisplayLocation then
	_G.WorldMapFrame.UIElementsFrame.BountyBoard.GetDisplayLocation = function(frame)
		if _G.InCombatLockdown() then
			return
		end

		return _G.WorldMapBountyBoardMixin.GetDisplayLocation(frame)
	end
end

if _G.WorldMapFrame.UIElementsFrame.ActionButton.GetDisplayLocation == _G.WorldMapActionButtonMixin.GetDisplayLocation then
	_G.WorldMapFrame.UIElementsFrame.ActionButton.GetDisplayLocation = function(frame, useAlternateLocation)
		if _G.InCombatLockdown() then
			return
		end

		return _G.WorldMapActionButtonMixin.GetDisplayLocation(frame, useAlternateLocation)
	end
end

if _G.WorldMapFrame.UIElementsFrame.ActionButton.Refresh == _G.WorldMapActionButtonMixin.Refresh then
	_G.WorldMapFrame.UIElementsFrame.ActionButton.Refresh = function(frame)
		if _G.InCombatLockdown() then
			return
		end

		_G.WorldMapActionButtonMixin.Refresh(frame)
	end
end

_G.WorldMapFrame.questLogMode = true
_G.QuestMapFrame_Open(true)