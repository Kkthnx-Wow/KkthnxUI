local K, C, L = unpack(select(2, ...))

local _G = _G

-- Lua API
local table_insert = table.insert
local getn = getn

local function LoadSkin()
	if K.CheckAddOnState("Skinner") or K.CheckAddOnState("Aurora") then return end

	local Skins = {
		"QueueStatusFrame",
		"DropDownList1Backdrop",
		"DropDownList1MenuBackdrop",

		-- DropDownMenu library support
		"L_DropDownList1Backdrop",
		"L_DropDownList1MenuBackdrop"
	}

	QueueStatusFrame:StripTextures()

	for i = 1, getn(Skins) do
		_G[Skins[i]]:SetTemplate("Transparent", true)
	end

	-- DropDownMenu
	_G.hooksecurefunc("UIDropDownMenu_CreateFrames", function(level, index)
		if not _G["DropDownList"..UIDROPDOWNMENU_MAXLEVELS.."Backdrop"].template then
			_G["DropDownList"..UIDROPDOWNMENU_MAXLEVELS.."Backdrop"]:SetTemplate("Transparent", true)
			_G["DropDownList"..UIDROPDOWNMENU_MAXLEVELS.."MenuBackdrop"]:SetTemplate("Transparent", true)
		end
	end)

	-- LibUIDropDownMenu
	_G.hooksecurefunc("L_UIDropDownMenu_CreateFrames", function(level, index)
		if not _G["L_DropDownList"..L_UIDROPDOWNMENU_MAXLEVELS.."Backdrop"].template then
			_G["L_DropDownList"..L_UIDROPDOWNMENU_MAXLEVELS.."Backdrop"]:SetTemplate("Transparent", true)
			_G["L_DropDownList"..L_UIDROPDOWNMENU_MAXLEVELS.."MenuBackdrop"]:SetTemplate("Transparent", true)
		end
	end)

	-- Reskin menu
	local ChatMenus = {
		"ChatMenu",
		"EmoteMenu",
		"LanguageMenu",
		"VoiceMacroMenu"
	}

	for i = 1, getn(ChatMenus) do
		if _G[ChatMenus[i]] == _G["ChatMenu"] then
			_G[ChatMenus[i]]:HookScript("OnShow", function(self)
				self:SetTemplate("Transparent", true)
				self:ClearAllPoints()
				self:SetPoint("BOTTOMRIGHT", ChatFrame1, "BOTTOMRIGHT", 0, 30)
			end)
		else
			_G[ChatMenus[i]]:HookScript("OnShow", function(self)
				self:SetTemplate("Transparent", true)
			end)
		end
	end

	-- skin return to graveyard button
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
		b:SetTemplate("", true)
	end
end

tinsert(K.SkinFuncs["KkthnxUI"], LoadSkin)