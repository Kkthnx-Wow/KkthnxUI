local K, C, L = unpack(KkthnxUI)
local Module = K:GetModule("DataText")

local max = math.max
local format = string.format
local GetNetStats, GetNetIpTypes, GetFileStreamingStatus, GetBackgroundLoadingStatus, GetAvailableBandwidth, GetDownloadedPercentage = GetNetStats, GetNetIpTypes, GetFileStreamingStatus, GetBackgroundLoadingStatus, GetAvailableBandwidth, GetDownloadedPercentage

local UNKNOWN = UNKNOWN
local ipTypes = { "IPv4", "IPv6" }
local LatencyDataText
local LatencyDataTextEntered

local function ColorLatency(latency)
	if latency < 250 then
		return "|cff0CD809" .. latency
	elseif latency < 500 then
		return "|cffE8DA0F" .. latency
	else
		return "|cffD80909" .. latency
	end
end

local function SetLatency()
	local _, _, latencyHome, latencyWorld = GetNetStats()
	local latency = max(latencyHome, latencyWorld)
	LatencyDataText.Text:SetText(L["MS"] .. ": " .. ColorLatency(latency))
end

local function OnEnter()
	LatencyDataTextEntered = true

	GameTooltip:SetOwner(LatencyDataText, "ANCHOR_NONE")
	GameTooltip:SetPoint(K.GetAnchors(LatencyDataText))
	GameTooltip:ClearLines()

	GameTooltip:AddLine(L["Latency"], 0.4, 0.6, 1)
	GameTooltip:AddLine(" ")

	local _, _, latencyHome, latencyWorld = GetNetStats()
	GameTooltip:AddDoubleLine(L["Home Latency"], ColorLatency(latencyHome) .. "|r ms", 0.5, 0.7, 1, 1, 1, 1)
	GameTooltip:AddDoubleLine(L["World Latency"], ColorLatency(latencyWorld) .. "|r ms", 0.5, 0.7, 1, 1, 1, 1)

	if GetCVarBool("useIPv6") then
		local ipTypeHome, ipTypeWorld = GetNetIpTypes()
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(L["Home Protocol"], ipTypes[ipTypeHome or 0] or UNKNOWN, 0.5, 0.7, 1, 1, 1, 1)
		GameTooltip:AddDoubleLine(L["World Protocol"], ipTypes[ipTypeWorld or 0] or UNKNOWN, 0.5, 0.7, 1, 1, 1, 1)
	end

	local downloading = GetFileStreamingStatus() ~= 0 or GetBackgroundLoadingStatus() ~= 0
	if downloading then
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(L["Bandwidth"], format("%.2f Mbps", GetAvailableBandwidth()), 0.5, 0.7, 1, 1, 1, 1)
		GameTooltip:AddDoubleLine(L["Download"], format("%.2f%%", GetDownloadedPercentage() * 100), 0.5, 0.7, 1, 1, 1, 1)
	end

	GameTooltip:Show()
end

local function OnUpdate(self, elapsed)
	self.timer = (self.timer or 0) + elapsed
	if self.timer > 1 then
		SetLatency()
		if LatencyDataTextEntered then
			OnEnter()
		end

		self.timer = 0
	end
end

local function OnLeave()
	LatencyDataTextEntered = false
	GameTooltip:Hide()
end

function Module:CreateLatencyDataText()
	if not C["DataText"].Latency then
		return
	end

	local xOffset = C["DataText"].System and 26 or 0
	local anchorFrame = C["DataText"].System and _G.KKUI_SystemDataText.Text or UIParent
	local anchorPoint1 = C["DataText"].System and "LEFT" or "TOPLEFT"
	local anchorPoint2 = C["DataText"].System and "RIGHT" or "TOPLEFT"

	LatencyDataText = CreateFrame("Frame", nil, UIParent)
	LatencyDataText:SetHitRectInsets(-16, 0, -10, -10)

	LatencyDataText.Text = K.CreateFontString(LatencyDataText, 12)
	LatencyDataText.Text:ClearAllPoints()
	LatencyDataText.Text:SetPoint(anchorPoint1, anchorFrame, anchorPoint2, xOffset, 0)

	LatencyDataText.Texture = LatencyDataText:CreateTexture(nil, "ARTWORK")
	LatencyDataText.Texture:SetPoint("RIGHT", LatencyDataText.Text, "LEFT", -4, 2)
	LatencyDataText.Texture:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\DataText\\ping.tga")
	LatencyDataText.Texture:SetSize(16, 16)
	LatencyDataText.Texture:SetVertexColor(unpack(C["DataText"].IconColor))

	LatencyDataText:SetAllPoints(LatencyDataText.Text)

	LatencyDataText:SetScript("OnEnter", OnEnter)
	LatencyDataText:SetScript("OnLeave", OnLeave)
	LatencyDataText:SetScript("OnUpdate", OnUpdate)
end
