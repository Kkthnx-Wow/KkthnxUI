--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Auras/Preview.lua
	Purpose:
		A layout preview for the player buffs, debuffs, and weapon enchants. The
		aura blocks are driven by Blizzard's intrinsic and only ever hold real
		auras, so to check size, spacing, and position without waiting on a real
		buff, this fills each block with placeholder icons on demand. Toggled with
		/kk auras.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

if not (K.Client and K.Client.IsRetail) then
	return
end

local Module = K:GetModule("Auras")

local _G = _G
local CreateFrame = CreateFrame
local GetTime = GetTime

-- A stand-in icon that reads clearly against the frames.
local PLACEHOLDER = "Interface\\ICONS\\Spell_Nature_MoonGlow"

-- The four dispel schools, so a debuff preview shows the same border colours the
-- engine tints real debuffs with (magic, curse, disease, poison).
local DISPEL_TINTS = {
	{ 0.20, 0.60, 1.00 }, -- Magic
	{ 0.60, 0.00, 1.00 }, -- Curse
	{ 0.60, 0.40, 0.00 }, -- Disease
	{ 0.00, 0.60, 0.00 }, -- Poison
}

-- The raid-frame dispel badges, in the same order as the tints above.
local DISPEL_ATLASES = {
	"RaidFrame-Icon-DebuffMagic",
	"RaidFrame-Icon-DebuffCurse",
	"RaidFrame-Icon-DebuffDisease",
	"RaidFrame-Icon-DebuffPoison",
}

-- Fill a holder with count placeholder icons laid out the way the real container
-- grows: from the top-right, leftwards, wrapping down after perRow. When tints is
-- given, each icon's border cycles through those colours.
local function FillBlock(store, holder, count, size, perRow, spacing, tints)
	if not holder then
		return
	end
	local step = size + spacing
	for i = 1, count do
		local icon = store[i]
		if not icon then
			icon = CreateFrame("Frame", nil, holder)
			local tex = icon:CreateTexture(nil, "ARTWORK")
			tex:SetPoint("TOPLEFT", icon, "TOPLEFT", 1, -1)
			tex:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", -1, 1)
			tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
			tex:SetTexture(PLACEHOLDER)
			K.CreateBorder(icon)
			local badge = icon:CreateTexture(nil, "OVERLAY", nil, 3)
			badge:SetPoint("BOTTOMRIGHT", icon, "BOTTOMRIGHT", 1, -1)
			icon.Badge = badge
			store[i] = icon
		end
		icon:SetFrameLevel(holder:GetFrameLevel() + 10)
		icon:SetSize(size, size)
		icon.Badge:SetSize(size * 0.45, size * 0.45)
		local col = (i - 1) % perRow
		local row = math.floor((i - 1) / perRow)
		icon:ClearAllPoints()
		icon:SetPoint("TOPRIGHT", holder, "TOPRIGHT", -col * step, -row * step)

		if tints and icon.KKUI_Border then
			local slot = ((i - 1) % #tints) + 1
			local tint = tints[slot]
			icon.KKUI_Border:SetVertexColor(tint[1], tint[2], tint[3])
			icon.Badge:SetAtlas(DISPEL_ATLASES[slot])
			icon.Badge:Show()
		else
			if icon.KKUI_Border then
				K.ResetBorderColor(icon.KKUI_Border)
			end
			icon.Badge:Hide()
		end
		icon:Show()
	end
end

local function HideStore(store)
	for _, icon in ipairs(store) do
		icon:Hide()
	end
end

function Module:ToggleTest()
	local db = C.Auras
	if not db.Enable then
		K.Print("Enable the aura display first.")
		return
	end

	self.PreviewOn = not self.PreviewOn
	self.PreviewBuffs = self.PreviewBuffs or {}
	self.PreviewDebuffs = self.PreviewDebuffs or {}

	if self.PreviewOn then
		-- Two full rows of each so wrapping and the down-growth are visible.
		FillBlock(self.PreviewBuffs, _G.KKUI_PlayerBuffsAnchor, db.PerRow + 4, db.BuffSize, db.PerRow, db.Spacing)
		FillBlock(self.PreviewDebuffs, _G.KKUI_PlayerDebuffsAnchor, db.PerRow + 4, db.DebuffSize, db.PerRow, db.Spacing, DISPEL_TINTS)

		-- Force both weapon-enchant buttons to show with a fake five-minute timer.
		if self.EnchantButtons then
			for _, button in ipairs(self.EnchantButtons) do
				button.Icon:SetTexture(PLACEHOLDER)
				button.Cooldown:SetCooldown(GetTime() - 60, 300)
				button.ends = nil
				button:Show()
			end
			if self.WeaponEnchant then
				self.WeaponEnchant:Show()
			end
		end
		K.Print("Aura preview ON. Run /kk auras again to clear.")
	else
		HideStore(self.PreviewBuffs)
		HideStore(self.PreviewDebuffs)
		if self.UpdateWeaponEnchants then
			self:UpdateWeaponEnchants()
		end
		K.Print("Aura preview OFF.")
	end
end
