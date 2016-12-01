local K, C, L = select(2, ...):unpack()

--[[

--------------------------------------------------------------------------------------------------------------------------------------
-- *** IMPORTANT!: If you want to use this file, which takes precedence over the GUI config options, rename it to, Profiles.lua *** --
--------------------------------------------------------------------------------------------------------------------------------------
It's important to not overwrite the original table. so if you want to edit, for example,
some of the unitframes default settings, it should be done this way.

C.Unitframe.EnhancedFrames = true
C.Unitframe.PercentHealth = true
C.Unitframe.ClassIcon = true
C.Unitframe.SmoothBars = true
C.Position.UnitFrames.PlayerCastbar = {"BOTTOM", "ActionBarAnchor", "TOP", 0, 175}

-------------------------------------------------------------
-- *** IMPORTANT!: Please do not edit settings this way!!! --
-------------------------------------------------------------

C["UnitFrames"] = {
	["EnhancedFrames"] = true,
	["PercentHealth"] = true,
	["ClassIcon"] = true,
	["SmoothBars"] = true,
}
C["Position"] = {
	UnitFrames = {
		["PlayerCastbar"] = {"BOTTOM", "ActionBarAnchor", "TOP", 0, 175},
	},
}

--]]

-- Per class config (overwrites general)
-- Class type needs to be uppercase -- DRUID, MAGE ect ect...
if K.Class == "DRUID" then

end

-- Role type needs to be uppercase -- TANK, HEALER, CASTER, MELEE
if K.Role == "TANK" then

end

-- Per character name config (overwrite general and class)
-- Name needs to be case sensitive
if K.Name == "CharacterName" then

end

-- Per max character level config (overwrite general, class and name)
if K.Level ~= MAX_PLAYER_LEVEL then

end

-- CharacterName personal config
if (K.Name == "CharacterName") and (K.Realm == "RealmName") then

end

-- CharacterName personal config
if (K.Name == "CharacterName" or K.Name == "CharacterName" or K.Name == "CharacterName" or K.Name == "CharacterName") and (K.Realm == "RealmName") then

end