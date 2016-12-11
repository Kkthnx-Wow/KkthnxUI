local K, C, L = unpack(select(2, ...))
if C.Blizzard.ReputationGain ~= true then return end

local frame = 1
local f = CreateFrame("FRAME", nil, UIParent)

local factionVars = {}

local cwhite, cyellow, corange, cresume = "|CFF999999", "|CFFD9C45C", "|CFFD9865C", "|r"
local fmt = string.format
local getfactioninfo = GetFactionInfo
local math_abs = math.abs
local math_ceil = math.ceil
local standingmax = 8
local standingmin = 1
local init = 0
local factions = 0
local chatframe = _G["ChatFrame" .. frame]
f:RegisterEvent("UPDATE_FACTION")

local function ScanFaction()
	if (GetNumFactions() == 0) then DEFAULT_CHAT_FRAME:AddMessage("Factions not yet available") end
	for i = 1, GetNumFactions() do
		local name, _, standingID, _, _, barValue, _, _, isHeader, _, hasRep = getfactioninfo(i)
		if ((not isHeader or hasRep) and name) then
			factionVars[name] = {}
			factionVars[name].Standing = standingID
			factionVars[name].Value = barValue
		end
	end
end

local function Report()
	local tempfactions = GetNumFactions()
	if (tempfactions ~= 0 and init == 0) then
		ScanFaction()
		init = 1
		factions = tempfactions
		return
	end
	if (tempfactions > factions) then
		ScanFaction()
		factions = tempfactions
	end
	for factionIndex = 1, GetNumFactions() do
		local name, _, standingID, barMin, barMax, barValue, _, _, isHeader, _, hasRep = getfactioninfo(factionIndex)

		if (not isHeader or hasRep) and factionVars[name] then
			local diff = barValue - factionVars[name].Value
			if diff ~= 0 then
				if standingID ~= factionVars[name].Standing then
					local newfaction = _G["FACTION_STANDING_LABEL" .. standingID]
					local newstandingtext =
					"New standing with " .. cyellow .. name .. cresume ..
					" is " .. cyellow .. newfaction .. cresume .. "!"

					chatframe:AddMessage(newstandingtext)
				end

				local remaining, nextstanding, plusminus
				if diff > 0 then
					remaining = barMax - barValue
					if standingID < standingmax then
						nextstanding = _G["FACTION_STANDING_LABEL" .. standingID + 1]
					else
						nextstanding = "End of " .. _G["FACTION_STANDING_LABEL" .. standingmax]
					end
				else
					remaining = barValue - barMin
					if standingID > standingmin then
						nextstanding = _G["FACTION_STANDING_LABEL" .. standingID - 1]
					else
						nextstanding = "Beginning of " .. _G["FACTION_STANDING_LABEL" .. standingmin]
					end
				end

				local change = math_abs(barValue - factionVars[name].Value)
				local repetitions = math_ceil(remaining / change)

				local newvaluetext = fmt("%s%+d%s %s%s, %s%d%s more to %s%s%s (%s%d%s Repetitions).",
				corange,change,cyellow,name,cresume,corange,remaining,cresume,
				cyellow,nextstanding,cresume,corange,repetitions,cresume )

				chatframe:AddMessage(newvaluetext)

				factionVars[name].Value = barValue
				factionVars[name].Standing = standingID
			end
		end
	end
end

local function eventHandler(self, event, ...)
	if(event == "UPDATE_FACTION") then Report() end
end

f:SetScript("OnEvent", eventHandler)