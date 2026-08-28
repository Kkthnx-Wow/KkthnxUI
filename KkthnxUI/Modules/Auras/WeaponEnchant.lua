--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Auras/WeaponEnchant.lua
	Purpose:
		Show temporary weapon enchants (rogue poisons, shaman imbues, sharpening
		stones, oils) next to the player buffs. These are not auras, so the aura
		container never carries them. Each slot gets an icon, a quality-tinted
		border, and a depleting cooldown ring with the remaining time.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

if not (K.Client and K.Client.IsRetail) then
	return
end

local Module = K:GetModule("Auras")

local CreateFrame = CreateFrame
local GetWeaponEnchantInfo = GetWeaponEnchantInfo
local GetInventoryItemTexture = GetInventoryItemTexture
local GetInventoryItemQuality = GetInventoryItemQuality
local GetItemQualityColor = C_Item and C_Item.GetItemQualityColor
local GetTime = GetTime
local abs = math.abs
local ceil = math.ceil

-- Inventory slots for the main hand and off hand, the only two the retail client
-- reports enchants for.
local SLOTS = { 16, 17 }

-- ---------------------------------------------------------------------------
-- Buttons
-- ---------------------------------------------------------------------------

local function OnEnter(self)
	GameTooltip:SetOwner(self, "ANCHOR_LEFT")
	GameTooltip:SetInventoryItem("player", self.slot)
	GameTooltip:Show()
end

local function OnLeave()
	GameTooltip:Hide()
end

local function CreateButton(parent, size, slot)
	local button = CreateFrame("Frame", nil, parent)
	button:SetSize(size, size)
	button.slot = slot

	local icon = button:CreateTexture(nil, "ARTWORK")
	icon:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
	icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
	icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
	button.Icon = icon

	local cd = CreateFrame("Cooldown", nil, button, "CooldownFrameTemplate")
	cd:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
	cd:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
	cd:SetReverse(true)
	cd:SetHideCountdownNumbers(false)
	button.Cooldown = cd

	K.CreateBorder(button)
	button:EnableMouse(true)
	button:SetScript("OnEnter", OnEnter)
	button:SetScript("OnLeave", OnLeave)
	button:Hide()
	return button
end

-- ---------------------------------------------------------------------------
-- Refresh
-- ---------------------------------------------------------------------------

-- The client only hands back the remaining time, so bucket it up to a sensible
-- total the way other UIs do, giving the ring something to sweep against.
local function DurationBucket(remain)
	if remain <= 60 then
		return 60
	elseif remain <= 600 then
		return 600
	elseif remain <= 1800 then
		return 1800
	end
	return ceil(remain / 3600) * 3600
end

function Module:UpdateWeaponEnchants()
	local buttons = self.EnchantButtons
	if not buttons then
		return
	end

	local hasMain, mainExp, _, _, hasOff, offExp = GetWeaponEnchantInfo()
	local has = { hasMain, hasOff }
	local expiration = { mainExp, offExp }
	local shown = 0

	for i, slot in ipairs(SLOTS) do
		local button = buttons[i]
		if has[i] then
			button.Icon:SetTexture(GetInventoryItemTexture("player", slot))

			-- Quality border, falling back to the configured border colour for common
			-- or unrated items.
			if GetItemQualityColor then
				local quality = GetInventoryItemQuality("player", slot)
				if quality and quality > 1 then
					local r, g, b = GetItemQualityColor(quality)
					if button.KKUI_Border then
						button.KKUI_Border:SetVertexColor(r, g, b)
					end
				elseif button.KKUI_Border then
					K.ResetBorderColor(button.KKUI_Border)
				end
			end

			-- Only restart the ring when the timer actually changed, so a refresh
			-- every second does not keep resetting the sweep.
			local remain = (expiration[i] or 0) / 1000
			local ends = GetTime() + remain
			if not button:IsShown() or abs(ends - (button.ends or 0)) > 1 then
				local duration = DurationBucket(remain)
				button.Cooldown:SetCooldown(ends - duration, duration)
				button.ends = ends
			end

			button:Show()
			shown = shown + 1
		else
			button.ends = nil
			button:Hide()
		end
	end

	self.WeaponEnchant:SetShown(shown > 0)
end

-- ---------------------------------------------------------------------------
-- Build
-- ---------------------------------------------------------------------------

function Module:SetupWeaponEnchants()
	if not C.Auras.WeaponEnchant then
		return
	end

	local db = C.Auras
	local size = db.BuffSize
	local step = size + db.Spacing

	-- A holder that carries the mover, with the row of buttons growing left from its
	-- right edge to match the buff block above it.
	local holder = CreateFrame("Frame", "KKUI_WeaponEnchantAnchor", UIParent)
	holder:SetSize(#SLOTS * step, size)

	-- Sit below the debuff block so the three rows stack: buffs, debuffs, enchants.
	local above = _G.KKUI_PlayerDebuffsAnchor or _G.KKUI_PlayerBuffsAnchor
	local point = above and { "TOPRIGHT", above, "BOTTOMRIGHT", 0, -db.Spacing } or { "TOPRIGHT", _G.Minimap or UIParent, "BOTTOMRIGHT", 0, -db.Spacing }
	K.CreateMover(holder, "WeaponEnchant", "Weapon Enchants", point, #SLOTS * step, size, "TOPRIGHT")

	self.WeaponEnchant = holder
	self.EnchantButtons = {}
	for i in ipairs(SLOTS) do
		local button = CreateButton(holder, size, SLOTS[i])
		if i == 1 then
			button:SetPoint("TOPRIGHT", holder, "TOPRIGHT", 0, 0)
		else
			button:SetPoint("RIGHT", self.EnchantButtons[i - 1], "LEFT", -db.Spacing, 0)
		end
		self.EnchantButtons[i] = button
	end

	holder:RegisterEvent("UNIT_INVENTORY_CHANGED")
	holder:RegisterEvent("PLAYER_ENTERING_WORLD")
	holder:SetScript("OnEvent", function(_, _, unit)
		if unit and unit ~= "player" then
			return
		end
		Module:UpdateWeaponEnchants()
	end)

	-- A slow ticker catches an enchant quietly expiring, which fires no event.
	C_Timer.NewTicker(1, function()
		Module:UpdateWeaponEnchants()
	end)

	self:UpdateWeaponEnchants()
end
