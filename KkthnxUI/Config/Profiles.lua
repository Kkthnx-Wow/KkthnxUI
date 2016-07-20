local K, C, L, _ = select(2, ...):unpack()

-- Per Class Config (overwrites general)
-- Class Type need to be UPPERCASE -- DRUID, MAGE ect ect...
if K.Class == "DRUID" then
end

if K.Role == "Tank" then
end

-- Per Character Name Config (overwrite general and class)
-- Name need to be case sensitive
if K.Name == "CharacterName" then
end

-- Per Max Character Level Config (overwrite general, class and name)
if K.Level ~= MAX_PLAYER_LEVEL then
end

-- Magicnachos Personal Config
if (K.Name == "Magicnachos" or K.Name == "Bootyshorts") and (K.Realm == "Icecrown") then

end

-- Kkthnx Personal Config
if (K.Name == "Kkthnx" or K.Name == "Rollndots" or K.Name == "Safeword" or K.Name == "Broflex" or K.Name == "Broflexin") and (K.Realm == "Icecrown") then

end