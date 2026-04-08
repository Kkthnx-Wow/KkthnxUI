--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Displays system performance metrics including FPS, memory usage, and CPU usage per addon.
-- - Design: Throttled OnUpdate that toggles between memory and CPU profiling via user interaction.
-- - Events: N/A (OnUpdate and Script driven)
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("DataText")

-- PERF: Localize globals and API functions to minimize lookup overhead.
local _G = _G
local C_AddOns_GetAddOnInfo = _G.C_AddOns.GetAddOnInfo
local C_AddOns_GetNumAddOns = _G.C_AddOns.GetNumAddOns
local C_AddOns_IsAddOnLoaded = _G.C_AddOns.IsAddOnLoaded
local CreateFrame = _G.CreateFrame
local GameTooltip = _G.GameTooltip
local GetAddOnCPUUsage = _G.GetAddOnCPUUsage
local GetAddOnMemoryUsage = _G.GetAddOnMemoryUsage
local GetCVarBool = _G.GetCVarBool
local GetFramerate = _G.GetFramerate
local GetTime = _G.GetTime
local IsShiftKeyDown = _G.IsShiftKeyDown
local ReloadUI = _G.ReloadUI
local ResetCPUUsage = _G.ResetCPUUsage
local SetCVar = _G.SetCVar
local StaticPopup_Hide = _G.StaticPopup_Hide
local StaticPopup_Show = _G.StaticPopup_Show
local UIParent = _G.UIParent
local UpdateAddOnCPUUsage = _G.UpdateAddOnCPUUsage
local UpdateAddOnMemoryUsage = _G.UpdateAddOnMemoryUsage
local collectgarbage = _G.collectgarbage
local gcinfo = _G.gcinfo
local ipairs = ipairs
local math_floor = math.floor
local math_max = math.max
local math_min = math.min
local next = next
local string_format = string.format
local table_insert = table.insert
local table_sort = table.sort
local table_wipe = table.wipe
local unpack = unpack

-- ---------------------------------------------------------------------------
-- State & Constants
-- ---------------------------------------------------------------------------
local systemDataText
local isSystemEntered = false
local lastClickTime = 0
local CLICK_COOLDOWN = 60
local MAX_ADDONS_SHOWN = 12

local infoTable = {}
local isScriptProfileEnabled = GetCVarBool("scriptProfile")
local disableString = "|cffff5555" .. _G.VIDEO_OPTIONS_DISABLED
local enableString = "|cff55ff55" .. _G.VIDEO_OPTIONS_ENABLED
local usageColor = { 0, 1, 0, 1, 1, 0, 1, 0, 0 }

_G.StaticPopupDialogs["CPUUSAGE"] = {
	text = "ReloadUI Required",
	button1 = _G.APPLY,
	button2 = _G.CLASS_TRIAL_THANKS_DIALOG_CLOSE_BUTTON,
	OnAccept = function()
		ReloadUI()
	end,
	whileDead = 1,
}

-- ---------------------------------------------------------------------------
-- Formatting & Utility
-- ---------------------------------------------------------------------------
local function formatMemory(value)
	-- REASON: Converts raw KB memory usage into a human-readable MB or KB string.
	return value > 1024 and string_format("%.1f mb", value / 1024) or string_format("%.0f kb", value)
end

local function sortByMemory(a, b)
	-- REASON: Sorts the addon list by memory consumption (descending).
	return (a and b and ((a[3] == b[3] and a[2] < b[2]) or a[3] > b[3])) or false
end

local function sortByCPU(a, b)
	-- REASON: Sorts the addon list by CPU time consumption (descending).
	return (a and b and ((a[4] == b[4] and a[2] < b[2]) or a[4] > b[4])) or false
end

local function getSmoothColor(cur, max)
	-- REASON: Returns a color gradient from K.oUF for visual representation of usage levels.
	return K.oUF:RGBColorGradient(cur, max, unpack(usageColor))
end

local function buildAddonList()
	-- REASON: Populates the internal info table with basic information about loaded/loadable addons.
	local numAddons = C_AddOns_GetNumAddOns()
	if numAddons == #infoTable then
		return
	end

	table_wipe(infoTable)
	for i = 1, numAddons do
		local _, title, _, isLoadable = C_AddOns_GetAddOnInfo(i)
		if isLoadable then
			table_insert(infoTable, { i, title, 0, 0 })
		end
	end
end

-- ---------------------------------------------------------------------------
-- Profiling Logic
-- ---------------------------------------------------------------------------
local function updateMemoryUsage()
	-- REASON: Polls the WoW engine for latest addon memory metrics and updates the cache.
	UpdateAddOnMemoryUsage()

	local totalMemory = 0
	for _, data in ipairs(infoTable) do
		if C_AddOns_IsAddOnLoaded(data[1]) then
			local memOutput = GetAddOnMemoryUsage(data[1])
			data[3] = memOutput
			totalMemory = totalMemory + memOutput
		end
	end
	table_sort(infoTable, sortByMemory)

	return totalMemory
end

local function updateCPUUsage()
	-- REASON: Polls the WoW engine for detailed per-addon CPU metrics. Requires scriptProfile CVar.
	UpdateAddOnCPUUsage()

	local totalCPU = 0
	for _, data in ipairs(infoTable) do
		if C_AddOns_IsAddOnLoaded(data[1]) then
			local cpuOutput = GetAddOnCPUUsage(data[1])
			data[4] = cpuOutput
			totalCPU = totalCPU + cpuOutput
		end
	end
	table_sort(infoTable, sortByCPU)

	return totalCPU
end

local function colorFPS(fps)
	-- REASON: Colors the FPS readout based on standard framerate targets (15/30/60).
	fps = fps and math_floor(fps) or 0
	local colorString = fps < 15 and "|cffD80909" or (fps < 30 and "|cffE8DA0F" or "|cff0CD809")
	return colorString .. fps
end

local function setFrameRateText()
	local fpsValue = math_floor(GetFramerate())
	systemDataText.Text:SetText(string_format("%s: %s", L["FPS"], colorFPS(fpsValue)))
end

-- ---------------------------------------------------------------------------
-- UI Interaction & Callbacks
-- ---------------------------------------------------------------------------
local function onEnter(self)
	-- REASON: Dynamically populates a tooltip with memory or CPU usage lists, with support for Shift-key expansion.
	isSystemEntered = true

	if not next(infoTable) then
		buildAddonList()
	end

	local isShift = IsShiftKeyDown()
	local maxAddonsToShow = isShift and #infoTable or math_min(MAX_ADDONS_SHOWN, #infoTable)

	GameTooltip:SetOwner(systemDataText, "ANCHOR_NONE")
	GameTooltip:SetPoint(K.GetAnchors(systemDataText))
	GameTooltip:ClearLines()

	if Module.ShowMemory or not isScriptProfileEnabled then
		local totalMem = updateMemoryUsage()
		GameTooltip:AddDoubleLine("System", formatMemory(totalMem), 0.4, 0.6, 1, 0.5, 0.7, 1)
		GameTooltip:AddLine(" ")

		local numEnabled = 0
		for _, data in ipairs(infoTable) do
			if C_AddOns_IsAddOnLoaded(data[1]) then
				numEnabled = numEnabled + 1
				if numEnabled <= maxAddonsToShow then
					local r, g, b = getSmoothColor(data[3], totalMem)
					GameTooltip:AddDoubleLine(data[2], formatMemory(data[3]), 1, 1, 1, r, g, b)
				end
			end
		end

		if not isShift and (numEnabled > MAX_ADDONS_SHOWN) then
			local hiddenMemory = 0
			for i = (MAX_ADDONS_SHOWN + 1), numEnabled do
				hiddenMemory = hiddenMemory + infoTable[i][3]
			end
			GameTooltip:AddDoubleLine(string_format("%d %s (%s)", numEnabled - MAX_ADDONS_SHOWN, L["Hidden"], L["Hold Shift"]), formatMemory(hiddenMemory), 0.5, 0.7, 1, 0.5, 0.7, 1)
		end
	else
		local totalCPUTime = updateCPUUsage()
		local passedTime = math_max(1, GetTime() - Module.CheckLoginTime)
		GameTooltip:AddDoubleLine(L["System"], string_format("%.3f ms", totalCPUTime / passedTime), 0.4, 0.6, 1, 0.5, 0.7, 1)
		GameTooltip:AddLine(" ")

		local numEnabled = 0
		for _, data in ipairs(infoTable) do
			if C_AddOns_IsAddOnLoaded(data[1]) then
				numEnabled = numEnabled + 1
				if numEnabled <= maxAddonsToShow then
					local r, g, b = getSmoothColor(data[4], totalCPUTime)
					GameTooltip:AddDoubleLine(data[2], string_format("%.3f ms", data[4] / passedTime), 1, 1, 1, r, g, b)
				end
			end
		end

		if not isShift and (numEnabled > MAX_ADDONS_SHOWN) then
			local hiddenCPU = 0
			for i = (MAX_ADDONS_SHOWN + 1), numEnabled do
				hiddenCPU = hiddenCPU + infoTable[i][4]
			end
			GameTooltip:AddDoubleLine(string_format("%d %s (%s)", numEnabled - MAX_ADDONS_SHOWN, L["Hidden"], L["Hold Shift"]), string_format("%.3f ms", hiddenCPU / passedTime), 0.5, 0.7, 1, 0.5, 0.7, 1)
		end
	end

	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(" ", "|TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:12:10:0:-1:512:512:12:66:230:307|t " .. L["Collect Memory"] .. " ", 1, 1, 1, 0.5, 0.7, 1)
	if isScriptProfileEnabled then
		GameTooltip:AddDoubleLine(" ", "|TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:12:10:0:-1:512:512:12:66:333:411|t " .. L["SwitchMode"] .. " ", 1, 1, 1, 0.5, 0.7, 1)
	end
	GameTooltip:AddDoubleLine(" ", "|TInterface\\TUTORIALFRAME\\UI-TUTORIAL-FRAME:13:11:0:-1:512:512:12:66:127:204|t " .. L["CPU Usage"] .. ": " .. (GetCVarBool("scriptProfile") and enableString or disableString) .. " ", 1, 1, 1, 0.5, 0.7, 1)
	GameTooltip:Show()
end

local function onUpdate(self, elapsed)
	-- REASON: One-second throttle to update framerate text and, if active, tooltip profiling data.
	self.timer = (self.timer or 0) + elapsed
	if self.timer > 1 then
		setFrameRateText()
		if isSystemEntered then
			onEnter(self)
		end
		self.timer = 0
	end
end

local function onLeave()
	isSystemEntered = false
	GameTooltip:Hide()
end

local function onMouseUp(_, btn)
	-- REASON: Interaction: Left-click triggers GC (with cooldown). Right-click toggles Memory/CPU mode. Middle-click toggles script profiling CVar.
	local currentTime = GetTime()

	if btn == "LeftButton" then
		if isScriptProfileEnabled then
			ResetCPUUsage()
			Module.CheckLoginTime = GetTime()
		end

		if currentTime - lastClickTime < CLICK_COOLDOWN then
			return
		end

		lastClickTime = currentTime
		local memBefore = gcinfo()
		collectgarbage("collect")
		K.Print(string_format(K.InfoColorTint .. "%s:|r %s", L["Memory Collected"], formatMemory(memBefore - gcinfo())))

		onEnter(nil)
	elseif btn == "RightButton" and isScriptProfileEnabled then
		Module.ShowMemory = not Module.ShowMemory
		onEnter(nil)
	elseif btn == "MiddleButton" then
		local currentValue = GetCVarBool("scriptProfile")
		SetCVar("scriptProfile", currentValue and 0 or 1)

		if GetCVarBool("scriptProfile") == isScriptProfileEnabled then
			_G.StaticPopup_Hide("CPUUSAGE")
		else
			_G.StaticPopup_Show("CPUUSAGE")
		end
		onEnter(nil)
	end
end

-- ---------------------------------------------------------------------------
-- Initialization
-- ---------------------------------------------------------------------------
function Module:CreateSystemDataText()
	-- REASON: Entry point for the system performance DataText; initializes the FPS readout and profiling logic.
	if not C["DataText"].System then
		return
	end

	systemDataText = CreateFrame("Frame", "KKUI_SystemDataText", UIParent)
	systemDataText:SetHitRectInsets(-16, 0, -10, -10)

	systemDataText.Text = K.CreateFontString(systemDataText, 12)
	systemDataText.Text:ClearAllPoints()
	systemDataText.Text:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 24, -6)

	systemDataText.Texture = systemDataText:CreateTexture(nil, "ARTWORK")
	systemDataText.Texture:SetPoint("RIGHT", systemDataText.Text, "LEFT", -4, 2)
	systemDataText.Texture:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\DataText\\fps.blp")
	systemDataText.Texture:SetSize(15, 15)
	systemDataText.Texture:SetVertexColor(unpack(C["DataText"].IconColor))

	systemDataText:SetAllPoints(systemDataText.Text)

	systemDataText:SetScript("OnEnter", onEnter)
	systemDataText:SetScript("OnLeave", onLeave)
	systemDataText:SetScript("OnMouseUp", onMouseUp)
	systemDataText:SetScript("OnUpdate", onUpdate)

	K.SystemDataText = systemDataText -- REASON: Allows other DataText modules to anchor to this one.
end
