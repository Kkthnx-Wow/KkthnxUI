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

	local y = -8
	for _, entry in ipairs(K.GetMoverList()) do
		local row = CreateFrame("Frame", nil, parent)
		row:SetSize(460, 26)
		row:SetPoint("TOPLEFT", listHeader, "BOTTOMLEFT", 0, y)
		y = y - 30
		K.CreateBackground(row, 0.15, 0.15, 0.15, 0.5)
		K.CreateBorder(row)

		local label = row:CreateFontString(nil, "OVERLAY")
		K.SetFont(label, 12)
		label:SetPoint("LEFT", 8, 0)
		label:SetText(entry.label)

		local reset = MakeButton(row, L["Reset"], 80)
		reset:SetPoint("RIGHT", -6, 0)
		reset:SetScript("OnClick", function()
			K.ResetMover(entry.key)
		end)

		local locate = MakeButton(row, L["Locate"], 80)
		locate:SetPoint("RIGHT", reset, "LEFT", -6, 0)
		locate:SetScript("OnClick", function()
			if not K.MoversEnabled() then
				K.ToggleMovers(true)
			end
			K.FlashMover(entry.key)
		end)
	end

	parent:SetHeight(200 - y)
end
