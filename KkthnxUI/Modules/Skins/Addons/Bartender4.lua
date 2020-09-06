local K, C = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local _G = _G

local BartenderFont = K.GetFont(C["UIFonts"].SkinFonts)
local BartenderTexture = K.GetTexture(C["UITextures"].SkinTextures)

function Module:ReskinBartender4()
	if IsAddOnLoaded("RareScanner") then
		--if scanner_button then
			scanner_button:StripTextures()
			scanner_button:SkinButton()
			scanner_button.FilterDisabledButton:SkinButton(nil, nil, '-')
			scanner_button.CloseButton:SkinCloseButton()
		--end
	end

	if not IsAddOnLoaded("Bartender4") or not C["Skins"].Bartender4 then
		return
	end

	local function StyleNormalButton(self)
		local Name = self:GetName()
		local Action = self.action
		local Button = self
		local Icon = _G[Name.."Icon"]
		local Count = _G[Name.."Count"]
		local Flash	 = _G[Name.."Flash"]
		local HotKey = _G[Name.."HotKey"]
		local Border = _G[Name.."Border"]
		local Btname = _G[Name.."Name"]
		local Normal = _G[Name.."NormalTexture"]
		local BtnBG = _G[Name.."FloatingBG"]

		Flash:SetTexture("")
		Button:SetNormalTexture("")

		Count:ClearAllPoints()
		Count:SetPoint("BOTTOMRIGHT", 0, 2)

		HotKey:ClearAllPoints()
		HotKey:SetPoint("TOPRIGHT", 0, -3)

		if Border and Button.isSkinned then
			Border:SetTexture("")
			if Border:IsShown() then
				Button.KKUI_Border:SetVertexColor(0.08, 0.70, 0)
			else
				Button.KKUI_Border:SetVertexColor(1, 1, 1)
			end
		end

		if Btname and Normal then
			local String = Action and GetActionText(Action)

			if String then
				local Text = string.sub(String, 1, 5)
				Btname:SetText(Text)
			end
		end

		if (Button.isSkinned) then
			return
		end

		if (Btname) then
			Btname:ClearAllPoints()
			Btname:SetPoint("BOTTOM", 1, 1)
		end

		if (BtnBG) then
			BtnBG:Kill()
		end

		Button:CreateBorder()
		Button:UnregisterEvent("ACTIONBAR_SHOWGRID")
		Button:UnregisterEvent("ACTIONBAR_HIDEGRID")

		Icon:SetTexCoord(unpack(K.TexCoords))
		Icon:SetAllPoints(Button)

		if (Normal) then
			Normal:ClearAllPoints()
			Normal:SetPoint("TOPLEFT")
			Normal:SetPoint("BOTTOMRIGHT")

			if (Button:GetChecked()) then
				ActionButton_UpdateState(Button)
			end
		end

		Button:StyleButton()
		Button.isSkinned = true
	end

	if BT4StatusBarTrackingManager then
		BT4StatusBarTrackingManager:StripTextures()
	end

	for i = 1, 10 do
		if _G["BT4Bar"..i] and _G["BT4Bar"..i].buttons then
			for k, button in pairs(_G["BT4Bar"..i].buttons) do
				StyleNormalButton(button)
			end
		end

		if _G["BT4StanceButton"..i] then
			StyleNormalButton(_G["BT4StanceButton"..i])
		end

		if _G["BT4PetButton"..i] then
			StyleNormalButton(_G["BT4PetButton"..i])
		end

		if MainMenuBarBackpackButton then
			local Texture = MainMenuBarBackpackButton.icon:GetTexture()
			MainMenuBarBackpackButton:StripTextures()
			MainMenuBarBackpackButton:CreateBorder()
			MainMenuBarBackpackButton.icon:SetTexCoord(unpack(K.TexCoords))
			MainMenuBarBackpackButton.icon:SetAllPoints(MainMenuBarBackpackButton)
			MainMenuBarBackpackButton.icon.SetTexCoord = function() end
			MainMenuBarBackpackButton.icon:SetTexture(Texture)

			for i = 0, 3 do
				if _G["CharacterBag"..i.."Slot"] then
					local Texture = _G["CharacterBag"..i.."Slot"].icon:GetTexture()
					_G["CharacterBag"..i.."Slot"]:StripTextures()
					_G["CharacterBag"..i.."Slot"]:CreateBorder()
					_G["CharacterBag"..i.."Slot"].icon:SetTexCoord(unpack(K.TexCoords))
					_G["CharacterBag"..i.."Slot"].icon:SetAllPoints(_G["CharacterBag"..i.."Slot"])
					_G["CharacterBag"..i.."Slot"].icon.SetTexCoord = function() end
					_G["CharacterBag"..i.."Slot"].icon:SetTexture(Texture)
				end
			end
		end
	end
end