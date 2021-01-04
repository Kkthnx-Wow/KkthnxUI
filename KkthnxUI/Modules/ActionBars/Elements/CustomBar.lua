local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("ActionBar")

local _G = _G
local math_min = _G.math.min
local math_ceil = _G.math.ceil
local table_insert = _G.table.insert

local FilterConfig = C.ActionBars.actionBarCustom
local padding, margin = 0, 6

function Module:SetupCustomBar(anchor)
	local size = C["ActionBar"].CustomBarButtonSize
	local num = 12
	local name = "KKUI_CustomBar"
	local page = 8

	local frame = CreateFrame("Frame", name, UIParent, "SecureHandlerStateTemplate")
	frame:SetWidth(num * size + (num - 1) * margin + 2 * padding)
	frame:SetHeight(size + 2 * padding)
	frame:SetPoint(unpack(anchor))
	frame.mover = K.Mover(frame, L[name], "CustomBar", anchor)
	frame.buttons = {}

	RegisterStateDriver(frame, "visibility", "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists][shapeshift] hide; show")
	RegisterStateDriver(frame, "page", page)

	local buttonList = {}
	for i = 1, num do
		local button = CreateFrame("CheckButton", "$parentButton"..i, frame, "ActionBarButtonTemplate")
		button:SetSize(size, size)
		button.id = (page - 1) * 12 + i
		button.isCustomButton = true
		button.commandName = L[name]..i
		button:SetAttribute("action", button.id)
		frame.buttons[i] = button
		table_insert(buttonList, button)
		table_insert(Module.buttons, button)
	end

	if C["ActionBar"].FadeCustomBar and FilterConfig.fader then
		Module.CreateButtonFrameFader(frame, buttonList, FilterConfig.fader)
	end

	Module:UpdateCustomBar()
end

function Module:UpdateCustomBar()
	local frame = _G.KKUI_CustomBar
	if not frame then
		return
	end

	local size = C["ActionBar"].CustomBarButtonSize
	local num = C["ActionBar"].CustomBarNumButtons
	local perRow = C["ActionBar"].CustomBarNumPerRow
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
	end

	for i = num + 1, 12 do
		local button = frame.buttons[i]
		button:SetAttribute("statehidden", true)
		button:Hide()
	end

	local column = math_min(num, perRow)
	local rows = math_ceil(num / perRow)
	frame:SetWidth(column * size + (column - 1) * margin + 2 * padding)
	frame:SetHeight(size * rows + (rows - 1) * margin + 2 * padding)
	frame.mover:SetSize(frame:GetSize())
end

function Module:CreateCustomBar()
	if C["ActionBar"].CustomBar then
		Module:SetupCustomBar({"BOTTOM", UIParent, "BOTTOM", 0, 140})
	end
end