--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/ActionBars/BindMode.lua
	Purpose:
		Keybind mode for the action bars. The stock bars are hidden, so the game's
		own quick keybind mode has nothing to point at. In this mode you hover one
		of our buttons and press the key you want on it. Escape clears the keys on
		the button under the pointer, or leaves the mode when none is hovered.

		Keys are saved as ordinary game bindings, so they show in the key bindings
		window and follow the character or account binding set like any other.
		Nothing is built until the mode is first used, and nothing runs while it is
		off. It cannot be used in combat.

		Open it with /kkbind or from the Action Bars page.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("ActionBars")

local _G = _G
local pairs = pairs
local ipairs = ipairs
local concat = table.concat
local format = string.format

local CreateFrame = CreateFrame
local UIParent = UIParent
local InCombatLockdown = InCombatLockdown
local GetBindingKey = GetBindingKey
local GetBindingAction = GetBindingAction
local SetBinding = SetBinding
local SaveBindings = SaveBindings
local GetCurrentBindingSet = GetCurrentBindingSet
local IsAltKeyDown = IsAltKeyDown
local IsControlKeyDown = IsControlKeyDown
local IsShiftKeyDown = IsShiftKeyDown

-- Keys that only ever modify another key, so pressing one alone binds nothing.
local MODIFIERS = {
	LSHIFT = true,
	RSHIFT = true,
	LCTRL = true,
	RCTRL = true,
	LALT = true,
	RALT = true,
	LMETA = true,
	RMETA = true,
}

-- Mouse buttons that can carry a binding. Left and right are the buttons used to
-- click around, so they are not offered.
local MOUSE_KEYS = {
	MiddleButton = "BUTTON3",
	Button4 = "BUTTON4",
	Button5 = "BUTTON5",
	Button6 = "BUTTON6",
	Button7 = "BUTTON7",
	Button8 = "BUTTON8",
	Button9 = "BUTTON9",
	Button10 = "BUTTON10",
}

local active
local command -- the binding of the button under the pointer
local commands = {} -- button -> the game binding it stands for
local hooked = {} -- buttons that already carry the hover hook

-- The capture frame takes the keyboard while the mode is on. The overlay sits
-- over the hovered button, so a click on it cannot cast whatever is underneath.
local capture = CreateFrame("Frame", "KKUI_BindCapture", UIParent)
capture:SetFrameStrata("FULLSCREEN_DIALOG")
capture:SetAllPoints(UIParent)
capture:EnableKeyboard(false)
capture:Hide()

local overlay = CreateFrame("Frame", "KKUI_BindOverlay", UIParent)
overlay:SetFrameStrata("FULLSCREEN_DIALOG")
overlay:SetFrameLevel(50)
overlay:EnableMouse(true)
overlay:Hide()

local hint = capture:CreateFontString(nil, "OVERLAY")
local label = overlay:CreateFontString(nil, "OVERLAY")
local built

local function Build()
	if built then
		return
	end
	built = true

	hint:SetPoint("TOP", UIParent, "TOP", 0, -120)
	K.SetFont(hint, 16, K.FontOutlineStyle())
	hint:SetText(L["Keybind mode. Hover a button and press a key. Escape clears the button, or leaves when none is hovered."])
	hint:SetWidth(520)

	local tint = overlay:CreateTexture(nil, "ARTWORK")
	tint:SetAllPoints()
	tint:SetColorTexture(K.Colors.accent[1], K.Colors.accent[2], K.Colors.accent[3], 0.55)
	K.CreateBorder(overlay)

	K.SetFont(label, 11, K.FontOutlineStyle())
	label:SetPoint("CENTER")
	label:SetWidth(120)
end

-- The name the game shows for a binding in its key bindings window.
local function CommandName(name)
	return _G["BINDING_NAME_" .. name] or name
end

local keys = {}
local function Refresh()
	if not command then
		return
	end
	for index = #keys, 1, -1 do
		keys[index] = nil
	end
	local list = { GetBindingKey(command) }
	for _, key in ipairs(list) do
		keys[#keys + 1] = key
	end
	label:SetText(#keys > 0 and concat(keys, "\n") or L["Not bound"])
end

local function Hover(button)
	if not active then
		return
	end
	command = commands[button]
	if not command then
		return
	end
	overlay:ClearAllPoints()
	overlay:SetAllPoints(button)
	overlay:Show()
	Refresh()
end

local function Save()
	SaveBindings(GetCurrentBindingSet())
end

local function Bind(keyString)
	if not command then
		return
	end
	local previous = GetBindingAction(keyString)
	SetBinding(keyString, command)
	Save()
	if previous and previous ~= "" and previous ~= command then
		K.Print(format(L["%s was moved from %s."], keyString, CommandName(previous)))
	end
	Refresh()
end

local function Clear()
	if not command then
		return
	end
	local list = { GetBindingKey(command) }
	for _, key in ipairs(list) do
		SetBinding(key)
	end
	Save()
	Refresh()
end

local function Leave()
	active = false
	command = nil
	overlay:Hide()
	capture:EnableKeyboard(false)
	capture:UnregisterEvent("PLAYER_REGEN_DISABLED")
	capture:Hide()
end

-- Rebuild which button stands for which binding, so a bar that was resized or
-- turned off since last time is read as it is now.
local function MapButtons()
	for button in pairs(commands) do
		commands[button] = nil
	end
	for _, def in ipairs(Module.BarDefs) do
		local bar = Module.bars[def.key]
		if bar and def.bindName and bar:IsShown() then
			for index, button in ipairs(bar.buttons) do
				if button:IsShown() then
					commands[button] = def.bindName .. index
					if not hooked[button] then
						hooked[button] = true
						button:HookScript("OnEnter", Hover)
					end
				end
			end
		end
	end
end

capture:SetScript("OnKeyDown", function(_, key)
	if MODIFIERS[key] then
		return
	end
	if key == "ESCAPE" then
		if command then
			Clear()
		else
			Leave()
		end
		return
	end
	if not command then
		return
	end
	local mods = (IsAltKeyDown() and "ALT-" or "") .. (IsControlKeyDown() and "CTRL-" or "") .. (IsShiftKeyDown() and "SHIFT-" or "")
	Bind(mods .. key)
end)

capture:SetScript("OnEvent", function()
	-- Bindings cannot be changed in combat.
	Leave()
end)

overlay:SetScript("OnLeave", function()
	command = nil
	overlay:Hide()
end)

overlay:SetScript("OnMouseDown", function(_, mouseButton)
	local key = MOUSE_KEYS[mouseButton]
	if not (key and command) then
		return
	end
	local mods = (IsAltKeyDown() and "ALT-" or "") .. (IsControlKeyDown() and "CTRL-" or "") .. (IsShiftKeyDown() and "SHIFT-" or "")
	Bind(mods .. key)
end)

-- The wheel can carry a binding too, so it is read from the overlay the same way
-- as the extra mouse buttons.
overlay:EnableMouseWheel(true)
overlay:SetScript("OnMouseWheel", function(_, delta)
	if not command then
		return
	end
	local mods = (IsAltKeyDown() and "ALT-" or "") .. (IsControlKeyDown() and "CTRL-" or "") .. (IsShiftKeyDown() and "SHIFT-" or "")
	Bind(mods .. (delta > 0 and "MOUSEWHEELUP" or "MOUSEWHEELDOWN"))
end)

function Module:ToggleBindMode()
	if active then
		Leave()
		return
	end
	if InCombatLockdown() then
		K.Print(L["Keybind mode cannot be used in combat."])
		return
	end
	if not (C.ActionBar and C.ActionBar.Enable and Module.bars.Bar1) then
		K.Print(L["The action bars are not enabled."])
		return
	end
	Build()
	MapButtons()
	active = true
	capture:RegisterEvent("PLAYER_REGEN_DISABLED")
	capture:Show()
	capture:EnableKeyboard(true)
end

_G.SLASH_KKUI_BIND1 = "/kkbind"
_G.SlashCmdList["KKUI_BIND"] = function()
	Module:ToggleBindMode()
end
