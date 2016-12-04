local K, C, L = select(2, ...):unpack()

-- Lua API
local _G = _G

-- Wow API
local IsAddOnLoaded = IsAddOnLoaded

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: LFRBrowseFrame, ScriptErrorsFrame, C_ArtifactUI, ArtifactFrame

-- Fix the scale on this.
local ScriptErrors = CreateFrame("Frame")
ScriptErrors:RegisterEvent("ADDON_LOADED")
ScriptErrors:SetScript("OnEvent", function(self, addon)
	if IsAddOnLoaded("Blizzard_DebugTools") or addon == "Blizzard_DebugTools" then
		ScriptErrorsFrame:SetParent(K.UIParent)
	end
end)

local TaintFix = CreateFrame("Frame")
TaintFix:SetScript("OnUpdate", function(self, elapsed)
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
PVPReadyDialog.leaveButton:Hide()
PVPReadyDialog.enterButton:ClearAllPoints()
PVPReadyDialog.enterButton:SetPoint("BOTTOM", PVPReadyDialog, "BOTTOM", 0, 25)

-- Original code (by Gnarfoz)
-- C_ArtifactUI.GetTotalPurchasedRanks() shenanigans
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
do
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

	_G.WorldMapFrame.questLogMode = true
	_G.QuestMapFrame_Open(true)
end