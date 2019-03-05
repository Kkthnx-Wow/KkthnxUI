local K, C = unpack(select(2, ...))
if C["Skins"].Hekili ~= true then
	return
end

if not K.CheckAddOnState("Hekili") then
	return
end

local _G = _G
local ipairs = ipairs

local Create_Hekili_Skin = CreateFrame("Frame")
Create_Hekili_Skin:RegisterEvent("PLAYER_LOGIN")
Create_Hekili_Skin:RegisterEvent("ADDON_LOADED")
Create_Hekili_Skin:SetScript("OnEvent", function()
	for Display, _ in ipairs(Hekili.DB.profile.displays) do
		for Buttons = 1, Hekili.DB.profiles.displays[Display].numIcons do
			local Button = _G["Hekili_D" .. Display .. "_B" .. Buttons]
			Button:CreateBorder()
			Button.Texture:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		end
	end
end)