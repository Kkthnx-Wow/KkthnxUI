local K, C = unpack(select(2, ...))

local _G = _G
local string_byte = _G.string.byte
local string_gsub = _G.string.gsub
local string_sub = _G.string.sub

local CreateFrame = _G.CreateFrame
local GetActionText = _G.GetActionText
local GetFlyoutID = _G.GetFlyoutID
local GetFlyoutInfo = _G.GetFlyoutInfo
local GetNumFlyouts = _G.GetNumFlyouts
local InCombatLockdown = _G.InCombatLockdown
local NUM_PET_ACTION_SLOTS = _G.NUM_PET_ACTION_SLOTS
local NUM_STANCE_SLOTS = _G.NUM_STANCE_SLOTS
local hooksecurefunc = _G.hooksecurefunc

local FlyoutButtons = 0
local function StyleNormalButton(self)
	local Name = self:GetName()
	local Action = self.action
	local Button = self
	local Icon = _G[Name.."Icon"]
	local Count = _G[Name.."Count"]
	local Flash	 = _G[Name.."Flash"]
	local HotKey = _G[Name.."HotKey"]
	local Border = _G[Name.."Border"]
	local Btname = _G[Name.."Name"]
	local Normal = _G[Name.."NormalTexture"]
	local BtnBG = _G[Name.."FloatingBG"]
	local Font = K.GetFont(C["UIFonts"].ActionBarsFonts)

	if not Button.IsSkinned then
		Flash:SetTexture("")
		Button:SetNormalTexture("")

		Count:ClearAllPoints()
		Count:SetPoint("BOTTOMRIGHT", 0, 2)

		HotKey:ClearAllPoints()
		HotKey:SetPoint("TOPRIGHT", 0, -3)

		Count:SetFontObject(Font)

		if (Btname) then
			if (C["ActionBar"].Macro) then
				Btname:SetFontObject(Font)
				Btname:ClearAllPoints()
				Btname:SetPoint("BOTTOM", 1, 1)
			else
				Btname:SetText("")
				Btname:Kill()
			end
		end

		if (BtnBG) then
			BtnBG:Kill()
		end

		if (C["ActionBar"].Hotkey) then
			HotKey:SetFontObject(Font)
			HotKey.ClearAllPoints = K.Noop
			HotKey.SetPoint = K.Noop
		else
			HotKey:SetText("")
			HotKey:Kill()
		end

		if (Name:match("Extra")) then
			Button.Pushed = true
		end

		Button:CreateBorder()
		Button:CreateInnerShadow()

		Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		Icon:SetDrawLayer("BACKGROUND", 7)

		if (Normal) then
			Normal:ClearAllPoints()
			Normal:SetPoint("TOPLEFT")
			Normal:SetPoint("BOTTOMRIGHT")

			if (Button:GetChecked()) then
				ActionButton_UpdateState(Button)
			end
		end

		if (Border) then
			Border:SetTexture("")
		end

		Button:StyleButton()
		Button.IsSkinned = true
	end

	K.UpdateHotkey(Button)

	if (Border and C["ActionBar"].EquipBorder) then
		if (Border:IsShown()) then
			Button:SetBackdropBorderColor(.08, .70, 0)
		else
			Button:SetBackdropBorderColor()
		end
	end

	if (Action and Btname and Normal and C["ActionBar"].Macro) then
		local String = GetActionText(Action)

		if String then
			local Text

			if string_byte(String, 1) > 223 then
				Text = string_sub(String, 1, 9)
			else
				Text = string_sub(String, 1, 4)
			end

			Btname:SetText(Text)
		end
	end
end

local function SkinPetAndShiftButton(Normal, Button, Icon, Name, Pet)
	if Button.IsSkinned then
		return
	end

	local PetSize = C["ActionBar"].StancePetSize
	local HotKey = _G[Button:GetName().."HotKey"]
	local Flash = _G[Name.."Flash"]
	local Font = K.GetFont(C["UIFonts"].ActionBarsFonts)

	Button:SetNormalTexture("")
	hooksecurefunc(Button, "SetNormalTexture", function(self, texture)
		if texture and texture ~= "" then
			self:SetNormalTexture("")
		end
	end)

	Button:SetSize(PetSize, PetSize)
	Button:CreateBorder()
	Button:CreateInnerShadow()

	if (C["ActionBar"].Hotkey) then
		HotKey:SetFontObject(Font)
		HotKey:ClearAllPoints()
		HotKey:SetPoint("TOPRIGHT", 0, -3)
	else
		HotKey:SetText("")
		HotKey:Kill()
	end

	Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
	Icon:SetAllPoints()
	Icon:SetDrawLayer("BACKGROUND", 7)

	if (Pet) then
		if (PetSize < 30) then
			local AutoCast = _G[Name.."AutoCastable"]
			AutoCast:SetAlpha(0)
		end

		local Shine = _G[Name.."Shine"]
		Shine:SetSize(PetSize, PetSize)
		Shine:ClearAllPoints()
		Shine:SetPoint("CENTER", Button, 0, 0)

		K.UpdateHotkey(Button)
	end

	Flash:SetTexture("")

	if Normal then
		Normal:ClearAllPoints()
		Normal:SetPoint("TOPLEFT")
		Normal:SetPoint("BOTTOMRIGHT")
	end

	Button:StyleButton()
	Button.IsSkinned = true
end

local function SkinStanceButtons()
	for i = 1, NUM_STANCE_SLOTS do
		local Name = "StanceButton"..i
		local Button = _G[Name]
		local Icon = _G[Name.."Icon"]
		local Normal = _G[Name.."NormalTexture"]

		SkinPetAndShiftButton(Normal, Button, Icon, Name, false)
	end
end

local function SkinPetButtons()
	for i = 1, NUM_PET_ACTION_SLOTS do
		local Name = "PetActionButton"..i
		local Button = _G[Name]
		local Icon = _G[Name.."Icon"]
		local Normal = _G[Name.."NormalTexture2"]

		SkinPetAndShiftButton(Normal, Button, Icon, Name, true)
	end
end

function K.UpdateHotkey(self)
	local HotKey = _G[self:GetName().."HotKey"]
	local Text = HotKey:GetText()
	local Indicator = _G["RANGE_INDICATOR"]

	if (not Text) then
		return
	end

	Text = string_gsub(Text, "(a%-)", "A")
	Text = string_gsub(Text, "(ALT%-)", "A")
	Text = string_gsub(Text, "(c%-)", "C")
	Text = string_gsub(Text, "(CTRL%-)", "C")
	Text = string_gsub(Text, "(Mouse Button )", "M")
	Text = string_gsub(Text, "(s%-)", "S")
	Text = string_gsub(Text, "(SHIFT%-)", "S")
	Text = string_gsub(Text, "(st%-)", "C") -- german control 'Steuerung'
	Text = string_gsub(Text, "(Кнопка мыши )", "M")
	Text = string_gsub(Text, "(滑鼠按鍵)", "M")
	Text = string_gsub(Text, "(鼠标按键)", "M")
	Text = string_gsub(Text, CAPSLOCK_KEY_TEXT, "CL")
	Text = string_gsub(Text, KEY_BUTTON1, "LMB")
	Text = string_gsub(Text, KEY_BUTTON10, "M10")
	Text = string_gsub(Text, KEY_BUTTON2, "RMB")
	Text = string_gsub(Text, KEY_BUTTON3, "M3")
	Text = string_gsub(Text, KEY_BUTTON4, "M4")
	Text = string_gsub(Text, KEY_BUTTON5, "M5")
	Text = string_gsub(Text, KEY_BUTTON6, "M6")
	Text = string_gsub(Text, KEY_BUTTON7, "M7")
	Text = string_gsub(Text, KEY_BUTTON8, "M8")
	Text = string_gsub(Text, KEY_BUTTON9, "M9")
	Text = string_gsub(Text, KEY_DELETE, "Del")
	Text = string_gsub(Text, KEY_HOME, "Hm")
	Text = string_gsub(Text, KEY_INSERT, "Ins")
	Text = string_gsub(Text, KEY_INSERT_MAC, "Hlp") -- mac
	Text = string_gsub(Text, KEY_MOUSEWHEELDOWN, "MD")
	Text = string_gsub(Text, KEY_MOUSEWHEELUP, "MU")
	Text = string_gsub(Text, KEY_NUMPAD0, "N0")
	Text = string_gsub(Text, KEY_NUMPAD1, "N1")
	Text = string_gsub(Text, KEY_NUMPAD2, "N2")
	Text = string_gsub(Text, KEY_NUMPAD3, "N3")
	Text = string_gsub(Text, KEY_NUMPAD4, "N4")
	Text = string_gsub(Text, KEY_NUMPAD5, "N5")
	Text = string_gsub(Text, KEY_NUMPAD6, "N6")
	Text = string_gsub(Text, KEY_NUMPAD7, "N7")
	Text = string_gsub(Text, KEY_NUMPAD8, "N8")
	Text = string_gsub(Text, KEY_NUMPAD9, "N9")
	Text = string_gsub(Text, KEY_NUMPADDECIMAL, "N.")
	Text = string_gsub(Text, KEY_NUMPADDIVIDE, "N/")
	Text = string_gsub(Text, KEY_NUMPADMINUS, "N-")
	Text = string_gsub(Text, KEY_NUMPADMULTIPLY, "N*")
	Text = string_gsub(Text, KEY_NUMPADPLUS, "N+")
	Text = string_gsub(Text, KEY_PAGEDOWN, "PD")
	Text = string_gsub(Text, KEY_PAGEUP, "PU")
	Text = string_gsub(Text, KEY_SPACE, "Spc")

	if HotKey:GetText() == Indicator then
		HotKey:SetText("")
	else
		HotKey:SetText(Text)
	end
end

local function SetupFlyoutButton()
	for i = 1, FlyoutButtons do
		local Button = _G["SpellFlyoutButton"..i]

		if Button and not Button.IsSkinned then
			StyleNormalButton(Button)

			if Button:GetChecked() then
				Button:SetChecked(nil)
			end

			if Button:GetHeight() ~= C["ActionBar"].DefaultButtonSize and not InCombatLockdown() then
				Button:SetSize(C["ActionBar"].DefaultButtonSize, C["ActionBar"].DefaultButtonSize)
			end

			Button.IsSkinned = true
		end
	end
end

local function StyleFlyoutButton(self)
	if not self.FlyoutArrow then
		return
	end

	self.FlyoutArrow:SetDrawLayer("OVERLAY", 2)

	if self.FlyoutBorder then
		self.FlyoutBorder:SetAlpha(0)
		self.FlyoutBorderShadow:SetAlpha(0)
	end

	SpellFlyoutHorizontalBackground:SetAlpha(0)
	SpellFlyoutVerticalBackground:SetAlpha(0)
	SpellFlyoutBackgroundEnd:SetAlpha(0)

	for i = 1, GetNumFlyouts() do
		local ID = GetFlyoutID(i)
		local _, _, NumSlots, IsKnown = GetFlyoutInfo(ID)

		if IsKnown then
			FlyoutButtons = NumSlots
			break
		end
	end

	SetupFlyoutButton()
end

local CreatePetShiftSkin = CreateFrame("Frame")
CreatePetShiftSkin:RegisterEvent("PLAYER_LOGIN")
CreatePetShiftSkin:SetScript("OnEvent", function()
	SkinStanceButtons()
	SkinPetButtons()
end)

local function HideHighlightButton(self)
	if self.overlay then
		self.overlay:Hide()
		ActionButton_HideOverlayGlow(self)
	end
end

hooksecurefunc("ActionButton_Update", StyleNormalButton)
hooksecurefunc("ActionButton_UpdateFlyout", StyleFlyoutButton)
hooksecurefunc("SpellButton_OnClick", StyleFlyoutButton)
hooksecurefunc("ActionButton_UpdateHotkeys", K.UpdateHotkey)
hooksecurefunc("PetActionButton_SetHotkeys", K.UpdateHotkey)
if C["ActionBar"].HideHighlight then
	hooksecurefunc("ActionButton_ShowOverlayGlow", HideHighlightButton)
end