local K, C = KkthnxUI[1], KkthnxUI[2]

-- Sourced: Tukui (Tukz & Hydra)
-- Edited: KkthnxUI (Kkthnx)

local floor = floor
local match = string.match
local pairs = pairs
local sort = table.sort
local tinsert = table.insert
local tremove = table.remove
local type = type
local unpack = unpack

local CreateFrame = CreateFrame
local GameTooltip = GameTooltip
local UIParent = UIParent
local StaticPopupDialogs = StaticPopupDialogs
local YES = YES
local NO = NO
local INFO = INFO
local OKAY = OKAY
local SlashCmdList = SlashCmdList

local BGColor = { 0.2, 0.2, 0.2 }
local BrightColor = { 0.35, 0.35, 0.35 }
local R, G, B = K.r, K.g, K.b

local HeaderText = string.format("%s %s", K.Title .. K.SystemColor, SETTINGS .. "|r")

local WindowWidth = 620
-- local WindowHeight = 360

local Spacing = 7
local LabelSpacing = 6

local HeaderWidth = WindowWidth - (Spacing * 2)
local HeaderHeight = 22

local ButtonListWidth = 130

local MenuButtonWidth = ButtonListWidth - (Spacing * 2)
local MenuButtonHeight = 20

local WidgetListWidth = (WindowWidth - ButtonListWidth) - (Spacing * 3) + 1
local WidgetHeight = 20 -- All widgets are the same height
local WidgetHighlightAlpha = 0.25

local SwitchWidth = 46
local EditBoxWidth = 134
local ButtonWidth = 138
local SliderWidth = 84
local SliderEditBoxWidth = 46
local DropdownWidth = 180
local ListItemsToShow = 8
local ColorButtonWidth = 110

local ColorPickerFrameCancel = K.Noop
local LastActiveDropdown
local LastActiveWindow
local MySelectedProfile = K.Realm .. "-" .. K.Name

local CreditLines = {
	{ type = "header", text = "PATREONS", color = "C0C0C0" },
	{ type = "header", text = "" },
	{ type = "header", text = "Tier 1" },
	{ type = "header", text = "Tier 2" },
	{ type = "header", text = "Tier 3" },
	{ type = "name", text = "Shovil", class = "WARRIOR" },
	{ type = "header", text = "Tier 4" },
	{ type = "header", text = "" },
	{ type = "header", text = "CREDITS" },
	{ type = "header", text = "" },
	{ type = "name", text = "Aftermathh" },
	{ type = "name", text = "Alteredcross", class = "ROGUE" },
	{ type = "name", text = "Alza" },
	{ type = "name", text = "Azilroka", class = "SHAMAN" },
	{ type = "name", text = "Benik", color = "00c0fa" },
	{ type = "name", text = "Blazeflack" },
	{ type = "name", text = "Caellian" },
	{ type = "name", text = "Caith" },
	{ type = "name", text = "Cassamarra", class = "HUNTER" },
	{ type = "name", text = "Darth Predator" },
	{ type = "name", text = "Elv", addOn = "(|cff1784d1ElvUI|r)" },
	{ type = "name", text = K.GetClassIcon("PRIEST") .. "|cffe31c73Faffi|r|cfffc4796GS|r", class = "PRIEST", color = "e31c73" },
	{ type = "name", text = K.GetClassIcon("DRUID") .. "Goldpaw", class = "DRUID", addOn = "(|c00000002|r|cff7284abA|r|cff6a7a9ez|r|cff617092e|r|cff596785r|r|cff505d78i|r|cff48536bt|r|cff3f495fe|r|cffffffffUI|r)" },
	{ type = "name", text = "Haleth" },
	{ type = "name", text = "Haste" },
	{ type = "name", text = "Hungtar" },
	{ type = "name", text = "Hydra", addOn = "(|cFFFFC44DvUI|r)" },
	{ type = "name", text = "Ishtara" },
	{ type = "name", text = "KkthnxUI Community" },
	{ type = "name", text = "LightSpark" },
	{ type = "name", text = "Magicnachos", class = "PRIEST" },
	{ type = "name", text = "Merathilis", class = "DRUID" },
	{ type = "name", text = "Nightcracker" },
	{ type = "name", text = "P3lim" },
	{ type = "name", text = "Palooza", class = "PRIEST" },
	{ type = "name", text = "Rav99", class = "DEMONHUNTER" },
	{ type = "name", text = "Roth" },
	{ type = "name", text = "Shestak", addOn = "ShestakUI" },
	{ type = "name", text = "Simpy" },
	{ type = "name", text = "siweia", addOn = "NDui" },
}

local GUI = CreateFrame("Frame", "KKUI_GUI", UIParent)
GUI.Windows = {}
GUI.Buttons = {}
GUI.Queue = {}
GUI.Widgets = {}

-- Create a KkthnxUI popup for profiles
StaticPopupDialogs["KKUI_SWITCH_PROFILE"] = {
	text = "Are you sure you want to switch your profile? If you accept, this current profile will be erased and replaced the character you selected!",
	button1 = YES,
	button2 = NO,
	OnAccept = function()
		local SelectedServer, SelectedNickname = string.split("-", MySelectedProfile)

		KkthnxUIDB.Variables[K.Realm][K.Name] = KkthnxUIDB.Variables[SelectedServer][SelectedNickname]
		KkthnxUIDB.Settings[K.Realm][K.Name] = KkthnxUIDB.Settings[SelectedServer][SelectedNickname]

		_G.ReloadUI()
	end,
}

local SetValue = function(group, option, value)
	-- Check if C[group][option] is a table, if it is set C[group][option].Value = value, otherwise set C[group][option] = value
	if type(C[group][option]) == "table" then
		C[group][option].Value = value
	else
		C[group][option] = value
	end

	-- Recursively initialize the KkthnxUIDB table
	KkthnxUIDB.Settings = KkthnxUIDB.Settings or {}
	KkthnxUIDB.Settings[K.Realm] = KkthnxUIDB.Settings[K.Realm] or {}
	KkthnxUIDB.Settings[K.Realm][K.Name] = KkthnxUIDB.Settings[K.Realm][K.Name] or {}
	local Settings = KkthnxUIDB.Settings[K.Realm][K.Name]

	-- Initialize the group table
	Settings[group] = Settings[group] or {}

	-- Set the value of the option in the group
	Settings[group][option] = value
end

local TrimHex = function(s)
	return string.match(s, "|c%x%x%x%x%x%x%x%x(.-)|r") or s
end

local AnchorOnEnter = function(self)
	if not self.Tooltip or not string.match(self.Tooltip, "%S") then
		return
	end
	if GameTooltip:IsForbidden() then
		return
	end

	local info = "|nMost options require a full UI reload|nYou can do this by clicking the |CFF00CC4CApply|r button|n|n"
	local info_color = { 163 / 255, 211 / 255, 255 / 255 }

	GameTooltip:ClearLines()
	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint("TOPLEFT", "KKUI_GUI", "TOPRIGHT", -3, -5)
	GameTooltip:AddLine(INFO)
	GameTooltip:AddLine(info, unpack(info_color))
	GameTooltip:AddLine(self.Tooltip, nil, nil, nil, true)
	GameTooltip:Show()
end

local AnchorOnLeave = function()
	if GameTooltip:IsForbidden() then
		return
	end

	GameTooltip:Hide()
end

local function GetOrderedIndex(t)
	local OrderedIndex = {}

	for key in pairs(t) do
		OrderedIndex[#OrderedIndex + 1] = key
	end

	table.sort(OrderedIndex, function(a, b)
		return TrimHex(a) < TrimHex(b)
	end)

	return OrderedIndex
end

local function OrderedNext(t, state)
	local OrderedIndex = GetOrderedIndex(t)
	local Key
	local NextIndex

	if state == nil then
		NextIndex = 1
	else
		for i = 1, #OrderedIndex do
			if OrderedIndex[i] == state then
				NextIndex = i + 1
				break
			end
		end
	end

	Key = OrderedIndex[NextIndex]

	if Key then
		-- print("Key: ", Key)
		-- print("Value: ", t[Key])
		return Key, t[Key]
	else
		-- print("Iteration ended")
	end
end

-- PairsByKeys function to iterate through the elements of a table in a specific order
local function PairsByKeys(t)
	-- Returns the iterator function and its initial state, so that it can be used with the for loop
	return OrderedNext, t, nil
end

local Reverse = function(value)
	if value == true then
		return false
	else
		return true
	end
end

-- Sections
-- CreateSection function to create a section of the user interface
local function CreateSection(self, text, icon, fontObject)
	-- Create the main frame
	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:SetSize(WidgetListWidth - (Spacing * 2), WidgetHeight)
	Anchor.IsSection = true

	-- Create the child frame
	local Section = CreateFrame("Frame", nil, Anchor)
	Section:SetPoint("TOPLEFT", Anchor, 0, 0)
	Section:SetPoint("BOTTOMRIGHT", Anchor, 0, 0)
	Section:CreateBorder()

	-- Create the label
	Section.Label = Section:CreateFontString(nil, "OVERLAY")
	Section.Label:SetPoint("CENTER", Section, LabelSpacing, 0)
	Section.Label:SetWidth(WidgetListWidth - (Spacing * 4))
	Section.Label:SetFontObject(fontObject or K.UIFont)
	Section.Label:SetJustifyH("CENTER")
	if icon then
		Section.Icon = Section:CreateTexture(nil, "ARTWORK")
		Section.Icon:SetSize(16, 16)
		Section.Icon:SetPoint("RIGHT", Section.Label, "LEFT", -2, 0)
		Section.Icon:SetTexture(icon)
		Section.Label:SetPoint("LEFT", Section, "LEFT", 20, 0)
	else
		Section.Label:SetPoint("CENTER", Section, 0, 0)
	end
	Section.Label:SetText("|CFFFFCC66" .. text .. "|r")

	-- Insert the created frame into the self.Widgets table
	table.insert(self.Widgets, Anchor)

	return Section
end

GUI.Widgets.CreateSection = CreateSection

-- Buttons
local ButtonOnEnter = function(self)
	self.Highlight:SetAlpha(WidgetHighlightAlpha)
end

local ButtonOnLeave = function(self)
	self.Highlight:SetAlpha(0)
end

local ButtonOnMouseDown = function(self)
	self.KKUI_Background:SetVertexColor(BGColor[1], BGColor[2], BGColor[3])
end

local ButtonOnMouseUp = function(self)
	self.KKUI_Background:SetVertexColor(C["Media"].Backdrops.ColorBackdrop[1], C["Media"].Backdrops.ColorBackdrop[2], C["Media"].Backdrops.ColorBackdrop[3], C["Media"].Backdrops.ColorBackdrop[4])
end

local CreateButton = function(self, midtext, text, tooltip, func)
	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:SetSize(WidgetListWidth - (Spacing * 2), WidgetHeight)
	Anchor:SetScript("OnEnter", AnchorOnEnter)
	Anchor:SetScript("OnLeave", AnchorOnLeave)
	Anchor.Tooltip = tooltip

	local Button = CreateFrame("Frame", nil, Anchor)
	Button:SetSize(ButtonWidth, WidgetHeight)
	Button:SetPoint("LEFT", Anchor, 0, 0)
	Button:CreateBorder()
	Button:SetScript("OnMouseDown", ButtonOnMouseDown)
	Button:SetScript("OnMouseUp", ButtonOnMouseUp)
	Button:SetScript("OnEnter", ButtonOnEnter)
	Button:SetScript("OnLeave", ButtonOnLeave)
	Button:HookScript("OnMouseUp", func)

	Button.Highlight = Button:CreateTexture(nil, "OVERLAY")
	Button.Highlight:SetAllPoints()
	Button.Highlight:SetTexture(K.GetTexture(C["General"].Texture))
	Button.Highlight:SetVertexColor(123 / 255, 132 / 255, 137 / 255)
	Button.Highlight:SetAlpha(0)

	Button.Middle = Button:CreateFontString(nil, "OVERLAY")
	Button.Middle:SetPoint("CENTER", Button, 0, 0)
	Button.Middle:SetWidth(WidgetListWidth - (Spacing * 4))
	Button.Middle:SetFontObject(K.UIFont)
	Button.Middle:SetJustifyH("CENTER")
	Button.Middle:SetText(midtext)

	Button.Label = Button:CreateFontString(nil, "OVERLAY")
	Button.Label:SetPoint("LEFT", Button, "RIGHT", Spacing, 0)
	Button.Label:SetWidth(WidgetListWidth - ButtonWidth - (Spacing * 4))
	Button.Label:SetJustifyH("LEFT")
	Button.Label:SetFontObject(K.UIFont)
	Button.Label:SetText(text)

	tinsert(self.Widgets, Anchor)

	return Button
end

GUI.Widgets.CreateButton = CreateButton

-- Switches
local SwitchOnMouseUp = function(self, button)
	if self.Movement:IsPlaying() then
		return
	end

	self.Thumb:ClearAllPoints()

	if button == "RightButton" then
		self.Value = Reverse(K.Defaults[self.Group][self.Option])
	end

	if self.Value then
		self.Thumb:SetPoint("RIGHT", self, 0, 0)
		self.Label:SetTextColor(123 / 255, 132 / 255, 137 / 255)
		self.Movement:SetOffset(-26, 0)
		self.Value = false
	else
		self.Thumb:SetPoint("LEFT", self, 0, 0)
		self.Label:SetTextColor(1, 1, 1)
		self.Movement:SetOffset(26, 0)
		self.Value = true
	end

	self.Movement:Play()
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)

	SetValue(self.Group, self.Option, self.Value)

	if self.Hook then
		self.Hook(self.Value, self.Group)
	end
end

local SwitchOnEnter = function(self)
	self.Highlight:SetAlpha(WidgetHighlightAlpha)
end

local SwitchOnLeave = function(self)
	self.Highlight:SetAlpha(0)
end

local CreateSwitch = function(self, group, option, text, tooltip, hook)
	-- print("group:", group, "option:", option)
	local Value = C[group][option]

	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:SetSize(WidgetListWidth - SwitchWidth - Spacing, WidgetHeight)
	Anchor:SetScript("OnEnter", AnchorOnEnter)
	Anchor:SetScript("OnLeave", AnchorOnLeave)
	Anchor.Tooltip = tooltip

	local Switch = CreateFrame("Frame", nil, Anchor)
	Switch:SetPoint("LEFT", Anchor, 0, 0)
	Switch:SetSize(SwitchWidth, WidgetHeight)
	Switch:CreateBorder()
	Switch:SetScript("OnMouseUp", SwitchOnMouseUp)
	Switch:SetScript("OnEnter", SwitchOnEnter)
	Switch:SetScript("OnLeave", SwitchOnLeave)
	Switch.Value = Value
	Switch.Hook = hook
	Switch.Group = group
	Switch.Option = option

	Switch.Highlight = Switch:CreateTexture(nil, "OVERLAY")
	Switch.Highlight:SetAllPoints()
	Switch.Highlight:SetTexture(K.GetTexture(C["General"].Texture))
	Switch.Highlight:SetVertexColor(123 / 255, 132 / 255, 137 / 255)
	Switch.Highlight:SetAlpha(0)

	Switch.Thumb = CreateFrame("Frame", nil, Switch)
	Switch.Thumb:SetSize(WidgetHeight, WidgetHeight)
	Switch.Thumb:CreateBorder(nil, nil, nil, nil, nil, nil, K.GetTexture(C["General"].Texture), nil, nil, nil, { 123 / 255, 132 / 255, 137 / 255 })

	Switch.Movement = CreateAnimationGroup(Switch.Thumb):CreateAnimation("Move")
	Switch.Movement:SetDuration(0.1)
	Switch.Movement:SetEasing("in-sinusoidal")

	Switch.TrackTexture = Switch:CreateTexture(nil, "ARTWORK")
	Switch.TrackTexture:SetPoint("TOPLEFT", Switch, 0, -1)
	Switch.TrackTexture:SetPoint("BOTTOMRIGHT", Switch.Thumb, "BOTTOMLEFT", 0, 1)
	Switch.TrackTexture:SetTexture(K.GetTexture(C["General"].Texture))
	Switch.TrackTexture:SetVertexColor(R, G, B)

	Switch.Label = Switch:CreateFontString(nil, "OVERLAY")
	Switch.Label:SetPoint("LEFT", Switch, "RIGHT", Spacing, 0)
	Switch.Label:SetWidth(WidgetListWidth - SwitchWidth - (Spacing * 4))
	Switch.Label:SetJustifyH("LEFT")
	Switch.Label:SetFontObject(K.UIFont)
	Switch.Label:SetText(text)

	if Value then
		Switch.Thumb:SetPoint("RIGHT", Switch, 0, 0)
		Switch.Label:SetTextColor(1, 1, 1)
	else
		Switch.Thumb:SetPoint("LEFT", Switch, 0, 0)
		Switch.Label:SetTextColor(123 / 255, 132 / 255, 137 / 255)
	end

	tinsert(self.Widgets, Anchor)

	return Switch
end

GUI.Widgets.CreateSwitch = CreateSwitch

local EditBoxOnEnter = function(self)
	self.Highlight:SetAlpha(WidgetHighlightAlpha)
end

local EditBoxOnLeave = function(self)
	self.Highlight:SetAlpha(0)
end

local EditBoxOnEnterPressed = function(self)
	local Value = self.Value and tonumber(self:GetText()) or tostring(self:GetText())

	SetValue(self.Group, self.Option, Value)

	if self.Hook then
		self.Hook(self.Value, self.Group)
	end

	self:SetAutoFocus(false)
	self:ClearFocus()
end

local EditBoxOnEscapePressed = function(self)
	self:SetText(self.Value)

	self:SetAutoFocus(false)
	self:ClearFocus()
end

local CreateEditBox = function(self, group, option, text, tooltip, hook)
	local Value = C[group][option]

	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:SetSize(WidgetListWidth - EditBoxWidth - Spacing, WidgetHeight)
	Anchor:SetScript("OnEnter", AnchorOnEnter)
	Anchor:SetScript("OnLeave", AnchorOnLeave)
	Anchor.Tooltip = tooltip

	local EditBox = CreateFrame("Frame", nil, Anchor)
	EditBox:SetPoint("LEFT", Anchor, 0, 0)
	EditBox:SetSize(EditBoxWidth, WidgetHeight)
	EditBox:CreateBorder()

	EditBox.Highlight = EditBox:CreateTexture(nil, "OVERLAY")
	EditBox.Highlight:SetAllPoints()
	EditBox.Highlight:SetTexture(K.GetTexture(C["General"].Texture))
	EditBox.Highlight:SetVertexColor(123 / 255, 132 / 255, 137 / 255)
	EditBox.Highlight:SetAlpha(0)

	EditBox.Label = EditBox:CreateFontString(nil, "OVERLAY")
	EditBox.Label:SetPoint("LEFT", EditBox, "RIGHT", LabelSpacing, 0)
	EditBox.Label:SetWidth(WidgetListWidth - (EditBoxWidth + EditBoxWidth) - (Spacing * 5))
	EditBox.Label:SetJustifyH("LEFT")
	EditBox.Label:SetFontObject(K.UIFont)
	EditBox.Label:SetText(text)

	EditBox.Box = CreateFrame("EditBox", nil, EditBox)
	EditBox.Box:SetFontObject(K.UIFont)
	EditBox.Box:SetPoint("TOPLEFT", EditBox, 0, 0)
	EditBox.Box:SetPoint("BOTTOMRIGHT", EditBox, 0, 0)
	EditBox.Box:SetJustifyH("CENTER")
	EditBox.Box:SetMaxLetters(999)
	EditBox.Box:SetAutoFocus(false)
	EditBox.Box:EnableKeyboard(true)
	EditBox.Box:EnableMouse(true)
	EditBox.Box:EnableMouseWheel(true)
	EditBox.Box:SetText(Value)
	EditBox.Box:SetScript("OnEnterPressed", EditBoxOnEnterPressed)
	EditBox.Box:SetScript("OnEscapePressed", EditBoxOnEscapePressed)
	EditBox.Box:SetScript("OnEnter", EditBoxOnEnter)
	EditBox.Box:SetScript("OnLeave", EditBoxOnLeave)

	EditBox.Box.Group = group
	EditBox.Box.Option = option
	EditBox.Box.Value = Value
	EditBox.Box.Hook = hook
	EditBox.Box.Parent = EditBox
	EditBox.Box.Highlight = EditBox.Highlight

	tinsert(self.Widgets, Anchor)

	return EditBox
end

GUI.Widgets.CreateEditBox = CreateEditBox

-- Sliders
local SliderEditBoxOnEnter = function(self)
	self.Highlight:SetAlpha(WidgetHighlightAlpha)
end

local SliderEditBoxOnLeave = function(self)
	self.Highlight:SetAlpha(0)
end

local SliderOnEnter = function(self)
	self.Highlight:SetAlpha(WidgetHighlightAlpha)
end

local SliderOnLeave = function(self)
	self.Highlight:SetAlpha(0)
end

local SliderOnValueChanged = function(self)
	local Value = self:GetValue()
	local Step = self.EditBox.StepValue

	if Step >= 1 then
		Value = floor(Value)
	else
		if Step <= 0.01 then
			Value = K.Round(Value, 2)
		else
			Value = K.Round(Value, 1)
		end
	end

	self.EditBox.Value = Value
	self.EditBox:SetText(Value)

	SetValue(self.EditBox.Group, self.EditBox.Option, Value)
	PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)

	if self.Hook then
		self.Hook(self.Value, self.Group)
	end
end

local SliderOnMouseWheel = function(self, delta)
	local Value = self.EditBox.Value
	local Step = self.EditBox.StepValue

	if delta < 0 then
		Value = Value - Step
	else
		Value = Value + Step
	end

	if Step >= 1 then
		Value = floor(Value)
	else
		if Step <= 0.01 then
			Value = K.Round(Value, 2)
		else
			Value = K.Round(Value, 1)
		end
	end

	if Value < self.EditBox.MinValue then
		Value = self.EditBox.MinValue
	elseif Value > self.EditBox.MaxValue then
		Value = self.EditBox.MaxValue
	end

	self.EditBox.Value = Value

	self:SetValue(Value)
	self.EditBox:SetText(Value)
end

local SliderEditBoxOnEnterPressed = function(self)
	local Value = tonumber(self:GetText())

	if type(Value) ~= "number" then
		return
	end

	if Value ~= self.Value then
		self.Slider:SetValue(Value)
		SliderOnValueChanged(self.Slider)
	end

	self:SetAutoFocus(false)
	self:ClearFocus()
end

local SliderEditBoxOnChar = function(self)
	local Value = tonumber(self:GetText())

	if type(Value) ~= "number" then
		self:SetText(self.Value)
	end
end

local SliderEditBoxOnMouseDown = function(self, button)
	if button == "LeftButton" then
		self:SetAutoFocus(true)
		self:SetText(self.Value)
	elseif button == "RightButton" and IsShiftKeyDown() then
		if self:HasFocus() then
			self:SetAutoFocus(false)
			self:ClearFocus()
		end

		local Value = K.Defaults[self.Group][self.Option]
		self:SetText(Value)
		self.Slider:SetValue(Value)
		SliderOnValueChanged(self.Slider)

		print("SliderEditBoxOnMouseUp - Group: " .. self.Group .. ", Option: " .. self.Option .. ", Value: " .. Value)
	end
end

local SliderEditBoxOnEditFocusLost = function(self)
	if self.Value > self.MaxValue then
		self.Value = self.MaxValue
	elseif self.Value < self.MinValue then
		self.Value = self.MinValue
	end

	self:SetText(self.Value)
end

local SliderEditBoxOnMouseWheel = function(self, delta)
	if self:HasFocus() then
		self:SetAutoFocus(false)
		self:ClearFocus()
	end

	if delta > 0 then
		self.Value = self.Value + self.StepValue

		if self.Value > self.MaxValue then
			self.Value = self.MaxValue
		end
	else
		self.Value = self.Value - self.StepValue

		if self.Value < self.MinValue then
			self.Value = self.MinValue
		end
	end

	self:SetText(self.Value)
	self.Slider:SetValue(self.Value)
end

local CreateSlider = function(self, group, option, text, minvalue, maxvalue, stepvalue, tooltip, hook)
	local Value = C[group][option]

	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:SetSize(WidgetListWidth - (Spacing * 2), WidgetHeight)
	Anchor:SetScript("OnEnter", AnchorOnEnter)
	Anchor:SetScript("OnLeave", AnchorOnLeave)
	Anchor.Tooltip = tooltip

	local EditBox = CreateFrame("Frame", nil, Anchor)
	EditBox:SetPoint("LEFT", Anchor, 0, 0)
	EditBox:SetSize(SliderEditBoxWidth, WidgetHeight)
	EditBox:CreateBorder()

	EditBox.Highlight = EditBox:CreateTexture(nil, "OVERLAY")
	EditBox.Highlight:SetAllPoints()
	EditBox.Highlight:SetTexture(K.GetTexture(C["General"].Texture))
	EditBox.Highlight:SetVertexColor(123 / 255, 132 / 255, 137 / 255)
	EditBox.Highlight:SetAlpha(0)

	EditBox.Box = CreateFrame("EditBox", nil, EditBox)
	EditBox.Box:SetFontObject(K.UIFont)
	EditBox.Box:SetPoint("TOPLEFT", EditBox, 0, 0)
	EditBox.Box:SetPoint("BOTTOMRIGHT", EditBox, 0, 0)
	EditBox.Box:SetJustifyH("CENTER")
	EditBox.Box:SetMaxLetters(4)
	EditBox.Box:SetAutoFocus(false)
	EditBox.Box:EnableKeyboard(true)
	EditBox.Box:EnableMouse(true)
	EditBox.Box:EnableMouseWheel(true)
	EditBox.Box:SetText(Value)
	EditBox.Box:SetScript("OnMouseWheel", SliderEditBoxOnMouseWheel)
	EditBox.Box:SetScript("OnMouseDown", SliderEditBoxOnMouseDown)
	EditBox.Box:SetScript("OnEscapePressed", SliderEditBoxOnEnterPressed)
	EditBox.Box:SetScript("OnEnterPressed", SliderEditBoxOnEnterPressed)
	EditBox.Box:SetScript("OnEditFocusLost", SliderEditBoxOnEditFocusLost)
	EditBox.Box:SetScript("OnChar", SliderEditBoxOnChar)
	EditBox.Box:SetScript("OnEnter", SliderEditBoxOnEnter)
	EditBox.Box:SetScript("OnLeave", SliderEditBoxOnLeave)
	EditBox.Box.Group = group
	EditBox.Box.Option = option
	EditBox.Box.MinValue = minvalue
	EditBox.Box.MaxValue = maxvalue
	EditBox.Box.StepValue = stepvalue
	EditBox.Box.Value = Value
	EditBox.Box.Parent = EditBox
	EditBox.Box.Highlight = EditBox.Highlight

	local Slider = CreateFrame("Slider", nil, EditBox)
	Slider:SetPoint("LEFT", EditBox, "RIGHT", Spacing, 0)
	Slider:SetSize(SliderWidth, WidgetHeight)
	Slider:SetThumbTexture(K.GetTexture(C["General"].Texture))
	Slider:SetOrientation("HORIZONTAL")
	Slider:SetValueStep(stepvalue)
	Slider:CreateBorder()
	Slider:SetMinMaxValues(minvalue, maxvalue)
	Slider:SetValue(Value)
	Slider:EnableMouseWheel(true)
	Slider:SetScript("OnMouseWheel", SliderOnMouseWheel)
	Slider:SetScript("OnValueChanged", SliderOnValueChanged)
	Slider:SetScript("OnEnter", SliderOnEnter)
	Slider:SetScript("OnLeave", SliderOnLeave)
	Slider.EditBox = EditBox.Box
	Slider.Hook = hook

	Slider.Highlight = Slider:CreateTexture(nil, "OVERLAY")
	Slider.Highlight:SetAllPoints()
	Slider.Highlight:SetTexture(K.GetTexture(C["General"].Texture))
	Slider.Highlight:SetVertexColor(123 / 255, 132 / 255, 137 / 255)
	Slider.Highlight:SetAlpha(0)

	Slider.Label = Slider:CreateFontString(nil, "OVERLAY")
	Slider.Label:SetPoint("LEFT", Slider, "RIGHT", LabelSpacing, 0)
	Slider.Label:SetWidth(WidgetListWidth - (SliderWidth + SliderEditBoxWidth) - (Spacing * 5))
	Slider.Label:SetJustifyH("LEFT")
	Slider.Label:SetFontObject(K.UIFont)
	Slider.Label:SetText(text)

	local Thumb = Slider:GetThumbTexture()
	Thumb:SetSize(8, WidgetHeight)
	Thumb:SetTexture(K.GetTexture(C["General"].Texture))
	Thumb:SetVertexColor(123 / 255, 132 / 255, 137 / 255)

	Thumb.Border = CreateFrame("Frame", nil, Slider)
	Thumb.Border:SetPoint("TOPLEFT", Slider:GetThumbTexture(), 0, -1)
	Thumb.Border:SetPoint("BOTTOMRIGHT", Slider:GetThumbTexture(), 0, 1)
	Thumb.Border:CreateBorder(nil, nil, nil, nil, nil, nil, K.GetTexture(C["General"].Texture), nil, nil, nil, { 123 / 255, 132 / 255, 137 / 255 })

	Slider.Progress = Slider:CreateTexture(nil, "ARTWORK")
	Slider.Progress:SetPoint("TOPLEFT", Slider, 1, -1)
	Slider.Progress:SetPoint("BOTTOMRIGHT", Thumb, "BOTTOMLEFT", 0, 0)
	Slider.Progress:SetTexture(K.GetTexture(C["General"].Texture))
	Slider.Progress:SetVertexColor(R, G, B)

	EditBox.Box.Slider = Slider

	Slider:Show()

	tinsert(self.Widgets, Anchor)

	return EditBox
end

GUI.Widgets.CreateSlider = CreateSlider

-- Dropdown Menu
local SetArrowUp = function(self)
	self.ArrowDown.Fade:SetChange(0)
	self.ArrowDown.Fade:SetEasing("out-sinusoidal")

	self.ArrowUp.Fade:SetChange(1)
	self.ArrowUp.Fade:SetEasing("in-sinusoidal")

	self.ArrowDown.Fade:Play()
	self.ArrowUp.Fade:Play()
end

local SetArrowDown = function(self)
	self.ArrowUp.Fade:SetChange(0)
	self.ArrowUp.Fade:SetEasing("out-sinusoidal")

	self.ArrowDown.Fade:SetChange(1)
	self.ArrowDown.Fade:SetEasing("in-sinusoidal")

	self.ArrowUp.Fade:Play()
	self.ArrowDown.Fade:Play()
end

local CloseLastDropdown = function(compare)
	if LastActiveDropdown and LastActiveDropdown.Menu:IsShown() and (LastActiveDropdown ~= compare) then
		if not LastActiveDropdown.Menu.FadeOut:IsPlaying() then
			LastActiveDropdown.Menu.FadeOut:Play()
			SetArrowDown(LastActiveDropdown)
		end
	end
end

local DropdownButtonOnMouseUp = function(self, button)
	self.Parent.Texture:SetVertexColor(BrightColor[1], BrightColor[2], BrightColor[3])

	if button == "LeftButton" then
		if self.Menu:IsVisible() then
			self.Menu.FadeOut:Play()
			SetArrowDown(self)
		else
			for i = 1, #self.Menu do
				if self.Parent.Type then
					if self.Menu[i].Key == self.Parent.Value then
						self.Menu[i].Selected:Show()

						if self.Parent.Type == "Texture" then
							self.Menu[i].Selected:SetTexture(K.GetTexture(self.Parent.Value))
						end
					else
						self.Menu[i].Selected:Hide()
					end
				else
					if self.Menu[i].Value == self.Parent.Value then
						self.Menu[i].Selected:Show()
					else
						self.Menu[i].Selected:Hide()
					end
				end
			end

			CloseLastDropdown(self)
			self.Menu:Show()
			self.Menu.FadeIn:Play()
			SetArrowUp(self)
		end

		LastActiveDropdown = self
	else
		local Value = K.Defaults[self.Parent.Group][self.Parent.Option]

		self.Parent.Value = Value

		if self.Parent.Type == "Texture" then
			self.Parent.Texture:SetTexture(K.GetTexture(Value))
		end

		self.Parent.Current:SetText(self.Parent.Value)

		SetValue(self.Parent.Group, self.Parent.Option, self.Parent.Value)
	end
end

local DropdownButtonOnMouseDown = function(self)
	local Red, Green, Blue = unpack(BrightColor)

	self.Parent.Texture:SetVertexColor(Red * 0.85, Green * 0.85, Blue * 0.85)
end

local MenuItemOnMouseUp = function(self)
	self.Parent.FadeOut:Play()
	SetArrowDown(self.GrandParent.Button)

	self.Highlight:SetAlpha(0)

	if self.GrandParent.Type then
		SetValue(self.Group, self.Option, self.Key)

		self.GrandParent.Value = self.Key

		if self.GrandParent.Hook then
			self.GrandParent.Hook(self.Key, self.Group)
		end
	else
		SetValue(self.Group, self.Option, self.Value)

		self.GrandParent.Value = self.Value

		if self.GrandParent.Hook then
			self.GrandParent.Hook(self.Value, self.Group)
		end
	end

	if self.GrandParent.Type == "Texture" then
		self.GrandParent.Texture:SetTexture(K.GetTexture(self.Key))
	end

	self.GrandParent.Current:SetText(self.Key)
end

local MenuItemOnEnter = function(self)
	self.Highlight:SetAlpha(WidgetHighlightAlpha)
end

local MenuItemOnLeave = function(self)
	self.Highlight:SetAlpha(0)
end

local DropdownButtonOnEnter = function(self)
	self.Highlight:SetAlpha(WidgetHighlightAlpha)
end

local DropdownButtonOnLeave = function(self)
	self.Highlight:SetAlpha(0)
end

local ScrollMenu = function(self)
	local First = false

	for i = 1, #self do
		if (i >= self.Offset) and (i <= self.Offset + ListItemsToShow - 1) then
			if not First then
				self[i]:SetPoint("TOPLEFT", self, 3, -3)
				First = true
			else
				self[i]:SetPoint("TOPLEFT", self[i - 1], "BOTTOMLEFT", 0, -6)
			end

			self[i]:Show()
		else
			self[i]:Hide()
		end
	end
end

local SetDropdownOffsetByDelta = function(self, delta)
	if delta == 1 then -- up
		self.Offset = self.Offset - 1

		if self.Offset <= 1 then
			self.Offset = 1
		end
	else -- down
		self.Offset = self.Offset + 1

		if self.Offset > (#self - (ListItemsToShow - 1)) then
			self.Offset = self.Offset - 1
		end
	end
end

local DropdownOnMouseWheel = function(self, delta)
	self:SetDropdownOffsetByDelta(delta)
	self:ScrollMenu()
	self.ScrollBar:SetValue(self.Offset)
end

local SetDropdownOffset = function(self, offset)
	self.Offset = offset

	if self.Offset <= 1 then
		self.Offset = 1
	elseif self.Offset > (#self - ListItemsToShow - 1) then
		self.Offset = self.Offset - 1
	end

	self:ScrollMenu()
end

local DropdownScrollBarOnValueChanged = function(self)
	local Value = K.Round(self:GetValue())
	local Parent = self:GetParent()
	Parent.Offset = Value

	Parent:ScrollMenu()
end

local DropdownScrollBarOnMouseWheel = function(self, delta)
	DropdownOnMouseWheel(self:GetParent(), delta)
end

local AddDropdownScrollBar = function(self)
	local MaxValue = (#self - (ListItemsToShow - 1))
	local Width = WidgetHeight / 2

	local ScrollBar = CreateFrame("Slider", nil, self)
	ScrollBar:SetPoint("TOPRIGHT", self, -Spacing, -Spacing)
	ScrollBar:SetPoint("BOTTOMRIGHT", self, -Spacing, Spacing)
	ScrollBar:SetWidth(Width)
	ScrollBar:SetThumbTexture(K.GetTexture(C["General"].Texture))
	ScrollBar:SetOrientation("VERTICAL")
	ScrollBar:SetValueStep(1)
	ScrollBar:CreateBorder()
	ScrollBar:SetMinMaxValues(1, MaxValue)
	ScrollBar:SetValue(1)
	ScrollBar:EnableMouseWheel(true)
	ScrollBar:SetScript("OnMouseWheel", DropdownScrollBarOnMouseWheel)
	ScrollBar:SetScript("OnValueChanged", DropdownScrollBarOnValueChanged)

	self.ScrollBar = ScrollBar

	local Thumb = ScrollBar:GetThumbTexture()
	Thumb:SetSize(Width, WidgetHeight)
	Thumb:SetTexture(K.GetTexture(C["General"].Texture))
	Thumb:SetVertexColor(0, 0, 0)

	ScrollBar.NewTexture = ScrollBar:CreateTexture(nil, "OVERLAY")
	ScrollBar.NewTexture:SetPoint("TOPLEFT", Thumb, 0, 0)
	ScrollBar.NewTexture:SetPoint("BOTTOMRIGHT", Thumb, 0, 0)
	ScrollBar.NewTexture:SetTexture(K.GetTexture(C["General"].Texture))
	ScrollBar.NewTexture:SetVertexColor(0, 0, 0)

	ScrollBar.NewTexture2 = ScrollBar:CreateTexture(nil, "OVERLAY")
	ScrollBar.NewTexture2:SetPoint("TOPLEFT", ScrollBar.NewTexture, 1, -1)
	ScrollBar.NewTexture2:SetPoint("BOTTOMRIGHT", ScrollBar.NewTexture, -1, 1)
	ScrollBar.NewTexture2:SetTexture(K.GetTexture(C["General"].Texture))
	ScrollBar.NewTexture2:SetVertexColor(BrightColor[1], BrightColor[2], BrightColor[3])

	self:EnableMouseWheel(true)
	self:SetScript("OnMouseWheel", DropdownOnMouseWheel)

	self.ScrollMenu = ScrollMenu
	self.SetDropdownOffset = SetDropdownOffset
	self.SetDropdownOffsetByDelta = SetDropdownOffsetByDelta
	self.ScrollBar = ScrollBar

	self:SetDropdownOffset(1)

	ScrollBar:Show()

	for i = 1, #self do
		self[i]:SetWidth((DropdownWidth - Width) - (Spacing * 3) + 2)
	end

	self:SetHeight(((WidgetHeight + 6) * ListItemsToShow) - 0)
end

local CreateDropdown = function(self, group, option, text, custom, tooltip, hook)
	local Value
	local Selections

	if custom then
		Value = C[group][option]

		if custom == "Texture" then
			Selections = C["Media"].Statusbars
		end
	else
		Value = C[group][option].Value
		Selections = C[group][option].Options
	end

	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:SetSize(WidgetListWidth - (Spacing * 2), WidgetHeight)
	Anchor:SetScript("OnEnter", AnchorOnEnter)
	Anchor:SetScript("OnLeave", AnchorOnLeave)
	Anchor.Tooltip = tooltip

	local Dropdown = CreateFrame("Frame", nil, Anchor)
	Dropdown:SetPoint("LEFT", Anchor, 0, 0)
	Dropdown:SetSize(DropdownWidth, WidgetHeight)
	Dropdown:CreateBorder()
	Dropdown:SetFrameLevel(self:GetFrameLevel() + 4)
	Dropdown.Values = Selections
	Dropdown.Value = Value
	Dropdown.Group = group
	Dropdown.Option = option
	Dropdown.Type = custom
	Dropdown.Hook = hook

	Dropdown.Texture = Dropdown:CreateTexture(nil, "ARTWORK")
	Dropdown.Texture:SetAllPoints()
	Dropdown.Texture:SetVertexColor(BrightColor[1], BrightColor[2], BrightColor[3])

	Dropdown.Button = CreateFrame("Frame", nil, Dropdown)
	Dropdown.Button:SetSize(DropdownWidth, WidgetHeight)
	Dropdown.Button:SetPoint("LEFT", Dropdown, 0, 0)
	Dropdown.Button:SetScript("OnMouseUp", DropdownButtonOnMouseUp)
	Dropdown.Button:SetScript("OnMouseDown", DropdownButtonOnMouseDown)
	Dropdown.Button:SetScript("OnEnter", DropdownButtonOnEnter)
	Dropdown.Button:SetScript("OnLeave", DropdownButtonOnLeave)

	Dropdown.Button.Highlight = Dropdown:CreateTexture(nil, "ARTWORK")
	Dropdown.Button.Highlight:SetAllPoints()
	Dropdown.Button.Highlight:SetTexture(K.GetTexture(C["General"].Texture))
	Dropdown.Button.Highlight:SetVertexColor(123 / 255, 132 / 255, 137 / 255)
	Dropdown.Button.Highlight:SetAlpha(0)

	Dropdown.Current = Dropdown:CreateFontString(nil, "ARTWORK")
	Dropdown.Current:SetPoint("LEFT", Dropdown, Spacing, 0)
	Dropdown.Current:SetFontObject(K.UIFont)
	Dropdown.Current:SetJustifyH("LEFT")
	Dropdown.Current:SetWidth(DropdownWidth - 4)
	Dropdown.Current:SetText(Value)

	Dropdown.Label = Dropdown:CreateFontString(nil, "OVERLAY")
	Dropdown.Label:SetPoint("LEFT", Dropdown, "RIGHT", LabelSpacing, 0)
	Dropdown.Label:SetWidth(WidgetListWidth - DropdownWidth - (Spacing * 4))
	Dropdown.Label:SetJustifyH("LEFT")
	Dropdown.Label:SetFontObject(K.UIFont)
	Dropdown.Label:SetJustifyH("LEFT")
	Dropdown.Label:SetWidth(WidgetListWidth - DropdownWidth - (Spacing * 4))
	Dropdown.Label:SetText(text)

	Dropdown.ArrowAnchor = CreateFrame("Frame", nil, Dropdown)
	Dropdown.ArrowAnchor:SetSize(WidgetHeight, WidgetHeight)
	Dropdown.ArrowAnchor:SetPoint("RIGHT", Dropdown, 0, 0)

	Dropdown.Button.ArrowDown = Dropdown.ArrowAnchor:CreateTexture(nil, "OVERLAY")
	Dropdown.Button.ArrowDown:SetSize(16, 16)
	Dropdown.Button.ArrowDown:SetPoint("CENTER", Dropdown.ArrowAnchor)
	Dropdown.Button.ArrowDown:SetTexture(C["Media"].Textures.ArrowTexture)
	Dropdown.Button.ArrowDown:SetRotation(rad(180))

	Dropdown.Button.ArrowUp = Dropdown.ArrowAnchor:CreateTexture(nil, "OVERLAY")
	Dropdown.Button.ArrowUp:SetSize(16, 16)
	Dropdown.Button.ArrowUp:SetPoint("CENTER", Dropdown.ArrowAnchor)
	Dropdown.Button.ArrowUp:SetTexture(C["Media"].Textures.ArrowTexture)
	Dropdown.Button.ArrowUp:SetRotation(rad(0))
	Dropdown.Button.ArrowUp:SetAlpha(0)

	Dropdown.Button.ArrowDown.Fade = CreateAnimationGroup(Dropdown.Button.ArrowDown):CreateAnimation("Fade")
	Dropdown.Button.ArrowDown.Fade:SetDuration(0.15)

	Dropdown.Button.ArrowUp.Fade = CreateAnimationGroup(Dropdown.Button.ArrowUp):CreateAnimation("Fade")
	Dropdown.Button.ArrowUp.Fade:SetDuration(0.15)

	Dropdown.Menu = CreateFrame("Frame", nil, Dropdown)
	Dropdown.Menu:SetPoint("TOP", Dropdown, "BOTTOM", 0, -6)
	Dropdown.Menu:SetSize(DropdownWidth, 1)
	Dropdown.Menu:CreateBorder()
	Dropdown.Menu:SetFrameLevel(Dropdown.Menu:GetFrameLevel() + 2)
	Dropdown.Menu:SetFrameStrata("DIALOG")
	Dropdown.Menu:Hide()
	Dropdown.Menu:SetAlpha(0)

	Dropdown.Button.Menu = Dropdown.Menu
	Dropdown.Button.Parent = Dropdown

	Dropdown.Menu.Fade = CreateAnimationGroup(Dropdown.Menu)

	Dropdown.Menu.FadeIn = Dropdown.Menu.Fade:CreateAnimation("Fade")
	Dropdown.Menu.FadeIn:SetEasing("in-sinusoidal")
	Dropdown.Menu.FadeIn:SetDuration(0.3)
	Dropdown.Menu.FadeIn:SetChange(1)

	Dropdown.Menu.FadeOut = Dropdown.Menu.Fade:CreateAnimation("Fade")
	Dropdown.Menu.FadeOut:SetEasing("out-sinusoidal")
	Dropdown.Menu.FadeOut:SetDuration(0.3)
	Dropdown.Menu.FadeOut:SetChange(0)
	Dropdown.Menu.FadeOut:SetScript("OnFinished", function(self)
		self:GetParent():Hide()
	end)

	local Count = 0
	local LastMenuItem

	for k, v in PairsByKeys(Selections) do
		Count = Count + 1

		local MenuItem = CreateFrame("Frame", nil, Dropdown.Menu)
		MenuItem:SetSize(DropdownWidth - 6, WidgetHeight)
		MenuItem:CreateBorder()
		MenuItem:SetScript("OnMouseUp", MenuItemOnMouseUp)
		MenuItem:SetScript("OnEnter", MenuItemOnEnter)
		MenuItem:SetScript("OnLeave", MenuItemOnLeave)
		MenuItem.Key = k
		MenuItem.Value = v
		MenuItem.Group = group
		MenuItem.Option = option
		MenuItem.Parent = MenuItem:GetParent()
		MenuItem.GrandParent = MenuItem:GetParent():GetParent()

		MenuItem.Highlight = MenuItem:CreateTexture(nil, "OVERLAY")
		MenuItem.Highlight:SetAllPoints()
		MenuItem.Highlight:SetTexture(K.GetTexture(C["General"].Texture))
		MenuItem.Highlight:SetVertexColor(123 / 255, 132 / 255, 137 / 255)
		MenuItem.Highlight:SetAlpha(0)

		MenuItem.Texture = MenuItem:CreateTexture(nil, "ARTWORK")
		MenuItem.Texture:SetAllPoints()
		MenuItem.Texture:SetTexture(K.GetTexture(C["General"].Texture))
		MenuItem.Texture:SetVertexColor(BrightColor[1], BrightColor[2], BrightColor[3])

		MenuItem.Selected = MenuItem:CreateTexture(nil, "OVERLAY")
		MenuItem.Selected:SetAllPoints()
		MenuItem.Selected:SetTexture(K.GetTexture(C["General"].Texture))
		MenuItem.Selected:SetVertexColor(R, G, B)

		MenuItem.Text = MenuItem:CreateFontString(nil, "OVERLAY")
		MenuItem.Text:SetPoint("LEFT", MenuItem, 5, 0)
		MenuItem.Text:SetWidth((DropdownWidth + 3) - (Spacing * 2))
		MenuItem.Text:SetFontObject(K.UIFont)
		MenuItem.Text:SetJustifyH("LEFT")
		MenuItem.Text:SetText(k)

		if custom == "Texture" then
			MenuItem.Texture:SetTexture(K.GetTexture(k))
			MenuItem.Selected:SetTexture(K.GetTexture(k))
		end

		if custom then
			if MenuItem.Key == MenuItem.GrandParent.Value then
				MenuItem.Selected:Show()
				MenuItem.GrandParent.Current:SetText(k)
			else
				MenuItem.Selected:Hide()
			end
		else
			if MenuItem.Value == MenuItem.GrandParent.Value then
				MenuItem.Selected:Show()
				MenuItem.GrandParent.Current:SetText(k)
			else
				MenuItem.Selected:Hide()
			end
		end

		tinsert(Dropdown.Menu, MenuItem)

		if LastMenuItem then
			MenuItem:SetPoint("TOP", LastMenuItem, "BOTTOM", 0, -6)
		else
			MenuItem:SetPoint("TOP", Dropdown.Menu, 0, -3)
		end

		if Count > ListItemsToShow then
			MenuItem:Hide()
		end

		LastMenuItem = MenuItem
	end

	if custom == "Texture" then
		Dropdown.Texture:SetTexture(K.GetTexture(Value))
	else
		Dropdown.Texture:SetTexture(K.GetTexture(C["General"].Texture))
	end

	if #Dropdown.Menu > ListItemsToShow then
		AddDropdownScrollBar(Dropdown.Menu)
	else
		Dropdown.Menu:SetHeight(((WidgetHeight + 6) * Count) + 0)
	end

	if self.Widgets then
		tinsert(self.Widgets, Anchor)
	end

	return Dropdown
end

GUI.Widgets.CreateDropdown = CreateDropdown

-- Color selection
local ColorOnMouseUp = function(self, button)
	local CPF = ColorPickerFrame

	if CPF:IsShown() then
		return
	end

	self:SetBackdropColor(BrightColor[1], BrightColor[2], BrightColor[3])

	local CurrentR, CurrentG, CurrentB = unpack(self.Value)

	if button == "LeftButton" then
		local ShowColorPickerFrame = function(r, g, b, func, cancel)
			HideUIPanel(CPF)
			CPF.Button = self

			CPF:SetColorRGB(CurrentR, CurrentG, CurrentB)

			CPF.Group = self.Group
			CPF.Option = self.Option
			CPF.OldR = CurrentR
			CPF.OldG = CurrentG
			CPF.OldB = CurrentB
			CPF.previousValues = self.Value
			CPF.func = func
			CPF.opacityFunc = func
			CPF.cancelFunc = cancel

			ShowUIPanel(CPF)
		end

		local ColorPickerFunction = function(restore)
			if restore ~= nil or self ~= CPF.Button then
				return
			end

			local NewR, NewG, NewB = CPF:GetColorRGB()

			NewR = K.Round(NewR, 3)
			NewG = K.Round(NewG, 3)
			NewB = K.Round(NewB, 3)

			local NewValue = { NewR, NewG, NewB }

			CPF.Button:GetParent().KKUI_Background:SetVertexColor(NewR, NewG, NewB)
			CPF.Button.Value = NewValue

			SetValue(CPF.Group, CPF.Option, NewValue)
		end

		ShowColorPickerFrame(CurrentR, CurrentG, CurrentB, ColorPickerFunction, ColorPickerFrameCancel)
	else
		local Value = K.Defaults[self.Group][self.Option]

		self:GetParent().KKUI_Background:SetVertexColor(unpack(Value))
		self.Value = Value

		SetValue(self.Group, self.Option, Value)
	end
end

local ColorOnMouseDown = function(self)
	self.KKUI_Background:SetVertexColor(BGColor[1], BGColor[2], BGColor[3])
end

local ColorOnEnter = function(self)
	self.Highlight:SetAlpha(WidgetHighlightAlpha)
end

local ColorOnLeave = function(self)
	self.Highlight:SetAlpha(0)
end

local CreateColorSelection = function(self, group, option, text, tooltip)
	local Value = C[group][option]
	local CurrentR, CurrentG, CurrentB = unpack(Value)

	local Anchor = CreateFrame("Frame", nil, self)
	Anchor:SetSize(WidgetListWidth - (Spacing * 2), WidgetHeight)
	Anchor:SetScript("OnEnter", AnchorOnEnter)
	Anchor:SetScript("OnLeave", AnchorOnLeave)
	Anchor.Tooltip = tooltip

	local Swatch = CreateFrame("Frame", nil, Anchor)
	Swatch:SetSize(WidgetHeight, WidgetHeight)
	Swatch:SetPoint("LEFT", Anchor, 0, 0)
	-- stylua: ignore
	Swatch:CreateBorder(nil, nil, nil, nil, nil, nil, K.GetTexture(C["General"].Texture), nil, nil, nil, {CurrentR, CurrentG, CurrentB})

	Swatch.Select = CreateFrame("Frame", nil, Swatch, "BackdropTemplate")
	Swatch.Select:SetSize(ColorButtonWidth, WidgetHeight)
	Swatch.Select:SetPoint("LEFT", Swatch, "RIGHT", Spacing, 0)
	Swatch.Select:CreateBorder()
	Swatch.Select:SetScript("OnMouseDown", ColorOnMouseDown)
	Swatch.Select:SetScript("OnMouseUp", ColorOnMouseUp)
	Swatch.Select:SetScript("OnEnter", ColorOnEnter)
	Swatch.Select:SetScript("OnLeave", ColorOnLeave)
	Swatch.Select.Group = group
	Swatch.Select.Option = option
	Swatch.Select.Value = Value

	Swatch.Select.Highlight = Swatch.Select:CreateTexture(nil, "OVERLAY")
	Swatch.Select.Highlight:SetAllPoints()
	Swatch.Select.Highlight:SetTexture(K.GetTexture(C["General"].Texture))
	Swatch.Select.Highlight:SetVertexColor(123 / 255, 132 / 255, 137 / 255)
	Swatch.Select.Highlight:SetAlpha(0)

	Swatch.Select.Label = Swatch.Select:CreateFontString(nil, "OVERLAY")
	Swatch.Select.Label:SetPoint("CENTER", Swatch.Select, 0, 0)
	Swatch.Select.Label:SetFontObject(K.UIFont)
	Swatch.Select.Label:SetJustifyH("CENTER")
	Swatch.Select.Label:SetWidth(ColorButtonWidth - 4)
	Swatch.Select.Label:SetText("Select Color")

	Swatch.Label = Swatch:CreateFontString(nil, "OVERLAY")
	Swatch.Label:SetPoint("LEFT", Swatch.Select, "RIGHT", LabelSpacing, 0)
	Swatch.Label:SetWidth(WidgetListWidth - (ColorButtonWidth + WidgetHeight) - (Spacing * 5))
	Swatch.Label:SetJustifyH("LEFT")
	Swatch.Label:SetFontObject(K.UIFont)
	Swatch.Label:SetJustifyH("LEFT")
	Swatch.Label:SetWidth(DropdownWidth - 4)
	Swatch.Label:SetText(text)

	tinsert(self.Widgets, Anchor)

	return Swatch
end

GUI.Widgets.CreateColorSelection = CreateColorSelection

-- GUI functions
GUI.AddWidgets = function(self, func)
	if type(func) ~= "function" then
		return
	end

	tinsert(self.Queue, func)
end

GUI.UnpackQueue = function(self)
	local Function

	for i = 1, #self.Queue do
		Function = tremove(self.Queue, 1)

		Function(self)
	end
end

GUI.SortMenuButtons = function(self)
	sort(self.Buttons, function(a, b)
		return a.Name < b.Name
	end)

	for i = 1, #self.Buttons do
		self.Buttons[i]:ClearAllPoints()

		if i == 1 then
			self.Buttons[i]:SetPoint("TOPLEFT", self.ButtonList, Spacing, -Spacing)
		else
			self.Buttons[i]:SetPoint("TOP", self.Buttons[i - 1], "BOTTOM", 0, -(Spacing - 1))
		end
	end
end

local SortWidgets = function(self)
	for i = 1, #self.Widgets do
		if i == 1 then
			self.Widgets[i]:SetPoint("TOPLEFT", self, Spacing, -Spacing)
		else
			self.Widgets[i]:SetPoint("TOPLEFT", self.Widgets[i - 1], "BOTTOMLEFT", 0, -(Spacing - 1))
		end
	end

	self.Sorted = true
end

local Scroll = function(self)
	local First = false

	for i = 1, #self.Widgets do
		if (i >= self.Offset) and (i <= self.Offset + self:GetParent().WindowCount - 1) then
			if not First then
				self.Widgets[i]:SetPoint("TOPLEFT", self, Spacing, -Spacing)
				First = true
			else
				self.Widgets[i]:SetPoint("TOPLEFT", self.Widgets[i - 1], "BOTTOMLEFT", 0, -(Spacing - 1))
			end

			self.Widgets[i]:Show()
		else
			self.Widgets[i]:Hide()
		end
	end
end

local SetOffsetByDelta = function(self, delta)
	if delta == 1 then -- up
		self.Offset = self.Offset - 1

		if self.Offset <= 1 then
			self.Offset = 1
		end
	else -- down
		self.Offset = self.Offset + 1

		if self.Offset > (#self.Widgets - (self:GetParent().WindowCount - 1)) then
			self.Offset = self.Offset - 1
		end
	end
end

local WindowOnMouseWheel = function(self, delta)
	self:SetOffsetByDelta(delta)
	self:Scroll()
	self.ScrollBar:SetValue(self.Offset)
end

local SetOffset = function(self, offset)
	self.Offset = offset

	if self.Offset <= 1 then
		self.Offset = 1
	elseif self.Offset > (#self.Widgets - self:GetParent().WindowCount - 1) then
		self.Offset = self.Offset - 1
	end

	self:Scroll()
end

local WindowScrollBarOnValueChanged = function(self)
	local Value = K.Round(self:GetValue())
	local Parent = self:GetParent()
	Parent.Offset = Value

	Parent:Scroll()
end

local WindowScrollBarOnMouseWheel = function(self, delta)
	WindowOnMouseWheel(self:GetParent(), delta)
end

local AddScrollBar = function(self)
	local MaxValue = (#self.Widgets - (self:GetParent().WindowCount - 1))

	local ScrollBar = CreateFrame("Slider", nil, self)
	ScrollBar:SetPoint("TOPRIGHT", self, -Spacing, -Spacing)
	ScrollBar:SetPoint("BOTTOMRIGHT", self, -Spacing, Spacing)
	ScrollBar:SetWidth(WidgetHeight)
	ScrollBar:SetThumbTexture(K.GetTexture(C["General"].Texture))
	ScrollBar:SetOrientation("VERTICAL")
	ScrollBar:SetValueStep(1)
	ScrollBar:CreateBorder()
	ScrollBar:SetMinMaxValues(1, MaxValue)
	ScrollBar:SetValue(1)
	ScrollBar:EnableMouseWheel(true)
	ScrollBar:SetScript("OnMouseWheel", WindowScrollBarOnMouseWheel)
	ScrollBar:SetScript("OnValueChanged", WindowScrollBarOnValueChanged)

	ScrollBar.Window = self

	local Thumb = ScrollBar:GetThumbTexture()
	Thumb:SetSize(WidgetHeight, WidgetHeight)
	Thumb:SetTexture(K.GetTexture(C["General"].Texture))
	Thumb:SetVertexColor(123 / 255, 132 / 255, 137 / 255)

	self:EnableMouseWheel(true)
	self:SetScript("OnMouseWheel", WindowOnMouseWheel)

	self.Scroll = Scroll
	self.SetOffset = SetOffset
	self.SetOffsetByDelta = SetOffsetByDelta
	self.ScrollBar = ScrollBar

	self:SetOffset(1)

	ScrollBar:Show()

	for i = 1, #self.Widgets do
		if self.Widgets[i].IsSection then
			self.Widgets[i]:SetWidth((WidgetListWidth - WidgetHeight) - (Spacing * 3))
		end
	end
end

GUI.DisplayWindow = function(self, name)
	if _G.KKUI_Credits and _G.KKUI_Credits:IsShown() then
		_G.KKUI_Credits:Hide()
		_G.KKUI_Credits.Move:Stop()

		local Window = GUI:GetWindow(LastActiveWindow)

		Window:Show()
		Window.Button.Selected:Show()

		return
	end

	for WindowName, Window in pairs(self.Windows) do
		if WindowName ~= name then
			Window:Hide()

			if Window.Button.Selected:IsShown() then
				Window.Button.Selected:Hide()
			end
		else
			if not Window.Sorted then
				SortWidgets(Window)

				if #Window.Widgets > self.WindowCount then
					AddScrollBar(Window)
				end
			end

			Window:Show()
			Window.Button.Selected:Show()

			LastActiveWindow = WindowName
		end
	end

	CloseLastDropdown()
end

local MenuButtonOnMouseUp = function(self)
	self.Parent:DisplayWindow(self.Name)
end

local MenuButtonOnEnter = function(self)
	self.Highlight:Show()
end

local MenuButtonOnLeave = function(self)
	self.Highlight:Hide()
end

GUI.CreateWindow = function(self, name, default)
	if self.Windows[name] then
		return
	end

	self.WindowCount = self.WindowCount or 0

	local Button = CreateFrame("Frame", nil, self.ButtonList)
	Button:SetSize(MenuButtonWidth, MenuButtonHeight)
	Button:CreateBorder()
	Button:SetScript("OnMouseUp", MenuButtonOnMouseUp)
	Button:SetScript("OnEnter", MenuButtonOnEnter)
	Button:SetScript("OnLeave", MenuButtonOnLeave)
	Button.Name = name
	Button.Parent = self

	Button.Highlight = Button:CreateTexture(nil, "OVERLAY")
	Button.Highlight:SetAllPoints()
	Button.Highlight:SetTexture(K.GetTexture(C["General"].Texture))
	Button.Highlight:SetVertexColor(R, G, B, 0.3)
	Button.Highlight:Hide()

	Button.Selected = Button:CreateTexture(nil, "OVERLAY")
	Button.Selected:SetPoint("TOPLEFT", Button, 1, -1)
	Button.Selected:SetPoint("BOTTOMRIGHT", Button, -1, 1)
	Button.Selected:SetTexture(K.GetTexture(C["General"].Texture))
	Button.Selected:SetVertexColor(R * 0.7, G * 0.7, B * 0.7, 0.5)
	Button.Selected:Hide()

	Button.Label = Button:CreateFontString(nil, "OVERLAY")
	Button.Label:SetPoint("CENTER", Button, 0, 0)
	Button.Label:SetWidth(MenuButtonWidth - (Spacing * 2))
	Button.Label:SetFontObject(K.UIFont)
	Button.Label:SetText(name)

	tinsert(self.Buttons, Button)

	local Window = CreateFrame("Frame", nil, self)
	Window:SetWidth(WidgetListWidth)
	Window:SetPoint("TOPRIGHT", self.Header, "BOTTOMRIGHT", 0, -(Spacing - 1))
	Window:SetPoint("BOTTOMRIGHT", self.Footer, "TOPRIGHT", 0, (Spacing - 1))
	Window:CreateBorder()
	Window.Button = Button
	Window.Widgets = {}
	Window.Offset = 0
	Window:Hide()

	self.Windows[name] = Window

	for key, func in pairs(self.Widgets) do
		Window[key] = func
	end

	if default then
		self.DefaultWindow = name
	end

	self.WindowCount = self.WindowCount + 1

	return Window
end

GUI.GetWindow = function(self, name)
	if self.Windows[name] then
		return self.Windows[name]
	else
		return self.Windows[self.DefaultWindow]
	end
end

local CloseOnEnter = function(self)
	self.Texture:SetVertexColor(1, 0.2, 0.2)
end

local CloseOnLeave = function(self)
	self.Texture:SetVertexColor(1, 1, 1)
end

local CloseOnMouseUp = function()
	GUI:Toggle()
end

local CreditLineHeight = 20

local function SetUpCredits(frame)
	frame.Lines = {}

	for i = 1, #CreditLines do
		local entry = CreditLines[i]
		local Line = CreateFrame("Frame", nil, frame)
		Line:SetSize(frame:GetWidth(), CreditLineHeight)

		Line.Text = Line:CreateFontString(nil, "OVERLAY")
		Line.Text:SetPoint("CENTER", Line, 0, 0)
		Line.Text:SetFontObject(K.UIFont)
		Line.Text:SetFont(select(1, Line.Text:GetFont()), 16, select(3, Line.Text:GetFont()))
		Line.Text:SetJustifyH("CENTER")

		if entry.type == "header" then
			Line.Text:SetText(entry.text)
			if entry.color then
				Line.Text:SetTextColor(tonumber(entry.color:sub(1, 2), 16) / 255, tonumber(entry.color:sub(3, 4), 16) / 255, tonumber(entry.color:sub(5, 6), 16) / 255)
			end
		elseif entry.type == "name" then
			if entry.class then
				Line.Text:SetTextColor(K.ClassColors[entry.class].r, K.ClassColors[entry.class].g, K.ClassColors[entry.class].b)
			elseif entry.color then
				Line.Text:SetTextColor(tonumber(entry.color:sub(1, 2), 16) / 255, tonumber(entry.color:sub(3, 4), 16) / 255, tonumber(entry.color:sub(5, 6), 16) / 255)
			end
			Line.Text:SetText(entry.text)
			if entry.addOn then
				Line.Text:SetText(Line.Text:GetText() .. " - " .. entry.addOn)
			end
		end

		if i == 1 then
			Line:SetPoint("TOP", frame, 0, -1)
		else
			Line:SetPoint("TOP", frame.Lines[i - 1], "BOTTOM", 0, 0)
		end

		tinsert(frame.Lines, Line)
	end

	frame:SetHeight(#frame.Lines * CreditLineHeight)
end

local ShowCreditFrame = function()
	local Window = GUI:GetWindow(LastActiveWindow)

	Window:Hide()

	_G.KKUI_Credits:Show()
	_G.KKUI_Credits.Move:Play()
end

local HideCreditFrame = function()
	_G.KKUI_Credits:Hide()
	_G.KKUI_Credits.Move:Stop()

	local Window = GUI:GetWindow(LastActiveWindow)

	Window:Show()
	Window.Button.Selected:Show()
end

local ToggleCreditsFrame = function()
	if _G.KKUI_Credits:IsShown() then
		HideCreditFrame()
	else
		ShowCreditFrame()
	end
end

local function CreateContactEditBox(parent, width, height)
	local eb = CreateFrame("EditBox", nil, parent)
	eb:SetSize(width, height)
	eb:SetAutoFocus(false)
	eb:SetTextInsets(5, 5, 0, 0)
	eb:SetFontObject(K.UIFont)

	eb.bg = CreateFrame("Frame", nil, eb)
	eb.bg:SetAllPoints()
	eb.bg:SetFrameLevel(eb:GetFrameLevel())
	eb.bg:CreateBorder()

	eb:SetScript("OnEscapePressed", function(self)
		self:ClearFocus()
	end)

	eb:SetScript("OnEnterPressed", function(self)
		self:ClearFocus()
	end)

	eb.Type = "EditBox"
	return eb
end

local CreateContactBox = function(parent, text, url, index)
	K.CreateFontString(parent, 14, text, "", "system", "TOP", 0, -50 - (index - 1) * 60)
	local box = CreateContactEditBox(parent, 250, 24)
	box:SetPoint("TOP", 0, -70 - (index - 1) * 60)
	box.url = url
	box:SetText(box.url)
	box:HighlightText()

	box:SetScript("OnTextChanged", function(self)
		self:SetText(self.url)
		self:HighlightText()
	end)

	box:SetScript("OnCursorChanged", function(self)
		self:SetText(self.url)
		self:HighlightText()
	end)
end

local AddContactFrame = function()
	if GUI.ContactFrame then
		GUI.ContactFrame:Show()
		return
	end

	local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetSize(300, 390)
	frame:SetPoint("CENTER")
	frame:CreateBorder()

	local frameLogo = frame:CreateTexture(nil, "OVERLAY")
	frameLogo:SetSize(512, 256)
	frameLogo:SetBlendMode("ADD")
	frameLogo:SetAlpha(0.07)
	frameLogo:SetTexture(C["Media"].Textures.LogoTexture)
	frameLogo:SetPoint("CENTER", frame, "CENTER", 0, 0)

	K.CreateFontString(frame, 16, "Contact Me", "", true, "TOP", 0, -10)
	local ll = CreateFrame("Frame", nil, frame)
	ll:SetPoint("TOP", -40, -32)
	K.CreateGF(ll, 80, 1, "Horizontal", 0.7, 0.7, 0.7, 0, 0.7)
	ll:SetFrameStrata("HIGH")
	local lr = CreateFrame("Frame", nil, frame)
	lr:SetPoint("TOP", 40, -32)
	K.CreateGF(lr, 80, 1, "Horizontal", 0.7, 0.7, 0.7, 0.7, 0)
	lr:SetFrameStrata("HIGH")

	CreateContactBox(frame, "|CFFee653aCurse|r", "https://www.curseforge.com/members/kkthnxtv", 1)
	CreateContactBox(frame, "|CFF666aa7WowInterface|r", "https://www.wowinterface.com/forums/member.php?action=getinfo&userid=303422", 2)
	CreateContactBox(frame, "|CFFf6f8faGitHub|r", "https://github.com/Kkthnx-Wow/KkthnxUI", 3)
	CreateContactBox(frame, "|CFF7289DADiscord|r", "https://discord.gg/Rc9wcK9cAB", 4)
	CreateContactBox(frame, "|CFF6441A4Twitch|r", "https://www.twitch.tv/kkthnxtv", 5)

	local back = CreateFrame("Button", nil, frame)
	back:SetSize(120, 20)
	back:SetPoint("BOTTOM", 0, 15)
	back:SkinButton()
	back.text = K.CreateFontString(back, 12, OKAY, "", true)
	back:SetScript("OnClick", function()
		frame:Hide()
		if not GUI:IsShown() then -- Show our GUI again after they click the okay button (If our GUI isn't shown again by that time)
			GUI:Toggle()
		end
	end)

	GUI.ContactFrame = frame
end

GUI.Enable = function(self)
	if self.Created then
		return
	end

	-- Main Window
	self:SetFrameStrata("DIALOG")
	self:SetWidth(WindowWidth)
	self:SetPoint("CENTER", UIParent, 0, 0)
	self:SetAlpha(0)
	K.CreateMoverFrame(self)
	self:Hide()

	-- Animation
	self.Fade = CreateAnimationGroup(self)

	self.FadeIn = self.Fade:CreateAnimation("Fade")
	self.FadeIn:SetDuration(0.2)
	self.FadeIn:SetChange(1)
	self.FadeIn:SetEasing("in-sinusoidal")

	self.FadeOut = self.Fade:CreateAnimation("Fade")
	self.FadeOut:SetDuration(0.2)
	self.FadeOut:SetChange(0)
	self.FadeOut:SetEasing("out-sinusoidal")
	self.FadeOut:SetScript("OnFinished", function(self)
		self:GetParent():Hide()

		if _G.KKUI_Credits:IsShown() then
			HideCreditFrame()
		end
	end)

	-- Header
	self.Header = CreateFrame("Frame", nil, self)
	self.Header:SetFrameStrata("DIALOG")
	self.Header:SetSize(HeaderWidth, HeaderHeight)
	self.Header:SetPoint("TOP", self, 0, -Spacing)
	self.Header:CreateBorder()

	self.Header.Label = self.Header:CreateFontString(nil, "OVERLAY")
	self.Header.Label:SetPoint("CENTER", self.Header, 0, 0)
	self.Header.Label:SetFontObject(K.UIFont)
	self.Header.Label:SetFont(select(1, self.Header.Label:GetFont()), 16, select(3, self.Header.Label:GetFont()))
	self.Header.Label:SetText(HeaderText)

	-- Footer
	self.Footer = CreateFrame("Frame", nil, self)
	self.Footer:SetFrameStrata("DIALOG")
	self.Footer:SetSize(HeaderWidth, HeaderHeight)
	self.Footer:SetPoint("BOTTOM", self, 0, Spacing)

	local FooterButtonWidth = ((HeaderWidth / 4) - Spacing) + 1

	-- Apply button
	local Apply = CreateFrame("Frame", nil, self.Footer)
	Apply:SetSize(FooterButtonWidth + 3, HeaderHeight)
	Apply:SetPoint("LEFT", self.Footer, 0, 0)
	Apply:CreateBorder()
	Apply:SetScript("OnMouseDown", ButtonOnMouseDown)
	Apply:SetScript("OnMouseUp", ButtonOnMouseUp)
	Apply:SetScript("OnEnter", ButtonOnEnter)
	Apply:SetScript("OnLeave", ButtonOnLeave)
	Apply:HookScript("OnMouseUp", function()
		K.SetupUIScale()
		if InCombatLockdown() then
			UIErrorsFrame:AddMessage(K.InfoColor .. ERR_NOT_IN_COMBAT)
			return
		end

		if GUI:IsShown() then
			GUI:Toggle()
		end

		StaticPopup_Show("KKUI_CHANGES_RELOAD")
	end)

	Apply.Highlight = Apply:CreateTexture(nil, "OVERLAY")
	Apply.Highlight:SetAllPoints()
	Apply.Highlight:SetTexture(K.GetTexture(C["General"].Texture))
	Apply.Highlight:SetVertexColor(123 / 255, 132 / 255, 137 / 255)
	Apply.Highlight:SetAlpha(0)

	Apply.Middle = Apply:CreateFontString(nil, "OVERLAY")
	Apply.Middle:SetPoint("CENTER", Apply, 0, 0)
	Apply.Middle:SetWidth(FooterButtonWidth - (Spacing * 2))
	Apply.Middle:SetFontObject(K.UIFont)
	Apply.Middle:SetJustifyH("CENTER")
	Apply.Middle:SetText("|CFF00CC4CApply|r")

	-- Reset button
	local Reset = CreateFrame("Frame", nil, self.Footer)
	Reset:SetSize(FooterButtonWidth - 1, HeaderHeight)
	Reset:SetPoint("LEFT", Apply, "RIGHT", (Spacing - 1), 0)
	Reset:CreateBorder()
	Reset:SetScript("OnMouseDown", ButtonOnMouseDown)
	Reset:SetScript("OnMouseUp", ButtonOnMouseUp)
	Reset:SetScript("OnEnter", ButtonOnEnter)
	Reset:SetScript("OnLeave", ButtonOnLeave)
	Reset:HookScript("OnMouseUp", function()
		_G.StaticPopup_Show("KKUI_RESET_DATA")
	end)

	Reset.Highlight = Reset:CreateTexture(nil, "OVERLAY")
	Reset.Highlight:SetAllPoints()
	Reset.Highlight:SetTexture(K.GetTexture(C["General"].Texture))
	Reset.Highlight:SetVertexColor(123 / 255, 132 / 255, 137 / 255)
	Reset.Highlight:SetAlpha(0)

	Reset.Middle = Reset:CreateFontString(nil, "OVERLAY")
	Reset.Middle:SetPoint("CENTER", Reset, 0, 0)
	Reset.Middle:SetWidth(FooterButtonWidth - (Spacing * 2))
	Reset.Middle:SetFontObject(K.UIFont)
	Reset.Middle:SetJustifyH("CENTER")
	Reset.Middle:SetText(K.SystemColor .. "Reset UI|r")

	-- Move button
	local Move = CreateFrame("Frame", nil, self.Footer)
	Move:SetSize(FooterButtonWidth + 1, HeaderHeight)
	Move:SetPoint("LEFT", Reset, "RIGHT", (Spacing - 1), 0)
	Move:CreateBorder()
	Move:SetScript("OnMouseDown", ButtonOnMouseDown)
	Move:SetScript("OnMouseUp", ButtonOnMouseUp)
	Move:SetScript("OnEnter", ButtonOnEnter)
	Move:SetScript("OnLeave", ButtonOnLeave)
	Move:HookScript("OnMouseUp", function(self)
		self.state = not self.state
		if self.state then
			SlashCmdList["KKUI_MOVEUI"]()
		else
			SlashCmdList["KKUI_LOCKUI"]()
		end
	end)

	Move.Highlight = Move:CreateTexture(nil, "OVERLAY")
	Move.Highlight:SetAllPoints()
	Move.Highlight:SetTexture(K.GetTexture(C["General"].Texture))
	Move.Highlight:SetVertexColor(123 / 255, 132 / 255, 137 / 255)
	Move.Highlight:SetAlpha(0)

	Move.Middle = Move:CreateFontString(nil, "OVERLAY")
	Move.Middle:SetPoint("CENTER", Move, 0, 0)
	Move.Middle:SetWidth(FooterButtonWidth - (Spacing * 2))
	Move.Middle:SetFontObject(K.UIFont)
	Move.Middle:SetJustifyH("CENTER")
	Move.Middle:SetText(K.SystemColor .. "Toggle UI|r")

	-- Credits button
	local Credits = CreateFrame("Frame", nil, self.Footer)
	Credits:SetSize(FooterButtonWidth + 2, HeaderHeight)
	Credits:SetPoint("LEFT", Move, "RIGHT", (Spacing - 1), 0)
	Credits:CreateBorder()
	Credits:SetScript("OnMouseDown", ButtonOnMouseDown)
	Credits:SetScript("OnMouseUp", ButtonOnMouseUp)
	Credits:SetScript("OnEnter", ButtonOnEnter)
	Credits:SetScript("OnLeave", ButtonOnLeave)
	Credits:HookScript("OnMouseUp", ToggleCreditsFrame)

	Credits.Highlight = Credits:CreateTexture(nil, "OVERLAY")
	Credits.Highlight:SetAllPoints()
	Credits.Highlight:SetTexture(K.GetTexture(C["General"].Texture))
	Credits.Highlight:SetVertexColor(123 / 255, 132 / 255, 137 / 255)
	Credits.Highlight:SetAlpha(0)

	Credits.Middle = Credits:CreateFontString(nil, "OVERLAY")
	Credits.Middle:SetPoint("CENTER", Credits, 0, 0)
	Credits.Middle:SetWidth(FooterButtonWidth - (Spacing * 2))
	Credits.Middle:SetFontObject(K.UIFont)
	Credits.Middle:SetJustifyH("CENTER")
	Credits.Middle:SetText(K.InfoColor .. "Credits|r")

	-- CVars button
	local ResetCVars = CreateFrame("Frame", nil, self.Footer)
	ResetCVars:SetSize(FooterButtonWidth + 3, HeaderHeight)
	ResetCVars:SetPoint("LEFT", Apply, 0, -28)
	ResetCVars:CreateBorder()
	ResetCVars:SetScript("OnMouseDown", ButtonOnMouseDown)
	ResetCVars:SetScript("OnMouseUp", ButtonOnMouseUp)
	ResetCVars:SetScript("OnEnter", ButtonOnEnter)
	ResetCVars:SetScript("OnLeave", ButtonOnLeave)
	ResetCVars:HookScript("OnMouseUp", function()
		_G.StaticPopup_Show("KKUI_RESET_CVARS")
	end)

	ResetCVars.Highlight = ResetCVars:CreateTexture(nil, "OVERLAY")
	ResetCVars.Highlight:SetAllPoints()
	ResetCVars.Highlight:SetTexture(K.GetTexture(C["General"].Texture))
	ResetCVars.Highlight:SetVertexColor(123 / 255, 132 / 255, 137 / 255)
	ResetCVars.Highlight:SetAlpha(0)

	ResetCVars.Middle = ResetCVars:CreateFontString(nil, "OVERLAY")
	ResetCVars.Middle:SetPoint("CENTER", ResetCVars, 0, 0)
	ResetCVars.Middle:SetWidth(FooterButtonWidth - (Spacing * 2))
	ResetCVars.Middle:SetFontObject(K.UIFont)
	ResetCVars.Middle:SetJustifyH("CENTER")
	ResetCVars.Middle:SetText(K.SystemColor .. "Reset CVars|r")

	-- Chat Button
	local ResetChat = CreateFrame("Frame", nil, self.Footer)
	ResetChat:SetSize(FooterButtonWidth - 1, HeaderHeight)
	ResetChat:SetPoint("LEFT", Reset, 0, -28)
	ResetChat:CreateBorder()
	ResetChat:SetScript("OnMouseDown", ButtonOnMouseDown)
	ResetChat:SetScript("OnMouseUp", ButtonOnMouseUp)
	ResetChat:SetScript("OnEnter", ButtonOnEnter)
	ResetChat:SetScript("OnLeave", ButtonOnLeave)
	ResetChat:HookScript("OnMouseUp", function()
		_G.StaticPopup_Show("KKUI_RESET_CHAT")
	end)

	ResetChat.Highlight = ResetChat:CreateTexture(nil, "OVERLAY")
	ResetChat.Highlight:SetAllPoints()
	ResetChat.Highlight:SetTexture(K.GetTexture(C["General"].Texture))
	ResetChat.Highlight:SetVertexColor(123 / 255, 132 / 255, 137 / 255)
	ResetChat.Highlight:SetAlpha(0)

	ResetChat.Middle = ResetChat:CreateFontString(nil, "OVERLAY")
	ResetChat.Middle:SetPoint("CENTER", ResetChat, 0, 0)
	ResetChat.Middle:SetWidth(FooterButtonWidth - Spacing)
	ResetChat.Middle:SetFontObject(K.UIFont)
	ResetChat.Middle:SetJustifyH("CENTER")
	ResetChat.Middle:SetText(K.SystemColor .. "Reset Chat|r")

	-- Contact Button
	local ContactMe = CreateFrame("Frame", nil, self.Footer)
	ContactMe:SetSize(FooterButtonWidth, HeaderHeight)
	ContactMe:SetPoint("LEFT", Move, 0, -28)
	ContactMe:CreateBorder()
	ContactMe:SetScript("OnMouseDown", ButtonOnMouseDown)
	ContactMe:SetScript("OnMouseUp", ButtonOnMouseUp)
	ContactMe:SetScript("OnEnter", ButtonOnEnter)
	ContactMe:SetScript("OnLeave", ButtonOnLeave)
	ContactMe:HookScript("OnMouseUp", function()
		if GUI:IsShown() then
			GUI:Toggle()
		end
		AddContactFrame()
	end)

	ContactMe.Highlight = ContactMe:CreateTexture(nil, "OVERLAY")
	ContactMe.Highlight:SetAllPoints()
	ContactMe.Highlight:SetTexture(K.GetTexture(C["General"].Texture))
	ContactMe.Highlight:SetVertexColor(123 / 255, 132 / 255, 137 / 255)
	ContactMe.Highlight:SetAlpha(0)

	ContactMe.Middle = ContactMe:CreateFontString(nil, "OVERLAY")
	ContactMe.Middle:SetPoint("CENTER", ContactMe, 0, 0)
	ContactMe.Middle:SetWidth(FooterButtonWidth - Spacing)
	ContactMe.Middle:SetFontObject(K.UIFont)
	ContactMe.Middle:SetJustifyH("CENTER")
	ContactMe.Middle:SetText(K.SystemColor .. "Contact Me!|r")

	-- Profiles button
	local Profiles = CreateFrame("Frame", nil, self.Footer)
	Profiles:SetSize(FooterButtonWidth + 2, HeaderHeight)
	Profiles:SetPoint("LEFT", Credits, 0, -28)
	Profiles:CreateBorder()
	Profiles:SetScript("OnMouseDown", ButtonOnMouseDown)
	Profiles:SetScript("OnMouseUp", ButtonOnMouseUp)
	Profiles:SetScript("OnEnter", ButtonOnEnter)
	Profiles:SetScript("OnLeave", ButtonOnLeave)
	Profiles:HookScript("OnMouseUp", function()
		if GUI:IsShown() then
			GUI:Toggle()
		end
		K.Profiles:Toggle()
	end)

	Profiles.Highlight = Profiles:CreateTexture(nil, "OVERLAY")
	Profiles.Highlight:SetAllPoints()
	Profiles.Highlight:SetTexture(K.GetTexture(C["General"].Texture))
	Profiles.Highlight:SetVertexColor(123 / 255, 132 / 255, 137 / 255)
	Profiles.Highlight:SetAlpha(0)

	Profiles.Middle = Profiles:CreateFontString(nil, "OVERLAY")
	Profiles.Middle:SetPoint("CENTER", Profiles, 0, 0)
	Profiles.Middle:SetWidth(FooterButtonWidth - (Spacing * 2))
	Profiles.Middle:SetFontObject(K.UIFont)
	Profiles.Middle:SetJustifyH("CENTER")
	Profiles.Middle:SetText(K.InfoColor .. "Profiles|r")

	-- Button list
	self.ButtonList = CreateFrame("Frame", nil, self)
	self.ButtonList:SetWidth(ButtonListWidth)
	self.ButtonList:SetPoint("BOTTOMLEFT", self, Spacing, Spacing)
	self.ButtonList:SetPoint("TOPLEFT", self.Header, "BOTTOMLEFT", 0, -(Spacing - 1))
	self.ButtonList:SetPoint("BOTTOMLEFT", self.Footer, "TOPLEFT", 0, (Spacing - 1))
	self.ButtonList:CreateBorder()

	-- Close
	self.Close = CreateFrame("Frame", nil, self.Header)
	self.Close:SetSize(HeaderHeight, HeaderHeight)
	self.Close:SetPoint("RIGHT", self.Header, 0, 0)
	self.Close:SetScript("OnEnter", CloseOnEnter)
	self.Close:SetScript("OnLeave", CloseOnLeave)
	self.Close:SetScript("OnMouseUp", CloseOnMouseUp)

	self.Close.Texture = self.Close:CreateTexture(nil, "OVERLAY")
	self.Close.Texture:SetPoint("CENTER", self.Close, 0, 0)
	self.Close.Texture:SetSize(20, 20)
	self.Close.Texture:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\CloseButton_32")

	self:UnpackQueue()

	-- Set the frame height
	local Height = (HeaderHeight * 2) + (Spacing + 2) + (self.WindowCount * MenuButtonHeight) + (self.WindowCount * Spacing)
	self:SetHeight(Height)

	if self.DefaultWindow then
		self:DisplayWindow(self.DefaultWindow)
	end

	self:SortMenuButtons()

	-- Create credits
	local CreditFrame = CreateFrame("Frame", "KKUI_Credits", self)
	CreditFrame:SetPoint("TOPRIGHT", self.Header, "BOTTOMRIGHT", 0, -(Spacing - 1))
	CreditFrame:SetPoint("TOPLEFT", self.ButtonList, "TOPRIGHT", (Spacing - 1), 0)
	CreditFrame:SetPoint("BOTTOMRIGHT", self.Footer, "TOPRIGHT", 0, (Spacing - 1))
	CreditFrame:SetPoint("BOTTOMLEFT", self.ButtonList, "BOTTOMRIGHT", (Spacing - 1), 0)
	CreditFrame:SetFrameStrata("DIALOG")
	CreditFrame:CreateBorder()
	CreditFrame:EnableMouse(true)
	CreditFrame:EnableMouseWheel(true)
	CreditFrame:Hide()

	local CreditLogo = CreditFrame:CreateTexture(nil, "OVERLAY")
	CreditLogo:SetSize(512, 256)
	CreditLogo:SetBlendMode("ADD")
	CreditLogo:SetAlpha(0.07)
	CreditLogo:SetTexture(C["Media"].Textures.LogoTexture)
	CreditLogo:SetPoint("CENTER", CreditFrame, "CENTER", 0, 0)

	local ScrollFrame = CreateFrame("ScrollFrame", nil, CreditFrame)
	ScrollFrame:SetPoint("TOPLEFT", CreditFrame, 1, -1)
	ScrollFrame:SetPoint("BOTTOMRIGHT", CreditFrame, -1, 1)

	local Scrollable = CreateFrame("Frame", nil, ScrollFrame)
	Scrollable:SetSize(ScrollFrame:GetSize())

	CreditFrame.Move = CreateAnimationGroup(Scrollable):CreateAnimation("Move")
	CreditFrame.Move:SetDuration(24)
	CreditFrame.Move:SetScript("OnFinished", function(self)
		local Parent = self:GetParent()

		Parent:ClearAllPoints()
		Parent:SetPoint("TOP", ScrollFrame, "BOTTOM", 0, 0)

		self:Play()
	end)

	ScrollFrame:SetScrollChild(Scrollable)

	SetUpCredits(Scrollable)

	CreditFrame.Move:SetOffset(0, (Scrollable:GetHeight() * 2))

	Scrollable:ClearAllPoints()
	Scrollable:SetPoint("TOP", ScrollFrame, "BOTTOM", 0, 0)

	self.Created = true
end

GUI.Toggle = function(self)
	if InCombatLockdown() then
		return
	end

	if self:IsShown() then
		self.FadeOut:Play()
	else
		self:Show()
		self.FadeIn:Play()
	end
end

GUI.PLAYER_REGEN_DISABLED = function(self)
	if self:IsShown() then
		self:SetAlpha(0)
		self:Hide()
		self.CombatClosed = true
	end
end

GUI.PLAYER_REGEN_ENABLED = function(self)
	if self.CombatClosed then
		self:Show()
		self:SetAlpha(1)
		self.CombatClosed = false
	end
end

GUI.SetProfile = function(self)
	local Dropdown = self:GetParent()
	local Profile = Dropdown.Current:GetText()

	if Profile and Profile ~= K.Realm .. "-" .. K.Name then
		MySelectedProfile = Profile

		GUI:Toggle()

		_G.StaticPopup_Show("KKUI_SWITCH_PROFILE")
	end
end

GUI:RegisterEvent("PLAYER_REGEN_DISABLED")
GUI:RegisterEvent("PLAYER_REGEN_ENABLED")
GUI:SetScript("OnEvent", function(self, event)
	self[event](self, event)
end)

K.GUI = GUI
