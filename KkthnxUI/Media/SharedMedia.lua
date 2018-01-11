local K = unpack(select(2, ...))
if K.LSM == nil then return end

-- LibSharedMedia fonts
K.LSM:Register("border", "KkthnxUI_Border", [[Interface\Tooltips\UI-Tooltip-Border]])
K.LSM:Register("border", "KkthnxUI_GlowTex", [[Interface\AddOns\KkthnxUI\Media\Textures\GlowTex]])
K.LSM:Register("font", "KkthnxUI_Damage", [[Interface\AddOns\KkthnxUI\Media\Fonts\Damage.ttf]], K.LSM.LOCALE_BIT_ruRU + K.LSM.LOCALE_BIT_western)
K.LSM:Register("font", "KkthnxUI_Normal", [[Interface\AddOns\KkthnxUI\Media\Fonts\Normal.ttf]], K.LSM.LOCALE_BIT_ruRU + K.LSM.LOCALE_BIT_western)
K.LSM:Register("sound", "GameMaster_Whisper", [[Sound\Spells\Simongame_visual_gametick.wav]])
K.LSM:Register("sound", "KkthnxUI_Whisper", [[Interface\AddOns\KkthnxUI\Media\Sounds\KWhisper.ogg]])
K.LSM:Register("sound", "Spell_Proc", [[Interface\AddOns\KkthnxUI\Media\Sounds\Proc.ogg]])
K.LSM:Register("statusbar", "KkthnxUI_StatusBar", [[Interface\TargetingFrame\UI-StatusBar]])