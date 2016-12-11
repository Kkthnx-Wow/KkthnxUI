local K, C, L = unpack(select(2, ...))
if C.Unitframe.Enable ~= true then return end

local _, ns = ...
local oUF = ns.oUF or oUF
local colors = K.Colors

-- Custom castbar element
-- Pretty much my own raped version of the oUF castbar element with fading and support for a flash textures.
--[[
Sub-Widgets

.Text - A FontString to represent spell name.
.Icon - A Texture to represent spell icon.
.Time - A FontString to represent spell duration.
.Shield - A Texture to represent if it"s NOT possible to interrupt.
.SafeZone - A Texture to represent latency.
.Spark - A Texture to represent the castbar spark.
.Flash - A Texture or Frame to flash when a cast is finished

Credits

Haste for oUF castbar element and Blizzard

Hooks and callbacks

CCastbar.PostCastStart(unit, name, castid)
CCastbar.PostCastFailed(unit, spellname, castid)
CCastbar.PostCastStop(unit, spellname, castid)
CCastbar.PostCastInterrupted(unit, spellname, castid)
CCastbar.PostCastInterruptible(unit)
CCastbar.PostCastNotInterruptible(unit)
CCastbar.PostCastDelayed(unit, name, castid)
CCastbar.PostChannelStart(unit, name)
CCastbar.PostChannelUpdate(unit, name)
CCastbar.PostChannelStop(unit, spellname)

CCastbar.CustomDelayText(duration)
CCastbar.CustomTimeText(duration)
]]

_G.CASTING_BAR_ALPHA_STEP = 0.05
_G.CASTING_BAR_FLASH_STEP = 0.05
_G.CASTING_BAR_FLASH_STEPOUT = 0.05
_G.CASTING_BAR_HOLD_TIME = 0.7

local UnitName = UnitName
local GetTime = GetTime
local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo

local updateSafeZone = function(self)
	local sz = self.SafeZone
	local width = self:GetWidth()
	local _, _, _, ms = GetNetStats()

	-- Guard against GetNetStats returning latencies of 0.
	if(ms ~= 0) then
		-- MADNESS!
		local safeZonePercent = (width / self.max) * (ms / 1e5)
		if(safeZonePercent > 1) then safeZonePercent = 1 end
		sz:SetWidth(width * safeZonePercent)
		sz:Show()
	else
		sz:Hide()
	end
end

local UNIT_SPELLCAST_START = function(self, event, unit, spell)
	if(self.unit ~= unit) then return end

	local castbar = self.CCastbar
	local name, _, text, texture, startTime, endTime, _, castid, notInterruptible = UnitCastingInfo(unit)
	if (not name or not castbar.enableCastbar) then
		castbar:Hide()
		return
	end

	castbar.duration = GetTime() - (startTime/1000)
	castbar.max = (endTime - startTime) / 1000
	castbar:SetMinMaxValues(0, castbar.max)
	castbar:SetValue(castbar.duration)

	castbar.interrupt = notInterruptible
	castbar.castid = castid

	castbar.casting = 1
	castbar.delay = 0
	castbar.holdTime = 0
	castbar.fadeOut = nil
	castbar.channeling = nil

	if (castbar.Text) then castbar.Text:SetText(text) end
	if (castbar.Icon) then castbar.Icon:SetTexture(texture) end
	if (castbar.Time) then castbar.Time:SetText() end
	if (castbar.Spark)then castbar.Spark:Show() end

	local shield = castbar.Shield
	if (shield and notInterruptible) then
		shield:Show()
	elseif (shield) then
		shield:Hide()
	end
	local sf = castbar.SafeZone
	if (sf) then
		sf:ClearAllPoints()
		sf:SetPoint("RIGHT")
		sf:SetPoint("TOP")
		sf:SetPoint("BOTTOM")
		updateSafeZone(castbar)
	end

	castbar:SetAlpha(1.0)
	castbar:Show()
	if(castbar.PostCastStart) then
		castbar:PostCastStart(unit, name, castid)
	end
end

local UNIT_SPELLCAST_FAILED = function(self, event, unit, spellname, _, castid)
	if (self.unit ~= unit) then return end
	local castbar = self.CCastbar
	if (castbar.castid ~= castid) then return end

	if (castbar.Flash) then castbar.Flash:Hide() end
	if (castbar.Spark) then castbar.Spark:Hide() end

	castbar.flash = nil
	castbar.casting = nil
	castbar.interrupt = nil
	castbar.fadeOut = 1

	castbar.holdTime = GetTime() + CASTING_BAR_HOLD_TIME

	if (castbar.PostCastFailed) then
		return castbar:PostCastFailed(unit, spellname, castid)
	end
end

local UNIT_SPELLCAST_INTERRUPTED = function(self, event, unit, spellname, _, castid)
	if (self.unit ~= unit) then return end
	local castbar = self.CCastbar

	if (castbar.castid ~= castid) and (castbar.fadeOut) then return end
	if (castbar.Spark) then castbar.Spark:Hide() end

	castbar.casting = nil
	castbar.channeling = nil
	castbar.fadeOut = 1
	castbar.holdTime = GetTime() + CASTING_BAR_HOLD_TIME

	if (castbar.PostCastInterrupted) then
		return castbar:PostCastInterrupted(unit, spellname, castid)
	end
end

local UNIT_SPELLCAST_INTERRUPTIBLE = function(self, event, unit)
	if (self.unit ~= unit) then return end
	local castbar = self.CCastbar

	if (castbar.Shield) then castbar.Shield:Hide() end
	castbar.interrupt = nil

	if (castbar.PostCastInterruptible) then
		return castbar:PostCastInterruptible(unit)
	end
end

local UNIT_SPELLCAST_NOT_INTERRUPTIBLE = function(self, event, unit)
	if(self.unit ~= unit) then return end

	local castbar = self.CCastbar
	if(castbar.Shield) then castbar.Shield:Show() end
	castbar.interrupt = 1

	if(castbar.PostCastNotInterruptible) then
		return castbar:PostCastNotInterruptible(unit)
	end
end

local UNIT_SPELLCAST_DELAYED = function(self, event, unit, spellname, _, castid)
	if (self.unit ~= unit) then return end
	local castbar = self.CCastbar

	local name, _, text, texture, startTime, endTime = UnitCastingInfo(unit)
	if(not startTime or not castbar:IsShown()) then return end

	local duration = GetTime() - (startTime / 1000)
	if(duration < 0) then duration = 0 end

	castbar.delay = castbar.delay + castbar.duration - duration
	castbar.duration = duration
	castbar:SetValue(duration)

	if (not castbar.casting) then
		if (castbar.Spark) then
			castbar.Spark:Show()
		end
		if (castbar.Flash) then
			castbar.Flash:SetAlpha(0.0)
			castbar.Flash:Hide()
		end
		castbar.casting = 1
		castbar.channeling = nil
		castbar.flash = nil
		castbar.fadeOut = 0
	end

	if(castbar.PostCastDelayed) then
		return castbar:PostCastDelayed(unit, name, castid)
	end
end

local UNIT_SPELLCAST_STOP = function(self, event, unit, spellname, _, castid)
	if(self.unit ~= unit) then return end

	local castbar = self.CCastbar
	if(castbar.castid == castid and castbar.casting and (not castbar.fadeOut)) then
		if (castbar.Flash) then
			castbar.Flash:SetAlpha(0.0)
			castbar.Flash:Show()
		end

		if (castbar.Spark) then
			castbar.Spark:Hide()
		end

		castbar.holdTime = 0
		castbar.flash = true
		castbar.fadeOut = 1
		castbar.casting = nil
		castbar.channeling = nil
		castbar.interrupt = nil

		castbar:SetValue(castbar.max)
		if(castbar.PostCastStop) then
			return castbar:PostCastStop(unit, spellname, castid)
		end
	end
end

local UNIT_SPELLCAST_CHANNEL_STOP = function(self, event, unit, spellname)
	if(self.unit ~= unit) then return end
	local castbar = self.CCastbar

	if (castbar:IsShown() or castbar.channeling) then
		if (castbar.Spark) then
			castbar.Spark:Hide()
		end
		if (castbar.Flash) then
			castbar.Flash:SetAlpha(0.0)
			castbar.Flash:Show()
		end

		castbar.channeling = nil
		castbar.interrupt = nil
		castbar.flash = true
		castbar.fadeOut = 1
		castbar.holdTime = 0

		if(castbar.PostChannelStop) then
			return castbar:PostChannelStop(unit, spellname)
		end
	end
end

local UNIT_SPELLCAST_CHANNEL_START = function(self, event, unit, spellname)
	if(self.unit ~= unit) then return end

	local castbar = self.CCastbar
	local name, _, text, texture, startTime, endTime, isTrade, interrupt = UnitChannelInfo(unit)
	if (not name or not castbar.enableCastbar) then
		return
	end

	castbar.duration = (endTime/1000) - GetTime()
	castbar.max = (endTime - startTime) / 1000
	castbar:SetMinMaxValues(0, castbar.max)
	castbar:SetValue(castbar.duration)

	castbar.interrupt = interrupt
	castbar.delay = 0

	castbar.castid = nil
	castbar.casting = nil

	castbar.holdTime = 0
	castbar.channeling = 1
	castbar.fadeOut = nil

	if (castbar.Text) then castbar.Text:SetText(name) end
	if (castbar.Icon) then castbar.Icon:SetTexture(texture) end
	if (castbar.Time) then castbar.Time:SetText() end
	if (castbar.Spark)then castbar.Spark:Show() end

	local shield = castbar.Shield
	if(shield and interrupt) then
		shield:Show()
	elseif (shield) then
		shield:Hide()
	end

	local sf = castbar.SafeZone
	if(sf) then
		sf:ClearAllPoints()
		sf:SetPoint("LEFT")
		sf:SetPoint("TOP")
		sf:SetPoint("BOTTOM")
		updateSafeZone(castbar)
	end

	castbar:SetAlpha(1.0)
	castbar:Show()
	if(castbar.PostChannelStart) then castbar:PostChannelStart(unit, name) end
end

local UNIT_SPELLCAST_CHANNEL_UPDATE = function(self, event, unit, spellname)
	if(self.unit ~= unit) then return end
	local castbar = self.CCastbar

	local name, _, text, texture, startTime, endTime, oldStart = UnitChannelInfo(unit)
	if(not name or not castbar:IsShown()) then
		return
	end

	local duration = (endTime / 1000) - GetTime()

	castbar.delay = castbar.delay + castbar.duration - duration
	castbar.duration = duration
	castbar.max = (endTime - startTime) / 1000

	castbar:SetMinMaxValues(0, castbar.max)
	castbar:SetValue(duration)

	if(castbar.PostChannelUpdate) then
		return castbar:PostChannelUpdate(unit, name)
	end
end

local UNIT_PET = function(self, event, unit)
	local castbar = self.CCastbar

	if unit == "player" then
		castbar.enableCastbar = UnitIsPossessed("pet")
		if ( not castbar.enableCastbar ) then
			castbar:Hide()
		elseif ( castbar.casting or castbar.channeling ) then
			castbar:Show()
		end
	end
end

local function flashOut(element)
	local alpha = element:GetAlpha() - CASTING_BAR_FLASH_STEPOUT
	if (alpha > 0.05) then
		element:SetAlpha(alpha)
	else
		element:SetAlpha(0.0)
		return true
	end
end

local function flashIn(element)
	local alpha = element:GetAlpha() + CASTING_BAR_FLASH_STEP
	if (alpha < 0.95) then
		element:SetAlpha(alpha)
	else
		element:SetAlpha(1.0)
		return true
	end
end

local onUpdate = function(self, elapsed)
	local barSpark = self.Spark
	local barFlash = self.Flash

	if(self.casting) then
		local duration = self.duration + elapsed
		if(duration > self.max) then
			self:SetValue(self.max)
			if (barSpark) then
				barSpark:Hide()
			end
			if (barFlash) then
				barFlash:SetAlpha(0.0)
				barFlash:Show()
			end

			self.holdTime = 0
			self.flash = true
			self.fadeOut = 1
			self.casting = nil
			self.channeling = nil
			self.interrupt = nil

			if(self.PostCastStop) then self:PostCastStop(self.__owner.unit) end
			return
		end

		if(self.Time) then
			if(self.delay ~= 0) then
				if(self.CustomDelayText) then
					self:CustomDelayText(duration)
				else
					self.Time:SetFormattedText("%.1f|cffff0000-%.1f|r", self.max - duration, self.delay)
				end
			else
				if(self.CustomTimeText) then
					self:CustomTimeText(duration)
				else
					self.Time:SetFormattedText("%.1f", self.max - duration)
				end
			end
		end

		self.duration = duration
		self:SetValue(duration)

		if (barFlash) then
			if self.flash then
				if flashOut(barFlash) then
					self.flash = nil
				end
			else
				barFlash:Hide()
			end
		end

		if(barSpark) then
			barSpark:SetPoint("CENTER", self, "LEFT", (duration / self.max) * self:GetWidth(), 0)
		end
	elseif(self.channeling) then
		local duration = self.duration - elapsed

		if(duration <= 0) then
			if (self.Spark) then
				self.Spark:Hide()
			end
			if (self.Flash) then
				self.Flash:SetAlpha(0.0)
				self.Flash:Show()
			end

			self.flash = true
			self.fadeOut = 1
			self.casting = nil
			self.channeling = nil
			self.interrupt = nil
			self.holdTime = 0

			if(self.PostChannelStop) then self:PostChannelStop(self.__owner.unit) end
			return
		end

		if(self.Time) then
			if(self.delay ~= 0) then
				if(self.CustomDelayText) then
					self:CustomDelayText(duration)
				else
					self.Time:SetFormattedText("%.1f|cffff0000%.1f|r", self.max - duration, self.delay)
				end
			else
				if(self.CustomTimeText) then
					self:CustomTimeText(duration)
				else
					self.Time:SetFormattedText("%.1f", self.max - duration)
				end
			end
		end

		self.duration = duration
		self:SetValue(duration)

		if (barFlash) then
			if self.flash then
				if flashOut(barFlash) then
					self.flash = nil
				end
			else
				barFlash:Hide()
			end
		end

		if(barSpark) then
			barSpark:SetPoint("CENTER", self, "LEFT", (duration / self.max) * self:GetWidth(), 0)
		end
	elseif (GetTime() < self.holdTime) then
		return
	elseif (self.flash) then
		if (barFlash) then
			if (flashIn(barFlash)) then
				self.flash = nil
			end
		else
			self.flash = nil
		end
	elseif (self.fadeOut) then
		local alpha = self:GetAlpha() - CASTING_BAR_ALPHA_STEP
		if (alpha > 0.05) then
			self:SetAlpha(alpha)
		else
			self.fadeOut = nil
			if (self.Spark) then self.Spark:Hide() end
			self:Hide()
		end
	end
end

local function UnrealCastbar(castbar)
	castbar.duration = 0
	castbar.max = 300
	castbar:SetMinMaxValues(0, castbar.max)
	castbar:SetValue(castbar.duration)

	castbar.interrupt = notInterruptible
	castbar.castid = castid

	castbar.casting = 1
	castbar.delay = 0
	castbar.holdTime = 0
	castbar.fadeOut = nil
	castbar.channeling = nil
	castbar:SetScript("OnUpdate", castbar.OnUpdate or onUpdate)

	if(castbar.Text) then castbar.Text:SetText"Fake Cast" end
	if(castbar.Icon) then castbar.Icon:SetTexture[[Interface\Icons\INV_Misc_Rune_01]] end
	if(castbar.Time) then castbar.Time:SetText() end
	if(castbar.Spark)then castbar.Spark:Show() end
	castbar:SetAlpha(1.0)
	castbar:Show()
	if(castbar.PostCastStart) then
		castbar:PostCastStart("player", "Fake Cast", 0)
	end
end

local Update = function(self, ...)
	UNIT_SPELLCAST_START(self, ...)
	return UNIT_SPELLCAST_CHANNEL_START(self, ...)
end

local ForceUpdate = function(element)
	return Update(element.__owner, "ForceUpdate", element.__owner.unit)
end

local Enable = function(object, unit)
	local castbar = object.CCastbar

	if(castbar) then
		castbar.__owner = object
		castbar.ForceUpdate = ForceUpdate
		if(not (unit and unit:match"%wtarget$")) then
			object:RegisterEvent("UNIT_SPELLCAST_START", UNIT_SPELLCAST_START)
			object:RegisterEvent("UNIT_SPELLCAST_FAILED", UNIT_SPELLCAST_FAILED)
			object:RegisterEvent("UNIT_SPELLCAST_STOP", UNIT_SPELLCAST_STOP)
			object:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED", UNIT_SPELLCAST_INTERRUPTED)
			object:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE", UNIT_SPELLCAST_INTERRUPTIBLE)
			object:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", UNIT_SPELLCAST_NOT_INTERRUPTIBLE)
			object:RegisterEvent("UNIT_SPELLCAST_DELAYED", UNIT_SPELLCAST_DELAYED)
			object:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START", UNIT_SPELLCAST_CHANNEL_START)
			object:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", UNIT_SPELLCAST_CHANNEL_UPDATE)
			object:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP", UNIT_SPELLCAST_CHANNEL_STOP)
		end

		castbar:SetScript("OnUpdate", castbar.OnUpdate or onUpdate)
		castbar.casting = nil
		castbar.channeling = nil
		castbar.holdTime = 0
		castbar.DummyCastbar = UnrealCastbar
		castbar.enableCastbar = true

		if(object.cUnit == "player") then
			CastingBarFrame:UnregisterAllEvents()
			CastingBarFrame.Show = CastingBarFrame.Hide
			CastingBarFrame:Hide()
		elseif(object.cUnit == "pet") then
			PetCastingBarFrame:UnregisterAllEvents()
			PetCastingBarFrame.Show = PetCastingBarFrame.Hide
			PetCastingBarFrame:Hide()
			object:RegisterEvent("UNIT_PET", UNIT_PET)
			castbar.enableCastbar = UnitIsPossessed("pet")
		end

		if(castbar:IsObjectType"StatusBar" and not castbar:GetStatusBarTexture()) then
			castbar:SetStatusBarTexture[[Interface\TargetingFrame\UI-StatusBar]]
		end

		local spark = castbar.Spark
		if(spark and spark:IsObjectType"Texture" and not spark:GetTexture()) then
			spark:SetTexture[[Interface\CastingBar\UI-CastingBar-Spark]]
		end

		local flash = castbar.Flash
		if(flash and flash:IsObjectType"Texture" and not flash:GetTexture()) then
			flash:SetTexture[[Interface\CastingBar\UI-CastingBar-Spark]]
		end


		local shield = castbar.Shield
		if(shield and shield:IsObjectType"Texture" and not shield:GetTexture()) then
			shield:SetTexture[[Interface\CastingBar\UI-CastingBar-Small-Shield]]
		end

		local sz = castbar.SafeZone
		if(sz and sz:IsObjectType"Texture" and not sz:GetTexture()) then
			sz:SetTexture(1, 0, 0)
		end

		castbar:Hide()

		return true
	end
end

local Disable = function(object, unit)
	local castbar = object.CCastbar

	if (castbar) then
		castbar:Hide()
		object:UnregisterEvent("UNIT_SPELLCAST_START", UNIT_SPELLCAST_START)
		object:UnregisterEvent("UNIT_SPELLCAST_FAILED", UNIT_SPELLCAST_FAILED)
		object:UnregisterEvent("UNIT_SPELLCAST_STOP", UNIT_SPELLCAST_STOP)
		object:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTED", UNIT_SPELLCAST_INTERRUPTED)
		object:UnregisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE", UNIT_SPELLCAST_INTERRUPTIBLE)
		object:UnregisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", UNIT_SPELLCAST_NOT_INTERRUPTIBLE)
		object:UnregisterEvent("UNIT_SPELLCAST_DELAYED", UNIT_SPELLCAST_DELAYED)
		object:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_START", UNIT_SPELLCAST_CHANNEL_START)
		object:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", UNIT_SPELLCAST_CHANNEL_UPDATE)
		object:UnregisterEvent("UNIT_SPELLCAST_CHANNEL_STOP", UNIT_SPELLCAST_CHANNEL_STOP)

		castbar:SetScript("OnUpdate", nil)

		if(object.cUnit == "pet") then
			object:UnregisterEvent("UNIT_PET", UNIT_PET)
		end
	end
end

oUF:AddElement("CCastbar", Update, Enable, Disable)