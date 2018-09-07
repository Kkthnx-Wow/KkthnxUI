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
local autoAccepting = {}

local function InviteApplicants()
	local applicants = C_LFGList_GetApplicants()
	for i = 1, #applicants do
		local id, status, pendingStatus, numMembers = C_LFGList_GetApplicantInfo(applicants[i])

		-- Using the premade "invite" feature does not work, as Blizzard have broken auto-accept intentionally
		-- Because of this, we can't invite groups, but we can still send normal invites to singletons.
		if numMembers == 1 and (pendingStatus or status == "applied") then
			local name, _, _, _, _, _, _, _, _, assignedRole = C_LFGList_GetApplicantMemberInfo(id, 1)
			if autoAccepting[assignedRole] then
				InviteUnit(name)
			end
		end
	end
end

local function OnCheckBoxClick(self)
	isAutoAccepting = self:GetChecked()
	autoAccepting[self.role] = isAutoAccepting

	if isAutoAccepting then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		InviteApplicants()
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
	end
end

local function CreateCheckbox(atlas, role)
	local button = CreateFrame("CheckButton", nil, LFGListFrame_ApplicationViewer)
	button:SetWidth(22)
	button:SetHeight(22)
	button:Show()

	button:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
	button:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
	button:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight")
	button:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")

	button.role = role
	button:SetScript("OnClick", OnCheckBoxClick)

	local icon = button:CreateTexture(nil, "ARTWORK")
	icon:SetAtlas(atlas)
	icon:SetWidth(17)
	icon:SetHeight(17)
	icon:SetPoint("LEFT", button, "RIGHT", 2, 0)
	button.icon = icon

	return button
end

local function CreateAutoAcceptButtons()
	local header = LFGListFrame_ApplicationViewer:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	header:SetPoint("BOTTOMLEFT", LFGListFrame_ApplicationViewer.InfoBackground, "BOTTOMLEFT", 12, 30)
	header:SetText(LFG_LIST_AUTO_ACCEPT)
	header:SetJustifyH("LEFT")

	local damageButton = CreateCheckbox("groupfinder-icon-role-large-dps", "DAMAGER")
	damageButton:SetPoint("TOPLEFT", header, "BOTTOMLEFT", -3, 2)

	local healerButton = CreateCheckbox("groupfinder-icon-role-large-heal", "HEALER")
	healerButton:SetPoint("LEFT", damageButton.icon, "RIGHT", 5, 0)

	local tankButton = CreateCheckbox("groupfinder-icon-role-large-tank", "TANK")
	tankButton:SetPoint("LEFT", healerButton.icon, "RIGHT", 5, 0)
end

function Module:ApplicantListUpdate()
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
end

function Module:GROUP_LEFT()
	isAutoAccepting = false
	displayedRaidConvert = false
end

function Module:OnEnable()
	if C["Misc"].PremadeAutoAccept ~= true then
		return
	end

	CreateAutoAcceptButtons()
	self:RegisterEvent("LFG_LIST_APPLICANT_LIST_UPDATED", "ApplicantListUpdate")
	self:RegisterEvent("PARTY_LEADER_CHANGED", "ApplicantListUpdate")
	self:RegisterEvent("GROUP_LEFT")
end

function Module:OnDisable()
	self:UnregisterEvent("LFG_LIST_APPLICANT_LIST_UPDATED")
	self:UnregisterEvent("PARTY_LEADER_CHANGED")
	self:UnregisterEvent("GROUP_LEFT")
end