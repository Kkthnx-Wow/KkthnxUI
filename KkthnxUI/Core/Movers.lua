local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:NewModule("Mover")

-- Sourced: NDui (siweia)
-- Edited: KkthnxUI (Kkthnx)

local table_wipe = table.wipe
local unpack = unpack

local CANCEL = CANCEL
local CreateFrame = CreateFrame
local ERR_NOT_IN_COMBAT = ERR_NOT_IN_COMBAT
local InCombatLockdown = InCombatLockdown
local IsControlKeyDown = IsControlKeyDown
local IsModifierKeyDown = IsModifierKeyDown
local IsShiftKeyDown = IsShiftKeyDown
local LOCK = LOCK
local NONE = NONE
local OKAY = OKAY
local PlaySound = PlaySound
local RESET = RESET
local SOUNDKIT = SOUNDKIT
local StaticPopup_Show = StaticPopup_Show
local UIErrorsFrame = UIErrorsFrame
local UIParent = UIParent

-- Frame Mover
local MoverList = {}
local f
local updater

function K:Mover(text, value, anchor, width, height, isAuraWatch)
	local key = "Mover"
	if isAuraWatch then
		key = "AuraWatchMover"
	end

	local mover = CreateFrame("Button", "KKUI_Mover", UIParent)
	mover:SetWidth(width or self:GetWidth())
	mover:SetHeight(height or self:GetHeight())
	mover:CreateBorder(nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, { 38 / 255, 125 / 255, 206 / 255, 80 / 255 })
	mover:Hide()

	mover.text = K.CreateFontString(mover, 12, text, "")
	mover.text:SetWordWrap(true)

	-- print("KKUI_Mover" .. text)

	if not KkthnxUIDB.Variables[K.Realm][K.Name][key][value] then
		mover:SetPoint(unpack(anchor))
	else
		mover:SetPoint(unpack(KkthnxUIDB.Variables[K.Realm][K.Name][key][value]))
	end

	mover:EnableMouse(true)
	mover:SetMovable(true)
	mover:SetClampedToScreen(true)
	mover:SetFrameStrata("HIGH")
	mover:RegisterForDrag("LeftButton")
	mover.__key = key
	mover.__value = value
	mover.__anchor = anchor
	mover.isAuraWatch = isAuraWatch
	mover:SetScript("OnEnter", Module.Mover_OnEnter)
	mover:SetScript("OnLeave", Module.Mover_OnLeave)
	mover:SetScript("OnDragStart", Module.Mover_OnDragStart)
	mover:SetScript("OnDragStop", Module.Mover_OnDragStop)
	mover:SetScript("OnMouseUp", Module.Mover_OnClick)

	if not isAuraWatch then
		table.insert(MoverList, mover)
	end

	self:ClearAllPoints()
	self:SetPoint("TOPLEFT", mover)

	return mover
end

function Module:CalculateMoverPoints(mover, trimX, trimY)
	local screenWidth = K.Round(UIParent:GetRight())
	local screenHeight = K.Round(UIParent:GetTop())
	local screenCenter = K.Round(UIParent:GetCenter(), nil)
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
		point = point .. "RIGHT"
		x = mover:GetRight() - screenWidth
	elseif x <= LEFT then
		point = point .. "LEFT"
		x = mover:GetLeft()
	else
		x = x - screenCenter
	end

	x = x + (trimX or 0)
	y = y + (trimY or 0)
	x, y = K.Round(x), K.Round(y)

	return x, y, point
end

function Module:UpdateTrimFrame()
	if not f then
		return
	end

	local x, y = Module:CalculateMoverPoints(self)
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
		f.__x:SetText(x)
		f.__y:SetText(y)
		f.__x.__current = x
		f.__y.__current = y
		mover:ClearAllPoints()
		mover:SetPoint(point, UIParent, point, x, y)
		KkthnxUIDB.Variables[K.Realm][K.Name][mover.__key][mover.__value] = { point, "UIParent", point, x, y }
	end
end

function Module:Mover_OnClick(btn)
	if IsShiftKeyDown() and btn == "RightButton" then
		if self.isAuraWatch then
			UIErrorsFrame:AddMessage(K.InfoColor .. "You can't hide AuraWatch mover by that.")
		else
			self:Hide()
		end
	elseif IsControlKeyDown() and btn == "RightButton" then
		self:ClearAllPoints()
		self:SetPoint(unpack(self.__anchor))
		KkthnxUIDB.Variables[K.Realm][K.Name][self.__key][self.__value] = nil
	end

	updater.__owner = self
	Module.UpdateTrimFrame(self)
end

function Module:Mover_OnEnter()
	K.ShowOverlayGlow(self, "AutoCastGlow")
	self.KKUI_Background:SetVertexColor(K.r, K.g, K.b, 0.8)
	self.text:SetTextColor(1, 0.8, 0)
end

function Module:Mover_OnLeave()
	K.HideOverlayGlow(self, "AutoCastGlow")
	self.KKUI_Background:SetVertexColor(38 / 255, 125 / 255, 206 / 255, 80 / 255)
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
	x = K.Round(x)
	y = K.Round(y)

	self:ClearAllPoints()
	self:SetPoint(orig, "UIParent", tar, x, y)
	KkthnxUIDB.Variables[K.Realm][K.Name][self.__key][self.__value] = { orig, "UIParent", tar, x, y }
	Module.UpdateTrimFrame(self)
	updater:Hide()
end

function Module:UnlockElements()
	for i = 1, #MoverList do
		local mover = MoverList[i]
		if not mover:IsShown() and not mover.isDisable then
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
	_G.SlashCmdList["KKUI_TOGGLEGRID"]("1")
	SlashCmdList.AuraWatch("lock")
end

_G.StaticPopupDialogs["RESET_MOVER"] = {
	text = "Are you sure to reset frames position?",
	button1 = OKAY,
	button2 = CANCEL,
	OnAccept = function()
		table_wipe(KkthnxUIDB.Variables[K.Realm][K.Name]["Mover"])
		table_wipe(KkthnxUIDB.Variables[K.Realm][K.Name]["AuraWatchMover"])
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
	f:SetSize(218, 90)
	f:CreateBorder()

	f.text = f:CreateFontString(nil, "OVERLAY")
	f.text:SetPoint("TOP", 0, -10)
	f.text:SetFontObject(K.UIFont)
	f.text:SetText(K.Title .. " Movers Config")
	f.text:SetWordWrap(false)

	local bu, text = {}, { LOCK, "Grids", "AuraWatch", RESET }
	for i = 1, 4 do
		bu[i] = CreateFrame("Button", nil, f)
		bu[i]:SetSize(100, 24)
		bu[i]:SkinButton()

		bu[i].text = bu[i]:CreateFontString(nil, "OVERLAY")
		bu[i].text:SetPoint("CENTER")
		bu[i].text:SetFontObject(K.UIFont)
		bu[i].text:SetText(text[i])
		bu[i].text:SetWordWrap(false)

		if i == 1 then
			bu[i]:SetPoint("BOTTOMLEFT", 6, 36)
		elseif i == 3 then
			bu[i]:SetPoint("TOP", bu[1], "BOTTOM", 0, -6)
		else
			bu[i]:SetPoint("LEFT", bu[i - 1], "RIGHT", 6, 0)
		end
	end

	bu[1]:SetScript("OnClick", Module.LockElements)

	bu[2]:SetScript("OnClick", function()
		_G.SlashCmdList["KKUI_TOGGLEGRID"]("64")
	end)

	bu[3]:SetScript("OnClick", function(self)
		self.state = not self.state
		if self.state then
			SlashCmdList.AuraWatch("move")
		else
			SlashCmdList.AuraWatch("lock")
		end
	end)

	-- Reset
	bu[4]:SetScript("OnClick", function()
		StaticPopup_Show("RESET_MOVER")
	end)

	local header = CreateFrame("Frame", nil, f)
	header:SetSize(212, 30)
	header:SetPoint("TOP")
	K.CreateMoverFrame(header, f)

	-- stylua: ignore
	local tips = K.InfoColor .. "|nCTRL + " .. L["Right Click"] .. K.SystemColor .. " = Reset Mover" .. K.InfoColor .. "|nSHIFT + " .. L["Right Click"] .. K.SystemColor .. " = Hide Panel"
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
	xBox:SetSize(60, 18)
	xBox:SetAutoFocus(false)
	xBox:SetTextInsets(5, 5, 0, 0)
	xBox:SetFontObject(K.UIFont)
	xBox:CreateBorder()
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
	yBox:SetSize(60, 18)
	yBox:SetAutoFocus(false)
	yBox:SetTextInsets(5, 5, 0, 0)
	yBox:SetFontObject(K.UIFont)
	yBox:CreateBorder()
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
		[1] = { degree = 180, offset = -1, x = 28, y = 9 },
		[2] = { degree = 0, offset = 1, x = 72, y = 9 },
		[3] = { degree = 90, offset = 1, x = 50, y = 22 },
		[4] = { degree = -90, offset = -1, x = 50, y = -4 },
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
		arrows[i]:SkinButton()

		arrows[i].Icon = arrows[i]:CreateTexture(nil, "ARTWORK")
		arrows[i].Icon:SetTexture("Interface\\OPTIONSFRAME\\VoiceChat-Play")
		arrows[i].Icon:SetAllPoints()
		arrows[i].Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

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
_G.SLASH_KKUI_MOVEUI4 = "/mmm"

_G.SlashCmdList["KKUI_LOCKUI"] = function()
	CreateConsole()
	Module:LockElements()
end
_G.SLASH_KKUI_LOCKUI1 = "/lockui"
_G.SLASH_KKUI_LOCKUI2 = "/lui"

function Module:OnEnable()
	updater = CreateFrame("Frame")
	updater:Hide()
	updater:SetScript("OnUpdate", function()
		Module.UpdateTrimFrame(updater.__owner)
	end)

	local loadMoverModules = {
		"DisableBlizzardMover",
	}

	for _, funcName in ipairs(loadMoverModules) do
		local func = self[funcName]
		if type(func) == "function" then
			local success, err = pcall(func, self)
			if not success then
				error("Error in function " .. funcName .. ": " .. tostring(err), 2)
			end
		end
	end
end

-- Disable blizzard edit mode
local function isUnitFrameEnable()
	return C["Unitframe"].Enable
end

local function isBuffEnable()
	return C["Auras"].Enable or C["Auras"].HideBlizBuff
end

local function isActionbarEnable()
	return C["ActionBar"].Enable
end

local function isCastbarEnable()
	return C["Unitframe"].Enable and C["Unitframe"].Castbars
end

local function isPartyEnable()
	return C["Party"].Enable
end

local function isRaidEnable()
	return C["Raid"].Enable
end

local function isArenaEnable()
	return C["Raid"].Enable
end

local function isTalkingHeadHidden()
	return C["Misc"].NoTalkingHead
end

local ignoredFrames = {
	-- ActionBars
	["StanceBar"] = isActionbarEnable,
	["EncounterBar"] = isActionbarEnable,
	["PetActionBar"] = isActionbarEnable,
	["PossessActionBar"] = isActionbarEnable,
	["MainMenuBarVehicleLeaveButton"] = isActionbarEnable,
	["MultiBarBottomLeft"] = isActionbarEnable,
	["MultiBarBottomRight"] = isActionbarEnable,
	["MultiBarLeft"] = isActionbarEnable,
	["MultiBarRight"] = isActionbarEnable,
	["MultiBar5"] = isActionbarEnable,
	["MultiBar6"] = isActionbarEnable,
	["MultiBar7"] = isActionbarEnable,
	-- Auras
	["BuffFrame"] = isBuffEnable,
	["DebuffFrame"] = isBuffEnable,
	-- UnitFrames
	["PlayerFrame"] = isUnitFrameEnable,
	["PlayerCastingBarFrame"] = isCastbarEnable,
	["FocusFrame"] = isUnitFrameEnable,
	["TargetFrame"] = isUnitFrameEnable,
	["BossTargetFrameContainer"] = isUnitFrameEnable,
	["PartyFrame"] = isPartyEnable,
	["CompactRaidFrameContainer"] = isRaidEnable,
	["ArenaEnemyFramesContainer"] = isArenaEnable,
	-- Misc
	["MinimapCluster"] = function()
		return not C["Minimap"].Enable
	end,
	["GameTooltipDefaultContainer"] = function()
		return true
	end,
	["TalkingHeadFrame"] = isTalkingHeadHidden,
}

local shutdownMode = {
	"OnEditModeEnter",
	"OnEditModeExit",
	"HasActiveChanges",
	"HighlightSystem",
	"SelectSystem",
}

function Module:DisableBlizzardMover()
	local editMode = EditModeManagerFrame

	-- remove the initial registers
	local registered = editMode.registeredSystemFrames
	for i = #registered, 1, -1 do
		local frame = registered[i]
		local ignore = ignoredFrames[frame:GetName()]

		if ignore and ignore() then
			for _, key in next, shutdownMode do
				frame[key] = K.Noop
			end
		end
	end

	-- account settings will be tainted
	local mixin = editMode.AccountSettings
	if isCastbarEnable() then
		mixin.RefreshCastBar = K.Noop
	end
	if isBuffEnable() then
		mixin.RefreshAuraFrame = K.Noop
	end
	if isRaidEnable() then
		mixin.ResetRaidFrames = K.Noop
		mixin.RefreshRaidFrames = K.Noop
	end
	if isArenaEnable() then
		mixin.RefreshArenaFrames = K.Noop
	end
	if isPartyEnable() then
		mixin.ResetPartyFrames = K.Noop
		mixin.RefreshPartyFrames = K.Noop
	end
	if isTalkingHeadHidden() then
		mixin.RefreshTalkingHeadFrame = K.Noop
	end
	if isUnitFrameEnable() then
		mixin.ResetTargetAndFocus = K.Noop
		mixin.RefreshTargetAndFocus = K.Noop
		mixin.RefreshBossFrames = K.Noop
	end
	if isActionbarEnable() then
		mixin.RefreshEncounterBar = K.Noop
		mixin.RefreshActionBarShown = K.Noop
		mixin.RefreshVehicleLeaveButton = K.Noop
		mixin.RefreshReputationBar = K.Noop

		if _G.MainStatusTrackingBarContainer then -- Ignore Experience Bar in EditMode
			_G.MainStatusTrackingBarContainer.OnEditModeEnter = K.Noop
		end
	end
	--ObjectiveTrackerFrame.IsInDefaultPosition = K.Noop
end
