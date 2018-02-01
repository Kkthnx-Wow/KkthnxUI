local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("DurabilityWarning")

local _G = _G

local DurabilityFrame = _G.DurabilityFrame

function Module:SetShow()
	self.Warning:Show()
end

function Module:SetHide()
	self.Warning:Hide()
end

function Module:OnEnable()
	if (not DurabilityFrame) then
		return
	end

	local Durability = CreateFrame("Frame")

	Durability:FontString("Warning", C["Media"].Font, 16, "THINOUTLINE")
	Durability.Warning:SetPoint("TOP", UIParent, "TOP", 0, -8)
	Durability.Warning:SetText(L["Miscellaneous"].Repair)
	Durability.Warning:SetTextColor(1, 0, 0)
	Durability.Warning:Hide()

	DurabilityFrame:SetAlpha(0)
	DurabilityFrame:Hide()
	DurabilityFrame:HookScript("OnShow", self.SetShow)
	DurabilityFrame:HookScript("OnHide", self.SetHide)
end

K["Durability"] = Module