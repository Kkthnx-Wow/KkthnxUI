local K, C, L = select(2, ...):unpack()
if C.Unitframe.Enable ~= true then return end

local _, ns = ...
local oUF = ns.oUF
local colors = K.Colors

local ignorePetSpells = {
	115746, -- Felbolt (Green Imp)
	3110, -- firebolt (imp)
	31707, -- waterbolt (water elemental)
	85692, -- Doom Bolt
}

-- Channeling ticks, based on Castbars by Xbeeps
local CastingBarFrameTicksSet
do
	local GetSpellInfo, GetCombatRatingBonus = GetSpellInfo, GetCombatRatingBonus

	-- Negative means not modified by haste
	local BaseTickDuration = {}
	if K.Class == "WARLOCK" then
		BaseTickDuration[GetSpellInfo(689) or ""] = 1 -- Drain Life
		BaseTickDuration[GetSpellInfo(198590) or ""] = 1 -- Drain Soul
		BaseTickDuration[GetSpellInfo(755) or ""] = 1 -- Health Funnel
	elseif K.Class == "DRUID" then
		BaseTickDuration[GetSpellInfo(740) or ""] = 2 -- Tranquility
	elseif K.Class == "PRIEST" then
		BaseTickDuration[GetSpellInfo(47540) or ""] = 1 -- Penance
		BaseTickDuration[GetSpellInfo(193473) or ""] = 1 -- Mind Flay
		BaseTickDuration[GetSpellInfo(48045) or ""] = 1 -- Mind Sear
		BaseTickDuration[GetSpellInfo(64843) or ""] = 2 -- Divine Hymn
		BaseTickDuration[GetSpellInfo(179338) or ""] = 1 -- Searing Insanity
	elseif K.Class == "MAGE" then
		BaseTickDuration[GetSpellInfo(5143) or ""] = 0.4 -- Arcane Missiles
		BaseTickDuration[GetSpellInfo(12051) or ""] = 2 -- Evocation
	elseif K.Class == "MONK" then
		BaseTickDuration[GetSpellInfo(117952) or ""] = 1 -- Crackling Jade Lightning
		BaseTickDuration[GetSpellInfo(115175) or ""] = 1 -- Soothing Mist
		BaseTickDuration[GetSpellInfo(113656) or ""] = 1 -- Fists of Fury
		BaseTickDuration[GetSpellInfo(173330) or ""] = -1 -- Mana Tea (not modified by haste)
	end

	function CastingBarFrameTicksSet(Castbar, unit, name, stop)
		Castbar.ticks = Castbar.ticks or {}
		local function CreateATick()
			local spark = Castbar:CreateTexture(nil, "ARTWORK")
			spark:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
			spark:SetVertexColor(1, 1, 1, 0.75)
			spark:SetBlendMode("ADD")
			spark:SetWidth(10)
			table.insert(Castbar.ticks, spark)
			return spark
		end
		for _,tick in ipairs(Castbar.ticks) do
			tick:Hide()
		end
		if (stop) then return end
		if (Castbar) then
			local baseTickDuration = BaseTickDuration[name]
			local tickDuration
			if (baseTickDuration) then
				if (baseTickDuration > 0) then
					local castTime = select(7, GetSpellInfo(2060))
					if (not castTime or (castTime == 0)) then
						castTime = 2500 / (1 + (GetCombatRatingBonus(CR_HASTE_SPELL) or 0) / 100)
					end
					tickDuration = (castTime / 2500) * baseTickDuration
				else
					tickDuration = -baseTickDuration
				end
			end
			if (tickDuration) then
				local width = Castbar:GetWidth()
				local delta = (tickDuration * width / Castbar.max)
				local i = 1
				while (delta * i) < width do
					if i > #Castbar.ticks then CreateATick() end
					local tick = Castbar.ticks[i]
					tick:SetHeight(Castbar:GetHeight() * 1.5)
					tick:SetPoint("CENTER", Castbar, "LEFT", delta * i, 0)
					tick:Show()
					i = i + 1
				end
			end
		end
	end
end

-- Setup Castbars
local BasePos = {
	boss = {"TOPRIGHT", "TOPLEFT", -10, 0},
	arena = {"TOPRIGHT", "TOPLEFT", -30, -10},
}

function ns.CreateCastbars(self, unit)
	local uconfig = ns.config[self.cUnit]
	if not uconfig.cbshow then return end
	local Movers = K.Movers

	local Castbar = K.CreateStatusBar(self, "BORDER", self:GetName().."Castbar")
	Castbar:SetFrameStrata("HIGH")
	K.CreateBorder(Castbar, 11, 3)

	if (BasePos[self.cUnit]) then
		local point, rpoint, x, y = unpack(BasePos[self.cUnit])
		Castbar:SetPoint(point, self, rpoint, x + uconfig.cboffset[1], y + uconfig.cboffset[2])
	else
		if (unit == "player") then
			Castbar:SetPoint(unpack(C.Position.UnitFrames.PlayerCastbar))
			Castbar:SetSize(C.Unitframe.PlayerCastbarWidth, C.Unitframe.PlayerCastbarHeight)
		elseif (unit == "target") then
			Castbar:SetPoint(unpack(C.Position.UnitFrames.TargetCastbar))
			Castbar:SetSize(C.Unitframe.TargetCastbarWidth, C.Unitframe.TargetCastbarHeight)
		elseif (unit == "focus") then
			Castbar:SetPoint(unpack(C.Position.UnitFrames.FocusCastbar))
			Castbar:SetSize(C.Unitframe.FocusCastbarWidth, C.Unitframe.FocusCastbarHeight)
		end
		Movers:RegisterFrame(Castbar)
	end

	Castbar.Background = Castbar:CreateTexture(nil, "BACKGROUND")
	Castbar.Background:SetTexture(C.Media.Blank)
	Castbar.Background:SetAllPoints(Castbar)

	if (unit == "player") then
		local SafeZone = Castbar:CreateTexture(nil, "BORDER")
		SafeZone:SetTexture(C.Media.Texture)
		SafeZone:SetVertexColor(unpack(C.Unitframe.CastbarSafeZoneColor))
		Castbar.SafeZone = SafeZone

		local Flash = CreateFrame("Frame", nil, Castbar)
		Flash:SetAllPoints(Castbar)

		K.CreateBorder(Flash, 11, 3)
		Flash:SetBorderTexture("white")
		Flash:SetBorderColor(1, 1, 0.6)
		if (uconfig.cbicon == "RIGHT") then
			Flash:SetBorderPadding(3, 3, 3, 4 + uconfig.cbheight)
		elseif (uconfig.cbicon == "LEFT") then
			Flash:SetBorderPadding(3, 3, 4 + uconfig.cbheight, 3)
		end
		Castbar.Flash = Flash
		Castbar.Ticks = ns.config.castbarticks
	end

	local Spark = Castbar:CreateTexture(nil, "ARTWORK", nil, 1)
	if (unit == "player") then
		Spark:SetSize(15, (C.Unitframe.PlayerCastbarHeight * 1.2))
	elseif (unit == "target") then
		Spark:SetSize(15, (C.Unitframe.TargetCastbarHeight * 1.2))
	elseif (unit == "focus") then
		Spark:SetSize(15, (C.Unitframe.FocusCastbarHeight * 1.2))
	else
		Spark:SetSize(15, (uconfig.cbheight * 1.2))
	end
	Spark:SetBlendMode("ADD")
	Castbar.Spark = Spark

	if (uconfig.cbicon ~= "NONE") then
		local Icon = Castbar:CreateTexture(nil, "ARTWORK")
		Icon:SetSize(uconfig.cbheight + 2, uconfig.cbheight + 2)
		Icon:SetTexCoord(0.05, 0.95, 0.05, 0.95)
		if (uconfig.cbicon == "RIGHT") then
			Icon:SetPoint("LEFT", Castbar, "RIGHT", 0, 0)
			Castbar:SetBorderPadding(3, 3, 3, 4 + uconfig.cbheight)
		elseif (uconfig.cbicon == "LEFT") then
			Icon:SetPoint("RIGHT", Castbar, "LEFT", 0, 0)
			Castbar:SetBorderPadding(3, 3, 4 + uconfig.cbheight, 3)
		elseif (uconfig.cbicon == "TOP") then
			Icon:SetPoint("BOTTOM", Castbar, "TOP", 0, 6)
		elseif (uconfig.cbicon == "BOTTOM") then
			Icon:SetPoint("TOP", Castbar, "BOTTOM", 0, -6)
		end
		Castbar.Icon = Icon
	end

	Castbar.Time = K.SetFontString(Castbar, C.Media.Font, 13, nil, "RIGHT")
	Castbar.Time:SetPoint("RIGHT", Castbar, -5, 0)

	Castbar.Text = K.SetFontString(Castbar, C.Media.Font, 13, nil, "LEFT")
	Castbar.Text:SetPoint("LEFT", Castbar, 4, 0)
	Castbar.Text:SetPoint("RIGHT", Castbar.Time, "LEFT", -8, 0)
	Castbar.Text:SetWordWrap(false)

	Castbar.PostCastStart = ns.PostCastStart
	Castbar.PostCastFailed = ns.PostCastFailed
	Castbar.PostCastInterrupted = ns.PostCastInterrupted
	Castbar.PostCastInterruptible = ns.UpdateCastbarColor
	Castbar.PostCastNotInterruptible = ns.UpdateCastbarColor
	Castbar.PostCastStop = ns.PostStop
	Castbar.PostChannelStop = ns.PostStop
	Castbar.PostChannelStart = ns.PostChannelStart

	self.CCastbar = Castbar
end

function ns.PostCastStart(Castbar, unit, name, castid)
	if (unit == "pet") then
		Castbar:SetAlpha(1)
		for _, spellID in pairs(ignorePetSpells) do
			if (UnitCastingInfo("pet") == GetSpellInfo(spellID)) then
				Castbar:SetAlpha(0)
			end
		end
	end
	ns.UpdateCastbarColor(Castbar, unit)
	if (Castbar.SafeZone) then
		Castbar.SafeZone:SetDrawLayer("BORDER", -1)
	end
end

function ns.PostCastFailed(Castbar, unit, spellname, castid)
	if (Castbar.Text) then
		Castbar.Text:SetText(FAILED)
	end
	Castbar:SetStatusBarColor(1, 0, 0) -- Red
	if (Castbar.max) then
		Castbar:SetValue(Castbar.max)
	end
end

function ns.PostCastInterrupted(Castbar, unit, spellname, castid)
	if (Castbar.Text) then
		Castbar.Text:SetText(INTERRUPTED)
	end
	Castbar:SetStatusBarColor(1, 0, 0)
	if (Castbar.max) then -- Some spells got trough without castbar
		Castbar:SetValue(Castbar.max)
	end
end

function ns.PostStop(Castbar, unit, spellname, castid)
	--Castbar:SetValue(Castbar.max)
	if (Castbar.Ticks) then
		CastingBarFrameTicksSet(Castbar, unit, name, true)
	end
end

function ns.PostChannelStart(Castbar, unit, name)
	if (unit == "pet" and Castbar:GetAlpha() == 0) then
		Castbar:SetAlpha(1)
	end

	ns.UpdateCastbarColor(Castbar, unit)
	if Castbar.SafeZone then
		Castbar.SafeZone:SetDrawLayer("BORDER", 1)
	end
	if (Castbar.Ticks) then
		CastingBarFrameTicksSet(Castbar, unit, name)
	end
end

function ns.UpdateCastbarColor(Castbar, unit)
	local color
	local bR, bG, bB = K.GetPaintColor(0.2)
	local text = "default"

	if UnitIsUnit(unit, "player") then
		color = colors.class[select(2, UnitClass("player"))]
	elseif Castbar.interrupt then
		color = colors.uninterruptible
		text = "white"
		bR, bG, bB = 0.8, 0.7, 0.2
	elseif UnitIsFriend(unit, "player") then
		color = colors.reaction[5]
	else
		color = colors.reaction[1]
	end

	Castbar:SetBorderTexture(text)
	Castbar:SetBorderColor(bR, bG, bB)

	local r, g, b = color[1], color[2], color[3]
	Castbar:SetStatusBarColor(r * 0.8, g * 0.8, b * 0.8)
	--Castbar.Background:SetVertexColor(r * 0.2, g * 0.2, b * 0.2)
	Castbar.Background:SetVertexColor(unpack(C.Media.Backdrop_Color))
end