local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("Announcements")

local _G = _G
local string_format = _G.string.format

local GetTime = _G.GetTime
local lastTimePet = 0
local lastTimePlayer = 0
local healthPercent = 35

function Module:SetupHealthAnnounce()
	if (UnitAffectingCombat("pet") and (UnitHealth("pet") / UnitHealthMax("pet") * 100) <= healthPercent) and lastTimePet ~= GetTime() then
		PlaySound(23404, "master")
		UIErrorsFrame:AddMessage(K.InfoColor..string_format(L["The health for %s is low!"], UnitName("pet")))

		lastTimePet = GetTime()
	end
	if (UnitAffectingCombat("player") and (UnitHealth("player") / UnitHealthMax("player") * 100) <= healthPercent) and lastTimePlayer ~= GetTime() then
		PlaySound(23404, "master")
		UIErrorsFrame:AddMessage(K.InfoColor..string_format(L["The health for %s is low!"], UnitName("player")))

		lastTimePlayer = GetTime()
	end
end

function Module:CreateHealthAnnounce()
	if not C["Announcements"].HealthAlert then
		return
	end

	K:RegisterEvent("UNIT_HEALTH", Module.SetupHealthAnnounce)
end