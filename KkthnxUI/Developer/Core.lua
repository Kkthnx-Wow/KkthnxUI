-- Create a new module for the death counter
local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

K.Devs = {
	["Kkthnx-Area 52"] = true,
}

local function isDeveloper()
	return K.Devs[K.Name .. "-" .. K.Realm]
end
K.isDeveloper = isDeveloper()

if not K.isDeveloper then
	return
end

local eventCount = 0
local threshold = 10000

local function performGarbageCollection()
  local before = collectgarbage("count")
  print("Memory usage before garbage collection:", BreakUpLargeNumbers(before))

  collectgarbage("collect")
  local after = collectgarbage("count")
  print("Memory usage after garbage collection:", BreakUpLargeNumbers(after))

  local collected = before - after
  print("Memory collected:", BreakUpLargeNumbers(collected))
end

local function onEvent(event)
  if InCombatLockdown() then return end

  eventCount = eventCount + 1

  if eventCount > threshold or event == "PLAYER_ENTERING_WORLD" then
    performGarbageCollection()
    eventCount = 0
    return
  end

  if event == "PLAYER_FLAGS_CHANGED" and UnitIsAFK("player") then
    performGarbageCollection()
    eventCount = 0
    return
  end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_FLAGS_CHANGED")

frame:SetScript("OnEvent", onEvent)





