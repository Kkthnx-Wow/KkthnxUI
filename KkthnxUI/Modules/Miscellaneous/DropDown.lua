local K, C, L = unpack(select(2, ...))

-- Lua API
local _G = _G
local tinsert = table.insert

-- Wow API
local hooksecurefunc = hooksecurefunc
local UIDROPDOWNMENU_MAXLEVELS = UIDROPDOWNMENU_MAXLEVELS

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: ChatFrame1, getn -- No idea what this is. There is no info about it. Maybe we shouldn't cahe this.

local SkinDropDowns = CreateFrame("Frame")
SkinDropDowns:RegisterEvent("ADDON_LOADED")
SkinDropDowns:SetScript("OnEvent", function(self, event, addon)
	if K.CheckAddOn("Skinner") or K.CheckAddOn("Aurora") then return end

	if addon == "KkthnxUI" then

		local Skins = {
			-- DropDownMenu library support
			"Lib_DropDownList1MenuBackdrop",
			"Lib_DropDownList2MenuBackdrop",
			"Lib_DropDownList1Backdrop",
			"Lib_DropDownList2Backdrop"
		}

		for i = 1, getn(Skins) do
			_G[Skins[i]]:SetTemplate("Transparent")
		end

		-- Reskin Dropdown menu
		hooksecurefunc("UIDropDownMenu_InitializeHelper", function(frame)
			for i = 1, UIDROPDOWNMENU_MAXLEVELS do
				_G["DropDownList"..i.."Backdrop"]:SetTemplate("Transparent")
				_G["DropDownList"..i.."MenuBackdrop"]:SetTemplate("Transparent")
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
					self:SetTemplate("Transparent")
					self:ClearAllPoints()
					self:SetPoint("BOTTOMRIGHT", ChatFrame1, "BOTTOMRIGHT", 0, 30)
				end)
			else
				_G[ChatMenus[i]]:HookScript("OnShow", function(self)
					self:SetTemplate("Transparent")
				end)
			end
		end

		-- Reskin buttons
		local BlizzardButtons = {
				"RaidUtilityConvertButton",
				"RaidUtilityMainTankButton",
				"RaidUtilityMainAssistButton",
				"RaidUtilityRoleButton",
				"RaidUtilityReadyCheckButton",
				"RaidUtilityShowButton",
				"RaidUtilityCloseButton",
				"RaidUtilityDisbandButton",
				"RaidUtilityRaidControlButton",
		}

		if C.Blizzard.RaidTools == true then
			tinsert(BlizzardButtons, "CompactRaidFrameManagerDisplayFrameLeaderOptionsRaidWorldMarkerButton")
		end

		for i = 1, getn(BlizzardButtons) do
			local buttons = _G[BlizzardButtons[i]]
			if buttons then
				buttons:SkinButton()
			end
		end
	end

	if event == "ADDON_LOADED" then
		self:UnregisterEvent("ADDON_LOADED")
	end
end)