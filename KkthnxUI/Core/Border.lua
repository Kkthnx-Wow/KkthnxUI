local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = {}

-- Lua API cache (Performance Optimization)
local type, unpack, setmetatable, pairs, error, ipairs = type, unpack, setmetatable, pairs, error, ipairs
local math_min, math_max = math.min, math.max

-- 1. FIX: Weak table to prevent memory leaks (Garbage collection can now clean these up)
local objectToWidgets = setmetatable({}, { __mode = "k" })

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

-- Centralize default config
local Config = {
	Style = C["General"].BorderStyle or "KkthnxUI",
	SizeKkthnx = 12,
	SizeDefault = 10,
}

local function GetDefaultBorderSize()
	return (Config.Style == "KkthnxUI") and Config.SizeKkthnx or Config.SizeDefault
end

-- Export border size for API.lua consistency
K.BorderSize = GetDefaultBorderSize()

--------------------------------------------------------------------------------
-- HELPER FUNCTIONS (Internal)
--------------------------------------------------------------------------------

local function GetTileCount(border, w, h)
	local size = border.__size or GetDefaultBorderSize()
	-- Prevent division by zero
	if size == 0 then
		return 1
	end
	return (w + 2 * (border.__offset or 0)) / size
end

local function UpdateTextureCoords(border, tile)
	-- Only the straight edges need tile repeating
	border.TOP:SetTexCoord(0.25, tile, 0.375, tile, 0.25, 0, 0.375, 0)
	border.BOTTOM:SetTexCoord(0.375, tile, 0.5, tile, 0.375, 0, 0.5, 0)
	border.LEFT:SetTexCoord(0, 0.125, 0, tile)
	border.RIGHT:SetTexCoord(0.125, 0.25, 0, tile)
end

-- Defined outside CreateBorder to avoid creating closures repeatedly
local function OnBorderResize(self)
	local border = objectToWidgets[self]
	if not border then
		return
	end

	local w, h = self:GetSize()
	local tile = GetTileCount(border, w, h)
	UpdateTextureCoords(border, tile)
end

--------------------------------------------------------------------------------
-- MODULE METHODS (The Border Object)
--------------------------------------------------------------------------------

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
end

function Module:SetTexture(texture)
	-- Case 1: Texture is a color table {r, g, b}
	if type(texture) == "table" then
		self:SetVertexColor(unpack(texture))
		return
	end

	-- Case 2: Texture is a file path string
	if type(texture) == "string" then
		for i, section in ipairs(borderSections) do
			local tex = self[section.name]
			-- Sections > 4 are the repeating sides (TOP, BOTTOM, LEFT, RIGHT)
			tex:SetTexture(texture, (i > 4) and "REPEAT" or nil, (i > 4) and "REPEAT" or nil)
		end
	end
end

function Module:SetSize(size)
	if type(size) ~= "number" then
		error("Border:SetSize() - Size must be a number", 2)
	end
	self.__size = size

	for _, v in ipairs(borderSections) do
		local tex = self[v.name]
		if v.name == "TOP" or v.name == "BOTTOM" then
			tex:SetHeight(size)
		elseif v.name == "LEFT" or v.name == "RIGHT" then
			tex:SetWidth(size)
		else
			tex:SetSize(size, size)
		end
	end

	-- Force an immediate update on the parent to fix coords
	if self.__parent then
		OnBorderResize(self.__parent)
	end
end

function Module:SetVertexColor(r, g, b, a)
	for _, section in ipairs(borderSections) do
		self[section.name]:SetVertexColor(r, g, b, a)
	end
end

-- Create proxy methods for common texture functions (Hide, Show, SetAlpha, etc.)
local function CreateProxyMethod(methodName)
	Module[methodName] = function(self, ...)
		for _, section in ipairs(borderSections) do
			local tex = self[section.name]
			if tex[methodName] then
				tex[methodName](tex, ...)
			end
		end
	end
end

CreateProxyMethod("Hide")
CreateProxyMethod("Show")
CreateProxyMethod("SetShown")
CreateProxyMethod("SetAlpha")

function Module:SetIgnoreParentAlpha(ignore)
	for _, section in ipairs(borderSections) do
		local tex = self[section.name]
		if tex and tex.SetIgnoreParentAlpha then
			tex:SetIgnoreParentAlpha(ignore and true or false)
		end
	end
end

function Module:IsObjectType(t)
	return t == "Border"
end

--------------------------------------------------------------------------------
-- INTERNAL FACTORY (K:CreateBorder)
--------------------------------------------------------------------------------

function K:CreateBorder(drawLayer, drawSubLevel)
	-- If this frame already has a border object tracked, return it
	if objectToWidgets[self] then
		return objectToWidgets[self]
	end

	local border = setmetatable({}, { __index = Module })
	border.__parent = self

	local layer = type(drawLayer) == "string" and drawLayer or "OVERLAY"
	local subLevel = type(drawSubLevel) == "number" and drawSubLevel or 1

	-- Create all 8 texture sections
	for _, section in ipairs(borderSections) do
		local tex = self:CreateTexture(nil, layer, nil, subLevel)
		tex:SetTexCoord(unpack(section.coord))
		border[section.name] = tex
	end

	-- Link corners to each other to form the frame structure
	border.TOP:SetPoint("TOPLEFT", border.TOPLEFT, "TOPRIGHT", 0, 0)
	border.TOP:SetPoint("TOPRIGHT", border.TOPRIGHT, "TOPLEFT", 0, 0)
	border.BOTTOM:SetPoint("BOTTOMLEFT", border.BOTTOMLEFT, "BOTTOMRIGHT", 0, 0)
	border.BOTTOM:SetPoint("BOTTOMRIGHT", border.BOTTOMRIGHT, "BOTTOMLEFT", 0, 0)
	border.LEFT:SetPoint("TOPLEFT", border.TOPLEFT, "BOTTOMLEFT", 0, 0)
	border.LEFT:SetPoint("BOTTOMLEFT", border.BOTTOMLEFT, "TOPLEFT", 0, 0)
	border.RIGHT:SetPoint("TOPRIGHT", border.TOPRIGHT, "BOTTOMRIGHT", 0, 0)
	border.RIGHT:SetPoint("BOTTOMRIGHT", border.BOTTOMRIGHT, "TOPRIGHT", 0, 0)

	-- Hook resizing logic
	if not self:GetScript("OnSizeChanged") then
		self:SetScript("OnSizeChanged", OnBorderResize)
	else
		self:HookScript("OnSizeChanged", OnBorderResize)
	end

	objectToWidgets[self] = border

	-- Apply defaults
	border:SetOffset(-4)
	border:SetSize(K.BorderSize)

	return border
end
