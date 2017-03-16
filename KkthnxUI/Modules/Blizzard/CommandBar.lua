local K, C, L = unpack(select(2, ...))

-- Lua Wow
local _G = _G

-- API Wow
local IsAddOnLoaded = _G.IsAddOnLoaded
local LoadAddOn = _G.LoadAddOn

-- GLOBALS: OrderHallCommandBar, CommandBar_Init

-- Mine
local isInit = false

local function CommandBar_OnEnter(self)
	if not self.isShown then
		self.isShown = true
		self:SetPoint("TOP", 0, 2)
	end
end

local function CommandBar_OnLeave(self)
	if not self:IsMouseOver(0, -6, 0, 0) then
		self.isShown = false
		self:SetPoint("TOP", 0, 24)
	end
end

local function CommandBar_Init()
	if not isInit then
		local isLoaded = true

		if not IsAddOnLoaded("Blizzard_OrderHallUI") then
			isLoaded = LoadAddOn("Blizzard_OrderHallUI")
		end

		if isLoaded then
			OrderHallCommandBar:StripTextures()
			OrderHallCommandBar:CreateBackdrop()
			OrderHallCommandBar:ClearAllPoints()
			OrderHallCommandBar:SetPoint("TOP", 0, 24)
			OrderHallCommandBar:SetHitRectInsets(0, 0, 0, -8)
			OrderHallCommandBar.AreaName:ClearAllPoints()
			OrderHallCommandBar.Currency:SetPoint("LEFT", OrderHallCommandBar.ClassIcon, "RIGHT", 10, 0)
			OrderHallCommandBar.AreaName:SetPoint("LEFT", OrderHallCommandBar.CurrencyIcon, "RIGHT", 10, 2)
			OrderHallCommandBar:SetWidth(OrderHallCommandBar.AreaName:GetStringWidth() + 500)
			OrderHallCommandBar.ClassIcon:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
			OrderHallCommandBar.ClassIcon:SetSize(46, 20)
			OrderHallCommandBar.CurrencyIcon:SetAtlas("legionmission-icon-currency", false)
			OrderHallCommandBar.AreaName:SetVertexColor(K.Color.r, K.Color.g, K.Color.b)
			OrderHallCommandBar.WorldMapButton:Kill()
			OrderHallCommandBar:SetScript("OnEnter", CommandBar_OnEnter)
			OrderHallCommandBar:SetScript("OnLeave", CommandBar_OnLeave)

			isInit = true

			return true
		end
	end
end

local Loading = CreateFrame("Frame")
Loading:RegisterEvent("PLAYER_LOGIN")
Loading:SetScript("OnEvent", CommandBar_Init)