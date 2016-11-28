local K, C, L = select(2, ...):unpack()
if C.Tooltip.Enable ~= true or C.Tooltip.Achievements ~= true then return end

-- LUA API
local select = select
local format = string.format
local find = string.find

-- WOW API
local hooksecurefunc = hooksecurefunc
local GetAchievementNumCriteria = GetAchievementNumCriteria
local ACHIEVEMENT_EARNED_BY = ACHIEVEMENT_EARNED_BY
local ACHIEVEMENT_NOT_COMPLETED_BY = ACHIEVEMENT_NOT_COMPLETED_BY
local ACHIEVEMENT_COMPLETED_BY = ACHIEVEMENT_COMPLETED_BY

-- YOUR ACHIEVEMENT STATUS IN TOOLTIP(ENHANCED ACHIEVEMENTS BY SYZGYN)
local colors = {
	["GREEN"] = {
		["r"] = 0.25,
		["g"] = 0.75,
		["b"] = 0.25,
	},
	["GRAY"] = {
		["r"] = 0.5,
		["g"] = 0.5,
		["b"] = 0.5,
	},
}

local function SetHyperlink(tooltip, refString)
	local output = {[0] = {}, [1] = {}}
	if select(3, find(refString, "(%a-):")) ~= "achievement" then return end

	local _, _, achievementID = find(refString, ":(%d+):")
	local numCriteria = GetAchievementNumCriteria(achievementID)
	local _, _, GUID = find(refString, ":%d+:(.-):")

	if GUID == UnitGUID("player") then
		tooltip:Show()
		return
	end

	tooltip:AddLine(" ")
	local _, _, _, completed, month, day, year, _, _, _, _, _, wasEarnedByMe, earnedBy = GetAchievementInfo(achievementID)

	if completed then
		if year < 10 then year = "0"..year end

		if K.Client == "ruRU" then
			tooltip:AddLine(L.Tooltip.AchievementComplete..day.."/"..month.."/"..year, 0, 1, 0)
		else
			tooltip:AddLine(L.Tooltip.AchievementComplete..month.."/"..day.."/"..year, 0, 1, 0)
		end

		if earnedBy then
			if earnedBy ~= "" then
				tooltip:AddLine(format(ACHIEVEMENT_EARNED_BY, earnedBy))
			end
			if not wasEarnedByMe then
				tooltip:AddLine(format(ACHIEVEMENT_NOT_COMPLETED_BY, K.Name))
			elseif K.Name ~= earnedBy then
				tooltip:AddLine(format(ACHIEVEMENT_COMPLETED_BY, K.Name))
			end
		end
	elseif numCriteria == 0 then
		tooltip:AddLine(L.Tooltip.AchievementIncomplete)
	else
		tooltip:AddLine(L.Tooltip.AchievementStatus)
		for i = 1, numCriteria, 2 do
			for a = 0, 1 do
				output[a].text = nil
				output[a].color = nil
				if i + a <= numCriteria then
					local name, _, completed, quantity, reqQuantity = GetAchievementCriteriaInfo(achievementID, i + a)
					if completed then
						output[a].text = name
						output[a].color = "GREEN"
					else
						if quantity < reqQuantity and reqQuantity > 1 then
							output[a].text = name.." ("..quantity.."/"..reqQuantity..")"
							output[a].color = "GRAY"
						else
							output[a].text = name
							output[a].color = "GRAY"
						end
					end
				else
					output[a].text = nil
				end
			end
			if output[1].text == nil then
				tooltip:AddLine(output[0].text, colors[output[0].color].r, colors[output[0].color].g, colors[output[0].color].b)
			else
				tooltip:AddDoubleLine(output[0].text, output[1].text, colors[output[0].color].r, colors[output[0].color].g, colors[output[0].color].b, colors[output[1].color].r, colors[output[1].color].g, colors[output[1].color].b)
			end
			output = {[0] = {}, [1] = {}}
		end
	end
	tooltip:Show()
end

hooksecurefunc(GameTooltip, "SetHyperlink", SetHyperlink)
hooksecurefunc(ItemRefTooltip, "SetHyperlink", SetHyperlink)