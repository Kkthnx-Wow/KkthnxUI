local K, C = unpack(select(2, ...))
local Module = K:GetModule("Chat")

local _G = _G

-- Thanks to ElvUI for providing great textures
local p = "Interface\\Addons\\KkthnxUI\\Media\\Chat\\Emojis\\"
local setEmojiTexture = {
	Angry = p.."Angry.tga",
	Blush = p.."Blush.tga",
	BrokenHeart = p.."BrokenHeart.tga",
	CallMe = p.."CallMe.tga",
	Cry = p.."Cry.tga",
	Facepalm = p.."Facepalm.tga",
	Grin = p.."Grin.tga",
	Heart = p.."Heart.tga",
	HeartEyes = p.."HeartEyes.tga",
 	Joy = p.."Joy.tga",
	Kappa = p.."Kappa.tga",
	Meaw = p.."Meaw.tga",
	MiddleFinger = p.."MiddleFinger.tga",
	Murloc = p.."Murloc.tga",
	OkHand = p.."OkHand.tga",
	OpenMouth = p.."OpenMouth.tga",
	Poop = p.."Poop.tga",
	Rage = p.."Rage.tga",
	SadKitty = p.."SadKitty.tga",
	Scream = p.."Scream.tga",
	ScreamCat = p.."ScreamCat.tga",
	SemiColon = p.."SemiColon.tga",
	SlightFrown = p.."SlightFrown.tga",
	Smile = p.."Smile.tga",
	Smirk = p.."Smirk.tga",
	Sob = p.."Sob.tga",
	StuckOutTongue = p.."StuckOutTongue.tga",
	StuckOutTongueClosedEyes = p.."StuckOutTongueClosedEyes.tga",
	Sunglasses = p.."Sunglasses.tga",
	Thinking = p.."Thinking.tga",
	ThumbsUp = p.."ThumbsUp.tga",
	Wink = p.."Wink.tga",
	ZZZ = p.."ZZZ.tga"
}

-- EMOJI EXPRESSION MAPS
local setEmoji = {}
setEmoji[":angry:"] = setEmojiTexture.Angry
setEmoji[":blush:"] = setEmojiTexture.Blush
setEmoji[":broken_heart:"] = setEmojiTexture.BrokenHeart
setEmoji[":call_me:"] = setEmojiTexture.CallMe
setEmoji[":cry:"] = setEmojiTexture.Cry
setEmoji[":facepalm:"] = setEmojiTexture.Facepalm
setEmoji[":grin:"] = setEmojiTexture.Grin
setEmoji[":heart:"] = setEmojiTexture.Heart
setEmoji[":heart_eyes:"] = setEmojiTexture.HeartEyes
setEmoji[":joy:"] = setEmojiTexture.Joy
setEmoji[":kappa:"] = setEmojiTexture.Kappa
setEmoji[":middle_finger:"] = setEmojiTexture.MiddleFinger
setEmoji[":murloc:"] = setEmojiTexture.Murloc
setEmoji[":ok_hand:"] = setEmojiTexture.OkHand
setEmoji[":open_mouth:"] = setEmojiTexture.OpenMouth
setEmoji[":poop:"] = setEmojiTexture.Poop
setEmoji[":rage:"] = setEmojiTexture.Rage
setEmoji[":sadkitty:"] = setEmojiTexture.SadKitty
setEmoji[":scream:"] = setEmojiTexture.Scream
setEmoji[":scream_cat:"] = setEmojiTexture.ScreamCat
setEmoji[":slight_frown:"] = setEmojiTexture.SlightFrown
setEmoji[":smile:"] = setEmojiTexture.Smile
setEmoji[":smirk:"] = setEmojiTexture.Smirk
setEmoji[":sob:"] = setEmojiTexture.Sob
setEmoji[":sunglasses:"] = setEmojiTexture.Sunglasses
setEmoji[":thinking:"] = setEmojiTexture.Thinking
setEmoji[":thumbs_up:"] = setEmojiTexture.ThumbsUp
setEmoji[":semi_colon:"] = setEmojiTexture.SemiColon
setEmoji[":wink:"] = setEmojiTexture.Wink
setEmoji[":zzz:"] = setEmojiTexture.ZZZ
setEmoji[":stuck_out_tongue:"] = setEmojiTexture.StuckOutTongue
setEmoji[":stuck_out_tongue_closed_eyes:"] = setEmojiTexture.StuckOutTongueClosedEyes
setEmoji[":meaw:"] = setEmojiTexture.Meaw
setEmoji[">:%("] = setEmojiTexture.Rage
setEmoji[":%$"] = setEmojiTexture.Blush
setEmoji["<\\3"] = setEmojiTexture.BrokenHeart
setEmoji[":\"%)"] = setEmojiTexture.Joy
setEmoji["\"%)"] = setEmojiTexture.Joy
setEmoji[",,!,,"] = setEmojiTexture.MiddleFinger
setEmoji["D:<"] = setEmojiTexture.Rage
setEmoji[":o3"] = setEmojiTexture.ScreamCat
setEmoji["XP"] = setEmojiTexture.StuckOutTongueClosedEyes
setEmoji["8%-%)"] = setEmojiTexture.Sunglasses
setEmoji["8%)"] = setEmojiTexture.Sunglasses
setEmoji[":%+1:"] = setEmojiTexture.ThumbsUp
setEmoji["::"] = setEmojiTexture.SemiColon
setEmoji["o"] = setEmojiTexture.Sob
setEmoji[":%-@"] = setEmojiTexture.Angry
setEmoji[":@"] = setEmojiTexture.Angry
setEmoji[":%-%)"] = setEmojiTexture.Smile
setEmoji[":%)"] = setEmojiTexture.Smile
setEmoji[":D"] = setEmojiTexture.Grin
setEmoji[":%-D"] = setEmojiTexture.Grin
setEmoji["%-D"] = setEmojiTexture.Grin
setEmoji["D"] = setEmojiTexture.Grin
setEmoji["=D"] = setEmojiTexture.Grin
setEmoji["xD"] = setEmojiTexture.Grin
setEmoji["XD"] = setEmojiTexture.Grin
setEmoji[":%-%("] = setEmojiTexture.SlightFrown
setEmoji[":%("] = setEmojiTexture.SlightFrown
setEmoji[":o"] = setEmojiTexture.OpenMouth
setEmoji[":%-o"] = setEmojiTexture.OpenMouth
setEmoji[":%-O"] = setEmojiTexture.OpenMouth
setEmoji[":O"] = setEmojiTexture.OpenMouth
setEmoji[":%-0"] = setEmojiTexture.OpenMouth
setEmoji[":P"] = setEmojiTexture.StuckOutTongue
setEmoji[":%-P"] = setEmojiTexture.StuckOutTongue
setEmoji[":p"] = setEmojiTexture.StuckOutTongue
setEmoji[":%-p"] = setEmojiTexture.StuckOutTongue
setEmoji["=P"] = setEmojiTexture.StuckOutTongue
setEmoji["=p"] = setEmojiTexture.StuckOutTongue
setEmoji["%-p"] = setEmojiTexture.StuckOutTongueClosedEyes
setEmoji["p"] = setEmojiTexture.StuckOutTongueClosedEyes
setEmoji["P"] = setEmojiTexture.StuckOutTongueClosedEyes
setEmoji["%-P"] = setEmojiTexture.StuckOutTongueClosedEyes
setEmoji["%-%)"] = setEmojiTexture.Wink
setEmoji["%)"] = setEmojiTexture.Wink
setEmoji[":S"] = setEmojiTexture.Smirk
setEmoji[":%-S"] = setEmojiTexture.Smirk
setEmoji[":,%("] = setEmojiTexture.Cry
setEmoji[":,%-%("] = setEmojiTexture.Cry
setEmoji[":\"%("] = setEmojiTexture.Cry
setEmoji[":\"%-%("] = setEmojiTexture.Cry
setEmoji[":F"] = setEmojiTexture.MiddleFinger
setEmoji["<3"] = setEmojiTexture.Heart
setEmoji["</3"] = setEmojiTexture.BrokenHeart

-- replace emojis
function Module:SetupEmojis(event, msg)
	for word in gmatch(msg, "%s-%S+%s*") do
		word = strtrim(word)
		local pattern = gsub(word, "([%(%)%.%%%+%-%*%?%[%^%$])", "%%%1")
		local emoji = setEmoji[pattern]

		if emoji and strmatch(msg, "[%s%p]-"..pattern.."[%s%p]*") then
			emoji = "|T"..emoji..":12|t"
			local base64 = K.Base64:Encode(word)
			msg = gsub(msg, "([%s%p]-)"..pattern.."([%s%p]*)", (base64 and ("%1|Hbduimoji:%%"..base64.."|h|cFFffffff|r|h") or "%1")..emoji.."%2")
		end
	end

	return msg
end

-- filter the message thats sent after the encoded string
function Module:ApplyEmojis(event, msg, ...)
	msg = Module:SetupEmojis(event, msg)
	return false, msg, ...
end

function Module:CreateEmojis()
    if not C["Chat"].Emojis then
        return
    end

	ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER", Module.ApplyEmojis)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_BN_WHISPER_INFORM", Module.ApplyEmojis)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", Module.ApplyEmojis)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_OFFICER", Module.ApplyEmojis)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", Module.ApplyEmojis)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", Module.ApplyEmojis)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", Module.ApplyEmojis)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", Module.ApplyEmojis)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_WARNING", Module.ApplyEmojis)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", Module.ApplyEmojis)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", Module.ApplyEmojis)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", Module.ApplyEmojis)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", Module.ApplyEmojis)
    ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", Module.ApplyEmojis)
end