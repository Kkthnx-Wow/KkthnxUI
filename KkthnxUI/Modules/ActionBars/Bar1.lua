local _, C = unpack(select(2, ...))
if C["ActionBar"].Enable ~= true then
	return
end

local _G = _G
local select = select

local CreateFrame = _G.CreateFrame
local GetActionTexture = _G.GetActionTexture
local HasOverrideActionBar = _G.HasOverrideActionBar
local HasVehicleActionBar = _G.HasVehicleActionBar
local InCombatLockdown = _G.InCombatLockdown
local NUM_ACTIONBAR_BUTTONS = _G.NUM_ACTIONBAR_BUTTONS
local RegisterStateDriver = _G.RegisterStateDriver
local UnitClass = _G.UnitClass

local Druid, Rogue

local ActionBar1 = CreateFrame("Frame", "Bar1Holder", ActionBarAnchor, "SecureHandlerStateTemplate")
ActionBar1:SetAllPoints(ActionBarAnchor)

for i = 1, 12 do
	local button = _G["ActionButton" .. i]
	button:SetSize(C["ActionBar"].ButtonSize, C["ActionBar"].ButtonSize)
	button:ClearAllPoints()
	button:SetParent(Bar1Holder)

	if i == 1 then
		button:SetPoint("BOTTOMLEFT", Bar1Holder, 0, 0)
	else
		local previous = _G["ActionButton" .. i - 1]
		button:SetPoint("LEFT", previous, "RIGHT", C["ActionBar"].ButtonSpace, 0)
	end
end

local function GetPageDriver()
	local driver = "[vehicleui][overridebar][possessbar][shapeshift]possess; [bar:2]2; [bar:3]3; [bar:4]4; [bar:5]5; [bar:6]6"

	local _, playerClass = UnitClass("player")
	if (playerClass == "DRUID") then
		if (C["ActionBar"].DisableStancePages) then
			driver = driver .. "; [bonusbar:1,nostealth] 7; [bonusbar:1,stealth] 7; [bonusbar:2] 8; [bonusbar:3] 9; [bonusbar:4] 10"
		else 
			driver = driver .. "; [bonusbar:1,nostealth] 7; [bonusbar:1,stealth] 8; [bonusbar:2] 8; [bonusbar:3] 9; [bonusbar:4] 10"
		end
	elseif (playerClass == "MONK") then
		driver = driver .. "; [bonusbar:1] 7; [bonusbar:2] 8; [bonusbar:3] 9"
	elseif (playerClass == "PRIEST") then
		driver = driver .. "; [bonusbar:1] 7"
	elseif (playerClass == "ROGUE") and (not C["ActionBar"].DisableStancePages) then
		driver = driver .. "; [bonusbar:1] 7"
	elseif (playerClass == "WARRIOR") then
		driver = driver .. "; [bonusbar:1] 7; [bonusbar:2] 8" 
	end
	driver = driver .. "; [form] 1; 1"

	return driver
end

ActionBar1:RegisterEvent("PLAYER_LOGIN")
ActionBar1:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR")
ActionBar1:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR")
ActionBar1:SetScript("OnEvent", function(self, event)
	if event == "PLAYER_LOGIN" then
		for i = 1, NUM_ACTIONBAR_BUTTONS do
			local button = _G["ActionButton" .. i]
			self:SetFrameRef("ActionButton" .. i, button)
		end

		self:Execute([[
		buttons = table.new()
		for i = 1, 12 do
			table.insert(buttons, self:GetFrameRef("ActionButton"..i))
		end
		]])

		self:SetAttribute("_onstate-page", [[
		if (newstate == "possess") or (newstate == "11") then
			if HasVehicleActionBar() then
				newstate = GetVehicleBarIndex() 
			elseif HasOverrideActionBar() then 
				newstate = GetOverrideBarIndex() 
			elseif HasTempShapeshiftActionBar() then
				newstate = GetTempShapeshiftBarIndex() 
			elseif HasBonusActionBar() and (GetActionBarPage() == 1) then 
				newstate = GetBonusBarIndex()
			else
				newstate = nil
			end
			if (not newstate) then
				newstate = 12 
			end
		end
		for i, button in ipairs(buttons) do
			button:SetAttribute("actionpage", tonumber(newstate))
		end
		]])

		RegisterStateDriver(self, "page", GetPageDriver())
	elseif (event == "UPDATE_VEHICLE_ACTIONBAR") or (event == "UPDATE_OVERRIDE_ACTIONBAR") then
		if not InCombatLockdown() and (HasVehicleActionBar() or HasOverrideActionBar()) then
			for i = 1, NUM_ACTIONBAR_BUTTONS do
				local button = _G["ActionButton" .. i]
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
	end
end)
