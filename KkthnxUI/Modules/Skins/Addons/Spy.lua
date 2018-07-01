local K, C = unpack(select(2, ...))
if C["Skins"].Spy ~= true then
	return
end

local CreateFrame = CreateFrame

local SpySkin = CreateFrame("Frame")
SpySkin:RegisterEvent("PLAYER_LOGIN")
SpySkin:SetScript("OnEvent", function()
	if not K.CheckAddOnState("Spy") then
		return
	end

	Spy_MainWindow.Backgrounds = Spy_MainWindow:CreateTexture(nil, "BACKGROUND", -2)
	Spy_MainWindow.Backgrounds:SetAllPoints()
	Spy_MainWindow.Backgrounds:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

	K.CreateBorder(Spy_MainWindow)

	Spy_AlertWindow.Backgrounds = Spy_AlertWindow:CreateTexture(nil, "BACKGROUND", -2)
	Spy_AlertWindow.Backgrounds:SetAllPoints()
	Spy_AlertWindow.Backgrounds:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

	K.CreateBorder(Spy_AlertWindow)

	Spy_AlertWindow:SetPoint("TOP", UIParent, "TOP", 0, -130)
end)