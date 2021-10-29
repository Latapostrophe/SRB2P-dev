local challengetypes = {
	"VC_ERADICATION",
	"VC_INFILTRATION",
	"VC_HUNT",
	"VC_REPEL",
	"VC_EXPLOIT",
	"VC_BOSS",
}

local challengeclauses = {
	
	"VE_SKILLJAMMER",
	"VE_ITEMJAMMER",
	"VE_NOSKILLS",
	"VE_NOITEMS",
}

for i = 1, #challengeclauses
	rawset(_G, challengeclauses[i], i)
end

for i = 1, #challengetypes
	rawset(_G, challengetypes[i], i)
end