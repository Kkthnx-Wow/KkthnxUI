local K, C, L, _ = select(2, ...):unpack()
if C.Automation.Resurrection ~= true then return end

local tostring = tostring
local CreateFrame = CreateFrame
local GetZoneText = GetZoneText
local UnitBuff = UnitBuff
local GetSpellInfo = GetSpellInfo

-- Auto resurrection
local WINTERGRASP
WINTERGRASP = L_ZONE_WINTERGRASP

local autoreleasepvp = CreateFrame("frame")
autoreleasepvp:RegisterEvent("PLAYER_DEAD")
autoreleasepvp:SetScript("OnEvent", function(self, event)
	local soulstone = GetSpellInfo(20707)
	if (K.Class ~= "SHAMAN") or not (soulstone and UnitBuff("player", soulstone)) then
		if (tostring(GetZoneText()) == WINTERGRASP) then
			RepopMe()
		end
		if MiniMapBattlefieldFrame.status == "active" then
			RepopMe()
		end
	end
end)