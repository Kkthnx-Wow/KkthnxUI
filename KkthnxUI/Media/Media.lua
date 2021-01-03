local K, C = unpack(select(2, ...))

C["Media"] = {
	["Sounds"] = {
		ProcSound = [[Interface\AddOns\KkthnxUI\Media\Sounds\Proc.ogg]],
		WarningSound = [[Interface\AddOns\KkthnxUI\Media\Sounds\Warning.ogg]],
		WhisperSound = [[Interface\AddOns\KkthnxUI\Media\Sounds\Whisper.ogg]],
	},

	["Backdrops"] = {
		Color = {0.04, 0.04, 0.04, 0.9},
	},

	["Borders"] = {
		AzeriteUI = [[Interface\AddOns\KkthnxUI\Media\Border\AzeriteUI\Border.tga]],
		AzeriteUITooltip = [[Interface\AddOns\KkthnxUI\Media\Border\AzeriteUI\Border_Tooltip.tga]],
		Color = {1, 1, 1},
		Glow = [[Interface\AddOns\KkthnxUI\Media\Border\Border_Glow_Overlay.tga]],
		KkthnxUI = [[Interface\AddOns\KkthnxUI\Media\Border\KkthnxUI\Border.tga]],
		KkthnxUITooltip = [[Interface\AddOns\KkthnxUI\Media\Border\KkthnxUI\Border_Tooltip.tga]],
	},

	["Textures"] = {
		Arrow = [[Interface\AddOns\KkthnxUI\Media\Textures\Arrow.tga]],
		Blank = [[Interface\BUTTONS\WHITE8X8]],
		Copy = [[Interface\AddOns\KkthnxUI\Media\Chat\Copy.tga]],
		Glow = [[Interface\AddOns\KkthnxUI\Media\Textures\GlowTex.tga]],
		Logo = [[Interface\AddOns\KkthnxUI\Media\Textures\Logo.tga]],
		Mouseover = [[Interface\AddOns\KkthnxUI\Media\Textures\Mouseover.tga]],
		NewClassIcons = [[Interface\AddOns\KkthnxUI\Media\Unitframes\NEW-ICONS-CLASSES.blp]],
		Shader = [[Interface\AddOns\KkthnxUI\Media\Textures\Shader.tga]],
		Spark_128 = [[Interface\AddOns\KkthnxUI\Media\Textures\Spark_128]],
		Spark_16 = [[Interface\AddOns\KkthnxUI\Media\Textures\Spark_16]],
		TargetIndicatorArrow = [[Interface\AddOns\KkthnxUI\Media\Nameplates\TargetIndicatorArrow.blp]],
	},

	["Fonts"] = {
		Blank = [[Interface\AddOns\KkthnxUI\Media\Fonts\Invisible.ttf]],
		Damage = [[Interface\AddOns\KkthnxUI\Media\Fonts\Damage.ttf]],
		KkthnxUI = [[Interface\AddOns\KkthnxUI\Media\Fonts\Normal.ttf]],
		Size = 12,
		Style = "OUTLINE",
	},

	["Statusbars"] = {
		AltzUI = [[Interface\AddOns\KkthnxUI\Media\Textures\AltzUI.tga]],
		AsphyxiaUI = [[Interface\AddOns\KkthnxUI\Media\Textures\AsphyxiaUI.tga]],
		AzeriteUI = [[Interface\AddOns\KkthnxUI\Media\Textures\AzeriteUI.tga]],
		DiabolicUI = [[Interface\AddOns\KkthnxUI\Media\Textures\DiabolicUI.tga]],
		Flat = [[Interface\AddOns\KkthnxUI\Media\Textures\Flat.tga]],
		GoldpawUI = [[Interface\AddOns\KkthnxUI\Media\Textures\GoldpawUI.tga]],
		KkthnxUI = [[Interface\AddOns\KkthnxUI\Media\Textures\Statusbar]],
		Palooza = [[Interface\AddOns\KkthnxUI\Media\Textures\Palooza.tga]],
		SkullFlowerUI = [[Interface\AddOns\KkthnxUI\Media\Textures\SkullFlowerUI.tga]],
		Tukui = [[Interface\AddOns\KkthnxUI\Media\Textures\ElvTukUI.tga]],
		ZorkUI = [[Interface\AddOns\KkthnxUI\Media\Textures\ZorkUI.tga]],
	},
}

if (K.Client == "koKR" or K.Client == "zhTW" or K.Client == "zhCN") then
	C["Media"].Fonts.KkthnxUI = STANDARD_TEXT_FONT
	C["Media"].Fonts.Damage = DAMAGE_TEXT_FONT
elseif (K.Client ~= "enUS" and K.Client ~= "frFR" and K.Client ~= "enGB") then
	C["Media"].Fonts.Damage = DAMAGE_TEXT_FONT
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