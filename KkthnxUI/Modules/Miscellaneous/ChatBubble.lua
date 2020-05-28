local K, C = unpack(select(2, ...))
local Module = K:GetModule("Miscellaneous")

-- Lua API
local _G = _G

local math_floor = _G.math.floor
local pairs = _G.pairs
local select = _G.select

-- WoW API
local C_ChatBubbles_GetAllChatBubbles = _G.C_ChatBubbles.GetAllChatBubbles
local CreateFrame = _G.CreateFrame
local InCombatLockdown = _G.InCombatLockdown
local IsInInstance = _G.IsInInstance

-- Textures
local BLANK_TEXTURE = C["Media"].Blank
local TOOLTIP_BORDER = C["Media"].Glow

-- Bubble Data
Module.customBubbles = {} -- local bubble registry
Module.numChildren = -1 -- worldframe children
Module.numBubbles = 0 -- worldframe customBubbles
Module.hooks = {}

local Hooks = Module.hooks

-- Syntax check
local check = function(value, num, ...)
	assert(type(num) == "number", ("Bad argument #%.0f to '%s': %s expected, got %s"):format(2, "Check", "number", type(num)))
	for i = 1,select("#", ...) do
		if type(value) == select(i, ...) then
			return
		end
	end
	local types = string.join(", ", ...)
	local name = string.match(debugstack(2, 2, 0), ": in function [`<](.-)['>]")
	error(("Bad argument #%.0f to '%s': %s expected, got %s"):format(num, name, types, type(value)), 3)
end

-- @input
-- frameHandle, scriptHandler, hook[, uniqueID]
function Module:ClearHook(frame, handler, hook, uniqueID)
	check(frame, 1, "table")
	check(handler, 2, "string")
	check(hook, 3, "function", "string")

	if (not Hooks[frame]) or (not Hooks[frame][handler]) then
		return
	end

	local hookList = Hooks[frame][handler]

	if uniqueID then
		hookList.unique[uniqueID] = nil
	else
		for id = #hookList.list,1,-1 do
			local func = hookList.list[id]
			if (func == hook) then
				table.remove(hookList.list, id)
			end
		end
	end
end

-- @input
-- frameHandle, scriptHandler, hook[, uniqueID]
function Module:SetHook(frame, handler, hook, uniqueID)
	check(frame, 1, "table")
	check(handler, 2, "string")
	check(hook, 3, "function", "string")
	check(uniqueID, 4, "string", "nil")

	-- If the hook is a method, we need a uniqueID for our module reference list!
	if (type(hook) == "string") then

		-- Let's make this backwards compatible and just make up an ID when it's not provided(?)
		if (not uniqueID) then
			uniqueID = (self:GetName()).."_"..hook
		end

		-- Reference the module
		Module[uniqueID] = self
	end

	if (not Hooks[frame]) then
		Hooks[frame] = {}
	end

	if (not Hooks[frame][handler]) then
		Hooks[frame][handler] = { list = {}, unique = {} }

		-- We only need a single handler
		-- Problem discovered in 8.2.0:
		-- The 'self' here will only refer to the first module
		-- that registered a hook for this frame and script handler.
		-- Meaning unless we track each registration's module,
		-- we'll get a nil error or weird bug by usind the wrong 'self'!
		local hookList = Hooks[frame][handler]
		frame:HookScript(handler, function(...)
			for id,func in pairs(hookList.unique) do
				if (type(func) == "string") then
					local module = Module[id]
					if (module) then
						module[func](module, id, ...)
					end
				else
					-- We allow unique hooks to just run a function
					-- without passing the self.
					func(...)
				end
			end

			-- This only ever occurs when the hook is a function,
			-- and no uniqueID is given.
			for _,func in ipairs(hookList.list) do
				func(...)
			end
		end)
	end

	local hookList = Hooks[frame][handler]

	if uniqueID then
		hookList.unique[uniqueID] = hook
	else
		local exists
		for _,func in ipairs(hookList.list) do
			if (func == hook) then
				exists = true
				break
			end
		end

		if (not exists) then
			table.insert(hookList.list, hook)
		end
	end
end

-- Custom Bubble parent frame
Module.BubbleBox = CreateFrame("Frame", nil, UIParent)
Module.BubbleBox:SetAllPoints()
Module.BubbleBox:Hide()

-- Update frame
Module.BubbleUpdater = CreateFrame("Frame", nil, WorldFrame)
Module.BubbleUpdater:SetFrameStrata("TOOLTIP")

local customBubbles = Module.customBubbles
local bubbleBox = Module.BubbleBox
local bubbleUpdater = Module.BubbleUpdater

local fontsize = 12 -- bubble font size

local function getPadding()
	return fontsize / 1.2
end

-- let the bubble size scale from 400 to 660ish (font size 22)
local function getMaxWidth()
	return 400 + math_floor((fontsize - 12) / 22 * 260)
end

local function getBackdrop(scale)
	return {
		bgFile = BLANK_TEXTURE,
		edgeFile = TOOLTIP_BORDER,
		edgeSize = 4 * scale,
		insets = {
			left = 4 * scale,
			right = 4 * scale,
			top = 4 * scale,
			bottom = 4 * scale
		}
	}
end

local function OnUpdate()
	-- Reference:
	--	bubble, customBubble.blizzardText = original bubble and message
	--	customBubbles[bubble], customBubbles[bubble].text = our custom bubble and message
	for _, bubble in pairs(C_ChatBubbles_GetAllChatBubbles()) do
		if (not customBubbles[bubble]) then
			Module:SetupBubble(bubble)
		end

		local customBubble = customBubbles[bubble]
		if bubble:IsShown() then
			-- continuing the fight against overlaps blending into each other!
			customBubbles[bubble]:SetFrameLevel(bubble:GetFrameLevel()) -- this works?

			local blizzTextWidth = math_floor(customBubble.blizzardText:GetWidth())
			local blizzTextHeight = math_floor(customBubble.blizzardText:GetHeight())
			local point, _, rpoint, blizzX, blizzY = customBubble.blizzardText:GetPoint()
			local r, g, b = customBubble.blizzardText:GetTextColor()
			customBubbles[bubble].color[1] = r
			customBubbles[bubble].color[2] = g
			customBubbles[bubble].color[3] = b

			if blizzTextWidth and blizzTextHeight and point and rpoint and blizzX and blizzY then
				if not customBubbles[bubble]:IsShown() then
					customBubbles[bubble]:Show()
				end

				local msg = customBubble.blizzardText:GetText()
				if msg and (customBubbles[bubble].last ~= msg) then
					customBubbles[bubble].text:SetText(msg or "")
					customBubbles[bubble].text:SetTextColor(r, g, b)
					customBubbles[bubble].last = msg

					local sWidth = customBubbles[bubble].text:GetStringWidth()
					local maxWidth = getMaxWidth()
					if sWidth > maxWidth then
						customBubbles[bubble].text:SetWidth(maxWidth)
					else
						customBubbles[bubble].text:SetWidth(sWidth)
					end
				end

				local space = getPadding()
				local ourTextWidth = customBubbles[bubble].text:GetWidth()
				local ourTextHeight = customBubbles[bubble].text:GetHeight()

				-- chatbubbles are rendered at BOTTOM, WorldFrame, BOTTOMLEFT, x, y
				local ourWidth = math_floor(ourTextWidth + space * 2)
				local ourHeight = math_floor(ourTextHeight + space * 2)

				-- hide while sizing and moving, to gain fps
				customBubbles[bubble]:Hide()
				customBubbles[bubble]:SetSize(ourWidth, ourHeight)
				customBubbles[bubble]:SetBackdropColor(0.04, 0.04, 0.04, 0.6)
				customBubbles[bubble]:SetBackdropBorderColor(0, 0, 0, 0.8)

				-- show the bubble again
				customBubbles[bubble]:Show()
			end

			customBubble.blizzardText:SetAlpha(0)
		else
			if customBubbles[bubble]:IsShown() then
				customBubbles[bubble]:Hide()
			else
				customBubbles[bubble].last = nil -- to avoid repeated messages not being shown
			end
		end
	end

	for bubble in pairs(customBubbles) do
		if (not bubble:IsShown()) and (customBubbles[bubble]:IsShown()) then
			customBubbles[bubble]:Hide()
		end
	end
end

function Module:DisableBlizzard(bubble)
	local customBubble = customBubbles[bubble]

	-- Grab the original bubble's text color
	customBubble.blizzardColor[1],
	customBubble.blizzardColor[2],
	customBubble.blizzardColor[3] = customBubble.blizzardText:GetTextColor()

	-- Make the original blizzard text transparent
	customBubble.blizzardText:SetAlpha(0)

	-- Remove all the default textures
	for region, _ in pairs(customBubbles[bubble].blizzardRegions) do
		region:SetTexture(nil)
		region:SetAlpha(0)
	end
end

function Module:EnableBlizzard(bubble)
	local customBubble = customBubbles[bubble]

	-- Restore the original text color
	customBubble.blizzardText:SetTextColor(customBubble.blizzardColor[1], customBubble.blizzardColor[2], customBubble.blizzardColor[3], 1)

	-- Restore all the original textures
	for region, texture in pairs(customBubbles[bubble].blizzardRegions) do
		region:SetTexture(texture)
		region:SetAlpha(1)
	end
end

function Module:SetupBubble(bubble)
	Module.numBubbles = Module.numBubbles + 1

	local customBubble = CreateFrame("Frame", nil, bubbleBox)
	customBubble:Hide()
	customBubble:SetFrameStrata("BACKGROUND")
	customBubble:SetFrameLevel(Module.numBubbles % 128 + 1) -- try to avoid overlapping bubbles blending into each other
	customBubble:SetBackdrop(getBackdrop(0.75))
	customBubble:SetPoint("BOTTOM", bubble, "BOTTOM", 0, 0)

	customBubble.blizzardRegions = {}
	customBubble.blizzardColor = {1, 1, 1, 1}
	customBubble.color = {1, 1, 1, 1}

	customBubble.text = customBubble:CreateFontString()
	customBubble.text:SetPoint("BOTTOMLEFT", 10, 10)
	customBubble.text:SetFontObject(K.GetFont(C["UIFonts"].SkinFonts))

	for i = 1, bubble:GetNumRegions() do
		local region = select(i, bubble:GetRegions())
		if (region:GetObjectType() == "Texture") then
			customBubble.blizzardRegions[region] = region:GetTexture()
		elseif (region:GetObjectType() == "FontString") then
			customBubble.blizzardText = region
		end
	end

	customBubbles[bubble] = customBubble

	-- Only disable the Blizzard bubble outside of instances,
	-- and only when any cinematics aren't playing.
	local _, instanceType = IsInInstance()
	if (instanceType == "none") then
		Module:DisableBlizzard(bubble)
	end
end

function Module:UpdateBubbleVisibility()
	local _, instanceType = IsInInstance()
	if (instanceType == "none") then
		-- Start our updater, this will show our bubbles.
		bubbleUpdater:SetScript("OnUpdate", OnUpdate)
		bubbleBox:Show()

		-- Manually disable the blizzard bubbles
		for bubble in pairs(customBubbles) do
			Module:DisableBlizzard(bubble)
		end
	else
		-- Stop our updater
		bubbleUpdater:SetScript("OnUpdate", nil)
		bubbleBox:Hide()

		-- Enable the Blizzard bubbles
		for bubble in pairs(customBubbles) do
			Module:EnableBlizzard(bubble)

			-- We need to manually hide ours
			customBubbles[bubble]:Hide()
		end
	end
end

function Module:CreateChatBubbles()
	if C["Skins"].ChatBubbles then
		Module.stylingEnabled = true
		K:RegisterEvent("PLAYER_ENTERING_WORLD", Module.OnBubbleEvent)
		K:RegisterEvent("PLAYER_REGEN_DISABLED", Module.OnBubbleEvent)
		K:RegisterEvent("PLAYER_REGEN_ENABLED", Module.OnBubbleEvent)
		Module:OnBubbleEvent("PLAYER_ENTERING_WORLD")
	else
		Module.stylingEnabled = nil
		K:UnregisterEvent("PLAYER_ENTERING_WORLD", Module.OnBubbleEvent)
		K:UnregisterEvent("PLAYER_REGEN_DISABLED", Module.OnBubbleEvent)
		K:UnregisterEvent("PLAYER_REGEN_ENABLED", Module.OnBubbleEvent)
		Module:OnBubbleEvent("PLAYER_ENTERING_WORLD")
	end
end

function Module:GetAllChatBubbles()
	return pairs(C_ChatBubbles_GetAllChatBubbles())
end

function Module:OnBubbleEvent(event)
	if (event == "PLAYER_ENTERING_WORLD") then
		-- Don't ever do any of this while in combat.
		-- This should never happen, we're just being overly safe here.
		if InCombatLockdown() then
			return K:RegisterEvent("PLAYER_REGEN_ENABLED", Module.OnBubbleEvent)
		end

		if Module.stylingEnabled then
			local _, instanceType = IsInInstance()
			if (instanceType == "none") then
				if UnitAffectingCombat("player") then
					SetCVar("chatBubbles", 0)
				else
					SetCVar("chatBubbles", 1)
				end
				--SetCVar("chatBubbles", 1)
			else
				if UnitAffectingCombat("player") then
					SetCVar("chatBubbles", 0)
				else
					SetCVar("chatBubbles", 1)
				end
				--SetCVar("chatBubbles", 0)
			end

			Module:SetHook(UIParent, "OnHide", Module.UpdateBubbleVisibility, "CG_UIPARENT_ONHIDE_BUBBLEUPDATE")
			Module:SetHook(UIParent, "OnShow", Module.UpdateBubbleVisibility, "CG_UIPARENT_ONSHOW_BUBBLEUPDATE")
			Module:SetHook(CinematicFrame, "OnHide", Module.UpdateBubbleVisibility, "CG_CINEMATICFRAME_ONHIDE_BUBBLEUPDATE")
			Module:SetHook(CinematicFrame, "OnShow", Module.UpdateBubbleVisibility, "CG_CINEMATICFRAME_ONSHOW_BUBBLEUPDATE")
			Module:SetHook(MovieFrame, "OnHide", Module.UpdateBubbleVisibility, "CG_MOVIEFRAME_ONHIDE_BUBBLEUPDATE")
			Module:SetHook(MovieFrame, "OnShow", Module.UpdateBubbleVisibility, "CG_MOVIEFRAME_ONSHOW_BUBBLEUPDATE")
		else
			Module:ClearHook(UIParent, "OnHide", Module.UpdateBubbleVisibility, "CG_UIPARENT_ONHIDE_BUBBLEUPDATE")
			Module:ClearHook(UIParent, "OnShow", Module.UpdateBubbleVisibility, "CG_UIPARENT_ONSHOW_BUBBLEUPDATE")
			Module:ClearHook(CinematicFrame, "OnHide", Module.UpdateBubbleVisibility, "CG_CINEMATICFRAME_ONHIDE_BUBBLEUPDATE")
			Module:ClearHook(CinematicFrame, "OnShow", Module.UpdateBubbleVisibility, "CG_CINEMATICFRAME_ONSHOW_BUBBLEUPDATE")
			Module:ClearHook(MovieFrame, "OnHide", Module.UpdateBubbleVisibility, "CG_MOVIEFRAME_ONHIDE_BUBBLEUPDATE")
			Module:ClearHook(MovieFrame, "OnShow", Module.UpdateBubbleVisibility, "CG_MOVIEFRAME_ONSHOW_BUBBLEUPDATE")
		end

		Module:UpdateBubbleVisibility()
	elseif (event == "PLAYER_REGEN_ENABLED") then
		return Module:OnBubbleEvent("PLAYER_ENTERING_WORLD")
	elseif (event == "PLAYER_REGEN_DISABLED") then
		return Module:OnBubbleEvent("PLAYER_ENTERING_WORLD")
	end
end