local K, C, L = select(2, ...):unpack()
if C.DataBars.ReputationEnable ~= true then return end

local GetWatchedFactionInfo = GetWatchedFactionInfo
local ToggleCharacter = ToggleCharacter

local Colors = FACTION_BAR_COLORS
local Movers = K.Movers

local Anchor = CreateFrame("Frame", "ReputationAnchor", UIParent)
Anchor:SetSize(C.DataBars.ReputationWidth, C.DataBars.ReputationHeight)
Anchor:SetPoint("TOP", Minimap, "BOTTOM", 0, -48)
Movers:RegisterFrame(Anchor)

local ReputationBar = CreateFrame("StatusBar", nil, UIParent)
ReputationBar:SetOrientation("HORIZONTAL")
ReputationBar:SetSize(C.DataBars.ReputationWidth, C.DataBars.ReputationHeight)
ReputationBar:SetPoint("CENTER", ReputationAnchor, "CENTER", 0, 0)
ReputationBar:SetStatusBarTexture(C.Media.Texture)

K.CreateBorder(ReputationBar, 10, 2.8)
ReputationBar:SetBackdrop({bgFile = C.Media.Blank,insets = {left = -1, right = -1, top = -1, bottom = -1}})
ReputationBar:SetBackdropColor(unpack(C.Media.Backdrop_Color))

if C.Blizzard.ColorTextures == true then
	ReputationBar:SetBorderTexture("white")
	ReputationBar:SetBackdropBorderColor(unpack(C.Blizzard.TexturesColor))
end

ReputationBar:SetScript("OnMouseDown", function(self, button)
	if (button == "LeftButton") then
		if ReputationFrame and ReputationFrame:IsShown() then ToggleCharacter("ReputationFrame")
		else
			ToggleCharacter("ReputationFrame")
		end
	end
end)

local function UpdateReputationBar()
    local Name, ID, Min, Max, Value = GetWatchedFactionInfo()

	if Name then
	    ReputationBar:Show()
        ReputationBar:SetMinMaxValues(Min, Max)
        ReputationBar:SetValue(Value)
        ReputationBar:SetStatusBarColor(Colors[ID].r, Colors[ID].g, Colors[ID].b)
	else
	    ReputationBar:Hide()
	end
end

ReputationBar:SetScript("OnEnter", function(self)
    local Name, ID, Min, Max, Value = GetWatchedFactionInfo()

	GameTooltip:ClearLines()
    GameTooltip:SetOwner(self, "ANCHOR_CURSOR", 0, -4)

	GameTooltip:AddLine(string.format("%s (%s)", Name, _G["FACTION_STANDING_LABEL" .. ID]))
	GameTooltip:AddLine(string.format("%d / %d (%d%%)", Value - Min, Max - Min, (Value - Min) / (Max - Min) * 100))

	GameTooltip:Show()
end)

ReputationBar:SetScript("OnLeave", function() GameTooltip:Hide() end)

if C.DataBars.ReputationFade then
	ReputationBar:SetAlpha(0)
	ReputationBar:HookScript("OnEnter", function(self) self:SetAlpha(1) end)
	ReputationBar:HookScript("OnLeave", function(self) self:SetAlpha(0) end)
	ReputationBar.Tooltip = true
end

ReputationBar:RegisterEvent("PLAYER_ENTERING_WORLD")
ReputationBar:RegisterEvent("UPDATE_FACTION")

ReputationBar:SetScript("OnEvent", UpdateReputationBar)
