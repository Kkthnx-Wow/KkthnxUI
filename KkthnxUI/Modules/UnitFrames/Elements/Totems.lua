local K, C = unpack(select(2, ...))
if C["Unitframe"].Enable ~= true then
	return
end

local Module = K:GetModule("Unitframes")

function Module:CreateClassTotems(width, height, spacing)
	local UnitframeTexture = K.GetTexture(C["Unitframe"].Texture)

	local totems = {}
	local maxTotems = 5

	width = (width - (maxTotems + 1) * spacing) / maxTotems
	spacing = width + spacing

	for slot = 1, maxTotems do
		local totem = CreateFrame("StatusBar", nil, self)
		local color = K.Colors.totems[slot]
		local r, g, b = color[1], color[2], color[3]
		totem:SetStatusBarTexture(UnitframeTexture)
		totem:SetStatusBarColor(r, g, b)
		totem:SetSize(width, height)
		totem:SetPoint(K.Class == "SHAMAN" and "BOTTOMLEFT" or "BOTTOMLEFT", (slot - 1) * spacing + 4, -14)
		totem:EnableMouse(true)

		totem.Background = totem:CreateTexture(nil, "BACKGROUND", -1)
		totem.Background:SetAllPoints()
		totem.Background:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

		totem.Border = CreateFrame("Frame", nil, totem)
		totem.Border:SetAllPoints()
		K.CreateBorder(totem.Border)

		local icon = totem:CreateTexture(nil, "ARTWORK")
		icon:SetSize(width - 5, width - 5)
		icon:SetPoint("TOP", totem, "BOTTOM", 0, -6)
		icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		icon:Hide()
		totem.icon = icon

		local border = CreateFrame("Frame", nil, totem)
		border:SetAllPoints(icon)
		border:Hide()
		totem.border = border

		border.Background = border:CreateTexture(nil, "BACKGROUND", -1)
		border.Background:SetAllPoints()
		border.Background:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

		border.Border = CreateFrame("Frame", nil, border)
		border.Border:SetAllPoints()
		K.CreateBorder(border.Border)

		totems[slot] = totem
	end

	self.CustomTotems = totems
end
