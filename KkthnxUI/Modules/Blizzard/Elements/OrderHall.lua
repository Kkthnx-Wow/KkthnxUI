local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Blizzard")

-- Sourced: NDui (siweia)

local C_CurrencyInfo_GetCurrencyInfo = C_CurrencyInfo.GetCurrencyInfo
local C_Garrison_GetClassSpecCategoryInfo = C_Garrison.GetClassSpecCategoryInfo
local C_Garrison_GetCurrencyTypes = C_Garrison.GetCurrencyTypes
local C_Garrison_RequestClassSpecCategoryInfo = C_Garrison.RequestClassSpecCategoryInfo
local GameTooltip = GameTooltip
local C_AddOns_IsAddOnLoaded = C_AddOns.IsAddOnLoaded
local IsShiftKeyDown = IsShiftKeyDown
local LE_FOLLOWER_TYPE_GARRISON_7_0 = Enum.GarrisonFollowerType.FollowerType_7_0
local LE_GARRISON_TYPE_7_0 = Enum.GarrisonType.Type_7_0
local hooksecurefunc = hooksecurefunc

function Module:OrderHall_CreateIcon()
	local OrderHallCommandBar = OrderHallCommandBar

	-- Create the Order Hall icon frame
	local hall = CreateFrame("Frame", "KKUI_OrderHallIcon", UIParent)
	hall:SetSize(40, 40)
	hall:SetPoint("TOP", 0, -30)
	hall:SetFrameStrata("HIGH")
	hall:CreateBorder()
	hall:Hide()
	K.CreateMoverFrame(hall, nil, true)
	K.RestoreMoverFrame(hall)
	Module.OrderHallIcon = hall

	-- Set the icon texture and category
	hall.Icon = hall:CreateTexture(nil, "ARTWORK")
	hall.Icon:SetAllPoints()
	hall.Icon:SetTexture("Interface\\WorldStateFrame\\ICONS-CLASSES")
	hall.Icon:SetTexCoord(unpack(_G.CLASS_ICON_TCOORDS[K.Class]))
	hall.Category = {}

	-- Set up mouseover events and show/hide based on Order Hall Command Bar state
	hall:SetScript("OnEnter", Module.OrderHall_OnEnter)
	hall:SetScript("OnLeave", Module.OrderHall_OnLeave)
	hooksecurefunc(OrderHallCommandBar, "SetShown", function(_, state)
		hall:SetShown(state)
	end)

	-- Hide default objects
	K.HideInterfaceOption(OrderHallCommandBar)
	OrderHallCommandBar.CurrencyHitTest:Kill()
end

function Module:OrderHall_Refresh()
	-- Request class spec category info and get currency types
	C_Garrison_RequestClassSpecCategoryInfo(LE_FOLLOWER_TYPE_GARRISON_7_0)
	local currency = C_Garrison_GetCurrencyTypes(LE_GARRISON_TYPE_7_0)

	-- Get currency info and set name, amount, and texture
	local info = C_CurrencyInfo_GetCurrencyInfo(currency)
	self.name = info.name
	self.amount = info.quantity
	self.texture = info.iconFileID

	-- Get class spec category info and set category data
	local categoryInfo = C_Garrison_GetClassSpecCategoryInfo(LE_FOLLOWER_TYPE_GARRISON_7_0)
	for index, info in ipairs(categoryInfo) do
		if not self.Category[index] then
			self.Category[index] = {}
		end
		self.Category[index].name = info.name
		self.Category[index].count = info.count
		self.Category[index].limit = info.limit
		self.Category[index].description = info.description
		self.Category[index].icon = info.icon
	end

	-- Set the number of categories
	self.numCategory = #categoryInfo
end

function Module:OrderHall_OnShiftDown(btn)
	if btn == "LSHIFT" then
		Module.OrderHall_OnEnter(Module.OrderHallIcon)
	end
end

local function getIconString(texture)
	return string.format("|T%s:12:12:0:0:64:64:5:59:5:59|t ", texture)
end

function Module:OrderHall_OnEnter()
	Module.OrderHall_Refresh(self)

	-- Set up tooltip
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 5, -5)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(K.MyClassColor .. _G["ORDER_HALL_" .. K.Class])
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(getIconString(self.texture) .. self.name, self.amount, 1, 1, 1, 1, 1, 1)

	-- Add category data to tooltip
	local blank
	for i = 1, self.numCategory do
		if not blank then
			GameTooltip:AddLine(" ")
			blank = true
		end

		local category = self.Category[i]
		if category then
			GameTooltip:AddDoubleLine(getIconString(category.icon) .. category.name, category.count .. "/" .. category.limit, 1, 1, 1, 1, 1, 1)
			if IsShiftKeyDown() then
				GameTooltip:AddLine(category.description, 0.5, 0.7, 1, 1)
			end
		end
	end

	-- Add shift key details to tooltip
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine("Shift:", "Expand Details", 1, 1, 1, 0.5, 0.7, 1)
	GameTooltip:Show()

	-- Register shift key event
	K:RegisterEvent("MODIFIER_STATE_CHANGED", Module.OrderHall_OnShiftDown)
end

function Module:OrderHall_OnLeave()
	GameTooltip:Hide()
	K:UnregisterEvent("MODIFIER_STATE_CHANGED", Module.OrderHall_OnShiftDown)
end

function Module:OrderHall_OnLoad(addon)
	if addon == "Blizzard_OrderHallUI" then
		Module:OrderHall_CreateIcon()
		K:UnregisterEvent(self, Module.OrderHall_OnLoad)
	end
end

function Module:CreateOrderHallIcon()
	if C_AddOns_IsAddOnLoaded("Blizzard_OrderHallUI") then
		Module:OrderHall_CreateIcon()
	else
		K:RegisterEvent("ADDON_LOADED", Module.OrderHall_OnLoad)
	end
end
