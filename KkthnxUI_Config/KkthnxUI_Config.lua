-- Sourced: Tukui (Tukz)
-- Edited: KkthnxUI (Kkthnx)

-- Lua API
local _G = _G
local math_floor = math.floor
local select = select
local string_find = string.find
local string_format = string.format
local string_lower = string.lower
local table_insert = table.insert
local table_sort = table.sort
local tonumber = tonumber
local type = type
local unpack = unpack

-- Wow API
local APPLY = _G.APPLY
local CLOSE = _G.CLOSE
local COLOR = _G.COLOR
local CreateFrame = _G.CreateFrame
local GameMenuFrame = _G.GameMenuFrame
local GameTooltip = _G.GameTooltip
local GetLocale = _G.GetLocale
local GetRealmName = _G.GetRealmName
local HideUIPanel = _G.HideUIPanel
local RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS
local ReloadUI = _G.ReloadUI
local ShowUIPanel = _G.ShowUIPanel
local UIParent = _G.UIParent
local UnitClass = _G.UnitClass
local UnitName = _G.UnitName
local UNKNOWN = _G.UNKNOWN

local KkthnxUIConfig = CreateFrame("Frame", "KkthnxUIConfig", UIParent)
KkthnxUIConfig.Functions = {}
local GroupPages = {}
local Locale = GetLocale()
local Class = select(2, UnitClass("player"))
local Colors = CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[Class] or RAID_CLASS_COLORS[Class]

local DropDownMenus = {}

if (Locale == "enGB") then
	Locale = "enUS"
end

function KkthnxUIConfig:SetOption(group, option, value)
	local C
	local Realm = GetRealmName()
	local Name = UnitName("player")

	if (KkthnxUIConfigPerAccount) then
		C = KkthnxUIConfigShared.Account
	else
		C = KkthnxUIConfigShared[Realm][Name]
	end

	if (not C[group]) then
		C[group] = {}
	end

	C[group][option] = value -- Save our setting

	if (not self.Functions[group]) then
		return
	end

	if self.Functions[group][option] then
		self.Functions[group][option](value) -- Run the associated function
	end
end

function KkthnxUIConfig:SetCallback(group, option, func)
	if (not self.Functions[group]) then
		self.Functions[group] = {}
	end

	self.Functions[group][option] = func -- Set a function to call
end

KkthnxUIConfig.ColorDefaults = {
	-- ActionBar
	["ActionBar"] = {
		["OutOfMana"] = {0.5, 0.5, 1.0},
		["OutOfRange"] = {0.8, 0.1, 0.1}
	},
	-- General
	["General"] = {
		["TexturesColor"] = {0.31, 0.31, 0.31}
	},
	-- Chat
	["Chat"] = {
		["LinkColor"] = {0.08, 1, 0.36}
	},
	-- DataBars
	["DataBars"] = {
		["AzeriteColor"] = {.901, .8, .601},
		["ExperienceColor"] = {0, 0.4, 1, .8},
		["ExperienceRestedColor"] = {1, 0, 1, 0.2},
	},
	-- Nameplates
	["Nameplates"] = {
		["BadColor"] = {1, 0, 0},
		["GoodColor"] = {0.2, 0.8, 0.2},
		["NearColor"] = {1, 1, 0},
		["OffTankColor"] = {0, 0.5, 1}
	},
	-- Unitframe
	["Unitframe"] = {
		["CastbarTicksColor"] = {0, 0, 0, 0.8}
	},
}

function KkthnxUIConfig:UpdateColorDefaults()
	self.ColorDefaults.ActionBar.OutOfMana = {0.5, 0.5, 1.0}
	self.ColorDefaults.ActionBar.OutOfRange = {0.8, 0.1, 0.1}
	self.ColorDefaults.Chat.LinkColor = {0.08, 1, 0.36}
	self.ColorDefaults.DataBars.AzeriteColor = {.901, .8, .601}
	self.ColorDefaults.DataBars.ExperienceColor = {0, 0.4, 1, .8}
	self.ColorDefaults.DataBars.ExperienceRestedColor = {1, 0, 1, 0.2}
	self.ColorDefaults.General.TexturesColor = {0.31, 0.31, 0.31}
	self.ColorDefaults.Nameplates.BadColor = {1, 0, 0}
	self.ColorDefaults.Nameplates.GoodColor = {0.2, 0.8, 0.2}
	self.ColorDefaults.Nameplates.NearColor = {1, 1, 0}
	self.ColorDefaults.Nameplates.OffTankColor = {0, 0.5, 1}
	self.ColorDefaults.Unitframe.CastbarTicksColor = {0, 0, 0, 0.8}
end

-- Filter unwanted groups
KkthnxUIConfig.Filter = {
	["FilgerSpells"] = true,
	["Media"] = true,
	["OrderedIndex"] = true,
}

local function GetOrderedIndex(t)
	local OrderedIndex = {}

	for key in pairs(t) do
		table_insert(OrderedIndex, key)
	end

	table_sort(OrderedIndex)

	return OrderedIndex
end

local function OrderedNext(t, state)
	local Key

	if (state == nil) then
		t.OrderedIndex = GetOrderedIndex(t)
		Key = t.OrderedIndex[1]

		return Key, t[Key]
	end

	Key = nil

	for i = 1, #t.OrderedIndex do
		if (t.OrderedIndex[i] == state) then
			Key = t.OrderedIndex[i + 1]
		end
	end

	if Key then
		return Key, t[Key]
	end

	t.OrderedIndex = nil

	return
end

local function PairsByKeys(t)
	return OrderedNext, t, nil
end

-- Create custom controls for options.
local function ControlOnEnter(self)
	local K = KkthnxUI[1]

	GameTooltip:SetOwner(self, "NONE")
	GameTooltip:SetPoint(K.GetAnchors(self))
	GameTooltip:ClearLines()
	GameTooltip:AddLine(self.Tooltip, nil, nil, nil, 1)
	GameTooltip:Show()
end

local function ControlOnLeave()
	GameTooltip:Hide()
end

local function SetControlInformation(control, group, option)
	if (not KkthnxUIConfig[Locale] or not KkthnxUIConfig[Locale][group]) then
		control.Label:SetText(option or UNKNOWN) -- Set what info we can for it. Fallback if needed.

		return
	end

	if (not KkthnxUIConfig[Locale][group][option]) then
		control.Label:SetText(option or UNKNOWN) -- Set what info we can for it. Fallback if needed.
	end

	local Info = KkthnxUIConfig[Locale][group][option]

	if (not Info) then
		return
	end

	control.Label:SetText(Info.Name)

	if control.Box then
		control.Box.Tooltip = Info.Desc
		control.Box:HookScript("OnEnter", ControlOnEnter)
		control.Box:HookScript("OnLeave", ControlOnLeave)
	else
		control.Tooltip = Info.Desc
		control:HookScript("OnEnter", ControlOnEnter)
		control:HookScript("OnLeave", ControlOnLeave)
	end
end

local function EditBoxOnMouseDown(self)
	self:SetAutoFocus(true)
end

local function EditBoxOnEditFocusLost(self)
	self:SetAutoFocus(false)
end

local function EditBoxOnTextChange(self)
	local Value = self:GetText()

	if (type(tonumber(Value)) == "number") then -- Assume we want a number, not a string
		Value = tonumber(Value)
	end

	KkthnxUIConfig:SetOption(self.Group, self.Option, Value)
end

local function EditBoxOnEnterPressed(self)
	self:SetAutoFocus(false)
	self:ClearFocus()

	local Value = self:GetText()

	if (type(tonumber(Value)) == "number") then -- Assume we want a number, not a string
		Value = tonumber(Value)
	end

	KkthnxUIConfig:SetOption(self.Group, self.Option, Value)
end

local function EditBoxOnMouseWheel(self, delta)
	local Number = tonumber(self:GetText())

	if (delta > 0) then
		Number = Number + 2
	else
		Number = Number - 2
	end

	self:SetText(Number)
end

local function ButtonOnClick(self)
	if self.Toggled then
		self.Tex:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\UI-CheckBox-Check-Disabled")
		self.Tex:SetAlpha(0.25)
		self.Toggled = false
	else
		self.Tex:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\UI-CheckBox-Check")
		self.Tex:SetAlpha(1)
		self.Toggled = true
	end

	KkthnxUIConfig:SetOption(self.Group, self.Option, self.Toggled)
end

local function ButtonCheck(self)
	self.Toggled = true
	self.Tex:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\UI-CheckBox-Check")
	self.Tex:SetAlpha(1)
end

local function ButtonUncheck(self)
	self.Toggled = false
	self.Tex:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\UI-CheckBox-Check-Disabled")
	self.Tex:SetAlpha(0.25)
end

local function ResetColor(self)
	local Defaults = KkthnxUIConfig.ColorDefaults

	if (Defaults[self.Group] and Defaults[self.Group][self.Option]) then
		local Default = Defaults[self.Group][self.Option]

		-- Count the alpha here. If a color doesnt use the alpha it will just ignore it.
		-- If we do not count for alpha we will always have our color default to 1 for alpha.
		self.Color:SetVertexColor(Default[1], Default[2], Default[3], Default[4])
		KkthnxUIConfig:SetOption(self.Group, self.Option, {Default[1], Default[2], Default[3], Default[4]})
	end
end

local function SetSelectedValue(dropdown, value)
	local Key

	if (dropdown.Type == "Custom") then
		for k, v in pairs(dropdown.Info.Options) do
			if (v == value) then
				Key = k

				break
			end
		end
	end

	if Key then
		value = Key
	end

	if dropdown[value] then
		if (dropdown.Type == "Texture") then
			dropdown.CurrentTex:SetTexture(dropdown[value])
		elseif (dropdown.Type == "Font") then
			dropdown.Current:SetFontObject(dropdown[value])
		end

		dropdown.Current:SetText((value))
	end
end

local function SetIconUp(self)
	self:ClearAllPoints()
	self:SetPoint("CENTER", self.Owner, 1, -4)
	self:SetTexture("Interface\\BUTTONS\\Arrow-Down-Up")
end

local function SetIconDown(self)
	self:ClearAllPoints()
	self:SetPoint("CENTER", self.Owner, 1, 1)
	self:SetTexture("Interface\\BUTTONS\\Arrow-Up-Up")
end

local function ListItemOnClick(self)
	local List = self.Owner
	local DropDown = List.Owner

	if (DropDown.Type == "Texture") then
		DropDown.CurrentTex:SetTexture(self.Value)
	elseif (DropDown.Type == "Font") then
		DropDown.Current:SetFontObject(self.Value)
	else
		DropDown.Info.Value = self.Value
	end

	DropDown.Current:SetText(self.Name)

	SetIconUp(DropDown.Button.Tex)
	List:Hide()

	if (DropDown.Type == "Custom") then
		KkthnxUIConfig:SetOption(DropDown._Group, DropDown._Option, DropDown.Info)
	else
		KkthnxUIConfig:SetOption(DropDown._Group, DropDown._Option, self.Name)
	end
end

local function ListItemOnEnter(self)
	self.Hover:SetVertexColor(1, 0.82, 0, 0.4)
end

local function ListItemOnLeave(self)
	self.Hover:SetVertexColor(1, 0.82, 0, 0)
end

local function AddListItems(self, info)
	local DropDown = self.Owner
	local Type = DropDown.Type
	local Height = 3
	local LastItem

	for Name, Value in pairs(info) do
		local Button = CreateFrame("Button", nil, self)
		Button:SetSize(self:GetWidth(), 20)

		local Text = Button:CreateFontString(nil, "OVERLAY")
		Text:SetPoint("LEFT", Button, 4, 0)

		if (Type ~= "Font") then
			local C = KkthnxUI[2]

			Text:SetFont(C["Media"].Font, 12)
			Text:SetShadowColor(0, 0, 0)
			Text:SetShadowOffset(1.25, -1.25)
		else
			Text:SetFontObject(Value)
		end

		Text:SetText(Name)

		if (Type == "Texture") then
			local Bar = self:CreateTexture(nil, "ARTWORK")
			Bar:SetAllPoints(Button)
			Bar:SetTexture(Value)
			Bar:SetVertexColor(Colors.r, Colors.g, Colors.b)

			Button.Bar = Bar
		end

		local Hover = Button:CreateTexture(nil, "OVERLAY")
		Hover:SetTexture("Interface\\Buttons\\UI-Listbox-Highlight2")
		Hover:SetBlendMode("ADD")
		Hover:SetAllPoints()
		Button:SetHighlightTexture(Hover)

		Button.Owner = self
		Button.Name = Name
		Button.Text = Text
		Button.Value = Value
		Button.Hover = Hover

		Button:SetScript("OnClick", ListItemOnClick)
		Button:SetScript("OnEnter", ListItemOnEnter)
		Button:SetScript("OnLeave", ListItemOnLeave)

		if (not LastItem) then
			Button:SetPoint("TOP", self, 0, 0)
		else
			Button:SetPoint("TOP", LastItem, "BOTTOM", 0, -1)
		end

		DropDown[Name] = Value

		LastItem = Button
		Height = Height + 20
	end

	self:SetHeight(Height)
end

local function CloseOtherLists(self)
	for i = 1, #DropDownMenus do
		local Menu = DropDownMenus[i]
		local List = Menu.List

		if (self ~= Menu and List:IsShown()) then
			List:Hide()
			SetIconUp(Menu.Button.Tex)
		end
	end
end

local function CloseList(self)
	for i = 1, #DropDownMenus do
		local Menu = DropDownMenus[i]
		local List = Menu.List

		if (self == List and self:IsShown()) then
			self:Hide()
			SetIconUp(Menu.Button.Tex)
			return
		end
	end
end

local function DropDownButtonOnClick(self)
	local DropDown = self.Owner
	local Texture = self.Tex

	if DropDown.List then
		local List = DropDown.List
		CloseOtherLists(DropDown)

		if List:IsVisible() then
			DropDown.List:Hide()
			SetIconUp(Texture)
		else
			DropDown.List:Show()
			SetIconDown(Texture)
		end
	end
end

local function SliderOnValueChanged(self, value)
	if (not self.ScrollFrame.Set) and (self.ScrollFrame:GetVerticalScrollRange() ~= 0) then
		self:SetMinMaxValues(0, math_floor(self.ScrollFrame:GetVerticalScrollRange()) - 1)
		self.ScrollFrame.Set = true
	end

	self.ScrollFrame:SetVerticalScroll(value)
end

local function SliderOnMouseWheel(self, delta)
	local Value = self:GetValue()

	if (delta > 0) then
		Value = Value - 10
	else
		Value = Value + 10
	end

	self:SetValue(Value)
end

local function CreateConfigButton(parent, group, option, value)
	local K = KkthnxUI[1]
	local C = KkthnxUI[2]

	local Button = CreateFrame("Button", nil, parent)

	Button.Backgrounds = Button:CreateTexture(nil, "BACKGROUND", -1)
	Button.Backgrounds:SetAllPoints()
	Button.Backgrounds:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

	Button.Borders = CreateFrame("Frame", nil, Button)
	Button.Borders:SetAllPoints()
	K.CreateBorder(Button.Borders)

	Button:SetSize(18, 18)
	Button.Toggled = false
	Button:SetScript("OnClick", ButtonOnClick)
	Button.Type = "Button"

	Button.Tex = Button:CreateTexture(nil, "OVERLAY")
	Button.Tex:SetAllPoints()

	Button.Check = ButtonCheck
	Button.Uncheck = ButtonUncheck

	Button.Group = group
	Button.Option = option

	Button.Label = Button:CreateFontString(nil, "OVERLAY")
	Button.Label:SetFont(C["Media"].Font, 12)
	Button.Label:SetPoint("LEFT", Button, "RIGHT", 5, 0)
	Button.Label:SetShadowColor(0, 0, 0)
	Button.Label:SetShadowOffset(1.25, -1.25)

	if value then
		Button:Check()
	else
		Button:Uncheck()
	end

	return Button
end

local function CreateConfigEditBox(parent, group, option, value, max)
	local K = KkthnxUI[1]
	local C = KkthnxUI[2]

	local EditBox = CreateFrame("Frame", nil, parent)
	EditBox:SetSize(50, 18)

	EditBox.Backgrounds = EditBox:CreateTexture(nil, "BACKGROUND", -1)
	EditBox.Backgrounds:SetAllPoints()
	EditBox.Backgrounds:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

	EditBox.Borders = CreateFrame("Frame", nil, EditBox)
	EditBox.Borders:SetAllPoints()
	K.CreateBorder(EditBox.Borders)

	EditBox.Type = "EditBox"

	EditBox.Box = CreateFrame("EditBox", nil, EditBox)
	EditBox.Box:SetFont(C["Media"].Font, 12)
	EditBox.Box:SetShadowOffset(1.25, -1.25)
	EditBox.Box:SetPoint("TOPLEFT", EditBox, 4, -2)
	EditBox.Box:SetPoint("BOTTOMRIGHT", EditBox, -4, 2)
	EditBox.Box:SetMaxLetters(max or 4)
	EditBox.Box:SetAutoFocus(false)
	EditBox.Box:EnableKeyboard(true)
	EditBox.Box:EnableMouse(true)
	EditBox.Box:SetScript("OnMouseDown", EditBoxOnMouseDown)
	EditBox.Box:SetScript("OnEscapePressed", EditBoxOnEnterPressed)
	EditBox.Box:SetScript("OnEnterPressed", EditBoxOnEnterPressed)
	EditBox.Box:SetScript("OnEditFocusLost", EditBoxOnEditFocusLost)
	EditBox.Box:SetScript("OnTextChanged", EditBoxOnTextChange)
	EditBox.Box:SetText(value)

	if (not max) then
		EditBox.Box:EnableMouseWheel(true)
		EditBox.Box:SetScript("OnMouseWheel", EditBoxOnMouseWheel)
	end

	EditBox.Label = EditBox:CreateFontString(nil, "OVERLAY")
	EditBox.Label:SetFont(C["Media"].Font, 12)
	EditBox.Label:SetPoint("LEFT", EditBox, "RIGHT", 5, 0)
	EditBox.Label:SetShadowColor(0, 0, 0)
	EditBox.Label:SetShadowOffset(1.25, -1.25)

	EditBox.Box.Group = group
	EditBox.Box.Option = option
	EditBox.Box.Label = EditBox.Label

	return EditBox
end

local function CreateConfigColorPicker(parent, group, option, value)
	local K = KkthnxUI[1]
	local C = KkthnxUI[2]

	local ConfigTexture = K.GetTexture(C["General"].Texture)

	local Button = CreateFrame("Button", nil, parent)

	Button.Backgrounds = Button:CreateTexture(nil, "BACKGROUND", -1)
	Button.Backgrounds:SetAllPoints()
	Button.Backgrounds:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

	Button.Borders = CreateFrame("Frame", nil, Button)
	Button.Borders:SetAllPoints()
	K.CreateBorder(Button.Borders)

	Button:SetSize(50, 18)
	Button.Colors = value
	Button.Type = "Color"
	Button.Group = group
	Button.Option = option
	Button:RegisterForClicks("AnyUp")
	Button:SetScript(
	"OnClick",
	function(self, button)
		if (button == "RightButton") then
			ResetColor(self)
		else
			if ColorPickerFrame:IsShown() then
				return
			end

			local OldR, OldG, OldB, OldA = unpack(value)

			local function ShowColorPicker(r, g, b, a, changedCallback, sameCallback)
				HideUIPanel(ColorPickerFrame)
				ColorPickerFrame.button = self
				ColorPickerFrame:SetColorRGB(r, g, b)
				ColorPickerFrame.hasOpacity = (a ~= nil and a < 1)
				ColorPickerFrame.opacity = a
				ColorPickerFrame.previousValues = {OldR, OldG, OldB, OldA}
				ColorPickerFrame.func, ColorPickerFrame.opacityFunc, ColorPickerFrame.cancelFunc =
				changedCallback,
				changedCallback,
				sameCallback
				ShowUIPanel(ColorPickerFrame)
			end

			local function ColorCallback(restore)
				if (restore ~= nil or self ~= ColorPickerFrame.button) then
					return
				end

				local NewA, NewR, NewG, NewB = OpacitySliderFrame:GetValue(), ColorPickerFrame:GetColorRGB()

				value = {NewR, NewG, NewB, NewA}
				KkthnxUIConfig:SetOption(group, option, value)
				self.Color:SetVertexColor(NewR, NewG, NewB, NewA)
			end

			local function SameColorCallback()
				value = {OldR, OldG, OldB, OldA}
				KkthnxUIConfig:SetOption(group, option, value)
				self.Color:SetVertexColor(OldR, OldG, OldB, OldA)
			end

			ShowColorPicker(OldR, OldG, OldB, OldA, ColorCallback, SameColorCallback)
		end
	end
	)

	Button.Name = Button:CreateFontString(nil, "OVERLAY")
	Button.Name:SetFont(C["Media"].Font, 12)
	Button.Name:SetPoint("CENTER", Button)
	Button.Name:SetShadowColor(0, 0, 0)
	Button.Name:SetShadowOffset(1.25, -1.25)
	Button.Name:SetText(COLOR)

	Button.Color = Button:CreateTexture(nil, "OVERLAY")
	Button.Color:SetAllPoints(Button)
	Button.Color:SetTexture(ConfigTexture)
	Button.Color:SetVertexColor(value[1], value[2], value[3], value[4])

	Button.Label = Button:CreateFontString(nil, "OVERLAY")
	Button.Label:SetFont(C["Media"].Font, 12)
	Button.Label:SetPoint("LEFT", Button, "RIGHT", 5, 0)
	Button.Label:SetShadowColor(0, 0, 0)
	Button.Label:SetShadowOffset(1.25, -1.25)

	return Button
end

local function CreateConfigDropDown(parent, group, option, value, type)
	local K = KkthnxUI[1]
	local C = KkthnxUI[2]

	local DropDown = CreateFrame("Button", nil, parent)
	DropDown:SetSize(150, 20)

	DropDown.Backgrounds = DropDown:CreateTexture(nil, "BACKGROUND", -1)
	DropDown.Backgrounds:SetAllPoints()
	DropDown.Backgrounds:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

	DropDown.Borders = CreateFrame("Frame", nil, DropDown)
	DropDown.Borders:SetAllPoints()
	K.CreateBorder(DropDown.Borders)

	DropDown.Type = type
	DropDown._Group = group
	DropDown._Option = option
	local Info

	if (type == "Font") then
		Info = K.FontTable
	elseif (type == "Texture") then
		Info = K.TextureTable
	else
		Info = value
	end

	DropDown.Info = Info

	local Current = DropDown:CreateFontString(nil, "OVERLAY")
	Current:SetPoint("LEFT", DropDown, 6, -0.5)

	if (type == "Texture") then
		local CurrentTex = DropDown:CreateTexture(nil, "ARTWORK")
		CurrentTex:SetSize(DropDown:GetWidth(), 20)
		CurrentTex:SetPoint("LEFT", DropDown, 0, 0)
		CurrentTex:SetVertexColor(Colors.r, Colors.g, Colors.b)
		DropDown.CurrentTex = CurrentTex

		Current:SetFont(C["Media"].Font, 12)
		Current:SetShadowColor(0, 0, 0)
		Current:SetShadowOffset(1.25, -1.25)
	elseif (type == "Custom") then
		Current:SetFont(C["Media"].Font, 12)
		Current:SetShadowColor(0, 0, 0)
		Current:SetShadowOffset(1.25, -1.25)
	end

	local Button = CreateFrame("Button", nil, DropDown)
	Button:SetSize(16, 16)

	Button.Backgrounds = Button:CreateTexture(nil, "BACKGROUND", -1)
	Button.Backgrounds:SetAllPoints()
	Button.Backgrounds:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

	Button.Borders = CreateFrame("Frame", nil, Button)
	Button.Borders:SetAllPoints()
	K.CreateBorder(Button.Borders)

	Button:SetPoint("RIGHT", DropDown, -2, 0)
	Button.Owner = DropDown

	local ButtonTex = Button:CreateTexture(nil, "OVERLAY")
	ButtonTex:SetSize(14, 14)
	ButtonTex:SetPoint("CENTER", Button, 1, -4)
	ButtonTex:SetTexture("Interface\\BUTTONS\\Arrow-Down-Up")
	ButtonTex.Owner = Button

	local Label = DropDown:CreateFontString(nil, "OVERLAY")
	Label:SetFont(C["Media"].Font, 12)
	Label:SetShadowColor(0, 0, 0)
	Label:SetShadowOffset(1.25, -1.25)
	Label:SetPoint("LEFT", DropDown, "RIGHT", 5, 0)

	local List = CreateFrame("Frame", nil, UIParent)
	List:SetPoint("TOPLEFT", DropDown, "BOTTOMLEFT", 0, -4)

	List.Backgrounds = List:CreateTexture(nil, "BACKGROUND", -1)
	List.Backgrounds:SetAllPoints()
	List.Backgrounds:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

	List.Borders = CreateFrame("Frame", nil, List)
	List.Borders:SetAllPoints()
	K.CreateBorder(List.Borders)

	List:Hide()
	List:SetWidth(150)
	List:SetFrameLevel(DropDown:GetFrameLevel() + 3)
	List:SetFrameStrata("HIGH")
	List:SetFrameLevel(100)
	List:EnableMouse(true)
	List:HookScript("OnHide", CloseList)
	List.Owner = DropDown

	if (type == "Custom") then
		AddListItems(List, Info.Options)
	else
		AddListItems(List, Info)
	end

	DropDown.Label = Label
	DropDown.Button = Button
	DropDown.Current = Current
	DropDown.List = List
	DropDown:HookScript(
	"OnHide",
	function()
		List:Hide()
	end
	)

	Button.Tex = ButtonTex
	Button:SetScript("OnClick", DropDownButtonOnClick)

	if (type == "Custom") then
		SetSelectedValue(DropDown, value.Value)
	else
		SetSelectedValue(DropDown, value)
	end
	table_insert(DropDownMenus, DropDown)

	return DropDown
end

local function CreateGroupOptions(group)
	local Control
	local LastControl
	local GroupPage = GroupPages[group]
	local Group = group

	for Option, Value in pairs(KkthnxUI[2][group]) do
		if (type(Value) == "boolean") then -- Button
			Control = CreateConfigButton(GroupPage, Group, Option, Value)
		elseif (type(Value) == "number") then -- EditBox
			Control = CreateConfigEditBox(GroupPage, Group, Option, Value)
		elseif (type(Value) == "table") then -- Color Picker / Custom DropDown
			if Value.Options then
				Control = CreateConfigDropDown(GroupPage, Group, Option, Value, "Custom")
			else
				Control = CreateConfigColorPicker(GroupPage, Group, Option, Value)
			end
		elseif (type(Value) == "string") then -- DropDown / EditBox
			if string_find(string_lower(Option), "font") then
				Control = CreateConfigDropDown(GroupPage, Group, Option, Value, "Font")
			elseif string_find(string_lower(Option), "texture") then
				Control = CreateConfigDropDown(GroupPage, Group, Option, Value, "Texture")
			else
				Control = CreateConfigEditBox(GroupPage, Group, Option, Value, 155)
			end
		end

		SetControlInformation(Control, Group, Option) -- Set the label and tooltip

		if (not GroupPage.Controls[Control.Type]) then
			GroupPage.Controls[Control.Type] = {}
		end

		table_insert(GroupPage.Controls[Control.Type], Control)
	end

	local Buttons = GroupPage.Controls["Button"]
	local ColorPickers = GroupPage.Controls["Color"]
	local Custom = GroupPage.Controls["Custom"]
	local EditBoxes = GroupPage.Controls["EditBox"]
	local Fonts = GroupPage.Controls["Font"]
	local Textures = GroupPage.Controls["Texture"]

	if Buttons then
		for i = 1, #Buttons do
			if (i == 1) then
				if LastControl then
					Buttons[i]:SetPoint("TOPLEFT", LastControl, "BOTTOMLEFT", 0, -6)
				else
					Buttons[i]:SetPoint("TOPLEFT", GroupPage, 6, -6)
				end
			else
				Buttons[i]:SetPoint("TOPLEFT", LastControl, "BOTTOMLEFT", 0, -6)
			end

			LastControl = Buttons[i]
		end
	end

	if EditBoxes then
		for i = 1, #EditBoxes do
			if (i == 1) then
				if LastControl then
					EditBoxes[i]:SetPoint("TOPLEFT", LastControl, "BOTTOMLEFT", 0, -6)
				else
					EditBoxes[i]:SetPoint("TOPLEFT", GroupPage, 6, -6)
				end
			else
				EditBoxes[i]:SetPoint("TOPLEFT", LastControl, "BOTTOMLEFT", 0, -6)
			end

			LastControl = EditBoxes[i]
		end
	end

	if ColorPickers then
		for i = 1, #ColorPickers do
			if (i == 1) then
				if LastControl then
					ColorPickers[i]:SetPoint("TOPLEFT", LastControl, "BOTTOMLEFT", 0, -6)
				else
					ColorPickers[i]:SetPoint("TOPLEFT", GroupPage, 6, -6)
				end
			else
				ColorPickers[i]:SetPoint("TOPLEFT", LastControl, "BOTTOMLEFT", 0, -6)
			end

			LastControl = ColorPickers[i]
		end
	end

	if Fonts then
		for i = 1, #Fonts do
			if (i == 1) then
				if LastControl then
					Fonts[i]:SetPoint("TOPLEFT", LastControl, "BOTTOMLEFT", 0, -6)
				else
					Fonts[i]:SetPoint("TOPLEFT", GroupPage, 6, -6)
				end
			else
				Fonts[i]:SetPoint("TOPLEFT", LastControl, "BOTTOMLEFT", 0, -6)
			end

			LastControl = Fonts[i]
		end
	end

	if Textures then
		for i = 1, #Textures do
			if (i == 1) then
				if LastControl then
					Textures[i]:SetPoint("TOPLEFT", LastControl, "BOTTOMLEFT", 0, -6)
				else
					Textures[i]:SetPoint("TOPLEFT", GroupPage, 6, -6)
				end
			else
				Textures[i]:SetPoint("TOPLEFT", LastControl, "BOTTOMLEFT", 0, -6)
			end

			LastControl = Textures[i]
		end
	end

	if Custom then
		for i = 1, #Custom do
			if (i == 1) then
				if LastControl then
					Custom[i]:SetPoint("TOPLEFT", LastControl, "BOTTOMLEFT", 0, -6)
				else
					Custom[i]:SetPoint("TOPLEFT", GroupPage, 6, -6)
				end
			else
				Custom[i]:SetPoint("TOPLEFT", LastControl, "BOTTOMLEFT", 0, -6)
			end

			LastControl = Custom[i]
		end
	end

	GroupPage.Handled = true
end

local function ShowGroup(group)
	if (not GroupPages[group]) then
		return
	end

	if (not GroupPages[group].Handled) then
		CreateGroupOptions(group)
	end

	for _, page in pairs(GroupPages) do
		page:Hide()

		if page.Slider then
			page.Slider:Hide()
		end
	end

	GroupPages[group]:Show()
	KkthnxUIConfigFrameTitle.Text:SetText(group)
	KkthnxUIConfigFrameTitle.Text:SetTextColor(68 / 255, 136 / 255, 255 / 255)

	if GroupPages[group].Slider then
		GroupPages[group].Slider:Show()
	end
end

local function GroupButtonOnClick(self)
	ShowGroup(self.Group)
end

-- Create the config window
function KkthnxUIConfig:CreateConfigWindow()
	local K = KkthnxUI[1]
	local C = KkthnxUI[2]
	local L = KkthnxUI[3]
	local SettingText = KkthnxUIConfigPerAccount and L["Config"].CharSettings or L["Config"].GlobalSettings

	self:UpdateColorDefaults()

	-- Dynamic sizing
	local NumGroups = 0

	for Group in pairs(C) do
		if (not self.Filter[Group]) then
			NumGroups = NumGroups + 1
		end
	end

	local Height = (12 + (NumGroups * 20) + ((NumGroups - 1) * 4)) -- Padding + (NumButtons * ButtonSize) + ((NumButtons - 1) * ButtonSpacing)

	local ConfigFrame = CreateFrame("Frame", "KkthnxUIConfigFrame", UIParent)
	ConfigFrame:SetSize(448, Height)
	ConfigFrame:SetPoint("CENTER")
	ConfigFrame:SetFrameStrata("HIGH")

	local LeftWindow = CreateFrame("Frame", "KkthnxUIConfigFrameLeft", ConfigFrame)

	LeftWindow.Backgrounds = LeftWindow:CreateTexture(nil, "BACKGROUND", -1)
	LeftWindow.Backgrounds:SetAllPoints()
	LeftWindow.Backgrounds:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

	LeftWindow.Borders = CreateFrame("Frame", nil, LeftWindow)
	LeftWindow.Borders:SetAllPoints()
	K.CreateBorder(LeftWindow.Borders)

	LeftWindow:SetSize(139, Height)
	LeftWindow:SetPoint("LEFT", ConfigFrame, 4, 0)
	LeftWindow:EnableMouse(true)

	local RightWindow = CreateFrame("Frame", "KkthnxUIConfigFrameRight", ConfigFrame)

	RightWindow.Backgrounds = RightWindow:CreateTexture(nil, "BACKGROUND", -1)
	RightWindow.Backgrounds:SetAllPoints()
	RightWindow.Backgrounds:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

	RightWindow.Borders = CreateFrame("Frame", nil, RightWindow)
	RightWindow.Borders:SetAllPoints()
	K.CreateBorder(RightWindow.Borders)

	RightWindow:SetSize(300, Height)
	RightWindow:SetPoint("RIGHT", ConfigFrame, 0, 0)
	RightWindow:EnableMouse(true)

	local TitleFrame = CreateFrame("Frame", "KkthnxUIConfigFrameTitle", ConfigFrame)

	TitleFrame.Backgrounds = TitleFrame:CreateTexture(nil, "BACKGROUND", -1)
	TitleFrame.Backgrounds:SetAllPoints()
	TitleFrame.Backgrounds:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

	TitleFrame.Borders = CreateFrame("Frame", nil, TitleFrame)
	TitleFrame.Borders:SetAllPoints()
	K.CreateBorder(TitleFrame.Borders)

	TitleFrame:SetSize(444, 24)
	TitleFrame:SetPoint("BOTTOM", ConfigFrame, "TOP", 2, 5)

	TitleFrame.Text = TitleFrame:CreateFontString(nil, "OVERLAY")
	TitleFrame.Text:SetFont(C["Media"].Font, 16)
	TitleFrame.Text:SetPoint("CENTER", TitleFrame, 0, 0)
	TitleFrame.Text:SetShadowColor(0, 0, 0)
	TitleFrame.Text:SetShadowOffset(1.25, -1.25)

	local InfoFrame = CreateFrame("Frame", "KkthnxUIConfigFrameCredit", ConfigFrame)

	InfoFrame.Backgrounds = InfoFrame:CreateTexture(nil, "BACKGROUND", -1)
	InfoFrame.Backgrounds:SetAllPoints()
	InfoFrame.Backgrounds:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

	InfoFrame.Borders = CreateFrame("Frame", nil, InfoFrame)
	InfoFrame.Borders:SetAllPoints()
	K.CreateBorder(InfoFrame.Borders)

	InfoFrame:SetSize(444, 24)
	InfoFrame:SetPoint("TOP", ConfigFrame, "BOTTOM", 2, -5)

	InfoFrame.Text = InfoFrame:CreateFontString(nil, "OVERLAY")
	InfoFrame.Text:SetFont(C["Media"].Font, 14)
	InfoFrame.Text:SetShadowOffset(1.25, -1.25)
	InfoFrame.Text:SetText(
	"Welcome to |cff4488ffKkthnxUI|r v" ..
	K.Version ..
	" " ..
	K.Client ..
	", " .. string_format("|cff%02x%02x%02x%s|r", K.Color.r * 255, K.Color.g * 255, K.Color.b * 255, K.Name)
	)
	InfoFrame.Text:SetPoint("CENTER", InfoFrame, 0, 0)

	local CloseButton = CreateFrame("Button", nil, InfoFrame)
	CloseButton:SkinButton()
	CloseButton:SetSize(138, 22)
	CloseButton:SetScript(
	"OnClick",
	function()
		ConfigFrame:Hide()
	end
	)
	CloseButton:SetFrameLevel(InfoFrame:GetFrameLevel() + 1)
	CloseButton:SetPoint("BOTTOMLEFT", InfoFrame, "BOTTOMLEFT", 0, -27)

	CloseButton.Text = CloseButton:CreateFontString(nil, "OVERLAY")
	CloseButton.Text:SetFont(C["Media"].Font, 12)
	CloseButton.Text:SetShadowOffset(1.25, -1.25)
	CloseButton.Text:SetPoint("CENTER", CloseButton)
	CloseButton.Text:SetTextColor(1, 0, 0)
	CloseButton.Text:SetText("|cffFF0000" .. CLOSE .. "|r")

	local ReloadButton = CreateFrame("Button", nil, InfoFrame)
	ReloadButton:SkinButton()
	ReloadButton:SetSize(148, 22)
	ReloadButton:SetScript(
	"OnClick",
	function()
		ReloadUI()
	end
	)
	ReloadButton:SetFrameLevel(InfoFrame:GetFrameLevel() + 1)
	ReloadButton:SetPoint("LEFT", CloseButton, "RIGHT", 5, 0)

	ReloadButton.Text = ReloadButton:CreateFontString(nil, "OVERLAY")
	ReloadButton.Text:SetFont(C["Media"].Font, 12)
	ReloadButton.Text:SetShadowOffset(1.25, -1.25)
	ReloadButton.Text:SetPoint("CENTER", ReloadButton)
	ReloadButton.Text:SetText("|cff00FF00" .. APPLY .. "|r")

	local GlobalButton = CreateFrame("Button", nil, InfoFrame)
	GlobalButton:SkinButton()
	GlobalButton:SetSize(148, 22)
	GlobalButton:SetScript(
	"OnClick",
	function()
		if not KkthnxUIConfigPerAccount then
			KkthnxUIConfigPerAccount = true
		else
			KkthnxUIConfigPerAccount = false
		end

		ReloadUI()
	end
	)
	GlobalButton:SetFrameLevel(InfoFrame:GetFrameLevel() + 1)
	GlobalButton:SetPoint("LEFT", ReloadButton, "RIGHT", 5, 0)

	GlobalButton.Text = GlobalButton:CreateFontString(nil, "OVERLAY")
	GlobalButton.Text:SetFont(C["Media"].Font, 12)
	GlobalButton.Text:SetShadowOffset(1.25, -1.25)
	GlobalButton.Text:SetPoint("CENTER", GlobalButton)
	GlobalButton.Text:SetText("|cffffd100" .. SettingText .. "|r")

	local ResetCVarsButton = CreateFrame("Button", nil, InfoFrame)
	ResetCVarsButton:SkinButton()
	ResetCVarsButton:SetSize(138, 22)
	ResetCVarsButton:SetScript("OnClick", K["Install"].Step1)
	ResetCVarsButton:SetFrameLevel(InfoFrame:GetFrameLevel() + 1)
	ResetCVarsButton:SetPoint("TOP", CloseButton, "BOTTOM", 0, -5)

	ResetCVarsButton.Text = ResetCVarsButton:CreateFontString(nil, "OVERLAY")
	ResetCVarsButton.Text:SetFont(C["Media"].Font, 12)
	ResetCVarsButton.Text:SetShadowOffset(1.25, -1.25)
	ResetCVarsButton.Text:SetPoint("CENTER", ResetCVarsButton)
	ResetCVarsButton.Text:SetText("|cffffd100" .. "Reset CVars" .. "|r")

	local ResetChatButton = CreateFrame("Button", nil, InfoFrame)
	ResetChatButton:SkinButton()
	ResetChatButton:SetSize(148, 22)
	ResetChatButton:SetScript("OnClick", K["Install"].Step2)
	ResetChatButton:SetFrameLevel(InfoFrame:GetFrameLevel() + 1)
	ResetChatButton:SetPoint("TOP", ReloadButton, "BOTTOM", 0, -5)

	ResetChatButton.Text = ResetChatButton:CreateFontString(nil, "OVERLAY")
	ResetChatButton.Text:SetFont(C["Media"].Font, 12)
	ResetChatButton.Text:SetShadowOffset(1.25, -1.25)
	ResetChatButton.Text:SetPoint("CENTER", ResetChatButton)
	ResetChatButton.Text:SetText("|cffffd100" .. "Reset Chat" .. "|r")

	local ResetButton = CreateFrame("Button", nil, InfoFrame)
	ResetButton:SkinButton()
	ResetButton:SetSize(148, 22)
	ResetButton:SetScript("OnClick", K["Install"].ResetData)
	ResetButton:SetFrameLevel(InfoFrame:GetFrameLevel() + 1)
	ResetButton:SetPoint("LEFT", ResetChatButton, "RIGHT", 5, 0)

	ResetButton.Text = ResetButton:CreateFontString(nil, "OVERLAY")
	ResetButton.Text:SetFont(C["Media"].Font, 12)
	ResetButton.Text:SetShadowOffset(1.25, -1.25)
	ResetButton.Text:SetPoint("CENTER", ResetButton)
	ResetButton.Text:SetText("|cffFF0000"..RESET_TO_DEFAULT.."|r")

	if (KkthnxUIData[GetRealmName()][UnitName("player")].InstallComplete) then
		ResetButton:Show()
		ResetCVarsButton:Show()
		ResetChatButton:Show()
	else
		ResetButton:Hide()
		ResetCVarsButton:Hide()
		ResetChatButton:Hide()
	end

	local LastButton
	local ButtonCount = 0

	for Group, Table in PairsByKeys(C) do
		if (not self.Filter[Group]) then
			local NumOptions = 0

			for Key in pairs(Table) do
				NumOptions = NumOptions + 1
			end

			local GroupHeight = 8 + (NumOptions * 25)

			local GroupPage = CreateFrame("Frame", nil, ConfigFrame)
			GroupPage:SetSize(300, Height)
			GroupPage:SetPoint("TOPRIGHT", ConfigFrame)
			GroupPage.Controls = {}

			if (GroupHeight > Height) then
				GroupPage:SetSize(300, GroupHeight)

				local ScrollFrame = CreateFrame("ScrollFrame", nil, RightWindow)
				ScrollFrame:SetSize(300, Height)
				ScrollFrame:SetAllPoints(RightWindow, 0, 4)
				ScrollFrame:SetScrollChild(GroupPage)
				ScrollFrame:SetClipsChildren(true) -- https://www.wowinterface.com/forums/showthread.php?t=55664

				local Slider = CreateFrame("Slider", nil, ScrollFrame)
				Slider:SetPoint("RIGHT", -6, 0)
				Slider:SetWidth(12)
				Slider:SetHeight(Height - 12)
				Slider:SetThumbTexture(C["Media"].Texture)
				Slider:SetOrientation("VERTICAL")
				Slider:SetValueStep(1)

				Slider.Backgrounds = Slider:CreateTexture(nil, "BACKGROUND", -1)
				Slider.Backgrounds:SetAllPoints()
				Slider.Backgrounds:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

				Slider.Borders = CreateFrame("Frame", nil, Slider)
				Slider.Borders:SetAllPoints()
				K.CreateBorder(Slider.Borders)

				Slider:SetMinMaxValues(0, 1)
				Slider:SetValue(0)
				Slider.ScrollFrame = ScrollFrame
				Slider:EnableMouseWheel(true)
				Slider:SetScript("OnMouseWheel", SliderOnMouseWheel)
				Slider:SetScript("OnValueChanged", SliderOnValueChanged)

				Slider:SetValue(10)
				Slider:SetValue(0)

				local Thumb = Slider:GetThumbTexture()
				Thumb:SetWidth(12)
				Thumb:SetHeight(18)
				Thumb:SetVertexColor(68 / 255, 136 / 255, 255 / 255, 0.8)

				Slider:Show()

				GroupPage.Slider = Slider
			end

			GroupPages[Group] = GroupPage

			local Button = CreateFrame("Button", nil, ConfigFrame)
			Button.Group = Group

			Button:SetSize(132, 20)
			Button:SetScript("OnClick", GroupButtonOnClick)
			Button:SetFrameLevel(LeftWindow:GetFrameLevel() + 1)

			if Button.SetHighlightTexture and not Button.Hover then
				Button.Hover = Button:CreateTexture(nil, "ARTWORK")
				Button.Hover:SetVertexColor(Colors.r, Colors.g, Colors.b, 0.8)
				Button.Hover:SetTexture("Interface\\Buttons\\UI-Listbox-Highlight2")
				Button.Hover:SetBlendMode("ADD")
				Button.Hover:SetAllPoints()
				Button:SetHighlightTexture(Button.Hover)
			end

			Button.Text = Button:CreateFontString(nil, "OVERLAY")
			Button.Text:SetFont(C["Media"].Font, 12)
			Button.Text:SetShadowOffset(1.25, -1.25)
			Button.Text:SetPoint("CENTER", Button)
			Button.Text:SetText(Group)

			Button.Active = Button:CreateTexture(nil, "ARTWORK")
			Button.Active:SetVertexColor(Colors.r, Colors.g, Colors.b, 0.2)
			Button.Active:SetTexture("Interface\\Buttons\\UI-Listbox-Highlight2")
			Button.Active:SetBlendMode("ADD")
			Button.Active:SetAllPoints()
			Button.Active:Hide()

			GroupPage:HookScript(
			"OnShow",
			function()
				Button.Active:Show()
			end
			)
			GroupPage:HookScript(
			"OnHide",
			function()
				Button.Active:Hide()
			end
			)

			if (ButtonCount == 0) then
				Button:SetPoint("TOP", LeftWindow, 0, -6)
			else
				Button:SetPoint("TOP", LastButton, "BOTTOM", 0, -4)
			end

			ButtonCount = ButtonCount + 1
			LastButton = Button
		end
	end

	ShowGroup("General") -- Show General options by default
	ConfigFrame:Hide()
	GameMenuFrame:HookScript(
	"OnShow",
	function()
		ConfigFrame:Hide()
	end
	)
end

do
	SlashCmdList["CONFIG"] = function()
		if (not KkthnxUIConfigFrame) then
			KkthnxUIConfig:CreateConfigWindow()
		end
		if KkthnxUIConfigFrame:IsVisible() then
			KkthnxUIConfigFrame:Hide()
		else
			KkthnxUIConfigFrame:Show()
		end
		HideUIPanel(GameMenuFrame)
	end
	SLASH_CONFIG1 = "/config"
	SLASH_CONFIG2 = "/cfg"
	SLASH_CONFIG3 = "/configui"
	SLASH_CONFIG4 = "/kc"
	SLASH_CONFIG5 = "/kkthnxui"
end