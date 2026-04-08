--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Automatically confirms loot and bind-on-pickup dialogs.
-- - Design: Loops through visible static popups and triggers the confirm button.
-- - Events: CONFIRM_DISENCHANT_ROLL, CONFIRM_LOOT_ROLL, LOOT_BIND_CONFIRM
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Loot")

-- PERF: Localize global environment for faster lookups.
local _G = _G
local StaticPopup_OnClick = _G.StaticPopup_OnClick
local STATICPOPUP_NUMDIALOGS = _G.STATICPOPUP_NUMDIALOGS

-- REASON: Checks for specific loot-related static popups and automatically clicks the confirm button.
local function setupAutoConfirm()
	for i = 1, STATICPOPUP_NUMDIALOGS do
		local frame = _G["StaticPopup" .. i]
		if frame and (frame.which == "CONFIRM_LOOT_ROLL" or frame.which == "LOOT_BIND") and frame:IsVisible() then
			StaticPopup_OnClick(frame, 1)
		end
	end
end

function Module:CreateAutoConfirm()
	if not C["Loot"].AutoConfirmLoot then
		return
	end

	K:RegisterEvent("CONFIRM_DISENCHANT_ROLL", setupAutoConfirm)
	K:RegisterEvent("CONFIRM_LOOT_ROLL", setupAutoConfirm)
	K:RegisterEvent("LOOT_BIND_CONFIRM", setupAutoConfirm)
end
