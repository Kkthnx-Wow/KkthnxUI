local K = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local _G = _G

local function SkinPetJournalTooltip()
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
	tt:SetTemplate("Transparent")
end

Module.SkinFuncs["Blizzard_Collections"] = SkinPetJournalTooltip