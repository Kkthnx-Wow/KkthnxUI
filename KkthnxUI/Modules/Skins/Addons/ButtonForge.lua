local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Skins")

local cfgFont = K.UIFontOutline
local cfg = {
	icon = {
		texCoord = K.TexCoords,
	},

	flyoutBorder = {
		file = "",
	},

	flyoutBorderShadow = {
		file = "",
	},

	border = {
		file = "",
	},

	normalTexture = {
		file = "",
	},

	flash = {
		file = "",
	},

	cooldown = {
		points = {
			{ "TOPLEFT", 1, -1 },
			{ "BOTTOMRIGHT", -1, 1 },
		},
	},

	name = {
		font = cfgFont,
		points = {
			{ "BOTTOMLEFT", 0, 0 },
			{ "BOTTOMRIGHT", 0, 0 },
		},
	},

	hotkey = {
		font = cfgFont,
		points = {
			{ "TOPRIGHT", 0, -3 },
			{ "TOPLEFT", 0, -3 },
		},
	},

	count = {
		font = cfgFont,
		points = {
			{ "BOTTOMRIGHT", 2, 0 },
		},
	},

	buttonstyle = {
		file = "",
	},
}

function Module:ReskinButtonForge()
	if not C["Skins"].ButtonForge then
		return
	end

	if not C_AddOns.IsAddOnLoaded("ButtonForge") then
		return
	end

	local ActionBar = K:GetModule("ActionBar")

	local function callback(_, event, button)
		if event == "BUTTON_ALLOCATED" then
			local bu = _G[button]
			local icon = _G[button .. "Icon"]
			ActionBar:StyleActionButton(bu, cfg)
			icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
			icon.SetTexCoord = K.Noop
		end
	end
	ButtonForge_API1.RegisterCallback(callback)

	local buttons = {
		"BFToolbarCreateBar",
		"BFToolbarCreateBonusBar",
		"BFToolbarDestroyBar",
		"BFToolbarAdvanced",
		"BFToolbarConfigureAction",
		"BFToolbarRightClickSelfCast",
	}

	for _, button in next, buttons do
		local bu = _G[button]
		if bu then
			ActionBar:StyleActionButton(bu, cfg)
		end
	end

	BFToolbar:StripTextures()
	BFToolbar:CreateBorder()
	BFToolbarToggle:SkinCloseButton()

	BFBindingDialog:StripTextures()
	BFBindingDialog:CreateBorder()
	BFBindingDialogBinding:SkinButton()
	BFBindingDialogUnbind:SkinButton()

	BFBindingDialog.Toggle:SkinCloseButton()

	BFConfigPageToolbarToggle:SkinButton()

	hooksecurefunc(BFUtil, "NewBar", function()
		for i = 1, BFConfigureLayer:GetNumChildren() do
			local child = select(i, BFConfigureLayer:GetChildren())
			if child:GetObjectType() == "EditBox" and not child.styled then
				child:StripTextures(2)
				child:CreateBorder()
				child.styled = true
			end

			if child and child.ParentBar and not child.styled then
				child.ParentBar.Background:StripTextures()
				child.ParentBar.Background:CreateBorder()
				child.ParentBar.LabelFrame:StripTextures()
				child.styled = true
			end
		end
	end)

	hooksecurefunc(BFBar, "Configure", function(self)
		self:SetButtonGap(6) -- Spacing
	end)
end
