local K, C = unpack(select(2, ...))

local _G = _G
local unpack = _G.unpack
local pairs = _G.pairs
local table_insert = _G.table.insert

local hooksecurefunc = _G.hooksecurefunc

table_insert(C.defaultThemes, function()
	local r, g, b = K.r, K.g, K.b

	-- Head Frame
	local frame = PetBattleFrame
	frame:StripTextures()
	frame.TopVersusText:SetPoint("TOP", 0, -45)

	-- Weather
	local weather = frame.WeatherFrame
	weather:ClearAllPoints()
	weather:SetPoint("TOP", frame.TopVersusText, "BOTTOM", 0, -15)
	weather.Label:Hide()
	weather.Name:Hide()
	weather.Icon:ClearAllPoints()
	weather.Icon:SetPoint("TOP", frame.TopVersusText, "BOTTOM", 0, -15)
	weather.Icon:SetTexCoord(unpack(K.TexCoords))
	weather.Icon.bg = CreateFrame("Frame", nil, weather)
	weather.Icon.bg:SetAllPoints(weather.Icon)
	weather.Icon.bg:SetFrameLevel(weather:GetFrameLevel())
	weather.Icon.bg:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true)
	weather.BackgroundArt:SetPoint("TOP", UIParent)
	weather.Duration:ClearAllPoints()
	weather.Duration:SetPoint("CENTER", weather.Icon, 1, 0)

	-- Current Pets
	local units = {frame.ActiveAlly, frame.ActiveEnemy}
	for index, unit in pairs(units) do
		unit.HealthBarBG:Hide()
		unit.HealthBarFrame:Hide()
		unit.healthBarWidth = 250
		unit.ActualHealthBar:SetTexture(C["Media"].Texture)

		unit.healthBg = CreateFrame("Frame", nil, unit)
		unit.healthBg:SetFrameLevel(unit:GetFrameLevel())
		unit.healthBg:CreateBorder()
		unit.healthBg:ClearAllPoints()
		unit.healthBg:SetWidth(252)

		unit.HealthText:ClearAllPoints()
		unit.HealthText:SetPoint("CENTER", unit.healthBg)

		unit.petIcon = unit:CreateTexture(nil, "ARTWORK")
		unit.petIcon:SetSize(25, 25)

		unit.petIcon:SetTexCoord(unpack(K.TexCoords))
		unit.petIcon.bg = CreateFrame("Frame", nil, unit)
		unit.petIcon.bg:SetAllPoints(unit.petIcon)
		unit.petIcon.bg:SetFrameLevel(unit:GetFrameLevel())
		unit.petIcon.bg:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true)

		unit.PetType:SetAlpha(0)
		unit.PetType:ClearAllPoints()
		unit.PetType:SetAllPoints(unit.petIcon)
		unit.Name:ClearAllPoints()

		unit.Border:SetAlpha(0)
		unit.Border2:SetAlpha(0)
		unit.BorderFlash:SetAlpha(0)

		unit.Iconbg = CreateFrame("Frame", nil, unit)
		unit.Iconbg:SetAllPoints(unit.Icon)
		unit.Iconbg:SetFrameLevel(unit:GetFrameLevel())
		unit.Iconbg:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true)

		unit.LevelUnderlay:SetAlpha(0)
		unit.Level:SetFontObject(SystemFont_Shadow_Huge1)
		unit.Level:ClearAllPoints()
		if unit.SpeedIcon then
			unit.SpeedUnderlay:SetAlpha(0)
			unit.SpeedIcon:SetSize(30, 30)
			unit.SpeedIcon:ClearAllPoints()
		end

		if index == 1 then
			unit.ActualHealthBar:SetPoint("BOTTOMLEFT", unit.Icon, "BOTTOMRIGHT", 0, 0)
			unit.healthBg:SetPoint("TOPLEFT", unit.ActualHealthBar, -1, 1)
			unit.healthBg:SetPoint("BOTTOMLEFT", unit.ActualHealthBar, -1, -1)
			unit.ActualHealthBar:SetGradient("HORIZONTAL", .26, 1, .22, .13, .5, .11)
			unit.petIcon:SetPoint("BOTTOMLEFT", unit.ActualHealthBar, "TOPLEFT", 0, 8)
			unit.Name:SetPoint("LEFT", unit.petIcon, "RIGHT", 5, 0)
			unit.Level:SetPoint("BOTTOMLEFT", unit.Icon, 2, 2)
			if unit.SpeedIcon then
				unit.SpeedIcon:SetPoint("LEFT", unit.healthBg, "RIGHT", 5, 0)
				unit.SpeedIcon:SetTexCoord(0, .5, .5, 1)
			end
		else
			unit.ActualHealthBar:SetPoint("BOTTOMRIGHT", unit.Icon, "BOTTOMLEFT", 0, 0)
			unit.healthBg:SetPoint("TOPRIGHT", unit.ActualHealthBar, 1, 1)
			unit.healthBg:SetPoint("BOTTOMRIGHT", unit.ActualHealthBar, 1, -1)
			unit.ActualHealthBar:SetGradient("HORIZONTAL", 1, .12, .24, .5, .06, .12)
			unit.petIcon:SetPoint("BOTTOMRIGHT", unit.ActualHealthBar, "TOPRIGHT", 0, 8)
			unit.Name:SetPoint("RIGHT", unit.petIcon, "LEFT", -5, 0)
			unit.Level:SetPoint("BOTTOMRIGHT", unit.Icon, 2, 2)
			if unit.SpeedIcon then
				unit.SpeedIcon:SetPoint("RIGHT", unit.healthBg, "LEFT", -5, 0)
				unit.SpeedIcon:SetTexCoord(.5, 0, .5, 1)
			end
		end
	end

	-- Pending Pets
	local buddy = {frame.Ally2,	frame.Ally3, frame.Enemy2, frame.Enemy3}
	for index, unit in pairs(buddy) do
		unit:ClearAllPoints()
		unit.HealthBarBG:SetAlpha(0)
		unit.HealthDivider:SetAlpha(0)
		unit.BorderAlive:SetAlpha(0)
		unit.BorderDead:SetAlpha(0)

		unit.Iconbg = CreateFrame("Frame", nil, unit)
		unit.Iconbg:SetAllPoints(unit.Icon)
		unit.Iconbg:SetFrameLevel(unit:GetFrameLevel())
		unit.Iconbg:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true)

		unit.deadIcon = unit:CreateTexture(nil, "ARTWORK")
		unit.deadIcon:SetAllPoints(unit.Icon)
		unit.deadIcon:SetTexture("Interface\\PETBATTLES\\DeadPetIcon")
		unit.deadIcon:Hide()

		unit.healthBarWidth = 36
		unit.ActualHealthBar:ClearAllPoints()
		unit.ActualHealthBar:SetPoint("TOPLEFT", unit.Icon, "BOTTOMLEFT", 1, -8)
		unit.ActualHealthBar:SetTexture(C["Media"].Texture)

		unit.healthBg = CreateFrame("Frame", nil, unit)
		unit.healthBg:CreateBorder()
		unit.healthBg:SetPoint("TOPLEFT", unit.ActualHealthBar, -1, 1)
		unit.healthBg:SetPoint("BOTTOMRIGHT", unit.ActualHealthBar, "TOPLEFT", 37, -8)
		unit.healthBg:SetFrameLevel(unit:GetFrameLevel())

		if index < 3 then
			unit.ActualHealthBar:SetGradient("VERTICAL", .26, 1, .22, .13, .5, .11)
		else
			unit.ActualHealthBar:SetGradient("VERTICAL", 1, .12, .24, .5, .06, .12)
		end
	end
	frame.Ally2:SetPoint("BOTTOMRIGHT", frame.ActiveAlly, "BOTTOMLEFT", -10, 22)
	frame.Ally3:SetPoint("BOTTOMRIGHT", frame.Ally2, "BOTTOMLEFT", -8, 0)
	frame.Enemy2:SetPoint("BOTTOMLEFT", frame.ActiveEnemy, "BOTTOMRIGHT", 10, 22)
	frame.Enemy3:SetPoint("BOTTOMLEFT", frame.Enemy2, "BOTTOMRIGHT", 8, 0)

	-- Update Status
	hooksecurefunc("PetBattleUnitFrame_UpdatePetType", function(self)
		if self.PetType and self.petIcon then
			local petType = C_PetBattles.GetPetType(self.petOwner, self.petIndex)
			self.petIcon:SetTexture("Interface\\ICONS\\Icon_PetFamily_"..PET_TYPE_SUFFIX[petType])
		end
	end)

	hooksecurefunc("PetBattleUnitFrame_UpdateDisplay", function(self)
		local petOwner = self.petOwner
		if (not petOwner) or self.petIndex > C_PetBattles.GetNumPets(petOwner) then
			return
		end

		if self.Icon then
			if petOwner == LE_BATTLE_PET_ALLY then
				self.Icon:SetTexCoord(.92, .08, .08, .92)
			else
				self.Icon:SetTexCoord(unpack(K.TexCoords))
			end
		end

		if self.glow then
			self.glow:Hide()
		end

		if self.Iconbg then
			local quality = C_PetBattles.GetBreedQuality(self.petOwner, self.petIndex) - 1 or 1
			local color = K.QualityColors[quality]
			self.Iconbg.KKUI_Border:SetVertexColor(color.r, color.g, color.b)
		end
	end)

	hooksecurefunc("PetBattleUnitFrame_UpdateHealthInstant", function(self)
		if self.BorderDead and self.BorderDead:IsShown() and self.Iconbg then
			self.Iconbg.KKUI_Border:SetVertexColor(1, .12, .24)
		end

		if self.BorderDead and self.deadIcon then
			self.deadIcon:SetShown(self.BorderDead:IsShown())
		end
	end)

	hooksecurefunc("PetBattleAuraHolder_Update", function(self)
		if not self.petOwner or not self.petIndex then
			return
		end

		local nextFrame = 1
		for i = 1, C_PetBattles.GetNumAuras(self.petOwner, self.petIndex) do
			local _, _, _, isBuff = C_PetBattles.GetAuraInfo(self.petOwner, self.petIndex, i)
			if (isBuff and self.displayBuffs) or (not isBuff and self.displayDebuffs) then
				local frame = self.frames[nextFrame]
				frame.DebuffBorder:Hide()
				if not frame.styled then
					frame.Icon:SetTexCoord(unpack(K.TexCoords))
					frame.Icon.bg = CreateFrame("Frame", nil, frame)
					frame.Icon.bg:SetAllPoints(frame.Icon)
					frame.Icon.bg:SetFrameLevel(frame:GetFrameLevel())
					frame.Icon.bg:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true)
					frame.styled = true
				end

				nextFrame = nextFrame + 1
			end
		end
	end)

	-- Bottom Frame
	local bottomFrame = frame.BottomFrame
	for i = 1, 3 do
		select(i, bottomFrame:GetRegions()):Hide()
	end
	bottomFrame.Delimiter:Hide()
	bottomFrame.MicroButtonFrame:Hide()
	bottomFrame.TurnTimer.ArtFrame:SetTexture("")
	bottomFrame.TurnTimer.ArtFrame2:SetTexture("")
	bottomFrame.TurnTimer.TimerBG:SetTexture("")
	for i = 1, 3 do
		select(i, bottomFrame.FlowFrame:GetRegions()):SetAlpha(0)
	end

	-- Reskin Petbar
	local bar = CreateFrame("Frame", "KKUI_PetBattleBar", UIParent, "SecureHandlerStateTemplate")
	bar:SetPoint("BOTTOM", UIParent, 0, 28)
	bar:SetSize(330, 40)
	local visibleState = "[petbattle] show; hide"
	RegisterStateDriver(bar, "visibility", visibleState)

	hooksecurefunc("PetBattleFrame_UpdateActionBarLayout", function(self)
		local f = self.BottomFrame
		local buttonList = {f.abilityButtons[1], f.abilityButtons[2], f.abilityButtons[3], f.SwitchPetButton, f.CatchButton, f.ForfeitButton}

		for i = 1, 6 do
			local bu = buttonList[i]
			bu:SetParent(bar)
			bu:SetSize(42, 42)
			bu:ClearAllPoints()
			if i == 1 then
				bu:SetPoint("LEFT", bar)
			else
				bu:SetPoint("LEFT", buttonList[i - 1], "RIGHT", 6, 0)
			end

			bu:SetNormalTexture("")
			bu:StyleButton()
			if not bu.bg then
				bu.Icon:SetTexCoord(unpack(K.TexCoords))
				bu.bg = CreateFrame("Frame", nil, bu)
				bu.bg:SetAllPoints(bu.Icon)
				bu.bg:SetFrameLevel(bu:GetFrameLevel())
				bu.bg:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true)
				bu.Icon:SetAllPoints()
			end

			bu.Cooldown:FontTemplate()
			bu.SelectedHighlight:ClearAllPoints()
			bu.SelectedHighlight:SetPoint("TOPLEFT", bu, -12, 12)
			bu.SelectedHighlight:SetPoint("BOTTOMRIGHT", bu, 12, -12)
		end
		buttonList[4]:GetCheckedTexture():SetColorTexture(r, g, b, .3)
	end)

	local skipButton = bottomFrame.TurnTimer.SkipButton
	skipButton:SetParent(bar)
	skipButton:SetSize(42, 42)

	skipButton:StripTextures()
	skipButton.Icon = skipButton:CreateTexture(nil, "ARTWORK")
	skipButton.Icon:SetTexture("Interface\\Icons\\Ability_Foundryraid_Dormant")
	skipButton.Icon:SetAllPoints()
	skipButton.Icon:SetTexCoord(unpack(K.TexCoords))
	skipButton:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true)
	skipButton:StyleButton()

	local xpbar = PetBattleFrameXPBar
	xpbar:StripTextures()
	xpbar:SetParent(bar)
	xpbar:SetWidth(bar:GetWidth())
	xpbar:SetStatusBarTexture(C["Media"].Texture)
	xpbar:CreateBorder()

	local turnTimer = bottomFrame.TurnTimer
	turnTimer:SetParent(bar)
	turnTimer:SetSize(xpbar:GetWidth() + 4, xpbar:GetHeight() + 10)
	turnTimer:ClearAllPoints()
	turnTimer:SetPoint("BOTTOM", bar, "TOP", 0, 7)

	turnTimer.bg = CreateFrame("Frame", nil, bottomFrame)
	turnTimer.bg:SetAllPoints(turnTimer)
	turnTimer.bg:SetFrameLevel(turnTimer:GetFrameLevel())
	turnTimer.bg:CreateBorder()

	turnTimer.Bar:ClearAllPoints()
	turnTimer.Bar:SetPoint("LEFT", 2, 0)
	turnTimer.TimerText:ClearAllPoints()
	turnTimer.TimerText:SetPoint("CENTER", turnTimer)

	hooksecurefunc("PetBattleFrame_UpdatePassButtonAndTimer", function()
		skipButton:ClearAllPoints()
		skipButton:SetPoint("LEFT", bottomFrame.ForfeitButton, "RIGHT", 6, 0)

		local pveBattle = C_PetBattles.IsPlayerNPC(LE_BATTLE_PET_ENEMY)
		turnTimer.bg:SetShown(not pveBattle)

		xpbar:ClearAllPoints()
		if pveBattle then
			xpbar:SetPoint("BOTTOM", bar, "TOP", 0, 7)
		else
			xpbar:SetPoint("BOTTOM", turnTimer, "TOP", 0, 4)
		end
	end)

	-- Pet Changing
	for i = 1, NUM_BATTLE_PETS_IN_BATTLE do
		local unit = bottomFrame.PetSelectionFrame["Pet"..i]
		local icon = unit.Icon

		icon:SetTexCoord(unpack(K.TexCoords))
		unit.Iconbg = CreateFrame("Frame", nil, unit)
		unit.Iconbg:SetAllPoints(icon)
		unit.Iconbg:SetFrameLevel(unit:GetFrameLevel())
		unit.Iconbg:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true)

		unit.HealthBarBG:Hide()
		unit.Framing:Hide()
		unit.HealthDivider:Hide()
		unit.Name:SetPoint("TOPLEFT", icon, "TOPRIGHT", 3, -3)

		unit.ActualHealthBar:SetPoint("BOTTOMLEFT", icon, "BOTTOMRIGHT", 7, 1)
		unit.ActualHealthBar:SetTexture(C["Media"].Texture)

		local bg = CreateFrame("Frame", nil, unit)
		bg:SetPoint("TOPLEFT", unit.ActualHealthBar, -1, 1)
		bg:SetPoint("BOTTOMRIGHT", unit.ActualHealthBar, "BOTTOMLEFT", 129, -1)
		bg:SetFrameLevel(unit:GetFrameLevel())
		bg:CreateBorder()
	end
end)