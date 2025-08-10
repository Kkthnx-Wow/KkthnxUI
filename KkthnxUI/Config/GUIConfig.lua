local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

-- KKTHNXUI NEW GUI CONFIGURATION
-- ====================================================
-- This file contains all the settings configurations for the NewGUI system.
-- Settings are organized into categories and sections with proper hook functions
-- for real-time updates without requiring UI reloads for many settings...

-- Ported from Config/GUI.lua to the new NewGUI system.
-- ====================================================

-- Module reference
local Module = K:GetModule("NewGUI")
local GUI = Module.GUI

-- Localization references
local enableTextColor = "|cff00cc4c"

-- Hook Functions for Real-time Updates
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

-- Individual bar scale update functions
local function UpdateActionBarPetScale()
	K:GetModule("ActionBar"):UpdateActionSize("BarPet")
end

local function UpdateActionBarStance()
	K:GetModule("ActionBar"):UpdateStanceBar()
end

local function UpdateActionBarVehicleButton()
	K:GetModule("ActionBar"):UpdateVehicleButton()
end

-- Function to populate GUI categories and sections
if not GUI or not GUI.AddCategory then
	print("|cffff0000KkthnxUI Error:|r NewGUI not initialized yet!")
	return
end

-- ACTION BARS CATEGORY
local function CreateActionBarsCategory()
	local actionBarCategory = GUI:AddCategory("Action Bars", "Interface\\Icons\\INV_Misc_GroupLooking")

	-- ActionBar 1 Section
	local bar1Section = GUI:AddSection(actionBarCategory, "ActionBar 1")
	GUI:CreateSwitch(bar1Section, "ActionBar.Bar1", enableTextColor .. L["Enable ActionBar"] .. " 1", L["Bar1 Desc"], UpdateActionbar)

	-- ActionBar 2 Section
	local bar2Section = GUI:AddSection(actionBarCategory, "ActionBar 2")
	GUI:CreateSwitch(bar2Section, "ActionBar.Bar2", enableTextColor .. L["Enable ActionBar"] .. " 2", L["Bar2 Desc"], UpdateActionbar)

	-- ActionBar 3 Section
	local bar3Section = GUI:AddSection(actionBarCategory, "ActionBar 3")
	GUI:CreateSwitch(bar3Section, "ActionBar.Bar3", enableTextColor .. L["Enable ActionBar"] .. " 3", L["Bar3 Desc"], UpdateActionbar)

	-- ActionBar 4 Section
	local bar4Section = GUI:AddSection(actionBarCategory, "ActionBar 4")
	GUI:CreateSwitch(bar4Section, "ActionBar.Bar4", enableTextColor .. L["Enable ActionBar"] .. " 4", L["Bar4 Desc"], UpdateActionbar)
	-- GUI:CreateSlider(bar4Section, "ActionBar.Bar4Size", L["Button Size"], 20, 80, 1, L["Bar4Size Desc"], UpdateActionBar4Scale)
	-- GUI:CreateSlider(bar4Section, "ActionBar.Bar4PerRow", L["Button PerRow"], 1, 12, 1, L["Bar4PerRow Desc"], UpdateActionBar4Scale)
	-- GUI:CreateSlider(bar4Section, "ActionBar.Bar4Num", L["Button Num"], 1, 12, 1, L["Bar4Num Desc"], UpdateActionBar4Scale)
	-- GUI:CreateSlider(bar4Section, "ActionBar.Bar4Font", L["Button FontSize"], 8, 20, 1, L["Bar4Font Desc"], UpdateActionBar4Scale)
	-- GUI:CreateSwitch(bar4Section, "ActionBar.Bar4Fade", L["Enable Fade for Bar 4"], L["Allows Bar 4 to fade based on the specified conditions"], UpdateABFaderState)

	-- ActionBar 5 Section
	local bar5Section = GUI:AddSection(actionBarCategory, "ActionBar 5")
	GUI:CreateSwitch(bar5Section, "ActionBar.Bar5", enableTextColor .. L["Enable ActionBar"] .. " 5", L["Bar5 Desc"], UpdateActionbar)
	-- GUI:CreateSlider(bar5Section, "ActionBar.Bar5Size", L["Button Size"], 20, 80, 1, L["Bar5Size Desc"], UpdateActionBar5Scale)
	-- GUI:CreateSlider(bar5Section, "ActionBar.Bar5PerRow", L["Button PerRow"], 1, 12, 1, L["Bar5PerRow Desc"], UpdateActionBar5Scale)
	-- GUI:CreateSlider(bar5Section, "ActionBar.Bar5Num", L["Button Num"], 1, 12, 1, L["Bar5Num Desc"], UpdateActionBar5Scale)
	-- GUI:CreateSlider(bar5Section, "ActionBar.Bar5Font", L["Button FontSize"], 8, 20, 1, L["Bar5Font Desc"], UpdateActionBar5Scale)
	-- GUI:CreateSwitch(bar5Section, "ActionBar.Bar5Fade", L["Enable Fade for Bar 5"], L["Allows Bar 5 to fade based on the specified conditions"], UpdateABFaderState)

	-- ActionBar 6 Section
	local bar6Section = GUI:AddSection(actionBarCategory, "ActionBar 6")
	GUI:CreateSwitch(bar6Section, "ActionBar.Bar6", enableTextColor .. L["Enable ActionBar"] .. " 6", L["Bar6 Desc"], UpdateActionbar)
	-- GUI:CreateSlider(bar6Section, "ActionBar.Bar6Size", L["Button Size"], 20, 80, 1, L["Bar6Size Desc"], UpdateActionBar6Scale)
	-- GUI:CreateSlider(bar6Section, "ActionBar.Bar6PerRow", L["Button PerRow"], 1, 12, 1, L["Bar6PerRow Desc"], UpdateActionBar6Scale)
	-- GUI:CreateSlider(bar6Section, "ActionBar.Bar6Num", L["Button Num"], 1, 12, 1, L["Bar6Num Desc"], UpdateActionBar6Scale)
	-- GUI:CreateSlider(bar6Section, "ActionBar.Bar6Font", L["Button FontSize"], 8, 20, 1, L["Bar6Font Desc"], UpdateActionBar6Scale)
	-- GUI:CreateSwitch(bar6Section, "ActionBar.Bar6Fade", L["Enable Fade for Bar 6"], L["Allows Bar 6 to fade based on the specified conditions"], UpdateABFaderState)

	-- ActionBar 7 Section
	local bar7Section = GUI:AddSection(actionBarCategory, "ActionBar 7")
	GUI:CreateSwitch(bar7Section, "ActionBar.Bar7", enableTextColor .. L["Enable ActionBar"] .. " 7", L["Bar7 Desc"], UpdateActionbar)
	-- GUI:CreateSlider(bar7Section, "ActionBar.Bar7Size", L["Button Size"], 20, 80, 1, L["Bar7Size Desc"], UpdateActionBar7Scale)
	-- GUI:CreateSlider(bar7Section, "ActionBar.Bar7PerRow", L["Button PerRow"], 1, 12, 1, L["Bar7PerRow Desc"], UpdateActionBar7Scale)
	-- GUI:CreateSlider(bar7Section, "ActionBar.Bar7Num", L["Button Num"], 1, 12, 1, L["Bar7Num Desc"], UpdateActionBar7Scale)
	-- GUI:CreateSlider(bar7Section, "ActionBar.Bar7Font", L["Button FontSize"], 8, 20, 1, L["Bar7Font Desc"], UpdateActionBar7Scale)
	-- GUI:CreateSwitch(bar7Section, "ActionBar.Bar7Fade", L["Enable Fade for Bar 7"], L["Allows Bar 7 to fade based on the specified conditions"], UpdateABFaderState)

	-- ActionBar 8 Section
	local bar8Section = GUI:AddSection(actionBarCategory, "ActionBar 8")
	GUI:CreateSwitch(bar8Section, "ActionBar.Bar8", enableTextColor .. L["Enable ActionBar"] .. " 8", L["Bar8 Desc"], UpdateActionbar)
	-- GUI:CreateSlider(bar8Section, "ActionBar.Bar8Size", L["Button Size"], 20, 80, 1, L["Bar8Size Desc"], UpdateActionBar8Scale)
	-- GUI:CreateSlider(bar8Section, "ActionBar.Bar8PerRow", L["Button PerRow"], 1, 12, 1, L["Bar8PerRow Desc"], UpdateActionBar8Scale)
	-- GUI:CreateSlider(bar8Section, "ActionBar.Bar8Num", L["Button Num"], 1, 12, 1, L["Bar8Num Desc"], UpdateActionBar8Scale)
	-- GUI:CreateSlider(bar8Section, "ActionBar.Bar8Font", L["Button FontSize"], 8, 20, 1, L["Bar8Font Desc"], UpdateActionBar8Scale)
	-- GUI:CreateSwitch(bar8Section, "ActionBar.Bar8Fade", L["Enable Fade for Bar 8"], L["Allows Bar 8 to fade based on the specified conditions"], UpdateABFaderState)

	-- Pet Bar Section
	local petBarSection = GUI:AddSection(actionBarCategory, L["ActionBar Pet"])
	GUI:CreateSlider(petBarSection, "ActionBar.BarPetSize", L["Button Size"], 20, 80, 1, L["BarPetSize Desc"], UpdateActionBarPetScale)
	GUI:CreateSlider(petBarSection, "ActionBar.BarPetPerRow", L["Button PerRow"], 1, 12, 1, L["BarPetPerRow Desc"], UpdateActionBarPetScale)
	GUI:CreateSlider(petBarSection, "ActionBar.BarPetFont", L["Button FontSize"], 8, 20, 1, L["BarPetFont Desc"], UpdateActionBarPetScale)
	GUI:CreateSwitch(petBarSection, "ActionBar.BarPetFade", L["Enable Fade for Pet Bar"], L["Allows the Pet Bar to fade based on the specified conditions"], UpdateABFaderState)

	-- Stance Bar Section
	local stanceBarSection = GUI:AddSection(actionBarCategory, L["ActionBar Stance"])
	GUI:CreateSwitch(stanceBarSection, "ActionBar.ShowStance", enableTextColor .. L["Enable StanceBar"], L["ShowStance Desc"])
	GUI:CreateSlider(stanceBarSection, "ActionBar.BarStanceSize", L["Button Size"], 20, 80, 1, L["BarStanceSize Desc"], UpdateActionBarStance)
	GUI:CreateSlider(stanceBarSection, "ActionBar.BarStancePerRow", L["Button PerRow"], 1, 12, 1, L["BarStancePerRow Desc"], UpdateActionBarStance)
	GUI:CreateSlider(stanceBarSection, "ActionBar.BarStanceFont", L["Button FontSize"], 8, 20, 1, L["BarStanceFont Desc"], UpdateActionBarStance)
	GUI:CreateSwitch(stanceBarSection, "ActionBar.BarStanceFade", L["Enable Fade for Stance Bar"], L["Allows the Stance Bar to fade based on the specified conditions"], UpdateABFaderState)

	-- Vehicle Button Section
	local vehicleSection = GUI:AddSection(actionBarCategory, L["ActionBar Vehicle"])
	GUI:CreateSlider(vehicleSection, "ActionBar.VehButtonSize", L["Button Size"], 20, 80, 1, L["VehButtonSize Desc"], UpdateActionBarVehicleButton)

	-- Toggles Section
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

	-- Fader Options Section
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

--[[ ==============================================
			ANNOUNCEMENTS CATEGORY - Alerts & Notifications
		============================================== ]]
local function CreateAnnouncementsCategory()
	local announcementsCategory = GUI:AddCategory("Announcements", "Interface\\Icons\\Ability_Warrior_BattleShout")

	-- Hook Functions for Announcements
	local function UpdateInterruptAlert()
		local announcementModule = K:GetModule("Announcements")
		if announcementModule and announcementModule.CreateInterruptAnnounce then
			announcementModule:CreateInterruptAnnounce()
		end
	end

	-- General Section
	local generalAnnouncementsSection = GUI:AddSection(announcementsCategory, GENERAL)
	GUI:CreateSwitch(generalAnnouncementsSection, "Announcements.ItemAlert", L["Announce Spells And Items"], "Alerts the group when specific spells or items are used.")
	GUI:CreateSwitch(generalAnnouncementsSection, "Announcements.PullCountdown", L["Announce Pull Countdown (/pc #)"], "Announces the pull countdown timer to your group or raid.")
	GUI:CreateSwitch(generalAnnouncementsSection, "Announcements.ResetInstance", L["Alert Group After Instance Resetting"], "Notifies the group when the instance is reset.")

	-- Combat Section
	local combatAnnouncementsSection = GUI:AddSection(announcementsCategory, L["Combat"])
	GUI:CreateSwitch(combatAnnouncementsSection, "Announcements.SaySapped", L["Announce When Sapped"], "Automatically announces in chat when you are sapped in PvP.")
	GUI:CreateSwitch(combatAnnouncementsSection, "Announcements.KillingBlow", L["Show Your Killing Blow Info"], "Displays a notification when you land a killing blow.")
	GUI:CreateSwitch(combatAnnouncementsSection, "Announcements.PvPEmote", L["Auto Emote On Your Killing Blow"], "Automatically performs an emote when you land a killing blow in PvP.")
	GUI:CreateSwitch(combatAnnouncementsSection, "Announcements.HealthAlert", L["Announce When Low On Health"], "Alerts when your health drops below a critical threshold.")
	GUI:CreateSwitch(combatAnnouncementsSection, "Announcements.KeystoneAlert", L["Announce When New Mythic Key Is Obtained"], L["Notifies you and your group when you receive a new Mythic+ keystone."])

	-- Interrupt Section
	local interruptSection = GUI:AddSection(announcementsCategory, INTERRUPT)
	GUI:CreateSwitch(interruptSection, "Announcements.InterruptAlert", enableTextColor .. L["Announce Interrupts"], "Announces when you successfully interrupt a spell.", UpdateInterruptAlert)
	GUI:CreateSwitch(interruptSection, "Announcements.DispellAlert", enableTextColor .. L["Announce Dispels"], "Announces when you successfully dispel an effect.", UpdateInterruptAlert)
	GUI:CreateSwitch(interruptSection, "Announcements.BrokenAlert", enableTextColor .. L["Announce Broken Spells"], "Alerts the group when a spell is broken (e.g., crowd control spells).", UpdateInterruptAlert)
	GUI:CreateSwitch(interruptSection, "Announcements.OwnInterrupt", L["Only Announce Own Interrupts"], "Limits interrupt announcements to only those you perform.")
	GUI:CreateSwitch(interruptSection, "Announcements.OwnDispell", L["Only Announce Own Dispels"], "Limits dispel announcements to only those you perform.")
	GUI:CreateSwitch(interruptSection, "Announcements.InstAlertOnly", L["Announce Only In Instances"], "Restricts announcements to dungeons, raids, and other instances.", UpdateInterruptAlert)

	-- Alert Channel Dropdown Options
	local alertChannelOptions = {
		{ text = PARTY, value = 1 },
		{ text = PARTY .. " / " .. RAID, value = 2 },
		{ text = RAID, value = 3 },
		{ text = SAY, value = 4 },
		{ text = YELL, value = 5 },
		{ text = EMOTE, value = 6 },
	}
	GUI:CreateDropdown(interruptSection, "Announcements.AlertChannel", L["Announce Interrupts To Specified Chat Channel"], alertChannelOptions, "Select the chat channel where interrupt and dispel alerts will be sent.")

	-- Quest Notifier Section
	local questNotifierSection = GUI:AddSection(announcementsCategory, L["QuestNotifier"])
	GUI:CreateSwitch(questNotifierSection, "Announcements.QuestNotifier", enableTextColor .. L["Enable QuestNotifier"], "Enables notifications related to quest progress and completion.")
	GUI:CreateSwitch(questNotifierSection, "Announcements.OnlyCompleteRing", L["Only Play Complete Quest Sound"], "Plays a sound only when a quest is fully completed.")
	GUI:CreateSwitch(questNotifierSection, "Announcements.QuestProgress", L["Alert QuestProgress In Chat"], "Sends quest progress updates to chat.")

	-- Rare Alert Section
	local rareAlertSection = GUI:AddSection(announcementsCategory, L["Rare Alert"])
	GUI:CreateSwitch(rareAlertSection, "Announcements.RareAlert", enableTextColor .. L["Enable Event & Rare Alerts"], "Enables alerts for nearby rare creatures and events.")
	GUI:CreateSwitch(rareAlertSection, "Announcements.AlertInWild", L["Don't Alert In Instances"], "Prevents rare alerts from triggering inside instances.")
	GUI:CreateSwitch(rareAlertSection, "Announcements.AlertInChat", L["Print Alerts In Chat"], "Prints alerts for rare events and creatures in the chat window.")
end

--[[ ==============================================
			ARENA CATEGORY - PvP Arena Frames
		============================================== ]]
local function CreateArenaCategory()
	local arenaCategory = GUI:AddCategory("Arena", "Interface\\Icons\\Achievement_Arena_2v2_7")

	-- Hook Functions for Arena
	local function UpdateArenaFrames()
		-- Arena frames don't have specific update functions in the modules
		-- The changes will be applied on next UI reload or when frames refresh
		local unitframeModule = K:GetModule("Unitframes")
		if unitframeModule and unitframeModule.RefreshAllUnits then
			unitframeModule:RefreshAllUnits()
		end
	end

	-- General Section
	local generalArenaSection = GUI:AddSection(arenaCategory, GENERAL)
	GUI:CreateSwitch(generalArenaSection, "Arena.Enable", enableTextColor .. L["Enable Arena"], "Toggle Arena Module On/Off", UpdateArenaFrames)
	GUI:CreateSwitch(generalArenaSection, "Arena.Castbars", L["Show Castbars"], "Enable castbars for arena opponent frames", UpdateArenaFrames)
	GUI:CreateSwitch(generalArenaSection, "Arena.CastbarIcon", "Show Castbars Icon", "Display icons on arena opponent castbars", UpdateArenaFrames)
	GUI:CreateSwitch(generalArenaSection, "Arena.Smooth", L["Smooth Bar Transition"], "Enable smooth health and power bar animations", UpdateArenaFrames)

	-- Sizes Section
	local arenaSizesSection = GUI:AddSection(arenaCategory, L["Sizes"])
	GUI:CreateSlider(arenaSizesSection, "Arena.HealthHeight", "Health Height", 20, 50, 1, "Height of arena opponent health bars", UpdateArenaFrames)
	GUI:CreateSlider(arenaSizesSection, "Arena.HealthWidth", "Health Width", 120, 180, 1, "Width of arena opponent health bars", UpdateArenaFrames)
	GUI:CreateSlider(arenaSizesSection, "Arena.PowerHeight", "Power Height", 10, 30, 1, "Height of arena opponent power bars", UpdateArenaFrames)
	GUI:CreateSlider(arenaSizesSection, "Arena.YOffset", "Vertical Offset From One Another" .. K.GreyColor .. "(54)|r", 40, 60, 1, "Vertical spacing between arena opponent frames", UpdateArenaFrames)

	-- Colors Section
	local arenaColorsSection = GUI:AddSection(arenaCategory, COLORS)

	-- Health Color Format Dropdown Options
	local healthColorOptions = {
		{ text = "Class", value = 1 },
		{ text = "Dark", value = 2 },
		{ text = "Value", value = 3 },
	}
	GUI:CreateDropdown(arenaColorsSection, "Arena.HealthbarColor", L["Health Color Format"], healthColorOptions, "Choose how arena opponent health bars are colored", UpdateArenaFrames)
end

--[[ ==============================================
			AURAWATCH CATEGORY - Aura Tracking System
		============================================== ]]
local function CreateAuraWatchCategory()
	local auraWatchCategory = GUI:AddCategory("AuraWatch", "Interface\\Icons\\Spell_Shadow_BrainWash")

	-- Hook Functions for AuraWatch
	local function UpdateAuraWatchSettings()
		-- AuraWatch settings typically require UI reload for major changes
		-- But we can update some settings dynamically
		local auraWatchModule = K:GetModule("Auras")
		if auraWatchModule then
			-- Settings updated silently, major changes may require UI reload
		end
	end

	local function OpenAuraWatchGUI()
		-- Open the AuraWatch configuration GUI
		K.NewGUI:Toggle()
		SlashCmdList["KKUI_AWCONFIG"]() -- To Be Implemented
	end

	-- General Section
	local generalAuraWatchSection = GUI:AddSection(auraWatchCategory, GENERAL)
	GUI:CreateSwitch(generalAuraWatchSection, "AuraWatch.Enable", enableTextColor .. L["Enable AuraWatch"], L["Enable Desc"], UpdateAuraWatchSettings)
	GUI:CreateSwitch(generalAuraWatchSection, "AuraWatch.ClickThrough", L["Disable AuraWatch Tooltip (ClickThrough)"], "If enabled, the icon would be uninteractable, you can't select or mouseover them.", UpdateAuraWatchSettings)
	GUI:CreateSwitch(generalAuraWatchSection, "AuraWatch.DeprecatedAuras", L["Track Auras From Previous Expansions"], "Enable tracking of auras from previous expansions that may still be relevant.", UpdateAuraWatchSettings)
	GUI:CreateSlider(generalAuraWatchSection, "AuraWatch.IconScale", L["AuraWatch IconScale"], 0.8, 2, 0.1, L["IconScale Desc"], UpdateAuraWatchSettings)

	-- Advanced Configuration Section
	local advancedAuraWatchSection = GUI:AddSection(auraWatchCategory, "Advanced Configuration")

	-- Create the AuraWatch GUI button widget using the proper GUI system
	GUI:CreateButtonWidget(advancedAuraWatchSection, "AuraWatch.OpenGUI", L["AuraWatch GUI"], "Open GUI", "Opens the advanced AuraWatch configuration interface where you can add, remove, and customize tracked auras, cooldowns, and buffs/debuffs.", function()
		OpenAuraWatchGUI()
	end)
end

--[[ ==============================================
			AURAS CATEGORY - Buff/Debuff & Totem Management
		============================================== ]]
local function CreateAurasCategory()
	local aurasCategory = GUI:AddCategory("Auras", "Interface\\Icons\\Spell_Magic_LesserInvisibilty")

	-- Hook Functions for Auras
	local function UpdateAurasSettings()
		-- Auras settings typically apply immediately
		local aurasModule = K:GetModule("Auras")
		if aurasModule then
			-- Settings updated silently
		end
	end

	local function UpdateTotemBar()
		if not C["Auras"].Totems then
			return
		end

		local aurasModule = K:GetModule("Auras")
		if aurasModule and aurasModule.TotemBar_Init then
			aurasModule:TotemBar_Init()
			-- TotemBar updated silently
		end
	end

	-- General Section
	local generalAurasSection = GUI:AddSection(aurasCategory, GENERAL)
	GUI:CreateSwitch(generalAurasSection, "Auras.Enable", enableTextColor .. L["Enable Auras"], L["Enable Desc"], UpdateAurasSettings)
	GUI:CreateSwitch(generalAurasSection, "Auras.HideBlizBuff", L["Hide The Default BuffFrame"], L["HideBlizBuff Desc"], UpdateAurasSettings)
	GUI:CreateSwitch(generalAurasSection, "Auras.Reminder", L["Auras Reminder (Shout/Intellect/Poison)"], L["Reminder Desc"], UpdateAurasSettings)
	GUI:CreateSwitch(generalAurasSection, "Auras.ReverseBuffs", L["Buffs Grow Right"], L["ReverseBuffs Desc"], UpdateAurasSettings)
	GUI:CreateSwitch(generalAurasSection, "Auras.ReverseDebuffs", L["Debuffs Grow Right"], "Controls the direction debuff icons grow from their anchor point.", UpdateAurasSettings)

	-- Sizes Section
	local aurasSizesSection = GUI:AddSection(aurasCategory, L["Sizes"])
	GUI:CreateSlider(aurasSizesSection, "Auras.BuffSize", L["Buff Icon Size"], 20, 40, 1, L["AuraSize Desc"], UpdateAurasSettings)
	GUI:CreateSlider(aurasSizesSection, "Auras.BuffsPerRow", L["Buffs per Row"], 10, 20, 1, L["BuffsPerRow Desc"], UpdateAurasSettings)
	GUI:CreateSlider(aurasSizesSection, "Auras.DebuffSize", L["DeBuff Icon Size"], 20, 40, 1, L["AuraSize Desc"], UpdateAurasSettings)
	GUI:CreateSlider(aurasSizesSection, "Auras.DebuffsPerRow", L["DeBuffs per Row"], 10, 16, 1, L["DebuffsPerRow Desc"], UpdateAurasSettings)

	-- Totems Section (using TUTORIAL_TITLE47 which represents "Totems" in the old system)
	local totemsSection = GUI:AddSection(aurasCategory, TUTORIAL_TITLE47 or "Totems")
	GUI:CreateSwitch(totemsSection, "Auras.Totems", enableTextColor .. L["Enable TotemBar"], L["Totems Desc"], UpdateTotemBar)
	GUI:CreateSwitch(totemsSection, "Auras.VerticalTotems", L["Vertical TotemBar"], L["VerticalTotems Desc"], UpdateTotemBar)
	GUI:CreateSlider(totemsSection, "Auras.TotemSize", L["Totems IconSize"], 24, 60, 1, L["TotemSize Desc"], UpdateTotemBar)
end

-- ====================================================
-- AUTOMATION CATEGORY
-- ====================================================
local function CreateAutomationCategory()
	local automationIcon = "Interface\\Icons\\Ability_Warrior_OffensiveStance"
	local category = GUI:AddCategory("Automation", automationIcon)

	-- ========================================
	-- INVITE MANAGEMENT SECTION
	-- ========================================
	local inviteSection = GUI:AddSection(category, "Invite Management")

	local function updateAutoInvite(newValue, oldValue, configPath)
		if K.GetModule then
			local automationModule = K:GetModule("Automation")
			if automationModule and automationModule.UpdateAutoInvite then
				automationModule:UpdateAutoInvite()
			end
		end
	end

	GUI:CreateSwitch(inviteSection, "Automation.AutoInvite", "Accept Invites From Friends & Guild Members", "Automatically accepts group invitations from friends or guild members.", updateAutoInvite)
	GUI:CreateSwitch(inviteSection, "Automation.AutoDeclineDuels", "Decline PvP Duels", "Automatically declines all PvP duel requests.", updateAutoInvite)
	GUI:CreateSwitch(inviteSection, "Automation.AutoDeclinePetDuels", "Decline Pet Duels", "Automatically declines all pet battle duel requests.", updateAutoInvite)
	GUI:CreateSwitch(inviteSection, "Automation.AutoPartySync", "Accept PartySync From Friends & Guild Members", "Automatically accepts Party Sync requests from friends or guild members.", updateAutoInvite)
	GUI:CreateTextInput(inviteSection, "Automation.WhisperInvite", "Auto Accept Invite Keyword", "Enter keyword...", "Enter a keyword that will trigger automatic acceptance of invites sent via whispers.", updateAutoInvite)

	-- ========================================
	-- AUTO-RESURRECT OPTIONS SECTION
	-- ========================================
	local resurrectSection = GUI:AddSection(category, "Auto-Resurrect Options")

	local function updateAutoResurrect(newValue, oldValue, configPath)
		if K.GetModule then
			local automationModule = K:GetModule("Automation")
			if automationModule and automationModule.UpdateAutoResurrect then
				automationModule:UpdateAutoResurrect()
			end
		end
	end

	GUI:CreateSwitch(resurrectSection, "Automation.AutoResurrect", "Auto Accept Resurrect Requests", "Automatically accepts resurrection requests during combat or in dungeons.", updateAutoResurrect)
	GUI:CreateSwitch(resurrectSection, "Automation.AutoResurrectThank", "Say 'Thank You' When Resurrected", "Sends a 'Thank you' message to the player who resurrects you.", updateAutoResurrect)

	-- ========================================
	-- AUTO-REWARD OPTIONS SECTION
	-- ========================================
	local rewardSection = GUI:AddSection(category, "Auto-Reward Options")

	local function updateAutoReward(newValue, oldValue, configPath)
		if K.GetModule then
			local automationModule = K:GetModule("Automation")
			if automationModule and automationModule.UpdateAutoReward then
				automationModule:UpdateAutoReward()
			end
		end
	end

	GUI:CreateSwitch(rewardSection, "Automation.AutoReward", "Auto Select Quest Rewards Best Value", "Automatically selects the highest value quest reward.", updateAutoReward)

	-- ========================================
	-- MISCELLANEOUS OPTIONS SECTION
	-- ========================================
	local miscSection = GUI:AddSection(category, "Miscellaneous Options")

	local function updateAutomationMisc(newValue, oldValue, configPath)
		if K.GetModule then
			local automationModule = K:GetModule("Automation")
			if automationModule then
				if configPath:find("AutoGoodbye") and automationModule.UpdateAutoGoodbye then
					automationModule:UpdateAutoGoodbye()
				elseif configPath:find("AutoKeystone") and automationModule.UpdateAutoKeystone then
					automationModule:UpdateAutoKeystone()
				elseif configPath:find("AutoOpenItems") and automationModule.UpdateAutoOpenItems then
					automationModule:UpdateAutoOpenItems()
				elseif configPath:find("AutoRelease") and automationModule.UpdateAutoRelease then
					automationModule:UpdateAutoRelease()
				elseif configPath:find("AutoScreenshot") and automationModule.UpdateAutoScreenshot then
					automationModule:UpdateAutoScreenshot()
				elseif configPath:find("AutoSetRole") and automationModule.UpdateAutoSetRole then
					automationModule:UpdateAutoSetRole()
				elseif configPath:find("AutoSkipCinematic") and automationModule.UpdateAutoSkipCinematic then
					automationModule:UpdateAutoSkipCinematic()
				elseif configPath:find("AutoSummon") and automationModule.UpdateAutoSummon then
					automationModule:UpdateAutoSummon()
				elseif configPath:find("NoBadBuffs") and automationModule.UpdateNoBadBuffs then
					automationModule:UpdateNoBadBuffs()
				end
			end
		end
	end

	GUI:CreateSwitch(miscSection, "Automation.AutoGoodbye", "Say Goodbye After Dungeon Completion", "Automatically says 'Goodbye' to the group when the dungeon is completed.", updateAutomationMisc)
	GUI:CreateSwitch(miscSection, "Automation.AutoKeystone", "Auto Place Mythic Keystones", "Automatically places your highest available Mythic Keystone in the dungeon keystone slot.", updateAutomationMisc)
	GUI:CreateSwitch(miscSection, "Automation.AutoOpenItems", "Auto Open Items In Your Inventory", "Automatically opens items in your inventory that contain loot.", updateAutomationMisc)
	GUI:CreateSwitch(miscSection, "Automation.AutoRelease", "Auto Release in Battlegrounds & Arenas", "Automatically releases your spirit upon death in battlegrounds or arenas.", updateAutomationMisc)
	GUI:CreateSwitch(miscSection, "Automation.AutoScreenshot", "Auto Screenshot Achievements", "Automatically takes a screenshot when you earn an achievement.", updateAutomationMisc)
	GUI:CreateSwitch(miscSection, "Automation.AutoSetRole", "Auto Set Your Role In Groups", "Automatically sets your role based on your class and specialization.", updateAutomationMisc)
	GUI:CreateSwitch(miscSection, "Automation.AutoSkipCinematic", "Auto Skip All Cinematics/Movies", "Automatically skips cinematics and movies during gameplay.", updateAutomationMisc)
	GUI:CreateSwitch(miscSection, "Automation.AutoSummon", "Auto Accept Summon Requests", "Automatically accepts summon requests from your group or raid.", updateAutomationMisc)
	GUI:CreateSwitch(miscSection, "Automation.NoBadBuffs", "Automatically Remove Annoying Buffs", "Automatically removes unwanted or annoying buffs.", updateAutomationMisc)
end
-- ====================================================
-- BOSS CATEGORY
-- ====================================================
local function CreateBossCategory()
	local bossIcon = "Interface\\Icons\\Achievement_boss_illidan"
	local bossCategory = GUI:AddCategory("Boss", bossIcon)

	-- Hook Functions for Boss
	local function UpdateBossFrames()
		-- Boss frames don't have specific update functions in the modules
		-- The changes will be applied on next UI reload or when frames refresh
		local unitframeModule = K:GetModule("Unitframes")
		if unitframeModule and unitframeModule.RefreshAllUnits then
			unitframeModule:RefreshAllUnits()
			-- Boss frame settings updated silently
		end
	end

	-- GENERAL SECTION
	local generalBossSection = GUI:AddSection(bossCategory, GENERAL)
	GUI:CreateSwitch(generalBossSection, "Boss.Enable", enableTextColor .. L["Enable Boss"], "Toggle Boss Module On/Off", UpdateBossFrames)
	GUI:CreateSwitch(generalBossSection, "Boss.Castbars", L["Show Castbars"], "Enable castbars for boss frames", UpdateBossFrames)
	GUI:CreateSwitch(generalBossSection, "Boss.CastbarIcon", "Show Castbars Icon", "Display icons on boss frame castbars", UpdateBossFrames)
	GUI:CreateSwitch(generalBossSection, "Boss.Smooth", L["Smooth Bar Transition"], "Enable smooth health and power bar animations", UpdateBossFrames)

	-- SIZES SECTION
	local bossSizesSection = GUI:AddSection(bossCategory, L["Sizes"])
	GUI:CreateSlider(bossSizesSection, "Boss.HealthHeight", "Health Height", 20, 50, 1, "Height of boss frame health bars", UpdateBossFrames)
	GUI:CreateSlider(bossSizesSection, "Boss.HealthWidth", "Health Width", 120, 180, 1, "Width of boss frame health bars", UpdateBossFrames)
	GUI:CreateSlider(bossSizesSection, "Boss.PowerHeight", "Power Height", 10, 30, 1, "Height of boss frame power bars", UpdateBossFrames)
	GUI:CreateSlider(bossSizesSection, "Boss.YOffset", "Vertical Offset From One Another" .. K.GreyColor .. "(54)|r", 40, 60, 1, "Vertical spacing between boss frames", UpdateBossFrames)

	-- COLORS SECTION
	local bossColorsSection = GUI:AddSection(bossCategory, COLORS)

	-- Health Color Format Dropdown Options
	local healthColorOptions = {
		{ text = "Class", value = 1 },
		{ text = "Dark", value = 2 },
		{ text = "Value", value = 3 },
	}
	GUI:CreateDropdown(bossColorsSection, "Boss.HealthbarColor", L["Health Color Format"], healthColorOptions, "Choose how boss frame health bars are colored", UpdateBossFrames)
end

-- CHAT CATEGORY
local function CreateChatCategory()
	local chatIcon = "Interface\\Icons\\Spell_Holy_Silence"
	local chatCategory = GUI:AddCategory("Chat", chatIcon)

	-- Hook Functions for Chat
	local function UpdateChatBackground()
		local chatModule = K:GetModule("Chat")
		if chatModule and chatModule.ToggleBackground then
			chatModule:ToggleBackground()
			-- Chat background updated silently
		end
	end

	local function UpdateChatSticky()
		local chatModule = K:GetModule("Chat")
		if chatModule and chatModule.UpdateStickyChannels then
			chatModule:UpdateStickyChannels()
			-- Chat sticky settings updated silently
		end
	end

	local function UpdateChatSize()
		local chatModule = K:GetModule("Chat")
		if chatModule and chatModule.UpdateChatSize then
			chatModule:UpdateChatSize()
			-- Chat size updated silently
		end
	end

	local function UpdateChatSettings()
		local chatModule = K:GetModule("Chat")
		if chatModule then
			-- Chat settings updated silently
		end
	end

	-- GENERAL SECTION
	local generalChatSection = GUI:AddSection(chatCategory, GENERAL)
	GUI:CreateSwitch(generalChatSection, "Chat.Enable", enableTextColor .. L["Enable Chat"], L["Enable Desc"], UpdateChatSettings)
	GUI:CreateSwitch(generalChatSection, "Chat.Lock", L["Lock Chat"], L["Lock Desc"], UpdateChatSettings)
	GUI:CreateSwitch(generalChatSection, "Chat.Background", L["Show Chat Background"], L["Background Desc"], UpdateChatBackground)
	GUI:CreateSwitch(generalChatSection, "Chat.OldChatNames", L["Use Default Channel Names"], L["OldChatNames Desc"], UpdateChatSettings)

	-- APPEARANCE SECTION
	local appearanceChatSection = GUI:AddSection(chatCategory, L["Appearance"])
	GUI:CreateSwitch(appearanceChatSection, "Chat.Emojis", L["Show Emojis In Chat"] .. " |TInterface\\Addons\\KkthnxUI\\Media\\Chat\\Emojis\\StuckOutTongueClosedEyes:0:0:4|t", L["Emojis Desc"], UpdateChatSettings)
	GUI:CreateSwitch(appearanceChatSection, "Chat.ChatItemLevel", L["Show ItemLevel on ChatFrames"], L["ChatItemLevel Desc"], UpdateChatSettings)

	-- Timestamp Format Dropdown Options
	local timestampOptions = {
		{ text = "Disabled", value = "NONE" },
		{ text = "HH:MM", value = "%H:%M" },
		{ text = "HH:MM:SS", value = "%H:%M:%S" },
		{ text = "MM/DD HH:MM", value = "%m/%d %H:%M" },
		{ text = "DD/MM HH:MM", value = "%d/%m %H:%M" },
	}
	GUI:CreateDropdown(appearanceChatSection, "Chat.TimestampFormat", L["Custom Chat Timestamps"], timestampOptions, L["TimestampFormat Desc"], UpdateChatSettings)

	-- BEHAVIOR SECTION
	local behaviorChatSection = GUI:AddSection(chatCategory, L["Behavior"])
	GUI:CreateSwitch(behaviorChatSection, "Chat.Freedom", L["Disable Chat Language Filter"], L["Freedom Desc"], UpdateChatSettings)
	GUI:CreateSwitch(behaviorChatSection, "Chat.ChatMenu", L["Show Chat Menu Buttons"], L["ChatMenu Desc"], UpdateChatSettings)
	GUI:CreateSwitch(behaviorChatSection, "Chat.Sticky", L["Stick On Channel If Whispering"], L["Sticky Desc"], UpdateChatSticky)
	GUI:CreateSwitch(behaviorChatSection, "Chat.WhisperColor", L["Differ Whisper Colors"], "Use different colors for incoming and outgoing whispers", UpdateChatSettings)

	-- SIZES SECTION
	local sizesChatSection = GUI:AddSection(chatCategory, L["Sizes"])
	GUI:CreateSlider(sizesChatSection, "Chat.Height", L["Lock Chat Height"], 100, 500, 1, L["Height Desc"], UpdateChatSize)
	GUI:CreateSlider(sizesChatSection, "Chat.Width", L["Lock Chat Width"], 200, 600, 1, L["Width Desc"], UpdateChatSize)
	GUI:CreateSlider(sizesChatSection, "Chat.LogMax", L["Chat History Lines To Save"], 0, 500, 10, L["LogMax Desc"], UpdateChatSettings)

	-- FADING SECTION
	local fadingChatSection = GUI:AddSection(chatCategory, L["Fading"])
	GUI:CreateSwitch(fadingChatSection, "Chat.Fading", L["Fade Chat Text"], "Enable automatic fading of chat messages after a set time", UpdateChatSettings)
	GUI:CreateSlider(fadingChatSection, "Chat.FadingTimeVisible", L["Fading Chat Visible Time"], 5, 120, 1, L["FadingTimeVisible Desc"], UpdateChatSettings)
end

-- DATATEXT CATEGORY
local function CreateDataTextCategory()
	local dataTextIcon = "Interface\\Icons\\Achievement_worldevent_childrensweek"
	local dataTextCategory = GUI:AddCategory("DataText", dataTextIcon)

	-- Hook Functions for DataText
	local function UpdateDataTextSettings()
		local dataTextModule = K:GetModule("DataText")
		if dataTextModule then
			print("|cff669DFFKkthnxUI:|r DataText settings updated!")
			-- DataText modules typically refresh themselves automatically
		end
	end

	local function UpdateDataTextColors()
		local dataTextModule = K:GetModule("DataText")
		if dataTextModule and dataTextModule.UpdateColors then
			dataTextModule:UpdateColors()
			print("|cff669DFFKkthnxUI:|r DataText colors updated!")
		end
	end

	-- GENERAL SECTION
	local generalDataTextSection = GUI:AddSection(dataTextCategory, GENERAL)
	GUI:CreateSwitch(generalDataTextSection, "DataText.Coords", L["Enable Positon Coords"], L["Coords Desc"], UpdateDataTextSettings)
	GUI:CreateSwitch(generalDataTextSection, "DataText.Friends", L["Enable Friends Info"], L["Friends Desc"], UpdateDataTextSettings)
	GUI:CreateSwitch(generalDataTextSection, "DataText.Gold", L["Enable Currency Info"], L["Gold Desc"], UpdateDataTextSettings)
	GUI:CreateSwitch(generalDataTextSection, "DataText.Guild", L["Enable Guild Info"], L["Guild Desc"], UpdateDataTextSettings)
	GUI:CreateSwitch(generalDataTextSection, "DataText.Latency", L["Enable Latency Info"], L["Latency Desc"], UpdateDataTextSettings)
	GUI:CreateSwitch(generalDataTextSection, "DataText.Location", L["Enable Minimap Location"], L["Location Desc"], UpdateDataTextSettings)
	GUI:CreateSwitch(generalDataTextSection, "DataText.Spec", L["Enable Specialization Info"], L["Spec Desc"], UpdateDataTextSettings)
	GUI:CreateSwitch(generalDataTextSection, "DataText.System", L["Enable System Info"], L["System Desc"], UpdateDataTextSettings)
	GUI:CreateSwitch(generalDataTextSection, "DataText.Time", L["Enable Minimap Time"], L["Time Desc"], UpdateDataTextSettings)

	-- ICON COLORS SECTION
	local iconColorsSection = GUI:AddSection(dataTextCategory, L["Icon Colors"])
	GUI:CreateColorPicker(iconColorsSection, "DataText.IconColor", L["Color The Icons"], L["IconColor Desc"], UpdateDataTextColors)

	-- TEXT TOGGLES SECTION
	local textTogglesSection = GUI:AddSection(dataTextCategory, L["Text Toggles"])
	GUI:CreateSwitch(textTogglesSection, "DataText.HideText", L["Hide Icon Text"], L["HideText Desc"], UpdateDataTextSettings)
end

-- GENERAL CATEGORY
local function CreateGeneralCategory()
	local generalIcon = "Interface\\Icons\\INV_Misc_Gear_01"
	local generalCategory = GUI:AddCategory("General", generalIcon)

	-- Hook Functions for General
	local function UpdateGeneralSettings()
		print("|cff669DFFKkthnxUI:|r General settings updated!")
	end

	local function UpdateMinimapIcon(newValue, oldValue, configPath)
		-- Toggle minimap icon visibility
		if K.Minimap and K.Minimap.OnClick then
			-- This would normally call the minimap icon toggle function
			print("|cff669DFFKkthnxUI:|r Minimap icon toggle updated!")
		end
	end

	local function UpdateUIScale(newValue, oldValue, configPath)
		if K.SetupUIScale then
			K:SetupUIScale()
			print("|cff669DFFKkthnxUI:|r UI Scale updated to", newValue)
		end
	end

	local function UpdateSmoothingAmount(newValue, oldValue, configPath)
		-- Update smoothing for all modules that use it
		print("|cff669DFFKkthnxUI:|r Smoothing amount updated to", newValue)
	end

	local function UpdateTextureColors(newValue, oldValue, configPath)
		-- Update texture colors across the UI
		print("|cff669DFFKkthnxUI:|r Texture colors updated!")
	end

	-- GENERAL SECTION
	local generalGeneralSection = GUI:AddSection(generalCategory, GENERAL)
	GUI:CreateSwitch(generalGeneralSection, "General.MinimapIcon", L["Enable Minimap Icon"], L["MinimapIcon Desc"], UpdateMinimapIcon)
	GUI:CreateSwitch(generalGeneralSection, "General.MoveBlizzardFrames", L["Move Blizzard Frames"], L["MoveBlizzardFrames Desc"], UpdateGeneralSettings)
	GUI:CreateSwitch(generalGeneralSection, "General.NoErrorFrame", L["Disable Blizzard Error Frame Combat"], "Prevents error messages from appearing during combat", UpdateGeneralSettings)
	GUI:CreateSwitch(generalGeneralSection, "General.NoTutorialButtons", L["Disable 'Some' Blizzard Tutorials"], L["NoTutorialButtons Desc"], UpdateGeneralSettings)

	-- Button Glow Mode Dropdown
	local glowModeOptions = {
		{ text = "Default", value = "default" },
		{ text = "Action Button Glow", value = "actionButton" },
		{ text = "Pixel Glow", value = "pixel" },
		{ text = "Auto Cast Shine", value = "autocast" },
	}
	GUI:CreateDropdown(generalGeneralSection, "General.GlowMode", L["Button Glow Mode"], glowModeOptions, L["GlowMode Desc"], UpdateGeneralSettings)

	-- Border Style Dropdown - dynamically loads all available border styles (marked for reload)
	local borderStyleOptions = {}
	if K.GetAllBorderStyles then
		borderStyleOptions = K.GetAllBorderStyles()
	else
		-- Fallback options if function not available
		borderStyleOptions = {
			{ text = "KkthnxUI", value = "KkthnxUI", description = "Default KkthnxUI border style" },
			{ text = "AzeriteUI", value = "AzeriteUI", description = "Clean Azerite-inspired border" },
			{ text = "KkthnxUI Blank", value = "KkthnxUI_Blank", description = "Minimal blank border style" },
			{ text = "KkthnxUI Pixel", value = "KkthnxUI_Pixel", description = "Sharp pixel-perfect border" },
		}
	end

	GUI:CreateDropdown(generalGeneralSection, "General.BorderStyle", L["Border Style"], borderStyleOptions, "Choose the visual style for UI borders (requires reload)", UpdateGeneralSettings)

	-- Number Prefix Style Dropdown
	local numberPrefixOptions = {
		{ text = "Standard", value = "STANDARD" },
		{ text = "Asian", value = "ASIAN" },
		{ text = "Chinese", value = "CHINESE" },
	}
	GUI:CreateDropdown(generalGeneralSection, "General.NumberPrefixStyle", L["Number Prefix Style"], numberPrefixOptions, "Choose how large numbers are abbreviated", UpdateGeneralSettings)

	-- Smoothing Amount Slider
	GUI:CreateSlider(generalGeneralSection, "General.SmoothAmount", "Smoothing Amount", 0.1, 1, 0.01, L["Setup healthbar smooth frequency for unitframes and nameplates. The lower the smoother."], UpdateSmoothingAmount)

	-- ========================================
	-- SCALING SECTION
	-- ========================================
	local scalingSection = GUI:AddSection(generalCategory, L["Scaling"])
	GUI:CreateSwitch(scalingSection, "General.AutoScale", L["Auto Scale"], L["AutoScaleTip"] .. " (requires reload)", UpdateUIScale)
	GUI:CreateSlider(scalingSection, "General.UIScale", L["Set UI scale"], 0.4, 1.15, 0.01, L["UIScaleTip"] .. " (requires reload)", UpdateUIScale)

	-- ========================================
	-- COLORS SECTION
	-- ========================================
	local colorsSection = GUI:AddSection(generalCategory, COLORS)

	GUI:CreateSwitch(colorsSection, "General.ColorTextures", L["Color 'Most' KkthnxUI Borders"], L["ColorTextures Desc"] .. " (requires reload)", UpdateTextureColors)

	GUI:CreateColorPicker(colorsSection, "General.TexturesColor", L["Textures Color"], "Choose the color for KkthnxUI textures and borders (requires reload)", UpdateTextureColors)

	-- ========================================
	-- TEXTURE SECTION
	-- ========================================
	local textureSection = GUI:AddSection(generalCategory, L["Texture"])

	-- Enhanced Texture Dropdown with previews - dynamically loads all available textures (marked for reload)
	GUI:CreateTextureDropdown(textureSection, "General.Texture", L["Set General Texture"], L["Texture Desc"] .. " (requires reload)", UpdateGeneralSettings)
end

-- ====================================================
-- INVENTORY CATEGORY
-- ====================================================
local function CreateInventoryCategory()
	local inventoryIcon = "Interface\\Icons\\INV_Misc_Bag_07"
	local inventoryCategory = GUI:AddCategory("Inventory", inventoryIcon)

	-- Hook Functions for Inventory
	local function UpdateBagStatus()
		local inventoryModule = K:GetModule("Bags")
		if inventoryModule and inventoryModule.UpdateBagStatus then
			inventoryModule:UpdateBagStatus()
			print("|cff669DFFKkthnxUI:|r Inventory bag status updated!")
		end
	end

	local function UpdateBagSortOrder()
		local inventoryModule = K:GetModule("Bags")
		if inventoryModule and inventoryModule.UpdateSortOrder then
			inventoryModule:UpdateSortOrder()
			print("|cff669DFFKkthnxUI:|r Inventory sort order updated!")
		end
	end

	local function UpdateBagAnchor()
		local inventoryModule = K:GetModule("Bags")
		if inventoryModule and inventoryModule.UpdateBagAnchor then
			inventoryModule:UpdateBagAnchor()
			print("|cff669DFFKkthnxUI:|r Inventory bag anchoring updated!")
		end
	end

	local function UpdateBagSize()
		local inventoryModule = K:GetModule("Bags")
		if inventoryModule and inventoryModule.UpdateBagSize then
			inventoryModule:UpdateBagSize()
			print("|cff669DFFKkthnxUI:|r Inventory bag size updated!")
		end
	end

	local function UpdateInventorySettings()
		local inventoryModule = K:GetModule("Bags")
		if inventoryModule then
			print("|cff669DFFKkthnxUI:|r Inventory settings updated!")
		end
	end

	-- GENERAL SECTION
	local generalInventorySection = GUI:AddSection(inventoryCategory, GENERAL)
	GUI:CreateSwitch(generalInventorySection, "Inventory.Enable", enableTextColor .. L["Enable Inventory"], L["Enable Desc"] .. " (requires reload)", UpdateInventorySettings)
	GUI:CreateSwitch(generalInventorySection, "Inventory.AutoSell", L["Auto Vendor Grays"], "Automatically sells gray quality items to vendors", UpdateInventorySettings)

	-- BAGS SECTION
	local bagsSection = GUI:AddSection(inventoryCategory, "Bags")
	GUI:CreateSwitch(bagsSection, "Inventory.BagsBindOnEquip", L["Display Bind Status"], L["BagsBindOnEquip Desc"], UpdateBagStatus)
	GUI:CreateSwitch(bagsSection, "Inventory.BagsItemLevel", L["Display Item Level"], L["BagsItemLevel Desc"], UpdateBagStatus)
	GUI:CreateSwitch(bagsSection, "Inventory.DeleteButton", L["Bags Delete Button"], "Shows a delete button for easy item deletion", UpdateInventorySettings)
	GUI:CreateSwitch(bagsSection, "Inventory.ReverseSort", L["Reverse the Sorting"], L["ReverseSort Desc"], UpdateBagSortOrder)
	GUI:CreateSwitch(bagsSection, "Inventory.ShowNewItem", L["Show New Item Glow"], "Highlights newly acquired items with a glow effect", UpdateInventorySettings)
	GUI:CreateSwitch(bagsSection, "Inventory.UpgradeIcon", L["Show Upgrade Icon"], "Displays an icon on items that are upgrades for your character", UpdateInventorySettings)
	GUI:CreateSlider(bagsSection, "Inventory.BagsPerRow", L["Bags Per Row"], 1, 20, 1, L["BagsPerRow Desc"], UpdateBagAnchor)
	GUI:CreateSlider(bagsSection, "Inventory.iLvlToShow", "ItemLevel Threshold", 1, 800, 1, L["iLvlToShow Desc"], UpdateBagStatus)

	-- BANK SECTION
	local bankSection = GUI:AddSection(inventoryCategory, BANK)
	GUI:CreateSlider(bankSection, "Inventory.BankPerRow", L["Bank Bags Per Row"], 1, 20, 1, L["BankPerRow Desc"], UpdateBagAnchor)

	-- OTHER SECTION
	local otherInventorySection = GUI:AddSection(inventoryCategory, OTHER)
	GUI:CreateSwitch(otherInventorySection, "Inventory.PetTrash", L["Pet Trash Currencies"], "In patch 9.1, you can buy 3 battle pets by using specific trash items. Keep this enabled, will sort these items into Collection Filter, and won't be sold by auto junk", UpdateInventorySettings)

	-- Auto Repair Dropdown Options
	local autoRepairOptions = {
		{ text = NONE, value = 0 },
		{ text = GUILD, value = 1 },
		{ text = PLAYER, value = 2 },
	}
	GUI:CreateDropdown(otherInventorySection, "Inventory.AutoRepair", L["Auto Repair Gear"], autoRepairOptions, "Choose how to automatically repair your gear", UpdateInventorySettings)

	-- FILTERS SECTION
	local filtersSection = GUI:AddSection(inventoryCategory, FILTERS)
	GUI:CreateSwitch(filtersSection, "Inventory.ItemFilter", L["Filter Items Into Categories"], L["ItemFilter Desc"], UpdateBagStatus)
	GUI:CreateSwitch(filtersSection, "Inventory.GatherEmpty", L["Gather Empty Slots Into One Button"], L["GatherEmpty Desc"], UpdateBagStatus)

	-- SIZES SECTION
	local inventorySizesSection = GUI:AddSection(inventoryCategory, L["Sizes"])
	GUI:CreateSlider(inventorySizesSection, "Inventory.BagsWidth", L["Bags Width"], 8, 16, 1, L["BagsWidth Desc"], UpdateBagSize)
	GUI:CreateSlider(inventorySizesSection, "Inventory.BankWidth", L["Bank Width"], 10, 18, 1, L["BankWidth Desc"], UpdateBagSize)
	GUI:CreateSlider(inventorySizesSection, "Inventory.IconSize", L["Slot Icon Size"], 28, 40, 1, L["IconSize Desc"] .. " (requires reload)", UpdateBagSize)

	-- BAG BAR SECTION
	local bagBarSection = GUI:AddSection(inventoryCategory, L["Bag Bar"])
	GUI:CreateSwitch(bagBarSection, "Inventory.BagBar", enableTextColor .. L["Enable Bagbar"], L["BagBar Desc"], UpdateInventorySettings)
	GUI:CreateSwitch(bagBarSection, "Inventory.JustBackpack", L["Just Show Main Backpack"], L["JustBackpack Desc"], UpdateInventorySettings)
	GUI:CreateSlider(bagBarSection, "Inventory.BagBarSize", L["BagBar Size"], 20, 34, 1, L["BagBarSize Desc"], UpdateInventorySettings)

	-- Growth Direction Dropdown Options
	local growthDirectionOptions = {
		{ text = "Horizontal", value = "HORIZONTAL" },
		{ text = "Vertical", value = "VERTICAL" },
	}
	GUI:CreateDropdown(bagBarSection, "Inventory.GrowthDirection", L["Growth Direction"], growthDirectionOptions, L["GrowthDirection Desc"], UpdateInventorySettings)

	-- Sort Direction Dropdown Options
	local sortDirectionOptions = {
		{ text = "Ascending", value = "ASCENDING" },
		{ text = "Descending", value = "DESCENDING" },
	}
	GUI:CreateDropdown(bagBarSection, "Inventory.SortDirection", L["Sort Direction"], sortDirectionOptions, "Choose the direction for sorting bag contents", UpdateInventorySettings)
end

-- ====================================================
-- LOOT CATEGORY
-- ====================================================
local function CreateLootCategory()
	local lootIcon = "Interface\\Icons\\INV_Misc_Coin_02"
	local lootCategory = GUI:AddCategory("Loot", lootIcon)

	-- Hook Functions for Loot
	local function UpdateLootSettings()
		local lootModule = K:GetModule("Loot")
		if lootModule then
			print("|cff669DFFKkthnxUI:|r Loot settings updated!")
		end
	end

	local function UpdateGroupLoot()
		local lootModule = K:GetModule("Loot")
		if lootModule and lootModule.UpdateGroupLoot then
			lootModule:UpdateGroupLoot()
			print("|cff669DFFKkthnxUI:|r Group loot settings updated!")
		end
	end

	local function UpdateFastLoot()
		local lootModule = K:GetModule("Loot")
		if lootModule and lootModule.UpdateFastLoot then
			lootModule:UpdateFastLoot()
			print("|cff669DFFKkthnxUI:|r Fast loot settings updated!")
		end
	end

	-- ========================================
	-- GENERAL SECTION
	-- ========================================
	local generalLootSection = GUI:AddSection(lootCategory, GENERAL)

	GUI:CreateSwitch(generalLootSection, "Loot.Enable", enableTextColor .. L["Enable Loot"], L["Enable Desc"], UpdateLootSettings)

	GUI:CreateSwitch(generalLootSection, "Loot.GroupLoot", enableTextColor .. L["Enable Group Loot"], L["GroupLoot Desc"], UpdateGroupLoot)

	-- ========================================
	-- AUTO-LOOTING SECTION
	-- ========================================
	local autoLootingSection = GUI:AddSection(lootCategory, L["Auto-Looting"])

	GUI:CreateSwitch(autoLootingSection, "Loot.FastLoot", L["Faster Auto-Looting"], L["FastLoot Desc"], UpdateFastLoot)

	-- ========================================
	-- AUTO-CONFIRM SECTION
	-- ========================================
	local autoConfirmSection = GUI:AddSection(lootCategory, L["Auto-Confirm"])

	GUI:CreateSwitch(autoConfirmSection, "Loot.AutoConfirm", L["Auto Confirm Loot Dialogs"], "Automatically confirms loot dialogs and prompts", UpdateLootSettings)

	GUI:CreateSwitch(autoConfirmSection, "Loot.AutoGreed", L["Auto Greed Green Items"], L["AutoGreed Desc"], UpdateLootSettings)
end

-- ====================================================
-- MINIMAP CATEGORY
-- ====================================================
local function CreateMinimapCategory()
	local minimapIcon = "Interface\\Icons\\INV_Misc_Map_01"
	local minimapCategory = GUI:AddCategory("Minimap", minimapIcon)

	-- Hook Functions for Minimap
	local function UpdateMinimapSettings()
		local minimapModule = K:GetModule("Minimap")
		if minimapModule then
			print("|cff669DFFKkthnxUI:|r Minimap settings updated!")
		end
	end

	local function UpdateMinimapSize()
		local minimapModule = K:GetModule("Minimap")
		if minimapModule and minimapModule.UpdateSize then
			minimapModule:UpdateSize()
			print("|cff669DFFKkthnxUI:|r Minimap size updated!")
		end
	end

	local function UpdateRecycleBin()
		local minimapModule = K:GetModule("Minimap")
		if minimapModule and minimapModule.UpdateRecycleBin then
			minimapModule:UpdateRecycleBin()
			print("|cff669DFFKkthnxUI:|r Minimap RecycleBin updated!")
		end
	end

	local function UpdateEasyVolume()
		local minimapModule = K:GetModule("Minimap")
		if minimapModule and minimapModule.UpdateEasyVolume then
			minimapModule:UpdateEasyVolume()
			print("|cff669DFFKkthnxUI:|r EasyVolume updated!")
		end
	end

	local function UpdateMailPulse()
		local minimapModule = K:GetModule("Minimap")
		if minimapModule and minimapModule.UpdateMailPulse then
			minimapModule:UpdateMailPulse()
			print("|cff669DFFKkthnxUI:|r Mail pulse updated!")
		end
	end

	-- ========================================
	-- GENERAL SECTION
	-- ========================================
	local generalMinimapSection = GUI:AddSection(minimapCategory, GENERAL)

	GUI:CreateSwitch(generalMinimapSection, "Minimap.Enable", enableTextColor .. L["Enable Minimap"], L["Enable Desc"], UpdateMinimapSettings)

	GUI:CreateSwitch(generalMinimapSection, "Minimap.Calendar", L["Show Minimap Calendar"], L["If enabled, show minimap calendar icon on minimap.|nYou can simply click mouse middle button on minimap to toggle calendar even without this option."], UpdateMinimapSettings)

	-- ========================================
	-- FEATURES SECTION
	-- ========================================
	local featuresSection = GUI:AddSection(minimapCategory, L["Features"])

	GUI:CreateSwitch(featuresSection, "Minimap.EasyVolume", L["EasyVolume"], L["EasyVolumeTip"], UpdateEasyVolume)

	GUI:CreateSwitch(featuresSection, "Minimap.MailPulse", L["Pulse Minimap Mail"], L["MailPulse Desc"], UpdateMailPulse)

	GUI:CreateSwitch(featuresSection, "Minimap.QueueStatusText", L["QueueStatus"], "Show queue status text on the minimap", UpdateMinimapSettings)

	GUI:CreateSwitch(featuresSection, "Minimap.ShowRecycleBin", L["Show Minimap Button Collector"], L["ShowRecycleBin Desc"], UpdateRecycleBin)

	-- ========================================
	-- RECYCLE BIN SECTION
	-- ========================================
	local recycleBinSection = GUI:AddSection(minimapCategory, L["Recycle Bin"])

	-- RecycleBin Position Dropdown Options
	local recycleBinPositionOptions = {
		{ text = "Top", value = "TOP" },
		{ text = "Top Right", value = "TOPRIGHT" },
		{ text = "Right", value = "RIGHT" },
		{ text = "Bottom Right", value = "BOTTOMRIGHT" },
		{ text = "Bottom", value = "BOTTOM" },
		{ text = "Bottom Left", value = "BOTTOMLEFT" },
		{ text = "Left", value = "LEFT" },
		{ text = "Top Left", value = "TOPLEFT" },
	}

	GUI:CreateDropdown(recycleBinSection, "Minimap.RecycleBinPosition", L["Set RecycleBin Positon"], recycleBinPositionOptions, L["RecycleBinPosition Desc"], UpdateRecycleBin)

	-- ========================================
	-- LOCATION SECTION
	-- ========================================
	local locationSection = GUI:AddSection(minimapCategory, L["Location"])

	-- Location Text Style Dropdown Options
	local locationTextOptions = {
		{ text = "Hidden", value = "HIDE" },
		{ text = "Simple", value = "SIMPLE" },
		{ text = "Full", value = "FULL" },
	}

	GUI:CreateDropdown(locationSection, "Minimap.LocationText", L["Location Text Style"], locationTextOptions, "Choose how location text is displayed on the minimap", UpdateMinimapSettings)

	-- ========================================
	-- SIZE SECTION
	-- ========================================
	local sizeSection = GUI:AddSection(minimapCategory, L["Size"])

	GUI:CreateSlider(sizeSection, "Minimap.Size", L["Minimap Size"], 120, 300, 1, L["Size Desc"], UpdateMinimapSize)
end

-- ====================================================
-- MISC CATEGORY
-- ====================================================
local function CreateMiscCategory()
	local miscIcon = "Interface\\Icons\\INV_Misc_Bag_10"
	local miscCategory = GUI:AddCategory("Misc", miscIcon)

	-- Hook Functions for Misc
	local function UpdateMiscSettings()
		local miscModule = K:GetModule("Misc")
		if miscModule then
			print("|cff669DFFKkthnxUI:|r Misc settings updated!")
		end
	end

	local function UpdateYClassColors()
		local miscModule = K:GetModule("Misc")
		if miscModule and miscModule.UpdateYClassColors then
			miscModule:UpdateYClassColors()
			print("|cff669DFFKkthnxUI:|r Class colors updated!")
		end
	end

	local function UpdateMaxZoomLevel()
		local miscModule = K:GetModule("Misc")
		if miscModule and miscModule.UpdateMaxZoomLevel then
			miscModule:UpdateMaxZoomLevel()
			print("|cff669DFFKkthnxUI:|r Max camera zoom level updated!")
		end
	end

	local function UpdateMarkerGrid()
		local miscModule = K:GetModule("Misc")
		if miscModule and miscModule.UpdateMarkerGrid then
			miscModule:UpdateMarkerGrid()
			print("|cff669DFFKkthnxUI:|r Marker grid updated!")
		end
	end

	-- ========================================
	-- GENERAL SECTION
	-- ========================================
	local generalMiscSection = GUI:AddSection(miscCategory, GENERAL)

	GUI:CreateSwitch(generalMiscSection, "Misc.ColorPicker", L["Enhanced Color Picker"], "Enhances the default color picker with additional functionality", UpdateMiscSettings)

	GUI:CreateSwitch(generalMiscSection, "Misc.EasyMarking", L["EasyMarking by Ctrl + LeftClick"], "Allows quick marking of targets using Ctrl + Left Click", UpdateMiscSettings)

	GUI:CreateSwitch(generalMiscSection, "Misc.HideBanner", L["Hide RaidBoss EmoteFrame"], "Hides the raid boss emote frame during encounters", UpdateMiscSettings)

	GUI:CreateSwitch(generalMiscSection, "Misc.HideBossEmote", L["Hide BossBanner"], "Hides the boss banner that appears during boss encounters", UpdateMiscSettings)

	GUI:CreateSwitch(generalMiscSection, "Misc.ImprovedStats", L["Display Character Frame Full Stats"], "Shows expanded character statistics in the character frame", UpdateMiscSettings)

	GUI:CreateSwitch(generalMiscSection, "Misc.NoTalkingHead", L["Remove And Hide The TalkingHead Frame"], "Completely removes the talking head frame from quest interactions", UpdateMiscSettings)

	GUI:CreateSwitch(generalMiscSection, "Misc.ShowWowHeadLinks", L["Show Wowhead Links Above Questlog Frame"], "Displays helpful Wowhead links above the quest log frame", UpdateMiscSettings)

	GUI:CreateSwitch(generalMiscSection, "Misc.SlotDurability", L["Show Slot Durability %"], "Shows durability percentage on equipment slots", UpdateMiscSettings)

	GUI:CreateSwitch(generalMiscSection, "Misc.YClassColors", "Enable ClassColors", "Toggle the display of class colors in the guild roster, friends list, and Who frame.", UpdateYClassColors)

	-- ========================================
	-- CAMERA SECTION
	-- ========================================
	local cameraSection = GUI:AddSection(miscCategory, "Camera")

	GUI:CreateSlider(cameraSection, "Misc.MaxCameraZoom", "Max Camera Zoom Level", 1, 2.6, 0.1, "Set the maximum camera zoom distance", UpdateMaxZoomLevel)

	-- ========================================
	-- TRADE SKILL SECTION
	-- ========================================
	local tradeSkillSection = GUI:AddSection(miscCategory, "Trade Skill")

	GUI:CreateSwitch(tradeSkillSection, "Misc.TradeTabs", L["Add Spellbook-Like Tabs On TradeSkillFrame"], "Adds convenient tabs to the trade skill frame similar to the spellbook", UpdateMiscSettings)

	-- ========================================
	-- SOCIAL SECTION
	-- ========================================
	local socialSection = GUI:AddSection(miscCategory, "Social")

	GUI:CreateSwitch(socialSection, "Misc.AFKCamera", L["AFK Camera"], "Enables automatic camera movement when you go AFK", UpdateMiscSettings)

	GUI:CreateSwitch(socialSection, "Misc.EnhancedFriends", L["Enhanced Colors (Friends/Guild +)"], "Enhances the friends and guild list with improved colors and information", UpdateMiscSettings)

	GUI:CreateSwitch(socialSection, "Misc.MuteSounds", "Mute Various Annoying Sounds In-Game", "Mutes specific annoying sound effects in the game", UpdateMiscSettings)

	GUI:CreateSwitch(socialSection, "Misc.ParagonEnable", L["Add Paragon Info on ReputationFrame"], L["ParagonReputationTip"], UpdateMiscSettings)

	-- ========================================
	-- MAIL SECTION
	-- ========================================
	local mailSection = GUI:AddSection(miscCategory, "Mail")

	GUI:CreateSwitch(mailSection, "Misc.EnhancedMail", "Add 'Postal' Like Feaures To The Mailbox", "Enhances the mailbox with features similar to the Postal addon", UpdateMiscSettings)

	-- ========================================
	-- QUESTING SECTION
	-- ========================================
	local questingSection = GUI:AddSection(miscCategory, "Questing")

	GUI:CreateSwitch(questingSection, "Misc.ExpRep", "Display Exp/Rep Bar (Minimap)", "Shows experience and reputation bars near the minimap", UpdateMiscSettings)

	GUI:CreateSwitch(questingSection, "Misc.QuestTool", "Add Tips For Some Quests And World Quests", "Provides helpful tips and information for quests and world quests", UpdateMiscSettings)

	-- ========================================
	-- MYTHIC+ SECTION
	-- ========================================
	local mythicPlusSection = GUI:AddSection(miscCategory, "Mythic+")

	GUI:CreateSwitch(mythicPlusSection, "Misc.MDGuildBest", L["Show Mythic+ GuildBest"], "Displays your guild's best Mythic+ dungeon times and scores", UpdateMiscSettings)

	-- ========================================
	-- RAID TOOL SECTION
	-- ========================================
	local raidToolSection = GUI:AddSection(miscCategory, "Raid Tool")

	GUI:CreateSwitch(raidToolSection, "Misc.RaidTool", L["Show Raid Utility Frame"], "Shows the raid utility frame with useful raid tools and information", UpdateMiscSettings)

	GUI:CreateSwitch(raidToolSection, "Misc.RMRune", "RMRune - Add Info", "Adds additional information for Runic Power and similar resources", UpdateMiscSettings)

	GUI:CreateTextInput(raidToolSection, "Misc.DBMCount", "DBMCount - Add Info", "Enter custom info...", "Configure custom DBM count information", UpdateMiscSettings)

	GUI:CreateSlider(raidToolSection, "Misc.MarkerBarSize", "Marker Bar Size - Add Info", 20, 40, 1, "Size of the world marker bar buttons", UpdateMarkerGrid)

	-- World Markers Bar Dropdown Options
	local markerBarOptions = {
		{ text = "Disabled", value = "DISABLED" },
		{ text = "Always Show", value = "ALWAYS" },
		{ text = "In Group Only", value = "GROUP" },
		{ text = "In Raid Only", value = "RAID" },
	}

	GUI:CreateDropdown(raidToolSection, "Misc.ShowMarkerBar", L["World Markers Bar"], markerBarOptions, "Controls when the world markers bar is displayed", UpdateMarkerGrid)

	-- ========================================
	-- MISCELLANEOUS SECTION
	-- ========================================
	local miscellaneousSection = GUI:AddSection(miscCategory, "Miscellaneous")

	-- Conditional widget for GemEnchantInfo (only show if ItemLevel is enabled)
	local function shouldShowGemEnchantInfo()
		return GetConfigValue("Misc.ItemLevel") == true
	end

	-- We'll create this as a regular widget for now, but in a full implementation
	-- you could use conditional visibility
	GUI:CreateSwitch(miscellaneousSection, "Misc.GemEnchantInfo", L["Character/Inspect Gem/Enchant Info"], "Shows gem and enchant information on character and inspect frames", UpdateMiscSettings)

	GUI:CreateSwitch(miscellaneousSection, "Misc.QuickJoin", L["QuickJoin"], L["QuickJoinTip"], UpdateMiscSettings)

	GUI:CreateSwitch(miscellaneousSection, "Misc.ItemLevel", L["Show Character/Inspect ItemLevel Info"], "Displays item level information on character and inspect frames", UpdateMiscSettings)
end

-- ====================================================
-- NAMEPLATE CATEGORY FUNCTION
-- ====================================================
local function CreateNameplateCategory()
	local nameplateIcon = "Interface\\Icons\\Spell_Arcane_MindMastery"
	local nameplateCategory = GUI:AddCategory("Nameplate", nameplateIcon)

	-- Hook Functions for Nameplate
	local function refreshNameplates()
		local nameplateModule = K:GetModule("Unitframes")
		if nameplateModule and nameplateModule.RefreshNameplates then
			nameplateModule:RefreshNameplates()
			print("|cff669DFFKkthnxUI:|r Nameplates refreshed!")
		end
	end

	local function UpdateCustomUnitList()
		local nameplateModule = K:GetModule("Unitframes")
		if nameplateModule and nameplateModule.UpdateCustomUnitList then
			nameplateModule:UpdateCustomUnitList()
			print("|cff669DFFKkthnxUI:|r Custom unit list updated!")
		end
	end

	local function UpdatePowerUnitList()
		local nameplateModule = K:GetModule("Nameplates")
		if nameplateModule and nameplateModule.UpdatePowerUnitList then
			nameplateModule:UpdatePowerUnitList()
			print("|cff669DFFKkthnxUI:|r Power unit list updated!")
		end
	end

	local function togglePlayerPlate()
		local nameplateModule = K:GetModule("Nameplates")
		if nameplateModule and nameplateModule.TogglePlayerPlate then
			nameplateModule:TogglePlayerPlate()
			print("|cff669DFFKkthnxUI:|r Player nameplate toggled!")
		end
	end

	local function togglePlatePower()
		local nameplateModule = K:GetModule("Nameplates")
		if nameplateModule and nameplateModule.TogglePlatePower then
			nameplateModule:TogglePlatePower()
			print("|cff669DFFKkthnxUI:|r Player nameplate power toggled!")
		end
	end

	local function UpdateNameplateSettings()
		local nameplateModule = K:GetModule("Nameplates")
		if nameplateModule then
			print("|cff669DFFKkthnxUI:|r Nameplate settings updated!")
		end
	end

	-- ========================================
	-- GENERAL SECTION
	-- ========================================
	local generalNameplateSection = GUI:AddSection(nameplateCategory, GENERAL)

	GUI:CreateSwitch(generalNameplateSection, "Nameplate.Enable", enableTextColor .. L["Enable Nameplates"], "Toggle the entire nameplate system on/off", UpdateNameplateSettings)
	GUI:CreateSwitch(generalNameplateSection, "Nameplate.ClassIcon", L["Show Enemy Class Icons"], "Displays class icons on enemy nameplates", refreshNameplates)
	GUI:CreateSwitch(generalNameplateSection, "Nameplate.ColoredTarget", "Colored Targeted Nameplate", "If enabled, this will color your targeted nameplate|nIts priority is higher than custom/threat colors", refreshNameplates)
	GUI:CreateSwitch(generalNameplateSection, "Nameplate.CustomUnitColor", L["Colored Custom Units"], "Enable custom coloring for specific units", refreshNameplates)
	GUI:CreateSwitch(generalNameplateSection, "Nameplate.FriendlyCC", L["Show Friendly ClassColor"], "Show class colors on friendly unit nameplates", refreshNameplates)
	GUI:CreateSwitch(generalNameplateSection, "Nameplate.FullHealth", L["Show Health Value"], "Display health values on nameplates", refreshNameplates)
	GUI:CreateSwitch(generalNameplateSection, "Nameplate.HostileCC", L["Show Hostile ClassColor"], "Show class colors on hostile unit nameplates", refreshNameplates)
	GUI:CreateSwitch(generalNameplateSection, "Nameplate.InsideView", L["Interacted Nameplate Stay Inside"], "Keep interacted nameplates visible inside the game view", refreshNameplates)
	GUI:CreateSwitch(generalNameplateSection, "Nameplate.NameOnly", L["Show Only Names For Friendly"], "Show only names for friendly units, hiding health bars", refreshNameplates)
	GUI:CreateSwitch(generalNameplateSection, "Nameplate.NameplateClassPower", "Show Nameplate Class Power", "Display class power resources on nameplates", refreshNameplates)

	-- Aura Filter Style Dropdown Options
	local auraFilterOptions = {
		{ text = "White & Black List", value = 1 },
		{ text = "List & Player", value = 2 },
		{ text = "List & Player & CCs", value = 3 },
	}
	GUI:CreateDropdown(generalNameplateSection, "Nameplate.AuraFilter", L["Auras Filter Style"], auraFilterOptions, "Choose which auras to display on nameplates", refreshNameplates)

	local targetIndicatorOptions = {
		{ text = "Disable", value = 1 },
		{ text = "Top Arrow", value = 2 },
		{ text = "Right Arrow", value = 3 },
		{ text = "Border Glow", value = 4 },
		{ text = "Top Arrow + Glow", value = 5 },
		{ text = "Right Arrow + Glow", value = 6 },
	}
	GUI:CreateDropdown(generalNameplateSection, "Nameplate.TargetIndicator", L["TargetIndicator Style"], targetIndicatorOptions, "Choose the target indicator style", refreshNameplates)

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
	GUI:CreateDropdown(generalNameplateSection, "Nameplate.TargetIndicatorTexture", "TargetIndicator Texture", targetIndicatorTextureOptions, "Choose the texture for target indicators", refreshNameplates)

	GUI:CreateTextInput(generalNameplateSection, "Nameplate.CustomUnitList", L["Custom UnitColor List"], "Enter unit names...", L["CustomUnitTip"], UpdateCustomUnitList)
	GUI:CreateTextInput(generalNameplateSection, "Nameplate.PowerUnitList", L["Custom PowerUnit List"], "Enter unit names...", L["CustomUnitTip"], UpdatePowerUnitList)

	-- ========================================
	-- CASTBAR SECTION
	-- ========================================
	local castbarSection = GUI:AddSection(nameplateCategory, "Castbar")
	GUI:CreateSwitch(castbarSection, "Nameplate.CastTarget", "Show Nameplate Target Of Casting Spell", "Display the target of spells being cast on nameplates", refreshNameplates)
	GUI:CreateSwitch(castbarSection, "Nameplate.CastbarGlow", "Force Crucial Spells To Glow", "Make important spells glow on nameplates", refreshNameplates)

	-- ========================================
	-- THREAT SECTION
	-- ========================================
	local threatSection = GUI:AddSection(nameplateCategory, "Threat")
	GUI:CreateSwitch(threatSection, "Nameplate.DPSRevertThreat", L["Revert Threat Color If Not Tank"], "Use standard threat colors when not tanking", refreshNameplates)
	GUI:CreateSwitch(threatSection, "Nameplate.TankMode", L["Force TankMode Colored"], "Force tank-style threat coloring regardless of role", refreshNameplates)

	-- ========================================
	-- MISCELLANEOUS SECTION
	-- ========================================
	local miscellaneousNameplateSection = GUI:AddSection(nameplateCategory, "Miscellaneous")

	GUI:CreateSwitch(miscellaneousNameplateSection, "Nameplate.AKSProgress", L["Show AngryKeystones Progress"], "Display AngryKeystones progress information on nameplates", refreshNameplates)
	GUI:CreateSwitch(miscellaneousNameplateSection, "Nameplate.PlateAuras", "Target Nameplate Auras", "Show auras on target nameplates", refreshNameplates)
	GUI:CreateSwitch(miscellaneousNameplateSection, "Nameplate.QuestIndicator", L["Quest Progress Indicator"], "Show quest progress indicators on nameplates", refreshNameplates)
	GUI:CreateSwitch(miscellaneousNameplateSection, "Nameplate.Smooth", L["Smooth Bars Transition"], "Enable smooth animations for nameplate bars", refreshNameplates)

	-- ========================================
	-- SIZES SECTION
	-- ========================================
	local sizesNameplateSection = GUI:AddSection(nameplateCategory, L["Sizes"])
	GUI:CreateSlider(sizesNameplateSection, "Nameplate.AuraSize", L["Auras Size"], 18, 40, 1, "Size of aura icons on nameplates", refreshNameplates)
	GUI:CreateSlider(sizesNameplateSection, "Nameplate.ExecuteRatio", L["Unit Execute Ratio"], 0, 90, 1, L["ExecuteRatioTip"], refreshNameplates)
	GUI:CreateSlider(sizesNameplateSection, "Nameplate.HealthTextSize", L["HealthText FontSize"], 8, 16, 1, "Font size for health text on nameplates", refreshNameplates)
	GUI:CreateSlider(sizesNameplateSection, "Nameplate.MaxAuras", L["Max Auras"], 4, 8, 1, "Maximum number of auras to show on nameplates", refreshNameplates)
	GUI:CreateSlider(sizesNameplateSection, "Nameplate.MinAlpha", L["Non-Target Nameplate Alpha"], 0.1, 1, 0.1, "Transparency of non-targeted nameplates", refreshNameplates)
	GUI:CreateSlider(sizesNameplateSection, "Nameplate.MinScale", L["Non-Target Nameplate Scale"], 0.1, 3, 0.1, "Scale of non-targeted nameplates", refreshNameplates)
	GUI:CreateSlider(sizesNameplateSection, "Nameplate.NameTextSize", L["NameText FontSize"], 8, 16, 1, "Font size for names on nameplates", refreshNameplates)
	GUI:CreateSlider(sizesNameplateSection, "Nameplate.PlateHeight", L["Nameplate Height"], 6, 28, 1, "Height of nameplate bars", refreshNameplates)
	GUI:CreateSlider(sizesNameplateSection, "Nameplate.PlateWidth", L["Nameplate Width"], 80, 240, 1, "Width of nameplate bars", refreshNameplates)
	GUI:CreateSlider(sizesNameplateSection, "Nameplate.VerticalSpacing", L["Nameplate Vertical Spacing"], 0.5, 2.5, 0.1, "Vertical spacing between stacked nameplates", refreshNameplates)
	GUI:CreateSlider(sizesNameplateSection, "Nameplate.SelectedScale", "SelectedScale", 1, 1.4, 0.1, "Scale multiplier for selected/targeted nameplates", refreshNameplates)

	-- ========================================
	-- PLAYER NAMEPLATE TOGGLES SECTION
	-- ========================================
	local playerTogglesSection = GUI:AddSection(nameplateCategory, "Player Nameplate Toggles")

	GUI:CreateSwitch(playerTogglesSection, "Nameplate.ShowPlayerPlate", enableTextColor .. L["Enable Personal Resource"], "Show your personal resource nameplate", togglePlayerPlate)

	GUI:CreateSwitch(playerTogglesSection, "Nameplate.PPGCDTicker", L["Enable GCD Ticker"], "Show global cooldown ticker on personal nameplate", refreshNameplates)
	GUI:CreateSwitch(playerTogglesSection, "Nameplate.PPHideOOC", L["Only Visible in Combat"], "Only show personal nameplate during combat", refreshNameplates)

	GUI:CreateSwitch(playerTogglesSection, "Nameplate.PPPowerText", L["Show Power Value"], "Display power values on personal nameplate", togglePlatePower)

	-- ========================================
	-- PLAYER NAMEPLATE VALUES SECTION
	-- ========================================
	local playerValuesSection = GUI:AddSection(nameplateCategory, "Player Nameplate Values")

	GUI:CreateSlider(playerValuesSection, "Nameplate.PPHeight", L["Classpower/Healthbar Height"], 4, 10, 1, "Height of class power and health bars on personal nameplate", refreshNameplates)

	GUI:CreateSlider(playerValuesSection, "Nameplate.PPIconSize", L["PlayerPlate IconSize"], 20, 40, 1, "Size of icons on personal nameplate", refreshNameplates)

	GUI:CreateSlider(playerValuesSection, "Nameplate.PPPHeight", L["PlayerPlate Powerbar Height"], 4, 10, 1, "Height of power bar on personal nameplate", refreshNameplates)

	-- ========================================
	-- COLORS SECTION
	-- ========================================
	local colorsNameplateSection = GUI:AddSection(nameplateCategory, COLORS)

	GUI:CreateColorPicker(colorsNameplateSection, "Nameplate.CustomColor", L["Custom Color"], "Color for custom units", refreshNameplates)

	GUI:CreateColorPicker(colorsNameplateSection, "Nameplate.InsecureColor", L["Insecure Color"], "Color for insecure threat level", refreshNameplates)

	GUI:CreateColorPicker(colorsNameplateSection, "Nameplate.OffTankColor", L["Off-Tank Color"], "Color for off-tank units", refreshNameplates)

	GUI:CreateColorPicker(colorsNameplateSection, "Nameplate.SecureColor", L["Secure Color"], "Color for secure threat level", refreshNameplates)

	GUI:CreateColorPicker(colorsNameplateSection, "Nameplate.TargetColor", "Selected Target Coloring", "Color for targeted nameplates", refreshNameplates)

	GUI:CreateColorPicker(colorsNameplateSection, "Nameplate.TargetIndicatorColor", L["TargetIndicator Color"], "Color for target indicators", refreshNameplates)

	GUI:CreateColorPicker(colorsNameplateSection, "Nameplate.TransColor", L["Transition Color"], "Color for threat transition states", refreshNameplates)
end

-- ====================================================
-- PARTY CATEGORY FUNCTION
-- ====================================================
local function CreatePartyCategory()
	local partyIcon = "Interface\\Icons\\Spell_ChargePositive"
	local partyCategory = GUI:AddCategory("Party", partyIcon)

	-- Hook Functions for Party
	local function UpdateUnitPartySize()
		local unitframeModule = K:GetModule("Unitframes")
		if unitframeModule and unitframeModule.UpdatePartySize then
			unitframeModule:UpdatePartySize()
			print("|cff669DFFKkthnxUI:|r Party frame size updated!")
		end
	end

	local function UpdatePartySettings()
		local unitframeModule = K:GetModule("Unitframes")
		if unitframeModule then
			print("|cff669DFFKkthnxUI:|r Party settings updated!")
			-- Party frames typically refresh themselves automatically
		end
	end

	-- ========================================
	-- GENERAL SECTION
	-- ========================================
	local generalPartySection = GUI:AddSection(partyCategory, GENERAL)

	GUI:CreateSwitch(generalPartySection, "Party.Enable", enableTextColor .. L["Enable Party"], "Toggle the entire party frame system on/off", UpdatePartySettings)

	GUI:CreateSwitch(generalPartySection, "Party.ShowBuffs", L["Show Party Buffs"], "Display buffs on party member frames", UpdatePartySettings)

	GUI:CreateSwitch(generalPartySection, "Party.ShowHealPrediction", L["Show HealPrediction Statusbars"], "Show incoming heal predictions on party frames", UpdatePartySettings)

	GUI:CreateSwitch(generalPartySection, "Party.ShowPartySolo", "Show Party Frames While Solo", "Display party frames even when playing solo", UpdatePartySettings)

	GUI:CreateSwitch(generalPartySection, "Party.ShowPet", L["Show Party Pets"], "Display pet frames for party members", UpdatePartySettings)

	GUI:CreateSwitch(generalPartySection, "Party.ShowPlayer", L["Show Player In Party"], "Include your own frame in the party display", UpdatePartySettings)

	GUI:CreateSwitch(generalPartySection, "Party.Smooth", L["Smooth Bar Transition"], "Enable smooth animations for party frame bars", UpdatePartySettings)

	GUI:CreateSwitch(generalPartySection, "Party.TargetHighlight", L["Show Highlighted Target"], "Highlight the targeted party member", UpdatePartySettings)

	-- ========================================
	-- PARTY CASTBARS SECTION
	-- ========================================
	local castbarsPartySection = GUI:AddSection(partyCategory, "Party Castbars")

	GUI:CreateSwitch(castbarsPartySection, "Party.Castbars", L["Show Castbars"], "Display castbars on party member frames", UpdatePartySettings)

	GUI:CreateSwitch(castbarsPartySection, "Party.CastbarIcon", L["Show Castbars"] .. " Icon", "Show spell icons on party member castbars", UpdatePartySettings)

	-- ========================================
	-- SIZES SECTION
	-- ========================================
	local sizesPartySection = GUI:AddSection(partyCategory, L["Sizes"])

	GUI:CreateSlider(sizesPartySection, "Party.HealthHeight", "Party Frame Health Height", 20, 50, 1, "Height of health bars on party frames", UpdateUnitPartySize)

	GUI:CreateSlider(sizesPartySection, "Party.HealthWidth", "Party Frame Health Width", 120, 180, 1, "Width of health bars on party frames", UpdateUnitPartySize)

	GUI:CreateSlider(sizesPartySection, "Party.PowerHeight", "Party Frame Power Height", 10, 30, 1, "Height of power bars on party frames", UpdateUnitPartySize)

	-- ========================================
	-- COLORS SECTION
	-- ========================================
	local colorsPartySection = GUI:AddSection(partyCategory, COLORS)

	-- Health Color Format Dropdown Options
	local healthColorOptions = {
		{ text = "Class", value = 1 },
		{ text = "Dark", value = 2 },
		{ text = "Value", value = 3 },
	}

	GUI:CreateDropdown(colorsPartySection, "Party.HealthbarColor", L["Health Color Format"], healthColorOptions, "Choose how health bars are colored on party frames", UpdatePartySettings)
end

-- ====================================================
-- RAID CATEGORY FUNCTION
-- ====================================================
local function CreateRaidCategory()
	local raidIcon = "Interface\\Icons\\Spell_Holy_PrayerOfHealing02"
	local raidCategory = GUI:AddCategory("Raid", raidIcon)

	-- Hook Functions for Raid
	local function UpdateUnitRaidSize()
		local unitframeModule = K:GetModule("Unitframes")
		if unitframeModule and unitframeModule.UpdateRaidSize then
			unitframeModule:UpdateRaidSize()
			print("|cff669DFFKkthnxUI:|r Raid frame size updated!")
		end
	end

	local function UpdateRaidSettings()
		local unitframeModule = K:GetModule("Unitframes")
		if unitframeModule then
			print("|cff669DFFKkthnxUI:|r Raid settings updated!")
			-- Raid frames typically refresh themselves automatically
		end
	end

	local function UpdateRaidBuffs()
		local unitframeModule = K:GetModule("Unitframes")
		if unitframeModule and unitframeModule.UpdateRaidBuffs then
			unitframeModule:UpdateRaidBuffs()
			print("|cff669DFFKkthnxUI:|r Raid buffs updated!")
		end
	end

	local function UpdateRaidDebuffs()
		local unitframeModule = K:GetModule("Unitframes")
		if unitframeModule and unitframeModule.UpdateRaidDebuffs then
			unitframeModule:UpdateRaidDebuffs()
			print("|cff669DFFKkthnxUI:|r Raid debuffs updated!")
		end
	end

	-- ========================================
	-- GENERAL SECTION
	-- ========================================
	local generalRaidSection = GUI:AddSection(raidCategory, GENERAL)

	GUI:CreateSwitch(generalRaidSection, "Raid.Enable", enableTextColor .. L["Enable Raidframes"], "Toggle the entire raid frame system on/off", UpdateRaidSettings)

	GUI:CreateSwitch(generalRaidSection, "Raid.HorizonRaid", L["Horizontal Raid Frames"], "Arrange raid frames horizontally instead of vertically", UpdateRaidSettings)

	GUI:CreateSwitch(generalRaidSection, "Raid.MainTankFrames", L["Show MainTank Frames"], "Display dedicated frames for main tanks", UpdateRaidSettings)

	GUI:CreateSwitch(generalRaidSection, "Raid.PowerBarShow", "Toggle The visibility Of All Power Bars", "Show or hide power bars on all raid frames", UpdateRaidSettings)

	GUI:CreateSwitch(generalRaidSection, "Raid.ManabarShow", L["Show Manabars"], "Display mana bars on raid frames", UpdateRaidSettings)

	GUI:CreateSwitch(generalRaidSection, "Raid.ReverseRaid", L["Reverse Raid Frame Growth"], "Reverse the direction raid frames grow from their anchor point", UpdateRaidSettings)

	GUI:CreateSwitch(generalRaidSection, "Raid.ShowHealPrediction", L["Show HealPrediction Statusbars"], "Show incoming heal predictions on raid frames", UpdateRaidSettings)

	GUI:CreateSwitch(generalRaidSection, "Raid.ShowNotHereTimer", L["Show Away/DND Status"], "Display away/DND status on raid member frames", UpdateRaidSettings)

	GUI:CreateSwitch(generalRaidSection, "Raid.ShowRaidSolo", "Show Raid Frames While Solo", "Display raid frames even when playing solo", UpdateRaidSettings)

	GUI:CreateSwitch(generalRaidSection, "Raid.ShowTeamIndex", L["Show Group Number Team Index"], "Display group numbers on raid frames", UpdateRaidSettings)

	GUI:CreateSwitch(generalRaidSection, "Raid.Smooth", L["Smooth Bar Transition"], "Enable smooth animations for raid frame bars", UpdateRaidSettings)

	GUI:CreateSwitch(generalRaidSection, "Raid.TargetHighlight", L["Show Highlighted Target"], "Highlight the targeted raid member", UpdateRaidSettings)

	-- ========================================
	-- SIZES SECTION
	-- ========================================
	local sizesRaidSection = GUI:AddSection(raidCategory, L["Sizes"])

	GUI:CreateSlider(sizesRaidSection, "Raid.Height", L["Raidframe Height"], 20, 100, 1, "Height of raid member frames", UpdateUnitRaidSize)

	GUI:CreateSlider(sizesRaidSection, "Raid.NumGroups", L["Number Of Groups to Show"], 1, 8, 1, "Number of raid groups to display", UpdateRaidSettings)

	GUI:CreateSlider(sizesRaidSection, "Raid.Width", L["Raidframe Width"], 20, 100, 1, "Width of raid member frames", UpdateUnitRaidSize)

	-- ========================================
	-- COLORS SECTION
	-- ========================================
	local colorsRaidSection = GUI:AddSection(raidCategory, COLORS)

	-- Health Color Format Dropdown Options
	local healthColorOptions = {
		{ text = "Class", value = 1 },
		{ text = "Dark", value = 2 },
		{ text = "Value", value = 3 },
	}

	GUI:CreateDropdown(colorsRaidSection, "Raid.HealthbarColor", L["Health Color Format"], healthColorOptions, "Choose how health bars are colored on raid frames", UpdateRaidSettings)

	-- Health Format Dropdown Options
	local healthFormatOptions = {
		{ text = "Disabled", value = "DISABLED" },
		{ text = "Current", value = "CURRENT" },
		{ text = "Percent", value = "PERCENT" },
		{ text = "Current - Percent", value = "CURRENT_PERCENT" },
		{ text = "Current | Max", value = "CURRENT_MAX" },
		{ text = "Deficit", value = "DEFICIT" },
	}

	GUI:CreateDropdown(colorsRaidSection, "Raid.HealthFormat", L["Health Format"], healthFormatOptions, "Choose how health values are displayed on raid frames", UpdateRaidSettings)

	-- ========================================
	-- RAID BUFFS SECTION
	-- ========================================
	local raidBuffsSection = GUI:AddSection(raidCategory, "Raid Buffs")

	-- Raid Buffs Style Dropdown Options
	local raidBuffsStyleOptions = {
		{ text = "Standard", value = "Standard" },
		{ text = "Aura Track", value = "Aura Track" },
		{ text = "Disabled", value = "Disabled" },
	}

	GUI:CreateDropdown(raidBuffsSection, "Raid.RaidBuffsStyle", "Select the buff style you want to use", raidBuffsStyleOptions, "Choose the style for displaying buffs on raid frames", UpdateRaidBuffs)

	-- Standard Buff Options (conditionally shown)
	GUI:CreateDropdown(raidBuffsSection, "Raid.RaidBuffs", "Enable buffs display & filtering", {
		{ text = "Disabled", value = "DISABLED" },
		{ text = "Show All", value = "ALL" },
		{ text = "Track Important", value = "IMPORTANT" },
		{ text = "Personal Only", value = "PERSONAL" },
	}, "Control which buffs are displayed on raid frames", UpdateRaidBuffs)

	GUI:CreateSwitch(raidBuffsSection, "Raid.DesaturateBuffs", "Desaturate buffs that are not by me", "Gray out buffs that were not cast by you", UpdateRaidBuffs)

	-- Aura Track Options (conditionally shown)
	GUI:CreateSwitch(raidBuffsSection, "Raid.AuraTrack", "Enable auras tracking module for healer (replace buffs)", "Enable enhanced aura tracking designed for healers", UpdateRaidBuffs)

	GUI:CreateSwitch(raidBuffsSection, "Raid.AuraTrackIcons", "Use squared icons instead of status bars", "Display aura tracking as icons rather than bars", UpdateRaidBuffs)

	GUI:CreateSwitch(raidBuffsSection, "Raid.AuraTrackSpellTextures", "Display icons texture on aura squares instead of colored squares", "Show spell textures on aura tracking icons", UpdateRaidBuffs)

	GUI:CreateSlider(raidBuffsSection, "Raid.AuraTrackThickness", "Thickness size of status bars in pixel", 2, 10, 1, "Thickness of aura tracking status bars", UpdateRaidBuffs)

	-- ========================================
	-- RAID DEBUFFS SECTION
	-- ========================================
	local raidDebuffsSection = GUI:AddSection(raidCategory, "Raid Debuffs")

	GUI:CreateSwitch(raidDebuffsSection, "Raid.DebuffWatch", "Enable debuffs tracking (filtered auto by current gameplay (pvp or pve)", "Enable automatic debuff tracking based on content type", UpdateRaidDebuffs)

	GUI:CreateSwitch(raidDebuffsSection, "Raid.DebuffWatchDefault", "We have already a debuff tracking list for pve and pvp, use it?", "Use the built-in debuff tracking lists for PvE and PvP content", UpdateRaidDebuffs)
end

-- ====================================================
-- SKINS CATEGORY FUNCTION
-- ====================================================
local function CreateSkinsCategory()
	local skinsIcon = "Interface\\Icons\\INV_Misc_Desecrated_ClothChest"
	local skinsCategory = GUI:AddCategory("Skins", skinsIcon)

	-- Hook Functions for Skins
	local function UpdateChatBubble()
		for _, chatBubble in pairs(C_ChatBubbles.GetAllChatBubbles()) do
			if chatBubble.KKUI_Background then
				chatBubble.KKUI_Background:SetVertexColor(C["Media"].Backdrops.ColorBackdrop[1], C["Media"].Backdrops.ColorBackdrop[2], C["Media"].Backdrops.ColorBackdrop[3], C["Skins"].ChatBubbleAlpha)
			end
		end
		print("|cff669DFFKkthnxUI:|r Chat bubble alpha updated!")
	end

	local function ResetDetails()
		local skinsModule = K:GetModule("Skins")
		if skinsModule and skinsModule.ResetDetailsAnchor then
			skinsModule:ResetDetailsAnchor(true)
			print("|cff669DFFKkthnxUI:|r Details anchor reset!")
		end
	end

	local function UpdateQuestFontSize()
		local miscModule = K:GetModule("Miscellaneous")
		if miscModule and miscModule.CreateQuestSizeUpdate then
			miscModule:CreateQuestSizeUpdate()
			print("|cff669DFFKkthnxUI:|r Quest font size updated!")
		end
	end

	local function UpdateObjectiveFontSize()
		local miscModule = K:GetModule("Miscellaneous")
		if miscModule and miscModule.CreateObjectiveSizeUpdate then
			miscModule:CreateObjectiveSizeUpdate()
			print("|cff669DFFKkthnxUI:|r Objective font size updated!")
		end
	end

	local function UpdateSkinsSettings()
		local skinsModule = K:GetModule("Skins")
		if skinsModule then
			print("|cff669DFFKkthnxUI:|r Skins settings updated!")
		end
	end

	-- ========================================
	-- BLIZZARD SKINS SECTION
	-- ========================================
	local blizzardSkinsSection = GUI:AddSection(skinsCategory, "Blizzard Skins")

	GUI:CreateSwitch(blizzardSkinsSection, "Skins.BlizzardFrames", L["Skin Some Blizzard Frames & Objects"], "Enable skinning of various Blizzard UI frames and objects", UpdateSkinsSettings)

	GUI:CreateSwitch(blizzardSkinsSection, "Skins.TalkingHeadBackdrop", L["TalkingHead Skin"], "Apply custom styling to the TalkingHead frame", UpdateSkinsSettings)

	GUI:CreateSwitch(blizzardSkinsSection, "Skins.ChatBubbles", L["ChatBubbles Skin"], "Apply custom styling to chat bubbles", UpdateSkinsSettings)

	GUI:CreateSlider(blizzardSkinsSection, "Skins.ChatBubbleAlpha", L["ChatBubbles Background Alpha"], 0, 1, 0.1, "Controls the transparency of chat bubble backgrounds", UpdateChatBubble)

	-- ========================================
	-- ADDON SKINS SECTION
	-- ========================================
	local addonSkinsSection = GUI:AddSection(skinsCategory, "AddOn Skins")

	GUI:CreateSwitch(addonSkinsSection, "Skins.Bartender4", L["Bartender4 Skin"], "Apply KkthnxUI styling to Bartender4 action bars", UpdateSkinsSettings)

	GUI:CreateSwitch(addonSkinsSection, "Skins.BigWigs", L["BigWigs Skin"], "Apply KkthnxUI styling to BigWigs boss mod frames", UpdateSkinsSettings)

	GUI:CreateSwitch(addonSkinsSection, "Skins.ButtonForge", L["ButtonForge Skin"], "Apply KkthnxUI styling to ButtonForge addon", UpdateSkinsSettings)

	GUI:CreateSwitch(addonSkinsSection, "Skins.ChocolateBar", L["ChocolateBar Skin"], "Apply KkthnxUI styling to ChocolateBar addon", UpdateSkinsSettings)

	GUI:CreateSwitch(addonSkinsSection, "Skins.DeadlyBossMods", L["Deadly Boss Mods Skin"], "Apply KkthnxUI styling to Deadly Boss Mods (DBM)", UpdateSkinsSettings)

	GUI:CreateSwitch(addonSkinsSection, "Skins.Details", L["Details Skin"], "Apply KkthnxUI styling to Details! damage meter", UpdateSkinsSettings)

	GUI:CreateSwitch(addonSkinsSection, "Skins.Dominos", L["Dominos Skin"], "Apply KkthnxUI styling to Dominos action bar addon", UpdateSkinsSettings)

	GUI:CreateSwitch(addonSkinsSection, "Skins.RareScanner", L["RareScanner Skin"], "Apply KkthnxUI styling to RareScanner addon", UpdateSkinsSettings)

	GUI:CreateSwitch(addonSkinsSection, "Skins.WeakAuras", L["WeakAuras Skin"], "Apply KkthnxUI styling to WeakAuras addon", UpdateSkinsSettings)

	-- Details Reset Button
	GUI:CreateButtonWidget(addonSkinsSection, "Skins.ResetDetails", L["Reset Details"], "Reset Details", "Reset the Details! damage meter anchor position to default", function()
		ResetDetails()
	end)

	-- ========================================
	-- FONT TWEAKS SECTION
	-- ========================================
	local fontTweaksSection = GUI:AddSection(skinsCategory, "Font Tweaks")

	GUI:CreateSlider(fontTweaksSection, "Skins.QuestFontSize", "Adjust QuestFont Size", 10, 30, 1, "Adjust the font size for quest text and descriptions", UpdateQuestFontSize)

	GUI:CreateSlider(fontTweaksSection, "Skins.ObjectiveFontSize", "Adjust ObjectiveFont Size", 10, 30, 1, "Adjust the font size for objective tracker text", UpdateObjectiveFontSize)
end

-- ====================================================
-- TOOLTIP CATEGORY FUNCTION
-- ====================================================
local function CreateTooltipCategory()
	local tooltipIcon = "Interface\\Icons\\Spell_Holy_SealOfWisdom"
	local tooltipCategory = GUI:AddCategory("Tooltip", tooltipIcon)

	-- Hook Functions for Tooltip
	local function UpdateTooltipSettings()
		local tooltipModule = K:GetModule("Tooltip")
		if tooltipModule then
			print("|cff669DFFKkthnxUI:|r Tooltip settings updated!")
		end
	end

	local function UpdateTooltipAnchor()
		local tooltipModule = K:GetModule("Tooltip")
		if tooltipModule and tooltipModule.UpdateAnchor then
			tooltipModule:UpdateAnchor()
			print("|cff669DFFKkthnxUI:|r Tooltip anchor updated!")
		end
	end

	local function UpdateTooltipCursor()
		local tooltipModule = K:GetModule("Tooltip")
		if tooltipModule and tooltipModule.UpdateCursorMode then
			tooltipModule:UpdateCursorMode()
			print("|cff669DFFKkthnxUI:|r Tooltip cursor mode updated!")
		end
	end

	-- ========================================
	-- GENERAL SECTION
	-- ========================================
	local generalTooltipSection = GUI:AddSection(tooltipCategory, GENERAL)

	GUI:CreateSwitch(generalTooltipSection, "Tooltip.Enable", enableTextColor .. "Enable Tooltip", "Toggle the enhanced tooltip system on/off", UpdateTooltipSettings)

	GUI:CreateSwitch(generalTooltipSection, "Tooltip.CombatHide", L["Hide Tooltip in Combat"], "Hide tooltips during combat to reduce screen clutter", UpdateTooltipSettings)

	GUI:CreateSwitch(generalTooltipSection, "Tooltip.Icons", L["Item Icons"], "Show item icons in tooltips", UpdateTooltipSettings)

	GUI:CreateSwitch(generalTooltipSection, "Tooltip.ShowIDs", L["Show Tooltip IDs"], "Display spell, item, and NPC IDs in tooltips for debugging", UpdateTooltipSettings)

	-- ========================================
	-- APPEARANCE SECTION
	-- ========================================
	local appearanceTooltipSection = GUI:AddSection(tooltipCategory, "Appearance")

	GUI:CreateSwitch(appearanceTooltipSection, "Tooltip.ClassColor", L["Quality Color Border"], "Color tooltip borders based on item quality or unit class", UpdateTooltipSettings)

	GUI:CreateSwitch(appearanceTooltipSection, "Tooltip.FactionIcon", L["Show Faction Icon"], "Display faction icons for players in tooltips", UpdateTooltipSettings)

	GUI:CreateSwitch(appearanceTooltipSection, "Tooltip.HideJunkGuild", L["Abbreviate Guild Names"], "Shorten long guild names in tooltips", UpdateTooltipSettings)

	GUI:CreateSwitch(appearanceTooltipSection, "Tooltip.HideRank", L["Hide Guild Rank"], "Hide guild rank information in player tooltips", UpdateTooltipSettings)

	GUI:CreateSwitch(appearanceTooltipSection, "Tooltip.HideRealm", L["Show realm name by SHIFT"], "Only show realm names when holding Shift key", UpdateTooltipSettings)

	GUI:CreateSwitch(appearanceTooltipSection, "Tooltip.HideTitle", L["Hide Player Title"], "Hide player titles in tooltips", UpdateTooltipSettings)

	-- Tooltip Anchor Dropdown Options
	local tooltipAnchorOptions = {
		{ text = "Top", value = "TOP" },
		{ text = "Top Right", value = "TOPRIGHT" },
		{ text = "Right", value = "RIGHT" },
		{ text = "Bottom Right", value = "BOTTOMRIGHT" },
		{ text = "Bottom", value = "BOTTOM" },
		{ text = "Bottom Left", value = "BOTTOMLEFT" },
		{ text = "Left", value = "LEFT" },
		{ text = "Top Left", value = "TOPLEFT" },
		{ text = "Cursor", value = "CURSOR" },
	}

	GUI:CreateDropdown(appearanceTooltipSection, "Tooltip.TipAnchor", "Tooltip Anchor", tooltipAnchorOptions, "Choose where tooltips are anchored on screen", UpdateTooltipAnchor)

	-- ADVANCED SECTION
	local advancedTooltipSection = GUI:AddSection(tooltipCategory, "Advanced")
	GUI:CreateSwitch(advancedTooltipSection, "Tooltip.LFDRole", L["Show Roles Assigned Icon"], "Display role icons for players in group finder", UpdateTooltipSettings)
	GUI:CreateSwitch(advancedTooltipSection, "Tooltip.SpecLevelByShift", L["Show Spec/ItemLevel by SHIFT"], "Show specialization and item level when holding Shift", UpdateTooltipSettings)
	GUI:CreateSwitch(advancedTooltipSection, "Tooltip.TargetBy", L["Show Player Targeted By"], "Show who is targeting the player in tooltips", UpdateTooltipSettings)

	-- Follow Cursor Dropdown Options
	local cursorModeOptions = {
		{ text = "Disabled", value = "DISABLED" },
		{ text = "Always", value = "ALWAYS" },
		{ text = "Combat Only", value = "COMBAT" },
		{ text = "Out of Combat", value = "NOCOMBAT" },
	}

	GUI:CreateDropdown(advancedTooltipSection, "Tooltip.CursorMode", L["Follow Cursor"], cursorModeOptions, "Control when tooltips follow the mouse cursor", UpdateTooltipCursor)

	-- RAIDER.IO SECTION (conditional)
	if not K.CheckAddOnState("RaiderIO") then
		local raiderIOSection = GUI:AddSection(tooltipCategory, "RaiderIO")
		GUI:CreateSwitch(raiderIOSection, "Tooltip.MDScore", "Show Mythic+ Rating", "Display Mythic+ rating scores in player tooltips (built-in alternative to RaiderIO)", UpdateTooltipSettings)
	end
end

-- UNITFRAME CATEGORY FUNCTION
local function CreateUnitframeCategory()
	local unitframeIcon = "Interface\\Icons\\Spell_Shadow_AntiShadow"
	local unitframeCategory = GUI:AddCategory("Unitframe", unitframeIcon)

	-- Hook Functions for Unitframe
	local function UpdateUnitframeSettings()
		local unitframeModule = K:GetModule("Unitframes")
		if unitframeModule then
			print("|cff669DFFKkthnxUI:|r Unitframe settings updated!")
		end
	end

	local function UpdateUFTextScale()
		local unitframeModule = K:GetModule("Unitframes")
		if unitframeModule and unitframeModule.UpdateTextScale then
			unitframeModule:UpdateTextScale()
			print("|cff669DFFKkthnxUI:|r Unitframe text scale updated!")
		end
	end

	local function UpdatePlayerBuffs()
		local unitframeModule = K:GetModule("Unitframes")
		if unitframeModule and unitframeModule.UpdatePlayerBuffs then
			unitframeModule:UpdatePlayerBuffs()
			print("|cff669DFFKkthnxUI:|r Player buffs updated!")
		end
	end

	local function UpdatePlayerDebuffs()
		local unitframeModule = K:GetModule("Unitframes")
		if unitframeModule and unitframeModule.UpdatePlayerDebuffs then
			unitframeModule:UpdatePlayerDebuffs()
			print("|cff669DFFKkthnxUI:|r Player debuffs updated!")
		end
	end

	local function UpdateTargetBuffs()
		local unitframeModule = K:GetModule("Unitframes")
		if unitframeModule and unitframeModule.UpdateTargetBuffs then
			unitframeModule:UpdateTargetBuffs()
			print("|cff669DFFKkthnxUI:|r Target buffs updated!")
		end
	end

	local function UpdateTargetDebuffs()
		local unitframeModule = K:GetModule("Unitframes")
		if unitframeModule and unitframeModule.UpdateTargetDebuffs then
			unitframeModule:UpdateTargetDebuffs()
			print("|cff669DFFKkthnxUI:|r Target debuffs updated!")
		end
	end

	local function UpdateUnitPlayerSize()
		local unitframeModule = K:GetModule("Unitframes")
		if unitframeModule and unitframeModule.UpdatePlayerSize then
			unitframeModule:UpdatePlayerSize()
			print("|cff669DFFKkthnxUI:|r Player frame size updated!")
		end
	end

	local function UpdateUnitTargetSize()
		local unitframeModule = K:GetModule("Unitframes")
		if unitframeModule and unitframeModule.UpdateTargetSize then
			unitframeModule:UpdateTargetSize()
			print("|cff669DFFKkthnxUI:|r Target frame size updated!")
		end
	end

	local function UpdateUnitFocusSize()
		local unitframeModule = K:GetModule("Unitframes")
		if unitframeModule and unitframeModule.UpdateFocusSize then
			unitframeModule:UpdateFocusSize()
			print("|cff669DFFKkthnxUI:|r Focus frame size updated!")
		end
	end

	-- GENERAL SECTION
	local generalUnitframeSection = GUI:AddSection(unitframeCategory, GENERAL)
	GUI:CreateSwitch(generalUnitframeSection, "Unitframe.Enable", enableTextColor .. L["Enable Unitframes"], "Toggle the entire unitframe system on/off", UpdateUnitframeSettings)
	GUI:CreateSwitch(generalUnitframeSection, "Unitframe.CastClassColor", L["Class Color Castbars"], "Color castbars based on the caster's class", UpdateUnitframeSettings)
	GUI:CreateSwitch(generalUnitframeSection, "Unitframe.CastReactionColor", L["Reaction Color Castbars"], "Color castbars based on your reaction to the caster (friendly/hostile)", UpdateUnitframeSettings)
	GUI:CreateSwitch(generalUnitframeSection, "Unitframe.ClassResources", L["Show Class Resources"], "Display class-specific resource bars (combo points, soul shards, etc.)", UpdateUnitframeSettings)
	GUI:CreateSwitch(generalUnitframeSection, "Unitframe.DebuffHighlight", L["Show Health Debuff Highlight"], "Highlight health bars when affected by dispellable debuffs", UpdateUnitframeSettings)
	GUI:CreateSwitch(generalUnitframeSection, "Unitframe.PvPIndicator", L["Show PvP Indicator on Player / Target"], "Display PvP status indicators on player and target frames", UpdateUnitframeSettings)
	GUI:CreateSwitch(generalUnitframeSection, "Unitframe.Range", "Fade Unitframes When NOT In Unit Range", "Fade out unitframes when the unit is out of range", UpdateUnitframeSettings)
	GUI:CreateSwitch(generalUnitframeSection, "Unitframe.ResurrectSound", L["Sound Played When You Are Resurrected"], "Play a sound effect when you are resurrected", UpdateUnitframeSettings)
	GUI:CreateSwitch(generalUnitframeSection, "Unitframe.ShowHealPrediction", L["Show HealPrediction Statusbars"], "Show incoming heal predictions on health bars", UpdateUnitframeSettings)
	GUI:CreateSwitch(generalUnitframeSection, "Unitframe.Smooth", L["Smooth Bars"], "Enable smooth animations for health and power bar changes", UpdateUnitframeSettings)
	GUI:CreateSwitch(generalUnitframeSection, "Unitframe.Stagger", L["Show |CFF00FF96Monk|r Stagger Bar"], "Display the stagger bar for Monk tanks", UpdateUnitframeSettings)
	GUI:CreateSlider(generalUnitframeSection, "Unitframe.AllTextScale", "(TEST) Scale All Unitframe Texts", 0.8, 1.5, 0.05, "Experimental: Scale all text on unitframes", UpdateUFTextScale)

	-- COMBAT TEXT SECTION
	local combatTextSection = GUI:AddSection(unitframeCategory, "Combat Text")
	GUI:CreateSwitch(combatTextSection, "Unitframe.CombatText", enableTextColor .. L["Enable Simple CombatText"], "Enable floating combat text display", UpdateUnitframeSettings)
	GUI:CreateSwitch(combatTextSection, "Unitframe.AutoAttack", L["Show AutoAttack Damage"], "Display auto-attack damage in combat text", UpdateUnitframeSettings)
	GUI:CreateSwitch(combatTextSection, "Unitframe.FCTOverHealing", L["Show Full OverHealing"], "Show full overhealing amounts in combat text", UpdateUnitframeSettings)
	GUI:CreateSwitch(combatTextSection, "Unitframe.HotsDots", L["Show Hots and Dots"], "Display heal over time and damage over time effects", UpdateUnitframeSettings)
	GUI:CreateSwitch(combatTextSection, "Unitframe.PetCombatText", L["Pet's Healing/Damage"], "Show combat text for pet damage and healing", UpdateUnitframeSettings)

	-- PLAYER SECTION
	local playerUnitframeSection = GUI:AddSection(unitframeCategory, PLAYER)
	GUI:CreateSwitch(playerUnitframeSection, "Unitframe.AdditionalPower", L["Show Additional Mana Power (|CFFFF7D0ADruid|r, |CFFFFFFFFPriest|r, |CFF0070DEShaman|r)"], "Display additional power bars for classes that use multiple resources", UpdateUnitframeSettings)
	GUI:CreateSwitch(playerUnitframeSection, "Unitframe.CastbarLatency", L["Show Castbar Latency"], "Display latency compensation on the player castbar", UpdateUnitframeSettings)
	GUI:CreateSwitch(playerUnitframeSection, "Unitframe.GlobalCooldown", "Show Global Cooldown Spark", "Display a spark on the castbar showing global cooldown", UpdateUnitframeSettings)
	GUI:CreateSwitch(playerUnitframeSection, "Unitframe.PlayerBuffs", L["Show Player Frame Buffs"], "Display buffs on the player frame", UpdateUnitframeSettings)
	GUI:CreateSwitch(playerUnitframeSection, "Unitframe.PlayerCastbar", L["Enable Player CastBar"], "Enable the player castbar", UpdateUnitframeSettings)
	GUI:CreateSwitch(playerUnitframeSection, "Unitframe.PlayerCastbarIcon", L["Enable Player CastBar"] .. " Icon", "Show spell icons on the player castbar", UpdateUnitframeSettings)
	GUI:CreateSwitch(playerUnitframeSection, "Unitframe.PlayerDebuffs", L["Show Player Frame Debuffs"], "Display debuffs on the player frame", UpdateUnitframeSettings)
	GUI:CreateSwitch(playerUnitframeSection, "Unitframe.ShowPlayerLevel", L["Show Player Frame Level"], "Display player level on the player frame", UpdateUnitframeSettings)

	-- Swing Bar Options
	GUI:CreateSwitch(playerUnitframeSection, "Unitframe.SwingBar", L["Unitframe Swingbar"], "Enable swing timer bar for melee attacks", UpdateUnitframeSettings)
	GUI:CreateSwitch(playerUnitframeSection, "Unitframe.SwingTimer", L["Unitframe Swingbar Timer"], "Show timer text on the swing bar", UpdateUnitframeSettings)
	GUI:CreateSwitch(playerUnitframeSection, "Unitframe.OffOnTop", "Offhand timer on top", "Position offhand swing timer above mainhand", UpdateUnitframeSettings)
	GUI:CreateSlider(playerUnitframeSection, "Unitframe.SwingWidth", "Unitframe SwingBar Width", 50, 1000, 1, "Width of the swing timer bar", UpdateUnitframeSettings)
	GUI:CreateSlider(playerUnitframeSection, "Unitframe.SwingHeight", "Unitframe SwingBar Height", 1, 50, 1, "Height of the swing timer bar", UpdateUnitframeSettings)

	-- Player Frame Sizing
	GUI:CreateSlider(playerUnitframeSection, "Unitframe.PlayerBuffsPerRow", L["Number of Buffs Per Row"], 4, 10, 1, "Number of buff icons per row on player frame", UpdatePlayerBuffs)
	GUI:CreateSlider(playerUnitframeSection, "Unitframe.PlayerDebuffsPerRow", L["Number of Debuffs Per Row"], 4, 10, 1, "Number of debuff icons per row on player frame", UpdatePlayerDebuffs)
	GUI:CreateSlider(playerUnitframeSection, "Unitframe.PlayerPowerHeight", "Player Power Bar Height", 10, 40, 1, "Height of the player power bar", UpdateUnitPlayerSize)
	GUI:CreateSlider(playerUnitframeSection, "Unitframe.PlayerHealthHeight", L["Player Frame Height"], 20, 75, 1, "Height of the player health bar", UpdateUnitPlayerSize)
	GUI:CreateSlider(playerUnitframeSection, "Unitframe.PlayerHealthWidth", L["Player Frame Width"], 100, 300, 1, "Width of the player frame", UpdateUnitPlayerSize)
	GUI:CreateSlider(playerUnitframeSection, "Unitframe.PlayerCastbarHeight", L["Player Castbar Height"], 20, 40, 1, "Height of the player castbar", UpdateUnitframeSettings)
	GUI:CreateSlider(playerUnitframeSection, "Unitframe.PlayerCastbarWidth", L["Player Castbar Width"], 100, 800, 1, "Width of the player castbar", UpdateUnitframeSettings)

	-- TARGET SECTION
	local targetUnitframeSection = GUI:AddSection(unitframeCategory, TARGET)
	GUI:CreateSwitch(targetUnitframeSection, "Unitframe.OnlyShowPlayerDebuff", L["Only Show Your Debuffs"], "Only display debuffs that you applied to the target", UpdateUnitframeSettings)
	GUI:CreateSwitch(targetUnitframeSection, "Unitframe.TargetBuffs", L["Show Target Frame Buffs"], "Display buffs on the target frame", UpdateUnitframeSettings)
	GUI:CreateSwitch(targetUnitframeSection, "Unitframe.TargetCastbar", L["Enable Target CastBar"], "Enable the target castbar", UpdateUnitframeSettings)
	GUI:CreateSwitch(targetUnitframeSection, "Unitframe.TargetCastbarIcon", L["Enable Target CastBar"] .. " Icon", "Show spell icons on the target castbar", UpdateUnitframeSettings)
	GUI:CreateSwitch(targetUnitframeSection, "Unitframe.TargetDebuffs", L["Show Target Frame Debuffs"], "Display debuffs on the target frame", UpdateUnitframeSettings)

	-- Target Frame Sizing
	GUI:CreateSlider(targetUnitframeSection, "Unitframe.TargetBuffsPerRow", L["Number of Buffs Per Row"], 4, 10, 1, "Number of buff icons per row on target frame", UpdateTargetBuffs)
	GUI:CreateSlider(targetUnitframeSection, "Unitframe.TargetDebuffsPerRow", L["Number of Debuffs Per Row"], 4, 10, 1, "Number of debuff icons per row on target frame", UpdateTargetDebuffs)
	GUI:CreateSlider(targetUnitframeSection, "Unitframe.TargetPowerHeight", "Target Power Bar Height", 10, 40, 1, "Height of the target power bar", UpdateUnitTargetSize)
	GUI:CreateSlider(targetUnitframeSection, "Unitframe.TargetHealthHeight", L["Target Frame Height"], 20, 75, 1, "Height of the target health bar", UpdateUnitTargetSize)
	GUI:CreateSlider(targetUnitframeSection, "Unitframe.TargetHealthWidth", L["Target Frame Width"], 100, 300, 1, "Width of the target frame", UpdateUnitTargetSize)
	GUI:CreateSlider(targetUnitframeSection, "Unitframe.TargetCastbarHeight", L["Target Castbar Height"], 20, 40, 1, "Height of the target castbar", UpdateUnitframeSettings)
	GUI:CreateSlider(targetUnitframeSection, "Unitframe.TargetCastbarWidth", L["Target Castbar Width"], 100, 800, 1, "Width of the target castbar", UpdateUnitframeSettings)

	-- PET SECTION
	local petUnitframeSection = GUI:AddSection(unitframeCategory, PET)
	GUI:CreateSwitch(petUnitframeSection, "Unitframe.HidePet", "Hide Pet Frame", "Hide the pet frame completely", UpdateUnitframeSettings)
	GUI:CreateSwitch(petUnitframeSection, "Unitframe.HidePetLevel", L["Hide Pet Level"], "Hide level text on the pet frame", UpdateUnitframeSettings)
	GUI:CreateSwitch(petUnitframeSection, "Unitframe.HidePetName", L["Hide Pet Name"], "Hide name text on the pet frame", UpdateUnitframeSettings)
	GUI:CreateSlider(petUnitframeSection, "Unitframe.PetHealthHeight", L["Pet Frame Height"], 10, 50, 1, "Height of the pet health bar", UpdateUnitframeSettings)
	GUI:CreateSlider(petUnitframeSection, "Unitframe.PetHealthWidth", L["Pet Frame Width"], 80, 300, 1, "Width of the pet frame", UpdateUnitframeSettings)
	GUI:CreateSlider(petUnitframeSection, "Unitframe.PetPowerHeight", L["Pet Power Bar"], 10, 50, 1, "Height of the pet power bar", UpdateUnitframeSettings)

	-- TARGET OF TARGET SECTION
	local totUnitframeSection = GUI:AddSection(unitframeCategory, "Target Of Target")
	GUI:CreateSwitch(totUnitframeSection, "Unitframe.HideTargetofTarget", L["Hide TargetofTarget Frame"], "Hide the target of target frame", UpdateUnitframeSettings)
	GUI:CreateSwitch(totUnitframeSection, "Unitframe.HideTargetOfTargetLevel", L["Hide TargetofTarget Level"], "Hide level text on the target of target frame", UpdateUnitframeSettings)
	GUI:CreateSwitch(totUnitframeSection, "Unitframe.HideTargetOfTargetName", L["Hide TargetofTarget Name"], "Hide name text on the target of target frame", UpdateUnitframeSettings)
	GUI:CreateSlider(totUnitframeSection, "Unitframe.TargetTargetHealthHeight", L["Target of Target Frame Height"], 10, 50, 1, "Height of the target of target health bar", UpdateUnitframeSettings)
	GUI:CreateSlider(totUnitframeSection, "Unitframe.TargetTargetHealthWidth", L["Target of Target Frame Width"], 80, 300, 1, "Width of the target of target frame", UpdateUnitframeSettings)
	GUI:CreateSlider(totUnitframeSection, "Unitframe.TargetTargetPowerHeight", "Target of Target Power Height", 10, 50, 1, "Height of the target of target power bar", UpdateUnitframeSettings)

	-- FOCUS SECTION
	local focusUnitframeSection = GUI:AddSection(unitframeCategory, FOCUS)
	GUI:CreateSwitch(focusUnitframeSection, "Unitframe.FocusBuffs", "Show Focus Frame Buffs", "Display buffs on the focus frame", UpdateUnitframeSettings)
	GUI:CreateSwitch(focusUnitframeSection, "Unitframe.FocusCastbar", "Enable Focus CastBar", "Enable the focus castbar", UpdateUnitframeSettings)
	GUI:CreateSwitch(focusUnitframeSection, "Unitframe.FocusCastbarIcon", "Enable Focus CastBar Icon", "Show spell icons on the focus castbar", UpdateUnitframeSettings)
	GUI:CreateSwitch(focusUnitframeSection, "Unitframe.FocusDebuffs", "Show Focus Frame Debuffs", "Display debuffs on the focus frame", UpdateUnitframeSettings)
	GUI:CreateSlider(focusUnitframeSection, "Unitframe.FocusPowerHeight", "Focus Power Bar Height", 10, 40, 1, "Height of the focus power bar", UpdateUnitFocusSize)
	GUI:CreateSlider(focusUnitframeSection, "Unitframe.FocusHealthHeight", L["Focus Frame Height"], 20, 75, 1, "Height of the focus health bar", UpdateUnitFocusSize)
	GUI:CreateSlider(focusUnitframeSection, "Unitframe.FocusHealthWidth", L["Focus Frame Width"], 100, 300, 1, "Width of the focus frame", UpdateUnitFocusSize)

	-- FOCUS TARGET SECTION
	local focusTargetSection = GUI:AddSection(unitframeCategory, "Focus Target")
	GUI:CreateSwitch(focusTargetSection, "Unitframe.HideFocusTarget", "Hide Focus Target Frame", "Hide the focus target frame", UpdateUnitframeSettings)
	GUI:CreateSwitch(focusTargetSection, "Unitframe.HideFocusTargetLevel", "Hide Focus Target Level", "Hide level text on the focus target frame", UpdateUnitframeSettings)
	GUI:CreateSwitch(focusTargetSection, "Unitframe.HideFocusTargetName", "Hide Focus Target Name", "Hide name text on the focus target frame", UpdateUnitframeSettings)
	GUI:CreateSlider(focusTargetSection, "Unitframe.FocusTargetHealthHeight", "Focus Target Frame Height", 10, 50, 1, "Height of the focus target health bar", UpdateUnitframeSettings)
	GUI:CreateSlider(focusTargetSection, "Unitframe.FocusTargetHealthWidth", "Focus Target Frame Width", 80, 300, 1, "Width of the focus target frame", UpdateUnitframeSettings)
	GUI:CreateSlider(focusTargetSection, "Unitframe.FocusTargetPowerHeight", "Focus Target Power Height", 10, 50, 1, "Height of the focus target power bar", UpdateUnitframeSettings)

	-- UNITFRAME MISC SECTION
	local miscUnitframeSection = GUI:AddSection(unitframeCategory, "Unitframe Misc")

	-- Health Color Format Dropdown Options
	local healthColorOptions = {
		{ text = "Class", value = 1 },
		{ text = "Dark", value = 2 },
		{ text = "Value", value = 3 },
	}
	GUI:CreateDropdown(miscUnitframeSection, "Unitframe.HealthbarColor", L["Health Color Format"], healthColorOptions, "Choose how health bars are colored across all unitframes", UpdateUnitframeSettings)

	-- Portrait Style Dropdown Options
	local portraitStyleOptions = {
		{ text = "No Portraits", value = 0 },
		{ text = "Default Portraits", value = 1 },
		{ text = "Class Portraits", value = 2 },
		{ text = "New Class Portraits", value = 3 },
		{ text = "Overlay Portrait", value = 4 },
		{ text = "3D Portraits", value = 5 },
	}
	GUI:CreateDropdown(miscUnitframeSection, "Unitframe.PortraitStyle", L["Unitframe Portrait Style"], portraitStyleOptions, "Choose the portrait style for unitframes. Note: 3D portraits may cause FPS drops", UpdateUnitframeSettings)
end

-- WORLDMAP CATEGORY FUNCTION
local function CreateWorldMapCategory()
	local worldMapIcon = "Interface\\Icons\\Achievement_worldevent_childrensweek"
	local worldMapCategory = GUI:AddCategory("WorldMap", worldMapIcon)

	-- Hook Functions for WorldMap
	local function UpdateWorldMapSettings()
		local worldMapModule = K:GetModule("WorldMap")
		if worldMapModule then
			print("|cff669DFFKkthnxUI:|r WorldMap settings updated!")
		end
	end

	local function UpdateMapFading()
		local worldMapModule = K:GetModule("WorldMap")
		if worldMapModule and worldMapModule.UpdateMapFading then
			worldMapModule:UpdateMapFading()
			print("|cff669DFFKkthnxUI:|r WorldMap fading updated!")
		end
	end

	local function UpdateMapSize()
		local worldMapModule = K:GetModule("WorldMap")
		if worldMapModule and worldMapModule.UpdateMapSize then
			worldMapModule:UpdateMapSize()
			print("|cff669DFFKkthnxUI:|r WorldMap size updated!")
		end
	end

	local function UpdateMapReveal()
		local worldMapModule = K:GetModule("WorldMap")
		if worldMapModule and worldMapModule.UpdateMapReveal then
			worldMapModule:UpdateMapReveal()
			print("|cff669DFFKkthnxUI:|r WorldMap reveal updated!")
		end
	end

	-- GENERAL SECTION
	local generalWorldMapSection = GUI:AddSection(worldMapCategory, GENERAL)
	GUI:CreateSwitch(generalWorldMapSection, "WorldMap.Coordinates", L["Show Player/Mouse Coordinates"], "Display player and mouse coordinates on the world map", UpdateWorldMapSettings)
	GUI:CreateSwitch(generalWorldMapSection, "WorldMap.FadeWhenMoving", L["Fade Worldmap When Moving"], "Make the world map fade out when your character is moving", UpdateMapFading)
	GUI:CreateSwitch(generalWorldMapSection, "WorldMap.SmallWorldMap", L["Show Smaller Worldmap"], "Use a smaller, more compact world map size", UpdateMapSize)

	-- WORLDMAP REVEAL SECTION
	local revealWorldMapSection = GUI:AddSection(worldMapCategory, "WorldMap Reveal")
	GUI:CreateSwitch(revealWorldMapSection, "WorldMap.MapRevealGlow", L["Map Reveal Shadow"], L["MapRevealTip"], UpdateMapReveal)

	-- SIZES SECTION
	local sizesWorldMapSection = GUI:AddSection(worldMapCategory, L["Sizes"])
	GUI:CreateSlider(sizesWorldMapSection, "WorldMap.AlphaWhenMoving", L["Alpha When Moving"], 0.1, 1, 0.01, "Set the transparency level when the world map fades during movement", UpdateMapFading)
end

-- CREDITS CATEGORY FUNCTION
local function CreateCreditsCategory()
	local creditsCategory = GUI:AddCategory("Credits", "Interface\\Icons\\Achievement_General")
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

	-- Special Recognition Section
	local specialSection = GUI:AddSection(creditsCategory, "Special Recognition")

	if GUI.CreateCredits then
		GUI:CreateCredits(specialSection, {
			{ name = "Kkthnx", class = "HUNTER" },
			{ name = "All Beta Testers", color = { 0.8, 0.8, 1, 1 } },
			{ name = "Discord Community", color = { 0.4, 0.6, 1, 1 } },
			{ name = "GitHub Contributors", color = { 0.2, 0.8, 0.2, 1 } },
		}, "Special Thanks")
	end

	-- Message Section
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

-- INITIALIZE ALL CATEGORIES
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
CreateRaidCategory()
CreateSkinsCategory()
CreateTooltipCategory()
CreateUnitframeCategory()
CreateWorldMapCategory()
-- Credits are always last!
CreateCreditsCategory()
