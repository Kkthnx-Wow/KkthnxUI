local K, C, L = unpack(select(2, ...))
if C["Unitframe"].Enable ~= true then return end

local function CreateAuraTimer(self, elapsed)
	if (self.TimeLeft) then
		self.Elapsed = (self.Elapsed or 0) + elapsed

		if self.Elapsed >= 0.1 then
			if not self.First then
				self.TimeLeft = self.TimeLeft - self.Elapsed
			else
				self.TimeLeft = self.TimeLeft - GetTime()
				self.First = false
			end

			if self.TimeLeft > 0 then
				local Time = K.FormatTime(self.TimeLeft)
				self.Remaining:SetText(Time)

				if self.TimeLeft <= 5 then
					self.Remaining:SetTextColor(1, 0, 0)
				else
					self.Remaining:SetTextColor(255/255, 210/255, 0/255)
				end
			else
				self.Remaining:Hide()
				self:SetScript("OnUpdate", nil)
			end

			self.Elapsed = 0
		end
	end
end

local function PostCreateAura(self, button)
	button:SetTemplate("Transparent", true)

	button.Remaining = button:CreateFontString(nil, "OVERLAY")
	button.Remaining:SetFont(C["Media"].Font, self.size * 0.46, "OUTLINE")
	button.Remaining:SetPoint("TOP", 1, -1)

	button.cd.noOCC = true
	button.cd.noCooldownCount = true
	button.cd:SetReverse()
	button.cd:SetFrameLevel(button:GetFrameLevel() + 1)
	button.cd:ClearAllPoints()
	button.cd:SetInside(button, 1, 1)
	button.cd:SetHideCountdownNumbers(true)

	button.icon:SetAllPoints()
	button.icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	button.icon:SetDrawLayer("ARTWORK")

	button.count:SetPoint("BOTTOMRIGHT", 3, 0)
	button.count:SetJustifyH("RIGHT")
	button.count:SetFont(C["Media"].Font, self.size * 0.46, "OUTLINE")
	button.count:SetTextColor(1, 1, 1)

	button.OverlayFrame = CreateFrame("Frame", nil, button, nil)
	button.OverlayFrame:SetFrameLevel(button.cd:GetFrameLevel() + 1)
	button.overlay:SetParent(button.OverlayFrame)
	button.count:SetParent(button.OverlayFrame)
	button.Remaining:SetParent(button.OverlayFrame)

	button.Animation = button:CreateAnimationGroup()
	button.Animation:SetLooping("BOUNCE")

	button.Animation.FadeOut = button.Animation:CreateAnimation("Alpha")
	button.Animation.FadeOut:SetFromAlpha(1)
	button.Animation.FadeOut:SetToAlpha(0)
	button.Animation.FadeOut:SetDuration(.6)
	button.Animation.FadeOut:SetSmoothing("IN_OUT")
end

local function SortAuras(a, b)
	if (a:IsShown() and b:IsShown()) then
		if (a.isDebuff == b.isDebuff) then
			return a.TimeLeft > b.TimeLeft
		elseif (not a.isDebuff) then
			return b.isDebuff
		end
	elseif (a:IsShown()) then
		return true
	end
end

local function PreSetPosition(self)
	table.sort(self, SortAuras)
	return 1, self.createdIcons
end

local function PostUpdateAura(self, unit, button, index, offset, filter, isDebuff, duration, timeLeft)
	local _, _, _, _, DType, Duration, ExpirationTime, UnitCaster, IsStealable = UnitAura(unit, index, button.filter)

	if button then
		if (button.filter == "HARMFUL") then
			if (not UnitIsFriend("player", unit) and button.caster ~= "player" and button.caster ~= "vehicle") then
				button.icon:SetDesaturated(true)
				button:SetBackdropBorderColor(unpack(C["Media"].BorderColor))
			else
				local color = DebuffTypeColor[DType] or DebuffTypeColor.none
				button.icon:SetDesaturated(false)
				button:SetBackdropBorderColor(color.r * 0.8, color.g * 0.8, color.b * 0.8)
			end
		else
			if (IsStealable or DType == "Magic") and not UnitIsFriend("player", unit) and not button.Animation.Playing then
				button.Animation:Play()
				button.Animation.Playing = true
			else
				button.Animation:Stop()
				button.Animation.Playing = false
			end
		end

		if Duration and Duration > 0 then
			button.Remaining:Show()
		else
			button.Remaining:Hide()
		end

		button.Duration = Duration
		button.TimeLeft = ExpirationTime
		button.First = true
		button:SetScript("OnUpdate", CreateAuraTimer)
	end
end

-- We will handle these individually so we can have the up most control of our auras on each unit/frame
function K.CreateAuras(self, unit)
	unit = unit:match("^(.-)%d+") or unit

	if (unit == "target") then
		local Buffs = CreateFrame("Frame", self:GetName().."Buffs", self)
		local Debuffs = CreateFrame("Frame", self:GetName().."Debuffs", self)

		Buffs:SetHeight(21)
		Buffs:SetWidth(130)
		Buffs:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -6)
		Buffs.size = 21
		Buffs.num = 15

		Debuffs:SetHeight(28)
		Debuffs:SetWidth(130)
		Debuffs:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 0, 26)
		Debuffs.size = 28
		Debuffs.num = 12

		Buffs.spacing = 6
		Buffs.initialAnchor = "TOPLEFT"
		Buffs["growth-y"] = "DOWN"
		Buffs["growth-x"] = "RIGHT"
		Buffs.PreSetPosition = PreSetPosition
		Buffs.CustomFilter = K.DefaultAuraFilter
		Buffs.PostCreateIcon = PostCreateAura
		Buffs.PostUpdateIcon = PostUpdateAura
		self.Buffs = Buffs

		Debuffs.spacing = 6
		Debuffs.initialAnchor = "TOPLEFT"
		Debuffs["growth-y"] = "UP"
		Debuffs["growth-x"] = "RIGHT"
		Debuffs.PreSetPosition = PreSetPosition
		Debuffs.CustomFilter = K.DefaultAuraFilter
		Debuffs.PostCreateIcon = PostCreateAura
		Debuffs.PostUpdateIcon = PostUpdateAura
		self.Debuffs = Debuffs

		K.Movers:RegisterFrame(Buffs) -- Still thinking about this. :D
		K.Movers:RegisterFrame(Debuffs) -- Still thinking about this. :D
	end

	-- Party.
	if (unit == "party") then
		local Buffs = CreateFrame("Frame", self:GetName().."Buffs", self)
		local Debuffs = CreateFrame("Frame", self:GetName().."Debuffs", self)

		Buffs:SetHeight(19)
		Buffs:SetWidth(self:GetWidth())
		Buffs:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -6)
		Buffs.size = 19
		Buffs.num = 4

		Debuffs:SetHeight(30)
		Debuffs:SetWidth(self.Power:GetWidth())
		Debuffs:SetPoint("LEFT", self, "RIGHT", 3, 0)
		Debuffs.size = 30
		Debuffs.num = 4

		Buffs.spacing = 6
		Buffs.initialAnchor = "TOPLEFT"
		Buffs["growth-y"] = "DOWN"
		Buffs["growth-x"] = "RIGHT"
		Buffs.PreSetPosition = PreSetPosition
		Buffs.CustomFilter = K.DefaultAuraFilter
		Buffs.PostCreateIcon = PostCreateAura
		Buffs.PostUpdateIcon = PostUpdateAura
		self.Buffs = Buffs

		Debuffs.spacing = 6
		Debuffs.initialAnchor = "TOPLEFT"
		Debuffs["growth-y"] = "UP"
		Debuffs["growth-x"] = "RIGHT"
		Debuffs.PreSetPosition = PreSetPosition
		Debuffs.CustomFilter = K.DefaultAuraFilter
		Debuffs.PostCreateIcon = PostCreateAura
		Debuffs.PostUpdateIcon = PostUpdateAura
		self.Debuffs = Debuffs
	end

	if (unit == "targettarget") then
		local Debuffs = CreateFrame("Frame", self:GetName().."Debuffs", self)

		Debuffs:SetHeight(self.Portrait:GetHeight())
		Debuffs:SetWidth(84)
		Debuffs:SetPoint("LEFT", self.Portrait, "RIGHT", 7, 0)
		Debuffs.size = 24
		Debuffs.num = 3

		Debuffs.spacing = 6
		Debuffs.initialAnchor = "LEFT"
		Debuffs["growth-y"] = "DOWN"
		Debuffs["growth-x"] = "RIGHT"
		Debuffs.PreSetPosition = PreSetPosition
		Debuffs.PostCreateIcon = PostCreateAura
		Debuffs.PostUpdateIcon = PostUpdateAura
		self.Debuffs = Debuffs
	end

	if (unit == "pet") then
		local Debuffs = CreateFrame("Frame", self:GetName().."Debuffs", self)

		Debuffs:SetHeight(14)
		Debuffs:SetWidth(60)
		Debuffs:SetPoint("TOPLEFT", self.Portrait, "TOPLEFT", -20, 0)
		Debuffs.size = 14
		Debuffs.num = 6

		Debuffs.spacing = 6
		Debuffs.initialAnchor = "TOPLEFT"
		Debuffs["growth-y"] = "DOWN"
		Debuffs["growth-x"] = "LEFT"
		Debuffs.PreSetPosition = PreSetPosition
		Debuffs.PostCreateIcon = PostCreateAura
		Debuffs.PostUpdateIcon = PostUpdateAura
		self.Debuffs = Debuffs
	end

	-- Boss.
	if (unit == "boss") then
		local Buffs = CreateFrame("Frame", self:GetName().."Buffs", self)
		local Debuffs = CreateFrame("Frame", self:GetName().."Debuffs", self)

		Buffs:SetHeight(20)
		Buffs:SetWidth(120)
		Buffs:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -6)
		Buffs.size = 20
		Buffs.num = 16

		Debuffs:SetHeight(22)
		Debuffs:SetWidth(120)
		Debuffs:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", -2, 26)
		Debuffs.size = 22
		Debuffs.num = 12

		Buffs.spacing = 6
		Buffs.initialAnchor = "TOPLEFT"
		Buffs["growth-y"] = "DOWN"
		Buffs["growth-x"] = "RIGHT"
		Buffs.PreSetPosition = PreSetPosition
		Buffs.CustomFilter = K.BossAuraFilter
		Buffs.PostCreateIcon = PostCreateAura
		Buffs.PostUpdateIcon = PostUpdateAura
		self.Buffs = Buffs

		Debuffs.spacing = 6
		Debuffs.initialAnchor = "TOPLEFT"
		Debuffs["growth-y"] = "UP"
		Debuffs["growth-x"] = "RIGHT"
		Debuffs.PreSetPosition = PreSetPosition
		Debuffs.CustomFilter = K.BossAuraFilter
		Debuffs.PostCreateIcon = PostCreateAura
		Debuffs.PostUpdateIcon = PostUpdateAura
		self.Debuffs = Debuffs
	end

	if (unit == "arena") then
		-- local Debuffs = CreateFrame("Frame", self:GetName().."Debuffs", self)

		-- Debuffs:SetHeight(22)
		-- Debuffs:SetWidth(120)
		-- Debuffs:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", -2, 26)
		-- Debuffs.size = 22
		-- Debuffs.num = 12

		-- Debuffs.spacing = 6
		-- Debuffs.initialAnchor = "TOPLEFT"
		-- Debuffs["growth-y"] = "UP"
		-- Debuffs["growth-x"] = "RIGHT"
		-- Debuffs.PostCreateIcon = PostCreateAura
		-- Debuffs.PostUpdateIcon = PostUpdateAura
		-- self.Debuffs = Debuffs
	end
end