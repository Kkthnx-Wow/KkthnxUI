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
	if not element.Text then
		return
	end

	local IsSecret = K.IsSecret

	if IsSecret(cur) or IsSecret(max) then
		if cur then
			element.Text:SetText(AbbreviateNumbers(cur))
			element:SetAlpha(1)
		else
			element.Text:SetText("")
			element:SetAlpha(0)
		end
		return
	end

	if not max or max <= 0 then
		element.Text:SetText("")
		element:SetAlpha(0)
		return
	end

	local perc = cur / max * 100
	if perc >= 100 then
		element.Text:SetText("")
		element:SetAlpha(0)
	else
		element.Text:SetFormattedText("%d%%", K.Round(perc))
		element:SetAlpha(1)
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
		K:SmoothBar(self.Health)
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

	Module:CreateBarValueTag(self, self.Health, "[hp]")

	-- REASON: Health spark — shows a glow at the current HP edge; hidden at full/zero/dead/offline.
	self.Health.Spark = Module:CreateBarSpark(self.Health)
	self.Health.PostUpdate = Module.PostUpdateHealthSpark

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
		K:SmoothBar(self.Power)
	end

	Module:CreateBarValueTag(self, self.Power, "[power]", { size = 11 })

	-- REASON: Power spark — shows a glow at the current power edge; hidden at full/zero/dead/offline.
	self.Power.Spark = Module:CreateBarSpark(self.Power)
	self.Power.PostUpdate = Module.PostUpdatePowerSpark

	Module:CreateUnitPortrait(self, { side = "left", modelName = "PlayerPortrait" })

	Module:CreatePrivateAuras(self, {
		point = "TOPRIGHT",
		relativeTo = self.Health,
		relativePoint = "TOPRIGHT",
		x = -2,
		y = -2,
		initialAnchor = "TOPRIGHT",
		growthX = "LEFT",
		growthY = "DOWN",
	})

	if C["Unitframe"].ClassResources then
		Module:CreateClassPower(self)
	end

	-- REASON: Debuffs
	if C["Unitframe"].PlayerDebuffs then
		self.Debuffs = CreateFrame("Frame", nil, self)
		self.Debuffs.spacing = 6
		self.Debuffs.initialAnchor = "BOTTOMLEFT"
		self.Debuffs.growthX = "RIGHT"
		self.Debuffs.growthY = "UP"
		self.Debuffs:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, 6)
		self.Debuffs:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 0, 6)
		self.Debuffs.num = 14
		self.Debuffs.iconsPerRow = C["Unitframe"].PlayerDebuffsPerRow

		Module:UpdateAuraContainer(playerWidth, self.Debuffs, self.Debuffs.num)

		self.Debuffs.PostCreateButton = Module.PostCreateButton
		self.Debuffs.PostUpdateButton = Module.PostUpdateButton
		self.Debuffs.showDebuffType = true
	end

	-- REASON: Buffs
	if C["Unitframe"].PlayerBuffs then
		self.Buffs = CreateFrame("Frame", nil, self)
		self.Buffs:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -6)
		self.Buffs:SetPoint("TOPRIGHT", self.Power, "BOTTOMRIGHT", 0, -6)
		self.Buffs.initialAnchor = "TOPLEFT"
		self.Buffs.growthX = "RIGHT"
		self.Buffs.growthY = "DOWN"
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
		local cbW = C["Unitframe"].PlayerCastbarWidth
		local cbH = C["Unitframe"].PlayerCastbarHeight
		Module:CreateUnitCastbar(self, {
			name = "oUF_CastbarPlayer",
			width = cbW,
			height = cbH,
			textSize = 12,
			stageSize = 20,
			decimal = "%.2f",
			timeToHold = 0.5,
			latency = true,
			mover = {
				label = "Player Castbar",
				key = "PlayerCB",
				anchor = { "BOTTOM", UIParent, "BOTTOM", 0, 200 },
				width = cbH + cbW + 3,
				height = cbH + 3,
			},
		})
	end

	-- REASON: Heal Prediction
	if C["Unitframe"].ShowHealPrediction then
		Module:CreateHealPrediction(self)
	end

	-- REASON: Level Tag — center-above detached portrait.
	if C["Unitframe"].ShowPlayerLevel then
		local levelDetached = Module.IsDetachedPortrait(playerPortraitStyle)
		local Level = Module:CreateLevelTagString(self, self.Portrait, {
			tag = "[fulllevel]",
			layout = "centerAbove",
			y = 15,
			show = levelDetached,
		})

		if Level and C["Unitframe"].HideMaxPlayerLevel then
			local function UpdateLevelVisibility(_, _, newLevel)
				local currentLevel = type(newLevel) == "number" and newLevel or UnitLevel("player")
				if IsLevelAtEffectiveMaxLevel(currentLevel) then
					Level:Hide()
				elseif levelDetached then
					Level:Show()
				end
			end

			UpdateLevelVisibility()
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
			Stagger.PostUpdate = Module.PostUpdateStagger
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
		if Module.IsDetachedPortrait(playerPortraitStyle) then
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
	if Module.IsDetachedPortrait(playerPortraitStyle) then
		self.LeaderIndicator:SetPoint("TOPLEFT", self.Portrait, 0, 10)
	else
		self.LeaderIndicator:SetPoint("TOPLEFT", self.Health, 0, 10)
	end
	self.LeaderIndicator.PostUpdate = Module.PostUpdateLeaderIndicator

	self.AssistantIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.AssistantIndicator:SetSize(16, 16)
	if Module.IsDetachedPortrait(playerPortraitStyle) then
		self.AssistantIndicator:SetPoint("TOPLEFT", self.Portrait, 0, 8)
	else
		self.AssistantIndicator:SetPoint("TOPLEFT", self.Health, 0, 8)
	end

	if C["Unitframe"].PvPIndicator then
		self.PvPIndicator = self:CreateTexture(nil, "OVERLAY")
		self.PvPIndicator:SetSize(30, 33)
		if Module.IsDetachedPortrait(playerPortraitStyle) then
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
	if Module.IsDetachedPortrait(playerPortraitStyle) then
		self.RaidTargetIndicator:SetPoint("TOP", self.Portrait, "TOP", 0, 8)
	else
		self.RaidTargetIndicator:SetPoint("TOP", self.Health, "TOP", 0, 8)
	end
	self.RaidTargetIndicator:SetSize(16, 16)

	self.ReadyCheckIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	if Module.IsDetachedPortrait(playerPortraitStyle) then
		self.ReadyCheckIndicator:SetPoint("CENTER", self.Portrait)
	else
		self.ReadyCheckIndicator:SetPoint("CENTER", self.Health)
	end
	self.ReadyCheckIndicator:SetSize(playerHeight - 4, playerHeight - 4)

	self.ResurrectIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.ResurrectIndicator:SetSize(44, 44)
	if Module.IsDetachedPortrait(playerPortraitStyle) then
		self.ResurrectIndicator:SetPoint("CENTER", self.Portrait)
	else
		self.ResurrectIndicator:SetPoint("CENTER", self.Health)
	end

	-- REASON: Resting Indicator (ZZZ animation)
	do
		local RestingIndicator = CreateFrame("Frame", nil, self.Overlay)
		RestingIndicator:SetSize(5, 5)
		if Module.IsDetachedPortrait(playerPortraitStyle) then
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

		local function OnUpdateResting(indicator, elapsed)
			indicator.elapsed = (indicator.elapsed or 0) + elapsed
			if indicator.elapsed > stepSpeed then
				step = step + 1
				if step == 7 then
					step = 1
				end

				for i = 1, 3 do
					texts[i]:SetShown(stepMaps[step][i])
				end

				indicator.elapsed = 0
			end
		end

		RestingIndicator:SetScript("OnUpdate", OnUpdateResting)

		RestingIndicator:SetScript("OnHide", function(indicator)
			step = 6
			-- Clean up OnUpdate script when hidden to save performance
			indicator:SetScript("OnUpdate", nil)
			indicator.elapsed = 0
		end)

		RestingIndicator:SetScript("OnShow", function(indicator)
			-- Restore OnUpdate script when shown
			indicator:SetScript("OnUpdate", OnUpdateResting)
		end)

		self.RestingIndicator = RestingIndicator
	end

	self.QuestSyncIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	if Module.IsDetachedPortrait(playerPortraitStyle) then
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
		Module:CreateDebuffHighlight(self)
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
