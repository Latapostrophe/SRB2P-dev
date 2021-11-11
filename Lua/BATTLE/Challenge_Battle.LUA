-- challenge battle definitions:

-- start callenge battles
-- by the time this is loaded, Dungeon_Handler.LUA has already spawned our player entities, we are then free to begin a battle!

-- @TODO: Probably make this into a rawset function and load it into a single ThinkFrame for optimization, though I doubt it will change much

-- helper function for adding score:
rawset(_G, "BTL_addScore", function(pn, score, message)

	local str = ""
	if message
		str = $..message.."\n"
		str = $.."\x82".."+"..score.." points!"

		BTL_logMessage(pn, str)
	end

	local btl = server.P_BattleStatus[pn]

	btl.addscore = $ and $ + score or score
	btl.addscorewait = 20	-- wait 20 tics before counting the score
end)

addHook("ThinkFrame", do
	if not server return end
	if leveltime ~= TICRATE*3 return end
	if server.gamemode ~= GM_CHALLENGE return end	-- doesn't concern me

	-- init arena center first:

	local shiftx = (mapheaderinfo[gamemap].arenashiftx or 0) *FRACUNIT
	local shifty = (mapheaderinfo[gamemap].arenashifty or 0) *FRACUNIT	-- mp arena shift
	local center

	for m in mobjs.iterate()
		if not m or not m.valid continue end

		if m.type == DNG_ARENAPOINT and m.spawnpoint -- and m.spawnpoint.extrainfo == battlen
			center = m
			break
		end
	end

	if not center
		print("\x82".."WARNING: ".."\x80"..": No Arena center, impossible to start the battle.")
	return end	-- youch

	for i = 1, 4	-- I suppose there's no harm in setting them all for posterity
		server.P_BattleStatus[i].arena_coords[1] = center.x + shiftx*(i-1)
		server.P_BattleStatus[i].arena_coords[2] = center.y + shifty*(i-1)
		server.P_BattleStatus[i].arena_coords[3] = center.z
		server.P_BattleStatus[i].arena_coords[4] = center.angle
		dprint("Succesfully set new arena coordinates!")

		if not server.P_netstat.leaders[i] continue end
		local header = BTL_challengebtllist[server.P_netstat.buffer.extradata]
		local scoremode

		if header.score
			scoremode = 1
		end

		local team_1 = server.plentities[1]
		local team_2 = {}

		local wave = 1
		if scoremode	-- In score attack, start with a random wave!
			wave = P_RandomRange(1, #header.waves)
		end

		for j = 1, #header.waves[wave]
			local enm = P_SpawnMobj(0, 0, 0, MT_PFIGHTER)
			enm.state = S_PLAY_STND
			enm.tics = -1
			enm.enemy = header.waves[wave][j]
			team_2[#team_2+1] = enm
		end

		local btl = server.P_BattleStatus[i]
		btl.superform = header.superform
		-- now initiate the battle between those two teams
		BTL_StartBattle(1, team_1, team_2, 0, nil, header.music or "PVP")

		if scoremode
			btl.scoremode = true
			btl.score = 0
			btl.waven = wave
		else
			btl.scoremode = nil
			btl.score = nil	-- just making sure...
			btl.waven = 1
		end

		--btl.items = {{"snuffsoul", 4}, {"hyperring", 4}, {"hypercombiring", 2}, {"me patra gem", 4}, {"1up", 1}}	-- team1's items
		btl.items = {}
		if header.items and #header.items
			for i = 1, #header.items do
				btl.items[i] = {}
				btl.items[i][1] = header.items[i][1]
				btl.items[i][2] = header.items[i][2]	-- do NOT directly affect the table memory adress, or terrible stuff would happen
			end
		end

		btl.subpersonas = {P_generateSubPersona("none")}
		if header.subpersonas
			for i = 1, #header.subpersonas

				local s = header.subpersonas[i]

				if s == "none" continue end	-- Already in.

				if type(s) == "string"	-- generate it
					local generated = P_generateSubPersona(s)
					if generated
						header.subpersonas[#header.subpersonas+1] = generated
					else
						print("\x82".."WARNING:".."\x80".." Invalid Sub-Persona '"..s.."' for selected Challenge Battle. Not adding.")
					end
				end
			end
		end

		btl.emeraldpow_max = 0
		btl.challenge = server.P_netstat.buffer.extradata
	end
end)

-- struct:
/*
	name: name of the encounter
	difficulty: difficulty rating (1-7)
	description: descrption of the challenge
	time: time limit
	score:	 If true, have infinite waves and ready the score system
	level: level the player character starts at
	items: forced item list for this battle
	subpersonas: forced subp list for this battle
	waves: {	{"enemy1", "enemy2", ...},
				{"enemy1", [.....]}
				[...]
			},
*/

rawset(_G, "BTL_challengebtllist", {

	{
		name = "Warm Up",
		description = "Weaklings. Show them their place!",
		difficulty = 0,
		time = TICRATE*60*10,
		music = "BATL1",
		items = {{"superring", 10}, {"snuffsoul", 5}, {"1up", 2}},
		subpersonas = {},
		level = 5,
		waves = {

					{"maya_1", "maya_1"},
					{"hand_1", "maya_1", "hand_1"},
					{"table_1", "hand_1", "hand_1", "maya_1"}
				},

	},

	{
		name = "Shadow Ambush",
		description = "Kill them! Destroy them all!",
		difficulty = 1,
		music = "VSNQST",
		time = TICRATE*60*8,
		items = {{"superring", 10}, {"snuffsoul", 5}, {"1up", 2}},
		subpersonas = {},
		level = 7,
		waves = {
					{"table_1", "hand_1", "hand_1"},
					{"balance_1", "hand_1", "balance_1"},
					{"beetle_1", "relic_1", "beetle_1"}
				},
	},

	{
		name = "Thebel Showdown",
		description = {"Fend off waves of enemies from", "the Thebel block to acquire points", "until time runs out!"},
		difficulty = 1,
		music = "VSNQST",
		time = TICRATE*60*5,
		items = {{"superring", 99}, {"snuffsoul", 99}, {"1up", 99}},
		subpersonas = {},
		score = true,	-- Score attack
		level = 7,
		waves = {

					{	"balance_1_postboss",
						"table_1_postboss",
						"balance_1_postboss"
					},

					{	"hablerie_1_postboss",
						"beetle_1",
						"maya_1_postboss"
					},

					{	"table_1_postboss",
						"mage_1",
						"table_1_postboss"
					},

					{	"relic_1",
						"maya_1_postboss",
						"cupid_1",
					},

					{	"hand_1_postboss",
						"relic_1",
						"hand_1_postboss",
					},

					{	"maya_1_postboss",
						"cupid_1",
						"maya_1_postboss",
						"maya_1_postboss"
					},

					{	"maya_1_postboss",
						"balance_1_postboss",
						"maya_1_postboss",
						"balance_1_postboss"
					},

					{	"table_1_postboss",
						"table_1_postboss",
						"table_1_postboss"
					},
					
					{
						"hablerie_1_postboss",
						"cupid_1",
						"hablerie_1_postboss",
					},
					
					{
						"table_1_postboss",
						"cupid_1",
						"cupid_1",
						"hablerie_1_postboss",
					},


				},
	},

	{
		name = "Crying Tables",
		description = "Defeat the Crying Tables once more!",
		difficulty = 2,
		time = TICRATE*60*10,
		items = {{"superring", 10}, {"snuffsoul", 5}, {"1up", 2}},
		subpersonas = {},
		music = "VSNQST",
		level = 5,
		waves = {
					{"table_boss1", "table_boss1", "table_boss1"}
				},

	},

	{
		name = "Drive to rampage",
		description = "Defeat the Rampage Drive once more!",
		difficulty = 3,
		time = TICRATE*60*10,
		items = {{"superring", 10}, {"snuffsoul", 5}, {"1up", 2}},
		subpersonas = {},
		music = "VSNQST",
		level = 8,
		waves = {
					{"drive_boss1"}
				},

	},

	{
		name = "Arqa Showdown",
		description = {"Fend off waves of enemies from", "the Arqa block to acquire points", "until time runs out!"},
		difficulty = 1,
		music = "VSNQST",
		time = TICRATE*60*5,
		items = {{"superring", 99}, {"snuffsoul", 99}, {"1up", 99}},
		subpersonas = {},
		score = true,	-- Score attack
		level = 14,
		waves = {
					{
						"book_1",
						"tiara_1_postboss",
						"beast_1_postboss",
						"basalt_1",
					},

					{	"wheel_1"},
					{	"wheel_1"},	-- make wave a bit more common		

					{
						"maya_2_postboss",
						"beast_1_postboss",
						"maya_2_postboss",
						"beast_1_postboss",
					},

					{
						"sword_1_postboss",
						"twins_1",
						"twins_1",
						"pesce_1_postboss",
					},

					{
						"tiara_1_postboss",
						"tiara_1_postboss",
						"basalt_1",
						"tiara_1_postboss",
					},

					{
						"balance_2",
						"balance_3",
						"fuzz_1_postboss",
					},

					{
						"balance_3",
						"maya_2_postboss",
						"maya_2_postboss",
					},

					{
						"twins_1",
						"book_1",
						"twins_1",
						"basalt_1",
					},
					
					{
						"pesce_1_postboss",
						"maya_2_postboss",
						"pesce_1_postboss",
					},
					
					{
						"fuzz_1_postboss",
						"basalt_1",
						"basalt_1",
						"fuzz_1_postboss",
					},
					
					{
						"balance_3",
						"pesce_1_postboss",
						"balance_3",
					},
					
					{
						"pesce_1_postboss",
						"twins_1",
						"twins_1",
						"fuzz_1_postboss",
					},
					
					{
						"basalt_1",
						"maya_2_postboss",
						"fuzz_1_postboss",
						"sword_1_postboss",
					},		

					{
						"sword_1_postboss",
						"maya_2_postboss",
						"pesce_1_postboss",
						"sword_1_postboss",
					},	
				},
	},

	{
		name = "Golden Experiences",
		description = "Defeat the Golden Beetles once more!",
		difficulty = 2,
		time = TICRATE*60*10,
		items = {{"superring", 10}, {"snuffsoul", 5}, {"1up", 2}},
		subpersonas = {},
		music = "VSNQST",
		level = 14,
		waves = {
					{"beetle_boss1", "beetle_boss1", "beetle_boss1"}
				},

	},

	{
		name = "Uranium Menace",
		description = "Defeat the Radioactive Relic once more!",
		difficulty = 3,
		time = TICRATE*60*10,
		items = {{"silverring", 10}, {"snuffsoul", 5}, {"1up", 2}},
		subpersonas = {},
		music = "VSNQST",
		level = 18,
		waves = {
					{"relic_boss1"}
				},

	},

	{
		name = "Yabbashah Showdown",
		description = {"Fend off waves of enemies from", "the Yabbashah block to acquire points", "until time runs out!"},
		difficulty = 1,
		music = "VSNQST",
		time = TICRATE*60*5,
		items = {{"silverring", 99}, {"snuffsoul", 99}, {"1up", 99}},
		subpersonas = {},
		score = true,	-- Score attack
		level = 25,
		waves = {
					{
						"maya_3",
						"hand_2",
						"book_2",
						"hablerie_2",
					},

					{
						"sword_2",
						"beetle_2",
						"sword_2",
						"tiara_1",
					},

					{
						"book_2",
						"hand_2",
						"book_2",

					},

					{
						"maya_3",
						"knight_1",
						"maya_3",
					},

					{
						"tiara_2",
						"drive_1",
						"tiara_2",
					},

					{
						"mage_3",
						"turret_1",
						"mage_3",
					},

					{
						"maya_3",
						"mage_3",
						"tiara_2",
						"maya_3",
					},

					{
						"turret_1",
						"book_2",
						"gene_1",
					},

					{
						"sword_2",
						"mage_3",
						"sword_2",
					},

					{
						"hand_2",
						"maya_3",
						"maya_3",
						"hablerie_2",
					},

					{
						"turret_1",
						"turret_1",
						"book_2",
					},

					{
						"knight_1",
						"tiara_2",
						"tiara_2",
					},
				},
	},

	{
		name = "Macho Macho Man",
		description = "Defeat the Gigas of Anger once more",
		difficulty = 3,
		time = TICRATE*60*10,
		items = {{"silverring", 10}, {"snuffsoul", 5}, {"1up", 2}},
		subpersonas = {},
		music = "VSNQST",
		level = 26,
		waves = {
					{"gigas_boss1", "gigas_boss1", "gigas_boss1"}
				},

	},

	{
		name = "The Ice Queens",
		description = "Defeat the Magical Maguses once more",
		difficulty = 3,
		time = TICRATE*60*10,
		items = {{"silverring", 10}, {"snuffsoul", 5}, {"1up", 2}},
		subpersonas = {},
		music = "VSNQST",
		level = 30,
		waves = {
					{"magus_boss1", "magus_boss1", "magus_boss1"}
				},

	},

	{
		name = "I'm right you're wrong",
		description = "Defeat the Dogmatic Tower once more.",
		difficulty = 4,
		time = TICRATE*60*10,
		items = {{"silverring", 10}, {"snuffsoul", 5}, {"1up", 2}},
		subpersonas = {},
		music = "VSNQST",
		level = 36,
		waves = {
					{"tower_boss1"}
				},

	},

	{
		name = "Tziah Showdown",
		description = {"Fend off waves of enemies from", "the Tziah block to acquire points", "until time runs out!"},
		difficulty = 1,
		music = "VSNQST",
		time = TICRATE*60*5,
		items = {{"silverring", 99}, {"snuffsoul", 99}, {"1up", 99}},
		subpersonas = {},
		score = true,	-- Score attack
		level = 40,
		waves = {
					{
						"maya_tziah",
						"idol_tziah",
						"maya_tziah",
					},

					{
						"relic_tziah",
						"giant_tziah",
						"mother_tziah",
					},

					{
						"relic_tziah",
						"minotaur_tziah",
						"relic_tziah",
					},

					{
						"drive_tziah",
						"gigas_tziah",
						"gigas_tziah",
						"idol_tziah",
					},

					{
						"giant_tziah",
						"giant_tziah",
						"snake_tziah",
					},

					{
						"twins_tziah",
						"beetle_tziah",
						"twins_tziah",
					},

					{
						"pesce_tziah",
						"minotaur_tziah",
						"snake_tziah",
					},

					{
						"magus_tziah",
						"twins_tziah",
						"twins_tziah",
						"magus_tziah",
					},

					{
						"snake_tziah",
						"giant_tziah",
						"snake_tziah",
						"mother_tziah",
					},

					{
						"cyclops_tziah",
						"turret_tziah",
						"turret_tziah",
						"maya_tziah",
					},

					{
						"idol_tziah",
						"idol_tziah",
						"panzer_tziah",
					},

					{
						"gigas_tziah",
						"maya_tziah",
						"relic_tziah",
					},

					{
						"twins_tziah",
						"beast_tziah",
						"pesce_tziah",
					},

					{
						"machine_tziah",
						"mother_tziah",
					},
				},
	},

	{
		name = "Warriors from hell",
		description = "Defeat the Hell Knights once more.",
		difficulty = 4,
		time = TICRATE*60*10,
		items = {{"silverring", 10}, {"snuffsoul", 5}, {"1up", 2}},
		subpersonas = {},
		music = "VSNQST",
		level = 40,
		waves = {
					{"knight_boss1_tziah", "knight_boss1_tziah", "knight_boss1_tziah"}
				},

	},

	{
		name = "La Valse",
		description = "Defeat the Intrepid Dancer once more",
		difficulty = 4,
		time = TICRATE*60*10,
		items = {{"silverring", 10}, {"snuffsoul", 5}, {"1up", 2}},
		subpersonas = {},
		music = "VSNQST",
		level = 43,
		waves = {
					{"dancer_boss1_tziah"}
				},

	},

	{
		name = "Oath To Order",
		description = "Defeat the Oath Giants once more",
		difficulty = 4,
		time = TICRATE*60*10,
		items = {{"silverring", 10}, {"snuffsoul", 5}, {"1up", 2}},
		subpersonas = {},
		music = "VSNQST",
		level = 45,
		waves = {
					{"giant_boss1_tziah", "giant_boss1_tziah", "giant_boss1_tziah"}
				},

	},


	{
		name = "Fear the Sleeping Table!",
		description = "Defeat the Sleeping Table once more",
		difficulty = 4,
		time = TICRATE*60*15,
		items = {{"patra gem", 5}, {"magic mirror", 2}, {"1up", 2}, {"snuffsoul", 2}, {"homunculus", 5}},
		subpersonas = {},
		msusic = "VSNQST",
		level = 47,
		waves = {
					{"table_boss1_tziah"}
				},
	},

	{
		name = "Harabah Showdown",
		description = {"Fend off waves of enemies from", "the Harabah block to acquire points", "until time runs out!"},
		difficulty = 1,
		music = "VSNQST",
		time = TICRATE*60*5,
		items = {{"hyperring", 99}, {"snuffsoul", 99}, {"1up", 99}},
		subpersonas = {},
		score = true,	-- Score attack
		level = 57,
		waves = {
					{	"maya_harabah",
						"maya_harabah",
						"machine_harabah",
						"maya_harabah",
						"maya_harabah",
					},

					{	"knight_harabah",
						"knight_harabah",
						"knight_harabah",
					},

					{	"twins_harabah",
						"twins_harabah",
						"table_harabah",
						"okina_harabah",
					},

					{	"snake_harabah",
						"knight_harabah",
						"snake_harabah",
						"eagle_harabah",
					},

					{	"idol_harabah",
						"okina_harabah",
						"maya_harabah",
						"twins_harabah",
					},

					{	"cyclops_harabah",
						"maya_harabah"
					},

					{	"cyclops_harabah",
						"twins_harabah",
					},

					{	"tower_harabah",
						"drive_harabah",
						"tower_harabah",
						"table_harabah",
					},

					{	"knight_harabah",
						"knight_harabah",
						"idol_harabah",
						"okina_harabah",
					},

					{	"dice_harabah",
						"dice_harabah",
						"eagle_harabah",
						"table_harabah",
					},

					{	"idol_harabah",
						"idol_harabah",
						"okina_harabah",
						"dice_harabah",
					},

					{	"drive_harabah",
						"snake_harabah",
						"snake_harabah",
						"table_harabah",

					},
				},
	},

	{
		name = "Triple Caliburn",
		description = "Defeat the Judgement Swords once more",
		difficulty = 4,
		time = TICRATE*60*10,
		items = {{"hyperring", 5}, {"snuffsoul", 5}, {"1up", 2}},
		subpersonas = {},
		music = "VSNQST",
		level = 56,
		waves = {
					{"sword_boss1_harabah", "sword_boss1_harabah", "sword_boss1_harabah"}
				},

	},

	{
		name = "Master of Phantoms",
		description = "Defeat the Phantom Master once more",
		difficulty = 4,
		time = TICRATE*60*10,
		items = {{"hyperring", 5}, {"snuffsoul", 5}, {"1up", 2}},
		subpersonas = {},
		music = "VSNQST",
		level = 57,
		waves = {
					{"phantom_boss1_harabah"}
				},

	},

	{
		name = "Stasis Giants",
		description = "Defeat the Stasis Giants once more",
		difficulty = 4,
		time = TICRATE*60*10,
		items = {{"hyperring", 5}, {"snuffsoul", 5}, {"1up", 2}},
		subpersonas = {},
		music = "VSNQST",
		level = 58,
		waves = {
					{"giant_boss1_harabah", "giant_boss1_harabah", "giant_boss1_harabah"}
				},

	},

	{
		name = "Seductive Dance",
		description = "Defeat the Royal Dancers once more",
		difficulty = 4,
		time = TICRATE*60*10,
		items = {{"hyperring", 5}, {"snuffsoul", 5}, {"1up", 2}},
		subpersonas = {},
		music = "VSNQST",
		level = 59,
		waves = {
					{"dancer_boss1_harabah", "dancer_boss1_harabah", "dancer_boss1_harabah"}
				},

	},

	{
		name = "Diceroll",
		description = "Defeat the Recknoning Dice once more",
		difficulty = 5,
		time = TICRATE*60*10,
		items = {{"hyperring", 5}, {"snuffsoul", 5}, {"1up", 2}},
		subpersonas = {},
		music = "VSNQST",
		level = 60,
		waves = {
					{"dice_boss1_harabah"}
				},

	},

	{
		name = "Adamah Showdown",
		description = {"Fend off waves of enemies from", "the Adamah block to acquire points", "until time runs out!"},
		difficulty = 1,
		music = "VSNQST",
		time = TICRATE*60*5,
		items = {{"hyperring", 99}, {"snuffsoul", 99}, {"1up", 99}},
		subpersonas = {},
		score = true,	-- Score attack
		level = 70,
		waves = {
					{
						"idol_adamah",
						"nyogo_adamah",
						"idol_adamah",
					},

					{
						"giant_adamah",
						"turret_adamah",
						"turret_adamah",
						"twins_adamah",
					},

					{
						"balance_adamah",
						"giant_adamah",
						"balance_adamah",
					},

					{
						"gene_adamah",
						"knight_adamah",
						"gene_adamah",
					},

					{
						"castle_adamah",
						"turret_adamah",
						"turret_adamah",
						"castle_adamah",
					},

					{
						"minotaur_adamah",
						"dice_adamah",
						"minotaur_adamah",
					},

					{
						"dice_adamah",
						"dice_adamah",
						"nyogo_adamah",
						"dice_adamah",
						"dice_adamah",
					},

					{
						"giant_adamah",
						"giant_adamah",
						"giant_adamah",
					},

					{
						"snake_adamah",
						"phantom_adamah",
						"panzer_adamah",
						"phantom_adamah",
					},

					{
						"dice_adamah",
						"nyogo_adamah",
						"phantom_adamah",
						"dice_adamah",
					},

					{
						"sand_adamah",
						"beetle_adamah",
						"drive_adamah",
						"sand_adamah",
					},

					{
						"gene_adamah",
						"hand_adamah",
						"hand_adamah",
						"gene_adamah",
					},

					{
						"idol_adamah",
						"hand_adamah",
						"hand_adamah",
						"idol_adamah",
					},

					{
						"balance_adamah",
						"panzer_adamah",
						"balance_adamah",
					},
					
					{
						"pesce_adamah",
						"nyogo_adamah",
						"pesce_adamah",
					},

					{
						"gigas_adamah",
						"sand_adamah",
						"maya_adamah",
						"gigas_adamah",
					},

					{
						"idol_adamah",
						"idol_adamah",
						"minotaur_adamah",
						"idol_adamah",
					},

					{
						"idol_adamah",
						"hand_adamah",
						"maya_adamah",
						"idol_adamah",
					},

					{
						"minotaur_adamah",
						"minotaur_adamah",
					},

					{
						"snake_adamah",
						"panzer_adamah",
						"snake_adamah",
					},

					{
						"idol_adamah",
						"minotaur_adamah",
						"idol_adamah",
					},

					{
						"snake_adamah",
						"knight_adamah",
						"snake_adamah",
					},

					{
						"drive_adamah",
						"giant_adamah",
						"nyogo_adamah",
					},

					{
						"idol_adamah",
						"idol_adamah",
						"idol_adamah",
						"dice_adamah",
					},
				},
	},

	{
		name = "SEGA Eagles",
		description = "Defeat the Saturn Eagles once more",
		difficulty = 5,
		time = TICRATE*60*10,
		items = {{"hyperring", 5}, {"snuffsoul", 5}, {"1up", 2}},
		subpersonas = {},
		music = "VSNQST",
		level = 70,
		waves = {
					{"eagle_boss1_adamah", "eagle_boss1_adamah", "eagle_boss1_adamah"}
				},

	},

	{
		name = "Za Hando",
		description = "Defeat the Killing Hand once more",
		difficulty = 5,
		time = TICRATE*60*10,
		items = {{"hyperring", 5}, {"snuffsoul", 5}, {"1up", 2}},
		subpersonas = {},
		music = "VSNQST",
		level = 71,
		waves = {
					{"hand_boss1_adamah"}
				},

	},

	{
		name = "Purifying Blades",
		description = "Defeat the Final Swords once more",
		difficulty = 5,
		time = TICRATE*60*10,
		items = {{"hyperring", 5}, {"snuffsoul", 5}, {"1up", 2}},
		subpersonas = {},
		music = "VSNQST",
		level = 72,
		waves = {
					{"sword_boss1_adamah", "sword_boss1_adamah", "sword_boss1_adamah"}
				},

	},

	{
		name = "White Knights",
		description = "Defeat the Holy Knights once more",
		difficulty = 5,
		time = TICRATE*60*10,
		items = {{"hyperring", 5}, {"snuffsoul", 5}, {"1up", 2}},
		subpersonas = {},
		music = "VSNQST",
		level = 73,
		waves = {
					{"knight_boss1_adamah", "knight_boss1_adamah", "knight_boss1_adamah"}
				},

	},

	{
		name = "Natural Order",
		description = "Defeat the World Balance once more",
		difficulty = 5,
		time = TICRATE*60*15,
		items = {{"hyperring", 5}, {"snuffsoul", 5}, {"1up", 2}, {"homunculus", 4}, {"dekaja gem", 5}, {"dekunda gem", 5}},
		subpersonas = {},
		music = "VSNQST",
		level = 75,
		waves = {
					{"balance_boss1_adamah"}
				},

	},

	{
		name = "Reap the Reaper",
		description = "Defeat the most powerful Shadow!",
		difficulty = 7,
		time = TICRATE*60*30,
		music = "VSNQST",
		level = 80,
		items = {{"hyperring", 5}, {"snuffsoul", 5}, {"1up", 2}, {"patra gem", 3}, {"dekaja gem", 5}, {"dekunda gem", 5}},
		waves = {
					{"reaper_noboss"}
				},
	},

	{
		name = "Angel Beat Up",
		description = "Yes. This is my anime waifu.",
		difficulty = 7,
		time = TICRATE*60*15,
		music = "VSNQST",
		unlocks = {UNLOCK_ANGEL, "You can now play as Kanade"},
		required = 30,
		unlock = UNLOCK_C1,
		level = 50,
		waves = {
					{"angel"}
				},
	},

	{
		name = "To be seen by Shinji",
		description = "We'll see who's will is stronger!",
		difficulty = 7,
		time = TICRATE*60*40,
		music = "MBOSSB",
		required = 31,
		unlock = UNLOCK_C2,
		level = 85,
		items = {{"hyperring", 5}, {"snuffsoul", 5}, {"patra gem", 5}, {"dekaja gem", 5}, {"dekunda gem", 5}},
		waves = {
					{"humptihiko"}
				},
	},

	{
		name = "LORD AND SAVIOUR",
		description = "I have come for you, my children.",
		difficulty = 10,
		time = TICRATE*60*50,
		music = "BATKAN",
		required = 32,
		unlock = UNLOCK_C3,
		unlocks = {UNLOCK_CH_FINISHED},
		level = 99,
		superform = true,
		items = {{"dekaja gem", 20}, {"dekunda gem", 20}, {"patra gem", 5}, {"1up", 5}, {"super1up", 3}},
		waves = {
					{"batkan"}
				},
	},
	
})

rawset(_G, "MAXCHALLENGEBATTLES", (#BTL_challengebtllist))