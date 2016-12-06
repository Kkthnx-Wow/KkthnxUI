local K, C, L = select(2, ...):unpack()
if C.Announcements.BadGear ~= true then return end

-- Lua API
local format = string.format
local pairs = pairs
local select = select

-- Wow API
local CreateFrame = CreateFrame
local GetInventoryItemID = GetInventoryItemID
local GetItemInfo = GetItemInfo
local IsInInstance = IsInInstance
local PlaySound = PlaySound

-- CHECK BAD GEAR IN INSTANCE
local BadGear = CreateFrame("Frame")
BadGear:RegisterEvent("ZONE_CHANGED_NEW_AREA")
BadGear:SetScript("OnEvent", function(self, event)
	if (event ~= "ZONE_CHANGED_NEW_AREA") or (not IsInInstance()) then return end
	local item = {}
	for i = 1, 17 do
		if K.AnnounceBadGear[i] ~= nil then
			item[i] = GetInventoryItemID("player", i) or 0
			for j, baditem in pairs(K.AnnounceBadGear[i]) do
				if item[i] == baditem then
					PlaySound("RaidWarning", "master")
					RaidNotice_AddMessage(RaidWarningFrame, format("%s %s", CURRENTLY_EQUIPPED, select(2, GetItemInfo(item[i])).."!!!"), ChatTypeInfo["RAID_WARNING"])
					print(format("|cffff3300%s %s", CURRENTLY_EQUIPPED, select(2, GetItemInfo(item[i])).."|cffff3300!!!|r"))
				end
			end
		end
	end
end)