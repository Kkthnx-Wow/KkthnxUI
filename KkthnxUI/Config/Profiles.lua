local K, C, L, _ = select(2, ...):unpack()

-- PER CLASS CONFIG (OVERWRITES GENERAL)
-- CLASS TYPE NEED TO BE UPPERCASE -- DRUID, MAGE ECT ECT...
if K.Class == "DRUID" then
end

if K.Role == "Tank" then
end

-- PER CHARACTER NAME CONFIG (OVERWRITE GENERAL AND CLASS)
-- NAME NEED TO BE CASE SENSITIVE
if K.Name == "CharacterName" then
end

-- PER MAX CHARACTER LEVEL CONFIG (OVERWRITE GENERAL, CLASS AND NAME)
if K.Level ~= MAX_PLAYER_LEVEL then
end

-- MAGICNACHOS PERSONAL CONFIG
if (K.Name == "Magicnachos") and (K.Realm == "Stormreaver") then

end

-- KKTHNX PERSONAL CONFIG
if (K.Name == "Kkthnx") and (K.Realm == "Stormreaver") then

end