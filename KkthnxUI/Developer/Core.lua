-- Create a new module for the death counter
local K, C, L = unpack(KkthnxUI)

K.Devs = {
	["Kkthnx-Area 52"] = true,
}

local function isDeveloper()
	return K.Devs[K.Name .. "-" .. K.Realm]
end
K.isDeveloper = isDeveloper()

if not K.isDeveloper then
	return
end

local Module = K:NewModule("TradeThanksButton")

-- Create the button for sending the thank you message
local lastClickTime = 0
function Module:CreateThanksButton()
	-- Create a new button frame
	self.thanksButton = CreateFrame("Button", nil, TradeFrame, "UIPanelButtonTemplate")

	-- Set the size of the button
	self.thanksButton:SetSize(80, 20)

	-- Set the text of the button
	self.thanksButton:SetText("Thanks")

	-- Set the position of the button
	self.thanksButton:SetPoint("BOTTOMLEFT", TradeFrame, "BOTTOMLEFT", 4, 6)

	-- Add an OnClick script to the button
	self.thanksButton:SetScript("OnClick", function()
		local currentTime = GetTime()
		if currentTime - lastClickTime < 5 then -- prevent spamming the button within 5 seconds
			return
		end
		-- Check if there is a target name
		if self.targetName then
			-- If there is, send a thank you message to the target through whisper
			DoEmote("THANK", self.targetName)
			lastClickTime = currentTime
			self.thanksButton:Disable() -- Disable the button when it's clicked
			C_Timer.After(2, function() -- After 2 seconds
				self.thanksButton:Enable() -- Enable the button again
			end)
		end
	end)
end

-- Function to be called when the TRADE_SHOW event is triggered
function Module.TRADE_SHOW()
	-- Set the target name to the current NPC name
	Module.targetName = UnitName("NPC")
end

-- Enable the module and its functions
function Module:OnEnable()
	-- Check if the TradeThanks option is enabled
	-- if not C["Misc"].TradeThanks then
	-- return
	-- end

	-- Create the thanks button
	self:CreateThanksButton()

	-- Register the TRADE_SHOW event and bind it to the TRADE_SHOW function
	K:RegisterEvent("TRADE_SHOW", self.TRADE_SHOW)
end

-- Function to update the visibility of the thanks button
function Module:UpdateThanksButton()
	-- Check if the TradeThanks option is enabled
	if C["Misc"].TradeThanks then
		-- If it is, show the thanks button
		if self.thanksButton then
			self.thanksButton:Show()
		else
			self:CreateThanksButton()
		end

		-- Register the TRADE_SHOW event and bind it to the TRADE_SHOW function
		K:RegisterEvent("TRADE_SHOW", self.TRADE_SHOW)
	else
		-- If it is not, hide the thanks button
		if self.thanksButton then
			self.thanksButton:Hide()
		end

		-- Unregister the TRADE_SHOW event
		K:UnregisterEvent("TRADE_SHOW", self.TRADE_SHOW)
	end
end

-- Module:RegisterMisc("TradeThanks", Module.OnEnable)
