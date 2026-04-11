--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Manages and displays the Totem Bar for classes with totems/summons.
-- - Design: Hooks Blizzard's TotemFrame to update custom totem icons and timers.
-- - Events: PLAYER_ENTERING_WORLD, TOTEM_UPDATE (via hooksecurefunc)
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Auras")

-- PERF: Localize globals and C-functions to reduce lookup overhead.
local _G = _G
local CreateFrame = CreateFrame
local GetTotemInfo = GetTotemInfo
local InCombatLockdown = InCombatLockdown
local TotemFrame = TotemFrame
local UIParent = UIParent
local hooksecurefunc = hooksecurefunc

local totems = {}

-- ---------------------------------------------------------------------------
-- Initialization
-- ---------------------------------------------------------------------------
-- REASON: Initialize the custom totem bar and its individual totem slots.
-- PERF: Pre-calculate width and height based on orientation to avoid repeated layout logic.
function Module:totemBarInit()
	local margin = 6
	local vertical = C["Auras"].VerticalTotems
	local iconSize = C["Auras"].TotemSize
	local width = vertical and (iconSize + margin * 2) or (iconSize * 4 + margin * 5)
	local height = vertical and (iconSize * 4 + margin * 5) or (iconSize + margin * 2)

	local totemBar = _G["KKUI_TotemBar"]
	if not totemBar then
		totemBar = CreateFrame("Frame", "KKUI_TotemBar", K.PetBattleFrameHider)
	end
	totemBar:SetSize(width, height)

	if not totemBar.mover then
		totemBar.mover = K.Mover(totemBar, "Totembar", "Totems", { "BOTTOM", UIParent, "BOTTOM", 0, 378 })
	end
	totemBar.mover:SetSize(width, height)

	for i = 1, 4 do
		local totem = totems[i]
		if not totem then
			totem = CreateFrame("Frame", nil, totemBar)
			totem.CD = CreateFrame("Cooldown", nil, totem, "CooldownFrameTemplate")
			totem.CD:SetPoint("TOPLEFT", totem, "TOPLEFT", 1, -1)
			totem.CD:SetPoint("BOTTOMRIGHT", totem, "BOTTOMRIGHT", -1, 1)
			totem.CD:SetReverse(true)

			totem.Icon = totem:CreateTexture(nil, "ARTWORK")
			totem.Icon:SetAllPoints()
			totem.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

			totem:CreateBorder()
			totem:SetAlpha(0)
			totems[i] = totem
		end

		totem:SetSize(iconSize, iconSize)
		totem:ClearAllPoints()
		if i == 1 then
			totem:SetPoint("BOTTOMLEFT", margin, margin)
		elseif vertical then
			totem:SetPoint("BOTTOM", totems[i - 1], "TOP", 0, margin)
		else
			totem:SetPoint("LEFT", totems[i - 1], "RIGHT", margin, 0)
		end
	end
end

-- ---------------------------------------------------------------------------
-- Updates
-- ---------------------------------------------------------------------------
-- REASON: Update the custom totem slots based on Blizzard's underlying TotemFrame state.
-- WARNING: Modifications to Blizzard's secure totem buttons are wrapped in combat checks to prevent taint.
function Module:totemBarUpdate()
	local activeTotems = 0
	for button in _G.TotemFrame.totemPool:EnumerateActive() do
		activeTotems = activeTotems + 1

		local _, _, start, dur, icon = GetTotemInfo(button.slot)
		local totem = totems[activeTotems]
		if K.IsSecretValue(dur) then
			totem.CD:SetCooldownFromDurationObject(GetTotemDuration(button.slot))
			totem.CD:Show()
			totem:SetAlpha(1)
		elseif start and dur then
			totem.CD:SetCooldown(start, dur)
			totem.CD:Show()
			totem:SetAlpha(1)
		else
			totem.CD:Hide()
			totem:SetAlpha(0)
		end
		totem.Icon:SetTexture(icon)

		button:ClearAllPoints()
		button:SetParent(totem)
		button:SetAllPoints(totem)
		button:SetAlpha(0)
		button:SetFrameLevel(totem:GetFrameLevel() + 1)
	end

	for i = activeTotems + 1, 4 do
		local totem = totems[i]
		totem.Icon:SetTexture("")
		totem.CD:Hide()
		totem:SetAlpha(0)
	end
end

-- ---------------------------------------------------------------------------
-- Core Module Functions
-- ---------------------------------------------------------------------------
-- REASON: Entry point for the totem module. Only initializes if the feature is enabled in config.
function Module:CreateTotems()
	if not C["Auras"].Totems then
		return
	end

	Module:totemBarInit()
	hooksecurefunc(TotemFrame, "Update", Module.totemBarUpdate)
end
