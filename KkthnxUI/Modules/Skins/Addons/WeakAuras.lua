local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Skins")

local unpack = unpack

local hooksecurefunc = hooksecurefunc

-- local function IconBgOnUpdate(self)
-- 	self:SetAlpha(self.__icon:GetAlpha())
-- end

local function UpdateIconTexCoord(icon)
	if icon.isCutting then
		return
	end
	icon.isCutting = true

	local width, height = icon:GetSize()
	if width ~= 0 and height ~= 0 then
		local left, right, top, bottom = unpack(K.TexCoords) -- normal icon
		local ratio = width / height
		if ratio > 1 then -- fat icon
			local offset = (1 - 1 / ratio) / 2
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

local function CreateIconBackground(parent)
	local bg = CreateFrame("Frame", nil, parent, "BackdropTemplate")
	bg:SetAllPoints(parent)
	bg:SetFrameLevel(parent:GetFrameLevel())
	bg:CreateBorder()
	return bg
end

local function ReskinWAIcon(icon)
	UpdateIconTexCoord(icon)
	hooksecurefunc(icon, "SetTexCoord", UpdateIconTexCoord)
	icon.bg = CreateIconBackground(icon)
	-- hooksecurefunc(icon, "SetVertexColor", UpdateIconBgAlpha)
end

local function ResetBGLevel(frame)
	frame.bg:SetFrameLevel(0)
end

local function Skin_WeakAuras(f, fType)
	if not f.styled then
		if fType == "icon" then
			ReskinWAIcon(f.icon)
		elseif fType == "aurabar" then
			f.bg = CreateIconBackground(f.bar)
			ReskinWAIcon(f.icon)
			hooksecurefunc(f, "SetFrameStrata", ResetBGLevel)
		end

		f.styled = true
	end

	if fType == "aurabar" then
		f.icon.bg:SetShown(not not f.iconVisible)
	end
end

local function ReskinWeakAuras()
	if not C["Skins"].WeakAuras then
		return
	end

	if WeakAuras.regionPrototype then
		local function OnPrototypeCreate(region)
			Skin_WeakAuras(region, region.regionType)
		end

		local function OnPrototypeModifyFinish(_, region)
			Skin_WeakAuras(region, region.regionType)
		end

		hooksecurefunc(WeakAuras.regionPrototype, "create", OnPrototypeCreate)
		hooksecurefunc(WeakAuras.regionPrototype, "modifyFinish", OnPrototypeModifyFinish)
	elseif WeakAuras.SetTextureOrAtlas then
		hooksecurefunc(WeakAuras, "SetTextureOrAtlas", function(icon)
			local parent = icon:GetParent()
			if parent then
				local region = parent.regionType and parent or parent:GetParent()
				if region.regionType then
					Skin_WeakAuras(region, region.regionType)
				end
			end
		end)
	end
end

Module:RegisterSkin("WeakAuras", ReskinWeakAuras)
