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
		version = "10.6.7 - Patch 11.2.5",
		date = "2026-06-11",
		description = "11.2.5 hardening pass: safer hooks, reversible automation toggles, and cherry-picked NexEnhance fixes.",
		changes = {
			["New Features"] = {
				"Automation: Auto-decline guild invites from strangers (friends, BNet friends, and guildmates still allowed)",
				"Miscellaneous: Quick Item Delete is now a reversible setting (defaults on to preserve prior behavior)",
			},
			["Bug Fixes"] = {
				"Tooltip: Guard aura-instance tooltip hooks so missing 11.2.5 APIs no longer error on load",
				"Automation: Auto Screenshot now reads ACHIEVEMENT_EARNED's alreadyEarnedOnAccount flag correctly",
				"Blizzard Fixes: Talent, addon list, guild news, and raid button patches apply when LOD addons are already loaded",
				"Blizzard Fixes: Money tooltip prefix/suffix spacing and tighter PetFrame click hit rect",
				"Skins: Objective Tracker skin guards nil progress/timer bars and missing pool methods",
				"Alert Frames: TalkingHead delayed-load and duplicate hook hardening",
				"ExtraGUI: Open GUI / Open / Manage launcher buttons now toggle their panel closed on a second click (matching the cogwheel) instead of doing nothing",
				"ExtraGUI: Removed the orphaned 'Chat.General' example panel that was unreachable and bound to placeholder Chat settings that did not exist",
				"Nameplate: Removed the duplicate 'Target Nameplate Auras' toggle that appeared in both the Auras and Miscellaneous sections",
				"Nameplate: Fixed the Custom Unit list tooltip showing the literal text 'CustomUnitTip' instead of the real instructions (a duplicate locale key was overriding it)",
				"Nameplate: Aura filter editor edits (whitelist/blacklist/custom units/target NPCs/trash units/major spells) now persist across /reload - additions and removals are saved per-character and re-applied at login instead of being lost",
				"ExtraGUI: Mute Sound IDs add button now reads the input field correctly (CreateTextInput no longer required fragile EditBox child hunting)",
				"ExtraGUI: Power Unit list live portrait refresh no longer errors on target change (rows now track NpcID/Portrait consistently)",
				"Tooltip: Unit standing label no longer errors when a reaction has no FACTION_STANDING_LABEL (nil-safe concat, cherry-picked from NexEnhance)",
				"Collections: AlreadyKnown pet check no longer errors when the collected-count API returns nil",
				"DataText: Durability repair cost now scans tooltip data by field instead of a fixed arg index (survives Blizzard arg reordering) and guards divide-by-zero on missing max durability",
				"DataText: Reputation bar/tooltip no longer mislabels mid-renown major factions (e.g. Renown 4) as 'Paragon'",
				"Loot: Faster Loot now skips locked loot slots (prevents acting on BoP-confirm/in-use slots) and also responds to LOOT_OPENED",
				"Automation: Faster Movie/Cinematic Skip installs its key hooks once, so a live re-toggle no longer stacks duplicate hooks",
			},
			["Improvements"] = {
				"Core: Settings loader now uses schema migrations and safer delta pruning for profile data",
				"Core: WidgetFactory moved into its own load-order-owned core file for cleaner GUI organization",
				"GUI: Unified config palette into a single K.GUITheme so the main config, ExtraGUI, and profile manager share one source of truth (no more drifting copy-pasted colors)",
				"GUI: Centralized shared panel metrics into K.GUILayout so config window dimensions are derived, not copy-pasted",
				"GUI: Split shared config path/default/SavedVariables writes into GUIConfigService.lua so GUI and ExtraGUI use one storage path",
				"GUI: Split Ctrl-hover reset button wiring into GUIResetButtons.lua so main config and ExtraGUI share one undo-button implementation",
				"GUI: Split pending-reload queue and reload prompt behavior into GUIReloadTracker.lua so GUI.lua no longer owns reload state inline",
				"ExtraGUI: Split repeated ActionBar extra-config registration into ExtraGUIActionBars.lua, reducing eight copy-pasted bar panels to one shared registration path",
				"ExtraGUI: Split inventory item-filter extra-config registration into ExtraGUIInventory.lua so filter labels/defaults live in one auditable data table",
				"ExtraGUI: Moved Whisper Invite, custom SoundKit IDs, and DBMCount editing behind focused ExtraGUI panels so the main config stays a clean launcher surface",
				"ExtraGUI: Text-input apply buttons now run the same live-update hooks as Enter/focus-lost, so advanced string settings apply consistently",
				"ExtraGUI: Unified list editors (Mute Sound IDs, Custom/Power Units, aura filter, auto-quest ignore NPCs) behind CreateListEditor + store adapters - ~500 lines of copy-paste removed, one code path for add/remove/scroll/persist",
				"ExtraGUI: CreateTextInput now exposes .editBox and GetText/SetText so callers stop hunting child EditBoxes",
				"ExtraGUI: RegisterExampleConfigs renamed to RegisterBuiltinConfigs (it was never examples-only)",
				"Nameplate: Moved the aura whitelist/blacklist editor onto the 'Auras Filter Style' dropdown (where filtering actually lives) instead of the simple 'Target Nameplate Auras' toggle",
				"Nameplate: Custom Unit Color and Custom Power Unit lists now open the full add/remove editor via a Manage button instead of a clear-on-submit buffer input",
				"Profiles: Polished the profile details panel - removed the duplicate 'currently active' line, themed all colors, fixed indentation to a real grid, and added a 'Customized: N settings' count plus last-switched time",
				"Profiles: Details box now auto-sizes to its content so longer profiles no longer spill text out below the panel",
				"Profiles: Import/export dialogs now reopen correctly after being closed instead of leaving hidden singleton frames behind",
				"Profiles: Split profile storage/import/export logic into ProfileService.lua so ProfileGUI.lua can focus on UI composition",
				"Profiles: Split reusable input/confirm/simple dialog builders into ProfileDialogs.lua for cleaner modal ownership",
				"Profiles: Split profile portrait atlas/fallback logic into ProfilePortraits.lua so list rendering no longer owns icon lookup rules",
				"Profiles: Copy, switch, delete, import, and reset operations now use guarded SavedVariables access",
				"Miscellaneous: Cooldown Viewer Settings added to movable frames list",
				"Blizzard Fixes: Addon list tooltip guard accepts owners without GetID",
				"Tooltip: Added 6 missing Midnight barter/curio vendor locations (Finery Funds, Dark Particle, Vile Essence, Void-Tainted Remains, Ethereal Energy, Chiming Void Curio)",
				"Skins: Chat bubble border tint now refreshes during the shared poll instead of a permanent per-bubble OnUpdate (removes always-on per-frame CPU cost)",
			},
		},
	},

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
