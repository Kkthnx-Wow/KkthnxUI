local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local _G = _G
local table_insert = table.insert

local hooksecurefunc = _G.hooksecurefunc
local ITEM_QUALITY_COLORS = _G.ITEM_QUALITY_COLORS
local UIParent = _G.UIParent

local function SkinPetTooltip()
	local function SetPetTooltip(tt)
		tt.Background:SetTexture(nil)

		if tt.Delimiter1 then
			tt.Delimiter1:SetTexture(nil)
			tt.Delimiter2:SetTexture(nil)
		end

		tt.BorderTop:SetTexture(nil)
		tt.BorderTopLeft:SetTexture(nil)
		tt.BorderTopRight:SetTexture(nil)
		tt.BorderLeft:SetTexture(nil)
		tt.BorderRight:SetTexture(nil)
		tt.BorderBottom:SetTexture(nil)
		tt.BorderBottomRight:SetTexture(nil)
		tt.BorderBottomLeft:SetTexture(nil)

		tt.Backgrounds = tt:CreateTexture(nil, "BACKGROUND", -1)
		tt.Backgrounds:SetAllPoints()
		tt.Backgrounds:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

		tt.Borders = CreateFrame("Frame", nil, tt)
		tt.Borders:SetAllPoints()
		K.CreateBorder(tt.Borders)
	end

	SetPetTooltip(PetBattlePrimaryAbilityTooltip)
	SetPetTooltip(PetBattlePrimaryUnitTooltip)
	SetPetTooltip(BattlePetTooltip)
	SetPetTooltip(FloatingBattlePetTooltip)
	SetPetTooltip(FloatingPetBattleAbilityTooltip)

	hooksecurefunc("BattlePetToolTip_Show", function(_, _, rarity)
		local quality = rarity and ITEM_QUALITY_COLORS[rarity]
		if quality and rarity > 1 then
			BattlePetTooltip:SetBackdropBorderColor(quality.r, quality.g, quality.b)
		else
			BattlePetTooltip:SetColorTexture(C["Media"].BorderColor[1], C["Media"].BorderColor[2], C["Media"].BorderColor[3])
		end
	end)

	hooksecurefunc("PetBattleAbilityTooltip_Show", function()
		local t = _G.PetBattlePrimaryAbilityTooltip
		t:ClearAllPoints()
		t:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -4, -4)
	end)
end

table_insert(Module.SkinFuncs["KkthnxUI"], SkinPetTooltip)