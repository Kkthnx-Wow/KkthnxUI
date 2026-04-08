--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Displays current game latency (Home and World) and network protocols.
-- - Design: Throttled OnUpdate script that refreshes latency text and tooltip data.
-- - Events: N/A (OnUpdate driven)
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("DataText")

-- PERF: Localize globals and API functions to reduce lookup overhead.
local _G = _G
local CreateFrame = _G.CreateFrame
local GameTooltip = _G.GameTooltip
local GetAvailableBandwidth = _G.GetAvailableBandwidth
local GetBackgroundLoadingStatus = _G.GetBackgroundLoadingStatus
local GetCVarBool = _G.GetCVarBool
local GetDownloadedPercentage = _G.GetDownloadedPercentage
local GetFileStreamingStatus = _G.GetFileStreamingStatus
local GetNetIpTypes = _G.GetNetIpTypes
local GetNetStats = _G.GetNetStats
local UIParent = _G.UIParent
local math_max = math.max
local string_format = string.format
local unpack = unpack

-- ---------------------------------------------------------------------------
-- State & Constants
-- ---------------------------------------------------------------------------
local latencyDataText
local isLatencyEntered = false
local IP_TYPES = { [1] = "IPv4", [2] = "IPv6" }

-- ---------------------------------------------------------------------------
-- Internal Logic
-- ---------------------------------------------------------------------------
local function colorLatency(latency)
	-- REASON: Dynamically colors the latency value based on typical playability thresholds.
	if latency < 250 then
		return "|cff0CD809" .. latency -- Green
	elseif latency < 500 then
		return "|cffE8DA0F" .. latency -- Yellow
	else
		return "|cffD80909" .. latency -- Red
	end
end

local function setLatencyText()
	-- REASON: Updates the DataText display with the highest current latency (Home or World).
	local _, _, latencyHome, latencyWorld = GetNetStats()
	local maxLatency = math_max(latencyHome, latencyWorld)
	latencyDataText.Text:SetText(L["MS"] .. ": " .. colorLatency(maxLatency))
end

local function onEnter(self)
	-- REASON: Provides a detailed network breakdown, including protocols and background download progress.
	isLatencyEntered = true

	GameTooltip:SetOwner(latencyDataText, "ANCHOR_NONE")
	GameTooltip:SetPoint(K.GetAnchors(latencyDataText))
	GameTooltip:ClearLines()

	GameTooltip:AddLine(L["Latency"], 0.4, 0.6, 1)
	GameTooltip:AddLine(" ")

	local _, _, latencyHome, latencyWorld = GetNetStats()
	GameTooltip:AddDoubleLine(L["Home Latency"], colorLatency(latencyHome) .. "|r ms", 0.5, 0.7, 1, 1, 1, 1)
	GameTooltip:AddDoubleLine(L["World Latency"], colorLatency(latencyWorld) .. "|r ms", 0.5, 0.7, 1, 1, 1, 1)

	if GetCVarBool("useIPv6") then
		local ipTypeHome, ipTypeWorld = GetNetIpTypes()
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(L["Home Protocol"], IP_TYPES[ipTypeHome or 0] or _G.UNKNOWN, 0.5, 0.7, 1, 1, 1, 1)
		GameTooltip:AddDoubleLine(L["World Protocol"], IP_TYPES[ipTypeWorld or 0] or _G.UNKNOWN, 0.5, 0.7, 1, 1, 1, 1)
	end

	local isDownloading = GetFileStreamingStatus() ~= 0 or GetBackgroundLoadingStatus() ~= 0
	if isDownloading then
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(L["Bandwidth"], string_format("%.2f Mbps", GetAvailableBandwidth()), 0.5, 0.7, 1, 1, 1, 1)
		GameTooltip:AddDoubleLine(L["Download"], string_format("%.2f%%", GetDownloadedPercentage() * 100), 0.5, 0.7, 1, 1, 1, 1)
	end

	GameTooltip:Show()
end

local function onUpdate(self, elapsed)
	-- REASON: Throttled update to refresh latency once per second to avoid excessive API polling.
	self.timer = (self.timer or 0) + elapsed
	if self.timer > 1 then
		setLatencyText()
		if isLatencyEntered then
			onEnter(self)
		end
		self.timer = 0
	end
end

local function onLeave()
	isLatencyEntered = false
	GameTooltip:Hide()
end

-- ---------------------------------------------------------------------------
-- Initialization
-- ---------------------------------------------------------------------------
function Module:CreateLatencyDataText()
	-- REASON: Entry point for latency DataText; calculates layout based on the presence of the System DataText.
	if not C["DataText"].Latency then
		return
	end

	local isSystemEnabled = C["DataText"].System
	local xOffset = isSystemEnabled and 26 or 0
	local anchorFrame = isSystemEnabled and _G.KKUI_SystemDataText and _G.KKUI_SystemDataText.Text or UIParent
	local anchorPoint1 = isSystemEnabled and "LEFT" or "TOPLEFT"
	local anchorPoint2 = isSystemEnabled and "RIGHT" or "TOPLEFT"

	latencyDataText = CreateFrame("Frame", nil, UIParent)
	latencyDataText:SetHitRectInsets(-16, 0, -10, -10)

	latencyDataText.Text = K.CreateFontString(latencyDataText, 12)
	latencyDataText.Text:ClearAllPoints()
	latencyDataText.Text:SetPoint(anchorPoint1, anchorFrame, anchorPoint2, xOffset, 0)

	latencyDataText.Texture = latencyDataText:CreateTexture(nil, "ARTWORK")
	latencyDataText.Texture:SetPoint("RIGHT", latencyDataText.Text, "LEFT", -4, 2)
	latencyDataText.Texture:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\DataText\\ping.tga")
	latencyDataText.Texture:SetSize(16, 16)
	latencyDataText.Texture:SetVertexColor(unpack(C["DataText"].IconColor))

	latencyDataText:SetAllPoints(latencyDataText.Text)

	latencyDataText:SetScript("OnEnter", onEnter)
	latencyDataText:SetScript("OnLeave", onLeave)
	latencyDataText:SetScript("OnUpdate", onUpdate)
end
