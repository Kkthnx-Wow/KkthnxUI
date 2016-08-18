local K, C, L, _ = select(2, ...):unpack()
if C.Unitframe.Enable ~= true then return end

-- LUA API
local _G = _G

-- WOW API
local GetName = GetName
local UnitIsFriend = UnitIsFriend
local hooksecurefunc = hooksecurefunc

TargetFrame.maxBuffs = 16
TargetFrame.maxDebuffs = 16
MAX_TARGET_BUFFS = 16
MAX_TARGET_DEBUFFS = 16

-- AURAS
local function TargetAuraColour(self)
	-- BUFFS
	for i = 1, MAX_TARGET_BUFFS do
		local bframe = _G[self:GetName().."Buff"..i]
		local bframecd = _G[self:GetName().."Buff"..i.."Cooldown"]
		local bframecount = _G[self:GetName().."Buff"..i.."Count"]
		if bframe then
			K.CreateBorder(bframe, 8)

			bframecd:ClearAllPoints()
			bframecd:SetPoint("TOPLEFT", bframe, 1.5, -1.5)
			bframecd:SetPoint("BOTTOMRIGHT", bframe, -1.5, 1.5)

			bframecount:ClearAllPoints()
			bframecount:SetPoint("CENTER", bframe, "BOTTOM", 0, 0)
			bframecount:SetJustifyH"CENTER"
			bframecount:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
			bframecount:SetDrawLayer("OVERLAY", 7)
		end
	end

	-- DEBUFFS
	for i = 1, MAX_TARGET_DEBUFFS do
		local dframe = _G[self:GetName().."Debuff"..i]
		local dframecd = _G[self:GetName().."Debuff"..i.."Cooldown"]
		local dframecount = _G[self:GetName().."Debuff"..i.."Count"]
		if dframe then
			K.CreateBorder(dframe, 8)
			-- BORDER COLOUR
			local dname = UnitDebuff(self.unit, i)
			local _, _, _, _, dtype = UnitDebuff(self.unit, i)
			if dname then
				local colour = DebuffTypeColor[dtype] or DebuffTypeColor.none
				local auborder = _G[self:GetName().."Debuff"..i.."Border"]
				auborder:Hide()
				dframe:SetBackdropBorderColor(colour.r, colour.g, colour.b)
			else
				dframe:SetBackdropBorderColor(unpack(C.Media.Border_Color))
			end

			if dframecd then -- PET DOESN'T SHOW CD?
				dframecd:ClearAllPoints()
				dframecd:SetPoint("TOPLEFT", dframe, 1.5, -1.5)
				dframecd:SetPoint("BOTTOMRIGHT", dframe, -1.5, 1.5)
			end
			if dframecount then -- TOT DOESN'T SHOW STACKS
				dframecount:ClearAllPoints()
				dframecount:SetPoint("CENTER", dframe, "BOTTOM")
				dframecount:SetJustifyH("CENTER")
				dframecount:SetFont(C.Media.Font, C.Media.Font_Size, C.Media.Font_Style)
			end
		end
	end
end

-- REPOSITION
local function TargetAuraPosit(self, auraName, numAuras, numOppositeAuras, largeAuraList, updateFunc, maxRowWidth, offsetX, mirrorAurasVertically)
	local AURA_OFFSET_Y = C.Unitframe.AuraOffsetY
	local LARGE_AURA_SIZE = C.Unitframe.LargeAuraSize
	local SMALL_AURA_SIZE = C.Unitframe.SmallAuraSize
	local AURA_ROW_WIDTH = 100
	local NUM_TOT_AURA_ROWS = 2
	local size
	local offsetY = AURA_OFFSET_Y
	local rowWidth = 0
	local firstBuffOnRow = 1

	for i = 1, numAuras do
		if largeAuraList[i] then
			size = LARGE_AURA_SIZE
		else
			size = SMALL_AURA_SIZE
		end

		if i == 1 then
			rowWidth = size
			self.auraRows = self.auraRows + 1
		else
			rowWidth = rowWidth + size + offsetX
		end

		if rowWidth > maxRowWidth then
			-- X & Y
			updateFunc(self, auraName, i, numOppositeAuras, firstBuffOnRow, size, offsetX + 1, offsetY + 2, mirrorAurasVertically)

			rowWidth = size
			self.auraRows = self.auraRows + 1
			firstBuffOnRow = i
			offsetY = AURA_OFFSET_Y

			if self.auraRows > NUM_TOT_AURA_ROWS then maxRowWidth = AURA_ROW_WIDTH end
		else
			updateFunc(self, auraName, i, numOppositeAuras, i - 1, size, offsetX + 1, offsetY + 2, mirrorAurasVertically)
		end
	end
end

hooksecurefunc("TargetofTarget_Update", TargetAuraColour)
hooksecurefunc("RefreshDebuffs", TargetAuraColour)
hooksecurefunc("TargetFrame_UpdateAuras", TargetAuraColour)