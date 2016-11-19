-- Initiation / Engine of KkthnxUI
local _G =_G

local AddOnName, Engine = ...

Engine[1] = {}
Engine[2] = {}
Engine[3] = {}

function Engine:unpack()
	return self[1], self[2], self[3]
end

_G[AddOnName] = Engine

--[[
-- ** KkthnxUI Engine Documentation ** --

	This should be at the top of every file inside of the KkthnxUI AddOn.
	local K, C, L = select(2, ...):unpack()
	You can also do local K, C = select(2, ...):unpack()
	As well as K = select(2, ...):unpack()
	This is going to depend on what you are going to be using in the file.

	This is how another addon imports the KkthnxUI engine.
	local K, C, L = KkthnxUI:unpack()
	You can also do local K, C = KkthnxUI:unpack()
	As well as K = select(2, ...):unpack()
	This is going to depend on what you are going to be using in the file.

--]]
