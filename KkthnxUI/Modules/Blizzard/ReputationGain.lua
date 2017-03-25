local K, C, L = unpack(select(2, ...))
if C.Blizzard.ReputationGain ~= true then return end

local _G = _G
local string_format = string.format

local GetNumFactions = _G.GetNumFactions
local GetFactionInfo = _G.GetFactionInfo
local DEFAULT_CHAT_FRAME = _G.DEFAULT_CHAT_FRAME

local reps = {}

local ReputationGain = CreateFrame("Frame")
ReputationGain:RegisterEvent("UPDATE_FACTION")
ReputationGain:SetScript("OnEvent", function()
	local name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader,
	isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canBeLFGBonus, _
	local difference
	for factionIndex = 1, GetNumFactions() do
		name, description, standingID, barMin, barMax, barValue, atWarWith, canToggleAtWar, isHeader,
		isCollapsed, hasRep, isWatched, isChild, factionID, hasBonusRepGain, canBeLFGBonus = GetFactionInfo(factionIndex)
		if not isHeader and name then
			if (reps[name]) then
				difference = barValue - reps[name]
				if (difference > 0) then
					-- print(format("Reputation with %s increased by %d. (%d remaining until %s)", --long version
					DEFAULT_CHAT_FRAME:AddMessage(string_format("%s + %d. (%d until %s)", name, difference, barMax - barValue, (standingID == 8) and "max" or _G["FACTION_STANDING_LABEL"..standingID + 1]), K.Color.r, K.Color.g, K.Color.b)
				elseif (difference < 0) then
					difference = 0 - difference
					-- print(format("Reputation with %s decreased by %d. (%d remaining until %s)", --long version
					DEFAULT_CHAT_FRAME:AddMessage(string_format("%s - %d. (%d until %s)", name, difference, barValue - barMin, (standingID == 1) and "min" or _G["FACTION_STANDING_LABEL"..standingID - 1]), K.Color.r, K.Color.g, K.Color.b)
				end
			end
			reps[name] = barValue
		end
	end
end)