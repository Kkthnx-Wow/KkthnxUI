local K, C, L, _ = select(2, ...):unpack()
if C.Experience.XP ~= true then return end

-- LUA API
local unpack = unpack
local min, max = math.min, math.max

-- WOW API
local IsMaxLevel = IsMaxLevel
local MAX_PLAYER_LEVEL = MAX_PLAYER_LEVEL

local barHeight, barWidth = C.Experience.XPHeight, C.Experience.XPWidth
local barTex, flatTex = C.Media.Texture
local color = RAID_CLASS_COLORS[K.Class]

local ExperienceAnchor = CreateFrame("Frame", "ExperienceAnchor", UIParent)
ExperienceAnchor:SetSize(C.Experience.XPWidth, 18)
ExperienceAnchor:SetPoint("TOPLEFT", Minimap, "BOTTOMLEFT", -1, -22)
ExperienceAnchor:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", 1, -22)

local FactionInfo = {
	[1] = {{170/255, 70/255, 70/255}, L_REPUTATION_HATED, "FFaa4646"},
	[2] = {{170/255, 70/255, 70/255}, L_REPUTATION_HOSTILE, "FFaa4646"},
	[3] = {{170/255, 70/255, 70/255}, L_REPUTATION_UNFRIENDLY, "FFaa4646"},
	[4] = {{200/255, 180/255, 100/255}, L_REPUTATION_NEUTRAL, "FFc8b464"},
	[5] = {{75/255, 175/255, 75/255}, L_REPUTATION_FRIENDLY, "FF4baf4b"},
	[6] = {{75/255, 175/255, 75/255}, L_REPUTATION_HONORED, "FF4baf4b"},
	[7] = {{75/255, 175/255, 75/255}, L_REPUTATION_REVERED, "FF4baf4b"},
	[8] = {{155/255, 255/255, 155/255}, L_REPUTATION_EXALTED,"FF9bff9b"},
}

function colorize(r) return FactionInfo[r][3] end

local function IsMaxLevel()
	if UnitLevel("player") == MAX_PLAYER_LEVEL then return true end
end

local backdrop = CreateFrame("Frame", "Experience_Backdrop", UIParent)
backdrop:SetSize(barWidth, barHeight)
backdrop:SetPoint("CENTER", ExperienceAnchor, "CENTER", 0, 0)
backdrop:SetFrameStrata("LOW")
backdrop:CreatePixelShadow()

local backdropBG = CreateFrame("Frame", "Experience_BackdropBG", backdrop)
backdropBG:SetFrameLevel(backdrop:GetFrameLevel() - 1)
backdropBG:SetPoint("TOPLEFT", -1, 1)
backdropBG:SetPoint("BOTTOMRIGHT", 1, -1)
backdropBG:SetBackdrop(K.BorderBackdrop)
backdropBG:SetBackdropColor(unpack(C.Media.Backdrop_Color))

local xpBar = CreateFrame("StatusBar", "Experience_xpBar", backdrop, "TextStatusBar")
xpBar:SetWidth(barWidth)
xpBar:SetHeight(GetWatchedFactionInfo() and (barHeight) or barHeight)
xpBar:SetPoint("TOP", backdrop,"TOP", 0, 0)
xpBar:SetStatusBarTexture(barTex)
if C.Experience.XPClassColor then xpBar:SetStatusBarColor(color.r, color.g, color.b) else xpBar:SetStatusBarColor(31/255, 41/255, 130/255) end

local restedxpBar = CreateFrame("StatusBar", "Experience_restedxpBar", backdrop, "TextStatusBar")
restedxpBar:SetHeight(GetWatchedFactionInfo() and (barHeight) or barHeight)
restedxpBar:SetWidth(barWidth)
restedxpBar:SetPoint("TOP", backdrop, "TOP", 0, 0)
restedxpBar:SetStatusBarTexture(barTex)
restedxpBar:Hide()

local repBar = CreateFrame("StatusBar", "Experience_repBar", backdrop, "TextStatusBar")
repBar:SetWidth(barWidth)
repBar:SetHeight(IsMaxLevel() and barHeight - 0 or 0)
repBar:SetPoint("BOTTOM", backdrop, "BOTTOM", 0, 0)
repBar:SetStatusBarTexture(barTex)
repBar:SetFrameLevel(xpBar:GetFrameLevel() + 1)

local mouseFrame = CreateFrame("Frame", "Experience_mouseFrame", backdrop)
mouseFrame:SetAllPoints(backdrop)
mouseFrame:EnableMouse(true)
mouseFrame:SetFrameLevel(3)

local function updateStatus()
	local XP, maxXP, restXP = UnitXP("player"), UnitXPMax("player"), GetXPExhaustion()
	if not maxXP or maxXP == 0 then return end
	local percXP = math.floor((XP / maxXP) * 100)

	if IsMaxLevel() then
		xpBar:Hide()
		restedxpBar:Hide()
		repBar:SetHeight(barHeight)
		if not GetWatchedFactionInfo() then backdrop:Hide() else backdrop:Show() end
	else
		xpBar:SetMinMaxValues(min(0, XP), maxXP)
		xpBar:SetValue(XP)

		if restXP then
			restedxpBar:Show()
			local r, g, b = color.r, color.g, color.b
			restedxpBar:SetStatusBarColor(r, g, b, .40)
			restedxpBar:SetMinMaxValues(min(0, XP), maxXP)
			restedxpBar:SetValue(XP + restXP)
		else
			restedxpBar:Hide()
		end

		if GetWatchedFactionInfo() then
			xpBar:SetHeight(barHeight)
			restedxpBar:SetHeight(barHeight)
			repBar:SetHeight(barHeight / 4)
			repBar:Show()
		else
			xpBar:SetHeight(barHeight)
			restedxpBar:SetHeight(barHeight)
			repBar:Hide()
		end
	end

	if GetWatchedFactionInfo() then
		local name, rank, minRep, maxRep, value = GetWatchedFactionInfo()
		repBar:SetMinMaxValues(minRep, maxRep)
		repBar:SetValue(value)
		repBar:SetStatusBarColor(unpack(FactionInfo[rank][1]))
	end

	mouseFrame:SetScript("OnEnter", function()
		GameTooltip:SetOwner(mouseFrame, "ANCHOR_TOPLEFT", -2, 5)
		GameTooltip:ClearLines()
		if not IsMaxLevel() then
			GameTooltip:AddLine(L_EXPERIENCE_BAR)
			GameTooltip:AddLine(string.format(L_EXPERIENCE_XP, K.Comma(XP), K.Comma(maxXP), (XP / maxXP) * 100))
			GameTooltip:AddLine(string.format(L_EXPERIENCE_XPREMAINING, K.Comma(maxXP - XP)))
			if restXP then GameTooltip:AddLine(string.format(L_EXPERIENCE_XPRESTED, K.Comma(restXP), restXP / maxXP * 100)) end
		end
		if GetWatchedFactionInfo() then
			local name, rank, min, max, value = GetWatchedFactionInfo()
			if not IsMaxLevel() then GameTooltip:AddLine(" ") end
			GameTooltip:AddLine(string.format(L_REPUTATION_FCTITLE, name))
			GameTooltip:AddLine(string.format(L_REPUTATION_STANDING..colorize(rank).. " %s|r", FactionInfo[rank][2]))
			GameTooltip:AddLine(string.format(L_REPUTATION_REP, K.Comma(value - min), K.Comma(max - min), (value - min)/(max - min) * 100))
			GameTooltip:AddLine(string.format(L_REPUTATION_REMAINGING, K.Comma(max - value)))
		end
		GameTooltip:Show()
	end)

	mouseFrame:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

local frame = CreateFrame("Frame", nil, UIParent)
frame:RegisterEvent("PLAYER_LEVEL_UP")
frame:RegisterEvent("PLAYER_XP_UPDATE")
frame:RegisterEvent("UPDATE_EXHAUSTION")
frame:RegisterEvent("CHAT_MSG_COMBAT_FACTION_CHANGE")
frame:RegisterEvent("UPDATE_FACTION")
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:SetScript("OnEvent", updateStatus)