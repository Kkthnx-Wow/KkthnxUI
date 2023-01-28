local K, C, L = unpack(KkthnxUI)
local Module = K:GetModule("Miscellaneous")

local pairs = _G.pairs
local string_format = _G.string.format
local string_split = _G.string.split
local table_sort = _G.table.sort
local table_wipe = _G.table.wipe
local tonumber = _G.tonumber

local Ambiguate = _G.Ambiguate
local CHALLENGE_MODE_GUILD_BEST_LINE = _G.CHALLENGE_MODE_GUILD_BEST_LINE
local CHALLENGE_MODE_GUILD_BEST_LINE_YOU = _G.CHALLENGE_MODE_GUILD_BEST_LINE_YOU
local CHALLENGE_MODE_POWER_LEVEL = _G.CHALLENGE_MODE_POWER_LEVEL
local C_ChallengeMode_GetGuildLeaders = _G.C_ChallengeMode.GetGuildLeaders
local C_ChallengeMode_GetMapUIInfo = _G.C_ChallengeMode.GetMapUIInfo
local C_MythicPlus_GetOwnedKeystoneChallengeMapID = _G.C_MythicPlus.GetOwnedKeystoneChallengeMapID
local C_MythicPlus_GetOwnedKeystoneLevel = _G.C_MythicPlus.GetOwnedKeystoneLevel
local C_MythicPlus_GetRunHistory = _G.C_MythicPlus.GetRunHistory
local GetItemInfo = _G.GetItemInfo
local CHALLENGE_MODE_THIS_WEEK = _G.CHALLENGE_MODE_THIS_WEEK
local WEEKLY_REWARDS_MYTHIC_TOP_RUNS = _G.WEEKLY_REWARDS_MYTHIC_TOP_RUNS
local hooksecurefunc = _G.hooksecurefunc

local hasAngryKeystones
local frame
local WeeklyRunsThreshold = 8

function Module:GuildBest_UpdateTooltip()
	local leaderInfo = self.leaderInfo
	if not leaderInfo then
		return
	end

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")

	local name = C_ChallengeMode_GetMapUIInfo(leaderInfo.mapChallengeModeID)
	GameTooltip:SetText(name, 1, 1, 1)
	GameTooltip:AddLine(format(CHALLENGE_MODE_POWER_LEVEL, leaderInfo.keystoneLevel))

	for i = 1, #leaderInfo.members do
		local classColorStr = K.ClassColors[leaderInfo.members[i].classFileName].colorStr
		GameTooltip:AddLine(format(CHALLENGE_MODE_GUILD_BEST_LINE, classColorStr, leaderInfo.members[i].name))
	end

	GameTooltip:Show()
end

function Module:GuildBest_Create()
	frame = CreateFrame("Frame", nil, ChallengesFrame, "BackdropTemplate")
	frame:SetPoint("BOTTOMRIGHT", -10, 75)
	frame:SetSize(170, 105)
	frame:CreateBorder()
	K.CreateFontString(frame, 16, GUILD, "", "system", "TOPLEFT", 16, -6)

	frame.entries = {}
	for i = 1, 4 do
		local entry = CreateFrame("Frame", nil, frame)
		entry:SetPoint("LEFT", 10, 0)
		entry:SetPoint("RIGHT", -10, 0)
		entry:SetHeight(18)

		entry.CharacterName = K.CreateFontString(entry, 13, "", "", false, "LEFT", 6, 0)
		entry.CharacterName:SetPoint("RIGHT", -30, 0)
		entry.CharacterName:SetJustifyH("LEFT")

		entry.Level = K.CreateFontString(entry, 13, "", "", "system")
		entry.Level:SetJustifyH("LEFT")
		entry.Level:ClearAllPoints()

		entry.Level:SetPoint("LEFT", entry, "RIGHT", -22, 0)
		entry:SetScript("OnEnter", self.GuildBest_UpdateTooltip)
		entry:SetScript("OnLeave", K.HideTooltip)

		if i == 1 then
			entry:SetPoint("TOP", frame, 0, -26)
		else
			entry:SetPoint("TOP", frame.entries[i - 1], "BOTTOM")
		end

		frame.entries[i] = entry
	end

	if not hasAngryKeystones then
		ChallengesFrame.WeeklyInfo.Child.Description:SetPoint("CENTER", 0, 20)
	end
end

function Module:GuildBest_SetUp(leaderInfo)
	self.leaderInfo = leaderInfo
	local str = CHALLENGE_MODE_GUILD_BEST_LINE
	if leaderInfo.isYou then
		str = CHALLENGE_MODE_GUILD_BEST_LINE_YOU
	end

	local classColorStr = K.ClassColors[leaderInfo.classFileName].colorStr
	self.CharacterName:SetText(string_format(str, classColorStr, leaderInfo.name))
	self.Level:SetText(leaderInfo.keystoneLevel)
end

local resize
function Module:GuildBest_Update()
	if not frame then
		Module:GuildBest_Create()
	end

	if self.leadersAvailable then
		local leaders = C_ChallengeMode_GetGuildLeaders()
		if leaders and #leaders > 0 then
			for i = 1, #leaders do
				Module.GuildBest_SetUp(frame.entries[i], leaders[i])
			end
			frame:Show()
		else
			frame:Hide()
		end
	end

	if not resize and hasAngryKeystones then
		hooksecurefunc(self.WeeklyInfo.Child.WeeklyChest, "SetPoint", function(frame, _, x, y)
			if x == 100 and y == -30 then
				frame:SetPoint("LEFT", 105, -5)
			end
		end)
		self.WeeklyInfo.Child.ThisWeekLabel:SetPoint("TOP", -135, -25)

		local schedule = AngryKeystones.Modules.Schedule
		frame:SetWidth(246)
		frame:ClearAllPoints()
		frame:SetPoint("BOTTOMLEFT", schedule.AffixFrame, "TOPLEFT", 0, 10)

		local keystoneText = schedule.KeystoneText
		keystoneText:SetFontObject(_G.Game13Font)
		keystoneText:ClearAllPoints()
		keystoneText:SetPoint("TOP", self.WeeklyInfo.Child.DungeonScoreInfo.Score, "BOTTOM", 0, -3)

		local affix = self.WeeklyInfo.Child.Affixes[1]
		if affix then
			affix:ClearAllPoints()
			affix:SetPoint("TOPLEFT", 20, -55)
		end

		resize = true
	end
end

function Module.GuildBest_OnLoad(event, addon)
	if addon == "Blizzard_ChallengesUI" then
		hooksecurefunc(ChallengesFrame, "Update", Module.GuildBest_Update)
		Module:KeystoneInfo_Create()
		ChallengesFrame.WeeklyInfo.Child.WeeklyChest:HookScript("OnEnter", Module.KeystoneInfo_WeeklyRuns)

		K:UnregisterEvent(event, Module.GuildBest_OnLoad)
	end
end

local function sortHistory(entry1, entry2)
	if entry1.level == entry2.level then
		return entry1.mapChallengeModeID < entry2.mapChallengeModeID
	else
		return entry1.level > entry2.level
	end
end

function Module:KeystoneInfo_WeeklyRuns()
	local runHistory = C_MythicPlus_GetRunHistory(false, true)
	local numRuns = runHistory and #runHistory
	if numRuns > 0 then
		local isShiftKeyDown = IsShiftKeyDown()
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(isShiftKeyDown and CHALLENGE_MODE_THIS_WEEK or string_format(WEEKLY_REWARDS_MYTHIC_TOP_RUNS, WeeklyRunsThreshold), "(" .. numRuns .. ")", 0.5, 0.7, 1)
		table_sort(runHistory, sortHistory)

		for i = 1, isShiftKeyDown and numRuns or WeeklyRunsThreshold do
			local runInfo = runHistory[i]
			if not runInfo then
				break
			end

			local name = C_ChallengeMode_GetMapUIInfo(runInfo.mapChallengeModeID)
			local r, g, b = 0, 1, 0
			if not runInfo.completed then
				r, g, b = 1, 0, 0
			end
			GameTooltip:AddDoubleLine(name, "Lv." .. runInfo.level, 1, 1, 1, r, g, b)
		end

		if not isShiftKeyDown then
			GameTooltip:AddLine(L["Hold Shift"], 0.6, 0.8, 1)
		end
		GameTooltip:Show()
	end
end

function Module:KeystoneInfo_Create()
	local texture = select(10, GetItemInfo(158923)) or 525134
	local iconColor = K.QualityColors[Enum.ItemQuality.Epic or 4]
	local button = CreateFrame("Frame", nil, ChallengesFrame.WeeklyInfo, "BackdropTemplate")
	button:SetPoint("BOTTOMLEFT", 4, 67)
	button:SetSize(32, 32)

	button.Icon = button:CreateTexture(nil, "ARTWORK")
	button.Icon:SetAllPoints()
	button.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	button.Icon:SetTexture(texture)

	button:CreateBorder()
	button.KKUI_Border:SetVertexColor(iconColor.r, iconColor.g, iconColor.b)

	button:SetScript("OnEnter", function(self)
		GameTooltip:ClearLines()
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine(L["Account Keystones"])

		for fullName, info in pairs(KkthnxUIDB.KeystoneInfo) do
			local name = Ambiguate(fullName, "none")
			local mapID, level, class, faction = string_split(":", info)
			local color = K.RGBToHex(K.ColorClass(class))
			local factionColor = faction == "Horde" and "|cffff5040" or "|cff00adf0"
			local dungeon = C_ChallengeMode_GetMapUIInfo(tonumber(mapID))
			GameTooltip:AddDoubleLine(string_format(color .. "%s:|r", name), string_format("%s%s(%s)|r", factionColor, dungeon, level))
		end

		GameTooltip:AddLine("")
		GameTooltip:AddDoubleLine(" ", K.ScrollButton .. L["Reset Data"] .. " ", 1, 1, 1, 0.5, 0.7, 1)
		GameTooltip:Show()
	end)

	button:SetScript("OnLeave", K.HideTooltip)
	button:SetScript("OnMouseUp", function(_, btn)
		if btn == "MiddleButton" then
			table_wipe(KkthnxUIDB.KeystoneInfo)
			Module:KeystoneInfo_Update() -- Update own keystone info after reset
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
	local mapID, keystoneLevel = Module:KeystoneInfo_UpdateBag()
	if mapID then
		KkthnxUIDB.KeystoneInfo[K.Name .. "-" .. K.Realm] = mapID .. ":" .. keystoneLevel .. ":" .. K.Class .. ":" .. K.Faction
	else
		KkthnxUIDB.KeystoneInfo[K.Name .. "-" .. K.Realm] = nil
	end
end

function Module:CreateGuildBest()
	if not C["Misc"].MDGuildBest then
		return
	end

	hasAngryKeystones = K.CheckAddOnState("AngryKeystones")
	K:RegisterEvent("ADDON_LOADED", Module.GuildBest_OnLoad)

	Module:KeystoneInfo_Update()
	K:RegisterEvent("BAG_UPDATE", Module.KeystoneInfo_Update)
end

Module:RegisterMisc("MDGuildBest", Module.CreateGuildBest) -- DFUPDATE
