local K, C = unpack(select(2, ...))
local Module = K:GetModule("Auras")

local _G = _G
local unpack = _G.unpack

local CreateFrame = _G.CreateFrame
local GetSpellTexture = _G.GetSpellTexture
local GetTotemInfo = _G.GetTotemInfo
local UIParent = _G.UIParent

-- Style
local totem = {}
local icons = {
	[1] = GetSpellTexture(120217), -- Fire
	[2] = GetSpellTexture(120218), -- Earth
	[3] = GetSpellTexture(120214), -- Water
	[4] = GetSpellTexture(120219), -- Air
}

local function TotemsGo()
	local Totembar = CreateFrame("Frame", nil, UIParent)
	Totembar:SetSize(32, 32)

	for i = 1, 4 do
		totem[i] = CreateFrame("Button", nil, Totembar)
		totem[i]:SetSize(32, 32)
		if i == 1 then
			totem[i]:SetPoint("CENTER", Totembar)
		else
			totem[i]:SetPoint("LEFT", totem[i - 1], "RIGHT", 5, 0)
		end

		totem[i].CD = CreateFrame("Cooldown", nil, totem[i], "CooldownFrameTemplate")
		totem[i].CD:SetAllPoints()
		totem[i].CD:SetReverse(true)

		totem[i].Icon = totem[i]:CreateTexture(nil, "ARTWORK")
		totem[i].Icon:SetAllPoints()
		totem[i].Icon:SetTexCoord(unpack(K.TexCoords))
		totem[i]:CreateBorder()

		totem[i].Icon:SetTexture(icons[i])
		totem[i]:SetAlpha(0.2)

		local defaultTotem = _G["TotemFrameTotem"..i]
		defaultTotem:SetParent(totem[i])
		defaultTotem:SetAllPoints()
		defaultTotem:SetAlpha(0)
		totem[i].parent = defaultTotem
	end

	K.Mover(Totembar, "Totembar", "Totems", {"CENTER", UIParent, "CENTER", 0, -190}, 140, 32)
end

function Module:UpdateTotems()
	for i = 1, 4 do
		local totem = totem[i]
		local defaultTotem = totem.parent
		local slot = defaultTotem.slot

		local haveTotem, _, start, dur, icon = GetTotemInfo(slot)
		if haveTotem and dur > 0 then
			totem.Icon:SetTexture(icon)
			totem.CD:SetCooldown(start, dur)
			totem.CD:Show()
			totem:SetAlpha(1)
		else
			totem:SetAlpha(0.2)
			totem.Icon:SetTexture(icons[i])
			totem.CD:Hide()
		end
	end
end

function Module:CreateShamanTotems()
	if not C["Auras"].Totems then
		return
	end

	TotemsGo()
	K:RegisterEvent("PLAYER_ENTERING_WORLD", self.UpdateTotems)
	K:RegisterEvent("PLAYER_TOTEM_UPDATE", self.UpdateTotems)
end