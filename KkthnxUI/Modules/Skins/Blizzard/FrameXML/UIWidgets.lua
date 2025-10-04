local K, C = KkthnxUI[1], KkthnxUI[2]

local Type_StatusBar = _G.Enum.UIWidgetVisualizationType.StatusBar
local Type_CaptureBar = _G.Enum.UIWidgetVisualizationType.CaptureBar
local Type_SpellDisplay = _G.Enum.UIWidgetVisualizationType.SpellDisplay
local Type_DoubleStatusBar = _G.Enum.UIWidgetVisualizationType.DoubleStatusBar
local Type_ItemDisplay = _G.Enum.UIWidgetVisualizationType.ItemDisplay

local function ResetLabelColor(text, _, _, _, _, force)
	if not force then
		text:SetTextColor(1, 1, 1, 1, true)
	end
end

local function HideRegion(region)
	if region then
		if region.SetTexture then
			region:SetTexture(nil)
		end
		region:ClearAllPoints()
		region:SetParent(K.UIFrameHider)
		region:Hide()
	end
end

local function ReskinWidgetStatusBar(bar)
	if bar and not bar.styled then
		if bar.BG then
			HideRegion(bar.BG)
		end
		if bar.BGLeft then
			HideRegion(bar.BGLeft)
		end
		if bar.BGRight then
			HideRegion(bar.BGRight)
		end
		if bar.BGCenter then
			HideRegion(bar.BGCenter)
		end
		if bar.BorderLeft then
			HideRegion(bar.BorderLeft)
		end
		if bar.BorderRight then
			HideRegion(bar.BorderRight)
		end
		if bar.BorderCenter then
			HideRegion(bar.BorderCenter)
		end
		if bar.Spark then
			HideRegion(bar.Spark)
		end
		if bar.SparkGlow then
			HideRegion(bar.SparkGlow)
		end
		if bar.BorderGlow then
			HideRegion(bar.BorderGlow)
		end
		if bar.Label then
			-- bar.Label:SetPoint("CENTER", 0, -5)
			-- bar.Label:SetFontObject(K.UIFont)
			ResetLabelColor(bar.Label)
			hooksecurefunc(bar.Label, "SetTextColor", ResetLabelColor)
		end
		bar:CreateBorder()

		bar.styled = true
	end
end

local function ReskinDoubleStatusBarWidget(self)
	if not self.styled then
		ReskinWidgetStatusBar(self.LeftBar)
		ReskinWidgetStatusBar(self.RightBar)

		self.styled = true
	end
end

local function ReskinPVPCaptureBar(self)
	self.LeftBar:SetTexture(K.GetTexture(C["General"].Texture))
	self.NeutralBar:SetTexture(K.GetTexture(C["General"].Texture))
	self.RightBar:SetTexture(K.GetTexture(C["General"].Texture))

	self.LeftBar:SetVertexColor(0.2, 0.6, 1)
	self.NeutralBar:SetVertexColor(0.8, 0.8, 0.8)
	self.RightBar:SetVertexColor(0.9, 0.2, 0.2)

	self.LeftLine:SetAlpha(0)
	self.RightLine:SetAlpha(0)
	self.BarBackground:SetAlpha(0)
	self.Glow1:SetAlpha(0)
	self.Glow2:SetAlpha(0)
	self.Glow3:SetAlpha(0)

	if not self.bg then
		self.bg = CreateFrame("Frame", nil, self)
		self.bg:SetPoint("TOPLEFT", self.LeftBar, -2, 2)
		self.bg:SetPoint("BOTTOMRIGHT", self.RightBar, 2, -2)
		self.bg:SetFrameLevel(self:GetFrameLevel())
		self.bg:CreateBorder()
	end
end

local function ReskinSpellDisplayWidget(spell)
	if not spell.bg then
		spell.Border:SetAlpha(0)
		spell.DebuffBorder:SetAlpha(0)
		spell.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])
		spell.bg = CreateFrame("Frame", nil, spell)
		spell.bg:SetAllPoints(spell.Icon)
		spell.bg:SetFrameLevel(spell:GetFrameLevel())
		spell.bg:CreateShadow(true)
	end
	spell.IconMask:Hide()
end

local function ReskinPowerBarWidget(self)
	if not self.widgetFrames then
		return
	end

	for _, widgetFrame in pairs(self.widgetFrames) do
		if widgetFrame.widgetType == Type_StatusBar then
			if not widgetFrame:IsForbidden() then
				ReskinWidgetStatusBar(widgetFrame.Bar)
			end
		end
	end
end

local function ReskinWidgetItemDisplay(item)
	if not item.bg then
		item.Icon:SetTexCoord(K.TexCoords[1], K.TexCoords[2], K.TexCoords[3], K.TexCoords[4])

		item.bg = CreateFrame("Frame", nil, item)
		item.bg:SetAllPoints(item.Icon)
		item.bg:SetFrameLevel(item:GetFrameLevel())
		item.bg:CreateShadow(true)
		-- Add border color here
	end
	item.IconMask:Hide()
end

local function ReskinWidgetGroups(self)
	if not self.widgetFrames then
		return
	end

	for _, widgetFrame in pairs(self.widgetFrames) do
		if not widgetFrame:IsForbidden() then
			local widgetType = widgetFrame.widgetType
			if widgetType == Type_DoubleStatusBar then
				ReskinDoubleStatusBarWidget(widgetFrame)
			elseif widgetType == Type_SpellDisplay then
				ReskinSpellDisplayWidget(widgetFrame.Spell)
			elseif widgetType == Type_StatusBar then
				ReskinWidgetStatusBar(widgetFrame.Bar)
			elseif widgetType == Type_ItemDisplay then
				ReskinWidgetItemDisplay(widgetFrame.Item)
			end
		end
	end
end

tinsert(C.defaultThemes, function()
	if not C["Skins"].BlizzardFrames then
		return
	end

	hooksecurefunc(_G.UIWidgetTopCenterContainerFrame, "UpdateWidgetLayout", ReskinWidgetGroups)
	ReskinWidgetGroups(_G.UIWidgetTopCenterContainerFrame)

	hooksecurefunc(_G.UIWidgetBelowMinimapContainerFrame, "UpdateWidgetLayout", function(self)
		if not self.widgetFrames then
			return
		end

		for _, widgetFrame in pairs(self.widgetFrames) do
			if widgetFrame.widgetType == Type_CaptureBar then
				if not widgetFrame:IsForbidden() then
					ReskinPVPCaptureBar(widgetFrame)
				end
			end
		end
	end)

	hooksecurefunc(_G.UIWidgetPowerBarContainerFrame, "UpdateWidgetLayout", ReskinPowerBarWidget)
	ReskinPowerBarWidget(_G.UIWidgetPowerBarContainerFrame)

	hooksecurefunc(_G.ObjectiveTrackerUIWidgetContainer, "UpdateWidgetLayout", ReskinPowerBarWidget)
	ReskinPowerBarWidget(_G.ObjectiveTrackerUIWidgetContainer)

	-- if font outline enabled in tooltip, fix text shows in two lines on Torghast info || This breaks tooltips in worldmap on world quests.
	-- hooksecurefunc(_G.UIWidgetTemplateTextWithStateMixin, "Setup", function(self)
	-- 	self.Text:SetWidth(self.Text:GetStringWidth() + 2)
	-- end)

	-- needs review, might remove this in the future
	hooksecurefunc(_G.UIWidgetTemplateStatusBarMixin, "Setup", function(self)
		if self:IsForbidden() then
			return
		end
		ReskinWidgetStatusBar(self.Bar)
		if self.Label then
			self.Label:SetTextColor(1, 0.8, 0)
		end
	end)

	_G.UIWidgetCenterDisplayFrame.CloseButton:SkinCloseButton()
end)
