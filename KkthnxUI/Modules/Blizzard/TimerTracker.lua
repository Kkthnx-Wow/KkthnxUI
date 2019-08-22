local K, C = unpack(select(2, ...))
local Module = K:GetModule("Blizzard")

-- Timer tracker
local function SkinIt(bar)
	local BlizzTimerTexture = K.GetTexture(C["UITextures"].UnitframeTextures)

	for i = 1, bar:GetNumRegions() do
		local region = select(i, bar:GetRegions())

		if region:GetObjectType() == "Texture" then
			region:SetTexture(nil)
		elseif region:GetObjectType() == "FontString" then
			region:SetFont(C["Media"].Font, 13, "")
			region:SetShadowOffset(1.25, -1.25)
		end
	end

	bar:SetSize(222, 24)
	bar:SetStatusBarTexture(BlizzTimerTexture)
	bar:SetStatusBarColor(170 / 255, 10 / 255, 10 / 255)

	bar.Backgrounds = bar:CreateTexture(nil, "BACKGROUND", -2)
	bar.Backgrounds:SetAllPoints()
	bar.Backgrounds:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

	K.CreateBorder(bar)

	bar.spark = bar:CreateTexture(nil, "OVERLAY")
	bar.spark:SetWidth(64)
	bar.spark:SetHeight(bar:GetHeight())
	bar.spark:SetTexture(C["Media"].Spark_128)
	bar.spark:SetBlendMode("ADD")
	bar.spark:SetPoint("CENTER", bar:GetStatusBarTexture(), "RIGHT", 0, 0)
end

function Module.START_TIMER()
	if C["Unitframe"].Enable ~= true then
		return
	end

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
