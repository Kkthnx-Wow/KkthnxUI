--[[-----------------------------------------------------------------------------
-- Live GUI refresh for misc module settings.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Miscellaneous")

local REFRESH_BY_KEY = {
	HideBanner = "UpdateBossBanner",
	HideBossEmote = "UpdateBossEmote",
	AutoBubbles = "UpdateAutoBubbles",
	ExpRep = "UpdateExpRepBar",
	ExpRepShowRested = "UpdateExpRepBar",
	ExpRepFade = "UpdateExpRepBar",
	ExpRepFadeOpacity = "UpdateExpRepBar",
	ExpRepFadeCombat = "UpdateExpRepBar",
	ExpRepFadeTarget = "UpdateExpRepBar",
	MuteSounds = "UpdateMuteSounds",
	MuteSoundIDs = "UpdateMuteSounds",
	EnhancedMail = "CreateImprovedMail",
	QuestTool = "CreateQuestTool",
	QuickJoin = "CreateQuickJoin",
	MDGuildBest = "CreateGuildBest",
	QueueTimers = "CreateQueueTimers",
	-- Audio / warning / hide-bars read C live inside QueueTimer; enable owns lifecycle.
	RaidTool = "UpdateRaidTool",
	EasyMarking = "UpdateEasyMarking",
	EasyMarkKey = "UpdateEasyMarking",
	ItemLevel = "createImprovedSlotItemLevelDisplay",
	GemEnchantInfo = "RefreshGearItemLevelOverlays",
	MissingEnchant = "RefreshGearItemLevelOverlays",
	TradeTabs = "createImprovedTradeTabs",
	AFKCamera = "CreateAFKCam",
	ImprovedStats = "createImprovedStatFrames",
	PopupQoL = "UpdatePopupQoL",
	PopupClickThroughToasts = "UpdatePopupQoL",
	PopupAutoConfirmLoot = "UpdatePopupQoL",
	PopupAutoConfirmTradeableEquip = "UpdatePopupQoL",
	PopupAutoConfirmTradeableSell = "UpdatePopupQoL",
	PopupEnterAcceptPurchase = "UpdatePopupQoL",
	PopupAltStackBuy = "UpdatePopupQoL",
	HeroTalentSwap = "CreateHeroTalentSwap",
	AudioSync = "CreateAudioSync",
	AchievementBackButton = "CreateAchievementBackButton",
}

local function OnMiscSetting(configPath)
	local key = configPath:match("^Misc%.(.+)$")
	if not key then
		return
	end

	if key == "YClassColors" then
		Module:UpdateYClassColors()
	elseif key == "ColorPicker" then
		local blizzard = K:GetModule("Blizzard")
		if blizzard.UpdateColorPicker then
			blizzard:UpdateColorPicker()
		end
	elseif key == "MaxCameraZoom" then
		Module:UpdateMaxCameraZoom()
	elseif key == "NoTalkingHead" then
		local blizzard = K:GetModule("Blizzard")
		if blizzard.UpdateNoTalkingHead then
			blizzard:UpdateNoTalkingHead()
		end
	elseif key == "ShowWowHeadLinks" then
		local worldMap = K:GetModule("WorldMap")
		if worldMap.CreateWowHeadLinks then
			worldMap:CreateWowHeadLinks()
		end
	elseif key == "SlotDurability" then
		local dataText = K:GetModule("DataText")
		if dataText and dataText.RefreshDataTextPanel then
			dataText:CreateDurabilityDataText()
		end
	elseif key == "ShowMarkerBar" or key == "MarkerBarSize" then
		if Module.updateWorldMarkerGrid then
			Module:updateWorldMarkerGrid()
		end
	elseif key == "QuickDelete" then
		Module:UpdateQuickDelete()
	elseif key == "QuickMenuList" then
		Module:CreateQuickMenuList()
	elseif key:sub(1, 17) == "ObjectiveTracker." then
		local automation = K:GetModule("Automation")
		if automation and automation.ObjectiveTracker_AutoHide then
			automation:ObjectiveTracker_AutoHide()
		end
	else
		local method = REFRESH_BY_KEY[key]
		if method and Module[method] then
			Module[method](Module)
		end
	end
end

K:RegisterSettingPrefixCallback("Misc.", OnMiscSetting)
