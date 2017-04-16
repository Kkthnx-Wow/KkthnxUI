local K, C, L = unpack(select(2, ...))
if C.DataBars.ReputationEnable ~= true then return end

-- WoW Lua
local _G = _G
local string_format = string.format

-- Wow API
local GetWatchedFactionInfo = _G.GetWatchedFactionInfo
local C_Reputation_GetFactionParagonInfo = _G.C_Reputation.GetFactionParagonInfo
local C_Reputation_IsFactionParagon = _G.C_Reputation.IsFactionParagon
local GetFriendshipReputation = _G.GetFriendshipReputation
local STANDING = _G.STANDING
local REPUTATION = _G.REPUTATION
local GetFactionInfo = _G.GetFactionInfo
local GetNumFactions = _G.GetNumFactions
local FACTION_BAR_COLORS = _G.FACTION_BAR_COLORS

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: ReputationFrame, ToggleCharacter, GameTooltip, UNKNOWN

local Colors = FACTION_BAR_COLORS
local Movers = K.Movers

local Anchor = CreateFrame("Frame", "ReputationAnchor", UIParent)
Anchor:SetSize(C.DataBars.ReputationWidth, C.DataBars.ReputationHeight)
Anchor:SetPoint("TOP", Minimap, "BOTTOM", 0, -67)
Movers:RegisterFrame(Anchor)

local ReputationBar = CreateFrame("StatusBar", nil, UIParent)
ReputationBar:SetOrientation("HORIZONTAL")
ReputationBar:SetSize(C.DataBars.ReputationWidth, C.DataBars.ReputationHeight)
ReputationBar:SetPoint("CENTER", ReputationAnchor, "CENTER", 0, 0)
ReputationBar:SetStatusBarTexture(C.Media.Texture)

ReputationBar.Spark = ReputationBar:CreateTexture(nil, "ARTWORK", nil, 1)
ReputationBar.Spark:SetSize(C.DataBars.ReputationHeight, C.DataBars.ReputationHeight * 2)
ReputationBar.Spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
ReputationBar.Spark:SetPoint("CENTER", ReputationBar:GetStatusBarTexture(), "RIGHT", 0, 0)
ReputationBar.Spark:SetAlpha(0.6)
ReputationBar.Spark:SetBlendMode("ADD")

K.CreateBorder(ReputationBar, -1)
ReputationBar:SetBackdrop({bgFile = C.Media.Blank,insets = {left = -1, right = -1, top = -1, bottom = -1}})
ReputationBar:SetBackdropColor(C.Media.Backdrop_Color[1], C.Media.Backdrop_Color[2], C.Media.Backdrop_Color[3], C.Media.Backdrop_Color[4])

ReputationBar.Text = ReputationBar:CreateFontString(nil, "OVERLAY")
ReputationBar.Text:SetFont(C.Media.Font, C.Media.Font_Size - 1)
ReputationBar.Text:SetShadowOffset(K.Mult, -K.Mult)
ReputationBar.Text:SetPoint("LEFT", ReputationBar, "RIGHT", 0, 0)
ReputationBar.Text:SetPoint("RIGHT", ReputationBar, "LEFT", 0, 0)
ReputationBar.Text:SetHeight(C.Media.Font_Size)
ReputationBar.Text:SetTextColor(1, 1, 1)
ReputationBar.Text:SetJustifyH("CENTER")

if C.Blizzard.ColorTextures == true then
	ReputationBar:SetBackdropBorderColor(C.Blizzard.TexturesColor[1], C.Blizzard.TexturesColor[2], C.Blizzard.TexturesColor[3])
end

ReputationBar:SetScript("OnMouseUp", function()
	ToggleCharacter("ReputationFrame")
end)

local BackupColor = FACTION_BAR_COLORS[1]
local FactionStandingLabelUnknown = UNKNOWN
local function UpdateReputationBar()
	local ID
	local IsFriend, FriendText, StandingLabel
	local Name, Reaction, Min, Max, Value, FactionID = GetWatchedFactionInfo()

	if (C_Reputation_IsFactionParagon(FactionID)) then
		local CurrentValue, Threshold = C_Reputation_GetFactionParagonInfo(FactionID)
		Min, Max, Value = 0, Threshold, CurrentValue
	end

	local NumFactions = GetNumFactions()

	if not Name then
		ReputationBar:Hide()
	elseif Name then
		ReputationBar:Show()

		local color = FACTION_BAR_COLORS[Reaction] or BackupColor
		ReputationBar:SetStatusBarColor(color.r, color.g, color.b)

		ReputationBar:SetMinMaxValues(Min, Max)
		ReputationBar:SetValue(Value)

		for i = 1, NumFactions do
			local FactionName, _, StandingID, _, _, _, _, _, _, _, _, _, _, FactionID = GetFactionInfo(i)
			local FriendID, _, _, _, _, _, FriendTextLevel = GetFriendshipReputation(FactionID)
			if FactionName == Name then
				if FriendID ~= nil then
					IsFriend = true
					FriendText = FriendTextLevel
				else
					ID = StandingID
				end
			end
		end

		if ID then
			StandingLabel = _G["FACTION_STANDING_LABEL"..ID]
		else
			StandingLabel = FactionStandingLabelUnknown
		end

		-- Prevent a division by zero
		local MaxMinDiff = Max - Min
		if (MaxMinDiff == 0) then
			MaxMinDiff = 1
		end

		local Text = string_format("%s: %d%% [%s]", Name, ((Value - Min) / (MaxMinDiff) * 100), IsFriend and FriendText or StandingLabel)

		if C.DataBars.InfoText then
			ReputationBar.Text:SetText(Text)
		else
			ReputationBar.Text:SetText("")
		end
	end
end

ReputationBar:SetScript("OnEnter", function(self)
	local Name, Reaction, Min, Max, Value, FactionID = GetWatchedFactionInfo()
	local FriendID, _, _, _, _, _, FriendTextLevel = GetFriendshipReputation(FactionID)

	if (C_Reputation_IsFactionParagon(FactionID)) then
		local CurrentValue, Threshold = C_Reputation_GetFactionParagonInfo(FactionID)
		Min, Max, Value = 0, Threshold, CurrentValue
	end

	GameTooltip:ClearLines()
	GameTooltip:SetOwner(self, "ANCHOR_CURSOR", 0, -4)

	if Name then
		GameTooltip:AddLine(Name)
		GameTooltip:AddLine(" ")

		GameTooltip:AddDoubleLine(STANDING..":", FriendID and FriendTextLevel or _G["FACTION_STANDING_LABEL"..Reaction], 1, 1, 1)
		GameTooltip:AddDoubleLine(REPUTATION..":", string_format("%d / %d (%d%%)", Value - Min, Max - Min, (Value - Min) / ((Max - Min == 0) and Max or (Max - Min)) * 100), 1, 1, 1)
	end
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine(L.DataBars.ReputationClick)

	GameTooltip:Show()
end)

if C.DataBars.ReputationFade then
	ReputationBar:SetAlpha(0)
	ReputationBar:HookScript("OnEnter", function(self) self:SetAlpha(1) end)
	ReputationBar:HookScript("OnLeave", function(self) self:SetAlpha(0) end)
	ReputationBar.Tooltip = true
end

ReputationBar:RegisterEvent("PLAYER_LOGIN")
ReputationBar:RegisterEvent("UPDATE_FACTION")
ReputationBar:SetScript("OnLeave", function() GameTooltip:Hide() end)
ReputationBar:SetScript("OnEvent", UpdateReputationBar)