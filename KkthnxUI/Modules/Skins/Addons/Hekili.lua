local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Skins")

function Module:ReskinHekili()
	local Hekili = _G.Hekili
	if not Hekili then
		return
	end

	if Hekili.CreateButton then
		local CreateButton = Hekili.CreateButton
		Hekili.CreateButton = function(...)
			local button = CreateButton(...)
			if button and not button.styled then
				button:CreateBorder()
				button.styled = true
			end
			return button
		end
	end
end

Module:RegisterSkin("Hekili", Module.ReskinHekili, true)
