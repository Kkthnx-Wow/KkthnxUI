local K, C = unpack(select(2, ...))

local _G = _G

local math_max = _G.math.max
local math_min = _G.math.min

local isScaling = false

local function GetBestScale()
	return math_max(0.4, math_min(1.15, 768 / K.ScreenHeight))
end

function K:SetupUIScale(init)
	if C["General"].AutoScale == true then
		C["General"].UIScale = GetBestScale()
	end

	local scale = C["General"].UIScale
	if init == true then
		local pixel, ratio = 1, 768 / K.ScreenHeight
		K.Mult = (pixel / scale) - ((pixel - ratio) / scale)
	elseif not InCombatLockdown() then
		UIParent:SetScale(scale)
	end
end

function K:UpdatePixelScale(event)
	if isScaling then
		return
	end
	isScaling = true

	if event == "UI_SCALE_CHANGED" then
		K.ScreenWidth, K.ScreenHeight = GetPhysicalScreenSize()
	end

	K:SetupUIScale(true)
	K:SetupUIScale()

	isScaling = false
end

function K:Scale(x)
	local mult = K.Mult
	return mult * math.floor(x / mult + 0.5)
end