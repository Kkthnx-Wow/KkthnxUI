local K, C, L, _ = select(2, ...):unpack()
if C.Automation.Resurrection ~= true then return end

local tostring = tostring
local CreateFrame = CreateFrame
local inBattlefield = inBattlefield
local GetCurrentMapAreaID = GetCurrentMapAreaID
local GetBattlefieldStatus = GetBattlefieldStatus
local GetMaxBattlefieldID = GetMaxBattlefieldID
local CanUseSoulstone = CanUseSoulstone
local HasSoulstone = HasSoulstone

-- AUTO RESURRECTION IN PVP
local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_DEAD")
frame:SetScript("OnEvent", function(self, event)
	local isInstance, instanceType = IsInInstance()
	local inBattlefield = false

	for i = 1, GetMaxBattlefieldID() do
		local status = GetBattlefieldStatus(i)
		if status == "active" then inBattlefield = true end
	end

	if not (HasSoulstone() and CanUseSoulstone()) then
		SetMapToCurrentZone()
		local areaID = GetCurrentMapAreaID() or 0
		if (areaID == 501) or (areaID == 708) or (areaID == 978) or (areaID == 1009) or (areaID == 1011) or (inBattlefield == true) then
			RepopMe()
		end
	end

	-- AUTO RELEASE IN WORLD PVP
	--if (inBattlefield == false) then
	if (event == "PLAYER_DEAD" and inBattlefield == false) then -- We might not need to check for PLAYER_DEAD since we alreay register it for the script.

		if HasSoulstone() then
			return
		end

		if (not isInstance) or (instanceType == "none") then
			RepopMe()
		end
	end
end)