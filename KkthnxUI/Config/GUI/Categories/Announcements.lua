local K = KkthnxUI[1]
K.GUIBuilder = K.GUIBuilder or {}
local B = K.GUIBuilder

function B.CreateAnnouncementsCategory()
	if not B or not B.Ready() then return end
	local K, GUI, C, L, enableTextColor = B.K, B.GUI, B.C, B.L, B.enableTextColor
	local GENERAL, COLORS, PLAYER, TARGET, FILTERS = B.GENERAL, B.COLORS, B.PLAYER, B.TARGET, B.FILTERS

	local announcementsCategory = GUI:AddCategory(L["Announcements"], "Interface\\Icons\\Ability_Warrior_BattleShout", "Announcements")

	-- General
	local generalAnnouncementsSection = GUI:AddSection(announcementsCategory, GENERAL)
	GUI:CreateSwitch(generalAnnouncementsSection, "Announcements.ItemAlert", L["Announce Spells And Items"], L["Announcements.ItemAlert Desc"])
	GUI:CreateSwitch(generalAnnouncementsSection, "Announcements.PullCountdown", L["Announce Pull Countdown (/pc #)"], L["Announcements.PullCountdown Desc"])
	GUI:CreateSwitch(generalAnnouncementsSection, "Announcements.ResetInstance", L["Alert Group After Instance Resetting"], L["Announcements.ResetInstance Desc"])

	-- Combat
	local combatAnnouncementsSection = GUI:AddSection(announcementsCategory, L["Combat"])
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
