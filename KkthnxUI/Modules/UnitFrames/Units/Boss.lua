local K, C = unpack(select(2, ...))
local Module = K:GetModule("Unitframes")

local oUF = oUF or K.oUF
assert(oUF, "KkthnxUI was unable to locate oUF.")

local _G = _G
local math_floor = _G.math.floor
local select = _G.select

local CreateFrame = _G.CreateFrame

function Module:CreateBoss()
	self.mystyle = "boss"

	local UnitframeFont = K.GetFont(C["UIFonts"].UnitframeFonts)
	local UnitframeTexture = K.GetTexture(C["UITextures"].UnitframeTextures)

	self.Overlay = CreateFrame("Frame", nil, self) -- We will use this to overlay onto our special borders.
	self.Overlay:SetAllPoints()
	self.Overlay:SetFrameLevel(5)

	Module.CreateHeader(self)

	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetHeight(24)
	self.Health:SetPoint("TOPLEFT")
	self.Health:SetPoint("TOPRIGHT")
	self.Health:SetStatusBarTexture(UnitframeTexture)
	self.Health:CreateBorder()

	self.Health.PostUpdate = C["Unitframe"].PortraitStyle.Value ~= "ThreeDPortraits" and Module.UpdateHealth
	self.Health.colorTapping = true
	self.Health.colorDisconnected = true
	self.Health.frequentUpdates = true

	if C["Boss"].HealthbarColor.Value == "Value" then
        self.Health.colorSmooth = true
        self.Health.colorClass = false
        self.Health.colorReaction = false
    elseif C["Boss"].HealthbarColor.Value == "Dark" then
        self.Health.colorSmooth = false
        self.Health.colorClass = false
        self.Health.colorReaction = false
        self.Health:SetStatusBarColor(0.31, 0.31, 0.31)
    else
        self.Health.colorSmooth = false
        self.Health.colorClass = true
        self.Health.colorReaction = true
    end

	if C["Boss"].Smooth then
		K:SmoothBar(self.Health)
	end

	self.Health.Value = self.Health:CreateFontString(nil, "OVERLAY")
	self.Health.Value:SetFontObject(UnitframeFont)
	self.Health.Value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
	self:Tag(self.Health.Value, "[hp]")

	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetHeight(12)
	self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -6)
	self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -6)
	self.Power:SetStatusBarTexture(UnitframeTexture)
	self.Power:CreateBorder()

	self.Power.colorPower = true
	self.Power.frequentUpdates = false
	self.Power.displayAltPower = true

	if C["Boss"].Smooth then
		K:SmoothBar(self.Power)
	end

	self.Power.Value = self.Power:CreateFontString(nil, "OVERLAY")
	self.Power.Value:SetPoint("CENTER", self.Power, "CENTER", 0, 0)
	self.Power.Value:SetFontObject(UnitframeFont)
	self.Power.Value:SetFont(select(1, self.Power.Value:GetFont()), 11, select(3, self.Power.Value:GetFont()))
	self:Tag(self.Power.Value, "[power]")

	self.Name = self:CreateFontString(nil, "OVERLAY")
	self.Name:SetPoint("TOP", self.Health, 0, 16)
	self.Name:SetWidth(156 * 0.90)
	self.Name:SetFontObject(UnitframeFont)
	self.Name:SetWordWrap(false)
	if C["Boss"].HealthbarColor.Value == "Class" then
		self:Tag(self.Name, "[name]")
	else
		self:Tag(self.Name, "[color][name]")
	end

	if C["Unitframe"].PortraitStyle.Value == "ThreeDPortraits" then
		self.Portrait = CreateFrame("PlayerModel", nil, self.Health)
		self.Portrait:SetFrameStrata(self:GetFrameStrata())
		self.Portrait:SetSize(self.Health:GetHeight() + self.Power:GetHeight() + 6, self.Health:GetHeight() + self.Power:GetHeight() + 6)
		self.Portrait:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0)
		self.Portrait:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true)
	elseif C["Unitframe"].PortraitStyle.Value ~= "ThreeDPortraits" then
		self.Portrait = self.Health:CreateTexture("BossPortrait", "BACKGROUND", nil, 1)
		self.Portrait:SetTexCoord(0.15, 0.85, 0.15, 0.85)
		self.Portrait:SetSize(self.Health:GetHeight() + self.Power:GetHeight() + 6, self.Health:GetHeight() + self.Power:GetHeight() + 6)
		self.Portrait:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0)

		self.Portrait.Border = CreateFrame("Frame", nil, self)
		self.Portrait.Border:SetAllPoints(self.Portrait)
		self.Portrait.Border:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true)

		if (C["Unitframe"].PortraitStyle.Value == "ClassPortraits" or C["Unitframe"].PortraitStyle.Value == "NewClassPortraits") then
			self.Portrait.PostUpdate = Module.UpdateClassPortraits
		end
	end

	self.Health:ClearAllPoints()
	self.Health:SetPoint("TOPLEFT")
	self.Health:SetPoint("TOPRIGHT", -self.Portrait:GetWidth() - 6, 0)

	local aurasSetWidth = 156
	self.Buffs = CreateFrame("Frame", self:GetName().."Buffs", self)
	self.Buffs:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -6)
	self.Buffs.initialAnchor = "TOPLEFT"
	self.Buffs["growth-x"] = "RIGHT"
	self.Buffs["growth-y"] = "DOWN"
	self.Buffs.num = 6
	self.Buffs.spacing = 6
	self.Buffs.iconsPerRow = 6
	self.Buffs.onlyShowPlayer = false
	self.Buffs.size = Module.auraIconSize(aurasSetWidth, self.Buffs.iconsPerRow, self.Buffs.spacing)
	self.Buffs:SetWidth(aurasSetWidth)
	self.Buffs:SetHeight((self.Buffs.size + self.Buffs.spacing) * math_floor(self.Buffs.num / self.Buffs.iconsPerRow + .5))
	self.Buffs.showStealableBuffs = true
	self.Buffs.PostCreateIcon = Module.PostCreateAura
	self.Buffs.PostUpdateIcon = Module.PostUpdateAura

	self.Debuffs = CreateFrame("Frame", self:GetName().."Debuffs", self)
	self.Debuffs.spacing = 6
	self.Debuffs.initialAnchor = "TOPRIGHT"
	self.Debuffs["growth-x"] = "LEFT"
	self.Debuffs["growth-y"] = "DOWN"
	self.Debuffs:SetPoint("TOPRIGHT", self, "TOPLEFT", -6, 0)
	self.Debuffs.num = 4
	self.Debuffs.iconsPerRow = 4
	self.Debuffs.CustomFilter = Module.CustomFilter
	self.Debuffs.size = Module.auraIconSize(aurasSetWidth - 44, self.Debuffs.iconsPerRow, self.Debuffs.spacing)
	self.Debuffs:SetWidth(aurasSetWidth - 44)
	self.Debuffs:SetHeight((self.Debuffs.size + self.Debuffs.spacing) * math_floor(self.Debuffs.num / self.Debuffs.iconsPerRow + .5))
	self.Debuffs.PostCreateIcon = Module.PostCreateAura
	self.Debuffs.PostUpdateIcon = Module.PostUpdateAura

	if (C["Boss"].Castbars) then
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
		self.Castbar.Button:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true)

		self.Castbar.Icon = self.Castbar.Button:CreateTexture(nil, "ARTWORK")
		self.Castbar.Icon:SetSize(self.Castbar:GetHeight(), self.Castbar:GetHeight())
		self.Castbar.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		self.Castbar.Icon:SetPoint("LEFT", self.Castbar, "RIGHT", 6, 0)

		self.Castbar.Button:SetAllPoints(self.Castbar.Icon)
	end

	self.RaidTargetIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.RaidTargetIndicator:SetPoint("TOP", self.Portrait, "TOP", 0, 8)
	self.RaidTargetIndicator:SetSize(16, 16)

	local PWOnRight = false
		local relF = "RIGHT"
		local relT = "LEFT"
		local xOffset = -6
		local yOffset = 0
		local otherSide = PWOnRight
		if otherSide then
			xOffset = -6
			yOffset = 0
		end

		local altPower = K.CreateFontString(self, 10, "")
		altPower:ClearAllPoints()
		if otherSide then
			altPower:SetPoint(relT, self.Power, relF, xOffset, yOffset)
		else
			local parent = self.Power
			altPower:SetPoint(relF, parent, relT, xOffset, yOffset)
		end
		self:Tag(altPower, "[altpower]")
		altPower:Show()
end