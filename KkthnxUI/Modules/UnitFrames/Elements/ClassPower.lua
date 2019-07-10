local K, C = unpack(select(2, ...))
if C["Unitframe"].Enable ~= true then
	return
end

local Module = K:GetModule("Unitframes")

local _G = _G
local next = next
local select = select

local ClassPowerTexture = K.GetTexture(C["UITextures"].UnitframeTextures)
local ComboColor = K.Colors.power["COMBO_POINTS"]
local CreateFrame = _G.CreateFrame
local UnitHasVehicleUI = _G.UnitHasVehicleUI
local GetRuneCooldown = _G.GetRuneCooldown

-- Post Update Runes
local function OnUpdateRunes(self, elapsed)
	local duration = self.duration + elapsed
	self.duration = duration
	self:SetValue(duration)

	if self.timer then
		local remain = self.runeDuration - duration
		if remain > 0 then
			self.timer:SetText(K.FormatTime(remain))
		else
			self.timer:SetText(nil)
		end
	end
end

local function PostUpdateRunes(element, runemap)
	for index, runeID in next, runemap do
		local rune = element[index]
		local start, duration, runeReady = GetRuneCooldown(runeID)
		if rune:IsShown() then
			if runeReady then
				rune:SetAlpha(1)
				rune:SetScript("OnUpdate", nil)
				if rune.timer then
					rune.timer:SetText(nil)
				end
			elseif start then
				rune:SetAlpha(.6)
				rune.runeDuration = duration
				rune:SetScript("OnUpdate", OnUpdateRunes)
			end
		end
	end
end

-- Post Update ClassPower
local function PostUpdateClassPower(element, _, max, diff)
	-- Update Layout On Change In Total Visible
	if (diff) then
		local maxWidth = 140
		local gap = 6

		for index = 1, max do
			local Bar = element[index]
			Bar:SetWidth(((maxWidth / max) - (((max - 1) * gap) / max)))

			if (index > 1) then
				Bar:ClearAllPoints()
				Bar:SetPoint("LEFT", element[index - 1], "RIGHT", gap, 0)
			end
		end
	end
	-- Update Color If This Is Combo Points
	if (max) then
		if (not UnitHasVehicleUI("player")) and (K.Class == "ROGUE" or K.Class == "DRUID") then
			local numColors = #ComboColor
			for index = 1, max do
				local Bar = element[index]
				local colorIndex
				if (max > numColors) then
					local exactIndex = index/max * numColors
					colorIndex = math.ceil(exactIndex)
				else
					colorIndex = index
				end
				Bar:SetStatusBarColor(ComboColor[colorIndex][1], ComboColor[colorIndex][2], ComboColor[colorIndex][3], ComboColor[colorIndex][4])
			end
		end
	end
end

-- Post Update Nameplate Classpower
local function PostUpdateNameplateClassPower(element, _, max, diff)
	-- Update Layout On Change In Total Visible
	if (diff) then
		local maxWidth = C["Nameplates"].Width
		local gap = 4

		for index = 1, max do
			local Bar = element[index]
			Bar:SetWidth(((maxWidth / max) - (((max - 1) * gap) / max)))

			if (index > 1) then
				Bar:ClearAllPoints()
				Bar:SetPoint("LEFT", element[index - 1], "RIGHT", gap, 0)
			end
		end
	end
	-- Update Color If This Is Combo Points
	if (max) then
		if (not UnitHasVehicleUI("player")) and (K.Class == "ROGUE" or K.Class == "DRUID") then
			local numColors = #ComboColor
			for index = 1, max do
				local Bar = element[index]
				local colorIndex
				if (max > numColors) then
					local exactIndex = index/max * numColors
					colorIndex = math.ceil(exactIndex)
				else
					colorIndex = index
				end
				Bar:SetStatusBarColor(ComboColor[colorIndex][1], ComboColor[colorIndex][2], ComboColor[colorIndex][3], ComboColor[colorIndex][4])
			end
		end
	end
end

-- Post Update Classpower Texture
local function UpdateClassPowerColor(element)
	local r, g, b
	if (not UnitHasVehicleUI("player")) then
		if (K.Class == "MONK") then
			r, g, b = 181/255 * 0.7, 255/255, 234/255 * 0.7
		elseif (K.Class == "WARLOCK") then
			r, g, b = 148/255, 130/255, 201/255
		elseif (K.Class == "PALADIN") then
			r, g, b = 228/255, 225/255, 16/255
		elseif (K.Class == "MAGE") then
			r, g, b = 0, 157/255, 1
		else
			r, g, b = 195/255, 202/255, 217/255
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
		Bar:SetSize(self.Health and self.Health:GetWidth() or 140, 14)
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

-- Death Knight Runebar
function Module:CreateRuneBar()
	local Runes = {}
	for index = 1, 6 do
		local Rune = CreateFrame("StatusBar", nil, self)
		local numRunes, maxWidth, gap = 6, 140, 6
		local width = ((maxWidth / numRunes) - (((numRunes-1) * gap) / numRunes))

		Rune:SetSize(width, 14)
		Rune:SetStatusBarTexture(ClassPowerTexture)
		Rune:CreateBorder()

		Rune.timer = Rune:CreateFontString(nil, "OVERLAY")
		Rune.timer:SetFontObject(K.GetFont(C["UIFonts"].UnitframeFonts))
		Rune.timer:SetPoint("CENTER", Rune, "CENTER", 0, 0)

		if (index == 1) then
			Rune:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -gap)
		else
			Rune:SetPoint("LEFT", Runes[index - 1], "RIGHT", gap, 0)
		end

		Runes[index] = Rune
	end

	Runes.colorSpec = true
	Runes.sortOrder = "asc"
	Runes.PostUpdate = PostUpdateRunes

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

	stagger.Value = stagger:CreateFontString(nil, "OVERLAY")
	stagger.Value:SetFontObject(K.GetFont(C["UIFonts"].UnitframeFonts))
	stagger.Value:SetPoint("CENTER", stagger, "CENTER", 0, 0)
	self:Tag(stagger.Value, "[KkthnxUI:MonkStagger]")

	self.Stagger = stagger
end

-- Create Class Power Bars For Nameplates (Combo Points...)
function Module:CreateNamePlateClassPower()
	local ClassPower = CreateFrame("Frame", nil, self)
	ClassPower:SetSize(C["Nameplates"].Width, C["Nameplates"].Height - 2)
	ClassPower.UpdateColor = UpdateClassPowerColor
	ClassPower.PostUpdate = PostUpdateNameplateClassPower

	for index = 1, 11 do
		local Bar = CreateFrame("StatusBar", nil, ClassPower)
		Bar:SetSize(C["Nameplates"].Width, 10)
		Bar:SetStatusBarTexture(ClassPowerTexture)
		Bar:CreateShadow(true)

		if (index > 1) then
			Bar:SetPoint("LEFT", ClassPower[index - 1], "RIGHT", 6, 0)
		else
			Bar:SetPoint("TOPLEFT", ClassPower, "BOTTOMLEFT", 0, 0)
		end

		if (index > 5) then
			Bar:SetFrameLevel(Bar:GetFrameLevel() + 1)
		end

		ClassPower[index] = Bar
	end

	self.ClassPower = ClassPower
end

-- Death Knight Runebar For Nameplates
function Module:CreateNamePlateRuneBar()
	local Runes = CreateFrame("Frame", nil, self)
	Runes:SetSize(C["Nameplates"].Width, C["Nameplates"].Height - 2)
	for index = 1, 6 do
		local Rune = CreateFrame("StatusBar", nil, Runes)
		local numRunes, maxWidth, gap = 6, C["Nameplates"].Width, 4
		local width = ((maxWidth / numRunes) - (((numRunes-1) * gap) / numRunes))

		Rune:SetSize(width, 10)
		Rune:SetStatusBarTexture(ClassPowerTexture)
		Rune:CreateShadow(true)

		if (index == 1) then
			Rune:SetPoint("TOPLEFT", Runes, "BOTTOMLEFT", 0, 0)
		else
			Rune:SetPoint("LEFT", Runes[index - 1], "RIGHT", gap, 0)
		end

		Runes[index] = Rune
	end

	Runes.colorSpec = true
	Runes.sortOrder = "asc"
	Runes.PostUpdate = PostUpdateRunes

	self.Runes = Runes
end

function Module:CreateNamePlateStaggerBar()
	local stagger = CreateFrame("StatusBar", nil, self)
	stagger:SetWidth(C["Nameplates"].Width)
	stagger:SetHeight(10)
	stagger:SetStatusBarTexture(ClassPowerTexture)
	stagger:CreateShadow(true)

	self.Stagger = stagger
end