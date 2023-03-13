local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = {}

local type, unpack = type, unpack

-- This creates an empty table objectToWidgets
local objectToWidgets = {}

-- This sets the __index of the objectToWidgets to itself
objectToWidgets.__index = objectToWidgets

-- This creates a table of border sections, each containing the name of the section and the texture coordinates for that section.
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

-- Define a local variable 'borderStyle' that stores the value of 'C["General"].BorderStyle.Value'
local borderStyle = C["General"].BorderStyle.Value

-- Define a function 'getBorderSize' that returns 12 if 'borderStyle' is "KkthnxUI", otherwise it returns 10
local function getBorderSize()
	return borderStyle == "KkthnxUI" and 12 or 10
end

-- Define a function 'getTile' that takes a 'border', width 'w' and height 'h' as input,
-- and returns a calculation of tile value based on the given parameters and 'getBorderSize()'
local function getTile(border, w, h)
	return (w + 2 * border.__offset) / getBorderSize()
end

-- Define a function 'setTextureCoordinates' that takes a 'border' and a 'tile' value as input,
-- and sets texture coordinates for the border using the given 'tile' value
local function setTextureCoordinates(border, tile)
	border.TOP:SetTexCoord(0.25, tile, 0.375, tile, 0.25, 0, 0.375, 0)
	border.BOTTOM:SetTexCoord(0.375, tile, 0.5, tile, 0.375, 0, 0.5, 0)
	border.LEFT:SetTexCoord(0, 0.125, 0, tile)
	border.RIGHT:SetTexCoord(0.125, 0.25, 0, tile)
end

-- Define a function 'onSizeChanged' that takes a 'self' object, width 'w' and height 'h' as input,
-- retrieves the border from 'objectToWidgets' table using 'self',
-- and calculates the 'tile' value using 'getTile' function,
-- then sets the texture coordinates using 'setTextureCoordinates'
local function onSizeChanged(self, w, h)
	local border = objectToWidgets[self]
	local tile = getTile(border, w, h)
	setTextureCoordinates(border, tile)
end

-- Define a function 'Module:SetOffset' that takes an 'offset' value as input,
-- and sets the offset values for each border element based on the input offset value
-- Only set the offset values if 'offset' is a number
function Module:SetOffset(offset)
	if offset and type(offset) == "number" then
		self.__offset = offset
		self.TOPLEFT:SetPoint("BOTTOMRIGHT", self.__parent, "TOPLEFT", -offset, offset)
		self.TOPRIGHT:SetPoint("BOTTOMLEFT", self.__parent, "TOPRIGHT", offset, offset)
		self.BOTTOMLEFT:SetPoint("TOPRIGHT", self.__parent, "BOTTOMLEFT", -offset, -offset)
		self.BOTTOMRIGHT:SetPoint("TOPLEFT", self.__parent, "BOTTOMRIGHT", offset, -offset)
	end
end

function Module:SetTexture(texture)
	-- If the texture parameter is a table, apply the color texture to all border sections.
	if type(texture) == "table" then
		for _, v in pairs(borderSections) do
			self[v.name]:SetColorTexture(unpack(texture))
		end
	else
		-- If it's not a table, set the texture of each border section accordingly.
		local len = #borderSections
		for i = 1, len do
			local v = borderSections[i]
			if i > 4 then -- If it's a corner section, repeat the texture.
				self[v.name]:SetTexture(texture, "REPEAT", "REPEAT")
			else
				self[v.name]:SetTexture(texture)
			end
		end
	end
end

function Module:SetSize(size)
	-- Throw an error if the size parameter is not a number.
	if type(size) ~= "number" then
		error("Border:SetSize() - Size must be a number", 2)
	end

	self.__size = size

	local len = #borderSections
	for i = 1, len do
		local v = borderSections[i]
		if v.name == "TOP" or v.name == "BOTTOM" then
			self[v.name]:SetHeight(size)
		elseif v.name == "LEFT" or v.name == "RIGHT" then
			self[v.name]:SetWidth(size)
		else
			self[v.name]:SetSize(size, size)
		end
	end

	onSizeChanged(self.__parent, self.__parent:GetWidth(), self.__parent:GetHeight())
end

function Module:Hide()
	-- Hide all the border sections.
	local len = #borderSections
	for i = 1, len do
		self[borderSections[i].name]:Hide()
	end
end

function Module:Show()
	-- Show all the border sections.
	local len = #borderSections
	for i = 1, len do
		self[borderSections[i].name]:Show()
	end
end

-- Set the visibility state of all the border sections
function Module:SetShown(isShown)
	local len = #borderSections
	for i = 1, len do
		self[borderSections[i].name]:SetShown(isShown)
	end
end

-- Get the vertex color of the TOPLEFT border section
function Module:GetVertexColor()
	return self.TOPLEFT:GetVertexColor()
end

-- Set the vertex color of all the border sections
function Module:SetVertexColor(r, g, b, a)
	local len = #borderSections
	for i = 1, len do
		self[borderSections[i].name]:SetVertexColor(r, g, b, a)
	end
end

-- Set the alpha of all the border sections
function Module:SetAlpha(a)
	local len = #borderSections
	for i = 1, len do
		self[borderSections[i].name]:SetAlpha(a)
	end
end

-- Check if the object type is a Border
function Module:IsObjectType(t)
	return t == "Border"
end

-- Function that creates a border
function K:CreateBorder(drawLayer, drawSubLevel)
	-- Create a new border object by mixing the Module table with __parent set to self
	local border = Mixin({ __parent = self }, Module)

	-- Create a texture for each border section and set its texture coordinates
	for _, section in pairs(borderSections) do
		border[section.name] = self:CreateTexture(nil, drawLayer or "OVERLAY", nil, drawSubLevel or 1)
		border[section.name]:SetTexCoord(unpack(section.coord))
	end

	-- Set the anchor points for each border section
	border.TOP:SetPoint("TOPLEFT", border.TOPLEFT, "TOPRIGHT", 0, 0)
	border.TOP:SetPoint("TOPRIGHT", border.TOPRIGHT, "TOPLEFT", 0, 0)

	border.BOTTOM:SetPoint("BOTTOMLEFT", border.BOTTOMLEFT, "BOTTOMRIGHT", 0, 0)
	border.BOTTOM:SetPoint("BOTTOMRIGHT", border.BOTTOMRIGHT, "BOTTOMLEFT", 0, 0)

	border.LEFT:SetPoint("TOPLEFT", border.TOPLEFT, "BOTTOMLEFT", 0, 0)
	border.LEFT:SetPoint("BOTTOMLEFT", border.BOTTOMLEFT, "TOPLEFT", 0, 0)

	border.RIGHT:SetPoint("TOPRIGHT", border.TOPRIGHT, "BOTTOMRIGHT", 0, 0)
	border.RIGHT:SetPoint("BOTTOMRIGHT", border.BOTTOMRIGHT, "TOPRIGHT", 0, 0)

	-- Hook the OnSizeChanged script for the parent frame to the onSizeChanged function
	self:HookScript("OnSizeChanged", onSizeChanged)

	-- Add the border object to the objectToWidgets table
	objectToWidgets[self] = border

	-- Set the offset and size of the border
	border:SetOffset(-4)
	border:SetSize(getBorderSize())

	return border -- Return the created border object
end
