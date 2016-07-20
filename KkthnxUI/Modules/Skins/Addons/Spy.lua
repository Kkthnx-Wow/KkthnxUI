local K, C, L, _ = select(2, ...):unpack()
if C.Skins.Spy ~= true then return end

local CreateFrame = CreateFrame
local IsAddOnLoaded = IsAddOnLoaded

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_LOGIN")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function(self, event)
	if not IsAddOnLoaded("Spy") then return end

	local function Skin_Spy()
		Spy_MainWindow:StripTextures()
		BarTexture = C.Media.Texture
		Spy:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
		Spy_MainWindow:CreateBackdrop(2)
		Spy_MainWindow:SetBackdropColor(unpack(C.Media.Backdrop_Color))
		end
		Skin_Spy()
end)