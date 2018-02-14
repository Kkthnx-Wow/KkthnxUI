local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("ProfessionTrainAll", "AceEvent-3.0", "AceHook-3.0")

local _G = _G

local ALL = _G.ALL
local BuyTrainerService = BuyTrainerService
local CreateFrame = _G.CreateFrame
local GetNumTrainerServices = _G.GetNumTrainerServices
local GetTrainerServiceCost = _G.GetTrainerServiceCost
local GetTrainerServiceInfo = _G.GetTrainerServiceInfo
local select = _G.select
local TOTAL = _G.TOTAL
local TRAIN = _G.TRAIN

function Module:ButtonCreate()
	self.button = CreateFrame("Button", "TradeSkillCreateTrainAllButton", ClassTrainerFrame, "MagicButtonTemplate")
	self.button:SetPoint("TOPRIGHT", ClassTrainerTrainButton, "TOPLEFT")
	self.button:SetPoint("LEFT", ClassTrainerFrameMoneyBg, "RIGHT", 2, 0) -- make the button as big as we can
	self.button:SetText(TRAIN.." "..ALL)

	self.button:SetScript("OnClick", function()
		for i = 1, GetNumTrainerServices() do
			if select(3, GetTrainerServiceInfo(i)) == "available" then
				BuyTrainerService(i)
			end
		end
	end)

	self.button:HookScript("OnEnter", function()
		local cost = 0
		for i = 1, GetNumTrainerServices() do
			if select(3, GetTrainerServiceInfo(i)) == "available" then
				cost = cost + GetTrainerServiceCost(i)
			end
		end

		GameTooltip:SetOwner(self.button,"ANCHOR_TOPRIGHT", 0, 4)
		GameTooltip:SetText("|cffffffff"..TOTAL.."|r "..K.FormatMoney(cost))
	end)

	self.button:HookScript("OnLeave", function()
		GameTooltip:Hide()
	end)
end

function Module:ButtonUpdate()
	for i = 1, GetNumTrainerServices() do
		if ClassTrainerTrainButton:IsEnabled() and select(3, GetTrainerServiceInfo(i)) == "available" then
			self.button:Enable()
			return
		end
	end

	self.button:Disable()
end

function Module:ADDON_LOADED(_, addon)
	if addon ~= "Blizzard_TrainerUI" then return end

	self:ButtonCreate()
	if not self:IsHooked("ClassTrainerFrame_Update") then
		self:SecureHook("ClassTrainerFrame_Update", "ButtonUpdate")
	end

	self:UnregisterEvent("ADDON_LOADED")
end

function Module:ToggleState()
	if not self.button then
		self:RegisterEvent("ADDON_LOADED")
	else
		self.button:Show()
		if not self:IsHooked("ClassTrainerFrame_Update") then
			self:SecureHook("ClassTrainerFrame_Update", "ButtonUpdate")
		end
	end
end

function Module:OnInitialize()
	-- if C["Misc"].TrainAll ~= true then return end
	self:ToggleState()
end