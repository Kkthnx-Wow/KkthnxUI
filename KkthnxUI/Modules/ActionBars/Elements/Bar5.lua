local K, C = unpack(KkthnxUI)
local Module = K:GetModule("ActionBar")

local _G = _G
local table_insert = _G.table.insert

local CreateFrame = _G.CreateFrame
local NUM_ACTIONBAR_BUTTONS = _G.NUM_ACTIONBAR_BUTTONS
local RegisterStateDriver = _G.RegisterStateDriver
local UIParent = _G.UIParent

local cfg = C.Bars.Bar5
local margin = C.Bars.BarMargin

function Module:CreateBar5()
	local num = NUM_ACTIONBAR_BUTTONS
	local buttonList = {}

	local frame = CreateFrame("Frame", "KKUI_ActionBar5", UIParent, "SecureHandlerStateTemplate")
	frame.mover = K.Mover(frame, "Actionbar" .. "5", "Bar5", { "RIGHT", _G.KKUI_ActionBar4, "LEFT", -margin, 0 })
	Module.movers[6] = frame.mover

	MultiBarLeft:SetParent(frame)
	MultiBarLeft:EnableMouse(false)
	MultiBarLeft.QuickKeybindGlow:SetTexture("")

	hooksecurefunc(MultiBarLeft, "SetScale", function(self, scale, force)
		if not force and scale ~= 1 then
			self:SetScale(1, true)
		end
	end)

	for i = 1, num do
		local button = _G["MultiBarLeftButton" .. i]
		table_insert(buttonList, button)
		table_insert(Module.buttons, button)
	end
	frame.buttons = buttonList

	frame.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; show"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	if cfg.fader then
		frame.isDisable = not C["ActionBar"].Bar5Fader
		Module.CreateButtonFrameFader(frame, buttonList, cfg.fader)
	end
end
