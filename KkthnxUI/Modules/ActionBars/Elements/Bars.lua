local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:NewModule("ActionBar")

-- Cache global references
local _G = _G

local UIParent = UIParent
local GetVehicleBarIndex = GetVehicleBarIndex
local UnitExists = UnitExists
local VehicleExit = VehicleExit
local PetDismiss = PetDismiss
local tinsert = table.insert
local RegisterStateDriver = RegisterStateDriver
local ceil = math.ceil
local min = math.min
local select = select
local GetCVarBool = GetCVarBool

-- Layout constants
local margin, padding = 6, 0

function Module:UpdateAllSize()
	if not C["ActionBar"].Enable then
		return
	end

	Module:UpdateActionSize("Bar1")
	Module:UpdateActionSize("Bar2")
	Module:UpdateActionSize("Bar3")
	Module:UpdateActionSize("Bar4")
	Module:UpdateActionSize("Bar5")
	Module:UpdateActionSize("Bar6")
	Module:UpdateActionSize("Bar7")
	Module:UpdateActionSize("Bar8")
	Module:UpdateActionSize("BarPet")
	Module:UpdateStanceBar()
	Module:UpdateVehicleButton()
end

function Module:UpdateFontSize(button, fontSize)
	button.Name:SetFontObject(K.UIFontOutline)
	button.Name:SetFont(select(1, button.Name:GetFont()), fontSize, select(3, button.Name:GetFont()))

	button.Count:SetFontObject(K.UIFontOutline)
	button.Count:SetFont(select(1, button.Count:GetFont()), fontSize, select(3, button.Count:GetFont()))

	button.HotKey:SetFontObject(K.UIFontOutline)
	button.HotKey:SetFont(select(1, button.HotKey:GetFont()), fontSize, select(3, button.HotKey:GetFont()))
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
		local column = 3
		local rows = 2

		frame:SetWidth(3 * size + (column - 1) * margin + 2 * padding)
		frame:SetHeight(size * rows + (rows - 1) * margin + 2 * padding)
		frame.mover:SetSize(frame:GetSize())
		frame.child:SetSize(frame:GetSize())
		frame.child.mover:SetSize(frame:GetSize())
		frame.child.mover.isDisable = false

		for i = 1, 12 do
			local button = frame.buttons[i]
			button:SetSize(size, size)
			button:ClearAllPoints()

			if i == 1 then
				button:SetPoint("TOPLEFT", frame, padding, -padding)
			elseif i == 7 then
				button:SetPoint("TOPLEFT", frame.child, padding, -padding)
			elseif mod(i - 1, 3) == 0 then
				button:SetPoint("TOP", frame.buttons[i - 3], "BOTTOM", 0, -margin)
			else
				button:SetPoint("LEFT", frame.buttons[i - 1], "RIGHT", margin, 0)
			end

			button:Show()
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

	self.buttonConfig.clickOnDown = GetCVarBool("ActionButtonUseKeyDown")
	self.buttonConfig.showGrid = C["ActionBar"].Grid
	self.buttonConfig.flyoutDirection = directions[C["ActionBar"]["Bar" .. i .. "Flyout"]]
	self.buttonConfig.actionButtonUI = true -- rotation highlight

	local hotkey = self.buttonConfig.text.hotkey
	hotkey.font.font = K.UIFontOutline
	hotkey.font.size = C["ActionBar"]["Bar" .. i .. "Font"]
	hotkey.font.flags = K.UIFontOutlineStyle
	hotkey.position.anchor = "TOPRIGHT"
	hotkey.position.relAnchor = false
	hotkey.position.offsetX = 0
	hotkey.position.offsetY = -2
	hotkey.justifyH = "RIGHT"

	local count = self.buttonConfig.text.count
	count.font.font = K.UIFontOutline
	count.font.size = C["ActionBar"]["Bar" .. i .. "Font"]
	count.font.flags = K.UIFontOutlineStyle
	count.position.anchor = "BOTTOMRIGHT"
	count.position.relAnchor = false
	count.position.offsetX = 2
	count.position.offsetY = 0
	count.justifyH = "RIGHT"

	local macro = self.buttonConfig.text.macro
	macro.font.font = K.UIFontOutline
	macro.font.size = C["ActionBar"]["Bar" .. i .. "Font"]
	macro.font.flags = K.UIFontOutlineStyle
	macro.position.anchor = "BOTTOM"
	macro.position.relAnchor = false
	macro.position.offsetX = 0
	macro.position.offsetY = 0
	macro.justifyH = "CENTER"

	local hideElements = self.buttonConfig.hideElements
	hideElements.hotkey = not C["ActionBar"].Hotkeys
	hideElements.macro = not C["ActionBar"].Macro
	hideElements.equipped = not C["ActionBar"].EquipColor

	local lockBars = C["ActionBar"].ButtonLock
	for _, button in next, self.buttons do
		self.buttonConfig.keyBoundTarget = button.bindName
		button.keyBoundTarget = self.buttonConfig.keyBoundTarget

		button:SetAttribute("buttonlock", lockBars)
		button:SetAttribute("checkmouseovercast", true)
		button:SetAttribute("checkfocuscast", true)
		button:SetAttribute("checkselfcast", true)

		button:UpdateConfig(self.buttonConfig)
	end
end

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
	SetCVar("ActionButtonUseKeyDown", C["ActionBar"].KeyDown and 1 or 0)

	for i = 1, 8 do
		local frame = _G["KKUI_ActionBar" .. i]
		if frame then
			Module.UpdateButtonConfig(frame, i)
		end
	end
end

function Module:ReassignBindings()
	if InCombatLockdown() or Module.isHousing then
		return
	end

	for index = 1, 8 do
		local frame = Module.headers[index]
		if frame then
			ClearOverrideBindings(frame)

			for _, button in next, frame.buttons do
				for _, key in next, { GetBindingKey(button.keyBoundTarget) } do
					if key and key ~= "" then
						SetOverrideBindingClick(frame, false, key, button:GetName())
					end
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
		if frame then
			ClearOverrideBindings(frame)
		end
	end
end

function Module:UpdateHousingState(state)
	Module.isHousing = (state ~= 0)
	if Module.isHousing then
		Module:ClearBindings()
	else
		Module:ReassignBindings()
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

	if not C["ActionBar"].Enable then
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
		"CreateBarFadeGlobal",
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
	K:RegisterEvent("HOUSE_EDITOR_MODE_CHANGED", Module.UpdateHousingState)

	if AdiButtonAuras then
		AdiButtonAuras:RegisterLAB("LibActionButton-1.0")
	end
end
