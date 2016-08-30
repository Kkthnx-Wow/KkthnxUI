local K, C, L, _ = select(2, ...):unpack()
if C.Aura.Enable ~= true then return end

-- LUA API
local _G = _G
local format = string.format
local floor = math.floor
local unpack = unpack

-- WOW API
local UnitHasVehicleUI = UnitHasVehicleUI
local hooksecurefunc = hooksecurefunc
local CreateFrame = CreateFrame

-- STYLE PLAYER BUFFS(BY TUKZ)
local rowbuffs = 16

local GetFormattedTime = function(s)
	if s >= 86400 then
		return format("%dd", floor(s / 86400 + 0.5))
	elseif s >= 3600 then
		return format("%dh", floor(s / 3600 + 0.5))
	elseif s >= 60 then
		return format("%dm", floor(s / 60 + 0.5))
	end
	return floor(s + 0.5)
end

local BuffsAnchor = CreateFrame("Frame", "BuffsAnchor", UIParent)
BuffsAnchor:SetPoint(unpack(C.Position.PlayerBuffs))
BuffsAnchor:SetSize((15 * C.Aura.BuffSize) + 42, (C.Aura.BuffSize * 2) + 3)

for i = 1, NUM_TEMP_ENCHANT_FRAMES do
	local buff = _G["TempEnchant"..i]
	local icon = _G["TempEnchant"..i.."Icon"]
	local border = _G["TempEnchant"..i.."Border"]
	local duration = _G["TempEnchant"..i.."Duration"]

	if border then border:Hide() end

	if i ~= 3 then
		--buff:SetTemplate("Default")
		buff:SetBackdrop(K.Border)
		if C.Aura.ClassColorBorder == true then
			buff:SetBackdropBorderColor(K.Color.r, K.Color.g, K.Color.b)
		elseif C.Blizzard.DarkTextures == true then
			buff:SetBackdropBorderColor(unpack(C.Blizzard.DarkTexturesColor))
		end
	end

	buff:SetSize(C.Aura.BuffSize, C.Aura.BuffSize)

	icon:SetTexCoord(unpack(K.TexCoords))
	icon:SetPoint("TOPLEFT", buff, 4, -4)
	icon:SetPoint("BOTTOMRIGHT", buff, -4, 4)
	icon:SetDrawLayer("BORDER")

	duration:ClearAllPoints()
	duration:SetPoint("CENTER", 2, 1)
	duration:SetDrawLayer("ARTWORK")
	duration:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)

	_G["TempEnchant2"]:ClearAllPoints()
	_G["TempEnchant2"]:SetPoint("RIGHT", _G["TempEnchant1"], "LEFT", 0, 0)
	
	if icon then
		icon:SetAlpha(1)
		icon:SetTexture(icon)
	else
		icon:SetAlpha(0)
	end
end

local function StyleBuffs(buttonName, index)
	local buff = _G[buttonName..index]
	local icon = _G[buttonName..index.."Icon"]
	local border = _G[buttonName..index.."Border"]
	local duration = _G[buttonName..index.."Duration"]
	local count = _G[buttonName..index.."Count"]

	if border then border:Hide() end

	if icon and not buff.isSkinned then
		buff:SetBackdrop(K.Border)
		if C.Aura.ClassColorBorder == true then
			buff:SetBackdropBorderColor(K.Color.r, K.Color.g, K.Color.b)
		elseif C.Blizzard.DarkTextures == true then
			buff:SetBackdropBorderColor(unpack(C.Blizzard.DarkTexturesColor))
		end

		buff:SetSize(C.Aura.BuffSize, C.Aura.BuffSize)

		icon:SetTexCoord(unpack(K.TexCoords))
		icon:SetPoint("TOPLEFT", buff, 4, -4)
		icon:SetPoint("BOTTOMRIGHT", buff, -4, 4)
		icon:SetDrawLayer("BORDER")

		duration:ClearAllPoints()
		duration:SetPoint("CENTER", 2, 1)
		duration:SetDrawLayer("ARTWORK")
		duration:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)

		count:ClearAllPoints()
		count:SetPoint("BOTTOMRIGHT", 2, 0)
		count:SetDrawLayer("ARTWORK")
		count:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
		
		if not buff.shadow then
			buff:CreateBlizzShadow(2)
		end

		buff.isSkinned = true
	end
end

local function UpdateFlash(self, elapsed)
	local index = self:GetID()
	self:SetAlpha(1)
end

local function UpdateDuration(auraButton, timeLeft)
	local duration = auraButton.duration
	if timeLeft and C.Aura.Timer == true then
		duration:SetFormattedText(GetFormattedTime(timeLeft))
		duration:SetVertexColor(1, 1, 1)
		duration:Show()
	else
		duration:Hide()
	end
end

local function UpdateBuffAnchors()
	local buttonName = "BuffButton"
	local buff, previousBuff, aboveBuff
	local numBuffs = 0
	local numAuraRows = 0
	local slack = BuffFrame.numEnchants
	local mainhand, _, _, offhand = GetWeaponEnchantInfo()

	for index = 1, BUFF_ACTUAL_DISPLAY do
		StyleBuffs(buttonName, index)
		local buff = _G[buttonName..index]
		numBuffs = numBuffs + 1
		index = numBuffs + slack
		buff:ClearAllPoints()
		if (index > 1) and (mod(index, rowbuffs) == 1) then
			numAuraRows = numAuraRows + 1
			buff:SetPoint("TOP", aboveBuff, "BOTTOM", 0, -3)
			aboveBuff = buff
		elseif index == 1 then
			numAuraRows = 1
			buff:SetPoint("TOPRIGHT", BuffsAnchor, "TOPRIGHT", 0, 0)
		else
			if numBuffs == 1 then
				if mainhand and offhand and not UnitHasVehicleUI("player") then
					buff:SetPoint("RIGHT", TempEnchant2, "LEFT", 0, 0)
				elseif ((mainhand and not offhand) or (offhand and not mainhand)) and not UnitHasVehicleUI("player") then
					buff:SetPoint("RIGHT", TempEnchant1, "LEFT", 0, 0)
				else
					buff:SetPoint("TOPRIGHT", BuffsAnchor, "TOPRIGHT", 0, 0)
				end
			else
				buff:SetPoint("RIGHT", previousBuff, "LEFT", 0, 0)
			end
		end
		previousBuff = buff
	end
end

local function UpdateDebuffAnchors(buttonName, index)
	local debuff = _G[buttonName..index]
	StyleBuffs(buttonName, index, true)
	local dtype = select(5, UnitDebuff("player", index))
	local color
	if (dtype ~= nil) then
		color = DebuffTypeColor[dtype]
	else
		color = DebuffTypeColor["none"]
	end
	debuff:SetBackdropBorderColor(color.r, color.g, color.b)
	debuff:ClearAllPoints()
	if index == 1 then
		debuff:SetPoint("TOPRIGHT", BuffsAnchor, 0, -126)
	else
		debuff:SetPoint("RIGHT", _G[buttonName..(index-1)], "LEFT", 0, 0)
	end
end

hooksecurefunc("BuffFrame_UpdateAllBuffAnchors", UpdateBuffAnchors)
hooksecurefunc("DebuffButton_UpdateAnchors", UpdateDebuffAnchors)
hooksecurefunc("AuraButton_UpdateDuration", UpdateDuration)
hooksecurefunc("AuraButton_OnUpdate", UpdateFlash)