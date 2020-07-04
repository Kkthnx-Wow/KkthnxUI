local K, C, L = unpack(select(2, ...))

--local _G = _G

--local ACHIEVEMENTS_GUILD_TAB = _G.ACHIEVEMENTS_GUILD_TAB
--local ACHIEVEMENT_BUTTON = _G.ACHIEVEMENT_BUTTON
--local BLIZZARD_STORE = _G.BLIZZARD_STORE
--local CALENDAR_VIEW_EVENT = _G.CALENDAR_VIEW_EVENT
--local CHARACTER_BUTTON = _G.CHARACTER_BUTTON
--local CHAT_CHANNELS = _G.CHAT_CHANNELS
--local COMMUNITIES = _G.COMMUNITIES
--local COMPACT_UNIT_FRAME_PROFILE_AUTOACTIVATEPVE = _G.COMPACT_UNIT_FRAME_PROFILE_AUTOACTIVATEPVE
--local COMPACT_UNIT_FRAME_PROFILE_AUTOACTIVATEPVP = _G.COMPACT_UNIT_FRAME_PROFILE_AUTOACTIVATEPVP
--local C_Social_IsSocialEnabled = _G.C_Social_IsSocialEnabled
--local CreateFrame = _G.CreateFrame
--local ENCOUNTER_JOURNAL = _G.ENCOUNTER_JOURNAL
--local EasyMenu = _G.EasyMenu
--local GARRISON_TYPE_8_0_LANDING_PAGE_TITLE = _G.GARRISON_TYPE_8_0_LANDING_PAGE_TITLE
--local GameMenuFrame = _G.GameMenuFrame
--local HEIRLOOMS = _G.HEIRLOOMS
--local HELP_BUTTON = _G.HELP_BUTTON
--local HideUIPanel = _G.HideUIPanel
--local InCombatLockdown = _G.InCombatLockdown
--local IsAddOnLoaded = _G.IsAddOnLoaded
--local IsInGuild = _G.IsInGuild
--local IsShiftKeyDown = _G.IsShiftKeyDown
--local LFG_TITLE = _G.LFG_TITLE
--local LoadAddOn = _G.LoadAddOn
--local MAINMENU_BUTTON = _G.MAINMENU_BUTTON
--local MOUNTS = _G.MOUNTS
--local MiniMapTrackingDropDown_Initialize = _G.MiniMapTrackingDropDown_Initialize
--local PETS = _G.PETS
--local PlaySound = _G.PlaySound
--local QUESTLOG_BUTTON = _G.QUESTLOG_BUTTON
--local RAID = _G.RAID
--local SOCIAL_BUTTON = _G.SOCIAL_BUTTON
--local SOCIAL_TWITTER_COMPOSE_NEW_TWEET = _G.SOCIAL_TWITTER_COMPOSE_NEW_TWEET
--local SOCIAL_TWITTER_TWEET_NOT_LINKED = _G.SOCIAL_TWITTER_TWEET_NOT_LINKED
--local SPELLBOOK_ABILITIES_BUTTON = _G.SPELLBOOK_ABILITIES_BUTTON
--local ShowUIPanel = _G.ShowUIPanel
--local TALENTS_BUTTON = _G.TALENTS_BUTTON
--local TOY_BOX = _G.TOY_BOX
--local UIDropDownMenu_Initialize = _G.UIDropDownMenu_Initialize
--local UIParent = _G.UIParent
--local WORLD_MAP = _G.WORLD_MAP

---- Create the new minimap tracking dropdown frame and initialize it
--local KkthnxUIMiniMapTrackingDropDown = CreateFrame("Frame", "KkthnxUIMiniMapTrackingDropDown", UIParent, "UIDropDownMenuTemplate")
--KkthnxUIMiniMapTrackingDropDown:SetID(1)
--KkthnxUIMiniMapTrackingDropDown:SetClampedToScreen(true)
--KkthnxUIMiniMapTrackingDropDown:Hide()
--UIDropDownMenu_Initialize(KkthnxUIMiniMapTrackingDropDown, MiniMapTrackingDropDown_Initialize, "MENU")
--KkthnxUIMiniMapTrackingDropDown.noResize = true

---- Create the minimap micro menu
--local menuFrame = CreateFrame("Frame", "MinimapRightClickMenu", UIParent)
--local menuList = {
--	{text = _G.MAINMENU_BUTTON, isTitle = true, notCheckable = true},
--	{text = "", notClickable = true, notCheckable = true},
--	{text = CHARACTER_BUTTON,
--		icon = "Interface\\PaperDollInfoFrame\\UI-EquipmentManager-Toggle",
--		func = function()
--			ToggleCharacter("PaperDollFrame")
--		end,
--	notCheckable = true},

--	{text = SPELLBOOK_ABILITIES_BUTTON,
--		icon = "Interface\\MINIMAP\\TRACKING\\Class",
--		func = function()
--			if not SpellBookFrame:IsShown() then
--				ShowUIPanel(SpellBookFrame)
--			else
--				HideUIPanel(SpellBookFrame)
--			end
--		end,
--	notCheckable = true},

--	{text = TALENTS_BUTTON,
--		func = function()
--			if not PlayerTalentFrame then
--				TalentFrame_LoadUI()
--			end

--			if not PlayerTalentFrame:IsShown() then
--				ShowUIPanel(PlayerTalentFrame)
--			else
--				HideUIPanel(PlayerTalentFrame)
--			end
--		end,
--	notCheckable = true},

--	{text = ACHIEVEMENT_BUTTON,
--		func = function()
--			ToggleAchievementFrame()
--		end,
--	notCheckable = true},

--	{text = WORLD_MAP.." / "..QUESTLOG_BUTTON,
--		func = function()
--			ShowUIPanel(WorldMapFrame)
--		end,
--	notCheckable = true},

--	{text = MOUNTS,
--		icon = "Interface\\MINIMAP\\TRACKING\\StableMaster",
--		func = function()
--			ToggleCollectionsJournal(1)
--		end,
--	notCheckable = true},

--	{text = CHAT_CHANNELS,
--		func = function()
--			ToggleChannelFrame()
--		end,
--	notCheckable = true},

--	{text = PETS,
--		icon = "Interface\\MINIMAP\\TRACKING\\StableMaster",
--		func = function()
--			ToggleCollectionsJournal(2)
--		end,
--	notCheckable = true},

--	{text = TOY_BOX,
--		icon = "Interface\\MINIMAP\\TRACKING\\Reagents",
--		func = function()
--			ToggleCollectionsJournal(3)
--		end,
--	notCheckable = true},

--	{text = HEIRLOOMS,
--		icon = "Interface\\PaperDollInfoFrame\\UI-EquipmentManager-Toggle",
--		func = function()
--			ToggleCollectionsJournal(4)
--		end,
--	notCheckable = true},

--	{text = SOCIAL_BUTTON,
--		func = function()
--			ToggleFriendsFrame(1)
--		end,
--	notCheckable = true},

--	{text = COMPACT_UNIT_FRAME_PROFILE_AUTOACTIVATEPVE.." / "..COMPACT_UNIT_FRAME_PROFILE_AUTOACTIVATEPVP,
--		icon = "Interface\\MINIMAP\\TRACKING\\BattleMaster",
--		func = function()
--			PVEFrame_ToggleFrame()
--		end,
--	notCheckable = true},

--	{text = ACHIEVEMENTS_GUILD_TAB,
--		func = function()
--			if IsInGuild() then
--				if (not GuildFrame) then
--					GuildFrame_LoadUI()
--				end

--				GuildFrame_Toggle()
--			else
--				if (not LookingForGuildFrame) then
--					LookingForGuildFrame_LoadUI()
--				end

--				LookingForGuildFrame_Toggle()
--			end
--		end,
--	notCheckable = true},

--	{text = COMMUNITIES,
--		func = function()
--			ToggleCommunitiesFrame()
--		end,
--	notCheckable = true},

--	{text = LFG_TITLE,
--		func = function()
--			ToggleLFDParentFrame()
--		end,
--	notCheckable = true},

--	{text = RAID,
--		icon = "Interface\\TARGETINGFRAME\\UI-TargetingFrame-Skull",
--		func = function()
--			ToggleFriendsFrame(3)
--		end,
--	notCheckable = true},

--	{text = HELP_BUTTON,
--		icon = "Interface\\CHATFRAME\\UI-ChatIcon-Blizz",
--		func = function()
--			ToggleHelpFrame()
--		end,
--	notCheckable = true},

--	{text = CALENDAR_VIEW_EVENT,
--		func = function()
--			if (not CalendarFrame) then
--				LoadAddOn("Blizzard_Calendar")
--			end

--			Calendar_Toggle()
--		end,
--	notCheckable = true},

--	{text = ENCOUNTER_JOURNAL,
--		icon = "Interface\\MINIMAP\\TRACKING\\Profession",
--		func = function()
--			if not IsAddOnLoaded("Blizzard_EncounterJournal") then
--				EncounterJournal_LoadUI()
--			end

--			ToggleFrame(EncounterJournal)
--		end,
--	notCheckable = true},

--	{text = GARRISON_TYPE_8_0_LANDING_PAGE_TITLE,
--		func = function()
--			GarrisonLandingPageMinimapButton_OnClick()
--		end,
--	notCheckable = true},

--	{text = SOCIAL_TWITTER_COMPOSE_NEW_TWEET,
--		func = function()
--			if not SocialPostFrame then
--				LoadAddOn("Blizzard_SocialUI")
--			end

--			local IsTwitterEnabled = C_Social_IsSocialEnabled()
--			if IsTwitterEnabled then
--				Social_SetShown(true)
--			else
--				K.Print(SOCIAL_TWITTER_TWEET_NOT_LINKED)
--			end
--		end,
--	notCheckable = true},

--	{text = MAINMENU_BUTTON,
--		func = function()
--			if (not GameMenuFrame:IsShown()) then
--				if (VideoOptionsFrame:IsShown()) then
--					VideoOptionsFrameCancel:Click()
--				elseif (AudioOptionsFrame:IsShown() ) then
--					AudioOptionsFrameCancel:Click()
--				elseif (InterfaceOptionsFrame:IsShown()) then
--					InterfaceOptionsFrameCancel:Click()
--				end
--				CloseMenus()
--				CloseAllWindows()
--				PlaySound(850) -- IG_MAINMENU_OPEN
--				ShowUIPanel(GameMenuFrame);
--			else
--				PlaySound(854) -- IG_MAINMENU_QUIT
--				HideUIPanel(GameMenuFrame)
--				MainMenuMicroButton_SetNormal()
--			end
--		end,
--	notCheckable = true},

--	{text = L["Toggle Bags"], notCheckable = true, func = function()
--		if BankFrame:IsShown() then
--			CloseBankBagFrames()
--			CloseBankFrame()
--			CloseAllBags()
--		else
--			if ContainerFrame1:IsShown() then
--				CloseAllBags()
--			else
--				ToggleAllBags()
--			end
--		end
--	end},

--	{text = BLIZZARD_STORE,
--		func = function()
--			StoreMicroButton:Click()
--		end,
--	notCheckable = true},

--	{text = "", notClickable = true, notCheckable = true},

--	{text = CLOSE,
--		func = function()

--		end,
--	notCheckable = true},
--}

--Minimap:SetScript("OnMouseUp", function(self, btn)
--	if C["Minimap"].Enable ~= true then
--		return
--	end

--	HideDropDownMenu(1, nil, KkthnxUIMiniMapTrackingDropDown)
--	menuFrame:Hide()

--	local position = self:GetPoint()
--	if btn == "MiddleButton" or (btn == "RightButton" and IsShiftKeyDown()) then
--		if InCombatLockdown() then
--			_G.UIErrorsFrame:AddMessage(K.InfoColor.._G.ERR_NOT_IN_COMBAT)
--			return
--		end

--		if position:match("LEFT") then
--			EasyMenu(menuList, menuFrame, "cursor")
--		else
--			EasyMenu(menuList, menuFrame, "cursor", -160, 0)
--		end
--	elseif btn == "RightButton" then
--		ToggleDropDownMenu(1, nil, KkthnxUIMiniMapTrackingDropDown, "cursor")
--	else
--		Minimap_OnClick(self)
--	end
--end)