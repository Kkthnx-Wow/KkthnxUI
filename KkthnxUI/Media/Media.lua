local K, C, L = unpack(select(2, ...))

local LSM = LibStub("LibSharedMedia-3.0")
local Locale = GetLocale()

C["Media"] = {
	["Backdrop_Color"] = {6/255, 6/255, 6/255, 0.9},
	["Blank_Font"] = [[Interface\AddOns\KkthnxUI\Media\Fonts\Invisible.ttf]],
	["Blank"] = [[Interface\AddOns\KkthnxUI\Media\Textures\Blank]],
	["Blizz"] = [[Interface\Tooltips\UI-Tooltip-Border]],
	["Border_Color"] = {192/255, 192/255, 192/255},
	["Border_Shadow"] = [[Interface\AddOns\KkthnxUI\Media\Border\BorderShadow.tga]],
	["Border_White"] = [[Interface\AddOns\KkthnxUI\Media\Border\BorderWhite.tga]],
	["Border"] = [[Interface\AddOns\KkthnxUI\Media\Border\BorderNormal.tga]],
	["Combat_Font_Size"] = 16,
	["Combat_Font_Style"] = "OUTLINE" or "THINOUTLINE",
	["Combat_Font"] = [[Interface\AddOns\KkthnxUI\Media\Fonts\Damage.ttf]],
	["Font_Size"] = 12,
	["Font_Style"] = "OUTLINE" or "THINOUTLINE",
	["Font"] = [[Interface\AddOns\KkthnxUI\Media\Fonts\Normal.ttf]],
	["Glow"] = [[Interface\AddOns\KkthnxUI\Media\Textures\GlowTex.tga]],
	["Logo"] = [[Interface\AddOns\KkthnxUI\Media\Textures\Logo.tga]],
	["Nameplate_BorderColor"] = {0, 0, 0, 1},
	["Proc_Sound"] = [[Interface\AddOns\KkthnxUI\Media\Sounds\Proc.ogg]],
	["Texture"] = [[Interface\TargetingFrame\UI-StatusBar]],
	["Warning_Sound"] = [[Interface\AddOns\KkthnxUI\Media\Sounds\Warning.ogg]],
	["Whisp_Sound"] = [[Interface\AddOns\KkthnxUI\Media\Sounds\Whisper.ogg]],
}

-- For those who love flat textures.
if C.General.UseFlatTextures then
	C.Media.Texture = [[Interface\AddOns\KkthnxUI\Media\Textures\Flat]]
	C.Media.Blank = [[Interface\AddOns\KkthnxUI\Media\Textures\Flat]]
end

-- Let people turn off my font and replace for certain locals
if (C.General.UseBlizzardFonts or Locale == "koKR" or Locale == "zhTW" or Locale == "zhCN") then
	C.Media.Font = STANDARD_TEXT_FONT
	C.Media.Combat_Font = DAMAGE_TEXT_FONT
	C.Blizzard.ReplaceBlizzardFonts = false
end

if LSM == nil then return end

-- LibSharedMedia fonts
LSM:Register("border", "KkthnxUI_Border", [[Interface\Tooltips\UI-Tooltip-Border]])
LSM:Register("border", "KkthnxUI_GlowTex", [[Interface\AddOns\KkthnxUI\Media\Textures\GlowTex]])
LSM:Register("font", "KkthnxUI_Damage", [[Interface\AddOns\KkthnxUI\Media\Fonts\Damage.ttf]])
LSM:Register("font", "KkthnxUI_Normal", [[Interface\AddOns\KkthnxUI\Media\Fonts\Normal.ttf]])
LSM:Register("sound", "GameMaster_Whisper", [[Sound\Spells\Simongame_visual_gametick.wav]])
LSM:Register("sound", "KkthnxUI_Whisper", [[Interface\AddOns\KkthnxUI\Media\Sounds\KWhisper.ogg]])
LSM:Register("sound", "Spell_Proc", [[Interface\AddOns\KkthnxUI\Media\Sounds\Proc.ogg]])
LSM:Register("statusbar", "KkthnxUI_StatusBar", [[Interface\TargetingFrame\UI-StatusBar]])