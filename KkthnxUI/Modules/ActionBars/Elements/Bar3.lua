local K, C = unpack(KkthnxUI)
local Module = K:GetModule("ActionBar")

local _G = _G
local table_insert = _G.table.insert

local CreateFrame = _G.CreateFrame
local NUM_ACTIONBAR_BUTTONS = _G.NUM_ACTIONBAR_BUTTONS
local RegisterStateDriver = _G.RegisterStateDriver
local UIParent = _G.UIParent

local cfg = C.Bars.Bar3
local margin = C.Bars.BarMargin

function Module:CreateBar3()
	local num = NUM_ACTIONBAR_BUTTONS
	local buttonList = {}

	local frame = CreateFrame("Frame", "KKUI_ActionBar3", UIParent, "SecureHandlerStateTemplate")
	frame.mover = K.Mover(frame, "Actionbar".."3", "Bar3", {"BOTTOM", _G.KKUI_ActionBar2, "TOP", 0, margin})
	Module.movers[3] = frame.mover

	MultiBarBottomRight:SetParent(frame)
	MultiBarBottomRight:EnableMouse(false)
	MultiBarBottomRight.QuickKeybindGlow:SetTexture("")

	for i = 1, num do
		local button = _G["MultiBarBottomRightButton"..i]
		table_insert(buttonList, button)
		table_insert(Module.buttons, button)
	end
	frame.buttons = buttonList

	frame.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; show"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	if cfg.fader then
		Module.CreateButtonFrameFader(frame, buttonList, cfg.fader)
	end
end