local K, C, L = select(2, ...):unpack()
if C.DataBars.Experience ~= true then return end

-- LUA API
local unpack = unpack
local min, max = math.min, math.max

-- WOW API
local IsMaxLevel = IsMaxLevel
local MAX_PLAYER_LEVEL = MAX_PLAYER_LEVEL

local Movers = K.Movers

local ExperienceAnchor = CreateFrame("Frame", "ExperienceAnchor", UIParent)
ExperienceAnchor:SetSize(C.DataBars.Width, 18)
ExperienceAnchor:SetPoint("TOP", KkthnxUIMinimapStats, "BOTTOM", 0, 2)
Movers:RegisterFrame(ExperienceAnchor)

local function IsMaxLevel()
	if UnitLevel("player") == MAX_PLAYER_LEVEL then return true end
end

local function GetExperience()
	return UnitXP("player"), UnitXPMax("player")
end

local Backdrop = CreateFrame("Frame", "Experience_Backdrop", UIParent)
Backdrop:SetSize(C.DataBars.Width, C.DataBars.Height)
Backdrop:SetPoint("CENTER", ExperienceAnchor, "CENTER", 0, 0)
Backdrop:SetFrameStrata("LOW")
K.CreateBorder(Backdrop, 10, 3)

if C.Blizzard.ColorTextures == true then
	Backdrop:SetBorderTexture("white")
	Backdrop:SetBackdropBorderColor(unpack(C.Blizzard.TexturesColor))
end

local BackdropBG = CreateFrame("Frame", "Experience_BackdropBG", Backdrop)
BackdropBG:SetFrameLevel(Backdrop:GetFrameLevel() - 1)
BackdropBG:SetPoint("TOPLEFT", -1, 1)
BackdropBG:SetPoint("BOTTOMRIGHT", 1, -1)
BackdropBG:SetBackdrop(K.BorderBackdrop)
BackdropBG:SetBackdropColor(unpack(C.Media.Backdrop_Color))

local ExperienceBar = CreateFrame("StatusBar", "Experience_ExperienceBar", Backdrop, "TextStatusBar")
ExperienceBar:SetWidth(C.DataBars.Width)
ExperienceBar:SetHeight(GetWatchedFactionInfo() and (C.DataBars.Height) or C.DataBars.Height)
ExperienceBar:SetPoint("TOP", Backdrop,"TOP", 0, 0)
ExperienceBar:SetStatusBarTexture(C.Media.Texture)
ExperienceBar:SetStatusBarColor(0/255, 144/255, 255/255)

local RestedXPBar = CreateFrame("StatusBar", "Experience_RestedXPBar", Backdrop, "TextStatusBar")
RestedXPBar:SetHeight(GetWatchedFactionInfo() and (C.DataBars.Height) or C.DataBars.Height)
RestedXPBar:SetWidth(C.DataBars.Width)
RestedXPBar:SetPoint("TOP", Backdrop, "TOP", 0, 0)
RestedXPBar:SetStatusBarTexture(C.Media.Texture)
RestedXPBar:Hide()

local ReputationBar = CreateFrame("StatusBar", "Experience_ReputationBar", Backdrop, "TextStatusBar")
ReputationBar:SetWidth(C.DataBars.Width)
ReputationBar:SetHeight(IsMaxLevel() and C.DataBars.Height - 0 or 0)
ReputationBar:SetPoint("BOTTOM", Backdrop, "BOTTOM", 0, 0)
ReputationBar:SetStatusBarTexture(C.Media.Texture)
ReputationBar:SetFrameLevel(ExperienceBar:GetFrameLevel() - 1)

-- Hacky way to quickly display the reputation frame.
ExperienceAnchor:SetScript("OnMouseDown", function(self, btn)
	if (btn == "LeftButton") then
		if ReputationFrame and ReputationFrame:IsShown() then ToggleCharacter("ReputationFrame")
		else
			ToggleCharacter("ReputationFrame")
		end
	end
end)

local MouseFrame = CreateFrame("Frame", "Experience_MouseFrame", UIParent)
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
		ReputationBar:SetHeight(C.DataBars.Height)
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
			ExperienceBar:SetHeight(C.DataBars.Height)
			RestedXPBar:SetHeight(C.DataBars.Height)
			ReputationBar:SetHeight(C.DataBars.Height / 4)
			ReputationBar:Show()
		else
			ExperienceBar:SetHeight(C.DataBars.Height)
			RestedXPBar:SetHeight(C.DataBars.Height)
			ReputationBar:Hide()
		end
	end

	if GetWatchedFactionInfo() then
		local Name, ID, Min, Max, Value = GetWatchedFactionInfo()
		ReputationBar:SetMinMaxValues(Min, Max)
		ReputationBar:SetValue(Value)
		ReputationBar:SetStatusBarColor(FACTION_BAR_COLORS[ID].r, FACTION_BAR_COLORS[ID].g, FACTION_BAR_COLORS[ID].b)
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

local Frame = CreateFrame("Frame", nil, UIParent)
Frame:RegisterEvent("PLAYER_ENTERING_WORLD")
Frame:RegisterEvent("PLAYER_LEVEL_UP")
Frame:RegisterEvent("PLAYER_UPDATE_RESTING")
Frame:RegisterEvent("PLAYER_XP_UPDATE")
Frame:RegisterEvent("UNIT_INVENTORY_CHANGED")
Frame:RegisterEvent("UPDATE_EXHAUSTION")
Frame:RegisterEvent("UPDATE_FACTION")
Frame:SetScript("OnEvent", UpdateStatus)