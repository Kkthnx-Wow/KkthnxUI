--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Config/Defaults.lua
	Purpose:
		The default value tree for every user facing setting. Core/Config.lua
		deep merges the active profile onto a copy of this tree and exposes the
		result as C. Add new settings here first so profiles pick them up.
-----------------------------------------------------------------------------]]

local K = KkthnxUI[1]

-- Stored on the engine so Core/Config.lua can read it without a global.
K.ConfigDefaults = {
	General = {
		AutoScale = true,
		UIScale = 0.71,
		BorderStyle = "KkthnxUI",
		BorderColor = { 1, 1, 1, 1 },
		Font = "Normal",
		FontOutline = true,
		WelcomeMessage = true,
	},

	ActionBar = {
		Enable = true,
		ShowGrid = true,
		Cooldowns = true,
		RangeColoring = "button", -- how out-of-range shows: button, hotkey, or none
		ProcGlow = "Pixel", -- spell-activation glow style: Pixel, Autocast, or Default
		Font = "Normal",
		FontSize = 12,
		FontFlag = "OUTLINE",
		-- Each bar is fully self-contained: size, spacing, layout, opacity,
		-- mouseover fade, and its own text toggles. Sizes and spacing match the
		-- original KkthnxUI (38px buttons, 6px spacing).
		Bar1 = { Enable = true, Buttons = 12, PerRow = 12, Size = 38, Space = 6, Alpha = 1, Mouseover = false, HotKey = true, MacroName = true, Count = true },
		Bar2 = { Enable = true, Buttons = 12, PerRow = 12, Size = 38, Space = 6, Alpha = 1, Mouseover = false, HotKey = true, MacroName = true, Count = true },
		Bar3 = { Enable = true, Buttons = 12, PerRow = 12, Size = 38, Space = 6, Alpha = 1, Mouseover = false, HotKey = true, MacroName = true, Count = true },
		Bar4 = { Enable = true, Buttons = 12, PerRow = 1, Size = 38, Space = 6, Alpha = 1, Mouseover = false, HotKey = true, MacroName = true, Count = true },
		Bar5 = { Enable = true, Buttons = 12, PerRow = 1, Size = 38, Space = 6, Alpha = 1, Mouseover = false, HotKey = true, MacroName = true, Count = true },
		-- Bars 6-8 are the extra multibars, off by default so they do not clutter.
		Bar6 = { Enable = false, Buttons = 12, PerRow = 12, Size = 34, Space = 6, Alpha = 1, Mouseover = false, HotKey = true, MacroName = true, Count = true },
		Bar7 = { Enable = false, Buttons = 12, PerRow = 12, Size = 34, Space = 6, Alpha = 1, Mouseover = false, HotKey = true, MacroName = true, Count = true },
		Bar8 = { Enable = false, Buttons = 12, PerRow = 12, Size = 34, Space = 6, Alpha = 1, Mouseover = false, HotKey = true, MacroName = true, Count = true },
		-- Pet, stance, and the extra/zone ability button.
		PetBar = { Enable = true, PerRow = 10, Size = 30, Space = 6, Alpha = 1, Mouseover = false, HotKey = true },
		StanceBar = { Enable = true, PerRow = 10, Size = 30, Space = 6, Alpha = 1, Mouseover = false, HotKey = true },
		PossessBar = { Enable = true, PerRow = 2, Size = 30, Space = 6, Alpha = 1, Mouseover = false, HotKey = true },
		ExtraBar = { Enable = true, Size = 46 },
	},

	-- Unit frame geometry follows the original KkthnxUI: health and power are two
	-- separate bordered bars stacked with a 6px gap, so a unit's outer height is
	-- Height + 6 + PowerHeight. Portraits are detached boxes beside the frame.
	Unitframe = {
		Enable = true,
		Texture = "KkthnxUI",
		ClassHealth = false,
		ClassColorBorder = false,
		ThreatHealthColor = false, -- colour enemy health bars by your threat instead of reaction
		BarBackdrop = true,
		Portrait = true,
		PortraitStyle = "3D", -- 3D, 2D, Class
		Smooth = true,
		HealthPrediction = true,
		RangeFade = true, -- dim units that are out of range
		RangeAlpha = 0.4, -- how faded an out-of-range unit gets
		GroupDispelOnly = true, -- party/raid debuffs: only ones you can dispel + boss
		AuraWatch = true, -- corner dots on party/raid frames for your tracked heals

		-- User aura filter additions, keyed by spell id. Whitelist always shows an
		-- aura, blacklist always hides it. Merged with the built-in lists.
		AuraWhitelist = {},
		AuraBlacklist = {},
		-- Text formatting shared by the units below.
		HealthFormat = "Both", -- None, Current, Percent, Both
		PowerFormat = "Current", -- None, Current, Percent, Both
		NameColor = true,
		NameLength = 18,

		-- Custom power bar colours, applied over the oUF defaults. Keyed by power
		-- token so both unit frames and nameplates use them.
		-- Retuned to sit alongside the #5C8BCF theme: softened jewel tones and
		-- warm ambers instead of harsh primaries, with mana locked to the accent.
		PowerColors = {
			MANA = { 0.36, 0.55, 0.81 }, -- theme accent
			RAGE = { 0.82, 0.31, 0.31 }, -- soft crimson
			FOCUS = { 0.90, 0.52, 0.28 }, -- warm copper
			ENERGY = { 0.95, 0.76, 0.32 }, -- soft amber gold
			RUNIC_POWER = { 0.33, 0.72, 0.88 }, -- frost cyan-blue
			LUNAR_POWER = { 0.45, 0.62, 0.88 }, -- astral blue
			MAELSTROM = { 0.25, 0.58, 0.88 }, -- deep ocean blue
			INSANITY = { 0.55, 0.32, 0.78 }, -- void purple
			FURY = { 0.72, 0.32, 0.82 }, -- fel magenta
			PAIN = { 0.92, 0.55, 0.22 }, -- demon amber
		},
		-- Reaction colours, indexed 1 (hated) to 8 (exalted), harmonised with the
		-- theme: crimson hostiles, gold neutral, jade friendly, frost-blue exalted.
		ReactionColors = {
			[1] = { 0.82, 0.31, 0.31 },
			[2] = { 0.82, 0.31, 0.31 },
			[3] = { 0.85, 0.45, 0.25 },
			[4] = { 0.95, 0.76, 0.32 },
			[5] = { 0.22, 0.80, 0.30 }, -- friendly: clear green, away from Evoker teal
			[6] = { 0.22, 0.80, 0.30 },
			[7] = { 0.22, 0.80, 0.30 },
			[8] = { 0.36, 0.72, 0.88 },
		},

		Player = { Enable = true, Width = 220, Height = 40, PowerHeight = 16, ShowPower = true, Buffs = false, Debuffs = true, ClassPower = true, AdditionalPower = true, ShowName = false },
		Target = { Enable = true, Width = 220, Height = 40, PowerHeight = 16, ShowPower = true, Buffs = true, Debuffs = true },
		TargetOfTarget = { Enable = true, Width = 100, Height = 18, PowerHeight = 10, ShowPower = true },
		Pet = { Enable = true, Width = 100, Height = 18, PowerHeight = 10, ShowPower = true, Debuffs = false },
		Focus = { Enable = true, Width = 200, Height = 34, PowerHeight = 14, ShowPower = true, Debuffs = true },
		FocusTarget = { Enable = true, Width = 100, Height = 18, PowerHeight = 10, ShowPower = true },
		Party = { Enable = true, Width = 150, Height = 26, PowerHeight = 10, ShowPower = true, ShowSolo = false, ShowPlayer = true, Debuffs = true, DispelHighlight = true, Portrait = true },
		-- Height is the health bar, the power bar (PowerHeight) sits below it with a
		-- PowerGap so the two read as separate bars. PowerMode: All, Mana, or None.
		Raid = { Enable = true, Width = 80, Height = 30, PowerHeight = 6, PowerGap = 6, PowerMode = "All", GroupsPerRow = 5, GroupBy = "GROUP", RaidWide = false, SortDirection = "ASC", Orientation = "DOWN_RIGHT", DispelHighlight = true, ShowGroupNumber = true },
		-- Spacing has to clear the frame plus its attached castbar, otherwise the
		-- bar for boss1 lands on top of boss2's name.
		Boss = { Enable = true, Width = 150, Height = 24, PowerHeight = 10, ShowPower = true, Spacing = 34, Debuffs = true, Castbar = true },

		Auras = {
			BuffSize = 24,
			DebuffSize = 26,
			PerRow = 7,
			NumBuffs = 12,
			NumDebuffs = 8,
			Spacing = 6,
			OnlyPlayerDebuffs = false,
		},

		ClassPower = {
			Height = 14,
			Spacing = 6,
		},

		Castbar = {
			Enable = true,
			ShowIcon = true,
			ShowTimer = true,
			ShowSpark = true,
			ShowLatency = true,
			TimeToHold = 0.4,
			PlayerWidth = 268,
			PlayerHeight = 28,
			TargetWidth = 268,
			TargetHeight = 34,
			FocusWidth = 208,
			FocusHeight = 24,
		},
	},

	Minimap = {
		Enable = true,
		Size = 200,
		Square = true,
		ShowLocation = true, -- zone name, top of the map
		ShowClock = true, -- time datatext, bottom of the map
		CollectButtons = true,
		ButtonCorner = "BOTTOMLEFT", -- corner the button-collector dot sits in
	},

	WorldMap = {
		Enable = true,
		SmallerMap = true, -- shrink the maximized map so it does not cover the screen
		Scale = 0.9,
		Coordinates = true, -- player and cursor coordinates in a corner of the map
		CoordPosition = "BOTTOMLEFT",
		Reveal = false, -- draw unexplored map areas (toggle on the map itself)
		RevealDim = true, -- dim the revealed areas so explored ground still stands out
	},

	Nameplate = {
		Enable = true,
		Width = 150,
		Height = 14,
		NameSize = 12,
		ClassColor = true,
		ShowHealthText = true,
		ShowQuestIcon = true,
		QuestShowParty = false, -- also mark NPCs on a party member's quest (greyed)
		QuestProgressFormat = "Completed", -- Completed (3/7) or Remaining (4)
		QuestProgressOnTarget = false, -- only show the progress text on your target

		ShowClassification = true,
		FriendlyNameOnly = true,
		ShowGuildName = true,
		ShowCastbar = true,
		CastbarHeight = 16,
		ShowDebuffs = true,
		OnlyMyDebuffs = true,
		TargetHighlight = true,
		TargetPower = true, -- your class resource on the target's nameplate
		ThreatColor = true,
		ThreatHealthColor = false, -- colour enemy health bars by your threat instead of reaction
		MaxDistance = 60,
		MaxAuras = 6,
		AuraSize = 24,
		AuraSpacing = 6,
		-- Custom health colours for priority mobs, keyed by npcID -> { r, g, b }.
		CustomColors = {},
	},

	Auras = {
		Enable = true,
		BuffSize = 30,
		DebuffSize = 32,
		PerRow = 8,
		Spacing = 6,
	},

	Cooldown = {
		Enable = true, -- Blizzard's native countdown numbers (the only ones that
		-- can read the secret cooldown duration on 12.1)
	},

	-- Blizzard frame skins. Retail only for now.
	Skins = {
		CharacterFrames = true,
		GearInfo = true, -- per-slot item level, gems, and enchant marks
		SocialColors = true, -- class/difficulty colour the Friends, Who, and Guild panels
		GameMenu = true, -- skin the pause menu and add a KkthnxUI options button
		ObjectiveTracker = true, -- tidy the quest tracker header/minimise and recolour its bars
		ObjectiveTrackerClassColor = true, -- class colour the tracker bars instead of the accent
	},

	-- Movable, reskinned micro menu. Retail only for now.
	MicroMenu = {
		Enable = true,
		ButtonSize = 28,
		Spacing = 6,
	},

	-- Movable, reskinned bag bar. Retail only for now.
	BagBar = {
		Enable = true,
		ButtonSize = 30,
		Spacing = 6,
	},

	-- All-in-one bag and bank replacement, auto categorised. Retail only for now.
	Bags = {
		Enable = true,
		ButtonSize = 34,
		Spacing = 6,
		BagsPerRow = 12,
		BankPerRow = 14,
		Categories = true, -- group items into New/Junk/Equipment/etc.
		MergeStacks = false, -- fold duplicate stackable items into one button
		GroupGearBySlot = false, -- split gear into per equipment slot shelves
		ShowItemLevel = true, -- item level on equippable gear
		ShowUpgradeTrack = true, -- upgrade track progress (cur/max) on gear
		PawnArrows = true, -- Pawn upgrade arrows on gear (only if Pawn is installed)
		QuestColor = true, -- quest-yellow border on quest items, ! bang on starters
		ReagentBagSection = true, -- group the reagent pouch into its own section
		DetachReagentBag = false, -- give the reagent pouch its own window (retail)
		ShowBagBar = true, -- show the bag slot strip, toggled from the bag window
		ShowItemBind = true, -- BoE / BoA marker on bind-on-equip gear
		ShowNewItems = true, -- glow freshly looted items
		ShowCurrencies = true, -- tracked currency row along the bottom
		JunkIcon = true, -- coin marker on grey items
		DesaturateJunk = false, -- grey out the icon of vendor trash
		DeleteButton = true, -- show the delete-cheapest-junk button
		JunkList = {}, -- itemID -> true, items the player flagged as junk
		ReverseSort = false, -- newest items to the top-left instead
		AutoSellJunk = false, -- sell grey items on visiting a merchant
		AutoDepositReagents = false, -- push reagents to the bank on opening it
		Collapsed = {}, -- section key -> true when the player folded it away
		Favorites = {}, -- itemID -> true, pinned to their own section on top
		Groups = {}, -- group name -> order, categories folded under one header
		CategoryGroup = {}, -- category key -> group name it belongs to
		CustomCategories = {}, -- custom category key -> display name
		ItemAssignments = {}, -- itemID -> category key the player pinned it to
	},

	-- Movable experience / reputation / honor / azerite / house progress bar.
	-- Retail only for now.
	ExpRep = {
		Enable = true,
		Width = 400,
		Height = 14,
		FontSize = 11,
		ShowText = true,
		ShowRested = true,
		Fade = false,
		FadeOpacity = 0,
		FadeCombat = true,
		FadeTarget = false,
	},

	-- Collect Blizzard's alert popups on one movable anchor. Retail only.
	AlertFrames = {
		Enable = true,
		HideTalkingHead = false, -- suppress the Talking Head dialog frame
		StackSpacing = 0, -- gap between stacked alerts (negative overlaps art padding)
	},

	-- Group pull timer on /pull (alias /pc). Retail and Classic.
	PullCountdown = {
		Enable = true,
		Seconds = 10, -- used when /pull is typed with no number
	},

	-- Tint already-known collectibles green at vendors, AH, and guild bank. Retail only.
	AlreadyKnown = {
		Enable = true,
	},

	-- Small quality-of-life automations. Retail only.
	Automation = {
		Enable = true,
		DeclineDuels = true, -- decline player duel requests
		DeclinePetDuels = true, -- decline pet-battle duel requests
		SkipCinematics = false, -- skip cinematics and movies (off so story is not lost)
		AutoRepair = true, -- repair all gear at a repair-capable merchant
		RepairGuildFunds = false, -- spend guild bank money first when allowed
	},

	-- Hands-off questing: accept, turn in, and reward selection. Retail only.
	AutoQuest = {
		Enable = true,
		Accept = true, -- accept offered quests
		TurnIn = true, -- hand in completed quests
		SelectReward = true, -- pick the highest vendor-value reward on a choice
		SkipGossip = true, -- click through a single-option gossip
		IgnoreTrivial = false, -- leave low-level (grey) quests alone
		Share = true, -- push accepted quests to the party
		PauseKey = "SHIFT", -- hold to pause automation (NONE disables the pause)
	},

	Chat = {
		Enable = true,
		Font = "Normal",
		FontSize = 13,
		FontOutline = false,
		Fade = false,
		FadeTime = 15,
		MouseWheelScroll = true,
		StickyWhisper = true,
		WhisperSound = true, -- play a sound on an incoming whisper
		SkinBubbles = true, -- give in-world chat bubbles our border and background
		ShortenChannels = true,
		ClassColorNames = true,
		URLLinks = true,
		HyperlinkTooltip = true,
		ChatBar = true,
		SideButtons = true, -- vertical icon strip on the left of the chat
		SpamFilter = false,
		CopyButton = true,
		Timestamps = true,
		GradientBackdrop = true,
	},

	Tooltip = {
		Enable = true,
		CursorAnchor = false, -- follow the cursor instead of the default corner
		HideInCombat = false,
		ShowItemInfo = true, -- item level on gear tooltips (older flavours only, retail shows it natively)
		ClassColorName = true,
		HealthValue = true,
		HealthBarPosition = "TOP", -- TOP or BOTTOM, outside the tooltip
		ShowTarget = true,
		ShowGuild = true, -- <Guild> line for players
		ShowItemLevel = true, -- inspect item level + spec on players
		ShowIDs = true, -- spell / item / currency / mount ids
		ShowIcons = true, -- icon beside the tooltip title
		ShowMountSource = true, -- collection status/source on a player's mount buff (hold Shift)
		BorderColor = true, -- tint the tooltip border by unit class/reaction
		ShowMount = true, -- the mount a player is riding
		ShowMythicScore = true, -- a player's Mythic+ rating
		ShowRole = true, -- tank/healer/dps icon for group members
		ShowFactionIcon = true, -- faction crest on the name, hides the faction line
		ShowRaidIcon = true, -- raid target marker ahead of the unit name
		ShowTargetedBy = true, -- who in your group is targeting this unit
		ShowTitle = true, -- swap in the player's title (PvP name)
		ShowRealm = true, -- append the realm for cross-realm players
		HidePvP = true, -- hide the big red PvP line
	},
}
