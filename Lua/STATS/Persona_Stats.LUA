-- List of personas

-- NOTE: For normal Personas, their BASE STAT TOTAL should be 3*LEVEL + 9
-- Since all our stats are based on Level 10 (lowest level in the game), this means the base stat total should be 37


for i = 0, 9
	freeslot("SPR_PSN"..i)
end
freeslot("SPR_PSNB")
freeslot("SPR_PSNC")

freeslot("SPR_MTTR", "SPR_KFST", "SPR_ALCE", "SPR_PXIE")


freeslot("MT_BTL_PERSONA")
mobjinfo[MT_BTL_PERSONA] = {
	doomednum = -1,
	spawnhealth = 1000,
	radius = 32<<FRACBITS,
	height = 32<<FRACBITS,
	spawnstate = S_INVISIBLE,
	flags = MF_NOBLOCKMAP|MF_NOGRAVITY,
}

local hacklist = {
{"agidyne",1},
{"bufudyne",1},
{"garudyne",1},
{"ziodyne",1},
{"psiodyne",1},
{"freidyne",1},
}

rawset(_G, "personaList", {
	
	["story_00"] = {
		name = "Sonic",
		arcana = ARCANA_FOOL,
		
		sprite = SPR_NULL,
		anim_idle = 	{SPR_NULL, A, 1},
		anim_atk = 		{SPR_NULL, A, 1},
		
		strength = 7,
		magic = 10,
		endurance = 6,
		luck = 4,
		agility = 12,
		
		skills = {}
	},
	
	["story_01"] = {
		name = "???",
		arcana = ARCANA_DEATH,

		sprite = SPR_PSN9,
		anim_idle = 	{SPR_PSN9, A, B, 16},
		anim_atk = 		{SPR_PSN9, C, D, D, D, D, D, D, D, D, D, E, F, F, F, F, F, F, F, G, H, G, H, G, H, G, H, G, H, G, H, G, H, G, H, G, H, G, H, G, H, G, H, G, H, 2},

		strength = 25,
		magic = 25,
		endurance = 20,
		luck = 20,
		agility = 15,

		skills = {{"eigaon", 1}, {"brave blade", 1}, {"megidola", 1}, {"curse amp", 1}}
	},

	["orpheus"] = {
		-- GENERAL
		name = "Orpheus",
		arcana = ARCANA_FOOL,

		-- STATS (at level 10. so we can have some precision, y'see)

		sprite = SPR_PSN0,
		anim_idle = 	{SPR_PSN0, A, B, C, B, 8},
		anim_atk = 		{SPR_PSN0, D, E, F, G, H, H, H, I, J, K, L, L, L, L, L, L, 2},
		startframe = 0,

		strength = 7,
		magic = 10,
		endurance = 6,
		luck = 4,
		agility = 12,
		weak = ATK_PSY,
		resist = ATK_FIRE,
		skills = {
					{"agi", 1}, {"lunge", 3}, {"flame link", 7},
					{"sukukaja", 12}, {"maragi", 15},

					{"sonic punch", 18, "lunge"}, {"agilao", 21, "agi"},
					{"assault dive", 25, "sonic punch"}, {"double link", 28},
					{"fire boost", 33}, {"maragion", 37, "maragi"},
					{"triple link", 41, "double link"},
					{"masukukaja", 45, "sukukaja"}, {"gigantic fist", 48, "assault dive"},
					{"agidyne", 52, "agilao"}, {"quadruple link", 57, "triple link"},
					{"maragidyne", 63, "maragion"}, {"fire amp", 67},
					{"infinite link", 75, "quadruple link"}, {"trisagion", 85, "agidyne"},
				},
	},

	["samael"] = {
		-- GENERAL
		name = "Samael",
		arcana = ARCANA_DEATH,

		-- STATS (at level 10. so we can have some precision, y'see)

		sprite = SPR_PSNB,
		anim_idle = 	{SPR_PSNB, A, B, 10},
		anim_atk = 		{SPR_PSNB, C, D, D, D, D, D, E, F, G, G, G, G, G, 3},
		startframe = 0,

		strength = 4,
		magic = 10,
		endurance = 7,
		luck = 12,
		agility = 6,
		weak = ATK_BLESS,
		resist = ATK_CURSE,
		skills = {
					{"eiha", 1}, {"mudo", 4},
					{"rakunda", 10}, {"maeiha", 15},
					{"life drain", 19}, {"eiga", 23},
					{"backup trick", 26}, {"curse boost", 33},
					{"maeiga", 36, "eiha"}, {"marakunda", 40, "rakunda"},
					{"mudoon", 43, "mudo"}, {"life leech", 47, "life drain"},
					{"tetraja", 51, "maeiha"}, {"eigaon", 54, "eiga"},
					{"life siphon", 59, "life leech"}, {"curse amp", 65, "curse boost"},
					{"maeigaon", 71, "maeiga"}
				},

		--skills = hacklist,
	},

	["omoikane"] = {
		-- GENERAL
		name = "Omoikane",
		arcana = ARCANA_HIEROPHANT,

		-- STATS (at level 10. so we can have some precision, y'see)

		sprite = SPR_PSNC,
		anim_idle = 	{SPR_PSNC, A, B, C, B, 8},
		anim_atk = 		{SPR_PSNC, D, E, F, F, F, F, G, H, H, H, H, H, H, H, H, H, 2},
		startframe = 0,

		strength = 4,
		magic = 12,
		endurance = 6,
		luck = 7,
		agility = 10,
		weak = ATK_NUCLEAR,
		resist = ATK_PSY,
		skills = {
					{"psi", 1}, {"makakaja", 5},
					{"mapsi", 14}, {"psy break", 18},
					{"psio", 20}, {"spirit drain", 23},
					{"makarakarn", 26}, {"psy boost", 30},
					{"mapsio", 34, "psi"}, {"mamakakaja", 38, "makakaja"},
					{"spirit leech", 42, "spirit drain"}, {"mind charge", 46, "mapsi"},
					{"psiodyne", 52, "psio"}, {"psy amp", 62, "psy boost"}, {"mapsiodyne", 68, "mapsio"},
					{"psycho force", 77, "psiodyne"}
				},

		--skills = hacklist,
	},

	["penthesilea"] = {
		-- GENERAL
		name = "Penthesilea",
		arcana = ARCANA_LOVERS,

		-- STATS (@ lv10)

		sprite = SPR_PSN6,
		anim_idle = 	{SPR_PSN6, A, B, 16},
		anim_atk = 		{SPR_PSN6, C, D, E, F, G, H, I, J, J, J, J, J, J, J, J, J, J, J, 3},
		startframe = 0,

		strength = 4,
		magic = 11,
		endurance = 6,
		luck = 10,
		agility = 8,
		weak = ATK_FIRE,
		resist = ATK_ICE|ATK_SLASH,
		skills = {
					{"bufu", 1}, {"dia", 4},
					{"cleave", 8}, {"pulinpa", 11},
					{"mabufu", 15}, {"bufula", 19},
					{"diarama", 23}, {"giant slice", 26},
					{"impure reach", 30, "bufu"},

					{"mabufula", 34, "dia"}, {"merciless slayer", 37, "cleave"},
					{"tentarafoo", 41, "pulinpa"}, {"ice boost", 45, "mabufu"},
					{"bufudyne", 52, "bufula"}, {"fatal end", 56, "giant slice"},
					{"diarahan", 58, "diarama"}, {"ice amp", 64, "ice boost"},
					{"mabufudyne", 67, "mabufula"}, {"niflheim", 75, "bufudyne"},
				},
	},

	["io"] = {
		-- GENERAL
		name = "Io",
		arcana = ARCANA_LOVERS,

		-- STATS (@ lv10)

		sprite = SPR_PSN5,
		anim_idle = 	{SPR_PSN5, A, H, I, J, K, 8},
		anim_atk = 		{SPR_PSN5, B, C, D, E, F, G, G, G, G, G, G, G, G, G, G, 3},
		startframe = 0,

		strength = 4,
		magic = 12,
		endurance = 6,
		luck = 10,
		agility = 7,
		weak = ATK_ELEC,
		resist = ATK_WIND|ATK_BLESS,
		skills = {
					{"dia", 1}, {"garu", 4},
					{"media", 14}, {"patra", 15},
					{"magaru", 16}, {"diarama", 19},
					{"garula", 21}, {"recarm", 25},

					{"me patra", 28, "dia"}, {"magarula", 34, "garu"},
					{"garuverse", 37, "magaru"}, {"wind boost", 40, "patra"},
					{"mediarama", 45, "media"},	{"samarecarm", 49, "recarm"},
					{"garudyne", 52, "garula"}, {"diarahan", 57, "diarama"},
					{"wind amp", 62, "wind boost"}, {"mediarahan", 66, "mediarama"},
					{"magarudyne", 70, "magarula"}, {"panta rhei", 81, "garudyne"}
				},
	},

	["palladion"] = {
		-- GENERAL
		name = "Palladion",
		arcana = ARCANA_CHARIOT,

		-- STATS (at level 10. so we can have some precision, y'see)

		sprite = SPR_PSN0,
		anim_idle = 	{SPR_PSN4, A, B, C, D, E, F, 8},
		anim_atk = 		{SPR_PSN4, G, H, I, J, J, J, J, J, J, 3},
		startframe = 0,

		strength = 9,
		magic = 7,
		endurance = 12,
		luck = 4,
		agility = 7,
		weak = ATK_ELEC,
		resist = ATK_STRIKE|ATK_NUCLEAR,
		skills = {
					{"snap", 1}, {"frei", 4},
					{"tarukaja", 11}, {"dekunda", 15},
					{"mafrei", 18}, {"assault shot", 22},
					{"freila", 26}, {"swordbreaker", 30},

					{"mafreila", 34, "snap"}, {"matarukaja", 38, "tarukaja"},
					{"heat wave", 42, "frei"}, {"power charge", 45, "mafrei"},
					{"heavy shot", 53, "assault shot"}, {"freidyne", 57, "freila"},
					{"vicious strike", 62, "heat wave"}, {"mafreidyne", 67, "mafreila"},
					{"pralaya", 75, "heavy shot"}, {"akasha arts", 85, "vicious strike"},



					/*{"frei", 1}, {"snap", 4},
					{"sukukaja", 8}, {"tarukaja", 12},
					{"dekunda", 15}, {"kill rush", 17},
					{"assault dive", 22}, {"rakukaja", 25},

					{"freila", 28, "snap"}, {"masukukaja", 32, "frei"},
					{"marakukaja", 35, "sukukaja"}, {"matarukaja", 38, "tarukaja"},
					{"heat wave", 42, "rakukaja"},
					{"power charge", 46, "assault dive"},
					{"gigantic fist", 53, "kill rush"},
					{"vicious strike", 57, "heat wave"},
					{"freidyne", 62, "freila"},
					{"god hand", 68, "gigantic fist"},
					{"akasha arts", 72, "vicious strike"},*/
				},
		--skills = hacklist,
	},

	["hermes"] = {
		-- GENERAL
		name = "Hermes",
		arcana = ARCANA_MAGICIAN,

		-- STATS (at level 10. so we can have some precision, y'see)

		sprite = SPR_PSN0,
		anim_idle = 	{SPR_PSN3, A, B, C, D, E, F, 8},
		anim_atk = 		{SPR_PSN3, G, G, H, H, H, H, H, H, H, G, A, D, D, D, D, D, D, D, D, D, D, 2},
		startframe = 0,

		strength = 10,
		magic = 7,
		endurance = 6,
		luck = 4,
		agility = 12,
		weak = ATK_WIND,
		resist = ATK_FIRE|ATK_SLASH,
		skills = {
					{"agi", 1}, {"cleave", 4},
					{"rakukaja", 12}, {"counter", 16},
					{"giant slice", 21},  {"agilao", 25},
					{"perfect keeper 1", 28}, {"gale slash", 32},

					{"marakukaja", 35, "cleave"}, {"torrent shot", 39, "agi"},
					{"regenerate 1", 42, "rakukaja"}, {"counterstrike", 45, "counter"},

					{"blade of fury", 49, "gale slash"}, {"fatal end", 53, "giant slice"},
					{"perfect keeper 2", 56, "perfect keeper 1"},
					{"regenerate 2", 59, "regenerate 1"}, {"agidyne", 62, "agilao"},
					{"high counter", 65, "counterstrike"}, {"deathbound", 68, "blade of fury"},
					{"regenerate 3", 72, "regenerate 2"}, {"brave blade", 77, "fatal end"},
			},
		--skills = hacklist,
	},

	["polydeuces"] = {
		-- GENERAL
		name = "Polydeuces",
		arcana = ARCANA_EMPEROR,

		-- STATS (at level 10. so we can have some precision, y'see)

		strength = 12,
		magic = 6,
		endurance = 10,
		luck = 4,
		agility = 8,
		weak = ATK_ICE,
		resist = ATK_ELEC,

		sprite = SPR_PSN2,
		anim_idle = {SPR_PSN2, A, B, C, 8},
		anim_atk = 	{SPR_PSN2, D, E, F, G, H, H, H, H, I, J, J, J, J, J, J, 2},

		skills = {

			{"lunge", 1}, {"zio", 4},
			{"dia", 9}, {"tarunda", 14},
			{"dekaja", 18}, {"assault dive", 23},
			{"teardrop", 27},  {"zionga", 31},

			{"hard knuckle", 35, "lunge"}, {"diarama", 39, "dia"},
			{"matarunda", 46, "zio"}, {"moondrop", 49, "teardrop"},
			{"gigantic fist", 53, "tarunda"}, {"ziodyne", 57, "assault dive"},
			{"iron fist", 61, "zionga"}, {"stardrop", 65, "moondrop"},
			{"diarahan", 69, "diarama"}, {"megaton raid", 75, "gigantic fist"}
		},
	},

	["nemesis"] = {
		-- GENERAL
		name = "Nemesis",
		arcana = ARCANA_JUSTICE,

		-- STATS (at level 10. so we can have some precision, y'see)

		sprite = SPR_PSN1,
		anim_idle = {SPR_PSN1, A, B, 6},
		anim_atk = 	{SPR_PSN1, C, D, E, E, E, E, E, F, G, H, H, H, H, H, 3},

		strength = 5,
		magic = 10,
		endurance = 6,
		luck = 12,
		agility = 6,
		weak = ATK_CURSE,
		resist = ATK_BLESS|ATK_PSY,
		skills = {
						{"kouha", 1}, {"dia", 4},
						{"hama", 9}, {"media", 14},
						{"psi", 16}, {"makouha", 18},
						{"kouga", 20}, {"makanda", 22},

						{"diarama", 23, "dia"}, {"psio", 26, "psi"},
						{"cruel attack", 28, "kouha"}, {"makouga", 32, "makouha"},
						{"hamaon", 35, "hama"},  {"mamakanda", 38, "makanda"},
						{"mediarama", 42, "media"}, {"vile assault", 46, "cruel attack"},
						{"kougaon", 52, "kouga"}, {"diarahan", 62, "diarama"},
						{"psiodyne", 66, "psio"}, {"makougaon", 69, "makouga"},
						{"mediarahan", 72, "mediarama"},
				},
		--skills = hacklist,
	},

	["orpheus_tutorial"] = {
		-- GENERAL
		name = "Orpheus",
		arcana = ARCANA_FOOL,

		-- STATS (at level 10. so we can have some precision, y'see)

		sprite = SPR_PSN0,
		anim_idle = 	{SPR_PSN0, A, B, C, B, 8},
		anim_atk = 		{SPR_PSN0, D, E, F, G, H, H, H, I, J, K, L, L, L, L, L, L, 2},
		startframe = 0,

		strength = 7,
		magic = 10,
		endurance = 6,
		luck = 4,
		agility = 12,
		weak = ATK_CURSE,
		resist = ATK_FIRE,
		skills = {
					{"agi", 1},
				},
	},

	["none_kanade"] = {
		-- GENERAL
		name = "None",			-- Name of the Persona
		arcana = nil,			-- Arcana (unused in Beta 1.0.0, can be left nil as well)

		sprite = SPR_PSN0,
		startframe = 0,

		anim_idle = 	{SPR_NULL, A},
		anim_atk = 		{SPR_NULL, A},

		-- Stats (at level 10)
		strength = 12,
		magic = 5,
		endurance = 7,
		luck = 6,
		agility = 10,

		weak = ATK_CURSE,
		resist = ATK_SLASH|ATK_BLESS,
		block = ATK_PIERCE,

		skills = {
					{"cleave", 1}, {"skewer", 5},
					{"counter", 12}, {"toxic slice", 16},
					{"twin slash", 20}, {"cruel attack", 24},
					{"sharp edge", 27}, {"gale slash", 31},

					{"counterstrike", 34, "counter"},
					{"distortion", 40, "cleave"},
					{"virus cutter", 43, "toxic slice"},
					{"fatal end", 46, "skewer"},
					{"howling", 50, "twin slash"},

					{"blade of fury", 54, "gale slash"},
					{"vile assault", 56, "cruel attack"},
					{"diamondcutter", 59, "sharp edge"},
					{"delay", 64, "counterstrike"},
					{"deathbound", 69, "blade of fury"},

					{"brave blade", 73, "fatal end"},
					{"tempest slash", 85, "brave blade"},
				},
	},

	["alice_alt"] = {
		-- GENERAL
		name = "Alice",
		arcana = ARCANA_DEATH,

		-- STATS (at level 10. so we can have some precision, y'see)

		sprite = SPR_ALCE,
		anim_idle = 	{SPR_ALCE, A, B, 8},
		anim_atk = 		{SPR_ALCE, C, D, D, D, D, E, F, G, H, I, J, J, K, K, K, K, K, K, K, K, K, 3},
		startframe = 0,

		strength = 10,
		magic = 10,
		endurance = 10,
		luck = 10,
		agility = 10,
		weak = ATK_BLESS|ATK_NUCLEAR,
		resist = ATK_PSY,
		drain = ATK_CURSE,
	},

	["pixie_alt"] = {
		-- GENERAL
		name = "Pixie",
		arcana = ARCANA_LOVERS,

		-- STATS (at level 10. so we can have some precision, y'see)

		sprite = SPR_ALCE,
		anim_idle = 	{SPR_PXIE, A, B, 4},
		anim_atk = 		{SPR_PXIE, C, C, C, C, D, E, E, E, E, E, E, E, E, E, E, 3},
		startframe = 0,

		strength = 10,
		magic = 10,
		endurance = 10,
		luck = 10,
		agility = 10,
		weak = ATK_CURSE|ATK_PIERCE,
		resist = ATK_WIND,
		drain = ATK_ELEC,
	},

	["metatron_alt"] = {
		-- GENERAL
		name = "Metatron",
		arcana = ARCANA_JUDGEMENT,

		-- STATS (at level 10. so we can have some precision, y'see)

		sprite = SPR_ALCE,
		anim_idle = 	{SPR_MTTR, A, B, 4},
		anim_atk = 		{SPR_MTTR, C, C, D, D, D, D, D, D, D, D, D, D, D, D, 3},
		startframe = 0,

		strength = 10,
		magic = 10,
		endurance = 10,
		luck = 10,
		agility = 10,
		weak = ATK_WIND|ATK_ICE,
		resist = ATK_FIRE|ATK_STRIKE|ATK_SLASH|ATK_PIERCE,
		drain = ATK_BLESS,
	},

	["kfrost_alt"] = {
		-- GENERAL
		name = "King Frost",
		arcana = ARCANA_EMPEROR,

		-- STATS (at level 10. so we can have some precision, y'see)

		sprite = SPR_ALCE,
		anim_idle = 	{SPR_KFST, A, B, 4},
		anim_atk = 		{SPR_KFST, C, D, C, D, C, D, E, E, E, E, E, E, E, 3},
		startframe = 0,

		strength = 10,
		magic = 10,
		endurance = 10,
		luck = 10,
		agility = 10,
		weak = ATK_FIRE|ATK_ELEC,
		resist = ATK_NUCLEAR,
		drain = ATK_ICE,
	},

	["unequipped"] = {
		-- GENERAL
		name = "Unequipped",
		arcana = 0,

		-- STATS (at level 10. so we can have some precision, y'see)

		sprite = SPR_PSN0,
		anim_idle = 	{SPR_NULL, A, 1},
		anim_atk = 		{SPR_NULL, A, 1},
		startframe = 0,

		strength = 7,
		magic = 7,
		endurance = 7,
		luck = 7,
		agility = 7,
		skills = {},
	},

}
)

rawset(_G, "sorted_personaList", {})

for k,v in pairs(personaList)
	sorted_personaList[#sorted_personaList+1] = k
end
table.sort(sorted_personaList, function(a, b)
						local t = personaList
						return (t[a].arcana or 0) < (t[b].arcana or 0)
				end)
