local K, C = unpack(select(2, ...))
local Module = K:GetModule("ActionBar")
local FilterConfig = C.ActionBars.actionBar4

local _G = _G
local table_insert = _G.table.insert

local CreateFrame = _G.CreateFrame
local InCombatLockdown = _G.InCombatLockdown
local NUM_ACTIONBAR_BUTTONS = _G.NUM_ACTIONBAR_BUTTONS
local RegisterStateDriver = _G.RegisterStateDriver
local UIParent = _G.UIParent

local padding, margin = 0, 6

local function SetFrameSize(frame, size, num)
	size = size or frame.buttonSize
	num = num or frame.numButtons

	frame:SetWidth(size + 2 * padding)
	frame:SetHeight(num * size + (num-1) * margin + 2 * padding)

	if not frame.mover then
		frame.mover = K.Mover(frame, SHOW_MULTIBAR3_TEXT, "Bar4", frame.Pos)
	else
		frame.mover:SetSize(frame:GetSize())
	end

	if not frame.SetFrameSize then
		frame.buttonSize = size
		frame.numButtons = num
		frame.SetFrameSize = SetFrameSize
	end
end

local function updateVisibility(event)
	if InCombatLockdown() then
		K:RegisterEvent("PLAYER_REGEN_ENABLED", updateVisibility)
	else
		InterfaceOptions_UpdateMultiActionBars()
		K:UnregisterEvent(event, updateVisibility)
	end
end

function Module:FixSizebarVisibility()
	K:RegisterEvent("PET_BATTLE_OVER", updateVisibility)
	K:RegisterEvent("PET_BATTLE_CLOSE", updateVisibility)
	K:RegisterEvent("UNIT_EXITED_VEHICLE", updateVisibility)
	K:RegisterEvent("UNIT_EXITING_VEHICLE", updateVisibility)
end

function Module:CreateBar4()
	local num = NUM_ACTIONBAR_BUTTONS
	local buttonList = {}
	local buttonSize = C["ActionBar"].RightButtonSize

	-- Create The Frame To Hold The Buttons
	local frame = CreateFrame("Frame", "KKUI_ActionBar4", UIParent, "SecureHandlerStateTemplate")
	frame.Pos = {"RIGHT", UIParent, "RIGHT", -4, 0}

	-- Move The Buttons Into Position And Reparent Them
	_G.MultiBarRight:SetParent(frame)
	_G.MultiBarRight:EnableMouse(false)
	_G.MultiBarRight.QuickKeybindGlow:SetTexture("")

	for i = 1, num do
		local button = _G["MultiBarRightButton"..i]
		table_insert(buttonList, button) -- Add The Button Object To The List
		button:SetSize(buttonSize, buttonSize)
		button:ClearAllPoints()

		if i == 1 then
			button:SetPoint("TOPRIGHT", frame, -padding, -padding)
		else
			local previous = _G["MultiBarRightButton"..i - 1]
			button:SetPoint("TOP", previous, "BOTTOM", 0, -margin)
		end
	end

	frame.buttonList = buttonList
	SetFrameSize(frame, buttonSize, num)

	frame.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; show"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	if C["ActionBar"].FadeRightBar and FilterConfig.fader then
		Module.CreateButtonFrameFader(frame, buttonList, FilterConfig.fader)
	end

	-- Fix visibility when leaving vehicle or petbattle
	Module:FixSizebarVisibility()
end