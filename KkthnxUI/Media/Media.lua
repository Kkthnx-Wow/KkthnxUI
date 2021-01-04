local K, C = unpack(select(2, ...))

C["Media"] = {
	["Sounds"] = {
		ProcSound = [[Interface\AddOns\KkthnxUI\Media\Sounds\Proc.ogg]],
		WarningSound = [[Interface\AddOns\KkthnxUI\Media\Sounds\Warning.ogg]],
		WhisperSound = [[Interface\AddOns\KkthnxUI\Media\Sounds\Whisper.ogg]],
	},

	["Backdrops"] = {
		ColorBackdrop = {0.04, 0.04, 0.04, 0.9},
	},

	["Borders"] = {
		AzeriteUIBorder = [[Interface\AddOns\KkthnxUI\Media\Border\AzeriteUI\Border.tga]],
		AzeriteUITooltipBorder = [[Interface\AddOns\KkthnxUI\Media\Border\AzeriteUI\Border_Tooltip.tga]],
		ColorBorder = {1, 1, 1},
		GlowBorder = [[Interface\AddOns\KkthnxUI\Media\Border\Border_Glow_Overlay.tga]],
		KkthnxUIBorder = [[Interface\AddOns\KkthnxUI\Media\Border\KkthnxUI\Border.tga]],
		KkthnxUITooltipBorder = [[Interface\AddOns\KkthnxUI\Media\Border\KkthnxUI\Border_Tooltip.tga]],
	},

	["Textures"] = {
		ArrowTexture = [[Interface\AddOns\KkthnxUI\Media\Textures\Arrow.tga]],
		BlankTexture = [[Interface\BUTTONS\WHITE8X8]],
		CopyChatTexture = [[Interface\AddOns\KkthnxUI\Media\Chat\Copy.tga]],
		GlowTexture = [[Interface\AddOns\KkthnxUI\Media\Textures\GlowTex.tga]],
		LogoTexture = [[Interface\AddOns\KkthnxUI\Media\Textures\Logo.tga]],
		MouseoverTexture = [[Interface\AddOns\KkthnxUI\Media\Textures\Mouseover.tga]],
		NewClassIconsTexture = [[Interface\AddOns\KkthnxUI\Media\Unitframes\NEW-ICONS-CLASSES.blp]],
		Spark128Texture = [[Interface\AddOns\KkthnxUI\Media\Textures\Spark_128]],
		Spark16Texture = [[Interface\AddOns\KkthnxUI\Media\Textures\Spark_16]],
		TargetIndicatorTexture = [[Interface\AddOns\KkthnxUI\Media\Nameplates\TargetIndicatorArrow.blp]],
	},

	["Fonts"] = {
		BlankFont = [[Interface\AddOns\KkthnxUI\Media\Fonts\Invisible.ttf]],
		DamageFont = [[Interface\AddOns\KkthnxUI\Media\Fonts\Damage.ttf]],
		KkthnxUIFont = [[Interface\AddOns\KkthnxUI\Media\Fonts\Normal.ttf]],
	},

	["Statusbars"] = {
		AltzUIStatusbar = [[Interface\AddOns\KkthnxUI\Media\Textures\AltzUI.tga]],
		AsphyxiaUIStatusbar = [[Interface\AddOns\KkthnxUI\Media\Textures\AsphyxiaUI.tga]],
		AzeriteUIStatusbar = [[Interface\AddOns\KkthnxUI\Media\Textures\AzeriteUI.tga]],
		DiabolicUIStatusbar = [[Interface\AddOns\KkthnxUI\Media\Textures\DiabolicUI.tga]],
		FlatStatusbar = [[Interface\AddOns\KkthnxUI\Media\Textures\Flat.tga]],
		GoldpawUIStatusbar = [[Interface\AddOns\KkthnxUI\Media\Textures\GoldpawUI.tga]],
		KkthnxUIStatusbar = [[Interface\AddOns\KkthnxUI\Media\Textures\Statusbar]],
		PaloozaStatusbar = [[Interface\AddOns\KkthnxUI\Media\Textures\Palooza.tga]],
		SkullFlowerUIStatusbar = [[Interface\AddOns\KkthnxUI\Media\Textures\SkullFlowerUI.tga]],
		TukuiStatusbar = [[Interface\AddOns\KkthnxUI\Media\Textures\ElvTukUI.tga]],
		ZorkUIStatusbar = [[Interface\AddOns\KkthnxUI\Media\Textures\ZorkUI.tga]],
	},
}

if (K.Client == "koKR" or K.Client == "zhTW" or K.Client == "zhCN") then
	C["Media"].Fonts.KkthnxUIFont = STANDARD_TEXT_FONT
	C["Media"].Fonts.DamageFont = DAMAGE_TEXT_FONT
elseif (K.Client ~= "enUS" and K.Client ~= "frFR" and K.Client ~= "enGB") then
	C["Media"].Fonts.DamageFont = DAMAGE_TEXT_FONT
end

if K.LSM == nil then
	return
end

-- Register Borders
for name, path in pairs(C["Media"].Borders) do
	K.LSM:Register("border", name, path)
end

-- Register Statusbars
for name, path in pairs(C["Media"].Statusbars) do
	K.LSM:Register("statusbar", name, path)
end

-- Register Sounds
for name, path in pairs(C["Media"].Sounds) do
	K.LSM:Register("sound", name, path)
end

-- Register Fonts
for name, path in pairs(C["Media"].Fonts) do
	K.LSM:Register("font", name, path)
end