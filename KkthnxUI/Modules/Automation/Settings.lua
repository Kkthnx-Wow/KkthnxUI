--[[-----------------------------------------------------------------------------
-- Live GUI refresh for automation toggles (event registration).
-----------------------------------------------------------------------------]]

local K = KkthnxUI[1]
local Module = K:GetModule("Automation")

local REFRESH_BY_KEY = {
	AutoInvite = "CreateAutoInvite",
	AutoDeclineGuildInvites = "CreateAutoDeclineGuildInvites",
	AutoDeclineDuels = "CreateAutoDeclineDuels",
	AutoDeclinePetDuels = "CreateAutoDeclineDuels",
	AutoPartySync = "CreateAutoPartySyncAccept",
	AutoResurrect = "CreateAutoResurrect",
	AutoReward = "CreateAutoBestReward",
	AutoDelves = "CreateAutoDelves",
	HolidayDungeon = "CreateHolidayDungeon",
	AuctionSearchFallback = "CreateAuctionSearchFallback",
	AuctionSearchHistory = "CreateAuctionSearchHistory",
	AuctionSearchHistoryMax = "CreateAuctionSearchHistory",
	AutoGoodbye = "CreateAutoGoodbye",
	AutoKeystone = "CreateAutoKeystone",
	AutoRelease = "CreateAutoRelease",
	AutoScreenshot = "CreateAutoScreenshot",
	AutoSetRole = "CreateAutoSetRole",
	ConfirmCinematicSkip = "CreateSkipCinematic",
	AutoSummon = "CreateAutoAcceptSummon",
	NoBadBuffs = "CreateAutoBadBuffs",
	SmartTracking = "CreateSmartTracking",
	SmartFishing = "CreateSmartFishing",
}

local AUTO_QUEST_KEYS = {
	AutoQuestAcceptRegular = true,
	AutoQuestAcceptDaily = true,
	AutoQuestAcceptWeekly = true,
	AutoQuestProtectTurnIns = true,
}

local function OnAutomationSetting(configPath)
	local key = configPath:match("^Automation%.(.+)$")
	if not key then
		return
	end

	if AUTO_QUEST_KEYS[key] and Module.SyncAutoQuestEvents then
		Module:SyncAutoQuestEvents()
		return
	end

	local method = REFRESH_BY_KEY[key]
	if method and Module[method] then
		Module[method](Module)
	end
end

K:RegisterSettingPrefixCallback("Automation.", OnAutomationSetting)
