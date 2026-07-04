--[[-----------------------------------------------------------------------------
-- oUF nameplate style function (health, castbar, auras, widget hooks).
-----------------------------------------------------------------------------
]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Unitframes")

local CreateFrame = CreateFrame

local function updateSpellTarget(self, _, unit)
	Module.PostCastUpdate(self.Castbar, unit)
end

function Module:CreatePlates()
	self.mystyle = "nameplate"

	-- REASON: Initialize base nameplate dimensions.
	-- MIDNIGHT (12.0): the oUF plate is parented to the Blizzard nameplate and already
	-- inherits UIParent's effective scale, so an explicit SetScale(UIScale) double-scales
	-- it (~0.5x) and shrinks all text. Mirror NDui, which leaves the plate at native scale.
	-- MIDNIGHT (12.0): oUF's NAME_PLATE_UNIT_ADDED handler calls unitFrame:SetAllPoints()
	-- (4 anchors filling the Blizzard base) BEFORE running this style function. We must
	-- ClearAllPoints() first, otherwise those anchors stay active, SetSize is ignored, and
	-- the plate stretches to the full driver/base size (oversized bars). Mirrors NDui.
	self:SetSize(C["Nameplate"].PlateWidth, C["Nameplate"].PlateHeight)
	self:ClearAllPoints()
	self:SetPoint("CENTER")

	-- Health Bar
	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetAllPoints()
	self.Health:SetStatusBarTexture(K.GetTexture(C["General"].Texture))

	self.Overlay = CreateFrame("Frame", nil, self)
	self.Overlay:SetAllPoints(self.Health)
	self.Overlay:SetFrameLevel(4)

	self.Health.backdrop = self.Health:CreateShadow(true)
	self.Health.backdrop:SetPoint("TOPLEFT", self.Health, "TOPLEFT", -3, 3)
	self.Health.backdrop:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", 3, -3)
	self.Health.backdrop:SetFrameLevel(self.Health:GetFrameLevel())

	self.Health.frequentUpdates = true
	self.Health.UpdateColor = Module.UpdateColor

	if C["Nameplate"].Smooth then
		K:SmoothBar(self.Health)
	end

	-- REASON: Health spark — anchored to the bar texture edge so it tracks smooth
	-- animation perfectly. Hidden at full/zero health, dead, or offline, same as
	-- all other unit frames. Nameplates are pooled/reused; the spark is created
	-- once per plate and stays attached through unit reassignment.
	self.Health.Spark = Module:CreateBarSpark(self.Health)
	self.Health.PostUpdate = Module.PostUpdateHealthSpark

	-- Text Elements
	-- REASON: Use oUF tags for dynamic text updating (name, level, health, etc.).
	self.levelText = K.CreateFontString(self, C["Nameplate"].NameTextSize, "", "", false)
	self.levelText:SetJustifyH("RIGHT")
	self.levelText:ClearAllPoints()
	self.levelText:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 6, 4)
	self.levelText:SetPoint("BOTTOMRIGHT", self, "TOPRIGHT", 6, 4)
	self:Tag(self.levelText, "[nplevel]")

	self.nameText = K.CreateFontString(self, C["Nameplate"].NameTextSize, "", "", false)
	self.nameText:SetJustifyH("LEFT")
	self.nameText:ClearAllPoints()
	self.nameText:SetPoint("BOTTOMLEFT", self, "TOPLEFT", 0, 4)
	self.nameText:SetPoint("BOTTOMRIGHT", self.levelText, "TOPRIGHT", -21, 4)
	self:Tag(self.nameText, "[name]")

	self.npcTitle = K.CreateFontString(self, C["Nameplate"].NameTextSize - 1)
	self.npcTitle:ClearAllPoints()
	self.npcTitle:SetPoint("TOP", self.nameText, "BOTTOM", 0, -4)
	self.npcTitle:Hide()
	self:Tag(self.npcTitle, "[npctitle]")

	self.guildName = K.CreateFontString(self, C["Nameplate"].NameTextSize - 1)
	self.guildName:SetTextColor(211 / 255, 211 / 255, 211 / 255)
	self.guildName:ClearAllPoints()
	self.guildName:SetPoint("TOP", self.nameText, "BOTTOM", 0, -4)
	self.guildName:Hide()
	self:Tag(self.guildName, "[guildname]")

	self.tarName = K.CreateFontString(self, C["Nameplate"].NameTextSize + 2)
	self.tarName:ClearAllPoints()
	self.tarName:SetPoint("TOP", self, "BOTTOM", 0, -10)
	self.tarName:Hide()
	self:Tag(self.tarName, "[tarname]")

	self.healthValue = K.CreateFontString(self.Overlay, C["Nameplate"].HealthTextSize, "", "", false, "CENTER", 0, 0)
	self.healthValue:SetPoint("CENTER", self.Overlay, 0, 0)
	self:Tag(self.healthValue, "[nphp]")

	-- Castbar
	-- REASON: Customize the castbar appearance with textures, sparks, and interrupt shields.
	self.Castbar = CreateFrame("StatusBar", nil, self)
	self.Castbar:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, -3)
	self.Castbar:SetPoint("TOPRIGHT", self, "BOTTOMRIGHT", 0, -3)
	self.Castbar:SetHeight(self:GetHeight() + 6)
	self.Castbar:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
	self.Castbar:SetFrameLevel(10)
	self.Castbar:CreateShadow(true)
	self.Castbar.castTicks = {}

	self.Castbar.Spark = self.Castbar:CreateTexture(nil, "OVERLAY", nil, 2)
	self.Castbar.Spark:SetSize(64, self.Castbar:GetHeight() - 2)
	self.Castbar.Spark:SetTexture(C["Media"].Textures.Spark128Texture)
	self.Castbar.Spark:SetBlendMode("ADD")
	self.Castbar.Spark:SetAlpha(0.8)

	self.Castbar.Shield = self.Castbar:CreateTexture(nil, "OVERLAY", nil, 4)
	self.Castbar.Shield:SetAtlas("Soulbinds_Portrait_Lock")
	self.Castbar.Shield:SetSize(self:GetHeight() + 14, self:GetHeight() + 14)
	self.Castbar.Shield:SetPoint("TOP", self.Castbar, "CENTER", 0, 6)

	self.Castbar.Time = K.CreateFontString(self.Castbar, 12, "", "", false, "RIGHT", 0, -1)
	self.Castbar.Text = K.CreateFontString(self.Castbar, 12, "", "", false, "LEFT", 0, -1)
	self.Castbar.Text:SetPoint("RIGHT", self.Castbar.Time, "LEFT", -5, 0)
	self.Castbar.Text:SetJustifyH("LEFT")
	self.Castbar.timeToHold = 0.5

	self.Castbar.Icon = self.Castbar:CreateTexture(nil, "ARTWORK")
	self.Castbar.Icon:SetSize(self:GetHeight() * 2 + 10, self:GetHeight() * 2 + 10)
	self.Castbar.Icon:SetPoint("BOTTOMRIGHT", self.Castbar, "BOTTOMLEFT", -3, 0)
	self.Castbar.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

	self.Castbar.Button = CreateFrame("Frame", nil, self.Castbar)
	self.Castbar.Button:CreateShadow(true)
	self.Castbar.Button:SetAllPoints(self.Castbar.Icon)
	self.Castbar.Button:SetFrameLevel(self.Castbar:GetFrameLevel())

	self.Castbar.glowFrame = CreateFrame("Frame", nil, self.Castbar)
	self.Castbar.glowFrame:SetPoint("CENTER", self.Castbar.Icon)
	self.Castbar.glowFrame:SetSize(self:GetHeight() * 2 + 5, self:GetHeight() * 2 + 5)

	self.Castbar.spellTarget = K.CreateFontString(self.Castbar, C["Nameplate"].NameTextSize + 2)
	self.Castbar.spellTarget:ClearAllPoints()
	self.Castbar.spellTarget:SetJustifyH("LEFT")
	self.Castbar.spellTarget:SetPoint("TOPLEFT", self.Castbar.Text, "BOTTOMLEFT", 0, -6)
	self:RegisterEvent("UNIT_TARGET", updateSpellTarget)

	self.Castbar.stageString = K.CreateFontString(self.Castbar, 22)
	self.Castbar.stageString:ClearAllPoints()
	self.Castbar.stageString:SetPoint("TOPLEFT", self.Castbar.Icon, -2, 2)

	self.Castbar.timeToHold = 0.5
	self.Castbar.decimal = "%.1f"
	self.Castbar.OnUpdate = Module.OnCastbarUpdate
	self.Castbar.PostCastStart = Module.PostCastStart
	self.Castbar.PostCastUpdate = Module.PostCastUpdate
	self.Castbar.PostCastStop = Module.PostCastStop
	self.Castbar.PostCastFail = Module.PostCastFailed
	self.Castbar.PostCastInterrupted = Module.PostCastInterrupted
	self.Castbar.PostCastInterruptible = Module.PostUpdateInterruptible
	self.Castbar.CreatePip = Module.CreatePip
	self.Castbar.PostUpdatePips = Module.PostUpdatePips

	-- Raid Target Indicator
	self.RaidTargetIndicator = self:CreateTexture(nil, "OVERLAY")
	self.RaidTargetIndicator:SetPoint("TOPRIGHT", self, "TOPLEFT", -5, 20)
	self.RaidTargetIndicator:SetSize(18, 18)

	-- Health Prediction
	-- REASON: Implement health prediction (incoming heals and absorbs) for better health awareness.
	do
		local frame = CreateFrame("Frame", nil, self)
		frame:SetAllPoints(self.Health)
		local frameLevel = frame:GetFrameLevel()
		local normalTexture = K.GetTexture(C["General"].Texture)

		local myBar = CreateFrame("StatusBar", nil, frame)
		myBar:SetPoint("TOP")
		myBar:SetPoint("BOTTOM")
		myBar:SetPoint("LEFT", self.Health:GetStatusBarTexture(), "RIGHT")
		myBar:SetStatusBarTexture(normalTexture)
		myBar:SetStatusBarColor(0, 1, 0.5, 0.5)
		myBar:SetFrameLevel(frameLevel)
		myBar:Hide()

		local otherBar = CreateFrame("StatusBar", nil, frame)
		otherBar:SetPoint("TOP")
		otherBar:SetPoint("BOTTOM")
		otherBar:SetPoint("LEFT", myBar:GetStatusBarTexture(), "RIGHT")
		otherBar:SetStatusBarTexture(normalTexture)
		otherBar:SetStatusBarColor(0, 1, 0, 0.5)
		otherBar:SetFrameLevel(frameLevel)
		otherBar:Hide()

		local absorbBar = CreateFrame("StatusBar", nil, frame)
		absorbBar:SetPoint("TOP")
		absorbBar:SetPoint("BOTTOM")
		absorbBar:SetPoint("LEFT", otherBar:GetStatusBarTexture(), "RIGHT")
		absorbBar:SetStatusBarTexture(normalTexture)
		absorbBar:SetStatusBarColor(0.66, 1, 1)
		absorbBar:SetFrameLevel(frameLevel)
		absorbBar:SetAlpha(0.5)
		absorbBar:Hide()
		local tex1 = absorbBar:CreateTexture(nil, "ARTWORK", nil, 1)
		tex1:SetAllPoints(absorbBar:GetStatusBarTexture())
		tex1:SetTexture("Interface\\RaidFrame\\Shield-Overlay")
		tex1:SetHorizTile(true)
		tex1:SetVertTile(true)

		local overAbsorbBar = CreateFrame("StatusBar", nil, frame)
		overAbsorbBar:SetAllPoints()
		overAbsorbBar:SetStatusBarTexture(normalTexture)
		overAbsorbBar:SetStatusBarColor(0.66, 1, 1)
		overAbsorbBar:SetFrameLevel(frameLevel)
		overAbsorbBar:SetAlpha(0.35)
		overAbsorbBar:Hide()
		local tex2 = overAbsorbBar:CreateTexture(nil, "ARTWORK", nil, 1)
		tex2:SetAllPoints(overAbsorbBar:GetStatusBarTexture())
		tex2:SetTexture("Interface\\RaidFrame\\Shield-Overlay")
		tex2:SetHorizTile(true)
		tex2:SetVertTile(true)

		local healAbsorbBar = CreateFrame("StatusBar", nil, frame)
		healAbsorbBar:SetPoint("TOP")
		healAbsorbBar:SetPoint("BOTTOM")
		healAbsorbBar:SetPoint("RIGHT", self.Health:GetStatusBarTexture())
		healAbsorbBar:SetReverseFill(true)
		healAbsorbBar:SetStatusBarTexture(normalTexture)
		healAbsorbBar:SetStatusBarColor(1, 0, 0.5)
		healAbsorbBar:SetFrameLevel(frameLevel)
		healAbsorbBar:SetAlpha(0.35)
		healAbsorbBar:Hide()
		local tex3 = healAbsorbBar:CreateTexture(nil, "ARTWORK", nil, 1)
		tex3:SetAllPoints(healAbsorbBar:GetStatusBarTexture())
		tex3:SetTexture("Interface\\RaidFrame\\Shield-Overlay")
		tex3:SetHorizTile(true)
		tex3:SetVertTile(true)

		local overAbsorb = self.Health:CreateTexture(nil, "OVERLAY", nil, 2)
		overAbsorb:SetWidth(8)
		overAbsorb:SetTexture("Interface\\RaidFrame\\Shield-Overshield")
		overAbsorb:SetBlendMode("ADD")
		overAbsorb:SetPoint("TOPLEFT", self.Health, "TOPRIGHT", -5, 0)
		overAbsorb:SetPoint("BOTTOMLEFT", self.Health, "BOTTOMRIGHT", -5, -0)
		overAbsorb:Hide()

		local overHealAbsorb = frame:CreateTexture(nil, "OVERLAY")
		overHealAbsorb:SetWidth(15)
		overHealAbsorb:SetTexture("Interface\\RaidFrame\\Absorb-Overabsorb")
		overHealAbsorb:SetBlendMode("ADD")
		overHealAbsorb:SetPoint("TOPRIGHT", self.Health, "TOPLEFT", 5, 2)
		overHealAbsorb:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMLEFT", 5, -2)
		overHealAbsorb:Hide()

		self.HealthPrediction = {
			myBar = myBar,
			otherBar = otherBar,
			absorbBar = absorbBar,
			healAbsorbBar = healAbsorbBar,
			overAbsorbBar = overAbsorbBar,
			overAbsorb = overAbsorb,
			overHealAbsorb = overHealAbsorb,
			maxOverflow = 1,
			PostUpdate = Module.PostUpdatePrediction,
		}
		self.predicFrame = frame
	end

	-- Aura Container
	-- REASON: Manage buffs and debuffs display above the nameplate.
	self.Auras = CreateFrame("Frame", nil, self)
	self.Auras:SetFrameLevel(self:GetFrameLevel() + 2)
	self.Auras.spacing = 4
	self.Auras.initialAnchor = "BOTTOMLEFT"
	self.Auras.growthY = "UP"

	-- REASON: Adjust aura position if class resource bars are enabled on nameplates.
	if C["Nameplate"].NameplateClassPower then
		self.Auras:SetPoint("BOTTOMLEFT", self.nameText, "TOPLEFT", 0, 8 + C["Nameplate"].PlateHeight)
		self.Auras:SetPoint("BOTTOMRIGHT", self.nameText, "TOPRIGHT", 0, 8 + C["Nameplate"].PlateHeight)
	else
		self.Auras:SetPoint("BOTTOMLEFT", self.nameText, "TOPLEFT", 0, 6)
		self.Auras:SetPoint("BOTTOMRIGHT", self.nameText, "TOPRIGHT", 0, 6)
	end

	self.Auras.numTotal = C["Nameplate"].MaxAuras
	self.Auras.size = C["Nameplate"].AuraSize
	self.Auras.gap = false
	self.Auras.disableMouse = true
	self.Auras.FilterAura = Module.CustomFilter

	Module:UpdateAuraContainer(self:GetWidth(), self.Auras, self.Auras.numTotal)

	self.Auras.showStealableBuffs = true
	self.Auras.PostCreateButton = Module.PostCreateButton
	self.Auras.PostUpdateButton = Module.PostUpdateButton
	self.Auras.PostUpdateInfo = Module.AurasPostUpdateInfo

	Module:CreateThreatColor(self)

	self.PvPClassificationIndicator = self:CreateTexture(nil, "ARTWORK")
	self.PvPClassificationIndicator:SetSize(18, 18)
	self.PvPClassificationIndicator:ClearAllPoints()
	if C["Nameplate"].ClassIcon then
		self.PvPClassificationIndicator:SetPoint("TOPLEFT", self, "TOPRIGHT", 5, 20)
	else
		self.PvPClassificationIndicator:SetPoint("LEFT", self, "RIGHT", 6, 0)
	end

	self.powerText = K.CreateFontString(self, 15)
	self.powerText:ClearAllPoints()
	self.powerText:SetPoint("TOP", self.Castbar, "BOTTOM", 0, -4)
	self:Tag(self.powerText, "[nppp]")

	-- REASON: Register various custom nameplate extensions.
	Module:MouseoverIndicator(self)
	Module:AddTargetIndicator(self)
	Module:AddCreatureIcon(self)
	Module:AddQuestIcon(self)
	Module:AddDungeonProgress(self)
	Module:AddClassIcon(self)

	Module:RegisterNameplate(self)
end
