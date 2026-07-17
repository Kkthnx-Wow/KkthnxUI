local K = KkthnxUI[1]
K.GUIBuilder = K.GUIBuilder or {}
local B = K.GUIBuilder

function B.CreateRaidCategory()
	if not B or not B.Ready() then return end
	local K, GUI, C, L, enableTextColor = B.K, B.GUI, B.C, B.L, B.enableTextColor
	local GENERAL, COLORS, PLAYER, TARGET, FILTERS = B.GENERAL, B.COLORS, B.PLAYER, B.TARGET, B.FILTERS

	local raidIcon = "Interface\\Icons\\Achievement_boss_illidan"
	local raidCategory = GUI:AddCategory(L["Raid"], raidIcon, "Raid")

	-- General Section
	local generalRaidSection = GUI:AddSection(raidCategory, GENERAL)
	GUI:CreateSwitch(generalRaidSection, "Raid.Enable", enableTextColor .. L["Enable Raidframes"], "Toggle the entire raid frame system on/off")
	GUI:CreateSwitch(generalRaidSection, "Raid.MainTankFrames", L["Show MainTank Frames"], L["Raid.MainTankFrames Desc"])

	-- Visibility
	local visibilityRaidSection = GUI:AddSection(raidCategory, L["Visibility"])
	GUI:CreateSwitch(visibilityRaidSection, "Raid.UseRaidForParty", L["Use Raid Frames for Party"], L["UseRaidForParty Desc"])
	GUI:CreateSwitch(visibilityRaidSection, "Raid.ShowRaidSolo", L["Show Raid Frames While Solo"], L["ShowRaidSolo Desc"])
	GUI:CreateSwitch(visibilityRaidSection, "Raid.ShowTeamIndex", L["Show Group Number Team Index"], L["Raid.ShowTeamIndex Desc"])

	-- Layout
	local layoutRaidSection = GUI:AddSection(raidCategory, L["Layout"])
	GUI:CreateSwitch(layoutRaidSection, "Raid.HorizonRaid", L["Horizontal Raid Frames"], L["Raid.HorizonRaid Desc"])
	GUI:CreateSwitch(layoutRaidSection, "Raid.ReverseRaid", L["Reverse Raid Frame Growth"], L["Raid.ReverseRaid Desc"])

	-- Bars
	local barsRaidSection = GUI:AddSection(raidCategory, L["Bars"])
	GUI:CreateSwitch(barsRaidSection, "Raid.PowerBarShow", L["Enable Power Bars"], L["Raid.PowerBarShow Desc"])
	local manaBarSwitch = GUI:CreateSwitch(barsRaidSection, "Raid.ManabarShow", L["Only Show Mana"], L["Raid.ManabarShow Desc"])
	GUI:DependsOn(manaBarSwitch, "Raid.PowerBarShow", true)
	GUI:CreateSwitch(barsRaidSection, "Raid.Smooth", L["Smooth Bar Transition"], L["Raid.Smooth Desc"])

	-- Behavior
	local behaviorRaidSection = GUI:AddSection(raidCategory, L["Behavior"])
	GUI:CreateSwitch(behaviorRaidSection, "Raid.ShowHealPrediction", L["Show HealPrediction Statusbars"], L["Raid.ShowHealPrediction Desc"])
	local raidAbsorbStrips = GUI:CreateSwitch(behaviorRaidSection, "Raid.AbsorbStrips", L["Raid Absorb Strip Bars"], L["Raid.AbsorbStrips Desc"])
	GUI:DependsOn(raidAbsorbStrips, "Raid.ShowHealPrediction", true)
	GUI:CreateSwitch(behaviorRaidSection, "Raid.DispelIcon", L["Raid Dispel Type Icons"], L["Raid.DispelIcon Desc"])
	local dispelIconAll = GUI:CreateSwitch(behaviorRaidSection, "Raid.DispelIconAll", L["Show All Dispellable Debuffs"], L["Raid.DispelIconAll Desc"])
	GUI:DependsOn(dispelIconAll, "Raid.DispelIcon", true)
	GUI:CreateSwitch(behaviorRaidSection, "Raid.TargetHighlight", L["Show Highlighted Target"], L["Raid.TargetHighlight Desc"])
	GUI:CreateSwitch(behaviorRaidSection, "Raid.ShowNotHereTimer", L["Show Away/DND Status"], L["Raid.ShowNotHereTimer Desc"])

	-- Sizes
	local sizesRaidSection = GUI:AddSection(raidCategory, L["Sizes"])
	GUI:CreateSlider(sizesRaidSection, "Raid.Height", L["Raidframe Height"], 20, 100, 1, L["Raid.Height Desc"])
	GUI:CreateSlider(sizesRaidSection, "Raid.NumGroups", L["Number Of Groups to Show"], 1, 8, 1, L["Raid.NumGroups Desc"])
	GUI:CreateSlider(sizesRaidSection, "Raid.Width", L["Raidframe Width"], 20, 100, 1, L["Raid.Width Desc"])

	-- Colors & Values
	local colorsRaidSection = GUI:AddSection(raidCategory, L["Colors"])
	local healthColorOptions = {
		{ text = "Class", value = 1 },
		{ text = "Dark", value = 2 },
		{ text = "Value", value = 3 },
	}
	GUI:CreateDropdown(colorsRaidSection, "Raid.HealthbarColor", L["Health Color Format"], healthColorOptions, L["Raid.HealthbarColor Desc"])
	local healthFormatOptions = {
		{ text = "Disable HP", value = 1 },
		{ text = "Health Percentage", value = 2 },
		{ text = "Health Remaining", value = 3 },
		{ text = "Health Lost", value = 4 },
	}
	GUI:CreateDropdown(colorsRaidSection, "Raid.HealthFormat", L["Health Format"], healthFormatOptions, L["Raid.HealthFormat Desc"])

	-- Raid Buffs
	local raidBuffsSection = GUI:AddSection(raidCategory, L["Raid Buffs"])
	local raidBuffsStyleOptions = {
		{ text = "Standard", value = 1 },
		{ text = "Aura Track", value = 2 },
		{ text = "Disable", value = 3 },
	}
	GUI:CreateDropdown(raidBuffsSection, "Raid.RaidBuffsStyle", L["Buff Style"], raidBuffsStyleOptions, L["RaidBuffsStyle Desc"])
	GUI:CreateDropdown(raidBuffsSection, "Raid.RaidBuffs", L["Buff Display & Filtering"], {
		{ text = "Only my buffs", value = 1 },
		{ text = "Only castable buffs", value = 2 },
		{ text = "All buffs", value = 3 },
	}, L["RaidBuffs Desc"])
	GUI:CreateSwitch(raidBuffsSection, "Raid.DesaturateBuffs", L["Desaturate non-player buffs"], L["DesaturateBuffs Desc"])

	-- Aura Track
	local auraTrackSection = GUI:AddSection(raidCategory, L["Aura Track"])
	local auraTrack = GUI:CreateSwitch(auraTrackSection, "Raid.AuraTrack", L["Enable aura tracking for healers (replaces buffs)"], L["AuraTrack Desc"])
	local auraTrackIcons = GUI:CreateSwitch(auraTrackSection, "Raid.AuraTrackIcons", L["Use square icons instead of bars"], L["AuraTrackIcons Desc"])
	local auraTrackTex = GUI:CreateSwitch(auraTrackSection, "Raid.AuraTrackSpellTextures", L["Show spell textures on aura icons"], L["AuraTrackSpellTextures Desc"])
	local auraTrackThick = GUI:CreateSlider(auraTrackSection, "Raid.AuraTrackThickness", L["Aura bar thickness (px)"], 2, 10, 1, L["AuraTrackThickness Desc"])
	local function IsAuraTrackStyle(v)
		return v == 2
	end
	GUI:DependsOn(auraTrack, "Raid.RaidBuffsStyle", 2, IsAuraTrackStyle)
	GUI:DependsOn(auraTrackIcons, "Raid.RaidBuffsStyle", 2, IsAuraTrackStyle)
	GUI:DependsOn(auraTrackTex, "Raid.RaidBuffsStyle", 2, IsAuraTrackStyle)
	GUI:DependsOn(auraTrackThick, "Raid.RaidBuffsStyle", 2, IsAuraTrackStyle)

	-- Raid Debuffs
	local raidDebuffsSection = GUI:AddSection(raidCategory, L["Raid Debuffs"])
	GUI:CreateSwitch(raidDebuffsSection, "Raid.DebuffWatch", L["Enable debuff tracking (auto-filter by PvP/PvE)"], L["DebuffWatch Desc"])
	GUI:CreateSwitch(raidDebuffsSection, "Raid.DebuffWatchDefault", L["Use built-in debuff lists (PvE & PvP)"], L["DebuffWatchDefault Desc"])
end
