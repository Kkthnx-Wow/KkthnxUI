--[[-----------------------------------------------------------------------------
-- Internal signal bus (NexEnhance/Plumber pattern). WoW events use K:RegisterEvent;
-- cross-module reactions use K:RegisterCallback("SettingChanged.Section.Key", ...).
-----------------------------------------------------------------------------]]

local K = KkthnxUI[1]

local type = type
local format = string.format
local sub = string.sub

local signalCallbacks = {}
local prefixCallbacks = {}

function K:RegisterCallback(signal, callback, owner)
	local list = signalCallbacks[signal]
	if not list then
		list = {}
		signalCallbacks[signal] = list
	end
	list[#list + 1] = { callback, owner, type(callback) == "string" }
	return callback
end

function K:TriggerCallback(signal, ...)
	local list = signalCallbacks[signal]
	if not list then
		return
	end

	for i = 1, #list do
		local cb = list[i]
		if cb then
			if cb[3] then
				cb[2][cb[1]](cb[2], ...)
			elseif cb[2] then
				cb[1](cb[2], ...)
			else
				cb[1](...)
			end
		end
	end
end

function K:UnregisterCallback(signal, callback, owner)
	local list = signalCallbacks[signal]
	if not list then
		return
	end

	local anyLive = false
	for i = 1, #list do
		local cb = list[i]
		if cb and cb[1] == callback and cb[2] == owner then
			list[i] = false
		elseif cb then
			anyLive = true
		end
	end

	if not anyLive then
		signalCallbacks[signal] = nil
	end
end

--- Convenience: subscribe to a GUI config path change (`SettingChanged.<configPath>`).
function K:RegisterSettingCallback(configPath, callback, owner)
	return K:RegisterCallback(format("SettingChanged.%s", configPath), callback, owner)
end

--- Subscribe to any config path that starts with `prefix` (e.g. `"Nameplate."`).
--- Callback receives `(configPath, newValue, oldValue)` after optional `owner`.
function K:RegisterSettingPrefixCallback(prefix, callback, owner)
	prefixCallbacks[#prefixCallbacks + 1] = { prefix, callback, owner, type(callback) == "string" }
	return callback
end

function K:TriggerSettingCallback(configPath, newValue, oldValue)
	K:TriggerCallback(format("SettingChanged.%s", configPath), newValue, oldValue)

	for i = 1, #prefixCallbacks do
		local entry = prefixCallbacks[i]
		local prefix = entry[1]
		if sub(configPath, 1, #prefix) == prefix then
			if entry[4] then
				entry[3][entry[2]](entry[3], configPath, newValue, oldValue)
			elseif entry[3] then
				entry[2](entry[3], configPath, newValue, oldValue)
			else
				entry[2](configPath, newValue, oldValue)
			end
		end
	end
end

--- True when a setting has a live update path (exact or prefix callback).
function K:HasSettingLiveUpdate(configPath)
	local exactSignal = format("SettingChanged.%s", configPath)
	local list = signalCallbacks[exactSignal]
	if list then
		for i = 1, #list do
			if list[i] then
				return true
			end
		end
	end

	for i = 1, #prefixCallbacks do
		local prefix = prefixCallbacks[i][1]
		if sub(configPath, 1, #prefix) == prefix then
			return true
		end
	end

	return false
end
