local K, C = unpack(select(2, ...))
local Module = K:NewModule("BlizzBugFixes", "AceEvent-3.0", "AceHook-3.0")

local _G = _G

local blizzardCollectgarbage = _G.collectgarbage
local PVPReadyDialog = _G.PVPReadyDialog
local ShowUIPanel, HideUIPanel = _G.ShowUIPanel, _G.HideUIPanel
local StaticPopupDialogs = _G.StaticPopupDialogs

local isAutoAccepting = false
local displayedRaidConvert = false

-- Garbage collection is being overused and misused,
-- and it's causing lag and performance drops.
if C["General"].FixGarbageCollect then
	blizzardCollectgarbage("setpause", 110)
	blizzardCollectgarbage("setstepmul", 200)

	_G.collectgarbage = function(opt, arg)
		if (opt == "collect") or (opt == nil) then
		elseif (opt == "count") then
			return blizzardCollectgarbage(opt, arg)
		elseif (opt == "setpause") then
			return blizzardCollectgarbage("setpause", 110)
		elseif opt == "setstepmul" then
			return blizzardCollectgarbage("setstepmul", 200)
		elseif (opt == "stop") then
		elseif (opt == "restart") then
		elseif (opt == "step") then
			if (arg ~= nil) then
				if (arg <= 10000) then
					return blizzardCollectgarbage(opt, arg)
				end
			else
				return blizzardCollectgarbage(opt, arg)
			end
		else
			return blizzardCollectgarbage(opt, arg)
		end
	end

	-- Memory usage is unrelated to performance, and tracking memory usage does not track "bad" addons.
	-- Developers can uncomment this line to enable the functionality when looking for memory leaks,
	-- but for the average end-user this is a completely pointless thing to track.
	_G.UpdateAddOnMemoryUsage = function() end
end

-- Misclicks for some popups
function Module:MisclickPopups()
	StaticPopupDialogs.RESURRECT.hideOnEscape = false
	StaticPopupDialogs.AREA_SPIRIT_HEAL.hideOnEscape = false
	StaticPopupDialogs.PARTY_INVITE.hideOnEscape = false
	StaticPopupDialogs.CONFIRM_SUMMON.hideOnEscape = false
	StaticPopupDialogs.ADDON_ACTION_FORBIDDEN.button1 = false
	StaticPopupDialogs.TOO_MANY_LUA_ERRORS.button1 = false
	StaticPopupDialogs.DELETE_ITEM.enterClicksFirstButton = true
	StaticPopupDialogs.DELETE_GOOD_ITEM = StaticPopupDialogs.DELETE_ITEM
	StaticPopupDialogs.CONFIRM_PURCHASE_TOKEN_ITEM.enterClicksFirstButton = true

	_G.PetBattleQueueReadyFrame.hideOnEscape = false

	if (PVPReadyDialog) then
		PVPReadyDialog.leaveButton:Hide()
		PVPReadyDialog.enterButton:ClearAllPoints()
		PVPReadyDialog.enterButton:SetPoint("BOTTOM", PVPReadyDialog, "BOTTOM", 0, 25)
		PVPReadyDialog.label:SetPoint("TOP", 0, -22)
	end
end

local function InviteApplicants()
	local applicants = C_LFGList.GetApplicants()
	for i = 1, #applicants do
		local id, status, pendingStatus, numMembers = C_LFGList.GetApplicantInfo(applicants[i])

		-- Using the premade "invite" feature does not work, as Blizzard have broken auto-accept intentionally
		-- Because of this, we can't invite groups, but we can still send normal invites to singletons.
		local name = C_LFGList.GetApplicantMemberInfo(id, 1)
		InviteUnit(name)
	end
end

local function OnCheckBoxClick(self)
	isAutoAccepting = self:GetChecked()

	if isAutoAccepting then
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
		InviteApplicants()
	else
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_OFF)
	end
end

local function OnCheckBoxEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	GameTooltip:SetText("|cffff0000CAUTION:|r This will auto accept members to your group", nil, nil, nil, nil, true)
	GameTooltip:Show()
end

local function OnCheckBoxLeave()
	GameTooltip_Hide()
end

local function CreateAutoAcceptButton()
	local button = CreateFrame("CheckButton", "PremadeAutoAcceptButton", LFGListFrame.ApplicationViewer)
	button:SetPoint("BOTTOMLEFT", LFGListFrame.ApplicationViewer.InfoBackground, "BOTTOMLEFT", 10, 10)
	button:SetHitRectInsets(0, -70, 0, 0)
	button:SetWidth(22)
	button:SetHeight(22)
	button:Show()

	button:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
	button:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
	button:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight")
	button:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")

	button:SetScript("OnClick", OnCheckBoxClick)
	button:SetScript("OnEnter", OnCheckBoxEnter)
	button:SetScript("OnLeave", OnCheckBoxLeave)

	local text = button:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	text:SetText(LFG_LIST_AUTO_ACCEPT)
	text:SetJustifyH("LEFT")
	text:SetPoint("LEFT", button, "RIGHT", 2, 0)
end

function Module:OnApplicantListUpdated()
	if UnitIsGroupLeader("player", LE_PARTY_CATEGORY_HOME) then
		if isAutoAccepting then
			-- Display conversion to raid notice.
			if not displayedRaidConvert and not IsInRaid(LE_PARTY_CATEGORY_HOME) then
				local futureCount = GetNumGroupMembers(LE_PARTY_CATEGORY_HOME) + C_LFGList.GetNumInvitedApplicantMembers() + C_LFGList.GetNumPendingApplicantMembers()
				if futureCount > (MAX_PARTY_MEMBERS + 1) then
					StaticPopup_Show("LFG_LIST_AUTO_ACCEPT_CONVERT_TO_RAID")
					displayedRaidConvert = true
				end
			end

			InviteApplicants()
		end
	end
end

function Module:UpdateAutoAccept()
	isAutoAccepting = false
	displayedRaidConvert = false
end

function Module:OnEnable()
	self:MisclickPopups()

	if not K.CheckAddOnState("WorldQuestsList") or not K.CheckAddOnState("PremadeAutoAccept") then
		self:RegisterEvent("LFG_LIST_APPLICANT_LIST_UPDATED", "OnApplicantListUpdated")
		self:RegisterEvent("GROUP_LEFT", "UpdateAutoAccept")
		self:RegisterEvent("PARTY_LEADER_CHANGED", "OnApplicantListUpdated")
		CreateAutoAcceptButton()
	end

	-- Fix spellbook taint
	ShowUIPanel(SpellBookFrame)
	HideUIPanel(SpellBookFrame)

	CreateFrame("Frame"):SetScript("OnUpdate", function()
		if LFRBrowseFrame.timeToClear then
			LFRBrowseFrame.timeToClear = nil
		end
	end)
end