--[[-----------------------------------------------------------------------------
	Addon: KkthnxUI
	File: Modules/Bags/BagBar.lua
	Purpose:
		A compact, movable bag bar. The backpack, bag slots, and reagent bag are
		reparented onto our own bar, sized to a row, given a slot background and our
		border, and their icons squared off (the stock round CircleMask is hidden).
		Blizzard re-applies its own skin on UpdateTextures and re-lays the BagsBar,
		so both are hooked to keep our look. Retail only for now.
-----------------------------------------------------------------------------]]

local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]

if not (K.Client and K.Client.IsRetail) then
	return
end

local Module = K:NewModule("BagBar")

local _G = _G
local pcall = pcall
local hooksecurefunc = hooksecurefunc
local InCombatLockdown = InCombatLockdown
local GetItemButtonIconTexture = GetItemButtonIconTexture

local BUTTONS = {
	"MainMenuBarBackpackButton",
	"CharacterBag0Slot",
	"CharacterBag1Slot",
	"CharacterBag2Slot",
	"CharacterBag3Slot",
	"CharacterReagentBag0Slot",
}

-- Stand-in bag icon for the backpack (and any empty slot), so it never reads as a
-- blank square. The client hands empty slots this default texture id.
local BACKPACK_ICON = 133633 -- INV_Misc_Bag_07
local DEFAULT_TEX = 1721259

local bar

local function IconOf(btn, name)
	return (GetItemButtonIconTexture and GetItemButtonIconTexture(btn)) or _G[name .. "IconTexture"] or btn.icon or btn.Icon
end

-- Square off and fit the icon. Bag swaps and Blizzard's UpdateTextures reset this,
-- so it is re-applied from those hooks.
local function CropIcon(btn, name)
	local icon = IconOf(btn, name)
	if not icon then
		return
	end
	local tex = icon:GetTexture()
	if name == "MainMenuBarBackpackButton" or not tex or tex == DEFAULT_TEX then
		icon:SetTexture(BACKPACK_ICON)
	end
	icon.Show = nil
	icon:Show()
	icon:ClearAllPoints()
	icon:SetPoint("TOPLEFT", btn, "TOPLEFT", 1, -1)
	icon:SetPoint("BOTTOMRIGHT", btn, "BOTTOMRIGHT", -1, 1)
	icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
end

-- Re-hide the art Blizzard restores on UpdateTextures (the round mask especially).
local function StripStock(btn)
	local nt = btn.GetNormalTexture and btn:GetNormalTexture()
	if nt then
		nt:SetAlpha(0)
	end
	local ht = btn.GetHighlightTexture and btn:GetHighlightTexture()
	if ht then
		ht:SetAlpha(0)
	end
	local pt = btn.GetPushedTexture and btn:GetPushedTexture()
	if pt then
		pt:SetAlpha(0)
	end
	if btn.CircleMask then
		btn.CircleMask:Hide()
	end
	if btn.IconBorder then
		btn.IconBorder:SetAlpha(0)
	end
	if btn.SlotHighlightTexture then
		btn.SlotHighlightTexture:SetAlpha(0)
	end
end

local function ReapplyIcons()
	for _, name in ipairs(BUTTONS) do
		local btn = _G[name]
		if btn and btn.__kkuiBag then
			StripStock(btn)
			CropIcon(btn, name)
		end
	end
end

local function Layout()
	if not bar then
		return
	end
	local cfg = C.BagBar
	local size = cfg.ButtonSize
	local space = cfg.Spacing
	local x, count = 0, 0

	for _, name in ipairs(BUTTONS) do
		local btn = _G[name]
		if btn and btn.__kkuiBag then
			-- Re-assert the parent: Blizzard's BagsBar layout reparents the buttons
			-- back to itself, which is what made them snap away.
			if btn:GetParent() ~= bar then
				btn:SetParent(bar)
			end
			btn:ClearAllPoints()
			btn:SetSize(size, size)
			btn:SetPoint("LEFT", bar, "LEFT", x, 0)
			x = x + size + space
			count = count + 1
		end
	end

	bar:SetSize(math.max(1, x - space), size)
	return count
end

local function Skin(btn, name)
	if btn.__kkuiBag then
		return
	end
	btn.__kkuiBag = true

	btn:SetParent(bar)
	StripStock(btn)
	K.CreateBackground(btn, 0.06, 0.06, 0.06, 0.9)
	CropIcon(btn, name)

	if not btn.KKUI_Border then
		K.CreateBorder(btn)
	end

	-- Blizzard restores its skin (round mask, normal texture) here, re-apply ours.
	if btn.UpdateTextures and not btn.__kkuiHook then
		btn.__kkuiHook = true
		hooksecurefunc(btn, "UpdateTextures", function(self)
			StripStock(self)
			CropIcon(self, self:GetName())
		end)
	end
end

function Module:Setup()
	if self.setupDone then
		return
	end
	self.setupDone = true

	local hidden = _G.KKUI_HiddenParent
	if not hidden then
		hidden = CreateFrame("Frame", "KKUI_HiddenParent", UIParent)
		hidden:Hide()
	end

	bar = CreateFrame("Frame", "KKUI_BagBar", UIParent)
	bar:SetSize(200, C.BagBar.ButtonSize)

	-- Take the Blizzard container out of play so it stops re-laying the buttons.
	-- The real culprit is not frame events: BagsBar:Layout is driven through the
	-- EventRegistry callback "MainMenuBarManager.OnExpandChanged" and the bag
	-- manager's CURSOR_CHANGED (fires on every item pickup / auto-expand), which
	-- UnregisterAllEvents does not remove. Drop those callbacks so Layout stops
	-- firing, and keep a Layout hook as a safety net.
	local bagsBar = _G.BagsBar
	if bagsBar then
		bagsBar:UnregisterAllEvents()
		if _G.EventRegistry then
			_G.EventRegistry:UnregisterCallback("MainMenuBarManager.OnExpandChanged", bagsBar)
		end
		if bagsBar.Layout then
			hooksecurefunc(bagsBar, "Layout", function()
				if not InCombatLockdown() then
					Layout()
				end
			end)
		end
		bagsBar:SetParent(hidden)
	end

	if _G.EventRegistry and _G.MainMenuBarBagManager then
		_G.EventRegistry:UnregisterFrameEventAndCallback("CURSOR_CHANGED", _G.MainMenuBarBagManager)
		_G.EventRegistry:UnregisterFrameEventAndCallback("EXPAND_BAG_BAR_CHANGED", _G.MainMenuBarBagManager)
	end
	local toggle = _G.BagBarExpandToggle
	if toggle then
		toggle:UnregisterAllEvents()
		toggle:SetParent(hidden)
		toggle:Hide()
	end

	for _, name in ipairs(BUTTONS) do
		local btn = _G[name]
		if btn then
			pcall(Skin, btn, name)
		end
	end

	-- Keep Blizzard's backpack free-slot count, anchored cleanly.
	local count = _G.MainMenuBarBackpackButtonCount
	if count then
		count:ClearAllPoints()
		count:SetPoint("BOTTOM", _G.MainMenuBarBackpackButton, "BOTTOM", 0, 2)
	end

	Layout()
	-- Sit 6px above the micro menu, right-aligned. Falls back to the corner if the
	-- micro menu is off.
	local micro = _G.KKUI_MicroMenu
	local point = micro and { "BOTTOMRIGHT", micro, "TOPRIGHT", 0, 6 } or { "BOTTOMRIGHT", UIParent, "BOTTOMRIGHT", -4, 34 }
	K.CreateMover(bar, "BagBar", L["Bag Bar"], point, bar:GetWidth(), bar:GetHeight())

	self:RegisterEvent("BAG_UPDATE_DELAYED", ReapplyIcons)
	-- Reparenting is blocked in combat, so re-assert the layout once it ends.
	self:RegisterEvent("PLAYER_REGEN_ENABLED", function()
		Layout()
		ReapplyIcons()
	end)
end

function Module:OnEnable()
	if not C.BagBar.Enable then
		return
	end
	self:Setup()
end
