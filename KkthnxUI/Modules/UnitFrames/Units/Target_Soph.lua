local K, C = unpack(select(2, ...))
if C["Unitframe"].Enable ~= true then
	return
end

local Module = K:GetModule("Unitframes")
local oUF = oUF or K.oUF

if not oUF then
	K.Print("Could not find a vaild instance of oUF. Stopping Target.lua code!")
	return
end

local _G = _G
local select = select

local CreateFrame = _G.CreateFrame

function Module:PostUpdatePvPIndicator(unit, status)
	local factionGroup = UnitFactionGroup(unit)

	if UnitIsPVPFreeForAll(unit) and status == "ffa" then
		self:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA")
		self:SetTexCoord(0, 0.65625, 0, 0.65625)
	elseif factionGroup and UnitIsPVP(unit) and status ~= nil then
		self:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\ObjectiveWidget")

		if factionGroup == "Alliance" then
			self:SetTexCoord(0.00390625, 0.136719, 0.511719, 0.671875)
		else
			self:SetTexCoord(0.00390625, 0.136719, 0.679688, 0.839844)
		end
	end
end

function Module:CreateTargetSoph(unit)
	self.mystyle = "target"

	local UnitframeFont = K.GetFont(C["UIFonts"].UnitframeFonts)
	local UnitframeTexture = "Interface\\AddOns\\AzeriteUI\\media\\hp_cap_bar.tga" -- K.GetTexture(C["UITextures"].UnitframeTextures)
	local HealPredictionTexture = K.GetTexture(C["UITextures"].HealPredictionTextures)

	self.Overlay = CreateFrame("Frame", nil, self) -- We will use this to overlay onto our special borders.
	self.Overlay:SetAllPoints()
	self.Overlay:SetFrameLevel(5)

	Module.CreateHeader(self)

	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetHeight(46)
	self.Health:SetPoint("TOPLEFT")
	self.Health:SetPoint("TOPRIGHT")
	self.Health:SetStatusBarTexture(UnitframeTexture)
	self.Health:SetReverseFill(true)
	--self.Health:SetRotation(60)
	--self.Health:CreateBorder()

	self.Health.PostUpdate = C["Unitframe"].PortraitStyle.Value ~= "ThreeDPortraits" and Module.UpdateHealth
	self.Health.colorTapping = true
	self.Health.colorDisconnected = true
	self.Health.frequentUpdates = true

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

	if C["Unitframe"].Smooth then
		K:SmoothBar(self.Health)
	end

	self.Health.Value = self.Health:CreateFontString(nil, "OVERLAY")
	self.Health.Value:SetPoint("LEFT", self.Health, "LEFT", 8, 4)
	self.Health.Value:SetFontObject(UnitframeFont)
	self.Health.Value:SetFont(select(1, self.Health.Value:GetFont()), 12, "OUTLINE")
	self.Health.Value:SetShadowOffset(0, 0)
	self.Health.Value:SetAlpha(0.6)
	self:Tag(self.Health.Value, "[hp]")

	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetSize(60, 13)
	self.Power:SetPoint("TOP", self.Health, "BOTTOM", -18, 6)
	self.Power:SetStatusBarTexture("Interface\\AddOns\\AzeriteUI\\media\\cast_bar.tga")
	--self.Power:CreateBorder()

	self.Power.colorPower = true
	self.Power.frequentUpdates = true

	if C["Unitframe"].Smooth then
		K:SmoothBar(self.Power)
	end

	self.Power.Value = self.Power:CreateFontString(nil, "OVERLAY")
	self.Power.Value:SetPoint("CENTER", self.Power, "CENTER", 0, 0)
	self.Power.Value:SetFontObject(UnitframeFont)
	self.Power.Value:SetFont(select(1, self.Power.Value:GetFont()), 12, "OUTLINE")
	self.Power.Value:SetShadowOffset(0, 0)
	self.Power.Value:SetAlpha(0.6)
	self:Tag(self.Power.Value, "[power]")

	self.Name = self:CreateFontString(nil, "OVERLAY")
	self.Name:SetPoint("TOPRIGHT", self.Health, 40, 16)
	self.Name:SetWidth(156 * 0.90)
	self.Name:SetFontObject(UnitframeFont)
	self.Name:SetWordWrap(false)
	self.Name:SetFont(select(1, self.Name:GetFont()), 12, "OUTLINE")
	self.Name:SetShadowOffset(0, 0)
	self.Name:SetAlpha(0.7)
	if C["Unitframe"].HealthbarColor.Value == "Class" then
		self:Tag(self.Name, "[name][afkdnd]")
	else
		self:Tag(self.Name, "[color][name][afkdnd]")
	end

	if C["Unitframe"].PortraitStyle.Value == "ThreeDPortraits" then
		self.Portrait = CreateFrame("PlayerModel", nil, self.Health)
		--self.Portrait:SetFrameStrata(self:GetFrameStrata())
		self.Portrait:SetSize(self.Health:GetHeight() + self.Power:GetHeight() + 6, self.Health:GetHeight() + self.Power:GetHeight() + 6)
		self.Portrait:SetPoint("TOPRIGHT", self, "TOPRIGHT", 4, 18)
		--self.Portrait:SetTexture("Interface\\AddOns\\AzeriteUI\\media\\portrait_frame_hi.tga")

			local mask = self.Portrait:CreateMaskTexture()
            mask:SetTexture("Interface\\AddOns\\AzeriteUI\\media\\portrait_frame_hi.tga", "CLAMPTOBLACKADDITIVE", "CLAMPTOBLACKADDITIVE")
            mask:SetAllPoints(self.Portrait)

            self.Portrait.Icon = self.Portrait:CreateTexture(nil, "BACKGROUND")
            self.Portrait.Icon:SetAllPoints(self.Portrait)
            self.Portrait.Icon:SetTexCoord(0.07, 0.93, 0.07, 0.93)
            self.Portrait.Icon:AddMaskTexture(mask)

		self.Portrait.Border = self.Portrait:CreateTexture("BorderApply", "OVERLAY", nil, 1)
		self.Portrait.Border:SetTexture("Interface\\AddOns\\AzeriteUI\\media\\portrait_frame_hi.tga")
		self.Portrait.Border:SetPoint("TOPLEFT", -20, 20)
		self.Portrait.Border:SetPoint("BOTTOMRIGHT", 20, -20)
		self.Portrait.Border:SetSize(120, 120)
		--self.Portrait:CreateBorder()
		--self.Portrait:CreateInnerShadow()
	elseif C["Unitframe"].PortraitStyle.Value ~= "ThreeDPortraits" then
		self.Portrait = self.Health:CreateTexture("TargetPortrait", "BACKGROUND", nil, 1)
		--self.Portrait:SetTexCoord(0.15, 0.85, 0.15, 0.85)
		self.Portrait:SetSize(self.Health:GetHeight() + self.Power:GetHeight() + 6, self.Health:GetHeight() + self.Power:GetHeight() + 6)
		self.Portrait:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0)
		self.Portrait:SetTexCoord(0.07, 0.93, 0.07, 0.93)

		self.Portrait.Border = self.Overlay:CreateTexture("BorderApply", "OVERLAY", nil, 7)
		self.Portrait.Border:SetTexture("Interface\\AddOns\\AzeriteUI\\media\\portrait_frame_hi.tga")
		self.Portrait.Border:SetPoint("TOPLEFT", self.Portrait, -32, 32)
		self.Portrait.Border:SetPoint("BOTTOMRIGHT", self.Portrait, 32, -32)
		--self.Portrait.Border:SetSize(150, 150)

		if (C["Unitframe"].PortraitStyle.Value == "ClassPortraits" or C["Unitframe"].PortraitStyle.Value == "NewClassPortraits") then
			self.Portrait.PostUpdate = Module.UpdateClassPortraits
		end
	end

	self.Health:ClearAllPoints()
	self.Health:SetPoint("TOPLEFT")
	self.Health:SetPoint("TOPRIGHT", -self.Portrait:GetWidth() - 6, 0)

	if C["Unitframe"].TargetDebuffs then
		local width = 156

		self.Debuffs = CreateFrame("Frame", self:GetName().."Debuffs", self)
		self.Debuffs.spacing = 6
		self.Debuffs.initialAnchor = "TOPLEFT"
		self.Debuffs["growth-x"] = "RIGHT"
		self.Debuffs["growth-y"] = "UP"
		self.Debuffs:SetPoint("TOPLEFT", self.Health, 0, 46)
		self.Debuffs.num = 6
		self.Debuffs.iconsPerRow = 5
		self.Debuffs.size = Module.auraIconSize(width, self.Debuffs.iconsPerRow, self.Debuffs.spacing)
		self.Debuffs:SetWidth(width)
		self.Debuffs:SetHeight((self.Debuffs.size + self.Debuffs.spacing) * math.floor(self.Debuffs.num/self.Debuffs.iconsPerRow + .5))
		self.Debuffs.onlyShowPlayer = C["Unitframe"].OnlyShowPlayerDebuff
		self.Debuffs.PostCreateIcon = Module.PostCreateAura
		self.Debuffs.PostUpdateIcon = Module.PostUpdateAura
	end

	if C["Unitframe"].TargetBuffs then
		local width = 156

		self.Buffs = CreateFrame("Frame", self:GetName().."Buffs", self)
		self.Buffs:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -6)
		self.Buffs.initialAnchor = "TOPLEFT"
		self.Buffs["growth-x"] = "RIGHT"
		self.Buffs["growth-y"] = "DOWN"
		self.Buffs.num = 6
		self.Buffs.spacing = 6
		self.Buffs.iconsPerRow = 6
		self.Buffs.onlyShowPlayer = false
		self.Buffs.size = Module.auraIconSize(width, self.Buffs.iconsPerRow, self.Buffs.spacing)
		self.Buffs:SetWidth(width)
		self.Buffs:SetHeight((self.Buffs.size + self.Buffs.spacing) * math.floor(self.Buffs.num/self.Buffs.iconsPerRow + .5))
		self.Buffs.showStealableBuffs = true
		self.Buffs.PostCreateIcon = Module.PostCreateAura
		self.Buffs.PostUpdateIcon = Module.PostUpdateAura
	end

	if (C["Unitframe"].Castbars) then
		self.Castbar = CreateFrame("StatusBar", "TargetCastbar", self)
		self.Castbar:SetPoint("BOTTOM", UIParent, "BOTTOM", 14, 335)
		self.Castbar:SetStatusBarTexture(UnitframeTexture)
		self.Castbar:SetSize(C["Unitframe"].TargetCastbarWidth, C["Unitframe"].TargetCastbarHeight)
		self.Castbar:SetClampedToScreen(true)
		self.Castbar:CreateBorder()

		self.Castbar.Spark = self.Castbar:CreateTexture(nil, "OVERLAY")
		self.Castbar.Spark:SetTexture(C["Media"].Spark_128)
		self.Castbar.Spark:SetSize(64, self.Castbar:GetHeight())
		self.Castbar.Spark:SetBlendMode("ADD")

		self.ShieldOverlay = CreateFrame("Frame", nil, self.Castbar) -- We will use this to overlay onto our special borders.
		self.ShieldOverlay:SetAllPoints()
		self.ShieldOverlay:SetFrameLevel(5)

		self.Castbar.Shield = self.ShieldOverlay:CreateTexture(nil, "OVERLAY")
		self.Castbar.Shield:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\CastBorderShield")
		self.Castbar.Shield:SetTexCoord(0, 0.84375, 0, 1)
		self.Castbar.Shield:SetSize(C["Unitframe"].TargetCastbarHeight * 0.84375, C["Unitframe"].TargetCastbarHeight)
		self.Castbar.Shield:SetPoint("CENTER", 0, -14)
		self.Castbar.Shield:SetVertexColor(0.5, 0.5, 0.7)

		self.Castbar.Time = self.Castbar:CreateFontString(nil, "OVERLAY", UnitframeFont)
		self.Castbar.Time:SetPoint("RIGHT", -3.5, 0)
		self.Castbar.Time:SetTextColor(0.84, 0.75, 0.65)
		self.Castbar.Time:SetJustifyH("RIGHT")

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
		self.Castbar.Icon:SetSize(C["Unitframe"].TargetCastbarHeight, C["Unitframe"].TargetCastbarHeight)
		self.Castbar.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		self.Castbar.Icon:SetPoint("BOTTOMRIGHT", self.Castbar, "BOTTOMLEFT", -6, 0)

		self.Castbar.Button:SetAllPoints(self.Castbar.Icon)

		K.Mover(self.Castbar, "TargetCastBar", "TargetCastBar", {"BOTTOM", UIParent, "BOTTOM", 14, 335})
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

	-- Level
	self.Level = self.Overlay:CreateFontString(nil, "OVERLAY")
	self.Level:SetPoint("BOTTOMRIGHT", self.Portrait, 16, 0)
	self.Level:SetFontObject(UnitframeFont)
	self:Tag(self.Level, "[fulllevel]")

	if C["Unitframe"].CombatText then
		local parentFrame = CreateFrame("Frame", nil, UIParent)
		self.FloatingCombatFeedback = CreateFrame("Frame", "oUF_Target_CombatTextFrame", parentFrame)
		self.FloatingCombatFeedback:SetSize(32, 32)
		K.Mover(self.FloatingCombatFeedback, "CombatText", "TargetCombatText", {"BOTTOM", self, "TOPRIGHT", 0, 120})

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

	if C["Unitframe"].PortraitTimers then
		self.PortraitTimer = CreateFrame("Frame", "$parentPortraitTimer", self.Health)
		self.PortraitTimer:CreateInnerShadow()
		self.PortraitTimer:SetFrameLevel(5) -- Watch me
		self.PortraitTimer:SetPoint("TOPLEFT", self.Portrait, "TOPLEFT", 1, -1)
		self.PortraitTimer:SetPoint("BOTTOMRIGHT", self.Portrait, "BOTTOMRIGHT", -1, 1)
		self.PortraitTimer:Hide()
	end

	if C["Unitframe"].PvPIndicator then
		self.PvPIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
		self.PvPIndicator:SetSize(30, 33)
		self.PvPIndicator:SetPoint("TOP", self.Portrait, "BOTTOM", 2, 6)
		self.PvPIndicator.PostUpdate = PostUpdatePvPIndicator
	end

	self.RaidTargetIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.RaidTargetIndicator:SetPoint("TOP", self.Portrait, "TOP", 0, 8)
	self.RaidTargetIndicator:SetSize(16, 16)

	self.ReadyCheckIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.ReadyCheckIndicator:SetPoint("CENTER", self.Portrait)
	self.ReadyCheckIndicator:SetSize(self.Portrait:GetWidth() - 4, self.Portrait:GetHeight() - 4)

	self.ResurrectIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.ResurrectIndicator:SetSize(44, 44)
	self.ResurrectIndicator:SetPoint("CENTER", self.Portrait)

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

	self.Range = Module.CreateRangeIndicator(self)
end