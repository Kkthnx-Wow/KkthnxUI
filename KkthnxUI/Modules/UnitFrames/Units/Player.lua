--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Creates and updates the Player unit frame.
-- - Design: Centerpiece of the UI. Features Health, Power, Portrait, Castbar, Class Power.
-- - Events: UNIT_HEALTH, UNIT_POWER, UNIT_AURA, etc. handled by oUF.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Unitframes")

-- REASON: Localize C-functions (Snake Case)
local select = _G.select
local string_format = _G.string.format
local unpack = _G.unpack

-- REASON: Localize Globals
local CreateFrame = _G.CreateFrame
local IsLevelAtEffectiveMaxLevel = _G.IsLevelAtEffectiveMaxLevel
local C_QuestSession = _G.C_QuestSession
local C_AddOns = _G.C_AddOns
local UIParent = _G.UIParent
local UnitLevel = _G.UnitLevel

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
	-- REASON: Quest Session Sync Indicator
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
	local playerPortraitStyle = C["Unitframe"].PortraitStyle

	local UnitframeTexture = K.GetTexture(C["General"].Texture)
	local HealPredictionTexture = K.GetTexture(C["General"].Texture)

	if not self then
		return
	end

	-- REASON: Overlay frame for borders and indicators.
	self.Overlay = CreateFrame("Frame", nil, self)
	self.Overlay:SetFrameStrata(self:GetFrameStrata())
	self.Overlay:SetFrameLevel(5)
	self.Overlay:SetAllPoints()
	self.Overlay:EnableMouse(false)

	Module.CreateHeader(self)

	-- REASON: Health Bar Setup
	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetHeight(playerHeight)
	self.Health:SetPoint("TOPLEFT")
	self.Health:SetPoint("TOPRIGHT")
	self.Health:SetStatusBarTexture(UnitframeTexture)
	self.Health:CreateBorder()

	self.Health.colorDisconnected = true
	self.Health.frequentUpdates = true

	if C["Unitframe"].Smooth then
		-- K:SmoothBar(self.Health)
	end

	if C["Unitframe"].HealthbarColor == 3 then
		self.Health.colorSmooth = true
		self.Health.colorClass = false
		self.Health.colorReaction = false
	elseif C["Unitframe"].HealthbarColor == 2 then
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
	self.Health.Value:SetFontObject(K.UIFont)
	self.Health.Value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
	self:Tag(self.Health.Value, "[hp]")

	-- REASON: Power Bar Setup
	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetHeight(C["Unitframe"].PlayerPowerHeight)
	self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -6)
	self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -6)
	self.Power:SetStatusBarTexture(UnitframeTexture)
	self.Power:CreateBorder()

	self.Power.colorPower = true
	self.Power.frequentUpdates = true

	if C["Unitframe"].Smooth then
		-- K:SmoothBar(self.Power)
	end

	self.Power.Value = self.Power:CreateFontString(nil, "OVERLAY")
	self.Power.Value:SetPoint("CENTER", self.Power, "CENTER", 0, 0)
	self.Power.Value:SetFontObject(K.UIFont)
	self.Power.Value:SetFont(select(1, self.Power.Value:GetFont()), 11, select(3, self.Power.Value:GetFont()))
	self:Tag(self.Power.Value, "[power]")

	-- REASON: Portrait Setup (2D/3D support)
	if playerPortraitStyle ~= 0 then
		if playerPortraitStyle == 4 then
			self.Portrait = CreateFrame("PlayerModel", nil, self)
			self.Portrait:SetFrameStrata(self:GetFrameStrata())
			self.Portrait:SetPoint("TOPLEFT", self.Health, "TOPLEFT", 1, -1)
			self.Portrait:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", -1, 1)
			self.Portrait:SetAlpha(0.6)
		elseif playerPortraitStyle == 5 then
			self.Portrait = CreateFrame("PlayerModel", nil, self.Health)
			self.Portrait:SetFrameStrata(self:GetFrameStrata())
			self.Portrait:SetSize(self.Health:GetHeight() + self.Power:GetHeight() + 6, self.Health:GetHeight() + self.Power:GetHeight() + 6)
			self.Portrait:SetPoint("TOPRIGHT", self, "TOPLEFT", -6, 0)
			self.Portrait:CreateBorder()
		else
			self.Portrait = self.Health:CreateTexture(nil, "BACKGROUND", nil, 1)
			self.Portrait:SetTexCoord(0.15, 0.85, 0.15, 0.85)
			self.Portrait:SetSize(self.Health:GetHeight() + self.Power:GetHeight() + 6, self.Health:GetHeight() + self.Power:GetHeight() + 6)
			self.Portrait:SetPoint("TOPRIGHT", self, "TOPLEFT", -6, 0)

			self.Portrait.Border = CreateFrame("Frame", nil, self)
			self.Portrait.Border:SetAllPoints(self.Portrait)
			self.Portrait.Border:CreateBorder()

			if playerPortraitStyle == 2 or playerPortraitStyle == 3 then
				self.Portrait.PostUpdate = Module.UpdateClassPortraits
			end
		end
	end

	if C["Unitframe"].ClassResources then
		Module:CreateClassPower(self)
	end

	-- REASON: Debuffs
	if C["Unitframe"].PlayerDebuffs then
		self.Debuffs = CreateFrame("Frame", nil, self)
		self.Debuffs.spacing = 6
		self.Debuffs.initialAnchor = "BOTTOMLEFT"
		self.Debuffs["growth-x"] = "RIGHT"
		self.Debuffs["growth-y"] = "UP"
		self.Debuffs:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, 6)
		self.Debuffs:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 0, 6)
		self.Debuffs.num = 14
		self.Debuffs.iconsPerRow = C["Unitframe"].PlayerDebuffsPerRow

		Module:UpdateAuraContainer(playerWidth, self.Debuffs, self.Debuffs.num)

		self.Debuffs.PostCreateButton = Module.PostCreateButton
		self.Debuffs.PostUpdateButton = Module.PostUpdateButton
	end

	-- REASON: Buffs
	if C["Unitframe"].PlayerBuffs then
		self.Buffs = CreateFrame("Frame", nil, self)
		self.Buffs:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -6)
		self.Buffs:SetPoint("TOPRIGHT", self.Power, "BOTTOMRIGHT", 0, -6)
		self.Buffs.initialAnchor = "TOPLEFT"
		self.Buffs["growth-x"] = "RIGHT"
		self.Buffs["growth-y"] = "DOWN"
		self.Buffs.num = 20
		self.Buffs.spacing = 6
		self.Buffs.iconsPerRow = C["Unitframe"].PlayerBuffsPerRow
		self.Buffs.onlyShowPlayer = false

		Module:UpdateAuraContainer(playerWidth, self.Buffs, self.Buffs.num)

		self.Buffs.PostCreateButton = Module.PostCreateButton
		self.Buffs.PostUpdateButton = Module.PostUpdateButton
	end

	-- REASON: Castbar
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

		Castbar.timeToHold = 0.5
		Castbar.PostCastStart = Module.UpdateCastBarColor
		Castbar.PostCastInterruptible = Module.UpdateCastBarColor
		Castbar.PostCastStop = Module.Castbar_FailedColor
		Castbar.PostCastFail = Module.Castbar_FailedColor
		Castbar.PostCastInterrupted = Module.Castbar_UpdateInterrupted
		Castbar.CreatePip = Module.CreatePip
		Castbar.PostUpdatePips = Module.PostUpdatePips
		Castbar.CustomTimeText = Module.CustomTimeText
		Castbar.CustomDelayText = Module.CustomTimeText
		
		-- Castbar.OnUpdate = Module.OnCastbarUpdate
		-- Castbar.PostCastStart = Module.PostCastStart
		-- Castbar.PostCastUpdate = Module.PostCastUpdate
		-- Castbar.PostCastStop = Module.PostCastStop
		-- Castbar.PostCastFail = Module.PostCastFailed
		-- Castbar.PostCastInterruptible = Module.PostUpdateInterruptible
		-- Castbar.CreatePip = Module.CreatePip
		-- Castbar.PostUpdatePips = Module.PostUpdatePips

		local mover = K.Mover(Castbar, "Player Castbar", "PlayerCB", { "BOTTOM", UIParent, "BOTTOM", 0, 200 }, Castbar:GetHeight() + Castbar:GetWidth() + 3, Castbar:GetHeight() + 3)
		Castbar:ClearAllPoints()
		Castbar:SetPoint("RIGHT", mover)
		Castbar.mover = mover

		self.Castbar = Castbar
	end

	-- REASON: Heal Prediction
	if C["Unitframe"].ShowHealPrediction then
		local frame = CreateFrame("Frame", nil, self)
		frame:SetAllPoints(self.Health)
		local frameLevel = frame:GetFrameLevel()

		local normalTexture = K.GetTexture(C["General"].Texture)

		-- Position and size
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
		local tex2 = overAbsorbBar:CreateTexture(nil, "ARTWORK", nil, 1)
		tex2:SetAllPoints(overAbsorbBar:GetStatusBarTexture())
		tex2:SetTexture("Interface\\RaidFrame\\Shield-Overlay", true, true)
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
		tex3:SetTexture("Interface\\RaidFrame\\Shield-Overlay", true, true)
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

	-- REASON: Level Tag
	if C["Unitframe"].ShowPlayerLevel then
		local Level = self:CreateFontString(nil, "OVERLAY")
		if playerPortraitStyle ~= 0 and playerPortraitStyle ~= 4 then
			Level:Show()
			Level:SetPoint("TOP", self.Portrait, 0, 15)
		else
			Level:Hide()
		end
		Level:SetFontObject(K.UIFont)
		self:Tag(Level, "[fulllevel]")

		self.Level = Level

		-- Handle dynamic max level hiding
		if C["Unitframe"].HideMaxPlayerLevel then
			local function UpdateLevelVisibility(_, _, newLevel)
				local currentLevel = type(newLevel) == "number" and newLevel or UnitLevel("player")
				if IsLevelAtEffectiveMaxLevel(currentLevel) then
					Level:Hide()
				else
					if playerPortraitStyle ~= 0 and playerPortraitStyle ~= 4 then
						Level:Show()
					end
				end
			end

			-- Initial check
			UpdateLevelVisibility()

			-- Update on level changes
			self:RegisterEvent("PLAYER_LEVEL_UP", UpdateLevelVisibility, true)
			self:RegisterEvent("PLAYER_ENTERING_WORLD", UpdateLevelVisibility, true)
		end
	end

	-- REASON: Monk Stagger
	if C["Unitframe"].Stagger then
		if K.Class == "MONK" then
			local Stagger = CreateFrame("StatusBar", self:GetName() .. "Stagger", self)
			Stagger:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, 6)
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

	-- REASON: Additional Power (Mana for Druids/Priests/Shamans)
	if C["Unitframe"].AdditionalPower then
		local AdditionalPower = CreateFrame("StatusBar", self:GetName() .. "AdditionalPower", self.Health)
		AdditionalPower.frequentUpdates = true
		AdditionalPower:SetWidth(12)
		AdditionalPower:SetOrientation("VERTICAL")
		if playerPortraitStyle ~= 0 and playerPortraitStyle ~= 4 then
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
			-- K:SmoothBar(AdditionalPower)
		end

		AdditionalPower.Text = AdditionalPower:CreateFontString(nil, "OVERLAY")
		AdditionalPower.Text:SetFontObject(K.UIFont)
		AdditionalPower.Text:SetFont(select(1, AdditionalPower.Text:GetFont()), 9, select(3, AdditionalPower.Text:GetFont()))
		AdditionalPower.Text:SetPoint("CENTER", AdditionalPower, 2, 0)

		AdditionalPower.PostUpdate = Module.PostUpdateAddPower

		self.AdditionalPower = AdditionalPower
	end

	-- REASON: Global Cooldown Spark
	if C["Unitframe"].GlobalCooldown then
		local GCD = CreateFrame("Frame", nil, self.Power)
		GCD:SetWidth(playerWidth)
		GCD:SetHeight(C["Unitframe"].PlayerPowerHeight - 2)
		GCD:SetPoint("LEFT", self.Power, "LEFT", 0, 0)

		GCD.Color = { 1, 1, 1, 0.6 }
		GCD.Texture = C["Media"].Textures.Spark128Texture
		GCD.Height = C["Unitframe"].PlayerPowerHeight - 2
		GCD.Width = 128 / 2

		self.GCD = GCD
	end

	self.LeaderIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.LeaderIndicator:SetSize(16, 16)
	if playerPortraitStyle ~= 0 and playerPortraitStyle ~= 4 then
		self.LeaderIndicator:SetPoint("TOPLEFT", self.Portrait, 0, 10)
	else
		self.LeaderIndicator:SetPoint("TOPLEFT", self.Health, 0, 10)
	end
	self.LeaderIndicator.PostUpdate = Module.PostUpdateLeaderIndicator

	self.AssistantIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.AssistantIndicator:SetSize(16, 16)
	if playerPortraitStyle ~= 0 and playerPortraitStyle ~= 4 then
		self.AssistantIndicator:SetPoint("TOPLEFT", self.Portrait, 0, 8)
	else
		self.AssistantIndicator:SetPoint("TOPLEFT", self.Health, 0, 8)
	end

	if C["Unitframe"].PvPIndicator then
		self.PvPIndicator = self:CreateTexture(nil, "OVERLAY")
		self.PvPIndicator:SetSize(30, 33)
		if playerPortraitStyle ~= 0 and playerPortraitStyle ~= 4 then
			self.PvPIndicator:SetPoint("RIGHT", self.Portrait, "LEFT", -2, 0)
		else
			self.PvPIndicator:SetPoint("RIGHT", self.Health, "LEFT", -2, 0)
		end
		self.PvPIndicator.PostUpdate = Module.PostUpdatePvPIndicator
	end

	self.CombatIndicator = self.Health:CreateTexture(nil, "OVERLAY")
	self.CombatIndicator:SetSize(16, 16)
	self.CombatIndicator:SetPoint("LEFT", 6, -1)
	self.CombatIndicator:SetAtlas("UI-HUD-UnitFrame-Player-CombatIcon")
	self.CombatIndicator:SetAlpha(0.7)

	self.RaidTargetIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	if playerPortraitStyle ~= 0 and playerPortraitStyle ~= 4 then
		self.RaidTargetIndicator:SetPoint("TOP", self.Portrait, "TOP", 0, 8)
	else
		self.RaidTargetIndicator:SetPoint("TOP", self.Health, "TOP", 0, 8)
	end
	self.RaidTargetIndicator:SetSize(16, 16)

	self.ReadyCheckIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	if playerPortraitStyle ~= 0 and playerPortraitStyle ~= 4 then
		self.ReadyCheckIndicator:SetPoint("CENTER", self.Portrait)
	else
		self.ReadyCheckIndicator:SetPoint("CENTER", self.Health)
	end
	self.ReadyCheckIndicator:SetSize(playerHeight - 4, playerHeight - 4)

	self.ResurrectIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.ResurrectIndicator:SetSize(44, 44)
	if playerPortraitStyle ~= 0 and playerPortraitStyle ~= 4 then
		self.ResurrectIndicator:SetPoint("CENTER", self.Portrait)
	else
		self.ResurrectIndicator:SetPoint("CENTER", self.Health)
	end

	-- REASON: Resting Indicator (ZZZ animation)
	do
		local RestingIndicator = CreateFrame("Frame", nil, self.Overlay)
		RestingIndicator:SetSize(5, 5)
		if playerPortraitStyle ~= 0 and playerPortraitStyle ~= 4 then
			RestingIndicator:SetPoint("TOPLEFT", self.Portrait, "TOPLEFT", -2, 4)
		else
			RestingIndicator:SetPoint("TOPLEFT", self.Health, "TOPLEFT", -2, 4)
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

		local function OnUpdateResting(self, elapsed)
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
		end

		RestingIndicator:SetScript("OnUpdate", OnUpdateResting)

		RestingIndicator:SetScript("OnHide", function(self)
			step = 6
			-- Clean up OnUpdate script when hidden to save performance
			self:SetScript("OnUpdate", nil)
			self.elapsed = 0
		end)

		RestingIndicator:SetScript("OnShow", function(self)
			-- Restore OnUpdate script when shown
			self:SetScript("OnUpdate", OnUpdateResting)
		end)

		self.RestingIndicator = RestingIndicator
	end

	self.QuestSyncIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	if playerPortraitStyle ~= 0 and playerPortraitStyle ~= 4 then
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

	-- REASON: Debuff Highlight
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
end
