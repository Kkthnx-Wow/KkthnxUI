--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Auto-widen AH browse when Current Expansion Only returns zero results.
-- - Design: Never taints protected AH actions.
-- - Events: AUCTION_HOUSE_BROWSE_RESULTS_UPDATED, Blizzard_AuctionHouseUI load
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Automation")

local C_AddOns_IsAddOnLoaded = _G.C_AddOns.IsAddOnLoaded
local C_AuctionHouse = _G.C_AuctionHouse
local C_Timer_After = _G.C_Timer.After
local Enum = _G.Enum

local FILTER = Enum and Enum.AuctionHouseFilter and Enum.AuctionHouseFilter.CurrentExpansionOnly

local hooked = false
local addonLoadRegistered = false

local function onBrowseResultsUpdated()
	if not C["Automation"].AuctionSearchFallback or not FILTER then
		return
	end
	if not (C_AuctionHouse and C_AuctionHouse.GetBrowseResults) then
		return
	end

	local results = C_AuctionHouse.GetBrowseResults()
	if #results ~= 0 then
		return
	end

	local searchBar = _G.AuctionHouseFrame and _G.AuctionHouseFrame.SearchBar
	local filterButton = searchBar and searchBar.FilterButton
	if not filterButton or not filterButton.filters then
		return
	end

	if filterButton.filters[FILTER] then
		filterButton:ToggleFilter(FILTER)
		searchBar:StartSearch()
	elseif not filterButton.filters[FILTER] then
		filterButton:ToggleFilter(FILTER)
	end
end

local function installHooks()
	if hooked or not _G.AuctionHouseFrame then
		return
	end

	hooked = true
	_G.AuctionHouseFrame:HookScript("OnShow", function()
		if not C["Automation"].AuctionSearchFallback then
			return
		end
		C_Timer_After(0.1, function()
			local filterButton = _G.AuctionHouseFrame.SearchBar and _G.AuctionHouseFrame.SearchBar.FilterButton
			if filterButton and not filterButton.filters[FILTER] then
				filterButton:Reset()
				filterButton:ToggleFilter(FILTER)
			end
		end)
	end)

	K:RegisterEvent("AUCTION_HOUSE_BROWSE_RESULTS_UPDATED", onBrowseResultsUpdated)
end

local function onAddonLoaded(_, addonName)
	if addonName == "Blizzard_AuctionHouseUI" then
		installHooks()
	end
end

local function trySetup()
	if hooked then
		return
	end
	if _G.AuctionHouseFrame or (C_AddOns_IsAddOnLoaded and C_AddOns_IsAddOnLoaded("Blizzard_AuctionHouseUI")) then
		installHooks()
		return
	end
	if addonLoadRegistered then
		return
	end
	addonLoadRegistered = true
	K:RegisterEvent("ADDON_LOADED", onAddonLoaded)
end

function Module:CreateAuctionSearchFallback()
	if not C["Automation"].AuctionSearchFallback then
		if hooked then
			K:UnregisterEvent("AUCTION_HOUSE_BROWSE_RESULTS_UPDATED", onBrowseResultsUpdated)
			hooked = false
		end
		return
	end

	trySetup()
end
