-- Equipment definition (Ring)

/*
	ring:

	def = defense stat. 10% of it is converted into endurance.
	hp
	sp	= stat bonuses
	slot = skill card
	rarity:		Determines damage variance ceiling you take
				1-2*	-> -10% to +10%
				3-4*	-> -10% to +7.5%
				5*		-> -10% to +5%
				6*		-> -10% to +2.5%
				7*		-> -10* to +0%

*/

-- this generates a default weapon table at level 0.
rawset(_G, "makeRing", function(ring, level)

	local r = ringsList[ring]
	if not r return nil end	-- nothing

	local res = {

		ref = ring,
		def = r.def,
		level = 0,
		slot = r.slot,
		rarity = r.rarity or 1,

		hp = r.hp or 0,
		sp = r.sp or 0,
	}

	if level
		for i = 1, level do
			enhanceRing(res)
		end
	end

	return res
end)

rawset(_G, "buildRingName", function(rng)
	if not rng return "" end

	local n = "\x9B"..ringsList[rng.ref].name
	if not n return "" end
	if rng.level
		n = $.."+"..rng.level
	end

	return n
end)

-- sort rings by raw defence stat
rawset(_G, "sortRings", function(t)
	table.sort(t, function(a, b) return a.def > b.def end)
end)

-- adds a ring to your inventory
rawset(_G, "addRing", function(mo, ring)
	if not server.P_BattleStatus return end
	local party	-- get party from fight entity or player mobj, whatever!
	if mo.player
		party = mo.player.P_party
	else
		party = mo.control.P_party
	end

	local btl = server.P_BattleStatus[party]
	if not btl return end

	btl.armours[#btl.armours+1] = ring
	sortRings(btl.armours)	-- resort table
end)

rawset(_G, "removeRing", function(mo, ring)
	if not server.P_BattleStatus return end
	local party	-- get party from fight entity or player mobj, whatever!
	if mo.player
		party = mo.player.P_party
	else
		party = mo.control.P_party
	end

	local btl = server.P_BattleStatus[party]
	if not btl return end

	for i = 1, #btl.armours
		if btl.armours[i] == ring
			table.remove(btl.armours, i)
			break
		end
	end
	sortRings(btl.armours)
end)

rawset(_G, "equipRing", function(mo, ring, dequip)

	-- we need to check for this first because we don't know if we already had a ring before
	if mo.wardring and not dequip
		addRing(mo, mo.wardring)	-- put this back in our inventory
	end

	mo.maxhp = max(1, mo.realhp + ring.hp)
	mo.maxsp = max(0, mo.realsp + ring.sp)
	mo.hp = min(mo.maxhp, $)
	mo.sp = min(mo.maxsp, $)

	mo.defence = max(0, ring.def)/10
	mo.wardring = ring

	if not dequip
		removeRing(mo, ring)	-- remove this one from our inventory
	end
end)

rawset(_G, "enhanceRing", function(ring)
	if ring.level >= 10 return end

	local base = ringsList[ring.ref]
	-- power +3% of original value:
	ring.def = $ + (base.def*3 / 100)

	ring.level = $+1
	if ring.hp
		ring.hp = $ + max(1, base.hp*3/100)
	end
	if ring.sp
		ring.sp = $ + 1
	end
end)

rawset(_G, "evaluateRingPrice", function(ring)
	if not ring return 0 end

	local price = ring.def*2

	local stats = {"hp", "sp"}
	for i = 1, #stats do
		price = $+ ring[stats[i]]*10
	end
	price = $ + 100*ring.level
	return price
end)

rawset(_G, "ringsList", {

	["telosturntable"] = {
		name = "Telos Turntable",
		def = -9999,
		desc = "An item equippable \nas a Wardring",
		sp = -999,
		hp = -999,
		rarity = 7,
	},

	["spirit bracelet"] = {
		name = "Spirit Bracelet",
		def = 300,
		desc = "Light rings that sacrifice\ndefensive options to allow their\nwearer to concentrate\nmore easily.",
		sp = 30,
		hp = -50,
		rarity = 2,
	},

	["spirit cuffs"] = {
		name = "Spirit Cuffs",
		def = 500,
		desc = "Light rings that sacrifice\ndefensive options to allow their\nwearer to concentrate\nmore easily.",
		sp = 75,
		hp = -100,
		rarity = 4,
	},

	["vigor bracelet"] = {
		name = "Vigor Bracelet",
		def = 300,
		desc = "Heavy rings that increase\none's vitality at the cost of making\nit much harder to concentrate.",
		sp = -30,
		hp = 50,
		rarity = 2,
	},

	["vigor cuffs"] = {
		name = "Vigor Cuffs",
		def = 500,
		desc = "Heavy rings that increase\none's vitality at the cost of making\nit much harder to concentrate.",
		sp = -75,
		hp = 150,
		rarity = 4,
	},

	["ring_01"] = {
		name = "Wardring",
		def = 160,
		desc = "Basic protective rings.",
		rarity = 1,
	},

	-- Series rings

	-- T1:
	["rekla rings"] = {
		name = "Rekla Rings",
		def = 190,
		desc = "Light steel rings.\nThey have blue stripes",
		hp = 5,
		rarity = 3,
	},

	["qualz rings"] = {
		name = "Qualz Rings",
		def = 210,
		desc = "Sturdy rings with quartz\npatterns. What a waste of quartz.",
		hp = 7,
		rarity = 3,
	},

	["vincir rings"] = {
		name = "Vincir Rings",
		def = 250,
		desc = "Gold platted rings that\nonly the victors shall wear.",
		hp = 10,
		sp = 1,
		rarity = 5,
	},

	-- T2:
	["blue rings"] = {
		name = "Blue Rings",
		def = 220,
		desc = "Blue tainted rings.\nThey actually glow in the dark!",
		hp = 10,
		sp = 1,
		rarity = 3,
	},

	["gliden rings"] = {
		name = "Gliden Rings",
		def = 260,
		desc = "Yellow rings with\nlightning-like patterns.",
		hp = 15,
		sp = 5,
		rarity = 5,
	},

	["strania rings"] = {
		name = "Strania Rings",
		def = 330,
		desc = "Red-hot rings that\nshow off your muscles. Somehow.",
		hp = 25,
		sp = 0,
		rarity = 6,
	},

	["maha rings"] = {
		name = "Maha Rings",
		def = 300,
		desc = "Purple rings that reflect\nlight. They're pretty.",
		hp = 0,
		sp = 15,
		rarity = 6,
	},

	-- T3:

	["red rings"] = {
		name = "Red Rings",
		def = 320,
		desc = "Some people like to collect these.\nIt's weird because they aren't\nthat great?",
		hp = 10,
		sp = 2,
		rarity = 3,
	},

	["comun rings"] = {
		name = "Comun Rings",
		def = 380,
		desc = "You might just mistake those\nfor bad Rings, but they came\nout much later than the weapons!",
		hp = 15,
		sp = 5,
		rarity = 4,
	},

	["v2-rekla rings"] = {
		name = "V2-Rekla Rings",
		def = 470,
		desc = "A much needed upgrade to lackluster\nRings. They're on par with fused\nequipment, even!",
		hp = 20,
		sp = 20,
		rarity = 6,
	},

	-- T4:
	["bright rings"] = {
		name = "Bright Rings",
		def = 360,
		desc = "Rings that glow in the dark.\n...They're made of plastic.",
		hp = 15,
		sp = 5,
		rarity = 2,
	},

	["alva rings"] = {
		name = "Alva Rings",
		def = 450,
		desc = "For some reason they swapped\nthe B for a V when releasing\nthis Ring overseas.",
		hp = 20,
		sp = 5,
		rarity = 4,
	},

	["reaver rings"] = {
		name = "Reaver Rings",
		def = 470,
		desc = "Dark grey and red rings.\nThey look edgy.",
		hp = 25,
		sp = 10,
		rarity = 5,
	},

	["revoluzio rings"] = {
		name = "Revoluzio Rings",
		def = 540,
		desc = "Intricate green energy patterns\nrun accross its surface.",
		hp = 35,
		sp = 25,
		rarity = 6,
	},

	-- T5:
	["laser rings"] = {
		name = "Laser Rings",
		def = 450,
		desc = "Surprisingly durable for how\ncheap it actually is.",
		hp = 15,
		sp = 5,
		rarity = 2,
	},

	["nox rings"] = {
		name = "Nox Rings",
		def = 500,
		desc = "Black rings with pink stripes.\nFancy and tough.",
		hp = 25,
		sp = 10,
		rarity = 3,
	},

	["lambda rings"] = {
		name = "Lambda Rings",
		def = 600,
		desc = "Plain grey rings.\nYou'd almost mistake them for common\nWardrings.",
		hp = 35,
		sp = 20,
		rarity = 5,
	},

	["agil rings"] = {
		name = "Agil Rings",
		def = 720,
		desc = "Their platinum alloy makes them\nextremely tough.",
		hp = 45,
		sp = 30,
		rarity = 6,
	},

	-- T6:
	["novel rings"] = {
		name = "Novel Rings",
		def = 1000,
		desc = "Extremely durable rings. \nThat's all there is to them.",
		hp = 0,
		sp = 0,
		rarity = 1,
	},

	["vitalis rings"] = {
		name = "Vitalis Rings",
		def = 770,
		desc = "An upgraded version of\nthe Strania Rings.",
		hp = 70,
		sp = 0,
		rarity = 4,
	},

	["spirita rings"] = {
		name = "Spirita Rings",
		def = 720,
		desc = "An upgraded version of\nthe Maha Rings.",
		hp = 0,
		sp = 50,
		rarity = 4,
	},

	["awake rings"] = {
		name = "Awake Rings",
		def = 840,
		desc = "White rings with blue streaks.",
		hp = 45,
		sp = 25,
		rarity = 5,
	},

	["freifi rings"] = {
		name = "Freifi Rings",
		def = 1100,
		desc = "There's not much debate, these are\namong the best Rings you can get\nA pink aura radiates from them.",
		hp = 120,
		sp = 40,
		rarity = 6,
	},

	["ragged rings"] = {
		name = "Ragged Rings",
		def = 1350,
		desc = "Cuffs torn from he who brings\nrest to souls. Chains dangle\nfrom them.",
		hp = 150,
		sp = 65,
		rarity = 7,
	},

	["buhn rings"] = {
		name = "Buhn Rings",
		def = 1500,
		desc = "This shouldn't exist.\nSo why does it?",
		hp = 180,
		sp = 80,
		rarity = 7,
	},

	["ring-0"] = {
		name = "Wardring-0",
		def = 180,
		desc = "It has a silver Velvet Room\nicon on it.",
		hp = 10,
		sp = 5,
		rarity = 2,
	},

	["chain rings"] = {
		name = "Chain Rings",
		def = 200,
		desc = "Light, fancy looking\nring chains.",
		hp = 10,
		rarity = 2,
	},

	["iron bracelets"] = {
		name = "Iron Bracelets",
		def = 275,
		desc = "Bulletproof iron rings",
		hp = 15,
		sp = 1,
		rarity = 2,
	},

	["shackled rings"] = {
		name = "Shackled Rings",
		def = 350,
		desc = "Heavy rings that look\nlike they've been sealed.",
		hp = 20,
		sp = 3,
		rarity = 3,
	},

	["libre rings"] = {
		name = "Libre Rings",
		def = 350,
		desc = "Light rings that look\nthey've been stripped from\nsomething.",
		hp = 10,
		sp = 10,
		rarity = 3,
	},

	["ion rings"] = {
		name = "Ion Rings",
		def = 450,
		desc = "Rings upgraded through fusion.\nAll around decent",
		hp = 30,
		sp = 20,
		rarity = 3,
	},

	["dyne rings"] = {
		name = "Dyne Rings",
		def = 950,
		desc = "Rings upgraded through fusion.\nAll around decent",
		hp = 60,
		sp = 45,
		rarity = 5,
	},


	["crescent rings"] = {
		name = "Crescent Rings",
		def = 400,
		desc = "Rings that fell from the moon.\nDim reflects can be seen\nunder the moonlight.",
		hp = 30,
		sp = 5,
		rarity = 3,
	},

	["dimidium rings"] = {
		name = "Dimidium Rings",
		def = 620,
		desc = "Rings that fell from the moon.\nA feint glow emanates shines\nunder the moonlight.",
		hp = 40,
		sp = 10,
		rarity = 4,
	},

	["plenae rings"] = {
		name = "Plenae Rings",
		def = 890,
		desc = "Rings that fell from the moon.\nThey shine brightly\nunder the moonlight.",
		hp = 60,
		sp = 25,
		rarity = 5,
	},

	["nova rings"] = {
		name = "Nova Rings",
		def = 1200,
		desc = "Rings that fell from the moon.\nLight bursts out of them\nunder the moonlight.",
		hp = 130,
		sp = 40,
		rarity = 6,
	},

	["eternity rings"] = {
		name = "Eternity Rings",
		def = 1600,
		desc = "The eternity of the cosmos\nreflects off of these Rings.\nBound to this universe,\nthey would give up anything\nto protect it.",
		hp = 200,
		sp = 50,
		rarity = 7,
	},

})