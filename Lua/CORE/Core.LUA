rawset(_G, "srb2p", {
	name = "SRB2PERSONA",
	version = "v1.3.5",
	verbase = 13,
	--debug = true,
	--debugprint = true,

	tutorial_map = 90, 	-- map for tutorial

	titlemap = 40,		-- don't forget to change that if the titlemap number changes

	tartarus_play = 2,		-- map where we play dungeon crawling
	tartarus_map = 1,		-- tartarus lobby map, used for mp shit etc
	customdungeon_map = 4,	-- map for custom dungeons

	colosseo_map = 3,	-- map for pvp stuff
	challenge_map = 20,	-- map for void runs

	loading = false,	-- used for special displays

	-- for DISPLAYING save data	(this is clientsided...)
	fileheaders = {},

	-- XDATA tables
	local_conds = {},		-- used for some unlockables.
	allowunlocks = true,	-- cheats
	challenge_bests = {}	-- best times/score for challenges.
})

rawset(_G, "cv_debugprints", CV_RegisterVar({
	name = "debugprints",
	defaultvalue = "Off",
	flags = 0,
	PossibleValue = CV_OnOff,
}))

rawset(_G, "cv_debugcheats", CV_RegisterVar({
	name = "debugcheats",
	defaultvalue = "Off",
	flags = CV_NETVAR,
	PossibleValue = CV_OnOff,
}))

rawset(_G, "currency", "\x96")
rawset(_G, "ICO_ITEM", "\x97")
rawset(_G, "ICO_SKILLCARD", "\x98")
rawset(_G, "ICO_PERSONA", "\x99")
rawset(_G, "ICO_KEYITEM", "\x9A")

-- +/- 25% per buff/debuff, max 3 buffs (75%)
rawset(_G, "BUFFSTEP", 25)
rawset(_G, "MAXBUFFS", 3)

local gm_constants = {
	"GM_COOP",
	"GM_CHALLENGE",
	"GM_VOIDRUN",
	"GM_PVP"
}
for i = 1, #gm_constants
	rawset(_G, gm_constants[i], i)
end

// PVP Gamemodes
local pvp_constants = {
	"PVP_PURGATORIO",
	"PVP_BOSSMODE",
	"PVP_RANDSKILLS"
}
for i = 1, #pvp_constants
	rawset(_G, pvp_constants[i], i)
end

-- push consoleplayer / displayplayer
rawset(_G, "consoleplayer", 0)
rawset(_G, "displayplayer", 0)
hud.add(function(v, p, c)
	if not consoleplayer or not consoleplayer.valid
		consoleplayer = p
	end
	displayplayer = p
end)

rawset(_G, "dprint", function(s)
	if cv_debugprints.value then print(s) end
end)

-- Weapon type constants:
local weapontypes = {
	"WPT_SHOES",			-- Sonic
	"WPT_REMOTE",			-- Eggman
	"WPT_HAMMER",			-- Amy
	"WPT_KNUCKLES",			-- Guess who
	"WPT_CLAWS",			-- Metal Sonic
	"WPT_MONITOR",			-- Tails
	"WPT_LIMITERS",			-- Shadow
	"WPT_PSYGLOVES",		-- Silver
	"WPT_HEELS",			-- Blaze
	"WPT_HANDSONIC",		-- Angel
	"WPT_GENERICMELEE",		-- generic melee weapons
	"WPT_GENERICRANGED",	-- generic ranged weapons
}

for i = 1, #weapontypes do
	rawset(_G, weapontypes[i], 2^(i-1))
end

-- some button constants:
rawset(_G, "BT_BTNA", BT_JUMP)
rawset(_G, "BT_BTNB", BT_USE)
rawset(_G, "BT_BTNC", BT_TOSSFLAG)
rawset(_G, "BT_BTNL", BT_WEAPONPREV)
rawset(_G, "BT_BTNR", BT_WEAPONNEXT)

rawset(_G, "atk_constant_2_num", {})

-- thanks luacolours;
rawset(_G, "MAXSKINCOLORS", 68)

local atk_constants = {
	"ATK_SLASH",
	"ATK_STRIKE",
	"ATK_PIERCE",
	"ATK_FIRE",
	"ATK_ICE",
	"ATK_WIND",
	"ATK_ELEC",
	"ATK_PSY",
	"ATK_NUCLEAR",
	"ATK_BLESS",
	"ATK_CURSE",
	"ATK_ALMIGHTY",
	"ATK_HEAL",
	"ATK_SUPPORT",
	"ATK_PASSIVE"
}
for i = 0, #atk_constants-1
	rawset(_G, atk_constants[i+1], 2^i)
	atk_constant_2_num[2^i] = i+1
end

-- PSV constants for passive skill effects
-- the way this works is that you give the passive skill the type of ATK_PASSIVE|ATK_TYPE
-- where ATK_TYPE is any other type, and the PSV_ constant will take effect on the ATK_TYPE affinity


local psv_constants = {
	"PSV_DODGE",	-- increase evasion
	"PSV_RESIST",	-- grants resist aff for type
	"PSV_BLOCK",	-- grants immunity aff for type
	"PSV_DRAIN",	-- grants drain aff for type
	"PSV_REPEL",	-- grants repel aff for type

	"PSV_BOOST",	-- boost damage by 'power' % for type
					-- if used for ATK_SUPPORT, increases healing done

	"PSV_ENDURE",	-- survive blows with 1 HP
					-- setting (a) type(s) lets you survive instakill attacks of this type with 1 HP instead of all attacks
					-- 'power' is how many times per battle this skill can be activated. Set to 0 for infinite uses
					-- 'accuracy' determines the likelyhood of the skill triggering.


	"PSV_STARTBATTLE",	-- execute a function at the start of the battle (the anim func), the target will be the user itself
	"PSV_STARTTURN",	-- execute a function at the start of the turn. (the anim func), the target will be the user itself
	"PSV_ENDTURN",		-- execute a function at the end of the turn. (the anim func), the target will be the user itself
	"PSV_ENDBATTLE",	-- execute a function at the end of the battle. (the anim func), the target will be the user itself

	"PSV_COND_RESIST",	-- resist status condition (odds /2)
	"PSV_COND_BLOCK",	-- nullify status condition (odds *0)

	"PSV_COND_BOOST",	-- increase odds of hitting a status condition (odds *1.2)

	"PSV_PERFECTIONNIST",	-- Final damage ranges from hit% to power% depending on remaining HP (100% to accuracy%)
	"PSV_SLAYER",			-- Increase damage by power% to enemies afflicted with the selected status conditions

	"PSV_SWORDBREAKER",		-- reduces damage of attack of 'type' type by 'power' % 'accuracy'% of the time

	"PSV_PLANB",			-- inflicts 'status' with a 'statuschance' rate when missing an instant kill of 'type'

	"PSV_LINKHITS",		-- Increase power of Link skills initial hits and allows them to hit more often (power for increase (%), accuracy for # hits)
	"PSV_LINKBOOST",	-- Increase the power of every subsequent link hit by +power% for every subsequent hit.

	-- should've been named DAMAGECALC probably but we're not gonna change that now...
	-- A lot of the above PSV constants are kinda deprecated by this but there's no real reason to remove them.
	"PSV_TRIGGERDAMAGE",			-- executes 'anim' with mo, target, dmg ad crit arugments when target is damaged. The returned value will be used as damage.
	"PSV_TRIGGERDAMAGE_RECEIVED",	-- ditto, but executes for the receiving end

	-- Ditto but runs when damage is physically received
	"PSV_ONDAMAGE",
	"PSV_ONDAMAGE_RECEIVED",

	-- Boosts critical hits odds by power% (multiplicative)
	"PSV_CRITBOOST",

	-- gets passed usable skills of 'mo', must return the new cost.
	-- the COST TYPE CANNOT BE CHANGED.
	-- anim(mo, skill, cost)
	-- return the cost
	"PSV_SKILLCOST",
}

for i = 1, #psv_constants
	rawset(_G, psv_constants[i], i)
end

/*
	Fields:
	Get appplied by certain attacks and yield various effect

	Garuverse: Heal 50% of damage you deal
	Zioverse: Echoes 20% of single target damage onto every other enemy under the effect of zionverse

	UNIMPLEMENTED:
	Agiverse: Increase EP gained from striking inflicted enemies, and raise odds of critical hits
	Bufuverse: Enemies can't dodge incoming attacks
*/

local fields = {
	"FLD_GARUVERSE",
	"FLD_ZIOVERSE",
	"FLD_AGIVERSE",
	"FLD_BUFUVERSE",
}

for i = 1, #fields
	rawset(_G, fields[i], i)
end

/*
	what do status conditions do? a stupid guide

	burn: 5% HP loss each turn, take 15% more damage
	freeze: Can't dodge, very weak against physical attacks
	shock: skip next turn. (1 turn)
	brainwash: attack ally, heal / buff enemy at random (3 turns)
	dizzy: accuracy halved (3 turns)
	silence: can't use skills (3 turns)
	sleep: can't act until attacked. recover 10% HP/SP every turn, phys attacks deal crit on sleeping entities (until healed/damaged)
	hex: take 50% of the damage you deal back
	despair: 5% SP loss at the end of each turn, goes away if sp = 1 (until healed)
	rage: atk*2, def/2, can only use random target melee attacks (3 turns)
	hunger: all stats halved (until heal)
	hyper: all stats +10, knockdown immunity (3 turns)
	super: all stats +15, damage immunity (until emerald gauge runs out)

	all of these can be healed by patra because fuck having 10 different skills / items for each specific cond
	of course you can't use patra on hyper/super, you fucking idiot
*/

-- COND_ status condition flags
rawset(_G, "COND_BURN", 1)
rawset(_G, "COND_FREEZE", 2)
rawset(_G, "COND_SHOCK", 4)
rawset(_G, "COND_BRAINWASH", 8)
rawset(_G, "COND_DIZZY", 16)
rawset(_G, "COND_SILENCE", 32)
rawset(_G, "COND_SLEEP", 64)
rawset(_G, "COND_HEX", 128)
rawset(_G, "COND_DESPAIR", 256)
rawset(_G, "COND_RAGE", 512)
rawset(_G, "COND_HUNGER", 1024)
rawset(_G, "COND_POISON", 2048)
rawset(_G, "COND_HYPER", 4096)
rawset(_G, "COND_SUPER", 8192)

local cond_color = {
	35,		-- burn
	130,	-- freeze
	64,		-- shock
	202,	-- brainwash
	52,		-- dizzy
	96,		-- silence
	162,	-- sleep
	185,	-- fear
	198,	-- despair
	45,		-- rage
	86,		-- hunger, pls insert food
	185,	-- poison
	1,		-- hyper mode
	-- super has none.
}

rawset(_G, "cond2color", {})
for i = 0, #cond_color-1 do
	cond2color[2^i] = cond_color[i+1]
end

-- TGT_ constants (again, just that it makes atk defs look clean.)

rawset(_G, "TGT_ENEMY", 1)
rawset(_G, "TGT_ALLY", 2)
rawset(_G, "TGT_CASTER", 3)
rawset(_G, "TGT_ALLENEMIES", 4)
rawset(_G, "TGT_ALLALLIES", 5)
rawset(_G, "TGT_DEAD", 6)
rawset(_G, "TGT_EVERYONE", 7)	-- lol why the fuck would you use this.

-- CST_ cost constants

rawset(_G, "CST_SP", 1)
rawset(_G, "CST_SPPERCENT", 2)
rawset(_G, "CST_HP", 3)
rawset(_G, "CST_HPPERCENT", 4)
rawset(_G, "CST_EP", 5)	-- emerald power

rawset(_G, "MAXSUBPERSONAS", 16)

-- ARCANA_ constants

rawset(_G, "ARCANA_FOOL", 0)
rawset(_G, "ARCANA_MAGICIAN", 1)
rawset(_G, "ARCANA_PRIESTRESS", 2)
rawset(_G, "ARCANA_EMPRESS", 3)
rawset(_G, "ARCANA_EMPEROR", 4)
rawset(_G, "ARCANA_HIEROPHANT", 5)
rawset(_G, "ARCANA_LOVERS", 6)
rawset(_G, "ARCANA_CHARIOT", 7)
rawset(_G, "ARCANA_JUSTICE", 8)
rawset(_G, "ARCANA_HERMIT", 9)
rawset(_G, "ARCANA_FORTUNE", 10)
rawset(_G, "ARCANA_STRENGTH", 11)
rawset(_G, "ARCANA_HANGED", 12)
rawset(_G, "ARCANA_DEATH", 13)
rawset(_G, "ARCANA_TEMPERANCE", 14)
rawset(_G, "ARCANA_DEVIL", 15)
rawset(_G, "ARCANA_TOWER", 16)
rawset(_G, "ARCANA_STAR", 17)
rawset(_G, "ARCANA_MOON", 18)
rawset(_G, "ARCANA_SUN", 19)
rawset(_G, "ARCANA_JUDGEMENT", 20)
rawset(_G, "ARCANA_WORLD", 21)

rawset(_G, "ARCANA_JESTER", 32767)
rawset(_G, "ARCANA_HUNGER", ARCANA_JESTER + ARCANA_STRENGTH)
rawset(_G, "ARCANA_AEON", ARCANA_JESTER + ARCANA_JUDGEMENT)
rawset(_G, "ARCANA_UNIVERSE", ARCANA_JESTER + ARCANA_WORLD)

-- yes good idea lets push uint32 to int32, itll be ok they said
-- NO IT'S NOT FUCKING OK YOU ABSOLUTE DUMBASS
rawset(_G, "angtoint", function(a)
	if not a return 0 end
	a = $/ANG1
	if a < 0
		a = $+360
	end
	return a
end)