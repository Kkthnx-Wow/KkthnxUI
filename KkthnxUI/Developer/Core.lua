local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Miscellaneous")

K.Devs = {
	["Kkthnx-Area 52"] = true,
}

local function isDeveloper()
	return K.Devs[K.Name .. "-" .. K.Realm]
end
K.isDeveloper = isDeveloper()

if not K.isDeveloper then
	return
end

---- [ ｡･:*:･ﾟ★,｡ 𝓥𝓲𝓰𝓸𝓻 𝓑𝓪𝓻 ｡･:*:･ﾟ★,｡ ] ----

local VigorBar

-- Function to create Vigor status bar
local function CreateVigorStatusBar(parent, name, width, texture)
	local statusBar = CreateFrame("StatusBar", name, parent)
	statusBar:SetSize(width, 16)
	statusBar:CreateBorder()
	K:SmoothBar(statusBar)

	if parent.lastStatusBar then
		statusBar:SetPoint("TOPLEFT", parent.lastStatusBar, "TOPRIGHT", 6, 0)
	else
		statusBar:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, 0)
	end

	statusBar:SetStatusBarTexture(texture)
	statusBar:SetMinMaxValues(0, 100)
	statusBar:SetStatusBarColor(0.2, 0.58, 0.8)

	statusBar:SetValue(0)

	parent.lastStatusBar = statusBar
	return statusBar
end

-- Function to skin the VigorBar
local function SkinVigorBar(widget)
	if not widget:IsShown() then
		return
	end

	local widgetInfo = C_UIWidgetManager.GetFillUpFramesWidgetVisualizationInfo(4460)
	if not widgetInfo then
		return
	end

	VigorBar:Show()
	local total = widgetInfo.numTotalFrames

	for i = 1, total do
		local value = (widgetInfo.numFullFrames >= i) and widgetInfo.fillMax or ((widgetInfo.numFullFrames + 1 == i) and widgetInfo.fillValue or widgetInfo.fillMin)

		VigorBar[i]:SetStatusBarColor(0.2, 0.58, 0.8)
		if widgetInfo.numFullFrames + 1 == i then
			VigorBar[i]:SetStatusBarColor(0.2 * 0.6, 0.58 * 0.6, 0.8 * 0.6)
		end

		VigorBar[i]:SetValue(value)
	end

	total = (total < 6 and IsPlayerSpell(377922)) and 6 or total

	if total < 6 then
		for i = total + 1, 6 do
			VigorBar[i]:Hide()
			VigorBar[i]:SetValue(0)
		end

		local spacing = 6
		local w, s = VigorBar:GetWidth(), 0

		for i = 1, total do
			VigorBar[i]:Show()
			VigorBar[i]:SetWidth((i ~= total) and (w - (spacing * (total - 1))) / total or w - s)
			s = s + VigorBar[i]:GetWidth() + spacing
		end
	end

	widget:SetAlpha(0)

	if not widget.hook then
		hooksecurefunc(widget, "Hide", function()
			VigorBar:Hide()
			VigorBar.lastStatusBar = nil
		end)
		widget.hook = true
	end
end

-- Function to handle events and update the VigorBar
local function UpdateVigorBar()
	for _, widget in pairs(UIWidgetPowerBarContainerFrame.widgetFrames) do
		if widget.widgetID == 4460 then
			SkinVigorBar(widget)
		end
	end
end

-- Function to create VigorBar frame and register events
local function CreateVigorBar()
	VigorBar = CreateFrame("Frame", "VigorBar", UIParent)
	VigorBar:SetPoint("TOP", UIParent, "TOP", 0, -30)
	VigorBar:SetSize(250, 18)
	VigorBar:Hide()

	-- Loop to create Vigor status bars
	for i = 1, 6 do
		VigorBar[i] = CreateVigorStatusBar(VigorBar, "Vigor" .. i, (250 - (6 * 5)) / 6, K.GetTexture(C["General"].Texture))
	end

	K.Mover(VigorBar, "VigorBar", "VigorBar", { "TOP", UIParent, "TOP", 0, -30 }, 250, 18)

	K:RegisterEvent("UNIT_POWER_UPDATE", UpdateVigorBar, "player")
	K:RegisterEvent("UPDATE_UI_WIDGET", UpdateVigorBar)
end

-- Register VigorBar module
Module:RegisterMisc("VigorBar", CreateVigorBar)
