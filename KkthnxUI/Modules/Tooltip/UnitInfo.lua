--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Tooltip/UnitInfo.lua
	Purpose:
		Enrich the unit tooltip: class / reaction coloured name with faction crest,
		raid and role icons, a condensed identity block, guild rank, target line,
		mount, Mythic+ rating, and "targeted by". Also colours the border by unit or
		item quality. All data hooks go through the modern TooltipDataProcessor and
		stay secret-value safe for Midnight.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

local Module = K:GetModule("Tooltip")

local _G = _G
local format = string.format
local select = select
local tconcat = table.concat

local UnitName = UnitName
local UnitPVPName = _G.UnitPVPName
local UnitClass = UnitClass
local UnitClassification = UnitClassification
local UnitIsPlayer = UnitIsPlayer
local UnitReaction = UnitReaction
local UnitExists = UnitExists
local UnitLevel = UnitLevel
local UnitIsAFK = UnitIsAFK
local UnitIsDND = UnitIsDND
local UnitGroupRolesAssigned = UnitGroupRolesAssigned
local UnitIsUnit = UnitIsUnit
local UnitFactionGroup = _G.UnitFactionGroup
local GetRaidTargetIndex = _G.GetRaidTargetIndex
local IsInRaid = IsInRaid
local GetNumGroupMembers = GetNumGroupMembers
local GetGuildInfo = GetGuildInfo
local GetCreatureDifficultyColor = _G.GetCreatureDifficultyColor
local C_Item = C_Item
local C_MountJournal = C_MountJournal
local C_PlayerInfo = C_PlayerInfo
local IsSecret = K.IsSecret

local classColors = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS
local ICON_LIST = _G.ICON_LIST

local FACTION_HORDE = _G.FACTION_HORDE
local FACTION_ALLIANCE = _G.FACTION_ALLIANCE
local LEVEL = _G.LEVEL
local PLAYER = _G.PLAYER

-- Faction crest markup, shown inline on the name line in place of the "Horde" /
-- "Alliance" text line (which we drop).
local FACTION_ICON = {
	Horde = "|A:communities-create-button-wow-horde:13:15|a ",
	Alliance = "|A:communities-create-button-wow-alliance:13:15|a ",
}

-- Coloured classification suffix for the level line, mirroring the frames.
local CLASSIFICATION = {
	elite = " |cffcc8800" .. (_G.ELITE or "Elite") .. "|r",
	rare = " |cffff99cc" .. (_G.ITEM_QUALITY3_DESC or "Rare") .. "|r",
	rareelite = " |cffff99cc" .. (_G.ITEM_QUALITY3_DESC or "Rare") .. "|r |cffcc8800" .. (_G.ELITE or "Elite") .. "|r",
	worldboss = " |cffff0000" .. (_G.BOSS or "Boss") .. "|r",
}

-- Role icon markup from the LFG role atlas, sized for the name line.
local ROLE_ICON = {
	TANK = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:0:19:22:41|t",
	HEALER = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:20:39:1:20|t",
	DAMAGER = "|TInterface\\LFGFrame\\UI-LFG-ICON-PORTRAITROLES:16:16:0:0:64:64:20:39:22:41|t",
}

-- Find the first tooltip line (past the name) whose text matches a predicate.
local function FindLine(tt, predicate)
	for i = 2, tt:NumLines() do
		local fs = _G["GameTooltipTextLeft" .. i]
		local text = fs and fs:GetText()
		if text and not IsSecret(text) and predicate(text) then
			return fs, i
		end
	end
end

-- Colour for a unit: class colour for players, reaction colour otherwise.
local function UnitColor(unit)
	if UnitIsPlayer(unit) then
		local _, class = UnitClass(unit)
		-- The class token can be a secret on some units, and a secret can never be
		-- used as a table key, so skip the palette lookup when it is.
		if class and not IsSecret(class) then
			-- Prefer our custom class palette so the tooltip matches the frames.
			local color = K.oUF and K.oUF.colors.class[class]
			if color then
				return color:GetRGB()
			end
			color = classColors[class]
			if color then
				return color.r, color.g, color.b
			end
		end
	else
		local reaction = UnitReaction(unit, "player")
		if reaction and not IsSecret(reaction) then
			-- Read our custom reaction palette so the tooltip matches the frames,
			-- falling back to Blizzard's if ours has no entry for this reaction.
			local color = K.oUF and K.oUF.colors and K.oUF.colors.reaction and K.oUF.colors.reaction[reaction]
			if color then
				return color:GetRGB()
			end
			local fallback = _G.FACTION_BAR_COLORS and _G.FACTION_BAR_COLORS[reaction]
			if fallback then
				return fallback.r, fallback.g, fallback.b
			end
		end
	end
	return 1, 1, 1
end

function Module:OnUnitTooltip(tt)
	local _, unit = tt:GetUnit()
	-- The unit token itself can be a secret value in Midnight (world objects,
	-- arena opponents). Unit APIs reject secret arguments while our code runs
	-- tainted, so bail before touching it.
	if not unit or IsSecret(unit) then
		return
	end
	if not UnitExists(unit) then
		return
	end

	local db = C.Tooltip
	local line = _G.GameTooltipTextLeft1
	local isPlayer = UnitIsPlayer(unit)

	-- Class / reaction coloured name, with an AFK / DND flag for players.
	if db.ClassColorName and line then
		local r, g, b = UnitColor(unit)
		line:SetTextColor(r, g, b)
	end
	if isPlayer and line then
		local name = line:GetText()
		if name and not IsSecret(name) then
			-- Swap in the PvP name (which carries the player's title) if wanted.
			if db.ShowTitle then
				local pvpName = UnitPVPName(unit)
				if pvpName and not IsSecret(pvpName) and pvpName ~= "" then
					name = pvpName
				end
			end
			-- Append the realm for cross-realm players.
			if db.ShowRealm then
				local realm = select(2, UnitName(unit))
				if realm and not IsSecret(realm) and realm ~= "" then
					name = name .. "-" .. realm
				end
			end
			-- Faction crest ahead of the name, standing in for the text line.
			local prefix = ""
			if db.ShowFactionIcon then
				local faction = UnitFactionGroup(unit)
				if faction and not IsSecret(faction) and FACTION_ICON[faction] then
					prefix = FACTION_ICON[faction]
				end
			end
			-- Raid target marker (skull, star, ...) ahead of the name.
			if db.ShowRaidIcon and ICON_LIST then
				local mark = GetRaidTargetIndex(unit)
				if mark and not IsSecret(mark) and ICON_LIST[mark] then
					prefix = prefix .. ICON_LIST[mark] .. "14|t "
				end
			end
			-- Role icon prefix for group members.
			if db.ShowRole then
				local role = UnitGroupRolesAssigned(unit)
				if role and ROLE_ICON[role] then
					prefix = prefix .. ROLE_ICON[role] .. " "
				end
			end
			-- AFK / DND flag suffix.
			local afk, dnd = UnitIsAFK(unit), UnitIsDND(unit)
			local flag = ""
			if not IsSecret(afk) and afk then
				flag = " |cffffcc00" .. CHAT_FLAG_AFK .. "|r"
			elseif not IsSecret(dnd) and dnd then
				flag = " |cffffcc00" .. CHAT_FLAG_DND .. "|r"
			end
			line:SetText(prefix .. name .. flag)
		end
	end

	-- Guild rank. Blizzard already prints the guild name on its own line, so we
	-- find that line (it contains the guild name, sometimes wrapped in <>) and
	-- append the rank rather than adding a duplicate. A muted gold keeps it from
	-- competing with the class-coloured name.
	if db.ShowGuild and isPlayer then
		local guild, rank = GetGuildInfo(unit)
		if guild and not IsSecret(guild) then
			local guildLine = FindLine(tt, function(t)
				return t:find(guild, 1, true) ~= nil
			end)
			if guildLine then
				if rank and rank ~= "" then
					guildLine:SetText(format("%s |cffababab(%s)|r", guild, rank))
				end
				guildLine:SetTextColor(0.85, 0.75, 0.5)
			end
		end
	end

	-- Colour the health bar to match and keep it anchored outside the tooltip.
	local bar = _G.GameTooltipStatusBar
	if bar then
		local r, g, b = UnitColor(unit)
		bar:SetStatusBarColor(r, g, b)
		if Module.PositionHealthBar then
			Module.PositionHealthBar(bar)
		end
	end

	-- Level line: recolour by difficulty, tidy the identity block. For creatures
	-- we add an Elite/Rare/Boss suffix, for players we drop the "(Player)" tag and
	-- class-colour the spec line just below so the identity reads as one block.
	local level = UnitLevel(unit)
	if level and not IsSecret(level) and LEVEL then
		local levelLine, levelIndex = FindLine(tt, function(t)
			return t:find(LEVEL, 1, true) ~= nil
		end)
		if levelLine and GetCreatureDifficultyColor then
			local color = GetCreatureDifficultyColor(level)
			if color then
				levelLine:SetTextColor(color.r, color.g, color.b)
			end
			if isPlayer then
				-- Strip the redundant "(Player)" type tag.
				local text = levelLine:GetText()
				if PLAYER and text and not IsSecret(text) then
					local stripped = text:gsub("%s*%(" .. PLAYER .. "%)", "")
					if stripped ~= text then
						levelLine:SetText(stripped)
					end
				end
				-- Class-colour the spec line directly under the level line.
				local specLine = levelIndex and _G["GameTooltipTextLeft" .. (levelIndex + 1)]
				local _, class = UnitClass(unit)
				local cc = class and classColors[class]
				if specLine and cc then
					specLine:SetTextColor(cc.r, cc.g, cc.b)
				end
			else
				local classify = UnitClassification(unit)
				local suffix = classify and not IsSecret(classify) and CLASSIFICATION[classify]
				local text = levelLine:GetText()
				if suffix and text and not IsSecret(text) then
					levelLine:SetText(text .. suffix)
				end
			end
		end
	end

	-- Target line.
	if db.ShowTarget and UnitExists(unit .. "target") then
		local targetName = UnitName(unit .. "target")
		if targetName then
			local r, g, b = UnitColor(unit .. "target")
			-- Comparing a secret name is illegal while tainted, so only special
			-- case "you" when the name is a plain value.
			if not IsSecret(targetName) and targetName == K.Name then
				tt:AddLine(format("%s: %s", TARGET, "|cffff5555" .. YOU .. "|r"))
			else
				tt:AddLine(format("%s: %s", TARGET, targetName), r, g, b)
			end
		end
	end

	-- A thin separator sets the stat block (mount / rating / item level) apart
	-- from the character identity above it.
	if isPlayer and (db.ShowMount or db.ShowMythicScore or db.ShowItemLevel) then
		tt:AddLine(" ")
	end

	-- Mount the unit is riding, from their buff list.
	if db.ShowMount and isPlayer and unit ~= "player" and C_MountJournal and C_MountJournal.GetMountFromSpell then
		for i = 1, 40 do
			local data = K.GetAuraData(unit, i, "HELPFUL")
			if not data then
				break
			end
			local spellID = data.spellId
			if spellID and not IsSecret(spellID) and C_MountJournal.GetMountFromSpell(spellID) then
				tt:AddDoubleLine(_G.MOUNT or "Mount", data.name, nil, nil, nil, 1, 1, 1)
				break
			end
		end
	end

	-- Mythic+ rating for players who have one this season.
	if db.ShowMythicScore and isPlayer and C_PlayerInfo and C_PlayerInfo.GetPlayerMythicPlusRatingSummary then
		local info = C_PlayerInfo.GetPlayerMythicPlusRatingSummary(unit)
		local score = info and info.currentSeasonScore
		if score and not IsSecret(score) and score > 0 then
			tt:AddDoubleLine(_G.DUNGEON_SCORE or "Mythic+ Rating", score, nil, nil, nil, 1, 1, 1)
		end
	end

	-- Who in your group is currently targeting this unit.
	if db.ShowTargetedBy and GetNumGroupMembers and GetNumGroupMembers() > 0 then
		local prefix = IsInRaid() and "raid" or "party"
		local names = {}
		for i = 1, GetNumGroupMembers() do
			local member = prefix .. i
			if not UnitIsUnit(member, "player") then
				local isTarget = UnitIsUnit(member .. "target", unit)
				if not IsSecret(isTarget) and isTarget then
					local mname = UnitName(member)
					if mname and not IsSecret(mname) then
						local r, g, b = UnitColor(member)
						names[#names + 1] = format("|cff%02x%02x%02x%s|r", r * 255, g * 255, b * 255, mname)
					end
				end
			end
		end
		if #names > 0 then
			tt:AddLine(format("%s: %s", _G.TARGET or "Target", tconcat(names, ", ")), nil, nil, nil, true)
		end
	end

	-- Item level and spec for players (async inspect, see Inspect.lua).
	if db.ShowItemLevel and isPlayer and self.AddInspectInfo then
		self:AddInspectInfo(tt, unit)
	end
end

-- Strip the loud PvP line Blizzard adds.
function Module:HidePvPLine(tt)
	if not C.Tooltip.HidePvP then
		return
	end
	for i = 2, tt:NumLines() do
		local fsLine = _G["GameTooltipTextLeft" .. i]
		local text = fsLine and fsLine:GetText()
		if text and not IsSecret(text) and text == PVP_ENABLED then
			fsLine:SetText(nil)
		end
	end
end

function Module:SetupUnitInfo()
	if not (TooltipDataProcessor and TooltipDataProcessor.AddTooltipPostCall) then
		return
	end

	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Unit, function(tt)
		if tt == _G.GameTooltip then
			Module:OnUnitTooltip(tt)
			Module:HidePvPLine(tt)
		end
	end)

	-- Drop the standalone "Horde" / "Alliance" faction line, we show a crest on
	-- the name line instead. Returning true from a line pre-call skips the line
	-- entirely, so no blank gap is left behind.
	if TooltipDataProcessor.AddLinePreCall and Enum.TooltipDataLineType then
		TooltipDataProcessor.AddLinePreCall(Enum.TooltipDataLineType.None, function(tt, lineData)
			if tt ~= _G.GameTooltip or not C.Tooltip.ShowFactionIcon then
				return
			end
			local text = lineData and lineData.leftText
			if text and not IsSecret(text) and (text == FACTION_HORDE or text == FACTION_ALLIANCE) then
				return true
			end
		end)
	end

	-- Colour the border by item quality on any of our skinned item tooltips,
	-- including the compare (shopping) tooltips, not just the main one.
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(tt)
		if not C.Tooltip.BorderColor or not tt.KKUI_Border then
			return
		end
		local _, link
		if tt.GetItem then
			_, link = tt:GetItem()
		end
		local quality = link and C_Item and C_Item.GetItemInfo and select(3, C_Item.GetItemInfo(link))
		if quality and quality > 1 and C_Item.GetItemQualityColor then
			local r, g, b = C_Item.GetItemQualityColor(quality)
			tt.KKUI_Border:SetVertexColor(r, g, b)
		else
			K.ResetBorderColor(tt.KKUI_Border)
		end
	end)

	-- Reset the unit border colour whenever the tooltip is cleared, so an item or
	-- spell tooltip after a unit does not keep the unit's colour.
	_G.GameTooltip:HookScript("OnTooltipCleared", function(tt)
		if C.Tooltip.BorderColor and tt.KKUI_Border then
			K.ResetBorderColor(tt.KKUI_Border)
		end
	end)
end
