--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Collection of various bug fixes and performance optimizations for Blizzard UI.
-- - Design: Uses isolated scope blocks (do-end) to resolve specific issues like taint and overflows.
-- - Events: ADDON_LOADED, PLAYER_REGEN_ENABLED, PLAYER_ENTERING_WORLD
-----------------------------------------------------------------------------]]

local K = KkthnxUI[1]

-- PERF: Localize globals and API functions to reduce lookup overhead.
local _G = _G
local C_ContentTracking = _G.C_ContentTracking
local C_GossipInfo_SelectOption = _G.C_GossipInfo and _G.C_GossipInfo.SelectOption
local C_Minimap = _G.C_Minimap
local C_QuestLog = _G.C_QuestLog
local C_SuperTrack = _G.C_SuperTrack
local CreateFrame = _G.CreateFrame
local GetTime = _G.GetTime
local InCombatLockdown = _G.InCombatLockdown
local RemoveTrackedAchievement = _G.RemoveTrackedAchievement
local hooksecurefunc = _G.hooksecurefunc
local print = _G.print
local string_format = _G.string.format

-- ---------------------------------------------------------------------------
-- Talent Frame Fix
-- ---------------------------------------------------------------------------
-- REASON: Fixes potential errors or redundant updates when the Talent Frame is loaded.
do
	local playerTalentFrame = _G.PlayerTalentFrame
	if playerTalentFrame then
		playerTalentFrame:UnregisterEvent("ACTIVE_TALENT_GROUP_CHANGED")
	else
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
-- REASON: Prevents errors in the Addon List UI when an owner ID is invalid or missing.
do
	local originalAddonTooltip_Update = _G.AddonTooltip_Update
	_G.AddonTooltip_Update = function(owner)
		if not owner or owner:GetID() < 1 then
			return
		end
		originalAddonTooltip_Update(owner)
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
				K:UnregisterEvent(event, setupRaidFix)
			end
		end
	end

	K:RegisterEvent("ADDON_LOADED", setupRaidFix)
end

-- ---------------------------------------------------------------------------
-- Guild News Fixes
-- ---------------------------------------------------------------------------
-- REASON: Fixes tooltip errors and performance jams in the Guild News feed.
do
	local function fixGuildNews(event, addon)
		if addon ~= "Blizzard_GuildUI" then
			return
		end

		local originalGuildNewsButton_OnEnter = _G.GuildNewsButton_OnEnter
		_G.GuildNewsButton_OnEnter = function(self)
			-- REASON: Prevent errors if news info is incomplete for a button.
			if not (self.newsInfo and self.newsInfo.whatText) then
				return
			end
			originalGuildNewsButton_OnEnter(self)
		end

		K:UnregisterEvent(event, fixGuildNews)
	end

	K:RegisterEvent("ADDON_LOADED", fixGuildNews)
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

-- ---------------------------------------------------------------------------
-- Quest Log Performance (QuestClean)
-- ---------------------------------------------------------------------------
-- REASON: Standalone performance utility to fix hidden quest tracking overhead.
do
	local COLOR_BLUE = "0070dd"
	local COLOR_SILVER = "c7c7c7"
	local DEEP_CLEAN_LIMIT = 160000 -- Future-proofed for TWW expansion cycles

	local function cleanActiveWatches()
		-- REASON: Removes watches for quests that are hidden but still tracked in the engine.
		local numEntries = C_QuestLog.GetNumQuestLogEntries()
		local cleaned = 0

		for i = 1, numEntries do
			local info = C_QuestLog.GetInfo(i)
			if info and not info.isHeader and info.isHidden then
				if C_QuestLog.GetQuestWatchType(info.questID) ~= nil then
					C_QuestLog.RemoveQuestWatch(info.questID)
					cleaned = cleaned + 1
				end
			end
		end

		-- REASON: Clears achievement watches which can also cause tracking overhead.
		if C_ContentTracking and C_ContentTracking.GetTrackedIDs then
			local trackedAchievements = C_ContentTracking.GetTrackedIDs(2) or {}
			for i = 1, #trackedAchievements do
				RemoveTrackedAchievement(trackedAchievements[i])
			end
		elseif _G.GetTrackedAchievements then
			local trackedAchievements = { _G.GetTrackedAchievements() }
			for i = 1, #trackedAchievements do
				RemoveTrackedAchievement(trackedAchievements[i])
			end
		end

		-- REASON: Resetting SuperTrack is a major performance boost as it reduces UI-to-Engine draw calls.
		C_SuperTrack.SetSuperTrackedQuestID(0)

		if cleaned > 0 then
			print(string_format("|cff%sQuestClean:|r |cff%sCleaned %d active hidden watches.|r", COLOR_BLUE, COLOR_SILVER, cleaned))
		end
	end

	local function deepCleanWatches()
		-- REASON: Brute-forces the watch list to fix "Orphaned Watch" bugs where non-existing quests hog resources.
		print(string_format("|cff%sQuestClean:|r |cff%sStarting Deep Clean. The client may hang for a moment...|r", COLOR_BLUE, COLOR_SILVER))

		local startTime = GetTime()
		for i = 1, DEEP_CLEAN_LIMIT do
			C_QuestLog.RemoveQuestWatch(i)
		end

		C_SuperTrack.SetSuperTrackedQuestID(0)
		local duration = GetTime() - startTime

		print(string_format("|cff%sQuestClean:|r |cff%sDeep Clean complete in %.2fs. Performance restored.|r", COLOR_BLUE, COLOR_SILVER, duration))
	end

	local initFrame = CreateFrame("Frame")
	initFrame:RegisterEvent("PLAYER_ENTERING_WORLD")

	initFrame:SetScript("OnEvent", function(self, _, isInitialLogin)
		cleanActiveWatches()

		if isInitialLogin then
			print(string_format("|cff%sQuestClean:|r |cff%sType /qc deep if your FPS is still lower than your alts.|r", COLOR_BLUE, COLOR_SILVER))
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
			print(string_format("|cff%sQuestClean:|r |cff%sStandard clean finished. Performance optimized.|r", COLOR_BLUE, COLOR_SILVER))
		end
	end
end
