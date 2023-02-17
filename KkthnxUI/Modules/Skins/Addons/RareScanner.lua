local K, C = KkthnxUI[1], KkthnxUI[2]
local Module = K:GetModule("Skins")
local Tooltip = K:GetModule("Tooltip")

-- Function to skin the RareScanner addon
function Module:ReskinRareScanner()
	-- Check if RareScanner is loaded
	if not IsAddOnLoaded("RareScanner") then
		return
	end

	-- Check if the RareScanner skin is enabled
	if not C["Skins"].RareScanner then
		return
	end

	-- Check if the scanner button exists and has a ModelView component
	local scannerButton = _G["scanner_button"]
	if not scannerButton or not scannerButton.ModelView then
		return
	end

	-- Remove OnEnter and OnLeave scripts from the scanner button
	scannerButton:SetScript("OnEnter", nil)
	scannerButton:SetScript("OnLeave", nil)

	-- Check if scanner button's CloseButton exists
	if scannerButton.CloseButton then
		-- Apply skin to the close button
		scannerButton.CloseButton:SkinCloseButton()
		-- Reposition the close button to top right with offset of -3, -3
		scannerButton.CloseButton:ClearAllPoints()
		scannerButton.CloseButton:SetPoint("TOPRIGHT", -3, -3)
	end

	-- Check if scanner button's FilterEntityButton exists
	if scannerButton.FilterEntityButton then
		-- Apply skin to the FilterEntityButton
		scannerButton.FilterEntityButton:SkinButton()
		-- Set normal and pushed texture to the FilterEntityButton
		scannerButton.FilterEntityButton:SetNormalTexture([[Interface\WorldMap\Dash_64Grey]], true)
		scannerButton.FilterEntityButton:SetPushedTexture([[Interface\WorldMap\Dash_64Grey]], true)
		-- Reposition the FilterEntityButton to top left with offset of 5, -5
		scannerButton.FilterEntityButton:ClearAllPoints()
		scannerButton.FilterEntityButton:SetSize(16, 16)
		scannerButton.FilterEntityButton:SetPoint("TOPLEFT", scannerButton, "TOPLEFT", 5, -5)
	end

	-- Check if scanner button's UnfilterEnabledButton exists
	if scannerButton.UnfilterEnabledButton then
		-- Apply skin to the UnfilterEnabledButton
		scannerButton.UnfilterEnabledButton:SkinButton()
		-- Set normal and pushed texture to the UnfilterEnabledButton
		scannerButton.UnfilterEnabledButton:SetNormalTexture([[Interface\WorldMap\Skull_64]], true)
		scannerButton.UnfilterEnabledButton:GetNormalTexture():SetTexCoord(0, 0.5, 0, 0.5)
		scannerButton.UnfilterEnabledButton:SetPushedTexture([[Interface\WorldMap\Skull_64]], true)
		scannerButton.UnfilterEnabledButton:GetPushedTexture():SetTexCoord(0, 0.5, 0, 0.5)
	end

	-- Remove the default textures of the scannerButton frame
	scannerButton:StripTextures()

	-- Apply custom border to the scannerButton frame
	scannerButton:CreateBorder()

	-- Show the Center region of the scanner button if it exists
	if scannerButton.Center then
		scannerButton.Center:Show()
	end

	-- Iterate through all regions of the scanner button
	for _, region in pairs({ scannerButton:GetRegions() }) do
		-- Check if the region is a texture
		if region:GetObjectType() == "Texture" then
			-- Check if the texture is the title background
			if region:GetTexture() == 235408 then
				-- Remove the texture
				region:SetTexture(nil)
			end
		end
	end

	if scannerButton.LootBar then
		-- Check if the LootBarToolTip exists
		if scannerButton.LootBar.LootBarToolTip then
			-- Hook the Show function of the LootBarToolTip
			hooksecurefunc(scannerButton.LootBar.LootBarToolTip, "Show", function(self)
				-- Call the ReskinTooltip function for the LootBarToolTip
				Tooltip.ReskinTooltip(_G.LootBarToolTip)

				-- Check if LootBarToolTipComp1 exists and has a Show function
				if scannerButton.LootBar.LootBarToolTipComp1 and scannerButton.LootBar.LootBarToolTipComp1.Show then
					-- Call the ReskinTooltip function for the LootBarToolTipComp1
					Tooltip.ReskinTooltip(scannerButton.LootBar.LootBarToolTipComp1)
				end

				-- Check if LootBarToolTipComp2 exists and has a Show function
				if scannerButton.LootBar.LootBarToolTipComp2 and scannerButton.LootBar.LootBarToolTipComp2.Show then
					-- Call the ReskinTooltip function for the LootBarToolTipComp2
					Tooltip.ReskinTooltip(scannerButton.LootBar.LootBarToolTipComp2)
				end
			end)
		end

		-- Hook to the "Acquire" function of the itemFramesPool object
		hooksecurefunc(scannerButton.LootBar.itemFramesPool, "Acquire", function(pool)
			-- Loop through all the active buttons in the pool
			for button in pool:EnumerateActive() do
				-- Check if the button has not been skinned yet
				if not button.isSkinned then
					-- Get the texture object of the button's Icon
					local icon = button.Icon
					if icon and icon:GetObjectType() == "Texture" then
						-- Set the texture coordinate of the icon
						icon:SetTexCoord(unpack(K.TexCoords))
						-- Get the width of the icon and subtract 2
						local size = icon:GetWidth() - 2
						-- Set the size of the icon
						icon:SetSize(size, size)
						-- Create a backdrop for the button
						button:CreateBackdrop()
						-- Set the backdrop to cover the entire icon
						button.KKUI_Backdrop:SetAllPoints(icon)
						-- Mark the button as skinned
						button.isSkinned = true
					end
				end
			end
		end)
	end

	-- Loop through the children of WorldMapFrame
	for _, child in pairs({ _G.WorldMapFrame:GetChildren() }) do
		-- Check if the child is a frame and has an EditBox and a relativeFrame
		if child:GetObjectType() == "Frame" and child.EditBox and child.relativeFrame then
			-- Loop through the regions of the EditBox
			for _, region in pairs({ child.EditBox:GetRegions() }) do
				-- Check if the region is a texture
				if region:GetObjectType() == "Texture" then
					-- Remove the texture if it exists
					if region:GetTexture() then
						region:SetTexture(nil)
					end
				end
			end

			-- Create a border for the EditBox
			child.EditBox:CreateBorder()

			-- Set the EditBox to cover the entire child frame
			child.EditBox:ClearAllPoints()
			child.EditBox:SetAllPoints(child)

			-- Resize the child frame
			local width, height = child:GetSize()
			child:SetSize(width, floor(height * 0.62))

			-- Reposition the child frame
			child:ClearAllPoints()
			child:SetPoint("TOP", _G.WorldMapFrame.ScrollContainer, "TOP", 0, -5)

			-- End the loop
			break
		end
	end
end
