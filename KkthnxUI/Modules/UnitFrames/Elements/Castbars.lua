local K, C, L = unpack(select(2, ...))
if C["Unitframe"].Enable ~= true or C["Unitframe"].Castbars ~= true then return end

local _G = _G
local math_abs = math.abs
local pairs = pairs
local select = select
local tonumber = tonumber
local unpack = unpack
local math_min = math.min

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

local CastbarFont = K.GetFont(C["General"].Font)
local CastbarTexture = K.GetTexture(C["General"].Texture)
local CastbarTextureFlat = C["Media"].TextureFlat

-- All unit-frame Cast bar functions
local ticks = {}
local function HideTicks()
	for i = 1, #ticks do
		ticks[i]:Hide()
	end
end

local function SetCastTicks(self, numTicks, extraTickRatio)
	-- Adjust tick heights
	self.tickHeight = self:GetHeight()

	extraTickRatio = extraTickRatio or 0
	HideTicks()
	if numTicks and numTicks <= 0 then return end
	local w = self:GetWidth()
	local d = w / (numTicks + extraTickRatio)
	for i = 1, numTicks do
		if not ticks[i] then
			ticks[i] = self:CreateTexture(nil, "OVERLAY")
			ticks[i]:SetTexture(CastbarTexture)
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

local function PostCastStart(self, unit, name)
	if unit == "vehicle" then unit = "player" end

	self.Text:SetText(name)

	-- Get length of Time, then calculate available length for Text
	local timeWidth = self.Time:GetStringWidth()
	local textWidth = self:GetWidth() - timeWidth - 10
	local textStringWidth = self.Text:GetStringWidth()

	if timeWidth == 0 or textStringWidth == 0 then
		K.Delay(0.05, function() -- Delay may need tweaking
			textWidth = self:GetWidth() - self.Time:GetStringWidth() - 10
			textStringWidth = self.Text:GetStringWidth()
			if textWidth > 0 then self.Text:SetWidth(math_min(textWidth, textStringWidth)) end
		end)
	else
		self.Text:SetWidth(math_min(textWidth, textStringWidth))
	end

	self.Spark:SetSize(14, self:GetHeight() * 3.2)

	self.unit = unit

	if C["Unitframe"].CastbarTicks and unit == "player" then
		local baseTicks = K.ChannelTicks[name]

		-- Detect channeling spell and if it"s the same as the previously channeled one
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

			SetCastTicks(self, baseTicks + bonusTicks, extraTickRatio)
		elseif baseTicks and K.ChannelTicksSize[name] then
			local curHaste = UnitSpellHaste("player") * 0.01
			local baseTickSize = K.ChannelTicksSize[name]
			local hastedTickSize = baseTickSize / (1 + curHaste)
			local extraTick = self.max - hastedTickSize * (baseTicks)
			local extraTickRatio = extraTick / hastedTickSize

			SetCastTicks(self, baseTicks, extraTickRatio)
		elseif baseTicks then
			local hasBuff = UnitBuff("player", MageBuffName)
			if name == MageSpellName and hasBuff then
				baseTicks = baseTicks + 5
			end
			SetCastTicks(self, baseTicks)
		else
			HideTicks()
		end
	elseif unit == "player" then
		HideTicks()
	end

	local colors = K.Colors
	local r, g, b = colors.castColor[1], colors.castColor[2], colors.castColor[3]

	local t
	if C["Unitframe"].CastClassColor and UnitIsPlayer(unit) then
		local _, class = UnitClass(unit)
		t = K.Colors.class[class]
	elseif C["Unitframe"].CastReactionColor and UnitReaction(unit, "player") then
		t = K.Colors.reaction[UnitReaction(unit, "player")]
	end

	if(t) then
		r, g, b = t[1], t[2], t[3]
	end

	if self.notInterruptible and unit ~= "player" and UnitCanAttack("player", unit) then
		r, g, b = colors.castNoInterrupt[1], colors.castNoInterrupt[2], colors.castNoInterrupt[3]
	end

	self:SetStatusBarColor(r, g, b)
end

local function PostCastStop(self)
	self.chainChannel = nil
	self.prevSpellCast = nil
end

local function PostCastFailed(self)
	self:SetMinMaxValues(0, 1)
	self:SetValue(1)
	self:SetStatusBarColor(1, 0, 0)

	self.Spark:SetPoint("CENTER", self, "RIGHT")

	self.Time:SetText("")
end

local function PostChannelUpdate(self, unit, name)
	if not (unit == "player" or unit == "vehicle") then return end

	if C["Unitframe"].CastbarTicks then
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

			SetCastTicks(self, baseTicks + bonusTicks, self.extraTickRatio)
		elseif baseTicks and K.ChannelTicksSize[name] then
			local curHaste = UnitSpellHaste("player") * 0.01
			local baseTickSize = K.ChannelTicksSize[name]
			local hastedTickSize = baseTickSize / (1 + curHaste)
			local extraTick = self.max - hastedTickSize * (baseTicks)
			if self.chainChannel then
				self.extraTickRatio = extraTick / hastedTickSize
				self.chainChannel = nil
			end

			SetCastTicks(self, baseTicks, self.extraTickRatio)
		elseif baseTicks then
			local hasBuff = UnitBuff("player", MageBuffName)
			if name == MageSpellName and hasBuff then
				baseTicks = baseTicks + 5
			end
			if self.chainChannel then
				baseTicks = baseTicks + 1
			end
			SetCastTicks(self, baseTicks)
		else
			HideTicks()
		end
	else
		HideTicks()
	end
end

local function PostCastInterruptible(self, unit)
	if unit == "vehicle" or unit == "player" then return end

	local colors = K.Colors
	local r, g, b = colors.castColor[1], colors.castColor[2], colors.castColor[3]

	local t
	if C["Unitframe"].CastClassColor and UnitIsPlayer(unit) then
		local _, class = UnitClass(unit)
		t = K.Colors.class[class]
	elseif C["Unitframe"].CastReactionColor and UnitReaction(unit, "player") then
		t = K.Colors.reaction[UnitReaction(unit, "player")]
	end

	if(t) then
		r, g, b = t[1], t[2], t[3]
	end

	if self.notInterruptible and UnitCanAttack("player", unit) then
		r, g, b = colors.castNoInterrupt[1], colors.castNoInterrupt[2], colors.castNoInterrupt[3]
	end

	self:SetStatusBarColor(r, g, b)
end

local function PostCastNotInterruptible(self)
	local colors = K.Colors
	self:SetStatusBarColor(colors.castNoInterrupt[1], colors.castNoInterrupt[2], colors.castNoInterrupt[3])
end

local function CustomCastDelayText(self, duration)
	if self.casting then
		duration = self.max - duration
	end

	if self.channeling then
		self.Time:SetText(("%.1f |cffaf5050%.1f|r"):format(duration, self.delay))
	else
		self.Time:SetText(("%.1f |cffaf5050%s %.1f|r"):format(math_abs(duration - self.max), "+", self.delay))
	end
end

local function CustomTimeText(self, duration)
	if self.max > 600 then
		return self.Time:SetText("")
	end

	if self.channeling then
		self.Time:SetText(("%.1f"):format(duration))
	else
		self.Time:SetText(("%.1f"):format(math_abs(duration - self.max)))
	end
end

-- Create CastBars
function K.CreateCastBar(self, unit)
	if C["Unitframe"].Castbars then
		if unit == "player" then
			local CastBar = CreateFrame("StatusBar", "$parentCastbar", self)
			if (C["Unitframe"].BarsStyle.Value == "FlatBarsStyle") then
				CastBar:SetStatusBarTexture(CastbarTextureFlat)
			elseif (C["Unitframe"].BarsStyle.Value == "DefaultBarsStyle") then
				CastBar:SetStatusBarTexture(CastbarTexture)
			end
			CastBar:SetSize(C["Unitframe"].CastbarWidth, C["Unitframe"].CastbarHeight)
			CastBar:SetPoint(C.Position.UnitFrames.PlayerCastbar[1], C.Position.UnitFrames.PlayerCastbar[2], C.Position.UnitFrames.PlayerCastbar[3], C.Position.UnitFrames.PlayerCastbar[4], C.Position.UnitFrames.PlayerCastbar[5])
			CastBar:SetClampedToScreen(true)

			CastBar.Spark = CastBar:CreateTexture(nil, "OVERLAY")
			CastBar.Spark:SetTexture(C["Media"].Spark)
			CastBar.Spark:SetBlendMode("ADD")

			CastBar.Time = CastBar:CreateFontString(nil, "OVERLAY")
			CastBar.Time:SetFont(C["Media"].Font, C["Media"].FontSize, C["Unitframe"].Outline and "OUTLINE" or "")
			CastBar.Time:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
			CastBar.Time:SetPoint("RIGHT", CastBar, "RIGHT", -4, 0)
			CastBar.Time:SetHeight(C["Media"].FontSize)
			CastBar.Time:SetTextColor(1, 1, 1)
			CastBar.Time:SetJustifyH("RIGHT")

			CastBar.Text = CastBar:CreateFontString(nil, "OVERLAY")
			CastBar.Text:SetFont(C["Media"].Font, C["Media"].FontSize, C["Unitframe"].Outline and "OUTLINE" or "")
			CastBar.Text:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
			CastBar.Text:SetPoint("LEFT", CastBar, "LEFT", 2, 0)
			CastBar.Text:SetPoint("RIGHT", CastBar.Time, "LEFT", -1, 0)
			CastBar.Text:SetHeight(C["Media"].FontSize)
			CastBar.Text:SetTextColor(1, 1, 1)
			CastBar.Text:SetJustifyH("LEFT")

			CastBar:SetTemplate("Transparent", true)

			if (C["Unitframe"].CastbarIcon) then
				CastBar.Button = CreateFrame("Frame", nil, CastBar)
				CastBar.Button:SetSize(26, 26)

				CastBar.Button:SetTemplate("Transparent")

				CastBar.Icon = CastBar.Button:CreateTexture(nil, "ARTWORK")
				CastBar.Icon:SetPoint("RIGHT", CastBar, "LEFT", -6, 0)
				CastBar.Icon:SetSize(CastBar:GetHeight(), CastBar:GetHeight())
				CastBar.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

				CastBar.Button:SetAllPoints(CastBar.Icon)
			end

			if (C["Unitframe"].CastbarLatency) then
				CastBar.SafeZone = CastBar:CreateTexture(nil, "ARTWORK")
				CastBar.SafeZone:SetTexture(C["Media"].Blank)
				CastBar.SafeZone:SetVertexColor(0.69, 0.31, 0.31, 0.75)

				CastBar.Latency = K.SetFontString(CastBar, C["Media"].Font, C["Media"].FontSize, C["Unitframe"].Outline and "OUTLINE" or "", "RIGHT")
				CastBar.Latency:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
				CastBar.Latency:SetTextColor(1, 1, 1)
				CastBar.Latency:SetPoint("TOPRIGHT", CastBar.Time, "BOTTOMRIGHT", 0, 0)
				CastBar.Latency:SetJustifyH("RIGHT")

				self:RegisterEvent("CURRENT_SPELL_CAST_CHANGED", function(self, event, caster)
					if (caster == "player" or caster == "vehicle") then
						CastBar.castSent = GetTime()
					end
				end)
			end

			CastBar.CustomDelayText = CustomCastDelayText
			CastBar.CustomTimeText = CustomTimeText
			CastBar.PostCastStart = PostCastStart
			CastBar.PostChannelStart = PostCastStart
			CastBar.PostCastStop = PostCastStop
			CastBar.PostChannelStop = PostCastStop
			CastBar.PostCastFailed = PostCastFailed
			CastBar.PostCastInterrupted = PostCastFailed
			CastBar.PostChannelUpdate = PostChannelUpdate
			CastBar.PostCastInterruptible = PostCastInterruptible
			CastBar.PostCastNotInterruptible = PostCastNotInterruptible

			CastBar.timeToHold = 0.4

			Movers:RegisterFrame(CastBar)

			-- Set to castbar.Icon
			self.Castbar = CastBar
			self.Castbar.Icon = CastBar.Icon

			return self.Castbar
		end

		if unit == "target" then
			local CastBar = CreateFrame("StatusBar", "$parentCastbar", self)
			if (C["Unitframe"].BarsStyle.Value == "FlatBarsStyle") then
				CastBar:SetStatusBarTexture(CastbarTextureFlat)
			elseif (C["Unitframe"].BarsStyle.Value == "DefaultBarsStyle") then
				CastBar:SetStatusBarTexture(CastbarTexture)
			end
			CastBar:SetSize(C["Unitframe"].CastbarWidth, C["Unitframe"].CastbarHeight)
			CastBar:SetPoint(C.Position.UnitFrames.TargetCastbar[1], C.Position.UnitFrames.TargetCastbar[2], C.Position.UnitFrames.TargetCastbar[3], C.Position.UnitFrames.TargetCastbar[4], C.Position.UnitFrames.TargetCastbar[5])
			CastBar:SetClampedToScreen(true)

			CastBar.Spark = CastBar:CreateTexture(nil, "OVERLAY")
			CastBar.Spark:SetTexture(C["Media"].Spark)
			CastBar.Spark:SetBlendMode("ADD")

			CastBar.Shield = CastBar:CreateTexture(nil, "OVERLAY")
			CastBar.Shield:SetTexture[[Interface\AddOns\KkthnxUI\Media\Textures\CastBorderShield]]
			CastBar.Shield:SetPoint("LEFT", CastBar, "RIGHT", -4, 12)

			CastBar.Time = CastBar:CreateFontString(nil, "OVERLAY")
			CastBar.Time:SetFont(C["Media"].Font, C["Media"].FontSize, C["Unitframe"].Outline and "OUTLINE" or "")
			CastBar.Time:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
			CastBar.Time:SetPoint("RIGHT", CastBar, "RIGHT", -4, 0)
			CastBar.Time:SetHeight(C["Media"].FontSize)
			CastBar.Time:SetTextColor(1, 1, 1)
			CastBar.Time:SetJustifyH("RIGHT")

			CastBar.Text = CastBar:CreateFontString(nil, "OVERLAY")
			CastBar.Text:SetFont(C["Media"].Font, C["Media"].FontSize, C["Unitframe"].Outline and "OUTLINE" or "")
			CastBar.Text:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
			CastBar.Text:SetPoint("LEFT", CastBar, "LEFT", 2, 0)
			CastBar.Text:SetPoint("RIGHT", CastBar.Time, "LEFT", -1, 0)
			CastBar.Text:SetHeight(C["Media"].FontSize)
			CastBar.Text:SetTextColor(1, 1, 1)
			CastBar.Text:SetJustifyH("LEFT")

			CastBar:SetTemplate("Transparent", true)

			if (C["Unitframe"].CastbarIcon) then
				CastBar.Button = CreateFrame("Frame", nil, CastBar)
				CastBar.Button:SetSize(26, 26)
				CastBar.Button:SetTemplate("Transparent")

				CastBar.Icon = CastBar.Button:CreateTexture(nil, "ARTWORK")
				CastBar.Icon:SetPoint("RIGHT", CastBar, "LEFT", -6, 0)
				CastBar.Icon:SetSize(CastBar:GetHeight(), CastBar:GetHeight())
				CastBar.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

				CastBar.Button:SetAllPoints(CastBar.Icon)
			end

			CastBar.CustomDelayText = CustomCastDelayText
			CastBar.CustomTimeText = CustomTimeText
			CastBar.PostCastStart = PostCastStart
			CastBar.PostChannelStart = PostCastStart
			CastBar.PostCastStop = PostCastStop
			CastBar.PostChannelStop = PostCastStop
			CastBar.PostCastFailed = PostCastFailed
			CastBar.PostCastInterrupted = PostCastFailed
			CastBar.PostChannelUpdate = PostChannelUpdate
			CastBar.PostCastInterruptible = PostCastInterruptible
			CastBar.PostCastNotInterruptible = PostCastNotInterruptible

			CastBar.timeToHold = 0.4

			Movers:RegisterFrame(CastBar)

			-- Set to castbar.Icon
			self.Castbar = CastBar
			self.Castbar.Icon = CastBar.Icon

			return self.Castbar
		end

		if unit == "focus" then
			local CastBar = CreateFrame("StatusBar", "$parentCastbar", self)
			CastBar:SetPoint("LEFT", 4, 0)
			CastBar:SetPoint("RIGHT", -30, 0)
			CastBar:SetPoint("TOP", 0, 60)
			CastBar:SetHeight(18)
			if (C["Unitframe"].BarsStyle.Value == "FlatBarsStyle") then
				CastBar:SetStatusBarTexture(CastbarTextureFlat)
			elseif (C["Unitframe"].BarsStyle.Value == "DefaultBarsStyle") then
				CastBar:SetStatusBarTexture(CastbarTexture)
			end
			CastBar:SetClampedToScreen(true)

			CastBar.Spark = CastBar:CreateTexture(nil, "OVERLAY")
			CastBar.Spark:SetTexture(C["Media"].Spark)
			CastBar.Spark:SetBlendMode("ADD")

			CastBar.Time = CastBar:CreateFontString(nil, "OVERLAY")
			CastBar.Time:SetFont(C["Media"].Font, C["Media"].FontSize, C["Unitframe"].Outline and "OUTLINE" or "")
			CastBar.Time:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
			CastBar.Time:SetPoint("RIGHT", CastBar, "RIGHT", -4, 0)
			CastBar.Time:SetHeight(C["Media"].FontSize)
			CastBar.Time:SetTextColor(1, 1, 1)
			CastBar.Time:SetJustifyH("RIGHT")

			CastBar.Text = CastBar:CreateFontString(nil, "OVERLAY")
			CastBar.Text:SetFont(C["Media"].Font, C["Media"].FontSize, C["Unitframe"].Outline and "OUTLINE" or "")
			CastBar.Text:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
			CastBar.Text:SetPoint("LEFT", CastBar, "LEFT", 2, 0)
			CastBar.Text:SetPoint("RIGHT", CastBar.Time, "LEFT", -1, 0)
			CastBar.Text:SetHeight(C["Media"].FontSize)
			CastBar.Text:SetTextColor(1, 1, 1)
			CastBar.Text:SetJustifyH("LEFT")

			CastBar.Button = CreateFrame("Frame", nil, CastBar)
			CastBar.Button:SetSize(CastBar:GetHeight(), CastBar:GetHeight())
			CastBar.Button:SetPoint("LEFT", CastBar, "RIGHT", 8, 0)

			CastBar:SetTemplate("Transparent", true)
			CastBar.Button:SetTemplate("Transparent")

			CastBar.Icon = CastBar.Button:CreateTexture(nil, "ARTWORK")
			CastBar.Icon:SetAllPoints()
			CastBar.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

			CastBar.CustomDelayText = CustomCastDelayText
			CastBar.CustomTimeText = CustomTimeText
			CastBar.PostCastStart = PostCastStart
			CastBar.PostChannelStart = PostCastStart
			CastBar.PostCastStop = PostCastStop
			CastBar.PostChannelStop = PostCastStop
			CastBar.PostCastFailed = PostCastFailed
			CastBar.PostCastInterrupted = PostCastFailed
			CastBar.PostChannelUpdate = PostChannelUpdate
			CastBar.PostCastInterruptible = PostCastInterruptible
			CastBar.PostCastNotInterruptible = PostCastNotInterruptible

			CastBar.timeToHold = 0.4

			-- Set to castbar.Icon
			self.Castbar = CastBar
			self.Castbar.Icon = CastBar.Icon

			return self.Castbar
		end

		if unit == "boss" then
			local CastBar = CreateFrame("StatusBar", "$parentCastbar", self)
			CastBar:SetPoint("LEFT", 4, 0)
			CastBar:SetPoint("RIGHT", -4, 0)
			CastBar:SetPoint("TOP", 0, 20)
			CastBar:SetHeight(18)
			if (C["Unitframe"].BarsStyle.Value == "FlatBarsStyle") then
				CastBar:SetStatusBarTexture(CastbarTextureFlat)
			elseif (C["Unitframe"].BarsStyle.Value == "DefaultBarsStyle") then
				CastBar:SetStatusBarTexture(CastbarTexture)
			end
			CastBar:SetClampedToScreen(true)

			CastBar.Spark = CastBar:CreateTexture(nil, "OVERLAY")
			CastBar.Spark:SetTexture(C["Media"].Spark)
			CastBar.Spark:SetBlendMode("ADD")

			CastBar.Time = CastBar:CreateFontString(nil, "OVERLAY")
			CastBar.Time:SetFont(C["Media"].Font, C["Media"].FontSize, C["Unitframe"].Outline and "OUTLINE" or "")
			CastBar.Time:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
			CastBar.Time:SetPoint("RIGHT", CastBar, "RIGHT", -4, 0)
			CastBar.Time:SetHeight(C["Media"].FontSize)
			CastBar.Time:SetTextColor(1, 1, 1)
			CastBar.Time:SetJustifyH("RIGHT")

			CastBar.Text = CastBar:CreateFontString(nil, "OVERLAY")
			CastBar.Text:SetFont(C["Media"].Font, C["Media"].FontSize, C["Unitframe"].Outline and "OUTLINE" or "")
			CastBar.Text:SetShadowOffset(C["Unitframe"].Outline and 0 or 1.25, C["Unitframe"].Outline and -0 or -1.25)
			CastBar.Text:SetPoint("LEFT", CastBar, "LEFT", 2, 0)
			CastBar.Text:SetPoint("RIGHT", CastBar.Time, "LEFT", -1, 0)
			CastBar.Text:SetHeight(C["Media"].FontSize)
			CastBar.Text:SetTextColor(1, 1, 1)
			CastBar.Text:SetJustifyH("LEFT")

			CastBar.Button = CreateFrame("Frame", nil, CastBar)
			CastBar.Button:SetSize(CastBar:GetHeight(), CastBar:GetHeight())
			CastBar.Button:SetPoint("RIGHT", CastBar, "LEFT", -8, 0)

			CastBar:SetTemplate("Transparent", true)
			CastBar.Button:SetTemplate("Transparent")

			CastBar.Icon = CastBar.Button:CreateTexture(nil, "ARTWORK")
			CastBar.Icon:SetAllPoints()
			CastBar.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

			CastBar.CustomDelayText = CustomCastDelayText
			CastBar.CustomTimeText = CustomTimeText
			CastBar.PostCastStart = PostCastStart
			CastBar.PostChannelStart = PostCastStart
			CastBar.PostCastStop = PostCastStop
			CastBar.PostChannelStop = PostCastStop
			CastBar.PostCastFailed = PostCastFailed
			CastBar.PostCastInterrupted = PostCastFailed
			CastBar.PostChannelUpdate = PostChannelUpdate
			CastBar.PostCastInterruptible = PostCastInterruptible
			CastBar.PostCastNotInterruptible = PostCastNotInterruptible

			CastBar.timeToHold = 0.4

			-- Set to castbar.Icon
			self.Castbar = CastBar
			self.Castbar.Icon = CastBar.Icon

			return self.Castbar
		end
	end
end