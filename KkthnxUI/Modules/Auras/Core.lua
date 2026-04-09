--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Core module for managing player buffs, debuffs, and weapon enchants.
-- - Design: Utilizes SecureAuraHeaderTemplate for secure aura handling in combat.
-- - Events: PLAYER_ENTERING_WORLD, WEAPON_ENCHANT_CHANGED, UNIT_AURA
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:NewModule("Auras")

-- PERF: Cache frequent APIs and globals to reduce table lookups in hot paths.
local _G = _G
local CreateFrame = _G.CreateFrame
local DebuffTypeColor = _G.DebuffTypeColor
local GameTooltip = _G.GameTooltip
local GetInventoryItemQuality = _G.GetInventoryItemQuality
local GetInventoryItemTexture = _G.GetInventoryItemTexture
local GetWeaponEnchantInfo = _G.GetWeaponEnchantInfo
local InCombatLockdown = _G.InCombatLockdown
local IsAltKeyDown = _G.IsAltKeyDown
local IsControlKeyDown = _G.IsControlKeyDown
local RegisterAttributeDriver = _G.RegisterAttributeDriver
local RegisterStateDriver = _G.RegisterStateDriver
local SecureHandlerSetFrameRef = _G.SecureHandlerSetFrameRef
local UIParent = _G.UIParent
local error = _G.error
local ipairs = _G.ipairs
local math_floor = _G.math.floor
local pcall = _G.pcall
local select = _G.select
local string_format = _G.string.format
local string_match = _G.string.match
local tonumber = _G.tonumber
local tostring = _G.tostring
local type = _G.type
local unpack = _G.unpack

local C_UnitAuras_GetAuraDataByIndex = _G.C_UnitAuras and _G.C_UnitAuras.GetAuraDataByIndex
local DAY, HOUR, MINUTE = 86400, 3600, 60

function Module:OnEnable()
	local loadAuraModules = {
		"HideBlizBuff",
		"BuildBuffFrame",
		"CreateTotems",
		-- "CreateReminder", -- Broken 12.0
	}

	-- PERF: Use ipairs for array iteration.
	for _, funcName in ipairs(loadAuraModules) do
		local func = self[funcName]
		if type(func) == "function" then
			local success, err = pcall(func, self)
			if not success then
				error("Error in function " .. funcName .. ": " .. tostring(err), 2)
			end
		end
	end
end

function Module:HideBlizBuff()
	if not C["Auras"].Enable and not C["Auras"].HideBlizBuff then
		return
	end

	K:RegisterEvent("PLAYER_ENTERING_WORLD", function(_, isLogin, isReload)
		if (isLogin or isReload) and not InCombatLockdown() then
			K.HideInterfaceOption(_G.BuffFrame)
			K.HideInterfaceOption(_G.DebuffFrame)
			BuffFrame.numHideableBuffs = 0 -- fix error when on editmode
		end
	end)
end

function Module:BuildBuffFrame()
	if not C["Auras"].Enable then
		return
	end

	-- REASON: Configure default aura layouts and positioning from settings.
	Module.settings = {
		Buffs = {
			offset = 12,
			size = C["Auras"].BuffSize,
			wrapAfter = C["Auras"].BuffsPerRow,
			maxWraps = 3,
			reverseGrow = C["Auras"].ReverseBuffs,
		},
		Debuffs = {
			offset = 12,
			size = C["Auras"].DebuffSize,
			wrapAfter = C["Auras"].DebuffsPerRow,
			maxWraps = 1,
			reverseGrow = C["Auras"].ReverseDebuffs,
		},
	}

	-- REASON: Initialize movers for custom positioning.
	Module.BuffFrame = Module:CreateAuraHeader("HELPFUL")
	Module.BuffFrame.mover = K.Mover(Module.BuffFrame, "Buffs", "BuffAnchor", { "TOPRIGHT", _G.Minimap, "TOPLEFT", -6, 0 })
	Module.BuffFrame:ClearAllPoints()
	Module.BuffFrame:SetPoint("TOPRIGHT", Module.BuffFrame.mover)

	Module.DebuffFrame = Module:CreateAuraHeader("HARMFUL")
	Module.DebuffFrame.mover = K.Mover(Module.DebuffFrame, "Debuffs", "DebuffAnchor", { "TOPRIGHT", Module.BuffFrame.mover, "BOTTOMRIGHT", 0, -12 })
	Module.DebuffFrame:ClearAllPoints()
	Module.DebuffFrame:SetPoint("TOPRIGHT", Module.DebuffFrame.mover)
end

function Module:FormatAuraTime(s)
	if s >= DAY then
		return string_format("%d" .. K.MyClassColor .. "d", s / DAY), s % DAY
	elseif s >= 2 * HOUR then
		return string_format("%d" .. K.MyClassColor .. "h", s / HOUR), s % HOUR
	elseif s >= 10 * MINUTE then
		return string_format("%d" .. K.MyClassColor .. "m", s / MINUTE), s % MINUTE
	elseif s >= MINUTE then
		local m = math_floor(s / MINUTE)
		local sec = math_floor(s - m * MINUTE)
		return string_format("%d:%02d", m, sec), s - math_floor(s)
	elseif s > 10 then
		return string_format("%d" .. K.MyClassColor .. "s", s), s - math_floor(s)
	elseif s > 5 then
		return string_format("|cffffff00%.1f|r", s), s - (math_floor(s * 10) / 10)
	else
		return string_format("|cffff0000%.1f|r", s), s - (math_floor(s * 10) / 10)
	end
end

function Module:UpdateTimer(elapsed)
	local onTooltip = GameTooltip:IsOwned(self)

	if not (self.timeLeft or self.expiration or onTooltip) then
		self:SetScript("OnUpdate", nil)
		return
	end

	-- PERF: Throttle updates to reduce CPU churn in large aura sets.
	self._throttle = (self._throttle or 0) + elapsed
	if self._throttle < 0.1 then
		return
	end
	elapsed = self._throttle
	self._throttle = 0

	if self.timeLeft then
		self.timeLeft = self.timeLeft - elapsed
	end

	if self.nextUpdate > 0 then
		self.nextUpdate = self.nextUpdate - elapsed
		return
	end

	if self.expiration then
		self.timeLeft = self.expiration / 1e3 - (GetTime() - self.oldTime)
	end

	if self.timeLeft and self.timeLeft >= 0 then
		local timer, nextUpdate = Module:FormatAuraTime(self.timeLeft)
		self.nextUpdate = nextUpdate
		self.timer:SetText(timer)
	end

	if onTooltip then
		Module:Button_SetTooltip(self)
	end
end

-- PERF: Centralized timer activation for aura buttons.
function Module:StartAuraTimer(button, timeLeft)
	button.nextUpdate = -1
	button.timeLeft = timeLeft
	button:SetScript("OnUpdate", Module.UpdateTimer)
	Module.UpdateTimer(button, 0)
end

function Module:GetSpellStat(arg16, arg17, arg18)
	return (arg16 > 0 and L["Versa"]) or (arg17 > 0 and L["Mastery"]) or (arg18 > 0 and L["Haste"]) or L["Crit"]
end

function Module:UpdateAuras(button, index)
	local unit, filter = button.header:GetAttribute("unit"), button.filter
	local auraData = C_UnitAuras_GetAuraDataByIndex(unit, index, filter)
	if not auraData then
		return
	end

	if auraData.duration > 0 and auraData.expirationTime then
		Module:StartAuraTimer(button, auraData.expirationTime - _G.GetTime())
	else
		button.timeLeft = nil
		button.timer:SetText("")
		button:SetScript("OnUpdate", nil)
	end

	local count = auraData.applications
	if count and count > 1 then
		button.count:SetText(count)
	else
		button.count:SetText("")
	end

	if filter == "HARMFUL" then
		local color = DebuffTypeColor[auraData.dispelName or "none"]
		button.KKUI_Border:SetVertexColor(color.r, color.g, color.b)
	else
		K.SetBorderColor(button.KKUI_Border)
	end

	-- Show spell stat for 'Soleahs Secret Technique'
	if auraData.spellId == 368512 then
		button.count:SetText(Module:GetSpellStat(unpack(auraData.points)))
	end

	button.spellID = auraData.spellId
	button.icon:SetTexture(auraData.icon)
	button.expiration = nil
end

function Module:UpdateTempEnchant(button, index)
	local expirationTime = select(button.enchantOffset, GetWeaponEnchantInfo())
	if expirationTime then
		local quality = GetInventoryItemQuality("player", index)
		local color = K.QualityColors[quality or 1]
		button.KKUI_Border:SetVertexColor(color.r, color.g, color.b)
		button.icon:SetTexture(GetInventoryItemTexture("player", index))

		button.expiration = expirationTime
		button.oldTime = _G.GetTime()
		Module:StartAuraTimer(button, expirationTime / 1e3) -- expirationTime is in seconds here?
	else
		button.expiration = nil
		button.timeLeft = nil
		button.timer:SetText("")
		-- REASON: Ensure OnUpdate script is removed when no enchantment to save resources.
		button:SetScript("OnUpdate", nil)
	end
end

function Module:OnAttributeChanged(attribute, value)
	if attribute == "index" then
		Module:UpdateAuras(self, value)
	elseif attribute == "target-slot" then
		Module:UpdateTempEnchant(self, value)
	end
end

function Module:UpdateHeader(header)
	local cfg = Module.settings.Debuffs
	if header.filter == "HELPFUL" then
		cfg = Module.settings.Buffs
		header:SetAttribute("consolidateTo", 0)
		header:SetAttribute("weaponTemplate", string_format("KKUI_AuraTemplate%d", cfg.size))
	end

	local margin = 6

	header:SetAttribute("separateOwn", 1)
	header:SetAttribute("sortMethod", "INDEX")
	header:SetAttribute("sortDirection", "+")
	header:SetAttribute("wrapAfter", cfg.wrapAfter)
	header:SetAttribute("maxWraps", cfg.maxWraps)
	header:SetAttribute("point", cfg.reverseGrow and "TOPLEFT" or "TOPRIGHT")
	header:SetAttribute("minWidth", (cfg.size + margin) * cfg.wrapAfter)
	header:SetAttribute("minHeight", (cfg.size + cfg.offset) * cfg.maxWraps)
	header:SetAttribute("xOffset", (cfg.reverseGrow and 1 or -1) * (cfg.size + margin))
	header:SetAttribute("yOffset", 0)
	header:SetAttribute("wrapXOffset", 0)
	header:SetAttribute("wrapYOffset", -(cfg.size + cfg.offset))
	header:SetAttribute("template", string_format("KKUI_AuraTemplate%d", cfg.size))

	local fontSize = math_floor(cfg.size / 30 * 12 + 0.5)
	local index = 1
	local child = select(index, header:GetChildren())
	while child do
		if (math_floor(child:GetWidth() * 100 + 0.5) / 100) ~= cfg.size then
			child:SetSize(cfg.size, cfg.size)
		end

		child.count:SetFontObject(K.UIFontOutline)
		local countFont, _, countFlags = child.count:GetFont()
		child.count:SetFont(countFont, fontSize, countFlags)

		child.timer:SetFontObject(K.UIFontOutline)
		local timerFont, _, timerFlags = child.timer:GetFont()
		child.timer:SetFont(timerFont, fontSize, timerFlags)

		-- WARNING: Blizzard bug fix: icons aren't being hidden when reducing the maximum number of buttons.
		if index > (cfg.maxWraps * cfg.wrapAfter) and child:IsShown() then
			child:Hide()
		end

		index = index + 1
		child = select(index, header:GetChildren())
	end
end

function Module:CreateAuraHeader(filter)
	local name = "KKUI_PlayerDebuffs"
	if filter == "HELPFUL" then
		name = "KKUI_PlayerBuffs"
	end

	local header = CreateFrame("Frame", name, UIParent, "SecureAuraHeaderTemplate")
	header:SetClampedToScreen(true)
	header:UnregisterEvent("UNIT_AURA") -- we only need to watch player and vehicle
	header:RegisterUnitEvent("UNIT_AURA", "player", "vehicle")
	header:SetAttribute("unit", "player")
	header:SetAttribute("filter", filter)
	header.filter = filter
	RegisterAttributeDriver(header, "unit", "[vehicleui] vehicle; player")

	header.visibility = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
	header.visibility:RegisterEvent("WEAPON_ENCHANT_CHANGED")
	SecureHandlerSetFrameRef(header.visibility, "AuraHeader", header)
	RegisterStateDriver(header.visibility, "customVisibility", "[petbattle] 0;1")
	header.visibility:SetAttribute(
		"_onstate-customVisibility",
		[[
        local header = self:GetFrameRef("AuraHeader")
        local hide, shown = newstate == 0, header:IsShown()
        if hide and shown then header:Hide() elseif not hide and not shown then header:Show() end
    ]]
	)

	if filter == "HELPFUL" then
		header:SetAttribute("consolidateDuration", -1)
		header:SetAttribute("includeWeapons", 1)
	end

	Module:UpdateHeader(header)
	header:Show()

	return header
end

function Module:RemoveSpellFromIgnoreList()
	if IsAltKeyDown() and IsControlKeyDown() and self.spellID and K.GetCharVars().AuraWatchList.IgnoreSpells[self.spellID] then
		K.GetCharVars().AuraWatchList.IgnoreSpells[self.spellID] = nil
		K.Print(string_format(L["RemoveFromIgnoreList"], "", self.spellID))
	end
end

function Module:Button_SetTooltip(button)
	if button:GetAttribute("index") then
		GameTooltip:SetUnitAura(button.header:GetAttribute("unit"), button:GetID(), button.filter)
	elseif button:GetAttribute("target-slot") then
		GameTooltip:SetInventoryItem("player", button:GetID())
	end
end

function Module:Button_OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", -5, -5)
	self.nextUpdate = -1
	self:SetScript("OnUpdate", Module.UpdateTimer)
end

local indexToOffset = { 2, 6, 10 }
function Module:CreateAuraIcon(button)
	button.header = button:GetParent()
	button.filter = button.header.filter
	button.name = button:GetName()
	local enchantIndex = tonumber(string_match(button.name, "TempEnchant(%d)$"))
	button.enchantOffset = indexToOffset[enchantIndex]

	local cfg = Module.settings.Debuffs
	if button.filter == "HELPFUL" then
		cfg = Module.settings.Buffs
	end
	local fontSize = math_floor(cfg.size / 30 * 12 + 0.5)

	button.icon = button:CreateTexture(nil, "BORDER")
	button.icon:SetAllPoints()
	button.icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

	button.count = button:CreateFontString(nil, "OVERLAY")
	button.count:SetPoint("TOPRIGHT", -1, -3)
	button.count:SetFontObject(K.UIFontOutline)
	button.count:SetFont(select(1, button.count:GetFont()), fontSize, select(3, button.count:GetFont()))

	button.timer = button:CreateFontString(nil, "OVERLAY")
	button.timer:SetPoint("TOP", button, "BOTTOM", 1, 5)
	button.timer:SetFontObject(K.UIFontOutline)
	button.timer:SetFont(select(1, button.timer:GetFont()), fontSize, select(3, button.timer:GetFont()))

	button:StyleButton()
	button:CreateBorder()

	-- button:RegisterForClicks("RightButtonUp", "RightButtonDown")
	button:SetScript("OnAttributeChanged", Module.OnAttributeChanged)
	button:HookScript("OnMouseDown", Module.RemoveSpellFromIgnoreList)
	button:SetScript("OnEnter", Module.Button_OnEnter)
	button:SetScript("OnLeave", K.HideTooltip)
end
