local _G = _G
local K, C, L = _G.unpack(_G.select(2, ...))

-- Lua API
local table_insert = table.insert
local getn = getn

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: ChatFrame1, QueueStatusFrame, L_UIDROPDOWNMENU_MAXLEVELS, UIDROPDOWNMENU_MAXLEVELS

local SkinDropDowns = _G.CreateFrame("Frame")
SkinDropDowns:RegisterEvent("ADDON_LOADED")
SkinDropDowns:SetScript("OnEvent", function(self, event, addon)
	if K.IsAddOnEnabled("Skinner") or K.IsAddOnEnabled("Aurora") then return end
	if addon == "KkthnxUI" then
		local Skins = {
			"QueueStatusFrame",
			"DropDownList1Backdrop",
			"DropDownList1MenuBackdrop",
			-- DropDownMenu library support
			"L_DropDownList1Backdrop",
			"L_DropDownList1MenuBackdrop"
		}

		QueueStatusFrame:StripTextures()

		for i = 1, getn(Skins) do
			_G[Skins[i]]:SetTemplate("Transparent", true)
		end

		--DropDownMenu
		_G.hooksecurefunc("UIDropDownMenu_CreateFrames", function(level, index)
			if not _G["DropDownList"..UIDROPDOWNMENU_MAXLEVELS.."Backdrop"].template then
				_G["DropDownList"..UIDROPDOWNMENU_MAXLEVELS.."Backdrop"]:SetTemplate("Transparent", true)
				_G["DropDownList"..UIDROPDOWNMENU_MAXLEVELS.."MenuBackdrop"]:SetTemplate("Transparent", true)
			end
		end)

		--LibUIDropDownMenu
		_G.hooksecurefunc("L_UIDropDownMenu_CreateFrames", function(level, index)
			if not _G["L_DropDownList"..L_UIDROPDOWNMENU_MAXLEVELS.."Backdrop"].template then
				_G["L_DropDownList"..L_UIDROPDOWNMENU_MAXLEVELS.."Backdrop"]:SetTemplate("Transparent", true)
				_G["L_DropDownList"..L_UIDROPDOWNMENU_MAXLEVELS.."MenuBackdrop"]:SetTemplate("Transparent", true)
			end
		end)

		-- Reskin menu
		local ChatMenus = {
			"ChatMenu",
			"EmoteMenu",
			"LanguageMenu",
			"VoiceMacroMenu"
		}

		for i = 1, getn(ChatMenus) do
			if _G[ChatMenus[i]] == _G["ChatMenu"] then
				_G[ChatMenus[i]]:HookScript("OnShow", function(self)
					self:SetTemplate("Transparent", true)
					self:ClearAllPoints()
					self:SetPoint("BOTTOMRIGHT", ChatFrame1, "BOTTOMRIGHT", 0, 30)
				end)
			else
				_G[ChatMenus[i]]:HookScript("OnShow", function(self)
					self:SetTemplate("Transparent", true)
				end)
			end
		end

		-- Reskin buttons
		local BlizzardButtons = {
				"RaidUtilityCloseButton",
				"RaidUtilityConvertButton",
				"RaidUtilityDisbandButton",
				"RaidUtilityMainAssistButton",
				"RaidUtilityMainTankButton",
				"RaidUtilityRaidControlButton",
				"RaidUtilityReadyCheckButton",
				"RaidUtilityRoleButton",
				"RaidUtilityShowButton",
		}

		if C["General"].RaidTools == true then
			table_insert(BlizzardButtons, "CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton")
		end

		for i = 1, getn(BlizzardButtons) do
			local buttons = _G[BlizzardButtons[i]]
			if buttons and not buttons.isSkinned then
				if buttons.isSkinned then return end
				buttons:SkinButton()
				buttons.isSkinned = true
			end
		end
	end
end)