local K, C, L, _ = select(2, ...):unpack()

local unpack = unpack
local select = select
local floor = math.floor
local collectgarbage = collectgarbage
local print = print
local format = string.format
local sort = table.sort
local GetNumAddOns, GetAddOnInfo, GetAddOnMemoryUsage = GetNumAddOns, GetAddOnInfo, GetAddOnMemoryUsage
local CreateFrame = CreateFrame
local IsAddOnLoaded = IsAddOnLoaded
local GetFramerate = GetFramerate

local StatFrame = CreateFrame("Frame", "StatFrame", Minimap)
StatFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
StatFrame:CreateBackdrop()
StatFrame:SetSize(0, 20)
StatFrame:SetPoint("BOTTOMLEFT", Minimap, "BOTTOMLEFT", -2, -24)
StatFrame:SetFrameLevel(Minimap:GetFrameLevel() + 3)
StatFrame:SetFrameStrata(Minimap:GetFrameStrata())
StatFrame:SetPoint("BOTTOMRIGHT", Minimap, 2, -24)

local Stat = CreateFrame("Frame", "StatSystem", UIParent)
Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
Stat:SetFrameStrata("BACKGROUND")
Stat:SetFrameLevel(3)
Stat:EnableMouse(true)
Stat.tooltip = false

local Text = StatFrame:CreateFontString(nil, "OVERLAY")
Text:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
Text:SetPoint(unpack(C.Position.StatsFrame))

-- Format Memory
local kiloByteString = "%d kb"
local megaByteString = "%.2f mb"
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

-- Build Memorytable
local memoryTable = {}
local function RebuildAddonList(self)
	local addOnCount = GetNumAddOns()
	if (addOnCount == #memoryTable) or self.tooltip == true then return end

	-- Number of loaded addons changed, create new memoryTable for all addons
	memoryTable = {}
	for i = 1, addOnCount do
		memoryTable[i] = { i, select(2, GetAddOnInfo(i)), 0, IsAddOnLoaded(i) }
	end
	self:SetAllPoints(Text)
end

-- Update Memorytable
local function UpdateMemory()
	-- Update the memory usages of the addons
	UpdateAddOnMemoryUsage()
	-- Load memory usage in table
	local addOnMem = 0
	local totalMemory = 0
	for i = 1, #memoryTable do
		addOnMem = GetAddOnMemoryUsage(memoryTable[i][1])
		memoryTable[i][3] = addOnMem
		totalMemory = totalMemory + addOnMem
	end
	-- Sort the table to put the largest addon on top
	table.sort(memoryTable, function(a, b)
		if a and b then
			return a[3] > b[3]
		end
	end)

	return totalMemory
end

-- Build DataText
local int = 10

local function Update(self, t)
	int = int - t

	if int < 0 then
		RebuildAddonList(self)
		local total = UpdateMemory()
		Text:SetText(floor(GetFramerate())..K.RGBToHex(K.Color.r, K.Color.g, K.Color.b).." fps|r & "..select(3, GetNetStats())..K.RGBToHex(K.Color.r, K.Color.g, K.Color.b).." ms|r")
		int = 10
	end
end
-- Setup Tooltip
Stat:SetScript("OnMouseDown", function () collectgarbage("collect") Update(Stat, 20) end)
Stat:SetScript("OnEnter", function(self)
	if not InCombatLockdown() then
		self.tooltip = true
		local anchor, panel, xoff, yoff = "ANCHOR_BOTTOMLEFT", self:GetParent(), 0, 5
		local bw_in, bw_out, latencyHome = GetNetStats()
		ms_combined = latencyHome
		GameTooltip:SetOwner(self, anchor, xoff, yoff)
		GameTooltip:ClearLines()
		local totalMemory = UpdateMemory()
		GameTooltip:AddDoubleLine(L_TOTALMEMORY_USAGE, formatMem(totalMemory))
		GameTooltip:AddLine(" ")
		for i = 1, #memoryTable do
			if (memoryTable[i][4]) then
				local red = memoryTable[i][3] / totalMemory
				local green = 1 - red
				GameTooltip:AddDoubleLine(memoryTable[i][2], formatMem(memoryTable[i][3]))
			end
		end
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(L_STATS_HOME, latencyHome.." "..MILLISECONDS_ABBR)
		GameTooltip:AddDoubleLine(L_STATS_GLOBAL, ms_combined.." "..MILLISECONDS_ABBR)
		GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine(L_STATS_INC, format( "%.4f", bw_in ) .. " kb/s")
		GameTooltip:AddDoubleLine(L_STATS_OUT, format( "%.4f", bw_out ) .. " kb/s")

		GameTooltip:AddLine(" ")
		GameTooltip:AddLine(L_STATS_SYSTEMLEFT)
		GameTooltip:AddLine(L_STATS_SYSTEMRIGHT)
		GameTooltip:Show()
	end
end)

-- Button Functionality
Stat:SetScript("OnMouseDown", function(self, btn)
	if (btn == "LeftButton") then
		if not LFDQueueFrame then ToggleFrame(LFDParentFrame) end
		ToggleFrame(LFDParentFrame)
	else
		UpdateAddOnMemoryUsage()
		local Before = gcinfo()
		collectgarbage("collect")
		UpdateAddOnMemoryUsage()
		local After = gcinfo()
		K.Print(L_DATATEXT_MEMORY_CLEANED..formatMem(Before-After))
	end
end)
Stat:SetScript("OnLeave", function(self) self.tooltip = false GameTooltip:Hide() end)
Stat:SetScript("OnUpdate", Update)
Stat:SetScript("OnEvent", function(self, event) collectgarbage("collect") end)
Update(Stat, 20)