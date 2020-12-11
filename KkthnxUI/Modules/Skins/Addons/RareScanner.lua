local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

function Module:ReskinRareScanner()
	if not IsAddOnLoaded("RareScanner") then
		return
	end

	if not C["Skins"].RareScanner then
		return
	end

	-- Scanner Button
	local button = _G.scanner_button
	button:StripTextures()
	button:SkinButton()

	local close = button.CloseButton
	close:SkinCloseButton()
	close:SetHitRectInsets(0, 0, 0, 0)
	close:SetScale(1)
	close:ClearAllPoints()
	close:SetPoint("BOTTOMRIGHT",-5, 5)

	K.ReskinArrow(button.FilterDisabledButton, "up")
	K.ReskinArrow(button.FilterEnabledButton, "down")

	-- TT.ReskinTooltip(button.LootBar.LootBarToolTipComp1)
	-- TT.ReskinTooltip(button.LootBar.LootBarToolTipComp2)

	-- RSLoot
	hooksecurefunc(button, "LoadLootBar", function(self)
		for itemFrame in self.LootBar.itemFramesPool:EnumerateActive() do
			if not itemFrame.styled then
				itemFrame.Icon:SetTexCoord(unpack(K.TexCoords))
				itemFrame.Icon.bg = CreateFrame("Frame", nil, itemFrame)
				itemFrame.Icon.bg:SetAllPoints(itemFrame.Icon)
				itemFrame.Icon.bg:SetFrameLevel(itemFrame:GetFrameLevel())
				itemFrame.Icon.bg:CreateBorder()

				itemFrame.HL = itemFrame:CreateTexture(nil, "HIGHLIGHT")
				itemFrame.HL:SetColorTexture(1, 1, 1, .25)
				itemFrame.HL:SetAllPoints(itemFrame.Icon)

				itemFrame.styled = true
			end
		end
	end)

	-- RSSearch
	for _, frame in ipairs(WorldMapFrame.overlayFrames) do
		local numChildren = frame:GetNumChildren()
		if frame:GetObjectType() == "Frame" and numChildren == 1 and frame.EditBox then
			frame:ClearAllPoints()
			frame:SetPoint("TOP", WorldMapFrame:GetCanvasContainer(), "TOP", 0, 0)
			frame.EditBox:DisableDrawLayer("BACKGROUND")
			--frame.EditBox:CreateBorder()
			break
		end
	end
end