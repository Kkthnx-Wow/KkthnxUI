--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: "Lack" icons when the player is missing buffs they can provide (shouts, poisons, enchants).
-- - Design: End-of-frame UNIT_AURA batching, GetPlayerAuraBySpellID, pre-combat snapshot, optional glow.
-- - Preview: /kk reminder toggles sample icons for positioning via /moveui.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:GetModule("Auras")

local ipairs, next, pairs, tinsert, wipe = ipairs, next, pairs, table.insert, wipe
local CreateFrame, UIParent = CreateFrame, UIParent
local GetNumGroupMembers = GetNumGroupMembers
local GetSpecialization = GetSpecialization
local GetWeaponEnchantInfo = GetWeaponEnchantInfo
local InCombatLockdown = InCombatLockdown
local IsInInstance = IsInInstance
local IsPlayerSpell = IsPlayerSpell
local UnitInVehicle = UnitInVehicle
local UnitIsDeadOrGhost = UnitIsDeadOrGhost

local C_Item_GetItemCooldown = C_Item.GetItemCooldown
local C_Item_GetItemCount = C_Item.GetItemCount
local C_Item_GetItemIconByID = C_Item.GetItemIconByID
local C_Item_IsEquippedItem = C_Item.IsEquippedItem
local C_PvP_GetZonePVPInfo = C_PvP.GetZonePVPInfo
local C_Spell_GetSpellTexture = C_Spell.GetSpellTexture
local C_UnitAuras_GetBuffDataByIndex = C_UnitAuras.GetBuffDataByIndex
local C_UnitAuras_GetPlayerAuraBySpellID = C_UnitAuras.GetPlayerAuraBySpellID
local C_Spell_GetSpellCooldownDuration = C_Spell.GetSpellCooldownDuration
local C_DurationUtil_CreateDuration = C_DurationUtil and C_DurationUtil.CreateDuration

local NotSecret = K.NotSecret

local REMINDER_BORDER = {
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	edgeSize = 14,
}
local REMINDER_BORDER_COLOR = { 1, 0.15, 0.1 }
local REMINDER_GLOW_COLOR = { 1, 0.15, 0.1 }
local REMINDER_BORDER_OUTSET = 3

local groups = C.SpellReminderBuffs[K.Class]
if not groups then
	groups = {}
	C.SpellReminderBuffs[K.Class] = groups
end

local iconSize
local frames = {}
local parentFrame
local testFrames = {}
local isRegistered = false
local itemsMerged = false
local addedItems = {}
local manualTest
local preview
local combatSnapshot = {}
local updatePending

local function Reminder_IconSize()
	return (C["Auras"].DebuffSize or 34) + 4
end

local function Reminder_FrameStep()
	return iconSize + 6
end

local function Reminder_WantsGlow()
	return C["Auras"].ReminderGlow ~= false
end

local function Reminder_AnchorBorderRing(anchor, frame)
	anchor:ClearAllPoints()
	anchor:SetPoint("TOPLEFT", frame, "TOPLEFT", -REMINDER_BORDER_OUTSET, REMINDER_BORDER_OUTSET)
	anchor:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", REMINDER_BORDER_OUTSET, -REMINDER_BORDER_OUTSET)
end

local function Reminder_AttachPulseGlow(frame)
	local glowHost = CreateFrame("Frame", nil, frame)
	Reminder_AnchorBorderRing(glowHost, frame)
	glowHost:SetFrameLevel(frame:GetFrameLevel() + 1)
	K.CreateGlowBorder(glowHost, { outset = 3, blend = "BLEND", color = REMINDER_GLOW_COLOR })

	local anim = glowHost:CreateAnimationGroup()
	anim:SetLooping("REPEAT")
	local fadeIn = anim:CreateAnimation("Alpha")
	fadeIn:SetFromAlpha(0.2)
	fadeIn:SetToAlpha(0.9)
	fadeIn:SetDuration(0.36)
	fadeIn:SetOrder(1)
	fadeIn:SetSmoothing("OUT")
	local fadeOut = anim:CreateAnimation("Alpha")
	fadeOut:SetFromAlpha(0.9)
	fadeOut:SetToAlpha(0.2)
	fadeOut:SetDuration(0.36)
	fadeOut:SetOrder(2)
	fadeOut:SetSmoothing("IN")
	glowHost.Anim = anim
	glowHost:SetScript("OnShow", function(self)
		self.Anim:Play()
	end)
	glowHost:SetScript("OnHide", function(self)
		self.Anim:Stop()
	end)
	glowHost:Hide()
	frame.ReminderGlow = glowHost
end

local function Reminder_SetGlowVisible(frame, visible)
	local glow = frame.ReminderGlow
	if not glow then
		return
	end
	if visible and Reminder_WantsGlow() then
		glow:Show()
	else
		glow:Hide()
	end
end

local function Reminder_ItemOnCooldown(itemID)
	local start, dur = C_Item_GetItemCooldown(itemID)
	if K.IsSecret(start) or K.IsSecret(dur) then
		return true
	end
	return dur and dur > 0
end

local function Reminder_ApplyItemCooldown(frame, itemID)
	local cd = frame.Cooldown
	if not (cd and itemID and C_DurationUtil_CreateDuration) then
		return
	end
	local start, dur = C_Item_GetItemCooldown(itemID)
	if K.IsSecret(start) or K.IsSecret(dur) or not dur or dur <= 0 then
		cd:Clear()
		return
	end
	local durObj = C_DurationUtil_CreateDuration()
	durObj:SetTimeFromStart(start, dur)
	cd:SetCooldownFromDurationObject(durObj)
	K.MaskCooldownSwipeFromDurationObject(cd, durObj)
end

local function Reminder_ApplyDependCooldown(frame, spellID)
	local cd = frame.Cooldown
	if not (cd and spellID and C_Spell_GetSpellCooldownDuration) then
		return
	end
	local durObj = C_Spell_GetSpellCooldownDuration(spellID)
	if durObj then
		cd:SetCooldownFromDurationObject(durObj)
		K.MaskCooldownSwipeFromDurationObject(cd, durObj)
	else
		cd:Clear()
	end
end

local function Reminder_ShowFrame(frame)
	frame:Show()
	Reminder_SetGlowVisible(frame, true)
end

local function Reminder_HideFrame(frame)
	frame:Hide()
	Reminder_SetGlowVisible(frame, false)
end

local function Reminder_PlayerEligible(cfg)
	if cfg.depends then
		for i = 1, #cfg.depends do
			if IsPlayerSpell(cfg.depends[i]) then
				return true
			end
		end
		return false
	end
	if cfg.depend then
		return IsPlayerSpell(cfg.depend)
	end
	return true
end

local function PlayerHasConfiguredBuff(cfg)
	for spellId in pairs(cfg.spells) do
		if NotSecret(spellId) then
			if C_UnitAuras_GetPlayerAuraBySpellID(spellId) then
				return true
			end
			if combatSnapshot[spellId] then
				return true
			end
		end
	end
	for i = 1, 40 do
		local auraData = C_UnitAuras_GetBuffDataByIndex("player", i, "HELPFUL")
		if not auraData then
			break
		end
		local spellId = auraData.spellId
		if NotSecret(spellId) and spellId and cfg.spells[spellId] then
			return true
		end
	end
	return false
end

local function SnapshotCombatBuffs()
	if not groups then
		return
	end
	wipe(combatSnapshot)
	for _, cfg in ipairs(groups) do
		if cfg.spells and not cfg.weaponIndex then
			for spellId in pairs(cfg.spells) do
				if NotSecret(spellId) and C_UnitAuras_GetPlayerAuraBySpellID(spellId) then
					combatSnapshot[spellId] = true
				end
			end
		end
	end
end

local function Reminder_Update(cfg)
	local frame = cfg.frame
	if not frame then
		return
	end

	local spec = cfg.spec
	local combat, instance, pvp = cfg.combat, cfg.instance, cfg.pvp
	local itemID, equip, inGroup = cfg.itemID, cfg.equip, cfg.inGroup
	local weaponIndex = cfg.weaponIndex

	local isEligible, isRightSpec, isEquipped, isGrouped = true, true, true, true
	local isInCombat, isInInst, isInPVP = false, false, false
	local inInst, instType = IsInInstance()

	if itemID then
		if inGroup and GetNumGroupMembers() < 2 then
			isGrouped = false
		end
		if equip and not C_Item_IsEquippedItem(itemID) then
			isEquipped = false
		end
		if C_Item_GetItemCount(itemID) == 0 or not isEquipped or not isGrouped or Reminder_ItemOnCooldown(itemID) then
			Reminder_HideFrame(frame)
			return
		end
	end

	if not Reminder_PlayerEligible(cfg) then
		isEligible = false
	end
	if spec and spec ~= GetSpecialization() then
		isRightSpec = false
	end
	if combat and InCombatLockdown() then
		isInCombat = true
	end
	if instance and inInst and (instType == "scenario" or instType == "party" or instType == "raid") then
		isInInst = true
	end
	if pvp and (instType == "arena" or instType == "pvp" or C_PvP_GetZonePVPInfo() == "combat") then
		isInPVP = true
	end
	if not combat and not instance and not pvp then
		isInCombat, isInInst, isInPVP = true, true, true
	end

	Reminder_HideFrame(frame)
	if isEligible and isRightSpec and (isInCombat or isInInst or isInPVP) and not UnitInVehicle("player") and not UnitIsDeadOrGhost("player") then
		if weaponIndex then
			local hasMainHandEnchant, _, _, _, hasOffHandEnchant = GetWeaponEnchantInfo()
			local mainActive = K.BooleanIsTrue(hasMainHandEnchant)
			local offActive = K.BooleanIsTrue(hasOffHandEnchant)
			if (mainActive and weaponIndex == 1) or (offActive and weaponIndex == 2) then
				return
			end
		elseif PlayerHasConfiguredBuff(cfg) then
			return
		end
		Reminder_ShowFrame(frame)
	end
end

local function Reminder_BuildFrame(texture)
	local frame = CreateFrame("Frame", nil, parentFrame)
	frame:SetSize(iconSize, iconSize)
	frame:SetClipsChildren(false)

	Reminder_AttachPulseGlow(frame)

	local icon = frame:CreateTexture(nil, "ARTWORK")
	icon:SetAllPoints(frame)
	icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	icon:SetTexture(texture)
	frame.Icon = icon

	local border = CreateFrame("Frame", nil, frame, "BackdropTemplate")
	Reminder_AnchorBorderRing(border, frame)
	border:SetFrameLevel(frame:GetFrameLevel() + 2)
	border:SetBackdrop(REMINDER_BORDER)
	border:SetBackdropBorderColor(REMINDER_BORDER_COLOR[1], REMINDER_BORDER_COLOR[2], REMINDER_BORDER_COLOR[3])
	frame.Border = border

	local text = frame:CreateFontString(nil, "OVERLAY")
	text:SetFontObject(K.UIFontOutline)
	text:SetText(L["Lack"])
	text:SetPoint("TOP", frame, "TOP", 1, 15)
	text:SetTextColor(1, 0.1, 0.1)
	frame.text = text

	local cd = CreateFrame("Cooldown", nil, frame, "CooldownFrameTemplate")
	cd:SetAllPoints(frame)
	cd:SetDrawEdge(false)
	cd:SetReverse(true)
	cd:SetHideCountdownNumbers(true)
	cd:Hide()
	frame.Cooldown = cd

	Reminder_HideFrame(frame)
	return frame
end

function Module:Reminder_Create(cfg)
	if not parentFrame then
		return
	end

	local texture = cfg.texture
	if not texture then
		local spellID = next(cfg.spells)
		if spellID then
			texture = C_Spell_GetSpellTexture(spellID)
		end
	end

	local frame = Reminder_BuildFrame(texture)
	cfg.frame = frame
	tinsert(frames, frame)
end

function Module:Reminder_UpdateAnchor()
	local index = 0
	local offset = Reminder_FrameStep()
	for _, frame in ipairs(frames) do
		if frame:IsShown() then
			frame:ClearAllPoints()
			frame:SetPoint("LEFT", parentFrame, "LEFT", offset * index, 0)
			index = index + 1
		end
	end
	parentFrame:SetWidth(offset * (index > 0 and index or 1))
end

local function Reminder_RunUpdate()
	updatePending = nil
	if preview or not parentFrame or not parentFrame:IsShown() then
		return
	end
	if not C["Auras"].Reminder or not groups then
		return
	end

	for _, cfg in ipairs(groups) do
		if not cfg.frame then
			Module:Reminder_Create(cfg)
		end
		Reminder_Update(cfg)
		if cfg.frame then
			if cfg.itemID then
				Reminder_ApplyItemCooldown(cfg.frame, cfg.itemID)
			elseif cfg.depend and cfg.frame.Cooldown then
				Reminder_ApplyDependCooldown(cfg.frame, cfg.depend)
			elseif cfg.frame.Cooldown then
				cfg.frame.Cooldown:Clear()
			end
		end
	end
	Module:Reminder_UpdateAnchor()
end

function Module.Reminder_OnEvent(event, unit)
	if event == "UNIT_AURA" and unit and unit ~= "player" then
		return
	end
	if event == "PLAYER_REGEN_DISABLED" then
		SnapshotCombatBuffs()
	elseif event == "PLAYER_REGEN_ENABLED" then
		wipe(combatSnapshot)
	end

	if updatePending then
		return
	end
	updatePending = true
	C_Timer_After(0, Reminder_RunUpdate)
end

function Module:Reminder_AddItemGroup()
	if itemsMerged then
		return
	end
	wipe(addedItems)

	for _, cfg in ipairs(groups) do
		if cfg and cfg.itemID then
			addedItems[cfg.itemID] = true
		end
	end

	for _, value in ipairs(C.SpellReminderBuffs["ITEMS"]) do
		if value and not value.disable and value.itemID and not addedItems[value.itemID] and C_Item_GetItemCount(value.itemID) > 0 then
			value.texture = value.texture or C_Item_GetItemIconByID(value.itemID)
			tinsert(groups, value)
			addedItems[value.itemID] = true
		end
	end

	itemsMerged = true
end

local function Reminder_EnsureParent()
	if parentFrame then
		return
	end

	iconSize = Reminder_IconSize()
	parentFrame = CreateFrame("Frame", nil, UIParent)
	parentFrame:SetSize(iconSize, iconSize)
	parentFrame:SetClipsChildren(false)
	parentFrame.mover = K.Mover(parentFrame, L["Auras Reminder (Shout/Intellect/Poison)"], "ReminderAnchor", { "CENTER", UIParent, "CENTER", -220, 130 }, iconSize, iconSize)
	parentFrame:ClearAllPoints()
	parentFrame:SetPoint("CENTER", parentFrame.mover)
end

local function Reminder_BuildSamples()
	for i = 1, #testFrames do
		testFrames[i]:Hide()
		testFrames[i]:SetParent(nil)
	end
	wipe(testFrames)

	local textures = {}
	if groups then
		for _, cfg in ipairs(groups) do
			local tex = cfg.texture
			if not tex then
				local spellID = next(cfg.spells)
				if spellID then
					tex = C_Spell_GetSpellTexture(spellID)
				end
			end
			if tex then
				textures[#textures + 1] = tex
			end
		end
	end
	if #textures == 0 then
		textures = { 135932, 135987, 132333 }
	end
	for i = 1, #textures do
		testFrames[i] = Reminder_BuildFrame(textures[i])
	end
end

local function Reminder_LayoutSamples()
	local offset = Reminder_FrameStep()
	for i = 1, #testFrames do
		local frame = testFrames[i]
		frame:ClearAllPoints()
		frame:SetPoint("LEFT", parentFrame, "LEFT", offset * (i - 1), 0)
	end
	parentFrame:SetWidth(offset * (#testFrames > 0 and #testFrames or 1))
end

function Module:Reminder_RefreshPreview()
	Reminder_EnsureParent()

	local shouldShow = manualTest
	if shouldShow == preview then
		if shouldShow then
			Reminder_LayoutSamples()
			for i = 1, #testFrames do
				Reminder_SetGlowVisible(testFrames[i], testFrames[i]:IsShown())
			end
		end
		return
	end
	preview = shouldShow

	if shouldShow then
		for _, frame in ipairs(frames) do
			Reminder_HideFrame(frame)
		end
		Reminder_BuildSamples()
		parentFrame:Show()
		for i = 1, #testFrames do
			Reminder_ShowFrame(testFrames[i])
		end
		Reminder_LayoutSamples()
	else
		for i = 1, #testFrames do
			Reminder_HideFrame(testFrames[i])
		end
		if C["Auras"].Reminder and groups then
			Reminder_RunUpdate()
		else
			Module:Reminder_UpdateAnchor()
			parentFrame:Hide()
		end
	end
end

function Module:Reminder_ToggleTest()
	manualTest = not manualTest
	self:Reminder_RefreshPreview()
	if manualTest then
		K.Print(K.InfoColor .. L["Auras Reminder (Shout/Intellect/Poison)"] .. ":|r " .. (L["Reminder Test On"] or "Test mode on — use /moveui to position."))
	else
		K.Print(K.InfoColor .. L["Auras Reminder (Shout/Intellect/Poison)"] .. ":|r " .. (L["Reminder Test Off"] or "Test mode off."))
	end
end

function Module:Reminder_ApplyGlow()
	for _, frame in ipairs(frames) do
		Reminder_SetGlowVisible(frame, frame:IsShown())
	end
	for i = 1, #testFrames do
		Reminder_SetGlowVisible(testFrames[i], testFrames[i]:IsShown())
	end
end

local function RegisterEvents()
	if isRegistered then
		return
	end
	isRegistered = true

	K:RegisterUnitEvent("UNIT_AURA", Module.Reminder_OnEvent, "player")
	K:RegisterUnitEvent("UNIT_EXITED_VEHICLE", Module.Reminder_OnEvent, "player")
	K:RegisterUnitEvent("UNIT_ENTERED_VEHICLE", Module.Reminder_OnEvent, "player")
	K:RegisterEvent("PLAYER_REGEN_ENABLED", Module.Reminder_OnEvent)
	K:RegisterEvent("PLAYER_REGEN_DISABLED", Module.Reminder_OnEvent)
	K:RegisterEvent("ZONE_CHANGED_NEW_AREA", Module.Reminder_OnEvent)
	K:RegisterEvent("PLAYER_ENTERING_WORLD", Module.Reminder_OnEvent)
	K:RegisterEvent("WEAPON_ENCHANT_CHANGED", Module.Reminder_OnEvent)
end

local function UnregisterEvents()
	if not isRegistered then
		return
	end
	isRegistered = false

	K:UnregisterEvent("UNIT_AURA", Module.Reminder_OnEvent)
	K:UnregisterEvent("UNIT_EXITED_VEHICLE", Module.Reminder_OnEvent)
	K:UnregisterEvent("UNIT_ENTERED_VEHICLE", Module.Reminder_OnEvent)
	K:UnregisterEvent("PLAYER_REGEN_ENABLED", Module.Reminder_OnEvent)
	K:UnregisterEvent("PLAYER_REGEN_DISABLED", Module.Reminder_OnEvent)
	K:UnregisterEvent("ZONE_CHANGED_NEW_AREA", Module.Reminder_OnEvent)
	K:UnregisterEvent("PLAYER_ENTERING_WORLD", Module.Reminder_OnEvent)
	K:UnregisterEvent("WEAPON_ENCHANT_CHANGED", Module.Reminder_OnEvent)
end

function Module:CreateReminder()
	Module:Reminder_AddItemGroup()

	if not next(groups) then
		Reminder_EnsureParent()
		return
	end

	if C["Auras"].Reminder then
		Reminder_EnsureParent()
		iconSize = Reminder_IconSize()
		parentFrame:SetSize(iconSize, iconSize)
		parentFrame:Show()
		RegisterEvents()
		Module.Reminder_OnEvent()
	else
		if parentFrame then
			parentFrame:Hide()
		end
		for _, frame in ipairs(frames) do
			Reminder_HideFrame(frame)
		end
		UnregisterEvents()
		if manualTest then
			manualTest = false
			preview = false
		end
	end
end

local function OnReminderSettingChanged()
	Module:CreateReminder()
	Module:Reminder_ApplyGlow()
end

K:RegisterSettingCallback("Auras.Reminder", OnReminderSettingChanged)
K:RegisterSettingCallback("Auras.ReminderGlow", OnReminderSettingChanged)
