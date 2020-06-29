local K, C = unpack(select(2, ...))
local Module = K:GetModule("Miscellaneous")

local _G = _G

local InCombatLockdown = _G.InCombatLockdown
local UnitIsAFK = _G.UnitIsAFK

local isSpinning
local function SpinStart()
	isSpinning = true
	MoveViewRightStart(0.1)
	UIParent:Hide()
end

local function SpinStop()
	if not isSpinning then
		return
	end

	isSpinning = nil
	MoveViewRightStop()
	if InCombatLockdown() then
		return
	end

	UIParent:Show()
end

function Module:SetupSpinCam(event)
	if event == "PLAYER_LEAVING_WORLD" then
		SpinStop()
	else
		if UnitIsAFK("player") and not InCombatLockdown() then
			SpinStart()
		else
			SpinStop()
		end
	end
end

function Module:CreateAFKCam()
	if not C["Misc"].AFKCamera then
		return
	end

	K:RegisterEvent("PLAYER_LEAVING_WORLD", Module.SetupSpinCam)
	K:RegisterEvent("PLAYER_FLAGS_CHANGED", Module.SetupSpinCam)
end