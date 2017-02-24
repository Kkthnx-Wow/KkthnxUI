local K, C, L = unpack(select(2, ...))
if C.Minimap.Enable ~= true then return end

-- Lua API
local _G = _G

-- Wow API
local InCombatLockdown = _G.InCombatLockdown

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: SLASH_FARMMODE1, MinimapAnchor, Minimap

-- Farm Mode
local Farm = false

_G.SlashCmdList.FARMMODE = function()
	if Farm == false then
		MinimapAnchor:SetSize(C.Minimap.Size * 1.64, C.Minimap.Size * 1.64)
		Minimap:SetSize(MinimapAnchor:GetWidth(), MinimapAnchor:GetWidth())
		Farm = true
	else
		MinimapAnchor:SetSize(C.Minimap.Size, C.Minimap.Size)
		Minimap:SetSize(MinimapAnchor:GetWidth(), MinimapAnchor:GetWidth())
		Farm = false
	end
end
SLASH_FARMMODE1 = "/farmmode"

-- Button for farm-mode
local Farm = CreateFrame("Button", "FarmModeButton", UIParent)
K.CreateBorder(Farm, 1)
Farm:SetBackdrop(K.BorderBackdrop)
Farm:SetBackdropColor(C.Media.Backdrop_Color[1], C.Media.Backdrop_Color[2], C.Media.Backdrop_Color[3], C.Media.Backdrop_Color[4])
Farm:SetPoint("TOPRIGHT", Minimap, "BOTTOMLEFT", -4, -4)
Farm:SetSize(19, 19)
Farm:SetAlpha(0)

Farm.Texture = Farm:CreateTexture(nil, "OVERLAY")
Farm.Texture:SetTexture("Interface\\Icons\\inv_misc_map_01")
Farm.Texture:SetTexCoord(unpack(K.TexCoords))
Farm.Texture:SetPoint("TOPLEFT", Farm, 2, -2)
Farm.Texture:SetPoint("BOTTOMRIGHT", Farm, -2, 2)

Farm:SetScript("OnClick", function()
	_G.SlashCmdList.FARMMODE()
end)

Farm:SetScript("OnEnter", function()
	if InCombatLockdown() then return end
	Farm:FadeIn()
end)

Farm:SetScript("OnLeave", function()
	Farm:FadeOut()
end)