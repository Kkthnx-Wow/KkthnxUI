--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Automation/Core.lua
	Purpose:
		A home for automations. This file owns the module and turns each one on from
		its own file, so every one stays self contained and easy to add to:
			DeclineDuel.lua  turn away duel and pet-battle duel requests
			MovieSkip.lua    skip cinematics and movies
			AutoRepair.lua   repair gear at a merchant, optionally on guild funds
			Quest.lua        hands-off questing (Accept/TurnIn/Gossip handlers)
		Each handler re-checks its own toggle when it fires, so changes apply
		without a reload. Retail only.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

if not (K.Client and K.Client.IsRetail) then
	return
end

local Module = K:NewModule("Automation")

function Module:OnEnable()
	-- The small quality-of-life automations share one toggle.
	if C.Automation.Enable then
		if self.SetupDeclineDuel then
			self:SetupDeclineDuel()
		end
		if self.SetupMovieSkip then
			self:SetupMovieSkip()
		end
		if self.SetupAutoRepair then
			self:SetupAutoRepair()
		end
	end

	-- Hands-off questing (Quest.lua) has its own C.AutoQuest toggle, so it runs
	-- independently of the small-automations toggle above.
	if self.SetupQuests then
		self:SetupQuests()
	end
end
