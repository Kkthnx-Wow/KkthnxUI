local K, C = unpack(select(2, ...))

local function LoadSkin()
	local slots = {
		"HeadSlot",
		"NeckSlot",
		"ShoulderSlot",
		"BackSlot",
		"ChestSlot",
		"ShirtSlot",
		"TabardSlot",
		"WristSlot",
		"HandsSlot",
		"WaistSlot",
		"LegsSlot",
		"FeetSlot",
		"Finger0Slot",
		"Finger1Slot",
		"Trinket0Slot",
		"Trinket1Slot",
		"MainHandSlot",
		"SecondaryHandSlot",
	}

	for _, slot in pairs(slots) do
		local icon = _G["Character"..slot.."IconTexture"]
		slot = _G["Character"..slot]
		slot:StripTextures()
		slot:StyleButton(false)
		slot.ignoreTexture:SetTexture([[Interface\PaperDollInfoFrame\UI-GearManager-LeaveItem-Transparent]])
		slot:SetTemplate("Transparent", true)
		icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		icon:SetAllPoints()

		hooksecurefunc(slot.IconBorder, "SetVertexColor", function(self, r, g, b)
			self:GetParent():SetBackdropBorderColor(r, g, b)
			self:SetTexture("")
		end)

		hooksecurefunc(slot.IconBorder, "Hide", function(self)
			self:GetParent():SetBackdropBorderColor(C["Media"].BorderColor[1], C["Media"].BorderColor[2], C["Media"].BorderColor[3])
		end)
	end

	CharacterLevelText:FontTemplate()
	CharacterStatsPane.ItemLevelFrame.Value:FontTemplate(nil, 20)

	local function ColorizeStatPane(frame)
		if (frame.leftGrad) then return end
		local r, g, b = 0.8, 0.8, 0.8
		frame.leftGrad = frame:CreateTexture(nil, "BORDER")
		frame.leftGrad:SetWidth(80)
		frame.leftGrad:SetHeight(frame:GetHeight())
		frame.leftGrad:SetPoint("LEFT", frame, "CENTER")
		frame.leftGrad:SetTexture(C["Media"].Blank)
		frame.leftGrad:SetGradientAlpha("Horizontal", r, g, b, 0.35, r, g, b, 0)

		frame.rightGrad = frame:CreateTexture(nil, "BORDER")
		frame.rightGrad:SetWidth(80)
		frame.rightGrad:SetHeight(frame:GetHeight())
		frame.rightGrad:SetPoint("RIGHT", frame, "CENTER")
		frame.rightGrad:SetTexture([[Interface\BUTTONS\WHITE8X8.blp]])
		frame.rightGrad:SetGradientAlpha("Horizontal", r, g, b, 0, r, g, b, 0.35)
	end
	CharacterStatsPane.ItemLevelFrame.Background:SetAlpha(0)
	ColorizeStatPane(CharacterStatsPane.ItemLevelFrame)

	hooksecurefunc("PaperDollFrame_UpdateStats", function()
		local level = UnitLevel("player")
		local categoryYOffset = -5
		local statYOffset = 0

		if (not IsAddOnLoaded("DejaCharacterStats")) then
			if (level >= MIN_PLAYER_LEVEL_FOR_ITEM_LEVEL_DISPLAY) then
				PaperDollFrame_SetItemLevel(CharacterStatsPane.ItemLevelFrame, "player")
				CharacterStatsPane.ItemLevelFrame.Value:SetTextColor(GetItemLevelColor())
				CharacterStatsPane.ItemLevelCategory:Show()
				CharacterStatsPane.ItemLevelFrame:Show()
				CharacterStatsPane.AttributesCategory:SetPoint("TOP", 0, -76)
			else
				CharacterStatsPane.ItemLevelCategory:Hide()
				CharacterStatsPane.ItemLevelFrame:Hide()
				CharacterStatsPane.AttributesCategory:SetPoint("TOP", 0, -20)
				categoryYOffset = -12
				statYOffset = -6
			end
		end

		local spec = GetSpecialization()
		local role = GetSpecializationRole(spec)

		CharacterStatsPane.statsFramePool:ReleaseAll()
		-- we need a stat frame to first do the math to know if we need to show the stat frame
		-- so effectively we"ll always pre-allocate
		local statFrame = CharacterStatsPane.statsFramePool:Acquire()

		local lastAnchor

		for catIndex = 1, #PAPERDOLL_STATCATEGORIES do
			local catFrame = CharacterStatsPane[PAPERDOLL_STATCATEGORIES[catIndex].categoryFrame]
			local numStatInCat = 0
			for statIndex = 1, #PAPERDOLL_STATCATEGORIES[catIndex].stats do
				local stat = PAPERDOLL_STATCATEGORIES[catIndex].stats[statIndex]
				local showStat = true
				if (showStat and stat.primary) then
					local primaryStat = select(6, GetSpecializationInfo(spec, nil, nil, nil, UnitSex("player")))
					if (stat.primary ~= primaryStat) then
						showStat = false
					end
				end
				if (showStat and stat.roles) then
					local foundRole = false
					for _, statRole in pairs(stat.roles) do
						if (role == statRole) then
							foundRole = true
							break
						end
					end
					showStat = foundRole
				end
				if (showStat) then
					statFrame.onEnterFunc = nil
					PAPERDOLL_STATINFO[stat.stat].updateFunc(statFrame, "player")
					if (not stat.hideAt or stat.hideAt ~= statFrame.numericValue) then
						if (numStatInCat == 0) then
							if (lastAnchor) then
								catFrame:SetPoint("TOP", lastAnchor, "BOTTOM", 0, categoryYOffset)
							end
							statFrame:SetPoint("TOP", catFrame, "BOTTOM", 0, -2)
						else
							statFrame:SetPoint("TOP", lastAnchor, "BOTTOM", 0, statYOffset)
						end
						numStatInCat = numStatInCat + 1
						statFrame.Background:SetShown(false)
						ColorizeStatPane(statFrame)
						statFrame.leftGrad:SetShown((numStatInCat % 2) == 0)
						statFrame.rightGrad:SetShown((numStatInCat % 2) == 0)
						lastAnchor = statFrame
						-- done with this stat frame, get the next one
						statFrame = CharacterStatsPane.statsFramePool:Acquire()
					end
				end
			end
			catFrame:SetShown(numStatInCat > 0)
		end
		-- release the current stat frame
		CharacterStatsPane.statsFramePool:Release(statFrame)
	end)

	local function StatsPane(type)
		CharacterStatsPane[type]:StripTextures()
		CharacterStatsPane[type]:CreateBackdrop("Transparent")
		CharacterStatsPane[type].Backdrop:ClearAllPoints()
		CharacterStatsPane[type].Backdrop:SetPoint("CENTER")
		CharacterStatsPane[type].Backdrop:SetWidth(150)
		CharacterStatsPane[type].Backdrop:SetHeight(18)
	end
	StatsPane("EnhancementsCategory")
	StatsPane("ItemLevelCategory")
	StatsPane("AttributesCategory")

	-- Titles
	PaperDollTitlesPane:HookScript("OnShow", function(self)
		for _, object in pairs(PaperDollTitlesPane.buttons) do
			object.BgTop:SetTexture(nil)
			object.BgBottom:SetTexture(nil)
			object.BgMiddle:SetTexture(nil)
			object.text:FontTemplate()
			hooksecurefunc(object.text, "SetFont", function(self, font)
				if font ~= C["Media"].Font then
					self:FontTemplate()
				end
			end)
		end
	end)
end

tinsert(K.SkinFuncs["KkthnxUI"], LoadSkin)