local K, C, L = unpack(select(2, ...))
if C.Unitframe.Enable ~= true or C.Unitframe.Castbars ~= true then return end

-- Lua API
local _G = _G
local math_abs = math.abs

-- Wow API
local CreateFrame = _G.CreateFrame
local GetNetStats = _G.GetNetStats
local GetSpellInfo = _G.GetSpellInfo
local GetTime = _G.GetTime
local UnitBuff = _G.UnitBuff
local UnitCanAttack = _G.UnitCanAttack
local UnitClass = _G.UnitClass
local UnitIsPlayer = _G.UnitIsPlayer
local UnitReaction = _G.UnitReaction
local UnitSpellHaste = _G.UnitSpellHaste

local Movers = K.Movers

-- All unitframe Castbar functions
local ticks = {}
function K.HideTicks()
	for i = 1, #ticks do
		ticks[i]:Hide()
	end
end

function K.SetCastTicks(self, numTicks, extraTickRatio)
	-- Adjust tick heights
	self.tickHeight = self:GetHeight()

	extraTickRatio = extraTickRatio or 0
	K.HideTicks()
	if numTicks and numTicks <= 0 then return end;
	local w = self:GetWidth()
	local d = w / (numTicks + extraTickRatio)
	for i = 1, numTicks do
		if not ticks[i] then
			ticks[i] = self:CreateTexture(nil, "OVERLAY")
			ticks[i]:SetTexture(C.Media.Texture)
			ticks[i]:SetVertexColor(0, 0, 0, 0.8)
			ticks[i]:SetWidth(2) -- We could use 1
		end

		ticks[i]:SetHeight(self.tickHeight)

		ticks[i]:ClearAllPoints()
		ticks[i]:SetPoint("RIGHT", self, "LEFT", d * i, 0)
		ticks[i]:Show()
	end
end

local MageSpellName = GetSpellInfo(5143) -- Arcane Missiles
local MageBuffName = GetSpellInfo(166872) -- 4p T17 bonus proc for arcane

function K.PostCastStart(self, unit, name)
	if unit == "vehicle" then unit = "player" end

	if unit == "player" and C.Unitframe.CastbarLatency == true and self.Latency then
		local _, _, _, lag = GetNetStats()
		local latency = GetTime() - (self.castSent or 0)
		lag = lag / 1e3 > self.max and self.max or lag / 1e3
		latency = latency > self.max and lag or latency
		self.Latency:SetText(("%dms"):format(latency * 1e3))
		self.castSent = nil
	end

	if C.Unitframe.CastbarTicks and unit == "player" then
		local baseTicks = K.ChannelTicks[name]

		-- Detect channeling spell and if it's the same as the previously channeled one
		if baseTicks and name == self.prevSpellCast then
			self.chainChannel = true
		elseif baseTicks then
			self.chainChannel = nil
			self.prevSpellCast = name
		end

		if baseTicks and K.ChannelTicksSize[name] and K.HastedChannelTicks[name] then
			local tickIncRate = 1 / baseTicks
			local curHaste = UnitSpellHaste("player") * 0.01
			local firstTickInc = tickIncRate / 2
			local bonusTicks = 0
			if curHaste >= firstTickInc then
				bonusTicks = bonusTicks + 1
			end

			local x = tonumber(K.Round(firstTickInc + tickIncRate, 2))
			while curHaste >= x do
				x = tonumber(K.Round(firstTickInc + (tickIncRate * bonusTicks), 2))
				if curHaste >= x then
					bonusTicks = bonusTicks + 1
				end
			end

			local baseTickSize = K.ChannelTicksSize[name]
			local hastedTickSize = baseTickSize / (1 + curHaste)
			local extraTick = self.max - hastedTickSize * (baseTicks + bonusTicks)
			local extraTickRatio = extraTick / hastedTickSize

			K.SetCastTicks(self, baseTicks + bonusTicks, extraTickRatio)
		elseif baseTicks and K.ChannelTicksSize[name] then
			local curHaste = UnitSpellHaste("player") * 0.01
			local baseTickSize = K.ChannelTicksSize[name]
			local hastedTickSize = baseTickSize / (1 + curHaste)
			local extraTick = self.max - hastedTickSize * (baseTicks)
			local extraTickRatio = extraTick / hastedTickSize

			K.SetCastTicks(self, baseTicks, extraTickRatio)
		elseif baseTicks then
			local hasBuff = UnitBuff("player", MageBuffName)
			if name == MageSpellName and hasBuff then
				baseTicks = baseTicks + 5
			end
			K.SetCastTicks(self, baseTicks)
		else
			K.HideTicks()
		end
	elseif unit == "player" then
		K.HideTicks()
	end

	-- Colors, you know Colours? ;)
	local colors = K.Colors
	local r, g, b = colors.castColor[1], colors.castColor[2], colors.castColor[3]

	local t
	if C.Unitframe.CastClassColor and UnitIsPlayer(unit) then
		local _, class = UnitClass(unit)
		t = K.Colors.class[class]
	elseif C.Unitframe.CastUnitReaction and UnitReaction(unit, 'player') then
		t = K.Colors.reaction[UnitReaction(unit, "player")]
	end

	if (t) then
		r, g, b = t[1], t[2], t[3]
	end

	if self.interrupt and unit ~= "player" and UnitCanAttack("player", unit) then
		r, g, b = colors.castNoInterrupt[1], colors.castNoInterrupt[2], colors.castNoInterrupt[3]
	end

	self:SetStatusBarColor(r, g, b)
	if self.Background:IsShown() then
		self.Background:SetVertexColor(r * 0.18, g * 0.18, b * 0.18)
	end
end

function K.PostCastStop(self)
	self.chainChannel = nil
	self.prevSpellCast = nil
end

function K.PostChannelUpdate(self, unit, name)
	if not (unit == "player" or unit == "vehicle") then return end

	if C.Unitframe.CastbarTicks then
		local baseTicks = K.ChannelTicks[name]

		if baseTicks and K.ChannelTicksSize[name] and K.HastedChannelTicks[name] then
			local tickIncRate = 1 / baseTicks
			local curHaste = UnitSpellHaste("player") * 0.01
			local firstTickInc = tickIncRate / 2
			local bonusTicks = 0
			if curHaste >= firstTickInc then
				bonusTicks = bonusTicks + 1
			end

			local x = tonumber(K.Round(firstTickInc + tickIncRate, 2))
			while curHaste >= x do
				x = tonumber(K.Round(firstTickInc + (tickIncRate * bonusTicks), 2))
				if curHaste >= x then
					bonusTicks = bonusTicks + 1
				end
			end

			local baseTickSize = K.ChannelTicksSize[name]
			local hastedTickSize = baseTickSize / (1 + curHaste)
			local extraTick = self.max - hastedTickSize * (baseTicks + bonusTicks)
			if self.chainChannel then
				self.extraTickRatio = extraTick / hastedTickSize
				self.chainChannel = nil
			end

			K.SetCastTicks(self, baseTicks + bonusTicks, self.extraTickRatio)
		elseif baseTicks and K.ChannelTicksSize[name] then
			local curHaste = UnitSpellHaste("player") * 0.01
			local baseTickSize = K.ChannelTicksSize[name]
			local hastedTickSize = baseTickSize / (1 + curHaste)
			local extraTick = self.max - hastedTickSize * (baseTicks)
			if self.chainChannel then
				self.extraTickRatio = extraTick / hastedTickSize
				self.chainChannel = nil
			end

			K.SetCastTicks(self, baseTicks, self.extraTickRatio)
		elseif baseTicks then
			local hasBuff = UnitBuff("player", MageBuffName)
			if name == MageSpellName and hasBuff then
				baseTicks = baseTicks + 5
			end
			if self.chainChannel then
				baseTicks = baseTicks + 1
			end
			K.SetCastTicks(self, baseTicks)
		else
			K.HideTicks()
		end
	else
		K.HideTicks()
	end
end

function K.PostCastInterruptible(self, unit)
	if unit == "vehicle" or unit == "player" then return end

	-- Colors, you know Colours? ;)
	local colors = K.Colors
	local r, g, b = colors.castColor[1], colors.castColor[2], colors.castColor[3]

	local t
	if C.Unitframe.CastClassColor and UnitIsPlayer(unit) then
		local _, class = UnitClass(unit)
		t = K.Colors.class[class]
	elseif C.Unitframe.CastUnitReaction and UnitReaction(unit, 'player') then
		t = K.Colors.reaction[UnitReaction(unit, "player")]
	end

	if (t) then
		r, g, b = t[1], t[2], t[3]
	end

	if self.interrupt and UnitCanAttack("player", unit) then
		r, g, b = colors.castNoInterrupt[1], colors.castNoInterrupt[2], colors.castNoInterrupt[3]
	end

	self:SetStatusBarColor(r, g, b)
	if self.Background:IsShown() then
		self.Background:SetVertexColor(r * 0.18, g * 0.18, b * 0.18)
	end
end

function K.PostCastInterrupted(self)
	self:SetMinMaxValues(0, 1)
	self:SetValue(1)
	self:SetStatusBarColor(1, 0, 0)

	self.Spark:SetPoint("CENTER", self, "RIGHT")
end

function K.PostCastNotInterruptible(self)
	local colors = K.Colors
	self:SetStatusBarColor(colors.castNoInterrupt[1], colors.castNoInterrupt[2], colors.castNoInterrupt[3])
end

function K.CustomDelayText(self, duration)
	if self.channeling then
		self.Time:SetText(("%.1f |cffaf5050%.1f|r"):format(math_abs(duration - self.max), self.delay))
	else
		self.Time:SetText(("%.1f |cffaf5050%s %.1f|r"):format(duration, "+", self.delay))
	end
end

function K.CustomTimeText(self, duration)
	if self.channeling then
		self.Time:SetText(("%.1f"):format(math_abs(duration - self.max)))
	else
		self.Time:SetText(("%.1f"):format(duration))
	end
end

-- Create CastBars
function K.CreateCastBar(self)
	if C.Unitframe.Castbars then
		if self.MatchUnit == "player" then
			local CastBar = K.CreateStatusBar(self, "oUF_KkthnxPlayer_Castbar")
			CastBar:SetStatusBarTexture(C.Media.Texture)
			CastBar:SetSize(C.Unitframe.CastbarWidth, C.Unitframe.CastbarHeight)
			CastBar:SetPoint(C.Position.UnitFrames.PlayerCastbar[1], C.Position.UnitFrames.PlayerCastbar[2], C.Position.UnitFrames.PlayerCastbar[3], C.Position.UnitFrames.PlayerCastbar[4], C.Position.UnitFrames.PlayerCastbar[5])
			CastBar:SetClampedToScreen(true)

			K.CreateBorder(CastBar, -1)

			CastBar.timeToHold = 0.4

			CastBar.Background = CastBar:CreateTexture(nil, "BORDER")
			CastBar.Background:SetAllPoints(CastBar)
			CastBar.Background:SetTexture(C.Media.Blank)

			CastBar.Spark = CastBar:CreateTexture(nil, "OVERLAY")
			CastBar.Spark:SetBlendMode("ADD")
			CastBar.Spark:SetWidth(10)
			CastBar.Spark:SetHeight(CastBar:GetHeight() * 1.6)
			CastBar.Spark:SetVertexColor(1, 1, 1)

			CastBar.Time = CastBar:CreateFontString(nil, "OVERLAY")
			CastBar.Time:SetFont(C.Media.Font, C.Media.Font_Size, C.Unitframe.Outline and "OUTLINE" or "")

			CastBar.Time:SetShadowOffset(C.Unitframe.Outline and 0 or K.Mult, C.Unitframe.Outline and -0 or -K.Mult)
			CastBar.Time:SetPoint("RIGHT", CastBar, "RIGHT", -4, 0)
			CastBar.Time:SetHeight(C.Media.Font_Size)
			CastBar.Time:SetTextColor(1, 1, 1)
			CastBar.Time:SetJustifyH("RIGHT")

			CastBar.Text = CastBar:CreateFontString(nil, "OVERLAY")
			CastBar.Text:SetFont(C.Media.Font, C.Media.Font_Size, C.Unitframe.Outline and "OUTLINE" or "")
			CastBar.Text:SetShadowOffset(C.Unitframe.Outline and 0 or K.Mult, C.Unitframe.Outline and -0 or -K.Mult)
			CastBar.Text:SetPoint("LEFT", CastBar, "LEFT", 2, 0)
			CastBar.Text:SetPoint("RIGHT", CastBar.Time, "LEFT", -1, 0)
			CastBar.Text:SetHeight(C.Media.Font_Size)
			CastBar.Text:SetTextColor(1, 1, 1)
			CastBar.Text:SetJustifyH("LEFT")

			if (C.Unitframe.CastbarIcon) then
				CastBar.Button = CreateFrame("Frame", nil, CastBar)
				CastBar.Button:SetSize(26, 26)

				K.CreateBorder(CastBar.Button, -1)

				CastBar.Icon = CastBar.Button:CreateTexture(nil, "ARTWORK")
				CastBar.Icon:SetPoint("RIGHT", CastBar, "LEFT", -8, 0)
				CastBar.Icon:SetSize(CastBar:GetHeight(), CastBar:GetHeight())
				CastBar.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

				CastBar.Button:SetAllPoints(CastBar.Icon)
			end

			if (C.Unitframe.CastbarLatency) then
				CastBar.SafeZone = CastBar:CreateTexture(nil, "OVERLAY")
				CastBar.SafeZone:SetTexture(C.Media.Blank)
				CastBar.SafeZone:SetVertexColor(0.69, 0.31, 0.31, 0.75)

				CastBar.Latency = K.SetFontString(CastBar, C.Media.Font, C.Media.Font_Size, C.Unitframe.Outline and "OUTLINE" or "", "RIGHT")
				CastBar.Latency:SetShadowOffset(C.Unitframe.Outline and 0 or K.Mult, C.Unitframe.Outline and -0 or -K.Mult)
				CastBar.Latency:SetTextColor(1, 1, 1)
				CastBar.Latency:SetPoint("TOPRIGHT", CastBar.Time, "BOTTOMRIGHT", 0, 0)
				CastBar.Latency:SetJustifyH("RIGHT")

				self:RegisterEvent("CURRENT_SPELL_CAST_CHANGED", function(self, event, caster)
					if (caster == "player" or caster == "vehicle") then
						CastBar.castSent = GetTime()
					end
				end)
			end

			CastBar.CustomDelayText = K.CustomDelayText
			CastBar.CustomTimeText = K.CustomTimeText
			CastBar.PostCastStart = K.PostCastStart
			CastBar.PostChannelStart = K.PostCastStart
			CastBar.PostCastStop = K.PostCastStop
			CastBar.PostChannelStop = K.PostCastStop
			CastBar.PostChannelUpdate = K.PostChannelUpdate
			CastBar.PostCastInterrupted = K.PostCastInterrupted
			CastBar.PostCastInterruptible = K.PostCastInterruptible
			CastBar.PostCastNotInterruptible = K.PostCastNotInterruptible

			Movers:RegisterFrame(CastBar)

			self.Castbar = CastBar

		elseif self.MatchUnit == "target" then
			local CastBar = K.CreateStatusBar(self, "oUF_KkthnxTarget_Castbar")
			CastBar:SetOrientation("HORIZONTAL")
			CastBar:SetStatusBarTexture(C.Media.Texture)
			CastBar:SetSize(C.Unitframe.CastbarWidth, C.Unitframe.CastbarHeight)
			CastBar:SetPoint(C.Position.UnitFrames.TargetCastbar[1], C.Position.UnitFrames.TargetCastbar[2], C.Position.UnitFrames.TargetCastbar[3], C.Position.UnitFrames.TargetCastbar[4], C.Position.UnitFrames.TargetCastbar[5])
			CastBar:SetClampedToScreen(true)

			K.CreateBorder(CastBar, -1)

			CastBar.timeToHold = 0.4

			CastBar.Spark = CastBar:CreateTexture(nil, "OVERLAY")
			CastBar.Spark:SetBlendMode("ADD")
			CastBar.Spark:SetWidth(10)
			CastBar.Spark:SetHeight(CastBar:GetHeight() * 1.6)
			CastBar.Spark:SetVertexColor(1, 1, 1)

			CastBar.Background = CastBar:CreateTexture(nil, "BORDER")
			CastBar.Background:SetAllPoints(CastBar)
			CastBar.Background:SetTexture(C.Media.Blank)

			CastBar.Shield = CastBar:CreateTexture(nil, "OVERLAY")
			CastBar.Shield:SetTexture[[Interface\AddOns\KkthnxUI\Media\Textures\CastBorderShield]]
			CastBar.Shield:SetPoint("LEFT", CastBar, "RIGHT", -4, 12)

			CastBar.Time = CastBar:CreateFontString(nil, "OVERLAY")
			CastBar.Time:SetFont(C.Media.Font, C.Media.Font_Size, C.Unitframe.Outline and "OUTLINE" or "")
			CastBar.Time:SetShadowOffset(C.Unitframe.Outline and 0 or K.Mult, C.Unitframe.Outline and -0 or -K.Mult)
			CastBar.Time:SetPoint("RIGHT", CastBar, "RIGHT", -4, 0)
			CastBar.Time:SetHeight(C.Media.Font_Size)
			CastBar.Time:SetTextColor(1, 1, 1)
			CastBar.Time:SetJustifyH("RIGHT")

			CastBar.Text = CastBar:CreateFontString(nil, "OVERLAY")
			CastBar.Text:SetFont(C.Media.Font, C.Media.Font_Size, C.Unitframe.Outline and "OUTLINE" or "")
			CastBar.Text:SetShadowOffset(C.Unitframe.Outline and 0 or K.Mult, C.Unitframe.Outline and -0 or -K.Mult)
			CastBar.Text:SetPoint("LEFT", CastBar, "LEFT", 2, 0)
			CastBar.Text:SetPoint("RIGHT", CastBar.Time, "LEFT", -1, 0)
			CastBar.Text:SetHeight(C.Media.Font_Size)
			CastBar.Text:SetTextColor(1, 1, 1)
			CastBar.Text:SetJustifyH("LEFT")

			if (C.Unitframe.CastbarIcon) then
				CastBar.Button = CreateFrame("Frame", nil, CastBar)
				CastBar.Button:SetSize(26, 26)
				K.CreateBorder(CastBar.Button, -1)

				CastBar.Icon = CastBar.Button:CreateTexture(nil, "ARTWORK")
				CastBar.Icon:SetPoint("RIGHT", CastBar, "LEFT", -8, 0)
				CastBar.Icon:SetSize(CastBar:GetHeight(), CastBar:GetHeight())
				CastBar.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

				CastBar.Button:SetAllPoints(CastBar.Icon)
			end

			CastBar.CustomDelayText = K.CustomDelayText
			CastBar.CustomTimeText = K.CustomTimeText
			CastBar.PostCastStart = K.PostCastStart
			CastBar.PostChannelStart = K.PostCastStart
			CastBar.PostCastStop = K.PostCastStop
			CastBar.PostChannelStop = K.PostCastStop
			CastBar.PostChannelUpdate = K.PostChannelUpdate
			CastBar.PostCastInterrupted = K.PostCastInterrupted
			CastBar.PostCastInterruptible = K.PostCastInterruptible
			CastBar.PostCastNotInterruptible = K.PostCastNotInterruptible

			Movers:RegisterFrame(CastBar)

			self.Castbar = CastBar

		elseif self.MatchUnit == "focus" then
			local CastBar = K.CreateStatusBar(self, "oUF_KkthnxFocus_Castbar")
			CastBar:SetPoint("LEFT", 0, 0)
			CastBar:SetPoint("RIGHT", -20, 0)
			CastBar:SetPoint("TOP", 0, 60)
			CastBar:SetHeight(18)
			CastBar:SetStatusBarTexture(C.Media.Texture)
			CastBar:SetClampedToScreen(true)

			K.CreateBorder(CastBar, -1)

			CastBar.timeToHold = 0.4

			CastBar.Spark = CastBar:CreateTexture(nil, "OVERLAY")
			CastBar.Spark:SetBlendMode("ADD")
			CastBar.Spark:SetWidth(10)
			CastBar.Spark:SetHeight(CastBar:GetHeight() * 1.6)
			CastBar.Spark:SetVertexColor(1, 1, 1)

			CastBar.Background = CastBar:CreateTexture(nil, "BORDER")
			CastBar.Background:SetAllPoints(CastBar)
			CastBar.Background:SetTexture(C.Media.Blank)

			CastBar.Time = CastBar:CreateFontString(nil, "OVERLAY")
			CastBar.Time:SetFont(C.Media.Font, C.Media.Font_Size, C.Unitframe.Outline and "OUTLINE" or "")
			CastBar.Time:SetShadowOffset(C.Unitframe.Outline and 0 or K.Mult, C.Unitframe.Outline and -0 or -K.Mult)
			CastBar.Time:SetPoint("RIGHT", CastBar, "RIGHT", -4, 0)
			CastBar.Time:SetHeight(C.Media.Font_Size)
			CastBar.Time:SetTextColor(1, 1, 1)
			CastBar.Time:SetJustifyH("RIGHT")

			CastBar.Text = CastBar:CreateFontString(nil, "OVERLAY")
			CastBar.Text:SetFont(C.Media.Font, C.Media.Font_Size, C.Unitframe.Outline and "OUTLINE" or "")
			CastBar.Text:SetShadowOffset(C.Unitframe.Outline and 0 or K.Mult, C.Unitframe.Outline and -0 or -K.Mult)
			CastBar.Text:SetPoint("LEFT", CastBar, "LEFT", 2, 0)
			CastBar.Text:SetPoint("RIGHT", CastBar.Time, "LEFT", -1, 0)
			CastBar.Text:SetHeight(C.Media.Font_Size)
			CastBar.Text:SetTextColor(1, 1, 1)
			CastBar.Text:SetJustifyH("LEFT")

			CastBar.Button = CreateFrame("Frame", nil, CastBar)
			CastBar.Button:SetSize(CastBar:GetHeight(), CastBar:GetHeight())
			CastBar.Button:SetPoint("LEFT", CastBar, "RIGHT", 8, 0)

			K.CreateBorder(CastBar.Button, -1)

			CastBar.Icon = CastBar.Button:CreateTexture(nil, "ARTWORK")
			CastBar.Icon:SetAllPoints()
			CastBar.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

			CastBar.CustomDelayText = K.CustomDelayText
			CastBar.CustomTimeText = K.CustomTimeText
			CastBar.PostCastStart = K.PostCastStart
			CastBar.PostChannelStart = K.PostCastStart
			CastBar.PostCastStop = K.PostCastStop
			CastBar.PostChannelStop = K.PostCastStop
			CastBar.PostChannelUpdate = K.PostChannelUpdate
			CastBar.PostCastInterrupted = K.PostCastInterrupted
			CastBar.PostCastInterruptible = K.PostCastInterruptible
			CastBar.PostCastNotInterruptible = K.PostCastNotInterruptible

			self.Castbar = CastBar
			self.Castbar.Icon = CastBar.Icon

		elseif self.IsBossFrame then
			local CastBar = K.CreateStatusBar(self, "oUF_KkthnxBoss_Castbar")
			CastBar:SetPoint("RIGHT", -138, 0)
			CastBar:SetPoint("LEFT", 0, 10)
			CastBar:SetPoint("LEFT", -138, 8)
			CastBar:SetHeight(16)
			CastBar:SetStatusBarTexture(C.Media.Texture)
			CastBar:SetClampedToScreen(true)

			K.CreateBorder(CastBar, -1)

			CastBar.Background = CastBar:CreateTexture(nil, "BORDER")
			CastBar.Background:SetAllPoints(CastBar)
			CastBar.Background:SetTexture(C.Media.Blank)

			CastBar.Spark = CastBar:CreateTexture(nil, "OVERLAY")
			CastBar.Spark:SetBlendMode("ADD")
			CastBar.Spark:SetWidth(10)
			CastBar.Spark:SetHeight(CastBar:GetHeight() * 1.6)
			CastBar.Spark:SetVertexColor(1, 1, 1)

			CastBar.Time = CastBar:CreateFontString(nil, "OVERLAY")
			CastBar.Time:SetFont(C.Media.Font, C.Media.Font_Size, C.Unitframe.Outline and "OUTLINE" or "")
			CastBar.Time:SetShadowOffset(C.Unitframe.Outline and 0 or K.Mult, C.Unitframe.Outline and -0 or -K.Mult)
			CastBar.Time:SetPoint("RIGHT", CastBar, "RIGHT", -4, 0)
			CastBar.Time:SetHeight(C.Media.Font_Size)
			CastBar.Time:SetTextColor(1, 1, 1)
			CastBar.Time:SetJustifyH("RIGHT")

			CastBar.Text = CastBar:CreateFontString(nil, "OVERLAY")
			CastBar.Text:SetFont(C.Media.Font, C.Media.Font_Size, C.Unitframe.Outline and "OUTLINE" or "")
			CastBar.Text:SetShadowOffset(C.Unitframe.Outline and 0 or K.Mult, C.Unitframe.Outline and -0 or -K.Mult)
			CastBar.Text:SetPoint("LEFT", CastBar, "LEFT", 2, 0)
			CastBar.Text:SetPoint("RIGHT", CastBar.Time, "LEFT", -1, 0)
			CastBar.Text:SetHeight(C.Media.Font_Size)
			CastBar.Text:SetTextColor(1, 1, 1)
			CastBar.Text:SetJustifyH("LEFT")

			CastBar.Button = CreateFrame("Frame", nil, CastBar)
			CastBar.Button:SetSize(CastBar:GetHeight(), CastBar:GetHeight())
			CastBar.Button:SetPoint("RIGHT", CastBar, "LEFT", -8, 0)

			K.CreateBorder(CastBar.Button, -1)

			CastBar.Icon = CastBar.Button:CreateTexture(nil, "ARTWORK")
			CastBar.Icon:SetAllPoints()
			CastBar.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

			CastBar.CustomDelayText = K.CustomDelayText
			CastBar.CustomTimeText = K.CustomTimeText
			CastBar.PostCastStart = K.PostCastStart
			CastBar.PostChannelStart = K.PostCastStart
			CastBar.PostCastStop = K.PostCastStop
			CastBar.PostChannelStop = K.PostCastStop
			CastBar.PostChannelUpdate = K.PostChannelUpdate
			CastBar.PostCastInterruptible = K.PostCastInterruptible
			CastBar.PostCastNotInterruptible = K.PostCastNotInterruptible

			self.Castbar = CastBar
			self.Castbar.Icon = CastBar.Icon

		elseif self.MatchUnit == "arena" then
			local CastBar = CreateFrame("StatusBar", nil, self)

			CastBar:SetPoint("RIGHT", -138, 0)
			CastBar:SetPoint("LEFT", 0, 10)
			CastBar:SetPoint("LEFT", -138, 8)
			CastBar:SetHeight(20)
			CastBar:SetStatusBarTexture(C.Media.Texture)
			CastBar:SetFrameLevel(6)

			K.CreateBorder(CastBar, -1)

			CastBar.Background = CastBar:CreateTexture(nil, "BORDER")
			CastBar.Background:SetAllPoints(CastBar)
			CastBar.Background:SetTexture(C.Media.Blank)
			CastBar.Background:SetVertexColor(C.Media.Backdrop_Color[1], C.Media.Backdrop_Color[2], C.Media.Backdrop_Color[3], C.Media.Backdrop_Color[4])

			CastBar.Time = CastBar:CreateFontString(nil, "OVERLAY")
			CastBar.Time:SetFont(C.Media.Font, C.Media.Font_Size, C.Unitframe.Outline and "OUTLINE" or "")
			CastBar.Time:SetShadowOffset(C.Unitframe.Outline and 0 or K.Mult, C.Unitframe.Outline and -0 or -K.Mult)
			CastBar.Time:SetPoint("RIGHT", CastBar, "RIGHT", -4, 0)
			CastBar.Time:SetTextColor(1, 1, 1)
			CastBar.Time:SetJustifyH("RIGHT")

			CastBar.Text = CastBar:CreateFontString(nil, "OVERLAY")
			CastBar.Text:SetFont(C.Media.Font, C.Media.Font_Size, C.Unitframe.Outline and "OUTLINE" or "")
			CastBar.Text:SetShadowOffset(C.Unitframe.Outline and 0 or K.Mult, C.Unitframe.Outline and -0 or -K.Mult)
			CastBar.Text:SetPoint("LEFT", CastBar, "LEFT", 4, 0)
			CastBar.Text:SetTextColor(1, 1, 1)
			CastBar.Text:SetWidth(166)
			CastBar.Text:SetJustifyH("LEFT")

			CastBar.Button = CreateFrame("Frame", nil, CastBar)
			CastBar.Button:SetSize(CastBar:GetHeight(), CastBar:GetHeight())
			CastBar.Button:SetPoint("RIGHT", CastBar, "LEFT", -4, 0)

			K.CreateBorder(CastBar.Button, -1)

			CastBar.Icon = CastBar.Button:CreateTexture(nil, "ARTWORK")
			CastBar.Icon:SetAllPoints()
			CastBar.Icon:SetTexCoord(unpack(K.TexCoords))

			CastBar.CustomDelayText = K.CustomDelayText
			CastBar.CustomTimeText = K.CustomTimeText
			CastBar.PostCastStart = K.PostCastStart
			CastBar.PostChannelStart = K.PostCastStart
			CastBar.PostCastStop = K.PostCastStop
			CastBar.PostChannelStop = K.PostCastStop
			CastBar.PostChannelUpdate = K.PostChannelUpdate
			CastBar.PostCastInterruptible = K.PostCastInterruptible
			CastBar.PostCastNotInterruptible = K.PostCastNotInterruptible

			self.Castbar = CastBar
			self.Castbar.Icon = CastBar.Icon
		end
	end
end