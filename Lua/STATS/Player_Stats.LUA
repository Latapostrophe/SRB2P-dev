-- Stats for characters

rawset(_G, "charStats", {

	["sonic"] = {

		-- GENERAL

		name = "Sonic",			-- This is only for bots / enemies
		basehp = 60,			-- base HP for level 1
		basesp = 35,
		persona = "orpheus",
		melee_natk = "sonic_atk1",	-- normal melee attack
		--melee_satk = "ssonic_atk1",	-- normal melee attack when super

		wep = "shoes_01",		-- default weapon.
		weptype = WPT_SHOES,	-- Equippable weapon type(s)

		atk = 30,	-- attack power of physical attacks
		acc = 85,	-- accuracy of physical attacks
		crit = 5,

		supercolor_start = SKINCOLOR_SUPERGOLD1,	-- if super form is applicable: will use this flash

		-- ANIMS
		-- Anims are built like this:
		-- {SPR_SPRITE, frame1, frame2, frame3, ... , duration between each frame, <"spr2">}
		-- spr2 is optional and must be between quotes, this is to avoid compability issues with older animations

		anim_stand = 		{SPR_PLAY, A, 8, "SPR2_STND"},		-- standing
		anim_stand_hurt =	{SPR_PLAY, A, 1, "SPR2_STND"},		-- standing (low HP)
		anim_stand_bored =	{SPR_PLAY, A, B, A, B, A, B, A, B, 10, "SPR2_WAIT"},	-- standing (rare anim)
		anim_guard = 		{SPR_PLAY, A, 1, "SPR2_WALK"},		-- guarding
		anim_move =			{SPR_PLAY, A, B, C, D, E, F, G, H, 2, "SPR2_WALK"},		-- moving
		anim_run =			{SPR_PLAY, A, B, C, D, 2, "SPR2_RUN_"},	-- guess what
		anim_atk =			{SPR_PLAY, A, B, C, D, E, F, 1, "SPR2_ROLL"},	-- attacking
		anim_aoa_end =		{SPR_PLAY, F, E, D, C, B, A, 1, "SPR2_ROLL"},	-- jumping out of all-out attack
		anim_hurt =			{SPR_PLAY, A, 35, "SPR2_PAIN"},		-- taking damage
		anim_getdown =		{SPR_PLAY, A, 1, "SPR2_PAIN"},		-- knocked down from weakness / crit
		anim_downloop =		{SPR_PLAY, A, 1, "SPR2_SHIT"},		-- is down
		anim_getup =		{SPR_PLAY, A, B, C, D, 1, "SPR2_ROLL"},		-- gets up from down
		anim_death =		{SPR_PLAY, A, 30, "SPR2_PAIN"},		-- dies
		anim_revive =		{SPR_PLAY, A, B, C, D, E, F, 1, "SPR2_ROLL"},		-- gets revived
		anim_evoker =		{SPR_PLAY, A, 2, "SPR2_CSMN"},	-- uses evoker
		anim_evoker_shoot = {SPR_PLAY, B, A, 2, "SPR2_CSMN"},

		anim_stand_super = 	{SPR_PLAY, A, B, C, D, 4, "SPR2_STND"},		-- standing
		anim_stand_hurt_super = 	{SPR_PLAY, A, B, C, D, 4, "SPR2_STND"},		-- standing
		anim_stand_bored_super = 	{SPR_PLAY, A, B, C, D, 4, "SPR2_STND"},		-- standing
		anim_run_super = 	{SPR_PLAY, A, B, 2, "SPR2_RUN_"},	-- run
		anim_evoker_super = 	{SPR_PLAY, A, B, C, D, 4, "SPR2_STND"},
		anim_evoker_shoot_super = 	{SPR_PLAY, A, B, C, D, 4, "SPR2_STND"},

		anim_special1 = {SPR_PLAY, A, B, C, D, 2, "SPR2_SPIN"}, -- spindash (revving up)
		anim_special2 = {SPR_PLAY, A, B, C, D, 1, "SPR2_SPIN"}, -- spindash (faster, revved up)

		-- VOICES
		-- Follow this template.
		-- All sounds in there will be *automatically* freeslotted.
		-- For custom characters, call VFX_freeslotC("skinname") OUT OF A THINKFRAME (!)
		-- See Player_Defs.LUA

		vfx_summon = {"sfx_sosum1", "sfx_sosum2", "sfx_sosum3", "sfx_sosum4", "sfx_sosum5"},
		vfx_skill = {"sfx_soskl1", "sfx_soskl2"},
		vfx_item = {"sfx_souse1"},
		vfx_hurt = {"sfx_sohrt1"},
		vfx_hurtx = {"sfx_sohtx1", "sfx_sohtx2"},
		vfx_die = {"sfx_sodie1"},
		vfx_killconfirm = {"sfx_soskl1", "sfx_soskl2"},
		vfx_heal = {"sfx_sohel1", "sfx_sohel2", "sfx_sohel3"},
		vfx_healself = {"sfx_sohel1", "sfx_sohel2", "sfx_sohel3"},
		vfx_kill = {"sfx_sokll1", "sfx_sokll2", "sfx_sokll3", "sfx_sokll4"},
		vfx_1more = {"sfx_so1mr1", "sfx_so1mr2"},
		vfx_crit = {"sfx_socrt1"},
		vfx_aoaask = {"sfx_soaoi1", "sfx_soaoi2", "sfx_soaoi3", "sfx_soaoi4"},
		vfx_aoado = {"sfx_soaoa1", "sfx_soaoa2", "sfx_soaoa3", "sfx_soaoa4"},
		vfx_aoarelent = {"sfx_somis2", "sfx_somis3"},
		vfx_miss = {"sfx_somis1", "sfx_somis2", "sfx_somis3"},
		vfx_dodge = {"sfx_sodge1"},
		vfx_win = {"sfx_sowin1", "sfx_sowin2", "sfx_sowin3", "sfx_sowin4"},
		vfx_levelup = {"sfx_solvl1", "sfx_socrt1", "sfx_sohel2", "sfx_sokll1"},


		icon = "ICO_SONI",	-- icon for net select and other menus
		hudbust = "SONIC_H",			-- patch to draw on the stat hud
		hudaoa = "H_SONAOA",	-- patch for all out attack hud
		hudsbust = "SSONIC_H",
		hudsaoa = "H_SSONAO",	-- same but for supers
		hudcutin = "SONIC_A",	-- cut in
		aoa_quote = "Let's get this\nparty started!",

		tip = "An agile attacker with Fire, Strike and Agility buffs. His link skill can build up a lot of additional damage on tough foes, but his magic attacks are much stronger. Mind your SP and Baton Pass to conserve it.",
	},

	["silver"] = {

		-- GENERAL

		name = "Silver",			-- This is only for bots / enemies
		basehp = 45,			-- base HP for level 1
		basesp = 50,
		persona = "omoikane",
		melee_natk = "silver_atk1",	-- normal melee attack

		supercolor_start = SKINCOLOR_SUPERTAN1,

		wep = "psygloves_01",
		weptype = WPT_PSYGLOVES,

		atk = 25,
		acc = 999,
		crit = 3,

		-- ANIMS
		-- Anims are built like this:
		-- {SPR_SPRITE, frame1, frame2, frame3, ... , duration between each frame}

		anim_stand = 		{SPR_PLAY, A, 8, "SPR2_STND"},		-- standing
		anim_stand_hurt =	{SPR_PLAY, A, 1, "SPR2_STND"},		-- standing (low HP)
		anim_stand_bored =	{SPR_PLAY, A, A, 30, "SPR2_WAIT"},	-- standing (rare anim)
		anim_guard = 		{SPR_PLAY, A, 1, "SPR2_WALK"},		-- guarding
		anim_move =			{SPR_PLAY, A, B, C, D, E, F, G, H, 2, "SPR2_WALK"},		-- moving
		anim_run =			{SPR_PLAY, A, B, C, D, E, F, G, H, 2, "SPR2_WALK"},
		anim_atk =			{SPR_PLAY, A, B, C, D, E, F, 1, "SPR2_ROLL"},	-- attacking
		anim_aoa_end =		{SPR_PLAY, F, E, D, C, B, A, 1, "SPR2_ROLL"},	-- jumping out of all-out attack
		anim_hurt =			{SPR_PLAY, A, 35, "SPR2_PAIN"},		-- taking damage
		anim_getdown =		{SPR_PLAY, A, 1, "SPR2_PAIN"},		-- knocked down from weakness / crit
		anim_downloop =		{SPR_PLAY, A, 1, "SPR2_CNT1"},		-- is down
		anim_getup =		{SPR_PLAY, A, B, C, D, 1, "SPR2_ROLL"},		-- gets up from down
		anim_death =		{SPR_PLAY, A, 30, "SPR2_PAIN"},		-- dies
		anim_revive =		{SPR_PLAY, A, B, C, D, E, F, 1, "SPR2_ROLL"},		-- gets revived
		anim_evoker =		{SPR_PLAY, A, 2, "SPR2_CSMN"},	-- uses evoker
		anim_evoker_shoot = {SPR_PLAY, B, A, 2, "SPR2_CSMN"},

		anim_stand_hurt_super = 	{SPR_PLAY, A, B, C, D, 4, "SPR2_STND"},		-- standing
		anim_stand_bored_super = 	{SPR_PLAY, A, B, C, D, 4, "SPR2_STND"},		-- standing
		anim_run_super = 	{SPR_PLAY, A, B, 2, "SPR2_RUN_"},	-- run
		anim_evoker_super = 	{SPR_PLAY, A, B, C, D, 4, "SPR2_STND"},
		anim_evoker_shoot_super = 	{SPR_PLAY, A, B, C, D, 4, "SPR2_STND"},

		anim_special1 = {SPR_MRSP, A, B, C, D, 2}, -- spindash (revving up)
		anim_special2 = {SPR_MRSP, A, B, C, D, 1}, -- spindash (faster, revved up)

		vfx_summon = {"sfx_sisum1", "sfx_sisum2", "sfx_sisum3", "sfx_sisum4", "sfx_sisum5"},
		vfx_skill = {"sfx_siskl1", "sfx_siskl2", "sfx_siskl3"},
		vfx_item = {"sfx_siskl3"},
		vfx_hurt = {"sfx_sihrt1"},
		vfx_hurtx = {"sfx_sidie1"},
		vfx_die = {"sfx_sidie1"},
		vfx_heal = {"sfx_sikll3"},
		vfx_healself = {"sfx_sikll3"},
		vfx_kill = {"sfx_sikll1", "sfx_sikll2", "sfx_sikll3", "sfx_sikll4"},
		vfx_1more = {"sfx_si1mr1", "sfx_si1mr2"},
		vfx_crit = {"sfx_sicrt1", "sfx_sicrt2"},
		vfx_aoaask = {"sfx_siaoi1"},
		vfx_aoado = {"sfx_siaoa1", "sfx_siaoa2", "sfx_siaoa3"},
		vfx_aoarelent = {"sfx_simis2"},
		vfx_miss = {"sfx_simis1", "sfx_simis2", "sfx_simis3"},
		vfx_dodge = {"sfx_siaoi2", "sfx_sidge1", "sfx_sikll4"},
		vfx_win = {"sfx_siwin1", "sfx_siwin2"},
		vfx_levelup = {"sfx_sikll3"},

		icon = "ICO_SILV",	-- icon for net select and other menus
		hudbust = "SIL_H",			-- patch to draw on the stat hud
		hudbustlayer = "",		-- transparent patch to draw for status conditions
		hudaoa = "H_SILAOA",	-- patch for all out attack hud
		hudcutin = "SILV_A",	-- cut in
		hudspr = "SILV",	-- sprite prefix since hud can't retrieve it. yikes
		aoa_quote = "It's no use!",

		tip = "A glass cannon with low HP and Endurance, but exceptional power and essentially unlimited SP. Use his Magic buffs to benefit attack and healing alike, and his magic barriers to potentially save teammates in need!",
	},

	["eggman"] = {

		-- GENERAL

		name = "Eggman",			-- This is only for bots / enemies
		basehp = 50,			-- base HP for level 1
		basesp = 45,
		persona = "samael",
		melee_natk = "eggman_atk1",	-- normal melee attack

		atk = 27,
		acc = 85,
		crit = 3,

		wep = "device_01",
		weptype = WPT_REMOTE,

		supercolor_start = SKINCOLOR_SUPERGOLD1,

		-- ANIMS
		-- Anims are built like this:
		-- {SPR_SPRITE, frame1, frame2, frame3, ... , duration between each frame}

		anim_stand = 		{SPR_PLAY, A, 8, "SPR2_STND"},		-- standing
		anim_stand_hurt =	{SPR_PLAY, A, 1, "SPR2_STND"},		-- standing (low HP)
		anim_stand_bored =	{SPR_PLAY, A, B, A, B, A, B, A, B, 10, "SPR2_WAIT"},	-- standing (rare anim)
		anim_guard = 		{SPR_PLAY, A, 1, "SPR2_WALK"},		-- guarding
		anim_move =			{SPR_PLAY, A, B, C, D, E, F, G, H, 2, "SPR2_WALK"},		-- moving
		anim_run =			{SPR_PLAY, A, B, C, D, 2, "SPR2_RUN_"},	-- guess what
		anim_atk =			{SPR_PLAY, A, B, C, D, 1, "SPR2_RUN_"},	-- attacking
		anim_aoa_end =		{SPR_PLAY, D, C, B, A, 1, "SPR2_ROLL"},	-- jumping out of all-out attack
		anim_hurt =			{SPR_PLAY, A, 35, "SPR2_PAIN"},		-- taking damage
		anim_getdown =		{SPR_PLAY, A, 1, "SPR2_PAIN"},		-- knocked down from weakness / crit
		anim_downloop =		{SPR_PLAY, A, 1, "SPR2_CNT1"},		-- is down
		anim_getup =		{SPR_PLAY, A, B, C, D, 1, "SPR2_RUN_"},		-- gets up from down
		anim_death =		{SPR_PLAY, A, 30, "SPR2_PAIN"},		-- dies
		anim_revive =		{SPR_PLAY, A, B, C, D, 1, "SPR2_RUN_"},		-- gets revived
		--anim_evoker =		{SPR_CSMN, A, B, 2},	-- holding evoker to head
		--anim_evoker_shoot =	{SPR_CSMN, C, 2},		-- shooting evoker

		anim_evoker = 		{SPR_PLAY, A, 8},
		anim_evoker_shoot = 		{SPR_PLAY, A, 8},

		anim_stand_super = 		{SPR_PLAY, A, B, C, B, 4, "SPR2_STND"},
		anim_stand_bored_super = 		{SPR_PLAY, A, B, C, B, 4, "SPR2_STND"},
		anim_stand_hurt_super = 		{SPR_PLAY, A, B, C, B, 4, "SPR2_STND"},

		anim_move_super = 		{SPR_PLAY, A, B, C, B, 4, "SPR2_WALK"},
		anim_run_super = 		{SPR_PLAY, A, B, C, D, E, F, 4, "SPR2_FLY_"},

		anim_special1 = {SPR_MRSP, A, B, C, D, 2}, -- spindash (revving up)
		anim_special2 = {SPR_MRSP, A, B, C, D, 1}, -- spindash (faster, revved up)

		vfx_summon = {"sfx_egsum1", "sfx_egsum2", "sfx_egsum3"},
		vfx_skill = {"sfx_egskl1", "sfx_egskl2", "sfx_egskl3"},
		vfx_item = {"sfx_egskl2"},
		vfx_hurt = {"sfx_eghrt1"},
		vfx_hurtx = {"sfx_egdie1"},
		vfx_die = {"sfx_egdie1", "sfx_egdie2", "sfx_egmis1"},
		vfx_heal = {"sfx_eghel1"},
		vfx_healself = {"sfx_eghel1"},
		vfx_kill = {"sfx_egkll1", "sfx_egkll2"},
		vfx_1more = {"sfx_eg1mr1", "sfx_eg1mr2", "sfx_eg1mr3", "sfx_eg1mr4"},
		vfx_crit = {"sfx_egcrt1", "sfx_egcrt2", "sfx_egcrt3"},
		vfx_aoaask = {"sfx_egaoi1"},
		vfx_aoado = {"sfx_egaoa1", "sfx_egaoa2"},
		vfx_aoarelent = {"sfx_egdge1"},
		vfx_miss = {"sfx_egmis1", "sfx_egmis2"},
		vfx_dodge = {"sfx_egdge1"},
		vfx_win = {"sfx_egwin1"},
		vfx_levelup = {"sfx_eg1mr2", "sfx_eghel1"},

		icon = "ICO_EGGM",	-- icon for net select and other menus
		hudbust = "EGG_H",			-- patch to draw on the stat hud
		hudbustlayer = "",		-- transparent patch to draw for status conditions
		hudaoa = "H_EGGAOA",	-- patch for all out attack hud
		hudcutin = "EGGM_A",	-- cut in
		hudspr = "EGGM",	-- sprite prefix since hud can't retrieve it. yikes
		aoa_quote = "Get a load of this!",

		tip = "A support centered around Curse skills. His failed instant kills can eventually inflict Hex which powers up his Curse skills. Used in conjuction with his defence debuff, he can quickly rack up damage for the party.",
	},

	["blaze"] = {

		-- GENERAL

		name = "Blaze",			-- This is only for bots / enemies
		basehp = 55,			-- base HP for level 1
		basesp = 42,
		persona = "penthesilea",
		persona_pvp = "penthesilea_pvp",
		melee_natk = "blaze_atk1",	-- normal melee attack

		atk = 30,
		acc = 85,
		crit = 5,

		wep = "heels_01",
		weptype = WPT_HEELS,

		overlay = MT_SRB2P_BLAZETAIL,
		overlaythink = spr2_doblazetail,

		supercolor_start = SKINCOLOR_SUPERRED1,

		-- ANIMS
		-- Anims are built like this:
		-- {SPR_SPRITE, frame1, frame2, frame3, ... , duration between each frame}

		anim_stand = 		{SPR_PLAY, A, 8, "SPR2_STND"},		-- standing
		anim_stand_hurt =	{SPR_PLAY, A, 1, "SPR2_STND"},		-- standing (low HP)
		anim_stand_bored =	{SPR_PLAY, A, B, A, B, A, B, A, B, 10, "SPR2_WAIT"},	-- standing (rare anim)
		anim_guard = 		{SPR_PLAY, A, 1, "SPR2_WALK"},		-- guarding
		anim_move =			{SPR_PLAY, A, B, C, D, E, F, G, H, 2, "SPR2_WALK"},		-- moving
		anim_run =			{SPR_PLAY, A, B, C, D, E, 1, "SPR2_RUN_"},	-- guess what
		anim_atk =			{SPR_PLAY, A, B, C, D, E, 1, "SPR2_ROLL"},	-- attacking
		anim_aoa_end =		{SPR_PLAY, A, B, C, D, E, 1, "SPR2_ROLL"},	-- jumping out of all-out attack
		anim_hurt =			{SPR_PLAY, A, 35, "SPR2_PAIN"},		-- taking damage
		anim_getdown =		{SPR_PLAY, A, 1, "SPR2_PAIN"},		-- knocked down from weakness / crit
		anim_downloop =		{SPR_PLAY, A, 1, "SPR2_CNT1"},		-- is down
		anim_getup =		{SPR_PLAY, A, B, C, D, E, 1, "SPR2_ROLL"},		-- gets up from down
		anim_death =		{SPR_PLAY, A, 30, "SPR2_PAIN"},		-- dies
		anim_revive =		{SPR_PLAY, A, B, C, D, 1, "SPR2_ROLL"},		-- gets revived
		--anim_evoker =		{SPR_CSMN, A, B, 2},	-- holding evoker to head
		--anim_evoker_shoot =	{SPR_CSMN, C, 2},		-- shooting evoker

		anim_evoker = 		{SPR_PLAY, A, 8},
		anim_evoker_shoot = 		{SPR_PLAY, A, 8},

		anim_stand_super = 	{SPR_PLAY, A, B, C, D, 4, "SPR2_STND"},		-- standing
		anim_stand_hurt_super = 	{SPR_PLAY, A, B, C, D, 4, "SPR2_STND"},		-- standing
		anim_stand_bored_super = 	{SPR_PLAY, A, B, C, D, 4, "SPR2_STND"},		-- standing
		anim_run_super = 	{SPR_PLAY, A, B, 2, "SPR2_RUN_"},	-- run
		anim_evoker_super = 	{SPR_PLAY, A, B, C, D, 4, "SPR2_STND"},
		anim_evoker_shoot_super = 	{SPR_PLAY, A, B, C, D, 4, "SPR2_STND"},

		anim_special1 = {SPR_MRSP, A, B, C, D, 2}, -- spindash (revving up)
		anim_special2 = {SPR_MRSP, A, B, C, D, 1}, -- spindash (faster, revved up)

		vfx_summon = {"sfx_blsum1", "sfx_blsum2"},
        vfx_skill = {"sfx_blskl1", "sfx_blskl2", "sfx_blskl3", "sfx_blskl4"},
        vfx_item = {"sfx_blskl1", "sfx_blskl2"},
        vfx_hurt = {"sfx_blhrt1", "sfx_blhrt2"},
        vfx_hurtx = {"sfx_blhrx1"},
        vfx_die = {"sfx_bldie1", "sfx_bldie2"},
        vfx_heal = {"sfx_blhel1", "sfx_blhel2", "sfx_blhel3"},
        vfx_healself = {"sfx_blkll1", "sfx_blhrt2"},
        vfx_kill = {"sfx_blkll1", "sfx_blkll2", "sfx_blkll3"},
        vfx_1more = {"sfx_blkll1", "sfx_blkll2"},
        vfx_crit = {"sfx_blcrt1", "sfx_blcrt2", "sfx_blcrt3"},
        vfx_aoaask = {"sfx_blaoi1"},
        vfx_aoado = {"sfx_blcrt2", "sfx_blcrt3", "sfx_blsum2"},
        vfx_aoarelent = {"sfx_blaor1"},
        vfx_miss = {"sfx_blmis1", "sfx_blmis2"},
        vfx_dodge = {"sfx_bldge1", "sfx_bldge2"},
        vfx_win = {"sfx_blwin1", "sfx_blwin2", "sfx_blwin3"},
        vfx_levelup = {"sfx_bllvl1", "sfx_bllvl2"},

		icon = "ICO_BLAZ",	-- icon for net select and other menus
		hudbust = "BLA_H",			-- patch to draw on the stat hud
		hudbustlayer = "",		-- transparent patch to draw for status conditions
		hudaoa = "H_BLAAOA",	-- patch for all out attack hud
		hudcutin = "BLAZ_A",	-- cut in
		hudspr = "BLAZ",	-- sprite prefix since hud can't retrieve it. yikes
		aoa_quote = "Don't play with \nfire!",

		tip = "Learns powerful Ice attacks and status skills. She eventually lands ailments more reliably and gains bonus damage when attacking enemies inflicted with them, thanks to that, she can shut down random encounters easily.",
	},

	["amy"] = {

		-- GENERAL

		name = "Amy",			-- This is only for bots / enemies
		basehp = 45,			-- base HP for level 1
		basesp = 50,
		persona = "io",
		persona_pvp = "io_pvp",
		melee_natk = "amy_atk1",	-- normal melee attack

		atk = 35,
		acc = 80,
		crit = 4,

		wep = "hammer_01",
		weptype = WPT_HAMMER,

		-- ANIMS
		-- Anims are built like this:
		-- {SPR_SPRITE, frame1, frame2, frame3, ... , duration between each frame}

		anim_stand = 		{SPR_PLAY, A, 8, "SPR2_STND"},		-- standing
		anim_stand_hurt =	{SPR_PLAY, A, 1, "SPR2_STND"},		-- standing (low HP)
		anim_stand_bored =	{SPR_PLAY, A, B, C, D, A, B, C, D, A, B, C, D, A, B, C, D, 10, "SPR2_WAIT"},	-- standing (rare anim)
		anim_guard = 		{SPR_PLAY, A, 1, "SPR2_WALK"},		-- guarding
		anim_move =			{SPR_PLAY, A, B, C, D, E, F, G, H, 2, "SPR2_WALK"},		-- moving
		anim_run =			{SPR_PLAY, A, B, C, D, E, F, G, H, 2, "SPR2_RUN_"},	-- guess what
		anim_atk =			{SPR_PLAY, A, B, C, D, 1, "SPR2_ROLL"},	-- attacking
		anim_aoa_end =		{SPR_PLAY, D, C, B, A, 1, "SPR2_ROLL"},	-- jumping out of all-out attack
		anim_hurt =			{SPR_PLAY, A, 35, "SPR2_PAIN"},		-- taking damage
		anim_getdown =		{SPR_PLAY, A, 1, "SPR2_PAIN"},		-- knocked down from weakness / crit
		anim_downloop =		{SPR_PLAY, A, 1, "SPR2_SHIT"},		-- is down
		anim_getup =		{SPR_PLAY, A, B, C, D, 1, "SPR2_ROLL"},		-- gets up from down
		anim_death =		{SPR_PLAY, A, 30, "SPR2_PAIN"},		-- dies
		anim_revive =		{SPR_PLAY, A, B, C, D, 1, "SPR2_ROLL"},		-- gets revived
		anim_evoker =		{SPR_PLAY, A, 2, "SPR2_CSMN"},	-- uses evoker
		anim_evoker_shoot = {SPR_PLAY, B, A, 2, "SPR2_CSMN"},

		anim_special1 = {SPR_PLAY, A, 2, "SPR2_MLEE"}, -- hammer prep
		anim_special2 = {SPR_PLAY, B, C, D, 2, "SPR2_MLEE"}, -- hammer swing
		anim_special3 = {SPR_PLAY, A, "SPR2_MLEE"},	-- hammer swung
		anim_special4 = {SPR_PLAY, A, B, C, D, E, "SPR2_TWIN"},	-- hammer spin

		vfx_summon = {"sfx_arsum1", "sfx_arsum2", "sfx_arsum3", "sfx_arsum4"},
		vfx_skill = {"sfx_arskl1", "sfx_arskl2", "sfx_arskl3"},
		vfx_item = {"sfx_aruse1"},
		vfx_hurt = {"sfx_arhrt1", "sfx_arhrt2", "sfx_arhrt3"},
		vfx_hurtx = {"sfx_arhrx1"},
		vfx_die = {"sfx_arhrt1"},
		vfx_heal = {"sfx_arhel1", "sfx_arhel2"},
		vfx_healself = {"sfx_arhel1", "sfx_arhel2"},
		vfx_kill = {"sfx_arkll1", "sfx_arkll2", "sfx_arkll3", "sfx_arkll4"},
		vfx_1more = {"sfx_ar1mr1"},
		vfx_crit = {"sfx_arcrt1", "sfx_arcrt2", "sfx_arcrt3"},
		vfx_aoaask = {"sfx_araoi1", "sfx_araoi2", "sfx_araoi3"},
		vfx_aoado = {"sfx_araoa1", "sfx_araoa2"},
		vfx_aoarelent = {"sfx_araor1"},
		vfx_miss = {"sfx_armis1", "sfx_armis2", "sfx_armis3"},
		vfx_dodge = {"sfx_ardge1"},
		vfx_win = {"sfx_arwin1", "sfx_arwin2", "sfx_arwin3", "sfx_arwin4"},
		vfx_levelup = {"sfx_arlvl1"},

		icon = "ICO_AMY",	-- icon for net select and other menus
		hudbust = "AMY_H",			-- patch to draw on the stat hud
		hudbustlayer = "",		-- transparent patch to draw for status conditions
		hudaoa = "H_AMYAOA",	-- patch for all out attack hud
		hudcutin = "AMYR_A",	-- cut in
		hudspr = "ROSY",	-- sprite prefix since hud can't retrieve it. yikes
		aoa_quote = "I won't let you \nget in our way!",

		tip = "The ultimate healing support with powerful Wind magic at her disposal. Her high luck makes her unlikely to be shut down by ailments. Magic buffs and Baton Pass make her healing stronger. Mind her low HP.",
	},

	["metalsonic"] = {

		-- GENERAL

		name = "Metal Sonic",			-- This is only for bots / enemies
		basehp = 70,					-- base HP for level 1
		basesp = 30,
		persona = "palladion",
		persona_pvp = "palladion_pvp",
		melee_natk = "metal_atk1",	-- normal melee attack

		atk = 40,
		acc = 80,
		crit = 1,

		wep = "claws_01",
		weptype = WPT_CLAWS,

		supercolor_start = SKINCOLOR_SUPERRUST1,

		-- ANIMS
		-- Anims are built like this:
		-- {SPR_SPRITE, frame1, frame2, frame3, ... , duration between each frame}

		anim_stand = 		{SPR_PLAY, A, 8, "SPR2_STND"},		-- standing
		anim_stand_hurt =	{SPR_PLAY, A, 1, "SPR2_STND"},		-- standing (low HP)
		anim_stand_bored =	{SPR_PLAY, A, B, A, B, A, B, A, B, 10, "SPR2_WAIT"},	-- standing (rare anim)
		anim_guard = 		{SPR_PLAY, A, 1, "SPR2_WALK"},		-- guarding
		anim_move =			{SPR_PLAY, A, 2, "SPR2_WALK"},		-- moving
		anim_run =			{SPR_PLAY, A, 2, "SPR2_RUN"},	-- guess what
		anim_atk =			{SPR_PLAY, A, B, C, D, E, 1, "SPR2_ROLL"},	-- attacking
		anim_aoa_end =		{SPR_PLAY, E, D, C, B, A, 1, "SPR2_ROLL"},	-- jumping out of all-out attack
		anim_hurt =			{SPR_PLAY, A, 35, "SPR2_PAIN"},		-- taking damage
		anim_getdown =		{SPR_PLAY, A, 1, "SPR2_PAIN"},		-- knocked down from weakness / crit
		anim_downloop =		{SPR_PLAY, A, 1, "SPR2_SHIT"},		-- is down
		anim_getup =		{SPR_PLAY, A, B, C, D, E, F, 1, "SPR2_ROLL"},		-- gets up from down
		anim_death =		{SPR_PLAY, A, 30, "SPR2_DEAD"},		-- dies
		anim_revive =		{SPR_PLAY, A, B, C, D, E, F, 1, "SPR2_ROLL"},		-- gets revived
		anim_evoker = 		{SPR_PLAY, A, 8, "SPR2_SPNG"},

		anim_special1 =		{SPR_PLAY, A, 2, "SPR2_SPNG"},	-- charge
		anim_special2 =		{SPR_PLAY, A, 2, "SPR2_DASH"},	-- dash

		vfx_summon = {"sfx_mssum1", "sfx_mssum2"},
        vfx_skill = {"sfx_msskl1", "sfx_msskl2"},
        vfx_item = {"sfx_mssum1", "sfx_mssum2"},
        vfx_hurt = {"sfx_mshrt1", "sfx_mshrt2"},
        vfx_hurtx = {"sfx_msskl2"},
        vfx_die = {"sfx_msmis1"},
        vfx_heal = {"sfx_mssum1", "sfx_mssum2"},
        vfx_healself = {"sfx_mssum1", "sfx_mssum2"},
        vfx_kill = {"sfx_mssum1", "sfx_mssum2"},
        vfx_1more = {"sfx_msdge1"},
        vfx_crit = {"sfx_msskl2"},
        vfx_aoaask = {"sfx_msaoi1"},
        vfx_aoado = {"sfx_msskl2"},
        vfx_aoarelent = {"sfx_msmis1"},
        vfx_miss = {"sfx_msmis1"},
        vfx_dodge = {"sfx_msdge1"},
        vfx_win = {"sfx_mswin1"},
        vfx_levelup = {"sfx_mswin1"},

		icon = "ICO_MSON",	-- icon for net select and other menus
		hudbust = "MSON_H",			-- patch to draw on the stat hud
		hudbustlayer = "",		-- transparent patch to draw for status conditions
		hudaoa = "H_MSONAOA",	-- patch for all out attack hud
		hudcutin = "MSON_A",	-- cut in
		hudspr = "MSON",	-- sprite prefix since hud can't retrieve it. yikes
		aoa_quote = "Awaiting permission\nfor annhilation.",

		tip = "His high endurance and HP make him the best at taking hits. He also boasts high power and Attack buffs as well as defensive options for the whole party. His SP is very low and best kept for buffing.",

	},

	["kanade"] = {

		-- GENERAL

		locked = UNLOCK_ANGEL,

		name = "Kanade",		-- This is only for bots / enemies
		basehp = 70,			-- base HP for level 1 (Cannot be <= 0)
		basesp = 20,			-- base SP for level 1 (Can be 0, but not < 0!)
		persona = "none_kanade",-- Persona to use
		melee_natk = "handsonic_melee",	-- normal melee attack

		wep = "blades_01",
		weptype = WPT_HANDSONIC,

		-- ANIMS
		-- Anims are built like this:
		-- {SPR_SPRITE, frame1, frame2, frame3, ... , duration between each frame, ["SPR2_CONST"]}
		-- (SPR2 must be a string, and is optional. Only for use with SPR_PLAY)

		-- Note: As of Beta 1.0.0, not all animations are implemented
		-- (* = unimplemented)

		anim_stand = 		{SPR_PLAY, A, 8, "SPR2_STND"},					-- standing
		anim_stand_hurt =	{SPR_PLAY, A, 1, "SPR2_STND"},					-- standing (low HP) *
		anim_stand_bored =	{SPR_PLAY, A, 8, "SPR2_STND"},					-- standing (occasionally plays after anim_stand has played several times)
		anim_guard = 		{SPR_PLAY, A, 1, "SPR2_GARD"},					-- guarding
		anim_move =			{SPR_PLAY, A, B, C, D, E, F, 2, "SPR2_WALK"},	-- moving
		anim_run =			{SPR_PLAY, A, B, C, D, E, F, 2, "SPR2_RUN_"},	-- guess what
		anim_atk =			{SPR_PLAY, A, B, C, D, 2, "SPR2_ROLL"},			-- attacking
		anim_aoa_end =		{SPR_PLAY, D, C, B, A, 2, "SPR2_ROLL"},			-- jumping out of all-out attack
		anim_hurt =			{SPR_PLAY, A, 35, "SPR2_DEAD"},					-- taking damage
		anim_getdown =		{SPR_PLAY, A, 1, "SPR2_DEAD"},					-- knocked down from weakness / crit *
		anim_downloop =		{SPR_PLAY, A, 1, "SPR2_CNT1"},					-- is down
		anim_getup =		{SPR_PLAY, A, B, C, D, 1, "SPR2_ROLL"},			-- gets up from down
		anim_death =		{SPR_PLAY, A, 30, "SPR2_PAIN"},					-- dies
		anim_revive =		{SPR_PLAY, A, B, C, D, 1, "SPR2_ROLL"},			-- gets revived

		-- anim_special1 through anim_special32 may also be used for various purposes (ie: attack animations)
		anim_special1 =		{SPR_PLAY, A, TICRATE, "SPR2_MLEE"},
		anim_special4 = 	{SPR_PLAY, A, TICRATE, "SPR2_GARD"},			-- guard
		anim_sepcial5 =		{SPR_PLAY, A, TICRATE, "SPR2_HWLP"},			-- howling prep
		anim_special6 =		{SPR_PLAY, A, B, 2, "SPR2_HOWL"},				-- howling

		-- VOICES
		-- Possible list of voices
		-- vfx_action = {"sfx_voice1", "sfx_voice2", [...], "sfx_voicen"}

		-- ...In the case of kanade, she's silent, but I will leave these here for reference!

		vfx_summon = {},	-- Summoning Persona to use a Skill
        vfx_skill = {},		-- Used a Skill
        vfx_item = {},		-- Used an item
        vfx_hurt = {},		-- Sustained damage
        vfx_hurtx = {},		-- Sustained heavy damage / Critical hit / Weakness
        vfx_die = {},		-- Death
        vfx_heal = {},		-- Healed by teammate
        vfx_healself = {},	-- Healed self
        vfx_kill = {},		-- Killed an enemy
        vfx_1more = {},		-- Performed 1more
        vfx_crit = {},		-- Cut-in for Weakness/Critical Hit
        vfx_aoaask = {},	-- Ask to All-Out Attack
        vfx_aoado = {},		-- Performing All-Out Attack
        vfx_aoarelent = {},	-- Relenting from All-Out Attack
        vfx_miss = {},		-- Missed attack
        vfx_dodge = {},		-- Dodged enemy attack
        vfx_win = {},		-- Battle won
        vfx_levelup = {},	-- Level Up!


		-- HUD DEFINTIIONS

		icon = "ICO_KANA",			-- head icon for character select
		hudbust = "H_KANBAR",			-- patch to draw on the stat hud
		hudaoa = "H_KANAOA",		-- patch for all out attack hud
		aoa_quote = "...",
		hudcutin = "KANA_A",		-- cut in frames prefix

		-- Tip to display on the character select.
		-- Give insight on their skill type and their strengths/weaknesses in battle!
		tip = "Specializes in hard hitting Slash skills. She learns a couple of unique skills and has high damage potential, but lacks coverage and utility due to her abysmal SP pool.",
	},

	["shadow"] = {

		-- GENERAL

		name = "Shadow",			-- This is only for bots / enemies
		basehp = 65,			-- base HP for level 1
		basesp = 30,
		persona = "hermes",
		persona_pvp = "hermes_pvp",
		melee_natk = "shadow_atk1",	-- normal melee attack

		supercolor_start = SKINCOLOR_SUPERTAN1,

		atk = 30,
		acc = 85,
		crit = 3,

		wep = "limiter_01",
		weptype = WPT_LIMITERS,

		-- ANIMS
		-- Anims are built like this:
		-- {SPR_SPRITE, frame1, frame2, frame3, ... , duration between each frame}

		anim_stand = 		{SPR_PLAY, A, 8, "SPR2_STND"},		-- standing
		anim_stand_hurt =	{SPR_PLAY, A, 1, "SPR2_STND"},		-- standing (low HP)
		anim_stand_bored =	{SPR_PLAY, A, A, 30, "SPR2_WAIT"},	-- standing (rare anim)
		anim_guard = 		{SPR_PLAY, A, 1, "SPR2_WALK"},		-- guarding
		anim_move =			{SPR_PLAY, A, B, C, D, E, F, G, H, I, J, 2, "SPR2_WALK"},		-- moving
		anim_run =			{SPR_PLAY, A, B, C, D, 2, "SPR2_RUN_"},	-- guess what
		anim_atk =			{SPR_PLAY, A, B, C, D, E, F, 1, "SPR2_ROLL"},	-- attacking
		anim_aoa_end =		{SPR_PLAY, F, E, D, C, B, A, 1, "SPR2_ROLL"},	-- jumping out of all-out attack
		anim_hurt =			{SPR_PLAY, A, 35, "SPR2_PAIN"},		-- taking damage
		anim_getdown =		{SPR_PLAY, A, 1, "SPR2_PAIN"},		-- knocked down from weakness / crit
		anim_downloop =		{SPR_PLAY, A, 1, "SPR2_SHIT"},		-- is down
		anim_getup =		{SPR_PLAY, A, B, C, D, 1, "SPR2_ROLL"},		-- gets up from down
		anim_death =		{SPR_PLAY, A, 30, "SPR2_PAIN"},		-- dies
		anim_revive =		{SPR_PLAY, A, B, C, D, E, F, 1, "SPR2_ROLL"},		-- gets revived

		anim_stand_hurt_super = 	{SPR_PLAY, A, B, 4, "SPR2_STND"},		-- standing
		anim_stand_bored_super = 	{SPR_PLAY, A, B, 4, "SPR2_STND"},		-- standing
		anim_run_super = 	{SPR_PLAY, A, B, 2, "SPR2_RUN_"},	-- run
		anim_evoker_super = 	{SPR_PLAY, A, B, 4, "SPR2_STND"},
		anim_evoker_shoot_super = 	{SPR_PLAY, A, B, 4, "SPR2_STND"},

		-- chaos control still frame
		anim_special1 = 		{SPR_SHDW, A, B, 2},
		anim_special2 =			{SPR_PLAY, G, F, E, D, C, B, A, 2, "SPR2_SNAP"},

		vfx_summon = {"sfx_shsum1", "sfx_shsum2", "sfx_shsum3", "sfx_shsum4", "sfx_shsum5"},
        vfx_skill = {"sfx_shskl1", "sfx_shskl2", "sfx_shskl3", "sfx_shskl4"},
        vfx_item = {"sfx_shuse1", "sfx_shdge1", "sfx_shdge2", "sfx_shdge3"},
        vfx_hurt = {"sfx_shhrt1", "sfx_shhrt2", "sfx_shhrt3"},
        vfx_hurtx = {"sfx_shhrx1"},
        vfx_die = {"sfx_shdie1"},
        vfx_heal = {"sfx_shhel1", "sfx_shdge1", "sfx_shdge2", "sfx_shdge3"},
        vfx_healself = {"sfx_shhes1", "sfx_shdge1", "sfx_shdge2", "sfx_shdge3"},
        vfx_kill = {"sfx_shkll1", "sfx_shkll2", "sfx_shkll3", "sfx_shkll4"},
        vfx_1more = {"sfx_sh1mr1", "sfx_sh1mr2", "sfx_sh1mr3"},
        vfx_crit = {"sfx_shcrt1", "sfx_shcrt2", "sfx_shcrt3", "sfx_shcrt4"},
        vfx_aoaask = {"sfx_shaoi1", "sfx_shaoi2"},
        vfx_aoado = {"sfx_shaoa1", "sfx_shaoa2", "sfx_shaoa3"},
        vfx_aoarelent = {"sfx_shaor1"},
        vfx_miss = {"sfx_shmis1", "sfx_shmis2", "sfx_shmis3"},
        vfx_dodge = {"sfx_shdge1", "sfx_shdge2", "sfx_shdge3"},
        vfx_win = {"sfx_shwin1", "sfx_shwin2", "sfx_shwin3", "sfx_shwin4", "sfx_shwin5"},
        vfx_levelup = {"sfx_shlvl1", "sfx_shkll1", "sfx_sh1mr2", "sfx_sh1mr3", "sfx_shhes1"},

		icon = "ICO_SHAD",		-- icon for net select and other menus
		hudbust = "SHAD_H",			-- patch to draw on the stat hud
		hudbustlayer = "",		-- transparent patch to draw for status conditions
		hudaoa = "H_SHDAOA",	-- patch for all out attack hud
		hudcutin = "SHAD_A",	-- cut in
		hudspr = "SHAD",	-- sprite prefix since hud can't retrieve it. yikes
		aoa_quote = "Disgusting black\ncreatures!",

		//tip = "DISGUSTING BLACK CREATURES!",
		tip = "Can unleash devastating Slash skills with a Fire coverage. He will eventually do more damage the higher his HP is, so use his Defence buffs to mitigate the damage he takes. This is the best use for his SP.",

	},

	["knuckles"] = {

		-- GENERAL

		name = "Knuckles",			-- This is only for bots / enemies
		basehp = 70,			-- base HP for level 1
		basesp = 30,
		persona = "polydeuces",
		persona_pvp = "polydeuces_pvp",
		melee_natk = "knuckles_atk1",	-- normal melee attack

		supercolor_start = SKINCOLOR_SUPERRED1,

		atk = 35,
		acc = 999,
		crit = 2,

		wep = "knuckles_01",
		weptype = WPT_KNUCKLES,

		-- ANIMS
		-- Anims are built like this:
		-- {SPR_SPRITE, frame1, frame2, frame3, ... , duration between each frame}

		anim_stand = 		{SPR_PLAY, A, 8, "SPR2_STND"},		-- standing
		anim_stand_hurt =	{SPR_PLAY, A, 1, "SPR2_STND"},		-- standing (low HP)
		anim_stand_bored =	{SPR_PLAY, A, B, A, B, A, B, A, B, 10, "SPR2_WAIT"},	-- standing (rare anim)
		anim_guard = 		{SPR_PLAY, A, 1, "SPR2_WALK"},		-- guarding
		anim_move =			{SPR_PLAY, A, B, C, D, E, F, G, H, 2, "SPR2_WALK"},		-- moving
		anim_run =			{SPR_PLAY, A, B, C, D, 2, "SPR2_RUN_"},	-- guess what
		anim_atk =			{SPR_PLAY, A, B, C, D, E, F, 1, "SPR2_ROLL"},	-- attacking
		anim_aoa_end =		{SPR_PLAY, F, E, D, C, B, A, 1, "SPR2_ROLL"},	-- jumping out of all-out attack
		anim_hurt =			{SPR_PLAY, A, 35, "SPR2_PAIN"},		-- taking damage
		anim_getdown =		{SPR_PLAY, A, 1, "SPR2_PAIN"},		-- knocked down from weakness / crit
		anim_downloop =		{SPR_PLAY, A, 1, "SPR2_SHIT"},		-- is down
		anim_getup =		{SPR_PLAY, A, B, C, D, 1, "SPR2_ROLL"},		-- gets up from down
		anim_death =		{SPR_PLAY, A, 30, "SPR2_PAIN"},		-- dies
		anim_revive =		{SPR_PLAY, A, B, C, D, E, F, 1, "SPR2_ROLL"},		-- gets revived
		--anim_evoker =		{SPR_CSMN, E, F, 2},	-- uses evoker

		anim_special1 =		{SPR_PLAY, A, 2, "SPR2_SPNG"},
		anim_special2 =		{SPR_PLAY, A, B, 2, "SPR2_FALL"},

		vfx_summon = {"sfx_knsum1", "sfx_knsum2", "sfx_knsum3", "sfx_knsum4", "sfx_knsum5"},
        vfx_skill = {"sfx_knskl1", "sfx_knskl2", "sfx_knskl3", "sfx_knskl4"},
        vfx_item = {"sfx_knhes1", "sfx_knhes2"},
        vfx_hurt = {"sfx_knhrt1"},
        vfx_hurtx = {"sfx_knhrx1"},
        vfx_die = {"sfx_kndie1"},
        vfx_heal = {"sfx_knhel1", "sfx_knhel2", "sfx_knhel3"},
        vfx_healself = {"sfx_knhes1", "sfx_knhes2"},
        vfx_kill = {"sfx_knkll1", "sfx_knkll2", "sfx_knkll3", "sfx_knkll4", "sfx_knkll5"},
        vfx_1more = {"sfx_kn1mr1", "sfx_kn1mr2", "sfx_kn1mr3"},
        vfx_crit = {"sfx_kncrt1", "sfx_kncrt2", "sfx_kncrt3", "sfx_kncrt4"},
        vfx_aoaask = {"sfx_knaoi1", "sfx_knaoi2", "sfx_knaoi3"},
        vfx_aoado = {"sfx_knaoa1", "sfx_knaoa2"},
        vfx_aoarelent = {"sfx_knhes1"},
        vfx_miss = {"sfx_knmis1"},
        vfx_dodge = {"sfx_kndge1", "sfx_kndge2"},
        vfx_win = {"sfx_knwin1", "sfx_knwin2", "sfx_knwin3", "sfx_knwin4", "sfx_knwin5"},
        vfx_levelup = {"sfx_knlvl1", "sfx_kn1mr1", "sfx_kn1mr2", "sfx_kncrt2", "sfx_knhel3"},

		icon = "ICO_KTE",	-- icon for net select and other menus
		hudbust = "KTE_H",			-- patch to draw on the stat hud
		hudbustlayer = "",		-- transparent patch to draw for status conditions
		hudaoa = "H_KTEAOA",	-- patch for all out attack hud
		aoa_quote = "Time for a \nKnuckle sandwich!",
		hudcutin = "KNUX_A",	-- cut in
		hudspr = "KNUX",	-- sprite prefix since hud can't retrieve it. yikes

		tip = "A powerhouse with a lot of utility thanks to his Strike, Elec and debuff skills. He has high HP and endurance, but his low agility means his accuracy can be low at times. Use agility buffs to counter the issue.",

	},

	["tails"] = {

		-- GENERAL

		name = "Tails",			-- This is only for bots / enemies
		basehp = 50,			-- base HP for level 1
		basesp = 45,
		persona = "nemesis",
		persona_pvp = "nemesis_pvp",
		melee_natk = "tails_atk1",	-- normal melee attack

		overlay = MT_SRB2P_TAILSOVERLAY,
		overlaythink = spr2_dotails,

		supercolor_start = SKINCOLOR_SUPERORANGE1,

		atk = 28,
		acc = 90,
		crit = 5,

		wep = "monitor_01",
		weptype = WPT_MONITOR,

		-- ANIMS
		-- Anims are built like this:
		-- {SPR_SPRITE, frame1, frame2, frame3, ... , duration between each frame}

		anim_stand = 		{SPR_PLAY, A, 8, "SPR2_STND"},		-- standing
		anim_stand_hurt =	{SPR_PLAY, A, 1, "SPR2_STND"},		-- standing (low HP)
		anim_stand_bored =	{SPR_PLAY, A, B, A, B, A, B, A, B, 10, "SPR2_WAIT"},	-- standing (rare anim)
		anim_guard = 		{SPR_PLAY, A, 1, "SPR2_WALK"},		-- guarding
		anim_move =			{SPR_PLAY, A, B, C, D, E, F, G, H, 2, "SPR2_WALK"},		-- moving
		anim_run =			{SPR_PLAY, A, B, 2, "SPR2_RUN_"},	-- guess what
		anim_atk =			{SPR_PLAY, A, B, C, 1, "SPR2_ROLL"},	-- attacking
		anim_aoa_end =		{SPR_PLAY, C, B, A, 1, "SPR2_ROLL"},	-- jumping out of all-out attack
		anim_hurt =			{SPR_PLAY, A, 35, "SPR2_PAIN"},		-- taking damage
		anim_getdown =		{SPR_PLAY, A, 1, "SPR2_PAIN"},		-- knocked down from weakness / crit
		anim_downloop =		{SPR_PLAY, A, 1, "SPR2_SHIT"},		-- is down
		anim_getup =		{SPR_PLAY, A, B, C, 1, "SPR2_ROLL"},		-- gets up from down
		anim_death =		{SPR_PLAY, A, 30, "SPR2_PAIN"},		-- dies
		anim_revive =		{SPR_PLAY, A, B, C, 1, "SPR2_ROLL"},		-- gets revived
		anim_revive =		{SPR_PLAY, A, B, C, 1, "SPR2_ROLL"},		-- gets revived
		anim_evoker =		{SPR_PLAY, A, 2, "SPR2_CSMN"},	-- uses evoker
		anim_evoker_shoot = {SPR_PLAY, B, A, 2, "SPR2_CSMN"},

		anim_special1 = 	{SPR_PLAY, A, 2, "SPR2_FLY"},	-- special animations, 32 slots

		vfx_summon = {"sfx_tasum1", "sfx_tasum2", "sfx_tasum3"},
        vfx_skill = {"sfx_taskl1", "sfx_taskl2", "sfx_taskl3", "sfx_taskl4", "sfx_taskl5"},
        vfx_item = {"sfx_tause1", "sfx_tause2"},
        vfx_hurt = {"sfx_tahrt1", "sfx_tahrt2", "sfx_tahrt3"},
        vfx_hurtx = {"sfx_tahrx1"},
        vfx_die = {"sfx_tadie1", "sfx_tadie2"},
        vfx_heal = {"sfx_tahel1", "sfx_tahel2"},
        vfx_healself = {"sfx_tahes1"},
        vfx_kill = {"sfx_takll1", "sfx_takll2", "sfx_takll3", "sfx_takll4", "sfx_takll5"},
        vfx_1more = {"sfx_ta1mr1", "sfx_ta1mr2", "sfx_ta1mr3"},
        vfx_crit = {"sfx_tacrt1", "sfx_tacrt2", "sfx_tacrt3"},
        vfx_aoaask = {"sfx_taskl2", "sfx_tasum3"},
        vfx_aoado = {"sfx_taaoa1"},
        vfx_aoarelent = {"sfx_taaor1", "sfx_tamis1"},
        vfx_miss = {"sfx_tamis1", "sfx_tamis2", "sfx_tamis3"},
        vfx_dodge = {"sfx_tadge1", "sfx_tadge2"},
        vfx_win = {"sfx_tawin1", "sfx_tawin2", "sfx_tawin3"},
        vfx_levelup = {"sfx_takll1", "sfx_takll3", "sfx_takll4", "sfx_taskl1"},

		icon = "ICO_TAIL",	-- icon for net select and other menus
		hudbust = "TAL_H",			-- patch to draw on the stat hud
		hudbustlayer = "",		-- transparent patch to draw for status conditions
		hudaoa = "H_TALAOA",	-- patch for all out attack hud
		aoa_quote = "Let's end this!",
		hudspr = "TAIL",	-- sprite prefix since hud can't retrieve it. yikes
		hudcutin = "TAILS_A",	-- cut in

		tip = "A well-rounded support with Bless, Expel, Psychic and Healing skills. His high Luck make Expel attacks reliable and make him very unlikely to sustain ailments. Mind his low HP and defence.",

	},

}
)


-- auto freeslot sounds:
for k, v in pairs(charStats)
	VFX_freeslotC(k)
end