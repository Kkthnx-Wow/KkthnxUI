local K, C, L = select(2, ...):unpack()
if C.DataText.Battleground ~= true then return end

-- LUA API
local unpack = unpack
local format = string.format

-- WOW API
local CreateFrame, UIParent = CreateFrame, UIParent
local GetNumBattlefieldScores = GetNumBattlefieldScores
local GetCurrentMapAreaID = GetCurrentMapAreaID
local IsInInstance = IsInInstance

-- MAP IDS
-- http://wow.gamepedia.com/MapID
local WSG = 443
local TP = 626
local AV = 401
local SOTA = 512
local IOC = 540
local EOTS = 482
local TBFG = 736
local AB = 461
local TOK = 856
local SSM = 860
local DG = 935
local ASH = 978

local classcolor = ("|cff%.2x%.2x%.2x"):format(K.Color.r * 255, K.Color.g * 255, K.Color.b * 255)

local bgframe = CreateFrame("Frame", "InfoBattleGround", UIParent)
bgframe:CreatePanel("Invisible", 300, C.Media.Font_Size, unpack(C.Position.BGScore))
bgframe:EnableMouse(true)
bgframe:SetScript("OnEnter", function(self)
	local numScores = GetNumBattlefieldScores()
	for i = 1, numScores do
		local name, _, honorableKills, deaths, _, _, _, _, _, damageDone, healingDone = GetBattlefieldScore(i)
		if name and name == K.Name then
			local curmapid = GetCurrentMapAreaID()
			SetMapToCurrentZone()
			GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", -8, -4)
			GameTooltip:ClearLines()
			GameTooltip:SetPoint("TOP", self, "BOTTOM", 0, -1)
			GameTooltip:ClearLines()
			GameTooltip:AddDoubleLine(STATISTICS, classcolor..name.."|r")
			GameTooltip:AddLine(" ")
			GameTooltip:AddDoubleLine(HONORABLE_KILLS..":", honorableKills, 1, 1, 1)
			GameTooltip:AddDoubleLine(DEATHS..":", deaths, 1, 1, 1)
			GameTooltip:AddDoubleLine(DAMAGE..":", damageDone, 1, 1, 1)
			GameTooltip:AddDoubleLine(SHOW_COMBAT_HEALING..":", healingDone, 1, 1, 1)
			-- Add extra statistics depending on what bg you are
			if curmapid == IOC or curmapid == TBFG or curmapid == AB or curmapid == ASH then
				GameTooltip:AddDoubleLine(L_DATATEXT_BASESASSAULTED, GetBattlefieldStatData(i, 1), 1, 1, 1)
				GameTooltip:AddDoubleLine(L_DATATEXT_BASESDEFENDED, GetBattlefieldStatData(i, 2), 1, 1, 1)
			elseif curmapid == WSG or curmapid == TP then
				GameTooltip:AddDoubleLine(L_DATATEXT_FLAGSCAPTURED, GetBattlefieldStatData(i, 1), 1, 1, 1)
				GameTooltip:AddDoubleLine(L_DATATEXT_FLAGSRETURNED, GetBattlefieldStatData(i, 2), 1, 1, 1)
			elseif curmapid == EOTS then
				GameTooltip:AddDoubleLine(L_DATATEXT_FLAGSCAPTURED, GetBattlefieldStatData(i, 1), 1, 1, 1)
			elseif curmapid == AV then
				GameTooltip:AddDoubleLine(L_DATATEXT_GRAVEYARDSASSAULTED, GetBattlefieldStatData(i, 1), 1, 1, 1)
				GameTooltip:AddDoubleLine(L_DATATEXT_GRAVEYARDSDEFENDED, GetBattlefieldStatData(i, 2), 1, 1, 1)
				GameTooltip:AddDoubleLine(L_DATATEXT_TOWERSASSAULTED, GetBattlefieldStatData(i, 3), 1, 1, 1)
				GameTooltip:AddDoubleLine(L_DATATEXT_TOWERSDEFENDED, GetBattlefieldStatData(i, 4), 1, 1, 1)
			elseif curmapid == SOTA then
				GameTooltip:AddDoubleLine(L_DATATEXT_DEMOLISHERSDESTROYED, GetBattlefieldStatData(i, 1), 1, 1, 1)
				GameTooltip:AddDoubleLine(L_DATATEXT_GATESDESTROYED, GetBattlefieldStatData(i, 2), 1, 1, 1)
			elseif curmapid == TOK then
				GameTooltip:AddDoubleLine(L_DATATEXT_ORB_POSSESSIONS, GetBattlefieldStatData(i, 1), 1, 1, 1)
				GameTooltip:AddDoubleLine(L_DATATEXT_VICTORY_POINTS, GetBattlefieldStatData(i, 2), 1, 1, 1)
			elseif curmapid == SSM then
				GameTooltip:AddDoubleLine(L_DATATEXT_CARTS_CONTROLLED, GetBattlefieldStatData(i, 1), 1, 1, 1)
			elseif curmapid == DG then
				GameTooltip:AddDoubleLine(L_DATATEXT_CARTS_CONTROLLED, GetBattlefieldStatData(i, 1), 1, 1, 1)
				GameTooltip:AddDoubleLine(L_DATATEXT_BASESASSAULTED, GetBattlefieldStatData(i, 3), 1, 1, 1)
				GameTooltip:AddDoubleLine(L_DATATEXT_BASESDEFENDED, GetBattlefieldStatData(i, 4), 1, 1, 1)
			end
			GameTooltip:Show()
		end
	end
end)

bgframe:SetScript("OnLeave", function(self) GameTooltip:Hide() end)
bgframe:SetScript("OnMouseUp", function(self, button)
	if QueueStatusMinimapButton:IsShown() then
		if button == "RightButton" then
			ToggleBattlefieldMinimap()
		else
			ToggleWorldStateScoreFrame()
		end
	end
end)

local Stat = CreateFrame("Frame")
Stat:EnableMouse(true)

local Text1 = InfoBattleGround:CreateFontString(nil, "OVERLAY")
Text1:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
Text1:SetShadowOffset(0, 0)
Text1:SetPoint("LEFT", 5, 0)
Text1:SetHeight(C.Media.Font_Size)

local Text2 = InfoBattleGround:CreateFontString(nil, "OVERLAY")
Text2:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
Text2:SetShadowOffset(0, 0)
Text2:SetPoint("LEFT", Text1, "RIGHT", 5, 0)
Text2:SetHeight(C.Media.Font_Size)

local Text3 = InfoBattleGround:CreateFontString(nil, "OVERLAY")
Text3:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
Text3:SetShadowOffset(0, 0)
Text3:SetPoint("LEFT", Text2, "RIGHT", 5, 0)
Text3:SetHeight(C.Media.Font_Size)

local int = 2
local function Update(self, t)
	int = int - t
	if int < 0 then
		local dmgtxt
		RequestBattlefieldScoreData()
		local numScores = GetNumBattlefieldScores()
		for i = 1, numScores do
			local name, killingBlows, _, _, honorGained, _, _, _, _, damageDone, healingDone = GetBattlefieldScore(i)
			if healingDone > damageDone then
				dmgtxt = (classcolor..SHOW_COMBAT_HEALING.." :|r "..K.ShortValue(healingDone))
			else
				dmgtxt = (classcolor..DAMAGE.." :|r "..K.ShortValue(damageDone))
			end
			if name and name == K.Name then
				Text1:SetText(dmgtxt)
				Text2:SetText(classcolor..COMBAT_HONOR_GAIN.." :|r "..format("%d", honorGained)) -- Honor no longer exsits in Legion??
				Text3:SetText(classcolor..KILLING_BLOWS.." :|r "..killingBlows)
			end
		end
		int = 2
	end
end

-- Hide text when not in an bg
local function OnEvent(self, event)
	if event == "PLAYER_ENTERING_WORLD" then
		local inInstance, instanceType = IsInInstance()
		if inInstance and (instanceType == "pvp") then
			bgframe:Show()
		else
			Text1:SetText("")
			Text2:SetText("")
			Text3:SetText("")
			bgframe:Hide()
		end
	end
end

Stat:RegisterEvent("PLAYER_ENTERING_WORLD")
Stat:SetScript("OnEvent", OnEvent)
Stat:SetScript("OnUpdate", Update)
Update(Stat, 2)