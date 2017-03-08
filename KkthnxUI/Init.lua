-- Initiation / Engine of KkthnxUI

local AddOnName, Engine = ...

-- Lua API
local _G = _G

-- Wow API
local CreateFrame = _G.CreateFrame

Engine[1] = CreateFrame("Frame") -- K, Functions, Constants, Variables
Engine[2] = {} -- C, Config
Engine[3] = {} -- L, Localization

_G[AddOnName] = Engine -- Allow other addons to use our Engine