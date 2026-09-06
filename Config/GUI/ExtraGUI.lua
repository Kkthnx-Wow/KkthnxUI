--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Config/GUI/ExtraGUI.lua
	Purpose:
		Flyout sub-panels. A category can offer
		an "extra" button that opens a panel docked to the right of the main
		window with its own scrollable controls. Only one extra shows at a time,
		and all close with the main window. This keeps busy pages (per-bar
		settings) tidy behind a single button.
-----------------------------------------------------------------------------]]

local K = KkthnxUI[1]

local GUI = K.GUI

local extras = {}

function GUI.HideExtras(except)
	for _, frame in pairs(extras) do
		if frame ~= except then
			frame:Hide()
		end
	end
end

-- Create (once) a flyout panel and populate it via build(scrollChild).
function GUI.CreateExtraGUI(name, title, build)
	if extras[name] then
		return extras[name]
	end

	local frame = CreateFrame("Frame", "KKUI_Extra_" .. name, GUI.window)
	frame:SetWidth(320)
	-- Match the main window's height so the flyout lines up top and bottom.
	frame:SetPoint("TOPLEFT", GUI.window, "TOPRIGHT", 8, 0)
	frame:SetPoint("BOTTOMLEFT", GUI.window, "BOTTOMRIGHT", 8, 0)
	frame:SetFrameStrata("HIGH")
	K.CreateBackground(frame, 0.05, 0.05, 0.05, 0.96)
	K.CreateBorder(frame)

	local header = frame:CreateFontString(nil, "OVERLAY")
	K.SetFont(header, 15, "OUTLINE")
	header:SetTextColor(K.Colors.accent[1], K.Colors.accent[2], K.Colors.accent[3])
	header:SetPoint("TOPLEFT", 16, -16)
	header:SetText(title)

	local close = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
	close:SetPoint("TOPRIGHT", -6, -6)
	K.SkinCloseButton(close)

	local scroll = CreateFrame("ScrollFrame", nil, frame, "UIPanelScrollFrameTemplate")
	scroll:SetPoint("TOPLEFT", 6, -44)
	scroll:SetPoint("BOTTOMRIGHT", -28, 8)
	K.SkinScrollBar(scroll.ScrollBar)

	local child = CreateFrame("Frame", nil, scroll)
	child:SetSize(1, 1)
	scroll:SetScrollChild(child)
	child:SetWidth(280)

	if build then
		build(child)
	end

	frame:Hide()
	extras[name] = frame
	return frame
end

-- Widget: a button that toggles an extra flyout panel.
function GUI.CreateExtraButton(parent, control)
	local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	button:SetSize(control.width or 160, 24)
	button:SetText(control.label)
	K.SkinButton(button)
	button:SetScript("OnClick", function()
		local extra = GUI.CreateExtraGUI(control.name, control.title, control.build)
		if extra:IsShown() then
			extra:Hide()
		else
			GUI.HideExtras(extra)
			extra:Show()
		end
	end)
	GUI.AttachTooltip(button, control)
	button.height = 30
	return button
end

GUI.Builders.extra = GUI.CreateExtraButton
