local K, C = unpack(KkthnxUI)
local Module = K:GetModule("Tooltip")

local gsub = gsub
local GetItemIcon, GetSpellTexture = GetItemIcon, GetSpellTexture
local newString = "0:0:64:64:5:59:5:59"

function Module:SetupTooltipIcon(icon)
	local title = icon and _G[self:GetName() .. "TextLeft1"]
	local titleText = title and title:GetText()
	if titleText and not strfind(titleText, ":20:20:") then
		title:SetFormattedText("|T%s:20:20:" .. newString .. ":%d|t %s", icon, 20, titleText)
	end

	for i = 2, self:NumLines() do
		local line = _G[self:GetName() .. "TextLeft" .. i]
		if not line then
			break
		end
		local text = line:GetText()
		if text and text ~= " " then
			local newText, count = gsub(text, "|T([^:]-):[%d+:]+|t", "|T%1:14:14:" .. newString .. "|t")
			if count > 0 then
				line:SetText(newText)
			end
		end
	end
end

function Module:HookTooltipCleared()
	self.tipModified = false
end

function Module:HookTooltipMethod()
	self:HookScript("OnTooltipCleared", Module.HookTooltipCleared)
end

function Module:ReskinRewardIcon()
	self.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

	self.Count:ClearAllPoints()
	self.Count:SetPoint("BOTTOMRIGHT", self.Icon, "BOTTOMRIGHT", 1, 1)

	self.bg = CreateFrame("Frame", nil, self)
	self.bg:SetAllPoints(self.Icon)
	self.bg:SetFrameLevel(2)
	self.bg:CreateBorder()

	local iconBorder = self.IconBorder
	iconBorder:SetAlpha(0)
end

function Module:CreateTooltipIcons()
	if not C["Tooltip"].Icons then
		return
	end

	-- Add Icons
	Module.HookTooltipMethod(GameTooltip)
	Module.HookTooltipMethod(ItemRefTooltip)

	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Item, function(self)
		if self == GameTooltip or self == ItemRefTooltip then
			local data = self:GetTooltipData()
			local id = data and data.id
			if id then
				Module.SetupTooltipIcon(self, GetItemIcon(id))
			end
		end
	end)
	TooltipDataProcessor.AddTooltipPostCall(Enum.TooltipDataType.Spell, function(self)
		if self == GameTooltip or self == ItemRefTooltip then
			local data = self:GetTooltipData()
			local id = data and data.id
			if id then
				Module.SetupTooltipIcon(self, GetSpellTexture(id))
			end
		end
	end)

	-- Cut Icons
	hooksecurefunc(GameTooltip, "SetUnitAura", function(self)
		Module.SetupTooltipIcon(self)
	end)

	hooksecurefunc(GameTooltip, "SetAzeriteEssence", function(self)
		Module.SetupTooltipIcon(self)
	end)
	hooksecurefunc(GameTooltip, "SetAzeriteEssenceSlot", function(self)
		Module.SetupTooltipIcon(self)
	end)

	-- Tooltip rewards icon
	Module.ReskinRewardIcon(GameTooltip.ItemTooltip)
	Module.ReskinRewardIcon(EmbeddedItemTooltip.ItemTooltip)
end
