local K, C = unpack(select(2, ...))
local Module = K:GetModule("Infobar")

local _G = _G
local select, collectgarbage = _G.select, _G.collectgarbage
local sort, wipe, format = _G.sort, _G.wipe, _G.format

local GetAddOnCPUUsage = _G.GetAddOnCPUUsage
local GetAddOnInfo = _G.GetAddOnInfo
local GetAddOnMemoryUsage = _G.GetAddOnMemoryUsage
local GetAvailableBandwidth = _G.GetAvailableBandwidth
local GetCVar = _G.GetCVar
local GetCVarBool = _G.GetCVarBool
local GetDownloadedPercentage = _G.GetDownloadedPercentage
local GetFramerate = _G.GetFramerate
local GetNetIpTypes = _G.GetNetIpTypes
local GetNetStats = _G.GetNetStats
local GetNumAddOns = _G.GetNumAddOns
local IsAddOnLoaded = _G.IsAddOnLoaded
local IsShiftKeyDown = _G.IsShiftKeyDown
local IsModifierKeyDown = _G.IsModifierKeyDown
local ResetCPUUsage = _G.ResetCPUUsage
local UpdateAddOnCPUUsage = _G.UpdateAddOnCPUUsage
local UpdateAddOnMemoryUsage = _G.UpdateAddOnMemoryUsage
local UNKNOWN = _G.UNKNOWN

-- initial delay for update (let the ui load)
local int, int2 = 6, 5

local enteredFrame = false
local bandwidthString = "%.2f Mbps"
local percentageString = "%.2f%%"
local homeLatencyString = "%d ms"
local kiloByteString = "%d kb"
local megaByteString = "%.2f mb"
local cpuProfiling = GetCVar("scriptProfile") == "1"

local function formatMem(memory)
	local mult = 10^1
	if memory > 999 then
		local mem = ((memory / 1024) * mult) / mult
		return format(megaByteString, mem)
	else
		local mem = (memory * mult) / mult
		return format(kiloByteString, mem)
	end
end

local function sortByMemoryOrCPU(a, b)
	if a and b then
		return (a[3] == b[3] and a[2] < b[2]) or a[3] > b[3]
	end
end

local memoryTable = {}
local cpuTable = {}
local function RebuildAddonList()
	local addOnCount = GetNumAddOns()
	if (addOnCount == #memoryTable) then
		return
	end

	-- Number of loaded addons changed, create new memoryTable for all addons
	wipe(memoryTable)
	wipe(cpuTable)
	for i = 1, addOnCount do
		memoryTable[i] = {i, select(2, GetAddOnInfo(i)), 0}
		cpuTable[i] = {i, select(2, GetAddOnInfo(i)), 0}
	end
end

local function UpdateMemory()
	-- Update the memory usages of the addons
	UpdateAddOnMemoryUsage()
	-- Load memory usage in table
	local totalMemory = 0
	for i = 1, #memoryTable do
		memoryTable[i][3] = GetAddOnMemoryUsage(memoryTable[i][1])
		totalMemory = totalMemory + memoryTable[i][3]
	end
	-- Sort the table to put the largest addon on top
	sort(memoryTable, sortByMemoryOrCPU)

	return totalMemory
end

local function UpdateCPU()
	-- Update the CPU usages of the addons
	UpdateAddOnCPUUsage()
	-- Load cpu usage in table
	local totalCPU = 0
	for i = 1, #cpuTable do
		local addonCPU = GetAddOnCPUUsage(cpuTable[i][1])
		cpuTable[i][3] = addonCPU
		totalCPU = totalCPU + addonCPU
	end

	-- Sort the table to put the largest addon on top
	sort(cpuTable, sortByMemoryOrCPU)

	return totalCPU
end

function Module:OnSystemMouseUp(button)
	if IsModifierKeyDown() and button == "RightButton" then
		UpdateAddOnMemoryUsage()
		local before = _G.gcinfo()
		collectgarbage("collect")
		UpdateAddOnMemoryUsage()
		K.Print(format("%s: %s", K.SystemColor.."Garbage Collected|r", formatMem(before - _G.gcinfo())))
		ResetCPUUsage()
	elseif button == "LeftButton" then
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

	local totalMemory = UpdateMemory()
	local bandwidth = GetAvailableBandwidth()
	local _, _, homePing, worldPing = GetNetStats()

	GameTooltip:AddDoubleLine("Home Latency:", format(homeLatencyString, homePing), nil, nil, nil, 102/255, 157/255, 255/255)
	GameTooltip:AddDoubleLine("World Latency:", format(homeLatencyString, worldPing), nil, nil, nil, 102/255, 157/255, 255/255)

	if GetCVarBool("useIPv6") then
		local ipTypeHome, ipTypeWorld = GetNetIpTypes()
		GameTooltip:AddDoubleLine("Home Protocol:", ipTypes[ipTypeHome or 0] or UNKNOWN, nil, nil, nil, 102/255, 157/255, 255/255)
		GameTooltip:AddDoubleLine("World Protocol:", ipTypes[ipTypeWorld or 0] or UNKNOWN, nil, nil, nil, 102/255, 157/255, 255/255)
	end

	if bandwidth ~= 0 then
		GameTooltip:AddDoubleLine("Bandwidth" , format(bandwidthString, bandwidth), nil, nil, nil, 102/255, 157/255, 255/255)
		GameTooltip:AddDoubleLine("Download" , format(percentageString, GetDownloadedPercentage() *100), nil, nil, nil, 102/255, 157/255, 255/255)
		GameTooltip:AddLine(" ")
	end

	local totalCPU
	GameTooltip:AddDoubleLine("Total Memory:", formatMem(totalMemory), nil, nil, nil, 102/255, 157/255, 255/255)
	if cpuProfiling then
		totalCPU = UpdateCPU()
		GameTooltip:AddDoubleLine("Total CPU:", format(homeLatencyString, totalCPU), nil, nil, nil, 102/255, 157/255, 255/255)
	end

	GameTooltip:AddLine(" ")
	if IsShiftKeyDown() or not cpuProfiling then
		for i = 1, #memoryTable do
			local ele = memoryTable[i]
			if ele and IsAddOnLoaded(ele[1]) then
				local red = ele[3] / totalMemory
				local green = 1 - red
				GameTooltip:AddDoubleLine(ele[2], formatMem(ele[3]), 1, 1, 1, red, green + .5, 0)
			end
		end
	else
		for i = 1, #cpuTable do
			local ele = cpuTable[i]
			if ele and IsAddOnLoaded(ele[1]) then
				local red = ele[3] / totalCPU
				local green = 1 - red
				GameTooltip:AddDoubleLine(ele[2], format(homeLatencyString, ele[3]), 1, 1, 1, red, green + .5, 0)
			end
		end

		GameTooltip:AddLine(" ")
		GameTooltip:AddLine("Hold Shift: "..K.InfoColor.."Memory Usage|r")
	end

	GameTooltip:AddLine(" ")
	GameTooltip:AddLine("Left Click: "..K.InfoColor.."AddOns List|r")
	GameTooltip:AddLine("Modifer + Right Click: "..K.InfoColor.."Collect Garbage|r")

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
		RebuildAddonList()
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