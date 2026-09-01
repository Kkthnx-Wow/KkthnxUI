--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	Author: Josh "Kkthnx" Russell
	File: Core/Engine.lua
	Purpose:
		Boot the shared namespace and the module framework.
		K is the engine table, C is the config table, L is the locale table.
		Modules register through K:NewModule and receive a lightweight event
		dispatcher so no module needs its own hand rolled event frame.
-----------------------------------------------------------------------------]]

local AddOnName, Engine = ...

-- Shared namespace. Every file pulls these out with:
--   local K, C, L = unpack(KkthnxUI)
local K = {}
local C = {}
local L = {}

Engine[1] = K
Engine[2] = C
Engine[3] = L

K.Title = AddOnName
K.Version = C_AddOns.GetAddOnMetadata(AddOnName, "Version") or "dev"

-- Build tag for tracking day to day changes while the public Version stays put.
-- Bump this every time you push a change so a bug report can be pinned to an exact
-- build. Format is YYYY.MM.DD.N, N being the build number for that day.
K.Build = "2026.09.01.2"

-- oUF embeds itself onto our shared addon namespace, so it is reachable here
-- because every file in the addon receives the same private table.
K.oUF = Engine.oUF

_G.KkthnxUI = Engine

-- ---------------------------------------------------------------------------
-- Local caching
-- ---------------------------------------------------------------------------

local pairs = pairs
local type = type
local next = next
local tinsert = table.insert
local xpcall = xpcall
local geterrorhandler = geterrorhandler
local CreateFrame = CreateFrame

-- ---------------------------------------------------------------------------
-- Client / flavor detection
-- ---------------------------------------------------------------------------

local project = WOW_PROJECT_ID
K.Client = {
	IsRetail = project == (WOW_PROJECT_MAINLINE or 1),
	IsClassic = project == WOW_PROJECT_CLASSIC,
	IsCata = project == (WOW_PROJECT_CATACLYSM_CLASSIC or -1),
	IsMists = project == (WOW_PROJECT_MISTS_CLASSIC or -1),
}

local wowVersion, wowBuild, _, wowTOC = GetBuildInfo()
K.WoWVersion = wowVersion
K.WoWBuild = wowBuild
K.TOCVersion = wowTOC

-- ---------------------------------------------------------------------------
-- Safe call helper (never let one module break the chain)
-- ---------------------------------------------------------------------------

local function errorHandler(err)
	return geterrorhandler()(err)
end

local function safeCall(func, ...)
	if type(func) == "function" then
		return xpcall(func, errorHandler, ...)
	end
end
K.SafeCall = safeCall

-- ---------------------------------------------------------------------------
-- Module framework
-- ---------------------------------------------------------------------------
-- A module is a plain table with an OnEnable method. Modules can also declare
-- an OnInitialize method that runs once SavedVariables are ready. Each module
-- gets RegisterEvent / UnregisterEvent mixed in, backed by a single shared
-- dispatch frame that fans events out to the modules that asked for them.

local modules = {}        -- name -> module table
local moduleOrder = {}    -- ordered list for deterministic enable order
local moduleMixin = {}    -- shared methods mixed into every module

-- Shared event dispatch frame. One frame, one OnEvent, keyed by event then
-- module so registration and dispatch stay O(1) per handler.
local dispatch = CreateFrame("Frame")
local eventMap = {}       -- event -> { [module] = handler }

dispatch:SetScript("OnEvent", function(_, event, ...)
	local handlers = eventMap[event]
	if not handlers then
		return
	end
	for module, handler in pairs(handlers) do
		if handler == true then
			-- No explicit handler: call self[event](self, event, ...)
			local fn = module[event]
			if fn then
				fn(module, event, ...)
			end
		elseif type(handler) == "string" then
			local fn = module[handler]
			if fn then
				fn(module, event, ...)
			end
		else
			handler(module, event, ...)
		end
	end
end)

-- module:RegisterEvent("EVENT", handler)
--   handler may be a function, a method name string, or nil (uses self.EVENT).
function moduleMixin:RegisterEvent(event, handler)
	local handlers = eventMap[event]
	if not handlers then
		handlers = {}
		eventMap[event] = handlers
		dispatch:RegisterEvent(event)
	end
	handlers[self] = handler or true
end

function moduleMixin:UnregisterEvent(event)
	local handlers = eventMap[event]
	if not handlers then
		return
	end
	handlers[self] = nil
	if not next(handlers) then
		eventMap[event] = nil
		dispatch:UnregisterEvent(event)
	end
end

function moduleMixin:UnregisterAllEvents()
	for event, handlers in pairs(eventMap) do
		if handlers[self] then
			handlers[self] = nil
			if not next(handlers) then
				eventMap[event] = nil
				dispatch:UnregisterEvent(event)
			end
		end
	end
end

-- Register a one-shot event that unregisters itself after the first fire.
function moduleMixin:RegisterEventOnce(event, handler)
	self:RegisterEvent(event, function(mod, evt, ...)
		mod:UnregisterEvent(evt)
		if type(handler) == "string" then
			local fn = mod[handler]
			if fn then
				fn(mod, evt, ...)
			end
		elseif handler then
			handler(mod, evt, ...)
		else
			local fn = mod[evt]
			if fn then
				fn(mod, evt, ...)
			end
		end
	end)
end

-- Create or fetch a module by name.
function K:NewModule(name)
	if modules[name] then
		return modules[name]
	end
	local module = setmetatable({ moduleName = name, enabledState = true }, { __index = moduleMixin })
	modules[name] = module
	tinsert(moduleOrder, module)
	return module
end

function K:GetModule(name, silent)
	local module = modules[name]
	if not module and not silent then
		error("K:GetModule: module '" .. tostring(name) .. "' does not exist.", 2)
	end
	return module
end

-- ---------------------------------------------------------------------------
-- Lifecycle driver
-- ---------------------------------------------------------------------------
-- OnInitialize runs on our ADDON_LOADED (SavedVariables ready).
-- OnEnable runs on PLAYER_LOGIN (game data ready), in registration order.

local initialized = false

local function InitializeModules()
	if initialized then
		return
	end
	initialized = true
	if K.SetupConfig then
		K:SetupConfig()
	end
	for _, module in pairs(modules) do
		if module.OnInitialize then
			safeCall(module.OnInitialize, module)
		end
	end
end

local function EnableModules()
	for _, module in ipairs(moduleOrder) do
		if module.enabledState and not module.__enabled and module.OnEnable then
			module.__enabled = true
			safeCall(module.OnEnable, module)
		end
	end
end

local boot = CreateFrame("Frame")
boot:RegisterEvent("ADDON_LOADED")
boot:RegisterEvent("PLAYER_LOGIN")
boot:SetScript("OnEvent", function(self, event, arg1)
	if event == "ADDON_LOADED" then
		if arg1 == AddOnName then
			self:UnregisterEvent("ADDON_LOADED")
			InitializeModules()
		end
	elseif event == "PLAYER_LOGIN" then
		self:UnregisterEvent("PLAYER_LOGIN")
		InitializeModules()
		EnableModules()
	end
end)
