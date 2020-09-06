local K = unpack(select(2, ...))
local Module = K:GetModule("Skins")

local _G = _G
local table_insert = _G.table.insert

local hooksecurefunc = _G.hooksecurefunc

-- Party Sync button
local function SkinWorldMapFrame()
	local sessionManagement = _G.QuestMapFrame.QuestSessionManagement

	local executeSessionCommand = sessionManagement.ExecuteSessionCommand
	executeSessionCommand:SetSize(36, 36)
	executeSessionCommand:SkinButton()

	local icon = executeSessionCommand:CreateTexture(nil, "ARTWORK")
	icon:SetAllPoints()
	executeSessionCommand.normalIcon = icon

	local sessionCommandToButtonAtlas = {
		[_G.Enum.QuestSessionCommand.Start] = "QuestSharing-DialogIcon",
		[_G.Enum.QuestSessionCommand.Stop] = "QuestSharing-Stop-DialogIcon"
	}

	hooksecurefunc(_G.QuestMapFrame.QuestSessionManagement, "UpdateExecuteCommandAtlases", function(self, command)
		self.ExecuteSessionCommand:SetNormalTexture("")
		self.ExecuteSessionCommand:SetPushedTexture("")
		self.ExecuteSessionCommand:SetDisabledTexture("")

		local atlas = sessionCommandToButtonAtlas[command]
		if atlas then
			self.ExecuteSessionCommand.normalIcon:SetAtlas(atlas)
		end
	end)
end

table_insert(Module.NewSkin["KkthnxUI"], SkinWorldMapFrame)