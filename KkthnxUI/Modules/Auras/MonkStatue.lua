local K, C = unpack(select(2, ...))
local A = K:GetModule("Auras")

-- Monk Statue
local bu
local function StatueGo()
	if bu then
		bu:Show()
		return
	end

	bu = CreateFrame("Button", nil, UIParent, "SecureActionButtonTemplate")
	bu:SetSize(30, 30)

    bu.CD = CreateFrame("Cooldown", nil, bu, "CooldownFrameTemplate")
	bu.CD:SetAllPoints()
	bu.CD:SetReverse(true)

	bu.Icon = bu:CreateTexture(nil, "ARTWORK")
	bu.Icon:SetAllPoints()
	bu.Icon:SetTexCoord(unpack(K.TexCoords))
	bu:CreateBorder()

	bu:RegisterForClicks("AnyUp")
	bu:SetAttribute("type1", "macro")
	bu:SetAttribute("type2", "macro")
	bu:SetAttribute("macrotext2", "/click TotemFrameTotem1 RightButton")
	bu:SetScript("OnEnter", function(self)
		if self:GetAlpha() < 1 then
			return
		end

		GameTooltip:SetOwner(self, "ANCHOR_LEFT")
		GameTooltip:ClearLines()
		GameTooltip:SetTotem(1)
		GameTooltip:Show()
	end)
	bu:SetScript("OnLeave", K.HideTooltip)

	K.Mover(bu, "Statue", "Statue", {"TOPRIGHT", UIParent, "BOTTOM", -460, 300}, 30, 30)
end

-- localizaed
local serpentStatue = GetSpellInfo(115313)
local serpentStatueTex = GetSpellTexture(115313)
local oxStatue = GetSpellInfo(115315)
local oxStatueTex = GetSpellTexture(115315)

function A:UpdateStatue()
	local haveTotem, _, start, dur = GetTotemInfo(1)
	if haveTotem then
		bu.CD:SetCooldown(start, dur)
		bu.CD:Show()
		bu:SetAlpha(1)
	else
		bu.CD:Hide()
		bu:SetAlpha(.3)
	end
end

local function checkSpec(event)
	if (GetSpecialization() == 2 and IsPlayerSpell(115313)) or (GetSpecialization() == 1 and IsPlayerSpell(115315)) then
		StatueGo()
		bu:SetAlpha(0.3)
		bu.CD:Hide()

		local statue
		if IsPlayerSpell(115313) then
			bu.Icon:SetTexture(serpentStatueTex)
			statue = serpentStatue
		else
			bu.Icon:SetTexture(oxStatueTex)
			statue = oxStatue
		end

		bu:SetAttribute("macrotext1", "/tar "..statue)
		K:RegisterEvent("PLAYER_TOTEM_UPDATE", A.UpdateStatue)
	else
		if bu then
			bu:Hide()
		end
		K:UnregisterEvent("PLAYER_TOTEM_UPDATE", A.UpdateStatue)
	end

	if event == "PLAYER_ENTERING_WORLD" then
		K:UnregisterEvent(event, checkSpec)
	end
end

function A:CreateMonkStatue()
	if not C["Auras"].Statue then
		return
	end

	K:RegisterEvent("PLAYER_ENTERING_WORLD", checkSpec)
	K:RegisterEvent("PLAYER_TALENT_UPDATE", checkSpec)
end