local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local _G = _G

local hooksecurefunc = _G.hooksecurefunc

local function SkinBattlefieldMinimap()
	local function GetOpacity()
		return 1 - (BattlefieldMapOptions and BattlefieldMapOptions.opacity or 1)
	end

	local oldAlpha = GetOpacity()

	local BattlefieldMapFrame = _G["BattlefieldMapFrame"]
	BattlefieldMapFrame:SetClampedToScreen(true)
	BattlefieldMapFrame:StripTextures()

	BattlefieldMapFrame.Backgrounds = BattlefieldMapFrame:CreateTexture(nil, "BACKGROUND", -2)
	BattlefieldMapFrame.Backgrounds:SetAllPoints()
	BattlefieldMapFrame.Backgrounds:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

	BattlefieldMapFrame.Borders = CreateFrame("Frame", nil, BattlefieldMapFrame)
	BattlefieldMapFrame.Borders:SetFrameLevel(BattlefieldMapFrame:GetFrameLevel() + 4)
	BattlefieldMapFrame.Borders:SetAllPoints()

	K.CreateBorder(BattlefieldMapFrame.Borders)

	BattlefieldMapFrame.Backgrounds:SetOutside(BattlefieldMapFrame.ScrollContainer)
	BattlefieldMapFrame.Borders:SetOutside(BattlefieldMapFrame.ScrollContainer)
	BattlefieldMapFrame.Backgrounds:SetColorTexture(0, 0, 0, oldAlpha)

	BattlefieldMapFrame:EnableMouse(true)
	BattlefieldMapFrame:SetMovable(true)

	BattlefieldMapFrame.BorderFrame:StripTextures()
	BattlefieldMapFrame.BorderFrame.CloseButton:SetFrameLevel(BattlefieldMapFrame.BorderFrame:GetFrameLevel() + 4)
	BattlefieldMapFrame.BorderFrame.CloseButton:ClearAllPoints()
	BattlefieldMapFrame.BorderFrame.CloseButton:SetPoint("TOPRIGHT", 2, 6)
	BattlefieldMapFrame.BorderFrame.CloseButton:SkinCloseButton()
	BattlefieldMapTab:Kill()

	local function InitializeOptionsDropDown()
		BattlefieldMapTab:InitializeOptionsDropDown()
	end

	BattlefieldMapFrame.ScrollContainer:HookScript("OnMouseUp", function(_, btn)
		if btn == "LeftButton" then
			BattlefieldMapTab:StopMovingOrSizing()
			BattlefieldMapTab:SetUserPlaced(true)
		elseif btn == "RightButton" then
			L_UIDropDownMenu_Initialize(BattlefieldMapTab.OptionsDropDown, InitializeOptionsDropDown, "MENU")
			ToggleDropDownMenu(1, nil, BattlefieldMapTab.OptionsDropDown, BattlefieldMapFrame:GetName(), 0, -4)
		end

		if OpacityFrame:IsShown() then
			OpacityFrame:Hide()
		end
	end)

	BattlefieldMapFrame.ScrollContainer:HookScript("OnMouseDown", function(_, btn)
		if btn == "LeftButton" and (BattlefieldMapOptions and not BattlefieldMapOptions.locked) then
			BattlefieldMapTab:StartMoving()
		end
	end)

	local function setBackdropAlpha()
		if BattlefieldMapFrame.Backgrounds then
			BattlefieldMapFrame.Backgrounds:SetColorTexture(0, 0, 0, GetOpacity())
		end
	end

	hooksecurefunc(BattlefieldMapFrame, "SetGlobalAlpha", setBackdropAlpha)
	hooksecurefunc(BattlefieldMapFrame, "RefreshAlpha", function()
		oldAlpha = GetOpacity()
	end)

	local function setOldAlpha()
		if oldAlpha then
			BattlefieldMapFrame:SetGlobalAlpha(oldAlpha)
			oldAlpha = nil
		end
	end

	local function setRealAlpha()
		oldAlpha = GetOpacity()
		BattlefieldMapFrame:SetGlobalAlpha(1)
	end

	BattlefieldMapFrame:HookScript("OnShow", setBackdropAlpha)
	BattlefieldMapFrame.ScrollContainer:HookScript("OnLeave", setOldAlpha)
	BattlefieldMapFrame.ScrollContainer:HookScript("OnEnter", setRealAlpha)
	BattlefieldMapFrame.BorderFrame.CloseButton:HookScript("OnLeave", setOldAlpha)
	BattlefieldMapFrame.BorderFrame.CloseButton:HookScript("OnEnter", setRealAlpha)
end

Module.SkinFuncs["Blizzard_BattlefieldMap"] = SkinBattlefieldMinimap