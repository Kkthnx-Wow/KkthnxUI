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
			["Desc"] = "Show empty action bar buttons",
		},
	},
	-- Nameplates Local
	["Nameplates"] = {
		["AurasSize"] = {
			["Name"] = "Auras Size",
			["Desc"] = "Size of the auras on Nameplates",
		},

		["BadColor"] = {
			["Name"] = "Bad Color",
			["Desc"] = "Description Needed",
		},

		["CastbarName"] = {
			["Name"] = "Castbar Name",
			["Desc"] = "Description Needed",
		},

		["CastUnitReaction"] = {
			["Name"] = "Cast Unit Reaction",
			["Desc"] = "Description Needed",
		},

		["Clamp"] = {
			["Name"] = "Clamp",
			["Desc"] = "Description Needed",
		},

		["Distance"] = {
			["Name"] = "Distance",
			["Desc"] = "Description Needed",
		},

		["Enable"] = {
			["Name"] = "Enable",
			["Desc"] = "Description Needed",
		},

		["EnhancedThreat"] = {
			["Name"] = "Enhanced Threat",
			["Desc"] = "Description Needed",
		},

		["FontSize"] = {
			["Name"] = "Font Size",
			["Desc"] = "Description Needed",
		},

		["GoodColor"] = {
			["Name"] = "Good Color",
			["Desc"] = "Description Needed",
		},

		["HealerIcon"] = {
			["Name"] = "Healer Icon",
			["Desc"] = "Description Needed",
		},

		["HealthValue"] = {
			["Name"] = "Health Value",
			["Desc"] = "Description Needed",
		},

		["Height"] = {
			["Name"] = "Height",
			["Desc"] = "Description Needed",
		},

		["NameAbbreviate"] = {
			["Name"] = "Name Abbreviate",
			["Desc"] = "Description Needed",
		},

		["NearColor"] = {
			["Name"] = "Near Color",
			["Desc"] = "Description Needed",
		},

		["OffTankColor"] = {
			["Name"] = "Off Tank Color",
			["Desc"] = "Description Needed",
		},

		["Outline"] = {
			["Name"] = "Outline",
			["Desc"] = "Description Needed",
		},

		["SelectedScale"] = {
			["Name"] = "Selected Scale",
			["Desc"] = "Description Needed",
		},

		["Smooth"] = {
			["Name"] = "Smooth",
			["Desc"] = "Description Needed",
		},

		["SmoothSpeed"] = {
			["Name"] = "Smooth Speed",
			["Desc"] = "Description Needed",
		},

		["TotemIcons"] = {
			["Name"] = "Totem Icons",
			["Desc"] = "Description Needed",
		},

		["TrackAuras"] = {
			["Name"] = "Track Auras",
			["Desc"] = "Description Needed",
		},

		["Width"] = {
			["Name"] = "Width",
			["Desc"] = "Description Needed",
		},
	},
	-- Announcements Local
	["Announcements"] = {
		["PullCountdown"] = {
			["Name"] = "Pull Countdown",
			["Desc"] = "Description Needed",
		},

		["SaySapped"] = {
			["Name"] = "Say Sapped",
			["Desc"] = "Description Needed",
		},

		["Interrupt"] = {
			["Name"] = "Interrupt",
			["Desc"] = "Description Needed",
		},
	},
	-- Automation Local
	["Automation"] = {
		["AutoCollapse"] = {
			["Name"] = "Auto Collapse",
			["Desc"] = "Description Needed",
		},

		["AutoInvite"] = {
			["Name"] = "Auto Invite",
			["Desc"] = "Description Needed",
		},

		["AutoRelease"] = {
			["Name"] = "Auto Release",
			["Desc"] = "Description Needed",
		},

		["AutoResurrect"] = {
			["Name"] = "Auto Resurrect",
			["Desc"] = "Description Needed",
		},

		["AutoResurrectCombat"] = {
			["Name"] = "Auto Resurrect Combat",
			["Desc"] = "Description Needed",
		},

		["AutoResurrectThank"] = {
			["Name"] = "Auto Resurrect Thanks",
			["Desc"] = "Description Needed",
		},

		["DeclinePetDuel"] = {
			["Name"] = "Decline Pet Duels",
			["Desc"] = "Description Needed",
		},

		["DeclinePvPDuel"] = {
			["Name"] = "Decline PvP Duels",
			["Desc"] = "Description Needed",
		},

		["ScreenShot"] = {
			["Name"] = "Screen Shot",
			["Desc"] = "Description Needed",
		},
	},
	-- Auras Local
	["Auras"] = {
		["Enable"] = {
			["Name"] = "Enable",
			["Desc"] = "Description Needed",
		},

		["ButtonSize"] = {
			["Name"] = "Button Size",
			["Desc"] = "Description Needed",
		},

		["ButtonSpace"] = {
			["Name"] = "Button Space",
			["Desc"] = "Description Needed",
		},

		["ButtonPerRow"] = {
			["Name"] = "Buttons Per Row",
			["Desc"] = "Description Needed",
		},
	},
	-- Chat Local
	["Chat"] = {
		["Enable"] = {
			["Name"] = "Enable",
			["Desc"] = "Description Needed",
		},

		["Fading"] = {
			["Name"] = "Fading",
			["Desc"] = "Description Needed",
		},

		["WhisperSound"] = {
			["Name"] = "Whisper Sound",
			["Desc"] = "Description Needed",
		},

		["FadingTimeFading"] = {
			["Name"] = "Fading Time Fading",
			["Desc"] = "Description Needed",
		},

		["FadingTimeVisible"] = {
			["Name"] = "Fading Time Visible",
			["Desc"] = "Description Needed",
		},

		["Height"] = {
			["Name"] = "Height",
			["Desc"] = "Description Needed",
		},

		["LinkBrackets"] = {
			["Name"] = "Link Brackets",
			["Desc"] = "Description Needed",
		},

		["LinkColor"] = {
			["Name"] = "Link Color",
			["Desc"] = "Description Needed",
		},

		["MessageFilter"] = {
			["Name"] = "Message Filter",
			["Desc"] = "Description Needed",
		},

		["Font"] = {
			["Name"] = "Font",
			["Desc"] = "Description Needed",
		},

		["ScrollByX"] = {
			["Name"] = "Scroll By X",
			["Desc"] = "Description Needed",
		},

		["SpamFilter"] = {
			["Name"] = "Spam Filter",
			["Desc"] = "Description Needed",
		},

		["TabsMouseover"] = {
			["Name"] = "Tabs Mouseover",
			["Desc"] = "Description Needed",
		},

		["TabsOutline"] = {
			["Name"] = "Tabs Outline",
			["Desc"] = "Description Needed",
		},

		["Width"] = {
			["Name"] = "Width",
			["Desc"] = "Description Needed",
		},

		["BubbleBackdrop"] = {
			["Name"] = "Bubble Backdrop",
			["Desc"] = "Description Needed",
		},
	},
	-- Cooldown Local
	["Cooldown"] = {
		["Days"] = {
			["Name"] = "Days",
			["Desc"] = "Description Needed",
		},

		["Enable"] = {
			["Name"] = "Enable",
			["Desc"] = "Description Needed",
		},

		["Expiring"] = {
			["Name"] = "Expiring",
			["Desc"] = "Description Needed",
		},

		["ExpiringDuration"] = {
			["Name"] = "Expiring Duration",
			["Desc"] = "Description Needed",
		},

		["FontSize"] = {
			["Name"] = "Font Size",
			["Desc"] = "Description Needed",
		},

		["Hours"] = {
			["Name"] = "Hours",
			["Desc"] = "Description Needed",
		},

		["Minutes"] = {
			["Name"] = "Minutes",
			["Desc"] = "Description Needed",
		},

		["Seconds"] = {
			["Name"] = "Seconds",
			["Desc"] = "Description Needed",
		},

		["Threshold"] = {
			["Name"] = "Threshold",
			["Desc"] = "Description Needed",
		},
	},
	-- DataText Local
	["DataText"] = {
		["Battleground"] = {
			["Name"] = "Battleground",
			["Desc"] = "Description Needed",
		},

		["LocalTime"] = {
			["Name"] = "Local Time",
			["Desc"] = "Description Needed",
		},

		["Outline"] = {
			["Name"] = "Outline",
			["Desc"] = "Description Needed",
		},

		["System"] = {
			["Name"] = "System",
			["Desc"] = "Description Needed",
		},

		["Time24Hr"] = {
			["Name"] = "24 Hour Time",
			["Desc"] = "Description Needed",
		},
	},
	-- Errors Local
	["Error"] = {
		["Black"] = {
			["Name"] = "Black",
			["Desc"] = "Description Needed",
		},

		["Combat"] = {
			["Name"] = "Combat",
			["Desc"] = "Description Needed",
		},

		["White"] = {
			["Name"] = "White",
			["Desc"] = "Description Needed",
		},

		["System"] = {
			["Name"] = "System",
			["Desc"] = "Description Needed",
		},

		["Time24Hr"] = {
			["Name"] = "24 Hour Time",
			["Desc"] = "Description Needed",
		},
	},
}