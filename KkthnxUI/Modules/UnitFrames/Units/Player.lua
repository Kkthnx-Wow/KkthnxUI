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
	if hasJoined then
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

	local UnitframeTexture = K.GetTexture(C["General"].Texture)
	local HealPredictionTexture = K.GetTexture(C["General"].Texture)

	local Overlay = CreateFrame("Frame", nil, self) -- We will use this to overlay onto our special borders.
	Overlay:SetAllPoints()
	Overlay:SetFrameLevel(5)

	Module.CreateHeader(self)

	local Health = CreateFrame("StatusBar", nil, self)
	Health:SetHeight(playerHeight)
	Health:SetPoint("TOPLEFT")
	Health:SetPoint("TOPRIGHT")
	Health:SetStatusBarTexture(UnitframeTexture)
	Health:CreateBorder()

	Health.colorDisconnected = true
	Health.frequentUpdates = true

	if C["Unitframe"].Smooth then
		K:SmoothBar(Health)
	end

	if C["Unitframe"].HealthbarColor.Value == "Value" then
		Health.colorSmooth = true
		Health.colorClass = false
		Health.colorReaction = false
	elseif C["Unitframe"].HealthbarColor.Value == "Dark" then
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
	Health.Value:SetFontObject(K.UIFont)
	Health.Value:SetPoint("CENTER", Health, "CENTER", 0, 0)
	self:Tag(Health.Value, "[hp]")

	local Power = CreateFrame("StatusBar", nil, self)
	Power:SetHeight(C["Unitframe"].PlayerPowerHeight)
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

	if playerPortraitStyle ~= "NoPortraits" then
		if playerPortraitStyle == "OverlayPortrait" then
			local Portrait = CreateFrame("PlayerModel", "KKUI_PlayerPortrait", self)
			Portrait:SetFrameStrata(self:GetFrameStrata())
			Portrait:SetPoint("TOPLEFT", Health, "TOPLEFT", 1, -1)
			Portrait:SetPoint("BOTTOMRIGHT", Health, "BOTTOMRIGHT", -1, 1)
			Portrait:SetAlpha(0.6)

			self.Portrait = Portrait
		elseif playerPortraitStyle == "ThreeDPortraits" then
			local Portrait = CreateFrame("PlayerModel", "KKUI_PlayerPortrait", Health)
			Portrait:SetFrameStrata(self:GetFrameStrata())
			Portrait:SetSize(Health:GetHeight() + Power:GetHeight() + 6, Health:GetHeight() + Power:GetHeight() + 6)
			Portrait:SetPoint("TOPRIGHT", self, "TOPLEFT", -6, 0)
			Portrait:CreateBorder()

			self.Portrait = Portrait
		elseif playerPortraitStyle ~= "ThreeDPortraits" and playerPortraitStyle ~= "OverlayPortrait" then
			local Portrait = Health:CreateTexture("KKUI_PlayerPortrait", "BACKGROUND", nil, 1)
			Portrait:SetTexCoord(0.15, 0.85, 0.15, 0.85)
			Portrait:SetSize(Health:GetHeight() + Power:GetHeight() + 6, Health:GetHeight() + Power:GetHeight() + 6)
			Portrait:SetPoint("TOPRIGHT", self, "TOPLEFT", -6, 0)

			Portrait.Border = CreateFrame("Frame", nil, self)
			Portrait.Border:SetAllPoints(Portrait)
			Portrait.Border:CreateBorder()

			self.Portrait = Portrait

			if playerPortraitStyle == "ClassPortraits" or playerPortraitStyle == "NewClassPortraits" then
				Portrait.PostUpdate = Module.UpdateClassPortraits
			end
		end
	end

	if C["Unitframe"].ClassResources then
		Module:CreateClassPower(self)
	end

	if C["Unitframe"].PlayerDebuffs then -- and C["Unitframe"].TargetDebuffsTop
		local Debuffs = CreateFrame("Frame", nil, self)
		Debuffs.spacing = 6
		Debuffs.initialAnchor = "BOTTOMLEFT"
		Debuffs["growth-x"] = "RIGHT"
		Debuffs["growth-y"] = "UP"
		Debuffs:SetPoint("BOTTOMLEFT", Health, "TOPLEFT", 0, 6)
		Debuffs:SetPoint("BOTTOMRIGHT", Health, "TOPRIGHT", 0, 6)
		Debuffs.num = 14
		Debuffs.iconsPerRow = C["Unitframe"].PlayerDebuffsPerRow

		Module:UpdateAuraContainer(playerWidth, Debuffs, Debuffs.num)

		Debuffs.PostCreateButton = Module.PostCreateButton
		Debuffs.PostUpdateButton = Module.PostUpdateButton

		self.Debuffs = Debuffs
	end

	if C["Unitframe"].PlayerBuffs then -- and C["Unitframe"].TargetDebuffsTop
		local Buffs = CreateFrame("Frame", nil, self)
		Buffs:SetPoint("TOPLEFT", Power, "BOTTOMLEFT", 0, -6)
		Buffs:SetPoint("TOPRIGHT", Power, "BOTTOMRIGHT", 0, -6)
		Buffs.initialAnchor = "TOPLEFT"
		Buffs["growth-x"] = "RIGHT"
		Buffs["growth-y"] = "DOWN"
		Buffs.num = 20
		Buffs.spacing = 6
		Buffs.iconsPerRow = C["Unitframe"].PlayerBuffsPerRow
		Buffs.onlyShowPlayer = false

		Module:UpdateAuraContainer(playerWidth, Buffs, Buffs.num)

		Buffs.PostCreateButton = Module.PostCreateButton
		Buffs.PostUpdateButton = Module.PostUpdateButton

		self.Buffs = Buffs
	end

	if C["Unitframe"].PlayerCastbar then
		local Castbar = CreateFrame("StatusBar", "oUF_CastbarPlayer", self)
		Castbar:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
		Castbar:SetFrameLevel(10)
		Castbar:SetSize(C["Unitframe"].PlayerCastbarWidth, C["Unitframe"].PlayerCastbarHeight)
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

		local safeZone = Castbar:CreateTexture(nil, "OVERLAY")
		safeZone:SetTexture(K.GetTexture(C["General"].Texture))
		safeZone:SetVertexColor(0.69, 0.31, 0.31, 0.75)
		safeZone:SetPoint("TOPRIGHT")
		safeZone:SetPoint("BOTTOMRIGHT")
		Castbar:SetFrameLevel(10)
		Castbar.SafeZone = safeZone

		local lagStr = K.CreateFontString(Castbar, 11)
		lagStr:ClearAllPoints()
		lagStr:SetPoint("BOTTOM", Castbar, "TOP", 0, 4)
		Castbar.LagString = lagStr

		Module:ToggleCastBarLatency(self)

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

		local mover = K.Mover(Castbar, "Player Castbar", "PlayerCB", { "BOTTOM", UIParent, "BOTTOM", 0, 200 }, Castbar:GetHeight() + Castbar:GetWidth() + 3, Castbar:GetHeight() + 3)
		Castbar:ClearAllPoints()
		Castbar:SetPoint("RIGHT", mover)
		Castbar.mover = mover

		self.Castbar = Castbar
	end

	if C["Unitframe"].ShowHealPrediction then
		local frame = CreateFrame("Frame", nil, self)
		frame:SetAllPoints()

		local mhpb = frame:CreateTexture(nil, "BORDER", nil, 5)
		mhpb:SetWidth(1)
		mhpb:SetTexture(HealPredictionTexture)
		mhpb:SetVertexColor(0, 1, 0.5, 0.25)

		local ohpb = frame:CreateTexture(nil, "BORDER", nil, 5)
		ohpb:SetWidth(1)
		ohpb:SetTexture(HealPredictionTexture)
		ohpb:SetVertexColor(0, 1, 0, 0.25)

		local abb = frame:CreateTexture(nil, "BORDER", nil, 5)
		abb:SetWidth(1)
		abb:SetTexture(HealPredictionTexture)
		abb:SetVertexColor(1, 1, 0, 0.25)

		local abbo = frame:CreateTexture(nil, "ARTWORK", nil, 1)
		abbo:SetAllPoints(abb)
		abbo:SetTexture("Interface\\RaidFrame\\Shield-Overlay", true, true)
		abbo.tileSize = 32

		local oag = frame:CreateTexture(nil, "ARTWORK", nil, 1)
		oag:SetWidth(15)
		oag:SetTexture("Interface\\RaidFrame\\Shield-Overshield")
		oag:SetBlendMode("ADD")
		oag:SetAlpha(0.7)
		oag:SetPoint("TOPLEFT", Health, "TOPRIGHT", -5, 2)
		oag:SetPoint("BOTTOMLEFT", Health, "BOTTOMRIGHT", -5, -2)

		local hab = CreateFrame("StatusBar", nil, frame)
		hab:SetPoint("TOPLEFT", Health)
		hab:SetPoint("BOTTOMRIGHT", Health:GetStatusBarTexture())
		hab:SetReverseFill(true)
		hab:SetStatusBarTexture(HealPredictionTexture)
		hab:SetStatusBarColor(1, 0, 0, 0.25)
		hab:SetFrameLevel(frame:GetFrameLevel())

		local ohg = frame:CreateTexture(nil, "ARTWORK", nil, 1)
		ohg:SetWidth(15)
		ohg:SetTexture("Interface\\RaidFrame\\Absorb-Overabsorb")
		ohg:SetBlendMode("ADD")
		ohg:SetAlpha(0.5)
		ohg:SetPoint("TOPRIGHT", Health, "TOPLEFT", 5, 2)
		ohg:SetPoint("BOTTOMRIGHT", Health, "BOTTOMLEFT", 5, -2)

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
		self.predicFrame = frame
	end

	-- Level
	if C["Unitframe"].ShowPlayerLevel then
		local Level = self:CreateFontString(nil, "OVERLAY")
		if playerPortraitStyle ~= "NoPortraits" and playerPortraitStyle ~= "OverlayPortrait" then
			Level:Show()
			Level:SetPoint("TOP", self.Portrait, 0, 15)
		else
			Level:Hide()
		end
		Level:SetFontObject(K.UIFont)
		self:Tag(Level, "[fulllevel]")

		self.Level = Level
	end

	if C["Unitframe"].Stagger then
		if K.Class == "MONK" then
			local Stagger = CreateFrame("StatusBar", self:GetName() .. "Stagger", self)
			Stagger:SetPoint("BOTTOMLEFT", Health, "TOPLEFT", 0, 6)
			Stagger:SetSize(playerWidth, 14)
			Stagger:SetStatusBarTexture(UnitframeTexture)
			Stagger:CreateBorder()

			Stagger.Value = Stagger:CreateFontString(nil, "OVERLAY")
			Stagger.Value:SetFontObject(K.UIFont)
			Stagger.Value:SetPoint("CENTER", Stagger, "CENTER", 0, 0)
			self:Tag(Stagger.Value, "[monkstagger]")

			self.Stagger = Stagger
		end
	end

	if C["Unitframe"].AdditionalPower then
		local AdditionalPower = CreateFrame("StatusBar", self:GetName() .. "AdditionalPower", Health)
		AdditionalPower.frequentUpdates = true
		AdditionalPower:SetWidth(12)
		AdditionalPower:SetOrientation("VERTICAL")
		if playerPortraitStyle ~= "NoPortraits" and playerPortraitStyle ~= "OverlayPortrait" then
			AdditionalPower:SetPoint("TOPLEFT", self.Portrait, -18, 0)
			AdditionalPower:SetPoint("BOTTOMLEFT", self.Portrait, -18, 0)
		else
			AdditionalPower:SetPoint("TOPLEFT", self, -18, 0)
			AdditionalPower:SetPoint("BOTTOMLEFT", self, -18, 0)
		end
		AdditionalPower:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
		AdditionalPower:SetStatusBarColor(unpack(K.Colors.power.MANA))
		AdditionalPower:CreateBorder()

		if C["Unitframe"].Smooth then
			K:SmoothBar(AdditionalPower)
		end

		AdditionalPower.Text = AdditionalPower:CreateFontString(nil, "OVERLAY")
		AdditionalPower.Text:SetFontObject(K.UIFont)
		AdditionalPower.Text:SetFont(select(1, AdditionalPower.Text:GetFont()), 9, select(3, AdditionalPower.Text:GetFont()))
		AdditionalPower.Text:SetPoint("CENTER", AdditionalPower, 2, 0)

		AdditionalPower.PostUpdate = Module.PostUpdateAddPower

		self.AdditionalPower = AdditionalPower
	end

	if C["Unitframe"].GlobalCooldown then
		local GCD = CreateFrame("Frame", "oUF_PlayerGCD", Power)
		GCD:SetWidth(playerWidth)
		GCD:SetHeight(C["Unitframe"].PlayerPowerHeight - 2)
		GCD:SetPoint("LEFT", Power, "LEFT", 0, 0)

		GCD.Color = { 1, 1, 1, 0.6 }
		GCD.Texture = C["Media"].Textures.Spark128Texture
		GCD.Height = C["Unitframe"].PlayerPowerHeight - 2
		GCD.Width = 128 / 2

		self.GCD = GCD
	end

	if C["Unitframe"].CombatText then
		if IsAddOnLoaded("MikScrollingBattleText") or IsAddOnLoaded("Parrot") or IsAddOnLoaded("xCT") or IsAddOnLoaded("sct") then
			C["Unitframe"].CombatText = false
			return
		end

		local parentFrame = CreateFrame("Frame", nil, UIParent)
		local FloatingCombatFeedback = CreateFrame("Frame", "oUF_Player_CombatTextFrame", parentFrame)
		FloatingCombatFeedback:SetSize(32, 32)
		K.Mover(FloatingCombatFeedback, "CombatText", "PlayerCombatText", { "BOTTOM", self, "TOPLEFT", 0, 120 })

		for i = 1, 36 do
			FloatingCombatFeedback[i] = parentFrame:CreateFontString("$parentText", "OVERLAY")
		end

		FloatingCombatFeedback.font = select(1, KkthnxUIFontOutline:GetFont())
		FloatingCombatFeedback.fontFlags = "OUTLINE"
		FloatingCombatFeedback.abbreviateNumbers = true

		self.FloatingCombatFeedback = FloatingCombatFeedback
	end

	-- Swing timer
	if C["Unitframe"].SwingBar then
		local width, height = C["Unitframe"].SwingWidth, C["Unitframe"].SwingHeight

		local bar = CreateFrame("Frame", nil, self)
		bar:SetSize(width, height)
		bar.mover = K.Mover(bar, "UFs SwingBar", "Swing", { "BOTTOM", UIParent, "BOTTOM", 0, 176 })
		bar:ClearAllPoints()
		bar:SetPoint("CENTER", bar.mover)

		local two = CreateFrame("StatusBar", nil, bar)
		two:SetStatusBarTexture(UnitframeTexture)
		two:SetStatusBarColor(0.8, 0.8, 0.8)
		two:CreateBorder()
		two:Hide()
		two:SetAllPoints()

		local main = CreateFrame("StatusBar", nil, bar)
		main:SetStatusBarTexture(UnitframeTexture)
		main:SetStatusBarColor(0.8, 0.8, 0.8)
		main:CreateBorder()
		main:Hide()
		main:SetAllPoints()

		local off = CreateFrame("StatusBar", nil, bar)
		off:SetStatusBarTexture(UnitframeTexture)
		off:SetStatusBarColor(0.8, 0.8, 0.8)
		off:CreateBorder()
		off:Hide()
		if C["Unitframe"].OffOnTop then
			off:SetPoint("BOTTOMLEFT", bar, "TOPLEFT", 0, 6)
			off:SetPoint("BOTTOMRIGHT", bar, "TOPRIGHT", 0, 6)
		else
			off:SetPoint("TOPLEFT", bar, "BOTTOMLEFT", 0, -6)
			off:SetPoint("TOPRIGHT", bar, "BOTTOMRIGHT", 0, -6)
		end
		off:SetHeight(height)

		bar.Text = K.CreateFontString(bar, 12, "")
		bar.Text:SetShown(C["Unitframe"].SwingTimer)
		bar.TextMH = K.CreateFontString(main, 12, "")
		bar.TextMH:SetShown(C["Unitframe"].SwingTimer)
		bar.TextOH = K.CreateFontString(off, 12, "")
		bar.TextOH:SetShown(C["Unitframe"].SwingTimer)

		self.Swing = bar
		self.Swing.Twohand = two
		self.Swing.Mainhand = main
		self.Swing.Offhand = off
		self.Swing.hideOoc = true
	end

	local LeaderIndicator = Overlay:CreateTexture(nil, "OVERLAY")
	LeaderIndicator:SetSize(12, 12)
	if playerPortraitStyle ~= "NoPortraits" and playerPortraitStyle ~= "OverlayPortrait" then
		LeaderIndicator:SetPoint("TOPLEFT", self.Portrait, 0, 8)
	else
		LeaderIndicator:SetPoint("TOPLEFT", Health, 0, 8)
	end

	local AssistantIndicator = Overlay:CreateTexture(nil, "OVERLAY")
	AssistantIndicator:SetSize(12, 12)
	if playerPortraitStyle ~= "NoPortraits" and playerPortraitStyle ~= "OverlayPortrait" then
		AssistantIndicator:SetPoint("TOPLEFT", self.Portrait, 0, 8)
	else
		AssistantIndicator:SetPoint("TOPLEFT", Health, 0, 8)
	end

	if C["Unitframe"].PvPIndicator then
		local PvPIndicator = self:CreateTexture(nil, "OVERLAY")
		PvPIndicator:SetSize(30, 33)
		if playerPortraitStyle ~= "NoPortraits" and playerPortraitStyle ~= "OverlayPortrait" then
			PvPIndicator:SetPoint("RIGHT", self.Portrait, "LEFT", -2, 0)
		else
			PvPIndicator:SetPoint("RIGHT", Health, "LEFT", -2, 0)
		end
		PvPIndicator.PostUpdate = Module.PostUpdatePvPIndicator

		self.PvPIndicator = PvPIndicator
	end

	local CombatIndicator = Health:CreateTexture(nil, "OVERLAY")
	CombatIndicator:SetSize(20, 20)
	CombatIndicator:SetPoint("LEFT", 2, 0)

	local RaidTargetIndicator = Overlay:CreateTexture(nil, "OVERLAY")
	if playerPortraitStyle ~= "NoPortraits" and playerPortraitStyle ~= "OverlayPortrait" then
		RaidTargetIndicator:SetPoint("TOP", self.Portrait, "TOP", 0, 8)
	else
		RaidTargetIndicator:SetPoint("TOP", Health, "TOP", 0, 8)
	end
	RaidTargetIndicator:SetSize(16, 16)

	local ReadyCheckIndicator = Overlay:CreateTexture(nil, "OVERLAY")
	if playerPortraitStyle ~= "NoPortraits" and playerPortraitStyle ~= "OverlayPortrait" then
		ReadyCheckIndicator:SetPoint("CENTER", self.Portrait)
	else
		ReadyCheckIndicator:SetPoint("CENTER", Health)
	end
	ReadyCheckIndicator:SetSize(playerHeight - 4, playerHeight - 4)

	local ResurrectIndicator = Overlay:CreateTexture(nil, "OVERLAY")
	ResurrectIndicator:SetSize(44, 44)
	if playerPortraitStyle ~= "NoPortraits" and playerPortraitStyle ~= "OverlayPortrait" then
		ResurrectIndicator:SetPoint("CENTER", self.Portrait)
	else
		ResurrectIndicator:SetPoint("CENTER", Health)
	end

	do
		local RestingIndicator = CreateFrame("Frame", "KKUI_RestingFrame", Overlay)
		RestingIndicator:SetSize(5, 5)
		if playerPortraitStyle ~= "NoPortraits" and playerPortraitStyle ~= "OverlayPortrait" then
			RestingIndicator:SetPoint("TOPLEFT", self.Portrait, "TOPLEFT", -2, 4)
		else
			RestingIndicator:SetPoint("TOPLEFT", Health, "TOPLEFT", -2, 4)
		end
		RestingIndicator:Hide()
		RestingIndicator.str = {}

		local step, stepSpeed = 0, 0.33

		local stepMaps = {
			[1] = { true, false, false },
			[2] = { true, true, false },
			[3] = { true, true, true },
			[4] = { false, true, true },
			[5] = { false, false, true },
			[6] = { false, false, false },
		}

		local offsets = {
			[1] = { 4, -4 },
			[2] = { 0, 0 },
			[3] = { -5, 5 },
		}

		for i = 1, 3 do
			local textFrame = CreateFrame("Frame", nil, RestingIndicator)
			textFrame:SetAllPoints()
			textFrame:SetFrameLevel(i + 5)
			local text = K.CreateFontString(textFrame, (7 + i * 3), "z", "", "system", "CENTER", offsets[i][1], offsets[i][2])
			RestingIndicator.str[i] = text
		end

		RestingIndicator:SetScript("OnUpdate", function(self, elapsed)
			self.elapsed = (self.elapsed or 0) + elapsed
			if self.elapsed > stepSpeed then
				step = step + 1
				if step == 7 then
					step = 1
				end

				for i = 1, 3 do
					RestingIndicator.str[i]:SetShown(stepMaps[step][i])
				end

				self.elapsed = 0
			end
		end)

		RestingIndicator:SetScript("OnHide", function()
			step = 6
		end)

		self.RestingIndicator = RestingIndicator
	end

	local QuestSyncIndicator = Overlay:CreateTexture(nil, "OVERLAY")
	if playerPortraitStyle ~= "NoPortraits" and playerPortraitStyle ~= "OverlayPortrait" then
		QuestSyncIndicator:SetPoint("BOTTOM", self.Portrait, "BOTTOM", 0, -13)
	else
		QuestSyncIndicator:SetPoint("BOTTOM", Health, "BOTTOM", 0, -13)
	end
	QuestSyncIndicator:SetSize(26, 26)
	QuestSyncIndicator:SetAtlas("QuestSharing-DialogIcon")
	QuestSyncIndicator:Hide()

	self:RegisterEvent("QUEST_SESSION_LEFT", updatePartySync, true)
	self:RegisterEvent("QUEST_SESSION_JOINED", updatePartySync, true)
	self:RegisterEvent("PLAYER_ENTERING_WORLD", updatePartySync, true)

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

	local ThreatIndicator = {
		IsObjectType = K.Noop,
		Override = Module.UpdateThreat,
	}

	-- Fader
	if C["Unitframe"].CombatFade then
		self.Fader = {
			[1] = { Combat = 1, Arena = 1, Instance = 1 },
			[2] = { PlayerTarget = 1, PlayerNotMaxHealth = 1, PlayerNotMaxMana = 1, Casting = 1 },
			[3] = { Stealth = 0.5 },
			[4] = { notCombat = 0, PlayerTaxi = 0 },
		}
		self.NormalAlpha = 1
	end

	self.Overlay = Overlay
	self.Health = Health
	self.Power = Power
	self.LeaderIndicator = LeaderIndicator
	self.AssistantIndicator = AssistantIndicator
	self.CombatIndicator = CombatIndicator
	self.RaidTargetIndicator = RaidTargetIndicator
	self.ReadyCheckIndicator = ReadyCheckIndicator
	self.ResurrectIndicator = ResurrectIndicator
	self.QuestSyncIndicator = QuestSyncIndicator
	self.Highlight = Highlight
	self.ThreatIndicator = ThreatIndicator
end
