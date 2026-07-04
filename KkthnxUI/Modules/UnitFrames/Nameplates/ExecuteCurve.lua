--[[-----------------------------------------------------------------------------
-- Execute-phase name text coloring via UnitHealthPercent + color curve (Midnight-safe).
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Unitframes")
local NP = Module.NP

local CreateColor = CreateColor
local Enum = Enum

local executedCurve = C_CurveUtil and C_CurveUtil.CreateColorCurve and C_CurveUtil.CreateColorCurve()
if executedCurve then
	executedCurve:SetType(Enum.LuaCurveType.Step)
end
NP.executedCurve = executedCurve

function Module:UpdateExecuteCurve()
	if not executedCurve then
		return
	end

	local executeRatio = C["Nameplate"].ExecuteRatio or 0
	local executeColor = C["Nameplate"].ExecuteColor
	executedCurve:ClearPoints()
	executedCurve:AddPoint(executeRatio / 100, CreateColor(1, 1, 1))
	executedCurve:AddPoint(0, CreateColor(executeColor[1], executeColor[2], executeColor[3]))
end
