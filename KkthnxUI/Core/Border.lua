local K, C = unpack(select(2, ...))

-- Sourced: oUF_Phanx (Phanx)
-- Edited: KkthnxUI (Kkthnx)

-- GLOBALS: unpack, select, _G, next, pairs, type

-- luacheck: globals unpack select _G next pairs type

-- WoW API
local next = next
local pairs = pairs
local select = select
local type = type
local unpack = unpack

local border_path = "Interface\\AddOns\\KkthnxUI\\Media\\Border\\Border_"
local shadow_path = "Interface\\AddOns\\KkthnxUI\\Media\\Border\\border-thick-glow-"
local sections = {"TOPLEFT", "TOP", "TOPRIGHT", "RIGHT", "BOTTOMRIGHT", "BOTTOM", "BOTTOMLEFT", "LEFT"}

local function SetBorderColor(self, r, g, b, a)
	local t = self.borderTextures
	if not t then return end

	for _, tex in pairs(t) do
		tex:SetVertexColor(r or C["Media"].BorderColor[1], g or C["Media"].BorderColor[2], b or C["Media"].BorderColor[3])

		if C["General"].ColorTextures then
			tex:SetVertexColor(C["General"].TexturesColor[1], C["General"].TexturesColor[2], C["General"].TexturesColor[3])
		end
	end
end

local function SetBackdropBorderColor(self, r, g, b, a)
	local t = self.borderTextures
	if not t then return end

	for _, tex in pairs(t) do
		tex:SetVertexColor(r or C["Media"].BorderColor[1], g or C["Media"].BorderColor[2], b or C["Media"].BorderColor[3])

		if C["General"].ColorTextures then
			tex:SetVertexColor(C["General"].TexturesColor[1], C["General"].TexturesColor[2], C["General"].TexturesColor[3])
		end
	end
end

local function GetBorderColor(self)
	return self.borderTextures and self.borderTextures.TOPLEFT:GetVertexColor()
end

local function ShowBorder(self)
	local t = self.borderTextures
	if not t then return end

	for _, tex in next, t do
		tex:Show()
	end
end

local function HideBorder(self)
	local t = self.borderTextures
	if not t then return end

	for _, tex in next, t do
		tex:Hide()
	end
end

local function CreateBorder(object, offset)
	local t = {}
	local thickness = 16
	local texture = border_path
	local offset = offset or 4

	for i = 1, #sections do
		local x = object:CreateTexture(nil, "OVERLAY", nil, 1)
		x:SetTexture(texture..sections[i])
		t[sections[i]] = x
	end

	t.TOPLEFT:SetSize(thickness, thickness)
	t.TOPLEFT:SetPoint("BOTTOMRIGHT", object, "TOPLEFT", offset, -offset)

	t.TOPRIGHT:SetSize(thickness, thickness)
	t.TOPRIGHT:SetPoint("BOTTOMLEFT", object, "TOPRIGHT", -offset, -offset)

	t.BOTTOMLEFT:SetSize(thickness, thickness)
	t.BOTTOMLEFT:SetPoint("TOPRIGHT", object, "BOTTOMLEFT", offset, offset)

	t.BOTTOMRIGHT:SetSize(thickness, thickness)
	t.BOTTOMRIGHT:SetPoint("TOPLEFT", object, "BOTTOMRIGHT", -offset, offset)

	t.TOP:SetHeight(thickness)
	t.TOP:SetHorizTile(true)
	t.TOP:SetPoint("TOPLEFT", t.TOPLEFT, "TOPRIGHT", 0, 0)
	t.TOP:SetPoint("TOPRIGHT", t.TOPRIGHT, "TOPLEFT", 0, 0)

	t.BOTTOM:SetHeight(thickness)
	t.BOTTOM:SetHorizTile(true)
	t.BOTTOM:SetPoint("BOTTOMLEFT", t.BOTTOMLEFT, "BOTTOMRIGHT", 0, 0)
	t.BOTTOM:SetPoint("BOTTOMRIGHT", t.BOTTOMRIGHT, "BOTTOMLEFT", 0, 0)

	t.LEFT:SetWidth(thickness)
	t.LEFT:SetVertTile(true)
	t.LEFT:SetPoint("TOPLEFT", t.TOPLEFT, "BOTTOMLEFT", 0, 0)
	t.LEFT:SetPoint("BOTTOMLEFT", t.BOTTOMLEFT, "TOPLEFT", 0, 0)

	t.RIGHT:SetWidth(thickness)
	t.RIGHT:SetVertTile(true)
	t.RIGHT:SetPoint("TOPRIGHT", t.TOPRIGHT, "BOTTOMRIGHT", 0, 0)
	t.RIGHT:SetPoint("BOTTOMRIGHT", t.BOTTOMRIGHT, "TOPRIGHT", 0, 0)

	object.borderTextures = t
	object.SetBorderColor = SetBorderColor
	object.SetBackdropBorderColor = SetBackdropBorderColor
	object.GetBorderColor = GetBorderColor
	object.ShowBorder = ShowBorder
	object.HideBorder = HideBorder
end

function K.CreateBorder(object, offset)
	if type(object) ~= "table" or not object.CreateTexture or object.borderTextures then
		return
	end

	CreateBorder(object, offset)
end

local function SetGlowColor(self, r, g, b, a)
	local t = self._t
	if not t then return end

	for _, tex in next, t do
		tex:SetVertexColor(r or 1, g or 1, b or 1, a or 1)
	end
end

local function GetGlowColor(self)
	return self._t and self._t.TOPLEFT:GetVertexColor()
end

local function ShowGlow(self)
	local t = self._t
	if not t then return end

	for _, tex in next, t do
		tex:Show()
	end
end

local function HideGlow(self)
	local t = self._t
	if not t then return end

	for _, tex in next, t do
		tex:Hide()
	end
end

local function CreateBorderGlow(object, offset)
	local t = {}
	local thickness = 16
	local texture = shadow_path
	local offset = offset or 4

	for i = 1, #sections do
		local x = object:CreateTexture(nil, "BACKGROUND", nil, -7)
		x:SetTexture(texture..sections[i])
		t[sections[i]] = x
	end

	t.TOPLEFT:SetSize(thickness, thickness)
	t.TOPLEFT:SetPoint("BOTTOMRIGHT", object, "TOPLEFT", offset, -offset)

	t.TOPRIGHT:SetSize(thickness, thickness)
	t.TOPRIGHT:SetPoint("BOTTOMLEFT", object, "TOPRIGHT", -offset, -offset)

	t.BOTTOMLEFT:SetSize(thickness, thickness)
	t.BOTTOMLEFT:SetPoint("TOPRIGHT", object, "BOTTOMLEFT", offset, offset)

	t.BOTTOMRIGHT:SetSize(thickness, thickness)
	t.BOTTOMRIGHT:SetPoint("TOPLEFT", object, "BOTTOMRIGHT", -offset, offset)

	t.TOP:SetHeight(thickness)
	t.TOP:SetHorizTile(true)
	t.TOP:SetPoint("TOPLEFT", t.TOPLEFT, "TOPRIGHT", 0, 0)
	t.TOP:SetPoint("TOPRIGHT", t.TOPRIGHT, "TOPLEFT", 0, 0)

	t.BOTTOM:SetHeight(thickness)
	t.BOTTOM:SetHorizTile(true)
	t.BOTTOM:SetPoint("BOTTOMLEFT", t.BOTTOMLEFT, "BOTTOMRIGHT", 0, 0)
	t.BOTTOM:SetPoint("BOTTOMRIGHT", t.BOTTOMRIGHT, "BOTTOMLEFT", 0, 0)

	t.LEFT:SetWidth(thickness)
	t.LEFT:SetVertTile(true)
	t.LEFT:SetPoint("TOPLEFT", t.TOPLEFT, "BOTTOMLEFT", 0, 0)
	t.LEFT:SetPoint("BOTTOMLEFT", t.BOTTOMLEFT, "TOPLEFT", 0, 0)

	t.RIGHT:SetWidth(thickness)
	t.RIGHT:SetVertTile(true)
	t.RIGHT:SetPoint("TOPRIGHT", t.TOPRIGHT, "BOTTOMRIGHT", 0, 0)
	t.RIGHT:SetPoint("BOTTOMRIGHT", t.BOTTOMRIGHT, "TOPRIGHT", 0, 0)

	return {
		_t = t,
		SetVertexColor = SetGlowColor,
		GetVertexColor = GetGlowColor,
		Show = ShowGlow,
		Hide = HideGlow,
		IsObjectType = K.Noop,
	}
end

function K.CreateBorderGlow(object, offset)
	if type(object) ~= "table" or not object.CreateTexture then
		return
	end

	return CreateBorderGlow(object, offset)
end