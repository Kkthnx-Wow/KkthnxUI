local K, C = KkthnxUI[1], KkthnxUI[2]

--[[
    KkthnxUI API (Application Programming Interface)
    is a set of functions and tools designed to help developers interact with and extend the KkthnxUI user interface.
    The API provides developers with access to various features and functions of KkthnxUI,
    allowing them to customize and extend the user interface in new and unique ways.
    Whether you're building an addon, developing a plugin, or just looking to customize your KkthnxUI experience,
    the API provides a powerful set of tools to help you achieve your goals.
]]

local getmetatable, select, unpack = getmetatable, select, unpack
local math_min, math_max, math_pi = math.min, math.max, math.pi
local CreateFrame, EnumerateFrames = CreateFrame, EnumerateFrames
local C_AddOns_GetAddOnMetadata = C_AddOns.GetAddOnMetadata
local RegisterStateDriver, UIParent = RegisterStateDriver, UIParent

local CustomCloseButton = "Interface\\AddOns\\KkthnxUI\\Media\\Textures\\CloseButton_32"

-- Utility Functions
local function rad(degrees)
	return degrees * math_pi / 180
end

-- Frame Hiders
do
	BINDING_HEADER_KKTHNXUI = C_AddOns_GetAddOnMetadata(..., "Title")

	K.UIFrameHider = CreateFrame("Frame", nil, UIParent)
	K.UIFrameHider:SetPoint("BOTTOM")
	K.UIFrameHider:SetSize(1, 1)
	K.UIFrameHider:Hide()

	K.PetBattleFrameHider = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
	K.PetBattleFrameHider:SetFrameStrata("LOW")
	RegisterStateDriver(K.PetBattleFrameHider, "visibility", "[petbattle] hide; show")
end

-- Helper to apply background texture
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

	if type(bgColor) == "table" then
		bg:SetVertexColor(unpack(bgColor))
	end

	frame.KKUI_Background = bg
end

-- 1. K.SetBorderColor
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

-- 2. CreateBorder (Wrapper)
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

	kkui_border:SetSize(BorderSize)
	kkui_border:SetTexture(BorderTexture)
	kkui_border:SetOffset(BorderOffset)

	-- Handle Coloring
	local colorToUse = (General.ColorTextures and General.TexturesColor) or BorderColor
	if colorToUse and type(colorToUse) == "table" then
		kkui_border:SetVertexColor(unpack(colorToUse))
	else
		kkui_border:SetVertexColor(1, 1, 1)
	end

	bFrame.KKUI_Border = kkui_border

	-- Add the Background
	AddBackground(bFrame, bgTexture, bgSubLevel, bgLayer, bgPoint, bgColor)

	return bFrame
end

-- 3. CreateBackdrop
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

-- 4. CreateShadow
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

-- Kill Function
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
	"bgLeft",
	"bgRight",
	"Portrait",
	"portrait",
	"ScrollFrameBorder",
	"ScrollUpBorder",
	"ScrollDownBorder",
}

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

-- Create Texture
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

-- Style Button
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

-- Button OnEnter and OnLeave
local function Button_OnEnter(self)
	if not self:IsEnabled() then
		return
	end

	self.KKUI_Border:SetVertexColor(102 / 255, 157 / 255, 255 / 255)
end

local function Button_OnLeave(self)
	K.SetBorderColor(self.KKUI_Border)
end

-- Skin Button
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
	-- Remove the normal, highlight, pushed and disabled textures
	if self.SetNormalTexture and not override then
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

	-- Do not apply custom border if the override argument is true
	self:CreateBorder(bSubLevel, bLayer, bSize, bTexture, bOffset, bColor, bgTexture, bgSubLevel, bgLayer, bgPoint, bgColor)

	-- Hook the OnEnter and OnLeave events
	self:HookScript("OnEnter", Button_OnEnter)
	self:HookScript("OnLeave", Button_OnLeave)
end

-- Skin Close Button
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

-- Skin CheckBox
local function SkinCheckBox(self, forceSaturation)
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

-- Hide Backdrop
local function HideBackdrop(self)
	if self.NineSlice then
		self.NineSlice:SetAlpha(0)
	end

	if self.SetBackdrop then
		self:SetBackdrop(nil)
	end
end

-- Setup Arrow
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

-- Reskin Arrow
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

-- Grab ScrollBar Element
local function GrabScrollBarElement(frame, element)
	local frameName = frame:GetDebugName()
	return frame[element] or frameName and (_G[frameName .. element] or string.find(frameName, element)) or nil
end

-- Skin ScrollBar (continued)
local function SkinScrollBar(self)
	-- Strip the textures from the parent and scrollbar frame
	self:GetParent():StripTextures()
	self:StripTextures()

	-- Get the thumb texture and set its alpha to 0, width to 16, and create a frame for it
	local thumb = GrabScrollBarElement(self, "ThumbTexture") or GrabScrollBarElement(self, "thumbTexture") or self.GetThumbTexture and self:GetThumbTexture()
	if thumb then
		thumb:SetAlpha(0)
		thumb:SetWidth(16)
		self.thumb = thumb

		local bg = CreateFrame("Frame", nil, self)
		-- Create a border for the frame with a dark grey color
		bg:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, { 0.20, 0.20, 0.20 })

		-- Set the position of the frame relative to the thumb texture
		bg:SetPoint("TOPLEFT", thumb, 0, -6)
		bg:SetPoint("BOTTOMRIGHT", thumb, 0, 6)

		-- Assign the frame to the thumb texture's background property
		thumb.bg = bg
	end

	-- Get the up and down arrows from the scrollbar frame and skin them with K.ReskinArrow() function
	local up, down = self:GetChildren()
	K.ReskinArrow(up, "up")
	K.ReskinArrow(down, "down")
end

local function KillEditMode(object)
	object.HighlightSystem = K.Noop
	object.ClearHighlight = K.Noop
end

-- Add API Function
local function addapi(object)
	local mt = getmetatable(object).__index

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

-- Apply API to Existing Frames
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
