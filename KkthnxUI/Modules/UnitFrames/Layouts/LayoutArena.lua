local K, C, L = select(2, ...):unpack()
if C.Unitframe.Enable ~= true then return end

local _, ns = ...
local oUF = ns.oUF or oUF

local textPath = "Interface\\AddOns\\KkthnxUI\\Media\\Unitframes\\"

local function arenaPrep(self, event, ...)
	if event ~= "ArenaPreparation" then return; end

	local specID = GetArenaOpponentSpec(self.id)
	local _, spec, _, icon, _, _, class = GetSpecializationInfoByID(specID)

	SetPortraitToTexture(self.Portrait, icon)
	self.Portrait:SetVertexColor(1, 1, 1, 1)

	self.Name:SetText(ARENA .. " " .. tostring(self.id))

	self.Health.Value:SetText(spec)
	self.Health:SetMinMaxValues(0, 1)
	self.Health:SetValue(1)
	self.Health:SetStatusBarColor(unpack(self.colors.class[class]))
end

local function updatePortrait(self, event, unit)
	local specID = GetArenaOpponentSpec(self.id)
	if specID then
		local _, _, _, icon = GetSpecializationInfoByID(specID)
		SetPortraitToTexture(self.Portrait, icon)
	elseif unit and UnitIsUnit(self.unit, unit) then
		SetPortraitTexture(self.Portrait, unit)
	end
end

function ns.createArenaLayout(self, unit)
	local config = ns.config
	local uconfig = config[self.cUnit]

	self.Texture = self:CreateTexture(nil, "BORDER")
	self.Texture:SetTexture(textPath.. "Arena")
	self.Texture:SetSize(230, 100)
	self.Texture:SetPoint("TOPLEFT", self, -22, 14)
	self.Texture:SetTexCoord(0, 0.90625, 0, 0.78125)

	if C.Blizzard.ColorTextures == true then
		self.Texture:SetVertexColor(unpack(C.Blizzard.TexturesColor))
	end

	self.Health = K.CreateStatusBar(self, nil, nil, true)
	self.Health:SetFrameLevel(self:GetFrameLevel()-1)
	self.Health:SetSize(117, 18)
	self.Health:SetPoint("TOPRIGHT", self.Texture, -43, -17)

	self.Power = K.CreateStatusBar(self, nil, nil, true)
	self.Power:SetFrameLevel(self:GetFrameLevel()-1)
	self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -3)
	self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -3)
	self.Power:SetHeight(self.Health:GetHeight())

	self.Portrait = self.Health:CreateTexture(nil, "BACKGROUND")
	self.Portrait:SetSize(64, 64)
	self.Portrait:SetPoint("TOPLEFT", self.Health, -64, 13)
	self.Portrait.Override = updatePortrait
	self:RegisterEvent("ARENA_OPPONENT_UPDATE", updatePortrait)

	self.Health.Value = K.SetFontString(self.Health, C.Media.Font, 13)
	self.Health.Value:SetPoint("CENTER", self.Health)

	self.Power.Value = K.SetFontString(self.Health, C.Media.Font, 13)
	self.Power.Value:SetPoint("CENTER", self.Power)

	self:SetSize(167, 46)
	self:SetScale(1)

	self.Health.colorTapping = true
	self.Health.colorDisconnected = true
	self.Health.colorClass = true
	self.Health.colorReaction = true

	self.Health.Smooth = true
	self.Health.PostUpdate = K.PostUpdateHealth
	table.insert(self.mouseovers, self.Health)

	self.Power.colorPower = true

	self.Power.Smooth = true
	self.Power.PostUpdate = K.PostUpdatePower
	table.insert(self.mouseovers, self.Power)

	-- name
	self.Name = K.SetFontString(self.Health, C.Media.Font, 14)
	self.Name:SetSize(110, 10)
	self.Name:SetPoint("BOTTOM", self.Health, "TOP", 0, 6)
	self:Tag(self.Name, "[KkthnxUI:Name]")

	-- PvP Icon
	self.PvP = self:CreateTexture(nil, "OVERLAY")
	self.PvP:SetSize(40, 40)
	self.PvP:SetPoint("TOPLEFT", self.Texture, -20, -20)

	-- portrait Timer
	self.PortraitTimer = CreateFrame("Frame", nil, self.Health)
	self.PortraitTimer.Icon = self.PortraitTimer:CreateTexture(nil, "BACKGROUND")
	self.PortraitTimer.Icon:SetAllPoints(self.Portrait)

	self.PortraitTimer.Remaining = K.SetFontString(self, C.Media.Font, self.Portrait:GetWidth() / 3, C.Media.Font_Style)
	self.PortraitTimer.Remaining:SetPoint("CENTER", self.PortraitTimer.Icon)
	self.PortraitTimer.Remaining:SetTextColor(1, 1, 1)

	-- Auras
	self.Buffs = K.AddBuffs(self, "TOPLEFT", 28, 5, 6, 1)
	self.Buffs:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -7)
	self.Buffs.CustomFilter = ns.CustomAuraFilters.arena

	-- Castbars
	if C.Unitframe.Castbars and uconfig.cbshow then
		ns.CreateCastbars(self)
	end

	-- oUF_Trinkets support
	self.Trinket = CreateFrame("Frame", nil, self)
	self.Trinket:SetSize(25, 25)
	self.Trinket:SetFrameLevel(self:GetFrameLevel() + 2)
	self.Trinket:SetPoint("RIGHT", self.Health, "LEFT", 0, 15)

	self.Trinket.Border = CreateFrame("Frame", nil, self.Trinket)
	self.Trinket.Border:SetFrameLevel(self.Trinket:GetFrameLevel() + 1)
	self.Trinket.Border:SetAllPoints()
	self.Trinket.Border.Texture = self.Trinket.Border:CreateTexture(nil, "OVERLAY")
	self.Trinket.Border.Texture:SetTexture("Interface\\Minimap\\MiniMap-TrackingBorder")
	self.Trinket.Border.Texture:SetPoint("TOPLEFT", -6, 5)
	self.Trinket.Border.Texture:SetSize(60, 60)

	if C.Blizzard.ColorTextures == true then
		self.Trinket.Border.Texture:SetVertexColor(unpack(C.Blizzard.TexturesColor))
	end

	self.PostUpdate = arenaPrep

	return self
end