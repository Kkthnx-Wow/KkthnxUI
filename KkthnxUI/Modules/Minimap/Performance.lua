--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Minimap/Performance.lua
	Purpose:
		The framerate and latency datatext, reading like "100fps - 10ms". The two
		numbers are graded against our shared palette (jade, gold, ember, crimson)
		so a glance tells you whether things are healthy, while the fps and ms
		labels take a colour of your choosing (white, class, or custom).

		Hovering gives the detail: home and world latency, bandwidth, the client
		framerate, and the addons costing the most time this session, read from
		the game's own addon profiler rather than a guess at memory use.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

local Module = K:GetModule("Minimap")

local _G = _G
local format = string.format
local ipairs = ipairs
local sort = table.sort
local tinsert = table.insert
local min = math.min
local floor = math.floor

local CreateFrame = CreateFrame
local GetFramerate = _G.GetFramerate
local GetNetStats = _G.GetNetStats
local C_AddOnProfiler = _G.C_AddOnProfiler
local C_AddOns = _G.C_AddOns
local UpdateAddOnMemoryUsage = _G.UpdateAddOnMemoryUsage
local GetAddOnMemoryUsage = _G.GetAddOnMemoryUsage
local collectgarbage = collectgarbage

local Minimap = _G.Minimap

-- How often the readout refreshes. Latency only moves every 30 seconds client
-- side, so a one second tick is plenty and keeps this cheap.
local UPDATE_INTERVAL = 1

-- Grading thresholds. Framerate counts UP (higher is better) and latency counts
-- DOWN (lower is better), so each list is walked in its own direction.
local FPS_STEPS = { { 60, "jade" }, { 40, "gold" }, { 20, "ember" } }
local MS_STEPS = { { 75, "jade" }, { 150, "gold" }, { 300, "ember" } }

-- Colour for a framerate: jade at 60 and above, then down through gold and ember
-- to crimson.
local function FPSColor(value)
	for _, step in ipairs(FPS_STEPS) do
		if value >= step[1] then
			return K.Colors[step[2]]
		end
	end
	return K.Colors.crimson
end

-- Colour for a latency in milliseconds, the same scale inverted.
local function MSColor(value)
	for _, step in ipairs(MS_STEPS) do
		if value <= step[1] then
			return K.Colors[step[2]]
		end
	end
	return K.Colors.crimson
end

local function Hex(color)
	return format("|cff%02x%02x%02x", color[1] * 255, color[2] * 255, color[3] * 255)
end

-- The colour the fps and ms labels wear, per the config.
local function LabelColor()
	local mode = C.Minimap.PerformanceLabelColor
	if mode == "Class" then
		local c = K.ClassColor
		return { c.r or c[1], c.g or c[2], c.b or c[3] }
	elseif mode == "Custom" then
		return C.Minimap.PerformanceCustomColor or { 1, 1, 1 }
	end
	return { 1, 1, 1 }
end

-- The worse of the two latencies is the one worth showing, since either one
-- being bad is what you actually feel.
local function Latency()
	if not GetNetStats then
		return 0, 0, 0, 0
	end
	local inBps, outBps, home, world = GetNetStats()
	home = home or 0
	world = world or 0
	return (home > world and home or world), home, world, (inBps or 0) + (outBps or 0)
end

local function BuildText()
	local fps = floor(GetFramerate() or 0)
	local ms = Latency()
	local label = Hex(LabelColor())
	local sep = C.Minimap.PerformanceSeparator or "-"
	return format("%s%d|r%sfps|r %s%s %s%d|r%sms|r", Hex(FPSColor(fps)), fps, label, label, sep, Hex(MSColor(ms)), ms, label)
end

-- ---------------------------------------------------------------------------
-- Tooltip
-- ---------------------------------------------------------------------------

-- Addon cost, newest first. The profiler reports real time per tick, which is a
-- far better signal than memory, so use it when the client has it enabled and
-- fall back to memory only when it does not.
local function AddProfilerLines(tooltip)
	if not (C_AddOnProfiler and C_AddOnProfiler.IsEnabled and C_AddOnProfiler.IsEnabled()) then
		return false
	end
	local metric = Enum.AddOnProfilerMetric and Enum.AddOnProfilerMetric.RecentAverageTime
	if not metric or not C_AddOnProfiler.GetTopKAddOnsForMetric then
		return false
	end

	local results = C_AddOnProfiler.GetTopKAddOnsForMetric(metric, 5)
	if not results or #results == 0 then
		return false
	end

	tooltip:AddLine(" ")
	tooltip:AddLine(L["Addon CPU (average per frame)"], 0.6, 0.8, 1)
	for _, entry in ipairs(results) do
		local name = entry.addOnName or "?"
		local value = entry.metricValue or 0
		-- Grade an addon the same way as the framerate, on time cost per frame.
		local color = value < 1 and K.Colors.jade or (value < 5 and K.Colors.gold or (value < 10 and K.Colors.ember or K.Colors.crimson))
		tooltip:AddDoubleLine(name, format("%.2f ms", value), 1, 1, 1, color[1], color[2], color[3])
	end
	return true
end

-- Memory fallback for clients with the profiler switched off.
local function AddMemoryLines(tooltip)
	if not (UpdateAddOnMemoryUsage and GetAddOnMemoryUsage and C_AddOns and C_AddOns.GetNumAddOns) then
		return
	end
	UpdateAddOnMemoryUsage()

	local list, total = {}, 0
	for i = 1, C_AddOns.GetNumAddOns() do
		if C_AddOns.IsAddOnLoaded(i) then
			local mem = GetAddOnMemoryUsage(i) or 0
			total = total + mem
			local name = C_AddOns.GetAddOnInfo(i)
			tinsert(list, { name = name or "?", mem = mem })
		end
	end
	if #list == 0 then
		return
	end
	sort(list, function(a, b)
		return a.mem > b.mem
	end)

	tooltip:AddLine(" ")
	tooltip:AddLine(L["Addon Memory"], 0.6, 0.8, 1)
	for i = 1, min(5, #list) do
		local entry = list[i]
		tooltip:AddDoubleLine(entry.name, format("%.2f mb", entry.mem / 1024), 1, 1, 1, 0.8, 0.8, 0.8)
	end
	tooltip:AddDoubleLine(_G.TOTAL or "Total", format("%.2f mb", total / 1024), 1, 0.82, 0, 1, 1, 1)
end

function Module:PerformanceTooltip(anchor)
	local fps = floor(GetFramerate() or 0)
	local _, home, world, bandwidth = Latency()

	GameTooltip:SetOwner(anchor, "ANCHOR_LEFT")
	GameTooltip:ClearLines()
	GameTooltip:AddLine(L["Performance"], 0.4, 0.78, 1)
	GameTooltip:AddLine(" ")

	local fc = FPSColor(fps)
	GameTooltip:AddDoubleLine(L["Framerate"], format("%d fps", fps), 1, 1, 1, fc[1], fc[2], fc[3])

	local hc, wc = MSColor(home), MSColor(world)
	GameTooltip:AddDoubleLine(L["Home Latency"], format("%d ms", home), 1, 1, 1, hc[1], hc[2], hc[3])
	GameTooltip:AddDoubleLine(L["World Latency"], format("%d ms", world), 1, 1, 1, wc[1], wc[2], wc[3])
	GameTooltip:AddDoubleLine(L["Bandwidth"], format("%.2f kb/s", bandwidth), 1, 1, 1, 0.8, 0.8, 0.8)

	if collectgarbage then
		GameTooltip:AddDoubleLine(L["UI Memory"], format("%.2f mb", (collectgarbage("count") or 0) / 1024), 1, 1, 1, 0.8, 0.8, 0.8)
	end

	if not AddProfilerLines(GameTooltip) then
		AddMemoryLines(GameTooltip)
	end

	GameTooltip:AddLine(" ")
	GameTooltip:AddLine("|cff669dffLeft Click|r " .. L["Collect garbage"], 0.6, 0.6, 0.6)
	GameTooltip:Show()
end

-- ---------------------------------------------------------------------------
-- Build
-- ---------------------------------------------------------------------------

function Module:CreatePerformance()
	if not C.Minimap.ShowPerformance then
		return
	end

	local perf = CreateFrame("Button", "KKUI_Performance", UIParent)
	-- Match the map width so the strip lines up with the other readouts around it,
	-- and keep the height in step with the text size.
	local width = C.Minimap.Size or 200
	local height = (C.Minimap.PerformanceFontSize or 13) + 6
	perf:SetSize(width, height)
	perf:RegisterForClicks("AnyUp")

	local text = perf:CreateFontString(nil, "OVERLAY")
	K.SetFont(text, C.Minimap.PerformanceFontSize or 13, K.FontOutlineStyle())
	-- Centred rather than filling the button, so the strip below hugs the readout
	-- instead of stretching the full click area.
	text:SetPoint("CENTER")
	perf.Text = text
	self.performance = perf

	-- The shared strip, spanning the whole readout like the zone name, the clock
	-- and the coordinates do.
	local shade = K.CreateTextShade(perf, "ARTWORK", 6)
	shade:SetRegion(perf, 0, 0)
	shade:SetColor(K.StripColor[1], K.StripColor[2], K.StripColor[3], K.GradientAlpha.strip)
	shade:Show()
	perf.Shade = shade

	-- Sits under the map by default, below the coordinate readout, and is movable
	-- from there like any other piece of the UI.
	local default = { "TOP", Minimap, "BOTTOM", 0, C.Minimap.ShowCoords and -22 or -6 }
	K.CreateMover(perf, "Performance", L["Performance"], default, width, height)

	-- A manual garbage collect, which is the one genuinely useful action here.
	perf:SetScript("OnMouseUp", function()
		if collectgarbage then
			local before = collectgarbage("count") or 0
			collectgarbage("collect")
			local after = collectgarbage("count") or 0
			K.Print("Collected %.2f mb", (before - after) / 1024)
		end
	end)
	perf:SetScript("OnEnter", function(self2)
		Module:PerformanceTooltip(self2)
	end)
	perf:SetScript("OnLeave", GameTooltip_Hide)

	-- Self-throttled, matching the clock datatext.
	local elapsed = UPDATE_INTERVAL
	perf:SetScript("OnUpdate", function(_, delta)
		elapsed = elapsed + delta
		if elapsed < UPDATE_INTERVAL then
			return
		end
		elapsed = 0
		text:SetText(BuildText())
	end)
end
