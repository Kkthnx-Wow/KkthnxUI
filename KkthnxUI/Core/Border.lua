local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = {}

local type, unpack, setmetatable, pairs, error = type, unpack, setmetatable, pairs, error

local objectToWidgets = setmetatable({}, { __index = objectToWidgets })

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

local borderStyle = C["General"].BorderStyle or "KkthnxUI"
local borderSizeKkthnx = 12
local borderSizeDefault = 10
local getBorderSize = (borderStyle == "KkthnxUI") and borderSizeKkthnx or borderSizeDefault

-- Export border size for use in API.lua to maintain consistency
K.BorderSize = getBorderSize

local function getTile(border, w, h)
	local borderSize = getBorderSize
	return (w + 2 * border.__offset) / borderSize
end

local function setTextureCoordinates(border, tile)
	border.TOP:SetTexCoord(0.25, tile, 0.375, tile, 0.25, 0, 0.375, 0)
	border.BOTTOM:SetTexCoord(0.375, tile, 0.5, tile, 0.375, 0, 0.5, 0)
	border.LEFT:SetTexCoord(0, 0.125, 0, tile)
	border.RIGHT:SetTexCoord(0.125, 0.25, 0, tile)
end

local function onSizeChanged(self, w, h)
	local border = objectToWidgets[self]
	if not border then
		return
	end

	local tile = getTile(border, w, h)
	setTextureCoordinates(border, tile)
end

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
	local len = #borderSections
	if type(texture) == "table" then
		for i = 1, len do
			local v = borderSections[i]
			self[v.name]:SetColorTexture(unpack(texture))
		end
	else
		for i = 1, len do
			local v = borderSections[i]
			if i > 4 then
				self[v.name]:SetTexture(texture, "REPEAT", "REPEAT")
			else
				self[v.name]:SetTexture(texture)
			end
		end
	end
end

function Module:SetSize(size)
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

	local parentWidth, parentHeight = self.__parent:GetWidth(), self.__parent:GetHeight()
	onSizeChanged(self.__parent, parentWidth, parentHeight)
end

function Module:Hide()
	for _, section in ipairs(borderSections) do
		self[section.name]:Hide()
	end
end

function Module:Show()
	local len = #borderSections
	for i = 1, len do
		self[borderSections[i].name]:Show()
	end
end

function Module:SetShown(isShown)
	local len = #borderSections
	for i = 1, len do
		self[borderSections[i].name]:SetShown(isShown)
	end
end

function Module:GetVertexColor()
	return self.TOPLEFT:GetVertexColor()
end

function Module:SetVertexColor(r, g, b, a)
	for _, section in ipairs(borderSections) do
		self[section.name]:SetVertexColor(r, g, b, a)
	end
end

function Module:SetAlpha(a)
	local len = #borderSections
	for i = 1, len do
		self[borderSections[i].name]:SetAlpha(a)
	end
end

function Module:IsObjectType(t)
	return t == "Border"
end

function K:CreateBorder(drawLayer, drawSubLevel)
	local border = setmetatable({}, { __index = Module })
	border.__parent = self

	-- Ensure drawLayer is a string and drawSubLevel is a number
	-- The API passes: bSubLevel (string) as drawLayer, bLayer (number) as drawSubLevel
	local layer = type(drawLayer) == "string" and drawLayer or "OVERLAY"
	local subLevel = type(drawSubLevel) == "number" and drawSubLevel or 1

	for i = 1, #borderSections do
		local section = borderSections[i]
		border[section.name] = self:CreateTexture(nil, layer, nil, subLevel)
		border[section.name]:SetTexCoord(unpack(section.coord))
	end

	border.TOP:SetPoint("TOPLEFT", border.TOPLEFT, "TOPRIGHT", 0, 0)
	border.TOP:SetPoint("TOPRIGHT", border.TOPRIGHT, "TOPLEFT", 0, 0)

	border.BOTTOM:SetPoint("BOTTOMLEFT", border.BOTTOMLEFT, "BOTTOMRIGHT", 0, 0)
	border.BOTTOM:SetPoint("BOTTOMRIGHT", border.BOTTOMRIGHT, "BOTTOMLEFT", 0, 0)

	border.LEFT:SetPoint("TOPLEFT", border.TOPLEFT, "BOTTOMLEFT", 0, 0)
	border.LEFT:SetPoint("BOTTOMLEFT", border.BOTTOMLEFT, "TOPLEFT", 0, 0)

	border.RIGHT:SetPoint("TOPRIGHT", border.TOPRIGHT, "BOTTOMRIGHT", 0, 0)
	border.RIGHT:SetPoint("BOTTOMRIGHT", border.BOTTOMRIGHT, "TOPRIGHT", 0, 0)

	self:HookScript("OnSizeChanged", onSizeChanged)

	objectToWidgets[self] = border

	border:SetOffset(-4)
	border:SetSize(getBorderSize)

	return border
end
