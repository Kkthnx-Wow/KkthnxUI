-- local K, C = unpack(select(2, ...))
-- local Module = K:NewModule("TotemsBar", "AceEvent-3.0", "AceTimer-3.0")

-- local _G = _G

-- local CreateFrame = _G.CreateFrame
-- local GetTotemInfo = _G.GetTotemInfo
-- local CooldownFrame_Set = _G.CooldownFrame_Set
-- local MAX_TOTEMS = _G.MAX_TOTEMS

-- function Module:Update()
-- 	local _, button, startTime, duration, icon

-- 	for i = 1, MAX_TOTEMS do
-- 		button = _G["TotemFrameTotem"..i]
-- 		_, _, startTime, duration, icon = GetTotemInfo(button.slot)

-- 		if button:IsShown() then
-- 			self.bar[i]:Show()
-- 			self.bar[i].iconTexture:SetTexture(icon)

-- 			CooldownFrame_Set(self.bar[i].cooldown, startTime, duration, 1)

-- 			button:ClearAllPoints()
-- 			button:SetParent(self.bar[i].holder)
-- 			button:SetAllPoints(self.bar[i].holder)
-- 		else
-- 			self.bar[i]:Hide()
-- 		end
-- 	end
-- end

-- function Module:ToggleEnable()
-- 	if C["Unitframe"].TotemBar then
-- 		self.bar:Show()

-- 		K:RegisterEvent("PLAYER_TOTEM_UPDATE", self.Update)
-- 		K:RegisterEvent("PLAYER_ENTERING_WORLD", self.Update)

-- 		self:Update()
-- 	else
-- 		self.bar:Hide()

-- 		K:UnregisterEvent("PLAYER_TOTEM_UPDATE", self.Update)
-- 		K:UnregisterEvent("PLAYER_ENTERING_WORLD", self.Update)
-- 	end
-- end

-- function Module:PositionAndSize()
-- 	local buttonSpacing = 6
-- 	local buttonSize = C["ActionBar"].ButtonSize or 34

-- 	for i = 1, MAX_TOTEMS do
-- 		local button = self.bar[i]
-- 		local prevButton = self.bar[i-1]
-- 		button:SetSize(buttonSize, buttonSize)
-- 		button:ClearAllPoints()

-- 		if i == 1 then
-- 			button:SetPoint("LEFT", self.bar, "LEFT", buttonSpacing, 0)
-- 		elseif prevButton then
-- 			button:SetPoint("LEFT", prevButton, "RIGHT", buttonSpacing, 0)
-- 		end
-- 	end

-- 	self.bar:SetWidth(buttonSize * (MAX_TOTEMS) + buttonSpacing * (MAX_TOTEMS) + buttonSpacing)
-- 	self.bar:SetHeight(buttonSize + buttonSpacing * 2)

-- 	self:Update()
-- end

-- function Module:OnEnable()
-- 	self.bar = CreateFrame("Frame", "KkthnxUI_TotemBar", _G.UIParent)
-- 	self.bar:SetPoint("CENTER", -316, -126)

-- 	for i = 1, MAX_TOTEMS do
-- 		local frame = CreateFrame("Button", self.bar:GetName().."Totem"..i, self.bar)
-- 		frame:SetID(i)
-- 		frame:CreateBorder()
-- 		frame:StyleButton()
-- 		frame:CreateInnerShadow()
-- 		frame:Hide()

-- 		frame.holder = CreateFrame("Frame", nil, frame)
-- 		frame.holder:SetAlpha(0)
-- 		frame.holder:SetAllPoints()

-- 		frame.iconTexture = frame:CreateTexture(nil, "ARTWORK")
-- 		frame.iconTexture:SetInside()
-- 		frame.iconTexture:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

-- 		frame.cooldown = CreateFrame("Cooldown", frame:GetName().."Cooldown", frame, "CooldownFrameTemplate")
-- 		frame.cooldown:SetReverse(true)
-- 		frame.cooldown:SetAllPoints(frame)

-- 		self.bar[i] = frame
-- 	end

-- 	self:PositionAndSize()

-- 	K.Mover(bar, "TotemBar", "TotemBar", {"CENTER", -316, -126})

-- 	self:ToggleEnable()
-- end