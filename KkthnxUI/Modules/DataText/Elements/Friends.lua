local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("Friends")

local function OnEvent()
end

local function OnEnter()
end

local function OnLeave()
	K.HideTooltip()
end

function Module:OnEnable()
end