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
	}

	QueueStatusFrame:StripTextures()

	for i = 1, #Skins do
		_G[Skins[i]]:StripTextures()
		_G[Skins[i]].Background = _G[Skins[i]]:CreateTexture(nil, "BACKGROUND", -1)
		_G[Skins[i]].Background:SetAllPoints()
		_G[Skins[i]].Background:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

		_G[Skins[i]].Borders = CreateFrame("Frame", nil, _G[Skins[i]])
		_G[Skins[i]].Borders:SetAllPoints(_G[Skins[i]])
		K.CreateBorder(_G[Skins[i]].Borders)
		_G[Skins[i]].Borders:SetBorderColor()
	end

	hooksecurefunc("UIDropDownMenu_CreateFrames", function()
		if not _G["DropDownList"..UIDROPDOWNMENU_MAXLEVELS.."Backdrop"].isSkinned then
			_G["DropDownList"..UIDROPDOWNMENU_MAXLEVELS.."Backdrop"]:StripTextures()
			_G["DropDownList"..UIDROPDOWNMENU_MAXLEVELS.."Backdrop"].Background = _G["DropDownList"..UIDROPDOWNMENU_MAXLEVELS.."Backdrop"]:CreateTexture(nil, "BACKGROUND", -1)
			_G["DropDownList"..UIDROPDOWNMENU_MAXLEVELS.."Backdrop"].Background:SetAllPoints()
			_G["DropDownList"..UIDROPDOWNMENU_MAXLEVELS.."Backdrop"].Background:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

			_G["DropDownList"..UIDROPDOWNMENU_MAXLEVELS.."Backdrop"].Borders = CreateFrame("Frame", nil, _G["DropDownList"..UIDROPDOWNMENU_MAXLEVELS.."Backdrop"])
			_G["DropDownList"..UIDROPDOWNMENU_MAXLEVELS.."Backdrop"].Borders:SetAllPoints(_G["DropDownList"..UIDROPDOWNMENU_MAXLEVELS.."Backdrop"])
			K.CreateBorder(_G["DropDownList"..UIDROPDOWNMENU_MAXLEVELS.."Backdrop"].Borders)
			_G["DropDownList"..UIDROPDOWNMENU_MAXLEVELS.."Backdrop"].Borders:SetBorderColor()

			_G["DropDownList"..UIDROPDOWNMENU_MAXLEVELS.."MenuBackdrop"]:StripTextures()
			_G["DropDownList"..UIDROPDOWNMENU_MAXLEVELS.."MenuBackdrop"].Background = _G["DropDownList"..UIDROPDOWNMENU_MAXLEVELS.."MenuBackdrop"]:CreateTexture(nil, "BACKGROUND", -1)
			_G["DropDownList"..UIDROPDOWNMENU_MAXLEVELS.."MenuBackdrop"].Background:SetAllPoints()
			_G["DropDownList"..UIDROPDOWNMENU_MAXLEVELS.."MenuBackdrop"].Background:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

			_G["DropDownList"..UIDROPDOWNMENU_MAXLEVELS.."MenuBackdrop"].Borders = CreateFrame("Frame", nil, _G["DropDownList"..UIDROPDOWNMENU_MAXLEVELS.."MenuBackdrop"])
			_G["DropDownList"..UIDROPDOWNMENU_MAXLEVELS.."MenuBackdrop"].Borders:SetAllPoints(_G["DropDownList"..UIDROPDOWNMENU_MAXLEVELS.."MenuBackdrop"])
			K.CreateBorder(_G["DropDownList"..UIDROPDOWNMENU_MAXLEVELS.."MenuBackdrop"].Borders)
			_G["DropDownList"..UIDROPDOWNMENU_MAXLEVELS.."MenuBackdrop"].Borders:SetBorderColor()

			_G["DropDownList"..UIDROPDOWNMENU_MAXLEVELS.."Backdrop"].isSkinned = true
		end
	end)

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
				self.Background = self:CreateTexture(nil, "BACKGROUND", -1)
				self.Background:SetAllPoints()
				self.Background:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

				self.Borders = CreateFrame("Frame", nil, self)
				self.Borders:SetAllPoints(self)
				K.CreateBorder(self.Borders)
				self.Borders:SetBorderColor()

				self:ClearAllPoints()
				self:SetPoint("BOTTOMRIGHT", ChatFrame1, "BOTTOMRIGHT", 0, 30)
			end)
		else
			_G[ChatMenus[i]]:HookScript("OnShow", function(self)
				self:StripTextures()
				self.Background = self:CreateTexture(nil, "BACKGROUND", -1)
				self.Background:SetAllPoints()
				self.Background:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

				self.Borders = CreateFrame("Frame", nil, self)
				self.Borders:SetAllPoints(self)
				K.CreateBorder(self.Borders)
				self.Borders:SetBorderColor()
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
		GhostFrame:SetPoint("TOP", UIParent, "TOP", 0, -150)
		GhostFrameContentsFrameText:SetPoint("TOPLEFT", 53, 0)
		GhostFrameContentsFrameIcon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		GhostFrameContentsFrameIcon:SetPoint("RIGHT", GhostFrameContentsFrameText, "LEFT", -12, 0)
		local b = CreateFrame("Frame", nil, GhostFrameContentsFrameIcon:GetParent())
		b:SetAllPoints(GhostFrameContentsFrameIcon)
		GhostFrameContentsFrameIcon:SetSize(37, 38)
		GhostFrameContentsFrameIcon:SetParent(b)

		b.Background = b:CreateTexture(nil, "BACKGROUND", -1)
		b.Background:SetAllPoints()
		b.Background:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

		b.Borders = CreateFrame("Frame", nil, b)
		b.Borders:SetAllPoints(b)
		K.CreateBorder(b.Borders)
		b.Borders:SetBorderColor()
	end
end

table_insert(Module.SkinFuncs["KkthnxUI"], SkinMiscStuff)