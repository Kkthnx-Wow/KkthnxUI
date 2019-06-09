local K, C = unpack(select(2, ...))
local Module = K:GetModule("ActionBar")

local _G = _G
local table_insert = table.insert

local CreateFrame = _G.CreateFrame
local hooksecurefunc = _G.hooksecurefunc
local InCombatLockdown = _G.InCombatLockdown
local NUM_ACTIONBAR_BUTTONS = _G.NUM_ACTIONBAR_BUTTONS
local RegisterStateDriver = _G.RegisterStateDriver
local UIParent = _G.UIParent

function Module:CreateBar4()
	local padding, margin, size = 0, 6, 34
	local num = NUM_ACTIONBAR_BUTTONS
	local buttonList = {}
	local layout = C["ActionBar"].Style.Value

	-- Create The Frame To Hold The Buttons
	local frame = CreateFrame("Frame", "KkthnxUI_ActionBar4", UIParent, "SecureHandlerStateTemplate")
	if layout == 2 then
		frame:SetWidth(25 * size + 20 * margin + 2 * padding)
		frame:SetHeight(2 * size + margin + 2 * padding)
		frame.Pos = {"BOTTOM", UIParent, "BOTTOM", 0, 4}
	elseif layout == 3 then
		frame:SetWidth(4 * size + 3 * margin + 2 * padding)
		frame:SetHeight(3 * size + 2 * margin + 2 * padding)
		frame.Pos = {"BOTTOM", UIParent, "BOTTOM", 450, 4}
	else
		frame:SetWidth(size + 2 * padding)
		frame:SetHeight(num * size + (num - 1) * margin + 2 * padding)
		frame.Pos = {"RIGHT", UIParent, "RIGHT", -4, 0}
	end
	frame:SetScale(1)

	-- Move The Buttons Into Position And Reparent Them
	MultiBarRight:SetParent(frame)
	MultiBarRight:EnableMouse(false)
	hooksecurefunc(MultiBarRight, "SetScale", function(self, scale)
		if scale < 1 then
			self:SetScale(1)
		end
	end)

	for i = 1, num do
		local button = _G["MultiBarRightButton"..i]
		table_insert(buttonList, button) -- Add The Button Object To The List
		button:SetSize(size, size)
		button:ClearAllPoints()

		if layout == 2 then
			if i == 1 then
				button:SetPoint("TOPLEFT", frame, padding, -padding)
			elseif i == 4 then
				local previous = _G["MultiBarRightButton1"]
				button:SetPoint("TOP", previous, "BOTTOM", 0, -margin)
			elseif i == 7 then
				local previous = _G["MultiBarRightButton3"]
				button:SetPoint("LEFT", previous, "RIGHT", 19 * size + 16 * margin, 0)
			elseif i == 10 then
				local previous = _G["MultiBarRightButton7"]
				button:SetPoint("TOP", previous, "BOTTOM", 0, -margin)
			else
				local previous = _G["MultiBarRightButton"..i - 1]
				button:SetPoint("LEFT", previous, "RIGHT", margin, 0)
			end
		elseif layout == 3 then
			if i == 1 then
				button:SetPoint("TOPLEFT", frame, padding, -padding)
			elseif i == 5 or i == 9 then
				local previous = _G["MultiBarRightButton"..i - 4]
				button:SetPoint("TOP", previous, "BOTTOM", 0, -margin)
			else
				local previous = _G["MultiBarRightButton"..i - 1]
				button:SetPoint("LEFT", previous, "RIGHT", margin, 0)
			end
		else
			if i == 1 then
				button:SetPoint("TOPRIGHT", frame, -padding, -padding)
			else
				local previous = _G["MultiBarRightButton"..i - 1]
				button:SetPoint("TOP", previous, "BOTTOM", 0, -margin)
			end
		end
	end

	-- Show/hide The Frame On A Given State Driver
	frame.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; show"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	-- Create Drag Frame And Drag Functionality
	frame:SetPoint(frame.Pos[1], frame.Pos[2], frame.Pos[3], frame.Pos[4], frame.Pos[5])
	K.Mover(frame, "Bar4", "Bar4", frame.Pos)

	if C["ActionBar"].Bar4Fade == true and K.BarFaderConfig then
		K.CreateButtonFrameFader(frame, buttonList)
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