local K, C = unpack(KkthnxUI)

local function reskinHelpTips(self)
	for frame in self.framePool:EnumerateActive() do
		if not frame.styled then
			if frame.OkayButton then
				frame.OkayButton:SkinButton()
			end

			if frame.CloseButton then
				frame.CloseButton:SkinCloseButton()
			end

			frame.styled = true
		end
	end
end

tinsert(C.defaultThemes, function()
	reskinHelpTips(HelpTip)
	hooksecurefunc(HelpTip, "Show", reskinHelpTips)
end)
