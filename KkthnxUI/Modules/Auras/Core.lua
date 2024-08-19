local K, C, L = KkthnxUI[1], KkthnxUI[2], KkthnxUI[3]
local Module = K:NewModule("Auras")

-- Cache WoW API and Lua functions
local math_floor, select, string_format = math.floor, select, string.format
local CreateFrame, GetTime, GetWeaponEnchantInfo = CreateFrame, GetTime, GetWeaponEnchantInfo
local DebuffTypeColor, RegisterAttributeDriver, RegisterStateDriver = DebuffTypeColor, RegisterAttributeDriver, RegisterStateDriver
local GameTooltip, GetInventoryItemQuality, GetInventoryItemTexture = GameTooltip, GetInventoryItemQuality, GetInventoryItemTexture

local day, hour, minute = 86400, 3600, 60

function Module:OnEnable()
	local loadAuraModules = { "HideBlizBuff", "BuildBuffFrame", "CreateTotems", "CreateReminder" }
	for _, funcName in ipairs(loadAuraModules) do
		local func = self[funcName]
		if type(func) == "function" then
			local success, err = pcall(func, self)
			if not success then
				error("Error in function " .. funcName .. ": " .. tostring(err), 2)
			end
		end
	end
end

function Module:HideBlizBuff()
	if not C["Auras"].Enable and not C["Auras"].HideBlizBuff then
		return
	end
	K:RegisterEvent("PLAYER_ENTERING_WORLD", function(_, isLogin, isReload)
		if isLogin or isReload then
			K.HideInterfaceOption(_G.BuffFrame)
			K.HideInterfaceOption(_G.DebuffFrame)
			BuffFrame.numHideableBuffs = 0 -- Prevent error in edit mode
		end
	end)
end

function Module:BuildBuffFrame()
	if not C["Auras"].Enable then
		return
	end

	-- Buff and Debuff settings
	Module.settings = {
		Buffs = { offset = 12, size = C["Auras"].BuffSize, wrapAfter = C["Auras"].BuffsPerRow, maxWraps = 3, reverseGrow = C["Auras"].ReverseBuffs },
		Debuffs = { offset = 12, size = C["Auras"].DebuffSize, wrapAfter = C["Auras"].DebuffsPerRow, maxWraps = 1, reverseGrow = C["Auras"].ReverseDebuffs },
	}

	-- Create Buff Header
	Module.BuffFrame = Module:CreateAuraHeader("HELPFUL")
	Module.BuffFrame.mover = K.Mover(Module.BuffFrame, "Buffs", "BuffAnchor", { "TOPRIGHT", _G.Minimap, "TOPLEFT", -6, 0 })
	Module.BuffFrame:SetPoint("TOPRIGHT", Module.BuffFrame.mover)

	-- Create Debuff Header
	Module.DebuffFrame = Module:CreateAuraHeader("HARMFUL")
	Module.DebuffFrame.mover = K.Mover(Module.DebuffFrame, "Debuffs", "DebuffAnchor", { "TOPRIGHT", Module.BuffFrame.mover, "BOTTOMRIGHT", 0, -12 })
	Module.DebuffFrame:SetPoint("TOPRIGHT", Module.DebuffFrame.mover)
end

function Module:FormatAuraTime(s)
	if s >= day then
		return string_format("%d" .. K.MyClassColor .. "d", s / day), s % day
	elseif s >= hour * 2 then
		return string_format("%d" .. K.MyClassColor .. "h", s / hour), s % hour
	elseif s >= minute * 10 then
		return string_format("%d" .. K.MyClassColor .. "m", s / minute), s % minute
	elseif s >= minute then
		return string_format("%d:%.2d", s / minute, s % minute), s - math_floor(s)
	elseif s > 10 then
		return string_format("%d" .. K.MyClassColor .. "s", s), s - math_floor(s)
	elseif s > 5 then
		return string_format("|cffffff00%.1f|r", s), s - string_format("%.1f", s)
	else
		return string_format("|cffff0000%.1f|r", s), s - string_format("%.1f", s)
	end
end

function Module:UpdateTimer(elapsed)
	local onTooltip = GameTooltip:IsOwned(self)
	if not (self.timeLeft or self.expiration or onTooltip) then
		self:SetScript("OnUpdate", nil)
		return
	end

	if self.timeLeft then
		self.timeLeft = self.timeLeft - elapsed
	elseif self.expiration then
		self.timeLeft = (self.expiration / 1e3) - (GetTime() - self.oldTime)
	end

	if self.timeLeft and self.timeLeft >= 0 then
		if self.nextUpdate > 0 then
			self.nextUpdate = self.nextUpdate - elapsed
			return
		end

		local timer, nextUpdate = Module:FormatAuraTime(self.timeLeft)
		self.nextUpdate = nextUpdate
		self.timer:SetText(timer)
	else
		self.timer:SetText("") -- Clear the timer if timeLeft is invalid
	end

	-- If the tooltip is showing, update it
	if onTooltip then
		Module:Button_SetTooltip(self)
	end
end

function Module:UpdateAuras(button, index)
	local unit, filter = button.header:GetAttribute("unit"), button.filter
	local auraData = C_UnitAuras.GetAuraDataByIndex(unit, index, filter)
	if not auraData then
		return
	end

	button.timeLeft = auraData.duration > 0 and (auraData.expirationTime - GetTime()) or nil
	if button.timeLeft then
		button.nextUpdate = -1
		button:SetScript("OnUpdate", Module.UpdateTimer)
		Module.UpdateTimer(button, 0)
	else
		button.timer:SetText("")
	end

	button.count:SetText(auraData.applications and auraData.applications > 1 and auraData.applications or "")
	button.icon:SetTexture(auraData.icon)

	if filter == "HARMFUL" then
		local color = DebuffTypeColor[auraData.dispelName or "none"]
		button.KKUI_Border:SetVertexColor(color.r, color.g, color.b)
	else
		K.SetBorderColor(button.KKUI_Border)
	end

	button.spellID = auraData.spellId
end

function Module:UpdateTempEnchant(button, index)
	local expirationTime = select(button.enchantOffset, GetWeaponEnchantInfo())
	if expirationTime then
		local quality = GetInventoryItemQuality("player", index)
		button.KKUI_Border:SetVertexColor(K.QualityColors[quality or 1].r, K.QualityColors[quality or 1].g, K.QualityColors[quality or 1].b)
		button.icon:SetTexture(GetInventoryItemTexture("player", index))
		button.expiration = expirationTime
		button.oldTime = GetTime()
		button:SetScript("OnUpdate", Module.UpdateTimer)
		button.nextUpdate = -1
		Module.UpdateTimer(button, 0)
	else
		button.timer:SetText("")
		button.expiration, button.timeLeft = nil, nil
	end
end

function Module:OnAttributeChanged(attribute, value)
	if attribute == "index" then
		Module:UpdateAuras(self, value)
	elseif attribute == "target-slot" then
		Module:UpdateTempEnchant(self, value)
	end
end

function Module:UpdateHeader(header)
	local cfg = Module.settings[header.filter == "HELPFUL" and "Buffs" or "Debuffs"]
	header:SetAttribute("wrapAfter", cfg.wrapAfter)
	header:SetAttribute("maxWraps", cfg.maxWraps)
	header:SetAttribute("point", cfg.reverseGrow and "TOPLEFT" or "TOPRIGHT")
	header:SetAttribute("xOffset", (cfg.reverseGrow and 1 or -1) * (cfg.size + 6))
	header:SetAttribute("wrapYOffset", -(cfg.size + cfg.offset))
	header:SetAttribute("template", string_format("KKUI_AuraTemplate%d", cfg.size))
	header:SetAttribute("minWidth", (cfg.size + 6) * cfg.wrapAfter)
	header:SetAttribute("minHeight", (cfg.size + cfg.offset) * cfg.maxWraps)
	header:SetAttribute("sortMethod", "INDEX")
	header:SetAttribute("sortDirection", "+")

	-- Update child aura frames
	local fontSize = math_floor(cfg.size / 30 * 12 + 0.5)
	for i, child in ipairs({ header:GetChildren() }) do
		if i <= (cfg.maxWraps * cfg.wrapAfter) then
			child:SetSize(cfg.size, cfg.size)
			child.count:SetFontObject(K.UIFontOutline)
			child.count:SetFont(select(1, child.count:GetFont()), fontSize, select(3, child.count:GetFont()))
			child.timer:SetFontObject(K.UIFontOutline)
			child.timer:SetFont(select(1, child.timer:GetFont()), fontSize, select(3, child.timer:GetFont()))
		else
			child:Hide() -- Hide extra frames beyond wrap limit
		end
	end
end

function Module:CreateAuraHeader(filter)
	local header = CreateFrame("Frame", "KKUI_Player" .. (filter == "HELPFUL" and "Buffs" or "Debuffs"), UIParent, "SecureAuraHeaderTemplate")
	header:SetClampedToScreen(true)
	header:RegisterUnitEvent("UNIT_AURA", "player", "vehicle")
	header:SetAttribute("unit", "player")
	header:SetAttribute("filter", filter)
	RegisterAttributeDriver(header, "unit", "[vehicleui] vehicle; player")

	header.visibility = CreateFrame("Frame", nil, UIParent, "SecureHandlerStateTemplate")
	header.visibility:RegisterEvent("WEAPON_ENCHANT_CHANGED")
	RegisterStateDriver(header.visibility, "customVisibility", "[petbattle] 0;1")
	header.visibility:SetAttribute("_onstate-customVisibility", [[local header = self:GetFrameRef("AuraHeader") if newstate == 0 then header:Hide() else header:Show() end]])
	SecureHandlerSetFrameRef(header.visibility, "AuraHeader", header)

	Module:UpdateHeader(header)
	header:Show()

	return header
end

function Module:RemoveSpellFromIgnoreList()
	if IsAltKeyDown() and IsControlKeyDown() and self.spellID then
		KkthnxUIDB.Variables[K.Realm][K.Name].AuraWatchList.IgnoreSpells[self.spellID] = nil
		K.Print(string_format(L["RemoveFromIgnoreList"], "", self.spellID))
	end
end

function Module:Button_SetTooltip(button)
	if button:GetAttribute("index") then
		GameTooltip:SetUnitAura(button.header:GetAttribute("unit"), button:GetID(), button.filter)
	elseif button:GetAttribute("target-slot") then
		GameTooltip:SetInventoryItem("player", button:GetID())
	end
end

function Module:Button_OnEnter()
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMLEFT", -5, -5)
	self.nextUpdate = -1
	self:SetScript("OnUpdate", Module.UpdateTimer)
end

function Module:CreateAuraIcon(button)
	button.header = button:GetParent()
	button.filter = button.header.filter
	local fontSize = math_floor(Module.settings[button.filter == "HELPFUL" and "Buffs" or "Debuffs"].size / 30 * 12 + 0.5)

	button.icon = button:CreateTexture(nil, "BORDER")
	button.icon:SetAllPoints()
	button.icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

	button.count = button:CreateFontString(nil, "OVERLAY")
	button.count:SetPoint("TOPRIGHT", -1, -3)
	button.count:SetFontObject(K.UIFontOutline)
	button.count:SetFont(select(1, button.count:GetFont()), fontSize, select(3, button.count:GetFont()))

	button.timer = button:CreateFontString(nil, "OVERLAY")
	button.timer:SetPoint("TOP", button, "BOTTOM", 1, 5)
	button.timer:SetFontObject(K.UIFontOutline)
	button.timer:SetFont(select(1, button.timer:GetFont()), fontSize, select(3, button.timer:GetFont()))

	button:StyleButton()
	button:CreateBorder()

	button:RegisterForClicks("RightButtonDown")
	button:SetScript("OnAttributeChanged", Module.OnAttributeChanged)
	button:HookScript("OnMouseDown", Module.RemoveSpellFromIgnoreList)
	button:SetScript("OnEnter", Module.Button_OnEnter)
	button:SetScript("OnLeave", K.HideTooltip)
end
