local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local _G = _G
local pairs = _G.pairs
local unpack = _G.unpack

local IsAddOnLoaded = _G.IsAddOnLoaded
local hooksecurefunc = _G.hooksecurefunc

local function IconBgOnUpdate(self)
	self:SetAlpha(self.__icon:GetAlpha())
end

local function UpdateIconTexCoord(icon)
	if icon.isCutting then return end
	icon.isCutting = true

	local width, height = icon:GetSize()
	if width ~= 0 and height ~= 0 then
		local left, right, top, bottom = unpack(K.TexCoords) -- normal icon
		local ratio = width/height
		if ratio > 1 then -- fat icon
			local offset = (1 - 1/ratio) / 2
			top = top + offset
			bottom = bottom - offset
		elseif ratio < 1 then -- thin icon
			local offset = (1 - ratio) / 2
			left = left + offset
			bottom = bottom - offset
		end
		icon:SetTexCoord(left, right, top, bottom)
	end

	icon.isCutting = nil
end

local function Skin_WeakAuras(f, fType)
	if fType == "icon" then
		if not f.styled then
			UpdateIconTexCoord(f.icon)
			hooksecurefunc(f.icon, "SetTexCoord", UpdateIconTexCoord)
			f.bg = CreateFrame("Frame", nil, f, "BackdropTemplate")
			f.bg:SetAllPoints(f)
			f.bg:SetFrameLevel(f:GetFrameLevel())
			f.bg:CreateBorder()
			f.bg.__icon = f.icon
			f.bg:HookScript("OnUpdate", IconBgOnUpdate)

			f.styled = true
		end
	elseif fType == "aurabar" then
		if not f.styled then
			f.bg = CreateFrame("Frame", nil, f.bar, "BackdropTemplate")
			f.bg:SetAllPoints(f.bar)
			f.bg:SetFrameLevel(f.bar:GetFrameLevel())
			f.bg:CreateBorder()
			UpdateIconTexCoord(f.icon)
			hooksecurefunc(f.icon, "SetTexCoord", UpdateIconTexCoord)
			f.iconFrame:SetAllPoints(f.icon)
			f.iconFrame:CreateBorder()

			f.styled = true
		end
	end
end

local function ReskinWeakAuras()
	if not C["Skins"].WeakAuras then
		return
	end

	local regionTypes = WeakAuras.regionTypes
	local Create_Icon, Modify_Icon = regionTypes.icon.create, regionTypes.icon.modify
	local Create_AuraBar, Modify_AuraBar = regionTypes.aurabar.create, regionTypes.aurabar.modify

	regionTypes.icon.create = function(parent, data)
		local region = Create_Icon(parent, data)
		Skin_WeakAuras(region, "icon")
		return region
	end

	regionTypes.aurabar.create = function(parent)
		local region = Create_AuraBar(parent)
		Skin_WeakAuras(region, "aurabar")
		return region
	end

	regionTypes.icon.modify = function(parent, region, data)
		Modify_Icon(parent, region, data)
		Skin_WeakAuras(region, "icon")
	end

	regionTypes.aurabar.modify = function(parent, region, data)
		Modify_AuraBar(parent, region, data)
		Skin_WeakAuras(region, "aurabar")
	end

	for weakAura in pairs(WeakAuras.regions) do
		local regions = WeakAuras.regions[weakAura]
		if regions.regionType == "icon" or regions.regionType == "aurabar" then
			Skin_WeakAuras(regions.region, regions.regionType)
		end
	end
end

Module:LoadWithAddOn("WeakAuras", "WeakAuras", ReskinWeakAuras)