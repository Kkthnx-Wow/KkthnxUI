local K, C, L = unpack(select(2, ...))
if not K.IsDeveloper and not K.IsDeveloperRealm then return end

print("If you are seeing this message and you are |cffff0000NOT|r a dev of |cff3c9bedKkthnxUI|r then please contact Kkthnx")

-- Remove the editbox for deleting "good" items
StaticPopupDialogs.DELETE_ITEM.enterClicksFirstButton = true
StaticPopupDialogs.DELETE_GOOD_ITEM = StaticPopupDialogs.DELETE_ITEM

local KkthnxUIDebugTools = LibStub("AceAddon-3.0"):NewAddon("DebugTools", "AceEvent-3.0", "AceHook-3.0")

--Cache global variables
--WoW API / Variables
local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame
local ScriptErrorsFrame_Update = ScriptErrorsFrame_Update
local InCombatLockdown = InCombatLockdown
local GetCVarBool = GetCVarBool
local ScriptErrorsFrame_OnError = ScriptErrorsFrame_OnError
local StaticPopup_Hide = StaticPopup_Hide

-- Global variables that we don"t cache, list them here for mikk"s FindGlobals script
-- GLOBALS: ScriptErrorsFrameScrollFrameText, ScriptErrorsFrame, ScriptErrorsFrameScrollFrame
-- GLOBALS: UIParent, IsAddOnLoaded, LoadAddOn

function KkthnxUIDebugTools:ModifyErrorFrame()
	ScriptErrorsFrameScrollFrameText.cursorOffset = 0
	ScriptErrorsFrameScrollFrameText.cursorHeight = 0
	ScriptErrorsFrameScrollFrameText:SetScript("OnEditFocusGained", nil)

	--[[local Orig_ScriptErrorsFrame_Update = ScriptErrorsFrame_Update
	ScriptErrorsFrame_Update = function(...)
		if GetCVarBool("scriptErrors") ~= true then
			Orig_ScriptErrorsFrame_Update(...)
			return
		end

		-- Sometimes the locals table does not have an entry for an index, which can cause an argument #6 error
		-- in Blizzard_DebugTools.lua:430 and then cause a C stack overflow, this will prevent that
		local index = ScriptErrorsFrame.index
		if( not index or not ScriptErrorsFrame.order[index] ) then
			index = #(ScriptErrorsFrame.order)
		end

		if( index > 0 ) then
			ScriptErrorsFrame.locals[index] = ScriptErrorsFrame.locals[index] or L["No locals to dump"]
		end

		Orig_ScriptErrorsFrame_Update(...)

		-- Stop text highlighting again
		ScriptErrorsFrameScrollFrameText:HighlightText(0, 0)
	end]]
	local function ScriptErrors_UnHighlightText()
		ScriptErrorsFrameScrollFrameText:HighlightText(0, 0)
	end
	hooksecurefunc("ScriptErrorsFrame_Update", ScriptErrors_UnHighlightText)

	-- Unhighlight text when focus is hit
	local function UnHighlightText(self)
		self:HighlightText(0, 0)
	end
	ScriptErrorsFrameScrollFrameText:HookScript("OnEscapePressed", UnHighlightText)

	ScriptErrorsFrame:SetSize(500, 300)
	ScriptErrorsFrameScrollFrame:SetSize(ScriptErrorsFrame:GetWidth() - 45, ScriptErrorsFrame:GetHeight() - 71)

	local BUTTON_WIDTH = 75
	local BUTTON_HEIGHT = 24
	local BUTTON_SPACING = 2

	-- Add a first button
	local firstButton = CreateFrame("Button", nil, ScriptErrorsFrame, "UIPanelButtonTemplate")
	firstButton:SetPoint("BOTTOMRIGHT", ScriptErrorsFrame.previous, "BOTTOMLEFT", -BUTTON_SPACING, 0)
	firstButton:SetText("First")
	firstButton:SetHeight(BUTTON_HEIGHT)
	firstButton:SetWidth(BUTTON_WIDTH)
	firstButton:SetScript("OnClick", function()
		ScriptErrorsFrame.index = 1
		ScriptErrorsFrame_Update()
	end)
	ScriptErrorsFrame.firstButton = firstButton

	-- Also add a Last button for errors
	local lastButton = CreateFrame("Button", nil, ScriptErrorsFrame, "UIPanelButtonTemplate")
	lastButton:SetPoint("BOTTOMLEFT", ScriptErrorsFrame.next, "BOTTOMRIGHT", BUTTON_SPACING, 0)
	lastButton:SetHeight(BUTTON_HEIGHT)
	lastButton:SetWidth(BUTTON_WIDTH)
	lastButton:SetText("Last")
	lastButton:SetScript("OnClick", function()
		ScriptErrorsFrame.index = #(ScriptErrorsFrame.order)
		ScriptErrorsFrame_Update()
	end)
	ScriptErrorsFrame.lastButton = lastButton
end

function KkthnxUIDebugTools:ScriptErrorsFrame_UpdateButtons()
	local numErrors = #ScriptErrorsFrame.order
	local index = ScriptErrorsFrame.index
	if ( index == 0 ) then
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

function KkthnxUIDebugTools:ScriptErrorsFrame_OnError(_, keepHidden)
	if keepHidden or self.MessagePrinted or not InCombatLockdown() or GetCVarBool("scriptErrors") ~= true then return end

	K.Print("|cFFE30000Lua error recieved. You can view the error message when you exit combat.")
	self.MessagePrinted = true
end

function KkthnxUIDebugTools:PLAYER_REGEN_ENABLED()
	ScriptErrorsFrame:SetParent(UIParent)
	self.MessagePrinted = nil
end

function KkthnxUIDebugTools:PLAYER_REGEN_DISABLED()
	ScriptErrorsFrame:SetParent(self.HideFrame)
end

function KkthnxUIDebugTools:TaintError(event, addonName, addonFunc)
	-- if GetCVarBool("scriptErrors") ~= true or C.General.TaintLog ~= true then return end
	if GetCVarBool("scriptErrors") ~= true then return end
	ScriptErrorsFrame_OnError("%s: %s tried to call the protected function '%s'."):format(event, addonName or "<name>", addonFunc or "<func>", false)
end

function KkthnxUIDebugTools:StaticPopup_Show(name)
	if(name == "ADDON_ACTION_FORBIDDEN") then
		StaticPopup_Hide(name)
	end
end

function KkthnxUIDebugTools:Initialize()
	self.HideFrame = CreateFrame("Frame")
	self.HideFrame:Hide()

	if(not IsAddOnLoaded("Blizzard_DebugTools")) then
		LoadAddOn("Blizzard_DebugTools")
	end

	self:ModifyErrorFrame()
	self:SecureHook("ScriptErrorsFrame_UpdateButtons")
	self:SecureHook("ScriptErrorsFrame_OnError")
	self:SecureHook("StaticPopup_Show")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("ADDON_ACTION_BLOCKED", "TaintError")
	self:RegisterEvent("ADDON_ACTION_FORBIDDEN", "TaintError")
end

KkthnxUIDebugTools:Initialize()