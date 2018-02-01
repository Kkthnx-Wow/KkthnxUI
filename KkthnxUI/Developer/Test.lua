local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("Testing", "AceEvent-3.0")

-- C["Testing"] = {

-- }

--[[
So I can test stuff.

Use this file for testing stuff that I do not want in the UI or I am unsure about.
This is a good file to mess around with code in for anyone else as well.

	((------ CodeName: Code Gone Wild :D ------))
	]]

--[[
This is the layout we need to follow.
local WelcomeHome = K:NewModule("WelcomeHome", "AceConsole-3.0")

function WelcomeHome:OnInitialize()
	-- Called when the addon is loaded
end

function WelcomeHome:OnEnable()
	self:RewardPrint("Hello World!")
end

function WelcomeHome:OnDisable()
	-- Called when the addon is disabled
end
]]