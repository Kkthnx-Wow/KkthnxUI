--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Config/GUI/AuraList.lua
	Purpose:
		The aura filter editor. Add spell ids to a whitelist (always show) or a
		blacklist (always hide); both drive K.FilterAura on the unit frame and
		nameplate aura panels. Rows show the spell icon and name so a bare id is
		still recognisable, with a remove button each.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

local GUI = K.GUI

local pairs = pairs
local tonumber = tonumber
local tsort = table.sort
local C_Spell = C_Spell

local function MakeButton(parent, text, width)
	local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	button:SetSize(width or 90, 22)
	button:SetText(text)
	K.SkinButton(button)
	return button
end

-- Re-read the merged lists and refresh every live aura panel so a change shows
-- without a reload.
local function ApplyFilters()
	if K.BuildAuraFilters then
		K.BuildAuraFilters()
	end
	local uf = K:GetModule("UnitFrames", true)
	if uf and uf.all then
		for _, frame in ipairs(uf.all) do
			if frame.UpdateAllElements then
				frame:UpdateAllElements("KKUI_AuraFilter")
			end
		end
	end
end

GUI.CustomPanels = GUI.CustomPanels or {}

function GUI.CustomPanels.AuraFilters(parent)
	local title = parent:CreateFontString(nil, "OVERLAY")
	K.SetFont(title, 14, "OUTLINE")
	title:SetTextColor(K.Colors.accent[1], K.Colors.accent[2], K.Colors.accent[3])
	title:SetPoint("TOPLEFT", 12, -8)
	title:SetText(L["Aura Filters"])

	local help = parent:CreateFontString(nil, "OVERLAY")
	K.SetFont(help, 12)
	help:SetTextColor(0.7, 0.7, 0.7)
	help:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)
	help:SetText(L["Whitelisted auras always show. Blacklisted auras never show."])

	-- Spell id entry with two destinations.
	local edit = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
	edit:SetSize(120, 22)
	edit:SetPoint("TOPLEFT", help, "BOTTOMLEFT", 6, -12)
	edit:SetAutoFocus(false)
	edit:SetNumeric(true)
	K.SkinEditBox(edit)

	local addWhite = MakeButton(parent, L["Add Whitelist"], 120)
	addWhite:SetPoint("LEFT", edit, "RIGHT", 8, 0)
	local addBlack = MakeButton(parent, L["Add Blacklist"], 120)
	addBlack:SetPoint("LEFT", addWhite, "RIGHT", 6, 0)

	-- Two stacked columns of rows, one per list.
	local rows = {}
	local function ClearRows()
		for _, row in ipairs(rows) do
			row:Hide()
		end
		wipe(rows)
	end

	local Refresh

	-- Build the rows for one list under a header, returning the y it ended at.
	local function BuildList(anchor, startY, listKey, header)
		local label = parent:CreateFontString(nil, "OVERLAY")
		K.SetFont(label, 12, "OUTLINE")
		label:SetPoint("TOPLEFT", anchor, "TOPLEFT", 0, startY)
		label:SetText(header)
		rows[#rows + 1] = label

		local y = startY - 20
		local list = C.Unitframe[listKey] or {}
		local ids = {}
		for id, on in pairs(list) do
			if on then
				ids[#ids + 1] = id
			end
		end
		tsort(ids)

		for _, id in ipairs(ids) do
			local row = CreateFrame("Frame", nil, parent)
			row:SetSize(300, 20)
			row:SetPoint("TOPLEFT", anchor, "TOPLEFT", 8, y)

			local icon = row:CreateTexture(nil, "ARTWORK")
			icon:SetSize(16, 16)
			icon:SetPoint("LEFT")
			icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
			icon:SetTexture(C_Spell and C_Spell.GetSpellTexture and C_Spell.GetSpellTexture(id) or 134400)

			local text = row:CreateFontString(nil, "OVERLAY")
			K.SetFont(text, 12)
			text:SetPoint("LEFT", icon, "RIGHT", 6, 0)
			local name = C_Spell and C_Spell.GetSpellName and C_Spell.GetSpellName(id)
			text:SetText((name and (name .. "  ") or "") .. "|cff888888(" .. id .. ")|r")

			local remove = MakeButton(row, L["Remove"], 70)
			remove:SetPoint("LEFT", row, "LEFT", 210, 0)
			remove:SetScript("OnClick", function()
				K:SetConfig({ "Unitframe", listKey, id }, nil)
				ApplyFilters()
				Refresh()
			end)

			rows[#rows + 1] = row
			y = y - 22
		end

		return y
	end

	Refresh = function()
		ClearRows()
		local y = BuildList(edit, -44, "AuraWhitelist", L["Whitelist"])
		BuildList(edit, y - 16, "AuraBlacklist", L["Blacklist"])
	end

	local function Add(listKey)
		local id = tonumber(edit:GetText())
		if id and id > 0 then
			K:SetConfig({ "Unitframe", listKey, id }, true)
			ApplyFilters()
			edit:SetText("")
			edit:ClearFocus()
			Refresh()
		end
	end

	addWhite:SetScript("OnClick", function()
		Add("AuraWhitelist")
	end)
	addBlack:SetScript("OnClick", function()
		Add("AuraBlacklist")
	end)

	Refresh()
	parent:SetHeight(520)
end
