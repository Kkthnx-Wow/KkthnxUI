local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("Infobar")

local _G = _G
local math_max = _G.math.max
local string_format = _G.string.format

local GetAvailableBandwidth = _G.GetAvailableBandwidth
local GetBackgroundLoadingStatus = _G.GetBackgroundLoadingStatus
local GetCVarBool = _G.GetCVarBool
local GetDownloadedPercentage = _G.GetDownloadedPercentage
local GetFileStreamingStatus = _G.GetFileStreamingStatus
local GetNetIpTypes = _G.GetNetIpTypes
local GetNetStats = _G.GetNetStats
local UNKNOWN = _G.UNKNOWN

local entered
local ipTypes = {
	"IPv4",
	"IPv6",
}

local function colorLatency(latency)
	if latency < 250 then
		return "|cff0CD809"..latency
	elseif latency < 500 then
		return "|cffE8DA0F"..latency
	else
		return "|cffD80909"..latency
	end
end

local function setLatency()
	local _, _, latencyHome, latencyWorld = GetNetStats()
	local latency = math_max(latencyHome, latencyWorld)
	Module.LatencyFrame.Text:SetText(L["MS"]..": "..colorLatency(latency))
end

local function OnEnter()
	entered = true

	GameTooltip:SetOwner(Module.LatencyFrame, "ANCHOR_NONE")
	GameTooltip:SetPoint(K.GetAnchors(Module.LatencyFrame))
	GameTooltip:ClearLines()

	GameTooltip:AddLine(L["Latency"], 0, 0.6, 1)
	GameTooltip:AddLine(" ")

	local _, _, latencyHome, latencyWorld = GetNetStats()
	GameTooltip:AddDoubleLine(L["Home Latency"], colorLatency(latencyHome).."|r ms", 0.6, 0.8, 1, 1, 1, 1)
	GameTooltip:AddDoubleLine(L["World Latency"], colorLatency(latencyWorld).."|r ms", 0.6, 0.8, 1, 1, 1, 1)

	if GetCVarBool("useIPv6") then
		local ipTypeHome, ipTypeWorld = GetNetIpTypes()
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(L["Home Protocol"], ipTypes[ipTypeHome or 0] or UNKNOWN, 0.6, 0.8, 1, 1, 1, 1)
		GameTooltip:AddDoubleLine(L["World Protocol"], ipTypes[ipTypeWorld or 0] or UNKNOWN, 0.6, 0.8, 1, 1, 1, 1)
	end

	local downloading = GetFileStreamingStatus() ~= 0 or GetBackgroundLoadingStatus() ~= 0
	if downloading then
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(L["Bandwidth"], string_format("%.2f Mbps", GetAvailableBandwidth()), 0.6, 0.8, 1, 1, 1, 1)
		GameTooltip:AddDoubleLine(L["Download"], string_format("%.2f%%", GetDownloadedPercentage() * 100), 0.6, 0.8, 1, 1, 1, 1)
	end

	GameTooltip:Show()
end

local function OnUpdate(self, elapsed)
	self.timer = (self.timer or 0) + elapsed
	if self.timer > 1 then
		setLatency()
		if entered then
			OnEnter()
		end

		self.timer = 0
	end
end

local function OnLeave()
	entered = false
	GameTooltip:Hide()
end

function Module:CreateLatencyDataText()
	if not C["DataText"].Latency then
		return
	end

	Module.LatencyFrame = CreateFrame("Frame", "KKUI_LatencyDataText", UIParent)

	Module.LatencyFrame.Text = Module.LatencyFrame:CreateFontString("OVERLAY")
	Module.LatencyFrame.Text:FontTemplate(nil, 12)
	Module.LatencyFrame.Text:ClearAllPoints()
	if C["DataText"].System then
		Module.LatencyFrame.Text:SetPoint("LEFT", KKUI_SystemDataText, "RIGHT", 4, 0)
	else
		Module.LatencyFrame.Text:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 4, -4)
	end

	Module.LatencyFrame:SetAllPoints(Module.LatencyFrame.Text)

	Module.LatencyFrame:SetScript("OnUpdate", OnUpdate)
	Module.LatencyFrame:SetScript("OnEnter", OnEnter)
	Module.LatencyFrame:SetScript("OnLeave", OnLeave)
end