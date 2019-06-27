local K = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local _G = _G

local table_insert = table.insert

local CreateFrame = _G.CreateFrame
local hooksecurefunc = _G.hooksecurefunc
local UIParent = _G.UIParent

local function SkinMiscStuff()
	if K.CheckAddOnState("Skinner") or K.CheckAddOnState("Aurora") then
		return
	end

	local Skins = {
		"QueueStatusFrame",
		"DropDownList1Backdrop",
		"DropDownList1MenuBackdrop",
		"TicketStatusFrameButton"
	}

	for i = 1, #Skins do
		_G[Skins[i]]:CreateBorder(nil, nil, nil, true)
	end

	local ChatMenus = {
		"ChatMenu",
		"EmoteMenu",
		"LanguageMenu",
		"VoiceMacroMenu"
	}

	for i = 1, #ChatMenus do
		if _G[ChatMenus[i]] == _G["ChatMenu"] then
			_G[ChatMenus[i]]:HookScript("OnShow", function(self)
				self:StripTextures()
				self:CreateBorder()

				self:ClearAllPoints()
				self:SetPoint("BOTTOMRIGHT", ChatFrame1, "BOTTOMRIGHT", 0, 30)
			end)
		else
			_G[ChatMenus[i]]:HookScript("OnShow", function(self)
				self:StripTextures()
				self:CreateBorder()
			end)
		end
	end

	do
		GhostFrameMiddle:SetAlpha(0)
		GhostFrameRight:SetAlpha(0)
		GhostFrameLeft:SetAlpha(0)
		GhostFrame:StripTextures(true)
		GhostFrame:SkinButton()
		GhostFrame:ClearAllPoints()
		GhostFrame:SetPoint("TOP", UIParent, "TOP", 0, -260)
		GhostFrameContentsFrameText:SetPoint("TOPLEFT", 53, 0)
		GhostFrameContentsFrameIcon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		GhostFrameContentsFrameIcon:SetPoint("RIGHT", GhostFrameContentsFrameText, "LEFT", -12, 0)
		local b = CreateFrame("Frame", nil, GhostFrameContentsFrameIcon:GetParent())
		b:SetAllPoints(GhostFrameContentsFrameIcon)
		GhostFrameContentsFrameIcon:SetSize(37, 38)
		GhostFrameContentsFrameIcon:SetParent(b)
		b:CreateBorder()
	end

	local TalentMicroButtonAlert = _G.TalentMicroButtonAlert
	if TalentMicroButtonAlert then -- why do we need to check this?
		TalentMicroButtonAlert:ClearAllPoints()
		TalentMicroButtonAlert:SetPoint("CENTER", UIParent, "TOP", 0, -75)
		TalentMicroButtonAlert.Arrow:Hide()
		TalentMicroButtonAlert.Text:FontTemplate()
		TalentMicroButtonAlert:CreateBorder(nil, nil, nil, true)
		TalentMicroButtonAlert:SetBackdropBorderColor(255/255, 255/255, 0/255)
		TalentMicroButtonAlert.CloseButton:SetPoint("TOPRIGHT", 4, 4)
		TalentMicroButtonAlert.CloseButton:SkinCloseButton()

		TalentMicroButtonAlert.tex = TalentMicroButtonAlert:CreateTexture(nil, "OVERLAY", 7)
		TalentMicroButtonAlert.tex:SetPoint("TOP", 0, -2)
		TalentMicroButtonAlert.tex:SetTexture("Interface\\DialogFrame\\UI-Dialog-Icon-AlertNew")
		TalentMicroButtonAlert.tex:SetSize(22, 22)
	end

	local CharacterMicroButtonAlert = _G.CharacterMicroButtonAlert
	if CharacterMicroButtonAlert then -- why do we need to check this?
		CharacterMicroButtonAlert.Arrow:Hide()
		CharacterMicroButtonAlert.Text:FontTemplate()
		CharacterMicroButtonAlert:CreateBorder(nil, nil, nil, true)
		CharacterMicroButtonAlert:SetBackdropBorderColor(255/255, 255/255, 0/255)
		CharacterMicroButtonAlert.CloseButton:SetPoint("TOPRIGHT", 4, 4)
		CharacterMicroButtonAlert.CloseButton:SkinCloseButton()

		CharacterMicroButtonAlert.tex = CharacterMicroButtonAlert:CreateTexture(nil, "OVERLAY", 7)
		CharacterMicroButtonAlert.tex:SetPoint("TOP", 0, -2)
		CharacterMicroButtonAlert.tex:SetTexture("Interface\\DialogFrame\\UI-Dialog-Icon-AlertNew")
		CharacterMicroButtonAlert.tex:SetSize(22, 22)
	end

	hooksecurefunc("UIDropDownMenu_CreateFrames", function(level, index)
		local listFrame = _G["DropDownList"..level]
		local listFrameName = listFrame:GetName()

		_G[listFrameName.."MenuBackdrop"]:CreateBorder(nil, nil, nil, true)
	end)
end

-- We will just lay this out in here for addons that need to be loaded before the code can run.
local function KillTalentTutorials()
	_G.PlayerTalentFrameSpecializationTutorialButton:Kill()
	_G.PlayerTalentFrameTalentsTutorialButton:Kill()
	_G.PlayerTalentFramePetSpecializationTutorialButton:Kill()
end

table_insert(Module.SkinFuncs["KkthnxUI"], SkinMiscStuff)
Module.SkinFuncs["Blizzard_TalentUI"] = KillTalentTutorials