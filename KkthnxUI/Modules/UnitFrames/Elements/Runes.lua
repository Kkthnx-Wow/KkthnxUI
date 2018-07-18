local K, C = unpack(select(2, ...))
if C["Unitframe"].Enable ~= true then
	return
end

local Module = K:GetModule("Unitframes")

local function RunesPostUpdate(self, runemap)
	local Bar = self
	local RuneMap = runemap
	
	for i, RuneID in next, RuneMap do
		local IsReady = select(3, GetRuneCooldown(RuneID))
		
		if IsReady then
			Bar[i]:GetStatusBarTexture():SetAlpha(1.0)
		else
			Bar[i]:GetStatusBarTexture():SetAlpha(0.3)
		end
	end
end

function Module:CreateClassRunes(width, height, spacing)
	if K.Class ~= "DEATHKNIGHT" then
		return
	end
	
	local RunesModuleTexture = K.GetTexture(C["Unitframe"].Texture)
	
	local runes = {}
	local maxRunes = 6
	
	width = (width - (maxRunes + 1) * spacing) / maxRunes
	spacing = width + spacing
	
	for i = 1, maxRunes do
		local rune = CreateFrame("StatusBar", nil, self)
		rune:SetSize(width, height)
		rune:SetPoint("BOTTOMLEFT", (i - 1) * spacing + 4, -14)
		rune:SetStatusBarTexture(RunesModuleTexture)
		
		rune.Background = rune:CreateTexture(nil, "BACKGROUND", -1)
		rune.Background:SetAllPoints()
		rune.Background:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])
		
		K.CreateBorder(rune)
		
		runes[i] = rune
	end
	
	runes.colorSpec = true
	runes.PostUpdate = RunesPostUpdate
	self.Runes = runes
end