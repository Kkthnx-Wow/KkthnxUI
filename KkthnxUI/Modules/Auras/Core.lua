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
local GetTime = _G.GetTime
local GetWeaponEnchantInfo = _G.GetWeaponEnchantInfo
local InCombatLockdown = _G.InCombatLockdown
local RegisterAttributeDriver = _G.RegisterAttributeDriver
local RegisterStateDriver = _G.RegisterStateDriver
local SecureHandlerSetFrameRef = _G.SecureHandlerSetFrameRef
local UIParent = _G.UIParent
local error = _G.error
local ipairs = _G.ipairs
local math_floor = _G.math.floor
local pcall = _G.pcall
local rawget = _G.rawget
local select = _G.select
local string_format = _G.string.format
local string_match = _G.string.match
local tonumber = _G.tonumber
local tostring = _G.tostring
local type = _G.type
local unpack = _G.unpack

local C_UnitAuras_GetAuraDataByIndex = _G.C_UnitAuras and _G.C_UnitAuras.GetAuraDataByIndex
local C_UnitAuras_GetAuraApplicationDisplayCount = _G.C_UnitAuras and _G.C_UnitAuras.GetAuraApplicationDisplayCount
local C_UnitAuras_GetAuraDispelTypeColor = _G.C_UnitAuras and _G.C_UnitAuras.GetAuraDispelTypeColor
local C_UnitAuras_GetAuraDuration = _G.C_UnitAuras and _G.C_UnitAuras.GetAuraDuration
local DAY, HOUR, MINUTE = 86400, 3600, 60
local MIN_SPELL_COUNT, MAX_SPELL_COUNT = 2, 999

local IsSecret = K.IsSecret

-- MIDNIGHT (12.0): dispel curve lives in K.GetDispelColorCurve (shared with oUF aura hooks).
local function GetDispelColorCurve()
	return K.GetDispelColorCurve(K.oUF)
end

function Module:OnEnable()
	Module:InitAuras()
end

function Module:InitAuras()
	if Module.aurasInitialized then
		return
	end

	local loadAuraModules = {
		"HideBlizBuff",
		"BuildBuffFrame",
		"CreateTotems",
		"CreateReminder",
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

	Module.aurasInitialized = true
end

function Module:SetAurasEnabled(enabled)
	if enabled then
		if not Module.aurasInitialized then
			Module:InitAuras()
		else
			Module:BuildBuffFrame()
			if Module.UpdateAuraLayout then
				Module:UpdateAuraLayout()
			end
		end
	elseif Module.BuffFrame then
		Module.BuffFrame:Hide()
	end
	if not enabled and Module.DebuffFrame then
		Module.DebuffFrame:Hide()
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

	if Module.BuffFrame then
		Module.BuffFrame:Show()
		if Module.DebuffFrame then
			Module.DebuffFrame:Show()
		end
		if Module.UpdateAuraLayout then
			Module:UpdateAuraLayout()
		end
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

-- PERF: FormatAuraTime runs per visible aura on every timer tick. The class color
-- is constant for the session, so build the d/h/m/s format strings once (lazily,
-- because K.MyClassColor isn't populated yet at file-load time) instead of
-- re-concatenating them on each call.
local AURA_DAY_FMT, AURA_HOUR_FMT, AURA_MINUTE_FMT, AURA_SECOND_FMT
local function EnsureAuraTimeFormats()
	if AURA_DAY_FMT then
		return
	end

	local color = K.MyClassColor or ""
	AURA_DAY_FMT = "%d" .. color .. "d"
	AURA_HOUR_FMT = "%d" .. color .. "h"
	AURA_MINUTE_FMT = "%d" .. color .. "m"
	AURA_SECOND_FMT = "%d" .. color .. "s"
end

function Module:FormatAuraTime(s)
	EnsureAuraTimeFormats()

	if s >= DAY then
		return string_format(AURA_DAY_FMT, s / DAY), s % DAY
	elseif s >= 2 * HOUR then
		return string_format(AURA_HOUR_FMT, s / HOUR), s % HOUR
	elseif s >= 10 * MINUTE then
		return string_format(AURA_MINUTE_FMT, s / MINUTE), s % MINUTE
	elseif s >= MINUTE then
		local m = math_floor(s / MINUTE)
		local sec = math_floor(s - m * MINUTE)
		return string_format("%d:%02d", m, sec), s - math_floor(s)
	elseif s > 10 then
		return string_format(AURA_SECOND_FMT, s), s - math_floor(s)
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

local function GetNativeAuraDuration(unit, auraInstanceID)
	if not (C_UnitAuras_GetAuraDuration and unit and auraInstanceID) then
		return nil
	end

	-- MIDNIGHT (12.0): use Blizzard's DurationObject for aura cooldowns so
	-- restricted timing data is rendered by the engine instead of Lua.
	local ok, auraDuration = pcall(C_UnitAuras_GetAuraDuration, unit, auraInstanceID)
	if ok then
		return auraDuration
	end
end

local function StyleNativeCooldownText(button)
	local cooldown = button.Cooldown
	if not (cooldown and button.timer) then
		return
	end

	local fontSize = select(2, button.timer:GetFont()) or 12
	-- Personal buffs/debuffs: timer sits under the icon (same as button.timer).
	K.StyleAuraCooldownCountdown(cooldown, fontSize, button, "TOP", 1, 5, "BOTTOM")
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

	local duration = auraData.duration
	local expirationTime = auraData.expirationTime
	local auraInstanceID = auraData.auraInstanceID
	local auraDuration = GetNativeAuraDuration(unit, auraInstanceID)

	if auraDuration and button.Cooldown then
		K.ArmAuraCooldown(button.Cooldown, auraDuration)
		button.Cooldown:SetHideCountdownNumbers(false)
		StyleNativeCooldownText(button)
		button.timeLeft = nil
		button.timer:SetText("")
		button.timer:Hide()
		button:SetScript("OnUpdate", nil)
	elseif not IsSecret(duration) and not IsSecret(expirationTime) and duration and expirationTime and duration > 0 then
		if button.Cooldown then
			button.Cooldown:Clear()
			button.Cooldown:SetHideCountdownNumbers(true)
		end
		button.timer:Show()
		Module:StartAuraTimer(button, expirationTime - GetTime())
	else
		if button.Cooldown then
			button.Cooldown:Clear()
			button.Cooldown:SetHideCountdownNumbers(true)
		end
		button.timeLeft = nil
		button.timer:SetText("")
		button.timer:Hide()
		button:SetScript("OnUpdate", nil)
	end

	local count = auraData.applications
	if IsSecret(count) and C_UnitAuras_GetAuraApplicationDisplayCount and auraInstanceID then
		button.count:SetText(C_UnitAuras_GetAuraApplicationDisplayCount(unit, auraInstanceID, MIN_SPELL_COUNT, MAX_SPELL_COUNT))
	elseif not IsSecret(count) and count and count > 1 then
		button.count:SetText(count)
	else
		button.count:SetText("")
	end

	if filter == "HARMFUL" then
		local color
		if C_UnitAuras_GetAuraDispelTypeColor and auraInstanceID then
			local curve = GetDispelColorCurve()
			if curve then
				-- pcall: secret/forbidden auras can still make the C call throw.
				local ok, result = pcall(C_UnitAuras_GetAuraDispelTypeColor, unit, auraInstanceID, curve)
				if ok then
					color = result
				end
			end
		end

		if not color then
			local dispelName = auraData.dispelName
			if not IsSecret(dispelName) then
				color = DebuffTypeColor[dispelName or "none"]
			end
		end
		color = color or DebuffTypeColor.none

		-- The curve API returns a ColorMixin (has :GetRGB); the fallback tables expose r/g/b.
		local r, g, b
		if color.GetRGB then
			r, g, b = color:GetRGB()
		else
			r, g, b = color.r, color.g, color.b
		end
		button.KKUI_Border:SetVertexColor(r, g, b)
	else
		K.SetBorderColor(button.KKUI_Border)
	end

	-- Show spell stat for 'Soleahs Secret Technique'
	local spellID = auraData.spellId
	if not IsSecret(spellID) and spellID == 368512 then
		local points = auraData.points
		-- MIDNIGHT (12.0): points can itself be a secret table; guard before indexing.
		if points and not IsSecret(points) then
			local point1, point2, point3 = points[1], points[2], points[3]
			if type(point1) == "number" and type(point2) == "number" and type(point3) == "number" and not IsSecret(point1) and not IsSecret(point2) and not IsSecret(point3) then
				button.count:SetText(Module:GetSpellStat(unpack(points)))
			end
		end
	end

	button.spellID = not IsSecret(spellID) and spellID or nil
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
		K.SetFont(child.count, select(1, child.count:GetFont()), fontSize, "OUTLINE")

		child.timer:SetFontObject(K.UIFontOutline)
		K.SetFont(child.timer, select(1, child.timer:GetFont()), fontSize, "OUTLINE")
		StyleNativeCooldownText(child)

		-- WARNING: Blizzard bug fix: icons aren't being hidden when reducing the maximum number of buttons.
		if index > (cfg.maxWraps * cfg.wrapAfter) and child:IsShown() then
			child:Hide()
		end

		index = index + 1
		child = select(index, header:GetChildren())
	end
end

Module._DeferredUpdateAuraLayout = Module._DeferredUpdateAuraLayout or function()
	Module:UpdateAuraLayout()
end

function Module:UpdateAuraLayout()
	if not C["Auras"].Enable or not Module.settings then
		return
	end

	if InCombatLockdown() then
		if not Module._pendingAuraLayout then
			Module._pendingAuraLayout = true
			if not Module._pendingAuraLayoutRegistered then
				Module._pendingAuraLayoutRegistered = true
				K:RegisterEvent("PLAYER_REGEN_ENABLED", Module._DeferredUpdateAuraLayout)
			end
		end
		return
	end

	Module._pendingAuraLayout = nil

	local cfg = C["Auras"]
	Module.settings.Buffs.size = cfg.BuffSize
	Module.settings.Buffs.wrapAfter = cfg.BuffsPerRow
	Module.settings.Buffs.reverseGrow = cfg.ReverseBuffs
	Module.settings.Debuffs.size = cfg.DebuffSize
	Module.settings.Debuffs.wrapAfter = cfg.DebuffsPerRow
	Module.settings.Debuffs.reverseGrow = cfg.ReverseDebuffs

	if Module.BuffFrame then
		Module:UpdateHeader(Module.BuffFrame)
	end
	if Module.DebuffFrame then
		Module:UpdateHeader(Module.DebuffFrame)
	end

	if Module._pendingAuraLayoutRegistered then
		Module._pendingAuraLayoutRegistered = nil
		K:UnregisterEvent("PLAYER_REGEN_ENABLED", Module._DeferredUpdateAuraLayout)
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
	K.SetFont(button.count, select(1, button.count:GetFont()), fontSize, "OUTLINE")

	button.timer = button:CreateFontString(nil, "OVERLAY")
	button.timer:SetPoint("TOP", button, "BOTTOM", 1, 5)
	button.timer:SetFontObject(K.UIFontOutline)
	K.SetFont(button.timer, select(1, button.timer:GetFont()), fontSize, "OUTLINE")

	button.Cooldown = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
	button.Cooldown:SetAllPoints(button.icon)
	button.Cooldown:SetDrawSwipe(false)
	button.Cooldown:SetDrawBling(false)
	button.Cooldown:SetHideCountdownNumbers(false)
	StyleNativeCooldownText(button)

	button:StyleButton()
	button:CreateBorder()

	-- button:RegisterForClicks("RightButtonUp", "RightButtonDown")
	button:SetScript("OnAttributeChanged", Module.OnAttributeChanged)
	button:SetScript("OnEnter", Module.Button_OnEnter)
	button:SetScript("OnLeave", K.HideTooltip)
end
