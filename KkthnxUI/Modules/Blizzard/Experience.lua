local K, C, L, _ = select(2, ...):unpack()
if C.Experience.XP ~= true then return end

-- LUA API
local unpack = unpack
local min, max = math.min, math.max

-- WOW API
local IsMaxLevel = IsMaxLevel
local MAX_PLAYER_LEVEL = MAX_PLAYER_LEVEL

local BarHeight, BarWidth = C.Experience.XPHeight, C.Experience.XPWidth
local barTex, flatTex = C.Media.Texture
local Colors = RAID_CLASS_COLORS[K.Class]
local Movers = K["Movers"]

local ExperienceAnchor = CreateFrame("Frame", "ExperienceAnchor", UIParent)
ExperienceAnchor:SetSize(C.Experience.XPWidth, 18)

if C.Minimap.Invert then
	ExperienceAnchor:SetPoint("TOPLEFT", Minimap, "TOPLEFT", -1, 44)
	ExperienceAnchor:SetPoint("TOPRIGHT", Minimap, "TOPRIGHT", 1, 44)
else
	ExperienceAnchor:SetPoint("TOPLEFT", Minimap, "BOTTOMLEFT", -1, -24)
	ExperienceAnchor:SetPoint("TOPRIGHT", Minimap, "BOTTOMRIGHT", 1, -24)
end
Movers:RegisterFrame(ExperienceAnchor)

local function IsMaxLevel()
	if UnitLevel("player") == MAX_PLAYER_LEVEL then return true end
end

local function GetExperience()
	return UnitXP("player"), UnitXPMax("player")
end

local function GetHonor()
	return UnitHonor("player"), UnitHonorMax("player")
end

local Backdrop = CreateFrame("Frame", "Experience_Backdrop", UIParent)
Backdrop:SetSize(BarWidth, BarHeight)
Backdrop:SetPoint("CENTER", ExperienceAnchor, "CENTER", 0, 0)
Backdrop:SetFrameStrata("LOW")
Backdrop:CreatePixelShadow()

local BackdropBG = CreateFrame("Frame", "Experience_BackdropBG", Backdrop)
BackdropBG:SetFrameLevel(Backdrop:GetFrameLevel() - 1)
BackdropBG:SetPoint("TOPLEFT", -1, 1)
BackdropBG:SetPoint("BOTTOMRIGHT", 1, -1)
BackdropBG:SetBackdrop(K.BorderBackdrop)
BackdropBG:SetBackdropColor(unpack(C.Media.Backdrop_Color))

local ExperienceBar = CreateFrame("StatusBar", "Experience_ExperienceBar", Backdrop, "TextStatusBar")
ExperienceBar:SetWidth(BarWidth)
ExperienceBar:SetHeight(GetWatchedFactionInfo() and (BarHeight) or BarHeight)
ExperienceBar:SetPoint("TOP", Backdrop,"TOP", 0, 0)
ExperienceBar:SetStatusBarTexture(barTex)
if C.Experience.XPClassColor then ExperienceBar:SetStatusBarColor(Colors.r, Colors.g, Colors.b) else ExperienceBar:SetStatusBarColor(0/255, 144/255, 255/255) end

local RestedXPBar = CreateFrame("StatusBar", "Experience_RestedXPBar", Backdrop, "TextStatusBar")
RestedXPBar:SetHeight(GetWatchedFactionInfo() and (BarHeight) or BarHeight)
RestedXPBar:SetWidth(BarWidth)
RestedXPBar:SetPoint("TOP", Backdrop, "TOP", 0, 0)
RestedXPBar:SetStatusBarTexture(barTex)
RestedXPBar:Hide()

local ReputationBar = CreateFrame("StatusBar", "Experience_ReputationBar", Backdrop, "TextStatusBar")
ReputationBar:SetWidth(BarWidth)
ReputationBar:SetHeight(IsMaxLevel() and BarHeight - 0 or 0)
ReputationBar:SetPoint("BOTTOM", Backdrop, "BOTTOM", 0, 0)
ReputationBar:SetStatusBarTexture(barTex)
ReputationBar:SetFrameLevel(ExperienceBar:GetFrameLevel() - 1)

-- HACKY WAY TO QUICKLY DISPLAY THE REPUTATION FRAME.
ExperienceAnchor:SetScript("OnMouseDown", function(self, btn)
	if (btn == "LeftButton") then
		if ReputationFrame and ReputationFrame:IsShown() then ToggleCharacter("ReputationFrame")
		else
			ToggleCharacter("ReputationFrame")
		end
	end
end)

local MouseFrame = CreateFrame("Frame", "Experience_MouseFrame", Backdrop)
MouseFrame:SetAllPoints(Backdrop)
MouseFrame:EnableMouse(true)
MouseFrame:SetFrameLevel(3)

local function UpdateStatus(event, owner)
	if (event == "UNIT_INVENTORY_CHANGED" and owner ~= "player") then
		return
	end

	local Current, Max

	local Rested = GetXPExhaustion()
	local IsRested = GetRestState()
	local Bars = 20
	Current, Max = GetExperience()

	if IsMaxLevel() then
		ExperienceBar:Hide()
		RestedXPBar:Hide()
		ReputationBar:SetHeight(BarHeight)
		if not GetWatchedFactionInfo() then Backdrop:Hide() else Backdrop:Show() end
	else
		ExperienceBar:SetMinMaxValues(0, Max)
		ExperienceBar:SetValue(Current)

		if (IsRested == 1 and Rested) then
			RestedXPBar:Show()
			RestedXPBar:SetStatusBarColor(75/255, 175/255, 76/255, .40)
			RestedXPBar:SetMinMaxValues(0, Max)
			RestedXPBar:SetValue(Rested + Current)
		else
			RestedXPBar:Hide()
		end

		if GetWatchedFactionInfo() then
			ExperienceBar:SetHeight(BarHeight)
			RestedXPBar:SetHeight(BarHeight)
			ReputationBar:SetHeight(BarHeight / 4)
			ReputationBar:Show()
		else
			ExperienceBar:SetHeight(BarHeight)
			RestedXPBar:SetHeight(BarHeight)
			ReputationBar:Hide()
		end
	end

	if GetWatchedFactionInfo() then
		local Name, ID, Min, Max, Value = GetWatchedFactionInfo()
		ReputationBar:SetMinMaxValues(Min, Max)
		ReputationBar:SetValue(Value)
		ReputationBar:SetStatusBarColor(FACTION_BAR_COLORS[ID].r, FACTION_BAR_COLORS[ID].g, FACTION_BAR_COLORS[ID].b)
	end

	if IsWatchingHonorAsXP() then
		local Level = UnitHonorLevel("player")
		local LevelMax = GetMaxPlayerHonorLevel()
		local Prestige = UnitPrestige("player")

		Current, Max = GetHonor()

		if Max == 0 then
			GameTooltip:AddLine(PVP_HONOR_PRESTIGE_AVAILABLE)
			GameTooltip:AddLine(PVP_HONOR_XP_BAR_CANNOT_PRESTIGE_HERE)
		else
			GameTooltip:AddLine(string.format("|cffee2222"..HONOR..": %d / %d (%d%% - %d/%d)|r", Current, Max, Current / Max * 100, Bars - (Bars * (Max - Current) / Max), Bars))
			GameTooltip:AddLine(string.format("|cffcccccc"..RANK..": %d / %d|r", Level, LevelMax))
			GameTooltip:AddLine(string.format("|cffcccccc"..PVP_PRESTIGE_RANK_UP_TITLE..": %d|r", Prestige))
		end
	end

	MouseFrame:SetScript("OnEnter", function()
		GameTooltip:SetOwner(MouseFrame, "ANCHOR_BOTTOMLEFT", -2, 5)
		GameTooltip:ClearLines()
		if not IsMaxLevel() then
			GameTooltip:AddLine(string.format("|cff0090FF"..XP..": %d / %d (%d%% - %d/%d)|r", Current, Max, Current / Max * 100, Bars - (Bars * (Max - Current) / Max), Bars))
			if (IsRested == 1 and Rested) then
				GameTooltip:AddLine(string.format("|cff4BAF4C"..TUTORIAL_TITLE26..": +%d (%d%%)|r", Rested, Rested / Max * 100))
			end
		end
		if GetWatchedFactionInfo() then
			local Name, ID, Min, Max, Value = GetWatchedFactionInfo()
			if not IsMaxLevel() then GameTooltip:AddLine(" ") end
			GameTooltip:AddLine(string.format("%s (%s)", Name, _G["FACTION_STANDING_LABEL" .. ID]))
			GameTooltip:AddLine(string.format("%d / %d (%d%%)", Value - Min, Max - Min, (Value - Min) / (Max - Min) * 100))
		end

		GameTooltip:Show()
	end)

	MouseFrame:SetScript("OnLeave", function() GameTooltip:Hide() end)
end

local frame = CreateFrame("Frame", nil, UIParent)
frame:RegisterEvent("PLAYER_ENTERING_WORLD")
frame:RegisterEvent("PLAYER_LEVEL_UP")
frame:RegisterEvent("PLAYER_UPDATE_RESTING")
frame:RegisterEvent("PLAYER_XP_UPDATE")
frame:RegisterEvent("UNIT_INVENTORY_CHANGED")
frame:RegisterEvent("UPDATE_EXHAUSTION")
frame:RegisterEvent("UPDATE_FACTION")
frame:RegisterEvent("HONOR_LEVEL_UPDATE")
frame:RegisterEvent("HONOR_PRESTIGE_UPDATE")
frame:RegisterEvent("HONOR_XP_UPDATE")
frame:SetScript("OnEvent", UpdateStatus)