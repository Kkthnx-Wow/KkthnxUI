local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Chat")

local UnitGroupRolesAssigned = UnitGroupRolesAssigned

-- Role icons
local ChatMSG = {
	CHAT_MSG_INSTANCE_CHAT = 1,
	CHAT_MSG_INSTANCE_CHAT_LEADER = 1,
	CHAT_MSG_PARTY = 1,
	CHAT_MSG_PARTY_LEADER = 1,
	CHAT_MSG_RAID = 1,
	CHAT_MSG_RAID_LEADER = 1,
	CHAT_MSG_RAID_WARNING = 1,
	CHAT_MSG_SAY = 1,
	CHAT_MSG_WHISPER = 1,
	CHAT_MSG_WHISPER_INFORM = 1,
	CHAT_MSG_YELL = 1,
}

local IconTex = {
	DAMAGER = "",
	HEALER = "|TInterface\\LFGFrame\\LFGRole:12:12:0:0:64:16:48:64:0:16|t",
	TANK = "|TInterface\\LFGFrame\\LFGRole:12:12:0:0:64:16:32:48:0:16|t",
}

local GetChatRoleIcons = GetColoredName
local function SetupChatRoleIcons(event, arg1, arg2, ...)
	local ret = GetChatRoleIcons(event, arg1, arg2, ...)
	if ChatMSG[event] then
		local playerRole = UnitGroupRolesAssigned(arg2)
		if playerRole == "NONE" and arg2:match(" *- *" .. K.Realm .. "$") then
			playerRole = UnitGroupRolesAssigned(arg2:gsub(" *-[^-]+$", ""))
		end

		if playerRole and IconTex[playerRole] then
			ret = IconTex[playerRole] .. ret
		end
	end

	return ret
end

function Module:CreateChatRoleIcon()
	if not C["Chat"].RoleIcons then
		return
	end

	_G.GetColoredName = SetupChatRoleIcons
end
