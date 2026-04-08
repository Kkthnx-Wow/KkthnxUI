--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Enhances the Quick Join and Premade Groups UI with automation and extra information.
-- - Design: Hooks LFG frames for double-click signup, auto-invites, and displays leader scores/faction icons.
-- - Events: LFG_LIST_APPLICANT_LIST_UPDATED
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Miscellaneous")
local TooltipModule = K:GetModule("Tooltip")

-- PERF: Localize global functions and environment for faster lookups.
local GetTime = _G.GetTime
local gsub = _G.string.gsub
local IsAltKeyDown = _G.IsAltKeyDown
local table_insert = _G.table.insert
local tostring = _G.tostring
local type = _G.type

local _G = _G
local C_LFGList_GetActivityInfoTable = _G.C_LFGList.GetActivityInfoTable
local C_LFGList_GetSearchResultInfo = _G.C_LFGList.GetSearchResultInfo
local CreateFrame = _G.CreateFrame
local HookSecureFunc = _G.hooksecurefunc
local IsAddOnLoaded = _G.C_AddOns.IsAddOnLoaded
local StaticPopup_Hide = _G.StaticPopup_Hide
local UnitIsGroupLeader = _G.UnitIsGroupLeader

-- SG: Constants
local LE_PARTY_CATEGORY_HOME = _G.LE_PARTY_CATEGORY_HOME or 1
local SCORE_DISPLAY_FORMAT = K.GreyColor .. "(%s) |r%s"
local FACTION_LOGOS = {
	[0] = "Horde",
	[1] = "Alliance",
}

-- REASON: Facilitates quick sign-ups by automating the click operation on LFG sign-up buttons.
function Module:onQuickJoinApplicationClick()
	local searchPanel = _G.LFGListFrame.SearchPanel
	if searchPanel.SignUpButton:IsEnabled() then
		searchPanel.SignUpButton:Click()
	end

	local applicationDialog = _G.LFGListApplicationDialog
	if (not IsAltKeyDown()) and applicationDialog:IsShown() and applicationDialog.SignUpButton:IsEnabled() then
		applicationDialog.SignUpButton:Click()
	end
end

local autoHidePendingFrame
function Module:onDialogAutoHideDelay()
	if not autoHidePendingFrame then
		return
	end

	if autoHidePendingFrame.informational then
		_G.StaticPopupSpecial_Hide(autoHidePendingFrame)
	elseif autoHidePendingFrame == "LFG_LIST_ENTRY_EXPIRED_TOO_MANY_PLAYERS" then
		StaticPopup_Hide(autoHidePendingFrame)
	end
	autoHidePendingFrame = nil
end

function Module:onQuickJoinDialogShow()
	autoHidePendingFrame = self
	K.Delay(1, Module.onDialogAutoHideDelay)
end

-- REASON: Adds an 'Auto Accept' checkbox to the LFG application viewer for group leaders to automate applicant invites.
function Module:createAutoAcceptButton()
	local applicationViewer = _G.LFGListFrame.ApplicationViewer
	local autoAcceptButton = CreateFrame("CheckButton", nil, applicationViewer, "InterfaceOptionsCheckButtonTemplate")
	autoAcceptButton:SetSize(24, 24)
	autoAcceptButton:SetHitRectInsets(0, -130, 0, 0)
	autoAcceptButton:SetPoint("BOTTOMLEFT", applicationViewer.InfoBackground, 12, 5)
	K.CreateFontString(autoAcceptButton, 13, _G.LFG_LIST_AUTO_ACCEPT, "", "system", "LEFT", 24, 0)

	local lastAutoRefreshTime = 0
	local function inviteApplicantFromButton(applicantButton)
		if applicantButton.applicantID and applicantButton.InviteButton:IsEnabled() then
			_G.C_LFGList.InviteApplicant(applicantButton.applicantID)
		end
	end

	K:RegisterEvent("LFG_LIST_APPLICANT_LIST_UPDATED", function()
		if not autoAcceptButton:GetChecked() then
			return
		end
		if not UnitIsGroupLeader("player", LE_PARTY_CATEGORY_HOME) then
			return
		end

		applicationViewer.ScrollBox:ForEachFrame(inviteApplicantFromButton)

		if applicationViewer:IsShown() then
			local currentTime = GetTime()
			if currentTime - lastAutoRefreshTime > 1 then
				lastAutoRefreshTime = currentTime
				applicationViewer.RefreshButton:Click()
			end
		end
	end)

	HookSecureFunc("LFGListApplicationViewer_UpdateInfo", function(self)
		autoAcceptButton:SetShown(UnitIsGroupLeader("player", LE_PARTY_CATEGORY_HOME) and not self.AutoAcceptButton:IsShown())
	end)
end

-- REASON: Displays the group leader's Mythic+ score or PvP rating directly on the search result entry for easier group filtering.
function Module:displayLeaderOverallScore()
	local searchResultID = self.resultID
	local searchResultInfo = searchResultID and C_LFGList_GetSearchResultInfo(searchResultID)
	if searchResultInfo then
		local activityInfo = C_LFGList_GetActivityInfoTable(searchResultInfo.activityIDs[1], nil, searchResultInfo.isWarMode)
		if activityInfo then
			local leaderScoreValue = activityInfo.isMythicPlusActivity and searchResultInfo.leaderOverallDungeonScore or activityInfo.isRatedPvpActivity and searchResultInfo.leaderPvpRatingInfo and searchResultInfo.leaderPvpRatingInfo.rating
			if leaderScoreValue then
				local currentActivityName = self.ActivityName:GetText()
				currentActivityName = gsub(currentActivityName, ".-" .. _G.HEADER_COLON, "")
				self.ActivityName:SetFormattedText(SCORE_DISPLAY_FORMAT, TooltipModule.GetDungeonScore(leaderScoreValue), currentActivityName)

				if not self.crossFactionLogo then
					local logoTexture = self:CreateTexture(nil, "OVERLAY")
					logoTexture:SetPoint("TOPLEFT", -6, 5)
					logoTexture:SetSize(24, 24)
					self.crossFactionLogo = logoTexture
				end
			end
		end

		if self.crossFactionLogo then
			if searchResultInfo.crossFactionListing then
				self.crossFactionLogo:Hide()
			else
				self.crossFactionLogo:SetTexture("Interface\\Timer\\" .. FACTION_LOGOS[searchResultInfo.leaderFactionGroup] .. "-Logo")
				self.crossFactionLogo:Show()
			end
		end
	end
end

-- REASON: Replaces the standard category selection button when PremadeGroupsFilter is loaded to bypass unnecessary menus.
function Module:replaceFindGroupButton()
	if not IsAddOnLoaded("PremadeGroupsFilter") then
		return
	end

	local categorySelection = _G.LFGListFrame.CategorySelection
	categorySelection.FindGroupButton:Hide()

	local findGroupButton = CreateFrame("Button", nil, categorySelection, "LFGListMagicButtonTemplate")
	findGroupButton:SetText(_G.LFG_LIST_FIND_A_GROUP)
	findGroupButton:SetSize(135, 22)
	findGroupButton:SetPoint("BOTTOMRIGHT", -3, 4)

	local lastSelectedCategory = 0
	findGroupButton:SetScript("OnClick", function()
		local currentCategoryID = categorySelection.selectedCategory
		if not currentCategoryID then
			return
		end

		local searchPanel = _G.LFGListFrame.SearchPanel
		if lastSelectedCategory ~= currentCategoryID then
			categorySelection.FindGroupButton:Click()
		else
			_G.PlaySound(_G.SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			_G.LFGListSearchPanel_SetCategory(searchPanel, currentCategoryID, categorySelection.selectedFilters, _G.LFGListFrame.baseFilters)
			_G.LFGListSearchPanel_DoSearch(searchPanel)
			_G.LFGListFrame_SetActivePanel(_G.LFGListFrame, searchPanel)
		end
		lastSelectedCategory = currentCategoryID
	end)
end

local function onSortingButtonSortingClick(sortingButton)
	sortingButton.ownerExpressionFrame.Sorting.Expression:SetText(sortingButton.sortingExpression)
	sortingButton.parentFrame.RefreshButton:Click()
end

local function createPGFSortButton(parentFrame, iconTexturePath, sortingExpression, ownerExpressionFrame)
	local sortButton = CreateFrame("Button", nil, parentFrame, "BackdropTemplate")
	sortButton:SetSize(24, 24)
	sortButton.texture = sortButton:CreateTexture(nil, "ARTWORK")
	sortButton.texture:SetTexture(iconTexturePath)
	sortButton.texture:SetAllPoints()
	sortButton.texture:SetTexCoord(_G.unpack(K.TexCoords))
	sortButton:CreateBorder()
	sortButton.sortingExpression = sortingExpression
	sortButton.parentFrame = parentFrame
	sortButton.ownerExpressionFrame = ownerExpressionFrame
	sortButton:SetScript("OnClick", onSortingButtonSortingClick)
	K.AddTooltip(sortButton, "ANCHOR_RIGHT", _G.CLUB_FINDER_SORT_BY)

	table_insert(parentFrame.pgfSortButtons, sortButton)
end

-- REASON: Injects custom sorting shortcuts for Mythic+, PvP rating, and listing age into PremadeGroupsFilter.
function Module:addPGFSortingShortcuts()
	if not IsAddOnLoaded("PremadeGroupsFilter") then
		return
	end

	local pgfDialogFrame = _G.PremadeGroupsFilterDialog
	local pgfExpressionPanel = _G.PremadeGroupsFilterMiniPanel
	pgfDialogFrame.pgfSortButtons = {}

	createPGFSortButton(pgfDialogFrame, 525134, "mprating desc", pgfExpressionPanel)
	createPGFSortButton(pgfDialogFrame, 1455894, "pvprating desc", pgfExpressionPanel)
	createPGFSortButton(pgfDialogFrame, 237538, "age asc", pgfExpressionPanel)

	for i = 1, #pgfDialogFrame.pgfSortButtons do
		local sortButton = pgfDialogFrame.pgfSortButtons[i]
		if i == 1 then
			sortButton:SetPoint("BOTTOMLEFT", pgfDialogFrame, "BOTTOMRIGHT", 3, 0)
		else
			sortButton:SetPoint("BOTTOM", pgfDialogFrame.pgfSortButtons[i - 1], "TOP", 0, 3)
		end
	end

	local pgfSettings = _G.PremadeGroupsFilterSettings
	if pgfSettings then
		pgfSettings.classBar = false
		pgfSettings.classCircle = false
		pgfSettings.leaderCrown = false
		pgfSettings.ratingInfo = false
		pgfSettings.oneClickSignUp = false
	end
end

-- REASON: Workaround for LFG listing taints caused by standard playstyle strings; necessary for secure frame interactions.
function Module:fixLFGListingTaint()
	if IsAddOnLoaded("PremadeGroupsFilter") then
		return
	end

	local arbitraryMythicPlusActivityID = 1160 -- Algeth'ar Academy
	if not _G.C_LFGList.IsPlayerAuthenticatedForLFG(arbitraryMythicPlusActivityID) then
		return
	end

	_G.C_LFGList.GetPlaystyleString = function(playstyleID, activityInfo)
		if not (activityInfo and playstyleID and playstyleID ~= 0 and _G.C_LFGList.GetLfgCategoryInfo(activityInfo.categoryID).showPlaystyleDropdown) then
			return nil
		end
		local globalStringPrefix
		if activityInfo.isMythicPlusActivity then
			globalStringPrefix = "GROUP_FINDER_PVE_PLAYSTYLE"
		elseif activityInfo.isRatedPvpActivity then
			globalStringPrefix = "GROUP_FINDER_PVP_PLAYSTYLE"
		elseif activityInfo.isCurrentRaidActivity then
			globalStringPrefix = "GROUP_FINDER_PVE_RAID_PLAYSTYLE"
		elseif activityInfo.isMythicActivity then
			globalStringPrefix = "GROUP_FINDER_PVE_MYTHICZERO_PLAYSTYLE"
		end
		return globalStringPrefix and _G[globalStringPrefix .. tostring(playstyleID)] or nil
	end

	_G.LFGListEntryCreation_SetTitleFromActivityInfo = K.Noop
end

function Module:CreateQuickJoin()
	if not C["Misc"].QuickJoin then
		return
	end

	local searchPanel = _G.LFGListFrame.SearchPanel
	HookSecureFunc(searchPanel.ScrollBox, "Update", function(self)
		for i = 1, self.ScrollTarget:GetNumChildren() do
			local childFrame = select(i, self.ScrollTarget:GetChildren())
			if childFrame.Name and not childFrame.isQuickJoinHooked then
				childFrame.Name:SetFontObject(_G.Game14Font)
				childFrame.ActivityName:SetFontObject(_G.Game12Font)
				childFrame:HookScript("OnDoubleClick", Module.onQuickJoinApplicationClick)

				childFrame.isQuickJoinHooked = true
			end
		end
	end)

	HookSecureFunc("LFGListInviteDialog_Accept", function()
		if _G.PVEFrame:IsShown() then
			_G.HideUIPanel(_G.PVEFrame)
		end
	end)

	HookSecureFunc("StaticPopup_Show", Module.onQuickJoinDialogShow)
	HookSecureFunc("LFGListInviteDialog_Show", Module.onQuickJoinDialogShow)
	HookSecureFunc("LFGListSearchEntry_Update", Module.displayLeaderOverallScore)

	Module:createAutoAcceptButton()
	Module:replaceFindGroupButton()
	Module:addPGFSortingShortcuts()
	Module:fixLFGListingTaint()
end

Module:RegisterMisc("QuickJoin", Module.CreateQuickJoin)
