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
	print("|cffff0000KkthnxUI Error:|r " .. (L["NewGUI not initialized yet!"]))
	return
end

-- Action Bars
local function CreateActionBarsCategory()
	local actionBarCategory = GUI:AddCategory(L["Action Bars"], "Interface\\Icons\\INV_Misc_GroupLooking")

	-- ActionBar 1
	local bar1Section = GUI:AddSection(actionBarCategory, L["ActionBar 1"])
	GUI:CreateSwitch(bar1Section, "ActionBar.Bar1", enableTextColor .. L["Enable ActionBar"] .. " 1", L["Bar1 Desc"])

	-- ActionBar 2
	local bar2Section = GUI:AddSection(actionBarCategory, L["ActionBar 2"])
	GUI:CreateSwitch(bar2Section, "ActionBar.Bar2", enableTextColor .. L["Enable ActionBar"] .. " 2", L["Bar2 Desc"])

	-- ActionBar 3
	local bar3Section = GUI:AddSection(actionBarCategory, L["ActionBar 3"])
	GUI:CreateSwitch(bar3Section, "ActionBar.Bar3", enableTextColor .. L["Enable ActionBar"] .. " 3", L["Bar3 Desc"])

	-- ActionBar 4
	local bar4Section = GUI:AddSection(actionBarCategory, L["ActionBar 4"])
	GUI:CreateSwitch(bar4Section, "ActionBar.Bar4", enableTextColor .. L["Enable ActionBar"] .. " 4", L["Bar4 Desc"])

	-- ActionBar 5
	local bar5Section = GUI:AddSection(actionBarCategory, L["ActionBar 5"])
	GUI:CreateSwitch(bar5Section, "ActionBar.Bar5", enableTextColor .. L["Enable ActionBar"] .. " 5", L["Bar5 Desc"])

	-- ActionBar 6
	local bar6Section = GUI:AddSection(actionBarCategory, L["ActionBar 6"])
	GUI:CreateSwitch(bar6Section, "ActionBar.Bar6", enableTextColor .. L["Enable ActionBar"] .. " 6", L["Bar6 Desc"])

	-- ActionBar 7
	local bar7Section = GUI:AddSection(actionBarCategory, L["ActionBar 7"])
	GUI:CreateSwitch(bar7Section, "ActionBar.Bar7", enableTextColor .. L["Enable ActionBar"] .. " 7", L["Bar7 Desc"])

	-- ActionBar 8
	local bar8Section = GUI:AddSection(actionBarCategory, L["ActionBar 8"])
	GUI:CreateSwitch(bar8Section, "ActionBar.Bar8", enableTextColor .. L["Enable ActionBar"] .. " 8", L["Bar8 Desc"])

	-- Pet Bar
	local petBarSection = GUI:AddSection(actionBarCategory, L["ActionBar Pet"])
	GUI:CreateSlider(petBarSection, "ActionBar.BarPetSize", L["Button Size"], 20, 80, 1, L["BarPetSize Desc"])
	GUI:CreateSlider(petBarSection, "ActionBar.BarPetPerRow", L["Button PerRow"], 1, 12, 1, L["BarPetPerRow Desc"])
	GUI:CreateSlider(petBarSection, "ActionBar.BarPetFont", L["Button FontSize"], 8, 20, 1, L["BarPetFont Desc"])
	GUI:CreateSwitch(petBarSection, "ActionBar.BarPetFade", L["Enable Fade for Pet Bar"], L["Allows the Pet Bar to fade based on the specified conditions"])

	-- Stance Bar
	local stanceBarSection = GUI:AddSection(actionBarCategory, L["ActionBar Stance"])
	GUI:CreateSwitch(stanceBarSection, "ActionBar.ShowStance", enableTextColor .. L["Enable StanceBar"], L["ShowStance Desc"])
	GUI:CreateSlider(stanceBarSection, "ActionBar.BarStanceSize", L["Button Size"], 20, 80, 1, L["BarStanceSize Desc"])
	GUI:CreateSlider(stanceBarSection, "ActionBar.BarStancePerRow", L["Button PerRow"], 1, 12, 1, L["BarStancePerRow Desc"])
	GUI:CreateSlider(stanceBarSection, "ActionBar.BarStanceFont", L["Button FontSize"], 8, 20, 1, L["BarStanceFont Desc"])
	GUI:CreateSwitch(stanceBarSection, "ActionBar.BarStanceFade", L["Enable Fade for Stance Bar"], L["Allows the Stance Bar to fade based on the specified conditions"])

	-- Vehicle Button
	local vehicleSection = GUI:AddSection(actionBarCategory, L["ActionBar Vehicle"])
	GUI:CreateSlider(vehicleSection, "ActionBar.VehButtonSize", L["Button Size"], 20, 80, 1, L["VehButtonSize Desc"])

	-- Toggles
	local togglesSection = GUI:AddSection(actionBarCategory, L["Toggles"])
	GUI:CreateSwitch(togglesSection, "ActionBar.EquipColor", L["Equip Color"], L["EquipColor Desc"])
	GUI:CreateSwitch(togglesSection, "ActionBar.Grid", L["Actionbar Grid"], L["Grid Desc"])
	GUI:CreateSwitch(togglesSection, "ActionBar.Hotkeys", L["Enable Hotkey"], L["Hotkeys Desc"])
	GUI:CreateSwitch(togglesSection, "ActionBar.Macro", L["Enable Macro"], L["Macro Desc"])
	GUI:CreateSwitch(togglesSection, "ActionBar.KeyDown", L["Cast on Key Press"], L["Cast spells and abilities on key press, not key release"])
	GUI:CreateSwitch(togglesSection, "ActionBar.ButtonLock", L["Lock Action Bars"], L["Keep your action bar layout locked in place to prevent accidental reordering. To move a spell or ability while locked, hold the Shift key."])
	GUI:CreateSwitch(togglesSection, "ActionBar.Cooldown", L["Show Cooldowns"], L["Cooldown Desc"])
	GUI:CreateSwitch(togglesSection, "ActionBar.MicroMenu", L["Enable MicroBar"], L["MicroMenu Desc"])
	GUI:CreateSwitch(togglesSection, "ActionBar.FadeMicroMenu", L["Mouseover MicroBar"], L["FadeMicroMenu Desc"])
	GUI:CreateSwitch(togglesSection, "ActionBar.OverrideWA", L["Enable OverrideWA"], L["OverrideWA Desc"])
	GUI:CreateSlider(togglesSection, "ActionBar.MmssTH", L["MMSSThreshold"], 60, 600, 1, L["MMSSThresholdTip"])
	GUI:CreateSlider(togglesSection, "ActionBar.TenthTH", L["TenthThreshold"], 0, 60, 1, L["TenthThresholdTip"])

	-- Fader Options
	local faderSection = GUI:AddSection(actionBarCategory, L["Fader Options"])
	GUI:CreateSwitch(faderSection, "ActionBar.BarFadeGlobal", L["Enable Global Fade"], L["BarFadeGlobal Desc"])
	GUI:CreateSlider(faderSection, "ActionBar.BarFadeAlpha", L["Fade Alpha"], 0, 1, 0.1, L["BarFadeAlpha Desc"])
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
	GUI:CreateSwitch(generalAnnouncementsSection, "Announcements.ItemAlert", L["Announce Spells And Items"], L["Announcements.ItemAlert Desc"])
	GUI:CreateSwitch(generalAnnouncementsSection, "Announcements.PullCountdown", L["Announce Pull Countdown (/pc #)"], L["Announcements.PullCountdown Desc"])
	GUI:CreateSwitch(generalAnnouncementsSection, "Announcements.ResetInstance", L["Alert Group After Instance Resetting"], L["Announcements.ResetInstance Desc"])

	-- Combat
	local combatAnnouncementsSection = GUI:AddSection(announcementsCategory, L["Combat"])
	GUI:CreateSwitch(combatAnnouncementsSection, "Announcements.HealthAlert", L["Announce When Low On Health"], L["Announcements.HealthAlert Desc"])
	GUI:CreateSwitch(combatAnnouncementsSection, "Announcements.KeystoneAlert", L["Announce When New Mythic Key Is Obtained"], L["Notifies you and your group when you receive a new Mythic+ keystone."])

	-- Quest Notifier
	local questNotifierSection = GUI:AddSection(announcementsCategory, L["QuestNotifier"])
	GUI:CreateSwitch(questNotifierSection, "Announcements.QuestNotifier", enableTextColor .. L["Enable QuestNotifier"], L["QuestNotifier Desc"])
	GUI:CreateSwitch(questNotifierSection, "Announcements.OnlyCompleteRing", L["Only Play Complete Quest Sound"], L["Announcements.OnlyCompleteRing Desc"])
	GUI:CreateSwitch(questNotifierSection, "Announcements.QuestProgress", L["Alert QuestProgress In Chat"], L["Announcements.QuestProgress Desc"])
	GUI:CreateSwitch(questNotifierSection, "Announcements.AnnounceWorldQuests", L["Announce World Quests"], L["AnnounceWorldQuests Desc"])
	GUI:CreateSlider(questNotifierSection, "Announcements.QuestProgressEveryNth", L["Quest Progress: Announce Every N Updates"], 1, 5, 1, L["QuestProgressEveryNth Desc"])

	-- Rare Alert
	local rareAlertSection = GUI:AddSection(announcementsCategory, L["Rare Alert"])
	GUI:CreateSwitch(rareAlertSection, "Announcements.RareAlert", enableTextColor .. L["Enable Event & Rare Alerts"], "Enables alerts for nearby rare creatures and events.")
	GUI:CreateSwitch(rareAlertSection, "Announcements.AlertOnlyInWorld", L["Don't Alert In Instances"], L["Announcements.AlertOnlyInWorld Desc"])
	GUI:CreateSwitch(rareAlertSection, "Announcements.AlertInChat", L["Print Alerts In Chat"], L["Announcements.AlertInChat Desc"])
	GUI:CreateSwitch(rareAlertSection, "Announcements.RareAlertSound", L["Rare Alert Sound"], L["Announcements.RareAlertSound Desc"])
	GUI:CreateSwitch(rareAlertSection, "Announcements.RareAlertSoundInBackground", L["Rare Alert Sound In Background"], L["Announcements.RareAlertSoundInBackground Desc"])
	GUI:CreateSwitch(rareAlertSection, "Announcements.RareAlertPopup", L["Rare Alert Popup"], L["Announcements.RareAlertPopup Desc"])
	GUI:CreateSwitch(rareAlertSection, "Announcements.RareAlertClickToTarget", L["Rare Alert Click To Target"], L["Announcements.RareAlertClickToTarget Desc"])
end

-- Arena
local function CreateArenaCategory()
	local arenaCategory = GUI:AddCategory(L["Arena"], "Interface\\Icons\\Achievement_Arena_2v2_7")

	-- General
	local generalArenaSection = GUI:AddSection(arenaCategory, GENERAL)
	GUI:CreateSwitch(generalArenaSection, "Arena.Enable", enableTextColor .. L["Enable Arena"], "Toggle Arena Module On/Off")
	GUI:CreateSwitch(generalArenaSection, "Arena.Castbars", L["Show Castbars"], L["Arena.Castbars Desc"])
	GUI:CreateSwitch(generalArenaSection, "Arena.CastbarIcon", L["Show Castbars Icon"], L["Arena CastbarIcon Desc"])
	GUI:CreateSwitch(generalArenaSection, "Arena.Smooth", L["Smooth Bar Transition"], L["Arena.Smooth Desc"])

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
	GUI:CreateDropdown(arenaColorsSection, "Arena.HealthbarColor", L["Health Color Format"], healthColorOptions, L["Arena.HealthbarColor Desc"])
end

-- Auras
local function CreateAurasCategory()
	local aurasCategory = GUI:AddCategory(L["Auras"], "Interface\\Icons\\Spell_Magic_LesserInvisibilty")

	-- General
	local generalAurasSection = GUI:AddSection(aurasCategory, GENERAL)
	GUI:CreateSwitch(generalAurasSection, "Auras.Enable", enableTextColor .. L["Enable Auras"], L["Enable Desc"])
	GUI:CreateSwitch(generalAurasSection, "Auras.HideBlizBuff", L["Hide The Default BuffFrame"], L["HideBlizBuff Desc"])
	GUI:CreateSwitch(generalAurasSection, "Auras.Reminder", L["Auras Reminder (Shout/Intellect/Poison)"], L["Reminder Desc"])
	local reminderGlow = GUI:CreateSwitch(generalAurasSection, "Auras.ReminderGlow", L["Reminder Glow"], L["Reminder Glow Desc"])
	GUI:DependsOn(reminderGlow, "Auras.Reminder", true)
	GUI:CreateSwitch(generalAurasSection, "Auras.ReverseBuffs", L["Buffs Grow Right"], L["ReverseBuffs Desc"])
	GUI:CreateSwitch(generalAurasSection, "Auras.ReverseDebuffs", L["Debuffs Grow Right"], L["Auras.ReverseDebuffs Desc"])

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
	local category = GUI:AddCategory(L["Automation"], automationIcon)

	-- Invite
	local inviteSection = GUI:AddSection(category, L["Invite Management"])

	GUI:CreateSwitch(inviteSection, "Automation.AutoInvite", L["Accept Invites From Friends & Guild Members"], L["AutoInvite Desc"])
	GUI:CreateSwitch(inviteSection, "Automation.AutoDeclineGuildInvites", L["Decline Guild Invites From Strangers"], L["AutoDeclineGuildInvites Desc"])
	GUI:CreateSwitch(inviteSection, "Automation.AutoDeclineDuels", L["Decline PvP Duels"], L["AutoDeclineDuels Desc"])
	GUI:CreateSwitch(inviteSection, "Automation.AutoDeclinePetDuels", L["Decline Pet Duels"], L["AutoDeclinePetDuels Desc"])
	GUI:CreateSwitch(inviteSection, "Automation.AutoPartySync", L["Accept PartySync From Friends & Guild Members"], L["AutoPartySync Desc"])
	GUI:CreateButtonWidget(inviteSection, "Automation.ManageWhisperInvite", L["Auto Accept Invite Keyword"], L["Open GUI"], L["WhisperInvite Desc"], function()
		if K.ExtraGUI and K.ExtraGUI.ToggleExtraConfig then
			K.ExtraGUI:ToggleExtraConfig("Automation.WhisperInvite", L["Auto Accept Invite Keyword"])
		end
	end)

	-- Auto-Resurrect
	local resurrectSection = GUI:AddSection(category, L["Auto-Resurrect Options"])
	GUI:CreateSwitch(resurrectSection, "Automation.AutoResurrect", L["Auto Accept Resurrect Requests"], L["AutoResurrect Desc"])
	GUI:CreateSwitch(resurrectSection, "Automation.AutoResurrectThank", L["Say 'Thank You' When Resurrected"], L["AutoResurrectThank Desc"])

	-- Auto-Reward
	local rewardSection = GUI:AddSection(category, L["Auto-Reward Options"])
	GUI:CreateSwitch(rewardSection, "Automation.AutoReward", L["Auto Select Quest Rewards Best Value"], L["AutoReward Desc"])
	GUI:CreateSwitch(rewardSection, "Automation.AutoShareQuest", L["Auto Share Accepted Quests"], L["AutoShareQuest Desc"])

	-- Miscellaneous
	local miscSection = GUI:AddSection(category, L["Miscellaneous Options"])
	GUI:CreateSwitch(miscSection, "Automation.AutoDelves", L["Auto Accept Delve Powers"], L["AutoDelves Desc"])
	GUI:CreateSwitch(miscSection, "Automation.AutoGoodbye", L["Say Goodbye After Dungeon Completion"], L["AutoGoodbye Desc"])
	GUI:CreateSwitch(miscSection, "Automation.AutoKeystone", L["Auto Place Mythic Keystones"], L["AutoKeystone Desc"])
	GUI:CreateSwitch(miscSection, "Automation.AutoRelease", L["Auto Release in Battlegrounds & Arenas"], L["AutoRelease Desc"])
	GUI:CreateSwitch(miscSection, "Automation.AutoScreenshot", L["Auto Screenshot Achievements"], L["AutoScreenshot Desc"])
	GUI:CreateSwitch(miscSection, "Automation.AutoSetRole", L["Auto Set Your Role In Groups"], L["AutoSetRole Desc"])
	GUI:CreateSwitch(miscSection, "Automation.ConfirmCinematicSkip", L["Quick Skip Cinematics (Key Press)"], L["ConfirmCinematicSkip Desc"])
	GUI:CreateSwitch(miscSection, "Automation.AutoSummon", L["Auto Accept Summon Requests"], L["AutoSummon Desc"])
	GUI:CreateSwitch(miscSection, "Automation.NoBadBuffs", L["Automatically Remove Annoying Buffs"], L["NoBadBuffs Desc"])

	-- Auto-Quest
	local listsSection = GUI:AddSection(category, L["Auto-Quest Lists"])
	GUI:CreateSwitch(listsSection, "Automation.AutoQuestAcceptRegular", L["Accept Regular Quests"], L["Automation.AutoQuestAcceptRegular Desc"])
	GUI:CreateSwitch(listsSection, "Automation.AutoQuestAcceptDaily", L["Accept Daily Quests"], L["Automation.AutoQuestAcceptDaily Desc"])
	GUI:CreateSwitch(listsSection, "Automation.AutoQuestAcceptWeekly", L["Accept Weekly Quests"], L["Automation.AutoQuestAcceptWeekly Desc"])
	GUI:CreateSwitch(listsSection, "Automation.AutoQuestProtectTurnIns", L["Protect Costly Quest Turn-Ins"], L["Automation.AutoQuestProtectTurnIns Desc"])
	GUI:CreateButtonWidget(listsSection, "Automation.ManageAutoQuestIgnore", L["Auto-Quest Ignore NPCs"], L["Open"], L["Automation.ManageAutoQuestIgnore Desc"], function()
		if K.ExtraGUI and K.ExtraGUI.ToggleExtraConfig then
			K.ExtraGUI:ToggleExtraConfig("Automation.AutoQuestIgnoreNPC", L["Auto-Quest Ignore NPCs"])
		end
	end)
end

-- Boss
local function CreateBossCategory()
	local bossIcon = "Interface\\Icons\\Achievement_boss_illidan"
	local bossCategory = GUI:AddCategory(L["Boss"], bossIcon)

	-- General
	local generalBossSection = GUI:AddSection(bossCategory, GENERAL)
	GUI:CreateSwitch(generalBossSection, "Boss.Enable", enableTextColor .. L["Enable Boss"], "Toggle Boss Module On/Off")
	GUI:CreateSwitch(generalBossSection, "Boss.Castbars", L["Show Castbars"], L["Boss.Castbars Desc"])
	GUI:CreateSwitch(generalBossSection, "Boss.CastbarIcon", L["Show Castbars Icon"], L["Boss CastbarIcon Desc"])
	GUI:CreateSwitch(generalBossSection, "Boss.Smooth", L["Smooth Bar Transition"], L["Boss.Smooth Desc"])

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
	GUI:CreateDropdown(bossColorsSection, "Boss.HealthbarColor", L["Health Color Format"], healthColorOptions, L["Boss.HealthbarColor Desc"])
end

-- Chat
local function CreateChatCategory()
	local chatIcon = "Interface\\Icons\\Ui_chat"
	local chatCategory = GUI:AddCategory(L["Chat"], chatIcon)

	-- General
	local generalChatSection = GUI:AddSection(chatCategory, GENERAL)
	GUI:CreateSwitch(generalChatSection, "Chat.Enable", enableTextColor .. L["Enable Chat"], L["Enable Desc"])
	GUI:CreateSwitch(generalChatSection, "Chat.Lock", L["Lock Chat"], L["Lock Desc"])
	GUI:CreateSwitch(generalChatSection, "Chat.Background", L["Show Chat Background"], L["Background Desc"])
	local channelAbbrOptions = {
		{ text = DISABLE, value = 1 },
		{ text = L["Short Names"], value = 2 },
		{ text = L["Localized Short Names"], value = 3 },
	}
	GUI:CreateDropdown(generalChatSection, "Chat.ChannelAbbr", L["Channel Abbreviations"], channelAbbrOptions, L["ChannelAbbr Desc"])

	-- Appearance
	local appearanceChatSection = GUI:AddSection(chatCategory, L["Appearance"])
	GUI:CreateSwitch(appearanceChatSection, "Chat.Emojis", L["Show Emojis In Chat"] .. " |TInterface\\Addons\\KkthnxUI\\Media\\Chat\\Emojis\\StuckOutTongueClosedEyes:0:0:4|t", L["Emojis Desc"])
	GUI:CreateSwitch(appearanceChatSection, "Chat.LootIcons", L["Show Loot Icons"], L["Chat.LootIcons Desc"])
	GUI:CreateSwitch(appearanceChatSection, "Chat.ChatItemLevel", L["Show ItemLevel on ChatFrames"], L["ChatItemLevel Desc"])
	GUI:CreateSwitch(appearanceChatSection, "Chat.CopyButton", "Show Copy Chat Button |TInterface\\Buttons\\UI-GuildButton-PublicNote-Up:14:14|t", L["Chat.CopyButton Desc"])
	GUI:CreateSwitch(appearanceChatSection, "Chat.ConfigButton", "Show Config Button |TInterface\\Buttons\\UI-OptionsButton:14:14|t", L["Chat.ConfigButton Desc"])
	GUI:CreateSwitch(appearanceChatSection, "Chat.RollButton", "Show Roll Button |A:charactercreate-icon-dice:14:14|a", L["Chat.RollButton Desc"])

	-- Timestamp Format
	local timestampOptions = {
		{ text = "Disable", value = 1 },
		{ text = "03:27 PM", value = 2 },
		{ text = "03:27:32 PM", value = 3 },
		{ text = "15:27", value = 4 },
		{ text = "15:27:32", value = 5 },
	}
	GUI:CreateDropdown(appearanceChatSection, "Chat.TimestampFormat", L["Custom Chat Timestamps"], timestampOptions, L["TimestampFormat Desc"])

	-- Behavior
	local behaviorChatSection = GUI:AddSection(chatCategory, L["Behavior"])
	GUI:CreateSwitch(behaviorChatSection, "Chat.Freedom", L["Disable Chat Language Filter"], L["Freedom Desc"])
	GUI:CreateSwitch(behaviorChatSection, "Chat.ChatMenu", L["Show Chat Menu Buttons"], L["ChatMenu Desc"])
	GUI:CreateSwitch(behaviorChatSection, "Chat.Sticky", L["Stick On Channel If Whispering"], L["Sticky Desc"])
	GUI:CreateSwitch(behaviorChatSection, "Chat.WhisperColor", L["Differ Whisper Colors"], L["Chat.WhisperColor Desc"])
	GUI:CreateSwitch(behaviorChatSection, "Chat.HighlightPlayer", L["Highlight Your Name"], L["Highlight Your Name Desc"])
	GUI:CreateSwitch(behaviorChatSection, "Chat.HighlightGuild", L["Highlight Guild Tags"], L["Highlight Guild Tags Desc"])

	-- Sizes
	local sizesChatSection = GUI:AddSection(chatCategory, L["Sizes"])
	GUI:CreateSlider(sizesChatSection, "Chat.Height", L["Lock Chat Height"], 100, 500, 1, L["Height Desc"])
	GUI:CreateSlider(sizesChatSection, "Chat.Width", L["Lock Chat Width"], 200, 600, 1, L["Width Desc"])

	local historyChatSection = GUI:AddSection(chatCategory, HISTORY)
	local logMaxWidget = GUI:CreateSlider(historyChatSection, "Chat.LogMax", L["Chat History Lines To Save"], 0, 250, 10, L["LogMax Desc"])
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
	GUI:CreateSwitch(fadingChatSection, "Chat.Fading", L["Fade Chat Text"], L["Chat.Fading Desc"])
	GUI:CreateSlider(fadingChatSection, "Chat.FadingTimeVisible", L["Fading Chat Visible Time"], 5, 120, 1, L["FadingTimeVisible Desc"])
end

-- DataText
local function CreateDataTextCategory()
	local dataTextIcon = "Interface\\Icons\\Achievement_worldevent_childrensweek"
	local dataTextCategory = GUI:AddCategory(L["DataText"], dataTextIcon)

	-- General
	local generalDataTextSection = GUI:AddSection(dataTextCategory, GENERAL)
	GUI:CreateSwitch(generalDataTextSection, "DataText.Coords", L["Enable Position Coords"], L["Coords Desc"])
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

	-- General
	local generalGeneralSection = GUI:AddSection(generalCategory, GENERAL)
	GUI:CreateSwitch(generalGeneralSection, "General.MinimapIcon", L["Enable Minimap Icon"], L["MinimapIcon Desc"])
	GUI:CreateSwitch(generalGeneralSection, "General.MoveBlizzardFrames", L["Move Blizzard Frames"], L["MoveBlizzardFrames Desc"])
	GUI:CreateSwitch(generalGeneralSection, "General.NoErrorFrame", L["Disable Blizzard Error Frame Combat"], L["General.NoErrorFrame Desc"])
	GUI:CreateSwitch(generalGeneralSection, "General.NoTutorialButtons", L["Disable 'Some' Blizzard Tutorials"], L["NoTutorialButtons Desc"])
	GUI:CreateSwitch(generalGeneralSection, "General.VersionCheck", L["Enable Version Check"], L["General.VersionCheck Desc"])

	-- Button Glow Mode
	local glowModeOptions = {
		{ text = "Pixel", value = 1 },
		{ text = "Autocast", value = 2 },
		{ text = "Action Button", value = 3 },
		{ text = "Proc Glow", value = 4 },
	}
	GUI:CreateDropdown(generalGeneralSection, "General.GlowMode", L["Button Glow Mode"], glowModeOptions, L["GlowMode Desc"])

	-- Border Style
	local borderStyleOptions
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
	GUI:CreateDropdown(generalGeneralSection, "General.BorderStyle", L["Border Style"], borderStyleOptions, L["General.BorderStyle Desc"])

	-- Number Prefix
	local numberPrefixOptions = {
		{ text = "Standard: b/m/k", value = 1 },
		{ text = "Asian: y/w", value = 2 },
		{ text = "Full Digits", value = 3 },
	}
	GUI:CreateDropdown(generalGeneralSection, "General.NumberPrefixStyle", L["Number Prefix Style"], numberPrefixOptions, L["General.NumberPrefixStyle Desc"])

	-- Smoothing
	GUI:CreateSlider(generalGeneralSection, "General.SmoothAmount", "Smoothing Amount", 0.1, 1, 0.01, L["Setup healthbar smooth frequency for unitframes and nameplates. The lower the smoother."])

	-- Scaling
	local scalingSection = GUI:AddSection(generalCategory, L["Scaling"])
	GUI:CreateSwitch(scalingSection, "General.AutoScale", L["Auto Scale"], L["AutoScaleTip"])
	GUI:CreateSlider(scalingSection, "General.UIScale", L["Set UI scale"], 0.4, 1.15, 0.01, L["UIScaleTip"])

	-- Colors
	local colorsSection = GUI:AddSection(generalCategory, COLORS)
	GUI:CreateSwitch(colorsSection, "General.ColorTextures", L["Color 'Most' KkthnxUI Borders"], L["ColorTextures Desc"])
	GUI:CreateColorPicker(colorsSection, "General.TexturesColor", L["Textures Color"], "Choose the color for KkthnxUI textures and borders")

	-- Texture Section
	local textureSection = GUI:AddSection(generalCategory, L["Texture"])

	-- Enhanced Texture
	GUI:CreateTextureDropdown(textureSection, "General.Texture", L["Set General Texture"], L["Texture Desc"])
end

-- Inventory
local function CreateInventoryCategory()
	local inventoryIcon = "Interface\\Icons\\INV_Misc_Bag_07"
	local inventoryCategory = GUI:AddCategory(L["Inventory"], inventoryIcon)

	-- General
	local generalInventorySection = GUI:AddSection(inventoryCategory, GENERAL)
	GUI:CreateSwitch(generalInventorySection, "Inventory.Enable", enableTextColor .. L["Enable Inventory"], L["Inventory.Enable Desc"] or L["Enable Desc"])
	GUI:CreateSwitch(generalInventorySection, "Inventory.AutoSell", L["Auto Vendor Grays"], L["Inventory.AutoSell Desc"])

	-- Bags Section
	local bagsSection = GUI:AddSection(inventoryCategory, L["Bags"])
	GUI:CreateSwitch(bagsSection, "Inventory.ColorUnusableItems", L["Color Unusable Items"], L["ColorUnusableItems Desc"])
	GUI:CreateSwitch(bagsSection, "Inventory.BagsBindOnEquip", L["Display Bind Status"], L["BagsBindOnEquip Desc"])
	GUI:CreateSwitch(bagsSection, "Inventory.BagsItemLevel", L["Display Item Level"], L["BagsItemLevel Desc"])
	GUI:CreateSwitch(bagsSection, "Inventory.DeleteButton", L["Bags Delete Button"], L["Inventory.DeleteButton Desc"])
	GUI:CreateSwitch(bagsSection, "Inventory.ReverseSort", L["Reverse the Sorting"], L["ReverseSort Desc"])
	GUI:CreateSwitch(bagsSection, "Inventory.ShowNewItem", L["Show New Item Glow"], L["Inventory.ShowNewItem Desc"])
	GUI:CreateSwitch(bagsSection, "Inventory.UpgradeIcon", L["Show Upgrade Icon"], L["Inventory.UpgradeIcon Desc"])
	GUI:CreateSlider(bagsSection, "Inventory.BagsPerRow", L["Bags Per Row"], 1, 20, 1, L["BagsPerRow Desc"])
	GUI:CreateSlider(bagsSection, "Inventory.iLvlToShow", "ItemLevel Threshold", 1, 800, 1, L["iLvlToShow Desc"])

	-- Bank Section
	local bankSection = GUI:AddSection(inventoryCategory, BANK)
	GUI:CreateSlider(bankSection, "Inventory.BankPerRow", L["Bank Bags Per Row"], 1, 20, 1, L["BankPerRow Desc"])

	-- Other Section
	local otherInventorySection = GUI:AddSection(inventoryCategory, OTHER)
	GUI:CreateSwitch(otherInventorySection, "Inventory.PetTrash", L["Pet Trash Currencies"], L["Inventory.PetTrash Desc"])

	-- Auto Repair
	local autoRepairOptions = {
		{ text = GUILD, value = 1 },
		{ text = PLAYER, value = 2 },
		{ text = DISABLE, value = 3 },
	}
	GUI:CreateDropdown(otherInventorySection, "Inventory.AutoRepair", L["Auto Repair Gear"], autoRepairOptions, L["Inventory.AutoRepair Desc"])

	-- Filters
	local filtersSection = GUI:AddSection(inventoryCategory, FILTERS)
	local _ = GUI:CreateSwitch(filtersSection, "Inventory.ItemFilter", L["Filter Items Into Categories"], L["ItemFilter Desc"])
	local gatherEmptySwitch = GUI:CreateSwitch(filtersSection, "Inventory.GatherEmpty", L["Gather Empty Slots Into One Button"], L["GatherEmpty Desc"])
	-- Dependency: Only allow Gather Empty when ItemFilter is enabled
	GUI:DependsOn(gatherEmptySwitch, "Inventory.ItemFilter", true, nil, L["Filter Items Into Categories"])

	-- Sizes
	local inventorySizesSection = GUI:AddSection(inventoryCategory, L["Sizes"])
	GUI:CreateSlider(inventorySizesSection, "Inventory.BagsWidth", L["Bags Width"], 8, 16, 1, L["BagsWidth Desc"])
	GUI:CreateSlider(inventorySizesSection, "Inventory.BankWidth", L["Bank Width"], 10, 18, 1, L["BankWidth Desc"])
	GUI:CreateSlider(inventorySizesSection, "Inventory.IconSize", L["Slot Icon Size"], 28, 40, 1, L["IconSize Desc"])

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
	GUI:CreateDropdown(bagBarSection, "Inventory.SortDirection", L["Sort Direction"], sortDirectionOptions, L["Inventory.SortDirection Desc"])
end

-- Loot
local function CreateLootCategory()
	local lootIcon = "Interface\\Icons\\INV_Misc_Coin_02"
	local lootCategory = GUI:AddCategory(L["Loot"], lootIcon)

	-- General
	local generalLootSection = GUI:AddSection(lootCategory, GENERAL)
	GUI:CreateSwitch(generalLootSection, "Loot.Enable", enableTextColor .. L["Enable Loot"], L["Enable Desc"])
	GUI:CreateSwitch(generalLootSection, "Loot.GroupLoot", enableTextColor .. L["Enable Group Loot"], L["GroupLoot Desc"])

	-- Auto-Loot
	local autoLootingSection = GUI:AddSection(lootCategory, L["Auto-Looting"])
	GUI:CreateSwitch(autoLootingSection, "Loot.FastLoot", L["Faster Auto-Looting"], L["FastLoot Desc"])

	-- Auto-Confirming
	local autoConfirmSection = GUI:AddSection(lootCategory, L["Auto-Confirm"])
	GUI:CreateSwitch(autoConfirmSection, "Loot.AutoConfirm", L["Auto Confirm Loot Dialogs"], L["Loot.AutoConfirm Desc"])
	GUI:CreateSwitch(autoConfirmSection, "Loot.AutoGreed", L["Auto Greed Green Items"], L["AutoGreed Desc"])
end

-- Minimap
local function CreateMinimapCategory()
	local minimapIcon = "Interface\\Icons\\INV_Misc_Map_01"
	local minimapCategory = GUI:AddCategory(L["Minimap"], minimapIcon)

	-- General
	local generalMinimapSection = GUI:AddSection(minimapCategory, GENERAL)
	GUI:CreateSwitch(generalMinimapSection, "Minimap.Enable", enableTextColor .. L["Enable Minimap"], L["Enable Desc"])
	GUI:CreateSwitch(generalMinimapSection, "Minimap.Calendar", L["Show Minimap Calendar"], L["If enabled, show minimap calendar icon on minimap.|nYou can simply click mouse middle button on minimap to toggle calendar even without this option."])

	-- Features
	local featuresSection = GUI:AddSection(minimapCategory, L["Features"])
	GUI:CreateSwitch(featuresSection, "Minimap.EasyVolume", L["EasyVolume"], L["EasyVolumeTip"])
	GUI:CreateSwitch(featuresSection, "Minimap.MailPulse", L["Pulse Minimap Mail"], L["MailPulse Desc"])
	GUI:CreateSwitch(featuresSection, "Minimap.QueueStatusText", L["QueueStatus"], L["Minimap.QueueStatusText Desc"])
	GUI:CreateSwitch(featuresSection, "Minimap.ShowRecycleBin", L["Show Minimap Button Collector"], L["ShowRecycleBin Desc"])

	-- Recycle Bin
	local recycleBinSection = GUI:AddSection(minimapCategory, L["Recycle Bin"])

	-- RecycleBin Position
	local recycleBinPositionOptions = {
		{ text = "BottomLeft", value = 1 },
		{ text = "BottomRight", value = 2 },
		{ text = "TopLeft", value = 3 },
		{ text = "TopRight", value = 4 },
	}
	GUI:CreateDropdown(recycleBinSection, "Minimap.RecycleBinPosition", L["Set RecycleBin Position"], recycleBinPositionOptions, L["RecycleBinPosition Desc"])

	-- Location Section
	local locationSection = GUI:AddSection(minimapCategory, L["Location"])

	-- Location Text Style
	local locationTextOptions = {
		{ text = "Always Display", value = 1 },
		{ text = "Hide", value = 2 },
		{ text = "Minimap Mouseover", value = 3 },
	}
	GUI:CreateDropdown(locationSection, "Minimap.LocationText", L["Location Text Style"], locationTextOptions, L["Minimap.LocationText Desc"])

	-- Size
	local sizeSection = GUI:AddSection(minimapCategory, L["Size"])
	GUI:CreateSlider(sizeSection, "Minimap.Size", L["Minimap Size"], 120, 300, 1, L["Size Desc"])
end

-- Misc Category
local function CreateMiscCategory()
	local miscIcon = "Interface\\Icons\\INV_Misc_Bag_10"
	local miscCategory = GUI:AddCategory(L["Misc"], miscIcon)

	-- UI Enhancements
	local uiEnhanceSection = GUI:AddSection(miscCategory, "UI Enhancements")
	GUI:CreateSwitch(uiEnhanceSection, "Misc.ColorPicker", L["Enhanced Color Picker"], L["Misc.ColorPicker Desc"])
	GUI:CreateSwitch(uiEnhanceSection, "Misc.ImprovedStats", L["Display Character Frame Full Stats"], L["Misc.ImprovedStats Desc"])
	GUI:CreateSwitch(uiEnhanceSection, "Misc.QuickDelete", L["Quick Item Delete"], L["Misc.QuickDelete Desc"])
	GUI:CreateSwitch(uiEnhanceSection, "Misc.QuickMenuList", L["Enhanced Unit Popup Menus"], L["Misc.QuickMenuList Desc"])
	GUI:CreateSwitch(uiEnhanceSection, "Misc.YClassColors", "Enable ClassColors", L["Misc.YClassColors Desc"])

	-- Target Marking
	local markingSection = GUI:AddSection(miscCategory, "Target Marking")
	GUI:CreateSwitch(markingSection, "Misc.EasyMarking", L["EasyMarking by Ctrl + LeftClick"], L["Misc.EasyMarking Desc"])

	-- Location Text Style
	local easyMarkKeyOptions = {
		{ text = "CTRL_KEY", value = 1 },
		{ text = "ALT_KEY", value = 2 },
		{ text = "SHIFT_KEY", value = 3 },
		{ text = DISABLE, value = 4 },
	}
	GUI:CreateDropdown(markingSection, "Misc.EasyMarkKey", "EasyMarking Key Modifier", easyMarkKeyOptions, L["Misc.EasyMarkKey Desc"])

	-- Encounter UI
	local encounterSection = GUI:AddSection(miscCategory, "Encounter UI")
	GUI:CreateSwitch(encounterSection, "Misc.HideBanner", L["Hide RaidBoss EmoteFrame"], L["Misc.HideBanner Desc"])
	GUI:CreateSwitch(encounterSection, "Misc.HideBossEmote", L["Hide BossBanner"], L["Misc.HideBossEmote Desc"])

	-- Camera
	local cameraSection = GUI:AddSection(miscCategory, "Camera")
	GUI:CreateSlider(cameraSection, "Misc.MaxCameraZoom", "Max Camera Zoom Level", 1, 2.6, 0.1, L["Misc.MaxCameraZoom Desc"])
	GUI:CreateSwitch(cameraSection, "Misc.AFKCamera", L["AFK Camera"], L["Misc.AFKCamera Desc"])

	-- Trade Skill
	local tradeSkillSection = GUI:AddSection(miscCategory, "Trade Skill")
	GUI:CreateSwitch(tradeSkillSection, "Misc.TradeTabs", L["Add Spellbook-Like Tabs On TradeSkillFrame"], L["Misc.TradeTabs Desc"])

	-- Social
	local socialSection = GUI:AddSection(miscCategory, "Social")
	GUI:CreateSwitch(socialSection, "Misc.EnhancedFriends", L["Enhanced Colors (Friends/Guild +)"], L["Misc.EnhancedFriends Desc"])
	GUI:CreateSwitch(socialSection, "Misc.QuickJoin", L["QuickJoin"], L["QuickJoinTip"])

	-- Audio
	local audioSection = GUI:AddSection(miscCategory, "Audio")
	GUI:CreateSwitch(audioSection, "Misc.MuteSounds", "Mute Various Annoying Sounds In-Game", L["Misc.MuteSounds Desc"])
	GUI:CreateButtonWidget(audioSection, "Misc.ManageMuteSoundIDs", L["Custom Mute Sound IDs"], L["Open GUI"], L["Misc.ManageMuteSoundIDs Desc"], function()
		if K.ExtraGUI and K.ExtraGUI.ToggleExtraConfig then
			K.ExtraGUI:ToggleExtraConfig("Misc.MuteSoundIDs", L["Custom Mute Sound IDs"])
		end
	end)
	-- Mail
	local mailSection = GUI:AddSection(miscCategory, "Mail")
	GUI:CreateSwitch(mailSection, "Misc.EnhancedMail", "Add 'Postal' Like Feaures To The Mailbox", L["Misc.EnhancedMail Desc"])

	-- Questing & Dialog
	local questingSection = GUI:AddSection(miscCategory, "Questing & Dialog")
	GUI:CreateSwitch(questingSection, "Misc.ExpRep", "Display Exp/Rep Bar (Minimap)", L["Misc.ExpRep Desc"])
	GUI:CreateSwitch(questingSection, "Misc.QuestTool", "Add Tips For Some Quests And World Quests", L["Misc.QuestTool Desc"])
	GUI:CreateSwitch(questingSection, "Misc.ShowWowHeadLinks", L["Show Wowhead Links Above Questlog Frame"], L["Misc.ShowWowHeadLinks Desc"])
	GUI:CreateSwitch(questingSection, "Misc.NoTalkingHead", L["Remove And Hide The TalkingHead Frame"], L["Misc.NoTalkingHead Desc"])

	-- Mythic+
	local mythicPlusSection = GUI:AddSection(miscCategory, "Mythic+")

	GUI:CreateSwitch(mythicPlusSection, "Misc.MDGuildBest", L["Show Mythic+ GuildBest"], L["Misc.MDGuildBest Desc"])

	-- Raid Tool
	local raidToolSection = GUI:AddSection(miscCategory, "Raid Tool")
	GUI:CreateSwitch(raidToolSection, "Misc.RaidTool", L["Show Raid Utility Frame"], L["Misc.RaidTool Desc"])
	GUI:CreateSwitch(raidToolSection, "Misc.RMRune", "RMRune - Add Info", L["Misc.RMRune Desc"])
	GUI:CreateButtonWidget(raidToolSection, "Misc.ManageDBMCount", L["DBMCount - Add Info"], L["Open GUI"], L["Misc.DBMCount Desc"], function()
		if K.ExtraGUI and K.ExtraGUI.ToggleExtraConfig then
			K.ExtraGUI:ToggleExtraConfig("Misc.DBMCount", L["DBMCount - Add Info"])
		end
	end)

	-- World Markers Bar
	local markerBarOptions = {
		{ text = "Grids", value = 1 },
		{ text = "Horizontal", value = 2 },
		{ text = "Vertical", value = 3 },
		{ text = DISABLE, value = 4 },
	}
	GUI:CreateDropdown(raidToolSection, "Misc.ShowMarkerBar", L["World Markers Bar"], markerBarOptions, L["Misc.ShowMarkerBar Desc"])
	GUI:CreateSlider(raidToolSection, "Misc.MarkerBarSize", "Marker Bar Size - Add Info", 20, 40, 1, L["Misc.MarkerBarSize Desc"])

	-- Character & Inspect
	local characterSection = GUI:AddSection(miscCategory, "Character & Inspect")
	GUI:CreateSwitch(characterSection, "Misc.ItemLevel", L["Show Character/Inspect ItemLevel Info"], L["Misc.ItemLevel Desc"])
	GUI:CreateSwitch(characterSection, "Misc.GemEnchantInfo", L["Character/Inspect Gem/Enchant Info"], L["Misc.GemEnchantInfo Desc"])
	GUI:CreateSwitch(characterSection, "Misc.SlotDurability", L["Show Slot Durability %"], L["Misc.SlotDurability Desc"])

	local queueTimerSection = GUI:AddSection(miscCategory, "Queue Timer")
	local _ = GUI:CreateSwitch(queueTimerSection, "Misc.QueueTimers", "Queue Timer", L["Misc.QueueTimers Desc"])
	local audio = GUI:CreateSwitch(queueTimerSection, "Misc.QueueTimerAudio", "Audio cue", L["Misc.QueueTimerAudio Desc"])
	local warn = GUI:CreateSwitch(queueTimerSection, "Misc.QueueTimerWarning", "6s warning beeps", L["Misc.QueueTimerWarning Desc"])
	local hide = GUI:CreateSwitch(queueTimerSection, "Misc.QueueTimerHideOtherTimers", "Hide other bars", L["Misc.QueueTimerHideOtherTimers Desc"])

	GUI:DependsOn(audio, "Misc.QueueTimers", true)
	GUI:DependsOn(warn, "Misc.QueueTimers", true)
	GUI:DependsOn(hide, "Misc.QueueTimers", true)
end

-- Nameplate
local function CreateNameplateCategory()
	local nameplateIcon = "Interface\\Icons\\Spell_Arcane_MindMastery"
	local nameplateCategory = GUI:AddCategory(L["Nameplate"], nameplateIcon)

	-- General
	local generalNameplateSection = GUI:AddSection(nameplateCategory, GENERAL)

	GUI:CreateSwitch(generalNameplateSection, "Nameplate.Enable", enableTextColor .. L["Enable Nameplates"], "Toggle the entire nameplate system on/off")
	GUI:CreateSwitch(generalNameplateSection, "Nameplate.ClassIcon", L["Show Enemy Class Icons"], L["Nameplate.ClassIcon Desc"])
	GUI:CreateSwitch(generalNameplateSection, "Nameplate.CustomUnitColor", L["Colored Custom Units"], L["Nameplate.CustomUnitColor Desc"])
	GUI:CreateSwitch(generalNameplateSection, "Nameplate.FriendlyCC", L["Show Friendly ClassColor"], L["Nameplate.FriendlyCC Desc"])
	GUI:CreateSwitch(generalNameplateSection, "Nameplate.HostileCC", L["Show Hostile ClassColor"], L["Nameplate.HostileCC Desc"])
	GUI:CreateSwitch(generalNameplateSection, "Nameplate.FullHealth", L["Show Health Value"], L["Nameplate.FullHealth Desc"])
	GUI:CreateSwitch(generalNameplateSection, "Nameplate.InsideView", L["Interacted Nameplate Stay Inside"], L["Nameplate.InsideView Desc"])
	GUI:CreateSwitch(generalNameplateSection, "Nameplate.NameOnly", L["Show Only Names For Friendly"], L["Nameplate.NameOnly Desc"])
	GUI:CreateSwitch(generalNameplateSection, "Nameplate.NameplateClassPower", "Show Nameplate Class Power", L["Nameplate.NameplateClassPower Desc"])

	-- Auras
	local aurasNameplateSection = GUI:AddSection(nameplateCategory, L["Auras"])
	local auraFilterOptions = {
		{ text = "White & Black List", value = 1 },
		{ text = "List & Player", value = 2 },
		{ text = "List & Player & CCs", value = 3 },
	}
	GUI:CreateDropdown(aurasNameplateSection, "Nameplate.AuraFilter", L["Auras Filter Style"], auraFilterOptions, L["Nameplate.AuraFilter Desc"])
	GUI:CreateSlider(aurasNameplateSection, "Nameplate.AuraSize", L["Auras Size"], 18, 40, 1, L["Nameplate.AuraSize Desc"])
	GUI:CreateSlider(aurasNameplateSection, "Nameplate.MaxAuras", L["Max Auras"], 4, 8, 1, L["Nameplate.MaxAuras Desc"])
	GUI:CreateSwitch(aurasNameplateSection, "Nameplate.PlateAuras", L["Target Nameplate Auras"], L["TargetPlateAuras Desc"])

	-- Targeting & Indicators
	local indicatorsSection = GUI:AddSection(nameplateCategory, L["Targeting & Indicators"])
	GUI:CreateSwitch(indicatorsSection, "Nameplate.ColoredTarget", L["Colored Targeted Nameplate"], L["ColoredTargeted Desc"])
	local targetIndicatorOptions = {
		{ text = "Disable", value = 1 },
		{ text = "Top Arrow", value = 2 },
		{ text = "Right Arrow", value = 3 },
		{ text = "Border Glow", value = 4 },
		{ text = "Top Arrow + Glow", value = 5 },
		{ text = "Right Arrow + Glow", value = 6 },
	}
	GUI:CreateDropdown(indicatorsSection, "Nameplate.TargetIndicator", L["TargetIndicator Style"], targetIndicatorOptions, L["Nameplate.TargetIndicator Desc"])
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
	GUI:CreateDropdown(indicatorsSection, "Nameplate.TargetIndicatorTexture", L["TargetIndicator Texture"], targetIndicatorTextureOptions, L["TargetIndicatorTexture Desc"])
	GUI:CreateColorPicker(indicatorsSection, "Nameplate.TargetIndicatorColor", L["TargetIndicator Color"], "Color for target indicators")

	-- Custom Lists
	local customListsSection = GUI:AddSection(nameplateCategory, L["Custom Lists"])
	-- REASON: The full add/remove editors (with portraits + default rows) live in ExtraGUI.
	-- Expose them through a Manage button rather than a clear-on-submit buffer input that hid the
	-- real list manager behind a cogwheel. The button configPath is a synthetic identifier so no
	-- redundant cogwheel attaches on top of the button.
	GUI:CreateButtonWidget(customListsSection, "Nameplate.CustomUnitListManage", L["Custom UnitColor List"], L["Open GUI"], L["CustomUnitTip"], function()
		if K.ExtraGUI and K.ExtraGUI.ToggleExtraConfig then
			K.ExtraGUI:ToggleExtraConfig("Nameplate.CustomUnitList", L["Custom UnitColor List"])
		end
	end)
	GUI:CreateButtonWidget(customListsSection, "Nameplate.PowerUnitListManage", L["Custom PowerUnit List"], L["Open GUI"], L["CustomUnitTip"], function()
		if K.ExtraGUI and K.ExtraGUI.ToggleExtraConfig then
			K.ExtraGUI:ToggleExtraConfig("Nameplate.PowerUnitList", L["Custom PowerUnit List"])
		end
	end)

	-- Castbar
	local castbarSection = GUI:AddSection(nameplateCategory, L["Castbar"])
	GUI:CreateSwitch(castbarSection, "Nameplate.CastTarget", L["Show Nameplate Target Of Casting Spell"], L["CastTarget Desc"])
	GUI:CreateSwitch(castbarSection, "Nameplate.CastbarGlow", L["Force Crucial Spells To Glow"], L["CastbarGlow Desc"])

	-- Threat
	local threatSection = GUI:AddSection(nameplateCategory, L["Threat"])
	GUI:CreateSwitch(threatSection, "Nameplate.DPSRevertThreat", L["Revert Threat Color If Not Tank"], L["Nameplate.DPSRevertThreat Desc"])
	GUI:CreateSwitch(threatSection, "Nameplate.TankMode", L["Force TankMode Colored"], L["Nameplate.TankMode Desc"])

	-- Miscellaneous
	local miscellaneousNameplateSection = GUI:AddSection(nameplateCategory, L["Miscellaneous"])
	GUI:CreateSwitch(miscellaneousNameplateSection, "Nameplate.AKSProgress", L["Show AngryKeystones Progress"], L["Nameplate.AKSProgress Desc"])
	-- NOTE: "Target Nameplate Auras" lives in the Auras section; it was duplicated here previously.
	GUI:CreateSwitch(miscellaneousNameplateSection, "Nameplate.QuestIndicator", L["Quest Progress Indicator"], L["Nameplate.QuestIndicator Desc"])

	local questProgressModeOptions = {
		{ text = L["Always"], value = 1 },
		{ text = L["On Your Target"], value = 2 },
		{ text = L["On Mouseover"], value = 3 },
		{ text = L["While Holding a Key"], value = 4 },
		{ text = L["Never"], value = 5 },
	}
	GUI:CreateDropdown(miscellaneousNameplateSection, "Nameplate.QuestProgressMode", L["Show Objective Progress"], questProgressModeOptions, L["Nameplate.QuestProgressMode Desc"])

	local questProgressKeyOptions = {
		{ text = L["Alt"], value = 1 },
		{ text = L["Ctrl"], value = 2 },
		{ text = L["Shift"], value = 3 },
	}
	GUI:CreateDropdown(miscellaneousNameplateSection, "Nameplate.QuestProgressModifier", L["Progress Modifier Key"], questProgressKeyOptions, L["Nameplate.QuestProgressModifier Desc"])

	local questProgressFormatOptions = {
		{ text = L["Completed (3/7)"], value = 1 },
		{ text = L["Remaining (4)"], value = 2 },
	}
	GUI:CreateDropdown(miscellaneousNameplateSection, "Nameplate.QuestProgressFormat", L["Progress Format"], questProgressFormatOptions, L["Nameplate.QuestProgressFormat Desc"])

	GUI:CreateSwitch(miscellaneousNameplateSection, "Nameplate.QuestShowPartyQuest", L["Show Party Quests"], L["Nameplate.QuestShowPartyQuest Desc"])

	local questIndicatorStyleOptions = {
		{ text = "Standard", value = 1 },
		{ text = "Enhanced (Icons)", value = 2 },
	}
	GUI:CreateDropdown(miscellaneousNameplateSection, "Nameplate.QuestIconStyle", "Quest Icon Style", questIndicatorStyleOptions, L["Nameplate.QuestIconStyle Desc"])

	GUI:CreateSwitch(miscellaneousNameplateSection, "Nameplate.Smooth", L["Smooth Bars Transition"], L["Nameplate.Smooth Desc"])

	-- Sizes
	local sizesNameplateSection = GUI:AddSection(nameplateCategory, L["Sizes"])
	GUI:CreateSlider(sizesNameplateSection, "Nameplate.HealthTextSize", L["HealthText FontSize"], 8, 16, 1, L["Nameplate.HealthTextSize Desc"])
	GUI:CreateSlider(sizesNameplateSection, "Nameplate.MinAlpha", L["Non-Target Nameplate Alpha"], 0.1, 1, 0.1, L["Nameplate.MinAlpha Desc"])
	GUI:CreateSlider(sizesNameplateSection, "Nameplate.MinScale", L["Non-Target Nameplate Scale"], 0.1, 3, 0.1, L["Nameplate.MinScale Desc"])
	GUI:CreateSlider(sizesNameplateSection, "Nameplate.NameTextSize", L["NameText FontSize"], 8, 16, 1, L["Nameplate.NameTextSize Desc"])
	GUI:CreateSlider(sizesNameplateSection, "Nameplate.PlateHeight", L["Nameplate Height"], 6, 28, 1, L["Nameplate.PlateHeight Desc"])
	GUI:CreateSlider(sizesNameplateSection, "Nameplate.PlateWidth", L["Nameplate Width"], 80, 240, 1, L["Nameplate.PlateWidth Desc"])
	GUI:CreateSlider(sizesNameplateSection, "Nameplate.VerticalSpacing", L["Nameplate Vertical Spacing"], 0.5, 2.5, 0.1, L["Nameplate.VerticalSpacing Desc"])
	GUI:CreateSlider(sizesNameplateSection, "Nameplate.SelectedScale", L["Selected Nameplate Scale"], 1, 1.4, 0.1, L["SelectedScale Desc"])
	GUI:CreateSlider(sizesNameplateSection, "Nameplate.ExecuteRatio", "Execute Ratio", 0, 50, 1, L["Nameplate.ExecuteRatio Desc"])

	-- Player Nameplate Toggles
	local playerTogglesSection = GUI:AddSection(nameplateCategory, L["Player Nameplate Toggles"])
	GUI:CreateSwitch(playerTogglesSection, "Nameplate.ShowPlayerPlate", enableTextColor .. L["Enable Personal Resource"], "Show your personal resource nameplate")
	GUI:CreateSwitch(playerTogglesSection, "Nameplate.PPGCDTicker", L["Enable GCD Ticker"], L["Nameplate.PPGCDTicker Desc"])
	GUI:CreateSwitch(playerTogglesSection, "Nameplate.PPHideOOC", L["Only Visible in Combat"], L["Nameplate.PPHideOOC Desc"])
	GUI:CreateSwitch(playerTogglesSection, "Nameplate.PPPowerText", L["Show Power Value"], L["Nameplate.PPPowerText Desc"])

	-- Player Nameplate Values
	local playerValuesSection = GUI:AddSection(nameplateCategory, L["Player Nameplate Values"])
	GUI:CreateSlider(playerValuesSection, "Nameplate.PPHeight", L["Classpower/Healthbar Height"], 4, 10, 1, L["Nameplate.PPHeight Desc"])
	GUI:CreateSlider(playerValuesSection, "Nameplate.PPIconSize", L["PlayerPlate IconSize"], 20, 40, 1, L["Nameplate.PPIconSize Desc"])
	GUI:CreateSlider(playerValuesSection, "Nameplate.PPPHeight", L["PlayerPlate Powerbar Height"], 4, 10, 1, L["Nameplate.PPPHeight Desc"])

	-- Colors
	local colorsNameplateSection = GUI:AddSection(nameplateCategory, COLORS)
	GUI:CreateColorPicker(colorsNameplateSection, "Nameplate.CustomColor", L["Custom Color"], "Color for custom units")
	GUI:CreateColorPicker(colorsNameplateSection, "Nameplate.InsecureColor", L["Insecure Color"], "Color for insecure threat level")
	GUI:CreateColorPicker(colorsNameplateSection, "Nameplate.OffTankColor", L["Off-Tank Color"], "Color for off-tank units")
	GUI:CreateColorPicker(colorsNameplateSection, "Nameplate.SecureColor", L["Secure Color"], "Color for secure threat level")
	GUI:CreateColorPicker(colorsNameplateSection, "Nameplate.TargetColor", "Selected Target Coloring", "Color for targeted nameplates")
	GUI:CreateColorPicker(colorsNameplateSection, "Nameplate.TransColor", L["Transition Color"], "Color for threat transition states")
	GUI:CreateColorPicker(colorsNameplateSection, "Nameplate.ExecuteColor", "Execute Color", "Color for health bars in execute range")
	GUI:CreateColorPicker(colorsNameplateSection, "Nameplate.QuestSkullColor", "Quest Kill Color", "Color for quest kill objectives")
	GUI:CreateColorPicker(colorsNameplateSection, "Nameplate.QuestItemColor", "Quest Item Color", "Color for quest item objectives")
	GUI:CreateColorPicker(colorsNameplateSection, "Nameplate.QuestChatColor", "Quest Chat Color", "Color for quest interaction objectives")
end

-- Party
local function CreatePartyCategory()
	local partyIcon = "Interface\\Icons\\Ships_ability_boardingparty"
	local partyCategory = GUI:AddCategory(L["Party"], partyIcon)

	-- General Section
	local generalPartySection = GUI:AddSection(partyCategory, GENERAL)
	GUI:CreateSwitch(generalPartySection, "Party.Enable", enableTextColor .. L["Enable Party"], "Toggle the entire party frame system on/off")
	GUI:CreateSwitch(generalPartySection, "Party.ShowBuffs", L["Show Party Buffs"], L["Party.ShowBuffs Desc"])
	GUI:CreateSwitch(generalPartySection, "Party.ShowHealPrediction", L["Show HealPrediction Statusbars"], L["Party.ShowHealPrediction Desc"])
	GUI:CreateSwitch(generalPartySection, "Party.ShowPartySolo", L["Show Party Frames While Solo"], L["ShowPartySolo Desc"])
	GUI:CreateSwitch(generalPartySection, "Party.ShowPet", L["Show Party Pets"], L["Party.ShowPet Desc"])
	GUI:CreateSwitch(generalPartySection, "Party.ShowPlayer", L["Show Player In Party"], L["Party.ShowPlayer Desc"])
	GUI:CreateSwitch(generalPartySection, "Party.Smooth", L["Smooth Bar Transition"], L["Party.Smooth Desc"])
	GUI:CreateSwitch(generalPartySection, "Party.TargetHighlight", L["Show Highlighted Target"], L["Party.TargetHighlight Desc"])

	-- Party Castbars Section
	local castbarsPartySection = GUI:AddSection(partyCategory, L["Party Castbars"])
	GUI:CreateSwitch(castbarsPartySection, "Party.Castbars", L["Show Castbars"], L["Party.Castbars Desc"])
	GUI:CreateSwitch(castbarsPartySection, "Party.CastbarIcon", L["Show Castbars"] .. " Icon", L["Party.CastbarIcon Desc"])

	-- Sizes Section
	local sizesPartySection = GUI:AddSection(partyCategory, L["Sizes"])
	GUI:CreateSlider(sizesPartySection, "Party.HealthHeight", L["Party Frame Health Height"], 20, 50, 1, L["Party.HealthHeight Desc"])
	GUI:CreateSlider(sizesPartySection, "Party.HealthWidth", L["Party Frame Health Width"], 120, 180, 1, L["Party.HealthWidth Desc"])
	GUI:CreateSlider(sizesPartySection, "Party.PowerHeight", L["Party Frame Power Height"], 10, 30, 1, L["Party.PowerHeight Desc"])

	-- Colors Section
	local colorsPartySection = GUI:AddSection(partyCategory, COLORS)
	local healthColorOptions = { -- Health Color Format Dropdown Options
		{ text = "Class", value = 1 },
		{ text = "Dark", value = 2 },
		{ text = "Value", value = 3 },
	}
	GUI:CreateDropdown(colorsPartySection, "Party.HealthbarColor", L["Health Color Format"], healthColorOptions, L["Party.HealthbarColor Desc"])
end

-- Raid Category
local function CreateRaidCategory()
	local raidIcon = "Interface\\Icons\\Achievement_boss_illidan"
	local raidCategory = GUI:AddCategory(L["Raid"], raidIcon)

	-- General Section
	local generalRaidSection = GUI:AddSection(raidCategory, GENERAL)
	GUI:CreateSwitch(generalRaidSection, "Raid.Enable", enableTextColor .. L["Enable Raidframes"], "Toggle the entire raid frame system on/off")
	GUI:CreateSwitch(generalRaidSection, "Raid.MainTankFrames", L["Show MainTank Frames"], L["Raid.MainTankFrames Desc"])

	-- Visibility
	local visibilityRaidSection = GUI:AddSection(raidCategory, L["Visibility"])
	GUI:CreateSwitch(visibilityRaidSection, "Raid.UseRaidForParty", L["Use Raid Frames for Party"], L["UseRaidForParty Desc"])
	GUI:CreateSwitch(visibilityRaidSection, "Raid.ShowRaidSolo", L["Show Raid Frames While Solo"], L["ShowRaidSolo Desc"])
	GUI:CreateSwitch(visibilityRaidSection, "Raid.ShowTeamIndex", L["Show Group Number Team Index"], L["Raid.ShowTeamIndex Desc"])

	-- Layout
	local layoutRaidSection = GUI:AddSection(raidCategory, L["Layout"])
	GUI:CreateSwitch(layoutRaidSection, "Raid.HorizonRaid", L["Horizontal Raid Frames"], L["Raid.HorizonRaid Desc"])
	GUI:CreateSwitch(layoutRaidSection, "Raid.ReverseRaid", L["Reverse Raid Frame Growth"], L["Raid.ReverseRaid Desc"])

	-- Bars
	local barsRaidSection = GUI:AddSection(raidCategory, L["Bars"])
	GUI:CreateSwitch(barsRaidSection, "Raid.PowerBarShow", L["Enable Power Bars"], L["Raid.PowerBarShow Desc"])
	local manaBarSwitch = GUI:CreateSwitch(barsRaidSection, "Raid.ManabarShow", L["Only Show Mana"], L["Raid.ManabarShow Desc"])
	GUI:DependsOn(manaBarSwitch, "Raid.PowerBarShow", true)
	GUI:CreateSwitch(barsRaidSection, "Raid.Smooth", L["Smooth Bar Transition"], L["Raid.Smooth Desc"])

	-- Behavior
	local behaviorRaidSection = GUI:AddSection(raidCategory, L["Behavior"])
	GUI:CreateSwitch(behaviorRaidSection, "Raid.ShowHealPrediction", L["Show HealPrediction Statusbars"], L["Raid.ShowHealPrediction Desc"])
	GUI:CreateSwitch(behaviorRaidSection, "Raid.TargetHighlight", L["Show Highlighted Target"], L["Raid.TargetHighlight Desc"])
	GUI:CreateSwitch(behaviorRaidSection, "Raid.ShowNotHereTimer", L["Show Away/DND Status"], L["Raid.ShowNotHereTimer Desc"])

	-- Sizes
	local sizesRaidSection = GUI:AddSection(raidCategory, L["Sizes"])
	GUI:CreateSlider(sizesRaidSection, "Raid.Height", L["Raidframe Height"], 20, 100, 1, L["Raid.Height Desc"])
	GUI:CreateSlider(sizesRaidSection, "Raid.NumGroups", L["Number Of Groups to Show"], 1, 8, 1, L["Raid.NumGroups Desc"])
	GUI:CreateSlider(sizesRaidSection, "Raid.Width", L["Raidframe Width"], 20, 100, 1, L["Raid.Width Desc"])

	-- Colors & Values
	local colorsRaidSection = GUI:AddSection(raidCategory, L["Colors"])
	local healthColorOptions = {
		{ text = "Class", value = 1 },
		{ text = "Dark", value = 2 },
		{ text = "Value", value = 3 },
	}
	GUI:CreateDropdown(colorsRaidSection, "Raid.HealthbarColor", L["Health Color Format"], healthColorOptions, L["Raid.HealthbarColor Desc"])
	local healthFormatOptions = {
		{ text = "Disable HP", value = 1 },
		{ text = "Health Percentage", value = 2 },
		{ text = "Health Remaining", value = 3 },
		{ text = "Health Lost", value = 4 },
	}
	GUI:CreateDropdown(colorsRaidSection, "Raid.HealthFormat", L["Health Format"], healthFormatOptions, L["Raid.HealthFormat Desc"])

	-- Raid Buffs
	local raidBuffsSection = GUI:AddSection(raidCategory, L["Raid Buffs"])
	local raidBuffsStyleOptions = {
		{ text = "Standard", value = 1 },
		{ text = "Aura Track", value = 2 },
		{ text = "Disable", value = 3 },
	}
	GUI:CreateDropdown(raidBuffsSection, "Raid.RaidBuffsStyle", L["Buff Style"], raidBuffsStyleOptions, L["RaidBuffsStyle Desc"])
	GUI:CreateDropdown(raidBuffsSection, "Raid.RaidBuffs", L["Buff Display & Filtering"], {
		{ text = "Only my buffs", value = 1 },
		{ text = "Only castable buffs", value = 2 },
		{ text = "All buffs", value = 3 },
	}, L["RaidBuffs Desc"])
	GUI:CreateSwitch(raidBuffsSection, "Raid.DesaturateBuffs", L["Desaturate non-player buffs"], L["DesaturateBuffs Desc"])

	-- Aura Track
	local auraTrackSection = GUI:AddSection(raidCategory, L["Aura Track"])
	GUI:CreateSwitch(auraTrackSection, "Raid.AuraTrack", L["Enable aura tracking for healers (replaces buffs)"], L["AuraTrack Desc"])
	GUI:CreateSwitch(auraTrackSection, "Raid.AuraTrackIcons", L["Use square icons instead of bars"], L["AuraTrackIcons Desc"])
	GUI:CreateSwitch(auraTrackSection, "Raid.AuraTrackSpellTextures", L["Show spell textures on aura icons"], L["AuraTrackSpellTextures Desc"])
	GUI:CreateSlider(auraTrackSection, "Raid.AuraTrackThickness", L["Aura bar thickness (px)"], 2, 10, 1, L["AuraTrackThickness Desc"])

	-- Raid Debuffs
	local raidDebuffsSection = GUI:AddSection(raidCategory, L["Raid Debuffs"])
	GUI:CreateSwitch(raidDebuffsSection, "Raid.DebuffWatch", L["Enable debuff tracking (auto-filter by PvP/PvE)"], L["DebuffWatch Desc"])
	GUI:CreateSwitch(raidDebuffsSection, "Raid.DebuffWatchDefault", L["Use built-in debuff lists (PvE & PvP)"], L["DebuffWatchDefault Desc"])
end

-- Skins Category
local function CreateSkinsCategory()
	local skinsIcon = "Interface\\Icons\\INV_Misc_Desecrated_ClothChest"
	local skinsCategory = GUI:AddCategory(L["Skins"], skinsIcon)

	local function ResetDetails()
		local skinsModule = K:GetModule("Skins")
		if skinsModule and skinsModule.ResetDetailsAnchor then
			skinsModule:ResetDetailsAnchor(true)
		end
	end

	-- Blizzard Skins
	local blizzardSkinsSection = GUI:AddSection(skinsCategory, L["Blizzard Skins"])
	GUI:CreateSwitch(blizzardSkinsSection, "Skins.BlizzardFrames", L["Skin Some Blizzard Frames & Objects"], L["Skins.BlizzardFrames Desc"])
	GUI:CreateSwitch(blizzardSkinsSection, "Skins.TalkingHeadBackdrop", L["TalkingHead Skin"], L["Skins.TalkingHeadBackdrop Desc"])
	GUI:CreateSwitch(blizzardSkinsSection, "Skins.ChatBubbles", L["ChatBubbles Skin"], L["Skins.ChatBubbles Desc"])
	GUI:CreateSlider(blizzardSkinsSection, "Skins.ChatBubbleAlpha", L["ChatBubbles Background Alpha"], 0, 1, 0.1, L["Skins.ChatBubbleAlpha Desc"])

	-- AddOn Skins
	local addonSkinsSection = GUI:AddSection(skinsCategory, L["AddOn Skins"])
	GUI:CreateSwitch(addonSkinsSection, "Skins.Bartender4", L["Bartender4 Skin"], L["Skins.Bartender4 Desc"])
	GUI:CreateSwitch(addonSkinsSection, "Skins.BigDebuffs", "BigDebuffs Support", L["Skins.BigDebuffs Desc"])
	GUI:CreateSwitch(addonSkinsSection, "Skins.BigWigs", L["BigWigs Skin"], L["Skins.BigWigs Desc"])
	GUI:CreateSwitch(addonSkinsSection, "Skins.ButtonForge", L["ButtonForge Skin"], L["Skins.ButtonForge Desc"])
	GUI:CreateSwitch(addonSkinsSection, "Skins.ChocolateBar", L["ChocolateBar Skin"], L["Skins.ChocolateBar Desc"])
	GUI:CreateSwitch(addonSkinsSection, "Skins.DeadlyBossMods", L["Deadly Boss Mods Skin"], L["Skins.DeadlyBossMods Desc"])
	GUI:CreateSwitch(addonSkinsSection, "Skins.Details", L["Details Skin"], L["Skins.Details Desc"])
	GUI:CreateSwitch(addonSkinsSection, "Skins.Dominos", L["Dominos Skin"], L["Skins.Dominos Desc"])
	GUI:CreateSwitch(addonSkinsSection, "Skins.Hekili", "Hekili Skin", L["Skins.Hekili Desc"])
	GUI:CreateSwitch(addonSkinsSection, "Skins.RareScanner", L["RareScanner Skin"], L["Skins.RareScanner Desc"])
	GUI:CreateSwitch(addonSkinsSection, "Skins.WeakAuras", L["WeakAuras Skin"], L["Skins.WeakAuras Desc"])

	-- Details Reset
	GUI:CreateButtonWidget(addonSkinsSection, "Skins.ResetDetails", L["Reset Details"], L["Reset Details"], L["ResetDetails Desc"], function()
		ResetDetails()
	end)

	-- Font Tweaks
	local fontTweaksSection = GUI:AddSection(skinsCategory, L["Font Tweaks"])
	GUI:CreateSlider(fontTweaksSection, "Skins.QuestFontSize", L["Adjust QuestFont Size"], 10, 30, 1, L["QuestFontSize Desc"])
	GUI:CreateSlider(fontTweaksSection, "Skins.ObjectiveFontSize", L["Adjust ObjectiveFont Size"], 10, 30, 1, L["ObjectiveFontSize Desc"])
end

-- Tooltip
local function CreateTooltipCategory()
	local tooltipIcon = "Interface\\Icons\\Inv_inscription_tooltip_darkmooncard_mop"
	local tooltipCategory = GUI:AddCategory(L["Tooltip"], tooltipIcon)

	-- General
	local generalTooltipSection = GUI:AddSection(tooltipCategory, GENERAL)
	GUI:CreateSwitch(generalTooltipSection, "Tooltip.Enable", enableTextColor .. L["Enable Tooltip"], L["Enable Desc"])
	GUI:CreateSwitch(generalTooltipSection, "Tooltip.CombatHide", L["Hide Tooltip in Combat"], L["Tooltip.CombatHide Desc"])
	GUI:CreateSwitch(generalTooltipSection, "Tooltip.Icons", L["Item Icons"], L["Tooltip.Icons Desc"])
	GUI:CreateSwitch(generalTooltipSection, "Tooltip.ShowIDs", L["Show Tooltip IDs"], L["Tooltip.ShowIDs Desc"])

	-- Appearance
	local appearanceTooltipSection = GUI:AddSection(tooltipCategory, L["Appearance"])
	GUI:CreateSwitch(appearanceTooltipSection, "Tooltip.ClassColor", L["Quality Color Border"], L["Tooltip.ClassColor Desc"])
	GUI:CreateSwitch(appearanceTooltipSection, "Tooltip.FactionIcon", L["Show Faction Icon"], L["Tooltip.FactionIcon Desc"])
	GUI:CreateSwitch(appearanceTooltipSection, "Tooltip.HideJunkGuild", L["Abbreviate Guild Names"], L["Tooltip.HideJunkGuild Desc"])
	GUI:CreateSwitch(appearanceTooltipSection, "Tooltip.HideRank", L["Hide Guild Rank"], L["Tooltip.HideRank Desc"])
	GUI:CreateSwitch(appearanceTooltipSection, "Tooltip.HideRealm", L["Show realm name by SHIFT"], L["Tooltip.HideRealm Desc"])
	GUI:CreateSwitch(appearanceTooltipSection, "Tooltip.HideTitle", L["Hide Player Title"], L["Tooltip.HideTitle Desc"])

	local healthBarTextOptions = {
		{ text = L["Current / Max"] or "Current / Max", value = "currentmax" },
		{ text = L["Current Only"] or "Current Only", value = "current" },
	}
	GUI:CreateDropdown(appearanceTooltipSection, "Tooltip.HealthBarText", L["Health Bar Text"], healthBarTextOptions, L["Tooltip.HealthBarText Desc"])
	GUI:CreateSlider(appearanceTooltipSection, "Tooltip.StatusBarHeight", L["Status Bar Height"] or "Status Bar Height", 8, 24, 1, L["Tooltip.StatusBarHeight Desc"])

	-- Tooltip Anchor
	local tooltipAnchorOptions = {
		{ text = "TOPLEFT", value = 1 },
		{ text = "TOPRIGHT", value = 2 },
		{ text = "BOTTOMLEFT", value = 3 },
		{ text = "BOTTOMRIGHT", value = 4 },
	}
	GUI:CreateDropdown(appearanceTooltipSection, "Tooltip.TipAnchor", L["Tooltip Anchor"], tooltipAnchorOptions, L["TooltipAnchor Desc"])

	-- Advanced
	local advancedTooltipSection = GUI:AddSection(tooltipCategory, L["Advanced"])
	GUI:CreateSwitch(advancedTooltipSection, "Tooltip.Achievements", L["Show Achievement Status"], L["Tooltip.Achievements Desc"])
	GUI:CreateSwitch(advancedTooltipSection, "Tooltip.InstanceLock", L["Show Instance Lock Compare"], L["Tooltip.InstanceLock Desc"])
	GUI:CreateSwitch(advancedTooltipSection, "Tooltip.LFDRole", L["Show Roles Assigned Icon"], L["Tooltip.LFDRole Desc"])
	GUI:CreateSwitch(advancedTooltipSection, "Tooltip.SpecLevelByShift", L["Show Spec/ItemLevel by SHIFT"], L["Tooltip.SpecLevelByShift Desc"])
	GUI:CreateSwitch(advancedTooltipSection, "Tooltip.TargetBy", L["Show Player Targeted By"], L["Tooltip.TargetBy Desc"])
	local vendorLocationMap = GUI:CreateSwitch(advancedTooltipSection, "Tooltip.VendorLocationOpenMap", L["Open Map on Vendor Waypoint"], L["Tooltip.VendorLocationOpenMap Desc"])
	GUI:CreateSwitch(advancedTooltipSection, "Tooltip.VendorLocation", L["Show Vendor Locations"], L["Tooltip.VendorLocation Desc"])
	GUI:DependsOn(vendorLocationMap, "Tooltip.VendorLocation", true)

	-- Follow Cursor
	local cursorModeOptions = {
		{ text = DISABLE, value = 1 },
		{ text = "LEFT", value = 2 },
		{ text = "TOP", value = 3 },
		{ text = "RIGHT", value = 4 },
	}
	GUI:CreateDropdown(advancedTooltipSection, "Tooltip.CursorMode", L["Follow Cursor"], cursorModeOptions, L["Tooltip.CursorMode Desc"])

	-- RaiderIO
	if not K.CheckAddOnState("RaiderIO") then
		local raiderIOSection = GUI:AddSection(tooltipCategory, L["RaiderIO"])
		GUI:CreateSwitch(raiderIOSection, "Tooltip.MDScore", L["Show Mythic+ Rating"], L["Show Mythic+ Rating Desc"])
	end
end

-- Unitframe
local function CreateUnitframeCategory()
	local unitframeIcon = "Interface\\Icons\\Spell_Shadow_AntiShadow"
	local unitframeCategory = GUI:AddCategory(L["Unitframe"], unitframeIcon)

	-- General
	local generalUnitframeSection = GUI:AddSection(unitframeCategory, GENERAL)
	GUI:CreateSwitch(generalUnitframeSection, "Unitframe.Enable", enableTextColor .. L["Enable Unitframes"], "Toggle the entire unitframe system on/off")
	GUI:CreateSwitch(generalUnitframeSection, "Unitframe.CastClassColor", L["Class Color Castbars"], L["Unitframe.CastClassColor Desc"])
	GUI:CreateSwitch(generalUnitframeSection, "Unitframe.CastReactionColor", L["Reaction Color Castbars"], L["Unitframe.CastReactionColor Desc"])
	GUI:CreateSwitch(generalUnitframeSection, "Unitframe.ClassResources", L["Show Class Resources"], L["Unitframe.ClassResources Desc"])
	GUI:CreateSwitch(generalUnitframeSection, "Unitframe.DebuffHighlight", L["Show Health Debuff Highlight"], L["Unitframe.DebuffHighlight Desc"])
	GUI:CreateSwitch(generalUnitframeSection, "Unitframe.PvPIndicator", L["Show PvP Indicator on Player / Target"], L["Unitframe.PvPIndicator Desc"])
	GUI:CreateSwitch(generalUnitframeSection, "Unitframe.Range", L["Unitframe Range Fading"], L["UnitframeRange Desc"])
	GUI:CreateSwitch(generalUnitframeSection, "Unitframe.ResurrectSound", L["Sound Played When You Are Resurrected"], L["Unitframe.ResurrectSound Desc"])
	GUI:CreateSwitch(generalUnitframeSection, "Unitframe.ShowHealPrediction", L["Show HealPrediction Statusbars"], L["Unitframe.ShowHealPrediction Desc"])
	GUI:CreateSwitch(generalUnitframeSection, "Unitframe.Smooth", L["Smooth Bars"], L["Unitframe.Smooth Desc"])
	GUI:CreateSwitch(generalUnitframeSection, "Unitframe.Stagger", L["Show |CFF00FF96Monk|r Stagger Bar"], L["Unitframe.Stagger Desc"])
	GUI:CreateSlider(generalUnitframeSection, "Unitframe.AllTextScale", L["(TEST) Scale All Unitframe Texts"], 0.8, 1.5, 0.05, L["AllTextScale Desc"])

	-- Player - General
	local playerGeneralSection = GUI:AddSection(unitframeCategory, PLAYER .. " - General")
	GUI:CreateSwitch(playerGeneralSection, "Unitframe.AdditionalPower", L["Show Additional Mana Power (|CFFFF7D0ADruid|r, |CFFFFFFFFPriest|r, |CFF0070DEShaman|r)"], L["Unitframe.AdditionalPower Desc"])
	GUI:CreateSwitch(playerGeneralSection, "Unitframe.ShowPlayerLevel", L["Show Player Frame Level"], L["Unitframe.ShowPlayerLevel Desc"])

	-- Player - Auras
	local playerAurasSection = GUI:AddSection(unitframeCategory, PLAYER .. " - Auras")
	GUI:CreateSwitch(playerAurasSection, "Unitframe.PlayerBuffs", L["Show Player Frame Buffs"], L["Unitframe.PlayerBuffs Desc"])
	GUI:CreateSwitch(playerAurasSection, "Unitframe.PlayerDebuffs", L["Show Player Frame Debuffs"], L["Unitframe.PlayerDebuffs Desc"])
	GUI:CreateSlider(playerAurasSection, "Unitframe.PlayerBuffsPerRow", L["Number of Buffs Per Row"], 4, 10, 1, L["Unitframe.PlayerBuffsPerRow Desc"])
	GUI:CreateSlider(playerAurasSection, "Unitframe.PlayerDebuffsPerRow", L["Number of Debuffs Per Row"], 4, 10, 1, L["Unitframe.PlayerDebuffsPerRow Desc"])

	-- Player - Castbar
	local playerCastbarSection = GUI:AddSection(unitframeCategory, PLAYER .. " - Castbar")
	GUI:CreateSwitch(playerCastbarSection, "Unitframe.PlayerCastbar", L["Enable Player CastBar"], L["Unitframe.PlayerCastbar Desc"])
	GUI:CreateSwitch(playerCastbarSection, "Unitframe.PlayerCastbarIcon", L["Enable Player CastBar"] .. " Icon", L["Unitframe.PlayerCastbarIcon Desc"])
	GUI:CreateSwitch(playerCastbarSection, "Unitframe.CastbarLatency", L["Show Castbar Latency"], L["Unitframe.CastbarLatency Desc"])
	GUI:CreateSwitch(playerCastbarSection, "Unitframe.GlobalCooldown", L["Show Global Cooldown Spark"], L["GlobalCooldownSpark Desc"])
	GUI:CreateSlider(playerCastbarSection, "Unitframe.PlayerCastbarHeight", L["Player Castbar Height"], 20, 40, 1, L["Unitframe.PlayerCastbarHeight Desc"])
	GUI:CreateSlider(playerCastbarSection, "Unitframe.PlayerCastbarWidth", L["Player Castbar Width"], 100, 800, 1, L["Unitframe.PlayerCastbarWidth Desc"])

	-- Player - Frame
	local playerFrameSection = GUI:AddSection(unitframeCategory, PLAYER .. " - Frame")
	GUI:CreateSlider(playerFrameSection, "Unitframe.PlayerHealthHeight", L["Player Frame Height"], 20, 75, 1, L["Unitframe.PlayerHealthHeight Desc"])
	GUI:CreateSlider(playerFrameSection, "Unitframe.PlayerHealthWidth", L["Player Frame Width"], 100, 300, 1, L["Unitframe.PlayerHealthWidth Desc"])
	GUI:CreateSlider(playerFrameSection, "Unitframe.PlayerPowerHeight", L["Player Power Bar Height"], 10, 40, 1, L["PlayerPowerHeight Desc"])

	-- Target
	local targetUnitframeSection = GUI:AddSection(unitframeCategory, TARGET)
	GUI:CreateSwitch(targetUnitframeSection, "Unitframe.OnlyShowPlayerDebuff", L["Only Show Your Debuffs"], L["Unitframe.OnlyShowPlayerDebuff Desc"])
	GUI:CreateSwitch(targetUnitframeSection, "Unitframe.TargetBuffs", L["Show Target Frame Buffs"], L["Unitframe.TargetBuffs Desc"])
	GUI:CreateSwitch(targetUnitframeSection, "Unitframe.TargetCastbar", L["Enable Target CastBar"], L["Unitframe.TargetCastbar Desc"])
	GUI:CreateSwitch(targetUnitframeSection, "Unitframe.TargetCastbarIcon", L["Enable Target CastBar"] .. " Icon", L["Unitframe.TargetCastbarIcon Desc"])
	GUI:CreateSwitch(targetUnitframeSection, "Unitframe.TargetDebuffs", L["Show Target Frame Debuffs"], L["Unitframe.TargetDebuffs Desc"])

	-- Target Frame Sizing
	GUI:CreateSlider(targetUnitframeSection, "Unitframe.TargetBuffsPerRow", L["Number of Buffs Per Row"], 4, 10, 1, L["Unitframe.TargetBuffsPerRow Desc"])
	GUI:CreateSlider(targetUnitframeSection, "Unitframe.TargetDebuffsPerRow", L["Number of Debuffs Per Row"], 4, 10, 1, L["Unitframe.TargetDebuffsPerRow Desc"])
	GUI:CreateSlider(targetUnitframeSection, "Unitframe.TargetPowerHeight", "Target Power Bar Height", 10, 40, 1, L["Unitframe.TargetPowerHeight Desc"])
	GUI:CreateSlider(targetUnitframeSection, "Unitframe.TargetHealthHeight", L["Target Frame Height"], 20, 75, 1, L["Unitframe.TargetHealthHeight Desc"])
	GUI:CreateSlider(targetUnitframeSection, "Unitframe.TargetHealthWidth", L["Target Frame Width"], 100, 300, 1, L["Unitframe.TargetHealthWidth Desc"])
	GUI:CreateSlider(targetUnitframeSection, "Unitframe.TargetCastbarHeight", L["Target Castbar Height"], 20, 40, 1, L["Unitframe.TargetCastbarHeight Desc"])
	GUI:CreateSlider(targetUnitframeSection, "Unitframe.TargetCastbarWidth", L["Target Castbar Width"], 100, 800, 1, L["Unitframe.TargetCastbarWidth Desc"])

	-- Pet
	local petUnitframeSection = GUI:AddSection(unitframeCategory, PET)
	GUI:CreateSwitch(petUnitframeSection, "Unitframe.HidePet", "Hide Pet Frame", L["Unitframe.HidePet Desc"])
	GUI:CreateSwitch(petUnitframeSection, "Unitframe.HidePetLevel", L["Hide Pet Level"], L["Unitframe.HidePetLevel Desc"])
	GUI:CreateSwitch(petUnitframeSection, "Unitframe.HidePetName", L["Hide Pet Name"], L["Unitframe.HidePetName Desc"])
	GUI:CreateSlider(petUnitframeSection, "Unitframe.PetHealthHeight", L["Pet Frame Height"], 10, 50, 1, L["Unitframe.PetHealthHeight Desc"])
	GUI:CreateSlider(petUnitframeSection, "Unitframe.PetHealthWidth", L["Pet Frame Width"], 80, 300, 1, L["Unitframe.PetHealthWidth Desc"])
	GUI:CreateSlider(petUnitframeSection, "Unitframe.PetPowerHeight", L["Pet Power Bar"], 10, 50, 1, L["Unitframe.PetPowerHeight Desc"])

	-- Target Of Target
	local totUnitframeSection = GUI:AddSection(unitframeCategory, L["Target Of Target"])
	GUI:CreateSwitch(totUnitframeSection, "Unitframe.HideTargetofTarget", L["Hide TargetofTarget Frame"], L["Unitframe.HideTargetofTarget Desc"])
	GUI:CreateSwitch(totUnitframeSection, "Unitframe.HideTargetOfTargetLevel", L["Hide TargetofTarget Level"], L["Unitframe.HideTargetOfTargetLevel Desc"])
	GUI:CreateSwitch(totUnitframeSection, "Unitframe.HideTargetOfTargetName", L["Hide TargetofTarget Name"], L["Unitframe.HideTargetOfTargetName Desc"])
	GUI:CreateSlider(totUnitframeSection, "Unitframe.TargetTargetHealthHeight", L["Target of Target Frame Height"], 10, 50, 1, L["Unitframe.TargetTargetHealthHeight Desc"])
	GUI:CreateSlider(totUnitframeSection, "Unitframe.TargetTargetHealthWidth", L["Target of Target Frame Width"], 80, 300, 1, L["Unitframe.TargetTargetHealthWidth Desc"])
	GUI:CreateSlider(totUnitframeSection, "Unitframe.TargetTargetPowerHeight", L["Target of Target Power Height"], 10, 50, 1, L["TargetTargetPowerHeight Desc"])

	-- Focus
	local focusUnitframeSection = GUI:AddSection(unitframeCategory, FOCUS)
	GUI:CreateSwitch(focusUnitframeSection, "Unitframe.FocusBuffs", L["Show Focus Frame Buffs"], L["FocusBuffs Desc"])
	GUI:CreateSwitch(focusUnitframeSection, "Unitframe.FocusCastbar", L["Enable Focus CastBar"], L["FocusCastbar Desc"])
	GUI:CreateSwitch(focusUnitframeSection, "Unitframe.FocusCastbarIcon", L["Enable Focus CastBar Icon"], L["FocusCastbarIcon Desc"])
	GUI:CreateSwitch(focusUnitframeSection, "Unitframe.FocusDebuffs", L["Show Focus Frame Debuffs"], L["FocusDebuffs Desc"])
	GUI:CreateSlider(focusUnitframeSection, "Unitframe.FocusPowerHeight", L["Focus Power Bar Height"], 10, 40, 1, L["FocusPowerHeight Desc"])
	GUI:CreateSlider(focusUnitframeSection, "Unitframe.FocusHealthHeight", L["Focus Frame Height"], 20, 75, 1, L["Unitframe.FocusHealthHeight Desc"])
	GUI:CreateSlider(focusUnitframeSection, "Unitframe.FocusHealthWidth", L["Focus Frame Width"], 100, 300, 1, L["Unitframe.FocusHealthWidth Desc"])

	-- Focus Target
	local focusTargetSection = GUI:AddSection(unitframeCategory, "Focus Target")
	GUI:CreateSwitch(focusTargetSection, "Unitframe.HideFocusTarget", "Hide Focus Target Frame", L["Unitframe.HideFocusTarget Desc"])
	GUI:CreateSwitch(focusTargetSection, "Unitframe.HideFocusTargetLevel", "Hide Focus Target Level", L["Unitframe.HideFocusTargetLevel Desc"])
	GUI:CreateSwitch(focusTargetSection, "Unitframe.HideFocusTargetName", "Hide Focus Target Name", L["Unitframe.HideFocusTargetName Desc"])
	GUI:CreateSlider(focusTargetSection, "Unitframe.FocusTargetHealthHeight", "Focus Target Frame Height", 10, 50, 1, L["Unitframe.FocusTargetHealthHeight Desc"])
	GUI:CreateSlider(focusTargetSection, "Unitframe.FocusTargetHealthWidth", "Focus Target Frame Width", 80, 300, 1, L["Unitframe.FocusTargetHealthWidth Desc"])
	GUI:CreateSlider(focusTargetSection, "Unitframe.FocusTargetPowerHeight", "Focus Target Power Height", 10, 50, 1, L["Unitframe.FocusTargetPowerHeight Desc"])

	-- Unitframe Misc
	local miscUnitframeSection = GUI:AddSection(unitframeCategory, "Unitframe Misc")

	-- Health Color Format
	local healthColorOptions = {
		{ text = "Class", value = 1 },
		{ text = "Dark", value = 2 },
		{ text = "Value", value = 3 },
	}
	GUI:CreateDropdown(miscUnitframeSection, "Unitframe.HealthbarColor", L["Health Color Format"], healthColorOptions, L["Unitframe.HealthbarColor Desc"])

	-- Portrait Style
	local portraitStyleOptions = {
		{ text = "No Portraits", value = 0 },
		{ text = "Default Portraits", value = 1 },
		{ text = "Class Portraits", value = 2 },
		{ text = "New Class Portraits", value = 3 },
		{ text = "Overlay Portrait", value = 4 },
		{ text = "3D Portraits", value = 5 },
	}
	GUI:CreateDropdown(miscUnitframeSection, "Unitframe.PortraitStyle", L["Unitframe Portrait Style"], portraitStyleOptions, L["Unitframe.PortraitStyle Desc"])
end

-- WorldMap
local function CreateWorldMapCategory()
	local worldMapIcon = "Interface\\Icons\\Icon_treasuremap"
	local worldMapCategory = GUI:AddCategory(L["WorldMap"], worldMapIcon)

	-- General
	local generalWorldMapSection = GUI:AddSection(worldMapCategory, GENERAL)
	GUI:CreateSwitch(generalWorldMapSection, "WorldMap.Coordinates", L["Show Player/Mouse Coordinates"], L["WorldMap.Coordinates Desc"])
	GUI:CreateSwitch(generalWorldMapSection, "WorldMap.FadeWhenMoving", L["Fade Worldmap When Moving"], L["WorldMap.FadeWhenMoving Desc"])
	GUI:CreateSwitch(generalWorldMapSection, "WorldMap.SmallWorldMap", L["Show Smaller Worldmap"], L["WorldMap.SmallWorldMap Desc"])

	-- Waypoint options
	GUI:CreateSwitch(generalWorldMapSection, "WorldMap.AutoOpenWaypoint", L["Auto-open world map when setting waypoint"], L["WorldMap.AutoOpenWaypoint Desc"])

	-- WorldMap Reveal
	local revealWorldMapSection = GUI:AddSection(worldMapCategory, "WorldMap Reveal")
	GUI:CreateSwitch(revealWorldMapSection, "WorldMap.MapRevealGlow", L["Map Reveal Shadow"], L["MapRevealTip"])

	-- Sizes
	local sizesWorldMapSection = GUI:AddSection(worldMapCategory, L["Sizes"])
	GUI:CreateSlider(sizesWorldMapSection, "WorldMap.AlphaWhenMoving", L["Alpha When Moving"], 0.1, 1, 0.01, L["WorldMap.AlphaWhenMoving Desc"])
end

-- Credits
local function CreateCreditsCategory()
	local creditsCategory = GUI:AddCategory(L["Credits"], "Interface\\Icons\\Achievement_General")
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
CreateRaidCategory()
CreateSkinsCategory()
CreateTooltipCategory()
CreateUnitframeCategory()
CreateWorldMapCategory()
-- Credits are always last!
CreateCreditsCategory()
