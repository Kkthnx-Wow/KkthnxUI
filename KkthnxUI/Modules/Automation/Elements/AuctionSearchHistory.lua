--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Notes:
-- - Purpose: Recent Auction House browse searches as a dropdown on the search box.
-- - Design: hooksecurefunc on C_AuctionHouse.SendBrowseQuery (text only). Dropdown
--   lives on UIParent so it must tear down on AH/search-bar hide. Account-wide
--   history in KkthnxUIDB.AuctionSearchHistory.
-- - Events: Blizzard_AuctionHouseUI load
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Automation")

local _G = _G
local ipairs = ipairs
local tinsert, tremove = table.insert, table.remove
local strtrim = strtrim
local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame
local C_Timer_After = C_Timer.After
local EditBox_ClearFocus = EditBox_ClearFocus
local C_AddOns_IsAddOnLoaded = C_AddOns.IsAddOnLoaded

local ROW_HEIGHT = 22
local ROW_PAD = 4
local DROPDOWN_PAD = 6

local apiHooked = false
local frameHooked = false
local addonLoadRegistered = false
local dropdown
local activeRows = {}
local hideScheduled = false

local function cfg()
	return C["Automation"]
end

local function HistoryList()
	KkthnxUIDB = KkthnxUIDB or {}
	KkthnxUIDB.AuctionSearchHistory = KkthnxUIDB.AuctionSearchHistory or {}
	return KkthnxUIDB.AuctionSearchHistory
end

local function MaxEntries()
	local n = cfg().AuctionSearchHistoryMax or 5
	if n < 1 then
		return 1
	end
	if n > 10 then
		return 10
	end
	return n
end

local function PushSearch(text)
	if not cfg().AuctionSearchHistory then
		return
	end

	text = strtrim(text or "")
	if text == "" then
		return
	end

	local recent = HistoryList()
	for i = #recent, 1, -1 do
		if recent[i] == text then
			tremove(recent, i)
		end
	end
	tinsert(recent, 1, text)

	local max = MaxEntries()
	while #recent > max do
		tremove(recent)
	end
end

local function HideDropdown()
	hideScheduled = false
	if dropdown then
		dropdown.searchBox = nil
		dropdown:Hide()
	end
end

local function ScheduleHideDropdown()
	if hideScheduled then
		return
	end
	hideScheduled = true
	C_Timer_After(0.12, function()
		hideScheduled = false
		if not dropdown or not dropdown:IsShown() then
			return
		end
		local searchBox = dropdown.searchBox
		if searchBox and searchBox.HasFocus and searchBox:HasFocus() then
			return
		end
		if dropdown:IsMouseOver() then
			return
		end
		HideDropdown()
	end)
end

local function EnsureDropdown()
	if dropdown then
		return dropdown
	end

	local frame = CreateFrame("Frame", "KKUI_AHSearchHistory", UIParent)
	frame:SetFrameStrata("TOOLTIP")
	frame:SetClampedToScreen(true)
	frame:Hide()
	frame:EnableMouse(true)
	frame:CreateBorder()

	frame:SetScript("OnEnter", function()
		hideScheduled = false
	end)
	frame:SetScript("OnLeave", ScheduleHideDropdown)

	dropdown = frame
	return frame
end

local function AcquireRow(parent)
	local btn = CreateFrame("Button", nil, parent)
	btn:SetHeight(ROW_HEIGHT)
	btn:SetHighlightTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight", "ADD")
	btn:GetHighlightTexture():SetAlpha(0.35)

	local label = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
	label:SetPoint("LEFT", ROW_PAD, 0)
	label:SetPoint("RIGHT", -ROW_PAD, 0)
	label:SetJustifyH("LEFT")
	btn.label = label

	btn:SetScript("OnClick", function(self)
		local searchBar = self.searchBar
		local searchBox = self.searchBox
		if not (searchBar and searchBox and cfg().AuctionSearchHistory) then
			return
		end
		searchBar:SetSearchText(self.queryText or "")
		searchBar:StartSearch()
		HideDropdown()
		EditBox_ClearFocus(searchBox)
	end)

	btn:SetScript("OnEnter", function(self)
		if self.label then
			self.label:SetTextColor(1, 0.82, 0)
		end
	end)
	btn:SetScript("OnLeave", function(self)
		if self.label then
			self.label:SetTextColor(1, 1, 1)
		end
	end)

	return btn
end

local function ShowDropdown(searchBar, searchBox)
	if not cfg().AuctionSearchHistory then
		return
	end

	local recent = HistoryList()
	if #recent == 0 then
		return
	end

	local panel = EnsureDropdown()
	for i = 1, #activeRows do
		activeRows[i]:Hide()
	end

	local width = searchBox:GetWidth()
	if not width or width < 80 then
		width = 200
	end
	panel:SetWidth(width + DROPDOWN_PAD * 2)

	for i = 1, #recent do
		local row = activeRows[i]
		if not row then
			row = AcquireRow(panel)
			activeRows[i] = row
		end
		row:SetParent(panel)
		row:SetWidth(width)
		row.queryText = recent[i]
		row.searchBar = searchBar
		row.searchBox = searchBox
		row.label:SetText(recent[i])
		row.label:SetTextColor(1, 1, 1)
		row:ClearAllPoints()
		row:SetPoint("TOPLEFT", panel, "TOPLEFT", DROPDOWN_PAD, -(DROPDOWN_PAD + (i - 1) * ROW_HEIGHT))
		row:Show()
	end

	panel:SetHeight(DROPDOWN_PAD * 2 + #recent * ROW_HEIGHT)
	panel:ClearAllPoints()
	panel:SetPoint("TOPLEFT", searchBox, "BOTTOMLEFT", -DROPDOWN_PAD, -2)
	panel.searchBox = searchBox

	local ah = _G.AuctionHouseFrame
	local level = (ah and ah:IsShown() and ah:GetFrameLevel() or 0) + 100
	panel:SetFrameLevel(level)
	panel:Show()
end

local function TryShowDropdown(searchBar, searchBox)
	if not (searchBar and searchBox and searchBox:IsVisible()) then
		return
	end
	ShowDropdown(searchBar, searchBox)
end

local function HookSearchBox(searchBar)
	local searchBox = searchBar and searchBar.SearchBox
	if not searchBox or searchBox.__kkuiAHHistoryHooked then
		return searchBox ~= nil
	end
	searchBox.__kkuiAHHistoryHooked = true

	searchBox:HookScript("OnEditFocusGained", function()
		TryShowDropdown(searchBar, searchBox)
	end)
	searchBox:HookScript("OnEditFocusLost", ScheduleHideDropdown)
	return true
end

local function HookSearchBar(searchBar)
	if not searchBar then
		return
	end
	HookSearchBox(searchBar)
	if searchBar.__kkuiAHHistoryBarHooked then
		return
	end
	searchBar.__kkuiAHHistoryBarHooked = true
	searchBar:HookScript("OnShow", function(self)
		HookSearchBox(self)
	end)
	searchBar:HookScript("OnHide", HideDropdown)
end

local function InstallApiHooks()
	if apiHooked then
		return true
	end
	if not (C_AuctionHouse and C_AuctionHouse.SendBrowseQuery) then
		return false
	end

	apiHooked = true
	hooksecurefunc(C_AuctionHouse, "SendBrowseQuery", function(query)
		if type(query) ~= "table" then
			return
		end
		local text = query.searchString
		if type(text) == "string" then
			PushSearch(text)
		end
	end)
	return true
end

local function TryInstallFrameHooks()
	local ah = _G.AuctionHouseFrame
	if not ah then
		return false
	end

	local searchBar = ah.SearchBar
	if searchBar then
		HookSearchBar(searchBar)
	end

	if not frameHooked then
		frameHooked = true
		ah:HookScript("OnShow", function()
			if not cfg().AuctionSearchHistory then
				return
			end
			C_Timer_After(0, function()
				local bar = ah.SearchBar
				if bar then
					HookSearchBar(bar)
				end
				local box = bar and bar.SearchBox
				if box and box.HasFocus and box:HasFocus() then
					TryShowDropdown(bar, box)
				end
			end)
		end)
		-- Dropdown lives on UIParent, not the AH frame — must tear down when AH closes.
		ah:HookScript("OnHide", HideDropdown)
	end

	return true
end

local function InstallHooks()
	InstallApiHooks()
	TryInstallFrameHooks()
end

local function OnAddonLoaded(_, addonName)
	if addonName == "Blizzard_AuctionHouseUI" then
		InstallHooks()
	end
end

function Module:CreateAuctionSearchHistory()
	if not cfg().AuctionSearchHistory then
		HideDropdown()
		local recent = HistoryList()
		local max = MaxEntries()
		while #recent > max do
			tremove(recent)
		end
		return
	end

	-- Trim if maxEntries was lowered while enabled.
	local recent = HistoryList()
	local max = MaxEntries()
	while #recent > max do
		tremove(recent)
	end

	if _G.AuctionHouseFrame or (C_AddOns_IsAddOnLoaded and C_AddOns_IsAddOnLoaded("Blizzard_AuctionHouseUI")) then
		InstallHooks()
	elseif not addonLoadRegistered then
		addonLoadRegistered = true
		K:RegisterEvent("ADDON_LOADED", OnAddonLoaded)
	end
end
