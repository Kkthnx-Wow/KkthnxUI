--[[-----------------------------------------------------------------------------
-- Shared builder context for modular GUI category files (Config/GUI/Categories).
-- Category files must use: local K = KkthnxUI[1]; local B = K.GUIBuilder
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("NewGUI")
local GUI = Module and Module.GUI

K.GUIBuilder = K.GUIBuilder or {}
local B = K.GUIBuilder

B.K, B.C, B.L = K, C, L
B.GUI = GUI
B.enableTextColor = "|cff00cc4c"

function B.RefreshGUI()
	local mod = K:GetModule("NewGUI")
	if mod and mod.GUI then
		B.GUI = mod.GUI
		GUI = mod.GUI
	end
	return B.GUI
end

B.GENERAL = GENERAL
B.COLORS = COLORS
B.PLAYER = PLAYER
B.TARGET = TARGET
B.FILTERS = FILTERS

function B.Ready()
	B.RefreshGUI()
	return B.GUI and B.GUI.AddCategory
end

function B.AddCategory(name, icon, key)
	return GUI:AddCategory(name, icon, key)
end

function B.AddSection(category, name)
	return GUI:AddSection(category, name)
end

function B.DependsOn(...)
	return GUI:DependsOn(...)
end

function B.Switch(section, ...)
	return GUI:CreateSwitch(section, ...)
end

function B.Slider(section, ...)
	return GUI:CreateSlider(section, ...)
end

function B.Dropdown(section, ...)
	return GUI:CreateDropdown(section, ...)
end

function B.Button(section, ...)
	return GUI:CreateButtonWidget(section, ...)
end

function B.Color(section, ...)
	return GUI:CreateColorPicker(section, ...)
end

function B.TextureDropdown(section, ...)
	return GUI:CreateTextureDropdown(section, ...)
end

function B.TextInput(section, ...)
	return GUI:CreateTextInput(section, ...)
end

function B.CheckboxGroup(section, ...)
	return GUI:CreateCheckboxGroup(section, ...)
end

function B.Credits(section, ...)
	return GUI:CreateCredits(section, ...)
end

function B.ExtraGUI(configPath, title)
	if K.ExtraGUI and K.ExtraGUI.ToggleExtraConfig then
		K.ExtraGUI:ToggleExtraConfig(configPath, title)
	end
end
