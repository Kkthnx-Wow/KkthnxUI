local K, C, L = select(2, ...):unpack()

-- Application Programming Interface for KkthnxUI (API)

-- Lua API
local getmetatable = getmetatable
local match = string.match
local floor = math.floor
local unpack, select = unpack, select

-- Wow API
local CreateFrame = CreateFrame
local CUSTOM_CLASS_COLORS, RAID_CLASS_COLORS = CUSTOM_CLASS_COLORS, RAID_CLASS_COLORS

local backdropr, backdropg, backdropb = unpack(C.Media.Backdrop_Color)
local borderr, borderg, borderb = unpack(C.Media.Border_Color)
local backdropa = 0.8
local bordera = 1

local Mult = 768 / string.match(K.Resolution, "%d+x(%d+)") / C.General.UIScale
local Scale = function(x)
	return Mult * math.floor(x / Mult + 0.5)
end

K.Scale = function(x) return Scale(x) end
K.Mult = Mult
K.NoScaleMult = K.Mult * C.General.UIScale

local Hider = CreateFrame("Frame", "UIFrameHider", UIParent)
Hider:Hide()

local PetBattleHider = CreateFrame("Frame", "PetBattleFrameHider", UIParent, "SecureHandlerStateTemplate")
PetBattleHider:SetAllPoints()
PetBattleHider:SetFrameStrata("LOW")
RegisterStateDriver(PetBattleHider, "visibility", "[petbattle] hide; show")

local function SetOutside(obj, anchor, xOffset, yOffset)
	xOffset = xOffset or 2
	yOffset = yOffset or 2
	anchor = anchor or obj:GetParent()

	if obj:GetPoint() then obj:ClearAllPoints() end

	obj:SetPoint("TOPLEFT", anchor, "TOPLEFT", -xOffset, yOffset)
	obj:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", xOffset, -yOffset)
end

local function SetInside(obj, anchor, xOffset, yOffset)
	xOffset = xOffset or 2
	yOffset = yOffset or 2
	anchor = anchor or obj:GetParent()

	if obj:GetPoint() then obj:ClearAllPoints() end

	obj:SetPoint("TOPLEFT", anchor, "TOPLEFT", xOffset, -yOffset)
	obj:SetPoint("BOTTOMRIGHT", anchor, "BOTTOMRIGHT", -xOffset, yOffset)
end

local function CreateOverlay(f, size)
	if f.overlay then return end
	size = size or 2

	local overlay = f:CreateTexture(nil, "BORDER", f)
	overlay:SetPoint("TOPLEFT", size, -size)
	overlay:SetPoint("BOTTOMRIGHT", -size, size)
	overlay:SetTexture(C.Media.Blank)
	overlay:SetVertexColor(26/255, 26/255, 26/255, 1)
	f.overlay = overlay
end

local function CreateBorder(f, size)
	if f.border then return end
	size = size or 2

	local border = CreateFrame("Frame", nil, f)
	border:SetPoint("TOPLEFT", -size, size)
	border:SetPoint("BOTTOMRIGHT", size, -size)
	border:SetFrameLevel(f:GetFrameLevel() + 1)
	border:SetBackdrop({
		edgeFile = C.Media.Blizz, edgeSize = 14,
		insets = {left = 2.5, right = 2.5, top = 2.5, bottom = 2.5}
	})
	border:SetBackdropBorderColor(unpack(C.Media.Border_Color))
	f.border = border
end

-- Backdrop
local function CreateBackdrop(f, t, size)
	if not t then t = "Default" end
	size = size or 2

	local b = CreateFrame("Frame", nil, f)
	b:SetPoint("TOPLEFT", -size, size)
	b:SetPoint("BOTTOMRIGHT", size, -size)
	b:SetTemplate(t)

	if f:GetFrameLevel() - 1 >= 0 then
		b:SetFrameLevel(f:GetFrameLevel() - 1)
	else
		b:SetFrameLevel(0)
	end

	f.backdrop = b
end

-- Who doesn't like shadows! More shadows!
local function CreateShadow(f, size)
	if f.Shadow then return end
	size = size or 3

	local shadow = CreateFrame("Frame", nil, f)
	shadow:SetFrameLevel(1)
	shadow:SetFrameStrata(f:GetFrameStrata())
	shadow:SetPoint("TOPLEFT", -size, size)
	shadow:SetPoint("BOTTOMLEFT", -size, -size)
	shadow:SetPoint("TOPRIGHT", size, size)
	shadow:SetPoint("BOTTOMRIGHT", size, -size)

	shadow:SetBackdrop( {
		edgeFile = C.Media.Glow, edgeSize = K.Scale(3),
		insets = {left = K.Scale(5), right = K.Scale(5), top = K.Scale(5), bottom = K.Scale(5)},
	})

	shadow:SetBackdropColor(C.Media.Backdrop_Color)
	shadow:SetBackdropBorderColor(0, 0, 0, 0.8)

	f.Shadow = shadow
end

local function CreateBlizzShadow(f, size)
	if f.shadow then return end
	size = size or 5

	local shadow = f:CreateTexture(nil, "BACKGROUND")
	shadow:SetPoint("TOPLEFT", -size, size)
	shadow:SetPoint("BOTTOMLEFT", -size, -size)
	shadow:SetPoint("TOPRIGHT", size, size)
	shadow:SetPoint("BOTTOMRIGHT", size, -size)

	shadow:SetTexture(C.Media.Border_Shadow)
	shadow:SetVertexColor(0, 0, 0, 0.8)

	f.shadow = shadow
end

local function GetTemplate(t)
	if t == "ClassColor" then
		local Color = K.Colors.class[K.Class]
		borderr, borderg, borderb, bordera = Color[1], Color[2], Color[3], Color[4]
		backdropr, backdropg, backdropb, backdropa = unpack(C.Media.Backdrop_Color)
	else
		borderr, borderg, borderb, bordera = unpack(C.Media.Border_Color)
		backdropr, backdropg, backdropb, backdropa = unpack(C.Media.Backdrop_Color)
	end
end

local function SetTemplate(f, t)
	GetTemplate(t)

	f:SetBackdrop({
		bgFile = C.Media.Blank, edgeFile = C.Media.Blizz, edgeSize = 14,
		insets = {left = 2.5, right = 2.5, top = 2.5, bottom = 2.5}
	})

	if t == "Transparent" then
		backdropa = C.Media.Overlay_Color[4]
	elseif t == "Overlay" then
		backdropa = 0.8
		f:CreateOverlay()
	else
		backdropa = C.Media.Backdrop_Color[4]
	end

	f:SetBackdropColor(backdropr, backdropg, backdropb, backdropa)
	f:SetBackdropBorderColor(borderr, borderg, borderb, bordera)

	if C.Blizzard.ColorTextures == true then
		f:SetBackdropBorderColor(unpack(C.Blizzard.TexturesColor))
	end
end

-- Create panel
local function CreatePanel(f, t, w, h, a1, p, a2, x, y)
	local r, g, b = K.Color.r, K.Color.g, K.Color.b
	f:SetFrameLevel(1)
	f:SetSize(w, h)
	f:SetFrameStrata("BACKGROUND")
	f:SetPoint(a1, p, a2, x, y)

	if t == "CreateBackdrop" then
		backdropa = C.Media.Overlay_Color[4]
		f:CreateBackdrop()
	elseif t == "CreateBorder" then
		f:SetBackdrop(K.BorderBackdrop)
		backdropa = C.Media.Overlay_Color[4]
		K.CreateBorder(f)
	elseif t == "SimpleBackdrop" then
		f:SetBackdrop(K.BorderBackdrop)
		backdropa = C.Media.Overlay_Color[4]
		bordera = 0
	elseif t == "Invisible" then
		backdropa = 0
		bordera = 0
	else
		backdropa = C.Media.Overlay_Color[4]
	end

	f:SetBackdropColor(backdropr, backdropg, backdropb, backdropa)
	f:SetBackdropBorderColor(borderr, borderg, borderb, bordera)
end

local function Kill(object)
	if object.UnregisterAllEvents then
		object:UnregisterAllEvents()
	end
	object.Show = K.Noop
	object:Hide()
end

-- StripTextures
local function StripTextures(Object, Kill, Text)
	for i = 1, Object:GetNumRegions() do
		local Region = select(i, Object:GetRegions())
		if Region and Region:GetObjectType() == "Texture" then
			if Kill then
				Region:Kill()
			else
				Region:SetTexture(nil)
			end
		end
	end
end

-- Example --> Font:FontString("Text", C.Media.Font, 12)
local function FontString(parent, name, fontName, fontHeight, fontStyle)
	local fs = parent:CreateFontString(nil, "OVERLAY")
	fs:SetFont(fontName, fontHeight, fontStyle)
	fs:SetJustifyH("LEFT")
	fs:SetShadowColor(0, 0, 0)
	fs:SetShadowOffset(K.Mult, K.Scale(-3)) -- Temp

	if not name then
		parent.Text = fs
	else
		parent[name] = fs
	end

	return fs
end

local function StyleButton(button)
	if button.SetHighlightTexture and not button.hover and not noHover then
		local hover = button:CreateTexture()
		hover:SetColorTexture(1, 1, 1, 0.3)
		hover:SetInside(button, 1, 1)
		button.hover = hover
		button:SetHighlightTexture(hover)
	end
	if button.SetPushedTexture and not button.pushed and not noPushed then
		local pushed = button:CreateTexture()
		pushed:SetColorTexture(0.9, 0.8, 0.1, 0.3)
		pushed:SetInside(button, 1, 1)
		button.pushed = pushed
		button:SetPushedTexture(pushed)
	end
	if button.SetCheckedTexture and not button.checked and not noChecked then
		local checked = button:CreateTexture()
		checked:SetColorTexture(1, 1, 1, 0.3)
		checked:SetInside(button, 1, 1)
		button.checked = checked
		button:SetCheckedTexture(checked)
	end
	local cooldown = button:GetName() and _G[button:GetName().."Cooldown"]
	if cooldown then
		cooldown:ClearAllPoints()
		cooldown:SetInside()
		cooldown:SetDrawEdge(false)
		cooldown:SetSwipeColor(0, 0, 0, 1)
	end
end

local function SkinButton(Frame, Strip)
	if Frame:GetName() then
		local Left = _G[Frame:GetName().."Left"]
		local Middle = _G[Frame:GetName().."Middle"]
		local Right = _G[Frame:GetName().."Right"]


		if Left then Left:SetAlpha(0) end
		if Middle then Middle:SetAlpha(0) end
		if Right then Right:SetAlpha(0) end
	end

	if Frame.Left then Frame.Left:SetAlpha(0) end
	if Frame.Right then Frame.Right:SetAlpha(0) end
	if Frame.Middle then Frame.Middle:SetAlpha(0) end
	if Frame.SetNormalTexture then Frame:SetNormalTexture("") end
	if Frame.SetHighlightTexture then Frame:SetHighlightTexture("") end
	if Frame.SetPushedTexture then Frame:SetPushedTexture("") end
	if Frame.SetDisabledTexture then Frame:SetDisabledTexture("") end

	if Strip then StripTextures(Frame) end

	-- This is so hacky lmao. Using CreateBackdrop for the time being.
	-- I need to make new textures for blizzard borders.
	Frame:CreateBackdrop("Default", 4)

	Frame:HookScript("OnEnter", function(self)
		local Color = RAID_CLASS_COLORS[select(2, UnitClass("player"))]

		Frame.backdrop:SetBackdropColor(Color.r * .15, Color.g * .15, Color.b * .15, C.Media.Backdrop_Color[4])
		Frame.backdrop:SetBackdropBorderColor(Color.r, Color.g, Color.b, C.Media.Border_Color[4])
	end)

	Frame:HookScript("OnLeave", function(self)
		local Color = RAID_CLASS_COLORS[select(2, UnitClass("player"))]

		Frame.backdrop:SetBackdropColor(C.Media.Backdrop_Color[1], C.Media.Backdrop_Color[2], C.Media.Backdrop_Color[3], C.Media.Backdrop_Color[4])
		Frame.backdrop:SetBackdropBorderColor(C.Media.Border_Color[1], C.Media.Border_Color[2], C.Media.Border_Color[3], C.Media.Border_Color[4])
	end)
end

-- Fade in/out functions
local function FadeIn(f)
	UIFrameFadeIn(f, 0.4, f:GetAlpha(), 1)
end

local function FadeOut(f)
	UIFrameFadeOut(f, 0.8, f:GetAlpha(), 0)
end

-- Merge KkthnxUI API with Wows API
local function AddAPI(object)
	local mt = getmetatable(object).__index
	if not object.CreateOverlay then mt.CreateOverlay = CreateOverlay end
	if not object.CreateBorder then mt.CreateBorder = CreateBorder end
	if not object.SetOutside then mt.SetOutside = SetOutside end
	if not object.SetInside then mt.SetInside = SetInside end
	if not object.CreateBackdrop then mt.CreateBackdrop = CreateBackdrop end
	if not object.SetTemplate then mt.SetTemplate = SetTemplate end
	if not object.CreatePanel then mt.CreatePanel = CreatePanel end
	if not object.CreateShadow then mt.CreateShadow = CreateShadow end
	if not object.CreateBlizzShadow then mt.CreateBlizzShadow = CreateBlizzShadow end
	if not object.StyleButton then mt.StyleButton = StyleButton end
	if not object.FontString then mt.FontString = FontString end
	if not object.Kill then mt.Kill = Kill end
	if not object.SkinButton then mt.SkinButton = SkinButton end
	if not object.StripTextures then mt.StripTextures = StripTextures end
	if not object.FadeIn then mt.FadeIn = FadeIn end
	if not object.FadeOut then mt.FadeOut = FadeOut end
end

local Handled = {["Frame"] = true}
local Object = CreateFrame("Frame")
AddAPI(Object)
AddAPI(Object:CreateTexture())
AddAPI(Object:CreateFontString())

Object = EnumerateFrames()
while Object do
	if not Object:IsForbidden() and not Handled[Object:GetObjectType()] then
		AddAPI(Object)
		Handled[Object:GetObjectType()] = true
	end

	Object = EnumerateFrames(Object)
end