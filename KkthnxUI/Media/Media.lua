local K, C = unpack(select(2, ...))

-- Borders
C["MediaBorders"] = {
	KKUI_Border = [[Interface\AddOns\KkthnxUI\Media\Border\KkthnxUI\Border.tga]],
	KKUI_Border_Tooltip = [[Interface\AddOns\KkthnxUI\Media\Border\KkthnxUI\Border_Tooltip.tga]],
	AzeriteUI_Border = [[Interface\AddOns\KkthnxUI\Media\Border\AzeriteUI\Border.tga]],
	AzeriteUI_Border_Tooltip = [[Interface\AddOns\KkthnxUI\Media\Border\AzeriteUI\Border_Tooltip.tga]],
}

-- Misc Media we don't want to expose to sharedmedia
C["MediaMisc"] = {
	Arrow = [[Interface\AddOns\KkthnxUI\Media\Textures\Arrow.tga]],	
	Blank = [[Interface\BUTTONS\WHITE8X8]],
	BorderGlow = [[Interface\AddOns\KkthnxUI\Media\Border\Border_Glow_Overlay.tga]],
	Copy = [[Interface\AddOns\KkthnxUI\Media\Chat\Copy.tga]],
	Glow = [[Interface\AddOns\KkthnxUI\Media\Textures\GlowTex.tga]],
	KKUI_GlowTex = [[Interface\AddOns\KkthnxUI\Media\Textures\GlowTex]],
	Logo = [[Interface\AddOns\KkthnxUI\Media\Textures\Logo.tga]],
	Mouseover = [[Interface\AddOns\KkthnxUI\Media\Textures\Mouseover.tga]],
	NPArrow = [[Interface\AddOns\KkthnxUI\Media\Nameplates\TargetIndicatorArrow.blp]],
	NewClassPortraits = [[Interface\AddOns\KkthnxUI\Media\Unitframes\NEW-ICONS-CLASSES.blp]],	
	Shader = [[Interface\AddOns\KkthnxUI\Media\Textures\Shader.tga]],
	Spark_128 = [[Interface\AddOns\KkthnxUI\Media\Textures\Spark_128]],
	Spark_16 = [[Interface\AddOns\KkthnxUI\Media\Textures\Spark_16]],
	Texture = [[Interface\AddOns\KkthnxUI\Media\Textures\Statusbar]],
}

-- Statusbars
C["MediaStatusbars"] = {
	AltzUI = [[Interface\AddOns\KkthnxUI\Media\Textures\AltzUI.tga]],
	AsphyxiaUI = [[Interface\AddOns\KkthnxUI\Media\Textures\AsphyxiaUI.tga]],
	AzeriteUI = [[Interface\AddOns\KkthnxUI\Media\Textures\AzeriteUI.tga]],
	DiabolicUI = [[Interface\AddOns\KkthnxUI\Media\Textures\DiabolicUI.tga]],
	FlatTexture = [[Interface\AddOns\KkthnxUI\Media\Textures\Flat.tga]],
	GoldpawUI = [[Interface\AddOns\KkthnxUI\Media\Textures\GoldpawUI.tga]],
	Palooza = [[Interface\AddOns\KkthnxUI\Media\Textures\Palooza.tga]],
	SkullFlowerUI = [[Interface\AddOns\KkthnxUI\Media\Textures\SkullFlowerUI.tga]],
	Tukui = [[Interface\AddOns\KkthnxUI\Media\Textures\ElvTukUI.tga]],
	ZorkUI = [[Interface\AddOns\KkthnxUI\Media\Textures\ZorkUI.tga]],
}

-- Sounds
C["MediaSounds"] = {
	Proc_Sound = [[Interface\AddOns\KkthnxUI\Media\Sounds\Proc.ogg]],
	WarningSound = [[Interface\AddOns\KkthnxUI\Media\Sounds\Warning.ogg]],
	WhisperSound = [[Interface\AddOns\KkthnxUI\Media\Sounds\Whisper.ogg]],
	GameMaster_Whisper = [[Sound\Spells\Simongame_visual_gametick.wav]],
}

-- Fonts
C["MediaFonts"] = {
	BlankFont = [[Interface\AddOns\KkthnxUI\Media\Fonts\Invisible.ttf]],
	CombatFont = [[Interface\AddOns\KkthnxUI\Media\Fonts\Damage.ttf]],
	KKUI_Normal = [[Interface\AddOns\KkthnxUI\Media\Fonts\Normal.ttf]],
	KKUI_Damage = [[Interface\AddOns\KkthnxUI\Media\Fonts\Damage.ttf]],
}

-- Settings related to media functions
C["MediaSettings"] = {
	FontSize = 12,
	FontStyle = "OUTLINE",
	BorderColor = {1, 1, 1},
	BackdropColor = {.04, .04, .04, 0.9},
}

if (K.Client == "koKR" or K.Client == "zhTW" or K.Client == "zhCN") then
	C["MediaFonts"].KKUI_Normal = STANDARD_TEXT_FONT
	C["MediaFonts"].KKUI_Damage = DAMAGE_TEXT_FONT
elseif (K.Client ~= "enUS" and K.Client ~= "frFR" and K.Client ~= "enGB") then
	C["MediaFonts"].KKUI_Damage = DAMAGE_TEXT_FONT
end

if K.LSM == nil then
	return
end

-- Register media to sharedmedia
-- Register Borders
for name, path in pairs(C["MediaBorders"]) do
	K.LSM:Register("border", name, path)
end
-- Register Statusbars
for name, path in pairs(C["MediaStatusbars"]) do
	K.LSM:Register("statusbar", name, path)
end
-- Register Sounds
for name, path in pairs(C["MediaSounds"]) do
	K.LSM:Register("sound", name, path)
end
-- Register Fonts
for name, path in pairs(C["MediaFonts"]) do
	K.LSM:Register("font", name, path)
end