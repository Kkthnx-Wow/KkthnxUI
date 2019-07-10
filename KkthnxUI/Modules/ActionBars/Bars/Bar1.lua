local K, C = unpack(select(2, ...))
local Module = K:NewModule("ActionBar")

local _G = _G
local next = next
local table_insert = table.insert

local CreateFrame = _G.CreateFrame
local GetActionTexture = _G.GetActionTexture
local NUM_ACTIONBAR_BUTTONS = _G.NUM_ACTIONBAR_BUTTONS
local RegisterStateDriver = _G.RegisterStateDriver
local UIParent = _G.UIParent

local function GetPageDriver()
	local driver = "[overridebar]override; [possessbar]possess; [shapeshift]shapeshift; [vehicleui]vehicle; [bar:2]2; [bar:3]3; [bar:4]4; [bar:5]5; [bar:6]6"

	if (K.Class == "DRUID") then
		if (C["ActionBar"].DisableStancePages) then
			driver = driver .. "; [bonusbar:1,nostealth] 7; [bonusbar:1,stealth] 7; [bonusbar:2] 8; [bonusbar:3] 9; [bonusbar:4] 10"
		else
			driver = driver .. "; [bonusbar:1,nostealth] 7; [bonusbar:1,stealth] 8; [bonusbar:2] 8; [bonusbar:3] 9; [bonusbar:4] 10"
		end

	elseif (K.Class == "MONK") then
		driver = driver .. "; [bonusbar:1] 7; [bonusbar:2] 8; [bonusbar:3] 9"

	elseif (K.Class == "PRIEST") then
		driver = driver .. "; [bonusbar:1] 7"

	elseif (K.Class == "ROGUE") then
		driver = driver .. "; [bonusbar:1] 7"

	elseif (K.Class == "WARRIOR") then
		driver = driver .. "; [bonusbar:1] 7; [bonusbar:2] 8"
	end
	driver = driver .. "; [form] 1; 1"

	return driver
end

function Module:OnEnable()
	if not C["ActionBar"].Enable then
		return
	end

	local padding, margin, size = 0, 6, 34
	local num = NUM_ACTIONBAR_BUTTONS
	local buttonList = {}
	local layout = C["ActionBar"].Style.Value

	-- Create The Frame To Hold The Buttons
	local frame = CreateFrame("Frame", "KkthnxUI_ActionBar1", UIParent, "SecureHandlerStateTemplate")
	frame:SetWidth(num * size + (num - 1) * margin + 2 * padding)
	frame:SetHeight(size + 2 * padding)
	if layout == 5 then
		frame.Pos = {"BOTTOM", UIParent, "BOTTOM", -120, 4}
	else
		frame.Pos = {"BOTTOM", UIParent, "BOTTOM", 0, 4}
	end
	frame:SetScale(1)

	for i = 1, num do
		local button = _G["ActionButton"..i]
		table_insert(buttonList, button) -- Add The Button Object To The List
		button:SetParent(frame)
		button:SetSize(size, size)
		button:ClearAllPoints()
		if i == 1 then
			button:SetPoint("BOTTOMLEFT", frame, padding, padding)
		else
			local previous = _G["ActionButton"..i - 1]
			button:SetPoint("LEFT", previous, "RIGHT", margin, 0)
		end
	end

	-- Show/hide The Frame On A Given State Driver
	frame.frameVisibility = "[petbattle] hide; show"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	-- Create Drag Frame And Drag Functionality
	frame:SetPoint(frame.Pos[1], frame.Pos[2], frame.Pos[3], frame.Pos[4], frame.Pos[5])
	K.Mover(frame, "Bar1", "Bar1", frame.Pos)

	for i, button in next, buttonList do
		frame:SetFrameRef("ActionButton"..i, button)
	end

	frame:Execute([[
	buttons = table.new()
	for i = 1, 12 do
		table.insert(buttons, self:GetFrameRef("ActionButton"..i))
	end
	]])

	-- Note that the functions meant to check for the various types of bars
	-- sometimes will return 'false' directly after a page change, when they should be 'true'.
	-- No idea as to why this randomly happens, but the macro driver at least responds correctly,
	-- and the bar index can still be retrieved correctly, so for now we just skip the checks.

	-- Affected functions, which we choose to avoid/work around here:
	-- HasVehicleActionBar()
	-- HasOverrideActionBar()
	-- HasTempShapeshiftActionBar()
	-- HasBonusActionBar()
	frame:SetAttribute("_onstate-page", [[
	local page;
	if (newstate == "vehicle")
	or (newstate == "override")
	or (newstate == "shapeshift")
	or (newstate == "possess")
	or (newstate == "11") then
		if (newstate == "vehicle") then
			page = GetVehicleBarIndex();
		elseif (newstate == "override") then
			page = GetOverrideBarIndex();
		elseif (newstate == "shapeshift") then
			page = GetTempShapeshiftBarIndex();
		elseif HasBonusActionBar() and (GetActionBarPage() == 1) then
			page = GetBonusBarIndex();
		else
			page = 12;
		end
	end

	if page then
		newstate = page;
	end

	for i, button in ipairs(buttons) do
		button:SetAttribute("actionpage", tonumber(newstate))
	end
	]])
	RegisterStateDriver(frame, "page", GetPageDriver())

	-- Add Elements
	self:CreateBar2()
	self:CreateBar3()
	self:CreateBar4()
	self:CreateBar5()
	self:CreateExtrabar()
	self:CreateLeaveVehicle()
	self:CreatePetbar()
	self:CreateStancebar()
	self:HideBlizz()
	self:HookActionEvents()

	-- Vehicle Fix
	local function vehicleFix()
		for _, button in next, buttonList do
			local action = button.action
			local icon = button.icon

			if action >= 120 then
				local texture = GetActionTexture(action)

				if (texture) then
					icon:SetTexture(texture)
					icon:Show()
				else
					if icon:IsShown() then
						icon:Hide()
					end
				end
			end
		end
	end
	K:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR", vehicleFix)
	K:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR", vehicleFix)
end