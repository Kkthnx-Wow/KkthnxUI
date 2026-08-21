--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/CharacterFrame/Core.lua
	Purpose:
		A character sheet for the flavours that ship the old paper doll (TBC
		Anniversary and friends), laid out like retail's and built from Blizzard's
		own frame chrome so it reads as a native window rather than a KkthnxUI skin.
		Retail keeps its own frame, so this only builds elsewhere.

		The layout lives in KKUI_CharacterFrame.xml (ButtonFrameTemplate window,
		ItemButtonTemplate slots). This file wires the portrait, title, close, and
		model, and routes the character key to it. Slot behaviour is in Slots.lua.
		The stats pane and inspect window are hooked here (BuildStats/UpdateStats)
		but their files are not written yet, so those calls stay guarded.
-----------------------------------------------------------------------------]]

local K = KkthnxUI[1]

-- Retail already has its character frame, so only build our own where the old
-- paper doll model is in play.
if K.Client and K.Client.IsRetail then
	return
end

local Module = K:NewModule("CharacterFrame")

local _G = _G
local ipairs = ipairs
local tinsert = table.insert
local UnitName = UnitName
local SetPortraitTexture = SetPortraitTexture
local hooksecurefunc = hooksecurefunc
local InCombatLockdown = InCombatLockdown

-- The slots in layout order. Each name gains "Slot" for GetInventorySlotInfo and
-- matches a parentKey on the XML frame.
Module.SlotNames = {
	"Head", "Neck", "Shoulder", "Back", "Chest", "Shirt", "Tabard", "Wrist",
	"Hands", "Waist", "Legs", "Feet", "Finger0", "Finger1", "Trinket0", "Trinket1",
	"MainHand", "SecondaryHand", "Ranged",
}

-- ---------------------------------------------------------------------------
-- Window chrome
-- ---------------------------------------------------------------------------

local function SetWindowTitle(frame, unit)
	local name = UnitName(unit) or ""
	if frame.SetTitle then
		frame:SetTitle(name)
	elseif frame.TitleText then
		frame.TitleText:SetText(name)
	elseif _G[frame:GetName() .. "TitleText"] then
		_G[frame:GetName() .. "TitleText"]:SetText(name)
	end
end

local function SetWindowPortrait(frame, unit)
	local portrait = frame.portrait or frame.PortraitContainer and frame.PortraitContainer.portrait or _G[frame:GetName() .. "Portrait"]
	if portrait then
		SetPortraitTexture(portrait, unit)
	end
end

local function StyleWindow(frame)
	frame:RegisterForDrag("LeftButton")
	frame:SetScript("OnDragStart", frame.StartMoving)
	frame:SetScript("OnDragStop", frame.StopMovingOrSizing)
	frame:SetClampedToScreen(true)

	-- The ButtonFrameTemplate close button hides its panel through the UI panel
	-- manager, which our standalone frame is not part of, so drive Hide directly.
	local close = frame.CloseButton or _G[frame:GetName() .. "CloseButton"]
	if close then
		close:SetScript("OnClick", function()
			frame:Hide()
		end)
	end
end

-- ---------------------------------------------------------------------------
-- Model
-- ---------------------------------------------------------------------------

function Module:RefreshModel()
	local model = self.Frame and self.Frame.Model
	if not model then
		return
	end
	model:SetUnit(self.unit or "player")
end

-- ---------------------------------------------------------------------------
-- Slots
-- ---------------------------------------------------------------------------

function Module:StyleAllSlots()
	local frame = self.Frame
	self.slots = {}
	for _, base in ipairs(self.SlotNames) do
		local button = frame[base]
		if button then
			self:StyleSlot(button, base)
			self.slots[#self.slots + 1] = button
		end
	end
end

function Module:UpdateAllSlots()
	if not self.slots then
		return
	end
	for _, button in ipairs(self.slots) do
		self:UpdateSlot(button)
	end
end

-- ---------------------------------------------------------------------------
-- Open / close
-- ---------------------------------------------------------------------------

function Module:Toggle()
	local frame = self.Frame
	if not frame then
		return
	end
	frame:SetShown(not frame:IsShown())
end

function Module:OnShow()
	local unit = self.unit or "player"
	SetWindowTitle(self.Frame, unit)
	SetWindowPortrait(self.Frame, unit)
	self:RefreshModel()
	self:UpdateAllSlots()
	if self.UpdateStats then
		self:UpdateStats()
	end
end

function Module:OnEnable()
	local frame = _G.KKUI_CharacterFrame
	if not frame then
		return
	end
	self.Frame = frame
	self.unit = "player"

	-- Close on Escape like every other panel, instead of Escape opening the game
	-- menu on top of an open sheet.
	if _G.UISpecialFrames then
		tinsert(_G.UISpecialFrames, "KKUI_CharacterFrame")
	end

	StyleWindow(frame)
	self:StyleAllSlots()
	if self.BuildStats then
		self:BuildStats(frame)
	end

	frame:SetScript("OnShow", function()
		Module:OnShow()
	end)

	-- Keep our slots and model in step with gear and cooldown changes while open.
	frame:RegisterEvent("PLAYER_EQUIPMENT_CHANGED")
	frame:RegisterEvent("UNIT_INVENTORY_CHANGED")
	frame:RegisterEvent("BAG_UPDATE_COOLDOWN")
	frame:SetScript("OnEvent", function(_, event, unit)
		if not frame:IsShown() then
			return
		end
		if event == "UNIT_INVENTORY_CHANGED" and unit ~= "player" then
			return
		end
		Module:UpdateAllSlots()
	end)

	-- Route the character key to our window and keep Blizzard's paper doll hidden.
	-- ToggleCharacter always tries to show CharacterFrame, so hiding it on show and
	-- toggling ours in the same pass turns the key into our toggle.
	if _G.CharacterFrame then
		_G.CharacterFrame:HookScript("OnShow", function(self)
			if InCombatLockdown() then
				return
			end
			self:Hide()
		end)
		hooksecurefunc("ToggleCharacter", function()
			if InCombatLockdown() then
				return
			end
			Module:Toggle()
		end)
	end
end
