local K, C, L, _ = select(2, ...):unpack()
if C.ActionBar.Enable ~= true then return end

-- LUA API
local _G = _G

-- WOW API
local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local HasOverrideActionBar = HasOverrideActionBar
local HasVehicleActionBar = HasVehicleActionBar
local Druid, Rogue = "", ""

-- SETUP MAIN ACTION BAR BY TUKZ
local bar = CreateFrame("Frame", "Bar1Holder", ActionBarAnchor, "SecureHandlerStateTemplate")
bar:SetAllPoints(ActionBarAnchor)

for i = 1, 12 do
	local button = _G["ActionButton"..i]
	button:SetSize(C.ActionBar.ButtonSize, C.ActionBar.ButtonSize)
	button:ClearAllPoints()
	button:SetParent(Bar1Holder)
	if i == 1 then
		button:SetPoint("BOTTOMLEFT", Bar1Holder, 0, 0)
	else
		local previous = _G["ActionButton"..i-1]
		button:SetPoint("LEFT", previous, "RIGHT", C.ActionBar.ButtonSpace, 0)
	end
end

local Page = {
	["DRUID"] = Druid,
	["ROGUE"] = Rogue,
	["DEFAULT"] = "[vehicleui:12] 12; [possessbar] 12; [overridebar] 14; [shapeshift] 13; [bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;",
}

local function GetBar()
	local condition = Page["DEFAULT"]
	local class = K.Class
	local page = Page[class]
	if page then condition = condition .. " " .. page end

	condition = condition .. " [form] 1; 1"

	return condition
end

bar:RegisterEvent("PLAYER_LOGIN")
bar:RegisterEvent("PLAYER_ENTERING_WORLD")
bar:RegisterEvent("KNOWN_CURRENCY_TYPES_UPDATE")
bar:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
bar:RegisterEvent("BAG_UPDATE")
bar:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR")
bar:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR")
bar:SetScript("OnEvent", function(self, event, ...)
	if event == "PLAYER_LOGIN" or event == "ACTIVE_TALENT_GROUP_CHANGED" then
		local button
		for i = 1, NUM_ACTIONBAR_BUTTONS do
			button = _G["ActionButton" .. i]
			self:SetFrameRef("ActionButton" .. i, button)
		end

		self:Execute([[
		buttons = table.new()
		for i = 1, 12 do
			table.insert(buttons, self:GetFrameRef("ActionButton"..i))
		end
		]])

		self:SetAttribute("_onstate-page", [[
		if HasTempShapeshiftActionBar() then
			newstate = GetTempShapeshiftBarIndex() or newstate
		end
		for i, buttons in ipairs(buttons) do
			buttons:SetAttribute("actionpage", tonumber(newstate))
		end
		]])

		RegisterStateDriver(self, "page", GetBar())
	elseif event == "UPDATE_VEHICLE_ACTIONBAR" or event == "UPDATE_OVERRIDE_ACTIONBAR" then
		if HasVehicleActionBar() then
			if not self.inVehicle then self.inVehicle = true end
		else
			if self.inVehicle then self.inVehicle = false end
		end
	else
		MainMenuBar_OnEvent(self, event, ...)
	end
end)