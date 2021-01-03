local K, C = unpack(select(2, ...))

-- Sourced: ShestakUI

local _G = _G
local table_insert = _G.table.insert

local hooksecurefunc = _G.hooksecurefunc

table_insert(C.defaultThemes, function()
	local atlasColors = {
		["UI-Frame-Bar-Fill-Blue"] = {.2, .6, 1},
		["UI-Frame-Bar-Fill-Red"] = {.9, .2, .2},
		["UI-Frame-Bar-Fill-Yellow"] = {1, .6, 0},
		["objectivewidget-bar-fill-left"] = {.2, .6, 1},
		["objectivewidget-bar-fill-right"] = {.9, .2, .2}
	}

	local function updateBarTexture(self, atlas)
		if atlasColors[atlas] then
			self:SetStatusBarTexture(C.Media.Texture)
			self:SetStatusBarColor(unpack(atlasColors[atlas]))
		end
	end

	local Type_DoubleStatusBar = _G.Enum.UIWidgetVisualizationType.DoubleStatusBar
	local Type_SpellDisplay = _G.Enum.UIWidgetVisualizationType.SpellDisplay

	local function reskinWidgetFrames()
		for _, widgetFrame in pairs(_G.UIWidgetTopCenterContainerFrame.widgetFrames) do
			if widgetFrame.widgetType == Type_DoubleStatusBar then
				if not widgetFrame.styled then
					for _, bar in pairs({widgetFrame.LeftBar, widgetFrame.RightBar}) do
						bar.BG:SetAlpha(0)
						bar.BorderLeft:SetAlpha(0)
						bar.BorderRight:SetAlpha(0)
						bar.BorderCenter:SetAlpha(0)
						bar.Spark:SetAlpha(0)
						bar.SparkGlow:SetAlpha(0)
						bar.BorderGlow:SetAlpha(0)
						bar:CreateBorder()
						hooksecurefunc(bar, "SetStatusBarAtlas", updateBarTexture)

						bar.newSpark = bar:CreateTexture(nil, "OVERLAY")
						bar.newSpark:SetTexture(C["MediaMisc"].Spark_16)
						bar.newSpark:SetHeight(bar:GetHeight())
						bar.newSpark:SetBlendMode("ADD")
						bar.newSpark:SetPoint("CENTER", bar:GetStatusBarTexture(), "RIGHT", 0, 0)
					end

					widgetFrame.styled = true
				end
			elseif widgetFrame.widgetType == Type_SpellDisplay then
				if not widgetFrame.styled then
					local widgetSpell = widgetFrame.Spell
					widgetSpell.IconMask:Hide()
					widgetSpell.Border:SetTexture(nil)
					widgetSpell.DebuffBorder:SetTexture(nil)
					widgetSpell.Icon:SetTexCoord(unpack(K.TexCoords))
					widgetSpell.Icon:CreateBorder()

					widgetFrame.styled = true
				end
			end
		end
	end
	K:RegisterEvent("PLAYER_ENTERING_WORLD", reskinWidgetFrames)
	K:RegisterEvent("UPDATE_ALL_UI_WIDGETS", reskinWidgetFrames)

	hooksecurefunc(_G.UIWidgetTemplateCaptureBarMixin, "Setup", function(self)
		self.LeftLine:SetAlpha(0)
		self.RightLine:SetAlpha(0)
		self.BarBackground:SetAlpha(0)
		self.Glow1:SetAlpha(0)
		self.Glow2:SetAlpha(0)
		self.Glow3:SetAlpha(0)

		self.LeftBar:SetTexture(C.Media.Texture)
		self.NeutralBar:SetTexture(C.Media.Texture)
		self.RightBar:SetTexture(C.Media.Texture)

		self.LeftBar:SetVertexColor(.2, .6, 1)
		self.NeutralBar:SetVertexColor(.8, .8, .8)
		self.RightBar:SetVertexColor(.9, .2, .2)

		if not self.bg then
			self.bg = CreateFrame("Frame", nil, self)
			self.bg:SetPoint("TOPLEFT", self.LeftBar, -2, 2)
			self.bg:SetPoint("BOTTOMRIGHT", self.RightBar, 2, -2)
			self.bg:SetFrameLevel(self:GetFrameLevel())
		end
	end)

	hooksecurefunc(_G.UIWidgetTemplateStatusBarMixin, "Setup", function(self)
		local bar = self.Bar
		local atlas = bar:GetStatusBarAtlas()
		updateBarTexture(bar, atlas)

		if not bar.styled then
			bar.BGLeft:SetAlpha(0)
			bar.BGRight:SetAlpha(0)
			bar.BGCenter:SetAlpha(0)
			bar.BorderLeft:SetAlpha(0)
			bar.BorderRight:SetAlpha(0)
			bar.BorderCenter:SetAlpha(0)
			bar.Spark:SetAlpha(0)
			bar:CreateBorder()

			bar.styled = true
		end
	end)
end)