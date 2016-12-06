local K, C, L = select(2, ...):unpack()
if C.DataText.Battleground ~= true or C.DataText.BottomBar ~= true then return end

-- Lua API
local format = string.format

-- Wow API
local GetBattlefieldScore = GetBattlefieldScore
local GetBattlefieldStatData = GetBattlefieldStatData
local GetCurrentMapAreaID = GetCurrentMapAreaID
local GetNumBattlefieldScores = GetNumBattlefieldScores
local IsInInstance = IsInInstance
local RequestBattlefieldScoreData = RequestBattlefieldScoreData
local SetMapToCurrentZone = SetMapToCurrentZone

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: STATISTICS, HONORABLE_KILLS, DEATHS, DAMAGE, SHOW_COMBAT_HEALING, QueueStatusMinimapButton
-- GLOBALS: ToggleBattlefieldMinimap, ToggleWorldStateScoreFrame, COMBAT_HONOR_GAIN, KILLING_BLOWS, GameTooltip

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

local ClassColor = ("|cff%.2x%.2x%.2x"):format(K.Color.r * 255, K.Color.g * 255, K.Color.b * 255)

local bgframe = KkthnxUIInfoBottomBattleGround
bgframe:SetScript("OnEnter", function(self)
	local numScores = GetNumBattlefieldScores()
	for i = 1, numScores do
		local name, _, honorableKills, deaths, _, _, _, _, _, damageDone, healingDone = GetBattlefieldScore(i)
		if name and name == K.Name then
			local curmapid = GetCurrentMapAreaID()
			SetMapToCurrentZone()
			GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, K.Scale(4))
			GameTooltip:ClearLines()
			GameTooltip:SetPoint("BOTTOM", self, "TOP", 0, 1)
			GameTooltip:ClearLines()
			GameTooltip:AddDoubleLine(STATISTICS, ClassColor..name.."|r")
			GameTooltip:AddLine(" ")
			GameTooltip:AddDoubleLine(HONORABLE_KILLS..":", honorableKills, 1, 1, 1)
			GameTooltip:AddDoubleLine(DEATHS..":", deaths, 1, 1, 1)
			GameTooltip:AddDoubleLine(DAMAGE..":", damageDone, 1, 1, 1)
			GameTooltip:AddDoubleLine(SHOW_COMBAT_HEALING..":", healingDone, 1, 1, 1)
			-- Add extra statistics depending on what bg you are
			if curmapid == IOC or curmapid == TBFG or curmapid == AB or curmapid == ASH then
				GameTooltip:AddDoubleLine(L.DataText.BasesAssaulted, GetBattlefieldStatData(i, 1), 1, 1, 1)
				GameTooltip:AddDoubleLine(L.DataText.BasesDefended, GetBattlefieldStatData(i, 2), 1, 1, 1)
			elseif curmapid == WSG or curmapid == TP then
				GameTooltip:AddDoubleLine(L.DataText.FlagsCaptured, GetBattlefieldStatData(i, 1), 1, 1, 1)
				GameTooltip:AddDoubleLine(L.DataText.FlagsReturned, GetBattlefieldStatData(i, 2), 1, 1, 1)
			elseif curmapid == EOTS then
				GameTooltip:AddDoubleLine(L.DataText.FlagsCaptured, GetBattlefieldStatData(i, 1), 1, 1, 1)
			elseif curmapid == AV then
				GameTooltip:AddDoubleLine(L.DataText.GraveyardsAssaulted, GetBattlefieldStatData(i, 1), 1, 1, 1)
				GameTooltip:AddDoubleLine(L.DataText.GraveyardsDefended, GetBattlefieldStatData(i, 2), 1, 1, 1)
				GameTooltip:AddDoubleLine(L.DataText.TowersAssaulted, GetBattlefieldStatData(i, 3), 1, 1, 1)
				GameTooltip:AddDoubleLine(L.DataText.TowersDefended, GetBattlefieldStatData(i, 4), 1, 1, 1)
			elseif curmapid == SOTA then
				GameTooltip:AddDoubleLine(L.DataText.DemolishersDestroyed, GetBattlefieldStatData(i, 1), 1, 1, 1)
				GameTooltip:AddDoubleLine(L.DataText.GatesDestroyed, GetBattlefieldStatData(i, 2), 1, 1, 1)
			elseif curmapid == TOK then
				GameTooltip:AddDoubleLine(L.DataText.OrbPossessions, GetBattlefieldStatData(i, 1), 1, 1, 1)
				GameTooltip:AddDoubleLine(L.DataText.VictoryPoints, GetBattlefieldStatData(i, 2), 1, 1, 1)
			elseif curmapid == SSM then
				GameTooltip:AddDoubleLine(L.DataText.CartsControlled, GetBattlefieldStatData(i, 1), 1, 1, 1)
			elseif curmapid == DG then
				GameTooltip:AddDoubleLine(L.DataText.CartsControlled, GetBattlefieldStatData(i, 1), 1, 1, 1)
				GameTooltip:AddDoubleLine(L.DataText.BasesAssaulted, GetBattlefieldStatData(i, 3), 1, 1, 1)
				GameTooltip:AddDoubleLine(L.DataText.BasesDefended, GetBattlefieldStatData(i, 4), 1, 1, 1)
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

local Text1 = KkthnxUIInfoBottomBattleGround:CreateFontString(nil, "OVERLAY")
Text1:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
Text1:SetPoint("LEFT", 30, 0)
Text1:SetHeight(KkthnxUIDataTextBottomBar:GetHeight())

local Text2 = KkthnxUIInfoBottomBattleGround:CreateFontString(nil, "OVERLAY")
Text2:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
Text2:SetPoint("CENTER", 0, 0)
Text2:SetHeight(KkthnxUIDataTextBottomBar:GetHeight())

local Text3 = KkthnxUIInfoBottomBattleGround:CreateFontString(nil, "OVERLAY")
Text3:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
Text3:SetPoint("RIGHT", -30, 0)
Text3:SetHeight(KkthnxUIDataTextBottomBar:GetHeight())

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
				dmgtxt = (ClassColor..SHOW_COMBAT_HEALING.." :|r "..K.ShortValue(healingDone))
			else
				dmgtxt = (ClassColor..DAMAGE.." :|r "..K.ShortValue(damageDone))
			end
			if name and name == K.Name then
				Text1:SetText(dmgtxt)
				Text2:SetText(ClassColor..COMBAT_HONOR_GAIN.." :|r "..format("%d", honorGained))
				Text3:SetText(ClassColor..KILLING_BLOWS.." :|r "..killingBlows)
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