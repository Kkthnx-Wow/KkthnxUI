local K, C, _ = select(2, ...):unpack()

local _G = _G
local floor = math.floor
local pairs, type = pairs, type
local unpack = unpack

local BORDER_TEXTURE = "Interface\\AddOns\\KkthnxUI\\Media\\Border\\Border"
local BORDER_SIZE = 12
local TEXTURE_SIZE = 64
local CORNER_SIZE = 12
local OFFSET_SIZE = 6
local BORDER_LAYER = "OVERLAY"

borderedObjects = {}

local sections = {"TOPLEFT", "TOP", "TOPRIGHT", "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT", "LEFT", "RIGHT"}

local function SetBackdropBorderColor(self, r, g, b, a)
	local t = self.BorderTextures
	if not t then return end

	if not r or not g or not b or a == 0 then
		r, g, b = unpack(C.Media.Border_Color)
	end

	for pos, tex in pairs(t) do
		tex:SetVertexColor(r, g, b)
	end
end

local function GetBorderColor(self)
	return self.BorderTextures and self.BorderTextures.TOPLEFT:GetVertexColor()
end

local function SetBorderParent(self, parent)
	local t = self.BorderTextures
	if not t then return end
	if not parent then
		parent = type(self.overlay) == "Frame" and self.overlay or self
	end
	for pos, tex in pairs(t) do
		tex:SetParent(parent)
	end
	self:SetBorderSize(self:GetBorderSize())
end

local function GetBorderParent(self)
	return self.BorderTextures and self.BorderTextures.TOPLEFT:GetParent()
end

local function SetBorderSize(self, size, dL, dR, dT, dB)
	local t = self.BorderTextures
	if not t then return end

	size = size or BORDER_SIZE
	dL, dR, dT, dB = dL or t.LEFT.offset or 0, dR or t.RIGHT.offset or 0, dT or t.TOP.offset or 0, dB or t.BOTTOM.offset or 0

	for pos, tex in pairs(t) do
		tex:SetSize(size, size)
	end

	local d = floor(size * (OFFSET_SIZE / CORNER_SIZE) + 0.5)
	local parent = t.TOPLEFT:GetParent()

	t.TOPLEFT:SetPoint("TOPLEFT", parent, -d - dL, d + dT)
	t.TOPRIGHT:SetPoint("TOPRIGHT", parent, d + dR, d + dT)
	t.BOTTOMLEFT:SetPoint("BOTTOMLEFT", parent, -d - dL, -d - dB)
	t.BOTTOMRIGHT:SetPoint("BOTTOMRIGHT", parent, d + dR, -d - dB)

	t.LEFT.offset, t.RIGHT.offset, t.TOP.offset, t.BOTTOM.offset = dL, dR, dT, dB
end

local function GetBorderSize(self)
	local t = self.BorderTextures
	if not t then return end
	return t.TOPLEFT:GetWidth(), t.LEFT.offset, t.RIGHT.offset, t.TOP.offset, t.BOTTOM.offset
end

function K.CreateBorder(self, size, offset, parent, layer)
	if type(self) ~= "table" or not self.CreateTexture or self.BorderTextures then return end

	local t = {}

	for i = 1, #sections do
		local x = self:CreateTexture(nil, layer or BORDER_LAYER)
		x:SetTexture(BORDER_TEXTURE)
		t[sections[i]] = x
	end

	local ONETHIRD = CORNER_SIZE / TEXTURE_SIZE
	local TWOTHIRDS = (TEXTURE_SIZE - CORNER_SIZE) / TEXTURE_SIZE

	t.TOPLEFT:SetTexCoord(0, ONETHIRD, 0, ONETHIRD)
	t.TOP:SetTexCoord(ONETHIRD, TWOTHIRDS, 0, ONETHIRD)
	t.TOPRIGHT:SetTexCoord(TWOTHIRDS, 1, 0, ONETHIRD)
	t.RIGHT:SetTexCoord(TWOTHIRDS, 1, ONETHIRD, TWOTHIRDS)
	t.BOTTOMRIGHT:SetTexCoord(TWOTHIRDS, 1, TWOTHIRDS, 1)
	t.BOTTOM:SetTexCoord(ONETHIRD, TWOTHIRDS, TWOTHIRDS, 1)
	t.BOTTOMLEFT:SetTexCoord(0, ONETHIRD, TWOTHIRDS, 1)
	t.LEFT:SetTexCoord(0, ONETHIRD, ONETHIRD, TWOTHIRDS)

	t.TOP:SetPoint("TOPLEFT", t.TOPLEFT, "TOPRIGHT")
	t.TOP:SetPoint("TOPRIGHT", t.TOPRIGHT, "TOPLEFT")

	t.RIGHT:SetPoint("TOPRIGHT", t.TOPRIGHT, "BOTTOMRIGHT")
	t.RIGHT:SetPoint("BOTTOMRIGHT", t.BOTTOMRIGHT, "TOPRIGHT")

	t.BOTTOM:SetPoint("BOTTOMLEFT", t.BOTTOMLEFT, "BOTTOMRIGHT")
	t.BOTTOM:SetPoint("BOTTOMRIGHT", t.BOTTOMRIGHT, "BOTTOMLEFT")

	t.LEFT:SetPoint("TOPLEFT", t.TOPLEFT, "BOTTOMLEFT")
	t.LEFT:SetPoint("BOTTOMLEFT", t.BOTTOMLEFT, "TOPLEFT")

	self.BorderTextures = t

	self.SetBackdropBorderColor  = SetBackdropBorderColor
	self.SetBorderLayer  = SetBorderLayer
	self.SetBorderParent = SetBorderParent
	self.SetBorderSize   = SetBorderSize

	self.GetBorderColor  = GetBorderColor
	self.GetBorderLayer  = GetBorderLayer
	self.GetBorderParent = GetBorderParent
	self.GetBorderSize   = GetBorderSize

	if self.GetBackdrop then
		local backdrop = self:GetBackdrop()
		if type(backdrop) == "table" then
			if backdrop.edgeFile then
				backdrop.edgeFile = nil
			end
			if backdrop.insets then
				backdrop.insets.top = 0
				backdrop.insets.right = 0
				backdrop.insets.bottom = 0
				backdrop.insets.left = 0
			end
			self:SetBackdrop(backdrop)
		end
	end

	if self.SetBackdropBorderColor then
		self.SetBackdropBorderColor = SetBackdropBorderColor
	end

	tinsert(borderedObjects, self)

	self:SetBackdropBorderColor()
	self:SetBorderParent(parent)
	self:SetBorderSize(size, offset)

	return true
end

_G.CreateBorder = K.CreateBorder