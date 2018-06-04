local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("DebugTools", "AceEvent-3.0", "AceHook-3.0")

if K.WowBuild < 24015 then
	return
end

-- WoW API
local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame
local InCombatLockdown = InCombatLockdown
local GetCVarBool = GetCVarBool
local StaticPopup_Hide = StaticPopup_Hide

function Module:ModifyErrorFrame()
	ScriptErrorsFrame.ScrollFrame.Text.cursorOffset = 0
	ScriptErrorsFrame.ScrollFrame.Text.cursorHeight = 0
	ScriptErrorsFrame.ScrollFrame.Text:SetScript("OnEditFocusGained", nil)

	local function ScriptErrors_UnHighlightText()
		ScriptErrorsFrame.ScrollFrame.Text:HighlightText(0, 0)
	end
	hooksecurefunc(ScriptErrorsFrame, "Update", ScriptErrors_UnHighlightText)

	-- Unhighlight text when focus is hit
	local function UnHighlightText(self)
		self:HighlightText(0, 0)
	end
	ScriptErrorsFrame.ScrollFrame.Text:HookScript("OnEscapePressed", UnHighlightText)

	ScriptErrorsFrame:SetSize(500, 300)
	ScriptErrorsFrame.ScrollFrame:SetSize(ScriptErrorsFrame:GetWidth() - 45, ScriptErrorsFrame:GetHeight() - 71)

	local BUTTON_WIDTH = 75
	local BUTTON_HEIGHT = 24
	local BUTTON_SPACING = 2

	-- Add a first button
	local firstButton = CreateFrame("Button", nil, ScriptErrorsFrame, "UIPanelButtonTemplate")
	firstButton:SetPoint("RIGHT", ScriptErrorsFrame.PreviousError, "LEFT", -BUTTON_SPACING, 0)
	firstButton:SetText("First")
	firstButton:SetHeight(BUTTON_HEIGHT)
	firstButton:SetWidth(BUTTON_WIDTH)
	firstButton:SetScript("OnClick", function()
		ScriptErrorsFrame.index = 1
		ScriptErrorsFrame:Update()
	end)
	ScriptErrorsFrame.firstButton = firstButton

	-- Also add a Last button for errors
	local lastButton = CreateFrame("Button", nil, ScriptErrorsFrame, "UIPanelButtonTemplate")
	lastButton:SetPoint("LEFT", ScriptErrorsFrame.NextError, "RIGHT", BUTTON_SPACING, 0)
	lastButton:SetHeight(BUTTON_HEIGHT)
	lastButton:SetWidth(BUTTON_WIDTH)
	lastButton:SetText("Last")
	lastButton:SetScript("OnClick", function()
		ScriptErrorsFrame.index = #(ScriptErrorsFrame.order)
		ScriptErrorsFrame:Update()
	end)
	ScriptErrorsFrame.lastButton = lastButton
end

function Module:ScriptErrorsFrame_UpdateButtons()
	local numErrors = #ScriptErrorsFrame.order
	local index = ScriptErrorsFrame.index
	if (index == 0) then
		ScriptErrorsFrame.lastButton:Disable()
		ScriptErrorsFrame.firstButton:Disable()
	else
		if ( numErrors == 1 ) then
			ScriptErrorsFrame.lastButton:Disable()
			ScriptErrorsFrame.firstButton:Disable()
		else
			ScriptErrorsFrame.lastButton:Enable()
			ScriptErrorsFrame.firstButton:Enable()
		end
	end
end

function Module:ScriptErrorsFrame_OnError(_, _, keepHidden)
	if keepHidden or Module.MessagePrinted or not InCombatLockdown() or GetCVarBool("scriptErrors") ~= true then return end

	K.Print(L["Blizzard"].Lua_Error_Recieved)
	Module.MessagePrinted = true
end

function Module:PLAYER_REGEN_ENABLED()
	ScriptErrorsFrame:SetParent(UIParent)
	Module.MessagePrinted = nil
end

function Module:PLAYER_REGEN_DISABLED()
	ScriptErrorsFrame:SetParent(K.UIFrameHider)
end

function Module:TaintError(event, addonName, addonFunc)
	if GetCVarBool("scriptErrors") ~= true or C["General"].TaintLog ~= true then return end
	ScriptErrorsFrame:OnError(L["Blizzard"].Taint_Error:format(event, addonName or "<name>", addonFunc or "<func>"), false, false)
end

function Module:StaticPopup_Show(name)
	if (name == "ADDON_ACTION_FORBIDDEN") then
		StaticPopup_Hide(name)
	end
end

function Module:OnEnable()
	if (not IsAddOnLoaded("Blizzard_DebugTools")) then
		LoadAddOn("Blizzard_DebugTools")
	end

	self:ModifyErrorFrame()
	self:SecureHook(ScriptErrorsFrame, "UpdateButtons", Module.ScriptErrorsFrame_UpdateButtons)
	self:SecureHook(ScriptErrorsFrame, "OnError", Module.ScriptErrorsFrame_OnError)
	self:SecureHook("StaticPopup_Show")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("ADDON_ACTION_BLOCKED", "TaintError")
	self:RegisterEvent("ADDON_ACTION_FORBIDDEN", "TaintError")
end