local K, C = KkthnxUI[1], KkthnxUI[2]

local function AdjustWardrobeFrame()
	local WardrobeFrame = _G["WardrobeFrame"]
	local WardrobeTransmogFrame = _G["WardrobeTransmogFrame"]

	-- Increase the width of the parent frames
	local initialParentFrameWidth = WardrobeFrame:GetWidth()
	local desiredParentFrameWidth = 1092
	local parentFrameWidthIncrease = desiredParentFrameWidth - initialParentFrameWidth
	WardrobeFrame:SetWidth(desiredParentFrameWidth)

	local initialTransmogFrameWidth = WardrobeTransmogFrame:GetWidth()
	local desiredTransmogFrameWidth = initialTransmogFrameWidth + parentFrameWidthIncrease
	WardrobeTransmogFrame:SetWidth(desiredTransmogFrameWidth)

	-- Improve the background texture
	WardrobeTransmogFrame.Inset.BG:SetTexture("Interface\\DressUpFrame\\DressingRoom" .. K.Class)
	WardrobeTransmogFrame.Inset.BG:SetTexCoord(0.00195312, 0.935547, 0.00195312, 0.978516)
	WardrobeTransmogFrame.Inset.BG:SetHorizTile(false)
	WardrobeTransmogFrame.Inset.BG:SetVertTile(false)

	-- Fix the size of the inset and model scene frames
	local insetWidth = K.Round(initialTransmogFrameWidth - WardrobeTransmogFrame.ModelScene:GetWidth(), 0)
	WardrobeTransmogFrame.Inset.BG:SetWidth(WardrobeTransmogFrame.Inset.Bg:GetWidth() - insetWidth)
	WardrobeTransmogFrame.ModelScene:SetWidth(WardrobeTransmogFrame:GetWidth() - insetWidth)

	-- Reposition the buttons and checkboxes
	WardrobeTransmogFrame.HeadButton:SetPoint("LEFT", 7, 0)
	WardrobeTransmogFrame.HandsButton:SetPoint("RIGHT", -7, 0)
	WardrobeTransmogFrame.MainHandButton:SetPoint("BOTTOM", -26, 23)
	WardrobeTransmogFrame.MainHandEnchantButton:SetPoint("CENTER", -26, -230)
	WardrobeTransmogFrame.SecondaryHandButton:SetPoint("BOTTOM", 26, 23)
	WardrobeTransmogFrame.SecondaryHandEnchantButton:SetPoint("CENTER", 26, -230)
	WardrobeTransmogFrame.ToggleSecondaryAppearanceCheckbox:SetPoint("BOTTOMLEFT", WardrobeTransmogFrame, "BOTTOMLEFT", 474, 15)

	-- Hide the control frame
	WardrobeTransmogFrame.ModelScene.ControlFrame:SetAlpha(0)
	WardrobeTransmogFrame.ModelScene.ControlFrame:SetScale(0.00001)
end

local function HideTutorialButton()
	if C["General"].NoTutorialButtons then
		_G.PetJournalTutorialButton:Kill()
	end
end

C.themes["Blizzard_Collections"] = function()
	if not C["Skins"].BlizzardFrames then
		return
	end

	if K.CheckAddOnState("BetterWardrobe") then
		return
	end

	AdjustWardrobeFrame()
	HideTutorialButton()
end
