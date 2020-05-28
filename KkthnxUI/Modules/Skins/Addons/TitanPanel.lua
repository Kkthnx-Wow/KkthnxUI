--local K, C = unpack(select(2, ...))
--local Module = K:GetModule("Skins")

--function Module:ReskinTitanPanel()
--	if not C["Skins"].TitanClassic then
--		return
--	end

--	if not (K.CheckAddOnState("Titan") or K.CheckAddOnState("TitanClassic")) then
--		return
--	end

--	K.Delay(1, function()
--		Titan_Bar__Display_Bar:CreateBorder(nil, nil, nil, true)
--		Titan_Bar__Display_Bar2:CreateBorder(nil, nil, nil, true)
--        Titan_Bar__Display_AuxBar:CreateBorder(nil, nil, nil, true)
--        Titan_Bar__Display_AuxBar2:CreateBorder(nil, nil, nil, true)

--		if RaidUtility_ShowButton then
--			RaidUtility_ShowButton:SetFrameStrata("TOOLTIP")
--		end
--	end)
--end