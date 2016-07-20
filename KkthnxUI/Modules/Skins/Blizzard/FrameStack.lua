local K, C, L, _ = select(2, ...):unpack()
if C.Tooltip.Enable ~= true then return end

-- FrameStackTooltip skin(by Elv22)
local frame = CreateFrame("Frame", nil, UIParent)
frame:SetScript("OnUpdate", function(self, elapsed)
	if IsAddOnLoaded("Aurora") then return end

	if self.elapsed and self.elapsed > 0.1 then
		if FrameStackTooltip then
			FrameStackTooltip:SetBackdrop(K.Backdrop)
			FrameStackTooltip:SetBackdropColor(unpack(C.Media.Backdrop_Color))
			FrameStackTooltip:SetBackdropBorderColor(unpack(C.Media.Border_Color))
			FrameStackTooltip.SetBackdropColor = K.Noop
			FrameStackTooltip.SetBackdropBorderColor = K.Noop
			self.elapsed = nil
			self:SetScript("OnUpdate", nil)
		end
		self.elapsed = 0
	else
		self.elapsed = (self.elapsed or 0) + elapsed
	end
end)