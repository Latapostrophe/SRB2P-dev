rawset(_G, "srb2p", {
	name = "SRB2PERSONA",
	version = "v2.0B-09.09.23",
	verbase = 20,
	debug = true,
	--debugprint = true,

	tutorial_map = 90, 	-- map for tutorial

	titlemap = 40,		-- don't forget to change that if the titlemap number changes

	tartarus_play = 2,		-- map where we play dungeon crawling
	tartarus_map = 1,		-- tartarus lobby map, used for mp shit etc
	customdungeon_map = 4,	-- map for custom dungeons

	colosseo_map = 3,	-- map for pvp stuff
	challenge_map = 20,	-- map for void runs

	story_startmap = 24, --21,	-- story start
	story_levelcap = 30,	-- level cap for story mode

	loading = false,	-- used for special displays

	-- for DISPLAYING save data	(this is clientsided...)
	fileheaders = {},
	-- event flags etc
	storydata = {
					events = {},		-- event flags
					compendium = {},	-- compendium data
					date = {},			-- date
					itemboxes = {},		-- item boxes opened (so that we can despawn them)
					checkpoints = {},	-- registered checkpoints
					emeralds = 0,		-- works like vanilla
					shopstocks = {},	-- shop stocks

					-- LiNK data
					linklvl = 1,		-- LiNK Level
					linkexp = 0,		-- LiNK EXP
					linkpts = 0,		-- LiNK Points
					linkskills = {},	-- LiNK Skill Levels

					-- Request data
					requeststatus = {},		-- Status of every request, nil by default.
					activerequests = {},	-- Active requests + trackers
				},

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

rawset(_G, "ICO_RARE1", "\xF4")
rawset(_G, "ICO_RARE2", "\xF5")
rawset(_G, "ICO_RARE3", "\xF6")
rawset(_G, "ICO_RARE4", "\xF7")
rawset(_G, "ICO_RARE5", "\xF8")
rawset(_G, "ICO_RARE6", "\xF9")
rawset(_G, "ICO_RARE7", "\xFA")

rawset(_G, "rarity_2_ico", {
	ICO_RARE1, ICO_RARE2, ICO_RARE3, ICO_RARE4, ICO_RARE5, ICO_RARE6, ICO_RARE7
})

-- +/- 10% per buff/debuff, max 3 buffs (45%)
rawset(_G, "BUFFSTEP", 15)
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

rawset(_G, "ARCANA_FOOL", 1)
rawset(_G, "ARCANA_MAGICIAN", 2)
rawset(_G, "ARCANA_PRIESTESS", 3)
rawset(_G, "ARCANA_EMPRESS", 4)
rawset(_G, "ARCANA_EMPEROR", 5)
rawset(_G, "ARCANA_HIEROPHANT", 6)
rawset(_G, "ARCANA_LOVERS", 7)
rawset(_G, "ARCANA_CHARIOT", 8)
rawset(_G, "ARCANA_JUSTICE", 9)
rawset(_G, "ARCANA_HERMIT", 10)
rawset(_G, "ARCANA_FORTUNE", 11)
rawset(_G, "ARCANA_STRENGTH", 12)
rawset(_G, "ARCANA_HANGED", 13)
rawset(_G, "ARCANA_DEATH", 14)
rawset(_G, "ARCANA_TEMPERANCE", 15)
rawset(_G, "ARCANA_DEVIL", 16)
rawset(_G, "ARCANA_TOWER", 17)
rawset(_G, "ARCANA_STAR", 18)
rawset(_G, "ARCANA_MOON", 19)
rawset(_G, "ARCANA_SUN", 20)
rawset(_G, "ARCANA_JUDGEMENT", 21)

-- LINK_ constants
local linkskills = {
	-- Raw stat up
	"LINK_HP",
	"LINK_SP",
	"LINK_ST",
	"LINK_MA",
	"LINK_EN",
	"LINK_AG",
	"LINK_LU",

	-- Party bonus stuff
	"LINK_ALLOUT",
	"LINK_REXP",
	"LINK_EPCONVERT",
	"LINK_MACCA",
	"LINK_RAREDROP",
	"LINK_BREEZE",

	-- services:
	"LINK_VELVET_SALES",
	"LINK_VELVET_TRADES",

	"LINK_VELVET_FUSION",
	"LINK_VELVET_HIFUSION",

	"LINK_VELVET_GRINDUP",
	"LINK_VELVET_DISMANTLE",

	-- misc
	"LINK_LEXP",
	"LINK_AFFINITY",

}

for i = 1, #linkskills do
	rawset(_G, linkskills[i], i)
	srb2p.storydata.linkskills[i] = 0
end

rawset(_G, "LINK_NUMSKILLS", #linkskills)


rawset(_G, "linkskill_name", {
	[LINK_HP] = "Party Toughness",
	[LINK_SP] = "Party Spirit",
	[LINK_ST] = "Party Strength",
	[LINK_MA] = "Party Casting",
	[LINK_EN] = "Party Defence",
	[LINK_AG] = "Party Quickstep",
	[LINK_LU] = "Party Gamble",

	-- battle
	[LINK_ALLOUT] = 	"Party Coordination",
	[LINK_REXP] =		"Reserve Growth",
	[LINK_EPCONVERT] =	"Chaos Conversion",
	[LINK_MACCA] =		"Extortionist",
	[LINK_RAREDROP] =	"Salvager",
	[LINK_BREEZE] =		"Victory Breeze",

	-- velvet idiots
	[LINK_VELVET_SALES] =		"Sweet Deals",
	[LINK_VELVET_TRADES] =		"Exchange Master",
	[LINK_VELVET_FUSION] =		"Summoning Growth",
	[LINK_VELVET_HIFUSION] =	"Summoning Pact",
	[LINK_VELVET_GRINDUP] =		"Grind Up",
	[LINK_VELVET_DISMANTLE] =	"Dismantlement Master",

	-- LiNK
	[LINK_LEXP] =		"WiLD Link",
	[LINK_AFFINITY] =	"WiLD Affinity",
})

-- main description
rawset(_G, "linkskill_desc", {
	[LINK_HP] = "Increase the party's Max HP.",
	[LINK_SP] = "Increase the party's Max SP.",
	[LINK_ST] = "Increase the party's Strength,\nboosting physical damage.",
	[LINK_MA] = "Increase the party's Magic,\nboosting magic skill damage.",
	[LINK_EN] = "Increase the party's Defence,\nreducing damage from enemy attacks.",
	[LINK_AG] = "Increase the party's Agility,\nboosting hit and evasion rates.",
	[LINK_LU] = "Increase the party's Luck\nboosting odds of inflicting and evading critical hits and ailments.",

	[LINK_ALLOUT] = 	"Increase damage dealt by All-Out Attacks.",
	[LINK_REXP] =		"Increase EXP earned by party members\nin the reserve.",
	[LINK_EPCONVERT] =	"Convert excess EP at the end of a Battle\ninto additional EXP and Macca",
	[LINK_MACCA] =		"Increase Macca earned from enemies.",
	[LINK_RAREDROP] =	"Increase item drop rates from enemies.",
	[LINK_BREEZE] =		"Recover some HP & SP after Battle.",

	[LINK_VELVET_SALES] =	"Reduces prices in the Velvet Shop",
	[LINK_VELVET_TRADES] =	"Unlocks new trades in the Velvet Shop",

	[LINK_VELVET_FUSION] = 	"Fused Sub-Personas gain extra\nlevels worth of EXP",
	[LINK_VELVET_HIFUSION] ="Allows fusing Sub-Persona\nthat are higher level than you",

	[LINK_VELVET_GRINDUP] =		"Adds a chance to skip enhancement\nlevels in the Velvet Lab",
	[LINK_VELVET_DISMANTLE] =	"Increase the amount of materials\nobtained from dismantlement",

	[LINK_LEXP] =		"Increase LiNK EXP earned.",
	[LINK_AFFINITY] =	"Gain stat bonuses when matching\nMain and Sub-Persona arcanas",
})

-- "sub" description, shows the effect with numbers!!
-- [1] is level 0, so base behaviour without the skill bought.
rawset(_G, "linkskill_effect", {

	[LINK_HP] = {
		"No effect",
		"Party HP +5",		-- +5
		"Party HP +10",		-- +5
		"Party HP +15",		-- +5
		"Party HP +20",		-- +5
		"Party HP +30",		-- +10
	},

	[LINK_SP] = {
		"No effect",
		"Party SP +2",		-- +2
		"Party SP +4",		-- +2
		"Party SP +6",		-- +2
		"Party SP +10",		-- +4
		"Party SP +15",		-- +5
	},

	[LINK_ST] = {
		"No effect",
		"Party Strength +1",
		"Party Strength +2",
		"Party Strength +3",
		"Party Strength +4",
		"Party Strength +5",
	},

	[LINK_MA] = {
		"No effect",
		"Party Magic +1",
		"Party Magic +2",
		"Party Magic +3",
		"Party Magic +4",
		"Party Magic +5",
	},

	[LINK_EN] = {
		"No effect",
		"Party Endurance +1",
		"Party Endurance +2",
		"Party Endurance +3",
		"Party Endurance +4",
		"Party Endurance +5",
	},

	[LINK_AG] = {
		"No effect",
		"Party Agility +1",
		"Party Agility +2",
		"Party Agility +3",
		"Party Agility +4",
		"Party Agility +5",
	},

	[LINK_LU] = {
		"No effect",
		"Party Luck +1",
		"Party Luck +2",
		"Party Luck +3",
		"Party Luck +4",
		"Party Luck +5",
	},

	[LINK_ALLOUT] = {
		"100% All-Out Attack \ndamage modifier",
		"110% All-Out Attack \ndamage modifier",
		"120% All-Out Attack \ndamage modifier",
		"130% All-Out Attack \ndamage modifier",
	},

	[LINK_REXP] = {
		"50% EXP earned by \nreserve members",
		"70% EXP earned by \nreserve members",
		"85% EXP earned by \nreserve members",
		"100% EXP earned by \nreserve members",
	},

	[LINK_EPCONVERT] = {
		"EP dissipates after Battle.",
		"Conversion rate: \n+5% EXP & Macca \nper EP Charge",
		"Conversion rate: \n+7.5% EXP & Macca \nper EP Charge",
		"Conversion rate: \n+10% EXP & Macca \nper EP Charge",
	},

	[LINK_RAREDROP] = {
		"100% enemy item drop \nrate modifier",
		"105% enemy item drop \nrate modifier",
		"110% enemy item drop \nrate modifier",
		"115% enemy item drop \nrate modifier",
	},

	[LINK_MACCA] = {
		"100% enemy Macca \ndrop modifier",
		"105% enemy Macca \ndrop modifier",
		"110% enemy Macca \ndrop modifier",
		"115% enemy Macca \ndrop modifier",
	},

	[LINK_BREEZE] = {
		"No effect",
		"After battle, party \nrecovers 4% HP \nand 2% SP",
		"After battle, party \nrecovers 7% HP \nand 3% SP",
		"After battle, party \nrecovers 10% HP \nand 5% SP",
	},

	[LINK_VELVET_SALES] = {
		"No effect",
		"5% discount in \nthe Velvet Shop",
		"10% discount in \nthe Velvet Shop",
		"15% discount in \nthe Velvet Shop",
	},

	[LINK_VELVET_TRADES] = {
		"No effect",
		"Unlock more trades \nin the Velvet Shop",
		"Unlock even more trades \nin the Velvet Shop",
		"Unlock all trades \nin the Velvet Shop",
	},

	[LINK_VELVET_FUSION] = {
		"No effect",
		"Fused Sub-Personas gain \nhalf a level worth of EXP",
		"Fused Sub-Personas gain \n1 level worth of EXP",
		"Fused Sub-Personas gain \n2 levels worth of EXP",
	},

	[LINK_VELVET_HIFUSION] = {
		"No effect",
		"Can fuse Sub-Personas \n1 level higher than you",
		"Can fuse Sub-Personas \n3 levels higher than you",
		"Can fuse Sub-Personas \n5 levels higher than you",
	},

	[LINK_VELVET_GRINDUP] = {
		"No effect",
		"25% chance to gain \n+2 levels when \nenhancing equipment",
		"25% chance to gain \n+2 to +3 levels when \nenhancing equipment",
		"25% chance to gain \n+2 to +5 levels when \nenhancing equipment",
	},

	[LINK_VELVET_DISMANTLE] = {
		"No effect",
		"+1 of each material \non dismantlement",
		"+2 of each material \non dismantlement",
		"+3 of each material \non dismantlement",
	},


	[LINK_LEXP] = {
		"100% LiNK EXP modifier",
		"110% LiNK EXP modifier",
		"120% LiNK EXP modifier",
		"130% LiNK EXP modifier",
	},

	[LINK_AFFINITY] = {
		"No effect",
		"+1 to all stats when \nArcanas of Main & \nSub Personas match.",
		"+2 to all stats when \nArcanas of Main & \nSub Personas match.",
		"+3 to all stats when \nArcanas of Main & \nSub Personas match.",
	},

})

rawset(_G, "linkskill_cost", { -- Lets implicit the max level for each skill from this table cause...you know what I mean?
	[LINK_HP] = {1,2,3,4,5},
	[LINK_SP] = {1,2,3,4,5},
	[LINK_ST] = {1,2,3,4,5},
	[LINK_MA] = {1,2,3,4,5},
	[LINK_EN] = {1,2,3,4,5},
	[LINK_AG] = {1,2,3,4,5},
	[LINK_LU] = {1,2,3,4,5},


	[LINK_ALLOUT] = {3,6,9},
	[LINK_REXP] = {5,10,15},
	[LINK_EPCONVERT] = {5,10,15},
	[LINK_RAREDROP] = {3,6,9},
	[LINK_MACCA] = {3,6,9},
	[LINK_BREEZE] = {5,10,15},

	[LINK_VELVET_SALES] =	{2, 5, 8},
	[LINK_VELVET_TRADES] =	{5, 10, 15},

	[LINK_VELVET_FUSION] = 		{2, 5, 8},
	[LINK_VELVET_HIFUSION] =	{5, 10, 15},

	[LINK_VELVET_DISMANTLE] = {3, 6, 9},
	[LINK_VELVET_GRINDUP] = {3, 6, 9},

	[LINK_LEXP] = {3,6,9,12,15},
	[LINK_AFFINITY] = {5,10,15},
})

rawset(_G, "linkexptable", {})
for i = 1, 99
	linkexptable[i] = 100*i
end

rawset(_G, "linkgrid", {

	{LINK_HP, LINK_SP, LINK_ST, LINK_MA, LINK_EN, LINK_AG, LINK_LU},
	{LINK_ALLOUT, LINK_REXP, LINK_EPCONVERT, LINK_RAREDROP, LINK_MACCA, LINK_BREEZE},
	{LINK_VELVET_SALES, LINK_VELVET_TRADES, LINK_VELVET_FUSION, LINK_VELVET_HIFUSION, LINK_VELVET_GRINDUP, LINK_VELVET_DISMANTLE},
	{LINK_LEXP, LINK_AFFINITY},
})

-- This is mainly for applying the hp and sp link boosts, but can be used for other things
rawset(_G, "linkfunction", {
	[LINK_HP] = function(mo)
		for i = 1, #server.plentities[1]
			local m = server.plentities[1][i]
			if not m.linkhp
				m.linkhp = 5*srb2p.storydata.linkskills[LINK_HP]
				m.maxhp = $ + m.linkhp
			else
				m.linkhp = $ + 5
				m.maxhp = $ + 5
				m.hp = $ + 5
				m.realhp = $ + 5
			end
		end
		return true
	end,
	[LINK_SP] = function(mo)
		for i = 1, #server.plentities[1]
			local m = server.plentities[1][i]
			if not m.linksp
				m.linksp = 2*srb2p.storydata.linkskills[LINK_SP]
				m.maxsp = $ + m.linksp
			else
				m.linksp = $ + 2
				m.maxsp = $ + 2
				m.sp = $ + 2
				m.realsp = $ + 2
			end
		end
		return true
  end,
})

-- Episode Stat Boost Limits
-- I made this expandable just in case
local stat_boost_consts = {
  "BOOST_CATALYST",
}
for i = 1, #stat_boost_consts
	rawset(_G, stat_boost_consts[i], i)
end


rawset(_G, "episode_limits", {
  [1] = { [BOOST_CATALYST] = 100 },
})

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