local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local _G = _G

local CreateFrame = _G.CreateFrame
local hooksecurefunc = _G.hooksecurefunc

function Module:ReskinSkada()
	if C["Skins"].Skada ~= true or not K.CheckAddOnState("Skada") then
		return
	end

	function Skada:ShowPopup()
		ModuleSkins:AcceptFrame("Do you want to reset Skada?", function(self)
			Skada:Reset()
			self:GetParent():Hide()
		end)
	end

	local SkadaDisplayBar = Skada.displays["bar"]

	hooksecurefunc(SkadaDisplayBar, "AddDisplayOptions", function(_, _, options)
		options.baroptions.args.barspacing = nil
		options.titleoptions.args.texture = nil
		options.titleoptions.args.bordertexture = nil
		options.titleoptions.args.thickness = nil
		options.titleoptions.args.margin = nil
		options.titleoptions.args.color = nil
		options.windowoptions = nil
	end)

	hooksecurefunc(SkadaDisplayBar, "ApplySettings", function(_, win)
		local skada = win.bargroup
		skada:SetSpacing(1)
		skada:SetFrameLevel(5)
		skada:SetBackdrop(nil)

		if win.db.enabletitle then
			if not skada.button.isSkinned then
				skada.button.Background = skada.button:CreateTexture(nil, "BACKGROUND", -1)
				skada.button.Background:SetAllPoints(skada.button)
				skada.button.Background:SetColorTexture(C["Media"].Backdrops.ColorBackdrop[1], C["Media"].Backdrops.ColorBackdrop[2], C["Media"].Backdrops.ColorBackdrop[3], C["Media"].Backdrops.ColorBackdrop[4])
				skada.button.isSkinned = true
			end

			local color = win.db.title.color
			skada.button:SetBackdropColor(color.r, color.g, color.b, color.a or 1)
		end

		if not skada.Borders then
			skada.Borders = CreateFrame("Frame", nil, skada)
			skada.Borders:SetAllPoints(skada)
			skada.Borders:CreateBorder()
		end

		if skada.Borders then
			skada.Borders:ClearAllPoints()
			if win.db.reversegrowth then
				skada.Borders:SetPoint("TOPLEFT", skada, "TOPLEFT", -1, 1)
				skada.Borders:SetPoint("BOTTOMRIGHT", win.db.enabletitle and skada.button or skada, "BOTTOMRIGHT", 1, -1)
			else

				skada.Borders:SetPoint("TOPLEFT", win.db.enabletitle and skada.button or skada, "TOPLEFT", -1, 1)
				skada.Borders:SetPoint("BOTTOMRIGHT", skada, "BOTTOMRIGHT", 1, -1)
			end
		end
	end)
end