local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:NewModule("ActionBar")

-- Global references for convenience and performance
local _G = _G
local UIParent = UIParent
local GetVehicleBarIndex = GetVehicleBarIndex
local UnitExists = UnitExists
local VehicleExit = VehicleExit
local PetDismiss = PetDismiss
local tinsert = table.insert
local RegisterStateDriver = RegisterStateDriver

-- Layout constants
local margin, padding = 6, 0

function Module:UpdateAllSize()
	-- check if action bar feature is enabled
	if not C["ActionBar"].Enable then
		return
	end

	-- update size of action bars
	local actionBars = { "Bar1", "Bar2", "Bar3", "Bar4", "Bar5", "Bar6", "Bar7", "Bar8", "BarPet" }
	for _, bar in ipairs(actionBars) do
		Module:UpdateActionSize(bar)
	end

	-- update stance bar
	Module:UpdateStanceBar()

	-- update vehicle button
	Module:UpdateVehicleButton()
end

function Module:UpdateFontSize(button, fontSize)
	-- Table containing elements of the button that need to have their font size updated
	local buttonElements = { "Name", "Count", "HotKey" }
	for _, element in ipairs(buttonElements) do
		-- Set font object
		button[element]:SetFontObject(K.UIFontOutline)
		-- Set font family, size, and style
		button[element]:SetFont(select(1, button[element]:GetFont()), fontSize, select(3, button[element]:GetFont()))
	end
end

function Module:UpdateActionSize(name)
	local frame = _G["KKUI_Action" .. name]
	if not frame then
		return
	end

	local size = C["ActionBar"][name .. "Size"]
	local fontSize = C["ActionBar"][name .. "Font"]
	local num = C["ActionBar"][name .. "Num"]
	local perRow = C["ActionBar"][name .. "PerRow"]
	if name == "BarPet" then
		num = 10
	end

	if num == 0 then
		-- Setting the number of columns and rows for the frame
		local column = 3
		local rows = 2

		-- Setting the width and height of the frame, the mover, and the child
		frame:SetWidth(3 * size + (column - 1) * margin + 2 * padding)
		frame:SetHeight(size * rows + (rows - 1) * margin + 2 * padding)
		frame.mover:SetSize(frame:GetSize())
		frame.child:SetSize(frame:GetSize())
		frame.child.mover:SetSize(frame:GetSize())

		-- Enabling the child mover
		frame.child.mover.isDisable = false

		-- Loop through all buttons in the frame
		for i = 1, 12 do
			local button = frame.buttons[i]
			-- Set the size of the button
			button:SetSize(size, size)
			-- Clear any existing points on the button
			button:ClearAllPoints()
			-- Position the button based on its index in the loop
			if i == 1 then
				button:SetPoint("TOPLEFT", frame, padding, -padding)
			elseif i == 7 then
				button:SetPoint("TOPLEFT", frame.child, padding, -padding)
			elseif mod(i - 1, 3) == 0 then
				button:SetPoint("TOP", frame.buttons[i - 3], "BOTTOM", 0, -margin)
			else
				button:SetPoint("LEFT", frame.buttons[i - 1], "RIGHT", margin, 0)
			end
			-- Show the button
			button:Show()
			-- Update the font size of the button
			Module:UpdateFontSize(button, fontSize)
		end
	else
		for i = 1, num do
			local button = frame.buttons[i]
			button:SetSize(size, size)
			button:ClearAllPoints()
			if i == 1 then
				button:SetPoint("TOPLEFT", frame, padding, -padding)
			elseif mod(i - 1, perRow) == 0 then
				button:SetPoint("TOP", frame.buttons[i - perRow], "BOTTOM", 0, -margin)
			else
				button:SetPoint("LEFT", frame.buttons[i - 1], "RIGHT", margin, 0)
			end
			button:Show()
			Module:UpdateFontSize(button, fontSize)
		end

		for i = num + 1, 12 do
			local button = frame.buttons[i]
			if not button then
				break
			end
			button:Hide()
		end

		local column = min(num, perRow)
		local rows = ceil(num / perRow)
		frame:SetWidth(column * size + (column - 1) * margin + 2 * padding)
		frame:SetHeight(size * rows + (rows - 1) * margin + 2 * padding)
		frame.mover:SetSize(frame:GetSize())
		if frame.child then
			frame.child.mover.isDisable = true
		end
	end
end

-- Update the button configuration for action bars
local directions = { "UP", "DOWN", "LEFT", "RIGHT" }
function Module:UpdateButtonConfig(i)
	if not self.buttonConfig then
		self.buttonConfig = {
			hideElements = {},
			text = {
				hotkey = {
					font = {},
					position = {},
				},
				count = {
					font = {},
					position = {},
				},
				macro = {
					font = {},
					position = {},
				},
			},
		}
	end

	self.buttonConfig.clickOnDown = true
	self.buttonConfig.showGrid = C["ActionBar"]["Grid"]
	self.buttonConfig.flyoutDirection = directions[C["ActionBar"]["Bar" .. i .. "Flyout"]]

	local hotkey = self.buttonConfig.text.hotkey
	hotkey.font.font = K.UIFont
	hotkey.font.size = C["ActionBar"]["Bar" .. i .. "Font"]
	hotkey.font.flags = K.UIFontStyle

	hotkey.position.anchor = "TOPRIGHT"
	hotkey.position.relAnchor = false
	hotkey.position.offsetX = 0
	hotkey.position.offsetY = -2
	hotkey.justifyH = "RIGHT"

	-- Initialize the count text configuration
	local count = self.buttonConfig.text.count
	local fontConfig = count.font
	local positionConfig = count.position

	-- Set the font style for the count text
	fontConfig.font = K.UIFont
	fontConfig.size = C["ActionBar"]["Bar" .. i .. "Font"]
	fontConfig.flags = K.UIFontStyle

	-- Set the position of the count text
	positionConfig.anchor = "BOTTOMRIGHT"
	positionConfig.relAnchor = false
	positionConfig.offsetX = 2
	positionConfig.offsetY = 0
	count.justifyH = "RIGHT"

	-- Initialize the macro text configuration
	local macro = self.buttonConfig.text.macro
	local fontConfig = macro.font
	local positionConfig = macro.position

	-- Set the font style for the macro text
	fontConfig.font = K.UIFont
	fontConfig.size = C["ActionBar"]["Bar" .. i .. "Font"]
	fontConfig.flags = K.UIFontStyle

	-- Set the position of the macro text
	positionConfig.anchor = "BOTTOM"
	positionConfig.relAnchor = false
	positionConfig.offsetX = 0
	positionConfig.offsetY = 0
	macro.justifyH = "CENTER"

	local hideElements = self.buttonConfig.hideElements
	hideElements.hotkey = not C["ActionBar"]["Hotkeys"]
	hideElements.macro = not C["ActionBar"]["Macro"]
	hideElements.equipped = not C["ActionBar"]["EquipColor"]

	-- Update button attributes and configuration based on CVAR values and button config
	local lockBars = GetCVar("lockActionBars") == "1"
	for _, button in next, self.buttons do
		self.buttonConfig.keyBoundTarget = button.bindName
		button.keyBoundTarget = self.buttonConfig.keyBoundTarget

		button:SetAttribute("buttonlock", lockBars)
		button:SetAttribute("unlockedpreventdrag", not lockBars)
		button:SetAttribute("checkmouseovercast", true)
		button:SetAttribute("checkfocuscast", true)
		button:SetAttribute("checkselfcast", true)

		-- Update the config for the button
		button:UpdateConfig(self.buttonConfig)
	end
end

-- Update action bar visibility and configuration based on settings
local fullPage = "[bar:6]6;[bar:5]5;[bar:4]4;[bar:3]3;[bar:2]2;[possessbar]16;[overridebar]18;[shapeshift]17;[vehicleui]16;[bonusbar:5]11;[bonusbar:4]10;[bonusbar:3]9;[bonusbar:2]8;[bonusbar:1]7;1"

function Module:UpdateBarVisibility()
	for i = 1, 8 do
		local frame = _G["KKUI_ActionBar" .. i]
		if frame then
			if C["ActionBar"]["Bar" .. i] then
				frame:Show()
				frame.mover.isDisable = false
				RegisterStateDriver(frame, "visibility", frame.visibility)
			else
				frame:Hide()
				frame.mover.isDisable = true
				UnregisterStateDriver(frame, "visibility")
			end
		end
	end
end

function Module:UpdateBarConfig()
	for i = 1, 8 do
		local frame = _G["KKUI_ActionBar" .. i]
		if frame then
			Module.UpdateButtonConfig(frame, i)
		end
	end
end

function Module:ReassignBindings()
	if InCombatLockdown() then
		return
	end

	for index = 1, 8 do
		local frame = Module.headers[index]
		for _, button in next, frame.buttons do
			for _, key in next, { GetBindingKey(button.keyBoundTarget) } do
				if key and key ~= "" then
					SetOverrideBindingClick(frame, false, key, button:GetName(), "Keybind")
				end
			end
		end
	end
end

function Module:ClearBindings()
	if InCombatLockdown() then
		return
	end

	for index = 1, 8 do
		local frame = Module.headers[index]
		ClearOverrideBindings(frame)
	end
end

function Module:CreateBars()
	Module.headers = {}
	for index = 1, 8 do
		Module.headers[index] = CreateFrame("Frame", "KKUI_ActionBar" .. index, UIParent, "SecureHandlerStateTemplate")
	end

	local BAR_DATA = {
		[1] = { page = 1, bindName = "ACTIONBUTTON", anchor = { "BOTTOM", UIParent, "BOTTOM", 0, 4 } },
		[2] = {
			page = 6,
			bindName = "MULTIACTIONBAR1BUTTON",
			anchor = { "BOTTOM", _G.KKUI_ActionBar1, "TOP", 0, margin },
		},
		[3] = {
			page = 5,
			bindName = "MULTIACTIONBAR2BUTTON",
			anchor = { "BOTTOM", _G.KKUI_ActionBar2, "TOP", 0, margin },
		},
		[4] = { page = 3, bindName = "MULTIACTIONBAR3BUTTON", anchor = { "RIGHT", UIParent, "RIGHT", -4, 0 } },
		[5] = {
			page = 4,
			bindName = "MULTIACTIONBAR4BUTTON",
			anchor = { "RIGHT", _G.KKUI_ActionBar4, "LEFT", -margin, 0 },
		},
		[6] = { page = 13, bindName = "MULTIACTIONBAR5BUTTON", anchor = { "CENTER", UIParent, "CENTER", 0, 0 } },
		[7] = { page = 14, bindName = "MULTIACTIONBAR6BUTTON", anchor = { "CENTER", UIParent, "CENTER", 0, 40 } },
		[8] = { page = 15, bindName = "MULTIACTIONBAR7BUTTON", anchor = { "CENTER", UIParent, "CENTER", 0, 80 } },
	}

	local mIndex = 1
	for index = 1, 8 do
		local data = BAR_DATA[index]
		local frame = Module.headers[index]
		frame.mover = K.Mover(frame, "Actionbar" .. index, "Bar" .. index, data.anchor)
		Module.movers[mIndex] = frame.mover
		mIndex = mIndex + 1
		frame.buttons = {}

		for i = 1, 12 do
			local button = K.LibActionButton:CreateButton(i, "$parentButton" .. i, frame)
			button:SetState(0, "action", i)
			for k = 1, 18 do
				button:SetState(k, "action", (k - 1) * 12 + i)
			end
			if i == 12 then
				button:SetState(GetVehicleBarIndex(), "custom", {
					func = function()
						if UnitExists("vehicle") then
							VehicleExit()
						else
							PetDismiss()
						end
					end,
					texture = 136190, -- Spell_Shadow_SacrificialShield
					tooltip = LEAVE_VEHICLE,
				})
			end
			button.MasqueSkinned = true
			button.bindName = data.bindName .. i

			tinsert(frame.buttons, button)
			tinsert(Module.buttons, button)
		end

		frame.visibility = index == 1 and "[petbattle] hide; show" or "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; show"

		frame:SetAttribute(
			"_onstate-page",
			[[
			self:SetAttribute("state", newstate)
			control:ChildUpdate("state", newstate)
		]]
		)
		RegisterStateDriver(frame, "page", index == 1 and fullPage or data.page)
	end

	K.LibActionButton.RegisterCallback(Module, "OnButtonUpdate", Module.UpdateBarBorderColor)

	if K.LibActionButton.flyoutHandler then
		K.LibActionButton.flyoutHandler.Background:Hide()
		for _, button in next, K.LibActionButton.FlyoutButtons do
			Module:StyleActionButton(button)
		end
	end

	local function delayUpdate()
		Module:UpdateBarConfig()
		K:UnregisterEvent("PLAYER_REGEN_ENABLED", delayUpdate)
	end
	K:RegisterEvent("CVAR_UPDATE", function(_, var)
		if var == "lockActionBars" then
			if InCombatLockdown() then
				K:RegisterEvent("PLAYER_REGEN_ENABLED", delayUpdate)
				return
			end
			Module:UpdateBarConfig()
		end
	end)
end

function Module:OnEnable()
	Module.buttons = {}
	Module:CreateMicroMenu()

	if C_AddOns.IsAddOnLoaded("ConsolePort") then
		return
	end

	if not C["ActionBar"]["Enable"] then
		return
	end

	Module.movers = {}
	local loadActionBarModules = {
		"CreateBars",
		"CreateExtrabar",
		"CreateLeaveVehicle",
		"CreatePetbar",
		"CreateStancebar",
		"ReskinBars",
		"UpdateBarConfig",
		"UpdateBarVisibility",
		"UpdateAllSize",
		"HideBlizz",
	}

	for _, funcName in ipairs(loadActionBarModules) do
		local func = self[funcName]
		if type(func) == "function" then
			local success, err = pcall(func, self)
			if not success then
				error("Error in function " .. funcName .. ": " .. tostring(err), 2)
			end
		end
	end

	if C_PetBattles.IsInBattle() then
		Module:ClearBindings()
	else
		Module:ReassignBindings()
	end
	K:RegisterEvent("UPDATE_BINDINGS", Module.ReassignBindings)
	K:RegisterEvent("PET_BATTLE_CLOSE", Module.ReassignBindings)
	K:RegisterEvent("PET_BATTLE_OPENING_DONE", Module.ClearBindings)

	if AdiButtonAuras then
		AdiButtonAuras:RegisterLAB("LibActionButton-1.0")
	end
end
