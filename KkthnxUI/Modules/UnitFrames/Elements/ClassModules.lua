local K, C = unpack(select(2, ...))
if C["Unitframe"].Enable ~= true then return end

local _G = _G

local CreateFrame = _G.CreateFrame
local UIParent = _G.UIParent

local function PostUpdateTotem(self)
	local shown = {}
	for index = 1, MAX_TOTEMS do
		local Totem = self[index]
		if (Totem:IsShown()) then
			local prevShown = shown[#shown]

			Totem:ClearAllPoints()
			Totem:SetPoint("TOPLEFT", shown[#shown] or self.__owner, "TOPRIGHT", 6, 0)
			table.insert(shown, Totem)
		end
	end
end

local function PostUpdateClassPower(self, cur, max, diff, powerType)
	if (diff) then
		for index = 1, max do
			local Bar = self[index]
			if (max == 3) then
				Bar:SetWidth(74)
			elseif (max == 4) then
				Bar:SetWidth(index > 2 and 40 or 43)
			elseif (max == 5 or max == 10) then
				Bar:SetWidth((index == 1 or index == 6) and 30 or 34)
			elseif (max == 6) then
				Bar:SetWidth(27)
			end

			if (max == 10) then
				-- Rogue anticipation talent, align > 5 on top of the first 5
				if (index == 6) then
					Bar:ClearAllPoints()
					Bar:SetPoint("TOP", self[index - 5], "BOTTOM", 0, -6)
				end
			else
				if (index > 1) then
					Bar:ClearAllPoints()
					Bar:SetPoint("LEFT", self[index - 1], "RIGHT", 4, 0)
				end
			end
		end
	end
end

local function UpdateClassPowerColor(self)
	local r, g, b = 1, 1, 2/5

	if (not UnitHasVehicleUI("player")) then
		if (K.Class == "MONK") then
			r, g, b = 0, 4/5, 3/5
		elseif (K.Class == "WARLOCK") then
			r, g, b = 2/3, 1/3, 2/3
		elseif (K.Class == "PALADIN") then
			r, g, b = 1, 1, 2/5
		elseif (K.Class == "MAGE") then
			r, g, b = 5/6, 1/2, 5/6
		end
	end

	for index = 1, #self do
		local Bar = self[index]
		if (K.Class == "ROGUE" and self.__max == 10 and index > 5) then
			r, g, b = 1, 0, 0
		end

		Bar:SetStatusBarColor(r, g, b)
	end
end

function K.CreateAlternatePowerBar(self, unit)
	-- Additional mana
	if (unit == "player" and K.Class == "DRUID" or K.Class == "SHAMAN" or K.Class == "PRIEST") then
		self.AdditionalPower = CreateFrame("StatusBar", nil, self)
		self.AdditionalPower:SetPoint("BOTTOM", self.Health, "TOP", 0, 6)
		self.AdditionalPower:SetStatusBarTexture(C.Media.Texture, "BORDER")
		self.AdditionalPower:SetSize(self.Health:GetWidth(), 10)
		self.AdditionalPower.colorPower = true
		self.AdditionalPower:SetTemplate("Transparent")
		self.AdditionalPower.Smooth = C["Unitframe"].Smooth
		self.AdditionalPower.SmoothSpeed = C["Unitframe"].SmoothSpeed * 10

		self.AdditionalPower.Value = self.AdditionalPower:CreateFontString(nil, "OVERLAY")
		self.AdditionalPower.Value:SetFont(C.Media.Font, 9)
		self.AdditionalPower.Value:SetShadowOffset(1, -1)
		self.AdditionalPower.Value:SetPoint("CENTER", self.AdditionalPower, 0, 0)

		self:Tag(self.AdditionalPower.Value, "[KkthnxUI:AltPowerCurrent]")
	end
end

function K.CreateClassModules(self, unit)
	unit = unit:match("^(.-)%d+") or unit

	if unit == "player" then
		local ClassPower = {}
		ClassPower.UpdateColor = UpdateClassPowerColor
		ClassPower.PostUpdate = PostUpdateClassPower

		for index = 1, 11 do -- have to create an extra to force __max to be different from UnitPowerMax
			local Bar = CreateFrame("StatusBar", nil, self)
			Bar:SetSize(34, 10)
			Bar:SetStatusBarTexture(C.Media.Texture)
			Bar:SetTemplate("Transparent")

			if (index > 1) then
				Bar:SetPoint("LEFT", ClassPower[index - 1], "RIGHT", 4, 0)
			else
				Bar:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 4, -4)
			end

			if (index > 5) then
				Bar:SetFrameLevel(Bar:GetFrameLevel() + 2)
			end

			ClassPower[index] = Bar
		end
		self.ClassPower = ClassPower

		local Totems = {}
		Totems.PostUpdate = PostUpdateTotem

		for index = 1, MAX_TOTEMS do
			local Totem = CreateFrame("Button", nil, self)
			Totem:SetSize(26, 26)
			Totem:SetTemplate("Transparent")

			local Icon = Totem:CreateTexture(nil, "OVERLAY")
			Icon:SetAllPoints()
			Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
			Totem.Icon = Icon

			local Cooldown = CreateFrame("Cooldown", nil, Totem, "CooldownFrameTemplate")
			Cooldown:SetInside()
			Cooldown:SetReverse(true)
			Totem.Cooldown = Cooldown

			Totems[index] = Totem
		end
		self.Totems = Totems

		if (K.Class == "DEATHKNIGHT") then
			local Runes = {}
			for index = 1, 6 do
				local Rune = CreateFrame("StatusBar", nil, self)
				Rune:SetSize(25.3, 10)
				Rune:SetStatusBarTexture(C.Media.Texture)
				Rune:SetTemplate("Transparent")

				if (index == 1) then
					Rune:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 4, -4)
				else
					Rune:SetPoint("LEFT", Runes[index - 1], "RIGHT", 6, 0)
				end

				Runes[index] = Rune
			end
			self.Runes = Runes
		end
	end
end