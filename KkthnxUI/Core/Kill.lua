local K, C = unpack(select(2, ...))

local _G = _G

local SetCVar = _G.SetCVar
local SetInsertItemsLeftToRight = _G.SetInsertItemsLeftToRight
local SetSortBagsRightToLeft = _G.SetSortBagsRightToLeft

local UnloadBlizzardFrames = CreateFrame("Frame")
UnloadBlizzardFrames:RegisterEvent("PLAYER_LOGIN")
UnloadBlizzardFrames:RegisterEvent("ADDON_LOADED")
UnloadBlizzardFrames:SetScript("OnEvent", function(_, event)
	if (event == "PLAYER_LOGIN") then
		local UIHider = K.UIFrameHider

		if (C["Raid"].Enable) then

			InterfaceOptionsFrameCategoriesButton10:SetHeight(0.00001)
			InterfaceOptionsFrameCategoriesButton10:SetAlpha(0)

			if CompactRaidFrameManager then
				CompactRaidFrameManager:SetParent(K.UIFrameHider)
			end

			if CompactUnitFrameProfiles then
				CompactUnitFrameProfiles:UnregisterAllEvents()
			end

			for i = 1, MAX_PARTY_MEMBERS do
				local PartyMember = _G["PartyMemberFrame" .. i]
				local Health = _G["PartyMemberFrame" .. i .. "HealthBar"]
				local Power = _G["PartyMemberFrame" .. i .. "ManaBar"]
				local Pet = _G["PartyMemberFrame" .. i .."PetFrame"]
				local PetHealth = _G["PartyMemberFrame" .. i .."PetFrame" .. "HealthBar"]

				PartyMember:UnregisterAllEvents()
				PartyMember:SetParent(UIHider)
				PartyMember:Hide()

				if Health then
					Health:UnregisterAllEvents()
				end

				if Power then
					Power:UnregisterAllEvents()
				end

				Pet:UnregisterAllEvents()
				Pet:SetParent(UIHider)
				PetHealth:UnregisterAllEvents()

				HidePartyFrame()
				ShowPartyFrame = K.Noop
				HidePartyFrame = K.Noop
			end
		end

		if (C["Unitframe"].Enable) then
			for i = 1, MAX_BOSS_FRAMES do
				local Boss = _G["Boss"..i.."TargetFrame"]
				local Health = _G["Boss"..i.."TargetFrame".."HealthBar"]
				local Power = _G["Boss"..i.."TargetFrame".."ManaBar"]

				Boss:UnregisterAllEvents()
				Boss.Show = K.Noop
				Boss:Hide()

				Health:UnregisterAllEvents()
				Power:UnregisterAllEvents()
			end

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

		if C["General"].AutoScale then
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
			InterfaceOptionsActionBarsPanelStackRightBars:Kill()
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
			SetSortBagsRightToLeft(true)
			SetInsertItemsLeftToRight(false)
		end

		if not C["Party"].Enable and not C["Raid"].Enable then
			C["Raid"].RaidUtility = false
		end
	end
end)