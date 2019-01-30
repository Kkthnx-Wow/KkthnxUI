local K, C = unpack(select(2, ...))
local oUF = oUF or K.oUF
assert(oUF, "KkthnxUI was unable to locate oUF.")

-- Source: Kesava @ curse.com.

local ipairs = ipairs
local pairs = pairs
local select = select

local function Cutaway_SetValue(bar, value)
    if not bar:IsVisible() then
        bar:orig_SetValue_Cutaway(value)
        return
    end

    if not bar.Cutaway_Fader.Animation then
        bar.Cutaway_Fader.Animation = bar.Cutaway_Fader:CreateAnimationGroup()
        bar.Cutaway_Fader.Animation.FadeOut = bar.Cutaway_Fader.Animation:CreateAnimation("Alpha")
        bar.Cutaway_Fader.Animation.FadeOut:SetFromAlpha(1)
        bar.Cutaway_Fader.Animation.FadeOut:SetToAlpha(0)
        bar.Cutaway_Fader.Animation.FadeOut:SetDuration(1.6)
        bar.Cutaway_Fader.Animation.FadeOut:SetSmoothing("OUT")
    end

    if value < bar:GetValue() then
        if bar.Cutaway_Fader and bar.Cutaway_Fader.Animation then
            if bar:GetReverseFill() then
                bar.Cutaway_Fader:SetPoint("RIGHT", bar:GetStatusBarTexture(),"LEFT")
                bar.Cutaway_Fader:SetPoint("LEFT", bar, "RIGHT", - (bar:GetValue() / select(2, bar:GetMinMaxValues())) * bar:GetWidth(), 0)
            else
                bar.Cutaway_Fader:SetPoint("LEFT", bar:GetStatusBarTexture(),"RIGHT")
                bar.Cutaway_Fader:SetPoint("RIGHT", bar, "LEFT", (bar:GetValue() / select(2, bar:GetMinMaxValues())) * bar:GetWidth(), 0)
            end

            bar.Cutaway_Fader.right = bar:GetValue()

            bar.Cutaway_Fader.Animation:Play()
            bar.Cutaway_Fader.Animation.Playing = true
            -- K.UIFrameFadeOut(bar.Cutaway_Fader, 2)
        else
            bar.Cutaway_Fader.Animation:Stop()
            bar.Cutaway_Fader.Animation.Playing = false
        end
    end

    if bar.Cutaway_Fader.right and value > bar.Cutaway_Fader.right then
        K.UIFrameFadeRemoveFrame(bar.Cutaway_Fader)
        bar.Cutaway_Fader:SetAlpha(0)
    end

    bar:orig_SetValue_Cutaway(value)
end

local function CutawayBar(frame, bar)
    local fader = bar:CreateTexture(nil, "ARTWORK")
    fader:SetTexture(C["Media"].Blank)
    -- fader:SetVertexColor(140/255, 29/255, 30/255)
    fader:SetVertexColor(bar:GetStatusBarColor() * 1.5)
    fader:SetAlpha(0)

    fader:SetPoint("TOP")
    fader:SetPoint("BOTTOM")

    bar.orig_SetValue_Cutaway = bar.SetValue
    bar.SetValue = Cutaway_SetValue

    bar.Cutaway_Fader = fader
end

local function hook(frame)
    frame.CutawayBar = CutawayBar

    for k, v in pairs({"Health"}) do
        if frame[v] and frame[v].Cutaway then
            frame:CutawayBar(frame[v])
        end
    end
end

for i, f in ipairs(oUF.objects) do
    hook(f)
end
oUF:RegisterInitCallback(hook)