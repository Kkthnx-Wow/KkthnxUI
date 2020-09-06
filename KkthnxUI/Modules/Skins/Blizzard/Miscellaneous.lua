local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local _G = _G
local table_insert = _G.table.insert

local hooksecurefunc = _G.hooksecurefunc

local function SkinMiscStuff()
	-- do
	-- 	for i = 1, 4 do
	-- 		local frame = _G["StaticPopup"..i]
	-- 		local bu = _G["StaticPopup"..i.."ItemFrame"]
	-- 		local close = _G["StaticPopup"..i.."CloseButton"]

	-- 		local gold = _G["StaticPopup"..i.."MoneyInputFrameGold"]
	-- 		local silver = _G["StaticPopup"..i.."MoneyInputFrameSilver"]
	-- 		local copper = _G["StaticPopup"..i.."MoneyInputFrameCopper"]

	-- 		_G["StaticPopup"..i.."ItemFrameNameFrame"]:Hide()
	-- 		_G["StaticPopup"..i.."ItemFrameIconTexture"]:SetTexCoord(unpack(K.TexCoords))

	-- 		bu:SetNormalTexture("")
	-- 		bu:SetHighlightTexture("")
	-- 		bu:SetPushedTexture("")
	-- 		bu:CreateBorder()
	-- 		bu.IconBorder:SetAlpha(0)
	-- 		frame["Border"]:Hide()

	-- 		silver:SetPoint("LEFT", gold, "RIGHT", 6, 0)
	-- 		copper:SetPoint("LEFT", silver, "RIGHT", 6, 0)

	-- 		frame:CreateBorder()
	-- 		for j = 1, 4 do
	-- 			frame["button"..j]:SkinButton()
	-- 		end
	-- 		frame["extraButton"]:SkinButton()
	-- 		close:SkinCloseButton()

	-- 		Module:SkinEditBox(_G["StaticPopup"..i.."EditBox"], 20)
	-- 		Module:SkinEditBox(gold)
	-- 		Module:SkinEditBox(silver)
	-- 		Module:SkinEditBox(copper)
	-- 	end

	-- 	hooksecurefunc("StaticPopup_Show", function(which, _, _, data)
	-- 		local info = StaticPopupDialogs[which]

	-- 		if not info then return end

	-- 		local dialog = nil
	-- 		dialog = StaticPopup_FindVisible(which, data)

	-- 		if not dialog then
	-- 			local index = 1
	-- 			if info.preferredIndex then
	-- 				index = info.preferredIndex
	-- 			end

	-- 			for i = index, STATICPOPUP_NUMDIALOGS do
	-- 				local frame = _G["StaticPopup"..i]
	-- 				if not frame:IsShown() then
	-- 					dialog = frame
	-- 					break
	-- 				end
	-- 			end

	-- 			if not dialog and info.preferredIndex then
	-- 				for i = 1, info.preferredIndex do
	-- 					local frame = _G["StaticPopup"..i]
	-- 					if not frame:IsShown() then
	-- 						dialog = frame
	-- 						break
	-- 					end
	-- 				end
	-- 			end
	-- 		end

	-- 		if not dialog then
	-- 			return
	-- 		end

	-- 		if info.closeButton then
	-- 			local closeButton = _G[dialog:GetName().."CloseButton"]

	-- 			closeButton:SetNormalTexture("")
	-- 			closeButton:SetPushedTexture("")

	-- 			if info.closeButtonIsHide then
	-- 				for _, pixel in pairs(closeButton.pixels) do
	-- 					pixel:Hide()
	-- 				end

	-- 				closeButton.minimize:Show()
	-- 			else
	-- 				for _, pixel in pairs(closeButton.pixels) do
	-- 					pixel:Show()
	-- 				end

	-- 				closeButton.minimize:Hide()
	-- 			end
	-- 		end
	-- 	end)

	-- 	-- Pet battle queue popup
	-- 	PetBattleQueueReadyFrame:CreateBorder()
	-- 	-- PetBattleQueueReadyFrame.Art:CreateBorder()
	-- 	PetBattleQueueReadyFrame.Border:Hide()
	-- 	PetBattleQueueReadyFrame.AcceptButton:SkinButton()
	-- 	PetBattleQueueReadyFrame.DeclineButton:SkinButton()

	-- 	-- PlayerReportFrame
	-- 	PlayerReportFrame:HookScript("OnShow", function(self)
	-- 		if not self.styled then
	-- 			self:StripTextures()
	-- 			self:CreateBorder()
	-- 			self.Comment:StripTextures()
	-- 			Module:SkinEditBox(self.Comment)
	-- 			self.ReportButton:SkinButton()
	-- 			self.CancelButton:SkinButton()

	-- 			self.styled = true
	-- 		end
	-- 	end)
	-- end

	do
		for i = 1, 6 do
			select(i, GhostFrame:GetRegions()):Hide()
		end

		GhostFrameContentsFrameIcon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

		local FrameIconBorderFrame = CreateFrame("Frame", nil, GhostFrameContentsFrameIcon:GetParent())
		FrameIconBorderFrame:SetAllPoints(GhostFrameContentsFrameIcon)
		FrameIconBorderFrame:SetFrameLevel(GhostFrame:GetFrameLevel() + 1)
		FrameIconBorderFrame:CreateBorder()

		GhostFrame:SkinButton()
	end
end

table_insert(Module.NewSkin["KkthnxUI"], SkinMiscStuff)