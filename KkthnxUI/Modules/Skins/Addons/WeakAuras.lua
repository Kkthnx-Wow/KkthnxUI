local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local _G = _G
local pairs = _G.pairs
local unpack = _G.unpack

local IsAddOnLoaded = _G.IsAddOnLoaded
local WeakAuras = _G.WeakAuras

-- WeakAuras skin
function Module:ReskinWeakAuras()
	if C["Skins"].WeakAuras ~= true then
		return
	end

	if not IsAddOnLoaded("WeakAuras") then
		return
	end

	local function Skin_WeakAuras(f, fType)
		if fType == "icon" then
			if not f.styled then
				f.icon:SetTexCoord(unpack(K.TexCoords))
				f.icon.SetTexCoord = K.Noop
				f:CreateBorder()
				--f.Shadow:HookScript("OnUpdate", function(self)
				--	self:SetAlpha(self:GetParent().icon:GetAlpha())
				--end)

				f.styled = true
			end
		elseif fType == "aurabar" then
			if not f.styled then
				f.bar:CreateBorder()
				f.icon:SetTexCoord(unpack(K.TexCoords))
				f.icon.SetTexCoord = K.Noop
				f.iconFrame:SetAllPoints(f.icon)
				f.iconFrame:CreateBorder()

				f.styled = true
			end
		end
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