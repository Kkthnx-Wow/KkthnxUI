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
		version = "10.6.6 - Patch 11.2.0",
		date = "2025-10-12",
		description = "New compact party frames, handy chat buttons, and lots of polish. We fixed bugs, cleaned up code, and made things snappier overall.",
		changes = {
			["New Features"] = {
				"SimpleParty - new compact raid-style party frames with full customization",
				"Chat frame buttons for quick copy, config access, and roll features",
				"Phase indicators now properly handle phased group members",
				"Spell cast visual effects for LibActionButton",
			},
			["Improvements"] = {
				"Party frames can now use traditional or compact layouts",
				"Better range detection for party frames",
				"Cleaner party frame and collection skins",
				"Tag icons sized better for readability",
				"Gold DataText shows more accurate info",
				"Chat buttons are easier to position and toggle",
				"Installer loads faster with better memory management",
				"Tutorial screens look nicer with color-coded pages",
				"Duel decline now handles PvP and pet duels separately",
			},
			["Bug Fixes"] = {
				"Scrapping machine now properly shows item levels and applies hooks correctly",
				"StaticPopup skins display consistently",
				"Party frame elements load in the correct order",
			},
			["Performance"] = {
				"Party frames update less frequently (only when needed)",
				"Phase indicators don't spam unnecessary updates",
				"Chat buttons initialize faster",
			},
		},
	},

	{
		version = "10.6.4 - Patch 11.2.0",
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
}
