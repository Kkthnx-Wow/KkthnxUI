-- Initiation / Engine of KkthnxUI

local AddOnName, Engine = ...

-- Lua API
local _G = _G

Engine[1] = CreateFrame("Frame")
Engine[2] = {}
Engine[3] = {}
Engine[4] = {}

_G[AddOnName] = Engine -- Allow other addons to use our Engine