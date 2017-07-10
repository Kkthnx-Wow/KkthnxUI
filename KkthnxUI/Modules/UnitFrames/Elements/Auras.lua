local K, C, L = unpack(select(2, ...))
if C.Unitframe.Enable ~= true then return end

-- Lua API
local _G = _G

-- Wow API
local UnitIsFriend = _G.UnitIsFriend
local CreateFrame = _G.CreateFrame
local GetTime = _G.GetTime
local UnitAura = _G.UnitAura

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: DebuffTypeColor

local function CreateAuraTimer(self, elapsed)
	if self.timeLeft then
		self.elapsed = (self.elapsed or 0) + elapsed
		if self.elapsed >= 0.1 then
			if not self.first then
				self.timeLeft = self.timeLeft - self.elapsed
			else
				self.timeLeft = self.timeLeft - GetTime()
				self.first = false
			end
			if self.timeLeft > 0 then
				local time = K.FormatTime(self.timeLeft)
				self.remaining:SetText(time)
				self.remaining:SetTextColor(1, 1, 1)
			else
				self.remaining:Hide()
				self:SetScript("OnUpdate", nil)
			end
			self.elapsed = 0
		end
	end
end

function K.PostCreateAura(self, button)
	K.CreateBorder(button)

	button.remaining = K.SetFontString(button, C.Media.Font, 10, "THINOUTLINE")
	button.remaining:SetShadowOffset(0, 0)
	button.remaining:SetPoint("TOPLEFT", 0, -3)

	button.cd.noOCC = true
	button.cd.noCooldownCount = true

	button.cd:SetReverse()
	button.icon:SetAllPoints()
	button.icon:SetTexCoord(.08, .92, .08, .92)
	button.icon:SetDrawLayer("ARTWORK")

	button.count:SetPoint("BOTTOMRIGHT", 1, 1)
	button.count:SetJustifyH("RIGHT")
	button.count:SetFont(C.Media.Font, 9, "THINOUTLINE")
	button.count:SetShadowOffset(0, 0)

	button.overlayFrame = CreateFrame("frame", nil, button, nil)
	button.cd:SetFrameLevel(button:GetFrameLevel() + 1)
	button.cd:ClearAllPoints()
	button.cd:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
	button.cd:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
	button.overlayFrame:SetFrameLevel(button.cd:GetFrameLevel() + 1)
	button.overlay:SetParent(button.overlayFrame)
	button.count:SetParent(button.overlayFrame)
	button.remaining:SetParent(button.overlayFrame)

	button.Animation = button:CreateAnimationGroup()
	button.Animation:SetLooping("BOUNCE")

	button.Animation.FadeOut = button.Animation:CreateAnimation("Alpha")
	button.Animation.FadeOut:SetFromAlpha(1)
	button.Animation.FadeOut:SetToAlpha(0)
	button.Animation.FadeOut:SetDuration(.6)
	button.Animation.FadeOut:SetSmoothing("IN_OUT")
end

function K.PostUpdateAura(self, unit, icon, index, offset, filter, isDebuff, duration, timeLeft)
	local _, _, _, _, dtype, duration, expirationTime, unitCaster, isStealable = UnitAura(unit, index, icon.filter)
	if icon then
		if icon.filter == "HARMFUL" then
			if not UnitIsFriend("player", unit) and icon.owner ~= "player" and icon.owner ~= "vehicle" then
				icon.icon:SetDesaturated(true)
				icon:SetBackdropBorderColor(1, 1, 1)
			else
				local color = DebuffTypeColor[dtype] or DebuffTypeColor.none
				icon.icon:SetDesaturated(false)
				icon:SetBackdropBorderColor(color.r, color.g, color.b)
			end
		else
			if isStealable or ((K.Class == "MAGE" or K.Class == "PRIEST" or K.Class == "SHAMAN") and dtype == "Magic") and not UnitIsFriend("player", unit) then
				if not icon.Animation:IsPlaying() then icon.Animation:Play() end
			else
				if icon.Animation:IsPlaying() then icon.Animation:Stop() end
			end
		end

		if duration and duration > 0 then
			if duration > 300 then
			icon.remaining:Hide()
			icon.cd:Hide()
		else
			icon.remaining:Show()
			icon.cd:Show()
		end
	end

		icon.duration = duration
		icon.timeLeft = expirationTime
		icon.first = true
		icon:SetScript("OnUpdate", CreateAuraTimer)
	end
end

-- We will handle these individually so we can have the up most control of our auras on each unit/frame
function K.CreateAuras(self, unit)
	-- Player - Debuffs only.
	if (self.MatchUnit == "player") then
		-- local buffs = CreateFrame("Frame", "$parentBuffs", self.Health)
		-- local debuffs = CreateFrame("Frame", "$parentDeBuffs", self.Health)

		-- buffs:SetHeight(22)
		-- buffs:SetWidth(self.Health:GetWidth() -6)
		-- buffs:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", -2, -8)
		-- buffs.size = 22
		-- buffs.num = 4

		-- debuffs:SetHeight(26)
		-- debuffs:SetWidth(self.Health:GetWidth() -4)
		-- debuffs:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", -6, 12)
		-- debuffs.size = 26
		-- debuffs.num = 4

		-- buffs.spacing = 5
		-- buffs.initialAnchor = "TOPLEFT"
		-- buffs["growth-y"] = "DOWN"
		-- buffs["growth-x"] = "RIGHT"
		-- buffs.CustomFilter = K.PlayerAuraFilter
		-- buffs.PostCreateIcon = K.PostCreateAura
		-- buffs.PostUpdateIcon = K.PostUpdateAura
		-- self.Buffs = buffs

		-- debuffs.spacing = 5
		-- debuffs.initialAnchor = "TOPLEFT"
		-- debuffs["growth-y"] = "UP"
		-- debuffs["growth-x"] = "RIGHT"
		-- debuffs.CustomFilter = K.PlayerAuraFilter
		-- debuffs.PostCreateIcon = K.PostCreateAura
		-- debuffs.PostUpdateIcon = K.PostUpdateAura
		-- self.Debuffs = debuffs

	-- Target and Focus.
elseif (self.MatchUnit == "focus") or (self.MatchUnit == "target") then
		local buffs = CreateFrame("Frame", "$parentBuffs", self.Health)
		local debuffs = CreateFrame("Frame", "$parentDeBuffs", self.Health)

		buffs:SetHeight(20)
		buffs:SetWidth(self.Health:GetWidth() -6)
		buffs:SetPoint("TOPLEFT", self, "BOTTOMLEFT", -2, -8)
		buffs.size = 20
		buffs.num = 16

		debuffs:SetHeight(22)
		debuffs:SetWidth(self.Health:GetWidth() -4)
		debuffs:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", -2, 26)
		debuffs.size = 22
		debuffs.num = 12

		buffs.spacing = 5
		buffs.initialAnchor = "TOPLEFT"
		buffs["growth-y"] = "DOWN"
		buffs["growth-x"] = "RIGHT"
		buffs.CustomFilter = K.DefaultAuraFilter
		buffs.PostCreateIcon = K.PostCreateAura
		buffs.PostUpdateIcon = K.PostUpdateAura
		self.Buffs = buffs

		debuffs.spacing = 5
		debuffs.initialAnchor = "TOPLEFT"
		debuffs["growth-y"] = "UP"
		debuffs["growth-x"] = "RIGHT"
		debuffs.CustomFilter = K.DefaultAuraFilter
		debuffs.PostCreateIcon = K.PostCreateAura
		debuffs.PostUpdateIcon = K.PostUpdateAura
		self.Debuffs = debuffs

		-- Party.
	elseif (self.IsPartyFrame) then
		local buffs = CreateFrame("Frame", nil, self)
		local debuffs = CreateFrame("Frame", nil, self)

		buffs:SetHeight(18)
		buffs:SetWidth(self:GetWidth())
		buffs:SetPoint("TOPLEFT", self.Health, "BOTTOMLEFT", 2, -12)
		buffs.size = 18
		buffs.num = 4

		debuffs:SetHeight(20)
		debuffs:SetWidth(self:GetWidth())
		debuffs:SetPoint("TOPLEFT", self.Health, "TOPRIGHT", 7, 1)
		debuffs.size = 20
		debuffs.num = 4

		buffs.spacing = 5
		buffs.initialAnchor = "TOPLEFT"
		buffs["growth-y"] = "DOWN"
		buffs["growth-x"] = "RIGHT"
		buffs.CustomFilter = K.DefaultAuraFilter
		buffs.PostCreateIcon = K.PostCreateAura
		buffs.PostUpdateIcon = K.PostUpdateAura
		self.Buffs = buffs

		debuffs.spacing = 5
		debuffs.initialAnchor = "TOPLEFT"
		debuffs["growth-y"] = "UP"
		debuffs["growth-x"] = "RIGHT"
		debuffs.CustomFilter = K.DefaultAuraFilter
		debuffs.PostCreateIcon = K.PostCreateAura
		debuffs.PostUpdateIcon = K.PostUpdateAura
		self.Debuffs = debuffs

		-- Boss.
	elseif (self.MatchUnit == "boss") then
		local buffs = CreateFrame("Frame", nil, self)
		local debuffs = CreateFrame("Frame", nil, self)

		buffs:SetHeight(20)
		buffs:SetWidth(self:GetWidth())
		buffs:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 2, -6)
		buffs.size = 26
		buffs.num = 4

		debuffs:SetHeight(24)
		debuffs:SetWidth(self:GetWidth())
		debuffs:SetPoint("TOPRIGHT", self, "BOTTOMLEFT", -5, 18)
		debuffs.size = 24
		debuffs.num = 4

		buffs.spacing = 5
		buffs.initialAnchor = "TOPLEFT"
		buffs["growth-y"] = "DOWN"
		buffs["growth-x"] = "RIGHT"
		buffs.CustomFilter = K.BossAuraFilter
		buffs.PostCreateIcon = K.PostCreateAura
		buffs.PostUpdateIcon = K.PostUpdateAura
		self.Buffs = buffs

		debuffs.spacing = 5
		debuffs.initialAnchor = "TOPRIGHT"
		debuffs["growth-y"] = "DOWN"
		debuffs["growth-x"] = "LEFT"
		debuffs.CustomFilter = K.BossAuraFilter
		debuffs.PostCreateIcon = K.PostCreateAura
		debuffs.PostUpdateIcon = K.PostUpdateAura
		self.Debuffs = debuffs

	elseif (self.MatchUnit == "arena") then -- This is already finished on the 7.0.0 alpha. We will merge this later.
		-- local buffs = CreateFrame("Frame", nil, self)
		-- local debuffs = CreateFrame("Frame", nil, self)

		-- buffs:SetHeight(26)
		-- buffs:SetWidth(self:GetWidth())
		-- buffs:SetPoint("TOPLEFT", self.Power, "BOTTOMLEFT", 0, -7)
		-- buffs.size = 26
		-- buffs.num = 6

		-- debuffs:SetHeight(24)
		-- debuffs:SetWidth(self:GetWidth())
		-- debuffs:SetPoint("TOPRIGHT", self, "BOTTOMLEFT", -34, 18)
		-- debuffs.size = 24
		-- debuffs.num = 4

		-- buffs.spacing = 5
		-- buffs.initialAnchor = "TOPLEFT"
		-- buffs["growth-y"] = "DOWN"
		-- buffs["growth-x"] = "RIGHT"
		-- buffs.CustomFilter = K.ArenaAuraFilter
		-- buffs.PostCreateIcon = K.PostCreateAura
		-- buffs.PostUpdateIcon = K.PostUpdateAura
		-- self.Buffs = buffs

		-- debuffs.spacing = 5
		-- debuffs.initialAnchor = "TOPRIGHT"
		-- debuffs["growth-y"] = "UP"
		-- debuffs["growth-x"] = "RIGHT"
		-- debuffs.PostCreateIcon = K.PostCreateAura
		-- debuffs.PostUpdateIcon = K.PostUpdateAura
		-- debuffs.CustomFilter = K.CustomAuraFilters.Boss
		-- debuffs.onlyShowPlayer = true
		-- self.Debuffs = debuffs
	end
end