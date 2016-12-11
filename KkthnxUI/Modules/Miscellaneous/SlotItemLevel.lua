local K, C, L = unpack(select(2, ...))
if C.Misc.ItemLevel ~= true then return end

-- ILevel by (Sanex (Arathor EU))

-- WoW Lua
local _G = _G
local select = select
local strmatch = string.match
local strsplit = string.split
local tonumber = tonumber
local tostring = tostring
local twipe = table.wipe
local type = type

-- Wow API
local GetInventoryItemLink = GetInventoryItemLink
local GetItemGem = GetItemGem
local GetItemInfo = GetItemInfo
local hooksecurefunc = hooksecurefunc
local upgradeTypeID = upgradeTypeID

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: CharacterBackSlot, CharacterChestSlot, CharacterWristSlot, CharacterLegsSlot
-- GLOBALS: CharacterFeetSlot, CharacterFinger0Slot, CharacterFinger1Slot, CharacterTrinket0Slot
-- GLOBALS: CharacterHeadSlot, CharacterNeckSlot, CharacterShoulderSlot, CharacterWaistSlot
-- GLOBALS: CharacterTrinket1Slot, CharacterSecondaryHandSlot, PaperDollFrame, ChatFrame1
-- GLOBALS: iLevelSetting, UIParent, SLASH_ILEVEL1, CharacterMainHandSlot, CharacterHandsSlot

local xo, yo = 8, 4 -- X-offset, Y-offset
local equiped = {} -- Table to store equiped items
local setting -- Setting on how much we show
local socketsTable = {
	-- WoD Sockets
	[523] = true, -- Dungeon
	[563] = true, -- Normal Raid
	[564] = true, -- Heroic Raid
	[565] = true, -- Mythic Raid

	-- Prismatic Sockets in 7.0, how many are there?
	[1808] = true, -- From Heroic Dungeons and T19 Normal Raids
	[3386] = true, -- From Vendor
	[3458] = true, -- Legendary item with socket?
}

local f = CreateFrame("Frame", nil, PaperDollFrame) -- ILevel number frame
f:RegisterEvent("PLAYER_LOGIN")

-- Tooltip and scanning by Phanx @ http://www.wowinterface.com/forums/showthread.php?p=271406
local S_ITEM_LEVEL = "^" .. gsub(ITEM_LEVEL, "%%d", "(%%d+)")
local S_UPGRADE_LEVEL = "^" .. gsub(ITEM_UPGRADE_TOOLTIP_FORMAT, "%%d", "(%%d+)")
local S_HEIRLOOM_LEVEL = "^" .. gsub(HEIRLOOM_UPGRADE_TOOLTIP_FORMAT, "%%d", "(%%d+)")

local scantip = CreateFrame("GameTooltip", "iLvlScanningTooltip", nil, "GameTooltipTemplate")
scantip:SetOwner(UIParent, "ANCHOR_NONE")

local function _getRealItemLevel(slotId)
	local realItemLevel, currentUpgradeLevel, maxUpgradeLevel
	local hasItem = scantip:SetInventoryItem("player", slotId)
	if not hasItem then return nil end -- With this we don't get ilvl for offhand if we equip 2h weapon

	for i = 2, scantip:NumLines() do -- Line 1 is always the name so you can skip it.
		local text = _G["iLvlScanningTooltipTextLeft"..i]:GetText()
		if text and text ~= "" then
			realItemLevel = realItemLevel or strmatch(text, S_ITEM_LEVEL)
			if not (currentUpgradeLevel or maxUpgradeLevel) then
				currentUpgradeLevel, maxUpgradeLevel = strmatch(text, S_UPGRADE_LEVEL)
				if not (currentUpgradeLevel or maxUpgradeLevel) then
					currentUpgradeLevel, maxUpgradeLevel = strmatch(text, S_HEIRLOOM_LEVEL)
				end
			end

			if realItemLevel and currentUpgradeLevel and maxUpgradeLevel then
				return realItemLevel, tonumber(currentUpgradeLevel), tonumber(maxUpgradeLevel)
			end
		end
	end

	return realItemLevel
end

local function _updateItems()
	for i = 1, 17 do -- Only check changed items or items without ilvl text, skip the shirt (4)
		local itemLink = GetInventoryItemLink("player", i)
		if i ~= 4 and (equiped[i] ~= itemLink or f[i]:GetText() == nil) then
			equiped[i] = itemLink
			local realItemLevel, currentUpgradeLevel, maxUpgradeLevel = _getRealItemLevel(i)
			local upgradeString, enchantString, gemString = "", "", ""
			local _, enchantID, gem1, gem2, gem3, gem4, numBonuses, affixes

			if setting >= 1 then
				if currentUpgradeLevel and maxUpgradeLevel and currentUpgradeLevel < maxUpgradeLevel then
					upgradeString = "|TInterface\\PetBattles\\BattleBar-AbilityBadge-Strong:0:0:0:0:32:32:2:30:2:30|t"
				end

				if setting == 2 then
					if itemLink then
						_, _, enchantID, _, _, _, _, _, _, _, _, upgradeTypeID, _, numBonuses, affixes = strsplit(":", itemLink, 15)
					end
					enchantID = tonumber(enchantID); numBonuses = tonumber(numBonuses); upgradeTypeID = tonumber(upgradeTypeID); realItemLevel = realItemLevel or ""

					if i == 2 or i == 3 or i == 11 or i == 12 or i == 15 then
						-- Neck, Shoulders, Finger0, Finger1, Chest
						if enchantID and enchantID > 0 then
							enchantString = "|T136244:0:0:0:0:32:32:2:30:2:30|t"
						elseif itemLink then
							enchantString = "|T136244:0:0:0:0:32:32:2:30:2:30:221:0:0|t"
						end
					end
					if i == 16 and upgradeTypeID == 256 then -- Main Hand, Artifact Weapon
						for b = 1, 3 do
							local _, gemLink = GetItemGem(itemLink, b)
							if gemLink and gemLink ~= "" then
								local _, _, _, _, _, _, _, _, _, t = GetItemInfo(gemLink)
								if t and t > 0 then
									gemString = gemString.."|T"..t..":0:0:0:0:32:32:2:30:2:30|t"
								end
							else
								gemString = gemString.."|TInterface\\ItemSocketingFrame\\UI-EmptySocket-Red:0:0:0:0:32:32:2:30:2:30|t"
							end
						end
					elseif numBonuses and numBonuses > 0 then
						for b = 1, numBonuses do
							local bonusID = select(b, strsplit(":", affixes))
							if socketsTable[tonumber(bonusID)] then
								local _, gemLink = GetItemGem(itemLink, 1)
								if gemLink and gemLink ~= "" then
									local _, _, _, _, _, _, _, _, _, t = GetItemInfo(gemLink)
									if t and t > 0 then
										gemString = gemString.."|T"..t..":0:0:0:0:32:32:2:30:2:30|t"
									end
								else
									gemString = gemString.."|TInterface\\ItemSocketingFrame\\UI-EmptySocket-Red:0:0:0:0:32:32:2:30:2:30|t"
								end
							end
						end
					end
				end
			end

			realItemLevel = realItemLevel or ""

			if setting == 2 then
				if i <= 5 or i == 15 or i == 9 then -- Left side
					f[i]:SetFormattedText("%s%s%s%s", realItemLevel, enchantString, gemString, upgradeString)
				elseif i == 16 then -- MainHand
					if gemString ~= "" then
						f[i]:SetFormattedText("%s%s\n%s", upgradeString, realItemLevel, gemString)
						f[i]:SetWidth(CharacterMainHandSlot:GetWidth() + 2) -- Fix for 3 gems in weapon
					else
						f[i]:SetFormattedText("%s%s", upgradeString, realItemLevel)
						f[i]:SetWidth(CharacterMainHandSlot:GetWidth())
					end
				elseif i == 17 then -- OffHand
					if gemString ~= "" then
						f[i]:SetFormattedText("%s%s\n%s", realItemLevel, upgradeString, gemString)
					else
						f[i]:SetFormattedText("%s%s", realItemLevel, upgradeString)
					end
				else -- Right side
					f[i]:SetFormattedText("%s%s%s%s", upgradeString, gemString, enchantString, realItemLevel)
				end
			elseif setting == 1 then
				if i <= 5 or i == 15 or i == 9 or i == 17 then -- Left side
					f[i]:SetText(realItemLevel..upgradeString)
				else
					f[i]:SetText(upgradeString..realItemLevel)
				end
			else
				f[i]:SetText(realItemLevel)
			end
		end
	end
end

local function _createStrings()
	local function _stringFactory(parent, myPoint, parentPoint, x, y)
		local s = f:CreateFontString(nil, "OVERLAY", "GameFontNormalOutline")
		s:SetPoint(myPoint, parent, parentPoint, x or 0, y or 0)
		s:SetShadowOffset(0, 0)

		return s
	end

	f:SetFrameLevel(CharacterHeadSlot:GetFrameLevel())

	f[1] = _stringFactory(CharacterHeadSlot, "LEFT", "RIGHT", xo)
	f[10] = _stringFactory(CharacterHandsSlot, "RIGHT", "LEFT", -xo)
	f[11] = _stringFactory(CharacterFinger0Slot, "RIGHT", "LEFT", -xo)
	f[12] = _stringFactory(CharacterFinger1Slot, "RIGHT", "LEFT", -xo)
	f[13] = _stringFactory(CharacterTrinket0Slot, "RIGHT", "LEFT", -xo)
	f[14] = _stringFactory(CharacterTrinket1Slot, "RIGHT", "LEFT", -xo)
	f[15] = _stringFactory(CharacterBackSlot, "LEFT", "RIGHT", xo)
	f[16] = _stringFactory(CharacterMainHandSlot, "BOTTOM", "TOP", 2, yo)
	f[17] = _stringFactory(CharacterSecondaryHandSlot, "BOTTOM", "TOP", 2, yo)
	f[2] = _stringFactory(CharacterNeckSlot, "LEFT", "RIGHT", xo)
	f[3] = _stringFactory(CharacterShoulderSlot, "LEFT", "RIGHT", xo)
	f[5] = _stringFactory(CharacterChestSlot, "LEFT", "RIGHT", xo)
	f[6] = _stringFactory(CharacterWaistSlot, "RIGHT", "LEFT", -xo)
	f[7] = _stringFactory(CharacterLegsSlot, "RIGHT", "LEFT", -xo)
	f[8] = _stringFactory(CharacterFeetSlot, "RIGHT", "LEFT", -xo)
	f[9] = _stringFactory(CharacterWristSlot, "LEFT", "RIGHT", xo)

	f:Hide()
end

local function OnEvent(self, event, ...) -- Event handler
	if event == "PLAYER_LOGIN" then
		self:UnregisterEvent(event)

		if type(iLevelSetting) ~= "numeric" then
			iLevelSetting = 2
		end
		setting = iLevelSetting

		_createStrings()

		PaperDollFrame:HookScript("OnShow", function(self)
			f:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
			f:RegisterEvent("ITEM_UPGRADE_MASTER_UPDATE")
			f:RegisterEvent("ARTIFACT_UPDATE")
			f:RegisterEvent("SOCKET_INFO_UPDATE")
			f:RegisterEvent("COMBAT_RATING_UPDATE")
			_updateItems()
			f:Show()
		end)

		PaperDollFrame:HookScript("OnHide", function(self)
			f:UnregisterEvent("PLAYER_EQUIPMENT_CHANGED")
			f:UnregisterEvent("ITEM_UPGRADE_MASTER_UPDATE")
			f:UnregisterEvent("ARTIFACT_UPDATE")
			f:UnregisterEvent("SOCKET_INFO_UPDATE")
			f:UnregisterEvent("COMBAT_RATING_UPDATE")
			f:Hide()
		end)
	elseif event == "PLAYER_EQUIPMENT_CHANGED" or event == "ITEM_UPGRADE_MASTER_UPDATE"
	or event == "ARTIFACT_UPDATE" or event == "SOCKET_INFO_UPDATE" or event == "COMBAT_RATING_UPDATE" then
		if (...) == 16 then
			equiped[16] = nil
			equiped[17] = nil
		end
		_updateItems()
	end
end
f:SetScript("OnEvent", OnEvent)

SLASH_ILEVEL1 = "/ilevel"
SlashCmdList.ILEVEL = function(...)
	if (...) == "0" then
		setting = 0
		iLevelSetting = 0
		twipe(equiped)
		_updateItems()
	elseif (...) == "1" then
		setting = 1
		iLevelSetting = 1
		twipe(equiped)
		_updateItems()
	elseif (...) == "2" then
		setting = 2
		iLevelSetting = 2
		twipe(equiped)
		_updateItems()
	end
	ChatFrame1:AddMessage("|cff3c9bed"..K.UIName..":|r /ilevel ( 0 | 1 | 2 )\n 0 - Only show item levels.\n 1 - Show item levels and upgrades.\n 2 - Show item levels, upgrades and enchants and gems.")
	ChatFrame1:AddMessage("|cff3c9bed"..K.UIName..":|r Current setting is " .. tostring(setting))
end