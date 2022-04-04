local K, C = unpack(KkthnxUI)

local _G = _G

C.themes["Blizzard_Collections"] = function()
    if K.CheckAddOnState("BetterWardrobe") then
        return
    end

	local WardrobeFrame = _G["WardrobeFrame"]
	local WardrobeTransmogFrame = _G["WardrobeTransmogFrame"]
	local initialParentFrameWidth = WardrobeFrame:GetWidth() -- Expecting 965
	local desiredParentFrameWidth = 1092
	local parentFrameWidthIncrease = desiredParentFrameWidth - initialParentFrameWidth

	WardrobeFrame:SetWidth(desiredParentFrameWidth)

	local initialTransmogFrameWidth = WardrobeTransmogFrame:GetWidth()
	local desiredTransmogFrameWidth = initialTransmogFrameWidth + parentFrameWidthIncrease
	WardrobeTransmogFrame:SetWidth(desiredTransmogFrameWidth)

	-- Insert better BG
	WardrobeTransmogFrame.Inset.BG:SetTexture("Interface\\DressUpFrame\\DressingRoom"..K.Class)
	WardrobeTransmogFrame.Inset.BG:SetTexCoord(0.00195312, 0.935547, 0.00195312, 0.978516)
	WardrobeTransmogFrame.Inset.BG:SetHorizTile(false)
	WardrobeTransmogFrame.Inset.BG:SetVertTile(false)

	-- These frames are built using absolute sizes instead of relative points for some reason. Let's stick with that..
	local insetWidth = K.Round(initialTransmogFrameWidth - WardrobeTransmogFrame.ModelScene:GetWidth(), 0)
	WardrobeTransmogFrame.Inset.BG:SetWidth(WardrobeTransmogFrame.Inset.Bg:GetWidth() - insetWidth)
	WardrobeTransmogFrame.ModelScene:SetWidth(WardrobeTransmogFrame:GetWidth() - insetWidth)

	-- Move HEADSLOT -- Other slots in the left column are attached relative to it
	WardrobeTransmogFrame.HeadButton:SetPoint("LEFT", 7, 0)

	-- Move HANDSSLOT -- Other slots in the right column are attached relative to it
	WardrobeTransmogFrame.HandsButton:SetPoint("RIGHT", -7, 0)

	-- Move MAINHANDSLOT
	WardrobeTransmogFrame.MainHandButton:SetPoint("BOTTOM", -26, 23)
	WardrobeTransmogFrame.MainHandEnchantButton:SetPoint("CENTER", -26, -230)

	-- Move SECONDARYHANDSLOT
	WardrobeTransmogFrame.SecondaryHandButton:SetPoint("BOTTOM", 26, 23)
	WardrobeTransmogFrame.SecondaryHandEnchantButton:SetPoint("CENTER", 26, -230)

	-- Move Separate Shoulder checkbox
	WardrobeTransmogFrame.ToggleSecondaryAppearanceCheckbox:SetPoint("BOTTOMLEFT", WardrobeTransmogFrame, "BOTTOMLEFT", 474, 15)

	WardrobeTransmogFrame.ModelScene.ControlFrame:SetAlpha(0)
	WardrobeTransmogFrame.ModelScene.ControlFrame:SetScale(0.00001)

	if C["General"].NoTutorialButtons then
		_G.PetJournalTutorialButton:Kill()
	end
end