local K = KkthnxUI[1]

local KKUI_Changelog = {
	{
		Version = "[10.4.9] - 2023-11-24 - Patch 10.2",
		General = "Stay connected with the KkthnxUI community on our Discord server for the latest updates and engaging discussions about the addon's development and features.",
		Sections = {

			{
				Header = "General",
				Entries = {
					"Enhanced overall addon functionality to align with the latest World of Warcraft Patch 10.2 updates.",
				},
			},

			{
				Header = "UI Updates",
				Entries = {
					"Updated and fixed issues with GroupLoot functionality.",
					"Upgraded LibActionButton to the latest version.",
					"Implemented updates to LibRangeCheck.",
					"Refined yClassColors.",
					"Enhanced unit frame tags.",
				},
			},

			{
				Header = "Bug Fixes",
				Entries = {
					"Attempted to resolve issues with the Goodbye module not functioning correctly at the end of instances.",
				},
			},

			{
				Header = "Optimization",
				Entries = {
					"Conducted thorough refactoring of yClassColors, streamlining the code for better performance and maintainability.",
					"Continued efforts to optimize code and UI elements for an improved user experience and addon responsiveness.",
				},
			},
		},
	},

	{
		Version = "[10.4.8] - 2023-11-22 - Patch 10.2",
		General = "Don't forget to join our KkthnxUI Discord server to stay up-to-date on the latest news and discussions about KkthnxUI and its future development.",
		Sections = {

			{
				Header = "General",
				Entries = {
					"Continued efforts to enhance the user interface experience with various updates and adjustments in line with the latest World of Warcraft updates.",
				},
			},

			{
				Header = "UI Updates",
				Entries = {
					"Optimized UI memory usage and performed code cleanup for better performance.",
					"Updated README.md to provide clearer, more current information.",
					"Improved QuickJoin functionality for a smoother user experience.",
					"Updated loot and fixed issues with mirrorbars for enhanced gameplay.",
					"Reworked spec in tooltip and increased spellflyout spacing for better visibility and user interaction.",
				},
			},

			{
				Header = "Code Improvements",
				Entries = {
					"Addressed and attempted to fix two taint issues for improved stability.",
					"Performed cleanup and bug fixes related to Blizzard's UI elements.",
					"Resolved a protected item range check issue ('IsItemInRange').",
				},
			},

			{
				Header = "Optimization",
				Entries = {
					"Conducted a thorough cleanup to enhance code clarity and maintainability.",
					"Improved formatting to use UPU over UPF for consistency and readability.",
					"Introduced adjustments to unitframe range stuff for better performance.",
				},
			},
		},
	},

	{
		Version = "[10.4.7] - 2023-5-5 - Patch 10.1",
		General = "Don't forget to join our KkthnxUI Discord [Rc9wcK9cAB] server to stay up-to-date on the latest news and discussions about KkthnxUI and its future development.",
		Sections = {

			{
				Header = "General",
				Entries = {
					"These updates and code improvements aim to provide a better user interface experience and enhance the overall performance and maintainability of the UI codebase in the Dragonflight Patch 10.1: Embers of Neltharion Patch.",
				},
			},

			{
				Header = "UI Updates",
				Entries = {
					"Updated the UI to align with the Dragonflight Patch 10.1: Embers of Neltharion Patch.",
					"Made various improvements to enhance the user experience.",
				},
			},

			{
				Header = "Code Improvements",
				Entries = {
					"Improved code formatting to ensure better readability.",
					"Reorganized the code for improved organization and maintainability.",
					"Introduced more descriptive names for variables and functions.",
				},
			},

			{
				Header = "Optimization",
				Entries = {
					"Optimized the code for improved performance and efficiency.",
					"Reviewed and refactored code to eliminate unnecessary computations and improve overall speed.",
				},
			},
		},
	},

	{
		Version = "[10.4.6] - 2023-1-22",
		General = "All notable changes to this project will be documented in this file. The format is based on " .. K.SystemColor .. "[Keep a Changelog]|r and this project adheres to " .. K.SystemColor .. "[Semantic Versioning]|r",
		Sections = {

			{
				Header = "Quote",
				Entries = {
					"If you can dream it, you can do it. - Walt Disney",
				},
			},

			{
				Header = "General",
				Entries = {
					"Improved code readability and performance.",
					"Refactored code for better maintainability.",
					"Fixed various UI bugs and improved overall stability.",
					"Added support for new features and improvements to existing ones.",
				},
			},
		},
	},

	{
		Version = "[10.4.5] - 2023-1-5",
		General = "All notable changes to this project will be documented in this file. The format is based on " .. K.SystemColor .. "[Keep a Changelog]|r and this project adheres to " .. K.SystemColor .. "[Semantic Versioning]|r",
		Sections = {
			{
				Header = "Added",
				Entries = {
					"[AutoOpen] Added combat check to bag check",
					"[Datatext] Added Community Feast",
					"[Datatext] Added support for Elemental Storm & Grand Hunts",
					"[Misc] Added logo + name + version animation popup",
					"[Portraits] Added EVOKER class portraits to our media files",
					"[Tooltip] Added support for mount and toy icons",
					"[Tutorials] Added more tutorials to DIE when you enable the option for it",
					"[Unitframes] Added new combat icon",
				},
			},

			{
				Header = "Changed",
				Entries = {
					"[Border] Changed the texture and brightness of the default KkthnxUI border. You won't notice much of a difference here",
					"[LibActionButton] Changed back to the default lib so MaxDPS / Hekili will work without needing support",
					"[Nameplates] Changed and updated quest icon code",
					"[Skins] Changed professions icons to be smaller so they do not overlap (Idk why they are so close in the first place)",
				},
			},

			{
				Header = "Removed",
				Entries = {
					"[Core] Removed various leftover debug prints",
				},
			},

			{
				Header = "Fixed",
				Entries = {
					"[Core] Fixed AutoConfirm, AutoGreed, Grouploot and Fasterloot not loading",
					"[Datatext] Fixed friends throwing a nil value",
					"[GroupLoot] Fixed all issues related to group loot",
					"[Inventory] Fixed setitems to check for nil",
					"[Lumos] Fixed lumos for personal resource display for all classes",
					"[Skins] Fixed Details not checking for the proper default texture?",
				},
			},
		},
	},

	{
		Version = "[10.4.4] - 2022-12-26",
		General = "All notable changes to this project will be documented in this file. The format is based on " .. K.SystemColor .. "[Keep a Changelog]|r and this project adheres to " .. K.SystemColor .. "[Semantic Versioning]|r",
		Sections = {
			{
				Header = "Added",
				Entries = {
					"[Actionbars] Texture color will now properly color actionbars too",
					"[Minimap] We now have our old calendar icon back",
					"[Misc] Support for killing more annoying tutorials",
					"[Movers] They now shine <3",
					"[Raidframes] Support Dragonflight debuffs",
					"[Skins] ObjectiveTracker skin is now complete",
					"[Unitframes] Allow users to turn off unitframe fading when out of range",
				},
			},

			{
				Header = "Changed",
				Entries = {
					"[Config] Update spell list for reminders",
					"[Datatext] Rename module from infobar to datatext",
					"[Lib] Update LibActionButton to latest version",
					"[Raidtool] Updated codebase for our raidtool",
					"[Unitframes] Refactor castbars to better support spell stages like blizzard has it",
					"[Unitframes] Updated how we handle bolster for nameplates",
				},
			},

			{
				Header = "Removed",
				Entries = {
					"[Unitframes] Disabled combat fader because portraits are buggy right now.. Idk why",
				},
			},

			{
				Header = "Fixed",
				Entries = {
					"[Automation] AutoKeystone should work once again",
					"[Automation] AutoOpen items should work once again",
					"[Inventory] Fix typo for BagReagent",
					"[Maps] Map reveal should now properly show its overlay on undiscovered zones",
					"[Misc] Fixed and enabled MDGuildBest",
				},
			},
		},
	},

	{
		Version = "[10.4.3] - 2022-12-19",
		General = "All notable changes to this project will be documented in this file. The format is based on " .. K.SystemColor .. "[Keep a Changelog]|r and this project adheres to " .. K.SystemColor .. "[Semantic Versioning]|r",
		Sections = {
			{
				Header = "Added",
				Entries = {
					"[Aurawatch] Support for Auras for Dragonflight",
					"[Chat] Reimplement chat link hovering module",
					"[Nameplates] Support soft-targeting updates",
					"[Tooltip] Support for anchoring tooltip in config",
					"[Unitframes] All frames to use text scaling option",
					"[Unitframes] Support buffs/debuffs for Dragonflight for raidframes",
					"[Unitframes] We should have castbars for all frames now?",
				},
			},

			{
				Header = "Changed",
				Entries = {
					"[AutoQuest] Make sure we check gossip id",
					"[Bags] Items we can not use in our bags will shown a red sign on them now (NEEDS FEEDBACK)",
					"[Bags] Use LibCustomGlow for new items in bags",
					"[Datatext] Apply new tab style to durability datatext",
				},
			},

			{
				Header = "Removed",
				Entries = {
					"[Chat] AddOn blocker is pointless. I do not feel we should block stuff?",
					"[Datatext] Torghast infomation is a thing of the past <3",
				},
			},

			{
				Header = "Fixed",
				Entries = {
					"[Actionbars] Micromenu should properly flash again",
					"[Aurawatch] Aurawatch cooldowns not updating properly",
					"[Bags] Allow bags to show more than 1 tracked currency",
					"[Bags] BoP/BoE should show again on bags",
					"[Bags] Prevent quest and professions textures from falling behind border",
					"[Databars] Reputation returning a nil value",
					"[Datatext] WoWToken show now show its price and update properly again",
					"[Minimap] Map having 2 KkthnxUI borders instead of one (old code)",
					"[Skins] Gamemenu should resize properly based on splash being able to be shown or not",
					"[Unitframes] Class power not being able to be disabled",
					"[Unitframes] Swingbar should properly work again",
				},
			},
		},
	},

	{
		Version = "[10.3.8 - Dragonflight] - 2022-11-30",
		General = "All notable changes to this project will be documented in this file. The format is based on " .. K.SystemColor .. "[Keep a Changelog]|r and this project adheres to " .. K.SystemColor .. "[Semantic Versioning]|r",
		Sections = {
			{
				Header = "Added",
				Entries = {
					"Suppport for DF release",
					"This is an early release so expect bugs and issues",
					"Join our discord to report an issues or ask questions",
				},
			},
		},
	},

	{
		Version = "[10.3.7] - 2022-8-24",
		Sections = {
			{
				Header = "Added",
				Entries = {
					"Cast Target for nameplates can be toggled off and on now",
					"New statusbars added to the textures dropdown",
					"Targeted nameplates can now be scaled in options",
					"Toy train is now muted for muted module (We can all rest now)",
					"You can now adjust the amount of smoothness statusbars have",
				},
			},

			{
				Header = "Fixed",
				Entries = {
					"MDGuildBest throwing a nil error",
					"Micromenu now has mouseover again",
				},
			},

			{
				Header = "Changed",
				Entries = {
					"Cleaned the BagsBar module",
					"Cleaned the GUI module for statusbars",
					"Refactored the UI is outdated notice",
					"Updated unitframe range Lib",
				},
			},
		},
	},

	{
		Version = "[10.3.6] - 2022-8-21",
		Sections = {
			{
				Header = "Fixed",
				Entries = {
					"ObjectiveTracker throwing nil error",
				},
			},

			{
				Header = "Changed",
				Entries = {
					"No need to break on keystone module return is enough",
				},
			},
		},
	},

	{
		Version = "[10.3.5] - 2022-8-21",
		Sections = {
			{
				Header = "Added",
				Entries = {
					"All KkthnxUI Blizzard skinning now can be toggled off",
					"KkthnxUI will not automatically add the new services chat channel",
					"More globals cached and more",
					"More statusbars to pick from",
					"New Micromenu style from Dragonflight",
					"New Safequeue like timer for LFD and PVP timers",
					"New actionbar/bags button backdrop texture from Dragonflight",
					"StatusReport is now back and stylish",
				},
			},

			{
				Header = "Fixed",
				Entries = {
					"Actionbars not being properly stripted and styled",
					"Border throwing an error with other addons and itself",
					"Filter mute cache properly fixed",
					"Gold datatext had the wrong events which caused it to not update",
					"LibSharedMeida was not importing our textures and borders",
					"Mount source tooltip not growing as it should",
				},
			},

			{
				Header = "Removed",
				Entries = {
					"Global fonts section (Use a font folder for your own fonts)",
					"Tabbiner is gone (Use another addon)",
				},
			},

			{
				Header = "Changed",
				Entries = {
					"Adjusted Tank/Healer tag icons",
					"AutoGoodbye now waits 6 seconds",
					"Bags itemglow is now 100% alpha",
					"Bump TOC file",
					"Fonts are now XML based (Thanks Goldpaw)",
					"Monster chat (say/yell/whisper) toggled off in chat",
					"Rewrote AutoKeystone module",
					"Rewrote BigWigs skin",
					"Rewrote some of the ChatHistory module",
					"Statusbar texture is now in General section",
				},
			},
		},
	},

	{
		Version = "[10.3.4] - 2022-8-12",
		Sections = {
			{
				Header = "Added",
				Entries = {
					"Announce When You Obtain New Mythic Key",
					"Auto Keystone Module",
					"Bags BoE & BoU Status Text",
					"Control For Player Buffs & Debuffs",
					"New Max CameraZoom Module",
					"Objective Tracker Adjustable Size",
					"Objective Tracker Now Follows Its Options UIFont Font",
					"Option To Disabled Minimap Mail Pulse",
				},
			},

			{
				Header = "Fixed",
				Entries = {
					"Dev Trying To Load",
					"DominationShards Module",
					"Filtering chat causing bug",
					"HideFocusTarget Options",
					"Highlight On Unitframes",
					"Raid Frames Mover Not Being The Right Size",
					"Some Minimap Blip Choices",
				},
			},

			{
				Header = "Removed",
				Entries = {
					"No Longer Copy A Name When Shift Clicking",
				},
			},

			{
				Header = "Changed",
				Entries = {
					"Auras Header (Needs Testing)",
					"Castbar Max Settings Width (800)",
					"Disable Tutorals To Its Own File",
					"Filters For Raid Groups",
					"Minimap Queue Status Text",
					"Some GUI Titles and Desc",
				},
			},
		},
	},

	{
		Version = "[10.3.3] - 2022-7-28",
		Sections = {
			{
				Header = "Added",
				Entries = {
					"Filtering for new spells learned",
					"Thank you button in trade (WIP) no release",
				},
			},

			{
				Header = "Fixed",
				Entries = {
					"Gold mail button",
					"Legendaries not filtering in bags",
					"Filtering chat causing bug",
				},
			},

			{
				Header = "Changed",
				Entries = {
					"Player and pet low health alert",
					"oUF portaits",
					"Minimap Queue Status Text",
				},
			},
		},
	},

	{
		Version = "[10.3.2] - 2022-7-16",
		Sections = {
			{
				Header = "Added",
				Entries = {
					"Chocolatebar skinning",
					"Custom bags filtering max 5 custom filters",
					"Gold datatext now supports deleting characters",
					"KkthnxUI minimap button",
					"New minimap volume module",
					"Option to toggle minimap queue text status",
					"Option to toggle quickjoin module",
					"Threshold for cooldown formatting",
					"Unitframe auras updated for latest patch",
				},
			},

			{
				Header = "Fixed",
				Entries = {
					"Collections frame moving",
					"Details addon styling and height",
					"Prevent party player castbar showing ticks",
					"Raidframe mana bars",
					"Rarescanner skinning",
				},
			},

			{
				Header = "Removed",
				Entries = {
					"Community news fix",
					"Custom maw status bar",
				},
			},

			{
				Header = "Changed",
				Entries = {
					"Bags count will show * if over 1000",
				},
			},
		},
	},

	{
		Version = "[10.3.1] - 2022-6-1",
		Sections = {
			{
				Header = "Fixed",
				Entries = {
					"Player report frame changes",
					"Raid utility module",
				},
			},

			{
				Header = "Changed",
				Entries = {
					"TOC to 90205",
				},
			},
		},
	},

	{
		Version = "[10.3.0] - 2022-4-5",
		Sections = {
			{
				Header = "Added",
				Entries = {
					"Dev code to test new features that might or might not come in the future",
					"Major spells casted will be notified to the player by a highlight glow on the castbar icon",
					"Nameplates code updated and missing functions added",
					"Quest navigation now should show estimated time of arrival",
				},
			},

			{
				Header = "Fixed",
				Entries = {
					"Actionbar drawlayers for flyoutarrow and autocastable",
					"Couple locales updated to relfect its proper module",
					"Leak in world map cords",
					"Left over file trying to load and throwing an error",
					"Nameplates class power returns",
					"Talkinghead is now working as intended",
					"Tooltip IDs and such info was not being shown",
					"Unitframe class power returns",
				},
			},

			{
				Header = "Removed",
				Entries = {
					"Mail enhanced contacts module",
					"Mouse cursor module",
					"Profession disenchant module",
					"Pulse cooldown module",
					"Raid and dungeon progression tooltip module",
				},
			},

			{
				Header = "Changed",
				Entries = {
					"Actionbars completely refactored to support customization",
					"Completely refactored the databars",
					"Datatext modules events handling updated",
					"Fog of war has been revamped",
					"Mount source collected info move to ID module",
					"Unitframes code updated to be faster (small impact)",
					"oUF lib updated",
				},
			},
		},
	},

	{
		Version = "[10.2.9] - 2021-12-23",
		Sections = {
			{
				Header = "Added",
				Entries = {
					"New API to handle new backdrops in 9.1",
					"New arrow texture",
					"New bags per row options for bank and bags",
					"New bags size updates live now",
					"New map reveal data for 9.1",
					"New map reveal data for Zereth Mortis",
					"New quest tool for adding helpful tips for some quests and world quests",
					"New support added for LibDBIcon",
				},
			},

			{
				Header = "Fixed",
				Entries = {
					"BNet anchor mover throwing nil error",
					"Bag bar icon for main backpack display issue",
					"Cooldowns now obey parent",
					"Guild datatext error",
					"Search in bags should properly work now",
					"TalkingHead backdrop covering the screen",
					"Titles pane throwing c stack overflow :|",
				},
			},

			{
				Header = "Removed",
				Entries = {
					"Compatibility for old patches before 9.1 hit",
				},
			},

			{
				Header = "Changed",
				Entries = {
					"oUF core files",
					"New extra quest button filters",
					"Bags now show timwarped keystones level",
				},
			},
		},
	},

	{
		Version = "[10.2.8] - 2021-08-6",
		Sections = {
			{
				Header = "Added",
				Entries = {
					"Tank and healer icons for party/raid frames",
					"Button forge addon skin",
					"Check to ignore pixel border option if we are sizing the border",
					"Code to scale the script errors frame",
					"Default loot frame skin (people love the default loot frame i guess)",
					"Domination rank module for tooltips",
					"Domination remove button on item socketing frame to easly remove domination socketed sockets",
					"Domination shards frame on item socketing frame to easly add shards you have",
					"Maw buffs mover in raid, blizz loves this BelowMinimap shit",
					"New actionbar layout 4",
					"No portaits support for party frames",
					"Options to turn off castbar icons",
					"Safety checks with portaits function in unitframes",
					"Wider transmog frame code, it loooooooooks so good",
				},
			},

			{
				Header = "Fixed",
				Entries = {
					"Talking head frame skin",
					"Boss frames mover size being bigger than the frame itself",
					"Chat ebitbox inset so it will not overlap character count",
					"Checkquest slash command",
					"Gold datatext throwing nil error for tooltip on bags",
					"Left over code in actionbar code that was causing an error in hardmode",
					"Nil error with raid index group numbers",
					"Raid debuffs not working at all",
				},
			},

			{
				Header = "Removed",
				Entries = {
					"Font template api",
					"Map pin code as there are so many damn addons to handle it if needed",
				},
			},

			{
				Header = "Changed",
				Entries = {
					"All actionbar code and added global scaling for them",
					"Announcements for interrupts, dispells and more",
					"Aurawatch auras list",
					"Cargbags library code",
					"Extra quest button lists and fixed ignore list",
					"Gui headers names to better flow",
					"Minimap ping code to not be in the middle of minimap",
					"Pulse cooldown code to prevent error if trying to use it when it is off",
					"Quest icon code for nameplates",
					"Quest notifier to be less intrusive when announcing",
					"Raid debuffs lib to use our cooldown timer",
					"Sim craft addon skin code and renabled it",
					"Skip cinematic code to be less intrusive (spacebar)",
					"Sort minimap button code",
					"Unitframe code for sizing health/power properly (player, target, tot, pet, focus, focustarget, party and raid)",
				},
			},
		},
	},
}

K.Changelog = KKUI_Changelog
