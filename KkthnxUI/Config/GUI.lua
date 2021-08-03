local K, C, L = unpack(select(2, ...))
local GUI = K["GUI"]

local _G = _G

local SetSortBagsRightToLeft = _G.SetSortBagsRightToLeft

local enableTextColor = "|cff00cc4c"
local newFeatureIcon = "|TInterface\\GossipFrame\\CampaignAvailableQuestIcon:16:16:-2|t"
local emojiExample = "|TInterface\\Addons\\KkthnxUI\\Media\\Chat\\Emojis\\StuckOutTongueClosedEyes:0:0:4|t"

local function UpdateBagSortOrder()
	SetSortBagsRightToLeft(not C["Inventory"].ReverseSort)
end

local function UpdateBagStatus()
	K:GetModule("Bags"):UpdateAllBags()
end

local function updateBagAnchor()
	K:GetModule("Bags"):UpdateAllAnchors()
end

local function UpdateTargetBuffs()
	local frame = _G.oUF_Target
	if not frame then
		return
	end

	local element = frame.Buffs
	element.iconsPerRow = C["Unitframe"].TargetBuffsPerRow

	local width = C["Unitframe"].TargetHealthWidth
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

	local width = C["Unitframe"].TargetHealthWidth
	local maxLines = element.iconsPerRow and K.Round((element.num) / element.iconsPerRow)
	element.size = K:GetModule("Unitframes").auraIconSize(width, element.iconsPerRow, element.spacing)
	element:SetWidth(width)
	element:SetHeight((element.size + element.spacing) * maxLines)
	element:ForceUpdate()
end

local function UpdateChatSticky()
	K:GetModule("Chat"):ChatWhisperSticky()
end

local function UpdateChatSize()
	K:GetModule("Chat"):UpdateChatSize()
end

local function ToggleChatBackground()
	K:GetModule("Chat"):ToggleChatBackground()
end

local function UpdateChatBubble()
	for _, chatBubble in pairs(C_ChatBubbles.GetAllChatBubbles()) do
		chatBubble.KKUI_Background:SetVertexColor(C["Media"].Backdrops.ColorBackdrop[1], C["Media"].Backdrops.ColorBackdrop[2], C["Media"].Backdrops.ColorBackdrop[3], C["Skins"].ChatBubbleAlpha)
	end
end

local function UpdateHotkeys()
	local Bar = K:GetModule("ActionBar")
	for _, button in pairs(Bar.buttons) do
		if button.UpdateHotkeys then
			button:UpdateHotkeys(button.buttonType)
		end
	end
end

local function UpdateMarkerGrid()
	K:GetModule("Blizzard"):RaidTool_UpdateGrid()
end

local function UpdateActionbarScale()
	K:GetModule("ActionBar"):UpdateAllScale()
end

local function UpdateCustomBar()
	K:GetModule("ActionBar"):UpdateCustomBar()
end

local function SetupAuraWatch()
	GUI:Toggle()
	SlashCmdList["KKUI_AWCONFIG"]() -- To Be Implemented
end

local function ResetDetails()
	if IsAddOnLoaded("Details") then
		_G.KkthnxUIDB.Variables["ResetDetails"] = true
		StaticPopup_Show("KKUI_CHANGES_RELOAD")
	else
		K.Print("Details is not loaded!")
	end
end

local function UpdateBlipTextures()
	K:GetModule("Minimap"):UpdateBlipTexture()
end

local function UpdateFilterList()
	K:GetModule("Chat"):UpdateFilterList()
end

local function UpdateFilterWhiteList()
	K:GetModule("Chat"):UpdateFilterWhiteList()
end

local function UpdateDataBarsSize()
	K:GetModule("DataBars"):UpdateDataBarsSize()
end

local function UpdateTotemBar()
	if not C["Auras"].Totems then
		return
	end

	K:GetModule("Auras"):TotemBar_Init()
end

local function UIScaleNotice()
	if C["General"].AutoScale and not K.setNotice then
		K.Print("Turn off AutoScale before using UIScale slider!")
		K.setNotice = true
	end
end

local function UpdateQuestFontSize()
	K:GetModule("Miscellaneous"):CreateQuestSizeUpdate()
end

local function UpdateCustomUnitList()
	K:GetModule("Unitframes"):CreateUnitTable()
end

local function UpdatePowerUnitList()
	K:GetModule("Unitframes"):CreatePowerUnitTable()
end

local function UpdateInterruptAlert()
	K:GetModule("Announcements"):CreateInterruptAnnounce()
end

local function UpdateNameplates()
	K:GetModule("Unitframes"):RefreshAllPlates()
end

local function UpdateUnitPlayerSize()
	local width = C["Unitframe"].PlayerHealthWidth
	local healthHeight = C["Unitframe"].PlayerHealthHeight
	local powerHeight = C["Unitframe"].PlayerPowerHeight
	local height = healthHeight + powerHeight + 6

	if not oUF_Player then
		return
	end

	_G.oUF_Player:SetSize(width, height)
	_G.oUF_Player.Health:SetHeight(healthHeight)
	_G.oUF_Player.Power:SetHeight(powerHeight)

	if C["Unitframe"].PortraitStyle.Value ~= "NoPortraits" then
		if _G.KKUI_PlayerPortrait then
			_G.KKUI_PlayerPortrait:SetSize(healthHeight + powerHeight + 6, healthHeight + powerHeight + 6)
		end
	end
end

local function UpdateUnitTargetSize()
	local width = C["Unitframe"].TargetHealthWidth
	local healthHeight = C["Unitframe"].TargetHealthHeight
	local powerHeight = C["Unitframe"].TargetPowerHeight
	local height = healthHeight + powerHeight + 6

	if not oUF_Target then
		return
	end

	_G.oUF_Target:SetSize(width, height)
	_G.oUF_Target.Health:SetHeight(healthHeight)
	_G.oUF_Target.Power:SetHeight(powerHeight)

	if C["Unitframe"].PortraitStyle.Value ~= "NoPortraits" then
		if _G.KKUI_TargetPortrait then
			_G.KKUI_TargetPortrait:SetSize(healthHeight + powerHeight + 6, healthHeight + powerHeight + 6)
		end
	end
end

local function UpdateUnitFocusSize()
	local width = C["Unitframe"].FocusHealthWidth
	local healthHeight = C["Unitframe"].FocusHealthHeight
	local powerHeight = C["Unitframe"].FocusPowerHeight
	local height = healthHeight + powerHeight + 6

	if not oUF_Focus then
		return
	end

	_G.oUF_Focus:SetSize(width, height)
	_G.oUF_Focus.Health:SetHeight(healthHeight)
	_G.oUF_Focus.Power:SetHeight(powerHeight)

	if C["Unitframe"].PortraitStyle.Value ~= "NoPortraits" then
		if _G.KKUI_FocusPortrait then
			_G.KKUI_FocusPortrait:SetSize(healthHeight + powerHeight + 6, healthHeight + powerHeight + 6)
		end
	end
end

local function UpdateUnitPartySize()
	local width = C["Party"].HealthWidth
	local healthHeight = C["Party"].HealthHeight
	local powerHeight = C["Party"].PowerHeight
	local height = healthHeight + powerHeight + 6

	for i = 1, MAX_PARTY_MEMBERS do
		local bu = _G["oUF_PartyUnitButton"..i]
		if bu then
			bu:SetSize(width, height)
			bu.Health:SetHeight(healthHeight)
			bu.Power:SetHeight(powerHeight)

			if C["Unitframe"].PortraitStyle.Value ~= "NoPortraits" then
				if _G.KKUI_PartyPortrait then
					_G.KKUI_PartyPortrait:SetSize(healthHeight + powerHeight + 6, healthHeight + powerHeight + 6)
				end
			end
		end
	end
end

local function UpdateUnitRaidSize()
	local width = C["Raid"].Width
	local healthHeight = C["Raid"].Height
	-- local powerHeight = C["Party"].PowerHeight
	local height = healthHeight

	for i = 1, MAX_RAID_MEMBERS do
		if InCombatLockdown() then
			return
		end

		local bu = _G["oUF_Raid"..i.."UnitButton"..i]
		if bu then
			bu:SetSize(width, height)
			bu.Health:SetHeight(healthHeight)
			-- bu.Power:SetHeight(powerHeight)
		end
	end
end

-- Translate Below Before Shadowlands
local ActionBar = function(self)
	local Window = self:CreateWindow(L["ActionBar"])

	Window:CreateSection(L["Toggles"])
	Window:CreateSwitch("ActionBar", "Enable", enableTextColor..L["Enable ActionBar"])
	Window:CreateSwitch("ActionBar", "Cooldowns", L["Show Cooldowns"])
	Window:CreateSwitch("ActionBar", "Count", L["Enable Count"])
	Window:CreateSwitch("ActionBar", "DecimalCD", L["Format Cooldowns As Decimals"])
	Window:CreateSwitch("ActionBar", "Hotkey", L["Enable Hotkey"], nil, UpdateHotkeys)
	Window:CreateSwitch("ActionBar", "Macro", L["Enable Macro"])
	Window:CreateSwitch("ActionBar", "MicroBar", L["Enable MicroBar"])
	Window:CreateSwitch("ActionBar", "OverrideWA", L["Enable OverrideWA"])
	Window:CreateSwitch("ActionBar", "PetBar", L["Show PetBar"])
	Window:CreateSwitch("ActionBar", "StanceBar", L["Show StanceBar"])

	Window:CreateSection(L["KKUI_CustomBar"])
	Window:CreateSwitch("ActionBar", "CustomBar", enableTextColor..L["Enable CustomBar"])
	Window:CreateSwitch("ActionBar", "FadeCustomBar", L["Mouseover CustomBar"])
	Window:CreateSlider("ActionBar", "CustomBarButtonSize", L["Set CustomBar Button Size"], 24, 60, 1, nil, UpdateCustomBar)
	Window:CreateSlider("ActionBar", "CustomBarNumButtons", L["Set CustomBar Num Buttons"], 1, 12, 1, nil, UpdateCustomBar)
	Window:CreateSlider("ActionBar", "CustomBarNumPerRow", L["Set CustomBar Num PerRow"], 1, 12, 1, nil, UpdateCustomBar)

	Window:CreateSection(L["Sizes"])
	Window:CreateSlider("ActionBar", "Scale", L["Set Actionbars Scale"], 0.6, 1.6, 0.1, nil, UpdateActionbarScale)

	Window:CreateSection(L["Fading"])
	Window:CreateSwitch("ActionBar", "FadeMicroBar", L["Mouseover MicroBar"])
	Window:CreateSwitch("ActionBar", "FadeRightBar", L["Mouseover RightBar 1"])
	Window:CreateSwitch("ActionBar", "FadeRightBar2", L["Mouseover RightBar 2"])

	Window:CreateSection(L["Layouts"])
	Window:CreateDropdown("ActionBar", "Layout", L["Choose Your Layout"])
end

local Announcements = function(self)
	local Window = self:CreateWindow(L["Announcements"])

	Window:CreateSection(L["Toggles"])
	Window:CreateSwitch("Announcements", "ItemAlert", L["Announce Items Being Placed"])
	Window:CreateSwitch("Announcements", "PullCountdown", L["Announce Pull Countdown (/pc #)"])
	Window:CreateSwitch("Announcements", "ResetInstance", L["Alert Group After Instance Resetting"])
	Window:CreateSwitch("Announcements", "SaySapped", L["Announce When Sapped"])
	Window:CreateSwitch("Announcements", "KillingBlow", L["Show Your Killing Blow Info"])
	Window:CreateSwitch("Announcements", "PvPEmote", L["Auto Emote On Your Killing Blow"])
	Window:CreateSwitch("Announcements", "HealthAlert", L["Announce When Low On Health"])

	Window:CreateSection(INTERRUPT)
	Window:CreateSwitch("Announcements", "InterruptAlert", enableTextColor..L["Announce Interrupts"], nil, UpdateInterruptAlert)
	Window:CreateSwitch("Announcements", "DispellAlert", enableTextColor..L["Announce Dispells"], nil, UpdateInterruptAlert)
	Window:CreateSwitch("Announcements", "BrokenAlert", enableTextColor..L["Announce Broken Spells"], nil, UpdateInterruptAlert)
	Window:CreateSwitch("Announcements", "OwnInterrupt", L["Own Interrupts Announced Only"])
	Window:CreateSwitch("Announcements", "OwnDispell", L["Own Dispells Announced Only"])
	Window:CreateSwitch("Announcements", "InstAlertOnly", L["Announce Only In Instances"], nil, UpdateInterruptAlert)
	Window:CreateDropdown("Announcements", "AlertChannel", L["Announce Interrupts To Specified Chat Channel"])

	Window:CreateSection(L["QuestNotifier"])
	Window:CreateSwitch("Announcements", "QuestNotifier", enableTextColor..L["Enable QuestNotifier"])
	Window:CreateSwitch("Announcements", "OnlyCompleteRing", L["Only Play Complete Quest Sound"])
	Window:CreateSwitch("Announcements", "QuestProgress", L["Alert QuestProgress In Chat"])

	Window:CreateSection(L["Rare Alert"])
	Window:CreateSwitch("Announcements", "RareAlert", enableTextColor..L["Enable Event & Rare Alerts"])
	Window:CreateSwitch("Announcements", "AlertInWild", L["Don't Alert In instances"])
	Window:CreateSwitch("Announcements", "AlertInChat", L["Print Alerts In Chat"])
end

local Automation = function(self)
	local Window = self:CreateWindow(L["Automation"])

	Window:CreateSection(L["Toggles"])
	Window:CreateSwitch("Automation", "AutoBlockStrangerInvites", L["Blocks Invites From Strangers"])
	Window:CreateSwitch("Automation", "AutoCollapse", L["Auto Collapse Objective Tracker"])
	Window:CreateSwitch("Automation", "AutoDeclineDuels", L["Decline PvP Duels"])
	Window:CreateSwitch("Automation", "AutoDeclinePetDuels", L["Decline Pet Duels"])
	Window:CreateSwitch("Automation", "AutoDisenchant", L["Milling, Prospecting & Disenchanting by Alt + Click"])
	Window:CreateSwitch("Automation", "AutoGoodbye", L["Say Goodbye After Dungeon Completion."])
	Window:CreateSwitch("Automation", "AutoInvite", L["Accept Invites From Friends & Guild Members"])
	Window:CreateSwitch("Automation", "AutoOpenItems", L["Auto Open Items In Your Inventory"])
	Window:CreateSwitch("Automation", "AutoPartySync", L["Accept PartySync From Friends & Guild Members"])
	Window:CreateSwitch("Automation", "AutoRelease", L["Auto Release in Battlegrounds & Arenas"])
	Window:CreateSwitch("Automation", "AutoResurrect", L["Auto Accept Resurrect Requests"])
	Window:CreateSwitch("Automation", "AutoResurrectThank", L["Say 'Thank You' When Resurrected"])
	Window:CreateSwitch("Automation", "AutoReward", L["Auto Select Quest Rewards Best Value"])
	Window:CreateSwitch("Automation", "AutoScreenshot", L["Auto Screenshot Achievements"])
	Window:CreateSwitch("Automation", "AutoSetRole", L["Auto Set Your Role In Groups"])
	Window:CreateSwitch("Automation", "AutoSkipCinematic", L["Auto Skip All Cinematic/Movies"])
	Window:CreateSwitch("Automation", "AutoSummon", L["Auto Accept Summon Requests"])
	Window:CreateSwitch("Automation", "AutoTabBinder", L["Only Tab Target Enemy Players"])
	Window:CreateSwitch("Automation", "NoBadBuffs", L["Automatically Remove Annoying Buffs"])
	Window:CreateEditBox("Automation", "WhisperInvite", L["Auto Accept Invite Keyword"])
end

local Inventory = function(self)
	local Window = self:CreateWindow(L["Inventory"])

	Window:CreateSection(L["Toggles"])
	Window:CreateSwitch("Inventory", "Enable", enableTextColor..L["Enable Inventory"])
	Window:CreateSwitch("Inventory", "AutoSell", L["Auto Vendor Grays"])
	Window:CreateSwitch("Inventory", "BagBar", L["Enable Bagbar"])
	Window:CreateSwitch("Inventory", "BagBarMouseover", L["Fade Bagbar"])
	Window:CreateSwitch("Inventory", "BagsItemLevel", L["Display Item Level"], nil, UpdateBagStatus)
	Window:CreateSwitch("Inventory", "DeleteButton", L["Bags Delete Button"])
	Window:CreateSwitch("Inventory", "MutliRows", L["Anchor Every Five Rows Into One Row"], nil, updateBagAnchor)
	Window:CreateSwitch("Inventory", "PetTrash", L["Pet Trash Currencies"], "In patch 9.1, you can buy 3 battle pets by using specific trash items. Keep this enabled, will sort these items into Collection Filter, and won't be sold by auto junk")
	Window:CreateSwitch("Inventory", "ReverseSort", L["Umm Reverse The Sorting"], nil, UpdateBagSortOrder)
	Window:CreateSwitch("Inventory", "ShowNewItem", L["Show New Item Glow"])
	Window:CreateSwitch("Inventory", "UpgradeIcon", L["Show Upgrade Icon"])
	Window:CreateDropdown("Inventory", "AutoRepair", L["Auto Repair Gear"])

	Window:CreateSection(FILTERS)
	Window:CreateSwitch("Inventory", "ItemFilter", L["Filter Items Into Categories"], nil, UpdateBagStatus)
	Window:CreateSwitch("Inventory", "FilterAnima", L["Filter Anima Items"], nil, UpdateBagStatus)
	Window:CreateSwitch("Inventory", "FilterAzerite", "Filter Azerite Items", nil, UpdateBagStatus)
	Window:CreateSwitch("Inventory", "FilterCollection", L["Filter Collection Items"], nil, UpdateBagStatus)
	Window:CreateSwitch("Inventory", "FilterConsumable", L["Filter Consumable Items"], nil, UpdateBagStatus)
	Window:CreateSwitch("Inventory", "FilterEquipSet", L["Filter EquipSet"], nil, UpdateBagStatus)
	Window:CreateSwitch("Inventory", "FilterEquipment", L["Filter Equipment Items"], nil, UpdateBagStatus)
	Window:CreateSwitch("Inventory", "FilterFavourite", L["Filter Favourite Items"], nil, UpdateBagStatus)
	Window:CreateSwitch("Inventory", "FilterGoods", L["Filter Goods Items"], nil, UpdateBagStatus)
	Window:CreateSwitch("Inventory", "FilterJunk", L["Filter Junk Items"], nil, UpdateBagStatus)
	Window:CreateSwitch("Inventory", "FilterLegendary", L["Filter Legendary Items"], nil, UpdateBagStatus)
	Window:CreateSwitch("Inventory", "FilterQuest", L["Filter Quest Items"], nil, UpdateBagStatus)
	Window:CreateSwitch("Inventory", "FilterRelic", L["Filter Korthia Relic Items"], nil, UpdateBagStatus)
	Window:CreateSwitch("Inventory", "GatherEmpty", L["Gather Empty Slots Into One Button"], nil, UpdateBagStatus)

	Window:CreateSection(L["Sizes"])
	Window:CreateSlider("Inventory", "BagsWidth", L["Bags Width"], 8, 16, 1)
	Window:CreateSlider("Inventory", "BankWidth", L["Bank Width"], 10, 18, 1)
	Window:CreateSlider("Inventory", "IconSize", L["Slot Icon Size"], 28, 40, 1)
end

local Auras = function(self)
	local Window = self:CreateWindow(L["Auras"])

	Window:CreateSection(L["Toggles"])
	Window:CreateSwitch("Auras", "Enable", enableTextColor..L["Enable Auras"])
	Window:CreateSwitch("Auras", "Reminder", L["Auras Reminder (Shout/Intellect/Poison)"])
	Window:CreateSwitch("Auras", "ReverseBuffs", L["Buffs Grow Right"])
	Window:CreateSwitch("Auras", "ReverseDebuffs", L["Debuffs Grow Right"])

	Window:CreateSection(L["Sizes"])
	Window:CreateSlider("Auras", "BuffSize", L["Buff Icon Size"], 20, 40, 1)
	Window:CreateSlider("Auras", "BuffsPerRow", L["Buffs per Row"], 10, 20, 1)
	Window:CreateSlider("Auras", "DebuffSize", L["DeBuff Icon Size"], 20, 40, 1)
	Window:CreateSlider("Auras", "DebuffsPerRow", L["DeBuffs per Row"], 10, 16, 1)

	Window:CreateSection(TUTORIAL_TITLE47)
	Window:CreateSwitch("Auras", "Totems", enableTextColor..L["Enable TotemBar"])
	Window:CreateSwitch("Auras", "VerticalTotems", L["Vertical TotemBar"], nil, UpdateTotemBar)
	Window:CreateSlider("Auras", "TotemSize", L["Totems IconSize"], 24, 60, 1, nil, UpdateTotemBar)
end

local AuraWatch = function(self)
	local Window = self:CreateWindow(L["AuraWatch"])

	Window:CreateSection(L["Toggles"])
	Window:CreateButton(L["AuraWatch GUI"], nil, nil, SetupAuraWatch)
	Window:CreateSwitch("AuraWatch", "Enable", enableTextColor..L["Enable AuraWatch"])
	Window:CreateSwitch("AuraWatch", "ClickThrough", L["Disable AuraWatch Tooltip (ClickThrough)"], "If enabled, the icon would be uninteractable, you can't select or mouseover them.")
	Window:CreateSwitch("AuraWatch", "DeprecatedAuras", L["Track Auras From Previous Expansions"])
	Window:CreateSwitch("AuraWatch", "QuakeRing", L["Alert On M+ Quake"])
	Window:CreateSlider("AuraWatch", "IconScale", L["AuraWatch IconScale"], 0.8, 2, 0.1)
end

local Chat = function(self)
	local Window = self:CreateWindow(L["Chat"])

	Window:CreateSection(L["Toggles"])
	Window:CreateSwitch("Chat", "Enable", enableTextColor..L["Enable Chat"])
	Window:CreateSwitch("Chat", "Background", L["Show Chat Background"], nil, ToggleChatBackground)
	Window:CreateSwitch("Chat", "ChatItemLevel", L["Show ItemLevel on ChatFrames"])
	Window:CreateSwitch("Chat", "ChatMenu", L["Show Chat Menu Buttons"])
	Window:CreateSwitch("Chat", "Emojis", L["Show Emojis In Chat"]..emojiExample)
	Window:CreateSwitch("Chat", "Freedom", L["Disable Chat Language Filter"])
	Window:CreateSwitch("Chat", "Lock", L["Lock Chat"])
	Window:CreateSwitch("Chat", "LootIcons", L["Show Chat Loot Icons"])
	Window:CreateSwitch("Chat", "OldChatNames", L["Use Default Channel Names"])
	Window:CreateSwitch("Chat", "RoleIcons", L["Show Role Icons In Chat"])
	Window:CreateSwitch("Chat", "Sticky", L["Stick On Channel If Whispering"], nil, UpdateChatSticky)
	Window:CreateSwitch("Chat", "WhisperColor", L["Differ Whipser Colors"])
	Window:CreateDropdown("Chat", "TimestampFormat", L["Custom Chat Timestamps"])

	Window:CreateSection(L["Sizes"])
	Window:CreateSlider("Chat", "Height", L["Lock Chat Height"], 100, 500, 1, nil, UpdateChatSize)
	Window:CreateSlider("Chat", "Width", L["Lock Chat Width"], 200, 600, 1, nil, UpdateChatSize)
	Window:CreateSlider("Chat", "LogMax", L["Chat History Lines To Save"], 10, 500, 10)

	Window:CreateSection(L["Fading"])
	Window:CreateSwitch("Chat", "Fading", L["Fade Chat Text"])
	Window:CreateSlider("Chat", "FadingTimeVisible", L["Fading Chat Visible Time"], 5, 120, 1)

	Window:CreateSection(FILTERS)
	Window:CreateSwitch("Chat", "EnableFilter", enableTextColor..L["Enable Chat Filter"])
	Window:CreateSwitch("Chat", "BlockSpammer", L["Block Repeated Spammer Messages"])
	Window:CreateSwitch("Chat", "BlockAddonAlert", L["Block 'Some' AddOn Alerts"])
	Window:CreateSwitch("Chat", "BlockStranger", L["Block Whispers From Strangers"])
	Window:CreateSlider("Chat", "FilterMatches", L["Filter Matches Number"], 1, 3, 1)
	Window:CreateEditBox("Chat", "ChatFilterList", L["ChatFilter BlackList"], "Enter words you want blacklisted|n|nUse SPACES between each word|n|nPress enter when you are done", UpdateFilterList)
	Window:CreateEditBox("Chat", "ChatFilterWhiteList", L["ChatFilter WhiteList"], "Enter words you want whitelisted|n|nUse SPACES between each word|n|nPress enter when you are done", UpdateFilterWhiteList)
end

local DataBars = function(self)
	local Window = self:CreateWindow(L["DataBars"])

	Window:CreateSection(L["Toggles"])
	Window:CreateSwitch("DataBars", "Enable", enableTextColor..L["Enable DataBars"])
	Window:CreateSwitch("DataBars", "MouseOver", L["Fade DataBars"])
	Window:CreateSwitch("DataBars", "Text", L["Show Text"])
	Window:CreateSwitch("DataBars", "TrackHonor", L["Track Honor"])
	Window:CreateDropdown("DataBars", "Text", L["Pick Text Formatting"])

	Window:CreateSection(L["Sizes"])
	Window:CreateSlider("DataBars", "Height", L["DataBars Height"], 14, 20, 1, nil, UpdateDataBarsSize)
	Window:CreateSlider("DataBars", "Width", L["DataBars Width"], 20, 300, 1, nil, UpdateDataBarsSize)

	Window:CreateSection(COLORS)
	Window:CreateColorSelection("DataBars", "ExperienceColor", L["Experience Bar Color"])
	Window:CreateColorSelection("DataBars", "HonorColor", L["Honor Bar Color"])
	Window:CreateColorSelection("DataBars", "RestedColor", L["Rested Bar Color"])
end

local DataText = function(self)
	local Window = self:CreateWindow(L["DataText"])

	Window:CreateSection(L["Toggles"])
	Window:CreateSwitch("DataText", "Friends", L["Enable Friends Info"])
	Window:CreateSwitch("DataText", "Gold", L["Enable Currency Info"])
	Window:CreateSwitch("DataText", "Guild", L["Enable Guild Info"])
	Window:CreateSwitch("DataText", "Latency", L["Enable Latency Info"])
	Window:CreateSwitch("DataText", "Location", L["Enable Minimap Location"])
	Window:CreateSwitch("DataText", "System", L["Enable System Info"])
	Window:CreateSwitch("DataText", "Time", L["Enable Minimap Time"])
	Window:CreateSwitch("DataText", "Coords", L["Enable Positon Coords"])
	Window:CreateColorSelection("DataText", "IconColor", L["Color The Icons"]) -- Needs Locale

	Window:CreateSection(L["Text"])
	Window:CreateSwitch("DataText", "HideText", L["Hide Icon Text"])
end

local General = function(self)
	local Window = self:CreateWindow(L["General"], true)

	Window:CreateSection("Profiles")
	local AddProfile = Window:CreateDropdown("General", "Profiles", L["Import Profiles From Other Characters"])
	AddProfile.Menu:HookScript("OnHide", GUI.SetProfile)

	Window:CreateSection(L["Toggles"])
	Window:CreateSwitch("General", "MoveBlizzardFrames", L["Move Blizzard Frames"])
	Window:CreateSwitch("General", "NoErrorFrame", L["Disable Blizzard Error Frame Combat"])
	Window:CreateSwitch("General", "NoTutorialButtons", L["Disable 'Some' Blizzard Tutorials"])
	Window:CreateSwitch("General", "VersionCheck", L["Enable Version Checking"])
	Window:CreateSwitch("General", "Welcome", L["Show Welcome Message"])
	Window:CreateDropdown("General", "BorderStyle", L["Border Style"])
	Window:CreateDropdown("General", "NumberPrefixStyle", L["Number Prefix Style"])

	Window:CreateSection(L["Scaling"])
	Window:CreateSwitch("General", "AutoScale", L["Auto Scale"], L["AutoScaleTip"])
	Window:CreateSlider("General", "UIScale", L["Set UI scale"], 0.4, 1.15, 0.01, L["UIScaleTip"], UIScaleNotice)

	Window:CreateSection(COLORS)
	Window:CreateSwitch("General", "ColorTextures", L["Color 'Most' KkthnxUI Borders"])
	Window:CreateColorSelection("General", "TexturesColor", L["Textures Color"])
end

local Loot = function(self)
	local Window = self:CreateWindow(L["Loot"])

	Window:CreateSection(L["Toggles"])
	Window:CreateSwitch("Loot", "Enable", enableTextColor..L["Enable Loot"])
	Window:CreateSwitch("Loot", "GroupLoot", enableTextColor..L["Enable Group Loot"])
	Window:CreateSwitch("Loot", "AutoConfirm", L["Auto Confirm Loot Dialogs"])
	Window:CreateSwitch("Loot", "AutoGreed", L["Auto Greed Green Items"])
	Window:CreateSwitch("Loot", "FastLoot", L["Faster Auto-Looting"])
end

local Minimap = function(self)
	local Window = self:CreateWindow(L["Minimap"])

	Window:CreateSection(L["Toggles"])
	Window:CreateSwitch("Minimap", "Enable", enableTextColor..L["Enable Minimap"])
	Window:CreateSwitch("Minimap", "Calendar", L["Show Minimap Calendar"], "If enabled, show minimap calendar icon on minimap.|nYou can simply click mouse middle button on minimap to toggle calendar even without this option.")
	Window:CreateSwitch("Minimap", "ShowRecycleBin", L["Show Minimap Button Collector"])
	Window:CreateDropdown("Minimap", "RecycleBinPosition", L["Set RecycleBin Positon"])
	Window:CreateDropdown("Minimap", "BlipTexture", L["Blip Icon Styles"], nil, nil, UpdateBlipTextures)
	Window:CreateDropdown("Minimap", "LocationText", L["Location Text Style"])

	Window:CreateSection(L["Sizes"])
	Window:CreateSlider("Minimap", "Size", L["Minimap Size"], 120, 300, 1)
end

local Misc = function(self)
	local Window = self:CreateWindow(L["Misc"])

	Window:CreateSection(L["Toggles"])
	Window:CreateSwitch("Misc", "AFKCamera", L["AFK Camera"])
	Window:CreateSwitch("Misc", "ColorPicker", L["Enhanced Color Picker"])
	Window:CreateSwitch("Misc", "EasyMarking", L["EasyMarking by Ctrl + LeftClick"])
	Window:CreateSwitch("Misc", "EnhancedFriends", L["Enhanced Colors (Friends/Guild +)"])
	Window:CreateSwitch("Misc", "GemEnchantInfo", L["Character/Inspect Gem/Enchant Info"])
	Window:CreateSwitch("Misc", "HideBanner", L["Hide RaidBoss EmoteFrame"])
	Window:CreateSwitch("Misc", "HideBossEmote", L["Hide BossBanner"])
	Window:CreateSwitch("Misc", "ImprovedStats", L["Display Character Frame Full Stats"])
	Window:CreateSwitch("Misc", "ItemLevel", L["Show Character/Inspect ItemLevel Info"])
	Window:CreateSwitch("Misc", "MDGuildBest", L["Show Mythic+ GuildBest"])
	Window:CreateSwitch("Misc", "MawThreatBar", L["Replace Default Maw Threat Status"])
	Window:CreateSwitch("Misc", "NoTalkingHead", L["Remove And Hide The TalkingHead Frame"])
	Window:CreateSwitch("Misc", "PriorityStats", newFeatureIcon.."Show Stat Priority Above Character Frame")
	Window:CreateSwitch("Misc", "ShowWowHeadLinks", L["Show Wowhead Links Above Questlog Frame"])
	Window:CreateSwitch("Misc", "SlotDurability", L["Show Slot Durability %"])
	Window:CreateSwitch("Misc", "TradeTabs", L["Add Spellbook-Like Tabs On TradeSkillFrame"])
	Window:CreateDropdown("Misc", "ShowMarkerBar", L["World Markers Bar"], nil, nil, UpdateMarkerGrid)

	Window:CreateSection(BUTTON_LAG_MAIL)
	Window:CreateSwitch("Misc", "EnhancedMail", "Enhance Mail Frame With Many Useful Features")
	Window:CreateSwitch("Misc", "MailSaver", "Mail Saver")

	Window:CreateSection("Paragon Reputation")
	Window:CreateSwitch("Misc", "ParagonEnable", L["Paragon Enable"], L["ParagonReputationTip"])
	Window:CreateSwitch("Misc", "ParagonToast", L["Paragon Toast"])
	Window:CreateSwitch("Misc", "ParagonToastSound", L["Paragon Toast Sound"])
	Window:CreateColorSelection("Misc", "ParagonColor", L["Paragon Color"])
	Window:CreateSlider("Misc", "ParagonToastFade", L["Paragon Toast Fade"], 1, 15, 1)
	Window:CreateDropdown("Misc", "ParagonText", L["Paragon Text Format"])

	Window:CreateSection(MOUSE_LABEL)
	Window:CreateSwitch("Misc", "MouseTrail", L["Enable Mouse Trail"])
	Window:CreateColorSelection("Misc", "MouseTrailColor", L["Mouse Trail Color"])
	Window:CreateDropdown("Misc", "MouseTrailTexture", "Pick Your Mouse Texture")
end

local Nameplate = function(self)
	local Window = self:CreateWindow(L["Nameplate"])

	Window:CreateSection(L["Toggles"])
	Window:CreateSwitch("Nameplate", "Enable", enableTextColor..L["Enable Nameplates"])
	Window:CreateSwitch("Nameplate", "AKSProgress", L["Show AngryKeystones Progress"])
	Window:CreateSwitch("Nameplate", "CastbarGlow", "Force Marjor Spells To Glow")
	Window:CreateSwitch("Nameplate", "ClassIcon", L["Show Enemy Class Icons"])
	Window:CreateSwitch("Nameplate", "ColoredTarget", "Colored Target Something Thing")
	Window:CreateSwitch("Nameplate", "CustomUnitColor", L["Colored Custom Units"])
	Window:CreateSwitch("Nameplate", "DPSRevertThreat", L["Revert Threat Color If Not Tank"])
	Window:CreateSwitch("Nameplate", "ExplosivesScale", L["Scale Nameplates for Explosives"])
	Window:CreateSwitch("Nameplate", "FriendlyCC", L["Show Friendly ClassColor"])
	Window:CreateSwitch("Nameplate", "FullHealth", L["Show Health Value"], nil, UpdateNameplates)
	Window:CreateSwitch("Nameplate", "HostileCC", L["Show Hostile ClassColor"])
	Window:CreateSwitch("Nameplate", "InsideView", L["Interacted Nameplate Stay Inside"])
	Window:CreateSwitch("Nameplate", "NameOnly", L["Show Only Names For Friendly"])
	Window:CreateSwitch("Nameplate", "NameplateClassPower", L["Target Nameplate ClassPower"])
	Window:CreateSwitch("Nameplate", "QuestIndicator", L["Quest Progress Indicator"])
	Window:CreateSwitch("Nameplate", "Smooth", L["Smooth Bars Transition"])
	Window:CreateSwitch("Nameplate", "TankMode", L["Force TankMode Colored"])
	Window:CreateDropdown("Nameplate", "AuraFilter", L["Auras Filter Style"], nil, nil, UpdateNameplates)
	Window:CreateDropdown("Nameplate", "TargetIndicator", L["TargetIndicator Style"], nil, nil, UpdateNameplates)
	Window:CreateDropdown("Nameplate", "TargetIndicatorTexture", "TargetIndicator Texture") -- Needs Locale
	Window:CreateEditBox("Nameplate", "CustomUnitList", L["Custom UnitColor List"], L["CustomUnitTip"], UpdateCustomUnitList)
	Window:CreateEditBox("Nameplate", "PowerUnitList", L["Custom PowerUnit List"], L["CustomUnitTip"], UpdatePowerUnitList)

	Window:CreateSection(L["Sizes"])
	Window:CreateSlider("Nameplate", "AuraSize", L["Auras Size"], 18, 40, 1, nil, UpdateNameplates)
	Window:CreateSlider("Nameplate", "Distance", L["Nameplete MaxDistance"], 10, 100, 1)
	Window:CreateSlider("Nameplate", "ExecuteRatio", L["Unit Execute Ratio"], 0, 90, 1, L["ExecuteRatioTip"])
	Window:CreateSlider("Nameplate", "HealthTextSize", L["HealthText FontSize"], 8, 16, 1, nil, UpdateNameplates)
	Window:CreateSlider("Nameplate", "MaxAuras", L["Max Auras"], 4, 8, 1, nil, UpdateNameplates)
	Window:CreateSlider("Nameplate", "MinAlpha", L["Non-Target Nameplate Alpha"], 0.1, 1, 0.1)
	Window:CreateSlider("Nameplate", "MinScale", L["Non-Target Nameplate Scale"], 0.1, 3, 0.1)
	Window:CreateSlider("Nameplate", "NameTextSize", L["NameText FontSize"], 8, 16, 1, nil, UpdateNameplates)
	Window:CreateSlider("Nameplate", "PlateHeight", L["Nameplate Height"], 6, 28, 1, nil, UpdateNameplates)
	Window:CreateSlider("Nameplate", "PlateWidth", L["Nameplate Width"], 80, 240, 1, nil, UpdateNameplates)
	Window:CreateSlider("Nameplate", "VerticalSpacing", L["Nameplate Vertical Spacing"], 0.1, 1, 1)

	Window:CreateSection("Player Nameplate Toggles")
	Window:CreateSwitch("Nameplate", "ShowPlayerPlate", enableTextColor..L["Enable Personal Resource"])
	Window:CreateSwitch("Nameplate", "ClassAuras", L["Track Personal Class Auras"])
	Window:CreateSwitch("Nameplate", "PPGCDTicker", L["Enable GCD Ticker"])
	Window:CreateSwitch("Nameplate", "PPHideOOC", L["Only Visible in Combat"])
	Window:CreateSwitch("Nameplate", "PPOnFire", "Always Refresh PlayerPlate Auras")
	Window:CreateSwitch("Nameplate", "PPPowerText", L["Show Power Value"])

	Window:CreateSection("Player Nameplate Values")
	Window:CreateSlider("Nameplate", "PPHeight", L["Classpower/Healthbar Height"], 4, 10, 1, nil, UpdateNameplates)
	Window:CreateSlider("Nameplate", "PPIconSize", L["PlayerPlate IconSize"], 20, 40, 1)
	Window:CreateSlider("Nameplate", "PPPHeight", L["PlayerPlate Powerbar Height"], 4, 10, 1, nil, UpdateNameplates)

	Window:CreateSection(COLORS)
	Window:CreateColorSelection("Nameplate", "CustomColor", L["Custom Color"])
	Window:CreateColorSelection("Nameplate", "InsecureColor", L["Insecure Color"])
	Window:CreateColorSelection("Nameplate", "OffTankColor", L["Off-Tank Color"])
	Window:CreateColorSelection("Nameplate", "SecureColor", L["Secure Color"])
	Window:CreateColorSelection("Nameplate", "TargetColor", "Selected Target Coloring")
	Window:CreateColorSelection("Nameplate", "TargetIndicatorColor", L["TargetIndicator Color"])
	Window:CreateColorSelection("Nameplate", "TransColor", L["Transition Color"])
end

local PulseCooldown = function(self)
	local Window = self:CreateWindow(L["PulseCooldown"])

	Window:CreateSection(L["Toggles"])
	Window:CreateSwitch("PulseCooldown", "Enable", enableTextColor..L["Enable PulseCooldown"])
	Window:CreateSwitch("PulseCooldown", "Sound", L["Play Sound On Pulse"])

	Window:CreateSection(L["Sizes"])
	Window:CreateSlider("PulseCooldown", "AnimScale", L["Animation Scale"], 0.5, 2, 0.1)
	Window:CreateSlider("PulseCooldown", "HoldTime", L["How Long To Display"], 0.1, 1, 0.1)
	Window:CreateSlider("PulseCooldown", "Size", L["Icon Size"], 60, 85, 1)
	Window:CreateSlider("PulseCooldown", "Threshold", L["Minimal Threshold Time"], 1, 5, 1)
end

local Skins = function(self)
	local Window = self:CreateWindow(L["Skins"])

	Window:CreateSection("Blizzard Skins")
	Window:CreateSwitch("Skins", "BlizzardFrames", L["Skin Some Blizzard Frames & Objects"])
	Window:CreateSwitch("Skins", "TalkingHeadBackdrop", L["TalkingHead Skin"])
	Window:CreateSwitch("Skins", "ChatBubbles", L["ChatBubbles Skin"])
	Window:CreateSlider("Skins", "ChatBubbleAlpha", L["ChatBubbles Background Alpha"], 0, 1, 0.1, nil, UpdateChatBubble)

	Window:CreateSection("AddOn Skins")
	Window:CreateSwitch("Skins", "Bartender4", L["Bartender4 Skin"])
	Window:CreateSwitch("Skins", "ButtonForge", L["ButtonForge Skin"])
	Window:CreateSwitch("Skins", "DeadlyBossMods", L["Deadly Boss Mods Skin"])
	Window:CreateSwitch("Skins", "Details", L["Details Skin"])
	Window:CreateSwitch("Skins", "Dominos", L["Dominos Skin"])
	Window:CreateSwitch("Skins", "RareScanner", L["RareScanner Skin"])
	Window:CreateSwitch("Skins", "WeakAuras", L["WeakAuras Skin"])
	Window:CreateButton(L["Reset Details"], nil, nil, ResetDetails)

	-- Disabled / Broken Skins
	-- Window:CreateSwitch("Skins", "BigWigs", L["BigWigs Skin"])
	-- Window:CreateSwitch("Skins", "ChocolateBar", L["ChocolateBar Skin"])
	-- Window:CreateSwitch("Skins", "Hekili", L["Hekili Skin"])
	-- Window:CreateSwitch("Skins", "Skada", L["Skada Skin"])
	-- Window:CreateSwitch("Skins", "Spy", L["Spy Skin"])
	-- Window:CreateSwitch("Skins", "TellMeWhen", L["TellMeWhen Skin"])
	-- Window:CreateSwitch("Skins", "TitanPanel", L["TitanPanel Skin"])
end

local Tooltip = function(self)
	local Window = self:CreateWindow(L["Tooltip"])

	Window:CreateSection(L["Toggles"])
	Window:CreateSwitch("Tooltip", "Enable", enableTextColor.."Enable Tooltip")
	Window:CreateSwitch("Tooltip", "ClassColor", L["Quality Color Border"])
	Window:CreateSwitch("Tooltip", "DominationRank", "Show Rank On Domination Shards/Armor")
	Window:CreateSwitch("Tooltip", "CombatHide", L["Hide Tooltip in Combat"])
	Window:CreateSwitch("Tooltip", "ConduitInfo", L["Conduit Collected Info"])
	Window:CreateSwitch("Tooltip", "Cursor", L["Follow Cursor"])
	Window:CreateSwitch("Tooltip", "FactionIcon", L["Show Faction Icon"])
	Window:CreateSwitch("Tooltip", "HideJunkGuild", L["Abbreviate Guild Names"])
	Window:CreateSwitch("Tooltip", "HideRank", L["Hide Guild Rank"])
	Window:CreateSwitch("Tooltip", "HideRealm", L["Show realm name by SHIFT"])
	Window:CreateSwitch("Tooltip", "HideTitle", L["Hide Player Title"])
	Window:CreateSwitch("Tooltip", "Icons", L["Item Icons"])
	Window:CreateSwitch("Tooltip", "LFDRole", L["Show Roles Assigned Icon"])
	Window:CreateSwitch("Tooltip", "MDScore", "Show Mythic+ Rating")
	Window:CreateSwitch("Tooltip", "ShowIDs", L["Show Tooltip IDs"])
	Window:CreateSwitch("Tooltip", "SpecLevelByShift", L["Show Spec/ItemLevel by SHIFT"])
	Window:CreateSwitch("Tooltip", "TargetBy", L["Show Player Targeted By"])

	Window:CreateSection("Raid Progression")
	Window:CreateSwitch("Tooltip", "Raids", enableTextColor.."Enable Raid Progression")
	Window:CreateSwitch("Tooltip", "Castle Nathria", "Castle Nathria")
	Window:CreateSwitch("Tooltip", "Sanctum of Domination", "Sanctum of Domination")

	Window:CreateSection("Mythic Progression")
	Window:CreateSwitch("Tooltip", "Mythics", enableTextColor.."Enable Mythics Progression")
	Window:CreateSwitch("Tooltip", "De Other Side", "De Other Side")
	Window:CreateSwitch("Tooltip", "Halls of Atonement", "Halls of Atonement")
	Window:CreateSwitch("Tooltip", "Mists of Tirna Scithe", "Mists of Tirna Scithe")
	Window:CreateSwitch("Tooltip", "Plaguefall", "Plaguefall Progression")
	Window:CreateSwitch("Tooltip", "Sanguine Depths", "Sanguine Depths")
	Window:CreateSwitch("Tooltip", "Spires of Ascension", "Spires of Ascension")
	Window:CreateSwitch("Tooltip", "Tazavesh, the Veiled Market", "Tazavesh, the Veiled Market")
	Window:CreateSwitch("Tooltip", "The Necrotic Wake", "The Necrotic Wake")
	Window:CreateSwitch("Tooltip", "Theater of Pain", "Theater of Pain")

	Window:CreateSection("Special Progression")
	Window:CreateSwitch("Tooltip", "Special", enableTextColor.."Enable Special Progression")
	Window:CreateSwitch("Tooltip", "Shadowlands Keystone Master: Season One", "Keystone Master: Season One")
	Window:CreateSwitch("Tooltip", "Shadowlands Keystone Master: Season Two", "Keystone Master: Season Two")
end

local UIFonts = function(self)
	local Window = self:CreateWindow(L["UIFonts"])

	Window:CreateSection("UI Fonts")
	Window:CreateDropdown("UIFonts", "ActionBarsFonts", L["Set ActionBar Font"], "Font")
	Window:CreateDropdown("UIFonts", "AuraFonts", L["Set Auras Font"], "Font")
	Window:CreateDropdown("UIFonts", "ChatFonts", L["Set Chat Font"], "Font")
	Window:CreateDropdown("UIFonts", "DataBarsFonts", L["Set DataBars Font"], "Font")
	Window:CreateDropdown("UIFonts", "DataTextFonts", L["Set DataText Font"], "Font")
	Window:CreateDropdown("UIFonts", "FilgerFonts", L["Set Filger Font"], "Font")
	Window:CreateDropdown("UIFonts", "GeneralFonts", L["Set General Font"], "Font")
	Window:CreateDropdown("UIFonts", "InventoryFonts", L["Set Inventory Font"], "Font")
	Window:CreateDropdown("UIFonts", "MinimapFonts", L["Set Minimap Font"], "Font")
	Window:CreateDropdown("UIFonts", "NameplateFonts", L["Set Nameplate Font"], "Font")
	Window:CreateDropdown("UIFonts", "QuestTrackerFonts", L["Set QuestTracker Font"], "Font")
	Window:CreateDropdown("UIFonts", "SkinFonts", L["Set Skins Font"], "Font")
	Window:CreateDropdown("UIFonts", "TooltipFonts", L["Set Tooltip Font"], "Font")
	Window:CreateDropdown("UIFonts", "UnitframeFonts", L["Set Unitframe Font"], "Font")

	Window:CreateSection("Font Tweaks")
	Window:CreateSlider("UIFonts", "QuestFontSize", L["Adjust QuestFont Size"], 10, 30, 1, nil, UpdateQuestFontSize)
end

local UITextures = function(self)
	local Window = self:CreateWindow(L["UITextures"])

	Window:CreateSection("UI Textures")
	Window:CreateDropdown("UITextures", "DataBarsTexture", L["Set DataBars Texture"], "Texture")
	Window:CreateDropdown("UITextures", "FilgerTextures", L["Set Filger Texture"], "Texture")
	Window:CreateDropdown("UITextures", "GeneralTextures", L["Set General Texture"], "Texture")
	Window:CreateDropdown("UITextures", "HealPredictionTextures", L["Set HealPrediction Texture"], "Texture")
	Window:CreateDropdown("UITextures", "LootTextures", L["Set Loot Texture"], "Texture")
	Window:CreateDropdown("UITextures", "NameplateTextures", L["Set Nameplate Texture"], "Texture")
	Window:CreateDropdown("UITextures", "QuestTrackerTexture", L["Set QuestTracker Texture"], "Texture")
	Window:CreateDropdown("UITextures", "SkinTextures", L["Set Skins Texture"], "Texture")
	Window:CreateDropdown("UITextures", "TooltipTextures", L["Set Tooltip Texture"], "Texture")
	Window:CreateDropdown("UITextures", "UnitframeTextures", L["Set Unitframe Texture"], "Texture")
end

local function updateUFTextScale()
	K:GetModule("Unitframes"):UpdateTextScale()
end

local Unitframe = function(self)
	local Window = self:CreateWindow(L["Unitframe"])

	Window:CreateSection(L["Toggles"])
	Window:CreateSwitch("Unitframe", "Enable", enableTextColor..L["Enable Unitframes"])
	Window:CreateSwitch("Unitframe", "CastClassColor", L["Class Color Castbars"])
	Window:CreateSwitch("Unitframe", "CastReactionColor", L["Reaction Color Castbars"])
	Window:CreateSwitch("Unitframe", "ClassResources", L["Show Class Resources"])
	Window:CreateSwitch("Unitframe", "CombatFade", L["Fade Unitframes"])
	Window:CreateSwitch("Unitframe", "DebuffHighlight", L["Show Health Debuff Highlight"])
	Window:CreateSwitch("Unitframe", "PvPIndicator", L["Show PvP Indicator on Player / Target"])
	Window:CreateSwitch("Unitframe", "ResurrectSound", L["Sound Played When You Are Resurrected"])
	Window:CreateSwitch("Unitframe", "ShowHealPrediction", L["Show HealPrediction Statusbars"])
	Window:CreateSwitch("Unitframe", "Smooth", L["Smooth Bars"])
	Window:CreateSwitch("Unitframe", "Stagger", L["Show |CFF00FF96Monk|r Stagger Bar"])

	Window:CreateSlider("Unitframe", "AllTextScale", "(TEST) Scale All Unitframe Texts", .8, 1.5, .05, nil, updateUFTextScale)

	Window:CreateSection("Combat Text")
	Window:CreateSwitch("Unitframe", "CombatText", enableTextColor..L["Enable Simple CombatText"])
	Window:CreateSwitch("Unitframe", "AutoAttack", L["Show AutoAttack Damage"])
	Window:CreateSwitch("Unitframe", "FCTOverHealing", L["Show Full OverHealing"])
	Window:CreateSwitch("Unitframe", "HotsDots", L["Show Hots and Dots"])
	Window:CreateSwitch("Unitframe", "PetCombatText", L["Pet's Healing/Damage"])

	Window:CreateSection(PLAYER)
	Window:CreateSwitch("Unitframe", "AdditionalPower", L["Show Additional Mana Power (|CFFFF7D0ADruid|r, |CFFFFFFFFPriest|r, |CFF0070DEShaman|r)"])
	Window:CreateSwitch("Unitframe", "CastbarLatency", L["Show Castbar Latency"])
	Window:CreateSwitch("Unitframe", "GlobalCooldown", "Show Global Cooldown Spark")
	Window:CreateSwitch("Unitframe", "PlayerBuffs", L["Show Player Frame Buffs"])
	Window:CreateSwitch("Unitframe", "PlayerCastbar", L["Enable Player CastBar"])
	Window:CreateSwitch("Unitframe", "PlayerCastbarIcon", L["Enable Player CastBar"].." Icon")
	Window:CreateSwitch("Unitframe", "PlayerDeBuffs", L["Show Player Frame Debuffs"])
	Window:CreateSwitch("Unitframe", "PlayerPowerPrediction", L["Show Player Power Prediction"])
	if C["Unitframe"].PortraitStyle.Value ~= "NoPortraits" then
		Window:CreateSwitch("Unitframe", "ShowPlayerLevel", L["Show Player Frame Level"])
	end
	Window:CreateSwitch("Unitframe", "ShowPlayerName", L["Show Player Frame Name"])
	Window:CreateSwitch("Unitframe", "Swingbar", L["Unitframe Swingbar"])
	Window:CreateSwitch("Unitframe", "SwingbarTimer", L["Unitframe Swingbar Timer"])
	Window:CreateSlider("Unitframe", "PlayerPowerHeight", "Player Power Bar Height", 10, 40, 1, nil, UpdateUnitPlayerSize)
	Window:CreateSlider("Unitframe", "PlayerHealthHeight", L["Player Frame Height"], 20, 75, 1, nil, UpdateUnitPlayerSize)
	Window:CreateSlider("Unitframe", "PlayerHealthWidth", L["Player Frame Width"], 100, 300, 1, nil, UpdateUnitPlayerSize)
	Window:CreateSlider("Unitframe", "PlayerCastbarHeight", L["Player Castbar Height"], 20, 40, 1)
	Window:CreateSlider("Unitframe", "PlayerCastbarWidth", L["Player Castbar Width"], 100, 300, 1)

	Window:CreateSection(TARGET)
	Window:CreateSwitch("Unitframe", "OnlyShowPlayerDebuff", L["Only Show Your Debuffs"])
	Window:CreateSwitch("Unitframe", "TargetBuffs", L["Show Target Frame Buffs"])
	Window:CreateSwitch("Unitframe", "TargetCastbar", L["Enable Target CastBar"])
	Window:CreateSwitch("Unitframe", "TargetCastbarIcon", L["Enable Target CastBar"].." Icon")
	Window:CreateSwitch("Unitframe", "TargetDebuffs", L["Show Target Frame Debuffs"])
	Window:CreateSlider("Unitframe", "TargetBuffsPerRow", L["Number of Buffs Per Row"], 4, 10, 1, nil, UpdateTargetBuffs)
	Window:CreateSlider("Unitframe", "TargetDebuffsPerRow", L["Number of Debuffs Per Row"], 4, 10, 1, nil, UpdateTargetDebuffs)
	Window:CreateSlider("Unitframe", "TargetPowerHeight", "Target Power Bar Height", 10, 40, 1, nil, UpdateUnitTargetSize)
	Window:CreateSlider("Unitframe", "TargetHealthHeight", L["Target Frame Height"], 20, 75, 1, nil, UpdateUnitTargetSize)
	Window:CreateSlider("Unitframe", "TargetHealthWidth", L["Target Frame Width"], 100, 300, 1, nil, UpdateUnitTargetSize)
	Window:CreateSlider("Unitframe", "TargetCastbarHeight", L["Target Castbar Height"], 20, 40, 1)
	Window:CreateSlider("Unitframe", "TargetCastbarWidth", L["Target Castbar Width"], 100, 300, 1)

	Window:CreateSection(PET)
	Window:CreateSwitch("Unitframe", "HidePetLevel", L["Hide Pet Level"])
	Window:CreateSwitch("Unitframe", "HidePetName", L["Hide Pet Name"])
	Window:CreateSlider("Unitframe", "PetHealthHeight", L["Pet Frame Height"], 10, 50, 1)
	Window:CreateSlider("Unitframe", "PetHealthWidth", L["Pet Frame Width"], 100, 300, 1)
	Window:CreateSlider("Unitframe", "PetPowerHeight", L["Pet Power Bar"], 10, 50, 1)

	Window:CreateSection("Target Of Target")
	Window:CreateSwitch("Unitframe", "HideTargetofTarget", L["Hide TargetofTarget Frame"])
	Window:CreateSwitch("Unitframe", "HideTargetOfTargetLevel", L["Hide TargetofTarget Level"])
	Window:CreateSwitch("Unitframe", "HideTargetOfTargetName", L["Hide TargetofTarget Name"])
	Window:CreateSlider("Unitframe", "TargetTargetHealthHeight", L["Target of Target Frame Height"], 10, 50, 1)
	Window:CreateSlider("Unitframe", "TargetTargetHealthWidth", L["Target of Target Frame Width"], 100, 300, 1)
	Window:CreateSlider("Unitframe", "TargetTargetPowerHeight", L["Target of Target Frame Height"], 10, 50, 1)

	Window:CreateSection(FOCUS)
	Window:CreateSlider("Unitframe", "FocusPowerHeight", "Focus Power Bar Height", 10, 40, 1, nil, UpdateUnitFocusSize)
	Window:CreateSlider("Unitframe", "FocusHealthHeight", L["Focus Frame Height"], 20, 75, 1, nil, UpdateUnitFocusSize)
	Window:CreateSlider("Unitframe", "FocusHealthWidth", L["Focus Frame Width"], 100, 300, 1, nil, UpdateUnitFocusSize)
	Window:CreateSwitch("Unitframe", "FocusBuffs", L["Show Target Frame Buffs"])
	Window:CreateSwitch("Unitframe", "FocusCastbar", L["Enable Target CastBar"])
	Window:CreateSwitch("Unitframe", "FocusCastbarIcon", L["Enable Target CastBar"].." Icon")
	Window:CreateSwitch("Unitframe", "FocusDebuffs", L["Show Target Frame Debuffs"])

	Window:CreateSection("Focus Target")
	Window:CreateSlider("Unitframe", "FocusTargetPowerHeight", "Focus Target Power Height", 10, 40, 1, nil, setUnitFocusTargetSize)
	Window:CreateSlider("Unitframe", "FocusTargetHealthHeight", "Focus Target Health Height", 20, 75, 1, nil, setUnitFocusTargetSize)
	Window:CreateSlider("Unitframe", "FocusTargetHealthWidth", "Focus Target Health Width", 100, 300, 1, nil, setUnitFocusTargetSize)

	Window:CreateSection("Unitframe Misc")
	Window:CreateDropdown("Unitframe", "HealthbarColor", L["Health Color Format"])
	Window:CreateDropdown("Unitframe", "PortraitStyle", L["Unitframe Portrait Style"], nil, "It is highly recommanded to NOT use 3D portraits as you could see a drop in FPS")
end

local Party = function(self)
	local Window = self:CreateWindow(L["Party"])

	Window:CreateSection(L["Toggles"])
	Window:CreateSwitch("Party", "Enable", enableTextColor..L["Enable Party"])
	Window:CreateSwitch("Party", "ShowBuffs", L["Show Party Buffs"])
	Window:CreateSwitch("Party", "ShowHealPrediction", L["Show HealPrediction Statusbars"])
	Window:CreateSwitch("Party", "ShowPartySolo", "Show Party Frames While Solo")
	Window:CreateSwitch("Party", "ShowPet", L["Show Party Pets"])
	Window:CreateSwitch("Party", "ShowPlayer", L["Show Player In Party"])
	Window:CreateSwitch("Party", "Smooth", L["Smooth Bar Transition"])
	Window:CreateSwitch("Party", "TargetHighlight", L["Show Highlighted Target"])

	Window:CreateSection("Party Castbars")
	Window:CreateSwitch("Party", "Castbars", L["Show Castbars"])
	Window:CreateSwitch("Party", "CastbarIcon", L["Show Castbars"].." Icon")

	Window:CreateSection(L["Sizes"])
	Window:CreateSlider("Party", "HealthHeight", "Party Frame Health Height", 20, 50, 1, nil, UpdateUnitPartySize)
	Window:CreateSlider("Party", "HealthWidth", "Party Frame Health Width", 120, 180, 1, nil, UpdateUnitPartySize)
	Window:CreateSlider("Party", "PowerHeight", "Party Frame Power Height", 10, 30, 1, nil, UpdateUnitPartySize)

	Window:CreateSection(COLOR)
	Window:CreateDropdown("Party", "HealthbarColor", L["Health Color Format"])
end

local Boss = function(self)
	local Window = self:CreateWindow(L["Boss"])

	Window:CreateSection(L["Toggles"])
	Window:CreateSwitch("Boss", "Enable", enableTextColor..L["Enable Boss"], "Toggle Boss Module On/Off")
	Window:CreateSwitch("Boss", "Castbars", L["Show Castbars"])
	Window:CreateSwitch("Boss", "CastbarIcon", "Show Castbars Icon")
	Window:CreateSwitch("Boss", "Smooth", L["Smooth Bar Transition"])

	Window:CreateSection(L["Sizes"])
	Window:CreateSlider("Boss", "HealthHeight", "Health Height", 20, 50, 1)
	Window:CreateSlider("Boss", "HealthWidth", "Health Width", 120, 180, 1)
	Window:CreateSlider("Boss", "PowerHeight", "Power Height", 10, 30, 1)
	Window:CreateSlider("Boss", "YOffset", "Vertical Offset From One Another"..K.GreyColor.."(54)|r", 40, 60, 1)

	Window:CreateSection(COLOR)
	Window:CreateDropdown("Boss", "HealthbarColor", L["Health Color Format"])
end

local Arena = function(self)
	local Window = self:CreateWindow(L["Arena"])

	Window:CreateSection(L["Toggles"])
	Window:CreateSwitch("Arena", "Enable", enableTextColor..L["Enable Arena"], "Toggle Arena Module On/Off")
	Window:CreateSwitch("Arena", "Castbars", L["Show Castbars"])
	Window:CreateSwitch("Arena", "CastbarIcon", "Show Castbars Icon")
	Window:CreateSwitch("Arena", "Smooth", L["Smooth Bar Transition"])

	Window:CreateSection(L["Sizes"])
	Window:CreateSlider("Arena", "HealthHeight", "Health Height", 20, 50, 1)
	Window:CreateSlider("Arena", "HealthWidth", "Health Width", 120, 180, 1)
	Window:CreateSlider("Arena", "PowerHeight", "Power Height", 10, 30, 1)
	Window:CreateSlider("Arena", "YOffset", "Vertical Offset From One Another"..K.GreyColor.."(54)|r", 40, 60, 1)

	Window:CreateSection(COLOR)
	Window:CreateDropdown("Arena", "HealthbarColor", L["Health Color Format"])
end

local Raid = function(self)
	local Window = self:CreateWindow(L["Raid"])

	Window:CreateSection(L["Toggles"])
	Window:CreateSwitch("Raid", "Enable", enableTextColor..L["Enable Raidframes"])
	Window:CreateSwitch("Raid", "HorizonRaid", L["Horizontal Raid Frames"])
	Window:CreateSwitch("Raid", "MainTankFrames", L["Show MainTank Frames"])
	Window:CreateSwitch("Raid", "ManabarShow", L["Show Manabars"])
	Window:CreateSwitch("Raid", "RaidUtility", L["Show Raid Utility Frame"])
	Window:CreateSwitch("Raid", "ReverseRaid", L["Reverse Raid Frame Growth"])
	Window:CreateSwitch("Raid", "ShowHealPrediction", L["Show HealPrediction Statusbars"])
	Window:CreateSwitch("Raid", "ShowNotHereTimer", L["Show Away/DND Status"])
	Window:CreateSwitch("Raid", "ShowRaidSolo", "Show Raid Frames While Solo")
	Window:CreateSwitch("Raid", "ShowTeamIndex", L["Show Group Number Team Index"])
	Window:CreateSwitch("Raid", "Smooth", L["Smooth Bar Transition"])
	Window:CreateSwitch("Raid", "SpecRaidPos", L["Save Raid Positions Based On Specs"])
	Window:CreateSwitch("Raid", "TargetHighlight", L["Show Highlighted Target"])

	Window:CreateSection(L["Sizes"])
	Window:CreateSlider("Raid", "Height", L["Raidframe Height"], 20, 100, 1, nil, UpdateUnitRaidSize)
	Window:CreateSlider("Raid", "NumGroups", L["Number Of Groups to Show"], 1, 8, 1)
	Window:CreateSlider("Raid", "Width", L["Raidframe Width"], 20, 100, 1, nil, UpdateUnitRaidSize)

	Window:CreateSection(COLOR)
	Window:CreateDropdown("Raid", "HealthbarColor", L["Health Color Format"])
	Window:CreateDropdown("Raid", "HealthFormat", L["Health Format"])

	Window:CreateSection("Raid Buffs")
	Window:CreateDropdown("Raid", "RaidBuffsStyle", "Select the buff style you want to use") -- Needs Locale

	if C["Raid"].RaidBuffsStyle.Value == "Standard" then
		Window:CreateDropdown("Raid", "RaidBuffs", "Enable buffs display & filtering") -- Needs Locale
		Window:CreateSwitch("Raid", "DesaturateBuffs", "Desaturate buffs that are not by me") -- Needs Locale
	elseif C["Raid"].RaidBuffsStyle.Value == "Aura Track" then
		Window:CreateSwitch("Raid", "AuraTrack", "Enable auras tracking module for healer (replace buffs)") -- Needs Locale
		Window:CreateSwitch("Raid", "AuraTrackIcons", "Use squared icons instead of status bars") -- Needs Locale
		Window:CreateSwitch("Raid", "AuraTrackSpellTextures", "Display icons texture on aura squares instead of colored squares") -- Needs Locale
		Window:CreateSlider("Raid", "AuraTrackThickness", "Thickness size of status bars in pixel", 2, 10, 1) -- Needs Locale
	end

	Window:CreateSection("Raid Debuffs")
	Window:CreateSwitch("Raid", "DebuffWatch", "Enable debuffs tracking (filtered auto by current gameplay (pvp or pve)") -- Needs Locale
	Window:CreateSwitch("Raid", "DebuffWatchDefault", "We have already a debuff tracking list for pve and pvp, use it?") -- Needs Locale
end

local WorldMap = function(self)
	local Window = self:CreateWindow(L["WorldMap"])

	Window:CreateSection(L["Toggles"])
	Window:CreateSwitch("WorldMap", "Coordinates", L["Show Player/Mouse Coordinates"])
	Window:CreateSwitch("WorldMap", "FadeWhenMoving", L["Fade Worldmap When Moving"])
	Window:CreateSwitch("WorldMap", "SmallWorldMap", L["Show Smaller Worldmap"])

	Window:CreateSection("WorldMap Reveal")
	Window:CreateSwitch("WorldMap", "MapRevealGlow", L["Map Reveal Shadow"], L["MapRevealTip"])
	Window:CreateColorSelection("WorldMap", "MapRevealGlowColor", L["Map Reveal Shadow Color"])

	Window:CreateSection(L["Sizes"])
	Window:CreateSlider("WorldMap", "AlphaWhenMoving", L["Alpha When Moving"], 0.1, 1, 0.1)
end

GUI:AddWidgets(ActionBar)
GUI:AddWidgets(Announcements)
GUI:AddWidgets(Arena)
GUI:AddWidgets(AuraWatch)
GUI:AddWidgets(Auras)
GUI:AddWidgets(Automation)
GUI:AddWidgets(Boss)
GUI:AddWidgets(Chat)
GUI:AddWidgets(DataBars)
GUI:AddWidgets(DataText)
GUI:AddWidgets(General)
GUI:AddWidgets(Inventory)
GUI:AddWidgets(Loot)
GUI:AddWidgets(Minimap)
GUI:AddWidgets(Misc)
GUI:AddWidgets(Nameplate)
GUI:AddWidgets(Party)
GUI:AddWidgets(PulseCooldown)
GUI:AddWidgets(Raid)
GUI:AddWidgets(Skins)
GUI:AddWidgets(Tooltip)
GUI:AddWidgets(UIFonts)
GUI:AddWidgets(UITextures)
GUI:AddWidgets(Unitframe)
GUI:AddWidgets(WorldMap)