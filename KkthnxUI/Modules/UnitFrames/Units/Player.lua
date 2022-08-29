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
	-- local timeStart, memStart = 0, 0
	-- if K.isProfiling then
	-- 	timeStart, memStart = debugprofilestop(), collectgarbage("count")
	-- end
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

	Module:CreateClassPower(self)

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

		Debuffs.PostCreateIcon = Module.PostCreateAura
		Debuffs.PostUpdateIcon = Module.PostUpdateAura

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

		Buffs.PostCreateIcon = Module.PostCreateAura
		Buffs.PostUpdateIcon = Module.PostUpdateAura

		self.Buffs = Buffs
	end

	if C["Unitframe"].PlayerCastbar then
		local Castbar = CreateFrame("StatusBar", "PlayerCastbar", self)
		Castbar:SetPoint("BOTTOM", UIParent, "BOTTOM", C["Unitframe"].PlayerCastbarIcon and 14 or 0, 200)
		Castbar:SetStatusBarTexture(UnitframeTexture)
		Castbar:SetSize(C["Unitframe"].PlayerCastbarWidth, C["Unitframe"].PlayerCastbarHeight)
		Castbar:SetClampedToScreen(true)
		Castbar:CreateBorder()

		Castbar.Spark = Castbar:CreateTexture(nil, "OVERLAY")
		Castbar.Spark:SetTexture(C["Media"].Textures.Spark128Texture)
		Castbar.Spark:SetSize(64, Castbar:GetHeight())
		Castbar.Spark:SetBlendMode("ADD")

		if C["Unitframe"].CastbarLatency then
			Castbar.SafeZone = Castbar:CreateTexture(nil, "OVERLAY")
			Castbar.SafeZone:SetTexture(UnitframeTexture)
			Castbar.SafeZone:SetVertexColor(0.69, 0.31, 0.31, 0.75)
			Castbar.SafeZone:SetPoint("TOPRIGHT")
			Castbar.SafeZone:SetPoint("BOTTOMRIGHT")
			Castbar:SetFrameLevel(10)

			Castbar.LagString = Castbar:CreateFontString(nil, "OVERLAY")
			Castbar.LagString:SetFontObject(K.UIFont)
			Castbar.LagString:SetFont(select(1, Castbar.LagString:GetFont()), 11, select(3, Castbar.LagString:GetFont()))
			Castbar.LagString:SetTextColor(0.84, 0.75, 0.65)
			Castbar.LagString:ClearAllPoints()
			Castbar.LagString:SetPoint("TOPRIGHT", Castbar, "BOTTOMRIGHT", -3.5, -3)

			self:RegisterEvent("GLOBAL_MOUSE_UP", Module.OnCastSent, true) -- Fix quests with WorldFrame interaction
			self:RegisterEvent("GLOBAL_MOUSE_DOWN", Module.OnCastSent, true)
			self:RegisterEvent("CURRENT_SPELL_CAST_CHANGED", Module.OnCastSent, true)
		else
			self:UnregisterEvent("GLOBAL_MOUSE_UP", Module.OnCastSent)
			self:UnregisterEvent("GLOBAL_MOUSE_DOWN", Module.OnCastSent)
			self:UnregisterEvent("CURRENT_SPELL_CAST_CHANGED", Module.OnCastSent)
			if Castbar and Castbar.__sendTime then
				Castbar.__sendTime = nil
			end
		end

		Castbar.decimal = "%.2f"

		Castbar.Time = Castbar:CreateFontString(nil, "OVERLAY")
		Castbar.Time:SetFontObject(K.UIFont)
		Castbar.Time:SetPoint("RIGHT", -3.5, 0)
		Castbar.Time:SetTextColor(0.84, 0.75, 0.65)
		Castbar.Time:SetJustifyH("RIGHT")

		Castbar.Text = Castbar:CreateFontString(nil, "OVERLAY")
		Castbar.Text:SetFontObject(K.UIFont)
		Castbar.Text:SetPoint("LEFT", 3.5, 0)
		Castbar.Text:SetPoint("RIGHT", Castbar.Time, "LEFT", -3.5, 0)
		Castbar.Text:SetTextColor(0.84, 0.75, 0.65)
		Castbar.Text:SetJustifyH("LEFT")
		Castbar.Text:SetWordWrap(false)

		if C["Unitframe"].PlayerCastbarIcon then
			Castbar.Button = CreateFrame("Frame", nil, Castbar)
			Castbar.Button:CreateBorder()

			Castbar.Icon = Castbar.Button:CreateTexture(nil, "ARTWORK")
			Castbar.Icon:SetSize(Castbar:GetHeight(), Castbar:GetHeight())
			Castbar.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
			Castbar.Icon:SetPoint("BOTTOMRIGHT", Castbar, "BOTTOMLEFT", -6, 0)

			Castbar.Button:SetAllPoints(Castbar.Icon)
		end

		local mover = K.Mover(Castbar, "Player Castbar", "PlayerCB", { "BOTTOM", UIParent, "BOTTOM", C["Unitframe"].PlayerCastbarIcon and 14 or 0, 200 })
		Castbar:ClearAllPoints()
		Castbar:SetPoint("RIGHT", mover)
		Castbar.mover = mover

		Castbar.OnUpdate = Module.OnCastbarUpdate
		Castbar.PostCastStart = Module.PostCastStart
		Castbar.PostCastUpdate = Module.PostCastUpdate
		Castbar.PostCastStop = Module.PostCastStop
		Castbar.PostCastFail = Module.PostCastFailed
		Castbar.PostCastInterruptible = Module.PostUpdateInterruptible

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

	if C["Unitframe"].PlayerPowerPrediction then
		local mainBar = CreateFrame("StatusBar", self:GetName() .. "PowerPrediction", Power)
		mainBar:SetReverseFill(true)
		mainBar:SetPoint("TOP", 0, -1)
		mainBar:SetPoint("BOTTOM", 0, 1)
		mainBar:SetPoint("RIGHT", Power:GetStatusBarTexture(), "RIGHT", -1, 0)
		mainBar:SetStatusBarTexture(HealPredictionTexture)
		mainBar:SetStatusBarColor(0.8, 0.1, 0.1, 0.6)
		mainBar:SetWidth(playerWidth)

		self.PowerPrediction = {
			mainBar = mainBar,
		}
	end

	if C["Unitframe"].ShowPlayerName then
		local Name = self:CreateFontString(nil, "OVERLAY")
		Name:SetPoint("BOTTOMLEFT", Health, "TOPLEFT", 0, 4)
		Name:SetPoint("BOTTOMRIGHT", Health, "TOPRIGHT", 0, 4)
		Name:SetFontObject(K.UIFont)
		if playerPortraitStyle == "NoPortraits" then
			if C["Unitframe"].HealthbarColor.Value == "Class" then
				self:Tag(Name, "[name] [fulllevel][afkdnd]")
			else
				self:Tag(Name, "[color][name] [fulllevel][afkdnd]")
			end
		else
			if C["Unitframe"].HealthbarColor.Value == "Class" then
				self:Tag(Name, "[name][afkdnd]")
			else
				self:Tag(Name, "[color][name][afkdnd]")
			end
		end

		self.Name = Name
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
		twospark:SetHeight(14)
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
		mainspark:SetHeight(14)
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
		offspark:SetHeight(14)
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

	local RestingIndicator = Health:CreateTexture(nil, "OVERLAY")
	RestingIndicator:SetPoint("RIGHT", -2, 2)
	RestingIndicator:SetSize(22, 22)

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
		DebuffHighlight:SetTexture(C["Media"].Textures.BlankTexture)
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
	self.RestingIndicator = RestingIndicator
	self.QuestSyncIndicator = QuestSyncIndicator
	self.Highlight = Highlight
	self.ThreatIndicator = ThreatIndicator

	-- if K.isProfiling then
	-- 	K:LogDebugInfo(self:GetDebugName() .. ":CreatePlayer", debugprofilestop() - timeStart, collectgarbage("count") - memStart)
	-- end
end
