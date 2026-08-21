--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Tooltip/Inspect.lua
	Purpose:
		Add an item level and specialisation line for players on the unit tooltip.
		Inspect data arrives asynchronously, so results are cached per GUID and the
		visible tooltip is patched in place once the inspect resolves.
-----------------------------------------------------------------------------]]

local K = KkthnxUI[1]

local Module = K:GetModule("Tooltip")

local _G = _G
local floor = math.floor

local UnitGUID = UnitGUID
local UnitIsUnit = UnitIsUnit
local IsSecret = K.IsSecret
local CanInspect = _G.CanInspect
local NotifyInspect = _G.NotifyInspect
local ClearInspectPlayer = _G.ClearInspectPlayer
local GetAverageItemLevel = _G.GetAverageItemLevel
local C_PaperDollInfo = _G.C_PaperDollInfo

-- Cache resolved data so we do not re-inspect the same player every hover.
local cache = {}
-- The GUID we are currently waiting on, and the unit token that produced it.
local pending, pendingUnit
-- The GUID the currently shown tooltip was rendered for. Stamped as we add our
-- line, so a late INSPECT_READY can confirm the tooltip is still the same unit
-- without calling UnitGUID on the secret token GameTooltip:GetUnit() hands back.
local shownGUID

local ILVL_COLOR = { 0.9, 0.8, 0.5 }

-- Append the cached line to a tooltip. Blizzard already prints spec and class,
-- so we only add the average item level it leaves out. A double line keeps the
-- label left and the value hard right, matching the mount / rating rows.
local function AddLines(tt, data)
	if data.ilvl and data.ilvl > 0 then
		tt:AddDoubleLine(STAT_AVERAGE_ITEM_LEVEL or "Item Level", data.ilvl, ILVL_COLOR[1], ILVL_COLOR[2], ILVL_COLOR[3], 1, 1, 1)
	end
end

-- Pull the average item level off an inspectable unit.
local function ReadInspect(unit)
	local ilvl
	if C_PaperDollInfo and C_PaperDollInfo.GetInspectItemLevel then
		ilvl = C_PaperDollInfo.GetInspectItemLevel(unit)
	end
	return ilvl and floor(ilvl) or 0
end

function Module:AddInspectInfo(tt, unit)
	local guid = UnitGUID(unit)
	if not guid or IsSecret(guid) then
		return
	end
	shownGUID = guid

	local data = cache[guid]
	if data then
		AddLines(tt, data)
		return
	end

	-- Our own gear is available without an inspect request.
	if UnitIsUnit(unit, "player") then
		local _, ilvl = GetAverageItemLevel()
		data = { ilvl = ilvl and floor(ilvl) or 0 }
		cache[guid] = data
		AddLines(tt, data)
		return
	end

	if CanInspect and CanInspect(unit) and not InCombatLockdown() then
		pending, pendingUnit = guid, unit
		if NotifyInspect then
			NotifyInspect(unit)
		end
	end
end

function Module:SetupInspect()
	local watcher = CreateFrame("Frame")
	watcher:RegisterEvent("INSPECT_READY")
	watcher:SetScript("OnEvent", function(_, _, guid)
		if IsSecret(guid) or guid ~= pending then
			return
		end

		local unit = pendingUnit
		pending, pendingUnit = nil, nil

		cache[guid] = { ilvl = ReadInspect(unit) }
		if ClearInspectPlayer then
			ClearInspectPlayer()
		end

		-- If the tooltip still shows the unit we inspected, patch it in place.
		-- GameTooltip:GetUnit() returns a secret token here, which cannot be fed
		-- to UnitGUID, so we compare against the GUID stamped when we rendered.
		local tt = _G.GameTooltip
		if tt:IsShown() and shownGUID == guid then
			AddLines(tt, cache[guid])
			tt:Show()
		end
	end)
	self.inspectWatcher = watcher
end
