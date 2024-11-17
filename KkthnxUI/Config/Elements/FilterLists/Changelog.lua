local K = KkthnxUI[1]

local KKUI_Changelog = {
	-- {
	-- 	Version = "[99.99.99] - 2080-04-01 - Patch 42.0",
	-- 	General = "Brace yourself for the ultimate KkthnxUI update! Packed with intergalactic features, time-traveling bugs, and a new AI that may or may not take over your computer.",

	-- 	Sections = {

	-- 		{
	-- 			Header = "Quantum Enhancements",
	-- 			Entries = {
	-- 				"Added support for quantum computers. Your UI now renders simultaneously in all possible universes.",
	-- 				"Fixed a rare issue where the minimap would collapse into a black hole when tracking too many quests.",
	-- 				"Added a feature where the UI automatically adjusts to your emotional state. Feeling down? KkthnxUI will cheer you up with random cat GIFs.",
	-- 			},
	-- 		},

	-- 		{
	-- 			Header = "AI Integration",
	-- 			Entries = {
	-- 				"Your UI is now sentient. It will greet you every morning, remind you to hydrate, and occasionally ask for a day off.",
	-- 				"Implemented a new feature where KkthnxUI will automatically play Call of Duty for you and pretend you're good at it.",
	-- 				"The UI will now analyze your gameplay and send passive-aggressive reminders when you keep standing in fire. 'Seriously, move, already!'",
	-- 			},
	-- 		},

	-- 		{
	-- 			Header = "Space-Time Bugs",
	-- 			Entries = {
	-- 				"Fixed a time-travel bug where your action bars would revert to the year 2020 every time you summoned a mount.",
	-- 				"Resolved an issue where players from the future could send you in-game mail from Patch 100.0, causing confusion and tears.",
	-- 				"Temporarily removed the 'Time Travel to Vanilla WoW' button. We're still cleaning up the mess from the last incident.",
	-- 			},
	-- 		},

	-- 		{
	-- 			Header = "Visual Overhauls",
	-- 			Entries = {
	-- 				"Replaced the health bars with mood rings. Now you can see exactly how your character is feeling based on color.",
	-- 				"Introduced 4D textures. Make sure you have your special glasses on to experience the UI in an extra dimension.",
	-- 				"Added a 'Disco Mode' option for raids. Be the life of the party as your UI dances along to the beat of your wipe.",
	-- 			},
	-- 		},

	-- 		{
	-- 			Header = "Version Bump",
	-- 			Entries = {
	-- 				"Bumped the version to 99.99.99 because we’re basically at UI enlightenment now.",
	-- 				"Patch 42.0 confirmed to be the answer to life, the universe, and everything.",
	-- 				"Increased the version number so that even future alien civilizations will know you're up-to-date.",
	-- 			},
	-- 		},
	-- 	},
	-- },

	{
		Version = "[10.5.9] - 2024-11-17 - Patch 11.0.5",
		General = "This update brings various performance improvements, bug fixes, and visual refinements to KkthnxUI. We've focused on optimizing code, enhancing functionality, and resolving reported issues for a smoother user experience.",

		Sections = {
			{
				Header = "Performance Improvements",
				Entries = {
					"Started more caching for performance in various files.",
					"Formatted all files for improved readability and consistency.",
				},
			},

			{
				Header = "Aura Watch and Nameplates",
				Entries = {
					"Updated various Aura Watch auras to ensure proper functionality.",
					"Updated Nameplate auras.",
				},
			},

			{
				Header = "Bug Fixes and Optimizations",
				Entries = {
					"Removed all Death Counter settings due to redundancy.",
					"Fixed labels in the config menu overlapping the scrollbar.",
					"Fixed typo in Lumos Evoker for improved clarity.",
					"Fixed Auto Screenshot to stop if the achievement has already been earned.",
					"Fixed Quick Join auto-invite button behavior.",
					"Fixed dropdown menu in Delves not appearing on the correct frame level.",
					"Fixed double progress text in time data text.",
					"Fixed Coords functionality that was broken in recent builds.",
					"Fixed Guild data text error caused by a new patch.",
				},
			},

			{
				Header = "Library Updates",
				Entries = {
					"Updated LibAnim to the latest version for enhanced animation support.",
					"Updated LibDeflate to the latest version for improved compression and data handling.",
				},
			},

			{
				Header = "New Features and Enhancements",
				Entries = {
					"Added Extra Button range code for better user interaction with Extra Buttons.",
					"Added action bar fader for smoother UI transitions.",
					"Added MDT (Mythic Dungeon Tools) integration to Nameplate progress.",
					"Added back professions page skinning for improved UI consistency.",
					"Only show gold in data text if the amount is over 100 gold.",
					"Added Instant Cast and Lock Action Bars functionality.",
				},
			},

			{
				Header = "Installer and Setup Fixes",
				Entries = {
					"Fixed typo in the installer for tutorial steps.",
					"Added a 1-click skip button to speed up the installation process.",
				},
			},
		},
	},

	{
		Version = "[10.5.8] - 2024-10-12 - Patch 11.2",
		General = "This update brings improvements, bug fixes, and a more polished experience for KkthnxUI users. We've refined visuals, optimized performance, and added new features.",

		Sections = {
			{
				Header = "UI Enhancements",
				Entries = {
					"Added skinning for the Menu to match the overall UI aesthetic.",
					"Refactored the Minimap menu by adding icons and improving functionality.",
					"Updated and refactored GroupLoot visuals for a cleaner experience.",
					"Enhanced ExtraQuestButton to better fit with the UI theme.",
				},
			},

			{
				Header = "Module Improvements",
				Entries = {
					"Recycled tables cleared in the AuraWatch module to improve performance.",
					"Updated the AlreadyKnown module and fixed API compatibility issues.",
					"Updated various Auras to ensure consistency and functionality.",
					"Refactored HealPrediction for unit frames to be more efficient.",
					"Updated LibRangeCheck for improved range detection.",
				},
			},

			{
				Header = "Color and Visual Refinements",
				Entries = {
					"Refactored most colors to be easier on the eyes for extended gameplay.",
					"Fixed ManaBars in raid frames and added an option to display all power types.",
					"Fixed ColorPicker errors that were causing inconsistent color selection.",
				},
			},

			{
				Header = "Bug Fixes and Optimizations",
				Entries = {
					"Fixed an AuraWatch error in the GUI that caused occasional crashes.",
					"Added new bag filters to better organize inventory management.",
				},
			},

			{
				Header = "New Features and Commands",
				Entries = {
					"Added a new /kk help command to provide guidance on available commands.",
				},
			},
		},
	},

	{
		Version = "[10.5.7] - 2024-09-18 - Patch 11.2",
		General = "This update brings new aura adjustments, quality-of-life changes, and some bug fixes to ensure smoother gameplay. We’ve also made updates to key spells, buffs, and UI elements to keep your experience running smoothly.",

		Sections = {

			{
				Header = "Bug Fixes",
				Entries = {
					"Fixed an issue with nil values in oUF auras.",
					"Resolved an issue where realm could return nil, causing errors.",
					"Updated TradeTabs to fix filter buttons that weren't working correctly.",
				},
			},

			{
				Header = "Auras",
				Entries = {
					"Updated and refined aura lists, including improvements for Hunter and other classes.",
					"Removed deprecated auras for a cleaner experience.",
				},
			},

			{
				Header = "Spells & Trinkets",
				Entries = {
					"Updated trinkets to ensure they are properly tracked and utilized in gameplay.",
					"Added new tier charge ID for upcoming updates.",
					"Updated major spells to keep them aligned with current content.",
				},
			},

			{
				Header = "Nameplates",
				Entries = {
					"Updated nameplate filters to reflect current spells and buffs, ensuring a better visual representation.",
				},
			},

			{
				Header = "Buff Checker",
				Entries = {
					"Updated food and buff tracking in the buff checker to support newer consumables.",
					"Refined raid buff checks for a more streamlined experience.",
				},
			},

			{
				Header = "Skins & UI",
				Entries = {
					"Updated UI skins to accommodate changes in Delves.",
					"Added a cosmetic item indicator to show whether an item is already known for cosmetic items.",
				},
			},

			{
				Header = "Weekly Updates",
				Entries = {
					"Removed Nzoth-related content and added new weekly content in Timewalking Weekly.",
				},
			},
		},
	},

	{
		Version = "[10.5.6] - 2024-09-08 - Patch 110002",
		General = "This update is here to fix those annoying bugs and make your KkthnxUI experience even better. We’ve also added a few neat tricks and improvements—because who doesn’t like a bit of polish?",

		Sections = {

			{
				Header = "Bug Fixes",
				Entries = {
					"Fixed that pesky Interrupt nil error—turns out we left an old function call hanging around. Oops!",
					"Added some safety checks for libraries, because nobody likes surprises when a library decides to take a day off.",
				},
			},

			{
				Header = "Nameplates",
				Entries = {
					"Your enemy nameplates now have a class icon check. No more mysterious vanishing icons—because they belong right where you can see 'em!",
				},
			},

			{
				Header = "Warband Bank",
				Entries = {
					"Warband Bank got some love with various updates and improvements. It's less clunky, and you'll like it more now. Trust us.",
					"Bags filter list updated: it’s now smart enough to include the Warband Bank. Because, really, how did we miss that?",
				},
			},

			{
				Header = "SharedMedia Integration",
				Entries = {
					"Added support for SharedMedia—probably. Let’s be honest, we’re still testing this one, but go ahead and play around with it!",
				},
			},

			{
				Header = "Installer Updates",
				Entries = {
					"Installer got a makeover! Now it’s smoother and less likely to throw a fit while setting up. It might even say ‘thank you’—who knows?",
				},
			},

			{
				Header = "Micromenu Refactoring",
				Entries = {
					"We cleaned up the micromenu code, making it less of a tangled mess. Oh, and that annoying mouseover issue? Yeah, it’s gone. Bye-bye!",
				},
			},

			{
				Header = "Party Walk-In",
				Entries = {
					"Added some extra checks for IsPartyWalkIn, because walking into parties unprepared? Not on our watch.",
				},
			},
		},
	},

	{
		Version = "[10.5.5] - 2024-08-24 - Patch 11.0",
		General = "This release introduces key updates and optimizations to KkthnxUI, improving overall performance and compatibility.",

		Sections = {

			{
				Header = "UI and Functionality Updates",
				Entries = {
					"Optimized and updated libchangelog to enhance logging features.",
					"Fixed an issue with keybindings in the UI caused by a nil error.",
					"Updated LibRangeCheck to the latest version.",
					"Removed reputation chat alerts and added functionality to change and cache a global variable.",
					"Fixed the AutoScreenshot module to restore its functionality.",
					"Updated the Automation API for quests to match the latest patch changes.",
					"Removed a leftover snowman from the AFK screen.",
					"Fixed and updated TradeTabs for better profession management.",
				},
			},

			{
				Header = "Version Bump",
				Entries = {
					"Increased the addon version to 10.5.5 to reflect the latest fixes and improvements.",
				},
			},
		},
	},

	{
		Version = "[10.5.4] - 2024-08-23 - Patch 11.0",
		General = "This update includes important fixes and improvements to enhance the functionality and visual experience of KkthnxUI.",

		Sections = {

			{
				Header = "Appearance and Functionality Updates",
				Entries = {
					"Fixed a bug where range checks were not working on certain units.",
					"Adjusted the minimap queue timer size and font for better readability.",
				},
			},

			{
				Header = "Code Cleanup",
				Entries = {
					"Removed old code related to status reports, improving overall efficiency and maintainability.",
				},
			},

			{
				Header = "Version Bump",
				Entries = {
					"Increased the addon version to 10.5.4 to reflect the latest fixes and enhancements.",
				},
			},
		},
	},

	{
		Version = "[10.5.2] - 2024-08-23 - Patch 11.0",
		General = "This update includes significant bug fixes, visual improvements, and feature enhancements aimed at providing a smoother and more reliable experience.",

		Sections = {

			{
				Header = "Appearance and Functionality Updates",
				Entries = {
					"Updated the version out of date notification system with improved visuals and messaging.",
					"Improved compatibility with third-party addons by handling minimap recycling for features such as TomTom and WIM.",
				},
			},

			{
				Header = "Bug Fixes",
				Entries = {
					"Fixed several range-related issues that caused incorrect fading behavior during combat.",
					"Resolved an error related to item count tracking.",
				},
			},

			{
				Header = "Feature Additions and Code Updates",
				Entries = {
					"Implemented new safeguards in unitframe tags to improve the handling of text and title displays.",
					"Updated several AuraWatch lists and filters to ensure accurate tracking for all relevant classes.",
				},
			},

			{
				Header = "Version Bump",
				Entries = {
					"Increased the addon version to 10.5.2 to reflect the latest fixes and enhancements.",
				},
			},
		},
	},

	{
		Version = "[10.5.1] - 2024-08-22 - Patch 11.0",
		General = "This update includes various performance optimizations across the codebase to improve maintainability and efficiency. These optimizations enhance overall functionality and responsiveness.",

		Sections = {

			{
				Header = "Optimization",
				Entries = {
					"Implemented global caching for frequently used functions and API calls to reduce redundant operations and improve performance.",
					"Optimized the LossOfControl frame reskinning process to ensure better performance and code clarity.",
					"Streamlined the header reskinning function for ObjectiveTracker, reducing code duplication and improving efficiency.",
					"Improved tooltip handling for mount sources and auras, optimizing lookup processes and reducing performance impact.",
				},
			},

			{
				Header = "Bug Fixes",
				Entries = {
					"Fixed an issue with an empty icon in the aura watch caused by incorrect calls being used.",
					"Fixed the `ExpansionLandingPageMinimapButton` not working on right-click.",
					"Fixed the minimap tracking icon always being shown.",
					"Fixed the tracking menu not opening with a right-click on the minimap tracking button.",
				},
			},
		},
	},

	{
		Version = "[10.5.0] - 2024-08-22 - Patch 11.0",
		General = "The KkthnxUI has been updated to align with The War Within expansion. Stay engaged with the community on Discord for the latest developments, updates, and discussions.",
		Sections = {

			{
				Header = "General",
				Entries = {
					"Major update to support The War Within expansion and Patch 11.0.",
					"Significant backend improvements and new features added.",
				},
			},

			{
				Header = "UI Updates",
				Entries = {
					"Updated and refined various modules for compatibility with The War Within expansion.",
					"Upgraded Warbank functionalities and ensured integration with the latest game systems.",
					"Updated core libraries to the latest versions, enhancing stability and performance.",
					"Improved multiple UI elements to ensure smooth operation in the new expansion.",
				},
			},

			{
				Header = "Bug Fixes",
				Entries = {
					"Resolved various minor bugs reported by the community.",
					"Fixed issues related to group functionality and unit frames.",
				},
			},

			{
				Header = "Optimization",
				Entries = {
					"Thorough optimizations across all modules to ensure better performance and faster response times.",
					"Refined the codebase for enhanced performance, especially in high-stress environments.",
				},
			},
		},
	},

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
