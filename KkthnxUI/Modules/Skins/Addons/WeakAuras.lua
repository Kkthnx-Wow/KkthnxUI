local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Skins")

local _G = _G
local unpack = _G.unpack

local hooksecurefunc = _G.hooksecurefunc

local function IconBgOnUpdate(self)
	self:SetAlpha(self.__icon:GetAlpha())
end

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

	local function OnPrototypeCreate(region)
		Skin_WeakAuras(region, region.regionType)
	end

	local function OnPrototypeModifyFinish(_, region)
		Skin_WeakAuras(region, region.regionType)
	end

	hooksecurefunc(WeakAuras.regionPrototype, "create", OnPrototypeCreate)
	hooksecurefunc(WeakAuras.regionPrototype, "modifyFinish", OnPrototypeModifyFinish)
end

Module:RegisterSkin("WeakAuras", ReskinWeakAuras)
