local K = KkthnxUI[1]
local Module = K:GetModule("Blizzard")

local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc
local UIParent = UIParent

-- Reanchor UIWidgets
function Module:CreateUIWidgets()
	local frame1 = CreateFrame("Frame", "KKUI_WidgetMover", UIParent)
	frame1:SetSize(200, 50)
	K.Mover(frame1, "UIWidgetFrame", "UIWidgetFrame", { "TOPRIGHT", Minimap, "BOTTOMRIGHT", 0, -28 })

	hooksecurefunc(UIWidgetBelowMinimapContainerFrame, "SetPoint", function(self, _, parent)
		if parent ~= frame1 then
			self:ClearAllPoints()
			self:SetPoint("TOPRIGHT", frame1)
		end
	end)

	local frame2 = CreateFrame("Frame", "KKUI_WidgetPowerBarMover", UIParent)
	frame2:SetSize(260, 40)
	K.Mover(frame2, "UIWidgetPowerBar", "UIWidgetPowerBar", { "BOTTOM", UIParent, "BOTTOM", 0, 250 })

	hooksecurefunc(UIWidgetPowerBarContainerFrame, "SetPoint", function(self, _, parent)
		if parent ~= frame2 then
			self:ClearAllPoints()
			self:SetPoint("CENTER", frame2)
		end
	end)
end
