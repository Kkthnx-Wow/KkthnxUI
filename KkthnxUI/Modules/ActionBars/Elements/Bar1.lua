local K, C, L = unpack(KkthnxUI)
local Module = K:NewModule("ActionBar")

local _G = _G
local next = _G.next
local table_insert = _G.table.insert

local CreateFrame = _G.CreateFrame
local GetActionTexture = _G.GetActionTexture
local UIParent = _G.UIParent

local cfg = C.Bars.Bar1
local margin, padding = C.Bars.BarMargin, C.Bars.BarPadding

function Module:UpdateAllScale()
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

	if num == 0 then
		local column = 3
		local rows = 2
		frame:SetWidth(3 * size + (column - 1) * margin + 2 * padding)
		frame:SetHeight(size * rows + (rows - 1) * margin + 2 * padding)
		frame.mover:SetSize(frame:GetSize())
		for i = 1, 12 do
			local button = frame.buttons[i]
			button:SetSize(size, size)
			button:ClearAllPoints()
			if i == 1 then
				button:SetPoint("TOPLEFT", frame, padding, -padding)
			elseif mod(i - 1, 3) == 0 then
				button:SetPoint("TOP", frame.buttons[i - 3], "BOTTOM", 0, -margin)
			else
				button:SetPoint("LEFT", frame.buttons[i - 1], "RIGHT", margin, 0)
			end
			button:SetAttribute("statehidden", false)
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
			button:SetAttribute("statehidden", false)
			button:Show()
			Module:UpdateFontSize(button, fontSize)
		end

		for i = num + 1, 12 do
			local button = frame.buttons[i]
			if not button then
				break
			end
			button:SetAttribute("statehidden", true)
			button:Hide()
		end

		local column = min(num, perRow)
		local rows = ceil(num / perRow)
		frame:SetWidth(column * size + (column - 1) * margin + 2 * padding)
		frame:SetHeight(size * rows + (rows - 1) * margin + 2 * padding)
		frame.mover:SetSize(frame:GetSize())
	end
end

function Module:CreateBar1()
	local num = NUM_ACTIONBAR_BUTTONS
	local RegisterStateDriver = _G.RegisterStateDriver
	local buttonList = {}

	local frame = CreateFrame("Frame", "KKUI_ActionBar1", UIParent, "SecureHandlerStateTemplate")
	frame.mover = K.Mover(frame, "Actionbar" .. "1", "Bar1", { "BOTTOM", UIParent, "BOTTOM", 0, 4 })
	Module.movers[1] = frame.mover

	for i = 1, num do
		local button = _G["ActionButton" .. i]
		table_insert(buttonList, button)
		table_insert(Module.buttons, button)
		button:SetParent(frame)
	end
	frame.buttons = buttonList

	frame.frameVisibility = "[petbattle] hide; show"
	RegisterStateDriver(frame, "visibility", frame.frameVisibility)

	if cfg.fader then
		Module.CreateButtonFrameFader(frame, buttonList, cfg.fader)
	end

	local actionPage = "[bar:6]6;[bar:5]5;[bar:4]4;[bar:3]3;[bar:2]2;[possessbar]16;[overridebar]18;[shapeshift]17;[vehicleui]16;[bonusbar:5]11;[bonusbar:4]10;[bonusbar:3]9;[bonusbar:2]8;[bonusbar:1]7;1"
	local buttonName = "ActionButton"
	for i, button in next, buttonList do
		frame:SetFrameRef(buttonName .. i, button)
	end

	frame:Execute(([[
		buttons = table.new()
		for i = 1, %d do
			tinsert(buttons, self:GetFrameRef("%s"..i))
		end
	]]):format(num, buttonName))

	frame:SetAttribute(
		"_onstate-page",
		[[
		for _, button in next, buttons do
			button:SetAttribute("actionpage", newstate)
		end
	]]
	)
	RegisterStateDriver(frame, "page", actionPage)

	-- Fix button texture
	local function FixActionBarTexture()
		for _, button in next, buttonList do
			local action = button.action
			if action < 120 then
				break
			end

			local icon = button.icon
			local texture = GetActionTexture(action)
			if texture then
				icon:SetTexture(texture)
				icon:Show()
			else
				icon:Hide()
			end
			Module.UpdateButtonStatus(button)
		end
	end
	K:RegisterEvent("SPELL_UPDATE_ICON", FixActionBarTexture)
	K:RegisterEvent("UPDATE_VEHICLE_ACTIONBAR", FixActionBarTexture)
	K:RegisterEvent("UPDATE_OVERRIDE_ACTIONBAR", FixActionBarTexture)
end

function Module:OnEnable()
	Module.buttons = {}
	Module:CreateMicroMenu()

	if C["ActionBar"].Enable then
		if IsAddOnLoaded("Dominos") or IsAddOnLoaded("Bartender4") or IsAddOnLoaded("RazerNaga") then
			return
		end

		Module.movers = {}
		Module:CreateBar1()
		Module:CreateBar2()
		Module:CreateBar3()
		Module:CreateBar4()
		Module:CreateBar5()
		Module:CreateBar678()
		Module:CreateCustomBar()
		Module:CreateExtrabar()
		Module:CreateLeaveVehicle()
		Module:CreatePetbar()
		Module:CreateStancebar()
		Module:HideBlizz()
		Module:CreateBarSkin()

		local function delaySize(event)
			Module:UpdateAllScale()
			K:UnregisterEvent(event, delaySize)
		end
		K:RegisterEvent("PLAYER_ENTERING_WORLD", delaySize)
	end

	if C["ActionBar"].Skin then
		Module:CreateBarSkin()
	end
end
