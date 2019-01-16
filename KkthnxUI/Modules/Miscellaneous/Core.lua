local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("Miscellaneous", "AceEvent-3.0")

local _G = _G
local select = select

local GetBattlefieldStatus = _G.GetBattlefieldStatus
local GetCVarBool = _G.GetCVarBool
local GetLFGDungeonInfo = _G.GetLFGDungeonInfo
local GetLFGDungeonRewards = _G.GetLFGDungeonRewards
local GetLFGRandomDungeonInfo = _G.GetLFGRandomDungeonInfo
local GetMaxBattlefieldID = _G.GetMaxBattlefieldID
local GetNumRandomDungeons = _G.GetNumRandomDungeons
local GetZoneText = _G.GetZoneText
local hooksecurefunc = _G.hooksecurefunc
local PlaySound = _G.PlaySound
local PlaySoundFile = _G.PlaySoundFile
local StaticPopup_Hide = _G.StaticPopup_Hide
local StaticPopupDialogs = _G.StaticPopupDialogs
local SOUNDKIT = _G.SOUNDKIT

local RESURRECTION_REQUEST_SOUND = "Sound\\Spells\\Resurrection.ogg"
local BATTLEGROUNDS = {
	["Wintergrasp"] = true,
	["Tol Barad"] = true,
	["Isle of Conquest"] = true,
	["Strand of the Ancients"] = true,
	["Alterac Valley"] = true,
	["Warsong Gulch"] = true,
	["Twin Peaks"] = true,
	["Arathi Basin"] = true,
	["Eye of the Storm"] = true,
	["Battle for Gilneas"] = true,
	["Deepwind Gorge"] = true,
	["Silvershard Mines"] = true,
	["The Battle for Gilneas"] = true,
	["Temple of Kotmogu"] = true
}

-- Fix UIErrorsFrame framelevel
UIErrorsFrame:SetFrameLevel(0)

-- Auto-accept replacing enchants
function Module:REPLACE_ENCHANT()
	if (TradeSkillFrame and TradeSkillFrame:IsShown()) then
		ReplaceEnchant()
		StaticPopup_Hide("REPLACE_ENCHANT")
	end
end

hooksecurefunc("StaticPopup_Show", function(popup, _, _, data)
	if (popup == "CONFIRM_LEARN_SPEC" and (not data.previewSpecCost or data.previewSpecCost <= 0)) then
		-- Auto-confirm changing specs
		StaticPopup_Hide(popup)
		SetSpecialization(data.previewSpec, data.isPet)
	elseif (popup == "ABANDON_QUEST") then
		-- Avoid having to click abandon twice
		StaticPopup_Hide(popup)
		StaticPopupDialogs[popup].OnAccept()
	end
end)

function Module:MERCHANT_CONFIRM_TRADE_TIMER_REMOVAL()
	StaticPopup_Hide("CONFIRM_MERCHANT_TRADE_TIMER_REMOVAL")
	SellCursorItem()
end

-- Add movement speed back to the CharacterFrame
hooksecurefunc("PaperDollFrame_SetMovementSpeed", function(self)
	self:Show()
end)
table.insert(PAPERDOLL_STATCATEGORIES[1].stats, {stat = "MOVESPEED"})

if C["General"].AutoScale then
	local scaleBtn = CreateFrame("Button", "KkthnxUIScaleBtn", Advanced_, "UIPanelButtonTemplate")
	scaleBtn:SetSize(200, 24)
	scaleBtn:SetText(L["Miscellaneous"].KkthnxUI_Scale_Button)
	scaleBtn:SetPoint("LEFT", Advanced_UseUIScale, "LEFT", 4, -70)
	scaleBtn:SetScript("OnClick", function()
		if (not KkthnxUIConfig) then
			K.Print(L["Miscellaneous"].Config_Not_Found)
			return
		end

		if (not KkthnxUIConfigFrame) then
			KkthnxUIConfig:CreateConfigWindow()
		end

		if KkthnxUIConfigFrame:IsVisible() then
			KkthnxUIConfigFrame:Hide()
		else
			HideUIPanel(VideoOptionsFrame)
			HideUIPanel(GameMenuFrame)
			KkthnxUIConfigFrame:Show()
		end
	end)
end

if C["General"].LagTolerance == true then
	local LagTolerance = CreateFrame("Frame")
	local int = 5
	local _, _, _, lag = GetNetStats()
	local LatencyUpdate = function(_, elapsed)
		int = int - elapsed
		if int < 0 then
			if lag ~= 0 and lag <= 400 then
				K.LockCVar("SpellQueueWindow", tostring(lag))
			end

			int = 5
		end
	end

	LagTolerance:SetScript("OnUpdate", LatencyUpdate)
	LatencyUpdate(LagTolerance, 10)
end

-- Force readycheck warning
local function ShowReadyCheckHook(_, initiator)
	if initiator ~= "player" then
		PlaySound(SOUNDKIT.READY_CHECK, "Master")
	end
end
hooksecurefunc("ShowReadyCheck", ShowReadyCheckHook)

-- Force lockActionBars CVar
local ForceActionBarCVar = CreateFrame("Frame")
ForceActionBarCVar:RegisterEvent("PLAYER_ENTERING_WORLD")
ForceActionBarCVar:RegisterEvent("CVAR_UPDATE")
ForceActionBarCVar:SetScript("OnEvent", function()
	if not GetCVarBool("lockActionBars") and C["ActionBar"].Enable then
		K.LockCVar("lockActionBars", 1)
	end
end)

-- Force other warnings
local ForceWarning = CreateFrame("Frame")
ForceWarning:RegisterEvent("UPDATE_BATTLEFIELD_STATUS")
ForceWarning:RegisterEvent("PET_BATTLE_QUEUE_PROPOSE_MATCH")
ForceWarning:RegisterEvent("LFG_PROPOSAL_SHOW")
ForceWarning:RegisterEvent("RESURRECT_REQUEST")
ForceWarning:SetScript("OnEvent", function(_, event)
	if event == "UPDATE_BATTLEFIELD_STATUS" then
		for i = 1, GetMaxBattlefieldID() do
			local status = GetBattlefieldStatus(i)
			if status == "confirm" then
				PlaySound(SOUNDKIT.UI_PET_BATTLES_PVP_THROUGH_QUEUE, "Master")
				break
			end
		end
	elseif event == "PET_BATTLE_QUEUE_PROPOSE_MATCH" then
		PlaySound(SOUNDKIT.UI_PET_BATTLES_PVP_THROUGH_QUEUE)
	elseif event == "LFG_PROPOSAL_SHOW" then
		PlaySound(SOUNDKIT.READY_CHECK)
	elseif event == "RESURRECT_REQUEST" then
		PlaySoundFile(RESURRECTION_REQUEST_SOUND, "Master")
	end
end)

-- Auto select current event boss from LFD tool(EventBossAutoSelect by Nathanyel)
local firstLFD
LFDParentFrame:HookScript("OnShow", function()
	if not firstLFD then
		firstLFD = 1
		for i = 1, GetNumRandomDungeons() do
			local id = GetLFGRandomDungeonInfo(i)
			local isHoliday = select(15, GetLFGDungeonInfo(id))
			if isHoliday and not GetLFGDungeonRewards(id) then
				LFDQueueFrame_SetType(id)
			end
		end
	end
end)

-- Remove boss emote spam during battlegrounds (ArathiBasin SpamFix by Partha)
local RaidBossEmoteFrame, spamDisabled = RaidBossEmoteFrame
function Module:ToggleBossEmotes()
	if BATTLEGROUNDS[GetZoneText()] then
		RaidBossEmoteFrame:UnregisterEvent("RAID_BOSS_EMOTE")
		spamDisabled = true
	elseif spamDisabled then
		RaidBossEmoteFrame:RegisterEvent("RAID_BOSS_EMOTE")
		spamDisabled = false
	end
end

function Module:PLAYER_ENTERING_WORLD()
	if not SetView == 3 then
		SetView(3)
		ResetView(3)
		if K.CodeDebug then
			K.Print("|cFFFF0000DEBUG:|r |cFF808080Line 187 - KkthnxUI|Modules|Miscellaneous|Core -|r |cFFFFFF00SetView was not 3|r")
		end
	else
		if K.CodeDebug then
			K.Print("|cFFFF0000DEBUG:|r |cFF808080Line 187 - KkthnxUI|Modules|Miscellaneous|Core -|r |cFFFFFF00SetView is 3|r")
		end
	end
end

function Module:OnEnable()
	self:RegisterEvent("REPLACE_ENCHANT")
	self:RegisterEvent("MERCHANT_CONFIRM_TRADE_TIMER_REMOVAL")

	if C["Misc"].BattlegroundSpam == true then
		self:RegisterEvent("PLAYER_ENTERING_WORLD", "ToggleBossEmotes")
		self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "ToggleBossEmotes")
	end

	self:RegisterEvent("PLAYER_ENTERING_WORLD")

	if C["Misc"].ImprovedStats == true then
		self:MissingStats()
	end
end