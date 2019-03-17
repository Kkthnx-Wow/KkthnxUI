local K, C = unpack(select(2, ...))
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

local ActionBar1 = CreateFrame("Frame", "Bar1Holder", ActionBarAnchor, "SecureHandlerStateTemplate")
ActionBar1:SetAllPoints(ActionBarAnchor)

for i = 1, NUM_ACTIONBAR_BUTTONS do
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

		-- Note that the functions meant to check for the various types of bars
		-- sometimes will return 'false' directly after a page change, when they should be 'true'.
		-- No idea as to why this randomly happens, but the macro driver at least responds correctly,
		-- and the bar index can still be retrieved correctly, so for now we just skip the checks.
		--
		-- Affected functions, which we choose to avoid/work around here:
		-- 	HasVehicleActionBar()
		-- 	HasOverrideActionBar()
		-- 	HasTempShapeshiftActionBar()
		-- 	HasBonusActionBar()
		self:SetAttribute("_onstate-page", [[
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