--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Misc/Focus.lua
	Purpose:
		Set focus by holding a modifier and clicking a unit, without burning a
		keybind or writing a macro.

		Two halves, because one alone does not cover everything you can click:

		Unit frames take a secure attribute. SecureButton_GetModifierPrefix builds
		a prefix of "shift-", "ctrl-" and "alt-", and the click handler looks up
		"<prefix>type<button>", so setting "shift-type1" to "focus" is the whole
		mechanism. It is Blizzard's own, the same one the compact raid frames use
		for their right-click focus.

		Nameplates and models are not our frames, so those are covered by an
		override binding on a hidden secure button running a focus macro against
		the mouseover unit.

		Attributes cannot be written to a secure frame in combat, so anything that
		appears mid-fight is queued and applied when the fight ends. Off by
		default.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

local Module = K:NewModule("Focus")

local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local next = next

-- Frames that wanted the attribute while we were locked down.
local queued = {}
local attribute, binding

-- The click handler reads "<modifier prefix>type<button>", and the prefix is
-- lower case with a trailing dash.
local MODIFIERS = {
	Shift = "shift-",
	Ctrl = "ctrl-",
	Alt = "alt-",
}

local BUTTONS = {
	Left = "1",
	Right = "2",
	Middle = "3",
}

local function Apply(frame)
	if not frame or frame.KKUI_Focuser then
		return
	end
	-- Nameplates are driven by the override binding instead. Giving them the
	-- attribute as well would make a modified click do both.
	if frame.isNamePlate then
		return
	end
	if InCombatLockdown() then
		queued[frame] = true
		return
	end
	frame:SetAttribute(attribute, "focus")
	frame.KKUI_Focuser = true
	queued[frame] = nil
end

local function ApplyAll()
	local objects = K.oUF and K.oUF.objects
	if not objects then
		return
	end
	for _, frame in next, objects do
		Apply(frame)
	end
end

function Module:PLAYER_REGEN_ENABLED()
	if next(queued) then
		for frame in next, queued do
			Apply(frame)
		end
	end
	ApplyAll()
end

-- New group frames are spawned as the roster changes, and each one needs the
-- attribute before a modified click will do anything.
function Module:GROUP_ROSTER_UPDATE()
	ApplyAll()
end

function Module:PLAYER_ENTERING_WORLD()
	ApplyAll()
end

function Module:OnEnable()
	local db = C.Misc
	if not db.FocusModifier or db.FocusModifier == "None" then
		return
	end

	local prefix = MODIFIERS[db.FocusModifier]
	local button = BUTTONS[db.FocusButton] or "1"
	if not prefix then
		return
	end

	attribute = prefix .. "type" .. button
	binding = db.FocusModifier:upper() .. "-BUTTON" .. button

	ApplyAll()

	self:RegisterEvent("PLAYER_REGEN_ENABLED", "PLAYER_REGEN_ENABLED")
	self:RegisterEvent("GROUP_ROSTER_UPDATE", "GROUP_ROSTER_UPDATE")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "PLAYER_ENTERING_WORLD")

	-- The second half: a hidden secure button the binding clicks, so the same
	-- modified click works on a nameplate or anything else under the cursor that
	-- is not one of our frames.
	local clicker = CreateFrame("Button", "KKUI_FocusClicker", UIParent, "SecureActionButtonTemplate")
	clicker:RegisterForClicks("AnyDown", "AnyUp")
	clicker:SetAttribute("type", "macro")
	clicker:SetAttribute("macrotext", "/focus [@mouseover,exists]")
	SetOverrideBindingClick(clicker, true, binding, "KKUI_FocusClicker")
end
