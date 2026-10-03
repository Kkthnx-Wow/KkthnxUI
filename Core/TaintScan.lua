--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Core/TaintScan.lua
	Purpose:
		Find out what this addon has written into Blizzard's tables.

		A "tainted by KkthnxUI" error means Blizzard code ran with our taint on it.
		The taint comes from a value we wrote that Blizzard later read, or a
		function of ours that Blizzard called. Guessing which write is responsible
		is how the same bug gets fixed four times, so this measures it: for every
		key on a set of Blizzard tables it asks issecurevariable who last wrote it,
		and lists the ones that say KkthnxUI.

		It only reads. Nothing here writes to a Blizzard table, so the scan cannot
		change what it measures.

			/kkdebug taint                scan the default set of tables
			/kkdebug taint <GlobalName>   scan one table, two levels deep

		It also reports whether the tooltip, map and tracker regions have restricted
		or secret anchoring. FontString:GetStringHeight is documented as returning a
		secret value when anchoring is secret, which is the failure in the widget
		tooltip errors.

		To use it as a control, run it on a fresh reload with the suspect feature
		off, then again with it on, and compare. A line that appears only in the
		second run belongs to that feature.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

local Debug = K.Debug

local pairs, pcall, type, tostring = pairs, pcall, type, tostring
local format, tconcat, sort = string.format, table.concat, table.sort
local issecurevariable = _G.issecurevariable
local issecretvalue = _G.issecretvalue

-- The name issecurevariable reports for something this addon wrote.
local ADDON = "KkthnxUI"

local stream = Debug.Register("taint", "Result of the last taint scan")

-- Tables to inspect, each with how many levels of nested tables to follow. Frames
-- are tables whose child frames are fields, so depth grows fast and stays small.
local ROOTS = {
	-- Tooltips, the path in the widget errors.
	{ "GameTooltip", 1 },
	{ "GameTooltip.widgetContainer", 2 },
	{ "ItemRefTooltip", 1 },
	{ "ShoppingTooltip1", 1 },
	{ "ShoppingTooltip2", 1 },
	{ "EmbeddedItemTooltip", 1 },
	{ "UIWidgetManager", 1 },

	-- World map and its pin machinery.
	{ "WorldMapFrame", 1 },
	{ "WorldMapFrame.ScrollContainer", 1 },
	{ "MapCanvasPinMixin", 0 },
	{ "MapCanvasDataProviderMixin", 0 },
	{ "AreaPOIPinMixin", 0 },
	{ "VignettePinMixin", 0 },
	{ "UIWidgetBaseTemplateMixin", 0 },
	{ "UIWidgetTemplateTextWithStateMixin", 0 },
	{ "UIWidgetTemplateItemDisplayMixin", 0 },

	-- Objective tracker, the path in the Maw buff errors.
	{ "ObjectiveTrackerFrame", 1 },
	{ "ObjectiveTrackerManager", 1 },
	{ "ScenarioObjectiveTracker", 1 },
	{ "QuestObjectiveTracker", 1 },
	{ "CampaignQuestObjectiveTracker", 1 },
	{ "WorldQuestObjectiveTracker", 1 },
	{ "BonusObjectiveTracker", 1 },
	{ "AchievementObjectiveTracker", 1 },
	{ "UIWidgetObjectiveTracker", 1 },
	{ "ProfessionsRecipeTracker", 1 },
	{ "MonthlyActivitiesObjectiveTracker", 1 },
	{ "InitiativeTasksObjectiveTracker", 1 },
	{ "ObjectiveTrackerModuleMixin", 0 },
	{ "ObjectiveTrackerBlockMixin", 0 },
	{ "ObjectiveTrackerContainerMixin", 0 },

	-- Frames this addon reskins or replaces.
	{ "Minimap", 1 },
	{ "MinimapCluster", 1 },
	{ "ExpansionLandingPageMinimapButton", 1 },
	{ "QueueStatusButton", 1 },
	{ "EditModeManagerFrame", 1 },
	{ "ChatFrame1", 1 },
	{ "GeneralDockManager", 1 },
	{ "PlayerFrame", 1 },
	{ "TargetFrame", 1 },
	{ "FocusFrame", 1 },
	{ "PartyFrame", 1 },
	{ "BuffFrame", 1 },
	{ "DebuffFrame", 1 },
	{ "MainActionBar", 1 },
	{ "StatusTrackingBarManager", 1 },
	{ "MicroMenu", 1 },
	{ "BagsBar", 1 },
	{ "CharacterFrame", 1 },
	{ "GameMenuFrame", 1 },
}

-- Frames whose anchoring state is worth reading directly.
local ANCHOR_PROBES = {
	"GameTooltip",
	"GameTooltip.widgetContainer",
	"WorldMapFrame",
	"ObjectiveTrackerFrame",
	"Minimap",
}

-- Keys this addon writes on purpose, on its own and on Blizzard frames, that
-- Blizzard never reads. Counted so the output is honest about what was left out.
local function IsOwnNoise(key)
	if type(key) ~= "string" then
		return false
	end
	return key:find("^[Kk][Kk][Uu][Ii]") ~= nil
		or key:find("^__[Kk][Kk][Uu][Ii]") ~= nil
		or key:find("^SLASH_KK") ~= nil
end

local stats

-- One level of a table. Reading a value taints this execution, which is fine,
-- since this runs from a slash command and never from Blizzard's own code.
local function Inspect(t, label, depth, seen, hits)
	if type(t) ~= "table" or seen[t] then
		return
	end
	seen[t] = true
	stats.tables = stats.tables + 1

	for key, value in pairs(t) do
		local keyType = type(key)
		if keyType == "string" or keyType == "number" then
			stats.keys = stats.keys + 1
			local ok, secure, by = pcall(issecurevariable, t, key)
			if ok and not secure and by == ADDON then
				if IsOwnNoise(key) then
					stats.noise = stats.noise + 1
				else
					local line = format("%s.%s (%s)", label, tostring(key), type(value))
					hits[line] = (hits[line] or 0) + 1
				end
			end
			if depth > 0 and keyType == "string" and type(value) == "table" then
				Inspect(value, label .. "." .. key, depth - 1, seen, hits)
			end
		end
	end
end

local function Resolve(path)
	local node = _G
	for part in path:gmatch("[^.]+") do
		if type(node) ~= "table" then
			return nil
		end
		node = node[part]
	end
	return node
end

-- Every global this addon defined or replaced. A replaced Blizzard function shows
-- up here by its Blizzard name.
local function ScanGlobals(hits)
	for name, value in pairs(_G) do
		if type(name) == "string" then
			stats.keys = stats.keys + 1
			local ok, secure, by = pcall(issecurevariable, _G, name)
			if ok and not secure and by == ADDON then
				if IsOwnNoise(name) then
					stats.noise = stats.noise + 1
				else
					local line = format("_G.%s (%s)", name, type(value))
					hits[line] = (hits[line] or 0) + 1
				end
			end
		end
	end
end

-- Map pins are acquired from pools, so they are not reachable by name. Walk the
-- pools the canvas keeps, the pins active in them, and the data providers.
local function ScanMap(hits, seen)
	local map = _G.WorldMapFrame
	if type(map) ~= "table" then
		return
	end

	if type(map.pinPools) == "table" then
		for template, pool in pairs(map.pinPools) do
			-- Labelled by template, not by pin, so identical findings across many
			-- pins collapse into one line with a count.
			local label = "pin[" .. tostring(template) .. "]"
			pcall(Inspect, pool, "pinPool[" .. tostring(template) .. "]", 1, seen, hits)
			if type(pool) == "table" and type(pool.EnumerateActive) == "function" then
				pcall(function()
					for pin in pool:EnumerateActive() do
						Inspect(pin, label, 0, seen, hits)
					end
				end)
			end
		end
	end

	if type(map.dataProviders) == "table" then
		for provider in pairs(map.dataProviders) do
			local name = "dataProvider"
			if type(provider) == "table" and type(provider.GetPinTemplate) == "function" then
				local ok, template = pcall(provider.GetPinTemplate, provider)
				if ok and template then
					name = "dataProvider[" .. tostring(template) .. "]"
				end
			end
			pcall(Inspect, provider, name, 0, seen, hits)
		end
	end
end

local function Flag(frame, method)
	if type(frame[method]) ~= "function" then
		return "n/a"
	end
	local ok, value = pcall(frame[method], frame)
	if not ok then
		return "error"
	end
	if issecretvalue and issecretvalue(value) then
		return "SECRET"
	end
	return tostring(value)
end

local function Describe(region)
	if type(region) ~= "table" then
		return tostring(region)
	end
	local ok, name = pcall(function()
		return region.GetName and region:GetName()
	end)
	if ok and name then
		return name
	end
	return "unnamed"
end

-- Anchoring is what makes GetStringHeight secret, so read it directly, and follow
-- the tooltip's anchors one hop to see what it is attached to.
local function ProbeAnchoring(out)
	out[#out + 1] = ""
	out[#out + 1] = "== Anchoring state =="
	for _, path in ipairs(ANCHOR_PROBES) do
		local frame = Resolve(path)
		if type(frame) == "table" and type(frame.GetNumPoints) == "function" then
			out[#out + 1] = format(
				"%-30s restricted=%s secret=%s points=%d",
				path,
				Flag(frame, "IsAnchoringRestricted"),
				Flag(frame, "IsAnchoringSecret"),
				frame:GetNumPoints()
			)
			if path == "GameTooltip" then
				for i = 1, frame:GetNumPoints() do
					local point, relativeTo, relativePoint = frame:GetPoint(i)
					out[#out + 1] = format(
						"    point %d: %s -> %s (%s) restricted=%s secret=%s",
						i,
						tostring(point),
						Describe(relativeTo),
						tostring(relativePoint),
						type(relativeTo) == "table" and Flag(relativeTo, "IsAnchoringRestricted") or "n/a",
						type(relativeTo) == "table" and Flag(relativeTo, "IsAnchoringSecret") or "n/a"
					)
				end
			end
		else
			out[#out + 1] = format("%-30s not present", path)
		end
	end
end

local function Setting(group, key)
	local table_ = C[group]
	if type(table_) ~= "table" then
		return "?"
	end
	return tostring(table_[key])
end

local function Scan(target)
	if not issecurevariable then
		K.Print(L["issecurevariable is not available on this client."])
		return
	end

	stats = { tables = 0, keys = 0, noise = 0 }
	local hits, seen, missing = {}, {}, {}

	if target and target ~= "" then
		local root = Resolve(target)
		if type(root) ~= "table" then
			K.Print(L["Nothing named '%s' to scan."], target)
			return
		end
		pcall(Inspect, root, target, 2, seen, hits)
	else
		pcall(ScanGlobals, hits)
		for _, entry in ipairs(ROOTS) do
			local root = Resolve(entry[1])
			if type(root) == "table" then
				pcall(Inspect, root, entry[1], entry[2], seen, hits)
			else
				missing[#missing + 1] = entry[1]
			end
		end
		pcall(ScanMap, hits, seen)
	end

	local lines = {}
	for line, count in pairs(hits) do
		lines[#lines + 1] = count > 1 and format("%s  x%d", line, count) or line
	end
	sort(lines)

	local out = {
		format("KkthnxUI %s build %s, game %s", K.Version, K.Build, K.TOCVersion or "?"),
		format(
			"Settings: Reveal=%s MoveFrames=%s Tooltip=%s TooltipCursorAnchor=%s ObjectiveTrackerSkin=%s Minimap=%s Nameplate=%s Unitframe=%s ActionBar=%s Auras=%s",
			Setting("WorldMap", "Reveal"),
			Setting("Misc", "MoveFrames"),
			Setting("Tooltip", "Enable"),
			Setting("Tooltip", "CursorAnchor"),
			Setting("Skins", "ObjectiveTracker"),
			Setting("Minimap", "Enable"),
			Setting("Nameplate", "Enable"),
			Setting("Unitframe", "Enable"),
			Setting("ActionBar", "Enable"),
			Setting("Auras", "Enable")
		),
		format(
			"Scanned %d tables and %d keys. %d keys tainted by %s need attention, %d more are our own KKUI fields that Blizzard never reads.",
			stats.tables,
			stats.keys,
			#lines,
			ADDON,
			stats.noise
		),
		"",
		"== Keys tainted by " .. ADDON .. " ==",
	}
	if #lines == 0 then
		out[#out + 1] = "(none)"
	end
	for i = 1, #lines do
		out[#out + 1] = lines[i]
	end

	if not target or target == "" then
		ProbeAnchoring(out)
		if #missing > 0 then
			sort(missing)
			out[#out + 1] = ""
			out[#out + 1] = "== Not present on this client =="
			out[#out + 1] = tconcat(missing, ", ")
		end
	end

	-- Kept on the stream too, so /kkdebug dump taint reads it back later.
	wipe(stream.lines)
	for i = 1, #out do
		stream.lines[i] = out[i]
	end

	K.ShowCopyText(L["Taint Scan"], tconcat(out, "\n"))
end

Debug.Command("taint", "List fields KkthnxUI has written into Blizzard tables", Scan)
