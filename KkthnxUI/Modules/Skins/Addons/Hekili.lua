local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

function Module:ReskinHekili()
	if not IsAddOnLoaded("Hekili") then
		return
    end

    if not C["Skins"].Hekili then
        return
    end

    for Display, _ in ipairs(Hekili.DB.profile.displays) do
        for Buttons = 1, Hekili.DB.profile.displays[Display].numIcons do
			local Button = _G["Hekili_D"..Display.."_B"..Buttons]
			Button:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, true)
			Button.Texture:SetTexCoord(unpack(K.TexCoords))
		end
	end
end