--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/ActionBars/Keybind.lua
	Purpose:
		Shorten hotkey text so it fits the small corner of a button. LAB owns the
		HotKey font string and rewrites it on rebind, so we hook its SetText and
		re-apply the abbreviations. Localized key names are resolved first with an
		English fallback so it reads correctly on every client.
-----------------------------------------------------------------------------]]

local K = KkthnxUI[1]

local Module = K:GetModule("ActionBars")

local _G = _G
local gsub = string.gsub

-- Localized modifier and key names with English fallbacks.
local L_BUTTON = (_G.KEY_BUTTON3 and _G.KEY_BUTTON3:gsub("3", "")) or "Button"
local L_MOUSEWHEELUP = _G.KEY_MOUSEWHEELUP or "Mouse Wheel Up"
local L_MOUSEWHEELDN = _G.KEY_MOUSEWHEELDOWN or "Mouse Wheel Down"
local L_NUMPAD = (_G.KEY_NUMPAD0 and _G.KEY_NUMPAD0:gsub("0", "")) or "Num Pad"
local L_PAGEUP = _G.KEY_PAGEUP or "Page Up"
local L_PAGEDOWN = _G.KEY_PAGEDOWN or "Page Down"
local L_SPACE = _G.KEY_SPACE or "Space"
local L_INSERT = _G.KEY_INSERT or "Insert"
local L_HOME = _G.KEY_HOME or "Home"
local L_DELETE = _G.KEY_DELETE or "Delete"

-- Order matters: modifiers first, then named keys, then generic patterns.
local REPLACEMENTS = {
	{ "(CTRL%-)", "c" },
	{ "(Ctrl%-)", "c" },
	{ "(ALT%-)", "a" },
	{ "(Alt%-)", "a" },
	{ "(SHIFT%-)", "s" },
	{ "(Shift%-)", "s" },
	{ "(META%-)", "m" },
	{ "(Meta%-)", "m" },
	{ L_MOUSEWHEELUP, "MU" },
	{ "MOUSEWHEELUP", "MU" },
	{ L_MOUSEWHEELDN, "MD" },
	{ "MOUSEWHEELDOWN", "MD" },
	{ L_BUTTON, "M" },
	{ "BUTTON", "M" },
	{ L_PAGEUP, "PU" },
	{ "PAGEUP", "PU" },
	{ L_PAGEDOWN, "PD" },
	{ "PAGEDOWN", "PD" },
	{ L_HOME, "Hm" },
	{ "HOME", "Hm" },
	{ "END", "End" },
	{ L_INSERT, "Ins" },
	{ "INSERT", "Ins" },
	{ L_DELETE, "Del" },
	{ "DELETE", "Del" },
	{ "BACKSPACE", "BS" },
	{ "TAB", "Tab" },
	{ "ESCAPE", "Esc" },
	{ L_SPACE, "Sp" },
	{ "SPACE", "Sp" },
	{ "CAPSLOCK", "CL" },
	{ "NUMLOCK", "NL" },
	{ "NUMPADDIVIDE", "N/" },
	{ "NUMPADMULTIPLY", "N*" },
	{ "NUMPADPLUS", "N+" },
	{ "NUMPADMINUS", "N-" },
	{ L_NUMPAD, "N" },
	{ "NUMPAD", "N" },
}

-- Abbreviate the given hotkey font string. Called as a SetText hook, so it
-- guards against recursion with a flag.
local function Abbreviate(hotkey)
	if hotkey.__setting then
		return
	end
	local text = hotkey:GetText()
	if not text then
		return
	end

	if text == _G.RANGE_INDICATOR then
		text = ""
	else
		for _, pair in ipairs(REPLACEMENTS) do
			text = gsub(text, pair[1], pair[2])
		end
	end

	hotkey.__setting = true
	hotkey:SetText(text)
	hotkey.__setting = false
end

-- Apply abbreviation to a button's hotkey and keep it applied on rebind.
function Module:StyleHotKey(button)
	local hotkey = button.HotKey
	if not hotkey or hotkey.__abbrevHooked then
		return
	end
	hotkey.__abbrevHooked = true
	Abbreviate(hotkey)
	hooksecurefunc(hotkey, "SetText", Abbreviate)
end
