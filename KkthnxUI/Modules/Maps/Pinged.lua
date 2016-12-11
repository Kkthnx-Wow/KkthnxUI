local K, C, L = unpack(select(2, ...))
if C.Minimap.Ping ~= true then return end

-- Lua API
local format = string.format
local select = select
local time = time

-- Wow API
local CreateFrame = CreateFrame
local CUSTOM_CLASS_COLORS = CUSTOM_CLASS_COLORS
local RAID_CLASS_COLORS = RAID_CLASS_COLORS
local UnitClass = UnitClass
local UnitName = UnitName
local UIFrameFlash = UIFrameFlash

local PingFrame = CreateFrame("Frame")
local PingText = K.SetFontString(PingFrame, C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
PingText:SetPoint("CENTER", Minimap, "CENTER", 0, 30)
PingText:SetJustifyH("CENTER")

local function OnEvent(self, event, unit)
	if UnitName(unit) ~= K.Name then
		if self.timer and time() - self.timer > 1 or not self.timer then
			local Class = CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS[select(2, UnitClass(unit))]
			PingText:SetText(format("|cffff0000*|r %s |cffff0000*|r", UnitName(unit)))
			PingText:SetTextColor(Class.r, Class.g, Class.b)
			UIFrameFlash(self, 0.2, 2.8, 5, false, 0, 5)
			self.timer = time()
		end
	end
end

PingFrame:RegisterEvent("MINIMAP_PING")
PingFrame:SetScript("OnEvent", OnEvent)