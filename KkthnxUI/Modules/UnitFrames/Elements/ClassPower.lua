local K, C = unpack(select(2, ...))
if C["Unitframe"].Enable ~= true then
	return
end

local Module = K:GetModule("Unitframes")

local _G = _G

local CreateFrame = _G.CreateFrame
local UnitHasVehicleUI = _G.UnitHasVehicleUI
local UnitPowerMax = _G.UnitPowerMax

-- GLOBALS: SPELL_POWER_COMBO_POINTS

local function PostUpdateClassPower(classPower, _, maxPower, maxPowerChanged)
	if (not maxPower or not maxPowerChanged) then
		return
	end

	local maxIndex = maxPower ~= 10 and maxPower or 5
	local height = classPower.height
	local spacing = classPower.spacing
	local width = (classPower.width - (maxIndex + 1) * spacing) / maxIndex
	spacing = width + spacing

	for i = 1, maxPower do
		classPower[i]:SetSize(width, height)
		classPower[i]:SetPoint("BOTTOMLEFT", ((i - 1) % maxIndex) * spacing + 4, -15)
	end
end

local function UpdateClassPowerColor(element)
	local r, g, b = 1, 1, 2 / 5
	if (not UnitHasVehicleUI("player")) then
		if (K.Class == "MONK") then
			r, g, b = 0, 4 / 5, 3 / 5
		elseif (K.Class == "WARLOCK") then
			r, g, b = 2 / 3, 1 / 3, 2 / 3
		elseif (K.Class == "PALADIN") then
			r, g, b = 1, 1, 2 / 5
		elseif (K.Class == "MAGE") then
			r, g, b = 5 / 6, 1 / 2, 5 / 6
		end
	end

	for index = 1, #element do
		local bar = element[index]
		if (K.Class == "ROGUE" and UnitPowerMax("player", SPELL_POWER_COMBO_POINTS) == 10 and index > 5) then
			r, g, b = 1, 0, 0
		end

		bar:SetStatusBarColor(r, g, b)
	end
end

function Module:CreateClassModules(width, height, spacing)
	local ClassModuleFont = K.GetFont(C["Unitframe"].Font)
	local ClassModuleTexture = K.GetTexture(C["Unitframe"].Texture)

	local classPower = {}

	classPower.width = width
	classPower.height = height
	classPower.spacing = spacing

	-- rogues with the anticipation talent have max 10 combo points
	-- create one extra to force __max to be different from UnitPowerMax
	-- needed for sizing and positioning in PostUpdate
	local maxPower = 11

	for i = 1, maxPower do
		local bar = CreateFrame("StatusBar", nil, self)
		bar:SetStatusBarTexture(ClassModuleTexture)
		bar:SetTemplate("Transparent")

		-- combo points 6-10 will be stacked on top of 1-5 for rogues with the anticipation talent
		if (i > 5) then
			bar:SetFrameLevel(bar:GetFrameLevel() + 2)
		end

		classPower[i] = bar
	end

	classPower.PostUpdate = PostUpdateClassPower
	classPower.UpdateColor = UpdateClassPowerColor

	self.ClassPower = classPower
end
