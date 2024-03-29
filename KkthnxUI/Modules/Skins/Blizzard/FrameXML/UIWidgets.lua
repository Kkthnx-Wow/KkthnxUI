local K, C = KkthnxUI[1], KkthnxUI[2]

-- Sourced: ShestakUI

local hooksecurefunc = hooksecurefunc

local Type_StatusBar = Enum.UIWidgetVisualizationType.StatusBar
local Type_CaptureBar = Enum.UIWidgetVisualizationType.CaptureBar
local Type_SpellDisplay = Enum.UIWidgetVisualizationType.SpellDisplay
local Type_DoubleStatusBar = Enum.UIWidgetVisualizationType.DoubleStatusBar

local atlasColors = {
	["UI-Frame-Bar-Fill-Blue"] = { 0.2, 0.6, 1 },
	["UI-Frame-Bar-Fill-Red"] = { 0.9, 0.2, 0.2 },
	["UI-Frame-Bar-Fill-Yellow"] = { 1, 0.6, 0 },
	["objectivewidget-bar-fill-left"] = { 0.2, 0.6, 1 },
	["objectivewidget-bar-fill-right"] = { 0.9, 0.2, 0.2 },
	["EmberCourtScenario-Tracker-barfill"] = { 0.9, 0.2, 0.2 },
}

local elementsToHide = {
	"BG",
	"BGLeft",
	"BGRight",
	"BGCenter",
	"BorderLeft",
	"BorderRight",
	"BorderCenter",
	"Spark",
	"SparkGlow",
	"BorderGlow",
}

local function ReplaceWidgetBarTexture(self, atlas)
	if atlasColors[atlas] then
		self:SetStatusBarTexture(K.GetTexture(C["General"].Texture))
		self:SetStatusBarColor(unpack(atlasColors[atlas]))
	end
end

local function ResetLabelColor(text, _, _, _, _, force)
	if not force then
		text:SetTextColor(1, 1, 1, 1, true)
	end
end

local function ReskinWidgetStatusBar(bar)
	if bar and not bar.styled then
		for _, elementName in ipairs(elementsToHide) do
			local element = bar[elementName]
			if element then
				element:SetAlpha(0)
			end
		end

		if bar.Label then
			bar.Label:SetDrawLayer("OVERLAY")
			bar.Label:SetPoint("CENTER", 0, -3)
			bar.Label:SetFontObject(Game12Font)

			ResetLabelColor(bar.Label)
			hooksecurefunc(bar.Label, "SetTextColor", ResetLabelColor)
		end

		bar:CreateBorder()

		if bar.GetStatusBarTexture then
			ReplaceWidgetBarTexture(bar, bar:GetStatusBarTexture())
			hooksecurefunc(bar, "SetStatusBarTexture", ReplaceWidgetBarTexture)
		end

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
	if not spell or not spell.bg then
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
			end
		end
	end
end

table.insert(C.defaultThemes, function()
	if not C["Skins"].BlizzardFrames then
		return
	end

	hooksecurefunc(_G.UIWidgetTopCenterContainerFrame, "UpdateWidgetLayout", ReskinWidgetGroups)
	ReskinWidgetGroups(_G.UIWidgetTopCenterContainerFrame)

	hooksecurefunc(_G.UIWidgetBelowMinimapContainerFrame, "UpdateWidgetLayout", function(self)
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

	hooksecurefunc(_G.TopScenarioWidgetContainerBlock.WidgetContainer, "UpdateWidgetLayout", ReskinPowerBarWidget)

	hooksecurefunc(_G.BottomScenarioWidgetContainerBlock.WidgetContainer, "UpdateWidgetLayout", function(self)
		if not self.widgetFrames then
			return
		end

		for _, widgetFrame in pairs(self.widgetFrames) do
			if widgetFrame.widgetType == Type_SpellDisplay then
				if not widgetFrame:IsForbidden() then
					ReskinSpellDisplayWidget(widgetFrame.Spell)
				end
			end
		end
	end)

	-- if font outline enabled in tooltip, fix text shows in two lines on Torghast info
	hooksecurefunc(_G.UIWidgetTemplateTextWithStateMixin, "Setup", function(self)
		self.Text:SetWidth(self.Text:GetStringWidth() + 2)
	end)

	-- needs review, might remove this in the future
	hooksecurefunc(_G.UIWidgetTemplateStatusBarMixin, "Setup", function(self)
		if self:IsForbidden() then
			return
		end

		ReskinWidgetStatusBar(self.Bar)
	end)
end)
