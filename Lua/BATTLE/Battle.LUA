-- core battle script goes here

rawset(_G, "cv_turntimer", CV_RegisterVar({
	name = "turntimer",
	defaultvalue = 0,
	flags = CV_NETVAR|CV_SAVE,
	PossibleValue = {MIN = 0, MAX = 99},
}))

-- MapLoad: Initiate server battle stuff.
rawset(_G, "spawnbattlecam", function()
	local camera = P_SpawnMobj(0, 0, 0, MT_BATTLECAMERA)
	camera.aiming = 0
	camera.goto = {}
	camera.gotoangle = {}
	camera.look = {}
	return camera
end)

rawset(_G, "lives_difficulty", {
	-1,	-- infinite
	10,	-- easy
	7,	-- normal
	5,	-- hard
	3,	-- very hard
	1,	-- risky
	0,	-- monad
})

-- man it would be cool if we could modify the way map starts too
rawset(_G, "BTL_MapLoad", function()
	if not server return end

	local difficulty_macca = {
		250,
		750,
		1500,
		2500,
		4000,
		8000,
		15000,
	}

	if not server.P_BattleStatus or server.P_BattleStatus.kill
		server.P_BattleStatus = {}

		for i = 1, 4
			server.P_BattleStatus[i] = {
				n = i,	-- # of battle status, can be used for misc purposes i guess?
				firstact = i,	-- used for PVP
				running = false,		-- is a battle going on?
				boss = false,			-- battle is a boss
				saved_affs = {},		-- enemy affinities and attacks
				--subpersonas = {P_generateSubPersona("none"), P_generateSubPersona("black frost"), P_generateSubPersona("pale rider"), P_generateSubPersona("titania")},		-- sub personas
				subpersonas = {P_generateSubPersona("none")},
				subpersonastock = 17,	-- # of subpersonas possible (+1 because none counts as its own subp)
				spu = 1,				-- number of sp units for players to work with
				emeraldpow_max = server.difficulty or 1,		-- max emerald power gauge
				emeraldpow = 0,			-- emerald power
				emeraldpow_lvbuf = 0,	-- for sounds
				emeraldpow_buffer = false,	-- someone is using hyper mode
				battletime = 0,			-- a timer that runs constantly while the battle is going.
				battlestate = 	0,		-- BS_ constants. battle state.
				actionstate = 0,		-- ACT_ constants. Used for player menus
				turn = 0,				-- # of turn
				turnorder = {},			-- list of entities that will act this turn. turnorder[1] is the current acting entity.
				fighters = {},			-- list of entities who are fighting
				plist = {},				-- what players are in the battle? Used for pvp, mostly
				deadplayers = {},		-- these players were KO'd and can be targetted by revive spells
				arena_coords = {-5024*FRACUNIT,7328*FRACUNIT,256*FRACUNIT},	-- this is where we do battle stuff
				crit_seeds = {},		-- we determine crit for each individual entity :P
				evasion_seeds = {},		-- we determine evasion rate for each entity
				items = {{"snuffsoul", 5}, {"superring", 5}, {"patra gem", 3}, {"1up", 2}, {"dekaja gem", 2}, {"dekunda gem", 2}, {"homunculus", 1}, {"chaos drive x", 1}, {"soma", 1}},		-- everyone shares items.
				weapons = {},			-- list of weapons
				armours = {},			-- list of wardrings
				skillcards = {},		-- everyone shares skillcards as well.
				cam = spawnbattlecam(),	-- nice altviewpoint slave.
				starttype = 0,			-- how do we start the battle? these are for presets.
				atktimer = 0,			-- for attack animations
				transition = 0,			-- used mainly for players
				hudtimer = {},			-- used for player UI animations
				refplayer = 0,			-- we use this player for reference when reviving!
				console = nil,
				console_time = 0,		-- console handler
				macca = difficulty_macca[server.difficulty] or 1000,			-- money
				r_exp = 0,				-- amount of total exp earned for the end of the battle:
				r_item,					-- item earned for the end of the battle;
				r_weapons,				-- weapons earned
				r_rings,				-- rings (armour) earned
				r_money = 0,			-- amount of money earned for the end of the battle:s
				r_precalculates = {},	-- precalculates level and exp after battle for animation
				r_levelupqueue = {},	-- level up queue, this is a queue of what entities are to level up for each player
				r_queueprogress = {},	-- level up queue progress for each player
				r_newskillsqueue = {},	-- new skills learnt queue progress. Per entity rather than per player.
				r_skillqueueprogress = {},	-- new skills queue progress.
				r_wipe = 20,
				waven = 1,
				gameover = nil,

				netstats = {
					floors = 0,
					time = 0,

					encounters = 0,
					wins = 0,
					runaways = 0,
					damagedealt = 0,
					damagetaken = 0,
					damagehealed = 0,
					enemiesdefeated = 0,
					knockdowns = 0,
					timesdied = 0,
					timesrevived = 0,

					holdups = 0,
					alloutattacks = 0,

					subpersonasfound = 0,

					maccaearned = 0,
					maccaspent = 0,

					itemsfound = 0,
					itemsused = 0,
					itemsbought = 0,
					itemssold = 0,

					weaponsenhanced = 0,
					ringsenhanced = 0,

					reaperspotted = 0,
				}

			}

			-- uuuh test
			/*local wep = {"shoes_01", "device_01", "hammer_01", "knuckles_01"}
			for k = 1, 24
				local wepn = wep[P_RandomRange(1, #wep)]
				--print(wepn)
				local w = makeWeapon(wepn, P_RandomRange(0, 10))
				table.insert(server.P_BattleStatus[i].weapons, w)
			end*/
		end

		SRB2P_runHook("DungeonStart", server.P_BattleStatus[i])
	else
		for i = 1, 4
			BTL_softReset(i)
			local btl = server.P_BattleStatus[i]
			btl.emeraldpow_max = server.difficulty or 1		-- max emerald power gauge
		end

		SRB2P_runHook("DungeonStart", server.P_BattleStatus[i])
	end

	if server.difficulty
		server.P_BattleStatus.lives = lives_difficulty[server.difficulty]
	end

	local parsed_from_header = 0
	for i = 1, 4

		-- parse arena coordinates if available:
		local btl = server.P_BattleStatus[i]
		local process = {"x","y","z"}
		for j = 1, #process do
			--dprint("Updating arena coordinate "..process[j].." for battle status "..i)

			if mapheaderinfo[gamemap]["arena"..process[j]] ~= nil
				btl.arena_coords[j] = tonumber(mapheaderinfo[gamemap]["arena"..process[j]]) * FRACUNIT
				dprint("Parsed arena coord "..process[j].." as "..(btl.arena_coords[j]/FRACUNIT))
				parsed_from_header = true
			end
		end
	end

	if not parsed_from_header
		-- parse boss waypoint if possible
		for m in mobjs.iterate() do
			if m and m.valid and m.type == MT_BOSS3WAYPOINT

				for i = 1, 4
					local btl = server.P_BattleStatus[i]
					local shiftx = (mapheaderinfo[gamemap].arenashiftx or 0)*FRACUNIT *(i-1)
					local shifty = (mapheaderinfo[gamemap].arenashifty or 0)*FRACUNIT *(i-1)
					local t = P_SpawnMobj(m.x+shiftx, m.y+shifty, m.z, MT_THOK)
					t.state = S_INVISIBLE

					btl.arenacenter = t
				end
				break
			end
		end
	end
end)

addHook("MapLoad", do
	BTL_MapLoad()
end)

rawset(_G, "BTL_resetSubPersonas", function(pn)

	local btl = server.P_BattleStatus[pn]
	if not btl return end

	for j = 1, #btl.subpersonas
		btl.subpersonas[j].equipped = nil
	end

end)

-- BTl_softReset: resets everything related to normal battle gameplay.
rawset(_G, "BTL_softReset", function(pn)

	--for i = 1,4
		local btl = server.P_BattleStatus[pn]
		if not btl return end

		if btl.fighters
			for i = 1, #btl.fighters
				local mo = btl.fighters[i]

				if mo and mo.valid and not mo.plyr
					mo.fuse = 1
				end
			end
		end

		btl.running = false
		btl.runaway = false
		btl.aoa = false
		btl.firstact = pn	-- PVP
		btl.plist = {}
		btl.boss = false
		btl.battletime = 0
		btl.battlestate = 0
		btl.actionstate = 0
		btl.turn = 0
		btl.emeraldpow = 0
		btl.emeraldhyper = false
		btl.emeraldpow_buffer = false
		btl.turnorder = {}
		btl.fighters = {}
		btl.deadplayers = {}
		btl.dmg_hits = nil
		btl.dmg_usecritanim = nil
		btl.dmg_downs = nil
		btl.atktimer = 0
		btl.crit_seeds = {}
		btl.evasion_seeds = {}
		btl.starttype = 0
		btl.atktimer = 0
		btl.hudtimer = {}
		btl.console = nil
		btl.console_time = 0
		btl.r_exp = 0
		btl.r_baseexp = 0
		btl.r_item = nil
		btl.r_weapons = nil
		btl.r_rings = nil
		btl.r_expmultiplier = 0
		btl.r_moneymultiplier = 0
		btl.r_money = 0
		btl.r_basemoney = 0
		btl.r_precalculates = {}
		btl.r_levelupqueue = {}
		btl.r_queueprogress = {}
		btl.r_newskillsqueue = {}
		btl.r_skillqueueprogress = {}
		btl.r_wipe = 20
		btl.shufflestatus = nil
		btl.shuffletimer = nil
		btl.holdupfinish = nil
		btl.cam = spawnbattlecam()
		btl.kill = nil
		btl.gameover = nil
		btl.score = nil
		btl.scoremode = nil
		btl.storedwaves = nil
		btl.addscore = nil
		btl.waven = 1

		/*for j = 1, #btl.subpersonas
			btl.subpersonas[j].equipped = nil
		end*/
	--end
end)

rawset(_G, "BTL_initEnemyAnims", function(mo)
	local tbl = enemyList[mo.enemy]
	mo.anim_stand = tbl.anim_stand or {SPR_PLAY, A, 1}
	mo.anim_stand_hurt = tbl.anim_stand_hurt or copyTable(tbl.anim_stand) or {SPR_PLAY, A, 1}
	mo.anim_stand_bored = tbl.anim_stand_bored or copyTable(tbl.anim_stand) or {SPR_PLAY, B, C, B, C, B, C, B, C, A, 10}
	mo.anim_move = tbl.anim_move or copyTable(tbl.anim_stand) or {SPR_PLAY, D, E, F, G, H, I, J, K, 2}
	mo.anim_run = tbl.anim_move or copyTable(tbl.anim_stand) or {SPR_PLAY, Q, R, S, T, 2}
	mo.anim_atk = tbl.anim_atk or copyTable(tbl.anim_stand) or {SPR_PLAY, M, N, O, 2}
	mo.anim_hurt = tbl.anim_hurt or copyTable(tbl.anim_stand) or {SPR_PLAY, 27, 35}
	mo.anim_getdown = tbl.anim_getdown or copyTable(tbl.anim_stand) or {SPR_PLAY, 27, 1}
	mo.anim_downloop = tbl.anim_downloop or copyTable(tbl.anim_stand) or {SPR_PLAY, 27, 1}
	mo.anim_getup = tbl.anim_getup or copyTable(tbl.anim_stand) or {SPR_PLAY, A, 1}
	mo.anim_death = tbl.anim_death or copyTable(tbl.anim_stand) or {SPR_PLAY, 27, 30}
	mo.anim_revive = tbl.anim_revive or copyTable(tbl.anim_stand) or {SPR_PLAY, A, 30}
	mo.persona = personaList[tbl.persona]

	if tbl.anim_evoker
		mo.anim_evoker = tbl.anim_evoker
	end

	if tbl.skin
		mo.skin = tbl.skin
	end

	if tbl.hudcutin
		mo.hudcutin = tbl.hudcutin
	end

	if tbl.hudscutin
		mo.hudscutin = tbl.hudscutin
	end

	if tbl.color
		mo.color = tbl.color
	end

	for i = 1, 32
		if tbl["anim_special"..i]
			mo["anim_special"..i] = tbl["anim_special"..i]
		else
			mo["anim_special"..i] = {SPR_PLAY, A, 1}
		end
	end
end)

rawset(_G, "BTL_initEnemyAnimsPlayer", function(mo)
	local tbl = enemyList[mo.enemy]
	mo.anim_stand = tbl.anim_stand or {SPR_PLAY, A, 1}
	mo.anim_stand_hurt = tbl.anim_stand_hurt or tbl.anim_stand
	mo.anim_stand_bored = tbl.anim_stand_bored or tbl.anim_stand
	mo.anim_move = tbl.anim_move or tbl.anim_stand
	mo.anim_run = tbl.anim_move or tbl.anim_stand
	mo.anim_atk = tbl.anim_atk or tbl.anim_stand
	mo.anim_hurt = tbl.anim_hurt or tbl.anim_stand
	mo.anim_getdown = tbl.anim_getdown or tbl.anim_stand
	mo.anim_downloop = tbl.anim_downloop or tbl.anim_stand
	mo.anim_getup = tbl.anim_getup or tbl.anim_stand
	mo.anim_death = tbl.anim_death or tbl.anim_stand
	mo.anim_revive = tbl.anim_revive or tbl.anim_stand

	if tbl.persona and personaList[tbl.persona] -- So bosses with invalid personas don't break stuff
		mo.persona = personaList[tbl.persona]
		mo.persona.anim_idle = {SPR_NULL, A, 1}
		mo.persona.anim_atk = {SPR_NULL, A, 1}
	end

	if tbl.anim_evoker
		mo.anim_evoker = tbl.anim_evoker
	else
		mo.anim_evoker = tbl.anim_stand
	end

	if tbl.skin
		mo.skin = tbl.skin
	end

	if tbl.hudcutin
		mo.hudcutin = tbl.hudcutin
	else
		mo.hudcutin = nil
	end

	if tbl.hudscutin
		mo.hudscutin = tbl.hudscutin
	else
		mo.hudscutin = nil
	end

	if tbl.color
		mo.color = tbl.color
	else
		mo.color = SKINCOLOR_GREEN
	end

	for i = 1, 32
		if tbl["anim_special"..i]
			mo["anim_special"..i] = tbl["anim_special"..i]
		else
			mo["anim_special"..i] = {SPR_PLAY, A, 1}
		end
	end

	ANIM_set(mo, mo.anim_stand, true)
end)

rawset(_G, "BTL_initEnemy", function(mo)
	local enemy = enemyList[mo.enemy]
	if not enemy
		print("Could not initiate enemy '"..mo.enemy.."', defaulting to Cowardly Maya")
		mo.enemy = "maya_1"
		enemy = enemyList["maya_1"]
	end

	-- create entry for saved affinity table if it doesn't exist
	if not server.P_BattleStatus[mo.battlen].saved_affs[mo.enemy]
		server.P_BattleStatus[mo.battlen].saved_affs[mo.enemy] = {0, 0, false}	-- attack affs, moves, beaten?
		-- search for existing affinities to see if we can find an enemy of the same name...
		for k, v in pairs(server.P_BattleStatus[mo.battlen].saved_affs)
			if enemyList[v]
			and enemyList[v].name == enemyList[mo.enemy].name
				server.P_BattleStatus[mo.battlen].saved_affs[mo.enemy] = server.P_BattleStatus[mo.battlen].saved_affs[v]
				break
			end
		end
	end

	mo.level = enemy.level
	mo.maxhp, mo.hp = enemy.hp, enemy.hp
	mo.maxsp, mo.sp = enemy.sp, enemy.sp
	mo.skills = enemy.skills
	mo.strength, mo.magic, mo.endurance, mo.agility, mo.luck = enemy.strength, enemy.magic, enemy.endurance, enemy.agility, enemy.luck
	mo.name = enemy.name
	mo.weak = enemy.weak or 0
	mo.repel = enemy.repel or 0
	mo.resist = enemy.resist or 0
	mo.block = enemy.block or 0
	mo.drain = enemy.drain or 0
	mo.thinker = enemy.thinker ~= nil	-- don't save the thinker in there!!!
	mo.boss = enemy.boss or false
	mo.endboss = enemy.finalboss or (enemy.endboss and not server.marathon) or false
	mo.turns = enemy.turns or 1
	mo.thinkframe = enemy.thinkframe ~= nil
	mo.deathanim = enemy.deathanim ~= nil

	mo.target_zoffs = enemy.target_zoffs or 0

	if server.gamemode == GM_CHALLENGE
		mo.endboss = false
	end	-- No endboss property in challenge mode.

	mo.skillchance = enemy.skillchance
	if mo.skillchance == nil	-- allow 0% ?
		mo.skillchance = 50
	end

	mo.escale = enemy.scale or FRACUNIT

	mo.atk = enemy.atk or 30 + (difficulty_atk[server.difficulty] or 0)
	mo.acc = enemy.acc or 85
	mo.crit = enemy.crit or 3

	BTL_initEnemyAnims(mo)
	BTL_readybuffs(mo)

	mo.melee = enemy.melee_natk

	SRB2P_runHook("EnemyInit", mo)

	return true
end)

rawset(_G, "BTL_logMessage", function(pn, message)
	local btl = server.P_BattleStatus[pn]
	if not btl
		dprint("WARNING: Error trying to print "..(message or pn))
		return
	end

	btl.console = message
	btl.console_time = TICRATE*2
end)

rawset(_G, "BTL_handleLog", function(pn)
	local btl = server.P_BattleStatus[pn]
	if btl.console_time
		btl.console_time = $-1
		if not btl.console_time
			btl.console = nil
		end
	end
end)

-- battle persona thinker:
rawset(_G, "battlePersonaThinker", function(ps)
	if not ps or not ps.valid return end

	if not ps.target or not ps.target.valid return end
	local mo = ps.target

	-- force sprite and tics
	--ps.sprite = mo.persona.sprite
	--mo.summonpersona.tics = -1

	-- update anim:
	if not ps.anim
		ANIM_set(ps, mo.persona.anim_idle,true)
	end
	ANIM_handle(ps)

	-- update position to our tagret

	local x, y = mo.x - 64*cos(mo.angle), mo.y - 64*sin(mo.angle)
	P_TeleportMove(ps, x, y, mo.z+ mo.scale*64)

	ps.angle = mo.angle -ANG1*10
	-- ^ offset angle so it displays the 3/4 view by default which is always super cool

	-- do stuff depending on state

	if not ps.p_state	-- no p_state: idle. we've just been summoned and haven't materialized yet
		if ps.anim ~= mo.persona.anim_idle
			ANIM_set(ps, mo.persona.anim_idle, true)
		end

		local trflag = FF_TRANS50 + (2*cos(leveltime*ANG1*10)/FRACUNIT)<<FF_TRANSSHIFT
		ps.frame = ($ & ~FF_TRANSMASK)|trflag

	elseif ps.p_state < 0	-- state < 0, we must disappear and die

		if ps.savetr == nil
			ps.savetr = ps.frame & FF_TRANSMASK
			ps.trtime = 0
		end

		ps.trtime = $+1
		ps.frame = ($ & ~FF_TRANSMASK)|min(FF_TRANS90, (ps.savetr + FF_TRANS10*ps.trtime))

		if ps.frame & FF_TRANSMASK == FF_TRANS90
			mo.summonpersona = nil
			P_RemoveMobj(ps)
			return
		end
	else	-- materialize. If the attack animation ends, dematerialize however

		if ps.savetr == nil
			ps.savetr = ps.frame & FF_TRANSMASK
			ps.trtime = 0
		end

		if ps.frame & FF_TRANSMASK
			ps.trtime = $+1
			ps.frame = ($ & ~FF_TRANSMASK)|(ps.savetr - FF_TRANS10*ps.trtime)
		end

		if ANIM_done(ps, mo.persona.anim_atk)
			ps.savetr = nil
			ps.p_state = -1
			return
		end
	end
end)
addHook("MobjThinker", battlePersonaThinker, MT_BTL_PERSONA)

-- split skills between battle skills and passive skills
rawset(_G, "BTL_splitSkills", function(v)
	v.passiveskills = {}
	local tmp_skill = {}

	for i = 1, #v.skills
		local s = v.skills[i]
		local implicit_count = 0

		if s and attackDefs[s]

			-- Add implicit skills (Passive & normal...)
			local im = s
			while attackDefs[im].implicit and implicit_count < 8	-- Max 8 implicit skills to avoid endless loops
				implicit_count = $+1

				local is = attackDefs[im].implicit
				local isdef = attackDefs[is]

				if is
					--print("Implicit: "..is)
					if isdef.type & ATK_PASSIVE
						v.passiveskills[#v.passiveskills+1] = is
					else
						tmp_skill[#tmp_skill+1] = is
					end

					im = is
				end
			end

			if attackDefs[s].type & ATK_PASSIVE	-- skill is passive
				v.passiveskills[#v.passiveskills+1] = s
				--dprint("passive skill: "..s)
			else

				-- is skill elligible in PVP? (keep them all in boss mode, it's fair game)
				if server.gamemode == GM_PVP and not server.bossmode
				and attackDefs[s]
					if attackDefs[s].target == TGT_CASTER	-- mind charge, power charge
					or attackDefs[s].target == TGT_DEAD		-- recarm, ...
					or attackDefs[s].luckbased and attackDefs[s].target == TGT_ALLENEMIES
						dprint("Skill "..s.." deemed too much bullshit for PVP, not adding")
						continue
					end
				end

				tmp_skill[#tmp_skill+1] = s
				--dprint("skill: "..s)
			end
		end
	end

	v.skills = copyTable(tmp_skill)
	table.sort(v.skills, attackSortFunc)
	-- free some memory:
	tmp_skill = nil
end)

-- intiate additonal skills from sub personas and skill cards in this order.
rawset(_G, "BTL_initAdditionalSkills", function(v, subpbonus)
	if not v.saveskills
		print("\x82".."WARNING: ".."\x80".."No saved skill list available.")
		return
	end
	v.skills = copyTable(v.saveskills)

	-- add skills from subpersonas, make sure we don't already have it though
	if subpbonus
		local subp = v.subpersona

		for i = 1, #subp.skills
			local addskill = true
			for j = 1, #v.skills
				if subp.skills[i] == v.skills[j]	-- duplicate...
					addskill = false
					break
				end
			end
			if addskill
				v.skills[#v.skills+1] = subp.skills[i]
			end
		end
	end

	-- add skills from the skillcard:
	if v.skillcard
		-- check if the skillcard isn't a duplicate before adding it
		-- use the full skill list for that
		local addskill = true

		for i = 1, #v.skills
			if v.skills[i] == v.skillcard	-- we already have that skill!
				addskill = false
				break -- just leave
			end
		end

		if addskill
			-- no duplicates? Add the skill at the bottom of our list
			v.skills[#v.skills+1] = v.skillcard
		end
	end

	if v.weapon
	and v.weapon.level >= 10

		local addskill = true

		for i = 1, #v.skills do
			if v.skills[i] == v.weapon.slot
				addskill = false
				break
			end
		end

		if addskill
			v.skills[#v.skills+1] = v.weapon.slot
		end
	end

	if v.wardring
	and v.wardring.level >= 10

		local addskill = true

		for i = 1, #v.skills do
			if v.skills[i] == v.wardring.slot
				addskill = false
				break
			end
		end

		if addskill
			v.skills[#v.skills+1] = v.wardring.slot
		end
	end

	-- finally, add emerald skills to the bottom of our list

	if server.gamemode ~= GM_COOP
		return	-- No emerald skills outside of coop
	end

	local btl = server.P_BattleStatus[v.battlen]
	if btl.emeraldpow_max and not v.enemy	-- obviously, only players may get access to those
		for i = 1, btl.emeraldpow_max
			if BTL_EmeraldSkills[i]	-- there may be no skill (hear: the 1st emerald)

				local dupe
				for j = 1, #v.skills
					if v.skills[j] == BTL_EmeraldSkills[i]
						dupe = true
						break
					end
				end
				-- Don't add a same skill twice!
				if dupe
					continue
				end

				v.skills[#v.skills+1] = BTL_EmeraldSkills[i]
			end
		end
	end
end)

-- set up stats and adds atat bonuses from subpersonas too
rawset(_G, "BTL_setupstats", function(v, subpbonus)
	if not v.savestats return end

	v.strength = v.savestats[1]
	v.magic = v.savestats[2]
	v.endurance = v.savestats[3]
	v.agility = v.savestats[4]
	v.luck = v.savestats[5]

	if not subpbonus return end

	local subp = v.subpersona
	if subp

		v.strength = max(1, $ + subp.st)
		v.magic = max(1, $ + subp.ma)
		v.endurance = max(1, $ + subp.en)
		v.agility = max(1, $ + subp.ag)
		v.luck = max(1, $ + subp.lu)
	end
end)

-- equips a subpersona
rawset(_G, "BTL_equipSubPersona", function(mo, subp)

	if mo.subpersona	-- unequip current subpersona if we had one
		--print("Subp "..mo.subpersona.name.." unequipped")
		mo.subpersona.equipped = nil
		mo.subpersona = nil
	end

	mo.subpersona = subp	-- for starters, this
	--print("Subp "..mo.subpersona.name.." equipped.")
	BTL_setupstats(mo, true)	-- set up our stats
	BTL_initAdditionalSkills(mo, true)	-- set up skills
	BTL_splitSkills(mo)	-- split passives from normal skills

	if not subp.level	-- cleanse subpersona if it's a non existant one.
		mo.subpersona = nil
	else
		-- equip it
		for i = 1, #server.plentities[mo.control.P_party]
			if server.plentities[mo.control.P_party][i] == mo
				subp.equipped = i
			end
		end
	end
end)

-- add mo's control to the plist if possible
rawset(_G, "BTL_addtoplist", function(btl, mo)
	if mo and mo.valid and mo.control and mo.control.valid

		-- check for dupes
		local dupe
		for i = 1, #btl.plist
			if btl.plist[i] == mo.control
				dupe = true
				break
			end
		end

		if not dupe
			btl.plist[#btl.plist+1] = mo.control
		end
	end
end)

rawset(_G, "BTL_StartBattle", function(pn, team1, team2, advantage, func, music, p1)	-- teams can be anything lol.
	local battleStatus = server.P_BattleStatus[pn]
	local bossbuf = battleStatus.boss

	BTL_softReset(pn)	-- ust i case

	battleStatus.boss = bossbuf

	-- if normalbattle is true, team2 will spawn like enemies and the camera will do preset stuff while BST_START is here.
	-- else you're free to tp the camera anywhere after calling this function
	battleStatus.running = true			-- battle is now running
	battleStatus.battletime = 0
	battleStatus.battlestate = 0
	battleStatus.emeraldpow_max = (server.cdungeon and server.cdungeon.maxep or server.difficulty)
	battleStatus.turn = 0
	battleStatus.turnorder = {}
	battleStatus.crit_seeds = {}
	battleStatus.deadplayers = {}
	battleStatus.battlestate = BS_START
	battleStatus.hudtimer.start = TICRATE*((advantage or battleStatus.boss) and 3 or 1) -- start transition
	battleStatus.advantage = advantage		-- advantage, stored here for animations and whatnot

	if battleStatus.func_buf	-- function buffer, used for some very specific instances (tutorial)
		battleStatus.func = battleStatus.func_buf
		battleStatus.func_buf = nil
	else
		battleStatus.func = func				-- used for starting events and other stuff, called at the start of each turn
	end

	battleStatus.music = music	-- save this

	battleStatus.refplayer = team1[1]	-- useful for dead players revival

	battleStatus.netstats.encounters = $ +1
	battleStatus.arena_coords[4] = $ or 0	-- angle, mostly unused

	D_endEvent(pn)

	if battleStatus.arenacenter and battleStatus.arenacenter.valid
		battleStatus.arena_coords[1] = battleStatus.arenacenter.x
		battleStatus.arena_coords[2] = battleStatus.arenacenter.y
		battleStatus.arena_coords[3] = battleStatus.arenacenter.z
		battleStatus.arena_coords[4] = battleStatus.arenacenter.angle
	end

	if server.gamemode == GM_CHALLENGE
		battleStatus.challengen = server.P_netstat.buffer.extradata
		battleStatus.timer = BTL_challengebtllist[battleStatus.challengen].time
		--battleStatus.scoretarget = BTL_challengebtllist[battleStatus.challengen].points
		--battleStatus.score = 0
		battleStatus.waven = $ or 1
	end

	local x, y, z = battleStatus.arena_coords[1], battleStatus.arena_coords[2], battleStatus.arena_coords[3]
	local dist = 256
	local currangle = battleStatus.arena_coords[4]

	local cam = battleStatus.cam
	if cam
		P_RemoveMobj(cam)
	end
	battleStatus.cam = spawnbattlecam()
	cam = battleStatus.cam

	P_TeleportMove(cam, x, y, z)
	CAM_stop(cam)
	cam.angle = currangle + ANG1*180

	local temp_an = currangle

	for k,v in ipairs(team1)	-- spawn team1 (generally players row)
		x, y = battleStatus.arena_coords[1]+dist*cos(currangle), battleStatus.arena_coords[2]+dist*sin(currangle)
		P_TeleportMove(v, x, y, z)	-- Teleport the object to the right spot.
		v.angle = currangle+ANGLE_180
		--if k <= 3
		currangle = $- (ANG1*30)
		v.shadowscale = v.scale
		--end

		v.battlen = pn	-- save which arena we're on

		-- special case for some cool stuff :)
		if battleStatus.superform
			v.status_condition = COND_SUPER
			local stats = {"strength", "magic", "endurance", "agility", "luck"}
			for i = 1, #stats do
				v[stats[i]] = $+25
			end
		end

		if v.enemy
			if not BTL_initEnemy(v)	-- this would be very unexpected.
				dprint("Failed to generate enemy "..v.enemy)
				P_RemoveMobj(v.enemy)
				updateUDtable(team1)
				continue
			end

			if v.gold
				v.expval = enemyList[v.enemy].r_exp *2
				v.enemy = "maya_gold"

				-- restart the enemy generation...
				if not BTL_initEnemy(v)	-- this would be very unexpected.
					dprint("Failed to generate enemy "..v.enemy)
					P_RemoveMobj(v.enemy)
					updateUDtable(team1)
					continue
				end

				if server.gamemode == GM_COOP and server.difficulty

					local stats_diff = {
						11,
						22,
						33,
						55,
						88,
						99,
						99,
					}

					local st = stats_diff[server.difficulty] or 99
					print(st)
					v.agility = st
					v.luck = st
				end
			end


			if v.extra
				v.status_condition = COND_HYPER
				local stats = {"strength", "magic", "endurance", "agility", "luck"}
				for i = 1, #stats do
					v[stats[i]] = $+10
				end
			end

		end

		v.enemies = copyTable(team2)
		v.allies = copyTable(team1)
		v.allies_noupdate = copyTable(team1)	-- this table doesn't update, we use it for HUD displaying (players hp bars)
		v.enemies_noupdate = copyTable(team2)	-- this table doesn't update, we use it for reviving
		v.saveskills = copyTable(v.skills)		-- for skill cards and sub persona reverting
		if v.plyr
			PLYR_getStats(v, v.level, true)
		end
		v.savestats = {v.strength, v.magic, v.endurance, v.agility, v.luck}	-- back up stats
		v.flags2 = $ & ~MF2_DONTDRAW
		ANIM_set(v, v.anim_stand, true)
		BTL_initAdditionalSkills(v)
		BTL_setupstats(v)

		-- finally equip the subpersona
		if v.subpersona
			BTL_equipSubPersona(v, v.subpersona)
		else
			BTL_splitSkills(v)
		end

		battleStatus.fighters[#battleStatus.fighters+1] = v
		BTL_addtoplist(battleStatus, v)

		-- check for PSV_STARTBATTLE skills and execute them!

		for i = 1, #v.passiveskills
			local psv = v.passiveskills[i]
			if attackDefs[psv]
				psv = attackDefs[$]
				if psv.passive == PSV_STARTBATTLE
				and psv.anim
					psv.anim(v, {v}, {v}, 1)	-- Execute this skill's anim function on myself ONCE.
				end
			end
		end

		if advantage == 1	-- team 1 has the advantage!
			v.priority = 16
		else
			v.priority = 0
		end
	end

	currangle = temp_an + ANG1*180 --ANGLE_180+ANGLE_90+ANG1*20

	for k,v in ipairs(team2)	-- spawn team2 (generally enemies row)
		x, y = battleStatus.arena_coords[1]+dist*cos(currangle), battleStatus.arena_coords[2]+dist*sin(currangle)
		P_TeleportMove(v, x, y, z)	-- Teleport the object to the right spot.
		v.angle = currangle+ANGLE_180
		--if k <= 3
		currangle = $- (ANG1*30)
		v.shadowscale = v.scale
		--else
			--currangle = ANG1*154
		--end

		v.battlen = pn	-- save which arena we're on

		if v.enemy	-- enemy stat initialization
			if not BTL_initEnemy(v)
				dprint("Failed to generate enemy "..v.enemy)
				P_RemoveMobj(v)
				updateUDtable(team1)
				continue
			end

			if v.extra
				v.status_condition = COND_HYPER
				local stats = {"strength", "magic", "endurance", "agility", "luck"}
				for i = 1, #stats do
					v[stats[i]] = $+10
				end
			end

			if v.gold
				v.expval = enemyList[v.enemy].r_exp *4
				v.enemy = "maya_gold"

				-- restart the enemy generation to make a gold shadow.
				if not BTL_initEnemy(v)
					dprint("Failed to generate enemy "..v.enemy)
					P_RemoveMobj(v.enemy)
					updateUDtable(team1)
					continue
				end


				if server.gamemode == GM_COOP and server.difficulty

					local stats_diff = {
						11,
						22,
						33,
						55,
						88,
						99,
						99,
					}

					local st = stats_diff[server.difficulty] or 99
					v.agility = st
					v.luck = st
				end
				
			end
		end

		v.enemies = copyTable(team1)
		v.allies = copyTable(team2)
		v.allies_noupdate = copyTable(team2)
		v.enemies_noupdate = copyTable(team1)	-- this table doesn't update, we use it for reviving
		v.saveskills = copyTable(v.skills)	-- you never know
		v.savestats = {v.strength, v.magic, v.endurance, v.agility, v.luck}	-- back up stats
		BTL_initAdditionalSkills(v)
		BTL_setupstats(v)

		-- in battle, we cannot use passive skills
		BTL_splitSkills(v)
		v.flags2 = $ & ~MF2_DONTDRAW

		-- rather unlikely
		if v.subpersona
			BTL_equipSubPersona(v, v.subpersona)
		end

		for i = 1, #v.passiveskills
			local psv = v.passiveskills[i]
			if attackDefs[psv]
				psv = attackDefs[$]
				if psv.passive == PSV_STARTBATTLE
				and psv.anim
					psv.anim(v, {v}, {v}, 1)	-- Execute this skill's anim function on myself ONCE.
				end
			end
		end

		if server.gamemode ~= GM_PVP
			v.sprite = SPR_ENMA
			v.frame = A
		end

		if advantage == 2	-- team 2 has the advantage!
		and not bossbuf
			v.priority = 16
		else
			v.priority = 0
		end

		if advantage~= nil
		and advantage < 3	-- specific to team2. This makes them invisible and then pop up like bad guys!
							-- this is handled later on in the BS_START handler.
			battleStatus.starttype = 0
			v.enemy_spawndelay = TICRATE*2 + (TICRATE/6)*k
			if k == 1
				P_TeleportMove(cam, v.x + 10*cos(v.angle), v.y + 10*sin(v.angle), v.z)
				cam.aiming = -ANG1*60
			end
		end
		battleStatus.fighters[#battleStatus.fighters+1] = v
		BTL_addtoplist(battleStatus, v)
	end

	if battleStatus.boss
		battleStatus.advantage = 2	-- weird hack, alright
	end

	-- I was about to forget...
	for i = 1, #battleStatus.plist do
		local p = battleStatus.plist[i]
		if not p or not p.valid continue end
		S_StartSound(nil, sfx_battle, p)	-- IT'S TIME!
		if server.gamemode ~= GM_VOIDRUN
			S_StopMusic(p)
		end
	end

	-- pvp: make the camera start differently from how it does in regular pve battles
	if server.gamemode == GM_PVP
		local dist = 1024
		local currangle = P_RandomRange(0, 359)*ANG1
		local x, y = battleStatus.arena_coords[1]+dist*cos(currangle), battleStatus.arena_coords[2]+dist*sin(currangle)
		P_TeleportMove(cam, x, y, 224*FRACUNIT)
		cam.aiming = ANG1*5
		cam.angle = R_PointToAngle2(cam.x, cam.y, battleStatus.arena_coords[1], battleStatus.arena_coords[2])

		x, y = battleStatus.arena_coords[1]+dist*2*cos(currangle), battleStatus.arena_coords[2]+dist*2*sin(currangle)
		CAM_goto(cam, x, y, 512*FRACUNIT, FRACUNIT/2)
	end

	SRB2P_runHook("BattleStart", battleStatus)
end)

rawset(_G, "BTL_mainHandler", function(pn)
	local battle = server.P_BattleStatus[pn]

	-- lua hook
	SRB2P_runHook("BattleThinker", battle)

	battle.battletime = $+1

	if server.gamemode == GM_CHALLENGE
	and battle.battlestate ~= BS_CHALLENGEEND	-- don't decrement if you won

		local mo = battle.turnorder[1]

		-- disable tactics:
		if mo and mo.valid and mo.commandflags ~= nil
			mo.commandflags = $|CDENY_TACTICS
		end

		battle.timer = max(0, $-1)

		if battle.addscore
			battle.addscorewait = $ and $-1 or 0
			if not battle.addscorewait

				local pts = battle.addscore
				local nowpts = battle.addscore/2

				battle.score = $ + (pts - nowpts)
				battle.addscore = nowpts
				for k, p in pairs(battle.plist)
					S_StartSound(nil, sfx_menu1, p)
				end
			end
		end
	end

	if server.gamemode == GM_PVP
		if battle.turnorder[1] and battle.turnorder[1].valid
			local mo = battle.turnorder[1]

			-- disable tactics:
			mo.commandflags = $|CDENY_TACTICS

			if battle.firstact ~= mo.party
				--dprint("initiating item swapping between PVP parties...")
				-- replace btl.items with btl.items2 and vice-versa
				local dummytable = {}
				-- step 1: save to dummy table
				for i = 1, #battle.items
					dummytable[i] = {}
					dummytable[i][1] = battle.items[i][1]
					dummytable[i][2] = battle.items[i][2]
				end

				-- step 2: transfer
				battle.items = battle.items2
				battle.items2 = dummytable

				battle.firstact = mo.party
				BTL_sortItems(battle)
				--dprint("swap succesful!")
			end
		end
	end
	-- plist maintenance:
	local i = #battle.plist
	while i
		if not battle.plist[i] or not battle.plist[i].valid
			table.remove(battle.plist, i)
		end
		i = $-1
	end

	-- advantage sfx
	for k, p in ipairs(battle.plist)
		if not p or not p.valid continue end
		if battle.battletime == TICRATE/2 and battle.advantage
			S_StartSound(nil, sfx_aoado, p)
		end
	end

	-- start music
	if server.gamemode ~= GM_VOIDRUN
		for k, p in ipairs(battle.plist)
			if not p or not p.valid continue end
			if battle.battletime == TICRATE*3/2
				local music = battle.music or "BATL1"
				S_ChangeMusic(music, true, p)
			end
		end
	else	-- In voidrun...

		-- boss score:
		local dng = server.P_DungeonStatus

		if dng.VR_type == VC_BOSS	-- boss event

			-- find the boss, and then set our score relative to how low its HP is
			local boss = server.plentities[battle.n][1].enemies[1]

			if boss and boss.valid
				dng.VR_target = boss.maxhp
				dng.VR_score = boss.maxhp - boss.hp
			end
		end
	end

	if battle.transition then battle.transition = $-1 end
	for i = 1, #battle.plist do
		local p = battle.plist[i]
		if not p or not p.valid continue end
		p.mo.momx , p.mo.momy, p.mo.momz = 0, 0, 0
		PLAY_nomove(p)

		if not battle.cam or not battle.cam.valid continue end
		-- You would think the above never happens.
		-- However the battle cam gets removed after level ups for a smooth transition:
		-- the battle is still 'running' as the hud fades away, or something

		if battle.hudtimer and battle.hudtimer.start and battle.hudtimer.start > 25 + (battle.advantage and TICRATE*2 or 0) break end
		p.awayviewmobj = battle.cam
		p.awayviewtics = 4
		p.awayviewaiming = battle.cam.aiming or 0
		p.pflags = $|PF_FORCESTRAFE
	end
	-- handle hud animation timer
	for k,v in pairs(battle.hudtimer)
		battle.hudtimer[k] = max(0, $-1)
	end

	BTL_handleLog(pn)

	if not battle.emeraldpow_max return end

	local hypercount = 0

	-- handle fighters and tables.
	for k,v in ipairs(battle.fighters)
		if not v.valid	-- remove any entity that's disappeared.
			table.remove(battle.fighters, k)
			continue
		else
			if v.status_condition and v.status_condition >= COND_HYPER and v.plyr
				hypercount = $+1
			end
		end
	end

	if not hypercount
		battle.emeraldpow_buffer = nil	-- remove visual effect
	end
	-- level visal stuff + sound

	if battle.emeraldpow_lvbuf ~= battle.emeraldpow / 100
		if battle.emeraldpow_lvbuf < battle.emeraldpow / 100
			playSound(pn, sfx_hyprc)
			battle.hudtimer.emeraldlvup = TICRATE
		end
		battle.emeraldpow_lvbuf = battle.emeraldpow/100
	end
end)

rawset(_G, "BTL_BuildTurnOrder_PVP", function(pn)

	local btl = server.P_BattleStatus[pn]
	btl.turn = $+1

	local dummytable = {}
	local turnorder = {}
	local maxspeed = -1000
	local removekey
	local addwho

	local pnum = P_RandomRange(1, 2)	-- no jealousy~

	for k,v in ipairs(btl.fighters)
		if not v or not v.valid return end

		if simulate
			v.saveacted = v.acted
			v.saveturnset = v.turnset
		end

		v.acted = nil	-- new turn, new chance
		v.turnset = nil

		if v.status_condition == COND_FREEZE
			v.priority = -2	-- frozen fighters act last!
		end

		dummytable[#dummytable+1] = v
	end

	repeat

		while not addwho

			for i = 1, #dummytable do
				local v = dummytable[i]

				if v and v.valid and v.agility + (v.priority or 0)*100 > maxspeed
				and v.party == pnum
					maxspeed = v.agility + (v.priority or 0)*100
					addwho = v
					removekey = i
				end
			end

			pnum = (pnum == 2) and 1 or 2
		end

		if addwho
			local instances = 1

			if addwho.turns and not simulate
				instances = max(1, addwho.turns)
			end

			for i = 1, instances do
				turnorder[#turnorder+1] = addwho
			end
			table.remove(dummytable, removekey)
			maxspeed = -1000
			removekey = 0
			addwho = nil
			--print(pnum)
		end
	until not #dummytable

	-- kill priority:
	for i = 1, #turnorder
		turnorder[i].priority = 0
	end


	if simulate
		for k,v in ipairs(btl.fighters)
			if not v or not v.valid return end

			v.acted = v.saveacted
			v.turnset = v.saveturnset
			v.saveacted = nil
			v.saveturnset = nil
		end
	end

	return turnorder
end)

rawset(_G, "BTL_BuildTurnOrder", function(pn, simulate)
	--dprint("PN "..pn..": Building turn order...")

	if SRB2P_runHook("BattleTurnOrder", battle) return end

	if server.gamemode == GM_PVP
		return BTL_BuildTurnOrder_PVP(pn)
	end

	local btl = server.P_BattleStatus[pn]
	btl.turn = $+1

	local dummytable = {}
	local turnorder = {}
	local maxspeed = -1000
	local removekey = 1
	local addwho = btl.fighters[1]

	for k,v in ipairs(btl.fighters)
		if not v or not v.valid return end

		if simulate
			v.saveacted = v.acted
			v.saveturnset = v.turnset
		end

		v.acted = nil	-- new turn, new chance
		v.turnset = nil

		if v.status_condition == COND_FREEZE
			v.priority = -2	-- frozen fighters act last!
		end

		dummytable[#dummytable+1] = v
	end

	repeat
		for i = 1, #dummytable do
			local v = dummytable[i]

			if v and v.valid and v.agility + (v.priority or 0)*100 > maxspeed
				maxspeed = v.agility + (v.priority or 0)*100
				addwho = v
				removekey = i
			end
		end

		if addwho
			local instances = 1

			if addwho.turns and not simulate
				instances = max(1, addwho.turns)
			end

			for i = 1, instances do
				turnorder[#turnorder+1] = addwho
			end
			table.remove(dummytable, removekey)
			maxspeed = -1000
			removekey = 0
			addwho = nil
		end
	until not #dummytable

	-- kill priority:
	for i = 1, #turnorder
		turnorder[i].priority = 0
	end

	if simulate
		for k,v in ipairs(btl.fighters)
			if not v or not v.valid return end

			v.acted = v.saveacted
			v.turnset = v.saveturnset
			v.saveacted = nil
			v.saveturnset = nil
		end
	end

	return turnorder
end)

rawset(_G, "BTL_startHandler", function(pn, func)	-- make the battle start!
												-- not very optimized but this doesn't necessarily matter.
	local battle = server.P_BattleStatus[pn]
	-- how do we start the battle?

	if server.gamemode == GM_PVP
		if battle.battletime == TICRATE*3
			CAM_stop(battle.cam)
			battle.turnorder = BTL_BuildTurnOrder(pn)
			battle.cam.goto = {}
			battle.cam.momx = 0
			battle.cam.momy = 0
			battle.cam.momz = 0
			local x,y,z,an,ai = CAM_defaultcoords(battle.turnorder[1])
			CAM_goto(battle.cam, x, y, z)
			CAM_angle(battle.cam, an)
			CAM_aiming(battle.cam, ai)
			return true
		end
		return
	end

	if battle.starttype == 0	-- generally how most battles start, ambush or no adv
		if battle.battletime == TICRATE*2-10

			local x,y,z,an,ai = CAM_defaultcoords(battle.fighters[1])
			CAM_goto(battle.cam, x, y, z)
			CAM_angle(battle.cam, an)
			CAM_aiming(battle.cam, ai)
		end

		-- spawn enemies
		if not battle.fighters[1] or not battle.fighters[1].valid then return end
		for k,v in ipairs(battle.fighters[1].enemies)

			if not v.valid continue end
			if not v.enemy continue end

			if v.enemy_spawndelay
				v.anim = nil	-- don't set the state :P
				v.enemy_spawndelay = $-1
				--v.flags2 = $|MF2_DONTDRAW	-- magical
				if not v.enemy_spawndelay
					v.scale = v.escale
					ANIM_set(v, v.anim_stand, true)
					v.enemy_spawndelay = nil

					for i = 1, 128
						local color = SKINCOLOR_RED
						if i%2 color = SKINCOLOR_BLACK end

						local x, y, z = v.x+P_RandomRange(-50, 50)*FRACUNIT, v.y+P_RandomRange(-50, 50)*FRACUNIT, v.z+P_RandomRange(-50, 50)*FRACUNIT
						local particle = P_SpawnMobj(x, y, z, MT_DUMMY)
						particle.color = color
						particle.frame = A
						particle.tics = 100
						particle.destscale = 0
						particle.momz = P_RandomRange(1, 10)*FRACUNIT
					end
				end
			end
		end

		if battle.battletime == TICRATE*3 + TICRATE/2
			return true
		end
	end
end)

rawset(_G, "resetEntitiesPositions", function(pn)
	--dprint("Reseting battle entities coordinates...")
	local battle = server.P_BattleStatus[pn]
	for i = 1, #battle.fighters
		battle.crit_seeds[i] = P_RandomRange(0, 100)
		battle.evasion_seeds[i] = P_RandomRange(0, 100)

		-- set teleport points / teleport objects back to their intended positions.

		local e = battle.fighters[i]
		if not e or not e.valid continue end
		if not e.defaultcoords
			e.defaultcoords = {e.x, e.y, e.z, e.angle}
		else
			P_TeleportMove(e, e.defaultcoords[1], e.defaultcoords[2], e.z)	-- useful after physical attacks / dying from repel etc
			if e.defaultcoords[4] ~= nil
				e.angle = e.defaultcoords[4]
			end	-- just in case since i'm not sure if it's always set...
		end
		e.attack = nil
		P_InstaThrust(e, 0, 0)

		if e.plyr
		and e.hp > 0	-- Don't change that if you're dead already.
			e.state = S_PLAY_STND	-- reset state
		end
		e.anim = nil
		ANIM_set(e, e.down and e.anim_downloop or e.guard and e.anim_guard or e.anim_stand, true)

		if e.hp <= 0
		and not e.extra	-- these guys will blow up, don't kill em yet
			-- dead
			e.flags2 = $|MF2_DONTDRAW
			if e.status_condition
				cureStatus(e)
				e.status_condition = nil
				e.status_turns = 0	-- just in case
			end
		end
	end
end)

rawset(_G, "BTL_resetPlayerMenu", function(mo)

	local battle = server.P_BattleStatus[mo.battlen]

	mo.t_hidehud = true
	battle.hudtimer.newturn = TICRATE*69
	-- ^ used to make sure the menu doesn't pop for a while if we don't want it to.

	mo.commandflags = $ or 0	-- disable / deny commands.

	-- setup hud stuff if not done yet:
	mo.t_act = ACT_NONE
	mo.t_command = $ or 0
	mo.t_renderangle = 0	-- used for hud stuff.

	mo.t_target = 1	-- reset target
	mo.t_ctarget = 12	-- reset reticle animation

	mo.t_skillselect = $ or 1	-- skill selection
	mo.t_itemselect = $ or 1	-- item selection
	mo.t_selectslide = 0

	local p = mo.control
	if p and p.valid
		if not p.cursormemory	-- reset cursor

			mo.t_command = 0
			mo.t_skillselect = 1
			mo.t_itemselect = 1
		end
	end
end)

rawset(_G, "BTL_setupPlayerTurn", function(mo)
	if mo.control and not mo.turnset
		local battle = server.P_BattleStatus[mo.battlen]
		mo.t_hidehud = false

		mo.t_acttimer = nil
		if netgame
		and cv_turntimer.value
			mo.t_acttimer = max(TICRATE*15, cv_turntimer.value*TICRATE)	-- 15 seconds minimum or it's actually stupid
		end

		mo.acted = true	-- we've acted. this is used so baton pass can't give you your turn back
		mo.turnset = true	-- used to know how to reset the camera properly

		mo.itemname = nil	-- reset this

		if netgame
			local str = "It's "..mo.name
			if mo.displaycontrolname
				str = $.." ("..mo.control.name..") "
			end
			str = $.."'s turn"
			BTL_logMessage(mo.battlen, str)
		end
		ANIM_set(mo, mo.anim_stand, true)

		if mo.hp
			mo.flags2 = $ & ~MF2_DONTDRAW
		end

		-- ready HUD animation timer:
		battle.hudtimer.newturn = TICRATE/3
		--battle.transition = 6
		local x,y,z,an,ai = CAM_defaultcoords(mo)

		battle.cam.aiming = ai
		P_TeleportMove(battle.cam, x, y, z)

		-- fix the angle real quick
		local tx, ty = mo.enemies[mo.t_target or 1].x, mo.enemies[mo.t_target or 1].y
		tx = $+48*cos(mo.enemies[mo.t_target or 1].angle-ANGLE_90)
		ty = $+48*sin(mo.enemies[mo.t_target or 1].angle-ANGLE_90)

		an = R_PointToAngle2(battle.cam.x, battle.cam.y, tx, ty)
		battle.cam.angle = an
	end
end)

rawset(_G, "BTL_VRRevive", function(pn)

	local btl = server.P_BattleStatus[pn]
	btl.VR_revives = $ or {}

	if not btl.VR_revivecheck
	and server.plentities[pn]

		for i = 1, #server.plentities[pn] do
			local mo = server.plentities[pn][i]

			if mo.hp <= 0
				btl.VR_revives[#btl.VR_revives+1] = mo
				mo.VR_revivetimer = 1

				local cam = btl.cam
				local target = mo
				local an = ANG1* P_RandomRange(10, 35)
				local gox = target.x + 800*cos(target.angle+an)
				local goy = target.y + 800*sin(target.angle+an)
				P_TeleportMove(cam, gox, goy, target.z + FRACUNIT*80)	-- teleport the camera to a nice spot
				cam.angle = R_PointToAngle2(gox, goy, target.x, target.y)
				cam.aiming = ANG1*(-3)
				CAM_stop(cam)

			end
		end

		btl.VR_revivecheck = true
	end

	if #btl.VR_revives
		local unfinished
		for i = 1, #btl.VR_revives
			local mo = btl.VR_revives[i]

			mo.VR_revivetimer = $+1
			local t = mo.VR_revivetimer

			if t < 60
			and leveltime%3 == 0
				for j = 1, 32
					local s = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
					s.state = S_SSPK1
					P_InstaThrust(s, 360/32 *j *ANG1, FRACUNIT*40)
				end
			end

			if t > 20 and t < 60
				for j = 1, 32

					local s = P_SpawnMobj(mo.x + P_RandomRange(-96, 96)*mo.scale, mo.y + P_RandomRange(-96, 96)*mo.scale, mo.z, MT_DUMMY)
					s.state = S_SSPK1
					s.momz = mo.scale*32
				end
			end

			if t == 30
				playSound(mo.battlen, sfx_heal2)
				resetDamage(mo)
				mo.atk_hitby = BTL_copyAttackDefs(attackDefs["dummy"])
				revivePlayer(mo)
				ANIM_set(mo, mo.anim_stand)
				mo.flags2 = $ & ~MF2_DONTDRAW
				damageObject(mo, -mo.maxhp)
			end

			if t < 100
				unfinished = true
			end
		end

		return unfinished

	end
end)

rawset(_G, "BTL_preturnHandler", function(pn)		-- here, we do stuff with whoever's turn it is!
	local battle = server.P_BattleStatus[pn]

	-- mid battle event
	-- (after we build the turn order if necessary)

	if not battle.turnorder[1]

		-- Void run: if players died, revive them now!
		if server.gamemode == GM_VOIDRUN
			if BTL_VRRevive(pn) return end
		end

		battle.turnorder = BTL_BuildTurnOrder(pn)
	end

	battle.VR_revives = nil
	battle.VR_revivecheck = nil

	if battle.func
		battle.func(battle)
	end
	if D_eventHandler(pn) return end	-- cutscene running, don't proceed

	if battle.hudtimer.start == nil
		battle.hudtimer.start = TICRATE/3
	else
		battle.hudtimer.transition = 6
	end

	if not battle.turnorder return end
	local mo = battle.turnorder[1]
	if not mo or not mo.valid return end

	resetEntitiesPositions(pn)

	mo.t_passed_stat = 0	-- used to not lower the same stat twice
	mo.t_statstuff = 0	-- used for console messages
	mo.t_stattimer = 0	-- used for waiting between stat indications
	mo.t_passivestuff = 0	-- used for keeping track of what pre-turn passives triggered
	mo.t_passivebuffer = 0	-- buffer for keeping track of the current passive we're using
	mo.t_passivetimer = 0	-- used for keeping track of the current passive skill anim
	mo.turnset = nil

	mo.t_statustimer = 0	-- used for a select few status conditions that take effect right on the turn.
	mo.t_hidehud = 0

	-- menu init
	if mo.plyr
		BTL_resetPlayerMenu(mo)
	end

	-- remove guard
	ANIM_set(mo, mo.anim_stand, true)
	mo.guard = nil
	mo.t_norun = nil	-- remove the runaway thing

	-- note: menu player init stuff is now handled at the top of the battle input func

	-- hooks
	SRB2P_runHook("NextTurn", mo)

	return true
end)

-- This function allows the player to select their target, to be ran whenever the player should be able to select target with left/right.
-- if not ran, target doesn't update.
rawset(_G, "BTL_handletargetselection", function(mo)

	if not mo.targets return end
	local maxt = #mo.targets

	if mo.t_ctarget then mo.t_ctarget = $-1 end	-- used for animation handler
	if not mo.t_cmem
		mo.t_cmem = {1, 1}	-- cursor mem for enemy, ally
	end

	if mo.attack and (mo.attack.target == TGT_ALLENEMIES or mo.attack.target == TGT_ALLALLIES or mo.attack.target == TGT_EVERYONE)
	or maxt == 1	-- there's only one dude...
	return end		-- in this case, all enemies are targetted, so don't take input into account
	local inputs = mo.control.mo.P_inputs

	if inputs["left"] == 1
		mo.t_target = $-1
		if not mo.t_target
			mo.t_target = maxt
		end
		mo.t_ctarget = 12
		playSound(mo.battlen, sfx_hover, mo)
	elseif inputs["right"] == 1
		mo.t_target = $+1
		if mo.t_target > maxt
			mo.t_target = 1
		end
		mo.t_ctarget = 12
		playSound(mo.battlen, sfx_hover, mo)
	end

	-- update cmem
	-- regardless of cursormemory because this is too big of a QoL change

	if mo.attack.target == TGT_ENEMY
		mo.t_cmem[1] = mo.t_target
	elseif mo.attack.target == TGT_ALLY
		mo.t_cmem[2] = mo.t_target
	end
end)

-- function to call when switching skills to auto update target selection
rawset(_G, "BTL_setSkillTargets", function(mo, targettype)
	local newtargets
	if targettype == TGT_ENEMY or targettype == TGT_ALLENEMIES
		newtargets = mo.enemies
	elseif targettype == TGT_ALLY or targettype == TGT_ALLALLIES
		newtargets = mo.allies
	elseif targettype == TGT_CASTER
		newtargets = {mo}
	elseif targettype == TGT_DEAD
		newtargets = mo.allies_noupdate
	elseif targettype == TGT_EVERYONE
		newtargets = {}
		for i = 1, #mo.allies
			newtargets[#newtargets+1] = mo.allies[i]
		end
		for i = 1, #mo.enemies
			newtargets[#newtargets+1] = mo.enemies[i]
		end
	end

	if mo.targets ~= newtargets or mo.targettype ~= targettype

		-- for tgt_dead; check if we have dead allies to begin with.
		local deadallieslist = {}
		if targettype == TGT_DEAD

			for i = 1, #mo.allies_noupdate
				if mo.allies_noupdate[i].hp <= 0
					deadallieslist[#deadallieslist+1] = mo.allies_noupdate[i]
				end
			end
			if not #deadallieslist
				mo.targets = nil
				return
			end
			newtargets = deadallieslist
		end

		mo.targettype = targettype
		mo.t_ctarget = 12
		playSound(mo.battlen, sfx_hover, mo)
		-- update camera, it wasn't made for THIS particular switch so we'll handle it here:
		if (not mo.targets or (mo.targets == mo.allies or (mo.targets and #mo.targets == 1 and mo.targets[1] == mo) or mo.targets == nil or mo.targets == deadallieslist)) and newtargets == mo.enemies
			mo.targets = newtargets or $

			local x, y, z, an, ai = CAM_defaultcoords(mo, true)
			local cam = server.P_BattleStatus[mo.battlen].cam
			P_TeleportMove(cam, x, y, z)
			cam.angle = an
			cam.aiming = ai
			CAM_stop(cam)
		end

		mo.targets = newtargets or $

		if targettype == TGT_ALLY
		and mo.t_cmem[2]
		and newtargets[mo.t_cmem[2]]
			mo.t_target = mo.t_cmem[2]
		elseif targettype == TGT_ENEMY
		and mo.t_cmem[1]
		and newtargets[mo.t_cmem[1]]
			mo.t_target = mo.t_cmem[1]
		else
			mo.t_target = 1
		end
	end
end)

rawset(_G, "command2act", {
	ACT_SKILL,
	ACT_ITEM,
	ACT_SUBPERSONAS,
	ACT_TACTICS,
	ACT_DEFEND,
})

-- ready return from a menu to the main one, the time gap is used for the HUD animation.
rawset(_G, "BTL_readyReturn", function(mo)
	server.P_BattleStatus[mo.battlen].hudtimer.out = 7
end)

rawset(_G, "BTL_handleReturn", function(mo)
	if server.P_BattleStatus[mo.battlen].hudtimer.out == 1
		mo.t_act = ACT_NONE
		mo.t_selectslide = 0
		BTL_setAttack(mo, mo.melee)	--attackDefs[charStats[mo.stats].melee_natk]
		BTL_setSkillTargets(mo, mo.attack.target)
		local x, y, z, an, ai = CAM_defaultcoords(mo, true)
		P_TeleportMove(server.P_BattleStatus[mo.battlen].cam, x, y, z)
		server.P_BattleStatus[mo.battlen].cam.angle = an
		server.P_BattleStatus[mo.battlen].cam.aiming = ai
	end
	return server.P_BattleStatus[mo.battlen].hudtimer.out
end)

-- sets values to deplete HP/SP on skill selection.
-- returns false is HP/SP was too low.
rawset(_G, "BTL_skillCostDepletion", function(mo)
	local skill = mo.attack
	if not skill return end
	local btl = server.P_BattleStatus[mo.battlen]
	local cost = ATK_getSkillCost(mo, skill)

	if mo.status_condition == COND_SUPER
		return true	-- free!
	end

	if skill.costtype == CST_HP
	or skill.costtype == CST_HPPERCENT
		if mo.boss then return true end

		if mo.hp <= cost
			playSound(mo.battlen, sfx_not)
			BTL_logMessage(mo.battlen, "Insufficient HP")
			return
		else
			mo.losehp = cost
		end
	elseif skill.costtype == CST_SP
	or skill.costtype == CST_SPPERCENT
		if mo.sp < cost
			playSound(mo.battlen, sfx_not)
			BTL_logMessage(mo.battlen, "Insufficient SP")
			return
		else
			mo.losesp = cost
		end
	elseif skill.costtype == CST_EP

		if not btl.emeraldpow_max
			playSound(mo.battlen, sfx_not)
			BTL_logMessage(mo.battlen, "What's \'EP\' ???")
			return
		end

		if btl.emeraldpow < cost
			playSound(mo.battlen, sfx_not)
			BTL_logMessage(mo.battlen, "Insufficient Emerald Power")
			return
		else
			btl.emeraldpow = $- cost
		end
	end

	return true
end)

-- Balance Skills
rawset(_G, "BTL_balanceSkills", function(mo)
	for k,v in ipairs(mo.skills)
		if v == "cleave"
		or v == "giant slice"
			v = "fatal end"
		elseif v == "lunge"
		or v == "assault dive"
			v = "gigantic fist"
		elseif v == "snap"
		or v == "cruel attack"
			v = "vile assault"
		elseif v == "double fang"
			v = "torrent shot"
		elseif v == "agi"
		or v == "agilao"
			v = "agidyne"
		elseif v == "maragi"
			v = "maragion"
		elseif v == "bufu"
		or v == "bufula"
			v = "bufudyne"
		elseif v == "mabufu"
			v = "mabufula"
		elseif v == "garu"
		or v == "garula"
			v = "garudyne"
		elseif v == "magaru"
			v = "magarula"
		elseif v == "zio"
		or v == "zionga"
			v = "ziodyne"
		elseif v == "mazio"
			v = "mazionga"
		elseif v == "psi"
		or v == "psio"
			v = "psiodyne"
		elseif v == "mapsi"
			v = "mapsio"
		elseif v == "frei"
		or v == "freila"
			v = "freidyne"
		elseif v == "mafrei"
			v = "mafreila"
		elseif v == "kouha"
		or v == "kouga"
			v = "kougaon"
		elseif v == "makouha"
			v = "makouga"
		elseif v == "eiha"
		or v == "eiga"
			v = "eigaon"
		elseif v == "maeiha"
			v = "maeiga"
		elseif v == "dia"
		or v == "diarahan"
		or v == "media"
		or v == "mediarama"
		or v == "mediarahan"
			v = "diarama"
		end
	end

	BTL_splitSkills(mo)
end)


-- updates the entity's 'targets' list so that it works with attacks.
rawset(_G, "BTL_updateTargetForAttack", function(mo)
	local atk = mo.attack
	if not atk return end
	if atk.target == TGT_ALLY or atk.target == TGT_ENEMY or atk.target == TGT_DEAD or atk.target == TGT_CASTER
		local starget = mo.targets[mo.t_target]
		mo.targets = {starget}
	end
end)

rawset(_G, "BTL_attackCastCheck", function(mo)

	local btl = server.P_BattleStatus[mo.battlen]	-- check for tutorial hyper mode
	if btl.tutorial_hyper and mo.status_condition ~= COND_HYPER
		playSound(mo.battlen, sfx_not)
		BTL_logMessage(mo.battlen, "Use Hyper Mode with \x92 first!")
		return false
	end

	if attackDefs[mo.attackref].nocast and attackDefs[mo.attackref].nocast(mo.targets, mo.t_target, mo)
		playSound(mo.battlen, sfx_not)
		return false
	else
		return true
	end
end)

-- mobjthinker to deplete their hp/sp after choosing skill and other visual quirks
rawset(_G, "depleteStatsThinker", function(mo)

	if not mo or not mo.valid return end

	if mo.losehp
		if mo.targethp == nil
			mo.targethp = mo.hp-mo.losehp
		end
		mo.hp = $-mo.losehp/2
		mo.losehp = $/2
		if not mo.losehp
			mo.hp = mo.targethp
			mo.losehp = nil
			mo.targethp = nil
		end
	end

	if mo.losesp
		if mo.targetsp == nil
			mo.targetsp = mo.sp-mo.losesp
		end
		mo.sp = $-mo.losesp/2
		mo.losesp = $/2
		if not mo.losesp
			mo.sp = mo.targetsp
			mo.losesp = nil
			mo.targetsp = nil
		end
	end

	-- helper for death animation
	if not mo.hp and not mo.redhp
		mo.hu_deadanim = ($ ~= nil) and $+1 or 0
	else
		mo.hu_deadanim = 0
	end

	-- visual thinkframe
	if mo.thinkframe
		if mo.enemy	-- for enemies
			enemyList[mo.enemy].thinkframe(mo)
		end
	end

	-- helper for dodge animation
	if mo.dodgeanim
	and mo.defaultcoords	-- we'll have trouble without this

		mo.flags2 = $|MF2_DONTDRAW

		local ddist = 64 *sin((TICRATE/2 - mo.dodgeanim)*ANG1*11) /FRACUNIT
		local dan = mo.angle-ANG1*90

		local dx = mo.defaultcoords[1]
		local dy = mo.defaultcoords[2]

		local dummy = P_SpawnMobj(dx + ddist*cos(dan), dy + ddist*sin(dan), mo.z, MT_DUMMY)
		dummy.sprite = mo.sprite
		dummy.frame = mo.frame
		if mo.color
			dummy.color = mo.color
		end
		if mo.skin
			dummy.skin = mo.skin
			dummy.sprite2 = mo.sprite2
		end
		dummy.angle = mo.angle
		dummy.rollangle = mo.rollangle
		dummy.colorized = mo.colorized
		dummy.fuse = 2
		dummy.scale = mo.scale
		mo.dodgedummy = dummy
		if mo.thinkframe
			if mo.enemy
				enemyList[mo.enemy].thinkframe(dummy)	-- apply this to the dummy too.
			end
		end

		mo.dodgeanim = $-1

		if not mo.dodgeanim
			P_TeleportMove(mo, dx, dy, mo.z)
			mo.flags2 = $ & ~MF2_DONTDRAW
		end
	end
end)
addHook("MobjThinker", depleteStatsThinker, MT_PFIGHTER)

-- basic selection for menus (used in battle first so it's defined here) TODO: move to LUA_MENU when this happens
-- mobj_t mo -> BATTLE ENTITY to run this from (expects a valid input field)
-- string varname -> name of the variable to affect
-- input incr -> input to use to increment the selection (eg: "up", "down", "left"....)
-- input depl -> input to use to decrement the selection
-- int mmin -> min value of the input (loops back to max)
-- int mmax -> max value of the input (loops back to min)
-- func confirm -> function to run when confirming. (BT_JUMP is used to confirm)
-- func back -> function to run when going back		(BT_USE is used to go back)
-- func change -> function to run when the value has been changed

rawset(_G, "M_BasicSelector", function(mo, varname, incr, depl, mmin, mmax, confirm, back, change)

	if not mo or not varname or not incr or not depl or tonumber(mmin)==nil or tonumber(mmax)==nil return end

	local inputs = mo.control.mo.P_inputs
	if mo[varname] == nil
		mo[varname] = mmin or 0	-- avoid errors
		dprint("M_BasicSelector: auto assigned "..varname.." to "..(mmin or 0)..".")
	end

	if inputs[incr]==1
		mo[varname] = $+1
		if mo[varname] > mmax
			mo[varname] = mmin
		end
		if change then change(mo) end
		playSound(mo.battlen, sfx_hover, mo)
	elseif inputs[depl]==1
		mo[varname] = $-1
		if mo[varname] < mmin
			mo[varname] = mmax
		end
		if change then change(mo) end
		playSound(mo.battlen, sfx_hover, mo)
	elseif inputs[BT_JUMP]==1	-- always assumed to be the confirm button.
		if confirm then confirm(mo) end
		playSound(mo.battlen, sfx_confir, mo)
	elseif inputs[BT_USE]==1	-- always assumed to be the back button
		if back then back(mo) end
		playSound(mo.battlen, sfx_cancel, mo)
	end
end)

-- handle in-turn status condtions here

rawset(_G, "status_cam", function(mo)

	local btl = server.P_BattleStatus[mo.battlen]
	local cam = btl.cam

	CAM_stop(cam)

	local an = ANG1* P_RandomRange(10, 35)

	local gox = mo.x + 300*cos(mo.angle+an)
	local goy = mo.y + 300*sin(mo.angle+an)

	local dest_x = mo.x + 430 * cos(mo.angle+an)
	local dest_y = mo.y + 430 * sin(mo.angle+an)

	P_TeleportMove(cam, gox, goy, mo.z + FRACUNIT*80)	-- teleport the camera to a nice spot
	cam.angle = R_PointToAngle2(gox, goy, mo.x, mo.y)
	cam.aiming = -ANG1*4
	CAM_goto(cam, dest_x, dest_y, mo.z + FRACUNIT*130)
end)

rawset(_G, "BTL_turnstatusconditions", function(mo)
	local btl = server.P_BattleStatus[mo.battlen]
	if mo.status_condition

		local pn = mo.battlen
		if server.gamemode == GM_PVP
			if mo.status_turns and mo.status_turns > 1
				cureStatus(mo)
				return
			end
		end


		if mo.status_condition == COND_SHOCK	-- we were shocked, skip 1 turn

			mo.t_hidehud = true	-- tell the renderer to not display anything

			if mo.status_timer == 2
				status_cam(mo)
				BTL_logMessage(pn, mo.name.." is shocked and couldn't move!")
			end

			mo.t_statustimer = $+1

			if mo.t_statustimer >= TICRATE
				-- skip our turn and cure the status condition straight away
				cureStatus(mo)
				mo.t_statustimer = 0
				btl.battlestate = BS_ENDTURN
				mo.t_statustimer = 0
				mo.flags2 = $ & ~MF2_DONTDRAW
			end

			return true

		elseif mo.status_condition == COND_SILENCE

			if not mo.t_statustimer
				mo.status_turns = $+1

				if mo.status_turns >= 2
					status_cam(mo)
					BTL_logMessage(pn, mo.name.." has recovered")
					mo.t_curebuffer = true
				else
					mo.statustimer = 35
				end
			end
			mo.t_statustimer = $+1

			if mo.t_statustimer >= TICRATE
				-- skip our turn.

				if mo.t_curebuffer
					cureStatus(mo)
					mo.t_statustimer = 0
					mo.t_curebuffer = nil
				end
			end

			if mo.t_curebuffer
				return true
			end

		elseif mo.status_condition == COND_DIZZY	-- goes away after 2 turns or smth

			if not mo.t_statustimer
				mo.status_turns = $+1

				if mo.status_turns >= 4
					status_cam(mo)
					BTL_logMessage(pn, mo.name.." has recovered")
					mo.t_curebuffer = true
				else
					mo.statustimer = 35
				end
			end
			mo.t_statustimer = $+1

			if mo.t_statustimer >= TICRATE
				-- skip our turn.

				if mo.t_curebuffer
					cureStatus(mo)
					mo.t_statustimer = 0
					mo.t_curebuffer = nil
				end
			end

			if mo.t_curebuffer
				return true
			end

		elseif mo.status_condition == COND_FREEZE	-- frozen, can't move until we're attacked.

			--mo.t_hidehud = true	-- tell the renderer to not display anything

			if not mo.t_statustimer
				mo.status_turns = $+1
				--BTL_logMessage(pn, mo.name.." is frozen solid!")
				if mo.status_turns >= 3
					status_cam(mo)
					BTL_logMessage(pn, mo.name.." broke out of the ice!")
					mo.t_curebuffer = true
				end
			end
			mo.t_statustimer = $+1

			if mo.t_statustimer >= TICRATE
				if mo.status_turns >= 3
					mo.t_curebuffer = nil
					cureStatus(mo)
					return
				end
				-- skip our turn.
				--btl.battlestate = BS_ENDTURN
				--mo.t_statustimer = 0
			end

			if mo.t_curebuffer
				return true
			end

		elseif mo.status_condition == COND_SLEEP	-- frozen, can't move until we're attacked.
			mo.t_hidehud = true	-- tell the renderer to not display anything

			if not mo.t_statustimer
				status_cam(mo)
				mo.status_turns = $+1
				BTL_logMessage(pn, mo.name.." is fast asleep...")
			end
			mo.t_statustimer = $+1

			if mo.t_statustimer == 10
				damageObject(mo, -mo.maxhp/10, DMG_NORMAL)
				damageSP(mo, -mo.maxsp/10)
				mo.damaged = 1
				playSound(mo.battlen, sfx_heal)
			end

			if mo.t_statustimer >= TICRATE+20
				-- skip our turn.
				btl.battlestate = BS_ENDTURN
				mo.t_statustimer = 0
			end

			return true

		elseif mo.status_condition == COND_HEX	-- fear, 1/2 chance of skipping a turn

			--mo.t_hidehud = true	-- tell the renderer to not display anything

			if not mo.t_statustimer
				mo.status_turns = $+1
				if mo.status_turns >= 3
					status_cam(mo)
					BTL_logMessage(pn, mo.name.." recovered.")
					mo.t_curebuffer = true
				end
			end
			mo.t_statustimer = $+1

			if mo.t_statustimer >= TICRATE
				if mo.status_turns >= 3
					mo.t_curebuffer = nil
					cureStatus(mo)
					return
				end
			end

			if mo.t_curebuffer
				return true
			end

		elseif mo.status_condition == COND_RAGE	-- rage, strong auto attack for 2 turns

			mo.t_hidehud = true	-- tell the renderer to not display anything

			if not mo.t_statustimer
				status_cam(mo)
				mo.status_turns = $+1
				if mo.status_turns >= 4
					BTL_logMessage(pn, mo.name.." has calmed down")
				else
					BTL_logMessage(pn, mo.name.." is enraged!")
				end
			end
			mo.t_statustimer = $+1

			if mo.t_statustimer >= TICRATE
				if mo.status_turns >= 4
					cureStatus(mo)
					mo.t_statustimer = 0
					mo.t_forcecontrol = nil
					return
				end
				-- attack, attack, ATTACK
				btl.battlestate = BS_ACTION
				mo.t_statustimer = 0
				BTL_setAttack(mo, mo.melee)
				mo.targets = {mo.enemies[P_RandomRange(1, #mo.enemies)]}
			end

			if mo.status_condition
				return true
			end

		-- brainwash is PAINFUL
		elseif mo.status_condition == COND_BRAINWASH

			mo.t_hidehud = true	-- tell the renderer to not display anything

			if not mo.t_statustimer
				status_cam(mo)
				mo.status_turns = $+1
				if mo.status_turns >= 2
					BTL_logMessage(pn, mo.name.." snapped out of it!")
				else
					BTL_logMessage(pn, mo.name.." is brainwashed!")
				end
			end
			mo.t_statustimer = $+1

			if mo.t_statustimer >= TICRATE

				if mo.status_turns >= 2
					cureStatus(mo)
					mo.t_statustimer = 0
					mo.t_forcecontrol = nil
					return
				end

				-- we can now perform 1 of 2 actions:
				-- 1: heal / cast buff on enemy
				-- 2: attack ally

				local skl
				-- rebuild the list without EP skills:
				local brskills = {}
				for i = 1, #mo.skills do
					local a = attackDefs[mo.skills[i]]
					if a
					and a.costtype ~= CST_EP
						brskills[#brskills+1] = mo.skills[i]
					end
				end

				if not #brskills or P_RandomRange(0, 1)
					skl = mo.melee
				else
					skl = brskills[P_RandomRange(1, #brskills)]	-- pick a random skill
				end

				if not attackDefs[skl]	-- FALLBACK
					skl = "dummy"
				end

				local readskl = attackDefs[skl]
				local t = readskl.target
				mo.targets = {mo.allies[P_RandomRange(1, #mo.allies)]}

				if t == TGT_ENEMY
					mo.targets = {mo.allies[P_RandomRange(1, #mo.allies)]}
				elseif t == TGT_ALLENEMIES
					mo.targets = copyTable(mo.allies)
				elseif t == TGT_ALLY
					mo.targets = {mo.enemies[P_RandomRange(1, #mo.enemies)]}
				elseif t == TGT_ALLALLIES
					mo.targets = copyTable(mo.enemies)
				elseif t == TGT_CASTER
					mo.targets = {mo}
				elseif t == TGT_DEAD
					skl = mo.melee
					mo.targets = {mo.allies[P_RandomRange(1, #mo.allies)]}

				elseif t == TGT_EVERYONE
					mo.targets = {}
					for i = 1, #mo.allies
						mo.targets[#mo.targets+1] = mo.allies[i]
					end
					for i = 1, #mo.enemies
						mo.targets[#mo.enemies+1] = mo.enemies[i]
					end
				end

				BTL_setAttack(mo, skl)

				if not BTL_skillCostDepletion(mo)
					BTL_setAttack(mo, "nosp")
					mo.targets = {mo}
					btl.battlestate = BS_ACTION
					mo.t_statustimer = 0
					return true
				end

				-- this is mostly for players:
				mo.t_forcecontrol = true
				btl.battlestate = BS_ACTION
				mo.t_statustimer = 0
				return true
			end

			if mo.status_condition
				return true
			end

		end
	end
end)

-- handle what entities do on their turn;
-- for players, this means everything relative to your selection and whatnot.
-- for enemies, they pick an attack relative to their AI
rawset(_G, "BTL_turnHandler", function(pn)
	local btl = server.P_BattleStatus[pn]
	local mo = btl.turnorder[1]
	if not mo or not mo.valid return end

	-- handle stats.
	-- do not count a turn if we just had a one more (aka already 'acted')
	if not mo.acted
	and not mo.onemore
	and not mo.batontouch
		-- note: this isn't very optimized, this is because of how we want to handle them.

		if mo.t_stattimer
			mo.t_stattimer = $-1
			-- tp cam to us:
			local cam = btl.cam
			--CAM_stop(cam)
			local x, y = mo.x + 320*cos(mo.angle + ANG1*50), mo.y + 320*sin(mo.angle + ANG1*50)
			P_TeleportMove(cam, x, y, mo.z + FRACUNIT*80)
			cam.angle = R_PointToAngle2(cam.x, cam.y, mo.x, mo.y)
			cam.aiming = -ANG1*2
			CAM_stop(cam)
			return
		end

		-- code below is deprecated, stats can no longer get reverted
		if mo.buffs["atk"][1] and mo.buffs["atk"][2] and mo.t_statstuff < 1
		and mo.t_passed_stat < 1
			mo.buffs["atk"][2] = $-1
			mo.t_passed_stat = $+1
			if not mo.buffs["atk"][2]

				BTL_logMessage(pn, "Attack reverted")
				mo.buffs["atk"][1] = 0
				mo.t_stattimer = TICRATE
				mo.t_statstuff = 0
				return

			end
		end
		mo.t_statstuff = $+1


		if mo.buffs["def"][1] and mo.buffs["def"][2] and mo.t_statstuff < 2
		and mo.t_passed_stat < 2
			mo.buffs["def"][2] = $-1
			mo.t_passed_stat = $+1
			if not mo.buffs["def"][2]

				BTL_logMessage(pn, "Defence reverted")
				mo.buffs["def"][1] = 0
				mo.t_stattimer = TICRATE
				mo.t_statstuff = 0
				return

			end
		end
		mo.t_statstuff = $+1


		if mo.buffs["agi"][1] and mo.buffs["agi"][2] and mo.t_statstuff < 3
		and mo.t_passed_stat < 3
			mo.buffs["agi"][2] = $-1
			mo.t_passed_stat = $+1
			if not mo.buffs["agi"][2]

				BTL_logMessage(pn, "Agility reverted")
				mo.buffs["agi"][1] = 0
				mo.t_stattimer = TICRATE
				mo.t_statstuff = 0
				return

			end
		end

		mo.t_statstuff = $+1
		local basestuff = mo.t_statstuff

		local checks = {ATK_SLASH, ATK_STRIKE, ATK_PIERCE, ATK_FIRE, ATK_ICE, ATK_WIND, ATK_ELEC, ATK_PSY, ATK_NUCLEAR, ATK_BLESS, ATK_CURSE, ATK_ALMIGHTY}
		local resists = {
							"Slash resistance", "Strike resistance", "Pierce resistance",
							"Fire resistance", "Ice resistance", "Wind resistance", "Elec resistance",
							"Psy resistance", "Nuke resistance", "Bless resistance", "Curse resistance", "Almighty resistance"
						}

		for i = 1, #checks do

			local curr = checks[i]

			if mo.buffs[curr][1] and mo.buffs[curr][2] and mo.t_statstuff < (basestuff+i)
			and mo.t_passed_stat < (basestuff + i)
				mo.buffs[curr][2] = $-1
				mo.t_passed_stat = $+1
				if not mo.buffs[curr][2]

					BTL_logMessage(pn, resists[i].." reverted")
					mo.buffs[curr][1] = 0
					mo.t_stattimer = TICRATE
					mo.t_statstuff = 0
					return
				end
			end
			mo.t_statstuff = $+1
		end

		-- next up, passive skills that should trigger at the start of the turn

		if not mo.t_passivebuffer

			for i = 1, #mo.passiveskills
				local psv = mo.passiveskills[i]
				if attackDefs[psv]
					psv = attackDefs[$]
					if psv.passive == PSV_STARTTURN and mo.t_passivestuff < i
						mo.t_passivestuff = i
						mo.t_passivebuffer = i
						mo.t_passivetimer = 0	-- reset this timer
						break	-- ^ this is the skill we're going to use
					end
				end
			end
		end

		if mo.t_passivebuffer
			-- tp cam to us:
			local cam = btl.cam
			--CAM_stop(cam)
			local x, y = mo.x + 320*cos(mo.angle + ANG1*50), mo.y + 320*sin(mo.angle + ANG1*50)
			P_TeleportMove(cam, x, y, mo.z + FRACUNIT*80)
			cam.angle = R_PointToAngle2(cam.x, cam.y, mo.x, mo.y)
			cam.aiming = -ANG1*2
			CAM_stop(cam)

			mo.atk_attacker = mo	-- makes these function correctly, we don't get getDamage for this, so we have to set it manually.
			local atk = attackDefs[mo.passiveskills[mo.t_passivebuffer]]
			mo.atk_hitby = BTL_copyAttackDefs(atk)	-- ditto
			if mo.t_passivetimer == 1 
				BTL_logMessage(mo.battlen, atk.name) 
			end
			if atk.anim(mo, {mo}, {mo}, mo.t_passivetimer)
				mo.t_passivebuffer = 0
				mo.t_passivetimer = 0
			end
			mo.t_passivetimer = $ +1
			return
		end
	end

	-- one more animation
	if mo.onemore
		mo.onemore = $-1

		if mo.onemore == TICRATE-1
			playLocalSound(mo, sfx_1more)
		end

		if not mo.onemore and mo.plyr
			-- ready HUD animation timer:
			btl.hudtimer.newturn = TICRATE/3
		end
		mo.setonemore = nil
		mo.batontouch = true	-- we can baton touch!
		return
	end

	-- recovering from being down:
	if mo.down
		if not mo.down_getup
			mo.down_getup = TICRATE
			BTL_logMessage(pn, mo.name.." has gotten back up!")
			-- tp cam to us:
			local cam = btl.cam
			--CAM_stop(cam)
			local x, y = mo.x + 320*cos(mo.angle + ANG1*50), mo.y + 320*sin(mo.angle + ANG1*50)
			P_TeleportMove(cam, x, y, mo.z + FRACUNIT*80)
			cam.angle = R_PointToAngle2(cam.x, cam.y, mo.x, mo.y)
			cam.aiming = -ANG1*2
			CAM_stop(cam)

			ANIM_set(mo, mo.anim_getup)
		end

		if ANIM_done(mo, mo.anim_getup)
			ANIM_set(mo, mo.anim_stand, true)
		end

		mo.down_getup = $-1
		if not mo.down_getup
			mo.down_getup = nil
			mo.down = nil
			-- put the cam back where it's supposed to go if we're a player
		end
		return
	end

	-- Evasion skills
	if mo.evasion

		mo.evasion = $-1
		if not mo.evasion

			-- it's over now
			BTL_setAttack(mo, mo.evasionskill)
			mo.targets = {mo}

			BTL_updateTargetForAttack(mo)
			return true	-- boom, we can act, fuck off
		else	-- do nothing.
			if mo.evasionprint
				BTL_logMessage(mo.battlen, mo.evasionprint)
			end

			-- Skip turn
			btl.battlestate = BS_ENDTURN
			return
		end
	end

	-- status conditions that take effect in-turn:
	--if btl.turnorder[2] ~= mo
	-- for multi-turn enemies, only apply this for their last turn (so we check if the next turn is still this particular enemy)
	-- statuses and fields will apply multiple times in case of 1-mores however!

		if BTL_turnstatusconditions(mo) return end

		-- field timers:
		if mo.fieldstate
			mo.fieldstate.turns = $-1
			--print(mo.fieldstate.turns)
			if mo.fieldstate.turns <= 0
				clearField(mo)
			end
		end
	--end

	-- TODO: make thinkers more accurate
	if not mo.plyr
	or mo.thinker
	or mo.thinker_n

		--if not mo.attack
		-- ^ why is that a condition?

			local thinker
			-- if we have a thinker directly saved inside of us, use that:

			-- if we have a tactic thinker (party members), try to fetch that (@TODO)
			if mo.thinker_n
			and P_thinkers		-- <<<< @TODO
				thinker = P_thinkers[mo.thinker_n]

			-- if we're an enemy, get the thinker from the table
			elseif mo.enemy
				thinker = enemyList[mo.enemy].thinker or generalEnemyThinker
			elseif mo.thinker
				thinker = mo.thinker	-- works in singleplayer...

			end

			-- prepare camera for players:
			if mo.plyr
				local x,y,z,an,ai = CAM_defaultcoords(mo)
				CAM_goto(btl.cam, x, y, z)
				CAM_angle(btl.cam, an)
				CAM_aiming(btl.cam, ai)
			end

			-- this is a hack which does set the actual attackdef but we use BTL_setAttack afterwards to undo the issue
			mo.attack, mo.targets = thinker(mo)
			for k, p in pairs(attackDefs)
				if mo.attack == p
					BTL_setAttack(mo, k)
					break
				end
			end

			if not mo.targets
				mo.targets = {mo.enemies[1]}
			end

			if not mo.attack
				BTL_setAttack(mo, "nosp")
				mo.targets = {mo}
			end

			-- summon persona for enemies with one.
			-- this is useful if we want some persona summoner battles?

			if mo.persona and not mo.persona.dontdraw
			and (not mo.summonpersona or not mo.summonpersona.valid)
			and not mo.t_summoned
			and not mo.attack.physical	-- physical attacks needn't summon anything

				mo.summonpersona = P_SpawnMobj(0, 0, 0, MT_BTL_PERSONA)
				mo.summonpersona.target = mo
				mo.summonpersona.scale = 0
				local scale = mo.scale
				if mo.enemy and enemyList[mo.enemy].personascale
					scale = enemyList[mo.enemy].personascale
				end

				mo.summonpersona.destscale = FixedMul(scale, FRACUNIT*12/10)
				mo.summonpersona.scalespeed = FRACUNIT/3

				mo.summonpersona.p_state = 1	-- idle
			end

			if mo.anim_evoker
				ANIM_set(mo, mo.anim_evoker, true)
			end

		--end

		-- wait a tiny second; can we USE this attack? :^)
		if mo.enemy
		and mo.attack.costtype == CST_SP

			if mo.sp < mo.attack.cost
				--HAHAHAHAHHAHAHAHA PATHETIC
				BTL_setAttack(mo, "nosp")
				mo.targets = {mo}
			else
				mo.sp = $ - mo.attack.cost
			end

			-- we don't check for HP because enemies don't lose HP when using skills.
			-- Moreover, party members don't use skills they don't have enough ressources to use

		elseif mo.plyr
		and not BTL_skillCostDepletion(mo)

			-- @TODO: fallback

		end

		BTL_logMessage(mo.battlen, mo.attack.name)
		return true -- no, we're not doing that, you piece of shit
	end

	-- case 1: the actor is a player that we control
	if mo.plyr
	and mo.control
		local inputs = mo.control.mo.P_inputs

		BTL_setupPlayerTurn(mo)	-- setup menu stuff. this func only runs once while 'acted' isn't set to true.

		-- handle turn timer here:
		if mo.t_acttimer
		and netgame
			mo.t_acttimer = $-1

			if not mo.t_acttimer

				-- don't forget this...!
				if mo.summonpersona and mo.summonpersona.valid
					mo.summonpersona.p_state = -1	-- fade out
				end

				btl.battlestate = BS_ENDTURN
				return
			end
		end

		-- challenge timer
		if server.gamemode == GM_CHALLENGE
		and not btl.timer	-- yikes
			btl.battlestate = BS_ENDTURN	-- skip straight to the end of the turn regardless of what you were doing
			return
		end

		-- VR timer
		if server.gamemode == GM_VOIDRUN
		and not server.P_DungeonStatus.VR_timer
			btl.battlestate = BS_ENDTURN
			return
		end


		-- you can activate hyper mode literally anywehere granted no one else already has it on!
		if inputs[BT_BTNC] == 1

			if mo.status_condition and mo.status_condition >= COND_HYPER	-- Hyper is active

				if not BTL_canSuper(btl, mo)
					BTL_logMessage(pn, "Hyper Mode is already active!")
					playSound(mo.battlen, sfx_not, mo)
					return
				else
					-- super mode activated...!
					-- add one more entry for us in turn order
					local i = #btl.turnorder +1
					while i > 1
						btl.turnorder[i] = btl.turnorder[i-1]	-- move everything 1 slot back so that there are 2 of us :woke:
						i = $-1
					end

					BTL_setAttack(mo, "super")
					--mo.attack = attackDefs["super"]
					BTL_setSkillTargets(mo, mo.attack.target)

				-- increase all stats
				local stats = {"strength", "magic", "endurance", "agility", "luck"}
				for i = 1, #stats do
					mo[stats[i]] = $+15	-- we already have +10 from hyper, so this gives a total of +25
				end

					return true	-- we're good
				end
			elseif btl.emeraldpow < 100
				BTL_logMessage(pn, "Insufficient Emerald Power!")
				playSound(mo.battlen, sfx_not, mo)
				return
			end

			-- begin hyper mode!
			btl.emeraldpow = max(0, $-100)
			btl.emeraldpow_buffer = true

			-- spawn particles
			btl.hudtimer.hypermode = TICRATE

			--phud.clear("emeraldpow")

			cureStatus(mo)	-- clear previous status. Especially useful for hunger and its half-stats
			mo.status_condition = COND_HYPER
			playSound(mo.battlen, sfx_supert)
			BTL_logMessage(mo.battlen, "Hyper Mode activated!")

			-- increase all stats
			local stats = {"strength", "magic", "endurance", "agility", "luck"}
			for i = 1, #stats do
				mo[stats[i]] = $+10
			end
		end

		if mo.t_act == ACT_NONE	-- command selection...

			local p = mo.control

			if mo.t_renderangle > 0
				mo.t_renderangle = $-1
			elseif mo.t_renderangle < 0
				mo.t_renderangle = $+1
			end

			local down = inputs["down"] == 1
			local up = inputs["up"] == 1

			if p and p.valid
			and not p.invertcommand
				down = inputs["up"] == 1
				up = inputs["down"] == 1
			end

			if down
			and not mo.t_renderangle
				mo.t_command = mo.t_command < 5 and $+1 or 0
				mo.t_renderangle = -3
				playSound(mo.battlen, sfx_turn, mo)
			elseif up
			and not mo.t_renderangle
				mo.t_command = mo.t_command == 0 and 5 or $-1
				mo.t_renderangle = 3
				playSound(mo.battlen, sfx_turn, mo)
			end

			-- basic attack + targetting

			mo.melee = charStats[mo.stats].melee_natk
			if mo.weapon and mo.weapon.melee
				mo.melee = mo.weapon.melee
			end

			if mo.status_condition == COND_SUPER
				if charStats[mo.stats].melee_satk
					mo.melee = charStats[mo.stats].melee_satk	-- super attack
				end
			end

			BTL_setAttack(mo, mo.melee)
			mo.targets = mo.enemies

			if not mo.targettype	-- ready this
				mo.targettype = mo.attack.target
			end


			CAM_followtarget(mo)
			BTL_handletargetselection(mo)	-- can target while selecting command

			if inputs[BT_JUMP]==1

				if not mo.targets return end

				if mo.commandflags & (2^mo.t_command)
					playSound(mo.battlen, sfx_not, mo)
					return
				end

				if not mo.t_command		-- command 0 is a specific case as it makes us attack immediately.
					BTL_updateTargetForAttack(mo)
					return true	-- boom, we can act, fuck off
				else
					local act = command2act[mo.t_command] or 0
					if act == ACT_SKILL		-- update target immediately if we select skill or item. Also set to evoker state

						if not #mo.skills
						or server.P_DungeonStatus.VR_clause == VE_NOSKILLS
							playSound(mo.battlen, sfx_not)
							if server.P_DungeonStatus.VR_clause == VE_NOSKILLS
								BTL_logMessage(mo.battlen, "Skills are sealed")
							else
								BTL_logMessage(mo.battlen, "No usable skills.")
							end
							return
						end

						-- because of subpersonas, it could be possible that a skill we had selected doesn't exist anymore,
						if mo.t_skillselect > #mo.skills
							mo.t_skillselect = 1	-- just revert back to the skill at the top of the list in that case!
						end

						--mo.attack = attackDefs[mo.skills[mo.t_skillselect]]
						BTL_setAttack(mo, mo.skills[mo.t_skillselect])
						BTL_setSkillTargets(mo, mo.attack.target)
						ANIM_set(mo, mo.anim_evoker, true)
						-- also start sounds:
						playSound(mo.battlen, sfx_qsumon)
						playSound(mo.battlen, sfx_arm)

						VFX_Play(mo, VFX_SUMMON)
					elseif act == ACT_ITEM

						BTL_sortItems(btl)	-- in case this wasn't done already

						if not #btl.items
						or btl.it_section2 < 2
						or server.P_DungeonStatus.VR_clause == VE_NOITEMS
							playSound(mo.battlen, sfx_not, mo)
							if server.P_DungeonStatus.VR_clause == VE_NOITEMS
								BTL_logMesage(pn, "Items are sealed")
							else
								BTL_logMessage(pn, "No items")
							end
							return
						end
						while (not btl.items[mo.t_itemselect]) or mo.t_itemselect > btl.it_section2-1
							mo.t_itemselect = $-1
						end
						local atk = itemDefs[btl.items[mo.t_itemselect][1]].attack
						if atk
							BTL_setAttack(mo, atk)
							BTL_setSkillTargets(mo, mo.attack.target)
						end
					elseif act == ACT_TACTICS	-- reset tactics related sub menu variables. It's a bit messy but this is the only menu like that, fret not.
						mo.t_tacticselect = 1
						mo.t_tacticsubmenu = 0
						mo.t_tacticsubmenu2 = 0
						mo.t_subtacticselect = 0
						mo.t_subtacticselect2 = 0

					elseif act == ACT_SUBPERSONAS	-- if we got no subpersonas,
						if #btl.subpersonas < 2	-- subpersona #1 is empty
							playSound(mo.battlen, sfx_not, mo)
							BTL_logMessage(pn, "No Sub-Personas available")
							return
						end

						-- otherwise, enter sub persona menu
						mo.t_subpselect = $ or 1
						-- check for out of bounds
						if mo.t_subpselect < 1 or mo.t_subpselect > #btl.subpersonas
							mo.t_subpselect = 1
						end
						mo.t_subpslide = 0
					end
					mo.t_act = act
					playSound(mo.battlen, sfx_select, mo)
					btl.hudtimer.to = 7
				end

			elseif inputs[BT_USE] == 1	-- on this menu, spin can initiate the baton touch!
			and mo.batontouch

				if #server.plentities[mo.battlen] < 2	-- only a single memeber?
					return	-- no baton pass!
				end

				if mo.commandflags
					if mo.commandflags & CDENY_BATONPASS
						playSound(mo.battlen, sfx_not)
						return	-- nope
					elseif mo.commandflags & CDISABLE_BATONPASS
						return	-- in this case, it's not here
					end
				end

				mo.t_act = ACT_BATONTOUCH
				BTL_setAttack(mo, "baton pass")
				BTL_setSkillTargets(mo, mo.attack.target)
				--mo.targets = mo.allies

			-- go to tactics
			elseif inputs[BT_WEAPONPREV] == 1

				if mo.commandflags
				and mo.commandflags & (CDISABLE_TACTICS|CDENY_TACTICS)
					return	-- nope.
				end

				-- shortcut to go straight to analysis
				mo.t_tacticselect = 1
				mo.t_tacticsubmenu = 1
				mo.t_tacticsubmenu2 = 0
				mo.t_subtacticselect = 0
				mo.t_subtacticselect2 = 0
				btl.hudtimer.to = 7
				btl.hudtimer.tactic_in = TICRATE*2/3
				mo.t_act = ACT_TACTICS
				mo.t_endtactics = true	-- will instantly ready return when you exit the analysis

			elseif inputs[BT_WEAPONNEXT] == 1

				mo.t_act = ACT_TURNORDER
				mo.t_turnordertimer = 1

				-- move the camera
				local cam = btl.cam
				local gox = btl.arena_coords[1] + 600*cos(btl.arena_coords[4] - ANG1*20)
				local goy = btl.arena_coords[2] + 600*sin(btl.arena_coords[4] - ANG1*20)

				CAM_goto(cam, gox, goy, mo.z + FRACUNIT*150)
				CAM_angle(cam, R_PointToAngle2(gox, goy, btl.arena_coords[1], btl.arena_coords[2]))
				CAM_aiming(cam, ANG1*(-7))

				mo.t_turnorder = copyTable(btl.turnorder)
				-- kill duplicates... (we'll use enemy.turns for the display)
				local i = #mo.t_turnorder
				-- iterate backwards because we're removing shit.
				while i
					if i > 1 and mo.t_turnorder[i-1] == mo.t_turnorder[i]
						table.remove(mo.t_turnorder, i)
					end

					i = $-1
				end

				local remaining = server.gamemode == GM_PVP and BTL_BuildTurnOrder_PVP(pn, true) or BTL_BuildTurnOrder(pn, true)
				-- get this with "simulation" mode.
				for i = 1, #remaining
					if remaining[i] == mo
						break
					else
						mo.t_turnorder[#mo.t_turnorder+1] = remaining[i]
					end
				end
			end

		elseif mo.t_act == ACT_TURNORDER

			mo.t_turnordertimer = $+1

			-- this state only checks for a button press.
			if not inputs[BT_WEAPONNEXT]
				mo.t_turnorder = 0
				mo.t_act = ACT_NONE
				CAM_followtarget(mo, true)	-- force go back
			end

		elseif mo.t_act == ACT_SUBPERSONAS
			if BTL_handleReturn(mo)
				mo.t_target = $ or 1
				return
			end

			if btl.hudtimer.equipsubp

				if btl.hudtimer.equipsubp == 4

					if mo.t_subp_backtoskill

						-- switch to skill submenu without telling anyone, shhh

						-- make sure we can use this skill:
						if mo.t_skillselect > #mo.skills
							mo.t_skillselect = 1
						end

						BTL_setAttack(mo, mo.skills[mo.t_skillselect])
						BTL_setSkillTargets(mo, mo.attack.target)
						ANIM_set(mo, mo.anim_evoker, true)
						-- also start sounds:
						playSound(mo.battlen, sfx_qsumon)
						playSound(mo.battlen, sfx_arm)
						mo.t_act = ACT_SKILL
						mo.t_command = 1
						mo.t_subp_backtoskill = nil	-- remove that property
					else	-- otherwise, under normal means, go back to the normal menu.
						playSound(mo.battlen, sfx_qsumon)
						mo.t_act = ACT_NONE
					end
				end
				return
			end

			if mo.t_subpslide > 0
				mo.t_subpslide = $-1
			elseif mo.t_subpslide < 0
				mo.t_subpslide = $+1
			end

			if inputs["down"] == 1
			and not mo.t_subpslide
				mo.t_subpslide = -3
				mo.t_subpselect = $+1
				if mo.t_subpselect > #btl.subpersonas
					mo.t_subpselect = 1
				end
				playSound(mo.battlen, sfx_turn, mo)

			elseif inputs["up"] == 1
			and not mo.t_subpslide
				mo.t_subpslide = 3
				mo.t_subpselect = $-1
				if mo.t_subpselect < 1
					mo.t_subpselect = #btl.subpersonas
				end
				playSound(mo.battlen, sfx_turn, mo)

			elseif inputs[BT_JUMP] == 1

				-- 1: make sure the selected subpersona isn't equipped
				-- saving subpersona by userdata is dangerous, let's save it by party index
				local mynum
				--for i = 1, #server.plentities[mo.control.P_party]
				for i = 1, server.P_netstat.teamlen do
					if server.plentities[mo.control.P_party][i] == mo
						mynum = i	-- that's me!
						break
					end
				end

				-- special case for nothing:
				if mo.t_subpselect == 1
				and not mo.subpersona
					BTL_logMessage(mo.battlen, "Already unequipped!")
					playSound(mo.battlen, sfx_not, mo)
					return
				end

				local subp = btl.subpersonas[mo.t_subpselect]
				if subp.equipped
				and mo.t_subpselect > 1	-- this shouldn't happen but you never know
					if subp.equipped == mynum
						BTL_logMessage(mo.battlen, "Already equipped!")
						playSound(mo.battlen, sfx_not, mo)
						return
					else
						BTL_logMessage(mo.battlen, "Used by "..mo.allies[subp.equipped].name.."!")
						playSound(mo.battlen, sfx_not, mo)
						return
					end
				end

				-- otherwise, we're free to equip it ourselves
				if mo.subpersona
					mo.subpersona.equipped = nil	-- unequip current subp
				end
				if mo.t_subpselect > 1
					subp.equipped = mynum
				end
				BTL_equipSubPersona(mo, subp)
				btl.hudtimer.equipsubp = 14

			elseif inputs[BT_USE] == 1
				if mo.t_subp_backtoskill
					btl.hudtimer.equipsubp = 14
					playSound(mo.battlen, sfx_cancel, mo)
				else
					BTL_readyReturn(mo)
				end
			end

		elseif mo.t_act == ACT_BATONTOUCH	-- baton touch, basically a "skill" special case.
				CAM_followtarget(mo)
				BTL_handletargetselection(mo)	-- can target while selecting command

				if BTL_handleReturn(mo)
					mo.t_target = $ or 1
					return
				end

				if inputs[BT_JUMP]==1	-- ready.
					if not BTL_attackCastCheck(mo) return end
					mo.no_action_vfx = true
					BTL_updateTargetForAttack(mo)
					return true
				elseif inputs[BT_USE]==1	-- return to main menu
					BTL_readyReturn(mo)
				end

		elseif mo.t_act == ACT_TACTICS	-- tactics, like running away, analysis and control swapping.
										-- Because everything in here is very different it's mostly a messy case by case scenario. Be careful when modifying this
			if BTL_handleReturn(mo)	-- used for hud transition
				mo.t_target = $ or 1	-- reset target if we don't have one somehow
				return
			end
			if not mo.t_tacticsubmenu	-- tactic submenu off

				-- if we have ANALYSIS highlighted let's make sure we can select the target
				BTL_setAttack(mo, "dummy")

				if mo.t_tacticselect == 1	-- if we're overing over ANALYSIS, then we can select target
					CAM_followtarget(mo)
					BTL_handletargetselection(mo)	-- can target while selecting command
				else	-- otherwise, don't do it
					mo.t_target = 0
					mo.t_ctarget = 12
				end

				M_BasicSelector(mo, "t_tacticselect", "down", "up", 1, 4,
					function(mo)	-- CONFIRM
						mo.t_tacticsubmenu = mo.t_tacticselect
						btl.hudtimer.tactic_in = TICRATE*2/3

						if mo.t_tacticselect == 2

							-- ready a table of shite...
							mo.t_tacticsstatus = {copyTable(mo.allies_noupdate), copyTable(mo.enemies[1].allies_noupdate)}
							-- check ENEMIES specifically for nil entries...
							local i = #mo.t_tacticsstatus[2]
							while i
								local e = mo.t_tacticsstatus[2][i]
								if not e or not e.valid
								or e.enemy and not e.hp	-- remove dead enemies specifically (dead players are OK)
									table.remove(mo.t_tacticsstatus[2], i)
								end
								i = $-1
							end

						-- @TODO: Bot tactics unimplemented
						elseif mo.t_tacticselect == 3
							playSound(mo.battlen, sfx_not, mo)
							mo.t_tacticsubmenu = 0
							btl.hudtimer.tactic_in = 0
							return

						-- in the case of run away (tacticselect 4), ready the vote buffer
						-- unless we aren't allowed to run anymore:
						elseif mo.t_tacticselect == 4
							if btl.boss
							or (btl.storedwaves and #btl.storedwaves)	-- voidrun multi-waves
								BTL_logMessage(mo.battlen, "Can't run away!")
								playSound(mo.battlen, sfx_not, mo)
								mo.t_tacticsubmenu = 0
								btl.hudtimer.tactic_in = 0
								return
							elseif mo.t_norun
								BTL_logMessage(mo.battlen, "Vote has already failed.")
								playSound(mo.battlen, sfx_not, mo)
								mo.t_tacticsubmenu = 0
								btl.hudtimer.tactic_in = 0
								return
							else
								mo.t_runvotes = {}
								mo.t_runvotetime = TICRATE*6	-- last second is used to show results
							end
						end
					end,
					function(mo)	-- BACK
						BTL_readyReturn(mo)
					end,
					function(mo)	-- CHANGE
						if mo.t_tacticselect == 1
							mo.t_target = $ or 1
						end
					end
				)
			else	-- tactic submenu on

				if btl.hudtimer.tactic_out	-- tactic_out is used to get rid of our old animations and whatnot
					mo.t_buf = true
					return
				end

				if not btl.hudtimer.tactic_out and mo.t_buf
					if mo.t_tacticsubmenu == 3	-- was voting; prevent from voting next turn
						mo.t_norun = true
					end
					mo.t_tacticsubmenu = 0
					mo.t_tacticsubmenu2 = 0
					mo.t_subtacticselect = 0
					mo.t_subtacticselect2 = 0
					mo.t_buf = nil

					if mo.t_endtactics
						mo.t_endtactics = nil
						BTL_readyReturn(mo)
					end
					return
				end

				if not mo.t_tacticsubmenu2 and inputs[BT_USE]==1	-- don't exit the entire menu if we're in a sub submenu

					playSound(mo.battlen, sfx_cancel, mo)
					if mo.t_skillview
						mo.t_skillview = nil
						return
					end
					btl.hudtimer.tactic_out = TICRATE*2/3
					return
				end

				-- special inputs for different tactic sub menus:

				if mo.t_tacticsubmenu == 1	-- analysis

					if not mo.t_skillview
					and inputs[BT_JUMP] == 1
						playSound(mo.battlen, sfx_select)
						mo.t_skillview = 1
					elseif mo.t_skillview
						-- checking skills
						-- we have 8 skills

						-- this kinda sucks but lol let's go with it
						if inputs["down"] == 1
							mo.t_skillview = $+1
							playSound(mo.battlen, sfx_hover)
							if (mo.t_skillview-1)%4 == 0
								mo.t_skillview = $-4
							end
						elseif inputs["up"] == 1
							mo.t_skillview = $-1
							playSound(mo.battlen, sfx_hover)
							if (mo.t_skillview%4) == 0
								mo.t_skillview = $+4
							end
						elseif inputs["left"] == 1
							mo.t_skillview = $-4
							playSound(mo.battlen, sfx_hover)
							if mo.t_skillview < 1
								mo.t_skillview = $+8
							end
						elseif inputs["right"] == 1
							mo.t_skillview = $+4
							playSound(mo.battlen, sfx_hover)
							if mo.t_skillview > 8
								mo.t_skillview = $-8
							end
						end
					end

				elseif mo.t_tacticsubmenu == 4	-- vote to run away

					-- let the animation play out:
					if btl.hudtimer.tactic_in return end

					-- if we use BT_USE, as the person who initiated the vote, the vote is cancelled straight away, see above.
					-- now, check what everyone else has to say...
					for i = 1, #mo.allies do
						if mo.t_runvotes[i] ~= nil continue end
						local ninputs = mo.allies[i].control.mo.P_inputs

						-- if someone has the same inputs as us, then that means they're voting the same as us, so yes if we're mo
						if mo.allies[i].control == mo.control
							mo.t_runvotes[i] = true
							--dprint("autovote in favor of control player")
							continue
						end

						if ninputs[BT_JUMP] == 1
							mo.t_runvotes[i] = true
							--dprint("voted yes")
						elseif ninputs[BT_USE] == 1
							mo.t_runvotes[i] = false
							--dprint("voted no")
						end
					end
					mo.t_runvotetime = $-1

					if mo.t_runvotetime <= TICRATE	-- out of time to vote, everyone who hasn't voted is going to be voting against.
						--dprint("vote time out, forcing remaining votes to false")
						for i = 1, #mo.allies do
							mo.t_runvotes[i] = $ or false
						end
					end

					if #mo.t_runvotes >= #mo.allies	-- everyone has voted
						--dprint("everyone has voted")
						mo.t_runvotetime = min($, TICRATE)
						-- clear vote buffer, prevent any other escape attempt if the vote failed, and perform an action.
						-- count fors:
						local runfor = 0
						for i = 1, #mo.allies do
							if mo.t_runvotes[i]
								runfor = $+1
							end
						end

						if mo.t_runvotetime <= 0
							if runfor > #mo.allies/2
								-- >majority decides to run away
								-- use the runaway skill which has the hack to end the fight, why wouldn't it!
								BTL_setAttack(mo, "run")
								mo.no_action_vfx = true
								mo.targets = {mo.enemies[1]}
								btl.battlestate = BS_ACTION	-- force act
							else
								-- >majority decides to stay
								mo.t_norun = true	-- cannot run again for this turn (this is reset at the start of the turn)
								playSound(mo.battlen, sfx_cancel, mo)
								btl.hudtimer.tactic_out = TICRATE*2/3	-- hack to exit the menu
							end
						end
					end
				end

				if mo.t_tacticsubmenu == 3	-- for party menu
					mo.t_subtacticselect = $ or 1
					mo.t_subtacticselect2 = $ or 0

					if btl.hudtimer.tactic_out2	-- akin to readyreturn
						return
					elseif btl.hudtimer.tactic_out2 == 0
						mo.t_tacticsubmenu2 = 0
						mo.t_subtacticselect2 = 0
						btl.hudtimer.tactic_out2 = nil
					end

					if mo.t_tacticsubmenu2	-- change tactics
						M_BasicSelector(mo, "t_subtacticselect2", "down", "up", 0, 5,
						function(mo)	-- CONFIRM
							local m = mo.allies[mo.t_subtacticselect]	-- this is why it's important to keep the other menu running
							m.thinkern = mo.t_subtacticselect2	-- this is later interpreted to run advanced thinkers in BS_ACTION
							btl.hudtimer.tactic_out2 = TICRATE*2/3	-- also exit this menu, chances are we don't want to set the tactic of this mo anymore
						end,
						function(mo)	-- BACK
							btl.hudtimer.tactic_out2 = TICRATE*2/3	-- just exit the menu
						end
						)
					else	-- select party member to change tactic off
						M_BasicSelector(mo, "t_subtacticselect", "down", "up", 1, #mo.allies,
						function(mo)	-- CONFIRM
							local m = mo.allies[mo.t_subtacticselect]	-- check if we CAN do anything to begin with
							if m.control ~= mo.control	-- yikes, this doesn't belong to us
								BTL_logMessage(mo.battlen, "Not under your control!")
								playSound(mo.battlen, sfx_not, mo)
								return
							elseif m == m.control.maincontrol or m == mo
								BTL_logMessage(mo.battlen, "Cannot change your own tactic")
								playSound(mo.battlen, sfx_not, mo)
								return
							end
							mo.t_tacticsubmenu2 = 1
							btl.hudtimer.tactic_in2 = TICRATE*2/3
						end,
						function(mo)	-- BACK
							btl.hudtimer.tactic_out2 = TICRATE*2/3
						end
						)
					end
				end
			end

		elseif mo.t_act == ACT_DEFEND
			if BTL_handleReturn(mo)	-- used for hud transition
				return
			end

			if inputs[BT_JUMP]==1

				-- check for super forms, don't fill by guarding if someone is super.
				local nofill
				for i  = 1, #mo.allies do
					if mo.allies[i].status_condition == COND_SUPER
						nofill = true
					end
				end

				if not nofill
					fillEmeraldGauge(mo, 33)	-- 33% emerald drive from guarding
				end
				BTL_setAttack(mo, "guard")
				mo.no_action_vfx = true	-- no voice
				mo.targets = {mo}
				return true	-- boom, we can act, fuck off
			elseif inputs[BT_USE]==1
				-- go back
				BTL_readyReturn(mo)
			end
		elseif mo.t_act == ACT_ITEM		-- item command selection

			if mo.t_selectslide
				mo.t_selectslide = $/2
			end

			if BTL_handleReturn(mo)	-- used for hud transition
				return
			end

			while not btl.items[mo.t_itemselect]	-- you NEVER KNOW.
				mo.t_itemselect = $-1
			end

			local itemn = btl.it_section2-1 --#btl.items	-- debug
			if inputs["down"]==1
			and itemn > 1
				mo.t_selectslide = mo.t_itemselect < itemn and -32 or itemn*32
				mo.t_itemselect = mo.t_itemselect < itemn and $+1 or 1
				playSound(mo.battlen, sfx_turn, mo)
				local atk = itemDefs[btl.items[mo.t_itemselect][1]].attack
				if atk
					BTL_setAttack(mo, atk)
					BTL_setSkillTargets(mo, mo.attack.target)
				end

			elseif inputs["up"]==1
			and itemn > 1
				mo.t_selectslide = mo.t_itemselect == 1 and itemn*-32 or 32
				mo.t_itemselect = mo.t_itemselect == 1 and itemn or $-1
				playSound(mo.battlen, sfx_turn, mo)
				local atk = itemDefs[btl.items[mo.t_itemselect][1]].attack
				if atk
					BTL_setAttack(mo, atk)
					BTL_setSkillTargets(mo, mo.attack.target)
				end

			elseif inputs[BT_USE]==1
				-- go back
				BTL_readyReturn(mo)
			elseif inputs[BT_JUMP]==1

				if not mo.targets return end

				-- check if the attack can be used:
				if not BTL_attackCastCheck(mo) return end
				-- CONSUME the item:

				-- set item name:
				mo.itemname = itemDefs[btl.items[mo.t_itemselect][1]].name
				BTL_useItem(btl, mo.t_itemselect, true)
				BTL_updateTargetForAttack(mo)
				mo.no_action_vfx = true
				VFX_Play(mo, VFX_ITEM)
				return true
			end

			CAM_followtarget(mo)
			BTL_handletargetselection(mo)	-- can target while selecting command

		elseif mo.t_act == ACT_SKILL	-- skill command selection

			if BTL_handleReturn(mo)	-- used for hud transition
			or btl.hudtimer.equipsubp
				if mo.anim == mo.anim_evoker
					ANIM_set(mo, mo.anim_stand, true)
				end

				if mo.summonpersona and mo.summonpersona.valid
					mo.summonpersona.p_state = -1	-- fade out
				end

				-- if we're using the hudtimer hack to switch menus, do it here!
				if btl.hudtimer.equipsubp == 4
					mo.t_act = ACT_SUBPERSONAS
					mo.t_command = 3
					mo.t_subp_backtoskill = true
					mo.t_subpselect = $ or 1
					mo.t_subpslide = 0
				end
				return
			end

			-- summon persona:
			if not mo.summonpersona or not mo.summonpersona.valid
				mo.summonpersona = P_SpawnMobj(0, 0, 0, MT_BTL_PERSONA)
				mo.summonpersona.target = mo
				mo.summonpersona.scale = 0
				mo.summonpersona.destscale = FRACUNIT*12/10
				mo.summonpersona.scalespeed = FRACUNIT/3

				mo.summonpersona.p_state = 0	-- idle
			end

			-- rest of the persona handler in MT_BTL_PERSONA's thinker

			summonAura(mo, SKINCOLOR_TEAL)

			if mo.t_selectslide
				mo.t_selectslide = $/2
			end

			local maxskills = #mo.skills	-- debug
			if inputs["down"]==1
			and maxskills > 1
				mo.t_selectslide = mo.t_skillselect < maxskills and -32 or maxskills*32
				mo.t_skillselect = mo.t_skillselect < maxskills and $+1 or 1
				playSound(mo.battlen, sfx_turn, mo)
				BTL_setAttack(mo, mo.skills[mo.t_skillselect])
				BTL_setSkillTargets(mo, mo.attack.target)

			elseif inputs["up"]==1
			and maxskills > 1
				mo.t_selectslide = mo.t_skillselect == 1 and maxskills*-32 or 32
				mo.t_skillselect = mo.t_skillselect == 1 and maxskills or $-1
				playSound(mo.battlen, sfx_turn, mo)
				BTL_setAttack(mo, mo.skills[mo.t_skillselect])
				BTL_setSkillTargets(mo, mo.attack.target)

			elseif inputs[BT_USE]==1
				-- go back
				BTL_readyReturn(mo)
			elseif inputs[BT_JUMP]==1
				if not mo.targets return end

				-- check if the attack can be used:
				if not BTL_attackCastCheck(mo) return end

				if not BTL_skillCostDepletion(mo)
					return
				end
				-- shoot ourselves and MANIFEST THE PERSONA
				playSound(mo.battlen, sfx_summon)
				ANIM_set(mo, mo.anim_evoker_shoot)
				BTL_updateTargetForAttack(mo)
				return true
			elseif (inputs[BT_WEAPONPREV] == 1 or inputs[BT_WEAPONNEXT] == 1)
			and not (mo.commandflags and mo.commandflags & (CDENY_PERSONA|CDISABLE_PERSONA))
			and btl.subpersonas and #btl.subpersonas
			and #btl.subpersonas > 1

				btl.hudtimer.equipsubp = 14	-- go to the other menu...
			end

			CAM_followtarget(mo)
			BTL_handletargetselection(mo)	-- can target while selecting command
		end
	end
end)


rawset(_G, "doCamAnim", function(mo, cutin)	-- this function is super messy but it's so worth it

	local cam = server.P_BattleStatus[mo.battlen].cam
	if not cam or not cam.valid return end

	if cam.done
		cam.didcutin = nil
		return true
	end

	if mo.plyr
	and not mo.t_forcecontrol
		local atk = mo.attack
		if atk.physical return true end
		local supportskill = false
		--local supportskill = ((atk.type == ATK_SUPPORT or atk.type == ATK_HEAL) and (atk.target == TGT_ALLY or atk.target == TGT_ALLALLIES)) and not cam.didcutin
		if (cutin or supportskill)
			if (mo.cutintimer or supportskill)
				if ((mo.cutintimer == TICRATE*3/2 - 1) or (not cam.didcutin))
					local an = ANG1* P_RandomRange(10, 35)

					local gox = mo.x + 300*cos(mo.angle+an)
					local goy = mo.y + 300*sin(mo.angle+an)

					local dest_x = mo.x + 430 * cos(mo.angle+an)
					local dest_y = mo.y + 430 * sin(mo.angle+an)

					cam.gotoangle = {}

					P_TeleportMove(cam, gox, goy, mo.z + FRACUNIT*80)	-- teleport the camera to a nice spot
					cam.angle = R_PointToAngle2(gox, goy, mo.x, mo.y)
					cam.aiming = -ANG1*4
					cam.didcutin = true
					CAM_goto(cam, dest_x, dest_y, mo.z + FRACUNIT*130)	-- CUT INS
				end
			else
				CAM_stop(cam)
				return true
			end
		else
			-- cut in animation is done / didn't happen

			local enm_count = 0
			local all_count = 0
			for k,v in ipairs(mo.targets)
				if compareTables(v.enemies_noupdate, mo.allies_noupdate)			-- these are our enemies
					enm_count = $+1
				elseif compareTables(v.allies_noupdate, mo.allies_noupdate)		-- they're our friend
					all_count = $+1
				end
			end

			if enm_count >= #mo.targets	-- it's only enemies
				if not cam.plyranim
					cam.plyranim = true
					CAM_stop(cam)
					P_TeleportMove(cam, cam.backupcoords[1], cam.backupcoords[2], cam.backupcoords[3])
					cam.angle = cam.backupcoords[4]
					cam.aiming = cam.backupcoords[5]	-- get back everything we had (just in case)
					cam.done = true
					return true	-- fuck off, this will do
				end

			elseif all_count >= #mo.targets	-- it's only allies
				local target = mo.targets[1]
				local an = ANG1* P_RandomRange(10, 35)
				local gox = target.x + 800*cos(target.angle+an)
				local goy = target.y + 800*sin(target.angle+an)
				P_TeleportMove(cam, gox, goy, target.z + FRACUNIT*80)	-- teleport the camera to a nice spot
				cam.angle = R_PointToAngle2(gox, goy, target.x, target.y)
				cam.aiming = ANG1*(-3)
				CAM_stop(cam)
				cam.done = true
				return true
			else	-- a mixed bag, an attack probably got repelled
				local gox = server.P_BattleStatus[mo.battlen].arena_coords[1] + 800*cos(ANG1*30)
				local goy = server.P_BattleStatus[mo.battlen].arena_coords[2] + 800*sin(ANG1*30)
				P_TeleportMove(cam, gox, goy, mo.z + FRACUNIT*120)
				cam.angle = R_PointToAngle2(gox, goy, server.P_BattleStatus[mo.battlen].arena_coords[1], server.P_BattleStatus[mo.battlen].arena_coords[2])
				cam.aiming = ANG1*(-4)
				cam.done = true
				CAM_stop(cam)
				return true
			end
		end
		return
	end

	if not mo.plyr or mo.t_forcecontrol
		if not cam.tp_en then
			cam.tp_en = true

			local atk = mo.attack

			if not atk.physical		-- enemy is using a skill

				local an = ANG1* P_RandomRange(10, 35)

				local gox = mo.x + 300*cos(mo.angle+an)
				local goy = mo.y + 300*sin(mo.angle+an)

				local dest_x = mo.x + 430 * cos(mo.angle+an)
				local dest_y = mo.y + 430 * sin(mo.angle+an)

				P_TeleportMove(cam, gox, goy, mo.z + FRACUNIT*80)	-- teleport the camera to a nice spot
				cam.angle = R_PointToAngle2(gox, goy, mo.x, mo.y)
				cam.aiming = -ANG1*4
				CAM_goto(cam, dest_x, dest_y, mo.z + FRACUNIT*130)

			else					-- enemy is using a regular physical attack
				-- go for the target
				local target = mo.targets[1] or mo	-- failsafe
				local an = ANG1* P_RandomRange(-5, -20)
				local gox = target.x + 600*cos(target.angle+(ANG1*140)+an)
				local goy = target.y + 600*sin(target.angle+(ANG1*140)+an)

				P_TeleportMove(cam, gox, goy, target.z + FRACUNIT*80)
				cam.angle = R_PointToAngle2(gox, goy, mo.x, mo.y)
				cam.aiming = ANG1*(-3)
				CAM_stop(cam)
				return true
			end
		end	-- we'll use this

		if cam.goto[1] == nil
		and cam.tp_en
		and not cam.tp_en2
			--mo.enemy_trans = 12	-- one more trans
			CAM_stop(cam)

			if #mo.targets == 1	-- only one target
				local target
				-- if we repelled an attack but the animation isn't to be repelled, keep the original target
				if mo.repelto and mo.attack.anim_norepel
					target = mo.repelto
				else
					target = mo.targets[1]
				end

				local an = ANG1* P_RandomRange(10, 35)
				local gox,goy
				if target.plyr
					gox = target.x + 300*cos(target.angle+ANGLE_180+an)
					goy = target.y + 300*sin(target.angle+ANGLE_180+an)
				else
					gox = target.x + 300*cos(target.angle+an)
					goy = target.y + 300*sin(target.angle+an)
				end
				--P_TeleportMove(cam, gox, goy, target.z + FRACUNIT*40)	-- teleport the camera to a nice spot
				CAM_goto(cam, gox, goy, target.z + FRACUNIT*40)
				CAM_angle(cam, R_PointToAngle2(gox, goy, target.x, target.y))
				CAM_aiming(cam, 0)
				--CAM_stop(cam)
			else
				-- there's multiple targets ooo
				--local baseoff
				local enm_count = 0
				local all_count = 0
				for k,v in ipairs(mo.targets)
					if compareTables(v.enemies, mo.allies)			-- these are our enemies
						enm_count = $+1
					elseif compareTables(v.allies, mo.allies)		-- they're our friend
						all_count = $+1
					end
				end

				if enm_count >= #mo.targets			-- all of them are our enemy
					local target = mo.targets[1] or mo	-- failsafe
					local an = ANG1* P_RandomRange(0, 40)
					local gox = target.x + 600*cos(target.angle+(ANG1*150)+an)
					local goy = target.y + 600*sin(target.angle+(ANG1*150)+an)

					CAM_goto(cam, gox, goy, target.z + FRACUNIT*80)
					CAM_angle(cam, R_PointToAngle2(gox, goy, target.x, target.y))
					CAM_aiming(cam, ANG1*(-3))

				elseif all_count >= #mo.targets		-- all of them are our allies
					local target = mo.targets[1] or mo
					local an = ANG1* P_RandomRange(10, 35)
					local gox = target.x + 650*cos(target.angle+an)
					local goy = target.y + 650*sin(target.angle+an)
					CAM_goto(cam, gox, goy, target.z + FRACUNIT*80)
					CAM_angle(cam, R_PointToAngle2(gox, goy, target.x, target.y))
					CAM_aiming(cam, ANG1*(-3))

				else								-- it's a mixed bag... was an attack repelled?
					local gox = server.P_BattleStatus[mo.battlen].arena_coords[1] + 800*cos(ANG1*30)
					local goy = server.P_BattleStatus[mo.battlen].arena_coords[2] + 800*sin(ANG1*30)

					CAM_goto(cam, gox, goy, mo.z + FRACUNIT*120)
					CAM_angle(cam, R_PointToAngle2(gox, goy, server.P_BattleStatus[mo.battlen].arena_coords[1], server.P_BattleStatus[mo.battlen].arena_coords[2]))
					CAM_aiming(cam, ANG1*(-4))
				end
				--CAM_stop(cam)
			end
			cam.tp_en2 = 1
		end

		if cam.tp_en2
			cam.tp_en2 = $+1
			if cam.tp_en2 >= 5
				return true
			end
		end
		return
	end

	return true
end)

rawset(_G, "doAttackAnim", function(mo, cutin)
	local btl = server.P_BattleStatus[mo.battlen]
	if cutin
		if not mo.cutintimer then
			mo.cutintimer = TICRATE*3/2
			playSound(mo.battlen, sfx_cutin)
		end
		if mo.cutintimer then
			mo.cutintimer = $-1
			if not mo.cutintimer
				mo.cutin = nil
				mo.cutintimer = nil
				return true
			end
		end
		return
	end

	return true		-- nothing for now.
end)

rawset(_G, "BTL_actionHandler", function(pn)	-- attack the enemy!
	local btl = server.P_BattleStatus[pn]
	local mo = btl.turnorder[1]
	if not mo or not mo.valid return end

	if netgame
		NET_synchAttack(mo)	-- for netgames
		-- functions don't synch properly over netgames so we NEED to do this to prevent further issues
	end
	local atk = attackDefs[mo.attackref]

	local can_cutin	-- if that's true, we might do a cut-in this turn. who knows.
	local fatal		-- the attack will kill the enemy

	-- get damage and all ready!
	if not btl.dmg_hits

		-- used to know what enemies were hit by links
		btl.linkhits = {}

		for k,v in ipairs(btl.fighters)
			if v and v.valid
				resetDamage(v)	-- ready v
			end
		end

		-- if we have a persona out, now's the time to materialize it!
		if mo.summonpersona and mo.summonpersona.valid
			mo.summonpersona.p_state = 1
		end

		BTL_logMessage(mo.battlen, mo.itemname or mo.attack.name)

		if not mo.plyr
			mo.enemy_trans = 10
			-- log the enemy's attack into our saved affinities
			-- iterate through skills to know which skill # we have to unveil first:
			local s = 0
			for i = 1, #mo.skills
				if attackDefs[mo.skills[i]] == atk
					s = i
					break
				end
			end
			btl.saved_affs[mo.enemy][2] = $ | (2^(s-1))
		end
		btl.cam.backupcoords = {btl.cam.x, btl.cam.y, btl.cam.z, btl.cam.angle, btl.cam.aiming}
		btl.dmg_hits = {}	-- damage we took
		btl.dmg_downs = {}	-- do we get knocked down from that!?
		btl.dmg_usecritanim = nil	-- use crit anim if the attack allows it

		-- shuffle target list if we have more than 1
		-- this makes multi target attacks feel more random and natural!

		if #mo.targets > 1	-- more than 1 target? Randomize them for better looking multi hit attacks!
			local dummy = copyTable(mo.targets)
			local new = {}

			while #dummy
				local key = P_RandomRange(1, #dummy)
				new[#new+1] = dummy[key]
				table.remove(dummy, key)
			end

			mo.targets = copyTable(new)
			dummy = nil
			new = nil	-- free memory
		end

		-- check for attack repelling!
		btl.oldtargetlist = {}
		local newtable = {}

		for k,v in ipairs(mo.targets)

			local repel = getAttackAff(v, mo.attack, mo) == DMG_REPEL	--v.repel & mo.attack.type
			for i = 1, #v.passiveskills
				local psv = v.passiveskills[i]
				if attackDefs[psv]
					psv = attackDefs[$]
					if psv.type & mo.attack.type
					and psv.passive == PSV_REPEL
						-- repel %?
						if not psv.accuracy
						or P_RandomRange(0, 100) <= psv.accuracy	-- used especially for counter
							repel = true
							if psv.accuracy	-- show off that we used counter
								BTL_logMessage(mo.battlen, psv.name)
							end
						end
					end
				end
			end

			btl.oldtargetlist[#btl.oldtargetlist+1] = v	-- keep the original targets in memory.

			-- oof
			-- note: we can also repel magic attacks if makarakarn is up.
			-- or physical attacks if tetrakarn is up.
			-- attack is physical if it costs HP, magic otherwise
			if (repel or (isAttackPhysical(mo.attack) and v.tetrakarn or not isAttackPhysical(mo.attack) and v.makarakarn))
			and mo.attack.type ~= ATK_ALMIGHTY	-- almighty doesn't get affected by repels.
			and mo.attack.type ~= ATK_HEAL		-- bruh
			and not mo.attack.norepel			-- norepel flag
			and not (v.guaranteedevasion)		-- no need to repel if we're just going to dodge anyway

				-- don't repel helpful skills
				if mo.attack.target == TGT_ALLY or mo.attack.target == TGT_ALLALLIES or mo.attack.target == TGT_CASTER
					newtable[#newtable+1] = v
					continue
				end

				if v == mo continue end	-- wait what

				local spr = SPR_ARMA	-- armageddon shield for repelling magic
				if isAttackPhysical(mo.attack)
					spr = SPR_FORC	-- force shield for repelling physical
				end

				-- if we aren't repelling the attack from affinity, drop tetrakarn or makarakarn accordingly
				if isAttackPhysical(mo.attack) and v.tetrakarn
					if not (v.repel & mo.attack.type)
						v.tetrakarn = nil
					end
				else
					if not (v.repel & mo.attack.type)
						v.makarakarn = nil
					end
				end
				v.repelspr = spr	-- used on attack tic 1
				mo.repelto = v		-- used for attacks that don't repel their animation
				v.damagestate = DMG_REPEL	-- set new damage state
				v.damaged = 5	-- fake damage to display the REPEL text
				-- unlock affinity anyway!
				if v.enemy
					btl.saved_affs[v.enemy][1] = $ | getAttackType(mo, atk)
				end

				-- check newtable to make sure we aren't in there already
				-- there are issues with repelling to the same entity multiple times.
				-- this also makes repelling less punishing in a way
				local dupe
				for i = 1, #newtable
					if newtable[i] == mo	-- ALREADY ADDED
						dupe = true
						break
					end
				end

				if not dupe
					newtable[#newtable+1] = mo
				end
				-- if this is a dupe, no one will get hit
			else
				newtable[#newtable+1] = v
			end
		end

		mo.targets = copyTable(newtable)


		for k,v in ipairs(mo.targets)

			-- first off, did we land the hit(s)?
			btl.dmg_hits[k] = {}	-- ready to receive damage!
			btl.dmg_downs[k] = {}	-- ready to store hits that should down
			v.dmg_index = k
			v.atk_hitby = mo.attack		-- this is fine, .attack doesn't have function values
			v.atk_hpremaining = v.hp	-- precalculate how much sp we'll have left
										-- used for some voice lines and all out attacks
			local aff = getAttackAff(v, atk, mo)

			if aff == DMG_BLOCK
			or aff == DMG_REPEL
			-- At this point, if we repel the attack AGAIN we should just be blocking it!
										-- we're not gonna play Pong, so just block the attack instead.
				v.block_offsets = {}
				local pos = {4, 1, 5, 2, 3}
				for i = 1, 5
					v.block_offsets[i] = {}
					v.block_offsets[i][1] = pos[i]
					v.block_offsets[i][2] = N_RandomRange(-4, 4)
				end
				v.atk_attacker = mo
				v.damagestate = DMG_BLOCK

				-- leftover from srb2 p5
				-- maybe could be reused? I like the new anim better

				if v.enemy
					btl.saved_affs[v.enemy][1] = $ | getAttackType(mo, atk)	-- unlock affinity on block too
				end

				continue -- don't compute damage in this case, it's not important!
			end
			for i = 1, atk.hits or 1

				-- we landed it!
				-- does our target block it, however?
				if aff == DMG_BLOCK
					btl.dmg_hits[k][i] = 0	-- 0 damage, we blocked it!
					continue
				end
				-- ok we're golden now, let's compute damage

				btl.dmg_downs[k][i] = false
				if v.atk_hpremaining == nil
					v.atk_hpremaining = v.hp	-- bruh bruh
				end

				btl.dmg_hits[k][i], btl.dmg_downs[k][i] = getDamage(v, mo, nil, true)	-- see ../ATTACK/Attack_Funcs
				-- the above precalculates damage and critical hits for the current hit
				if btl.dmg_hits[k][i] == "miss"
					continue	-- we missed, skip this
				end
				btl.dmg_hits[k][i] = $ or 0							-- just in case
				v.atk_hpremaining = $ - (btl.dmg_hits[k][i] or 0)	-- calculate remaining hp

				if v.atk_hpremaining <= 0
					fatal = true	-- this attack will kill!
				end

				if aff == DMG_WEAK
				and not v.boss
					btl.dmg_downs[k][i] = true
				end

				if btl.dmg_downs[k][i]
				and not v.down	-- don't cutin if the target is down already
				and not (v.allies == mo.allies)
				and not v ~= mo					-- don't onemore if we hit ourselves somehow
					if not atk.physical	-- lolno
						can_cutin = true
					end
					v.crituptheass2 = true
				end

				-- special case for physical attacks and characters
				if btl.dmg_downs[k][i]
				and atk.critanim
					btl.dmg_usecritanim = true
				end

				if v.linkstate
				and i == 1
				and atk.power
				and atk.type ~= ATK_HEAL
				and aff ~= DMG_DRAIN
				and btl.dmg_hits[k][1]
				and btl.dmg_hits[k][1] > 0	-- only positive (non heal) damage
					btl.linkhits[#btl.linkhits+1] = v
				end
			end
		end

		if mo.hudcutin
		and can_cutin	-- cut-ins only happen if an enemy gets knocked down
			mo.cutin = true	-- sure!
			VFX_Play(mo, VFX_CRIT)
		else
			if not mo.no_action_vfx
				VFX_Play(mo, VFX_SKILL)
			end
			mo.no_action_vfx = nil	-- reset this
		end
	end

	if mo.enemy_trans
		mo.enemy_trans = $-1
	end

	local targets = mo.targets
	if atk.anim_norepel
		targets = btl.oldtargetlist	-- don't hit ourselves in the animation, this would be quite tragic
	end

	local repelt

	for i = 1, #btl.oldtargetlist
		local t = btl.oldtargetlist[i]
		if not t or not t.valid continue end

			if t.repelspr	-- this MEANS that we have to repel
			and not mo.attack.anim_norepel	-- draw the repel mirror when we get damaged instead if this is true.
			-- otherwise, draw it as the animation starts:
				local x, y = t.x + 32*cos(t.angle), t.y + 32*sin(t.angle)
				local s = P_SpawnMobj(x, y, t.z+mo.height/2, MT_DUMMY)
				s.scale = FRACUNIT/2
				s.destscale = FRACUNIT*3
				s.scalespeed = FRACUNIT/3
				s.fuse = TICRATE
				s.sprite = t.repelspr
				s.frame = $|FF_PAPERSPRITE|FF_FULLBRIGHT
				s.angle = t.angle + ANG1*90
				S_StartSound(server.P_BattleStatus[t.battlen].cam, sfx_rflc)
				t.repelspr = nil
				t.repeltimer = TICRATE/2
			end

			if t.repeltimer
				repelt = t.repeltimer
				t.repeltimer = $-1
			end
	end

	if repelt
		if repelt == 1
			BTL_logMessage(mo.battlen, atk.name)	-- do it again I wasn't looking
		end
		return
	end	-- don't proceed until the repel animation is over

	if not atk.physical		-- we're not using a skill.

		if mo.t_forcecontrol
			-- summon persona:
			if mo.persona and not mo.persona.dontdraw
			and (not mo.summonpersona or not mo.summonpersona.valid)
			and not mo.t_summoned

				mo.summonpersona = P_SpawnMobj(0, 0, 0, MT_BTL_PERSONA)
				mo.summonpersona.target = mo
				mo.summonpersona.scale = 0
				mo.summonpersona.destscale = FRACUNIT*12/10
				mo.summonpersona.scalespeed = FRACUNIT/3

				mo.summonpersona.p_state = 1	-- idle
			end
		end

		doAttackAnim(mo, mo.cutin)
		if not doCamAnim(mo, mo.cutin)
			if not mo.itemname
			and not atk.physical
				local color
				if not mo.plyr then color = SKINCOLOR_RED end
				summonAura(mo, color)
			end
		return end	-- don't do anything until our cool attack pose is done
	else
		doCamAnim(mo)-- we'll probably just teleport the camera in this case
	end

	btl.atktimer = $+1
	mo.t_summoned = true	-- buffer for brainwash/ai control

	-- persona attack animation:
	if mo.summonpersona and mo.summonpersona.valid
		if mo.summonpersona.anim ~= mo.persona.anim_atk
			ANIM_set(mo.summonpersona, mo.persona.anim_atk)
		end
	end

	local param = btl.dmg_usecritanim and "critanim" or "anim"
	btl.dmg_actor = mo

	if not mo.targets
	or not mo.targets[1]
		mo.targets = btl.oldtargetlist
	elseif not btl.oldtargetlist
	or not btl.oldtargetlist[1]
		btl.oldtargetlist = mo.targets		-- fallback?
	end

	if atk[param](mo, btl.oldtargetlist, mo.targets, btl.atktimer)

		local isoffensive = (atk.target ~= TGT_ALLY and atk.target ~= TGT_ALLALLIES) and atk.power and not atk.luckbased

		/*if mo.powercharge
		and isoffensive
			if isAttackPhysical(atk) and not atk.physical	-- autoattack
				mo.powercharge = nil
			end
		end
		if mo.mindcharge
		and isoffensive
			if not isAttackPhysical(atk)
				mo.mindcharge = nil
			end
		end*/
		-- ^ Old behaviour, unused because it made these skills too polarizing.
		-- Instead, always get rid of them if you use any skill that doesn't give you the buff.

		if not atk.mindcharge
			mo.mindcharge = nil		-- remove charge
		end
		if not atk.powercharge
			mo.powercharge = nil	-- remove charge
		end

		-- evasion skills? Ready the timer.
		if atk.evasionskill
			if mo.guaranteedevasion	-- < Assume this is the first usage. The skill must manually unset it.
				mo.evasion = atk.evasionskill
				mo.evasionprint = atk.evasionprint	-- can be nil

				-- yes this is kind of annoying, alas...
				for k, a in pairs(attackDefs)
					if a == atk
						mo.evasionskill = k
						break
					end
				end
			else
				mo.evasionskill = nil
				mo.evasion = nil
				mo.evasionprint = nil
			end
		end

		for i = 1, #mo.targets
			local t = mo.targets[i]
			if not t or not t.valid continue end	--???
			t.cachestatus = nil
		end

		mo.t_forcecontrol = nil
		mo.t_summoned = nil
		btl.dmg_hits = nil	-- we don't need those anymore, to the trash, boo!
		btl.dmg_downs = nil
		btl.dmg_actor = nil
		btl.dmg_usecritanim = nil
		btl.atktimer = 0
		local cam = btl.cam
		cam.tp_en = nil
		cam.tp_en2 = nil	-- don't use those during attack anims, it might not go well
		cam.plyranim = nil
		cam.done = nil

		return true	-- this turn's done that you like it or not!
	end
end)


rawset(_G, "BTL_linkHandler", function(pn)
	local btl = server.P_BattleStatus[pn]

	-- do all links one by one.
	if #btl.linkhits

		local mo = btl.linkhits[1]

		if not (mo and mo.valid)
			table.remove(btl.linkhits, 1)
			return
		end

		if not btl.dmg_hits

			if not mo.hp	-- happens if a link skill killed an enemy.
			or (mo.enemy and not mo.deathanim and enemyList[mo.enemy].deathanim)	-- Very funny bug that CAN actually happen.
			-- This happens with Monad final boss where the Link can happen during the cutscene because of that, it's really stupid

				table.remove(btl.linkhits, 1)
				return
			end

			btl.atktimer = 0
			btl.dmg_actor = mo.linkstate.entref

			mo.dmg_index = 1
			mo.atk_attacker = btl.dmg_actor
			mo.atk_hitby = BTL_copyAttackDefs(attackDefs[mo.linkstate.atkref])
			resetDamage(mo)

			btl.dmg_hits = {}	-- damage taken
			btl.dmg_downs = {}	-- damage knockdown	(won't happen here but needs resetting anyway)

			-- link damage (base dmg + linkboost% * added links per new link)
			local linkdamage = mo.linkstate.dmg + (mo.linkstate.dmg*mo.linkstate.linkboost/100)*(mo.linkstate.link-1)

			-- links only down if they hit a weakness (no random crit)
			btl.dmg_downs[1] = {getAttackAff(mo, mo.atk_hitby, mo.atk_attacker) == DMG_WEAK}
			btl.dmg_hits[1] = {linkdamage}

			BTL_logMessage(pn, mo.atk_hitby.name)
		end

		-- now use the skill
		btl.atktimer = $+1
		--print(btl.atktimer)

		if attackDefs[mo.linkstate.atkref].anim(mo.atk_attacker, {mo}, {mo}, btl.atktimer)
			mo.atk_attacker.t_forcecontrol = nil
			mo.atk_attacker.t_summoned = nil
			btl.dmg_hits = nil	-- we don't need those anymore, to the trash, boo!
			btl.dmg_downs = nil
			btl.dmg_actor = nil
			btl.dmg_usecritanim = nil
			btl.atktimer = 0
			local cam = btl.cam
			cam.tp_en = nil
			cam.tp_en2 = nil	-- don't use those during attack anims, it might not go well
			cam.plyranim = nil
			cam.done = nil

			-- increase links and remove linkstate if need be:
			mo.linkstate.link = $+1
			if mo.linkstate.link >= mo.linkstate.maxlink
				mo.linkstate = nil
			end

			table.remove(btl.linkhits, 1)
		end
	else	-- no more link hits to do
		return true
	end
end)

rawset(_G, "BTL_deadEnemiescleanse", function(btl)
	-- check for dead entities!
	/*for k,v in ipairs(btl.fighters)
		if v and v.valid and not v.hp and v.enemy and not v.plyr
			--P_RemoveMobj(v)
		end
	end*/

	/*
		Do not handle straight up removal of the mobj here, if we do this, enemies that killed themselves with repelled attacks would softlock the game
	*/

	-- update userdata tables (remove indexes for the entities we may have killed above)
	--updateUDtable_nohp(btl.fighters)
	updateUDtable_nohp(btl.turnorder)

	local playerref

	local t1
	local t2
	for k,v in ipairs(btl.fighters)
		if not v.valid continue end	-- wat
		updateUDtable(v.enemies)
		updateUDtable(v.allies)
		updateUDtable_nohp(v.enemies)
		updateUDtable_nohp(v.allies)

		updateUDtable(v.allies_noupdate)
		updateUDtable(v.enemies_noupdate)	-- update for .valid still
		if v.plyr and not playerref
			t1 = v.allies
			t2 = v.enemies
			playerref = true
		end
	end

	return t1 or {}, t2 or {}
end)


-- removes any entity with no HP that isn't a core entity
rawset(_G, "BTL_fullCleanse", function(btl)
	for k,v in ipairs(btl.fighters)
		if v and v.valid and not v.hp and v.enemy and not v.plyr and not v.corentity
			P_RemoveMobj(v)
		end
	end
	updateUDtable(btl.fighters)
	updateUDtable(btl.turnorder)

	for k,v in ipairs(btl.fighters)
		if not v.valid continue end	-- wat
		updateUDtable(v.enemies)
		updateUDtable(v.allies)
		updateUDtable_nohp(v.enemies)
		updateUDtable_nohp(v.allies)
		updateUDtable(v.allies_noupdate)
		updateUDtable(v.enemies_noupdate)	-- update for .valid still
	end
end)

rawset(_G, "statusConditionEffects", function(mo)	-- the little animations over the enemy's head when that happens
	if not mo or not mo.valid or not mo.hp return end
	if mo.hp <= 0 return end

	-- down:
	-- note: down isn't actually a status condition but still has its visual handled here because it's close enough
	if mo.down
		local an = leveltime * ANG1 * 8
		for i = 1, 2 do
			local dx = mo.x + 64*cos(an)
			local dy = mo.y + 64*sin(an)
			local dz = mo.z + mo.height + 12*sin(an + leveltime*ANG1*4)
			local s = P_SpawnMobj(dx, dy, dz, MT_DUMMY)
			s.state = S_SPRK1
			s.scale = FRACUNIT*2
			s.destscale = 0
			s.frame = A|FF_FULLBRIGHT
			s.tics = 1
			if (leveltime%2)
				s.fuse = 2
			end
			an = $+ ANG1*180
		end
	end

	-- fields that spawn particles i guess??
	if mo.fieldstate

		if mo.fieldstate.type == FLD_ZIOVERSE

			if leveltime%2 == 0

				local x = mo.x + P_RandomRange(-64, 64)*mo.scale
				local y = mo.y + P_RandomRange(-64, 64)*mo.scale
				local z = mo.z + P_RandomRange(-64, 64)*mo.scale

				P_SpawnMobj(x, y, z, MT_SUPERSPARK)

			end

		elseif mo.fieldstate.type == FLD_AGIVERSE

			local rfac = (mo.maxhp + mo.maxsp) - mo.level

			local ang = (rfac + leveltime)*ANG1*12
			local zpos = mo.z + 32*mo.scale + 32*sin((rfac + leveltime)*ANG1*8)

			local x = mo.x + 64*cos(ang)
			local y = mo.y + 64*sin(ang)
			local f = P_SpawnMobj(x, y, zpos, MT_DUMMY)
			f.tics = 2
			f.sprite = SPR_FPRT
			f.frame = $ & ~FF_TRANSMASK
			f.frame = $|FF_FULLBRIGHT|TR_TRANS20
			f.scale = mo.scale*5/2

			local g = P_SpawnGhostMobj(f)
			g.destscale = 1
			g.scalespeed = FRACUNIT/4
		end
	end

	-- uh, i mean i guess we can count tetrakarn / makrakarn / mind charge / power charge as special effects too~

	if server.P_BattleStatus[mo.battlen]
	and server.P_BattleStatus[mo.battlen].battlestate == BS_DOTURN

		if (mo.tetrakarn or mo.makarakarn or mo.tetraja)
		and leveltime%2

			local x, y = mo.x + 32*cos(mo.angle), mo.y + 32*sin(mo.angle)
			local s = P_SpawnMobj(x, y, mo.z+mo.height/2, MT_DUMMY)
			s.scale = mo.scale
			s.fuse = 2
			if mo.tetraja
				s.sprite = SPR_ELEM
			else
				s.sprite = mo.tetrakarn and SPR_FORC or SPR_ARMA
			end
			s.frame = $|FF_PAPERSPRITE|FF_FULLBRIGHT |FF_TRANS50
			s.angle = mo.angle + ANG1*90
		end
	end

	-- mind charge
	if mo.mindcharge
		if not (leveltime%4)
			local elec = P_SpawnMobj(mo.x, mo.y, mo.z + mo.height/2, MT_DUMMY)
			elec.sprite = SPR_DELK
			elec.frame = P_RandomRange(0, 7)|FF_FULLBRIGHT
			elec.destscale = FRACUNIT*4
			elec.scalespeed = FRACUNIT/4
			elec.tics = TICRATE/8
			elec.color = SKINCOLOR_CYAN
		end

		if leveltime %4 == 0
			local a = R_PointToAngle(mo.x, mo.y)
			local x = mo.x - cos(a)
			local y = mo.y - sin(a)

			local dummy = P_SpawnMobj(x, y, mo.z, MT_DUMMY)
			if mo.skin
				dummy.skin = mo.skin
			end
			dummy.state = mo.state
			dummy.sprite = mo.sprite
			dummy.sprite2 = mo.sprite2
			dummy.frame = mo.frame
			dummy.angle = mo.angle
			dummy.scale = mo.scale
			dummy.colorized = true
			dummy.color = SKINCOLOR_CYAN
			dummy.fuse = 2
		end
	end

	-- power charge
	if mo.powercharge
		if not (leveltime%4)
			local elec = P_SpawnMobj(mo.x, mo.y, mo.z + mo.height, MT_DUMMY)
			elec.sprite = SPR_DELK
			elec.frame = P_RandomRange(0, 7)|FF_FULLBRIGHT
			elec.destscale = FRACUNIT*4
			elec.scalespeed = FRACUNIT/4
			elec.tics = TICRATE/8
			elec.color = SKINCOLOR_CRIMSON
		end

		if leveltime %4 == 0
			local a = R_PointToAngle(mo.x, mo.y)
			local x = mo.x - cos(a)
			local y = mo.y - sin(a)

			local dummy = P_SpawnMobj(x, y, mo.z, MT_DUMMY)
			if mo.skin
				dummy.skin = mo.skin
			end
			dummy.state = mo.state
			dummy.sprite = mo.sprite
			dummy.sprite2 = mo.sprite2
			dummy.frame = mo.frame
			dummy.angle = mo.angle
			dummy.scale = mo.scale
			dummy.colorized = true
			dummy.color = SKINCOLOR_CRIMSON
			dummy.fuse = 2
		end
	end

	-- guaranteed evasion
	if mo.guaranteedevasion
		if leveltime%10 == 0

			local g = P_SpawnGhostMobj(mo)
			g.colorized = true
			g.destscale = mo.scale*4
			g.scalespeed = mo.scale/12

			g = P_SpawnGhostMobj(mo)
			g.colorized = true
			g.destscale = mo.scale*4
			g.scalespeed = mo.scale/6
		end
	end

	-- oh boy I wish Lua had switch cases LOL
	-- burn

	if mo.status_condition == COND_BURN
		local steam = P_SpawnMobj(mo.x+P_RandomRange(-45, 45)*mo.scale, mo.y+P_RandomRange(-45, 45)*mo.scale, mo.z+P_RandomRange(5, 30)*mo.scale, MT_SMOKE)
		P_SetObjectMomZ(steam, P_RandomRange(1, 3)*mo.scale)

		if not (leveltime%2)
			local fire = P_SpawnMobj(mo.x+P_RandomRange(-45, 45)*mo.scale, mo.y+P_RandomRange(-45, 45)*FRACUNIT, mo.z+P_RandomRange(5, 30)*mo.scale, MT_DUMMY)
			fire.sprite = SPR_FPRT
			fire.frame = $ & ~FF_TRANSMASK
			fire.frame = $|FF_FULLBRIGHT|TR_TRANS20
			fire.scale = mo.scale*5/2
			fire.momz = P_RandomRange(1, 3)*mo.scale
			fire.scalespeed = mo.scale/12
			fire.destscale = 1
			fire.tics = TICRATE
		end

	-- poison
	elseif mo.status_condition == COND_POISON
		for i = 1,2
			local psn = P_SpawnMobj(mo.x+P_RandomRange(-15,15)*FRACUNIT, mo.y+P_RandomRange(-15,15)*FRACUNIT, mo.z+P_RandomRange(0,15)*FRACUNIT, MT_DUMMY)
			psn.sprite = SPR_THOK
			psn.frame = A
			psn.color = SKINCOLOR_PURPLE
			psn.scale = FRACUNIT/2
			psn.destscale = FRACUNIT/99
			psn.momz = P_RandomRange(5, 12)*FRACUNIT
			psn.tics = TICRATE
		end

	-- brainwash: <3 <3 <3
	elseif mo.status_condition == COND_BRAINWASH

		for i = 1, 2
			local s = P_SpawnMobj(mo.x + P_RandomRange(-32, 32)*FRACUNIT, mo.y + P_RandomRange(-32, 32)*FRACUNIT, mo.z + 32*FRACUNIT, MT_DUMMY)
			s.sprite = SPR_LOVE
			s.frame = P_RandomRange(0, 2)|FF_FULLBRIGHT|FF_TRANS30
			s.momz = P_RandomRange(2, 5)*FRACUNIT
			s.scale = P_RandomRange(FRACUNIT*3/4, FRACUNIT*3/2)
			s.destscale = 1
			s.tics = TICRATE*3/2
		end

	-- dizzy: stars above the head or whatvs
	elseif mo.status_condition == COND_DIZZY

		for i = 1, 3
			local s = P_SpawnMobj(mo.x + P_RandomRange(-32, 32)*FRACUNIT, mo.y + P_RandomRange(-32, 32)*FRACUNIT, mo.z + 32*FRACUNIT, MT_DUMMY)
			s.sprite = SPR_STUN
			s.frame = P_RandomRange(0, 2)|FF_FULLBRIGHT|FF_TRANS30
			s.color = P_RandomRange(0,1) and SKINCOLOR_LAVENDER or SKINCOLOR_ORANGE
			s.momz = P_RandomRange(2, 5)*FRACUNIT
			s.scale = P_RandomRange(FRACUNIT/2, FRACUNIT)
			s.destscale = 1
			s.tics = TICRATE*3/2
		end

	elseif mo.status_condition == COND_HEX

		for i = 1, 3
			local s = P_SpawnMobj(mo.x + P_RandomRange(-32, 32)*FRACUNIT, mo.y + P_RandomRange(-32, 32)*FRACUNIT, mo.z + 32*FRACUNIT, MT_DUMMY)
			s.sprite = SPR_FEAR
			s.frame = P_RandomRange(0, 1)|FF_FULLBRIGHT
			s.momz = P_RandomRange(2, 5)*FRACUNIT
			s.scale = P_RandomRange(FRACUNIT/2, FRACUNIT)
			s.destscale = 1
			s.tics = TICRATE*3/2
		end

	elseif mo.status_condition == COND_HUNGER	-- ez just vore smth lol

		local thok = P_SpawnMobj(mo.x+P_RandomRange(-40, 40)*FRACUNIT, mo.y+P_RandomRange(-40, 40)*FRACUNIT, mo.z+P_RandomRange(20, 60)*FRACUNIT, MT_DUMMY)
		thok.sprite = SPR_SUMN
		thok.frame = F|FF_FULLBRIGHT|TR_TRANS30
		thok.momz = -P_RandomRange(6, 16)*FRACUNIT
		thok.color = SKINCOLOR_GREEN
		thok.tics = P_RandomRange(10, 35)

	-- GO TO SLEEP -Cae-sama
	elseif mo.status_condition == COND_SLEEP

		if leveltime%16 == 0
			local s = P_SpawnMobj(mo.x, mo.y, mo.z + 32*FRACUNIT, MT_DUMMY)
			s.sprite = SPR_SLEP
			s.frame = FF_FULLBRIGHT
			s.momz = P_RandomRange(2, 5)*FRACUNIT
			s.scale = P_RandomRange(FRACUNIT, FRACUNIT*3/2)
			P_InstaThrust(s, P_RandomRange(0, 359)*ANG1, 4<<FRACBITS)
			s.destscale = 1
			s.tics = TICRATE*3/2
		end

	-- shock: shake and spawn yellow sparks
	elseif mo.status_condition == COND_SHOCK
		mo.flags2 = $|MF2_DONTDRAW
		local dummy = P_SpawnMobj(mo.x + P_RandomRange(-4, 4)*FRACUNIT, mo.y + P_RandomRange(-4, 4)*FRACUNIT, mo.z, MT_DUMMY)
		if mo.skin
			dummy.skin = mo.skin
		end
		dummy.state = mo.state
		dummy.sprite = mo.sprite
		dummy.sprite2 = mo.sprite2
		dummy.frame = mo.frame
		dummy.angle = mo.angle
		dummy.scale = mo.scale
		dummy.color = mo.color
		dummy.fuse = 2

		if not (leveltime%4)
			local elec = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
			elec.sprite = SPR_DELK
			elec.frame = P_RandomRange(0, 7)|FF_FULLBRIGHT
			elec.destscale = FRACUNIT*4
			elec.scalespeed = FRACUNIT/4
			elec.tics = TICRATE/8
			elec.color = SKINCOLOR_YELLOW
		end

	-- silence! make as much noise as kanade (so none, dipshit)
	elseif mo.status_condition == COND_SILENCE

		local cam = server.P_BattleStatus[mo.battlen].cam

		local startx = mo.x + 20*cos(cam.angle-ANG1*90)
		local starty = mo.y + 20*sin(cam.angle-ANG1*90)

		local glan = R_PointToAngle(startx, starty)
		local glx = startx - 4*cos(glan)
		local gly = starty - 4*sin(glan)

		local stfu = P_SpawnMobj(glx, gly, mo.z + 48*FRACUNIT, MT_DUMMY)
		stfu.sprite = SPR_STFU
		stfu.frame = ((leveltime%21)/7)|FF_FULLBRIGHT
		stfu.tics = 2

	-- despair, teloli moment
	elseif mo.status_condition == COND_DESPAIR

		local cam = server.P_BattleStatus[mo.battlen].cam

		local startx = mo.x + 20*cos(cam.angle-ANG1*90)
		local starty = mo.y + 20*sin(cam.angle-ANG1*90)

		local glan = R_PointToAngle(startx, starty)
		local glx = startx - 4*cos(glan)
		local gly = starty - 4*sin(glan)

		local sad = P_SpawnMobj(glx, gly, mo.z + 48*FRACUNIT + P_RandomRange(-1, 1)*FRACUNIT, MT_DUMMY)
		sad.sprite = SPR_DESP
		sad.frame = FF_FULLBRIGHT
		sad.tics = 2

	-- rage (zxys tsun tsun mode~)
	elseif mo.status_condition == COND_RAGE

		local cam = server.P_BattleStatus[mo.battlen].cam

		local startx = mo.x + 20*cos(cam.angle-ANG1*90) + P_RandomRange(-1, 1)*FRACUNIT
		local starty = mo.y + 20*sin(cam.angle-ANG1*90) + P_RandomRange(-1, 1)*FRACUNIT

		local glan = R_PointToAngle(startx, starty)
		local glx = startx - 10*cos(glan)
		local gly = starty - 10*sin(glan)

		local tsun = P_SpawnMobj(glx, gly, mo.z + 48*FRACUNIT + P_RandomRange(-1, 1)*FRACUNIT, MT_DUMMY)
		tsun.sprite = SPR_TSUN
		tsun.frame = FF_FULLBRIGHT
		tsun.scale = (leveltime%20 < 10) and FRACUNIT or FRACUNIT*3/4
		tsun.tics = 2

	-- freeze
	elseif mo.status_condition == COND_FREEZE

		local dust = P_SpawnMobj(mo.x+P_RandomRange(-64, 64)*FRACUNIT, mo.y+P_RandomRange(-64, 64)*FRACUNIT, mo.z+P_RandomRange(0, 64)*FRACUNIT, MT_DUMMY)
		dust.flags = $|MF_NOGRAVITY|MF_NOCLIPHEIGHT
		dust.state, dust.scale, dust.angle = S_BUFUDYNE_DUST1, FRACUNIT, 0
		dust.destscale = FRACUNIT*9/4
		dust.scalespeed = FRACUNIT/18
		dust.momz = 5*FRACUNIT/2

	-- hyper mode!
	elseif mo.status_condition == COND_HYPER

		-- spawn periodically flashing dummy
		local glan = R_PointToAngle(mo.x, mo.y)
		local glx = mo.x - 2*cos(glan)
		local gly = mo.y - 2*sin(glan)

		local inv = P_SpawnMobj(glx, gly, mo.z, MT_DUMMY)
		inv.fuse = 2
		inv.sprite = SPR_HYPR
		inv.frame = (leveltime%8) /2
		inv.scale = mo.scale

		if leveltime%8 == 0

			glx = mo.x - cos(glan)
			gly = mo.y - sin(glan)

			local dum = P_SpawnMobj(glx, gly, mo.z, MT_DUMMY)

			dum.state = mo.state
			dum.sprite = mo.sprite
			if mo.skin
				dum.skin = mo.skin
				dum.sprite2 = mo.sprite2
			end
			dum.frame = mo.frame|FF_FULLBRIGHT
			dum.color = SKINCOLOR_WHITE
			dum.colorized = true
			dum.angle = mo.angle
			dum.color = mo.color
			dum.scale = mo.scale
			dum.flags = MF_NOGRAVITY|MF_BOSS|MF_NOCLIPTHING
			dum.fuse = 2
		end

	elseif mo.status_condition == COND_SUPER
		-- super colour:
		local supercolor = charStats[mo.stats].supercolor_start
		if supercolor
			mo.color = min((supercolor + abs(((leveltime >> 1) % 9) - 4)), #skincolors - 1)
		else
			-- super orb
			local scale = charStats[mo.stats].superorbscale or FRACUNIT*12/10
			local caman = R_PointToAngle(mo.x, mo.y)

			local orb = P_SpawnMobj(mo.x - cos(caman), mo.y - sin(caman), mo.z, MT_DUMMY)
			orb.sprite = SPR_SORB
			orb.frame = FF_FULLBRIGHT|FF_TRANS30| (leveltime%16 / 2)
			orb.fuse = 2
		end
	end
end)

addHook("MobjThinker", statusConditionEffects, MT_PFIGHTER)	-- apply above's thinker


rawset(_G, "BTL_handleStatusConditions", function(pn, timer)
	local btl = server.P_BattleStatus[pn]
	local mo = btl.turnorder[1]
	local cam = btl.cam

	if not mo return true end	-- well uh shit?
	if not mo.status_condition return true end	-- go on, go on
	if mo.status_condition_pass return true end	-- that means we already did this

	if timer == 1		-- not that the camera should do anything else
		resetEntitiesPositions(pn)
	end

	if mo.status_condition == COND_BURN	-- Ca bruuuule

		if timer == 1
			status_cam(mo)
			mo.status_turns = $+1
		elseif timer == 5
			BTL_logMessage(pn, mo.name.. " is damaged by their burn.")
		elseif timer == 30
			playSound(mo.battlen, sfx_fire1)
			local fire = P_SpawnMobj(mo.x, mo.y, mo.z, MT_BOSSEXPLODE)
			fire.state = S_QUICKBOOM1
			fire.scale = FRACUNIT*3/2
			local damage = mo.maxhp/20
			if mo.hp - damage < 1
				damage = mo.hp-1
			end
			damageObject(mo, damage, DMG_NORMAL)
			if mo.hp == 1
			or (mo.boss and mo.status_turns > 2)
				BTL_logMessage(pn, "The burn wore off.")
			end
		elseif timer >= 75
			if mo.hp == 1
			or (mo.boss and mo.status_turns > 2)
				mo.status_condition = nil
				mo.status_turns = nil
			end
			return true
		end

	elseif mo.status_condition == COND_POISON	-- poison

		if timer == 1
			status_cam(mo)
			mo.status_turns = $+1
		elseif timer == 5
			BTL_logMessage(pn, mo.name.. " is damaged by poison")
		elseif timer == 30
			playSound(mo.battlen, sfx_absorb)
			local damage = mo.maxhp/20
			if mo.hp - damage < 1
				damage = mo.hp-1
			end
			damageObject(mo, damage, DMG_NORMAL)
			if mo.hp == 1
			or (mo.boss and mo.status_turns > 2)
				BTL_logMessage(pn, "The poison wore off.")
			end
		elseif timer >= 75
			if mo.hp == 1
			or (mo.boss and mo.status_turns > 2)
				mo.status_condition = nil
				mo.status_turns = nil
			end
			return true
		end

	elseif mo.status_condition == COND_DESPAIR	-- depresso

		if timer == 1
			status_cam(mo)
			mo.status_turns = $+1
		elseif timer == 5
			BTL_logMessage(pn, mo.name.. " is hit by desperation...")
		elseif timer == 30
			playSound(mo.battlen, sfx_absorb)
			local damage = mo.maxsp/20
			if mo.boss
				damage = min(10, mo.maxsp/50)
			end

			if mo.sp - damage < 1
				damage = mo.sp-1
			end
			mo.damagestate = DMG_NORMAL
			mo.damageflags = DF_SP
			damageSP(mo, damage)
			if mo.sp == 1
			or (mo.boss and mo.status_turns > 2)
				BTL_logMessage(pn, "The despair went away")
			end
		elseif timer >= 75
			if mo.sp == 1
			or (mo.boss and mo.status_turns > 2)
				mo.status_condition = nil
				mo.status_turns = nil
			end
			return true
		end

	elseif mo.status_condition == COND_HYPER
		mo.status_turns = $ or 0

		if timer == 1
			if not mo.extra
				mo.status_turns = $+1
			end
			if mo.status_turns >= 3
				BTL_logMessage(pn, "Hyper Mode wore off...")
				status_cam(mo)
			else
				return true
			end
		elseif timer == TICRATE
			-- this here only happens if hyper mode wears off
			mo.status_condition = 0
			mo.status_turns = 0
			BTL_setupstats(mo)	-- reset the stats from hyper mode
			--btl.emeraldpow_buffer = false	-- can use hyper mode again
		end

	elseif mo.status_condition == COND_SUPER
	and not btl.superform	-- free super formes
		mo.status_turns = $ or 0
		if timer == 1

			if mo.status_turns > 1	-- skip the first turn, it's free.
			and btl.emeraldpow >= 100
				btl.emeraldpow = max(0, $-100)
			end

			mo.status_turns = $+1

			if btl.emeraldpow < 100
			or (btl.emeraldpow_max < 7 and not btl.superform)
				BTL_logMessage(pn, mo.name.."'s Super Form wore off...")
				status_cam(mo)
			else
				return true
			end

		elseif timer == TICRATE
			mo.status_condition = 0
			mo.status_turns = 0
			if mo.control and mo.control.maincontrol == mo
				mo.color = mo.control.mo.color
			else
				mo.color = skins[mo.skin].prefcolor
			end
			BTL_setupstats(mo)	-- akin to hypermode
			ANIM_set(mo, mo.anim_stand)
		end
	else
		return true	-- status condition not handled here
	end
end)

rawset(_G, "BTL_initHoldup", function(btl, t)

	btl.netstats.holdups = $+1

	resetEntitiesPositions(btl.n)	-- in case of modifications from melee attacks
	local x,y,z,an,ai = CAM_defaultcoords(btl.turnorder[1])
	CAM_goto(btl.cam, x, y, z)
	CAM_angle(btl.cam, an)
	CAM_aiming(btl.cam, ai)

	local ref = t[1]
	for k,v in ipairs(ref.enemies)
		if v.endboss	-- special finsher for endboss
			btl.holdupfinish = true
		end
	end

	btl.holdupadv = t	-- remember which team initiated the holdup. this will avoid us having to process that again
	btl.hudtimer.holdupstart = TICRATE*2

	btl.battlestate = BS_HOLDUP
end)

rawset(_G, "BTL_endturnHandler", function(pn)
	local btl = server.P_BattleStatus[pn]
	local mo = btl.turnorder[1]
	if not mo or not mo.valid
		--print("\x82".."WARNING".."\x80"..": No valid entity at the end of the turn? Be careful how you use those debug commands!")
		for k,v in ipairs(btl.fighters)
			if v and v.valid
				mo = v
				btl.turnorder[1] = v
				--print("Using entity "..k.." ("..v.name..") as a backup for reference. Battle flow may be altered.")
				break
			end
		end
	end
	
	if not mo.t_passivebuffer
		for i = 1, #mo.passiveskills
			local psv = mo.passiveskills[i]
			if attackDefs[psv]
				psv = attackDefs[$]
				if psv.passive == PSV_ENDTURN and mo.t_passivestuff < i
					mo.t_passivestuff = i
					mo.t_passivebuffer = i
					mo.t_passivetimer = 0	-- reset this timer
					break	-- ^ this is the skill we're going to use
				end
			end
		end
	end
	
	if mo.t_passivebuffer
		-- tp cam to us:
		local cam = btl.cam
		--CAM_stop(cam)
		local x, y = mo.x + 320*cos(mo.angle + ANG1*50), mo.y + 320*sin(mo.angle + ANG1*50)
		P_TeleportMove(cam, x, y, mo.z + FRACUNIT*80)
		cam.angle = R_PointToAngle2(cam.x, cam.y, mo.x, mo.y)
		cam.aiming = -ANG1*2
		CAM_stop(cam)

		mo.atk_attacker = mo	-- makes these function correctly, we don't get getDamage for this, so we have to set it manually.
		local atk = attackDefs[mo.passiveskills[mo.t_passivebuffer]]
		mo.atk_hitby = BTL_copyAttackDefs(atk)	-- ditto
		if mo.t_passivetimer == 1
			BTL_logMessage(mo.battlen, atk.name)
		end
		if atk.anim(mo, {mo}, {mo}, mo.t_passivetimer)
			mo.t_passivebuffer = 0
			mo.t_passivetimer = 0
		end
		mo.t_passivetimer = $ +1
		return
	end

	-- before we cleanse, iterate t2 for dead enemies with extra flag for blowup seq
	for k,v in ipairs(btl.fighters)

		if v and v.valid and v.deathanim and v.hp <= 0
			return
		end

		if v and v.valid and v.hu_deadanim and not v.extra and v.hu_deadanim < 13
			-- deadanim at 13 is considered finished
			return	-- wait for deadanim to finish playing before cleansing
		end

		if v and v.valid and v.hp <= 0 and v.extra
			btl.extra_blowuptarget = v
			btl.extra_blowuptime = 0
			btl.battlestate = BS_HYPERDIE
			return
		end
	end

	local t1, t2 = BTL_deadEnemiescleanse(btl)
	-- don't forget to use BTL_fullCleanse(btl) to remove dead enemy objects once they aren't needed anymore


	-- voidrun: if timer hits 0 at the end of a turn, kill all enemies and end the battle!
	if server.gamemode == GM_VOIDRUN
	and server.P_DungeonStatus.VR_timer <= 0
		for i = 1, #t2 do
			local e = t2[i]
			e.hp = 0
			e.flags2 = $ | MF2_DONTDRAW

			local fake = P_SpawnMobj(e.x, e.y, e.z, MT_THOK)
			fake.sprite = e.sprite
			fake.angle = e.angle
			fake.frame = e.frame
			fake.scale = e.scale
			fake.tics = -1
			fake.fuse = 10
		end
		t1, t2 = BTL_deadEnemiescleanse(btl)	-- do this again since we just fake-killed enemies lol
	end

	-- are there any teams left?
	if server.gamemode == GM_PVP
		if not #t1 or not #t2
			BTL_fullCleanse(btl)
			for i = 1, 4
				btl.battlestate = BS_PVPOVER
				btl.hudtimer.pvpend = TICRATE*3
				return
			end
		end
	end

	if not #t1			-- all players are dead
	or (server.gamemode == GM_VOIDRUN and server.P_DungeonStatus.VR_lives <= 0)
	-- do game over sequence

		if server.gamemode == GM_VOIDRUN
		and server.P_DungeonStatus.VR_lives	-- we still have lives!!
			btl.turnorder = {}	-- let's cheat, this will force party members to be revived, otherwise things break lol
			btl.battlestate = BS_PRETURN
			print("Don't gameover")
			return
		end

		if server.gamemode ~= GM_VOIDRUN
		or server.P_DungeonStatus.VR_lives
			for p in players.iterate do
				if p and p.P_party == pn
					S_FadeOutStopMusic(MUSICRATE*2, p)
				end
			end
		end

		if server.gamemode == GM_CHALLENGE
			btl.battlestate = BS_CHALLENGEEND
			btl.hudtimer.challengeend = TICRATE*5
			btl.challengewon = nil
			BTL_fullCleanse(btl)
			return
			-- yep, that's a loss
		end

		if not btl.gameover
			btl.gameover = 1
		end
		btl.gameover = $+1

		if btl.gameover == TICRATE
			--D_startEvent("ev_gameover")
			-- ^ that's for singleplayer
			BTL_fullCleanse(btl)
			btl.battlestate = BS_GAMEOVER
			btl.hudtimer.gameover = TICRATE
			btl.hudtimer.gameovertimeout = TICRATE*5
			btl.gameoverchoice = 0
		end

		-- start the event
		if D_eventHandler(pn) return end	-- cutscene running, don't proceed

		return
	elseif not #t2		-- all enemies are dead

		-- revive our dead players and remove status conditions
		-- also remove the added skills from skill cards and subpersonas, we don't want to carry those over :yikes:

		local mo = server.plentities[pn][1]
		if server.gamemode ~= GM_CHALLENGE	-- bruh.
		and not (btl.storedwaves and #btl.storedwaves and btl.waven < #btl.storedwaves)
			for i = 1, #mo.allies_noupdate
				local m = mo.allies_noupdate[i]

				m.skills = copyTable(m.saveskills)
				table.sort(m.skills, attackSortFunc)	-- re-sort in case we learned something new.
				-- we don't NEED to remove passiveskills since it'll get reset by the next battle anyway.

				if not m.hp
					--dprint("Reviving player "..m.name)
					revivePlayer(m)
					m.hp = 1
				end
			end
		end

		if server.gamemode == GM_CHALLENGE
		or (btl.storedwaves and #btl.storedwaves)	-- multi-wave battles

			btl.waven = $+1	-- increase wave and check if we got more!

			if server.gamemode == GM_CHALLENGE
			and btl.scoremode
				if btl.waven > #BTL_challengebtllist[btl.challengen].waves
					btl.waven = 1	-- restart
				end

				BTL_addScore(pn, 5000, "Wave completed!")
			end

			-- If we killed an enemy with a 1more, it will technically linger and give us a nonsensical 1more next time we act.
			-- So we must get rid of it here
			if mo and mo.valid
				mo.setonemore = nil
			end

			local wave = btl.storedwaves
			if server.gamemode == GM_CHALLENGE
				wave = BTL_challengebtllist[btl.challengen].waves
			end

			if wave[btl.waven]
				-- There are still waves to be had!

				resetEntitiesPositions(pn)
				CAM_stop(btl.cam)
				btl.turnorder = BTL_BuildTurnOrder(pn)
				btl.cam.goto = {}
				btl.cam.momx = 0
				btl.cam.momy = 0
				btl.cam.momz = 0
				local fd = btl.cam.firstdefault
				P_TeleportMove(btl.cam, fd[1], fd[2], fd[3])
				btl.cam.angle = fd[4]
				btl.cam.aiming = 0
				btl.nextwave = wave[btl.waven]
				btl.hudtimer.moreenemies = TICRATE*5/2
				btl.battlestate = BS_MOREENEMIES
				BTL_fullCleanse(btl)
				return
			end

			if server.gamemode == GM_CHALLENGE

				for p in players.iterate do
					if p and p.P_party == pn
						S_StopMusic(p)
					end
				end

				-- wow, you have winned
				-- all enemies cleared, go to challenge mode result screen

				btl.battlestate = BS_CHALLENGEEND
				btl.challengewon = true	-- yes, you won, used to know what graphic to display
				btl.hudtimer.challengeend = TICRATE*5
				BTL_fullCleanse(btl)
				return
			end
		end

		-- do end of battle screen
		--S_ChangeMusic("AFTRBL")
		if not btl.shuffletimer
			for p in players.iterate do
				if p and p.P_party == pn

					local winquote = P_RandomRange(1, #server.plentities[p.P_party])
					for i = 1, #server.plentities[p.P_party]
						if i == winquote
						and btl.r_exp	-- no exp = run away
							VFX_Play(server.plentities[p.P_party][i], VFX_WIN, nil, p)
						end
					end

					if server.gamemode ~= GM_VOIDRUN
						S_FadeOutStopMusic(MUSICRATE, p)
					end
				end
			end
		end

		-- endboss finisher:
		if btl.holdupfinish
		-- check for tartarus netgame here
			btl.battlestate = BS_MPFINISH
			btl.hudtimer.mpfinish = TICRATE*6
			BTL_fullCleanse(btl)
			btl.netstats.wins = $+1	-- count that as a win!

			-- Do Tartarus specific unlocks etc:
			if server.gamemode == GM_COOP
				if mapheaderinfo[gamemap].tartarus

					-- Finished Block 6 / Marathon mode (both work to unlock Monad)

					if server.difficulty >= 6
					and not srb2p.local_conds[UNLOCK_B7]
						for p in players.iterate do
							P_unlock(UNLOCK_B7, p, "The Monad Block is now available from Rogue Mode!")
						end
					end

					-- Finished block 7:
					if server.difficulty == 7
					and not server.marathon	-- ?
					and not srb2p.local_conds[UNLOCK_B7_FINISHED]
						P_unlock(UNLOCK_B7_FINISHED)		-- Silent unlock
					end
				end

				-- Finished Marathon
				if server.marathon
					if not srb2p.local_conds[UNLOCK_B7]
						for p in players.iterate do
							P_unlock(UNLOCK_B7, p, "The Monad Block is now available from Rogue Mode!")
						end
					end
					if not srb2p.local_conds[UNLOCK_MR_FINISHED]
						P_unlock(UNLOCK_MR_FINISHED)		-- Silent unlock
					end

				end
			end
			-- Finished Void Run
			if server.gamemode == GM_VOIDRUN
			and not srb2p.local_conds[UNLOCK_VR_FINISHED]
				P_unlock(UNLOCK_VR_FINISHED)
			end

			return
		end

		-- we must know whether we should have a shuffle time first
		-- AKA: quick finish, did AOA in battle or 1/6 random

		if (btl.turn <= 1 or btl.aoa or not P_RandomRange(0, 6))	-- lol debug
		and not btl.shuffletimer	-- < we already did shuffletime
		and not btl.runaway
		and not btl.holdupfinish	-- for 1p
		and not SAVE_localtable.tutorial		-- not during tutorials
		and not (server.gamemode == GM_VOIDRUN)	-- not in void run.
			btl.battlestate = BS_SHUFFLE
			btl.hudtimer.shufflestart = TICRATE*3/2

			-- for wand cards:
			btl.r_baseexp = btl.r_exp
			btl.r_basemoney = btl.r_money
			btl.r_expmultiplier = 0
			btl.r_moneymultiplier = 0
			btl.r_healhp = 0
			btl.r_healsp = 0
			btl.r_expmultipliers = {}
			btl.r_moneymultipliers = {}
			btl.r_healhps = {}
			btl.r_healsps = {}
			return
		end

		-- Iterate through mo's party and check for passive skills with PSV_ENDBATTLE
		for i = 1, #mo.allies
			local v = mo.allies[i]
			dprint("Executing PSV_ENDBATTLE passives for "..v.name)
			for j = 1, #v.passiveskills
				local psv = v.passiveskills[j]
				if attackDefs[psv]
					psv = attackDefs[$]
					if psv.passive == PSV_ENDBATTLE
					and psv.anim
						psv.anim(v, {v}, {v}, 1)	-- Execute this skill's anim function on myself ONCE.
					end
				end
			end

			PLYR_getStats(v, v.level, true)
		end

		btl.battlestate = BS_END
		btl.hudtimer.endb = TICRATE*3/2
		btl.r_precalculates = {}

		-- obtain random roll items
		if not btl.runaway
		--and mo.attack ~= attackDefs["run"]
			local tbl = server.items
			local newtable = {}
			if tbl
				for k,v in ipairs(tbl)
					for j = 1, v[2]
						newtable[#newtable+1] = v[1]
					end
				end
			end
		end

		BTL_fullCleanse(btl)
		return
	end

	-- challenge mode: time's up!
	if server.gamemode == GM_CHALLENGE
	and not btl.timer
		btl.battlestate = BS_CHALLENGEEND
		btl.hudtimer.challengeend = TICRATE*5
		btl.challengewon = btl.scoremode	-- false if outside of score mode, otherwise, it's a victory regardless!
		BTL_fullCleanse(btl)
		return
		-- yep, that's a loss
	end

	if mo and mo.valid and mo.setonemore

		-- we have gotten a one more; this means we knocked an enemy down on our turn.
		-- so let's check if *all* our enemies are down to see if we can initiate an All Out Attack:

		if mo.plyr and #mo.allies > 1	-- of course this would only apply for players, and if we have more than 1 ally to attack with

			local dcount = 0
			for k,v in ipairs(mo.enemies) do
				if v.down
					dcount = $+1
				end
			end

			-- check if we have at least 1 ally free of status condition:
			local cond_count = 0
			for k,v in ipairs(mo.allies)
				if not BTL_noAOAStatus(v)
					cond_count = $+1
				end
			end

			if dcount >= #mo.enemies
			and server.gamemode ~= GM_CHALLENGE	-- no all out attacks in challenge mode
			and cond_count > 1	-- At least 2 allies necessary!
			and mo.hp
				VFX_Play(mo, VFX_AOAASK)
				BTL_fullCleanse(btl)
				BTL_initHoldup(btl, mo.allies)
				return	-- don't process anymore. We will get back to the entity's turn if we cancel or to the next turn if we don't
			end
		end

		mo.turnset = nil
		mo.onemore = TICRATE
		mo.setonemore = nil

		VFX_Play(mo, VFX_1MORE)
	end

	-- even if we aren't doing the above, check for endboss being knocked down to initiate the final AOA
	for k,v in ipairs(mo.enemies) do
		if v.down and v.endboss and v.hp == 1
			BTL_fullCleanse(btl)
			BTL_initHoldup(btl, mo.allies)
			return
		end
	end

	if not mo.statustimer then mo.statustimer = 0 end

	if btl.turnorder[2] ~= mo	-- ditto, only do that at the end of an enemy's last turn for multi-turn enemies
	and not btl.skipstatus		-- set after link skills etc
		if not BTL_handleStatusConditions(pn, mo.statustimer)
			mo.statustimer = $+1
			return
		end

		if mo.status_res
			mo.status_res = max(0, $-2)
		end
	end

	mo.skipdowncheck = nil	-- don't forget to remove this
	mo.batontouch = nil	-- can't baton touch anymore
	if btl.turnorder[1] and btl.turnorder[1].valid
		btl.turnorder[1].status_condition_pass = nil	-- it's a full loop!
		btl.turnorder[1].statustimer = nil
	end

	local pdump
	if mo.batonpassto
		pdump = mo.batonpassto
		mo.batonpassto = nil
	end

	-- remove dead entities from turn order and fighters (like, dead but still in-game, players)
	updateUDtable_nohp(btl.turnorder)
	updateUDtable_nohp(btl.fighters)

	if pdump

		-- delete any entry regarding pdump in the turn list, we're moving it!
		for i = 1, #btl.turnorder
			if btl.turnorder[i] == pdump
				table.remove(btl.turnorder, i)
				break
			end
		end

		btl.turnorder[1] = pdump
	else
		if mo and not mo.onemore and not (btl.linkhits and #btl.linkhits)
			-- don't remove turns if we're about to enter link hit state
			mo.batonpassbuff = 0	-- reset baton pass buff
			table.remove(btl.turnorder, 1)
			-- advance through turnorder
		end
	end

	BTL_fullCleanse(btl)	-- *remove* dead enemies, they aren't needed anymore

	-- perform link states:
	if btl.linkhits
	and #btl.linkhits
		--print("Do links")
		btl.skipstatus = true
		btl.battlestate = BS_LINK
		return
	end

	btl.skipstatus = nil

	if btl.battlestate ~= BS_HOLDUP
		btl.battlestate = BS_PRETURN	-- bullshit preturn
	end
	btl.actionstate = ACT_NONE		-- get back on the main menu
end)

rawset(_G, "BTL_holdupHandler", function(pn)

	local btl = server.P_BattleStatus[pn]
	local mo = btl.turnorder[1]
	local plist = btl.plist

	if not mo or not mo.valid return end

	if not mo.control
		dprint("PN "..pn..": ERROR: No player to control All-Out attack prompt. Reverting to p1")
		mo = plist[1].control
	end

	-- cancel all out attack.
	-- if we do that, it ends instantly and we simply get a one more

	if btl.hudtimer.aoarelent	-- relent animation
		btl.hudtimer.aoarelent = $-1
		if not btl.hudtimer.aoarelent
			btl.battlestate = BS_ENDTURN
		end
		return
	end

	if btl.hudtimer.holdupstart > 20 return end	-- the animation has yet to finish...

	if mo.control.mo.P_inputs[BT_USE] == 1
	and not btl.holdupfinish	-- can't do that~
	and not SAVE_localtable.tutorial	-- nope.
		-- go back to end of turn.
		-- we get a one more and will thus skip the down enemies check (which would trigger the aoa prompt again)
		mo.onemore = 25
		mo.setonemore = nil	-- don't check whether we should get a onemore / trigger aoa
		btl.hudtimer.aoarelent = 8
		VFX_Play(mo, VFX_AOARELENT)
		--btl.battlestate = BS_ENDTURN

	elseif mo.control.mo.P_inputs[BT_JUMP] == 1

		-- the targets are undeniably our enemies
		mo.itemname = nil		-- make sure we don't start the AOA with the "FREIDYNE GEM" name lol.....
		mo.no_action_vfx = true
		mo.targets = copyTable(mo.enemies)
		BTL_setAttack(mo, "all_out")
		btl.battlestate = BS_ACTION			-- set the battlestate to action so we use the move
		mo.onemore = nil
		mo.setonemore = nil
		btl.netstats.alloutattacks = $+1
		VFX_Play(mo, VFX_AOADO)
	end
end)

rawset(_G, "BTL_endHandler", function(pn)
	local btl = server.P_BattleStatus[pn]
	local plist = server.playerlist[pn] --btl.plist

	-- handle result music change:
	if btl.hudtimer.endb == 10

		if server.gamemode ~= GM_VOIDRUN
			for i = 1, server.P_netstat.teamlen do
				local p = plist[i]
				if not p or not p.valid continue end
				S_ChangeMusic(btl.savemusic or MUS_PlayRandomBattleMusic("mus_battle_results"), nil, p)
				btl.savemusic = nil
			end
		end

		server.P_BattleStatus[pn].netstats.wins = $+1	-- that's a win in my book.

		-- make players and shuffle cards invisible:
		for _, v in ipairs(server.plentities[pn])

			cureStatus(v)	-- run status cure func
			v.t_cmem = nil	-- remove cursor memory
			v.status_condition = 0
			v.status_turns = 0	-- 4 super / hyper

			if v.control
				COM_BufInsertText(v.control, "chasecam 1")
			end

			v.flags2 = $|MF2_DONTDRAW
			if v.shufflecards and #v.shufflecards	-- we have to remove the mobjs from this list
				for i = 1, #v.shufflecards do
					if v.shufflecards[i] and v.shufflecards[i].valid

						if v.shufflecards[i].target and v.shufflecards[i].target.valid
							v.shufflecards[i].target.flags2 = $|MF2_DONTDRAW
						end

						v.shufflecards[i].flags2 = $|MF2_DONTDRAW
					end
				end
			end
		end
	elseif btl.hudtimer.endb < 10
		-- by the time the timer hits 180 we will be showing the attack
		local gox = btl.arena_coords[1] + 900*cos((leveltime)*(ANG1/4))
		local goy = btl.arena_coords[2] + 900*sin((leveltime)*(ANG1/4))
		-- simply teleport the camera, we don't need it to transition with CAM_goto

		local cam = btl.cam
		if not cam.valid return end	--!?
		P_TeleportMove(cam, gox, goy, btl.arena_coords[3] + 350<<FRACBITS)
		cam.aiming = -ANG1*3
		cam.angle = R_PointToAngle2(gox, goy, btl.arena_coords[1], btl.arena_coords[2])
		-- make the camera spin towards the center of the arena, or something
	end

	-- precalculate the level at which we will be at as well as our final EXP after the battle:

	if not btl.r_precalculates[1]

		--for i = 1, #server.plentities[pn]
		for i = 1, server.P_netstat.teamlen do
			if not server.plentities[pn][i] continue end

			local xp = btl.r_exp -- xp earned during btl
			local mo = server.plentities[pn][i]
			local sxp = mo.exp	-- exp to start from (will be mo.exp at first, then 0 if we level up during precalc)
			btl.r_precalculates[i] = {sxp, mo.level, nil}	-- 1: xp, 2: level, 3: has level up?
			btl.r_newskillsqueue[i] = {}

			-- save our stats, and save our old skills for the level up animation:
			-- reset our stats before saving them though;
			BTL_setupstats(mo)	-- this will use the old savestats table, useful to cancel hyper mode buff
			mo.savestats = {mo.strength, mo.magic, mo.endurance, mo.agility, mo.luck}
			mo.saveskills = copyTable(mo.skills)	-- reminder that if we assign an existing table to a value, both will get modified if one gets it.
			mo.r_levelupenter = TICRATE*2/3	-- used for animation on level up screen

			-- precalculate the level and the exp we'll be at
			while xp and not mo.penalty
			and btl.r_precalculates[i][2] < mo.levelcap
				if sxp + xp >= needEXP[btl.r_precalculates[i][2]]
					xp = $ - (needEXP[btl.r_precalculates[i][2]] - sxp)	-- take away the exp we needed to level up from our total...
					btl.r_precalculates[i][2] = $+1					-- add 1 level
					btl.r_precalculates[i][3] = true				-- we have leveled up.
					sxp = 0	-- set sxp to 0 as if we had actually leveled up

					-- check for skills to learn:
					local stats = mo.persona
					for f = 1, #stats.skills
						local j = stats.skills[f]
						-- j[1] is the skill to learn, j[2] is the level we can learn it at.
						if j and j[1] and j[2] and btl.r_precalculates[i][2] == j[2]
							btl.r_newskillsqueue[i][#btl.r_newskillsqueue[i]+1] = j	-- save j rather than j[1] so we can display the next skill lv on the status screen
							--dprint("PN "..pn..": Bot "..i.." will learn skill "..j[1])
						end
					end

					if btl.r_precalculates[i][2] >= mo.levelcap	-- level 99
						break	-- stop there.
					end

				else
					btl.r_precalculates[i][1] = sxp + xp
					xp = 0		-- next
				end
			end
			--dprint("PN "..pn..": Precalculated player "..i.." with exp "..btl.r_precalculates[i][1].." at level "..btl.r_precalculates[i][2])
		end

		btl.r_levelupqueue = {}
		btl.r_numplayers = 0
		--btl.r_queueprogress = {}

		-- build level up queue:
		for i = 1, 4
			--btl.r_queueprogress[i+1] = 1	-- how far is this player in their level up progress?
			btl.r_levelupqueue[i] = {}	-- amount of entities the player will be shown leveling up...
			btl.r_numplayers = $+1	-- used later to check if everyone's done leveling up
			if not plist[i] or not plist[i].valid continue end
			for j = 1, server.P_netstat.teamlen do
				if not server.plentities[pn][j] continue end
				if server.plentities[pn][j].control == plist[i] and btl.r_precalculates[j][3]	-- if we have control over this player and they have leveled up
					table.insert(btl.r_levelupqueue[i], server.plentities[pn][j])
					dprint("PN "..pn..": Player "..i.." can be shown Bot "..j.." leveling up..")
				end
			end
		end

		btl.r_done = {}	-- reset "exp animation done" status
	end

	if btl.hudtimer.endb return end	-- wait for hud to finish animating (...)

	if btl.r_expdiff == nil
		btl.r_expdiff = (btl.r_exp or 0) - (btl.r_baseexp or 0)
		btl.r_moneydiff = (btl.r_money or 0) - (btl.r_basemoney or 0)
	end

	-- more visual shit
	if (btl.r_baseexp or 0) < btl.r_exp or (btl.r_basemoney or 0) < btl.r_money
		btl.r_baseexp = min(btl.r_exp, $+max(1, btl.r_expdiff/24))
		btl.r_basemoney = min(btl.r_money, $+max(1, btl.r_moneydiff/24))
		for i = 1, server.P_netstat.teamlen do
			if not server.plentities[pn][i] continue end
			local mo = server.plentities[pn][i]
			S_StartSound(nil, sfx_menu1, mo.control)
		end

		return
	end

	btl.r_expdiff = nil
	btl.r_moneyiff = nil	-- kill these vars

	local framelevelup
	-- true if we levelled up this frame. Avoids earrape.

	-- fill exp bars over time or w/e!
	local addf = max(1, btl.r_exp /35)	--will take 1 second at most.
	for i = 1, server.P_netstat.teamlen do
		if not server.plentities[pn][i] continue end
		local mo = server.plentities[pn][i]
		local c = btl.r_precalculates[i]

		if mo.level < c[2]	-- below precalculated level:
			mo.exp = $ + addf
			if mo.control
				S_StartSound(nil, sfx_menu1, mo.control)
			end
			if mo.exp >= needEXP[mo.level]
				mo.level = $+1
				mo.exp = 0
				BTL_levelUpStats(mo, mo.level)
				for i = 1, #btl.plist do
					local p = btl.plist[i]
					if not p or not p.valid continue end

					S_StartSound(nil, sfx_lvup, p)
					VFX_Play(mo, VFX_LEVELUP, nil, p)

					P_FlashPal(p, 0, 2)
				end
				framelevelup = true
			end
		else
			if mo.exp < c[1]
				mo.exp = min(c[1], $ + addf)
				if mo.control
					S_StartSound(nil, sfx_menu1, mo.control)
				end
			else
				btl.r_done[i] = true
			end
		end
	end

	local mo = server.plentities[pn][1]

	-- count players:
	local countplayers = 0
	for i = 1, server.P_netstat.teamlen do
		if not server.plentities[pn][i] continue end
		countplayers = $+1
	end

	if mo.control.mo.P_inputs[BT_JUMP] == 1
	and #btl.r_done >= countplayers	-- once everyone is done, we CAN go to the next screen!
	and btl.hudtimer.levelup == nil
		btl.hudtimer.levelup = TICRATE/2
	end

	if btl.hudtimer.levelup and btl.hudtimer.levelup == 1
		btl.battlestate = BS_LEVELUP	-- special btlstate where we call the normal level up animation function
		btl.hudtimer.levelup = nil
		--btl.hudtimer.levelup_enter = TICRATE*2/3
	end
end)

-- do level up animation
rawset(_G, "BTL_levelupAnimation", function(mo)
	local btl = server.P_BattleStatus[mo.battlen]
	local pn = mo.battlen

	if not mo return end

	local mynum	-- our player num:
	for i = 1, #server.plentities[pn] do
		if server.plentities[mo.battlen][i] == mo
			mynum = i
			break
		end
	end

	if mo.r_levelupenter
		mo.r_levelupenter = $-1
		return
	end

	local save_checkouts = 0
	local stats = {mo.strength, mo.magic, mo.endurance, mo.agility, mo.luck}

	for i = 1, 5
		if mo.savestats[i] >= stats[i]
			save_checkouts = $+1
		end
	end

	if save_checkouts >= 5	-- that means all our stats are good!
		return true			-- since we handle stats last, that means we're good!
	end

	-- first off, we will be handling skills

	if btl.r_newskillsqueue[mynum] and btl.r_newskillsqueue[mynum][1]

		if #mo.skills < 8 or mo.justgotskill	-- less than 8 skills, so we just learn the new skill in the next slot (justgotskill is to avoid the 8th skill triggering the 2nd behavior)

			if mo.r_nskilltimer == nil
				mo.r_nskilltimer = 0
			end
			mo.r_nskilltimer = $+1

			if mo.r_nskilltimer == 20
				mo.skills[#mo.skills+1] = btl.r_newskillsqueue[mynum][1][1]
				mo.newskillnum = #mo.skills	-- we use this to know which skill to flash in HUD rendering
				mo.justgotskill = true
				S_StartSound(nil, sfx_nskill, mo.control)
				--dprint("PN "..pn..": Skill learnt: "..btl.r_newskillsqueue[mynum][1][1])
			end

			if mo.r_nskilltimer >= TICRATE*3/2
				mo.r_nskilltimer = nil	-- set timer to nil so we will restart if we need to.
				table.remove(btl.r_newskillsqueue[mynum], 1)	-- remove first skill.
				mo.newskillnum = nil
				mo.justgotskill = nil
			end
		else				-- more than 8 skills, we need to let the player forget one.

			if mo.newskillnum	-- we have selected a skill
				if mo.r_nskilltimer == nil
					mo.r_nskilltimer = 0
				end
				mo.r_nskilltimer = $+1

				if mo.r_nskilltimer == 20
					mo.skills[mo.newskillnum] = btl.r_newskillsqueue[mynum][1][1]
					S_StartSound(nil, sfx_nskill, mo.control)
					--dprint("PN "..pn..": Skill learnt: "..btl.r_newskillsqueue[mynum][1][1])
				end

				if mo.r_nskilltimer >= TICRATE*3/2
					mo.r_nskilltimer = nil	-- set timer to nil so we will restart if we need to.
					table.remove(btl.r_newskillsqueue[mynum], 1)	-- remove first skill.
					mo.newskillnum = nil
				end

				return	-- no need to process button inputs anymore or w/e,
			end

			if not mo.r_forgetselect
				mo.r_forgetselect = 1	-- start at skill 1 that we will forget
				-- double check to see if we can't select the skill to forget by default:
				if btl.r_newskillsqueue[mynum][1][3]
					for i = 1, #mo.skills
						if mo.skills[i] == btl.r_newskillsqueue[mynum][1][3]
							mo.r_forgetselect = i -- tell the player to forget *this* skill instead
							break
						end
					end
				end

			end

			-- handle the inputs here:
			local inpt = mo.control.mo.P_inputs

			-- check if we want to confirm our choice...
			if mo.r_askconfirm

				if inpt[BT_USE] == 1
					S_StartSound(nil, sfx_cancel, mo.control)
					mo.r_askconfirm = nil

				elseif inpt[BT_JUMP] == 1

					if mo.r_askconfirm == 1	-- new skill
						mo.newskillnum = mo.r_forgetselect
						mo.r_forgetselect = nil
					else	-- don't learn new skill
						mo.r_nskilltimer = nil	-- set timer to nil so we will restart if we need to.
						table.remove(btl.r_newskillsqueue[mynum], 1)	-- remove first skill.
						mo.newskillnum = nil
						mo.r_forgetselect = nil	-- remove both of these to prevent skill flashing
					end
					mo.r_askconfirm = nil

					S_StartSound(nil, sfx_hover, mo.control)
				end

				return
			end


			if inpt["down"] ==1
				if not (mo.r_forgetselect%4)	-- at bottom.
					mo.r_forgetselect = $-3
				else
					mo.r_forgetselect = $+1
				end
				S_StartSound(nil, sfx_hover, mo.control)
			elseif inpt["up"] ==1
				mo.r_forgetselect = $-1
				if not (mo.r_forgetselect%4)	-- at top
					mo.r_forgetselect = $+4
				end
				S_StartSound(nil, sfx_hover, mo.control)
			elseif inpt["right"] ==1 or inpt["left"] ==1
				if mo.r_forgetselect > 4
					mo.r_forgetselect = $-4
				else
					mo.r_forgetselect = $+4
				end
				S_StartSound(nil, sfx_hover, mo.control)
			elseif inpt[BT_JUMP] ==1	-- confirm forget
				S_StartSound(nil, sfx_hover, mo.control)
				mo.r_askconfirm = 1



			elseif inpt[BT_USE] ==1		-- I don't want new skills!
				S_StartSound(nil, sfx_cancel, mo.control)
				mo.r_askconfirm = 2


			end
		end
		return	-- don't proceed for as long as we have got skills to learn
	end

	-- when we're done, handle stats, because when stats are done, we can press the button and continue
	if not mo.r_stattimer
		mo.r_stattimer = 0
	end
	mo.r_stattimer = $+1

	if mo.r_stattimer > 15

		if mo.r_stattimer%2
			local playsound	-- don't earrape 5 times / tic

			for i = 1, 5
				if mo.savestats[i] < stats[i]
					mo.savestats[i] = $+1
					playsound = true
				elseif mo.savestats[i] > stats[i]	-- ?????
					mo.savestats[i] = $-1
					playsound = true
				end
			end

			if playsound and consoleplayer == mo.control
				S_StartSound(nil, sfx_menu1)
			end
		end
	end
end)

-- BTL_LvUpParanoia: Handle players leaving in case that actually does happen.
rawset(_G, "BTL_LvUpParanoia", function(pn)
	local btl = server.P_BattleStatus[pn]
	local plist = server.playerlist[pn]	--btl.plist
	for i = 1, server.P_netstat.teamlen do
		if (not plist[i] or not plist[i].valid)	-- we have a problem.
		and btl.r_levelupqueue
		and btl.r_levelupqueue[i]	-- don't paranoia if there's nothing to paranoia about.
		and #btl.r_levelupqueue[i]
			btl.r_levelupqueue[1] = addTables(btl.r_levelupqueue[1], btl.r_levelupqueue[i])
			btl.r_levelupqueue[i] = nil
			--print("DBG_PARANOIA POSITIVE ("..i..")")
		end
	end
end)

-- BTL_levelUpHandler: handle leveling up
rawset(_G, "BTL_levelUpHandler", function(pn)
	-- we will essentially be calling the level up handler on every player that has to level up
	local btl = server.P_BattleStatus[pn]
	local donelevelingup = 0	-- used to know when level ups are over

	if not #btl.r_levelupqueue	-- if there's no level up queue then that means we're done here!
		dprint("PN "..pn..": BTL_levelUpHandler ERROR: No level up queue?")
		btl.battlestate = BS_FINISH
		return
	end

	-- keep spinning camera, also in BS_FINISH, this is the only dupe of this code so w/e
	local gox = btl.arena_coords[1] + 900*cos((leveltime)*(ANG1/4))
	local goy = btl.arena_coords[2] + 900*sin((leveltime)*(ANG1/4))
	-- simply teleport the camera, we don't need it to transition with CAM_goto

	local cam = btl.cam
	P_TeleportMove(cam, gox, goy, btl.arena_coords[3] + 350<<FRACBITS)
	cam.aiming = -ANG1*3
	cam.angle = R_PointToAngle2(gox, goy, btl.arena_coords[1], btl.arena_coords[2])
	-- make the camera spin towards the center of the arena, or something

	BTL_LvUpParanoia(pn)

	local levelupplayers, playersdone = 0, 0
	for i = 1, #btl.r_precalculates do
		if btl.r_precalculates[i][3]
			levelupplayers = $+1
		end
	end

	for i = 1, #btl.r_levelupqueue do
		local t = btl.r_levelupqueue[i]
		if not t or not #t
			donelevelingup = $+1
			continue
		end

		if BTL_levelupAnimation(t[1])	-- returns true when animation done:
			local inpt = t[1].control.mo.P_inputs
			if inpt[BT_JUMP]==1	-- to next player
			and not t[1].r_transition
				t[1].r_transition = TICRATE/2
			end
		end

		if t[1].r_transition
			t[1].r_transition = $-1
			if not t[1].r_transition	-- transition for next done playing
				table.remove(t, 1)
			end
		end
	end

	-- check if EVERYONE is done leveling up:
	if donelevelingup >= #btl.r_levelupqueue
		--dprint("PN "..pn..": Level up sequence finished succesfully")
		btl.battlestate = BS_FINISH
		-- get our items if we got some
		if btl.r_item
			for i = 1, #btl.r_item
				BTL_addItem(btl, btl.r_item[i][1], btl.r_item[i][2])
			end
		end

		if btl.r_weapons
			for i = 1, #btl.r_weapons
				local wpn = btl.r_weapons[i]
				addWeapon(server.plentities[pn][1], wpn)
			end
		end

		if btl.r_rings
			for i = 1, #btl.r_rings
				local ring = btl.r_rings[i]
				addRing(server.plentities[pn][1], ring)
			end
		end

	end
end)

rawset(_G, "BTL_levelUpStats", function(mo, level)

	-- we have leveled up!
	-- from leveling up, we get 3 additional points to our stat total

	-- stats are prioritized depending on the base stats (higher base stats are more prone to getting points)
	-- however, if some stats are laggig behind they will get points as well

	local persona = mo.persona

	-- start with our HP/SP

	local addhp = charStats[mo.stats].basehp /10
	local addsp = charStats[mo.stats].basesp /10

	local hpstr = tostring(charStats[mo.stats].basehp)
	local spstr = tostring(charStats[mo.stats].basesp)

	local hpdec = tonumber(hpstr:sub(hpstr:len(), hpstr:len()))
	local spdec = tonumber(spstr:sub(spstr:len(), spstr:len()))

	mo.dechp = $ + hpdec
	mo.decsp = $ + spdec

	while mo.dechp >= 10
		addhp = $+1
		mo.dechp = $-10
	end

	while mo.decsp >= 10
		addsp = $+1
		mo.decsp = $-10
	end

	-- fixed stat growth in void run
	if server.gamemode == GM_VOIDRUN
		addhp = 5
		addsp = 0
	end

	mo.maxhp = $ + addhp
	mo.maxsp = $ + addsp
	mo.realhp = $ + addhp
	mo.realsp =  $ + addsp

	if mo.hp
		mo.hp = $ + addhp
		mo.sp = $ + addsp
	end

	-- Calc new player stats (take weapon into consideration)
	PLYR_getStats(mo, mo.level, true)
end)

-- battle has ended: reset every battle related variable and acquire items / money and whatnot.
rawset(_G, "BTL_finish", function(pn)

	local btl = server.P_BattleStatus[pn]
	-- this is where we will handle item / money shit.
	-- but we aren't there just yet.
	-- leave a TODO
	btl.r_wipe = $-1

	local plist = btl.plist

	-- get rid of awayviewtics
	for i = 1, #plist do
		local p = plist[i]
		if not p or not p.valid continue end

		p.awayviewtics = 0
		if not p.mo continue end

		local mo = p.mo
		PLAY_move(p)
		p.powers[pw_flashing] = TICRATE*3 -1
		mo.z = mo.floorz
		mo.momx, mo.momy, mo.momz = 0, 0, 0
		mo.state = S_PLAY_STND
		mo.p_battlebuf = nil

		if mo.hit_reaper
		and mo.hit_reaper.valid
		and btl.r_exp	-- If we got any EXP, that means we beat the reaper

			P_RemoveMobj(mo.hit_reaper)	-- kill the reaper??
		end
		mo.hit_reaper = nil

		if gamemap == srb2p.tartarus_play
			--S_ChangeMusic("BLOCK"..DNG_returnBlock(server.P_DungeonStatus.floor), true, p)
			P_RestoreMusic(p)	-- restore the block music (or whatever the player chose idk)
			if server.reaper and server.reaper.valid
				S_ChangeMusic("REAPER", true, p)
			end
		elseif server.gamemode ~= GM_VOIDRUN
			P_RestoreMusic(p)
		end
	end

	-- wipe shuffle time properties if necessary
	for _, v in ipairs(server.plentities[pn])
		v.flags2 = $|MF2_DONTDRAW
		v.shuffletypes = nil	-- only numbers
		if v.shufflecards and #v.shufflecards	-- we have to remove the mobjs from this list
			for i = 1, #v.shufflecards do
				if v.shufflecards[i] and v.shufflecards[i].valid

					if v.shufflecards[i].target and v.shufflecards[i].target.valid
						P_RemoveMobj(v.shufflecards[i].target)
					end

					if v.shufflecards[i].death and v.shufflecards[i].death.valid
						P_RemoveMobj(v.shufflecards[i].death)
					end

					P_RemoveMobj(v.shufflecards[i])
					continue
				end
			end
		end
		v.shufflecards = nil	-- kill table
		v.shufflepointers = nil	-- only numbers, kill

		-- everything from there on out is just numbers
		v.shuffle_speed = nil
		v.shuffle_timesswapped = nil
		v.shuffle_choice = nil
		v.shuffleselect = nil
		v.shuffle_swapangle1 = nil
		v.shuffle_swapangle2 = nil
		v.shuffle_addedangle = nil
		v.shuffle_swap = nil

		if v.shuffle_skillcard	-- we have gotten a skill card.
		-- check if we should add it to our skill card list
			if btl.skillcards	-- make sure the tbl exists
				-- iterate through the table to make sure we don't already have it, we don't need duplicates
				local dupe
				for i = 1, #btl.skillcards
					if btl.skillcards[i] == v.shuffle_skillcard
						dupe = true
						--dprint("PN "..pn..": Card is a duplicate, don't add it ...")
						break
					end
				end

				if not dupe	-- not a duplicate
					btl.skillcards[#btl.skillcards+1] = v.shuffle_skillcard
				end
				v.shuffle_skillcard = nil	-- wipe out
			end
		end

		v.saveskills = nil
		table.sort(v.skills, attackSortFunc)	-- re-sort ONCE AGAIN after skills have potentially been learnt
	end


	-- now that we have fetched everything that we NEEDED to fetch, reset the parts of the battle that need reseting
	if not btl.r_wipe
		if btl.cam and btl.cam.valid
			P_RemoveMobj(btl.cam)
		end

		-- add the money:
		--btl.macca = $ + btl.r_money
		BTL_getMacca(btl, btl.r_money)

		BTL_softReset(pn)
		btl.cam = spawnbattlecam()	-- new clean camera for next battle
		PLYR_reset(pn)	-- reset battle variable for permanent entities

		-- event buffer: This event is meant to play after the battle is over.
		-- ...So do play it!
		if btl.event_buf
		and not netgame	-- this would be disasterous.
			D_startEvent(pn, btl.event_buf)
			btl.event_buf = nil	-- wipe this from existence
		end

		--dprint("PN "..pn..": Battle has ended succesfully")
	end

	-- after vc_repel battles, instantly switch floors
	if server.gamemode == GM_VOIDRUN
	and server.P_DungeonStatus.VR_type == VC_REPEL
	and btl.r_wipe == 19
		server.P_DungeonStatus.floor = $+1
		server.P_DungeonStatus.stairsfound = nil
		DNG_setFloor(server.P_DungeonStatus.floor)
		server.reaper = nil
	end
end)

-- shuffle time
-- reminder:
-- 1 = sword,
-- 2 = hp cup
-- 3 = sp cup
-- 4 = weed
-- 5 = subp
-- 6 = penalty
-- 7 = blank

freeslot("SPR_SHFL")

-- return random subpersona
rawset(_G, "BTL_getSkillCard", function(level)
	-- select possible cards:
	local cards
	--if mapheaderinfo[gamemap].tartarus	-- tartarus uses special kind of waves, it needs its own table since it's pretty long

		/*local i = server.P_DungeonStatus.floor

		while i
			if DNG_skillcards[i]
				cards = DNG_skillcards[i]
				break
			end
			i = $-1
		end*/
	cards = DNG_skillcards_level[level]

	--else	-- for other dungeons
	--	cards = DNG_dungeoncards[gamemap][server.P_DungeonStatus.section]
	--end

	if not cards or not #cards return "agi" end

	-- now, pick a random card from the list:
	local choice = cards[P_RandomRange(1, #cards)]
	-- verify if our choice is a valid skill
	if attackDefs[choice]
		return choice
	else
		print("\x82".."WARNING: ".."\x80".."Invalid skill card detected, internal name is "..choice)
		return "agi" -- Fallback onto agi, like in the case where the table we got is nil or has no skills
	end
end)

rawset(_G, "BTL_getPersona", function(pn)

	-- FAILSAFE
	if #server.P_BattleStatus[pn].subpersonas > server.P_BattleStatus[pn].subpersonastock	-- too many!!!
		return nil
	end

	local i = server.P_DungeonStatus.floor

	local personas
	if mapheaderinfo[gamemap].tartarus	-- tartarus has its own subp lists / floor
		while i
			if DNG_subpersonas[i]
				personas = DNG_subpersonas[i]
				break
			end
			i = $-1
		end

	elseif server.cdungeon
		personas = server.cdungeon.shufflepersonas

	else
		personas = DNG_dungeonpersonas[gamemap][server.P_DungeonStatus.section]
	end

	if not personas or not #personas return nil end

	local choice = personas[P_RandomRange(1, #personas)]

	-- is the subpersona valid...?
	local subp = subpersonaList[choice]
	if not subp
		print("\x82".."WARNING: ".."\x80".."Invalid subpersona selected, internal name is "..choice)
		return nil -- not a valid subpersona entry
	elseif not subp.name
	or subp.sprite == nil -- Values at 0 trip the not condition, we have to specify that we want to catch *nil* values
	or subp.frame == nil
	or subp.lv == nil
	or subp.weapontype == nil
	or subp.st == nil
	or subp.ma == nil
	or subp.en == nil
	or subp.ag == nil
	or subp.lu == nil
		print("\x82".."WARNING: ".."\x80".."Subpersona with uninitialized elements selected, internal name is "..choice)
		-- Ugly, so lets keep this verbose data to a dprint
		dprint("Listing stats...")
		dprint("Name: "..(subp.name or "nil"))
		dprint("Sprite: "..(subp.sprite == nil and "nil" or subp.sprite))
		dprint("Frame: "..(subp.frame == nil and "nil" or subp.frame))
		dprint("Level: "..(subp.lv == nil and "nil" or subp.lv))
		dprint("Weapon Type: "..(subp.weapontype == nil and "nil" or subp.weapontype))
		dprint("Strength: "..(subp.st == nil and "nil" or subp.st))
		dprint("Magic: "..(subp.ma == nil and "nil" or subp.ma))
		dprint("Endurance: "..(subp.en == nil and "nil" or subp.en))
		dprint("Agility: "..(subp.ag == nil and "nil" or subp.ag))
		dprint("Luck: "..(subp.lu == nil and "nil" or subp.lu))
		return nil
	end
	-- do we already have it...?
	for i = 1, #server.P_BattleStatus[pn].subpersonas
		if server.P_BattleStatus[pn].subpersonas[i].ref == subpersonaList[choice]	-- yep we do.
			return nil
		end
	end

	return choice
end)

-- lookup table for cards
local type_sprite = {

	SPR_SRDC,
	SPR_CUPC,
	SPR_COIC,
	SPR_WNDC,
}

rawset(_G, "BTL_shuffleHandler", function(pn)

	local btl = server.P_BattleStatus[pn]
	local cam = btl.cam

	if btl.hudtimer.shufflestart == TICRATE
		for i = 1, 4
			if server.playerlist[pn][i] and server.playerlist[pn][i].valid
				S_StartSound(nil, sfx_1more, server.playerlist[pn][i])
			end
		end
	end

	-- card handler to keep the subp image attached to it:
	for i = 1, server.P_netstat.teamlen do
		if not server.plentities[pn][i] continue end
		local mo = server.plentities[pn][i]
		if mo.shufflecards and #mo.shufflecards and mo.shufflecards[1].valid
			for j = 1, #mo.shufflecards do
				local c = mo.shufflecards[j]
				if c.target
					local an = c.angle - ANG1*90
					local xpos2 = c.x - cos(an)
					local ypos2 = c.y - sin(an)
					P_TeleportMove(c.target, xpos2, ypos2, c.z)
					c.target.angle = c.angle
				end

				if c.death
					--print(c.death.flags2 & MF2_DONTDRAW)
					local an = c.angle - ANG1*90
					local xpos2 = c.x - 2*cos(an)
					local ypos2 = c.y - 2*sin(an)
					P_TeleportMove(c.death, xpos2, ypos2, c.z)
					c.death.angle = c.angle
					c.death.frame = ($ & ~FF_TRANSMASK)
					c.death.frame = $ | (TR_TRANS40 + ((leveltime%8)/2)*TR_TRANS10) | FF_PAPERSPRITE
				end
			end
		end
	end

	if not btl.shufflestatus	-- shuffle time hasn't started yet

		-- also get the camera in a good spot
		P_TeleportMove(cam, btl.arena_coords[1], btl.arena_coords[2], btl.arena_coords[3] + 256<<FRACBITS)
		cam.angle = ANG1*90
		cam.aiming = 0
		CAM_stop(cam)
		btl.shuffletimer = 0

		local chosensubp = {}	-- sub personas generated, make sure we don't get the same ones twice per player

		-- set the cards for everyone:
		for i = 1, server.P_netstat.teamlen do
			if not server.plentities[pn][i] continue end
			local mo = server.plentities[pn][i]
			mo.shuffletypes = {}	-- types
			mo.shufflelevels = {}	-- levels
			mo.shufflecards = {}	-- card mobjs
			mo.shufflepointers = {}	-- what card mobj is which at the end of the shuffle?
			mo.shufflepersonas = {}	-- keep track of what subp we can get
			mo.shuffleconfirm = nil	-- confirmed shuffle time
			mo.shuffle_swapspeed = nil

			local safecard = P_RandomRange(1, 4)	-- this card physically can't be a penalty card
			local maxcardlevel = 1

			if server.cdungeon
				maxcardlevel = server.cdungeon.shufflelevel
			else
				-- normal
				maxcardlevel = DNG_maxCardLevel[server.difficulty] or 1
			end

			for j = 1, 4 do
				mo.shuffletypes[j] = P_RandomRange(1, safecard == j and 5 or 7)

				local reaperchance = P_RandomRange(server.difficulty, 32) == 32 and (mo.shuffletypes[j] ~= 5 and j ~= safecard)

				if reaperchance
					mo.shuffletypes[j] = $|1024
				end

				mo.shufflelevels[j] = P_RandomRange(1, maxcardlevel)	-- !?

				-- subpersona special case:
				if mo.shuffletypes[j] & 1023 == 5
					mo.shufflepersonas[j] = BTL_getPersona(pn)

					local dupe = #btl.subpersonas + (mo.shufflepersonas[j] and #mo.shufflepersonas[j] or 0) > btl.subpersonastock

					for f = 1, #chosensubp
						if chosensubp[f] == mo.shufflepersonas[j]
							dupe = true
							break
						end
					end

					chosensubp[#chosensubp+1] = mo.shufflepersonas[j]	-- add to list to check for duplicates

					if not mo.shufflepersonas[j] or dupe
						-- revert back to a skill card if there's no persona (duplicate) or if we aren't the right player
						mo.shuffletypes[j] = 1
						mo.shufflepersonas[j] = nil
					end
				end
			end

			-- spawn the physical cards
			for j = 1, #mo.shuffletypes
				local xpos = cam.x - (288<<FRACBITS) + (j-1)*192<<FRACBITS
				local c = P_SpawnMobj(xpos, cam.y + 600<<FRACBITS, cam.z, MT_DUMMY)
				c.scale = FRACUNIT
				c.flags = MF_NOGRAVITY
				c.tics = -1
				c.renderflags = $|RF_NOCOLORMAPS

				local t = mo.shuffletypes[j] & 1023	-- without death flag

				if type_sprite[t]	-- normal LEVELED card
					c.sprite = type_sprite[t]
					c.frame = (mo.shufflelevels[j] -1)|FF_PAPERSPRITE|FF_FULLBRIGHT
				else				-- special card with no level
					c.sprite = SPR_SHFL
					c.frame = (mo.shuffletypes[j] & 1023)|FF_PAPERSPRITE|FF_FULLBRIGHT
				end

				c.angle = cam.angle + ANG1*90

				local an = R_PointToAngle(c.x, c.y)
				local xpos2 = c.x - cos(an)
				local ypos2 = c.y - sin(an)

				-- spawn the subpersona overlay if necessary:
				if mo.shufflepersonas[j]

					local subp = P_SpawnMobj(xpos2, ypos2, cam.z, MT_DUMMY)
					subp.tics = -1
					subp.scale = FRACUNIT
					subp.sprite = subpersonaList[mo.shufflepersonas[j]].sprite
					subp.frame = subpersonaList[mo.shufflepersonas[j]].frame|FF_PAPERSPRITE|FF_FULLBRIGHT
					subp.target = c
					subp.renderflags = $|RF_NOCOLORMAPS
					c.target = subp
					c.subpersona = mo.shufflepersonas[j]
					subp.angle = c.angle
				end

				if mo.shuffletypes[j] & 1024
					local death = P_SpawnMobj(xpos2, ypos2, cam.z, MT_DUMMY)
					death.scale = FRACUNIT
					death.target = c
					death.tics = -1
					death.sprite = SPR_SHFL
					death.frame = I|FF_FULLBRIGHT|FF_TRANS50
					death.renderflags = $|RF_NOCOLORMAPS
					c.death = death
				end

				-- should we display these on our screen...?
				if not (mo.control == displayplayer and mo.control.maincontrol == mo)
					c.flags2 = $|MF2_DONTDRAW
					if c.target
						c.target.flags2 = $|MF2_DONTDRAW
					end

					if c.death
						c.death.flags2 = $|MF2_DONTDRAW
					end

				end
				mo.shufflecards[j] = c	--card mobj
				mo.shufflepointers[j] = c
			end
			mo.shuffle_timesswapped = 0	-- # of times we swapped the cards
			mo.shuffle_choice = 1	-- what card we're gonna pick?
		end

		-- set the status
		btl.shufflestatus = 1

	elseif btl.shufflestatus == 3	-- we made our choice, show us the choice
		btl.shuffletimer = $+1

		if btl.shuffletimer >= TICRATE*3
			-- we're done here, back to endturn
			btl.battlestate = BS_ENDTURN
			-- don't erase shuffletime properties from players as it's STILL useful.
			-- we'll do it right as we end the battle.

			return
		end

		for i = 1, server.P_netstat.teamlen do
			if not server.plentities[pn][i] continue end
			local mo = server.plentities[pn][i]

			local c = mo.shufflecards[mo.shuffle_choice]

			local tgtx = cam.x
			local tgty = cam.y + 256<<FRACBITS

			c.momx = (tgtx - c.x)/2
			c.momy = (tgty - c.y)/2

			-- turn the card around to show us what it was
			if btl.shuffletimer < TICRATE/2
				c.angle = R_PointToAngle2(cam.x, cam.y, c.x, c.y) - ANG1*90
			end

			if btl.shuffletimer == TICRATE/2
				S_StartSound(nil, sfx_hamaca, mo.control)
			end

			if btl.shuffletimer >= TICRATE/2
			and btl.shuffletimer < TICRATE/2 + 9
				c.angle = $ - ANG1*20
				if c.target and (mo.control == displayplayer and mo.control.maincontrol == mo)
					c.target.flags2 = $ & ~MF2_DONTDRAW
				end

				if c.death and (mo.control == displayplayer and mo.control.maincontrol == mo)
					c.death.flags2 = $ & ~MF2_DONTDRAW
				end

			elseif btl.shuffletimer == TICRATE/2 + 9
				c.angle = cam.angle + ANG1*90

				-- don't be too crude to bots
				if mo.control and mo.control.maincontrol ~= mo
					mo.shuffletypes[mo.shuffle_choice] = min($, 6)	-- at worse, get a blank card if penalty or death
				end
				local ctype = mo.shuffletypes[mo.shuffle_choice]
				local lvl = mo.shufflelevels[mo.shuffle_choice]
				--print("Card lvl: "..lvl)
				local death = ctype & 1024
				ctype = $ & 1023	-- remove possible death flag

				local deatheffect = death and 2 or 1


				if death
					if server.P_DungeonStatus.reapertimer

						local reapertimer = TICRATE*6*60
						local numteams = 0
						for i = 1, 4 do
							if server.playerlist[i] and #server.playerlist[i]
								numteams = $+1
							end
						end

						server.P_DungeonStatus.reapertimer = $ - reapertimer/numteams
					end
				end

				if ctype == 1		-- sword: grant skill card
					-- skill cards are per dungeon, they work like enemy waves, so go refer to that instead.
					mo.shuffle_skillcard = BTL_getSkillCard(lvl)
				elseif ctype == 2	-- party recovers HP & SP

					btl.r_healhps[#btl.r_healhps+1] = BTL_shuffleCupHeal[lvl] *deatheffect

					/*for j = 1, server.P_netstat.teamlen do
						if not server.plentities[pn][j] continue end
						local mo2 = server.plentities[pn][j]

						local heals = BTL_shuffleCupHeal[lvl]

						mo2.hp = min(mo2.maxhp, $ + (mo2.maxhp*heals/100)*deatheffect)
						mo2.sp = min(mo2.maxsp, $ + (mo2.maxsp*(heals/3)/100)*deatheffect)
					end*/
					if mo.control and mo.control.maincontrol == mo
						S_StartSound(nil, sfx_heal, mo.control)
					end

				elseif ctype == 3	-- money increased
					--local mult = BTL_shuffleMultiplier_money[lvl] - 100
					btl.r_moneymultipliers[#btl.r_moneymultipliers+1] = (BTL_shuffleMultiplier_money[lvl]-100) *deatheffect
					--btl.r_money = $ + (btl.r_basemoney) + (btl.r_basemoney*mult/100) *deatheffect

					if mo.control and mo.control.maincontrol == mo
						S_StartSound(nil, sfx_chchng, mo.control)
					end

				elseif ctype == 4	-- EXP increases
					--local mult = BTL_shuffleMultiplier_EXP[lvl] - 100
					btl.r_expmultipliers[#btl.r_expmultipliers+1] = (BTL_shuffleMultiplier_EXP[lvl]-100) *deatheffect
					--btl.r_exp = $ + (btl.r_baseexp) + (btl.r_baseexp*mult/100) *deatheffect

					if mo.control and mo.control.maincontrol == mo
						S_StartSound(nil, sfx_nskill, mo.control)
					end

				elseif ctype == 5	-- gotta award a persona!
					local psna = c.subpersona
					mo.shuffle_persona = psna

					psna = P_generateSubPersona(psna)
					-- check for dupes...
					local dupe = false
					for i = 1, #btl.subpersonas do
						if btl.subpersonas[i] and btl.subpersonas[i].int == psna.int
							dupe = true
							break
						end
					end

					if not dupe
						btl.subpersonas[#btl.subpersonas+1] = psna
						btl.netstats.subpersonasfound = $+1
					end

					psna = nil	-- kill that regardless, GC will do the rest


				elseif ctype == 6	-- empty card
					-- nothing, literally nothing!

				elseif ctype == 7	-- penalty~
					mo.penalty = true

					if mo.control and mo.control.maincontrol == mo
						S_StartSound(nil, sfx_absorb, mo.control)
					end

				end

				-- get final multipliers on the last loop.
				-- cards stack with diminutive returns
				if i == server.P_netstat.teamlen
					-- exp multipliers
					if #btl.r_expmultipliers
						table.sort(btl.r_expmultipliers, function(a, b) return a > b end)
						-- build final multiplier
						for i = 1, #btl.r_expmultipliers
							btl.r_expmultiplier = $ + max(1, btl.r_expmultipliers[i] / i)
						end
						--print("Final exp multiplier: "..btl.r_expmultiplier)
						btl.r_exp = $ + btl.r_baseexp*btl.r_expmultiplier / 100
					end

					-- macca multipliers
					if #btl.r_moneymultipliers
						table.sort(btl.r_moneymultipliers, function(a, b) return a > b end)
						-- build final multiplier
						for i = 1, #btl.r_moneymultipliers
							btl.r_moneymultiplier = $ + max(1, btl.r_moneymultipliers[i] / i)
						end

						--print("Final money multiplier: "..btl.r_moneymultiplier)
						btl.r_money = $ + btl.r_basemoney*btl.r_moneymultiplier / 100
					end

					-- cup heals
					if #btl.r_healhps
						table.sort(btl.r_healhps, function(a, b) return a > b end)
						-- build final heal %
						for i = 1, #btl.r_healhps
							btl.r_healhp = $ + max(1, btl.r_healhps[i] / i)
						end

						-- now heal everyone
						for j = 1, server.P_netstat.teamlen do
							if not server.plentities[pn][j] continue end
							local mo2 = server.plentities[pn][j]

							local heals = BTL_shuffleCupHeal[lvl]

							mo2.hp = min(mo2.maxhp, $ + ((mo2.maxhp*btl.r_healhp/100) or 1))
							mo2.sp = min(mo2.maxsp, $ + ((mo2.maxsp*(btl.r_healhp/2)/100) or 1))
						end

					end
				end
			end
		end


	elseif btl.shufflestatus == 2	-- handle the SELECTING here

		btl.shuffletimer = $+1
		if btl.shuffletimer > TICRATE*5
			-- time's over
			btl.shufflestatus = 3
			btl.shuffletimer = 0
			return
		end

		local selected = 0

		for i = 1, server.P_netstat.teamlen do
			if not server.plentities[pn][i] continue end
			local mo = server.plentities[pn][i]

			if mo.control.maincontrol ~= mo
				selected = $+1
				continue
			end	-- nope

			-- inputs
			local inputs = mo.control.mo.P_inputs	-- very cool

			if not mo.shuffleselect
				if inputs["right"] == 1
					mo.shuffle_choice = $+1
					if mo.shuffle_choice > 4
						mo.shuffle_choice = 1
					end
					S_StartSound(nil, sfx_hover, mo.control)
				elseif inputs["left"] == 1
					mo.shuffle_choice = $-1
					if mo.shuffle_choice < 1
						mo.shuffle_choice = 4
					end
					S_StartSound(nil, sfx_hover, mo.control)
				elseif inputs[BT_JUMP] == 1
					S_StartSound(nil, sfx_confir, mo.control)
					mo.shuffleselect = true
				end
			else
				selected = $+1
			end

			-- now put the cursor on the card we chose
			local c = mo.shufflecards[mo.shuffle_choice]
			local cursor = P_SpawnMobj(c.x, c.y - 4<<FRACBITS, c.z, MT_DUMMY)
			cursor.scale = FRACUNIT
			-- spawn the cursor a bit in front of the card so GL doesn't cry.
			-- poor GL, give it a headpat

			cursor.tics = 1
			cursor.sprite = SPR_SHFL

			-- translucency:
			local tr = TR_TRANS40 + ((leveltime%8)/2)*TR_TRANS10
			cursor.frame = A|tr|FF_PAPERSPRITE
			cursor.angle = c.angle

			if not (mo.control == displayplayer and mo.control.maincontrol == mo)
				cursor.flags2 = $|MF2_DONTDRAW
			end
		end

		if selected >= server.P_netstat.teamlen
			btl.shuffletimer = TICRATE*5
			-- skip!
		end

	elseif btl.shufflestatus == 1	-- handle the SHUFFLING HERE
	and not btl.hudtimer.shufflestart	-- wait til animation is over (...)
		btl.shuffletimer = $+1

		if btl.shuffletimer >= TICRATE*7 + 10	-- that was plenty of time, begin selection
			btl.shufflestatus = 2

			-- right before continuing, reorder our cards by ascending x position
			-- yes this is messy, but i don't give two dicks
			for i = 1, server.P_netstat.teamlen do
				if not server.plentities[pn][i] continue end
				local mo = server.plentities[pn][i]
				table.sort(mo.shufflecards, function(a, b)
						return (a.x < b.x)
					end)

				-- sometimes stuff "visually" gets messed up.
				-- however we can count on the code for a safe fix
				for j = 1, #mo.shufflecards
					local c = mo.shufflecards
					c.frame = (mo.shuffletypes[j] & 1023)|FF_PAPERSPRITE
				end

			end
			btl.shuffletimer = 0	-- reset for easier timer implemetation later (...)
			return
		end

		if btl.shuffletimer == TICRATE
			btl.savemusic = MUS_PlayRandomBattleMusic("mus_battle_results")
		end

		for i = 1, server.P_netstat.teamlen do
			if not server.plentities[pn][i] continue end
			local mo = server.plentities[pn][i]

			if btl.shuffletimer == TICRATE
			and server.gamemode ~= GM_VOIDRUN
				S_ChangeMusic(btl.savemusic, nil, mo.control)
			end

			-- when do we swap cards?
			if btl.shuffletimer >= TICRATE*5/2	-- 2.5 sec
			and mo.shuffle_timesswapped < 8
			and btl.shuffletimer <= TICRATE*6 + 20
				if not mo.shuffle_swaptime
					mo.shuffle_swaptime = 0
				end
				-- not swapping, wait a bit
				if not mo.shuffle_swap
					mo.shuffle_swaptime = $+1

					if mo.shuffle_swaptime > 3	-- we've waited enough

						-- play a sound indcating that we're swapping the cards:
						S_StartSound(nil, sfx_hamaca, mo.control)

						-- swapping speed:
						if not mo.shuffle_swapspeed
							mo.shuffle_swapspeed = 0
						end
						-- select 2 random cards to swap with one another:
						mo.shuffle_swap = {P_RandomRange(1, 4), P_RandomRange(1, 4)}
						mo.shuffle_swapspeed = min(20, $+6)	-- angle in degrees to increment by each frame
						mo.shuffle_timesswapped = $+1
						mo.shuffle_swapangle1 = 0	-- angle we're currently at (in degrees) for card1
						mo.shuffle_swapangle2 = 180	-- angle we're currently at (in degrees) for card2
						mo.shuffle_addedangle = 0	-- total angle we added

						if mo.shuffle_swap[1] == mo.shuffle_swap[2]	-- we can't swap the card with itself, correct this
							mo.shuffle_swap[2] = $+1
							if mo.shuffle_swap[2] > 4	-- oops, went out of bound whilst trying to correct
								mo.shuffle_swap[2] = 1
							end
						end

						-- we have both our cards, to make things easier, precalculate where the center between those two is.
						-- given our angle, the x axis is the only one we need to worry about
						mo.shuffle_swapx = (mo.shufflecards[mo.shuffle_swap[1]].x/FRACUNIT + mo.shufflecards[mo.shuffle_swap[2]].x/FRACUNIT)/2
						-- er, dumb last minute check:
						if mo.shufflecards[mo.shuffle_swap[1]].x > mo.shufflecards[mo.shuffle_swap[2]].x
							-- in this case, invert both our angles
							mo.shuffle_swapangle1 = 180
							mo.shuffle_swapangle2 = 0

						end

						-- this will be useful
						mo.shufflecards[mo.shuffle_swap[1]].targetx = mo.shufflecards[mo.shuffle_swap[2]].x
						mo.shufflecards[mo.shuffle_swap[2]].targetx = mo.shufflecards[mo.shuffle_swap[1]].x
						mo.shuffle_swapcoords = {mo.shufflecards[mo.shuffle_swap[1]].x, mo.shufflecards[mo.shuffle_swap[2]].x}

						-- now we're set to swap the cards in the handler below

						mo.shuffle_swaptime = nil	-- reset swap timer
					end
				else
					-- we are swapping our cards.
					-- Their actual movement is handled in their iterator below.
					-- here we take care of incrementing the angle and end the swaps

					mo.shuffle_addedangle = $+mo.shuffle_swapspeed
					mo.shuffle_swapangle1 = $+mo.shuffle_swapspeed
					mo.shuffle_swapangle2 = $+mo.shuffle_swapspeed

					if mo.shuffle_addedangle > 180 - (mo.shuffle_swapspeed+1)	-- swap is over
						-- swap the two cards in our shuffletypes table
						local card1 = mo.shuffle_swap[1]
						local card2 = mo.shuffle_swap[2]
						local c1type = mo.shuffletypes[card1]
						local c2type = mo.shuffletypes[card2]

						if i == 1
							--dprint("swapped "..card1.. "("..c1type..") with "..card2.." ("..c2type..")")
						end

						-- give the cards their target coordinates just in case:
						P_TeleportMove(mo.shufflecards[mo.shuffle_swap[1]], mo.shufflecards[mo.shuffle_swap[1]].targetx, mo.shufflecards[mo.shuffle_swap[1]].y, cam.z)
						P_TeleportMove(mo.shufflecards[mo.shuffle_swap[2]], mo.shufflecards[mo.shuffle_swap[2]].targetx, mo.shufflecards[mo.shuffle_swap[2]].y, cam.z)

						-- sort cards...
						table.sort(mo.shufflecards, function(a, b)
							return (a.x < b.x)
						end)

						-- get new array of types
						for k,v in ipairs(mo.shufflecards)

							-- get the new array of levels...
							if v.sprite ~= SPR_SHFL	-- a bit hacky I know...
								mo.shufflelevels[k] = (v.frame & FF_FRAMEMASK) +1	-- reminder that frame A is 0...
								local spr_to_type = {
									[SPR_SRDC] = 1,
									[SPR_CUPC] = 2,
									[SPR_COIC] = 3,
									[SPR_WNDC] = 4,
								}
								mo.shuffletypes[k] = spr_to_type[v.sprite] + (v.death and 1024 or 0)	-- sus.......

							else
								mo.shuffletypes[k] = (v.frame & FF_FRAMEMASK) + (v.death and 1024 or 0)
							end
						end

						mo.shuffle_swapx = nil
						mo.shuffle_swapcoords = nil
						mo.shuffle_swap = nil
						mo.shuffle_swapangle = 0
					end
				end
			end

			for j = 1, #mo.shuffletypes

				local c = mo.shufflecards[j]

				if not (mo.control == displayplayer and mo.control.maincontrol == mo)
					c.flags2 = $|MF2_DONTDRAW
				end

				-- flip the cards

				if btl.shuffletimer == TICRATE*2
					S_StartSound(nil, sfx_hamaca, mo.control)
				end

				if btl.shuffletimer >= TICRATE*2
				and btl.shuffletimer < TICRATE*2 + 9
					c.angle = $ + ANG1*20

				elseif btl.shuffletimer >= TICRATE*2 + 9

					if c.target
						c.target.flags2 = $|MF2_DONTDRAW
					end

					if c.death
						c.death.flags2 = $|MF2_DONTDRAW
					end

					--c.angle = cam.angle + ANG1*270	-- remain flipped for now
					c.angle = R_PointToAngle2(cam.x, cam.y, c.x, c.y) - ANG1*90

					-- swap the cards!
					if mo.shuffle_swap
					and mo.shuffle_addedangle < 180 - (mo.shuffle_swapspeed+1)	-- safe measure
					and not mo.shuffle_swaptime
					and mo.shuffle_timesswapped < 8
						-- we must identify who we are;
						-- card1 goes below, card2 goes above when swapping

						if j == mo.shuffle_swap[1]	-- we are card 1
							-- again, we only worry about x and z here
							local dist = (mo.shuffle_swapx - mo.shuffle_swapcoords[1]/FRACUNIT)
							local x = mo.shuffle_swapx*FRACUNIT + dist*cos(mo.shuffle_swapangle1*ANG1)
							local z = cam.z + dist*sin(mo.shuffle_swapangle1*ANG1)	-- cam.z is the base z coord for this
							P_TeleportMove(c, x, c.y, z)
							--dprint((mo.shuffle_swapx/FRACUNIT).." - "..(mo.shuffle_swapcoords[1]/FRACUNIT))

						elseif j == mo.shuffle_swap[2] -- we are card 2
							-- again, we only worry about x and z here
							local dist = (mo.shuffle_swapcoords[2]/FRACUNIT - mo.shuffle_swapx)
							local x = mo.shuffle_swapx*FRACUNIT + dist*cos(mo.shuffle_swapangle2*ANG1)
							local z = cam.z + dist*sin(mo.shuffle_swapangle2*ANG1)	-- cam.z is the base z coord for this
							P_TeleportMove(c, x, c.y, z)
						end
					end
				end

			end
		end
	end
end)

-- score reels for multiplayer
-- mostly cosmetic just to tell players to give themselves a pat on the back!~
rawset(_G, "BTL_MPfinish", function(pn)

	local btl = server.P_BattleStatus[pn]
	local t = btl.hudtimer.mpfinish
	local cam = btl.cam
	local plist = btl.plist

	if t > TICRATE
		-- get a point somewhere in our view to spawn the rain
		local x = cam.x + 128*cos(cam.angle)
		local y = cam.y + 128*sin(cam.angle)

		local freq = max(1, t/3)
		local amt = 16 - (t*2/TICRATE)

		for i = 1, max(1, amt)
			local s = P_SpawnMobj(x + P_RandomRange(-150, 150)*FRACUNIT, y + P_RandomRange(-150, 150)*FRACUNIT, cam.ceilingz, MT_DUMMY)
			s.sprite = SPR_RAIN
			s.frame = B
			s.color = P_RandomRange(0, 1) and SKINCOLOR_RED or SKINCOLOR_BLACK
			s.momz = -FRACUNIT*16
			s.tics = TICRATE*2
			s.flags = MF_NOCLIPHEIGHT
			s.scale = FRACUNIT*3/2
		end
	end

	if t < TICRATE*3
	and (t%6) == 0
	and t
		createSplat(btl.turnorder[1], FRACUNIT*3, FRACUNIT, -1)
		playSound(pn, sfx_ghit)
	end

	if not t	-- timer over, spin cam like usual~
		-- by the time the timer hits 180 we will be showing the attack
		local gox = btl.arena_coords[1] + 900*cos((leveltime)*(ANG1/4))
		local goy = btl.arena_coords[2] + 900*sin((leveltime)*(ANG1/4))
		-- simply teleport the camera, we don't need it to transition with CAM_goto

		P_TeleportMove(cam, gox, goy, btl.arena_coords[3] + 350<<FRACBITS)
		cam.aiming = -ANG1*3
		cam.angle = R_PointToAngle2(gox, goy, btl.arena_coords[1], btl.arena_coords[2])
		-- make the camera spin towards the center of the arena, or something

		for _, v in ipairs(server.plentities[pn])
			v.flags2 = $|MF2_DONTDRAW
			-- no shuffletime to worry about here <3
		end

		for i = 1, #plist do
			local p = plist[i]
			if not p or not p.valid continue end
			S_ChangeMusic("RESLTF", true, p)
		end
	end

	-- wait for server input:
	-- (we consider the server as player entity #1's control)
	local p = plist[1]
	if not p or not p.valid
		p = plist[1]	-- :shrug:
	end

	if not p or p.cmd == nil
	or p.cmd.buttons & BT_JUMP	-- lol yeah
		-- ok so basically
		--btl.running = false
		btl.kill = true	-- on next mapload; set this to nil and reload
		--G_ExitLevel(1, true)
		--btl.battlestate = 0	-- do NOT buffer this shit multiple times for some godforsaken reason
	end
end)

rawset(_G, "BTL_HyperDie", function(pn)
	local btl = server.P_BattleStatus[pn]
	local t = btl.extra_blowuptarget

	btl.extra_blowuptime = $+1
	if btl.extra_blowuptime == 1
		status_cam(t)
		playSound(pn, sfx_debuff)
		resetEntitiesPositions(pn)
	end

	if btl.extra_blowuptime < TICRATE*3/2
		local h_angle = P_RandomRange(1, 359)*ANG1
		local v_angle = P_RandomRange(1, 359)*ANG1
		local dist = 256
		local spd = P_RandomRange(40, 50)

		local s_x = t.x+ dist*FixedMul(cos(h_angle), cos(v_angle))
		local s_y = t.y+ dist*FixedMul(sin(h_angle), cos(v_angle))
		local s_z = (t.z+t.height/2)+ dist* sin(v_angle)

		local s = P_SpawnMobj(s_x, s_y, s_z, MT_DUMMY)

		s.frame = A
		s.color = SKINCOLOR_WHITE
		s.scale = FRACUNIT*3/2
		s.destscale = FRACUNIT/5
		s.target = t
		s.tics = 10
		s.momx = (t.x - s.x)/10
		s.momy = (t.y - s.y)/10
		s.momz = (t.z - s.z)/10

		--A_HomingChase(s, 10*FRACUNIT, 0)
	elseif btl.extra_blowuptime == TICRATE*3/2
		local cam = btl.cam
		CAM_stop(cam)
		local bx = t.x + 1024*cos(t.angle)
		local by = t.y + 1024*sin(t.angle)

		P_TeleportMove(cam, bx, by, t.z + FRACUNIT*128)
		cam.angle = R_PointToAngle2(bx, by, t.x, t.y)
		playSound(btl.n, sfx_megi5)

		local an = 0
		for i = 1, 32
			local s = P_SpawnMobj(t.x, t.y, t.z + FRACUNIT*32, MT_DUMMY)
			s.color = SKINCOLOR_WHITE
			s.state = S_MEGITHOK
			s.scale = $/2
			s.fuse = TICRATE*2
			P_InstaThrust(s, an*ANG1, 50<<FRACBITS)

			s = P_SpawnMobj(t.x, t.y, t.z + FRACUNIT*32, MT_DUMMY)
			s.color = SKINCOLOR_WHITE
			s.state = S_MEGITHOK
			s.scale = $/4
			s.fuse = TICRATE*2
			P_InstaThrust(s, an*ANG1, 30<<FRACBITS)

			an = $ + (360/32)
		end

		t.flags2 = $|MF2_DONTDRAW
		-- now hurt everyone that's in our team:
		updateUDtable(t.allies)	-- clear invalid entries if necessary
		for k,v in ipairs(t.allies)
			if v ~= t	-- not ourselves though lol...
				resetDamage(v)
				v.atk_hitby = BTL_copyAttackDefs(attackDefs["dummy"])
				damageObject(v, v.maxhp/3 + P_RandomRange(-v.maxhp/8, v.maxhp/8), DMG_NORMAL)
			end
		end
	elseif btl.extra_blowuptime == TICRATE*7/2
		t.extra = nil
		t.hp = 0
		btl.battlestate = BS_ENDTURN
	end
end)

rawset(_G, "retrymsg", {
	"Keep pressing on!",
	"Let's try that again!",
	"Don't give up!",
	"It's not over yet!",
	"None of that ever happened!",
	"That was rough...!",
	"There's always hope!",
	"Not gonna let this happen, are you?",
	"He's not gonna get away with this!",
})

rawset(_G, "BTL_gameOver", function(pn)
	local battle = server.P_BattleStatus[pn]
	local t = battle.hudtimer.gameovertimeout

	local nbkill = 0
	for i = 1, 4
		local tb = server.P_BattleStatus[i]

		if tb.gameover or not (server.plentities[i][1])
			nbkill = $+1
		end
	end

	if battle.hudtimer.gameoverremove

		if battle.hudtimer.gameoverremove == 1	--
			-- start by ending the battles:
			for i = 1,4
				if not server.P_BattleStatus[i].running continue end
				for j = 1, server.P_netstat.teamlen do
					if not server.plentities[i][j] continue end
					local mo = server.plentities[i][j]
					mo.hp = mo.maxhp
					mo.sp = mo.maxsp
					mo.skills = copyTable(mo.saveskills)
				end
				server.P_BattleStatus[i].r_wipe = 1	-- instantly clear
				BTL_finish(i)
			end

			server.P_DungeonStatus.gameoverfade = 9		-- quick hack
			server.P_DungeonStatus.lifeexplode = 9+20
			if gamemap == 5
				-- If we're at the peak, reset the map
				DNG_loadNewMap(5)
			else
				-- go back to the last floor where we saved
				DNG_setFloor(server.P_DungeonStatus.savefloor)
			end
			DNG_logMessage(retrymsg[P_RandomRange(1, #retrymsg)])
		end

		return	-- don't continue
	end

	if nbkill >= 4
	and pn == 1	-- first battle status gets to choose what we do
		local inputs = server.plentities[pn][1].control.mo.P_inputs	-- player 1

		if inputs[BT_JUMP] == 1
		and server.P_BattleStatus.lives
		and server.gamemode ~= GM_VOIDRUN
			dprint("Retrying from the last starpost...!")
			-- restart from the last checkpoint

			-- start by ending the battles:
			for i = 1,4
				if not server.P_BattleStatus[i].running continue end
				server.P_BattleStatus[i].hudtimer.gameoverremove = 9
			end

			-- take my life away
			server.P_BattleStatus.lives = $-1

		elseif inputs[BT_USE] == 1
			-- terminate the game
			for i = 1, 4
				server.P_BattleStatus[i].running = false
				server.P_BattleStatus[i].battlestate = 0
			end
			server.P_BattleStatus.kill = true
			G_SetCustomExitVars(1, 1)
			G_ExitLevel()
			dprint("Terminated session")
		end
	end
end)

rawset(_G, "BTL_pvpOver", function(pn)
	local btl = server.P_BattleStatus[pn]
	if not btl.hudtimer.pvpend
		server.P_BattleStatus.kill = true
		G_SetCustomExitVars(1, 1)
		G_ExitLevel()
		btl.battlestate = 0
		dprint("Terminated session")
	end
end)

rawset(_G, "BTL_moreEnemiesHandler", function(pn)
	local btl = server.P_BattleStatus[pn]
	local battleStatus = btl	-- convenience for the copypasted chunk of code
	local mo = server.plentities[pn][1]	-- this works

	-- respawn shit:
	if TICRATE*5/2 - btl.hudtimer.moreenemies == TICRATE*3/2
		local x, y, z = battleStatus.arena_coords[1], battleStatus.arena_coords[2], battleStatus.arena_coords[3]
		local dist = 256
		local currangle = battleStatus.arena_coords[4]

		local temp_an = currangle

		-- ready our enemies
		local team2 = {}
		for i = 1, #btl.nextwave do
			local enm = P_SpawnMobj(0, 0, 0, MT_PFIGHTER)
			enm.state = S_PLAY_STND
			enm.tics = -1
			enm.enemy = btl.nextwave[i]
			team2[#team2+1] = enm
		end


		for k,v in ipairs(mo.allies_noupdate)	-- some team1 stuff
			v.enemies = copyTable(team2)	-- reset our enemy table
			v.enemies_noupdate = copyTable(team2)
		end

		currangle = temp_an + ANG1*180 --ANGLE_180+ANGLE_90+ANG1*20

		for k,v in ipairs(team2)	-- spawn team2 (generally enemies row)
			x, y = battleStatus.arena_coords[1]+dist*cos(currangle), battleStatus.arena_coords[2]+dist*sin(currangle)
			P_TeleportMove(v, x, y, z)	-- Teleport the object to the right spot.
			v.angle = currangle+ANGLE_180
			currangle = $- (ANG1*30)

			v.battlen = pn	-- save which arena we're on

			if v.enemy
				BTL_initEnemy(v)	-- this is likely to be the case unless we're in pvp.
			end
			v.enemies = copyTable(mo.allies)
			v.allies = copyTable(team2)
			v.allies_noupdate = copyTable(team2)
			v.enemies_noupdate = copyTable(mo.allies_noupdate)	-- this table doesn't update, we use it for reviving
			v.saveskills = copyTable(v.skills)	-- you never know
			v.savestats = {v.strength, v.magic, v.endurance, v.agility, v.luck}	-- back up stats
			BTL_initAdditionalSkills(v)
			BTL_setupstats(v)

			-- in battle, we cannot use passive skills
			BTL_splitSkills(v)
			v.flags2 = $ & ~MF2_DONTDRAW

			-- rather unlikely
			if v.subpersona
				BTL_equipSubPersona(v, v.subpersona)
			end

			-- Execute PSV_STARTBATTLE passives?
			-- I guess technically this isn't the start of the battle but these guys JUST spawned.
			for i = 1, #v.passiveskills
				local psv = v.passiveskills[i]
				if attackDefs[psv]
					psv = attackDefs[$]
					if psv.passive == PSV_STARTBATTLE
					and psv.anim
						psv.anim(v, {v}, {v}, 1)	-- Execute this skill's anim function on myself ONCE.
					end
				end
			end

			v.enemy_spawndelay = TICRATE/2 + (TICRATE/6)*k
			v.sprite = SPR_ENMA
			v.frame = A

			battleStatus.fighters[#battleStatus.fighters+1] = v
			BTL_addtoplist(battleStatus, v)
		end

		btl.hudtimer.newenemyspawn = TICRATE*3/2
		-- restart turn order
		btl.turnorder = BTL_BuildTurnOrder(pn)
	end

	if btl.hudtimer.newenemyspawn

		if btl.hudtimer.newenemyspawn == 1
			btl.battlestate = BS_PRETURN
			return
		end

		for k,v in ipairs(mo.enemies)

			if not v.valid continue end
			if not v.enemy continue end

			if v.enemy_spawndelay
				v.anim = nil	-- don't set the state :P
				v.enemy_spawndelay = $-1
				--v.flags2 = $|MF2_DONTDRAW	-- magical
				if not v.enemy_spawndelay
					v.scale = v.escale
					ANIM_set(v, v.anim_stand, true)
					v.enemy_spawndelay = nil

					for i = 1, 128
						local color = SKINCOLOR_RED
						if i%2 color = SKINCOLOR_BLACK end

						local x, y, z = v.x+P_RandomRange(-50, 50)*FRACUNIT, v.y+P_RandomRange(-50, 50)*FRACUNIT, v.z+P_RandomRange(-50, 50)*FRACUNIT
						local particle = P_SpawnMobj(x, y, z, MT_DUMMY)
						particle.color = color
						particle.frame = A
						particle.tics = 100
						particle.destscale = 0
						particle.momz = P_RandomRange(1, 10)*FRACUNIT
					end
				end
			end
		end
	end
end)

rawset(_G, "BTL_challengeEndHandler", function(pn)
	-- challenge has ended (loss or not)
	local btl = server.P_BattleStatus[pn]

	if btl.challengewon
	and not btl.challengesaved
	and btl.challenge <= MAXCHALLENGEBATTLES
		-- save new personal bests!

		if btl.scoremode
			if btl.score > (srb2p.challenge_bests[btl.challenge] or 0)
				btl.newrecord = true	-- this is clientsided, ssh.
				srb2p.challenge_bests[btl.challenge] = btl.score
			end
		else

			if btl.battletime < (srb2p.challenge_bests[btl.challenge] or 9999*TICRATE)
				btl.newrecord = true	-- this is clientsided, ssh.
				srb2p.challenge_bests[btl.challenge] = btl.battletime
			end
		end

		-- check if we must unlock new challenges!
		local n = #srb2p.challenge_bests

		for i = 1, #BTL_challengebtllist
			local b = BTL_challengebtllist[i]

			if b.required
			and b.unlock
			and n >= b.required
			and not srb2p.local_conds[b.unlock]

				for p in players.iterate
					P_unlock(b.unlock, p, "A new challenge battle has been unlocked!")
				end
			end
		end

		-- check if we unlocked anything new!
		local c = BTL_challengebtllist[btl.challenge]
		if c.unlocks
		and not srb2p.local_conds[c.unlocks[1]]

			for p in players.iterate
				P_unlock(c.unlocks[1], p, c.unlocks[2])
			end
		end

		btl.challengesaved = true	-- don't repeat that every frame...
	end

	if not btl.hudtimer.challengeend
		if btl.newrecord
			SAVE_put_xdata()	-- save my records!
		end
		btl.kill = true
	end
end)

-- {BS_, func, if true, which BS_ ?}
rawset(_G, "battlefunchandler", {
	[BS_START] 		=	{BTL_startHandler, 		BS_PRETURN},
	[BS_PRETURN] 	=	{BTL_preturnHandler, 	BS_DOTURN},
	[BS_DOTURN]		=	{BTL_turnHandler,		BS_ACTION},
	[BS_ACTION]		=	{BTL_actionHandler,		BS_ENDTURN},
	[BS_ENDTURN]	=	{BTL_endturnHandler,	nil},
	[BS_HOLDUP]		=	{BTL_holdupHandler,		nil},
	[BS_SHUFFLE]	=	{BTL_shuffleHandler,	nil},
	[BS_END]		=	{BTL_endHandler,		nil},
	[BS_LEVELUP]	=	{BTL_levelUpHandler,	nil},
	[BS_FINISH] 	=	{BTL_finish,			nil},
	[BS_MPFINISH]	=	{BTL_MPfinish,			nil},
	[BS_HYPERDIE]	=	{BTL_HyperDie,			nil},
	[BS_GAMEOVER]	=	{BTL_gameOver,			nil},
	[BS_PVPOVER]	=	{BTL_pvpOver,			nil},
	[BS_MOREENEMIES]=	{BTL_moreEnemiesHandler,nil},
	[BS_CHALLENGEEND]=	{BTL_challengeEndHandler,	nil},
	[BS_LINK] = 		{BTL_linkHandler, 		BS_ENDTURN},
})

--addHook("ThinkFrame", do	-- now let's throw all this shit together y'see
rawset(_G, "BTL_Thinker", function()
	if not server return end
	if not server.valid return end

	if not server.plentities or not #server.plentities or not server.skinlist return end	-- wait until we're finished setting up our team in MP

	local kill = 0
	local gameover = 0
	local kbuf

	for i = 1, 4

		if not server or not server.valid return end

		if server.P_BattleStatus[i]
		and server.P_BattleStatus[i].running	-- no need to call our handlers if nothing's running lol
			local battle = server.P_BattleStatus[i]
			BTL_mainHandler(i)				-- battle time, camera etc

			if battlefunchandler[battle.battlestate]
				if battlefunchandler[battle.battlestate][1](i)
					battle.battlestate = battlefunchandler[$][2]
				end
			end

			-- btl needs killing??
			if battle.kill
			or not (server and server.valid and server.plentities and #server.plentities[i])	-- if battlestatus is empty, count is as finished regardless.
				kill = $+1
				kbuf = true
			end

			if battle.gameover
			or not (server and server.valid and server.plentities and #server.plentities[i])	-- if battlestatus is empty, count is as finished regardless.
				gameover = $+1
			end
		end

		if server and server.valid
		and server.P_BattleStatus
		and not server.P_BattleStatus[i].running
		and not #server.plentities[i]
			kill = $+1
		end
	end

	if not server or not server.valid return end	--!?

	if kill >= 4	-- end session
	and kbuf

		if gameover >= 4
			-- wait for commands
			return
		end

		for i = 1, 4
			server.P_BattleStatus[i].running = false
			server.P_BattleStatus[i].battlestate = 0
		end
		server.P_BattleStatus.kill = true
		G_SetCustomExitVars(1, 1)
		G_ExitLevel()
		dprint("Terminated session")
	end
end)


COM_AddCommand("d_rigexp", function(p, arg)

	if not cv_debugcheats.value return end

	if not p or not p.P_party return end	-- bruh
	if not arg return end
	local btl = server.P_BattleStatus[p.P_party]
	if not btl.running return end

	btl.r_exp = $ + (tonumber(arg) or 0)
end, 1)

COM_AddCommand("d_endbattle", function(p)

	if not cv_debugcheats.value return end

	if not p or not p.P_party return end	-- bruh
	local btl = server.P_BattleStatus[p.P_party]
	if not btl.running return end

	for i = 1, #p.control.enemies
		if not p.control.enemies[i] or not p.control.enemies[i].valid continue end
		p.control.enemies[i].hp = 0
		p.control.enemies[i].flags2 = $|MF2_DONTDRAW
		btl.r_exp = $ + enemyList[p.control.enemies[i].enemy].r_exp
		btl.r_money = $ + enemyList[p.control.enemies[i].enemy].r_exp/4
	end
	btl.battlestate = BS_ENDTURN
	print("DEBUG: Forcefully ended battle...")
end, 1)

COM_AddCommand("d_getsubpersona", function(p, arg)

	if not cv_debugcheats.value return end

	if not p or not p.P_party return end	-- bruh
	local btl = server.P_BattleStatus[p.P_party]
	if not arg return end

	if subpersonaList[arg]
		btl.subpersonas[#btl.subpersonas+1] = P_generateSubPersona(arg)
		CONS_Printf(p, "DEBUG: Sub Persona \'"..arg.."\' added to battle status "..p.P_party)
	else
		CONS_Printf(p, "DEBUG: Subpersona \'"..arg.."\' does not exist.")
	end
end, 1)

COM_AddCommand("d_getskillcard", function(p, arg)

	if not cv_debugcheats.value return end

	if not p or not p.P_party return end
	local btl = server.P_BattleStatus[p.P_party]
	if not arg return end

	if attackDefs[arg]
		btl.skillcards[#btl.skillcards+1] = arg
		CONS_Printf(p, "DEBUG: Skill Card \'"..arg.."\' added to battle status "..p.P_party)
	else
		CONS_Printf(p, "DEBUG: Skill Card \'"..arg.."\' does not exist.")
	end
end, 1)

COM_AddCommand("d_getitem", function(p, arg)

	if not cv_debugcheats.value return end

	if not p or not p.P_party return end
	local btl = server.P_BattleStatus[p.P_party]
	if not arg return end

	if itemDefs[arg]
		BTL_addItem(btl, arg, 1)
		CONS_Printf(p, "DEBUG: Item \'"..arg.."\' added to battle status "..p.P_party)
	else
		CONS_Printf(p, "DEBUG: Item \'"..arg.."\' does not exist.")
	end
end, 1)

COM_AddCommand("d_getmacca", function(p, arg)

	if not cv_debugcheats.value return end

	if not p or not p.P_party return end	-- bruh
	local btl = server.P_BattleStatus[p.P_party]
	if not arg return end

	btl.macca = $ + (tonumber(arg) or 0)
end, 1)

COM_AddCommand("d_resetstats", function(p, arg)

	if not cv_debugcheats.value return end

	local list = server.plentities[p.P_party]
	if not list or not #list return end	-- nigga?

	for i = 1, #list do
		PLYR_getStats(list[i], list[i].level, true)
	end

end, 1)

COM_AddCommand("d_getweapon", function(p, arg, arg2)

	if not cv_debugcheats.value return end
	if not arg return end

	if not weaponsList[arg]
		CONS_Printf(p, "Weapon '"..arg.."' doesn't exist.")
		return
	else
		local lv = tonumber(arg2) or 0	
		local wp = makeWeapon(arg, lv)
		addWeapon(p.mo, wp)
		CONS_Printf(p, "DEBUGL Weapon '"..arg.."' added to weapon list")
	end
end, 1)

COM_AddCommand("d_getring", function(p, arg, arg2)

	if not cv_debugcheats.value return end
	if not arg return end

	if not ringsList[arg]
		CONS_Printf(p, "Ring '"..arg.."' doesn't exist.")
		return
	else
		local lv = tonumber(arg2) or 0
		local r = makeRing(arg, lv)
		addRing(p.mo, r)
		CONS_Printf(p, "DEBUGL Wardring '"..arg.."' added to ring list")
	end
end, 1)