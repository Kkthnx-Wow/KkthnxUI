local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Unitframes")

local _G = _G
local select = _G.select
local string_format = _G.string.format

local CreateFrame = _G.CreateFrame

function Module.PostUpdateAddPower(element, cur, max)
	if element.Text and max > 0 then
		local perc = cur / max * 100
		if perc == 100 then
			perc = ""
			element:SetAlpha(0)
		else
			perc = string_format("%d%%", perc)
			element:SetAlpha(1)
		end

		element.Text:SetText(perc)
	end
end

local function updatePartySync(self)
	local hasJoined = C_QuestSession.HasJoined()
	if (hasJoined) then
		self.QuestSyncIndicator:Show()
	else
		self.QuestSyncIndicator:Hide()
	end
end

function Module:CreatePlayer()
	self.mystyle = "player"

	local playerWidth = C["Unitframe"].PlayerHealthWidth
	local playerHeight = C["Unitframe"].PlayerHealthHeight
	local playerPortraitStyle = C["Unitframe"].PortraitStyle.Value

	local UnitframeFont = K.GetFont(C["UIFonts"].UnitframeFonts)
	local UnitframeTexture = K.GetTexture(C["UITextures"].UnitframeTextures)
	local HealPredictionTexture = K.GetTexture(C["UITextures"].HealPredictionTextures)

	self.Overlay = CreateFrame("Frame", nil, self) -- We will use this to overlay onto our special borders.
	self.Overlay:SetAllPoints()
	self.Overlay:SetFrameLevel(5)

	Module.CreateHeader(self)

	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetHeight(playerHeight)
	self.Health:SetPoint("TOPLEFT")
	self.Health:SetPoint("TOPRIGHT")
	self.Health:SetStatusBarTexture(UnitframeTexture)
	self.Health:CreateBorder()

	self.Health.PostUpdate = Module.UpdateHealth
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
	self.Health.Value:SetFontObject(UnitframeFont)
	self.Health.Value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
	self:Tag(self.Health.Value, "[hp]")

	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetHeight(C["Unitframe"].PlayerPowerHeight)
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
	self.Power.Value:SetFontObject(UnitframeFont)
	self.Power.Value:SetFont(select(1, self.Power.Value:GetFont()), 11, select(3, self.Power.Value:GetFont()))
	self:Tag(self.Power.Value, "[power]")

	if playerPortraitStyle ~= "NoPortraits" then
		if playerPortraitStyle == "OverlayPortrait" then
			self.Portrait = CreateFrame("PlayerModel", "KKUI_PlayerPortrait", self)
			self.Portrait:SetFrameStrata(self:GetFrameStrata())
			self.Portrait:SetPoint("TOPLEFT", self.Health, "TOPLEFT", 1, -1)
			self.Portrait:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", -1, 1)
			self.Portrait:SetAlpha(0.6)
		elseif playerPortraitStyle == "ThreeDPortraits" then
			self.Portrait = CreateFrame("PlayerModel", "KKUI_PlayerPortrait", self.Health)
			self.Portrait:SetFrameStrata(self:GetFrameStrata())
			self.Portrait:SetSize(self.Health:GetHeight() + self.Power:GetHeight() + 6, self.Health:GetHeight() + self.Power:GetHeight() + 6)
			self.Portrait:SetPoint("TOPRIGHT", self, "TOPLEFT", -6, 0)
			self.Portrait:CreateBorder()
		elseif playerPortraitStyle ~= "ThreeDPortraits" and playerPortraitStyle ~= "OverlayPortrait" then
			self.Portrait = self.Health:CreateTexture("KKUI_PlayerPortrait", "BACKGROUND", nil, 1)
			self.Portrait:SetTexCoord(0.15, 0.85, 0.15, 0.85)
			self.Portrait:SetSize(self.Health:GetHeight() + self.Power:GetHeight() + 6, self.Health:GetHeight() + self.Power:GetHeight() + 6)
			self.Portrait:SetPoint("TOPRIGHT", self, "TOPLEFT", -6, 0)

			self.Portrait.Border = CreateFrame("Frame", nil, self)
			self.Portrait.Border:SetAllPoints(self.Portrait)
			self.Portrait.Border:CreateBorder()

			if (playerPortraitStyle == "ClassPortraits" or playerPortraitStyle == "NewClassPortraits") then
				self.Portrait.PostUpdate = Module.UpdateClassPortraits
			end
		end
	end

	if C["Unitframe"].ClassResources and not C["Nameplate"].ShowPlayerPlate then
		Module:CreateClassPower(self)
	end

	if C["Unitframe"].PlayerDeBuffs then
		self.Debuffs = CreateFrame("Frame", nil, self)
		self.Debuffs.spacing = 6
		self.Debuffs.initialAnchor = "TOPLEFT"
		self.Debuffs["growth-x"] = "RIGHT"
		self.Debuffs["growth-y"] = "UP"
		self.Debuffs:SetPoint("TOPLEFT", self.Health, 0, 48)
		self.Debuffs.num = 14
		self.Debuffs.iconsPerRow = 5

		Module:UpdateAuraContainer(playerWidth, self.Debuffs, self.Debuffs.num)

		self.Debuffs.PostCreateIcon = Module.PostCreateAura
		self.Debuffs.PostUpdateIcon = Module.PostUpdateAura
	end

	if C["Unitframe"].PlayerBuffs then
		self.Buffs = CreateFrame("Frame", nil, self)
		self.Buffs:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -6)
		self.Buffs.initialAnchor = "TOPLEFT"
		self.Buffs["growth-x"] = "RIGHT"
		self.Buffs["growth-y"] = "DOWN"
		self.Buffs.num = 6
		self.Buffs.spacing = 6
		self.Buffs.iconsPerRow = 6
		self.Buffs.onlyShowPlayer = false

		Module:UpdateAuraContainer(playerWidth, self.Buffs, self.Buffs.num)

		self.Buffs.showStealableBuffs = true
		self.Buffs.PostCreateIcon = Module.PostCreateAura
		self.Buffs.PostUpdateIcon = Module.PostUpdateAura
	end

	if C["Unitframe"].PlayerCastbar then
		self.Castbar = CreateFrame("StatusBar", "PlayerCastbar", self)
		self.Castbar:SetPoint("BOTTOM", UIParent, "BOTTOM", C["Unitframe"].PlayerCastbarIcon and 14 or 0, 200)
		self.Castbar:SetStatusBarTexture(UnitframeTexture)
		self.Castbar:SetSize(C["Unitframe"].PlayerCastbarWidth, C["Unitframe"].PlayerCastbarHeight)
		self.Castbar:SetClampedToScreen(true)
		self.Castbar:CreateBorder()

		self.Castbar.Spark = self.Castbar:CreateTexture(nil, "OVERLAY")
		self.Castbar.Spark:SetTexture(C["Media"].Textures.Spark128Texture)
		self.Castbar.Spark:SetSize(64, self.Castbar:GetHeight())
		self.Castbar.Spark:SetBlendMode("ADD")

		if C["Unitframe"].CastbarLatency then
			self.Castbar.SafeZone = self.Castbar:CreateTexture(nil, "OVERLAY")
			self.Castbar.SafeZone:SetTexture(UnitframeTexture)
			self.Castbar.SafeZone:SetVertexColor(0.69, 0.31, 0.31, 0.75)
			self.Castbar.SafeZone:SetPoint("TOPRIGHT")
			self.Castbar.SafeZone:SetPoint("BOTTOMRIGHT")
			self.Castbar:SetFrameLevel(10)

			self.Castbar.LagString = self.Castbar:CreateFontString(nil, "OVERLAY")
			self.Castbar.LagString:SetFontObject(UnitframeFont)
			self.Castbar.LagString:SetFont(select(1, self.Castbar.LagString:GetFont()), 11, select(3, self.Castbar.LagString:GetFont()))
			self.Castbar.LagString:SetTextColor(0.84, 0.75, 0.65)
			self.Castbar.LagString:ClearAllPoints()
			self.Castbar.LagString:SetPoint("TOPRIGHT", self.Castbar, "BOTTOMRIGHT", -3.5, -3)

			self:RegisterEvent("CURRENT_SPELL_CAST_CHANGED", Module.OnCastSent, true)
		end

		self.Castbar.decimal = "%.2f"

		self.Castbar.OnUpdate = Module.OnCastbarUpdate
		self.Castbar.PostCastStart = Module.PostCastStart
		self.Castbar.PostCastStop = Module.PostCastStop
		self.Castbar.PostCastFail = Module.PostCastFailed
		self.Castbar.PostCastInterruptible = Module.PostUpdateInterruptible

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

		if C["Unitframe"].PlayerCastbarIcon then
			self.Castbar.Button = CreateFrame("Frame", nil, self.Castbar)
			self.Castbar.Button:CreateBorder()

			self.Castbar.Icon = self.Castbar.Button:CreateTexture(nil, "ARTWORK")
			self.Castbar.Icon:SetSize(self.Castbar:GetHeight(), self.Castbar:GetHeight())
			self.Castbar.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
			self.Castbar.Icon:SetPoint("BOTTOMRIGHT", self.Castbar, "BOTTOMLEFT", -6, 0)

			self.Castbar.Button:SetAllPoints(self.Castbar.Icon)
		end

		local mover = K.Mover(self.Castbar, "Player Castbar", "PlayerCB", {"BOTTOM", UIParent, "BOTTOM", C["Unitframe"].PlayerCastbarIcon and 14 or 0, 200})
		self.Castbar:ClearAllPoints()
		self.Castbar:SetPoint("RIGHT", mover)
		self.Castbar.mover = mover
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
		hab:SetWidth(170)
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
		mainBar:SetPoint("TOP", 0, -1)
		mainBar:SetPoint("BOTTOM", 0, 1)
		mainBar:SetPoint("RIGHT", self.Power:GetStatusBarTexture(), "RIGHT", -1, 0)
		mainBar:SetStatusBarTexture(HealPredictionTexture)
		mainBar:SetStatusBarColor(0.8, 0.1, 0.1, 0.6)
		mainBar:SetWidth(playerWidth)

		self.PowerPrediction = {
			mainBar = mainBar
		}
	end

	if C["Unitframe"].ShowPlayerName then
		self.Name = self:CreateFontString(nil, "OVERLAY")
		self.Name:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, 4)
		self.Name:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 0, 4)
		self.Name:SetFontObject(UnitframeFont)
		if playerPortraitStyle == "NoPortraits" then
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
	end

	-- Level
	if C["Unitframe"].ShowPlayerLevel then
		self.Level = self:CreateFontString(nil, "OVERLAY")
		if playerPortraitStyle ~= "NoPortraits" and playerPortraitStyle ~= "OverlayPortrait" then
			self.Level:Show()
			self.Level:SetPoint("TOP", self.Portrait, 0, 15)
		else
			self.Level:Hide()
		end
		self.Level:SetFontObject(UnitframeFont)
		self:Tag(self.Level, "[fulllevel]")
	end

	if C["Unitframe"].Stagger then
		if K.Class == "MONK" then
			self.Stagger = CreateFrame("StatusBar", self:GetName().."Stagger", self)
			self.Stagger:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, 6)
			self.Stagger:SetSize(playerWidth, 14)
			self.Stagger:SetStatusBarTexture(UnitframeTexture)
			self.Stagger:CreateBorder()

			self.Stagger.Value = self.Stagger:CreateFontString(nil, "OVERLAY")
			self.Stagger.Value:SetFontObject(K.GetFont(C["UIFonts"].UnitframeFonts))
			self.Stagger.Value:SetPoint("CENTER", self.Stagger, "CENTER", 0, 0)
			self:Tag(self.Stagger.Value, "[monkstagger]")
		end
	end

	if C["Unitframe"].AdditionalPower then
		self.AdditionalPower = CreateFrame("StatusBar", self:GetName().."AdditionalPower", self.Health)
		self.AdditionalPower.frequentUpdates = true
		self.AdditionalPower:SetWidth(12)
		self.AdditionalPower:SetOrientation("VERTICAL")
		if playerPortraitStyle ~= "NoPortraits" and playerPortraitStyle ~= "OverlayPortrait" then
			self.AdditionalPower:SetPoint("TOPLEFT", self.Portrait, -18, 0)
			self.AdditionalPower:SetPoint("BOTTOMLEFT", self.Portrait, -18, 0)
		else
			self.AdditionalPower:SetPoint("TOPLEFT", self, -18, 0)
			self.AdditionalPower:SetPoint("BOTTOMLEFT", self, -18, 0)
		end
		self.AdditionalPower:SetStatusBarTexture(K.GetTexture(C["UITextures"].UnitframeTextures))
		self.AdditionalPower:SetStatusBarColor(unpack(K.Colors.power.MANA))
		self.AdditionalPower:CreateBorder()

		if C["Unitframe"].Smooth then
			K:SmoothBar(self.AdditionalPower)
		end

		self.AdditionalPower.Text = self.AdditionalPower:CreateFontString(nil, "OVERLAY")
		self.AdditionalPower.Text:SetFontObject(K.GetFont(C["UIFonts"].UnitframeFonts))
		self.AdditionalPower.Text:SetFont(select(1, self.AdditionalPower.Text:GetFont()), 9, select(3, self.AdditionalPower.Text:GetFont()))
		self.AdditionalPower.Text:SetPoint("CENTER", self.AdditionalPower, 2, 0)

		self.AdditionalPower.PostUpdate = Module.PostUpdateAddPower
	end

	-- GCD spark
	if C["Unitframe"].GlobalCooldown then
		-- self.GCD = CreateFrame("Frame", self:GetName().."_GlobalCooldown", self)
		-- self.GCD:SetWidth(playerWidth)
		-- self.GCD:SetHeight(self.Health:GetHeight())
		-- self.GCD:SetFrameStrata("HIGH")
		-- self.GCD:SetPoint("LEFT", self.Health, "LEFT", 0, 0)

		-- self.GCD.Color = {1, 1, 1}
		-- self.GCD.Height = 26
		-- self.GCD.Width = 128
	end

	if C["Unitframe"].CombatText then
		if IsAddOnLoaded("MikScrollingBattleText") or IsAddOnLoaded("Parrot") or IsAddOnLoaded("xCT") or IsAddOnLoaded("sct") then
			C["Unitframe"].CombatText = false
			return
		end

		local parentFrame = CreateFrame("Frame", nil, UIParent)
		self.FloatingCombatFeedback = CreateFrame("Frame", "oUF_Player_CombatTextFrame", parentFrame)
		self.FloatingCombatFeedback:SetSize(32, 32)
		K.Mover(self.FloatingCombatFeedback, "CombatText", "PlayerCombatText", {"BOTTOM", self, "TOPLEFT", 0, 120})

		for i = 1, 36 do
			self.FloatingCombatFeedback[i] = parentFrame:CreateFontString("$parentText", "OVERLAY")
		end

		self.FloatingCombatFeedback.font = C["Media"].Fonts.DamageFont
		self.FloatingCombatFeedback.fontFlags = "OUTLINE"
		self.FloatingCombatFeedback.abbreviateNumbers = true
	end

	-- Swing timer
	if C["Unitframe"].Swingbar then
		local bar = CreateFrame("Frame", nil, self)
		local width = C["Unitframe"].PlayerCastbarWidth - C["Unitframe"].PlayerCastbarHeight - 5
		bar:SetSize(width, 13)
		if C["Unitframe"].PlayerCastbar then
			bar:SetPoint("TOP", self.Castbar.mover, "BOTTOM", 0, -6)
		else
			bar:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 200)
		end

		local two = CreateFrame("StatusBar", nil, bar)
		two:Hide()
		two:SetAllPoints()
		two:SetStatusBarTexture(UnitframeTexture)
		two:SetStatusBarColor(0.31, 0.45, 0.63)
		two:CreateBorder()

		local twospark = two:CreateTexture(nil, "OVERLAY")
		twospark:SetTexture(C["Media"].Textures.Spark16Texture)
		twospark:SetHeight(C["DataBars"].Height)
		twospark:SetBlendMode("ADD")
		twospark:SetPoint("CENTER", two:GetStatusBarTexture(), "RIGHT", 0, 0)

		local bg = two:CreateTexture(nil, "BACKGROUND", nil, 1)
		bg:Hide()
		bg:SetPoint("TOPRIGHT")
		bg:SetPoint("BOTTOMRIGHT")
		bg:SetColorTexture(0.2, 0.2, 0.2, 0.6)

		local main = CreateFrame("StatusBar", nil, bar)
		main:Hide()
		main:SetAllPoints()
		main:SetStatusBarTexture(UnitframeTexture)
		main:SetStatusBarColor(0.31, 0.45, 0.63)
		main:CreateBorder()

		local mainspark = main:CreateTexture(nil, "OVERLAY")
		mainspark:SetTexture(C["Media"].Textures.Spark16Texture)
		mainspark:SetHeight(C["DataBars"].Height)
		mainspark:SetBlendMode("ADD")
		mainspark:SetPoint("CENTER", main:GetStatusBarTexture(), "RIGHT", 0, 0)

		local off = CreateFrame("StatusBar", nil, bar)
		off:Hide()
		off:SetPoint("TOPLEFT", bar, "BOTTOMLEFT", 0, -3)
		off:SetPoint("BOTTOMRIGHT", bar, "BOTTOMRIGHT", 0, -6)
		off:SetStatusBarTexture(UnitframeTexture)
		off:SetStatusBarColor(0.78, 0.25, 0.25)
		off:CreateBorder()

		local offspark = off:CreateTexture(nil, "OVERLAY")
		offspark:SetTexture(C["Media"].Textures.Spark16Texture)
		offspark:SetHeight(C["DataBars"].Height)
		offspark:SetBlendMode("ADD")
		offspark:SetPoint("CENTER", off:GetStatusBarTexture(), "RIGHT", 0, 0)

		if C["Unitframe"].SwingbarTimer then
			bar.Text = K.CreateFontString(bar, 12, "", "")
			bar.TextMH = K.CreateFontString(main, 12, "", "")
			bar.TextOH = K.CreateFontString(off, 12, "", "", false, "CENTER", 1, -5)
		end

		self.Swing = bar
		self.Swing.Twohand = two
		self.Swing.Mainhand = main
		self.Swing.Offhand = off
		self.Swing.bg = bg
		self.Swing.hideOoc = true
	end

	self.LeaderIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.LeaderIndicator:SetSize(12, 12)
	if playerPortraitStyle ~= "NoPortraits" and playerPortraitStyle ~= "OverlayPortrait" then
		self.LeaderIndicator:SetPoint("TOPLEFT", self.Portrait, 0, 8)
	else
		self.LeaderIndicator:SetPoint("TOPLEFT", self.Health, 0, 8)
	end

	self.AssistantIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.AssistantIndicator:SetSize(12, 12)
	if playerPortraitStyle ~= "NoPortraits" and playerPortraitStyle ~= "OverlayPortrait" then
		self.AssistantIndicator:SetPoint("TOPLEFT", self.Portrait, 0, 8)
	else
		self.AssistantIndicator:SetPoint("TOPLEFT", self.Health, 0, 8)
	end

	if C["Unitframe"].PvPIndicator then
		self.PvPIndicator = self:CreateTexture(nil, "OVERLAY")
		self.PvPIndicator:SetSize(30, 33)
		if playerPortraitStyle ~= "NoPortraits" and playerPortraitStyle ~= "OverlayPortrait" then
			self.PvPIndicator:SetPoint("RIGHT", self.Portrait, "LEFT", -2, 0)
		else
			self.PvPIndicator:SetPoint("RIGHT", self.Health, "LEFT", -2, 0)
		end
		self.PvPIndicator.PostUpdate = Module.PostUpdatePvPIndicator
	end

	self.CombatIndicator = self.Health:CreateTexture(nil, "OVERLAY")
	self.CombatIndicator:SetSize(20, 20)
	self.CombatIndicator:SetPoint("LEFT", 2, 0)

	self.RaidTargetIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	if playerPortraitStyle ~= "NoPortraits" and playerPortraitStyle ~= "OverlayPortrait" then
		self.RaidTargetIndicator:SetPoint("TOP", self.Portrait, "TOP", 0, 8)
	else
		self.RaidTargetIndicator:SetPoint("TOP", self.Health, "TOP", 0, 8)
	end
	self.RaidTargetIndicator:SetSize(16, 16)

	self.ReadyCheckIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	if playerPortraitStyle ~= "NoPortraits" and playerPortraitStyle ~= "OverlayPortrait" then
		self.ReadyCheckIndicator:SetPoint("CENTER", self.Portrait)
	else
		self.ReadyCheckIndicator:SetPoint("CENTER", self.Health)
	end
	self.ReadyCheckIndicator:SetSize(playerHeight - 4, playerHeight - 4)

	self.ResurrectIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.ResurrectIndicator:SetSize(44, 44)
	if playerPortraitStyle ~= "NoPortraits" and playerPortraitStyle ~= "OverlayPortrait" then
		self.ResurrectIndicator:SetPoint("CENTER", self.Portrait)
	else
		self.ResurrectIndicator:SetPoint("CENTER", self.Health)
	end

	self.RestingIndicator = self.Health:CreateTexture(nil, "OVERLAY")
	self.RestingIndicator:SetPoint("RIGHT", -2, 2)
	self.RestingIndicator:SetSize(22, 22)

	self.QuestSyncIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	if playerPortraitStyle ~= "NoPortraits" and playerPortraitStyle ~= "OverlayPortrait" then
		self.QuestSyncIndicator:SetPoint("BOTTOM", self.Portrait, "BOTTOM", 0, -13)
	else
		self.QuestSyncIndicator:SetPoint("BOTTOM", self.Health, "BOTTOM", 0, -13)
	end
	self.QuestSyncIndicator:SetSize(26, 26)
	self.QuestSyncIndicator:SetAtlas("QuestSharing-DialogIcon")
	self.QuestSyncIndicator:Hide()

	self:RegisterEvent("QUEST_SESSION_LEFT", updatePartySync, true)
	self:RegisterEvent("QUEST_SESSION_JOINED", updatePartySync, true)
	self:RegisterEvent("PLAYER_ENTERING_WORLD", updatePartySync, true)

	if C["Unitframe"].DebuffHighlight then
		self.DebuffHighlight = self.Health:CreateTexture(nil, "OVERLAY")
		self.DebuffHighlight:SetAllPoints(self.Health)
		self.DebuffHighlight:SetTexture(C["Media"].Textures.BlankTexture)
		self.DebuffHighlight:SetVertexColor(0, 0, 0, 0)
		self.DebuffHighlight:SetBlendMode("ADD")

		self.DebuffHighlightAlpha = 0.45
		self.DebuffHighlightFilter = true
	end

	if C["Unitframe"].GlobalCooldown then
		self.GlobalCooldown = CreateFrame("Frame", nil, self.Health)
		self.GlobalCooldown:SetWidth(playerWidth)
		self.GlobalCooldown:SetHeight(28)
		self.GlobalCooldown:SetFrameStrata("HIGH")
		self.GlobalCooldown:SetPoint("LEFT", self.Health, "LEFT", 0, 0)
	end

	self.CombatFade = C["Unitframe"].CombatFade

	self.Highlight = self.Health:CreateTexture(nil, "OVERLAY")
	self.Highlight:SetAllPoints()
	self.Highlight:SetTexture("Interface\\PETBATTLES\\PetBattle-SelectedPetGlow")
	self.Highlight:SetTexCoord(0, 1, .5, 1)
	self.Highlight:SetVertexColor(.6, .6, .6)
	self.Highlight:SetBlendMode("ADD")
	self.Highlight:Hide()

	self.ThreatIndicator = {
		IsObjectType = K.Noop,
		Override = Module.UpdateThreat,
	}
end