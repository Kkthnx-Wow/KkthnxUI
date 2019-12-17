local K, C = unpack(select(2,...))

local _G = _G

local math_max = _G.math.max
local math_min = _G.math.min

local InCombatLockdown = _G.InCombatLockdown
local UIParent = _G.UIParent

local function GetPerfectScale()
	local scale = C["General"].UIScale
	local bestScale = math_max(0.4, math_min(1.15, 768 / K.ScreenHeight))
	local pixelScale = 768 / K.ScreenHeight

	if C["General"].AutoScale then
		scale = bestScale
	end

	K.Mult = (bestScale / scale) - ((bestScale - pixelScale) / scale)

	return scale
end

local isScaling = false
function K:SetupUIScale()
	if isScaling then
		return
	end

	isScaling = true

	local scale = GetPerfectScale()
	local parentScale = UIParent:GetScale()
	if scale ~= parentScale and not InCombatLockdown() then
		UIParent:SetScale(scale)
	end

	C["General"].UIScale = scale

	isScaling = false
end