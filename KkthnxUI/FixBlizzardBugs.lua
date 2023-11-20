local K = KkthnxUI[1], KkthnxUI[2]
local Module = K:NewModule("FixBlizzardBugs")

-- Workaround for https://worldofwarcraft.blizzard.com/en-gb/news/24030413/hotfixes-november-16-2023
local InCombatLockdown = _G.InCombatLockdown

-- Check if "IsItemInRange" is a secure variable
if issecurevariable("IsItemInRange") then
	-- If it is secure, store the original function
	local IsItemInRange = _G.IsItemInRange

	-- Replace the original function with a new version
	_G.IsItemInRange = function(...)
		-- If in combat, return true (or modify as needed)
		return InCombatLockdown() and true or IsItemInRange(...)
	end
end

-- Check if "UnitInRange" is a secure variable
if issecurevariable("UnitInRange") then
	-- If it is secure, store the original function
	local UnitInRange = _G.UnitInRange

	-- Replace the original function with a new version
	_G.UnitInRange = function(...)
		-- If in combat, return true (or modify as needed)
		return InCombatLockdown() and true or UnitInRange(...)
	end
end

function Module:OnEnable()
	-- Don't call this prior to our own addon loading,
	-- or it'll completely mess up the loading order.
	C_AddOns.LoadAddOn("Blizzard_Channels")

	-- Kill off the non-stop voice chat error 17 on retail.
	-- This only occurs in linux, but we can't check for that.
	ChannelFrame:UnregisterEvent("VOICE_CHAT_ERROR")
end
