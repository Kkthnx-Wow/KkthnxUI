local K, C, L, _ = select(2, ...):unpack()

-- LUA API
local _G = _G

INTERFACE_ACTION_BLOCKED = ""

local FixTooltip = CreateFrame("Frame")
FixTooltip:RegisterEvent("UPDATE_BONUS_ACTIONBAR")
FixTooltip:RegisterEvent("ACTIONBAR_PAGE_CHANGED")
FixTooltip:SetScript("OnEvent", function()
	local done
	GameTooltip:HookScript("OnTooltipCleared", function(self)
		if not done and self:NumLines() == 0 then
			self:Hide()
			done = true
		end
	end)
end)

local FixTooltipBags = CreateFrame("Frame")
FixTooltipBags:RegisterEvent("BAG_UPDATE_DELAYED")
FixTooltipBags:SetScript("OnEvent", function()
	local done
	if StuffingFrameBags and StuffingFrameBags:IsShown() then
		GameTooltip:HookScript("OnTooltipCleared", function(self)
			if not done and self:NumLines() == 0 then
				self:Hide()
				done = true
			end
		end)
	end
end)

-- FIX WORLD MAP TAINTS (BY LIGHTSPARK)
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

-- FIX REMOVETALENT() TAINT
FCF_StartAlertFlash = K.Noop

WorldMapPlayerUpper:EnableMouse(false)
WorldMapPlayerLower:EnableMouse(false)

if K.Client == "ruRU" then
	_G["DeclensionFrame"]:SetFrameStrata("HIGH")
end

local TaintFix = CreateFrame("Frame")
TaintFix:SetScript("OnUpdate", function(self, elapsed)
	if LFRBrowseFrame.timeToClear then
		LFRBrowseFrame.timeToClear = nil
	end
end)

-- MISCLICKS FOR SOME POPUPS
StaticPopupDialogs.RESURRECT.hideOnEscape = nil
StaticPopupDialogs.AREA_SPIRIT_HEAL.hideOnEscape = nil
StaticPopupDialogs.PARTY_INVITE.hideOnEscape = nil
StaticPopupDialogs.PARTY_INVITE_XREALM.hideOnEscape = nil
StaticPopupDialogs.CONFIRM_SUMMON.hideOnEscape = nil
StaticPopupDialogs.ADDON_ACTION_FORBIDDEN.button1 = nil
StaticPopupDialogs.TOO_MANY_LUA_ERRORS.button1 = nil
PetBattleQueueReadyFrame.hideOnEscape = nil
PVPReadyDialog.leaveButton:Hide()
PVPReadyDialog.enterButton:ClearAllPoints()
PVPReadyDialog.enterButton:SetPoint("BOTTOM", PVPReadyDialog, "BOTTOM", 0, 25)