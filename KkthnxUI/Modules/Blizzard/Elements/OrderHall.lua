--[[-----------------------------------------------------------------------------
-- Addon: KkthnxUI
-- Author: Josh "Kkthnx" Russell
-- Notes:
-- - Purpose: Replaces the Order Hall command bar with a compact icon and detailed tooltip.
-- - Design: Hooks OrderHallCommandBar and queries garrison API for currency and category info.
-- - Events: ADDON_LOADED (Blizzard_OrderHallUI), MODIFIER_STATE_CHANGED
-----------------------------------------------------------------------------]]

local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Blizzard")

-- PERF: Localize globals and API functions to reduce lookup overhead.
local _G = _G
local C_CurrencyInfo_GetCurrencyInfo = _G.C_CurrencyInfo.GetCurrencyInfo
local C_Garrison_GetClassSpecCategoryInfo = _G.C_Garrison.GetClassSpecCategoryInfo
local C_Garrison_GetCurrencyTypes = _G.C_Garrison.GetCurrencyTypes
local C_Garrison_RequestClassSpecCategoryInfo = _G.C_Garrison.RequestClassSpecCategoryInfo
local CreateFrame = _G.CreateFrame
local GameTooltip = _G.GameTooltip
local IsShiftKeyDown = IsShiftKeyDown
local UIParent = _G.UIParent
local hooksecurefunc = hooksecurefunc
local ipairs = ipairs
local string_format = string.format
local unpack = unpack

-- ---------------------------------------------------------------------------
-- Constants
-- ---------------------------------------------------------------------------
local LE_GARRISON_TYPE_7_0 = _G.Enum.GarrisonType.Type_7_0_Garrison or _G.Enum.GarrisonType.Type_7_0
local LE_FOLLOWER_TYPE_GARRISON_7_0 = _G.Enum.GarrisonFollowerType.FollowerType_7_0_GarrisonFollower or _G.Enum.GarrisonFollowerType.FollowerType_7_0

-- ---------------------------------------------------------------------------
-- Internal Logic
-- ---------------------------------------------------------------------------
local function getIconString(texture)
	-- REASON: Formats a texture ID/path into a consistent inline chat/tooltip icon string.
	return string_format("|T%s:12:12:0:0:64:64:5:59:5:59|t ", texture)
end

function Module:OrderHall_Refresh()
	-- REASON: Dynamically updates the stored Order Hall data by querying the Blizzard Garrison and Currency APIs.
	C_Garrison_RequestClassSpecCategoryInfo(LE_FOLLOWER_TYPE_GARRISON_7_0)
	local currency = C_Garrison_GetCurrencyTypes(LE_GARRISON_TYPE_7_0)
	local info = C_CurrencyInfo_GetCurrencyInfo(currency)
	if info then
		self.name = info.name
		self.amount = info.quantity
		self.texture = info.iconFileID
	end

	local categoryInfo = C_Garrison_GetClassSpecCategoryInfo(LE_FOLLOWER_TYPE_GARRISON_7_0)
	for index, catData in ipairs(categoryInfo) do
		local category = self.Category
		if not category[index] then
			category[index] = {}
		end

		category[index].name = catData.name
		category[index].count = catData.count
		category[index].limit = catData.limit
		category[index].description = catData.description
		category[index].icon = catData.icon
	end

	self.numCategory = #categoryInfo
end

function Module:OrderHall_OnShiftDown(btn)
	-- REASON: Updates the tooltip visibility/content when the player toggles the Shift key.
	if btn == "LSHIFT" or btn == "RSHIFT" then
		Module.OrderHall_OnEnter(Module.OrderHallIcon)
	end
end

function Module:OrderHall_OnEnter()
	-- REASON: Populates and displays the detailed Order Hall tooltip on mouseover.
	Module.OrderHall_Refresh(self)

	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 5, -5)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(K.MyClassColor .. _G["ORDER_HALL_" .. K.Class])
	GameTooltip:AddLine(" ")
	if self.name then
		GameTooltip:AddDoubleLine(getIconString(self.texture) .. self.name, self.amount, 1, 1, 1, 1, 1, 1)
	end

	local blank
	for i = 1, self.numCategory do
		if not blank then
			GameTooltip:AddLine(" ")
			blank = true
		end

		local category = self.Category[i]
		if category then
			GameTooltip:AddDoubleLine(getIconString(category.icon) .. category.name, category.count .. "/" .. category.limit, 1, 1, 1, 1, 1, 1)
			-- REASON: Shows extended descriptions only when holding Shift to avoid tooltip bloat.
			if IsShiftKeyDown() then
				GameTooltip:AddLine(category.description, 0.5, 0.7, 1, 1)
			end
		end
	end

	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine("Shift:", "Expand Details", 1, 1, 1, 0.5, 0.7, 1)
	GameTooltip:Show()

	K:RegisterEvent("MODIFIER_STATE_CHANGED", Module.OrderHall_OnShiftDown)
end

function Module:OrderHall_OnLeave()
	GameTooltip:Hide()
	K:UnregisterEvent("MODIFIER_STATE_CHANGED", Module.OrderHall_OnShiftDown)
end

-- ---------------------------------------------------------------------------
-- Initialization
-- ---------------------------------------------------------------------------
function Module:OrderHall_CreateIcon()
	-- REASON: Creates the physical Order Hall icon frame and sets up its behavior.
	local orderHallCommandBar = _G.OrderHallCommandBar
	if not orderHallCommandBar then
		return
	end

	local hall = CreateFrame("Frame", "KKUI_OrderHallIcon", UIParent)
	hall:SetSize(40, 40)
	hall:SetPoint("TOP", 0, -30)
	hall:SetFrameStrata("HIGH")
	hall:CreateBorder()
	hall:Hide()

	K.CreateMoverFrame(hall, nil, true)
	K.RestoreMoverFrame(hall)
	Module.OrderHallIcon = hall

	hall.Icon = hall:CreateTexture(nil, "ARTWORK")
	hall.Icon:SetAllPoints()
	hall.Icon:SetTexture("Interface\\WorldStateFrame\\ICONS-CLASSES")
	hall.Icon:SetTexCoord(unpack(_G.CLASS_ICON_TCOORDS[K.Class]))
	hall.Category = {}

	hall:SetScript("OnEnter", Module.OrderHall_OnEnter)
	hall:SetScript("OnLeave", Module.OrderHall_OnLeave)

	-- REASON: Mirrors the visibility of the original command bar to ensure it only shows when relevant.
	hooksecurefunc(orderHallCommandBar, "SetShown", function(_, state)
		hall:SetShown(state)
	end)

	-- WARNING: Hiding the original UI components to prevent visual overlaps.
	K.HideInterfaceOption(orderHallCommandBar)
	if orderHallCommandBar.CurrencyHitTest then
		orderHallCommandBar.CurrencyHitTest:Kill()
	end
end

function Module:OrderHall_OnLoad(event, addon)
	if addon == "Blizzard_OrderHallUI" then
		Module:OrderHall_CreateIcon()
		K:UnregisterEvent(event, Module.OrderHall_OnLoad)
	end
end

function Module:CreateOrderHallIcon()
	-- REASON: Registration entry point; ensures the Order Hall enhancement is loaded when available.
	if _G.C_AddOns.IsAddOnLoaded("Blizzard_OrderHallUI") then
		Module:OrderHall_CreateIcon()
	else
		K:RegisterEvent("ADDON_LOADED", Module.OrderHall_OnLoad)
	end
end
