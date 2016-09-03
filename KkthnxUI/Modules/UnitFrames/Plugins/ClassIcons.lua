local K, C, L, _ = select(2, ...):unpack()
if C.Unitframe.ClassIcon ~= true then return end

-- CLASS ICONS
hooksecurefunc("UnitFramePortrait_Update", function(self)
	if self.portrait then
		if UnitIsPlayer(self.unit) then
			local t = CLASS_ICON_TCOORDS[select(2, UnitClass(self.unit))]
			if t then
				self.portrait:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
				self.portrait:SetTexCoord(unpack(t))
			end
		else
			self.portrait:SetTexCoord(0, 1, 0, 1)
		end
	end
end)