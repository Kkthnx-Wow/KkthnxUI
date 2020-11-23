local K, C = unpack(select(2, ...))
local Module = K:GetModule("Miscellaneous")

local _G = _G

-- Mouse Trail
local pollingRate = 1 / 60
local numLines = 10
local lines = {}

local function GetLength(startX, startY, endX, endY)
	-- Determine dimensions
	local dx, dy = endX - startX, endY - startY

	-- Normalize direction if necessary
	if dx < 0 then
		dx, dy = -dx, -dy
	end

	-- Calculate actual length of line
	return sqrt((dx * dx) + (dy * dy))
end

local function UpdateTrail()
	local startX, startY = _G.GetScaledCursorPosition()

	for i = 1, numLines do
		local info = lines[i]

		local endX, endY = info.x, info.y
		if GetLength(startX, startY, endX, endY) < 0.1 then
			info.line:Hide()
		else
			info.line:Show()
			info.line:SetStartPoint("BOTTOMLEFT", _G.UIParent, startX, startY)
			info.line:SetEndPoint("BOTTOMLEFT", _G.UIParent, endX, endY)
		end

		info.x, info.y = startX, startY
		startX, startY = endX, endY
	end
end

function Module:CreateMouseTrail()
	if not C["Misc"].MouseTrail then
		return
	end

	for i = 1, numLines do
		local line = _G.UIParent:CreateLine()
		line:SetThickness(_G.Lerp(5, 1, (i - 1) / numLines))
		line:SetColorTexture(unpack(C["Misc"].MouseTrailColor))

		local startA, endA = _G.Lerp(1, 0, (i - 1) / numLines), _G.Lerp(1, 0, i / numLines)
		line:SetGradientAlpha("HORIZONTAL", 1, 1, 1, startA, 1, 1, 1, endA)

		lines[i] = {line = line, x = 0, y = 0}
	end

	C_Timer.NewTicker(pollingRate, UpdateTrail)
end