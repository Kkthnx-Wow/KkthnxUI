--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/QoL/BossBanner.lua
	Purpose:
		Hide the large banner that drops from the top of the screen when a boss
		dies, with its loot list. The kill and the loot still show in chat and in
		the loot window.

		The banner is told to stop listening for the two events that raise it.
		Nothing on the banner is changed, so turning the option off and reloading
		puts it back.
-----------------------------------------------------------------------------]]

local K = KkthnxUI[1]

if not (K.Client and K.Client.IsRetail) then
	return
end

local Module = K:GetModule("QoL")

function Module:SetupBossBanner()
	local banner = _G.BossBanner
	if not banner then
		return
	end
	banner:UnregisterEvent("BOSS_KILL")
	banner:UnregisterEvent("ENCOUNTER_LOOT_RECEIVED")
end
