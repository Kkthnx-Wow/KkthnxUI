local K, C = unpack(select(2, ...))
local Module = K:GetModule("Blizzard")

local _G = _G
local floor = _G.floor
local gsub = _G.gsub
local strjoin = _G.strjoin
local strlen = _G.strlen
local strsub = _G.strsub
local tonumber = _G.tonumber
local wipe = _G.wipe

local CALENDAR_COPY_EVENT = _G.CALENDAR_COPY_EVENT
local CALENDAR_PASTE_EVENT = _G.CALENDAR_PASTE_EVENT
local CLASS = _G.CLASS
local CreateFrame = _G.CreateFrame
local DEFAULT = _G.DEFAULT
local IsAddOnLoaded = _G.IsAddOnLoaded
local IsControlKeyDown = _G.IsControlKeyDown
local IsModifierKeyDown = _G.IsModifierKeyDown

local colorBuffer = {}
local function alphaValue(num)
	return num and floor(((1 - num) * 100) + 0.05) or 0
end

local function UpdateAlphaText(alpha)
	if not alpha then
		alpha = alphaValue(_G.OpacitySliderFrame:GetValue())
	end

	_G.ColorPPBoxA:SetText(alpha)
end

local function UpdateAlpha(tbox)
	local num = tbox:GetNumber()
	if num > 100 then
		tbox:SetText(100)
		num = 100
	end

	_G.OpacitySliderFrame:SetValue(1 - (num / 100))
end

local function expandFromThree(r, g, b)
	return strjoin("", r, r, g, g, b, b)
end

local function extendToSix(str)
	for _=1, 6-strlen(str) do
		str=str..0
	end

	return str
end

local function GetHexColor(box)
	local rgb, rgbSize = box:GetText(), box:GetNumLetters()
	if rgbSize == 3 then
		rgb = gsub(rgb, "(%x)(%x)(%x)$", expandFromThree)
	elseif rgbSize < 6 then
		rgb = gsub(rgb, "(.+)$", extendToSix)
	end

	local r, g, b = tonumber(strsub(rgb, 0, 2), 16) or 0, tonumber(strsub(rgb, 3, 4), 16) or 0, tonumber(strsub(rgb, 5, 6), 16) or 0

	return r / 255, g / 255, b / 255
end

local function UpdateColorTexts(r, g, b, box)
	if not (r and g and b) then
		r, g, b = _G.ColorPickerFrame:GetColorRGB()

		if box then
			if box == _G.ColorPPBoxH then
				r, g, b = GetHexColor(box)
			else
				local num = box:GetNumber()
				if num > 255 then
					num = 255
				end

				local c = num/255
				if box == _G.ColorPPBoxR then
					r = c
				elseif box == _G.ColorPPBoxG then
					g = c
				elseif box == _G.ColorPPBoxB then
					b = c
				end
			end
		end
	end

	-- we want those /255 values
	r, g, b = r * 255, g * 255, b * 255

	_G.ColorPPBoxH:SetText(("%.2x%.2x%.2x"):format(r, g, b))
	_G.ColorPPBoxR:SetText(r)
	_G.ColorPPBoxG:SetText(g)
	_G.ColorPPBoxB:SetText(b)
end

local function UpdateColor()
	local r, g, b = GetHexColor(_G.ColorPPBoxH)
	_G.ColorPickerFrame:SetColorRGB(r, g, b)
	_G.ColorSwatch:SetColorTexture(r, g, b)
end

local function ColorPPBoxA_SetFocus()
	_G.ColorPPBoxA:SetFocus()
end

local function ColorPPBoxR_SetFocus()
	_G.ColorPPBoxR:SetFocus()
end

local delayWait, delayFunc = 0.15
local function delayCall()
	if delayFunc then
		delayFunc()
		delayFunc = nil
	end
end
local function onColorSelect(frame, r, g, b)
	if frame.noColorCallback then
		return
	end

	_G.ColorSwatch:SetColorTexture(r, g, b)
	UpdateColorTexts(r, g, b)

	if r == 0 and g == 0 and b == 0 then
		return
	end

	if not frame:IsVisible() then
		delayCall()
	elseif not delayFunc then
		delayFunc = _G.ColorPickerFrame.func
		C_Timer.After(delayWait, delayCall)
	end
end

local function onValueChanged(frame, value)
	local alpha = alphaValue(value)
	if frame.lastAlpha ~= alpha then
		frame.lastAlpha = alpha

		UpdateAlphaText(alpha)

		if not _G.ColorPickerFrame:IsVisible() then
			delayCall()
		else
			local opacityFunc = _G.ColorPickerFrame.opacityFunc
			if delayFunc and (delayFunc ~= opacityFunc) then
				delayFunc = opacityFunc
			elseif not delayFunc then
				delayFunc = opacityFunc
				C_Timer.After(delayWait, delayCall)
			end
		end
	end
end

function Module:CreateColorPicker()
	if IsAddOnLoaded("ColorPickerPlus") or C["Misc"].ColorPicker ~= true then
		return
	end

	-- Skin the default frame, move default buttons into place
	_G.ColorPickerFrame:SetClampedToScreen(true)
	_G.ColorPickerFrame:CreateBorder()
	_G.ColorPickerFrame.Border:Hide()

	_G.ColorPickerFrame.Header:StripTextures()
	_G.ColorPickerFrame.Header:ClearAllPoints()
	_G.ColorPickerFrame.Header:SetPoint('TOP', _G.ColorPickerFrame, 0, 8)

	_G.ColorPickerCancelButton:ClearAllPoints()
	_G.ColorPickerOkayButton:ClearAllPoints()
	_G.ColorPickerCancelButton:SetPoint("BOTTOMRIGHT", _G.ColorPickerFrame, "BOTTOMRIGHT", -14, 14)
	_G.ColorPickerCancelButton:SetPoint("BOTTOMLEFT", _G.ColorPickerFrame, "BOTTOM", 0, 14)
	_G.ColorPickerOkayButton:SetPoint("BOTTOMLEFT", _G.ColorPickerFrame,"BOTTOMLEFT", 14, 14)
	_G.ColorPickerOkayButton:SetPoint("RIGHT", _G.ColorPickerCancelButton,"LEFT", -6, 0)

	--S:HandleSliderFrame(_G.OpacitySliderFrame)
	ColorPickerOkayButton:SkinButton()
	ColorPickerCancelButton:SkinButton()

	_G.ColorPickerFrame:HookScript("OnShow", function(frame)
		-- get color that will be replaced
		local r, g, b = frame:GetColorRGB()
		_G.ColorPPOldColorSwatch:SetColorTexture(r, g, b)

		-- show/hide the alpha box
		if frame.hasOpacity then
			_G.ColorPPBoxA:Show()
			_G.ColorPPBoxLabelA:Show()
			_G.ColorPPBoxH:SetScript("OnTabPressed", ColorPPBoxA_SetFocus)
			UpdateAlphaText()
			UpdateColorTexts()
			frame:SetWidth(405)
		else
			_G.ColorPPBoxA:Hide()
			_G.ColorPPBoxLabelA:Hide()
			_G.ColorPPBoxH:SetScript("OnTabPressed", ColorPPBoxR_SetFocus)
			UpdateColorTexts()
			frame:SetWidth(345)
		end

		-- Memory Fix, Colorpicker will call the self.func() 100x per second, causing fps/memory issues,
		-- We overwrite these two scripts and set a limit on how often we allow a call their update functions
		_G.OpacitySliderFrame:SetScript("OnValueChanged", onValueChanged)
		frame:SetScript("OnColorSelect", onColorSelect)
	end)

	-- make the Color Picker dialog a bit taller, to make room for edit boxes
	_G.ColorPickerFrame:SetHeight(_G.ColorPickerFrame:GetHeight() + 40)

	-- move the Color Swatch
	_G.ColorSwatch:ClearAllPoints()
	_G.ColorSwatch:SetPoint("TOPLEFT", _G.ColorPickerFrame, "TOPLEFT", 215, -45)

	-- add Color Swatch for original color
	local t = _G.ColorPickerFrame:CreateTexture("ColorPPOldColorSwatch")
	local w, h = _G.ColorSwatch:GetSize()
	t:SetSize(w * 0.75, h * 0.75)
	t:SetColorTexture(0, 0, 0)
	-- OldColorSwatch to appear beneath ColorSwatch
	t:SetDrawLayer("BORDER")
	t:SetPoint("BOTTOMLEFT", "ColorSwatch", "TOPRIGHT", -(w / 2), -(h / 3))

	-- add Color Swatch for the copied color
	t = _G.ColorPickerFrame:CreateTexture("ColorPPCopyColorSwatch")
	t:SetColorTexture(0,0,0)
	t:SetSize(w, h)
	t:Hide()

	-- add copy button to the _G.ColorPickerFrame
	local b = CreateFrame("Button", "ColorPPCopy", _G.ColorPickerFrame, "UIPanelButtonTemplate")
	b:SkinButton()
	b:SetText(CALENDAR_COPY_EVENT)
	b:SetWidth(58)
	b:SetHeight(22)
	b:SetPoint("TOPLEFT", "ColorSwatch", "BOTTOMLEFT", -6, -20)

	-- copy color into buffer on button click
	b:SetScript("OnClick", function()
		-- copy current dialog colors into buffer
		colorBuffer.r, colorBuffer.g, colorBuffer.b = _G.ColorPickerFrame:GetColorRGB()

		-- enable Paste button and display copied color into swatch
		_G.ColorPPPaste:Enable()
		_G.ColorPPCopyColorSwatch:SetColorTexture(colorBuffer.r, colorBuffer.g, colorBuffer.b)
		_G.ColorPPCopyColorSwatch:Show()

		colorBuffer.a = (_G.ColorPickerFrame.hasOpacity and _G.OpacitySliderFrame:GetValue()) or nil
	end)

	--class color button
	-- b = CreateFrame("Button", "ColorPPClass", _G.ColorPickerFrame, "UIPanelButtonTemplate")
	-- b:SetText(CLASS)
	-- b:SkinButton()
	-- b:SetWidth(80)
	-- b:SetHeight(22)
	-- b:SetPoint("TOP", "ColorPPCopy", "BOTTOMRIGHT", 0, -7)

	-- b:SetScript("OnClick", function()
	-- 	_G.ColorPickerFrame:SetColorRGB(K.r, K.g, K.b)
	-- 	_G.ColorSwatch:SetColorTexture(K.r, K.g, K.b)
	-- 	if _G.ColorPickerFrame.hasOpacity then
	-- 		_G.OpacitySliderFrame:SetValue(0)
	-- 	end
	-- end)

	-- class color buttons
	local ClassIconsTexture = "|TInterface\\WorldStateFrame\\Icons-Classes:22:22:0:0:256:256:"
	local CITS = _G.CLASS_ICON_TCOORDS
	local ColorPPWidth = _G.ColorPickerFrame:GetWidth()

	b = CreateFrame("Button", "ColorPPHunterClass", _G.ColorPickerFrame, "UIPanelButtonTemplate")
	b:SetText(ClassIconsTexture..tostring(CITS["HUNTER"][1]*256)..":"..tostring(CITS["HUNTER"][2]*256)..":"..tostring(CITS["HUNTER"][3]*256)..":"..tostring(CITS["HUNTER"][4]*256).."|t")
	b:SkinButton()
	b:SetWidth(ColorPPWidth / 15.7)
	b:SetHeight(ColorPPWidth / 15.7)
	b:SetPoint("BOTTOMRIGHT", _G.ColorPickerFrame, "TOPRIGHT", 0, 6)

	b:SetScript("OnClick", function()
		_G.ColorPickerFrame:SetColorRGB(0.67, 0.84, 0.45)
		_G.ColorSwatch:SetColorTexture(0.67, 0.84, 0.45)
		if _G.ColorPickerFrame.hasOpacity then
			_G.OpacitySliderFrame:SetValue(0)
		end
	end)

	b = CreateFrame("Button", "ColorPPDemonHunterClass", _G.ColorPickerFrame, "UIPanelButtonTemplate")
	b:SetText(ClassIconsTexture..tostring(CITS["DEMONHUNTER"][1]*256)..":"..tostring(CITS["DEMONHUNTER"][2]*256)..":"..tostring(CITS["DEMONHUNTER"][3]*256)..":"..tostring(CITS["DEMONHUNTER"][4]*256).."|t")
	b:SkinButton()
	b:SetWidth(ColorPPWidth / 15.7)
	b:SetHeight(ColorPPWidth / 15.7)
	b:SetPoint("RIGHT", "ColorPPHunterClass", "LEFT", -6, 0)

	b:SetScript("OnClick", function()
		_G.ColorPickerFrame:SetColorRGB(0.64, 0.19, 0.79)
		_G.ColorSwatch:SetColorTexture(0.64, 0.19, 0.79)
		if _G.ColorPickerFrame.hasOpacity then
			_G.OpacitySliderFrame:SetValue(0)
		end
	end)

	b = CreateFrame("Button", "ColorPPMonkClass", _G.ColorPickerFrame, "UIPanelButtonTemplate")
	b:SetText(ClassIconsTexture..tostring(CITS["MONK"][1]*256)..":"..tostring(CITS["MONK"][2]*256)..":"..tostring(CITS["MONK"][3]*256)..":"..tostring(CITS["MONK"][4]*256).."|t")
	b:SkinButton()
	b:SetWidth(ColorPPWidth / 15.7)
	b:SetHeight(ColorPPWidth / 15.7)
	b:SetPoint("RIGHT", "ColorPPDemonHunterClass", "LEFT", -6, 0)

	b:SetScript("OnClick", function()
		_G.ColorPickerFrame:SetColorRGB(0.00, 1.00, 0.59)
		_G.ColorSwatch:SetColorTexture(0.00, 1.00, 0.59)
		if _G.ColorPickerFrame.hasOpacity then
			_G.OpacitySliderFrame:SetValue(0)
		end
	end)

	b = CreateFrame("Button", "ColorPPPriestClass", _G.ColorPickerFrame, "UIPanelButtonTemplate")
	b:SetText(ClassIconsTexture..tostring(CITS["PRIEST"][1]*256)..":"..tostring(CITS["PRIEST"][2]*256)..":"..tostring(CITS["PRIEST"][3]*256)..":"..tostring(CITS["PRIEST"][4]*256).."|t")
	b:SkinButton()
	b:SetWidth(ColorPPWidth / 15.7)
	b:SetHeight(ColorPPWidth / 15.7)
	b:SetPoint("RIGHT", "ColorPPMonkClass", "LEFT", -6, 0)

	b:SetScript("OnClick", function()
		_G.ColorPickerFrame:SetColorRGB(0.86, 0.92, 0.98)
		_G.ColorSwatch:SetColorTexture(0.86, 0.92, 0.98)
		if _G.ColorPickerFrame.hasOpacity then
			_G.OpacitySliderFrame:SetValue(0)
		end
	end)

	b = CreateFrame("Button", "ColorPPWarlockClass", _G.ColorPickerFrame, "UIPanelButtonTemplate")
	b:SetText(ClassIconsTexture..tostring(CITS["WARLOCK"][1]*256)..":"..tostring(CITS["WARLOCK"][2]*256)..":"..tostring(CITS["WARLOCK"][3]*256)..":"..tostring(CITS["WARLOCK"][4]*256).."|t")
	b:SkinButton()
	b:SetWidth(ColorPPWidth / 15.7)
	b:SetHeight(ColorPPWidth / 15.7)
	b:SetPoint("RIGHT", "ColorPPPriestClass", "LEFT", -6, 0)

	b:SetScript("OnClick", function()
		_G.ColorPickerFrame:SetColorRGB(0.58, 0.51, 0.79)
		_G.ColorSwatch:SetColorTexture(0.58, 0.51, 0.79)
		if _G.ColorPickerFrame.hasOpacity then
			_G.OpacitySliderFrame:SetValue(0)
		end
	end)

	b = CreateFrame("Button", "ColorPPDeathknightClass", _G.ColorPickerFrame, "UIPanelButtonTemplate")
	b:SetText(ClassIconsTexture..tostring(CITS["DEATHKNIGHT"][1]*256)..":"..tostring(CITS["DEATHKNIGHT"][2]*256)..":"..tostring(CITS["DEATHKNIGHT"][3]*256)..":"..tostring(CITS["DEATHKNIGHT"][4]*256).."|t")
	b:SkinButton()
	b:SetWidth(ColorPPWidth / 15.7)
	b:SetHeight(ColorPPWidth / 15.7)
	b:SetPoint("RIGHT", "ColorPPWarlockClass", "LEFT", -6, 0)

	b:SetScript("OnClick", function()
		_G.ColorPickerFrame:SetColorRGB(0.77, 0.12, 0.24)
		_G.ColorSwatch:SetColorTexture(0.77, 0.12, 0.24)
		if _G.ColorPickerFrame.hasOpacity then
			_G.OpacitySliderFrame:SetValue(0)
		end
	end)

	b = CreateFrame("Button", "ColorPPDruidClass", _G.ColorPickerFrame, "UIPanelButtonTemplate")
	b:SetText(ClassIconsTexture..tostring(CITS["DRUID"][1]*256)..":"..tostring(CITS["DRUID"][2]*256)..":"..tostring(CITS["DRUID"][3]*256)..":"..tostring(CITS["DRUID"][4]*256).."|t")
	b:SkinButton()
	b:SetWidth(ColorPPWidth / 15.7)
	b:SetHeight(ColorPPWidth / 15.7)
	b:SetPoint("RIGHT", "ColorPPDeathknightClass", "LEFT", -6, 0)

	b:SetScript("OnClick", function()
		_G.ColorPickerFrame:SetColorRGB(1.00, 0.49, 0.03)
		_G.ColorSwatch:SetColorTexture(1.00, 0.49, 0.03)
		if _G.ColorPickerFrame.hasOpacity then
			_G.OpacitySliderFrame:SetValue(0)
		end
	end)

	b = CreateFrame("Button", "ColorPPMageClass", _G.ColorPickerFrame, "UIPanelButtonTemplate")
	b:SetText(ClassIconsTexture..tostring(CITS["MAGE"][1]*256)..":"..tostring(CITS["MAGE"][2]*256)..":"..tostring(CITS["MAGE"][3]*256)..":"..tostring(CITS["MAGE"][4]*256).."|t")
	b:SkinButton()
	b:SetWidth(ColorPPWidth / 15.7)
	b:SetHeight(ColorPPWidth / 15.7)
	b:SetPoint("RIGHT", "ColorPPDruidClass", "LEFT", -6, 0)

	b:SetScript("OnClick", function()
		_G.ColorPickerFrame:SetColorRGB(0.41, 0.80, 1.00)
		_G.ColorSwatch:SetColorTexture(0.41, 0.80, 1.00)
		if _G.ColorPickerFrame.hasOpacity then
			_G.OpacitySliderFrame:SetValue(0)
		end
	end)

	b = CreateFrame("Button", "ColorPPPaladinClass", _G.ColorPickerFrame, "UIPanelButtonTemplate")
	b:SetText(ClassIconsTexture..tostring(CITS["PALADIN"][1]*256)..":"..tostring(CITS["PALADIN"][2]*256)..":"..tostring(CITS["PALADIN"][3]*256)..":"..tostring(CITS["PALADIN"][4]*256).."|t")
	b:SkinButton()
	b:SetWidth(ColorPPWidth / 15.7)
	b:SetHeight(ColorPPWidth / 15.7)
	b:SetPoint("RIGHT", "ColorPPMageClass", "LEFT", -6, 0)

	b:SetScript("OnClick", function()
		_G.ColorPickerFrame:SetColorRGB(0.96, 0.55, 0.73)
		_G.ColorSwatch:SetColorTexture(0.96, 0.55, 0.73)
		if _G.ColorPickerFrame.hasOpacity then
			_G.OpacitySliderFrame:SetValue(0)
		end
	end)

	b = CreateFrame("Button", "ColorPPRogueClass", _G.ColorPickerFrame, "UIPanelButtonTemplate")
	b:SetText(ClassIconsTexture..tostring(CITS["ROGUE"][1]*256)..":"..tostring(CITS["ROGUE"][2]*256)..":"..tostring(CITS["ROGUE"][3]*256)..":"..tostring(CITS["ROGUE"][4]*256).."|t")
	b:SkinButton()
	b:SetWidth(ColorPPWidth / 15.7)
	b:SetHeight(ColorPPWidth / 15.7)
	b:SetPoint("RIGHT", "ColorPPPaladinClass", "LEFT", -6, 0)

	b:SetScript("OnClick", function()
		_G.ColorPickerFrame:SetColorRGB(1.00, 0.95, 0.32)
		_G.ColorSwatch:SetColorTexture(1.00, 0.95, 0.32)
		if _G.ColorPickerFrame.hasOpacity then
			_G.OpacitySliderFrame:SetValue(0)
		end
	end)

	b = CreateFrame("Button", "ColorPPShamanClass", _G.ColorPickerFrame, "UIPanelButtonTemplate")
	b:SetText(ClassIconsTexture..tostring(CITS["SHAMAN"][1]*256)..":"..tostring(CITS["SHAMAN"][2]*256)..":"..tostring(CITS["SHAMAN"][3]*256)..":"..tostring(CITS["SHAMAN"][4]*256).."|t")
	b:SkinButton()
	b:SetWidth(ColorPPWidth / 15.7)
	b:SetHeight(ColorPPWidth / 15.7)
	b:SetPoint("RIGHT", "ColorPPRogueClass", "LEFT", -6, 0)

	b:SetScript("OnClick", function()
		_G.ColorPickerFrame:SetColorRGB(0.16, 0.31, 0.61)
		_G.ColorSwatch:SetColorTexture(0.16, 0.31, 0.61)
		if _G.ColorPickerFrame.hasOpacity then
			_G.OpacitySliderFrame:SetValue(0)
		end
	end)

	b = CreateFrame("Button", "ColorPPWarriorClass", _G.ColorPickerFrame, "UIPanelButtonTemplate")
	b:SetText(ClassIconsTexture..tostring(CITS["WARRIOR"][1]*256)..":"..tostring(CITS["WARRIOR"][2]*256)..":"..tostring(CITS["WARRIOR"][3]*256)..":"..tostring(CITS["WARRIOR"][4]*256).."|t")
	b:SkinButton()
	b:SetWidth(ColorPPWidth / 15.7)
	b:SetHeight(ColorPPWidth / 15.7)
	b:SetPoint("RIGHT", "ColorPPShamanClass", "LEFT", -6, 0)

	b:SetScript("OnClick", function()
		_G.ColorPickerFrame:SetColorRGB(0.78, 0.61, 0.43)
		_G.ColorSwatch:SetColorTexture(0.78, 0.61, 0.43)
		if _G.ColorPickerFrame.hasOpacity then
			_G.OpacitySliderFrame:SetValue(0)
		end
	end)

	-- add paste button to the _G.ColorPickerFrame
	b = CreateFrame("Button", "ColorPPPaste", _G.ColorPickerFrame, "UIPanelButtonTemplate")
	b:SetText(CALENDAR_PASTE_EVENT)
	b:SkinButton()
	b:SetWidth(58)
	b:SetHeight(22)
	b:SetPoint("TOPLEFT", "ColorPPCopy", "TOPRIGHT", 6, 0)
	b:Disable() -- enable when something has been copied

	-- paste color on button click, updating frame components
	b:SetScript("OnClick", function()
		_G.ColorPickerFrame:SetColorRGB(colorBuffer.r, colorBuffer.g, colorBuffer.b)
		_G.ColorSwatch:SetColorTexture(colorBuffer.r, colorBuffer.g, colorBuffer.b)
		if _G.ColorPickerFrame.hasOpacity then
			if colorBuffer.a then --color copied had an alpha value
				_G.OpacitySliderFrame:SetValue(colorBuffer.a)
			end
		end
	end)

	-- add defaults button to the _G.ColorPickerFrame
	b = CreateFrame("Button", "ColorPPDefault", _G.ColorPickerFrame, "UIPanelButtonTemplate")
	b:SetText(DEFAULT)
	b:SkinButton()
	b:SetWidth(80)
	b:SetHeight(22)
	b:SetPoint("TOP", "ColorPPCopy", "BOTTOMRIGHT", 0, -10)
	b:Disable() -- enable when something has been copied
	b:SetScript("OnHide", function(btn)
		if btn.colors then
			wipe(btn.colors)
		end
	end)

	b:SetScript("OnShow", function(btn)
		if btn.colors then
			btn:Enable()
		else
			btn:Disable()
		end
	end)

	-- paste color on button click, updating frame components
	b:SetScript("OnClick", function(btn)
		local colors = btn.colors
		_G.ColorPickerFrame:SetColorRGB(colors.r, colors.g, colors.b)
		_G.ColorSwatch:SetColorTexture(colors.r, colors.g, colors.b)
		if _G.ColorPickerFrame.hasOpacity then
			if colors.a then
				_G.OpacitySliderFrame:SetValue(colors.a)
			end
		end
	end)

	-- position Color Swatch for copy color
	_G.ColorPPCopyColorSwatch:SetPoint("BOTTOM", "ColorPPPaste", "TOP", 0, 10)

	-- move the Opacity Slider Frame to align with bottom of Copy ColorSwatch
	_G.OpacitySliderFrame:ClearAllPoints()
	_G.OpacitySliderFrame:SetPoint("BOTTOM", "ColorPPDefault", "BOTTOM", 0, 0)
	_G.OpacitySliderFrame:SetPoint("RIGHT", "ColorPickerFrame", "RIGHT", -35, 18)

	-- set up edit box frames and interior label and text areas
	local boxes = {"R", "G", "B", "H", "A"}
	for i = 1, #boxes do
		local rgb = boxes[i]
		local box = CreateFrame("EditBox", "ColorPPBox"..rgb, _G.ColorPickerFrame, "InputBoxTemplate")
		box:SetPoint("TOP", "ColorPickerWheel", "BOTTOM", 0, -15)
		box:SetFrameStrata("DIALOG")
		box:SetAutoFocus(false)
		box:SetTextInsets(0, 7, 0, 0)
		box:SetJustifyH("RIGHT")
		box:SetHeight(24)
		box:SetID(i)
		box:StripTextures(2)
		box:CreateBackdrop()
		box.Backdrop:SetPoint("TOPLEFT", box, "TOPLEFT", 4, -4)
		box.Backdrop:SetPoint("BOTTOMRIGHT", box, "BOTTOMRIGHT", -3, 4)

		-- hex entry box
		if i == 4 then
			box:SetMaxLetters(6)
			box:SetWidth(56)
			box:SetNumeric(false)
		else
			box:SetMaxLetters(3)
			box:SetWidth(40)
			box:SetNumeric(true)
		end

		-- label
		local label = box:CreateFontString("ColorPPBoxLabel"..rgb, "ARTWORK", "GameFontNormalSmall")
		label:SetPoint("RIGHT", "ColorPPBox"..rgb, "LEFT", 0, 0)
		label:SetText(i == 4 and "#" or rgb)
		label:SetTextColor(1, 1, 1)

		-- set up scripts to handle event appropriately
		if i == 5 then
			box:SetScript("OnKeyUp", function(eb, key)
				local copyPaste = IsControlKeyDown() and key == "V"
				if key == "BACKSPACE" or copyPaste or (strlen(key) == 1 and not IsModifierKeyDown()) then
					UpdateAlpha(eb)
				elseif key == "ENTER" or key == "ESCAPE" then
					eb:ClearFocus()
					UpdateAlpha(eb)
				end
			end)
		else
			box:SetScript("OnKeyUp", function(eb, key)
				local copyPaste = IsControlKeyDown() and key == "V"
				if key == "BACKSPACE" or copyPaste or (strlen(key) == 1 and not IsModifierKeyDown()) then
					if i ~= 4 then
						UpdateColorTexts(nil, nil, nil, eb)
					end

					if i == 4 and eb:GetNumLetters() ~= 6 then
						return
					end
					UpdateColor()
				elseif key == "ENTER" or key == "ESCAPE" then
					eb:ClearFocus()
					UpdateColorTexts(nil, nil, nil, eb)
					UpdateColor()
				end
			end)
		end

		box:SetScript("OnEditFocusGained", function(eb)
			eb:SetCursorPosition(0)
			eb:HighlightText()
		end)

		box:SetScript("OnEditFocusLost", function(eb)
			eb:HighlightText(0, 0)
		end)

		box:Show()
	end

	-- finish up with placement
	_G.ColorPPBoxA:SetPoint("RIGHT", "OpacitySliderFrame", "RIGHT", 10, 0)
	_G.ColorPPBoxH:SetPoint("RIGHT", "ColorPPDefault", "RIGHT", -10, 0)
	_G.ColorPPBoxB:SetPoint("RIGHT", "ColorPPDefault", "LEFT", -40, 0)
	_G.ColorPPBoxG:SetPoint("RIGHT", "ColorPPBoxB", "LEFT", -25, 0)
	_G.ColorPPBoxR:SetPoint("RIGHT", "ColorPPBoxG", "LEFT", -25, 0)

	-- define the order of tab cursor movement
	_G.ColorPPBoxR:SetScript("OnTabPressed", function()
		_G.ColorPPBoxG:SetFocus()
	end)

	_G.ColorPPBoxG:SetScript("OnTabPressed", function()
		_G.ColorPPBoxB:SetFocus()
	end)

	_G.ColorPPBoxB:SetScript("OnTabPressed", function()
		_G.ColorPPBoxH:SetFocus()
	end)

	_G.ColorPPBoxA:SetScript("OnTabPressed", function()
		_G.ColorPPBoxR:SetFocus()
	end)

	-- make the color picker movable.
	local mover = CreateFrame("Frame", nil, _G.ColorPickerFrame)
	mover:SetPoint("TOPLEFT", _G.ColorPickerFrame, "TOP", -60, 0)
	mover:SetPoint("BOTTOMRIGHT", _G.ColorPickerFrame, "TOP", 60, -15)

	mover:SetScript("OnMouseDown", function()
		_G.ColorPickerFrame:StartMoving()
	end)

	mover:SetScript("OnMouseUp", function()
		_G.ColorPickerFrame:StopMovingOrSizing()
	end)

	mover:EnableMouse(true)

	_G.ColorPickerFrame:SetUserPlaced(true)
	_G.ColorPickerFrame:EnableKeyboard(false)
end