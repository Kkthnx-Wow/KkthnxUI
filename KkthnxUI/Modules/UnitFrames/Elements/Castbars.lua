local K, C, L = unpack(select(2, ...))
if (C["Unitframe"].Enable ~= true or C["Unitframe"].Castbars ~= true) then
	return
end

local Module = K:GetModule("Unitframes")

local _G = _G

-- Wow API
local CreateFrame = _G.CreateFrame

local CastbarFont = K.GetFont(C["Unitframe"].Font)
local CastbarTexture = K.GetTexture(C["Unitframe"].Texture)

function Module:CreateCastBar(unit)
	unit = unit:match("^(%a-)%d+") or unit

	local castbar = CreateFrame("StatusBar", "$parentCastbar", self)
	castbar:SetStatusBarTexture(CastbarTexture)
	castbar:SetSize(C["Unitframe"].CastbarWidth, C["Unitframe"].CastbarHeight)
	castbar:SetClampedToScreen(true)
	castbar:SetTemplate("Transparent", true)

	castbar:ClearAllPoints()
	if (unit == "player") then
		castbar:SetPoint("BOTTOM", ActionBarAnchor, "TOP", 0, 203)
		K.Movers:RegisterFrame(castbar)
	elseif (unit == "target") then
		castbar:SetPoint("BOTTOM", oUF_PlayerCastbar, "TOP", 0, 6)
		K.Movers:RegisterFrame(castbar)
	elseif (unit == "focus" or unit == "arena" or unit == "boss") then
		castbar:SetPoint("LEFT", 4, 0)
		castbar:SetPoint("RIGHT", -28, 0)
		castbar:SetPoint("TOP", 0, 20)
		castbar:SetHeight(18)
	end

	castbar.PostCastStart = Module.CheckCast
	castbar.PostChannelStart = Module.CheckChannel

	local spark = castbar:CreateTexture(nil, "OVERLAY")
	spark:SetTexture(C["Media"].Spark_128)
	spark:SetSize(128, castbar:GetHeight())
	spark:SetBlendMode("ADD")
	castbar.Spark = spark

	if (unit == "target") then
		local shield = castbar:CreateTexture(nil, "ARTWORK")
		shield:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\CastBorderShield")
		shield:SetPoint("RIGHT", castbar, "LEFT", 34, 12)
		castbar.Shield = shield
	end

	if (unit == "player") then
		local safeZone = castbar:CreateTexture(nil, "ARTWORK")
		safeZone:SetTexture(CastbarTexture)
		safeZone:SetPoint("RIGHT")
		safeZone:SetPoint("TOP")
		safeZone:SetPoint("BOTTOM")
		safeZone:SetVertexColor(0.69, 0.31, 0.31, 0.75)
		safeZone:SetWidth(0.0001)
		castbar.SafeZone = safeZone
	end

	if (unit == "player" or unit == "target" or unit == "focus" or unit == "arena" or unit == "boss") then
		local time = castbar:CreateFontString(nil, "OVERLAY", CastbarFont)
		time:SetPoint("RIGHT", -3.5, 0)
		time:SetTextColor(0.84, 0.75, 0.65)
		time:SetJustifyH("RIGHT")
		castbar.Time = time

		castbar.CustomTimeText = Module.CustomCastTimeText
		castbar.CustomDelayText = Module.CustomCastDelayText

		local text = castbar:CreateFontString(nil, "OVERLAY", CastbarFont)
		text:SetPoint("LEFT", 3.5, 0)
		text:SetPoint("RIGHT", time, "LEFT", -3.5, 0)
		text:SetTextColor(0.84, 0.75, 0.65)
		text:SetJustifyH("LEFT")
		text:SetWordWrap(false)
		castbar.Text = text
	end

	if (unit ~= "pet" and C["Unitframe"].CastbarIcon) then
		local button = CreateFrame("Frame", nil, castbar)
		button:SetSize(20, 20)
		button:SetTemplate("Transparent", true)

		local icon = button:CreateTexture(nil, "ARTWORK")
		icon:SetSize(castbar:GetHeight(), castbar:GetHeight())
		icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
		button:SetAllPoints(icon)
		if (unit == "player") then
			icon:SetPoint("RIGHT", castbar, "LEFT", -6, 0)
		elseif (unit == "target") then
			icon:SetPoint("LEFT", castbar, "RIGHT", 6, 0)
		else
			icon:SetPoint("LEFT", castbar, "RIGHT", 6, 0)
		end

		castbar.Icon = icon
	end

	self.Castbar = castbar
end