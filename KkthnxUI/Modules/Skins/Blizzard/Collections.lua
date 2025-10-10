local K, C = KkthnxUI[1], KkthnxUI[2]

-- Cache frequently accessed values
local DESIRED_WARDROBE_WIDTH = 1092
local TEXTURE_PATH = "Interface\\DressUpFrame\\DressingRoom"

local function AdjustWardrobeFrame()
	-- Cache global frame lookups
	local wardrobeFrame = _G.WardrobeFrame
	local transmogFrame = _G.WardrobeTransmogFrame

	-- Safety check
	if not wardrobeFrame or not transmogFrame then
		return
	end

	-- Cache frame width values (minimize method calls)
	local initialParentWidth = wardrobeFrame:GetWidth()
	local parentWidthIncrease = DESIRED_WARDROBE_WIDTH - initialParentWidth
	wardrobeFrame:SetWidth(DESIRED_WARDROBE_WIDTH)

	local initialTransmogWidth = transmogFrame:GetWidth()
	local desiredTransmogWidth = initialTransmogWidth + parentWidthIncrease
	transmogFrame:SetWidth(desiredTransmogWidth)

	-- Cache nested frame references
	local insetBG = transmogFrame.Inset.BG
	local modelScene = transmogFrame.ModelScene

	-- Safety check for nested frames
	if not insetBG or not modelScene then
		return
	end

	-- Improve the background texture
	local texturePath = TEXTURE_PATH .. K.Class
	insetBG:SetTexture(texturePath)
	insetBG:SetTexCoord(0.00195312, 0.935547, 0.00195312, 0.978516)
	insetBG:SetHorizTile(false)
	insetBG:SetVertTile(false)

	-- Fix the size of the inset and model scene frames
	local modelSceneWidth = modelScene:GetWidth()
	local insetWidth = K.Round(initialTransmogWidth - modelSceneWidth, 0)
	local insetBgWidth = transmogFrame.Inset.Bg:GetWidth()
	insetBG:SetWidth(insetBgWidth - insetWidth)

	-- Cache final width calculation
	local finalTransmogWidth = transmogFrame:GetWidth()
	modelScene:SetWidth(finalTransmogWidth - insetWidth)

	-- Reposition buttons (cache button references)
	local headButton = transmogFrame.HeadButton
	local handsButton = transmogFrame.HandsButton
	local mainHandButton = transmogFrame.MainHandButton
	local mainHandEnchant = transmogFrame.MainHandEnchantButton
	local secondaryHandButton = transmogFrame.SecondaryHandButton
	local secondaryHandEnchant = transmogFrame.SecondaryHandEnchantButton
	local toggleCheckbox = transmogFrame.ToggleSecondaryAppearanceCheckbox

	headButton:SetPoint("LEFT", 7, 0)
	handsButton:SetPoint("RIGHT", -7, 0)
	mainHandButton:SetPoint("BOTTOM", -26, 23)
	mainHandEnchant:SetPoint("CENTER", -26, -230)
	secondaryHandButton:SetPoint("BOTTOM", 26, 23)
	secondaryHandEnchant:SetPoint("CENTER", 26, -230)
	toggleCheckbox:SetPoint("BOTTOMLEFT", transmogFrame, "BOTTOMLEFT", 474, 15)

	-- Hide the control frame (cache reference)
	local controlFrame = modelScene.ControlFrame
	if controlFrame then
		controlFrame:SetAlpha(0)
		controlFrame:SetScale(0.00001)
	end
end

local function HideTutorialButton()
	if not C["General"].NoTutorialButtons then
		return
	end

	local tutorialButton = _G.PetJournalTutorialButton
	if tutorialButton and tutorialButton.Kill then
		tutorialButton:Kill()
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
