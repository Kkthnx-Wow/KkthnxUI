local K, C, L = select(2, ...):unpack()
if C.Auras.Enable ~= true then return end

-- Lua API
local next = next
local select = select
local unpack = unpack

-- Wow API
local GetInventoryItemTexture = GetInventoryItemTexture
local GetTime = GetTime
local GetWeaponEnchantInfo = GetWeaponEnchantInfo
local UnitAura = UnitAura

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: BuffFrame, TemporaryEnchantFrame, InterfaceOptionsFrameCategoriesButton12
-- GLOBALS: DebuffTypeColor

local KkthnxUIAuras = K.Auras

KkthnxUIAuras.Headers = {}
KkthnxUIAuras.FlashTimer = 30
KkthnxUIAuras.ProxyIcon = "Interface\\Icons\\misc_arrowdown"

function KkthnxUIAuras:DisableBlizzardAuras()
	BuffFrame:Kill()
	TemporaryEnchantFrame:Kill()
	InterfaceOptionsFrameCategoriesButton12:SetScale(0.00001)
	InterfaceOptionsFrameCategoriesButton12:SetAlpha(0)
end

function KkthnxUIAuras:StartOrStopFlash(timeleft)
	if(timeleft < KkthnxUIAuras.FlashTimer) then
		if(not self:IsPlaying()) then
			self:Play()
		end
	elseif(self:IsPlaying()) then
		self:Stop()
	end
end

function KkthnxUIAuras:OnUpdate(elapsed)
	local TimeLeft

	if(self.Enchant) then
		local Expiration = select(self.Enchant, GetWeaponEnchantInfo())

		if(Expiration) then
			TimeLeft = Expiration / 1e3
		else
			TimeLeft = 0
		end
	else
		TimeLeft = self.TimeLeft - elapsed
	end

	self.TimeLeft = TimeLeft

	if(TimeLeft <= 0) then
		self.TimeLeft = nil
		self.Duration:SetText("")

		if self.Enchant then
			self.Dur = nil
		end

		return self:SetScript("OnUpdate", nil)
	else
		local Text = K.FormatTime(TimeLeft)
		local r, g, b = K.ColorGradient(self.TimeLeft, self.Dur, 0.8, 0, 0, 0.8, 0.8, 0, 0, 0.8, 0)

		if(TimeLeft < 60.5) then
			if C.Auras.Flash then
				KkthnxUIAuras.StartOrStopFlash(self.Animation, TimeLeft)
			end

			if(TimeLeft < 5) then
				self.Duration:SetTextColor(255/255, 20/255, 20/255)
			else
				self.Duration:SetTextColor(255/255, 165/255, 0/255)
			end
		else
			if self.Animation and self.Animation:IsPlaying() then
				self.Animation:Stop()
			end

			self.Duration:SetTextColor(.9, .9, .9)
		end

		self.Duration:SetText(Text)
	end
end

function KkthnxUIAuras:UpdateAura(index)
	local Name, Rank, Texture, Count, DType, Duration, ExpirationTime, Caster, IsStealable, ShouldConsolidate, SpellID, CanApplyAura, IsBossDebuff = UnitAura(self:GetParent():GetAttribute("unit"), index, self.Filter)

	if (Name) then
		if (not C.Auras.Consolidate) then
			ShouldConsolidate = false
		end

		if (ShouldConsolidate) then
			self.Duration:Hide()
		end

		if (Duration > 0 and ExpirationTime and not ShouldConsolidate) then
			local TimeLeft = ExpirationTime - GetTime()
			if (not self.TimeLeft) then
				self.TimeLeft = TimeLeft
				self:SetScript("OnUpdate", KkthnxUIAuras.OnUpdate)
			else
				self.TimeLeft = TimeLeft
			end

			self.Dur = Duration

			if C.Auras.Flash then
				KkthnxUIAuras.StartOrStopFlash(self.Animation, TimeLeft)
			end
		else
			if C.Auras.Flash then
				self.Animation:Stop()
			end

			self.TimeLeft = nil
			self.Dur = nil
			self.Duration:SetText("")
			self:SetScript("OnUpdate", nil)
		end

		if (Count > 1) then
			self.Count:SetText(Count)
		else
			self.Count:SetText("")
		end

		if (self.Filter == "HARMFUL") then
			local Color = DebuffTypeColor[DType or "none"]
			self.border:SetBackdropBorderColor(Color.r * 3/5, Color.g * 3/5, Color.b * 3/5)
		end

		self.Icon:SetTexture(Texture)
	end
end

function KkthnxUIAuras:UpdateTempEnchant(slot)
	local Enchant = (slot == 16 and 2) or 6
	local Expiration = select(Enchant, GetWeaponEnchantInfo())
	local Icon = GetInventoryItemTexture("player", slot)

	if (Expiration) then
		if not self.Dur then
			self.Dur = Expiration / 1e3
		end

		self.Enchant = Enchant
		self:SetScript("OnUpdate", KkthnxUIAuras.OnUpdate)
	else
		self.Dur = nil
		self.Enchant = nil
		self.TimeLeft = nil
		self:SetScript("OnUpdate", nil)
	end

	-- Secure Aura Header Fix: sometime an empty temp enchant is show, which should not! Example, Shaman/Flametongue/Two-Handed
	if Icon then
		self:SetAlpha(1)
		self.Icon:SetTexture(Icon)
	else
		self:SetAlpha(0)
	end
end

function KkthnxUIAuras:OnAttributeChanged(attribute, value)
	if (attribute == "index") then
		return KkthnxUIAuras.UpdateAura(self, value)
	elseif(attribute == "target-slot") then
		return KkthnxUIAuras.UpdateTempEnchant(self, value)
	end
end

function KkthnxUIAuras:Skin()
	local Proxy = self.IsProxy
	local Font = C.Media.Font
	local FontSize = C.Media.Font_Size
	local FontStyle = C.Media.Font_Style

	local Icon = self:CreateTexture(nil, "BORDER")
	Icon:SetTexCoord(unpack(K.TexCoords))
	Icon:SetInside()

	local Count = self:CreateFontString(nil, "OVERLAY")
	Count:SetFont(Font, FontSize, FontStyle)
	Count:SetPoint("TOP", self, 1, -4)

	if (not Proxy) then
		local Duration = self:CreateFontString(nil, "OVERLAY")
		Duration:SetFont(Font, FontSize, FontStyle)
		Duration:SetPoint("BOTTOM", 0, -14)

		if C.Auras.Flash then
			local Animation = self:CreateAnimationGroup()
			Animation:SetLooping("BOUNCE")

			local FadeOut = Animation:CreateAnimation("Alpha")
			FadeOut:SetFromAlpha(1)
			FadeOut:SetToAlpha(0.5)
			FadeOut:SetDuration(0.6)
			FadeOut:SetSmoothing("IN_OUT")

			self.Animation = Animation
		end

		if (C.Auras.Animation and not self.AuraGrowth) then
			local AuraGrowth = self:CreateAnimationGroup()

			local Grow = AuraGrowth:CreateAnimation("Scale")
			Grow:SetOrder(1)
			Grow:SetDuration(0.2)
			Grow:SetScale(1.25, 1.25)

			local Shrink = AuraGrowth:CreateAnimation("Scale")
			Shrink:SetOrder(2)
			Shrink:SetDuration(0.2)
			Shrink:SetScale(0.75, 0.75)

			self.AuraGrowth = AuraGrowth

			self:SetScript("OnShow", function(self)
				if self.AuraGrowth then
					self.AuraGrowth:Play()
				end
			end)
		end

		self.Duration = Duration
		self.Filter = self:GetParent():GetAttribute("filter")

		self:SetScript("OnAttributeChanged", KkthnxUIAuras.OnAttributeChanged)
	else
		local x = self:GetWidth()
		local y = self:GetHeight()

		local Overlay = self:CreateTexture(nil, "OVERLAY")
		Overlay:SetTexture(KkthnxUIAuras.ProxyIcon)
		Overlay:SetInside()
		Overlay:SetTexCoord(unpack(K.TexCoords))

		self.Overlay = Overlay
	end

	self.Icon = Icon
	self.Count = Count
	--self:SetTemplate("Default")
	self:CreateBorder() -- has to be a better way to create the blizzard border with SetTemplate.

	if C.Blizzard.ColorTextures == true then
		self.border:SetBackdropBorderColor(unpack(C.Blizzard.TexturesColor))
	end

	if not self.shadow then
		self:CreateBlizzShadow(5)
	end
end

function KkthnxUIAuras:OnEnterWorld()
	for _, Header in next, KkthnxUIAuras.Headers do
		local Child = Header:GetAttribute("child1")
		local i = 1
		while(Child) do
			KkthnxUIAuras.UpdateAura(Child, Child:GetID())

			i = i + 1
			Child = Header:GetAttribute("child" .. i)
		end
	end
end

function KkthnxUIAuras:LoadVariables() -- to be completed
	local Headers = KkthnxUIAuras.Headers
	local Buffs = Headers[1]
	local Debuffs = Headers[2]
	local Position = Buffs:GetPoint()

	if Position:match("LEFT") then
		Buffs:SetAttribute("xOffset", 35)
		Buffs:SetAttribute("point", Position)
		Debuffs:SetAttribute("xOffset", 35)
		Debuffs:SetAttribute("point", Position)
	end
end
