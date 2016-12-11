local K, C, L = unpack(select(2, ...))

-- Wow API
local IsShiftKeyDown = IsShiftKeyDown

-- CHAT SCROLL MODULE
function FloatingChatFrame_OnMouseScroll(self, delta)
	if (delta < 0) then
		if IsShiftKeyDown() then
			self:ScrollToBottom()
		else
			for i = 1, (C.Chat.ScrollByX or 3) do
				self:ScrollDown()
			end
		end
	elseif (delta > 0) then
		if IsShiftKeyDown() then
			self:ScrollToTop()
		else
			for i = 1, (C.Chat.ScrollByX or 3) do
				self:ScrollUp()
			end
		end
	end
end