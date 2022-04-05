local K = unpack(KkthnxUI)

--[[
### Guiding Principles
Changelogs are for humans, not machines.
There should be an entry for every single version.
The same types of changes should be grouped.
Versions and sections should be linkable.
The latest version comes first.
The release date of each version is displayed.
Mention whether you follow Semantic Versioning.

### Types of changes
-- 'Added' for new features.
-- 'Changed' for changes in existing functionality.
-- 'Deprecated' for soon-to-be removed features.
-- 'Removed' for now removed features.
-- 'Fixed' for any bug fixes.
--]]

local KKUI_Changelog = {
	{
		Version = "[10.3.0] - 2022-4-5",
		General = "All notable changes to this project will be documented in this file. The format is based on "..K.SystemColor.."[Keep a Changelog]|r and this project adheres to "..K.SystemColor.."[Semantic Versioning]|r",
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
				}
			}
		}
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
				}
			}
		}
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
					"Raid debuffs not working at all"
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
				}
			}
		}
	},
}

K.Changelog = KKUI_Changelog