local K, C, L = unpack(select(2, ...))
local Module = K:GetModule("ActionBar")

-- Sourced: siweia (NDui)

local _G = _G
local string_find = _G.string.find
local string_format = _G.string.format
local string_upper = _G.string.upper
local tonumber = _G.tonumber

local CreateFrame = _G.CreateFrame
local GetBindingKey = _G.GetBindingKey
local GetMacroInfo = _G.GetMacroInfo
local GetSpellBookItemName = _G.GetSpellBookItemName
local InCombatLockdown = _G.InCombatLockdown
local IsAddOnLoaded = _G.IsAddOnLoaded
local IsAltKeyDown = _G.IsAltKeyDown
local IsControlKeyDown = _G.IsControlKeyDown
local IsShiftKeyDown = _G.IsShiftKeyDown
local LoadBindings = _G.LoadBindings
local SaveBindings = _G.SaveBindings
local SetBinding = _G.SetBinding
local SlashCmdList = _G.SlashCmdList
local SpellBook_GetSpellBookSlot = _G.SpellBook_GetSpellBookSlot
local hooksecurefunc = _G.hooksecurefunc

-- Button types
local function hookActionButton(self)
	local pet = self.commandName and string_find(self.commandName, "^BONUSACTION") and "PET"
	local stance = self.commandName and string_find(self.commandName, "^SHAPESHIFT") and "STANCE"
	Module:Bind_Update(self, pet or stance or nil)
end

local function hookMacroButton(self)
	Module:Bind_Update(self, "MACRO")
end

local function hookSpellButton(self)
	Module:Bind_Update(self, "SPELL")
end

function Module:Bind_RegisterButton(button)
	if button.IsProtected and button.IsObjectType and button:IsObjectType("CheckButton") and button:IsProtected() then
		button:HookScript("OnEnter", hookActionButton)
	end
end

function Module:Bind_RegisterMacro()
	if self ~= "Blizzard_MacroUI" then
		return
	end

	for i = 1, MAX_ACCOUNT_MACROS do
		local button = _G["MacroButton"..i]
		button:HookScript("OnEnter", hookMacroButton)
	end
end

function Module:Bind_Create()
	if Module.keybindFrame then
		return
	end

	local frame = CreateFrame("Frame", nil, UIParent, "BackdropTemplate")
	frame:SetFrameStrata("DIALOG")
	frame:EnableMouse(true)
	frame:EnableKeyboard(true)
	frame:EnableMouseWheel(true)
	frame:CreateBorder()
	frame.KKUI_Background:SetVertexColor(1, 0.8, 0, 0.25)
	frame.KKUI_Border:SetVertexColor(1, 0.8, 0)
	frame:Hide()

	frame:SetScript("OnEnter", function()
		GameTooltip:SetOwner(frame, "ANCHOR_NONE")
		GameTooltip:SetPoint("BOTTOM", frame, "TOP", 0, 2)
		GameTooltip:AddLine(frame.tipName or frame.name, 0.6, 0.8, 1)

		if #frame.bindings == 0 then
			GameTooltip:AddLine(NOT_BOUND, 1, 0, 0)
			GameTooltip:AddLine(PRESS_KEY_TO_BIND)
		else
			GameTooltip:AddDoubleLine(L["Key Index"], L["Key Binding"], 0.6, 0.6, 0.6, 0.6, 0.6, 0.6)
			for i = 1, #frame.bindings do
				GameTooltip:AddDoubleLine(i, frame.bindings[i], 1, 1, 1, 0, 1, 0)
			end
			GameTooltip:AddLine("Press the escape key or right click to unbind this action.", 1, 0.8, 0, 1)
		end
		GameTooltip:Show()
	end)

	frame:SetScript("OnLeave", Module.Bind_HideFrame)

	frame:SetScript("OnKeyUp", function(_, key)
		Module:Bind_Listener(key)
	end)

	frame:SetScript("OnMouseUp", function(_, key)
		Module:Bind_Listener(key)
	end)

	frame:SetScript("OnMouseWheel", function(_, delta)
		if delta > 0 then
			Module:Bind_Listener("MOUSEWHEELUP")
		else
			Module:Bind_Listener("MOUSEWHEELDOWN")
		end
	end)

	for _, button in pairs(Module.buttons) do
		Module:Bind_RegisterButton(button)
	end

	for i = 1, 12 do
		local button = _G["SpellButton"..i]
		button:HookScript("OnEnter", hookSpellButton)
	end

	if not IsAddOnLoaded("Blizzard_MacroUI") then
		hooksecurefunc("LoadAddOn", Module.Bind_RegisterMacro)
	else
		Module.Bind_RegisterMacro("Blizzard_MacroUI")
	end

	Module.keybindFrame = frame
end

function Module:Bind_Update(button, spellmacro)
	local frame = Module.keybindFrame
	if not frame.enabled or InCombatLockdown() then
		return
	end

	frame.button = button
	frame.spellmacro = spellmacro
	frame:ClearAllPoints()
	frame:SetAllPoints(button)
	frame:Show()

	if spellmacro == "SPELL" then
		frame.id = SpellBook_GetSpellBookSlot(frame.button)
		frame.name = GetSpellBookItemName(frame.id, SpellBookFrame.bookType)
		frame.bindings = {GetBindingKey(spellmacro.." "..frame.name)}
	elseif spellmacro == "MACRO" then
		frame.id = frame.button:GetID()
		local colorIndex = K.Round(select(2, MacroFrameTab1Text:GetTextColor()), 1)
		if colorIndex == 0.8 then
			frame.id = frame.id + MAX_ACCOUNT_MACROS
		end
		frame.name = GetMacroInfo(frame.id)
		frame.bindings = {GetBindingKey(spellmacro.." "..frame.name)}
	elseif spellmacro == "STANCE" or spellmacro == "PET" then
		frame.name = button:GetName()
		if not frame.name then
			return
		end
		frame.tipName = button.commandName and GetBindingName(button.commandName)

		frame.id = tonumber(button:GetID())
		if not frame.id or frame.id < 1 or frame.id > (spellmacro == "STANCE" and 10 or 12) then
			frame.bindstring = "CLICK "..frame.name..":LeftButton"
		else
			frame.bindstring = (spellmacro=="STANCE" and "SHAPESHIFTBUTTON" or "BONUSACTIONBUTTON")..frame.id
		end
		frame.bindings = {GetBindingKey(frame.bindstring)}
	else
		frame.name = button:GetName()
		if not frame.name then
			return
		end
		frame.tipName = button.commandName and GetBindingName(button.commandName)

		frame.action = tonumber(button.action)
		if button.isCustomButton or not frame.action or frame.action < 1 or frame.action > 168 then
			frame.bindstring = "CLICK "..frame.name..":LeftButton"
		else
			local modact = 1+(frame.action-1)%12
			if frame.name == "ExtraActionButton1" then
				frame.bindstring = "EXTRAACTIONBUTTON1"
			elseif frame.action < 25 or frame.action > 72 then
				frame.bindstring = "ACTIONBUTTON"..modact
			elseif frame.action < 73 and frame.action > 60 then
				frame.bindstring = "MULTIACTIONBAR1BUTTON"..modact
			elseif frame.action < 61 and frame.action > 48 then
				frame.bindstring = "MULTIACTIONBAR2BUTTON"..modact
			elseif frame.action < 49 and frame.action > 36 then
				frame.bindstring = "MULTIACTIONBAR4BUTTON"..modact
			elseif frame.action < 37 and frame.action > 24 then
				frame.bindstring = "MULTIACTIONBAR3BUTTON"..modact
			end
		end
		frame.bindings = {GetBindingKey(frame.bindstring)}
	end

	-- Refresh tooltip
	frame:GetScript("OnEnter")(self)
end

local ignoreKeys = {
	["LALT"] = true,
	["RALT"] = true,
	["LCTRL"] = true,
	["RCTRL"] = true,
	["LSHIFT"] = true,
	["RSHIFT"] = true,
	["UNKNOWN"] = true,
	["LeftButton"] = true,
}

function Module:Bind_Listener(key)
	local frame = Module.keybindFrame
	if key == "ESCAPE" or key == "RightButton" then
		if frame.bindings then
			for i = 1, #frame.bindings do
				SetBinding(frame.bindings[i])
			end
		end
		K.Print(string_format(L["Clear Binds"], frame.tipName or frame.name))

		Module:Bind_Update(frame.button, frame.spellmacro)
		return
	end

	local isKeyIgnore = ignoreKeys[key]
	if isKeyIgnore then
		return
	end

	if key == "MiddleButton" then
		key = "BUTTON3"
	end

	if string_find(key, "Button%d") then
		key = string_upper(key)
	end

	local alt = IsAltKeyDown() and "ALT-" or ""
	local ctrl = IsControlKeyDown() and "CTRL-" or ""
	local shift = IsShiftKeyDown() and "SHIFT-" or ""

	if not frame.spellmacro or frame.spellmacro == "PET" or frame.spellmacro == "STANCE" then
		SetBinding(alt..ctrl..shift..key, frame.bindstring)
	else
		SetBinding(alt..ctrl..shift..key, frame.spellmacro.." "..frame.name)
	end
	K.Print((frame.tipName or frame.name).." |cff00ff00"..L["Key Bound To"].."|r "..alt..ctrl..shift..key)

	Module:Bind_Update(frame.button, frame.spellmacro)
end

function Module:Bind_HideFrame()
	local frame = Module.keybindFrame
	frame:ClearAllPoints()
	frame:Hide()

	if not GameTooltip:IsForbidden() then
		GameTooltip:Hide()
	end
end

function Module:Bind_Activate()
	Module.keybindFrame.enabled = true
	K:RegisterEvent("PLAYER_REGEN_DISABLED", Module.Bind_Deactivate)
end

function Module:Bind_Deactivate(save)
	if save == true then
		SaveBindings(KkthnxUIDB.Variables[K.Realm][K.Name].BindType)
		K.Print(K.SystemColor..L["Save KeyBinds"].."|r")
	else
		LoadBindings(KkthnxUIDB.Variables[K.Realm][K.Name].BindType)
		K.Print(K.SystemColor..L["Discard KeyBinds"].."|r")
	end

	Module:Bind_HideFrame()
	Module.keybindFrame.enabled = false
	K:UnregisterEvent("PLAYER_REGEN_DISABLED", Module.Bind_Deactivate)
	Module.keybindDialog:Hide()
end

function Module:Bind_CreateDialog()
	local dialog = Module.keybindDialog
	if dialog then
		dialog:Show()
		return
	end

	local frame = CreateFrame("Frame", nil, UIParent)
	frame:SetSize(320, 100)
	frame:SetPoint("TOP", 0, -135)
	frame:CreateBorder()

	frame.top = CreateFrame("Frame", nil, frame)
	frame.top:SetSize(320, 20)
	frame.top:SetPoint("TOP", 0, 26)
	frame.top:CreateBorder()

	K.CreateFontString(frame.top, 14, K.Title.." "..K.SystemColor..KEY_BINDING, "", false, "CENTER", 0, 0)

	frame.bottom = CreateFrame("Frame", nil, frame)
	frame.bottom:SetSize(294, 20)
	frame.bottom:SetPoint("BOTTOMRIGHT", 0, -26)
	frame.bottom:CreateBorder()

	frame.text = frame:CreateFontString(nil, "OVERLAY")
	frame.text:SetFont(C["Media"].Fonts.KkthnxUIFont, 12)
	frame.text:SetWidth(314)
	frame.text:SetTextColor(1, .8, 0)
	frame.text:SetShadowOffset(1, -1)
	frame.text:SetPoint("TOP", 0, -15)
	frame.text:SetText(K.SystemColor..L["Keybind Mode"].."|r")

	local button1 = CreateFrame("Button", nil, frame, "OptionsButtonTemplate")
	button1:SetSize(118, 20)
	button1:SkinButton()
	button1:SetScript("OnClick", function()
		Module:Bind_Deactivate(true)
	end)
	button1:SetFrameLevel(frame:GetFrameLevel() + 1)
	button1:SetPoint("BOTTOMLEFT", 25, 10)

	button1.text = button1:CreateFontString(nil, "OVERLAY")
	button1.text:SetFont(C["Media"].Fonts.KkthnxUIFont, 12)
	button1.text:SetShadowOffset(1, -1)
	button1.text:SetPoint("CENTER", button1)
	button1.text:SetText(APPLY)

	local button2 = CreateFrame("Button", nil, frame, "OptionsButtonTemplate")
	button2:SetSize(118, 20)
	button2:SkinButton()
	button2:SetScript("OnClick", function()
		Module:Bind_Deactivate()
	end)
	button2:SetFrameLevel(frame:GetFrameLevel() + 1)
	button2:SetPoint("BOTTOMRIGHT", -25, 10)

	button2.text = button2:CreateFontString(nil, "OVERLAY")
	button2.text:SetFont(C["Media"].Fonts.KkthnxUIFont, 12)
	button2.text:SetShadowOffset(1, -1)
	button2.text:SetPoint("CENTER", button2)
	button2.text:SetText(CANCEL)

	local checkBox = CreateFrame("CheckButton", nil, frame, "OptionsCheckButtonTemplate")
	checkBox:SetSize(20, 20)
	checkBox:SkinCheckBox()
	checkBox:SetChecked(KkthnxUIDB.Variables[K.Realm][K.Name].BindType == 2)
	checkBox:SetPoint("RIGHT", frame.bottom, "LEFT", -6, 0)
	checkBox:SetScript("OnClick", function(self)
		KkthnxUIDB.Variables[K.Realm][K.Name].BindType = self:GetChecked() and 2 or 1
	end)

	checkBox.text = frame.bottom:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	checkBox.text:SetPoint("CENTER", 0, 0)
	checkBox.text:SetText(checkBox:GetChecked() and K.SystemColor..CHARACTER_SPECIFIC_KEYBINDINGS.."|r" or K.GreyColor..CHARACTER_SPECIFIC_KEYBINDINGS.."|r")
	checkBox:SetHitRectInsets(0, 0 - checkBox.text:GetWidth(), 0, 0)

	Module.keybindDialog = frame
end

SlashCmdList["KKUI_KEYBINDS"] = function()
	if InCombatLockdown() then
		UIErrorsFrame:AddMessage(K.InfoColor..ERR_NOT_IN_COMBAT)
		return
	end

	Module:Bind_Create()
	Module:Bind_Activate()
	Module:Bind_CreateDialog()
end

_G.SLASH_KKUI_KEYBINDS1 = "/bindkey"
_G.SLASH_KKUI_KEYBINDS2 = "/hoverbind"
_G.SLASH_KKUI_KEYBINDS3 = "/bk"
_G.SLASH_KKUI_KEYBINDS4 = "/bb"

if not K.CheckAddOnState("Bartender4") and not K.CheckAddOnState("Dominos") then
	_G.SLASH_KKUI_KEYBINDS5 = "/kb"
end

if not K.CheckAddOnState("HealBot") then
	_G.SLASH_KKUI_KEYBINDS6 = "/hb"
end