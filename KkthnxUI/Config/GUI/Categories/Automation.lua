local K = KkthnxUI[1]
K.GUIBuilder = K.GUIBuilder or {}
local B = K.GUIBuilder

function B.CreateAutomationCategory()
	if not B or not B.Ready() then return end
	local K, GUI, C, L, enableTextColor = B.K, B.GUI, B.C, B.L, B.enableTextColor
	local GENERAL, COLORS, PLAYER, TARGET, FILTERS = B.GENERAL, B.COLORS, B.PLAYER, B.TARGET, B.FILTERS

	local automationIcon = "Interface\\Icons\\Ability_Warrior_OffensiveStance"
	local category = GUI:AddCategory(L["Automation"], automationIcon, "Automation")

	-- Invite
	local inviteSection = GUI:AddSection(category, L["Invite Management"])

	GUI:CreateSwitch(inviteSection, "Automation.AutoInvite", L["Accept Invites From Friends & Guild Members"], L["AutoInvite Desc"])
	local declineGuildInvites = GUI:CreateSwitch(inviteSection, "Automation.AutoDeclineGuildInvites", L["Decline Guild Invites From Strangers"], L["AutoDeclineGuildInvites Desc"])
	-- REASON: granular trust/notify
	-- controls, all dependent on the master toggle above.
	local declineFromFriends = GUI:CreateSwitch(inviteSection, "Automation.AutoDeclineGuildInvitesFromFriends", L["Allow From Friends"], L["AutoDeclineGuildInvitesFromFriends Desc"])
	local declineFromGuild = GUI:CreateSwitch(inviteSection, "Automation.AutoDeclineGuildInvitesFromGuild", L["Allow From Guild"], L["AutoDeclineGuildInvitesFromGuild Desc"])
	local declineAnnounce = GUI:CreateSwitch(inviteSection, "Automation.AutoDeclineGuildInvitesAnnounce", L["Announce Blocks"], L["AutoDeclineGuildInvitesAnnounce Desc"])
	local declineSound = GUI:CreateSwitch(inviteSection, "Automation.AutoDeclineGuildInvitesSound", L["Play Sound"], L["AutoDeclineGuildInvitesSound Desc"])
	GUI:DependsOn(declineFromFriends, "Automation.AutoDeclineGuildInvites", true)
	GUI:DependsOn(declineFromGuild, "Automation.AutoDeclineGuildInvites", true)
	GUI:DependsOn(declineAnnounce, "Automation.AutoDeclineGuildInvites", true)
	GUI:DependsOn(declineSound, "Automation.AutoDeclineGuildInvites", true)
	local guildStatsButton = GUI:CreateButtonWidget(inviteSection, "Automation.GuildInviteStats", L["Guild Invite Stats"], L["Print"], L["GuildInviteStats Desc"], function()
		local automation = K:GetModule("Automation")
		if automation and automation.PrintGuildInviteStats then
			automation:PrintGuildInviteStats()
		end
	end)
	GUI:DependsOn(guildStatsButton, "Automation.AutoDeclineGuildInvites", true)
	GUI:CreateSwitch(inviteSection, "Automation.AutoDeclineDuels", L["Decline PvP Duels"], L["AutoDeclineDuels Desc"])
	GUI:CreateSwitch(inviteSection, "Automation.AutoDeclinePetDuels", L["Decline Pet Duels"], L["AutoDeclinePetDuels Desc"])
	GUI:CreateSwitch(inviteSection, "Automation.AutoPartySync", L["Accept PartySync From Friends & Guild Members"], L["AutoPartySync Desc"])
	GUI:CreateButtonWidget(inviteSection, "Automation.ManageWhisperInvite", L["Auto Accept Invite Keyword"], L["Open GUI"], L["WhisperInvite Desc"], function()
		if K.ExtraGUI and K.ExtraGUI.ToggleExtraConfig then
			K.ExtraGUI:ToggleExtraConfig("Automation.WhisperInvite", L["Auto Accept Invite Keyword"])
		end
	end)
	GUI:CreateSwitch(inviteSection, "Automation.WhisperInviteRestriction", L["Whisper Invite Friends/Guild Only"], L["Automation.WhisperInviteRestriction Desc"])

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
	GUI:CreateSwitch(miscSection, "Automation.HolidayDungeon", L["Holiday Dungeon Nudge"], L["HolidayDungeon Desc"])
	GUI:CreateSwitch(miscSection, "Automation.AuctionSearchFallback", L["Auction Search Fallback"], L["AuctionSearchFallback Desc"])
	GUI:CreateSwitch(miscSection, "Automation.AuctionSearchHistory", L["Auction Search History"], L["Automation.AuctionSearchHistory Desc"])
	local ashMax = GUI:CreateSlider(miscSection, "Automation.AuctionSearchHistoryMax", L["Recent Search Count"], 3, 10, 1, L["Automation.AuctionSearchHistoryMax Desc"])
	GUI:DependsOn(ashMax, "Automation.AuctionSearchHistory", true)
	GUI:CreateSwitch(miscSection, "Automation.SmartFishing", L["Smart Fishing"], L["Automation.SmartFishing Desc"])
	GUI:CreateSwitch(miscSection, "Automation.AutoGoodbye", L["Say Goodbye After Dungeon Completion"], L["AutoGoodbye Desc"])
	GUI:CreateSwitch(miscSection, "Automation.AutoKeystone", L["Auto Place Mythic Keystones"], L["AutoKeystone Desc"])
	GUI:CreateSwitch(miscSection, "Automation.AutoRelease", L["Auto Release in Battlegrounds & Arenas"], L["AutoRelease Desc"])
	GUI:CreateSwitch(miscSection, "Automation.AutoScreenshot", L["Auto Screenshot Achievements"], L["AutoScreenshot Desc"])
	GUI:CreateSwitch(miscSection, "Automation.AutoSetRole", L["Auto Set Your Role In Groups"], L["AutoSetRole Desc"])
	GUI:CreateSwitch(miscSection, "Automation.ConfirmCinematicSkip", L["Quick Skip Cinematics (Key Press)"], L["ConfirmCinematicSkip Desc"])
	GUI:CreateSwitch(miscSection, "Automation.AutoSummon", L["Auto Accept Summon Requests"], L["AutoSummon Desc"])
	GUI:CreateSwitch(miscSection, "Automation.NoBadBuffs", L["Automatically Remove Annoying Buffs"], L["NoBadBuffs Desc"])
	GUI:CreateSwitch(miscSection, "Automation.SmartTracking", L["Smart Minimap Tracking"], L["Automation.SmartTracking Desc"])

	-- Auto-Quest
	local listsSection = GUI:AddSection(category, L["Auto-Quest Lists"])
	GUI:CreateSwitch(listsSection, "Automation.AutoQuestAcceptRegular", L["Accept Regular Quests"], L["Automation.AutoQuestAcceptRegular Desc"])
	GUI:CreateSwitch(listsSection, "Automation.AutoQuestAcceptDaily", L["Accept Daily Quests"], L["Automation.AutoQuestAcceptDaily Desc"])
	GUI:CreateSwitch(listsSection, "Automation.AutoQuestAcceptWeekly", L["Accept Weekly Quests"], L["Automation.AutoQuestAcceptWeekly Desc"])
	GUI:CreateSwitch(listsSection, "Automation.AutoQuestProtectTurnIns", L["Protect Costly Quest Turn-Ins"], L["Automation.AutoQuestProtectTurnIns Desc"])
	GUI:CreateSwitch(listsSection, "Automation.AutoQuestSkipGossip", L["Auto-Skip Story Gossip"], L["Automation.AutoQuestSkipGossip Desc"])
	GUI:CreateButtonWidget(listsSection, "Automation.ManageAutoQuestIgnore", L["Auto-Quest Ignore NPCs"], L["Open"], L["Automation.ManageAutoQuestIgnore Desc"], function()
		if K.ExtraGUI and K.ExtraGUI.ToggleExtraConfig then
			K.ExtraGUI:ToggleExtraConfig("Automation.AutoQuestIgnoreNPC", L["Auto-Quest Ignore NPCs"])
		end
	end)
end
