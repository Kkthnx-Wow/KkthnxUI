local K, C = unpack(select(2, ...))
local Module = K:GetModule("Automation")

local _G = _G

local GetBindingAction = _G.GetBindingAction
local GetBindingKey = _G.GetBindingKey
local GetCurrentBindingSet = _G.GetCurrentBindingSet
local GetZonePVPInfo = _G.GetZonePVPInfo
local InCombatLockdown = _G.InCombatLockdown
local IsInInstance = _G.IsInInstance
local SaveBindings = _G.SaveBindings
local SetBinding = _G.SetBinding

-- Replace these into our config later?
local isFail = false
local isOpenWorld = false
local isDefaultKey = true

function Module:OnTabBinderEvent(event, ...)
	if event == "ZONE_CHANGED_NEW_AREA" or (event == "PLAYER_REGEN_ENABLED" and isFail) or event == "DUEL_REQUESTED" or event == "DUEL_FINISHED" or event == "CHAT_MSG_SYSTEM" then
		if event == "CHAT_MSG_SYSTEM" and ... == _G.ERR_DUEL_REQUESTED then
			event = "DUEL_REQUESTED"
		elseif event == "CHAT_MSG_SYSTEM" then
			return
		end

		local BindSet = GetCurrentBindingSet()
		if BindSet ~= 1 and BindSet ~= 2 then
			return
		end

		if InCombatLockdown() then
			isFail = true
			return
		end

		local PVPType = GetZonePVPInfo()
		local _, ZoneType = IsInInstance()
		local TargetKey = GetBindingKey("TARGETNEARESTENEMYPLAYER")
		if TargetKey == nil then
			TargetKey = GetBindingKey("TARGETNEARESTENEMY")
		end

		if TargetKey == nil and isDefaultKey then
			TargetKey = "TAB"
		end

		local LastTargetKey = GetBindingKey("TARGETPREVIOUSENEMYPLAYER")
		if LastTargetKey == nil then
			LastTargetKey = GetBindingKey("TARGETPREVIOUSENEMY")
		end

		if LastTargetKey == nil and isDefaultKey then
			LastTargetKey = "SHIFT-TAB"
		end

		local CurrentBind
		if TargetKey then
			CurrentBind = GetBindingAction(TargetKey)
		end

		if ZoneType == "arena" or ZoneType == "pvp" or (isOpenWorld and ZoneType == "none") or PVPType == "combat" or event == "DUEL_REQUESTED" then
			if CurrentBind ~= "TARGETNEARESTENEMYPLAYER" then
				local Success
				if TargetKey == nil then
					Success = true
				else
					Success = SetBinding(TargetKey, "TARGETNEARESTENEMYPLAYER")
				end

				if LastTargetKey then
					SetBinding(LastTargetKey, "TARGETPREVIOUSENEMYPLAYER")
				end

				if Success then
					SaveBindings(BindSet)
					isFail = false
					K.Print("\124cFF74D06C[AutoTabBinder]\124r PVP Mode")
				else
					isFail = true
				end
			end
		else
			if CurrentBind ~= "TARGETNEARESTENEMY" then
				local Success
				if TargetKey == nil then
					Success = true
				else
					Success = SetBinding(TargetKey, "TARGETNEARESTENEMY")
				end

				if LastTargetKey then
					SetBinding(LastTargetKey, "TARGETPREVIOUSENEMY")
				end

				if Success then
					SaveBindings(BindSet)
					isFail = false
					K.Print("\124cFF74D06C[AutoTabBinder]\124r PVE Mode")
				else
					isFail = true
				end
			end
		end
	end
end

function Module:CreateAutoTabBinder()
	if not C["Automation"].AutoTabBinder then
		return
	end

	K:RegisterEvent("ZONE_CHANGED_NEW_AREA", self.OnTabBinderEvent)
	K:RegisterEvent("PLAYER_REGEN_ENABLED", self.OnTabBinderEvent)
	K:RegisterEvent("DUEL_REQUESTED", self.OnTabBinderEvent)
	K:RegisterEvent("DUEL_FINISHED", self.OnTabBinderEvent)
	K:RegisterEvent("CHAT_MSG_SYSTEM", self.OnTabBinderEvent)
end