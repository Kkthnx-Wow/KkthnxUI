local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

-- KkthnxUI New GUI Configuration

-- This file contains all the settings configurations for the NewGUI system.
-- Settings are organized into categories and sections with proper hook functions
-- for real-time updates without requiring UI reloads for many settings...

-- Ported from Config/GUI.lua to the new NewGUI system.

-- Module reference
local Module = K:GetModule("NewGUI")
local GUI = Module.GUI

-- Localization references
local enableTextColor = "|cff00cc4c"

-- Function to populate GUI categories and sections
if not GUI or not GUI.AddCategory then
	print("|cffff0000KkthnxUI Error:|r " .. (L["NewGUI not initialized yet!"] or "NewGUI not initialized yet!"))
	return
end

-- Action Bars
local function CreateActionBarsCategory()
	local actionBarCategory = GUI:AddCategory(L["Action Bars"], "Interface\\Icons\\INV_Misc_GroupLooking")

	-- Hooks
	local function UpdateActionbar()
		K:GetModule("ActionBar"):UpdateBarVisibility()
	end

	local function SetABFaderState()
		local ActionBarModule = K:GetModule("ActionBar")
		if not ActionBarModule.fadeParent then
			return
		end
		ActionBarModule.fadeParent:SetAlpha(C["ActionBar"].BarFadeAlpha)
	end

	local function UpdateABFaderState()
		local ActionBarModule = K:GetModule("ActionBar")
		if not ActionBarModule.fadeParent then
			return
		end
		ActionBarModule:UpdateFaderState()
		ActionBarModule.fadeParent:SetAlpha(C["ActionBar"].BarFadeAlpha)
	end

	local function UpdateActionbarHotkeys()
		K:GetModule("ActionBar"):UpdateBarConfig()
	end

	-- Individual bar scale
	local function UpdateActionBarPetScale()
		K:GetModule("ActionBar"):UpdateActionSize("BarPet")
	end

	local function UpdateActionBarStance()
		K:GetModule("ActionBar"):UpdateStanceBar()
	end

	local function UpdateActionBarVehicleButton()
		K:GetModule("ActionBar"):UpdateVehicleButton()
	end

	-- ActionBar 1
	local bar1Section = GUI:AddSection(actionBarCategory, L["ActionBar 1"] or "ActionBar 1")
	GUI:CreateSwitch(bar1Section, "ActionBar.Bar1", enableTextColor .. L["Enable ActionBar"] .. " 1", L["Bar1 Desc"], UpdateActionbar)

	-- ActionBar 2
	local bar2Section = GUI:AddSection(actionBarCategory, L["ActionBar 2"] or "ActionBar 2")
	GUI:CreateSwitch(bar2Section, "ActionBar.Bar2", enableTextColor .. L["Enable ActionBar"] .. " 2", L["Bar2 Desc"], UpdateActionbar)

	-- ActionBar 3
	local bar3Section = GUI:AddSection(actionBarCategory, L["ActionBar 3"] or "ActionBar 3")
	GUI:CreateSwitch(bar3Section, "ActionBar.Bar3", enableTextColor .. L["Enable ActionBar"] .. " 3", L["Bar3 Desc"], UpdateActionbar)

	-- ActionBar 4
	local bar4Section = GUI:AddSection(actionBarCategory, L["ActionBar 4"] or "ActionBar 4")
	GUI:CreateSwitch(bar4Section, "ActionBar.Bar4", enableTextColor .. L["Enable ActionBar"] .. " 4", L["Bar4 Desc"], UpdateActionbar)

	-- ActionBar 5
	local bar5Section = GUI:AddSection(actionBarCategory, L["ActionBar 5"] or "ActionBar 5")
	GUI:CreateSwitch(bar5Section, "ActionBar.Bar5", enableTextColor .. L["Enable ActionBar"] .. " 5", L["Bar5 Desc"], UpdateActionbar)

	-- ActionBar 6
	local bar6Section = GUI:AddSection(actionBarCategory, L["ActionBar 6"] or "ActionBar 6")
	GUI:CreateSwitch(bar6Section, "ActionBar.Bar6", enableTextColor .. L["Enable ActionBar"] .. " 6", L["Bar6 Desc"], UpdateActionbar)

	-- ActionBar 7
	local bar7Section = GUI:AddSection(actionBarCategory, L["ActionBar 7"] or "ActionBar 7")
	GUI:CreateSwitch(bar7Section, "ActionBar.Bar7", enableTextColor .. L["Enable ActionBar"] .. " 7", L["Bar7 Desc"], UpdateActionbar)

	-- ActionBar 8
	local bar8Section = GUI:AddSection(actionBarCategory, L["ActionBar 8"] or "ActionBar 8")
	GUI:CreateSwitch(bar8Section, "ActionBar.Bar8", enableTextColor .. L["Enable ActionBar"] .. " 8", L["Bar8 Desc"], UpdateActionbar)

	-- Pet Bar
	local petBarSection = GUI:AddSection(actionBarCategory, L["ActionBar Pet"])
	GUI:CreateSlider(petBarSection, "ActionBar.BarPetSize", L["Button Size"], 20, 80, 1, L["BarPetSize Desc"], UpdateActionBarPetScale)
	GUI:CreateSlider(petBarSection, "ActionBar.BarPetPerRow", L["Button PerRow"], 1, 12, 1, L["BarPetPerRow Desc"], UpdateActionBarPetScale)
	GUI:CreateSlider(petBarSection, "ActionBar.BarPetFont", L["Button FontSize"], 8, 20, 1, L["BarPetFont Desc"], UpdateActionBarPetScale)
	GUI:CreateSwitch(petBarSection, "ActionBar.BarPetFade", L["Enable Fade for Pet Bar"], L["Allows the Pet Bar to fade based on the specified conditions"], UpdateABFaderState)

	-- Stance Bar
	local stanceBarSection = GUI:AddSection(actionBarCategory, L["ActionBar Stance"])
	GUI:CreateSwitch(stanceBarSection, "ActionBar.ShowStance", enableTextColor .. L["Enable StanceBar"], L["ShowStance Desc"])
	GUI:CreateSlider(stanceBarSection, "ActionBar.BarStanceSize", L["Button Size"], 20, 80, 1, L["BarStanceSize Desc"], UpdateActionBarStance)
	GUI:CreateSlider(stanceBarSection, "ActionBar.BarStancePerRow", L["Button PerRow"], 1, 12, 1, L["BarStancePerRow Desc"], UpdateActionBarStance)
	GUI:CreateSlider(stanceBarSection, "ActionBar.BarStanceFont", L["Button FontSize"], 8, 20, 1, L["BarStanceFont Desc"], UpdateActionBarStance)
	GUI:CreateSwitch(stanceBarSection, "ActionBar.BarStanceFade", L["Enable Fade for Stance Bar"], L["Allows the Stance Bar to fade based on the specified conditions"], UpdateABFaderState)

	-- Vehicle Button
	local vehicleSection = GUI:AddSection(actionBarCategory, L["ActionBar Vehicle"])
	GUI:CreateSlider(vehicleSection, "ActionBar.VehButtonSize", L["Button Size"], 20, 80, 1, L["VehButtonSize Desc"], UpdateActionBarVehicleButton)

	-- Toggles
	local togglesSection = GUI:AddSection(actionBarCategory, L["Toggles"])
	GUI:CreateSwitch(togglesSection, "ActionBar.EquipColor", L["Equip Color"], L["EquipColor Desc"], UpdateActionbarHotkeys)
	GUI:CreateSwitch(togglesSection, "ActionBar.Grid", L["Actionbar Grid"], L["Grid Desc"], UpdateActionbarHotkeys)
	GUI:CreateSwitch(togglesSection, "ActionBar.Hotkeys", L["Enable Hotkey"], L["Hotkeys Desc"], UpdateActionbarHotkeys)
	GUI:CreateSwitch(togglesSection, "ActionBar.Macro", L["Enable Macro"], L["Macro Desc"], UpdateActionbarHotkeys)
	GUI:CreateSwitch(togglesSection, "ActionBar.KeyDown", L["Cast on Key Press"], L["Cast spells and abilities on key press, not key release"], UpdateActionbarHotkeys)
	GUI:CreateSwitch(togglesSection, "ActionBar.ButtonLock", L["Lock Action Bars"], L["Keep your action bar layout locked in place to prevent accidental reordering. To move a spell or ability while locked, hold the Shift key."], UpdateActionbarHotkeys)
	GUI:CreateSwitch(togglesSection, "ActionBar.Cooldown", L["Show Cooldowns"], L["Cooldown Desc"])
	GUI:CreateSwitch(togglesSection, "ActionBar.MicroMenu", L["Enable MicroBar"], L["MicroMenu Desc"])
	GUI:CreateSwitch(togglesSection, "ActionBar.FadeMicroMenu", L["Mouseover MicroBar"], L["FadeMicroMenu Desc"])
	GUI:CreateSwitch(togglesSection, "ActionBar.OverrideWA", L["Enable OverrideWA"], L["OverrideWA Desc"])
	GUI:CreateSlider(togglesSection, "ActionBar.MmssTH", L["MMSSThreshold"], 60, 600, 1, L["MMSSThresholdTip"])
	GUI:CreateSlider(togglesSection, "ActionBar.TenthTH", L["TenthThreshold"], 0, 60, 1, L["TenthThresholdTip"])

	-- Fader Options
	local faderSection = GUI:AddSection(actionBarCategory, L["Fader Options"])
	GUI:CreateSwitch(faderSection, "ActionBar.BarFadeGlobal", L["Enable Global Fade"], L["BarFadeGlobal Desc"])
	GUI:CreateSlider(faderSection, "ActionBar.BarFadeAlpha", L["Fade Alpha"], 0, 1, 0.1, L["BarFadeAlpha Desc"], SetABFaderState)
	GUI:CreateSlider(faderSection, "ActionBar.BarFadeDelay", L["Fade Delay"], 0, 3, 0.1, L["BarFadeDelay Desc"])
	GUI:CreateSwitch(faderSection, "ActionBar.BarFadeCombat", L["Fade Out of Combat"], L["BarFadeCombat Desc"])
	GUI:CreateSwitch(faderSection, "ActionBar.BarFadeTarget", L["Fade without Target"], L["BarFadeTarget Desc"])
	GUI:CreateSwitch(faderSection, "ActionBar.BarFadeCasting", L["Fade While Casting"], L["BarFadeCasting Desc"])
	GUI:CreateSwitch(faderSection, "ActionBar.BarFadeHealth", L["Fade on Full Health"], L["BarFadeHealth Desc"])
	GUI:CreateSwitch(faderSection, "ActionBar.BarFadeVehicle", L["Fade in Vehicle"], L["BarFadeVehicle Desc"])
end

-- Announcements
local function CreateAnnouncementsCategory()
	local announcementsCategory = GUI:AddCategory(L["Announcements"], "Interface\\Icons\\Ability_Warrior_BattleShout")

	-- General
	local generalAnnouncementsSection = GUI:AddSection(announcementsCategory, GENERAL)
	GUI:CreateSwitch(generalAnnouncementsSection, "Announcements.ItemAlert", L["Announce Spells And Items"], "Alerts the group when specific spells or items are used.")
	GUI:CreateSwitch(generalAnnouncementsSection, "Announcements.PullCountdown", L["Announce Pull Countdown (/pc #)"], "Announces the pull countdown timer to your group or raid.")
	GUI:CreateSwitch(generalAnnouncementsSection, "Announcements.ResetInstance", L["Alert Group After Instance Resetting"], "Notifies the group when the instance is reset.")

	-- Combat
	local combatAnnouncementsSection = GUI:AddSection(announcementsCategory, L["Combat"])
	GUI:CreateSwitch(combatAnnouncementsSection, "Announcements.SaySapped", L["Announce When Sapped"], "Automatically announces in chat when you are sapped in PvP.")
	GUI:CreateSwitch(combatAnnouncementsSection, "Announcements.KillingBlow", L["Show Your Killing Blow Info"], "Displays a notification when you land a killing blow.")
	GUI:CreateSwitch(combatAnnouncementsSection, "Announcements.PvPEmote", L["Auto Emote On Your Killing Blow"], "Automatically performs an emote when you land a killing blow in PvP.")
	GUI:CreateSwitch(combatAnnouncementsSection, "Announcements.HealthAlert", L["Announce When Low On Health"], "Alerts when your health drops below a critical threshold.")
	GUI:CreateSwitch(combatAnnouncementsSection, "Announcements.KeystoneAlert", L["Announce When New Mythic Key Is Obtained"], L["Notifies you and your group when you receive a new Mythic+ keystone."])

	-- Interrupt
	local interruptSection = GUI:AddSection(announcementsCategory, L["Interrupt"] or INTERRUPT)
	GUI:CreateSwitch(interruptSection, "Announcements.InterruptAlert", enableTextColor .. L["Announce Interrupts"], "Announces when you successfully interrupt a spell.")
	GUI:CreateSwitch(interruptSection, "Announcements.DispellAlert", enableTextColor .. L["Announce Dispels"], "Announces when you successfully dispel an effect.")
	GUI:CreateSwitch(interruptSection, "Announcements.BrokenAlert", enableTextColor .. L["Announce Broken Spells"], "Alerts the group when a spell is broken (e.g., crowd control spells).")
	GUI:CreateSwitch(interruptSection, "Announcements.OwnInterrupt", L["Only Announce Own Interrupts"], "Limits interrupt announcements to only those you perform.")
	GUI:CreateSwitch(interruptSection, "Announcements.OwnDispell", L["Only Announce Own Dispels"], "Limits dispel announcements to only those you perform.")
	GUI:CreateSwitch(interruptSection, "Announcements.InstAlertOnly", L["Announce Only In Instances"], "Restricts announcements to dungeons, raids, and other instances.")

	-- Alert Channel
	local alertChannelOptions = {
		{ text = PARTY, value = 1 },
		{ text = PARTY .. " / " .. RAID, value = 2 },
		{ text = RAID, value = 3 },
		{ text = SAY, value = 4 },
		{ text = YELL, value = 5 },
		{ text = EMOTE, value = 6 },
	}
	GUI:CreateDropdown(interruptSection, "Announcements.AlertChannel", L["Announce Interrupts To Specified Chat Channel"], alertChannelOptions, L["AlertChannel Desc"] or "Select the chat channel where interrupt and dispel alerts will be sent.")

	-- Quest Notifier
	local questNotifierSection = GUI:AddSection(announcementsCategory, L["QuestNotifier"])
	GUI:CreateSwitch(questNotifierSection, "Announcements.QuestNotifier", enableTextColor .. L["Enable QuestNotifier"], L["QuestNotifier Desc"] or "Enables notifications related to quest progress and completion.")
	GUI:CreateSwitch(questNotifierSection, "Announcements.OnlyCompleteRing", L["Only Play Complete Quest Sound"], "Plays a sound only when a quest is fully completed.")
	GUI:CreateSwitch(questNotifierSection, "Announcements.QuestProgress", L["Alert QuestProgress In Chat"], "Sends quest progress updates to chat.")
	GUI:CreateSwitch(questNotifierSection, "Announcements.AnnounceWorldQuests", L["Announce World Quests"], L["AnnounceWorldQuests Desc"], nil, true)
	GUI:CreateSlider(questNotifierSection, "Announcements.QuestProgressEveryNth", L["Quest Progress: Announce Every N Updates"], 1, 5, 1, L["QuestProgressEveryNth Desc"], nil, true)

	-- Rare Alert
	local rareAlertSection = GUI:AddSection(announcementsCategory, L["Rare Alert"])
	GUI:CreateSwitch(rareAlertSection, "Announcements.RareAlert", enableTextColor .. L["Enable Event & Rare Alerts"], "Enables alerts for nearby rare creatures and events.")
	GUI:CreateSwitch(rareAlertSection, "Announcements.AlertInWild", L["Don't Alert In Instances"], "Prevents rare alerts from triggering inside instances.")
	GUI:CreateSwitch(rareAlertSection, "Announcements.AlertInChat", L["Print Alerts In Chat"], "Prints alerts for rare events and creatures in the chat window.")
end

-- Arena
local function CreateArenaCategory()
	local arenaCategory = GUI:AddCategory(L["Arena"] or "Arena", "Interface\\Icons\\Achievement_Arena_2v2_7")

	-- General
	local generalArenaSection = GUI:AddSection(arenaCategory, GENERAL)
	GUI:CreateSwitch(generalArenaSection, "Arena.Enable", enableTextColor .. L["Enable Arena"], "Toggle Arena Module On/Off")
	GUI:CreateSwitch(generalArenaSection, "Arena.Castbars", L["Show Castbars"], "Enable castbars for arena opponent frames")
	GUI:CreateSwitch(generalArenaSection, "Arena.CastbarIcon", L["Show Castbars Icon"], L["Arena CastbarIcon Desc"])
	GUI:CreateSwitch(generalArenaSection, "Arena.Smooth", L["Smooth Bar Transition"], "Enable smooth health and power bar animations")

	-- Sizes
	local arenaSizesSection = GUI:AddSection(arenaCategory, L["Sizes"])
	GUI:CreateSlider(arenaSizesSection, "Arena.HealthHeight", L["Health Height"], 20, 50, 1, L["Arena.HealthHeight Desc"])
	GUI:CreateSlider(arenaSizesSection, "Arena.HealthWidth", L["Health Width"], 120, 180, 1, L["Arena.HealthWidth Desc"])
	GUI:CreateSlider(arenaSizesSection, "Arena.PowerHeight", L["Power Height"], 10, 30, 1, L["Arena.PowerHeight Desc"])
	GUI:CreateSlider(arenaSizesSection, "Arena.YOffset", L["Vertical Offset Between Frames"] .. K.GreyColor .. "(54)|r", 40, 60, 1, L["Arena.VerticalOffset Desc"])

	-- Colors
	local arenaColorsSection = GUI:AddSection(arenaCategory, COLORS)

	-- Health Color Format
	local healthColorOptions = {
		{ text = "Class", value = 1 },
		{ text = "Dark", value = 2 },
		{ text = "Value", value = 3 },
	}
	GUI:CreateDropdown(arenaColorsSection, "Arena.HealthbarColor", L["Health Color Format"], healthColorOptions, "Choose how arena opponent health bars are colored")
end

-- AuraWatch
local function CreateAuraWatchCategory()
	local auraWatchCategory = GUI:AddCategory(L["AuraWatch"] or "AuraWatch", "Interface\\Icons\\Spell_Shadow_BrainWash")

	local function OpenAuraWatchGUI()
		-- Open the AuraWatch configuration GUI
		K.NewGUI:Toggle()
		SlashCmdList["KKUI_AWCONFIG"]() -- To Be Implemented
	end

	-- General
	local generalAuraWatchSection = GUI:AddSection(auraWatchCategory, GENERAL)
	GUI:CreateSwitch(generalAuraWatchSection, "AuraWatch.Enable", enableTextColor .. L["Enable AuraWatch"], L["Enable Desc"])
	GUI:CreateSwitch(generalAuraWatchSection, "AuraWatch.ClickThrough", L["Disable AuraWatch Tooltip (ClickThrough)"], "If enabled, the icon would be uninteractable, you can't select or mouseover them.")
	GUI:CreateSwitch(generalAuraWatchSection, "AuraWatch.DeprecatedAuras", L["Track Auras From Previous Expansions"], "Enable tracking of auras from previous expansions that may still be relevant.")
	GUI:CreateSlider(generalAuraWatchSection, "AuraWatch.IconScale", L["AuraWatch IconScale"], 0.8, 2, 0.1, L["IconScale Desc"])

	-- Advanced
	local advancedAuraWatchSection = GUI:AddSection(auraWatchCategory, L["Advanced Configuration"] or "Advanced Configuration")

	-- Create the AuraWatch GUI button widget using the proper GUI system
	GUI:CreateButtonWidget(advancedAuraWatchSection, "AuraWatch.OpenGUI", L["AuraWatch GUI"], (L["Open GUI"] or "Open GUI"), (L["Open AuraWatch GUI Tooltip"] or "Opens the advanced AuraWatch configuration interface where you can add, remove, and customize tracked auras, cooldowns, and buffs/debuffs."), function()
		OpenAuraWatchGUI()
	end)
end

-- Auras
local function CreateAurasCategory()
	local aurasCategory = GUI:AddCategory(L["Auras"] or "Auras", "Interface\\Icons\\Spell_Magic_LesserInvisibilty")

	-- General
	local generalAurasSection = GUI:AddSection(aurasCategory, GENERAL)
	GUI:CreateSwitch(generalAurasSection, "Auras.Enable", enableTextColor .. L["Enable Auras"], L["Enable Desc"])
	GUI:CreateSwitch(generalAurasSection, "Auras.HideBlizBuff", L["Hide The Default BuffFrame"], L["HideBlizBuff Desc"])
	GUI:CreateSwitch(generalAurasSection, "Auras.Reminder", L["Auras Reminder (Shout/Intellect/Poison)"], L["Reminder Desc"])
	GUI:CreateSwitch(generalAurasSection, "Auras.ReverseBuffs", L["Buffs Grow Right"], L["ReverseBuffs Desc"])
	GUI:CreateSwitch(generalAurasSection, "Auras.ReverseDebuffs", L["Debuffs Grow Right"], "Controls the direction debuff icons grow from their anchor point.")

	-- Sizes
	local aurasSizesSection = GUI:AddSection(aurasCategory, L["Sizes"])
	GUI:CreateSlider(aurasSizesSection, "Auras.BuffSize", L["Buff Icon Size"], 20, 40, 1, L["AuraSize Desc"])
	GUI:CreateSlider(aurasSizesSection, "Auras.BuffsPerRow", L["Buffs per Row"], 10, 20, 1, L["BuffsPerRow Desc"])
	GUI:CreateSlider(aurasSizesSection, "Auras.DebuffSize", L["DeBuff Icon Size"], 20, 40, 1, L["AuraSize Desc"])
	GUI:CreateSlider(aurasSizesSection, "Auras.DebuffsPerRow", L["DeBuffs per Row"], 10, 16, 1, L["DebuffsPerRow Desc"])

	-- Totems
	local totemsSection = GUI:AddSection(aurasCategory, TUTORIAL_TITLE47 or "Totems")
	GUI:CreateSwitch(totemsSection, "Auras.Totems", enableTextColor .. L["Enable TotemBar"], L["Totems Desc"])
	GUI:CreateSwitch(totemsSection, "Auras.VerticalTotems", L["Vertical TotemBar"], L["VerticalTotems Desc"])
	GUI:CreateSlider(totemsSection, "Auras.TotemSize", L["Totems IconSize"], 24, 60, 1, L["TotemSize Desc"])
end

-- Automation
local function CreateAutomationCategory()
	local automationIcon = "Interface\\Icons\\Ability_Warrior_OffensiveStance"
	local category = GUI:AddCategory(L["Automation"] or "Automation", automationIcon)

	-- Invite
	local inviteSection = GUI:AddSection(category, L["Invite Management"] or "Invite Management")

	local function updateInviteKeyword()
		local automationModule = K:GetModule("Automation")
		if automationModule and automationModule.onUpdateInviteKeyword then
			automationModule:onUpdateInviteKeyword()
		end
	end

	GUI:CreateSwitch(inviteSection, "Automation.AutoInvite", L["Accept Invites From Friends & Guild Members"], L["AutoInvite Desc"])
	GUI:CreateSwitch(inviteSection, "Automation.AutoDeclineDuels", L["Decline PvP Duels"], L["AutoDeclineDuels Desc"])
	GUI:CreateSwitch(inviteSection, "Automation.AutoDeclinePetDuels", L["Decline Pet Duels"], L["AutoDeclinePetDuels Desc"])
	GUI:CreateSwitch(inviteSection, "Automation.AutoPartySync", L["Accept PartySync From Friends & Guild Members"], L["AutoPartySync Desc"])
	GUI:CreateTextInput(inviteSection, "Automation.WhisperInvite", L["Auto Accept Invite Keyword"], L["WhisperInvite Placeholder"], L["WhisperInvite Desc"], updateInviteKeyword)

	-- Auto-Resurrect
	local resurrectSection = GUI:AddSection(category, L["Auto-Resurrect Options"] or "Auto-Resurrect Options")
	GUI:CreateSwitch(resurrectSection, "Automation.AutoResurrect", L["Auto Accept Resurrect Requests"], L["AutoResurrect Desc"])
	GUI:CreateSwitch(resurrectSection, "Automation.AutoResurrectThank", L["Say 'Thank You' When Resurrected"], L["AutoResurrectThank Desc"])

	-- Auto-Reward
	local rewardSection = GUI:AddSection(category, L["Auto-Reward Options"] or "Auto-Reward Options")
	GUI:CreateSwitch(rewardSection, "Automation.AutoReward", L["Auto Select Quest Rewards Best Value"], L["AutoReward Desc"])
	GUI:CreateSwitch(rewardSection, "Automation.AutoShareQuest", L["Auto Share Accepted Quests"], L["AutoShareQuest Desc"])

	-- Miscellaneous
	local miscSection = GUI:AddSection(category, L["Miscellaneous Options"] or "Miscellaneous Options")
	GUI:CreateSwitch(miscSection, "Automation.AutoGoodbye", L["Say Goodbye After Dungeon Completion"], L["AutoGoodbye Desc"])
	GUI:CreateSwitch(miscSection, "Automation.AutoKeystone", L["Auto Place Mythic Keystones"], L["AutoKeystone Desc"])
	GUI:CreateSwitch(miscSection, "Automation.AutoRelease", L["Auto Release in Battlegrounds & Arenas"], L["AutoRelease Desc"])
	GUI:CreateSwitch(miscSection, "Automation.AutoScreenshot", L["Auto Screenshot Achievements"], L["AutoScreenshot Desc"])
	GUI:CreateSwitch(miscSection, "Automation.AutoSetRole", L["Auto Set Your Role In Groups"], L["AutoSetRole Desc"])
	GUI:CreateSwitch(miscSection, "Automation.ConfirmCinematicSkip", L["Quick Skip Cinematics (Key Press)"], L["ConfirmCinematicSkip Desc"])
	GUI:CreateSwitch(miscSection, "Automation.AutoSummon", L["Auto Accept Summon Requests"], L["AutoSummon Desc"])
	GUI:CreateSwitch(miscSection, "Automation.NoBadBuffs", L["Automatically Remove Annoying Buffs"], L["NoBadBuffs Desc"])

	-- Auto-Quest
	local listsSection = GUI:AddSection(category, L["Auto-Quest Lists"] or "Auto-Quest Lists")
	GUI:CreateButtonWidget(listsSection, "Automation.ManageAutoQuestIgnore", L["Auto-Quest Ignore NPCs"], L["Open"], "Open the manager to add or remove NPC IDs that should be ignored by auto questing (per character).", function()
		if K.ExtraGUI and K.ExtraGUI.ShowExtraConfig then
			K.ExtraGUI:ShowExtraConfig("Automation.AutoQuestIgnoreNPC", L["Auto-Quest Ignore NPCs"])
		end
	end)
end

-- Boss
local function CreateBossCategory()
	local bossIcon = "Interface\\Icons\\Achievement_boss_illidan"
	local bossCategory = GUI:AddCategory(L["Boss"] or "Boss", bossIcon)

	-- General
	local generalBossSection = GUI:AddSection(bossCategory, GENERAL)
	GUI:CreateSwitch(generalBossSection, "Boss.Enable", enableTextColor .. L["Enable Boss"], "Toggle Boss Module On/Off")
	GUI:CreateSwitch(generalBossSection, "Boss.Castbars", L["Show Castbars"], "Enable castbars for boss frames")
	GUI:CreateSwitch(generalBossSection, "Boss.CastbarIcon", L["Show Castbars Icon"], L["Boss CastbarIcon Desc"])
	GUI:CreateSwitch(generalBossSection, "Boss.Smooth", L["Smooth Bar Transition"], "Enable smooth health and power bar animations")

	-- Sizes
	local bossSizesSection = GUI:AddSection(bossCategory, L["Sizes"])
	GUI:CreateSlider(bossSizesSection, "Boss.HealthHeight", L["Health Height"], 20, 50, 1, L["Boss.HealthHeight Desc"])
	GUI:CreateSlider(bossSizesSection, "Boss.HealthWidth", L["Health Width"], 120, 180, 1, L["Boss.HealthWidth Desc"])
	GUI:CreateSlider(bossSizesSection, "Boss.PowerHeight", L["Power Height"], 10, 30, 1, L["Boss.PowerHeight Desc"])
	GUI:CreateSlider(bossSizesSection, "Boss.YOffset", L["Vertical Offset Between Frames"] .. K.GreyColor .. "(54)|r", 40, 60, 1, L["Boss.VerticalOffset Desc"])

	-- Colors
	local bossColorsSection = GUI:AddSection(bossCategory, COLORS)

	-- Health Color Format
	local healthColorOptions = {
		{ text = "Class", value = 1 },
		{ text = "Dark", value = 2 },
		{ text = "Value", value = 3 },
	}
	GUI:CreateDropdown(bossColorsSection, "Boss.HealthbarColor", L["Health Color Format"], healthColorOptions, "Choose how boss frame health bars are colored")
end

-- Chat
local function CreateChatCategory()
	local chatIcon = "Interface\\Icons\\Ui_chat"
	local chatCategory = GUI:AddCategory(L["Chat"] or "Chat", chatIcon)

	-- Hooks
	local function UpdateChatBackground()
		local chatModule = K:GetModule("Chat")
		if chatModule and chatModule.ToggleChatBackground then
			chatModule:ToggleChatBackground()
			-- Chat background updated silently
		end
	end

	-- Generic chat settings
	local function UpdateChatSettings()
		local chatModule = K:GetModule("Chat")
		if chatModule then
			return
		end
	end

	local function UpdateChatSize()
		local chatModule = K:GetModule("Chat")
		if chatModule and chatModule.UpdateChatSize then
			chatModule:UpdateChatSize()
		end
	end

	local function UpdateChatHistory()
		local chatModule = K:GetModule("Chat")
		if chatModule and chatModule.UpdateChatHistory then
			chatModule:onLogMaxChanged()
		end
	end

	local function UpdateChatButtons()
		local chatModule = K:GetModule("Chat")
		if chatModule and chatModule.UpdateChatButtons then
			chatModule:UpdateChatButtons()
		end
	end

	-- General
	local generalChatSection = GUI:AddSection(chatCategory, GENERAL)
	GUI:CreateSwitch(generalChatSection, "Chat.Enable", enableTextColor .. L["Enable Chat"], L["Enable Desc"])
	GUI:CreateSwitch(generalChatSection, "Chat.Lock", L["Lock Chat"], L["Lock Desc"])
	GUI:CreateSwitch(generalChatSection, "Chat.Background", L["Show Chat Background"], L["Background Desc"], UpdateChatBackground)
	GUI:CreateSwitch(generalChatSection, "Chat.OldChatNames", L["Use Default Channel Names"], L["OldChatNames Desc"])

	-- Appearance
	local appearanceChatSection = GUI:AddSection(chatCategory, L["Appearance"])
	GUI:CreateSwitch(appearanceChatSection, "Chat.Emojis", L["Show Emojis In Chat"] .. " |TInterface\\Addons\\KkthnxUI\\Media\\Chat\\Emojis\\StuckOutTongueClosedEyes:0:0:4|t", L["Emojis Desc"])
	GUI:CreateSwitch(appearanceChatSection, "Chat.ChatItemLevel", L["Show ItemLevel on ChatFrames"], L["ChatItemLevel Desc"])
	GUI:CreateSwitch(appearanceChatSection, "Chat.CopyButton", "Show Copy Chat Button |TInterface\\Buttons\\UI-GuildButton-PublicNote-Up:14:14|t", "Enable or disable the Copy Chat button, which allows you to copy chat text.", UpdateChatButtons, true)
	GUI:CreateSwitch(appearanceChatSection, "Chat.ConfigButton", "Show Config Button |TInterface\\Buttons\\UI-OptionsButton:14:14|t", "Enable or disable the Config button, which provides quick access to the configuration menu.", UpdateChatButtons, true)
	GUI:CreateSwitch(appearanceChatSection, "Chat.RollButton", "Show Roll Button |A:charactercreate-icon-dice:14:14|a", "Enable or disable the Roll button, which allows you to roll a random number between 1 and 100.", UpdateChatButtons, true)

	-- Timestamp Format
	local timestampOptions = {
		{ text = "Disable", value = 1 },
		{ text = "03:27 PM", value = 2 },
		{ text = "03:27:32 PM", value = 3 },
		{ text = "15:27", value = 4 },
		{ text = "15:27:32", value = 5 },
	}
	GUI:CreateDropdown(appearanceChatSection, "Chat.TimestampFormat", L["Custom Chat Timestamps"], timestampOptions, L["TimestampFormat Desc"], UpdateChatSettings)

	-- Behavior
	local behaviorChatSection = GUI:AddSection(chatCategory, L["Behavior"])
	GUI:CreateSwitch(behaviorChatSection, "Chat.Freedom", L["Disable Chat Language Filter"], L["Freedom Desc"])
	GUI:CreateSwitch(behaviorChatSection, "Chat.ChatMenu", L["Show Chat Menu Buttons"], L["ChatMenu Desc"])
	GUI:CreateSwitch(behaviorChatSection, "Chat.Sticky", L["Stick On Channel If Whispering"], L["Sticky Desc"])
	GUI:CreateSwitch(behaviorChatSection, "Chat.WhisperColor", L["Differ Whisper Colors"], "Use different colors for incoming and outgoing whispers")

	-- Sizes
	local sizesChatSection = GUI:AddSection(chatCategory, L["Sizes"])
	GUI:CreateSlider(sizesChatSection, "Chat.Height", L["Lock Chat Height"], 100, 500, 1, L["Height Desc"], UpdateChatSize)
	GUI:CreateSlider(sizesChatSection, "Chat.Width", L["Lock Chat Width"], 200, 600, 1, L["Width Desc"], UpdateChatSize)

	local historyChatSection = GUI:AddSection(chatCategory, HISTORY)
	local logMaxWidget = GUI:CreateSlider(historyChatSection, "Chat.LogMax", L["Chat History Lines To Save"], 0, 250, 10, L["LogMax Desc"], UpdateChatHistory)
	-- Inline Reset Saved Chat History button, anchored near the slider track
	if logMaxWidget and logMaxWidget.Slider then
		local resetHistoryButton = GUI:CreateButton(logMaxWidget, (L and L["Reset Chat History"]) or "Reset Chat History", 130, 18, function()
			StaticPopupDialogs["KKUI_CLEAR_CHAT_HISTORY"] = {
				text = (L and L["Clear all chat history now?"]) or "Clear all chat history now?",
				button1 = YES,
				button2 = NO,
				OnAccept = function()
					local chatModule = K:GetModule("Chat")
					if chatModule and chatModule.ClearChatHistory then
						chatModule:ClearChatHistory()
					end
				end,
				timeout = 0,
				whileDead = true,
				hideOnEscape = true,
				preferredIndex = 3,
			}
			StaticPopup_Show("KKUI_CLEAR_CHAT_HISTORY")
		end)
		resetHistoryButton:ClearAllPoints()
		resetHistoryButton:SetPoint("RIGHT", logMaxWidget.Slider, "LEFT", -12, 0)
		resetHistoryButton:Show()
	end

	-- Fading
	local fadingChatSection = GUI:AddSection(chatCategory, L["Fading"])
	GUI:CreateSwitch(fadingChatSection, "Chat.Fading", L["Fade Chat Text"], "Enable automatic fading of chat messages after a set time")
	GUI:CreateSlider(fadingChatSection, "Chat.FadingTimeVisible", L["Fading Chat Visible Time"], 5, 120, 1, L["FadingTimeVisible Desc"])
end

-- DataText
local function CreateDataTextCategory()
	local dataTextIcon = "Interface\\Icons\\Achievement_worldevent_childrensweek"
	local dataTextCategory = GUI:AddCategory(L["DataText"] or "DataText", dataTextIcon)

	-- General
	local generalDataTextSection = GUI:AddSection(dataTextCategory, GENERAL)
	GUI:CreateSwitch(generalDataTextSection, "DataText.Coords", L["Enable Positon Coords"], L["Coords Desc"])
	GUI:CreateSwitch(generalDataTextSection, "DataText.Friends", L["Enable Friends Info"], L["Friends Desc"])
	GUI:CreateSwitch(generalDataTextSection, "DataText.Gold", L["Enable Currency Info"], L["Gold Desc"])
	GUI:CreateSwitch(generalDataTextSection, "DataText.Guild", L["Enable Guild Info"], L["Guild Desc"])
	GUI:CreateSwitch(generalDataTextSection, "DataText.Latency", L["Enable Latency Info"], L["Latency Desc"])
	GUI:CreateSwitch(generalDataTextSection, "DataText.Location", L["Enable Minimap Location"], L["Location Desc"])
	GUI:CreateSwitch(generalDataTextSection, "DataText.Spec", L["Enable Specialization Info"], L["Spec Desc"])
	GUI:CreateSwitch(generalDataTextSection, "DataText.System", L["Enable System Info"], L["System Desc"])
	GUI:CreateSwitch(generalDataTextSection, "DataText.Time", L["Enable Minimap Time"], L["Time Desc"])

	-- Icon Colors
	local iconColorsSection = GUI:AddSection(dataTextCategory, L["Icon Colors"])
	GUI:CreateColorPicker(iconColorsSection, "DataText.IconColor", L["Color The Icons"], L["IconColor Desc"])

	-- Text Toggles
	local textTogglesSection = GUI:AddSection(dataTextCategory, L["Text Toggles"])
	GUI:CreateSwitch(textTogglesSection, "DataText.HideText", L["Hide Icon Text"], L["HideText Desc"])
end

-- General
local function CreateGeneralCategory()
	local generalIcon = "Interface\\Icons\\INV_Misc_Gear_01"
	local generalCategory = GUI:AddCategory(L["General"], generalIcon)

	local function UpdateUIScale(newValue, oldValue, configPath)
		if K.SetupUIScale then
			K:SetupUIScale()
		end
	end

	-- General
	local generalGeneralSection = GUI:AddSection(generalCategory, GENERAL)
	GUI:CreateSwitch(generalGeneralSection, "General.MinimapIcon", L["Enable Minimap Icon"], L["MinimapIcon Desc"])
	GUI:CreateSwitch(generalGeneralSection, "General.MoveBlizzardFrames", L["Move Blizzard Frames"], L["MoveBlizzardFrames Desc"])
	GUI:CreateSwitch(generalGeneralSection, "General.NoErrorFrame", L["Disable Blizzard Error Frame Combat"], "Prevents error messages from appearing during combat")
	GUI:CreateSwitch(generalGeneralSection, "General.NoTutorialButtons", L["Disable 'Some' Blizzard Tutorials"], L["NoTutorialButtons Desc"])

	-- Button Glow Mode
	local glowModeOptions = {
		{ text = "Pixel", value = 1 },
		{ text = "Autocast", value = 2 },
		{ text = "Action Button", value = 3 },
		{ text = "Proc Glow", value = 4 },
	}
	GUI:CreateDropdown(generalGeneralSection, "General.GlowMode", L["Button Glow Mode"], glowModeOptions, L["GlowMode Desc"])

	-- Border Style
	local borderStyleOptions = {}
	if K.GetAllBorderStyles then
		borderStyleOptions = K.GetAllBorderStyles()
	else
		-- Fallback options if function not available
		borderStyleOptions = {
			{ text = "KkthnxUI", value = "KkthnxUI", description = "Default KkthnxUI border style" },
			{ text = "AzeriteUI", value = "AzeriteUI", description = "Clean Azerite-inspired border" },
			{ text = "KkthnxUI Pixel", value = "KkthnxUI_Pixel", description = "Sharp pixel-perfect border" },
			{ text = "KkthnxUI Blank", value = "KkthnxUI_Blank", description = "Minimal blank border style" },
		}
	end
	GUI:CreateDropdown(generalGeneralSection, "General.BorderStyle", L["Border Style"], borderStyleOptions, "Choose the visual style for UI borders")

	-- Number Prefix
	local numberPrefixOptions = {
		{ text = "Standard: b/m/k", value = 1 },
		{ text = "Asian: y/w", value = 2 },
		{ text = "Full Digits", value = 3 },
	}
	GUI:CreateDropdown(generalGeneralSection, "General.NumberPrefixStyle", L["Number Prefix Style"], numberPrefixOptions, "Choose how large numbers are abbreviated")

	-- Smoothing
	GUI:CreateSlider(generalGeneralSection, "General.SmoothAmount", "Smoothing Amount", 0.1, 1, 0.01, L["Setup healthbar smooth frequency for unitframes and nameplates. The lower the smoother."])

	-- Scaling
	local scalingSection = GUI:AddSection(generalCategory, L["Scaling"])
	GUI:CreateSwitch(scalingSection, "General.AutoScale", L["Auto Scale"], L["AutoScaleTip"] .. " (requires reload)", UpdateUIScale)
	GUI:CreateSlider(scalingSection, "General.UIScale", L["Set UI scale"], 0.4, 1.15, 0.01, L["UIScaleTip"] .. " (requires reload)", UpdateUIScale)

	-- Colors
	local colorsSection = GUI:AddSection(generalCategory, COLORS)
	GUI:CreateSwitch(colorsSection, "General.ColorTextures", L["Color 'Most' KkthnxUI Borders"], L["ColorTextures Desc"] .. " (requires reload)")
	GUI:CreateColorPicker(colorsSection, "General.TexturesColor", L["Textures Color"], "Choose the color for KkthnxUI textures and borders (requires reload)")

	-- Texture Section
	local textureSection = GUI:AddSection(generalCategory, L["Texture"])

	-- Enhanced Texture
	GUI:CreateTextureDropdown(textureSection, "General.Texture", L["Set General Texture"], L["Texture Desc"] .. " (requires reload)")
end

-- Inventory
local function CreateInventoryCategory()
	local inventoryIcon = "Interface\\Icons\\INV_Misc_Bag_07"
	local inventoryCategory = GUI:AddCategory(L["Inventory"] or "Inventory", inventoryIcon)

	-- Hooks
	local function UpdateBagStatus()
		local inventoryModule = K:GetModule("Bags")
		if inventoryModule and inventoryModule.UpdateBagStatus then
			inventoryModule:UpdateBagStatus()
		end
	end

	local function UpdateBagSortOrder()
		local inventoryModule = K:GetModule("Bags")
		if inventoryModule and inventoryModule.UpdateSortOrder then
			inventoryModule:UpdateSortOrder()
		end
	end

	local function UpdateBagAnchor()
		local inventoryModule = K:GetModule("Bags")
		if inventoryModule and inventoryModule.UpdateBagAnchor then
			inventoryModule:UpdateBagAnchor()
		end
	end

	local function UpdateBagSize()
		local inventoryModule = K:GetModule("Bags")
		if inventoryModule and inventoryModule.UpdateBagSize then
			inventoryModule:UpdateBagSize()
		end
	end

	-- General
	local generalInventorySection = GUI:AddSection(inventoryCategory, GENERAL)
	GUI:CreateSwitch(generalInventorySection, "Inventory.Enable", enableTextColor .. L["Enable Inventory"], L["Enable Desc"] .. " (requires reload)")
	GUI:CreateSwitch(generalInventorySection, "Inventory.AutoSell", L["Auto Vendor Grays"], "Automatically sells gray quality items to vendors")

	-- Bags Section
	local bagsSection = GUI:AddSection(inventoryCategory, L["Bags"] or "Bags")
	GUI:CreateSwitch(bagsSection, "Inventory.ColorUnusableItems", L["Color Unusable Items"], L["ColorUnusableItems Desc"], UpdateBagStatus, true)
	GUI:CreateSwitch(bagsSection, "Inventory.BagsBindOnEquip", L["Display Bind Status"], L["BagsBindOnEquip Desc"], UpdateBagStatus)
	GUI:CreateSwitch(bagsSection, "Inventory.BagsItemLevel", L["Display Item Level"], L["BagsItemLevel Desc"], UpdateBagStatus)
	GUI:CreateSwitch(bagsSection, "Inventory.DeleteButton", L["Bags Delete Button"], "Shows a delete button for easy item deletion")
	GUI:CreateSwitch(bagsSection, "Inventory.ReverseSort", L["Reverse the Sorting"], L["ReverseSort Desc"], UpdateBagSortOrder)
	GUI:CreateSwitch(bagsSection, "Inventory.ShowNewItem", L["Show New Item Glow"], "Highlights newly acquired items with a glow effect")
	GUI:CreateSwitch(bagsSection, "Inventory.UpgradeIcon", L["Show Upgrade Icon"], "Displays an icon on items that are upgrades for your character")
	GUI:CreateSlider(bagsSection, "Inventory.BagsPerRow", L["Bags Per Row"], 1, 20, 1, L["BagsPerRow Desc"], UpdateBagAnchor)
	GUI:CreateSlider(bagsSection, "Inventory.iLvlToShow", "ItemLevel Threshold", 1, 800, 1, L["iLvlToShow Desc"], UpdateBagStatus)

	-- Bank Section
	local bankSection = GUI:AddSection(inventoryCategory, BANK)
	GUI:CreateSlider(bankSection, "Inventory.BankPerRow", L["Bank Bags Per Row"], 1, 20, 1, L["BankPerRow Desc"], UpdateBagAnchor)

	-- Other Section
	local otherInventorySection = GUI:AddSection(inventoryCategory, OTHER)
	GUI:CreateSwitch(otherInventorySection, "Inventory.PetTrash", L["Pet Trash Currencies"], "In patch 9.1, you can buy 3 battle pets by using specific trash items. Keep this enabled, will sort these items into Collection Filter, and won't be sold by auto junk", UpdateInventorySettings)

	-- Auto Repair
	local autoRepairOptions = {
		{ text = GUILD, value = 1 },
		{ text = PLAYER, value = 2 },
		{ text = DISABLE, value = 3 },
	}
	GUI:CreateDropdown(otherInventorySection, "Inventory.AutoRepair", L["Auto Repair Gear"], autoRepairOptions, "Choose how to automatically repair your gear")

	-- Filters
	local filtersSection = GUI:AddSection(inventoryCategory, FILTERS)
	local itemFilterSwitch = GUI:CreateSwitch(filtersSection, "Inventory.ItemFilter", L["Filter Items Into Categories"], L["ItemFilter Desc"], UpdateBagStatus)
	local gatherEmptySwitch = GUI:CreateSwitch(filtersSection, "Inventory.GatherEmpty", L["Gather Empty Slots Into One Button"], L["GatherEmpty Desc"], UpdateBagStatus)
	-- Dependency: Only allow Gather Empty when ItemFilter is enabled
	GUI:DependsOn(gatherEmptySwitch, "Inventory.ItemFilter", true, nil, L["Filter Items Into Categories"])

	-- Sizes
	local inventorySizesSection = GUI:AddSection(inventoryCategory, L["Sizes"])
	GUI:CreateSlider(inventorySizesSection, "Inventory.BagsWidth", L["Bags Width"], 8, 16, 1, L["BagsWidth Desc"], UpdateBagSize)
	GUI:CreateSlider(inventorySizesSection, "Inventory.BankWidth", L["Bank Width"], 10, 18, 1, L["BankWidth Desc"], UpdateBagSize)
	GUI:CreateSlider(inventorySizesSection, "Inventory.IconSize", L["Slot Icon Size"], 28, 40, 1, L["IconSize Desc"] .. " (requires reload)", UpdateBagSize)

	-- Bag Bar
	local bagBarSection = GUI:AddSection(inventoryCategory, L["Bag Bar"])
	GUI:CreateSwitch(bagBarSection, "Inventory.BagBar", enableTextColor .. L["Enable Bagbar"], L["BagBar Desc"])
	GUI:CreateSwitch(bagBarSection, "Inventory.JustBackpack", L["Just Show Main Backpack"], L["JustBackpack Desc"])
	GUI:CreateSlider(bagBarSection, "Inventory.BagBarSize", L["BagBar Size"], 20, 34, 1, L["BagBarSize Desc"])

	-- Growth
	local growthDirectionOptions = {
		{ text = "Horizontal", value = 1 },
		{ text = "Vertical", value = 2 },
	}
	GUI:CreateDropdown(bagBarSection, "Inventory.GrowthDirection", L["Growth Direction"], growthDirectionOptions, L["GrowthDirection Desc"])

	-- Sort
	local sortDirectionOptions = {
		{ text = "Ascending", value = 1 },
		{ text = "Descending", value = 2 },
	}
	GUI:CreateDropdown(bagBarSection, "Inventory.SortDirection", L["Sort Direction"], sortDirectionOptions, "Choose the direction for sorting bag contents")
end

-- Loot
local function CreateLootCategory()
	local lootIcon = "Interface\\Icons\\INV_Misc_Coin_02"
	local lootCategory = GUI:AddCategory(L["Loot"] or "Loot", lootIcon)

	-- General
	local generalLootSection = GUI:AddSection(lootCategory, GENERAL)
	GUI:CreateSwitch(generalLootSection, "Loot.Enable", enableTextColor .. L["Enable Loot"], L["Enable Desc"])
	GUI:CreateSwitch(generalLootSection, "Loot.GroupLoot", enableTextColor .. L["Enable Group Loot"], L["GroupLoot Desc"])

	-- Auto-Loot
	local autoLootingSection = GUI:AddSection(lootCategory, L["Auto-Looting"])
	GUI:CreateSwitch(autoLootingSection, "Loot.FastLoot", L["Faster Auto-Looting"], L["FastLoot Desc"])

	-- Auto-Confirming
	local autoConfirmSection = GUI:AddSection(lootCategory, L["Auto-Confirm"])
	GUI:CreateSwitch(autoConfirmSection, "Loot.AutoConfirm", L["Auto Confirm Loot Dialogs"], "Automatically confirms loot dialogs and prompts")
	GUI:CreateSwitch(autoConfirmSection, "Loot.AutoGreed", L["Auto Greed Green Items"], L["AutoGreed Desc"])
end

-- Minimap
local function CreateMinimapCategory()
	local minimapIcon = "Interface\\Icons\\INV_Misc_Map_01"
	local minimapCategory = GUI:AddCategory(L["Minimap"] or "Minimap", minimapIcon)

	local function UpdateMinimapSize()
		local minimapModule = K:GetModule("Minimap")
		if minimapModule and minimapModule.UpdateSize then
			minimapModule:UpdateSize()
		end
	end

	local function UpdateRecycleBin()
		local minimapModule = K:GetModule("Minimap")
		if minimapModule and minimapModule.UpdateRecycleBin then
			minimapModule:UpdateRecycleBin()
		end
	end

	local function UpdateEasyVolume()
		local minimapModule = K:GetModule("Minimap")
		if minimapModule and minimapModule.UpdateEasyVolume then
			minimapModule:UpdateEasyVolume()
		end
	end

	local function UpdateMailPulse()
		local minimapModule = K:GetModule("Minimap")
		if minimapModule and minimapModule.UpdateMailPulse then
			minimapModule:UpdateMailPulse()
		end
	end

	-- General
	local generalMinimapSection = GUI:AddSection(minimapCategory, GENERAL)
	GUI:CreateSwitch(generalMinimapSection, "Minimap.Enable", enableTextColor .. L["Enable Minimap"], L["Enable Desc"])
	GUI:CreateSwitch(generalMinimapSection, "Minimap.Calendar", L["Show Minimap Calendar"], L["If enabled, show minimap calendar icon on minimap.|nYou can simply click mouse middle button on minimap to toggle calendar even without this option."])

	-- Features
	local featuresSection = GUI:AddSection(minimapCategory, L["Features"])
	GUI:CreateSwitch(featuresSection, "Minimap.EasyVolume", L["EasyVolume"], L["EasyVolumeTip"], UpdateEasyVolume)
	GUI:CreateSwitch(featuresSection, "Minimap.MailPulse", L["Pulse Minimap Mail"], L["MailPulse Desc"], UpdateMailPulse)
	GUI:CreateSwitch(featuresSection, "Minimap.QueueStatusText", L["QueueStatus"], "Show queue status text on the minimap")
	GUI:CreateSwitch(featuresSection, "Minimap.ShowRecycleBin", L["Show Minimap Button Collector"], L["ShowRecycleBin Desc"], UpdateRecycleBin)

	-- Recycle Bin
	local recycleBinSection = GUI:AddSection(minimapCategory, L["Recycle Bin"])

	-- RecycleBin Position
	local recycleBinPositionOptions = {
		{ text = "BottomLeft", value = 1 },
		{ text = "BottomRight", value = 2 },
		{ text = "TopLeft", value = 3 },
		{ text = "TopRight", value = 4 },
	}
	GUI:CreateDropdown(recycleBinSection, "Minimap.RecycleBinPosition", L["Set RecycleBin Positon"], recycleBinPositionOptions, L["RecycleBinPosition Desc"], UpdateRecycleBin)

	-- Location Section
	local locationSection = GUI:AddSection(minimapCategory, L["Location"])

	-- Location Text Style
	local locationTextOptions = {
		{ text = "Always Display", value = 1 },
		{ text = "Hide", value = 2 },
		{ text = "Minimap Mouseover", value = 3 },
	}
	GUI:CreateDropdown(locationSection, "Minimap.LocationText", L["Location Text Style"], locationTextOptions, "Choose how location text is displayed on the minimap")

	-- Size
	local sizeSection = GUI:AddSection(minimapCategory, L["Size"])
	GUI:CreateSlider(sizeSection, "Minimap.Size", L["Minimap Size"], 120, 300, 1, L["Size Desc"], UpdateMinimapSize)
end

-- Misc Category
local function CreateMiscCategory()
	local miscIcon = "Interface\\Icons\\INV_Misc_Bag_10"
	local miscCategory = GUI:AddCategory(L["Misc"] or "Misc", miscIcon)

	local function UpdateYClassColors()
		local miscModule = K:GetModule("Miscellaneous")
		if miscModule and miscModule.UpdateYClassColors then
			miscModule:UpdateYClassColors()
		end
	end

	local function UpdateMaxZoomLevel()
		local miscModule = K:GetModule("Miscellaneous")
		if miscModule and miscModule.UpdateMaxZoomLevel then
			miscModule:UpdateMaxZoomLevel()
		end
	end

	local function UpdateMarkerGrid()
		local miscModule = K:GetModule("Miscellaneous")
		if miscModule and miscModule.UpdateMarkerGrid then
			miscModule:UpdateMarkerGrid()
		end
	end

	-- UI Enhancements
	local uiEnhanceSection = GUI:AddSection(miscCategory, "UI Enhancements")
	GUI:CreateSwitch(uiEnhanceSection, "Misc.ColorPicker", L["Enhanced Color Picker"], "Enhances the default color picker with additional functionality")
	GUI:CreateSwitch(uiEnhanceSection, "Misc.ImprovedStats", L["Display Character Frame Full Stats"], "Shows expanded character statistics in the character frame")
	GUI:CreateSwitch(uiEnhanceSection, "Misc.YClassColors", "Enable ClassColors", "Toggle the display of class colors in the guild roster, friends list, and Who frame.", UpdateYClassColors)

	-- Target Marking
	local markingSection = GUI:AddSection(miscCategory, "Target Marking")
	GUI:CreateSwitch(markingSection, "Misc.EasyMarking", L["EasyMarking by Ctrl + LeftClick"], "Allows quick marking of targets using Ctrl + Left Click")

	-- Location Text Style
	local easyMarkKeyOptions = {
		{ text = "CTRL_KEY", value = 1 },
		{ text = "ALT_KEY", value = 2 },
		{ text = "SHIFT_KEY", value = 3 },
		{ text = DISABLE, value = 4 },
	}
	GUI:CreateDropdown(markingSection, "Misc.EasyMarkKey", "EasyMarking Key Modifier", easyMarkKeyOptions, "Put the tooltip info in...!")

	-- Encounter UI
	local encounterSection = GUI:AddSection(miscCategory, "Encounter UI")
	GUI:CreateSwitch(encounterSection, "Misc.HideBanner", L["Hide RaidBoss EmoteFrame"], "Hides the raid boss emote frame during encounters")
	GUI:CreateSwitch(encounterSection, "Misc.HideBossEmote", L["Hide BossBanner"], "Hides the boss banner that appears during boss encounters")

	-- Camera
	local cameraSection = GUI:AddSection(miscCategory, "Camera")
	GUI:CreateSlider(cameraSection, "Misc.MaxCameraZoom", "Max Camera Zoom Level", 1, 2.6, 0.1, "Set the maximum camera zoom distance", UpdateMaxZoomLevel)
	GUI:CreateSwitch(cameraSection, "Misc.AFKCamera", L["AFK Camera"], "Enables automatic camera movement when you go AFK")

	-- Trade Skill
	local tradeSkillSection = GUI:AddSection(miscCategory, "Trade Skill")
	GUI:CreateSwitch(tradeSkillSection, "Misc.TradeTabs", L["Add Spellbook-Like Tabs On TradeSkillFrame"], "Adds convenient tabs to the trade skill frame similar to the spellbook")

	-- Social
	local socialSection = GUI:AddSection(miscCategory, "Social")
	GUI:CreateSwitch(socialSection, "Misc.EnhancedFriends", L["Enhanced Colors (Friends/Guild +)"], "Enhances the friends and guild list with improved colors and information")
	GUI:CreateSwitch(socialSection, "Misc.QuickJoin", L["QuickJoin"], L["QuickJoinTip"])

	-- Audio
	local audioSection = GUI:AddSection(miscCategory, "Audio")
	GUI:CreateSwitch(audioSection, "Misc.MuteSounds", "Mute Various Annoying Sounds In-Game", "Mutes specific annoying sound effects in the game")

	-- Mail
	local mailSection = GUI:AddSection(miscCategory, "Mail")
	GUI:CreateSwitch(mailSection, "Misc.EnhancedMail", "Add 'Postal' Like Feaures To The Mailbox", "Enhances the mailbox with features similar to the Postal addon")

	-- Questing & Dialog
	local questingSection = GUI:AddSection(miscCategory, "Questing & Dialog")
	GUI:CreateSwitch(questingSection, "Misc.ExpRep", "Display Exp/Rep Bar (Minimap)", "Shows experience and reputation bars near the minimap")
	GUI:CreateSwitch(questingSection, "Misc.QuestTool", "Add Tips For Some Quests And World Quests", "Provides helpful tips and information for quests and world quests")
	GUI:CreateSwitch(questingSection, "Misc.ShowWowHeadLinks", L["Show Wowhead Links Above Questlog Frame"], "Displays helpful Wowhead links above the quest log frame")
	GUI:CreateSwitch(questingSection, "Misc.NoTalkingHead", L["Remove And Hide The TalkingHead Frame"], "Completely removes the talking head frame from quest interactions")

	-- Mythic+
	local mythicPlusSection = GUI:AddSection(miscCategory, "Mythic+")

	GUI:CreateSwitch(mythicPlusSection, "Misc.MDGuildBest", L["Show Mythic+ GuildBest"], "Displays your guild's best Mythic+ dungeon times and scores")

	-- Raid Tool
	local raidToolSection = GUI:AddSection(miscCategory, "Raid Tool")
	GUI:CreateSwitch(raidToolSection, "Misc.RaidTool", L["Show Raid Utility Frame"], "Shows the raid utility frame with useful raid tools and information")
	GUI:CreateSwitch(raidToolSection, "Misc.RMRune", "RMRune - Add Info", "Adds additional information for Runic Power and similar resources")
	GUI:CreateTextInput(raidToolSection, "Misc.DBMCount", "DBMCount - Add Info", "Enter custom info...", "Configure custom DBM count information")

	-- World Markers Bar
	local markerBarOptions = {
		{ text = "Grids", value = 1 },
		{ text = "Horizontal", value = 2 },
		{ text = "Vertical", value = 3 },
		{ text = DISABLE, value = 4 },
	}
	GUI:CreateDropdown(raidToolSection, "Misc.ShowMarkerBar", L["World Markers Bar"], markerBarOptions, "Controls when the world markers bar is displayed", UpdateMarkerGrid)
	GUI:CreateSlider(raidToolSection, "Misc.MarkerBarSize", "Marker Bar Size - Add Info", 20, 40, 1, "Size of the world marker bar buttons", UpdateMarkerGrid)

	-- Character & Inspect
	local characterSection = GUI:AddSection(miscCategory, "Character & Inspect")
	GUI:CreateSwitch(characterSection, "Misc.ItemLevel", L["Show Character/Inspect ItemLevel Info"], "Displays item level information on character and inspect frames")
	GUI:CreateSwitch(characterSection, "Misc.GemEnchantInfo", L["Character/Inspect Gem/Enchant Info"], "Shows gem and enchant information on character and inspect frames")
	GUI:CreateSwitch(characterSection, "Misc.SlotDurability", L["Show Slot Durability %"], "Shows durability percentage on equipment slots")

	local queueTimerSection = GUI:AddSection(miscCategory, "Queue Timer")
	local master = GUI:CreateSwitch(queueTimerSection, "Misc.QueueTimers", "Queue Timer", "Enable enhanced queue timer for PvE/PvP dialogs", nil, true)
	local audio = GUI:CreateSwitch(queueTimerSection, "Misc.QueueTimerAudio", "Audio cue", "Play a sound when the timer UI opens", nil, true)
	local warn = GUI:CreateSwitch(queueTimerSection, "Misc.QueueTimerWarning", "6s warning beeps", "Triple beep near expiration", nil, true)
	local hide = GUI:CreateSwitch(queueTimerSection, "Misc.QueueTimerHideOtherTimers", "Hide other bars", "Hide other timer status bars on the dialog", nil, true)

	GUI:DependsOn(audio, "Misc.QueueTimers", true)
	GUI:DependsOn(warn, "Misc.QueueTimers", true)
	GUI:DependsOn(hide, "Misc.QueueTimers", true)
end

-- Nameplate
local function CreateNameplateCategory()
	local nameplateIcon = "Interface\\Icons\\Spell_Arcane_MindMastery"
	local nameplateCategory = GUI:AddCategory(L["Nameplate"] or "Nameplate", nameplateIcon)

	-- Hooks
	local function refreshNameplates()
		local nameplateModule = K:GetModule("Unitframes")
		if nameplateModule and nameplateModule.UpdateNameplateSize then
			nameplateModule:UpdateNameplateSize()
		end
	end

	local function UpdateCustomUnitList(newValue, oldValue, path)
		-- Treat this input as a buffer: merge tokens into the real list, then clear the buffer
		local input = tostring(newValue or "")
		-- normalize separators and trim
		input = input:gsub(",", " ")
		input = input:gsub("%s+", " ")
		input = input:match("^%s*(.-)%s*$") or ""

		if input ~= "" then
			local existing = tostring(C["Nameplate"].CustomUnitList or "")
			local set = {}
			for w in string.gmatch(existing, "%S+") do
				set[w] = true
			end
			for w in string.gmatch(input, "%S+") do
				set[w] = true
			end
			local merged = {}
			for w in pairs(set) do
				table.insert(merged, w)
			end
			table.sort(merged)
			local mergedStr = table.concat(merged, " ")

			if K.GUI and K.GUI.GUI and K.GUI.GUI.SetConfigValue then
				K.GUI.GUI:SetConfigValue("Nameplate.CustomUnitList", mergedStr)
				-- Clear the buffer input field
				if path then
					K.GUI.GUI:SetConfigValue(path, "")
				end
			else
				C["Nameplate"].CustomUnitList = mergedStr
			end
		end

		local nameplateModule = K:GetModule("Unitframes")
		if nameplateModule and nameplateModule.CreateUnitTable then
			nameplateModule:CreateUnitTable()
		end
	end

	local function UpdatePowerUnitList(newValue, oldValue, path)
		-- Treat this input as a buffer: merge tokens into the real list, then clear the buffer
		local input = tostring(newValue or "")
		-- normalize separators and trim
		input = input:gsub(",", " ")
		input = input:gsub("%s+", " ")
		input = input:match("^%s*(.-)%s*$") or ""

		if input ~= "" then
			local existing = tostring(C["Nameplate"].PowerUnitList or "")
			local set = {}
			for w in string.gmatch(existing, "%S+") do
				set[w] = true
			end
			for w in string.gmatch(input, "%S+") do
				set[w] = true
			end
			local merged = {}
			for w in pairs(set) do
				table.insert(merged, w)
			end
			table.sort(merged)
			local mergedStr = table.concat(merged, " ")

			if K.GUI and K.GUI.GUI and K.GUI.GUI.SetConfigValue then
				K.GUI.GUI:SetConfigValue("Nameplate.PowerUnitList", mergedStr)
				-- Clear the buffer input field
				if path then
					K.GUI.GUI:SetConfigValue(path, "")
				end
			else
				C["Nameplate"].PowerUnitList = mergedStr
			end
		end

		local nameplateModule = K:GetModule("Unitframes")
		if nameplateModule and nameplateModule.CreatePowerUnitTable then
			nameplateModule:CreatePowerUnitTable()
		end
	end

	local function togglePlayerPlate()
		local nameplateModule = K:GetModule("Unitframes")
		if nameplateModule and nameplateModule.TogglePlayerPlate then
			nameplateModule:TogglePlayerPlate()
		end
	end

	local function togglePlatePower()
		local nameplateModule = K:GetModule("Unitframes")
		if nameplateModule and nameplateModule.TogglePlatePower then
			nameplateModule:TogglePlatePower()
		end
	end

	-- General
	local generalNameplateSection = GUI:AddSection(nameplateCategory, GENERAL)

	GUI:CreateSwitch(generalNameplateSection, "Nameplate.Enable", enableTextColor .. L["Enable Nameplates"], "Toggle the entire nameplate system on/off")
	GUI:CreateSwitch(generalNameplateSection, "Nameplate.ClassIcon", L["Show Enemy Class Icons"], "Displays class icons on enemy nameplates", refreshNameplates)
	GUI:CreateSwitch(generalNameplateSection, "Nameplate.CustomUnitColor", L["Colored Custom Units"], "Enable custom coloring for specific units", refreshNameplates)
	GUI:CreateSwitch(generalNameplateSection, "Nameplate.FriendlyCC", L["Show Friendly ClassColor"], "Show class colors on friendly unit nameplates", refreshNameplates)
	GUI:CreateSwitch(generalNameplateSection, "Nameplate.HostileCC", L["Show Hostile ClassColor"], "Show class colors on hostile unit nameplates", refreshNameplates)
	GUI:CreateSwitch(generalNameplateSection, "Nameplate.FullHealth", L["Show Health Value"], "Display health values on nameplates", refreshNameplates)
	GUI:CreateSwitch(generalNameplateSection, "Nameplate.InsideView", L["Interacted Nameplate Stay Inside"], "Keep interacted nameplates visible inside the game view", refreshNameplates)
	GUI:CreateSwitch(generalNameplateSection, "Nameplate.NameOnly", L["Show Only Names For Friendly"], "Show only names for friendly units, hiding health bars", refreshNameplates)
	GUI:CreateSwitch(generalNameplateSection, "Nameplate.NameplateClassPower", "Show Nameplate Class Power", "Display class power resources on nameplates", refreshNameplates)

	-- Auras
	local aurasNameplateSection = GUI:AddSection(nameplateCategory, L["Auras"])
	local auraFilterOptions = {
		{ text = "White & Black List", value = 1 },
		{ text = "List & Player", value = 2 },
		{ text = "List & Player & CCs", value = 3 },
	}
	GUI:CreateDropdown(aurasNameplateSection, "Nameplate.AuraFilter", L["Auras Filter Style"], auraFilterOptions, "Choose which auras to display on nameplates", refreshNameplates)
	GUI:CreateSlider(aurasNameplateSection, "Nameplate.AuraSize", L["Auras Size"], 18, 40, 1, "Size of aura icons on nameplates", refreshNameplates)
	GUI:CreateSlider(aurasNameplateSection, "Nameplate.MaxAuras", L["Max Auras"], 4, 8, 1, "Maximum number of auras to show on nameplates", refreshNameplates)
	GUI:CreateSwitch(aurasNameplateSection, "Nameplate.PlateAuras", L["Target Nameplate Auras"], L["TargetPlateAuras Desc"], refreshNameplates)

	-- Targeting & Indicators
	local indicatorsSection = GUI:AddSection(nameplateCategory, L["Targeting & Indicators"])
	GUI:CreateSwitch(indicatorsSection, "Nameplate.ColoredTarget", L["Colored Targeted Nameplate"], L["ColoredTargeted Desc"], refreshNameplates)
	local targetIndicatorOptions = {
		{ text = "Disable", value = 1 },
		{ text = "Top Arrow", value = 2 },
		{ text = "Right Arrow", value = 3 },
		{ text = "Border Glow", value = 4 },
		{ text = "Top Arrow + Glow", value = 5 },
		{ text = "Right Arrow + Glow", value = 6 },
	}
	GUI:CreateDropdown(indicatorsSection, "Nameplate.TargetIndicator", L["TargetIndicator Style"], targetIndicatorOptions, "Choose the target indicator style", refreshNameplates)
	local targetIndicatorTextureOptions = {
		{ text = "Blue Arrow 2" .. "|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\BlueArrow2:0|t", value = "Interface\\Addons\\KkthnxUI\\Media\\Nameplates\\BlueArrow2" },
		{ text = "Blue Arrow" .. "|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\BlueArrow:0|t", value = "Interface\\Addons\\KkthnxUI\\Media\\Nameplates\\BlueArrow" },
		{ text = "Neon Blue Arrow" .. "|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\NeonBlueArrow:0|t", value = "Interface\\Addons\\KkthnxUI\\Media\\Nameplates\\NeonBlueArrow" },
		{ text = "Neon Green Arrow" .. "|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\NeonGreenArrow:0|t", value = "Interface\\Addons\\KkthnxUI\\Media\\Nameplates\\NeonGreenArrow" },
		{ text = "Neon Pink Arrow" .. "|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\NeonPinkArrow:0|t", value = "Interface\\Addons\\KkthnxUI\\Media\\Nameplates\\NeonPinkArrow" },
		{ text = "Neon Red Arrow" .. "|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\NeonRedArrow:0|t", value = "Interface\\Addons\\KkthnxUI\\Media\\Nameplates\\NeonRedArrow" },
		{ text = "Neon Purple Arrow" .. "|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\NeonPurpleArrow:0|t", value = "Interface\\Addons\\KkthnxUI\\Media\\Nameplates\\NeonPurpleArrow" },
		{ text = "Purple Arrow" .. "|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\PurpleArrow:0|t", value = "Interface\\Addons\\KkthnxUI\\Media\\Nameplates\\PurpleArrow" },
		{ text = "Red Arrow 2" .. "|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\RedArrow2.tga:0|t", value = "Interface\\Addons\\KkthnxUI\\Media\\Nameplates\\RedArrow2" },
		{ text = "Red Arrow" .. "|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\RedArrow:0|t", value = "Interface\\Addons\\KkthnxUI\\Media\\Nameplates\\RedArrow" },
		{ text = "Red Chevron Arrow" .. "|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\RedChevronArrow:0|t", value = "Interface\\Addons\\KkthnxUI\\Media\\Nameplates\\RedChevronArrow" },
		{ text = "Red Chevron Arrow2" .. "|TInterface\\Addons\\KkthnxUI\\Media\\Nameplates\\RedChevronArrow2:0|t", value = "Interface\\Addons\\KkthnxUI\\Media\\Nameplates\\RedChevronArrow2" },
	}
	GUI:CreateDropdown(indicatorsSection, "Nameplate.TargetIndicatorTexture", L["TargetIndicator Texture"], targetIndicatorTextureOptions, L["TargetIndicatorTexture Desc"], refreshNameplates)
	GUI:CreateColorPicker(indicatorsSection, "Nameplate.TargetIndicatorColor", L["TargetIndicator Color"], "Color for target indicators", refreshNameplates)

	-- Custom Lists
	local customListsSection = GUI:AddSection(nameplateCategory, L["Custom Lists"])
	-- Use buffer inputs so values clear after submission and are merged into the real lists
	GUI:CreateTextInput(customListsSection, "Nameplate.CustomUnitListInput", L["Custom UnitColor List"], L["Enter unit names..."], L["CustomUnitTip"], UpdateCustomUnitList)
	GUI:CreateTextInput(customListsSection, "Nameplate.PowerUnitListInput", L["Custom PowerUnit List"], L["Enter unit names..."], L["CustomUnitTip"], UpdatePowerUnitList)

	-- Castbar
	local castbarSection = GUI:AddSection(nameplateCategory, L["Castbar"])
	GUI:CreateSwitch(castbarSection, "Nameplate.CastTarget", L["Show Nameplate Target Of Casting Spell"], L["CastTarget Desc"], refreshNameplates)
	GUI:CreateSwitch(castbarSection, "Nameplate.CastbarGlow", L["Force Crucial Spells To Glow"], L["CastbarGlow Desc"], refreshNameplates)

	-- Threat
	local threatSection = GUI:AddSection(nameplateCategory, L["Threat"])
	GUI:CreateSwitch(threatSection, "Nameplate.DPSRevertThreat", L["Revert Threat Color If Not Tank"], "Use standard threat colors when not tanking", refreshNameplates)
	GUI:CreateSwitch(threatSection, "Nameplate.TankMode", L["Force TankMode Colored"], "Force tank-style threat coloring regardless of role", refreshNameplates)

	-- Miscellaneous
	local miscellaneousNameplateSection = GUI:AddSection(nameplateCategory, L["Miscellaneous"])
	GUI:CreateSwitch(miscellaneousNameplateSection, "Nameplate.AKSProgress", L["Show AngryKeystones Progress"], "Display AngryKeystones progress information on nameplates", refreshNameplates)
	GUI:CreateSwitch(miscellaneousNameplateSection, "Nameplate.PlateAuras", "Target Nameplate Auras", "Show auras on target nameplates", refreshNameplates)
	GUI:CreateSwitch(miscellaneousNameplateSection, "Nameplate.QuestIndicator", L["Quest Progress Indicator"], "Show quest progress indicators on nameplates", refreshNameplates)
	GUI:CreateSwitch(miscellaneousNameplateSection, "Nameplate.Smooth", L["Smooth Bars Transition"], "Enable smooth animations for nameplate bars", refreshNameplates)

	-- Sizes
	local sizesNameplateSection = GUI:AddSection(nameplateCategory, L["Sizes"])
	GUI:CreateSlider(sizesNameplateSection, "Nameplate.HealthTextSize", L["HealthText FontSize"], 8, 16, 1, "Font size for health text on nameplates", refreshNameplates)
	GUI:CreateSlider(sizesNameplateSection, "Nameplate.MinAlpha", L["Non-Target Nameplate Alpha"], 0.1, 1, 0.1, "Transparency of non-targeted nameplates", refreshNameplates)
	GUI:CreateSlider(sizesNameplateSection, "Nameplate.MinScale", L["Non-Target Nameplate Scale"], 0.1, 3, 0.1, "Scale of non-targeted nameplates", refreshNameplates)
	GUI:CreateSlider(sizesNameplateSection, "Nameplate.NameTextSize", L["NameText FontSize"], 8, 16, 1, "Font size for names on nameplates", refreshNameplates)
	GUI:CreateSlider(sizesNameplateSection, "Nameplate.PlateHeight", L["Nameplate Height"], 6, 28, 1, "Height of nameplate bars", refreshNameplates)
	GUI:CreateSlider(sizesNameplateSection, "Nameplate.PlateWidth", L["Nameplate Width"], 80, 240, 1, "Width of nameplate bars", refreshNameplates)
	GUI:CreateSlider(sizesNameplateSection, "Nameplate.VerticalSpacing", L["Nameplate Vertical Spacing"], 0.5, 2.5, 0.1, "Vertical spacing between stacked nameplates", refreshNameplates)
	GUI:CreateSlider(sizesNameplateSection, "Nameplate.SelectedScale", L["Selected Nameplate Scale"], 1, 1.4, 0.1, L["SelectedScale Desc"], refreshNameplates)

	-- Player Nameplate Toggles
	local playerTogglesSection = GUI:AddSection(nameplateCategory, L["Player Nameplate Toggles"])
	GUI:CreateSwitch(playerTogglesSection, "Nameplate.ShowPlayerPlate", enableTextColor .. L["Enable Personal Resource"], "Show your personal resource nameplate", togglePlayerPlate)
	GUI:CreateSwitch(playerTogglesSection, "Nameplate.PPGCDTicker", L["Enable GCD Ticker"], "Show global cooldown ticker on personal nameplate", refreshNameplates)
	GUI:CreateSwitch(playerTogglesSection, "Nameplate.PPHideOOC", L["Only Visible in Combat"], "Only show personal nameplate during combat", refreshNameplates)
	GUI:CreateSwitch(playerTogglesSection, "Nameplate.PPPowerText", L["Show Power Value"], "Display power values on personal nameplate", togglePlatePower)

	-- Player Nameplate Values
	local playerValuesSection = GUI:AddSection(nameplateCategory, L["Player Nameplate Values"])
	GUI:CreateSlider(playerValuesSection, "Nameplate.PPHeight", L["Classpower/Healthbar Height"], 4, 10, 1, "Height of class power and health bars on personal nameplate", refreshNameplates)
	GUI:CreateSlider(playerValuesSection, "Nameplate.PPIconSize", L["PlayerPlate IconSize"], 20, 40, 1, "Size of icons on personal nameplate", refreshNameplates)
	GUI:CreateSlider(playerValuesSection, "Nameplate.PPPHeight", L["PlayerPlate Powerbar Height"], 4, 10, 1, "Height of power bar on personal nameplate", refreshNameplates)

	-- Colors
	local colorsNameplateSection = GUI:AddSection(nameplateCategory, COLORS)
	GUI:CreateColorPicker(colorsNameplateSection, "Nameplate.CustomColor", L["Custom Color"], "Color for custom units", refreshNameplates)
	GUI:CreateColorPicker(colorsNameplateSection, "Nameplate.InsecureColor", L["Insecure Color"], "Color for insecure threat level", refreshNameplates)
	GUI:CreateColorPicker(colorsNameplateSection, "Nameplate.OffTankColor", L["Off-Tank Color"], "Color for off-tank units", refreshNameplates)
	GUI:CreateColorPicker(colorsNameplateSection, "Nameplate.SecureColor", L["Secure Color"], "Color for secure threat level", refreshNameplates)
	GUI:CreateColorPicker(colorsNameplateSection, "Nameplate.TargetColor", "Selected Target Coloring", "Color for targeted nameplates", refreshNameplates)
	GUI:CreateColorPicker(colorsNameplateSection, "Nameplate.TransColor", L["Transition Color"], "Color for threat transition states", refreshNameplates)
end

-- Party
local function CreatePartyCategory()
	local partyIcon = "Interface\\Icons\\Ships_ability_boardingparty"
	local partyCategory = GUI:AddCategory(L["Party"] or "Party", partyIcon)

	-- Hook Functions for Party
	local function UpdateUnitPartySize()
		local unitframeModule = K:GetModule("Unitframes")
		if unitframeModule and unitframeModule.UpdatePartySize then
			unitframeModule:UpdatePartySize()
		end
	end

	-- General Section
	local generalPartySection = GUI:AddSection(partyCategory, GENERAL)
	GUI:CreateSwitch(generalPartySection, "Party.Enable", enableTextColor .. L["Enable Party"], "Toggle the entire party frame system on/off")
	GUI:CreateSwitch(generalPartySection, "Party.ShowBuffs", L["Show Party Buffs"], "Display buffs on party member frames")
	GUI:CreateSwitch(generalPartySection, "Party.ShowHealPrediction", L["Show HealPrediction Statusbars"], "Show incoming heal predictions on party frames")
	GUI:CreateSwitch(generalPartySection, "Party.ShowPartySolo", L["Show Party Frames While Solo"], L["ShowPartySolo Desc"])
	GUI:CreateSwitch(generalPartySection, "Party.ShowPet", L["Show Party Pets"], "Display pet frames for party members")
	GUI:CreateSwitch(generalPartySection, "Party.ShowPlayer", L["Show Player In Party"], "Include your own frame in the party display")
	GUI:CreateSwitch(generalPartySection, "Party.Smooth", L["Smooth Bar Transition"], "Enable smooth animations for party frame bars")
	GUI:CreateSwitch(generalPartySection, "Party.TargetHighlight", L["Show Highlighted Target"], "Highlight the targeted party member")

	-- Party Castbars Section
	local castbarsPartySection = GUI:AddSection(partyCategory, L["Party Castbars"])
	GUI:CreateSwitch(castbarsPartySection, "Party.Castbars", L["Show Castbars"], "Display castbars on party member frames")
	GUI:CreateSwitch(castbarsPartySection, "Party.CastbarIcon", L["Show Castbars"] .. " Icon", "Show spell icons on party member castbars")

	-- Sizes Section
	local sizesPartySection = GUI:AddSection(partyCategory, L["Sizes"])
	GUI:CreateSlider(sizesPartySection, "Party.HealthHeight", L["Party Frame Health Height"], 20, 50, 1, L["Party.HealthHeight Desc"], UpdateUnitPartySize)
	GUI:CreateSlider(sizesPartySection, "Party.HealthWidth", L["Party Frame Health Width"], 120, 180, 1, L["Party.HealthWidth Desc"], UpdateUnitPartySize)
	GUI:CreateSlider(sizesPartySection, "Party.PowerHeight", L["Party Frame Power Height"], 10, 30, 1, L["Party.PowerHeight Desc"], UpdateUnitPartySize)

	-- Colors Section
	local colorsPartySection = GUI:AddSection(partyCategory, COLORS)
	local healthColorOptions = { -- Health Color Format Dropdown Options
		{ text = "Class", value = 1 },
		{ text = "Dark", value = 2 },
		{ text = "Value", value = 3 },
	}
	GUI:CreateDropdown(colorsPartySection, "Party.HealthbarColor", L["Health Color Format"], healthColorOptions, "Choose how health bars are colored on party frames")
end

-- SimpleParty (Raid-style compact party frames)
local function CreateSimplePartyCategory()
	local simplePartyIcon = "Interface\\Icons\\Ships_ability_boardingpartyalliance"
	local simplePartyCategory = GUI:AddCategory("Simple Party", simplePartyIcon)

	-- Hook Functions
	local function UpdateUnitSimplePartySize()
		local unitframeModule = K:GetModule("Unitframes")
		if unitframeModule and unitframeModule.UpdateSimplePartySize then
			unitframeModule:UpdateSimplePartySize()
		end
	end

	-- General Section
	local generalSimplePartySection = GUI:AddSection(simplePartyCategory, GENERAL)
	GUI:CreateSwitch(generalSimplePartySection, "SimpleParty.Enable", enableTextColor .. "Enable Simple Party (Raid-Style)", "Use compact raid-style party frames instead of traditional party frames (requires reload)", nil, true)
	GUI:CreateSwitch(generalSimplePartySection, "SimpleParty.ShowHealPrediction", L["Show HealPrediction Statusbars"], "Show incoming heal predictions on party frames", nil, true)
	GUI:CreateSwitch(generalSimplePartySection, "SimpleParty.Smooth", L["Smooth Bar Transition"], "Enable smooth animations for party frame bars", nil, true)
	GUI:CreateSwitch(generalSimplePartySection, "SimpleParty.TargetHighlight", L["Show Highlighted Target"], "Highlight the targeted party member", nil, true)

	-- Layout Section
	local layoutSimplePartySection = GUI:AddSection(simplePartyCategory, L["Layout"] or "Layout")
	GUI:CreateSwitch(layoutSimplePartySection, "SimpleParty.HorizonParty", L["Horizontal Party Frames"] or "Horizontal Party Frames", "Arrange party frames horizontally instead of vertically (requires reload)", nil, true)

	-- Bars Section
	local barsSimplePartySection = GUI:AddSection(simplePartyCategory, L["Bars"] or "Bars")
	GUI:CreateSwitch(barsSimplePartySection, "SimpleParty.PowerBarShow", "Show All Power Bars", "Show power bars on all party frames", nil, true)
	GUI:CreateSwitch(barsSimplePartySection, "SimpleParty.ManabarShow", L["Show Manabars"], "Display mana bars on party frames", nil, true)

	-- Sizes Section
	local sizesSimplePartySection = GUI:AddSection(simplePartyCategory, L["Sizes"])
	GUI:CreateSlider(sizesSimplePartySection, "SimpleParty.HealthHeight", "Simple Party Frame Height", 20, 100, 1, "Height of simple party member frames (requires reload)", UpdateUnitSimplePartySize, true)
	GUI:CreateSlider(sizesSimplePartySection, "SimpleParty.HealthWidth", "Simple Party Frame Width", 20, 100, 1, "Width of simple party member frames (requires reload)", UpdateUnitSimplePartySize, true)

	-- Colors Section
	local colorsSimplePartySection = GUI:AddSection(simplePartyCategory, COLORS)
	local healthColorOptions = {
		{ text = "Class", value = 1 },
		{ text = "Dark", value = 2 },
		{ text = "Value", value = 3 },
	}
	GUI:CreateDropdown(colorsSimplePartySection, "SimpleParty.HealthbarColor", L["Health Color Format"], healthColorOptions, "Choose how health bars are colored on simple party frames", nil, true)

	-- Raid Buffs Style
	local raidBuffsStyleOptions = {
		{ text = "Standard", value = 1 },
		{ text = "Aura Track", value = 2 },
		{ text = "Disable", value = 3 },
	}
	GUI:CreateDropdown(colorsSimplePartySection, "SimpleParty.RaidBuffsStyle", L["Buff Style"], raidBuffsStyleOptions, "Choose the buff display style for simple party frames", nil, true)
end

-- Raid Category
local function CreateRaidCategory()
	local raidIcon = "Interface\\Icons\\Achievement_boss_illidan"
	local raidCategory = GUI:AddCategory(L["Raid"] or "Raid", raidIcon)

	-- Hook Functions for Raid
	local function UpdateUnitRaidSize()
		local unitframeModule = K:GetModule("Unitframes")
		if unitframeModule and unitframeModule.UpdateRaidSize then
			unitframeModule:UpdateRaidSize()
		end
	end

	local function UpdateRaidBuffs()
		local unitframeModule = K:GetModule("Unitframes")
		if unitframeModule and unitframeModule.UpdateRaidBuffs then
			unitframeModule:UpdateRaidBuffs()
		end
	end

	local function UpdateRaidDebuffs()
		local unitframeModule = K:GetModule("Unitframes")
		if unitframeModule and unitframeModule.UpdateRaidDebuffs then
			unitframeModule:UpdateRaidDebuffs()
		end
	end

	-- General Section
	local generalRaidSection = GUI:AddSection(raidCategory, GENERAL)
	GUI:CreateSwitch(generalRaidSection, "Raid.Enable", enableTextColor .. L["Enable Raidframes"], "Toggle the entire raid frame system on/off")
	GUI:CreateSwitch(generalRaidSection, "Raid.MainTankFrames", L["Show MainTank Frames"], "Display dedicated frames for main tanks")

	-- Visibility
	local visibilityRaidSection = GUI:AddSection(raidCategory, L["Visibility"] or "Visibility")
	local function RefreshHeadersForUseRaidForParty()
		local uf = K:GetModule("Unitframes")
		if uf and uf.UpdateAllHeaders then
			uf:UpdateAllHeaders()
		end
	end
	GUI:CreateSwitch(visibilityRaidSection, "Raid.UseRaidForParty", L["Use Raid Frames for Party"] or "Use Raid Frames for Party", L["UseRaidForParty Desc"] or "Show raid frames instead of party frames while in a 2-5 player party.", RefreshHeadersForUseRaidForParty)
	GUI:CreateSwitch(visibilityRaidSection, "Raid.ShowRaidSolo", L["Show Raid Frames While Solo"] or "Show Raid Frames While Solo", L["ShowRaidSolo Desc"] or "Display raid frames when not in a group")
	GUI:CreateSwitch(visibilityRaidSection, "Raid.ShowTeamIndex", L["Show Group Number Team Index"], "Display group numbers above raid frames")

	-- Layout
	local layoutRaidSection = GUI:AddSection(raidCategory, L["Layout"] or "Layout")
	GUI:CreateSwitch(layoutRaidSection, "Raid.HorizonRaid", L["Horizontal Raid Frames"], "Arrange raid frames horizontally instead of vertically", UpdateRaidSettings)
	GUI:CreateSwitch(layoutRaidSection, "Raid.ReverseRaid", L["Reverse Raid Frame Growth"], "Reverse the growth direction of raid frames")

	-- Bars
	local barsRaidSection = GUI:AddSection(raidCategory, L["Bars"] or "Bars")
	GUI:CreateSwitch(barsRaidSection, "Raid.PowerBarShow", "Show All Power Bars", "Show power bars on all raid frames")
	GUI:CreateSwitch(barsRaidSection, "Raid.ManabarShow", L["Show Manabars"], "Display mana bars on raid frames")
	GUI:CreateSwitch(barsRaidSection, "Raid.Smooth", L["Smooth Bar Transition"], "Enable smooth animations for raid frame bars")

	-- Behavior
	local behaviorRaidSection = GUI:AddSection(raidCategory, L["Behavior"] or "Behavior")
	GUI:CreateSwitch(behaviorRaidSection, "Raid.ShowHealPrediction", L["Show HealPrediction Statusbars"], "Show incoming heal predictions on raid frames")
	GUI:CreateSwitch(behaviorRaidSection, "Raid.TargetHighlight", L["Show Highlighted Target"], "Highlight the selected raid unit")
	GUI:CreateSwitch(behaviorRaidSection, "Raid.ShowNotHereTimer", L["Show Away/DND Status"], "Display Away/DND status on raid members")

	-- Sizes
	local sizesRaidSection = GUI:AddSection(raidCategory, L["Sizes"])
	GUI:CreateSlider(sizesRaidSection, "Raid.Height", L["Raidframe Height"], 20, 100, 1, "Height of raid member frames", UpdateUnitRaidSize)
	GUI:CreateSlider(sizesRaidSection, "Raid.NumGroups", L["Number Of Groups to Show"], 1, 8, 1, "Number of raid groups to display")
	GUI:CreateSlider(sizesRaidSection, "Raid.Width", L["Raidframe Width"], 20, 100, 1, "Width of raid member frames", UpdateUnitRaidSize)

	-- Colors & Values
	local colorsRaidSection = GUI:AddSection(raidCategory, L["Colors"] or "Colors & Values")
	local healthColorOptions = {
		{ text = "Class", value = 1 },
		{ text = "Dark", value = 2 },
		{ text = "Value", value = 3 },
	}
	GUI:CreateDropdown(colorsRaidSection, "Raid.HealthbarColor", L["Health Color Format"], healthColorOptions, "Choose how raid health bars are colored")
	local healthFormatOptions = {
		{ text = "Disable HP", value = 1 },
		{ text = "Health Percentage", value = 2 },
		{ text = "Health Remaining", value = 3 },
		{ text = "Health Lost", value = 4 },
	}
	GUI:CreateDropdown(colorsRaidSection, "Raid.HealthFormat", L["Health Format"], healthFormatOptions, "Choose how health values are displayed on raid frames")

	-- Raid Buffs
	local raidBuffsSection = GUI:AddSection(raidCategory, L["Raid Buffs"])
	local raidBuffsStyleOptions = {
		{ text = "Standard", value = 1 },
		{ text = "Aura Track", value = 2 },
		{ text = "Disable", value = 3 },
	}
	GUI:CreateDropdown(raidBuffsSection, "Raid.RaidBuffsStyle", L["Buff Style"], raidBuffsStyleOptions, L["RaidBuffsStyle Desc"], UpdateRaidBuffs)
	GUI:CreateDropdown(raidBuffsSection, "Raid.RaidBuffs", L["Buff Display & Filtering"], {
		{ text = "Only my buffs", value = 1 },
		{ text = "Only castable buffs", value = 2 },
		{ text = "All buffs", value = 3 },
	}, L["RaidBuffs Desc"], UpdateRaidBuffs)
	GUI:CreateSwitch(raidBuffsSection, "Raid.DesaturateBuffs", L["Desaturate non-player buffs"], L["DesaturateBuffs Desc"], UpdateRaidBuffs)

	-- Aura Track
	local auraTrackSection = GUI:AddSection(raidCategory, L["Aura Track"])
	GUI:CreateSwitch(auraTrackSection, "Raid.AuraTrack", L["Enable aura tracking for healers (replaces buffs)"], L["AuraTrack Desc"], UpdateRaidBuffs)
	GUI:CreateSwitch(auraTrackSection, "Raid.AuraTrackIcons", L["Use square icons instead of bars"], L["AuraTrackIcons Desc"], UpdateRaidBuffs)
	GUI:CreateSwitch(auraTrackSection, "Raid.AuraTrackSpellTextures", L["Show spell textures on aura icons"], L["AuraTrackSpellTextures Desc"], UpdateRaidBuffs)
	GUI:CreateSlider(auraTrackSection, "Raid.AuraTrackThickness", L["Aura bar thickness (px)"], 2, 10, 1, L["AuraTrackThickness Desc"], UpdateRaidBuffs)

	-- Raid Debuffs
	local raidDebuffsSection = GUI:AddSection(raidCategory, L["Raid Debuffs"])
	GUI:CreateSwitch(raidDebuffsSection, "Raid.DebuffWatch", L["Enable debuff tracking (auto-filter by PvP/PvE)"], L["DebuffWatch Desc"], UpdateRaidDebuffs)
	GUI:CreateSwitch(raidDebuffsSection, "Raid.DebuffWatchDefault", L["Use built-in debuff lists (PvE & PvP)"], L["DebuffWatchDefault Desc"], UpdateRaidDebuffs)
end

-- Skins Category
local function CreateSkinsCategory()
	local skinsIcon = "Interface\\Icons\\INV_Misc_Desecrated_ClothChest"
	local skinsCategory = GUI:AddCategory(L["Skins"] or "Skins", skinsIcon)

	-- Hook Functions
	local function UpdateChatBubble()
		for _, chatBubble in pairs(C_ChatBubbles.GetAllChatBubbles()) do
			if chatBubble.KKUI_Background then
				chatBubble.KKUI_Background:SetVertexColor(C["Media"].Backdrops.ColorBackdrop[1], C["Media"].Backdrops.ColorBackdrop[2], C["Media"].Backdrops.ColorBackdrop[3], C["Skins"].ChatBubbleAlpha)
			end
		end
	end

	local function ResetDetails()
		local skinsModule = K:GetModule("Skins")
		if skinsModule and skinsModule.ResetDetailsAnchor then
			skinsModule:ResetDetailsAnchor(true)
		end
	end

	local function UpdateQuestFontSize()
		local miscModule = K:GetModule("Miscellaneous")
		if miscModule and miscModule.CreateQuestSizeUpdate then
			miscModule:CreateQuestSizeUpdate()
		end
	end

	local function UpdateObjectiveFontSize()
		local miscModule = K:GetModule("Miscellaneous")
		if miscModule and miscModule.CreateObjectiveSizeUpdate then
			miscModule:CreateObjectiveSizeUpdate()
		end
	end

	-- Blizzard Skins
	local blizzardSkinsSection = GUI:AddSection(skinsCategory, L["Blizzard Skins"])
	GUI:CreateSwitch(blizzardSkinsSection, "Skins.BlizzardFrames", L["Skin Some Blizzard Frames & Objects"], "Enable skinning of various Blizzard UI frames and objects")
	GUI:CreateSwitch(blizzardSkinsSection, "Skins.TalkingHeadBackdrop", L["TalkingHead Skin"], "Apply custom styling to the TalkingHead frame")
	GUI:CreateSwitch(blizzardSkinsSection, "Skins.ChatBubbles", L["ChatBubbles Skin"], "Apply custom styling to chat bubbles")
	GUI:CreateSlider(blizzardSkinsSection, "Skins.ChatBubbleAlpha", L["ChatBubbles Background Alpha"], 0, 1, 0.1, "Controls the transparency of chat bubble backgrounds", UpdateChatBubble)

	-- AddOn Skins
	local addonSkinsSection = GUI:AddSection(skinsCategory, L["AddOn Skins"])
	GUI:CreateSwitch(addonSkinsSection, "Skins.Bartender4", L["Bartender4 Skin"], "Apply KkthnxUI styling to Bartender4 action bars")
	GUI:CreateSwitch(addonSkinsSection, "Skins.BigWigs", L["BigWigs Skin"], "Apply KkthnxUI styling to BigWigs boss mod frames")
	GUI:CreateSwitch(addonSkinsSection, "Skins.ButtonForge", L["ButtonForge Skin"], "Apply KkthnxUI styling to ButtonForge addon")
	GUI:CreateSwitch(addonSkinsSection, "Skins.ChocolateBar", L["ChocolateBar Skin"], "Apply KkthnxUI styling to ChocolateBar addon")
	GUI:CreateSwitch(addonSkinsSection, "Skins.DeadlyBossMods", L["Deadly Boss Mods Skin"], "Apply KkthnxUI styling to Deadly Boss Mods (DBM)")
	GUI:CreateSwitch(addonSkinsSection, "Skins.Details", L["Details Skin"], "Apply KkthnxUI styling to Details! damage meter")
	GUI:CreateSwitch(addonSkinsSection, "Skins.Dominos", L["Dominos Skin"], "Apply KkthnxUI styling to Dominos action bar addon")
	GUI:CreateSwitch(addonSkinsSection, "Skins.RareScanner", L["RareScanner Skin"], "Apply KkthnxUI styling to RareScanner addon")
	GUI:CreateSwitch(addonSkinsSection, "Skins.WeakAuras", L["WeakAuras Skin"], "Apply KkthnxUI styling to WeakAuras addon")

	-- Details Reset
	GUI:CreateButtonWidget(addonSkinsSection, "Skins.ResetDetails", L["Reset Details"], L["Reset Details"], L["ResetDetails Desc"], function()
		ResetDetails()
	end)

	-- Font Tweaks
	local fontTweaksSection = GUI:AddSection(skinsCategory, L["Font Tweaks"])
	GUI:CreateSlider(fontTweaksSection, "Skins.QuestFontSize", L["Adjust QuestFont Size"], 10, 30, 1, L["QuestFontSize Desc"], UpdateQuestFontSize)
	GUI:CreateSlider(fontTweaksSection, "Skins.ObjectiveFontSize", L["Adjust ObjectiveFont Size"], 10, 30, 1, L["ObjectiveFontSize Desc"], UpdateObjectiveFontSize)
end

-- Tooltip
local function CreateTooltipCategory()
	local tooltipIcon = "Interface\\Icons\\Inv_inscription_tooltip_darkmooncard_mop"
	local tooltipCategory = GUI:AddCategory(L["Tooltip"] or "Tooltip", tooltipIcon)

	local function UpdateTooltipAnchor()
		local tooltipModule = K:GetModule("Tooltip")
		if tooltipModule and tooltipModule.UpdateAnchor then
			tooltipModule:UpdateAnchor()
		end
	end

	local function UpdateTooltipCursor()
		local tooltipModule = K:GetModule("Tooltip")
		if tooltipModule and tooltipModule.UpdateCursorMode then
			tooltipModule:UpdateCursorMode()
		end
	end

	-- General
	local generalTooltipSection = GUI:AddSection(tooltipCategory, GENERAL)
	GUI:CreateSwitch(generalTooltipSection, "Tooltip.Enable", enableTextColor .. L["Enable Tooltip"], L["Enable Desc"])
	GUI:CreateSwitch(generalTooltipSection, "Tooltip.CombatHide", L["Hide Tooltip in Combat"], "Hide tooltips during combat to reduce screen clutter")
	GUI:CreateSwitch(generalTooltipSection, "Tooltip.Icons", L["Item Icons"], "Show item icons in tooltips")
	GUI:CreateSwitch(generalTooltipSection, "Tooltip.ShowIDs", L["Show Tooltip IDs"], "Display spell, item, and NPC IDs in tooltips for debugging")

	-- Appearance
	local appearanceTooltipSection = GUI:AddSection(tooltipCategory, L["Appearance"])
	GUI:CreateSwitch(appearanceTooltipSection, "Tooltip.ClassColor", L["Quality Color Border"], "Color tooltip borders based on item quality or unit class")
	GUI:CreateSwitch(appearanceTooltipSection, "Tooltip.FactionIcon", L["Show Faction Icon"], "Display faction icons for players in tooltips")
	GUI:CreateSwitch(appearanceTooltipSection, "Tooltip.HideJunkGuild", L["Abbreviate Guild Names"], "Shorten long guild names in tooltips")
	GUI:CreateSwitch(appearanceTooltipSection, "Tooltip.HideRank", L["Hide Guild Rank"], "Hide guild rank information in player tooltips")
	GUI:CreateSwitch(appearanceTooltipSection, "Tooltip.HideRealm", L["Show realm name by SHIFT"], "Only show realm names when holding Shift key")
	GUI:CreateSwitch(appearanceTooltipSection, "Tooltip.HideTitle", L["Hide Player Title"], "Hide player titles in tooltips")

	-- Tooltip Anchor
	local tooltipAnchorOptions = {
		{ text = "TOPLEFT", value = 1 },
		{ text = "TOPRIGHT", value = 2 },
		{ text = "BOTTOMLEFT", value = 3 },
		{ text = "BOTTOMRIGHT", value = 4 },
	}
	GUI:CreateDropdown(appearanceTooltipSection, "Tooltip.TipAnchor", L["Tooltip Anchor"], tooltipAnchorOptions, L["TooltipAnchor Desc"], UpdateTooltipAnchor)

	-- Advanced
	local advancedTooltipSection = GUI:AddSection(tooltipCategory, L["Advanced"] or "Advanced")
	GUI:CreateSwitch(advancedTooltipSection, "Tooltip.LFDRole", L["Show Roles Assigned Icon"], "Display role icons for players in group finder")
	GUI:CreateSwitch(advancedTooltipSection, "Tooltip.SpecLevelByShift", L["Show Spec/ItemLevel by SHIFT"], "Show specialization and item level when holding Shift")
	GUI:CreateSwitch(advancedTooltipSection, "Tooltip.TargetBy", L["Show Player Targeted By"], "Show who is targeting the player in tooltips")

	-- Follow Cursor
	local cursorModeOptions = {
		{ text = DISABLE, value = 1 },
		{ text = "LEFT", value = 2 },
		{ text = "TOP", value = 3 },
		{ text = "RIGHT", value = 4 },
	}
	GUI:CreateDropdown(advancedTooltipSection, "Tooltip.CursorMode", L["Follow Cursor"], cursorModeOptions, "Control when tooltips follow the mouse cursor", UpdateTooltipCursor)

	-- RaiderIO
	if not K.CheckAddOnState("RaiderIO") then
		local raiderIOSection = GUI:AddSection(tooltipCategory, L["RaiderIO"] or "RaiderIO")
		GUI:CreateSwitch(raiderIOSection, "Tooltip.MDScore", L["Show Mythic+ Rating"], L["Show Mythic+ Rating Desc"])
	end
end

-- Unitframe
local function CreateUnitframeCategory()
	local unitframeIcon = "Interface\\Icons\\Spell_Shadow_AntiShadow"
	local unitframeCategory = GUI:AddCategory(L["Unitframe"] or "Unitframe", unitframeIcon)

	local function UpdateUFTextScale()
		local unitframeModule = K:GetModule("Unitframes")
		if unitframeModule and unitframeModule.UpdateTextScale then
			unitframeModule:UpdateTextScale()
		end
	end

	local function UpdatePlayerBuffs()
		local unitframeModule = K:GetModule("Unitframes")
		if unitframeModule and unitframeModule.UpdatePlayerBuffs then
			unitframeModule:UpdatePlayerBuffs()
		end
	end

	local function UpdatePlayerDebuffs()
		local unitframeModule = K:GetModule("Unitframes")
		if unitframeModule and unitframeModule.UpdatePlayerDebuffs then
			unitframeModule:UpdatePlayerDebuffs()
		end
	end

	local function UpdateTargetBuffs()
		local unitframeModule = K:GetModule("Unitframes")
		if unitframeModule and unitframeModule.UpdateTargetBuffs then
			unitframeModule:UpdateTargetBuffs()
		end
	end

	local function UpdateTargetDebuffs()
		local unitframeModule = K:GetModule("Unitframes")
		if unitframeModule and unitframeModule.UpdateTargetDebuffs then
			unitframeModule:UpdateTargetDebuffs()
		end
	end

	local function UpdateUnitPlayerSize()
		local unitframeModule = K:GetModule("Unitframes")
		if unitframeModule and unitframeModule.UpdatePlayerSize then
			unitframeModule:UpdatePlayerSize()
		end
	end

	local function UpdateUnitTargetSize()
		local unitframeModule = K:GetModule("Unitframes")
		if unitframeModule and unitframeModule.UpdateTargetSize then
			unitframeModule:UpdateTargetSize()
		end
	end

	local function UpdateUnitFocusSize()
		local unitframeModule = K:GetModule("Unitframes")
		if unitframeModule and unitframeModule.UpdateFocusSize then
			unitframeModule:UpdateFocusSize()
		end
	end

	-- General
	local generalUnitframeSection = GUI:AddSection(unitframeCategory, GENERAL)
	GUI:CreateSwitch(generalUnitframeSection, "Unitframe.Enable", enableTextColor .. L["Enable Unitframes"], "Toggle the entire unitframe system on/off")
	GUI:CreateSwitch(generalUnitframeSection, "Unitframe.CastClassColor", L["Class Color Castbars"], "Color castbars based on the caster's class")
	GUI:CreateSwitch(generalUnitframeSection, "Unitframe.CastReactionColor", L["Reaction Color Castbars"], "Color castbars based on your reaction to the caster (friendly/hostile)")
	GUI:CreateSwitch(generalUnitframeSection, "Unitframe.ClassResources", L["Show Class Resources"], "Display class-specific resource bars (combo points, soul shards, etc.)")
	GUI:CreateSwitch(generalUnitframeSection, "Unitframe.DebuffHighlight", L["Show Health Debuff Highlight"], "Highlight health bars when affected by dispellable debuffs")
	GUI:CreateSwitch(generalUnitframeSection, "Unitframe.PvPIndicator", L["Show PvP Indicator on Player / Target"], "Display PvP status indicators on player and target frames")
	GUI:CreateSwitch(generalUnitframeSection, "Unitframe.Range", L["Unitframe Range Fading"], L["UnitframeRange Desc"], true)
	GUI:CreateSwitch(generalUnitframeSection, "Unitframe.ResurrectSound", L["Sound Played When You Are Resurrected"], "Play a sound effect when you are resurrected")
	GUI:CreateSwitch(generalUnitframeSection, "Unitframe.ShowHealPrediction", L["Show HealPrediction Statusbars"], "Show incoming heal predictions on health bars")
	GUI:CreateSwitch(generalUnitframeSection, "Unitframe.Smooth", L["Smooth Bars"], "Enable smooth animations for health and power bar changes")
	GUI:CreateSwitch(generalUnitframeSection, "Unitframe.Stagger", L["Show |CFF00FF96Monk|r Stagger Bar"], "Display the stagger bar for Monk tanks")
	GUI:CreateSlider(generalUnitframeSection, "Unitframe.AllTextScale", L["(TEST) Scale All Unitframe Texts"], 0.8, 1.5, 0.05, L["AllTextScale Desc"], UpdateUFTextScale)

	-- Combat Text
	local combatTextSection = GUI:AddSection(unitframeCategory, L["Combat Text"])
	GUI:CreateSwitch(combatTextSection, "Unitframe.CombatText", enableTextColor .. L["Enable Simple CombatText"], "Enable floating combat text display")
	GUI:CreateSwitch(combatTextSection, "Unitframe.AutoAttack", L["Show AutoAttack Damage"], "Display auto-attack damage in combat text")
	GUI:CreateSwitch(combatTextSection, "Unitframe.FCTOverHealing", L["Show Full OverHealing"], "Show full overhealing amounts in combat text")
	GUI:CreateSwitch(combatTextSection, "Unitframe.HotsDots", L["Show Hots and Dots"], "Display heal over time and damage over time effects")
	GUI:CreateSwitch(combatTextSection, "Unitframe.PetCombatText", L["Pet's Healing/Damage"], "Show combat text for pet damage and healing")

	-- Player - General
	local playerGeneralSection = GUI:AddSection(unitframeCategory, PLAYER .. " - General")
	GUI:CreateSwitch(playerGeneralSection, "Unitframe.AdditionalPower", L["Show Additional Mana Power (|CFFFF7D0ADruid|r, |CFFFFFFFFPriest|r, |CFF0070DEShaman|r)"], "Display additional power bars for classes that use multiple resources")
	GUI:CreateSwitch(playerGeneralSection, "Unitframe.ShowPlayerLevel", L["Show Player Frame Level"], "Display player level on the player frame")

	-- Player - Auras
	local playerAurasSection = GUI:AddSection(unitframeCategory, PLAYER .. " - Auras")
	GUI:CreateSwitch(playerAurasSection, "Unitframe.PlayerBuffs", L["Show Player Frame Buffs"], "Display buffs on the player frame")
	GUI:CreateSwitch(playerAurasSection, "Unitframe.PlayerDebuffs", L["Show Player Frame Debuffs"], "Display debuffs on the player frame")
	GUI:CreateSlider(playerAurasSection, "Unitframe.PlayerBuffsPerRow", L["Number of Buffs Per Row"], 4, 10, 1, "Number of buff icons per row on player frame", UpdatePlayerBuffs)
	GUI:CreateSlider(playerAurasSection, "Unitframe.PlayerDebuffsPerRow", L["Number of Debuffs Per Row"], 4, 10, 1, "Number of debuff icons per row on player frame", UpdatePlayerDebuffs)

	-- Player - Castbar
	local playerCastbarSection = GUI:AddSection(unitframeCategory, PLAYER .. " - Castbar")
	GUI:CreateSwitch(playerCastbarSection, "Unitframe.PlayerCastbar", L["Enable Player CastBar"], "Enable the player castbar")
	GUI:CreateSwitch(playerCastbarSection, "Unitframe.PlayerCastbarIcon", L["Enable Player CastBar"] .. " Icon", "Show spell icons on the player castbar")
	GUI:CreateSwitch(playerCastbarSection, "Unitframe.CastbarLatency", L["Show Castbar Latency"], "Display latency compensation on the player castbar")
	GUI:CreateSwitch(playerCastbarSection, "Unitframe.GlobalCooldown", L["Show Global Cooldown Spark"], L["GlobalCooldownSpark Desc"])
	GUI:CreateSlider(playerCastbarSection, "Unitframe.PlayerCastbarHeight", L["Player Castbar Height"], 20, 40, 1, "Height of the player castbar")
	GUI:CreateSlider(playerCastbarSection, "Unitframe.PlayerCastbarWidth", L["Player Castbar Width"], 100, 800, 1, "Width of the player castbar")

	-- Player - Frame
	local playerFrameSection = GUI:AddSection(unitframeCategory, PLAYER .. " - Frame")
	GUI:CreateSlider(playerFrameSection, "Unitframe.PlayerHealthHeight", L["Player Frame Height"], 20, 75, 1, "Height of the player health bar", UpdateUnitPlayerSize)
	GUI:CreateSlider(playerFrameSection, "Unitframe.PlayerHealthWidth", L["Player Frame Width"], 100, 300, 1, "Width of the player frame", UpdateUnitPlayerSize)
	GUI:CreateSlider(playerFrameSection, "Unitframe.PlayerPowerHeight", L["Player Power Bar Height"], 10, 40, 1, L["PlayerPowerHeight Desc"], UpdateUnitPlayerSize)

	-- Player - Swing Bar
	local playerSwingSection = GUI:AddSection(unitframeCategory, PLAYER .. " - Swing Bar")
	GUI:CreateSwitch(playerSwingSection, "Unitframe.SwingBar", L["Unitframe Swingbar"], "Enable swing timer bar for melee attacks")
	GUI:CreateSwitch(playerSwingSection, "Unitframe.SwingTimer", L["Unitframe Swingbar Timer"], "Show timer text on the swing bar")
	GUI:CreateSwitch(playerSwingSection, "Unitframe.OffOnTop", L["Offhand timer on top"], L["OffOnTop Desc"])
	GUI:CreateSlider(playerSwingSection, "Unitframe.SwingWidth", L["Unitframe SwingBar Width"], 50, 1000, 1, L["SwingWidth Desc"])
	GUI:CreateSlider(playerSwingSection, "Unitframe.SwingHeight", L["Unitframe SwingBar Height"], 1, 50, 1, L["SwingHeight Desc"])

	-- Target
	local targetUnitframeSection = GUI:AddSection(unitframeCategory, TARGET)
	GUI:CreateSwitch(targetUnitframeSection, "Unitframe.OnlyShowPlayerDebuff", L["Only Show Your Debuffs"], "Only display debuffs that you applied to the target")
	GUI:CreateSwitch(targetUnitframeSection, "Unitframe.TargetBuffs", L["Show Target Frame Buffs"], "Display buffs on the target frame")
	GUI:CreateSwitch(targetUnitframeSection, "Unitframe.TargetCastbar", L["Enable Target CastBar"], "Enable the target castbar")
	GUI:CreateSwitch(targetUnitframeSection, "Unitframe.TargetCastbarIcon", L["Enable Target CastBar"] .. " Icon", "Show spell icons on the target castbar")
	GUI:CreateSwitch(targetUnitframeSection, "Unitframe.TargetDebuffs", L["Show Target Frame Debuffs"], "Display debuffs on the target frame")

	-- Target Frame Sizing
	GUI:CreateSlider(targetUnitframeSection, "Unitframe.TargetBuffsPerRow", L["Number of Buffs Per Row"], 4, 10, 1, "Number of buff icons per row on target frame", UpdateTargetBuffs)
	GUI:CreateSlider(targetUnitframeSection, "Unitframe.TargetDebuffsPerRow", L["Number of Debuffs Per Row"], 4, 10, 1, "Number of debuff icons per row on target frame", UpdateTargetDebuffs)
	GUI:CreateSlider(targetUnitframeSection, "Unitframe.TargetPowerHeight", "Target Power Bar Height", 10, 40, 1, "Height of the target power bar", UpdateUnitTargetSize)
	GUI:CreateSlider(targetUnitframeSection, "Unitframe.TargetHealthHeight", L["Target Frame Height"], 20, 75, 1, "Height of the target health bar", UpdateUnitTargetSize)
	GUI:CreateSlider(targetUnitframeSection, "Unitframe.TargetHealthWidth", L["Target Frame Width"], 100, 300, 1, "Width of the target frame", UpdateUnitTargetSize)
	GUI:CreateSlider(targetUnitframeSection, "Unitframe.TargetCastbarHeight", L["Target Castbar Height"], 20, 40, 1, "Height of the target castbar")
	GUI:CreateSlider(targetUnitframeSection, "Unitframe.TargetCastbarWidth", L["Target Castbar Width"], 100, 800, 1, "Width of the target castbar")

	-- Pet
	local petUnitframeSection = GUI:AddSection(unitframeCategory, PET)
	GUI:CreateSwitch(petUnitframeSection, "Unitframe.HidePet", "Hide Pet Frame", "Hide the pet frame completely")
	GUI:CreateSwitch(petUnitframeSection, "Unitframe.HidePetLevel", L["Hide Pet Level"], "Hide level text on the pet frame")
	GUI:CreateSwitch(petUnitframeSection, "Unitframe.HidePetName", L["Hide Pet Name"], "Hide name text on the pet frame")
	GUI:CreateSlider(petUnitframeSection, "Unitframe.PetHealthHeight", L["Pet Frame Height"], 10, 50, 1, "Height of the pet health bar")
	GUI:CreateSlider(petUnitframeSection, "Unitframe.PetHealthWidth", L["Pet Frame Width"], 80, 300, 1, "Width of the pet frame")
	GUI:CreateSlider(petUnitframeSection, "Unitframe.PetPowerHeight", L["Pet Power Bar"], 10, 50, 1, "Height of the pet power bar")

	-- Target Of Target
	local totUnitframeSection = GUI:AddSection(unitframeCategory, L["Target Of Target"])
	GUI:CreateSwitch(totUnitframeSection, "Unitframe.HideTargetofTarget", L["Hide TargetofTarget Frame"], "Hide the target of target frame")
	GUI:CreateSwitch(totUnitframeSection, "Unitframe.HideTargetOfTargetLevel", L["Hide TargetofTarget Level"], "Hide level text on the target of target frame")
	GUI:CreateSwitch(totUnitframeSection, "Unitframe.HideTargetOfTargetName", L["Hide TargetofTarget Name"], "Hide name text on the target of target frame")
	GUI:CreateSlider(totUnitframeSection, "Unitframe.TargetTargetHealthHeight", L["Target of Target Frame Height"], 10, 50, 1, "Height of the target of target health bar")
	GUI:CreateSlider(totUnitframeSection, "Unitframe.TargetTargetHealthWidth", L["Target of Target Frame Width"], 80, 300, 1, "Width of the target of target frame")
	GUI:CreateSlider(totUnitframeSection, "Unitframe.TargetTargetPowerHeight", L["Target of Target Power Height"], 10, 50, 1, L["TargetTargetPowerHeight Desc"])

	-- Focus
	local focusUnitframeSection = GUI:AddSection(unitframeCategory, FOCUS)
	GUI:CreateSwitch(focusUnitframeSection, "Unitframe.FocusBuffs", L["Show Focus Frame Buffs"], L["FocusBuffs Desc"])
	GUI:CreateSwitch(focusUnitframeSection, "Unitframe.FocusCastbar", L["Enable Focus CastBar"], L["FocusCastbar Desc"])
	GUI:CreateSwitch(focusUnitframeSection, "Unitframe.FocusCastbarIcon", L["Enable Focus CastBar Icon"], L["FocusCastbarIcon Desc"])
	GUI:CreateSwitch(focusUnitframeSection, "Unitframe.FocusDebuffs", L["Show Focus Frame Debuffs"], L["FocusDebuffs Desc"])
	GUI:CreateSlider(focusUnitframeSection, "Unitframe.FocusPowerHeight", L["Focus Power Bar Height"], 10, 40, 1, L["FocusPowerHeight Desc"], UpdateUnitFocusSize)
	GUI:CreateSlider(focusUnitframeSection, "Unitframe.FocusHealthHeight", L["Focus Frame Height"], 20, 75, 1, "Height of the focus health bar", UpdateUnitFocusSize)
	GUI:CreateSlider(focusUnitframeSection, "Unitframe.FocusHealthWidth", L["Focus Frame Width"], 100, 300, 1, "Width of the focus frame", UpdateUnitFocusSize)

	-- Focus Target
	local focusTargetSection = GUI:AddSection(unitframeCategory, "Focus Target")
	GUI:CreateSwitch(focusTargetSection, "Unitframe.HideFocusTarget", "Hide Focus Target Frame", "Hide the focus target frame")
	GUI:CreateSwitch(focusTargetSection, "Unitframe.HideFocusTargetLevel", "Hide Focus Target Level", "Hide level text on the focus target frame")
	GUI:CreateSwitch(focusTargetSection, "Unitframe.HideFocusTargetName", "Hide Focus Target Name", "Hide name text on the focus target frame")
	GUI:CreateSlider(focusTargetSection, "Unitframe.FocusTargetHealthHeight", "Focus Target Frame Height", 10, 50, 1, "Height of the focus target health bar")
	GUI:CreateSlider(focusTargetSection, "Unitframe.FocusTargetHealthWidth", "Focus Target Frame Width", 80, 300, 1, "Width of the focus target frame")
	GUI:CreateSlider(focusTargetSection, "Unitframe.FocusTargetPowerHeight", "Focus Target Power Height", 10, 50, 1, "Height of the focus target power bar")

	-- Unitframe Misc
	local miscUnitframeSection = GUI:AddSection(unitframeCategory, "Unitframe Misc")

	-- Health Color Format
	local healthColorOptions = {
		{ text = "Class", value = 1 },
		{ text = "Dark", value = 2 },
		{ text = "Value", value = 3 },
	}
	GUI:CreateDropdown(miscUnitframeSection, "Unitframe.HealthbarColor", L["Health Color Format"], healthColorOptions, "Choose how health bars are colored across all unitframes")

	-- Portrait Style
	local portraitStyleOptions = {
		{ text = "No Portraits", value = 0 },
		{ text = "Default Portraits", value = 1 },
		{ text = "Class Portraits", value = 2 },
		{ text = "New Class Portraits", value = 3 },
		{ text = "Overlay Portrait", value = 4 },
		{ text = "3D Portraits", value = 5 },
	}
	GUI:CreateDropdown(miscUnitframeSection, "Unitframe.PortraitStyle", L["Unitframe Portrait Style"], portraitStyleOptions, "Choose the portrait style for unitframes. Note: 3D portraits may cause FPS drops")
end

-- WorldMap
local function CreateWorldMapCategory()
	local worldMapIcon = "Interface\\Icons\\Icon_treasuremap"
	local worldMapCategory = GUI:AddCategory(L["WorldMap"] or "WorldMap", worldMapIcon)

	local function UpdateMapFading()
		local worldMapModule = K:GetModule("WorldMap")
		if worldMapModule and worldMapModule.UpdateMapFading then
			worldMapModule:UpdateMapFading()
		end
	end

	local function UpdateMapSize()
		local worldMapModule = K:GetModule("WorldMap")
		if worldMapModule and worldMapModule.UpdateMapSize then
			worldMapModule:UpdateMapSize()
		end
	end

	local function UpdateMapReveal()
		local worldMapModule = K:GetModule("WorldMap")
		if worldMapModule and worldMapModule.UpdateMapReveal then
			worldMapModule:UpdateMapReveal()
		end
	end

	-- General
	local generalWorldMapSection = GUI:AddSection(worldMapCategory, GENERAL)
	GUI:CreateSwitch(generalWorldMapSection, "WorldMap.Coordinates", L["Show Player/Mouse Coordinates"], "Display player and mouse coordinates on the world map")
	GUI:CreateSwitch(generalWorldMapSection, "WorldMap.FadeWhenMoving", L["Fade Worldmap When Moving"], "Make the world map fade out when your character is moving", UpdateMapFading)
	GUI:CreateSwitch(generalWorldMapSection, "WorldMap.SmallWorldMap", L["Show Smaller Worldmap"], "Use a smaller, more compact world map size", UpdateMapSize)

	-- WorldMap Reveal
	local revealWorldMapSection = GUI:AddSection(worldMapCategory, "WorldMap Reveal")
	GUI:CreateSwitch(revealWorldMapSection, "WorldMap.MapRevealGlow", L["Map Reveal Shadow"], L["MapRevealTip"], UpdateMapReveal)

	-- Sizes
	local sizesWorldMapSection = GUI:AddSection(worldMapCategory, L["Sizes"])
	GUI:CreateSlider(sizesWorldMapSection, "WorldMap.AlphaWhenMoving", L["Alpha When Moving"], 0.1, 1, 0.01, "Set the transparency level when the world map fades during movement", UpdateMapFading)
end

-- Credits
local function CreateCreditsCategory()
	local creditsCategory = GUI:AddCategory(L["Credits"] or "Credits", "Interface\\Icons\\Achievement_General")
	local contributorsSection = GUI:AddSection(creditsCategory, "KkthnxUI Contributors & Community")

	if GUI.CreateCredits then
		GUI:CreateCredits(contributorsSection, {
			{ name = "Aftermathh" },
			{ name = "Alteredcross", class = "ROGUE" },
			{ name = "Alza" },
			{ name = "Azilroka", class = "SHAMAN" },
			{ name = "Benik", color = "|cff00c0fa" }, -- Custom blue color
			{ name = "Blazeflack" },
			{ name = "Caellian" },
			{ name = "Caith" },
			{ name = "Cassamarra", class = "HUNTER" },
			{ name = "Darth Predator" },
			{ name = "Elv" },
			{ name = "|cffe31c73Faffi|r|cfffc4796GS|r", class = "PRIEST" }, -- Custom colored name
			{ name = "Goldpaw", class = "DRUID" },
			{ name = "Haleth" },
			{ name = "Haste" },
			{ name = "Hungtar" },
			{ name = "Hydra" },
			{ name = "Ishtara" },
			{ name = "LightSpark" },
			{ name = "Magicnachos", class = "PRIEST" },
			{ name = "Merathilis", class = "DRUID" },
			{ name = "moerf", class = "WARLOCK" },
			{ name = "Nightcracker" },
			{ name = "P3lim" },
			{ name = "Palooza", class = "PRIEST" },
			{ name = "Rav99", class = "DEMONHUNTER" },
			{ name = "Roth" },
			{ name = "Shestak" },
			{ name = "|cff49CAF5S|r|cff80C661i|r|cffFFF461m|r|cffF6885Fp|r|cffCD84B9y|r" }, -- Simpy's rainbow colors: Turquoise, Sea Green, Khaki, Salmon, Orchid
			{ name = "siweia" },
		}, "Community Contributors & Supporters")
	end

	-- Special Recognition
	local specialSection = GUI:AddSection(creditsCategory, "Special Recognition")

	if GUI.CreateCredits then
		GUI:CreateCredits(specialSection, {
			{ name = "All Beta Testers", color = { 0.8, 0.8, 1, 1 } },
			{ name = "Discord Community", color = { 0.4, 0.6, 1, 1 } },
			{ name = "GitHub Contributors", color = { 0.2, 0.8, 0.2, 1 } },
		}, "Special Thanks")
	end

	-- Message
	local messageSection = GUI:AddSection(creditsCategory, "Forever Grateful - A Journey Together")
	if GUI.CreateCredits then
		GUI:CreateCredits(messageSection, {
			{ name = "To everyone who has supported KkthnxUI since the WOTLK days...", color = { 1, 0.9, 0.7, 1 } },
			{ name = "" },
			{ name = "None of this would be possible without the incredible people", color = { 0.9, 0.9, 0.9, 1 } },
			{ name = "who have stood behind me, believed in this project, and", color = { 0.9, 0.9, 0.9, 1 } },
			{ name = "stuck with me through every expansion, every challenge,", color = { 0.9, 0.9, 0.9, 1 } },
			{ name = "and every moment of doubt.", color = { 0.9, 0.9, 0.9, 1 } },
			{ name = "" },
			{ name = "From those late nights in Northrend to the epic battles", color = { 0.8, 0.9, 1, 1 } },
			{ name = "in the Shadowlands and beyond, you've been there.", color = { 0.8, 0.9, 1, 1 } },
			{ name = "Through bug reports, feature requests, kind words,", color = { 0.8, 0.9, 1, 1 } },
			{ name = "and unwavering loyalty - you made this journey possible.", color = { 0.8, 0.9, 1, 1 } },
			{ name = "" },
			{ name = "Your feedback shaped every feature. Your patience", color = { 1, 0.8, 0.9, 1 } },
			{ name = "carried me through every setback. Your enthusiasm", color = { 1, 0.8, 0.9, 1 } },
			{ name = "fueled every late-night coding session.", color = { 1, 0.8, 0.9, 1 } },
			{ name = "" },
			{ name = "KkthnxUI isn't just an addon - it's a community,", color = { 0.9, 1, 0.8, 1 } },
			{ name = "a family built over years of shared adventures.", color = { 0.9, 1, 0.8, 1 } },
			{ name = "Every line of code carries the spirit of everyone", color = { 0.9, 1, 0.8, 1 } },
			{ name = "who believed this crazy dream could become reality.", color = { 0.9, 1, 0.8, 1 } },
			{ name = "" },
			{ name = "From the bottom of my heart, thank you.", color = { 1, 0.7, 0.7, 1 } },
			{ name = "For your trust. For your friendship. For your support.", color = { 1, 0.7, 0.7, 1 } },
			{ name = "For making this journey more than I ever imagined.", color = { 1, 0.7, 0.7, 1 } },
			{ name = "" },
			{ name = "Here's to many more years of adventure together!", color = { 1, 0.9, 0.5, 1 } },
			{ name = "" },
			{ name = "With endless gratitude and love,", color = { 0.9, 0.8, 1, 1 } },
			{ name = "Kkthnx", color = { 1, 0.6, 0.6, 1 }, atlas = "GarrisonTroops-Health" },
		}, "")
	end
end

-- Initialize All Categories
CreateActionBarsCategory()
CreateAnnouncementsCategory()
CreateArenaCategory()
CreateAuraWatchCategory()
CreateAurasCategory()
CreateAutomationCategory()
CreateBossCategory()
CreateChatCategory()
CreateDataTextCategory()
CreateGeneralCategory()
CreateInventoryCategory()
CreateLootCategory()
CreateMinimapCategory()
CreateMiscCategory()
CreateNameplateCategory()
CreatePartyCategory()
CreateSimplePartyCategory()
CreateRaidCategory()
CreateSkinsCategory()
CreateTooltipCategory()
CreateUnitframeCategory()
CreateWorldMapCategory()
-- Credits are always last!
CreateCreditsCategory()
