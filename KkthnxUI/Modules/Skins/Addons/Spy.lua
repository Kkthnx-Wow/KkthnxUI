local K, C = unpack(select(2, ...))
if C["Skins"].Spy ~= true or not K.CheckAddOnState("Spy") then
	return
end

local SpySkin = CreateFrame("Frame")
SpySkin:RegisterEvent("ADDON_LOADED")
SpySkin:RegisterEvent("PLAYER_ENTERING_WORLD")
SpySkin:SetScript("OnEvent", function()
	Spy_MainWindow:CreateBorder()
	Spy_AlertWindow:CreateBorder()
	Spy_MainWindow.CloseButton:SkinCloseButton()
	Spy_AlertWindow:SetPoint("TOP", UIParent, "TOP", 0, -130)
end)