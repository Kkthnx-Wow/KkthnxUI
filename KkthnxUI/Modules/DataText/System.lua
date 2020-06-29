local K, C = unpack(select(2, ...))
local Module = K:GetModule("Infobar")

local _G = _G
local select = _G.select
local string_format = _G.string.format

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

function Module:OnSystemMouseUp(button)
	if button == "LeftButton" then
		if _G.AddonList:IsShown() then
			_G.AddonList_OnCancel()
		else
			_G.PlaySound(_G.SOUNDKIT.IG_MAINMENU_OPTION)
			_G.ShowUIPanel(_G.AddonList)
		end
	end
end

local ipTypes = {"IPv4", "IPv6"}
function Module:OnSystemEnter()
	enteredFrame = true

	GameTooltip:SetOwner(Module.SystemFrame, "ANCHOR_NONE")
	GameTooltip:SetPoint(K.GetAnchors(Module.SystemFrame))
	GameTooltip:ClearLines()

	local bandwidth = GetAvailableBandwidth()
	local _, _, homePing, worldPing = GetNetStats()

	GameTooltip:AddDoubleLine("Home Latency:", string_format(homeLatencyString, homePing), nil, nil, nil, 102/255, 157/255, 255/255)
	GameTooltip:AddDoubleLine("World Latency:", string_format(homeLatencyString, worldPing), nil, nil, nil, 102/255, 157/255, 255/255)

	if GetCVarBool("useIPv6") then
		local ipTypeHome, ipTypeWorld = GetNetIpTypes()
		GameTooltip:AddDoubleLine("Home Protocol:", ipTypes[ipTypeHome or 0] or UNKNOWN, nil, nil, nil, 102/255, 157/255, 255/255)
		GameTooltip:AddDoubleLine("World Protocol:", ipTypes[ipTypeWorld or 0] or UNKNOWN, nil, nil, nil, 102/255, 157/255, 255/255)
	end

	if bandwidth ~= 0 then
		GameTooltip:AddDoubleLine("Bandwidth" , string_format(bandwidthString, bandwidth), nil, nil, nil, 102/255, 157/255, 255/255)
		GameTooltip:AddDoubleLine("Download" , string_format(percentageString, GetDownloadedPercentage() *100), nil, nil, nil, 102/255, 157/255, 255/255)
		GameTooltip:AddLine(" ")
	end

	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine("Left Click:", K.InfoColor.."AddOns List|r")

	GameTooltip:Show()
end

function Module:OnSystemLeave()
	enteredFrame = false
	GameTooltip:Hide()
end

function Module:OnSystemUpdate(t)
	int = int - t
	int2 = int2 - t

	if int < 0 then
		int = 10
	end

	if int2 < 0 then
		local isFPS = math.floor(GetFramerate())
		local latencyString = select(4, GetNetStats())
		local fpsString = K.MyClassColor.._G.FPS_ABBR.."|r"
		local msString = K.MyClassColor.._G.MILLISECONDS_ABBR.."|r"
		local performanceString = "%d%s - %d%s"

		Module.SystemFont:SetFormattedText(performanceString, latencyString, msString, isFPS, fpsString)

		int2 = 1

		if enteredFrame then
			Module:OnSystemEnter()
		end
	end
end

function Module:CreateSystemDataText()
	if not C["DataText"].System then
		return
	end

	Module.SystemFrame = CreateFrame("Frame", "KKUI_SystemDataText", UIParent)

	Module.SystemFont = Module.SystemFrame:CreateFontString("OVERLAY")
	Module.SystemFont:FontTemplate(nil, 13)
	Module.SystemFont:SetPoint("TOPLEFT", UIParent, "TOPLEFT", 4, -4)

	Module.SystemFrame:SetAllPoints(Module.SystemFont)

	Module.SystemFrame:SetScript("OnUpdate", Module.OnSystemUpdate)
	Module.SystemFrame:SetScript("OnEnter", Module.OnSystemEnter)
	Module.SystemFrame:SetScript("OnLeave", Module.OnSystemLeave)
	Module.SystemFrame:SetScript("OnMouseUp", Module.OnSystemMouseUp)
end