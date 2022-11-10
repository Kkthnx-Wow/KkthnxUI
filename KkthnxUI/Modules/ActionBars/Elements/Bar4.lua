local K, C = unpack(KkthnxUI)
local Module = K:GetModule("ActionBar")

local _G = _G
local table_insert = _G.table.insert

local CreateFrame = _G.CreateFrame
local InCombatLockdown = _G.InCombatLockdown
local UIParent = _G.UIParent

local cfg = C.Bars.Bar4

function Module:ToggleBarFader(name)
	local frame = _G["KKUI_Action" .. name]
	if not frame then
		return
	end

	frame.isDisable = not C["ActionBar"][name .. "Fader"]
	if frame.isDisable then
		Module:StartFadeIn(frame)
	else
		Module:StartFadeOut(frame)
	end
end

function Module:UpdateFrameClickThru()
	local showBar4, showBar5

	local function updateClickThru()
		_G.KKUI_ActionBar4:EnableMouse(showBar4)
		_G.KKUI_ActionBar5:EnableMouse((not showBar4 and showBar4) or (showBar4 and showBar5))
	end

	hooksecurefunc("SetActionBarToggles", function(_, _, bar3, bar4)
		showBar4 = not not bar3
		showBar5 = not not bar4
		if InCombatLockdown() then
			K:RegisterEvent("PLAYER_REGEN_ENABLED", updateClickThru)
		else
			updateClickThru()
		end
	end)
end

function Module:CreateBar4()
	local num = NUM_ACTIONBAR_BUTTONS
	local RegisterStateDriver = _G.RegisterStateDriver
	local buttonList = {}

	local frame = CreateFrame("Frame", "KKUI_ActionBar4", UIParent, "SecureHandlerStateTemplate")
	frame.mover = K.Mover(frame, "Actionbar" .. "4", "Bar4", { "RIGHT", UIParent, "RIGHT", -4, 0 })
	Module.movers[5] = frame.mover

	_G.MultiBarRight:SetParent(frame)
	_G.MultiBarRight:EnableMouse(false)
	_G.MultiBarRight.QuickKeybindGlow:SetTexture("")

	for i = 1, num do
		local button = _G["MultiBarRightButton" .. i]
		table_insert(buttonList, button)
		table_insert(Module.buttons, button)
	end
	frame.buttons = buttonList

	frame.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; show"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	if cfg.fader then
		frame.isDisable = not C["ActionBar"].Bar4Fader
		Module.CreateButtonFrameFader(frame, buttonList, cfg.fader)
	end

	Module:UpdateFrameClickThru()
end
