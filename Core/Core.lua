--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Core/Core.lua
	Purpose:
		The Core module. Owns first login setup: applies the UI scale, refreshes
		pixel math on resolution changes, prints the welcome line, and registers
		the /kk slash command that opens the config GUI.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

local Module = K:NewModule("Core")

function Module:OnEnable()
	-- Prefer key down response for action buttons.
	if not InCombatLockdown() then
		SetCVar("ActionButtonUseKeyDown", 1)
	end

	K:SetupUIScale()
	K.RefreshBorderColors()

	-- Recompute pixel math when the screen scale or resolution changes.
	self:RegisterEvent("UI_SCALE_CHANGED", function()
		K.ScreenWidth, K.ScreenHeight = GetPhysicalScreenSize()
		K:SetupUIScale()
	end)
	self:RegisterEvent("DISPLAY_SIZE_CHANGED", function()
		K.ScreenWidth, K.ScreenHeight = GetPhysicalScreenSize()
		K:SetupUIScale()
	end)

	if C.General.WelcomeMessage then
		K.Print(L["Version %s (build %s) loaded. Type %s for options."], K.Version, K.Build, "|cff5C8BCF/kk|r")
	end
end

-- ---------------------------------------------------------------------------
-- Slash commands
-- ---------------------------------------------------------------------------

SLASH_KKTHNXUI1 = "/kk"
SLASH_KKTHNXUI2 = "/kkthnxui"
SlashCmdList.KKTHNXUI = function(msg)
	msg = (msg or ""):lower():gsub("%s+", "")

	if msg == "reset" then
		K:ResetProfile()
		return
	elseif msg == "rl" or msg == "reload" then
		ReloadUI()
		return
	elseif msg == "move" or msg == "unlock" then
		K.ToggleMovers()
		return
	elseif msg == "resetpos" then
		K.ResetMovers()
		return
	elseif msg == "install" then
		if K.OpenInstaller then
			K.OpenInstaller()
		end
		return
	elseif msg == "chat" then
		if K.InstallChat then
			K.InstallChat()
		end
		return
	elseif msg == "buttons" then
		if K.ToggleButtonPreview then
			K.ToggleButtonPreview()
		end
		return
	elseif msg == "test" then
		local uf = K:GetModule("UnitFrames", true)
		if uf and uf.ToggleTest then
			uf:ToggleTest()
		end
		return
	elseif msg == "auras" then
		local auras = K:GetModule("Auras", true)
		if auras and auras.ToggleTest then
			auras:ToggleTest()
		end
		return
	end

	if K.ToggleConfigGUI then
		K.ToggleConfigGUI()
	else
		K.Print(L["Config GUI is not available yet."])
	end
end
