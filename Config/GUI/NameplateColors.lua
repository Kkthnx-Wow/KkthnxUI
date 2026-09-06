--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Config/GUI/NameplateColors.lua
	Purpose:
		The custom nameplate colour editor. Add an npcID and a colour to paint that
		mob's health bar, for kill-first or focus targets. Drives K.NameplateColors
		through the config, with a swatch to pick the colour and a per-row remove.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

local GUI = K.GUI

local pairs = pairs
local tonumber = tonumber
local tsort = table.sort

local function MakeButton(parent, text, width)
	local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	button:SetSize(width or 90, 22)
	button:SetText(text)
	K.SkinButton(button)
	return button
end

-- Rebuild the lookup and repaint any plate on its next health tick.
local function ApplyColors()
	if K.BuildNameplateColors then
		K.BuildNameplateColors()
	end
end

GUI.CustomPanels = GUI.CustomPanels or {}

function GUI.CustomPanels.NameplateColors(parent)
	local title = parent:CreateFontString(nil, "OVERLAY")
	K.SetFont(title, 14, "OUTLINE")
	title:SetTextColor(K.Colors.accent[1], K.Colors.accent[2], K.Colors.accent[3])
	title:SetPoint("TOPLEFT", 12, -8)
	title:SetText(L["Custom Unit Colors"])

	local help = parent:CreateFontString(nil, "OVERLAY")
	K.SetFont(help, 12)
	help:SetTextColor(K.Colors.muted[1], K.Colors.muted[2], K.Colors.muted[3])
	help:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -6)
	help:SetText(L["Paint a mob's health bar by npcID, for kill-first or focus targets."])

	-- The colour being staged for the next Add.
	local pending = { 1, 0.2, 0.2 }

	local edit = CreateFrame("EditBox", nil, parent, "InputBoxTemplate")
	edit:SetSize(120, 22)
	edit:SetPoint("TOPLEFT", help, "BOTTOMLEFT", 6, -12)
	edit:SetAutoFocus(false)
	edit:SetNumeric(true)
	K.SkinEditBox(edit)

	-- Colour swatch that opens the picker and stores the chosen colour.
	local swatch = CreateFrame("Button", nil, parent)
	swatch:SetSize(22, 22)
	swatch:SetPoint("LEFT", edit, "RIGHT", 8, 0)
	K.CreateBorder(swatch)
	local swatchTex = swatch:CreateTexture(nil, "ARTWORK")
	swatchTex:SetAllPoints()
	swatchTex:SetColorTexture(pending[1], pending[2], pending[3])
	swatch:SetScript("OnClick", function()
		local function apply()
			local r, g, b = ColorPickerFrame:GetColorRGB()
			pending[1], pending[2], pending[3] = r, g, b
			swatchTex:SetColorTexture(r, g, b)
		end
		local info = {
			r = pending[1], g = pending[2], b = pending[3], hasOpacity = false,
			swatchFunc = apply,
			cancelFunc = apply,
		}
		if ColorPickerFrame.SetupColorPickerAndShow then
			ColorPickerFrame:SetupColorPickerAndShow(info)
		end
	end)

	local add = MakeButton(parent, L["Add"], 90)
	add:SetPoint("LEFT", swatch, "RIGHT", 8, 0)

	local rows = {}
	local function ClearRows()
		for _, row in ipairs(rows) do
			row:Hide()
		end
		wipe(rows)
	end

	local Refresh

	Refresh = function()
		ClearRows()
		local list = C.Nameplate.CustomColors or {}
		local ids = {}
		for id in pairs(list) do
			ids[#ids + 1] = id
		end
		tsort(ids)

		local y = -48
		for _, id in ipairs(ids) do
			local color = list[id]
			local row = CreateFrame("Frame", nil, parent)
			row:SetSize(300, 20)
			row:SetPoint("TOPLEFT", edit, "TOPLEFT", 0, y)

			local box = row:CreateTexture(nil, "ARTWORK")
			box:SetSize(16, 16)
			box:SetPoint("LEFT")
			box:SetColorTexture(color[1], color[2], color[3])

			local text = row:CreateFontString(nil, "OVERLAY")
			K.SetFont(text, 12)
			text:SetPoint("LEFT", box, "RIGHT", 8, 0)
			text:SetText(L["npcID"] .. " " .. id)

			local remove = MakeButton(row, L["Remove"], 70)
			remove:SetPoint("LEFT", row, "LEFT", 210, 0)
			remove:SetScript("OnClick", function()
				K:SetConfig({ "Nameplate", "CustomColors", id }, nil)
				ApplyColors()
				Refresh()
			end)

			rows[#rows + 1] = row
			y = y - 22
		end
	end

	add:SetScript("OnClick", function()
		local id = tonumber(edit:GetText())
		if id and id > 0 then
			K:SetConfig({ "Nameplate", "CustomColors", id }, { pending[1], pending[2], pending[3] })
			ApplyColors()
			edit:SetText("")
			edit:ClearFocus()
			Refresh()
		end
	end)

	Refresh()
	parent:SetHeight(520)
end
