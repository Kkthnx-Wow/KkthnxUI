local _, C, L = unpack(select(2, ...))
if C["Quests"].WoWheadLink ~= true then return end
-- local Module = K:NewModule("WoWHeadLink", "AceEvent-3.0") -- We will convert this to handle with ACE3 later.

-- Add quest/achievement wowhead link
local subDomain = (setmetatable({
    ruRU = "ru",
    frFR = "fr", deDE = "de",
    esES = "es", esMX = "es",
    ptBR = "pt", ptPT = "pt", itIT = "it",
    koKR = "ko", zhTW = "cn", zhCN = "cn"
}, { __index = function(t,v) return "www" end }))[GetLocale()]

local linkQuest = "http://"..subDomain..".wowhead.com/quest=%d"
local linkAchievement = "http://"..subDomain..".wowhead.com/achievement=%d"

hooksecurefunc("QuestObjectiveTracker_OnOpenDropDown", function(self, level)
	local _, b, i, info, questID
	b = self.activeFrame
	questID = b.id

	if (level == 1) then
		info = L_UIDropDownMenu_CreateInfo()
		info.text = "WoWHead Link"
		info.func = function(id)
			local inputBox = StaticPopup_Show("WATCHFRAME_URL")
			inputBox.editBox:SetText(linkQuest:format(questID))
			inputBox.editBox:HighlightText()
		end
		info.arg1 = questID
		info.notCheckable = true
		UIDropDownMenu_AddButton(info, level)
	end
end)

hooksecurefunc("AchievementObjectiveTracker_OnOpenDropDown", function(self, level)
	local _, b, i, info
	b = self.activeFrame
	i = b.id

	if (level == 1) then
		info = L_UIDropDownMenu_CreateInfo()
		info.text = "WoWHead Link"
		info.func = function(_, i)
			local inputBox = StaticPopup_Show("WATCHFRAME_URL")
			inputBox.editBox:SetText(linkAchievement:format(i))
			inputBox.editBox:HighlightText()
		end
		info.arg1 = i
		info.notCheckable = true
		UIDropDownMenu_AddButton(info, level)
	end
end)

hooksecurefunc("BonusObjectiveTracker_OnOpenDropDown", function(self, level)
	local block = self.activeFrame
	local questID = block.TrackedQuest.questID

	if (level == 1) then
		info = L_UIDropDownMenu_CreateInfo()
		info.text = "WoWHead Link"
		info.func = function()
			local inputBox = StaticPopup_Show("WATCHFRAME_URL")
			inputBox.editBox:SetText(linkQuest:format(questID))
			inputBox.editBox:HighlightText()
		end
		info.arg1 = questID
		info.notCheckable = true
		UIDropDownMenu_AddButton(info, level)
	end
end)

local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, event, addon)
	if addon == "Blizzard_AchievementUI" then
		hooksecurefunc("AchievementButton_OnClick", function(self)
			if self.id and IsControlKeyDown() then
				local inputBox = StaticPopup_Show("WATCHFRAME_URL")
				inputBox.editBox:SetText(linkAchievement:format(self.id))
				inputBox.editBox:HighlightText()
			end
		end)
	end
end)