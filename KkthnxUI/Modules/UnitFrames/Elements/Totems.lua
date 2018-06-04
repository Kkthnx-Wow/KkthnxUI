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
		totem:SetTemplate("Transparent")
		totem:SetStatusBarTexture(UnitframeTexture)
		totem:SetStatusBarColor(r, g, b)
		totem:SetSize(width, height)
		totem:SetPoint(K.Class == "SHAMAN" and "BOTTOMLEFT" or "BOTTOMLEFT", (slot - 1) * spacing + 4, -14)
		totem:EnableMouse(true)

		local icon = totem:CreateTexture(nil, "ARTWORK")
		icon:SetSize(width -5, width -5)
		icon:SetPoint("TOP", totem, "BOTTOM", 0, -6)
		icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		icon:Hide()
		totem.icon = icon

		local border = CreateFrame("Frame", nil, totem)
		border:SetAllPoints(icon)
		border:SetTemplate("")
		border:Hide()
		totem.border = border

		totems[slot] = totem
	end

	self.CustomTotems = totems
end
