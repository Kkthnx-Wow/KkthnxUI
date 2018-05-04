local K, C, L = unpack(select(2, ...))

-- Lua
local _G = _G
local print = print

-- API
local CreateFrame = _G.CreateFrame
local hooksecurefunc = _G.hooksecurefunc
local InCombatLockdown = _G.InCombatLockdown
local IsAltKeyDown = _G.IsAltKeyDown
local L_ToggleDropDownMenu = _G.L_ToggleDropDownMenu
local L_UIDropDownMenu_AddButton = _G.L_UIDropDownMenu_AddButton
local L_UIDropDownMenu_CreateInfo = _G.L_UIDropDownMenu_CreateInfo
local L_UIDropDownMenu_Initialize = _G.L_UIDropDownMenu_Initialize

-- GLOBALS: UIParent, SHOW_BATTLEFIELDMINIMAP_PLAYERS, LOCK_BATTLEFIELDMINIMAP, BATTLEFIELDMINIMAP_OPACITY_LABEL
-- GLOBALS: BattlefieldMinimapTabDropDown_TogglePlayers, BattlefieldMinimapTabDropDown_ToggleLock
-- GLOBALS: BattlefieldMinimapTabDropDown_ShowOpacity, BattlefieldMinimap_UpdateOpacity
-- GLOBALS: L_UIDROPDOWNMENU_MENU_LEVEL, BattlefieldMinimapCloseButton, BattlefieldMinimapOptions
-- GLOBALS: BattlefieldMinimapCorner, BattlefieldMinimapBackground, BattlefieldMinimapTab, BattlefieldMinimapTabLeft
-- GLOBALS: BattlefieldMinimapTabMiddle, BattlefieldMinimapTabRight, OpacityFrame

local scale = 1.0
local min, max = 0.5, 3.0

local function LoadSkin()
	local BattlefieldMinimap = _G["BattlefieldMinimap"]

	BattlefieldMinimap:SetClampedToScreen(true)
	BattlefieldMinimapCorner:Kill()
	BattlefieldMinimapBackground:Kill()
	BattlefieldMinimapTab:Kill()
	BattlefieldMinimapTabLeft:Kill()
	BattlefieldMinimapTabMiddle:Kill()
	BattlefieldMinimapTabRight:Kill()

	BattlefieldMinimap:CreateBackdrop("Transparent")
	BattlefieldMinimap.Backdrop:SetPoint("BOTTOMRIGHT", -6, 4)
	BattlefieldMinimap:SetFrameStrata("LOW")
	BattlefieldMinimapCloseButton:ClearAllPoints()
	BattlefieldMinimapCloseButton:SetPoint("TOPRIGHT", -4, 0)
	BattlefieldMinimapCloseButton:SkinCloseButton()
	BattlefieldMinimapCloseButton:SetFrameStrata("MEDIUM")

	BattlefieldMinimap:EnableMouse(true)
	BattlefieldMinimap:SetMovable(true)
	BattlefieldMinimap:EnableMouseWheel(true)

	BattlefieldMinimap:SetScript("OnMouseWheel", function(frame, delta)
		if not IsAltKeyDown() or InCombatLockdown() then
			print("You are either in combat or not holding down alt when try to scale the BattlefieldMinimap!")
			return
		end

		if delta > 0 then
			scale = scale + 0.25
		elseif delta < 0 then
			scale = scale - 0.25
		end

		if scale > max then
			scale = max
		end

		if scale < min
		then scale = min
		end

		BattlefieldMinimap:SetScale(scale)
	end)

	-- Custom dropdown to avoid using regular DropDownMenu code (taints)
	local function BattlefieldMinimapTabDropDown_Initialize()
		local info = L_UIDropDownMenu_CreateInfo()

		-- Show battlefield players
		info.text = SHOW_BATTLEFIELDMINIMAP_PLAYERS
		info.func = BattlefieldMinimapTabDropDown_TogglePlayers
		info.checked = BattlefieldMinimapOptions and BattlefieldMinimapOptions.showPlayers or false
		info.isNotRadio = true
		L_UIDropDownMenu_AddButton(info, L_UIDROPDOWNMENU_MENU_LEVEL)

		-- Battlefield minimap lock
		info.text = LOCK_BATTLEFIELDMINIMAP
		info.func = BattlefieldMinimapTabDropDown_ToggleLock
		info.checked = BattlefieldMinimapOptions and BattlefieldMinimapOptions.locked or false
		info.isNotRadio = true
		L_UIDropDownMenu_AddButton(info, L_UIDROPDOWNMENU_MENU_LEVEL)

		-- Opacity
		info.text = BATTLEFIELDMINIMAP_OPACITY_LABEL
		info.func = BattlefieldMinimapTabDropDown_ShowOpacity
		info.notCheckable = true
		L_UIDropDownMenu_AddButton(info, L_UIDROPDOWNMENU_MENU_LEVEL)
	end

	local UIBattlefieldMinimapTabDropDown = CreateFrame("Frame", "UIBattlefieldMinimapTabDropDown", UIParent, "L_UIDropDownMenuTemplate")
	UIBattlefieldMinimapTabDropDown:SetID(1)
	UIBattlefieldMinimapTabDropDown:Hide()
	L_UIDropDownMenu_Initialize(UIBattlefieldMinimapTabDropDown, BattlefieldMinimapTabDropDown_Initialize, "MENU")

	BattlefieldMinimap:SetScript("OnMouseUp", function(self, btn)
		if btn == "LeftButton" then
			BattlefieldMinimapTab:StopMovingOrSizing()
			BattlefieldMinimapTab:SetUserPlaced(true)
			if OpacityFrame:IsShown() then OpacityFrame:Hide() end -- seem to be a bug with default ui in 4.0, we hide it on next click
		elseif btn == "RightButton" then
			L_ToggleDropDownMenu(1, nil, UIBattlefieldMinimapTabDropDown, self:GetName(), 0, -4)
			if OpacityFrame:IsShown() then OpacityFrame:Hide() end -- seem to be a bug with default ui in 4.0, we hide it on next click
		end
	end)

	BattlefieldMinimap:SetScript("OnMouseDown", function(self, btn)
		if btn == "LeftButton" and (BattlefieldMinimapOptions and not BattlefieldMinimapOptions.locked) then
			BattlefieldMinimapTab:StartMoving()
		end
	end)

	hooksecurefunc("BattlefieldMinimap_UpdateOpacity", function()
		local alpha = 1.0 - (BattlefieldMinimapOptions and BattlefieldMinimapOptions.opacity or 0);
		BattlefieldMinimap.Backdrop:SetAlpha(alpha)
	end)

	local oldAlpha
	BattlefieldMinimap:HookScript("OnEnter", function()
		oldAlpha = BattlefieldMinimapOptions and BattlefieldMinimapOptions.opacity or 0
		BattlefieldMinimap_UpdateOpacity(0)
	end)

	BattlefieldMinimap:HookScript("OnLeave", function()
		if oldAlpha then
			BattlefieldMinimap_UpdateOpacity(oldAlpha)
			oldAlpha = nil
		end
	end)

	BattlefieldMinimapCloseButton:HookScript("OnEnter", function()
		oldAlpha = BattlefieldMinimapOptions and BattlefieldMinimapOptions.opacity or 0
		BattlefieldMinimap_UpdateOpacity(0)
	end)

	BattlefieldMinimapCloseButton:HookScript("OnLeave", function()
		if oldAlpha then
			BattlefieldMinimap_UpdateOpacity(oldAlpha)
			oldAlpha = nil
		end
	end)
end

K.SkinFuncs["Blizzard_BattlefieldMinimap"] = LoadSkin