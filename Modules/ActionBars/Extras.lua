--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/ActionBars/Extras.lua
	Purpose:
		The extra buttons that sit outside the numbered bars: the encounter extra
		action button, the zone ability button, and the leave-vehicle button. Each
		is skinned to match and given its own mover. Blizzard (and Edit Mode) keep
		trying to re-anchor these, so the position is re-asserted from a SetPoint
		hook, out of combat only, and once more when combat ends. Blizzard still
		drives their visibility and contents.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

local _G = _G
local hooksecurefunc = hooksecurefunc
local InCombatLockdown = InCombatLockdown
local max = math.max

local Module = K:GetModule("ActionBars")

-- Give a Blizzard-owned frame its own mover and keep it pinned there. The frame
-- is anchored to an invisible holder we own, and any later re-anchor by Blizzard
-- is undone on the next safe moment.
-- width and height override the frame's own size, for a frame whose footprint is
-- mostly decorative art we hide (see the zone ability frame, which is 256 by 128
-- of styling around a 52 pixel button).
function Module:AttachExtraMover(frame, key, label, point, reparent, width, height)
	if not frame or frame.__kkuiExtra then
		return
	end
	frame.__kkuiExtra = true

	local w = width or ((frame:GetWidth() or 0) > 0 and frame:GetWidth() or C.ActionBar.ExtraBar.Size)
	local h = height or ((frame:GetHeight() or 0) > 0 and frame:GetHeight() or C.ActionBar.ExtraBar.Size)

	local holder = CreateFrame("Frame", "KKUI_" .. key .. "Holder", UIParent)
	holder:SetSize(w, h)
	frame.__kkuiMover = K.CreateMover(holder, key, label, point, w, h)
	frame.__kkuiHolder = holder

	local function Reanchor()
		if frame.__kkuiPinning or InCombatLockdown() then
			return
		end
		frame.__kkuiPinning = true
		-- Some of these get reparented by Edit Mode (the vehicle button back onto a
		-- hidden bar), so re-assert the parent as well when asked.
		if reparent and frame:GetParent() ~= UIParent then
			frame:SetParent(UIParent)
		end
		frame:ClearAllPoints()
		frame:SetPoint("CENTER", holder, "CENTER", 0, 0)
		frame.__kkuiPinning = false
	end

	Reanchor()
	hooksecurefunc(frame, "SetPoint", Reanchor)
	frame.__kkuiReanchor = Reanchor
end

-- Re-size a mover after the fact, for a frame whose useful area changes (the zone
-- ability row grows with the number of abilities on offer).
function Module:ResizeExtraMover(frame, w, h)
	if not frame or not w or not h or w <= 0 or h <= 0 then
		return
	end
	if frame.__kkuiHolder then
		frame.__kkuiHolder:SetSize(w, h)
	end
	if frame.__kkuiMover then
		frame.__kkuiMover:SetSize(w, h)
	end
end

-- Encounter / quest extra action button.
function Module:StyleExtraActionButton()
	local button = _G.ExtraActionButton1
	if not button then
		return
	end
	if button.style then
		button.style:SetAlpha(0)
	end
	self:StyleAuxButton(button)
	self:AttachExtraMover(button, "ExtraActionButton", L["Extra Action Button"], { "BOTTOM", UIParent, "BOTTOM", 0, 320 })
end

-- Zone ability (dragon glyphs, garrison abilities, etc.).
--
-- The buttons are not a fixed frame.SpellButton any more. They come out of a pool
-- on ZoneAbilityFrame.SpellButtonContainer, built fresh whenever the displayed
-- abilities change, so styling once at login skinned nothing at all. Walk the
-- active buttons after every update instead. StyleAuxButton marks what it has
-- already done, so a recycled button is not styled twice.
function Module:StyleZoneAbility()
	local frame = _G.ZoneAbilityFrame
	if not frame then
		return
	end
	if frame.Style then
		frame.Style:SetAlpha(0)
	end

	-- The template's own NormalTexture is UI-Quickslot2, anchored well outside the
	-- button (-16 to +17), so it reads as a second frame sitting around ours.
	-- StyleAuxButton clears it, but that work is guarded to run once per button and
	-- these come from a pool, so a button that is released and picked up again can
	-- come back wearing its art. Clear it on every update rather than trusting the
	-- one-shot pass.
	local function StripButtonArt(button)
		local normal = button.NormalTexture or (button.GetNormalTexture and button:GetNormalTexture())
		if normal then
			normal:SetTexture(nil)
			normal:SetAlpha(0)
		end
		if button.SetNormalTexture then
			button:SetNormalTexture(0)
		end

		-- Keep the hover inside our border instead of the oversized stock square.
		local highlight = button.GetHighlightTexture and button:GetHighlightTexture()
		if highlight then
			highlight:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
			highlight:ClearAllPoints()
			highlight:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
			highlight:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
			highlight:SetBlendMode("ADD")
		end

		-- Refresh re-sets the icon texture, so re-crop and re-anchor it to sit flush.
		if button.Icon then
			button.Icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
			button.Icon:ClearAllPoints()
			button.Icon:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
			button.Icon:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
		end
	end

	local function StyleButtons()
		-- The update re-assigns the frame's Style atlas every time, so keep it down.
		if frame.Style then
			frame.Style:SetAlpha(0)
		end
		local container = frame.SpellButtonContainer
		if not (container and container.EnumerateActive) then
			return
		end

		-- Size the mover to the buttons, not to the frame. The template is 256 by 128
		-- because that is the footprint of the Style art, which we hide, so measuring
		-- the frame gave a mover far bigger than anything visible. The row also grows
		-- with the number of abilities, so re-measure on every update.
		local count, width, height = 0, 0, 0
		for button in container:EnumerateActive() do
			Module:StyleAuxButton(button)
			StripButtonArt(button)
			count = count + 1
			width = width + (button:GetWidth() or 0)
			height = max(height, button:GetHeight() or 0)
		end
		if count > 0 then
			-- The container lays the buttons out with a 4 pixel gap between them.
			Module:ResizeExtraMover(frame, width + (count - 1) * 4, height)
		end
	end

	-- Start at one button's worth, and build the mover first so the pass below has a
	-- holder to measure into. StyleButtons re-sizes it once abilities show up.
	local size = C.ActionBar.ExtraBar.Size
	self:AttachExtraMover(frame, "ZoneAbility", L["Zone Ability"], { "BOTTOM", UIParent, "BOTTOM", 80, 320 }, nil, size, size)

	StyleButtons()
	if frame.UpdateDisplayedZoneAbilities then
		hooksecurefunc(frame, "UpdateDisplayedZoneAbilities", StyleButtons)
	end
end

-- Reuse Blizzard's secure leave-vehicle button, skinned and repositioned. It
-- manages its own show/hide, so no state driver is needed here.
function Module:StyleVehicleLeave()
	local button = _G.MainMenuBarVehicleLeaveButton
	if not button then
		return
	end

	-- It is a child of MainActionBar, which we reparent to a hidden frame to
	-- disable the stock bars, so it never showed. Pull it back onto UIParent.
	button:SetParent(UIParent)
	button:SetSize(C.ActionBar.ExtraBar.Size, C.ActionBar.ExtraBar.Size)

	-- Keep the original exit art: its icon IS the normal texture,
	-- so instead of stripping it we crop the button-frame padding off and fit it
	-- inside our border. Nuking it is what left the button blank.
	local normal = button:GetNormalTexture()
	if normal then
		normal:SetTexCoord(0.220625, 0.799375, 0.220625, 0.779375)
		normal:ClearAllPoints()
		normal:SetPoint("TOPLEFT", button, "TOPLEFT", 1, -1)
		normal:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -1, 1)
	end
	local pushed = button:GetPushedTexture()
	if pushed then
		pushed:SetTexCoord(0.140625, 0.859375, 0.140625, 0.859375)
		pushed:SetAllPoints(button)
	end
	local highlight = button:GetHighlightTexture()
	if highlight then
		highlight:SetTexture("Interface\\Buttons\\ButtonHilight-Square")
		highlight:SetAllPoints(button)
		highlight:SetBlendMode("ADD")
	end

	if not button.__kkuiVehicle then
		button.__kkuiVehicle = true
		K.CreateBackground(button, 0.06, 0.06, 0.06, 0.9)
		K.CreateBorder(button)
		-- These stock scripts taint through EditModeManager so we drop them. The
		-- mixin still drives visibility through its own events.
		button:SetScript("OnShow", nil)
		button:SetScript("OnHide", nil)
	end

	self:AttachExtraMover(button, "VehicleLeave", L["Leave Vehicle"], { "BOTTOM", UIParent, "BOTTOM", -80, 320 }, true)
end

-- Re-pin every extra once combat ends, since we skip re-anchoring in combat.
function Module:PinExtras()
	for _, key in ipairs({ "ExtraActionButton1", "ZoneAbilityFrame", "MainMenuBarVehicleLeaveButton" }) do
		local frame = _G[key]
		if frame and frame.__kkuiReanchor then
			frame.__kkuiReanchor()
		end
	end
end

function Module:CreateExtras()
	if not C.ActionBar.ExtraBar.Enable then
		return
	end
	self:StyleExtraActionButton()
	self:StyleZoneAbility()
	self:StyleVehicleLeave()

	self:RegisterEvent("PLAYER_REGEN_ENABLED", "PinExtras")
end
