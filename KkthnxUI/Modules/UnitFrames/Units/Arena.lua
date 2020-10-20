local K, C = unpack(select(2, ...))
local Module = K:GetModule("Unitframes")

local _G = _G

local CreateFrame = _G.CreateFrame
local GetArenaOpponentSpec = _G.GetArenaOpponentSpec
local GetSpecializationInfoByID = _G.GetSpecializationInfoByID
local IsInInstance = _G.IsInInstance
local UnitFactionGroup = _G.UnitFactionGroup

local function PostUpdateArenaPreparationSpec(self)
	local specIcon = self.PVPSpecIcon
	local instanceType = select(2, IsInInstance())

	if (instanceType == "arena") then
		local specID = self.id and GetArenaOpponentSpec(tonumber(self.id))

		if specID and specID > 0 then
			local icon = select(4, GetSpecializationInfoByID(specID))

			specIcon.Icon:SetTexture(icon)
		else
			specIcon.Icon:SetTexture([[INTERFACE\ICONS\INV_MISC_QUESTIONMARK]])
		end
	else
		local faction = UnitFactionGroup(self.unit)

		if faction == "Horde" then
			specIcon.Icon:SetTexture([[Interface\Icons\INV_BannerPVP_01]])
		elseif faction == "Alliance" then
			specIcon.Icon:SetTexture([[Interface\Icons\INV_BannerPVP_02]])
		else
			specIcon.Icon:SetTexture([[INTERFACE\ICONS\INV_MISC_QUESTIONMARK]])
		end
	end

	self.forceInRange = true
end

local function UpdatePowerColorArenaPreparation(self, specID)
	-- oUF is unable to get power color on arena preparation, so we add this feature here.
	local power = self
	local playerClass = select(6, GetSpecializationInfoByID(specID))

	if playerClass then
		local powerColor = K.Colors.specpowertypes[playerClass][specID]

		if powerColor then
			local r, g, b = unpack(powerColor)

			power:SetStatusBarColor(r, g, b)
		else
			power:SetStatusBarColor(0, 0, 0)
		end
	end
end

function Module:CreateArena()
	self.mystyle = "arena"
	local UnitframeFont = K.GetFont(C["UIFonts"].UnitframeFonts)
	local UnitframeTexture = K.GetTexture(C["UITextures"].UnitframeTextures)

	Module.CreateHeader(self)

	self:SetAttribute("type2", "focus")

	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetHeight(28)
	self.Health:SetPoint("TOPLEFT")
	self.Health:SetPoint("TOPRIGHT")
	self.Health:SetStatusBarTexture(UnitframeTexture)
	self.Health:CreateBorder()

	if C["Arena"].HealthbarColor.Value == "Value" then
		self.Health.colorSmooth = true
		self.Health.colorClass = false
		self.Health.colorReaction = false
	elseif C["Arena"].HealthbarColor.Value == "Dark" then
		self.Health.colorSmooth = false
		self.Health.colorClass = false
		self.Health.colorReaction = false
		self.Health:SetStatusBarColor(0.31, 0.31, 0.31)
	else
		self.Health.colorSmooth = false
		self.Health.colorClass = true
		self.Health.colorReaction = true
	end

	if C["Arena"].Smooth then
		K:SmoothBar(self.Health)
	end

	self.Health.Value = self.Health:CreateFontString(nil, "OVERLAY")
	self.Health.Value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
	self.Health.Value:SetFontObject(UnitframeFont)
	self:Tag(self.Health.Value, "[hp]")

	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetHeight(14)
	self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -6)
	self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -6)
	self.Power:SetStatusBarTexture(UnitframeTexture)
	self.Power:CreateBorder()
	self.Power.UpdateColorArenaPreparation = UpdatePowerColorArenaPreparation
	self.Power.colorPower = true
	self.Power.frequentUpdates = true

	if C["Arena"].Smooth then
		K:SmoothBar(self.Power)
	end

	self.Power.Value = self.Power:CreateFontString(nil, "OVERLAY")
	self.Power.Value:SetPoint("CENTER", self.Power, "CENTER", 0, 0)
	self.Power.Value:SetFontObject(UnitframeFont)
	self.Power.Value:SetFont(select(1, self.Power.Value:GetFont()), 11, select(3, self.Power.Value:GetFont()))
	self:Tag(self.Power.Value, "[power]")

	self.PVPSpecIcon = CreateFrame("Frame", nil, self)
	self.PVPSpecIcon:SetSize(self.Health:GetHeight() + self.Power:GetHeight() + 6, self.Health:GetHeight() + self.Power:GetHeight() + 6)
	self.PVPSpecIcon:SetPoint("TOPLEFT", self, "TOPLEFT", 0 ,0)
	self.PVPSpecIcon:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true)

	self.Trinket = CreateFrame("Frame", nil, self)
	self.Trinket:SetSize(self.Health:GetHeight() + self.Power:GetHeight() + 6, self.Health:GetHeight() + self.Power:GetHeight() + 6)
	self.Trinket:SetPoint("TOPLEFT", self, "TOPLEFT", 0 ,0)

	self.Health:ClearAllPoints()
	self.Health:SetPoint("TOPLEFT", self.PVPSpecIcon:GetWidth() + 6, 0)
	self.Health:SetPoint("TOPRIGHT")

	self.Portrait = CreateFrame("PlayerModel", nil, self.Health)
	self.Portrait:SetFrameLevel(self.Health:GetFrameLevel())
	self.Portrait:SetAllPoints()
	self.Portrait:SetAlpha(0.2)

	self.Name = self:CreateFontString(nil, "OVERLAY")
	self.Name:SetPoint("TOP", self.Health, 0, 16)
	self.Name:SetWidth(156 * 0.90)
	self.Name:SetFontObject(UnitframeFont)
	self.Name:SetWordWrap(false)
	self:Tag(self.Name, "[name]")

	self.Buffs = CreateFrame("Frame", self:GetName().."Buffs", self)
	self.Buffs:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -6)
	self.Buffs:SetWidth(156)
	self.Buffs.num = 6
	self.Buffs.spacing = 6
	self.Buffs.size = ((((self.Buffs:GetWidth() - (self.Buffs.spacing * (self.Buffs.num - 1))) / self.Buffs.num)))
	self.Buffs:SetHeight(self.Buffs.size)
	self.Buffs.initialAnchor = "TOPLEFT"
	self.Buffs["growth-y"] = "DOWN"
	self.Buffs["growth-x"] = "RIGHT"
	self.Buffs.showStealableBuffs = true
	self.Buffs.PostCreateIcon = Module.PostCreateAura
	self.Buffs.PostUpdateIcon = Module.PostUpdateAura

	self.Debuffs = CreateFrame("Frame", self:GetName().."Debuffs", self)
	self.Debuffs:SetWidth(156)
	self.Debuffs:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, 6)
	self.Debuffs.num = 6
	self.Debuffs.spacing = 6
	self.Debuffs.size = ((((self.Debuffs:GetWidth() - (self.Debuffs.spacing * (self.Debuffs.num - 1))) / self.Debuffs.num)))
	self.Debuffs:SetHeight(self.Debuffs.size)
	self.Debuffs.initialAnchor = "TOPLEFT"
	self.Debuffs["growth-y"] = "UP"
	self.Debuffs["growth-x"] = "RIGHT"
	self.Debuffs.CustomFilter = Module.CustomFilter
	self.Debuffs.onlyShowPlayer = C["Unitframe"].OnlyShowPlayerDebuff
	self.Debuffs.PostCreateIcon = Module.PostCreateAura
	self.Debuffs.PostUpdateIcon = Module.PostUpdateAura

	self.Castbar = CreateFrame("StatusBar", "BossCastbar", self)
	self.Castbar:SetStatusBarTexture(UnitframeTexture)
	self.Castbar:SetClampedToScreen(true)
	self.Castbar:CreateBorder()

	self.Castbar:ClearAllPoints()
	self.Castbar:SetPoint("LEFT", 0, 0)
	self.Castbar:SetPoint("RIGHT", -24, 0)
	self.Castbar:SetPoint("TOP", 0, 24)
	self.Castbar:SetHeight(18)

	self.Castbar.Spark = self.Castbar:CreateTexture(nil, "OVERLAY")
	self.Castbar.Spark:SetTexture(C["Media"].Spark_128)
	self.Castbar.Spark:SetSize(64, self.Castbar:GetHeight())
	self.Castbar.Spark:SetBlendMode("ADD")

	self.Castbar.Time = self.Castbar:CreateFontString(nil, "OVERLAY", UnitframeFont)
	self.Castbar.Time:SetPoint("RIGHT", -3.5, 0)
	self.Castbar.Time:SetTextColor(0.84, 0.75, 0.65)
	self.Castbar.Time:SetJustifyH("RIGHT")

	self.Castbar.decimal = "%.1f"

	self.Castbar.OnUpdate = Module.OnCastbarUpdate
	self.Castbar.PostCastStart = Module.PostCastStart
	self.Castbar.PostCastStop = Module.PostCastStop
	self.Castbar.PostCastFail = Module.PostCastFailed
	self.Castbar.PostCastInterruptible = Module.PostUpdateInterruptible

	self.Castbar.Text = self.Castbar:CreateFontString(nil, "OVERLAY", UnitframeFont)
	self.Castbar.Text:SetPoint("LEFT", 3.5, 0)
	self.Castbar.Text:SetPoint("RIGHT", self.Castbar.Time, "LEFT", -3.5, 0)
	self.Castbar.Text:SetTextColor(0.84, 0.75, 0.65)
	self.Castbar.Text:SetJustifyH("LEFT")
	self.Castbar.Text:SetWordWrap(false)

	self.Castbar.Button = CreateFrame("Frame", nil, self.Castbar)
	self.Castbar.Button:SetSize(20, 20)
	self.Castbar.Button:CreateBorder()

	self.Castbar.Icon = self.Castbar.Button:CreateTexture(nil, "ARTWORK")
	self.Castbar.Icon:SetSize(self.Castbar:GetHeight(), self.Castbar:GetHeight())
	self.Castbar.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	self.Castbar.Icon:SetPoint("LEFT", self.Castbar, "RIGHT", 6, 0)

	self.Castbar.Button:SetAllPoints(self.Castbar.Icon)

	self.PostUpdate = PostUpdateArenaPreparationSpec
end