local K, C, L = unpack(select(2, ...))
if C["Automation"].AutoRelease ~= true then return end

-- Wow Lua
local _G = _G

-- Wow API
local GetCurrentMapAreaID = _G.GetCurrentMapAreaID
local HasSoulstone = _G.HasSoulstone
local IsInInstance = _G.IsInInstance

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: SetMapToCurrentZone, RepopMe

-- Auto release the spirit in battlegrounds
local AutoRelease = CreateFrame("Frame")
AutoRelease:RegisterEvent("PLAYER_DEAD")
AutoRelease:SetScript("OnEvent", function(self, event)
	-- If player has ability to self-resurrect (soulstone, reincarnation, etc), do nothing and quit
	-- HasSoulstone() affects all self-res abilities, returns valid data only while dead
	if HasSoulstone() then return end

	-- Resurrect if player is in a battleground
	local InstStat, InstType = IsInInstance()
	if InstStat and InstType == "pvp" then
		RepopMe()
		return
	end

	-- Get current location
	SetMapToCurrentZone()
	local areaID = GetCurrentMapAreaID() or 0

	-- Resurrect if player is in Wintergrasp (501)
	if (areaID == 501 or areaID == 708 or areaID == 978 or areaID == 1009 or areaID == 1011) then
		RepopMe()
		return
	end
	return
end)