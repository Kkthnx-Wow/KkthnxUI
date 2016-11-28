local K, C, L = select(2, ...):unpack()

local DataText = K.DataTexts
local NameColor = DataText.NameColor
local ValueColor = DataText.ValueColor

local format = string.format

local int = 1
local MemoryTable = {}
local KilobyteString = "%d ".. DataText.ValueColor .."kb".."|r"
local MegabyteString = "%.2f ".. DataText.ValueColor .."mb".."|r"
local Mult = 10^1
local BandwidthString = "%.2f Mbps"
local PercentageString = "%.2f%%"

local function FormatMemory(memory)
	if(memory > 999) then
		local Memory = ((memory / 1024) * Mult) / Mult
		return format(MegabyteString, Memory)
	else
		local Memory = (memory * Mult) / Mult
		return format(KilobyteString, Memory)
	end
end

local function UpdateMemory()
	UpdateAddOnMemoryUsage()

	local AddOnMem = 0
	local TotalMem = 0

	for i = 1, #MemoryTable do
		AddOnMem = GetAddOnMemoryUsage(MemoryTable[i][1])
		MemoryTable[i][3] = AddOnMem
		TotalMem = TotalMem + AddOnMem
	end

	table.sort(MemoryTable, function(a, b)
		if(a and b) then
			return a[3] > b[3]
		end
	end)

	return TotalMem
end

local function RebuildAddonList(self)
	local AddOnCount = GetNumAddOns()
	if(AddOnCount == #MemoryTable) or self.tooltip then
		return
	end

	MemoryTable = {}

	for i = 1, AddOnCount do
		local Title = select(2, GetAddOnInfo(i))
		MemoryTable[i] = { i, Title, 0, IsAddOnLoaded(i) }
	end
end

local function OnEnter(self)
	if(InCombatLockdown()) then
		return
	end

	GameTooltip:SetOwner(self:GetTooltipAnchor())
	GameTooltip:ClearLines()
	GameTooltip:AddLine(L.DataText.System)
	GameTooltip:AddLine(" ")

	local Bandwidth = GetAvailableBandwidth()
	if(Bandwidth ~= 0) then
		GameTooltip:AddDoubleLine(NameColor .. L.DataText.Bandwidth .. "|r", format(ValueColor .. BandwidthString .. "|r", Bandwidth))
		GameTooltip:AddDoubleLine(NameColor .. L.DataText.Bandwidth .. "|r", format(ValueColor .. PercentageString .. "|r", GetDownloadedPercentage() * 100))
		GameTooltip:AddLine(" ")
	end

	local TotalMemory = UpdateMemory()
	GameTooltip:AddDoubleLine(L.DataText.TotalMemoryUsage, FormatMemory(TotalMemory), 0.69, 0.31, 0.31, 0.84, 0.75, 0.65)
	GameTooltip:AddLine("")

	for i = 1, #MemoryTable do
		if(MemoryTable[i][4]) then
			local Red = MemoryTable[i][3] / TotalMemory
			local Green = 1 - Red

			GameTooltip:AddDoubleLine(MemoryTable[i][2], FormatMemory(MemoryTable[i][3]), 1, 1, 1, Red, Green + 0.5, 0)
		end
	end

	self.Text:SetText(DataText.ValueColor .. FormatMemory(TotalMemory) .. "|r")
	GameTooltip:Show()
end

local function OnMouseUp()
	collectgarbage("collect")
end

local function Update(self, second)
	int = int - second

	if(int < 0) then
		RebuildAddonList(self)
		local Total = UpdateMemory()

		self.Text:SetText(DataText.ValueColor .. FormatMemory(Total) .. "|r")
		int = 10
	end
end

local function Enable(self)
	if(not self.Text) then
		local Text = self:CreateFontString(nil, "OVERLAY")
		Text:SetFont(DataText.Font, DataText.Size, DataText.Flags)

		self.Text = Text
	end

	self:SetScript("OnUpdate", Update)
	self:SetScript("OnEnter", OnEnter)
	self:SetScript("OnLeave", GameTooltip_Hide)
	self:SetScript("OnMouseUp", OnMouseUp)
	self:Update(1)
end

local function Disable(self)
	self.Text:SetText("")
	self:SetScript("OnUpdate", nil)
	self:SetScript("OnEnter", nil)
	self:SetScript("OnLeave", nil)
	self:SetScript("OnMouseUp", nil)
end

DataText:Register(L.DataText.Memory, Enable, Disable, Update)