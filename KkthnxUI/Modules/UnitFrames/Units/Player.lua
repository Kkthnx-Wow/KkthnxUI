local K, C = unpack(select(2, ...))
local Module = K:GetModule("Unitframes")
local oUF = oUF or K.oUF

if (not oUF) then
	K.Print("Could not find a vaild instance of oUF. Stopping Player.lua code!")
	return
end

local _G = _G
local select = select

local CreateFrame = _G.CreateFrame

function Module:CreatePlayer()
	local UnitframeFont = K.GetFont(C["UIFonts"].UnitframeFonts)
	local UnitframeTexture = K.GetTexture(C["UITextures"].UnitframeTextures)
	local HealPredictionTexture = K.GetTexture(C["UITextures"].HealPredictionTextures)

	self.Overlay = CreateFrame("Frame", nil, self) -- We will use this to overlay onto our special borders.
	self.Overlay:SetAllPoints()
	self.Overlay:SetFrameLevel(5)

	Module.CreateHeader(self)

	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetHeight(28)
	self.Health:SetPoint("TOPLEFT")
	self.Health:SetPoint("TOPRIGHT")
	self.Health:SetStatusBarTexture(UnitframeTexture)
	self.Health:CreateBorder()

	self.Health.PostUpdate = C["General"].PortraitStyle.Value ~= "ThreeDPortraits" and Module.UpdateHealth
	self.Health.colorTapping = true
	self.Health.colorDisconnected = true
	self.Health.frequentUpdates = true
	self.Health.Smooth = C["Unitframe"].Smooth

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
	self.Health.Value:SetFontObject(UnitframeFont)
	self.Health.Value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
	self:Tag(self.Health.Value, "[hp]")

	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetHeight(14)
	self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -6)
	self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -6)
	self.Power:SetStatusBarTexture(UnitframeTexture)
	self.Power:CreateBorder()

	self.Power.colorPower = true
	self.Power.frequentUpdates = true

	if C["Unitframe"].Smooth then
		self.Power.Smooth = true
	end

	self.Power.Value = self.Power:CreateFontString(nil, "OVERLAY")
	self.Power.Value:SetPoint("CENTER", self.Power, "CENTER", 0, 0)
	self.Power.Value:SetFontObject(UnitframeFont)
	self.Power.Value:SetFont(select(1, self.Power.Value:GetFont()), 11, select(3, self.Power.Value:GetFont()))
	self:Tag(self.Power.Value, "[power]")

	if C["General"].PortraitStyle.Value == "ThreeDPortraits" then
		self.Portrait = CreateFrame("PlayerModel", nil, self.Health)
		self.Portrait:SetFrameStrata(self:GetFrameStrata())
		self.Portrait:SetSize(self.Health:GetHeight() + self.Power:GetHeight() + 6, self.Health:GetHeight() + self.Power:GetHeight() + 6)
		self.Portrait:SetPoint("TOPLEFT", self, "TOPLEFT", 0 ,0)
		self.Portrait:CreateBorder()
		self.Portrait:CreateInnerShadow()
	elseif C["General"].PortraitStyle.Value ~= "ThreeDPortraits" then
		self.Portrait = self.Health:CreateTexture("PlayerPortrait", "BACKGROUND", nil, 1)
		self.Portrait:SetTexCoord(0.15, 0.85, 0.15, 0.85)
		self.Portrait:SetSize(self.Health:GetHeight() + self.Power:GetHeight() + 6, self.Health:GetHeight() + self.Power:GetHeight() + 6)
		self.Portrait:SetPoint("TOPLEFT", self, "TOPLEFT", 0 ,0)

		self.Portrait.Border = CreateFrame("Frame", nil, self)
		self.Portrait.Border:SetAllPoints(self.Portrait)
		self.Portrait.Border:CreateBorder()
		self.Portrait.Border:CreateInnerShadow()

		if (C["General"].PortraitStyle.Value == "ClassPortraits" or C["General"].PortraitStyle.Value == "NewClassPortraits") then
			self.Portrait.PostUpdate = Module.UpdateClassPortraits
		end
	end

	self.Health:ClearAllPoints()
	self.Health:SetPoint("TOPLEFT", self.Portrait:GetWidth() + 6, 0)
	self.Health:SetPoint("TOPRIGHT")

	if C["Unitframe"].PlayerAuraBars then
		self.AuraBars = CreateFrame("Frame", self:GetName().."AuraBars", self)
		self.AuraBars:SetHeight(18)
		self.AuraBars:SetWidth(210)
		self.AuraBars:SetPoint("TOPLEFT", 0, 38)
		self.AuraBars.auraBarTexture = UnitframeTexture
		self.AuraBars.PostCreateBar = Module.PostCreateAuraBar
		self.AuraBars.CustomFilter = Module.CustomAuraFilter.Blacklist
		self.AuraBars.spacing = 6
		self.AuraBars.gap = 6
		self.AuraBars.width = 186
		self.AuraBars.height = 18

		K.Mover(self.AuraBars, "PlayerAuraBars", "PlayerAuraBars", {"TOPLEFT", self, 0, 38})
	elseif C["Unitframe"].PlayerBuffs then
		self.Buffs = CreateFrame("Frame", self:GetName().."Buffs", self)

		self.Buffs:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -6)
		self.Buffs:SetWidth(156)
		self.Buffs.num = 6 * 4
		self.Buffs.spacing = 6
		self.Buffs.size = ((((self.Buffs:GetWidth() - (self.Buffs.spacing * (self.Buffs.num / 4 - 1))) / self.Buffs.num)) * 4)
		self.Buffs:SetHeight(self.Buffs.size * 4)
		self.Buffs.initialAnchor = "TOPLEFT"
		self.Buffs["growth-y"] = "DOWN"
		self.Buffs["growth-x"] = "RIGHT"
		self.Buffs.PostCreateIcon = Module.PostCreateAura
		self.Buffs.PostUpdateIcon = Module.PostUpdateAura
		self.Buffs.CustomFilter = Module.CustomAuraFilter.Blacklist
	end

	if (C["Unitframe"].Castbars) then
		self.Castbar = CreateFrame("StatusBar", "PlayerCastbar", self)
		self.Castbar:SetPoint("BOTTOM", UIParent, "BOTTOM", 14, 200)
		self.Castbar:SetStatusBarTexture(UnitframeTexture)
		self.Castbar:SetSize(C["Unitframe"].PlayerCastbarWidth, C["Unitframe"].PlayerCastbarHeight)
		self.Castbar:SetClampedToScreen(true)
		self.Castbar:CreateBorder()

		self.Castbar.Spark = self.Castbar:CreateTexture(nil, "OVERLAY")
		self.Castbar.Spark:SetTexture(C["Media"].Spark_128)
		self.Castbar.Spark:SetSize(64, self.Castbar:GetHeight())
		self.Castbar.Spark:SetBlendMode("ADD")

		if C["Unitframe"].CastbarLatency then
			self.Castbar.SafeZone = self.Castbar:CreateTexture(nil, "ARTWORK")
			self.Castbar.SafeZone:SetTexture(UnitframeTexture)
			self.Castbar.SafeZone:SetPoint("RIGHT")
			self.Castbar.SafeZone:SetPoint("TOP")
			self.Castbar.SafeZone:SetPoint("BOTTOM")
			self.Castbar.SafeZone:SetVertexColor(0.69, 0.31, 0.31, 0.75)

			self.Castbar.Lag = self.Castbar:CreateFontString(nil, "OVERLAY")
			self.Castbar.Lag:SetPoint("TOPRIGHT", self.Castbar, "BOTTOMRIGHT", -3.5, -3)
			self.Castbar.Lag:SetFontObject(UnitframeFont)
			self.Castbar.Lag:SetFont(select(1, self.Castbar.Lag:GetFont()), 11, select(3, self.Castbar.Lag:GetFont()))
			self.Castbar.Lag:SetTextColor(0.84, 0.75, 0.65)
			self.Castbar.Lag:SetJustifyH("RIGHT")
			self:RegisterEvent("CURRENT_SPELL_CAST_CHANGED", Module.OnCastSent, true)
		end

		self.Castbar.decimal = "%.2f"

		self.Castbar.OnUpdate = Module.OnCastbarUpdate
		self.Castbar.PostCastStart = Module.PostCastStart
		self.Castbar.PostChannelStart = Module.PostCastStart
		self.Castbar.PostCastStop = Module.PostCastStop
		self.Castbar.PostChannelStop = Module.PostChannelStop
		self.Castbar.PostCastFail = Module.PostCastFailed
		self.Castbar.PostCastInterrupted = Module.PostCastFailed
		self.Castbar.PostCastInterruptible = Module.PostUpdateInterruptible
		self.Castbar.PostCastNotInterruptible = Module.PostUpdateInterruptible

		self.Castbar.Time = self.Castbar:CreateFontString(nil, "OVERLAY", UnitframeFont)
		self.Castbar.Time:SetPoint("RIGHT", -3.5, 0)
		self.Castbar.Time:SetTextColor(0.84, 0.75, 0.65)
		self.Castbar.Time:SetJustifyH("RIGHT")

		self.Castbar.Text = self.Castbar:CreateFontString(nil, "OVERLAY", UnitframeFont)
		self.Castbar.Text:SetPoint("LEFT", 3.5, 0)
		self.Castbar.Text:SetPoint("RIGHT", self.Castbar.Time, "LEFT", -3.5, 0)
		self.Castbar.Text:SetTextColor(0.84, 0.75, 0.65)
		self.Castbar.Text:SetJustifyH("LEFT")
		self.Castbar.Text:SetWordWrap(false)

		self.Castbar.Button = CreateFrame("Frame", nil, self.Castbar)
		self.Castbar.Button:SetSize(20, 20)
		self.Castbar.Button:CreateBorder()
		self.Castbar.Button:CreateInnerShadow()

		self.Castbar.Icon = self.Castbar.Button:CreateTexture(nil, "ARTWORK")
		self.Castbar.Icon:SetSize(self.Castbar:GetHeight(), self.Castbar:GetHeight())
		self.Castbar.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		self.Castbar.Icon:SetPoint("BOTTOMRIGHT", self.Castbar, "BOTTOMLEFT", -6, 0)

		self.Castbar.Button:SetAllPoints(self.Castbar.Icon)

		K.Mover(self.Castbar, "PlayerCastBar", "PlayerCastBar", {"BOTTOM", UIParent, "BOTTOM", 14, 200})
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

		local hab = CreateFrame("StatusBar", nil, self)
		hab:SetPoint("TOP")
		hab:SetPoint("BOTTOM")
		hab:SetPoint("RIGHT", self.Health:GetStatusBarTexture())
		hab:SetWidth(156)
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

	if C["Unitframe"].PlayerPowerPrediction then
		local mainBar = CreateFrame("StatusBar", self:GetName().."PowerPrediction", self.Power)
		mainBar:SetReverseFill(true)
		mainBar:SetPoint("TOP")
		mainBar:SetPoint("BOTTOM")
		mainBar:SetPoint("RIGHT", self.Power:GetStatusBarTexture(), "RIGHT")
		mainBar:SetStatusBarTexture(HealPredictionTexture)
		mainBar:SetStatusBarColor(1, 1, 1, 0.2)
		mainBar:SetWidth(156)

		self.PowerPrediction = {
			mainBar = mainBar
		}
	end

	if C["Unitframe"].ShowPlayerName then
		self.Name = self:CreateFontString(nil, "OVERLAY")
		self.Name:SetPoint("TOP", self.Health, 0, 16)
		self.Name:SetWidth(156)
		self.Name:SetFontObject(UnitframeFont)
		self:Tag(self.Name, "[color][name]")
	end

	-- Level
	if C["Unitframe"].ShowPlayerLevel and K.Level ~= _G.MAX_PLAYER_LEVEL then
		self.Level = self:CreateFontString(nil, "OVERLAY")
		self.Level:SetPoint("TOP", self.Portrait, 0, 15)
		self.Level:SetFontObject(UnitframeFont)
		self:Tag(self.Level, "[fulllevel]")
	end

	self.LeaderIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.LeaderIndicator:SetSize(14, 14)
	self.LeaderIndicator:SetPoint("TOPLEFT", self.Overlay, "TOPLEFT", 0, 8)

	if C["Unitframe"].ClassResources then
		local bar = CreateFrame("Frame", "ClassPowerBar", self)
		bar:SetSize(156, 14)

		if C["Unitframe"].ShowPlayerName then
			bar.Pos = {"TOPLEFT", self.Health, 0, 36}
		else
			bar.Pos = {"TOPLEFT", self.Health, 0, 20}
		end

		local bars = {}
		for i = 1, 6 do
			bars[i] = CreateFrame("StatusBar", nil, bar)
			bars[i]:SetHeight(14)
			bars[i]:SetWidth((156 - 5 * 6) / 6)
			bars[i]:SetStatusBarTexture(UnitframeTexture)
			bars[i]:SetFrameLevel(self:GetFrameLevel() + 5)
			bars[i]:CreateBorder()

			if i == 1 then
				bars[i]:SetPoint("BOTTOMLEFT")
			else
				bars[i]:SetPoint("LEFT", bars[i-1], "RIGHT", 6, 0)
			end

			if K.Class == "DEATHKNIGHT" then
				bars[i].timer = K.CreateFontString(bars[i], 13, "")
			end
		end

		if K.Class == "DEATHKNIGHT" then
			bars.colorSpec = true
			bars.sortOrder = "asc"
			bars.PostUpdate = Module.PostUpdateRunes
			self.Runes = bars
		else
			bars.PostUpdate = Module.PostUpdateClassPower
			self.ClassPower = bars
		end

		K.Mover(bar, "ClassPowerBar", "ClassPowerBar", bar.Pos, 156, 14)
	end

	if C["Unitframe"].Stagger then
		if K.Class == "MONK" then
			self.Stagger = CreateFrame("StatusBar", self:GetName().."Stagger", self)
			self.Stagger:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, 6)
			self.Stagger:SetSize(156, 14)
			self.Stagger:SetStatusBarTexture(UnitframeTexture)
			self.Stagger:CreateBorder()

			self.Stagger.Value = self.Stagger:CreateFontString(nil, "OVERLAY")
			self.Stagger.Value:SetFontObject(K.GetFont(C["UIFonts"].UnitframeFonts))
			self.Stagger.Value:SetPoint("CENTER", self.Stagger, "CENTER", 0, 0)
			self:Tag(self.Stagger.Value, "[monkstagger]")
		end
	end

	if C["Unitframe"].AdditionalPower then
		if K.Class == "DRUID" or K.Class == "PRIEST" or K.Class == "SHAMAN" then
			self.AdditionalPower = CreateFrame("StatusBar", self:GetName().."AdditionalPower", self)
			self.AdditionalPower:SetHeight(14)
			self.AdditionalPower:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, 6)
			self.AdditionalPower:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 0, 6)
			self.AdditionalPower:SetStatusBarTexture(K.GetTexture(C["UITextures"].UnitframeTextures))
			self.AdditionalPower.colorPower = true
			self.AdditionalPower:CreateBorder()
			self.AdditionalPower.frequentUpdates = true

			if C["Unitframe"].Smooth then
				self.AdditionalPower.Smooth = true
			end

			self.AdditionalPower.Text = self.AdditionalPower:CreateFontString(nil, "OVERLAY")
			self.AdditionalPower.Text:SetFontObject(K.GetFont(C["UIFonts"].UnitframeFonts))
			self.AdditionalPower.Text:SetPoint("CENTER", self.AdditionalPower, "CENTER", 0, -1)

			self.AdditionalPower.PostUpdate = Module.PostUpdateAddPower
		end
	end

	if C["Unitframe"].CombatText then
		local parentFrame = CreateFrame("Frame", nil, UIParent)
		self.FloatingCombatFeedback = CreateFrame("Frame", "oUF_Player_CombatTextFrame", parentFrame)
		self.FloatingCombatFeedback:SetSize(32, 32)
		K.Mover(self.FloatingCombatFeedback, "CombatText", "PlayerCombatText", {"BOTTOM", self, "TOPLEFT", 0, 120})

		for i = 1, 36 do
			self.FloatingCombatFeedback[i] = parentFrame:CreateFontString("$parentText", "OVERLAY")
		end

		self.FloatingCombatFeedback.font = C["Media"].Font
		self.FloatingCombatFeedback.fontFlags = "OUTLINE"
		self.FloatingCombatFeedback.showPets = true
		self.FloatingCombatFeedback.showHots = true
		self.FloatingCombatFeedback.showAutoAttack = true
		self.FloatingCombatFeedback.showOverHealing = false
		self.FloatingCombatFeedback.abbreviateNumbers = true
		self.FloatingCombatFeedback.colors = {
			ABSORB = {0.84, 0.75, 0.65},
			BLOCK = {0.84, 0.75, 0.65},
			CRITENERGIZE = {0.31, 0.45, 0.63},
			CRITHEAL = {0.33, 0.59, 0.33},
			CRITICAL = {0.69, 0.31, 0.31},
			CRUSHING = {0.69, 0.31, 0.31},
			DAMAGE = {0.69, 0.31, 0.31},
			ENERGIZE = {0.31, 0.45, 0.63},
			GLANCING = {0.69, 0.31, 0.31},
			HEAL = {0.33, 0.59, 0.33},
			IMMUNE = {0.84, 0.75, 0.65},
			MISS = {0.84, 0.75, 0.65},
			RESIST = {0.84, 0.75, 0.65},
			STANDARD = {0.84, 0.75, 0.65},
		}
	end

	-- Swing timer
	if C["Unitframe"].Swingbar then
		self.Swing = CreateFrame("Frame", "KKUI_SwingBar", self)
		self.Swing:SetSize(260, 14)
		self.Swing:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 280)

		self.Swing.Twohand = CreateFrame("Statusbar", nil, self.Swing)
		self.Swing.Twohand:SetPoint("TOPLEFT")
		self.Swing.Twohand:SetPoint("BOTTOMRIGHT")
		self.Swing.Twohand:SetStatusBarTexture(UnitframeTexture)
		self.Swing.Twohand:SetStatusBarColor(0.8, 0.3, 0.3)
		self.Swing.Twohand:SetFrameLevel(20)
		self.Swing.Twohand:SetFrameStrata("LOW")
		self.Swing.Twohand:Hide()
		self.Swing.Twohand:CreateBorder()

		if C["Unitframe"].SwingbarTimer then
			self.Swing.Twohand.Text = self.Swing.Twohand:CreateFontString(nil, "OVERLAY")
			self.Swing.Twohand.Text:SetFontObject(K.GetFont(C["UIFonts"].UnitframeFonts))
			self.Swing.Twohand.Text:SetPoint("LEFT", self.Swing.Twohand, 3, 0)
			self.Swing.Twohand.Text:SetSize(260 * 0.7, 14)
			self.Swing.Twohand.Text:SetJustifyH("LEFT")
		end

		self.Swing.Twohand.Spark = self.Swing.Twohand:CreateTexture(nil, "OVERLAY")
		self.Swing.Twohand.Spark:SetTexture(C["Media"].Spark_16)
		self.Swing.Twohand.Spark:SetHeight(self.Swing:GetHeight())
		self.Swing.Twohand.Spark:SetBlendMode("ADD")
		self.Swing.Twohand.Spark:SetPoint("CENTER", self.Swing.Twohand:GetStatusBarTexture(), "RIGHT", 0, 0)

		self.Swing.Mainhand = CreateFrame("Statusbar", nil, self.Swing)
		self.Swing.Mainhand:SetPoint("BOTTOM", self.Castbar, 0, 0)
		self.Swing.Mainhand:SetSize(260, 16)
		self.Swing.Mainhand:SetStatusBarTexture(UnitframeTexture)
		self.Swing.Mainhand:SetStatusBarColor(0.8, 0.3, 0.3)
		self.Swing.Mainhand:SetFrameLevel(20)
		self.Swing.Mainhand:SetFrameStrata("LOW")
		self.Swing.Mainhand:Hide()
		self.Swing.Mainhand:CreateBorder()

		if C["Unitframe"].SwingbarTimer then
			self.Swing.Mainhand.Text = self.Swing.Mainhand:CreateFontString(nil, "OVERLAY")
			self.Swing.Mainhand.Text:SetFontObject(K.GetFont(C["UIFonts"].UnitframeFonts))
			self.Swing.Mainhand.Text:SetPoint("LEFT", self.Swing.Mainhand, 3, 0)
			self.Swing.Mainhand.Text:SetSize(260 * 0.7, 12)
			self.Swing.Mainhand.Text:SetJustifyH("LEFT")
		end

		self.Swing.Mainhand.Spark = self.Swing.Mainhand:CreateTexture(nil, "OVERLAY")
		self.Swing.Mainhand.Spark:SetTexture(C["Media"].Spark_16)
		self.Swing.Mainhand.Spark:SetHeight(self.Swing:GetHeight())
		self.Swing.Mainhand.Spark:SetBlendMode("ADD")
		self.Swing.Mainhand.Spark:SetPoint("CENTER", self.Swing.Mainhand:GetStatusBarTexture(), "RIGHT", 0, 0)

		self.Swing.Offhand = CreateFrame("Statusbar", nil, self.Swing)
		self.Swing.Offhand:SetPoint("BOTTOM", self.Swing.Mainhand, "TOP", 0, 2)
		self.Swing.Offhand:SetSize(260, 16)
		self.Swing.Offhand:SetStatusBarTexture(UnitframeTexture)
		self.Swing.Offhand:SetStatusBarColor(0.8, 0.3, 0.3)
		self.Swing.Offhand:SetFrameLevel(20)
		self.Swing.Offhand:SetFrameStrata("LOW")
		self.Swing.Offhand:Hide()
		self.Swing.Offhand:CreateBorder()

		if C["Unitframe"].SwingbarTimer then
			self.Swing.Offhand.Text = self.Swing.Offhand:CreateFontString(nil, "OVERLAY")
			self.Swing.Offhand.Text:SetFontObject(K.GetFont(C["UIFonts"].UnitframeFonts))
			self.Swing.Offhand.Text:SetPoint("LEFT", self.Swing.Offhand, 3, 0)
			self.Swing.Offhand.Text:SetSize(260 * 0.7, 12)
			self.Swing.Offhand.Text:SetJustifyH("LEFT")
		end

		self.Swing.Offhand.Spark = self.Swing.Offhand:CreateTexture(nil, "OVERLAY")
		self.Swing.Offhand.Spark:SetTexture(C["Media"].Spark_16)
		self.Swing.Offhand.Spark:SetHeight(self.Swing:GetHeight())
		self.Swing.Offhand.Spark:SetBlendMode("ADD")
		self.Swing.Offhand.Spark:SetPoint("CENTER", self.Swing.Offhand:GetStatusBarTexture(), "RIGHT", 0, 0)

		self.Swing.hideOoc = true

		K.Mover(self.Swing, "PlayerSwingBar", "PlayerSwingBar", {"TOP", self.Castbar, "BOTTOM", 0, -5})
	end

	if C["Unitframe"].PvPIndicator then
		self.PvPIndicator = self:CreateTexture(nil, "OVERLAY")
		self.PvPIndicator:SetSize(30, 33)
		self.PvPIndicator:SetPoint("RIGHT", self.Portrait, "LEFT", -2, 0)
		self.PvPIndicator.PostUpdate = Module.PostUpdatePvPIndicator
	end

	self.CombatIndicator = self.Health:CreateTexture(nil, "OVERLAY")
	self.CombatIndicator:SetSize(20, 20)
	self.CombatIndicator:SetPoint("LEFT", 0, 0)
	self.CombatIndicator:SetVertexColor(1, 0.2, 0.2, 1)

	self.RaidTargetIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.RaidTargetIndicator:SetPoint("TOP", self.Portrait, "TOP", 0, 8)
	self.RaidTargetIndicator:SetSize(16, 16)

	self.ReadyCheckIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.ReadyCheckIndicator:SetPoint("CENTER", self.Portrait)
	self.ReadyCheckIndicator:SetSize(self.Portrait:GetWidth() - 4, self.Portrait:GetHeight() - 4)

	self.ResurrectIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.ResurrectIndicator:SetSize(44, 44)
	self.ResurrectIndicator:SetPoint("CENTER", self.Portrait)

	self.RestingIndicator = self.Health:CreateTexture(nil, "OVERLAY")
	self.RestingIndicator:SetPoint("RIGHT", 0, 2)
	self.RestingIndicator:SetSize(22, 22)
	self.RestingIndicator:SetAlpha(0.7)

	if C["Unitframe"].DebuffHighlight then
		self.DebuffHighlight = self.Health:CreateTexture(nil, "OVERLAY")
		self.DebuffHighlight:SetAllPoints(self.Health)
		self.DebuffHighlight:SetTexture(C["Media"].Blank)
		self.DebuffHighlight:SetVertexColor(0, 0, 0, 0)
		self.DebuffHighlight:SetBlendMode("ADD")

		self.DebuffHighlightAlpha = 0.45
		self.DebuffHighlightFilter = true
		self.DebuffHighlightFilterTable = K.DebuffHighlightColors
	end

	if C["Unitframe"].PortraitTimers then
		self.PortraitTimer = CreateFrame("Frame", "$parentPortraitTimer", self.Health)
		self.PortraitTimer:CreateInnerShadow()
		self.PortraitTimer:SetFrameLevel(5) -- Watch me
		self.PortraitTimer:SetInside(self.Portrait, 1, 1)
		self.PortraitTimer:Hide()
	end

	if C["Unitframe"].GlobalCooldown then
		self.GlobalCooldown = CreateFrame("Frame", nil, self.Health)
		self.GlobalCooldown:SetWidth(156)
		self.GlobalCooldown:SetHeight(28)
		self.GlobalCooldown:SetFrameStrata("HIGH")
		self.GlobalCooldown:SetPoint("LEFT", self.Health, "LEFT", 0, 0)
	end

	self.Highlight = self.Health:CreateTexture(nil, "OVERLAY")
	self.Highlight:SetAllPoints()
	self.Highlight:SetTexture("Interface\\PETBATTLES\\PetBattle-SelectedPetGlow")
	self.Highlight:SetTexCoord(0, 1, .5, 1)
	self.Highlight:SetVertexColor(.6, .6, .6)
	self.Highlight:SetBlendMode("ADD")
	self.Highlight:Hide()

	self.ThreatIndicator = {
		IsObjectType = function() end,
		Override = Module.UpdateThreat,
	}

	self.CombatFade = C["Unitframe"].CombatFade
end