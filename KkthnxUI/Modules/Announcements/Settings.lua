--[[-----------------------------------------------------------------------------
-- Live GUI refresh for announcement toggles.
-----------------------------------------------------------------------------]]

local K = KkthnxUI[1]
local Module = K:GetModule("Announcements")

local REFRESH_BY_KEY = {
	ItemAlert = "CreateItemAnnounce",
	ResetInstance = "CreateResetInstance",
	RareAlert = "CreateRareAnnounce",
	QuestNotifier = "CreateQuestNotifier",
	KeystoneAlert = "CreateKeystoneAnnounce",
	PullCountdown = "CreatePullCountdown",
	AlertInChat = "CreateRareAnnounce",
	AlertOnlyInWorld = "CreateRareAnnounce",
}

local RARE_ALERT_PREFIX = "RareAlert"
local QUEST_PREFIX = "Quest"

local function OnAnnouncementsSetting(configPath)
	local key = configPath:match("^Announcements%.(.+)$")
	if not key then
		return
	end

	if key:sub(1, #RARE_ALERT_PREFIX) == RARE_ALERT_PREFIX and Module.CreateRareAnnounce then
		Module:CreateRareAnnounce()
		return
	end

	if (key:sub(1, #QUEST_PREFIX) == QUEST_PREFIX or key == "OnlyCompleteRing" or key == "AnnounceWorldQuests" or key == "QuestProgressEveryNth")
		and Module.CreateQuestNotifier then
		Module:CreateQuestNotifier()
		return
	end

	local method = REFRESH_BY_KEY[key]
	if method and Module[method] then
		Module[method](Module)
	end
end

K:RegisterSettingPrefixCallback("Announcements.", OnAnnouncementsSetting)
