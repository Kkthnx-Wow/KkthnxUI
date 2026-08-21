--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Tooltip/HealthBar.lua
	Purpose:
		Style the unit tooltip's health bar: our texture and border, anchored just
		outside the tooltip, with a locked colour (so the unit post-call's class or
		reaction colour sticks) and a percent value readout.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

local Module = K:GetModule("Tooltip")

local _G = _G
local IsSecret = K.IsSecret

-- Anchor the health bar just outside the tooltip, above or below, with a small
-- gap. Blizzard re-anchors it on show, so this is called again from the unit
-- post-call to keep our placement.
local function PositionHealthBar(bar)
	local tt = bar:GetParent()
	bar:ClearAllPoints()
	if C.Tooltip.HealthBarPosition == "BOTTOM" then
		bar:SetPoint("TOPLEFT", tt, "BOTTOMLEFT", 0, -6)
		bar:SetPoint("TOPRIGHT", tt, "BOTTOMRIGHT", 0, -6)
	else
		bar:SetPoint("BOTTOMLEFT", tt, "TOPLEFT", 0, 6)
		bar:SetPoint("BOTTOMRIGHT", tt, "TOPRIGHT", 0, 6)
	end
end
Module.PositionHealthBar = PositionHealthBar

function Module:StyleHealthBar()
	local bar = _G.GameTooltipStatusBar
	if not bar then
		return
	end
	bar:SetStatusBarTexture(K.GetTexture(C.Unitframe and C.Unitframe.Texture or "KkthnxUI"))
	bar:SetHeight(12)
	PositionHealthBar(bar)

	-- Blizzard's HealthBar_OnValueChanged forces the bar green on every health
	-- tick unless lockColor is set. Lock it so our class/reaction colour from the
	-- unit post-call is what sticks.
	bar.lockColor = true

	if not bar.KKUI_Background then
		K.CreateBackground(bar, 0.1, 0.1, 0.1, 0.9)
		K.CreateBorder(bar)
	end

	-- The bar now runs 0..1 as a health percent (the real amount is secret), so
	-- the value is the fraction and we show it as a percentage.
	if not bar.KKUI_Text then
		local text = bar:CreateFontString(nil, "OVERLAY")
		K.SetFont(text, 11, K.FontOutlineStyle())
		text:SetPoint("CENTER", bar, "CENTER", 0, 0)
		bar.KKUI_Text = text

		bar:HookScript("OnValueChanged", function(self, value)
			local fs = self.KKUI_Text
			if not fs then
				return
			end
			if not C.Tooltip.HealthValue or not value or IsSecret(value) then
				fs:SetText("")
				return
			end
			local minV, maxV = self:GetMinMaxValues()
			local pct
			if minV and maxV and not IsSecret(minV) and not IsSecret(maxV) and maxV > minV then
				pct = (value - minV) / (maxV - minV) * 100
			else
				pct = value * 100
			end
			fs:SetFormattedText("%d%%", pct)
		end)
	end
end
