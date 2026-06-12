--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Displays achievement status in tooltip (Enhanced Achievements by Syzgyn)
-- - Design: Hooks tooltip SetHyperlink
-- - Events: None
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Tooltip")

-- REASON: Localize globals for performance and stack safety.
local _G = _G
local string_match = _G.string.match
local string_format = _G.string.format
local hooksecurefunc = _G.hooksecurefunc

local GetAchievementInfo = _G.GetAchievementInfo
local UnitGUID = _G.UnitGUID
local ACHIEVEMENT_EARNED_BY = _G.ACHIEVEMENT_EARNED_BY
local ACHIEVEMENT_NOT_COMPLETED_BY = _G.ACHIEVEMENT_NOT_COMPLETED_BY
local ACHIEVEMENT_COMPLETED_BY = _G.ACHIEVEMENT_COMPLETED_BY
local GameTooltip = _G.GameTooltip
local ItemRefTooltip = _G.ItemRefTooltip

-- REASON: Helper function to inject achievement earned status into tooltip.
local function SetHyperlink(tooltip, refString)
	local linkType = string_match(refString, "^(%a+):")
	if linkType ~= "achievement" then
		return
	end

	local achievementID = string_match(refString, ":(%d+):")
	local GUID = string_match(refString, ":%d+:(.-):")

	if GUID == UnitGUID("player") then
		tooltip:Show()
		return
	end

	tooltip:AddLine(" ")
	local _, _, _, completed, _, _, _, _, _, _, _, _, wasEarnedByMe, earnedBy = GetAchievementInfo(achievementID)

	if completed then
		if earnedBy and earnedBy ~= "" then
			tooltip:AddLine(string_format(ACHIEVEMENT_EARNED_BY, earnedBy))
		end

		if not wasEarnedByMe then
			tooltip:AddLine(string_format(ACHIEVEMENT_NOT_COMPLETED_BY, K.Name))
		elseif K.Name ~= earnedBy then
			tooltip:AddLine(string_format(ACHIEVEMENT_COMPLETED_BY, K.Name))
		end
	end

	tooltip:Show()
end

-- REASON: Initializes the achievement tooltip hooking.
function Module:CreateAchievementStatus()
	if not C["Tooltip"].Achievements then
		return
	end

	hooksecurefunc(GameTooltip, "SetHyperlink", SetHyperlink)
	hooksecurefunc(ItemRefTooltip, "SetHyperlink", SetHyperlink)
end
