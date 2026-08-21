--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Core/Border.lua
	Purpose:
		The signature KkthnxUI 8 section border. Ported from the original addon
		and wired into the new engine. A border is stored directly on its parent
		frame under a private key so there is no global weak table to manage.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

local type = type
local unpack = unpack
local error = error
local IsSecret = K.IsSecret

local BORDER_KEY = "KKUI_Border"

local Border = {}

local function GetDefaultStyle()
	return (C.General and C.General.BorderStyle) or "KkthnxUI"
end

local function GetDefaultSize()
	return GetDefaultStyle() == "KkthnxUI" and 12 or 10
end

K.BorderSize = GetDefaultSize()
K.BorderRegistry = {}

-- ---------------------------------------------------------------------------
-- Tiling math
-- ---------------------------------------------------------------------------

local function GetTileCount(border, width)
	local size = border.__size or K.BorderSize
	if size == 0 then
		return 1
	end
	local offset = border.__offset or 0
	return (width + 2 * offset) / size
end

local function UpdateTexCoords(border, tile)
	border.TOP:SetTexCoord(0.25, tile, 0.375, tile, 0.25, 0, 0.375, 0)
	border.BOTTOM:SetTexCoord(0.375, tile, 0.5, tile, 0.375, 0, 0.5, 0)
	border.LEFT:SetTexCoord(0, 0.125, 0, tile)
	border.RIGHT:SetTexCoord(0.125, 0.25, 0, tile)
end

local function OnResize(frame)
	local border = frame and frame[BORDER_KEY]
	if not border then
		return
	end
	local width = frame:GetWidth()
	if IsSecret(width) then
		return
	end
	UpdateTexCoords(border, GetTileCount(border, width))
end

-- ---------------------------------------------------------------------------
-- Border methods
-- ---------------------------------------------------------------------------

function Border:SetOffset(offset)
	if type(offset) ~= "number" then
		return
	end
	offset = K.Scale(offset)
	self.__offset = offset

	local p = self.__parent
	self.TOPLEFT:SetPoint("BOTTOMRIGHT", p, "TOPLEFT", -offset, offset)
	self.TOPRIGHT:SetPoint("BOTTOMLEFT", p, "TOPRIGHT", offset, offset)
	self.BOTTOMLEFT:SetPoint("TOPRIGHT", p, "BOTTOMLEFT", -offset, -offset)
	self.BOTTOMRIGHT:SetPoint("TOPLEFT", p, "BOTTOMRIGHT", offset, -offset)

	OnResize(p)
end

function Border:SetTexture(texture)
	if type(texture) == "table" then
		self:SetVertexColor(unpack(texture))
		return
	end
	if type(texture) == "string" then
		self.TOPLEFT:SetTexture(texture)
		self.TOPRIGHT:SetTexture(texture)
		self.BOTTOMLEFT:SetTexture(texture)
		self.BOTTOMRIGHT:SetTexture(texture)
		self.TOP:SetTexture(texture, "REPEAT", "REPEAT")
		self.BOTTOM:SetTexture(texture, "REPEAT", "REPEAT")
		self.LEFT:SetTexture(texture, "REPEAT", "REPEAT")
		self.RIGHT:SetTexture(texture, "REPEAT", "REPEAT")
	end
end

function Border:SetSize(size)
	if type(size) ~= "number" then
		error("Border:SetSize() - size must be a number", 2)
	end
	size = K.Scale(size)
	self.__size = size

	self.TOPLEFT:SetSize(size, size)
	self.TOPRIGHT:SetSize(size, size)
	self.BOTTOMLEFT:SetSize(size, size)
	self.BOTTOMRIGHT:SetSize(size, size)
	self.TOP:SetHeight(size)
	self.BOTTOM:SetHeight(size)
	self.LEFT:SetWidth(size)
	self.RIGHT:SetWidth(size)

	OnResize(self.__parent)
end

function Border:SetVertexColor(r, g, b, a)
	self.TOPLEFT:SetVertexColor(r, g, b, a)
	self.TOPRIGHT:SetVertexColor(r, g, b, a)
	self.BOTTOMLEFT:SetVertexColor(r, g, b, a)
	self.BOTTOMRIGHT:SetVertexColor(r, g, b, a)
	self.TOP:SetVertexColor(r, g, b, a)
	self.BOTTOM:SetVertexColor(r, g, b, a)
	self.LEFT:SetVertexColor(r, g, b, a)
	self.RIGHT:SetVertexColor(r, g, b, a)
end

-- Proxy simple frame methods across all eight segments.
local function AddProxy(method)
	Border[method] = function(self, ...)
		self.TOPLEFT[method](self.TOPLEFT, ...)
		self.TOPRIGHT[method](self.TOPRIGHT, ...)
		self.BOTTOMLEFT[method](self.BOTTOMLEFT, ...)
		self.BOTTOMRIGHT[method](self.BOTTOMRIGHT, ...)
		self.TOP[method](self.TOP, ...)
		self.BOTTOM[method](self.BOTTOM, ...)
		self.LEFT[method](self.LEFT, ...)
		self.RIGHT[method](self.RIGHT, ...)
	end
end

AddProxy("Hide")
AddProxy("Show")
AddProxy("SetShown")
AddProxy("SetAlpha")
AddProxy("SetIgnoreParentAlpha")
AddProxy("SetDrawLayer")

function Border:IsObjectType(t)
	return t == "Border"
end

-- ---------------------------------------------------------------------------
-- Factory
-- ---------------------------------------------------------------------------

function K.CreateBorder(frame, drawLayer, subLevel)
	local existing = frame[BORDER_KEY]
	if existing then
		return existing
	end

	local border = setmetatable({ __parent = frame }, { __index = Border })
	local layer = type(drawLayer) == "string" and drawLayer or "OVERLAY"
	local sub = type(subLevel) == "number" and subLevel or 1

	local function CreateEdge(c1, c2, c3, c4)
		local tex = frame:CreateTexture(nil, layer, nil, sub)
		tex:SetTexCoord(c1, c2, c3, c4)
		K.DisablePixelSnap(tex)
		return tex
	end

	border.TOPLEFT = CreateEdge(0.5, 0.625, 0, 1)
	border.TOPRIGHT = CreateEdge(0.625, 0.75, 0, 1)
	border.BOTTOMLEFT = CreateEdge(0.75, 0.875, 0, 1)
	border.BOTTOMRIGHT = CreateEdge(0.875, 1, 0, 1)
	border.TOP = CreateEdge(0.25, 0.375, 0, 1)
	border.BOTTOM = CreateEdge(0.375, 0.5, 0, 1)
	border.LEFT = CreateEdge(0, 0.125, 0, 1)
	border.RIGHT = CreateEdge(0.125, 0.25, 0, 1)

	border.TOP:SetPoint("TOPLEFT", border.TOPLEFT, "TOPRIGHT", 0, 0)
	border.TOP:SetPoint("TOPRIGHT", border.TOPRIGHT, "TOPLEFT", 0, 0)
	border.BOTTOM:SetPoint("BOTTOMLEFT", border.BOTTOMLEFT, "BOTTOMRIGHT", 0, 0)
	border.BOTTOM:SetPoint("BOTTOMRIGHT", border.BOTTOMRIGHT, "BOTTOMLEFT", 0, 0)
	border.LEFT:SetPoint("TOPLEFT", border.TOPLEFT, "BOTTOMLEFT", 0, 0)
	border.LEFT:SetPoint("BOTTOMLEFT", border.BOTTOMLEFT, "TOPLEFT", 0, 0)
	border.RIGHT:SetPoint("TOPRIGHT", border.TOPRIGHT, "BOTTOMRIGHT", 0, 0)
	border.RIGHT:SetPoint("BOTTOMRIGHT", border.BOTTOMRIGHT, "TOPRIGHT", 0, 0)

	if not frame:GetScript("OnSizeChanged") then
		frame:SetScript("OnSizeChanged", OnResize)
	else
		frame:HookScript("OnSizeChanged", OnResize)
	end

	frame[BORDER_KEY] = border

	local style = GetDefaultStyle()
	border:SetOffset(-4)
	border:SetSize(K.BorderSize)
	border:SetTexture(K.MediaFolder .. "Border\\" .. style .. "\\Border.tga")

	K.BorderRegistry[#K.BorderRegistry + 1] = border
	return border
end

-- A soft outer shadow: a backdrop frame sitting a few pixels
-- outside the target whose only art is a fuzzy edge glow. Used where the hard
-- eight-section border is too heavy, such as nameplates. The colour can be
-- changed later with K.SetShadowColor (target highlight, threat).
local SHADOW_TEXTURE = K.MediaFolder .. "Textures\\GlowShadow.blp"

function K.CreateShadow(frame, size, r, g, b, a)
	if frame.KKUI_Shadow then
		return frame.KKUI_Shadow
	end
	local anchor = frame
	if frame:IsObjectType("Texture") then
		anchor = frame:GetParent()
	end
	local offset = size or 4
	local shadow = CreateFrame("Frame", nil, anchor, "BackdropTemplate")
	shadow:SetPoint("TOPLEFT", frame, "TOPLEFT", -offset, offset)
	shadow:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", offset, -offset)
	shadow:SetFrameLevel(math.max(0, anchor:GetFrameLevel() - 1))
	shadow:SetBackdrop({ edgeFile = SHADOW_TEXTURE, edgeSize = offset + 1 })
	shadow:SetBackdropBorderColor(r or 0, g or 0, b or 0, a or 1)
	frame.KKUI_Shadow = shadow
	return shadow
end

-- Recolour an existing shadow (no-op if the frame has none).
function K.SetShadowColor(frame, r, g, b, a)
	local shadow = frame and frame.KKUI_Shadow
	if shadow then
		shadow:SetBackdropBorderColor(r, g, b, a or 1)
	end
end

-- Convenience: give a frame a dark background plus the border in one call.
function K.CreateBackdrop(frame, colorTable)
	if frame.KKUI_Background then
		return frame
	end
	local c = colorTable or { 0.06, 0.06, 0.06, 0.9 }
	K.CreateBackground(frame, c[1], c[2], c[3], c[4])
	K.CreateBorder(frame)
	return frame
end

-- Put one border back to the configured colour. Used when something that
-- temporarily owned the colour (threat, dispel school) lets go of it.
function K.ResetBorderColor(border)
	if not border then
		return
	end
	border.__customColor = nil
	local color = (C.General and C.General.BorderColor) or { 1, 1, 1, 1 }
	border:SetVertexColor(color[1], color[2], color[3], color[4] or 1)
end

-- Recolor every registered border, used by the config GUI on color changes.
function K.RefreshBorderColors()
	local color = (C.General and C.General.BorderColor) or { 1, 1, 1 }
	for _, border in ipairs(K.BorderRegistry) do
		if not border.__customColor then
			border:SetVertexColor(color[1], color[2], color[3], color[4] or 1)
		end
	end
end
