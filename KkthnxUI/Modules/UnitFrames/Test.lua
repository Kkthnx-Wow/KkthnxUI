--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/UnitFrames/Test.lua
	Purpose:
		A preview mode for the group and boss frames. Secure group headers can only
		show real units, so to lay out and judge the look while solo we spawn plain
		mock frames that mimic ours (bordered health bar, name, power, a few fake
		debuffs). They anchor to the same movers the real frames use, so what you
		position here is what you get. Purely visual, never interactive.
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]

local Module = K:GetModule("UnitFrames")

local CreateFrame = CreateFrame
local pairs = pairs
local floor = math.floor
local random = math.random
local format = string.format

local pcall = pcall
local RAID_CLASS_COLORS = RAID_CLASS_COLORS

local CLASSES = { "WARRIOR", "MAGE", "ROGUE", "PRIEST", "DRUID", "HUNTER", "PALADIN", "SHAMAN", "WARLOCK", "MONK", "DEATHKNIGHT", "DEMONHUNTER", "EVOKER" }
local NAMES = { "Kkthnx", "Aldric", "Mireva", "Torvald", "Sylara", "Bront", "Yvenne", "Dragan", "Lunara", "Kaelis", "Vorin", "Ysolde", "Grimm", "Nyssa", "Rhogar", "Elowen", "Dorne", "Fenwick", "Isolde", "Marek" }

-- A generic debuff icon for the fake aura row.
local FAKE_ICONS = { 136207, 135813, 136118, 132298, 135936 }

local function ClassColor(index)
	local class = CLASSES[(index - 1) % #CLASSES + 1]
	local c = RAID_CLASS_COLORS and RAID_CLASS_COLORS[class]
	if c then
		return c.r, c.g, c.b
	end
	return 0.4, 0.6, 0.9
end

-- One mock frame: a bordered health bar with name and percent, an optional power
-- bar below, and an optional fake debuff row.
-- Gap between the health and power bars, matching our border spacing.
local POWER_GAP = 6

local function BuildMock(parent, index, width, height, powerHeight, withAuras, withPortrait)
	local f = CreateFrame("Frame", nil, parent)
	local total = height + (powerHeight > 0 and (powerHeight + POWER_GAP) or 0)
	f:SetSize(width, total)

	-- Square portrait hanging off the left, like the real party frame.
	if withPortrait then
		local portrait = CreateFrame("Frame", nil, f)
		portrait:SetSize(total, total)
		portrait:SetPoint("TOPRIGHT", f, "TOPLEFT", -POWER_GAP, 0)
		local pr, pg, pb = ClassColor(index)
		local fill = portrait:CreateTexture(nil, "ARTWORK")
		fill:SetAllPoints()
		fill:SetColorTexture(pr * 0.4, pg * 0.4, pb * 0.4, 1)
		K.CreateBackground(portrait, 0.1, 0.1, 0.1, 0.9)
		K.CreateBorder(portrait)
	end

	local health = CreateFrame("StatusBar", nil, f)
	health:SetPoint("TOPLEFT", f, "TOPLEFT", 0, 0)
	health:SetPoint("TOPRIGHT", f, "TOPRIGHT", 0, 0)
	health:SetHeight(height)
	health:SetStatusBarTexture(K.GetTexture(C.Unitframe and C.Unitframe.Texture or "KkthnxUI"))
	local r, g, b = ClassColor(index)
	health:SetStatusBarColor(r, g, b)
	health:SetMinMaxValues(0, 100)
	health:SetValue(random(35, 100))
	K.CreateBackground(health, 0.1, 0.1, 0.1, 0.9)
	K.CreateBorder(health)

	local name = health:CreateFontString(nil, "OVERLAY")
	K.SetFont(name, height > 22 and 12 or 10, K.FontOutlineStyle())
	name:SetPoint("LEFT", health, "LEFT", 3, 0)
	name:SetText(NAMES[(index - 1) % #NAMES + 1])

	local hp = health:CreateFontString(nil, "OVERLAY")
	K.SetFont(hp, height > 22 and 12 or 10, K.FontOutlineStyle())
	hp:SetPoint("RIGHT", health, "RIGHT", -3, 0)
	hp:SetText(format("%d%%", health:GetValue()))

	if powerHeight > 0 then
		local power = CreateFrame("StatusBar", nil, f)
		power:SetPoint("TOPLEFT", health, "BOTTOMLEFT", 0, -POWER_GAP)
		power:SetPoint("TOPRIGHT", health, "BOTTOMRIGHT", 0, -POWER_GAP)
		power:SetHeight(powerHeight)
		power:SetStatusBarTexture(K.GetTexture(C.Unitframe and C.Unitframe.Texture or "KkthnxUI"))
		power:SetStatusBarColor(0.36, 0.55, 0.81)
		power:SetMinMaxValues(0, 100)
		power:SetValue(random(20, 100))
		K.CreateBackground(power, 0.1, 0.1, 0.1, 0.9)
		K.CreateBorder(power)
	end

	if withAuras then
		local dispel = { { 0.9, 0, 0 }, { 0, 0.6, 1 }, { 0.6, 0, 1 }, { 0.6, 0.4, 0 } }
		local prev
		for i = 1, 3 do
			local icon = CreateFrame("Frame", nil, f)
			icon:SetSize(20, 20)
			-- Sit to the right of the frame so a downward stack never overlaps.
			if prev then
				icon:SetPoint("LEFT", prev, "RIGHT", 4, 0)
			else
				icon:SetPoint("LEFT", f, "RIGHT", 6, 0)
			end
			prev = icon
			local tex = icon:CreateTexture(nil, "ARTWORK")
			tex:SetAllPoints()
			tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
			tex:SetTexture(FAKE_ICONS[(i - 1) % #FAKE_ICONS + 1])
			K.CreateBorder(icon)
			local col = dispel[(i - 1) % #dispel + 1]
			if icon.KKUI_Border then
				icon.KKUI_Border.__customColor = true
				icon.KKUI_Border:SetVertexColor(col[1], col[2], col[3])
			end
			-- Fake duration text so the timer placement is visible.
			local dur = icon:CreateFontString(nil, "OVERLAY")
			K.SetFont(dur, 11, K.FontOutlineStyle())
			dur:SetPoint("CENTER")
			dur:SetText(random(3, 40))
		end
	end

	return f
end

-- Lay a pool of mock frames out in a grid anchored to a mover.
local function BuildGroup(self, key, moverKey, count, perColumn, width, height, powerHeight, spacing, withAuras, withPortrait)
	if self.testFrames[key] then
		return self.testFrames[key]
	end
	local mover = K.GetMover and K.GetMover(moverKey)
	local holder = CreateFrame("Frame", nil, UIParent)
	holder:SetFrameStrata("MEDIUM")
	holder:SetSize(width, height)
	holder:SetPoint("TOPLEFT", mover or UIParent, mover and "TOPLEFT" or "CENTER", 0, 0)

	local step = height + (powerHeight > 0 and (powerHeight + POWER_GAP) or 0) + spacing
	local frames = {}
	for i = 1, count do
		local col = perColumn > 0 and floor((i - 1) / perColumn) or 0
		local row = perColumn > 0 and ((i - 1) % perColumn) or (i - 1)
		local f = BuildMock(holder, i, width, height, powerHeight, withAuras, withPortrait)
		f:SetPoint("TOPLEFT", holder, "TOPLEFT", col * (width + spacing), -row * step)
		frames[i] = f
	end
	holder.frames = frames
	self.testFrames[key] = holder
	return holder
end

-- Build (once) and show or hide every mock group.
function Module:ShowTestFrames(show)
	self.testFrames = self.testFrames or {}

	if show then
		local uf = C.Unitframe
		-- Spacing matches the real frames: boss uses its own Spacing, party is set
		-- 24px apart, raid uses the standard 6px. Each build is guarded so a problem
		-- with one never blocks the others.
		pcall(BuildGroup, self, "Boss", "BossFrames", 5, 0, uf.Boss.Width, uf.Boss.Height, uf.Boss.PowerHeight, uf.Boss.Spacing or 34, true, false)
		pcall(BuildGroup, self, "Party", "PartyFrames", 5, 0, uf.Party.Width, uf.Party.Height, uf.Party.PowerHeight, 24, true, uf.Party.Portrait)
		pcall(BuildGroup, self, "Raid", "RaidFrames", 40, 5, uf.Raid.Width, uf.Raid.Height, uf.Raid.PowerMode ~= "None" and uf.Raid.PowerHeight or 0, 6, false, false)
	end

	for _, holder in pairs(self.testFrames) do
		holder:SetShown(show)
	end
end
