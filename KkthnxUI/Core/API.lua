--[[-----------------------------------------------------------------------------
Addon: KkthnxUI
Author: Josh "Kkthnx" Russell
Notes:
- Purpose: Core API extension framework for WoW UI objects.
- Combat: Safe for combat use except where explicitly noted (taint hazards).
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local ADDON_NAME = ...

-- ---------------------------------------------------------------------------
-- Locals & Global Caching
-- ---------------------------------------------------------------------------

-- PERF: Cache frequent APIs and globals to reduce table lookups in hot paths.
local _G = _G
local type, tonumber, unpack, select, pairs = type, tonumber, unpack, select, pairs
local getmetatable = getmetatable
local math_min, math_max, math_pi = math.min, math.max, math.pi
local CreateFrame, EnumerateFrames = CreateFrame, EnumerateFrames
local C_AddOns_GetAddOnMetadata = C_AddOns.GetAddOnMetadata
local RegisterStateDriver = RegisterStateDriver
local UIParent = UIParent

-- ---------------------------------------------------------------------------
-- Constants & Configuration
-- ---------------------------------------------------------------------------

local CustomCloseButton = "Interface\\AddOns\\KkthnxUI\\Media\\Textures\\CloseButton_32"

-- ---------------------------------------------------------------------------
-- Utility Functions
-- ---------------------------------------------------------------------------

-- Converts degrees to radians for API rotations.
local function rad(degrees)
	return degrees * math_pi / 180
end

-- ---------------------------------------------------------------------------
-- Frame Hiders
-- ---------------------------------------------------------------------------

do
	BINDING_HEADER_KKTHNXUI = C_AddOns_GetAddOnMetadata(ADDON_NAME, "Title")

	-- NOTE: Generic hider for elements that should never be shown.
	K.UIFrameHider = CreateFrame("Frame", nil, UIParent)
	K.UIFrameHider:SetPoint("BOTTOM")
	K.UIFrameHider:SetSize(1, 1)
	K.UIFrameHider:Hide()

	-- WARNING: Securely hide/show frames based on pet battle state without causing taint.
	K.PetBattleFrameHider = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
	K.PetBattleFrameHider:SetFrameStrata("LOW")
	RegisterStateDriver(K.PetBattleFrameHider, "visibility", "[petbattle] hide; show")
end

-- ---------------------------------------------------------------------------
-- UI Styling: Backgrounds & Borders
-- ---------------------------------------------------------------------------

-- REASON: Consolidated helper to apply consistent background textures and colors.
local function AddBackground(frame, texture, subLevel, layer, point, color)
	if frame.KKUI_Background then
		return
	end

	local Media = C.Media
	local bgTexture = texture or Media.Textures.White8x8Texture
	local bgSubLevel = subLevel or "BACKGROUND"
	local bgLayer = layer or -2
	local bgPoint = point or 0
	local bgColor = color or Media.Backdrops.ColorBackdrop

	local bg = frame:CreateTexture(nil, bgSubLevel, nil, bgLayer)
	bg:SetTexture(bgTexture, true, true)

	-- Safe check for global TexCoords
	if K.TexCoords then
		bg:SetTexCoord(unpack(K.TexCoords))
	end

	bg:SetPoint("TOPLEFT", frame, "TOPLEFT", bgPoint, -bgPoint)
	bg:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -bgPoint, bgPoint)

	-- NOTE: Handle both ColorBackdrop (table) and custom color overrides.
	if type(bgColor) == "table" then
		bg:SetVertexColor(unpack(bgColor))
	end

	frame.KKUI_Background = bg
end

-- REASON: Dynamically updates border colors based on user configuration or defaults.
function K.SetBorderColor(self)
	if not self or type(self) ~= "table" or not self.SetVertexColor then
		return
	end

	local colorTextures = C["General"].ColorTextures
	local texturesColor = C["General"].TexturesColor

	if colorTextures and texturesColor and #texturesColor == 3 then
		local r = math_min(math_max(texturesColor[1], 0), 1)
		local g = math_min(math_max(texturesColor[2], 0), 1)
		local b = math_min(math_max(texturesColor[3], 0), 1)
		self:SetVertexColor(r, g, b)
	else
		self:SetVertexColor(1, 1, 1)
	end
end

-- REASON: High-level wrapper to create a full KkthnxUI-styled frame (border + background).
local function CreateBorder(bFrame, ...)
	if not bFrame or type(bFrame) ~= "table" then
		return nil, "Invalid frame"
	end
	if bFrame.KKUI_Border then
		return bFrame
	end

	-- Explicit unpacking avoids the "spaghetti args" issue
	local bSubLevel, bLayer, bSize, bTexture, bOffset, bColor, bgTexture, bgSubLevel, bgLayer, bgPoint, bgColor = ...

	local General, Media = C.General, C.Media
	local BorderValue = General.BorderStyle or "KkthnxUI"
	local BorderSize = bSize or K.BorderSize or (BorderValue == "KkthnxUI" and 12 or 10)

	-- Create the internal border object
	local kkui_border = K.CreateBorder(bFrame, bSubLevel or "OVERLAY", bLayer or 1)
	if not kkui_border then
		return nil, "Failed to create border"
	end

	local BorderTexture = bTexture or ("Interface\\AddOns\\KkthnxUI\\Media\\Border\\" .. BorderValue .. "\\Border.tga")
	local BorderOffset = bOffset or -4
	local BorderColor = bColor or Media.Borders.ColorBorder

	-- REASON: Ensure the actual texture object is updated with the correct styling.
	kkui_border:SetSize(BorderSize)
	kkui_border:SetTexture(BorderTexture)
	kkui_border:SetOffset(BorderOffset)

	-- Handle Coloring
	local colorToUse = BorderColor
	if General.ColorTextures and type(General.TexturesColor) == "table" then
		colorToUse = General.TexturesColor
	end
	if type(colorToUse) == "table" then
		kkui_border:SetVertexColor(unpack(colorToUse))
	else
		kkui_border:SetVertexColor(1, 1, 1)
	end

	bFrame.KKUI_Border = kkui_border

	-- Add the Background
	AddBackground(bFrame, bgTexture, bgSubLevel, bgLayer, bgPoint, bgColor)

	return bFrame
end

-- REASON: Creates a separate backdrop frame to handle layering and styling without affecting content.
local function CreateBackdrop(bFrame, ...)
	if not bFrame or type(bFrame) ~= "table" then
		return
	end
	if bFrame.KKUI_Backdrop then
		return bFrame.KKUI_Backdrop
	end

	local bPointa, bPointb, bPointc, bPointd, bSubLevel, bLayer, bSize, bTexture, bOffset, bColor, bgTexture, bgSubLevel, bgLayer, bgPoint, bgColor = ...

	local points = { bPointa or 0, bPointb or 0, bPointc or 0, bPointd or 0 }

	local backdrop = CreateFrame("Frame", "$parentBackdrop", bFrame)
	backdrop:SetPoint("TOPLEFT", bFrame, "TOPLEFT", points[1], points[2])
	backdrop:SetPoint("BOTTOMRIGHT", bFrame, "BOTTOMRIGHT", points[3], points[4])

	-- Apply border and background to the new backdrop frame
	CreateBorder(backdrop, bSubLevel, bLayer, bSize, bTexture, bOffset, bColor, bgTexture, bgSubLevel, bgLayer, bgPoint, bgColor)

	backdrop:SetFrameLevel(math_max(0, bFrame:GetFrameLevel() - 1))
	bFrame.KKUI_Backdrop = backdrop

	return bFrame
end

-- ---------------------------------------------------------------------------
-- Visual Effects: Shadows & Glows
-- ---------------------------------------------------------------------------

-- REASON: Applies a glow/shadow effect using the legacy Backdrop system (BackdropTemplate).
local function CreateShadow(frame, useBackdrop)
	if not frame or type(frame) ~= "table" then
		return
	end
	if frame.Shadow then
		return frame.Shadow
	end

	local parentFrame = frame:IsObjectType("Texture") and frame:GetParent() or frame
	local shadow = CreateFrame("Frame", nil, parentFrame, "BackdropTemplate")

	shadow:SetPoint("TOPLEFT", frame, -3, 3)
	shadow:SetPoint("BOTTOMRIGHT", frame, 3, -3)

	local backdrop = {
		edgeFile = C["Media"].Textures.GlowTexture,
		edgeSize = 3,
	}

	-- Apply background if requested
	if useBackdrop then
		backdrop.bgFile = C["Media"].Textures.White8x8Texture
		backdrop.insets = { left = 3, right = 3, top = 3, bottom = 3 }
	end

	shadow:SetBackdrop(backdrop)
	shadow:SetFrameLevel(math_max(parentFrame:GetFrameLevel() - 1, 0))

	if useBackdrop then
		shadow:SetBackdropColor(unpack(C["Media"].Backdrops.ColorBackdrop))
	end
	shadow:SetBackdropBorderColor(0, 0, 0, 0.8)

	frame.Shadow = shadow
	return shadow
end

-- ---------------------------------------------------------------------------
-- UI Utilities: Texture Manipulation
-- ---------------------------------------------------------------------------

-- REASON: Effectively "deletes" an object by hiding it and preventing re-show or event triggers.
local function Kill(object)
	if object.UnregisterAllEvents then
		object:UnregisterAllEvents()
		object:SetParent(K.UIFrameHider)
	else
		object.Show = object.Hide
	end
	object:Hide()
end

-- Strip Textures
local blizzTextures = {
	"Inset",
	"inset",
	"InsetFrame",
	"LeftInset",
	"RightInset",
	"NineSlice",
	"BG",
	"border",
	"Border",
	"Background",
	"BorderFrame",
	"bottomInset",
	"BottomInset",
	"BottomMiddle",
	"MiddleMiddle",
	"TabSpacer",
	"TabSpacer1",
	"TabSpacer2",
	"_RightSeparator",
	"_LeftSeparator",
	"Cover",
	"Border",
	"Background",
	"TopTex",
	"TopLeftTex",
	"TopRightTex",
	"LeftTex",
	"BottomTex",
	"BottomLeftTex",
	"BottomRightTex",
	"RightTex",
	"MiddleTex",
	"Center",
}

-- REASON: Recursively removes Blizzard default textures and frame regions to allow for custom skinning.
-- NOTE: Supports "killing" textures or setting specific alpha/texture values for targeted stripping.
local function StripTextures(object, kill)
	local frameName = object.GetName and object:GetName()

	-- Strip textures from Blizzard frames
	for _, texture in pairs(blizzTextures) do
		local blizzFrame = object[texture] or (frameName and _G[frameName .. texture])
		if blizzFrame then
			StripTextures(blizzFrame, kill) -- Recursively strip textures from Blizzard frames
		end
	end

	-- Strip textures from the given object's regions
	if object.GetNumRegions then -- Check if the given object has regions
		for i = 1, object:GetNumRegions() do -- Iterate through all regions
			local region = select(i, object:GetRegions()) -- Get region at index i

			-- Check if region is a Texture type
			if region and region.IsObjectType and region:IsObjectType("Texture") then
				if kill and type(kill) == "boolean" then -- Kill the texture if boolean true is passed as kill argument
					region:Kill()
				elseif tonumber(kill) then -- Set alpha to 0 for specified texture index
					if kill == 0 then
						region:SetAlpha(0)
					elseif i ~= kill then -- Set texture to empty string for all other indices
						region:SetTexture("")
					end
				else -- Set texture to empty string by default
					region:SetTexture("")
				end
			end
		end
	end
end

-- ---------------------------------------------------------------------------
-- UI Components: Buttons & Textures
-- ---------------------------------------------------------------------------

-- REASON: Standardized texture creation for buttons.
local function CreateTexture(button, noTexture, texturePath, desaturated, vertexColor, setPoints)
	if not noTexture then
		local texture = button:CreateTexture()
		texture:SetTexture(texturePath)
		texture:SetPoint("TOPLEFT", button, "TOPLEFT", setPoints, -setPoints)
		texture:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -setPoints, setPoints)
		texture:SetBlendMode("ADD")

		if desaturated then
			texture:SetDesaturated(true)
		end

		if vertexColor then
			texture:SetVertexColor(unpack(vertexColor))
		end

		return texture
	end
end

-- REASON: Adds standard hover, pushed, and checked states to any button.
local function StyleButton(button, noHover, noPushed, noChecked, setPoints)
	-- setPoints default value is 0
	setPoints = setPoints or 0

	-- Create highlight, pushed, and checked textures for the button if they do not exist
	if button.SetHighlightTexture and not noHover then
		button.hover = CreateTexture(button, noHover, "Interface\\Buttons\\ButtonHilight-Square", false, nil, setPoints)
		button:SetHighlightTexture(button.hover)
	end

	if button.SetPushedTexture and not noPushed then
		button.pushed = CreateTexture(button, noPushed, "Interface\\Buttons\\ButtonHilight-Square", true, { 246 / 255, 196 / 255, 66 / 255 }, setPoints)
		button:SetPushedTexture(button.pushed)
	end

	if button.SetCheckedTexture and not noChecked then
		button.checked = CreateTexture(button, noChecked, "Interface\\Buttons\\CheckButtonHilight", false, nil, setPoints)
		button:SetCheckedTexture(button.checked)
	end

	local name = button.GetName and button:GetName()
	local cooldown = name and _G[name .. "Cooldown"]

	if cooldown then
		cooldown:ClearAllPoints()
		cooldown:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
		cooldown:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
		cooldown:SetDrawEdge(false)
		cooldown:SetSwipeColor(0, 0, 0, 1)
	end
end

-- ---------------------------------------------------------------------------
-- Internal Handlers
-- ---------------------------------------------------------------------------

-- NOTE: Used to highlight borders on mouse interactions.
local function Button_OnEnter(self)
	if not self:IsEnabled() then
		return
	end

	local border = self.KKUI_Border
	if border and border.SetVertexColor then
		border:SetVertexColor(102 / 255, 157 / 255, 255 / 255)
	end
end

local function Button_OnLeave(self)
	local border = self.KKUI_Border
	if border then
		K.SetBorderColor(border)
	end
end

-- ---------------------------------------------------------------------------
-- Button Skinning
-- ---------------------------------------------------------------------------

-- REASON: Comprehensive Blizzard button skinning; handles texture stripping, borders, and interaction hooks.
local blizzRegions = {
	"Left",
	"Middle",
	"Right",
	"Mid",
	"LeftDisabled",
	"MiddleDisabled",
	"RightDisabled",
	"TopLeft",
	"TopRight",
	"BottomLeft",
	"BottomRight",
	"TopMiddle",
	"MiddleLeft",
	"MiddleRight",
	"BottomMiddle",
	"MiddleMiddle",
	"TabSpacer",
	"TabSpacer1",
	"TabSpacer2",
	"_RightSeparator",
	"_LeftSeparator",
	"Cover",
	"Border",
	"Background",
	"TopTex",
	"TopLeftTex",
	"TopRightTex",
	"LeftTex",
	"BottomTex",
	"BottomLeftTex",
	"BottomRightTex",
	"RightTex",
	"MiddleTex",
	"Center",
}

local function SkinButton(self, override, ...)
	local bSubLevel, bLayer, bSize, bTexture, bOffset, bColor, bgTexture, bgSubLevel, bgLayer, bgPoint, bgColor = ...

	-- NOTE: Use 0 to safely clear textures as nil/"" can cause issues on some game clients.
	if self.SetNormalTexture and not override then
		-- SetNormalTexture(nil/"") can error on some clients; 0 is a common safe clear
		self:SetNormalTexture(0)
	end

	if self.SetHighlightTexture then
		self:SetHighlightTexture(0)
	end

	if self.SetPushedTexture then
		self:SetPushedTexture(0)
	end

	if self.SetDisabledTexture then
		self:SetDisabledTexture(0)
	end

	-- Hide all regions defined in the blizzRegions table
	for _, region in pairs(blizzRegions) do
		if self[region] then
			self[region]:SetAlpha(0)
			self[region]:Hide()
		end
	end

	-- Apply custom border (override only affects whether we clear the normal texture)
	self:CreateBorder(bSubLevel, bLayer, bSize, bTexture, bOffset, bColor, bgTexture, bgSubLevel, bgLayer, bgPoint, bgColor)

	-- Hook the OnEnter and OnLeave events
	self:HookScript("OnEnter", Button_OnEnter)
	self:HookScript("OnLeave", Button_OnLeave)
end

-- ---------------------------------------------------------------------------
-- Specialized UI Skinning
-- ---------------------------------------------------------------------------

-- REASON: Standardizes the appearance and positioning of close buttons.
local function SkinCloseButton(self, parent, xOffset, yOffset)
	-- Define the parent frame and x,y offset of the close button
	parent = parent or self:GetParent()
	xOffset = xOffset or -6
	yOffset = yOffset or -6

	-- Set the size of the close button and its position relative to the parent frame
	self:SetSize(16, 16)
	self:ClearAllPoints()
	self:SetPoint("TOPRIGHT", parent, "TOPRIGHT", xOffset, yOffset)

	-- Remove any textures that may already be applied to the button
	self:StripTextures()
	-- Check if there is a Border attribute, if so set its alpha to 0
	if self.Border then
		self.Border:SetAlpha(0)
	end

	-- Create a border for the button with specific color and alpha values
	self:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, { 0.85, 0.25, 0.25 })
	-- Apply the 'StyleButton' function to the button
	self:StyleButton()

	-- Remove the default disabled texture
	self:SetDisabledTexture("")
	-- Get the disabled texture and set its color and draw layer
	local dis = self:GetDisabledTexture()
	dis:SetVertexColor(0, 0, 0, 0.4)
	dis:SetDrawLayer("OVERLAY")
	dis:SetAllPoints()

	-- Create a texture for the button
	local tex = self:CreateTexture()
	-- Set the texture to CustomCloseButton
	tex:SetTexture(CustomCloseButton)
	-- Set the texture to cover the entire button
	tex:SetAllPoints()
	self.__texture = tex
end

-- REASON: Standardizes checkbox appearance with a custom backdrop and checkmark.
local function SkinCheckBox(self, forceSaturation)
	-- SetNormalTexture(nil/"") can error on some clients; 0 is a common safe clear
	self:SetNormalTexture(0)

	local bg = CreateFrame("Frame", nil, self, "BackdropTemplate")
	bg:SetAllPoints(self)
	bg:SetFrameLevel(self:GetFrameLevel())
	bg:CreateBorder()
	self.bg = bg

	self:SetHighlightTexture("Interface\\Buttons\\ButtonHilight-Square")
	local hl = self:GetHighlightTexture()
	hl:SetAllPoints(bg)

	self:SetPushedTexture("Interface\\Buttons\\ButtonHilight-Square")
	local pushed = self:GetPushedTexture()
	pushed:SetAllPoints(bg)
	pushed:SetVertexColor(246 / 255, 196 / 255, 66 / 255)

	local ch = self:GetCheckedTexture()
	ch:SetAtlas("checkmark-minimal")
	ch:SetPoint("TOPLEFT", bg, "TOPLEFT", -3, 3)
	ch:SetPoint("BOTTOMRIGHT", bg, "BOTTOMRIGHT", 3, -3)

	self.forceSaturation = forceSaturation
end

-- REASON: Standardizes editbox appearance by stripping textures and adding a border.
local function SkinEditBox(self, height, width)
	local frameName = self.GetName and self:GetName()
	for _, region in pairs(blizzRegions) do
		region = frameName and _G[frameName .. region] or self[region]
		if region then
			region:SetAlpha(0)
		end
	end

	local bg = CreateFrame("Frame", nil, self)
	bg:SetFrameLevel(self:GetFrameLevel())
	bg:SetPoint("TOPLEFT", -2, 0)
	bg:SetPoint("BOTTOMRIGHT", 0, 0)
	bg:CreateBorder()
	self.__bg = bg

	if height then
		self:SetHeight(height)
	end

	if width then
		self:SetWidth(width)
	end
end

-- REASON: Utility to hide standard Blizzard backdrop elements (NineSlice, etc.).
local function HideBackdrop(self)
	if self.NineSlice then
		self.NineSlice:SetAlpha(0)
	end

	if self.SetBackdrop then
		self:SetBackdrop(nil)
	end
end

-- ---------------------------------------------------------------------------
-- UI Utilities: Arrows & Navigation
-- ---------------------------------------------------------------------------

-- REASON: Standardizes the appearance and rotation of arrow textures.
local arrowDegree = {
	["up"] = 0,
	["down"] = 180,
	["left"] = 90,
	["right"] = -90,
}

function K.SetupArrow(self, direction)
	self:SetTexture(C["Media"].Textures.ArrowTexture)
	self:SetRotation(rad(arrowDegree[direction]))
end

-- REASON: High-level wrapper to skin an arrow button.
function K.ReskinArrow(self, direction)
	self:StripTextures()
	self:SetSize(16, 16)
	self:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, { 0.20, 0.20, 0.20 })
	self:StyleButton()

	self:SetDisabledTexture("Interface\\ChatFrame\\ChatFrameBackground")
	local dis = self:GetDisabledTexture()
	dis:SetVertexColor(0, 0, 0, 0.3)
	dis:SetDrawLayer("OVERLAY")
	dis:SetAllPoints()

	local tex = self:CreateTexture(nil, "ARTWORK")
	tex:SetAllPoints()
	K.SetupArrow(tex, direction)
	self.__texture = tex
end

-- ---------------------------------------------------------------------------
-- ScrollBar Skinning
-- ---------------------------------------------------------------------------

-- REASON: Locates internal scrollbar elements (up/down/thumb) reliably.
local function GrabScrollBarElement(frame, element)
	local frameName = frame:GetDebugName()
	return frame[element] or (frameName and _G[frameName .. element]) or nil
end

-- REASON: Comprehensive scrollbar skinning; handles thumb styling and arrow reskinning.
local function SkinScrollBar(self)
	-- NOTE: Standardize scrollbar width and texture transparency.
	self:GetParent():StripTextures()
	self:StripTextures()

	local thumb = GrabScrollBarElement(self, "ThumbTexture") or GrabScrollBarElement(self, "thumbTexture") or self.GetThumbTexture and self:GetThumbTexture()
	if thumb and (type(thumb) ~= "table" or not thumb.SetAlpha) then
		thumb = nil
	end
	if thumb then
		thumb:SetAlpha(0)
		thumb:SetWidth(16)
		self.thumb = thumb

		local bg = CreateFrame("Frame", nil, self)
		bg:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, { 0.20, 0.20, 0.20 })

		-- Set the position of the frame relative to the thumb texture
		bg:SetPoint("TOPLEFT", thumb, 0, -6)
		bg:SetPoint("BOTTOMRIGHT", thumb, 0, 6)

		-- Assign the frame to the thumb texture's background property
		thumb.bg = bg
	end

	-- NOTE: Skin the up/down buttons using standardized arrow logic.
	local up, down = self:GetChildren()
	K.ReskinArrow(up, "up")
	K.ReskinArrow(down, "down")
end

local function KillEditMode(object)
	object.HighlightSystem = K.Noop
	object.ClearHighlight = K.Noop
end

-- ---------------------------------------------------------------------------
-- API Injection
-- ---------------------------------------------------------------------------

-- REASON: Injects KkthnxUI methods into frame metatables for object-oriented usage.
local function addapi(object)
	local meta = getmetatable(object)
	local mt = meta and meta.__index
	if not mt then
		return
	end

	if not mt.CreateBorder then
		mt.CreateBorder = CreateBorder
	end
	if not mt.CreateBackdrop then
		mt.CreateBackdrop = CreateBackdrop
	end
	if not mt.CreateShadow then
		mt.CreateShadow = CreateShadow
	end
	if not mt.Kill then
		mt.Kill = Kill
	end
	if not mt.SkinButton then
		mt.SkinButton = SkinButton
	end
	if not mt.StripTextures then
		mt.StripTextures = StripTextures
	end
	if not mt.StyleButton then
		mt.StyleButton = StyleButton
	end
	if not mt.SkinCloseButton then
		mt.SkinCloseButton = SkinCloseButton
	end
	if not mt.SkinCheckBox then
		mt.SkinCheckBox = SkinCheckBox
	end
	if not mt.SkinEditBox then
		mt.SkinEditBox = SkinEditBox
	end
	if not mt.SkinScrollBar then
		mt.SkinScrollBar = SkinScrollBar
	end
	if not mt.HideBackdrop then
		mt.HideBackdrop = HideBackdrop
	end
	if not mt.KillEditMode then
		mt.KillEditMode = KillEditMode
	end
end

-- ---------------------------------------------------------------------------
-- Initialization
-- ---------------------------------------------------------------------------

-- NOTE: Automatically apply the API to all existing frames and common UI objects.
local handled = { Frame = true }
local object = CreateFrame("Frame")
addapi(object)
addapi(object:CreateTexture())
addapi(object:CreateFontString())
addapi(object:CreateMaskTexture())

object = EnumerateFrames()
while object do
	if not object:IsForbidden() and not handled[object:GetObjectType()] then
		addapi(object)
		handled[object:GetObjectType()] = true
	end

	object = EnumerateFrames(object)
end

addapi(_G.GameFontNormal) -- Add API to `CreateFont` objects without actually creating one
addapi(CreateFrame("ScrollFrame")) -- Hacky fix for issue on 7.1 PTR where scroll frames no longer seem to inherit the methods from the 'Frame' widget
