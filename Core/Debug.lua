--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Core/Debug.lua
	Purpose:
		A recorder any part of the addon can write to, so a bug that only shows up
		in play can be traced instead of guessed at.

		Work is split into named streams, each one off until it is switched on.
		Nothing is hooked, nothing is registered and nothing is allocated for a
		stream that is off, so leaving instrumentation in the code costs nothing
		on a normal session.

		Output is recorded, not printed. A zone change or a combat pull produces a
		burst that chat scroll would eat, so lines go into a ring buffer and come
		out through the copy window when asked for.

		Usage from a module:

			local stream = K.Debug.Register("chat", "Chat window geometry")
			stream:Log("something happened: %s", value)
			stream:Watch(ChatFrame1, "ChatFrame1")
			stream:Events({ "PLAYER_ENTERING_WORLD" })
			stream:Snapshot(ChatFrame1, "after load")

		In game:

			/kkdebug                  list the streams
			/kkdebug <name>           turn one on or off
			/kkdebug dump [name]      read what was recorded
			/kkdebug clear [name]
			/kkdebug watch <frame>    instrument any frame by name, on the fly
-----------------------------------------------------------------------------]]

local K, L = KkthnxUI[1], KkthnxUI[3]

local CreateFrame = CreateFrame
local debugstack = _G.debugstack
local format = string.format
local tconcat = table.concat
local tostring = tostring
local select = select
local pairs = pairs
local pcall = pcall
local ipairs = ipairs
local sort = table.sort
local tinsert = table.insert
local tremove = table.remove
local type = type
local wipe = wipe

-- Lines held per stream. Old lines are dropped rather than new ones, since the
-- end of a burst is usually the interesting part.
local MAX_LINES = 500

-- Every write that can move or resize a frame.
local GEOMETRY_METHODS = {
	"SetPoint",
	"SetAllPoints",
	"ClearAllPoints",
	"SetSize",
	"SetWidth",
	"SetHeight",
	"SetScale",
	"SetParent",
	"SetUserPlaced",
	"Show",
	"Hide",
}

local Debug = {}
K.Debug = Debug

local streams = {}
local streamMixin = {}

-- ---------------------------------------------------------------------------
-- Recording
-- ---------------------------------------------------------------------------

-- Several stack frames, not one. A post hook on a widget method starts in C, so
-- the first usable line is well up the stack, and taking only one gave nothing
-- but "[C]: in function 'SetPoint'".
local function Caller(depth)
	local stack = debugstack(depth or 4, 12, 0)
	if not stack then
		return "unknown"
	end
	local kept = {}
	for line in stack:gmatch("[^\n]+") do
		line = line:gsub("^%s+", ""):gsub("Interface/AddOns/", "")
		-- Our own plumbing and bare C entries say nothing about who called.
		if not line:find("Debug%.lua") and not line:find("^%[C%]") then
			kept[#kept + 1] = line
			if #kept >= 4 then
				break
			end
		end
	end
	if #kept == 0 then
		return "no lua frames, called from C"
	end
	return tconcat(kept, "\n      < ")
end

-- Frames print as a table address otherwise, which is unreadable in a log. A
-- named frame resolves, an unnamed one at least says it is a frame.
local function Describe(value)
	if type(value) == "table" then
		local ok, name = pcall(function()
			return value.GetName and value:GetName()
		end)
		if ok and name then
			return name
		end
		if pcall(function()
			return value.GetObjectType and value:GetObjectType()
		end) then
			return "unnamed:" .. tostring(value):sub(8)
		end
	end
	return tostring(value)
end

function streamMixin:Push(text)
	local lines = self.lines
	lines[#lines + 1] = format("%.3f  %s", GetTime(), text)
	-- Oldest line goes when the buffer is full. The end of a burst is usually the
	-- interesting part, so the front is what gets dropped.
	if #lines > MAX_LINES then
		tremove(lines, 1)
	end
end

function streamMixin:Log(fmt, ...)
	if not self.enabled then
		return
	end
	if select("#", ...) > 0 then
		self:Push(format(fmt, ...))
	else
		self:Push(fmt)
	end
end

-- Log with the calling line attached, for anything worth tracing back.
function streamMixin:Trace(fmt, ...)
	if not self.enabled then
		return
	end
	local text = select("#", ...) > 0 and format(fmt, ...) or fmt
	self:Push(text .. "\n      " .. Caller(3))
end

-- Where a frame actually is, resolved. This is what the player sees, as opposed
-- to what the anchors claim.
function streamMixin:Snapshot(frame, tag)
	if not self.enabled or not frame then
		return
	end

	-- Every point, not just the first. A frame with two anchors that disagree
	-- lands somewhere neither of them names on its own, and printing only point
	-- one hid exactly that.
	local count = frame:GetNumPoints()
	local anchors = {}
	for i = 1, count do
		local point, relativeTo, relativePoint, x, y = frame:GetPoint(i)
		anchors[i] = format(
			"%s->%s.%s(%.1f,%.1f)",
			tostring(point),
			Describe(relativeTo),
			tostring(relativePoint),
			x or 0,
			y or 0
		)
	end

	self:Push(format(
		"[%s] %s points=%d [%s] size=%.0fx%.0f left=%.0f bottom=%.0f scale=%.3f shown=%s parent=%s",
		tostring(tag),
		tostring(frame:GetName() or "unnamed"),
		count,
		tconcat(anchors, " | "),
		frame:GetWidth() or 0,
		frame:GetHeight() or 0,
		frame:GetLeft() or 0,
		frame:GetBottom() or 0,
		frame:GetEffectiveScale() or 0,
		tostring(frame:IsShown()),
		tostring(frame:GetParent() and frame:GetParent():GetName())
	))
end

-- Read the geometry one frame later. The layout engine resolves at the end of a
-- frame, so GetLeft straight after a SetPoint hands back the previous rect. Every
-- immediate reading is therefore one step behind, which is worse than useless
-- when the question is where a frame actually ended up.
local settleQueue = {}
local settleDriver

function streamMixin:SnapshotSettled(frame, tag)
	if not self.enabled or not frame then
		return
	end

	settleQueue[#settleQueue + 1] = { stream = self, frame = frame, tag = tag }

	if not settleDriver then
		settleDriver = CreateFrame("Frame")
	end
	settleDriver:SetScript("OnUpdate", function(driver)
		driver:SetScript("OnUpdate", nil)
		for i = 1, #settleQueue do
			local entry = settleQueue[i]
			entry.stream:Snapshot(entry.frame, entry.tag .. " SETTLED")
			settleQueue[i] = nil
		end
	end)
end

-- ---------------------------------------------------------------------------
-- Instrumentation
-- ---------------------------------------------------------------------------

-- Hook every geometry write on a frame and record the caller. Hooks go on once
-- and stay, so the enabled check inside each one is what makes a switched off
-- stream free rather than uninstalling anything.
function streamMixin:Watch(frame, label, methods)
	if not frame then
		return
	end
	self.watched = self.watched or {}
	if self.watched[frame] then
		return
	end
	self.watched[frame] = true

	label = label or frame:GetName() or "frame"

	for _, method in ipairs(methods or GEOMETRY_METHODS) do
		if frame[method] then
			hooksecurefunc(frame, method, function(_, ...)
				if not self.enabled then
					return
				end
				local args, count = {}, select("#", ...)
				for i = 1, count do
					args[i] = Describe((select(i, ...)))
				end
				self:Push(format(
					"%s:%s(%s) size=%.0fx%.0f points=%d\n      %s",
					label,
					method,
					tconcat(args, ", "),
					frame:GetWidth() or 0,
					frame:GetHeight() or 0,
					frame:GetNumPoints(),
					Caller(4)
				))
			end)
		end
	end
end

-- Hook a global function by name, so a write that happens somewhere we are not
-- watching still names the path that led to it.
function streamMixin:WatchGlobal(name)
	if type(_G[name]) ~= "function" then
		return
	end
	self.globals = self.globals or {}
	if self.globals[name] then
		return
	end
	self.globals[name] = true

	hooksecurefunc(name, function()
		if self.enabled then
			self:Push(name .. "()\n      " .. Caller(4))
		end
	end)
end

-- Hook a method on a table or frame, for mixins and Blizzard managers.
function streamMixin:WatchMethod(object, method, label)
	if not object or type(object[method]) ~= "function" then
		return
	end
	hooksecurefunc(object, method, function()
		if self.enabled then
			self:Push((label or method) .. "()\n      " .. Caller(4))
		end
	end)
end

-- Record when these events fire, optionally snapshotting a frame each time.
function streamMixin:Events(events, frame)
	self.watcher = self.watcher or CreateFrame("Frame")
	local watcher = self.watcher
	for _, event in ipairs(events) do
		watcher:RegisterEvent(event)
	end
	watcher:SetScript("OnEvent", function(_, event, ...)
		if not self.enabled then
			return
		end
		local first = ...
		self:Push(format("EVENT %s%s", event, first ~= nil and (" " .. tostring(first)) or ""))
		if frame then
			self:Snapshot(frame, event)
			self:SnapshotSettled(frame, event)
		end
	end)
end

-- ---------------------------------------------------------------------------
-- Streams
-- ---------------------------------------------------------------------------

-- Whether a stream was left on, kept outside the profile so a debug session is
-- never carried into an exported profile. Read straight off the saved variable
-- because streams register at file load, before the config is built.
local function Remembered(name)
	local db = _G.KkthnxUIDB
	return db and db.debugStreams and db.debugStreams[name] and true or false
end

local function Remember(name, enabled)
	local db = _G.KkthnxUIDB
	if not db then
		return
	end
	db.debugStreams = db.debugStreams or {}
	db.debugStreams[name] = enabled or nil
end

function Debug.Register(name, description)
	local stream = streams[name]
	if stream then
		return stream
	end
	stream = setmetatable({
		name = name,
		description = description or name,
		-- Survives a reload on purpose. The bugs worth recording often happen
		-- during load, and a flag that resets can never see them.
		enabled = Remembered(name),
		lines = {},
	}, { __index = streamMixin })
	streams[name] = stream
	return stream
end

function Debug.Get(name)
	return streams[name]
end

local function SortedNames()
	local names = {}
	for name in pairs(streams) do
		names[#names + 1] = name
	end
	sort(names)
	return names
end

local function List()
	local names = SortedNames()
	if #names == 0 then
		K.Print(L["No debug streams registered. Something failed to load."])
		return
	end
	K.Print(L["Debug streams:"])
	for _, name in ipairs(names) do
		local stream = streams[name]
		print(format(
			"  |cff%s%s|r  %s  |cff9EA7B5%s|r",
			stream.enabled and "4CD97B" or "737A87",
			name,
			stream.enabled and L["on"] or L["off"],
			stream.description
		))
	end
end

local function Dump(name)
	local pick = name and { name } or SortedNames()
	local out = {}
	for _, key in ipairs(pick) do
		local stream = streams[key]
		if stream and #stream.lines > 0 then
			out[#out + 1] = format("== %s (%d lines) ==", key, #stream.lines)
			for i = 1, #stream.lines do
				out[#out + 1] = stream.lines[i]
			end
			out[#out + 1] = ""
		end
	end
	if #out == 0 then
		K.Print(L["Nothing recorded. Turn a stream on, reproduce the problem, then dump."])
		return
	end
	-- Stamped so a pasted log says which build produced it.
	tinsert(out, 1, format("KkthnxUI %s build %s, game %s", K.Version, K.Build, K.TOCVersion or "?"))
	K.ShowCopyText(L["Debug Log"], tconcat(out, "\n"))
end

local function Clear(name)
	for _, key in ipairs(name and { name } or SortedNames()) do
		local stream = streams[key]
		if stream then
			wipe(stream.lines)
		end
	end
	K.Print(L["Debug log cleared."])
end

-- Instrument any frame by name without writing code for it first, which is what
-- makes this useful the moment something misbehaves.
local function WatchByName(frameName)
	local frame = _G[frameName]
	if not frame or type(frame.GetObjectType) ~= "function" then
		K.Print(L["No frame named '%s'."], frameName)
		return
	end
	local stream = Debug.Register("adhoc", L["Frames watched from the command line"])
	stream.enabled = true
	stream:Watch(frame, frameName)
	stream:Snapshot(frame, "watch start")
	K.Print(L["Watching %s. Reproduce it, then /kkdebug dump adhoc."], frameName)
end

function Debug.Toggle(name)
	local stream = name and streams[name]
	if not stream then
		K.Print(L["No debug stream named '%s'."], tostring(name))
		List()
		return
	end
	stream.enabled = not stream.enabled
	Remember(name, stream.enabled)
	if stream.enabled then
		wipe(stream.lines)
		K.Print(L["Debug stream '%s' is on and stays on through a reload. Reproduce it, then /kkdebug dump %s."], name, name)
	else
		K.Print(L["Debug stream '%s' is off. %d lines held, /kkdebug dump %s to read them."], name, #stream.lines, name)
	end
end

-- Saved variables do not exist yet while these files are executing, so the
-- remembered flags are applied once the game hands them over. Hooks are already
-- installed by then and gate themselves on the flag, so nothing is missed.
local loader = CreateFrame("Frame")
loader:RegisterEvent("ADDON_LOADED")
loader:SetScript("OnEvent", function(self, _, addon)
	if addon ~= "KkthnxUI" then
		return
	end
	self:UnregisterAllEvents()

	local db = _G.KkthnxUIDB
	local saved = db and db.debugStreams
	if not saved then
		return
	end
	local live = {}
	for name, on in pairs(saved) do
		local stream = streams[name]
		if stream and on then
			stream.enabled = true
			live[#live + 1] = name
		end
	end
	if #live > 0 then
		sort(live)
		K.Print(L["Debug recording: %s. /kkdebug dump to read, /kkdebug <name> to stop."], tconcat(live, ", "))
	end
end)

_G.SLASH_KKUI_DEBUG1 = "/kkdebug"
_G.SLASH_KKUI_DEBUG2 = "/kkd"
_G.SlashCmdList.KKUI_DEBUG = function(input)
	input = input or ""
	-- Split on the first run of whitespace rather than matching the whole line. A
	-- whole line pattern returns nil for anything with a third word, and the nil
	-- then blew up in format further down instead of saying anything.
	local command = input:match("^%s*(%S+)") or ""
	local rest = input:match("^%s*%S+%s+(.+)$")
	local argument = rest and rest:match("^(%S+)") or nil

	command = command:lower()

	if command == "" or command == "help" then
		List()
	elseif command == "dump" then
		Dump(argument and argument:lower() or nil)
	elseif command == "clear" then
		Clear(argument and argument:lower() or nil)
	elseif command == "watch" then
		if not argument then
			K.Print(L["Usage: /kkdebug watch <frame name>"])
		else
			-- Frame names are case sensitive, so this one keeps the raw text.
			WatchByName(argument)
		end
	else
		Debug.Toggle(command)
	end
end
