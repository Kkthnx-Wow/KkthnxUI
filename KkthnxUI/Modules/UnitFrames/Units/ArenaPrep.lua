local K, C = unpack(select(2, ...))
local Module = K:GetModule("Unitframes")

local oUF = oUF or K.oUF
assert(oUF, "KkthnxUI was unable to locate oUF.")

local _G = _G

local CreateFrame = _G.CreateFrame
local GetArenaOpponentSpec = _G.GetArenaOpponentSpec
local GetSpecializationInfoByID = _G.GetSpecializationInfoByID
local LOCALIZED_CLASS_NAMES_MALE = _G.LOCALIZED_CLASS_NAMES_MALE
local GetNumArenaOpponentSpecs = _G.GetNumArenaOpponentSpecs

function Module:CreateArenaPreparation()
	local HealthTexture = K.GetTexture(C["Arena"].Texture)
	local Font = K.GetFont(C["Arena"].Font)
	local ArenaPreparation = {}

	for i = 1, 5 do
		local arenaFrame = self.Arena[i]

		ArenaPreparation[i] = CreateFrame("Frame", self:GetName().."PreparationFrame", _G.UIParent)
		ArenaPreparation[i]:SetAllPoints(arenaFrame)
		ArenaPreparation[i]:SetScript("OnEvent", Module.ShowHideArenaPreparation)

		ArenaPreparation[i].Health = CreateFrame("StatusBar", nil, ArenaPreparation[i])
		ArenaPreparation[i].Health:SetAllPoints()
		ArenaPreparation[i].Health:SetStatusBarTexture(HealthTexture)
		ArenaPreparation[i].Health:CreateBorder()

		ArenaPreparation[i].Icon = ArenaPreparation[i]:CreateTexture(nil, "OVERLAY")
		ArenaPreparation[i].Icon.Background = CreateFrame("Frame", nil, ArenaPreparation[i])
		ArenaPreparation[i].Icon.Background:SetSize(52, 52)
		ArenaPreparation[i].Icon.Background:SetPoint("RIGHT", ArenaPreparation[i], "LEFT", -6, 0)
		ArenaPreparation[i].Icon.Background:CreateBorder()
		ArenaPreparation[i].Icon:SetParent(ArenaPreparation[i].Icon.Background)
		ArenaPreparation[i].Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		ArenaPreparation[i].Icon:SetInside(ArenaPreparation[i].Icon.Background)

		ArenaPreparation[i].SpecClass = ArenaPreparation[i].Health:CreateFontString(nil, "OVERLAY")
		ArenaPreparation[i].SpecClass:SetFontObject(Font)
		ArenaPreparation[i].SpecClass:SetPoint("CENTER")

		ArenaPreparation[i]:Hide()
		ArenaPreparation[i].Name:Hide()
		ArenaPreparation[i].Health.Value:Hide()

		ArenaPreparation[i]:RegisterEvent("PLAYER_ENTERING_WORLD")
		ArenaPreparation[i]:RegisterEvent("ARENA_OPPONENT_UPDATE")
		ArenaPreparation[i]:RegisterEvent("ARENA_PREP_OPPONENT_SPECIALIZATIONS")
	end

	Module.ArenaPreparation = ArenaPreparation
end

function Module:HideArenaPreparation()
	for i = 1, 5 do
		local prepFrame = Module.ArenaPreparation[i]
		prepFrame:Hide()
	end
end

function Module:ShowArenaPreparation()
	local numOpps = GetNumArenaOpponentSpecs()

	for i = 1, 5 do
		local prepFrame = Module.ArenaPreparation[i]

		if (i <= numOpps) then
			local specID = GetArenaOpponentSpec(i)

			if (specID and specID > 0) then
				local _, spec, _, texture, _, class = GetSpecializationInfoByID(specID)

				if (class) then
					local color = Module.Arena[i].colors.class[class]

					prepFrame.SpecClass:SetText(spec.." - "..LOCALIZED_CLASS_NAMES_MALE[class])
					prepFrame.Health:SetStatusBarColor(color[1], color[2], color[3])
					prepFrame.Icon:SetTexture(texture or [[INTERFACE\ICONS\INV_MISC_QUESTIONMARK]])
				else
					prepFrame.Health:SetStatusBarColor(0.2, 0.2, 0.2, 1)
				end

				prepFrame:Show()
			else
				prepFrame:Hide()
			end
		else
			prepFrame:Hide()
		end
	end
end

function Module:ShowHideArenaPreparation(event)
	if (event == "ARENA_OPPONENT_UPDATE") then
		Module:HideArenaPreparation()
	else
		Module:ShowArenaPreparation()
	end
end