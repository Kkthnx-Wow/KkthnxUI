local K, C, L, _ = select(2, ...):unpack()

local _G = _G
local collectgarbage = collectgarbage
local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown

INTERFACE_ACTION_BLOCKED = ""

-- Fix RemoveTalent() taint
FCF_StartAlertFlash = K.Noop

local TaintFix = CreateFrame("Frame")
TaintFix:SetScript("OnUpdate", function(self, elapsed)
	if LFRBrowseFrame.timeToClear then
		LFRBrowseFrame.timeToClear = nil
	end
end)

LFRBrowseFrameListScrollFrame:ClearAllPoints()
LFRBrowseFrameListScrollFrame:SetPoint("TOPLEFT", LFRBrowseFrameListButton1, "TOPLEFT", 0, 0)
LFRBrowseFrameListScrollFrame:SetPoint("BOTTOMRIGHT", LFRBrowseFrameListButton19, "BOTTOMRIGHT", 5, -2)
LFRQueueFrameSpecificListScrollFrame:ClearAllPoints()
LFRQueueFrameSpecificListScrollFrame:SetPoint("TOPLEFT", LFRQueueFrameSpecificListButton1, "TOPLEFT", 0, 0)
LFRQueueFrameSpecificListScrollFrame:SetPoint("BOTTOMRIGHT", LFRQueueFrameSpecificListButton14, "BOTTOMRIGHT", 0, -2)

-- Misclicks for some popups
StaticPopupDialogs.RESURRECT.hideOnEscape = nil
StaticPopupDialogs.AREA_SPIRIT_HEAL.hideOnEscape = nil
StaticPopupDialogs.PARTY_INVITE.hideOnEscape = nil
StaticPopupDialogs.CONFIRM_SUMMON.hideOnEscape = nil
StaticPopupDialogs.ADDON_ACTION_FORBIDDEN.button1 = nil
StaticPopupDialogs.TOO_MANY_LUA_ERRORS.button1 = nil
StaticPopupDialogs.CONFIRM_BATTLEFIELD_ENTRY.button2 = nil