local K, C, L = unpack(select(2, ...))
if K.CheckAddOnState("Speedyload") then return end

-- Sourced: Cybeloras (Cybeloras)

local _G = _G
local ipairs = ipairs
local next = next
local select = select
local table_wipe = table.wipe

local CreateFrame = _G.CreateFrame
local geterrorhandler = _G.geterrorhandler
local GetFramesRegisteredForEvent = _G.GetFramesRegisteredForEvent
local getmetatable = _G.getmetatable
local hooksecurefunc = _G.hooksecurefunc
local issecurevariable = _G.issecurevariable
local WorldStateAlwaysUpFrame = _G.WorldStateAlwaysUpFrame

local enteredOnce, listenForUnreg
local occured = {}
local events = {
	SPELLS_CHANGED = {},
	USE_GLYPH = {},
	PET_TALENT_UPDATE = {},
	PLAYER_TALENT_UPDATE = {},
	WORLD_MAP_UPDATE = {},
	UPDATE_WORLD_STATES = {},
	CRITERIA_UPDATE = {},
	RECEIVED_ACHIEVEMENT_LIST = {},
	ACTIONBAR_SLOT_CHANGED = {},
	SPELL_UPDATE_USABLE = {},
	UPDATE_FACTION = {},
	MAP_BAR_UPDATE = {},
}

local frameBlacklist = {
	[WorldStateAlwaysUpFrame] = true
}

local function canMod(frame)
	if frameBlacklist[frame] then
		return false
	end

	local name = frame:GetName()

	if not name then
		-- As a rule of thumb, Blizzard doesn't create anonymous frames
		-- so it should always be safe to modify them.
		return true
	end

	local isSecure = issecurevariable(name)

	if isSecure then
		frameBlacklist[frame] = true
		return false
	end

	return true
end

-- our PLAYER_ENTERING_WORLD handler needs to be absolutely the very first one that gets fired.
local f
do
	local t = {GetFramesRegisteredForEvent("PLAYER_ENTERING_WORLD")}
	for i, frame in ipairs(t) do
		if canMod(frame) then
			frame:UnregisterEvent("PLAYER_ENTERING_WORLD")
		end
	end

	f = CreateFrame("Frame")
	f:RegisterEvent("PLAYER_ENTERING_WORLD")

	for i, frame in ipairs(t) do
		if canMod(frame) then
			frame:RegisterEvent("PLAYER_ENTERING_WORLD")
		end
	end
	table_wipe(t)
end

local validUnregisterFuncs = {
	[f.UnregisterEvent] = true, -- might as well add this since we already have the frame
}
local function isUnregisterFuncValid(table, func)
	if not func then
		return false
	end
	local isValid = issecurevariable(table, "UnregisterEvent")
	if not validUnregisterFuncs[func] then
		validUnregisterFuncs[func] = not not isValid
	end
	return isValid
end

local function unregister(event, ...)
	for i = 1, select("#", ...) do
		local frame = select(i, ...)
		local UnregisterEvent = frame.UnregisterEvent
		if canMod(frame) and (validUnregisterFuncs[UnregisterEvent] or isUnregisterFuncValid(frame, UnregisterEvent)) then
			UnregisterEvent(frame, event)
			events[event][frame] = 1
		end
	end
end

if PetStableFrame then
	-- just do this outright. Probably the most pointless event registration in history.
	PetStableFrame:UnregisterEvent("SPELLS_CHANGED")
end

f:SetScript("OnEvent", function(self, gameEvent)
	if gameEvent == "PLAYER_ENTERING_WORLD" then
		if not enteredOnce then
			f:RegisterEvent("PLAYER_LEAVING_WORLD")

			hooksecurefunc(getmetatable(f).__index, "UnregisterEvent", function(frame, event)
				if listenForUnreg then
					local frames = events[event]
					if frames then
						frames[frame] = nil
					end
				end
			end)
			enteredOnce = 1
		else
			listenForUnreg = nil
			for event, frames in next, events do
				for frame in next, frames do
					frame:RegisterEvent(event)
					local OnEvent = occured[event] and frame:GetScript("OnEvent")
					if OnEvent then
						local arg1
						if event == "ACTIONBAR_SLOT_CHANGED" then
							arg1 = 0
						end
						local success, err = _G.pcall(OnEvent, frame, event, arg1)
						if not success then
							geterrorhandler()(err, 1)
						end
					end
					frames[frame] = nil
				end
			end
			table_wipe(occured)
		end
	elseif gameEvent == "PLAYER_LEAVING_WORLD" then
		table_wipe(occured)
		for event in next, events do
			unregister(event, _G.GetFramesRegisteredForEvent(event))
			f:RegisterEvent(event) -- must register on f >AFTER< unregistering everything (duh?)
		end
		listenForUnreg = 1
	else
		occured[gameEvent] = 1
		f:UnregisterEvent(gameEvent)
	end
end)