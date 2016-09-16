local K, C, L, _ = select(2, ...):unpack()
if C.ActionBar.Enable ~= true then return end

-- LUA API
local _G = _G

-- WOW API
local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local HasOverrideActionBar = HasOverrideActionBar
local HasVehicleActionBar = HasVehicleActionBar

-- SETUP MAIN ACTION BAR BY TUKZ
local ActionBar1 = CreateFrame("Frame", "Bar1Holder", ActionBarAnchor, "SecureHandlerStateTemplate")
ActionBar1:SetAllPoints(ActionBarAnchor)

local Page = {
	["DRUID"] = "[bonusbar:1,nostealth] 7; [bonusbar:1,stealth] 8; [bonusbar:2] 8; [bonusbar:3] 9; [bonusbar:4] 10;",
	["ROGUE"] = "[bonusbar:1] 7;",
	["DEFAULT"] = "[vehicleui][possessbar] 12; [shapeshift] 13; [overridebar] 14; [bar:2] 2; [bar:3] 3; [bar:4] 4; [bar:5] 5; [bar:6] 6;",
}

local function GetBar()
	local Condition = Page["DEFAULT"]
	local Class = select(2, UnitClass("player"))
	local Page = Page[Class]

	if Page then
		Condition = Condition .. " " .. Page
	end

	Condition = Condition .. " [form] 1; 1"

	return Condition
end

ActionBar1:RegisterEvent("PLAYER_LOGIN")
ActionBar1:RegisterEvent("PLAYER_ENTERING_WORLD")
ActionBar1:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR")
-- ActionBar1:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR")
ActionBar1:RegisterEvent("CURRENCY_DISPLAY_UPDATE")
ActionBar1:RegisterEvent("BAG_UPDATE")
ActionBar1:SetScript("OnEvent", function(self, event, unit, ...)
	if event == "PLAYER_LOGIN" or event == "ACTIVE_TALENT_GROUP_CHANGED" then
		local Button
		for i = 1, NUM_ACTIONBAR_BUTTONS do
			local Button = _G["ActionButton"..i]
			self:SetFrameRef("ActionButton"..i, Button)
		end

		self:Execute([[
		Button = table.new()
		for i = 1, 12 do
			table.insert(Button, self:GetFrameRef("ActionButton"..i))
		end
		]])

		self:SetAttribute("_onstate-page", [[
		if HasTempShapeshiftActionBar() then
			newstate = GetTempShapeshiftBarIndex() or newstate
		end

		for i, Button in ipairs(Button) do
			Button:SetAttribute("actionpage", tonumber(newstate))
		end
		]])

		RegisterStateDriver(self, "page", GetBar())
	elseif event == "PLAYER_ENTERING_WORLD" then
		local Button
		for i = 1, 12 do
			local Button = _G["ActionButton"..i]
			Button:SetSize(C.ActionBar.ButtonSize, C.ActionBar.ButtonSize)
			Button:ClearAllPoints()
			Button:SetParent(Bar1Holder)
			Button:SetFrameStrata("BACKGROUND")
			Button:SetFrameLevel(15)
			if i == 1 then
				Button:SetPoint("BOTTOMLEFT", Bar1Holder, 0, 0)
			else
				local Previous = _G["ActionButton"..i-1]
				Button:SetPoint("LEFT", Previous, "RIGHT", C.ActionBar.ButtonSpace, 0)
			end
		end
	elseif event == "UPDATE_VEHICLE_ACTIONBAR" or event == "UPDATE_OVERRIDE_ACTIONBAR" then
		-- if not InCombatLockdown() and (HasVehicleActionBar() or HasOverrideActionBar()) then
		if not InCombatLockdown() and (HasVehicleActionBar()) then
			for i = 1, NUM_ACTIONBAR_BUTTONS do
				local Button = _G["ActionButton"..i]
				ActionButton_Update(Button)
			end
		end
	else
		MainMenuBar_OnEvent(self, event, ...)
	end
end)