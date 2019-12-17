local K, C = unpack(select(2, ...))
local Module = K:GetModule("Blizzard")

local _G = _G
local unpack = _G.unpack

local CooldownFrame_Set = _G.CooldownFrame_Set
local CreateFrame = _G.CreateFrame
local GetTotemInfo = _G.GetTotemInfo
local MAX_TOTEMS = _G.MAX_TOTEMS

function Module:Update()
	for i=1, MAX_TOTEMS do
		local button = _G["TotemFrameTotem"..i]
		local _, _, startTime, duration, icon = GetTotemInfo(button.slot)

		if button:IsShown() then
			Module.bar[i]:Show()
			Module.bar[i].iconTexture:SetTexture(icon)
			CooldownFrame_Set(Module.bar[i].cooldown, startTime, duration, 1)

			button:ClearAllPoints()
			button:SetParent(Module.bar[i].holder)
			button:SetAllPoints(Module.bar[i].holder)
		else
			Module.bar[i]:Hide()
		end
	end
end

function Module:PositionAndSize()
	if not C["Unitframe"].TotemBar then
		return
	end

	local buttonSpacing = 6
	local buttonSize = C["ActionBar"].ButtonSize or 34

	for i = 1, MAX_TOTEMS do
		local button = self.bar[i]
		local prevButton = self.bar[i-1]
		button:SetSize(buttonSize, buttonSize)
		button:ClearAllPoints()
		if i == 1 then
			button:SetPoint("LEFT", self.bar, "LEFT", buttonSpacing, 0)
		elseif prevButton then
			button:SetPoint("LEFT", prevButton, "RIGHT", buttonSpacing, 0)
		end
	end

	self.bar:SetWidth(buttonSize * (MAX_TOTEMS) + buttonSpacing * (MAX_TOTEMS) + buttonSpacing)
	self.bar:SetHeight(buttonSize + buttonSpacing * 2)

	self:Update()
end

function Module:CreateTotemBar()
	if not C["Unitframe"].TotemBar then
		return
	end

	local bar = CreateFrame("Frame", "KKUI_TotemBar", UIParent)
	bar:SetPoint("CENTER", -316, -126)
	self.bar = bar

	for i=1, MAX_TOTEMS do
		local frame = CreateFrame("Button", bar:GetName().."Totem"..i, bar)
		frame:SetID(i)
		frame:CreateBorder()
		frame:CreateInnerShadow()
		frame:StyleButton()
        frame:Hide()

		frame.holder = CreateFrame("Frame", nil, frame)
		frame.holder:SetAlpha(0)
		frame.holder:SetAllPoints()

		frame.iconTexture = frame:CreateTexture(nil, "ARTWORK")
		frame.iconTexture:SetTexCoord(unpack(K.TexCoords))
		frame.iconTexture:SetInside()

		frame.cooldown = CreateFrame("Cooldown", frame:GetName().."Cooldown", frame, "CooldownFrameTemplate")
		frame.cooldown:SetReverse(true)
		frame.cooldown:SetAllPoints(frame)
		self.bar[i] = frame
	end

	self:PositionAndSize()

	K:RegisterEvent("PLAYER_TOTEM_UPDATE", self.Update)
	K:RegisterEvent("PLAYER_ENTERING_WORLD", self.Update)

	K.Mover(bar, "TotemBar", "TotemBar", {"CENTER", -316, -126})
end