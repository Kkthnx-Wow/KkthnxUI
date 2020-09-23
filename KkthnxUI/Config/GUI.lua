local K, C, L = unpack(select(2, ...))
local GUI = K["GUI"]

local _G = _G

local SetSortBagsRightToLeft = _G.SetSortBagsRightToLeft
local BAG_FILTER_EQUIPMENT = _G.BAG_FILTER_EQUIPMENT

local enableTextColor = "|cff00cc4c"

local function UpdateBagSortOrder()
	SetSortBagsRightToLeft(not C["Inventory"].ReverseSort)
end

local function UpdateBagStatus()
	K:GetModule("Bags"):UpdateAllBags()

	local label = BAG_FILTER_EQUIPMENT
	if C["Inventory"].ItemSetFilter then
		label = "Equipement Set"
	end
	_G.KKUI_BackpackEquipment.label:SetText(label)
	_G.KKUI_BackpackBankEquipment.label:SetText(label)
end

local function UpdateTargetBuffs()
	local frame = _G.oUF_Target
	if not frame then
		return
	end

	local element = frame.Buffs
	element.iconsPerRow = C["Unitframe"].TargetBuffsPerRow

	local width = 156 -- Static
	local maxLines = element.iconsPerRow and K.Round((element.num) / element.iconsPerRow)
	element.size = K:GetModule("Unitframes").auraIconSize(width, element.iconsPerRow, element.spacing)
	element:SetWidth(width)
	element:SetHeight((element.size + element.spacing) * maxLines)
	element:ForceUpdate()
end

local function UpdateTargetDebuffs()
	local frame = _G.oUF_Target
	if not frame then
		return
	end

	local element = frame.Debuffs
	element.iconsPerRow = C["Unitframe"].TargetDebuffsPerRow

	local width = 156 -- Static
	local maxLines = element.iconsPerRow and K.Round((element.num) / element.iconsPerRow)
	element.size = K:GetModule("Unitframes").auraIconSize(width, element.iconsPerRow, element.spacing)
	element:SetWidth(width)
	element:SetHeight((element.size + element.spacing) * maxLines)
	element:ForceUpdate()
end

local function UpdateChatSize()
	local CF1 = _G.ChatFrame1
	CF1:SetSize(C["Chat"].Width, C["Chat"].Height)

	if C["Chat"].Background then
		if KKUI_ChatFrameBG then
			KKUI_ChatFrameBG:SetSize(C["Chat"].Width + 26, C["Chat"].Height + 34)
		end

		if KKUI_ChatTabsBG then
			KKUI_ChatTabsBG:SetSize(C["Chat"].Width + 16, 24)
		end
	end

	if KKUI_ChatMenu then
		KKUI_ChatMenu:SetHeight(C["Chat"].Height - 6)
	end

	if CF1.mover then
		CF1.mover:SetSize(C["Chat"].Width, C["Chat"].Height)
	end
end

local function UpdateChatBubble()
	for _, chatBubble in pairs(C_ChatBubbles.GetAllChatBubbles()) do
		chatBubble.KKUI_Background:SetVertexColor(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Skins"].ChatBubbleAlpha)
    end
end

-- Translate Below Before Shadowlands
local ActionBar = function(self)
	local Window = self:CreateWindow(L["ActionBar"])

	Window:CreateSection("ActionBar Toggles")
	Window:CreateSwitch("ActionBar", "Enable", enableTextColor.."Enable ActionBar")
	Window:CreateSwitch("ActionBar", "Cooldowns", "Show Cooldowns")
	Window:CreateSwitch("ActionBar", "Count", "Enable Count")
	Window:CreateSwitch("ActionBar", "DecimalCD", "Format Cooldowns As Decimals")
	Window:CreateSwitch("ActionBar", "FadePetBar", "Mouseover PetBar")
	Window:CreateSwitch("ActionBar", "FadeRightBar", "Mouseover RightBar 1")
	Window:CreateSwitch("ActionBar", "FadeRightBar2", "Mouseover RightBar 2")
	Window:CreateSwitch("ActionBar", "FadeStanceBar", "Mouseover StanceBar")
	Window:CreateSwitch("ActionBar", "Hotkey", "Enable Hotkey")
	Window:CreateSwitch("ActionBar", "Macro", "Enable Macro")
	Window:CreateSwitch("ActionBar", "MicroBar", "Enable MicroBar")
	Window:CreateSwitch("ActionBar", "MicroBarMouseover", "Enable MicroBarMouseover")
	Window:CreateSwitch("ActionBar", "OverrideWA", "Enable OverrideWA")

	Window:CreateSection("ActionBar Sizes")
	Window:CreateSlider("ActionBar", "DefaultButtonSize", "Set MainBars Button Size", 28, 36, 1)
	Window:CreateSlider("ActionBar", "RightButtonSize", "Set RightBars Button Size", 28, 36, 1)
	Window:CreateSlider("ActionBar", "StancePetSize", "Set Stance/Pet Button Size", 28, 36, 1)

	Window:CreateSection("ActionBar Layouts")
	Window:CreateDropdown("ActionBar", "Layout", "Choose Your Layout")
end

local Announcements = function(self)
	local Window = self:CreateWindow(L["Announcements"])

	Window:CreateSection("Announcement Toggles")
	Window:CreateSwitch("Announcements", "ItemAlert", "Announce Items Being Placed")
	Window:CreateSwitch("Announcements", "PullCountdown", "Announce Pull Countdown (/pc #)")
	Window:CreateSwitch("Announcements", "RareAlert", "Announce Rares, Chests & War Supplies")
	Window:CreateSwitch("Announcements", "SaySapped", "Announce When Sapped")
	Window:CreateDropdown("Announcements", "Interrupt", "Announce Interrupts")
end

local Automation = function(self)
	local Window = self:CreateWindow(L["Automation"])

	Window:CreateSection("Automation Toggles")

	Window:CreateSwitch("Automation", "AutoSummon", "Auto Accept Summon Requests")
	Window:CreateSwitch("Automation", "AutoBlockStrangerInvites", "Blocks Invites From Strangers")
	Window:CreateSwitch("Automation", "AutoCollapse", "Auto Collapse Objective Tracker")
	Window:CreateSwitch("Automation", "AutoDeclineDuels", "Decline PvP Duels")
	Window:CreateSwitch("Automation", "AutoDeclinePetDuels", "Decline Pet Duels")
	Window:CreateSwitch("Automation", "AutoDisenchant", "Auto Disenchant With 'ALT'")
	Window:CreateSwitch("Automation", "AutoInvite", "Accept Invites From Friends & Guild Members")
	Window:CreateSwitch("Automation", "AutoPartySync", "Accept PartySync From Friends & Guild Members")
	Window:CreateSwitch("Automation", "AutoRelease", "Auto Release in Battlegrounds & Arenas")
	Window:CreateSwitch("Automation", "AutoResurrect", "Auto Accept Resurrect Requests")
	Window:CreateSwitch("Automation", "AutoResurrectThank", "Say 'Thank You' When Resurrected")
	Window:CreateSwitch("Automation", "AutoReward", "Auto Select Quest Rewards Best Value")
	Window:CreateSwitch("Automation", "AutoScreenshot", "Auto Screenshot Achievements")
	Window:CreateSwitch("Automation", "AutoSetRole", "Auto Set Your Role In Groups")
	Window:CreateSwitch("Automation", "AutoTabBinder", "Only Tab Target Enemy Players")
	Window:CreateSwitch("Automation", "NoBadBuffs", "Automatically Remove Annoying Buffs")
	Window:CreateEditBox("Automation", "WhisperInvite", "Auto Accept Invite Keyword")
end

local Inventory = function(self)
	local Window = self:CreateWindow(L["Inventory"])

	Window:CreateSection("Inventory Toggles")
	Window:CreateSwitch("Inventory", "Enable", enableTextColor.."Enable Inventory")
	Window:CreateSwitch("Inventory", "AutoSell", "Auto Vendor Grays")
	Window:CreateSwitch("Inventory", "BagBar", "Enable Bagbar")
	Window:CreateSwitch("Inventory", "BagBarMouseover", "Fade Bagbar")
	Window:CreateSwitch("Inventory", "BagsItemLevel", "Display Item Level")
	Window:CreateSwitch("Inventory", "DeleteButton", "Bags Delete Button")
	Window:CreateSwitch("Inventory", "ShowNewItem", "Show New Item Glow")
	Window:CreateSwitch("Inventory", "UpgradeIcon", "Show Upgrade Icon")
	Window:CreateSwitch("Inventory", "ReverseSort", "Umm Reverse The Sorting", nil, UpdateBagSortOrder)
	Window:CreateDropdown("Inventory", "AutoRepair", "Auto Repair Gear")

	Window:CreateSection("Inventory Filters")
	Window:CreateSwitch("Inventory", "GatherEmpty", "Gather Empty Slots Into One Button", nil, UpdateBagStatus)
	Window:CreateSwitch("Inventory", "ItemFilter", "Filter Items Into Categories", nil, UpdateBagStatus)
	Window:CreateSwitch("Inventory", "ItemSetFilter", "Filter EquipmentSets", nil, UpdateBagStatus)
	Window:CreateSwitch("Inventory", "FilterAzerite", "Filter Azerite Items", nil, UpdateBagStatus)
	Window:CreateSwitch("Inventory", "FilterConsumable", "Filter Consumable Items", nil, UpdateBagStatus)
	Window:CreateSwitch("Inventory", "FilterEquipment", "Filter Equipment Items", nil, UpdateBagStatus)
	Window:CreateSwitch("Inventory", "FilterFavourite", "Filter Favourite Items", nil, UpdateBagStatus)
	Window:CreateSwitch("Inventory", "FilterGoods", "Filter Goods Items", nil, UpdateBagStatus)
	Window:CreateSwitch("Inventory", "FilterJunk", "Filter Junk Items", nil, UpdateBagStatus)
	Window:CreateSwitch("Inventory", "FilterLegendary", "Filter Legendary Items", nil, UpdateBagStatus)
	Window:CreateSwitch("Inventory", "FilterMount", "Filter Mount Items", nil, UpdateBagStatus)
	Window:CreateSwitch("Inventory", "FilterQuest", "Filter Quest Items", nil, UpdateBagStatus)

	Window:CreateSection("Inventory Sizes")
	Window:CreateSlider("Inventory", "BagsWidth", "Bags Width", 8, 16, 1)
	Window:CreateSlider("Inventory", "BankWidth", "Bank Width", 10, 18, 1)
	Window:CreateSlider("Inventory", "IconSize", "Slot Icon Size", 28, 36, 1)
end

local Auras = function(self)
	local Window = self:CreateWindow(L["Auras"])

	Window:CreateSection("Aura Toggles")
	Window:CreateSwitch("Auras", "Enable", enableTextColor.."Enable Auras")
	Window:CreateSwitch("Auras", "Reminder", "Auras Reminder (Shout/Intellect/Poison)")
	Window:CreateSwitch("Auras", "ReverseBuffs", "Buffs Grow Right")
	Window:CreateSwitch("Auras", "ReverseDebuffs", "Debuffs Grow Right")
	Window:CreateSwitch("Auras", "Totems", "Show Totems Bar")

	Window:CreateSection("Aura Sizes")
	Window:CreateSlider("Auras", "BuffSize", "Buff Icon Size", 20, 40, 1)
	Window:CreateSlider("Auras", "BuffsPerRow", "Buffs per Row", 10, 20, 1)
	Window:CreateSlider("Auras", "DebuffSize", "DeBuff Icon Size", 20, 40, 1)
	Window:CreateSlider("Auras", "DebuffsPerRow", "DeBuffs per Row", 10, 16, 1)
end

local Chat = function(self)
	local Window = self:CreateWindow(L["Chat"])

	Window:CreateSection("Chat Toggles")
	Window:CreateSwitch("Chat", "Enable", enableTextColor.."Enable Chat")
	Window:CreateSwitch("Chat", "Background", "Show Chat Background")
	Window:CreateSwitch("Chat", "ChatItemLevel", "Show ItemLevel on ChatFrames")
	Window:CreateSwitch("Chat", "ChatMenu", "Show Chat Menu Buttons")
	Window:CreateSwitch("Chat", "LootIcons", "Show Chat Loot Icons")
	Window:CreateSwitch("Chat", "OldChatNames", "Use Default Channel Names")
	Window:CreateSwitch("Chat", "TabsMouseover", "Fade Chat Tabs")
	Window:CreateSwitch("Chat", "WhisperColor", "Differ Whipser Colors")
	Window:CreateSwitch("Chat", "WhisperSound", "Whisper Sound")
	Window:CreateDropdown("Chat", "TimestampFormat", "Custom Chat Timestamps")

	Window:CreateSection("Chat Values")
	Window:CreateSlider("Chat", "Width", "Chat Width", 300, 600, 1, UpdateChatSize)
	Window:CreateSlider("Chat", "Height", "Chat Height", 150, 300, 1, UpdateChatSize)

	Window:CreateSection("Chat Fading")
	Window:CreateSwitch("Chat", "Fading", "Fade Chat")
	Window:CreateSlider("Chat", "FadingTimeFading", "Fade Chat Time", 1, 5, 1)
	Window:CreateSlider("Chat", "FadingTimeVisible", "Fading Chat Visible Time", 5, 60, 1)

	Window:CreateSection("Chat Filter")
	Window:CreateSwitch("Chat", "EnableFilter", enableTextColor.."Enable Chat Filter")
	Window:CreateEditBox("Chat", "ChatFilterList", "ChatFilter BlackList", "Enter words you want blacklisted|n|nUse SPACES between each word|n|nPress enter when you are done", K:GetModule("Chat"):UpdateFilterList())
	Window:CreateEditBox("Chat", "ChatFilterWhiteList", "ChatFilter WhiteList", "Enter words you want whitelisted|n|nUse SPACES between each word|n|nPress enter when you are done", K:GetModule("Chat"):UpdateFilterWhiteList())
	Window:CreateSwitch("Chat", "BlockAddonAlert", "Block 'Some' AddOn Alerts")
	Window:CreateSwitch("Chat", "BlockStranger", "Block Whispers From Strangers")
	Window:CreateSwitch("Chat", "AllowFriends", "Allow Spam From Friends")
	Window:CreateSlider("Chat", "FilterMatches", "Filter Matches Number", 1, 3, 1)
end

local DataBars = function(self)
	local Window = self:CreateWindow(L["DataBars"])

	Window:CreateSection("DataBar Toggles")
	Window:CreateSwitch("DataBars", "Enable", enableTextColor.."Enable DataBars")
	Window:CreateSwitch("DataBars", "MouseOver", "Fade DataBars")
	Window:CreateSwitch("DataBars", "Text", "Show Text")
	Window:CreateSwitch("DataBars", "TrackHonor", "Track Honor")

	Window:CreateSection("DataBar Sizes")
	Window:CreateSlider("DataBars", "Width", "DataBars Width", 20, 300, 1)
	Window:CreateSlider("DataBars", "Height", "DataBars Height", 14, 20, 1)

	Window:CreateSection("DataBar Colors")
	Window:CreateColorSelection("DataBars", "AzeriteColor", "Azerite Bar Color")
	Window:CreateColorSelection("DataBars", "ExperienceColor", "Experience Bar Color")
	Window:CreateColorSelection("DataBars", "HonorColor", "Honor Bar Color")
	Window:CreateColorSelection("DataBars", "RestedColor", "Rested Bar Color")
end

local DataText = function(self)
	local Window = self:CreateWindow(L["DataText"])

	Window:CreateSection("DataText Toggles")
	Window:CreateSwitch("DataText", "Currency", "Enable Currency Info")
	Window:CreateSwitch("DataText", "Friends", "Enable Friends Info")
	Window:CreateSwitch("DataText", "Guild", "Enable Guild Info")
	Window:CreateSwitch("DataText", "Latency", "Enable Latency Info")
	Window:CreateSwitch("DataText", "Location", "Enable Minimap Location")
	Window:CreateSwitch("DataText", "System", "Enable System Info")
	Window:CreateSwitch("DataText", "Time", "Enable Minimap Time")
end

local Filger = function(self)
	local Window = self:CreateWindow(L["Filger"])

	Window:CreateSection("Filger Toggles")
	Window:CreateSwitch("Filger", "Enable", enableTextColor.."Enable Filger")
	Window:CreateSwitch("Filger", "ShowTooltip", "Show Tooltip On Hover")
	Window:CreateSwitch("Filger", "TestMode", "Test Mode")

	Window:CreateSection("Filger Player Toggles")
	Window:CreateSwitch("Filger", "ShowBuff", "Show Buffs")
	Window:CreateSwitch("Filger", "ShowCD", "Show Cooldowns")
	Window:CreateSwitch("Filger", "Expiration", "Sort Cooldowns By Expiration")
	Window:CreateSwitch("Filger", "ShowProc", "Show Procs")
	Window:CreateSwitch("Filger", "ShowPvPPlayer", "Show PvP Debuffs")
	Window:CreateSwitch("Filger", "ShowSpecial", "Show Special Buffs")

	Window:CreateSection("Filger Target Toggles")
	Window:CreateSwitch("Filger", "ShowAuraBar", "Show AuraBars")
	Window:CreateSwitch("Filger", "ShowDebuff", "Show Debuffs")
	Window:CreateSwitch("Filger", "ShowPvPTarget", "Show PvP Auras")

	Window:CreateSection("Filger Sizes")
	Window:CreateSlider("Filger", "BuffSize", "Buff Size", 28, 40, 1)
	Window:CreateSlider("Filger", "CooldownSize", "Cooldown Size", 28, 40, 1)
	Window:CreateSlider("Filger", "MaxTestIcon", "Max Test Icons", 1, 10, 1)
	Window:CreateSlider("Filger", "PvPSize", "PvP Icon Size", 50, 70, 1)
end

local General = function(self)
	local Window = self:CreateWindow(L["General"], true)

	Window:CreateSection("General Toggles")
	Window:CreateSwitch("General", "AutoScale", "Auto Scale", nil, K:SetupUIScale())
	Window:CreateSwitch("General", "ColorTextures", "Color 'Most' KkthnxUI Borders")
	Window:CreateSwitch("General", "HideErrors", "Hide 'Some' UI Errors")
	Window:CreateSwitch("General", "MoveBlizzardFrames", "Move Blizzard Frames")
	Window:CreateSwitch("General", "NoTutorialButtons", "Disable 'Some' Blizzard Tutorials")
	Window:CreateSwitch("General", "ReplaceBlizzardFonts", "Replace 'Some' Blizzard Fonts")
	Window:CreateSwitch("General", "VersionCheck", "Enable Version Checking")
	Window:CreateSwitch("General", "Welcome", "Show Welcome Message")
	if C["General"].ReplaceBlizzardFonts then
		Window:CreateSlider("General", "FontSize", "Adjust 'Some' Font Sizes", 10, 16, 1, K:GetModule("Skins"):ReskinBlizzardFonts())
	end
	Window:CreateDropdown("General", "NumberPrefixStyle", "Number Prefix Style")

	Window:CreateSection("General Scaling")
	Window:CreateSlider("General", "UIScale", "Set UI scale", 0.4, 1.15, 0.01, K:SetupUIScale())

	Window:CreateSection("General Colors")
	Window:CreateColorSelection("General", "TexturesColor", "Textures Color")
end

local Loot = function(self)
	local Window = self:CreateWindow(L["Loot"])

	Window:CreateSection("Loot Toggles")
	Window:CreateSwitch("Loot", "Enable", enableTextColor.."Enable Loot")
	Window:CreateSwitch("Loot", "GroupLoot", enableTextColor.."Enable Group Loot")
	Window:CreateSwitch("Loot", "AutoConfirm", "Auto Confirm Loot Dialogs")
	Window:CreateSwitch("Loot", "AutoGreed", "Auto Greed Green Items")
	Window:CreateSwitch("Loot", "FastLoot", "Faster Auto-Looting")
end

local Minimap = function(self)
	local Window = self:CreateWindow(L["Minimap"])

	Window:CreateSection("Minimap Toggles")
	Window:CreateSwitch("Minimap", "Enable", enableTextColor.."Enable Minimap")
	Window:CreateSwitch("Minimap", "ShowGarrison", "Show Garrison Button")
	Window:CreateSwitch("Minimap", "ShowRecycleBin", "Show Minimap Button Collector")
	Window:CreateDropdown("Minimap", "LocationText", "Location Text Style")
	Window:CreateDropdown("Minimap", "BlipTexture", "Blip Icon Styles")

	Window:CreateSection("Minimap Sizes")
	Window:CreateSlider("Minimap", "Size", "Minimap Size", 120, 300, 1)
end

local Misc = function(self)
	local Window = self:CreateWindow(L["Misc"])

	Window:CreateSection("Misc Toggles")
	Window:CreateSwitch("Misc", "AFKCamera", "AFK Camera")
	Window:CreateSwitch("Misc", "ColorPicker", "Enhanced Color Picker")
	Window:CreateSwitch("Misc", "EnhancedFriends", "Enhanced Colors (Friends/Guild +)")
	Window:CreateSwitch("Misc", "GemEnchantInfo", "Character/Inspect Gem/Enchant Info")
	Window:CreateSwitch("Misc", "HideBanner", "Hide RaidBoss EmoteFrame")
	Window:CreateSwitch("Misc", "HideBossEmote", "Hide BossBanner")
	Window:CreateSwitch("Misc", "ImprovedStats", "Display Character Frame Full Stats")
	Window:CreateSwitch("Misc", "ItemLevel", "Show Character/Inspect ItemLevel Info")
	Window:CreateSwitch("Misc", "KillingBlow", "Show Your Killing Blow Info")
	Window:CreateSwitch("Misc", "NoTalkingHead", "Remove And Hide The TalkingHead Frame")
	Window:CreateSwitch("Misc", "PvPEmote", "Auto Emote On Your Killing Blow")
	Window:CreateSwitch("Misc", "ShowWowHeadLinks", "Show Wowhead Links Above Questlog Frame")
	Window:CreateSwitch("Misc", "SlotDurability", "Show Slot Durability %")
	Window:CreateSwitch("Misc", "TradeTabs", "Add Spellbook-Like Tabs On TradeSkillFrame")
end

local Nameplate = function(self)
	local Window = self:CreateWindow(L["Nameplate"])

	Window:CreateSection("Nameplate Toggles")
	Window:CreateSwitch("Nameplate", "Enable", enableTextColor.."Enable Nameplates")
	Window:CreateSwitch("Nameplate", "AKSProgress", "Show AngryKeystones Progress")
	Window:CreateSwitch("Nameplate", "ClassIcon", "Show Enemy Class Icons")
	Window:CreateSwitch("Nameplate", "CustomUnitColor", "Colored Custom Units")
	Window:CreateSwitch("Nameplate", "DPSRevertThreat", "Revert Threat Color If Not Tank")
	Window:CreateSwitch("Nameplate", "ExplosivesScale", "Scale Nameplates for Explosives")
	Window:CreateSwitch("Nameplate", "FriendlyCC", "Show Friendly ClassColor")
	Window:CreateSwitch("Nameplate", "FullHealth", "Show Health Value")
	Window:CreateSwitch("Nameplate", "HostileCC", "Show Hostile ClassColor")
	Window:CreateSwitch("Nameplate", "InsideView", "Interacted Nameplate Stay Inside")
	Window:CreateSwitch("Nameplate", "NameOnly", "Show Only Names For Friendly")
	Window:CreateSwitch("Nameplate", "NameplateClassPower", "Target Nameplate ClassPower")
	Window:CreateSwitch("Nameplate", "QuestIndicator", "Quest Progress Indicator")
	Window:CreateSwitch("Nameplate", "Smooth", "Smooth Bars Transition")
	Window:CreateSwitch("Nameplate", "TankMode", "Force TankMode Colored")
	Window:CreateDropdown("Nameplate", "AuraFilter", "Auras Filter Style")
	Window:CreateDropdown("Nameplate", "TargetIndicator", "TargetIndicator Style")

	Window:CreateSection("Nameplate Values")
	Window:CreateSlider("Nameplate", "AuraSize", "Auras Size", 16, 28, 1)
	Window:CreateSlider("Nameplate", "Distance", "Nameplete MaxDistance", 10, 100, 1)
	Window:CreateSlider("Nameplate", "HealthTextSize", "HealthText FontSize", 8, 16, 1)
	Window:CreateSlider("Nameplate", "MaxAuras", "Max Auras", 4, 8, 1)
	Window:CreateSlider("Nameplate", "MinAlpha", "Non-Target Nameplate Alpha", 0.1, 1, 0.1)
	Window:CreateSlider("Nameplate", "MinScale", "Non-Target Nameplate Scale", 0.1, 3, 0.1)
	Window:CreateSlider("Nameplate", "NameTextSize", "NameText FontSize", 8, 16, 1)
	Window:CreateSlider("Nameplate", "PlateHeight", "Nameplate Height", 6, 12, 1)
	Window:CreateSlider("Nameplate", "PlateWidth", "Nameplate Width", 80, 180, 1)
	Window:CreateSlider("Nameplate", "VerticalSpacing", "Nameplate Vertical Spacing", 0.1, 1, 1)

	Window:CreateSection("Player Nameplate Toggles")
	Window:CreateSwitch("Nameplate", "ShowPlayerPlate", enableTextColor.."Enable Personal Resource")
	Window:CreateSwitch("Nameplate", "ClassAuras", "Track Personal Class Auras")
	Window:CreateSwitch("Nameplate", "PPGCDTicker", "Enable GCD Ticker")
	Window:CreateSwitch("Nameplate", "PPHideOOC", "Only Visible in Combat")
	Window:CreateSwitch("Nameplate", "PPPowerText", "Show Power Value")

	Window:CreateSection("Player Nameplate Values")
	Window:CreateSlider("Nameplate", "PPHeight", "Classpower/Healthbar Height", 4, 10, 1)
	Window:CreateSlider("Nameplate", "PPIconSize", "PlayerPlate IconSize", 20, 40, 1)
	Window:CreateSlider("Nameplate", "PPPHeight", "PlayerPlate Powerbar Height", 4, 10, 1)

	Window:CreateSection("Nameplate Colors")
	Window:CreateColorSelection("Nameplate", "CustomColor", "Custom Color")
	Window:CreateColorSelection("Nameplate", "InsecureColor", "Insecure Color")
	Window:CreateColorSelection("Nameplate", "OffTankColor", "Off-Tank Color")
	Window:CreateColorSelection("Nameplate", "SecureColor", "Secure Color")
	Window:CreateColorSelection("Nameplate", "TargetIndicatorColor", "TargetIndicator Color")
	Window:CreateColorSelection("Nameplate", "TransColor", "Transition Color")
end

local PulseCooldown = function(self)
	local Window = self:CreateWindow(L["PulseCooldown"])

	Window:CreateSection("PulseCooldown Toggles")
	Window:CreateSwitch("PulseCooldown", "Enable", enableTextColor.."Enable PulseCooldown")
	Window:CreateSwitch("PulseCooldown", "Sound", "Play Sound On Pulse")

	Window:CreateSection("PulseCooldown Values")
	Window:CreateSlider("PulseCooldown", "AnimScale", "Animation Scale", 0.5, 2, 0.1)
	Window:CreateSlider("PulseCooldown", "HoldTime", "How Long To Display", 0.1, 1, 0.1)
	Window:CreateSlider("PulseCooldown", "Size", "Icon Size", 60, 85, 1)
	Window:CreateSlider("PulseCooldown", "Threshold", "Minimal Threshold Time", 1, 5, 1)
end

local Skins = function(self)
	local Window = self:CreateWindow(L["Skins"])

	Window:CreateSection("Skins Toggles")
	Window:CreateSwitch("Skins", "Bartender4", "Bartender4 Skin")
	Window:CreateSwitch("Skins", "BigWigs", "BigWigs Skin")
	Window:CreateSwitch("Skins", "BlizzardFrames", "Skin Some Blizzard Frames & Objects")
	Window:CreateSwitch("Skins", "ChatBubbles", "ChatBubbles Skin")
	Window:CreateSwitch("Skins", "ChocolateBar", "ChocolateBar Skin")
	Window:CreateSwitch("Skins", "DeadlyBossMods", "Deadly Boss Mods Skin")
	Window:CreateSwitch("Skins", "Details", "Details Skin")
	Window:CreateSwitch("Skins", "Hekili", "Hekili Skin")
	Window:CreateSwitch("Skins", "Skada", "Skada Skin")
	Window:CreateSwitch("Skins", "Spy", "Spy Skin")
	Window:CreateSwitch("Skins", "TalkingHeadBackdrop", "TalkingHead Skin")
	Window:CreateSwitch("Skins", "TellMeWhen", "TellMeWhen Skin")
	Window:CreateSwitch("Skins", "TitanPanel", "TitanPanel Skin")
	Window:CreateSwitch("Skins", "WeakAuras", "WeakAuras Skin")

	Window:CreateSection("Skin Values")
	Window:CreateSlider("Skins", "ChatBubbleAlpha", "ChatBubbles Background Alpha", 0, 1, 0.1, UpdateChatBubble)
end

local Tooltip = function(self)
	local Window = self:CreateWindow(L["Tooltip"])

	Window:CreateSection("Tooltip Toggles")
	Window:CreateSwitch("Tooltip", "ClassColor", "Quality Color Border")
	Window:CreateSwitch("Tooltip", "CombatHide", "Hide Tooltip in Combat")
	Window:CreateSwitch("Tooltip", "Cursor", "Follow Cursor")
	Window:CreateSwitch("Tooltip", "FactionIcon", "Show Faction Icon")
	Window:CreateSwitch("Tooltip", "HideJunkGuild", "Abbreviate Guild Names")
	Window:CreateSwitch("Tooltip", "HideRank", "Hide Guild Rank")
	Window:CreateSwitch("Tooltip", "HideRealm", "Show realm name by SHIFT")
	Window:CreateSwitch("Tooltip", "HideTitle", "Hide Player Title")
	Window:CreateSwitch("Tooltip", "Icons", "Item Icons")
	Window:CreateSwitch("Tooltip", "LFDRole", "Show Roles Assigned Icon")
	Window:CreateSwitch("Tooltip", "ShowIDs", "Show Tooltip IDs")
	Window:CreateSwitch("Tooltip", "SpecLevelByShift", "Show Spec/ItemLevel by SHIFT")
	Window:CreateSwitch("Tooltip", "TargetBy", "Show Player Targeted By")
end

local UIFonts = function(self)
	local Window = self:CreateWindow(L["UIFonts"])

	Window:CreateSection("UI Fonts")

	Window:CreateDropdown("UIFonts", "ActionBarsFonts", "Set ActionBar Font", "Font")
	Window:CreateDropdown("UIFonts", "AuraFonts", "Set Auras Font", "Font")
	Window:CreateDropdown("UIFonts", "ChatFonts", "Set Chat Font", "Font")
	Window:CreateDropdown("UIFonts", "DataBarsFonts", "Set DataBars Font", "Font")
	Window:CreateDropdown("UIFonts", "DataTextFonts", "Set DataText Font", "Font")
	Window:CreateDropdown("UIFonts", "FilgerFonts", "Set Filger Font", "Font")
	Window:CreateDropdown("UIFonts", "GeneralFonts", "Set General Font", "Font")
	Window:CreateDropdown("UIFonts", "InventoryFonts", "Set Inventory Font", "Font")
	Window:CreateDropdown("UIFonts", "MinimapFonts", "Set Minimap Font", "Font")
	Window:CreateDropdown("UIFonts", "NameplateFonts", "Set Nameplate Font", "Font")
	Window:CreateDropdown("UIFonts", "QuestTrackerFonts", "Set QuestTracker Font", "Font")
	Window:CreateDropdown("UIFonts", "SkinFonts", "Set Skins Font", "Font")
	Window:CreateDropdown("UIFonts", "TooltipFonts", "Set Tooltip Font", "Font")
	Window:CreateDropdown("UIFonts", "UnitframeFonts", "Set Unitframe Font", "Font")
end

local UITextures = function(self)
	local Window = self:CreateWindow(L["UITextures"])

	Window:CreateSection("UI Textures")

	Window:CreateDropdown("UITextures", "DataBarsTexture", "Set DataBars Texture", "Texture")
	Window:CreateDropdown("UITextures", "FilgerTextures", "Set Filger Texture", "Texture")
	Window:CreateDropdown("UITextures", "GeneralTextures", "Set General Texture", "Texture")
	Window:CreateDropdown("UITextures", "HealPredictionTextures", "Set HealPrediction Texture", "Texture")
	Window:CreateDropdown("UITextures", "LootTextures", "Set Loot Texture", "Texture")
	Window:CreateDropdown("UITextures", "NameplateTextures", "Set Nameplate Texture", "Texture")
	Window:CreateDropdown("UITextures", "QuestTrackerTexture", "Set QuestTracker Texture", "Texture")
	Window:CreateDropdown("UITextures", "SkinTextures", "Set Skins Texture", "Texture")
	Window:CreateDropdown("UITextures", "TooltipTextures", "Set Tooltip Texture", "Texture")
	Window:CreateDropdown("UITextures", "UnitframeTextures", "Set Unitframe Texture", "Texture")
end

local Unitframe = function(self)
	local Window = self:CreateWindow(L["Unitframe"])

	Window:CreateSection("Unitframe Toggles")
	Window:CreateSwitch("Unitframe", "CastClassColor", "Class Color Castbars")
	Window:CreateSwitch("Unitframe", "CastReactionColor", "Reaction Color Castbars")
	Window:CreateSwitch("Unitframe", "CastbarLatency", "Show Castbar Latency")
	Window:CreateSwitch("Unitframe", "Castbars", enableTextColor.."Enable Castbars")
	Window:CreateSwitch("Unitframe", "ClassResources", "Show Class Resources")
	Window:CreateSwitch("Unitframe", "CombatFade", "Fade Unitframes")
	Window:CreateSwitch("Unitframe", "DebuffHighlight", "Show Health Debuff Highlight")
	Window:CreateSwitch("Unitframe", "Enable", enableTextColor.."Enable Unitframes")
	Window:CreateSwitch("Unitframe", "GlobalCooldown", "Show Global Cooldown")
	Window:CreateSwitch("Unitframe", "OnlyShowPlayerDebuff", "Only Show Your Debuffs")
	Window:CreateSwitch("Unitframe", "PortraitTimers", "Portrait Spell Timers")
	Window:CreateSwitch("Unitframe", "PvPIndicator", "Show PvP Indicator on Player / Target")
	Window:CreateSwitch("Unitframe", "ResurrectSound", "Sound Played When You Are Resurrected")
	Window:CreateSwitch("Unitframe", "ShowHealPrediction", "Show HealPrediction Statusbars")
	Window:CreateSwitch("Unitframe", "Smooth", "Smooth Bars")
	if K.Class == "MONK" then
		Window:CreateSwitch("Unitframe", "Stagger", "Show |CFF00FF96Monk|r Stagger Bar")
	end
	Window:CreateSwitch("Unitframe", "Swingbar", "Unitframe Swingbar")
	Window:CreateSwitch("Unitframe", "SwingbarTimer", "Unitframe Swingbar Timer")

	Window:CreateSection("Unitframe Floating CombatText")
	Window:CreateSwitch("Unitframe", "CombatText", enableTextColor.."Enable Simple CombatText")
	Window:CreateSwitch("Unitframe", "AutoAttack", "Show AutoAttack Damage")
	Window:CreateSwitch("Unitframe", "FCTOverHealing", "Show Full OverHealing")
	Window:CreateSwitch("Unitframe", "HotsDots", "Show Hots and Dots")
	Window:CreateSwitch("Unitframe", "PetCombatText", "Pet's Healing/Damage")

	Window:CreateSection("Unitframe Player")
	Window:CreateSwitch("Unitframe", "AdditionalPower", "Show Additional Mana Power (|CFFFF7D0ADruid|r, |CFFFFFFFFPriest|r, |CFF0070DEShaman|r)")
	Window:CreateSwitch("Unitframe", "PlayerBuffs", "Show Player Frame Buffs")
	Window:CreateSwitch("Unitframe", "PlayerDeBuffs", "Show Player Frame Debuffs")
	Window:CreateSwitch("Unitframe", "PlayerPowerPrediction", "Show Player Power Prediction")
	Window:CreateSwitch("Unitframe", "ShowPlayerLevel", "Show Player Frame Level")
	Window:CreateSwitch("Unitframe", "ShowPlayerName", "Show Player Frame Name")

	Window:CreateSection("Unitframe Target")
	Window:CreateSwitch("Unitframe", "TargetBuffs", "Show Target Frame Buffs")
	Window:CreateSwitch("Unitframe", "TargetDebuffs", "Show Target Frame Debuffs")
	Window:CreateSlider("Unitframe", "TargetBuffsPerRow", "Number of Buffs Per Row", 4, 10, 1, UpdateTargetBuffs)
	Window:CreateSlider("Unitframe", "TargetDebuffsPerRow", "Number of Debuffs Per Row", 4, 10, 1, UpdateTargetDebuffs)

	Window:CreateSection("Unitframe Target Of Target")
	Window:CreateSwitch("Unitframe", "HideTargetofTarget", "Hide TargetofTarget Frame")
	Window:CreateSwitch("Unitframe", "HideTargetOfTargetLevel", "Hide TargetofTarget Level")
	Window:CreateSwitch("Unitframe", "HideTargetOfTargetName", "Hide TargetofTarget Name")

	Window:CreateSection("Unitframe Sizes")
	Window:CreateSlider("Unitframe", "PlayerCastbarHeight", "Player Castbar Height", 20, 40, 1)
	Window:CreateSlider("Unitframe", "PlayerCastbarWidth", "Player Castbar Width", 160, 300, 1)
	Window:CreateSlider("Unitframe", "TargetCastbarHeight", "Target Castbar Height", 20, 40, 1)
	Window:CreateSlider("Unitframe", "TargetCastbarWidth", "Target Castbar Width", 160, 300, 1)

	Window:CreateSection("Unitframe Misc")
	Window:CreateDropdown("Unitframe", "HealthbarColor", "Health Color Format")
	Window:CreateDropdown("Unitframe", "PortraitStyle", "Unitframe Portrait Style")
end

local Party = function(self)
	local Window = self:CreateWindow(L["Party"])

	Window:CreateSection("Party Toggles")
	Window:CreateSwitch("Party", "Enable", enableTextColor.."Enable Party")
	Window:CreateSwitch("Party", "Castbars", "Show Castbars")
	Window:CreateSwitch("Party", "PortraitTimers", "Portrait Spell Timers")
	Window:CreateSwitch("Party", "ShowBuffs", "Show Party Buffs")
	Window:CreateSwitch("Party", "ShowHealPrediction", "Show HealPrediction Statusbars")
	Window:CreateSwitch("Party", "ShowPet", "Show Party Pets")
	Window:CreateSwitch("Party", "ShowPlayer", "Show Player In Party")
	Window:CreateSwitch("Party", "Smooth", "Smooth Bar Transition")
	Window:CreateSwitch("Party", "TargetHighlight", "Show Highlighted Target")

	Window:CreateSection("Party Misc")
	Window:CreateDropdown("Party", "HealthbarColor", "Health Color Format")
end

local Boss = function(self)
	local Window = self:CreateWindow(L["Boss"])

	Window:CreateSection("Boss Toggles")
	Window:CreateSwitch("Boss", "Enable", enableTextColor.."Enable Boss", "Toggle Boss Module On/Off")
	Window:CreateSwitch("Boss", "Castbars", "Show Castbars")
	Window:CreateSwitch("Boss", "Smooth", "Smooth Bar Transition")

	Window:CreateSection("Boss Misc")
	Window:CreateDropdown("Boss", "HealthbarColor", "Health Color Format")
end

local Arena = function(self)
	local Window = self:CreateWindow(L["Arena"])

	Window:CreateSection("Arena Toggles")
	Window:CreateSwitch("Arena", "Enable", enableTextColor.."Enable Arena")
	Window:CreateSwitch("Arena", "Castbars", "Show Castbars")
	Window:CreateSwitch("Arena", "Smooth", "Smooth Bar Transition")

	Window:CreateSection("Arena Misc")
	Window:CreateDropdown("Arena", "HealthbarColor", "Health Color Format")
end

local Raid = function(self)
	local Window = self:CreateWindow(L["Raid"])

	Window:CreateSection("Raid Toggles")
	Window:CreateSwitch("Raid", "Enable", enableTextColor.."Enable Raidframes")
	Window:CreateSwitch("Raid", "AuraDebuffs", "AuraWatch")
	Window:CreateSwitch("Raid", "AuraWatch", "Show AuraWatch Icons")
	Window:CreateSwitch("Raid", "HorizonRaid", "Horizontal Raid Frames")
	-- Window:CreateSwitch("Raid", "MainTankFrames", "MainTank Frames")
	Window:CreateSwitch("Raid", "ManabarShow", "Show Manabars")
	Window:CreateSwitch("Raid", "RaidUtility", "Show Raid Utility Frame")
	Window:CreateSwitch("Raid", "ReverseRaid", "Reverse Raid Frame Growth")
	Window:CreateSwitch("Raid", "ShowHealPrediction", "Show HealPrediction Statusbars")
	Window:CreateSwitch("Raid", "ShowNotHereTimer", "Show Away/DND Status")
	Window:CreateSwitch("Raid", "ShowTeamIndex", "Show Group Number Team Index")
	Window:CreateSwitch("Raid", "Smooth", "Smooth Bar Transition")
	Window:CreateSwitch("Raid", "SpecRaidPos", "Save Raid Positions Based On Specs")
	Window:CreateSwitch("Raid", "TargetHighlight", "Show Highlighted Target")

	Window:CreateSection("Raid Values")
	Window:CreateSlider("Raid", "AuraDebuffIconSize", "Aura Debuff Icon Size", 18, 30, 1)
	Window:CreateSlider("Raid", "AuraWatchIconSize", "AuraWatch Icon Size", 8, 14, 1)
	Window:CreateSlider("Raid", "Height", "Raidframe Height", 20, 100, 1)
	Window:CreateSlider("Raid", "NumGroups", "Number Of Groups to Show", 1, 8, 1)
	Window:CreateSlider("Raid", "Width", "Raidframe Width", 20, 100, 1)

	Window:CreateSection("Raid Misc")
	Window:CreateDropdown("Raid", "HealthbarColor", "Health Color Format")
	Window:CreateDropdown("Raid", "HealthFormat", "Health Format")
end

local QuestNotifier = function(self)
	if IsAddOnLoaded("QuestNotifier") then
		return
	end

	local Window = self:CreateWindow(L["QuestNotifier"])

	Window:CreateSection("QuestNotifier Toggles")
	Window:CreateSwitch("QuestNotifier", "Enable", enableTextColor.."Enable QuestNotifier")
	Window:CreateSwitch("QuestNotifier", "OnlyCompleteRing", "Only Play Complete Quest Sound")
	Window:CreateSwitch("QuestNotifier", "QuestProgress", "Alert QuestProgress In Chat")
end

local WorldMap = function(self)
	local Window = self:CreateWindow(L["WorldMap"])

	Window:CreateSection("WorldMap Toggles")
	Window:CreateSwitch("WorldMap", "Coordinates", "Show Player/Mouse Coordinates")
	Window:CreateSwitch("WorldMap", "FadeWhenMoving", "Fade Worldmap When Moving")
	Window:CreateSwitch("WorldMap", "SmallWorldMap", "Show Smaller Worldmap")
	Window:CreateSwitch("WorldMap", "WorldMapPlus", "Show Enhanced World Map Features")

	Window:CreateSection("WorldMap Values")
	Window:CreateSlider("WorldMap", "AlphaWhenMoving", "Alpha When Moving", 0.1, 1, 0.1)
end

GUI:AddWidgets(ActionBar)
GUI:AddWidgets(Announcements)
GUI:AddWidgets(Arena)
GUI:AddWidgets(Auras)
GUI:AddWidgets(Automation)
GUI:AddWidgets(Boss)
GUI:AddWidgets(Chat)
GUI:AddWidgets(DataBars)
GUI:AddWidgets(DataText)
GUI:AddWidgets(Filger)
GUI:AddWidgets(General)
GUI:AddWidgets(Inventory)
GUI:AddWidgets(Loot)
GUI:AddWidgets(Minimap)
GUI:AddWidgets(Misc)
GUI:AddWidgets(Nameplate)
GUI:AddWidgets(Party)
GUI:AddWidgets(PulseCooldown)
GUI:AddWidgets(QuestNotifier)
GUI:AddWidgets(Raid)
GUI:AddWidgets(Skins)
GUI:AddWidgets(Tooltip)
GUI:AddWidgets(UIFonts)
GUI:AddWidgets(UITextures)
GUI:AddWidgets(Unitframe)
GUI:AddWidgets(WorldMap)