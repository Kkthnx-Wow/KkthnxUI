local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("Miscellaneous")

local _G = _G
local select = select

local BuyTrainerService = _G.BuyTrainerService
local CreateFrame = _G.CreateFrame
local GetNumTrainerServices = _G.GetNumTrainerServices
local GetTrainerServiceInfo = _G.GetTrainerServiceInfo
local hooksecurefunc = _G.hooksecurefunc

function Module:ADDON_LOADED(event, addon)
	if addon == "Blizzard_TrainerUI" then
		local button = CreateFrame("Button", "ClassTrainerTrainAllButton", ClassTrainerFrame, "MagicButtonTemplate")
		button:SetText(ACHIEVEMENTFRAME_FILTER_ALL)
		button:SetPoint("TOPRIGHT", ClassTrainerTrainButton, "TOPLEFT")
		button:SetPoint("RIGHT", ClassTrainerFrameMoneyFrame, "RIGHT")
		button:SetScript("OnClick", function()
			for i = 1, GetNumTrainerServices() do
				if select(2, GetTrainerServiceInfo(i)) == "available" then
					BuyTrainerService(i)
				end
			end
		end)

		hooksecurefunc("ClassTrainerFrame_Update", function()
			for i = 1, GetNumTrainerServices() do
				if ClassTrainerTrainButton:IsEnabled() and select(2, GetTrainerServiceInfo(i)) == "available" then
					button:Enable()
					return
				end
			end

			button:Disable()
		end)
	end
end

function Module:OnEnable()
	self:RegisterEvent("ADDON_LOADED")
end

function Module:OnDisable()
	self:UnregisterEvent("ADDON_LOADED")
end