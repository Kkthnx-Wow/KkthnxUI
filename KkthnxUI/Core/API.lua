local K, C = unpack(select(2, ...))

-- Application Programming Interface for KkthnxUI (API)

local _G = _G
local assert = _G.assert
local getmetatable = _G.getmetatable
local select = _G.select

local CreateFrame = _G.CreateFrame
local EnumerateFrames = _G.EnumerateFrames
local GetAddOnMetadata = _G.GetAddOnMetadata
local RegisterAttributeDriver = _G.RegisterAttributeDriver
local RegisterStateDriver = _G.RegisterStateDriver
local UIParent = _G.UIParent

local CustomCloseButton = "Interface\\AddOns\\KkthnxUI\\Media\\Textures\\CloseButton_32"

do
	BINDING_HEADER_KKTHNXUI = GetAddOnMetadata(..., "Title")

	K.UIFrameHider = CreateFrame("Frame", nil, UIParent, "SecureHandlerAttributeTemplate")
	K.UIFrameHider:Hide()
	K.UIFrameHider:SetPoint("TOPLEFT", 0, 0)
	K.UIFrameHider:SetPoint("BOTTOMRIGHT", 0, 0)
	RegisterAttributeDriver(K.UIFrameHider, "state-visibility", "hide")

	K.PetBattleHider = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
	K.PetBattleHider:SetAllPoints()
	K.PetBattleHider:SetFrameStrata("LOW")
	RegisterStateDriver(K.PetBattleHider, "visibility", "[petbattle] hide; show")
end

-- This is a lot...
local function CreateBorder(bFrame, bSubLevel, bLayer, bSize, bTexture, bOffset, bRed, bGreen, bBlue, bAlpha, bgTexture, bgSubLevel, bgLayer, bgPoint, bgRed, bgGreen, bgBlue, bgAlpha, bgBackground)
	if bFrame.KKUI_Border then
		return
	end

	if bFrame:GetObjectType() == "Texture" then
		bFrame = bFrame:GetParent()
	end

	-- Border
	local BorderSubLevel = bSubLevel or "OVERLAY"
	local BorderLayer = bLayer or 1
	local BorderSize = bSize or 12
	local BorderTexture = bTexture or C["Media"].Border
	local BorderOffset = bOffset or -4
	local BorderRed = bRed or C["General"].ColorTextures and C["General"].TexturesColor[1] or C["Media"].BorderColor[1]
	local BorderGreen = bGreen or C["General"].ColorTextures and C["General"].TexturesColor[2] or C["Media"].BorderColor[2]
	local BorderBlue = bBlue or C["General"].ColorTextures and C["General"].TexturesColor[3] or C["Media"].BorderColor[3]
	local BorderAlpha = bAlpha or 1

	-- Background
	local BackgroundTexture = bgTexture or C["Media"].Blank
	local BackgroundSubLevel = bgSubLevel or "BACKGROUND"
	local BackgroundLayer = bgLayer or -1
	local BackgroundPoint = bgPoint or 0
	local BackgroundRed = bgRed or C["Media"].BackdropColor[1]
	local BackgroundGreen = bgGreen or C["Media"].BackdropColor[2]
	local BackgroundBlue = bgBlue or C["Media"].BackdropColor[3]
	local BackgroundAlpha = bgAlpha or C["Media"].BackdropColor[4]
	local UseBackground = bgBackground or true

	-- Create Our Border
	if not bFrame.KKUI_Border then
		local kkui_border = K.CreateBorder(bFrame, BorderSubLevel, BorderLayer)
		kkui_border:SetSize(BorderSize)
		kkui_border:SetTexture(BorderTexture)
		kkui_border:SetOffset(BorderOffset)
		kkui_border:SetVertexColor(BorderRed, BorderGreen, BorderBlue, BorderAlpha)
		bFrame.KKUI_Border = true
		bFrame.KKUI_Border = kkui_border
	end

	-- Create Our Background (true/false)
	if UseBackground then
		if not bFrame.KKUI_Background then
			local kkui_background = bFrame:CreateTexture()
			kkui_background:SetDrawLayer(BackgroundSubLevel, BackgroundLayer)
			kkui_background:SetTexture(BackgroundTexture)
			kkui_background:SetPoint("TOPLEFT", bFrame ,"TOPLEFT", BackgroundPoint, -BackgroundPoint)
			kkui_background:SetPoint("BOTTOMRIGHT", bFrame ,"BOTTOMRIGHT", -BackgroundPoint, BackgroundPoint)
			kkui_background:SetVertexColor(BackgroundRed, BackgroundGreen, BackgroundBlue, BackgroundAlpha)
			bFrame.KKUI_Background = true
			bFrame.KKUI_Background = kkui_background
		end
	end
end

-- Simple Create Backdrop.
local function CreateBackdrop(f)
	if f.Backdrop then
		return
	end

	local b = CreateFrame("Frame", nil, f)
	b:SetPoint("TOPLEFT", f, "TOPLEFT")
	b:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT")
	b:CreateBorder()

	if f:GetFrameLevel() - 1 >= 0 then
		b:SetFrameLevel(f:GetFrameLevel())
	else
		b:SetFrameLevel(0)
	end

	f.Backdrop = b
end

-- The Famous Shadow?
local function CreateShadow(f, bd)
	if f.Shadow then
		return
	end

	local frame = f
	if f:GetObjectType() == "Texture" then
		frame = f:GetParent()
	end
	local lvl = frame:GetFrameLevel()

	f.Shadow = CreateFrame("Frame", nil, frame, "BackdropTemplate")
	f.Shadow:SetPoint("TOPLEFT", f, -3, 3)
	f.Shadow:SetPoint("BOTTOMRIGHT", f, 3, -3)
	if bd then
		f.Shadow:SetBackdrop({
			bgFile = C["Media"].Blank,
			edgeFile = C["Media"].Glow,
			edgeSize = 3,
			insets = {left = 3, right = 3, top = 3, bottom = 3}
		})
	else
		f.Shadow:SetBackdrop({
			edgeFile = C["Media"].Glow,
			edgeSize = 3
		})
	end
	f.Shadow:SetFrameLevel(lvl == 0 and 0 or lvl - 1)
	if bd then
		f.Shadow:SetBackdropColor(C.Media.BackdropColor[1], C.Media.BackdropColor[2], C.Media.BackdropColor[3], C.Media.BackdropColor[4])
	end
	f.Shadow:SetBackdropBorderColor(0, 0, 0, 0.8)

	return f.Shadow
end

-- Its A Killer.
local function Kill(object)
	if object.UnregisterAllEvents then
		object:UnregisterAllEvents()
		object:SetParent(K.UIFrameHider)
	else
		object.Show = object.Hide
	end
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
	"FilligreeOverlay",
	"PortraitOverlay",
	"ArtOverlayFrame",
	"Portrait",
	"portrait",
	"ScrollFrameBorder",
	"ScrollUpBorder",
	"ScrollDownBorder",
}

local function StripTextures(object, kill)
	local frameName = object.GetName and object:GetName()
	for _, texture in pairs(blizzTextures) do
		local blizzFrame = object[texture] or (frameName and _G[frameName..texture])
		if blizzFrame then
			StripTextures(blizzFrame, kill)
		end
	end

	if object.GetNumRegions then
		for i = 1, object:GetNumRegions() do
			local region = select(i, object:GetRegions())
			if region and region.IsObjectType and region:IsObjectType("Texture") then
				if kill and type(kill) == "boolean" then
					region:Kill()
				elseif tonumber(kill) then
					if kill == 0 then
						region:SetAlpha(0)
					elseif i ~= kill then
						region:SetTexture("")
					end
				else
					region:SetTexture("")
				end
			end
		end
	end
end

-- Font Template.
local function FontTemplate(fs, font, fontSize, fontStyle)
	fs.font = font
	fs.fontSize = fontSize
	fs.fontStyle = fontStyle

	font = font or C["Media"].Font
	fontSize = fontSize or 12

	if fontSize > 12 and not fs.fontSize then
		fontSize = 12
	end

	fs:SetFont(font, fontSize, fontStyle)
	if fontStyle and (fontStyle ~= "NONE") then
		fs:SetShadowOffset(0, 0)
		fs:SetShadowColor(0, 0, 0, 0)
	else
		local s = K.Mult or 1
		fs:SetShadowOffset(s, -s / 2)
		fs:SetShadowColor(0, 0, 0, 1)
	end
end

local function StyleButton(button, noHover, noPushed, noChecked, setPoints)
	local pointsSet = setPoints or 0

	if button.SetHighlightTexture and not button.hover and not noHover then
		local hover = button:CreateTexture()
		hover:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
		hover:SetPoint("TOPLEFT", button, "TOPLEFT", pointsSet, -pointsSet)
		hover:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -pointsSet, pointsSet)
		hover:SetBlendMode("ADD")
		button:SetHighlightTexture(hover)
		button.hover = hover
	end

	if button.SetPushedTexture and not button.pushed and not noPushed then
		local pushed = button:CreateTexture()
		pushed:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
		pushed:SetDesaturated(true)
		pushed:SetVertexColor(246/255, 196/255, 66/255)
		pushed:SetPoint("TOPLEFT", button, "TOPLEFT", pointsSet, -pointsSet)
		pushed:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -pointsSet, pointsSet)
		pushed:SetBlendMode("ADD")
		button:SetPushedTexture(pushed)
		button.pushed = pushed
	end

	if button.SetCheckedTexture and not button.checked and not noChecked then
		local checked = button:CreateTexture()
		checked:SetTexture("Interface\\Buttons\\CheckButtonHilight")
		checked:SetPoint("TOPLEFT", button, "TOPLEFT", pointsSet, -pointsSet)
		checked:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -pointsSet, pointsSet)
		checked:SetBlendMode("ADD")
		button:SetCheckedTexture(checked)
		button.checked = checked
	end

	local name = button.GetName and button:GetName()
	local cooldown = name and _G[name.."Cooldown"]
	if cooldown then
		cooldown:ClearAllPoints()
		cooldown:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
		cooldown:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
		cooldown:SetDrawEdge(false)
		cooldown:SetSwipeColor(0, 0, 0, 1)
	end
end

local function SetModifiedBackdrop(self)
	if not self:IsEnabled() then
		return
	end

	self.KKUI_Border:SetVertexColor(102/255, 157/255, 255/255, 1)
end

local function SetOriginalBackdrop(self)
	self.KKUI_Border:SetVertexColor(1, 1, 1)
end

local blizzButtonRegions = {
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
}

local function SkinButton(f, forceStrip)
	if f.SetNormalTexture then
		f:SetNormalTexture("")
	end

	if f.SetHighlightTexture then
		f:SetHighlightTexture("")
	end

	if f.SetPushedTexture then
		f:SetPushedTexture("")
	end

	if f.SetDisabledTexture then
		f:SetDisabledTexture("")
	end

	local buttonName = f.GetName and f:GetName()
	for _, region in pairs(blizzButtonRegions) do
		region = buttonName and _G[buttonName..region] or f[region]
		if region then
			region:SetAlpha(0)
		end
	end

	if forceStrip then
		f:StripTextures()
	end

	f:CreateBorder()

	f:HookScript("OnEnter", SetModifiedBackdrop)
	f:HookScript("OnLeave", SetOriginalBackdrop)
end

local function SkinCloseButton(f, point, texture)
	assert(f, "doesnt exist!")

	f:StripTextures()
	f:CreateBorder(nil, nil, nil, nil, -12, nil, nil, nil, nil, nil, nil, nil, 8)

	f:HookScript("OnEnter", SetModifiedBackdrop)
	f:HookScript("OnLeave", SetOriginalBackdrop)
	f:SetHitRectInsets(6, 6, 7, 7)

	local closeTexture = texture or CustomCloseButton
	if not f.button then
		f.button = f:CreateTexture(nil, "OVERLAY")
		f.button:SetSize(16, 16)
		f.button:SetTexture(closeTexture)
		f.button:SetPoint("CENTER", f, "CENTER")
	end

	if point then
		f:SetPoint("TOPRIGHT", point, "TOPRIGHT", 2, 2)
	end
end

local function SkinCheckBox(f)
	f:StripTextures()
	f:CreateBorder()

	if f.SetCheckedTexture then
		f:SetCheckedTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\UI-CheckBox-Check")
	end

	if f.SetDisabledCheckedTexture then
		f:SetDisabledCheckedTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\UI-CheckBox-Check-Disabled")
	end

	-- Why Is The Disabled Texture Always Displayed As Checked?
	f:HookScript("OnDisable", function(self)
		if not self.SetDisabledTexture then
			return
		end

		if self:GetChecked() then
			self:SetDisabledTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\UI-CheckBox-Check-Disabled")
		else
			self:SetDisabledTexture("")
		end
	end)

	f.SetNormalTexture = K.Noop
	f.SetPushedTexture = K.Noop
	f.SetHighlightTexture = K.Noop
end

-- Handle arrows
local arrowDegree = {
	["up"] = 0,
	["down"] = 180,
	["left"] = 90,
	["right"] = -90,
}

local function SetupArrow(self, direction)
	self:SetTexture(C["Media"].Arrow)
	self:SetRotation(rad(arrowDegree[direction]))
end

function K.ReskinArrow(self, direction)
	self:SetSize(16, 16)
	self:SkinButton()

	self:SetDisabledTexture("Interface\\ChatFrame\\ChatFrameBackground")
	local dis = self:GetDisabledTexture()
	dis:SetVertexColor(0, 0, 0, .3)
	dis:SetDrawLayer("OVERLAY")
	dis:SetAllPoints()

	local tex = self:CreateTexture(nil, "ARTWORK")
	tex:SetAllPoints()
	SetupArrow(tex, direction)
	self.__texture = tex
end

local function GrabScrollBarElement(frame, element)
	local frameName = frame:GetDebugName()
	return frame[element] or frameName and (_G[frameName..element] or string.find(frameName, element)) or nil
end

local function SkinScrollBar(self)
	self:GetParent():StripTextures()
	self:StripTextures()

	local thumb = GrabScrollBarElement(self, "ThumbTexture") or GrabScrollBarElement(self, "thumbTexture") or self.GetThumbTexture and self:GetThumbTexture()
	if thumb then
		thumb:SetAlpha(0)
		thumb:SetWidth(16)
		self.thumb = thumb

		local bg = CreateFrame("Frame", nil, self)
		bg:CreateBorder()
		bg:SetPoint("TOPLEFT", thumb, 0, -6)
		bg:SetPoint("BOTTOMRIGHT", thumb, 0, 6)
		thumb.bg = bg
	end

	local up, down = self:GetChildren()
	K.ReskinArrow(up, "up")
	K.ReskinArrow(down, "down")
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

	if not object.FontTemplate then
		mt.FontTemplate = FontTemplate
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
end

local handled = {Frame = true}
local object = CreateFrame('Frame')
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
addapi(CreateFrame('ScrollFrame')) -- Hacky fix for issue on 7.1 PTR where scroll frames no longer seem to inherit the methods from the 'Frame' widget