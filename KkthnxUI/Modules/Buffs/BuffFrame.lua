local K, C, L, _ = select(2, ...):unpack()
if C.Aura.Enable ~= true then return end

local mainhand, _, _, offhand = GetWeaponEnchantInfo()
local rowbuffs
if K.ScreenWidth <= 1440 then
	rowbuffs = 12
else
	rowbuffs = 16
end

local GetFormattedTime = function(s)
	if s >= 86400 then
		return format("%dd", floor(s/86400 + 0.5))
	elseif s >= 3600 then
		return format("%dh", floor(s/3600 + 0.5))
	elseif s >= 60 then
		return format("%dm", floor(s/60 + 0.5))
	end
	return floor(s + 0.5)
end

local BuffsAnchor = CreateFrame("Frame", "BuffsAnchor", UIParent)
BuffsAnchor:SetPoint(unpack(C.Position.PlayerBuffs))
BuffsAnchor:SetSize((15 * C.Aura.BuffSize) + 42, (C.Aura.BuffSize * 2) + 3)

for i = 1, 2 do
	local f = CreateFrame("Frame", nil, _G["TempEnchant"..i])
	f:CreatePanel("CreateBackdrop", C.Aura.BuffSize, C.Aura.BuffSize, "CENTER", _G["TempEnchant"..i], "CENTER", 0, 0)
	if C.Aura.ClassColorBorder == true then
		f.backdrop:SetBackdropBorderColor(K.Color.r, K.Color.g, K.Color.b)
	end

	if not f.shadow then
		f:CreateBlizzShadow(5)
	end

    _G["TempEnchant"..i.."Border"]:ClearAllPoints()
    _G["TempEnchant"..i.."Border"]:SetPoint("TOPRIGHT", _G["TempEnchant"..i], 1, 1)
    _G["TempEnchant"..i.."Border"]:SetPoint("BOTTOMLEFT", _G["TempEnchant"..i], -1, -1)
    _G["TempEnchant"..i.."Border"]:SetTexCoord(0, 1, 0, 1)
    _G["TempEnchant"..i.."Border"]:SetVertexColor(1, 1, 1)

	_G["TempEnchant2"]:ClearAllPoints()
	_G["TempEnchant2"]:SetPoint("RIGHT", _G["TempEnchant1"], "LEFT", -3, 0)

	_G["TempEnchant"..i.."Icon"]:SetTexCoord(0.1, 0.9, 0.1, 0.9)
	_G["TempEnchant"..i.."Icon"]:SetPoint("TOPLEFT", _G["TempEnchant"..i], 2, -2)
	_G["TempEnchant"..i.."Icon"]:SetPoint("BOTTOMRIGHT", _G["TempEnchant"..i], -2, 2)

	_G["TempEnchant"..i]:SetSize(C.Aura.BuffSize, C.Aura.BuffSize)

	_G["TempEnchant"..i.."Duration"]:ClearAllPoints()
	_G["TempEnchant"..i.."Duration"]:SetPoint("CENTER", 2, 1)
	_G["TempEnchant"..i.."Duration"]:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
	_G["TempEnchant"..i.."Duration"]:SetShadowOffset(0, 0)
end

local function StyleBuffs(buttonName, index, debuff)
	local buff = _G[buttonName..index]
	local icon = _G[buttonName..index.."Icon"]
	local border = _G[buttonName..index.."Border"]
	local duration = _G[buttonName..index.."Duration"]
	local count = _G[buttonName..index.."Count"]
	if icon and not _G[buttonName..index.."Panel"] then
		icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
		icon:SetPoint("TOPLEFT", buff, 2, -2)
		icon:SetPoint("BOTTOMRIGHT", buff, -2, 2)

		buff:SetSize(C.Aura.BuffSize, C.Aura.BuffSize)

		duration:ClearAllPoints()
		duration:SetPoint("CENTER", 2, 1)
		duration:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
		duration:SetShadowOffset(0, 0)

		count:ClearAllPoints()
		count:SetPoint("BOTTOMRIGHT", 0, 1)
		count:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
		count:SetShadowOffset(0, 0)

		local panel = CreateFrame("Frame", buttonName..index.."Panel", buff)
		panel:CreatePanel("CreateBackdrop", C.Aura.BuffSize, C.Aura.BuffSize, "CENTER", buff, "CENTER", 0, 0)
		if C.Aura.ClassColorBorder == true then
			panel.backdrop:SetBackdropBorderColor(K.Color.r, K.Color.g, K.Color.b)
		end
		panel:SetFrameLevel(buff:GetFrameLevel() - 1)
		panel:SetFrameStrata(buff:GetFrameStrata())

		if not panel.shadow then
			panel:CreateBlizzShadow(5)
		end
	end
	if border then border:Hide() end
end

function UpdateFlash(self, elapsed)
	local index = self:GetID()
	self:SetAlpha(1)
end

local UpdateDuration = function(auraButton, timeLeft)
	local duration = auraButton.duration
	if SHOW_BUFF_DURATIONS == "1" and timeLeft then
		duration:SetFormattedText(GetFormattedTime(timeLeft))
		duration:Show()
	else
		duration:Hide()
	end
end

local function UpdateBuffAnchors()
	local buttonName = "BuffButton"
	local buff, previousBuff, aboveBuff
	local numBuffs = 0
	local slack = BuffFrame.numEnchants
	local mainhand, _, _, offhand = GetWeaponEnchantInfo()

	for index = 1, BUFF_ACTUAL_DISPLAY do
		StyleBuffs(buttonName, index, false)
		local buff = _G[buttonName..index]

		if not buff.consolidated then
			numBuffs = numBuffs + 1
			index = numBuffs + slack
			buff:ClearAllPoints()
			if (index > 1) and (mod(index, rowbuffs) == 1) then
				if index == rowbuffs + 1 then
					buff:SetPoint("TOP", ConsolidatedBuffs, "BOTTOM", 0, -3)
				else
					buff:SetPoint("TOP", aboveBuff, "BOTTOM", 0, -3)
				end
				aboveBuff = buff
			elseif index == 1 then
				buff:SetPoint("TOPRIGHT", BuffsAnchor, "TOPRIGHT", 0, 0)
			else
				if numBuffs == 1 then
					if mainhand and offhand and not UnitHasVehicleUI("player") then
						buff:SetPoint("RIGHT", TempEnchant2, "LEFT", -3, 0)
					elseif ((mainhand and not offhand) or (offhand and not mainhand)) and not UnitHasVehicleUI("player") then
						buff:SetPoint("RIGHT", TempEnchant1, "LEFT", -3, 0)
					else
						buff:SetPoint("RIGHT", ConsolidatedBuffs, "LEFT", -3, 0)
					end
				else
					buff:SetPoint("RIGHT", previousBuff, "LEFT", -3, 0)
				end
			end
			previousBuff = buff
		end
	end
end

local function UpdateDebuffAnchors(buttonName, index)
	local debuff = _G[buttonName..index]
	StyleBuffs(buttonName, index, true)
	local dtype = select(5, UnitDebuff("player",index))
	local color
	if (dtype ~= nil) then
		color = DebuffTypeColor[dtype]
	else
		color = DebuffTypeColor["none"]
	end
	_G[buttonName..index.."Panel"].backdrop:SetBackdropBorderColor(color.r, color.g, color.b)
	debuff:ClearAllPoints()
	if index == 1 then
		debuff:SetPoint("TOPRIGHT", BuffsAnchor, -1, -126)
	else
		debuff:SetPoint("RIGHT", _G[buttonName..(index-1)], "LEFT", -4, 0)
	end
end

-- Fixing the consolidated buff container size
local z = 0.79
local function UpdateConsolidatedBuffsAnchors()
	ConsolidatedBuffsTooltip:SetWidth(min(BuffFrame.numConsolidated * C.Aura.BuffSize * z + 18, 4 * C.Aura.BuffSize * z + 18))
	ConsolidatedBuffsTooltip:SetHeight(floor((BuffFrame.numConsolidated + 3) / 4 ) * C.Aura.BuffSize * z + CONSOLIDATED_BUFF_ROW_HEIGHT * z)
end

hooksecurefunc("BuffFrame_UpdateAllBuffAnchors", UpdateBuffAnchors)
hooksecurefunc("DebuffButton_UpdateAnchors", UpdateDebuffAnchors)
hooksecurefunc("AuraButton_UpdateDuration", UpdateDuration)
hooksecurefunc("AuraButton_OnUpdate", UpdateFlash)