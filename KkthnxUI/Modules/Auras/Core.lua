local K, C, L = unpack(select(2, ...))
local Module = K:NewModule("Auras")

-- Sourced: NDui (Siweia)

local _G = _G
local math_floor = _G.math.floor
local select = _G.select
local string_format = _G.string.format
local string_match = _G.string.match
local unpack = _G.unpack

local CreateFrame = _G.CreateFrame
local DebuffTypeColor = _G.DebuffTypeColor
local GetInventoryItemQuality = _G.GetInventoryItemQuality
local GetInventoryItemTexture = _G.GetInventoryItemTexture
local GetItemQualityColor = _G.GetItemQualityColor
local GetTime = _G.GetTime
local GetWeaponEnchantInfo = _G.GetWeaponEnchantInfo
local RegisterAttributeDriver = _G.RegisterAttributeDriver
local RegisterStateDriver = _G.RegisterStateDriver
local UIParent = _G.UIParent
local UnitAura = _G.UnitAura

function Module:OnEnable()
	-- Elements
	self:CreateTotems()
	self:CreateReminder()

	if not C["Auras"].Enable then
		return
	end

	-- Config
	Module.settings = {
		Buffs = {
			offset = 12,
			size = C["Auras"].BuffSize,
			wrapAfter = C["Auras"].BuffsPerRow,
			maxWraps = 3,
			reverseGrow = C["Auras"].ReverseBuffs,
		},
		Debuffs = {
			offset = 12,
			size = C["Auras"].DebuffSize,
			wrapAfter = C["Auras"].DebuffsPerRow,
			maxWraps = 1,
			reverseGrow = C["Auras"].ReverseDebuffs,
		},
	}

	-- HideBlizz
	K.HideInterfaceOption(_G.BuffFrame)
	K.HideInterfaceOption(_G.TemporaryEnchantFrame)

	-- Movers
	self.BuffFrame = self:CreateAuraHeader("HELPFUL")
	local buffAnchor = K.Mover(self.BuffFrame, "Buffs", "BuffAnchor", {"TOPRIGHT", _G.Minimap, "TOPLEFT", -6, 0})
	self.BuffFrame:ClearAllPoints()
	self.BuffFrame:SetPoint("TOPRIGHT", buffAnchor)

	self.DebuffFrame = self:CreateAuraHeader("HARMFUL")
	local debuffAnchor = K.Mover(self.DebuffFrame, "Debuffs", "DebuffAnchor", {"TOPRIGHT", buffAnchor, "BOTTOMRIGHT", 0, -12})
	self.DebuffFrame:ClearAllPoints()
	self.DebuffFrame:SetPoint("TOPRIGHT", debuffAnchor)
end

local day, hour, minute = 86400, 3600, 60
function Module:FormatAuraTime(s)
	if s >= day then
		return string_format("%d"..K.MyClassColor.."d", s / day), s % day
	elseif s >= 2 * hour then
		return string_format("%d"..K.MyClassColor.."h", s / hour), s % hour
	elseif s >= 10 * minute then
		return string_format("%d"..K.MyClassColor.."m", s / minute), s % minute
	elseif s >= minute then
		return string_format("%d:%.2d", s / minute, s % minute), s - math_floor(s)
	elseif s > 10 then
		return string_format("%d"..K.MyClassColor.."s", s), s - math_floor(s)
	elseif s > 5 then
		return string_format("|cffffff00%.1f|r", s), s - string_format("%.1f", s)
	else
		return string_format("|cffff0000%.1f|r", s), s - string_format("%.1f", s)
	end
end

function Module:UpdateTimer(elapsed)
	if self.offset then
		local expiration = select(self.offset, GetWeaponEnchantInfo())
		if expiration then
			self.timeLeft = expiration / 1e3
		else
			self.timeLeft = 0
		end
	else
		self.timeLeft = self.timeLeft - elapsed
	end

	if self.nextUpdate > 0 then
		self.nextUpdate = self.nextUpdate - elapsed
		return
	end

	if self.timeLeft >= 0 then
		local timer, nextUpdate = Module:FormatAuraTime(self.timeLeft)
		self.nextUpdate = nextUpdate
		self.timer:SetText(timer)
	end
end

function Module:UpdateAuras(button, index)
	local filter = button:GetParent():GetAttribute("filter")
	local unit = button:GetParent():GetAttribute("unit")
	local name, texture, count, debuffType, duration, expirationTime, _, _, _, spellID = UnitAura(unit, index, filter)

	if name then
		if duration > 0 and expirationTime then
			local timeLeft = expirationTime - GetTime()
			if not button.timeLeft then
				button.nextUpdate = -1
				button.timeLeft = timeLeft
				button:SetScript("OnUpdate", Module.UpdateTimer)
			else
				button.timeLeft = timeLeft
			end
			-- Need Reviewed
			button.nextUpdate = -1
			Module.UpdateTimer(button, 0)
		else
			button.timeLeft = nil
			button.timer:SetText("")
			button:SetScript("OnUpdate", nil)
		end

		if count and count > 1 then
			button.count:SetText(count)
		else
			button.count:SetText("")
		end

		if filter == "HARMFUL" then
			local color = DebuffTypeColor[debuffType or "none"]
			button.KKUI_Border:SetVertexColor(color.r, color.g, color.b)
		else
			if C["General"].ColorTextures then
				button.KKUI_Border:SetVertexColor(unpack(C["General"].TexturesColor))
			else
				button.KKUI_Border:SetVertexColor(1, 1, 1)
			end
		end

		button.spellID = spellID
		button.icon:SetTexture(texture)
		button.offset = nil
	end
end

function Module:UpdateTempEnchant(button, index)
	local quality = GetInventoryItemQuality("player", index)
	button.icon:SetTexture(GetInventoryItemTexture("player", index))

	local offset = 2
	local weapon = button:GetName():sub(-1)
	if string_match(weapon, "2") then
		offset = 6
	end

	if quality then
		button.KKUI_Border:SetVertexColor(GetItemQualityColor(quality))
	end

	local expirationTime = select(offset, GetWeaponEnchantInfo())
	if expirationTime then
		button.offset = offset
		button:SetScript("OnUpdate", Module.UpdateTimer)
		button.nextUpdate = -1
		Module.UpdateTimer(button, 0)
	else
		button.offset = nil
		button.timeLeft = nil
		button:SetScript("OnUpdate", nil)
		button.timer:SetText("")
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
	local cfg = Module.settings.Debuffs
	if header:GetAttribute("filter") == "HELPFUL" then
		cfg = Module.settings.Buffs
		header:SetAttribute("consolidateTo", 0)
		header:SetAttribute("weaponTemplate", string_format("KKUI_AuraTemplate%d", cfg.size))
	end

	local margin = 6

	header:SetAttribute("separateOwn", 1)
	header:SetAttribute("sortMethod", "INDEX")
	header:SetAttribute("sortDirection", "+")
	header:SetAttribute("wrapAfter", cfg.wrapAfter)
	header:SetAttribute("maxWraps", cfg.maxWraps)
	header:SetAttribute("point", cfg.reverseGrow and "TOPLEFT" or "TOPRIGHT")
	header:SetAttribute("minWidth", (cfg.size + margin) * cfg.wrapAfter)
	header:SetAttribute("minHeight", (cfg.size + cfg.offset) * cfg.maxWraps)
	header:SetAttribute("xOffset", (cfg.reverseGrow and 1 or -1) * (cfg.size + margin))
	header:SetAttribute("yOffset", 0)
	header:SetAttribute("wrapXOffset", 0)
	header:SetAttribute("wrapYOffset", -(cfg.size + cfg.offset))
	header:SetAttribute("template", string_format("KKUI_AuraTemplate%d", cfg.size))

	local index = 1
	local child = select(index, header:GetChildren())
	while child do
		if (math_floor(child:GetWidth() * 100 + 0.5) / 100) ~= cfg.size then
			child:SetSize(cfg.size, cfg.size)
		end

		-- Blizzard bug fix, icons arent being hidden when you reduce the amount of maximum buttons
		if index > (cfg.maxWraps * cfg.wrapAfter) and child:IsShown() then
			child:Hide()
		end

		index = index + 1
		child = select(index, header:GetChildren())
	end
end

function Module:CreateAuraHeader(filter)
	local name = "KKUI_PlayerDebuffs"
	if filter == "HELPFUL" then
		name = "KKUI_PlayerBuffs"
	end

	local header = CreateFrame("Frame", name, UIParent, "SecureAuraHeaderTemplate")
	header:SetClampedToScreen(true)
	header:SetAttribute("unit", "player")
	header:SetAttribute("filter", filter)
	RegisterStateDriver(header, "visibility", "[petbattle] hide; show")
	RegisterAttributeDriver(header, "unit", "[vehicleui] vehicle; player")

	if filter == "HELPFUL" then
		header:SetAttribute("consolidateDuration", -1)
		header:SetAttribute("includeWeapons", 1)
	end

	Module:UpdateHeader(header)
	header:Show()

	return header
end

function Module:RemoveSpellFromIgnoreList()
	if IsAltKeyDown() and IsControlKeyDown() and self.spellID and KkthnxUIDB.Variables[K.Realm][K.Name].AuraWatchList.IgnoreSpells[self.spellID] then
		KkthnxUIDB.Variables[K.Realm][K.Name].AuraWatchList.IgnoreSpells[self.spellID] = nil
		K.Print(string.format(L["RemoveFromIgnoreList"], "", self.spellID))
	end
end

function Module:CreateAuraIcon(button)
	local header = button:GetParent()
	local cfg = Module.settings.Debuffs
	if header:GetAttribute("filter") == "HELPFUL" then
		cfg = Module.settings.Buffs
	end
	local fontSize = math_floor(cfg.size / 30 * 12 + 0.5)

	button.icon = button:CreateTexture(nil, "BORDER")
	button.icon:SetAllPoints()
	button.icon:SetTexCoord(unpack(K.TexCoords))

	button.count = button:CreateFontString(nil, "OVERLAY")
	button.count:SetPoint("TOPRIGHT", -1, -3)
	button.count:SetFontObject(K.GetFont(C["UIFonts"].AuraFonts))
	button.count:SetFont(select(1, button.count:GetFont()), fontSize, select(3, button.count:GetFont()))

	button.timer = button:CreateFontString(nil, "OVERLAY")
	button.timer:SetPoint("TOP", button, "BOTTOM", 1, 5)
	button.timer:SetFontObject(K.GetFont(C["UIFonts"].AuraFonts))
	button.timer:SetFont(select(1, button.timer:GetFont()), fontSize, select(3, button.timer:GetFont()))

	button:StyleButton()
	button:CreateBorder()

	button:SetScript("OnAttributeChanged", Module.OnAttributeChanged)
	button:HookScript("OnMouseDown", Module.RemoveSpellFromIgnoreList)
end