local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local _G = _G

local function ReskinColections()
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

	if not tt.IsSkinned then
		tt.Backgrounds = tt:CreateTexture(nil, "BACKGROUND", -2)
		tt.Backgrounds:SetAllPoints()
		tt.Backgrounds:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

		K.CreateBorder(tt)
		tt.IsSkinned = true
	end
end

Module.NewSkin["Blizzard_Collections"] = ReskinColections