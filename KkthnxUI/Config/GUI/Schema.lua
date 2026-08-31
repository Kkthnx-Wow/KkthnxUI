--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Config/GUI/Schema.lua
	Purpose:
		The declarative options tree the window turns into panels. Each category
		holds a flat list of controls (headers, checks, sliders, dropdowns,
		colours, buttons). Adding a setting is a single table entry here.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

local GUI = K.GUI

-- The GUI loads before the modules, so resolve the action bar module lazily
-- when a control actually fires (by which point it exists).
local function ActionBarModule()
	return K:GetModule("ActionBars", true)
end

-- Live-apply helper: relayout one bar after a setting changes.
local function ApplyBar(key)
	return function()
		local AB = ActionBarModule()
		if AB and AB.UpdateBar then
			AB:UpdateBar(key)
		end
	end
end

local function ApplyAllBars()
	local AB = ActionBarModule()
	if AB and AB.UpdateAllBars then
		AB:UpdateAllBars()
	end
end

local function ApplyBags()
	local B = K:GetModule("Bags", true)
	if B and B.UpdateAll then
		B:UpdateAll()
	end
end

local function UnitFrameModule()
	return K:GetModule("UnitFrames", true)
end

-- Live-apply for the two unit frame settings that do not need a rebuild.
local function RefreshHealthBorders()
	local UF = UnitFrameModule()
	if not UF or not UF.RefreshHealthBorder then
		return
	end
	for _, frame in ipairs(UF.all) do
		UF.RefreshHealthBorder(frame)
	end
end

local function RefreshTags(method)
	return function()
		local oUF = K.oUF
		if oUF and oUF.Tags then
			oUF.Tags:RefreshMethods(method)
		end
	end
end

-- Live apply for the experience bar appearance sliders / toggles.
local function ApplyExpRep()
	local m = K:GetModule("ExpRep", true)
	if m and m.Refresh then
		m:Refresh()
	end
end

-- Live apply for the alert-frame stack spacing / talking head toggle.
local function ApplyAlertFrames()
	local m = K:GetModule("AlertFrames", true)
	if m and m.Refresh then
		m:Refresh()
	end
end

local TEXT_FORMATS = {
	{ text = L["None"], value = "None" },
	{ text = L["Current"], value = "Current" },
	{ text = L["Percent"], value = "Percent" },
	{ text = L["Both"], value = "Both" },
}

local CASTBAR_DEP = { "Unitframe", "Castbar", "Enable" }

-- Build dropdown option lists from a media table's keys.
local function MediaOptions(tbl)
	local list = {}
	for name in pairs(tbl) do
		list[#list + 1] = { text = name, value = name }
	end
	table.sort(list, function(a, b)
		return a.text < b.text
	end)
	return list
end

-- The full control list for a single bar, applied live. Used inside that bar's
-- flyout panel, so it carries no header of its own. All rows below the enable
-- toggle grey out when the bar is disabled.
local function BarControls(key)
	local apply = ApplyBar(key)
	local dep = { "ActionBar", key, "Enable" }
	return {
		{ kind = "check", label = L["Enable Bar"], path = { "ActionBar", key, "Enable" }, reload = true },
		{ kind = "slider", label = L["Max Buttons"], path = { "ActionBar", key, "Buttons" }, min = 1, max = 12, step = 1, apply = apply, dependsOn = dep },
		{ kind = "slider", label = L["Buttons Per Row"], path = { "ActionBar", key, "PerRow" }, min = 1, max = 12, step = 1, apply = apply, dependsOn = dep },
		{ kind = "slider", label = L["Button Size"], path = { "ActionBar", key, "Size" }, min = 20, max = 50, step = 1, apply = apply, dependsOn = dep },
		{ kind = "slider", label = L["Button Spacing"], path = { "ActionBar", key, "Space" }, min = 0, max = 12, step = 1, apply = apply, dependsOn = dep },
		{ kind = "slider", label = L["Bar Opacity"], path = { "ActionBar", key, "Alpha" }, min = 0, max = 1, step = 0.05, apply = apply, dependsOn = dep },
		{ kind = "check", label = L["Mouseover Only"], path = { "ActionBar", key, "Mouseover" }, apply = apply, dependsOn = dep },
		{ kind = "check", label = L["Fade Out Of Combat"], path = { "ActionBar", key, "FadeCombat" }, apply = apply, dependsOn = dep, tooltip = L["Fade the bar while out of combat and show it the moment a fight starts."] },
		{ kind = "check", label = L["Show Hotkey"], path = { "ActionBar", key, "HotKey" }, apply = apply, dependsOn = dep },
		{ kind = "check", label = L["Show Macro Name"], path = { "ActionBar", key, "MacroName" }, apply = apply, dependsOn = dep },
		{ kind = "check", label = L["Show Count"], path = { "ActionBar", key, "Count" }, apply = apply, dependsOn = dep },
	}
end

-- Concatenate several control lists into one.
local function Join(...)
	local out = {}
	for i = 1, select("#", ...) do
		for _, control in ipairs((select(i, ...))) do
			out[#out + 1] = control
		end
	end
	return out
end

-- An "open flyout" button for one bar. The panel is built lazily so the bar's
-- controls only exist once the user opens it.
local function BarButton(title, key)
	return {
		kind = "extra",
		label = title,
		name = "ActionBar_" .. key,
		title = title,
		build = function(child)
			K.GUI.LayoutControls(child, BarControls(key))
		end,
	}
end

-- Generic flyout button: opens a panel laid out from a fixed control list.
local function ExtraButton(title, name, controls)
	return {
		kind = "extra",
		label = title,
		name = name,
		title = title,
		build = function(child)
			K.GUI.LayoutControls(child, controls)
		end,
	}
end

-- Re-apply the custom colour tables and recolour every live frame so a picker
-- change shows immediately without a reload.
local function ApplyUnitColors()
	if K.ApplyUnitColors then
		K.ApplyUnitColors()
	end
	local uf = K:GetModule("UnitFrames", true)
	if uf and uf.all then
		for _, frame in ipairs(uf.all) do
			if frame.UpdateAllElements then
				frame:UpdateAllElements("KKUI_ColorUpdate")
			end
		end
	end
end

-- Colour pickers for the power and reaction palette.
local function ColorControls()
	local list = { { kind = "header", label = L["Power Colors"] } }
	local powers = {
		{ "MANA", L["Mana"] }, { "RAGE", L["Rage"] }, { "ENERGY", L["Energy"] },
		{ "FOCUS", L["Focus"] }, { "RUNIC_POWER", L["Runic Power"] },
		{ "LUNAR_POWER", L["Lunar Power"] }, { "MAELSTROM", L["Maelstrom"] },
		{ "INSANITY", L["Insanity"] }, { "FURY", L["Fury"] }, { "PAIN", L["Pain"] },
	}
	for _, p in ipairs(powers) do
		list[#list + 1] = { kind = "color", label = p[2], path = { "Unitframe", "PowerColors", p[1] }, apply = ApplyUnitColors }
	end

	list[#list + 1] = { kind = "header", label = L["Reaction Colors"] }
	local reactions = {
		{ 2, L["Hostile"] }, { 3, L["Unfriendly"] }, { 4, L["Neutral"] },
		{ 5, L["Friendly"] }, { 8, L["Exalted"] },
	}
	for _, r in ipairs(reactions) do
		list[#list + 1] = { kind = "color", label = r[2], path = { "Unitframe", "ReactionColors", r[1] }, apply = ApplyUnitColors }
	end
	return list
end

-- Controls for one unit. opts flags which optional rows apply. Everything below
-- the enable toggle greys out when the unit is disabled.
local function UnitControls(key, opts)
	opts = opts or {}
	local dep = { "Unitframe", key, "Enable" }
	local controls = {
		{ kind = "check", label = L["Enable"], path = { "Unitframe", key, "Enable" }, reload = true },
		{ kind = "slider", label = L["Width"], path = { "Unitframe", key, "Width" }, min = 60, max = 340, step = 2, reload = true, dependsOn = dep },
		{ kind = "slider", label = L["Health Height"], path = { "Unitframe", key, "Height" }, min = 12, max = 80, step = 1, reload = true, dependsOn = dep },
	}

	local function Add(control)
		controls[#controls + 1] = control
	end

	if opts.power then
		Add({ kind = "check", label = L["Show Power Bar"], path = { "Unitframe", key, "ShowPower" }, reload = true, dependsOn = dep, tooltip = L["Hide the power bar for this frame and let the health bar fill the space."] })
		Add({ kind = "slider", label = L["Power Height"], path = { "Unitframe", key, "PowerHeight" }, min = 0, max = 30, step = 1, reload = true, dependsOn = dep })
	end
	if opts.powerMode then
		Add({ kind = "dropdown", label = L["Power Bar"], path = { "Unitframe", key, "PowerMode" }, options = {
			{ text = L["All Powers"], value = "All" },
			{ text = L["Mana Only"], value = "Mana" },
			{ text = L["None"], value = "None" },
		}, reload = true, dependsOn = dep })
		Add({ kind = "slider", label = L["Power Spacing"], path = { "Unitframe", key, "PowerGap" }, min = 0, max = 12, step = 1, reload = true, dependsOn = dep })
	end
	if opts.buffs then
		Add({ kind = "check", label = L["Show Buffs"], path = { "Unitframe", key, "Buffs" }, reload = true, dependsOn = dep })
	end
	if opts.debuffs then
		Add({ kind = "check", label = L["Show Debuffs"], path = { "Unitframe", key, "Debuffs" }, reload = true, dependsOn = dep })
	end
	if opts.portrait then
		Add({ kind = "check", label = L["Show Portrait"], path = { "Unitframe", key, "Portrait" }, reload = true, dependsOn = dep })
	end
	if opts.raidStyle then
		Add({ kind = "check", label = L["Raid-Style Frames"], path = { "Unitframe", key, "RaidStyle" }, reload = true, dependsOn = dep, tooltip = L["Use compact raid frames for the party: five healing frames that match the raid look and use the raid settings."] })
	end
	if opts.name then
		Add({ kind = "check", label = L["Show Name"], path = { "Unitframe", key, "ShowName" }, reload = true, dependsOn = dep })
	end
	if opts.classPower then
		Add({ kind = "check", label = L["Show Class Resource"], path = { "Unitframe", key, "ClassPower" }, reload = true, dependsOn = dep, tooltip = L["Combo points, runes, chi, soul shards, and the monk stagger bar."] })
		Add({ kind = "check", label = L["Show Additional Power"], path = { "Unitframe", key, "AdditionalPower" }, reload = true, dependsOn = dep, tooltip = L["The mana strip druids keep while shapeshifted."] })
	end
	if opts.showSolo then
		Add({ kind = "check", label = L["Show While Solo"], path = { "Unitframe", key, "ShowSolo" }, reload = true, dependsOn = dep })
	end
	if opts.showPlayer then
		Add({ kind = "check", label = L["Show Player"], path = { "Unitframe", key, "ShowPlayer" }, reload = true, dependsOn = dep, tooltip = L["Include your own frame in the party. Turn off if your player frame is enough."] })
	end
	if opts.dispelHighlight then
		Add({ kind = "check", label = L["Dispel Highlight"], path = { "Unitframe", key, "DispelHighlight" }, reload = true, dependsOn = dep, tooltip = L["Colour the border of any member with a debuff you can dispel."] })
	end
	if opts.groupsPerRow then
		Add({ kind = "slider", label = L["Groups Per Row"], path = { "Unitframe", key, "GroupsPerRow" }, min = 1, max = 8, step = 1, reload = true, dependsOn = dep })
	end
	if opts.groupBy then
		Add({ kind = "dropdown", label = L["Group By"], path = { "Unitframe", key, "GroupBy" }, options = {
			{ text = L["Group"], value = "GROUP" },
			{ text = L["Class"], value = "CLASS" },
			{ text = L["Role"], value = "ROLE" },
		}, reload = true, dependsOn = dep })
	end
	if opts.groupNumber then
		Add({ kind = "check", label = L["Show Group Numbers"], path = { "Unitframe", key, "ShowGroupNumber" }, reload = true, dependsOn = dep })
	end
	if opts.raidLayout then
		Add({ kind = "check", label = L["Raid-Wide Sorting"], path = { "Unitframe", key, "RaidWide" }, reload = true, dependsOn = dep, tooltip = L["Sort the whole raid as one list spread across the columns, instead of one column per group."] })
		Add({ kind = "dropdown", label = L["Sort Direction"], path = { "Unitframe", key, "SortDirection" }, options = {
			{ text = L["Ascending"], value = "ASC" },
			{ text = L["Descending"], value = "DESC" },
		}, reload = true, dependsOn = dep })
		Add({ kind = "dropdown", label = L["Growth Direction"], path = { "Unitframe", key, "Orientation" }, options = {
			{ text = L["Down, then Right"], value = "DOWN_RIGHT" },
			{ text = L["Down, then Left"], value = "DOWN_LEFT" },
			{ text = L["Up, then Right"], value = "UP_RIGHT" },
			{ text = L["Up, then Left"], value = "UP_LEFT" },
		}, reload = true, dependsOn = dep })
	end
	if opts.spacing then
		Add({ kind = "slider", label = L["Frame Spacing"], path = { "Unitframe", key, "Spacing" }, min = 10, max = 80, step = 1, reload = true, dependsOn = dep })
	end
	if opts.castbar then
		Add({ kind = "check", label = L["Show Castbar"], path = { "Unitframe", key, "Castbar" }, reload = true, dependsOn = dep })
	end

	return controls
end

GUI.schema = {
	{
		name = "General",
		icon = "Interface/ICONS/Achievement_General",
		title = L["General"],
		columns = 2,
		controls = {
			{ kind = "header", label = L["Interface"] },
			{ kind = "check", label = L["Auto UI Scale"], path = { "General", "AutoScale" }, reload = true },
			{ kind = "slider", label = L["UI Scale"], path = { "General", "UIScale" }, min = 0.4, max = 1.15, step = 0.01, reload = true },
			{ kind = "dropdown", label = L["Font"], path = { "General", "Font" }, options = MediaOptions(C.Media.Fonts), reload = true },
			{ kind = "check", label = L["Font Outline"], path = { "General", "FontOutline" }, reload = true },
			{ kind = "check", label = L["Welcome Message"], path = { "General", "WelcomeMessage" } },
			{ kind = "button", label = L["Report a Bug"], onClick = function()
				if K.GUI and K.GUI.Hide then
					K.GUI.Hide()
				end
				if K.ToggleBugReport then
					K.ToggleBugReport()
				end
			end },
			{ kind = "header", label = L["Placement"] },
			{ kind = "description", label = L["Unlock the UI to drag frames around. Hover a frame and use the arrow keys to nudge it one pixel at a time."] },
			{ kind = "button", label = L["Move UI"], onClick = function()
				K.GUI.Hide()
				K.ToggleMovers(true)
			end },
			{ kind = "button", label = L["Reset Positions"], onClick = function()
				K.ResetMovers()
			end },
			{ kind = "header", label = L["Border"] },
			{ kind = "dropdown", label = L["Border Style"], path = { "General", "BorderStyle" }, options = MediaOptions(C.Media.Borders), reload = true },
			{ kind = "color", label = L["Border Color"], path = { "General", "BorderColor" }, apply = function()
				K.RefreshBorderColors()
			end },
		},
	},

	{
		name = "ActionBar",
		icon = "Interface/ICONS/INV_Misc_Book_09",
		title = L["Action Bars"],
		controls = Join({
			{ kind = "header", label = L["Global"] },
			{ kind = "check", label = L["Enable Action Bars"], path = { "ActionBar", "Enable" }, reload = true },
			{ kind = "check", label = L["Show Empty Button Grid"], path = { "ActionBar", "ShowGrid" }, reload = true },
			{ kind = "check", label = L["Cooldown Count"], path = { "ActionBar", "Cooldowns" }, reload = true },
			{ kind = "check", label = L["Cast On Key Down"], path = { "ActionBar", "KeyDown" }, reload = true, tooltip = L["Fire actions on key press instead of on release."] },
			{ kind = "dropdown", label = L["Out of Range"], path = { "ActionBar", "RangeColoring" }, options = {
				{ text = L["Whole Button"], value = "button" },
				{ text = L["Hotkey Only"], value = "hotkey" },
				{ text = L["None"], value = "none" },
			}, apply = ApplyAllBars, tooltip = L["How a button shows an ability that is out of range."] },
			{ kind = "dropdown", label = L["Proc Glow"], path = { "ActionBar", "ProcGlow" }, reload = true, options = {
				{ text = L["Pixel"], value = "Pixel" },
				{ text = L["Autocast Shine"], value = "Autocast" },
				{ text = L["Blizzard Default"], value = "Default" },
			}, tooltip = L["The glow shown when an ability procs."] },
			{ kind = "header", label = L["Button Text"] },
			{ kind = "dropdown", label = L["Font"], path = { "ActionBar", "Font" }, options = MediaOptions(C.Media.Fonts), apply = ApplyAllBars },
			{ kind = "slider", label = L["Font Size"], path = { "ActionBar", "FontSize" }, min = 8, max = 24, step = 1, apply = ApplyAllBars },
			{ kind = "dropdown", label = L["Font Outline"], path = { "ActionBar", "FontFlag" }, options = {
				{ text = L["None"], value = "NONE" },
				{ text = L["Outline"], value = "OUTLINE" },
				{ text = L["Thick Outline"], value = "THICKOUTLINE" },
			}, apply = ApplyAllBars },
			{ kind = "header", label = L["Configure Each Bar"] },
			BarButton(L["Bar 1 (Main)"], "Bar1"),
			BarButton(L["Bar 2 (Bottom)"], "Bar2"),
			BarButton(L["Bar 3 (Right)"], "Bar3"),
			BarButton(L["Bar 4 (Right)"], "Bar4"),
			BarButton(L["Bar 5 (Left)"], "Bar5"),
			BarButton(L["Bar 6"], "Bar6"),
			BarButton(L["Bar 7"], "Bar7"),
			BarButton(L["Bar 8"], "Bar8"),
			{ kind = "header", label = L["Extra Bars"] },
			{ kind = "check", label = L["Enable Pet Bar"], path = { "ActionBar", "PetBar", "Enable" }, reload = true },
			{ kind = "check", label = L["Enable Stance Bar"], path = { "ActionBar", "StanceBar", "Enable" }, reload = true },
			{ kind = "check", label = L["Enable Extra Buttons"], path = { "ActionBar", "ExtraBar", "Enable" }, reload = true },
		}),
	},

	{
		name = "Unitframe",
		icon = "Interface/ICONS/Achievement_Character_Human_Male",
		title = L["Unit Frames"],
		controls = {
			{ kind = "header", label = L["Global"] },
			{ kind = "check", label = L["Enable Unit Frames"], path = { "Unitframe", "Enable" }, reload = true },
			{ kind = "dropdown", label = L["Status Bar Texture"], path = { "Unitframe", "Texture" }, options = MediaOptions(C.Media.Statusbars), reload = true },
			{ kind = "check", label = L["Smooth Bar Animation"], path = { "Unitframe", "Smooth" }, reload = true },
			{ kind = "check", label = L["Class Colored Health"], path = { "Unitframe", "ClassHealth" }, reload = true },
			{ kind = "check", label = L["Class Colored Border"], path = { "Unitframe", "ClassColorBorder" }, apply = RefreshHealthBorders, tooltip = L["Threat still takes the border over while you have aggro."] },
			{ kind = "check", label = L["Threat Health Color"], path = { "Unitframe", "ThreatHealthColor" }, reload = true, tooltip = L["Colour enemy health bars by your threat, role-aware, instead of by reaction."] },
			{ kind = "check", label = L["Colored Bar Backdrop"], path = { "Unitframe", "BarBackdrop" }, reload = true, tooltip = L["Tints the empty part of a bar with a dark version of its colour, so a nearly dead unit still reads at a glance."] },
			{ kind = "check", label = L["Heal Prediction"], path = { "Unitframe", "HealthPrediction" }, reload = true, tooltip = L["Shows incoming heals and absorb shields on the health bar."] },
			{ kind = "check", label = L["Range Fade"], path = { "Unitframe", "RangeFade" }, reload = true, tooltip = L["Dim units that are out of range."] },
			{ kind = "slider", label = L["Range Fade Alpha"], path = { "Unitframe", "RangeAlpha" }, min = 0.1, max = 0.9, step = 0.05, reload = true, dependsOn = { "Unitframe", "RangeFade" } },
			{ kind = "check", label = L["Group Dispel Debuffs Only"], path = { "Unitframe", "GroupDispelOnly" }, reload = true, tooltip = L["On party and raid frames show only debuffs you can dispel, plus boss mechanics."] },
			{ kind = "check", label = L["Aura Watch"], path = { "Unitframe", "AuraWatch" }, reload = true, tooltip = L["Corner dots on party and raid frames that light up for your class heals over time."] },

			{ kind = "header", label = L["Text"] },
			{ kind = "dropdown", label = L["Health Text"], path = { "Unitframe", "HealthFormat" }, options = TEXT_FORMATS, reload = true },
			{ kind = "dropdown", label = L["Power Text"], path = { "Unitframe", "PowerFormat" }, options = TEXT_FORMATS, reload = true },
			{ kind = "check", label = L["Colored Names"], path = { "Unitframe", "NameColor" }, apply = RefreshTags("kkui:namecolor"), tooltip = L["Class colour for players, reaction colour for everything else."] },
			{ kind = "slider", label = L["Name Length"], path = { "Unitframe", "NameLength" }, min = 0, max = 30, step = 1, apply = RefreshTags("kkui:name"), tooltip = L["Zero shows the full name."] },

			{ kind = "header", label = L["Portrait"] },
			{ kind = "check", label = L["Show Portrait"], path = { "Unitframe", "Portrait" }, reload = true },
			{ kind = "dropdown", label = L["Portrait Style"], path = { "Unitframe", "PortraitStyle" }, options = {
				{ text = L["3D Model"], value = "3D" },
				{ text = L["2D Portrait"], value = "2D" },
				{ text = L["Class Icon"], value = "Class" },
			}, reload = true, dependsOn = { "Unitframe", "Portrait" } },

			{ kind = "header", label = L["Configure Units"] },
			ExtraButton(L["Frame Colors"], "UF_Colors", ColorControls()),
			{ kind = "extra", label = L["Aura Filters"], name = "UF_AuraFilters", title = L["Aura Filters"], build = function(child)
				K.GUI.CustomPanels.AuraFilters(child)
			end },
			ExtraButton(L["Player"], "UF_Player", UnitControls("Player", { power = true, buffs = true, debuffs = true, classPower = true, name = true })),
			ExtraButton(L["Target"], "UF_Target", UnitControls("Target", { power = true, buffs = true, debuffs = true })),
			ExtraButton(L["Focus"], "UF_Focus", UnitControls("Focus", { power = true, debuffs = true })),
			ExtraButton(L["Target of Target"], "UF_ToT", UnitControls("TargetOfTarget", { power = true })),
			ExtraButton(L["Focus Target"], "UF_FocusTarget", UnitControls("FocusTarget", { power = true })),
			ExtraButton(L["Pet"], "UF_Pet", UnitControls("Pet", { power = true, debuffs = true })),
			ExtraButton(L["Party"], "UF_Party", UnitControls("Party", { power = true, debuffs = true, portrait = true, showSolo = true, showPlayer = true, dispelHighlight = true, castbar = true, raidStyle = true })),
			ExtraButton(L["Raid"], "UF_Raid", UnitControls("Raid", { power = true, powerMode = true, groupsPerRow = true, groupBy = true, groupNumber = true, raidLayout = true, dispelHighlight = true })),
			{ kind = "button", label = L["Toggle Test Frames"], onClick = function()
				local uf = K:GetModule("UnitFrames", true)
				if uf and uf.ToggleTest then
					uf:ToggleTest()
				end
			end },
			ExtraButton(L["Boss"], "UF_Boss", UnitControls("Boss", { power = true, debuffs = true, spacing = true, castbar = true, portrait = true })),

			{ kind = "header", label = L["Elements"] },
			ExtraButton(L["Auras"], "UF_Auras", {
				{ kind = "slider", label = L["Buff Size"], path = { "Unitframe", "Auras", "BuffSize" }, min = 16, max = 40, step = 1, reload = true },
				{ kind = "slider", label = L["Debuff Size"], path = { "Unitframe", "Auras", "DebuffSize" }, min = 16, max = 40, step = 1, reload = true },
				{ kind = "slider", label = L["Auras Per Row"], path = { "Unitframe", "Auras", "PerRow" }, min = 3, max = 12, step = 1, reload = true },
				{ kind = "slider", label = L["Aura Spacing"], path = { "Unitframe", "Auras", "Spacing" }, min = 0, max = 12, step = 1, reload = true },
				{ kind = "slider", label = L["Max Buffs"], path = { "Unitframe", "Auras", "NumBuffs" }, min = 1, max = 40, step = 1, reload = true },
				{ kind = "slider", label = L["Max Debuffs"], path = { "Unitframe", "Auras", "NumDebuffs" }, min = 1, max = 40, step = 1, reload = true },
				{ kind = "check", label = L["Only My Debuffs"], path = { "Unitframe", "Auras", "OnlyPlayerDebuffs" }, reload = true },
			}),
			ExtraButton(L["Class Resource"], "UF_ClassPower", {
				{ kind = "slider", label = L["Height"], path = { "Unitframe", "ClassPower", "Height" }, min = 6, max = 30, step = 1, reload = true },
				{ kind = "slider", label = L["Segment Spacing"], path = { "Unitframe", "ClassPower", "Spacing" }, min = 0, max = 12, step = 1, reload = true },
			}),
			ExtraButton(L["Castbar"], "UF_Castbar", {
				{ kind = "check", label = L["Enable Castbar"], path = { "Unitframe", "Castbar", "Enable" }, reload = true },
				{ kind = "check", label = L["Show Cast Icon"], path = { "Unitframe", "Castbar", "ShowIcon" }, reload = true, dependsOn = CASTBAR_DEP },
				{ kind = "check", label = L["Show Cast Timer"], path = { "Unitframe", "Castbar", "ShowTimer" }, reload = true, dependsOn = CASTBAR_DEP },
				{ kind = "check", label = L["Show Spark"], path = { "Unitframe", "Castbar", "ShowSpark" }, reload = true, dependsOn = CASTBAR_DEP },
				{ kind = "check", label = L["Show Latency"], path = { "Unitframe", "Castbar", "ShowLatency" }, reload = true, dependsOn = CASTBAR_DEP, tooltip = L["Marks the window at the end of a cast where your spell is already on its way."] },
				{ kind = "slider", label = L["Hold On Finish"], path = { "Unitframe", "Castbar", "TimeToHold" }, min = 0, max = 2, step = 0.1, reload = true, dependsOn = CASTBAR_DEP, tooltip = L["Seconds an interrupted or failed cast stays on screen."] },
				{ kind = "header", label = L["Player"] },
				{ kind = "slider", label = L["Width"], path = { "Unitframe", "Castbar", "PlayerWidth" }, min = 120, max = 500, step = 2, reload = true, dependsOn = CASTBAR_DEP },
				{ kind = "slider", label = L["Height"], path = { "Unitframe", "Castbar", "PlayerHeight" }, min = 12, max = 50, step = 1, reload = true, dependsOn = CASTBAR_DEP },
				{ kind = "header", label = L["Target"] },
				{ kind = "slider", label = L["Width"], path = { "Unitframe", "Castbar", "TargetWidth" }, min = 120, max = 500, step = 2, reload = true, dependsOn = CASTBAR_DEP },
				{ kind = "slider", label = L["Height"], path = { "Unitframe", "Castbar", "TargetHeight" }, min = 12, max = 50, step = 1, reload = true, dependsOn = CASTBAR_DEP },
				{ kind = "header", label = L["Focus"] },
				{ kind = "slider", label = L["Width"], path = { "Unitframe", "Castbar", "FocusWidth" }, min = 120, max = 500, step = 2, reload = true, dependsOn = CASTBAR_DEP },
				{ kind = "slider", label = L["Height"], path = { "Unitframe", "Castbar", "FocusHeight" }, min = 12, max = 50, step = 1, reload = true, dependsOn = CASTBAR_DEP },
			}),
		},
	},

	{
		name = "Minimap",
		icon = "Interface/ICONS/INV_Misc_Map_01",
		title = L["Minimap"],
		controls = {
			{ kind = "header", label = L["Minimap"] },
			{ kind = "check", label = L["Enable Minimap"], path = { "Minimap", "Enable" }, reload = true },
			{ kind = "slider", label = L["Size"], path = { "Minimap", "Size" }, min = 120, max = 300, step = 2, reload = true, dependsOn = { "Minimap", "Enable" } },
			{ kind = "check", label = L["Square Shape"], path = { "Minimap", "Square" }, reload = true, dependsOn = { "Minimap", "Enable" } },
			{ kind = "check", label = L["Show Border"], path = { "Minimap", "ShowBorder" }, reload = true, dependsOn = { "Minimap", "Enable" } },
			{ kind = "check", label = L["Fade Until Hover"], path = { "Minimap", "MouseoverFade" }, reload = true, dependsOn = { "Minimap", "Enable" }, tooltip = L["Fade the minimap out while you are not hovering it."] },
			{ kind = "slider", label = L["Faded Alpha"], path = { "Minimap", "FadeAlpha" }, min = 0, max = 0.9, step = 0.05, reload = true, dependsOn = { "Minimap", "MouseoverFade" } },
			{ kind = "check", label = L["Show Zone Text"], path = { "Minimap", "ShowLocation" }, reload = true, dependsOn = { "Minimap", "Enable" } },
			{ kind = "slider", label = L["Zone Text Size"], path = { "Minimap", "LocationFontSize" }, min = 8, max = 20, step = 1, reload = true, dependsOn = { "Minimap", "ShowLocation" } },
			{ kind = "check", label = L["Show Clock"], path = { "Minimap", "ShowClock" }, reload = true, dependsOn = { "Minimap", "Enable" } },
			{ kind = "slider", label = L["Clock Text Size"], path = { "Minimap", "ClockFontSize" }, min = 8, max = 20, step = 1, reload = true, dependsOn = { "Minimap", "ShowClock" } },
			{ kind = "check", label = L["Collect Minimap Buttons"], path = { "Minimap", "CollectButtons" }, reload = true, dependsOn = { "Minimap", "Enable" } },
				{ kind = "dropdown", label = L["Button Collector Corner"], path = { "Minimap", "ButtonCorner" }, options = {
					{ text = L["Bottom Left"], value = "BOTTOMLEFT" },
					{ text = L["Bottom Right"], value = "BOTTOMRIGHT" },
					{ text = L["Top Left"], value = "TOPLEFT" },
					{ text = L["Top Right"], value = "TOPRIGHT" },
				}, reload = true, dependsOn = { "Minimap", "CollectButtons" }, tooltip = L["Which corner of the minimap the button-collector dot sits in."] },

				{ kind = "header", label = L["World Map"] },
				{ kind = "check", label = L["Enable World Map Tweaks"], path = { "WorldMap", "Enable" }, reload = true, tooltip = L["Shrink the maximized world map and show coordinates."] },
				{ kind = "check", label = L["Smaller World Map"], path = { "WorldMap", "SmallerMap" }, reload = true, dependsOn = { "WorldMap", "Enable" }, tooltip = L["Scale the maximized map down so it no longer covers the whole screen."] },
				{ kind = "slider", label = L["Map Scale"], path = { "WorldMap", "Scale" }, min = 0.6, max = 1, step = 0.05, reload = true, dependsOn = { "WorldMap", "Enable" } },
				{ kind = "check", label = L["Map Coordinates"], path = { "WorldMap", "Coordinates" }, reload = true, dependsOn = { "WorldMap", "Enable" }, tooltip = L["Show player and cursor coordinates in a corner of the map."] },
				{ kind = "dropdown", label = L["Coordinate Position"], path = { "WorldMap", "CoordPosition" }, options = {
					{ text = L["Bottom Left"], value = "BOTTOMLEFT" },
					{ text = L["Bottom Right"], value = "BOTTOMRIGHT" },
					{ text = L["Top Left"], value = "TOPLEFT" },
					{ text = L["Top Right"], value = "TOPRIGHT" },
				}, reload = true, dependsOn = { "WorldMap", "Enable" } },
				{ kind = "check", label = L["Map Reveal"], path = { "WorldMap", "Reveal" }, reload = true, dependsOn = { "WorldMap", "Enable" }, tooltip = L["Draw the parts of a zone you have not explored yet. Also toggleable from a checkbox on the map itself."] },
				{ kind = "check", label = L["Dim Revealed Areas"], path = { "WorldMap", "RevealDim" }, reload = true, dependsOn = { "WorldMap", "Reveal" }, tooltip = L["Shade the revealed areas so the ground you have actually explored still stands out."] },
		},
	},

	{
		name = "Auras",
		icon = "Interface/ICONS/Spell_Nature_MoonGlow",
		title = L["Buffs & Debuffs"],
		controls = {
			{ kind = "header", label = L["Player Auras"] },
			{ kind = "check", label = L["Enable Buffs & Debuffs"], path = { "Auras", "Enable" }, reload = true },
			{ kind = "slider", label = L["Buff Size"], path = { "Auras", "BuffSize" }, min = 20, max = 44, step = 1, reload = true, dependsOn = { "Auras", "Enable" } },
			{ kind = "slider", label = L["Debuff Size"], path = { "Auras", "DebuffSize" }, min = 20, max = 44, step = 1, reload = true, dependsOn = { "Auras", "Enable" } },
			{ kind = "slider", label = L["Per Row"], path = { "Auras", "PerRow" }, min = 4, max = 16, step = 1, reload = true, dependsOn = { "Auras", "Enable" } },
			{ kind = "slider", label = L["Spacing"], path = { "Auras", "Spacing" }, min = 0, max = 12, step = 1, reload = true, dependsOn = { "Auras", "Enable" } },
				{ kind = "check", label = L["Show Weapon Enchants"], path = { "Auras", "WeaponEnchant" }, reload = true, dependsOn = { "Auras", "Enable" } },
		},
	},

	{
		name = "Cooldown",
		icon = "Interface/ICONS/Spell_Holy_BorrowedTime",
		title = L["Cooldowns"],
		controls = {
			{ kind = "header", label = L["Cooldown Text"] },
			{ kind = "check", label = L["Enable Cooldown Text"], path = { "Cooldown", "Enable" }, reload = true, tooltip = L["Show Blizzard's countdown numbers on cooldowns. On 12.1 the duration is a protected value, so these native numbers are the only ones that can display it."] },
		},
	},

	{
		name = "Chat",
		icon = "Interface/ICONS/UI_Chat",
		title = L["Chat"],
		controls = {
			{ kind = "header", label = L["Chat"] },
			{ kind = "check", label = L["Enable Chat Skin"], path = { "Chat", "Enable" }, reload = true },
			{ kind = "slider", label = L["Font Size"], path = { "Chat", "FontSize" }, min = 10, max = 20, step = 1, reload = true, dependsOn = { "Chat", "Enable" } },
			{ kind = "check", label = L["Font Outline"], path = { "Chat", "FontOutline" }, reload = true, dependsOn = { "Chat", "Enable" } },
			{ kind = "check", label = L["Mouse Wheel Scroll"], path = { "Chat", "MouseWheelScroll" }, reload = true, dependsOn = { "Chat", "Enable" } },
			{ kind = "check", label = L["Sticky Whisper"], path = { "Chat", "StickyWhisper" }, reload = true, dependsOn = { "Chat", "Enable" }, tooltip = L["Keep the edit box on whisper after replying."] },
			{ kind = "check", label = L["Whisper Sound"], path = { "Chat", "WhisperSound" }, reload = true, dependsOn = { "Chat", "Enable" }, tooltip = L["Play a sound when you receive a whisper."] },
			{ kind = "check", label = L["Skin Chat Bubbles"], path = { "Chat", "SkinBubbles" }, reload = true, dependsOn = { "Chat", "Enable" }, tooltip = L["Give the in-world chat bubbles our border and dark background."] },
			{ kind = "check", label = L["Shorten Channel Names"], path = { "Chat", "ShortenChannels" }, reload = true, dependsOn = { "Chat", "Enable" } },
			{ kind = "check", label = L["Class Colored Names"], path = { "Chat", "ClassColorNames" }, reload = true, dependsOn = { "Chat", "Enable" } },
			{ kind = "check", label = L["Clickable URLs"], path = { "Chat", "URLLinks" }, reload = true, dependsOn = { "Chat", "Enable" } },
			{ kind = "check", label = L["Hyperlink Hover Tooltips"], path = { "Chat", "HyperlinkTooltip" }, reload = true, dependsOn = { "Chat", "Enable" } },
			{ kind = "check", label = L["Channel Quick Bar"], path = { "Chat", "ChatBar" }, reload = true, dependsOn = { "Chat", "Enable" } },
			{ kind = "check", label = L["Side Button Strip"], path = { "Chat", "SideButtons" }, reload = true, dependsOn = { "Chat", "Enable" }, tooltip = L["A fading column of icon buttons on the left of the chat for channels, copy, scroll, and config."] },
			{ kind = "check", label = L["Repeat Spam Filter"], path = { "Chat", "SpamFilter" }, reload = true, dependsOn = { "Chat", "Enable" }, tooltip = L["Drop identical messages repeated in public channels within 30 seconds."] },
			{ kind = "check", label = L["Gradient Backdrop"], path = { "Chat", "GradientBackdrop" }, reload = true, dependsOn = { "Chat", "Enable" }, tooltip = L["A soft class-colored fade behind the chat that fades out to the right."] },
			{ kind = "check", label = L["Copy Button"], path = { "Chat", "CopyButton" }, reload = true, dependsOn = { "Chat", "Enable" } },
			{ kind = "check", label = L["Timestamps"], path = { "Chat", "Timestamps" }, reload = true, dependsOn = { "Chat", "Enable" } },
			{ kind = "check", label = L["Highlight Keywords"], path = { "Chat", "KeywordHighlight" }, dependsOn = { "Chat", "Enable" }, tooltip = L["Colour your name and any keywords you set wherever they appear in chat."] },
			{ kind = "editbox", label = L["Extra Keywords"], path = { "Chat", "KeywordList" }, dependsOn = { "Chat", "KeywordHighlight" }, tooltip = L["Comma separated words to watch for. Your name is always watched."], apply = function()
				local m = K:GetModule("Chat")
				if m and m.RefreshKeywords then
					m:RefreshKeywords()
				end
			end },
			{ kind = "color", label = L["Keyword Color"], path = { "Chat", "KeywordColor" }, dependsOn = { "Chat", "KeywordHighlight" } },
			{ kind = "check", label = L["Keyword Sound"], path = { "Chat", "KeywordSound" }, dependsOn = { "Chat", "KeywordHighlight" }, tooltip = L["Play a short sound when a keyword is mentioned."] },
			{ kind = "check", label = L["Keyword Count Badge"], path = { "Chat", "KeywordCount" }, reload = true, dependsOn = { "Chat", "KeywordHighlight" }, tooltip = L["Show a badge counting unread keyword mentions in the corner of the chat."] },
			{ kind = "check", label = L["Fade Inactive Chat"], path = { "Chat", "Fade" }, reload = true, dependsOn = { "Chat", "Enable" } },
			{ kind = "slider", label = L["Fade Time"], path = { "Chat", "FadeTime" }, min = 5, max = 60, step = 5, reload = true, dependsOn = { "Chat", "Fade" } },
		},
	},

	{
		name = "Nameplate",
		icon = "Interface/ICONS/Ability_Hunter_SniperShot",
		title = L["Nameplates"],
		controls = {
			{ kind = "header", label = L["Nameplates"] },
			{ kind = "check", label = L["Enable Nameplates"], path = { "Nameplate", "Enable" }, reload = true },
			{ kind = "slider", label = L["Width"], path = { "Nameplate", "Width" }, min = 80, max = 240, step = 2, reload = true, dependsOn = { "Nameplate", "Enable" } },
			{ kind = "slider", label = L["Height"], path = { "Nameplate", "Height" }, min = 6, max = 30, step = 1, reload = true, dependsOn = { "Nameplate", "Enable" } },
			{ kind = "slider", label = L["Name Size"], path = { "Nameplate", "NameSize" }, min = 8, max = 20, step = 1, reload = true, dependsOn = { "Nameplate", "Enable" } },
			{ kind = "slider", label = L["View Distance"], path = { "Nameplate", "MaxDistance" }, min = 20, max = 100, step = 5, reload = true, dependsOn = { "Nameplate", "Enable" } },
			{ kind = "header", label = L["Elements"] },
			{ kind = "check", label = L["Class Colored Health"], path = { "Nameplate", "ClassColor" }, reload = true, dependsOn = { "Nameplate", "Enable" } },
			{ kind = "check", label = L["Health Percent Text"], path = { "Nameplate", "ShowHealthText" }, reload = true, dependsOn = { "Nameplate", "Enable" } },
			{ kind = "check", label = L["Quest Icon"], path = { "Nameplate", "ShowQuestIcon" }, reload = true, dependsOn = { "Nameplate", "Enable" } },
			{ kind = "check", label = L["Show Party Quests"], path = { "Nameplate", "QuestShowParty" }, dependsOn = { "Nameplate", "ShowQuestIcon" }, tooltip = L["Also mark NPCs on a party member's quest (the icon is greyed)."] },
			{ kind = "check", label = L["Progress On Target Only"], path = { "Nameplate", "QuestProgressOnTarget" }, dependsOn = { "Nameplate", "ShowQuestIcon" }, tooltip = L["Only show the objective progress text on your current target."] },
			{ kind = "dropdown", label = L["Progress Format"], path = { "Nameplate", "QuestProgressFormat" }, dependsOn = { "Nameplate", "ShowQuestIcon" }, options = {
				{ text = L["Completed (3/7)"], value = "Completed" },
				{ text = L["Remaining (4)"], value = "Remaining" },
			} },
			{ kind = "check", label = L["Elite / Rare / Boss Icon"], path = { "Nameplate", "ShowClassification" }, reload = true, dependsOn = { "Nameplate", "Enable" } },
			{ kind = "check", label = L["Friendly Name Only"], path = { "Nameplate", "FriendlyNameOnly" }, reload = true, dependsOn = { "Nameplate", "Enable" }, tooltip = L["Hide the health bar on friendly units, showing just the name."] },
			{ kind = "check", label = L["Guild Name (name-only)"], path = { "Nameplate", "ShowGuildName" }, reload = true, dependsOn = { "Nameplate", "FriendlyNameOnly" }, tooltip = L["Show a player's guild under their name in name-only mode."] },
			{ kind = "check", label = L["Threat Coloring"], path = { "Nameplate", "ThreatColor" }, reload = true, dependsOn = { "Nameplate", "Enable" }, tooltip = L["Tint the plate shadow by your threat: holding, losing, or pulling aggro."] },
			{ kind = "check", label = L["Threat Health Color"], path = { "Nameplate", "ThreatHealthColor" }, reload = true, dependsOn = { "Nameplate", "Enable" }, tooltip = L["Colour the enemy health bar itself by your threat, role-aware, instead of by reaction."] },
			{ kind = "check", label = L["Role Colors"], path = { "Nameplate", "RoleColors" }, reload = true, dependsOn = { "Nameplate", "Enable" }, tooltip = L["Colour hostile plates by caster or melee so casters stand out. A unit that runs on mana is read as a caster."] },
			{ kind = "color", label = L["Caster Color"], path = { "Nameplate", "CasterColor" }, reload = true, dependsOn = { "Nameplate", "RoleColors" } },
			{ kind = "color", label = L["Melee Color"], path = { "Nameplate", "MeleeColor" }, reload = true, dependsOn = { "Nameplate", "RoleColors" } },
			{ kind = "check", label = L["Target Highlight"], path = { "Nameplate", "TargetHighlight" }, reload = true, dependsOn = { "Nameplate", "Enable" } },
			{ kind = "check", label = L["Target Class Resource"], path = { "Nameplate", "TargetPower" }, reload = true, dependsOn = { "Nameplate", "Enable" }, tooltip = L["Show your combo points / class resource on the target's nameplate."] },
			{ kind = "check", label = L["Show Castbar"], path = { "Nameplate", "ShowCastbar" }, reload = true, dependsOn = { "Nameplate", "Enable" } },
			{ kind = "slider", label = L["Castbar Height"], path = { "Nameplate", "CastbarHeight" }, min = 8, max = 30, step = 1, reload = true, dependsOn = { "Nameplate", "ShowCastbar" } },
			{ kind = "check", label = L["Show Debuffs"], path = { "Nameplate", "ShowDebuffs" }, reload = true, dependsOn = { "Nameplate", "Enable" } },
			{ kind = "check", label = L["Only My Debuffs"], path = { "Nameplate", "OnlyMyDebuffs" }, reload = true, dependsOn = { "Nameplate", "ShowDebuffs" } },
			{ kind = "slider", label = L["Debuff Size"], path = { "Nameplate", "AuraSize" }, min = 16, max = 40, step = 1, reload = true, dependsOn = { "Nameplate", "ShowDebuffs" } },
			{ kind = "slider", label = L["Debuff Spacing"], path = { "Nameplate", "AuraSpacing" }, min = 0, max = 12, step = 1, reload = true, dependsOn = { "Nameplate", "ShowDebuffs" } },
			{ kind = "slider", label = L["Max Debuffs"], path = { "Nameplate", "MaxAuras" }, min = 1, max = 10, step = 1, reload = true, dependsOn = { "Nameplate", "ShowDebuffs" } },
				{ kind = "check", label = L["Show Private Auras"], path = { "Nameplate", "PrivateAuras" }, reload = true, dependsOn = { "Nameplate", "Enable" } },
				{ kind = "slider", label = L["Private Aura Size"], path = { "Nameplate", "PrivateAuraSize" }, min = 16, max = 44, step = 1, reload = true, dependsOn = { "Nameplate", "PrivateAuras" } },

			{ kind = "header", label = L["Custom Unit Colors"] },
			{ kind = "extra", label = L["Custom Unit Colors"], name = "NP_CustomColors", title = L["Custom Unit Colors"], build = function(child)
				K.GUI.CustomPanels.NameplateColors(child)
			end },
		},
	},

	{
		name = "Tooltip",
		icon = "Interface/ICONS/INV_Misc_Note_02",
		title = L["Tooltip"],
		controls = {
			{ kind = "header", label = L["Tooltip"] },
			{ kind = "check", label = L["Enable Tooltip Skin"], path = { "Tooltip", "Enable" }, reload = true },
			{ kind = "check", label = L["Anchor To Cursor"], path = { "Tooltip", "CursorAnchor" }, dependsOn = { "Tooltip", "Enable" } },
			{ kind = "check", label = L["Hide In Combat"], path = { "Tooltip", "HideInCombat" }, dependsOn = { "Tooltip", "Enable" } },
			{ kind = "dropdown", label = L["Health Bar Position"], path = { "Tooltip", "HealthBarPosition" }, options = {
				{ text = L["Top"], value = "TOP" },
				{ text = L["Bottom"], value = "BOTTOM" },
			}, reload = true, dependsOn = { "Tooltip", "Enable" } },
			{ kind = "check", label = L["Health Bar Value"], path = { "Tooltip", "HealthValue" }, dependsOn = { "Tooltip", "Enable" }, tooltip = L["Show the health amount and percent on the tooltip's health bar."] },
			{ kind = "header", label = L["Unit Info"] },
			{ kind = "check", label = L["Class Colored Name"], path = { "Tooltip", "ClassColorName" }, dependsOn = { "Tooltip", "Enable" } },
			{ kind = "check", label = L["Show Realm Name"], path = { "Tooltip", "ShowRealm" }, dependsOn = { "Tooltip", "Enable" }, tooltip = L["Append the realm for players from another realm."] },
			{ kind = "check", label = L["Show Raid Target Icon"], path = { "Tooltip", "ShowRaidIcon" }, dependsOn = { "Tooltip", "Enable" }, tooltip = L["Show the skull/star/etc. marker ahead of a marked unit's name."] },
			{ kind = "check", label = L["Show Faction Icon"], path = { "Tooltip", "ShowFactionIcon" }, dependsOn = { "Tooltip", "Enable" }, tooltip = L["Show a Horde/Alliance crest on the name and hide the faction text line."] },
			{ kind = "check", label = L["Border Color By Unit"], path = { "Tooltip", "BorderColor" }, dependsOn = { "Tooltip", "Enable" }, tooltip = L["Tint the tooltip border by the unit's class or reaction."] },
			{ kind = "check", label = L["Show Mount"], path = { "Tooltip", "ShowMount" }, dependsOn = { "Tooltip", "Enable" } },
			{ kind = "check", label = L["Show Mythic+ Rating"], path = { "Tooltip", "ShowMythicScore" }, dependsOn = { "Tooltip", "Enable" } },
			{ kind = "check", label = L["Show Role Icon"], path = { "Tooltip", "ShowRole" }, dependsOn = { "Tooltip", "Enable" } },
			{ kind = "check", label = L["Show Targeted By"], path = { "Tooltip", "ShowTargetedBy" }, dependsOn = { "Tooltip", "Enable" }, tooltip = L["List which group members are targeting the unit."] },
			{ kind = "check", label = L["Show Target"], path = { "Tooltip", "ShowTarget" }, dependsOn = { "Tooltip", "Enable" } },
			{ kind = "check", label = L["Show Guild"], path = { "Tooltip", "ShowGuild" }, dependsOn = { "Tooltip", "Enable" } },
			{ kind = "check", label = L["Show Item Level"], path = { "Tooltip", "ShowItemLevel" }, dependsOn = { "Tooltip", "Enable" } },
			{ kind = "check", label = L["Show IDs"], path = { "Tooltip", "ShowIDs" }, reload = true, dependsOn = { "Tooltip", "Enable" }, tooltip = L["Append spell, item, currency, and mount ids to tooltips."] },
			{ kind = "check", label = L["Show Icons"], path = { "Tooltip", "ShowIcons" }, reload = true, dependsOn = { "Tooltip", "Enable" }, tooltip = L["Show the item, spell, or mount icon beside the tooltip title."] },
			{ kind = "check", label = L["Show Mount Source"], path = { "Tooltip", "ShowMountSource" }, reload = true, dependsOn = { "Tooltip", "Enable" }, tooltip = L["Hold Shift over a player's mount buff to see its collection status and source."] },
			{ kind = "check", label = L["Show Title"], path = { "Tooltip", "ShowTitle" }, dependsOn = { "Tooltip", "Enable" } },
			{ kind = "check", label = L["Hide PvP Line"], path = { "Tooltip", "HidePvP" }, dependsOn = { "Tooltip", "Enable" } },
		},
	},

	{
		name = "ExperienceBar",
		icon = "Interface/ICONS/XP_Icon",
		title = L["Experience Bar"],
		controls = {
			{ kind = "header", label = L["Experience Bar"] },
			{ kind = "check", label = L["Enable Experience Bar"], path = { "ExpRep", "Enable" }, reload = true, tooltip = L["Replace Blizzard's experience/reputation tracker with a movable bar (reload to restore Blizzard's)."] },
			{ kind = "check", label = L["Show Bar Text"], path = { "ExpRep", "ShowText" }, apply = ApplyExpRep, dependsOn = { "ExpRep", "Enable" } },
			{ kind = "check", label = L["Show Rested"], path = { "ExpRep", "ShowRested" }, apply = ApplyExpRep, dependsOn = { "ExpRep", "Enable" } },
			{ kind = "slider", label = L["Bar Width"], path = { "ExpRep", "Width" }, min = 120, max = 600, step = 1, apply = ApplyExpRep, dependsOn = { "ExpRep", "Enable" } },
			{ kind = "slider", label = L["Bar Height"], path = { "ExpRep", "Height" }, min = 6, max = 40, step = 1, apply = ApplyExpRep, dependsOn = { "ExpRep", "Enable" } },
			{ kind = "slider", label = L["Font Size"], path = { "ExpRep", "FontSize" }, min = 8, max = 24, step = 1, apply = ApplyExpRep, dependsOn = { "ExpRep", "Enable" } },
			{ kind = "header", label = L["Fade"] },
			{ kind = "check", label = L["Fade Bar"], path = { "ExpRep", "Fade" }, apply = ApplyExpRep, dependsOn = { "ExpRep", "Enable" }, tooltip = L["Fade the bar out and reveal it on mouseover."] },
			{ kind = "slider", label = L["Faded Opacity"], path = { "ExpRep", "FadeOpacity" }, min = 0, max = 100, step = 5, apply = ApplyExpRep, dependsOn = { "ExpRep", "Fade" } },
			{ kind = "check", label = L["Show in Combat"], path = { "ExpRep", "FadeCombat" }, apply = ApplyExpRep, dependsOn = { "ExpRep", "Fade" } },
			{ kind = "check", label = L["Show with Target"], path = { "ExpRep", "FadeTarget" }, apply = ApplyExpRep, dependsOn = { "ExpRep", "Fade" } },
		},
	},

	{
		name = "AlertFrames",
		icon = "Interface/ICONS/Achievement_General",
		title = L["Alert Frames"],
		controls = {
			{ kind = "header", label = L["Alert Frames"] },
			{ kind = "check", label = L["Enable Alert Frames"], path = { "AlertFrames", "Enable" }, reload = true, tooltip = L["Move achievement, loot, and reward popups to one movable anchor at the top of the screen (reload to restore Blizzard's)."] },
			{ kind = "slider", label = L["Stack Spacing"], path = { "AlertFrames", "StackSpacing" }, min = -15, max = 10, step = 1, apply = ApplyAlertFrames, dependsOn = { "AlertFrames", "Enable" }, tooltip = L["Gap between stacked alerts. 0 is tight, negative overlaps the art padding."] },
			{ kind = "check", label = L["Hide Talking Head"], path = { "AlertFrames", "HideTalkingHead" }, apply = ApplyAlertFrames, dependsOn = { "AlertFrames", "Enable" }, tooltip = L["Suppress the Talking Head dialog frame (reload to re-enable it)."] },
		},
	},

	{
		name = "PullCountdown",
		icon = "Interface/ICONS/Ability_Warrior_Charge",
		title = L["Pull Countdown"],
		controls = {
			{ kind = "header", label = L["Pull Countdown"] },
			{ kind = "check", label = L["Enable Pull Countdown"], path = { "PullCountdown", "Enable" }, tooltip = L["Announce a pull timer in party/raid chat with /pull [seconds] (alias /pc). A second /pull cancels. Needs a group and no combat."] },
			{ kind = "slider", label = L["Default Seconds"], path = { "PullCountdown", "Seconds" }, min = 3, max = 30, step = 1, dependsOn = { "PullCountdown", "Enable" }, tooltip = L["Seconds used when you type /pull with no number."] },
		},
	},

	{
		name = "GroupTools",
		icon = "Interface/ICONS/Ability_Warrior_BattleShout",
		title = L["Group Tools"],
		controls = {
			{ kind = "header", label = L["Group Tools"] },
			{ kind = "check", label = L["Enable Group Tools"], path = { "GroupTools", "Enable" }, reload = true, tooltip = L["A movable panel shown only in a group: ready check, role check, pull timer, world markers, target icons, and a role count."] },
			{ kind = "slider", label = L["Pull Timer Seconds"], path = { "GroupTools", "PullTime" }, min = 3, max = 30, step = 1, reload = true, dependsOn = { "GroupTools", "Enable" }, tooltip = L["Seconds counted down by the pull timer button."] },
		},
	},

	{
		name = "Loot",
		icon = "Interface/ICONS/INV_Misc_Bag_10",
		title = L["Loot Frame"],
		controls = {
			{ kind = "header", label = L["Loot Frame"] },
			{ kind = "check", label = L["Enable Loot Window"], path = { "Loot", "Enable" }, reload = true, tooltip = L["Replace the stock pick-up list with our own compact loot window."] },
			{ kind = "slider", label = L["Row Height"], path = { "Loot", "IconSize" }, min = 24, max = 44, step = 2, reload = true, dependsOn = { "Loot", "Enable" } },
			{ kind = "slider", label = L["Minimum Width"], path = { "Loot", "Width" }, min = 180, max = 360, step = 4, reload = true, dependsOn = { "Loot", "Enable" } },
			{ kind = "check", label = L["Open At Cursor"], path = { "Loot", "UnderMouse" }, dependsOn = { "Loot", "Enable" }, tooltip = L["Open the loot window at the mouse instead of the saved spot."] },
		},
	},

	{
		name = "MicroMenu",
		icon = "Interface/ICONS/INV_Misc_Book_09",
		title = L["Micro Menu"],
		controls = {
			{ kind = "header", label = L["Micro Menu"] },
			{ kind = "check", label = L["Enable Micro Menu"], path = { "MicroMenu", "Enable" }, reload = true, tooltip = L["A movable, reskinned row of the character/spellbook/collections buttons."] },
			{ kind = "slider", label = L["Button Size"], path = { "MicroMenu", "ButtonSize" }, min = 20, max = 40, step = 1, reload = true, dependsOn = { "MicroMenu", "Enable" } },
			{ kind = "slider", label = L["Button Spacing"], path = { "MicroMenu", "Spacing" }, min = 0, max = 12, step = 1, reload = true, dependsOn = { "MicroMenu", "Enable" } },

			{ kind = "header", label = L["Bag Bar"] },
			{ kind = "check", label = L["Enable Bag Bar"], path = { "BagBar", "Enable" }, reload = true, tooltip = L["A movable, reskinned bag bar with the backpack free-slot count."] },
			{ kind = "slider", label = L["Bag Button Size"], path = { "BagBar", "ButtonSize" }, min = 20, max = 40, step = 1, reload = true, dependsOn = { "BagBar", "Enable" } },
			{ kind = "slider", label = L["Bag Button Spacing"], path = { "BagBar", "Spacing" }, min = 0, max = 12, step = 1, reload = true, dependsOn = { "BagBar", "Enable" } },
		},
	},

	{
		name = "Bags",
		icon = "Interface/ICONS/INV_Misc_Bag_08",
		title = L["Bags"],
		controls = {
			{ kind = "header", label = L["Bags"] },
			{ kind = "check", label = L["Enable Bags"], path = { "Bags", "Enable" }, reload = true, tooltip = L["An all-in-one, auto categorised bag and bank window that replaces the default bags."] },
			{ kind = "check", label = L["Categorise Items"], path = { "Bags", "Categories" }, apply = ApplyBags, dependsOn = { "Bags", "Enable" }, tooltip = L["Group items into New, Equipment, Consumables, and the like."] },
			{ kind = "check", label = L["Merge Duplicate Stacks"], path = { "Bags", "MergeStacks" }, apply = ApplyBags, dependsOn = { "Bags", "Enable" }, tooltip = L["Show one button per stackable item with the combined count."] },
			{ kind = "check", label = L["Group Gear By Slot"], path = { "Bags", "GroupGearBySlot" }, apply = ApplyBags, dependsOn = { "Bags", "Enable" }, tooltip = L["Split equippable gear into its own shelf for each equipment slot."] },
			{ kind = "slider", label = L["Button Size"], path = { "Bags", "ButtonSize" }, min = 24, max = 48, step = 1, apply = ApplyBags, dependsOn = { "Bags", "Enable" } },
			{ kind = "slider", label = L["Button Spacing"], path = { "Bags", "Spacing" }, min = 0, max = 10, step = 1, apply = ApplyBags, dependsOn = { "Bags", "Enable" } },
			{ kind = "slider", label = L["Bags Per Row"], path = { "Bags", "BagsPerRow" }, min = 6, max = 20, step = 1, apply = ApplyBags, dependsOn = { "Bags", "Enable" } },
			{ kind = "slider", label = L["Bank Per Row"], path = { "Bags", "BankPerRow" }, min = 6, max = 24, step = 1, apply = ApplyBags, dependsOn = { "Bags", "Enable" } },

			{ kind = "header", label = L["Item Markers"] },
			{ kind = "check", label = L["Show Item Level"], path = { "Bags", "ShowItemLevel" }, apply = ApplyBags, dependsOn = { "Bags", "Enable" }, tooltip = L["Item level on equippable gear."] },
			{ kind = "check", label = L["Show Upgrade Track"], path = { "Bags", "ShowUpgradeTrack" }, apply = ApplyBags, dependsOn = { "Bags", "Enable" }, tooltip = L["Show upgrade progress (current/max) on gear, green once fully upgraded."] },
			{ kind = "check", label = L["Pawn Upgrade Arrows"], path = { "Bags", "PawnArrows" }, apply = ApplyBags, dependsOn = { "Bags", "Enable" }, tooltip = L["Show a green arrow on gear Pawn rates as an upgrade. Needs the Pawn addon installed."] },
			{ kind = "check", label = L["Show Bind Type"], path = { "Bags", "ShowItemBind" }, apply = ApplyBags, dependsOn = { "Bags", "Enable" }, tooltip = L["Mark bind-on-equip and bind-on-use gear that has not bound yet."] },
			{ kind = "check", label = L["Glow New Items"], path = { "Bags", "ShowNewItems" }, apply = ApplyBags, dependsOn = { "Bags", "Enable" } },
			{ kind = "check", label = L["Junk Coin Icon"], path = { "Bags", "JunkIcon" }, apply = ApplyBags, dependsOn = { "Bags", "Enable" } },
			{ kind = "check", label = L["Fade Junk Items"], path = { "Bags", "DesaturateJunk" }, apply = ApplyBags, dependsOn = { "Bags", "Enable" }, tooltip = L["Grey out the icon of vendor trash so it fades behind the rest."] },
			{ kind = "check", label = L["Delete Junk Button"], path = { "Bags", "DeleteButton" }, reload = true, dependsOn = { "Bags", "Enable" }, tooltip = L["Show a button that deletes your lowest value junk item to free a slot."] },
			{ kind = "check", label = L["Quest Item Colour"], path = { "Bags", "QuestColor" }, apply = ApplyBags, dependsOn = { "Bags", "Enable" }, tooltip = L["Give quest items a quest-yellow border and a bang on items that start a quest."] },
			{ kind = "check", label = L["Reagent Bag Section"], path = { "Bags", "ReagentBagSection" }, apply = ApplyBags, dependsOn = { "Bags", "Enable" }, tooltip = L["Group everything in the reagent pouch into its own section."] },
			{ kind = "check", label = L["Detach Reagent Bag"], path = { "Bags", "DetachReagentBag" }, reload = true, dependsOn = { "Bags", "Enable" }, tooltip = L["Give the reagent pouch its own window instead of a section in the bags."] },
			{ kind = "check", label = L["Show Bag Bar"], path = { "Bags", "ShowBagBar" }, apply = function()
				local B = K:GetModule("Bags", true)
				if B and B.ToggleBagStrip then
					if B.BagFrame then
						B:ToggleBagStrip(B.BagFrame, C.Bags.ShowBagBar)
					end
					if B.BankFrame then
						B:ToggleBagStrip(B.BankFrame, C.Bags.ShowBagBar)
					end
				end
			end, dependsOn = { "Bags", "Enable" }, tooltip = L["Show the bag slot strip on the bag window. Also toggled by the button in the window."] },
			{ kind = "check", label = L["Track Currencies"], path = { "Bags", "ShowCurrencies" }, apply = ApplyBags, dependsOn = { "Bags", "Enable" }, tooltip = L["Show your pinned currencies along the bottom of the window."] },

			{ kind = "header", label = L["Behaviour"] },
			{ kind = "check", label = L["Reverse Sort"], path = { "Bags", "ReverseSort" }, dependsOn = { "Bags", "Enable" }, tooltip = L["Fill new items from the top-left instead of the bottom-right."] },
			{ kind = "check", label = L["Auto Deposit Reagents"], path = { "Bags", "AutoDepositReagents" }, dependsOn = { "Bags", "Enable" }, tooltip = L["Push reagents into the bank when you open it."] },

			{ kind = "header", label = L["Vendors"] },
			{ kind = "check", label = L["Tint Known Collectibles"], path = { "AlreadyKnown", "Enable" }, reload = true, tooltip = L["Tint already-known recipes, pets, toys, mounts, cosmetics, and housing decor green at vendors, the Auction House, and the Guild Bank."] },
		},
	},

	{
		name = "Automation",
		icon = "Interface/ICONS/Ability_Rogue_MasterOfSubtlety",
		title = L["Automation"],
		controls = {
			{ kind = "header", label = L["Automation"] },
			{ kind = "check", label = L["Enable Automation"], path = { "Automation", "Enable" }, reload = true, tooltip = L["Small quality-of-life automations."] },
			{ kind = "check", label = L["Decline Duels"], path = { "Automation", "DeclineDuels" }, dependsOn = { "Automation", "Enable" }, tooltip = L["Turn away player duel requests."] },
			{ kind = "check", label = L["Decline Pet Duels"], path = { "Automation", "DeclinePetDuels" }, dependsOn = { "Automation", "Enable" }, tooltip = L["Turn away pet-battle duel requests."] },
			{ kind = "check", label = L["Skip Cinematics"], path = { "Automation", "SkipCinematics" }, dependsOn = { "Automation", "Enable" }, tooltip = L["Skip cinematics and movies. Leave off on a first playthrough."] },
			{ kind = "check", label = L["Auto Repair"], path = { "Automation", "AutoRepair" }, dependsOn = { "Automation", "Enable" }, tooltip = L["Repair all gear when a repair-capable merchant opens."] },
			{ kind = "check", label = L["Repair With Guild Funds"], path = { "Automation", "RepairGuildFunds" }, dependsOn = { "Automation", "Enable" }, tooltip = L["Spend guild bank money first when you have repair permission, then fall back to your own."] },
			{ kind = "check", label = L["Auto Sell Junk"], path = { "Automation", "SellJunk" }, dependsOn = { "Automation", "Enable" }, tooltip = L["Sell all grey items automatically when you open a merchant. Works even with the KkthnxUI bags disabled."] },

				{ kind = "header", label = L["Auto Quest"] },
				{ kind = "check", label = L["Enable Auto Quest"], path = { "AutoQuest", "Enable" }, reload = true, tooltip = L["Accept and turn in quests automatically. Hold the pause key to do it by hand."] },
				{ kind = "check", label = L["Accept Quests"], path = { "AutoQuest", "Accept" }, dependsOn = { "AutoQuest", "Enable" } },
				{ kind = "check", label = L["Turn In Quests"], path = { "AutoQuest", "TurnIn" }, dependsOn = { "AutoQuest", "Enable" } },
				{ kind = "check", label = L["Pick Best Reward"], path = { "AutoQuest", "SelectReward" }, dependsOn = { "AutoQuest", "Enable" }, tooltip = L["On a choice of rewards, take the one worth the most gold."] },
				{ kind = "check", label = L["Skip Gossip"], path = { "AutoQuest", "SkipGossip" }, dependsOn = { "AutoQuest", "Enable" }, tooltip = L["Click through an NPC with only a single gossip option."] },
				{ kind = "check", label = L["Ignore Trivial Quests"], path = { "AutoQuest", "IgnoreTrivial" }, dependsOn = { "AutoQuest", "Enable" }, tooltip = L["Leave low-level grey quests alone."] },
				{ kind = "check", label = L["Share Quests"], path = { "AutoQuest", "Share" }, dependsOn = { "AutoQuest", "Enable" }, tooltip = L["Push accepted quests to your party."] },
				{ kind = "dropdown", label = L["Pause Key"], path = { "AutoQuest", "PauseKey" }, dependsOn = { "AutoQuest", "Enable" }, options = {
					{ text = SHIFT_KEY_TEXT or "Shift", value = "SHIFT" },
					{ text = CTRL_KEY_TEXT or "Ctrl", value = "CTRL" },
					{ text = ALT_KEY_TEXT or "Alt", value = "ALT" },
					{ text = NONE or "None", value = "NONE" },
				}, tooltip = L["Hold this key to pause automation while the NPC window is open."] },
		},
	},

	{
		name = "Skins",
		icon = "Interface/ICONS/INV_Chest_Cloth_17",
		title = L["Skins"],
		controls = {
			{ kind = "header", label = L["Skins"] },
			{ kind = "check", label = L["Character & Inspect Frames"], path = { "Skins", "CharacterFrames" }, reload = true, tooltip = L["Restyle and resize the Character and Inspect frames. Reload to fully undo."] },
			{ kind = "check", label = L["Gear Item Level & Gems"], path = { "Skins", "GearInfo" }, reload = true, tooltip = L["Show item level, gems, enchants, and a missing-enchant warning on each equipment slot."], dependsOn = { "Skins", "CharacterFrames" } },

			{ kind = "header", label = L["Social"] },
			{ kind = "check", label = L["Social Class Colours"], path = { "Skins", "SocialColors" }, reload = true, tooltip = L["Class-colour names and difficulty-colour levels in the Friends, Who, and Guild panels."] },

				{ kind = "header", label = L["Game Menu"] },
				{ kind = "check", label = L["Skin Game Menu"], path = { "Skins", "GameMenu" }, reload = true, tooltip = L["Restyle the pause menu and add a KkthnxUI button that opens these options."] },

				{ kind = "header", label = L["Objective Tracker"] },
				{ kind = "check", label = L["Skin Objective Tracker"], path = { "Skins", "ObjectiveTracker" }, reload = true, tooltip = L["Hide the quest tracker header backgrounds, tidy the minimise button, and recolour its bars."] },
				{ kind = "check", label = L["Class-Coloured Bars"], path = { "Skins", "ObjectiveTrackerClassColor" }, tooltip = L["Tint quest progress and timer bars with your class colour instead of the accent colour."], dependsOn = { "Skins", "ObjectiveTracker" } },
		},
	},

	{
		name = "Movers",
		icon = "Interface/ICONS/Ability_Hunter_MasterMarksman",
		title = L["Move UI"],
		custom = "Movers",
	},

	-- Profiles use a bespoke panel built in Profiles.lua.
	{
		name = "Profiles",
		icon = "Interface/ICONS/INV_Misc_Note_01",
		title = L["Profiles"],
		custom = "Profiles",
	},
}
