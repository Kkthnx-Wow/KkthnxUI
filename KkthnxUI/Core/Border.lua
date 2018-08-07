local ADDON = ...
local K, C = unpack(select(2, ...))

-- Sourced: oUF_Phanx (Phanx)
-- Edited: KkthnxUI (Kkthnx)
-- Rewrite: Lars "Goldpaw" Norberg (Optimization and standard border texture compatibility)

-- Speeed!!!
local _G = _G
local pairs = _G.pairs
local type = _G.type

-- Default border values
local borderOffset = 4
local borderSize = 16
local borderPath = [[Interface\AddOns\]] .. ADDON .. [[\Media\Border\Border.tga]]

-- Local cache of our borders
-- *We don't expose these directly to the modules,
-- to minimize attached keys and avoid outside tampering.
local borderCache = {}

-- Template methods for our borders
-- *Note that these methods only exist on the frame
-- when border has been created in the first place,
-- so there's no need for any additional existence checks.
local BorderTemplate = {
	-- Set or update the border color and alpha.
	SetBorderColor = function(self, r, g, b, a)
		local borderColor = C["Media"].BorderColor

		if C["General"].ColorTextures then
			local textureColor = C["General"].TexturesColor
			r = textureColor[1] or r or borderColor[1]
			g = textureColor[2] or g or borderColor[2]
			b = textureColor[3] or b or borderColor[3]
		else
			r = r or borderColor[1]
			g = g or borderColor[2]
			b = b or borderColor[3]
		end

		-- Alpha will always return to fully opaque
		-- if not included in the function arguments.
		a = a or 1

		-- Apply the colors to all the textures in the cache
		local cache = borderCache[self]
		for id in pairs(cache) do
			cache[id]:SetVertexColor(r, g, b, a)
		end
	end,

	-- Retrieve the current border color and alpha.
	GetBorderColor = function(self)
		-- All textures have the same vertex color,
		-- so just retrieve it from the first one
		return borderCache[self][1]:GetVertexColor()
	end,

	-- Show the border
	ShowBorder = function(self)
		local cache = borderCache[self]
		for id in pairs(cache) do
			cache[id]:Show()
		end
	end,

	-- Hide the border
	HideBorder = function(self)
		local cache = borderCache[self]
		for id in pairs(cache) do
			cache[id]:Hide()
		end
	end
}

-- Redirecting WoW API calls to our own
BorderTemplate.SetBackdropBorderColor = BorderTemplate.SetBorderColor
BorderTemplate.GetBackdropBorderColor = BorderTemplate.GetBorderColor

-- Usage:
-- K.CreateBorder(object, [offset], [size], [path])
-- 	@param object 	<frame> 		- the frame we attach the border too
-- 	@param offset 	<number,nil> 	- (optional) pixels the border is offset into the frame
-- 	@param size 	<number,nil> 	- (optional) pixel thickness of the border
-- 	@param path 	<string,nil> 	- (optional) file path to the border texture
function K.CreateBorder(object, offset, size, path)
	-- Silently fail if the wrong object type or if the border already exists.
	if type(object) ~= "table" or borderCache[object] or not object.CreateTexture then
		return
	end

	-- Always replace missing values with our defaults,
	-- but allow even the texture path to be overridden
	-- to allow for a more flexible function than the previous one.
	local offset = offset or borderOffset
	local size = size or borderSize
	local path = path or borderPath

	-- First create the corners
	local topLeft = object:CreateTexture()
	topLeft:SetDrawLayer("OVERLAY")
	topLeft:SetPoint("TOPLEFT", object, "TOPLEFT", offset - size, -offset + size)
	topLeft:SetSize(size, size)
	topLeft:SetTexture(path)
	topLeft:SetTexCoord(4 / 8, 5 / 8, 0, 1)

	local topRight = object:CreateTexture()
	topRight:SetDrawLayer("OVERLAY")
	topRight:SetPoint("TOPRIGHT", object, "TOPRIGHT", -offset + size, -offset + size)
	topRight:SetSize(size, size)
	topRight:SetTexture(path)
	topRight:SetTexCoord(5 / 8, 6 / 8, 0, 1)

	local bottomLeft = object:CreateTexture()
	bottomLeft:SetDrawLayer("OVERLAY")
	bottomLeft:SetPoint("BOTTOMLEFT", object, "BOTTOMLEFT", offset - size, offset - size)
	bottomLeft:SetSize(size, size)
	bottomLeft:SetTexture(path)
	bottomLeft:SetTexCoord(6 / 8, 7 / 8, 0, 1)

	local bottomRight = object:CreateTexture()
	bottomRight:SetDrawLayer("OVERLAY")
	bottomRight:SetPoint("BOTTOMRIGHT", object, "BOTTOMRIGHT", -offset + size, offset - size)
	bottomRight:SetSize(size, size)
	bottomRight:SetTexture(path)
	bottomRight:SetTexCoord(7 / 8, 8 / 8, 0, 1)

	-- Then create the sides, which are connected to the corners
	local left = object:CreateTexture()
	left:SetDrawLayer("OVERLAY")
	left:SetPoint("TOPLEFT", topLeft, "BOTTOMLEFT")
	left:SetPoint("BOTTOMRIGHT", bottomLeft, "TOPRIGHT")
	left:SetTexture(path)
	left:SetTexCoord(0 / 8, 1 / 8, 0, 1)

	local right = object:CreateTexture()
	right:SetDrawLayer("OVERLAY")
	right:SetPoint("TOPRIGHT", topRight, "BOTTOMRIGHT")
	right:SetPoint("BOTTOMLEFT", bottomRight, "TOPLEFT")
	right:SetTexture(path)
	right:SetTexCoord(1 / 8, 2 / 8, 0, 1)

	-- top and bottom needs to be rotated 90 degrees clockwise,
	-- so we need to use the (ULx, ULy, LLx, LLy, URx, URy, LRx, LRy) version of texcoord here.
	local top = object:CreateTexture()
	top:SetDrawLayer("OVERLAY")
	top:SetPoint("TOPLEFT", topLeft, "TOPRIGHT")
	top:SetPoint("BOTTOMRIGHT", topRight, "BOTTOMLEFT")
	top:SetTexture(path)
	top:SetTexCoord(2 / 8, 1, 3 / 8, 1, 2 / 8, 0, 3 / 8, 0)

	local bottom = object:CreateTexture()
	bottom:SetDrawLayer("OVERLAY")
	bottom:SetPoint("BOTTOMLEFT", bottomLeft, "BOTTOMRIGHT")
	bottom:SetPoint("TOPRIGHT", bottomRight, "TOPLEFT")
	bottom:SetTexture(path)
	bottom:SetTexCoord(3 / 8, 1, 4 / 8, 1, 3 / 8, 0, 4 / 8, 0)

	-- Store the border textures in our local cache,
	-- without directly exposing the textures to the modules.
	borderCache[object] = {left, right, top, bottom, topLeft, topRight, bottomLeft, bottomRight}

	-- Embed our custom border template methods into the frame,
	-- and replace some standard Blizzard API calls for compatibility.
	for name, func in pairs(BorderTemplate) do
		object[name] = func
	end
end
