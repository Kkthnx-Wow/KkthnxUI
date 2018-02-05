local K, C = unpack(select(2, ...))

local _G = _G

local function LoadSkin()
	local tt = _G.PetJournalPrimaryAbilityTooltip
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

K.SkinFuncs["Blizzard_Collections"] = LoadSkin