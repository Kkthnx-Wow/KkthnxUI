local K, C = unpack(select(2, ...))

C["Media"] = {
	AltzUI = [[Interface\AddOns\KkthnxUI\Media\Textures\AltzUI.tga]],
	AsphyxiaUI = [[Interface\AddOns\KkthnxUI\Media\Textures\AsphyxiaUI.tga]],
	AzeriteUI = [[Interface\AddOns\KkthnxUI\Media\Textures\AzeriteUI.tga]],
	BackdropColor = {.04, .04, .04, 0.9},
	Blank = [[Interface\BUTTONS\WHITE8X8]],
	BlankFont = [[Interface\AddOns\KkthnxUI\Media\Fonts\Invisible.ttf]],
	Border = [[Interface\AddOns\KkthnxUI\Media\Border\Border.tga]],
	BorderColor = {1, 1, 1},
	BorderGlow = [[Interface\AddOns\KkthnxUI\Media\Border\BorderGlow.tga]],
	CombatFont = [[Interface\AddOns\KkthnxUI\Media\Fonts\Damage.ttf]],
	Copy = [[Interface\AddOns\KkthnxUI\Media\Chat\Copy.tga]],
	DiabolicUI = [[Interface\AddOns\KkthnxUI\Media\Textures\DiabolicUI.tga]],
	FlatTexture = [[Interface\AddOns\KkthnxUI\Media\Textures\Flat.tga]],
	Font = [[Interface\AddOns\KkthnxUI\Media\Fonts\Normal.ttf]],
	FontSize = 12,
	FontStyle = "OUTLINE",
	Glow = [[Interface\AddOns\KkthnxUI\Media\Textures\GlowTex.tga]],
	GoldpawUI = [[Interface\AddOns\KkthnxUI\Media\Textures\GoldpawUI.tga]],
	Logo = [[Interface\AddOns\KkthnxUI\Media\Textures\Logo.tga]],
	Mouseover = [[Interface\AddOns\KkthnxUI\Media\Textures\Mouseover.tga]],
	NewClassPortraits = [[Interface\AddOns\KkthnxUI\Media\Unitframes\NEW-ICONS-CLASSES.blp]],
	NPArrow = [[Interface\AddOns\KkthnxUI\Media\Nameplates\arrow_single_right_64.tga]],
	NPHealer = [[Interface\AddOns\KkthnxUI\Media\Nameplates\UI-Plate-Healer.tga]],
	NPTank = [[Interface\AddOns\KkthnxUI\Media\Nameplates\UI-Plate-Tank.tga]],
	Proc_Sound = [[Interface\AddOns\KkthnxUI\Media\Sounds\Proc.ogg]],
	Shader = [[Interface\AddOns\KkthnxUI\Media\Textures\Shader.tga]],
	SkullFlowerUI = [[Interface\AddOns\KkthnxUI\Media\Textures\SkullFlowerUI.tga]],
	Spark_128 = [[Interface\AddOns\KkthnxUI\Media\Textures\Spark_128]],
	Spark_16 = [[Interface\AddOns\KkthnxUI\Media\Textures\Spark_16]],
	Texture = [[Interface\TargetingFrame\UI-StatusBar]],
	Tukui = [[Interface\AddOns\KkthnxUI\Media\Textures\ElvTukUI.tga]],
	WarningSound = [[Interface\AddOns\KkthnxUI\Media\Sounds\Warning.ogg]],
	WhisperSound = [[Interface\AddOns\KkthnxUI\Media\Sounds\Whisper.ogg]],
	ZorkUI = [[Interface\AddOns\KkthnxUI\Media\Textures\ZorkUI.tga]],
}

if (K.Client == "koKR" or K.Client == "zhTW" or K.Client == "zhCN") then
	C["Media"].Font = STANDARD_TEXT_FONT
	C["Media"].CombatFont = DAMAGE_TEXT_FONT
end

if K.LSM == nil then
	return
end

-- LibSharedMedia Stuff
K.LSM:Register("border", "KkthnxUI_Border", [[Interface\AddOns\KkthnxUI\Media\Border\Border.tga]])
K.LSM:Register("border", "KkthnxUI_GlowTex", [[Interface\AddOns\KkthnxUI\Media\Textures\GlowTex]])
K.LSM:Register("font", "KkthnxUI_Damage", [[Interface\AddOns\KkthnxUI\Media\Fonts\Damage.ttf]], K.LSM.LOCALE_BIT_ruRU + K.LSM.LOCALE_BIT_western)
K.LSM:Register("font", "KkthnxUI_Normal", [[Interface\AddOns\KkthnxUI\Media\Fonts\Normal.ttf]], K.LSM.LOCALE_BIT_ruRU + K.LSM.LOCALE_BIT_western)
K.LSM:Register("sound", "GameMaster_Whisper", [[Sound\Spells\Simongame_visual_gametick.wav]])
K.LSM:Register("sound", "KkthnxUI_Whisper", [[Interface\AddOns\KkthnxUI\Media\Sounds\KWhisper.ogg]])
K.LSM:Register("sound", "Spell_Proc", [[Interface\AddOns\KkthnxUI\Media\Sounds\Proc.ogg]])
K.LSM:Register("statusbar", "KkthnxUI_StatusBar", [[Interface\TargetingFrame\UI-StatusBar]])