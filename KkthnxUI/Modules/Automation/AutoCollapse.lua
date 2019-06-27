--local K, C = unpack(select(2, ...))
--local Module = K:NewModule("AutoCollapse", "AceEvent-3.0")

--local _G = _G

--local C_Garrison_IsPlayerInGarrison = _G.C_Garrison.IsPlayerInGarrison
--local InCombatLockdown = _G.InCombatLockdown
--local IsInInstance = _G.IsInInstance
--local IsResting = _G.IsResting
--local ObjectiveTracker_Expand, ObjectiveTracker_Collapse = _G.ObjectiveTracker_Expand, _G.ObjectiveTracker_Collapse
--local TrackerMinimizeButton = _G["ObjectiveTrackerFrame"].HeaderMenu.MinimizeButton

--local TrackerStateDriver = {
--	["FULL"] = function(frame)
--		ObjectiveTracker_Expand()
--		TrackerMinimizeButton:SetNormalTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\TrackerButton")
--		frame:Show()
--	end,

--	["COLLAPSED"] = function(frame)
--		ObjectiveTracker_Collapse()
--		TrackerMinimizeButton:SetNormalTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\TrackerButton")
--		frame:Show()
--	end,

--	["HIDE"] = function(frame)
--		frame:Hide()
--	end,
--}

--function Module:ChangeState(event)
--	if not Module.Database.AutoCollapse then
--		return
--	end

--	if InCombatLockdown() and event ~= "PLAYER_REGEN_DISABLED" then
--		return
--	end

--	local inCombat = event == "PLAYER_REGEN_DISABLED" and true or false

--	if inCombat and Module.Database.Combat.Value ~= "NONE" then
--		TrackerStateDriver[Module.Database.Combat.Value](Module.TrackerFrame)
--	elseif C_Garrison_IsPlayerInGarrison(2) then
--		TrackerStateDriver[Module.Database.Garrison.Value](Module.TrackerFrame)
--	elseif C_Garrison_IsPlayerInGarrison(3) then -- Here be order halls
--		TrackerStateDriver[Module.Database.Orderhall.Value](Module.TrackerFrame)
--	elseif IsResting() then
--		TrackerStateDriver[Module.Database.Rested.Value](Module.TrackerFrame)
--	else
--		local instance, instanceType = IsInInstance()
--		if instance then
--			if instanceType == "pvp" then
--				TrackerStateDriver[Module.Database.Battleground.Value](Module.TrackerFrame)
--			elseif instanceType == "arena" then
--				TrackerStateDriver[Module.Database.Arena.Value](Module.TrackerFrame)
--			elseif instanceType == "party" then
--				TrackerStateDriver[Module.Database.Dungeon.Value](Module.TrackerFrame)
--			elseif instanceType == "scenario" then
--				TrackerStateDriver[Module.Database.Scenario.Value](Module.TrackerFrame)
--			elseif instanceType == "raid" then
--				TrackerStateDriver[Module.Database.Raid.Value](Module.TrackerFrame)
--			end
--		else
--			TrackerStateDriver["FULL"](Module.TrackerFrame)
--		end
--	end

--	if K.CheckAddOnState("WorldQuestTracker") and ObjectiveTrackerFrame.MODULES then -- and WorldQuestTrackerAddon then
--		local y = 0
--		for i = 1, #ObjectiveTrackerFrame.MODULES do
--			local module = ObjectiveTrackerFrame.MODULES[i]
--			if (module.Header:IsShown()) then
--				y = y + module.contentsHeight
--			end
--		end
--		if (ObjectiveTrackerFrame.collapsed) then
--			WorldQuestTrackerAddon.TrackerHeight = 20
--		else
--			WorldQuestTrackerAddon.TrackerHeight = y
--		end

--		WorldQuestTrackerAddon.RefreshTrackerAnchor()
--	end
--end

--function Module:OnEnable()
--	Module.Database = C["Automation"]
--	Module.TrackerFrame = ObjectiveTrackerFrame

--	self:RegisterEvent("LOADING_SCREEN_DISABLED", "ChangeState")
--	self:RegisterEvent("PLAYER_UPDATE_RESTING", "ChangeState")
--	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "ChangeState")
--	self:RegisterEvent("PLAYER_REGEN_ENABLED", "ChangeState")
--	self:RegisterEvent("PLAYER_REGEN_DISABLED", "ChangeState")

--	Module:ChangeState()
--end
