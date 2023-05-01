local K, C = KkthnxUI[1], KkthnxUI[2]

tinsert(C.defaultThemes, function()
	if not C["Skins"].BlizzardFrames then
		return
	end

	local cr, cg, cb = K.r, K.g, K.b

	AddonList:StripTextures()
	AddonList:CreateBorder()
	AddonListEnableAllButton:SkinButton()
	AddonListDisableAllButton:SkinButton()
	AddonListCancelButton:SkinButton()
	AddonListOkayButton:SkinButton()
	AddonListForceLoad:SkinCheckBox()
	-- B.ReskinDropDown(AddonCharacterDropDown)
	-- B.ReskinTrimScroll(AddonList.ScrollBar)

	AddonListForceLoad:SetSize(16, 16)
	AddonCharacterDropDown:SetWidth(170)

	local function forceSaturation(self, _, force)
		if force then
			return
		end
		self:SetVertexColor(cr, cg, cb)
		self:SetDesaturated(true, true)
	end

	hooksecurefunc("AddonList_InitButton", function(entry)
		if not entry.styled then
			entry.Enabled:SkinCheckBox(true)
			entry.Enabled:SetSize(16, 16)
			entry.LoadAddonButton:SkinButton()
			hooksecurefunc(entry.Enabled:GetCheckedTexture(), "SetDesaturated", forceSaturation)

			entry.styled = true
		end
	end)
end)
