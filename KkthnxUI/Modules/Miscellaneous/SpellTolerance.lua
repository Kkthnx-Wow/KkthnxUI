local K, C, L = unpack(select(2, ...))
if C["General"].SpellTolerance ~= true then return end

local tostring = tostring

local GetCVar = _G.GetCVar
local SetCVar = _G.SetCVar

local SpellTolerance = CreateFrame("Frame")
local int = 5

local _, _, _, lag = GetNetStats()
local function LatencyUpdate(self, elapsed)
  int = int - elapsed
  if int < 0 then
    if K.Legion715 then
      if GetCVar("reducedLagTolerance") ~= tostring(1) then
        SetCVar("reducedLagTolerance", tostring(1))
      end
    end

    if lag ~= 0 and lag <= 400 then
      if K.Legion730 then
        SetCVar("SpellQueueWindow", tostring(lag))
      else
        SetCVar("maxSpellStartRecoveryOffset", tostring(lag))
      end
    end
    int = 5
  end
end

SpellTolerance:SetScript("OnUpdate", LatencyUpdate)
LatencyUpdate(SpellTolerance, 10)