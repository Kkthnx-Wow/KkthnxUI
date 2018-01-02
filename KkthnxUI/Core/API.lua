local K, C, L = unpack(select(2, ...))
-- Application Programming Interface for KkthnxUI (API)

-- Lua API
local _G = _G
local getmetatable = getmetatable
local math_floor = math.floor
local select = select
local string_match = string.match
local math_max = math.max
local type = type
local unpack = unpack

-- Wow API
local CreateFrame = _G.CreateFrame
local RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS
local UnitClass = _G.UnitClass

-- Global variables that we don"t cache, list them here for mikk"s FindGlobals script
-- GLOBALS: noHover, noPushed, noChecked, bordera, KkthnxUIFont

-- Preload
K.Mult = 768 / string_match(K.Resolution, "%d+x(%d+)") / C["General"].UIScale
function K.Scale(x) return K.Mult * math_floor(x / K.Mult + 0.5) end
K.NoScaleMult = K.Mult * C["General"].UIScale

local color = RAID_CLASS_COLORS[K.Class]
local backdropr, backdropg, backdropb, backdropa = C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4]
local borderr, borderg, borderb = C["Media"].BorderColor[1], C["Media"].BorderColor[2], C["Media"].BorderColor[3]

-- frame to securely hide items (Goldpaw)
K.UIFrameHider = CreateFrame("Frame", "KkthnxUI_FrameHider", UIParent)
K.UIFrameHider:Hide()
K.UIFrameHider:SetAllPoints()
RegisterStateDriver(K.UIFrameHider, "visibility", "hide")

-- Petbattle frame to hide items when in petbattles
K.PetBattleHider = CreateFrame("Frame", "KkthnxUI_PetBattleHider", UIParent, "SecureHandlerStateTemplate")
K.PetBattleHider:SetAllPoints()
K.PetBattleHider:SetFrameStrata("LOW")
RegisterStateDriver(K.PetBattleHider, "visibility", "[petbattle] hide; show")

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

local function TrimIcon(self, customTrim)
	if self.SetTexCoord then
		local trim = customTrim or .08
		self:SetTexCoord(trim, 1 -trim, trim, 1 -trim)
	else
		K.Print("function SetTexCoord does not exist for", self:GetName() or self)
	end
end

local function SetTemplate(self, template, strip, noHover, noPushed, noChecked)
	if not template then template = "" end
	if not strip then self:StripTextures(true) end
	if template == "None" then self:SetBackdrop(nil) return end

	K.CreateBorder(self)
	self:SetBackdrop({bgFile = C["Media"].Blank, tile = false, tileSize = 0, insets = {left = 0, right = 0, top = 0, bottom = 0}})

	local backdropcolor, bordercolor
	if string_match(template, "Black") then
		backdropcolor = C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], 1
		bordercolor = C["Media"].BorderColor[1], C["Media"].BorderColor[2], C["Media"].BorderColor[3]
	elseif string_match(template, "Button") then
		backdropcolor = C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4]
		bordercolor = C["Media"].BorderColor[1], C["Media"].BorderColor[2], C["Media"].BorderColor[3]

		if string_match(template, "Action") then
			local cooldown = self:GetName() and _G[self:GetName().."Cooldown"] or self.cooldown
			if cooldown then
				cooldown:SetAllPoints()
				if not self.cooldown then self.cooldown = cooldown end
			end

			if self.icon then
				self.icon:TrimIcon()
				self.icon:SetDrawLayer("BACKGROUND", 1)
			end
		end

		if self.SetNormalTexture then
			self:SetNormalTexture("")
		end

		if self.SetHighlightTexture and not self.hover and not noHover then
			local hover = self:CreateTexture()
			hover:SetVertexColor(1, 1, 1)
			hover:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
			hover:SetBlendMode("ADD")
			hover:SetAllPoints()
			self.hover = hover
			self:SetHighlightTexture(hover)
		end

		if self.SetPushedTexture and not self.pushed and not noPushed then
			local pushed = self:CreateTexture()
			pushed:SetVertexColor(1.0, 0.82, 0.0)
			pushed:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
			pushed:SetBlendMode("ADD")
			pushed:SetDesaturated(true)
			pushed:SetAllPoints()
			self.pushed = pushed
			self:SetPushedTexture(pushed)
		end

		if self.SetCheckedTexture and not self.checked and not noChecked then
			local checked = self:CreateTexture()
			checked:SetTexture("Interface\\Buttons\\CheckButtonHilight")
			checked:SetBlendMode("ADD")
			checked:SetAllPoints()
			self.checked = checked
			self:SetCheckedTexture(checked)
		end

		local cooldown = self:GetName() and _G[self:GetName().."Cooldown"]
		if cooldown and self:IsObjectType("Frame") then
			cooldown:ClearAllPoints()
			cooldown:SetPoint("TOPLEFT", 1, -1)
			cooldown:SetPoint("BOTTOMRIGHT", -1, 1)
			cooldown:SetDrawEdge(false)
			cooldown:SetSwipeColor(0, 0, 0, 1)
		end

		if self.SetNormalFontObject then
			self:SetNormalFontObject(KkthnxUIFont)
			self:SetHighlightFontObject(KkthnxUIFont)
			self:SetDisabledFontObject(KkthnxUIFont)
			self:SetPushedTextOffset(0, 0)
		end
	elseif template == "Transparent" then
		backdropcolor = C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4]
		bordercolor = C["Media"].BorderColor[1], C["Media"].BorderColor[2], C["Media"].BorderColor[3]
	elseif template == "Black" then
		backdropcolor = C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], 1
		bordercolor = C["Media"].BorderColor[1], C["Media"].BorderColor[2], C["Media"].BorderColor[3]
	end

	if backdropcolor and bordercolor then
		self:SetBackdropColor(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])
		self:SetBackdropBorderColor(C["Media"].BorderColor[1], C["Media"].BorderColor[2], C["Media"].BorderColor[3])
	else
		self:SetBackdrop(nil)
	end
end

local function CreateBackdrop(f, t, tex, ignoreUpdates)
	if not t then t = "Default" end
	if f.Backdrop then return end

	local b = CreateFrame("Frame", "$parentBackdrop", f)
	b:SetAllPoints()
	b:SetTemplate(t, tex, ignoreUpdates)

	if f:GetFrameLevel() - 1 >= 0 then
		b:SetFrameLevel(f:GetFrameLevel() - 1)
	else
		b:SetFrameLevel(0)
	end

	f.Backdrop = b
end

-- Creates a textured shadow backdrop anchored to a frame
local function CreateShadow(self, size, strip, backdrop)
	if self.Shadow then return end
	if not size then size = 3 end

	backdropr, backdropg, backdropb, backdropa = C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4]
	borderr, borderg, borderb = 0, 0, 0

	if strip then self:StripTextures() end

	local shadow = CreateFrame("Frame", "$parentShadow", self)
	shadow:SetFrameLevel(1)
	shadow:SetFrameStrata(self:GetFrameStrata())
	shadow:SetOutside(self, size, size)
	if backdrop then
		shadow:SetBackdrop({bgFile = C["Media"].Blank, edgeFile = C["Media"].Glow, edgeSize = 3, tile = false, tileSize = 0, insets = {left = 3, right = 3, top = 3, bottom = 3}})
	else
		shadow:SetBackdrop({edgeFile = C["Media"].Glow, edgeSize = K.Scale(3), insets = {left = K.Scale(5), right = K.Scale(5), top = K.Scale(5), bottom = K.Scale(5)}})
	end
	shadow:SetBackdropColor(backdropr, backdropg, backdropb, backdropa)
	shadow:SetBackdropBorderColor(borderr, borderg, borderb, 0.9)

	self.Shadow = shadow
end

-- Create a Backdrop we can easly apply to frame/textures.
local function CreateBackground(self, strip)
	if self.Background then return end

	backdropr, backdropg, backdropb, backdropa = C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4]

	if strip then self:StripTextures() end

	local background = self:CreateTexture("$parentBackground", "BORDER")
	background:SetAllPoints()
	background:SetTexture(C["Media"].Blank)
	background:SetVertexColor(backdropr, backdropg, backdropb, backdropa)

	self.Background = background
end

-- Create panel
local function CreatePanel(f, t, w, h, a1, p, a2, x, y)
	local balpha = C["Media"].BackdropColor[4] or 0.9
	local balpha = backdropa

	f:SetFrameLevel(1)
	f:SetSize(w, h)
	f:SetFrameStrata("BACKGROUND")
	f:SetPoint(a1, p, a2, x, y)

	if t == "Transparent" then
		f:SetTemplate("Transparent", false)
	elseif t == "CreateBackdrop" then
		f:CreateBackdrop()
	elseif t == "Invisible" then
		balpha = 0
	elseif t == "CreateBorder" then
		balpha = 0
		K.CreateBorder(f)
	else
		balpha = C["Media"].BackdropColor[4]
	end

	f:SetBackdropColor(backdropr, backdropg, backdropb, backdropa)
	f:SetBackdropBorderColor(borderr, borderg, borderb)
end

local function Kill(object)
	if object.UnregisterAllEvents then
		object:UnregisterAllEvents()
		object:SetParent(K.UIFrameHider)
	else
		object.Show = object.Hide
	end

	object:Hide()
end

-- Removes any textures that the object might have
local function StripTextures(object, kill)
	for i = 1, object:GetNumRegions() do
		local region = select(i, object:GetRegions())
		if region and region:GetObjectType() == "Texture" then
			if kill and type(kill) == "boolean" then
				region:Kill()
			elseif region:GetDrawLayer() == kill then
				region:SetTexture(nil)
			elseif kill and type(kill) == "string" and region:GetTexture() ~= kill then
				region:SetTexture(nil)
			else
				region:SetTexture(nil)
			end
		end
	end
end

-- More advanced version of SetAllPoints, this allows you to pass up to 4 additional arguments that dictate the offsets:
-- One single value applies to all four sides.
-- wo values apply first to top and bottom, the second one to left and right.
-- hree values apply first to top, second to left and right and third to bottom.
-- Four values apply to top, right, bottom and left in that order (clockwise).
local function SetPoints(object, ...)
	local offsets, parent
	if ... and type(select(1, ...)) ~= "number" then
		offsets = {select(2, ...)}
		parent = ...
	else
		offsets = {...}
		parent = object:GetParent()
	end

	object:ClearAllPoints()
	if #offsets == 0 then
		object:SetAllPoints()
	elseif #offsets == 1 then
		object:SetPoint("TOPLEFT", parent, offsets[1], -offsets[1])
		object:SetPoint("BOTTOMRIGHT", parent, -offsets[1], offsets[1])
	elseif #offsets == 2 then
		object:SetPoint("TOPLEFT", parent, offsets[2], -offsets[1])
		object:SetPoint("BOTTOMRIGHT", parent, -offsets[2], offsets[1])
	elseif #offsets == 3 then
		object:SetPoint("TOPLEFT", parent, offsets[2], -offsets[1])
		object:SetPoint("BOTTOMRIGHT", parent, -offsets[2], offsets[3])
	else
		object:SetPoint("TOPLEFT", parent, offsets[4], -offsets[1])
		object:SetPoint("BOTTOMRIGHT", parent, -offsets[2], offsets[3])
	end
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

local function FontTemplate(fs, font, fontSize, fontStyle)
	fs.font = font
	fs.fontSize = fontSize
	fs.fontStyle = fontStyle

	font = font or C["Media"].Font
	fontSize = fontSize or C["Media"].FontSize
	fontStyle = fontStyle or "OUTLINE" or C["Media"].FontStyle

	fs:SetFont(font, fontSize, fontStyle)
	if fontStyle and (fontStyle ~= "NONE") then
		fs:SetShadowColor(0, 0, 0, 0.2)
	else
		fs:SetShadowColor(0, 0, 0, 1)
	end
	fs:SetShadowOffset((K.Mult or 1), -(K.Mult or 1))
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

	local cooldown = button:GetName() and _G[button:GetName().."Cooldown"]
	if cooldown and button:IsObjectType("Frame") then
		cooldown:ClearAllPoints()
		cooldown:SetPoint("TOPLEFT", 1, -1)
		cooldown:SetPoint("BOTTOMRIGHT", -1, 1)
		cooldown:SetDrawEdge(false)
		cooldown:SetSwipeColor(0, 0, 0, 1)
	end
end

function K.StatusBarColorGradient(bar, value, max, Backdrop)
    local current = (not max and value) or (value and max and max ~= 0 and value/max)
    if not (bar and current) then return end
    local r, g, b = K.ColorGradient(current, 0.8, 0, 0, 0.8, 0.8, 0, 0, 0.8, 0)
    local bg = Backdrop or bar.Backdrop
    if bg then bg:SetBackdropColor(r * 0.25, g * 0.25, b * 0.25) end
    bar:SetStatusBarColor(r, g, b)
end

local function SetModifiedBackdrop(self)
	if self.Backdrop then self = self.Backdrop end
	if not C["General"].ColorTextures then -- Fix a rare nil error
		self:SetBackdropBorderColor(color.r, color.g, color.b, 1)
	end
	self:SetBackdropColor(color.r * .15, color.g * .15, color.b * .15, C["Media"].BackdropColor[4])
end

local function SetOriginalBackdrop(self)
	if self.Backdrop then self = self.Backdrop end
	if not C["General"].ColorTextures then -- Fix a rare nil error
		self:SetBackdropBorderColor(C["Media"].BorderColor[1], C["Media"].BorderColor[2], C["Media"].BorderColor[3], 1)
	end
	self:SetBackdropColor(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])
end

local function SkinButton(f, strip)
	assert(f, "doesn't exist!")

	if f.Left then f.Left:SetAlpha(0) end
	if f.Middle then f.Middle:SetAlpha(0) end
	if f.Right then f.Right:SetAlpha(0) end
	if f.LeftSeparator then f.LeftSeparator:SetAlpha(0) end
	if f.RightSeparator then f.RightSeparator:SetAlpha(0) end

	if f.SetNormalTexture then f:SetNormalTexture("") end
	if f.SetHighlightTexture then f:SetHighlightTexture("") end
	if f.SetPushedTexture then f:SetPushedTexture("") end
	if f.SetDisabledTexture then f:SetDisabledTexture("") end

	if strip then f:StripTextures() end

	f:SetTemplate("Transparent", true)
	f:HookScript("OnEnter", SetModifiedBackdrop)
	f:HookScript("OnLeave", SetOriginalBackdrop)
end

local function SkinCloseButton(f, point, text)
	assert(f, "doesn't exist!")

	f:StripTextures()

	if not f.backdrop then
		f:CreateBackdrop("Transparent", true)
		f.Backdrop:SetPoint("TOPLEFT", 7, -8)
		f.Backdrop:SetPoint("BOTTOMRIGHT", -8, 8)
		f:HookScript("OnEnter", SetModifiedBackdrop)
		f:HookScript("OnLeave", SetOriginalBackdrop)
		f:SetHitRectInsets(6, 6, 7, 7)
	end

	if not text then text = "|cffb0504fx|r" end

	if not f.text then
		f.text = f:CreateFontString(nil, "OVERLAY")
		f.text:SetFont(C["Media"].Font, 16, "OUTLINE")
		f.text:SetShadowOffset(0, 0)
		f.text:SetText(text)
		f.text:SetJustifyH("CENTER")
		f.text:SetPoint("CENTER", f, "CENTER")
	end

	if point then
		f:SetPoint("TOPRIGHT", point, "TOPRIGHT", 2, 2)
	end
end

-- Fade in/out functions
local function FadeIn(frame)
	K.UIFrameFadeIn(frame, 0.4, frame:GetAlpha(), 1)
end

local function FadeOut(frame)
	K.UIFrameFadeOut(frame, 0.2, frame:GetAlpha(), 0)
end

-- Merge KkthnxUI API with Wows API
local function AddAPI(object)
	local mt = getmetatable(object).__index
	if not object.CreateBackdrop then mt.CreateBackdrop = CreateBackdrop end
	if not object.CreatePanel then mt.CreatePanel = CreatePanel end
	if not object.CreateShadow then mt.CreateShadow = CreateShadow end
	if not object.CreateBackground then mt.CreateBackground = CreateBackground end
	if not object.FadeIn then mt.FadeIn = FadeIn end
	if not object.FadeOut then mt.FadeOut = FadeOut end
	if not object.FontString then mt.FontString = FontString end
	if not object.FontTemplate then mt.FontTemplate = FontTemplate end
	if not object.Kill then mt.Kill = Kill end
	if not object.SetInside then mt.SetInside = SetInside end
	if not object.SetOutside then mt.SetOutside = SetOutside end
	if not object.SetPoints then mt.SetPoints = SetPoints end
	if not object.SetTemplate then mt.SetTemplate = SetTemplate end
	if not object.SkinButton then mt.SkinButton = SkinButton end
	if not object.StripTextures then mt.StripTextures = StripTextures end
	if not object.StyleButton then mt.StyleButton = StyleButton end
	if not object.SkinCloseButton then mt.SkinCloseButton = SkinCloseButton end
	if not object.TrimIcon then mt.TrimIcon = TrimIcon end
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

--Hacky fix for issue on 7.1 PTR where scroll frames no longer seem to inherit the methods from the "Frame" widget
local ScrollFrame = CreateFrame("ScrollFrame")
AddAPI(ScrollFrame)