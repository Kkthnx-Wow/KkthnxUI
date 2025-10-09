local K = KkthnxUI[1]

-- Changelog data structure
-- Each entry supports:
--   version: "X.Y.Z" (required)
--   date: "YYYY-MM-DD" (optional)
--   description: "Brief summary of this version" (optional)
--   changes: table of sections, each with:
--     - section name (e.g., "General", "Performance", "Bug Fixes")
--     - array of change strings
--
-- Example:
-- {
--   version = "1.0.0",
--   date = "2025-01-15",
--   description = "Major overhaul with new features and performance improvements",
--   changes = {
--     ["General"] = { "Change 1", "Change 2" },
--     ["Performance"] = { "Optimization 1" },
--   }
-- }

K.ChangelogData = {
	{
		version = "[10.6.4] - Patch 11.2.0",
		date = "2025-10-08",
		description = "Mythic raid upgrade! 104 files changed with thousands of lines improved. Turbo-charged performance, shiny new features, and massive code refactoring. Your UI is now faster, flashier, and ready to crit!",
		changes = {
			["New Features"] = {
				"Added new changelog system with sectioned entries, WoW texture icons, and version tracking",
				"Implemented 'Focus on latest version' checkbox to highlight recent changes",
				"Added clickable Discord, GitHub, and Issues buttons with helpful tooltips",
				"Added changelog summary counts (Bug Fixes, New Features, Performance, etc.)",
				"Added separator lines between changelog versions for better readability",
				"Added ColorUnusableItems option to highlight items you can't use in bags",
				"Added FilterLegacy option for bag filtering",
				"Added UseRaidForParty option to use raid frames for party members",
				"Added QueueTimerAudio, QueueTimerWarning, and QueueTimerHideOtherTimers settings",
				"Added AnnounceWorldQuests option for quest announcements",
				"Added QuestProgressEveryNth setting to control quest progress frequency",
				"DataText bars can now be moved independently for better customization",
				"Added ISNEW tags for new features in the UI",
				"Added SetIgnoreParentAlpha method to border system for better transparency control",
			},
			["Improvements"] = {
				"Reverted to LibUnfit-1.0 library for improved item filtering and compatibility",
				"Completely refactored GUI configuration with 626 additions and 827 deletions for better organization",
				"Enhanced AutoQuest data lists with better documentation and structure",
				"Improved cargBags library: container, core, implementation, and item button systems",
				"Updated bag filters, layouts, and plugins (bagBar, bagTabs, searchBar, tagDisplay)",
				"Enhanced oUF elements: auras, class power, health, portrait, power, runes, stagger, and tags",
				"Improved Guild datatext for better performance and stability",
				"Enhanced MicroMenu and LeaveVehicle action bar elements",
				"Updated various announcement modules: Interrupt, ItemAlert, Keystone, QuestNotifier, RareAlert, ResetInstance",
				"Improved AuraWatch system and core aura functionality",
				"Enhanced automation modules: AutoOpen, BadBuffs, DeclineDuel, Goodbye, Quest, Screenshot, SetRole, SkipCinematic, Summon",
				"Renamed AutoSkipCinematic to ConfirmCinematicSkip for clarity",
				"Removed redundant AutoOpenItems setting (merged into automation)",
				"Updated chat modules: History and Rename for better functionality",
				"Enhanced datatext elements: Friends, Gold, Guild, and Time",
				"Improved inventory filtering system and core functionality",
				"Updated map elements: MapReveal and Minimap improvements",
				"Enhanced miscellaneous modules: AFKCam, ExpRep, ParagonRep, QueueTimer, RaidTool, yClassColors",
				"Removed ParagonEnable setting (functionality integrated)",
				"Updated skin modules: CharacterFrame, ChatFrame, UIWidgets, and QuestNavigation",
				"Improved tooltip core functionality",
				"Enhanced UnitFrames: Castbar, Range, Tags, and raid debuffs",
				"Updated group frames: Party and PartyPet",
				"Improved unit frames: Arena, Boss, Focus, FocusTarget, Nameplates, Pet, Target, TargetOfTarget",
				"Enhanced oUF plugins: AuraTrack and RaidDebuffs",
			},
			["Bug Fixes"] = {
				"Fixed scrapping UI errors that were causing unexpected behavior",
				"Fixed bank and warband bank not updating properly",
				"Fixed raid and party frame visibility issues",
				"Resolved cargBags implementation.lua errors affecting bag functionality",
				"Fixed various GUI configuration display and interaction issues",
				"Fixed cooldown display issues in action bars",
				"Fixed keybind overlay problems",
				"Corrected UIWidgets errors in Blizzard frames",
				"Fixed chat history and rename module bugs",
				"Resolved datatext update and display issues",
				"Fixed inventory filter edge cases",
				"Corrected minimap and world map display problems",
			},
			["Performance"] = {
				"Optimized changelog data structure for faster loading times",
				"Improved bag update mechanisms to reduce lag (5619 additions, 5645 deletions)",
				"Enhanced datatext update frequency and efficiency",
				"Streamlined oUF element updates for better frame rendering",
				"Optimized cargBags core for faster bag operations",
				"Reduced memory footprint by consolidating duplicate code",
				"Improved event handler efficiency across all modules",
			},
		},
	},

	{
		version = "[10.6.0] - 2024-12-19 - Patch 11.0.7 - Siren Isle",
		date = "2024-12-19",
		description = "This update introduces key fixes, optimizations, and new features for KkthnxUI. We've focused on improving performance, enhancing the user experience, and resolving reported issues to ensure a smoother, more reliable interface.",
		changes = {
			["Performance"] = {
				"Updated our loading process to prevent nil values",
				"Started to add checks to many functions and code for better error handling and stability",
				"Updated action bar code for better responsiveness and overall performance",
			},
			["Bug Fixes"] = {
				"Fixed an error in QuickJoin.lua to prevent unexpected behavior",
				"Fixed health announce module from throwing nil value if pet name was nil",
				"Fixed nameplateSelectedScale CVar to ensure proper scaling on nameplates",
				"Belt will no longer bug you about not having a belt enchant, reducing unnecessary alerts",
				"Fixed keystone announce module to ensure proper announcement functionality",
			},
			["Improvements"] = {
				"Updated Nameplate and Aura Watch auras to ensure proper display and tracking",
				"Updated interrupt module to avoid announcing certain spells, reducing spam in chat",
				"Updated oUF to the latest version for improved unit frame handling and functionality",
			},
			["New Features"] = {
				"Testing a chat filter to block pointless monster spam, leading to a cleaner chat experience",
			},
		},
	},

	{
		version = "[10.5.9] - 2024-11-17 - Patch 11.0.5",
		date = "2024-11-17",
		description = "This update brings various performance improvements, bug fixes, and visual refinements to KkthnxUI. We've focused on optimizing code, enhancing functionality, and resolving reported issues for a smoother user experience.",
		changes = {
			["Performance"] = {
				"Started more caching for performance in various files",
				"Formatted all files for improved readability and consistency",
			},
			["Improvements"] = {
				"Updated various Aura Watch auras to ensure proper functionality",
				"Updated Nameplate auras",
				"Updated LibAnim to the latest version for enhanced animation support",
				"Updated LibDeflate to the latest version for improved compression and data handling",
			},
			["Bug Fixes"] = {
				"Removed all Death Counter settings due to redundancy",
				"Fixed labels in the config menu overlapping the scrollbar",
				"Fixed Auto Screenshot to stop if the achievement has already been earned",
				"Fixed Quick Join auto-invite button behavior",
				"Fixed dropdown menu in Delves not appearing on the correct frame level",
				"Fixed double progress text in time data text",
				"Fixed Coords functionality that was broken in recent builds",
				"Fixed Guild data text error caused by a new patch",
			},
			["New Features"] = {
				"Added Extra Button range code for better user interaction with Extra Buttons",
				"Added action bar fader for smoother UI transitions",
				"Added MDT (Mythic Dungeon Tools) integration to Nameplate progress",
				"Added back professions page skinning for improved UI consistency",
				"Only show gold in data text if the amount is over 100 gold",
				"Added Instant Cast and Lock Action Bars functionality",
				"Fixed typo in the installer for tutorial steps",
				"Added a 1-click skip button to speed up the installation process",
			},
		},
	},

	{
		version = "[10.5.8] - 2024-10-12 - Patch 11.2",
		date = "2024-10-12",
		description = "This update brings improvements, bug fixes, and a more polished experience for KkthnxUI users. We've refined visuals, optimized performance, and added new features.",
		changes = {
			["Improvements"] = {
				"Added skinning for the Menu to match the overall UI aesthetic",
				"Refactored the Minimap menu by adding icons and improving functionality",
				"Updated and refactored GroupLoot visuals for a cleaner experience",
				"Enhanced ExtraQuestButton to better fit with the UI theme",
				"Recycled tables cleared in the AuraWatch module to improve performance",
				"Updated the AlreadyKnown module and fixed API compatibility issues",
				"Updated various Auras to ensure consistency and functionality",
				"Refactored HealPrediction for unit frames to be more efficient",
				"Updated LibRangeCheck for improved range detection",
				"Refactored most colors to be easier on the eyes for extended gameplay",
				"Fixed ManaBars in raid frames and added an option to display all power types",
				"Fixed ColorPicker errors that were causing inconsistent color selection",
			},
			["Bug Fixes"] = {
				"Fixed an AuraWatch error in the GUI that caused occasional crashes",
				"Added new bag filters to better organize inventory management",
			},
			["New Features"] = {
				"Added a new /kk help command to provide guidance on available commands",
			},
		},
	},

	{
		version = "[10.5.7] - 2024-09-18 - Patch 11.2",
		date = "2024-09-18",
		description = "This update brings new aura adjustments, quality-of-life changes, and some bug fixes to ensure smoother gameplay. We've also made updates to key spells, buffs, and UI elements to keep your experience running smoothly.",
		changes = {
			["Bug Fixes"] = {
				"Fixed an issue with nil values in oUF auras",
				"Resolved an issue where realm could return nil, causing errors",
				"Updated TradeTabs to fix filter buttons that weren't working correctly",
			},
			["Improvements"] = {
				"Updated and refined aura lists, including improvements for Hunter and other classes",
				"Removed deprecated auras for a cleaner experience",
				"Updated trinkets to ensure they are properly tracked and utilized in gameplay",
				"Added new tier charge ID for upcoming updates",
				"Updated major spells to keep them aligned with current content",
				"Updated nameplate filters to reflect current spells and buffs, ensuring a better visual representation",
				"Updated food and buff tracking in the buff checker to support newer consumables",
				"Refined raid buff checks for a more streamlined experience",
				"Updated UI skins to accommodate changes in Delves",
				"Added a cosmetic item indicator to show whether an item is already known for cosmetic items",
				"Removed Nzoth-related content and added new weekly content in Timewalking Weekly",
			},
		},
	},

	{
		version = "[10.5.6] - 2024-09-08 - Patch 110002",
		date = "2024-09-08",
		description = "This update is here to fix those annoying bugs and make your KkthnxUI experience even better. We've also added a few neat tricks and improvements—because who doesn't like a bit of polish?",
		changes = {
			["Bug Fixes"] = {
				"Fixed that pesky Interrupt nil error—turns out we left an old function call hanging around. Oops!",
				"Added some safety checks for libraries, because nobody likes surprises when a library decides to take a day off",
			},
			["Improvements"] = {
				"Your enemy nameplates now have a class icon check. No more mysterious vanishing icons—because they belong right where you can see 'em!",
				"Warband Bank got some love with various updates and improvements. It's less clunky, and you'll like it more now. Trust us",
				"Bags filter list updated: it's now smart enough to include the Warband Bank. Because, really, how did we miss that?",
				"Added support for SharedMedia—probably. Let's be honest, we're still testing this one, but go ahead and play around with it!",
				"Installer got a makeover! Now it's smoother and less likely to throw a fit while setting up. It might even say 'thank you'—who knows?",
				"We cleaned up the micromenu code, making it less of a tangled mess. Oh, and that annoying mouseover issue? Yeah, it's gone. Bye-bye!",
				"Added some extra checks for IsPartyWalkIn, because walking into parties unprepared? Not on our watch",
			},
		},
	},

	{
		version = "[10.5.5] - 2024-08-24 - Patch 11.0",
		date = "2024-08-24",
		description = "This release introduces key updates and optimizations to KkthnxUI, improving overall performance and compatibility.",
		changes = {
			["Improvements"] = {
				"Optimized and updated libchangelog to enhance logging features",
				"Fixed an issue with keybindings in the UI caused by a nil error",
				"Updated LibRangeCheck to the latest version",
				"Removed reputation chat alerts and added functionality to change and cache a global variable",
				"Fixed the AutoScreenshot module to restore its functionality",
				"Updated the Automation API for quests to match the latest patch changes",
				"Removed a leftover snowman from the AFK screen",
				"Fixed and updated TradeTabs for better profession management",
			},
		},
	},

	{
		version = "[10.5.4] - 2024-08-23 - Patch 11.0",
		date = "2024-08-23",
		description = "This update includes important fixes and improvements to enhance the functionality and visual experience of KkthnxUI.",
		changes = {
			["Bug Fixes"] = {
				"Fixed a bug where range checks were not working on certain units",
				"Adjusted the minimap queue timer size and font for better readability",
				"Removed old code related to status reports, improving overall efficiency and maintainability",
			},
		},
	},

	{
		version = "[10.5.2] - 2024-08-23 - Patch 11.0",
		date = "2024-08-23",
		description = "This update includes significant bug fixes, visual improvements, and feature enhancements aimed at providing a smoother and more reliable experience.",
		changes = {
			["Improvements"] = {
				"Updated the version out of date notification system with improved visuals and messaging",
				"Improved compatibility with third-party addons by handling minimap recycling for features such as TomTom and WIM",
				"Implemented new safeguards in unitframe tags to improve the handling of text and title displays",
				"Updated several AuraWatch lists and filters to ensure accurate tracking for all relevant classes",
			},
			["Bug Fixes"] = {
				"Fixed several range-related issues that caused incorrect fading behavior during combat",
				"Resolved an error related to item count tracking",
			},
		},
	},

	{
		version = "[10.5.1] - 2024-08-22 - Patch 11.0",
		date = "2024-08-22",
		description = "This update includes various performance optimizations across the codebase to improve maintainability and efficiency. These optimizations enhance overall functionality and responsiveness.",
		changes = {
			["Performance"] = {
				"Implemented global caching for frequently used functions and API calls to reduce redundant operations and improve performance",
				"Optimized the LossOfControl frame reskinning process to ensure better performance and code clarity",
				"Streamlined the header reskinning function for ObjectiveTracker, reducing code duplication and improving efficiency",
				"Improved tooltip handling for mount sources and auras, optimizing lookup processes and reducing performance impact",
			},
			["Bug Fixes"] = {
				"Fixed an issue with an empty icon in the aura watch caused by incorrect calls being used",
				"Fixed the `ExpansionLandingPageMinimapButton` not working on right-click",
				"Fixed the minimap tracking icon always being shown",
				"Fixed the tracking menu not opening with a right-click on the minimap tracking button",
			},
		},
	},

	{
		version = "[10.5.0] - 2024-08-22 - Patch 11.0",
		date = "2024-08-22",
		description = "The KkthnxUI has been updated to align with The War Within expansion. Stay engaged with the community on Discord for the latest developments, updates, and discussions.",
		changes = {
			["General"] = {
				"Major update to support The War Within expansion and Patch 11.0",
				"Significant backend improvements and new features added",
			},
			["Improvements"] = {
				"Updated and refined various modules for compatibility with The War Within expansion",
				"Upgraded Warbank functionalities and ensured integration with the latest game systems",
				"Updated core libraries to the latest versions, enhancing stability and performance",
				"Improved multiple UI elements to ensure smooth operation in the new expansion",
			},
			["Bug Fixes"] = {
				"Resolved various minor bugs reported by the community",
				"Fixed issues related to group functionality and unit frames",
			},
			["Performance"] = {
				"Thorough optimizations across all modules to ensure better performance and faster response times",
				"Refined the codebase for enhanced performance, especially in high-stress environments",
			},
		},
	},

	{
		version = "[10.4.9] - 2023-11-24 - Patch 10.2",
		date = "2023-11-24",
		description = "Stay connected with the KkthnxUI community on our Discord server for the latest updates and engaging discussions about the addon's development and features.",
		changes = {
			["General"] = {
				"Enhanced overall addon functionality to align with the latest World of Warcraft Patch 10.2 updates",
			},
			["Improvements"] = {
				"Updated and fixed issues with GroupLoot functionality",
				"Upgraded LibActionButton to the latest version",
				"Implemented updates to LibRangeCheck",
				"Refined yClassColors",
				"Enhanced unit frame tags",
			},
			["Bug Fixes"] = {
				"Attempted to resolve issues with the Goodbye module not functioning correctly at the end of instances",
			},
			["Performance"] = {
				"Conducted thorough refactoring of yClassColors, streamlining the code for better performance and maintainability",
				"Continued efforts to optimize code and UI elements for an improved user experience and addon responsiveness",
			},
		},
	},

	{
		version = "[10.4.8] - 2023-11-22 - Patch 10.2",
		date = "2023-11-22",
		description = "Don't forget to join our KkthnxUI Discord server to stay up-to-date on the latest news and discussions about KkthnxUI and its future development.",
		changes = {
			["General"] = {
				"Continued efforts to enhance the user interface experience with various updates and adjustments in line with the latest World of Warcraft updates",
			},
			["Improvements"] = {
				"Optimized UI memory usage and performed code cleanup for better performance",
				"Updated README.md to provide clearer, more current information",
				"Improved QuickJoin functionality for a smoother user experience",
				"Updated loot and fixed issues with mirrorbars for enhanced gameplay",
				"Reworked spec in tooltip and increased spellflyout spacing for better visibility and user interaction",
			},
			["Bug Fixes"] = {
				"Addressed and attempted to fix two taint issues for improved stability",
				"Performed cleanup and bug fixes related to Blizzard's UI elements",
				"Resolved a protected item range check issue ('IsItemInRange')",
			},
			["Performance"] = {
				"Conducted a thorough cleanup to enhance code clarity and maintainability",
				"Improved formatting to use UPU over UPF for consistency and readability",
				"Introduced adjustments to unitframe range stuff for better performance",
			},
		},
	},

	{
		version = "[10.4.7] - 2023-5-5 - Patch 10.1",
		date = "2023-05-05",
		description = "These updates and code improvements aim to provide a better user interface experience and enhance the overall performance and maintainability of the UI codebase in the Dragonflight Patch 10.1: Embers of Neltharion Patch.",
		changes = {
			["Improvements"] = {
				"Updated the UI to align with the Dragonflight Patch 10.1: Embers of Neltharion Patch",
				"Made various improvements to enhance the user experience",
				"Improved code formatting to ensure better readability",
				"Reorganized the code for improved organization and maintainability",
				"Introduced more descriptive names for variables and functions",
			},
			["Performance"] = {
				"Optimized the code for improved performance and efficiency",
				"Reviewed and refactored code to eliminate unnecessary computations and improve overall speed",
			},
		},
	},

	{
		version = "[10.4.6] - 2023-1-22",
		date = "2023-01-22",
		description = "Improved code readability and performance with various bug fixes and new features.",
		changes = {
			["General"] = {
				"Improved code readability and performance",
				"Refactored code for better maintainability",
				"Fixed various UI bugs and improved overall stability",
				"Added support for new features and improvements to existing ones",
			},
		},
	},

	{
		version = "[10.4.5] - 2023-1-5",
		date = "2023-01-05",
		changes = {
			["New Features"] = {
				"[AutoOpen] Added combat check to bag check",
				"[Datatext] Added Community Feast",
				"[Datatext] Added support for Elemental Storm & Grand Hunts",
				"[Misc] Added logo + name + version animation popup",
				"[Portraits] Added EVOKER class portraits to our media files",
				"[Tooltip] Added support for mount and toy icons",
				"[Tutorials] Added more tutorials to DIE when you enable the option for it",
				"[Unitframes] Added new combat icon",
			},
			["Improvements"] = {
				"[Border] Changed the texture and brightness of the default KkthnxUI border. You won't notice much of a difference here",
				"[LibActionButton] Changed back to the default lib so MaxDPS / Hekili will work without needing support",
				"[Nameplates] Changed and updated quest icon code",
				"[Skins] Changed professions icons to be smaller so they do not overlap",
			},
			["Bug Fixes"] = {
				"[Core] Fixed AutoConfirm, AutoGreed, Grouploot and Fasterloot not loading",
				"[Datatext] Fixed friends throwing a nil value",
				"[GroupLoot] Fixed all issues related to group loot",
				"[Inventory] Fixed setitems to check for nil",
				"[Skins] Fixed Details not checking for the proper default texture",
				"[Core] Removed various leftover debug prints",
			},
		},
	},

	{
		version = "[10.4.4] - 2022-12-26",
		date = "2022-12-26",
		changes = {
			["New Features"] = {
				"[Actionbars] Texture color will now properly color actionbars too",
				"[Minimap] We now have our old calendar icon back",
				"[Misc] Support for killing more annoying tutorials",
				"[Movers] They now shine <3",
				"[Raidframes] Support Dragonflight debuffs",
				"[Skins] ObjectiveTracker skin is now complete",
				"[Unitframes] Allow users to turn off unitframe fading when out of range",
			},
			["Improvements"] = {
				"[Config] Update spell list for reminders",
				"[Datatext] Rename module from infobar to datatext",
				"[Lib] Update LibActionButton to latest version",
				"[Raidtool] Updated codebase for our raidtool",
				"[Unitframes] Refactor castbars to better support spell stages like blizzard has it",
				"[Unitframes] Updated how we handle bolster for nameplates",
			},
			["Bug Fixes"] = {
				"[Automation] AutoKeystone should work once again",
				"[Automation] AutoOpen items should work once again",
				"[Inventory] Fix typo for BagReagent",
				"[Maps] Map reveal should now properly show its overlay on undiscovered zones",
				"[Misc] Fixed and enabled MDGuildBest",
				"[Unitframes] Disabled combat fader because portraits are buggy right now",
			},
		},
	},

	{
		version = "[10.4.3] - 2022-12-19",
		date = "2022-12-19",
		changes = {
			["New Features"] = {
				"[Aurawatch] Support for Auras for Dragonflight",
				"[Chat] Reimplement chat link hovering module",
				"[Nameplates] Support soft-targeting updates",
				"[Tooltip] Support for anchoring tooltip in config",
				"[Unitframes] All frames to use text scaling option",
				"[Unitframes] Support buffs/debuffs for Dragonflight for raidframes",
				"[Unitframes] We should have castbars for all frames now",
			},
			["Improvements"] = {
				"[AutoQuest] Make sure we check gossip id",
				"[Bags] Items we can not use in our bags will shown a red sign on them now",
				"[Bags] Use LibCustomGlow for new items in bags",
				"[Datatext] Apply new tab style to durability datatext",
			},
			["Bug Fixes"] = {
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
				"[Chat] AddOn blocker is pointless. I do not feel we should block stuff",
				"[Datatext] Torghast infomation is a thing of the past",
			},
		},
	},

	{
		version = "[10.3.8 - Dragonflight] - 2022-11-30",
		date = "2022-11-30",
		description = "Early release for Dragonflight - expect bugs and issues. Join our discord to report any issues or ask questions.",
		changes = {
			["General"] = {
				"Support for DF release",
				"This is an early release so expect bugs and issues",
				"Join our discord to report any issues or ask questions",
			},
		},
	},

	{
		version = "[10.3.7] - 2022-8-24",
		date = "2022-08-24",
		changes = {
			["New Features"] = {
				"Cast Target for nameplates can be toggled off and on now",
				"New statusbars added to the textures dropdown",
				"Targeted nameplates can now be scaled in options",
				"Toy train is now muted for muted module (We can all rest now)",
				"You can now adjust the amount of smoothness statusbars have",
			},
			["Bug Fixes"] = {
				"MDGuildBest throwing a nil error",
				"Micromenu now has mouseover again",
			},
			["Improvements"] = {
				"Cleaned the BagsBar module",
				"Cleaned the GUI module for statusbars",
				"Refactored the UI is outdated notice",
				"Updated unitframe range Lib",
			},
		},
	},

	{
		version = "[10.3.6] - 2022-8-21",
		date = "2022-08-21",
		changes = {
			["Bug Fixes"] = {
				"ObjectiveTracker throwing nil error",
			},
			["Improvements"] = {
				"No need to break on keystone module return is enough",
			},
		},
	},

	{
		version = "[10.3.5] - 2022-8-21",
		date = "2022-08-21",
		changes = {
			["New Features"] = {
				"All KkthnxUI Blizzard skinning now can be toggled off",
				"KkthnxUI will not automatically add the new services chat channel",
				"More globals cached and more",
				"More statusbars to pick from",
				"New Micromenu style from Dragonflight",
				"New Safequeue like timer for LFD and PVP timers",
				"New actionbar/bags button backdrop texture from Dragonflight",
				"StatusReport is now back and stylish",
			},
			["Bug Fixes"] = {
				"Actionbars not being properly stripted and styled",
				"Border throwing an error with other addons and itself",
				"Filter mute cache properly fixed",
				"Gold datatext had the wrong events which caused it to not update",
				"LibSharedMeida was not importing our textures and borders",
				"Mount source tooltip not growing as it should",
			},
			["Improvements"] = {
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
				"Global fonts section (Use a font folder for your own fonts)",
				"Tabbiner is gone (Use another addon)",
			},
		},
	},
	-- Add new versions above this line, newest first
}
