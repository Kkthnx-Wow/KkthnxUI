local K, C = unpack(select(2, ...))

local LSM = LibStub("LibSharedMedia-3.0")

C["Media"] = {
	["Backdrop_Color"] = {5/255, 5/255, 5/255, 0.8},
	["Blank"] = [[Interface\AddOns\KkthnxUI\Media\Textures\Blank]],
	["Blank_Font"] = [[Interface\AddOns\KkthnxUI\Media\Fonts\Invisible.ttf]],
	["Blizz"] = [[Interface\Tooltips\UI-Tooltip-Border]],
	["Border"] = [[Interface\AddOns\KkthnxUI\Media\Border\BorderNormal.tga]],
	["Border_White"] = [[Interface\AddOns\KkthnxUI\Media\Border\BorderWhite.tga]],
	["Border_Color"] = {192/255, 192/255, 192/255, 1},
	["Border_Shadow"] = [[Interface\AddOns\KkthnxUI\Media\Border\BorderShadow.tga]],
	["Combat_Font"] = [[Interface\AddOns\KkthnxUI\Media\Fonts\Damage.ttf]],
	["Combat_Font_Size"] = 16,
	["Combat_Font_Style"] = "OUTLINE" or "THINOUTLINE",
	["Font"] = [[Interface\AddOns\KkthnxUI\Media\Fonts\Normal.ttf]],
	["Font_Size"] = 12,
	["Font_Style"] = "OUTLINE" or "THINOUTLINE",
	["Glow"] = [[Interface\AddOns\KkthnxUI\Media\Textures\GlowTex.tga]],
	["Nameplate_BorderColor"] = {0/255, 0/255, 0/255, 1},
	["Overlay_Color"] = {0/255, 0/255, 0/255, 0.8},
	["Proc_Sound"] = [[Interface\AddOns\KkthnxUI\Media\Sounds\Proc.ogg]],
	["Texture"] = [[Interface\TargetingFrame\UI-StatusBar]],
	["Warning_Sound"] = [[Interface\AddOns\KkthnxUI\Media\Sounds\Warning.ogg]],
	["Whisp_Sound"] = [[Interface\AddOns\KkthnxUI\Media\Sounds\Whisper.ogg]],
	["Logo"] = [[Interface\AddOns\KkthnxUI\Media\Textures\Logo.tga]],
}

if LSM == nil then return end

-- LSM fonts
LSM:Register("border", "KkthnxUI_Border", [[Interface\Tooltips\UI-Tooltip-Border]])
LSM:Register("border", "KkthnxUI_GlowTex", [[Interface\AddOns\KkthnxUI\Media\Textures\GlowTex]])
LSM:Register("font", "KkthnxUI_Damage", [[Interface\AddOns\KkthnxUI\Media\Fonts\Damage.ttf]])
LSM:Register("font", "KkthnxUI_Normal", [[Interface\AddOns\KkthnxUI\Media\Fonts\Normal.ttf]])
LSM:Register("sound", "GameMaster_Whisper", [[Sound\Spells\Simongame_visual_gametick.wav]])
LSM:Register("sound", "KkthnxUI_Whisper", [[Interface\AddOns\KkthnxUI\Media\Sounds\KWhisper.ogg]])
LSM:Register("sound", "Spell_Proc", [[Interface\AddOns\KkthnxUI\Media\Sounds\Proc.ogg]])
LSM:Register("statusbar", "KkthnxUI_StatusBar", [[Interface\TargetingFrame\UI-StatusBar]])