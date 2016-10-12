local K, C, L = select(2, ...):unpack()
if C.Stats.System ~= true then return end

local format = format
local int = 1
local int2 = 2
local MemoryTable = {}
local KilobyteString, MegabyteString
local Mult = 10^1
local bandwidthString = "%.2f Mbps"
local percentageString = "%.2f%%"

local SystemDT = CreateFrame("Frame")

local MemoryColor = K.RGBToHex(1, 1, 1)
local KilobyteString = "%d ".. MemoryColor .."kb".."|r"
local MegabyteString = "%.2f ".. MemoryColor .."mb".."|r"
local StatColor = K.RGBToHex(1, 1, 1)
local StatClassColor = K.RGBToHex(K.Color.r, K.Color.g, K.Color.b)
local Movers = K.Movers

local Text = KkthnxUIMinimapStats:CreateFontString(nil, "OVERLAY")
Text:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
Text:SetPoint(unpack(C.Position.SystemDT))

-- Format Memory
local FormatMemory = function(memory)
	if (memory > 999) then
		local Memory = ((memory/1024) * Mult) / Mult
		return string.format(MegabyteString, Memory)
	else
		local Memory = (memory * Mult) / Mult
		return string.format(KilobyteString, Memory)
	end
end

-- Build MemoryTable
local RebuildAddonList = function(self)
	local AddOnCount = GetNumAddOns()
	if (AddOnCount == #MemoryTable) or self.tooltip then
		return
	end

	wipe(MemoryTable)

	for i = 1, AddOnCount do
		MemoryTable[i] = {i, select(2, GetAddOnInfo(i)), 0, IsAddOnLoaded(i)}
	end
end

-- Update MemoryTable
local UpdateMemory = function()
	-- Update the memory usages of the addons
	UpdateAddOnMemoryUsage()
	local AddOnMem = 0
	local TotalMem = 0

	for i = 1, #MemoryTable do
		AddOnMem = GetAddOnMemoryUsage(MemoryTable[i][1])
		MemoryTable[i][3] = AddOnMem
		TotalMem = TotalMem + AddOnMem
	end
	-- Sort the table to put the largest addon on top
	table.sort(MemoryTable, function(a, b)
		if (a and b) then
			return a[3] > b[3]
		end
	end)

	return TotalMem
end

-- Build DataText
local Update = function(self, second)
	int = int - second

	if (int < 0) then
		RebuildAddonList(self)
		int = 10
	end

	int2 = int2 - second
	if (int2 < 0) then

		local MS = select(3, GetNetStats())
		local Rate = floor(GetFramerate())

		if (MS == 0) then
			MS = "0"
		end

		Text:SetFormattedText("%s %s %s %s", StatColor .. Rate .. "|r", StatClassColor .. L_DATATEXT_FPS .. "|r", "& " .. StatColor .. MS .. "|r", StatClassColor .. L_DATATEXT_MS .. "|r")
		int2 = 2

		self:SetAllPoints(Text)
	end
end

-- Tooltip
local OnEnter = function(self)
	if (not InCombatLockdown()) then

		GameTooltip:ClearLines()
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 0, 5)

		local Bandwidth = GetAvailableBandwidth()

		local TotalMemory = UpdateMemory()
		GameTooltip:AddDoubleLine(L_DATATEXT_TOTALMEMORY, FormatMemory(TotalMemory), 0.69, 0.31, 0.31,0.84, 0.75, 0.65)
		GameTooltip:AddLine(" ")

		for i = 1, #MemoryTable do
			if (MemoryTable[i][4]) then
				local Red = MemoryTable[i][3] / TotalMemory
				local Green = 1 - Red

				GameTooltip:AddDoubleLine(MemoryTable[i][2], FormatMemory(MemoryTable[i][3]), 1, 1, 1, Red, Green + .5, 0)
			end
		end

		GameTooltip:AddLine(" ")
		if (Bandwidth ~= 0) then
			GameTooltip:AddDoubleLine(L_DATATEXT_BANDWIDTH , string.format(bandwidthString, Bandwidth),0.69, 0.31, 0.31,0.84, 0.75, 0.65)
			GameTooltip:AddDoubleLine(L_DATATEXT_DOWNLOAD , string.format(percentageString, GetDownloadedPercentage() * 100), 0.69, 0.31, 0.31, 0.84, 0.75, 0.65)
			GameTooltip:AddLine(" ")
		end

		local _, _, HomeLatency, WorldLatency = GetNetStats()
		local Latency = format(MAINMENUBAR_LATENCY_LABEL, HomeLatency, WorldLatency)

		GameTooltip:AddLine(Latency)
		GameTooltip:Show()
	end
end

local OnLeave = function()
	GameTooltip:Hide()
end

local OnMouseUp = function()
	collectgarbage("collect")
	-- print(OnMouseUp, collectgarbage)
end

local ResetData = function(self, event)
	wipe(MemoryTable)
end

SystemDT:SetScript("OnEvent", ResetData)
SystemDT:SetScript("OnUpdate", Update)
SystemDT:SetScript("OnEnter", OnEnter)
SystemDT:SetScript("OnLeave", OnLeave)
SystemDT:SetScript("OnMouseUp", OnMouseUp)
Update(SystemDT, 10)