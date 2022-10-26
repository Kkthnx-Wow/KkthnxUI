local K, C = unpack(KkthnxUI)
local Module = K:GetModule("ActionBar")

local _G = _G
local tinsert = tinsert

local cfg = C.Bars.Bar5
local margin = C.Bars.BarMargin

local function createBar(index, offset)
	local num = NUM_ACTIONBAR_BUTTONS
	local buttonList = {}

	local frame = CreateFrame("Frame", "KKUI_ActionBar" .. index, UIParent, "SecureHandlerStateTemplate")
	frame.mover = K.Mover(frame, "Actionbar" .. index, "Bar" .. index, { "CENTER", UIParent, "CENTER", 0, offset })
	Module.movers[index + 1] = frame.mover

	_G["MultiBar" .. (index - 1)]:SetParent(frame)
	_G["MultiBar" .. (index - 1)]:EnableMouse(false)

	for i = 1, num do
		local button = _G["MultiBar" .. (index - 1) .. "Button" .. i]
		tinsert(buttonList, button)
		tinsert(Module.buttons, button)
	end
	frame.buttons = buttonList

	frame.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; show"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	--if cfg.fader then
	--	frame.isDisable = not C.db["Actionbar"]["Bar5Fader"]
	--	Bar.CreateButtonFrameFader(frame, buttonList, cfg.fader)
	--end
end

function Module:CreateBar678()
	createBar(6, 0)
	createBar(7, 40)
	createBar(8, 80)
end
