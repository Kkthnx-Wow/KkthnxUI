local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Loot")

-- Sourced: ShestakUI (Wetxius, Shestak)

local STATICPOPUP_NUMDIALOGS = STATICPOPUP_NUMDIALOGS

-- Function to handle auto confirming of loot dialogs
local function SetupAutoConfirm()
	-- Loop through all the static popup dialogs
	for i = 1, STATICPOPUP_NUMDIALOGS do
		-- Get the current popup frame
		local frame = _G["StaticPopup" .. i]

		-- Check if the popup frame is visible and its type is either "CONFIRM_LOOT_ROLL" or "LOOT_BIND"
		if (frame.which == "CONFIRM_LOOT_ROLL" or frame.which == "LOOT_BIND") and frame:IsVisible() then
			-- Call the StaticPopup_OnClick function with the first option (index 1) selected
			StaticPopup_OnClick(frame, 1)
		end
	end
end

-- Function to create the auto confirm feature
function Module:CreateAutoConfirm()
	-- Check if the auto confirm loot feature is enabled in the config
	if not C["Loot"].AutoConfirmLoot then
		return
	end

	-- Register the CONFIRM_DISENCHANT_ROLL, CONFIRM_LOOT_ROLL, and LOOT_BIND_CONFIRM events
	-- and call the SetupAutoConfirm function when any of them triggers
	K:RegisterEvent("CONFIRM_DISENCHANT_ROLL", SetupAutoConfirm)
	K:RegisterEvent("CONFIRM_LOOT_ROLL", SetupAutoConfirm)
	K:RegisterEvent("LOOT_BIND_CONFIRM", SetupAutoConfirm)
end
