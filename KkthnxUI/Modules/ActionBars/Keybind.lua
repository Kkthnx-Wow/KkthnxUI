local K, C, L = unpack(select(2, ...))

-- Sourced: Nightcracker (ncHoverBind)
-- Updated: Kkthnx (KkthnxUI)

local _G = _G
local print = _G.print
local tonumber = _G.tonumber

local APPLY = _G.APPLY
local CANCEL = _G.CANCEL
local EnumerateFrames = _G.EnumerateFrames
local ERR_NOT_IN_COMBAT = _G.ERR_NOT_IN_COMBAT
local GetBindingKey = _G.GetBindingKey
local GetMacroInfo = _G.GetMacroInfo
local GetSpellBookItemName = _G.GetSpellBookItemName
local hooksecurefunc = _G.hooksecurefunc
local InCombatLockdown = _G.InCombatLockdown
local IsAddOnLoaded = _G.IsAddOnLoaded
local IsAltKeyDown = _G.IsAltKeyDown
local IsControlKeyDown = _G.IsControlKeyDown
local IsShiftKeyDown = _G.IsShiftKeyDown
local LoadBindings = _G.LoadBindings
local SaveBindings = _G.SaveBindings
local SetBinding = _G.SetBinding
local SpellBook_GetSpellBookSlot = _G.SpellBook_GetSpellBookSlot

local bind, localmacros, frame = CreateFrame("Frame", "KkthnxUI_HoverBind", UIParent), 0
function K.BindingUI()
	if InCombatLockdown() then
		print("|cffffff00"..ERR_NOT_IN_COMBAT.."|r")
		return
	end

	if not bind.loaded then
		bind:SetFrameStrata("DIALOG")
		bind:EnableMouse(true)
		bind:EnableKeyboard(true)
		bind:EnableMouseWheel(true)
		bind.texture = bind:CreateTexture()
		bind.texture:SetAllPoints(bind)
		bind.texture:SetColorTexture(0, 0, 0, .25)
		bind:Hide()

		bind:SetScript("OnEvent", function(self)
			self:Deactivate(false)
		end)

		bind:SetScript("OnLeave", function(self)
			self:HideFrame()
		end)

		bind:SetScript("OnKeyUp", function(self, key)
			self:Listener(key)
		end)

		bind:SetScript("OnMouseUp", function(self, key)
			self:Listener(key)
		end)

		bind:SetScript("OnMouseWheel", function(self, delta)
			if delta > 0 then
				self:Listener("MOUSEWHEELUP")
			else
				self:Listener("MOUSEWHEELDOWN")
			end
		end)

		function bind:Update(b, spellmacro)
			if not self.enabled or InCombatLockdown() then return end

			self.button = b
			self.spellmacro = spellmacro
			self:ClearAllPoints()
			self:SetAllPoints(b)
			self:Show()
			ShoppingTooltip1:Hide()

			if spellmacro == "SPELL" then
				self.button.id = SpellBook_GetSpellBookSlot(self.button)
				self.button.name = GetSpellBookItemName(self.button.id, SpellBookFrame.bookType)

				GameTooltip:AddLine("Trigger")
				GameTooltip:Show()
				GameTooltip:SetScript("OnHide", function(self)
					self:SetOwner(bind, "ANCHOR_NONE")
					self:SetPoint("BOTTOM", bind, "TOP", 0, 1)
					self:AddLine(bind.button.name, 1, 1, 1)
					bind.button.bindings = {GetBindingKey(spellmacro.." "..bind.button.name)}
					if #bind.button.bindings == 0 then
						self:AddLine(OPTION_TOOLTIP_AUTO_SELF_CAST_NONE_KEY, .6, .6, .6)
					else
						self:AddDoubleLine(KEY1, KEY_BINDING, .6, .6, .6, .6, .6, .6)
						for i = 1, #bind.button.bindings do
							self:AddDoubleLine(i, bind.button.bindings[i])
						end
					end
					self:Show()
					self:SetScript("OnHide", nil)
				end)
			elseif spellmacro == "MACRO" then
				self.button.id = self.button:GetID()
				if localmacros == 1 then
					self.button.id = self.button.id + 36
				end
				self.button.name = GetMacroInfo(self.button.id)

				GameTooltip:SetOwner(bind, "ANCHOR_NONE")
				GameTooltip:SetPoint("BOTTOM", bind, "TOP", 0, 1)
				GameTooltip:AddLine(bind.button.name, 1, 1, 1)

				bind.button.bindings = {GetBindingKey(spellmacro.." "..bind.button.name)}
				if #bind.button.bindings == 0 then
					GameTooltip:AddLine(OPTION_TOOLTIP_AUTO_SELF_CAST_NONE_KEY, .6, .6, .6)
				else
					GameTooltip:AddDoubleLine(KEY1, KEY_BINDING, .6, .6, .6, .6, .6, .6)
					for i = 1, #bind.button.bindings do
						GameTooltip:AddDoubleLine("Binding"..i, bind.button.bindings[i], 1, 1, 1)
					end
				end
				GameTooltip:Show()
			elseif spellmacro == "STANCE" or spellmacro == "PET" then
				self.button.id = tonumber(b:GetID())
				self.button.name = b:GetName()

				if not self.button.name then
					return
				end

				if not self.button.id or self.button.id < 1 or self.button.id > (spellmacro == "STANCE" and 10 or 12) then
					self.button.bindstring = "CLICK "..self.button.name..":LeftButton"
				else
					self.button.bindstring = (spellmacro == "STANCE" and "SHAPESHIFTBUTTON" or "BONUSACTIONBUTTON")..self.button.id
				end

				GameTooltip:AddLine("Trigger")
				GameTooltip:Show()
				GameTooltip:SetScript("OnHide", function(self)
					self:SetOwner(bind, "ANCHOR_NONE")
					self:SetPoint("BOTTOM", bind, "TOP", 0, 1)
					self:AddLine(bind.button.name, 1, 1, 1)
					bind.button.bindings = {GetBindingKey(bind.button.bindstring)}
					if #bind.button.bindings == 0 then
						self:AddLine(OPTION_TOOLTIP_AUTO_SELF_CAST_NONE_KEY, .6, .6, .6)
					else
						self:AddDoubleLine(KEY1, KEY_BINDING, .6, .6, .6, .6, .6, .6)
						for i = 1, #bind.button.bindings do
							self:AddDoubleLine(KEY1..i, bind.button.bindings[i])
						end
					end
					self:Show()
					self:SetScript("OnHide", nil)
				end)
			else
				self.button.action = tonumber(b.action)
				self.button.name = b:GetName()

				if not self.button.name then
					return
				end

				if not self.button.action or self.button.action < 1 or self.button.action > 132 then
					self.button.bindstring = "CLICK "..self.button.name..":LeftButton"
				else
					local modact = 1+(self.button.action-1)%12
					if self.button.action < 25 or self.button.action > 72 then
						self.button.bindstring = "ACTIONBUTTON"..modact
					elseif self.button.action < 73 and self.button.action > 60 then
						self.button.bindstring = "MULTIACTIONBAR1BUTTON"..modact
					elseif self.button.action < 61 and self.button.action > 48 then
						self.button.bindstring = "MULTIACTIONBAR2BUTTON"..modact
					elseif self.button.action < 49 and self.button.action > 36 then
						self.button.bindstring = "MULTIACTIONBAR4BUTTON"..modact
					elseif self.button.action < 37 and self.button.action > 24 then
						self.button.bindstring = "MULTIACTIONBAR3BUTTON"..modact
					end
				end

				GameTooltip:AddLine("Trigger")
				GameTooltip:Show()
				GameTooltip:SetScript("OnHide", function(self)
					self:SetOwner(bind, "ANCHOR_NONE")
					self:SetPoint("BOTTOM", bind, "TOP", 0, 1)
					self:AddLine(bind.button.name, 1, 1, 1)
					bind.button.bindings = {GetBindingKey(bind.button.bindstring)}
					if #bind.button.bindings == 0 then
						self:AddLine(OPTION_TOOLTIP_AUTO_SELF_CAST_NONE_KEY, .6, .6, .6)
					else
						self:AddDoubleLine(KEY1, KEY_BINDING, .6, .6, .6, .6, .6, .6)
						for i = 1, #bind.button.bindings do
							self:AddDoubleLine(i, bind.button.bindings[i])
						end
					end
					self:Show()
					self:SetScript("OnHide", nil)
				end)
			end
		end

		function bind:Listener(key)
			if key == "ESCAPE" or key == "RightButton" then
				for i = 1, #self.button.bindings do
					SetBinding(self.button.bindings[i])
				end
				print("|cffffff00"..UNBIND.."|r".." |cff00ff00"..self.button.name.."|r.")
				self:Update(self.button, self.spellmacro)
				if self.spellmacro ~= "MACRO" then
					GameTooltip:Hide()
				end
				return
			end

			if key == "LSHIFT"
			or key == "RSHIFT"
			or key == "LCTRL"
			or key == "RCTRL"
			or key == "LALT"
			or key == "RALT"
			or key == "UNKNOWN"
			then
				return
			end

			if key == "MiddleButton" then
				key = "BUTTON3"
			end

			if key:find("Button%d") then
				key = key:upper()
			end

			local alt = IsAltKeyDown() and "ALT-" or ""
			local ctrl = IsControlKeyDown() and "CTRL-" or ""
			local shift = IsShiftKeyDown() and "SHIFT-" or ""

			if not self.spellmacro or self.spellmacro == "PET" or self.spellmacro == "STANCE" then
				SetBinding(alt..ctrl..shift..key, self.button.bindstring)
			else
				SetBinding(alt..ctrl..shift..key, self.spellmacro.." "..self.button.name)
			end

			print(alt..ctrl..shift..key.." |cff00ff00"..KEY1.."|r "..self.button.name..".")
			self:Update(self.button, self.spellmacro)

			if self.spellmacro ~= "MACRO" then
				GameTooltip:Hide()
			end
		end

		function bind:HideFrame()
			self:ClearAllPoints()
			self:Hide()
			GameTooltip:Hide()
		end

		function bind:Activate()
			self.enabled = true
			self:RegisterEvent("PLAYER_REGEN_DISABLED")
		end

		function bind:Deactivate(save)
			if save then
				SaveBindings(KkthnxUIData[GetRealmName()][UnitName("player")].BindType)
				print("|cffffff00"..KEY_BOUND.."|r")
			else
				LoadBindings(KkthnxUIData[GetRealmName()][UnitName("player")].BindType)
				print("|cffffff00"..UNCHECK_ALL.."|r")
			end

			self.enabled = false
			self:HideFrame()
			self:UnregisterEvent("PLAYER_REGEN_DISABLED")
			frame:Hide()
		end

		function bind:CallBindFrame()
			if frame then
				frame:Show()
				return
			end

			frame = CreateFrame("Frame", nil, UIParent)
			frame:SetSize(320, 100)
			frame:SetPoint("TOP", 0, -136)
			frame:CreateBorder()

			frame.top = CreateFrame("Frame", nil, frame)
			frame.top:SetSize(320, 20)
			frame.top:SetPoint("TOP", 0, 26)
			frame.top:CreateBorder()

			frame.title = frame.top:CreateFontString(nil, "OVERLAY")
			frame.title:SetFont(C["Media"].Font, 14)
			frame.title:SetTextColor(1, .8, 0)
			frame.title:SetShadowOffset(1.25, -1.25)
			frame.title:SetPoint("CENTER")
			frame.title:SetText(K.Title.." "..KEY_BINDING)

			frame.bottom = CreateFrame("Frame", nil, frame)
			frame.bottom:SetSize(320, 20)
			frame.bottom:SetPoint("BOTTOM", 0, -26)
			frame.bottom:CreateBorder()

			frame.text = frame:CreateFontString(nil, "OVERLAY")
			frame.text:SetFont(C["Media"].Font, 12)
			frame.text:SetWidth(314)
			frame.text:SetTextColor(1, .8, 0)
			frame.text:SetShadowOffset(1.25, -1.25)
			frame.text:SetPoint("TOP", 0, -15)
			frame.text:SetText(L["Keybind Mode"])

			local button1 = CreateFrame("Button", nil, frame, "OptionsButtonTemplate")
			button1:SetSize(118, 20)
			button1:SkinButton()
			button1:SetScript("OnClick", function()
				bind:Deactivate(true)
			end)
			button1:SetFrameLevel(frame:GetFrameLevel() + 1)
			button1:SetPoint("BOTTOMLEFT", 25, 10)

			button1.text = button1:CreateFontString(nil, "OVERLAY")
			button1.text:SetFont(C["Media"].Font, 12)
			button1.text:SetShadowOffset(1.25, -1.25)
			button1.text:SetPoint("CENTER", button1)
			button1.text:SetText(APPLY)

			local button2 = CreateFrame("Button", nil, frame, "OptionsButtonTemplate")
			button2:SetSize(118, 20)
			button2:SkinButton()
			button2:SetScript("OnClick", function()
				bind:Deactivate(false)
			end)
			button2:SetFrameLevel(frame:GetFrameLevel() + 1)
			button2:SetPoint("BOTTOMRIGHT", -25, 10)

			button2.text = button2:CreateFontString(nil, "OVERLAY")
			button2.text:SetFont(C["Media"].Font, 12)
			button2.text:SetShadowOffset(1.25, -1.25)
			button2.text:SetPoint("CENTER", button2)
			button2.text:SetText(CANCEL)

			local checkBox = CreateFrame("CheckButton", nil, frame, "OptionsCheckButtonTemplate")
			checkBox:SetSize(14, 14)
			checkBox:SkinCheckBox()
			checkBox:SetChecked(KkthnxUIData[GetRealmName()][UnitName("player")].BindType == 2)
			checkBox:SetPoint("CENTER", frame.bottom, -96, 0)
			checkBox:SetScript("OnClick", function(self)
				if self:GetChecked() == true then
					KkthnxUIData[GetRealmName()][UnitName("player")].BindType = 2
				else
					KkthnxUIData[GetRealmName()][UnitName("player")].BindType = 1
				end
			end)

			checkBox.text = frame.bottom:CreateFontString(nil, "OVERLAY", "GameFontNormal")
			checkBox.text:SetPoint("CENTER", 14, 1)
			checkBox.text:SetText(CHARACTER_SPECIFIC_KEYBINDINGS)
			checkBox:SetHitRectInsets(0, 0 - checkBox.text:GetWidth(), 0, 0)
			checkBox.text:Show()
		end

		-- Registering
		local stance = StanceButton1:GetScript("OnClick")
		local pet = PetActionButton1:GetScript("OnClick")
		local button = ActionButton1:GetScript("OnClick")

		local function register(val)
			if val.IsProtected and val.GetObjectType and val.GetScript and val:GetObjectType() == "CheckButton" and val:IsProtected() then
				local script = val:GetScript("OnClick")
				if script == button then
					val:HookScript("OnEnter", function(self)
						bind:Update(self)
					end)
				elseif script == stance then
					val:HookScript("OnEnter", function(self)
						bind:Update(self, "STANCE")
					end)
				elseif script == pet then
					val:HookScript("OnEnter", function(self)
						bind:Update(self, "PET")
					end)
				end
			end
		end

		local val = EnumerateFrames()
		while val do
			register(val)
			val = EnumerateFrames(val)
		end

		for i = 1, 12 do
			local b = _G["SpellButton"..i]
			b:HookScript("OnEnter", function(self)
				bind:Update(self, "SPELL")
			end)
		end

		local function registermacro()
			for i = 1, 36 do
				local b = _G["MacroButton"..i]
				b:HookScript("OnEnter", function(self)
					bind:Update(self, "MACRO")
				end)
			end

			MacroFrameTab1:HookScript("OnMouseUp", function()
				localmacros = 0
			end)

			MacroFrameTab2:HookScript("OnMouseUp", function()
				localmacros = 1
			end)
		end

		if not IsAddOnLoaded("Blizzard_MacroUI") then
			hooksecurefunc("LoadAddOn", function(addon)
				if addon == "Blizzard_MacroUI" then
					registermacro()
				end
			end)
		else
			registermacro()
		end
		bind.loaded = 1
	end

	if not bind.enabled then
		bind:Activate()
		bind:CallBindFrame()
	end
end

-- K:RegisterChatCommand("bindkey", K.BindingUI)
-- K:RegisterChatCommand("hoverbind", K.BindingUI)
-- K:RegisterChatCommand("bk", K.BindingUI)

-- if not K.CheckAddOnState("Bartender4") and not K.CheckAddOnState("Dominos") then
-- 	K:RegisterChatCommand("kb", K.BindingUI)
-- end

-- if not K.CheckAddOnState("HealBot") then
-- 	K:RegisterChatCommand("hb", K.BindingUI)
-- end