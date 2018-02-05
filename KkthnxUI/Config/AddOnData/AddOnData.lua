local K, C, L = unpack(select(2, ...))

local _G = _G

local ReloadUI = _G.ReloadUI
local StaticPopup_Show = _G.StaticPopup_Show

-- GLOBALS: InstallStepComplete

local function SetupAddons()
	-- KkthnxUI
	--[[if K.CheckAddOnState("KkthnxUI") then
		K.LoadKkthnxUIProfile()
	end--]]

	-- DBM
	if K.CheckAddOnState("DBM-Core") then
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

SlashCmdList.SETTINGS = function(msg)
	if msg == "skada" then
		if K.CheckAddOnState("Skada") then
			K.LoadSkadaProfile(true)
			StaticPopup_Show("CHANGES_RL")
			print("|cffffff00".."Skada profile loaded".."|r")
		end
	--[[elseif msg == "kkthnx" or msg == "kkthnxui" then
		if K.CheckAddOnState("KkthnxUI") then
			K.LoadKkthnxUIProfile()
			StaticPopup_Show("CHANGES_RL")
			print("|cffffff00".."KkthnxUI profile loaded".."|r")
		end--]]
	elseif msg == "dbm" then
		if K.CheckAddOnState("DBM-Core") then
			K.LoadDBMProfile()
			StaticPopup_Show("CHANGES_RL")
			print("|cffffff00".."DBM profile loaded".."|r")
		end
	elseif msg == "bigwigs" then
		if K.CheckAddOnState("BigWigs") then
			K.LoadBigWigsProfile()
			StaticPopup_Show("CHANGES_RL")
			print("|cffffff00".."BigWigs profile loaded".."|r")
		end
	elseif msg == "pawn" then
		if K.CheckAddOnState("Pawn") then
			K.LoadPawnProfile()
			StaticPopup_Show("CHANGES_RL")
			print("|cffffff00".."Pawn profile loaded".."|r")
		end
	elseif msg == "msbt" then
		if K.CheckAddOnState("MikScrollingBattleText") then
			K.LoadMSBTProfile()
			StaticPopup_Show("CHANGES_RL")
			print("|cffffff00".."MikScrollingBattleText profile loaded".."|r")
		end
	elseif msg == "bugsack" then
		if K.CheckAddOnState("BugSack") then
			K.LoadBugSackProfile()
			StaticPopup_Show("CHANGES_RL")
			print("|cffffff00".."BugSack profile loaded".."|r")
		end
	elseif msg == "buggrabber" then
		if K.CheckAddOnState("!BugGrabber") then
			K.LoadBugGrabberProfile()
			StaticPopup_Show("CHANGES_RL")
			print("|cffffff00".."BugSack profile loaded".."|r")
		end
	elseif msg == "bt4" or msg == "bartender" then
		if K.CheckAddOnState("Bartender4") then
			K.LoadBartenderProfile()
			StaticPopup_Show("CHANGES_RL")
			print("|cffffff00".."Bartender4 profile loaded".."|r")
		end
	elseif msg == "all" or msg == "addons" then
		SetupAddons()
	else
		-- print("|cffffff00"..L_INFO_SETTINGS_DBM.."|r")
		-- print("|cffffff00"..L_INFO_SETTINGS_DXE.."|r")
		-- print("|cffffff00"..L_INFO_SETTINGS_MSBT.."|r")
		-- print("|cffffff00"..L_INFO_SETTINGS_SKADA.."|r")
		-- print("|cffffff00"..L_INFO_SETTINGS_ALL.."|r")

		K.Print("All AddOn profiles loaded.")
		--StaticPopup_Show("CHANGES_RL")
	end
end
_G.SLASH_SETTINGS1 = "/settings"