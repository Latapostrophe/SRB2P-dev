-- Defines request related constants as well as every request!

rawset(_G, "MAXREQUESTS", 30)
rawset(_G, "MAXACCEPTREQUESTS", 3)


-- quest status (for srb2p.storymode)
local queststatus = {
	"QS_UNAVAILABLE",	-- Locked (disoplays as ???)
	"QS_NEW",		-- New request (shows a '!')
	"QS_CHECKED",		-- Checked once
	"QS_ACCEPTEDONCE",	-- Similar to QS_CHECKED, but implies the quest was accepted and then cancelled. (for first time rewards)	
	"QS_SUBMITTABLE",	-- Completed, can be submitted to change status to QS_CLEARED or QS_CLEAREDONCE
	"QS_CLEAREDONCE",	-- Similar to QS_CHECKED, but implies the quest was accepted and then cleared once. (for repeatable quests)	
	"QS_ACCEPTED",		-- Accepted
	"QS_CLEARED",		-- Cleared and cannot be accepted anymore.
}
for i = 1, #queststatus
	rawset(_G, queststatus[i], i-1)
end

-- objective types:
local objectives = {
	"OBJ_ITEM",
	"OBJ_ENEMY",
	"OBJ_ENHANCE",
	"OBJ_FUSION",
	"OBJ_EVENTFLAG",
	"OBJ_CUSTOM"
}

for i = 1, #objectives
	rawset(_G, objectives[i], i)
end

-- acquire constants for item objectives.
local acquire = {
	"ACQ_ANY",		-- any method
	"ACQ_DROP",		-- item must be dropped from an enemy or an item box
	"ACQ_BUY",		-- item must be purchased
	"ACQ_TRADE",	-- item must be exchanged for
}

for i = 1, #acquire
	rawset(_G, acquire[i], i-1)
end

rawset(_G, "requestsList", {

-- 001
{
	
	title = "Using the shop",
	sender = "Alt",
	desc = "Hey, just reminding you that I hold a shop with various items you can buy anytime with no limits! Swing by sometime and buy something with Macca!",
	objectives = {
		{
			type = OBJ_ITEM,
			data = {nil, 1, ACQ_BUY}
		},
	},
	
	rewards = {
		{"exp", 50},
		{"lexp", 500},
		{"macca", 500},
		{"weapon", "rekla sneakers", 5},
		{"wardring", "rekla rings", 5},
	},

},

-- 002
{
	
	title = "Upgrade your equipment",
	sender = "Ris",
	desc = "Yo! Your equipment's just as important as your Sub-Personas. I'll give you some materials, so bring me your stuff and let's buff it up!",
	objectives = {
		{
			type = OBJ_ENHANCE,
			data = {{"weapon", nil}, 10},
		},

		{
			type = OBJ_ENHANCE,
			data = {{"wardring", nil}, 10},
		},
		
	},
	
	rewards = {
		{"exp", 100},
	},
	
	acceptance = {
		{"item", "amethyst", 20}
	},

},

-- 003
{
	
	title = "Fusion Test",
	sender = "Snow",
	desc = "Hello, I'd like you to fuse a Sub-Persona, whichever you want. It's important that you understand how to do it. I'll be waiting!",
	objectives = {
		{
			type = OBJ_FUSION,
			data = {}
		},
	},
	
	rewards = {
		{"exp", 50},
	},
},

-- 004
{
	
	title = "Fusing Ability I",
	sender = "Snow",
	desc = "Hey, I'd like to test your Sub-Persona Fusion skills. If you can clear this, I'll give you something worthwhile.",
	objectives = {
		{
			type = OBJ_FUSION,
			data = {"pixie", nil, {"bufu"}}
		},
	},
	
	rewards = {
		{"item", "sc/ mabufu", 1},
		{"macca", 1000},
		{"exp", 500},
	},

},

-- 005
})