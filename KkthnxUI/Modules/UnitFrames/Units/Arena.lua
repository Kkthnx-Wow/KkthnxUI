local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Unitframes")

-- Lua functions
local select = select

-- WoW API
local CreateFrame = CreateFrame

function Module:CreateArena()
	self.mystyle = "arena"

	local arenaWidth = C["Arena"].HealthWidth
	local arenaHeight = C["Arena"].HealthHeight
	local arenaPortraitStyle = C["Unitframe"].PortraitStyle.Value

	local UnitframeTexture = K.GetTexture(C["General"].Texture)
	-- local HealPredictionTexture = K.GetTexture(C["General"].Texture)

	self.Overlay = CreateFrame("Frame", nil, self) -- We will use this to overlay onto our special borders.
	self.Overlay:SetAllPoints()
	self.Overlay:SetFrameLevel(6)

	Module.CreateHeader(self)

	self.Health = CreateFrame("StatusBar", nil, self)
	self.Health:SetHeight(arenaHeight)
	self.Health:SetPoint("TOPLEFT")
	self.Health:SetPoint("TOPRIGHT")
	self.Health:SetStatusBarTexture(UnitframeTexture)
	self.Health:CreateBorder()

	self.Health.colorDisconnected = true
	self.Health.frequentUpdates = true

	if C["Arena"].Smooth then
		K:SmoothBar(self.Health)
	end

	if C["Arena"].HealthbarColor.Value == "Value" then
		self.Health.colorSmooth = true
		self.Health.colorClass = false
		self.Health.colorReaction = false
	elseif C["Arena"].HealthbarColor.Value == "Dark" then
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
	self.Health.Value:SetFont(select(1, self.Health.Value:GetFont()), 10, select(3, self.Health.Value:GetFont()))
	self:Tag(self.Health.Value, "[hp]")

	self.Power = CreateFrame("StatusBar", nil, self)
	self.Power:SetHeight(C["Arena"].PowerHeight)
	self.Power:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 0, -6)
	self.Power:SetPoint("TOPRIGHT", self.Health, "BOTTOMRIGHT", 0, -6)
	self.Power:SetStatusBarTexture(UnitframeTexture)
	self.Power:CreateBorder()

	self.Power.colorPower = true
	self.Power.SetFrequentUpdates = true

	if C["Arena"].Smooth then
		K:SmoothBar(self.Power)
	end

	self.Name = self:CreateFontString(nil, "OVERLAY")
	self.Name:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, 4)
	self.Name:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 0, 4)
	self.Name:SetFontObject(K.UIFont)
	if arenaPortraitStyle == "NoPortraits" or arenaPortraitStyle == "OverlayPortrait" then
		if C["Unitframe"].HealthbarColor.Value == "Class" then
			self:Tag(self.Name, "[name] [nplevel]")
		else
			self:Tag(self.Name, "[color][name] [nplevel]")
		end
	else
		if C["Unitframe"].HealthbarColor.Value == "Class" then
			self:Tag(self.Name, "[name]")
		else
			self:Tag(self.Name, "[color][name]")
		end
	end

	if arenaPortraitStyle ~= "NoPortraits" then
		if arenaPortraitStyle == "OverlayPortrait" then
			self.Portrait = CreateFrame("PlayerModel", "KKUI_ArenaPortrait", self)
			self.Portrait:SetFrameStrata(self:GetFrameStrata())
			self.Portrait:SetPoint("TOPLEFT", self.Health, "TOPLEFT", 1, -1)
			self.Portrait:SetPoint("BOTTOMRIGHT", self.Health, "BOTTOMRIGHT", -1, 1)
			self.Portrait:SetAlpha(0.6)
		elseif arenaPortraitStyle == "ThreeDPortraits" then
			self.Portrait = CreateFrame("PlayerModel", "KKUI_ArenaPortrait", self.Health)
			self.Portrait:SetFrameStrata(self:GetFrameStrata())
			self.Portrait:SetSize(self.Health:GetHeight() + self.Power:GetHeight() + 6, self.Health:GetHeight() + self.Power:GetHeight() + 6)
			self.Portrait:SetPoint("TOPLEFT", self, "TOPRIGHT", 6, 0)
			self.Portrait:CreateBorder()
		elseif arenaPortraitStyle ~= "ThreeDPortraits" and arenaPortraitStyle ~= "OverlayPortrait" then
			self.Portrait = self.Health:CreateTexture("KKUI_ArenaPortrait", "BACKGROUND", nil, 1)
			self.Portrait:SetTexCoord(0.15, 0.85, 0.15, 0.85)
			self.Portrait:SetSize(self.Health:GetHeight() + self.Power:GetHeight() + 6, self.Health:GetHeight() + self.Power:GetHeight() + 6)
			self.Portrait:SetPoint("TOPLEFT", self, "TOPRIGHT", 6, 0)

			self.Portrait.Border = CreateFrame("Frame", nil, self)
			self.Portrait.Border:SetAllPoints(self.Portrait)
			self.Portrait.Border:CreateBorder()

			if arenaPortraitStyle == "ClassPortraits" or arenaPortraitStyle == "NewClassPortraits" then
				self.Portrait.PostUpdate = Module.UpdateClassPortraits
			end
		end
	end

	self.Level = self:CreateFontString(nil, "OVERLAY")
	if arenaPortraitStyle ~= "NoPortraits" and arenaPortraitStyle ~= "OverlayPortrait" then
		self.Level:Show()
		self.Level:SetPoint("BOTTOMLEFT", self.Portrait, "TOPLEFT", 0, 4)
		self.Level:SetPoint("BOTTOMRIGHT", self.Portrait, "TOPRIGHT", 0, 4)
	else
		self.Level:Hide()
	end
	self.Level:SetFontObject(K.UIFont)
	self:Tag(self.Level, "[nplevel]")

	self.Trinket = CreateFrame("Frame", "KKUI_ArenaTrinket", self)
	self.Trinket:SetSize(self.Health:GetHeight() + self.Power:GetHeight() + 6, self.Health:GetHeight() + self.Power:GetHeight() + 6)
	self.Trinket:SetPoint("RIGHT", self, "LEFT", -6, 0)
	self.Trinket:CreateBorder()

	--if C["Arena"].ShowBuffs then
	self.Buffs = CreateFrame("Frame", nil, self)
	self.Buffs:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -6)
	self.Buffs:SetPoint("TOPRIGHT", self.Power, "BOTTOMRIGHT", 0, -6)
	self.Buffs.initialAnchor = "TOPLEFT"
	self.Buffs["growth-x"] = "RIGHT"
	self.Buffs["growth-y"] = "DOWN"
	self.Buffs.num = 6
	self.Buffs.spacing = 6
	self.Buffs.iconsPerRow = 6
	self.Buffs.onlyShowPlayer = false

	Module:UpdateAuraContainer(arenaWidth, self.Buffs, self.Buffs.num)

	self.Buffs.showStealableBuffs = true
	self.Buffs.PostCreateButton = Module.PostCreateButton
	self.Buffs.PostUpdateButton = Module.PostUpdateButton
	--end

	self.Debuffs = CreateFrame("Frame", self:GetName() .. "Debuffs", self)
	self.Debuffs.spacing = 6
	self.Debuffs.initialAnchor = "TOPRIGHT"
	self.Debuffs["growth-x"] = "LEFT"
	self.Debuffs["growth-y"] = "DOWN"
	self.Debuffs:SetPoint("TOPRIGHT", self.Trinket, "TOPLEFT", -6, 0)
	self.Debuffs.num = 2
	self.Debuffs.iconsPerRow = 4

	Module:UpdateAuraContainer(arenaWidth, self.Debuffs, self.Debuffs.num)

	self.Debuffs.PostCreateButton = Module.PostCreateButton
	self.Debuffs.PostUpdateButton = Module.PostUpdateButton

	if C["Arena"].Castbars then
		self.Castbar = CreateFrame("StatusBar", "ArenaCastbar", self)
		self.Castbar:SetStatusBarTexture(UnitframeTexture)
		self.Castbar:SetClampedToScreen(true)
		self.Castbar:CreateBorder()

		self.Castbar:ClearAllPoints()
		if arenaPortraitStyle == "NoPortraits" or arenaPortraitStyle == "OverlayPortrait" then
			self.Castbar:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", C["Arena"].CastbarIcon and 24, 6)
			self.Castbar:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", 0, 6)
		else
			self.Castbar:SetPoint("BOTTOMRIGHT", self.Portrait, "TOPRIGHT", 0, 6)
			self.Castbar:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", C["Arena"].CastbarIcon and 24, 6)
		end
		self.Castbar:SetHeight(18)

		self.Castbar.Spark = self.Castbar:CreateTexture(nil, "OVERLAY")
		self.Castbar.Spark:SetTexture(C["Media"].Textures.Spark128Texture)
		self.Castbar.Spark:SetSize(128, self.Castbar:GetHeight())
		self.Castbar.Spark:SetBlendMode("ADD")

		self.Castbar.Time = self.Castbar:CreateFontString(nil, "OVERLAY")
		self.Castbar.Time:SetFontObject(K.UIFont)
		self.Castbar.Time:SetFont(select(1, self.Castbar.Time:GetFont()), 11, select(3, self.Castbar.Time:GetFont()))
		self.Castbar.Time:SetPoint("RIGHT", -3.5, 0)
		self.Castbar.Time:SetTextColor(0.84, 0.75, 0.65)
		self.Castbar.Time:SetJustifyH("RIGHT")

		self.Castbar.decimal = "%.2f"

		self.Castbar.OnUpdate = Module.OnCastbarUpdate
		self.Castbar.PostCastStart = Module.PostCastStart
		self.Castbar.PostCastStop = Module.PostCastStop
		self.Castbar.PostCastFail = Module.PostCastFailed
		self.Castbar.PostCastInterruptible = Module.PostUpdateInterruptible
		-- self.Castbar.UpdatePips = K.Noop -- use my own code

		self.Castbar.Text = self.Castbar:CreateFontString(nil, "OVERLAY")
		self.Castbar.Text:SetFontObject(K.UIFont)
		self.Castbar.Text:SetFont(select(1, self.Castbar.Text:GetFont()), 11, select(3, self.Castbar.Text:GetFont()))
		self.Castbar.Text:SetPoint("LEFT", 3.5, 0)
		self.Castbar.Text:SetPoint("RIGHT", self.Castbar.Time, "LEFT", -3.5, 0)
		self.Castbar.Text:SetTextColor(0.84, 0.75, 0.65)
		self.Castbar.Text:SetJustifyH("LEFT")
		self.Castbar.Text:SetWordWrap(false)

		if C["Arena"].CastbarIcon then
			self.Castbar.Button = CreateFrame("Frame", nil, self.Castbar)
			self.Castbar.Button:SetSize(16, 16)
			self.Castbar.Button:CreateBorder()

			self.Castbar.Icon = self.Castbar.Button:CreateTexture(nil, "ARTWORK")
			self.Castbar.Icon:SetSize(self.Castbar:GetHeight(), self.Castbar:GetHeight())
			self.Castbar.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
			self.Castbar.Icon:SetPoint("RIGHT", self.Castbar, "LEFT", -6, 0)

			self.Castbar.Button:SetAllPoints(self.Castbar.Icon)
		end
	end

	if C["Arena"].TargetHighlight then
		self.TargetHighlight = CreateFrame("Frame", nil, self.Overlay, "BackdropTemplate")
		self.TargetHighlight:SetBackdrop({ edgeFile = C["Media"].Borders.GlowBorder, edgeSize = 12 })

		local relativeTo
		if arenaPortraitStyle == "NoPortraits" or arenaPortraitStyle == "OverlayPortrait" then
			relativeTo = self.Health
		else
			relativeTo = self.Portrait
		end

		self.TargetHighlight:SetPoint("TOPLEFT", relativeTo, -5, 5)
		self.TargetHighlight:SetPoint("BOTTOMRIGHT", relativeTo, 5, -5)
		self.TargetHighlight:SetBackdropBorderColor(1, 1, 0)
		self.TargetHighlight:Hide()

		local function UpdateArenaTargetGlow()
			if UnitIsUnit("target", self.unit) then
				self.TargetHighlight:Show()
			else
				self.TargetHighlight:Hide()
			end
		end

		self:RegisterEvent("PLAYER_TARGET_CHANGED", UpdateArenaTargetGlow, true)
	end

	self.RaidTargetIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	if arenaPortraitStyle ~= "NoPortraits" and arenaPortraitStyle ~= "OverlayPortrait" then
		self.RaidTargetIndicator:SetPoint("TOP", self.Portrait, "TOP", 0, 8)
	else
		self.RaidTargetIndicator:SetPoint("TOP", self.Health, "TOP", 0, 8)
	end
	self.RaidTargetIndicator:SetSize(14, 14)

	self.ResurrectIndicator = self.Overlay:CreateTexture(nil, "OVERLAY")
	self.ResurrectIndicator:SetSize(28, 28)
	if arenaPortraitStyle ~= "NoPortraits" and arenaPortraitStyle ~= "OverlayPortrait" then
		self.ResurrectIndicator:SetPoint("CENTER", self.Portrait)
	else
		self.ResurrectIndicator:SetPoint("CENTER", self.Health)
	end

	self.Highlight = self.Health:CreateTexture(nil, "OVERLAY")
	self.Highlight:SetAllPoints()
	self.Highlight:SetTexture("Interface\\PETBATTLES\\PetBattle-SelectedPetGlow")
	self.Highlight:SetTexCoord(0, 1, 0.5, 1)
	self.Highlight:SetVertexColor(0.6, 0.6, 0.6)
	self.Highlight:SetBlendMode("ADD")
	self.Highlight:Hide()

	local altPower = K.CreateFontString(self, 10, "")
	altPower:SetPoint("RIGHT", self.Power, "LEFT", -6, 0)
	self:Tag(altPower, "[altpower]")

	self.Range = {
		Override = Module.UpdateRange,
	}
end
