local K, C, L = unpack(select(2, ...))
if C.Misc.KillingBlow ~= true then return end

-- Lua API
local _G = _G
local bit_band = bit.band
local select = select

-- Wow API
local UnitGUID = _G.UnitGUID
local GetPlayerInfoByGUID = _G.GetPlayerInfoByGUID
local RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS
local ACTION_PARTY_KILL = _G.ACTION_PARTY_KILL

-- Global variables that we don't cache, list them here for mikk"s FindGlobals script
-- GLOBALS: COMBATLOG_OBJECT_CONTROL_PLAYER

local Movers = K.Movers

-- Setup message frame
local MessageFrame = CreateFrame("ScrollingMessageFrame", "KillingBlowMessageFrame", UIParent)
MessageFrame:SetFont(C.Media.Font, 18, "OUTLINE")
MessageFrame:SetSize(256, 64)
MessageFrame:SetPoint("CENTER", 0, 205)
MessageFrame:SetInsertMode("TOP")
MessageFrame:SetTimeVisible(3)
MessageFrame:SetFadeDuration(1.5)
MessageFrame:SetFrameLevel(0)
Movers:RegisterFrame(MessageFrame)

local KillingBlow = CreateFrame("Frame")
KillingBlow:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
KillingBlow:SetScript("OnEvent", function(self, event, ...)
	local _, event, _, sourceGUID, sourceName, _, _, destGUID, destName, destFlags = ...
	if (event == "PARTY_KILL") and (sourceGUID == K.GUID) and (bit_band(destFlags, COMBATLOG_OBJECT_CONTROL_PLAYER) > 0) then
		local destGUID, tname = select(8, ...)
		local classIndex = select(2, GetPlayerInfoByGUID(destGUID))
		local color = classIndex and RAID_CLASS_COLORS[classIndex] or {r = 0.2, g = 1, b = 0.2}
		MessageFrame:AddMessage("|cff33FF33"..ACTION_PARTY_KILL..": |r"..tname, color.r, color.g, color.b)
	end
end)