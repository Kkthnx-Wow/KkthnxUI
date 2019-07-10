local K, C = unpack(select(2, ...))

local _G = _G
local pairs = pairs
local table_insert = table.insert
local type = type
local unpack = unpack

local CANCEL = _G.CANCEL
local CreateFrame = _G.CreateFrame
local CUSTOM_CLASS_COLORS = _G.CUSTOM_CLASS_COLORS
local ERR_NOT_IN_COMBAT = _G.ERR_NOT_IN_COMBAT
local GetRealmName = _G.GetRealmName
local InCombatLockdown = _G.InCombatLockdown
local LOCK = _G.LOCK
local RAID_CLASS_COLORS = _G.RAID_CLASS_COLORS
local RESET = _G.RESET
local UIParent = _G.UIParent
local UnitName = _G.UnitName

function K.CopyTable(source, target)
	for key, value in pairs(source) do
		if type(value) == "table" then
			if not target[key] then
				target[key] = {}
			end

			for k in pairs(value) do
				target[key][k] = value[k]
			end
		else
			target[key] = value
		end
	end
end

function K.GetCoords(object)
    local p, anch, rP, x, y = object:GetPoint()

    if not x then
        return p, anch, rP, x, y
    else
        return p, anch and anch:GetName() or "UIParent", rP, K.Round(x), K.Round(y)
    end
end

local classColor = K.Class == "PRIEST" and K.PriestColors or (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[K.Class] or RAID_CLASS_COLORS[K.Class])

local function SetModifiedBackdrop(self)
	self.Backgrounds:SetColorTexture(classColor.r * .15, classColor.g * .15, classColor.b * .15, C["Media"].BackdropColor[4])
end

local function SetOriginalBackdrop(self)
	self.Backgrounds:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])
end

-- Frame Mover
local MoverList, BackupTable, f = {}, {}

function K:Mover(text, value, anchor, width, height)
	local key = "Mover"

	-- Wipe Old Settings With No Conflict.
	if KkthnxUIData[GetRealmName()][UnitName("player")].Movers then
		K.StaticPopup_Show("OLD_MOVERS_DATABASE_RL")
	end

	if not KkthnxUIData[GetRealmName()][UnitName("player")][key] then
		KkthnxUIData[GetRealmName()][UnitName("player")][key] = {}
	end

	local mover = CreateFrame("Frame", nil, UIParent)
	mover:SetWidth(width or self:GetWidth())
	mover:SetHeight(height or self:GetHeight())
	mover:CreateBorder()

	mover.text = mover:CreateFontString(nil, "OVERLAY")
	mover.text:SetPoint("CENTER")
	mover.text:FontTemplate()
	mover.text:SetText(text)
	mover.text:SetWordWrap(false)

	table_insert(MoverList, mover)

	if not KkthnxUIData[GetRealmName()][UnitName("player")][key][value] then
		mover:SetPoint(unpack(anchor))
	else
		mover:SetPoint(unpack(KkthnxUIData[GetRealmName()][UnitName("player")][key][value]))
	end

	mover:EnableMouse(true)
	mover:SetMovable(true)
	mover:SetClampedToScreen(true)
	mover:SetFrameStrata("HIGH")
	mover:RegisterForDrag("LeftButton")

	mover:SetScript("OnEnter", function(self)
		local p, anch, rP, x, y = K.GetCoords(self)
        SetModifiedBackdrop(self)
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

	mover:SetScript("OnLeave", function(self)
		SetOriginalBackdrop(self)
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
	SlashCmdList["TOGGLEGRID"]("1")
end

StaticPopupDialogs["RESET_MOVER"] = {
	text = "Reset Mover Confirm",
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function()
		wipe(KkthnxUIData[GetRealmName()][UnitName("player")]["Mover"])
		ReloadUI()
	end,
}

StaticPopupDialogs["CANCEL_MOVER"] = {
	text = "Cancel Mover Confirm",
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function()
		K.CopyTable(BackupTable, KkthnxUIData[GetRealmName()][UnitName("player")]["Mover"])
		ReloadUI()
	end,
}

-- Mover Console
local function CreateConsole()
	if f then
		return
	end

	f = CreateFrame("Frame", nil, UIParent)
	f:SetPoint("CENTER", 0, 151)
	f:SetSize(308, 65)
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
			bu[i]:SetPoint("BOTTOMLEFT", 5, 5)
		else
			bu[i]:SetPoint("LEFT", bu[i-1], "RIGHT", 6, 0)
		end
	end

	bu[1]:SetScript("OnClick", LockElements)

	bu[2]:SetScript("OnClick", function()
		StaticPopup_Show("CANCEL_MOVER")
	end)

	bu[3]:SetScript("OnClick", function()
		SlashCmdList["TOGGLEGRID"]("64")
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

SlashCmdList["KKTHNXUI_MOVER"] = function()
	if InCombatLockdown() then
		UIErrorsFrame:AddMessage(ERR_NOT_IN_COMBAT)
		return
	end
	CreateConsole()
	UnlockElements()
end
SLASH_KKTHNXUI_MOVER1 = "/moveui"
SLASH_KKTHNXUI_MOVER2 = "/mui"
SLASH_KKTHNXUI_MOVER3 = "/mm"