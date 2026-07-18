local K = KkthnxUI[1]
K.GUIBuilder = K.GUIBuilder or {}
local B = K.GUIBuilder

function B.CreateMiscCategory()
	if not B or not B.Ready() then
		return
	end
	local K, GUI, C, L, enableTextColor = B.K, B.GUI, B.C, B.L, B.enableTextColor

	local miscIcon = "Interface\\Icons\\INV_Misc_Bag_10"
	local miscCategory = GUI:AddCategory(L["Misc"], miscIcon, "Misc")

	-- UI Enhancements (+ former TradeSkill / Social / Mail micro-sections)
	local uiEnhanceSection = GUI:AddSection(miscCategory, L["GUI.Section.UIEnhancements"])
	GUI:CreateSwitch(uiEnhanceSection, "Misc.ColorPicker", L["Enhanced Color Picker"], L["Misc.ColorPicker Desc"])
	GUI:CreateSwitch(uiEnhanceSection, "Misc.QuickDelete", L["Quick Item Delete"], L["Misc.QuickDelete Desc"])
	GUI:CreateSwitch(uiEnhanceSection, "Misc.PopupQoL", L["Popup QoL"], L["Misc.PopupQoL Desc"])
	local popupToasts = GUI:CreateSwitch(uiEnhanceSection, "Misc.PopupClickThroughToasts", L["Click-Through Event Toasts"], L["Misc.PopupClickThroughToasts Desc"])
	local popupLoot = GUI:CreateSwitch(uiEnhanceSection, "Misc.PopupAutoConfirmLoot", L["Auto-Confirm BoP Loot"], L["Misc.PopupAutoConfirmLoot Desc"])
	local popupEquip = GUI:CreateSwitch(uiEnhanceSection, "Misc.PopupAutoConfirmTradeableEquip", L["Auto-Confirm Tradeable Equip"], L["Misc.PopupAutoConfirmTradeableEquip Desc"])
	local popupSell = GUI:CreateSwitch(uiEnhanceSection, "Misc.PopupAutoConfirmTradeableSell", L["Auto-Confirm Tradeable Sell"], L["Misc.PopupAutoConfirmTradeableSell Desc"])
	local popupPurchase = GUI:CreateSwitch(uiEnhanceSection, "Misc.PopupEnterAcceptPurchase", L["Enter Accepts Purchases"], L["Misc.PopupEnterAcceptPurchase Desc"])
	local popupStack = GUI:CreateSwitch(uiEnhanceSection, "Misc.PopupAltStackBuy", L["Alt+Right-Click Stack Buy"], L["Misc.PopupAltStackBuy Desc"])
	GUI:DependsOn(popupToasts, "Misc.PopupQoL", true)
	GUI:DependsOn(popupLoot, "Misc.PopupQoL", true)
	GUI:DependsOn(popupEquip, "Misc.PopupQoL", true)
	GUI:DependsOn(popupSell, "Misc.PopupQoL", true)
	GUI:DependsOn(popupPurchase, "Misc.PopupQoL", true)
	GUI:DependsOn(popupStack, "Misc.PopupQoL", true)
	GUI:CreateSwitch(uiEnhanceSection, "Misc.QuickMenuList", L["Enhanced Unit Popup Menus"], L["Misc.QuickMenuList Desc"])
	GUI:CreateSwitch(uiEnhanceSection, "Misc.YClassColors", L["Enable ClassColors"], L["Misc.YClassColors Desc"])
	GUI:CreateSwitch(uiEnhanceSection, "Misc.TradeTabs", L["Add Spellbook-Like Tabs On TradeSkillFrame"], L["Misc.TradeTabs Desc"])
	GUI:CreateSwitch(uiEnhanceSection, "Misc.QuickJoin", L["QuickJoin"], L["QuickJoinTip"])
	GUI:CreateSwitch(uiEnhanceSection, "Misc.EnhancedMail", L["Enhanced Mail Features"], L["Misc.EnhancedMail Desc"])
	GUI:CreateSwitch(uiEnhanceSection, "Misc.AutoBubbles", L["Auto Bubbles"], L["Misc.AutoBubbles Desc"])
	GUI:CreateSwitch(uiEnhanceSection, "Misc.HeroTalentSwap", L["Hero Talent Swap"], L["Misc.HeroTalentSwap Desc"])
	GUI:CreateSwitch(uiEnhanceSection, "Misc.AchievementBackButton", L["Achievement Back Button"], L["Misc.AchievementBackButton Desc"])

	-- Target Marking
	local markingSection = GUI:AddSection(miscCategory, L["GUI.Section.TargetMarking"])
	GUI:CreateSwitch(markingSection, "Misc.EasyMarking", L["EasyMarking by Ctrl + LeftClick"], L["Misc.EasyMarking Desc"])
	local easyMarkKeyOptions = {
		{ text = "CTRL_KEY", value = 1 },
		{ text = "ALT_KEY", value = 2 },
		{ text = "SHIFT_KEY", value = 3 },
		{ text = DISABLE, value = 4 },
	}
	local easyMarkKey = GUI:CreateDropdown(markingSection, "Misc.EasyMarkKey", L["EasyMarking Key Modifier"], easyMarkKeyOptions, L["Misc.EasyMarkKey Desc"])
	GUI:DependsOn(easyMarkKey, "Misc.EasyMarking", true)

	-- Encounter UI
	local encounterSection = GUI:AddSection(miscCategory, L["GUI.Section.EncounterUI"])
	GUI:CreateSwitch(encounterSection, "Misc.HideBanner", L["Hide RaidBoss EmoteFrame"], L["Misc.HideBanner Desc"])
	GUI:CreateSwitch(encounterSection, "Misc.HideBossEmote", L["Hide BossBanner"], L["Misc.HideBossEmote Desc"])

	-- Camera
	local cameraSection = GUI:AddSection(miscCategory, L["GUI.Section.Camera"])
	GUI:CreateSlider(cameraSection, "Misc.MaxCameraZoom", L["Max Camera Zoom Level"], 1, 2.6, 0.1, L["Misc.MaxCameraZoom Desc"])
	GUI:CreateSwitch(cameraSection, "Misc.AFKCamera", L["AFK Camera"], L["Misc.AFKCamera Desc"])

	-- Audio
	local audioSection = GUI:AddSection(miscCategory, L["GUI.Section.Audio"])
	GUI:CreateSwitch(audioSection, "Misc.MuteSounds", L["Mute Annoying Sounds"], L["Misc.MuteSounds Desc"])
	GUI:CreateSwitch(audioSection, "Misc.AudioSync", L["Audio Sync"], L["Misc.AudioSync Desc"])
	GUI:CreateButtonWidget(audioSection, "Misc.ManageMuteSoundIDs", L["Custom Mute Sound IDs"], L["Open GUI"], L["Misc.ManageMuteSoundIDs Desc"], function()
		if K.ExtraGUI and K.ExtraGUI.ToggleExtraConfig then
			K.ExtraGUI:ToggleExtraConfig("Misc.MuteSoundIDs", L["Custom Mute Sound IDs"])
		end
	end)

	-- Questing, Dialog & Objective Tracker
	local questingSection = GUI:AddSection(miscCategory, L["GUI.Section.QuestingDialog"])
	GUI:CreateSwitch(questingSection, "Misc.ExpRep", L["Display Exp/Rep Bar"], L["Misc.ExpRep Desc"])
	GUI:CreateSwitch(questingSection, "Misc.QuestTool", L["Quest Tips"], L["Misc.QuestTool Desc"])
	GUI:CreateSwitch(questingSection, "Misc.ShowWowHeadLinks", L["Show Wowhead Links Above Questlog Frame"], L["Misc.ShowWowHeadLinks Desc"])
	GUI:CreateSwitch(questingSection, "Misc.NoTalkingHead", L["Remove And Hide The TalkingHead Frame"], L["Misc.NoTalkingHead Desc"])
	GUI:CreateSwitch(questingSection, "Misc.ObjectiveTracker.AutoHide", L["Auto Hide Objective Tracker"], L["Misc.ObjectiveTracker.AutoHide Desc"])
	local trackerMplus = GUI:CreateSwitch(questingSection, "Misc.ObjectiveTracker.AutoHideInKeystone", L["Hide Tracker in Mythic+"], L["Misc.ObjectiveTracker.AutoHideInKeystone Desc"])
	GUI:DependsOn(trackerMplus, "Misc.ObjectiveTracker.AutoHide", true)

	-- Raid Tool (+ Mythic+)
	local raidToolSection = GUI:AddSection(miscCategory, L["GUI.Section.RaidTool"])
	GUI:CreateSwitch(raidToolSection, "Misc.RaidTool", L["Show Raid Utility Frame"], L["Misc.RaidTool Desc"])
	GUI:CreateSwitch(raidToolSection, "Misc.RMRune", L["Flask / Rune Check"], L["Misc.RMRune Desc"])
	GUI:CreateButtonWidget(raidToolSection, "Misc.ManageDBMCount", L["Pull Timer Seconds"], L["Open GUI"], L["Misc.DBMCount Desc"], function()
		if K.ExtraGUI and K.ExtraGUI.ToggleExtraConfig then
			K.ExtraGUI:ToggleExtraConfig("Misc.DBMCount", L["Pull Timer Seconds"])
		end
	end)
	local markerBarOptions = {
		{ text = "Grids", value = 1 },
		{ text = "Horizontal", value = 2 },
		{ text = "Vertical", value = 3 },
		{ text = DISABLE, value = 4 },
	}
	GUI:CreateDropdown(raidToolSection, "Misc.ShowMarkerBar", L["World Markers Bar"], markerBarOptions, L["Misc.ShowMarkerBar Desc"])
	local markerBarSize = GUI:CreateSlider(raidToolSection, "Misc.MarkerBarSize", L["Marker Bar Size"], 20, 40, 1, L["Misc.MarkerBarSize Desc"])
	GUI:DependsOn(markerBarSize, "Misc.ShowMarkerBar", 4, function(v)
		return v ~= 4
	end)
	GUI:CreateSwitch(raidToolSection, "Misc.MDGuildBest", L["Show Mythic+ GuildBest"], L["Misc.MDGuildBest Desc"])

	-- Character & Inspect
	local characterSection = GUI:AddSection(miscCategory, L["GUI.Section.CharacterInspect"])
	GUI:CreateSwitch(characterSection, "Misc.ItemLevel", L["Show Character/Inspect ItemLevel Info"], L["Misc.ItemLevel Desc"])
	local gemEnchant = GUI:CreateSwitch(characterSection, "Misc.GemEnchantInfo", L["Character/Inspect Gem/Enchant Info"], L["Misc.GemEnchantInfo Desc"])
	local missingEnchant = GUI:CreateSwitch(characterSection, "Misc.MissingEnchant", L["Warn Missing Enchants"], L["Misc.MissingEnchant Desc"])
	GUI:CreateSwitch(characterSection, "Misc.ImprovedStats", L["Display Character Frame Full Stats"], L["Misc.ImprovedStats Desc"])
	GUI:CreateSwitch(characterSection, "Misc.SlotDurability", L["Show Slot Durability %"], L["Misc.SlotDurability Desc"])
	GUI:DependsOn(gemEnchant, "Misc.ItemLevel", true)
	GUI:DependsOn(missingEnchant, "Misc.ItemLevel", true)

	-- Queue Timer
	local queueTimerSection = GUI:AddSection(miscCategory, L["GUI.Section.QueueTimer"])
	GUI:CreateSwitch(queueTimerSection, "Misc.QueueTimers", L["Queue Timer"], L["Misc.QueueTimers Desc"])
	local queueAudio = GUI:CreateSwitch(queueTimerSection, "Misc.QueueTimerAudio", L["Queue Timer Audio"], L["Misc.QueueTimerAudio Desc"])
	local queueWarn = GUI:CreateSwitch(queueTimerSection, "Misc.QueueTimerWarning", L["Queue Timer Warning"], L["Misc.QueueTimerWarning Desc"])
	local queueHide = GUI:CreateSwitch(queueTimerSection, "Misc.QueueTimerHideOtherTimers", L["Hide Other Queue Timers"], L["Misc.QueueTimerHideOtherTimers Desc"])
	GUI:DependsOn(queueAudio, "Misc.QueueTimers", true)
	GUI:DependsOn(queueWarn, "Misc.QueueTimers", true)
	GUI:DependsOn(queueHide, "Misc.QueueTimers", true)
end
