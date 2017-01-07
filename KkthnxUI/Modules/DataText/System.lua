local K, C, L = unpack(select(2, ...))

-- Lua API
local collectgarbage = collectgarbage
local math_floor = math.floor
local select = select
local string_format = string.format
local table_sort = table.sort
local table_wipe = table.wipe

-- Wow API
local GetAddOnCPUUsage = GetAddOnCPUUsage
local GetAddOnInfo = GetAddOnInfo
local GetAddOnMemoryUsage = GetAddOnMemoryUsage
local GetAvailableBandwidth = GetAvailableBandwidth
local GetCVar = GetCVar
local GetDownloadedPercentage = GetDownloadedPercentage
local GetFramerate = GetFramerate
local GetNetStats = GetNetStats
local GetNumAddOns = GetNumAddOns
local IsAddOnLoaded = IsAddOnLoaded
local IsShiftKeyDown = IsShiftKeyDown
local ResetCPUUsage = ResetCPUUsage
local SetCVar = SetCVar
local UpdateAddOnCPUUsage = UpdateAddOnCPUUsage
local UpdateAddOnMemoryUsage = UpdateAddOnMemoryUsage

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: GameTooltip, SLASH_CPUPROFILING1

local DataTextSystem = CreateFrame("Frame")
DataTextSystem:EnableMouse(true)
DataTextSystem:SetFrameStrata("BACKGROUND")
DataTextSystem:SetFrameLevel(3)

local Font, FontSize, FontStyle = C.Media.Font, C.Media.Font_Size, C.Media.Font_Style
local NameColor = K.RGBToHex(K.Color.r, K.Color.g, K.Color.b)
local ValueColor = K.RGBToHex(1, 1, 1)
local Text = KkthnxUIMinimapStats:CreateFontString(nil, "OVERLAY")
Text:SetFont(Font, FontSize, FontStyle)
Text:SetPoint("CENTER", KkthnxUIMinimapStats, "CENTER", 0, .5)

-- initial delay for update (let the ui load)
local int, int2 = 6, 5
local enteredFrame = false
local bandwidthString = "%.2f Mbps"
local percentageString = "%.2f%%"
local homeLatencyString = "%d ms"
local kiloByteString = "%d kb"
local megaByteString = "%.2f mb"
local totalMemory = 0
local bandwidth = 0

local function formatMem(memory)
	local mult = 10^1
	if memory > 999 then
		local mem = ((memory/1024) * mult) / mult
		return string_format(megaByteString, mem)
	else
		local mem = (memory * mult) / mult
		return string_format(kiloByteString, mem)
	end
end

local function sortByMemoryOrCPU(a, b)
	if a and b then
		return a[3] > b[3]
	end
end

local memoryTable = {}
local cpuTable = {}
local function RebuildAddonList()
	local addOnCount = GetNumAddOns()
	if (addOnCount == #memoryTable) then return end

	-- Number of loaded addons changed, create new memoryTable for all addons
	table_wipe(memoryTable)
	table_wipe(cpuTable)
	for i = 1, addOnCount do
		memoryTable[i] = { i, select(2, GetAddOnInfo(i)), 0, IsAddOnLoaded(i) }
		cpuTable[i] = { i, select(2, GetAddOnInfo(i)), 0, IsAddOnLoaded(i) }
	end
end

local function UpdateMemory()
	-- Update the memory usages of the addons
	UpdateAddOnMemoryUsage()
	-- Load memory usage in table
	totalMemory = 0
	for i = 1, #memoryTable do
		memoryTable[i][3] = GetAddOnMemoryUsage(memoryTable[i][1])
		totalMemory = totalMemory + memoryTable[i][3]
	end
	-- Sort the table to put the largest addon on top
	table_sort(memoryTable, sortByMemoryOrCPU)
end

local function UpdateCPU()
	--Update the CPU usages of the addons
	UpdateAddOnCPUUsage()
	-- Load cpu usage in table
	local addonCPU = 0
	local totalCPU = 0
	for i = 1, #cpuTable do
		addonCPU = GetAddOnCPUUsage(cpuTable[i][1])
		cpuTable[i][3] = addonCPU
		totalCPU = totalCPU + addonCPU
	end

	-- Sort the table to put the largest addon on top
	table_sort(cpuTable, sortByMemoryOrCPU)

	return totalCPU
end

local function Click()
	collectgarbage("collect");
	ResetCPUUsage();
end

local function OnEnter(self)
	enteredFrame = true
	local cpuProfiling = GetCVar("scriptProfile") == "1"
	local anchor, panel, xoff, yoff = "ANCHOR_BOTTOMLEFT", self:GetParent(), 0, 5
	GameTooltip:SetOwner(self, anchor, xoff, yoff)
	GameTooltip:ClearLines()

	UpdateMemory()
	bandwidth = GetAvailableBandwidth()

	GameTooltip:AddDoubleLine(L.DataText.HomeLatency, string_format(homeLatencyString, select(3, GetNetStats())), 0.69, 0.31, 0.31,0.84, 0.75, 0.65)

	if bandwidth ~= 0 then
		GameTooltip:AddDoubleLine(L.DataText.Bandwidth, string_format(bandwidthString, bandwidth),0.69, 0.31, 0.31,0.84, 0.75, 0.65)
		GameTooltip:AddDoubleLine(L.DataText.Download, string_format(percentageString, GetDownloadedPercentage() *100),0.69, 0.31, 0.31, 0.84, 0.75, 0.65)
		GameTooltip:AddLine(" ")
	end

	local totalCPU = nil
	GameTooltip:AddDoubleLine(L.DataText.TotalMemory, formatMem(totalMemory), 0.69, 0.31, 0.31,0.84, 0.75, 0.65)
	if cpuProfiling then
		totalCPU = UpdateCPU()
		GameTooltip:AddDoubleLine(L.DataText.TotalCPU, string_format(homeLatencyString, totalCPU), 0.69, 0.31, 0.31,0.84, 0.75, 0.65)
	end

	local red, green
	if IsShiftKeyDown() or not cpuProfiling then
		GameTooltip:AddLine(" ")
		for i = 1, #memoryTable do
			if (memoryTable[i][4]) then
				red = memoryTable[i][3] / totalMemory
				green = 1 - red
				GameTooltip:AddDoubleLine(memoryTable[i][2], formatMem(memoryTable[i][3]), 1, 1, 1, red, green + .5, 0)
			end
		end
	end

	if cpuProfiling and not IsShiftKeyDown() then
		GameTooltip:AddLine(" ")
		for i = 1, #cpuTable do
			if (cpuTable[i][4]) then
				red = cpuTable[i][3] / totalCPU
				green = 1 - red
				GameTooltip:AddDoubleLine(cpuTable[i][2], string_format(homeLatencyString, cpuTable[i][3]), 1, 1, 1, red, green + .5, 0)
			end
		end
		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(L.DataText.MemoryUsage)
	end

	GameTooltip:Show()
end

local function OnLeave()
	enteredFrame = false
	GameTooltip:Hide()
end

local function Update(self, t)
	int = int - t
	int2 = int2 - t

	if int < 0 then
		RebuildAddonList()
		int = 10
	end
	if int2 < 0 then
		local framerate = math_floor(GetFramerate())
		local latency = select(4, GetNetStats())

		Text:SetFormattedText("%s %s %s %s", ValueColor .. framerate .. "|r", NameColor .. "FPS &" .. "|r", ValueColor .. latency .. "|r", NameColor .. "MS" .. "|r")
		int2 = 1

		self:SetAllPoints(Text)

		if enteredFrame then
			OnEnter(self)
		end
	end
end

-- Command to toggle, cpuProfiling.
SlashCmdList.CPUPROFILING = function(msg)
	if msg == "on" or msg == "1" or msg == "true" then
		K.LockCVar("scriptProfile", 1)
		K.Print("cpuProfiling is now activated.")
	elseif msg == "off" or msg == "0" or msg == "false" then
		K.LockCVar("scriptProfile", 0)
		K.Print("cpuProfiling is now deactivated.")
	end
end
SLASH_CPUPROFILING1 = "/cpuprofile"

DataTextSystem:SetScript("OnMouseDown", Click)
DataTextSystem:SetScript("OnUpdate", Update)
DataTextSystem:SetScript("OnEnter", OnEnter)
DataTextSystem:SetScript("OnLeave", OnLeave)
Update(DataTextSystem, 10)