local K, C = KkthnxUI[1], KkthnxUI[2]

local mediaFolder = K.MediaFolder
C["Media"] = {
	["Sounds"] = {
		KillingBlow = mediaFolder .. "Sounds\\KillingBlow.ogg",
	},

	["Backdrops"] = {
		ColorBackdrop = { 0.060, 0.060, 0.060, 0.9 },
	},

	["Borders"] = {
		AzeriteUIBorder = mediaFolder .. "Border\\AzeriteUI\\Border.tga",
		AzeriteUITooltipBorder = mediaFolder .. "Border\\AzeriteUI\\Border_Tooltip.tga",
		ColorBorder = { 1, 1, 1 },
		GlowBorder = mediaFolder .. "Border\\Border_Glow_Overlay.tga",
		KkthnxUIBorder = mediaFolder .. "Border\\KkthnxUI\\Border.tga",
		KkthnxUITooltipBorder = mediaFolder .. "Border\\KkthnxUI\\Border_Tooltip.tga",
	},

	["Textures"] = {
		ArrowTexture = mediaFolder .. "Textures\\Arrow.tga",
		BlankTexture = mediaFolder .. "Textures\\BlankTexture.blp",
		CopyChatTexture = mediaFolder .. "Chat\\Copy.tga",
		GlowTexture = mediaFolder .. "Textures\\GlowTex.tga",
		LogoSmallTexture = mediaFolder .. "Textures\\LogoSmall.tga",
		LogoTexture = mediaFolder .. "Textures\\Logo.tga",
		MouseoverTexture = mediaFolder .. "Textures\\Mouseover.tga",
		NewClassIconsTexture = mediaFolder .. "Unitframes\\NEW-ICONS-CLASSES.blp",
		Spark128Texture = mediaFolder .. "Textures\\Spark_128.tga",
		Spark16Texture = mediaFolder .. "Textures\\Spark_16.tga",
		TargetIndicatorTexture = mediaFolder .. "Nameplates\\TargetIndicatorArrow.blp",
		White8x8Texture = "Interface\\BUTTONS\\WHITE8X8",
	},

	["Fonts"] = {
		BlankFont = mediaFolder .. "Fonts\\Invisible.ttf",
	},

	["Statusbars"] = {
		AltzUI = mediaFolder .. "Statusbars\\AltzUI.tga",
		AsphyxiaUI = mediaFolder .. "Statusbars\\AsphyxiaUI.tga",
		AzeriteUI = mediaFolder .. "Statusbars\\AzeriteUI.tga",
		Clean = mediaFolder .. "Statusbars\\Clean.tga",
		Flat = mediaFolder .. "Statusbars\\Flat.tga",
		Glamour7 = mediaFolder .. "Statusbars\\Glamour7.tga",
		GoldpawUI = mediaFolder .. "Statusbars\\GoldpawUI.tga",
		KkthnxUI = mediaFolder .. "Statusbars\\Statusbar",
		KuiBright = mediaFolder .. "Statusbars\\KuiStatusbarBright.tga",
		Kui = mediaFolder .. "Statusbars\\KuiStatusbar.tga",
		Palooza = mediaFolder .. "Statusbars\\Palooza.tga",
		PinkGradient = mediaFolder .. "Statusbars\\PinkGradient.tga",
		Rain = mediaFolder .. "Statusbars\\Rain.tga",
		SkullFlowerUI = mediaFolder .. "Statusbars\\SkullFlowerUI.tga",
		Tukui = mediaFolder .. "Statusbars\\ElvTukUI.tga",
		WGlass = mediaFolder .. "Statusbars\\Wglass.tga",
		Water = mediaFolder .. "Statusbars\\Water.tga",
		ZorkUI = mediaFolder .. "Statusbars\\ZorkUI.tga",
	},
}

local statusbars = C["Media"].Statusbars
local defaultTexture = statusbars.KkthnxUI

function K.GetTexture(texture)
	return statusbars[texture] and statusbars[texture] or defaultTexture
end

-- Register media types
if K.LibSharedMedia then
	for mediaType, mediaTable in pairs(C["Media"]) do
		for name, path in pairs(mediaTable) do
			K.LibSharedMedia:Register(mediaType, name, path)
		end
	end
end
