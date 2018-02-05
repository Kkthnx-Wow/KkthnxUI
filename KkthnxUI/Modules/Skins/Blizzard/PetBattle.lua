local K, C = unpack(select(2, ...))

local _G = _G

local hooksecurefunc = _G.hooksecurefunc
local ITEM_QUALITY_COLORS = _G.ITEM_QUALITY_COLORS

local function LoadSkin()
	local function SkinPetTooltip(tt)
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
		tt:SetTemplate("Transparent", true)
	end

	SkinPetTooltip(PetBattlePrimaryAbilityTooltip)
	SkinPetTooltip(PetBattlePrimaryUnitTooltip)
	SkinPetTooltip(BattlePetTooltip)
	SkinPetTooltip(FloatingBattlePetTooltip)
	SkinPetTooltip(FloatingPetBattleAbilityTooltip)

	hooksecurefunc("BattlePetToolTip_Show", function(_, _, rarity)
		local quality = rarity and ITEM_QUALITY_COLORS[rarity]
		if quality and rarity > 1 then
			BattlePetTooltip:SetBackdropBorderColor(quality.r, quality.g, quality.b)
		else
			BattlePetTooltip:SetBackdropBorderColor(C["Media"].BorderColor[1], C["Media"].BorderColor[2], C["Media"].BorderColor[3])
		end
	end)

	hooksecurefunc("PetBattleAbilityTooltip_Show", function()
		local t = _G.PetBattlePrimaryAbilityTooltip
		t:ClearAllPoints()
		t:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -4, -4)
	end)
end

tinsert(K.SkinFuncs["KkthnxUI"], LoadSkin)