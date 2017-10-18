-- Lua Wow
local _G = _G
local K, C = _G.unpack(_G.select(2, ...))
local KkthnxUIBlizzFixes = K:NewModule("KkthnxUIBlizzFixes", "AceEvent-3.0", "AceHook-3.0")

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: UIParent, SpellBookFrame, LFRBrowseFrame, PVPTimerFrame, BATTLEFIELD_SHUTDOWN_TIMER

-- Fix floatingCombatText not being enabled after AddOns like MSBT
function KkthnxUIBlizzFixes:FixFloatingCombatText()
	-- print(GetCVar("floatingCombatTextCombatDamage"))
	if (GetCVar("floatingCombatTextCombatDamage") ~= 1) then
		K.LockCVar("floatingCombatTextCombatDamage", GetCVarDefault("floatingCombatTextCombatDamage"))
		K.LockCVar("floatingCombatTextCombatHealing", GetCVarDefault("floatingCombatTextCombatHealing"))
	end
end

-- Fix the excessive "Not enough players" spam in Felsong battlegrounds
function KkthnxUIBlizzFixes:FixNotEnoughPlayers()
	hooksecurefunc("PVP_UpdateStatus", function()
		local isInInstance, instanceType = _G.IsInInstance()
		if (instanceType == "pvp") or (instanceType == "arena") then
			for i = 1, _G.GetMaxBattlefieldID() do
				local status, mapName, teamSize, registeredMatch = GetBattlefieldStatus(i)
				if (status == "active") then
					_G.PVPTimerFrame:SetScript("OnUpdate", nil)
					_G.BATTLEFIELD_SHUTDOWN_TIMER = 0
				else
					local kickOutTimer = GetBattlefieldInstanceExpiration()
					if (kickOutTimer == 0) then
						_G.PVPTimerFrame:SetScript("OnUpdate", nil)
						_G.BATTLEFIELD_SHUTDOWN_TIMER = 0
					end
				end
			end
		end
	end)
end

-- FixOrderHallMap(Ketho)
function KkthnxUIBlizzFixes:FixOrderHallMap()
	local locations = {
		[23] = function() return _G.select(4, _G.GetMapInfo()) and 1007 end, -- Paladin, Sanctum of Light; Eastern Plaguelands
		[1040] = function() return 1007 end, -- Priest, Netherlight Temple; Azeroth
		[1044] = function() return 1007 end, -- Monk, Temple of Five Dawns; none
		[1048] = function() return 1007 end, -- Druid, Emerald Dreamway; none
		[1052] = function() return _G.GetCurrentMapDungeonLevel() > 1 and 1007 end, -- Demon Hunter, Fel Hammer; Mardum
		[1088] = function() return _G.GetCurrentMapDungeonLevel() == 3 and 1033 end, -- Nighthold -> Suramar
	}

	local OnClick = _G.WorldMapZoomOutButton_OnClick

	function WorldMapZoomOutButton_OnClick()
		local id = locations[_G.GetCurrentMapAreaID()]
		local out = id and id()
		if out then
			_G.SetMapByID(out)
		else
			OnClick()
		end
	end
end

-- LookingForGroup taint
function KkthnxUIBlizzFixes:FixLFGTaint()
	_G.CreateFrame("Frame"):SetScript("OnUpdate", function(self, elapsed)
		if LFRBrowseFrame.timeToClear then
			LFRBrowseFrame.timeToClear = nil
		end
	end)
end

-- Misclicks for some popups
function KkthnxUIBlizzFixes:FixMisclickPopups()
	StaticPopupDialogs.RESURRECT.hideOnEscape = nil
	StaticPopupDialogs.AREA_SPIRIT_HEAL.hideOnEscape = nil
	StaticPopupDialogs.PARTY_INVITE.hideOnEscape = nil
	StaticPopupDialogs.CONFIRM_SUMMON.hideOnEscape = nil
	StaticPopupDialogs.ADDON_ACTION_FORBIDDEN.button1 = nil
	StaticPopupDialogs.TOO_MANY_LUA_ERRORS.button1 = nil
	PetBattleQueueReadyFrame.hideOnEscape = nil
	if (PVPReadyDialog) then
		PVPReadyDialog.leaveButton:Hide()
		PVPReadyDialog.enterButton:ClearAllPoints()
		PVPReadyDialog.enterButton:SetPoint("BOTTOM", PVPReadyDialog, "BOTTOM", 0, 25)
		PVPReadyDialog.label:SetPoint("TOP", 0, -22)
	end
end

-- Garbage collection is being overused and misused,
-- and it's causing lag and performance drops.
do
	local oldcollectgarbage = _G.collectgarbage
	oldcollectgarbage("setpause", 110)
	oldcollectgarbage("setstepmul", 200)

	_G.collectgarbage = function(opt, arg)
		if (opt == "collect") or (opt == nil) then
		elseif (opt == "count") then
			return oldcollectgarbage(opt, arg)
		elseif (opt == "setpause") then
			return oldcollectgarbage("setpause", 110)
		elseif opt == "setstepmul" then
			return oldcollectgarbage("setstepmul", 200)
		elseif (opt == "stop") then
		elseif (opt == "restart") then
		elseif (opt == "step") then
			if (arg ~= nil) then
				if (arg <= 10000) then
					return oldcollectgarbage(opt, arg)
				end
			else
				return oldcollectgarbage(opt, arg)
			end
		else
			return oldcollectgarbage(opt, arg)
		end
	end

	-- Memory usage is unrelated to performance, and tracking memory usage does not track "bad" addons.
	-- Developers can uncomment this line to enable the functionality when looking for memory leaks,
	-- but for the average end-user this is a completely pointless thing to track.
	_G.UpdateAddOnMemoryUsage = K.Noop
end

function KkthnxUIBlizzFixes:FixMapBlackOut()
	-- Don't black out the world with the full screen WorldMap,
	-- we want to see what's going on in the background in case of danger!
	if (_G.BlackoutWorld and not C["WorldMap"].Enable) then
		_G.BlackoutWorld:SetAlpha(0)
	end
end

function KkthnxUIBlizzFixes:PLAYER_ENTERING_WORLD(event)
	if (K.IsAddOnEnabled("MikScrollingBattleText")) then
		return
	end

	self:FixFloatingCombatText()

	if event == "PLAYER_ENTERING_WORLD" then
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	end
end

function KkthnxUIBlizzFixes:OnEnable()
	self:FixFloatingCombatText()
	self:FixLFGTaint()
	self:FixMapBlackOut()
	self:FixMisclickPopups()
	self:FixNotEnoughPlayers()
	self:FixOrderHallMap()

	self:RegisterEvent("PLAYER_ENTERING_WORLD")
end