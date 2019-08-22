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

local function PostUpdateAddPower(element, _, cur, max)
	if element.Text and max > 0 then
		local perc = cur / max * 100
		if perc == 100 then
			perc = ""
			element:SetAlpha(0)
		else
			perc = string.format("%d%%", perc)
			element:SetAlpha(1)
		end

		element.Text:SetText(perc)
	end
end

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
	self.Health.colorClass = true
	self.Health.colorReaction = true
	self.Health.frequentUpdates = true

	K.SmoothBar(self.Health)

	self.Health.Value = self.Health:CreateFontString(nil, "OVERLAY")
	self.Health.Value:SetFontObject(UnitframeFont)
	self.Health.Value:SetPoint("CENTER", self.Health, "CENTER", 0, 0)
	self:Tag(self.Health.Value, C["Unitframe"].PlayerHealthFormat.Value)

	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetHeight(14)
	self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -6)
	self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -6)
	self.Power:SetStatusBarTexture(UnitframeTexture)
	self.Power:CreateBorder()

	self.Power.colorPower = true
	self.Power.frequentUpdates = true

	K.SmoothBar(self.Power)

	self.Power.Value = self.Power:CreateFontString(nil, "OVERLAY")
	self.Power.Value:SetPoint("CENTER", self.Power, "CENTER", 0, 0)
	self.Power.Value:SetFontObject(UnitframeFont)
	self.Power.Value:SetFont(select(1, self.Power.Value:GetFont()), 11, select(3, self.Power.Value:GetFont()))
	self:Tag(self.Power.Value, "[KkthnxUI:PowerCurrent]")

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

	if C["Unitframe"].PlayerBuffs then
		self.Buffs = CreateFrame("Frame", self:GetName().."Buffs", self)

		if K.Class == "ROGUE"
		or K.Class == "DRUID"
		or K.Class == "MAGE"
		or K.Class == "MONK"
		or K.Class == "DEATHKNIGHT"
		or K.Class == "SHAMAN"
		or K.Class == "PALADIN"
		or K.Class == "WARLOCK" then
			self.Buffs:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -26)
		else
			self.Buffs:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -6)
		end
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
		--self.Buffs.CustomFilter = Module.AurasFilter.BlackList
	end

	if (C["Unitframe"].Castbars) then
		self.Castbar = CreateFrame("StatusBar", "PlayerCastbar", self)
		self.Castbar:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 266)
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
		self.Castbar.PostCastFailed = Module.PostCastFailed
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

		K.Mover(self.Castbar, "PlayerCastBar", "PlayerCastBar", {"BOTTOM", UIParent, "BOTTOM", 0, 266})
	end

	-- HealPredictionAndAbsorb
	do
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
		oag:SetAlpha(.7)
		oag:SetPoint("TOPLEFT", self.Health, "TOPRIGHT", -5, 2)
		oag:SetPoint("BOTTOMLEFT", self.Health, "BOTTOMRIGHT", -5, -2)

		local hab = CreateFrame("StatusBar", nil, self.Health)
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

	if C["Unitframe"].ShowPlayerName then
		self.Name = self:CreateFontString(nil, "OVERLAY")
		self.Name:SetPoint("TOP", self.Health, 0, 16)
		self.Name:SetWidth(self.Health:GetWidth())
		self.Name:SetFontObject(UnitframeFont)
		self:Tag(self.Name, "[KkthnxUI:DifficultyColor][KkthnxUI:NameMedium]")
	end

	-- Level
	if C["Unitframe"].ShowPlayerLevel and K.Level ~= _G.MAX_PLAYER_LEVEL then
		self.Level = self:CreateFontString(nil, "OVERLAY")
		self.Level:SetPoint("TOP", self.Portrait, 0, 15)
		self.Level:SetFontObject(UnitframeFont)
		self:Tag(self.Level, "[KkthnxUI:DifficultyColor][level]")
	end

	if C["Raid"].ShowGroupText then
		self.GroupNumber = self.Overlay:CreateFontString(nil, "OVERLAY")
		self.GroupNumber:SetPoint("BOTTOM", self.Portrait, 0, 0)
		self.GroupNumber:SetFontObject(UnitframeFont)
		self.GroupNumber:SetFont(select(1, self.GroupNumber:GetFont()), 11, select(3, self.GroupNumber:GetFont()))
		self:Tag(self.GroupNumber, "[KkthnxUI:GetNameColor][KkthnxUI:GroupNumber]")
	end

	if C["Unitframe"].AdditionalPower then
		if K.Class == "DRUID" or K.Class == "PRIEST" or K.Class == "SHAMAN" then
			self.AdditionalPower = CreateFrame("StatusBar", nil, self)
			self.AdditionalPower:SetHeight(14)
			self.AdditionalPower:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, 6)
			self.AdditionalPower:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 0, 6)
			self.AdditionalPower:SetStatusBarTexture(K.GetTexture(C["UITextures"].UnitframeTextures))
			self.AdditionalPower:SetStatusBarColor(unpack(K.Colors.power["MANA"]))
			self.AdditionalPower:CreateBorder()
			self.AdditionalPower.frequentUpdates = true

			K.SmoothBar(self.AdditionalPower)

			self.AdditionalPower.Text = self.AdditionalPower:CreateFontString(nil, "OVERLAY")
			self.AdditionalPower.Text:SetFontObject(K.GetFont(C["UIFonts"].UnitframeFonts))
			self.AdditionalPower.Text:SetPoint("CENTER", self.AdditionalPower, "CENTER", 0, 0)

			self.AdditionalPower.PostUpdate = PostUpdateAddPower
		end
	end

	self.LeaderIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.LeaderIndicator:SetSize(14, 14)
	self.LeaderIndicator:SetPoint("TOPLEFT", self.Overlay, "TOPLEFT", 0, 8)

	-- Class Power (Combo Points, etc...)
	if C["Unitframe"].ClassResource then
		Module.CreateClassPower(self)
		if (K.Class == "MONK") then
			Module.CreateStaggerBar(self)
		elseif (K.Class == "DEATHKNIGHT") then
			Module.CreateRuneBar(self)
		end
	end

	if C["Unitframe"].CombatText then
		local parentFrame = CreateFrame("Frame", nil, UIParent)
		self.FloatingCombatFeedback = CreateFrame("Frame", "oUF_CombatTextFrame", parentFrame)
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

		-- Default CombatText
		if not _G.InCombatLockdown() then _G.SetCVar("enableFloatingCombatText", 0) end
		K.HideInterfaceOption(_G.InterfaceOptionsCombatPanelEnableFloatingCombatText)
	end

	if C["Unitframe"].Swingbar then
		self.Swing = CreateFrame("StatusBar", nil, self)
		self.Swing:SetSize(250, 5)
		self.Swing:SetPoint("TOP", self.Castbar, "BOTTOM", -16, -5)

		self.Swing.Twohand = CreateFrame("StatusBar", nil, self.Swing)
		self.Swing.Twohand:SetStatusBarTexture(UnitframeTexture)
		self.Swing.Twohand:SetStatusBarColor(.8, .8, .8)
		self.Swing.Twohand:CreateShadow(true)
		self.Swing.Twohand:Hide()
		self.Swing.Twohand:SetAllPoints()

		self.Swing.Mainhand = CreateFrame("StatusBar", nil, self.Swing)
		self.Swing.Mainhand:SetStatusBarTexture(UnitframeTexture)
		self.Swing.Mainhand:SetStatusBarColor(.8, .8, .8)
		self.Swing.Mainhand:CreateShadow(true)
		self.Swing.Mainhand:Hide()
		self.Swing.Mainhand:SetAllPoints()

		self.Swing.Offhand = CreateFrame("StatusBar", nil, self.Swing)
		self.Swing.Offhand:SetStatusBarTexture(UnitframeTexture)
		self.Swing.Offhand:SetStatusBarColor(.8, .8, .8)
		self.Swing.Offhand:CreateShadow(true)
		self.Swing.Offhand:Hide()
		self.Swing.Offhand:SetPoint("TOPLEFT", self.Swing, "BOTTOMLEFT", 0, -3)
		self.Swing.Offhand:SetPoint("BOTTOMRIGHT", self.Swing, "BOTTOMRIGHT", 0, -6)

		if C["Unitframe"].SwingbarTimer then
			self.Swing.Text = self.Swing:CreateFontString(nil, "OVERLAY")
			self.Swing.Text:SetFontObject(K.GetFont(C["UIFonts"].UnitframeFonts))
			self.Swing.Text:SetPoint("CENTER", 1, 0)
			self.Swing.Text:SetWordWrap(false)

			self.Swing.TextMH = self.Swing.Mainhand:CreateFontString(nil, "OVERLAY")
			self.Swing.TextMH:SetFontObject(K.GetFont(C["UIFonts"].UnitframeFonts))
			self.Swing.TextMH:SetPoint("CENTER", 1, 0)
			self.Swing.Text:SetWordWrap(false)

			self.Swing.TextOH = self.Swing.Offhand:CreateFontString(nil, "OVERLAY")
			self.Swing.TextOH:SetFontObject(K.GetFont(C["UIFonts"].UnitframeFonts))
			self.Swing.TextOH:SetPoint("CENTER", 1, 0)
			self.Swing.Text:SetWordWrap(false)
		end
		self.Swing.hideOoc = true
	end

	self.PvPIndicator = self:CreateTexture(nil, "OVERLAY")
	self.PvPIndicator:SetSize(30, 33)
	self.PvPIndicator:SetPoint("RIGHT", self.Portrait, "LEFT", -2, 0)
	self.PvPIndicator.PostUpdate = Module.PostUpdatePvPIndicator

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

	self.PortraitTimer = CreateFrame("Frame", "$parentPortraitTimer", self.Health)
	self.PortraitTimer:CreateInnerShadow()
	self.PortraitTimer:SetFrameLevel(5) -- Watch me
	self.PortraitTimer:SetInside(self.Portrait, 1, 1)

	self.GlobalCooldown = CreateFrame("Frame", nil, self.Health)
	self.GlobalCooldown:SetWidth(156)
	self.GlobalCooldown:SetHeight(28)
	self.GlobalCooldown:SetFrameStrata("HIGH")
	self.GlobalCooldown:SetPoint("LEFT", self.Health, "LEFT", 0, 0)

	self.Highlight = self.Health:CreateTexture(nil, "OVERLAY")
	self.Highlight:SetAllPoints()
	self.Highlight:SetTexture("Interface\\PETBATTLES\\PetBattle-SelectedPetGlow")
	self.Highlight:SetTexCoord(0, 1, .5, 1)
	self.Highlight:SetVertexColor(.6, .6, .6)
	self.Highlight:SetBlendMode("ADD")
	self.Highlight:Hide()

	self.LootSpecIndicator = self.Overlay:CreateTexture("$parentSpecIcon")
	self.LootSpecIndicator:SetTexCoord(unpack(K.TexCoords))
    self.LootSpecIndicator:SetSize(16, 16)
    self.LootSpecIndicator:SetPoint("TOPRIGHT", self.Portrait, 10, 4)

	self.LootSpecIndicator.Border = CreateFrame("Frame", nil, self.Overlay)
	self.LootSpecIndicator.Border:SetAllPoints(self.LootSpecIndicator)
	K.CreateBorder(self.LootSpecIndicator.Border)

	self.ThreatIndicator = {
		IsObjectType = function() end,
		Override = Module.UpdateThreat,
	}

	self.CombatFade = C["Unitframe"].CombatFade
end