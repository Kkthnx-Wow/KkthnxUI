local K, C = unpack(select(2, ...))

-- Sourced: NDui (siweia)

local _G = _G
local unpack = _G.unpack

local C_Garrison_GetClassSpecCategoryInfo = _G.C_Garrison.GetClassSpecCategoryInfo
local C_Garrison_GetCurrencyTypes = _G.C_Garrison.GetCurrencyTypes
local C_Garrison_IsPlayerInGarrison = _G.C_Garrison.IsPlayerInGarrison
local C_Garrison_RequestClassSpecCategoryInfo = _G.C_Garrison.RequestClassSpecCategoryInfo
local CreateFrame = _G.CreateFrame
local GameTooltip = _G.GameTooltip
local GetCurrencyInfo = _G.GetCurrencyInfo
local IsShiftKeyDown = _G.IsShiftKeyDown
local LE_FOLLOWER_TYPE_GARRISON_7_0 = _G.LE_FOLLOWER_TYPE_GARRISON_7_0
local LE_GARRISON_TYPE_7_0 = _G.LE_GARRISON_TYPE_7_0
local UIParent = _G.UIParent

local hall = CreateFrame("Frame", "KKUIOrderHallIcon", UIParent)
hall:SetSize(40, 40)
hall:SetPoint("TOPLEFT", 4, -4)
hall:SetFrameStrata("HIGH")
hall:Hide()
hall:CreateBorder()
K.CreateMoverFrame(hall)
hall.Icon = hall:CreateTexture(nil, "ARTWORK")
hall.Icon:SetAllPoints()
if C["General"].PortraitStyle.Value == "NewClassPortraits" then
	local betterClassIcons = "Interface\\AddOns\\KkthnxUI\\Media\\Unitframes\\BetterClassIcons\\%s.tga"
	hall.Icon:SetTexture(betterClassIcons:format(K.Class))
	hall.Icon:SetTexCoord(0.15, 0.85, 0.15, 0.85)
else
	hall.Icon:SetTexture("Interface\\WorldStateFrame\\ICONS-CLASSES")
	hall.Icon:SetTexCoord(unpack(CLASS_ICON_TCOORDS[K.Class]))
end
hall.Category = {}

local function RetrieveData(self)
	local currency = C_Garrison_GetCurrencyTypes(LE_GARRISON_TYPE_7_0)
	self.name, self.amount, self.texture = GetCurrencyInfo(currency)

	local categoryInfo = C_Garrison_GetClassSpecCategoryInfo(LE_FOLLOWER_TYPE_GARRISON_7_0)
	self.numCategory = #categoryInfo
	for i, category in ipairs(categoryInfo) do
		self.Category[i] = {category.name, category.count, category.limit, category.description, category.icon}
	end
end

hall:RegisterUnitEvent("UNIT_AURA", "player")
hall:RegisterEvent("PLAYER_ENTERING_WORLD")
hall:RegisterEvent("ADDON_LOADED")
hall:SetScript("OnEvent", function(self, event, arg1)
	if event == "ADDON_LOADED" and arg1 == "Blizzard_OrderHallUI" then
		OrderHallCommandBar:Hide()
		OrderHallCommandBar.Show = K.Noop
		GarrisonLandingPageTutorialBox:SetClampedToScreen(true)
		self:UnregisterEvent("ADDON_LOADED")
	elseif event == "UNIT_AURA" or event == "PLAYER_ENTERING_WORLD" then
		local inOrderHall = C_Garrison_IsPlayerInGarrison(LE_GARRISON_TYPE_7_0)
		self:SetShown(inOrderHall)
	elseif event == "MODIFIER_STATE_CHANGED" and arg1 == "LSHIFT" then
		self:GetScript("OnEnter")(self)
	end
end)

hall:SetScript("OnEnter", function(self)
	C_Garrison_RequestClassSpecCategoryInfo(LE_FOLLOWER_TYPE_GARRISON_7_0)
	RetrieveData(self)

	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 5, -5)
	GameTooltip:ClearLines()
	GameTooltip:AddLine(K.MyClassColor.._G["ORDER_HALL_"..K.Class])
	GameTooltip:AddLine(" ")

	local icon = " |T"..self.texture..":12:12:0:0:50:50:4:46:4:46|t "
	GameTooltip:AddDoubleLine(self.name, self.amount..icon, 1, 1, 1, 1, 1, 1)

	local blank
	for i = 1, self.numCategory do
		if not blank then
			GameTooltip:AddLine(" ")
			blank = true
		end

		local name, count, limit, description = unpack(self.Category[i])
		GameTooltip:AddDoubleLine(name, count.."/"..limit, 1, 1, 1, 1, 1, 1)

		if IsShiftKeyDown() then
			GameTooltip:AddLine(description, 0.6, 0.8, 1, true)
		end
	end
	GameTooltip:AddLine(" ")
	GameTooltip:AddLine("Hold SHIFT For Details")
	GameTooltip:Show()

	self:RegisterEvent("MODIFIER_STATE_CHANGED")
end)

hall:SetScript("OnLeave", function(self)
	GameTooltip:Hide()
	self:UnregisterEvent("MODIFIER_STATE_CHANGED")
end)