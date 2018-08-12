local K, C = unpack(select(2, ...))

-- Application Programming Interface for KkthnxUI (API)

local _G = _G
local assert = _G.assert
local getmetatable = _G.getmetatable
local math_floor = _G.math.floor
local select = _G.select
local string_match = _G.string.match

local CreateFrame = _G.CreateFrame
local CUSTOM_CLASS_COLORS = _G.CUSTOM_CLASS_COLORS
local EnumerateFrames = _G.EnumerateFrames
local RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS
local RegisterStateDriver = _G.RegisterStateDriver
local UIParent = _G.UIParent
local UnitClass = _G.UnitClass

local CustomClass = select(2, UnitClass("player"))
local CustomClassColor = K.Class == "PRIEST" and K.PriestColors or (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[CustomClass] or RAID_CLASS_COLORS[CustomClass])
local CustomCloseButton = "Interface\\AddOns\\KkthnxUI\\Media\\Textures\\CloseButton_32"
local CustomNoop = K.Noop

-- Preload
K.Mult = 768 / string_match(K.Resolution, "%d+x(%d+)") / C.General.UIScale
K.NoScaleMult = K.Mult * C.General.UIScale

function K.Scale(x)
	return K.Mult * math_floor(x / K.Mult + .5)
end

K.UIFrameHider = CreateFrame("Frame", "UIFrameHider", UIParent)
K.UIFrameHider:Hide()
K.UIFrameHider:SetAllPoints()
K.UIFrameHider.children = {}
RegisterStateDriver(K.UIFrameHider, "visibility", "hide")

K.PetBattleHider = CreateFrame("Frame", "PetBattleHider", UIParent, "SecureHandlerStateTemplate")
K.PetBattleHider:SetAllPoints()
K.PetBattleHider:SetFrameStrata("LOW")
RegisterStateDriver(K.PetBattleHider, "visibility", "[petbattle] hide; show")

local function SetOutside(obj, anchor, xOffset, yOffset)
	xOffset = xOffset or 0
	yOffset = yOffset or 0
	anchor = anchor or obj:GetParent()

	if obj:GetPoint() then
		obj:ClearAllPoints()
	end

	obj:SetPoint("TOPLEFT", anchor, "TOPLEFT", -xOffset, yOffset)
	obj:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", xOffset, -yOffset)
end

local function SetInside(obj, anchor, xOffset, yOffset)
	xOffset = xOffset or 0
	yOffset = yOffset or 0
	anchor = anchor or obj:GetParent()

	if obj:GetPoint() then
		obj:ClearAllPoints()
	end

	obj:SetPoint("TOPLEFT", anchor, "TOPLEFT", xOffset, -yOffset)
	obj:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", -xOffset, yOffset)
end

local function CreateBorder(f, _, bLayer, bOffset, bPoints)
	bLayer = bLayer or 0
	bOffset = bOffset or 4
	bPoints = bPoints or 0

	K.CreateBorder(f, bOffset)

	f.Backgrounds = f:CreateTexture(nil, "BACKGROUND")
	f.Backgrounds:SetDrawLayer("BACKGROUND", bLayer)
	f.Backgrounds:SetPoint("TOPLEFT", f ,"TOPLEFT", bPoints, -bPoints)
	f.Backgrounds:SetPoint("BOTTOMRIGHT", f ,"BOTTOMRIGHT", -bPoints, bPoints)
	f.Backgrounds:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

	f:SetBorderColor()
end

local function CreateBackdrop(f, t)
	if f.Backdrop then
		return
	end

	if not t then
		t = "Default"
	end

	local b = CreateFrame("Frame", nil, f)
	b:SetOutside()
	b:CreateBorder(t, -7)

	if f:GetFrameLevel() - 1 >= 0 then
		b:SetFrameLevel(f:GetFrameLevel() - 1)
	else
		b:SetFrameLevel(0)
	end

	f.Backdrop = b
end


local function CreateShadow(f)
	if f.Shadow then
		return
	end

	local shadow = CreateFrame("Frame", nil, f)
	shadow:SetFrameLevel(1)
	shadow:SetFrameStrata(f:GetFrameStrata())
	shadow:SetPoint("TOPLEFT", -4, 4)
	shadow:SetPoint("BOTTOMRIGHT", 4, -4)

	shadow:SetBackdrop({edgeFile = C.Media.Glow, edgeSize = K.Scale(4)})

	shadow:SetBackdropColor(C.Media.BackdropColor[1], C.Media.BackdropColor[2], C.Media.BackdropColor[3], C.Media.BackdropColor[4])
	shadow:SetBackdropBorderColor(0, 0, 0, 0.8)
	f.Shadow = shadow
end

local function Kill(Object)
	if Object.UnregisterAllEvents then
		Object:UnregisterAllEvents()
	end

	Object.Show = CustomNoop
	Object:Hide()
end

local function StripTextures(Object, Remove)
	for i = 1, Object:GetNumRegions() do
		local Region = select(i, Object:GetRegions())
		if Region:GetObjectType() == "Texture" then
			if Remove then
				Region:Kill()
			else
				Region:SetTexture(nil)
			end
		end
	end
end

local function FontTemplate(fs, font, fontSize, fontStyle)
	fs.font = font
	fs.fontSize = fontSize
	fs.fontStyle = fontStyle

	font = font or C.Media.Font
	fontSize = fontSize or 12

	fs:SetFont(font, fontSize, fontStyle)
	if fontStyle and (fontStyle ~= "NONE") then
		fs:SetShadowColor(0, 0, 0, 0.2)
	else
		fs:SetShadowColor(0, 0, 0, 1)
	end
	fs:SetShadowOffset((K.Mult or 1), -(K.Mult or 1))
end

local function FontString(parent, name, fontName, fontHeight, fontStyle)
	local fs = parent:CreateFontString(nil, "OVERLAY")
	fs:SetFont(fontName, fontHeight, fontStyle)
	fs:SetJustifyH("LEFT")
	fs:SetShadowColor(0, 0, 0)
	fs:SetShadowOffset(K.Mult, -K.Mult)

	if not name then
		parent.Text = fs
	else
		parent[name] = fs
	end

	return fs
end

local function StyleButton(button, noHover, noPushed, noChecked)
	if button.SetHighlightTexture and not button.hover and not noHover then
		local hover = button:CreateTexture()
		hover:SetVertexColor(1, 1, 1)
		hover:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
		hover:SetBlendMode("ADD")
		hover:SetAllPoints()
		button.hover = hover
		button:SetHighlightTexture(hover)
	end

	if button.SetPushedTexture and not button.pushed and not noPushed then
		local pushed = button:CreateTexture()
		pushed:SetVertexColor(1.0, 0.82, 0.0)
		pushed:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
		pushed:SetBlendMode("ADD")
		pushed:SetDesaturated(true)
		pushed:SetAllPoints()
		button.pushed = pushed
		button:SetPushedTexture(pushed)
	end

	if button.SetCheckedTexture and not button.checked and not noChecked then
		local checked = button:CreateTexture()
		checked:SetTexture("Interface\\Buttons\\CheckButtonHilight")
		checked:SetBlendMode("ADD")
		checked:SetAllPoints()
		button.checked = checked
		button:SetCheckedTexture(checked)
	end

	local cooldown = button:GetName() and _G[button:GetName() .. "Cooldown"]
	if cooldown and button:IsObjectType("Frame") then
		cooldown:ClearAllPoints()
		cooldown:SetPoint("TOPLEFT", 1, -1)
		cooldown:SetPoint("BOTTOMRIGHT", -1, 1)
		cooldown:SetDrawEdge(false)
		cooldown:SetSwipeColor(0, 0, 0, 1)
	end

	if button.SetNormalFontObject then
		button:SetNormalFontObject(KkthnxUIFont)
		button:SetHighlightFontObject(KkthnxUIFont)
		button:SetDisabledFontObject(KkthnxUIFont)
		button:SetPushedTextOffset(0, 0)
	end
end

local function SetModifiedBackdrop(self)
	if not C["General"].ColorTextures then
		self.Borders:SetBackdropBorderColor(CustomClassColor.r, CustomClassColor.g, CustomClassColor.b, 1)
	end

	self.Background:SetColorTexture(CustomClassColor.r * .15, CustomClassColor.g * .15, CustomClassColor.b * .15, C.Media.BackdropColor[4])
end

local function SetOriginalBackdrop(self)
	if not C["General"].ColorTextures then
		self.Borders:SetBackdropBorderColor(C.Media.BorderColor[1], C.Media.BorderColor[2], C.Media.BorderColor[3], 1)
	end

	self.Background:SetColorTexture(C.Media.BackdropColor[1], C.Media.BackdropColor[2], C.Media.BackdropColor[3], C.Media.BackdropColor[4])
end

local function SkinButton(f, strip)
	assert(f, "doesnt exist!")

	if f.Left then
		f.Left:SetAlpha(0)
	end

	if f.Middle then
		f.Middle:SetAlpha(0)
	end

	if f.Right then
		f.Right:SetAlpha(0)
	end

	if f.TopLeft then
		f.TopLeft:SetAlpha(0)
	end

	if f.TopMiddle then
		f.TopMiddle:SetAlpha(0)
	end

	if f.TopRight then
		f.TopRight:SetAlpha(0)
	end

	if f.MiddleLeft then
		f.MiddleLeft:SetAlpha(0)
	end

	if f.MiddleMiddle then
		f.MiddleMiddle:SetAlpha(0)
	end

	if f.MiddleRight then
		f.MiddleRight:SetAlpha(0)
	end

	if f.BottomLeft then
		f.BottomLeft:SetAlpha(0)
	end

	if f.BottomMiddle then
		f.BottomMiddle:SetAlpha(0)
	end

	if f.BottomRight then
		f.BottomRight:SetAlpha(0)
	end

	if f.LeftSeparator then
		f.LeftSeparator:SetAlpha(0)
	end

	if f.RightSeparator then
		f.RightSeparator:SetAlpha(0)
	end

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

	if strip then
		f:StripTextures()
	end

	f.Background = f:CreateTexture(nil, "BACKGROUND", -1)
	f.Background:SetAllPoints(f)
	f.Background:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

	f.Borders = CreateFrame("Frame", nil, f)
	f.Borders:SetAllPoints(f)
	K.CreateBorder(f.Borders)

	f:HookScript("OnEnter", SetModifiedBackdrop)
	f:HookScript("OnLeave", SetOriginalBackdrop)
end

local function SkinCloseButton(f, point, texture)
	assert(f, "doesnt exist!")

	f:StripTextures()

	if not f.Background then
		f.Background = f:CreateTexture(nil, "BACKGROUND", -1)
		f.Background:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])
		f.Background:SetPoint("TOPLEFT", 8, -8)
		f.Background:SetPoint("BOTTOMRIGHT", -8, 8)

		f.Borders = CreateFrame("Frame", nil, f)
		f.Borders:SetPoint("TOPLEFT", 8, -8)
		f.Borders:SetPoint("BOTTOMRIGHT", -8, 8)
		K.CreateBorder(f.Borders)

		f:HookScript("OnEnter", SetModifiedBackdrop)
		f:HookScript("OnLeave", SetOriginalBackdrop)
		f:SetHitRectInsets(6, 6, 7, 7)
	end

	if not texture then
		texture = CustomCloseButton
	end

	if not f.button then
		f.button = f:CreateTexture(nil, "OVERLAY")
		f.button:SetSize(16, 16)
		f.button:SetTexture(texture)
		f.button:SetPoint("CENTER", f, "CENTER")
	end

	if point then
		f:SetPoint("TOPRIGHT", point, "TOPRIGHT", 2, 2)
	end
end

local function SetFadeIn(frame)
	K.UIFrameFadeIn(frame, 0.4, frame:GetAlpha(), 1)
end

local function SetFadeOut(frame)
	K.UIFrameFadeOut(frame, 0.2, frame:GetAlpha(), 0)
end

local function AddCustomAPI(object)
	local MetaTable = getmetatable(object).__index

	if not object.SetOutside then
		MetaTable.SetOutside = SetOutside
	end

	if not object.SetInside then
		MetaTable.SetInside = SetInside
	end

	if not object.CreateBorder then
		MetaTable.CreateBorder = CreateBorder
	end

	if not object.CreateBackdrop then
		MetaTable.CreateBackdrop = CreateBackdrop
	end

	if not object.CreateShadow then
		MetaTable.CreateShadow = CreateShadow
	end

	if not object.SetFadeIn then
		MetaTable.SetFadeIn = SetFadeIn
	end

	if not object.SetFadeOut then
		MetaTable.SetFadeOut = SetFadeOut
	end

	if not object.FontString then
		MetaTable.FontString = FontString
	end

	if not object.FontTemplate then
		MetaTable.FontTemplate = FontTemplate
	end

	if not object.Kill then
		MetaTable.Kill = Kill
	end

	if not object.SkinButton then
		MetaTable.SkinButton = SkinButton
	end

	if not object.StripTextures then
		MetaTable.StripTextures = StripTextures
	end

	if not object.StyleButton then
		MetaTable.StyleButton = StyleButton
	end

	if not object.SkinCloseButton then
		MetaTable.SkinCloseButton = SkinCloseButton
	end
end

local Handled = {["Frame"] = true}
local Object = CreateFrame("Frame")

AddCustomAPI(Object)
AddCustomAPI(Object:CreateTexture())
AddCustomAPI(Object:CreateFontString())

Object = EnumerateFrames()
while Object do
	if not Object:IsForbidden() and not Handled[Object:GetObjectType()] then
		AddCustomAPI(Object)
		Handled[Object:GetObjectType()] = true
	end

	Object = EnumerateFrames(Object)
end

-- Hacky fix for issue on 7.1 PTR where scroll frames no longer seem to inherit the methods from the "Frame" widget
local ScrollFrame = CreateFrame("ScrollFrame")
AddCustomAPI(ScrollFrame)