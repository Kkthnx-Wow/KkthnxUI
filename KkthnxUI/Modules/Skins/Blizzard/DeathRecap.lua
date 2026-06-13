--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Skins the Blizzard Death Recap frame.
-- - Design: Applies custom borders and skins buttons/events within the Death Recap UI.
-- - Events: N/A
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

-- REASON: Localize globals for performance and stack safety.
local _G = _G
local select = _G.select
local unpack = _G.unpack

local NUM_DEATH_RECAP_EVENTS = _G["NUM_DEATH_RECAP_EVENTS"]

local function GetDeathRecapFrame()
	local deathRecap = _G["DeathRecap"]
	return _G["DeathRecapFrame"] or (deathRecap and deathRecap.Frame) or deathRecap
end

local function SkinDeathRecapFrame()
	local DeathRecapFrame = GetDeathRecapFrame()
	if not DeathRecapFrame or not DeathRecapFrame.DisableDrawLayer or DeathRecapFrame.styled then
		return DeathRecapFrame
	end

	-- Disable the border draw layer and hide unwanted elements
	DeathRecapFrame:DisableDrawLayer("BORDER")
	if DeathRecapFrame.Background then
		DeathRecapFrame.Background:Hide()
	end
	if DeathRecapFrame.BackgroundInnerGlow then
		DeathRecapFrame.BackgroundInnerGlow:Hide()
	end
	if DeathRecapFrame.Divider then
		DeathRecapFrame.Divider:Hide()
	end

	-- Create a new border for the frame
	DeathRecapFrame:CreateBorder()

	-- Skin the bottom close button (without a parent key)
	local closeButton = select(8, DeathRecapFrame:GetChildren())
	if closeButton then
		closeButton:SkinButton()
	end

	-- Skin the close button at the top right corner
	if DeathRecapFrame.CloseXButton then
		DeathRecapFrame.CloseXButton:SkinCloseButton()
	end

	DeathRecapFrame.styled = true
	return DeathRecapFrame
end

local function SkinRecapEvents(DeathRecapFrame)
	if not DeathRecapFrame then
		return
	end

	local numEvents = NUM_DEATH_RECAP_EVENTS or 0
	for i = 1, numEvents do
		local eventFrame = DeathRecapFrame["Recap" .. i]
		local recap = eventFrame and eventFrame.SpellInfo
		if recap and not recap.styled then
			if recap.IconBorder then
				recap.IconBorder:Hide()
			end
			if recap.Icon then
				recap.Icon:SetTexCoord(unpack(K.TexCoords))
			end
			recap:CreateBorder()
			recap.styled = true
		end
	end
end

-- REASON: Main entry point for Blizzard Death Recap skinning.
C.themes["Blizzard_DeathRecap"] = function()
	if not C["Skins"].BlizzardFrames then
		return
	end

	local DeathRecapFrame = SkinDeathRecapFrame()
	SkinRecapEvents(DeathRecapFrame)
end
