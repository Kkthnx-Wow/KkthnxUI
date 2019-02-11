local K, C = unpack(select(2, ...))
local ModuleSkins = K:GetModule("Skins")
if C["Skins"].Hekili ~= true or not K.CheckAddOnState("Hekili") then
	return
end

local _G = _G
local ipairs = ipairs

local SkinHekili = CreateFrame("Frame")
SkinHekili:RegisterEvent("PLAYER_LOGIN")
SkinHekili:SetScript("OnEvent", function(self, event, addon)
	for Display, _ in ipairs(Hekili.DB.profile.displays) do
		for Buttons = 1, Hekili.DB.profile.displays[Display].numIcons do
			local Button = _G["Hekili_D"..Display.."_B"..Buttons]
			Button:CreateBorder()
			Button.Texture:SetTexCoord(K.TexCoords[4], K.TexCoords[4], K.TexCoords[4], K.TexCoords[4])
		end
	end
end)