local K = unpack(select(2, ...))
if K.CheckAddOnState("Leatrix_Plus") then
	return
end

local _G = _G

local CreateFrame = _G.CreateFrame
local hooksecurefunc = _G.hooksecurefunc
local IsAddOnLoaded = _G.IsAddOnLoaded

-- Add Buttons To Main Dressup Frames
local DressUpNudeBtn = CreateFrame("Button", "Nude", DressUpFrame, "UIPanelButtonTemplate")
DressUpNudeBtn:SetPoint("BOTTOMLEFT", 106, 79)
DressUpNudeBtn:SetSize(80, 22)
DressUpNudeBtn:SetText("Nude")
DressUpNudeBtn:ClearAllPoints()
DressUpNudeBtn:SetPoint("RIGHT", DressUpFrameResetButton, "LEFT", 0, 0)
DressUpNudeBtn:SetScript("OnClick", function()
	DressUpFrameResetButton:Click() -- Done First In Case Any Slots Refuse To Clear
	for i = 1, 19 do
		DressUpModel:UndressSlot(i) -- Done This Way To Prevent Issues With Undress
	end
end)

local DressUpTabBtn = CreateFrame("Button", "Tabard", DressUpFrame, "UIPanelButtonTemplate")
DressUpTabBtn:SetPoint("BOTTOMLEFT", 26, 79)
DressUpTabBtn:SetSize(80, 22)
DressUpTabBtn:SetText("Tabard")
DressUpTabBtn:ClearAllPoints()
DressUpTabBtn:SetPoint("RIGHT", DressUpNudeBtn, "LEFT", 0, 0)
DressUpTabBtn:SetScript("OnClick", function()
	DressUpModel:UndressSlot(19)
end)

-- Only Show Dressup Buttons If Its A Player (Reset Button Will Show Too)
hooksecurefunc(DressUpFrameResetButton, "Show", function()
	DressUpNudeBtn:Show()
	DressUpTabBtn:Show()
end)

hooksecurefunc(DressUpFrameResetButton, "Hide", function()
	DressUpNudeBtn:Hide()
	DressUpTabBtn:Hide()
end)

local BtnStrata, BtnLevel = SideDressUpModelResetButton:GetFrameStrata(), SideDressUpModelResetButton:GetFrameLevel()

-- Add Buttons To Auction House Dressup Frame
local DressUpSideBtn = CreateFrame("Button", "Tabard", SideDressUpFrame, "UIPanelButtonTemplate")
DressUpSideBtn:SetPoint("BOTTOMLEFT", 14, 20)
DressUpSideBtn:SetSize(60, 22)
DressUpSideBtn:SetText("Tabard")
DressUpSideBtn:SetFrameStrata(BtnStrata)
DressUpSideBtn:SetFrameLevel(BtnLevel)
DressUpSideBtn:SetScript("OnClick", function()
	SideDressUpModel:UndressSlot(19)
end)

local DressUpSideNudeBtn = CreateFrame("Button", "Nude", SideDressUpFrame, "UIPanelButtonTemplate")
DressUpSideNudeBtn:SetPoint("BOTTOMRIGHT", -18, 20)
DressUpSideNudeBtn:SetSize(60, 22)
DressUpSideNudeBtn:SetText("Nude")
DressUpSideNudeBtn:SetFrameStrata(BtnStrata)
DressUpSideNudeBtn:SetFrameLevel(BtnLevel)
DressUpSideNudeBtn:SetScript("OnClick", function()
	SideDressUpModelResetButton:Click() -- Done First In Case Any Slots Refuse To Clear
	for i = 1, 19 do
		SideDressUpModel:UndressSlot(i) -- Done This Way To Prevent Issues With Undress
	end
end)

-- Only Show Side Dressup Buttons If Its A Player (Reset Button Will Show Too)
hooksecurefunc(SideDressUpModelResetButton, "Show", function()
	DressUpSideBtn:Show()
	DressUpSideNudeBtn:Show()
end)

hooksecurefunc(SideDressUpModelResetButton, "Hide", function()
	DressUpSideBtn:Hide()
	DressUpSideNudeBtn:Hide()
end)

-- Function To Set Animations
local function SetupAnimations()
	DressUpModel:SetAnimation(255)
	SideDressUpModel:SetAnimation(255)
end

-- Dressing Room
hooksecurefunc("DressUpFrame_Show", SetupAnimations)
DressUpFrame.ResetButton:HookScript("OnClick", SetupAnimations)
-- Auction House Dressing Room
hooksecurefunc(SideDressUpModel, "SetUnit", SetupAnimations)
SideDressUpModelResetButton:HookScript("OnClick", SetupAnimations)

-- Function To Hide Controls
local function SetupControls()
	CharacterModelFrameControlFrame:Hide()
	DressUpModelControlFrame:Hide()
	SideDressUpModelControlFrame:Hide()
end

-- Hide Controls For Character Sheet, Dressing Room And Auction House Dressing Room
CharacterModelFrameControlFrame:HookScript("OnShow", SetupControls)
DressUpModelControlFrame:HookScript("OnShow", SetupControls)
SideDressUpModelControlFrame:HookScript("OnShow", SetupControls)

-- Wardrobe (Used By Transmogrifier Npc)
local function DoBlizzardCollectionsFunc()
	-- Hide Positioning Controls
	WardrobeTransmogFrameControlFrame:HookScript("OnShow", WardrobeTransmogFrameControlFrame.Hide)
	-- Disable Special Animations
	hooksecurefunc(WardrobeTransmogFrame.Model, "SetUnit", function()
		WardrobeTransmogFrame.Model:SetAnimation(255)
	end)
end

if IsAddOnLoaded("Blizzard_Collections") then
	DoBlizzardCollectionsFunc()
else
	local waitFrame = CreateFrame("FRAME")
	waitFrame:RegisterEvent("ADDON_LOADED")
	waitFrame:SetScript("OnEvent", function(_, _, arg1)
		if arg1 == "Blizzard_Collections" then
			DoBlizzardCollectionsFunc()
			waitFrame:UnregisterAllEvents()
		end
	end)
end

-- Inspect System
local function DoInspectSystemFunc()
	-- Hide Positioning Controls
	InspectModelFrameControlFrame:HookScript("OnShow", InspectModelFrameControlFrame.Hide)
end

if IsAddOnLoaded("Blizzard_InspectUI") then
	DoInspectSystemFunc()
else
	local waitFrame = CreateFrame("FRAME")
	waitFrame:RegisterEvent("ADDON_LOADED")
	waitFrame:SetScript("OnEvent", function(_, _, arg1)
		if arg1 == "Blizzard_InspectUI" then
			DoInspectSystemFunc()
			waitFrame:UnregisterAllEvents()
		end
	end)
end