local K, C = unpack(select(2, ...))
local Module = K:NewModule("Developer")


local _G = _G

local IsMounted = _G.IsMounted
local UIErrorsFrame = _G.UIErrorsFrame

local dismountMessages = {
	--[_G.TAXIMAP_OPENED] = true,
	[_G.ERR_ATTACK_MOUNTED] = true,
	[_G.ERR_MOUNT_ALREADYMOUNTED] = true,
	[_G.ERR_NOT_WHILE_MOUNTED] = true,
	[_G.ERR_TAXIPLAYERALREADYMOUNTED] = true,
	[_G.SPELL_FAILED_NOT_MOUNTED] = true
}

local standupMessages = {
	[_G.ERR_CANTATTACK_NOTSTANDING] = true,
	[_G.ERR_LOOT_NOTSTANDING] = true,
	[_G.ERR_TAXINOTSTANDING] = true,
	[_G.SPELL_FAILED_NOT_STANDING] = true
}

local function SetupQuickDismountStandup(_, _, ...)
	-- Dismount & DoEmote could be an issue with taints in combat.
	-- Maybe we only allow these out of combat??? Thinking...
	if IsMounted() or dismountMessages[select(2, ...)] then
		_G.Dismount()
		UIErrorsFrame:Clear()
	end

	if standupMessages[select(2, ...)] then
		_G.DoEmote("STAND")
		UIErrorsFrame:Clear()
	end
end

function Module:CreateQuickDismountStandup()
    K:RegisterEvent("UI_ERROR_MESSAGE", SetupQuickDismountStandup)
end

function Module:OnEnable()
    Module:CreateQuickDismountStandup()
end