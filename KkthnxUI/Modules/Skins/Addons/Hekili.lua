--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Skins Hekili action buttons.
-- - Design: Hooks Hekili's button creation to apply KkthnxUI border styling.
-- - Events: N/A
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Skins")

-- REASON: Localize globals for performance and stack safety.
local _G = _G

-- REASON: Main entry point for Hekili skinning.
function Module:ReskinHekili()
	if not C["Skins"].Hekili then
		return
	end

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
