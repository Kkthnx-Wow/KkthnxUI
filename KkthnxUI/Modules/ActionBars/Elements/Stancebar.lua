local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("ActionBar")

local tinsert = tinsert

local margin, padding = 6, 0
local num = NUM_STANCE_SLOTS or 10

-- Update the stance bar's size, layout, and button positions
function Module:UpdateStanceBar()
	if InCombatLockdown() then
		return
	end

	local frame = _G["KKUI_ActionBarStance"]
	if not frame then
		return
	end

	local size = C["ActionBar"].BarStanceSize
	local fontSize = C["ActionBar"].BarStanceFont
	local perRow = C["ActionBar"].BarStancePerRow
	local column = math.min(num, perRow)
	local rows = math.ceil(num / perRow)
	local buttons = frame.buttons
	local button, buttonX, buttonY

	for i = 1, num do
		button = buttons[i]
		if not button then
			break
		end

		button:SetSize(size, size)
		buttonX = ((i - 1) % perRow) * (size + margin) + padding
		buttonY = math.floor((i - 1) / perRow) * (size + margin) + padding
		button:ClearAllPoints()
		button:SetPoint("TOPLEFT", frame, "TOPLEFT", buttonX, -buttonY)
		Module:UpdateFontSize(button, fontSize)
	end

	frame:SetWidth(column * size + (column - 1) * margin + 2 * padding)
	frame:SetHeight(size * rows + (rows - 1) * margin + 2 * padding)
	frame.mover:SetSize(size, size)
end

function Module:UpdateStance()
	local inCombat = InCombatLockdown()
	local numForms = GetNumShapeshiftForms()
	local texture, isActive, isCastable
	local icon, cooldown
	local start, duration, enable

	for i, button in pairs(self.actionButtons) do
		if not inCombat then
			button:Hide()
		end
		icon = button.icon
		if i <= numForms then
			texture, isActive, isCastable = GetShapeshiftFormInfo(i)
			icon:SetTexture(texture)

			--Cooldown stuffs
			cooldown = button.cooldown
			if texture then
				if not inCombat then
					button:Show()
				end
				cooldown:Show()
			else
				cooldown:Hide()
			end
			start, duration, enable = GetShapeshiftFormCooldown(i)
			CooldownFrame_Set(cooldown, start, duration, enable)

			if isActive then
				button:SetChecked(true)
			else
				button:SetChecked(false)
			end

			if isCastable then
				icon:SetVertexColor(1.0, 1.0, 1.0)
			else
				icon:SetVertexColor(0.4, 0.4, 0.4)
			end
		end
	end
end

function Module:StanceBarOnEvent()
	Module:UpdateStanceBar()
	Module.UpdateStance(StanceBar)
end

function Module:CreateStancebar()
	local buttonList = {}
	local frame = CreateFrame("Frame", "KKUI_ActionBarStance", UIParent, "SecureHandlerStateTemplate")
	frame.mover = K.Mover(frame, "StanceBar", "StanceBar", { "BOTTOMLEFT", _G.KKUI_ActionBar3, "TOPLEFT", 0, margin })
	Module.movers[11] = frame.mover

	-- StanceBar
	StanceBar:SetParent(frame)
	StanceBar:EnableMouse(false)
	StanceBar:UnregisterAllEvents()

	for i = 1, num do
		local button = _G["StanceButton" .. i]
		button:SetParent(frame)
		tinsert(buttonList, button)
		tinsert(Module.buttons, button)
	end
	frame.buttons = buttonList

	-- Fix stance bar updating
	Module:StanceBarOnEvent()
	K:RegisterEvent("UPDATE_SHAPESHIFT_FORM", Module.StanceBarOnEvent)
	K:RegisterEvent("UPDATE_SHAPESHIFT_FORMS", Module.StanceBarOnEvent)
	K:RegisterEvent("UPDATE_SHAPESHIFT_USABLE", Module.StanceBarOnEvent)
	K:RegisterEvent("UPDATE_SHAPESHIFT_COOLDOWN", Module.StanceBarOnEvent)

	frame.frameVisibility = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; show"
	RegisterStateDriver(frame, "visibility", not C["ActionBar"].ShowStance and "hide" or frame.frameVisibility)
end
