-- Localization for enUS & enGB clients

local PerformanceSlight = "\n|cffFF0000Disabling this may slightly increase performance|r" -- For semi-high CPU options
local ToggleOffReminder = "\n|cffFF0000Turn this off to manually input your bar numbers|r"

KkthnxUIConfig["enUS"] = {
	-- General Local
	["General"] = {
		["AutoScale"] = {
			["Name"] = "Auto Scale",
			["Desc"] = "Automatically scale the User Interface based on your screen resolution",
		},

		["UIScale"] = {
			["Name"] = "UI Scale",
			["Desc"] = "Set a custom UI scale",
		},

		["BubbleFontSize"] = {
			["Name"] = "Bubble Font Size",
			["Desc"] = "Set a custom chat bubble font size",
		},

		["DisableTutorialButtons"] = {
			["Name"] = "Disable Tutorial Buttons",
			["Desc"] = "Disables the tutorial button found on some frames.",
		},

		["FontSize"] = {
			["Name"] = "General UI Font Size",
			["Desc"] = "Set the font size for everything in UI. Note: This doesn't effect somethings that have their own seperate options (UnitFrame Font, Datatext Font, ect..)",
		},

		["SpellTolerance"] = {
			["Name"] = "Spell Tolerance",
			["Desc"] = "Periodically adjust the Spell Tolerance variable to match your world latency so that spell queueing always works optimally, regardless of your instance server's location.",
		},

		["TaintLog"] = {
			["Name"] = "Log Taints",
			["Desc"] = "Send ADDON_ACTION_BLOCKED errors to the Lua Error frame. These errors are less important in most cases and will not effect your game performance. Also a lot of these errors cannot be fixed. Please only report these errors if you notice a Defect in gameplay.",
		},

		["ToggleButton"] = {
			["Name"] = "Toggle Button",
			["Desc"] = "Description Needed",
		},

		["ToggleButton"] = {
			["Name"] = "Toggle Button",
			["Desc"] = "Description Needed",
		},

		["UseBlizzardFonts"] = {
			["Name"] = "Blizzard Fonts",
			["Desc"] = "Change some of the default Blizzard fonts to match the UI",
		},
	},
	-- ActionBar Local
	["ActionBar"] = {
		["BottomBars"] = {
			["Name"] = "Bottom Bars",
			["Desc"] = "The amount of bars to display on the bottom. Note: Value can only be 1-3",
		},

		["ButtonSize"] = {
			["Name"] = "Button Size",
			["Desc"] = "The size of the action buttons.",
		},

		["ButtonSpace"] = {
			["Name"] = "Button Space",
			["Desc"] = "The spacing between buttons.",
		},

		["PetBarMouseover"] = {
			["Name"] = "Petbar Mouseover",
			["Desc"] = "Display the Petbar while mousing over it.",
		},

		["Enable"] = {
			["Name"] = "Enable",
			["Desc"] = "Toggle the Actionbars. This can be useful if another AddOn is intering with our actionbars",
		},

		["Grid"] = {
			["Name"] = "Enable",
			["Desc"] = "Toggle the Actionbars. This can be useful if another AddOn is intering with our actionbars",
		},
	},
	-- Nameplates Local
	["Nameplates"] = {
		["UseTargetGlow"] = {
			["Name"] = "Use Target Glow",
			["Desc"] = "Show a glow on targeted nameplate",
		},

		["CastbarHeight"] = {
			["Name"] = "Castbar Height",
			["Desc"] = "The height of the nameplate castbar.",
		},

		["PowerBar"] = {
			["Name"] = "PowerBar",
			["Desc"] = "Toggle the powerbar on nameplates for healers only.",
		},

		["DisplayStyle"] = {
			["Name"] = "Display Style",
			["Desc"] = "Controls which nameplates will be displayed.",
		},

		["Enable"] = {
			["Name"] = "Enable",
			["Desc"] = "Toggle the nameplates on/off",
		},

		["EnemyMinions"] = {
			["Name"] = "Enemy Minions",
			["Desc"] = OPTION_TOOLTIP_UNIT_NAME_ENEMY_MINIONS,
		},

		["EnemyMinors"] = {
			["Name"] = "Enemy Minors",
			["Desc"] = OPTION_TOOLTIP_UNIT_NAMEPLATES_SHOW_ENEMY_MINUS,
		},

		["FontSize"] = {
			["Name"] = "Font Size",
			["Desc"] = "Font size for all nameplate fonts.",
		},

		["FriendlyMinions"] = {
			["Name"] = "Friendly Minions",
			["Desc"] = OPTION_TOOLTIP_UNIT_NAME_FRIENDLY_MINIONS,
		},

		["HealthbarHeight"] = {
			["Name"] = "Healthbar Height",
			["Desc"] = "Base Height for the healthbar",
		},

		["HealthbarWidth"] = {
			["Name"] = "Healthbar Width",
			["Desc"] = "Base Width for the healthbar",
		},

		["AuraIconSize"] = {
			["Name"] = "AuraIcon Size",
			["Desc"] = "Base Size for the Aura Icon",
		},

		["LowHealthThreshold"] = {
			["Name"] = "Low Health Threshold",
			["Desc"] = "Make the nameplate glow yellow when it is below this percent of health, it will glow red when the health value is half of this value.",
		},

		["MarkHealers"] = {
			["Name"] = "Mark Healers",
			["Desc"] = "Display a healer icon over known healers inside battlegrounds or arenas.",
		},

		["AurasMaxDuration"] = {
			["Name"] = "Auras Max Duration",
			["Desc"] = "Max Duration for the Aura timers",
		},

		["AlwaysShowTargetHealth"] = {
			["Name"] = "Always Show Target Health",
			["Desc"] = "Description Needed",
		},

		["MotionType"] = {
			["Name"] = "Motion Type",
			["Desc"] = "Set to either stack nameplates vertically or allow them to overlap.",
		},

		["NumAuras"] = {
			["Name"] = "# Displayed Auras",
			["Desc"] = "Controls how many auras are displayed, this will also affect the size of the auras.",
		},

		["PowerbarHeight"] = {
			["Name"] = "Powerbar Height",
			["Desc"] = "Base Height for the powerbar",
		},

		["ShowAuras"] = {
			["Name"] = "Show Auras",
			["Desc"] = "Toggle the display of auras on/off",
		},

		["ShowEnemyCombat"] = {
			["Name"] = "Show Enemy Combat",
			["Desc"] = "Control enemy nameplates toggling on or off when in combat.",
		},

		["ShowFriendlyCombat"] = {
			["Name"] = "Show Friendly Combat",
			["Desc"] = "Control friendly nameplates toggling on or off when in combat.",
		},

		["TargetScale"] = {
			["Name"] = "Target Scale",
			["Desc"] = "Scale of the nameplate that is targetted.",
		},
	},
}