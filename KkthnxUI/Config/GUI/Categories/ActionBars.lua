local K = KkthnxUI[1]
K.GUIBuilder = K.GUIBuilder or {}
local B = K.GUIBuilder

function B.CreateActionBarsCategory()
	if not B or not B.Ready() then return end
	local K, GUI, C, L, enableTextColor = B.K, B.GUI, B.C, B.L, B.enableTextColor
	local GENERAL, COLORS, PLAYER, TARGET, FILTERS = B.GENERAL, B.COLORS, B.PLAYER, B.TARGET, B.FILTERS

	local actionBarCategory = GUI:AddCategory(L["Action Bars"], "Interface\\Icons\\INV_Misc_GroupLooking", "ActionBars")

	local barVisibilitySection = GUI:AddSection(actionBarCategory, L["Bar Visibility"])
	GUI:CreateSwitch(barVisibilitySection, "ActionBar.Enable", enableTextColor .. L["Enable ActionBars"], L["ActionBar.Enable Desc"])
	for barIndex = 1, 8 do
		GUI:CreateSwitch(
			barVisibilitySection,
			"ActionBar.Bar" .. barIndex,
			enableTextColor .. L["Enable ActionBar"] .. " " .. barIndex,
			L["Bar" .. barIndex .. " Desc"]
		)
	end

	-- Pet Bar
	local petBarSection = GUI:AddSection(actionBarCategory, L["ActionBar Pet"])
	GUI:CreateSlider(petBarSection, "ActionBar.BarPetSize", L["Button Size"], 20, 80, 1, L["BarPetSize Desc"])
	GUI:CreateSlider(petBarSection, "ActionBar.BarPetPerRow", L["Button PerRow"], 1, 12, 1, L["BarPetPerRow Desc"])
	GUI:CreateSlider(petBarSection, "ActionBar.BarPetFont", L["Button FontSize"], 8, 20, 1, L["BarPetFont Desc"])
	GUI:CreateSwitch(petBarSection, "ActionBar.BarPetFade", L["Enable Fade for Pet Bar"], L["Allows the Pet Bar to fade based on the specified conditions"])

	-- Stance Bar
	local stanceBarSection = GUI:AddSection(actionBarCategory, L["ActionBar Stance"])
	GUI:CreateSwitch(stanceBarSection, "ActionBar.ShowStance", enableTextColor .. L["Enable StanceBar"], L["ShowStance Desc"])
	local stanceSize = GUI:CreateSlider(stanceBarSection, "ActionBar.BarStanceSize", L["Button Size"], 20, 80, 1, L["BarStanceSize Desc"])
	local stancePerRow = GUI:CreateSlider(stanceBarSection, "ActionBar.BarStancePerRow", L["Button PerRow"], 1, 12, 1, L["BarStancePerRow Desc"])
	local stanceFont = GUI:CreateSlider(stanceBarSection, "ActionBar.BarStanceFont", L["Button FontSize"], 8, 20, 1, L["BarStanceFont Desc"])
	local stanceFade = GUI:CreateSwitch(stanceBarSection, "ActionBar.BarStanceFade", L["Enable Fade for Stance Bar"], L["Allows the Stance Bar to fade based on the specified conditions"])
	GUI:DependsOn(stanceSize, "ActionBar.ShowStance", true)
	GUI:DependsOn(stancePerRow, "ActionBar.ShowStance", true)
	GUI:DependsOn(stanceFont, "ActionBar.ShowStance", true)
	GUI:DependsOn(stanceFade, "ActionBar.ShowStance", true)

	-- Vehicle Button
	local vehicleSection = GUI:AddSection(actionBarCategory, L["ActionBar Vehicle"])
	GUI:CreateSlider(vehicleSection, "ActionBar.VehButtonSize", L["Button Size"], 20, 80, 1, L["VehButtonSize Desc"])

	-- Toggles
	local togglesSection = GUI:AddSection(actionBarCategory, L["Toggles"])
	GUI:CreateSwitch(togglesSection, "ActionBar.EquipColor", L["Equip Color"], L["EquipColor Desc"])
	GUI:CreateSwitch(togglesSection, "ActionBar.Grid", L["Actionbar Grid"], L["Grid Desc"])
	GUI:CreateSwitch(togglesSection, "ActionBar.Hotkeys", L["Enable Hotkey"], L["Hotkeys Desc"])
	GUI:CreateSwitch(togglesSection, "ActionBar.Macro", L["Enable Macro"], L["Macro Desc"])
	GUI:CreateSwitch(togglesSection, "ActionBar.KeyDown", L["Cast on Key Press"], L["Cast spells and abilities on key press, not key release"])
	GUI:CreateSwitch(togglesSection, "ActionBar.ButtonLock", L["Lock Action Bars"], L["Keep your action bar layout locked in place to prevent accidental reordering. To move a spell or ability while locked, hold the Shift key."])
	GUI:CreateSwitch(togglesSection, "ActionBar.Cooldown", L["Show Cooldowns"], L["Cooldown Desc"])
	GUI:CreateSwitch(togglesSection, "ActionBar.DesaturateOnCooldown", L["Desaturate on Cooldown"], L["DesaturateOnCooldown Desc"])
	GUI:CreateSlider(togglesSection, "ActionBar.CooldownAlpha", L["Cooldown Alpha"], 0, 100, 1, L["CooldownAlpha Desc"])
	GUI:CreateSwitch(togglesSection, "ActionBar.MicroMenu", L["Enable MicroBar"], L["MicroMenu Desc"])
	GUI:CreateSwitch(togglesSection, "ActionBar.FadeMicroMenu", L["Mouseover MicroBar"], L["FadeMicroMenu Desc"])
	-- OverrideWA only affects newly styled cooldown frames; flipping it mid-session needs a reload.
	GUI:CreateSwitch(togglesSection, "ActionBar.OverrideWA", L["Enable OverrideWA"], L["OverrideWA Desc"], nil, nil, true)
	GUI:CreateSlider(togglesSection, "ActionBar.MmssTH", L["MMSSThreshold"], 60, 600, 1, L["MMSSThresholdTip"])
	-- Fader Options
	local faderSection = GUI:AddSection(actionBarCategory, L["Fader Options"])
	GUI:CreateSwitch(faderSection, "ActionBar.BarFadeGlobal", L["Enable Global Fade"], L["BarFadeGlobal Desc"])
	GUI:CreateSlider(faderSection, "ActionBar.BarFadeAlpha", L["Fade Alpha"], 0, 1, 0.1, L["BarFadeAlpha Desc"])
	GUI:CreateSlider(faderSection, "ActionBar.BarFadeDelay", L["Fade Delay"], 0, 3, 0.1, L["BarFadeDelay Desc"])
	GUI:CreateSwitch(faderSection, "ActionBar.BarFadeCombat", L["Fade Out of Combat"], L["BarFadeCombat Desc"])
	GUI:CreateSwitch(faderSection, "ActionBar.BarFadeTarget", L["Fade without Target"], L["BarFadeTarget Desc"])
	GUI:CreateSwitch(faderSection, "ActionBar.BarFadeCasting", L["Fade While Casting"], L["BarFadeCasting Desc"])
	GUI:CreateSwitch(faderSection, "ActionBar.BarFadeHealth", L["Fade on Full Health"], L["BarFadeHealth Desc"])
	GUI:CreateSwitch(faderSection, "ActionBar.BarFadeVehicle", L["Fade in Vehicle"], L["BarFadeVehicle Desc"])

	-- Cursor Ring
	local cursorRingSection = GUI:AddSection(actionBarCategory, L["Cursor Ring"])
	GUI:CreateSwitch(cursorRingSection, "ActionBar.CursorRing", enableTextColor .. L["Enable Cursor Ring"], L["ActionBar.CursorRing Desc"])
	local cursorCast = GUI:CreateSwitch(cursorRingSection, "ActionBar.CursorRingShowCast", L["Show Cast Ring"], L["ActionBar.CursorRingShowCast Desc"])
	local cursorCombat = GUI:CreateSwitch(cursorRingSection, "ActionBar.CursorRingCombatOnly", L["Combat Only"], L["ActionBar.CursorRingCombatOnly Desc"])
	local cursorSize = GUI:CreateSlider(cursorRingSection, "ActionBar.CursorRingSize", L["Cursor Ring Size"], 24, 96, 2, L["ActionBar.CursorRingSize Desc"])
	GUI:DependsOn(cursorCast, "ActionBar.CursorRing", true)
	GUI:DependsOn(cursorCombat, "ActionBar.CursorRing", true)
	GUI:DependsOn(cursorSize, "ActionBar.CursorRing", true)
end

