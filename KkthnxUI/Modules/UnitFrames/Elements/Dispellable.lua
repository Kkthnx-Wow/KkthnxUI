local K, C = unpack(select(2, ...))
local Module = K:GetModule("Unitframes")

local function UpdateTimer(button, elapsed)
	local timeLeft = button.timeLeft - elapsed
	button.timer:SetText((timeLeft > 0) and K.FormatTime(timeLeft))
	button.timeLeft = timeLeft
end

local function PostUpdateDispel(dispel, _, _, _, duration, expiration)
	local button = dispel.dispelIcon
	if (duration and duration > 0) then
		button.timeLeft = expiration - GetTime()
		button:SetScript("OnUpdate", UpdateTimer)
	else
		button:SetScript("OnUpdate", nil)
		button.timer:SetText()
	end
end

function Module.CreateDispel(self, unit)
	local dispellable = {}

	local texture = self.Health:CreateTexture(nil, "OVERLAY")
	texture:SetTexture(C["Media"].Mouseover)
	texture:SetBlendMode("ADD")
	texture:SetVertexColor(1, 1, 1, 0) -- hide in case the class cannot dispel
	texture:SetAllPoints()
	dispellable.dispelTexture = texture

	if (unit == "target" or unit == "party") then
		local button = CreateFrame("Button", "oUF_DispelButton", self.Health)
		button:SetPoint("CENTER")
		button:SetSize(22, 22)
		button:SetToplevel(true)
		button:CreateBorder()

		local icon = button:CreateTexture(nil, "ARTWORK")
		icon:SetAllPoints()
		icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		button.icon = icon

		local timer = button:CreateFontString(nil, "OVERLAY", "KkthnxUIFontOutline", 1)
		timer:SetPoint("TOPLEFT", 1, 1)
		button.timer = timer

		local count = button:CreateFontString(nil, "OVERLAY", "KkthnxUIFontOutline", 1)
		count:SetPoint("BOTTOMRIGHT", -1, 1)
		button.count = count

		button:Hide() -- hide in case the class cannot dispel
		dispellable.dispelIcon = button
		dispellable.PostUpdate = PostUpdateDispel
	end

	self.Dispellable = dispellable
end