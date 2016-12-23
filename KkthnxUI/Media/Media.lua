local K, C, L = unpack(select(2, ...))

local LibSharedMedia = LibStub("LibSharedMedia-3.0")
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

if (Locale == "koKR" or Locale == "zhTW" or Locale == "zhCN") then
	C.Media.Font = STANDARD_TEXT_FONT
	C.Media.Font = UNIT_NAME_FONT
	C.Media.Combat_Font = DAMAGE_TEXT_FONT
end

if LibSharedMedia == nil then return end

-- LibSharedMedia fonts
LibSharedMedia:Register("border", "KkthnxUI_Border", [[Interface\Tooltips\UI-Tooltip-Border]])
LibSharedMedia:Register("border", "KkthnxUI_GlowTex", [[Interface\AddOns\KkthnxUI\Media\Textures\GlowTex]])
LibSharedMedia:Register("font", "KkthnxUI_Damage", [[Interface\AddOns\KkthnxUI\Media\Fonts\Damage.ttf]])
LibSharedMedia:Register("font", "KkthnxUI_Normal", [[Interface\AddOns\KkthnxUI\Media\Fonts\Normal.ttf]])
LibSharedMedia:Register("sound", "GameMaster_Whisper", [[Sound\Spells\Simongame_visual_gametick.wav]])
LibSharedMedia:Register("sound", "KkthnxUI_Whisper", [[Interface\AddOns\KkthnxUI\Media\Sounds\KWhisper.ogg]])
LibSharedMedia:Register("sound", "Spell_Proc", [[Interface\AddOns\KkthnxUI\Media\Sounds\Proc.ogg]])
LibSharedMedia:Register("statusbar", "KkthnxUI_StatusBar", [[Interface\TargetingFrame\UI-StatusBar]])