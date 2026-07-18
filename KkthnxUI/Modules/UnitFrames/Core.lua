--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Main orchestration and coordination for the Unitframes module.
-- - Design: Manages spawning, visibility, aura handling, and shared UI elements for all oUF frames.
-- - Events: PLAYER_REGEN_ENABLED, UNIT_INVENTORY_CHANGED, PLAYER_TARGET_CHANGED, PLAYER_FOCUS_CHANGED, UNIT_FACTION
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:NewModule("Unitframes")
local AuraModule = K:GetModule("Auras")
local oUF = K.oUF

-- Lua functions
local ipairs = ipairs
local next = next
local pairs = pairs
local rawget = rawget
local string_format = string.format
local unpack = unpack
local math_min = math.min
local math_ceil = math.ceil
local math_floor = math.floor

-- WoW API
local CLASS_ICON_TCOORDS = CLASS_ICON_TCOORDS
local CreateFrame = CreateFrame
local GetRuneCooldown = GetRuneCooldown
local GetTime = GetTime
local hooksecurefunc = hooksecurefunc
local InCombatLockdown = InCombatLockdown
local IsInInstance = IsInInstance
local PlaySound = PlaySound
local SOUNDKIT = SOUNDKIT
local tinsert = tinsert
local tremove = tremove
local pcall = pcall
local UIParent = UIParent
local RegisterStateDriver = RegisterStateDriver
local UnregisterStateDriver = UnregisterStateDriver
local UnitClass = UnitClass
local UnitExists = UnitExists
local UnitLevel = UnitLevel
local IsLevelAtEffectiveMaxLevel = IsLevelAtEffectiveMaxLevel
local UnitFactionGroup = UnitFactionGroup
local UnitIsEnemy = UnitIsEnemy
local UnitIsFriend = UnitIsFriend
local UnitIsPVP = UnitIsPVP
local UnitIsPVPFreeForAll = UnitIsPVPFreeForAll
local UnitIsPlayer = UnitIsPlayer
local UnitThreatSituation = UnitThreatSituation
local UnitGUID = UnitGUID
local UnitIsConnected = UnitIsConnected
local UnitIsVisible = UnitIsVisible
local UnitIsTapDenied = UnitIsTapDenied
local UnitPlayerControlled = UnitPlayerControlled
local UnitInPartyIsAI = UnitInPartyIsAI
local UnitClass = UnitClass
local UnitReaction = UnitReaction
local UnitHealthPercent = UnitHealthPercent
local UnitPowerPercent = UnitPowerPercent
local UnitPowerType = UnitPowerType
local UnitSelectionType = UnitSelectionType
local SetPortraitTexture = SetPortraitTexture
local IsSecret = K.IsSecret
local NotSecret = K.NotSecret

-- oUF nils Private after finalize.lua; mirror private.unitSelectionType locally.
local function safeUnitSelectionType(unit, considerHostile)
	if considerHostile then
		local threat = UnitThreatSituation("player", unit)
		if IsSecret(threat) then
			return nil
		elseif threat then
			return 0
		end
	end

	if not UnitSelectionType then
		return nil
	end

	local selection = UnitSelectionType(unit, true)
	if IsSecret(selection) then
		return nil
	end

	return selection
end

local registeredStyles = Module._oUFRegisteredStyles or {}
Module._oUFRegisteredStyles = registeredStyles

--- oUF styles are global for the session; live rebuilds must not re-register.
local function registerStyleOnce(name, func)
	if registeredStyles[name] then
		return
	end
	oUF:RegisterStyle(name, func)
	registeredStyles[name] = true
end

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

-- Header registry
Module.headers = Module.headers or {}

-- Visibility helpers
-- REASON: Determines visibility state for party frames based on configuration and group status.
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

-- REASON: Determines visibility state for raid frames based on configuration.
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

-- REASON: Resets anchor points for all children in a unit header to safely re-anchor.
function Module:ResetHeaderPoints(header)
	for i = 1, header:GetNumChildren() do
		local child = select(i, header:GetChildren())
		if child and child.ClearAllPoints then
			child:ClearAllPoints()
		end
	end
end

function Module:GetPartyHeader(headerName)
	for _, header in ipairs(self.headers or {}) do
		if header.groupType == "party" then
			if not headerName then
				return header
			end
			if header.GetName and header:GetName() == headerName then
				return header
			end
		end
	end
end

local function disableGroupHeader(header)
	if not header then
		return
	end

	pcall(UnregisterStateDriver, header, "visibility")
	header:SetAttribute("showPlayer", false)
	header:SetAttribute("showParty", false)
	header:SetAttribute("showRaid", false)
	header:SetAttribute("showSolo", false)
	header:Hide()
	if K.UIFrameHider then
		header:SetParent(K.UIFrameHider)
	end
end

local function retireUnitFrame(frame)
	if not frame then
		return
	end

	frame:Hide()
	if K.UIFrameHider then
		frame:SetParent(K.UIFrameHider)
	end
end

local function removeHeadersByGroupType(headers, groupType)
	if not headers then
		return
	end

	for i = #headers, 1, -1 do
		local header = headers[i]
		if header and header.groupType == groupType then
			disableGroupHeader(header)
			tremove(headers, i)
		end
	end
end

local function attachPartyToMover(party, moverKey, defaultAnchor, width, height)
	local mover = _G["KKUI_Mover_" .. moverKey]
	if mover then
		if mover.SetSize then
			mover:SetSize(width, height)
		end
		party:ClearAllPoints()
		party:SetPoint("TOPLEFT", mover)
	else
		mover = K.Mover(party, moverKey, moverKey, defaultAnchor, width, height)
	end
	return mover
end

-- Reason: K:RegisterEvent callbacks do not preserve ":" method self; wrapper ensures Module is used.
Module._DeferredUpdateAllHeaders = Module._DeferredUpdateAllHeaders or function()
	Module:UpdateAllHeaders()
end

-- REASON: Updates visibility for all registered headers, deferred in combat to prevent taints.
function Module:UpdateAllHeaders()
	if not self.headers or #self.headers == 0 then
		return
	end

	-- REASON: Avoid protected attribute changes in combat; defer until out of combat.
	if InCombatLockdown() then
		self._pendingHeaderUpdate = true

		-- REASON: Use wrapper to preserve ':' self + avoid duplicate registrations while spam-called in combat.
		if not self._pendingHeaderUpdateRegistered then
			self._pendingHeaderUpdateRegistered = true
			K:RegisterEvent("PLAYER_REGEN_ENABLED", Module._DeferredUpdateAllHeaders)
		end
		return
	elseif self._pendingHeaderUpdate then
		self._pendingHeaderUpdate = nil

		-- REASON: Unregister wrapper after deferred update.
		if self._pendingHeaderUpdateRegistered then
			self._pendingHeaderUpdateRegistered = nil
			K:UnregisterEvent("PLAYER_REGEN_ENABLED", Module._DeferredUpdateAllHeaders)
		end
	end

	for _, header in ipairs(self.headers) do
		local vis
		if header.groupType == "party" then
			vis = self:GetPartyVisibility()
		elseif header.groupType == "pet" then
			vis = self:GetPartyPetVisibility()
		elseif header.groupType == "raid" then
			vis = self:GetRaidVisibility()
		end

		-- REASON: Apply only when visibility state actually changes to avoid taint churn.
		if vis and header.__lastVis ~= vis then
			RegisterStateDriver(header, "visibility", vis)
			header.__lastVis = vis
		end
	end
end

-- Centralized 3D portrait alpha fix (handles model and optional border)
-- REASON: Centralized 3D portrait alpha fix to handle model and optional border/background.
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

	-- REASON: Ensure our border (if present) also ignores parent alpha and is driven manually.
	local border = portrait.KKUI_Border
	if border and border.SetIgnoreParentAlpha then
		border:SetIgnoreParentAlpha(true)
	end

	-- REASON: Also handle a potential portrait background.
	local background = portrait.KKUI_Background
	if background and background.SetIgnoreParentAlpha then
		background:SetIgnoreParentAlpha(true)
	end

	-- REASON: Cache base alphas so we can restore intended alpha when scale returns to 1.
	if border and not border.__baseAlpha and border.GetAlpha then
		border.__baseAlpha = border:GetAlpha() or 1
	end

	if background and not background.__baseAlpha then
		local baseAlpha
		if background.GetVertexColor then
			local _, _, _, a = background:GetVertexColor()
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
				-- SetModelAlpha every tick resets the 3D portrait visually — only push when changed.
				if p.SetModelAlpha and p.__lastModelAlpha ~= alpha then
					p.__lastModelAlpha = alpha
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
				local fb = p.__fallbackTexture
				if fb and fb:IsShown() and fb.SetAlpha then
					fb:SetAlpha(scale * (p.__baseAlpha or 1))
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

-- SECRET (12.0): oUF's stock portrait element filters events through Private.unitIsUnit,
-- whose result can itself be a secret boolean in instances. Update self.unit directly and
-- treat secret GUIDs as "changed" via Portrait.Override so the vendored oUF files stay untouched.
-- Mirrors stock oUF: availability is just connected + visible (no IsVisible/model-ready
-- gating, which caused the model to stick on the blank/"?" state after the initial spawn
-- ForceUpdate fired before the element was shown). Secret booleans fail open.
local function ReadPortraitAvailability(unit)
	local connected = UnitIsConnected(unit)
	if IsSecret(connected) then
		connected = true
	end

	local visible = UnitIsVisible(unit)
	if IsSecret(visible) then
		visible = true
	end

	return connected and visible
end

-- Midnight (12.0.5+): PlayerModel:SetUnit requires declassified identity. Instance NPCs
-- (target/focus/boss) are secret, so SetUnit fails silently and leaves a black box.
-- SetPortraitTexture still works; overlay a 2D fallback on the PlayerModel frame.
local function EnsurePortraitFallback(element)
	if not element.__fallbackTexture then
		local tex = element:CreateTexture(nil, "OVERLAY", nil, 7)
		tex:SetAllPoints(element)
		tex:SetTexCoord(0.15, 0.85, 0.15, 0.85)
		element.__fallbackTexture = tex
	end
	return element.__fallbackTexture
end

-- textureOnly: already on the 2D overlay — just swap the portrait art.
-- Calling ClearModel here on every UNIT_PORTRAIT_UPDATE is what made ToT blink.
local function ShowPortrait2DFallback(element, unit, textureOnly)
	if not textureOnly then
		element:ClearModel()
	end
	local tex = EnsurePortraitFallback(element)
	SetPortraitTexture(tex, unit)
	K.UnsnapPortraitTexture(tex)
	tex:Show()
	element.__usingFallback = true
end

local function HidePortrait2DFallback(element)
	local tex = element.__fallbackTexture
	if tex then
		tex:Hide()
	end
	element.__usingFallback = nil
end

local function ShouldUse2DFallback(element, unit, isAvailable)
	if not isAvailable then
		return false
	end
	if K.IsSecretUnit(unit) then
		return true
	end
	local guid = UnitGUID(unit)
	if guid and element.__fallbackGUID and element.__fallbackGUID == guid then
		return true
	end
	return false
end

-- 3D PlayerModel only needs a full ClearModel/SetUnit on these. UNIT_PORTRAIT_UPDATE and
-- PORTRAITS_UPDATED spam on targettarget and would reload the model every few frames.
local PORTRAIT_MODEL_RELOAD = {
	ForceUpdate = true,
	UNIT_MODEL_CHANGED = true,
	UNIT_CONNECTION = true,
	PARTY_MEMBER_ENABLE = true,
	PARTY_MEMBER_DISABLE = true,
}

function Module.PortraitOverride(self, event)
	local element = self.Portrait
	local unit = self.unit
	if not element or not unit then
		return
	end

	-- Incident (ToT portrait, Jul 2026): `newGUID = secretGUID or …` made every update a
	-- "GUID change" while identity was restricted, so ClearModel/SetUnit ran on a loop.
	-- Mirror stock oUF: skip GUID compares when either side is secret; track secret↔plain
	-- transitions so we still reload once when restrictions flip.
	local guid = UnitGUID(unit)
	local secretGUID = IsSecret(guid)
	local newGUID
	if secretGUID then
		newGUID = not element.__guidWasSecret
		element.__guidWasSecret = true
		element.guid = nil
		if newGUID then
			element.__fallbackGUID = nil
		end
	else
		newGUID = element.__guidWasSecret or element.guid ~= guid
		element.__guidWasSecret = nil
		if newGUID then
			element.guid = guid
			element.__fallbackGUID = nil
		end
	end

	if element.PreUpdate then
		element:PreUpdate(unit)
	end

	local isAvailable = ReadPortraitAvailability(unit)
	local use2DFallback = ShouldUse2DFallback(element, unit, isAvailable)
	local availabilityChanged = element.state ~= isAvailable
	local fallbackChanged = (not not element.__usingFallback) ~= use2DFallback
	local isPlayerModel = element:IsObjectType("PlayerModel")

	local hasStateChanged
	if isPlayerModel then
		hasStateChanged = newGUID or availabilityChanged or fallbackChanged or PORTRAIT_MODEL_RELOAD[event]
	else
		hasStateChanged = newGUID or availabilityChanged or event ~= "OnUpdate"
	end

	if hasStateChanged then
		if isPlayerModel then
			if not isAvailable then
				HidePortrait2DFallback(element)
				element:ClearModel()
				element:SetCamDistanceScale(0.25)
				element:SetPortraitZoom(0)
				element:SetPosition(0, 0, 0.25)
				element:SetModel([[Interface\Buttons\TalkToMeQuestionMark.m2]])
			elseif use2DFallback then
				ShowPortrait2DFallback(element, unit)
			else
				HidePortrait2DFallback(element)
				element:ClearModel()
				element:SetCamDistanceScale(1)
				element:SetPortraitZoom(1)
				element:SetPosition(0, 0, 0)

				local success = element:SetUnit(unit)
				if not success then
					local unitGUID = UnitGUID(unit)
					element.__fallbackGUID = NotSecret(unitGUID) and unitGUID or "secret"
					ShowPortrait2DFallback(element, unit)
				end
			end
		else
			if not isAvailable then
				element:SetTexture([[Interface\Icons\INV_Misc_QuestionMark]])
			else
				local class, _
				if element.showClass then
					_, class = UnitClass(unit)
					if IsSecret(class) then
						class = nil
					end
				end

				if class then
					element:SetAtlas("classicon-" .. class)
				else
					SetPortraitTexture(element, unit)
					K.UnsnapPortraitTexture(element)
				end
			end
		end

		element.state = isAvailable
	end

	-- Same unit, new Blizzard portrait art — refresh the 2D overlay only (no ClearModel).
	if element.__usingFallback and isAvailable and (
		event == "UNIT_PORTRAIT_UPDATE"
		or event == "PORTRAITS_UPDATED"
		or event == "UNIT_MODEL_CHANGED"
	) then
		ShowPortrait2DFallback(element, unit, true)
	end

	if element.PostUpdate then
		return element:PostUpdate(unit, hasStateChanged)
	end
end

-- REASON: Installs the secret-safe portrait override on a spawned frame (any portrait type).
function Module:SecurePortrait(frame)
	if frame and frame.Portrait then
		frame.Portrait.Override = Module.PortraitOverride
		local portrait = frame.Portrait
		if portrait.IsObjectType and portrait:IsObjectType("PlayerModel") then
			local userPostUpdate = portrait.PostUpdate
			portrait.PostUpdate = function(element, unit, hasStateChanged)
				-- SetUnit resets camera distance; re-apply only right after an
				-- actual model change (hasStateChanged), not on every OnUpdate tick.
				-- BUGFIX: this previously ran unconditionally on every PostUpdate call.
				-- PortraitOverride fires on every OnUpdate (every frame), so this was
				-- forcing the camera back to distance/zoom 1 every single frame even when
				-- nothing changed — visible as flicker/stutter on 3D PlayerModel portraits
				-- (style 5), most noticeable on frequently-refreshing frames like Target
				-- of Target. SetUnit() (the actual cause of the camera reset) is only
				-- ever called when hasStateChanged is true, so gating on it here exactly
				-- matches when reapplication is actually needed.
				if hasStateChanged and element:IsShown() and not element.__usingFallback then
					if element.SetCamDistanceScale then
						element:SetCamDistanceScale(1)
					end
					if element.SetPortraitZoom and element.state then
						element:SetPortraitZoom(1)
					end
				end
				if userPostUpdate then
					return userPostUpdate(element, unit, hasStateChanged)
				end
			end
		end
	end
	Module:SecureHealth(frame)
end

local function isPlayerOrPartyAI(unit)
	local isPlayer = UnitIsPlayer(unit)
	if NotSecret(isPlayer) and isPlayer then
		return true
	end
	local isAI = UnitInPartyIsAI(unit)
	return NotSecret(isAI) and isAI or false
end

-- Midnight (12.0): stock oUF Health.UpdateColor compares UnitIsPlayer / UnitReaction
-- directly; secret booleans error in instances. Gate secret unit colors before painting.
function Module.HealthColorOverride(self, event, unit)
	if not unit or self.unit ~= unit then
		return
	end

	local element = self.Health
	if not element then
		return
	end

	local colors = self.colors
	local color
	local connected = UnitIsConnected(unit)

	if element.colorDisconnected and NotSecret(connected) and not connected then
		color = colors.disconnected
	else
		local controlled = UnitPlayerControlled(unit)
		local tapped = UnitIsTapDenied(unit)
		if element.colorTapping and NotSecret(controlled) and not controlled and NotSecret(tapped) and tapped then
			color = colors.tapped
		else
			local threat
			if element.colorThreat and NotSecret(controlled) and not controlled then
				threat = UnitThreatSituation("player", unit)
			end
			if element.colorThreat and NotSecret(controlled) and not controlled and NotSecret(threat) and threat then
				color = colors.threat[threat]
			elseif element.colorClass and isPlayerOrPartyAI(unit)
				or (element.colorClassNPC and not isPlayerOrPartyAI(unit))
				or (element.colorClassPet and NotSecret(controlled) and controlled and not (NotSecret(UnitIsPlayer(unit)) and UnitIsPlayer(unit)))
			then
				local _, class = UnitClass(unit)
				if NotSecret(class) and class then
					color = colors.class[class]
				end
			elseif element.colorSelection then
				local selection = safeUnitSelectionType(unit, element.considerSelectionInCombatHostile)
				if selection then
					color = colors.selection[selection]
				end
			elseif element.colorReaction then
				if not isPlayerOrPartyAI(unit) then
					local nr, ng, nb = K.GetNpcReactionColor(unit)
					if nr then
						element:SetStatusBarColor(nr, ng, nb)
						if element.PostUpdateColor then
							element:PostUpdateColor(unit, nil)
						end
						return
					end
					local reaction = UnitReaction(unit, "player")
					if NotSecret(reaction) and reaction then
						color = colors.reaction[reaction]
					end
				end
			elseif element.colorSmooth and colors.health and colors.health.GetCurve then
				local curve = colors.health:GetCurve()
				if curve then
					if UnitHealthPercent then
						local smoothColor = UnitHealthPercent(unit, true, curve)
						if smoothColor and smoothColor.GetRGB then
							element:SetStatusBarColor(smoothColor:GetRGB())
							if element.PostUpdateColor then
								element:PostUpdateColor(unit, smoothColor)
							end
							return
						end
					elseif element.values then
						local smoothColor = element.values:EvaluateCurrentHealthPercent(curve)
						if smoothColor and smoothColor.GetRGB then
							element:SetStatusBarColor(smoothColor:GetRGB())
							if element.PostUpdateColor then
								element:PostUpdateColor(unit, smoothColor)
							end
							return
						end
					end
				end
			elseif element.colorHealth then
				color = colors.health
			end
		end
	end

	if color and color.GetRGB then
		element:SetStatusBarColor(color:GetRGB())
	end

	if element.PostUpdateColor then
		element:PostUpdateColor(unit, color)
	end
end

function Module:SecureHealth(frame)
	if frame and frame.Health and frame.Health.UpdateColor ~= Module.HealthColorOverride then
		frame.Health.UpdateColor = Module.HealthColorOverride
	end
	Module:SecurePower(frame)
end

-- Midnight (12.0): stock oUF Power.UpdateColor — same secret pitfalls as health.
function Module.PowerColorOverride(self, event, unit)
	if not unit or self.unit ~= unit then
		return
	end

	local element = self.Power
	if not element then
		return
	end

	local colors = self.colors
	local color
	local atlas
	local r, g, b
	local connected = UnitIsConnected(unit)

	if element.colorDisconnected and NotSecret(connected) and not connected then
		color = colors.disconnected
	else
		local controlled = UnitPlayerControlled(unit)
		local tapped = UnitIsTapDenied(unit)
		if element.colorTapping and NotSecret(controlled) and not controlled and NotSecret(tapped) and tapped then
			color = colors.tapped
		else
			local threat
			if element.colorThreat and NotSecret(controlled) and not controlled then
				threat = UnitThreatSituation("player", unit)
			end
			if element.colorThreat and NotSecret(controlled) and not controlled and NotSecret(threat) and threat then
				color = colors.threat[threat]
			elseif element.colorPower then
				if element.displayType then
					color = colors.power[element.displayType]
				end

				if not color then
					local pType, pToken, altR, altG, altB = UnitPowerType(unit)
					if NotSecret(pToken) and pToken then
						color = colors.power[pToken]
					end

					if not color and NotSecret(altR) and altR then
						r, g, b = altR, altG, altB
						if r > 1 or g > 1 or b > 1 then
							r, g, b = r / 255, g / 255, b / 255
						end
					elseif NotSecret(pType) and pType then
						color = colors.power[pType] or colors.power.MANA
					end
				end

				if element.colorPowerAtlas and color and color.GetAtlas then
					atlas = color:GetAtlas()
				end

				if element.colorPowerSmooth and color and color.GetCurve then
					local curve = color:GetCurve()
					if curve and UnitPowerPercent then
						local smoothColor = UnitPowerPercent(unit, nil, true, curve)
						if smoothColor and smoothColor.GetRGB then
							color = smoothColor
						end
					end
				end
			elseif element.colorClass and isPlayerOrPartyAI(unit)
				or (element.colorClassNPC and not isPlayerOrPartyAI(unit))
				or (element.colorClassPet and NotSecret(controlled) and controlled and not (NotSecret(UnitIsPlayer(unit)) and UnitIsPlayer(unit)))
			then
				local _, class = UnitClass(unit)
				if NotSecret(class) and class then
					color = colors.class[class]
				end
			elseif element.colorSelection then
				local selection = safeUnitSelectionType(unit, element.considerSelectionInCombatHostile)
				if selection then
					color = colors.selection[selection]
				end
			elseif element.colorReaction then
				if not isPlayerOrPartyAI(unit) then
					local nr, ng, nb = K.GetNpcReactionColor(unit)
					if nr then
						element:SetStatusBarColor(nr, ng, nb)
						if element.PostUpdateColor then
							element:PostUpdateColor(unit, nil, nr, ng, nb)
						end
						return
					end
					local reaction = UnitReaction(unit, "player")
					if NotSecret(reaction) and reaction then
						color = colors.reaction[reaction]
					end
				end
			end
		end
	end

	if atlas then
		element:SetStatusBarTexture(atlas)
		element:SetStatusBarColor(1, 1, 1)
	else
		if element.__texture then
			element:SetStatusBarTexture(element.__texture)
		end

		if b then
			element:SetStatusBarColor(r, g, b)
		elseif color and color.GetRGB then
			element:SetStatusBarColor(color:GetRGB())
		end
	end

	if element.PostUpdateColor then
		element:PostUpdateColor(unit, color, r, g, b)
	end
end

function Module:SecurePower(frame)
	if frame and frame.Power and frame.Power.UpdateColor ~= Module.PowerColorOverride then
		frame.Power.UpdateColor = Module.PowerColorOverride
	end
end

-- Midnight (12.0): Blizzard-controlled private aura anchors on player/target.
function Module:CreatePrivateAuras(frame, opts)
	if not (C_UnitAuras and C_UnitAuras.AddPrivateAuraAnchor) then
		return
	end
	if C["Unitframe"].PrivateAuras == false then
		return
	end

	opts = opts or {}
	local element = CreateFrame("Frame", nil, frame)
	element:SetSize(opts.width or 72, opts.height or 24)
	element:SetPoint(
		opts.point or "TOPLEFT",
		opts.relativeTo or frame.Health,
		opts.relativePoint or "BOTTOMLEFT",
		opts.x or 0,
		opts.y or -4
	)
	element.size = opts.size or 20
	element.num = opts.num or 6
	element.spacing = opts.spacing or 2
	element.initialAnchor = opts.initialAnchor or "BOTTOMLEFT"
	element.growthX = opts.growthX or "RIGHT"
	element.growthY = opts.growthY or "UP"
	frame.PrivateAuras = element
end

-- REASON: Updates class-specific portrait textures based on configuration.
function Module:UpdateClassPortraits(unit)
	if C["Unitframe"].PortraitStyle == 0 or not unit then
		return
	end

	local isPlayer = UnitIsPlayer(unit)
	if IsSecret(isPlayer) or not isPlayer then
		-- Class atlases on NPCs look like garbage — face portrait instead.
		SetPortraitTexture(self, unit)
		K.UnsnapPortraitTexture(self)
		return
	end

	local _, unitClass = UnitClass(unit)
	if IsSecret(unitClass) or not unitClass then
		SetPortraitTexture(self, unit)
		K.UnsnapPortraitTexture(self)
		return
	end

	local portraitStyle = C["Unitframe"].PortraitStyle
	local classTCoords = CLASS_ICON_TCOORDS[unitClass]

	local texturePath
	if portraitStyle == 2 then
		texturePath = "Interface\\AddOns\\KkthnxUI\\Media\\Unitframes\\OLD-ICONS-CLASSES"
	elseif portraitStyle == 3 then
		texturePath = "Interface\\AddOns\\KkthnxUI\\Media\\Unitframes\\NEW-ICONS-CLASSES"
	end

	self:SetTexture(texturePath or "Interface\\TargetingFrame\\UI-Classes-Circles")
	if classTCoords then
		self:SetTexCoord(classTCoords[1], classTCoords[2], classTCoords[3], classTCoords[4])
	else
		self:SetTexCoord(0.15, 0.85, 0.15, 0.85)
	end
	K.UnsnapPortraitTexture(self)
end

-- REASON: Updates PvP status indicators for units.
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

-- REASON: Updates the leader indicator based on group status and instance type.
function Module.PostUpdateLeaderIndicator(element, isLeader, isInLFGInstance)
	if isLeader then
		if isInLFGInstance then
			element:SetAtlas("Ping_Chat_Assist")
		else
			element:SetTexture([[Interface\GroupFrame\UI-Group-LeaderIcon]])
		end
	end
end

-- REASON: Updates unit border colors based on threat status.
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
	-- REASON: Some styles may not build the expected border object; avoid nil errors.
	if not borderObject then
		return
	end

	-- REASON: Guard oUF threat table access.
	if status and status > 1 and oUF and oUF.colors and oUF.colors.threat and oUF.colors.threat[status] then
		-- MIDNIGHT (12.0): oUF's colors.threat[i] are ColorMixin objects created via
		-- oUF:CreateColor(GetThreatStatusColor(i)) and no longer carry numeric [1]/[2]/[3]
		-- indices, so unpack() returned nils and SetVertexColor errored. Read via GetRGB.
		local color = oUF.colors.threat[status]
		local r, g, b
		if color.GetRGB then
			r, g, b = color:GetRGB()
		else
			r, g, b = color[1], color[2], color[3]
		end
		if r then
			borderObject:SetVertexColor(r, g, b)
		else
			K.SetBorderColor(borderObject)
		end
	else
		K.SetBorderColor(borderObject)
	end
end

-- REASON: Updates the phase icon texture coordinates based on phasing status.
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
function Module.PLAYER_FOCUS_CHANGED(event)
	CreateTargetSound(nil, "focus")
end

function Module.PLAYER_TARGET_CHANGED(event)
	CreateTargetSound(nil, "target")
end

function Module.UNIT_FACTION(event, unit)
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
function Module:PostUpdatePrediction(unit)
	if not showOverAbsorb then
		if self.overAbsorbBar then
			self.overAbsorbBar:Hide()
		end
		return
	end

	local values = self.values
	if not values then
		return
	end

	local maxHealth = values:GetMaximumHealth()
	local health = values:GetCurrentHealth()
	local allIncomingHeal = select(1, values:GetIncomingHeals())
	local allAbsorb = select(1, values:GetDamageAbsorbs())

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
-- REASON: Handles OnEnter event for unit frames to show highlights and tooltips.
local function UF_OnEnter(self)
	if not self.disableTooltip then
		_G.UnitFrame_OnEnter(self)
	end
	self.Highlight:Show()
end

-- REASON: Handles OnLeave event for unit frames to hide highlights and tooltips.
local function UF_OnLeave(self)
	if not self.disableTooltip then
		_G.UnitFrame_OnLeave(self)
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

-- REASON: Toggles castbar latency tracking for the player frame.
function Module:ToggleCastBarLatency(frame)
	frame = frame or _G.oUF_Player
	if not frame then
		return
	end

	if C["Unitframe"].CastbarLatency then
		frame:RegisterEvent("GLOBAL_MOUSE_UP", Module.OnCastSent, true) -- REASON: Fix quests with WorldFrame interaction.
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

-- REASON: Updates the size and height of an aura container based on width and icons per row.
function Module:UpdateAuraContainer(width, element, maxAuras)
	-- SECRET (12.0): width comes from a parent:GetWidth() that can be secret on
	-- restricted nameplates. Bail out of the layout math rather than throwing, but
	-- still guarantee a column count exists so oUF's SetPosition never reads
	-- element:GetWidth(). Fall back to a single row (maxAuras columns).
	if IsSecret(width) then
		if not element.maxCols then
			element.maxCols = (maxAuras and maxAuras > 0) and maxAuras or 1
		end
		return
	end

	local iconsPerRow = element.iconsPerRow
	local spacing = element.spacing or 0

	-- REASON: When iconsPerRow is set we auto-calc the size, otherwise use element.size.
	local size = iconsPerRow and Module.auraIconSize(width, iconsPerRow, spacing) or element.size

	-- REASON: Need CEIL, not ROUND, or the container can be too short and clip last row.
	local maxLines = iconsPerRow and math_ceil((maxAuras or 0) / iconsPerRow) or 2
	if maxLines < 1 then
		maxLines = 1
	end

	local newH = (size + spacing) * maxLines

	-- SECRET (12.0): pin the column count so oUF's SetPosition never has to read
	-- element:GetWidth() -- that value becomes secret on restricted nameplates and
	-- crashes its width-based arithmetic. Cap columns so width math stays plain.
	local sizeX = (size or 0) + spacing
	if iconsPerRow then
		element.maxCols = iconsPerRow
	elseif sizeX > 0 and width > 0 then
		local cols = math_floor(width / sizeX + 0.5)
		element.maxCols = cols > 0 and cols or 1
	end

	-- REASON: Only apply changes when something actually differs to reduce layout
	-- churn. Guard the GetWidth() read in case the element itself is restricted.
	local curWidth = element:GetWidth()
	local widthChanged = IsSecret(curWidth) or curWidth ~= width
	if element.size ~= size or widthChanged or element:GetHeight() ~= newH then
		element.size = size
		element:SetWidth(width)
		element:SetHeight(newH)
	end
end

-- Texture Cropping

-- REASON: Updates icon texture coordinates to maintain aspect ratio and crop cleanly.
function Module:UpdateIconTexCoord(width, height)
	-- REASON: This is hooked to SetSize; keep it safe + handle both aspect directions.
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

-- REASON: Main post-creation setup for aura buttons (Count, Cooldown, Icon, Styling).
function Module.PostCreateButton(element, button)
	local fontSize = element.fontSize or (element.size * 0.52)

	-- REASON: Parent overlay frame lets us raise text/indicators above icon/cooldown reliably.
	local parentFrame = CreateFrame("Frame", nil, button)
	parentFrame:SetAllPoints(button)
	parentFrame:SetFrameLevel(button:GetFrameLevel() + 3)

	-- COUNT TEXT (STACKS)
	button.Count = button.Count or K.CreateFontString(parentFrame, fontSize - 1, "", "OUTLINE", false, "BOTTOMRIGHT", 6, -3)

	-- COOLDOWN CONFIG (IF PRESENT)
	-- Countdown numbers: toggled in PostUpdateButton. Prefer engine FS when
	-- DurationObject is armed (secret-safe); hide numbers for Lua FormatTime fallback.
	if button.Cooldown then
		button.Cooldown.noOCC = true
		button.Cooldown.noCooldownCount = true -- OmniCC off — we use Blizzard or button.timer
		button.Cooldown:SetReverse(true)
		button.Cooldown:SetHideCountdownNumbers(true)
	end

	-- ICON BASELINE
	if button.Icon then
		button.Icon:SetAllPoints()
		button.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	end

	-- NAMEPLATE VS UNITFRAME STYLING
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

	-- REASON: Keep Blizzard dispel overlay when showDebuffType is enabled (nameplates).
	if button.Overlay and not element.showDebuffType then
		button.Overlay:SetTexture(nil)
	end

	-- STEALABLE INDICATOR (OPTIONAL)
	if button.Stealable then
		button.Stealable:SetParent(parentFrame)
		button.Stealable:SetAtlas("bags-newitem")
		button.Stealable:Hide() -- REASON: Prevent "sticky" display between reused buttons.
	end

	-- TIMER TEXT (DURATION) — OUTLINE, no shadow (readable on busy icons).
	if not button.timer then
		button.timer = K.CreateFontString(parentFrame, fontSize, "", "OUTLINE")
	end

	-- REASON: Keep texcoords correct when size changes.
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

-- REASON: Main post-update logic for aura buttons (Colors, Stealable, Icons).
function Module.PostUpdateButton(element, button, unit, data)
	local duration = data.duration
	local expiration = data.expirationTime
	local debuffType = data.dispelName
	local isStealableRaw = data.isStealable
	local auraInstanceID = data.auraInstanceID
	-- SECRET (12.0): the raw isHarmful field is secret and oUF never copies it onto the
	-- button; use the safe derived data.isHarmfulAura (true for a debuff, nil for a buff).
	local buttonIsHarmful = data.isHarmfulAura
	local isPlayerAura = data.isPlayerAura
	if IsSecret(debuffType) then
		debuffType = nil
	end
	if IsSecret(buttonIsHarmful) then
		buttonIsHarmful = nil
	end
	if IsSecret(isPlayerAura) then
		isPlayerAura = false
	end

	local owner = element.__owner
	local style = owner and owner.mystyle

	-- REASON: Original code always set identical values; keep it simple.
	local size = element.size
	button:SetSize(size, size)

	-- DESATURATION RULES (HARMFUL + FILTEREDSTYLE + RAID BUFFS)
	if button.Icon then
		local desaturate = false
		if buttonIsHarmful == true and filteredStyle and filteredStyle[style] and not isPlayerAura then
			desaturate = true
		elseif element.IsRaid and buttonIsHarmful ~= true and C["Raid"].DesaturateBuffs and not isPlayerAura then
			desaturate = true
		end
		button.Icon:SetDesaturated(desaturate)
	end

	-- BORDER COLORING (DEBUFF TYPE)
	-- REASON: oUF nameplate buttons may use Shadow border; unitframes use KKUI_Border.
	if buttonIsHarmful == true then
		local r, g, b = K.GetAuraDispelBorderRGB(unit, auraInstanceID, oUF)
		if not r and debuffType and oUF and oUF.colors and oUF.colors.debuff then
			local color = oUF.colors.debuff[debuffType] or oUF.colors.debuff.none
			if color then
				if color.GetRGB then
					r, g, b = color:GetRGB()
				elseif color[1] then
					r, g, b = color[1], color[2], color[3]
				end
			end
		end

		if r then
			if style == "nameplate" then
				if button.Shadow and button.Shadow.SetBackdropBorderColor then
					button.Shadow:SetBackdropBorderColor(r, g, b, 0.8)
				end
			else
				if button.KKUI_Border and button.KKUI_Border.SetVertexColor then
					button.KKUI_Border:SetVertexColor(r, g, b)
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

	-- STEALABLE INDICATOR
	-- REASON: Must explicitly hide when not applicable or it can "stick" on reused buttons.
	if button.Stealable then
		local canSteal = not UnitIsPlayer(unit) and buttonIsHarmful == false
		if canSteal then
			if IsSecret(isStealableRaw) and button.Stealable.SetAlphaFromBoolean then
				button.Stealable:SetAlphaFromBoolean(isStealableRaw, 1, 0)
			elseif isStealableRaw or (debuffType and dispellType[debuffType]) then
				button.Stealable:Show()
			else
				button.Stealable:Hide()
			end
		else
			button.Stealable:Hide()
		end
	end

	-- COOLDOWN / TIMER
	-- Prefer DurationObject + GetCountdownFontString for secret-safe aura timers.
	-- Lua OnUpdate + button.timer only when duration fields are plain and GetAuraDuration fails.
	button:SetScript("OnUpdate", nil)

	local durObj
	if button.Cooldown and auraInstanceID and C_UnitAuras and C_UnitAuras.GetAuraDuration then
		durObj = C_UnitAuras.GetAuraDuration(unit, auraInstanceID)
	end

	if durObj and button.Cooldown then
		-- oUF already called SetCooldownFromDurationObject; arm mask + show engine countdown.
		K.ArmAuraCooldown(button.Cooldown, durObj, true)
		button.Cooldown:SetHideCountdownNumbers(false)
		local fontSize = element.fontSize or (size * 0.52)
		K.StyleAuraCooldownCountdown(button.Cooldown, fontSize, button, "CENTER", 1, 0)
		if button.timer then
			button.timer:Hide()
			button.timer:SetText("")
		end
	elseif not IsSecret(duration) and not IsSecret(expiration) and duration and expiration and duration > 0 then
		if button.Cooldown then
			button.Cooldown:SetHideCountdownNumbers(true)
			-- oUF hid the frame when GetAuraDuration was nil — restore classic swipe.
			if button.Cooldown.SetCooldown then
				button.Cooldown:SetCooldown(expiration - duration, duration)
				button.Cooldown:Show()
			end
		end
		button.expiration = expiration
		button:SetScript("OnUpdate", K.CooldownOnUpdate)
		if button.timer then
			button.timer:Show()
		end
	else
		if button.Cooldown then
			button.Cooldown:SetHideCountdownNumbers(true)
		end
		if button.timer then
			button.timer:Hide()
			button.timer:SetText("")
		end
	end

	-- REPLACE ICON TEXTURE (IF DEFINED)
	-- REASON: ReplacedIcons uses spellID keys; data.spellId is the reliable source.
	local spellID = data.spellId
	local newTexture
	if not IsSecret(spellID) and spellID then
		newTexture = Module.ReplacedSpellIcons[spellID]
	end
	if newTexture and button.Icon then
		button.Icon:SetTexture(newTexture)
	end

	-- BOLSTER STACKS DISPLAY (IF THIS IS THE CHOSEN BOLSTER AURA)
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
			local spellID = data and data.spellId
			if not IsSecret(spellID) and spellID == 209859 then
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
end

--========================================================--
-- Custom Filter
--========================================================--

-- REASON: Custom aura filter logic for nameplates, unitframes, boss, and arena frames.
function Module.CustomFilter(element, unit, data)
	local owner = element.__owner
	local style = owner and owner.mystyle

	local name = data.name
	local debuffType = data.dispelName
	local isStealableRaw = data.isStealable
	local spellID = data.spellId
	local nameplateShowAll = data.nameplateShowAll
	-- SECRET (12.0): oUF derives the safe flags isPlayerAura / isHarmfulAura because
	-- the raw isPlayerAura/isHarmful fields are secret. isHarmfulAura is `true` for a
	-- debuff and `nil` for a buff (never `false`), so test it with `not`, not `== false`.
	local isPlayerAura = data.isPlayerAura
	local isHarmful = data.isHarmfulAura
	local isStealable = K.BooleanIsTrue(isStealableRaw)

	if IsSecret(name) then
		name = nil
	end
	if IsSecret(debuffType) then
		debuffType = nil
	end
	if IsSecret(spellID) then
		spellID = nil
	end
	if IsSecret(nameplateShowAll) then
		nameplateShowAll = false
	end
	if IsSecret(isPlayerAura) then
		isPlayerAura = false
	end
	if IsSecret(isHarmful) then
		isHarmful = nil
	end

	local showDebuffType = C["Unitframe"].OnlyShowPlayerDebuff

	-- Shared blacklist for every style that shares the nameplate list.
	if spellID and C.NameplateBlackList[spellID] then
		return false
	end

	-- NAMEPLATES / BOSS / ARENA FILTERING RULES
	if style == "nameplate" or style == "boss" or style == "arena" then
		-- PASS ALL BOLSTER
		-- REASON: Explicitly want bolster visible for stack aggregation.
		if spellID == 209859 then
			return true
		end

		-- NAMEONLY PLATES USE WHITELIST ONLY
		-- REASON: Reduce clutter on name-only plates.
		if owner and owner.plateType == "NameOnly" then
			return spellID and C.NameplateWhiteList[spellID] == true
		end

		-- DISPELL/STEAL SHOW
		-- REASON: Highlight purgeable buffs on enemies (not player units).
		if (isStealable or (debuffType and dispellType[debuffType])) and not UnitIsPlayer(unit) and not isHarmful then
			return true
		end

		-- WHITELIST ALWAYS SHOWS
		if spellID and C.NameplateWhiteList[spellID] then
			return true
		end

		-- NAMEPLATES: normal player-aura mode should only show debuffs. Helpful
		-- buffs on enemies are handled above when explicitly whitelisted or
		-- purge/dispel-relevant; otherwise they clutter every plate in Midnight.
		if not isHarmful then
			return false
		end

		-- AURA FILTER MODES
		local auraFilter = C["Nameplate"].AuraFilter
		return (auraFilter == 3 and nameplateShowAll) or (auraFilter ~= 1 and isPlayerAura)
	end

	-- UNITFRAMES (target/focus/player/…): stealables always win; then player-only
	-- debuff gate; then any valid slot (secret name still OK via auraInstanceID).
	if not isHarmful and isStealable then
		return true
	end

	if showDebuffType and isHarmful then
		return isPlayerAura == true
	end

	if name ~= nil then
		return true
	end

	-- MIDNIGHT: aura name may be secret while the slot is still valid.
	return data.auraInstanceID ~= nil
end

-- REASON: Sync stagger tag text when oUF updates the bar fill/color.
function Module.PostUpdateStagger(element)
	if element.Value and element.Value.UpdateTag then
		element.Value:UpdateTag()
	end
end

-- REASON: Updates rune displays for Death Knights.
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
		if rune:IsShown() then
			local start, duration, runeReady = GetRuneCooldown(runeID)
			if IsSecret(start) or IsSecret(duration) or IsSecret(runeReady) then
				if not IsSecret(runeReady) and rune.SetAlphaFromBoolean then
					rune:SetAlphaFromBoolean(runeReady, 1, 0.6)
					if runeReady then
						rune:SetScript("OnUpdate", nil)
						if rune.timer then
							rune.timer:SetText(nil)
						end
					end
				end
			elseif runeReady then
				rune:SetAlpha(1)
				rune:SetScript("OnUpdate", nil)
				if rune.timer then
					rune.timer:SetText(nil)
				end
			elseif start then
				rune:SetAlpha(0.6)
				rune.duration = GetTime() - start
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

local VOID_METAMORPHOSIS_SPELL_ID = 1217607

local function getClassPowerColorRGB(element, powerType)
	local powerColors = element.__owner and element.__owner.colors and element.__owner.colors.power
	if not powerColors then
		return 1, 0, 0
	end

	local color = powerColors[powerType]
	if not color then
		return 1, 0, 0
	end

	-- Staged colors (e.g. SOUL_FRAGMENTS no-meta vs meta) use ColorMixin entries per stage.
	if powerType == "SOUL_FRAGMENTS" and type(color) == "table" and color[1] and color[1].GetRGB then
		local pick = color[1]
		if C_UnitAuras and C_UnitAuras.GetPlayerAuraBySpellID and C_UnitAuras.GetPlayerAuraBySpellID(VOID_METAMORPHOSIS_SPELL_ID) and color[2] then
			pick = color[2]
		end
		return pick:GetRGB()
	end

	if color.GetRGB then
		return color:GetRGB()
	end

	if type(color[1]) == "number" and color[2] and color[3] then
		return color[1], color[2], color[3]
	end

	return 1, 0, 0
end

local function applyBarColor(bar, color)
	if not bar or not color then
		return
	end

	if color.GetRGB then
		bar:SetStatusBarColor(color:GetRGB())
	elseif type(color[1]) == "number" and color[2] and color[3] then
		bar:SetStatusBarColor(color[1], color[2], color[3])
	end
end

-- GetUnitChargedPowerPoints returns an array of point indices (use tContains).
-- Indexing charged[i] as a boolean was wrong — Echoing Reprimand stars
-- never lit correctly. Elements can be secret under UnitPowerRestricted — only compare plain.
local function isChargedPowerPoint(chargedPowerPoints, index)
	if not chargedPowerPoints or IsSecret(chargedPowerPoints) then
		return false
	end

	for j = 1, #chargedPowerPoints do
		local pointIndex = chargedPowerPoints[j]
		if NotSecret(pointIndex) and pointIndex == index then
			return true
		end
	end

	return false
end

-- REASON: Updates class power displays (Combo points, runes, etc.) with special handling for Rogue/Druid combo points.
function Module.PostUpdateClassPower(element, cur, max, diff, powerType, chargedPowerPoints)
	local prevColor = element.prevColor
	local curReadable = cur and not IsSecret(cur)
	local maxReadable = max and not IsSecret(max)
	-- REASON: Special handling for combo points with graduated colors.
	if powerType == "COMBO_POINTS" then
		local comboColors = element.__owner.colors.power["COMBO_POINTS_GRADUATED"]
		if comboColors and curReadable and cur > 0 then
			-- REASON: Set individual colors for each active combo point bar.
			for i = 1, cur do
				local bar = element[i]
				if bar then
					local colorIndex = math_min(i, #comboColors)
					local color = comboColors[colorIndex]
					if color then
						applyBarColor(bar, color)
					else
						applyBarColor(bar, comboColors[1])
					end
				end
			end
			element.prevColor = cur
			-- Fall through: still need bar width + Echoing Reprimand charge stars.
		elseif curReadable and cur > 0 then
			-- Fallback when graduated colors table missing.
			local thisColor = (maxReadable and cur == max) and 1 or 2
			if not prevColor or prevColor ~= thisColor then
				local r, g, b = 1, 0, 0
				if thisColor == 2 then
					r, g, b = getClassPowerColorRGB(element, powerType)
				end
				SetStatusBarColor(element, r, g, b)
				element.prevColor = thisColor
			end
		end
	else
		-- Non-combo power types: full = red, otherwise class power color.
		if curReadable and cur > 0 then
			local thisColor = (maxReadable and cur == max) and 1 or 2
			if not prevColor or prevColor ~= thisColor then
				local r, g, b = 1, 0, 0
				if thisColor == 2 then
					r, g, b = getClassPowerColorRGB(element, powerType)
				end
				SetStatusBarColor(element, r, g, b)
				element.prevColor = thisColor
			end
		end
	end

	if diff and not IsSecret(diff) and maxReadable and max and element.__owner.ClassPowerBar then
		local totalWidth = element.__owner.ClassPowerBar:GetWidth()
		if totalWidth and not IsSecret(totalWidth) and totalWidth > 0 then
			local barWidth = (totalWidth - (max - 1) * 6) / max
			for i = 1, max do
				local bar = element[i]
				if bar then
					bar:SetWidth(barWidth)
				end
			end
		end
	end

	-- Max can be 10 (Maelstrom Weapon); only iterate existing charge-star bars.
	for i = 1, #element do
		local bar = element[i]
		if not bar.chargeStar then
			break
		end

		bar.chargeStar:SetShown(isChargedPowerPoint(chargedPowerPoints, i))
	end
end

-- REASON: Creates the class power bar for player frames and nameplates.
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
	-- Capacity 10: Maelstrom Weapon stacks to 10; combo/chi/essence stay ≤7.
	local maxBar = isDK and 6 or 10
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

-- REASON: Updates the text scale for all unit frame elements (Health, Power, Names, etc.).
function Module:UpdateTextScale()
	local scale = C["Unitframe"].AllTextScale
	for _, frame in ipairs(oUF.objects) do
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

local function ResizePrimaryFrame(frame, width, healthH, powerH)
	if not frame then
		return
	end

	frame:SetSize(width, healthH + powerH + 6)

	if frame.Health then
		frame.Health:SetHeight(healthH)
	end

	if frame.Power then
		frame.Power:SetHeight(powerH)
	end
end

local function RefreshAuraRows(frame, width, buffsPerRowKey, debuffsPerRowKey)
	local cfg = C["Unitframe"]

	if frame.Buffs and buffsPerRowKey then
		frame.Buffs.iconsPerRow = cfg[buffsPerRowKey]
		Module:UpdateAuraContainer(width, frame.Buffs, frame.Buffs.num)
		if frame.Buffs.ForceUpdate then
			frame.Buffs:ForceUpdate()
		end
	end

	if frame.Debuffs and debuffsPerRowKey then
		frame.Debuffs.iconsPerRow = cfg[debuffsPerRowKey]
		Module:UpdateAuraContainer(width, frame.Debuffs, frame.Debuffs.num)
		if frame.Debuffs.ForceUpdate then
			frame.Debuffs:ForceUpdate()
		end
	end
end

local function SyncUnitMover(frame, moverName)
	local mover = moverName and _G[moverName]
	if mover and mover.SetSize and frame then
		mover:SetSize(frame:GetWidth(), frame:GetHeight())
	end
end

-- REASON: Shared by UpdatePlayerSize/UpdateTargetSize/UpdateFocusSize — previously each
-- was a near-identical copy differing only by config-key prefix, frame global, and
-- mover name. buffsPerRowKey/debuffsPerRowKey are optional (Focus has no per-row aura
-- config, so it omits them and skips that step entirely, matching prior behavior).
local function UpdateCoreFrameSize(cfgPrefix, frameGlobal, moverName, buffsPerRowKey, debuffsPerRowKey)
	local cfg = C["Unitframe"]
	local width = cfg[cfgPrefix .. "HealthWidth"]
	local frame = _G[frameGlobal]

	ResizePrimaryFrame(frame, width, cfg[cfgPrefix .. "HealthHeight"], cfg[cfgPrefix .. "PowerHeight"])
	if buffsPerRowKey or debuffsPerRowKey then
		RefreshAuraRows(frame, width, buffsPerRowKey, debuffsPerRowKey)
	end
	SyncUnitMover(frame, moverName)
end

-- REASON: Shared by UpdatePlayerBuffs/UpdatePlayerDebuffs/UpdateTargetBuffs/
-- UpdateTargetDebuffs — previously four near-identical copies differing only by frame
-- global, aura element name (Buffs/Debuffs), and config keys.
local function RefreshFrameAuraRow(frameGlobal, auraKey, widthCfgKey, perRowCfgKey)
	local cfg = C["Unitframe"]
	local frame = _G[frameGlobal]
	local element = frame and frame[auraKey]
	if not element then
		return
	end

	element.iconsPerRow = cfg[perRowCfgKey]
	Module:UpdateAuraContainer(cfg[widthCfgKey], element, element.num)
	if element.ForceUpdate then
		element:ForceUpdate()
	end
end

function Module:UpdatePlayerSize()
	UpdateCoreFrameSize("Player", "oUF_Player", "PlayerUF", "PlayerBuffsPerRow", "PlayerDebuffsPerRow")
end

function Module:UpdatePlayerLevelVisibility()
	local frame = _G.oUF_Player
	if not frame or not frame.Level then
		return
	end

	local cfg = C["Unitframe"]
	if not cfg.ShowPlayerLevel then
		frame.Level:Hide()
		return
	end

	local style = cfg.PortraitStyle or 0
	if cfg.HideMaxPlayerLevel and IsLevelAtEffectiveMaxLevel(UnitLevel("player")) then
		frame.Level:Hide()
	elseif style == 0 or style == 4 then
		frame.Level:Hide()
	else
		frame.Level:Show()
	end
end

function Module:UpdateOptionalUnitLevels()
	local cfg = C["Unitframe"]
	local style = cfg.PortraitStyle or 0
	local hideForStyle = (style == 0 or style == 4)

	local function apply(frame, hideLevel)
		if not frame or not frame.Level then
			return
		end
		if hideForStyle or hideLevel then
			frame.Level:Hide()
		else
			frame.Level:Show()
		end
	end

	apply(_G.oUF_Pet, cfg.HidePetLevel)
	apply(_G.oUF_FocusTarget, cfg.HideFocusTargetLevel)
	apply(_G.oUF_ToT, cfg.HideTargetOfTargetLevel)
end

function Module:UpdatePlayerBuffs()
	RefreshFrameAuraRow("oUF_Player", "Buffs", "PlayerHealthWidth", "PlayerBuffsPerRow")
end

function Module:UpdatePlayerDebuffs()
	RefreshFrameAuraRow("oUF_Player", "Debuffs", "PlayerHealthWidth", "PlayerDebuffsPerRow")
end

function Module:UpdateTargetSize()
	UpdateCoreFrameSize("Target", "oUF_Target", "TargetUF", "TargetBuffsPerRow", "TargetDebuffsPerRow")
end

function Module:UpdateTargetBuffs()
	RefreshFrameAuraRow("oUF_Target", "Buffs", "TargetHealthWidth", "TargetBuffsPerRow")
end

function Module:UpdateTargetDebuffs()
	RefreshFrameAuraRow("oUF_Target", "Debuffs", "TargetHealthWidth", "TargetDebuffsPerRow")
end

function Module:UpdateFocusSize()
	-- REASON: Focus has no configurable per-row aura settings (nil buffsPerRowKey/
	-- debuffsPerRowKey), so UpdateCoreFrameSize skips the aura-row refresh step.
	UpdateCoreFrameSize("Focus", "oUF_Focus", "FocusUF")
end

function Module:UpdatePartySize()
	if not C["Party"].Enable or C["SimpleParty"].Enable then
		return
	end

	local width = C["Party"].HealthWidth
	local height = C["Party"].HealthHeight
	local powerH = C["Party"].PowerHeight
	local totalH = height + powerH + 6

	for _, header in ipairs(self.headers or {}) do
		if header.groupType == "party" and header.GetName and header:GetName() == "oUF_Party" then
			for i = 1, header:GetNumChildren() do
				local frame = select(i, header:GetChildren())
				if frame and frame.SetSize then
					frame:SetSize(width, totalH)
					if frame.Health then
						frame.Health:SetHeight(height)
					end
					if frame.Power then
						frame.Power:SetHeight(powerH)
					end
					if frame.Name then
						frame.Name:SetWidth(width)
					end
					if frame.Castbar then
						frame.Castbar:SetWidth(width)
					end
				end
			end
		end
	end
end

function Module:UpdateRaidSize()
	if not C["Raid"].Enable then
		return
	end

	local width = C["Raid"].Width
	local height = C["Raid"].Height

	for _, header in ipairs(self.headers or {}) do
		if header.groupType == "raid" then
			for i = 1, header:GetNumChildren() do
				local frame = select(i, header:GetChildren())
				if frame and frame.SetSize then
					frame:SetSize(width, height)
					if frame.RaidDebuffs then
						local debuffSize = (height >= 32) and (height - 20) or height
						frame.RaidDebuffs:SetSize(debuffSize, debuffSize)
					end
					if frame.UpdateRaidPower then
						local unit = frame.unit or (frame.GetAttribute and frame:GetAttribute("unit"))
						if unit then
							frame:UpdateRaidPower(nil, unit)
						end
					end
				end
			end
		end
	end
end

local function deferUntilRegen(pendingKey, registeredKey, deferredFn)
	if InCombatLockdown() then
		Module[pendingKey] = true
		if not Module[registeredKey] then
			Module[registeredKey] = true
			K:RegisterEvent("PLAYER_REGEN_ENABLED", deferredFn)
		end
		return true
	end

	if Module[pendingKey] then
		Module[pendingKey] = nil
		if Module[registeredKey] then
			Module[registeredKey] = nil
			K:UnregisterEvent("PLAYER_REGEN_ENABLED", deferredFn)
		end
	end

	return false
end

local function resizeArenaBossFrame(frame, width, healthHeight, powerHeight)
	if not frame or not frame.SetSize then
		return
	end

	local totalH = healthHeight + powerHeight + 6
	frame:SetSize(width, totalH)
	if frame.Health then
		frame.Health:SetHeight(healthHeight)
	end
	if frame.Power then
		frame.Power:SetHeight(powerHeight)
	end
	if frame.Castbar and frame.Castbar.SetWidth then
		frame.Castbar:SetWidth(width)
	end
	if frame.mover and frame.mover.SetSize then
		frame.mover:SetSize(width, totalH)
	end
end

function Module:UpdateArenaSize()
	if not C["Arena"].Enable then
		return
	end

	local cfg = C["Arena"]
	for i = 1, 5 do
		resizeArenaBossFrame(_G["oUF_Arena" .. i], cfg.HealthWidth, cfg.HealthHeight, cfg.PowerHeight)
	end
end

function Module:UpdateBossSize()
	if not C["Boss"].Enable then
		return
	end

	local cfg = C["Boss"]
	for i = 1, 10 do
		resizeArenaBossFrame(_G["oUF_Boss" .. i], cfg.HealthWidth, cfg.HealthHeight, cfg.PowerHeight)
	end
end

local function applyAuraTrackSettings(frame, cfg)
	if not frame or not frame.AuraTrack then
		return
	end

	local track = frame.AuraTrack
	track.Icons = cfg.AuraTrackIcons
	track.SpellTextures = cfg.AuraTrackSpellTextures
	track.Thickness = cfg.AuraTrackThickness

	track:ClearAllPoints()
	if track.Icons ~= true then
		track:SetPoint("TOPLEFT", frame.Health, "TOPLEFT", 2, -2)
		track:SetPoint("BOTTOMRIGHT", frame.Health, "BOTTOMRIGHT", -2, 2)
	else
		track:SetPoint("TOPLEFT", frame.Health, "TOPLEFT", -4, -6)
		track:SetPoint("BOTTOMRIGHT", frame.Health, "BOTTOMRIGHT", 4, 6)
	end

	if track.ForceUpdate then
		track:ForceUpdate()
	end
end

local function forEachHeaderChild(headers, groupType, callback)
	for _, header in ipairs(headers or {}) do
		if header.groupType == groupType then
			for i = 1, header:GetNumChildren() do
				callback(select(i, header:GetChildren()))
			end
		end
	end
end

local GRAY_HEALTH_COLOR = { 0.31, 0.31, 0.31 }

function Module:ApplyHealthbarColor(health, colorMode)
	if not health then
		return
	end

	if colorMode == 3 then
		health.colorSmooth = true
		health.colorClass = false
		health.colorReaction = false
	elseif colorMode == 2 then
		health.colorSmooth = false
		health.colorClass = false
		health.colorReaction = false
		health:SetStatusBarColor(GRAY_HEALTH_COLOR[1], GRAY_HEALTH_COLOR[2], GRAY_HEALTH_COLOR[3])
	else
		health.colorSmooth = false
		health.colorClass = true
		health.colorReaction = true
	end

	if health.ForceUpdate then
		health:ForceUpdate()
	end
end

function Module:ApplyHealthbarColorToFrame(frame, colorMode)
	if frame and frame.Health then
		self:ApplyHealthbarColor(frame.Health, colorMode)
	end
end

function Module:UpdateUnitframeHealthbarColor()
	local mode = C["Unitframe"].HealthbarColor
	local frames = {
		_G.oUF_Player,
		_G.oUF_Target,
		_G.oUF_Focus,
		_G.oUF_Pet,
		_G.oUF_ToT,
		_G.oUF_FocusTarget,
	}

	for i = 1, #frames do
		self:ApplyHealthbarColorToFrame(frames[i], mode)
	end
end

function Module:UpdateBossHealthbarColor()
	local mode = C["Boss"].HealthbarColor
	for i = 1, 10 do
		self:ApplyHealthbarColorToFrame(_G["oUF_Boss" .. i], mode)
	end
end

function Module:UpdateArenaHealthbarColor()
	local mode = C["Arena"].HealthbarColor
	for i = 1, 5 do
		self:ApplyHealthbarColorToFrame(_G["oUF_Arena" .. i], mode)
	end
end

function Module:UpdatePartyHealthbarColors()
	if C["SimpleParty"].Enable then
		return
	end

	local mode = C["Party"].HealthbarColor
	forEachHeaderChild(self.headers, "party", function(frame)
		Module:ApplyHealthbarColorToFrame(frame, mode)
	end)
	forEachHeaderChild(self.headers, "pet", function(frame)
		Module:ApplyHealthbarColorToFrame(frame, mode)
	end)
end

function Module:UpdateSimplePartyHealthbarColors()
	if not C["SimpleParty"].Enable then
		return
	end

	local mode = C["SimpleParty"].HealthbarColor
	forEachHeaderChild(self.headers, "party", function(frame)
		Module:ApplyHealthbarColorToFrame(frame, mode)
	end)
end

function Module:UpdateRaidHealthbarColors()
	local mode = C["Raid"].HealthbarColor
	forEachHeaderChild(self.headers, "raid", function(frame)
		Module:ApplyHealthbarColorToFrame(frame, mode)
	end)

	local tank = _G.oUF_MainTank
	if tank then
		for i = 1, tank:GetNumChildren() do
			self:ApplyHealthbarColorToFrame(select(i, tank:GetChildren()), mode)
		end
	end
end

local function setBarTexture(bar, texture)
	if bar and bar.SetStatusBarTexture then
		bar:SetStatusBarTexture(texture)
	end
end

local function applyTextureToFrame(frame, texture)
	if not frame then
		return
	end

	setBarTexture(frame.Health, texture)
	setBarTexture(frame.Power, texture)
	setBarTexture(frame.Castbar, texture)
	setBarTexture(frame.AdditionalPower, texture)
	setBarTexture(frame.Stagger, texture)

	local prediction = frame.HealthPrediction
	if prediction then
		setBarTexture(prediction.myBar, texture)
		setBarTexture(prediction.otherBar, texture)
		setBarTexture(prediction.absorbBar, texture)
		if prediction.damageAbsorbForward then
			setBarTexture(prediction.damageAbsorbForward, texture)
		end
		setBarTexture(prediction.overAbsorbBar, texture)
		setBarTexture(prediction.healAbsorbBar, texture)
		if prediction.absorbStrip then
			setBarTexture(prediction.absorbStrip, texture)
		end
		if prediction.healAbsorbStrip then
			setBarTexture(prediction.healAbsorbStrip, texture)
		end
	end

	local classPower = frame.ClassPower
	if classPower then
		for i = 1, #classPower do
			setBarTexture(classPower[i], texture)
		end
	end

	local runes = frame.Runes
	if runes then
		for i = 1, #runes do
			setBarTexture(runes[i], texture)
		end
	end
end

local function applySmoothToBar(bar, enabled)
	if not bar then
		return
	end

	if enabled then
		K:SmoothBar(bar)
	else
		K:DesmoothBar(bar)
	end
end

local function applySmoothToFrame(frame, enabled)
	if not frame then
		return
	end

	applySmoothToBar(frame.Health, enabled)
	applySmoothToBar(frame.Power, enabled)
	applySmoothToBar(frame.Castbar, enabled)
	applySmoothToBar(frame.AdditionalPower, enabled)

	local prediction = frame.HealthPrediction
	if prediction then
		applySmoothToBar(prediction.myBar, enabled)
		applySmoothToBar(prediction.otherBar, enabled)
		applySmoothToBar(prediction.absorbBar, enabled)
		if prediction.damageAbsorbForward then
			applySmoothToBar(prediction.damageAbsorbForward, enabled)
		end
		applySmoothToBar(prediction.overAbsorbBar, enabled)
		applySmoothToBar(prediction.healAbsorbBar, enabled)
		if prediction.absorbStrip then
			applySmoothToBar(prediction.absorbStrip, enabled)
		end
		if prediction.healAbsorbStrip then
			applySmoothToBar(prediction.healAbsorbStrip, enabled)
		end
	end
end

local function forEachUnitFrame(callback)
	local oUF = K.oUF
	if oUF and oUF.objects then
		for _, object in next, oUF.objects do
			callback(object)
		end
	end
end

function Module:UpdateStatusBarTextures()
	local texture = K.GetTexture(C["General"].Texture)

	forEachUnitFrame(function(frame)
		applyTextureToFrame(frame, texture)
	end)

	local playerCastbar = _G.oUF_Player and _G.oUF_Player.Castbar
	if playerCastbar and playerCastbar.Lag then
		playerCastbar.Lag:SetTexture(texture)
	end

	local player = _G.oUF_Player
	if player then
		if player.ClassPower then
			for i = 1, #player.ClassPower do
				setBarTexture(player.ClassPower[i], texture)
			end
		end
		if player.Runes then
			for i = 1, #player.Runes do
				setBarTexture(player.Runes[i], texture)
			end
		end
	end
end

function Module:UpdateUnitframeSmooth()
	local enabled = C["Unitframe"].Smooth
	local frames = {
		_G.oUF_Player,
		_G.oUF_Target,
		_G.oUF_Focus,
		_G.oUF_Pet,
		_G.oUF_ToT,
		_G.oUF_FocusTarget,
	}

	for i = 1, #frames do
		applySmoothToFrame(frames[i], enabled)
	end
end

function Module:UpdateBossSmooth()
	local enabled = C["Boss"].Smooth
	for i = 1, 10 do
		applySmoothToFrame(_G["oUF_Boss" .. i], enabled)
	end
end

function Module:UpdateArenaSmooth()
	local enabled = C["Arena"].Smooth
	for i = 1, 5 do
		applySmoothToFrame(_G["oUF_Arena" .. i], enabled)
	end
end

function Module:UpdatePartySmooth()
	if C["SimpleParty"].Enable then
		return
	end

	local enabled = C["Party"].Smooth
	forEachHeaderChild(self.headers, "party", function(frame)
		applySmoothToFrame(frame, enabled)
	end)
	forEachHeaderChild(self.headers, "pet", function(frame)
		applySmoothToFrame(frame, enabled)
	end)
end

function Module:UpdateSimplePartySmooth()
	if not C["SimpleParty"].Enable then
		return
	end

	local enabled = C["SimpleParty"].Smooth
	forEachHeaderChild(self.headers, "party", function(frame)
		applySmoothToFrame(frame, enabled)
	end)
end

function Module:UpdateRaidSmooth()
	local enabled = C["Raid"].Smooth
	forEachHeaderChild(self.headers, "raid", function(frame)
		applySmoothToFrame(frame, enabled)
	end)

	local tank = _G.oUF_MainTank
	if tank then
		for i = 1, tank:GetNumChildren() do
			applySmoothToFrame(select(i, tank:GetChildren()), enabled)
		end
	end
end

function Module:UpdateRaidAuraTrack()
	if not C["Raid"].Enable or C["Raid"].RaidBuffsStyle ~= 2 then
		return
	end

	local cfg = C["Raid"]
	forEachHeaderChild(self.headers, "raid", function(frame)
		applyAuraTrackSettings(frame, cfg)
	end)

	local tank = _G.oUF_MainTank
	if tank then
		for i = 1, tank:GetNumChildren() do
			applyAuraTrackSettings(select(i, tank:GetChildren()), cfg)
		end
	end
end

function Module:UpdateSimplePartyAuraTrack()
	if not C["Party"].Enable or not C["SimpleParty"].Enable or C["SimpleParty"].RaidBuffsStyle ~= 2 then
		return
	end

	forEachHeaderChild(self.headers, "party", function(frame)
		applyAuraTrackSettings(frame, C["SimpleParty"])
	end)
end

function Module:UpdateRaidHealthTags()
	local oUF = K.oUF
	if not oUF or not oUF.objects then
		return
	end

	for _, object in next, oUF.objects do
		local unit = object.unit
		if unit and (unit:match("^raid%d") or unit:match("^party%d")) then
			local value = object.Health and object.Health.Value
			if value and value.UpdateTag then
				value:UpdateTag()
			elseif object.UpdateTags then
				object:UpdateTags()
			end
		end
	end
end

local function refreshAuraElement(element)
	if element and element.ForceUpdate then
		element:ForceUpdate()
	end
end

function Module:UpdateRaidBuffAuras()
	forEachHeaderChild(self.headers, "raid", function(frame)
		refreshAuraElement(frame.Buffs)
	end)

	forEachHeaderChild(self.headers, "party", function(frame)
		refreshAuraElement(frame.Buffs)
	end)

	local tank = _G.oUF_MainTank
	if tank then
		for i = 1, tank:GetNumChildren() do
			refreshAuraElement(select(i, tank:GetChildren()).Buffs)
		end
	end
end

function Module:UpdateOnlyShowPlayerDebuffs()
	local onlyPlayer = C["Unitframe"].OnlyShowPlayerDebuff
	local frames = {
		_G.oUF_Player,
		_G.oUF_Target,
		_G.oUF_Focus,
	}

	for i = 1, 10 do
		frames[#frames + 1] = _G["oUF_Boss" .. i]
	end

	for i = 1, 5 do
		frames[#frames + 1] = _G["oUF_Arena" .. i]
	end

	for _, frame in ipairs(frames) do
		if frame and frame.Debuffs then
			frame.Debuffs.onlyShowPlayer = onlyPlayer
			refreshAuraElement(frame.Debuffs)
		end
	end
end

Module._DeferredUpdateSimplePartyOrientation = Module._DeferredUpdateSimplePartyOrientation or function()
	Module:UpdateSimplePartyOrientation()
end

function Module:UpdateSimplePartyOrientation()
	if deferUntilRegen("_pendingSimplePartyOrientation", "_pendingSimplePartyOrientationRegistered", Module._DeferredUpdateSimplePartyOrientation) then
		return
	end

	if not C["Party"].Enable or not C["SimpleParty"].Enable then
		return
	end

	local horizon = C["SimpleParty"].HorizonParty
	local width = C["SimpleParty"].HealthWidth or 70
	local height = C["SimpleParty"].HealthHeight or 44
	local header = self:GetPartyHeader("oUF_SimpleParty")

	if not header then
		return
	end

	header:SetAttribute("point", horizon and "LEFT" or "TOP")
	header:SetAttribute("xOffset", horizon and 6 or 0)
	header:SetAttribute("yOffset", horizon and 0 or -6)
	self:ResetHeaderPoints(header)

	local mover = _G.KKUI_Mover_SimplePartyFrame
	if mover and mover.SetSize then
		if horizon then
			mover:SetSize((width + 6) * 5, height)
		else
			mover:SetSize(width, (height + 6) * 5)
		end
	end

	if header:IsShown() then
		header:Hide()
		header:Show()
	end
end

Module._DeferredUpdateRaidLayout = Module._DeferredUpdateRaidLayout or function()
	Module:UpdateRaidLayout()
end

function Module:UpdateRaidLayout()
	if not C["Raid"].Enable then
		return
	end

	if deferUntilRegen("_pendingRaidLayout", "_pendingRaidLayoutRegistered", Module._DeferredUpdateRaidLayout) then
		return
	end

	local horizonRaid = C["Raid"].HorizonRaid
	local reverse = C["Raid"].ReverseRaid
	local showTeamIndex = C["Raid"].ShowTeamIndex
	local raidWidth, raidHeight = C["Raid"].Width, C["Raid"].Height
	local numGroups = C["Raid"].NumGroups
	local groups = {}

	for _, header in ipairs(self.headers or {}) do
		if header.groupType == "raid" and header.index then
			groups[header.index] = header
		end
	end

	local raidMover = _G.KKUI_Mover_RaidFrame
	if raidMover and raidMover.SetSize then
		if horizonRaid then
			raidMover:SetSize((raidWidth + 5) * 5, (raidHeight + (showTeamIndex and 15 or 5)) * numGroups)
		else
			raidMover:SetSize((raidWidth + 5) * numGroups, (raidHeight + 5) * 5)
		end
	end

	for i = 1, numGroups do
		local group = groups[i]
		if not group then
			break
		end

		group:SetAttribute("point", horizonRaid and "LEFT" or "TOP")
		self:ResetHeaderPoints(group)

		if i == 1 and raidMover then
			group:ClearAllPoints()
			if reverse then
				group:SetPoint(horizonRaid and "BOTTOMLEFT" or "TOPRIGHT", raidMover)
			else
				group:SetPoint("TOPLEFT", raidMover)
			end
		elseif groups[i - 1] then
			local prev = groups[i - 1]
			group:ClearAllPoints()
			if horizonRaid then
				if reverse then
					group:SetPoint("BOTTOMLEFT", prev, "TOPLEFT", 0, showTeamIndex and 18 or 6)
				else
					group:SetPoint("TOPLEFT", prev, "BOTTOMLEFT", 0, showTeamIndex and -18 or -6)
				end
			elseif reverse then
				group:SetPoint("TOPRIGHT", prev, "TOPLEFT", -6, 0)
			else
				group:SetPoint("TOPLEFT", prev, "TOPRIGHT", 6, 0)
			end
		end

		if group:IsShown() then
			group:Hide()
			group:Show()
		end
	end

	local tank = _G.oUF_MainTank
	if tank then
		tank:SetAttribute("point", horizonRaid and "LEFT" or "TOP")
		self:ResetHeaderPoints(tank)
	end
end

Module._DeferredUpdateSimplePartySize = Module._DeferredUpdateSimplePartySize or function()
	Module:UpdateSimplePartySize()
end

function Module:UpdateSimplePartyPowerBars()
	local oUF = K.oUF
	if not oUF then
		return
	end

	for _, object in next, oUF.objects do
		if object.unit and object.unit:match("^party%d") and object.UpdateSimplePartyPower then
			object:UpdateSimplePartyPower(nil, object.unit)
		end
	end
end

function Module:UpdateSimplePartyPowerHeight()
	local oUF = K.oUF
	if not oUF then
		return
	end

	local newHeight = C["SimpleParty"].PowerBarHeight

	for _, object in next, oUF.objects do
		if object.Power and object.unit and object.unit:match("^party%d") then
			object.Power:SetHeight(newHeight)
			if object.UpdateSimplePartyPower then
				object:UpdateSimplePartyPower(nil, object.unit)
			end
		end
	end
end

function Module:UpdateSimplePartySize()
	if deferUntilRegen("_pendingSimplePartySize", "_pendingSimplePartySizeRegistered", Module._DeferredUpdateSimplePartySize) then
		return
	end

	if not C["Party"].Enable or not C["SimpleParty"].Enable then
		return
	end

	local width = C["SimpleParty"].HealthWidth or 70
	local height = C["SimpleParty"].HealthHeight or 44
	local horizon = C["SimpleParty"].HorizonParty
	local header = self:GetPartyHeader("oUF_SimpleParty") or self:GetPartyHeader()

	if not header then
		return
	end

	for i = 1, header:GetNumChildren() do
		local frame = select(i, header:GetChildren())
		if frame and frame.SetSize then
			frame:SetSize(width, height)

			if frame.RaidDebuffs then
				local debuffSize = (height >= 32) and (height - 20) or height
				frame.RaidDebuffs:SetSize(debuffSize, debuffSize)
			end

			if frame.UpdateSimplePartyPower and (frame.unit or frame.GetAttribute) then
				local unit = frame.unit or (frame.GetAttribute and (frame:GetAttribute("oUF-guessUnit") or frame:GetAttribute("unit")))
				if unit then
					frame:UpdateSimplePartyPower(nil, unit)
				end
			end
		end
	end

	local mover = _G.KKUI_Mover_SimplePartyFrame
	if mover and mover.SetSize then
		if horizon then
			mover:SetSize((width + 6) * 5, height)
		else
			mover:SetSize(width, (height + 6) * 5)
		end
	end
end

Module._DeferredRebuildPartyFrames = Module._DeferredRebuildPartyFrames or function()
	Module:RebuildPartyFrames()
end

-- Forward-declare: SpawnPartyFrames calls this before the body is assigned below.
-- Incident (UF Core, Jul 2026): local function after SpawnPartyFrames made the call a nil global.
local DisableBlizzardRaidFrames

function Module:RebuildPartyFrames()
	if deferUntilRegen("_pendingPartyRebuild", "_pendingPartyRebuildRegistered", Module._DeferredRebuildPartyFrames) then
		return
	end

	removeHeadersByGroupType(self.headers, "party")
	removeHeadersByGroupType(self.headers, "pet")

	if C["Party"].Enable then
		self:SpawnPartyFrames()
	end

	self:UpdateAllHeaders()
	self:UpdateRaidDebuffIndicator()
end

function Module:SpawnPartyFrames()
	if not C["Party"].Enable then
		return
	end

	-- Install forces useCompactPartyFrames; bury the CUF container when we own party.
	DisableBlizzardRaidFrames()

	local partyMover

	if C["SimpleParty"].Enable then
		registerStyleOnce("SimpleParty", Module.CreateSimpleParty)
		oUF:SetActiveStyle("SimpleParty")

		local simplePartyWidth = C["SimpleParty"].HealthWidth
		local simplePartyHeight = C["SimpleParty"].HealthHeight
		local horizonParty = C["SimpleParty"].HorizonParty
		local partyXOffset = horizonParty and 6 or 0
		local partyYOffset = horizonParty and 0 or -6

		local partyMoverWidth, partyMoverHeight
		if horizonParty then
			partyMoverWidth = (simplePartyWidth + 6) * 5
			partyMoverHeight = simplePartyHeight
		else
			partyMoverWidth = simplePartyWidth
			partyMoverHeight = (simplePartyHeight + 6) * 5
		end

		-- stylua: ignore
		local party = oUF:SpawnHeader(
			"oUF_SimpleParty", nil,
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

		partyMover = attachPartyToMover(party, "SimplePartyFrame", { "LEFT", UIParent, 350, 0 }, partyMoverWidth, partyMoverHeight)
		party.groupType = "party"
		tinsert(Module.headers, party)
		RegisterStateDriver(party, "visibility", Module:GetPartyVisibility())
	else
		registerStyleOnce("Party", Module.CreateParty)
		oUF:SetActiveStyle("Party")

		local partyXOffset, partyYOffset = 6, C["Party"].ShowBuffs and 56 or 36
		local partyMoverWidth = C["Party"].HealthWidth
		local partyMoverHeight = C["Party"].HealthHeight + C["Party"].PowerHeight + 1 + partyYOffset * 8
		local partyGroupingOrder = "NONE,DAMAGER,HEALER,TANK"

		-- stylua: ignore
		local party = oUF:SpawnHeader(
			"oUF_Party", nil,
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

		partyMover = attachPartyToMover(party, "PartyFrame", { "TOPLEFT", UIParent, "TOPLEFT", 50, -300 }, partyMoverWidth, partyMoverHeight)
		party.groupType = "party"
		tinsert(Module.headers, party)
		RegisterStateDriver(party, "visibility", Module:GetPartyVisibility())
	end

	if C["Party"].ShowPet and partyMover then
		registerStyleOnce("PartyPet", Module.CreatePartyPet)
		oUF:SetActiveStyle("PartyPet")

		local partypetXOffset, partypetYOffset = 6, 25
		local partpetMoverWidth = 60
		local partpetMoverHeight = 34 * 5 + partypetYOffset * 4

		-- stylua: ignore
		local partyPet = oUF:SpawnHeader(
			"oUF_PartyPet", "SecureGroupPetHeaderTemplate",
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
		attachPartyToMover(partyPet, "PartyPetFrame", moverAnchor, partpetMoverWidth, partpetMoverHeight)
		partyPet.groupType = "pet"
		tinsert(Module.headers, partyPet)
		RegisterStateDriver(partyPet, "visibility", Module:GetPartyPetVisibility())
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

-- Centralized Blizzard raid/party CUF disable
-- REASON: CompactRaidFrameContainer still ApplyToFrames on Edit Mode close even after
-- CompactPartyFrame:UnregisterAllEvents. Under addon taint, CUF health color compares
-- secret StatusBar RGB and throws. Reparent + OnShow bury to keep Blizzard frames quiet.
-- Do NOT Dummy EditMode AccountSettings Refresh* — that taints Edit Mode itself (see Movers).
DisableBlizzardRaidFrames = function()
	if InCombatLockdown() then
		return
	end

	local hider = K.UIFrameHider

	if CompactPartyFrame then
		CompactPartyFrame:UnregisterAllEvents()
		if hider then
			CompactPartyFrame:SetParent(hider)
		end
		if not CompactPartyFrame._kkuiSuppressed then
			CompactPartyFrame._kkuiSuppressed = true
			CompactPartyFrame:HookScript("OnShow", function(self)
				self:Hide()
			end)
		end
		CompactPartyFrame:Hide()
	end

	local container = _G.CompactRaidFrameContainer
	if container then
		container:UnregisterAllEvents()
		if hider then
			container:SetParent(hider)
		end
		if not container._kkuiSuppressed then
			container._kkuiSuppressed = true
			container:HookScript("OnShow", function(self)
				self:Hide()
			end)
		end
		container:Hide()
	end

	if _G.CompactRaidFrameManager_SetSetting then
		_G.CompactRaidFrameManager_SetSetting("IsShown", "0")
		UIParent:UnregisterEvent("GROUP_ROSTER_UPDATE")
		_G.CompactRaidFrameManager:UnregisterAllEvents()
		if hider then
			_G.CompactRaidFrameManager:SetParent(hider)
		end
	end
end

local function removeRaidFrames(headers)
	removeHeadersByGroupType(headers, "raid")
	retireUnitFrame(_G.oUF_MainTank)
end

Module._DeferredRebuildRaidFrames = Module._DeferredRebuildRaidFrames or function()
	Module:RebuildRaidFrames()
end

function Module:SpawnRaidFrames()
	if not C["Raid"].Enable then
		return
	end

	SetCVar("predictedHealth", 1)
	registerStyleOnce("Raid", Module.CreateRaid)
	oUF:SetActiveStyle("Raid")
	DisableBlizzardRaidFrames()

	local horizonRaid = C["Raid"].HorizonRaid
	local numGroups = C["Raid"].NumGroups
	local raidWidth, raidHeight = C["Raid"].Width, C["Raid"].Height
	local showTeamIndex = C["Raid"].ShowTeamIndex

	local raidMoverWidth, raidMoverHeight
	if horizonRaid then
		raidMoverWidth = (raidWidth + 5) * 5
		raidMoverHeight = (raidHeight + (showTeamIndex and 15 or 5)) * numGroups
	else
		raidMoverWidth = (raidWidth + 5) * numGroups
		raidMoverHeight = (raidHeight + 5) * 5
	end

	local function CreateGroup(name, i)
		return oUF:SpawnHeader(
			name,
			nil,
			"showPlayer",
			true,
			"showSolo",
			true,
			"showParty",
			true,
			"showRaid",
			true,
			"xOffset",
			6,
			"yOffset",
			-6,
			"groupFilter",
			tostring(i),
			"groupingOrder",
			"1,2,3,4,5,6,7,8",
			"groupBy",
			"GROUP",
			"sortMethod",
			"INDEX",
			"maxColumns",
			1,
			"unitsPerColumn",
			5,
			"columnSpacing",
			5,
			"point",
			horizonRaid and "LEFT" or "TOP",
			"columnAnchorPoint",
			"LEFT",
			"oUF-initialConfigFunction",
			CreateHeaderInit(raidWidth, raidHeight)
		)
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

	for i = 1, numGroups do
		local group = CreateGroup("oUF_Raid" .. i, i)
		group.index = i
		group.groupType = "raid"
		tinsert(Module.headers, group)
		RegisterStateDriver(group, "visibility", Module:GetRaidVisibility())

		if i == 1 then
			attachPartyToMover(group, "RaidFrame", { "TOPLEFT", UIParent, "TOPLEFT", 4, -180 }, raidMoverWidth, raidMoverHeight)
		end

		if showTeamIndex then
			CreateTeamIndex(group)
			group:HookScript("OnShow", CreateTeamIndex)
		end
	end

	if C["Raid"].MainTankFrames then
		registerStyleOnce("MainTank", Module.CreateRaid)
		oUF:SetActiveStyle("MainTank")

		local horizonTankRaid = C["Raid"].HorizonRaid
		local raidTankWidth, raidTankHeight = C["Raid"].Width, C["Raid"].Height
		local raidtank = oUF:SpawnHeader(
			"oUF_MainTank",
			nil,
			"showRaid",
			true,
			"xOffset",
			6,
			"yOffset",
			-6,
			"groupFilter",
			"MAINTANK",
			"point",
			horizonTankRaid and "LEFT" or "TOP",
			"columnAnchorPoint",
			"LEFT",
			"template",
			C["Raid"].MainTankFrames and "oUF_MainTankTT" or "oUF_MainTank",
			"oUF-initialConfigFunction",
			string_format(
				[[ 
				self:SetWidth(%d)
				self:SetHeight(%d)
			]],
				raidTankWidth,
				raidTankHeight
			)
		)

		attachPartyToMover(raidtank, "MainTankFrame", { "TOPLEFT", UIParent, "TOPLEFT", 4, -50 }, raidTankWidth, raidTankHeight)
	end

	self:UpdateRaidLayout()
end

function Module:RebuildRaidFrames()
	if deferUntilRegen("_pendingRaidRebuild", "_pendingRaidRebuildRegistered", Module._DeferredRebuildRaidFrames) then
		return
	end

	removeRaidFrames(self.headers)

	if C["Raid"].Enable then
		self:SpawnRaidFrames()
	end

	self:UpdateAllHeaders()
	self:UpdateRaidDebuffIndicator()
end

Module._DeferredRebuildPortraitUnits = Module._DeferredRebuildPortraitUnits or function()
	Module:RebuildPortraitUnits()
end

function Module:SpawnCoreUnitFrames()
	if not C["Unitframe"].Enable then
		return
	end

	local cfg = C["Unitframe"]

	registerStyleOnce("Player", Module.CreatePlayer)
	registerStyleOnce("Target", Module.CreateTarget)
	registerStyleOnce("ToT", Module.CreateTargetOfTarget)
	registerStyleOnce("Focus", Module.CreateFocus)
	registerStyleOnce("FocusTarget", Module.CreateFocusTarget)
	registerStyleOnce("Pet", Module.CreatePet)

	oUF:SetActiveStyle("Player")
	retireUnitFrame(_G.oUF_Player)
	local Player = oUF:Spawn("player", "oUF_Player")
	Player:SetSize(cfg.PlayerHealthWidth, cfg.PlayerHealthHeight + cfg.PlayerPowerHeight + 6)
	attachPartyToMover(Player, "PlayerUF", { "BOTTOM", UIParent, "BOTTOM", -260, 320 }, Player:GetWidth(), Player:GetHeight())

	oUF:SetActiveStyle("Target")
	retireUnitFrame(_G.oUF_Target)
	local Target = oUF:Spawn("target", "oUF_Target")
	Target:SetSize(cfg.TargetHealthWidth, cfg.TargetHealthHeight + cfg.TargetPowerHeight + 6)
	attachPartyToMover(Target, "TargetUF", { "BOTTOM", UIParent, "BOTTOM", 260, 320 }, Target:GetWidth(), Target:GetHeight())

	if not cfg.HideTargetofTarget then
		oUF:SetActiveStyle("ToT")
		retireUnitFrame(_G.oUF_ToT)
		local TargetOfTarget = oUF:Spawn("targettarget", "oUF_ToT")
		TargetOfTarget:SetSize(cfg.TargetTargetHealthWidth, cfg.TargetTargetHealthHeight + cfg.TargetTargetPowerHeight + 6)
		local totMover = _G.KKUI_Mover_TotUF
		if totMover then
			totMover:SetSize(TargetOfTarget:GetWidth(), TargetOfTarget:GetHeight())
			TargetOfTarget:ClearAllPoints()
			TargetOfTarget:SetPoint("TOPLEFT", totMover)
		else
			K.Mover(TargetOfTarget, "TotUF", "TotUF", { "TOPLEFT", Target, "BOTTOMRIGHT", 6, -6 }, TargetOfTarget:GetWidth(), TargetOfTarget:GetHeight())
		end
	else
		retireUnitFrame(_G.oUF_ToT)
	end

	oUF:SetActiveStyle("Pet")
	retireUnitFrame(_G.oUF_Pet)
	local Pet = oUF:Spawn("pet", "oUF_Pet")
	Pet:SetSize(cfg.PetHealthWidth, cfg.PetHealthHeight + cfg.PetPowerHeight + 6)
	local petMover = _G.KKUI_Mover_Pet
	if petMover then
		petMover:SetSize(Pet:GetWidth(), Pet:GetHeight())
		Pet:ClearAllPoints()
		Pet:SetPoint("TOPLEFT", petMover)
	else
		K.Mover(Pet, "Pet", "Pet", { "TOPRIGHT", Player, "BOTTOMLEFT", -6, -6 }, Pet:GetWidth(), Pet:GetHeight())
	end

	oUF:SetActiveStyle("Focus")
	retireUnitFrame(_G.oUF_Focus)
	local Focus = oUF:Spawn("focus", "oUF_Focus")
	Focus:SetSize(cfg.FocusHealthWidth, cfg.FocusHealthHeight + cfg.FocusPowerHeight + 6)
	attachPartyToMover(Focus, "FocusUF", { "BOTTOMRIGHT", Player, "TOPLEFT", -60, 200 }, Focus:GetWidth(), Focus:GetHeight())

	if not cfg.HideFocusTarget then
		oUF:SetActiveStyle("FocusTarget")
		retireUnitFrame(_G.oUF_FocusTarget)
		local FocusTarget = oUF:Spawn("focustarget", "oUF_FocusTarget")
		FocusTarget:SetSize(cfg.FocusTargetHealthWidth, cfg.FocusTargetHealthHeight + cfg.FocusTargetPowerHeight + 6)
		local ftMover = _G.KKUI_Mover_FocusTarget
		if ftMover then
			ftMover:SetSize(FocusTarget:GetWidth(), FocusTarget:GetHeight())
			FocusTarget:ClearAllPoints()
			FocusTarget:SetPoint("TOPLEFT", ftMover)
		else
			K.Mover(FocusTarget, "FocusTarget", "FocusTarget", { "TOPLEFT", Focus, "BOTTOMRIGHT", 6, -6 }, FocusTarget:GetWidth(), FocusTarget:GetHeight())
		end
	else
		retireUnitFrame(_G.oUF_FocusTarget)
	end

	self:UpdateTextScale()
	self:UpdatePlayerLevelVisibility()
	self:UpdateOptionalUnitLevels()
end

function Module:SpawnBossFrames()
	if not C["Boss"].Enable then
		return
	end

	registerStyleOnce("Boss", Module.CreateBoss)
	oUF:SetActiveStyle("Boss")

	local cfg = C["Boss"]
	for i = 1, 10 do
		retireUnitFrame(_G["oUF_Boss" .. i])
	end

	local Boss = {}
	for i = 1, 10 do
		Boss[i] = oUF:Spawn("boss" .. i, "oUF_Boss" .. i)
		Boss[i]:SetSize(cfg.HealthWidth, cfg.HealthHeight + cfg.PowerHeight + 6)

		local bossMoverWidth = cfg.HealthWidth
		local bossMoverHeight = cfg.HealthHeight + cfg.PowerHeight + 6
		local moverKey = "BossFrame" .. i
		local anchorKey = (i == 1) and "Boss1" or ("Boss" .. i)
		local defaultAnchor = (i == 1)
				and { "BOTTOMRIGHT", UIParent, "RIGHT", -250, 140 }
			or { "TOPLEFT", Boss[i - 1], "BOTTOMLEFT", 0, -cfg.YOffset }

		local mover = _G["KKUI_Mover_" .. moverKey]
		if mover then
			mover:SetSize(bossMoverWidth, bossMoverHeight)
			Boss[i]:ClearAllPoints()
			Boss[i]:SetPoint("TOPLEFT", mover)
			Boss[i].mover = mover
		else
			Boss[i].mover = K.Mover(Boss[i], moverKey, anchorKey, defaultAnchor, bossMoverWidth, bossMoverHeight)
		end
	end
end

function Module:SpawnArenaFrames()
	if not C["Arena"].Enable then
		return
	end

	registerStyleOnce("Arena", Module.CreateArena)
	oUF:SetActiveStyle("Arena")

	local cfg = C["Arena"]
	for i = 1, 5 do
		retireUnitFrame(_G["oUF_Arena" .. i])
	end

	local Arena = {}
	for i = 1, 5 do
		Arena[i] = oUF:Spawn("arena" .. i, "oUF_Arena" .. i)
		Arena[i]:SetSize(cfg.HealthWidth, cfg.HealthHeight + cfg.PowerHeight + 6)

		local arenaMoverWidth = cfg.HealthWidth
		local arenaMoverHeight = cfg.HealthHeight + cfg.PowerHeight + 6
		local moverKey = "ArenaFrame" .. i
		local anchorKey = (i == 1) and "Arena1" or ("Arena" .. i)
		local defaultAnchor = (i == 1)
				and { "BOTTOMRIGHT", UIParent, "RIGHT", -250, 140 }
			or { "TOPLEFT", Arena[i - 1], "BOTTOMLEFT", 0, -cfg.YOffset }

		local mover = _G["KKUI_Mover_" .. moverKey]
		if mover then
			mover:SetSize(arenaMoverWidth, arenaMoverHeight)
			Arena[i]:ClearAllPoints()
			Arena[i]:SetPoint("TOPLEFT", mover)
			Arena[i].mover = mover
		else
			Arena[i].mover = K.Mover(Arena[i], moverKey, anchorKey, defaultAnchor, arenaMoverWidth, arenaMoverHeight)
		end
	end
end

Module._DeferredSpawnBossFrames = Module._DeferredSpawnBossFrames or function()
	Module:SpawnBossFrames()
end

function Module:SafeSpawnBossFrames()
	if deferUntilRegen("_pendingBossSpawn", "_pendingBossSpawnRegistered", Module._DeferredSpawnBossFrames) then
		return
	end

	self:SpawnBossFrames()
end

Module._DeferredSpawnArenaFrames = Module._DeferredSpawnArenaFrames or function()
	Module:SpawnArenaFrames()
end

function Module:SafeSpawnArenaFrames()
	if deferUntilRegen("_pendingArenaSpawn", "_pendingArenaSpawnRegistered", Module._DeferredSpawnArenaFrames) then
		return
	end

	self:SpawnArenaFrames()
end

function Module:RebuildPortraitUnits()
	if deferUntilRegen("_pendingPortraitRebuild", "_pendingPortraitRebuildRegistered", Module._DeferredRebuildPortraitUnits) then
		return
	end

	self:SpawnCoreUnitFrames()
	self:RebuildPartyFrames()

	if C["Boss"].Enable then
		self:SpawnBossFrames()
	end

	if C["Arena"].Enable then
		self:SpawnArenaFrames()
	end
end

local CORE_UNIT_FRAMES = {
	"oUF_Player",
	"oUF_Target",
	"oUF_ToT",
	"oUF_Pet",
	"oUF_Focus",
	"oUF_FocusTarget",
}

local OPTIONAL_UNIT_FRAMES = {
	"oUF_Boss1",
	"oUF_Boss2",
	"oUF_Boss3",
	"oUF_Boss4",
	"oUF_Boss5",
	"oUF_Arena1",
	"oUF_Arena2",
	"oUF_Arena3",
	"oUF_Arena4",
	"oUF_Arena5",
}

local function setUnitFrameShown(frame, shown)
	if frame then
		frame:SetShown(shown)
	end
end

local function setUnitFramesListShown(frameNames, shown)
	for i = 1, #frameNames do
		setUnitFrameShown(_G[frameNames[i]], shown)
	end
end

function Module:RegisterCoreUnitEvents()
	if Module._coreUnitEventsRegistered then
		return
	end
	Module._coreUnitEventsRegistered = true
	K:RegisterEvent("PLAYER_TARGET_CHANGED", Module.PLAYER_TARGET_CHANGED)
	K:RegisterEvent("PLAYER_FOCUS_CHANGED", Module.PLAYER_FOCUS_CHANGED)
	K:RegisterUnitEvent("UNIT_FACTION", Module.UNIT_FACTION, "player")
end

function Module:UnregisterCoreUnitEvents()
	if not Module._coreUnitEventsRegistered then
		return
	end
	Module._coreUnitEventsRegistered = false
	K:UnregisterEvent("PLAYER_TARGET_CHANGED", Module.PLAYER_TARGET_CHANGED)
	K:UnregisterEvent("PLAYER_FOCUS_CHANGED", Module.PLAYER_FOCUS_CHANGED)
	K:UnregisterEvent("UNIT_FACTION", Module.UNIT_FACTION)
end

function Module:CreateUnits()
	-- Reset header list to avoid duplicates on re-init/profile switch
	if Module.headers then
		wipe(Module.headers)
	end

	-- Re-apply persisted nameplate aura-filter edits onto the runtime data tables.
	-- Done unconditionally (not just when nameplates are enabled) because MajorSpells
	-- feeds castbars on other frames too. Idempotent, so re-running on profile switch is safe.
	Module:ApplyNameplateAuraOverrides()
	local showPartyFrame = C["Party"].Enable

	if C["Nameplate"].Enable then
		Module:InitNameplates()
	end

	do -- Playerplate-like PlayerFrame
		registerStyleOnce("PlayerPlate", Module.CreatePlayerPlate)
		oUF:SetActiveStyle("PlayerPlate")
		local plate = oUF:Spawn("player", "oUF_PlayerPlate", true)
		plate.mover = K.Mover(plate, "PlayerPlate", "PlayerPlate", { "BOTTOM", UIParent, "BOTTOM", 0, 300 })
		Module:TogglePlayerPlate()
	end

	do -- Fake nameplate for target class power
		registerStyleOnce("TargetPlate", Module.CreateTargetPlate)
		oUF:SetActiveStyle("TargetPlate")
		oUF:Spawn("player", "oUF_TargetPlate", true)
		Module:ToggleTargetClassPower()
	end

	if C["Unitframe"].Enable then
		Module:SpawnCoreUnitFrames()
		Module:RegisterCoreUnitEvents()
	end

	Module:SpawnBossFrames()
	Module:SpawnArenaFrames()

	if showPartyFrame then
		Module:SpawnPartyFrames()
	end

	Module:SpawnRaidFrames()

	-- Apply header visibility once after creation
	Module:UpdateAllHeaders()
end

function Module:SetUnitframesEnabled(enabled)
	if enabled then
		Module:SpawnCoreUnitFrames()
		Module:RegisterCoreUnitEvents()
		setUnitFramesListShown(CORE_UNIT_FRAMES, true)

		if Module.TogglePlayerPlate then
			Module:TogglePlayerPlate()
		end
		if Module.ToggleTargetClassPower then
			Module:ToggleTargetClassPower()
		end

		if C["Boss"].Enable then
			for i = 1, 5 do
				setUnitFrameShown(_G["oUF_Boss" .. i], true)
			end
		end
		if C["Arena"].Enable then
			for i = 1, 5 do
				setUnitFrameShown(_G["oUF_Arena" .. i], true)
			end
		end

		Module:UpdateAllHeaders()
	else
		setUnitFramesListShown(CORE_UNIT_FRAMES, false)
		setUnitFramesListShown(OPTIONAL_UNIT_FRAMES, false)
		setUnitFrameShown(_G.oUF_PlayerPlate, false)
		setUnitFrameShown(_G.oUF_TargetPlate, false)

		if Module.headers then
			for i = 1, #Module.headers do
				setUnitFrameShown(Module.headers[i], false)
			end
		end

		Module:UnregisterCoreUnitEvents()
	end
end

-- REASON: Updates the raid debuff indicators based on the current instance type.
function Module:UpdateRaidDebuffIndicator()
	local ORD = K.oUF_RaidDebuffs or oUF_RaidDebuffs
	if ORD then
		local _, InstanceType = IsInInstance()
		ORD:ResetDebuffData()

		if InstanceType == "party" or InstanceType == "raid" then
			if C["Raid"].DebuffWatchDefault or C["SimpleParty"].DebuffWatchDefault then
				ORD:RegisterDebuffs(C["DebuffsTracking_PvE"].spells)
			end
			ORD:RegisterDebuffs(K.GetCharVars().Tracking.PvE)
		else
			if C["Raid"].DebuffWatchDefault or C["SimpleParty"].DebuffWatchDefault then
				ORD:RegisterDebuffs(C["DebuffsTracking_PvP"].spells)
			end
			ORD:RegisterDebuffs(K.GetCharVars().Tracking.PvP)
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
