local K, C, L, _ = select(2, ...):unpack()

local format = string.format
local min = math.min
local unpack = unpack
local CreateFrame = CreateFrame
local GetWatchedFactionInfo = GetWatchedFactionInfo
local MAX_PLAYER_LEVEL = MAX_PLAYER_LEVEL

local r, g, b = K.Color.r, K.Color.g, K.Color.b

-- Utility
local FactionInfo = {
	[1] = {170/255, 70/255, 70/255, L_REPUTATION_HATED, "FFaa4646"},
	[2] = {170/255, 70/255, 70/255, L_REPUTATION_HOSTILE, "FFaa4646"},
	[3] = {170/255, 70/255, 70/255, L_REPUTATION_UNFRIENDLY, "FFaa4646"},
	[4] = {200/255, 180/255, 100/255, L_REPUTATION_NEUTRAL, "FFc8b464"},
	[5] = {75/255, 175/255, 75/255, L_REPUTATION_FRIENDLY, "FF4baf4b"},
	[6] = {75/255, 175/255, 75/255, L_REPUTATION_HONORED, "FF4baf4b"},
	[7] = {75/255, 175/255, 75/255, L_REPUTATION_REVERED, "FF4baf4b"},
	[8] = {155/255, 255/255, 155/255, L_REPUTATION_EXALTED,"FF9bff9b"},
}

-- Create frames
local backdrop = CreateFrame("Frame", nil, Minimap)
backdrop:SetHeight(8)
backdrop:SetPoint("TOP", Minimap, "BOTTOM")
backdrop:SetPoint("TOPLEFT", Minimap, "BOTTOMLEFT", -1, -26)
backdrop:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", 1, -26)
backdrop:SetBackdrop(K.BorderBackdrop)
backdrop:SetBackdropColor(unpack(C.Media.Backdrop_Color))
backdrop:CreatePixelShadow(2)

local xpBar = CreateFrame("StatusBar", nil, backdrop)
xpBar:SetHeight(GetWatchedFactionInfo() and 5 or 7)
xpBar:SetPoint("TOP", backdrop, "TOP", 0, -1)
xpBar:SetPoint("LEFT", backdrop, 1, 0)
xpBar:SetPoint("RIGHT", backdrop, -1, 0)
xpBar:SetStatusBarTexture(C.Media.Texture)
xpBar:SetStatusBarColor(.5, 0, .75)

local restedxpBar = CreateFrame("StatusBar", nil, backdrop)
restedxpBar:SetHeight(GetWatchedFactionInfo() and 5 or 7)
restedxpBar:SetPoint("TOP", backdrop, "TOP", 0, -1)
restedxpBar:SetPoint("LEFT", backdrop, 1, 0)
restedxpBar:SetPoint("RIGHT", backdrop, -1, 0)
restedxpBar:SetStatusBarTexture(C.Media.Texture)
restedxpBar:SetStatusBarColor(0, .4, .8)

local repBar = CreateFrame("StatusBar", nil, backdrop)
repBar:SetHeight(5)
repBar:SetPoint("BOTTOM", backdrop, "BOTTOM", 0, 1)
repBar:SetPoint("LEFT", backdrop, 1, 0)
repBar:SetPoint("RIGHT", backdrop, -1, 0)
repBar:SetStatusBarTexture(C.Media.Texture)

local sep = backdrop:CreateTexture(nil, "BORDER")
sep:SetWidth(backdrop:GetWidth() + 12)
sep:SetHeight(1)
sep:SetPoint("TOP", xpBar, "BOTTOM")
sep:SetTexture(C.Media.Blank)
sep:SetVertexColor(0, 0, 0)

local mouseFrame = CreateFrame("Frame", "ExpBar", backdrop)
mouseFrame:SetAllPoints(backdrop)
mouseFrame:EnableMouse(true)

backdrop:SetFrameLevel(0)
restedxpBar:SetFrameLevel(1)
repBar:SetFrameLevel(2)
xpBar:SetFrameLevel(2)
mouseFrame:SetFrameLevel(3)

-- Update function
local function updateStatus()
	local XP, maxXP = UnitXP("player"), UnitXPMax("player")
	local restXP = GetXPExhaustion()

	if UnitLevel("player") == MAX_PLAYER_LEVEL then
		xpBar:Hide()
		restedxpBar:Hide()
		sep:Hide()
		repBar:SetHeight(6)
		if not GetWatchedFactionInfo() then
			backdrop:Hide()
		else
			backdrop:Show()
		end
	else
		xpBar:SetMinMaxValues(min(0, XP), maxXP)
		xpBar:SetValue(XP)

		if restXP then
			restedxpBar:Show()
			restedxpBar:SetMinMaxValues(min(0, XP), maxXP)
			restedxpBar:SetValue(XP+restXP)
		else
			restedxpBar:Hide()
		end

		if GetWatchedFactionInfo() then
			xpBar:SetHeight(3)
			restedxpBar:SetHeight(3)
			repBar:SetHeight(2)
			repBar:Show()
			sep:Show()
		else
			xpBar:SetHeight(6)
			restedxpBar:SetHeight(6)
			repBar:Hide()
			sep:Hide()
		end
	end

	if GetWatchedFactionInfo() then
		local name, rank, minRep, maxRep, value = GetWatchedFactionInfo()
		repBar:SetMinMaxValues(minRep, maxRep)
		repBar:SetValue(value)
		repBar:SetStatusBarColor(FactionInfo[rank][1], FactionInfo[rank][2], FactionInfo[rank][3])
	end
end

local frame = CreateFrame("Frame", nil, UIParent)
frame:RegisterEvent("PLAYER_LEVEL_UP")
frame:RegisterEvent("PLAYER_XP_UPDATE")
frame:RegisterEvent("UPDATE_EXHAUSTION")
frame:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
frame:RegisterEvent("UPDATE_FACTION")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", updateStatus)

-- Mouse events
mouseFrame:SetScript("OnEnter", function()
	local XP, maxXP = UnitXP("player"), UnitXPMax("player")
	local restXP = GetXPExhaustion()

	GameTooltip:SetOwner(mouseFrame, "ANCHOR_BOTTOMLEFT", 0, 7)
	GameTooltip:ClearLines()
	if UnitLevel("player") ~= MAX_PLAYER_LEVEL then
		GameTooltip:AddDoubleLine(L_EXPERIENCE_BAR, K.Name, r, g, b, 1, 1, 1)
		GameTooltip:AddDoubleLine(L_CURRENT_EXPERIENCE, format('%s/%s (%d%%)', K.Comma(XP), K.Comma(maxXP), (XP/maxXP)*100), r, g, b, 1, 1, 1)
		GameTooltip:AddDoubleLine(L_REMAINING_EXPERIENCE, format('%s', K.Comma(maxXP-XP)), r, g, b, 1, 1, 1)
		if restXP then
			GameTooltip:AddDoubleLine(L_RESTED_EXPERIENCE, format('|cffb3e1ff%s (%d%%)', K.Comma(restXP), restXP/maxXP*100), r, g, b)
		end
	end
	if GetWatchedFactionInfo() then
		local name, rank, start, cap, value = GetWatchedFactionInfo()
		if UnitLevel("player") ~= MAX_PLAYER_LEVEL then GameTooltip:AddLine(" ") end
		GameTooltip:AddDoubleLine(L_REPUTATION_BAR, name, r, g, b, 1, 1, 1)
		GameTooltip:AddDoubleLine(L_STANDING_REPUTATION, format('|c'..FactionInfo[rank][5]..'%s|r', FactionInfo[rank][4]), r, g, b)
		GameTooltip:AddDoubleLine(L_CURRENT_REPUTATION, format('%s/%s (%d%%)', K.Comma(value-start), K.Comma(cap-start), (value-start)/(cap-start)*100), r, g, b, 1, 1, 1)
		GameTooltip:AddDoubleLine(L_REMAINING_REPUTATION, format('%s', K.Comma(cap-value)), r, g, b, 1, 1, 1)
	end
	GameTooltip:Show()
end)

mouseFrame:SetScript("OnLeave", function()
	GameTooltip:Hide()
end)