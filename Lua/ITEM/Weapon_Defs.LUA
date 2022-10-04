-- Equipment definition

-- all purpose weapon
local all = 0
for i = 0, 30 do
	all = $|(2^i)
end

rawset(_G, "WPT_ALL", all)

local weaponicons = {

	[WPT_SHOES] = 			"\x9C",
	[WPT_REMOTE] =  		"\x9D",
	[WPT_HAMMER] = 			"\x9E",
	[WPT_KNUCKLES] = 		"\x9F",
	[WPT_CLAWS] = 			"\xA0",
	[WPT_MONITOR] = 		"\xA1",
	[WPT_LIMITERS] = 		"\xA2",
	[WPT_PSYGLOVES] = 		"\xA3",
	[WPT_HEELS] = 			"\xA4",
	[WPT_HANDSONIC] = 		"\xA5",
	[WPT_GENERICMELEE] = 	"\xA7",
	[WPT_GENERICRANGED] = 	"\xA8",

	[WPT_ALL] = "\xA7",
}

/*
	weapon:

	type = weapon type (Used to know which character(s) can equip them)
	atk = base attack stat of the weapon (/10 in effect) (default: 300)
	acc = accuracy of the weapon (%) (default: 95)
	crit = crit rate of the weapon (%) (default: 5)
	melee = skill to use in place of the character's melee attack
	grindtier = 1-7: replaces rarity when checking what materials are needed to upgrade the weapon
	st
	ma
	en
	ag
	lu	= stat bonuses
	slot = skill card
	rarity = 	# between 1-7.
				Rarity affects damage variance floor
				1-2* 	-> -10% to +10%
				3-4*	-> -7.5% to +10%
				5*		-> -5% to +10%
				6*		-> -2.5% to +10%
				7*		-> 0% to +10%

*/

-- this generates a weapon.
-- lvl sets the enhancement level of the weapon
rawset(_G, "makeWeapon", function(wpn, lvl)

	local w = weaponsList[wpn]
	if not w return nil end	-- nothing

	local weapon = {

		ref = wpn,
		atk = w.atk or 300,
		acc = w.acc or 95,
		crit = w.crit or 5,
		slot = w.slot,
		rarity = w.rarity or 1,
		element = w.element,
		level = 0,
		melee = w.melee,
		grindtier = w.grindtier or w.rarity or 1,

		st = w.st or 0,
		ma = w.ma or 0,
		en = w.en or 0,
		ag = w.ag or 0,
		lu = w.lu or 0,
	}

	--lvl = 10

	if lvl
		for i = 1, lvl
			enhanceWeapon(weapon)
		end
	end

	return weapon
end)

rawset(_G, "getEquipGrindTier", function(e)
	return min(7, e.grindtier or e.rarity or 1)	-- whatever works
end)

rawset(_G, "buildWeaponName", function(wpn)
	if not wpn or not weaponsList[wpn.ref] return "" end

	-- get weapon's types
	local type = weaponicons[weaponsList[wpn.ref].type] or tostring(weaponsList[wpn.ref].type)

	local n = type..weaponsList[wpn.ref].name
	if wpn.level
		n = $.."+"..wpn.level
	end

	return n
end)

-- sort weapons by raw atk stat & type
rawset(_G, "sortWeapons", function(t)
	table.sort(t, function(a, b)

				if weaponsList[a.ref].type ~= weaponsList[b.ref].type
					return weaponsList[a.ref].type < weaponsList[b.ref].type
				else
					return a.atk > b.atk
				end
			end)
end)

-- adds a weapon
rawset(_G, "addWeapon", function(mo, wep)
	if not server.P_BattleStatus return end

	local party	-- get party from fight entity or player mobj, whatever!
	if mo.player
		party = mo.player.P_party
	else
		party = mo.control.P_party
	end

	local btl = server.P_BattleStatus[party]
	if not btl return end

	btl.weapons[#btl.weapons+1] = wep
	sortWeapons(btl.weapons)	-- resort table
end)

rawset(_G, "removeWeapon", function(mo, wep)
	if not server.P_BattleStatus return end
	local party	-- get party from fight entity or player mobj, whatever!
	if mo.player
		party = mo.player.P_party
	else
		party = mo.control.P_party
	end

	local btl = server.P_BattleStatus[party]
	if not btl return end

	for i = 1, #btl.weapons
		if btl.weapons[i] == wep
			table.remove(btl.weapons, i)
			break
		end
	end
	sortWeapons(btl.weapons)	-- resort table
end)

-- check if mo can equip wep
rawset(_G, "getEquipWeaponType", function(mo)

	local stats = charStats[mo.stats]
	if not stats return end	-- ??
	-- in dire situations, have us equip generic melee weapons
	if not stats.weptype return WPT_GENERICMELEE end

	return stats.weptype
end)

rawset(_G, "canEquipWeapon", function(mo, wep)
	return weaponsList[wep.ref].type & getEquipWeaponType(mo)
end)

-- equips a weapon on mo and changes their stats accordingly.
-- this doesn't do anything with inventory
rawset(_G, "equipWeapon", function(mo, wep, dequip)

	-- we need to check for this because weapon is nil when we first initialize the player
	if mo.weapon and not dequip
		-- add the current weapon back into our inventory
		addWeapon(mo, mo.weapon)
	end
	mo.atk = max(1, wep.atk/10)
	mo.acc = wep.acc
	mo.crit = wep.crit
	mo.weapon = wep

	PLYR_getStats(mo, mo.level, true, true, true)

	if not dequip
		removeWeapon(mo, wep)	-- remove this
	end
end)

-- enhances a weapon by +1 level. Does nothing if the level is already 10 (or above ???)
rawset(_G, "enhanceWeapon", function(wep)
	if wep.level >= 10 return end

	local base = weaponsList[wep.ref]
	-- power +3.5% of original value (floored to 1 atk):
	wep.atk = $ + max(10, base.atk*35 / 1000)

	wep.level = $+1
	if (wep.level % 5 == 0)
		local stats = {"st", "ma", "en", "ag", "lu"}
		for i = 1, #stats do
			if wep[stats[i]]
				wep[stats[i]] = $+1
			end
		end
	end
end)

-- Evaluates a weapon's cost:
/*
	cost is: 3* raw weapon atk (the one that's generally over 200)
	+ 10*additional stat bonus (per stat point, so 2 agility is +20)
	+ 100*level

	In total, all of that has a % multiplier depending on rarity:
	1-2*:	1x
	3*:		1.5x
	4*:		2x
	5*:		5x
	6*:		10x
	7*:		100x
*/

local rarity_multiplier = {
	100,
	100,
	150,
	200,
	300,
	500,
	750,
}

rawset(_G, "evaluateWeaponPrice", function(wep)
	if not wep return 0 end
	local price = wep.atk

	local stats = {"st", "ma", "en", "ag", "lu"}
	for i = 1, #stats do
		price = $ + wep[stats[i]]*5
	end

	price = $ + 100*wep.level
	price = $ + (price*rarity_multiplier[min(7, wep.rarity or 1)])/(100)

	return price
end)

/*
	Some slight weapons convention for now.
	PS: plans to obtain them may change but weapons probably won't

	Default (1*) -> Ion series (3*) -> Dyne series (5*)
	These are upgraded via materials & specific skill cards

	Crescent series (3*) -> Dimidium series (4*) -> Plenae series (5*) -> Nova series (6*)
	Crescent series to be obtainable quite easily, upgradable with materials that drop during respective moon phases.
	(Dimidium: Half, Plenae: Full, Nova: New)





*/

rawset(_G, "weaponsList", {

	["nihil shoes"] = {
		name = "Nihil Shoes",
		type = WPT_SHOES,
		atk = 1,
		desc = "Shoes made from fusing\na frame and Sub-Persona.\nAttributes may vary.",
		rarity = 1,
	},

	["nihil monitor"] = {
		name = "Nihil Monitor",
		type = WPT_MONITOR,
		atk = 1,
		desc = "Monitor made from fusing\na frame and Sub-Persona.\nAttributes may vary.",
		rarity = 1,
	},

	["nihil knuckles"] = {
		name = "Nihil Knuckles",
		type = WPT_KNUCKLES,
		atk = 1,
		desc = "Knuckles made from fusing\na frame and Sub-Persona.\nAttributes may vary.",
		rarity = 1,
	},

	["nihil device"] = {
		name = "Nihil Device",
		type = WPT_REMOTE,
		atk = 1,
		desc = "Device made from fusing\na frame and Sub-Persona.\nAttributes may vary.",
		rarity = 1,
	},

	["nihil limiters"] = {
		name = "Nihil Limiters",
		type = WPT_LIMITERS,
		atk = 1,
		desc = "Limiters made from fusing\na frame and Sub-Persona.\nAttributes may vary.",
		rarity = 1,
	},

	["nihil hammer"] = {
		name = "Nihil Hammer",
		type = WPT_HAMMER,
		atk = 1,
		desc = "Hammer made from fusing\na frame and Sub-Persona.\nAttributes may vary.",
		rarity = 1,
	},

	["nihil claws"] = {
		name = "Nihil Claws",
		type = WPT_CLAWS,
		atk = 1,
		desc = "Claws made from fusing\na frame and Sub-Persona.\nAttributes may vary.",
		rarity = 1,
	},

	["nihil heels"] = {
		name = "Nihil Heels",
		type = WPT_HEELS,
		atk = 1,
		desc = "Heels made from fusing\na frame and Sub-Persona.\nAttributes may vary.",
		rarity = 1,
	},

	["nihil gloves"] = {
		name = "Nihil Gloves",
		type = WPT_PSYGLOVES,
		atk = 1,
		desc = "Gloves made from fusing\na frame and Sub-Persona.\nAttributes may vary.",
		rarity = 1,
	},

	["nihil blades"] = {
		name = "Nihil Blades",
		type = WPT_HANDSONIC,
		atk = 1,
		desc = "Blades made from fusing\na frame and Sub-Persona.\nAttributes may vary.",
		rarity = 1,
	},

	["nihil rapier"] = {
		name = "Nihil Rapier",
		type = WPT_GENERICMELEE,
		atk = 1,
		desc = "Rapier made from fusing\na frame and Sub-Persona.\nAttributes may vary.",
		rarity = 1,
	},

	["nihil gun"] = {
		name = "Nihil Gun",
		type = WPT_GENERICRANGED,
		atk = 1,
		desc = "Handgun made from fusing\na frame and Sub-Persona.\nAttributes may vary.",
		rarity = 1,
	},

	["generic_01"] = {
		name = "Genesis",
		type = WPT_ALL,
		atk = 300,
		desc = "Basic all-purpose\nweapon.",
		rarity = 1,
		slot = "mastery 1",
	},

	["genesis-ion"] = {
		name = "Genesis-Ion",
		type = WPT_ALL,
		atk = 900,
		ma = 1,
		st = 1,
		desc = "Basic all-purpose\nweapon.",
		rarity = 3,
		slot = "mastery 2",
	},

	["genesis-dyne"] = {
		name = "Genesis-Dyne",
		type = WPT_ALL,
		atk = 1450,
		ma = 3,
		st = 3,
		desc = "Basic all-purpose\nweapon.",
		rarity = 5,
		slot = "mastery 3",
	},

	["melee_01"] = {
		name = "Rapier",
		type = WPT_GENERICMELEE,
		atk = 300,
		desc = "Light Rapier.\nEasy to use but not very strong.",
		rarity = 1,
		slot = "mastery 1",
	},

	["ion rapier"] = {
		name = "Ion Rapier",
		type = WPT_GENERICMELEE,
		atk = 900,
		desc = "Rapier enhanced via fusion.",
		rarity = 3,
		ma = 1,
		st = 1,
		slot = "mastery 2",
	},

	["dyne rapier"] = {
		name = "Dyne Rapier",
		type = WPT_GENERICMELEE,
		atk = 1500,
		desc = "Rapier enhanced via fusion.",
		rarity = 5,
		ma = 3,
		st = 3,
		slot = "mastery 3",
	},

	["ranged_01"] = {
		name = "Handgun",
		type = WPT_GENERICRANGED,
		atk = 300,
		desc = "A classic handgun. \nDon't confuse it for\nyour Evoker!",
		rarity = 1,
		slot = "mastery 1",
	},

	["ion handgun"] = {
		name = "Ion Handgun",
		type = WPT_GENERICRANGED,
		atk = 900,
		desc = "Handgun enhanced through fusion.\n...It fires more like a\nmachinegun, actually.",
		rarity = 3,
		ma = 1,
		st = 1,
		slot = "mastery 2",
	},

	["dyne handgun"] = {
		name = "Dyne Handgun",
		type = WPT_GENERICRANGED,
		atk = 1500,
		desc = "Handgun enhanced through fusion.\nFires a lightning fast stream\nof bullets.",
		rarity = 5,
		ma = 3,
		st = 3,
		slot = "mastery 3",
	},

	["bfg9000"] = {
		name = "BFG 9000",
		type = WPT_GENERICRANGED,
		atk = 2900,
		desc = "That's a Big, Uh...\nFreakin' Gun!",
		rarity = 7,
		ma = 7,
		st = 7,
		ag = 7,
		lu = 7,
		en = 7,
		slot = "megidolaon",
	},

	/*
		SHOES (Sonic)
	*/

	-- TIER 1

	["shoes_01"] = {
		name = "Speed Shoes",
		type = WPT_SHOES,
		atk = 300,
		desc = "Sonic's favourites!",
		slot = "mastery 1",
		rarity = 1,
	},

	["ion runners"] = {
		name = "Ion Runners",
		type = WPT_SHOES,
		atk = 900,
		desc = "Shoes upgraded through\nfusion. The wearer\ncan move as freely\nas the wind.",
		ma = 1,
		ag = 1,
		slot = "mastery 2",
		rarity = 3,
	},

	["dyne runners"] = {
		name = "Dyne Runners",
		type = WPT_SHOES,
		atk = 1500,
		desc = "Shoes upgraded through\nfusion. The wearer becomes\none with the wind.",
		ma = 3,
		ag = 3,
		slot = "mastery 3",
		rarity = 5,
	},

	["crescent sneakers"] = {
		name = "Crescent Sneakers",
		type = WPT_SHOES,
		atk = 700,
		desc = "Shoes imbuded with the\nblessing of the moon.",
		rarity = 3,
	},

	["dimidium sneakers"] = {
		name = "Dimidium Sneakers",
		type = WPT_SHOES,
		atk = 1000,
		desc = "Shoes imbuded with the\nblessing of the moon.\nThey glow faintly\nunder the moonlight.",
		rarity = 4,
	},

	["plenae sneakers"] = {
		name = "Plenae Sneakers",
		type = WPT_SHOES,
		atk = 1350,
		desc = "Shoes imbuded with the\nblessing of the moon.\nThey shine under\nthe moonlight.",
		rarity = 5,
	},

	["nova sneakers"] = {
		name = "Nova Sneakers",
		type = WPT_SHOES,
		atk = 1800,
		desc = "Shoes imbuded with the\nblessing of the moon.\nA shining aura bursts\nout of them under the\nmoonlight.",
		rarity = 6,
	},

	["cometstream"] = {
		name = "Cometstream",
		type = WPT_SHOES,
		atk = 2400,
		desc = "Only light may race with\nthese Shoes' wearer.\nThe trail they leave\nbehind banishes darkness.",
		rarity = 7,
		st = 5,
		ma = 5,
		en = 5,
		ag = 5,
		lu = 5,
	},

	["device_01"] = {
		name = "Badnik Device",
		type = WPT_REMOTE,
		atk = 230,
		desc = "Command an army of\nCrawlas to attack.",
		slot = "mastery 1",
		rarity = 1,
	},

	["ion remote"] = {
		name = "Ion Remote",
		type = WPT_REMOTE,
		atk = 900,
		desc = "A Remote upgraded through\nfusion. It can hold\n a surprisingly high voltage.",
		ma = 1,
		lu = 1,
		slot = "mastery 2",
		rarity = 3,
	},

	["dyne remote"] = {
		name = "Dyne Remote",
		type = WPT_REMOTE,
		atk = 1500,
		desc = "A Remote upgraded through\nfusion. Commands lightning, somehow.",
		ma = 3,
		lu = 3,
		slot = "mastery 3",
		rarity = 5,
	},

	["star's order"] = {
		name = "Star's Order",
		type = WPT_REMOTE,
		atk = 2400,
		desc = "Fires an orbital strike\nfrom the broken\nremnants of the Egg Rock\nusing the cosmos' will.",
		rarity = 7,
		st = 5,
		ma = 5,
		en = 5,
		ag = 5,
		lu = 5,
	},

	["blades_01"] = {
		name = "Hand Sonic",
		type = WPT_HANDSONIC,
		atk = 300,
		desc = "Sharp Blades attached to\none's sleeves.",
		slot = "mastery 1",
		rarity = 1,
	},

	["ion sabers"] = {
		name = "Ion Sabers",
		type = WPT_HANDSONIC,
		atk = 900,
		desc = "Blades upgraded through fusion.\nThey cut rocks in half.",
		st = 1,
		ag = 1,
		slot = "mastery 2",
		rarity = 3,
	},

	["dyne sabers"] = {
		name = "Dyne Sabers",
		type = WPT_HANDSONIC,
		atk = 1500,
		desc = "Blades upgraded through\nfusion. Might accidentally slice\na building or two.",
		st = 3,
		ag = 3,
		slot = "mastery 3",
		rarity = 5,
	},

	["hammer_01"] = {
		name = "Piko Piko",
		type = WPT_HAMMER,
		atk = 280,
		desc = "Amy's trusty hammer.",
		slot = "mastery 1",
		rarity = 1,
	},

	["ion slammer"] = {
		name = "Ion Slammer",
		type = WPT_HAMMER,
		atk = 900,
		desc = "A Hammer upgraded through\nfusion. It gets hotter the\nmore intense its wielder's feelings are.",
		ma = 1,
		en = 1,
		slot = "mastery 2",
		rarity = 3,
	},

	["dyne slammer"] = {
		name = "Dyne Slammer",
		type = WPT_HAMMER,
		atk = 1500,
		desc = "A Hammer upgraded through\nfusion. Materializes\nits wielder's burning passion.",
		ma = 3,
		en = 3,
		slot = "mastery 3",
		rarity = 5,
	},

	["star crusher"] = {
		name = "Star Crusher",
		type = WPT_HAMMER,
		atk = 2400,
		desc = "Those who slam this hammer\nmake the stars shiver.\nThose who get slammed by\nthis hammer are never heard\nfrom ever again.",
		rarity = 7,
		st = 5,
		ma = 5,
		en = 5,
		ag = 5,
		lu = 5,
	},

	["knuckles_01"] = {
		name = "Spiked Gloves",
		type = WPT_KNUCKLES,
		atk = 350,
		desc = "Spiked gloves that go\nthrough boulders.",
		slot = "mastery 1",
		rarity = 1,
	},

	["ion breakles"] = {
		name = "Ion Breakles",
		type = WPT_KNUCKLES,
		atk = 900,
		desc = "Knuckles upgraded through\nfusion. Their punches produce\nradiations.",
		st = 1,
		en = 1,
		slot = "mastery 2",
		rarity = 3,
	},

	["dyne breakles"] = {
		name = "Dyne Breakles",
		type = WPT_KNUCKLES,
		atk = 1500,
		desc = "Knuckles upgraded through\nfusion. Can rival a nuclear power\nplant under the right circumstances.",
		st = 3,
		en = 3,
		slot = "mastery 3",
		rarity = 5,
	},

	["cosmos breaker"] = {
		name = "Cosmos Breaker",
		type = WPT_KNUCKLES,
		atk = 2400,
		desc = "Gloves cappable of\npunching holes through the\nvery cosmos.",
		rarity = 7,
		st = 5,
		ma = 5,
		en = 5,
		ag = 5,
		lu = 5,
	},

	["claws_01"] = {
		name = "Metal Claws",
		type = WPT_CLAWS,
		atk = 350,
		desc = "Claws cappable of shredding\nthrough steel.",
		slot = "mastery 1",
		rarity = 1,
	},


	["ion slicers"] = {
		name = "Ion Slicers",
		type = WPT_CLAWS,
		atk = 1000,
		desc = "Claws upgraded through\nfusion. A dark trail is left\nbehind their swings.",
		st = 1,
		en = 1,
		slot = "mastery 2",
		rarity = 3,
	},

	["dyne slicers"] = {
		name = "Dyne Slicers",
		type = WPT_CLAWS,
		atk = 1600,
		desc = "Claws upgraded through\nfusion. Even if just for\nan instant, they rip light apart.",
		st = 3,
		en = 3,
		slot = "mastery 3",
		rarity = 5,
	},

	["cosmos shredders"] = {
		name = "Cosmos Shredders",
		type = WPT_CLAWS,
		atk = 2400,
		desc = "A slice from these Claws\nreduces anything it tears\nto atoms.",
		rarity = 7,
		st = 5,
		ma = 5,
		en = 5,
		ag = 5,
		lu = 5,
	},

	["monitor_01"] = {
		name = "Fake Box",
		type = WPT_MONITOR,
		atk = 280,
		desc = "Monitor loaded with explosives",
		slot = "mastery 1",
		rarity = 1,
	},

	["ion monitor"] = {
		name = "Ion Monitor",
		type = WPT_MONITOR,
		atk = 900,
		desc = "A Monitor upgraded through\nfusion. It keeps\ntrack of abnormalities.",
		ma = 1,
		lu = 1,
		slot = "mastery 2",
		rarity = 3,
	},

	["dyne monitor"] = {
		name = "Dyne Monitor",
		type = WPT_MONITOR,
		atk = 1500,
		desc = "A Monitor upgraded through\nfusion. It monitors lifeforms'\nhealth and acts upon it.",
		ma = 3,
		lu = 3,
		slot = "mastery 3",
		rarity = 5,
	},

	["cosmic recorder"] = {
		name = "Cosmic Recorder",
		type = WPT_MONITOR,
		atk = 2400,
		desc = "A monitor that has\nkept track of History.\nDetonating it unleashes\ncataclysms of past tragedies\nupon the target.",
		rarity = 7,
		st = 5,
		ma = 5,
		en = 5,
		ag = 5,
		lu = 5,
	},

	["limiter_01"] = {
		name = "Chaos Limiter",
		type = WPT_LIMITERS,
		atk = 300,
		desc = "High-tech Chaos limiters\nthat allow for a\ncompromise between power\nand safety.",
		slot = "mastery 1",
		rarity = 1,
	},

	["ion shackles"] = {
		name = "Ion Shackle",
		type = WPT_LIMITERS,
		atk = 900,
		desc = "Limiters upgraded through\nfusion. It has some\ncontrol over gravity.",
		st = 1,
		ag = 1,
		slot = "mastery 2",
		rarity = 3,
	},

	["dyne shackles"] = {
		name = "Dyne Shackles",
		type = WPT_LIMITERS,
		atk = 1500,
		desc = "Limiters upgraded through\nfusion. It holds dominion over\nthe surrounding gravity.",
		st = 3,
		ag = 3,
		slot = "mastery 3",
		rarity = 5,
	},

	["chaos unlocker"] = {
		name = "Chaos' Unlocker",
		type = WPT_LIMITERS,
		atk = 2400,
		desc = "Only by wearing these\nLimiters can one\ntruly reach their limit.",
		rarity = 7,
		st = 5,
		ma = 5,
		en = 5,
		ag = 5,
		lu = 5,
	},

	["psygloves_01"] = {
		name = "Psy Gloves",
		type = WPT_PSYGLOVES,
		atk = 280,
		desc = "Powerful Psychic gloves\nto smash your enemies from\na distance with!",
		slot = "mastery 1",
		rarity = 1,
	},

	["ion gauntlets"] = {
		name = "Ion Gauntlets",
		type = WPT_PSYGLOVES,
		atk = 900,
		desc = "Gloves upgraded through\nfusion. They shoot light\nbeams.",
		ma = 1,
		lu = 1,
		slot = "mastery 2",
		rarity = 3,
	},

	["dyne gauntlets"] = {
		name = "Dyne Gauntlets",
		type = WPT_PSYGLOVES,
		atk = 1500,
		desc = "Gloves upgraded through\nfusion. They can bend light\nand erase darkness.",
		ma = 3,
		lu = 3,
		slot = "mastery 3",
		rarity = 5,
	},

	["cosmic manipulator"] = {
		name = "Cosmic Manipulator",
		type = WPT_PSYGLOVES,
		atk = 2400,
		desc = "Divine gloves cappable\nof shaping the universe to\none's will.",
		rarity = 7,
		st = 5,
		ma = 5,
		en = 5,
		ag = 5,
		lu = 5,
	},

	["heels_01"] = {
		name = "Royal Heels",
		type = WPT_HEELS,
		atk = 300,
		desc = "Heels sharp enough\nto pierce through steel.",
		slot = "mastery 1",
		rarity = 1,
	},

	["ion escarpin"] = {
		name = "Ion Escarpin",
		type = WPT_HEELS,
		atk = 900,
		desc = "Heels upgraded through\nfusion. They hold their wielder's\noriginal purpose.",
		ma = 1,
		en = 1,
		slot = "mastery 2",
		rarity = 3,
	},

	["dyne escarpin"] = {
		name = "Dyne Escarpin",
		type = WPT_HEELS,
		atk = 1500,
		desc = "Heels upgraded through\nfusion. They contain their wielder's\nfull potential.",
		ma = 3,
		en = 3,
		slot = "mastery 3",
		rarity = 5,
	},

	["planetary piercers"] = {
		name = "Planetary Piercers",
		type = WPT_HEELS,
		atk = 2400,
		desc = "Heels with the power\nto pierce through an\nentire planet.",
		rarity = 7,
		st = 5,
		ma = 5,
		en = 5,
		ag = 5,
		lu = 5,
	},
})

local defaulttypes = {
	WPT_SHOES, WPT_MONITOR, WPT_LIMITERS, WPT_HEELS, WPT_PSYGLOVES, WPT_KNUCKLES, WPT_HAMMER, WPT_REMOTE, WPT_CLAWS, WPT_GENERICMELEE, WPT_GENERICRANGED, WPT_HANDSONIC
}

local typenames = {
	[WPT_SHOES] = "Sneakers",
	[WPT_MONITOR] = "Monitor",
	[WPT_KNUCKLES] = "Knuckles",
	[WPT_LIMITERS] = "Limiters",
	[WPT_HAMMER] = "Hammer",
	[WPT_CLAWS] = "Claws",
	[WPT_REMOTE] = "Device",
	[WPT_HEELS] = "Heels",
	[WPT_PSYGLOVES] = "Gloves",
	[WPT_GENERICMELEE] = "Rapier",
	[WPT_GENERICRANGED] = "Handgun",
	[WPT_HANDSONIC] = "Blades",
}

-- Weapon series
rawset(_G, "weaponSeries", {})

-- drops a weapon from a series with skewed odds to be more likely to drop equippable weapons by the team that dropped it
rawset(_G, "dropWeaponFromSeries", function(series, team)

	if not team return end
	if not series return end

	local weplist = weaponSeries[series]
	if not weplist return end

	local wep = nil
	local tries = 3

	while tries
		wep = weplist[P_RandomRange(1, #weplist)]
		local twep = makeWeapon(wep)
		local wt = weaponsList[twep.ref].type

		local special_type_in_team
		if wt < WPT_HANDSONIC
			special_type_in_team = true
		end

		for i = 1, #team
			if canEquipWeapon(team[i], twep)
				tries = 1	-- we're good
				special_type_in_team = true
				break
			end

			if wt >= WPT_HANDSONIC	-- special weapons
			and wt == getEquipWeaponType(team[i])
				special_type_in_team = true
			end
		end

		if not special_type_in_team
			tries = $+1	-- get another weapon.
		end
		-- othherwise... try again.
		tries = $-1
	end

	-- after 3 tries, just give us whatever weapon we dropped
	return wep
end)

rawset(_G, "createWeaponSeries", function(name, power, accuracy, stats, slot, rarity, types, description, elem)

	local lname = name:lower()
	weaponSeries[lname] = {}

	for i = 1, #types do

		local wpt = types[i]

		local wpnname = name.." "..typenames[wpt]
		local index = wpnname:lower()

		weaponsList[index] = {
			name = wpnname,
			wtype = wpt,
			type = wpt,
			atk = power,
			rarity = rarity,
			slot = slot,
			desc = description,
			element = elem,
			acc = accuracy,
		}

		local checkstats = {"st", "ma", "en", "ag", "lu"}
		for j = 1, #stats do
			weaponsList[index][checkstats[j]] = stats[j] or 0
		end
		table.insert(weaponSeries[lname], index)

		--print("Created "..wpnname.." (Added to '"..lname.."'series list)")
	end
end)

/*
-------------------------------------------
TIER 1: Drop from Thebel and Arqa
-------------------------------------------

*1: 	Stock Series 		<base weapons>
*2:		Comun Series 		(ATK: 32-43, 		SLOT: 	Reflex I)
*3:		Rekla Series 		(ATK: 35-47, 		SLOT: 	Reflex I)

--- RARE ---
*4:		Qualz Series 		(ATK: 37-49, 		SLOT:	Patra			En +1)
*5:		Vinquir Series 		(ATK: 40-51,		SLOT: 	Rebellion		Lu +1)
*/

createWeaponSeries("Comun", 320, 98, {1, 1, 0, 0, 0}, "reflex 1", 2, defaulttypes, "The Comun series is a slight\nadvancement compared to basic weapons.\nBut many consider them too weak still")
createWeaponSeries("Rekla", 350, 98, {0, 0, 1, 0, 0}, "reflex 1", 3, defaulttypes, "The Rekla series carries\nwith it slightly more consistency\nin its power.")

createWeaponSeries("Qualz", 370, 98, {0, 0, 3, 0, 0}, "patra", 4, defaulttypes, "A defensive weapon series that\ncan even cure illnesses,\ngiven the power.")
createWeaponSeries("Vincir", 400, 98, {1, 1, 0, 0, 2}, "rebellion", 5, defaulttypes, "A weapon series worn by the\nvictorious.")


/*

TIER 2

*1 Lambda Series			(ATK: 35-47		SLOT: Precision I)
*2 Dia Series				(ATK: 39-52		SLOT: Dia)
*3 Blue Series				(ATK: 43-58		SLOT: Mabufu)
*4 Sinnrit Series			(ATK: 45-60		SLOT: Mudo					Lu +1)
*4 Honlyn Series			(ATK: 45-60		SLOT: Hama					Lu +1)

--- RARE ---
*5 Gliden Series			(ATK: 48-65		SLOT: Mazio					Ag +1)
*6 Maha Series				(ATK: 55-74		SLOT: Precision II			Ma +1	Ag +1)
*6 Strania Series			(ATK: 55-74		SLOT: Might II				St +1	Ag +1)
*/

createWeaponSeries("Lambda", 350, 90, {}, "precision 1", 1, defaulttypes, "An easy to produce series\n, slightly stronger than some of\nits counterparts.")
createWeaponSeries("Dia", 390, 80, {0, 1, 0, 0, 0}, "dia", 2, defaulttypes, "A series named after its\nskill slot.")
createWeaponSeries("Blue", 430, 80, {0, 1, 0, 0, 0}, "mabufu", 3, defaulttypes, "A weapon series that\ncan produce magic similar to ice.")
createWeaponSeries("Honlyn", 450, 85, {0, 0, 0, 0, 2}, "hama", 4, defaulttypes, "Honlyn Shirit...")
createWeaponSeries("Sinnrit", 450, 85, {0, 0, 0, 0, 2}, "mudo", 4, defaulttypes, "...Look behind you.")

createWeaponSeries("Gliden", 480, 99, {0, 2, 0, 1, 0}, "zionga", 5, defaulttypes, "A weapon series that could\nalmost shock opponents with\na touch.")

local magictypes = {WPT_MONITOR, WPT_REMOTE, WPT_HAMMER, WPT_HEELS, WPT_PSYGLOVES, WPT_GENERICRANGED}
local physicaltypes = {WPT_SHOES, WPT_LIMITERS, WPT_CLAWS, WPT_HANDSONIC, WPT_KNUCKLES, WPT_GENERICMELEE}
createWeaponSeries("Maha", 550, 92, {-3, 3, -1, 1, 0}, "precision 2", 6, magictypes, "A weapon imbuded with magic\npowers.")
createWeaponSeries("Strania", 550, 92, {3, -3, -1, 1, 0}, "might 2", 6, physicaltypes, "A weapon imbuded with sheer\nmight.")


/*
TIER 3

*1 Dion Series				(ATK: 45-60		SLOT: Toughness II			Ag +1)
*2 Alter Series				(ATK: 49-66		SLOT: Technique II			Ag +1)
*3 Red Series				(ATK: 55-74		SLOT: Precision II			Ag +1)
*4 V2-Comun Series			(ATK: 61-82		SLOT: Reflex III			En +1 	Ag+1)

--- RARE ---
*5 Vitalis Series			(ATK 65-87		SLOT: Regenerate 2			St +1	Ag +1)
*5 Spirita Series			(ATK 65-87		SLOT: Invigorate 1			Ma +1	En +1)
*6 V2-Rekla Series			(ATK 70-94		SLOT: Mastery II			St +1	Ma +1	Ag +1	En +1)
*/

createWeaponSeries("Dion", 450, 95, {0, 0, 1, 1, 0}, "toughness 2", 1, defaulttypes, "Some say the name of this series\nis 'One letter away\nfrom disaster'")
createWeaponSeries("Alter", 490, 95, {0, 0, 1, 1, 0}, "technique 2", 2, defaulttypes, "Weapons of this series rely\non crafty techniques to be efficient.")
createWeaponSeries("Red", 550, 98, {0, 0, 0, 1, 0}, "precision 2", 3, defaulttypes, "An upgrade to the 'Blue'\nseries. What it lost in\nmagic proess, it gained in\npotential efficiency.")
createWeaponSeries("V2-Comun", 610, 90, {0, 0, 2, 1, 0}, "reflex 3", 4, defaulttypes, "A new version of the Comun\nseries. These weapons offer\nhigh defensive options,\nstrangely enough.")

createWeaponSeries("Vitalis", 650, 50, {2, 0, 0, 2, 0}, "regenerate 2", 5, physicaltypes, "Those who wield this series\ncan find the strength to stand\nback up from any bad beat.")
createWeaponSeries("Spirita", 650, 50, {0, 2, 2, 0, 0}, "invigorate 1", 5, magictypes, "Those who wield this series\ncan find the resolve to stand\nagainst any problem.")
createWeaponSeries("V2-Rekla", 700, 100, {2, 2, 2, 2, 0}, "mastery 2", 6, defaulttypes, "A major upgrade to the Rekla\nseries, now with high\noffensive capabilities.")


/*
TIER 4

*2 Dim Series				(ATK: 67-90		SLOT: Guard I				En +1	Ag +1)
*2 Bright Series			(ATK: 67-90		SLOT: Mastery I				En +1	Ag +1)
*3 Wilh Series				(ATK 74-99		SLOT: Endure				En +1	Lu +1)
*4 Alva Series				(ATK 80-108		SLOT: Technique III			Ag +1	Lu +1)

--- RARE ---

*5 Reaver Series			(ATK 91-122		SLOT: Last Stand			St +1	Ma +1	Ag +1)	(Dmg +20% if HP < 50%)
*6 Revoluzio Series			(ATK 101-136	SLOT: Equalizer				St +2	Ma +2	Ag +1)	(Weak/Crit/Tech dmg - 25%, All dmg +7%)
*/

createWeaponSeries("Dim", 670, 95, {0, 0, 2, 2, 0}, "guard 2", 2, defaulttypes, "Once a rarity.\nVery common now.")
createWeaponSeries("Bright", 670, 95, {0, 0, 2, 2, 0}, "mastery 1", 2, defaulttypes, "An offensive counterpart\nto the Dim series.")
createWeaponSeries("Wilh", 740, 75, {-1, -1, 3, 0, 2}, "endure", 3, defaulttypes, "The spirit of a knight\ninhabits this weapon. Never\nyield!")
createWeaponSeries("Alva", 800, 85, {0, 0, 0, 2, 2}, "technique 3", 4, defaulttypes, "An upgrade to the Alter\nseries. Its core functionality\nremains.")

createWeaponSeries("Reaver", 910, 99, {2, 2, -3, 1, 0}, "last stand", 5, defaulttypes, "A stylized font reads\n'Never yield' on the\nside.")
createWeaponSeries("Revoluzio", 1010, 100, {3, 3, 0, 1, 0}, "equalizer", 6, defaulttypes, "Enemies targetted by this\nweapon better have an\nescape plan on the ready.")

/*

TIER 5

*1 V2-Vincir Series			(ATK: 88-118	SLOT: Might III				St +1)
*2 Laser Series				(ATK: 96-129	SLOT: Precision III			Ma +1)
*3 Nox Series				(ATK: 107-144	SLOT: Spirit Surge			Ma +2)					(Dmg +20% if SP < 50%)

--- RARE ---
*5 V2-Dion Series			(ATK 125-168	SLOT: Guard III				St +1	Ma +1	En +3)
*5 V2-Lambda Series			(ATK 125-168	SLOT: Mastery III			St +2	Ma +2	En +1)
*6 Agil Series				(ATK 142-191	SLOT: Challenger II			St +3	Ma +3	Ag +3)	(Dmg +20% against bosses)

*/

createWeaponSeries("V2-Vincir", 880, 95, {2, 0, 0, 0, 0}, "might 3", 1, defaulttypes, "A cheap to produce upgrade\nto the Vincir series.")
createWeaponSeries("Laser", 960, 90, {0, 2, 0, 0, 0}, "precision 3", 2, defaulttypes, "It has laser sights.\nIt's debatable whether it's\nreally useful on\nmelee weapons...")
createWeaponSeries("Nox", 1070, 90, {0, 3, 0, 0, -2}, "spirit surge", 3, defaulttypes, "A very cheap weapon for the power\nit theoritically allows for.")

createWeaponSeries("V2-Dion", 1250, 75, {-1, -1, 5, 0, 0}, "guard 3", 5, defaulttypes, "An upgrade to the Dion series.\nMany wonder why it wasn't\nrebranded.")
createWeaponSeries("V2-Lambda", 1250, 99, {2, 2, 1, 0, 0}, "mastery 3", 5, defaulttypes, "An upgrade to the Lambda\nseries. It's proficient in many\nthings, now.")
createWeaponSeries("Agil", 1420, 100, {3, 3, -1, 0, 0}, "challenger 2", 6, defaulttypes, "A weapon specifically designed\nto take on tough foes.")

/*

TIER 6

*1 Novel Series				(ATK 145-191	SLOT: Mastery II			Ma +1	St +1)
*3 V2-Alter Series			(ATK 153-206	SLOT: Technique III			Ma +3	St +3)
*4 V2-Vitalis Series		(ATK 166-224	SLOT: Regenerate 3			St +4	En +2)
*4 V2-Spirita Series		(ATK 166-224	SLOT: Invigorate 2			Ma +4	Ag +2)

--- RARE ---
*5 Awake Series				(ATK 176-237	SLOT: Challenger II			St +3	Ma +3)			(Dmg +20% against bosses)
*5 Obliance Series			(ATK 176-237	SLOT: Ignorance				St +3	Ma +3)			(Ignore enemy resistances, weak/crit/tech dmg -5%)
*6 Freifi Series			(ATK 189-255	SLOT: Freifi Aura			All +3 )				(More powerful version of Mastery III, +10% damage against bosses)
*7 Buhn Series				(ATK 200-270	SLOT: Unfathomable Darkenss	All +4 )				(Effects of 'Freifi Aura' + chance of instant kill (9999 damage) (5%) on non-boss foes

*/

createWeaponSeries("Novel", 2200, 85, {-2, -2, -2, -2, -2}, "mastery 2", 1, defaulttypes, "A mass produced, strong\nweapon series. It hits hard as a weapon\but many say it leaves much to be desired\nas a support tool...")
createWeaponSeries("V2-Alter", 1530, 95, {3, 3, 0, 0, 0}, "technique 3", 3, defaulttypes, "The ultimate upgrade to the\nAlter series. It recovers its\norginal branding and maximizes\nits strengths.")
createWeaponSeries("V2-Vitalis", 1660, 90, {5, -6, 0, 3, 0}, "regenerate 3", 4, physicaltypes, "An upgrade to the Vitalis series.\nIt magnifies recovery on its\nwielder.")
createWeaponSeries("V2-Spirita", 1660, 90, {-6, 5, 3, 0, 0}, "invigorate 2", 4, magictypes, "An upgrade to the Spirita series.\nIt magnifies concentration.")

createWeaponSeries("Awake", 1760, 100, {3, 3, -3, 0, 0}, "challenger 2", 5, defaulttypes, "A new, more accessible take\non the Agil series.")
createWeaponSeries("Obliance", 1760, 100, {3, 3, 0, 0, 0}, "ignorance", 5, defaulttypes, "A unique weapon that requires\nless thought process to use,\nwhen given the power.")
createWeaponSeries("Freifi", 1890, 100, {4, 4, 3, 3, 3}, "freifi aura", 6, defaulttypes, "The strongest conventional\nseries of weapons.\nThere isn't much competition.")

createWeaponSeries("Ragged", 2050, 100, {5, 5, -7, 5, 2}, "rending scythe", 7, defaulttypes, "A weapon torn off from he\nwho brings rest to souls.")
createWeaponSeries("Buhn", 2200, 100, {6, 6, 4, 4, 4}, "unfathomable darkness", 7, defaulttypes, "Honlyn Shirit.\nIt has arrived.")


-- VOID RUN SPECIFIC WEAPON SERIES
createWeaponSeries("Foie", 410, 90, {2, 2, 0, 0, -2}, "precision 2", 3, defaulttypes, "A weapon series capable of producing flames.\nIt's pretty weak.", ATK_FIRE)
createWeaponSeries("Barta", 410, 90, {2, 2, 0, 0, -2}, "precision 2", 3, defaulttypes, "A weapon series capable of producing snowflakes.\nIt's pretty weak.", ATK_ICE)
createWeaponSeries("Zan", 410, 90, {2, 2, 0, 0, -2}, "precision 2", 3, defaulttypes, "A weapon series capable of producing gusts.\nIt's pretty weak.", ATK_WIND)
createWeaponSeries("Zonde", 410, 90, {2, 2, 0, 0, -2}, "precision 2", 3, defaulttypes, "A weapon series capable of producing sparks.\nIt's pretty weak.", ATK_ELEC)

createWeaponSeries("Rafoie", 780, 90, {3, 3, 0, 0, -1}, "precision 2", 4, defaulttypes, "A weapon series capable of producing flames.\nIt looks strong.", ATK_FIRE)
createWeaponSeries("Rabarta", 780, 90, {3, 3, 0, 0, -1}, "precision 2", 4, defaulttypes, "A weapon series capable of producing snowflakes.\nIt looks strong.", ATK_ICE)
createWeaponSeries("Razan", 780, 90, {3, 3, 0, 0, -1}, "precision 2", 4, defaulttypes, "A weapon series capable of producing gusts.\nIt looks strong.", ATK_WIND)
createWeaponSeries("Razonde", 780, 90, {3, 3, 0, 0, -1}, "precision 2", 4, defaulttypes, "A weapon series capable of producing sparks.\nIt looks strong.", ATK_ELEC)

createWeaponSeries("Nafoie", 1250, 90, {4, 4, 0, 0, 0}, "precision 3", 5, defaulttypes, "A weapon series capable of producing flames.\nIt looks strong.", ATK_FIRE)
createWeaponSeries("Nabarta", 1250, 90, {4, 4, 0, 0, 0}, "precision 3", 5, defaulttypes, "A weapon series capable of producing snowflakes.\nIt looks strong.", ATK_ICE)
createWeaponSeries("Nazan", 1250, 90, {4, 4, 0, 0, 0}, "precision 3", 5, defaulttypes, "A weapon series capable of producing gusts.\nIt looks strong.", ATK_WIND)
createWeaponSeries("Nazonde", 1250, 90, {4, 4, 0, 0, 0}, "precision 3", 5, defaulttypes, "A weapon series capable of producing sparks.\nIt looks strong.", ATK_ELEC)