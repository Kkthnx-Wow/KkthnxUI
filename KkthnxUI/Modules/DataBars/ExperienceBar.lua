local K, C, L = select(2, ...):unpack()
if C.DataBars.ExperienceEnable ~= true or K.Level == MAX_PLAYER_LEVEL then return end

local Bars = 20
local Movers = K.Movers

local Anchor = CreateFrame("Frame", "ExperienceAnchor", UIParent)
Anchor:SetSize(C.DataBars.ExperienceWidth, C.DataBars.ExperienceHeight)
Anchor:SetPoint("TOP", Minimap, "BOTTOM", 0, -33)
Movers:RegisterFrame(Anchor)

local ExperienceBar = CreateFrame("StatusBar",  nil, UIParent)
ExperienceBar:SetOrientation("HORIZONTAL")
ExperienceBar:SetSize(C.DataBars.ExperienceWidth, C.DataBars.ExperienceHeight)
ExperienceBar:SetPoint("CENTER", ExperienceAnchor, "CENTER", 0, 0)
ExperienceBar:SetStatusBarTexture(C.Media.Texture)
ExperienceBar:SetStatusBarColor(unpack(C.DataBars.ExperienceColor))

K.CreateBorder(ExperienceBar, 10, 2.8)

local ExperienceBarRested = CreateFrame("StatusBar", nil, UIParent)
ExperienceBarRested:SetOrientation("HORIZONTAL")
ExperienceBarRested:SetSize(C.DataBars.ExperienceWidth, C.DataBars.ExperienceHeight)
ExperienceBarRested:SetPoint("BOTTOM", ExperienceBar, "BOTTOM", 0, 0)
ExperienceBarRested:SetStatusBarTexture(C.Media.Texture)
ExperienceBarRested:SetStatusBarColor(unpack(C.DataBars.ExperienceRestedColor))

ExperienceBarRested:SetBackdrop({bgFile = C.Media.Blank,insets = {left = -1, right = -1, top = -1, bottom = -1}})
ExperienceBarRested:SetBackdropColor(unpack(C.Media.Backdrop_Color))

if C.Blizzard.ColorTextures == true then
	ExperienceBar:SetBorderTexture("white")
	ExperienceBar:SetBackdropBorderColor(unpack(C.Blizzard.TexturesColor))
end

local function UpdateExperienceBar()
    local Current, Max = UnitXP("player"), UnitXPMax("player")
    local Rested = GetXPExhaustion()
    local IsRested = GetRestState()

    ExperienceBar:SetMinMaxValues(0, Max)
    ExperienceBar:SetValue(Current)

    if (IsRested == 1 and Rested) then
	    ExperienceBarRested:SetFrameLevel(ExperienceBar:GetFrameLevel() - 1)
        ExperienceBarRested:SetMinMaxValues(0, Max)
        ExperienceBarRested:SetValue(Rested + Current)
    end
end

ExperienceBar:SetScript("OnEnter", function(self)
    local Current, Max = UnitXP("player"), UnitXPMax("player")
    local Rested = GetXPExhaustion()
    local IsRested = GetRestState()

	if Max == 0 then
		return
	end

	GameTooltip:ClearLines()
    GameTooltip:SetOwner(self, "ANCHOR_CURSOR", 0, -4)

	GameTooltip:AddLine(string.format("|cff0090FF"..XP..": %d / %d (%d%% - %d/%d)|r", Current, Max, Current / Max * 100, Bars - (Bars * (Max - Current) / Max), Bars))

    if (IsRested == 1 and Rested) then
        GameTooltip:AddLine(string.format("|cff4BAF4C"..TUTORIAL_TITLE26..": +%d (%d%%)|r", Rested, Rested / Max * 100))
    end

	GameTooltip:Show()
end)

ExperienceBar:SetScript("OnLeave", function() GameTooltip:Hide() end)

if C.DataBars.ExperienceFade then
	ExperienceBar:SetAlpha(0)
	ExperienceBar:HookScript("OnEnter", function(self) self:SetAlpha(1) end)
	ExperienceBar:HookScript("OnLeave", function(self) self:SetAlpha(0) end)
	ExperienceBar.Tooltip = true
end

ExperienceBar:RegisterEvent("PLAYER_ENTERING_WORLD")
ExperienceBar:RegisterEvent("PLAYER_XP_UPDATE")
ExperienceBar:RegisterEvent("PLAYER_LEVEL_UP")
ExperienceBar:RegisterEvent("UPDATE_EXHAUSTION")
ExperienceBar:RegisterEvent("PLAYER_UPDATE_RESTING")

ExperienceBar:SetScript("OnEvent", UpdateExperienceBar)
