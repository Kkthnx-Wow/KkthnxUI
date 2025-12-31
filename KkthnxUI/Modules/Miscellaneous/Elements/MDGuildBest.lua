local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Miscellaneous")

-- Performance: cache globals / frequently-used functions
local _G = _G

-- Lua
local ipairs = ipairs
local pairs = pairs
local tonumber = tonumber
local format = string.format
local strsplit = strsplit
local wipe = wipe
local sort = table.sort

-- WoW API
local CreateFrame = CreateFrame
local GameTooltip = GameTooltip
local IsShiftKeyDown = IsShiftKeyDown
local hooksecurefunc = hooksecurefunc
local SlashCmdList = SlashCmdList
local ChatFrame1 = ChatFrame1
local C_AddOns_IsAddOnLoaded = (C_AddOns and C_AddOns.IsAddOnLoaded) or IsAddOnLoaded

local Ambiguate = Ambiguate
local C_Item_GetItemIconByID = C_Item and C_Item.GetItemIconByID
local C_MythicPlus_GetRunHistory = C_MythicPlus.GetRunHistory
local C_MythicPlus_GetOwnedKeystoneLevel = C_MythicPlus.GetOwnedKeystoneLevel
local C_MythicPlus_GetOwnedKeystoneChallengeMapID = C_MythicPlus.GetOwnedKeystoneChallengeMapID
local C_ChallengeMode_GetMapUIInfo = C_ChallengeMode.GetMapUIInfo
local C_ChallengeMode_GetGuildLeaders = C_ChallengeMode.GetGuildLeaders

-- Constants
local CHALLENGE_MODE_POWER_LEVEL = CHALLENGE_MODE_POWER_LEVEL
local CHALLENGE_MODE_GUILD_BEST_LINE = CHALLENGE_MODE_GUILD_BEST_LINE
local CHALLENGE_MODE_GUILD_BEST_LINE_YOU = CHALLENGE_MODE_GUILD_BEST_LINE_YOU
local CHALLENGE_MODE_THIS_WEEK = CHALLENGE_MODE_THIS_WEEK
local WEEKLY_REWARDS_MYTHIC_TOP_RUNS = WEEKLY_REWARDS_MYTHIC_TOP_RUNS

-- Feature
local hasAngryKeystones
local frame
local resize

local WeeklyRunsThreshold = 8
local MY_FULLNAME = K.Name .. "-" .. K.Realm

local function EnsureDB()
	if not _G.KkthnxUIDB then
		_G.KkthnxUIDB = {}
	end
	if not _G.KkthnxUIDB.KeystoneInfo then
		_G.KkthnxUIDB.KeystoneInfo = {}
	end
	return _G.KkthnxUIDB
end

function Module:GuildBest_UpdateTooltip()
	local leaderInfo = self.leaderInfo
	if not leaderInfo then
		return
	end

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")

	local name = C_ChallengeMode_GetMapUIInfo(leaderInfo.mapChallengeModeID)
	GameTooltip:SetText(name or "", 1, 1, 1)
	GameTooltip:AddLine(format(CHALLENGE_MODE_POWER_LEVEL, leaderInfo.keystoneLevel or 0))

	local members = leaderInfo.members
	if members then
		for i = 1, #members do
			local m = members[i]
			local classColorStr = (m and m.classFileName and K.ClassColors[m.classFileName] and K.ClassColors[m.classFileName].colorStr) or "ffffffff"
			GameTooltip:AddLine(format(CHALLENGE_MODE_GUILD_BEST_LINE, classColorStr, m and m.name or ""))
		end
	end

	GameTooltip:Show()
end

function Module:GuildBest_Create()
	frame = CreateFrame("Frame", nil, ChallengesFrame, "BackdropTemplate")
	frame:SetPoint("BOTTOMRIGHT", -8, 75)
	frame:SetSize(170, 105)
	frame:CreateBorder()
	K.CreateFontString(frame, 16, GUILD, "", "system", "TOPLEFT", 16, -6)

	frame.entries = {}
	for i = 1, 4 do
		local entry = CreateFrame("Frame", nil, frame)
		entry:SetPoint("LEFT", 10, 0)
		entry:SetPoint("RIGHT", -10, 0)
		entry:SetHeight(18)

		entry.CharacterName = K.CreateFontString(entry, 14, "", "", false, "LEFT", 6, 0)
		entry.CharacterName:SetPoint("RIGHT", -30, 0)
		entry.CharacterName:SetJustifyH("LEFT")

		entry.Level = K.CreateFontString(entry, 14, "", "system")
		entry.Level:SetJustifyH("LEFT")
		entry.Level:ClearAllPoints()
		entry.Level:SetPoint("LEFT", entry, "RIGHT", -22, 0)

		entry:SetScript("OnEnter", Module.GuildBest_UpdateTooltip)
		entry:SetScript("OnLeave", K.HideTooltip)

		if i == 1 then
			entry:SetPoint("TOP", frame, 0, -26)
		else
			entry:SetPoint("TOP", frame.entries[i - 1], "BOTTOM")
		end

		frame.entries[i] = entry
	end

	-- Avoid overlapping the weekly description text when no AngryKeystones
	if not hasAngryKeystones and ChallengesFrame.WeeklyInfo and ChallengesFrame.WeeklyInfo.Child and ChallengesFrame.WeeklyInfo.Child.Description then
		ChallengesFrame.WeeklyInfo.Child.Description:SetPoint("CENTER", 0, 20)
	end

	-- Details "keys" window toggle (if Details Keystone module exists)
	if SlashCmdList and SlashCmdList.KEYSTONE then
		local button = CreateFrame("Button", nil, frame)
		button:SetSize(20, 20)
		button:SetPoint("TOPRIGHT", -12, -5)
		button:SetScript("OnClick", function()
			if _G.DetailsKeystoneInfoFrame and _G.DetailsKeystoneInfoFrame.IsShown and _G.DetailsKeystoneInfoFrame:IsShown() then
				_G.DetailsKeystoneInfoFrame:Hide()
			else
				-- Details expects "/keys" + editBox in many builds; fall back to calling without args.
				if ChatFrame1 and ChatFrame1.editBox then
					SlashCmdList.KEYSTONE("/keys", ChatFrame1.editBox)
				else
					SlashCmdList.KEYSTONE()
				end
			end
		end)

		local tex = button:CreateTexture(nil, "ARTWORK")
		tex:SetAllPoints()
		tex:SetTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Up")
		tex:SetVertexColor(0, 1, 0)

		local hl = button:CreateTexture(nil, "HIGHLIGHT")
		hl:SetAllPoints()
		hl:SetTexture("Interface\\Buttons\\UI-GuildButton-PublicNote-Up")
	end

	-- RaiderIO has its own guild weekly frame; hide if present
	if _G.RaiderIO_GuildWeeklyFrame then
		K.HideInterfaceOption(_G.RaiderIO_GuildWeeklyFrame)
	end
end

function Module:GuildBest_SetUp(leaderInfo)
	self.leaderInfo = leaderInfo

	local template = CHALLENGE_MODE_GUILD_BEST_LINE
	if leaderInfo.isYou then
		template = CHALLENGE_MODE_GUILD_BEST_LINE_YOU
	end

	local classColorStr = (leaderInfo.classFileName and K.ClassColors[leaderInfo.classFileName] and K.ClassColors[leaderInfo.classFileName].colorStr) or "ffffffff"
	self.CharacterName:SetText(format(template, classColorStr, leaderInfo.name or ""))
	self.Level:SetText(leaderInfo.keystoneLevel or "")
end

function Module:GuildBest_Update()
	if not frame then
		Module:GuildBest_Create()
	end

	if self.leadersAvailable then
		local leaders = C_ChallengeMode_GetGuildLeaders()
		if leaders and #leaders > 0 then
			for i = 1, 4 do
				local info = leaders[i]
				if not info then
					break
				end
				Module.GuildBest_SetUp(frame.entries[i], info)
			end
			frame:Show()
		else
			frame:Hide()
		end
	end

	-- AngryKeystones layout adjustments (updated to match newer NDui offsets)
	if not resize and hasAngryKeystones and self.WeeklyInfo and self.WeeklyInfo.Child and self.WeeklyInfo.Child.WeeklyChest then
		hooksecurefunc(self.WeeklyInfo.Child.WeeklyChest, "SetPoint", function(chest, _, x, y)
			if x == 100 and y == 0 then
				chest:SetPoint("LEFT", 110, -5)
			end
		end)

		if self.WeeklyInfo.Child.ThisWeekLabel then
			self.WeeklyInfo.Child.ThisWeekLabel:SetPoint("TOP", -125, -25)
		end

		local schedule = _G.AngryKeystones and _G.AngryKeystones.Modules and _G.AngryKeystones.Modules.Schedule
		if schedule and schedule.AffixFrame then
			frame:SetWidth(246)
			frame:ClearAllPoints()
			frame:SetPoint("BOTTOMLEFT", schedule.AffixFrame, "TOPLEFT", 0, 10)
		end

		local keystoneText = schedule and schedule.KeystoneText
		if keystoneText and self.WeeklyInfo.Child.DungeonScoreInfo and self.WeeklyInfo.Child.DungeonScoreInfo.Score then
			keystoneText:SetFontObject(Game13Font)
			keystoneText:ClearAllPoints()
			keystoneText:SetPoint("TOP", self.WeeklyInfo.Child.DungeonScoreInfo.Score, "BOTTOM", 0, -3)
		end

		resize = true
	end
end

-- Keystone info (weekly runs + account keys)
local function sortHistory(a, b)
	if a.level == b.level then
		return a.mapChallengeModeID < b.mapChallengeModeID
	end
	return a.level > b.level
end

function Module:KeystoneInfo_WeeklyRuns()
	local runHistory = C_MythicPlus_GetRunHistory(false, true)
	local numRuns = runHistory and #runHistory
	if not numRuns or numRuns <= 0 then
		return
	end

	local showAll = IsShiftKeyDown()
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(showAll and CHALLENGE_MODE_THIS_WEEK or format(WEEKLY_REWARDS_MYTHIC_TOP_RUNS, WeeklyRunsThreshold), "(" .. numRuns .. ")", 0.6, 0.8, 1)

	sort(runHistory, sortHistory)

	local limit = showAll and numRuns or WeeklyRunsThreshold
	for i = 1, limit do
		local runInfo = runHistory[i]
		if not runInfo then
			break
		end

		local name = C_ChallengeMode_GetMapUIInfo(runInfo.mapChallengeModeID) or ""
		local r, g, b = 0, 1, 0
		if not runInfo.completed then
			r, g, b = 1, 0, 0
		end
		GameTooltip:AddDoubleLine(name, "Lv." .. (runInfo.level or 0), 1, 1, 1, r, g, b)
	end

	if not showAll then
		GameTooltip:AddLine(L["Hold Shift"] or "Hold Shift", 0.6, 0.8, 1)
	end

	GameTooltip:Show()
end

function Module:KeystoneInfo_Create()
	local db = EnsureDB()

	local texture = (C_Item_GetItemIconByID and C_Item_GetItemIconByID(158923)) or 525134
	local iconColor = K.QualityColors[(Enum and Enum.ItemQuality and Enum.ItemQuality.Epic) or 4] or K.QualityColors[4]

	local button = CreateFrame("Frame", nil, ChallengesFrame.WeeklyInfo, "BackdropTemplate")
	button:SetPoint("BOTTOMLEFT", 2, 67)
	button:SetSize(32, 32)

	button.Icon = button:CreateTexture(nil, "ARTWORK")
	button.Icon:SetAllPoints()
	button.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	button.Icon:SetTexture(texture)

	button:CreateBorder()
	if button.KKUI_Border and iconColor then
		button.KKUI_Border:SetVertexColor(iconColor.r, iconColor.g, iconColor.b)
	end

	button:SetScript("OnEnter", function(self)
		local keystoneDB = db.KeystoneInfo

		GameTooltip:ClearLines()
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine(L["Account Keystones"] or "Account Keystones")

		if keystoneDB then
			for fullName, info in pairs(keystoneDB) do
				local name = Ambiguate(fullName, "none")
				local mapID, level, class, faction = strsplit(":", info)

				local color = K.RGBToHex(K.ColorClass(class))
				local factionColor = (faction == "Horde") and "|cffff5040" or "|cff00adf0"
				local dungeon = C_ChallengeMode_GetMapUIInfo(tonumber(mapID)) or "?"

				GameTooltip:AddDoubleLine(format(color .. "%s:|r", name), format("%s%s(%s)|r", factionColor, dungeon, level or "?"))
			end
		end

		GameTooltip:AddLine("")
		GameTooltip:AddDoubleLine(" ", (K.ScrollButton or "") .. (L["Reset Data"] or "Reset Data") .. " ", 1, 1, 1, 0.5, 0.7, 1)
		GameTooltip:Show()
	end)

	button:SetScript("OnLeave", K.HideTooltip)
	button:SetScript("OnMouseUp", function(_, btn)
		if btn == "MiddleButton" then
			if db.KeystoneInfo then
				wipe(db.KeystoneInfo)
			end
			Module:KeystoneInfo_Update() -- refresh own keystone info after reset
		end
	end)
end

function Module:KeystoneInfo_UpdateBag()
	local keystoneMapID = C_MythicPlus_GetOwnedKeystoneChallengeMapID()
	if keystoneMapID then
		return keystoneMapID, C_MythicPlus_GetOwnedKeystoneLevel()
	end
end

function Module:KeystoneInfo_Update()
	local db = EnsureDB()

	local mapID, keystoneLevel = Module:KeystoneInfo_UpdateBag()
	if mapID then
		db.KeystoneInfo[MY_FULLNAME] = mapID .. ":" .. keystoneLevel .. ":" .. K.Class .. ":" .. K.Faction
	else
		db.KeystoneInfo[MY_FULLNAME] = nil
	end
end

-- Loader
local function LoadGuildBest()
	if not ChallengesFrame then
		return
	end

	hooksecurefunc(ChallengesFrame, "Update", Module.GuildBest_Update)

	-- Add Keystone helper UI (account keys + weekly runs info)
	Module:KeystoneInfo_Create()
	if ChallengesFrame.WeeklyInfo and ChallengesFrame.WeeklyInfo.Child and ChallengesFrame.WeeklyInfo.Child.WeeklyChest then
		ChallengesFrame.WeeklyInfo.Child.WeeklyChest:HookScript("OnEnter", Module.KeystoneInfo_WeeklyRuns)
	end
end

function Module.GuildBest_OnLoad(event, addon)
	if addon == "Blizzard_ChallengesUI" then
		LoadGuildBest()
		K:UnregisterEvent(event, Module.GuildBest_OnLoad)
	end
end

function Module:CreateGuildBest()
	if not C["Misc"].MDGuildBest then
		return
	end

	hasAngryKeystones = C_AddOns_IsAddOnLoaded and C_AddOns_IsAddOnLoaded("AngryKeystones")

	-- If Challenges UI is already loaded, hook immediately; otherwise wait for ADDON_LOADED.
	if C_AddOns_IsAddOnLoaded and C_AddOns_IsAddOnLoaded("Blizzard_ChallengesUI") and ChallengesFrame then
		LoadGuildBest()
	else
		K:RegisterEvent("ADDON_LOADED", Module.GuildBest_OnLoad)
	end

	Module:KeystoneInfo_Update()
	K:RegisterEvent("BAG_UPDATE", Module.KeystoneInfo_Update)
end

Module:RegisterMisc("MDGuildBest", Module.CreateGuildBest)
