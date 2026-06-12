local K = KkthnxUI[1]

-- MIDNIGHT (12.0): The old smoothing here replaced StatusBar:SetValue /
-- SetMinMaxValues and animated the fill in Lua (Lerp + ratio math). Health and
-- power values are now secret in combat/instances, so any arithmetic or
-- comparison on them throws "attempt to compare a secret number value".
--
-- Blizzard's StatusBar widget gained native interpolation that does the easing
-- inside the engine (secret-safe). The bundled oUF already forwards
-- `element.smoothing` to SetValue(value, interpolation) for Health, Power,
-- AlternativePower and Castbar, so we just flag the bar with an interpolation
-- enum instead of hooking it -- this mirrors NDui's UF:SmoothBar.

local next = next
local tonumber = _G.tonumber
local Enum = _G.Enum

-- REASON: Resolve the interpolation enums defensively in case a flavor lacks them.
local INTERPOLATION = Enum and Enum.StatusBarInterpolation
local SMOOTH = (INTERPOLATION and INTERPOLATION.ExponentialEaseOut) or 1
local IMMEDIATE = (INTERPOLATION and INTERPOLATION.Immediate) or 0

-- REASON: Track smoothed bars so a live smoothing toggle can re-apply to all of them.
local handledObjects = {}
local smoothingEnabled = true

local function ApplySmoothing(bar)
	-- NOTE: oUF reads bar.smoothing and passes it to SetValue(value, interpolation).
	bar.smoothing = smoothingEnabled and SMOOTH or IMMEDIATE
end

function K:SmoothBar(bar)
	handledObjects[bar] = true
	ApplySmoothing(bar)
end

function K:DesmoothBar(bar)
	handledObjects[bar] = nil
	bar.smoothing = IMMEDIATE
end

function K:SetSmoothingAmount(amount)
	-- MIDNIGHT (12.0): native interpolation has no per-amount knob like the old
	-- Lua lerp did, so treat any positive amount as "smoothing on" (ExponentialEaseOut)
	-- and <= 0 as "off" (Immediate). Re-apply to every tracked bar so the change is live.
	smoothingEnabled = (tonumber(amount) or 0) > 0

	for bar in next, handledObjects do
		ApplySmoothing(bar)
	end
end
