local K, C = unpack(select(2, ...))
if C["Skins"].WeakAuras ~= true or not K.CheckAddOnState("WeakAuras") then return end

local _G = _G
local pairs = pairs

local CreateFrame = _G.CreateFrame
local WeakAuras = _G.WeakAuras

-- WeakAuras skin
local WeakAura_Skin = CreateFrame("Frame")
WeakAura_Skin:RegisterEvent("PLAYER_LOGIN")
WeakAura_Skin:SetScript("OnEvent", function(self, event)
	local function Skin_WeakAuras(frame, ftype)
		if not frame.Shadow then
			frame:CreateShadow()

			if frame.icon then
				frame.icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
				frame.icon.SetTexCoord = K.Noop
			end

			if ftype == "icon" then
				frame.Shadow:HookScript("OnUpdate", function(self)
					self:SetAlpha(self:GetParent().icon:GetAlpha())
				end)
			end
		end

		if ftype == "aurabar" then
			frame.Shadow:Show() -- Want to adjust this to fit better.
		end
	end

	local Create_Icon, Modify_Icon = WeakAuras.regionTypes.icon.create, WeakAuras.regionTypes.icon.modify
	local Create_AuraBar, Modify_AuraBar = WeakAuras.regionTypes.aurabar.create, WeakAuras.regionTypes.aurabar.modify

	WeakAuras.regionTypes.icon.create = function(parent, data)
		local region = Create_Icon(parent, data)
		Skin_WeakAuras(region, "icon")
		return region
	end

	WeakAuras.regionTypes.aurabar.create = function(parent)
		local region = Create_AuraBar(parent)
		Skin_WeakAuras(region, "aurabar")
		return region
	end

	WeakAuras.regionTypes.icon.modify = function(parent, region, data)
		Modify_Icon(parent, region, data)
		Skin_WeakAuras(region, "icon")
	end

	WeakAuras.regionTypes.aurabar.modify = function(parent, region, data)
		Modify_AuraBar(parent, region, data)
		Skin_WeakAuras(region, "aurabar")
	end

	for weakAura, _ in pairs(WeakAuras.regions) do
		if WeakAuras.regions[weakAura].regionType == "icon"
		or WeakAuras.regions[weakAura].regionType == "aurabar" then
			Skin_WeakAuras(WeakAuras.regions[weakAura].region, WeakAuras.regions[weakAura].regionType)
		end
	end
end)