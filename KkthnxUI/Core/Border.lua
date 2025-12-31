--[[-----------------------------------------------------------------------------
Addon: KkthnxUI
Author: Josh "Kkthnx" Russell
Notes:
- Purpose: Custom 8-section border system for UI objects.
- Combat: Safe for combat use; uses frame script hooks for resizing.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = {}

-- ---------------------------------------------------------------------------
-- Locals & Global Caching
-- ---------------------------------------------------------------------------

local type = type
local unpack = unpack
local ipairs = ipairs
local error = error

-- ---------------------------------------------------------------------------
-- Internal State & Config
-- ---------------------------------------------------------------------------

-- REASON: Border is stored directly on the parent frame to prevent table growth and avoid weak-table pitfalls.
local BORDER_KEY = "__kkthnx_border"

local borderSections = {
	{ name = "TOPLEFT", coord = { 0.5, 0.625, 0, 1 } },
	{ name = "TOPRIGHT", coord = { 0.625, 0.75, 0, 1 } },
	{ name = "BOTTOMLEFT", coord = { 0.75, 0.875, 0, 1 } },
	{ name = "BOTTOMRIGHT", coord = { 0.875, 1, 0, 1 } },
	{ name = "TOP", coord = { 0.25, 0.375, 0, 1 } },
	{ name = "BOTTOM", coord = { 0.375, 0.5, 0, 1 } },
	{ name = "LEFT", coord = { 0, 0.125, 0, 1 } },
	{ name = "RIGHT", coord = { 0.125, 0.25, 0, 1 } },
}

local function GetDefaultBorderSize()
	local style = C and C["General"] and C["General"].BorderStyle or "KkthnxUI"
	return (style == "KkthnxUI") and 12 or 10
end

K.BorderSize = GetDefaultBorderSize()

-- ---------------------------------------------------------------------------
-- Utility Helpers
-- ---------------------------------------------------------------------------

local function GetTileCount(border, w)
	local size = border.__size or K.BorderSize
	if size == 0 then
		return 1
	end

	local offset = border.__offset or 0
	return (w + 2 * offset) / size
end

local function UpdateTextureCoords(border, tile)
	-- REASON: Uses 8-arg SetTexCoord to preserve existing tiling behavior for atlas-based strips.
	border.TOP:SetTexCoord(0.25, tile, 0.375, tile, 0.25, 0, 0.375, 0)
	border.BOTTOM:SetTexCoord(0.375, tile, 0.5, tile, 0.375, 0, 0.5, 0)
	border.LEFT:SetTexCoord(0, 0.125, 0, tile)
	border.RIGHT:SetTexCoord(0.125, 0.25, 0, tile)
end

-- NOTE: Resizes tiling edges when the parent frame changes size.
local function OnBorderResize(self)
	local border = self and self[BORDER_KEY]
	if not border then
		return
	end

	local w = self:GetWidth()
	local tile = GetTileCount(border, w)
	UpdateTextureCoords(border, tile)
end

-- ---------------------------------------------------------------------------
-- Border Framework Methods
-- ---------------------------------------------------------------------------

function Module:SetOffset(offset)
	if type(offset) ~= "number" then
		return
	end

	self.__offset = offset

	local p = self.__parent
	self.TOPLEFT:SetPoint("BOTTOMRIGHT", p, "TOPLEFT", -offset, offset)
	self.TOPRIGHT:SetPoint("BOTTOMLEFT", p, "TOPRIGHT", offset, offset)
	self.BOTTOMLEFT:SetPoint("TOPRIGHT", p, "BOTTOMLEFT", -offset, -offset)
	self.BOTTOMRIGHT:SetPoint("TOPLEFT", p, "BOTTOMRIGHT", offset, -offset)

	OnBorderResize(p)
end

function Module:SetTexture(texture)
	-- NOTE: Case 1: Texture is a color table {r, g, b, a}.
	if type(texture) == "table" then
		self:SetVertexColor(unpack(texture))
		return
	end

	-- NOTE: Case 2: Texture is a file path string.
	if type(texture) == "string" then
		for i = 1, #borderSections do
			local section = borderSections[i]
			local tex = self[section.name]
			if i > 4 then
				-- REASON: Straight edges allow wrap behavior for coords outside [0..1] to facilitate tiling.
				tex:SetTexture(texture, "REPEAT", "REPEAT")
			else
				tex:SetTexture(texture)
			end
		end
	end
end

function Module:SetSize(size)
	if type(size) ~= "number" then
		error("Border:SetSize() - Size must be a number", 2)
	end

	self.__size = size

	for i = 1, #borderSections do
		local name = borderSections[i].name
		local tex = self[name]

		if name == "TOP" or name == "BOTTOM" then
			tex:SetHeight(size)
		elseif name == "LEFT" or name == "RIGHT" then
			tex:SetWidth(size)
		else
			tex:SetSize(size, size)
		end
	end

	OnBorderResize(self.__parent)
end

function Module:SetVertexColor(r, g, b, a)
	for i = 1, #borderSections do
		self[borderSections[i].name]:SetVertexColor(r, g, b, a)
	end
end

-- REASON: Dynamically maps standard Frame methods to all 8 border segments.
local function CreateProxyMethod(methodName)
	Module[methodName] = function(self, ...)
		for i = 1, #borderSections do
			local tex = self[borderSections[i].name]
			local fn = tex and tex[methodName]
			if fn then
				fn(tex, ...)
			end
		end
	end
end

CreateProxyMethod("Hide")
CreateProxyMethod("Show")
CreateProxyMethod("SetShown")
CreateProxyMethod("SetAlpha")

function Module:SetIgnoreParentAlpha(ignore)
	for i = 1, #borderSections do
		local tex = self[borderSections[i].name]
		if tex and tex.SetIgnoreParentAlpha then
			tex:SetIgnoreParentAlpha(ignore and true or false)
		end
	end
end

function Module:IsObjectType(t)
	return t == "Border"
end

-- ---------------------------------------------------------------------------
-- Border Factory
-- ---------------------------------------------------------------------------

function K:CreateBorder(drawLayer, drawSubLevel)
	-- NOTE: Return existing border for this frame if it already exists to avoid duplication.
	local existing = self[BORDER_KEY]
	if existing then
		return existing
	end

	local border = setmetatable({}, { __index = Module })
	border.__parent = self

	local layer = type(drawLayer) == "string" and drawLayer or "OVERLAY"
	local subLevel = type(drawSubLevel) == "number" and drawSubLevel or 1

	-- REASON: Create all 8 sections (4 corners, 4 edges).
	for i = 1, #borderSections do
		local section = borderSections[i]
		local tex = self:CreateTexture(nil, layer, nil, subLevel)
		tex:SetTexCoord(unpack(section.coord))
		border[section.name] = tex
	end

	-- REASON: Link edges to corners to ensure they scale and move together.
	border.TOP:SetPoint("TOPLEFT", border.TOPLEFT, "TOPRIGHT", 0, 0)
	border.TOP:SetPoint("TOPRIGHT", border.TOPRIGHT, "TOPLEFT", 0, 0)
	border.BOTTOM:SetPoint("BOTTOMLEFT", border.BOTTOMLEFT, "BOTTOMRIGHT", 0, 0)
	border.BOTTOM:SetPoint("BOTTOMRIGHT", border.BOTTOMRIGHT, "BOTTOMLEFT", 0, 0)
	border.LEFT:SetPoint("TOPLEFT", border.TOPLEFT, "BOTTOMLEFT", 0, 0)
	border.LEFT:SetPoint("BOTTOMLEFT", border.BOTTOMLEFT, "TOPLEFT", 0, 0)
	border.RIGHT:SetPoint("TOPRIGHT", border.TOPRIGHT, "BOTTOMRIGHT", 0, 0)
	border.RIGHT:SetPoint("BOTTOMRIGHT", border.BOTTOMRIGHT, "TOPRIGHT", 0, 0)

	-- NOTE: Hook resizing logic without clobbering existing OnSizeChanged scripts.
	if not self:GetScript("OnSizeChanged") then
		self:SetScript("OnSizeChanged", OnBorderResize)
	else
		self:HookScript("OnSizeChanged", OnBorderResize)
	end

	-- Store on the frame so it stays reachable and doesn't require a global map.
	self[BORDER_KEY] = border

	-- Apply defaults.
	border:SetOffset(-4)
	border:SetSize(K.BorderSize)

	return border
end
