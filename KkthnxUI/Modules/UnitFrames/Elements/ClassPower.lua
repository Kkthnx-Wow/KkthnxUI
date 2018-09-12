local K, C = unpack(select(2, ...))
if C["Unitframe"].Enable ~= true then
	return
end

local Module = K:GetModule("Unitframes")

local _G = _G

local CreateFrame = _G.CreateFrame
local UnitPowerMax = _G.UnitPowerMax
local UnitHasVehicleUI = _G.UnitHasVehicleUI

local ClassPowerTexture = K.GetTexture(C["Unitframe"].Texture)

-- Post Update ClassPower
local function PostUpdateClassPower(element, cur, max, diff, powerType)
	if (diff) then
		local maxWidth, gap = 130, 6

		for index = 1, max do
			local Bar = element[index]
			Bar:SetWidth(((maxWidth / max) - (((max - 1) * gap) / max)))

			if (index > 1) then
				Bar:ClearAllPoints()
				Bar:SetPoint("LEFT", element[index - 1], "RIGHT", gap, 0)
			end
		end
	end
end

-- Post Update ClassPower Texture
local function UpdateClassPowerColor(element)
	-- Fallback for the rare cases where an unknown type is requested.
	local r, g, b = 195/255, 202/255, 217/255

	if (not UnitHasVehicleUI("player")) then
		if (K.Class == "ROGUE") then
			r, g, b = 220/255, 68/255,  25/255
		elseif (K.Class == "DRUID") then
			r, g, b = 220/255, 68/255,  25/255
		elseif (K.Class == "MONK") then
			r, g, b = 181/255 * 0.7, 255/255, 234/255 * 0.7
		elseif (K.Class == "WARLOCK") then
			r, g, b = 148/255, 130/255, 201/255
		elseif (K.Class == "PALADIN") then
			r, g, b = 245/255, 254/255, 145/255
		elseif (K.Class == "MAGE") then
			r, g, b = 121/255, 152/255, 192/255
		end
	end

	for index = 1, #element do
		local Bar = element[index]
		Bar:SetStatusBarColor(r, g, b)
	end
end

-- Create Class Power Bars (Combo Points...)
function Module:CreateClassPower()
	local ClassPower = {}
	ClassPower.UpdateColor = UpdateClassPowerColor
	ClassPower.PostUpdate = PostUpdateClassPower

	for index = 1, 11 do
		local Bar = CreateFrame("StatusBar", "oUF_KkthnxClassPower", self)
		Bar:SetWidth(130)
		Bar:SetHeight(14)
		Bar:SetStatusBarTexture(ClassPowerTexture)
		Bar:CreateBorder()

		if (index > 1) then
			Bar:SetPoint("LEFT", ClassPower[index - 1], "RIGHT", 6, 0)
		else
			Bar:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -6)
		end

		if (index > 5) then
			Bar:SetFrameLevel(Bar:GetFrameLevel() + 1)
		end

		ClassPower[index] = Bar
	end

	self.ClassPower = ClassPower
end

-- Death Knight Runebar PostUpdate
local function PostUpdateRune(self, runemap)
	local Bar = self
	local RuneMap = runemap

	for i, RuneID in next, RuneMap do
		local IsReady = select(3, GetRuneCooldown(RuneID))

		if IsReady then
			Bar[i]:GetStatusBarTexture():SetAlpha(1.0)
		else
			Bar[i]:GetStatusBarTexture():SetAlpha(0.3)
		end
	end
end

-- Death Knight Runebar
function Module:CreateRuneBar()
	local Runes = {}
	for index = 1, 6 do
		local Rune = CreateFrame("StatusBar", nil, self)
		local numRunes, maxWidth, gap = 6, 130, 6
		local width = ((maxWidth / numRunes) - (((numRunes-1) * gap) / numRunes))

		Rune:SetSize(width, 14)
		Rune:SetStatusBarTexture(ClassPowerTexture)
		Rune:CreateBorder()

		if (index == 1) then
			Rune:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -gap)
		else
			Rune:SetPoint("LEFT", Runes[index - 1], "RIGHT", gap, 0)
		end

		Runes[index] = Rune
	end

	Runes.colorSpec = true -- color runes by spec
	Runes.sortOrder = "asc"
	Runes.PostUpdate = PostUpdateRune

	self.Runes = Runes
end

function Module:CreateStaggerBar()
	local stagger = CreateFrame("StatusBar", nil, self)
	stagger:SetPoint("LEFT", 4, 0)
	stagger:SetPoint("RIGHT", -4, 0)
	stagger:SetPoint("BOTTOM", self.Health, "TOP", 0, 6)
	stagger:SetHeight(14)
	stagger:SetStatusBarTexture(ClassPowerTexture)
	stagger:CreateBorder()

	self.Stagger = stagger
end

local function PostUpdateTotem(element)
	local shown = {}
	for index = 1, MAX_TOTEMS do
		local Totem = element[index]
		if (Totem:IsShown()) then
			local prevShown = shown[#shown]

			Totem:ClearAllPoints()
			if (index == 1) then
				Totem:SetPoint("TOPLEFT", element.__owner, "BOTTOMLEFT", 56, -3)
			else
				Totem:SetPoint("LEFT", shown[#shown], "RIGHT", 6, 0)
			end

			table.insert(shown, Totem)
		end
	end
end

function Module:CreateTotems()
	local Totems = {}
	Totems.PostUpdate = PostUpdateTotem

	for index = 1, MAX_TOTEMS do
		local Totem = CreateFrame("Button", nil, self.Power)
		Totem:SetSize(22, 22)

		local Icon = Totem:CreateTexture(nil, "OVERLAY")
		Icon:SetAllPoints()
		Icon:SetTexCoord(unpack(K.TexCoords))
		Totem.Icon = Icon

		local Cooldown = CreateFrame("Cooldown", nil, Totem, "CooldownFrameTemplate")
		Cooldown:SetPoint("TOPLEFT", 1, -1)
		Cooldown:SetPoint("BOTTOMRIGHT", -1, 1)
		Cooldown:SetReverse(true)
		Totem.Cooldown = Cooldown

		Totem:CreateBorder()

		Totems[index] = Totem
	end

	self.Totems = Totems
end