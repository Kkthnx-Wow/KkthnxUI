local K, C = unpack(select(2, ...))
if C["Unitframe"].Enable ~= true then return end

local _G = _G

local CreateFrame = _G.CreateFrame
local UIParent = _G.UIParent

local ClassModuleFont = K.GetFont(C["Unitframe"].Font)
local ClassModuleTexture = K.GetTexture(C["Unitframe"].Texture)

local function PostUpdateClassPower(classPower, power, maxPower, maxPowerChanged)
	if (not maxPower or not maxPowerChanged) then return end

	local maxIndex = maxPower ~= 10 and maxPower or 5
	local height = classPower.height
	local spacing = classPower.spacing
	local width = (classPower.width - (maxIndex + 1) * spacing) / maxIndex
	spacing = width + spacing

	for i = 1, maxPower do
		classPower[i]:SetSize(width, height)
		classPower[i]:SetPoint("BOTTOMLEFT", ((i - 1) % maxIndex) * spacing + 4, -14)
	end
end

local function UpdateClassPowerColor(self)
	local r, g, b

	if (not UnitHasVehicleUI("player")) then
		if (K.Class == "MONK") then
			r, g, b = 0, 4/5, 3/5
		elseif (K.Class == "WARLOCK") then
			r, g, b = 2/3, 1/3, 2/3
		elseif (K.Class == "PALADIN") then
			r, g, b = 1, 1, 2/5
		elseif (K.Class == "MAGE") then
			r, g, b = 5/6, 1/2, 5/6
		else
			r, g, b = 1, 1, 2/5
		end
	end

	for index = 1, #self do
		local bar = self[index]
		if (index > 5 and K.Class == "ROGUE" and UnitPowerMax("player", 4) == 10) then
			r, g, b = 1, 0, 0
		end

		bar:SetStatusBarColor(r, g, b)
	end
end

function K.CreateClassModules(self, width, height, spacing)
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

		-- combo points 6-10 will be stacked on top of 1-5 for rogues with the anticipation talent
		if (i > 5) then
			bar:SetFrameLevel(bar:GetFrameLevel() + 1)
		end

		bar:SetTemplate("Transparent")

		classPower[i] = bar
	end

	classPower.PostUpdate = PostUpdateClassPower
	classPower.UpdateColor = UpdateClassPowerColor

	self.ClassPower = classPower
end

local function PostUpdateRune(_, rune, _, _, _, isReady)
	if (isReady) then
		rune:SetAlpha(1)
	else
		rune:SetAlpha(0.5)
	end
end

function K.CreateClassRunes(self, width, height, spacing)
	local runes = {}
	local maxRunes = 6

	width = (width - (maxRunes + 1) * spacing) / maxRunes
	spacing = width + spacing

	for i = 1, maxRunes do
		local rune = CreateFrame("StatusBar", nil, self)
		rune:SetSize(width, height)
		rune:SetPoint("BOTTOMLEFT", (i - 1) * spacing + 4, -14)
		rune:SetStatusBarTexture(ClassModuleTexture)
		rune:SetTemplate("Transparent")

		runes[i] = rune
	end

	runes.colorSpec = true
	runes.PostUpdate = PostUpdateRune
	self.Runes = runes
end