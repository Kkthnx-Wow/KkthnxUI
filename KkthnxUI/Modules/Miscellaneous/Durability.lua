local K, C, L = select(2, ...):unpack()
if C.Misc.DurabilityWarninig ~= true then return end

local Durability = CreateFrame("Frame", nil, UIParent)
local TimerTracker = TimerTracker
local DurabilityFrame = DurabilityFrame

function Durability:OnShow()
	Durability.Warning:Show()
end

function Durability:OnHide()
	Durability.Warning:Hide()
end

function Durability:Enable()
	self:FontString("Warning", C.Media.Font, 18, "OUTLINE")
	self.Warning:SetPoint("TOP", UIParent, "TOP", 0, -8)
	self.Warning:SetText(L_MISC_REPAIR)
	self.Warning:SetTextColor(1, 0, 0)
	self.Warning:Hide()

	DurabilityFrame:SetAlpha(0)
	DurabilityFrame:Hide()
	DurabilityFrame:HookScript("OnShow", self.OnShow)
	DurabilityFrame:HookScript("OnHide", self.OnHide)
end

Durability:RegisterEvent("PLAYER_LOGIN")
Durability:SetScript("OnEvent", Durability.Enable)