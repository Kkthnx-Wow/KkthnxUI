local LSM = LibStub('LibSharedMedia-3.0')

if LSM == nil then return end

-- LSM Fonts
LSM:Register("border", "KkthnxUI_Border", [[Interface\Tooltips\UI-Tooltip-Border]])
LSM:Register("border", "KkthnxUI_GlowTex", [[Interface\AddOns\KkthnxUI\Media\Textures\GlowTex]])
LSM:Register("font", "KkthnxUI_Damage", [[Interface\AddOns\KkthnxUI\Media\Fonts\Damage.ttf]])
LSM:Register("font", "KkthnxUI_Normal", [[Interface\AddOns\KkthnxUI\Media\Fonts\Normal.ttf]])
LSM:Register("sound", "GameMaster_Whisper", [[Sound\Spells\Simongame_visual_gametick.wav]])
LSM:Register("sound", "KkthnxUI_Whisper", [[Interface\AddOns\KkthnxUI\Media\Sounds\KWhisper.ogg]])
LSM:Register("sound", "Spell_Proc", [[Interface\AddOns\KkthnxUI\Media\Sounds\Proc.ogg]])
LSM:Register("statusbar", "KkthnxUI_StatusBar", [[Interface\TargetingFrame\UI-StatusBar]])