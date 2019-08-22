local K = unpack(select(2, ...))

-- Smoothy
local smoothing = {}
local f = CreateFrame("Frame")
f:SetScript("OnUpdate", function()
	local limit = 30 / GetFramerate()
	for bar, value in pairs(smoothing) do
		local cur = bar:GetValue()
		local new = cur + min((value-cur) / 8, max(value-cur, limit))
		if new ~= new then
			new = value
		end
		bar:SetValue_(new)
		if cur == value or abs(new - value) < 1 then
			smoothing[bar] = nil
			bar:SetValue_(value)
		end
	end
end)

local function SetSmoothValue(self, value)
	if value ~= self:GetValue() or value == 0 then
		smoothing[self] = value
	else
		smoothing[self] = nil
	end
end

function K:SmoothBar()
	if not self.SetValue_ then
		self.SetValue_ = self.SetValue
		self.SetValue = SetSmoothValue
	end
end