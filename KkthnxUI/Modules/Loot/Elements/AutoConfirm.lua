local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Loot")

-- Sourced: ShestakUI (Wetxius, Shestak)

local STATICPOPUP_NUMDIALOGS = STATICPOPUP_NUMDIALOGS

-- Function to handle auto confirming of loot dialogs
local function SetupAutoConfirm()
	for i = 1, STATICPOPUP_NUMDIALOGS do
		local frame = _G["StaticPopup" .. i]
		if (frame.which == "CONFIRM_LOOT_ROLL" or frame.which == "LOOT_BIND") and frame:IsVisible() then
			StaticPopup_OnClick(frame, 1)
		end
	end
end

-- Function to create the auto confirm feature
function Module:CreateAutoConfirm()
	if not C["Loot"].AutoConfirmLoot then
		return
	end

	K:RegisterEvent("CONFIRM_DISENCHANT_ROLL", SetupAutoConfirm)
	K:RegisterEvent("CONFIRM_LOOT_ROLL", SetupAutoConfirm)
	K:RegisterEvent("LOOT_BIND_CONFIRM", SetupAutoConfirm)
end
