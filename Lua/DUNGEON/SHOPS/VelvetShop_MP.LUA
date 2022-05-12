shopList["velvet_shop_mp1"] = {
	
	menuclose = "m_selectfacility",
	
	textdata = {		-- data containing text to be displayed at random

		-- text format: {name, text, portrait, colour}

		welcome = {		-- On main shop page
			{"Alt", "How convenient that you'd show up! I was short on cash.", "H_ALT01", SKINCOLOR_BLUE},
			{"Alt", "Welcome to the Velvet Shop!", "H_ALT01", SKINCOLOR_BLUE},
			{"Alt", "Hope you brought in a ton of Macca...", "H_ALT01", SKINCOLOR_BLUE},
		},

		buying = {			-- when buying shit
			{"Alt", "My policy is that you're either satisfied or not refunded!", "H_ALT01", SKINCOLOR_BLUE},
			{"Alt", "Come on, I just need a little more money to buy that manga...", "H_ALT01", SKINCOLOR_BLUE},
			{"Alt", "Buy it or I'll commit suicide.", "H_ALT01", SKINCOLOR_BLUE},
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
			{"Alt", "Catch you later.", "H_ALT01", SKINCOLOR_BLUE},
		},
	},

	-- normal item sell table

	-- {itemname, [price], [diff_1], [diff_2]}
	-- price can be set on normal items with the cost field, but can be overwritten here.
	-- diff_1 is threshold difficulty (item only available if difficulty >= diff_1)
	-- diff_2 is also threshold difficulty (item only avilable if difficulty <= diff_2)

	items = {
		{"superring", nil, nil, 3},
		{"supercombiring", nil, 3},
		{"silverring", nil, 2},
		{"silvercombiring", nil, 3},
		{"hyperring", nil, 5},
		{"1up"},
		{"snuffsoul", nil, nil, 5},
		{"chewing soul", nil, 4},
		{"patra gem"},
		{"me patra gem"},
		{"dekaja gem", 200, 3},
		{"dekunda gem", 200, 3},
		{"homunculus", nil, 3},
	},

	weapons = {
		{makeWeapon("shoes_01", 10), 800, nil, 4},
		{makeWeapon("ion runners"), 4000, 3},
		{makeWeapon("dyne runners"), 12500, 6},

		{makeWeapon("device_01", 10), 800, nil, 4},
		{makeWeapon("ion remote"), 4000, 3},
		{makeWeapon("dyne remote"), 12500, 6},

		{makeWeapon("hammer_01", 10), 800, nil, 4},
		{makeWeapon("ion slammer"), 4000, 3},
		{makeWeapon("dyne slammer"), 12500, 6},

		{makeWeapon("knuckles_01", 10), 800, nil, 4},
		{makeWeapon("ion breakles"), 4000, 3},
		{makeWeapon("dyne breakles"), 12500, 6},

		{makeWeapon("claws_01", 10), 800, nil, 4},
		{makeWeapon("ion slicers"), 4000, 3},
		{makeWeapon("dyne slicers"), 12500, 6},

		{makeWeapon("monitor_01", 10), 800, nil, 4},
		{makeWeapon("ion monitor"), 4000, 3},
		{makeWeapon("dyne monitor"), 12500, 6},		

		{makeWeapon("limiter_01", 10), 800, nil, 4},
		{makeWeapon("ion shackles"), 4000, 3},
		{makeWeapon("dyne shackles"), 12500, 6},

		{makeWeapon("psygloves_01", 10), 800, nil, 4},
		{makeWeapon("ion gauntlets"), 4000, 3},
		{makeWeapon("dyne gauntlets"), 12500, 6},

		{makeWeapon("heels_01", 10), 800, nil, 4},
		{makeWeapon("ion escarpin"), 4000, 3},
		{makeWeapon("dyne escarpin"), 12500, 6},

		{makeWeapon("blades_01", 10), 800, nil, 4},
		{makeWeapon("ion sabers"), 4000, 3},
		{makeWeapon("dyne sabers"), 12500, 6},

		{makeWeapon("melee_01", 10), 800, nil, 4},
		{makeWeapon("ion rapier"), 4000, 3},
		{makeWeapon("dyne rapier"), 12500, 6},

		{makeWeapon("ranged_01", 10), 800, nil, 4},
		{makeWeapon("ion handgun"), 4000, 3},
		{makeWeapon("dyne handgun"), 12500, 6},

	},

	armour = {
		{makeRing("vigor bracelet"), 1000, 2, 5},
		{makeRing("vigor cuffs"), 7000, 4},
		{makeRing("spirit bracelet"), 1000, 2, 5},
		{makeRing("spirit cuffs"), 7000, 4},
		{makeRing("chain rings", 10), 550, nil, 3},
		{makeRing("iron bracelets", 10), 800, nil, 3},
		{makeRing("shackled rings", 10), 2500, 3, 5},
		{makeRing("libre rings"), 2500, 3, 5},
		{makeRing("ion rings"), 4000, 3},
		{makeRing("dyne rings"), 12500, 6},
	},

	-- skill card sell tables
	skillcards = {

		{"sc/ tarukaja", 500, 3},
		{"sc/ makakaja", 500, 3},
		{"sc/ rakukaja", 500, 3},
		{"sc/ sukukaja", 500, 3},

		{"sc/ tarunda", 500, 3},
		{"sc/ makanda", 500, 3},
		{"sc/ rakunda", 500, 3},
		{"sc/ sukunda", 500, 3},

		{"sc/ agi", 500, nil, 3},
		{"sc/ maragi", 1200, 2, 3},
		{"sc/ agilao", 900, 3, 5},
		{"sc/ maragion", 2000, 4, 6},
		{"sc/ agidyne", 1500, 6},
		{"sc/ maragidyne", 3000, 7},

		{"sc/ bufu", 500, nil, 3},
		{"sc/ mabufu", 1200, 2, 3},
		{"sc/ bufula", 900, 3, 5},
		{"sc/ mabufula", 2000, 4, 6},
		{"sc/ bufudyne", 1500, 6},
		{"sc/ mabufudyne", 3000, 7},

		{"sc/ zio", 500, nil, 3},
		{"sc/ mazio", 1200, 2, 3},
		{"sc/ zionga", 900, 3, 5},
		{"sc/ mazionga", 2000, 4, 6},
		{"sc/ ziodyne", 1500, 6},
		{"sc/ maziodyne", 3000, 7},

		{"sc/ garu", 500, nil, 3},
		{"sc/ magaru", 1200, 2, 3},
		{"sc/ garula", 900, 3, 5},
		{"sc/ magarula", 2000, 4, 6},
		{"sc/ garudyne", 1500, 6},
		{"sc/ magarudyne", 3000, 7},

		{"sc/ psi", 500, nil, 3},
		{"sc/ mapsi", 1200, 2, 3},
		{"sc/ psio", 900, 3, 5},
		{"sc/ mapsio", 2000, 4, 6},
		{"sc/ psiodyne", 1500, 6},
		{"sc/ mapsiodyne", 3000, 7},

		{"sc/ frei", 500, nil, 3},
		{"sc/ mafrei", 1200, 2, 3},
		{"sc/ freila", 900, 3, 5},
		{"sc/ mafreila", 2000, 4, 6},
		{"sc/ freidyne", 1500, 6},
		{"sc/ mafreidyne", 3000, 7},

		{"sc/ kouha", 500, nil, 3},
		{"sc/ makouha", 1200, 2, 3},
		{"sc/ kouga", 900, 3, 5},
		{"sc/ makouga", 2000, 4, 6},
		{"sc/ kougaon", 1500, 6},
		{"sc/ makougaon", 3000, 7},

		{"sc/ eiha", 500, nil, 3},
		{"sc/ maeiha", 1200, 2, 3},
		{"sc/ eiga", 900, 3, 5},
		{"sc/ maeiga", 2000, 4, 6},
		{"sc/ eigaon", 1500, 6},
		{"sc/ maeigaon", 3000, 7},

	},

	-- sub persona sell tables
	subpersonas = {
		{"jack frost", 750, 1},
		{"angel", 750, 1, 1},
		{"ghoul", 750, 1, 1},
		{"nata taishi", 750, 1},
		{"pixie", 750, 1},

		{"pyro jack", 1500, 2},
		{"principality", 1500, 2},
		{"naga", 1500, 2},
		{"lamia", 1500, 2},
		{"fortuna", 1500, 2},
		{"narcissus", 1500, 2},
		{"oberon", 1500, 2},

		{"hua po", 2500, 3},
		{"orobas", 2500, 3},
		{"leanan sidhe", 2500, 3},
		{"king frost", 2500, 3},
		{"queen mab", 2500, 3},
		{"ares", 2500, 3},
		{"mithra", 2500, 3},
		{"lilim", 2500, 3},		

		{"black frost", 4000, 4},
		{"chu chulainn", 4000, 4},
		{"girimehkala", 4000, 4},
		{"kaiwan", 4000, 4},
		{"oumitsunu", 4000, 4},
		{"pale rider", 4000, 4},
		{"succubus", 4000, 4},
		{"titania", 4000, 4},
		{"virtue", 4000, 4},

		{"anubis", 5000, 5},
		{"kinki", 6500, 5},
		{"quezacoatl", 6500, 5},
		{"belphegor", 6500, 5},
		{"siegfried", 6500, 5},
		{"matador", 6500, 5},
		{"hell biker", 6500, 5},
		{"byakko", 6500, 5},
		{"seiryuu", 6500, 5},
		{"mara", 6500, 5},
		
		{"trumpeter", 10500, 6},
		{"alice", 10500, 6},
		{"daisoujou", 10500, 6},
		{"lilith", 10500, 6},
		{"archangel", 10500, 6},
		{"raphael", 10500, 6},
		{"sati", 10500, 6},
		{"loki", 10500, 6},	
	},
}