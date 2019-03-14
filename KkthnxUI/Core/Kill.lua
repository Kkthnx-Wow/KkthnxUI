local K, C = unpack(select(2, ...))

local _G = _G

local SetCVar = _G.SetCVar
local SetInsertItemsLeftToRight = _G.SetInsertItemsLeftToRight

local UnloadBlizzardFrames = CreateFrame("Frame")
UnloadBlizzardFrames:RegisterEvent("PLAYER_LOGIN")
UnloadBlizzardFrames:RegisterEvent("ADDON_LOADED")
UnloadBlizzardFrames:SetScript("OnEvent", function()
	if InCombatLockdown() then
		return
	end

	local UIHider = K.UIFrameHider

	if C["Raid"].Enable then
		-- Hide Default RaidFrame
		local function HideRaid()
			if InCombatLockdown() then
				return
			end

			K.HideObject(CompactRaidFrameManager)
			local compact_raid = CompactRaidFrameManager_GetSetting("IsShown")
			if compact_raid and compact_raid ~= "0" then
				CompactRaidFrameManager_SetSetting("IsShown", "0")
			end
		end

		CompactRaidFrameManager:HookScript("OnShow", HideRaid)

		if CompactRaidFrameManager_UpdateShown then
			hooksecurefunc("CompactRaidFrameManager_UpdateShown", HideRaid)
		end

		CompactRaidFrameContainer:UnregisterAllEvents()

		-- Hide Raid Interface Options.
		InterfaceOptionsFrameCategoriesButton10:SetHeight(0.00001)
		InterfaceOptionsFrameCategoriesButton10:SetAlpha(0)
	end

	if (C["Unitframe"].Enable) then
		K.KillMenuOption(true, "InterfaceOptionsCombatPanelTargetOfTarget")

		if (InterfaceOptionsUnitFramePanelPartyBackground) then
			InterfaceOptionsUnitFramePanelPartyBackground:Hide()
			InterfaceOptionsUnitFramePanelPartyBackground:SetAlpha(0)
		end

		if (PartyMemberBackground) then
			PartyMemberBackground:SetParent(UIHider)
			PartyMemberBackground:Hide()
			PartyMemberBackground:SetAlpha(0)
		end
	end

	if C["General"]["Scaling"].Value then
		Advanced_UseUIScale:Kill()
		Advanced_UIScaleSlider:Kill()
	end

	if (C["ActionBar"].Cooldowns) then
		SetCVar("countdownForCooldowns", 0)
		K.KillMenuOption(true, "InterfaceOptionsActionBarsPanelCountdownCooldowns")
	end

	if (C["ActionBar"].Enable) then
		InterfaceOptionsActionBarsPanelAlwaysShowActionBars:Kill()
		InterfaceOptionsActionBarsPanelBottomLeft:Kill()
		InterfaceOptionsActionBarsPanelBottomRight:Kill()
		InterfaceOptionsActionBarsPanelRight:Kill()
		InterfaceOptionsActionBarsPanelRightTwo:Kill()
	end

	if (C["Nameplates"].Enable) then
		SetCVar("ShowClassColorInNameplate", 1)
		K.KillMenuOption(true, "InterfaceOptionsNamesPanelUnitNameplatesMakeLarger")
		K.KillMenuOption(true, "InterfaceOptionsNamesPanelUnitNameplatesAggroFlash")
	end

	if (C["Minimap"].Enable) then
		K.KillMenuOption(true, "InterfaceOptionsDisplayPanelRotateMinimap")
	end

	if (C["Inventory"].Enable) then
		SetInsertItemsLeftToRight(C["Inventory"].ReverseLoot)
	end

	if not C["Party"].Enable and not C["Raid"].Enable then
		C["Raid"].RaidUtility = false
	end
end)