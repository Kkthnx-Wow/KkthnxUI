local K, C, L, _ = select(2, ...):unpack()

local Reputation = CreateFrame("Frame", nil, UIParent)
local HideTooltip = GameTooltip_Hide
local Bars = 20
local Colors = FACTION_BAR_COLORS

Reputation.NumBars = 2

function Reputation:SetTooltip()
	if (not GetWatchedFactionInfo()) then
		return
	end

	local Name, ID, Min, Max, Value = GetWatchedFactionInfo()

	if (self == Reputation.RepBar1) then
		GameTooltip:SetOwner(self, "ANCHOR_LEFT", 0, -5)
	else
		GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", 0, 5)
	end

	GameTooltip:AddLine(string.format("%s (%s)", Name, _G["FACTION_STANDING_LABEL" .. ID]))
	GameTooltip:AddLine(string.format("%d / %d (%d%%)", Value - Min, Max - Min, (Value - Min) / (Max - Min) * 100))
	GameTooltip:Show()
end

function Reputation:Update()
	if GetWatchedFactionInfo() then
		self:Enable()
	else
		self:Disable()

		return
	end

	local Name, ID, Min, Max, Value = GetWatchedFactionInfo()

	for i = 1, self.NumBars do
		self["RepBar"..i]:SetMinMaxValues(Min, Max)
		self["RepBar"..i]:SetValue(Value)
		self["RepBar"..i]:SetStatusBarColor(Colors[ID].r, Colors[ID].g, Colors[ID].b)
	end
end

function Reputation:Create()
	for i = 1, self.NumBars do
		local RepBar = CreateFrame("StatusBar", nil, UIParent)

		RepBar:SetStatusBarTexture(C.Media.Texture)
		RepBar:EnableMouse()
		RepBar:SetFrameStrata("BACKGROUND")
		RepBar:SetFrameLevel(3)
		--RepBar:CreateBackdrop()
		RepBar:SetScript("OnEnter", Reputation.SetTooltip)
		RepBar:SetScript("OnLeave", HideTooltip)

		RepBar:CreatePixelShadow(2)
		RepBar:SetBackdrop(K.BorderBackdrop)
		RepBar:SetBackdropColor(unpack(C.Media.Backdrop_Color))

		RepBar:SetSize(Minimap:GetWidth() - 4, 8)
		RepBar:SetPoint("TOPLEFT", Minimap, "BOTTOMLEFT", -1, -36)
		RepBar:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", 1, -36)

		self["RepBar"..i] = RepBar
	end

	self:RegisterEvent("UPDATE_FACTION")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")

	self:SetScript("OnEvent", self.Update)
end

function Reputation:Enable()
	if not self.IsCreated then
		self:Create()

		self.IsCreated = true
	end

	for i = 1, self.NumBars do
		if not self["RepBar"..i]:IsShown() then
			self["RepBar"..i]:Show()
		end
	end
end

function Reputation:Disable()
	for i = 1, self.NumBars do
		if self["RepBar"..i]:IsShown() then
			self["RepBar"..i]:Hide()
		end
	end
end

Reputation:Enable()