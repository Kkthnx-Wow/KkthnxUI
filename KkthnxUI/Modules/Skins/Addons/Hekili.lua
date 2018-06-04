local K = unpack(select(2, ...))
if not K.CheckAddOnState("Hekili") then
	return
end

local _G = _G
local ipairs = ipairs

local SkinHekili = CreateFrame("Frame")
SkinHekili:RegisterEvent("PLAYER_ENTERING_WORLD")
SkinHekili:SetScript("OnEvent", function()
	for Display, _ in ipairs(Hekili.DB.profile.displays) do
		for Buttons = 1, Hekili.DB.profile.displays[Display].numIcons do
			local Button = _G["Hekili_D"..Display.."_B"..Buttons]
			Button:SetTemplate()
			Button.Texture:SetTexCoord(K.TexCoords[4], K.TexCoords[4], K.TexCoords[4], K.TexCoords[4])
		end
	end
end)