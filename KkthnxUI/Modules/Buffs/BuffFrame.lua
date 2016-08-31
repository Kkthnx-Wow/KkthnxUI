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
local rowbuffs
if K.ScreenWidth <= 1440 then
	rowbuffs = 12
else
	rowbuffs = 16
end

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
		buff:SetTemplate("Default")
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
	duration:SetFont(C.Media.Font,C.Media.Font_Size, C.Media.Font_Style)
	duration:SetShadowOffset(0, -0)

	_G["TempEnchant2"]:ClearAllPoints()
	_G["TempEnchant2"]:SetPoint("RIGHT", _G["TempEnchant1"], "LEFT", -1, 0)
end

local function StyleBuffs(buttonName, index)
	local buff = _G[buttonName..index]
	local icon = _G[buttonName..index.."Icon"]
	local border = _G[buttonName..index.."Border"]
	local duration = _G[buttonName..index.."Duration"]
	local count = _G[buttonName..index.."Count"]

	if border then border:Hide() end

	if icon and not buff.isSkinned then
		buff:SetTemplate("Default")
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
		duration:SetFont(C.Media.Font,C.Media.Font_Size, C.Media.Font_Style)
		duration:SetShadowOffset(0, -0)

		count:ClearAllPoints()
		count:SetPoint("BOTTOMRIGHT", 2, 0)
		count:SetDrawLayer("ARTWORK")
		count:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
		count:SetShadowOffset(0, -0)

		if not buff.shadow then
			buff:CreateBlizzShadow(2)
		end

		buff.isSkinned = true
	end
end


local function StyleDeBuffs(buttonName, index)
	local buff = _G[buttonName..index]
	local icon = _G[buttonName..index.."Icon"]
	local border = _G[buttonName..index.."Border"]
	local duration = _G[buttonName..index.."Duration"]
	local count = _G[buttonName..index.."Count"]
	--local dtype = select(5, UnitDebuff("player",i))
	--local dtype, _, _, _, debuffType, _, _, _, _, _, _, _, _ = UnitDebuff("player", i)
	--local color = 1,1,1

	if border then border:Hide() end

	if icon and not buff.isSkinned then
		buff:SetTemplate("Default")
		buff:SetBackdropBorderColor(1 * 3/5, 0 * 3/5, 0 * 3/5)
		buff:SetSize(C.Aura.BuffSize * 1.1, C.Aura.BuffSize * 1.1)

		icon:SetTexCoord(unpack(K.TexCoords))
		icon:SetPoint("TOPLEFT", buff, 4, -4)
		icon:SetPoint("BOTTOMRIGHT", buff, -4, 4)
		icon:SetDrawLayer("BORDER")

		duration:ClearAllPoints()
		duration:SetPoint("CENTER", 2, 1)
		duration:SetDrawLayer("ARTWORK")
		duration:SetFont(C.Media.Font, C.Media.Font_Size * 1.1, C.Media.Font_Style)
		duration:SetShadowOffset(0, -0)

		count:ClearAllPoints()
		count:SetPoint("BOTTOMRIGHT", 2, 0)
		count:SetDrawLayer("ARTWORK")
		count:SetFont(C.Media.Font, C.Media.Font_Size * 1.1, C.Media.Font_Style)
		count:SetShadowOffset(0, -0)

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
					buff:SetPoint("RIGHT", TempEnchant2, "LEFT", -1, 0)
				elseif ((mainhand and not offhand) or (offhand and not mainhand)) and not UnitHasVehicleUI("player") then
					buff:SetPoint("RIGHT", TempEnchant1, "LEFT", -1, 0)
				else
					buff:SetPoint("TOPRIGHT", BuffsAnchor, "TOPRIGHT", 0, 0)
				end
			else
				buff:SetPoint("RIGHT", previousBuff, "LEFT", -1, 0)
			end
		end
		previousBuff = buff
	end
end

local function UpdateDebuffAnchors(buttonName, index)
	_G[buttonName..index]:Show()
	local debuff = _G[buttonName..index]
	StyleDeBuffs(buttonName, index)

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