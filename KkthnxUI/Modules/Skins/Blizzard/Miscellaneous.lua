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

	-- local Skins = {
	-- 	"QueueStatusFrame",
	-- 	"DropDownList1Backdrop",
	-- 	"DropDownList1MenuBackdrop",
	-- 	"TicketStatusFrameButton"
	-- }

	-- for i = 1, #Skins do
	-- 	_G[Skins[i]]:CreateBorder(nil, nil, nil, true)
	-- end

	-- local ChatMenus = {
	-- 	"ChatMenu",
	-- 	"EmoteMenu",
	-- 	"LanguageMenu",
	-- 	"VoiceMacroMenu"
	-- }

	-- for i = 1, #ChatMenus do
	-- 	if _G[ChatMenus[i]] == _G["ChatMenu"] then
	-- 		_G[ChatMenus[i]]:HookScript("OnShow", function(self)
	-- 			self:StripTextures()
	-- 			self:CreateBorder()

	-- 			self:ClearAllPoints()
	-- 			self:SetPoint("BOTTOMRIGHT", ChatFrame1, "BOTTOMRIGHT", 0, 30)
	-- 		end)
	-- 	else
	-- 		_G[ChatMenus[i]]:HookScript("OnShow", function(self)
	-- 			self:StripTextures()
	-- 			self:CreateBorder()
	-- 		end)
	-- 	end
	-- end

	do
		_G.GhostFrameMiddle:SetAlpha(0)
		_G.GhostFrameRight:SetAlpha(0)
		_G.GhostFrameLeft:SetAlpha(0)
		_G.GhostFrame:StripTextures(true)
		_G.GhostFrame:SkinButton()
		_G.GhostFrame:ClearAllPoints()
		_G.GhostFrame:SetPoint("TOP", UIParent, "TOP", 0, -40)
		_G.GhostFrameContentsFrameText:SetPoint("TOPLEFT", 53, 0)
		_G.GhostFrameContentsFrameIcon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		_G.GhostFrameContentsFrameIcon:SetPoint("RIGHT", _G.GhostFrameContentsFrameText, "LEFT", -12, 0)
		local b = CreateFrame("Frame", nil, _G.GhostFrameContentsFrameIcon:GetParent())
		b:SetAllPoints(_G.GhostFrameContentsFrameIcon)
		_G.GhostFrameContentsFrameIcon:SetSize(37, 38)
		_G.GhostFrameContentsFrameIcon:SetParent(b)
		b:CreateBorder()
	end

	-- hooksecurefunc("UIDropDownMenu_CreateFrames", function(level)
	-- 	local listFrame = _G["DropDownList"..level]
	-- 	local listFrameName = listFrame:GetName()

	-- 	_G[listFrameName.."MenuBackdrop"]:CreateBorder(nil, nil, nil, true)
	-- end)

	if _G.IsAddOnLoaded("Blizzard_TalentUI") then
		_G.PlayerTalentFrameSpecializationTutorialButton:Kill()
		_G.PlayerTalentFrameTalentsTutorialButton:Kill()
		_G.PlayerTalentFramePetSpecializationTutorialButton:Kill()
	end

	_G.SpellBookFrameTutorialButton:Kill()
	_G.HelpOpenTicketButtonTutorial:Kill()
	_G.HelpPlate:Kill()
	_G.HelpPlateTooltip:Kill()

	_G.WorldMapFrame.BorderFrame.Tutorial:Kill()

	if _G.IsAddOnLoaded("Blizzard_Collections") then
		_G.PetJournalTutorialButton:Kill()
	end

	_G.CollectionsMicroButtonAlert:UnregisterAllEvents()
	_G.CollectionsMicroButtonAlert:SetParent(K.UIFrameHider)
	_G.CollectionsMicroButtonAlert:Hide()

	_G.EJMicroButtonAlert:UnregisterAllEvents()
	_G.EJMicroButtonAlert:SetParent(K.UIFrameHider)
	_G.EJMicroButtonAlert:Hide()

	_G.LFDMicroButtonAlert:UnregisterAllEvents()
	_G.LFDMicroButtonAlert:SetParent(K.UIFrameHider)
	_G.LFDMicroButtonAlert:Hide()

	_G.TutorialFrameAlertButton:UnregisterAllEvents()
	_G.TutorialFrameAlertButton:Hide()

	_G.TalentMicroButtonAlert:UnregisterAllEvents()
	_G.TalentMicroButtonAlert:SetParent(K.UIFrameHider)
end

table_insert(Module.NewSkin["KkthnxUI"], SkinMiscStuff)