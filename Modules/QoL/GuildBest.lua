--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/QoL/GuildBest.lua
	Purpose:
		On the Mythic Plus dungeons window, list the best runs by guild members this
		week: who, in which dungeon, at what key level. Hover a row for the dungeon
		and the whole party.

		The panel is a child of the window made by this file, so it opens and closes
		with it and nothing on the window itself is changed. The window asks the
		game for the guild's runs when it opens, and this file reads the answer when
		the game says it has arrived.
-----------------------------------------------------------------------------]]

local K = KkthnxUI[1]

if not (K.Client and K.Client.IsRetail) then
	return
end

local Module = K:GetModule("QoL")

local IsSecret = K.IsSecret
local format = string.format
local CreateFrame = CreateFrame
local C_ChallengeMode = C_ChallengeMode
local GameTooltip = GameTooltip

-- Game strings, with a plain fallback in case one is missing.
local POWER_LEVEL = _G.CHALLENGE_MODE_POWER_LEVEL or "Level %d"
local LINE = _G.CHALLENGE_MODE_GUILD_BEST_LINE or "|c%s%s|r"
local LINE_YOU = _G.CHALLENGE_MODE_GUILD_BEST_LINE_YOU or "|c%s%s|r"

local ROWS = 4
local ROW_HEIGHT = 18

local panel

local function ClassHex(classFile)
	local color = classFile and RAID_CLASS_COLORS[classFile]
	return color and color.colorStr or "ffffffff"
end

local function OnEnter(row)
	local run = row.run
	if not run then
		return
	end
	GameTooltip:SetOwner(row, "ANCHOR_RIGHT")
	GameTooltip:SetText(C_ChallengeMode.GetMapUIInfo(run.mapChallengeModeID) or "", 1, 1, 1)
	GameTooltip:AddLine(format(POWER_LEVEL, run.keystoneLevel))
	for _, member in ipairs(run.members) do
		GameTooltip:AddLine(format(LINE, ClassHex(member.classFileName), member.name))
	end
	GameTooltip:Show()
end

local function Fill(row, run)
	row.run = run
	local template = run.isYou and LINE_YOU or LINE
	row.Name:SetText(format(template, ClassHex(run.classFileName), run.name))
	row.Level:SetText(run.keystoneLevel)
	row:Show()
end

local function Refresh()
	if not panel then
		return
	end
	local leaders = C_ChallengeMode.GetGuildLeaders()
	if IsSecret(leaders) or not leaders or #leaders == 0 then
		panel:Hide()
		return
	end
	for index, row in ipairs(panel.Rows) do
		local run = leaders[index]
		if run then
			Fill(row, run)
		else
			row.run = nil
			row:Hide()
		end
	end
	panel:Show()
end

local function Build()
	local window = _G.ChallengesFrame
	if panel or not window then
		return
	end

	panel = CreateFrame("Frame", nil, window)
	panel:SetPoint("BOTTOMRIGHT", -8, 75)
	panel:SetSize(170, 30 + ROWS * ROW_HEIGHT)
	K.CreateGradientBackground(panel, 0.5)
	K.CreateBorder(panel)

	local title = panel:CreateFontString(nil, "OVERLAY")
	K.SetFont(title, 14, K.FontOutlineStyle())
	title:SetPoint("TOPLEFT", 12, -8)
	title:SetText(_G.GUILD)
	title:SetTextColor(K.Colors.accent[1], K.Colors.accent[2], K.Colors.accent[3])

	panel.Rows = {}
	for index = 1, ROWS do
		local row = CreateFrame("Frame", nil, panel)
		row:SetHeight(ROW_HEIGHT)
		-- Both anchors are top ones so the row's height alone decides its bottom.
		row:SetPoint("TOPLEFT", panel, "TOPLEFT", 8, -26 - (index - 1) * ROW_HEIGHT)
		row:SetPoint("TOPRIGHT", panel, "TOPRIGHT", -8, -26 - (index - 1) * ROW_HEIGHT)
		row.Name = row:CreateFontString(nil, "OVERLAY")
		K.SetFont(row.Name, 12, K.FontOutlineStyle())
		row.Name:SetPoint("LEFT", 4, 0)
		row.Name:SetPoint("RIGHT", -28, 0)
		row.Name:SetJustifyH("LEFT")
		row.Name:SetWordWrap(false)
		row.Level = row:CreateFontString(nil, "OVERLAY")
		K.SetFont(row.Level, 12, K.FontOutlineStyle())
		row.Level:SetPoint("RIGHT", -2, 0)
		row.Level:SetTextColor(K.Colors.gold[1], K.Colors.gold[2], K.Colors.gold[3])
		row:SetScript("OnEnter", OnEnter)
		row:SetScript("OnLeave", GameTooltip_Hide)
		panel.Rows[index] = row
	end

	window:HookScript("OnShow", Refresh)
	Refresh()
end

local function OnAddOnLoaded(_, _, addon)
	if addon == "Blizzard_ChallengesUI" then
		Build()
	end
end

function Module:SetupGuildBest()
	if C_AddOns.IsAddOnLoaded("Blizzard_ChallengesUI") then
		Build()
	else
		self:RegisterEvent("ADDON_LOADED", OnAddOnLoaded)
	end
	self:RegisterEvent("CHALLENGE_MODE_LEADERS_UPDATE", Refresh)
end
