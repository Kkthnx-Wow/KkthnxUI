local K, C = unpack(select(2, ...))

C["Media"] = {
	AltzUI = [[Interface\AddOns\KkthnxUI\Media\Textures\AltzUI.tga]],
	Arrow = [[Interface\AddOns\KkthnxUI\Media\Textures\Arrow.tga]],
	AsphyxiaUI = [[Interface\AddOns\KkthnxUI\Media\Textures\AsphyxiaUI.tga]],
	AzeriteUI = [[Interface\AddOns\KkthnxUI\Media\Textures\AzeriteUI.tga]],
	BackdropColor = {.04, .04, .04, 0.9},
	Blank = [[Interface\BUTTONS\WHITE8X8]],
	BlankFont = [[Interface\AddOns\KkthnxUI\Media\Fonts\Invisible.ttf]],
--	Border = [[Interface\AddOns\KkthnxUI\Media\Border\KkthnxUI\Border.tga]],
	BorderColor = {1, 1, 1},
	BorderGlow = [[Interface\AddOns\KkthnxUI\Media\Border\Border_Glow_Overlay.tga]],
--	BorderTooltip = [[Interface\AddOns\KkthnxUI\Media\Border\KkthnxUI\Border_Tooltip.tga]],
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
	NPArrow = [[Interface\AddOns\KkthnxUI\Media\Nameplates\TargetIndicatorArrow.blp]],
	NewClassPortraits = [[Interface\AddOns\KkthnxUI\Media\Unitframes\NEW-ICONS-CLASSES.blp]],
	Palooza = [[Interface\AddOns\KkthnxUI\Media\Textures\Palooza.tga]],
	Proc_Sound = [[Interface\AddOns\KkthnxUI\Media\Sounds\Proc.ogg]],
	Shader = [[Interface\AddOns\KkthnxUI\Media\Textures\Shader.tga]],
	SkullFlowerUI = [[Interface\AddOns\KkthnxUI\Media\Textures\SkullFlowerUI.tga]],
	Spark_128 = [[Interface\AddOns\KkthnxUI\Media\Textures\Spark_128]],
	Spark_16 = [[Interface\AddOns\KkthnxUI\Media\Textures\Spark_16]],
	Texture = [[Interface\AddOns\KkthnxUI\Media\Textures\Statusbar]],
	Tukui = [[Interface\AddOns\KkthnxUI\Media\Textures\ElvTukUI.tga]],
	WarningSound = [[Interface\AddOns\KkthnxUI\Media\Sounds\Warning.ogg]],
	WhisperSound = [[Interface\AddOns\KkthnxUI\Media\Sounds\Whisper.ogg]],
	ZorkUI = [[Interface\AddOns\KkthnxUI\Media\Textures\ZorkUI.tga]],
}

if (K.Client == "koKR" or K.Client == "zhTW" or K.Client == "zhCN") then
	C["Media"].Font = STANDARD_TEXT_FONT
	C["Media"].CombatFont = DAMAGE_TEXT_FONT
elseif (K.Client ~= "enUS" and K.Client ~= "frFR" and K.Client ~= "enGB") then
	C["Media"].CombatFont = DAMAGE_TEXT_FONT
end

if K.LSM == nil then
	return
end

-- LibSharedMedia Stuff
K.LSM:Register("border", "KKUI_Border", [[Interface\AddOns\KkthnxUI\Media\Border\KkthnxUI\Border.tga]])
K.LSM:Register("border", "KKUI_Border_Tooltip", [[Interface\AddOns\KkthnxUI\Media\Border\KkthnxUI\Border_Tooltip.tga]])
K.LSM:Register("border", "KKUI_GlowTex", [[Interface\AddOns\KkthnxUI\Media\Textures\GlowTex]])
K.LSM:Register("font", "KKUI_Damage", [[Interface\AddOns\KkthnxUI\Media\Fonts\Damage.ttf]])
K.LSM:Register("font", "KKUI_Normal", [[Interface\AddOns\KkthnxUI\Media\Fonts\Normal.ttf]])
K.LSM:Register("sound", "GameMaster_Whisper", [[Sound\Spells\Simongame_visual_gametick.wav]])
K.LSM:Register("sound", "KKUI_SpellProc", [[Interface\AddOns\KkthnxUI\Media\Sounds\Proc.ogg]])
K.LSM:Register("sound", "KKUI_Whisper", [[Interface\AddOns\KkthnxUI\Media\Sounds\KWhisper.ogg]])
K.LSM:Register("statusbar", "KKUI_StatusBar", [[Interface\AddOns\KkthnxUI\Media\Textures\Statusbar]])