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
		Version = "[10.3.8.Github] - Soon :)",
		Sections = {
			{
				Header = "Added",
				Entries = {
					"Code to support right clicking Datatext Gold module to update in real time",
					"More fonts to fonts file",
					"New unitframe fader code",
				},
			},

			-- {
			-- 	Header = "Fixed",
			-- 	Entries = {},
			-- },

			{
				Header = "Removed",
				Entries = {
					"We do not see to see our OWN name on the player unitframe. This is completely pointless",
				},
			},

			{
				Header = "Changed",
				Entries = {
					"Castbar Glow has a better desc name in gui",
					"Cleaned Gold module code",
					"Cleaned UIDropDownMenu skinning code",
					"Goodbye module has a lot more phrases now with a random timer",
					"No longer have split up media folders. All merged together now",
					"Thicker border on gem icons in character/inspect",
				},
			},
		},
	},

	{
		Version = "[10.3.7] - 2022-8-24",
		General = "All notable changes to this project will be documented in this file. The format is based on " .. K.SystemColor .. "[Keep a Changelog]|r and this project adheres to " .. K.SystemColor .. "[Semantic Versioning]|r",
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
