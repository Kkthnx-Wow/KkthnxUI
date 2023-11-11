-- Create a new module for the death counter
local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

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

-- Enable debugging
local DEBUG_MODE = true

local function debugPrint(message)
	if DEBUG_MODE then
		print("|cFF33FF99[DEBUG]|r", message)
	end
end

---- [ ｡･:*:･ﾟ★,｡ 𝓖𝓪𝓻𝓫𝓪𝓰𝓮 𝓒𝓵𝓮𝓪𝓷𝓾𝓹 𝓢𝓬𝓻𝓲𝓹𝓽 ｡･:*:･ﾟ★,｡ ] ----

local eventCount = 0
local threshold = 5000

local function performGarbageCollection()
	local before = collectgarbage("count")
	debugPrint("Memory usage before garbage collection: " .. before)

	collectgarbage("collect")
	local after = collectgarbage("count")
	debugPrint("Memory usage after garbage collection: " .. after)

	local collected = before - after
	debugPrint("Memory collected: " .. collected)
end

local function onEvent(event)
	if InCombatLockdown() then
		return
	end

	eventCount = eventCount + 1

	if eventCount > threshold or event == "PLAYER_ENTERING_WORLD" or (event == "PLAYER_FLAGS_CHANGED" and UnitIsAFK("player")) then
		performGarbageCollection()
		eventCount = 0
	end
end

local frame = CreateFrame("Frame")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_FLAGS_CHANGED")

frame:SetScript("OnEvent", onEvent)

---- [ ｡･:*:･ﾟ★,｡ 𝓥𝓲𝓰𝓸𝓻 𝓑𝓪𝓻 ｡･:*:･ﾟ★,｡ ] ----

local VigorBar = CreateFrame("Frame", "VigorBar", UIParent)
VigorBar:SetPoint("TOP", UIParent, "TOP", 0, -12)
VigorBar:SetSize(250, 16)
VigorBar:Hide()

local function CreateVigorStatusBar(parent, name, width, texture)
	local statusBar = CreateFrame("StatusBar", name, parent)
	statusBar:SetSize(width, 16)
	statusBar:CreateBorder()

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

for i = 1, 6 do
	VigorBar[i] = CreateVigorStatusBar(VigorBar, "Vigor" .. i, 250 / 6, K.GetTexture(C["General"].Texture))
end

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

		local spacing = select(4, VigorBar[6]:GetPoint())
		local w, s = VigorBar:GetWidth(), 0

		for i = 1, total do
			VigorBar[i]:Show()
			VigorBar[i]:SetWidth((i ~= total) and w / total - spacing or w - s)
			s = s + (w / total)
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

local frame = CreateFrame("Frame")
frame:RegisterEvent("UPDATE_UI_WIDGET")
frame:RegisterEvent("UPDATE_ALL_UI_WIDGETS")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", function()
	for _, widget in pairs(UIWidgetPowerBarContainerFrame.widgetFrames) do
		if widget.widgetID == 4460 then
			SkinVigorBar(widget)
		end
	end
end)
