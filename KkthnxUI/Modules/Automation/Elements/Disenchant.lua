local K, C = unpack(select(2, ...))

-- One-click Milling, Prospecting and Disenchanting(Molinari by p3lim)

local _G = _G
local string_format = _G.string.format
local string_match = _G.string.match

local GetContainerItemLink = _G.GetContainerItemLink
local GetItemCount = _G.GetItemCount
local GetItemInfo = _G.GetItemInfo
local GetItemInfoFromHyperlink = _G.GetItemInfoFromHyperlink
local GetMouseFocus = _G.GetMouseFocus
local GetSpellInfo = _G.GetSpellInfo
local InCombatLockdown = _G.InCombatLockdown
local IsAltKeyDown = _G.IsAltKeyDown
local IsSpellKnown = _G.IsSpellKnown
local LE_ITEM_CLASS_ARMOR = _G.LE_ITEM_CLASS_ARMOR
local LE_ITEM_CLASS_WEAPON = _G.LE_ITEM_CLASS_WEAPON

local button = CreateFrame("Button", "KKUI_OneClickMPD", UIParent, "SecureActionButtonTemplate, AutoCastShineTemplate")
button:SetScript("OnEvent", function(self, event, ...)
	if not C["Automation"].AutoDisenchant then
		return
	end

	self[event](self, ...)
end)

if not C["Automation"].AutoDisenchant then
	button:EnableMouse(false)
end

button:RegisterEvent("PLAYER_LOGIN")

function button:PLAYER_LOGIN()
	local milling, prospect, disenchanter, rogue

	if IsSpellKnown(51005) then
		milling = true
	end

	if IsSpellKnown(31252) then
		prospect = true
	end

	if IsSpellKnown(13262) then
		disenchanter = true
	end

	if IsSpellKnown(1804) then
		rogue = ITEM_MIN_SKILL:gsub("%%s", (K.Client == "ruRU" and "Взлом замков" or GetSpellInfo(1809))):gsub("%%d", "%(.*%)")
	end

	GameTooltip:HookScript("OnTooltipSetItem", function(self)
		local _, link = self:GetItem()
		if link and not InCombatLockdown() and IsAltKeyDown() and not (AuctionFrame and AuctionFrame:IsShown()) then
			local itemID = GetItemInfoFromHyperlink(link)
			if not itemID then
				return
			end
			local spell, r, g, b
			if milling and GetItemCount(itemID) >= 5 and C.MPDHerbs[itemID] then
				spell, r, g, b = GetSpellInfo(51005), 0.5, 1, 0.5
			elseif prospect and GetItemCount(itemID) >= 5 and C.MPDOres[itemID] then
				spell, r, g, b = GetSpellInfo(31252), 1, 0.33, 0.33
			elseif disenchanter then
				local _, _, itemRarity, _, _, _, _, _, _, _, _, class, subClass = GetItemInfo(link)
				if not (class == LE_ITEM_CLASS_WEAPON or class == LE_ITEM_CLASS_ARMOR or (class == 3 and subClass == 11)) or not (itemRarity and (itemRarity > 1 and (itemRarity < 5 or itemRarity == 6))) then
					return
				end
				spell, r, g, b = GetSpellInfo(13262), 0.5, 0.5, 1
			elseif rogue then
				for index = 1, self:NumLines() do
					if string_match(_G["GameTooltipTextLeft"..index]:GetText() or "", rogue) then
						spell, r, g, b = GetSpellInfo(1804), 0, 1, 1
					end
				end
			end

			local bag, slot = GetMouseFocus():GetParent(), GetMouseFocus()
			if spell and GetContainerItemLink(bag:GetID(), slot:GetID()) == link then
				button:SetAttribute("macrotext", string_format("/cast %s\n/use %s %s", spell, bag:GetID(), slot:GetID()))
				button:SetAllPoints(slot)
				button:Show()
				AutoCastShine_AutoCastStart(button, r, g, b)
			end
		end
	end)

	self:SetFrameStrata("TOOLTIP")
	self:SetAttribute("*type1", "macro")
	self:SetScript("OnLeave", self.MODIFIER_STATE_CHANGED)

	self:RegisterEvent("MODIFIER_STATE_CHANGED")
	self:Hide()

	for _, sparks in pairs(self.sparkles) do
		sparks:SetHeight(sparks:GetHeight() * 3)
		sparks:SetWidth(sparks:GetWidth() * 3)
	end
end

function button:MODIFIER_STATE_CHANGED(key)
	if not self:IsShown() and not key and key ~= "LALT" and key ~= "RALT" then
		return
	end

	if InCombatLockdown() then
		self:SetAlpha(0)
		self:RegisterEvent("PLAYER_REGEN_ENABLED")
	else
		self:ClearAllPoints()
		self:SetAlpha(1)
		self:Hide()
		AutoCastShine_AutoCastStop(self)
	end
end

function button:PLAYER_REGEN_ENABLED()
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:MODIFIER_STATE_CHANGED()
end