local K, C, L, _ = select(2, ...):unpack()
if C.Minimap.Enable ~= true then return end

-- FARM-MODE
local Farm = false
SlashCmdList.FARMMODE = function()
	if Farm == false then
		MinimapAnchor:SetSize(C.Minimap.Size * 1.65, C.Minimap.Size * 1.65)
		Minimap:SetSize(MinimapAnchor:GetWidth(), MinimapAnchor:GetWidth())
		Farm = true
	else
		MinimapAnchor:SetSize(C.Minimap.Size, C.Minimap.Size)
		Minimap:SetSize(MinimapAnchor:GetWidth(), MinimapAnchor:GetWidth())
		Farm = false
	end
end
SLASH_FARMMODE1 = "/farmmode"
SLASH_FARMMODE2 = "/fm"

-- BUTTON FOR FARM-MODE
local Farm = CreateFrame("Button", "FarmMode", UIParent)
K.CreateBorder(Farm, 10)
Farm:SetPoint("TOP", ToggleBar5, "BOTTOM", 0, -4)
Farm:SetSize(19, 19)
Farm:SetAlpha(0)

Farm.t = Farm:CreateTexture(nil, "OVERLAY")
Farm.t:SetTexture("Interface\\Icons\\inv_misc_map_01")
Farm.t:SetTexCoord(unpack(K.TexCoords))
Farm.t:SetPoint("TOPLEFT", Farm, 2, -2)
Farm.t:SetPoint("BOTTOMRIGHT", Farm, -2, 2)

Farm:SetScript("OnClick", function()
	SlashCmdList.FARMMODE()
end)

Farm:SetScript("OnEnter", function()
	Farm:FadeIn()
end)

Farm:SetScript("OnLeave", function()
	Farm:FadeOut()
end)