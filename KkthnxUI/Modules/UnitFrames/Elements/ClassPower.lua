local K, C = unpack(select(2, ...))
if C["Unitframe"].Enable ~= true then
	return
end

local Module = K:GetModule("Unitframes")

local _G = _G

local CreateFrame = _G.CreateFrame
local UnitPowerMax = _G.UnitPowerMax

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

local function UpdateClassPowerColor(classPower, powerType)
	local color = classPower.__owner.colors.power[powerType]
	local r, g, b = color[1], color[2], color[3]

	local isAnticipationRogue = K.Class == "ROGUE" and UnitPowerMax("player", _G.SPELL_POWER_COMBO_POINTS) == 10

	for i = 1, #classPower do
		if (i > 5 and isAnticipationRogue) then
			r, g, b = 1, 0, 0
		end

		local bar = classPower[i]
		bar:SetStatusBarColor(r, g, b)
	end
end

function Module:CreateClassModules(width, height, spacing)
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

		bar.Background = bar:CreateTexture(nil, "BACKGROUND", -1)
		bar.Background:SetAllPoints()
		bar.Background:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

		K.CreateBorder(bar)

		-- 6-10 will be stacked on top of 1-5 for rogues with the anticipation talent
		if (i > 5) then
			bar:SetFrameLevel(bar:GetFrameLevel() + 2)
		end

		classPower[i] = bar
	end

	classPower.PostUpdate = PostUpdateClassPower
	classPower.UpdateColor = UpdateClassPowerColor

	self.ClassPower = classPower
end
