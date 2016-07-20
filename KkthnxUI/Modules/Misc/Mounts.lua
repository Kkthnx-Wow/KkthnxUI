local K, C, L, _ = select(2, ...):unpack()

local IsMounted = IsMounted
local CanExitVehicle = CanExitVehicle
local IsFlyableArea = IsFlyableArea
local IsControlKeyDown = IsControlKeyDown
local GetNumCompanions = GetNumCompanions
local GetCompanionInfo = GetCompanionInfo

-- Universal Mount macro(by Monolit)
-- /cancelform [noform:4]
-- /run Mountz("your_ground_mount","your_flying_mount")
function Mountz(groundmount, flyingmount)
	local flyablex, nofly
	local num = GetNumCompanions("MOUNT")
	if not num or IsMounted() then
		Dismount()
		return
	end
	if CanExitVehicle() then
		VehicleExit()
		return
	end
	if IsUsableSpell(59569) ~= true then
		nofly = true
	end
	flyablex = IsFlyableArea()
	if not nofly and IsFlyableArea() then
		flyablex = true
	end
	if IsControlKeyDown() then
		flyablex = not flyablex
	end
	for i = 1, num, 1 do
		local _, info  = GetCompanionInfo("MOUNT", i)
		if flyingmount and info == flyingmount and flyablex then
			CallCompanion("MOUNT", i)
			return
		elseif groundmount and info == groundmount and not flyablex then
			CallCompanion("MOUNT", i)
			return
		end
	end
end