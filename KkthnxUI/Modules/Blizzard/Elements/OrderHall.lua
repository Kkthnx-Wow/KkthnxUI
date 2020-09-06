local K, C = unpack(select(2, ...))
local Module = K:GetModule("Blizzard")

-- Sourced: NDui (siweia)

local _G = _G

local ipairs, format = _G.ipairs, _G.format
local GetCurrencyInfo, IsShiftKeyDown = _G.GetCurrencyInfo, _G.IsShiftKeyDown
local C_Garrison_GetCurrencyTypes = _G.C_Garrison.GetCurrencyTypes
local C_Garrison_GetClassSpecCategoryInfo = _G.C_Garrison.GetClassSpecCategoryInfo
local C_Garrison_RequestClassSpecCategoryInfo = _G.C_Garrison.RequestClassSpecCategoryInfo
local LE_GARRISON_TYPE_7_0, LE_FOLLOWER_TYPE_GARRISON_7_0 = _G.LE_GARRISON_TYPE_7_0, _G.LE_FOLLOWER_TYPE_GARRISON_7_0

function Module:OrderHall_CreateIcon()
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
	hall.Icon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[K.Class]))
	hall.Category = {}

	hall:SetScript("OnEnter", Module.OrderHall_OnEnter)
	hall:SetScript("OnLeave", Module.OrderHall_OnLeave)

	hooksecurefunc(OrderHallCommandBar, "SetShown", function(_, state)
		hall:SetShown(state)
	end)

	-- Default objects
	K.HideInterfaceOption(OrderHallCommandBar)
	OrderHallCommandBar.CurrencyHitTest:Kill()
	GarrisonLandingPageTutorialBox:SetClampedToScreen(true)
end

function Module:OrderHall_Refresh()
	C_Garrison_RequestClassSpecCategoryInfo(LE_FOLLOWER_TYPE_GARRISON_7_0)
	local currency = C_Garrison_GetCurrencyTypes(LE_GARRISON_TYPE_7_0)
	self.name, self.amount, self.texture = GetCurrencyInfo(currency)

	local categoryInfo = C_Garrison_GetClassSpecCategoryInfo(LE_FOLLOWER_TYPE_GARRISON_7_0)
	for index, info in ipairs(categoryInfo) do
		local category = self.Category
		if not category[index] then
			category[index] = {}
		end
		category[index].name = info.name
		category[index].count = info.count
		category[index].limit = info.limit
		category[index].description = info.description
		category[index].icon = info.icon
	end

	self.numCategory = #categoryInfo
end

function Module:OrderHall_OnShiftDown(btn)
	if btn == "LSHIFT" then
		Module.OrderHall_OnEnter(Module.OrderHallIcon)
	end
end

local function getIconString(texture)
	return format("|T%s:12:12:0:0:64:64:5:59:5:59|t ", texture)
end

function Module:OrderHall_OnEnter()
	Module.OrderHall_Refresh(self)

	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 5, -5)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(K.MyClassColor.._G["ORDER_HALL_"..K.Class])
	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine(getIconString(self.texture)..self.name, self.amount, 1,1,1, 1,1,1)

	local blank
	for i = 1, self.numCategory do
		if not blank then
			GameTooltip:AddLine(" ")
			blank = true
		end

		local category = self.Category[i]
		if category then
			GameTooltip:AddDoubleLine(getIconString(category.icon)..category.name, category.count.."/"..category.limit, 1,1,1, 1,1,1)
			if IsShiftKeyDown() then
				GameTooltip:AddLine(category.description, .6,.8,1, 1)
			end
		end
	end

	GameTooltip:AddLine(" ")
	GameTooltip:AddDoubleLine("Shift:", "Expand Details", 1, 1, 1, 0.6, 0.8, 1)
	GameTooltip:Show()

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
	if IsAddOnLoaded("Blizzard_OrderHallUI") then
		Module:OrderHall_CreateIcon()
	else
		K:RegisterEvent("ADDON_LOADED", Module.OrderHall_OnLoad)
	end
end