local K, C = unpack(KkthnxUI)

C["Media"] = {
	["Sounds"] = {
		KillingBlow = K.MediaFolder .. "Sounds\\KillingBlow.ogg",
	},

	["Backdrops"] = {
		ColorBackdrop = { 0.045, 0.045, 0.045, 0.9 },
	},

	["Borders"] = {
		AzeriteUIBorder = K.MediaFolder .. "Border\\AzeriteUI\\Border.tga",
		AzeriteUITooltipBorder = K.MediaFolder .. "Border\\AzeriteUI\\Border_Tooltip.tga",
		ColorBorder = { 1, 1, 1 }, -- Doesn't feel like this fits here
		GlowBorder = K.MediaFolder .. "Border\\Border_Glow_Overlay.tga",
		KkthnxUIBorder = K.MediaFolder .. "Border\\KkthnxUI\\Border.tga",
		KkthnxUITooltipBorder = K.MediaFolder .. "Border\\KkthnxUI\\Border_Tooltip.tga",
	},

	["Textures"] = {
		ArrowTexture = K.MediaFolder .. "Textures\\Arrow.tga",
		BGLineTexture = K.MediaFolder .. "Textures\\BGLineTexture",
		BlankTexture = K.MediaFolder .. "Textures\\BlankTexture.blp",
		CopyChatTexture = K.MediaFolder .. "Chat\\Copy.tga",
		GlowTexture = K.MediaFolder .. "Textures\\GlowTex.tga",
		LogoSmallTexture = K.MediaFolder .. "Textures\\LogoSmall.tga",
		LogoTexture = K.MediaFolder .. "Textures\\Logo.tga",
		MouseoverTexture = K.MediaFolder .. "Textures\\Mouseover.tga",
		NewClassIconsTexture = K.MediaFolder .. "Unitframes\\NEW-ICONS-CLASSES.blp",
		Spark128Texture = K.MediaFolder .. "Textures\\Spark_128",
		Spark16Texture = K.MediaFolder .. "Textures\\Spark_16",
		TargetIndicatorTexture = K.MediaFolder .. "Nameplates\\TargetIndicatorArrow.blp",
		White8x8Texture = "Interface\\BUTTONS\\WHITE8X8",
	},

	["Fonts"] = {
		BlankFont = K.MediaFolder .. "Fonts\\Invisible.ttf",
	},

	["Statusbars"] = {
		AltzUI = K.MediaFolder .. "Statusbars\\AltzUI.tga",
		AsphyxiaUI = K.MediaFolder .. "Statusbars\\AsphyxiaUI.tga",
		AzeriteUI = K.MediaFolder .. "Statusbars\\AzeriteUI.tga",
		Clean = K.MediaFolder .. "Statusbars\\Clean.tga",
		Flat = K.MediaFolder .. "Statusbars\\Flat.tga",
		Glamour7 = K.MediaFolder .. "Statusbars\\Glamour7.tga",
		GoldpawUI = K.MediaFolder .. "Statusbars\\GoldpawUI.tga",
		KkthnxUI = K.MediaFolder .. "Statusbars\\Statusbar",
		KuiBright = K.MediaFolder .. "Statusbars\\KuiStatusbarBright.tga",
		Kui = K.MediaFolder .. "Statusbars\\KuiStatusbar.tga",
		Palooza = K.MediaFolder .. "Statusbars\\Palooza.tga",
		PinkGradient = K.MediaFolder .. "Statusbars\\PinkGradient.tga",
		Rain = K.MediaFolder .. "Statusbars\\Rain.tga",
		SkullFlowerUI = K.MediaFolder .. "Statusbars\\SkullFlowerUI.tga",
		Tukui = K.MediaFolder .. "Statusbars\\ElvTukUI.tga",
		WGlass = K.MediaFolder .. "Statusbars\\Wglass.tga",
		Water = K.MediaFolder .. "Statusbars\\Water.tga",
		ZorkUI = K.MediaFolder .. "Statusbars\\ZorkUI.tga",
	},
}

function K.GetTexture(texture)
	if C["Media"].Statusbars[texture] then
		return C["Media"].Statusbars[texture]
	else
		return C["Media"].Statusbars["KkthnxUI"] -- Return something to prevent errors
	end
end

-- Register Borders
if K.SharedMedia then
	for name, path in pairs(C["Media"].Borders) do
		K.SharedMedia:Register("border", name, path)
	end

	-- Register Statusbars
	for name, path in pairs(C["Media"].Statusbars) do
		K.SharedMedia:Register("statusbar", name, path)
	end

	-- Register Sounds
	for name, path in pairs(C["Media"].Sounds) do
		K.SharedMedia:Register("sound", name, path)
	end

	-- Register Fonts
	for name, path in pairs(C["Media"].Fonts) do
		K.SharedMedia:Register("font", name, path)
	end
end
