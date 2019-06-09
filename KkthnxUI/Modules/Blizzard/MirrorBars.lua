local K, C = unpack(select(2, ...))

-- Sourced: Tukui

local function MirrorTimers_Update()
	for i = 1, MIRRORTIMER_NUMTIMERS, 1 do
		local Bar = _G["MirrorTimer"..i]
		if not Bar.isSkinned then
			local Status = _G[Bar:GetName().."StatusBar"]
			local Border = _G[Bar:GetName().."Border"]
			local Text = _G[Bar:GetName().."Text"]

			Bar:StripTextures()
			Bar:CreateBorder()

			Status:ClearAllPoints()
			Status:SetAllPoints(Bar)
			Status:SetStatusBarTexture(C["Media"].Texture)

			Text:ClearAllPoints()
			Text:SetPoint("CENTER", Bar)

			Status.Spark = Status:CreateTexture(nil, "OVERLAY")
			Status.Spark:SetWidth(128)
			Status.Spark:SetHeight(Status:GetHeight())
			Status.Spark:SetTexture(C["Media"].Spark_128)
			Status.Spark:SetBlendMode("ADD")
			Status.Spark:SetPoint("CENTER", Status:GetStatusBarTexture(), "RIGHT", 0, 0)

			Border:SetTexture(nil)

			Bar.isSkinned = true
		end
	end
end

hooksecurefunc("MirrorTimer_Show", MirrorTimers_Update)