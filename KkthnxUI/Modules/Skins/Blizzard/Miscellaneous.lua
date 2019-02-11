local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local _G = _G

local table_insert = table.insert

local CreateFrame = _G.CreateFrame
local hooksecurefunc = _G.hooksecurefunc
local UIDROPDOWNMENU_MAXLEVELS = _G.UIDROPDOWNMENU_MAXLEVELS
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

	hooksecurefunc("UIDropDownMenu_CreateFrames", function(level, index)
		local listFrame = _G["DropDownList"..level]
		local listFrameName = listFrame:GetName()

		-- Skin the backdrop
		for i = 1, _G.UIDROPDOWNMENU_MAXLEVELS do
			local menu = _G["DropDownList"..i.."MenuBackdrop"]
			local backdrop = _G["DropDownList"..i.."Backdrop"]
			if not backdrop.IsSkinned then
				backdrop:CreateBorder(nil, nil, nil, true)
				menu:CreateBorder(nil, nil, nil, true)

				backdrop.IsSkinned = true
			end
		end
	end)
end

table_insert(Module.SkinFuncs["KkthnxUI"], SkinMiscStuff)