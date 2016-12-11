local K, C, L = unpack(select(2, ...))
if C.Skins.Spy ~= true then return end

local CreateFrame = CreateFrame


local SpySkin = CreateFrame("Frame")
SpySkin:RegisterEvent("PLAYER_LOGIN")
SpySkin:SetScript("OnEvent", function(self, event)
	if not K.CheckAddOn("Spy") then return end

	Spy_MainWindow:SetTemplate("Transparent")
	Spy_AlertWindow:SetTemplate("Transparent")
	Spy_AlertWindow:SetPoint("TOP", UIParent, "TOP", 0, -130)
end)