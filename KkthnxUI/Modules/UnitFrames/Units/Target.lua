local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Unitframes")

-- Lua functions
local select = select

-- WoW API
local CreateFrame = CreateFrame

function Module:CreateTarget()
	self.mystyle = "target"

	local targetWidth = C["Unitframe"].TargetHealthWidth
	local targetHeight = C["Unitframe"].TargetHealthHeight
	local targetPortraitStyle = C["Unitframe"].PortraitStyle

	local UnitframeTexture = K.GetTexture(C["General"].Texture)
	local HealPredictionTexture = K.GetTexture(C["General"].Texture)

	Module.CreateHeader(self)

	local Health = CreateFrame("StatusBar", nil, self)
	Health:SetHeight(targetHeight)
	Health:SetPoint("TOPLEFT")
	Health:SetPoint("TOPRIGHT")
	Health:SetStatusBarTexture(UnitframeTexture)
	Health:CreateBorder()

	local Overlay = CreateFrame("Frame", nil, self) -- We will use this to overlay onto our special borders.
	Overlay:SetFrameStrata(self:GetFrameStrata())
	Overlay:SetFrameLevel(6)
	Overlay:SetAllPoints()
	Overlay:EnableMouse(false)

	Health.colorTapping = true
	Health.colorDisconnected = true
	Health.frequentUpdates = true

	if C["Unitframe"].Smooth then
		K:SmoothBar(Health)
	end

	if C["Unitframe"].HealthbarColor == 3 then
		Health.colorSmooth = true
		Health.colorClass = false
		Health.colorReaction = false
	elseif C["Unitframe"].HealthbarColor == 2 then
		Health.colorSmooth = false
		Health.colorClass = false
		Health.colorReaction = false
		Health:SetStatusBarColor(0.31, 0.31, 0.31)
	else
		Health.colorSmooth = false
		Health.colorClass = true
		Health.colorReaction = true
	end

	Health.Value = Health:CreateFontString(nil, "OVERLAY")
	Health.Value:SetPoint("CENTER", Health, "CENTER", 0, 0)
	Health.Value:SetFontObject(K.UIFont)
	self:Tag(Health.Value, "[hp]")

	local Power = CreateFrame("StatusBar", nil, self)
	Power:SetHeight(C["Unitframe"].TargetPowerHeight)
	Power:SetPoint("TOPLEFT", Health, "BOTTOMLEFT", 0, -6)
	Power:SetPoint("TOPRIGHT", Health, "BOTTOMRIGHT", 0, -6)
	Power:SetStatusBarTexture(UnitframeTexture)
	Power:CreateBorder()

	Power.colorPower = true
	Power.frequentUpdates = true

	if C["Unitframe"].Smooth then
		K:SmoothBar(Power)
	end

	Power.Value = Power:CreateFontString(nil, "OVERLAY")
	Power.Value:SetPoint("CENTER", Power, "CENTER", 0, 0)
	Power.Value:SetFontObject(K.UIFont)
	Power.Value:SetFont(select(1, Power.Value:GetFont()), 11, select(3, Power.Value:GetFont()))
	self:Tag(Power.Value, "[power]")

	local Name = self:CreateFontString(nil, "OVERLAY")
	Name:SetPoint("BOTTOMLEFT", Health, "TOPLEFT", 0, 4)
	Name:SetPoint("BOTTOMRIGHT", Health, "TOPRIGHT", 0, 4)
	Name:SetFontObject(K.UIFont)
	Name:SetWordWrap(false)

	if targetPortraitStyle == 0 or targetPortraitStyle == 4 then
		if C["Unitframe"].HealthbarColor == 1 then
			self:Tag(Name, "[name] [fulllevel][afkdnd]")
		else
			self:Tag(Name, "[color][name] [fulllevel][afkdnd]")
		end
	else
		if C["Unitframe"].HealthbarColor == 1 then
			self:Tag(Name, "[name][afkdnd]")
		else
			self:Tag(Name, "[color][name][afkdnd]")
		end
	end

	if targetPortraitStyle ~= 0 then
		local Portrait

		if targetPortraitStyle == 4 then
			Portrait = CreateFrame("PlayerModel", "KKUI_TargetPortrait", self)
			Portrait:SetFrameStrata(self:GetFrameStrata())
			Portrait:SetPoint("TOPLEFT", Health, "TOPLEFT", 1, -1)
			Portrait:SetPoint("BOTTOMRIGHT", Health, "BOTTOMRIGHT", -1, 1)
			Portrait:SetAlpha(0.6)
		elseif targetPortraitStyle == 5 then
			Portrait = CreateFrame("PlayerModel", "KKUI_TargetPortrait", Health)
			Portrait:SetFrameStrata(self:GetFrameStrata())
			Portrait:SetSize(Health:GetHeight() + Power:GetHeight() + 6, Health:GetHeight() + Power:GetHeight() + 6)
			Portrait:SetPoint("TOPLEFT", self, "TOPRIGHT", 6, 0)
			Portrait:CreateBorder()
		else
			Portrait = Health:CreateTexture("KKUI_TargetPortrait", "BACKGROUND", nil, 1)
			Portrait:SetTexCoord(0.15, 0.85, 0.15, 0.85)
			Portrait:SetSize(Health:GetHeight() + Power:GetHeight() + 6, Health:GetHeight() + Power:GetHeight() + 6)
			Portrait:SetPoint("TOPLEFT", self, "TOPRIGHT", 6, 0)

			Portrait.Border = CreateFrame("Frame", nil, self)
			Portrait.Border:SetAllPoints(Portrait)
			Portrait.Border:CreateBorder()

			if targetPortraitStyle == 2 or targetPortraitStyle == 3 then
				Portrait.PostUpdate = Module.UpdateClassPortraits
			end
		end

		self.Portrait = Portrait

		if targetPortraitStyle == 5 then
			Module:ApplyPortraitAlphaFix(self)
		end
	end

	if C["Unitframe"].TargetDebuffs then -- and C["Unitframe"].TargetDebuffsTop
		local Debuffs = CreateFrame("Frame", nil, self)
		Debuffs.spacing = 6
		Debuffs.initialAnchor = "BOTTOMLEFT"
		Debuffs["growth-x"] = "RIGHT"
		Debuffs["growth-y"] = "UP"
		Debuffs:SetPoint("BOTTOMLEFT", Name, "TOPLEFT", 0, 6)
		Debuffs:SetPoint("BOTTOMRIGHT", Name, "TOPRIGHT", 0, 6)
		Debuffs.num = 14
		Debuffs.iconsPerRow = C["Unitframe"].TargetDebuffsPerRow

		Module:UpdateAuraContainer(targetWidth, Debuffs, Debuffs.num)

		Debuffs.onlyShowPlayer = C["Unitframe"].OnlyShowPlayerDebuff
		Debuffs.PostCreateButton = Module.PostCreateButton
		Debuffs.PostUpdateButton = Module.PostUpdateButton

		self.Debuffs = Debuffs
	end

	if C["Unitframe"].TargetBuffs then -- and C["Unitframe"].TargetDebuffsTop
		local Buffs = CreateFrame("Frame", nil, self)
		Buffs:SetPoint("TOPLEFT", Power, "BOTTOMLEFT", 0, -6)
		Buffs:SetPoint("TOPRIGHT", Power, "BOTTOMRIGHT", 0, -6)
		Buffs.initialAnchor = "TOPLEFT"
		Buffs["growth-x"] = "RIGHT"
		Buffs["growth-y"] = "DOWN"
		Buffs.num = 20
		Buffs.spacing = 6
		Buffs.iconsPerRow = C["Unitframe"].TargetBuffsPerRow
		Buffs.onlyShowPlayer = false

		Module:UpdateAuraContainer(targetWidth, Buffs, Buffs.num)

		Buffs.showStealableBuffs = true
		Buffs.PostCreateButton = Module.PostCreateButton
		Buffs.PostUpdateButton = Module.PostUpdateButton

		self.Buffs = Buffs
	end

	if C["Unitframe"].TargetCastbar then
		local Castbar = CreateFrame("StatusBar", "oUF_CastbarTarget", self)
		Castbar:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
		Castbar:SetFrameLevel(10)
		Castbar:SetSize(C["Unitframe"].TargetCastbarWidth, C["Unitframe"].TargetCastbarHeight)
		Castbar:CreateBorder()
		Castbar.castTicks = {}

		Castbar.Spark = Castbar:CreateTexture(nil, "OVERLAY", nil, 7)
		Castbar.Spark:SetSize(64, Castbar:GetHeight() - 2)
		Castbar.Spark:SetTexture(C["Media"].Textures.Spark128Texture)
		Castbar.Spark:SetBlendMode("ADD")
		Castbar.Spark:SetAlpha(0.8)

		local shield = Castbar:CreateTexture(nil, "OVERLAY", nil, 4)
		shield:SetAtlas("Soulbinds_Portrait_Lock")
		shield:SetSize(C["Unitframe"].TargetCastbarHeight + 10, C["Unitframe"].TargetCastbarHeight + 10)
		shield:SetPoint("TOP", Castbar, "CENTER", 0, 6)
		Castbar.Shield = shield

		local timer = K.CreateFontString(Castbar, 12, "", "", false, "RIGHT", -3, 0)
		local name = K.CreateFontString(Castbar, 12, "", "", false, "LEFT", 3, 0)
		name:SetPoint("RIGHT", timer, "LEFT", -5, 0)
		name:SetJustifyH("LEFT")

		Castbar.Icon = Castbar:CreateTexture(nil, "ARTWORK")
		Castbar.Icon:SetSize(Castbar:GetHeight(), Castbar:GetHeight())
		Castbar.Icon:SetPoint("BOTTOMRIGHT", Castbar, "BOTTOMLEFT", -6, 0)
		Castbar.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

		Castbar.Button = CreateFrame("Frame", nil, Castbar)
		Castbar.Button:CreateBorder()
		Castbar.Button:SetAllPoints(Castbar.Icon)
		Castbar.Button:SetFrameLevel(Castbar:GetFrameLevel())

		local stage = K.CreateFontString(Castbar, 20)
		stage:ClearAllPoints()
		stage:SetPoint("TOPLEFT", Castbar.Icon, 1, -1)
		Castbar.stageString = stage

		Castbar.decimal = "%.2f"

		Castbar.Time = timer
		Castbar.Text = name
		Castbar.OnUpdate = Module.OnCastbarUpdate
		Castbar.PostCastStart = Module.PostCastStart
		Castbar.PostCastUpdate = Module.PostCastUpdate
		Castbar.PostCastStop = Module.PostCastStop
		Castbar.PostCastFail = Module.PostCastFailed
		Castbar.PostCastInterruptible = Module.PostUpdateInterruptible
		Castbar.CreatePip = Module.CreatePip
		Castbar.PostUpdatePips = Module.PostUpdatePips

		local mover = K.Mover(Castbar, "Target Castbar", "TargetCB", { "BOTTOM", UIParent, "BOTTOM", 0, 342 }, Castbar:GetHeight() + Castbar:GetWidth() + 6, Castbar:GetHeight())
		Castbar:ClearAllPoints()
		Castbar:SetPoint("RIGHT", mover)
		Castbar.mover = mover

		self.Castbar = Castbar
	end

	if C["Unitframe"].ShowHealPrediction then
		local frame = CreateFrame("Frame", nil, self)
		frame:SetAllPoints(Health)
		local frameLevel = frame:GetFrameLevel()

		local normalTexture = K.GetTexture(C["General"].Texture)

		-- Position and size
		local myBar = CreateFrame("StatusBar", nil, frame)
		myBar:SetPoint("TOP")
		myBar:SetPoint("BOTTOM")
		myBar:SetPoint("LEFT", Health:GetStatusBarTexture(), "RIGHT")
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
		local tex = absorbBar:CreateTexture(nil, "ARTWORK", nil, 1)
		tex:SetAllPoints(absorbBar:GetStatusBarTexture())
		tex:SetTexture("Interface\\RaidFrame\\Shield-Overlay", true, true)
		tex:SetHorizTile(true)
		tex:SetVertTile(true)

		local overAbsorbBar = CreateFrame("StatusBar", nil, frame)
		overAbsorbBar:SetAllPoints()
		overAbsorbBar:SetStatusBarTexture(normalTexture)
		overAbsorbBar:SetStatusBarColor(0.66, 1, 1)
		overAbsorbBar:SetFrameLevel(frameLevel)
		overAbsorbBar:SetAlpha(0.35)
		overAbsorbBar:Hide()
		local tex = overAbsorbBar:CreateTexture(nil, "ARTWORK", nil, 1)
		tex:SetAllPoints(overAbsorbBar:GetStatusBarTexture())
		tex:SetTexture("Interface\\RaidFrame\\Shield-Overlay", true, true)
		tex:SetHorizTile(true)
		tex:SetVertTile(true)

		local healAbsorbBar = CreateFrame("StatusBar", nil, frame)
		healAbsorbBar:SetPoint("TOP")
		healAbsorbBar:SetPoint("BOTTOM")
		healAbsorbBar:SetPoint("RIGHT", Health:GetStatusBarTexture())
		healAbsorbBar:SetReverseFill(true)
		healAbsorbBar:SetStatusBarTexture(normalTexture)
		healAbsorbBar:SetStatusBarColor(1, 0, 0.5)
		healAbsorbBar:SetFrameLevel(frameLevel)
		healAbsorbBar:SetAlpha(0.35)
		healAbsorbBar:Hide()
		local tex = healAbsorbBar:CreateTexture(nil, "ARTWORK", nil, 1)
		tex:SetAllPoints(healAbsorbBar:GetStatusBarTexture())
		tex:SetTexture("Interface\\RaidFrame\\Shield-Overlay", true, true)
		tex:SetHorizTile(true)
		tex:SetVertTile(true)

		local overAbsorb = Health:CreateTexture(nil, "OVERLAY", nil, 2)
		overAbsorb:SetWidth(8)
		overAbsorb:SetTexture("Interface\\RaidFrame\\Shield-Overshield")
		overAbsorb:SetBlendMode("ADD")
		overAbsorb:SetPoint("TOPLEFT", Health, "TOPRIGHT", -5, 0)
		overAbsorb:SetPoint("BOTTOMLEFT", Health, "BOTTOMRIGHT", -5, -0)
		overAbsorb:Hide()

		local overHealAbsorb = frame:CreateTexture(nil, "OVERLAY")
		overHealAbsorb:SetWidth(15)
		overHealAbsorb:SetTexture("Interface\\RaidFrame\\Absorb-Overabsorb")
		overHealAbsorb:SetBlendMode("ADD")
		overHealAbsorb:SetPoint("TOPRIGHT", Health, "TOPLEFT", 5, 2)
		overHealAbsorb:SetPoint("BOTTOMRIGHT", Health, "BOTTOMLEFT", 5, -2)
		overHealAbsorb:Hide()

		-- Register with oUF
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

	-- Level
	local Level = self:CreateFontString(nil, "OVERLAY")
	if targetPortraitStyle ~= 0 and targetPortraitStyle ~= 4 then
		Level:Show()
		Level:SetPoint("BOTTOMLEFT", self.Portrait, "TOPLEFT", 0, 4)
		Level:SetPoint("BOTTOMRIGHT", self.Portrait, "TOPRIGHT", 0, 4)
	else
		Level:Hide()
	end
	Level:SetFontObject(K.UIFont)
	self:Tag(Level, "[fulllevel]")

	if C["Unitframe"].CombatText then
		local parentFrame = CreateFrame("Frame", nil, UIParent)
		local FloatingCombatFeedback = CreateFrame("Frame", "oUF_Target_CombatTextFrame", parentFrame)
		FloatingCombatFeedback:SetSize(32, 32)
		K.Mover(FloatingCombatFeedback, "CombatText", "TargetCombatText", { "BOTTOM", self, "TOPRIGHT", 0, 120 })

		for i = 1, 36 do
			FloatingCombatFeedback[i] = FloatingCombatFeedback:CreateFontString("$parentText", "OVERLAY")
		end

		FloatingCombatFeedback.font = select(1, KkthnxUIFontOutline:GetFont())
		FloatingCombatFeedback.fontFlags = "OUTLINE"
		FloatingCombatFeedback.abbreviateNumbers = true
		FloatingCombatFeedback:SetFrameStrata("HIGH")

		self.FloatingCombatFeedback = FloatingCombatFeedback

		-- Default CombatText
		SetCVar("enableFloatingCombatText", 0)
		-- K.HideInterfaceOption(_G.InterfaceOptionsCombatPanelEnableFloatingCombatText)
	end

	if C["Unitframe"].PvPIndicator then
		local PvPIndicator = self:CreateTexture(nil, "OVERLAY")
		PvPIndicator:SetSize(30, 33)
		if targetPortraitStyle ~= 0 and targetPortraitStyle ~= 4 then
			PvPIndicator:SetPoint("LEFT", self.Portrait, "RIGHT", 2, 0)
		else
			PvPIndicator:SetPoint("LEFT", Health, "RIGHT", 2, 0)
		end
		PvPIndicator.PostUpdate = Module.PostUpdatePvPIndicator

		self.PvPIndicator = PvPIndicator
	end

	local LeaderIndicator = Overlay:CreateTexture(nil, "OVERLAY")
	LeaderIndicator:SetSize(16, 16)
	if targetPortraitStyle ~= 0 and targetPortraitStyle ~= 4 then
		LeaderIndicator:SetPoint("TOPRIGHT", self.Portrait, 0, 10)
	else
		LeaderIndicator:SetPoint("TOPRIGHT", Health, 0, 10)
	end
	LeaderIndicator.PostUpdate = Module.PostUpdateLeaderIndicator

	local AssistantIndicator = Overlay:CreateTexture(nil, "OVERLAY")
	AssistantIndicator:SetSize(16, 16)
	if AssistantIndicator ~= 0 and targetPortraitStyle ~= 4 then
		AssistantIndicator:SetPoint("TOPRIGHT", self.Portrait, 0, 10)
	else
		AssistantIndicator:SetPoint("TOPRIGHT", Health, 0, 10)
	end

	local RaidTargetIndicator = Overlay:CreateTexture(nil, "OVERLAY")
	if targetPortraitStyle ~= 0 and targetPortraitStyle ~= 4 then
		RaidTargetIndicator:SetPoint("TOP", self.Portrait, "TOP", 0, 8)
	else
		RaidTargetIndicator:SetPoint("TOP", Health, "TOP", 0, 8)
	end
	RaidTargetIndicator:SetSize(16, 16)

	local ReadyCheckIndicator = Overlay:CreateTexture(nil, "OVERLAY")
	if targetPortraitStyle ~= 0 and targetPortraitStyle ~= 4 then
		ReadyCheckIndicator:SetPoint("CENTER", self.Portrait)
	else
		ReadyCheckIndicator:SetPoint("CENTER", Health)
	end
	ReadyCheckIndicator:SetSize(targetHeight - 4, targetHeight - 4)

	local ResurrectIndicator = Overlay:CreateTexture(nil, "OVERLAY")
	ResurrectIndicator:SetSize(44, 44)
	if targetPortraitStyle ~= 0 and targetPortraitStyle ~= 4 then
		ResurrectIndicator:SetPoint("CENTER", self.Portrait)
	else
		ResurrectIndicator:SetPoint("CENTER", Health)
	end

	local QuestIndicator = Overlay:CreateTexture(nil, "OVERLAY")
	QuestIndicator:SetSize(20, 20)
	QuestIndicator:SetPoint("TOPLEFT", Health, "TOPRIGHT", -6, 6)

	if C["Unitframe"].DebuffHighlight then
		local DebuffHighlight = Health:CreateTexture(nil, "OVERLAY")
		DebuffHighlight:SetAllPoints(Health)
		DebuffHighlight:SetTexture(C["Media"].Textures.White8x8Texture)
		DebuffHighlight:SetVertexColor(0, 0, 0, 0)
		DebuffHighlight:SetBlendMode("ADD")

		self.DebuffHighlight = DebuffHighlight

		self.DebuffHighlightAlpha = 0.45
		self.DebuffHighlightFilter = true
	end

	local Highlight = Health:CreateTexture(nil, "OVERLAY")
	Highlight:SetAllPoints()
	Highlight:SetTexture("Interface\\PETBATTLES\\PetBattle-SelectedPetGlow")
	Highlight:SetTexCoord(0, 1, 0.5, 1)
	Highlight:SetVertexColor(0.6, 0.6, 0.6)
	Highlight:SetBlendMode("ADD")
	Highlight:Hide()

	self.ThreatIndicator = {
		IsObjectType = K.Noop,
		Override = Module.UpdateThreat,
	}

	self.RangeFader = {
		insideAlpha = 1,
		outsideAlpha = 0.55,
	}

	-- Register with oUF
	self.RangeFader = {
		insideAlpha = 1,
		outsideAlpha = 0.55,
		MaxAlpha = 1,
		MinAlpha = 0.3,
	}

	self.Overlay = Overlay
	self.Health = Health
	self.Power = Power
	self.Name = Name
	self.Level = Level
	self.LeaderIndicator = LeaderIndicator
	self.AssistantIndicator = AssistantIndicator
	self.RaidTargetIndicator = RaidTargetIndicator
	self.ReadyCheckIndicator = ReadyCheckIndicator
	self.ResurrectIndicator = ResurrectIndicator
	self.QuestIndicator = QuestIndicator
	self.Highlight = Highlight
end
