--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Config/GUI/Movers.lua
	Purpose:
		The Movers panel. Toggle move mode, reset everything, or find and reset a
		single mover from a scrollable list. Registered as a custom GUI panel.
-----------------------------------------------------------------------------]]

local K, L = KkthnxUI[1], KkthnxUI[3]

local GUI = K.GUI

local function MakeButton(parent, text, width)
	local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	button:SetSize(width or 90, 22)
	button:SetText(text)
	K.SkinButton(button)
	return button
end

GUI.CustomPanels = GUI.CustomPanels or {}

function GUI.CustomPanels.Movers(parent)
	local title = parent:CreateFontString(nil, "OVERLAY")
	K.SetFont(title, 14, "OUTLINE")
	title:SetTextColor(K.Colors.accent[1], K.Colors.accent[2], K.Colors.accent[3])
	title:SetPoint("TOPLEFT", 12, -8)
	title:SetText(L["Movers"])

	local toggle = MakeButton(parent, L["Toggle Move Mode"], 160)
	toggle:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -10)
	toggle:SetScript("OnClick", function()
		K.ToggleMovers()
	end)

	local resetAll = MakeButton(parent, L["Reset All"], 120)
	resetAll:SetPoint("LEFT", toggle, "RIGHT", 8, 0)
	resetAll:SetScript("OnClick", function()
		K.ResetMovers()
	end)

	local listHeader = parent:CreateFontString(nil, "OVERLAY")
	K.SetFont(listHeader, 12, "OUTLINE")
	listHeader:SetTextColor(K.Colors.accent[1], K.Colors.accent[2], K.Colors.accent[3])
	listHeader:SetPoint("TOPLEFT", toggle, "BOTTOMLEFT", 0, -16)
	listHeader:SetText(L["Individual Frames"])

	-- Rows are rebuilt every time the panel is shown. The list used to be a single
	-- snapshot taken when the config window was first opened, so any mover created
	-- after that never appeared here. Rows are pooled so reopening costs nothing.
	local rows = {}

	local function AcquireRow(index)
		local row = rows[index]
		if row then
			row:Show()
			return row
		end

		row = CreateFrame("Frame", nil, parent)
		row:SetSize(460, 26)
		K.CreateBackground(row, 0.15, 0.15, 0.15, 0.5)
		K.CreateBorder(row)

		row.Label = row:CreateFontString(nil, "OVERLAY")
		K.SetFont(row.Label, 12)
		row.Label:SetPoint("LEFT", 8, 0)

		row.Reset = MakeButton(row, L["Reset"], 80)
		row.Reset:SetPoint("RIGHT", -6, 0)
		row.Reset:SetScript("OnClick", function()
			K.ResetMover(row.moverKey)
		end)

		row.Locate = MakeButton(row, L["Locate"], 80)
		row.Locate:SetPoint("RIGHT", row.Reset, "LEFT", -6, 0)
		row.Locate:SetScript("OnClick", function()
			if not K.MoversEnabled() then
				K.ToggleMovers(true)
			end
			K.FlashMover(row.moverKey)
		end)

		rows[index] = row
		return row
	end

	local function Populate()
		local list = K.GetMoverList()
		local y = -8
		for index, entry in ipairs(list) do
			local row = AcquireRow(index)
			row:ClearAllPoints()
			row:SetPoint("TOPLEFT", listHeader, "BOTTOMLEFT", 0, y)
			row.moverKey = entry.key
			row.Label:SetText(entry.label)
			y = y - 30
		end
		for index = #list + 1, #rows do
			rows[index]:Hide()
		end
		parent:SetHeight(200 - y)
	end

	parent:HookScript("OnShow", Populate)
	Populate()
end
