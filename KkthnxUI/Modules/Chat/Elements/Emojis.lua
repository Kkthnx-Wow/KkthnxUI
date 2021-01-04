local K, C = unpack(select(2, ...))
local Module = K:GetModule("Chat")

local _G = _G
local string_gmatch = _G.string.gmatch
local string_gsub = _G.string.gsub
local string_match = _G.string.match
local string_trim = _G.string.trim

local ChatFrame_AddMessageEventFilter = _G.ChatFrame_AddMessageEventFilter

-- Thanks to ElvUI for providing great textures
local getEmojiMedia = "Interface\\Addons\\KkthnxUI\\Media\\Chat\\Emojis\\"
local setEmojiTexture = {
	Angry = getEmojiMedia.."Angry.tga",
	Blush = getEmojiMedia.."Blush.tga",
	BrokenHeart = getEmojiMedia.."BrokenHeart.tga",
	CallMe = getEmojiMedia.."CallMe.tga",
	Cry = getEmojiMedia.."Cry.tga",
	Facepalm = getEmojiMedia.."Facepalm.tga",
	Grin = getEmojiMedia.."Grin.tga",
	Heart = getEmojiMedia.."Heart.tga",
	HeartEyes = getEmojiMedia.."HeartEyes.tga",
	Joy = getEmojiMedia.."Joy.tga",
	Kappa = getEmojiMedia.."Kappa.tga",
	Meaw = getEmojiMedia.."Meaw.tga",
	MiddleFinger = getEmojiMedia.."MiddleFinger.tga",
	Murloc = getEmojiMedia.."Murloc.tga",
	OkHand = getEmojiMedia.."OkHand.tga",
	OpenMouth = getEmojiMedia.."OpenMouth.tga",
	Poop = getEmojiMedia.."Poop.tga",
	Rage = getEmojiMedia.."Rage.tga",
	SadKitty = getEmojiMedia.."SadKitty.tga",
	Scream = getEmojiMedia.."Scream.tga",
	ScreamCat = getEmojiMedia.."ScreamCat.tga",
	SemiColon = getEmojiMedia.."SemiColon.tga",
	SlightFrown = getEmojiMedia.."SlightFrown.tga",
	Smile = getEmojiMedia.."Smile.tga",
	Smirk = getEmojiMedia.."Smirk.tga",
	Sob = getEmojiMedia.."Sob.tga",
	StuckOutTongue = getEmojiMedia.."StuckOutTongue.tga",
	StuckOutTongueClosedEyes = getEmojiMedia.."StuckOutTongueClosedEyes.tga",
	Sunglasses = getEmojiMedia.."Sunglasses.tga",
	Thinking = getEmojiMedia.."Thinking.tga",
	ThumbsUp = getEmojiMedia.."ThumbsUp.tga",
	Wink = getEmojiMedia.."Wink.tga",
	ZZZ = getEmojiMedia.."ZZZ.tga",
}

-- EMOJI EXPRESSION MAPS
local setEmoji = {}
setEmoji[",,!,,"] = setEmojiTexture.MiddleFinger
setEmoji["8%)"] = setEmojiTexture.Sunglasses
setEmoji["8%-%)"] = setEmojiTexture.Sunglasses
setEmoji[":%$"] = setEmojiTexture.Blush
setEmoji[":%("] = setEmojiTexture.SlightFrown
setEmoji[":%)"] = setEmojiTexture.Smile
setEmoji[":%+1:"] = setEmojiTexture.ThumbsUp
setEmoji[":%-%("] = setEmojiTexture.SlightFrown
setEmoji[":%-%)"] = setEmojiTexture.Smile
setEmoji[":%-0"] = setEmojiTexture.OpenMouth
setEmoji[":%-@"] = setEmojiTexture.Angry
setEmoji[":%-D"] = setEmojiTexture.Grin
setEmoji[":%-O"] = setEmojiTexture.OpenMouth
setEmoji[":%-P"] = setEmojiTexture.StuckOutTongue
setEmoji[":%-S"] = setEmojiTexture.Smirk
setEmoji[":%-o"] = setEmojiTexture.OpenMouth
setEmoji[":%-p"] = setEmojiTexture.StuckOutTongue
setEmoji[":,%("] = setEmojiTexture.Cry
setEmoji[":,%-%("] = setEmojiTexture.Cry
setEmoji[":;:"] = setEmojiTexture.SemiColon
setEmoji[":@"] = setEmojiTexture.Angry
setEmoji[":D"] = setEmojiTexture.Grin
setEmoji[":F"] = setEmojiTexture.MiddleFinger
setEmoji[":O"] = setEmojiTexture.OpenMouth
setEmoji[":P"] = setEmojiTexture.StuckOutTongue
setEmoji[":S"] = setEmojiTexture.Smirk
setEmoji[":\"%("] = setEmojiTexture.Cry
setEmoji[":\"%)"] = setEmojiTexture.Joy
setEmoji[":\"%-%("] = setEmojiTexture.Cry
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
setEmoji[":meaw:"] = setEmojiTexture.Meaw
setEmoji[":middle_finger:"] = setEmojiTexture.MiddleFinger
setEmoji[":murloc:"] = setEmojiTexture.Murloc
setEmoji[":o"] = setEmojiTexture.OpenMouth
setEmoji[":o3"] = setEmojiTexture.ScreamCat
setEmoji[":ok_hand:"] = setEmojiTexture.OkHand
setEmoji[":open_mouth:"] = setEmojiTexture.OpenMouth
setEmoji[":p"] = setEmojiTexture.StuckOutTongue
setEmoji[":poop:"] = setEmojiTexture.Poop
setEmoji[":rage:"] = setEmojiTexture.Rage
setEmoji[":sadkitty:"] = setEmojiTexture.SadKitty
setEmoji[":scream:"] = setEmojiTexture.Scream
setEmoji[":scream_cat:"] = setEmojiTexture.ScreamCat
setEmoji[":semi_colon:"] = setEmojiTexture.SemiColon
setEmoji[":slight_frown:"] = setEmojiTexture.SlightFrown
setEmoji[":smile:"] = setEmojiTexture.Smile
setEmoji[":smirk:"] = setEmojiTexture.Smirk
setEmoji[":sob:"] = setEmojiTexture.Sob
setEmoji[":stuck_out_tongue:"] = setEmojiTexture.StuckOutTongue
setEmoji[":stuck_out_tongue_closed_eyes:"] = setEmojiTexture.StuckOutTongueClosedEyes
setEmoji[":sunglasses:"] = setEmojiTexture.Sunglasses
setEmoji[":thinking:"] = setEmojiTexture.Thinking
setEmoji[":thumbs_up:"] = setEmojiTexture.ThumbsUp
setEmoji[":wink:"] = setEmojiTexture.Wink
setEmoji[":zzz:"] = setEmojiTexture.ZZZ
setEmoji[";%)"] = setEmojiTexture.Wink
setEmoji[";%-%)"] = setEmojiTexture.Wink
setEmoji[";%-D"] = setEmojiTexture.Grin
setEmoji[";%-P"] = setEmojiTexture.StuckOutTongueClosedEyes
setEmoji[";%-p"] = setEmojiTexture.StuckOutTongueClosedEyes
setEmoji[";D"] = setEmojiTexture.Grin
setEmoji[";P"] = setEmojiTexture.StuckOutTongueClosedEyes
setEmoji[";\"%)"] = setEmojiTexture.Joy
setEmoji[";o;"] = setEmojiTexture.Sob
setEmoji[";p"] = setEmojiTexture.StuckOutTongueClosedEyes
setEmoji["</3"] = setEmojiTexture.BrokenHeart
setEmoji["<3"] = setEmojiTexture.Heart
setEmoji["<\\3"] = setEmojiTexture.BrokenHeart
setEmoji["=D"] = setEmojiTexture.Grin
setEmoji["=P"] = setEmojiTexture.StuckOutTongue
setEmoji["=p"] = setEmojiTexture.StuckOutTongue
setEmoji[">:%("] = setEmojiTexture.Rage
setEmoji["D:<"] = setEmojiTexture.Rage
setEmoji["XD"] = setEmojiTexture.Grin
setEmoji["XP"] = setEmojiTexture.StuckOutTongueClosedEyes
setEmoji["xD"] = setEmojiTexture.Grin

-- replace emojis
function Module:SetupEmojis(_, msg)
	for word in string_gmatch(msg, "%s-%S+%s*") do
		word = string_trim(word)
		local pattern = string_gsub(word, "([%(%)%.%%%+%-%*%?%[%^%$])", "%%%1")
		local emoji = setEmoji[pattern]

		if emoji and string_match(msg, "[%s%p]-"..pattern.."[%s%p]*") then
			emoji = "|T"..emoji..":14:14|t"
			local base64 = K.Base64:Encode(word)
			msg = string_gsub(msg, "([%s%p]-)"..pattern.."([%s%p]*)", (base64 and ("%1|Helvmoji:%%"..base64.."|h|cFFffffff|r|h") or "%1")..emoji.."%2")
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
	ChatFrame_AddMessageEventFilter("CHAT_MSG_CHANNEL", Module.ApplyEmojis)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_GUILD", Module.ApplyEmojis)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT", Module.ApplyEmojis)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_INSTANCE_CHAT_LEADER", Module.ApplyEmojis)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_OFFICER", Module.ApplyEmojis)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY", Module.ApplyEmojis)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_PARTY_LEADER", Module.ApplyEmojis)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID", Module.ApplyEmojis)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_LEADER", Module.ApplyEmojis)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_RAID_WARNING", Module.ApplyEmojis)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_SAY", Module.ApplyEmojis)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER", Module.ApplyEmojis)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_WHISPER_INFORM", Module.ApplyEmojis)
	ChatFrame_AddMessageEventFilter("CHAT_MSG_YELL", Module.ApplyEmojis)
end