--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Skins the Blizzard Loss of Control frame.
-- - Design: Applies custom borders, icon coordinates, and positions the frame with a mover.
-- - Events: N/A
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

-- REASON: Localize globals for performance and stack safety.
local _G = _G
local CreateFrame = _G.CreateFrame
local UIParent = _G.UIParent
local hooksecurefunc = _G.hooksecurefunc
local select = _G.select
local table_insert = _G.table.insert
local unpack = _G.unpack

local LossOfControlFrame = _G.LossOfControlFrame

-- Function to skin the LossOfControl frame
-- REASON: Main entry point for Blizzard Loss of Control Frame skinning.
table_insert(C.defaultThemes, function()
	if not C["Skins"].BlizzardFrames then
		return
	end

	local frame = LossOfControlFrame
	frame:StripTextures()

	local iconBorder = CreateFrame("Frame", nil, frame)
	iconBorder:SetAllPoints(frame.Icon)
	iconBorder:CreateBorder()
	iconBorder.KKUI_Border:SetVertexColor(1, 0, 0)

	frame.Icon:SetTexCoord(unpack(K.TexCoords))

	local abilityName = frame.AbilityName
	abilityName:ClearAllPoints()
	abilityName:SetPoint("BOTTOM", frame, 0, -8)
	abilityName.scrollTime = nil
	abilityName:SetFontObject(K.UIFont)
	abilityName:SetFont(select(1, abilityName:GetFont()), 20, select(3, abilityName:GetFont()))

	-- Hide TimeLeft text
	frame.TimeLeft.NumberText:Hide()
	frame.TimeLeft.SecondsText:Hide()

	-- Hook function to control LossOfControlFrame display
	hooksecurefunc(LossOfControlFrame, "SetUpDisplay", function(self)
		local icon = self.Icon
		local abilityName = self.AbilityName
		local animation = self.Anim

		icon:ClearAllPoints()
		icon:SetPoint("CENTER", self)

		abilityName:ClearAllPoints()
		abilityName:SetPoint("BOTTOM", self, 0, -8)

		if animation and animation:IsPlaying() then
			animation:Stop()
		end
	end)

	local frameSize = frame.Icon:GetWidth() + 50
	frame:SetSize(frameSize, frameSize)
	K.Mover(frame, "LossOfControl", "LossOfControlFrame", { "CENTER", UIParent, "CENTER", 0, 250 }, frame:GetSize())
end)
