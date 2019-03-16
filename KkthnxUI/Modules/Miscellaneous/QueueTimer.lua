local K, C = unpack(select(2, ...))
if K.CheckAddOnState("DBM-Core") or K.CheckAddOnState("BigWigs") then
	return
end

local Module = K:NewModule("QueueTimer", "AceEvent-3.0")

-- Sourced: LFG_ProposalTime (Freebaser)

local _G = _G

local PlaySound = _G.PlaySound
local StopSound = _G.StopSound
local GetTime = _G.GetTime
local CreateFrame = _G.CreateFrame

do
	local prev
	function Module:LFG_PROPOSAL_SHOW()
		if not prev then
			local timerBar = CreateFrame("StatusBar", nil, LFGDungeonReadyPopup)
			timerBar:SetPoint("TOP", LFGDungeonReadyPopup, "BOTTOM", 0, -5)
			local tex = timerBar:CreateTexture()
			tex:SetTexture(C["Media"].Texture)
			timerBar:SetStatusBarTexture(tex)
			timerBar:SetSize(190, 9)
			timerBar:SetStatusBarColor(1, 0.1, 0)
			timerBar:SetMinMaxValues(0, 40)
			timerBar:Show()

			local bg = timerBar:CreateTexture(nil, "BACKGROUND")
			bg:SetAllPoints(timerBar)
			bg:SetColorTexture(C["Media"].BackdropColor[1], C["Media"].BackdropColor[2], C["Media"].BackdropColor[3], C["Media"].BackdropColor[4])

			local spark = timerBar:CreateTexture(nil, "OVERLAY")
			spark:SetTexture(C["Media"].Spark_128)
			spark:SetSize(128, timerBar:GetHeight() or 32)
			spark:SetBlendMode("ADD")
			spark:SetPoint("CENTER", timerBar:GetStatusBarTexture(), "RIGHT", 0, 0)

			local border = timerBar:CreateTexture(nil, "OVERLAY")
			border:SetTexture(130874) -- Interface\\CastingBar\\UI-CastingBar-Border
			border:SetSize(256, 64)
			border:SetPoint("TOP", timerBar, 0, 28)

			timerBar.text = timerBar:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
			timerBar.text:SetPoint("CENTER", timerBar, "CENTER")

			self.LFG_PROPOSAL_SHOW = function()
				prev = GetTime() + 40
				-- Play in Master for those that have SFX off or very low.
				-- Using false as third arg to avoid the "only one of each sound at a time" throttle.
				-- Only play via the "Master" channel if we have sounds turned on
				if self.isSoundOn ~= false then
					local _, id = PlaySound(8960, "Master", false)
					if id then
						StopSound(id - 1) -- Should work most of the time to stop the blizz sound
					end
				end
			end
			self:LFG_PROPOSAL_SHOW()

			timerBar:SetScript("OnUpdate", function(f)
				local timeLeft = prev - GetTime()
				if timeLeft > 0 then
					f:SetValue(timeLeft)
					f.text:SetFormattedText("%.1f", timeLeft)
				end
			end)
		end
	end
end

function Module:OnInitialize()
	self:RegisterEvent("LFG_PROPOSAL_SHOW")
end