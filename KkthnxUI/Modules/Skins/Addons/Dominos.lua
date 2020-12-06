local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local _G = _G

function Module:ReskinDominos()
	if not C["Skins"].Dominos then
		return
	end

	local function StyleNormalDominosButton(self)
		local name = self:GetName()
		if name:match("ExtraActionButton") then
			return
		end

		local button = self
		local icon = _G[name.."Icon"]
		local count = _G[name.."Count"]
		local flash = _G[name.."Flash"]
		local hotkey = _G[name.."HotKey"]
		local border = _G[name.."Border"]
		local btname = _G[name.."Name"]
		local normal = _G[name.."NormalTexture"]

		flash:SetTexture("")
		button:SetNormalTexture("")

		if border then
			border:Hide()
			border = K.Noop
		end

		if count then
			count:ClearAllPoints()
			count:SetPoint("BOTTOMRIGHT", 0, 2)
		end

		if btname then
			btname:ClearAllPoints()
			btname:SetPoint("BOTTOM", 0, 0)
		end

		if hotkey then
			hotkey:ClearAllPoints()
			hotkey:SetPoint("TOPRIGHT", 0, 0)
			hotkey:SetWidth(button:GetWidth() - 1)
		end

		if not button.isSkinned then
			button:CreateBackdrop()
			button.Backdrop:SetAllPoints()

			icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
			icon:SetAllPoints()

			button.isSkinned = true
		end

		if normal then
			normal:ClearAllPoints()
			normal:SetPoint("TOPLEFT")
			normal:SetPoint("BOTTOMRIGHT")
		end
	end

	local function StyleSmallDominosButton(button, icon, name, hotkey, pet)
		if not button then return end
		local flash = _G[name.."Flash"]
		button:StyleButton()
		button:SetNormalTexture("")

		hooksecurefunc(button, "SetNormalTexture", function(self, texture)
			if texture and texture ~= "" then
				self:SetNormalTexture("")
			end
		end)

		if flash then
			flash:SetColorTexture(0.8, 0.8, 0.8, 0.5)
			flash:SetPoint("TOPLEFT", button, 2, -2)
			flash:SetPoint("BOTTOMRIGHT", button, -2, 2)
		end

		if hotkey then
			hotkey:ClearAllPoints()
			hotkey:SetPoint("TOPRIGHT", 0, 0)
			hotkey:SetWidth(button:GetWidth() - 1)
		end

		if not button.isSkinned then
			button:CreateBackdrop()
			button.Backdrop:SetAllPoints()

			icon:SetTexCoord(0.1, 0.9, 0.1, 0.9)
			icon:SetAllPoints()

			if pet then
				local autocast = _G[name.."AutoCastable"]
				autocast:SetSize((button:GetWidth() * 2) - 10, (button:GetWidth() * 2) - 10)
				autocast:ClearAllPoints()
				autocast:SetPoint("CENTER", button, 0, 0)

				local shine = _G[name.."Shine"]
				shine:SetSize(button:GetWidth(), button:GetWidth())

				local cooldown = _G[name.."Cooldown"]
				cooldown:SetSize(button:GetWidth() - 2, button:GetWidth() - 2)
			end

			button.isSkinned = true
		end
	end

	do
		for i = 1, 60 do
			if _G["DominosActionButton"..i] then
				_G["DominosActionButton"..i]:StyleButton()
				StyleNormalDominosButton(_G["DominosActionButton"..i])
			end
		end

		for i = 1, 12 do
			_G["ActionButton"..i]:StyleButton()
			_G["MultiBarBottomLeftButton"..i]:StyleButton()
			_G["MultiBarBottomRightButton"..i]:StyleButton()
			_G["MultiBarLeftButton"..i]:StyleButton()
			_G["MultiBarRightButton"..i]:StyleButton()
			StyleNormalDominosButton(_G["ActionButton"..i])
			StyleNormalDominosButton(_G["MultiBarBottomLeftButton"..i])
			StyleNormalDominosButton(_G["MultiBarBottomRightButton"..i])
			StyleNormalDominosButton(_G["MultiBarLeftButton"..i])
			StyleNormalDominosButton(_G["MultiBarRightButton"..i])
		end

		for i = 1, NUM_STANCE_SLOTS do
			local name = "StanceButton"..i
			local button = _G[name]
			local icon = _G[name.."Icon"]
			local hotkey = _G[name.."HotKey"]
			StyleSmallDominosButton(button, icon, name, hotkey)
		end

		for i = 1, NUM_PET_ACTION_SLOTS do
			local name = "PetActionButton"..i
			local button = _G[name]
			local icon = _G[name.."Icon"]
			local hotkey = _G[name.."HotKey"]
			StyleSmallDominosButton(button, icon, name, hotkey, true)
		end

		if DominosFrameexp then
			DominosFrameexp:CreateBorder()
		end
	end
end