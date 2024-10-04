local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Unitframes")

-- Lua functions
local select = select
local string_format = string.format

-- WoW API
local CreateFrame = CreateFrame

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
	Overlay:SetFrameStrata(self:GetFrameStrata())
	Overlay:SetFrameLevel(5)
	Overlay:SetAllPoints()
	Overlay:EnableMouse(false)

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
		local Portrait

		if playerPortraitStyle == "OverlayPortrait" then
			Portrait = CreateFrame("PlayerModel", "KKUI_PlayerPortrait", self)
			Portrait:SetFrameStrata(self:GetFrameStrata())
			Portrait:SetPoint("TOPLEFT", Health, "TOPLEFT", 1, -1)
			Portrait:SetPoint("BOTTOMRIGHT", Health, "BOTTOMRIGHT", -1, 1)
			Portrait:SetAlpha(0.6)
		elseif playerPortraitStyle == "ThreeDPortraits" then
			Portrait = CreateFrame("PlayerModel", "KKUI_PlayerPortrait", Health)
			Portrait:SetFrameStrata(self:GetFrameStrata())
			Portrait:SetSize(Health:GetHeight() + Power:GetHeight() + 6, Health:GetHeight() + Power:GetHeight() + 6)
			Portrait:SetPoint("TOPRIGHT", self, "TOPLEFT", -6, 0)
			Portrait:CreateBorder()
		else
			Portrait = Health:CreateTexture("KKUI_PlayerPortrait", "BACKGROUND", nil, 1)
			Portrait:SetTexCoord(0.15, 0.85, 0.15, 0.85)
			Portrait:SetSize(Health:GetHeight() + Power:GetHeight() + 6, Health:GetHeight() + Power:GetHeight() + 6)
			Portrait:SetPoint("TOPRIGHT", self, "TOPLEFT", -6, 0)

			Portrait.Border = CreateFrame("Frame", nil, self)
			Portrait.Border:SetAllPoints(Portrait)
			Portrait.Border:CreateBorder()

			if playerPortraitStyle == "ClassPortraits" or playerPortraitStyle == "NewClassPortraits" then
				Portrait.PostUpdate = Module.UpdateClassPortraits
			end
		end

		self.Portrait = Portrait
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
		Castbar.PostUpdatePips = Module.PostUpdatePips

		local mover = K.Mover(Castbar, "Player Castbar", "PlayerCB", { "BOTTOM", UIParent, "BOTTOM", 0, 200 }, Castbar:GetHeight() + Castbar:GetWidth() + 3, Castbar:GetHeight() + 3)
		Castbar:ClearAllPoints()
		Castbar:SetPoint("RIGHT", mover)
		Castbar.mover = mover

		self.Castbar = Castbar
	end

	if C["Unitframe"].ShowHealPrediction then
		local frame = CreateFrame("Frame", nil, self)
		frame:SetAllPoints(Health)
		local frameLevel = frame:GetFrameLevel()

		-- Position and size
		local myBar = CreateFrame("StatusBar", nil, frame)
		myBar:SetPoint("TOP")
		myBar:SetPoint("BOTTOM")
		myBar:SetPoint("LEFT", Health:GetStatusBarTexture(), "RIGHT")
		myBar:SetStatusBarTexture(HealPredictionTexture)
		myBar:SetStatusBarColor(0, 1, 0.5, 0.5)
		myBar:Hide()

		local otherBar = CreateFrame("StatusBar", nil, frame)
		otherBar:SetPoint("TOP")
		otherBar:SetPoint("BOTTOM")
		otherBar:SetPoint("LEFT", myBar:GetStatusBarTexture(), "RIGHT")
		otherBar:SetStatusBarTexture(HealPredictionTexture)
		otherBar:SetStatusBarColor(0, 1, 0, 0.5)
		otherBar:Hide()

		local absorbBar = CreateFrame("StatusBar", nil, frame)
		absorbBar:SetPoint("TOP")
		absorbBar:SetPoint("BOTTOM")
		absorbBar:SetPoint("LEFT", otherBar:GetStatusBarTexture(), "RIGHT")
		absorbBar:SetStatusBarTexture(HealPredictionTexture)
		absorbBar:SetStatusBarColor(0.66, 1, 1, 0.7)
		absorbBar:SetFrameLevel(frameLevel)
		absorbBar:Hide()

		local overAbsorbBar = CreateFrame("StatusBar", nil, frame)
		overAbsorbBar:SetAllPoints()
		overAbsorbBar:SetStatusBarTexture(HealPredictionTexture)
		overAbsorbBar:SetStatusBarColor(0.66, 1, 1, 0.7)
		overAbsorbBar:SetFrameLevel(frameLevel)
		overAbsorbBar:Hide()

		local healAbsorbBar = CreateFrame("StatusBar", nil, frame)
		healAbsorbBar:SetPoint("TOP")
		healAbsorbBar:SetPoint("BOTTOM")
		healAbsorbBar:SetPoint("RIGHT", Health:GetStatusBarTexture())
		healAbsorbBar:SetReverseFill(true)
		healAbsorbBar:SetStatusBarTexture(HealPredictionTexture)
		local tex = healAbsorbBar:GetStatusBarTexture()
		tex:SetTexture("Interface\\RaidFrame\\Shield-Overlay", true, true)
		tex:SetHorizTile(true)
		tex:SetVertTile(true)
		healAbsorbBar:Hide()

		local overAbsorb = Health:CreateTexture(nil, "OVERLAY")
		overAbsorb:SetWidth(15)
		overAbsorb:SetTexture("Interface\\RaidFrame\\Shield-Overshield")
		overAbsorb:SetBlendMode("ADD")
		overAbsorb:SetPoint("TOPLEFT", Health, "TOPRIGHT", -5, 2)
		overAbsorb:SetPoint("BOTTOMLEFT", Health, "BOTTOMRIGHT", -5, -2)
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
		if C_AddOns.IsAddOnLoaded("MikScrollingBattleText") or C_AddOns.IsAddOnLoaded("Parrot") or C_AddOns.IsAddOnLoaded("xCT") or C_AddOns.IsAddOnLoaded("sct") then
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
	LeaderIndicator:SetSize(16, 16)
	if playerPortraitStyle ~= "NoPortraits" and playerPortraitStyle ~= "OverlayPortrait" then
		LeaderIndicator:SetPoint("TOPLEFT", self.Portrait, 0, 10)
	else
		LeaderIndicator:SetPoint("TOPLEFT", Health, 0, 10)
	end

	local AssistantIndicator = Overlay:CreateTexture(nil, "OVERLAY")
	AssistantIndicator:SetSize(16, 16)
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
	CombatIndicator:SetSize(16, 16)
	CombatIndicator:SetPoint("LEFT", 6, -1)
	CombatIndicator:SetAtlas("UI-HUD-UnitFrame-Player-CombatIcon")
	CombatIndicator:SetAlpha(0.7)

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

		local textFrame = CreateFrame("Frame", nil, RestingIndicator)
		textFrame:SetAllPoints()
		textFrame:SetFrameLevel(6)

		local texts = {}
		local offsets = {
			{ 4, -4 },
			{ 0, 0 },
			{ -5, 5 },
		}

		for i = 1, 3 do
			texts[i] = K.CreateFontString(textFrame, (7 + i * 3), "z", "", "system", "CENTER", offsets[i][1], offsets[i][2])
		end

		local step, stepSpeed = 0, 0.33

		local stepMaps = {
			[1] = { true, false, false },
			[2] = { true, true, false },
			[3] = { true, true, true },
			[4] = { false, true, true },
			[5] = { false, false, true },
			[6] = { false, false, false },
		}

		RestingIndicator:SetScript("OnUpdate", function(self, elapsed)
			self.elapsed = (self.elapsed or 0) + elapsed
			if self.elapsed > stepSpeed then
				step = step + 1
				if step == 7 then
					step = 1
				end

				for i = 1, 3 do
					texts[i]:SetShown(stepMaps[step][i])
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
	-- if C["Unitframe"].CombatFade then
	-- 	self.Fader = {
	-- 		[1] = { Combat = 1, Arena = 1, Instance = 1 },
	-- 		[2] = { PlayerTarget = 1, PlayerNotMaxHealth = 1, PlayerNotMaxMana = 1, Casting = 1 },
	-- 		[3] = { Stealth = 0.5 },
	-- 		[4] = { notCombat = 0, PlayerTaxi = 0 },
	-- 	}
	-- 	self.NormalAlpha = 1
	-- end

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
