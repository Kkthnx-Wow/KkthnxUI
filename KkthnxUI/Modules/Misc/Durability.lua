local K, C, L = select(2, ...):unpack()
if C.Misc.DurabilityWarninig ~= true then return end

local Durability = CreateFrame("Frame")
local TimerTracker = TimerTracker
local DurabilityFrame = DurabilityFrame

function Durability:OnShow()
	Durability.Warning:Show()
end

function Durability:OnHide()
	Durability.Warning:Hide()
end

Durability:FontString("Warning", C.Media.Font, 18, "THINOUTLINE")
Durability.Warning:SetPoint("TOP", UIParent, "TOP", 0, -8)
Durability.Warning:SetText(L_MISC_REPAIR)
Durability.Warning:SetTextColor(1, 0, 0)
Durability.Warning:Hide()

DurabilityFrame:SetAlpha(0)
DurabilityFrame:Hide()
DurabilityFrame:HookScript("OnShow", Durability.OnShow)
DurabilityFrame:HookScript("OnHide", Durability.OnHide)
