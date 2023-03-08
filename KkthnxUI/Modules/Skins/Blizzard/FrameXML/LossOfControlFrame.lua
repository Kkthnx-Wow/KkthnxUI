local K, C = KkthnxUI[1], KkthnxUI[2]

-- Sourced: ElvUI (Elvz)
-- Edited: KkthnxUI (Kkthnx)

-- Import required functions
local table_insert = table.insert
local CreateFrame = CreateFrame
local hooksecurefunc = hooksecurefunc

-- Add theme to the default themes list
table_insert(C.defaultThemes, function()
	-- Exit if Blizzard frames skinning is disabled
	if not C["Skins"].BlizzardFrames then
		return
	end

	-- Create a frame to be used as a border around the Loss of Control frame icon
	local IconBorder = CreateFrame("Frame", nil, LossOfControlFrame)
	IconBorder:SetAllPoints(LossOfControlFrame.Icon)
	IconBorder:SetFrameLevel(LossOfControlFrame:GetFrameLevel())

	-- Create a border for the frame
	local borderWidth = C["General"].BorderStyle.Value ~= "KkthnxUI_Pixel" and 32 or nil
	local borderOffset = C["General"].BorderStyle.Value ~= "KkthnxUI_Pixel" and -10 or nil
	IconBorder:CreateBorder(nil, nil, borderWidth, nil, borderOffset, nil, nil, nil, nil)

	-- Set the color of the border to red
	IconBorder.KKUI_Border:SetVertexColor(1, 0, 0)

	-- Apply texture coordinates to the Loss of Control frame icon
	LossOfControlFrame.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

	-- Strip textures from the Loss of Control frame
	LossOfControlFrame:StripTextures()

	-- Move the ability name text to the bottom of the frame
	LossOfControlFrame.AbilityName:ClearAllPoints()
	LossOfControlFrame.AbilityName:SetPoint("BOTTOM", LossOfControlFrame, 0, -8)

	-- Remove scroll animation from the ability name text
	LossOfControlFrame.AbilityName.scrollTime = nil

	-- Apply a custom font to the ability name text
	LossOfControlFrame.AbilityName:SetFontObject(K.UIFont)
	LossOfControlFrame.AbilityName:SetFont(select(1, LossOfControlFrame.AbilityName:GetFont()), 20, select(3, LossOfControlFrame.AbilityName:GetFont()))

	-- Remove the text elements from the time left display
	LossOfControlFrame.TimeLeft.NumberText:Kill()
	LossOfControlFrame.TimeLeft.SecondsText:Kill()

	-- Hook the setup function to stop the shake animation and center the icon and ability name text
	hooksecurefunc("LossOfControlFrame_SetUpDisplay", function(self)
		local Icon = self.Icon
		local AbilityName = self.AbilityName
		local Anim = self.Anim

		Icon:ClearAllPoints()
		Icon:SetPoint("CENTER", self, "CENTER", 0, 0)

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
