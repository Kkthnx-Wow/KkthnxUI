local K, C, L = unpack(select(2, ...))

local floor = math.floor
local GetPlayerMapPosition = GetPlayerMapPosition
local ToggleFrame = ToggleFrame

local DataText = K.DataTexts
local NameColor = DataText.NameColor
local ValueColor = DataText.ValueColor

local x, y = 0, 0
local timeSinceUpdate

local OnMouseDown = function()
	ToggleFrame(WorldMapFrame)
end

local OnUpdate = function(self, elapsed)
	timeSinceUpdate = (timeSinceUpdate or 0) + elapsed

	if (timeSinceUpdate > 0.1) then
		x, y = GetPlayerMapPosition("player")

		if not GetPlayerMapPosition("player") then
			x = 0
			y = 0
		end

		x = floor(100 * x, 1)
		y = floor(100 * y, 1)

		self.Text:SetFormattedText("%s: %s", L.DataText.Coords, ValueColor .. x .. ", " .. y .. "|r")
		timeSinceUpdate = 0
	end
end

local Enable = function(self)
	if (not self.Text) then
		local Text = self:CreateFontString(nil, "OVERLAY")
		Text:SetFont(DataText.Font, DataText.Size, DataText.Flags)

		self.Text = Text
	end

	self:SetScript("OnMouseDown", OnMouseDown)
	self:SetScript("OnUpdate", OnUpdate)
end

local Disable = function(self)
	self.Text:SetText("")
	self:UnregisterAllEvents()

	self:SetScript("OnMouseDown", nil)
	self:SetScript("OnUpdate", nil)
end

DataText:Register(L.DataText.Coords, Enable, Disable, OnUpdate)
