local K, C = unpack(select(2, ...))
local Module = K:NewModule("PremadeAutoAccept", "AceEvent-3.0")

-- Sourced: PremadeAutoAccept (C) Kruithne <kruithne@gmail.com>

local _G = _G

local C_LFGList_GetApplicantInfo = _G.C_LFGList.GetApplicantInfo
local C_LFGList_GetApplicantMemberInfo = _G.C_LFGList.GetApplicantMemberInfo
local C_LFGList_GetApplicants = _G.C_LFGList.GetApplicants
local C_LFGList_GetNumInvitedApplicantMembers = _G.C_LFGList.GetNumInvitedApplicantMembers
local C_LFGList_GetNumPendingApplicantMembers = _G.C_LFGList.GetNumPendingApplicantMembers
local GetNumGroupMembers = _G.GetNumGroupMembers
local InviteUnit = _G.InviteUnit
local IsInRaid = _G.IsInRaid
local LFGListFrame_ApplicationViewer = _G.LFGListFrame.ApplicationViewer
local PlaySound = _G.PlaySound
local SOUNDKIT = _G.SOUNDKIT
local StaticPopup_Show = _G.StaticPopup_Show
local UnitIsGroupLeader = _G.UnitIsGroupLeader

local isAutoAccepting = false
local displayedRaidConvert = false

local function InviteApplicants()
	local applicants = C_LFGList_GetApplicants()
	for i = 1, #applicants do
		local id, status, pendingStatus, numMembers = C_LFGList_GetApplicantInfo(applicants[i])

		-- Using the premade "invite" feature does not work, as Blizzard have broken auto-accept intentionally
		-- Because of this, we can't invite groups, but we can still send normal invites to singletons.
		if numMembers == 1 and (pendingStatus or status == "applied") then
			local name = C_LFGList_GetApplicantMemberInfo(id, 1)
			InviteUnit(name)
		end
	end
end

function Module:AutoAccept()
	-- Force the auto-accept button to show even when the server says no.
	_G.C_LFGList.CanActiveEntryUseAutoAccept = function()
		return true
	end

	-- Overwrite the old handler for clicking the auto-accept button.
	LFGListFrame_ApplicationViewer.AutoAcceptButton:SetScript("OnClick", function(self)
		if self:GetChecked() then
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		else
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
		end

		isAutoAccepting = self:GetChecked()
		if isAutoAccepting then
			InviteApplicants()
		end
	end)

	-- Prevent Blizzard UI from changing the tick-state of the auto-accept button.
	local old_SetChecked = LFGListFrame_ApplicationViewer.AutoAcceptButton.SetChecked
	LFGListFrame_ApplicationViewer.AutoAcceptButton.SetChecked = function()
		old_SetChecked(LFGListFrame_ApplicationViewer.AutoAcceptButton, isAutoAccepting)
	end
end

function Module:UpdateList()
	if UnitIsGroupLeader("player", LE_PARTY_CATEGORY_HOME) then
		if isAutoAccepting then
			-- Display conversion to raid notice.
			if not displayedRaidConvert and not IsInRaid(LE_PARTY_CATEGORY_HOME) then
				local futureCount = GetNumGroupMembers(LE_PARTY_CATEGORY_HOME) + C_LFGList_GetNumInvitedApplicantMembers() + C_LFGList_GetNumPendingApplicantMembers()
				if futureCount > (MAX_PARTY_MEMBERS + 1) then
					StaticPopup_Show("LFG_LIST_AUTO_ACCEPT_CONVERT_TO_RAID")
					displayedRaidConvert = true
				end
			end

			InviteApplicants()
		end
	end

	LFGListFrame_ApplicationViewer.AutoAcceptButton:SetChecked(isAutoAccepting)
end

function Module:ADDON_LOADED()
	Module:AutoAccept()
end

function Module:GROUP_LEFT()
	isAutoAccepting = false
	displayedRaidConvert = false
end

function Module:OnEnable()
	if C["Misc"].PremadeAutoAccept ~= true then
		return
	end

	self:RegisterEvent("ADDON_LOADED")
	self:RegisterEvent("LFG_LIST_APPLICANT_LIST_UPDATED", "UpdateList")
	self:RegisterEvent("PARTY_LEADER_CHANGED", "UpdateList")
	self:RegisterEvent("GROUP_LEFT")
end

function Module:OnDisable()
	self:UnregisterEvent("ADDON_LOADED")
	self:UnregisterEvent("LFG_LIST_APPLICANT_LIST_UPDATED")
	self:UnregisterEvent("PARTY_LEADER_CHANGED")
	self:UnregisterEvent("GROUP_LEFT")
end