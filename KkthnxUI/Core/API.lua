local K, C = unpack(KkthnxUI)

-- Application Programming Interface for KkthnxUI (API)

local _G = _G
local assert = _G.assert
local getmetatable = _G.getmetatable
local select = _G.select

local CreateFrame = _G.CreateFrame
local EnumerateFrames = _G.EnumerateFrames
local GetAddOnMetadata = _G.GetAddOnMetadata
local RegisterStateDriver = _G.RegisterStateDriver
local UIParent = _G.UIParent

local CustomCloseButton = "Interface\\AddOns\\KkthnxUI\\Media\\Textures\\CloseButton_32"

do
	BINDING_HEADER_KKTHNXUI = GetAddOnMetadata(..., "Title")

	K.UIFrameHider = CreateFrame("Frame")
	K.UIFrameHider:Hide()

	K.PetBattleFrameHider = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
	K.PetBattleFrameHider:SetAllPoints()
	K.PetBattleFrameHider:SetFrameStrata("LOW")
	RegisterStateDriver(K.PetBattleFrameHider, "visibility", "[petbattle] hide; show")
end

do
	function K.SetBorderColor(self)
		if C["General"].ColorTextures then
			self:SetVertexColor(C["General"].TexturesColor[1], C["General"].TexturesColor[2], C["General"].TexturesColor[3])
		else
			self:SetVertexColor(1, 1, 1)
		end
	end
end

-- CreateBorder function: creates a border and background for the passed frame (bFrame)
-- bSubLevel, bLayer, bSize, bTexture, bOffset, bRed, bGreen, bBlue, bAlpha, bgTexture, bgSubLevel, bgLayer, bgPoint, bgRed, bgGreen, bgBlue, bgAlpha are optional arguments to customize the appearance of the border and background
local function CreateBorder(bFrame, ...)
	local bSubLevel, bLayer, bSize, bTexture, bOffset, bRed, bGreen, bBlue, bAlpha, bgTexture, bgSubLevel, bgLayer, bgPoint, bgRed, bgGreen, bgBlue, bgAlpha = ...
	-- Border
	local BorderSubLevel = bSubLevel or "OVERLAY" -- Sublevel of the border, default is "OVERLAY"
	local BorderLayer = bLayer or 1 -- Layer of the border, default is 1
	local BorderValue = C["General"].BorderStyle.Value or "KkthnxUI" -- Border style value, default is "KkthnxUI"
	local BorderSize

	if BorderValue == "KkthnxUI" then -- Size of the border, default is 12
		BorderSize = bSize or 12
	else
		BorderSize = bSize or 10
	end

	if not bFrame.KKUI_Border then -- check if the frame already has a border
		local BorderTexture = bTexture or ("Interface\\AddOns\\KkthnxUI\\Media\\Border\\" .. BorderValue .. "\\Border.tga") -- texture of the border, default is "Interface\\AddOns\\KkthnxUI\\Media\\Border\\" .. BorderValue .. "\\Border.tga"
		local BorderOffset = bOffset or -4 -- offset of the border, default is -4
		local BorderRed = bRed or C["Media"].Borders.ColorBorder[1] -- red color of the border, default is C["Media"].Borders.ColorBorder[1]
		local BorderGreen = bGreen or C["Media"].Borders.ColorBorder[2] -- green color of the border, default is C["Media"].Borders.ColorBorder[2]
		local BorderBlue = bBlue or C["Media"].Borders.ColorBorder[3] -- blue color of the border, default is C["Media"].Borders.ColorBorder[3]
		local BorderAlpha = bAlpha or 1 -- alpha of the border, default is 1

		-- Create Our Border
		local kkui_border = K.CreateBorder(bFrame, BorderSubLevel, BorderLayer)
		kkui_border:SetSize(BorderSize) -- set the size of the border
		kkui_border:SetTexture(BorderTexture) -- set the texture of the border
		kkui_border:SetOffset(BorderOffset) -- set the offset of the border
		if C["General"].ColorTextures then -- check if C["General"].ColorTextures is true
			kkui_border:SetVertexColor(C["General"].TexturesColor[1], C["General"].TexturesColor[2], C["General"].TexturesColor[3])
		else
			kkui_border:SetVertexColor(BorderRed, BorderGreen, BorderBlue, BorderAlpha)
		end

		bFrame.KKUI_Border = kkui_border -- save the border as a property of the frame so that it can be referenced later on.
	end

	if not bFrame.KKUI_Background then -- check if the frame already has a background
		local BackgroundTexture = bgTexture or C["Media"].Textures.White8x8Texture -- texture of the background, default is C["Media"].Textures.White8x8Texture
		local BackgroundSubLevel = bgSubLevel or "BACKGROUND" -- sub-level of the background, default is "BACKGROUND"
		local BackgroundLayer = bgLayer or -2 -- layer of the background, default is -2
		local BackgroundPoint = bgPoint or 0 -- point of the background, default is 0
		local BackgroundRed = bgRed or C["Media"].Backdrops.ColorBackdrop[1] -- red color of the background, default is C["Media"].Backdrops.ColorBackdrop[1]
		local BackgroundGreen = bgGreen or C["Media"].Backdrops.ColorBackdrop[2] -- green color of the background, default is C["Media"].Backdrops.ColorBackdrop[2]
		local BackgroundBlue = bgBlue or C["Media"].Backdrops.ColorBackdrop[3] -- blue color of the background, default is C["Media"].Backdrops.ColorBackdrop[3]
		local BackgroundAlpha = bgAlpha or C["Media"].Backdrops.ColorBackdrop[4] -- alpha of the background, default is C["Media"].Backdrops.ColorBackdrop[4]

		-- Create Our Background
		local kkui_background = bFrame:CreateTexture(nil, BackgroundSubLevel, nil, BackgroundLayer) -- create the background texture
		kkui_background:SetTexture(BackgroundTexture, true, true) -- set the texture of the background
		kkui_background:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4]) -- set the texture coordinates of the background
		kkui_background:SetPoint("TOPLEFT", bFrame, "TOPLEFT", BackgroundPoint, -BackgroundPoint) -- set the position of the background
		kkui_background:SetPoint("BOTTOMRIGHT", bFrame, "BOTTOMRIGHT", -BackgroundPoint, BackgroundPoint) -- set the size of the background
		kkui_background:SetVertexColor(BackgroundRed, BackgroundGreen, BackgroundBlue, BackgroundAlpha) -- set the color of the background

		bFrame.KKUI_Background = kkui_background -- save the background as a property of the frame so that it can be referenced later on.
	end

	return bFrame, ...
end

-- Simple Create Backdrop.
local function CreateBackdrop(bFrame, bPointa, bPointb, bPointc, bPointd, bSubLevel, bLayer, bSize, bTexture, bOffset, bRed, bGreen, bBlue, bAlpha, bgTexture, bgSubLevel, bgLayer, bgPoint, bgRed, bgGreen, bgBlue, bgAlpha)
	if bFrame.KKUI_Backdrop then
		return
	end

	local BorderPointA = bPointa or 0 -- The first point of the border's position.
	local BorderPointB = bPointb or 0 -- The second point of the border's position.
	local BorderPointC = bPointc or 0 -- The third point of the border's position.
	local BorderPointD = bPointd or 0 -- The fourth point of the border's position.

	local kkui_backdrop = CreateFrame("Frame", "$parentBackdrop", bFrame) -- Create the backdrop frame.
	kkui_backdrop:SetPoint("TOPLEFT", bFrame, "TOPLEFT", BorderPointA, BorderPointB) -- Set the first point of the border's position.
	kkui_backdrop:SetPoint("BOTTOMRIGHT", bFrame, "BOTTOMRIGHT", BorderPointC, BorderPointD) -- Set the second point of the border's position.
	kkui_backdrop:CreateBorder(bSubLevel, bLayer, bSize, bTexture, bOffset, bRed, bGreen, bBlue, bAlpha, bgTexture, bgSubLevel, bgLayer, bgPoint, bgRed, bgGreen, bgBlue, bgAlpha) -- Create the border.

	if bFrame:GetFrameLevel() - 1 >= 0 then
		kkui_backdrop:SetFrameLevel(bFrame:GetFrameLevel())
	else
		kkui_backdrop:SetFrameLevel(0)
	end

	bFrame.KKUI_Backdrop = kkui_backdrop -- Save the backdrop as a property of the frame so that it can be referenced later on.
end

local function CreateShadow(f, bd)
	-- check if the shadow already exists, return if it does
	if f.Shadow then
		return
	end

	-- get the parent frame if the passed object is a texture
	local frame = f
	if f:GetObjectType() == "Texture" then
		frame = f:GetParent()
	end

	-- get the frame level of the parent frame
	local lvl = frame:GetFrameLevel()

	-- create the shadow frame using the BackdropTemplate
	f.Shadow = CreateFrame("Frame", nil, frame, "BackdropTemplate")

	-- set the position and size of the shadow frame
	f.Shadow:SetPoint("TOPLEFT", f, -3, 3)
	f.Shadow:SetPoint("BOTTOMRIGHT", f, 3, -3)

	-- set the backdrop of the shadow frame
	if bd then
		f.Shadow:SetBackdrop({
			bgFile = C["Media"].Textures.White8x8Texture,
			edgeFile = C["Media"].Textures.GlowTexture,
			edgeSize = 3,
			insets = { left = 3, right = 3, top = 3, bottom = 3 },
		})
	else
		f.Shadow:SetBackdrop({
			edgeFile = C["Media"].Textures.GlowTexture,
			edgeSize = 3,
		})
	end

	-- set the frame level of the shadow frame to be one lower than the parent frame
	f.Shadow:SetFrameLevel(lvl == 0 and 0 or lvl - 1)

	-- set the background color of the shadow frame if the bd argument is true
	if bd then
		f.Shadow:SetBackdropColor(C["Media"].Backdrops.ColorBackdrop[1], C["Media"].Backdrops.ColorBackdrop[2], C["Media"].Backdrops.ColorBackdrop[3], C["Media"].Backdrops.ColorBackdrop[4])
	end

	-- set the border color of the shadow frame
	f.Shadow:SetBackdropBorderColor(0, 0, 0, 0.8)

	-- return the created shadow frame
	return f.Shadow
end

-- Its A Killer.
local function Kill(object)
	-- Check if the object has an "UnregisterAllEvents" method
	if object.UnregisterAllEvents then
		-- Unregister all events for the object
		object:UnregisterAllEvents()
		-- Set the object's parent to K.UIFrameHider (likely a hidden frame used for hiding objects)
		object:SetParent(K.UIFrameHider)
	else
		-- If the object does not have an "UnregisterAllEvents" method, set its "Show" method to its "Hide" method
		object.Show = object.Hide
	end
	-- Hide the object
	object:Hide()
end

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

-- Strips textures from a given object, and optionally kills or sets alpha to 0 for the specified texture.
-- @param object The object to strip textures from.
-- @param kill If true, kills the texture. If a number, sets alpha to 0 for the specified texture index. Otherwise, sets texture to empty string.
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

local function StyleButton(button, noHover, noPushed, noChecked, setPoints)
	-- setPoints default value is 0
	setPoints = setPoints or 0

	-- Create highlight texture for the button if it does not exist
	if button.SetHighlightTexture and not button.hover and not noHover then
		local hover = button:CreateTexture()
		hover:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
		hover:SetPoint("TOPLEFT", button, "TOPLEFT", setPoints, -setPoints)
		hover:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -setPoints, setPoints)
		hover:SetBlendMode("ADD")
		button:SetHighlightTexture(hover)
		button.hover = hover
	end

	-- Create pushed texture for the button if it does not exist
	if button.SetPushedTexture and not button.pushed and not noPushed then
		local pushed = button:CreateTexture()
		pushed:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
		pushed:SetDesaturated(true)
		pushed:SetVertexColor(246 / 255, 196 / 255, 66 / 255)
		pushed:SetPoint("TOPLEFT", button, "TOPLEFT", setPoints, -setPoints)
		pushed:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -setPoints, setPoints)
		pushed:SetBlendMode("ADD")
		button:SetPushedTexture(pushed)
		button.pushed = pushed
	end

	-- Create checked texture for the button if it does not exist
	if button.SetCheckedTexture and not button.checked and not noChecked then
		local checked = button:CreateTexture()
		checked:SetTexture("Interface\\Buttons\\CheckButtonHilight")
		checked:SetPoint("TOPLEFT", button, "TOPLEFT", setPoints, -setPoints)
		checked:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -setPoints, setPoints)
		checked:SetBlendMode("ADD")
		button:SetCheckedTexture(checked)
		button.checked = checked
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

-- Handle button
local function Button_OnEnter(self)
	if not self:IsEnabled() then
		return
	end

	self.KKUI_Border:SetVertexColor(102 / 255, 157 / 255, 255 / 255)
end

local function Button_OnLeave(self)
	K.SetBorderColor(self.KKUI_Border)
end

local blizzRegions = {
	"Left",
	"Middle",
	"Right",
	"TopLeft",
	"TopRight",
	"BottomLeft",
	"BottomRight",
	"Background",
	"Border",
	"Center",
}

local function SkinButton(self, override, ...)
	local bSubLevel, bLayer, bSize, bTexture, bOffset, bRed, bGreen, bBlue, bAlpha, bgTexture, bgSubLevel, bgLayer, bgPoint, bgRed, bgGreen, bgBlue, bgAlpha = ...
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
	self:CreateBorder(bSubLevel, bLayer, bSize, bTexture, bOffset, bRed, bGreen, bBlue, bAlpha, bgTexture, bgSubLevel, bgLayer, bgPoint, bgRed, bgGreen, bgBlue, bgAlpha)

	-- Hook the OnEnter and OnLeave events
	self:HookScript("OnEnter", Button_OnEnter)
	self:HookScript("OnLeave", Button_OnLeave)
end

-- Handle close button
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
	self:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 0.85, 0.25, 0.25)
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

local function SkinCheckBox(self, forceSaturation)
	self:SetNormalTexture(0)
	self:SetPushedTexture(0)

	local bg = CreateFrame("Frame", nil, self, "BackdropTemplate")
	bg:SetAllPoints(self)
	bg:SetFrameLevel(self:GetFrameLevel())
	bg:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 0.20, 0.20, 0.20)
	self.bg = bg

	self:SetHighlightTexture("")
	local hl = self:GetHighlightTexture()
	hl:SetAllPoints(bg)
	hl:SetVertexColor(K.r, K.g, K.b, 0.25)

	local ch = self:GetCheckedTexture()
	ch:SetPoint("TOPLEFT", self, "TOPLEFT", -5, 5)
	ch:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 5, -5)
	ch:SetAtlas("checkmark-minimal")
	ch:SetDesaturated(true)
	ch:SetTexCoord(0, 1, 0, 1)
	ch:SetVertexColor(K.r, K.g, K.b)

	self.forceSaturation = forceSaturation
end

-- Handle arrows
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

function K.ReskinArrow(self, direction)
	self:StripTextures()
	self:SetSize(16, 16)
	self:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 0.20, 0.20, 0.20)
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

local function GrabScrollBarElement(frame, element)
	local frameName = frame:GetDebugName()
	return frame[element] or frameName and (_G[frameName .. element] or string.find(frameName, element)) or nil
end

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
		bg:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, 0.20, 0.20, 0.20)

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

local function HideBackdrop(self)
	if self.NineSlice then
		self.NineSlice:SetAlpha(0)
	end

	if self.SetBackdrop then
		self:SetBackdrop(nil)
	end
end

local function addapi(object)
	local mt = getmetatable(object).__index

	if not object.CreateBorder then
		mt.CreateBorder = CreateBorder
	end

	if not object.CreateBackdrop then
		mt.CreateBackdrop = CreateBackdrop
	end

	if not object.CreateShadow then
		mt.CreateShadow = CreateShadow
	end

	if not object.Kill then
		mt.Kill = Kill
	end

	if not object.SkinButton then
		mt.SkinButton = SkinButton
	end

	if not object.StripTextures then
		mt.StripTextures = StripTextures
	end

	if not object.StyleButton then
		mt.StyleButton = StyleButton
	end

	if not object.SkinCloseButton then
		mt.SkinCloseButton = SkinCloseButton
	end

	if not object.SkinCheckBox then
		mt.SkinCheckBox = SkinCheckBox
	end

	if not object.SkinScrollBar then
		mt.SkinScrollBar = SkinScrollBar
	end

	if not object.HideBackdrop then
		mt.HideBackdrop = HideBackdrop
	end
end

local handled = { Frame = true }
local object = CreateFrame("Frame")
addapi(object)
addapi(object:CreateTexture())
addapi(object:CreateFontString())
addapi(object:CreateMaskTexture())

object = EnumerateFrames()
while object do
	local objType = object:GetObjectType()
	if not object:IsForbidden() and not handled[objType] then
		addapi(object)
		handled[objType] = true
	end

	object = EnumerateFrames(object)
end

addapi(_G.GameFontNormal) --Add API to `CreateFont` objects without actually creating one
addapi(CreateFrame("ScrollFrame")) --Hacky fix for issue on 7.1 PTR where scroll frames no longer seem to inherit the methods from the 'Frame' widget
