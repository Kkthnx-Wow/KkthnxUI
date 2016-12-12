local K, C, L = unpack(select(2, ...))

-- Lua API
local _G = _G
local select = select
local tostring = tostring
local unpack = unpack

-- Wow API
local CreateFrame = CreateFrame
local GetActiveSpecGroup = GetActiveSpecGroup
local GetNumShapeshiftForms = GetNumShapeshiftForms
local GetNumSpecializations = GetNumSpecializations
local GetSpecialization = GetSpecialization
local GetSpecializationInfo = GetSpecializationInfo
local InCombatLockdown = InCombatLockdown

local IsShiftKeyDown = IsShiftKeyDown
local SetSpecialization = SetSpecialization
local UIParent = UIParent

-- Global variables that we don't cache, list them here for mikk's FindGlobals script
-- GLOBALS: UIErrorsFrame, ERR_NOT_IN_COMBAT, Lib_EasyMenu, Recount_MainWindow
-- GLOBALS: Skada, UIConfigMain, CreateUIConfig, HideUIPanel, Menu, GameTooltip

local Movers = K.Movers

-- Bottom bars anchor
local BottomBarAnchor = CreateFrame("Frame", "ActionBarAnchor", PetBattleFrameHider)
if C.DataText.BottomBar ~= true then
	BottomBarAnchor:CreatePanel("Invisible", 1, 1, "BOTTOM", "UIParent", "BOTTOM", 0, 4)
else
	BottomBarAnchor:CreatePanel("Invisible", 1, 1, unpack(C.Position.BottomBars))
end
BottomBarAnchor:SetWidth((C.ActionBar.ButtonSize * 12) + (C.ActionBar.ButtonSpace * 11))
if C.ActionBar.BottomBars == 2 then
	BottomBarAnchor:SetHeight((C.ActionBar.ButtonSize * 2) + C.ActionBar.ButtonSpace)
elseif C.ActionBar.BottomBars == 3 then
	if C.ActionBar.SplitBars == true then
		BottomBarAnchor:SetHeight((C.ActionBar.ButtonSize * 2) + C.ActionBar.ButtonSpace)
	else
		BottomBarAnchor:SetHeight((C.ActionBar.ButtonSize * 3) + (C.ActionBar.ButtonSpace * 2))
	end
else
	BottomBarAnchor:SetHeight(C.ActionBar.ButtonSize)
end
BottomBarAnchor:SetFrameStrata("LOW")
Movers:RegisterFrame(BottomBarAnchor)

-- Right bars anchor
local RightBarAnchor = CreateFrame("Frame", "RightActionBarAnchor", PetBattleFrameHider)
RightBarAnchor:CreatePanel("Invisible", 1, 1, unpack(C.Position.RightBars))
RightBarAnchor:SetHeight((C.ActionBar.ButtonSize * 12) + (C.ActionBar.ButtonSpace * 11))
if C.ActionBar.RightBars == 1 then
	RightBarAnchor:SetWidth(C.ActionBar.ButtonSize)
elseif C.ActionBar.RightBars == 2 then
	RightBarAnchor:SetWidth((C.ActionBar.ButtonSize * 2) + C.ActionBar.ButtonSpace)
elseif C.ActionBar.RightBars == 3 then
	RightBarAnchor:SetWidth((C.ActionBar.ButtonSize * 3) + (C.ActionBar.ButtonSpace * 2))
else
	RightBarAnchor:Hide()
end
RightBarAnchor:SetFrameStrata("LOW")
Movers:RegisterFrame(RightBarAnchor)

-- Split bar anchor
if C.ActionBar.SplitBars == true then
	local SplitBarLeft = CreateFrame("Frame", "SplitBarLeft", PetBattleFrameHider)
	SplitBarLeft:CreatePanel("Invisible", (C.ActionBar.ButtonSize * 3) + (C.ActionBar.ButtonSpace * 2), (C.ActionBar.ButtonSize * 2) + C.ActionBar.ButtonSpace, "BOTTOMRIGHT", ActionBarAnchor, "BOTTOMLEFT", -C.ActionBar.ButtonSpace, 0)
	SplitBarLeft:SetFrameStrata("LOW")

	local SplitBarRight = CreateFrame("Frame", "SplitBarRight", PetBattleFrameHider)
	SplitBarRight:CreatePanel("Invisible", (C.ActionBar.ButtonSize * 3) + (C.ActionBar.ButtonSpace * 2), (C.ActionBar.ButtonSize * 2) + C.ActionBar.ButtonSpace, "BOTTOMLEFT", ActionBarAnchor, "BOTTOMRIGHT", C.ActionBar.ButtonSpace, 0)
	SplitBarRight:SetFrameStrata("LOW")
end

-- Pet bar anchor
local PetBarAnchor = CreateFrame("Frame", "PetActionBarAnchor", PetBattleFrameHider)
if C.ActionBar.PetBarHorizontal == true then
	PetBarAnchor:CreatePanel("Invisible", (C.ActionBar.ButtonSize * 10) + (C.ActionBar.ButtonSpace * 9), (C.ActionBar.ButtonSize + C.ActionBar.ButtonSpace), unpack(C.Position.PetHorizontal))
elseif C.ActionBar.RightBars > 0 then
	PetBarAnchor:CreatePanel("Invisible", C.ActionBar.ButtonSize + 3, (C.ActionBar.ButtonSize * 10) + (C.ActionBar.ButtonSpace * 9), "RIGHT", RightBarAnchor, "LEFT", 0, 0)
else
	PetBarAnchor:CreatePanel("Invisible", (C.ActionBar.ButtonSize + C.ActionBar.ButtonSpace), (C.ActionBar.ButtonSize * 10) + (C.ActionBar.ButtonSpace * 9), unpack(C.Position.RightBars))
end
PetBarAnchor:SetFrameStrata("LOW")
RegisterStateDriver(PetBarAnchor, "visibility", "[pet,novehicleui,nopossessbar,nopetbattle] show; hide")
Movers:RegisterFrame(PetBarAnchor)

-- Stance bar anchor
local ShiftAnchor = CreateFrame("Frame", "ShapeShiftBarAnchor", PetBattleFrameHider)
ShiftAnchor:RegisterEvent("PLAYER_LOGIN")
ShiftAnchor:RegisterEvent("PLAYER_ENTERING_WORLD")
ShiftAnchor:RegisterEvent("UPDATE_SHAPESHIFT_FORMS")
ShiftAnchor:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
ShiftAnchor:SetScript("OnEvent", function(self, event, ...)
	local Forms = GetNumShapeshiftForms()
	if Forms > 0 then
		if C.ActionBar.StanceBarHorizontal ~= true then
			ShiftAnchor:SetWidth(C.ActionBar.ButtonSize + 3)
			ShiftAnchor:SetHeight((C.ActionBar.ButtonSize * Forms) + ((C.ActionBar.ButtonSpace * Forms) - 3))
			ShiftAnchor:SetPoint("TOPLEFT", _G["StanceButton1"], "TOPLEFT")
		else
			ShiftAnchor:SetWidth((C.ActionBar.ButtonSize * Forms) + ((C.ActionBar.ButtonSpace * Forms) - 3))
			ShiftAnchor:SetHeight(C.ActionBar.ButtonSize)
			ShiftAnchor:SetPoint("TOPLEFT", _G["StanceButton1"], "TOPLEFT")
		end
	end
end)

-- Chat background
if C.Chat.Background == true and C.Chat.Enable == true then
	local chatbd = CreateFrame("Frame", "ChatBackground", UIParent)
	chatbd:CreatePanel("Transparent", C.Chat.Width + 7, C.Chat.Height + 4, "TOPLEFT", ChatFrame1, "TOPLEFT", -3, 1)
	chatbd:SetBackdrop(K.BorderBackdrop)
	chatbd:SetBackdropColor(unpack(C.Media.Backdrop_Color))

	if C.Chat.TabsMouseover ~= true then
		local chattabs = CreateFrame("Frame", "ChatTabsPanel", UIParent)
		chattabs:CreatePanel("Transparent", chatbd:GetWidth(), 20, "BOTTOM", chatbd, "TOP", 0, 3)
		chattabs:SetBackdrop(K.BorderBackdrop)
		chattabs:SetBackdropColor(unpack(C.Media.Backdrop_Color))
	end
end

-- Spec
local LeftClickMenu = {}
LeftClickMenu[1] = {text = L.ConfigButton.SpecMenu, isTitle = true, notCheckable = true}

local function ActiveTalents()
	local Tree = GetSpecialization(false, false, GetActiveSpecGroup())
	return Tree
end

local KkthnxUISpecSwap = CreateFrame("Frame", "KkthnxUISpecSwap", UIParent, "UIDropDownMenuTemplate")
KkthnxUISpecSwap:SetTemplate()
KkthnxUISpecSwap:RegisterEvent("PLAYER_LOGIN")
KkthnxUISpecSwap:SetScript("OnEvent", function(...)
	local specIndex
	for specIndex = 1, GetNumSpecializations() do
		LeftClickMenu[specIndex + 1] = {
			text = tostring(select(2, GetSpecializationInfo(specIndex))),
			notCheckable = true,
			func = (function()
				local getSpec = GetSpecialization()
				if getSpec and getSpec == specIndex then
					UIErrorsFrame:AddMessage(L.ConfigButton.SpecError, 1.0, 0.0, 0.0, 53, 5);
					return
				end
				SetSpecialization(specIndex)
			end)
		}
	end
end)

-- Minimap Panels
if Minimap and C.Minimap.Enable then
	local MinimapStats = CreateFrame("Frame", "KkthnxUIMinimapStats", Minimap)
	MinimapStats:SetTemplate()
	if C.General.ShowConfigButton == true then
		MinimapStats:SetSize(((Minimap:GetWidth() -16)), 28)
		MinimapStats:SetPoint("TOP", Minimap, "BOTTOM", -13, -2)
	else
		MinimapStats:SetSize(((Minimap:GetWidth() + 10)), 28)
		MinimapStats:SetPoint("TOP", Minimap, "BOTTOM", 0, -2)
	end
	MinimapStats:SetFrameStrata("LOW")
	Movers:RegisterFrame(MinimapStats)

	if C.Blizzard.ColorTextures == true then
		MinimapStats:SetBackdropBorderColor(unpack(C.Blizzard.TexturesColor))
	end
end

-- BottomBar DT
if C.DataText.BottomBar then
	local DataTextBottomBar = CreateFrame("Frame", "KkthnxUIDataTextBottomBar", UIParent)
	DataTextBottomBar:SetSize(ActionBarAnchor:GetWidth() + 6, 28)
	DataTextBottomBar:SetPoint("TOP", ActionBarAnchor, "BOTTOM", 0, -1)
	DataTextBottomBar:SetTemplate()
	DataTextBottomBar:SetFrameStrata("BACKGROUND")
	DataTextBottomBar:SetFrameLevel(1)
	Movers:RegisterFrame(DataTextBottomBar)
end

-- BottomSplitBarLeft DT
if C.ActionBar.SplitBars and C.DataText.BottomBar then
	local DataTextSplitBarLeft = CreateFrame("Frame", "KkthnxUIDataTextSplitBarLeft", UIParent)
	DataTextSplitBarLeft:SetSize(((C.ActionBar.ButtonSize * 3) + (C.ActionBar.ButtonSpace * 2) +3), 28)
	DataTextSplitBarLeft:SetPoint("RIGHT", KkthnxUIDataTextBottomBar, "LEFT", 0, 0)
	DataTextSplitBarLeft:SetTemplate()
	DataTextSplitBarLeft:SetFrameStrata("BACKGROUND")
	DataTextSplitBarLeft:SetFrameLevel(1)
	Movers:RegisterFrame(DataTextSplitBarLeft)
end

-- BottomSplitBarRight DT
if C.ActionBar.SplitBars and C.DataText.BottomBar then
	local DataTextSplitBarRight = CreateFrame("Frame", "KkthnxUIDataTextSplitBarRight", UIParent)
	DataTextSplitBarRight:SetSize(((C.ActionBar.ButtonSize * 3) + (C.ActionBar.ButtonSpace * 2) +3), 28)
	DataTextSplitBarRight:SetPoint("LEFT", KkthnxUIDataTextBottomBar, "RIGHT", 0, 0)
	DataTextSplitBarRight:SetTemplate()
	DataTextSplitBarRight:SetFrameStrata("BACKGROUND")
	DataTextSplitBarRight:SetFrameLevel(1)
	Movers:RegisterFrame(DataTextSplitBarRight)
end

-- Battleground stats frame
if C.DataText.Battleground == true and C.DataText.BottomBar == true then
	local BattleGroundFrame = CreateFrame("Frame", "KkthnxUIInfoBottomBattleGround", UIParent)
	BattleGroundFrame:SetTemplate()
	BattleGroundFrame:SetAllPoints(KkthnxUIDataTextBottomBar)
	BattleGroundFrame:SetFrameStrata("LOW")
	BattleGroundFrame:SetFrameLevel(0)
	BattleGroundFrame:EnableMouse(true)

	BattleGroundFrame.Background = BattleGroundFrame:CreateTexture(nil, "BORDER")
	BattleGroundFrame.Background:SetPoint("TOPLEFT", BattleGroundFrame, 4, -4)
	BattleGroundFrame.Background:SetPoint("BOTTOMRIGHT", BattleGroundFrame, -4, 4)
	BattleGroundFrame.Background:SetColorTexture(0.019, 0.019, 0.019, 0.9)
end

-- ToggleButton Special
if C.General.ShowConfigButton == true then
	local ToggleButtonSpecial = CreateFrame( "Frame", "KkthnxToggleSpecialButton", oUF_PetBattleFrameHider)
	ToggleButtonSpecial:SetPoint("LEFT", KkthnxUIMinimapStats, "RIGHT", 2, 0)
	ToggleButtonSpecial:SetSize(20, 20)
	ToggleButtonSpecial:SetFrameStrata("BACKGROUND")
	ToggleButtonSpecial:SetFrameLevel(2)
	ToggleButtonSpecial:SkinButton()

	ToggleButtonSpecial["Text"] = K.SetFontString(ToggleButtonSpecial, C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
	ToggleButtonSpecial["Text"]:SetPoint("CENTER", ToggleButtonSpecial, "CENTER", 0, .5)
	ToggleButtonSpecial["Text"]:SetText("|cff3c9bedK|r")
	ToggleButtonSpecial["Text"]:SetShadowOffset(0, 0)

	ToggleButtonSpecial:EnableMouse(true)
	ToggleButtonSpecial:HookScript("OnMouseDown", function(self, btn)
		if(InCombatLockdown() and not btn == "RightButton") then
			K.Print(ERR_NOT_IN_COMBAT)
			return
		end

		if (IsShiftKeyDown() and btn == "LeftButton") then
			Lib_EasyMenu(LeftClickMenu, KkthnxUISpecSwap, "cursor", 0, 0, "MENU", 2)
			return
		end

		if (IsShiftKeyDown() and btn == "RightButton") then
			K.DataTexts:ToggleDataPositions()
			return
		end

		if btn == "LeftButton" then
			local Movers = K.Movers
			Movers:StartOrStopMoving()
		end

		if btn == "RightButton" then
			if K.CheckAddOn("Recount") then
				if Recount_MainWindow:IsShown() then
					Recount_MainWindow:Hide()
				else
					Recount_MainWindow:Show()
				end
			end
			if K.CheckAddOn("Skada") then
				Skada:ToggleWindow()
			end
		end

		if btn == "MiddleButton" then
			if UIConfigMain and UIConfigMain:IsShown() then
				UIConfigMain:Hide()
			else
				CreateUIConfig()
				HideUIPanel(Menu)
			end
		end
	end)

	ToggleButtonSpecial:HookScript("OnEnter", function(self)
		local anchor, panel, xoff, yoff = "ANCHOR_BOTTOM", self:GetParent(), 0, 5
		GameTooltip:SetOwner(self, anchor, xoff, yoff)
		GameTooltip:ClearLines()
		GameTooltip:AddLine(L.ConfigButton.Functions)
		GameTooltip:AddDoubleLine(L.ConfigButton.LeftClick, L.ConfigButton.MoveUI, 1, 1, 1)
		if K.CheckAddOn("Recount") then
			GameTooltip:AddDoubleLine(L.ConfigButton.RightClick, L.ConfigButton.Recount, 1, 1, 1)
		end
		if K.CheckAddOn("Skada") then
			GameTooltip:AddDoubleLine(L.ConfigButton.RightClick, L.ConfigButton.Skada, 1, 1, 1)
		end
		GameTooltip:AddDoubleLine(L.ConfigButton.MiddleClick, L.ConfigButton.Config, 1, 1, 1)
		GameTooltip:AddDoubleLine(L.ConfigButton.ShiftClick, L.ConfigButton.Spec, 1, 1, 1)
		GameTooltip:AddDoubleLine(L.ConfigButton.ShiftClick, "Toggle Datatext", 1, 1, 1)
		GameTooltip:Show()
		GameTooltip:SetTemplate()
	end)

	ToggleButtonSpecial:HookScript("OnLeave", function(self)
		GameTooltip:Hide()
	end)
end