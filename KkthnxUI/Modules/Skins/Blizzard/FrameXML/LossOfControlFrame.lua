local K, C = unpack(select(2, ...))

-- Import required functions
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

-- Apply theme to the Loss of Control frame
table.insert(C.defaultThemes, function()
	-- Exit if Blizzard frames skinning is disabled
	if not C.Skins.BlizzardFrames then
		return
	end

	-- Strip textures from the Loss of Control frame
	LossOfControlFrame:StripTextures()

	-- Create a border around the Loss of Control frame icon
	local iconBorder = CreateFrame("Frame", nil, LossOfControlFrame)
	iconBorder:SetAllPoints(LossOfControlFrame.Icon)
	iconBorder:CreateBorder()

	-- Set the color of the border to red
	iconBorder.KKUI_Border:SetVertexColor(1, 0, 0)

	-- Apply texture coordinates to the Loss of Control frame icon
	LossOfControlFrame.Icon:SetTexCoord(unpack(K.TexCoords))

	-- Move the ability name text to the bottom of the frame
	LossOfControlFrame.AbilityName:ClearAllPoints()
	LossOfControlFrame.AbilityName:SetPoint("BOTTOM", LossOfControlFrame, 0, -8)

	-- Remove scroll animation from the ability name text
	LossOfControlFrame.AbilityName.scrollTime = nil

	-- Apply a custom font to the ability name text
	LossOfControlFrame.AbilityName:SetFontObject(K.UIFont)
	LossOfControlFrame.AbilityName:SetFont(select(1, LossOfControlFrame.AbilityName:GetFont()), 20, select(3, LossOfControlFrame.AbilityName:GetFont()))

	-- Remove the text elements from the time left display
	LossOfControlFrame.TimeLeft.NumberText:Hide()
	LossOfControlFrame.TimeLeft.SecondsText:Hide()

	-- Hook the setup function to stop the shake animation and center the icon and ability name text
	hooksecurefunc("LossOfControlFrame_SetUpDisplay", function(self)
		local Icon = self.Icon
		local AbilityName = self.AbilityName
		local Anim = self.Anim

		Icon:ClearAllPoints()
		Icon:SetPoint("CENTER", self)

		AbilityName:ClearAllPoints()
		AbilityName:SetPoint("BOTTOM", self, 0, -8)

		if Anim and Anim:IsPlaying() then
			Anim:Stop()
		end
	end)

	-- Set the size and position of the Loss of Control frame and create a mover
	local frameSize = LossOfControlFrame.Icon:GetWidth() + 50
	LossOfControlFrame:SetSize(frameSize, frameSize)
	K.Mover(LossOfControlFrame, "LossOfControl", "LossOfControlFrame", { "CENTER", UIParent, "CENTER", 0, 250 }, LossOfControlFrame:GetSize())
end)
