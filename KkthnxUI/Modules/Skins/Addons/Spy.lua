local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

function Module:ReskinSpy()
	if not C["Skins"].Spy then
		return
	end

	if not K.CheckAddOnState("Spy") then
		return
	end

	if Spy_MainWindow.Background then
		Spy_MainWindow.Background:StripTextures()
		Spy_MainWindow.Background:CreateBorder()
		Spy_MainWindow:StripTextures()
	else
		Spy_MainWindow:StripTextures()
		Spy_MainWindow:CreateBorder()
	end

	TestFrame:StripTextures()
	TestFrame:CreateBorder()
	Spy_AlertWindow:StripTextures()
	Spy_AlertWindow:CreateBorder()
	Spy_MainWindow.CloseButton:SkinCloseButton()
	Spy_MainWindow.CloseButton:SetSize(28, 28)
	Spy_MainWindow.CloseButton:SetPoint("TOPRIGHT", 0, -8)
	Spy_AlertWindow:SetPoint("TOP", UIParent, "TOP", 0, -130)
end