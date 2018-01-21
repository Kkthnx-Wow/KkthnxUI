local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("OrderHall", "AceEvent-3.0")

-- Credits
-- Lars "Goldpaw" Norberg for the design.

-- Lua API
local _G = _G

-- Wow API
local UIParent = _G.UIParent
local C_Timer_After = _G.C_Timer.After

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: OrderHallCommandBar

function Module:UpdateOrderHallUI()
	local frame = self.frame
	local bar = OrderHallCommandBar

	local index = 1
	C_Timer.After(0.4, function()
		local last
		for i, child in ipairs({bar:GetChildren()}) do
			if child.Icon and child.Count and child.TroopPortraitCover then
				child:ClearAllPoints()
				child:SetPoint("LEFT", bar.Currency, "RIGHT", 10 + (index-1) * 70, 0)
				child:SetWidth(60)

				child.TroopPortraitCover:Hide()
				child.Icon:ClearAllPoints()
				child.Icon:SetPoint("LEFT", child, "LEFT", 0, 0)
				child.Icon:SetSize(32, 16)

				child.Count:ClearAllPoints()
				child.Count:SetPoint("LEFT", child.Icon, "RIGHT", 5, 0)
				child.Count:SetTextColor(.9, .9, .9)
				child.Count:SetShadowOffset(.75, -.75)

				last = child.Count

				index = index + 1
			end
		end

		local firstX = bar.CurrencyIcon:GetLeft()
		local lastX = last and last:GetRight() or bar.Currency:GetRight()
		local width = lastX - firstX

		frame:SetWidth(width)
	end)
end

function Module:SetUpOrderHallUI()
	self:RegisterEvent("DISPLAY_SIZE_CHANGED", "UpdateOrderHallUI")
	self:RegisterEvent("UI_SCALE_CHANGED", "UpdateOrderHallUI")
	self:RegisterEvent("GARRISON_FOLLOWER_CATEGORIES_UPDATED", "UpdateOrderHallUI")
	self:RegisterEvent("GARRISON_FOLLOWER_ADDED", "UpdateOrderHallUI")
	self:RegisterEvent("GARRISON_FOLLOWER_REMOVED", "UpdateOrderHallUI")

	self.styled = false

	OrderHallCommandBar:HookScript("OnShow", function()
		local frame = self.frame

		if (not self.styled) then
			local bar = OrderHallCommandBar

			bar:EnableMouse(false)
			bar.Background:SetAtlas(nil)

			bar.ClassIcon:Hide()
			bar.AreaName:Hide()

			bar.CurrencyIcon:ClearAllPoints()
			bar.CurrencyIcon:SetPoint("LEFT", frame, "LEFT", 0, 0)

			bar.CurrencyHitTest:ClearAllPoints()
			bar.CurrencyHitTest:SetAllPoints(bar.CurrencyIcon)

			bar.Currency:ClearAllPoints()
			bar.Currency:SetPoint("LEFT", bar.CurrencyIcon, "RIGHT", 5, 0)
			bar.Currency:SetTextColor(.9, .9, .9)
			bar.Currency:SetShadowOffset(0.75, -.75)

			bar.WorldMapButton:UnregisterAllEvents()
			bar.WorldMapButton:Hide()

			self.styled = true
		end

		OrderHallCommandBar:SetPoint("TOP", frame, "CENTER", 0, 32)
	end)

	OrderHallCommandBar:HookScript("OnHide", function()
		OrderHallCommandBar:SetPoint("TOP", self.frame, "CENTER", 0, 32)
	end)
end

function Module:ApplySettings()
	if not self.frame then return end
	self:UpdatePosition()
end

function Module:UpdatePosition()
	self.frame:ClearAllPoints()
	self.frame:SetPoint("TOP", UIParent, "TOP", 0, -4)
end

function Module:ADDON_LOADED(_, addonName)
	if addonName == "Blizzard_OrderHallUI" then
		self:UnregisterEvent("ADDON_LOADED")
		self:SetUpOrderHallUI()
	end
end

function Module:OnInitialize()
	self.frame = CreateFrame("Frame", nil, UIParent)
	self.frame:SetSize(20, 20)

	if IsAddOnLoaded("Blizzard_OrderHallUI") then
		self:SetUpOrderHallUI()
	else
		self:RegisterEvent("ADDON_LOADED")
	end
end

function Module:OnEnable()
	self:ApplySettings()
end

function Module:OnDisable()
end