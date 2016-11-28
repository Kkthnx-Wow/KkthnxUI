local K, C, L = select(2, ...):unpack()

local InCombatLockdown = InCombatLockdown
local ToggleCharacter = ToggleCharacter

local format = string.format
local floor = math.floor
local sort = table.sort
local GetInventoryItemLink = GetInventoryItemLink
local GetInventoryItemDurability = GetInventoryItemDurability

local DataText = K.DataTexts
local NameColor = DataText.NameColor
local ValueColor = DataText.ValueColor

local OnMouseDown = function(self, btn)
	ToggleCharacter("PaperDollFrame")
end

local OnEnter = function(self)
	if (InCombatLockdown()) then
		return
	end

	GameTooltip:SetOwner(self:GetTooltipAnchor())
	GameTooltip:ClearLines()
	GameTooltip:AddLine(ARMOR)
	GameTooltip:AddLine(" ")

	for i = 1, 11 do
		if (L.DataText.Slots[i][3] ~= 1000) then
			local Green, Red

			Green = L.DataText.Slots[i][3] * 2
			Red = 1 - Green

			GameTooltip:AddDoubleLine(L.DataText.Slots[i][2], floor(L.DataText.Slots[i][3] * 100) .. "%", 1, 1, 1, Red + 1, Green, 0)
		end
	end

	GameTooltip:Show()
end

local OnEvent = function(self)
	local Total = 0
	local Current, Max

	for i = 1, 11 do
		if (GetInventoryItemLink("player", L.DataText.Slots[i][1]) ~= nil) then
			Current, Max = GetInventoryItemDurability(L.DataText.Slots[i][1])

			if (Current) then
				L.DataText.Slots[i][3] = Current / Max
				Total = Total + 1
			end
		end
	end

	sort(L.DataText.Slots, function(a, b)
		return a[3] < b[3]
	end)

	if (Total > 0) then
		self.Text:SetFormattedText("%s: %s%%", NameColor .. ARMOR .. "|r", ValueColor .. floor(L.DataText.Slots[1][3] * 100) .. "|r")
	else
		self.Text:SetFormattedText("%s: %s%%", NameColor .. ARMOR .. "|r", ValueColor .. "100" .. "|r")
	end

	Total = 0
end

local function Enable(self)
	if (not self.Text) then
		local Text = self:CreateFontString(nil, "OVERLAY")
		Text:SetFont(DataText.Font, DataText.Size, DataText.Flags)

		self.Text = Text
	end

	self:RegisterEvent("MERCHANT_SHOW")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("UPDATE_INVENTORY_DURABILITY")
	self:SetScript("OnEvent", OnEvent)
	self:SetScript("OnEnter", OnEnter)
	self:SetScript("OnLeave", GameTooltip_Hide)
	self:SetScript("OnMouseDown", OnMouseDown)
	self:Update()
end

local function Disable(self)
	self.Text:SetText("")
	self:UnregisterAllEvents()
	self:SetScript("OnEvent", nil)
	self:SetScript("OnEnter", nil)
	self:SetScript("OnLeave", nil)
	self:SetScript("OnMouseDown", nil)
end

DataText:Register(DURABILITY, Enable, Disable, OnEvent)