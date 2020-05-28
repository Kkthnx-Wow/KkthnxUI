local K, _, L = unpack(select(2, ...))
local Module = K:GetModule("Miscellaneous")

local _G = _G

local Ambiguate, GetContainerNumSlots, GetContainerItemInfo = _G.Ambiguate, _G.GetContainerNumSlots, _G.GetContainerItemInfo
local CHALLENGE_MODE_GUILD_BEST_LINE = _G.CHALLENGE_MODE_GUILD_BEST_LINE
local CHALLENGE_MODE_GUILD_BEST_LINE_YOU = _G.CHALLENGE_MODE_GUILD_BEST_LINE_YOU
local CHALLENGE_MODE_POWER_LEVEL = _G.CHALLENGE_MODE_POWER_LEVEL
local C_ChallengeMode_GetMapUIInfo, C_ChallengeMode_GetGuildLeaders = _G.C_ChallengeMode.GetMapUIInfo, _G.C_ChallengeMode.GetGuildLeaders
local format, strsplit, strmatch, tonumber, pairs, wipe, select = _G.string.format, _G.string.split, _G.string.match, _G.tonumber, _G.pairs, _G.wipe, _G.select

local frame
function Module:GuildBest_UpdateTooltip()
	local leaderInfo = self.leaderInfo
	if not leaderInfo then return end

	GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
	local name = C_ChallengeMode_GetMapUIInfo(leaderInfo.mapChallengeModeID)
	GameTooltip:SetText(name, 1, 1, 1)
	GameTooltip:AddLine(format(CHALLENGE_MODE_POWER_LEVEL, leaderInfo.keystoneLevel))
	for i = 1, #leaderInfo.members do
		local classColorStr = K.ClassColors[leaderInfo.members[i].classFileName].colorStr
		GameTooltip:AddLine(format(CHALLENGE_MODE_GUILD_BEST_LINE, classColorStr,leaderInfo.members[i].name));
	end
	GameTooltip:Show()
end

function Module:GuildBest_Create()
	frame = CreateFrame("Frame", nil, ChallengesFrame)
	frame:SetPoint("BOTTOMRIGHT", -10, 80)
	frame:SetSize(170, 106)
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
		entry.Level = K.CreateFontString(entry, 14, "", "", "system")
		entry.Level:SetJustifyH("LEFT")
		entry.Level:ClearAllPoints()
		entry.Level:SetPoint("LEFT", entry, "RIGHT", -22, 0)
		entry:SetScript("OnEnter", self.GuildBest_UpdateTooltip)
		entry:SetScript("OnLeave", K.HideTooltip)

		if i == 1 then
			entry:SetPoint("TOP", frame, 0, -26)
		else
			entry:SetPoint("TOP", frame.entries[i-1], "BOTTOM")
		end

		frame.entries[i] = entry
	end
end

function Module:GuildBest_SetUp(leaderInfo)
	self.leaderInfo = leaderInfo
	local str = CHALLENGE_MODE_GUILD_BEST_LINE
	if leaderInfo.isYou then
		str = CHALLENGE_MODE_GUILD_BEST_LINE_YOU
	end

	local classColorStr = K.ClassColors[leaderInfo.classFileName].colorStr
	self.CharacterName:SetText(format(str, classColorStr, leaderInfo.name))
	self.Level:SetText(leaderInfo.keystoneLevel)
end

local resize
function Module:GuildBest_Update()
	if not frame then Module:GuildBest_Create() end
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

	if not resize and IsAddOnLoaded("AngryKeystones") then
		local schedule = AngryKeystones.Modules.Schedule.AffixFrame
		frame:SetWidth(246)
		frame:ClearAllPoints()
		frame:SetPoint("BOTTOMLEFT", schedule, "TOPLEFT", 0, 10)

		self.WeeklyInfo.Child.Label:SetPoint("TOP", -135, -25)

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
		hooksecurefunc("ChallengesFrame_Update", Module.GuildBest_Update)
		Module:KeystoneInfo_Create()

		K:UnregisterEvent(event, Module.GuildBest_OnLoad)
	end
end

-- Keystone Info
local myFaction = K.Faction
local myFullName = K.Name.."-"..K.Realm
local iconColor = K.QualityColors[LE_ITEM_QUALITY_EPIC or 4]

function Module:KeystoneInfo_Create()
	local texture = select(10, GetItemInfo(158923)) or 525134
	local button = CreateFrame("Frame", nil, ChallengesFrame.WeeklyInfo)

	button:SetPoint("BOTTOMLEFT", 4, 66)
	button:SetSize(34, 34)
	button:CreateBorder()
	button.Icon = button:CreateTexture(nil, "ARTWORK")
	button.Icon:SetAllPoints()
	button.Icon:SetTexCoord(unpack(K.TexCoords))
	button.Icon:SetTexture(texture)
	button:SetBackdropBorderColor(iconColor.r, iconColor.g, iconColor.b)
	button:SetScript("OnEnter", function(self)
		GameTooltip:ClearLines()
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:AddLine("Account Keystone")

		for fullName, info in pairs(KkthnxUIData[K.Realm][K.Name].KeystoneInfo) do
			local name = Ambiguate(fullName, "none")
			local mapID, level, class, faction = strsplit(":", info)
			local color = K.RGBToHex(K.ColorClass(class))
			local factionColor = faction == "Horde" and "|cffff5040" or "|cff00adf0"
			local dungeon = C_ChallengeMode_GetMapUIInfo(tonumber(mapID))

			GameTooltip:AddDoubleLine(format(color.."%s:|r", name), format("%s%s(%s)|r", factionColor, dungeon, level))
		end

		GameTooltip:AddDoubleLine(" ", K.GreyColor.."---------------")
		GameTooltip:AddDoubleLine(" ", " |TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:127:204|t ".."Reset Data".." ", 1, 1, 1, 0.6, 0.8, 1)
		GameTooltip:Show()
	end)

	button:SetScript("OnLeave", K.HideTooltip)
	button:SetScript("OnMouseUp", function(_, btn)
		if btn == "MiddleButton" then
			wipe(KkthnxUIData[K.Realm][K.Name].KeystoneInfo)
		end
	end)
end

function Module:KeystoneInfo_UpdateBag()
	for bag = 0, 4 do
		local numSlots = GetContainerNumSlots(bag)
		for slot = 1, numSlots do
			local slotLink = select(7, GetContainerItemInfo(bag, slot))
			local itemString = slotLink and strmatch(slotLink, "|Hkeystone:([0-9:]+)|h(%b[])|h")
			if itemString then
				return slotLink, itemString
			end
		end
	end
end

function Module:KeystoneInfo_Update()
	local link, itemString = Module:KeystoneInfo_UpdateBag()
	if link then
		local _, mapID, level = strsplit(":", itemString)
		KkthnxUIData[K.Realm][K.Name].KeystoneInfo[myFullName] = mapID..":"..level..":"..K.Class..":"..myFaction
	else
		KkthnxUIData[K.Realm][K.Name].KeystoneInfo[myFullName] = nil
	end
end

function Module:CreateMDGuildBest()
	K:RegisterEvent("ADDON_LOADED", self.GuildBest_OnLoad)
	self:KeystoneInfo_Update()
	K:RegisterEvent("BAG_UPDATE", self.KeystoneInfo_Update)
end