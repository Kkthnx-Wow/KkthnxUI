local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

function Module:ReskinTitanPanel()
	if not C["Skins"].TitanPanel then
		return
	end

	if not (K.CheckAddOnState("Titan")) then
		return
	end

	C_Timer.After(2, function()
		Titan_Bar__Display_Bar:StripTextures()
		Titan_Bar__Display_Bar2:StripTextures()
		Titan_Bar__Display_AuxBar:StripTextures()
		Titan_Bar__Display_AuxBar2:StripTextures()

		Titan_Bar__Display_Bar:CreateBorder()
		Titan_Bar__Display_Bar2:CreateBorder()
		Titan_Bar__Display_AuxBar:CreateBorder()
		Titan_Bar__Display_AuxBar2:CreateBorder()

		if RaidUtility_ShowButton then
			RaidUtility_ShowButton:SetFrameStrata('TOOLTIP')
		end
	end)
end