local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("Mover")

local _G = _G
local math_floor = _G.math.floor
local table_wipe = _G.table.wipe
local unpack = _G.unpack

local CANCEL = _G.CANCEL
local CreateFrame = _G.CreateFrame
local ERR_NOT_IN_COMBAT = _G.ERR_NOT_IN_COMBAT
local GetRealmName = _G.GetRealmName
local InCombatLockdown = _G.InCombatLockdown
local IsControlKeyDown = _G.IsControlKeyDown
local IsModifierKeyDown = _G.IsModifierKeyDown
local IsShiftKeyDown = _G.IsShiftKeyDown
local LOCK = _G.LOCK
local OKAY = _G.OKAY
local PlaySound = _G.PlaySound
local RESET = _G.RESET
local StaticPopup_Show = _G.StaticPopup_Show
local UIErrorsFrame = _G.UIErrorsFrame
local UIParent = _G.UIParent
local UnitName = _G.UnitName

-- Frame Mover
local MoverList, f = {}
local updater

function K:Mover(text, value, anchor, width, height)
	local key = "Mover"

	if KkthnxUIData[GetRealmName()][UnitName("player")] and not KkthnxUIData[GetRealmName()][UnitName("player")][key] then
		KkthnxUIData[GetRealmName()][UnitName("player")][key] = {}
	end

	local mover = CreateFrame("Button", nil, UIParent)
	mover:SetFrameLevel(self:GetFrameLevel() + 1)
	mover:SetWidth(width or self:GetWidth())
	mover:SetHeight(height or self:GetHeight())
	mover:Hide()
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
	mover.__key = key
	mover.__value = value
	mover.__anchor = anchor
	mover:SetScript("OnEnter", Module.Mover_OnEnter)
	mover:SetScript("OnLeave", Module.Mover_OnLeave)
	mover:SetScript("OnDragStart", Module.Mover_OnDragStart)
	mover:SetScript("OnDragStop", Module.Mover_OnDragStop)
	mover:SetScript("OnMouseUp", Module.Mover_OnClick)
	table.insert(MoverList, mover)

	self:ClearAllPoints()
	self:SetPoint("TOPLEFT", mover)

	return mover
end

function Module:CalculateMoverPoints(mover, trimX, trimY)
	local screenWidth = math_floor(UIParent:GetRight() + .5)
	local screenHeight = math_floor(UIParent:GetTop() + .5)
	local screenCenter = math_floor(UIParent:GetCenter() + .5)
	local x, y = mover:GetCenter()

	local LEFT = screenWidth / 3
	local RIGHT = screenWidth * 2 / 3
	local TOP = screenHeight / 2
	local point

	if y >= TOP then
		point = "TOP"
		y = -(screenHeight - mover:GetTop())
	else
		point = "BOTTOM"
		y = mover:GetBottom()
	end

	if x >= RIGHT then
		point = point.."RIGHT"
		x = mover:GetRight() - screenWidth
	elseif x <= LEFT then
		point = point.."LEFT"
		x = mover:GetLeft()
	else
		x = x - screenCenter
	end

	x = x + (trimX or 0)
	y = y + (trimY or 0)

	return x, y, point
end

function Module:UpdateTrimFrame()
	local x, y = Module:CalculateMoverPoints(self)
	x, y = math_floor(x + .5), math_floor(y + .5)
	f.__x:SetText(x)
	f.__y:SetText(y)
	f.__x.__current = x
	f.__y.__current = y
	f.__trimText:SetText(self.text:GetText())
end

function Module:DoTrim(trimX, trimY)
	local mover = updater.__owner
	if mover then
		local x, y, point = Module:CalculateMoverPoints(mover, trimX, trimY)
		x, y = math_floor(x + .5), math_floor(y + .5)
		f.__x:SetText(x)
		f.__y:SetText(y)
		f.__x.__current = x
		f.__y.__current = y
		mover:ClearAllPoints()
		mover:SetPoint(point, UIParent, point, x, y)
		KkthnxUIData[GetRealmName()][UnitName("player")][mover.__key][mover.__value] = {point, "UIParent", point, x, y}
	end
end

function Module:Mover_OnClick(btn)
	if IsShiftKeyDown() and btn == "RightButton" then
		self:Hide()
	elseif IsControlKeyDown() and btn == "RightButton" then
		self:ClearAllPoints()
		self:SetPoint(unpack(self.__anchor))
		KkthnxUIData[GetRealmName()][UnitName("player")][self.__key][self.__value] = nil
	end

	updater.__owner = self
	Module.UpdateTrimFrame(self)
end

function Module:Mover_OnEnter()
	self:SetBackdropBorderColor(K.r, K.g, K.b)
	self.text:SetTextColor(1, .8, 0)
end

function Module:Mover_OnLeave()
	self:SetBackdropBorderColor(0, 0, 0)
	self.text:SetTextColor(1, 1, 1)
end

function Module:Mover_OnDragStart()
	self:StartMoving()
	Module.UpdateTrimFrame(self)
	updater.__owner = self
	updater:Show()
end

function Module:Mover_OnDragStop()
	self:StopMovingOrSizing()
	local orig, _, tar, x, y = self:GetPoint()
	x = math_floor(x + .5)
	y = math_floor(y + .5)

	self:ClearAllPoints()
	self:SetPoint(orig, "UIParent", tar, x, y)
	KkthnxUIData[GetRealmName()][UnitName("player")][self.__key][self.__value] = {orig, "UIParent", tar, x, y}
	Module.UpdateTrimFrame(self)
	updater:Hide()
end

function Module:UnlockElements()
	for i = 1, #MoverList do
		local mover = MoverList[i]
		if not mover:IsShown() then
			mover:Show()
		end
	end
	f:Show()
end

function Module:LockElements()
	for i = 1, #MoverList do
		local mover = MoverList[i]
		mover:Hide()
	end

	f:Hide()
	SlashCmdList["KKUI_TOGGLEGRID"]("1")
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

-- Mover Console
local function CreateConsole()
	if f then
		return
	end

	f = CreateFrame("Frame", nil, UIParent)
	f:SetPoint("CENTER", 0, 150)
	f:SetSize(264, 62)
	f:CreateBorder()

	f.text = f:CreateFontString(nil, "OVERLAY")
	f.text:SetPoint("TOP", 0, -10)
	f.text:FontTemplate()
	f.text:SetText(K.Title.." Movers Config")
	f.text:SetWordWrap(false)

	local bu, text = {}, {LOCK, "Grids", RESET}
	for i = 1, 3 do
		bu[i] = CreateFrame("Button", nil, f)
		bu[i]:SetSize(80, 24)
		bu[i]:SkinButton()

		bu[i].text = bu[i]:CreateFontString(nil, "OVERLAY")
		bu[i].text:SetPoint("CENTER")
		bu[i].text:FontTemplate()
		bu[i].text:SetText(text[i])
		bu[i].text:SetWordWrap(false)

		if i == 1 then
			bu[i]:SetPoint("BOTTOMLEFT", 6, 6)
		else
			bu[i]:SetPoint("LEFT", bu[i-1], "RIGHT", 6, 0)
		end
	end

	bu[1]:SetScript("OnClick", Module.LockElements)

	bu[2]:SetScript("OnClick", function()
		SlashCmdList["KKUI_TOGGLEGRID"]("64")
	end)

	bu[3]:SetScript("OnClick", function()
		StaticPopup_Show("RESET_MOVER")
	end)

	local header = CreateFrame("Frame", nil, f)
	header:SetSize(212, 30)
	header:SetPoint("TOP")
	K.CreateMoverFrame(header, f)

	local tips = K.InfoColor.."|nCTRL + "..L["Right Click"]..K.SystemColor.." = Reset Mover"..K.InfoColor.."|nSHIFT + "..L["Right Click"]..K.SystemColor.." = Hide Panel"
	header.title = "Mover Tips"
	K.AddTooltip(header, "ANCHOR_TOP", tips)

	local tex = header:CreateTexture()
	tex:SetSize(30, 30)
	tex:SetPoint("TOPRIGHT", 2, 0)
	tex:SetTexture("Interface\\Common\\Help-i")

	local frame = CreateFrame("Frame", nil, f)
	frame:SetSize(212, 74)
	frame:SetPoint("TOP", f, "BOTTOM", 0, -6)
	frame:CreateBorder()
	f.__trimText = K.CreateFontString(frame, 12, NONE, "", "system", "BOTTOM", 0, 5)

	local xBox = CreateFrame("EditBox", nil, frame)
	xBox:SetSize(60, 22)
	xBox:SetAutoFocus(false)
	xBox:SetTextInsets(5, 5, 0, 0)
	xBox:SetFont(C.Media.Font, 12, "")
	xBox:SetScript("OnEscapePressed", frame.ClearFocus)
	xBox:SetScript("OnEnterPressed", frame.ClearFocus)
	xBox:SetPoint("TOPRIGHT", frame, "TOP", -12, -5)
	K.CreateFontString(xBox, 14, "X:", "", "system", "LEFT", -20, 0)
	xBox:SetJustifyH("CENTER")
	xBox.__current = 0
	xBox:HookScript("OnEnterPressed", function(self)
		local text = self:GetText()
		text = tonumber(text)
		if text then
			local diff = text - self.__current
			self.__current = text
			Module:DoTrim(diff)
		end
	end)
	f.__x = xBox

	local yBox = CreateFrame("EditBox", nil, frame)
	yBox:SetSize(60, 22)
	yBox:SetAutoFocus(false)
	yBox:SetTextInsets(5, 5, 0, 0)
	yBox:SetFont(C.Media.Font, 12, "")
	yBox:SetScript("OnEscapePressed", frame.ClearFocus)
	yBox:SetScript("OnEnterPressed", frame.ClearFocus)
	yBox:SetPoint("TOPRIGHT", frame, "TOP", -12, -29)
	K.CreateFontString(yBox, 14, "Y:", "", "system", "LEFT", -20, 0)
	yBox:SetJustifyH("CENTER")
	yBox.__current = 0
	yBox:HookScript("OnEnterPressed", function(self)
		local text = self:GetText()
		text = tonumber(text)
		if text then
			local diff = text - self.__current
			self.__current = text
			Module:DoTrim(nil, diff)
		end
	end)
	f.__y = yBox

	local arrows = {}
	local arrowIndex = {
		[1] = {degree = 180, offset = -1, x = 28, y = 9},
		[2] = {degree = 0, offset = 1, x = 72, y = 9},
		[3] = {degree = 90, offset = 1, x = 50, y = 22},
		[4] = {degree = -90, offset = -1, x = 50, y = -4},
	}
	local function arrowOnClick(self)
		local modKey = IsModifierKeyDown()
		if self.__index < 3 then
			Module:DoTrim(self.__offset * (modKey and 10 or 1))
		else
			Module:DoTrim(nil, self.__offset * (modKey and 10 or 1))
		end
		PlaySound(SOUNDKIT.IG_MAINMENU_OPTION_CHECKBOX_ON)
	end

	for i = 1, 4 do
		arrows[i] = CreateFrame("Button", nil, frame)
		arrows[i]:SetSize(16, 16)

		arrows[i].Icon = arrows[i]:CreateTexture(nil, "ARTWORK")
		arrows[i].Icon:SetTexture("Interface\\OPTIONSFRAME\\VoiceChat-Play")
		arrows[i].Icon:SetAllPoints()
		arrows[i].Icon:SetTexCoord(unpack(K.TexCoords))

		local arrowData = arrowIndex[i]
		arrows[i].__index = i
		arrows[i].__offset = arrowData.offset
		arrows[i]:SetScript("OnClick", arrowOnClick)
		arrows[i]:SetPoint("CENTER", arrowData.x, arrowData.y)
		arrows[i].Icon:SetPoint("TOPLEFT", 3, -3)
		arrows[i].Icon:SetPoint("BOTTOMRIGHT", -3, 3)
		arrows[i].Icon:SetRotation(math.rad(arrowData.degree))
	end

	local function showLater(event)
		if event == "PLAYER_REGEN_DISABLED" then
			if f:IsShown() then
				Module:LockElements()
				K:RegisterEvent("PLAYER_REGEN_ENABLED", showLater)
			end
		else
			Module:UnlockElements()
			K:UnregisterEvent(event, showLater)
		end
	end
	K:RegisterEvent("PLAYER_REGEN_DISABLED", showLater)
end

_G.SlashCmdList["KKUI_MOVEUI"] = function()
	if InCombatLockdown() then
		UIErrorsFrame:AddMessage(ERR_NOT_IN_COMBAT)
		return
	end
	CreateConsole()
	Module:UnlockElements()
end
_G.SLASH_KKUI_MOVEUI1 = "/moveui"
_G.SLASH_KKUI_MOVEUI2 = "/mui"
_G.SLASH_KKUI_MOVEUI3 = "/mm"

function Module:OnEnable()
	updater = CreateFrame("Frame")
	updater:Hide()
	updater:SetScript("OnUpdate", function()
		Module.UpdateTrimFrame(updater.__owner)
	end)
end