local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Miscellaneous")
local TT = K:GetModule("Tooltip")

local StaticPopup_Hide, HideUIPanel, GetTime = StaticPopup_Hide, HideUIPanel, GetTime
local UnitIsGroupLeader = UnitIsGroupLeader
local IsAltKeyDown = IsAltKeyDown
local C_LFGList_GetSearchResultInfo = C_LFGList.GetSearchResultInfo
local C_LFGList_GetActivityInfoTable = C_LFGList.GetActivityInfoTable
local IsAddOnLoaded = C_AddOns.IsAddOnLoaded

local HEADER_COLON = _G.HEADER_COLON
local LE_PARTY_CATEGORY_HOME = _G.LE_PARTY_CATEGORY_HOME or 1
local scoreFormat = K.GreyColor .. "(%s) |r%s"

local LFGListFrame = _G.LFGListFrame
local ApplicationViewerFrame = LFGListFrame.ApplicationViewer
local searchPanel = LFGListFrame.SearchPanel
local categorySelection = LFGListFrame.CategorySelection

function Module:HookApplicationClick()
	if LFGListFrame.SearchPanel.SignUpButton:IsEnabled() then
		LFGListFrame.SearchPanel.SignUpButton:Click()
	end
	if (not IsAltKeyDown()) and LFGListApplicationDialog:IsShown() and LFGListApplicationDialog.SignUpButton:IsEnabled() then
		LFGListApplicationDialog.SignUpButton:Click()
	end
end

local pendingFrame
function Module:DialogHideInSecond()
	if not pendingFrame then
		return
	end

	if pendingFrame.informational then
		StaticPopupSpecial_Hide(pendingFrame)
	elseif pendingFrame == "LFG_LIST_ENTRY_EXPIRED_TOO_MANY_PLAYERS" then
		StaticPopup_Hide(pendingFrame)
	end
	pendingFrame = nil
end

function Module:HookDialogOnShow()
	pendingFrame = self
	K.Delay(1, Module.DialogHideInSecond)
end

function Module:AddAutoAcceptButton()
	local bu = CreateFrame("CheckButton", nil, ApplicationViewerFrame, "InterfaceOptionsCheckButtonTemplate")
	bu:SetSize(24, 24)
	bu:SetHitRectInsets(0, -130, 0, 0)
	bu:SetPoint("BOTTOMLEFT", ApplicationViewerFrame.InfoBackground, 12, 5)
	K.CreateFontString(bu, 13, _G.LFG_LIST_AUTO_ACCEPT, "", "system", "LEFT", 24, 0)

	local lastTime = 0
	local function clickInviteButton(button)
		if button.applicantID and button.InviteButton:IsEnabled() then
			C_LFGList.InviteApplicant(button.applicantID)
		end
	end

	K:RegisterEvent("LFG_LIST_APPLICANT_LIST_UPDATED", function()
		if not bu:GetChecked() then
			return
		end
		if not UnitIsGroupLeader("player", LE_PARTY_CATEGORY_HOME) then
			return
		end

		ApplicationViewerFrame.ScrollBox:ForEachFrame(clickInviteButton)

		if ApplicationViewerFrame:IsShown() then
			local now = GetTime()
			if now - lastTime > 1 then
				lastTime = now
				ApplicationViewerFrame.RefreshButton:Click()
			end
		end
	end)

	hooksecurefunc("LFGListApplicationViewer_UpdateInfo", function(self)
		bu:SetShown(UnitIsGroupLeader("player", LE_PARTY_CATEGORY_HOME) and not self.AutoAcceptButton:IsShown())
	end)
end

local factionStr = {
	[0] = "Horde",
	[1] = "Alliance",
}
function Module:ShowLeaderOverallScore()
	local resultID = self.resultID
	local searchResultInfo = resultID and C_LFGList_GetSearchResultInfo(resultID)
	if searchResultInfo then
		local activityInfo = C_LFGList_GetActivityInfoTable(searchResultInfo.activityID, nil, searchResultInfo.isWarMode)
		if activityInfo then
			local showScore = activityInfo.isMythicPlusActivity and searchResultInfo.leaderOverallDungeonScore or activityInfo.isRatedPvpActivity and searchResultInfo.leaderPvpRatingInfo and searchResultInfo.leaderPvpRatingInfo.rating
			if showScore then
				local oldName = self.ActivityName:GetText()
				oldName = gsub(oldName, ".-" .. HEADER_COLON, "") -- Tazavesh
				self.ActivityName:SetFormattedText(scoreFormat, TT.GetDungeonScore(showScore), oldName)

				if not self.crossFactionLogo then
					local logo = self:CreateTexture(nil, "OVERLAY")
					logo:SetPoint("TOPLEFT", -6, 5)
					logo:SetSize(24, 24)
					self.crossFactionLogo = logo
				end
			end
		end

		if self.crossFactionLogo then
			if searchResultInfo.crossFactionListing then
				self.crossFactionLogo:Hide()
			else
				self.crossFactionLogo:SetTexture("Interface\\Timer\\" .. factionStr[searchResultInfo.leaderFactionGroup] .. "-Logo")
				self.crossFactionLogo:Show()
			end
		end
	end
end

function Module:ReplaceFindGroupButton()
	if not IsAddOnLoaded("PremadeGroupsFilter") then
		return
	end

	categorySelection.FindGroupButton:Hide()

	local bu = CreateFrame("Button", nil, categorySelection, "LFGListMagicButtonTemplate")
	bu:SetText(LFG_LIST_FIND_A_GROUP)
	bu:SetSize(135, 22)
	bu:SetPoint("BOTTOMRIGHT", -3, 4)

	local lastCategory = 0
	bu:SetScript("OnClick", function()
		local selectedCategory = categorySelection.selectedCategory
		if not selectedCategory then
			return
		end

		if lastCategory ~= selectedCategory then
			categorySelection.FindGroupButton:Click()
		else
			PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
			LFGListSearchPanel_SetCategory(searchPanel, selectedCategory, categorySelection.selectedFilters, LFGListFrame.baseFilters)
			LFGListSearchPanel_DoSearch(searchPanel)
			LFGListFrame_SetActivePanel(LFGListFrame, searchPanel)
		end
		lastCategory = selectedCategory
	end)
end

local function clickSortButton(self)
	self.__owner.Sorting.Expression:SetText(self.sortStr)
	self.__parent.RefreshButton:Click()
end

local function createSortButton(parent, texture, sortStr, panel)
	local bu = CreateFrame("Button", nil, parent, "BackdropTemplate")
	bu:SetSize(24, 24)
	bu.texture = bu:CreateTexture(nil, "ARTWORK")
	bu.texture:SetTexture(texture)
	bu.texture:SetAllPoints()
	bu.texture:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	bu:CreateBorder()
	bu.sortStr = sortStr
	bu.__parent = parent
	bu.__owner = panel
	bu:SetScript("OnClick", clickSortButton)
	K.AddTooltip(bu, "ANCHOR_RIGHT", CLUB_FINDER_SORT_BY)

	tinsert(parent.__sortBu, bu)
end

function Module:AddPGFSortingExpression()
	if not IsAddOnLoaded("PremadeGroupsFilter") then
		return
	end

	local PGFDialog = _G.PremadeGroupsFilterDialog
	local ExpressionPanel = _G.PremadeGroupsFilterMiniPanel
	PGFDialog.__sortBu = {}

	createSortButton(PGFDialog, 525134, "mprating desc", ExpressionPanel)
	createSortButton(PGFDialog, 1455894, "pvprating desc", ExpressionPanel)
	createSortButton(PGFDialog, 237538, "age asc", ExpressionPanel)

	for i = 1, #PGFDialog.__sortBu do
		local bu = PGFDialog.__sortBu[i]
		if i == 1 then
			bu:SetPoint("BOTTOMLEFT", PGFDialog, "BOTTOMRIGHT", 3, 0)
		else
			bu:SetPoint("BOTTOM", PGFDialog.__sortBu[i - 1], "TOP", 0, 3)
		end
	end

	if PremadeGroupsFilterSettings then
		PremadeGroupsFilterSettings.classBar = false
		PremadeGroupsFilterSettings.classCircle = false
		PremadeGroupsFilterSettings.leaderCrown = false
		PremadeGroupsFilterSettings.ratingInfo = false
		PremadeGroupsFilterSettings.oneClickSignUp = false
	end
end

function Module:FixListingTaint() -- From PremadeGroupsFilter
	if IsAddOnLoaded("PremadeGroupsFilter") then
		return
	end

	local activityIdOfArbitraryMythicPlusDungeon = 1160 -- Algeth'ar Academy
	if not C_LFGList.IsPlayerAuthenticatedForLFG(activityIdOfArbitraryMythicPlusDungeon) then
		return
	end

	C_LFGList.GetPlaystyleString = function(playstyle, activityInfo)
		if not (activityInfo and playstyle and playstyle ~= 0 and C_LFGList.GetLfgCategoryInfo(activityInfo.categoryID).showPlaystyleDropdown) then
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
		return globalStringPrefix and _G[globalStringPrefix .. tostring(playstyle)] or nil
	end

	-- Disable automatic group titles to prevent tainting errors
	LFGListEntryCreation_SetTitleFromActivityInfo = function(_) end
end

function Module:QuickJoin()
	if not C["Misc"].QuickJoin then
		return
	end

	hooksecurefunc(LFGListFrame.SearchPanel.ScrollBox, "Update", function(self)
		for i = 1, self.ScrollTarget:GetNumChildren() do
			local child = select(i, self.ScrollTarget:GetChildren())
			if child.Name and not child.hooked then
				child.Name:SetFontObject(Game14Font)
				child.ActivityName:SetFontObject(Game12Font)
				child:HookScript("OnDoubleClick", Module.HookApplicationClick)

				child.hooked = true
			end
		end
	end)

	hooksecurefunc("LFGListInviteDialog_Accept", function()
		if PVEFrame:IsShown() then
			HideUIPanel(PVEFrame)
		end
	end)

	hooksecurefunc("StaticPopup_Show", Module.HookDialogOnShow)
	hooksecurefunc("LFGListInviteDialog_Show", Module.HookDialogOnShow)
	hooksecurefunc("LFGListSearchEntry_Update", Module.ShowLeaderOverallScore)

	Module:AddAutoAcceptButton()
	Module:ReplaceFindGroupButton()
	Module:AddPGFSortingExpression()
	Module:FixListingTaint()
end
Module:RegisterMisc("QuickJoin", Module.QuickJoin)
