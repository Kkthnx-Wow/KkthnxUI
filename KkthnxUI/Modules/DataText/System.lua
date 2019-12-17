local K, C, L = unpack(select(2, ...))
if C["DataText"].System ~= true then
	return
end

local Module = K:GetModule("Infobar")
local ModuleInfo = Module:RegisterInfobar("KkthnxUISystem", {"TOPLEFT", UIParent, "TOPLEFT", 4, -4})

local _G = _G
local select = _G.select
local string_format = _G.string.format
local math_floor = _G.math.floor

local GameTooltip = _G.GameTooltip
local GetAvailableBandwidth = _G.GetAvailableBandwidth
local GetCVarBool = _G.GetCVarBool
local GetDownloadedPercentage = _G.GetDownloadedPercentage
local GetFramerate = _G.GetFramerate
local GetNetIpTypes = _G.GetNetIpTypes
local GetNetStats = _G.GetNetStats
local UNKNOWN = _G.UNKNOWN

-- initial delay for update (let the ui load)
local int, int2 = 6, 5
local enteredFrame = false
local bandwidthString = "%.2f Mbps"
local percentageString = "%.2f%%"
local homeLatencyString = "%d ms"

local ipTypes = {"IPv4", "IPv6"}
ModuleInfo.onEnter = function(self)
	enteredFrame = true
	GameTooltip:SetOwner(self, "ANCHOR_NONE")
	GameTooltip:SetPoint(K.GetAnchors(self))
	GameTooltip:ClearLines()

	local bandwidth = GetAvailableBandwidth()
	local _, _, homePing, worldPing = GetNetStats()

	GameTooltip:AddDoubleLine(L["Home Latency:"], string_format(homeLatencyString, homePing), nil, nil, nil, 1, 1, 1)
	GameTooltip:AddDoubleLine(L["World Latency:"], string_format(homeLatencyString, worldPing), nil, nil, nil, 1, 1, 1)

	if GetCVarBool("useIPv6") then
		local ipTypeHome, ipTypeWorld = GetNetIpTypes()
		GameTooltip:AddDoubleLine(L["Home Protocol:"], ipTypes[ipTypeHome or 0] or UNKNOWN, nil, nil, nil, 1, 1, 1)
		GameTooltip:AddDoubleLine(L["World Protocol:"], ipTypes[ipTypeWorld or 0] or UNKNOWN, nil, nil, nil, 1, 1, 1)
	end

	if bandwidth ~= 0 then
		GameTooltip:AddDoubleLine(L["Bandwidth"] , string_format(bandwidthString, bandwidth), nil, nil, nil, 1, 1, 1)
		GameTooltip:AddDoubleLine(L["Download"] , string_format(percentageString, GetDownloadedPercentage() * 100), nil, nil, nil, 1, 1, 1)
		GameTooltip:AddLine(" ")
	end

	GameTooltip:Show()
end

ModuleInfo.onLeave = function()
	enteredFrame = false
	GameTooltip:Hide()
end

ModuleInfo.onUpdate = function(self, t)
	int = int - t
	int2 = int2 - t

	if int2 < 0 then
		local fps = math_floor(GetFramerate())
		local cast_latency = select(4, GetNetStats())
		local PlayerColorStr = _G.RAID_CLASS_COLORS[K.Class].colorStr
		local FPS_ABBR = "|c"..PlayerColorStr.._G.FPS_ABBR.."|r"
		local MILLISECONDS_ABBR = "|c"..PlayerColorStr.._G.MILLISECONDS_ABBR.."|r"
		local performance_string = "%d%s - %d%s"

		self.text:SetFormattedText(performance_string, cast_latency, MILLISECONDS_ABBR, fps, FPS_ABBR)
		int2 = 1

		if enteredFrame then
			self:onEnter()
		end
	end
end