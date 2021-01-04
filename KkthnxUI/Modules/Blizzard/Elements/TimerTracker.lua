local K, C = unpack(select(2, ...))
local Module = K:GetModule("Blizzard")

local _G = _G
local pairs = _G.pairs
local select = _G.select

-- Timer tracker
local function SkinIt(bar)
	local BlizzTimerTexture = K.GetTexture(C["UITextures"].UnitframeTextures)

	for i = 1, bar:GetNumRegions() do
		local region = select(i, bar:GetRegions())

		if region:GetObjectType() == "Texture" then
			region:SetTexture(nil)
		elseif region:GetObjectType() == "FontString" then
			region:SetFont(C["Media"].Fonts.KkthnxUIFont, 13, "")
			region:SetShadowOffset(1.25, -1.25)
		end
	end

	bar:SetSize(222, 24)
	bar:SetStatusBarTexture(BlizzTimerTexture)
	bar:SetStatusBarColor(170 / 255, 10 / 255, 10 / 255)
	bar:CreateBorder()

	bar.spark = bar:CreateTexture(nil, "OVERLAY")
	bar.spark:SetWidth(64)
	bar.spark:SetHeight(bar:GetHeight())
	bar.spark:SetTexture(C["Media"].Textures.Spark128Texture)
	bar.spark:SetBlendMode("ADD")
	bar.spark:SetPoint("CENTER", bar:GetStatusBarTexture(), "RIGHT", 0, 0)
end

function Module.START_TIMER()
	for _, b in pairs(TimerTracker.timerList) do
		if b["bar"] and not b["bar"].skinned then
			SkinIt(b["bar"])
			b["bar"].skinned = true
		end
	end
end

function Module:CreateTimerTracker()
	K:RegisterEvent("START_TIMER", self.START_TIMER)
	self:START_TIMER()
end