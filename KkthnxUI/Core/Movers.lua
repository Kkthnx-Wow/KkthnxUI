local K = unpack(select(2, ...))

local _G = _G
local table_insert = _G.table.insert
local unpack = _G.unpack
local table_wipe = _G.table.wipe

local CANCEL = _G.CANCEL
local CreateFrame = _G.CreateFrame
local ERR_NOT_IN_COMBAT = _G.ERR_NOT_IN_COMBAT
local GameTooltip = _G.GameTooltip
local GetRealmName = _G.GetRealmName
local InCombatLockdown = _G.InCombatLockdown
local KEY_BUTTON1 = _G.KEY_BUTTON1
local KEY_BUTTON2 = _G.KEY_BUTTON2
local LOCK = _G.LOCK
local RESET = _G.RESET
local UIParent = _G.UIParent
local UnitName = _G.UnitName
local OKAY = _G.OKAY
local StaticPopup_Show = _G.StaticPopup_Show
local UIErrorsFrame = _G.UIErrorsFrame

function K.GetCoords(object)
    local p, anch, rP, x, y = object:GetPoint()

    if not x then
        return p, anch, rP, x, y
    else
        return p, anch and anch:GetName() or "UIParent", rP, K.Round(x), K.Round(y)
    end
end

-- Frame Mover
local MoverList, BackupTable, f = {}, {}
function K:Mover(text, value, anchor, width, height)
	if not self then
		return
	end

	local selfName = self:GetName()
	assert(selfName, (string.format("Failed to create a mover, object '%s' has no name", self:GetDebugName())))

	local key = "Mover"

	if KkthnxUIData[GetRealmName()][UnitName("player")] and not KkthnxUIData[GetRealmName()][UnitName("player")][key] then
		KkthnxUIData[GetRealmName()][UnitName("player")][key] = {}
	end

	local mover = CreateFrame("Button", nil, UIParent)
	mover:SetFrameLevel(self:GetFrameLevel() + 1)
	mover:SetWidth(width or self:GetWidth())
	mover:SetHeight(height or self:GetHeight())
	mover:SetHighlightTexture("Interface\\BUTTONS\\WHITE8X8")
	mover:GetHighlightTexture():SetAlpha(0.3)
	local bg = mover:CreateTexture(nil, "BACKGROUND", nil, 0)
	bg:SetColorTexture(38/255, 125/255, 206/255, 90/255)
	bg:SetAllPoints()

	mover.text = mover:CreateFontString(nil, "OVERLAY")
	mover.text:SetPoint("CENTER")
	mover.text:FontTemplate()
	mover.text:SetText(text)
	mover.text:SetWidth(mover:GetWidth())

	table_insert(MoverList, mover)

	if not KkthnxUIData[GetRealmName()][UnitName("player")][key][value] then
		mover:SetPoint(unpack(anchor))
	else
		mover:SetPoint(unpack(KkthnxUIData[GetRealmName()][UnitName("player")][key][value]))
	end

	mover:SetToplevel(true)
	mover:EnableMouse(true)
	mover:SetMovable(true)
	mover:SetClampedToScreen(true)
	mover:RegisterForDrag("LeftButton")

	mover:SetScript("OnEnter", function(self)
		local p, anch, rP, x, y = K.GetCoords(self)
        GameTooltip:SetOwner(self, "ANCHOR_NONE")
        GameTooltip:SetPoint(K.GetAnchors(self))
        GameTooltip:ClearLines()

        GameTooltip:AddLine("|cffffd100Mover:|r "..text, 1, 1, 1)
        GameTooltip:AddLine("|cffffd100Point:|r "..p, 1, 1, 1)
        GameTooltip:AddLine("|cffffd100Attached to:|r "..rP.." |cffffd100of|r "..anch, 1, 1, 1)
        GameTooltip:AddLine("|cffffd100X:|r "..x..", |cffffd100Y:|r "..y, 1, 1, 1)
        GameTooltip:AddLine(" ")
		GameTooltip:AddDoubleLine("|TInterface\\TutorialFrame\\UI-TUTORIAL-FRAME:16:12:0:0:512:512:1:76:218:318|t "..KEY_BUTTON1, "Move", 1, 1, 1)
		GameTooltip:AddDoubleLine("|TInterface\\TutorialFrame\\UI-TUTORIAL-FRAME:16:12:0:0:512:512:1:76:321:421|t "..KEY_BUTTON2, RESET, 1, 1, 1)
		GameTooltip:Show()
	end)

	mover:SetScript("OnLeave", function()
		GameTooltip:Hide()
	end)

	mover:SetScript("OnDragStart", function()
		mover:StartMoving()
	end)

	mover:SetScript("OnDragStop", function()
		mover:StopMovingOrSizing()
		local orig, _, tar, x, y = mover:GetPoint()
		KkthnxUIData[GetRealmName()][UnitName("player")][key][value] = {orig, "UIParent", tar, x, y}
	end)

	mover:SetScript("OnMouseUp", function(_, button)
		if button == "RightButton" and key and value then
			mover:ClearAllPoints()
			mover:SetPoint(unpack(anchor))

			KkthnxUIData[GetRealmName()][UnitName("player")][key][value] = nil
		end
	end)

	mover:Hide()
	self:ClearAllPoints()
	self:SetPoint("TOPLEFT", mover)

	return mover
end

local function UnlockElements()
	for i = 1, #MoverList do
		local mover = MoverList[i]
		if not mover:IsShown() then
			mover:Show()
		end
	end
	K.CopyTable(KkthnxUIData[GetRealmName()][UnitName("player")]["Mover"], BackupTable)
	f:Show()
end

local function LockElements()
	for i = 1, #MoverList do
		local mover = MoverList[i]
		mover:Hide()
	end
	f:Hide()
	K.ToggleGrid("1")
end

_G.StaticPopupDialogs["RESET_MOVER"] = {
	text = "Reset Mover Confirm",
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function()
		table_wipe(KkthnxUIData[GetRealmName()][UnitName("player")]["Mover"])
		_G.ReloadUI()
	end,
}

_G.StaticPopupDialogs["CANCEL_MOVER"] = {
	text = "Cancel Mover Confirm",
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function()
		K.CopyTable(BackupTable, KkthnxUIData[GetRealmName()][UnitName("player")]["Mover"])
		_G.ReloadUI()
	end,
}

-- Mover Console
local function CreateConsole()
	if f then
		return
	end

	f = CreateFrame("Frame", nil, UIParent)
	f:SetPoint("CENTER", 0, 150)
	f:SetSize(306, 62)
	f:CreateBorder()

	f.text = f:CreateFontString(nil, "OVERLAY")
	f.text:SetPoint("TOP", 0, -10)
	f.text:FontTemplate()
	f.text:SetText(K.Title.." Movers Config")
	f.text:SetWordWrap(false)

	local bu, text = {}, {LOCK, CANCEL, "Grids", RESET}
	for i = 1, 4 do
		bu[i] = CreateFrame("Button", nil, f)
		bu[i]:SetSize(70, 26)
		bu[i]:SkinButton()

		bu[i].text = bu[i]:CreateFontString(nil, "OVERLAY")
		bu[i].text:SetPoint("CENTER")
		bu[i].text:FontTemplate()
		bu[i].text:SetText(text[i])
		bu[i].text:SetWordWrap(false)

		if i == 1 then
			bu[i]:SetPoint("BOTTOMLEFT", 4, 4)
		else
			bu[i]:SetPoint("LEFT", bu[i-1], "RIGHT", 6, 0)
		end
	end

	bu[1]:SetScript("OnClick", LockElements)

	bu[2]:SetScript("OnClick", function()
		StaticPopup_Show("CANCEL_MOVER")
	end)

	bu[3]:SetScript("OnClick", function()
		K.ToggleGrid("64")
	end)

	bu[4]:SetScript("OnClick", function()
		StaticPopup_Show("RESET_MOVER")
	end)

	local function showLater(event)
		if event == "PLAYER_REGEN_DISABLED" then
			if f:IsShown() then
				LockElements()
				K:RegisterEvent("PLAYER_REGEN_ENABLED", showLater)
			end
		else
			UnlockElements()
			K:UnregisterEvent(event, showLater)
		end
	end
	K:RegisterEvent("PLAYER_REGEN_DISABLED", showLater)
end

_G.SlashCmdList["MOVEUI"] = function()
	if InCombatLockdown() then
		UIErrorsFrame:AddMessage(ERR_NOT_IN_COMBAT)
		return
	end
	CreateConsole()
	UnlockElements()
end
_G.SLASH_MOVEUI1 = "/moveui"
_G.SLASH_MOVEUI2 = "/mui"
_G.SLASH_MOVEUI3 = "/mm"