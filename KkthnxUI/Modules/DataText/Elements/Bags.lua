local K, C, L = select(2, ...):unpack()

local NUM_BAG_SLOTS = NUM_BAG_SLOTS
local GetContainerNumFreeSlots = GetContainerNumFreeSlots
local GetContainerNumSlots = GetContainerNumSlots
local ToggleAllBags = ToggleAllBags

local DataText = K.DataTexts
local NameColor = DataText.NameColor
local ValueColor = DataText.ValueColor

local OnEnter = function(self)
	if (InCombatLockdown()) then
		return
	end

	GameTooltip:SetOwner(self:GetTooltipAnchor())
	GameTooltip:ClearLines()
	GameTooltip:AddLine(BAGSLOTTEXT)
	GameTooltip:AddLine(" ")

	local Free, Total, Used = 0, 0, 0

	for i = 0, NUM_BAG_SLOTS do
		Free, Total = Free + GetContainerNumFreeSlots(i), Total + GetContainerNumSlots(i)
	end

	Used = Total - Free

	GameTooltip:AddDoubleLine(NameColor .. L.DataText.TotalBagSlots .. "|r", ValueColor .. Total .. "|r")
	GameTooltip:AddDoubleLine(NameColor .. L.DataText.TotalUsedBagSlots .. "|r", ValueColor .. Used .. "|r")
	GameTooltip:AddDoubleLine(NameColor .. L.DataText.TotalFreeBagSlots .. "|r", ValueColor .. Free .. "|r")

	GameTooltip:Show()
end

local OnMouseDown = function(self, btn)
	if (btn ~= "LeftButton") then
		return
	end

	ToggleAllBags()
end

local Update = function(self)
	local Free, Total, Used = 0, 0, 0

	for i = 0, NUM_BAG_SLOTS do
		Free, Total = Free + GetContainerNumFreeSlots(i), Total + GetContainerNumSlots(i)
	end

	Used = Total - Free

	self.Text:SetFormattedText("%s: %s/%s", NameColor .. L.DataText.Bags .. "|r", ValueColor .. Used, Total .. "|r")
end

local Enable = function(self)
	if (not self.Text) then
		local Text = self:CreateFontString(nil, "OVERLAY")
		Text:SetFont(DataText.Font, DataText.Size, DataText.Flags)

		self.Text = Text
	end

	self:RegisterEvent("BAG_UPDATE")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:SetScript("OnEvent", Update)
	self:SetScript("OnEnter", OnEnter)
	self:SetScript("OnLeave", GameTooltip_Hide)
	self:SetScript("OnMouseDown", OnMouseDown)
	self:Update()
end

local Disable = function(self)
	self.Text:SetText("")
	self:UnregisterAllEvents()
	self:SetScript("OnEvent", nil)
	self:SetScript("OnEnter", nil)
	self:SetScript("OnLeave", nil)
	self:SetScript("OnMouseDown", nil)
end

DataText:Register("Bags", Enable, Disable, Update)