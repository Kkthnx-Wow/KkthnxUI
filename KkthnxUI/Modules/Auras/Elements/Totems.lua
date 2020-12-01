local K, C = unpack(select(2, ...))
local Module = K:GetModule("Auras")

local _G = _G
local unpack = _G.unpack

local CreateFrame = _G.CreateFrame
local GetTotemInfo = _G.GetTotemInfo

local totems = {}
function Module:TotemBar_Init()
	local margin = 6
	local vertical = C["Auras"].VerticalTotems
	local iconSize = C["Auras"].TotemSize
	local width = vertical and (iconSize + margin * 2) or (iconSize * 4 + margin * 5)
	local height = vertical and (iconSize * 4 + margin * 5) or (iconSize + margin * 2)

	local totemBar = _G["KKUI_TotemBar"]
	if not totemBar then
		totemBar = CreateFrame("Frame", "KKUI_TotemBar", K.PetBattleHider)
	end
	totemBar:SetSize(width, height)

	if not totemBar.mover then
		totemBar.mover = K.Mover(totemBar, "Totembar", "Totems", {"BOTTOMRIGHT", UIParent, "BOTTOM", -450, 20})
	end
	totemBar.mover:SetSize(width, height)

	for i = 1, 4 do
		local totem = totems[i]
		if not totem then
			totem = CreateFrame("Frame", nil, totemBar)
			totem.CD = CreateFrame("Cooldown", nil, totem, "CooldownFrameTemplate")
			totem.CD:SetPoint("TOPLEFT", totem, "TOPLEFT", 1, -1)
			totem.CD:SetPoint("BOTTOMRIGHT", totem, "BOTTOMRIGHT", -1, 1)
			totem.CD:SetReverse(true)

			totem.Icon = totem:CreateTexture(nil, "ARTWORK")
			totem.Icon:SetAllPoints()
			totem.Icon:SetTexCoord(unpack(K.TexCoords))

			totem:CreateBorder()
			totem:SetAlpha(0)
			totems[i] = totem

			local blizzTotem = _G["TotemFrameTotem"..i]
			blizzTotem:SetParent(totem)
			blizzTotem:SetAllPoints()
			blizzTotem:SetAlpha(0)
			totem.__owner = blizzTotem
		end

		totem:SetSize(iconSize, iconSize)
		totem:ClearAllPoints()
		if i == 1 then
			totem:SetPoint("BOTTOMLEFT", margin, margin)
		elseif vertical then
			totem:SetPoint("BOTTOM", totems[i-1], "TOP", 0, margin)
		else
			totem:SetPoint("LEFT", totems[i-1], "RIGHT", margin, 0)
		end
	end
end

function Module:TotemBar_Update()
	for i = 1, 4 do
		local totem = totems[i]
		local defaultTotem = totem.__owner
		local slot = defaultTotem.slot

		local haveTotem, _, start, dur, icon = GetTotemInfo(slot)
		if haveTotem and dur > 0 then
			totem.Icon:SetTexture(icon)
			totem.CD:SetCooldown(start, dur)
			totem.CD:Show()
			totem:SetAlpha(1)
		else
			totem.Icon:SetTexture("")
			totem.CD:Hide()
			totem:SetAlpha(0)
		end
	end
end

function Module:CreateTotems()
	if not C["Auras"].Totems then
		return
	end

	Module:TotemBar_Init()
	K:RegisterEvent("PLAYER_ENTERING_WORLD", Module.TotemBar_Update)
	K:RegisterEvent("PLAYER_TOTEM_UPDATE", Module.TotemBar_Update)
end