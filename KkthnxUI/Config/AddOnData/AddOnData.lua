local K, C, L = unpack(select(2, ...))

local _G = _G
local print = print

local ReloadUI = _G.ReloadUI
local StaticPopup_Show = _G.StaticPopup_Show

-- GLOBALS: InstallStepComplete

local function SetupAddons()
	-- DBM
	if K.CheckAddOnState("DBM-Core") and K.CheckAddOnState("DBM-StatusBarTimers") then
		K.LoadDBMProfile()
	end

	-- !BugGrabber
	if K.CheckAddOnState("!BugGrabber") then
		K.LoadBugGrabberProfile()
	end

	-- BugSack
	if K.CheckAddOnState("BugSack") then
		K.LoadBugSackProfile()
	end

	-- Details
	if K.CheckAddOnState("Details") then
		K.LoadDetailsProfile()
	end

	-- MikScrollingBattleText
	if K.CheckAddOnState("MikScrollingBattleText") then
		K.LoadMSBTProfile()
	end

	-- Pawn
	if K.CheckAddOnState("Pawn") then
		K.LoadPawnProfile()
	end

	-- Recount
	if K.CheckAddOnState("Recount") then
		K.LoadRecountProfile()
	end

	-- Skada
	if K.CheckAddOnState("Skada") then
		K.LoadSkadaProfile()
	end

	-- BigWigs
	if K.CheckAddOnState("BigWigs") then
		K.LoadBigWigsProfile()
	end
end

function K.AddOnSettings(msg)
	if msg == "skada" then
		if K.CheckAddOnState("Skada") then
			K.LoadSkadaProfile(true)
			StaticPopup_Show("CHANGES_RL")
			print("|cffffff00".."Skada profile loaded".."|r")
		else
			print("|CFFFF0000AddOn Skada is not loaded!|r")
		end
	elseif msg == "dbm" then
		if K.CheckAddOnState("DBM-Core") then
			K.LoadDBMProfile()
			StaticPopup_Show("CHANGES_RL")
			print("|cffffff00".."DBM profile loaded".."|r")
		else
			print("|CFFFF0000AddOn DeadlyBossMods is not loaded!|r")
		end
	elseif msg == "bigwigs" then
		if K.CheckAddOnState("BigWigs") then
			K.LoadBigWigsProfile()
			StaticPopup_Show("CHANGES_RL")
			print("|cffffff00".."BigWigs profile loaded".."|r")
		else
			print("|CFFFF0000AddOn BigWigs is not loaded!|r")
		end
	elseif msg == "pawn" then
		if K.CheckAddOnState("Pawn") then
			K.LoadPawnProfile()
			StaticPopup_Show("CHANGES_RL")
			print("|cffffff00".."Pawn profile loaded".."|r")
		else
			print("|CFFFF0000AddOn Pawn is not loaded!|r")
		end
	elseif msg == "msbt" then
		if K.CheckAddOnState("MikScrollingBattleText") then
			K.LoadMSBTProfile()
			StaticPopup_Show("CHANGES_RL")
			print("|cffffff00".."MikScrollingBattleText profile loaded".."|r")
		else
			print("|CFFFF0000AddOn MikScrollingBattleText is not loaded!|r")
		end
	elseif msg == "bugsack" then
		if K.CheckAddOnState("BugSack") then
			K.LoadBugSackProfile()
			StaticPopup_Show("CHANGES_RL")
			print("|cffffff00".."BugSack profile loaded".."|r")
		else
			print("|CFFFF0000AddOn BugSack is not loaded!|r")
		end
	elseif msg == "buggrabber" then
		if K.CheckAddOnState("!BugGrabber") then
			K.LoadBugGrabberProfile()
			StaticPopup_Show("CHANGES_RL")
			print("|cffffff00".."BugSack profile loaded".."|r")
		else
			print("|CFFFF0000AddOn !BugGrabber is not loaded!|r")
		end
	elseif msg == "bt4" or msg == "bartender" then
		if K.CheckAddOnState("Bartender4") then
			K.LoadBartenderProfile()
			StaticPopup_Show("CHANGES_RL")
			print("|cffffff00".."Bartender4 profile loaded".."|r")
		else
			print("|CFFFF0000AddOn Bartender4 is not loaded!|r")
		end
	elseif msg == "all" or msg == "addons" then
		SetupAddons()
		K.Print("All supported AddOn profiles loaded, if the AddOn is loaded!")
	else
		print("|cffffff00The following commands are supported for AddOn profiles.|r")
		print(" ")
		print("|cff00ff00/settings dbm|r, to apply the settings |cff00ff00DeadlyBossMods.|cff00ff00")
		print("|cff00ff00/settings msbt|r, to apply the settings |cff00ff00MikScrollingBattleText.|cff00ff00")
		print("|cff00ff00/settings skada|r, to apply the settings |cff00ff00Skada.|cff00ff00")
		print("|cff00ff00/settings bt4 or bartender|r, to apply the settings |cff00ff00Bartender4.|cff00ff00")
		print("|cff00ff00/settings buggrabber|r, to apply the settings |cff00ff00!BugGrabber.|cff00ff00")
		print("|cff00ff00/settings bugsack|r, to apply the settings |cff00ff00BugSack.|cff00ff00")
		print("|cff00ff00/settings pawn|r, to apply the settings |cff00ff00Pawn.|cff00ff00")
		print("|cff00ff00/settings bigwigs|r, to apply the settings |cff00ff00BigWigs.|cff00ff00")
		print("|cff00ff00/settings all|r, to apply settings for all supported AddOns, if that AddOn is loaded!")
		print(" ")
	end
end
K:RegisterChatCommand("settings", K.AddOnSettings)