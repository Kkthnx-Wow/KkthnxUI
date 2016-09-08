local K, C, L, _ = select(2, ...):unpack()

local collectgarbage = collectgarbage
local UnitIsAFK = UnitIsAFK
local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local CollectGarbage = CreateFrame("Frame")

local eventcount = 0
function CollectGarbage:OnEvent(event, unit)
	eventcount = eventcount + 1

	if (InCombatLockdown() and eventcount > 25000) or (not InCombatLockdown() and eventcount > 10000) or event == "PLAYER_ENTERING_WORLD" then
		collectgarbage("collect")
		eventcount = 0

		self:UnregisterEvent(event)
	else
		if (unit ~= "player") then
			return
		end

		if UnitIsAFK(unit) then
			collectgarbage("collect")
		end
	end
end

function CollectGarbage:Enable()
	self:SetScript("OnEvent", self.OnEvent)
end

CollectGarbage:RegisterEvent("PLAYER_FLAGS_CHANGED")
CollectGarbage:RegisterEvent("PLAYER_ENTERING_WORLD")

function CollectGarbage:OnEvent(event, addon)
	if (event == "PLAYER_LOGIN") then
		CollectGarbage:Enable()
	end
end

CollectGarbage:RegisterEvent("PLAYER_LOGIN")
CollectGarbage:RegisterEvent("ADDON_LOADED")
CollectGarbage:SetScript("OnEvent", CollectGarbage.OnEvent)