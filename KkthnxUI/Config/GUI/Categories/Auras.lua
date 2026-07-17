local K = KkthnxUI[1]
K.GUIBuilder = K.GUIBuilder or {}
local B = K.GUIBuilder

function B.CreateAurasCategory()
	if not B or not B.Ready() then return end
	local K, GUI, C, L, enableTextColor = B.K, B.GUI, B.C, B.L, B.enableTextColor
	local GENERAL, COLORS, PLAYER, TARGET, FILTERS = B.GENERAL, B.COLORS, B.PLAYER, B.TARGET, B.FILTERS

	local aurasCategory = GUI:AddCategory(L["Auras"], "Interface\\Icons\\Spell_Magic_LesserInvisibilty", "Auras")

	-- General
	local generalAurasSection = GUI:AddSection(aurasCategory, GENERAL)
	GUI:CreateSwitch(generalAurasSection, "Auras.Enable", enableTextColor .. L["Enable Auras"], L["Enable Desc"])
	GUI:CreateSwitch(generalAurasSection, "Auras.HideBlizBuff", L["Hide The Default BuffFrame"], L["HideBlizBuff Desc"])
	GUI:CreateSwitch(generalAurasSection, "Auras.Reminder", L["Auras Reminder (Shout/Intellect/Poison)"], L["Reminder Desc"])
	local reminderGlow = GUI:CreateSwitch(generalAurasSection, "Auras.ReminderGlow", L["Reminder Glow"], L["Reminder Glow Desc"])
	GUI:DependsOn(reminderGlow, "Auras.Reminder", true)
	-- REASON: dedicated icon-size slider instead of the
	-- reminder icons silently inheriting the unrelated Auras.DebuffSize setting.
	local reminderIconSize = GUI:CreateSlider(generalAurasSection, "Auras.ReminderIconSize", L["Reminder Icon Size"], 20, 64, 1, L["Reminder Icon Size Desc"])
	GUI:DependsOn(reminderIconSize, "Auras.Reminder", true)
	GUI:CreateSwitch(generalAurasSection, "Auras.ReverseBuffs", L["Buffs Grow Right"], L["ReverseBuffs Desc"])
	GUI:CreateSwitch(generalAurasSection, "Auras.ReverseDebuffs", L["Debuffs Grow Right"], L["Auras.ReverseDebuffs Desc"])

	-- Sizes
	local aurasSizesSection = GUI:AddSection(aurasCategory, L["Sizes"])
	GUI:CreateSlider(aurasSizesSection, "Auras.BuffSize", L["Buff Icon Size"], 20, 40, 1, L["AuraSize Desc"])
	GUI:CreateSlider(aurasSizesSection, "Auras.BuffsPerRow", L["Buffs per Row"], 10, 20, 1, L["BuffsPerRow Desc"])
	GUI:CreateSlider(aurasSizesSection, "Auras.DebuffSize", L["DeBuff Icon Size"], 20, 40, 1, L["AuraSize Desc"])
	GUI:CreateSlider(aurasSizesSection, "Auras.DebuffsPerRow", L["DeBuffs per Row"], 10, 16, 1, L["DebuffsPerRow Desc"])

	-- Totems
	local totemsSection = GUI:AddSection(aurasCategory, TUTORIAL_TITLE47 or "Totems")
	GUI:CreateSwitch(totemsSection, "Auras.Totems", enableTextColor .. L["Enable TotemBar"], L["Totems Desc"])
	local verticalTotems = GUI:CreateSwitch(totemsSection, "Auras.VerticalTotems", L["Vertical TotemBar"], L["VerticalTotems Desc"])
	local totemSize = GUI:CreateSlider(totemsSection, "Auras.TotemSize", L["Totems IconSize"], 24, 60, 1, L["TotemSize Desc"])
	GUI:DependsOn(verticalTotems, "Auras.Totems", true)
	GUI:DependsOn(totemSize, "Auras.Totems", true)
end
