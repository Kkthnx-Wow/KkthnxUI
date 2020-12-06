local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

function Module:ReskinChocolateBar()
	if not C["Skins"].ChocolateBar then
		return
	end

	if not (K.CheckAddOnState("ChocolateBar")) then
		return
	end

	for i = 1, 20 do
		local chocolateFrame = _G["ChocolateBar"..i]
		if chocolateFrame then
			chocolateFrame:StripTextures()
			chocolateFrame:CreateBorder()
		end
	end

	if RaidUtility_ShowButton then
		RaidUtility_ShowButton:SetFrameStrata("TOOLTIP")
	end
end