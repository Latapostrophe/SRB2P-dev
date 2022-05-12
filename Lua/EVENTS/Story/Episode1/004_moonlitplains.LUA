-- Story script for MAP24
-- Contains associated events and item drop tables

local mapnum = 24	-- change this if the mapnum changes for w/e reason

-- NPCs
local partynpcdta = {
	
	flag2 = "",
	npcdta = {

		-- Tails
		[1] = {
			angle = 0,
			text1 = "It's hard to believe the grass turns blue during the Dark Hour...",
			text2 = "It's hard to believe the grass turns blue during the Dark Hour...",
		},
		-- Knuckles
		[2] = {
			angle = ANG1*25,
			text1 = "Tails' gotta be furhter in, let's press on!",
			text2 = "This place is still weird looking even after all this time...",
		},
		-- Amy
		[3] = {
			angle = ANG1*10,
			text1 = "There's an eerie feeling about this place...",
			text2 = "That area still feels off even after all that time...",
		},		
		-- Metal Sonic
		[4] = {
			angle = ANG1*300,
			text1 = "...",
			text2 = "...",
		},
		-- Shadow
		[5] = {
			angle = ANG1*75,
			text1 = "So these are the effects of the Dark Hour on such basic places...",
			text2 = "So these are the effects of the Dark Hour on such basic places...",
		},
		-- Silver
		[6] = {
			angle = ANG1*280,
			text1 = "That eerie feeling... It reminds me of home...",
			text2 = "That eerie feeling... It reminds me of home...",
		},
		-- Blaze
		[7] = {
			angle = ANG1*270,
			text1 = "This is what could become of this world if we don't act...",
			text2 = "This is what could become of this world if we don't act...",
		},
		-- Eggman
		[8] = {
			angle = ANG1*315,
			text1 = "So this is what this Dark Hour is cappable of...",
			text2 = "It seems the distortion here is as strong as ever...",
		},
	}
}

-- Initialise party NPCs
D_initPartyNPCs(mapnum, partynpcdta)

-- Initialize Velvet Room
D_initVelvetRoomNPC(mapnum, ANG1*300)

-- enemy waves
DNG_dungeonwaves[mapnum] = {
			
	[1] = 	{
				{	"maya_1",
					"maya_1",
				},
			},
			
	[2] = {

		{	"maya_1",
			"maya_1",
			"maya_1",
		},
		
		{
			"hablerie_1",
			"hand_1",
		},
		
		{
			"maya_1",
			"hablerie_1",
			"maya_1",
		},

		{	"hand_1",
			"hand_1",
		},

		{	"table_1",
			"table_1",
			"maya_1",
		},

		{	"table_1",
			"maya_1",
			"hand_1"
		},
		
		{
			"table_1",
			"hablerie_1",
			"hand_1",
		},	
		
		{
			"balance_1",
			"hablerie_1",
			"maya_1",
		},

		{	"balance_1",
			"balance_1"},

		{	"beetle_1"},	
		{	"beetle_1"},	-- make this wave slightly more common lol
	},
	
}
-- item boxes:
DNG_itemBoxes[mapnum] = {

	[1] = {
		{"amethyst", 1},
	},

	[2] = {
		{"supercombiring", 1},
	},

	[3] = {
		{"amethyst", 1},
	},

	[4] = {
		{"superring", 2},
	},
	
	[5] = {{25, 1}},	-- 25h
	
	[6] = {
		{"superring", 2},
	},

	[7] = {
		{"superring", 2},
	},	
}

-- travel points
DNG_interactiveObjects[mapnum] = {
	
	[0] = {
		type = IT_AREASWITCH,
		targetmap = mapnum,
		targetid = 1,
		targetangle = ANG1*180,
		
		text = "Moonlit Plains",

		func = 	function()
					DNG_changeSection(2)
				end,		
		
	},

	[1] = {
		type = IT_AREASWITCH,
		targetmap = mapnum,
		targetid = 0,
		targetangle = 0,
		
		text = "Entrance",

		func = 	function()
					DNG_changeSection(1)
				end,		
		
	},
	
}
