local K, C, L = unpack(select(2, ...))
if C.DataBars.ReputationEnable ~= true then return end

-- WoW Lua
local _G = _G
local format = string.format

-- Wow API
local GetWatchedFactionInfo = GetWatchedFactionInfo

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: ReputationFrame, ToggleCharacter, GameTooltip

local Colors = FACTION_BAR_COLORS
local Movers = K.Movers

local Anchor = CreateFrame("Frame", "ReputationAnchor", UIParent)
Anchor:SetSize(C.DataBars.ReputationWidth, C.DataBars.ReputationHeight)
Anchor:SetPoint("TOP", Minimap, "BOTTOM", 0, -63)
Movers:RegisterFrame(Anchor)

local ReputationBar = CreateFrame("StatusBar", nil, UIParent)
ReputationBar:SetOrientation("HORIZONTAL")
ReputationBar:SetSize(C.DataBars.ReputationWidth, C.DataBars.ReputationHeight)
ReputationBar:SetPoint("CENTER", ReputationAnchor, "CENTER", 0, 0)
ReputationBar:SetStatusBarTexture(C.Media.Texture)

K.CreateBorder(ReputationBar, -1)
ReputationBar:SetBackdrop({bgFile = C.Media.Blank,insets = {left = -1, right = -1, top = -1, bottom = -1}})
ReputationBar:SetBackdropColor(unpack(C.Media.Backdrop_Color))

ReputationBar.Text = ReputationBar:CreateFontString(nil, "OVERLAY")
ReputationBar.Text:SetFont(C.Media.Font, C.Media.Font_Size - 1)
ReputationBar.Text:SetShadowOffset(K.Mult, -K.Mult)
ReputationBar.Text:SetPoint("LEFT", ReputationBar, "RIGHT", 0, 0)
ReputationBar.Text:SetPoint("RIGHT", ReputationBar, "LEFT", 0, 0)
ReputationBar.Text:SetHeight(C.Media.Font_Size)
ReputationBar.Text:SetTextColor(1, 1, 1)
ReputationBar.Text:SetJustifyH("CENTER")

if C.Blizzard.ColorTextures == true then
	ReputationBar:SetBackdropBorderColor(unpack(C.Blizzard.TexturesColor))
end

ReputationBar:SetScript("OnMouseUp", function()
	ToggleCharacter("ReputationFrame")
end)

local function UpdateReputationBar()
	local isFriend, friendText, standingLabel
	local FactionStandingLabelUnknown = UNKNOWN
	local Name, ID, Min, Max, Value = GetWatchedFactionInfo()

	if not Name then
		ReputationBar:Hide()
	elseif Name and not InCombatLockdown() then
		ReputationBar:Show()

		if ID then
			standingLabel = _G["FACTION_STANDING_LABEL"..ID]
		else
			standingLabel = FactionStandingLabelUnknown
		end

		local Text = format("%s: %d%% [%s]", Name, ((Value - Min) / (Max - Min) * 100), isFriend and friendText or standingLabel)
		if C.DataBars.InfoText then
			ReputationBar.Text:SetText(Text)
		else
			ReputationBar.Text:SetText(nil)
		end

		ReputationBar:SetMinMaxValues(Min, Max)
		ReputationBar:SetValue(Value)
		ReputationBar:SetStatusBarColor(Colors[ID].r, Colors[ID].g, Colors[ID].b)
	end
end

ReputationBar:SetScript("OnEnter", function(self)
	local Name, ID, Min, Max, Value = GetWatchedFactionInfo()

	GameTooltip:ClearLines()
	GameTooltip:SetOwner(self, "ANCHOR_CURSOR", 0, -4)

	GameTooltip:AddLine(format("%s (%s)", Name, _G["FACTION_STANDING_LABEL" .. ID]))
	GameTooltip:AddLine(format("%d / %d (%d%%)", Value - Min, Max - Min, (Value - Min) / (Max - Min) * 100))

	GameTooltip:Show()
end)

if C.DataBars.ReputationFade then
	ReputationBar:SetAlpha(0)
	ReputationBar:HookScript("OnEnter", function(self) self:SetAlpha(1) end)
	ReputationBar:HookScript("OnLeave", function(self) self:SetAlpha(0) end)
	ReputationBar.Tooltip = true
end

ReputationBar:RegisterEvent("PLAYER_ENTERING_WORLD")
ReputationBar:RegisterEvent("UPDATE_FACTION")
ReputationBar:RegisterEvent("PLAYER_LEVEL_UP")
ReputationBar:SetScript("OnLeave", function() GameTooltip:Hide() end)
ReputationBar:SetScript("OnEvent", UpdateReputationBar)