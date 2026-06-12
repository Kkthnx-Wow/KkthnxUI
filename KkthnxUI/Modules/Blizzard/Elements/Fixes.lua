--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Collection of various bug fixes and performance optimizations for Blizzard UI.
-- - Design: Uses isolated scope blocks (do-end) to resolve specific issues like taint and overflows.
-- - Events: ADDON_LOADED, PLAYER_REGEN_ENABLED, PLAYER_ENTERING_WORLD
-----------------------------------------------------------------------------]]

local K = _G["KkthnxUI"][1]

-- PERF: Localize globals and API functions to reduce lookup overhead.
local _G = _G
local C_AddOns_IsAddOnLoaded = _G.C_AddOns.IsAddOnLoaded
local C_ContentTracking = _G.C_ContentTracking
local C_QuestLog = _G.C_QuestLog
local C_SuperTrack = _G.C_SuperTrack
local CreateFrame = _G.CreateFrame
local GetTime = _G.GetTime
local InCombatLockdown = _G.InCombatLockdown
local hooksecurefunc = _G.hooksecurefunc
local string_format = _G.string.format

-- ---------------------------------------------------------------------------
-- Talent Frame Fix
-- ---------------------------------------------------------------------------
-- REASON: Fixes potential errors or redundant updates when the Talent Frame is loaded.
do
	local playerTalentFrame = _G.PlayerTalentFrame
	if playerTalentFrame then
		playerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	elseif _G.TalentFrame_LoadUI then
		hooksecurefunc("TalentFrame_LoadUI", function()
			if _G.PlayerTalentFrame then
				_G.PlayerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
			end
		end)
	end
end

-- ---------------------------------------------------------------------------
-- Addon List Tooltip Fix
-- ---------------------------------------------------------------------------
-- WARNING: Intentional global overwrite. hooksecurefunc cannot block execution (it is post-hook only).
-- This pre-hook guard is required to prevent errors when owner:GetID() returns an invalid index.
-- REASON: Prevents errors in the Addon List UI when an owner ID is invalid or missing.
do
	local originalAddonTooltip_Update = _G.AddonTooltip_Update
	if originalAddonTooltip_Update then
		_G.AddonTooltip_Update = function(owner)
			if not owner or (owner.GetID and owner:GetID() < 1) then
				return
			end
			return originalAddonTooltip_Update(owner)
		end
	end
end

-- ---------------------------------------------------------------------------
-- Money Tooltip Spacing Fix
-- ---------------------------------------------------------------------------
-- REASON: Blizzard's SetTooltipMoney can omit spacing around prefix/suffix coin text.
do
	if _G.SetTooltipMoney then
		local C_CurrencyInfo_GetCoinTextureString = _G.C_CurrencyInfo and _G.C_CurrencyInfo.GetCoinTextureString
		local getCoinTextureString = C_CurrencyInfo_GetCoinTextureString or _G.GetCoinTextureString
		if getCoinTextureString then
			_G.SetTooltipMoney = function(frame, money, _, prefixText, suffixText)
				frame:AddLine((prefixText or "") .. " " .. getCoinTextureString(money) .. " " .. (suffixText or ""), 1, 1, 1)
			end
		end
	end
end

-- ---------------------------------------------------------------------------
-- Pet Frame Click Area Fix
-- ---------------------------------------------------------------------------
-- REASON: PetFrame's default hit rect is slightly too tall; tighten without reparenting.
do
	local petFrame = _G.PetFrame
	if petFrame and petFrame.SetHitRectInsets then
		petFrame:SetHitRectInsets(0, 0, 1, 5)
	end
end

-- ---------------------------------------------------------------------------
-- Collections Journal Fixes
-- ---------------------------------------------------------------------------
-- REASON: Fixes layout issues and adds a mover for the Collections Journal.
do
	local isCollectionsDone = false
	local function setupCollectionsFix(event, addon)
		if event == "ADDON_LOADED" and addon == "Blizzard_Collections" then
			-- REASON: Fixes an issue where the secondary appearance checkbox label was improperly sized/positioned.
			local wardrobeTransmogFrame = _G.WardrobeTransmogFrame
			if wardrobeTransmogFrame and wardrobeTransmogFrame.ToggleSecondaryAppearanceCheckbox then
				local checkBox = wardrobeTransmogFrame.ToggleSecondaryAppearanceCheckbox
				checkBox.Label:ClearAllPoints()
				checkBox.Label:SetPoint("LEFT", checkBox, "RIGHT", 2, 1)
				checkBox.Label:SetWidth(152)
			end

			local collectionsJournal = _G.CollectionsJournal
			if collectionsJournal then
				collectionsJournal:HookScript("OnShow", function()
					if not isCollectionsDone then
						if InCombatLockdown() then
							K:RegisterEvent("PLAYER_REGEN_ENABLED", setupCollectionsFix)
						else
							K.CreateMoverFrame(collectionsJournal)
						end
						isCollectionsDone = true
					end
				end)
			end
			K:UnregisterEvent(event, setupCollectionsFix)
		elseif event == "PLAYER_REGEN_ENABLED" then
			if _G.CollectionsJournal then
				K.CreateMoverFrame(_G.CollectionsJournal)
			end
			K:UnregisterEvent(event, setupCollectionsFix)
		end
	end

	K:RegisterEvent("ADDON_LOADED", setupCollectionsFix)
end

-- ---------------------------------------------------------------------------
-- Raid Group Button Fix
-- ---------------------------------------------------------------------------
-- REASON: Ensures raid group buttons are correctly attributed to allowing target selection on click.
do
	local function fixRaidGroupButtons()
		for i = 1, 40 do
			local bu = _G["RaidGroupButton" .. i]
			if bu and bu.unit and not bu.clickFixed then
				bu:SetAttribute("type", "target")
				bu:SetAttribute("unit", bu.unit)
				bu.clickFixed = true
			end
		end
	end

	local function setupRaidFix(event, addon)
		if event == "ADDON_LOADED" and addon == "Blizzard_RaidUI" then
			if not InCombatLockdown() then
				fixRaidGroupButtons()
			else
				K:RegisterEvent("PLAYER_REGEN_ENABLED", setupRaidFix)
			end
			K:UnregisterEvent(event, setupRaidFix)
		elseif event == "PLAYER_REGEN_ENABLED" then
			local raidGroupButton1 = _G.RaidGroupButton1
			if raidGroupButton1 and raidGroupButton1:GetAttribute("type") ~= "target" then
				fixRaidGroupButtons()
			end
			K:UnregisterEvent(event, setupRaidFix)
		end
	end

	if C_AddOns_IsAddOnLoaded("Blizzard_RaidUI") then
		setupRaidFix("ADDON_LOADED", "Blizzard_RaidUI")
	else
		K:RegisterEvent("ADDON_LOADED", setupRaidFix)
	end
end

-- ---------------------------------------------------------------------------
-- Guild News Fixes
-- ---------------------------------------------------------------------------
-- REASON: Fixes tooltip errors and performance jams in the Guild News feed.
do
	local function applyGuildNewsFix()
		local originalGuildNewsButton_OnEnter = _G.GuildNewsButton_OnEnter
		if type(originalGuildNewsButton_OnEnter) ~= "function" then
			return
		end

		-- WARNING: Intentional global overwrite. hooksecurefunc cannot block execution.
		-- This pre-hook guard prevents errors when newsInfo is nil or lacks whatText.
		_G.GuildNewsButton_OnEnter = function(self)
			-- REASON: Prevent errors if news info is incomplete for a button.
			if not (self.newsInfo and self.newsInfo.whatText) then
				return
			end
			return originalGuildNewsButton_OnEnter(self)
		end
	end

	local function fixGuildNews(event, addon)
		if addon ~= "Blizzard_GuildUI" then
			return
		end

		applyGuildNewsFix()
		K:UnregisterEvent(event, fixGuildNews)
	end

	if C_AddOns_IsAddOnLoaded("Blizzard_GuildUI") then
		applyGuildNewsFix()
	else
		K:RegisterEvent("ADDON_LOADED", fixGuildNews)
	end
end

do
	local lastUpdateTime, timeGap = 0, 1.5
	local function updateGuildNews(self, event)
		-- REASON: Throttles news updates to prevent UI "jams" or excessive server calls.
		if event == "PLAYER_ENTERING_WORLD" then
			_G.QueryGuildNews()
		else
			if self:IsVisible() then
				local currentTime = GetTime()
				if currentTime - lastUpdateTime > timeGap then
					if _G.CommunitiesGuildNews_Update then
						_G.CommunitiesGuildNews_Update(self)
					end
					lastUpdateTime = currentTime
				end
			end
		end
	end

	local guildDetailsFrameNews = _G.CommunitiesFrameGuildDetailsFrameNews
	if guildDetailsFrameNews then
		guildDetailsFrameNews:SetScript("OnEvent", updateGuildNews)
	end
end

-- Fix Professions drag taint in combat
do
	local done
	local function setupMisc(event, addon)
		if event == "ADDON_LOADED" and addon == "Blizzard_ProfessionsBook" then
			ProfessionsBookFrame:HookScript("OnShow", function()
				if not done then
					if InCombatLockdown() then
						K:RegisterEvent("PLAYER_REGEN_ENABLED", setupMisc)
					else
						K.CreateMoverFrame(ProfessionsBookFrame)
					end
					done = true
				end
			end)
			K:UnregisterEvent(event, setupMisc)
		elseif event == "PLAYER_REGEN_ENABLED" then
			K.CreateMoverFrame(ProfessionsBookFrame)
			K:UnregisterEvent(event, setupMisc)
		end
	end

	K:RegisterEvent("ADDON_LOADED", setupMisc)
end

-- ---------------------------------------------------------------------------
-- Quest Log Performance (QuestClean)
-- ---------------------------------------------------------------------------
-- REASON: Standalone performance utility to fix hidden quest tracking overhead.
do
	local DEEP_CLEAN_LIMIT = 160000 -- Future-proofed for TWW expansion cycles
	local DEEP_CLEAN_CHUNK_SIZE = 5000 -- How many quests to clean per tick to prevent hanging

	-- REASON: Localize Hot Globals for performance inside loops
	local GetNumQuestLogEntries = C_QuestLog.GetNumQuestLogEntries
	local GetInfo = C_QuestLog.GetInfo
	local GetQuestWatchType = C_QuestLog.GetQuestWatchType
	local RemoveQuestWatch = C_QuestLog.RemoveQuestWatch
	local SetSuperTrackedQuestID = C_SuperTrack.SetSuperTrackedQuestID
	local GetTrackedIDs = C_ContentTracking and C_ContentTracking.GetTrackedIDs
	local GetTrackedAchievements = _G.GetTrackedAchievements
	local RemoveTrackedAchievement = _G.RemoveTrackedAchievement
	local NewTicker = C_Timer.NewTicker
	local math_min = math.min
	local select = select
	local table_wipe = table.wipe

	local tempTracked = {}

	local function cleanActiveWatches()
		-- REASON: Removes watches for quests that are hidden but still tracked in the engine.
		local numEntries = GetNumQuestLogEntries()
		local cleaned = 0

		for i = 1, numEntries do
			local info = GetInfo(i)
			if info and not info.isHeader and info.isHidden then
				if GetQuestWatchType(info.questID) ~= nil then
					RemoveQuestWatch(info.questID)
					cleaned = cleaned + 1
				end
			end
		end

		-- REASON: Clears achievement watches which can also cause tracking overhead.
		if GetTrackedIDs then
			local trackedAchievements = GetTrackedIDs(2)
			if trackedAchievements then
				for i = 1, #trackedAchievements do
					RemoveTrackedAchievement(trackedAchievements[i])
				end
			end
		elseif GetTrackedAchievements then
			table_wipe(tempTracked)
			local numTracked = select("#", GetTrackedAchievements())
			for i = 1, numTracked do
				tempTracked[i] = select(i, GetTrackedAchievements())
			end
			for i = 1, #tempTracked do
				RemoveTrackedAchievement(tempTracked[i])
			end
		end

		-- REASON: Resetting SuperTrack is a major performance boost as it reduces UI-to-Engine draw calls.
		SetSuperTrackedQuestID(0)

		if cleaned > 0 then
			K.Print(string_format("QuestClean: Cleaned %d active hidden watches.", cleaned))
		end
	end

	local isDeepCleaning = false
	local function deepCleanWatches()
		if isDeepCleaning then
			K.Print("QuestClean: Deep Clean is already running...")
			return
		end

		-- REASON: Brute-forces the watch list to fix "Orphaned Watch" bugs.
		-- Throttled using a ticker to avoid freezing the game client.
		K.Print("QuestClean: Starting Deep Clean in background. This will take a few seconds...")

		isDeepCleaning = true
		local startTime = GetTime()
		local currentIndex = 1
		local ticker

		ticker = NewTicker(0.05, function()
			local endIndex = math_min(currentIndex + DEEP_CLEAN_CHUNK_SIZE - 1, DEEP_CLEAN_LIMIT)
			for i = currentIndex, endIndex do
				RemoveQuestWatch(i)
			end

			currentIndex = endIndex + 1

			if currentIndex > DEEP_CLEAN_LIMIT then
				ticker:Cancel()
				SetSuperTrackedQuestID(0)
				local duration = GetTime() - startTime
				K.Print(string_format("QuestClean: Deep Clean complete in %.2fs. Performance restored.", duration))
				isDeepCleaning = false
			end
		end)
	end

	local initFrame = CreateFrame("Frame")
	initFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

	initFrame:SetScript("OnEvent", function(self, _, isInitialLogin)
		cleanActiveWatches()

		if isInitialLogin then
			K.Print("QuestClean: Type /qc deep if your FPS is still lower than your alts.")
		end

		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
		self:SetScript("OnEvent", nil)
	end)

	_G.SLASH_QUESTCLEAN1 = "/qc"
	_G.SLASH_QUESTCLEAN2 = "/questclean"
	_G.SlashCmdList["QUESTCLEAN"] = function(msg)
		local command = msg:lower()
		if command == "deep" then
			deepCleanWatches()
		else
			cleanActiveWatches()
			K.Print("QuestClean: Standard clean finished. Performance optimized.")
		end
	end
end
