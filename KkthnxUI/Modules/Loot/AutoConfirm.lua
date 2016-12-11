local K, C, L = unpack(select(2, ...))
if C.Loot.ConfirmDisenchant ~= true then return end

local _G = _G
local CreateFrame = CreateFrame

-- Disenchant confirmation(tekKrush by Tekkub)
local frame = CreateFrame("Frame")
frame:RegisterEvent("CONFIRM_DISENCHANT_ROLL")
frame:RegisterEvent("CONFIRM_LOOT_ROLL")
frame:RegisterEvent("LOOT_BIND_CONFIRM")
frame:SetScript("OnEvent", function(self, event, id)
	for i = 1, STATICPOPUP_NUMDIALOGS do
		local frame = _G["StaticPopup"..i]
		if (frame.which == "CONFIRM_LOOT_ROLL" or frame.which == "LOOT_BIND") and frame:IsVisible() then StaticPopup_OnClick(frame, 1) end
	end
end)