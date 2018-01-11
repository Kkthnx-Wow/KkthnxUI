local K, C = unpack(select(2, ...))

C["Media"] = {
	BackdropColor = {.04, .04, .04, 0.9},
	Blank = [[Interface\BUTTONS\WHITE8X8]],
	BlankFont = [[Interface\AddOns\KkthnxUI\Media\Fonts\Invisible.ttf]],
	Border = [[Interface\Tooltips\UI-Tooltip-Border]],
	BorderColor = {1, 1, 1},
	BorderShadow = [[Interface\AddOns\KkthnxUI\Media\Border\Border_Shadow.tga]],
	CombatFont = [[Interface\AddOns\KkthnxUI\Media\Fonts\Damage.ttf]],
	Copy = [[Interface\AddOns\KkthnxUI\Media\Chat\Copy.tga]],
	DiabolicUI = [[Interface\AddOns\KkthnxUI\Media\Textures\DiabolicUI.tga]],
	FlatTexture = [[Interface\AddOns\KkthnxUI\Media\Textures\Flat.tga]],
	Font = [[Interface\AddOns\KkthnxUI\Media\Fonts\Normal.ttf]],
	FontSize = 12,
	FontStyle = "OUTLINE",
	Glow = [[Interface\AddOns\KkthnxUI\Media\Textures\GlowTex.tga]],
	Logo = [[Interface\AddOns\KkthnxUI\Media\Textures\Logo.tga]],
	NewClassPortraits = [[Interface\AddOns\KkthnxUI\Media\Unitframes\NEW-ICONS-CLASSES.blp]],
	Proc_Sound = [[Interface\AddOns\KkthnxUI\Media\Sounds\Proc.ogg]],
	Spark = [[Interface\AddOns\KkthnxUI\Media\Textures\Spark.blp]],
	Texture = [[Interface\TargetingFrame\UI-StatusBar]],
	Tukui = [[Interface\AddOns\KkthnxUI\Media\Textures\ElvTukUI.tga]],
	ValueColor = {68/255, 136/255, 255/255},
	WarningSound = [[Interface\AddOns\KkthnxUI\Media\Sounds\Warning.ogg]],
	WhisperSound = [[Interface\AddOns\KkthnxUI\Media\Sounds\Whisper.ogg]],
}

if (K.Client == "koKR" or K.Client == "zhTW" or K.Client == "zhCN") then
	C["Media"].Font = STANDARD_TEXT_FONT
	C["Media"].CombatFont = DAMAGE_TEXT_FONT
end