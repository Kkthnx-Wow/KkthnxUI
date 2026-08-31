--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Config/GUI/Widgets.lua
	Purpose:
		The GUI widget toolkit. Every control (check, slider, dropdown, colour,
		button, header) is built from a declarative control table and wired to a
		config path through K:SetConfig. Shared on K.GUI so the window and schema
		files can build panels without touching frame internals.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

-- Shared theme accent, pulled from the palette so a palette change flows through
-- every widget instead of leaving stray hardcoded colours behind.
local ACCENT = K.Colors.accent

local GUI = {}
K.GUI = GUI

-- ---------------------------------------------------------------------------
-- Config path access
-- ---------------------------------------------------------------------------

function GUI.GetValue(path)
	local node = C
	for i = 1, #path do
		node = node[path[i]]
		if node == nil then
			return nil
		end
	end
	return node
end

-- Apply a changed value: persist it, run any live callback, flag reload need,
-- then refresh any controls whose enabled state depends on other settings.
function GUI.ApplyChange(control, value)
	K:SetConfig(control.path, value)
	if control.apply then
		control.apply(value)
	end
	if control.reload and GUI.MarkReload then
		GUI.MarkReload()
	end
	GUI.RefreshDependencies()
end

-- ---------------------------------------------------------------------------
-- Dependency (grey-out) system
-- ---------------------------------------------------------------------------
-- A control may declare `dependsOn = { path... }`. When that config value is
-- falsy the widget greys out and stops responding. Each builder attaches a
-- widget.KKUI_SetEnabled(enabled) so one refresh pass can update them all.

GUI.dependents = {}

function GUI.RegisterDependent(widget, control)
	if control.dependsOn then
		GUI.dependents[#GUI.dependents + 1] = { widget = widget, path = control.dependsOn }
	end
end

function GUI.RefreshDependencies()
	for _, entry in ipairs(GUI.dependents) do
		if entry.widget.KKUI_SetEnabled then
			entry.widget.KKUI_SetEnabled(GUI.GetValue(entry.path) and true or false)
		end
	end
end

-- ---------------------------------------------------------------------------
-- Shared look helpers
-- ---------------------------------------------------------------------------

local function SkinButton(button)
	K.CreateBackground(button, 0.2, 0.2, 0.2, 0.7)
	K.CreateBorder(button)
	local fs = button:GetFontString()
	if fs then
		fs:SetTextColor(1, 1, 1)
	end
end

-- ---------------------------------------------------------------------------
-- Header / description (non-interactive)
-- ---------------------------------------------------------------------------

function GUI.CreateHeader(parent, control)
	local frame = CreateFrame("Frame", nil, parent)
	frame:SetSize(440, 24)

	local fs = frame:CreateFontString(nil, "OVERLAY")
	K.SetFont(fs, 14, "OUTLINE")
	fs:SetTextColor(ACCENT[1], ACCENT[2], ACCENT[3])
	fs:SetPoint("LEFT", frame, "LEFT", 0, 0)
	fs:SetText(control.label)

	-- A soft rule trailing the label so each section reads as its own block.
	local rule = frame:CreateTexture(nil, "ARTWORK")
	rule:SetColorTexture(ACCENT[1], ACCENT[2], ACCENT[3], 0.22)
	rule:SetHeight(1)
	rule:SetPoint("LEFT", fs, "RIGHT", 8, 0)
	rule:SetPoint("RIGHT", frame, "RIGHT", -6, 0)

	frame.height = 28
	return frame
end

function GUI.CreateDescription(parent, control)
	local fs = parent:CreateFontString(nil, "OVERLAY")
	K.SetFont(fs, 11)
	fs:SetTextColor(0.7, 0.7, 0.7)
	fs:SetWidth(440)
	fs:SetJustifyH("LEFT")
	fs:SetSpacing(3)
	fs:SetText(control.label)
	fs.height = (fs:GetStringHeight() or 12) + 8
	return fs
end

-- ---------------------------------------------------------------------------
-- Checkbox
-- ---------------------------------------------------------------------------

function GUI.CreateCheck(parent, control)
	local check = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
	K.SkinCheckBox(check)

	check.Text:ClearAllPoints()
	check.Text:SetPoint("LEFT", check, "RIGHT", 8, 0)
	check.Text:SetText(control.label)
	K.SetFont(check.Text, 12)
	check.Text:SetTextColor(1, 1, 1)

	check:SetChecked(GUI.GetValue(control.path) and true or false)
	check:SetScript("OnClick", function(self)
		GUI.ApplyChange(control, self:GetChecked() and true or false)
	end)
	if control.tooltip then
		check:SetScript("OnEnter", function(self)
			GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
			GameTooltip:SetText(control.label, 1, 1, 1)
			GameTooltip:AddLine(control.tooltip, 0.8, 0.8, 0.8, true)
			GameTooltip:Show()
		end)
		check:SetScript("OnLeave", GameTooltip_Hide)
	end

	check.KKUI_SetEnabled = function(enabled)
		check:SetEnabled(enabled)
		check.Text:SetTextColor(enabled and 1 or 0.4, enabled and 1 or 0.4, enabled and 1 or 0.4)
	end
	GUI.RegisterDependent(check, control)

	check.height = 30
	return check
end

-- ---------------------------------------------------------------------------
-- Slider
-- ---------------------------------------------------------------------------

function GUI.CreateSlider(parent, control)
	local holder = CreateFrame("Frame", nil, parent)
	holder:SetSize(260, 50)

	local label = holder:CreateFontString(nil, "OVERLAY")
	K.SetFont(label, 12)
	label:SetPoint("TOPLEFT")
	label:SetText(control.label)

	-- A bare slider, built from scratch, so no Blizzard template art can leak
	-- through. Track is a sibling frame one level below the slider so the thumb
	-- (a texture on the slider) still draws above it.
	local slider = CreateFrame("Slider", nil, holder)
	slider:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -12)
	slider:SetPoint("RIGHT", holder, "RIGHT", 0, 0)
	slider:SetHeight(16)
	slider:SetOrientation("HORIZONTAL")
	slider:SetMinMaxValues(control.min, control.max)
	slider:SetValueStep(control.step)
	slider:SetObeyStepOnDrag(true)
	slider:SetHitRectInsets(0, 0, -8, -8)

	local track = CreateFrame("Frame", nil, holder)
	track:SetFrameLevel(math.max(0, slider:GetFrameLevel() - 1))
	track:SetPoint("LEFT", slider, "LEFT", 0, 0)
	track:SetPoint("RIGHT", slider, "RIGHT", 0, 0)
	track:SetHeight(6)
	K.CreateBackground(track, 0.08, 0.08, 0.08, 0.95)
	K.CreateBorder(track)

	-- A crisp square handle to match our square, bordered UI rather than a soft dot:
	-- a bright fill sitting on a dark backing square that reads as a thin border, and
	-- an accent line down its middle so it looks like a grabbable knob. The backing
	-- is anchored to the thumb so it slides along with it.
	local THUMB = { 0.6, 0.78, 1.0 }
	local THUMB_HOVER = { 0.82, 0.9, 1.0 }

	local thumb = slider:CreateTexture(nil, "OVERLAY")
	thumb:SetColorTexture(THUMB[1], THUMB[2], THUMB[3], 1)
	thumb:SetSize(10, 18)
	slider:SetThumbTexture(thumb)

	local border = slider:CreateTexture(nil, "ARTWORK")
	border:SetColorTexture(0.04, 0.04, 0.04, 1)
	border:SetSize(14, 22)
	border:SetPoint("CENTER", thumb, "CENTER", 0, 0)

	slider:HookScript("OnEnter", function()
		thumb:SetColorTexture(THUMB_HOVER[1], THUMB_HOVER[2], THUMB_HOVER[3], 1)
	end)
	slider:HookScript("OnLeave", function()
		thumb:SetColorTexture(THUMB[1], THUMB[2], THUMB[3], 1)
	end)

	local low = holder:CreateFontString(nil, "OVERLAY")
	K.SetFont(low, 10)
	low:SetTextColor(0.6, 0.6, 0.6)
	low:SetPoint("TOPLEFT", slider, "BOTTOMLEFT", 0, -2)
	low:SetText(control.min)

	local high = holder:CreateFontString(nil, "OVERLAY")
	K.SetFont(high, 10)
	high:SetTextColor(0.6, 0.6, 0.6)
	high:SetPoint("TOPRIGHT", slider, "BOTTOMRIGHT", 0, -2)
	high:SetText(control.max)

	local step = control.step
	local function Round(v)
		return step >= 1 and K.Round(v) or K.Round(v, 2)
	end

	-- Editable value box, top-right. Type a number and press enter to set it.
	local valueBox = CreateFrame("EditBox", nil, holder, "InputBoxTemplate")
	valueBox:SetSize(52, 18)
	valueBox:SetPoint("TOPRIGHT", holder, "TOPRIGHT", -2, 0)
	valueBox:SetAutoFocus(false)
	valueBox:SetJustifyH("CENTER")
	K.SkinEditBox(valueBox)
	valueBox:SetScript("OnEnterPressed", function(self)
		local v = tonumber(self:GetText())
		if v then
			slider:SetValue(K.Clamp(Round(v), control.min, control.max))
		end
		self:ClearFocus()
	end)
	valueBox:SetScript("OnEscapePressed", valueBox.ClearFocus)

	local value = GUI.GetValue(control.path) or control.min
	slider:SetValue(value)
	valueBox:SetText(Round(value))

	slider:SetScript("OnValueChanged", function(_, v)
		v = Round(v)
		if not valueBox:HasFocus() then
			valueBox:SetText(v)
		end
		GUI.ApplyChange(control, v)
	end)

	holder.KKUI_SetEnabled = function(enabled)
		slider:SetEnabled(enabled)
		valueBox:SetEnabled(enabled)
		holder:SetAlpha(enabled and 1 or 0.4)
		label:SetTextColor(enabled and 1 or 0.5, enabled and 1 or 0.5, enabled and 1 or 0.5)
	end
	GUI.RegisterDependent(holder, control)

	holder.KKUI_SetWidth = function(w)
		holder:SetWidth(w)
	end

	holder.height = 60
	return holder
end

-- ---------------------------------------------------------------------------
-- Dropdown (lightweight, no UIDropDownMenu taint)
-- ---------------------------------------------------------------------------

function GUI.CreateDropdown(parent, control)
	local holder = CreateFrame("Frame", nil, parent)
	holder:SetSize(260, 46)

	local label = holder:CreateFontString(nil, "OVERLAY")
	K.SetFont(label, 12)
	label:SetPoint("TOPLEFT")
	label:SetText(control.label)

	local button = CreateFrame("Button", nil, holder)
	button:SetHeight(22)
	button:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -6)
	button:SetPoint("RIGHT", holder, "RIGHT", 0, 0)
	SkinButton(button)

	-- A real chevron from SquareButtonTextures (greyscale, so it tints), instead
	-- of a typed "v". The down-arrow is the up-arrow with its V coords flipped.
	local arrow = button:CreateTexture(nil, "OVERLAY")
	arrow:SetTexture("Interface\\BUTTONS\\SquareButtonTextures")
	arrow:SetTexCoord(0.45312500, 0.64062500, 0.20312500, 0.01562500)
	arrow:SetVertexColor(ACCENT[1], ACCENT[2], ACCENT[3])
	arrow:SetSize(14, 14)
	arrow:SetPoint("RIGHT", -6, 0)

	local text = button:CreateFontString(nil, "OVERLAY")
	K.SetFont(text, 12)
	text:SetPoint("LEFT", 6, 0)
	text:SetPoint("RIGHT", arrow, "LEFT", -4, 0)
	text:SetJustifyH("LEFT")

	local function CurrentText()
		local value = GUI.GetValue(control.path)
		for _, opt in ipairs(control.options) do
			if opt.value == value then
				return opt.text
			end
		end
		return tostring(value)
	end
	text:SetText(CurrentText())

	local menu = CreateFrame("Frame", nil, button)
	menu:SetPoint("TOPLEFT", button, "BOTTOMLEFT", 0, -2)
	menu:SetPoint("TOPRIGHT", button, "BOTTOMRIGHT", 0, -2)
	menu:SetFrameStrata("FULLSCREEN_DIALOG")
	K.CreateBackground(menu, 0.05, 0.05, 0.05, 0.95)
	K.CreateBorder(menu)
	menu:Hide()

	local rowY = -4
	for _, opt in ipairs(control.options) do
		local row = CreateFrame("Button", nil, menu)
		row:SetHeight(20)
		row:SetPoint("TOPLEFT", menu, "TOPLEFT", 4, rowY)
		row:SetPoint("TOPRIGHT", menu, "TOPRIGHT", -4, rowY)
		rowY = rowY - 20
		local rowText = row:CreateFontString(nil, "OVERLAY")
		K.SetFont(rowText, 12)
		rowText:SetPoint("LEFT", 6, 0)
		rowText:SetText(opt.text)
		row:SetHighlightTexture(C.Media.Textures.White8x8)
		row:GetHighlightTexture():SetVertexColor(ACCENT[1], ACCENT[2], ACCENT[3], 0.3)
		row:SetScript("OnClick", function()
			GUI.ApplyChange(control, opt.value)
			text:SetText(CurrentText())
			menu:Hide()
		end)
	end
	menu:SetHeight(-rowY + 4)

	button:SetScript("OnClick", function()
		menu:SetShown(not menu:IsShown())
	end)

	holder.KKUI_SetEnabled = function(enabled)
		button:SetEnabled(enabled)
		holder:SetAlpha(enabled and 1 or 0.4)
		label:SetTextColor(enabled and 1 or 0.5, enabled and 1 or 0.5, enabled and 1 or 0.5)
		if not enabled then
			menu:Hide()
		end
	end
	GUI.RegisterDependent(holder, control)

	holder.KKUI_SetWidth = function(w)
		holder:SetWidth(w)
	end

	holder.height = 50
	return holder
end

-- ---------------------------------------------------------------------------
-- Colour picker
-- ---------------------------------------------------------------------------

function GUI.CreateColor(parent, control)
	local holder = CreateFrame("Frame", nil, parent)
	holder:SetSize(260, 26)

	local swatch = CreateFrame("Button", nil, holder)
	swatch:SetSize(18, 18)
	swatch:SetPoint("LEFT")
	K.CreateBorder(swatch)
	local tex = swatch:CreateTexture(nil, "ARTWORK")
	tex:SetAllPoints()
	tex:SetColorTexture(1, 1, 1)

	local label = holder:CreateFontString(nil, "OVERLAY")
	K.SetFont(label, 12)
	label:SetPoint("LEFT", swatch, "RIGHT", 8, 0)
	label:SetText(control.label)

	local function Refresh()
		local c = GUI.GetValue(control.path) or { 1, 1, 1, 1 }
		tex:SetColorTexture(c[1], c[2], c[3], c[4] or 1)
	end
	Refresh()

	swatch:SetScript("OnClick", function()
		local c = GUI.GetValue(control.path) or { 1, 1, 1, 1 }
		-- Modern ColorPickerFrame: alpha comes from GetColorAlpha (1 = opaque),
		-- and info.opacity is that same alpha. The old OpacitySliderFrame is gone.
		local function apply()
			local r, g, b = ColorPickerFrame:GetColorRGB()
			local a = ColorPickerFrame.GetColorAlpha and ColorPickerFrame:GetColorAlpha() or (c[4] or 1)
			GUI.ApplyChange(control, { r, g, b, a })
			Refresh()
		end
		local info = {
			r = c[1], g = c[2], b = c[3], opacity = c[4] or 1, hasOpacity = true,
			swatchFunc = apply, opacityFunc = apply,
			cancelFunc = function()
				GUI.ApplyChange(control, c)
				Refresh()
			end,
		}
		if ColorPickerFrame.SetupColorPickerAndShow then
			ColorPickerFrame:SetupColorPickerAndShow(info)
		else
			ColorPickerFrame:Show()
		end
	end)

	holder.height = 30
	return holder
end

-- ---------------------------------------------------------------------------
-- Action button (runs a callback)
-- ---------------------------------------------------------------------------

function GUI.CreateButton(parent, control)
	local button = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
	button:SetSize(control.width or 150, 24)
	button:SetText(control.label)
	K.SkinButton(button)
	button:SetScript("OnClick", function()
		if control.onClick then
			control.onClick()
		end
	end)
	button.height = 30
	return button
end

-- ---------------------------------------------------------------------------
-- Text entry (free-form string, e.g. a comma separated keyword list)
-- ---------------------------------------------------------------------------

function GUI.CreateEditBox(parent, control)
	local holder = CreateFrame("Frame", nil, parent)
	holder:SetSize(260, 44)

	local label = holder:CreateFontString(nil, "OVERLAY")
	K.SetFont(label, 12)
	label:SetPoint("TOPLEFT")
	label:SetText(control.label)

	local edit = CreateFrame("EditBox", nil, holder)
	edit:SetSize(control.width or 220, 22)
	edit:SetPoint("TOPLEFT", label, "BOTTOMLEFT", 0, -4)
	edit:SetAutoFocus(false)
	edit:SetFontObject("ChatFontNormal")
	edit:SetTextInsets(6, 6, 0, 0)
	K.SkinEditBox(edit)
	edit:SetText(GUI.GetValue(control.path) or "")

	local function Commit()
		GUI.ApplyChange(control, edit:GetText() or "")
		edit:ClearFocus()
	end
	edit:SetScript("OnEnterPressed", Commit)
	edit:SetScript("OnEditFocusLost", Commit)
	edit:SetScript("OnEscapePressed", function()
		edit:SetText(GUI.GetValue(control.path) or "")
		edit:ClearFocus()
	end)

	holder.KKUI_SetEnabled = function(enabled)
		edit:EnableMouse(enabled)
		edit:SetAlpha(enabled and 1 or 0.4)
		label:SetAlpha(enabled and 1 or 0.4)
	end
	GUI.RegisterDependent(holder, control)

	holder.height = 48
	return holder
end

-- Dispatch table used by the window when laying out a panel.
GUI.Builders = {
	header = GUI.CreateHeader,
	description = GUI.CreateDescription,
	check = GUI.CreateCheck,
	slider = GUI.CreateSlider,
	dropdown = GUI.CreateDropdown,
	color = GUI.CreateColor,
	button = GUI.CreateButton,
	editbox = GUI.CreateEditBox,
}

-- Placeholder so ApplyChange can call it before the window defines it.
GUI.MarkReload = GUI.MarkReload or function() end
