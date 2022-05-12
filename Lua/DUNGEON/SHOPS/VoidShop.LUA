shopList["void_shop"] = {
	
	menuclose = "m_selectfacility",
	
	textdata = {		-- data containing text to be displayed at random

		-- text format: {name, text, portrait, colour}

		welcome = {		-- On main shop page
			{"Alt", "Welcome to the Void Shop!", "H_ALT01", SKINCOLOR_BLUE},
			{"Alt", "Make sure to prepare before the next challenge.", "H_ALT01", SKINCOLOR_BLUE},
		},

		buying = {			-- when buying shit
			{"Alt", "My policy is that you're either satisfied or not refunded!", "H_ALT01", SKINCOLOR_BLUE},
			{"Alt", "All items are cheaper during challenges!\nNot that you get to keep them outside of it though.", "H_ALT01", SKINCOLOR_BLUE},
		},

		buy = {				-- you just bought something
			{"Alt", "I'll make great use of that Macca, trust me...", "H_ALT02", SKINCOLOR_BLUE},
			{"Alt", "I know just what I'll spend this on...", "H_ALT03", SKINCOLOR_BLUE},
		},

		buyconfirm = {
			{"Alt", "%NAME%... \nAnd you want %QUANTITY%... \nThat'll be %COST%", "H_ALT01", SKINCOLOR_BLUE},
		},

		buycard = {
			{"Alt", "%NAME%... \nAnd you want %QUANTITY%... \nThat'll be %COST%", "H_ALT01", SKINCOLOR_BLUE},
		},

		buypersona = {
			{"Alt", "The Sub-Persona %NAME%... \nThat'll be %COST%.\n...Is demon trafficking even legal?", "H_ALT05", SKINCOLOR_BLUE},
			{"Alt", "The Sub-Persona %NAME%... \nThat'll be %COST%.", "H_ALT01", SKINCOLOR_BLUE},
			{"Alt", "The Sub-Persona %NAME%... \nThat'll be %COST%.", "H_ALT01", SKINCOLOR_BLUE},
			{"Alt", "The Sub-Persona %NAME%... \nThat'll be %COST%.", "H_ALT01", SKINCOLOR_BLUE},
		},

		broke = {
			{"Alt", "You're broke...", "H_ALT04", SKINCOLOR_BLUE},
			{"Alt", "You don't have enough for that...", "H_ALT04", SKINCOLOR_BLUE},
		},

		buydupe = {
			{"Alt", "You already have that one...", "H_ALT04", SKINCOLOR_BLUE},
			{"Alt", "I don't think you need duplicates, idiot...", "H_ALT04", SKINCOLOR_BLUE},
		},

		stockfull = {
			{"Alt", "You're carrying too many of those...\nI can always buy some back if you'd like, though...", "H_ALT05", SKINCOLOR_BLUE},
		},

		selling = {
			{"Alt", "What kind of garbage are you gonna sell me back today, mh?", "H_ALT05", SKINCOLOR_BLUE},
			{"Alt", "Jeez, you need Macca that badly you'd sell stuff to me?", "H_ALT02", SKINCOLOR_BLUE},
			{"Alt", "Fine, I'll help disposing of your junk...", "H_ALT04", SKINCOLOR_BLUE},
		},

		sellconfirm = {
			{"Alt", "%NAME%... \nAnd you're giving me %QUANTITY%... \nThat's %COST% for you.", "H_ALT01", SKINCOLOR_BLUE},
		},

		sellother = {
			{"Alt", "%NAME%... \nThat's %COST% for you.", "H_ALT01", SKINCOLOR_BLUE},
		},

		sellequipped = {
			{"Alt", "Someone has that equipped, idiot...", "H_ALT01", SKINCOLOR_BLUE},
		},

		sell = {			-- you just sold something
			{"Alt", "Awesome, now I can sell it back to you later for 10 times the price! Er, I mean, thanks.", "H_ALT01", SKINCOLOR_BLUE},
			{"Alt", "I won't be reaching my life goals anytime soon if I give you my Macca... Lame...", "H_ALT04", SKINCOLOR_BLUE},
		},

		cantsell = {
			{"Alt", "You should keep hold of that.", "H_ALT05", SKINCOLOR_BLUE},
			{"Alt", "I can't buy that.", "H_ALT05", SKINCOLOR_BLUE},
		},

		soldout = {
			{"Alt", "Someone sold that before you could. \nThink faster next time, dummy.", "H_ALT02", SKINCOLOR_BLUE},
		},

		leave = {
			{"Alt", "See ya and good luck!", "H_ALT01", SKINCOLOR_BLUE},
			{"Alt", "You're doing okay so far.\nBest of luck.", "H_ALT01", SKINCOLOR_BLUE},
			{"Alt", "This will only keep getting harder,\nso make sure you got everything you need...", "H_ALT01", SKINCOLOR_BLUE},
		},
	},

	-- normal item sell table

	-- {itemname, [price], [diff_1], [diff_2]}
	-- price can be set on normal items with the cost field, but can be overwritten here.
	-- diff_1 is threshold difficulty (item only available if difficulty >= diff_1)
	-- diff_2 is also threshold difficulty (item only avilable if difficulty <= diff_2)
	-- for void runs, diff_1 and 2 factor in the challenge number instead

	items = {
		{"bronzering", 30, nil, nil},
		{"superring", nil, 9, nil},
		{"supercombiring", nil, 9, nil},
		{"silverring", nil, 6},
		{"silvercombiring", nil, 12},
		{"soulfragment", 250, nil, 9},
		{"snuffsoul", 300, 9},
		{"patra gem", 40},
		{"me patra gem", 70},
		{"dekaja gem", 100, 3},
		{"dekunda gem", 100, 3},
		{"assault signal", nil, 6},
		{"casting signal", nil, 6},
		{"guarding signal", nil, 6},
		{"speedup signal", nil, 6},
		{"homunculus", 100, 3},
	},

	weapons = {
		{makeWeapon("shoes_01", 10), 700, nil, 6},
		{makeWeapon("monitor_01", 10), 700, nil, 6},
		{makeWeapon("knuckles_01", 10), 700, nil, 6},
		{makeWeapon("device_01", 10), 700, nil, 6},
		{makeWeapon("claws_01", 10), 700, nil, 6},
		{makeWeapon("hammer_01", 10), 700, nil, 6},
		{makeWeapon("limiter_01", 10), 700, nil, 6},
		{makeWeapon("heels_01", 10), 700, nil, 6},
		{makeWeapon("psygloves_01", 10), 700, nil, 6},
		{makeWeapon("blades_01", 10), 700, nil, 6},
		{makeWeapon("melee_01", 10), 700, nil, 6},
		{makeWeapon("ranged_01", 10), 700, nil, 6},
		
		{makeWeapon("zan sneakers", 0), 1500, 6, 12},
		{makeWeapon("zonde monitor", 0), 1500, 6, 12},
		{makeWeapon("barta knuckles", 0), 1500, 6, 12},
		{makeWeapon("foie hammer", 0), 1500, 6, 12},
		{makeWeapon("zonde claws", 0), 1500, 6, 12},
		{makeWeapon("barta device", 0), 1500, 6, 12},
		{makeWeapon("zonde limiters", 0), 1500, 6, 12},
		{makeWeapon("foie heels", 0), 1500, 6, 12},
		{makeWeapon("zan gloves", 0), 1500, 6, 12},
		{makeWeapon("barta blades", 0), 1500, 6, 12},
		{makeWeapon("foie rapier", 0), 1500, 6, 12},
		{makeWeapon("zonde handgun", 0), 1500, 6, 12},
		
		{makeWeapon("bright sneakers", 10), 2000, 9},
		{makeWeapon("bright monitor", 10), 2000, 9},
		{makeWeapon("bright knuckles", 10), 2000, 9},
		{makeWeapon("bright hammer", 10), 2000, 9},
		{makeWeapon("bright claws", 10), 2000, 9},
		{makeWeapon("bright device", 10), 2000, 9},
		{makeWeapon("bright limiters", 10), 2000, 9},
		{makeWeapon("bright heels", 10), 2000, 9},
		{makeWeapon("bright gloves", 10), 2000, 9},
		{makeWeapon("bright blades", 10), 2000, 9},
		{makeWeapon("bright rapier", 10), 2000, 9},
		{makeWeapon("bright handgun", 10), 2000, 9},

		{makeWeapon("razan sneakers", 0), 1500, 12},
		{makeWeapon("razonde monitor", 0), 1500, 12},
		{makeWeapon("rabarta knuckles", 0), 1500, 12},
		{makeWeapon("rafoie hammer", 0), 1500, 12},
		{makeWeapon("razonde claws", 0), 1500, 12},
		{makeWeapon("rabarta device", 0), 1500, 12},
		{makeWeapon("razonde limiters", 0), 1500, 12},
		{makeWeapon("rafoie heels", 0), 1500, 12},
		{makeWeapon("razan gloves", 0), 1500, 12},
		{makeWeapon("rabarta blades", 0), 1500, 6, 12},
		{makeWeapon("rafoie rapier", 0), 1500, 6, 12},
		{makeWeapon("razonde handgun", 0), 1500, 6, 12},		
		
	},

	armour = {
		{makeRing("ring-0", 10), 500, nil, 6},
		{makeRing("alva rings"), 1800, 6},
		{makeRing("nox rings"), 2200, 9},
		{makeRing("lambda rings"), 4000, 15},
	},
	
	skillcards = {
		{"sc/ agi", 250, nil, 9},
		{"sc/ bufu", 250, nil, 9},
		{"sc/ garu", 250, nil, 9},
		{"sc/ zio", 250, nil, 9},
		{"sc/ psi", 250, nil, 9},
		{"sc/ frei", 250, nil, 9},
		
		{"sc/ maragi", 700, 6, 15},
		{"sc/ mabufu", 700, 6, 15},
		{"sc/ magaru", 700, 6, 15},
		{"sc/ mazio", 700, 6, 15},
		{"sc/ mafrei", 700, 6, 15},
		{"sc/ mapsi", 700, 6, 15},
		
		{"sc/ agilao", 700, 6, 18},
		{"sc/ bufula", 700, 6, 18},
		{"sc/ garula", 700, 6, 18},
		{"sc/ zionga", 700, 6, 18},
		{"sc/ psio", 700, 6, 18},
		{"sc/ freila", 700, 6, 18},
		
		{"sc/ maragion", 2000, 9},
		{"sc/ mabufula", 2000, 9},
		{"sc/ magarula", 2000, 9},
		{"sc/ mazionga", 2000, 9},
		{"sc/ mapsio", 2000, 9},
		{"sc/ mafreila", 2000, 9},
		
		
		{"sc/ agidyne", 2250, 15},
		{"sc/ bufudyne", 2250, 15},
		{"sc/ garudyne", 2250, 15},
		{"sc/ ziodyne", 2250, 15},
		{"sc/ psiodyne", 2250, 15},
		{"sc/ freidyne", 2250, 15},
		
		
		{"sc/ maragidyne", 4250, 21},
		{"sc/ mabufudyne", 4250, 21},
		{"sc/ magarudyne", 4250, 21},
		{"sc/ maziodyne", 4250, 21},
		{"sc/ mapsiodyne", 4250, 21},
		{"sc/ mafreidyne", 4250, 21},
		
		{"sc/ dia", 500},
		{"sc/ diarama", 1500, 6},
		{"sc/ media", 1500, 6},
		{"sc/ mediarama", 7000, 15},
	},
}