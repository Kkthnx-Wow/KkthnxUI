--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Displays guild leadership rankings and Mythic+ weekly records in the Challenges frame.
-- - Design: Hooks Blizzard's Challenges UI, integrates with AngryKeystones and Details Keystones, and tracks account-wide keystone info.
-- - Events: ADDON_LOADED, BAG_UPDATE, CHALLENGE_MODE_LEADERS_UPDATE
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Miscellaneous")

-- PERF: Localize global functions and environment for faster lookups.
local ipairs = _G.ipairs
local pairs = _G.pairs
local string_format = _G.string.format
local strsplit = _G.strsplit
local table_sort = _G.table.sort
local table_wipe = _G.table.wipe
local tonumber = _G.tonumber

local _G = _G
local Ambiguate = _G.Ambiguate
local C_AddOns_IsAddOnLoaded = _G.C_AddOns.IsAddOnLoaded
local C_ChallengeMode_GetGuildLeaders = _G.C_ChallengeMode.GetGuildLeaders
local C_ChallengeMode_GetMapUIInfo = _G.C_ChallengeMode.GetMapUIInfo
local C_Item_GetItemIconByID = _G.C_Item and _G.C_Item.GetItemIconByID
local C_MythicPlus_GetRunHistory = _G.C_MythicPlus.GetRunHistory
local C_MythicPlus_GetOwnedKeystoneChallengeMapID = _G.C_MythicPlus.GetOwnedKeystoneChallengeMapID
local C_MythicPlus_GetOwnedKeystoneLevel = _G.C_MythicPlus.GetOwnedKeystoneLevel
local CreateFrame = _G.CreateFrame
local GameTooltip = _G.GameTooltip
local HookSecureFunc = _G.hooksecurefunc
local IsShiftKeyDown = _G.IsShiftKeyDown

-- SG: Constants
local CHALLENGE_MODE_POWER_LEVEL = _G.CHALLENGE_MODE_POWER_LEVEL
local CHALLENGE_MODE_GUILD_BEST_LINE = _G.CHALLENGE_MODE_GUILD_BEST_LINE
local CHALLENGE_MODE_GUILD_BEST_LINE_YOU = _G.CHALLENGE_MODE_GUILD_BEST_LINE_YOU
local CHALLENGE_MODE_THIS_WEEK = _G.CHALLENGE_MODE_THIS_WEEK
local WEEKLY_REWARDS_MYTHIC_TOP_RUNS = _G.WEEKLY_REWARDS_MYTHIC_TOP_RUNS

-- SG: State Variables
local isAngryKeystonesLoaded
local guildBestFrame
local hasResizedAngryKeystones
local WEEKLY_RUNS_THRESHOLD = 8
local MY_ACCOUNT_NAME = K.Name .. "-" .. K.Realm

local function ensureDatabase()
	if not _G.KkthnxUIDB then
		_G.KkthnxUIDB = {}
	end
	if not _G.KkthnxUIDB.KeystoneInfo then
		_G.KkthnxUIDB.KeystoneInfo = {}
	end
	return _G.KkthnxUIDB
end

function Module:onGuildBestEntryEnter()
	local leaderData = self.leaderData
	if not leaderData then
		return
	end

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")

	local dungeonName = C_ChallengeMode_GetMapUIInfo(leaderData.mapChallengeModeID)
	GameTooltip:SetText(dungeonName or "", 1, 1, 1)
	GameTooltip:AddLine(string_format(CHALLENGE_MODE_POWER_LEVEL, leaderData.keystoneLevel or 0))

	local memberList = leaderData.members
	if memberList then
		for i = 1, #memberList do
			local memberData = memberList[i]
			local classColorHex = (memberData and memberData.classFileName and K.ClassColors[memberData.classFileName] and K.ClassColors[memberData.classFileName].colorStr) or "ffffffff"
			GameTooltip:AddLine(string_format(CHALLENGE_MODE_GUILD_BEST_LINE, classColorHex, memberData and memberData.name or ""))
		end
	end

	GameTooltip:Show()
end

function Module:createGuildBestFrame()
	guildBestFrame = CreateFrame("Frame", nil, _G.ChallengesFrame, "BackdropTemplate")
	guildBestFrame:SetPoint("BOTTOMRIGHT", -8, 75)
	guildBestFrame:SetSize(170, 105)
	guildBestFrame:CreateBorder()
	K.CreateFontString(guildBestFrame, 16, _G.GUILD, "", "system", "TOPLEFT", 16, -6)

	guildBestFrame.entryFrames = {}
	for i = 1, 4 do
		local entryFrame = CreateFrame("Frame", nil, guildBestFrame)
		entryFrame:SetPoint("LEFT", 10, 0)
		entryFrame:SetPoint("RIGHT", -10, 0)
		entryFrame:SetHeight(18)

		entryFrame.CharacterName = K.CreateFontString(entryFrame, 14, "", "", false, "LEFT", 6, 0)
		entryFrame.CharacterName:SetPoint("RIGHT", -30, 0)
		entryFrame.CharacterName:SetJustifyH("LEFT")

		entryFrame.Level = K.CreateFontString(entryFrame, 14, "", "system")
		entryFrame.Level:SetJustifyH("LEFT")
		entryFrame.Level:ClearAllPoints()
		entryFrame.Level:SetPoint("LEFT", entryFrame, "RIGHT", -22, 0)

		entryFrame:SetScript("OnEnter", Module.onGuildBestEntryEnter)
		entryFrame:SetScript("OnLeave", _G.K.HideTooltip)

		if i == 1 then
			entryFrame:SetPoint("TOP", guildBestFrame, 0, -26)
		else
			entryFrame:SetPoint("TOP", guildBestFrame.entryFrames[i - 1], "BOTTOM")
		end

		guildBestFrame.entryFrames[i] = entryFrame
	end

	-- REASON: Adjusts Blizzard's internal weekly description text to avoid overlap when AngryKeystones is not present.
	if not isAngryKeystonesLoaded and _G.ChallengesFrame.WeeklyInfo and _G.ChallengesFrame.WeeklyInfo.Child and _G.ChallengesFrame.WeeklyInfo.Child.Description then
		_G.ChallengesFrame.WeeklyInfo.Child.Description:SetPoint("CENTER", 0, 20)
	end

	-- REASON: Integrates with the Details! Keystone module if available for quick access to keystone data.
	if _G.SlashCmdList and _G.SlashCmdList.KEYSTONE then
		local keystoneButton = CreateFrame("Button", nil, guildBestFrame)
		keystoneButton:SetSize(20, 20)
		keystoneButton:SetPoint("TOPRIGHT", -12, -5)
		keystoneButton:SetScript("OnClick", function()
			if _G.DetailsKeystoneInfoFrame and _G.DetailsKeystoneInfoFrame:IsShown() then
				_G.DetailsKeystoneInfoFrame:Hide()
			else
				if _G.ChatFrame1 and _G.ChatFrame1.editBox then
					_G.SlashCmdList.KEYSTONE("/keys", _G.ChatFrame1.editBox)
				else
					_G.SlashCmdList.KEYSTONE()
				end
			end
		end)

		local iconTexture = keystoneButton:CreateTexture(nil, "ARTWORK")
		iconTexture:SetAllPoints()
		iconTexture:SetTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Up")
		iconTexture:SetVertexColor(0, 1, 0)

		local highlightTexture = keystoneButton:CreateTexture(nil, "HIGHLIGHT")
		highlightTexture:SetAllPoints()
		highlightTexture:SetTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Up")
	end

	-- REASON: Hides RaiderIO's internal guild weekly frame as KkthnxUI provides its own integrated alternative.
	if _G.RaiderIO_GuildWeeklyFrame then
		_G.K.HideInterfaceOption(_G.RaiderIO_GuildWeeklyFrame)
	end
end

function Module:setupGuildBestEntry(leaderData)
	self.leaderData = leaderData

	local template = CHALLENGE_MODE_GUILD_BEST_LINE
	if leaderData.isYou then
		template = CHALLENGE_MODE_GUILD_BEST_LINE_YOU
	end

	local classColorHex = (leaderData.classFileName and K.ClassColors[leaderData.classFileName] and K.ClassColors[leaderData.classFileName].colorStr) or "ffffffff"
	self.CharacterName:SetText(string_format(template, classColorHex, leaderData.name or ""))
	self.Level:SetText(leaderData.keystoneLevel or "")
end

function Module:updateGuildBestData()
	if not guildBestFrame then
		Module:createGuildBestFrame()
	end

	if self.areLeadersAvailable then
		local leaderList = C_ChallengeMode_GetGuildLeaders()
		if leaderList and #leaderList > 0 then
			for i = 1, 4 do
				local leaderData = leaderList[i]
				if not leaderData then
					break
				end
				Module.setupGuildBestEntry(guildBestFrame.entryFrames[i], leaderData)
			end
			guildBestFrame:Show()
		else
			guildBestFrame:Hide()
		end
	end

	-- REASON: Applies layout adaptations for AngryKeystones to maintain UI alignment in the Challenges frame.
	if not hasResizedAngryKeystones and isAngryKeystonesLoaded and self.WeeklyInfo and self.WeeklyInfo.Child and self.WeeklyInfo.Child.WeeklyChest then
		HookSecureFunc(self.WeeklyInfo.Child.WeeklyChest, "SetPoint", function(weeklyChestFrame, _, xPos, yPos)
			if xPos == 100 and yPos == 0 then
				weeklyChestFrame:SetPoint("LEFT", 110, -5)
			end
		end)

		if self.WeeklyInfo.Child.ThisWeekLabel then
			self.WeeklyInfo.Child.ThisWeekLabel:SetPoint("TOP", -125, -25)
		end

		local angryKeystonesSchedule = _G.AngryKeystones and _G.AngryKeystones.Modules and _G.AngryKeystones.Modules.Schedule
		if angryKeystonesSchedule and angryKeystonesSchedule.AffixFrame then
			guildBestFrame:SetWidth(246)
			guildBestFrame:ClearAllPoints()
			guildBestFrame:SetPoint("BOTTOMLEFT", angryKeystonesSchedule.AffixFrame, "TOPLEFT", 0, 10)
		end

		local keystoneTextObject = angryKeystonesSchedule and angryKeystonesSchedule.KeystoneText
		if keystoneTextObject and self.WeeklyInfo.Child.DungeonScoreInfo and self.WeeklyInfo.Child.DungeonScoreInfo.Score then
			keystoneTextObject:SetFontObject(_G.Game13Font)
			keystoneTextObject:ClearAllPoints()
			keystoneTextObject:SetPoint("TOP", self.WeeklyInfo.Child.DungeonScoreInfo.Score, "BOTTOM", 0, -3)
		end

		hasResizedAngryKeystones = true
	end
end

-- Keystone info (weekly runs + account keys)
-- REASON: Sorts the Mythic+ run history by keystone level (descending) and map ID (ascending) for consistent display.
local function sortMythicHistory(runA, runB)
	if runA.level == runB.level then
		return runA.mapChallengeModeID < runB.mapChallengeModeID
	end
	return runA.level > runB.level
end

function Module:onWeeklyChestEnter()
	local runHistory = C_MythicPlus_GetRunHistory(false, true)
	local numRunsTotal = runHistory and #runHistory
	if not numRunsTotal or numRunsTotal <= 0 then
		return
	end

	local isShiftHeld = IsShiftKeyDown()
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(isShiftHeld and CHALLENGE_MODE_THIS_WEEK or string_format(WEEKLY_REWARDS_MYTHIC_TOP_RUNS, WEEKLY_RUNS_THRESHOLD), "(" .. numRunsTotal .. ")", 0.6, 0.8, 1)

	table_sort(runHistory, sortMythicHistory)

	local displayLimit = isShiftHeld and numRunsTotal or WEEKLY_RUNS_THRESHOLD
	for i = 1, displayLimit do
		local runInfo = runHistory[i]
		if not runInfo then
			break
		end

		local dungeonName = C_ChallengeMode_GetMapUIInfo(runInfo.mapChallengeModeID) or ""
		local red, green, blue = 0, 1, 0
		if not runInfo.completed then
			red, green, blue = 1, 0, 0
		end
		GameTooltip:AddDoubleLine(dungeonName, "Lv." .. (runInfo.level or 0), 1, 1, 1, red, green, blue)
	end

	if not isShiftHeld then
		GameTooltip:AddLine(L["Hold Shift"], 0.6, 0.8, 1)
	end

	GameTooltip:Show()
end

function Module:createKeystoneInfoButton()
	local database = ensureDatabase()
	local iconTexturePath = (_G.C_Item and _G.C_Item.GetItemIconByID(158923)) or 525134
	local qualityColorInfo = K.QualityColors[(Enum and Enum.ItemQuality and Enum.ItemQuality.Epic) or 4] or K.QualityColors[4]

	local keystoneInfoFrame = CreateFrame("Frame", nil, _G.ChallengesFrame.WeeklyInfo, "BackdropTemplate")
	keystoneInfoFrame:SetPoint("BOTTOMLEFT", 2, 67)
	keystoneInfoFrame:SetSize(32, 32)

	keystoneInfoFrame.Icon = keystoneInfoFrame:CreateTexture(nil, "ARTWORK")
	keystoneInfoFrame.Icon:SetAllPoints()
	keystoneInfoFrame.Icon:SetTexCoord(_G.unpack(K.TexCoords))
	keystoneInfoFrame.Icon:SetTexture(iconTexturePath)

	keystoneInfoFrame:CreateBorder()
	if keystoneInfoFrame.KKUI_Border and qualityColorInfo then
		keystoneInfoFrame.KKUI_Border:SetVertexColor(qualityColorInfo.r, qualityColorInfo.g, qualityColorInfo.b)
	end

	keystoneInfoFrame:SetScript("OnEnter", function(self)
		local keystoneDatabase = database.KeystoneInfo
		GameTooltip:ClearLines()
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine(L["Account Keystones"])

		if keystoneDatabase then
			for accountKey, infoString in pairs(keystoneDatabase) do
				local amibguatedName = Ambiguate(accountKey, "none")
				local dungeonMapID, mythicKeystoneLevel, classFile, factionName = strsplit(":", infoString)

				local classColorHex = K.RGBToHex(K.ColorClass(classFile))
				local factionColorHex = (factionName == "Horde") and "|cffff5040" or "|cff00adf0"
				local dungeonName = C_ChallengeMode_GetMapUIInfo(tonumber(dungeonMapID)) or "?"

				GameTooltip:AddDoubleLine(string_format(classColorHex .. "%s:|r", amibguatedName), string_format("%s%s(%s)|r", factionColorHex, dungeonName, mythicKeystoneLevel or "?"))
			end
		end

		GameTooltip:AddLine("")
		GameTooltip:AddDoubleLine(" ", (K.ScrollButton or "") .. L["Reset Data"] .. " ", 1, 1, 1, 0.5, 0.7, 1)
		GameTooltip:Show()
	end)

	keystoneInfoFrame:SetScript("OnLeave", _G.K.HideTooltip)
	keystoneInfoFrame:SetScript("OnMouseUp", function(_, mouseButton)
		if mouseButton == "MiddleButton" then
			if database.KeystoneInfo then
				table_wipe(database.KeystoneInfo)
			end
			Module:updateAccountKeystoneData()
		end
	end)
end

function Module:getOwnedKeystoneInfo()
	local keystoneMapID = C_MythicPlus_GetOwnedKeystoneChallengeMapID()
	if keystoneMapID then
		return keystoneMapID, C_MythicPlus_GetOwnedKeystoneLevel()
	end
end

-- REASON: Persists the current player's keystone information to the account-wide database for cross-character tracking.
function Module:updateAccountKeystoneData()
	local database = ensureDatabase()
	local dungeonMapID, keystoneLevelValue = Module:getOwnedKeystoneInfo()
	if dungeonMapID then
		database.KeystoneInfo[MY_ACCOUNT_NAME] = dungeonMapID .. ":" .. keystoneLevelValue .. ":" .. K.Class .. ":" .. K.Faction
	else
		database.KeystoneInfo[MY_ACCOUNT_NAME] = nil
	end
end

local function initializeGuildBestElements()
	if not _G.ChallengesFrame then
		return
	end

	HookSecureFunc(_G.ChallengesFrame, "Update", Module.updateGuildBestData)

	-- REASON: Adds an account-wide keystone tracking icon and hooks the weekly chest for enhanced run history.
	Module:createKeystoneInfoButton()
	if _G.ChallengesFrame.WeeklyInfo and _G.ChallengesFrame.WeeklyInfo.Child and _G.ChallengesFrame.WeeklyInfo.Child.WeeklyChest then
		_G.ChallengesFrame.WeeklyInfo.Child.WeeklyChest:HookScript("OnEnter", Module.onWeeklyChestEnter)
	end
end

function Module.onAddonLoadForGuildBest(addonEvent, addonName)
	if addonName == "Blizzard_ChallengesUI" then
		initializeGuildBestElements()
		K:UnregisterEvent(addonEvent, Module.onAddonLoadForGuildBest)
	end
end

function Module:CreateGuildBest()
	if not C["Misc"].MDGuildBest then
		return
	end

	isAngryKeystonesLoaded = C_AddOns_IsAddOnLoaded and C_AddOns_IsAddOnLoaded("AngryKeystones")

	if C_AddOns_IsAddOnLoaded and C_AddOns_IsAddOnLoaded("Blizzard_ChallengesUI") and _G.ChallengesFrame then
		initializeGuildBestElements()
	else
		K:RegisterEvent("ADDON_LOADED", Module.onAddonLoadForGuildBest)
	end

	Module:updateAccountKeystoneData()
	K:RegisterEvent("BAG_UPDATE", Module.updateAccountKeystoneData)
end

Module:RegisterMisc("MDGuildBest", Module.CreateGuildBest)
