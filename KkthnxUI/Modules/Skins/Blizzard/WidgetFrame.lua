local K, C = unpack(select(2, ...))

-- Sourced: ShestakUI

local _G = _G

local hooksecurefunc = _G.hooksecurefunc

local Type_StatusBar = _G.Enum.UIWidgetVisualizationType.StatusBar
local Type_CaptureBar = _G.Enum.UIWidgetVisualizationType.CaptureBar
local Type_SpellDisplay = _G.Enum.UIWidgetVisualizationType.SpellDisplay
local Type_DoubleStatusBar = _G.Enum.UIWidgetVisualizationType.DoubleStatusBar

local atlasColors = {
	["UI-Frame-Bar-Fill-Blue"] = {0.2, 0.6, 1},
	["UI-Frame-Bar-Fill-Red"] = {0.9, 0.2, 0.2},
	["UI-Frame-Bar-Fill-Yellow"] = {1, 0.6, 0},
	["objectivewidget-bar-fill-left"] = {0.2, 0.6, 1},
	["objectivewidget-bar-fill-right"] = {0.9, 0.2, 0.2},
	["EmberCourtScenario-Tracker-barfill"] = {0.9, 0.2, 0.2},
}

function K:ReplaceWidgetBarTexture(atlas)
	if atlasColors[atlas] then
		self:SetStatusBarTexture(C["Media"].Statusbars.KkthnxUIStatusbar)
		self:SetStatusBarColor(unpack(atlasColors[atlas]))
	end
end

local function ReskinWidgetStatusBar(bar)
	if bar and not bar.styled then
		if bar.BG then
			bar.BG:SetAlpha(0)
		end

		if bar.BGLeft then
			bar.BGLeft:SetAlpha(0)
		end

		if bar.BGRight then
			bar.BGRight:SetAlpha(0)
		end

		if bar.BGCenter then
			bar.BGCenter:SetAlpha(0)
		end

		if bar.BorderLeft then
			bar.BorderLeft:SetAlpha(0)
		end

		if bar.BorderRight then
			bar.BorderRight:SetAlpha(0)
		end

		if bar.BorderCenter then
			bar.BorderCenter:SetAlpha(0)
		end

		if bar.Spark then
			bar.Spark:SetAlpha(0)
		end

		if bar.SparkGlow then
			bar.SparkGlow:SetAlpha(0)
		end

		if bar.BorderGlow then
			bar.BorderGlow:SetAlpha(0)
		end

		if bar.Label then
			bar.Label:SetPoint("CENTER", 0, -5)
			bar.Label:SetFontObject(KkthnxUIFont)
		end
		bar:CreateShadow(true)
		K.ReplaceWidgetBarTexture(bar, bar:GetStatusBarAtlas())
		hooksecurefunc(bar, "SetStatusBarAtlas", K.ReplaceWidgetBarTexture)

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
	self.LeftBar:SetTexture(C["Media"].Statusbars.KkthnxUIStatusbar)
	self.NeutralBar:SetTexture(C["Media"].Statusbars.KkthnxUIStatusbar)
	self.RightBar:SetTexture(C["Media"].Statusbars.KkthnxUIStatusbar)

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
		spell.Icon:SetTexCoord(unpack(K.TexCoords))

		spell.bg = CreateFrame("Frame", nil, spell)
		spell.bg:SetAllPoints(spell.Icon)
		spell.bg:SetFrameLevel(spell:GetFrameLevel())
		spell.bg:CreateShadow(true)
	end
	spell.IconMask:Hide()
end

table.insert(C.defaultThemes, function()
	hooksecurefunc(_G.UIWidgetTopCenterContainerFrame, "UpdateWidgetLayout", function(self)
		for _, widgetFrame in pairs(self.widgetFrames) do
			local widgetType = widgetFrame.widgetType
			if widgetType == Type_DoubleStatusBar then
				ReskinDoubleStatusBarWidget(widgetFrame)
			elseif widgetType == Type_SpellDisplay then
				ReskinSpellDisplayWidget(widgetFrame.Spell)
			elseif widgetType == Type_StatusBar then
				ReskinWidgetStatusBar(widgetFrame.Bar)
			end
		end
	end)

	hooksecurefunc(_G.UIWidgetBelowMinimapContainerFrame, "UpdateWidgetLayout", function(self)
		for _, widgetFrame in pairs(self.widgetFrames) do
			if widgetFrame.widgetType == Type_CaptureBar then
				ReskinPVPCaptureBar(widgetFrame)
			end
		end
	end)

	hooksecurefunc(_G.UIWidgetPowerBarContainerFrame, "UpdateWidgetLayout", function(self)
		for _, widgetFrame in pairs(self.widgetFrames) do
			if widgetFrame.widgetType == Type_StatusBar then
				ReskinWidgetStatusBar(widgetFrame.Bar)
			end
		end
	end)

	hooksecurefunc(_G.TopScenarioWidgetContainerBlock.WidgetContainer, "UpdateWidgetLayout", function(self)
		for _, widgetFrame in pairs(self.widgetFrames) do
			if widgetFrame.widgetType == Type_StatusBar then
				ReskinWidgetStatusBar(widgetFrame.Bar)
			end
		end
	end)

	hooksecurefunc(_G.BottomScenarioWidgetContainerBlock.WidgetContainer, "UpdateWidgetLayout", function(self)
		for _, widgetFrame in pairs(self.widgetFrames) do
			if widgetFrame.widgetType == Type_SpellDisplay then
				ReskinSpellDisplayWidget(widgetFrame.Spell)
			end
		end
	end)

	-- needs review, might remove this in the future
	hooksecurefunc(_G.UIWidgetTemplateStatusBarMixin, "Setup", function(self)
		ReskinWidgetStatusBar(self.Bar)
	end)
end)