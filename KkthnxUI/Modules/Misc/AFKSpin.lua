local K, C, _ = select(2, ...):unpack()
if C.Misc.AFKCamera ~= true then return end

local CAMERA_SPEED = 0.035
local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local UnitIsAFK = UnitIsAFK
local UnitIsDead = UnitIsDead

local SpinCam = CreateFrame("Frame")
local OnEvent = function(self, event, unit)
	if(InCombatLockdown()) then
		return
	end

	SetCVar("autoClearAFK", "1") -- We need to be sure

	if event == "PLAYER_FLAGS_CHANGED" then
		if unit == "player" then
			if UnitIsAFK(unit) and not UnitIsDead(unit) then
				SpinStart()
			else
				SpinStop()
			end
		end
	elseif event == "PLAYER_DEAD" then
		if UnitIsAFK("player") then
			SpinStop()
		end
	elseif event == "PLAYER_REGEN_DISABLED" then
		if UnitIsAFK("player") then
			SpinStop()
		end
	elseif event == "PLAYER_LEAVING_WORLD" then
		SpinStop()
	end
end
SpinCam:RegisterEvent("PLAYER_DEAD")
SpinCam:RegisterEvent("PLAYER_ENTERING_WORLD")
SpinCam:RegisterEvent("PLAYER_FLAGS_CHANGED")
SpinCam:RegisterEvent("PLAYER_LEAVING_WORLD")
SpinCam:RegisterEvent("PLAYER_LOGIN")
SpinCam:RegisterEvent("PLAYER_REGEN_DISABLED")
SpinCam:SetScript("OnEvent", OnEvent)

function SpinStart()
	spinning = true
	MoveViewRightStart(CAMERA_SPEED)
	UIParent:Hide()
end

function SpinStop()
	if not spinning then return end
	spinning = nil
	MoveViewRightStop()
	UIParent:Show()
end