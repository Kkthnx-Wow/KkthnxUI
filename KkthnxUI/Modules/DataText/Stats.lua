local K, C, L, _ = select(2, ...):unpack()

local Stat = CreateFrame("Frame")
Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
Stat:SetFrameStrata("BACKGROUND")
Stat:SetFrameLevel(3)
Stat:EnableMouse(true)
Stat.tooltip = false
local scolor1 = K.RGBToHex(.4, .4, .4)
local scolor2 = K.RGBToHex(1, 1, 1)

local StatFrame = CreateFrame("Frame", "StatFrame", Minimap)
if C.Minimap.Enable == true then
	StatFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
	StatFrame:CreateBackdrop()
	if C.Blizzard.ColorTextures == true then
		StatFrame.backdrop:SetBackdropBorderColor(unpack(C.Blizzard.TexturesColor))
	end
	StatFrame:SetSize(0, 20)
<<<<<<< HEAD

=======
 
>>>>>>> origin/master
 	if C.Minimap.Invert then
		StatFrame:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -2, 24)
		StatFrame:SetPoint("TOPRIGHT", Minimap, 2, 24)
 	else
		StatFrame:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", -2, -24)
		StatFrame:SetPoint("BOTTOMRIGHT", Minimap, 2, -24)
 	end
<<<<<<< HEAD

=======
 	
>>>>>>> origin/master
	StatFrame:SetFrameLevel(Minimap:GetFrameLevel() + 3)
	StatFrame:SetFrameStrata(Minimap:GetFrameStrata())
else
	StatFrame:SetSize(0, 20)
	StatFrame:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", 0, -34)
	StatFrame:SetFrameLevel(Minimap:GetFrameLevel() + 3)
	StatFrame:SetFrameStrata(Minimap:GetFrameStrata())
	StatFrame:SetPoint("BOTTOMRIGHT", Minimap, 0, -34)
end

local Text = StatFrame:CreateFontString(nil, "OVERLAY")
Text:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
Text:SetPoint(unpack(C.Position.StatsFrame))

-- FORMAT MEMORY
local bandwidthString = "%.2f Mbps"
local percentageString = "%.2f%%"
local kiloByteString = "%d kb"
local megaByteString = "%.2f mb"
local function formatMem(memory)
	local mult = 10^1
	if memory > 999 then
		local mem = ((memory / 1024) * mult) / mult
		return string.format(megaByteString, mem)
	else
		local mem = (memory * mult) / mult
		return string.format(kiloByteString, mem)
	end
end

-- BUILD MEMORYTABLE
local memoryTable = {}
local function RebuildAddonList(self)
	local addOnCount = GetNumAddOns()
	if (addOnCount == #memoryTable) or self.tooltip == true then return end

	memoryTable = {}
	for i = 1, addOnCount do memoryTable[i] = {i, select(2, GetAddOnInfo(i)), 0, IsAddOnLoaded(i)} end
	self:SetAllPoints(Text)
end

-- UPDATE MEMORYTABLE
local function UpdateMemory()
	UpdateAddOnMemoryUsage()
	local addOnMem = 0
	local totalMemory = 0
	for i = 1, #memoryTable do
		addOnMem = GetAddOnMemoryUsage(memoryTable[i][1])
		memoryTable[i][3] = addOnMem
		totalMemory = totalMemory + addOnMem
	end
	table.sort(memoryTable, function(a, b)
		if a and b then return a[3] > b[3] end
	end)
	return totalMemory
end

-- BUILD DATATEXT
local int, int2 = 10, 2
local function Update(self, t)
	int = int - t
	int2 = int2 - t
	if int < 0 then
		RebuildAddonList(self)
		int = 10
	end
	if int2 < 0 then
		Text:SetText(floor(GetFramerate())..K.RGBToHex(K.Color.r, K.Color.g, K.Color.b).." fps|r & "..select(3, GetNetStats())..K.RGBToHex(K.Color.r, K.Color.g, K.Color.b).." ms|r")
		int2 = 2
	end
end

-- SETUP TOOLTIP
Stat:SetScript("OnEnter", function(self)
	if InCombatLockdown() then return end

	self.tooltip = true
	local bandwidth = GetAvailableBandwidth()
	local anchor, panel, xoff, yoff = "ANCHOR_BOTTOMLEFT", self:GetParent(), 0, 5
	local bw_in, bw_out, latencyHome, latencyWorld = GetNetStats()
	ms_combined = latencyHome + latencyWorld
	GameTooltip:SetOwner(self, anchor, xoff, yoff)
	GameTooltip:ClearLines()
	local totalMemory = UpdateMemory()
	GameTooltip:AddDoubleLine(L_TOTALMEMORY_USAGE, formatMem(totalMemory), 46/255, 182/255, 255/255, .84, .75, .65)
	GameTooltip:AddLine(" ")
	for i = 1, #memoryTable do
		if (memoryTable[i][4]) then
			local red = memoryTable[i][3] / totalMemory
			local green = 1 - red
			GameTooltip:AddDoubleLine(memoryTable[i][2], formatMem(memoryTable[i][3]), 1, 1, 1, red, green + .5, 0)
		end
	end
	GameTooltip:AddLine(" ")
	if bandwidth ~= 0 then
		GameTooltip:AddDoubleLine(L_STATS_BANDWIDTH, string.format(bandwidthString, bandwidth),  46/255, 182/255, 255/255, .84, .75, .65)
		GameTooltip:AddDoubleLine(L_STATS_DOWNLOAD, string.format(percentageString, GetDownloadedPercentage() * 100),  46/255, 182/255, 255/255, .84, .75, .65)
		GameTooltip:AddLine(" ")
	end
	GameTooltip:AddDoubleLine(L_STATS_HOME, latencyHome.." "..MILLISECONDS_ABBR,  46/255, 182/255, 255/255, .84, .75, .65)
	GameTooltip:AddDoubleLine(L_STATS_WORLD, latencyWorld.." "..MILLISECONDS_ABBR,  46/255, 182/255, 255/255, .84, .75, .65)
	GameTooltip:AddDoubleLine(L_STATS_GLOBAL, ms_combined.." "..MILLISECONDS_ABBR,  46/255, 182/255, 255/255, .84, .75, .65)
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(L_STATS_INC, string.format("%.4f", bw_in) .. " kb/s",  46/255, 182/255, 255/255, .84, .75, .65)
	GameTooltip:AddDoubleLine(L_STATS_OUT, string.format("%.4f", bw_out) .. " kb/s",  46/255, 182/255, 255/255, .84, .75, .65)

	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(L_STATS_SYSTEMLEFT)
	GameTooltip:AddLine(L_STATS_SYSTEMRIGHT)
	GameTooltip:Show()
end)

-- BUTTON FUNCTIONALITY
Stat:SetScript("OnMouseDown", function(self, btn)
	if (btn == "LeftButton") then
		if not PVEFrame then PVEFrame_ToggleFrame() end
		PVEFrame_ToggleFrame()
	else
		collectgarbage("collect")
	end
end)
Stat:SetScript("OnLeave", function(self) self.tooltip = false GameTooltip:Hide() end)
Stat:SetScript("OnUpdate", Update)
Update(Stat, 10)