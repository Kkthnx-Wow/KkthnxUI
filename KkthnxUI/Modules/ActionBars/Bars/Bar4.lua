local K, C = unpack(select(2, ...))
local Module = K:GetModule("ActionBar")
local FilterConfig = K.ActionBars.actionBar4

local _G = _G
local table_insert = _G.table.insert

local CreateFrame = _G.CreateFrame
local InCombatLockdown = _G.InCombatLockdown
local NUM_ACTIONBAR_BUTTONS = _G.NUM_ACTIONBAR_BUTTONS
local RegisterStateDriver = _G.RegisterStateDriver
local UIParent = _G.UIParent

function Module:CreateBar4()
	local padding, margin = 0, 6
	local num = NUM_ACTIONBAR_BUTTONS
	local buttonList = {}
	local buttonSize = C["ActionBar"].RightButtonSize

	-- Create The Frame To Hold The Buttons
	local frame = CreateFrame("Frame", "KkthnxUI_ActionBar4", UIParent, "SecureHandlerStateTemplate")
	frame:SetWidth(buttonSize + 2 * padding)
	frame:SetHeight(num * buttonSize + (num - 1) * margin + 2 * padding)
	frame.Pos = {"RIGHT", UIParent, "RIGHT", -4, 0}

	-- Move The Buttons Into Position And Reparent Them
	_G.MultiBarRight:SetParent(frame)
	_G.MultiBarRight:EnableMouse(false)

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

	-- Show/hide The Frame On A Given State Driver
	frame.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; show"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	-- Create Drag Frame And Drag Functionality
	if K.ActionBars.userPlaced then
		K.Mover(frame, SHOW_MULTIBAR3_TEXT, "Bar4", frame.Pos)
	end

	if C["ActionBar"].FadeRightBar and FilterConfig.fader then
		Module.CreateButtonFrameFader(frame, buttonList, FilterConfig.fader)
	end

	-- Fix Annoying Visibility
	local function updateVisibility(event)
		if InCombatLockdown() then
			K:RegisterEvent("PLAYER_REGEN_ENABLED", updateVisibility)
		else
			InterfaceOptions_UpdateMultiActionBars()
			K:UnregisterEvent(event, updateVisibility)
		end
	end
	K:RegisterEvent("UNIT_EXITING_VEHICLE", updateVisibility)
	K:RegisterEvent("UNIT_EXITED_VEHICLE", updateVisibility)
	K:RegisterEvent("PET_BATTLE_CLOSE", updateVisibility)
	K:RegisterEvent("PET_BATTLE_OVER", updateVisibility)
end