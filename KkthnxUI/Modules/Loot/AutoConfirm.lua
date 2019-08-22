local K, C = unpack(select(2, ...))
local Module = K:GetModule("Loot")

local _G = _G

local STATICPOPUP_NUMDIALOGS = _G.STATICPOPUP_NUMDIALOGS or 4

local function SetupAutoConfirm()
	for i = 1, STATICPOPUP_NUMDIALOGS do
		local frame = _G["StaticPopup"..i]
		if (frame.which == "CONFIRM_LOOT_ROLL" or frame.which == "LOOT_BIND") and frame:IsVisible() then
			_G.StaticPopup_OnClick(frame, 1)
		end
	end
end

function Module:CreateAutoConfirm()
	if C["Loot"].AutoDisenchant ~= true then
		return
	end

	K:RegisterEvent("CONFIRM_DISENCHANT_ROLL", SetupAutoConfirm)
	K:RegisterEvent("CONFIRM_LOOT_ROLL", SetupAutoConfirm)
	K:RegisterEvent("LOOT_BIND_CONFIRM", SetupAutoConfirm)
end