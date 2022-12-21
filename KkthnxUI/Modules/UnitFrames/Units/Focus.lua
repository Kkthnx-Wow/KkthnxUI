local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Unitframes")

local _G = _G
local select = select

local CreateFrame = _G.CreateFrame

function Module:CreateFocus()
	self.mystyle = "focus"

	local focusWidth = C["Unitframe"].FocusHealthWidth
	local focusPortraitStyle = C["Unitframe"].PortraitStyle.Value

	local UnitframeTexture = K.GetTexture(C["General"].Texture)
	local HealPredictionTexture = K.GetTexture(C["General"].Texture)

	Module.CreateHeader(self)

	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetHeight(C["Unitframe"].FocusHealthHeight)
	self.Health:SetPoint("TOPLEFT")
	self.Health:SetPoint("TOPRIGHT")
	self.Health:SetStatusBarTexture(UnitframeTexture)
	self.Health:CreateBorder()

	self.Overlay = CreateFrame("Frame", nil, self) -- We will use this to overlay onto our special borders.
	self.Overlay:SetAllPoints(self.Health)
	self.Overlay:SetFrameLevel(5)

	self.Health.colorTapping = true
	self.Health.colorDisconnected = true
	self.Health.frequentUpdates = true

	if C["Unitframe"].Smooth then
		K:SmoothBar(self.Health)
	end

	if C["Unitframe"].HealthbarColor.Value == "Value" then
		self.Health.colorSmooth = true
		self.Health.colorClass = false
		self.Health.colorReaction = false
	elseif C["Unitframe"].HealthbarColor.Value == "Dark" then
		self.Health.colorSmooth = false
		self.Health.colorClass = false
		self.Health.colorReaction = false
		self.Health:SetStatusBarColor(0.31, 0.31, 0.31)
	else
		self.Health.colorSmooth = false
		self.Health.colorClass = true
		self.Health.colorReaction = true
	end

	self.Health.Value = self.Health:CreateFontString(nil, "OVERLAY")
	self.Health.Value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
	self.Health.Value:SetFontObject(K.UIFont)
	self:Tag(self.Health.Value, "[hp]")

	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetHeight(C["Unitframe"].FocusPowerHeight)
	self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -6)
	self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -6)
	self.Power:SetStatusBarTexture(UnitframeTexture)
	self.Power:CreateBorder()

	self.Power.colorPower = true
	self.Power.frequentUpdates = true

	if C["Unitframe"].Smooth then
		K:SmoothBar(self.Power)
	end

	self.Power.Value = self.Power:CreateFontString(nil, "OVERLAY")
	self.Power.Value:SetPoint("CENTER", self.Power, "CENTER", 0, 0)
	self.Power.Value:SetFontObject(K.UIFont)
	self.Power.Value:SetFont(select(1, self.Power.Value:GetFont()), 11, select(3, self.Power.Value:GetFont()))
	self:Tag(self.Power.Value, "[power]")

	self.Name = self:CreateFontString(nil, "OVERLAY")
	self.Name:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, 4)
	self.Name:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 0, 4)
	self.Name:SetFontObject(K.UIFont)
	self.Name:SetWordWrap(false)

	if focusPortraitStyle == "NoPortraits" then
		if C["Unitframe"].HealthbarColor.Value == "Class" then
			self:Tag(self.Name, "[name] [fulllevel][afkdnd]")
		else
			self:Tag(self.Name, "[color][name] [fulllevel][afkdnd]")
		end
	else
		if C["Unitframe"].HealthbarColor.Value == "Class" then
			self:Tag(self.Name, "[name][afkdnd]")
		else
			self:Tag(self.Name, "[color][name][afkdnd]")
		end
	end

	if focusPortraitStyle ~= "NoPortraits" then
		if focusPortraitStyle == "OverlayPortrait" then
			self.Portrait = CreateFrame("PlayerModel", "KKUI_FocusPortrait", self)
			self.Portrait:SetFrameStrata(self:GetFrameStrata())
			self.Portrait:SetPoint("TOPLEFT", self.Health, "TOPLEFT", 1, -1)
			self.Portrait:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", -1, 1)
			self.Portrait:SetAlpha(0.6)
		elseif focusPortraitStyle == "ThreeDPortraits" then
			self.Portrait = CreateFrame("PlayerModel", "KKUI_FocusPortrait", self.Health)
			self.Portrait:SetFrameStrata(self:GetFrameStrata())
			self.Portrait:SetSize(self.Health:GetHeight() + self.Power:GetHeight() + 6, self.Health:GetHeight() + self.Power:GetHeight() + 6)
			self.Portrait:SetPoint("TOPLEFT", self, "TOPRIGHT", 6, 0)
			self.Portrait:CreateBorder()
		elseif focusPortraitStyle ~= "ThreeDPortraits" and focusPortraitStyle ~= "OverlayPortrait" then
			self.Portrait = self.Health:CreateTexture("KKUI_FocusPortrait", "BACKGROUND", nil, 1)
			self.Portrait:SetTexCoord(0.15, 0.85, 0.15, 0.85)
			self.Portrait:SetSize(self.Health:GetHeight() + self.Power:GetHeight() + 6, self.Health:GetHeight() + self.Power:GetHeight() + 6)
			self.Portrait:SetPoint("TOPLEFT", self, "TOPRIGHT", 6, 0)

			self.Portrait.Border = CreateFrame("Frame", nil, self)
			self.Portrait.Border:SetAllPoints(self.Portrait)
			self.Portrait.Border:CreateBorder()

			if focusPortraitStyle == "ClassPortraits" or focusPortraitStyle == "NewClassPortraits" then
				self.Portrait.PostUpdate = Module.UpdateClassPortraits
			end
		end
	end

	if C["Unitframe"].FocusDebuffs then
		self.Debuffs = CreateFrame("Frame", nil, self)
		self.Debuffs.spacing = 6
		self.Debuffs.initialAnchor = "BOTTOMLEFT"
		self.Debuffs["growth-x"] = "RIGHT"
		self.Debuffs["growth-y"] = "UP"
		self.Debuffs:SetPoint("BOTTOMLEFT", self.Name, "TOPLEFT", 0, 6)
		self.Debuffs:SetPoint("BOTTOMRIGHT", self.Name, "TOPRIGHT", 0, 6)
		self.Debuffs.num = 15
		self.Debuffs.iconsPerRow = C["Unitframe"].TargetDebuffsPerRow

		Module:UpdateAuraContainer(focusWidth, self.Debuffs, self.Debuffs.num)

		self.Debuffs.onlyShowPlayer = C["Unitframe"].OnlyShowPlayerDebuff
		self.Debuffs.PostCreateButton = Module.PostCreateButton
		self.Debuffs.PostUpdateButton = Module.PostUpdateButton
	end

	if C["Unitframe"].FocusBuffs then
		self.Buffs = CreateFrame("Frame", nil, self)
		self.Buffs:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -6)
		self.Buffs:SetPoint("TOPRIGHT", self.Power, "BOTTOMRIGHT", 0, -6)
		self.Buffs.initialAnchor = "TOPLEFT"
		self.Buffs["growth-x"] = "RIGHT"
		self.Buffs["growth-y"] = "DOWN"
		self.Buffs.num = 20
		self.Buffs.spacing = 6
		self.Buffs.iconsPerRow = C["Unitframe"].TargetBuffsPerRow
		self.Buffs.onlyShowPlayer = false

		Module:UpdateAuraContainer(focusWidth, self.Buffs, self.Buffs.num)

		self.Buffs.showStealableBuffs = true
		self.Buffs.PostCreateButton = Module.PostCreateButton
		self.Buffs.PostUpdateButton = Module.PostUpdateButton
	end

	if C["Unitframe"].FocusCastbar then
		local Castbar = CreateFrame("StatusBar", "oUF_CastbarFocus", self)
		Castbar:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
		Castbar:SetFrameLevel(10)
		Castbar:SetSize(C["Unitframe"].FocusCastbarWidth, C["Unitframe"].FocusCastbarHeight)
		Castbar:CreateBorder()
		Castbar.castTicks = {}

		Castbar.Spark = Castbar:CreateTexture(nil, "OVERLAY", nil, 2)
		Castbar.Spark:SetSize(64, Castbar:GetHeight() - 2)
		Castbar.Spark:SetTexture(C["Media"].Textures.Spark128Texture)
		Castbar.Spark:SetBlendMode("ADD")
		Castbar.Spark:SetAlpha(0.8)

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
		Castbar.PostUpdatePip = Module.PostUpdatePip

		local mover = K.Mover(Castbar, "Focus Castbar", "FocusCB", { "BOTTOM", UIParent, "BOTTOM", -474, 750 }, Castbar:GetHeight() + Castbar:GetWidth() + 3, Castbar:GetHeight() + 3)
		Castbar:ClearAllPoints()
		Castbar:SetPoint("RIGHT", mover)
		Castbar.mover = mover

		self.Castbar = Castbar
	end

	if C["Unitframe"].ShowHealPrediction then
		local mhpb = self.Health:CreateTexture(nil, "BORDER", nil, 5)
		mhpb:SetWidth(1)
		mhpb:SetTexture(HealPredictionTexture)
		mhpb:SetVertexColor(0, 1, 0.5, 0.25)

		local ohpb = self.Health:CreateTexture(nil, "BORDER", nil, 5)
		ohpb:SetWidth(1)
		ohpb:SetTexture(HealPredictionTexture)
		ohpb:SetVertexColor(0, 1, 0, 0.25)

		local abb = self.Health:CreateTexture(nil, "BORDER", nil, 5)
		abb:SetWidth(1)
		abb:SetTexture(HealPredictionTexture)
		abb:SetVertexColor(1, 1, 0, 0.25)

		local abbo = self.Health:CreateTexture(nil, "ARTWORK", nil, 1)
		abbo:SetAllPoints(abb)
		abbo:SetTexture("Interface\\RaidFrame\\Shield-Overlay", true, true)
		abbo.tileSize = 32

		local oag = self.Health:CreateTexture(nil, "ARTWORK", nil, 1)
		oag:SetWidth(15)
		oag:SetTexture("Interface\\RaidFrame\\Shield-Overshield")
		oag:SetBlendMode("ADD")
		oag:SetAlpha(0.25)
		oag:SetPoint("TOPLEFT", self.Health, "TOPRIGHT", -5, 2)
		oag:SetPoint("BOTTOMLEFT", self.Health, "BOTTOMRIGHT", -5, -2)

		local hab = CreateFrame("StatusBar", nil, self.Health)
		hab:SetPoint("TOP")
		hab:SetPoint("BOTTOM")
		hab:SetPoint("RIGHT", self.Health:GetStatusBarTexture())
		hab:SetWidth(focusWidth)
		hab:SetReverseFill(true)
		hab:SetStatusBarTexture(HealPredictionTexture)
		hab:SetStatusBarColor(1, 0, 0, 0.25)

		local ohg = self.Health:CreateTexture(nil, "ARTWORK", nil, 1)
		ohg:SetWidth(15)
		ohg:SetTexture("Interface\\RaidFrame\\Absorb-Overabsorb")
		ohg:SetBlendMode("ADD")
		ohg:SetPoint("TOPRIGHT", self.Health, "TOPLEFT", 5, 2)
		ohg:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMLEFT", 5, -2)

		self.HealPredictionAndAbsorb = {
			myBar = mhpb,
			otherBar = ohpb,
			absorbBar = abb,
			absorbBarOverlay = abbo,
			overAbsorbGlow = oag,
			healAbsorbBar = hab,
			overHealAbsorbGlow = ohg,
			maxOverflow = 1,
		}
	end

	-- Level
	self.Level = self:CreateFontString(nil, "OVERLAY")
	if focusPortraitStyle ~= "NoPortraits" and focusPortraitStyle ~= "OverlayPortrait" then
		self.Level:Show()
		self.Level:SetPoint("BOTTOMLEFT", self.Portrait, "TOPLEFT", 0, 4)
		self.Level:SetPoint("BOTTOMRIGHT", self.Portrait, "TOPRIGHT", 0, 4)
	else
		self.Level:Hide()
	end
	self.Level:SetFontObject(K.UIFont)
	self:Tag(self.Level, "[fulllevel]")

	if C["Unitframe"].PvPIndicator then
		self.PvPIndicator = self:CreateTexture(nil, "OVERLAY")
		self.PvPIndicator:SetSize(30, 33)
		if focusPortraitStyle ~= "NoPortraits" and focusPortraitStyle ~= "OverlayPortrait" then
			self.PvPIndicator:SetPoint("LEFT", self.Portrait, "RIGHT", 2, 0)
		else
			self.PvPIndicator:SetPoint("LEFT", self.Health, "RIGHT", 2, 0)
		end
		self.PvPIndicator.PostUpdate = Module.PostUpdatePvPIndicator
	end

	self.LeaderIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.LeaderIndicator:SetSize(12, 12)
	if focusPortraitStyle == "NoPortraits" then
		self.LeaderIndicator:SetPoint("TOPRIGHT", self.Health, 0, 8)
	else
		self.LeaderIndicator:SetPoint("TOPRIGHT", self.Portrait, 0, 8)
	end

	self.RaidTargetIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	if focusPortraitStyle ~= "NoPortraits" and focusPortraitStyle ~= "OverlayPortrait" then
		self.RaidTargetIndicator:SetPoint("TOP", self.Portrait, "TOP", 0, 8)
	else
		self.RaidTargetIndicator:SetPoint("TOP", self.Health, "TOP", 0, 8)
	end
	self.RaidTargetIndicator:SetSize(16, 16)

	self.ReadyCheckIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	if focusPortraitStyle ~= "NoPortraits" and focusPortraitStyle ~= "OverlayPortrait" then
		self.ReadyCheckIndicator:SetPoint("CENTER", self.Portrait)
	else
		self.ReadyCheckIndicator:SetPoint("CENTER", self.Health)
	end
	self.ReadyCheckIndicator:SetSize(C["Unitframe"].FocusHealthHeight - 4, C["Unitframe"].FocusHealthHeight - 4)

	self.ResurrectIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.ResurrectIndicator:SetSize(44, 44)
	if focusPortraitStyle ~= "NoPortraits" and focusPortraitStyle ~= "OverlayPortrait" then
		self.ResurrectIndicator:SetPoint("CENTER", self.Portrait)
	else
		self.ResurrectIndicator:SetPoint("CENTER", self.Health)
	end

	if C["Unitframe"].DebuffHighlight then
		self.DebuffHighlight = self.Health:CreateTexture(nil, "OVERLAY")
		self.DebuffHighlight:SetAllPoints(self.Health)
		self.DebuffHighlight:SetTexture(C["Media"].Textures.White8x8Texture)
		self.DebuffHighlight:SetVertexColor(0, 0, 0, 0)
		self.DebuffHighlight:SetBlendMode("ADD")

		self.DebuffHighlightAlpha = 0.45
		self.DebuffHighlightFilter = true
	end

	self.Highlight = self.Health:CreateTexture(nil, "OVERLAY")
	self.Highlight:SetAllPoints()
	self.Highlight:SetTexture("Interface\\PETBATTLES\\PetBattle-SelectedPetGlow")
	self.Highlight:SetTexCoord(0, 1, 0.5, 1)
	self.Highlight:SetVertexColor(0.6, 0.6, 0.6)
	self.Highlight:SetBlendMode("ADD")
	self.Highlight:Hide()

	self.ThreatIndicator = {
		IsObjectType = K.Noop,
		Override = Module.UpdateThreat,
	}

	self.Range = Module.CreateRangeIndicator(self)
end
