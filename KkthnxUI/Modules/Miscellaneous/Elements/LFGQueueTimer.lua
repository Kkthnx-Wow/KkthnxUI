local K, C = unpack(select(2, ...))
local Module = K:GetModule("Miscellaneous")

local _G = _G

local CreateFrame = _G.CreateFrame
local GetTime = _G.GetTime
local IsAddOnLoaded = _G.IsAddOnLoaded

-- Queue timer on LFGDungeonReadyDialog

local prev
function Module:SetupLFGProposalTime()
	if not prev then
		local timerBar = CreateFrame("StatusBar", nil, LFGDungeonReadyDialog)
		timerBar:SetPoint("TOP", LFGDungeonReadyDialog, "BOTTOM", 0, -4)
		timerBar:SetStatusBarTexture(K.GetTexture(C["UITextures"].GeneralTextures))
		timerBar:SetSize(240, 14)
		timerBar:SetStatusBarColor(1, 0.1, 0)
		timerBar:SetMinMaxValues(0, 40)
		timerBar:CreateBorder()
		timerBar:Show()

		timerBar.spark = timerBar:CreateTexture(nil, "OVERLAY")
		timerBar.spark:SetTexture(C["Media"].Spark_128)
		timerBar.spark:SetSize(64, 14)
		timerBar.spark:SetBlendMode("ADD")
		timerBar.spark:SetPoint("CENTER", timerBar:GetStatusBarTexture(), "RIGHT", 0, 0)

		timerBar.text = timerBar:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
		timerBar.text:SetPoint("CENTER", timerBar, "CENTER")

		Module.LFG_PROPOSAL_SHOW = function()
			prev = GetTime() + 40
			-- Play in Master for those that have SFX off or very low.
			-- Using false as third arg to avoid the "only one of each sound at a time" throttle.
			-- Only play via the "Master" channel if we have sounds turned on
			local _, id = PlaySound(8960, "Master", false) -- SOUNDKIT.READY_CHECK
			if id then
				StopSound(id - 1) -- Should work most of the time to stop the blizz sound
			end
		end
		Module:LFG_PROPOSAL_SHOW()

		timerBar:SetScript("OnUpdate", function(f)
			local timeLeft = prev - GetTime()
			if timeLeft > 0 then
				f:SetValue(timeLeft)
				f.text:SetFormattedText("KkthnxUI: %.1f", timeLeft)
			end
		end)
	end
end

-- No config option for this as this will be disabled if replaced by one of the 2 addons that provide this.
-- This is an important QoL addition.
function Module:CreateLFGProposalTime()
	if IsAddOnLoaded("DBM-Core") or IsAddOnLoaded("BigWigs") then
		return
	end

	K:RegisterEvent("LFG_PROPOSAL_SHOW", Module.SetupLFGProposalTime)
end