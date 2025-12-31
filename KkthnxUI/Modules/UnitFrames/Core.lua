local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:NewModule("Unitframes")
local AuraModule = K:GetModule("Auras")
local oUF = K.oUF

-- Lua functions
local pairs = pairs
local string_format = string.format
local unpack = unpack
local math_min = math.min
local ceil = math.ceil
local floor = math.floor

-- WoW API
local CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS
local CreateFrame = CreateFrame
local GetRuneCooldown = GetRuneCooldown
local IsInInstance = IsInInstance
local MAX_BOSS_FRAMES = MAX_BOSS_FRAMES
local PlaySound = PlaySound
local SOUNDKIT = SOUNDKIT
local UIParent = UIParent
local RegisterStateDriver = RegisterStateDriver
local UnitClass = UnitClass
local UnitExists = UnitExists
local UnitFactionGroup = UnitFactionGroup
local UnitIsEnemy = UnitIsEnemy
local UnitIsFriend = UnitIsFriend
local UnitIsPVP = UnitIsPVP
local UnitIsPVPFreeForAll = UnitIsPVPFreeForAll
local UnitIsPlayer = UnitIsPlayer
local UnitThreatSituation = UnitThreatSituation

-- Custom variables
local lastPvPSound = false
local phaseIconTexCoords = {
	[1] = { 1 / 128, 33 / 128, 1 / 64, 33 / 64 },
	[2] = { 34 / 128, 66 / 128, 1 / 64, 33 / 64 },
}
local filteredStyle = {
	["arena"] = true,
	["boss"] = true,
	["nameplate"] = true,
	["target"] = true,
}

-- Header registry (NDui-like pattern)
Module.headers = Module.headers or {}

-- Visibility helpers (NDui-like, adapted to our config)
function Module:GetPartyVisibility()
	if not C["Party"].Enable then
		return "hide"
	end
	-- If using raid layout for party, hide party header entirely
	if C["Raid"].UseRaidForParty then
		return "hide"
	end
	-- Blizzard-like: hide party when in raid; show in party (and optional solo)
	local vis = "[group:raid] hide;[group:party] show;hide"
	if C["Party"].ShowPartySolo then
		vis = "[nogroup] show;" .. vis
	end
	return vis
end

function Module:GetRaidVisibility()
	if not C["Raid"].Enable then
		return "hide"
	end
	-- When using raid layout for party, show raid header for any group (party or raid)
	if C["Raid"].UseRaidForParty then
		return "[group] show;hide"
	end
	-- Only show in raid (Blizzard-like)
	return "[group:raid] show;hide"
end

function Module:GetPartyPetVisibility()
	if not C["Party"].Enable or not C["Party"].ShowPet then
		return "hide"
	end
	-- If using raid layout for party, hide party-pet header too
	if C["Raid"].UseRaidForParty then
		return "hide"
	end
	return self:GetPartyVisibility()
end

function Module:ResetHeaderPoints(header)
	for i = 1, header:GetNumChildren() do
		local child = select(i, header:GetChildren())
		if child and child.ClearAllPoints then
			child:ClearAllPoints()
		end
	end
end

-- Reason: K:RegisterEvent callbacks do not preserve ":" method self; wrapper ensures Module is used.
Module._DeferredUpdateAllHeaders = Module._DeferredUpdateAllHeaders or function()
	Module:UpdateAllHeaders()
end

function Module:UpdateAllHeaders()
	if not self.headers or #self.headers == 0 then
		return
	end
	-- Avoid protected attribute changes in combat; defer until out of combat
	if InCombatLockdown() then
		self._pendingHeaderUpdate = true

		-- Reason: Use wrapper to preserve ':' self + avoid duplicate registrations while spam-called in combat
		if not self._pendingHeaderUpdateRegistered then
			self._pendingHeaderUpdateRegistered = true
			K:RegisterEvent("PLAYER_REGEN_ENABLED", Module._DeferredUpdateAllHeaders)
		end
		return
	elseif self._pendingHeaderUpdate then
		self._pendingHeaderUpdate = nil

		-- Reason: Unregister wrapper after deferred update
		if self._pendingHeaderUpdateRegistered then
			self._pendingHeaderUpdateRegistered = nil
			K:UnregisterEvent("PLAYER_REGEN_ENABLED", Module._DeferredUpdateAllHeaders)
		end
	end

	for _, header in pairs(self.headers) do
		local vis
		if header.groupType == "party" then
			vis = self:GetPartyVisibility()
		elseif header.groupType == "pet" then
			vis = self:GetPartyPetVisibility()
		elseif header.groupType == "raid" then
			vis = self:GetRaidVisibility()
		end

		-- Apply only when visibility state actually changes to avoid taint churn
		if vis and header.__lastVis ~= vis then
			RegisterStateDriver(header, "visibility", vis)
			header.__lastVis = vis
		end
	end
end

-- Centralized 3D portrait alpha fix (handles model and optional border)
function Module:ApplyPortraitAlphaFix(frame)
	if not frame then
		return
	end
	if not frame.Portrait then
		return
	end
	if not frame.Portrait.IsObjectType or not frame.Portrait:IsObjectType("PlayerModel") then
		return
	end

	local portrait = frame.Portrait
	portrait.__baseAlpha = portrait.__baseAlpha or (portrait:GetAlpha() or 1)
	if portrait.SetIgnoreParentAlpha then
		portrait:SetIgnoreParentAlpha(true)
	end

	-- Ensure our border (if present) also ignores parent alpha and is driven manually
	local border = portrait.KKUI_Border
	if border and border.SetIgnoreParentAlpha then
		border:SetIgnoreParentAlpha(true)
	end
	-- Also handle a potential portrait background
	local background = portrait.KKUI_Background
	if background and background.SetIgnoreParentAlpha then
		background:SetIgnoreParentAlpha(true)
	end

	-- Cache base alphas so we can restore intended alpha when scale returns to 1
	if border and not border.__baseAlpha and border.GetAlpha then
		border.__baseAlpha = border:GetAlpha() or 1
	end
	if background and not background.__baseAlpha then
		local baseAlpha
		if background.GetVertexColor then
			local _r, _g, _b, a = background:GetVertexColor()
			baseAlpha = a
		end
		background.__baseAlpha = baseAlpha or ((C["Media"] and C["Media"].Backdrops and C["Media"].Backdrops.ColorBackdrop and C["Media"].Backdrops.ColorBackdrop[4]) or 0.9)
	end

	if not frame.__portraitAlphaHooked then
		frame.__portraitAlphaHooked = true
		hooksecurefunc(frame, "SetAlpha", function(owner, value)
			local p = owner.Portrait
			if p and p.IsObjectType and p:IsObjectType("PlayerModel") then
				local scale = (value or 1)
				local alpha = scale * (p.__baseAlpha or 1)
				if p.SetModelAlpha then
					p:SetModelAlpha(alpha)
				end
				local b = p.KKUI_Border
				if b and b.SetAlpha then
					b:SetAlpha(scale * (b.__baseAlpha or 1))
				end
				local bg = p.KKUI_Background
				if bg and bg.SetAlpha then
					bg:SetAlpha(scale * (bg.__baseAlpha or 1))
				end
			end
		end)
	end

	local scaleSeed = (frame:GetAlpha() or 1)
	local seed = scaleSeed * (portrait.__baseAlpha or 1)
	if portrait.SetModelAlpha then
		portrait:SetModelAlpha(seed)
	end
	if border and border.SetAlpha then
		border:SetAlpha(scaleSeed * (border.__baseAlpha or 1))
	end
	if background and background.SetAlpha then
		background:SetAlpha(scaleSeed * (background.__baseAlpha or 1))
	end
end

function Module:UpdateClassPortraits(unit)
	if C["Unitframe"].PortraitStyle == 0 or not unit then
		return
	end

	local _, unitClass = UnitClass(unit)

	if unitClass then
		local PortraitValue = C["Unitframe"].PortraitStyle
		local ClassTCoords = CLASS_ICON_TCOORDS[unitClass]

		local texturePath
		if PortraitValue == 2 and UnitIsPlayer(unit) then
			texturePath = "Interface\\AddOns\\KkthnxUI\\Media\\Unitframes\\OLD-ICONS-CLASSES"
		elseif PortraitValue == 3 and UnitIsPlayer(unit) then
			texturePath = "Interface\\AddOns\\KkthnxUI\\Media\\Unitframes\\NEW-ICONS-CLASSES"
		end

		self:SetTexture(texturePath or "Interface\\TargetingFrame\\UI-Classes-Circles")
		if ClassTCoords then
			self:SetTexCoord(ClassTCoords[1], ClassTCoords[2], ClassTCoords[3], ClassTCoords[4])
		else
			self:SetTexCoord(0.15, 0.85, 0.15, 0.85)
		end
	end
end

function Module:PostUpdatePvPIndicator(unit, status)
	local factionGroup = UnitFactionGroup(unit)

	if UnitIsPVPFreeForAll(unit) and status == "ffa" then
		self:SetTexture("Interface\\TargetingFrame\\UI-PVP-FFA")
		self:SetTexCoord(0, 0.65625, 0, 0.65625)
	elseif factionGroup and UnitIsPVP(unit) and status ~= nil then
		self:SetTexture("Interface\\QUESTFRAME\\objectivewidget")

		if factionGroup == "Alliance" then
			self:SetTexCoord(0.00390625, 0.136719, 0.511719, 0.671875)
		else
			self:SetTexCoord(0.00390625, 0.136719, 0.679688, 0.839844)
		end
	end
end

function Module.PostUpdateLeaderIndicator(element, isLeader, isInLFGInstance)
	if isLeader then
		if isInLFGInstance then
			element:SetAtlas("Ping_Chat_Assist")
		else
			element:SetTexture([[Interface\GroupFrame\UI-Group-LeaderIcon]])
		end
	end
end

function Module:UpdateThreat(_, unit)
	if unit ~= self.unit then
		return
	end

	-- Get the current threat status of the unit
	local status = UnitThreatSituation(unit)

	-- Get the portrait style, health frame, and portrait frame
	local portraitStyle = C["Unitframe"].PortraitStyle
	local health = self.Health
	local portrait = self.Portrait

	-- Determine the border object based on the portrait style
	local borderObject
	if portraitStyle == 5 then
		borderObject = portrait.KKUI_Border
	elseif portraitStyle ~= 0 and portraitStyle ~= 4 then
		borderObject = portrait.Border and portrait.Border.KKUI_Border
	else
		borderObject = health.KKUI_Border
	end

	-- Update the border color based on threat status
	-- Reason: Some styles may not build the expected border object; avoid nil errors
	if not borderObject then
		return
	end

	-- Reason: Guard oUF threat table access
	if status and status > 1 and oUF and oUF.colors and oUF.colors.threat and oUF.colors.threat[status] then
		local r, g, b = unpack(oUF.colors.threat[status])
		borderObject:SetVertexColor(r, g, b)
	else
		K.SetBorderColor(borderObject)
	end
end

function Module:UpdatePhaseIcon(isPhased)
	self:SetTexCoord(unpack(phaseIconTexCoords[isPhased == 2 and 2 or 1]))
end

-- Function that plays a sound when the target or focus changes
local function CreateTargetSound(_, unit)
	-- Check if the unit exists
	if UnitExists(unit) then
		local soundKit
		-- Determine the sound kit based on the unit's relation to the player
		if UnitIsEnemy("player", unit) then
			soundKit = SOUNDKIT.IG_CREATURE_AGGRO_SELECT
		elseif UnitIsFriend("player", unit) then
			soundKit = SOUNDKIT.IG_CHARACTER_NPC_SELECT
		else
			soundKit = SOUNDKIT.IG_CREATURE_NEUTRAL_SELECT
		end
		PlaySound(soundKit)
	else
		PlaySound(SOUNDKIT.INTERFACE_SOUND_LOST_TARGET_UNIT)
	end
end

-- Function that plays a sound when the player changes their focus
function Module:PLAYER_FOCUS_CHANGED()
	CreateTargetSound(nil, "focus")
end

-- Function that plays a sound when the player changes their target
function Module:PLAYER_TARGET_CHANGED()
	CreateTargetSound(nil, "target")
end

function Module:UNIT_FACTION(unit)
	if unit ~= "player" then
		return
	end

	-- Check if player is in a PvP zone
	local isPvP = not not (UnitIsPVPFreeForAll("player") or UnitIsPVP("player"))

	-- Play sound if player enters a PvP zone and it has not been played yet
	if isPvP and not lastPvPSound then
		PlaySound(SOUNDKIT.IG_PVP_UPDATE)
	end

	-- Update lastPvPSound variable
	lastPvPSound = isPvP
end

local showOverAbsorb = false
function Module:PostUpdatePrediction(_, health, maxHealth, allIncomingHeal, allAbsorb)
	if not showOverAbsorb then
		self.overAbsorbBar:Hide()
		return
	end

	local hasOverAbsorb
	local overAbsorbAmount = health + allIncomingHeal + allAbsorb - maxHealth
	if overAbsorbAmount > 0 then
		if overAbsorbAmount > maxHealth then
			hasOverAbsorb = true
			overAbsorbAmount = maxHealth
		end
		self.overAbsorbBar:SetMinMaxValues(0, maxHealth)
		self.overAbsorbBar:SetValue(overAbsorbAmount)
		self.overAbsorbBar:Show()
	else
		self.overAbsorbBar:Hide()
	end

	if hasOverAbsorb then
		self.overAbsorb:Show()
	else
		self.overAbsorb:Hide()
	end
end

-- Elements
local function UF_OnEnter(self)
	if not self.disableTooltip then
		UnitFrame_OnEnter(self)
	end
	self.Highlight:Show()
end

local function UF_OnLeave(self)
	if not self.disableTooltip then
		UnitFrame_OnLeave(self)
	end
	self.Highlight:Hide()
end

function Module:UpdateClickState()
	self:RegisterForClicks(self.onKeyDown and "AnyDown" or "AnyUp")
	self.onKeyDown = nil
	self:UnregisterEvent("PLAYER_REGEN_ENABLED", Module.UpdateClickState, true)
end

function Module:CreateHeader(_, onKeyDown)
	if InCombatLockdown() then
		self.onKeyDown = onKeyDown
		self:RegisterEvent("PLAYER_REGEN_ENABLED", Module.UpdateClickState, true)
	else
		self:RegisterForClicks(onKeyDown and "AnyDown" or "AnyUp")
	end
	self:HookScript("OnEnter", UF_OnEnter)
	self:HookScript("OnLeave", UF_OnLeave)
end

function Module:ToggleCastBarLatency(frame)
	frame = frame or _G.oUF_Player
	if not frame then
		return
	end

	if C["Unitframe"].CastbarLatency then
		frame:RegisterEvent("GLOBAL_MOUSE_UP", Module.OnCastSent, true) -- Fix quests with WorldFrame interaction
		frame:RegisterEvent("GLOBAL_MOUSE_DOWN", Module.OnCastSent, true)
		frame:RegisterEvent("CURRENT_SPELL_CAST_CHANGED", Module.OnCastSent, true)
	else
		frame:UnregisterEvent("GLOBAL_MOUSE_UP", Module.OnCastSent)
		frame:UnregisterEvent("GLOBAL_MOUSE_DOWN", Module.OnCastSent)
		frame:UnregisterEvent("CURRENT_SPELL_CAST_CHANGED", Module.OnCastSent)
		if frame.Castbar then
			frame.Castbar.__sendTime = nil
		end
	end
end

-- Auras Helpers (oUF-style callbacks)

-- Lua / WoW API locals (Reason: faster lookups + avoids repeated global table indexing)
local math_ceil = math.ceil
local math_floor = math.floor
local next = next

local CreateFrame = CreateFrame
local UnitIsPlayer = UnitIsPlayer
local hooksecurefunc = hooksecurefunc

-- Aura Icon Size Cache

-- Cache the result of aura icon size calculations
-- Reason: Avoid recalculating the same size every update (layout can call this a lot)
local auraIconSizeCache = {}

local function QuantizePixel(value)
	-- Reason: widths/spacings can be floats; quantizing prevents infinite cache growth
	if not value or value <= 0 then
		return 0
	end
	return math_floor(value + 0.5)
end

function Module.auraIconSize(width, iconsPerRow, spacing)
	-- Reason: size depends on width + iconsPerRow + spacing; all must be part of the cache key
	local w = QuantizePixel(width)
	local n = iconsPerRow or 0
	local s = QuantizePixel(spacing or 0)

	if n <= 0 then
		return 0
	end

	local byW = auraIconSizeCache[w]
	if not byW then
		byW = {}
		auraIconSizeCache[w] = byW
	end

	local key = n .. ":" .. s
	local cached = byW[key]
	if not cached then
		cached = (w - (n - 1) * s) / n
		byW[key] = cached
	end

	return cached
end

function Module:UpdateAuraContainer(width, element, maxAuras)
	local iconsPerRow = element.iconsPerRow
	local spacing = element.spacing or 0

	-- Reason: When iconsPerRow is set we auto-calc the size, otherwise use element.size
	local size = iconsPerRow and Module.auraIconSize(width, iconsPerRow, spacing) or element.size

	-- Reason: Need CEIL, not ROUND, or the container can be too short and clip last row
	local maxLines = iconsPerRow and math_ceil((maxAuras or 0) / iconsPerRow) or 2
	if maxLines < 1 then
		maxLines = 1
	end

	local newH = (size + spacing) * maxLines

	-- Reason: Only apply changes when something actually differs to reduce layout churn
	if element.size ~= size or element:GetWidth() ~= width or element:GetHeight() ~= newH then
		element.size = size
		element:SetWidth(width)
		element:SetHeight(newH)
	end
end

-- Texture Cropping

function Module:UpdateIconTexCoord(width, height)
	-- Reason: This is hooked to SetSize; keep it safe + handle both aspect directions
	if not width or not height or width <= 0 or height <= 0 then
		return
	end

	local icon = self.Icon
	if not icon then
		return
	end

	-- Crop to center-square regardless of aspect ratio
	if width > height then
		-- Crop left/right
		local ratio = height / width
		local mult = (1 - ratio) * 0.5
		icon:SetTexCoord(K.TexCoords[1] + mult, K.TexCoords[2] - mult, K.TexCoords[3], K.TexCoords[4])
	elseif height > width then
		-- Crop top/bottom
		local ratio = width / height
		local mult = (1 - ratio) * 0.5
		icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3] + mult, K.TexCoords[4] - mult)
	else
		-- Perfect square
		icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	end
end

-- Button Setup

function Module.PostCreateButton(element, button)
	local fontSize = element.fontSize or (element.size * 0.52)

	-- Reason: Parent overlay frame lets us raise text/indicators above icon/cooldown reliably
	local parentFrame = CreateFrame("Frame", nil, button)
	parentFrame:SetAllPoints(button)
	parentFrame:SetFrameLevel(button:GetFrameLevel() + 3)

	-- Count text (stacks)
	button.Count = button.Count or K.CreateFontString(parentFrame, fontSize - 1, "", "OUTLINE", false, "BOTTOMRIGHT", 6, -3)

	-- Cooldown config (if present)
	if button.Cooldown then
		button.Cooldown.noOCC = true
		button.Cooldown.noCooldownCount = true
		button.Cooldown:SetReverse(true)
		button.Cooldown:SetHideCountdownNumbers(true)
	end

	-- Icon baseline
	if button.Icon then
		button.Icon:SetAllPoints()
		button.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	end

	-- Nameplate vs Unitframe styling
	local style = element.__owner and element.__owner.mystyle
	if style == "nameplate" then
		if button.Cooldown then
			button.Cooldown:SetAllPoints()
		end
		if button.CreateShadow then
			button:CreateShadow(true)
		end
	else
		if button.Cooldown then
			button.Cooldown:SetPoint("TOPLEFT", 1, -1)
			button.Cooldown:SetPoint("BOTTOMRIGHT", -1, 1)
		end
		if button.CreateBorder then
			button:CreateBorder()
		end
	end

	-- Reason: Some templates may not have Overlay; avoid nil errors
	if button.Overlay then
		button.Overlay:SetTexture(nil)
	end

	-- Stealable indicator (optional)
	if button.Stealable then
		button.Stealable:SetParent(parentFrame)
		button.Stealable:SetAtlas("bags-newitem")
		button.Stealable:Hide() -- Reason: Prevent “sticky” display between reused buttons
	end

	-- Click hook (optional safety)
	-- Reason: AuraModule might not exist in every load order; avoid hard errors
	if AuraModule and AuraModule.RemoveSpellFromIgnoreList then
		button:HookScript("OnMouseDown", AuraModule.RemoveSpellFromIgnoreList)
	end

	-- Timer text (duration)
	if not button.timer then
		button.timer = K.CreateFontString(parentFrame, fontSize, "", "OUTLINE")
	end

	-- Keep texcoords correct when size changes
	-- Reason: Some auras may not be perfectly square; we crop them cleanly
	hooksecurefunc(button, "SetSize", Module.UpdateIconTexCoord)
end

-- Icon Overrides

Module.ReplacedSpellIcons = {
	[368078] = 348567, -- Reason: Movement Speed
	[368079] = 348567, -- Reason: Movement Speed
	[368103] = 648208, -- Reason: Swiftness
	[368243] = 237538, -- Reason: CD
	[373785] = 236293, -- Reason: S4, Great Warlock Camouflage
}

-- Dispel/steal highlight types
-- Reason: Match your original intent; "" included for some server/tooltip variations
local dispellType = {
	["Magic"] = true,
	[""] = true,
}

-- Button Update

function Module.PostUpdateButton(element, button, unit, data)
	local duration = data.duration
	local expiration = data.expirationTime
	local debuffType = data.dispelName

	local owner = element.__owner
	local style = owner and owner.mystyle

	-- Reason: Original code always set identical values; keep it simple
	local size = element.size
	button:SetSize(size, size)

	-- Desaturation rules (harmful + filteredStyle)
	-- Reason: filteredStyle must exist in your file; guard so missing table doesn't hard error
	if button.Icon then
		if button.isHarmful and filteredStyle and filteredStyle[style] and not data.isPlayerAura then
			button.Icon:SetDesaturated(true)
		else
			button.Icon:SetDesaturated(false)
		end
	end

	-- Border coloring (debuff type)
	-- Reason: oUF nameplate buttons may use Shadow border; unitframes use KKUI_Border
	if button.isHarmful then
		local color
		if oUF and oUF.colors and oUF.colors.debuff then
			color = oUF.colors.debuff[debuffType] or oUF.colors.debuff.none
		end

		if color then
			if style == "nameplate" then
				if button.Shadow and button.Shadow.SetBackdropBorderColor then
					button.Shadow:SetBackdropBorderColor(color[1], color[2], color[3], 0.8)
				end
			else
				if button.KKUI_Border and button.KKUI_Border.SetVertexColor then
					button.KKUI_Border:SetVertexColor(color[1], color[2], color[3])
				end
			end
		end
	else
		if style == "nameplate" then
			if button.Shadow and button.Shadow.SetBackdropBorderColor then
				button.Shadow:SetBackdropBorderColor(0, 0, 0, 0.8)
			end
		else
			if button.KKUI_Border then
				K.SetBorderColor(button.KKUI_Border)
			end
		end
	end

	-- Stealable indicator
	-- Reason: Must explicitly hide when not applicable or it can “stick” on reused buttons
	if button.Stealable then
		if dispellType[debuffType] and not UnitIsPlayer(unit) and not button.isHarmful then
			button.Stealable:Show()
		else
			button.Stealable:Hide()
		end
	end

	-- Cooldown/timer
	if duration and duration > 0 then
		button.expiration = expiration
		button:SetScript("OnUpdate", K.CooldownOnUpdate)
		if button.timer then
			button.timer:Show()
		end
	else
		button:SetScript("OnUpdate", nil)
		if button.timer then
			button.timer:Hide()
		end
	end

	-- Replace icon texture (if defined)
	-- Reason: Your table uses spellID keys; data.spellId is the reliable source
	local spellID = data.spellId
	local newTexture = spellID and Module.ReplacedSpellIcons[spellID]
	if newTexture and button.Icon then
		button.Icon:SetTexture(newTexture)
	end

	-- Bolster stacks display (if this is the chosen bolster aura)
	if element.bolsterInstanceID and element.bolsterInstanceID == button.auraInstanceID then
		if button.Count then
			button.Count:SetText(element.bolsterStacks)
		end
	end
end

-- Post Update Info (Bolster + Dot tracking)

function Module.AurasPostUpdateInfo(element, _, _, debuffsChanged)
	-- Bolster tracking reset
	-- Reason: This function can run multiple times; always rebuild state from current data
	element.bolsterStacks = 0
	element.bolsterInstanceID = nil

	-- Reason: next(nil) errors; guard for safety
	local allBuffs = element.allBuffs
	local activeBuffs = element.activeBuffs

	if allBuffs and activeBuffs then
		for auraInstanceID, data in next, allBuffs do
			if data and data.spellId == 209859 then
				-- Keep first instance visible; hide duplicates but count stacks
				if not element.bolsterInstanceID then
					element.bolsterInstanceID = auraInstanceID
					activeBuffs[auraInstanceID] = true
				end

				element.bolsterStacks = element.bolsterStacks + 1

				if element.bolsterStacks > 1 then
					activeBuffs[auraInstanceID] = nil
				end
			end
		end
	end

	-- Push bolster stack count onto the visible button
	if element.bolsterStacks > 0 and element.visibleButtons and element.visibleButtons > 0 then
		for i = 1, element.visibleButtons do
			local button = element[i]
			if button and element.bolsterInstanceID and element.bolsterInstanceID == button.auraInstanceID then
				if button.Count then
					button.Count:SetText(element.bolsterStacks)
				end
				break
			end
		end
	end

	-- Dot tracking
	if debuffsChanged then
		element.hasTheDot = nil

		if C["Nameplate"].ColorByDot and element.allDebuffs then
			local spellList = C["Nameplate"].DotSpellList and C["Nameplate"].DotSpellList.Spells
			if spellList then
				for _, data in next, element.allDebuffs do
					if data and data.isPlayerAura and spellList[data.spellId] then
						element.hasTheDot = true
						break
					end
				end
			end
		end
	end
end

--========================================================--
-- Custom Filter
--========================================================--

function Module.CustomFilter(element, unit, data)
	local owner = element.__owner
	local style = owner and owner.mystyle

	local name = data.name
	local debuffType = data.dispelName
	local isStealable = data.isStealable
	local spellID = data.spellId
	local nameplateShowAll = data.nameplateShowAll

	local showDebuffType = C["Unitframe"].OnlyShowPlayerDebuff

	-- Nameplates / Boss / Arena filtering rules
	if style == "nameplate" or style == "boss" or style == "arena" then
		-- Pass all bolster
		-- Reason: You explicitly want bolster visible for stack aggregation
		if spellID == 209859 then
			return true
		end

		-- NameOnly plates use whitelist only
		-- Reason: Reduce clutter on name-only plates
		if owner and owner.plateType == "NameOnly" then
			return C.NameplateWhiteList[spellID] == true
		end

		-- Blacklist always blocks
		if C.NameplateBlackList[spellID] then
			return false
		end

		-- Dispell/steal show
		-- Reason: Highlight purgeable buffs on enemies (not player units)
		if (isStealable or dispellType[debuffType]) and not UnitIsPlayer(unit) and not data.isHarmful then
			return true
		end

		-- Whitelist always shows
		if C.NameplateWhiteList[spellID] then
			return true
		end

		-- Aura filter modes
		local auraFilter = C["Nameplate"].AuraFilter
		return (auraFilter == 3 and nameplateShowAll) or (auraFilter ~= 1 and data.isPlayerAura)
	end

	-- Unitframes: strict boolean returns
	-- Reason: Don’t return strings (truthy) — keep it explicit + predictable
	if showDebuffType then
		return data.isPlayerAura == true
	end
	return name ~= nil
end

-- Post Update Runes
local function OnUpdateRunes(self, elapsed)
	local duration = self.duration + elapsed
	self.duration = duration
	self:SetValue(duration)

	if self.timer then
		local remain = self.runeDuration - duration
		if remain > 0 then
			self.timer:SetText(K.FormatTime(remain))
		else
			self.timer:SetText(nil)
		end
	end
end

function Module.PostUpdateRunes(element, runemap)
	for index, runeID in next, runemap do
		local rune = element[index]
		local start, duration, runeReady = GetRuneCooldown(runeID)
		if rune:IsShown() then
			if runeReady then
				rune:SetAlpha(1)
				rune:SetScript("OnUpdate", nil)
				if rune.timer then
					rune.timer:SetText(nil)
				end
			elseif start then
				rune:SetAlpha(0.6)
				rune.runeDuration = duration
				rune:SetScript("OnUpdate", OnUpdateRunes)
			end
		end
	end
end

local function SetStatusBarColor(element, r, g, b)
	for i = 1, #element do
		local bar = element[i]
		bar:SetStatusBarColor(r, g, b)
	end
end

function Module.PostUpdateClassPower(element, cur, max, diff, powerType, chargedPowerPoints)
	local prevColor = element.prevColor
	local thisColor

	-- Special handling for combo points with graduated colors
	if powerType == "COMBO_POINTS" then
		local comboColors = element.__owner.colors.power["COMBO_POINTS_GRADUATED"]
		if comboColors and cur and cur > 0 then
			-- Set individual colors for each active combo point bar
			for i = 1, cur do
				local bar = element[i]
				local colorIndex = math_min(i, #comboColors)
				local color = comboColors[colorIndex]
				if color then
					bar:SetStatusBarColor(color[1], color[2], color[3])
				else
					-- Fallback to first color if colorIndex is out of range
					local fallbackColor = comboColors[1]
					bar:SetStatusBarColor(fallbackColor[1], fallbackColor[2], fallbackColor[3])
				end
			end
			element.prevColor = cur -- Track current combo points for change detection
			return -- Exit early since we handled combo points
		else
			-- Fallback to original logic if graduated colors not available
			if not cur or cur == 0 then
				thisColor = nil
			else
				thisColor = cur == max and 1 or 2
				if not prevColor or prevColor ~= thisColor then
					local r, g, b = 1, 0, 0
					if thisColor == 2 then
						local color = element.__owner.colors.power[powerType]
						r, g, b = color[1], color[2], color[3]
					end
					SetStatusBarColor(element, r, g, b)
					element.prevColor = thisColor
				end
			end
		end
	else
		-- Original logic for non-combo point power types
		if not cur or cur == 0 then
			thisColor = nil
		else
			thisColor = cur == max and 1 or 2
			if not prevColor or prevColor ~= thisColor then
				local r, g, b = 1, 0, 0
				if thisColor == 2 then
					local color = element.__owner.colors.power[powerType]
					r, g, b = color[1], color[2], color[3]
				end
				SetStatusBarColor(element, r, g, b)
				element.prevColor = thisColor
			end
		end
	end

	if diff then
		local barWidth = (element.__owner.ClassPowerBar:GetWidth() - (max - 1) * 6) / max
		for i = 1, max do
			local bar = element[i]
			bar:SetWidth(barWidth)
		end
	end

	for i = 1, 7 do
		local bar = element[i]
		if not bar.chargeStar then
			break
		end

		local showChargeStar = chargedPowerPoints and chargedPowerPoints[i]
		bar.chargeStar:SetShown(showChargeStar)
	end
end

function Module:CreateClassPower(self)
	local barWidth, barHeight, barPoint
	if self.mystyle == "PlayerPlate" then
		barWidth, barHeight = C["Nameplate"].PlateWidth, C["Nameplate"].PlateHeight
		barPoint = { "BOTTOMLEFT", self, "TOPLEFT", 0, 6 }
	elseif self.mystyle == "targetplate" then
		barWidth, barHeight = C["Nameplate"].PlateWidth, C["Nameplate"].PlateHeight - 2
		barPoint = { "CENTER", self }
	else
		barWidth, barHeight = C["Unitframe"].PlayerHealthWidth, 14
		barPoint = { "BOTTOMLEFT", self, "TOPLEFT", 0, 6 }
	end

	local isDK = K.Class == "DEATHKNIGHT"
	local maxBar = isDK and 6 or 7
	local bars, bar = {}, CreateFrame("Frame", "$parentClassPowerBar", self)

	bar:SetSize(barWidth, barHeight)
	bar:SetPoint(unpack(barPoint))

	if not bar.chargeParent then
		bar.chargeParent = CreateFrame("Frame", nil, bar)
		bar.chargeParent:SetAllPoints()
		bar.chargeParent:SetFrameLevel(8)
	end

	for i = 1, maxBar do
		local statusbar = CreateFrame("StatusBar", nil, bar)
		statusbar:SetHeight(barHeight)
		statusbar:SetWidth((barWidth - (maxBar - 1) * 6) / maxBar)
		statusbar:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
		statusbar:SetFrameLevel(self:GetFrameLevel() + 5)
		if self.mystyle == "PlayerPlate" or self.mystyle == "targetplate" then
			statusbar:CreateShadow(true)
		else
			statusbar:CreateBorder()
		end

		if i == 1 then
			statusbar:SetPoint("BOTTOMLEFT")
		else
			statusbar:SetPoint("LEFT", bars[i - 1], "RIGHT", 6, 0)
		end

		if isDK then
			statusbar.timer = K.CreateFontString(statusbar, 10, "")
		else
			local chargeStar = bar.chargeParent:CreateTexture()
			chargeStar:SetAtlas("VignetteKill")
			chargeStar:SetDesaturated(true)
			chargeStar:SetSize(22, 22)
			chargeStar:SetPoint("CENTER", statusbar)
			chargeStar:Hide()
			statusbar.chargeStar = chargeStar
		end

		bars[i] = statusbar
	end

	if isDK then
		bars.colorSpec, bars.sortOrder, bars.__max = true, "asc", 6
		bars.PostUpdate = Module.PostUpdateRunes
		self.Runes = bars
	else
		bars.PostUpdate = Module.PostUpdateClassPower
		self.ClassPower = bars
	end

	self.ClassPowerBar = bar
end

local textScaleFrames = {
	["player"] = true,
	["target"] = true,
	["focus"] = true,
	["pet"] = true,
	["targetoftarget"] = true,
	["focustarget"] = true,
	["boss"] = true,
	["arena"] = true,
}

function Module:UpdateTextScale()
	local scale = C["Unitframe"].AllTextScale
	for _, frame in pairs(oUF.objects) do
		local style = frame.mystyle
		if style and textScaleFrames[style] then
			if frame.Name then
				frame.Name:SetScale(scale)
			end

			if frame.Level then
				frame.Level:SetScale(scale)
			end

			frame.Health.Value:SetScale(scale)

			if frame.Power.Value then
				frame.Power.Value:SetScale(scale)
			end

			local castbar = frame.Castbar
			if castbar then
				castbar.Text:SetScale(scale)
				castbar.Time:SetScale(scale)
				if castbar.Lag then
					castbar.Lag:SetScale(scale)
				end
			end
		end
	end
end

-- Add direction/apply helper and init string factory
local function CreateHeaderInit(width, height)
	return string_format(
		[[ 
		self:SetWidth(%d)
		self:SetHeight(%d)
	]],
		width,
		height
	)
end

-- Centralized Blizzard raid frame disable
local function DisableBlizzardRaidFrames()
	if InCombatLockdown() then
		return
	end
	if CompactPartyFrame then
		CompactPartyFrame:UnregisterAllEvents()
	end
	if _G.CompactRaidFrameManager_SetSetting then
		_G.CompactRaidFrameManager_SetSetting("IsShown", "0")
		UIParent:UnregisterEvent("GROUP_ROSTER_UPDATE")
		_G.CompactRaidFrameManager:UnregisterAllEvents()
		_G.CompactRaidFrameManager:SetParent(K.UIFrameHider)
	end
end

function Module:CreateUnits()
	-- Reset header list to avoid duplicates on re-init/profile switch
	if Module.headers then
		wipe(Module.headers)
	end
	local horizonRaid = C["Raid"].HorizonRaid
	local numGroups = C["Raid"].NumGroups
	local raidWidth, raidHeight = C["Raid"].Width, C["Raid"].Height
	local reverse = C["Raid"].ReverseRaid
	local showPartyFrame = C["Party"].Enable
	local showTeamIndex = C["Raid"].ShowTeamIndex

	if C["Nameplate"].Enable then
		Module:SetupCVars()
		Module:BlockAddons()
		Module:CreateUnitTable()
		Module:CreatePowerUnitTable()
		Module:UpdateGroupRoles()
		Module:QuestIconCheck()
		Module:RefreshPlateOnFactionChanged()

		oUF:RegisterStyle("Nameplates", Module.CreatePlates)
		oUF:SetActiveStyle("Nameplates")
		oUF:SpawnNamePlates("oUF_NPs", Module.PostUpdatePlates)
	end

	do -- Playerplate-like PlayerFrame
		oUF:RegisterStyle("PlayerPlate", Module.CreatePlayerPlate)
		oUF:SetActiveStyle("PlayerPlate")
		local plate = oUF:Spawn("player", "oUF_PlayerPlate", true)
		plate.mover = K.Mover(plate, "PlayerPlate", "PlayerPlate", { "BOTTOM", UIParent, "BOTTOM", 0, 300 })
		Module:TogglePlayerPlate()
	end

	do -- Fake nameplate for target class power
		oUF:RegisterStyle("TargetPlate", Module.CreateTargetPlate)
		oUF:SetActiveStyle("TargetPlate")
		oUF:Spawn("player", "oUF_TargetPlate", true)
		Module:ToggleTargetClassPower()
	end

	if C["Unitframe"].Enable then
		oUF:RegisterStyle("Player", Module.CreatePlayer)
		oUF:RegisterStyle("Target", Module.CreateTarget)
		oUF:RegisterStyle("ToT", Module.CreateTargetOfTarget)
		oUF:RegisterStyle("Focus", Module.CreateFocus)
		oUF:RegisterStyle("FocusTarget", Module.CreateFocusTarget)
		oUF:RegisterStyle("Pet", Module.CreatePet)

		oUF:SetActiveStyle("Player")
		local Player = oUF:Spawn("player", "oUF_Player")
		Player:SetSize(C["Unitframe"].PlayerHealthWidth, C["Unitframe"].PlayerHealthHeight + C["Unitframe"].PlayerPowerHeight + 6)
		K.Mover(Player, "PlayerUF", "PlayerUF", { "BOTTOM", UIParent, "BOTTOM", -260, 320 }, Player:GetWidth(), Player:GetHeight())

		oUF:SetActiveStyle("Target")
		local Target = oUF:Spawn("target", "oUF_Target")
		Target:SetSize(C["Unitframe"].TargetHealthWidth, C["Unitframe"].TargetHealthHeight + C["Unitframe"].TargetPowerHeight + 6)
		K.Mover(Target, "TargetUF", "TargetUF", { "BOTTOM", UIParent, "BOTTOM", 260, 320 }, Target:GetWidth(), Target:GetHeight())

		if not C["Unitframe"].HideTargetofTarget then
			oUF:SetActiveStyle("ToT")
			local TargetOfTarget = oUF:Spawn("targettarget", "oUF_ToT")
			TargetOfTarget:SetSize(C["Unitframe"].TargetTargetHealthWidth, C["Unitframe"].TargetTargetHealthHeight + C["Unitframe"].TargetTargetPowerHeight + 6)
			K.Mover(TargetOfTarget, "TotUF", "TotUF", { "TOPLEFT", Target, "BOTTOMRIGHT", 6, -6 }, TargetOfTarget:GetWidth(), TargetOfTarget:GetHeight())
		end

		oUF:SetActiveStyle("Pet")
		local Pet = oUF:Spawn("pet", "oUF_Pet")
		Pet:SetSize(C["Unitframe"].PetHealthWidth, C["Unitframe"].PetHealthHeight + C["Unitframe"].PetPowerHeight + 6)
		K.Mover(Pet, "Pet", "Pet", { "TOPRIGHT", Player, "BOTTOMLEFT", -6, -6 }, Pet:GetWidth(), Pet:GetHeight())

		oUF:SetActiveStyle("Focus")
		local Focus = oUF:Spawn("focus", "oUF_Focus")
		Focus:SetSize(C["Unitframe"].FocusHealthWidth, C["Unitframe"].FocusHealthHeight + C["Unitframe"].FocusPowerHeight + 6)
		K.Mover(Focus, "FocusUF", "FocusUF", { "BOTTOMRIGHT", Player, "TOPLEFT", -60, 200 }, Focus:GetWidth(), Focus:GetHeight())

		if not C["Unitframe"].HideFocusTarget then
			oUF:SetActiveStyle("FocusTarget")
			local FocusTarget = oUF:Spawn("focustarget", "oUF_FocusTarget")
			FocusTarget:SetSize(C["Unitframe"].FocusTargetHealthWidth, C["Unitframe"].FocusTargetHealthHeight + C["Unitframe"].FocusTargetPowerHeight + 6)
			K.Mover(FocusTarget, "FocusTarget", "FocusTarget", { "TOPLEFT", Focus, "BOTTOMRIGHT", 6, -6 }, FocusTarget:GetWidth(), FocusTarget:GetHeight())
		end

		K:RegisterEvent("PLAYER_TARGET_CHANGED", Module.PLAYER_TARGET_CHANGED)
		K:RegisterEvent("PLAYER_FOCUS_CHANGED", Module.PLAYER_FOCUS_CHANGED)
		K:RegisterEvent("UNIT_FACTION", Module.UNIT_FACTION)

		Module:UpdateTextScale()
	end

	if C["Boss"].Enable then
		oUF:RegisterStyle("Boss", Module.CreateBoss)
		oUF:SetActiveStyle("Boss")

		local Boss = {}
		for i = 1, 10 do -- MAX_BOSS_FRAMES, 10 in 11.0?
			Boss[i] = oUF:Spawn("boss" .. i, "oUF_Boss" .. i)
			Boss[i]:SetSize(C["Boss"].HealthWidth, C["Boss"].HealthHeight + C["Boss"].PowerHeight + 6)

			local bossMoverWidth, bossMoverHeight = C["Boss"].HealthWidth, C["Boss"].HealthHeight + C["Boss"].PowerHeight + 6
			if i == 1 then
				Boss[i].mover = K.Mover(Boss[i], "BossFrame" .. i, "Boss1", { "BOTTOMRIGHT", UIParent, "RIGHT", -250, 140 }, bossMoverWidth, bossMoverHeight)
			else
				Boss[i].mover = K.Mover(Boss[i], "BossFrame" .. i, "Boss" .. i, { "TOPLEFT", Boss[i - 1], "BOTTOMLEFT", 0, -C["Boss"].YOffset }, bossMoverWidth, bossMoverHeight)
			end
		end
	end

	if C["Arena"].Enable then
		oUF:RegisterStyle("Arena", Module.CreateArena)
		oUF:SetActiveStyle("Arena")

		local Arena = {}
		for i = 1, 5 do
			Arena[i] = oUF:Spawn("arena" .. i, "oUF_Arena" .. i)
			Arena[i]:SetSize(C["Arena"].HealthWidth, C["Arena"].HealthHeight + C["Arena"].PowerHeight + 6)

			local arenaMoverWidth, arenaMoverHeight = C["Arena"].HealthWidth, C["Arena"].HealthHeight + C["Arena"].PowerHeight + 6
			if i == 1 then
				Arena[i].mover = K.Mover(Arena[i], "ArenaFrame" .. i, "Arena1", { "BOTTOMRIGHT", UIParent, "RIGHT", -250, 140 }, arenaMoverWidth, arenaMoverHeight)
			else
				Arena[i].mover = K.Mover(Arena[i], "ArenaFrame" .. i, "Arena" .. i, { "TOPLEFT", Arena[i - 1], "BOTTOMLEFT", 0, -C["Arena"].YOffset }, arenaMoverWidth, arenaMoverHeight)
			end
		end
	end

	local partyMover
	if showPartyFrame then
		-- Check if using SimpleParty (raid-style compact) or traditional Party frames
		if C["SimpleParty"].Enable then
			-- Use raid-style compact party frames
			oUF:RegisterStyle("SimpleParty", Module.CreateSimpleParty)
			oUF:SetActiveStyle("SimpleParty")

			local simplePartyWidth = C["SimpleParty"].HealthWidth
			local simplePartyHeight = C["SimpleParty"].HealthHeight
			local horizonParty = C["SimpleParty"].HorizonParty
			local partyXOffset = horizonParty and 6 or 0
			local partyYOffset = horizonParty and 0 or -6

			-- Calculate mover size based on orientation
			local partyMoverWidth, partyMoverHeight
			if horizonParty then
				-- Horizontal: width = 5 frames wide, height = 1 frame tall
				partyMoverWidth = (simplePartyWidth + 6) * 5
				partyMoverHeight = simplePartyHeight
			else
				-- Vertical: width = 1 frame wide, height = 5 frames tall
				partyMoverWidth = simplePartyWidth
				partyMoverHeight = (simplePartyHeight + 6) * 5
			end

			-- stylua: ignore
			local party = oUF:SpawnHeader(
				"oUF_SimpleParty", nil, nil,
				"showPlayer", C["Party"].ShowPlayer,
				"showSolo", true,
				"showParty", true,
				"showRaid", false,
				"xOffset", partyXOffset,
				"yOffset", partyYOffset,
				"groupFilter", "1",
				"groupingOrder", "TANK,HEALER,DAMAGER,NONE",
				"groupBy", "GROUP",
				"sortMethod", "INDEX",
				"maxColumns", 1,
				"unitsPerColumn", 5,
				"columnSpacing", 6,
				"point", horizonParty and "LEFT" or "TOP",
				"columnAnchorPoint", "LEFT",
				"oUF-initialConfigFunction", string_format([[ 
					self:SetWidth(%d)
					self:SetHeight(%d)
				]], simplePartyWidth, simplePartyHeight)
			)

			partyMover = K.Mover(party, "SimplePartyFrame", "SimplePartyFrame", { "LEFT", UIParent, 350, 0 }, partyMoverWidth, partyMoverHeight)
			party.groupType = "party"
			tinsert(Module.headers, party)
			RegisterStateDriver(party, "visibility", Module:GetPartyVisibility())
			party:ClearAllPoints()
			party:SetPoint("TOPLEFT", partyMover)
		else
			-- Use traditional party frames with portraits, castbars, etc.
			oUF:RegisterStyle("Party", Module.CreateParty)
			oUF:SetActiveStyle("Party")

			local partyXOffset, partyYOffset = 6, C["Party"].ShowBuffs and 56 or 36
			local partyMoverWidth = C["Party"].HealthWidth
			local partyMoverHeight = C["Party"].HealthHeight + C["Party"].PowerHeight + 1 + partyYOffset * 8
			local partyGroupingOrder = "NONE,DAMAGER,HEALER,TANK"

			-- stylua: ignore
			local party = oUF:SpawnHeader(
				"oUF_Party", nil, nil,
				"showPlayer", C["Party"].ShowPlayer,
				"showSolo", true,
				"showParty", true,
				"showRaid", false,
				"xOffset", partyXOffset,
				"yOffset", partyYOffset,
				"groupFilter", "1",
				"groupingOrder", partyGroupingOrder,
				"groupBy", "ASSIGNEDROLE",
				"sortMethod", "NAME",
				"point", "BOTTOM",
				"columnAnchorPoint", "LEFT",
				"oUF-initialConfigFunction", string_format([[ 
					self:SetWidth(%d)
					self:SetHeight(%d)
				]], C["Party"].HealthWidth, C["Party"].HealthHeight + C["Party"].PowerHeight + 6)
			)

			partyMover = K.Mover(party, "PartyFrame", "PartyFrame", { "TOPLEFT", UIParent, "TOPLEFT", 50, -300 }, partyMoverWidth, partyMoverHeight)
			party.groupType = "party"
			tinsert(Module.headers, party)
			RegisterStateDriver(party, "visibility", Module:GetPartyVisibility())
			party:ClearAllPoints()
			party:SetPoint("TOPLEFT", partyMover)
		end

		if C["Party"].ShowPet then
			oUF:RegisterStyle("PartyPet", Module.CreatePartyPet)
			oUF:SetActiveStyle("PartyPet")

			local partypetXOffset, partypetYOffset = 6, 25
			local partpetMoverWidth = 60
			local partpetMoverHeight = 34 * 5 + partypetYOffset * 4

			-- stylua: ignore
			local partyPet = oUF:SpawnHeader(
				"oUF_PartyPet", "SecureGroupPetHeaderTemplate", nil,
				"showSolo", true,
				"showParty", true,
				"showRaid", false,
				"xOffset", partypetXOffset,
				"yOffset", partypetYOffset,
				"point", "BOTTOM",
				"columnAnchorPoint", "LEFT",
				"oUF-initialConfigFunction", string_format([[ 
					self:SetWidth(%d)
					self:SetHeight(%d)
				]], 60, 34)
			)

			local moverAnchor = { "TOPLEFT", partyMover, "TOPRIGHT", 6, -40 }
			local petMover = K.Mover(partyPet, "PartyPetFrame", "PartyPetFrame", moverAnchor, partpetMoverWidth, partpetMoverHeight)
			partyPet.groupType = "pet"
			tinsert(Module.headers, partyPet)
			RegisterStateDriver(partyPet, "visibility", Module:GetPartyPetVisibility())
			partyPet:ClearAllPoints()
			partyPet:SetPoint("TOPLEFT", petMover)
		end
	end

	if C["Raid"].Enable then
		SetCVar("predictedHealth", 1)
		oUF:RegisterStyle("Raid", Module.CreateRaid)
		oUF:SetActiveStyle("Raid")

		-- Hide Default RaidFrame via helper
		DisableBlizzardRaidFrames()

		local raidMover
		-- stylua: ignore
		local function CreateGroup(name, i)
			local group = oUF:SpawnHeader(
				name, nil, nil,
				"showPlayer", true,
				"showSolo", true,
				"showParty", true,
				"showRaid", true,
				"xOffset", 6,
				"yOffset", -6,
				"groupFilter", tostring(i),
				"groupingOrder", "1,2,3,4,5,6,7,8",
				"groupBy", "GROUP",
				"sortMethod", "INDEX",
				"maxColumns", 1,
				"unitsPerColumn", 5,
				"columnSpacing", 5,
				"point", horizonRaid and "LEFT" or "TOP",
				"columnAnchorPoint", "LEFT",
				"oUF-initialConfigFunction", CreateHeaderInit(raidWidth, raidHeight)
			)

			return group
		end

		local function CreateTeamIndex(header)
			local parent = _G[header:GetName() .. "UnitButton1"]
			if parent and not parent.teamIndex then
				local teamIndex = K.CreateFontString(parent, 11, string_format(_G.GROUP_NUMBER, header.index), "")
				teamIndex:ClearAllPoints()
				teamIndex:SetPoint("BOTTOM", parent, "TOP", 0, 3)
				teamIndex:SetTextColor(255 / 255, 204 / 255, 102 / 255)

				parent.teamIndex = teamIndex
			end
		end

		local groups = {}
		for i = 1, numGroups do
			groups[i] = CreateGroup("oUF_Raid" .. i, i)
			groups[i].index = i
			groups[i].groupType = "raid"
			tinsert(Module.headers, groups[i])
			RegisterStateDriver(groups[i], "visibility", Module:GetRaidVisibility())

			if i == 1 then
				if horizonRaid then
					raidMover = K.Mover(groups[i], "RaidFrame", "RaidFrame", { "TOPLEFT", UIParent, "TOPLEFT", 4, -180 }, (raidWidth + 5) * 5, (raidHeight + (showTeamIndex and 15 or 5)) * numGroups)
					if reverse then
						groups[i]:ClearAllPoints()
						groups[i]:SetPoint("BOTTOMLEFT", raidMover)
					end
				else
					raidMover = K.Mover(groups[i], "RaidFrame", "RaidFrame", { "TOPLEFT", UIParent, "TOPLEFT", 4, -180 }, (raidWidth + 5) * numGroups, (raidHeight + 5) * 5)
					if reverse then
						groups[i]:ClearAllPoints()
						groups[i]:SetPoint("TOPRIGHT", raidMover)
					end
				end
			else
				if horizonRaid then
					if reverse then
						groups[i]:SetPoint("BOTTOMLEFT", groups[i - 1], "TOPLEFT", 0, showTeamIndex and 18 or 6)
					else
						groups[i]:SetPoint("TOPLEFT", groups[i - 1], "BOTTOMLEFT", 0, showTeamIndex and -18 or -6)
					end
				else
					if reverse then
						groups[i]:SetPoint("TOPRIGHT", groups[i - 1], "TOPLEFT", -6, 0)
					else
						groups[i]:SetPoint("TOPLEFT", groups[i - 1], "TOPRIGHT", 6, 0)
					end
				end
			end

			if showTeamIndex then
				CreateTeamIndex(groups[i])
				groups[i]:HookScript("OnShow", CreateTeamIndex)
			end
		end

		if C["Raid"].MainTankFrames then
			oUF:RegisterStyle("MainTank", Module.CreateRaid)
			oUF:SetActiveStyle("MainTank")

			local horizonTankRaid = C["Raid"].HorizonRaid
			local raidTankWidth, raidTankHeight = C["Raid"].Width, C["Raid"].Height
			-- stylua: ignore
			local raidtank = oUF:SpawnHeader(
				"oUF_MainTank", nil, "raid",
				"showRaid", true,
				"xOffset", 6,
				"yOffset", -6,
				"groupFilter", "MAINTANK",
				"point", horizonTankRaid and "LEFT" or "TOP",
				"columnAnchorPoint", "LEFT",
				"template", C["Raid"].MainTankFrames and "oUF_MainTankTT" or "oUF_MainTank",
				"oUF-initialConfigFunction", string_format([[ 
					self:SetWidth(%d)
					self:SetHeight(%d)
				]], raidTankWidth, raidTankHeight)
			)

			local raidtankMover = K.Mover(raidtank, "MainTankFrame", "MainTankFrame", { "TOPLEFT", UIParent, "TOPLEFT", 4, -50 }, raidTankWidth, raidTankHeight)
			raidtank:ClearAllPoints()
			raidtank:SetPoint("TOPLEFT", raidtankMover)
		end
	end

	-- Apply header visibility once after creation
	Module:UpdateAllHeaders()
end

function Module:UpdateRaidDebuffIndicator()
	local ORD = K.oUF_RaidDebuffs or oUF_RaidDebuffs

	if ORD then
		local _, InstanceType = IsInInstance()

		ORD:ResetDebuffData()

		if InstanceType == "party" or InstanceType == "raid" then
			if C["Raid"].DebuffWatchDefault or C["SimpleParty"].DebuffWatchDefault then
				ORD:RegisterDebuffs(C["DebuffsTracking_PvE"].spells)
			end

			ORD:RegisterDebuffs(KkthnxUIDB.Variables[K.Realm][K.Name].Tracking.PvE)
		else
			if C["Raid"].DebuffWatchDefault or C["SimpleParty"].DebuffWatchDefault then
				ORD:RegisterDebuffs(C["DebuffsTracking_PvP"].spells)
			end

			ORD:RegisterDebuffs(KkthnxUIDB.Variables[K.Realm][K.Name].Tracking.PvP)
		end
	end
end

function Module:OnEnable()
	-- Register our units / layout
	self:CreateUnits()

	if C["Raid"].DebuffWatch or C["SimpleParty"].DebuffWatch then
		local ORD = K.oUF_RaidDebuffs or oUF_RaidDebuffs
		local RaidDebuffs = CreateFrame("Frame")

		RaidDebuffs:RegisterEvent("PLAYER_ENTERING_WORLD")
		RaidDebuffs:SetScript("OnEvent", Module.UpdateRaidDebuffIndicator)

		if ORD then
			ORD.ShowDispellableDebuff = true
			ORD.FilterDispellableDebuff = true
			ORD.MatchBySpellName = false
		end

		self:CreateTracking()
	end
end

-- Live update SimpleParty width/height from GUI without reload
-- Reason: K:RegisterEvent callbacks do not preserve ":" method self; wrapper ensures Module is used.
Module._DeferredUpdateSimplePartySize = Module._DeferredUpdateSimplePartySize or function()
	Module:UpdateSimplePartySize()
end

function Module:UpdateSimplePartySize()
	-- Defer in combat
	if InCombatLockdown() then
		self._pendingSimplePartySize = true

		-- Reason: Use wrapper to preserve ':' self + avoid duplicate registrations while spam-called in combat
		if not self._pendingSimplePartySizeRegistered then
			self._pendingSimplePartySizeRegistered = true
			K:RegisterEvent("PLAYER_REGEN_ENABLED", Module._DeferredUpdateSimplePartySize)
		end
		return
	elseif self._pendingSimplePartySize then
		self._pendingSimplePartySize = nil

		-- Reason: Unregister wrapper after deferred update
		if self._pendingSimplePartySizeRegistered then
			self._pendingSimplePartySizeRegistered = nil
			K:UnregisterEvent("PLAYER_REGEN_ENABLED", Module._DeferredUpdateSimplePartySize)
		end
	end

	if not C["Party"].Enable or not C["SimpleParty"].Enable then
		return
	end

	local width = C["SimpleParty"].HealthWidth or 70
	local height = C["SimpleParty"].HealthHeight or 44
	local horizon = C["SimpleParty"].HorizonParty

	-- Find the SimpleParty header
	local header
	for _, h in pairs(self.headers or {}) do
		if h and h.groupType == "party" and h.GetName and h:GetName() == "oUF_SimpleParty" then
			header = h
			break
		end
	end
	-- Fallback: pick the first party header when using SimpleParty
	if not header then
		for _, h in pairs(self.headers or {}) do
			if h and h.groupType == "party" then
				header = h
				break
			end
		end
	end
	if not header then
		return
	end

	-- Resize each unit button and adjust dependent elements
	for i = 1, header:GetNumChildren() do
		local frame = select(i, header:GetChildren())
		if frame and frame.SetSize then
			frame:SetSize(width, height)

			-- Update debuff indicator size if present
			if frame.RaidDebuffs then
				local debuffSize = (height >= 32) and (height - 20) or height
				frame.RaidDebuffs:SetSize(debuffSize, debuffSize)
			end

			-- Re-run power/health layout logic to respect PowerBarHeight
			if frame.UpdateSimplePartyPower and (frame.unit or frame.GetAttribute) then
				local unit = frame.unit or (frame.GetAttribute and (frame:GetAttribute("oUF-guessUnit") or frame:GetAttribute("unit")))
				if unit then
					frame:UpdateSimplePartyPower(nil, unit)
				end
			end
		end
	end

	-- Update mover size to match layout
	local mover = _G["SimplePartyFrame"]
	if mover and mover.SetSize then
		if horizon then
			mover:SetSize((width + 6) * 5, height)
		else
			mover:SetSize(width, (height + 6) * 5)
		end
	end
end
