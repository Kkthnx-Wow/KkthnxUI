local K, C = KkthnxUI[1], KkthnxUI[2]

-- Globals -> locals
local _G = _G
local type = type

-- Cache frequently accessed values
local DESIRED_WARDROBE_WIDTH = 1092
local TEXTURE_PATH = "Interface\\DressUpFrame\\DressingRoom"

-- WoW frames / funcs (globals -> locals)
local WardrobeFrame = _G.WardrobeFrame
local WardrobeTransmogFrame = _G.WardrobeTransmogFrame
local PetJournalTutorialButton = _G.PetJournalTutorialButton

local function SafeSetPoint(frame, ...)
	if frame and frame.SetPoint then
		frame:ClearAllPoints()
		frame:SetPoint(...)
	end
end

local function AdjustWardrobeFrame()
	-- Re-resolve in case Blizzard loads it after your theme fires
	WardrobeFrame = WardrobeFrame or _G.WardrobeFrame
	WardrobeTransmogFrame = WardrobeTransmogFrame or _G.WardrobeTransmogFrame

	local wardrobeFrame = WardrobeFrame
	local transmogFrame = WardrobeTransmogFrame
	if not wardrobeFrame or not transmogFrame then
		return
	end

	-- If already applied, bail (prevents weird resizing if theme runs twice)
	if wardrobeFrame.__kkui_widened then
		return
	end
	wardrobeFrame.__kkui_widened = true

	-- Parent width
	local initialParentWidth = wardrobeFrame:GetWidth() or 0
	if initialParentWidth <= 0 then
		return
	end

	local parentWidthIncrease = DESIRED_WARDROBE_WIDTH - initialParentWidth
	if parentWidthIncrease == 0 then
		return
	end

	wardrobeFrame:SetWidth(DESIRED_WARDROBE_WIDTH)

	-- Child width
	local initialTransmogWidth = transmogFrame:GetWidth() or 0
	if initialTransmogWidth > 0 then
		transmogFrame:SetWidth(initialTransmogWidth + parentWidthIncrease)
	end

	-- Nested refs (guard everything)
	local inset = transmogFrame.Inset
	local insetBG = inset and inset.BG
	local insetBgFrame = inset and inset.Bg
	local modelScene = transmogFrame.ModelScene
	if not insetBG or not insetBgFrame or not modelScene then
		return
	end

	-- Background texture
	-- NOTE: K.Class must already be set (your UI does). If not, fallback to "".
	local classKey = K.Class or ""
	insetBG:SetTexture(TEXTURE_PATH .. classKey)
	insetBG:SetTexCoord(0.00195312, 0.935547, 0.00195312, 0.978516)
	insetBG:SetHorizTile(false)
	insetBG:SetVertTile(false)

	-- Fix widths: preserve the original inset/model split, but with new transmog width.
	local modelSceneWidth = modelScene:GetWidth() or 0
	local oldInsetWidth = (initialTransmogWidth > 0 and modelSceneWidth > 0) and (initialTransmogWidth - modelSceneWidth) or 0
	if oldInsetWidth < 0 then
		oldInsetWidth = 0
	end

	-- InsetBG width correction (based on Blizzard inset container Bg width)
	local insetBgWidth = insetBgFrame:GetWidth() or 0
	if insetBgWidth > 0 and oldInsetWidth > 0 then
		insetBG:SetWidth(insetBgWidth - oldInsetWidth)
	end

	local finalTransmogWidth = transmogFrame:GetWidth() or 0
	if finalTransmogWidth > 0 and oldInsetWidth > 0 then
		modelScene:SetWidth(finalTransmogWidth - oldInsetWidth)
	end

	-- Reposition buttons (guard each)
	SafeSetPoint(transmogFrame.HeadButton, "LEFT", 7, 0)
	SafeSetPoint(transmogFrame.HandsButton, "RIGHT", -7, 106)
	SafeSetPoint(transmogFrame.MainHandButton, "BOTTOM", -26, 23)
	SafeSetPoint(transmogFrame.MainHandEnchantButton, "CENTER", -26, -230)
	SafeSetPoint(transmogFrame.SecondaryHandButton, "BOTTOM", 26, 23)
	SafeSetPoint(transmogFrame.SecondaryHandEnchantButton, "CENTER", 26, -230)
	SafeSetPoint(transmogFrame.ToggleSecondaryAppearanceCheckbox, "BOTTOMLEFT", transmogFrame, "BOTTOMLEFT", 474, 15)

	-- Hide model controls (guard)
	local controlFrame = modelScene.ControlFrame
	if controlFrame then
		controlFrame:SetAlpha(0)
		controlFrame:SetScale(0.00001)
	end
end

local function HideTutorialButton()
	if not (C and C.General and C.General.NoTutorialButtons) then
		return
	end

	_G.PetJournalTutorialButton:Kill()
end

C.themes["Blizzard_Collections"] = function()
	if not (C and C.Skins and C.Skins.BlizzardFrames) then
		return
	end

	if K.CheckAddOnState("BetterWardrobe") then
		return
	end

	AdjustWardrobeFrame()
	HideTutorialButton()
end
