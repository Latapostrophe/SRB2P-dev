local mapnum = 23

local vendingmachine_textdata = {
		-- text format: {name, text, portrait, colour}

		welcome = {		-- On main shop page
			{nil, "This is a vending machine. What will you do?"},
		},

		buying = {			-- when buying shit
			{nil, "What will you get?"},
		},

		buy = {				-- you just bought something
			{nil, "You bought a nice drink."},
		},

		buyconfirm = {
			{nil, "%NAME% x%QUANTITY%... \nThat'll be %COST%"},
		},

		broke = {
			{nil, "You can't afford that."},
		},

		leave = {
			{nil, "We're done here."},
		},
}

shopList["vending_machine_1"] = {

	textdata = vendingmachine_textdata,
	nosell = true,
	stocklimit = true,	-- keep track of how many items are left in the shop. We ONLY limit the items tab.

	-- normal item sell table

	-- {itemname, [price], [diff_1], [diff_2], [qty]}
	-- price can be set on normal items with the cost field, but can be overwritten here.
	-- diff_1 is threshold difficulty (item only available if difficulty >= diff_1)
	-- diff_2 is also threshold difficulty (item only avilable if difficulty <= diff_2)
	-- qty: how many of this item is available? Story mode only, availability resets everyday.

	items = {
		{"minute soubrette", nil, nil, nil, 2},
		{"3up", nil, nil, nil, 2},
		{"loh brew", nil, nil, nil, 2},	
		{"chaos cola", nil, nil, nil, 1},		
	},
}

shopList["vending_machine_2"] = {

	textdata = vendingmachine_textdata,
	nosell = true,
	stocklimit = true,	-- keep track of how many items are left in the shop. We ONLY limit the items tab.

	items = {
		{"nep bull", nil, nil, nil, 2},
		{"peach rings", nil, nil, nil, 1},
		{"spirite", nil, nil, nil, 1},		
	},
}

shopList["vending_machine_3"] = {

	textdata = vendingmachine_textdata,
	nosell = true,
	stocklimit = true,	-- keep track of how many items are left in the shop. We ONLY limit the items tab.

	items = {
		{"nep bull", nil, nil, nil, 2},
		{"minute soubrette", nil, nil, nil, 1},
		{"chaos cola", nil, nil, nil, 1},		
	},
}

shopList["vending_machine_4"] = {

	textdata = vendingmachine_textdata,
	nosell = true,
	stocklimit = true,	-- keep track of how many items are left in the shop. We ONLY limit the items tab.

	items = {
		{"loh brew", nil, nil, nil, 1},
		{"spirita", nil, nil, nil, 1},
		{"chaos cola", nil, nil, nil, 1},		
	},
}

-- snack bar
shopList["city_shop_1"] = {

	textdata =  {
		welcome = {		-- On main shop page
			{"Owner", "Welcome, what do you want?"},
		},

		buying = {			-- when buying shit
			{"Owner", "What are you getting?"},
		},

		buy = {				-- you just bought something
			{"Owner", "Here you go!"},
		},

		buyconfirm = {
			{"Owner", "%NAME% x%QUANTITY%... \nThat'll be %COST%"},
		},

		broke = {
			{"Owner", "...I'm sorry but you don't seem to have enough on you."},
		},

		leave = {
			{"Owner", "Do come again!"},
		},
	},
	nosell = true,
	stocklimit = true,	-- keep track of how many items are left in the shop. We ONLY limit the items tab.

	items = {
		{"ham sandwich", nil, nil, nil, 4},
		{"chilli dog", nil, nil, nil, 4},
		{"grilled fsteak", nil, nil, nil, 1},
		{"donut", nil, nil, nil, 1},
		{"pepperoni pizza", nil, nil, nil, 1},			
	},
}

-- drug store
shopList["city_shop_2"] = {

	textdata =  {
		welcome = {		-- On main shop page
			{"Pharmacist", "Hello there, what do you need?"},
		},

		buying = {			-- when buying shit
			{"Pharmacist", "Take your time."},
		},

		buy = {				-- you just bought something
			{"Pharmacist", "Here it is."},
		},

		buyconfirm = {
			{"Pharmacist", "%NAME% x%QUANTITY%... \nThat'll be %COST%"},
		},

		broke = {
			{"Pharmacist", "You seem a bit short on money..."},
		},

		leave = {
			{"Pharmacist", "Be careful out there!"},
		},
	},
	nosell = true,
	stocklimit = true,	-- keep track of how many items are left in the shop. We ONLY limit the items tab.

	items = {
		{"bronzering", 15, nil, nil, 4},
		{"superring", 45, nil, nil, 4},
		{"patra gem", 20, nil, nil, 2},	
	},
}

-- clothes store
shopList["city_shop_3"] = {

	textdata =  {
		welcome = {		-- On main shop page
			{"Owner", "Why hello there!"},
		},

		buying = {			-- when buying shit
			{"Owner", "We've got interresting items in store..."},
		},

		buy = {				-- you just bought something
			{"Owner", "There you have it."},
		},

		buyconfirm = {
			{"Owner", "%NAME% x%QUANTITY%... \nThat'll be %COST%"},
		},

		broke = {
			{"Owner", "You won't get fashionnable for free, you know..."},
		},

		leave = {
			{"Owner", "Pleasure doing business with you!"},
		},
	},
	nosell = true,
	
	weapons = {
		{makeWeapon("comun sneakers"), 150, nil, nil},		
	},

	armour = {
		{makeRing("rekla rings"), 350, nil, nil},
	},
}

DNG_interactiveObjects[mapnum] = {
	
	[1] = {
		type = IT_INTERACTION,
		text = "Vending Machine",
		func = 	function(o, mo)
					DNG_startShop(mo, "vending_machine_1")
				end,
	},

	[2] = {
		type = IT_INTERACTION,
		text = "Vending Machine",
		func = 	function(o, mo)
					DNG_startShop(mo, "vending_machine_2")
				end,
	},

	[3] = {
		type = IT_INTERACTION,
		text = "Vending Machine",
		func = 	function(o, mo)
					DNG_startShop(mo, "vending_machine_3")
				end,
	},
	
	[4] = {
		type = IT_INTERACTION,
		text = "Vending Machine",
		func = 	function(o, mo)
					DNG_startShop(mo, "vending_machine_4")
				end,
	},

	[5] = {
		type = IT_INTERACTION,
		text = "Snack Bar",
		func = 	function(o, mo)
					DNG_startShop(mo, "city_shop_1")
				end,
	},	

	[6] = {
		type = IT_INTERACTION,
		text = "Drug Store",
		func = 	function(o, mo)
					DNG_startShop(mo, "city_shop_2")
				end,
	},	

	[7] = {
		type = IT_INTERACTION,
		text = "Fashion Store",
		func = 	function(o, mo)
					DNG_startShop(mo, "city_shop_3")
				end,
	},		
}