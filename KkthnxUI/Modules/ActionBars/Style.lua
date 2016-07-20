local K, C, L, _ = select(2, ...):unpack()
if C.ActionBar.Enable ~= true then return end

-- By Tukz
local _G = _G
local match = string.match
local gsub = string.gsub
local ipairs = ipairs
local tostring = tostring
local NUM_PET_ACTION_SLOTS = NUM_PET_ACTION_SLOTS
local hooksecurefunc = hooksecurefunc

local function StyleNormalButton(self)
	local name = self:GetName()
	if name:match("MultiCast") then return end
	local button = self
	local icon = _G[name.."Icon"]
	local count = _G[name.."Count"]
	local flash = _G[name.."Flash"]
	local hotkey = _G[name.."HotKey"]
	local border = _G[name.."Border"]
	local macroName = _G[name.."Name"]
	local normal = _G[name.."NormalTexture"]
	local float = _G[name.."FloatingBG"]

	flash:SetTexture("")
	button:SetNormalTexture("")

	if (float) then
		float:Kill()
	end

	count:ClearAllPoints()
	count:SetPoint("BOTTOMRIGHT", 0, 2)
	count:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)

	hotkey:ClearAllPoints()
	hotkey:SetPoint("TOPRIGHT", 0, -2)

	if macroName then
		if C.ActionBar.Macro == true then
			macroName:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
			macroName:ClearAllPoints()
			macroName:SetPoint("BOTTOM", 1, 1)
			macroName:SetVertexColor(1, 0.82, 0, 1)
		else
			macroName:SetText("")
			macroName:Kill()
		end
	end

	if hotkey then
		if C.ActionBar.Hotkey then
			hotkey:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
			hotkey.ClearAllPoints = K.Noop
			hotkey.SetPoint = K.Noop
		else
			hotkey:SetText("")
			hotkey:Kill()
		end
	end

	if not button.isSkinned then
		if self:GetHeight() ~= C.ActionBar.ButtonSize and not InCombatLockdown() then
			self:SetSize(C.ActionBar.ButtonSize, C.ActionBar.ButtonSize)
		end
		button:CreateBackdrop()
		button.backdrop:SetOutside()

		icon:SetTexCoord(unpack(K.TexCoords))
		icon:SetInside()
		icon:SetDrawLayer("BORDER", 7) -- ??

		button.isSkinned = true
	end

	if border and button.isSkinned then
		border:SetTexture("")
		if border:IsShown() and C.ActionBar.EquipBorder then
			button.backdrop:SetBackdropBorderColor(.08, .70, 0)
		else
			button.backdrop:SetBackdropBorderColor(unpack(C.Media.Border_Color))
		end
	end

	if not button.shadow and button.isSkinned then
		button:CreateBlizzShadow(5)
	end

	if normal then
		normal:ClearAllPoints()
		normal:SetPoint("TOPLEFT")
		normal:SetPoint("BOTTOMRIGHT")
	end
end

local function StyleSmallButton(normal, button, icon, name, pet)
	local flash = _G[name.."Flash"]
	button:SetNormalTexture("")
	button.SetNormalTexture = K.Noop

	flash:SetColorTexture(204/255, 204/255, 204/255, 0.5)
	flash:SetInside()

	if not button.isSkinned then
		button:SetSize(C.ActionBar.ButtonSize, C.ActionBar.ButtonSize)
		button:CreateBackdrop()
		button.backdrop:SetOutside()

		icon:SetTexCoord(unpack(K.TexCoords))
		icon:SetInside()
		icon:SetDrawLayer("BORDER", 7)

		if pet then
			local autocast = _G[name.."AutoCastable"]
			autocast:SetSize((C.ActionBar.ButtonSize * 2) - 10, (C.ActionBar.ButtonSize * 2) - 10)
			autocast:ClearAllPoints()
			autocast:SetPoint("CENTER", button, 0, 0)

			local shine = _G[name.."Shine"]
			shine:SetSize(C.ActionBar.ButtonSize, C.ActionBar.ButtonSize)

			local cooldown = _G[name.."Cooldown"]
			cooldown:SetSize(C.ActionBar.ButtonSize - 2, C.ActionBar.ButtonSize - 2)
		end

		button.isSkinned = true
	end

	if not button.shadow then
		button:CreateBlizzShadow(5)
	end

	if normal then
		normal:ClearAllPoints()
		normal:SetOutside()
	end
end

function K.StyleShift()
	for i = 1, NUM_STANCE_SLOTS do
		local name = "StanceButton"..i
		local button = _G[name]
		local icon = _G[name.."Icon"]
		local normal = _G[name.."NormalTexture"]
		StyleSmallButton(normal, button, icon, name)
	end
end

function K.StylePet()
	for i = 1, NUM_PET_ACTION_SLOTS do
		local name = "PetActionButton"..i
		local button = _G[name]
		local icon = _G[name.."Icon"]
		local normal = _G[name.."NormalTexture2"]
		StyleSmallButton(normal, button, icon, name, true)
	end
end

local function UpdateHotkey(self, actionButtonType)
	local hotkey = _G[self:GetName() .. "HotKey"]
	local text = hotkey:GetText()
	local indicator = _G["RANGE_INDICATOR"]

	if (not text) then
		return
	end

	text = gsub(text, "(s%-)", "S")
	text = gsub(text, "(a%-)", "A")
	text = gsub(text, "(c%-)", "C")
	text = gsub(text, KEY_MOUSEWHEELDOWN , "MDn")
    text = gsub(text, KEY_MOUSEWHEELUP , "MUp")
	text = gsub(text, KEY_BUTTON3, "M3")
	text = gsub(text, KEY_BUTTON4, "M4")
	text = gsub(text, KEY_BUTTON5, "M5")
	text = gsub(text, KEY_MOUSEWHEELUP, "MU")
	text = gsub(text, KEY_MOUSEWHEELDOWN, "MD")
	text = gsub(text, KEY_NUMPAD0, "N0")
    text = gsub(text, KEY_NUMPAD1, "N1")
    text = gsub(text, KEY_NUMPAD2, "N2")
    text = gsub(text, KEY_NUMPAD3, "N3")
    text = gsub(text, KEY_NUMPAD4, "N4")
    text = gsub(text, KEY_NUMPAD5, "N5")
    text = gsub(text, KEY_NUMPAD6, "N6")
    text = gsub(text, KEY_NUMPAD7, "N7")
    text = gsub(text, KEY_NUMPAD8, "N8")
    text = gsub(text, KEY_NUMPAD9, "N9")
    text = gsub(text, KEY_NUMPADDECIMAL, "N.")
    text = gsub(text, KEY_NUMPADDIVIDE, "N/")
    text = gsub(text, KEY_NUMPADMINUS, "N-")
    text = gsub(text, KEY_NUMPADMULTIPLY, "N*")
    text = gsub(text, KEY_NUMPADPLUS, "N+")
	text = gsub(text, KEY_PAGEUP, "PU")
	text = gsub(text, KEY_PAGEDOWN, "PD")
	text = gsub(text, KEY_SPACE, "SpB")
	text = gsub(text, KEY_INSERT, "Ins")
	text = gsub(text, KEY_HOME, "Hm")
	text = gsub(text, KEY_DELETE, "Del")
	text = gsub(text, KEY_INSERT_MAC, "Hlp") -- mac

	if hotkey:GetText() == indicator then
		hotkey:SetText("")
	else
		hotkey:SetText(text)
	end
end

-- Rescale cooldown spiral to fix texture
local buttonNames = {
	"ActionButton",
	"MultiBarBottomLeftButton",
	"MultiBarBottomRightButton",
	"MultiBarLeftButton",
	"MultiBarRightButton",
	"StanceButton",
	"PetActionButton",
	"MultiCastActionButton"
}

for _, name in ipairs(buttonNames) do
	for index = 1, 12 do
		local buttonName = name..tostring(index)
		local button = _G[buttonName]
		local cooldown = _G[buttonName.."Cooldown"]

		if (button == nil or cooldown == nil) then
			break
		end

		cooldown:ClearAllPoints()
		cooldown:SetInside()
	end
end

do
	for i = 1, 12 do
		_G["ActionButton"..i]:StyleButton(true)
		_G["MultiBarBottomLeftButton"..i]:StyleButton(true)
		_G["MultiBarBottomRightButton"..i]:StyleButton(true)
		_G["MultiBarLeftButton"..i]:StyleButton(true)
		_G["MultiBarRightButton"..i]:StyleButton(true)
	end

	for i = 1, 10 do
		_G["StanceButton"..i]:StyleButton(true)
		_G["PetActionButton"..i]:StyleButton(true)
	end
end

hooksecurefunc("ActionButton_Update", StyleNormalButton)
if C.ActionBar.Hotkey == true then
	hooksecurefunc("ActionButton_OnEvent", function(self, event, ...) if event == "PLAYER_ENTERING_WORLD" then ActionButton_UpdateHotkeys(self, self.buttonType) end end)
	hooksecurefunc("ActionButton_UpdateHotkeys", UpdateHotkey)
end