local K, C, L = unpack(select(2, ...))
if C["Chat"].SpamFilter ~= true then return end

-- Spam keywords
K.ChatSpamList = {
	",com",
	".c.0.m",
	".c0m",
	"{circle}",
	"{cross}",
	"{diamond}",
	"{moon}",
	"{skull}",
	"{square}",
	"{star}",
	"{triangle}",
	"%[.*%].*%[dirge%]",
	"%[.*%].*%[willy%]",
	"%[.*%].*anal",
	"%[.*%].*in.*bed",
	"%[.*%].*rectum",
	"%[dirge%].*%[.*%]",
	"%[willy%].*%[.*%]",
	"█",
	"░",
	"▒",
	"▓",
	"anal.*%[.*%]",
	"in.*bed.*%[.*%]",
	"rectum.*%[.*%]",
	"w.w.w",
	"wts",
	"www",
}