local K = KkthnxUI[1]
K.GUIBuilder = K.GUIBuilder or {}
local B = K.GUIBuilder

function B.CreateUnitframeCategory()
	if not B or not B.Ready() then return end
	local K, GUI, C, L, enableTextColor = B.K, B.GUI, B.C, B.L, B.enableTextColor
	local GENERAL, COLORS, PLAYER, TARGET, FILTERS = B.GENERAL, B.COLORS, B.PLAYER, B.TARGET, B.FILTERS

	local unitframeIcon = "Interface\\Icons\\Spell_Shadow_AntiShadow"
	local unitframeCategory = GUI:AddCategory(L["Unitframe"], unitframeIcon, "Unitframe")

	-- General
	local generalUnitframeSection = GUI:AddSection(unitframeCategory, GENERAL)
	GUI:CreateSwitch(generalUnitframeSection, "Unitframe.Enable", enableTextColor .. L["Enable Unitframes"], "Toggle the entire unitframe system on/off")
	GUI:CreateSwitch(generalUnitframeSection, "Unitframe.CastClassColor", L["Class Color Castbars"], L["Unitframe.CastClassColor Desc"])
	GUI:CreateSwitch(generalUnitframeSection, "Unitframe.CastReactionColor", L["Reaction Color Castbars"], L["Unitframe.CastReactionColor Desc"])
	GUI:CreateSwitch(generalUnitframeSection, "Unitframe.CastbarKickTick", L["Castbar Kick Tick"], L["CastbarKickTick Desc"])
	GUI:CreateSwitch(generalUnitframeSection, "Unitframe.CastbarKickReadyFill", L["Castbar Kick Ready Fill"], L["CastbarKickReadyFill Desc"])
	GUI:CreateSwitch(generalUnitframeSection, "Unitframe.CastTarget", L["Show Cast Target"], L["Unitframe.CastTarget Desc"])
	GUI:CreateSwitch(generalUnitframeSection, "Unitframe.ClassResources", L["Show Class Resources"], L["Unitframe.ClassResources Desc"])
	GUI:CreateSwitch(generalUnitframeSection, "Unitframe.DebuffHighlight", L["Show Health Debuff Highlight"], L["Unitframe.DebuffHighlight Desc"])
	GUI:CreateSwitch(generalUnitframeSection, "Unitframe.PvPIndicator", L["Show PvP Indicator on Player / Target"], L["Unitframe.PvPIndicator Desc"])
	GUI:CreateSwitch(generalUnitframeSection, "Unitframe.Range", L["Unitframe Range Fading"], L["UnitframeRange Desc"])
	GUI:CreateSwitch(generalUnitframeSection, "Unitframe.ResurrectSound", L["Sound Played When You Are Resurrected"], L["Unitframe.ResurrectSound Desc"])
	GUI:CreateSwitch(generalUnitframeSection, "Unitframe.ShowHealPrediction", L["Show HealPrediction Statusbars"], L["Unitframe.ShowHealPrediction Desc"])
	GUI:CreateSwitch(generalUnitframeSection, "Unitframe.Smooth", L["Smooth Bars"], L["Unitframe.Smooth Desc"])
	GUI:CreateSwitch(generalUnitframeSection, "Unitframe.CombatFade", L["Combat Fade"], L["Unitframe.CombatFade Desc"])
	GUI:CreateSwitch(generalUnitframeSection, "Unitframe.Stagger", L["Show |CFF00FF96Monk|r Stagger Bar"], L["Unitframe.Stagger Desc"])
	GUI:CreateSlider(generalUnitframeSection, "Unitframe.AllTextScale", L["Scale All Unitframe Texts"], 0.8, 1.5, 0.05, L["AllTextScale Desc"])

	-- Player - General
	local playerGeneralSection = GUI:AddSection(unitframeCategory, PLAYER .. " - General")
	GUI:CreateSwitch(playerGeneralSection, "Unitframe.AdditionalPower", L["Show Additional Mana Power (|CFFFF7D0ADruid|r, |CFFFFFFFFPriest|r, |CFF0070DEShaman|r)"], L["Unitframe.AdditionalPower Desc"])
	GUI:CreateSwitch(playerGeneralSection, "Unitframe.ShowPlayerLevel", L["Show Player Frame Level"], L["Unitframe.ShowPlayerLevel Desc"])

	-- Player - Auras
	local playerAurasSection = GUI:AddSection(unitframeCategory, PLAYER .. " - Auras")
	GUI:CreateSwitch(playerAurasSection, "Unitframe.PlayerBuffs", L["Show Player Frame Buffs"], L["Unitframe.PlayerBuffs Desc"])
	GUI:CreateSwitch(playerAurasSection, "Unitframe.PrivateAuras", L["Unitframe.PrivateAuras"], L["Unitframe.PrivateAuras Desc"])
	GUI:CreateSwitch(playerAurasSection, "Unitframe.PlayerDebuffs", L["Show Player Frame Debuffs"], L["Unitframe.PlayerDebuffs Desc"])
	GUI:CreateSlider(playerAurasSection, "Unitframe.PlayerBuffsPerRow", L["Number of Buffs Per Row"], 4, 10, 1, L["Unitframe.PlayerBuffsPerRow Desc"])
	GUI:CreateSlider(playerAurasSection, "Unitframe.PlayerDebuffsPerRow", L["Number of Debuffs Per Row"], 4, 10, 1, L["Unitframe.PlayerDebuffsPerRow Desc"])

	-- Player - Castbar
	local playerCastbarSection = GUI:AddSection(unitframeCategory, PLAYER .. " - Castbar")
	GUI:CreateSwitch(playerCastbarSection, "Unitframe.PlayerCastbar", L["Enable Player CastBar"], L["Unitframe.PlayerCastbar Desc"])
	local playerCastIcon = GUI:CreateSwitch(playerCastbarSection, "Unitframe.PlayerCastbarIcon", L["Enable Player CastBar"] .. " Icon", L["Unitframe.PlayerCastbarIcon Desc"])
	local playerCastLatency = GUI:CreateSwitch(playerCastbarSection, "Unitframe.CastbarLatency", L["Show Castbar Latency"], L["Unitframe.CastbarLatency Desc"])
	local playerGcd = GUI:CreateSwitch(playerCastbarSection, "Unitframe.GlobalCooldown", L["Show Global Cooldown Spark"], L["GlobalCooldownSpark Desc"])
	local playerCastH = GUI:CreateSlider(playerCastbarSection, "Unitframe.PlayerCastbarHeight", L["Player Castbar Height"], 20, 40, 1, L["Unitframe.PlayerCastbarHeight Desc"])
	local playerCastW = GUI:CreateSlider(playerCastbarSection, "Unitframe.PlayerCastbarWidth", L["Player Castbar Width"], 100, 800, 1, L["Unitframe.PlayerCastbarWidth Desc"])
	GUI:DependsOn(playerCastIcon, "Unitframe.PlayerCastbar", true)
	GUI:DependsOn(playerCastLatency, "Unitframe.PlayerCastbar", true)
	GUI:DependsOn(playerGcd, "Unitframe.PlayerCastbar", true)
	GUI:DependsOn(playerCastH, "Unitframe.PlayerCastbar", true)
	GUI:DependsOn(playerCastW, "Unitframe.PlayerCastbar", true)

	-- Player - Frame
	local playerFrameSection = GUI:AddSection(unitframeCategory, PLAYER .. " - Frame")
	GUI:CreateSlider(playerFrameSection, "Unitframe.PlayerHealthHeight", L["Player Frame Height"], 20, 75, 1, L["Unitframe.PlayerHealthHeight Desc"])
	GUI:CreateSlider(playerFrameSection, "Unitframe.PlayerHealthWidth", L["Player Frame Width"], 100, 300, 1, L["Unitframe.PlayerHealthWidth Desc"])
	GUI:CreateSlider(playerFrameSection, "Unitframe.PlayerPowerHeight", L["Player Power Bar Height"], 10, 40, 1, L["PlayerPowerHeight Desc"])

	-- Target
	local targetUnitframeSection = GUI:AddSection(unitframeCategory, TARGET)
	GUI:CreateSwitch(targetUnitframeSection, "Unitframe.OnlyShowPlayerDebuff", L["Only Show Your Debuffs"], L["Unitframe.OnlyShowPlayerDebuff Desc"])
	GUI:CreateSwitch(targetUnitframeSection, "Unitframe.TargetBuffs", L["Show Target Frame Buffs"], L["Unitframe.TargetBuffs Desc"])
	GUI:CreateSwitch(targetUnitframeSection, "Unitframe.TargetCastbar", L["Enable Target CastBar"], L["Unitframe.TargetCastbar Desc"])
	local targetCastIcon = GUI:CreateSwitch(targetUnitframeSection, "Unitframe.TargetCastbarIcon", L["Enable Target CastBar"] .. " Icon", L["Unitframe.TargetCastbarIcon Desc"])
	GUI:CreateSwitch(targetUnitframeSection, "Unitframe.TargetDebuffs", L["Show Target Frame Debuffs"], L["Unitframe.TargetDebuffs Desc"])

	-- Target Frame Sizing
	GUI:CreateSlider(targetUnitframeSection, "Unitframe.TargetBuffsPerRow", L["Number of Buffs Per Row"], 4, 10, 1, L["Unitframe.TargetBuffsPerRow Desc"])
	GUI:CreateSlider(targetUnitframeSection, "Unitframe.TargetDebuffsPerRow", L["Number of Debuffs Per Row"], 4, 10, 1, L["Unitframe.TargetDebuffsPerRow Desc"])
	GUI:CreateSlider(targetUnitframeSection, "Unitframe.TargetPowerHeight", L["Target Power Bar Height"], 10, 40, 1, L["Unitframe.TargetPowerHeight Desc"])
	GUI:CreateSlider(targetUnitframeSection, "Unitframe.TargetHealthHeight", L["Target Frame Height"], 20, 75, 1, L["Unitframe.TargetHealthHeight Desc"])
	GUI:CreateSlider(targetUnitframeSection, "Unitframe.TargetHealthWidth", L["Target Frame Width"], 100, 300, 1, L["Unitframe.TargetHealthWidth Desc"])
	local targetCastH = GUI:CreateSlider(targetUnitframeSection, "Unitframe.TargetCastbarHeight", L["Target Castbar Height"], 20, 40, 1, L["Unitframe.TargetCastbarHeight Desc"])
	local targetCastW = GUI:CreateSlider(targetUnitframeSection, "Unitframe.TargetCastbarWidth", L["Target Castbar Width"], 100, 800, 1, L["Unitframe.TargetCastbarWidth Desc"])
	GUI:DependsOn(targetCastIcon, "Unitframe.TargetCastbar", true)
	GUI:DependsOn(targetCastH, "Unitframe.TargetCastbar", true)
	GUI:DependsOn(targetCastW, "Unitframe.TargetCastbar", true)

	-- Pet
	local petUnitframeSection = GUI:AddSection(unitframeCategory, PET)
	GUI:CreateSwitch(petUnitframeSection, "Unitframe.HidePet", L["Hide Pet Frame"], L["Unitframe.HidePet Desc"])
	GUI:CreateSwitch(petUnitframeSection, "Unitframe.HidePetLevel", L["Hide Pet Level"], L["Unitframe.HidePetLevel Desc"])
	GUI:CreateSwitch(petUnitframeSection, "Unitframe.HidePetName", L["Hide Pet Name"], L["Unitframe.HidePetName Desc"])
	GUI:CreateSlider(petUnitframeSection, "Unitframe.PetHealthHeight", L["Pet Frame Height"], 10, 50, 1, L["Unitframe.PetHealthHeight Desc"])
	GUI:CreateSlider(petUnitframeSection, "Unitframe.PetHealthWidth", L["Pet Frame Width"], 80, 300, 1, L["Unitframe.PetHealthWidth Desc"])
	GUI:CreateSlider(petUnitframeSection, "Unitframe.PetPowerHeight", L["Pet Power Bar"], 10, 50, 1, L["Unitframe.PetPowerHeight Desc"])

	-- Target Of Target
	local totUnitframeSection = GUI:AddSection(unitframeCategory, L["Target Of Target"])
	GUI:CreateSwitch(totUnitframeSection, "Unitframe.HideTargetofTarget", L["Hide TargetofTarget Frame"], L["Unitframe.HideTargetofTarget Desc"])
	GUI:CreateSwitch(totUnitframeSection, "Unitframe.HideTargetOfTargetLevel", L["Hide TargetofTarget Level"], L["Unitframe.HideTargetOfTargetLevel Desc"])
	GUI:CreateSwitch(totUnitframeSection, "Unitframe.HideTargetOfTargetName", L["Hide TargetofTarget Name"], L["Unitframe.HideTargetOfTargetName Desc"])
	GUI:CreateSlider(totUnitframeSection, "Unitframe.TargetTargetHealthHeight", L["Target of Target Frame Height"], 10, 50, 1, L["Unitframe.TargetTargetHealthHeight Desc"])
	GUI:CreateSlider(totUnitframeSection, "Unitframe.TargetTargetHealthWidth", L["Target of Target Frame Width"], 80, 300, 1, L["Unitframe.TargetTargetHealthWidth Desc"])
	GUI:CreateSlider(totUnitframeSection, "Unitframe.TargetTargetPowerHeight", L["Target of Target Power Height"], 10, 50, 1, L["TargetTargetPowerHeight Desc"])

	-- Focus
	local focusUnitframeSection = GUI:AddSection(unitframeCategory, FOCUS)
	GUI:CreateSwitch(focusUnitframeSection, "Unitframe.FocusBuffs", L["Show Focus Frame Buffs"], L["FocusBuffs Desc"])
	GUI:CreateSwitch(focusUnitframeSection, "Unitframe.FocusCastbar", L["Enable Focus CastBar"], L["FocusCastbar Desc"])
	local focusCastIcon = GUI:CreateSwitch(focusUnitframeSection, "Unitframe.FocusCastbarIcon", L["Enable Focus CastBar Icon"], L["FocusCastbarIcon Desc"])
	local focusCastH = GUI:CreateSlider(focusUnitframeSection, "Unitframe.FocusCastbarHeight", L["Focus Castbar Height"], 20, 40, 1, L["Unitframe.FocusCastbarHeight Desc"])
	local focusCastW = GUI:CreateSlider(focusUnitframeSection, "Unitframe.FocusCastbarWidth", L["Focus Castbar Width"], 100, 800, 1, L["Unitframe.FocusCastbarWidth Desc"])
	GUI:CreateSwitch(focusUnitframeSection, "Unitframe.FocusDebuffs", L["Show Focus Frame Debuffs"], L["FocusDebuffs Desc"])
	GUI:DependsOn(focusCastIcon, "Unitframe.FocusCastbar", true)
	GUI:DependsOn(focusCastH, "Unitframe.FocusCastbar", true)
	GUI:DependsOn(focusCastW, "Unitframe.FocusCastbar", true)
	GUI:CreateSlider(focusUnitframeSection, "Unitframe.FocusPowerHeight", L["Focus Power Bar Height"], 10, 40, 1, L["FocusPowerHeight Desc"])
	GUI:CreateSlider(focusUnitframeSection, "Unitframe.FocusHealthHeight", L["Focus Frame Height"], 20, 75, 1, L["Unitframe.FocusHealthHeight Desc"])
	GUI:CreateSlider(focusUnitframeSection, "Unitframe.FocusHealthWidth", L["Focus Frame Width"], 100, 300, 1, L["Unitframe.FocusHealthWidth Desc"])

	-- Focus Target
	local focusTargetSection = GUI:AddSection(unitframeCategory, L["GUI.Section.FocusTarget"])
	GUI:CreateSwitch(focusTargetSection, "Unitframe.HideFocusTarget", L["Hide Focus Target Frame"], L["Unitframe.HideFocusTarget Desc"])
	GUI:CreateSwitch(focusTargetSection, "Unitframe.HideFocusTargetLevel", L["Hide Focus Target Level"], L["Unitframe.HideFocusTargetLevel Desc"])
	GUI:CreateSwitch(focusTargetSection, "Unitframe.HideFocusTargetName", L["Hide Focus Target Name"], L["Unitframe.HideFocusTargetName Desc"])
	GUI:CreateSlider(focusTargetSection, "Unitframe.FocusTargetHealthHeight", L["Focus Target Frame Height"], 10, 50, 1, L["Unitframe.FocusTargetHealthHeight Desc"])
	GUI:CreateSlider(focusTargetSection, "Unitframe.FocusTargetHealthWidth", L["Focus Target Frame Width"], 80, 300, 1, L["Unitframe.FocusTargetHealthWidth Desc"])
	GUI:CreateSlider(focusTargetSection, "Unitframe.FocusTargetPowerHeight", L["Focus Target Power Height"], 10, 50, 1, L["Unitframe.FocusTargetPowerHeight Desc"])

	-- Unitframe Misc
	local miscUnitframeSection = GUI:AddSection(unitframeCategory, L["GUI.Section.UnitframeMisc"])

	-- Health Color Format
	local healthColorOptions = {
		{ text = "Class", value = 1 },
		{ text = "Dark", value = 2 },
		{ text = "Value", value = 3 },
	}
	GUI:CreateDropdown(miscUnitframeSection, "Unitframe.HealthbarColor", L["Health Color Format"], healthColorOptions, L["Unitframe.HealthbarColor Desc"])

	-- Portrait Style
	local portraitStyleOptions = {
		{ text = "No Portraits", value = 0 },
		{ text = "Default Portraits", value = 1 },
		{ text = "Class Portraits", value = 2 },
		{ text = "New Class Portraits", value = 3 },
		{ text = "Overlay Portrait", value = 4 },
		{ text = "3D Portraits", value = 5 },
	}
	GUI:CreateDropdown(miscUnitframeSection, "Unitframe.PortraitStyle", L["Unitframe Portrait Style"], portraitStyleOptions, L["Unitframe.PortraitStyle Desc"])
end
