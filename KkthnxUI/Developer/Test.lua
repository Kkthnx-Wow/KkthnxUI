-- So I can test stuff.

-- Use this file for testing stuff that I do not want in the UI or I am unsure about.
-- This is a good file to mess around with code in for anyone else as well.

-- CodeName : Code Gone Wild ;D

local K, C, L = unpack(select(2, ...))
if not K.IsDeveloper() and not K.IsDeveloperRealm() then return end -- Check this code.

-- Always debug our temp code.
if LibDebug then LibDebug() end

-- Lua API

-- Wow API

-- Global variables that we don"t cache, list them here for mikk"s FindGlobals script
-- GLOBALS: