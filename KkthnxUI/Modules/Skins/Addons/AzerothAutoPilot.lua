local K, C = unpack(select(2, ...))
if not K.CheckAddOnState("Azeroth Auto Pilot") or C["Skins"].AzerothAutoPilot ~= true then
	return
end

local Module = K:NewModule("AzerothAutoPilotSkin")
local ModuleSkins = K:GetModule("Skins")

function Module:SkinAzerothAutoPilot()
	local AAPSFont = K.GetFont(C["Skins"].Font)
	local AAPSTexture = K.GetTexture(C["Skins"].Texture)

	AAP_GreetingsFrame:StripTextures()
	AAP_GreetingsFrame:CreateShadow(true)
	AAP.QuestList.Greetings2FS1:SetWidth(500)
	AAP.QuestList.Greetings:SetHeight(175)
	AAP.QuestList.Greetings2FS1:SetFontObject(AAPSFont)
	AAP.QuestList.Greetings2FS1:SetFont(select(1, AAP.QuestList.Greetings2FS1:GetFont()), 20, select(3, AAP.QuestList.Greetings2FS1:GetFont()))
	AAP.QuestList.Greetings2FS2:SetFontObject(AAPSFont)
	AAP.QuestList.Greetings2FS2:SetFont(select(1, AAP.QuestList.Greetings2FS1:GetFont()), 14, select(3, AAP.QuestList.Greetings2FS1:GetFont()))
	AAP.QuestList.Greetings2FS221:SetFontObject(AAPSFont)
	AAP.QuestList.Greetings2FS221:SetFont(select(1, AAP.QuestList.Greetings2FS1:GetFont()), 14, select(3, AAP.QuestList.Greetings2FS1:GetFont()))
	AAP_GreetingsHideB:SkinButton()
	AAP_SkipActiveButton3:SkinButton()
	AAP_SugQuestFrameFrame:StripTextures()
	AAP_SugQuestFrameFrame:CreateShadow(true)

	local function AAP_buttonSkin(self, button)
		self.icon = self:GetNormalTexture()
		self.icon:SetAllPoints()
		self:SetWidth(AAP.QuestList2.BF1:GetHeight()-2)
		self:SetHeight(AAP.QuestList2.BF1:GetHeight()-2)
		return
	end

	local i
	for i = 1, 20 do
		_G["CLQListF"..i]:StripTextures()
		_G["CLQListF"..i]:CreateShadow(true)
		_G["AAP_SkipActiveButton"..i]:SkinButton()
		AAP.QuestList2["BF"..i]["AAP_Button"]:HookScript("OnShow", AAP_buttonSkin)
		AAP.QuestList.QuestFrames["FS"..i]:SetFontObject(AAPSFont)
		AAP.QuestList.QuestFrames["FS"..i]:SetFont(select(1, AAP.QuestList.QuestFrames["FS"..i]:GetFont()), 18, select(3, AAP.QuestList.QuestFrames["FS"..i]:GetFont()))
		AAP.QuestList.QuestFrames["FS"..i]["Fontstring1"]:SetFontObject(AAPSFont)
		AAP.QuestList.QuestFrames["FS"..i]["Fontstring1"]:SetFont(select(1, AAP.QuestList.QuestFrames["FS"..i]["Fontstring1"]:GetFont()), 10, select(3, AAP.QuestList.QuestFrames["FS"..i]["Fontstring1"]:GetFont()))
	end

	for i = 1, 5 do
		_G["CLQaaListF"..i]:StripTextures()
		_G["CLQaaListF"..i]:CreateShadow(true)
		AAP.PartyList.PartyFramesFS1[i]:SetFontObject(AAPSFont)
		AAP.PartyList.PartyFramesFS1[i]:SetFont(select(1, AAP.PartyList.PartyFramesFS1[i]:GetFont()), 16, select(3, AAP.PartyList.PartyFramesFS1[i]:GetFont()))
		AAP.PartyList.PartyFrames[i]:SetPoint("BOTTOMLEFT", AAP.PartyList.PartyFrame, "BOTTOMLEFT",41,-((26*i)-25))
		_G["CLQaListF"..i]:StripTextures()
		_G["CLQaListF"..i]:CreateShadow(true)
		AAP.PartyList.PartyFramesFS2[i]:SetFontObject(AAPSFont)
		AAP.PartyList.PartyFramesFS2[i]:SetFont(select(1, AAP.PartyList.PartyFramesFS2[i]:GetFont()), 16, select(3, AAP.PartyList.PartyFramesFS2[i]:GetFont()))
		AAP.PartyList.PartyFrames2[i]:SetPoint("BOTTOMLEFT", AAP.PartyList.PartyFrame, "BOTTOMLEFT",0,-((26*i)-25))
	end

	AAP_UpdateQuestList()
	AAP_OptionsMainFrame:StripTextures()
	AAP_OptionsMainFrame:CreateBorder()

	for i = 1, 3 do
		AAP.OptionsFrame["Slider"..i].Low:SetFontObject(AAPSFont)
		AAP.OptionsFrame["Slider"..i].Low:SetFont(select(1, AAP.OptionsFrame["Slider"..i].Low:GetFont()), 10, select(3, AAP.OptionsFrame["Slider"..i].Low:GetFont()))
		AAP.OptionsFrame["Slider"..i].High:SetFontObject(AAPSFont)
		AAP.OptionsFrame["Slider"..i].High:SetFont(select(1, AAP.OptionsFrame["Slider"..i].High:GetFont()), 10, select(3, AAP.OptionsFrame["Slider"..i].High:GetFont()))
		AAP.OptionsFrame["Slider"..i].Text:SetFontObject(AAPSFont)
		AAP.OptionsFrame["Slider"..i].Text:SetFont(select(1, AAP.OptionsFrame["Slider"..i].Text:GetFont()), 10, select(3, AAP.OptionsFrame["Slider"..i].Text:GetFont()))
	end

	for i = 1, 4 do
		_G["AAP_OptionsButtons"..i]:SkinButton()
		local text = AAP.OptionsFrame["Button"..i]:GetText()
		AAP.OptionsFrame["Button"..i]:SetText("")
		AAP.OptionsFrame["Button"..i].Text = AAP.OptionsFrame["Button"..i]:CreateFontString(nil, "OVERLAY")
		AAP.OptionsFrame["Button"..i].Text:SetFontObject(AAPSFont)
		AAP.OptionsFrame["Button"..i].Text:SetFont(select(1, AAP.OptionsFrame["Button"..i].Text:GetFont()), 12, select(3, AAP.OptionsFrame["Button"..i].Text:GetFont()))
		AAP.OptionsFrame["Button"..i].Text:SetTextColor(255, 255, 0)
		AAP.OptionsFrame["Button"..i].Text:SetText(text)
		AAP.OptionsFrame["Button"..i].Text:SetPoint("CENTER", 0, 0)
	end

	AAP_Warcamp2:StripTextures()
	AAP_Warcamp2:CreateShadow(true)
	AAP.QuestList.WarcampFS2:SetFontObject(AAPSFont)
	AAP.QuestList.WarcampFS2:SetFont(select(1, AAP.QuestList.WarcampFS2:GetFont()), 14, select(3, AAP.QuestList.WarcampFS2:GetFont()))

	for i = 1, 2 do
		_G["AAP_WarCampB"..i]:SkinButton()
		local text = AAP.QuestList["WarcampB"..i]:GetText()
		AAP.QuestList["WarcampB"..i]:SetText("")
		AAP.QuestList["WarcampB"..i].Text = AAP.QuestList["WarcampB"..i]:CreateFontString(nil, "OVERLAY")
		AAP.QuestList["WarcampB"..i].Text:SetFontObject(AAPSFont)
		AAP.QuestList["WarcampB"..i].Text:SetFont(select(1, AAP.QuestList["WarcampB"..i].Text:GetFont()), 12, select(3, AAP.QuestList["WarcampB"..i].Text:GetFont()))
		AAP.QuestList["WarcampB"..i].Text:SetTextColor(255, 255, 0)
		AAP.QuestList["WarcampB"..i].Text:SetText(text)
		AAP.QuestList["WarcampB"..i].Text:SetPoint("CENTER", 0, 0)
	end

	AAP_AFkFrames:StripTextures()
	AAP_AFkFrames:CreateShadow(true)
	AAP_AfkFrame.Fontstring:SetFontObject(AAPSFont)
	AAP_AfkFrame.Fontstring:SetFont(select(1, AAP_AfkFrame.Fontstring:GetFont()), 20, select(3, AAP_AfkFrame.Fontstring:GetFont()))
	AAP_ArrowActiveButton:StripTextures()
	AAP_ArrowActiveButton:CreateShadow(true)
	AAP_ArrowFrame.Fontstring:SetFontObject(AAPSFont)
	AAP_ArrowFrame.Fontstring:SetFont(select(1, AAP_ArrowFrame.Fontstring:GetFont()), 8, select(3, AAP_ArrowFrame.Fontstring:GetFont()))
	AAP_ArrowFrame.Fontstring:SetWidth(AAP_ArrowFrame.Fontstring:GetStringWidth() + 100)
	AAP_ArrowFrame.Button:SetWidth(AAP_ArrowFrame.Fontstring:GetStringWidth() + 2)
	AAP_ArrowFrame.distance:SetFontObject(AAPSFont)
	AAP_ArrowFrame.distance:SetFont(select(1, AAP_ArrowFrame.distance:GetFont()), 10, select(3, AAP_ArrowFrame.distance:GetFont()))

	AAP_BrutalFrames1:StripTextures()
	AAP_BrutalFrames2:StripTextures()
	AAP_BrutalFrames1:CreateShadow(true)
	AAP_BrutalFrames2:CreateShadow(true)
	AAP.BrutallCC.BrutallFrame.FrameName:SetPoint("TOP", AAP.BrutallCC.BrutallFrame.Frame, "TOP",-25,27)

	for i = 1, 4 do
		AAP.BrutallCC.BrutallFrame["FS"..i]:SetFont(AAPSFont, 16)
	end

	AAP.QuestList.SugQuestFrameFS1:SetFontObject(AAPSFont)
	AAP.QuestList.SugQuestFrameFS1:SetFont(select(1, AAP.QuestList.SugQuestFrameFS1:GetFont()), 20, select(3, AAP.QuestList.SugQuestFrameFS1:GetFont()))
	AAP.QuestList.SugQuestFrameFS2:SetFontObject(AAPSFont)
	AAP.QuestList.SugQuestFrameFS2:SetFont(select(1, AAP.QuestList.SugQuestFrameFS2:GetFont()), 15, select(3, AAP.QuestList.SugQuestFrameFS2:GetFont()))
	AAP_SBX1:SkinButton()
	AAP_SBX2:SkinButton()

	for i = 1, 20 do
		AAP.QuestList2["BF"..i]["AAP_Button"]:SetPoint("LEFT",AAP.QuestList2["BF"..i],"RIGHT",1,0)
	end

	AAP.Banners.BannersFrame.FrameFS1:SetFontObject(AAPSFont)
	AAP.Banners.BannersFrame.FrameFS1:SetFont(select(1, AAP.Banners.BannersFrame.FrameFS1:GetFont()), 8, select(3, AAP.Banners.BannersFrame.FrameFS1:GetFont()))
	AAP.Banners.BannersFrame.FrameFS2:SetFontObject(AAPSFont)
	AAP.Banners.BannersFrame.FrameFS2:SetFont(select(1, AAP.Banners.BannersFrame.FrameFS2:GetFont()), 10, select(3, AAP.Banners.BannersFrame.FrameFS2:GetFont()))
	AAP.Banners.BannersFrame.B1:SetPoint("TOP", AAP.Banners.BannersFrame.Frame, "BOTTOM", 0, -1)
	AAP.Banners.BannersFrame.B1.icon = AAP.Banners.BannersFrame.B1:GetNormalTexture()

	for i = 1, 5 do
		_G["AAP_BannersFrames"..i]:StripTextures()
		_G["AAP_BannersFrames"..i]:CreateShadow(true)

		if i < 4 then
			AAP.Banners.BannersFrame["B"..i].icon = AAP.Banners.BannersFrame["B"..i]:GetNormalTexture()
		end

		if AAP.Banners.BannersFrame["FrameB2"..i] then
			_G["AAP_BannersFrames2B"..i]:StripTextures()
			_G["AAP_BannersFrames2B"..i]:CreateShadow(true)
			--_G["AAP_BannersFramesz2B"..i]:SetStatusBarTexture(AAPTexture)
			AAP.Banners.BannersFrame["FrameB2"..i]:SetWidth(29)
			AAP.Banners.BannersFrame["FrameB2"..i]:SetHeight(29)
		end

		if AAP.Banners.BannersFrame["FrameB3"..i] then
			_G["AAP_BannersFrames3B"..i]:StripTextures()
			_G["AAP_BannersFrames3B"..i]:CreateShadow(true)
			--_G["AAP_BannersFramesz3B"..i]:SetStatusBarTexture(AAPTexture)
			AAP.Banners.BannersFrame["FrameB3"..i]:SetWidth(29)
			AAP.Banners.BannersFrame["FrameB3"..i]:SetHeight(29)
		end

		if AAP.Banners.BannersFrame["FrameB4"..i] then
			_G["AAP_BannersFrames4B"..i]:StripTextures()
			_G["AAP_BannersFrames4B"..i]:CreateShadow(true)
			--_G["AAP_BannersFramesz4B"..i]:SetStatusBarTexture(AAPTexture)
			AAP.Banners.BannersFrame["FrameB4"..i]:SetWidth(29)
			AAP.Banners.BannersFrame["FrameB4"..i]:SetHeight(29)
		end

		if 	AAP.Banners.BannersFrame["Frame"..i] then
			AAP.Banners.BannersFrame["Frame"..i]:SetPoint("TOPLEFT", AAP.Banners.BannersFrame, "TOPLEFT",-(33*i),0)
			AAP.Banners.BannersFrame["FrameB2"..i]:SetPoint("TOP", AAP.Banners.BannersFrame["Frame"..i], "BOTTOM", 0, -2)

			AAP.Banners.BannersFrame["FrameFS1"..i]:SetFontObject(AAPSFont)
			AAP.Banners.BannersFrame["FrameFS1"..i]:SetFont(select(1, AAP.Banners.BannersFrame["FrameFS1"..i]:GetFont()), 8, select(3, AAP.Banners.BannersFrame["FrameFS1"..i]:GetFont()))
			AAP.Banners.BannersFrame["FrameFSs"..i]:SetFontObject(AAPSFont)
			AAP.Banners.BannersFrame["FrameFSs"..i]:SetFont(select(1, AAP.Banners.BannersFrame["FrameFSs"..i]:GetFont()), 10, select(3, AAP.Banners.BannersFrame["FrameFSs"..i]:GetFont()))
		end
	end
end

--if IsAddOnLoaded("Azeroth Auto Pilot") then
--	table.insert(ModuleSkins.SkinFuncs["KkthnxUI"], Module.SkinAzerothAutoPilot)
--else
--	Module.SkinFuncs["Skada"] = Module.SkinAzerothAutoPilot
--end

Module.SkinFuncs["Skada"] = Module.SkinAzerothAutoPilot