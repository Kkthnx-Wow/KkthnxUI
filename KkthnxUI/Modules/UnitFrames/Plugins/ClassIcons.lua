local K, C, L, _ = select(2, ...):unpack()
if C.Unitframe.ClassIcon ~= true then return end

-- CLASS ICONS
-- CREDITS TO GOSSIPGIRLXO FOR THE DARK FLATICONS.
hooksecurefunc("UnitFramePortrait_Update", function(self)
	if self.portrait then
		if UnitIsPlayer(self.unit) then
			local t = CLASS_ICON_TCOORDS[select(2, UnitClass(self.unit))]
			if t then
				if C.Unitframe.FlatClassIcons then
					self.portrait:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Unitframes\\DarkClassIcons")
				else
					self.portrait:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
				end
				self.portrait:SetTexCoord(unpack(t))
			end
		else
			self.portrait:SetTexCoord(0, 1, 0, 1)
		end
	end
end)