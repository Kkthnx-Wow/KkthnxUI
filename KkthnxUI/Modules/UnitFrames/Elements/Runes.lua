local K, C = unpack(select(2, ...))
if C["Unitframe"].Enable ~= true then
	return
end

local Module = K:GetModule("Unitframes")

local _G = _G
local next = next
local select = select

local CreateFrame = _G.CreateFrame
local GetRuneCooldown = _G.GetRuneCooldown

local function PostUpdateRune(self, runemap)
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

	local runes = {}
	local maxRunes = 6
	local runesTexture = K.GetTexture(C["Unitframe"].Texture)

	width = (width - (maxRunes + 1) * spacing) / maxRunes
	spacing = width + spacing

	for i = 1, maxRunes do
		local rune = CreateFrame("StatusBar", nil, self)
		rune:SetSize(width, height)
		rune:SetPoint("BOTTOMLEFT", (i - 1) * spacing, -14)
		rune:SetStatusBarTexture(runesTexture)
		rune:CreateBorder()

		runes[i] = rune
	end

	runes.colorSpec = true
	runes.sortOrder = "asc"
	runes.PostUpdate = PostUpdateRune
	self.Runes = runes
end