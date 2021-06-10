local K, C = unpack(select(2, ...))

local Profiles = CreateFrame("Frame", "KKUI_Profiles", UIParent)
local Prefix = "KkthnxUI:Profile:"

local CloseOnEnter = function(self)
	self.Texture:SetVertexColor(1, 0.2, 0.2)
end

local CloseOnLeave = function(self)
	self.Texture:SetVertexColor(1, 1, 1)
end

function Profiles:Export()
	local Settings = {}

	Settings.Variables = KkthnxUIDB.Variables[K.Realm][K.Name]
	Settings.Settings = KkthnxUIDB.Settings[K.Realm][K.Name]

	local Serialized = K.Serialize:Serialize(Settings)
	local Compressed = K.Deflate:CompressDeflate(Serialized)
	local Encoded = K.Deflate:EncodeForPrint(Compressed)
	local Result = Prefix..Encoded

	return Result
end

function Profiles:Import()
	local EditBox = self:GetParent().EditBox
	local Status = self:GetParent().Status
	local Code = EditBox:GetText()
	local LibCode = string.gsub(Code, Prefix, "")
	local Decoded = K.Deflate:DecodeForPrint(LibCode)

	if Code == EditBox.Code then
		Status:SetText("|cffff0000Sorry, You Are Currently Using This Profile Already|r")
	elseif Decoded then
		local Decompressed = K.Deflate:DecompressDeflate(Decoded)
		local Success, Table = K.Serialize:Deserialize(Decompressed)

		if Success then
			KkthnxUIDB.Variables[K.Realm][K.Name] = Table.Variables
			KkthnxUIDB.Settings[K.Realm][K.Name] = Table.Settings

			ReloadUI()
		else
			Status:SetText("|cffff0000Sorry, This Profile Code Is Not Valid|r")
		end
	else
		Status:SetText("|cffff0000Sorry, This Profile Code Is Not Valid|r")
	end
end

function Profiles:Toggle()
	if self:IsShown() then
		self:Hide()
	else
		self:Show()
		self.EditBox:SetText(self.EditBox.Code)
	end
end

local class = select(2, UnitClass("player"))
local texcoord = CLASS_ICON_TCOORDS[class]
function Profiles:OnTextChanged()
	local Code = self:GetText()
	local Status = self:GetParent().Status

	if Code ~= self.Code then
		Status:SetText("You Are Currently Trying To Apply A New Profile Code")
	else
		Status:SetText("Export Profile For: ".."|TInterface\\WorldStateFrame\\Icons-Classes:16:16:0:0:256:256:"..tostring(texcoord[1]*256)..":"..tostring(texcoord[2]*256)..":"..tostring(texcoord[3]*256)..":"..tostring(texcoord[4]*256).."|t "..K.RGBToHex(unpack(K.Colors.class[K.Class]))..(K.Name).."|r")
	end
end

function Profiles:RestoreCode()
	local EditBox = self:GetParent().EditBox

	EditBox:SetText(EditBox.Code)
end

function Profiles:Enable()
	self:SetSize(600, 170)
	self:SetPoint("CENTER", UIParent, "CENTER", 0, 250)
	self:CreateBorder()

	K.CreateMoverFrame(self)

	self.Logo = self:CreateTexture(nil, "OVERLAY")
	self.Logo:SetSize(320, 150)
	self.Logo:SetScale(0.8)
	self.Logo:SetTexture(C["Media"].Textures.LogoTexture)
	self.Logo:SetPoint("TOP", self, "TOP", 0, 20)

	self.Title = self:CreateFontString(nil, "OVERLAY")
	self.Title:SetFontObject(KkthnxUIFont)
	self.Title:SetFont(select(1, self.Title:GetFont()), 15, select(3, self.Title:GetFont()))
	self.Title:SetPoint("TOP", self, "TOP", 0, -86)
	self.Title:SetText(K.SystemColor.."In this window, you will be able to export, import or share your profile.|r")

	self.Description = self:CreateFontString(nil, "OVERLAY")
	self.Description:SetFontObject(KkthnxUIFont)
	self.Description:SetFont(select(1, self.Description:GetFont()), 15, select(3, self.Description:GetFont()))
	self.Description:SetPoint("TOP", self.Title, "TOP", 0, -20)
	self.Description:SetText(K.SystemColor.."If you wish to use another profile, just replace the code below and hit apply.|r")

	local ll = CreateFrame("Frame", nil, self)
	ll:SetPoint("TOP", self.Description, -100, -30)
	K.CreateGF(ll, 200, 1, "Horizontal", .7, .7, .7, 0, .7)
	ll:SetFrameStrata("HIGH")
	local lr = CreateFrame("Frame", nil, self)
	lr:SetPoint("TOP", self.Description, 100, -30)
	K.CreateGF(lr, 200, 1, "Horizontal", .7, .7, .7, .7, 0)
	lr:SetFrameStrata("HIGH")

	self.Status = self:CreateFontString(nil, "OVERLAY")
	self.Status:SetFontObject(KkthnxUIFont)
	self.Status:SetFont(select(1, self.Status:GetFont()), 15, select(3, self.Status:GetFont()))
	self.Status:SetPoint("TOP", self.Title, "TOP", 0, -60)
	self.Status:SetTextColor(102/255, 157/255, 255/255, 1)

	self.EditBox = CreateFrame("EditBox", nil, self)
	self.EditBox:SetMultiLine(true)
	self.EditBox:SetCursorPosition(0)
	self.EditBox:EnableMouse(true)
	self.EditBox:SetAutoFocus(false)
	self.EditBox:SetFontObject(ChatFontNormal)
	self.EditBox:SetWidth(self:GetWidth() - 8)
	self.EditBox:SetHeight(250)
	self.EditBox:SetPoint("TOP", self, "BOTTOM", 0, -10)
	self.EditBox:SetScript("OnEscapePressed", function(self)
		self:ClearFocus()
	end)
	self.EditBox:SetScript("OnTextChanged", Profiles.OnTextChanged)
	self.EditBox:CreateBackdrop()
	self.EditBox.Backdrop:SetPoint("TOPLEFT", -4, 4)
	self.EditBox.Backdrop:SetPoint("BOTTOMRIGHT", 4, -4)
	self.EditBox.Backdrop.KKUI_Border:SetVertexColor(102/255, 157/255, 255/255, 1)
	self.EditBox:SetTextInsets(4, 4, 4, 4)
	self.EditBox.Code = self:Export()

	self.Close = CreateFrame("Button", nil, self)
	self.Close:SetSize(22, 22)
	self.Close:SetPoint("TOPRIGHT", self, 0, 0)
	self.Close:SetScript("OnEnter", CloseOnEnter)
	self.Close:SetScript("OnLeave", CloseOnLeave)
	self.Close:SetScript("OnClick", function(self)
		self:GetParent():Hide()
		if not K.GUI:IsShown() then -- Show our GUI again after they click the okay button (If our GUI isn't shown again by that time)
			K.GUI:Toggle()
		end
	end)

	self.Close.Texture = self.Close:CreateTexture(nil, "OVERLAY")
	self.Close.Texture:SetPoint("CENTER", self.Close, 0, 0)
	self.Close.Texture:SetSize(20, 20)
	self.Close.Texture:SetTexture("Interface\\AddOns\\KkthnxUI\\Media\\Textures\\CloseButton_32")

	self.Apply = CreateFrame("Button", nil, self)
	self.Apply:SetSize(self:GetWidth() / 2 - 4, 26)
	self.Apply:SkinButton()
	self.Apply:SetPoint("TOPLEFT", self.EditBox, "BOTTOMLEFT", -4, -10)
	self.Apply.Text = self.Apply:CreateFontString(nil, "OVERLAY")
	self.Apply.Text:SetFontObject(KkthnxUIFont)
	self.Apply.Text:SetPoint("CENTER")
	self.Apply.Text:SetText("|CFF00CC4C"..APPLY.."|r")
	self.Apply:SetScript("OnClick", Profiles.Import)

	self.Reset = CreateFrame("Button", nil, self)
	self.Reset:SetSize(self:GetWidth() / 2 - 4, 26)
	self.Reset:SkinButton()
	self.Reset:SetPoint("TOPRIGHT", self.EditBox, "BOTTOMRIGHT", 4, -10)
	self.Reset.Text = self.Reset:CreateFontString(nil, "OVERLAY")
	self.Reset.Text:SetFontObject(KkthnxUIFont)
	self.Reset.Text:SetPoint("CENTER")
	self.Reset.Text:SetText(RESET)
	self.Reset.Text:SetTextColor(102/255, 157/255, 255/255, 1)
	self.Reset:SetScript("OnClick", Profiles.RestoreCode)

	self:Hide()
end

K.Profiles = Profiles