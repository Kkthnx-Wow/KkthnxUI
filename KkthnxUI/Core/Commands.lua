local K, C, L, _ = select(2, ...):unpack()

local _G = _G
local format, lower = string.format, string.lower
local ipairs = ipairs
local print, tostring, select = print, tostring, select

local EnableAddOn, DisableAllAddOns = EnableAddOn, DisableAllAddOns
local FrameStackTooltip_Toggle = FrameStackTooltip_Toggle
local GetAddOnInfo = GetAddOnInfo
local GetMouseFocus = GetMouseFocus
local GetNumPartyMembers, GetNumRaidMembers = GetNumPartyMembers, GetNumRaidMembers
local GetNumQuestLogEntries = GetNumQuestLogEntries
local IsAddOnLoaded = IsAddOnLoaded
local IsInInstance = IsInInstance
local ReloadUI = ReloadUI
local ResetCPUUsage = ResetCPUUsage
local SetCVar = SetCVar
local UpdateAddOnCPUUsage, GetAddOnCPUUsage = UpdateAddOnCPUUsage, GetAddOnCPUUsage
local debugprofilestart, debugprofilestop = debugprofilestart, debugprofilestop

-- Ready Check
SlashCmdList.RCSLASH = function() DoReadyCheck() end
SLASH_RCSLASH1 = "/rc"

-- Help Frame.
SlashCmdList.TICKET = function() ToggleHelpFrame() end
SLASH_TICKET1 = "/gm"

-- Fix The CombatLog.
SlashCmdList.CLEARCOMBAT = function() CombatLogClearEntries() K.Print("|cffffe02eCombatLog has been cleared & fixed.|r") end
SLASH_CLEARCOMBAT1 = "/clearcombat"
SLASH_CLEARCOMBAT2 = "/clfix"

-- Here we can restart wow's engine. Could be use for sound issues and more.
SlashCmdList.GFXENGINE = function() RestartGx() end
SLASH_GFXENGINE1 = "/restartgfx"
SLASH_GFXENGINE2 = "/fixgfx"

-- Clear all quests in questlog
SlashCmdList.CLEARQUESTS = function()
	for i = 1, GetNumQuestLogEntries() do SelectQuestLogEntry(i) SetAbandonQuest() AbandonQuest() end
end
SLASH_CLEARQUESTS1 = "/clearquests"
SLASH_CLEARQUESTS2 = "/clquests"

-- KkthnxUI Help Commands
SlashCmdList.UIHELP = function()
	for i, v in ipairs(L_SLASHCMD_HELP) do print("|cffffe02e"..("%s"):format(tostring(v)).."|r") end
end
SLASH_UIHELP1 = "/uihelp"
SLASH_UIHELP2 = "/helpui"
SLASH_UIHELP3 = "/kkthnxui"

SLASH_SCALE1 = "/uiscale"
SlashCmdList["SCALE"] = function() 
	SetCVar("uiScale", 768/string.match(({GetScreenResolutions()})[GetCurrentResolution()], "%d+x(%d+)"))
end

-- Disband party or raid (by Monolit)
SlashCmdList["GROUPDISBAND"] = function()
	SendChatMessage(L_INFO_DISBAND, "RAID" or "PARTY")
	if UnitInRaid("player") then
		for i = 1, GetNumRaidMembers() do
			local name, _, _, _, _, _, _, online = GetRaidRosterInfo(i)
			if online and name ~= K.Name then
				UninviteUnit(name)
			end
		end
	else
		for i = MAX_PARTY_MEMBERS, 1, -1 do
			if GetPartyMember(i) then
				UninviteUnit(UnitName("party"..i))
			end
		end
	end
	LeaveParty()
end
SLASH_GROUPDISBAND1 = "/rd"

-- Enable LUA error by command
function SlashCmdList.LUAERROR(msg)
	msg = lower(msg)
	if(msg == "on") then
		DisableAllAddOns()
		EnableAddOn("KkthnxUI")
		EnableAddOn("KkthnxUI_Config")
		SetCVar("scriptErrors", 1)
		ReloadUI()
	elseif(msg == "off") then
		SetCVar("scriptErrors", 0)
		K.Print("Lua errors off.")
	else
		K.Print("/luaerror on - /luaerror off")
	end
end
SLASH_LUAERROR1 = "/luaerror"

-- Convert party to raid
SlashCmdList.PARTYTORAID = function()
	if GetNumPartyMembers() > 0 then
		if UnitInParty("player") and IsGroupLeader() then
			ConvertToRaid()
		end
	else
		K.Print("|cffffe02e"..ERR_NOT_IN_GROUP.."|r")
	end
end
SLASH_PARTYTORAID1 = "/toraid"
SLASH_PARTYTORAID2 = "/convert"

-- Instance teleport
SlashCmdList.INSTTELEPORT = function()
	local inInstance = IsInInstance()
	if inInstance then
		LFGTeleport(true)
	else
		LFGTeleport()
	end
end
SLASH_INSTTELEPORT1 = "/teleport"

-- Spec switching(by Monolit)
SlashCmdList["SPEC"] = function()
	local spec = GetActiveTalentGroup()
	if spec == 1 then SetActiveTalentGroup(2) elseif spec == 2 then SetActiveTalentGroup(1) end
end
SLASH_SPEC1 = "/ss"
SLASH_SPEC2 = "/spec"

-- Deadly Boss Mods Testing.
SlashCmdList.DBMTEST = function() if (select(4, GetAddOnInfo("DBM-Core"))) then DBM:DemoMode() end end
SLASH_DBMTEST1 = "/dbmtest"

-- Clear Chat
SlashCmdList.CLEARCHAT = function(cmd)
	cmd = cmd and strtrim(strlower(cmd))
	for i = 1, NUM_CHAT_WINDOWS do
		local f = _G["ChatFrame"..i]
		if f:IsVisible() or cmd == "all" then
			f:Clear()
		end
	end
end
SLASH_CLEARCHAT1 = "/cc"
SLASH_CLEARCHAT2 = "/clearchat"

-- Test Blizzard Alert Frames
SlashCmdList.TEST_ACHIEVEMENT = function()
	PlaySound("LFG_Rewards")
	if not AchievementFrame then
		AchievementFrame_LoadUI()
	end
	AchievementAlertFrame_ShowAlert(229)
	AchievementAlertFrame_ShowAlert(1707)
end
SLASH_TEST_ACHIEVEMENT1 = "/testa"

-- Grid on screen
local grid
SlashCmdList.GRIDONSCREEN = function()
	if grid then
		grid:Hide()
		grid = nil
	else
		grid = CreateFrame("Frame", nil, UIParent)
		grid:SetAllPoints(UIParent)
		local width = K.ScreenWidth / 128
		local height = K.ScreenHeight / 72
		for i = 0, 128 do
			local texture = grid:CreateTexture(nil, "BACKGROUND")
			if i == 64 then
				texture:SetColorTexture(46/255, 181/255, 255/255, 0.8)
			else
				texture:SetColorTexture(0/255, 0/255, 0/255, 0.8)
			end
			texture:SetPoint("TOPLEFT", grid, "TOPLEFT", i * width - 1, 0)
			texture:SetPoint("BOTTOMRIGHT", grid, "BOTTOMLEFT", i * width, 0)
		end
		for i = 0, 72 do
			local texture = grid:CreateTexture(nil, "BACKGROUND")
			if i == 36 then
				texture:SetColorTexture(46/255, 181/255, 255/255, 0.8)
			else
				texture:SetColorTexture(0/255, 0/255, 0/255, 0.8)
			end
			texture:SetPoint("TOPLEFT", grid, "TOPLEFT", 0, -i * height)
			texture:SetPoint("BOTTOMRIGHT", grid, "TOPRIGHT", 0, -i * height - 1)
		end
	end
end
SLASH_GRIDONSCREEN1 = "/align"
SLASH_GRIDONSCREEN2 = "/grid"

-- Reduce video settings to optimize performance
local function BoostUI()

	SetCVar("environmentDetail", 0.5)
	SetCVar("extshadowquality", 0)
	SetCVar("farclip", 500)
	SetCVar("ffx", 0)
	SetCVar("groundeffectdensity", 16)
	SetCVar("groundeffectdist", 1)
	SetCVar("hwPCF", 1)
	SetCVar("m2Faster", 1)
	SetCVar("shadowLOD", 0)
	SetCVar("showfootprintparticles", 0)
	SetCVar("showfootprints", 0)
	SetCVar("skycloudlod", 1)
	SetCVar("timingmethod", 1)
	SetMultisampleFormat(1)

	StaticPopup_Show("BOOST_UI_RELOAD")
end

-- Add a warning so we do not piss people off.
StaticPopupDialogs.BOOST_UI = {
	text = L_POPUP_BOOSTUI,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = BoostUI,
	showAlert = true,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = true,
	preferredIndex = 3,
}

SLASH_BOOSTUI1 = "/boost"
SLASH_BOOSTUI2 = "/boostui"
SlashCmdList.BOOSTUI = function() StaticPopup_Show("BOOST_UI") end

StaticPopupDialogs.BOOST_UI_RELOAD = {
	text = L_POPUP_RELOADUI,
	button1 = ACCEPT,
	button2 = CANCEL,
	OnAccept = function() ReloadUI() end,
	timeout = 0,
	whileDead = 1,
	hideOnEscape = false,
	preferredIndex = 3,
}
