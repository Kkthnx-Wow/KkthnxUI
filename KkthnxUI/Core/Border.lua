local K, C = unpack(KkthnxUI)
local Module = {}

local next = next
local type = type
local unpack = unpack

local objectToWidgets = {}
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

local function getBorderSizeChanged()
	return C["General"].BorderStyle.Value == "KkthnxUI" and 12 or 10
end

local function getTile(border, w, h)
	return (w + 2 * border.__offset) / getBorderSizeChanged()
end

local function setTextureCoordinates(border, tile)
	border.TOP:SetTexCoord(0.25, tile, 0.375, tile, 0.25, 0, 0.375, 0)
	border.BOTTOM:SetTexCoord(0.375, tile, 0.5, tile, 0.375, 0, 0.5, 0)
	border.LEFT:SetTexCoord(0, 0.125, 0, tile)
	border.RIGHT:SetTexCoord(0.125, 0.25, 0, tile)
end

local function onSizeChanged(self, w, h)
	local border = objectToWidgets[self]
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
	if type(texture) == "table" then
		for _, v in next, borderSections do
			self[v.name]:SetColorTexture(unpack(texture))
		end
	else
		for i, v in next, borderSections do
			if i > 4 then
				self[v.name]:SetTexture(texture, "REPEAT", "REPEAT")
			else
				self[v.name]:SetTexture(texture)
			end
		end
	end
end

function Module:SetSize(size)
	assert(type(size) == "number", "Size must be a number")
	self.__size = size
	for _, v in pairs(borderSections) do
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
	for _, v in next, borderSections do
		self[v.name]:Hide()
	end
end

function Module:Show()
	for _, v in next, borderSections do
		self[v.name]:Show()
	end
end

function Module:SetShown(isShown)
	for _, v in next, borderSections do
		self[v.name]:SetShown(isShown)
	end
end

function Module:GetVertexColor()
	return self.TOPLEFT:GetVertexColor()
end

function Module:SetVertexColor(r, g, b, a)
	for _, v in next, borderSections do
		self[v.name]:SetVertexColor(r, g, b, a)
	end
end

function Module:SetAlpha(a)
	for _, v in next, borderSections do
		self[v.name]:SetAlpha(a)
	end
end

function Module:IsObjectType(t)
	return t == "Border"
end

function K:CreateBorder(drawLayer, drawSubLevel)
	local border = Mixin({ __parent = self }, Module)
	for _, section in pairs(borderSections) do
		border[section.name] = self:CreateTexture(nil, drawLayer or "OVERLAY", nil, drawSubLevel or 1)
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
	border:SetSize(getBorderSizeChanged())

	return border
end
