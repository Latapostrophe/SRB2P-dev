for i = 2, 9
	freeslot("SPR_ENM"..i)
end

freeslot("SPR_KNDR")
freeslot("SPR_BATK")
freeslot("SPR_VALT")
freeslot("SPR_MNMS")

for i = 1, 7
	freeslot("sfx_batk"..i)
end

for i = 1, 8
	freeslot("sfx_bean"..i)
end

-- select the most appropriate attack
-- return values: skill, target
-- target may be nil, in this case, use the skill's auto targetting method
-- for tgt_allallies / tgt_allenemies, make sure to reassign the target properly

rawset(_G, "smartAttackSelect", function(mo, forceheal)

	-- ally under 50% health, see if we can help them out with our best healing skill!
	-- though, always prioritize the ally with the lowest health.

	local onemore = mo.batontouch
	-- this may seem silly, but this is an effective way to check if we're acting out of a 1more!

	-- Last resort skills: Always use those if our HP is 25% or less.

	if mo.hp < mo.maxhp/4
		for i = 1, #mo.skills
			if not attackDefs[mo.skills[i]] continue end
			if attackDefs[mo.skills[i]].lastresort
				return attackDefs[mo.skills[i]]
			end
		end
	end

	local heal
	local healcount = 0	-- used to know if we should prioritize using single target heal or multi target heal
	local healskill

	for i = 1, #mo.allies
		local a = mo.allies[i]
		if a.hp < a.maxhp/2
			--dprint("ENEMY LOGIC: Weakened ally, searching for healing skills...")
			healcount = $+1	-- # of allies we have to heal
			if heal and a.hp < heal.hp
				heal = a
			end
		end
	end

	local healChance = P_RandomRange(0, 100)

	if heal	-- we have to try to heal someone!
	and (forceheal or healChance < 25)	-- 25% chance of healing, to avoid stall fests
		-- check if we have a skill for that
		for i = 1, #mo.skills
			local a = attackDefs[mo.skills[i]]
			if a.type == ATK_HEAL and a.power	-- this is a healing skill
				if healskill	-- we already have a healing skill chosen... let's see if this new skill is better suited
					if healskill.targettype == TGT_ALLY and a.targettype == TGT_ALLALLIES and healcount > 1
						healskill = a
						continue
						-- we need to heal multiple targets, and this skill heals more!
					end

					if healskill.targettype == TGT_ALLALLIES and a.targettype == TGT_ALLY and healcount <= 1
						healskill = a
						continue
						-- don't needlessly waste SP using multi heal when we could instead heal only a single target
					end

					if healskill.power < a.power and healskill.targettype == a.targettype
						healskill = a
						continue
						-- same target type, but more power. Tell you what, let's replace it!
					end
				end

				healskill = a
			end
		end
	end

	if healskill
		--dprint("ENEMY LOGIC: Healing skill found")
		return skill, a
	end

	local dekunda
	local dekundaskill
	local dekaja
	local dekajaskill

	-- we are affected by debuffs...
	-- see if we can use dekunda!

	if onemore
		--dprint("ENEMY LOGIC: 1MORE! Checking for actions...")
		for i = 1, #mo.allies do
			local a = mo.allies[i]
			for k, v in pairs(a.buffs) do

				if v[1] < 0	-- v[1] is a.buffs[key][1]
					--dprint("ENEMY LOGIC: Affected by debuffs, trying to find dekunda...")
					-- this stat has been lowered! I don't like this one bit!
					dekunda = 1
					break
				end
			end
		end

		if dekunda	-- search for dekunda in our skill list...
			for i = 1, #mo.skills
				local a = attackDefs[mo.skills[i]]
				if a and a.dekunda
					dekundaskill = a
					break
				end
			end
		end

		if dekundaskill
			--dprint("ENEMY LOGIC: Found dekunda.")
			return dekundaskill
		end

		-- less important, try and use dekaja if the enemy party is buffed
		for i = 1, #mo.enemies do
			local a = mo.enemies[i]
			for k, v in pairs(a.buffs) do

				if v[1] > 0	-- v[1] is a.buffs[key][1]
					--dprint("ENEMY LOGIC: Found enemy affected by buff! I don't like this!")
					-- this stat has been increased! I don't like this one bit!
					dekunda = 1
					break
				end
			end
		end

		if dekaja	-- search for dekaja in our skill list...
			for i = 1, #mo.skills
				local a = attackDefs[mo.skills[i]]
				if a and a.dekaja
					dekajaskill = a
					break
				end
			end
		end

		if dekajaskill
			--dprint("ENEMY LOGIC: Found dekaja.")
			return dekajaskill
		end

		--dprint("ENEMY LOGIC: Nothing better to do, see if we can buff ourselves or debuff the enemy!")

		-- if none of that can be done, let's see if we can use this to buff ourselves, perhaps?
		-- or debuff the enemy, one of the other!
		local superbuffs = {}
		local buffs = {}
		local superdebuffs = {}
		local debuffs = {}

		-- get everything we can:
		for i = 1, #mo.skills
			local a = attackDefs[mo.skills[i]]
			if not a
				--dprint(mo.skills[i].." is invalid!")
				continue
			end

			if a.superbuff
			and not (a.tetrakarn and mo.tetrakarn)
			and not (a.makarakarn and mo.makarakarn)
				superbuffs[#superbuffs+1] = a
			elseif a.buff
				buffs[#buffs+1] = a
			elseif a.superdebuff
				superdebuffs[#superdebuffs+1] = a
			elseif a.debuff
				debuffs[#debuffs+1] = a
			end
		end

		-- depending on what we have, prioritize buffing ourselves in that situation!
		if #superbuffs and P_RandomRange(0, 4)
			return superbuffs[P_RandomRange(1, #superbuffs)]
		elseif #buffs and P_RandomRange(0, 1)
			return buffs[P_RandomRange(1, #buffs)]
		elseif #superdebuffs and P_RandomRange(0, 4)
			return superdebuffs[P_RandomRange(1, #superdebuffs)]
		elseif #debuffs and P_RandomRange(0, 1)
			return debuffs[P_RandomRange(1, #debuffs)]
		end
	end

	-- ghastly wail is a tool of mass destruction!
	-- check if targets are fearful!
	local gtarget

	for i = 1, #mo.enemies
		local a = mo.enemies[i]
		if a.status_condition == COND_HEX
			gtarget = a
			--dprint("ENEMY LOGIC: Found a fearful enemy... Checking for Ghastly Wail...")
			break
		end
	end

	local btl = server.P_BattleStatus[mo.battlen]

	if gtarget
	and btl.turnorder[2] == mo		-- double-turn enemies: only use ghastly wail on our first turn
									-- WARNING: THIS CODE DOESN'T WORK FOR ENEMIES WITH > 2 TURNS

		for i = 1, #mo.skills
			local a = attackDefs[mo.skills[i]]
			if a and a.ghastlywail
				--dprint("ENEMY LOGIC: Found Ghastly Wail")
				return a, gtarget
			end
		end
	end

	-- looks like we're out of cool options, huh!
	-- build a skill list without the specific skills we can't use at all.

	--dprint("ENEMY LOGIC: No special action, just select a random skill")

	local usable_skills = {}

	local last_turn = server.P_BattleStatus[mo.battlen][2] ~= mo
	-- if we don't have a turn after this one, we CAN use mind/power charge

	for i = 1, #mo.skills
		local s = mo.skills[i]
		local a = attackDefs[s]

		if a
		and not a.dekunda
		and not a.dekaja
		and not a.ghastlywail
		and not (last_turn and (a.powercharge or a.mindcharge))
		and not (a.type == ATK_HEAL)
		and not (mo.mindcharge and isAttackPhysical(a))
		and not (mo.powercharge and not isAttackPhysical(a))
		and not ((mo.mindcharge or mo.powercharge) and (not a.power or a.instantkill))
			usable_skills[#usable_skills+1] = s
		end
	end

	local atk
	if not #usable_skills
		atk = (enemyList[mo.enemy].melee_natk or "slash_1")	-- default attack
	else
		atk = usable_skills[P_RandomRange(1, #usable_skills)]
	end

	return attackDefs[atk]
end)

rawset(_G, "generalEnemyThinker", function(mo)
	-- we are a retarded enemy and we're too generic to do anything specific!
	--dprint("Enemy thinker for "..mo.name)
	-- do we use a skill or our normal attack?
	local skillchance = enemyList[mo.enemy].skillchance or 50
	local attack, targets
	local atarget

	if P_RandomRange(0, 100) <= skillchance and mo.skills and #mo.skills
	and mo.status_condition ~= COND_RAGE
	and mo.status_condition ~= COND_SILENCE
		attack, atarget = smartAttackSelect(mo) or attackDefs[(enemyList[mo.enemy].melee_natk or "slash_1")]
	else	-- no skills or not using skills
		attack = attackDefs[(enemyList[mo.enemy].melee_natk or "slash_1")]	-- default attack
	end

	if not atarget	-- nothing from smart select, do it the yolo way!
		targets = {mo.enemies[P_RandomRange(1, #mo.enemies)]}

		-- get the target(s) of the attack
		if not attack
			attack = attackDefs[(enemyList[mo.enemy].melee_natk or "slash_1")]
		end
		local skill = attack

		if skill.target == TGT_ENEMY	-- target random enemy
			targets = {mo.enemies[P_RandomRange(1, #mo.enemies)]}
		elseif skill.target == TGT_ALLENEMIES
			targets = copyTable(mo.enemies)	-- target all enemies
		elseif skill.target == TGT_ALLY	-- target random ally
			targets = {mo.allies[P_RandomRange(1, #mo.allies)]}
		elseif skill.target == TGT_ALLALLIES -- target all allies
			targets = copyTable(mo.allies)
		elseif skill.target == TGT_CASTER
			targets = {mo}
		elseif skill.target == TGT_DEAD
			print("\x82".."WARNING:".."\x80".." Enemies shouldn't use skills targetting dead entities.")
			attack = "slash_1"
			targets = {mo.enemies[P_RandomRange(1, #mo.enemies)]}	-- fallback
		elseif skill.target == TGT_EVERYONE
			targets = {}
			for i = 1, #mo.allies
				targets[#targets+1] = mo.allies[i]
			end
			for i = 1, #mo.enemies
				targets[#targets+1] = mo.enemies[i]
			end
		end
	else
		targets = {atarget}	-- lol.
	end

	return attack, targets
end)

-- enemies

rawset(_G, "enemyList", {
	["test_entity"] = {
		name = "TEST ENEMY",
		level = 80,
		hp = 999,
		sp = 999,
		skillchance = 100,
		strength = 40,
		magic = 40,
		endurance = 40,
		luck = 40,
		agility = 40,
		melee_natk = "strike_1",	-- enemies don't have crit anims for their attacks.
		weak = 0,
		repel = ATK_ICE,
		thinker = generalEnemyThinker,
		r_exp = 1000,

		anim_stand = 		{SPR_ENM1, A, 10},
		anim_stand_hurt =	{SPR_ENM1, A, 1},
		anim_move =			{SPR_ENM1, A, 2},
		anim_run =			{SPR_ENM1, A, 2},
		anim_hurt =			{SPR_ENM1, A, 35},
		anim_getdown =		{SPR_ENM1, A, 1},
		anim_downloop =		{SPR_ENM1, A, 1},
		anim_getup =		{SPR_ENM1, A, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"poisma"},
	},

	["reaper_noboss"] = {
		name = "The Reaper",
		skillchance = 100,	-- /100, probability of using a skill
		level = 99,
		hp = 4444,
		sp = 4444,
		strength = 85,
		magic = 85,
		endurance = 66,
		luck = 66,
		agility = 66,
		melee_natk = "strike_1",	-- enemies don't have crit anims for their attacks.
		thinker = generalEnemyThinker,
		boss = true,
		turns = 2,
		scale = FRACUNIT*3/2,

		r_exp = 75000,
		anim_stand = 		{SPR_REAP, A, B, C, D, E, F, G, H, I, J, 4},
		anim_stand_hurt = 	{SPR_REAP, A, B, C, D, E, F, G, H, I, J, 4},
		anim_move =			{SPR_REAP, A, B, C, D, E, F, G, H, I, J, 4},
		anim_run =			{SPR_REAP, A, B, C, D, E, F, G, H, I, J, 4},
		anim_hurt =			{SPR_REAP, A, 10},
		anim_getdown =		{SPR_REAP, A, 1},
		anim_downloop =		{SPR_REAP, A, 1},
		anim_getup =		{SPR_REAP, A, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {	"megidola", "megidolaon", "power charge", "mind charge",
					"megaton raid", "vicious strike", "marakunda", "heat riser",
					"marakunda", "masukunda", "matarunda", "maragidyne", "mabufudyne",
					"fire boost", "ice boost", "elec boost", "wind boost", "psy boost", "nuke boost", "bless boost", "curse boost",
					"magarudyne", "maziodyne", "mafreidyne", "mapsiodyne", "tetrakarn", "makarakarn",
					"dekaja", "dekunda"},
	},

	["reaper_alt"] = {
		name = "The Reaper",
		skillchance = 100,	-- /100, probability of using a skill
		level = 99,
		hp = 4444,
		sp = 4444,
		strength = 85,
		magic = 85,
		endurance = 85,
		luck = 85,
		agility = 1,
		melee_natk = "strike_1",	-- enemies don't have crit anims for their attacks.
		thinker = 	function(mo)

						D_startEvent(mo.battlen, "ev_b7_start")
						return attackDefs["heat riser"], {mo}
					end,

		boss = true,
		nopvp = true,
		turns = 2,
		scale = FRACUNIT*3/2,

		r_exp = 75000,
		anim_stand = 		{SPR_REAP, A, B, C, D, E, F, G, H, I, J, 4},
		anim_stand_hurt = 	{SPR_REAP, A, B, C, D, E, F, G, H, I, J, 4},
		anim_move =			{SPR_REAP, A, B, C, D, E, F, G, H, I, J, 4},
		anim_run =			{SPR_REAP, A, B, C, D, E, F, G, H, I, J, 4},
		anim_hurt =			{SPR_REAP, A, 10},
		anim_getdown =		{SPR_REAP, A, 1},
		anim_downloop =		{SPR_REAP, A, 1},
		anim_getup =		{SPR_REAP, A, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"infinite endure", "heat riser"},
	},

	["reaper"] = {
		name = "The Reaper",
		skillchance = 100,	-- /100, probability of using a skill
		level = 99,
		hp = 4444,
		sp = 4444,
		strength = 85,
		magic = 85,
		endurance = 66,
		luck = 66,
		agility = 66,
		melee_natk = "strike_1",	-- enemies don't have crit anims for their attacks.
		thinker = generalEnemyThinker,
		boss = true,
		endboss = true,
		bopvp = true,
		turns = 2,
		scale = FRACUNIT*3/2,

		r_exp = 75000,
		anim_stand = 		{SPR_REAP, A, B, C, D, E, F, G, H, I, J, 4},
		anim_stand_hurt = 	{SPR_REAP, A, B, C, D, E, F, G, H, I, J, 4},
		anim_move =			{SPR_REAP, A, B, C, D, E, F, G, H, I, J, 4},
		anim_run =			{SPR_REAP, A, B, C, D, E, F, G, H, I, J, 4},
		anim_hurt =			{SPR_REAP, A, 10},
		anim_getdown =		{SPR_REAP, A, 1},
		anim_downloop =		{SPR_REAP, A, 1},
		anim_getup =		{SPR_REAP, A, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {	"megidola", "megidolaon", "power charge", "mind charge",
					"megaton raid", "vicious strike", "marakunda", "heat riser",
					"marakunda", "masukunda", "matarunda", "maragidyne", "mabufudyne",
					"magarudyne", "maziodyne", "mafreidyne", "mapsiodyne", "tetrakarn", "makarakarn",
					"dekaja", "dekunda"},
	},

	------------------
	-- MONAD DEPTHS --
	------------------
	-- (Absolute Bullshit)

	["drive_boss_monad"] = {
		name = "Re: Rampage Drive",
		skillchance = 100,	-- /100, probability of using a skill
		level = 94,
		hp = 4617,
		sp = 3852,
		atk = 450,
		strength = 80,
		magic = 80,
		endurance = 71,
		luck = 55,
		agility = 60,
		melee_natk = "strike_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_WIND,
		repel = ATK_ELEC,
		block = ATK_BLESS|ATK_CURSE,
		scale = FRACUNIT*2,
		thinker = generalEnemyThinker,
		boss = true,
		r_exp = 50350,
		r_macca = 5000,
		turns = 2,

		r_drops = {
			{{"series", "freifi"}, 50},
			{{"series", "freifi"}, 50},
			{{"series", "buhn"}, 10},
			{"vessel 2", 100},
			{"vessel 2", 100},
			{"vessel 2", 100},
			{"vessel 2", 100},
			{"soul 2", 100},
			{"soul 2", 100},
			{"soul 2", 100},
			{"soul 2", 100},
			{"ruby", 100},
			{"ruby", 100},
			{"ruby", 100},
			{"ruby", 100},
			{"ruby", 80},
			{"ruby", 80},
			{"painite", 70},
			{"painite", 50},
		},

		anim_stand = 		{SPR_ENM1, G, 10},
		anim_stand_hurt =	{SPR_ENM1, G, 1},
		anim_move =			{SPR_ENM1, G, 2},
		anim_run =			{SPR_ENM1, G, 2},
		anim_hurt =			{SPR_ENM1, G, 35},
		anim_getdown =		{SPR_ENM1, G, 1},
		anim_downloop =		{SPR_ENM1, G, 1},
		anim_getup =		{SPR_ENM1, G, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"makakaja", "marakunda", "mind charge", "power charge", "megaton raid", "maziodyne", "elec boost"},
	},

	["table_boss_monad"] = {
		name = "Re: Sleeping Table",
		skillchance = 100,	-- /100, probability of using a skill
		level = 96,
		hp = 4521,
		sp = 4000,
		strength = 80,
		magic = 87,
		endurance = 72,
		luck = 60,
		agility = 70,
		melee_natk = "strike_1",
		resist = ATK_FIRE|ATK_STRIKE,
		thinker = generalEnemyThinker,

		boss = true,
		--endboss = true,
		turns = 2,
		scale = FRACUNIT*5/2,

		r_drops = {
			{{"series", "freifi"}, 50},
			{{"series", "freifi"}, 50},
			{{"series", "buhn"}, 10},
			{"vessel 2", 100},
			{"vessel 2", 100},
			{"vessel 2", 100},
			{"vessel 2", 100},
			{"soul 2", 100},
			{"soul 2", 100},
			{"soul 2", 100},
			{"soul 2", 100},
			{"ruby", 100},
			{"ruby", 100},
			{"ruby", 100},
			{"ruby", 100},
			{"ruby", 80},
			{"ruby", 80},
			{"painite", 70},
			{"painite", 50},
		},

		r_exp = 49200,
		r_macca = 7000,
		anim_stand = 		{SPR_ENM2, S, 10},
		anim_stand_hurt =	{SPR_ENM2, S, 1},
		anim_move =			{SPR_ENM2, S, 2},
		anim_run =			{SPR_ENM2, S, 2},
		anim_hurt =			{SPR_ENM2, S, 35},
		anim_getdown =		{SPR_ENM2, S, 1},
		anim_downloop =		{SPR_ENM2, S, 1},
		anim_getup =		{SPR_ENM2, S, 1},

		skills = {"maragidyne", "mahamaon", "megidolaon", "evil smile", "ghastly wail", "fire boost", "fire boost", "dekaja", "dekunda"},
	},

	["maya_boss_monad"] = {
		name = "Re: Cowardly Maya",
		skillchance = 100,	-- /100, probability of using a skill
		level = 2,
		atk = 450,
		hp = 5500,
		sp = 8500,
		strength = 82,
		magic = 99,
		endurance = 73,
		luck = 50,
		agility = 75,
		melee_natk = "slash_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_WIND|ATK_ELEC|ATK_BLESS|ATK_CURSE|ATK_FIRE|ATK_PSY|ATK_NUCLEAR|ATK_ICE,
		thinker = generalEnemyThinker,
		r_exp = 52500,
		r_macca = 8700,
		turns = 2,
		boss = true,
		r_drops = {
			{{"series", "freifi"}, 90},
			{{"series", "buhn"}, 50},
			{"vessel 2", 100},
			{"vessel 2", 100},
			{"vessel 2", 100},
			{"vessel 2", 100},
			{"soul 2", 100},
			{"soul 2", 100},
			{"soul 2", 100},
			{"soul 2", 100},
			{"ruby", 100},
			{"ruby", 100},
			{"ruby", 100},
			{"ruby", 100},
			{"ruby", 80},
			{"ruby", 80},
			{"painite", 100},
			{"painite", 100},
		},

		anim_stand = 		{SPR_ENM1, D, 10},
		anim_stand_hurt =	{SPR_ENM1, D, 1},
		anim_move =			{SPR_ENM1, D, 2},
		anim_run =			{SPR_ENM1, D, 2},
		anim_hurt =			{SPR_ENM1, D, 35},
		anim_getdown =		{SPR_ENM1, D, 1},
		anim_downloop =		{SPR_ENM1, D, 1},
		anim_getup =		{SPR_ENM1, D, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"buchikamashi", "maragidyne", "mabufudyne", "maziodyne", "magarudyne", "mapsiodyne", "mafreidyne", "makougaon", "maeigaon", "megidolaon", "mind charge", "power charge"},
	},

	["maya_monad"] = {
		name = "Vengeful Maya",
		skillchance = 100,	-- /100, probability of using a skill
		level = 84,
		hp = 603,
		sp = 260,
		strength = 50,
		magic = 72,
		endurance = 47,
		luck = 53,
		agility = 57,
		melee_natk = "slash_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_ICE,
		repel = ATK_FIRE,
		resist = ATK_BLESS|ATK_CURSE,
		thinker = generalEnemyThinker,
		r_exp = 1604,

		anim_stand = 		{SPR_ENM1, D, 10},
		anim_stand_hurt =	{SPR_ENM1, D, 1},
		anim_move =			{SPR_ENM1, D, 2},
		anim_run =			{SPR_ENM1, D, 2},
		anim_hurt =			{SPR_ENM1, D, 35},
		anim_getdown =		{SPR_ENM1, D, 1},
		anim_downloop =		{SPR_ENM1, D, 1},
		anim_getup =		{SPR_ENM1, D, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"agidyne", "fire amp", "fire boost", "hamaon", "foolish whisper", "dekaja"},
	},

	["hablerie_monad"] = {
		name = "Forgotten Hablerie",
		skillchance = 100,	-- /100, probability of using a skill
		level = 85,
		hp = 547,
		sp = 250,
		strength = 40,
		magic = 69,
		endurance = 44,
		luck = 50,
		agility = 50,
		melee_natk = "strike_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_FIRE,
		repel = ATK_ICE,
		resist = ATK_BLESS|ATK_CURSE,
		thinker = generalEnemyThinker,
		r_exp = 1517,

		anim_stand = 		{SPR_ENM5, C, 10},
		anim_stand_hurt =	{SPR_ENM5, C, 1},
		anim_move =			{SPR_ENM5, C, 2},
		anim_run =			{SPR_ENM5, C, 2},
		anim_hurt =			{SPR_ENM5, C, 35},
		anim_getdown =		{SPR_ENM5, C, 1},
		anim_downloop =		{SPR_ENM5, C, 1},
		anim_getup =		{SPR_ENM5, C, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"mediarahan", "bufudyne", "ice amp", "ice boost", "dekaja"},
	},

	["basalt_monad"] = {
		name = "Royal Basalt",
		skillchance = 100,	-- /100, probability of using a skill
		level = 88,
		hp = 480,
		sp = 350,
		strength = 72,
		magic = 40,
		endurance = 45,
		luck = 40,
		agility = 50,
		melee_natk = "strike_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_PSY|ATK_NUCLEAR,
		repel = ATK_CURSE,
		resist = ATK_BLESS,
		thinker = generalEnemyThinker,
		r_exp = 3517,

		anim_stand = 		{SPR_ENM5, I, 10},
		anim_stand_hurt =	{SPR_ENM5, I, 1},
		anim_move =			{SPR_ENM5, I, 2},
		anim_run =			{SPR_ENM5, I, 2},
		anim_hurt =			{SPR_ENM5, I, 35},
		anim_getdown =		{SPR_ENM5, I, 1},
		anim_downloop =		{SPR_ENM5, I, 1},
		anim_getup =		{SPR_ENM5, I, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"god hand", "vicious strike", "matarukaja", "last resort"},
	},

	["machine_monad"] = {
		name = "Gunman Machine",
		skillchance = 100,	-- /100, probability of using a skill
		level = 90,
		hp = 555,
		sp = 350,
		strength = 72,
		magic = 40,
		endurance = 40,
		luck = 40,
		agility = 50,
		melee_natk = "strike_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_PSY|ATK_NUCLEAR,
		resist = ATK_STRIKE,
		repel = ATK_PIERCE,
		thinker = generalEnemyThinker,
		r_exp = 3517,

		anim_stand = 		{SPR_ENM5, M, 10},
		anim_stand_hurt =	{SPR_ENM5, M, 1},
		anim_move =			{SPR_ENM5, M, 2},
		anim_run =			{SPR_ENM5, M, 2},
		anim_hurt =			{SPR_ENM5, M, 35},
		anim_getdown =		{SPR_ENM5, M, 1},
		anim_downloop =		{SPR_ENM5, M, 1},
		anim_getup =		{SPR_ENM5, M, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"revolution", "brave blade", "pralaya"},
	},

	["mother_monad"] = {
		name = "Luxurious Mother",
		skillchance = 100,	-- /100, probability of using a skill
		level = 87,
		hp = 501,
		sp = 200,
		strength = 20,
		magic = 68,
		endurance = 42,
		luck = 40,
		agility = 50,
		melee_natk = "strike_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_BLESS|ATK_CURSE,
		thinker = generalEnemyThinker,
		r_exp = 2517,

		anim_stand = 		{SPR_ENM5, V, 10},
		anim_stand_hurt =	{SPR_ENM5, V, 1},
		anim_move =			{SPR_ENM5, V, 2},
		anim_run =			{SPR_ENM5, V, 2},
		anim_hurt =			{SPR_ENM5, V, 35},
		anim_getdown =		{SPR_ENM5, V, 1},
		anim_downloop =		{SPR_ENM5, V, 1},
		anim_getup =		{SPR_ENM5, V, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"diarahan", "maziodyne", "mabufudyne", "elec boost"},
	},

	["okina_monad"] = {
		name = "Preaching Okina",
		skillchance = 100,	-- /100, probability of using a skill
		level = 87,
		hp = 450,
		sp = 500,
		strength = 20,
		magic = 68,
		endurance = 42,
		luck = 40,
		agility = 50,
		melee_natk = "strike_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_ICE,
		drain = ATK_ELEC|ATK_WIND,
		thinker = generalEnemyThinker,
		r_exp = 2047,

		anim_stand = 		{SPR_ENM5, V, 10},
		anim_stand_hurt =	{SPR_ENM5, V, 1},
		anim_move =			{SPR_ENM5, V, 2},
		anim_run =			{SPR_ENM5, V, 2},
		anim_hurt =			{SPR_ENM5, V, 35},
		anim_getdown =		{SPR_ENM5, V, 1},
		anim_downloop =		{SPR_ENM5, V, 1},
		anim_getup =		{SPR_ENM5, V, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"poison mist", "poison boost", "brave blade"},
	},

	["sand_monad"] = {
		name = "Eternal Sand",
		skillchance = 100,	-- /100, probability of using a skill
		level = 86,
		hp = 553,
		sp = 360,
		strength = 67,
		magic = 50,
		endurance = 49,
		luck = 46,
		agility = 54,
		melee_natk = "slash_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_NUCLEAR,
		repel = ATK_STRIKE,
		resist = ATK_FIRE|ATK_ELEC,
		thinker = generalEnemyThinker,
		r_exp = 2404,

		anim_stand = 		{SPR_ENM4, A, 10},
		anim_stand_hurt =	{SPR_ENM4, A, 1},
		anim_move =			{SPR_ENM4, A, 2},
		anim_run =			{SPR_ENM4, A, 2},
		anim_hurt =			{SPR_ENM4, A, 35},
		anim_getdown =		{SPR_ENM4, A, 1},
		anim_downloop =		{SPR_ENM4, A, 1},
		anim_getup =		{SPR_ENM4, A, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"garudyne", "wind amp", "wind boost", "mapsiodyne", "magarudyne", "brave blade", "dekaja"},
	},

	["turret_monad"] = {
		name = "Diamantine Turret",
		skillchance = 100,	-- /100, probability of using a skill
		level = 88,
		hp = 578,
		sp = 192,
		strength = 50,
		magic = 59,
		endurance = 53,
		luck = 51,
		agility = 51,
		melee_natk = "strike_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_PSY|ATK_BLESS,
		block = ATK_ICE,
		repel = ATK_NUCLEAR,
		thinker = generalEnemyThinker,
		r_exp = 2601,

		anim_stand = 		{SPR_ENM4, B, 10},
		anim_stand_hurt =	{SPR_ENM4, B, 1},
		anim_move =			{SPR_ENM4, B, 2},
		anim_run =			{SPR_ENM4, B, 2},
		anim_hurt =			{SPR_ENM4, B, 35},
		anim_getdown =		{SPR_ENM4, B, 1},
		anim_downloop =		{SPR_ENM4, B, 1},
		anim_getup =		{SPR_ENM4, B, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"mind charge", "megidolaon", "mapsiodyne"},
	},

	["musha_monad"] = {
		name = "Edge Musha",
		skillchance = 100,	-- /100, probability of using a skill
		level = 90,
		hp = 601,
		sp = 292,
		strength = 59,
		magic = 40,
		endurance = 55,
		luck = 47,
		agility = 65,
		melee_natk = "strike_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_FIRE|ATK_WIND,
		block = ATK_PSY,
		repel = ATK_STRIKE|ATK_SLASH|ATK_PIERCE,
		thinker = generalEnemyThinker,
		r_exp = 2721,

		anim_stand = 		{SPR_ENM4, C, 10},
		anim_stand_hurt =	{SPR_ENM4, C, 1},
		anim_move =			{SPR_ENM4, C, 2},
		anim_run =			{SPR_ENM4, C, 2},
		anim_hurt =			{SPR_ENM4, C, 35},
		anim_getdown =		{SPR_ENM4, C, 1},
		anim_downloop =		{SPR_ENM4, C, 1},
		anim_getup =		{SPR_ENM4, C, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"power charge", "deathbound", "brave blade"},
	},

	["tower_monad"] = {
		name = "Ungodly Tower",
		skillchance = 100,	-- /100, probability of using a skill
		level = 88,
		hp = 528,
		sp = 392,
		strength = 40,
		magic = 40,
		endurance = 65,
		luck = 65,
		agility = 45,
		melee_natk = "strike_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_PSY,
		repel = ATK_BLESS|ATK_CURSE,
		thinker = generalEnemyThinker,
		r_exp = 2521,

		anim_stand = 		{SPR_ENM4, D, 10},
		anim_stand_hurt =	{SPR_ENM4, D, 1},
		anim_move =			{SPR_ENM4, D, 2},
		anim_run =			{SPR_ENM4, D, 2},
		anim_hurt =			{SPR_ENM4, D, 35},
		anim_getdown =		{SPR_ENM4, D, 1},
		anim_downloop =		{SPR_ENM4, D, 1},
		anim_getup =		{SPR_ENM4, D, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"virus breath", "sexy dance", "evil smile", "heat riser", "mahamaon", "mamudoon"},
	},

	["giant_monad"] = {
		name = "Cuddly Giant",
		skillchance = 100,	-- /100, probability of using a skill
		level = 86,
		hp = 900,
		sp = 392,
		strength = 71,
		magic = 40,
		endurance = 32,
		luck = 65,
		agility = 55,
		melee_natk = "strike_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_STRIKE|ATK_PIERCE|ATK_SLASH,
		repel = ATK_FIRE|ATK_ICE|ATK_ELEC|ATK_WIND|ATK_PSY|ATK_NUCLEAR,
		thinker = generalEnemyThinker,
		r_exp = 2281,

		noroguerandom = true,	-- Don't randomize affinities with rogue mode

		anim_stand = 		{SPR_ENM4, E, 10},
		anim_stand_hurt =	{SPR_ENM4, E, 1},
		anim_move =			{SPR_ENM4, E, 2},
		anim_run =			{SPR_ENM4, E, 2},
		anim_hurt =			{SPR_ENM4, E, 35},
		anim_getdown =		{SPR_ENM4, E, 1},
		anim_downloop =		{SPR_ENM4, E, 1},
		anim_getup =		{SPR_ENM4, E, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"high counter", "tetrakarn", "megaton raid", "maragidyne", "magarudyne", "maziodyne", "mapsiodyne", "mabufudyne", "mafreidyne"},
	},

	["gigas_monad"] = {
		name = "Revolutionary Gigas",
		skillchance = 100,	-- /100, probability of using a skill
		level = 92,
		hp = 587,
		sp = 392,
		strength = 71,
		magic = 50,
		endurance = 62,
		luck = 61,
		agility = 65,
		melee_natk = "strike_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_FIRE,
		thinker = generalEnemyThinker,
		r_exp = 2281,

		anim_stand = 		{SPR_ENM4, I, 10},
		anim_stand_hurt =	{SPR_ENM4, I, 1},
		anim_move =			{SPR_ENM4, I, 2},
		anim_run =			{SPR_ENM4, I, 2},
		anim_hurt =			{SPR_ENM4, I, 35},
		anim_getdown =		{SPR_ENM4, I, 1},
		anim_downloop =		{SPR_ENM4, I, 1},
		anim_getup =		{SPR_ENM4, I, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"revolution"},
	},

	["mage_monad"] = {
		name = "Clear Mage",
		skillchance = 100,	-- /100, probability of using a skill
		level = 85,
		hp = 478,
		sp = 302,
		strength = 50,
		magic = 50,
		endurance = 50,
		luck = 50,
		agility = 50,
		melee_natk = "slash_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_CURSE,
		block = ATK_BLESS,
		resist = ATK_ICE,
		thinker = generalEnemyThinker,
		r_exp = 1401,

		anim_stand = 		{SPR_ENM1, H, 10},
		anim_stand_hurt =	{SPR_ENM1, H, 1},
		anim_move =			{SPR_ENM1, H, 2},
		anim_run =			{SPR_ENM1, H, 2},
		anim_hurt =			{SPR_ENM1, H, 35},
		anim_getdown =		{SPR_ENM1, H, 1},
		anim_downloop =		{SPR_ENM1, H, 1},
		anim_getup =		{SPR_ENM1, H, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"debilitate", "dekaja", "dekunda", "marin karin"},
	},

	["eagle_monad"] = {
		name = "Saturn Eagle",
		skillchance = 100,	-- /100, probability of using a skill
		level = 91,
		hp = 560,
		sp = 439,
		strength = 66,
		magic = 66,
		endurance = 50,
		luck = 50,
		agility = 48,
		melee_natk = "pierce_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_ELEC|ATK_PIERCE,
		block = ATK_WIND,
		resist = ATK_ICE,
		thinker = generalEnemyThinker,

		r_exp = 1815,
		anim_stand = 		{SPR_ENM3, S, 10},
		anim_stand_hurt =	{SPR_ENM3, S, 1},
		anim_move =			{SPR_ENM3, S, 2},
		anim_run =			{SPR_ENM3, S, 2},
		anim_hurt =			{SPR_ENM3, S, 35},
		anim_getdown =		{SPR_ENM3, S, 1},
		anim_downloop =		{SPR_ENM3, S, 1},
		anim_getup =		{SPR_ENM3, S, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"garudyne", "wind amp", "magarudyne", "mamakakaja", "mediarama", "tentarafoo", "dekaja", "dekunda"},
	},

	["knight_monad"] = {
		name = "Holy Knight",
		skillchance = 100,	-- /100, probability of using a skill
		level = 91,
		hp = 521,
		sp = 471,
		strength = 65,
		magic = 52,
		endurance = 48,
		luck = 40,
		agility = 38,
		melee_natk = "pierce_1",	-- enemies don't have crit anims for their attacks.
		repel = ATK_PIERCE,
		drain = ATK_ICE,
		weak = ATK_FIRE,
		thinker = generalEnemyThinker,
		r_exp = 2111,
		anim_stand = 		{SPR_ENM1, K, 10},
		anim_stand_hurt =	{SPR_ENM1, K, 1},
		anim_move =			{SPR_ENM1, K, 2},
		anim_run =			{SPR_ENM1, K, 2},
		anim_hurt =			{SPR_ENM1, K, 35},
		anim_getdown =		{SPR_ENM1, K, 1},
		anim_downloop =		{SPR_ENM1, K, 1},
		anim_getup =		{SPR_ENM1, K, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"torrent shot", "bufudyne", "ice amp", "matarukaja", "dekaja", "dekunda"},
	},

	------------
	-- ADAMAH --
	------------
	-- You sure SMT's harder than this?
	-- (Bullshit)

	["balance_boss1_adamah"] = {
		name = "World Balance",
		skillchance = 100,	-- /100, probability of using a skill
		level = 85,
		hp = 7000,
		sp = 2000,
		strength = 65,
		magic = 65,
		endurance = 42,
		luck = 35,
		agility = 40,
		melee_natk = "pierce_1",	-- enemies don't have crit anims for their attacks.
		thinker = generalEnemyThinker,

		boss = true,
		endboss = true,
		turns = 2,
		scale = FRACUNIT*3,

		r_drops = {
			{{"series", "awake"}, 100},
			{{"series", "obliance"}, 100},
			{{"series", "freifi"}, 40},
			{{"series", "buhn"}, 5},
			{"emerald", 100},
			{"emerald", 100},
			{"diamond", 100},
			{"diamond", 100},
			{"ruby", 80},
			{"ruby", 80},
			{"ruby", 80},
		},

		r_exp = 50000,
		anim_stand = 		{SPR_ENM3, O, 10},
		anim_stand_hurt =	{SPR_ENM3, O, 1},
		anim_move =			{SPR_ENM3, O, 2},
		anim_run =			{SPR_ENM3, O, 2},
		anim_hurt =			{SPR_ENM3, O, 35},
		anim_getdown =		{SPR_ENM3, O, 1},
		anim_downloop =		{SPR_ENM3, O, 1},
		anim_getup =		{SPR_ENM3, O, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"maragidyne", "mabufudyne", "magarudyne", "maziodyne", "mapsiodyne", "mafreidyne", "megidola", "megidolaon", "fire amp", "wind amp", "ice amp", "elec amp", "psy amp", "nuke amp", "bless amp", "curse amp", "debilitate", "heat riser", "mahamaon", "mamudoon"},
	},

	["knight_boss1_adamah"] = {
		name = "Holy Knight",
		skillchance = 100,	-- /100, probability of using a skill
		level = 75,
		hp = 2021,
		sp = 471,
		strength = 65,
		magic = 57,
		endurance = 45,
		luck = 45,
		agility = 44,
		melee_natk = "pierce_1",	-- enemies don't have crit anims for their attacks.
		repel = ATK_PIERCE,
		drain = ATK_ICE,
		weak = ATK_FIRE,
		thinker = generalEnemyThinker,

		boss = true,
		scale = FRACUNIT*2,

		r_drops = {
			{{"series", "awake"}, 35},
			{{"series", "obliance"}, 35},
			{{"series", "freifi"}, 6},
			{{"series", "buhn"}, 1},
			{"emerald", 100},
			{"emerald", 100},
			{"diamond", 100},
			{"diamond", 100},
			{"ruby", 80},
			{"ruby", 80},
			{"ruby", 80},
		},

		r_exp = 7111,
		anim_stand = 		{SPR_ENM1, K, 10},
		anim_stand_hurt =	{SPR_ENM1, K, 1},
		anim_move =			{SPR_ENM1, K, 2},
		anim_run =			{SPR_ENM1, K, 2},
		anim_hurt =			{SPR_ENM1, K, 35},
		anim_getdown =		{SPR_ENM1, K, 1},
		anim_downloop =		{SPR_ENM1, K, 1},
		anim_getup =		{SPR_ENM1, K, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"torrent shot", "bufudyne", "mabufula", "vile assault", "ice amp", "matarukaja", "dekaja", "dekunda"},
	},

	["sword_boss1_adamah"] = {
		name = "Final Sword",
		skillchance = 100,	-- /100, probability of using a skill
		level = 74,
		hp = 1952,
		sp = 310,
		strength = 54,
		magic = 50,
		endurance = 45,
		luck = 45,
		agility = 40,
		melee_natk = "slash_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_NUCLEAR,
		repel = ATK_PSY|ATK_CURSE,
		resist = ATK_SLASH,
		thinker = generalEnemyThinker,

		boss = true,
		scale = FRACUNIT*3/2,

		r_drops = {
			{{"series", "awake"}, 35},
			{{"series", "obliance"}, 35},
			{{"series", "freifi"}, 6},
			{{"series", "buhn"}, 1},
			{"emerald", 100},
			{"emerald", 100},
			{"diamond", 100},
			{"diamond", 100},
			{"ruby", 80},
			{"ruby", 80},
			{"ruby", 80},
		},

		r_exp = 7111,
		anim_stand = 		{SPR_ENM1, U, 10},
		anim_stand_hurt =	{SPR_ENM1, U, 1},
		anim_move =			{SPR_ENM1, U, 2},
		anim_run =			{SPR_ENM1, U, 2},
		anim_hurt =			{SPR_ENM1, U, 35},
		anim_getdown =		{SPR_ENM1, U, 1},
		anim_downloop =		{SPR_ENM1, U, 1},
		anim_getup =		{SPR_ENM1, U, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"marakukaja", "tempest slash", "gale slash", "mapsio", "psiodyne", "tentarafoo", "matarukaja", "dekaja", "dekunda"},
	},

	["hand_boss1_adamah"] = {
		name = "Killing Hand",
		skillchance = 100,	-- /100, probability of using a skill
		level = 79,
		hp = 5502,
		sp = 780,
		strength = 60,
		magic = 60,
		endurance = 45,
		luck = 44,
		agility = 44,
		melee_natk = "strike_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_ICE,
		drain = ATK_FIRE,
		resist = ATK_STRIKE,
		thinker = generalEnemyThinker,

		boss = true,
		turns = 2,
		scale = FRACUNIT*3/2,

		r_drops = {
			{{"series", "awake"}, 45},
			{{"series", "obliance"}, 45},
			{{"series", "freifi"}, 10},
			{{"series", "buhn"}, 2},
			{"emerald", 100},
			{"emerald", 100},
			{"diamond", 100},
			{"diamond", 100},
			{"ruby", 80},
			{"ruby", 80},
			{"ruby", 80},
		},

		r_exp = 25444,
		anim_stand = 		{SPR_ENM3, U, 10},
		anim_stand_hurt =	{SPR_ENM3, U, 1},
		anim_move =			{SPR_ENM3, U, 2},
		anim_run =			{SPR_ENM3, U, 2},
		anim_hurt =			{SPR_ENM3, U, 35},
		anim_getdown =		{SPR_ENM3, U, 1},
		anim_downloop =		{SPR_ENM3, U, 1},
		anim_getup =		{SPR_ENM3, U, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"agidyne", "maragidyne", "fire amp", "megaton raid", "deathbound", "megidola", "masukunda", "poisma", "dekaja", "dekunda"},
	},

	["eagle_boss1_adamah"] = {
		name = "Saturn Eagle",
		skillchance = 100,	-- /100, probability of using a skill
		level = 72,
		hp = 1712,
		sp = 439,
		strength = 50,
		magic = 50,
		endurance = 42,
		luck = 42,
		agility = 42,
		melee_natk = "pierce_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_ELEC|ATK_PIERCE,
		block = ATK_WIND,
		resist = ATK_ICE,
		thinker = generalEnemyThinker,

		boss = true,
		scale = FRACUNIT*3/2,

		r_drops = {
			{{"series", "awake"}, 35},
			{{"series", "obliance"}, 35},
			{{"series", "freifi"}, 6},
			{{"series", "buhn"}, 1},
			{"emerald", 100},
			{"emerald", 100},
			{"diamond", 100},
			{"diamond", 100},
			{"ruby", 80},
			{"ruby", 80},
			{"ruby", 80},
		},

		r_exp = 8150,
		anim_stand = 		{SPR_ENM3, S, 10},
		anim_stand_hurt =	{SPR_ENM3, S, 1},
		anim_move =			{SPR_ENM3, S, 2},
		anim_run =			{SPR_ENM3, S, 2},
		anim_hurt =			{SPR_ENM3, S, 35},
		anim_getdown =		{SPR_ENM3, S, 1},
		anim_downloop =		{SPR_ENM3, S, 1},
		anim_getup =		{SPR_ENM3, S, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"garudyne", "wind amp", "magarula", "mamakakaja", "media", "tentarafoo", "dekaja", "dekunda"},
	},

	["maya_adamah"] = {
		name = "Doom Maya",
		skillchance = 90,
		level = 66,
		hp = 417,
		sp = 233,
		strength = 49,
		magic = 52,
		endurance = 43,
		agility = 45,
		luck = 43,
		melee_natk = "slash_1",
		block = ATK_ICE|ATK_PSY,
		weak = ATK_ELEC|ATK_BLESS,
		thinker = generalEnemyThinker,

		r_exp = 1002,

		anim_stand = 		{SPR_ENM3, R, 10},
		anim_stand_hurt =	{SPR_ENM3, R, 1},
		anim_move =			{SPR_ENM3, R, 2},
		anim_run =			{SPR_ENM3, R, 2},
		anim_hurt =			{SPR_ENM3, R, 35},
		anim_getdown =		{SPR_ENM3, R, 1},
		anim_downloop =		{SPR_ENM3, R, 1},
		anim_getup =		{SPR_ENM3, R, 1},

		skills = {"bufudyne", "mediarama", "life leech", "mamakanda", "marakunda", "evade slash", "evade pierce", "evade strike"}
	},

	["beetle_adamah"] = {
		name = "Emperor Beetle",
		skillchance = 90,
		level = 68,
		hp = 428,
		sp = 124,
		strength = 57,
		magic = 50,
		endurance = 46,
		agility = 37,
		luck = 34,
		melee_natk = "pierce_1",
		block = ATK_SLASH|ATK_PIERCE|ATK_STRIKE,
		drain = ATK_ELEC,
		weak = ATK_ICE,
		thinker = generalEnemyThinker,

		r_exp = 1327,

		anim_stand = 		{SPR_ENM3, J, 10},
		anim_stand_hurt =	{SPR_ENM3, J, 1},
		anim_move =			{SPR_ENM3, J, 2},
		anim_run =			{SPR_ENM3, J, 2},
		anim_hurt =			{SPR_ENM3, J, 35},
		anim_getdown =		{SPR_ENM3, J, 1},
		anim_downloop =		{SPR_ENM3, J, 1},
		anim_getup =		{SPR_ENM3, J, 1},

		skills = {"ziodyne", "deathbound", "poison mist", "elec amp", "matarukaja"}
	},

	["sand_adamah"] = {
		name = "Eternal Sand",
		skillchance = 100,
		level = 67,
		hp = 429,
		sp = 276,
		strength = 51,
		magic = 58,
		endurance = 42,
		agility = 39,
		luck = 39,
		melee_natk = "slash_1",
		block = ATK_WIND,
		resist = ATK_ICE,
		weak = ATK_FIRE,
		thinker = generalEnemyThinker,

		r_exp = 831,

		anim_stand = 		{SPR_ENM3, L, 10},
		anim_stand_hurt =	{SPR_ENM3, L, 1},
		anim_move =			{SPR_ENM3, L, 2},
		anim_run =			{SPR_ENM3, L, 2},
		anim_hurt =			{SPR_ENM3, L, 35},
		anim_getdown =		{SPR_ENM3, L, 1},
		anim_downloop =		{SPR_ENM3, L, 1},
		anim_getup =		{SPR_ENM3, L, 1},

		skills = {"magarudyne", "megido", "masukukaja", "mamakakaja"}
	},

	["dice_adamah"] = {
		name = "Silver Dice",
		skillchance = 100,
		level = 67,
		hp = 421,
		sp = 128,
		strength = 40,
		magic = 56,
		endurance = 41,
		agility = 41,
		luck = 39,
		melee_natk = "strike_1",
		block = ATK_WIND|ATK_BLESS,
		weak = ATK_CURSE|ATK_NUCLEAR,
		thinker = generalEnemyThinker,

		r_exp = 977,

		anim_stand = 		{SPR_ENM3, K, 10},
		anim_stand_hurt =	{SPR_ENM3, K, 1},
		anim_move =			{SPR_ENM3, K, 2},
		anim_run =			{SPR_ENM3, K, 2},
		anim_hurt =			{SPR_ENM3, K, 35},
		anim_getdown =		{SPR_ENM3, K, 1},
		anim_downloop =		{SPR_ENM3, K, 1},
		anim_getup =		{SPR_ENM3, K, 1},

		skills = {"infuriate", "psiodyne", "psy amp", "last resort", "mind charge"}
	},

	["table_adamah"] = {
		name = "Sleeping Table",
		skillchance = 100,	-- /100, probability of using a skill
		level = 70,
		hp = 436,
		sp = 310,
		strength = 50,
		magic = 56,
		endurance = 42,
		luck = 41,
		agility = 40,
		melee_natk = "strike_1",
		resist = ATK_FIRE|ATK_STRIKE,
		weak = ATK_WIND,
		thinker = generalEnemyThinker,

		r_exp = 1260,
		anim_stand = 		{SPR_ENM2, S, 10},
		anim_stand_hurt =	{SPR_ENM2, S, 1},
		anim_move =			{SPR_ENM2, S, 2},
		anim_run =			{SPR_ENM2, S, 2},
		anim_hurt =			{SPR_ENM2, S, 35},
		anim_getdown =		{SPR_ENM2, S, 1},
		anim_downloop =		{SPR_ENM2, S, 1},
		anim_getup =		{SPR_ENM2, S, 1},

		skills = {"agidyne", "maragion", "hamaon", "fire amp", "megido", "evil touch", "ghastly wail"},
	},

	["giant_adamah"] = {
		name = "Stasis Giant",
		skillchance = 80,	-- /100, probability of using a skill
		level = 67,
		hp = 454,
		sp = 97,
		strength = 50,
		magic = 38,
		endurance = 40,
		luck = 10,
		agility = 39,
		melee_natk = "slash_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_PSY,
		resist = ATK_STRIKE|ATK_FIRE|ATK_WIND|ATK_PIERCE,
		thinker = generalEnemyThinker,

		atk = 400,

		r_exp = 1301,
		anim_stand = 		{SPR_ENM2, G, 10},
		anim_stand_hurt =	{SPR_ENM2, G, 1},
		anim_move =			{SPR_ENM2, G, 2},
		anim_run =			{SPR_ENM2, G, 2},
		anim_hurt =			{SPR_ENM2, G, 35},
		anim_getdown =		{SPR_ENM2, G, 1},
		anim_downloop =		{SPR_ENM2, G, 1},
		anim_getup =		{SPR_ENM2, G, 1},

		skills = {"fatal end", "gigantic fist", "deathbound", "marakukaja", "marakunda", "survival trick"},
	},

	["idol_adamah"] = {
		name = "Praying Idol",
		skillchance = 100,	-- /100, probability of using a skill
		level = 70,
		hp = 426,
		sp = 187,
		strength = 50,
		magic = 56,
		endurance = 42,
		luck = 41,
		agility = 40,
		melee_natk = "strike_1",
		resist = ATK_NUCLEAR|ATK_ICE|ATK_BLESS,
		weak = ATK_PSY|ATK_FIRE,
		thinker = generalEnemyThinker,

		r_exp = 1160,
		anim_stand = 		{SPR_ENM3, H, 10},
		anim_stand_hurt =	{SPR_ENM3, H, 1},
		anim_move =			{SPR_ENM3, H, 2},
		anim_run =			{SPR_ENM3, H, 2},
		anim_hurt =			{SPR_ENM3, H, 35},
		anim_getdown =		{SPR_ENM3, H, 1},
		anim_downloop =		{SPR_ENM3, H, 1},
		anim_getup =		{SPR_ENM3, H, 1},

		skills = {"freidyne", "mafreidyne", "nuke boost", "mamakakaja", "debilitate"},
	},

	["balance_adamah"] = {
		name = "Light Balance",
		skillchance = 100,	-- /100, probability of using a skill
		level = 70,
		hp = 404,
		sp = 213,
		strength = 40,
		magic = 56,
		endurance = 42,
		luck = 40,
		agility = 40,
		melee_natk = "pierce_1",
		repel = ATK_CURSE|ATK_BLESS,
		weak = ATK_NUCLEAR|ATK_PSY,
		thinker = generalEnemyThinker,

		r_exp = 1160,
		anim_stand = 		{SPR_ENM3, N, 10},
		anim_stand_hurt =	{SPR_ENM3, N, 1},
		anim_move =			{SPR_ENM3, N, 2},
		anim_run =			{SPR_ENM3, N, 2},
		anim_hurt =			{SPR_ENM3, N, 35},
		anim_getdown =		{SPR_ENM3, N, 1},
		anim_downloop =		{SPR_ENM3, N, 1},
		anim_getup =		{SPR_ENM3, N, 1},

		skills = {"hamaon", "mudoon", "mahama", "mamudo", "death boost", "expel boost", "maeigaon", "makougaon", "megido"},
	},

	["minotaur_adamah"] = {
		name = "Minotaur II",
		skillchance = 100,	-- /100, probability of using a skill
		level = 78,
		hp = 8888,
		sp = 412,
		strength = 65,
		magic = 65,
		endurance = 1,
		luck = 40,
		agility = 40,
		melee_natk = "strike_1",
		resist = ATK_CURSE|ATK_BLESS,
		weak = ATK_WIND|ATK_ELEC,
		thinker = generalEnemyThinker,

		scale = FRACUNIT*3,

		r_exp = 1960,
		anim_stand = 		{SPR_ENM3, Q, 10},
		anim_stand_hurt =	{SPR_ENM3, Q, 1},
		anim_move =			{SPR_ENM3, Q, 2},
		anim_run =			{SPR_ENM3, Q, 2},
		anim_hurt =			{SPR_ENM3, Q, 35},
		anim_getdown =		{SPR_ENM3, Q, 1},
		anim_downloop =		{SPR_ENM3, Q, 1},
		anim_getup =		{SPR_ENM3, Q, 1},

		skills = {"megaton raid", "deathbound", "triple down", "bufudyne", "mabufula", "ice amp", "matarukaja", "regenerate 2"},
	},

	/*
	["minotaur_adamah_death-edition"] = {
		name = "Minotaur IIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIIII",
		skillchance = 100,	-- /100, probability of using a skill
		boss = true,
		level = 99,
		hp = 6666,
		sp = 500,
		strength = 65,
		magic = 65,
		endurance = 1,
		luck = 40,
		agility = 40,
		melee_natk = "strike_1",
		resist = ATK_CURSE|ATK_BLESS,
		weak = ATK_WIND|ATK_ELEC,
		thinker = generalEnemyThinker,

		scale = 5*FRACUNIT,

		r_exp = 69420,
		anim_stand = 		{SPR_ENM3, Q, 10},
		anim_stand_hurt =	{SPR_ENM3, Q, 1},
		anim_move =			{SPR_ENM3, Q, 2},
		anim_run =			{SPR_ENM3, Q, 2},
		anim_hurt =			{SPR_ENM3, Q, 35},
		anim_getdown =		{SPR_ENM3, Q, 1},
		anim_downloop =		{SPR_ENM3, Q, 1},
		anim_getup =		{SPR_ENM3, Q, 1},

		skills = {"megaton raid", "deathbound", "power charge", "tarukaja", "regenerate 3"},
	},
	*/

	["gigas_adamah"] = {
		name = "Supreme Gigas",
		skillchance = 100,	-- /100, probability of using a skill
		level = 69,
		hp = 419,
		sp = 208,
		strength = 55,
		magic = 48,
		endurance = 45,
		luck = 41,
		agility = 40,
		melee_natk = "strike_1",
		drain = ATK_WIND,
		weak = ATK_NUCLEAR,
		thinker = generalEnemyThinker,

		r_exp = 1160,
		anim_stand = 		{SPR_ENM3, P, 10},
		anim_stand_hurt =	{SPR_ENM3, P, 1},
		anim_move =			{SPR_ENM3, P, 2},
		anim_run =			{SPR_ENM3, P, 2},
		anim_hurt =			{SPR_ENM3, P, 35},
		anim_getdown =		{SPR_ENM3, P, 1},
		anim_downloop =		{SPR_ENM3, P, 1},
		anim_getup =		{SPR_ENM3, P, 1},

		skills = {"garudyne", "magarula", "wind amp", "dekaja", "masukukaja", "masukunda"},
	},

	["castle_adamah"] = {
		name = "Plague Castle",
		skillchance = 100,	-- /100, probability of using a skill
		level = 72,
		hp = 378,
		sp = 68,
		strength = 30,
		magic = 49,
		endurance = 55,
		luck = 30,
		agility = 41,
		melee_natk = "strike_1",
		resist = ATK_FIRE|ATK_WIND|ATK_CURSE|ATK_BLESS,
		weak = ATK_ICE,
		thinker = generalEnemyThinker,

		r_exp = 1026,
		anim_stand = 		{SPR_ENM3, D, 10},
		anim_stand_hurt =	{SPR_ENM3, D, 1},
		anim_move =			{SPR_ENM3, D, 2},
		anim_run =			{SPR_ENM3, D, 2},
		anim_hurt =			{SPR_ENM3, D, 35},
		anim_getdown =		{SPR_ENM3, D, 1},
		anim_downloop =		{SPR_ENM3, D, 1},
		anim_getup =		{SPR_ENM3, D, 1},

		skills = {"virus breath", "last resort", "tetraja", "debilitate"},
	},

	["hand_adamah"] = {
		name = "Pure Hand",
		skillchance = 100,	-- /100, probability of using a skill
		level = 71,
		hp = 419,
		sp = 232,
		strength = 56,
		magic = 54,
		endurance = 45,
		luck = 40,
		agility = 35,
		melee_natk = "strike_1",
		weak = ATK_CURSE|ATK_ELEC,
		thinker = generalEnemyThinker,

		r_exp = 926,
		anim_stand = 		{SPR_ENM3, M, 10},
		anim_stand_hurt =	{SPR_ENM3, M, 1},
		anim_move =			{SPR_ENM3, M, 2},
		anim_run =			{SPR_ENM3, M, 2},
		anim_hurt =			{SPR_ENM3, M, 35},
		anim_getdown =		{SPR_ENM3, M, 1},
		anim_downloop =		{SPR_ENM3, M, 1},
		anim_getup =		{SPR_ENM3, M, 1},

		skills = {"hamaon", "expel boost", "kougaon", "garudyne", "mamakakaja", "survive death"},
	},

	["turret_adamah"] = {
		name = "Berserk Turret",
		skillchance = 100,	-- /100, probability of using a skill
		level = 72,
		scale = FRACUNIT/2,
		hp = 504,
		sp = 90,
		strength = 51,
		magic = 47,
		endurance = 35,
		luck = 40,
		agility = 40,
		melee_natk = "strike_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_FIRE,
		resist = ATK_STRIKE|ATK_SLASH|ATK_PIERCE,
		thinker = generalEnemyThinker,
		r_exp = 1281,

		anim_stand = 		{SPR_ENM1, J, 10},
		anim_stand_hurt =	{SPR_ENM1, J, 1},
		anim_move =			{SPR_ENM1, J, 2},
		anim_run =			{SPR_ENM1, J, 2},
		anim_hurt =			{SPR_ENM1, J, 35},
		anim_getdown =		{SPR_ENM1, J, 1},
		anim_downloop =		{SPR_ENM1, J, 1},
		anim_getup =		{SPR_ENM1, J, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"mind charge", "mabufula", "ice amp", "survival trick"},
	},

	["twins_adamah"] = {
		name = "Glorified Twins",
		skillchance = 100,	-- /100, probability of using a skill
		level = 68,
		hp = 423,
		sp = 16,
		strength = 60,
		magic = 52,
		endurance = 45,
		luck = 40,
		agility = 41,
		melee_natk = "strike_1",
		drain = ATK_CURSE|ATK_BLESS,
		weak = ATK_ICE,
		thinker = generalEnemyThinker,

		r_exp = 1226,
		anim_stand = 		{SPR_ENM3, T, 10},
		anim_stand_hurt =	{SPR_ENM3, T, 1},
		anim_move =			{SPR_ENM3, T, 2},
		anim_run =			{SPR_ENM3, T, 2},
		anim_hurt =			{SPR_ENM3, T, 35},
		anim_getdown =		{SPR_ENM3, T, 1},
		anim_downloop =		{SPR_ENM3, T, 1},
		anim_getup =		{SPR_ENM3, T, 1},

		skills = {"counterstrike", "megaton raid", "power charge", "survival trick"},
	},

	["phantom_adamah"] = {
		name = "Phantom Master",
		skillchance = 100,	-- /100, probability of using a skill
		level = 73,
		hp = 420,
		sp = 239,
		strength = 25,
		magic = 58,
		endurance = 40,
		luck = 40,
		agility = 38,
		melee_natk = "slash_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_PSY,
		block = ATK_CURSE|ATK_BLESS,
		thinker = generalEnemyThinker,

		r_exp = 1217,
		anim_stand = 		{SPR_ENM1, H, 10},
		anim_stand_hurt =	{SPR_ENM1, H, 1},
		anim_move =			{SPR_ENM1, H, 2},
		anim_run =			{SPR_ENM1, H, 2},
		anim_hurt =			{SPR_ENM1, H, 35},
		anim_getdown =		{SPR_ENM1, H, 1},
		anim_downloop =		{SPR_ENM1, H, 1},
		anim_getup =		{SPR_ENM1, H, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"maragidyne", "maziodyne", "eigaon", "fire boost", "elec boost", "mamakakaja", "marakunda", "mind charge"},
	},

	["snake_adamah"] = {
		name = "Stubborn Snake",
		skillchance = 100,
		level = 70,
		hp = 421,
		sp = 250,
		strength = 45,
		magic = 50,
		endurance = 40,
		agility = 29,
		luck = 48,
		melee_natk = "pierce_1",
		weak = ATK_BLESS,
		resist = ATK_FIRE|ATK_WIND|ATK_ELEC|ATK_ICE,
		thinker = generalEnemyThinker,

		r_exp = 872,

		anim_stand = 		{SPR_ENM3, G, 10},
		anim_stand_hurt =	{SPR_ENM3, G, 1},
		anim_move =			{SPR_ENM3, G, 2},
		anim_run =			{SPR_ENM3, G, 2},
		anim_hurt =			{SPR_ENM3, G, 35},
		anim_getdown =		{SPR_ENM3, G, 1},
		anim_downloop =		{SPR_ENM3, G, 1},
		anim_getup =		{SPR_ENM3, G, 1},

		skills = {"torrent shot", "psiodyne", "mudoon", "survive death", "survive expel"}
	},

	["knight_adamah"] = {
		name = "Murderous Knight",
		skillchance = 90,
		level = 72,
		hp = 450,
		sp = 200,
		strength = 37,
		magic = 41,
		endurance = 44,
		agility = 33,
		luck = 34,
		melee_natk = "strike_1",
		weak = ATK_FIRE,
		block = ATK_SLASH|ATK_WIND,
		repel = ATK_STRIKE|ATK_PIERCE,
		thinker = generalEnemyThinker,

		scale = FRACUNIT*133/100,

		r_exp = 1319,
		anim_stand = 		{SPR_ENM2, Y, 10},
		anim_stand_hurt =	{SPR_ENM2, Y, 1},
		anim_move =			{SPR_ENM2, Y, 2},
		anim_run =			{SPR_ENM2, Y, 2},
		anim_hurt =			{SPR_ENM2, Y, 35},
		anim_getdown =		{SPR_ENM2, Y, 1},
		anim_downloop =		{SPR_ENM2, Y, 1},
		anim_getup =		{SPR_ENM2, Y, 1},

		skills = {"torrent shot", "magarudyne", "megaton raid", "matarukaja", "marakunda", "tetrakarn"}
	},

	["idol_adamah"] = {
		name = "Stressed Idol",
		skillchance = 85,
		level = 69, --nice
		hp = 486,
		sp = 200,
		strength = 35,
		magic = 35,
		endurance = 45,
		agility = 35,
		luck = 55,
		melee_natk = "pierce_1",
		weak = ATK_ELEC,
		resist = ATK_CURSE|ATK_BLESS|ATK_PSY,
		thinker = generalEnemyThinker,

		r_exp = 2300,
		anim_stand = 		{SPR_ENM3, H, 10},
		anim_stand_hurt =	{SPR_ENM3, H, 1},
		anim_move =			{SPR_ENM3, H, 2},
		anim_run =			{SPR_ENM3, H, 2},
		anim_hurt =			{SPR_ENM3, H, 35},
		anim_getdown =		{SPR_ENM3, H, 1},
		anim_downloop =		{SPR_ENM3, H, 1},
		anim_getup =		{SPR_ENM3, H, 1},

		skills = {"virus breath", "brain jack", "infuriate", "dormina", "mapsio"}
	},

	["drive_adamah"] = {
		name = "Gunning Drive",
		skillchance = 80,	-- /100, probability of using a skill
		level = 62,
		hp = 498,
		sp = 139,
		strength = 55,
		magic = 30,
		endurance = 43,
		luck = 33,
		agility = 38,
		melee_natk = "pierce_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_FIRE,
		resist = ATK_ICE|ATK_PIERCE,
		atk = 200,

		thinker = generalEnemyThinker,
		r_exp = 1280,

		anim_stand = 		{SPR_ENM1, Y, 10},
		anim_stand_hurt =	{SPR_ENM1, Y, 1},
		anim_move =			{SPR_ENM1, Y, 2},
		anim_run =			{SPR_ENM1, Y, 2},
		anim_hurt =			{SPR_ENM1, Y, 35},
		anim_getdown =		{SPR_ENM1, Y, 1},
		anim_downloop =		{SPR_ENM1, Y, 1},
		anim_getup =		{SPR_ENM1, Y, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"triple down", "torrent shot", "megido", "agidyne", "power charge", "mamakanda"},
	},

	["gene_adamah"] = {
		name = "Next Gene",
		skillchance = 95,	-- /100, probability of using a skill
		level = 68,
		hp = 509,
		sp = 190,
		strength = 50,
		magic = 63,
		endurance = 39,
		luck = 35,
		agility = 34,
		melee_natk = "strike_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_BLESS|ATK_STRIKE,
		resist = ATK_FIRE|ATK_WIND|ATK_CURSE,
		atk = 200,

		thinker = generalEnemyThinker,
		r_exp = 1325,

		anim_stand = 		{SPR_ENM5, P, 10},
		anim_stand_hurt =	{SPR_ENM5, P, 1},
		anim_move =			{SPR_ENM5, P, 2},
		anim_run =			{SPR_ENM5, P, 2},
		anim_hurt =			{SPR_ENM5, P, 35},
		anim_getdown =		{SPR_ENM5, P, 1},
		anim_downloop =		{SPR_ENM5, P, 1},
		anim_getup =		{SPR_ENM5, P, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"masukukaja", "makajamon", "mafreidyne"},
	},

	["pesce_adamah"] = {
		name = "Enlightened Pesce",
		skillchance = 95,	-- /100, probability of using a skill
		level = 65,
		hp = 509,
		sp = 190,
		strength = 60,
		magic = 54,
		endurance = 39,
		luck = 50,
		agility = 34,
		melee_natk = "strike_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_PSY|ATK_FIRE,
		resist = ATK_NUCLEAR|ATK_ICE|ATK_ELEC,
		atk = 200,

		thinker = generalEnemyThinker,
		r_exp = 1325,

		anim_stand = 		{SPR_ENM5, F, 10},
		anim_stand_hurt =	{SPR_ENM5, F, 1},
		anim_move =			{SPR_ENM5, F, 2},
		anim_run =			{SPR_ENM5, F, 2},
		anim_hurt =			{SPR_ENM5, F, 35},
		anim_getdown =		{SPR_ENM5, F, 1},
		anim_downloop =		{SPR_ENM5, F, 1},
		anim_getup =		{SPR_ENM5, F, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"diarahan", "toxic slice", "poison boost", "maziodyne"},
	},

	["nyogo_adamah"] = {
		name = "Odd Nyogo",
		skillchance = 95,	-- /100, probability of using a skill
		level = 70,
		hp = 559,
		sp = 276,
		strength = 62,
		magic = 40,
		endurance = 43,
		luck = 30,
		agility = 39,
		melee_natk = "strike_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_ICE|ATK_ELEC,
		drain = ATK_STRIKE|ATK_PIERCE,
		atk = 200,

		thinker = generalEnemyThinker,
		r_exp = 1610,

		anim_stand = 		{SPR_ENM5, Z, 10},
		anim_stand_hurt =	{SPR_ENM5, Z, 1},
		anim_move =			{SPR_ENM5, Z, 2},
		anim_run =			{SPR_ENM5, Z, 2},
		anim_hurt =			{SPR_ENM5, Z, 35},
		anim_getdown =		{SPR_ENM5, Z, 1},
		anim_downloop =		{SPR_ENM5, Z, 1},
		anim_getup =		{SPR_ENM5, Z, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"vicious strike", "rebellion", "gigantic fist"},
	},

	["panzer_adamah"] = {
		name = "Otherwordly Panzer",
		skillchance = 95,	-- /100, probability of using a skill
		level = 70,
		hp = 559,
		sp = 276,
		strength = 41,
		magic = 67,
		endurance = 45,
		luck = 30,
		agility = 35,
		melee_natk = "strike_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_STRIKE|ATK_SLASH,
		block = ATK_FIRE,
		atk = 200,

		thinker = generalEnemyThinker,
		r_exp = 1692,

		anim_stand = 		{SPR_ENM5, K, 10},
		anim_stand_hurt =	{SPR_ENM5, K, 1},
		anim_move =			{SPR_ENM5, K, 2},
		anim_run =			{SPR_ENM5, K, 2},
		anim_hurt =			{SPR_ENM5, K, 35},
		anim_getdown =		{SPR_ENM5, K, 1},
		anim_downloop =		{SPR_ENM5, K, 1},
		anim_getup =		{SPR_ENM5, K, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"high counter", "maragidyne", "deathbound"},
	},

	-- HARABAH ENEMIES
	["giant_boss1_harabah"] = {
		name = "Stasis Giant",
		skillchance = 80,	-- /100, probability of using a skill
		level = 65,
		hp = 1200,
		sp = 500,
		strength = 43,
		magic = 43,
		endurance = 45,
		luck = 20,
		agility = 35,
		melee_natk = "slash_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_ICE|ATK_NUCLEAR,
		resist = ATK_STRIKE|ATK_FIRE|ATK_WIND|ATK_PIERCE,
		thinker = generalEnemyThinker,

		atk = 300,

		boss = true,
		scale = FRACUNIT*133/100,

		r_drops = {
			{{"series", "v2-dion"}, 35},
			{{"series", "v2-lambda"}, 35},
			{{"series", "agil"}, 5},
			{"emerald", 100},
			{"emerald", 100},
			{"diamond", 100},
			{"diamond", 100},
			{"ruby", 80},
			{"ruby", 80},
			{"ruby", 80},
		},

		r_exp = 2500,
		anim_stand = 		{SPR_ENM2, G, 10},
		anim_stand_hurt =	{SPR_ENM2, G, 1},
		anim_move =			{SPR_ENM2, G, 2},
		anim_run =			{SPR_ENM2, G, 2},
		anim_hurt =			{SPR_ENM2, G, 35},
		anim_getdown =		{SPR_ENM2, G, 1},
		anim_downloop =		{SPR_ENM2, G, 1},
		anim_getup =		{SPR_ENM2, G, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"fatal end", "gigantic fist", "gale slash", "power charge", "diarama", "tempest slash", "dekaja", "dekunda"},
	},

	["phantom_boss1_harabah"] = {
		name = "Phantom Master",
		skillchance = 100,	-- /100, probability of using a skill
		level = 65,
		hp = 3000,
		sp = 500,
		strength = 25,
		magic = 55,
		endurance = 36,
		luck = 35,
		agility = 25,
		melee_natk = "slash_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_PSY,
		block = ATK_CURSE|ATK_BLESS,
		thinker = generalEnemyThinker,

		atk = 300,
		turns = 2,

		boss = true,
		scale = FRACUNIT*3/2,

		r_drops = {
			{{"series", "v2-dion"}, 55},
			{{"series", "v2-lambda"}, 55},
			{{"series", "agil"}, 25},
			{"emerald", 100},
			{"emerald", 100},
			{"diamond", 100},
			{"diamond", 100},
			{"ruby", 90},
			{"ruby", 90},
			{"ruby", 90},
		},

		r_exp = 15500,
		anim_stand = 		{SPR_ENM1, H, 10},
		anim_stand_hurt =	{SPR_ENM1, H, 1},
		anim_move =			{SPR_ENM1, H, 2},
		anim_run =			{SPR_ENM1, H, 2},
		anim_hurt =			{SPR_ENM1, H, 35},
		anim_getdown =		{SPR_ENM1, H, 1},
		anim_downloop =		{SPR_ENM1, H, 1},
		anim_getup =		{SPR_ENM1, H, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"hamaon", "mind charge", "megido", "mamakakaja", "evil smile", "ghastly wail", "dekaja", "dekunda"},
	},

	["sword_boss1_harabah"] = {
		name = "Judgement Sword",
		skillchance = 100,	-- /100, probability of using a skill
		level = 58,
		hp = 950,
		sp = 1300,
		strength = 46,
		magic = 40,
		endurance = 28,
		luck = 32,
		agility = 35,
		melee_natk = "slash_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_CURSE,
		block = ATK_BLESS,
		drain = ATK_ELEC,
		resist = ATK_FIRE|ATK_SLASH|ATK_STRIKE|ATK_PIERCE,
		repel = ATK_NUCLEAR,
		thinker = generalEnemyThinker,

		atk = 300,

		boss = true,
		scale = FRACUNIT*3/2,

		r_drops = {
			{{"series", "v2-dion"}, 35},
			{{"series", "v2-lambda"}, 35},
			{{"series", "agil"}, 5},
			{"emerald", 100},
			{"emerald", 100},
			{"diamond", 100},
			{"diamond", 100},
			{"ruby", 80},
			{"ruby", 80},
			{"ruby", 80},
		},

		r_exp = 2500,
		anim_stand = 		{SPR_ENM1, I, 10},
		anim_stand_hurt =	{SPR_ENM1, I, 1},
		anim_move =			{SPR_ENM1, I, 2},
		anim_run =			{SPR_ENM1, I, 2},
		anim_hurt =			{SPR_ENM1, I, 35},
		anim_getdown =		{SPR_ENM1, I, 1},
		anim_downloop =		{SPR_ENM1, I, 1},
		anim_getup =		{SPR_ENM1, I, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"tempest slash", "ziodyne", "marakunda", "tarukaja", "kill rush", "dekaja", "dekunda"},
	},

	["dancer_boss1_harabah"] = {
		name = "Royal Dancer",
		skillchance = 100,	-- /100, probability of using a skill
		level = 61,
		hp = 1120,
		sp = 500,
		strength = 34,
		magic = 50,
		endurance = 34,
		luck = 30,
		agility = 40,
		melee_natk = "pierce_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_FIRE|ATK_WIND,
		resist = ATK_ELEC|ATK_ICE,
		thinker = generalEnemyThinker,

		r_drops = {
			{{"series", "v2-dion"}, 35},
			{{"series", "v2-lambda"}, 35},
			{{"series", "agil"}, 5},
			{"emerald", 100},
			{"emerald", 100},
			{"diamond", 100},
			{"diamond", 100},
			{"ruby", 80},
			{"ruby", 80},
			{"ruby", 80},
		},

		boss = true,
		scale = FRACUNIT*3/2,

		r_exp = 2500,
		anim_stand = 		{SPR_ENM3, B, 10},
		anim_stand_hurt =	{SPR_ENM3, B, 1},
		anim_move =			{SPR_ENM3, B, 2},
		anim_run =			{SPR_ENM3, B, 2},
		anim_hurt =			{SPR_ENM3, B, 35},
		anim_getdown =		{SPR_ENM3, B, 1},
		anim_downloop =		{SPR_ENM3, B, 1},
		anim_getup =		{SPR_ENM3, B, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"sexy dance", "tentarafoo", "heat wave", "psiodyne", "dekaja", "dekunda"},
	},

	["dice_boss1_harabah"] = {
		name = "Reckoning Dice",
		skillchance = 100,	-- /100, probability of using a skill
		level = 69,
		hp = 3700,
		sp = 500,
		strength = 42,
		magic = 58,
		endurance = 42,
		luck = 42,
		agility = 36,
		melee_natk = "slash_1",	-- enemies don't have crit anims for their attacks.
		resist = ATK_FIRE|ATK_ICE|ATK_WIND|ATK_ELEC|ATK_PSY|ATK_NUCLEAR|ATK_BLESS|ATK_CURSE,
		thinker = generalEnemyThinker,

		r_drops = {
			{{"series", "v2-dion"}, 65},
			{{"series", "v2-lambda"}, 65},
			{{"series", "agil"}, 45},
			{"emerald", 100},
			{"emerald", 100},
			{"diamond", 100},
			{"diamond", 100},
			{"ruby", 80},
			{"ruby", 80},
			{"ruby", 80},
		},

		boss = true,
		endboss = true,
		turns = 2,
		scale = FRACUNIT*2,

		r_exp = 10000,
		anim_stand = 		{SPR_ENM2, U, 10},
		anim_stand_hurt =	{SPR_ENM2, U, 1},
		anim_move =			{SPR_ENM2, U, 2},
		anim_run =			{SPR_ENM2, U, 2},
		anim_hurt =			{SPR_ENM2, U, 35},
		anim_getdown =		{SPR_ENM2, U, 1},
		anim_downloop =		{SPR_ENM2, U, 1},
		anim_getup =		{SPR_ENM2, U, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"megidola", "megidolaon", "maragion", "mabufula", "magarula", "mapsio", "mazionga", "mafreila", "maeiga", "makouga", "tetrakarn", "provoke", "dekaja", "dekunda"},
	},

	["maya_harabah"] = {
		name = "Imprudent Maya",
		skillchance = 90,
		level = 52,
		hp = 338,
		sp = 169,
		strength = 38,
		magic = 38,
		endurance = 38,
		agility = 38,
		luck = 38,
		melee_natk = "slash_1",
		resist = ATK_PSY,
		block = ATK_FIRE,
		weak = ATK_ICE|ATK_ELEC|ATK_NUCLEAR,
		thinker = generalEnemyThinker,

		r_exp = 414,

		anim_stand = 		{SPR_ENM3, E, 10},
		anim_stand_hurt =	{SPR_ENM3, E, 1},
		anim_move =			{SPR_ENM3, E, 2},
		anim_run =			{SPR_ENM3, E, 2},
		anim_hurt =			{SPR_ENM3, E, 35},
		anim_getdown =		{SPR_ENM3, E, 1},
		anim_downloop =		{SPR_ENM3, E, 1},
		anim_getup =		{SPR_ENM3, E, 1},

		skills = {"agilao", "agidyne", "rakunda", "tarunda", "sukunda"}
	},

	["twins_harabah"] = {
		name = "Crazy Twins",
		skillchance = 90,
		level = 54,
		hp = 302,
		sp = 172,
		strength = 38,
		magic = 41,
		endurance = 35,
		agility = 35,
		luck = 33,
		melee_natk = "strike_1",
		repel = ATK_ELEC,
		block = ATK_NUCLEAR|ATK_BLESS,
		weak = ATK_FIRE|ATK_CURSE,
		thinker = generalEnemyThinker,

		r_exp = 1037,

		anim_stand = 		{SPR_ENM3, F, 10},
		anim_stand_hurt =	{SPR_ENM3, F, 1},
		anim_move =			{SPR_ENM3, F, 2},
		anim_run =			{SPR_ENM3, F, 2},
		anim_hurt =			{SPR_ENM3, F, 35},
		anim_getdown =		{SPR_ENM3, F, 1},
		anim_downloop =		{SPR_ENM3, F, 1},
		anim_getup =		{SPR_ENM3, F, 1},

		skills = {"ziodyne", "mazionga", "mind charge", "mahama"}
	},

	["snake_harabah"] = {
		name = "Immoral Snake",
		skillchance = 100,
		level = 49,
		hp = 326,
		sp = 160,
		strength = 43,
		magic = 50,
		endurance = 36,
		agility = 28,
		luck = 37,
		melee_natk = "pierce_1",
		repel = ATK_PSY,
		block = ATK_WIND,
		weak = ATK_PIERCE|ATK_BLESS|ATK_CURSE,
		thinker = generalEnemyThinker,

		r_exp = 872,

		anim_stand = 		{SPR_ENM3, G, 10},
		anim_stand_hurt =	{SPR_ENM3, G, 1},
		anim_move =			{SPR_ENM3, G, 2},
		anim_run =			{SPR_ENM3, G, 2},
		anim_hurt =			{SPR_ENM3, G, 35},
		anim_getdown =		{SPR_ENM3, G, 1},
		anim_downloop =		{SPR_ENM3, G, 1},
		anim_getup =		{SPR_ENM3, G, 1},

		skills = {"tentarafoo", "sexy dance", "marin karin", "mapsio", "poisma", "poison mist", "survive death", "survive expel"}
	},

	["knight_harabah"] = {
		name = "Hell Knight",
		skillchance = 90,
		level = 54,
		hp = 314,
		sp = 145,
		strength = 37,
		magic = 42,
		endurance = 37,
		agility = 33,
		luck = 34,
		melee_natk = "strike_1",
		repel = ATK_ELEC,
		block = ATK_SLASH|ATK_PIERCE,
		weak = ATK_WIND,
		drain = ATK_CURSE,
		thinker = generalEnemyThinker,

		scale = FRACUNIT*133/100,

		r_exp = 1319,
		anim_stand = 		{SPR_ENM2, Y, 10},
		anim_stand_hurt =	{SPR_ENM2, Y, 1},
		anim_move =			{SPR_ENM2, Y, 2},
		anim_run =			{SPR_ENM2, Y, 2},
		anim_hurt =			{SPR_ENM2, Y, 35},
		anim_getdown =		{SPR_ENM2, Y, 1},
		anim_downloop =		{SPR_ENM2, Y, 1},
		anim_getup =		{SPR_ENM2, Y, 1},

		skills = {"ziodyne", "maziodyne", "power charge", "gigantic fist", "infuriate", "rakunda"}
	},

	["idol_harabah"] = {
		name = "Ruinous Idol",
		skillchance = 100,
		level = 52,
		hp = 335,
		sp = 191,
		strength = 45,
		magic = 45,
		endurance = 30,
		agility = 31,
		luck = 34,
		melee_natk = "pierce_1",
		weak = ATK_BLESS|ATK_FIRE,
		block = ATK_PSY|ATK_NUCLEAR,
		repel = ATK_CURSE,
		thinker = generalEnemyThinker,

		atk = 140,

		r_exp = 1127,
		anim_stand = 		{SPR_ENM3, H, 10},
		anim_stand_hurt =	{SPR_ENM3, H, 1},
		anim_move =			{SPR_ENM3, H, 2},
		anim_run =			{SPR_ENM3, H, 2},
		anim_hurt =			{SPR_ENM3, H, 35},
		anim_getdown =		{SPR_ENM3, H, 1},
		anim_downloop =		{SPR_ENM3, H, 1},
		anim_getup =		{SPR_ENM3, H, 1},

		skills = {"mudoon", "mamudo", "eigaon", "makajamon"}
	},

	["drive_harabah"] = {
		name = "Slaughter Drive",
		skillchance = 100,	-- /100, probability of using a skill
		level = 55,
		hp = 328,
		sp = 139,
		strength = 41,
		magic = 45,
		endurance = 37,
		luck = 33,
		agility = 32,
		melee_natk = "slash_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_NUCLEAR|ATK_PSY,
		resist = ATK_FIRE,

		thinker = generalEnemyThinker,
		r_exp = 1280,

		anim_stand = 		{SPR_ENM1, Y, 10},
		anim_stand_hurt =	{SPR_ENM1, Y, 1},
		anim_move =			{SPR_ENM1, Y, 2},
		anim_run =			{SPR_ENM1, Y, 2},
		anim_hurt =			{SPR_ENM1, Y, 35},
		anim_getdown =		{SPR_ENM1, Y, 1},
		anim_downloop =		{SPR_ENM1, Y, 1},
		anim_getup =		{SPR_ENM1, Y, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"agidyne", "hamaon", "maragion"},
	},

	["tower_harabah"] = {
		name = "Tower of Grief",
		skillchance = 100,
		level = 52,
		hp = 302,
		sp = 175,
		strength = 39,
		magic = 41,
		endurance = 30,
		agility = 42,
		luck = 35,
		melee_natk = "pierce_1",
		weak = ATK_ICE|ATK_CURSE,
		block = ATK_PSY|ATK_NUCLEAR,
		drain = ATK_FIRE,
		repel = ATK_BLESS,

		thinker = generalEnemyThinker,

		r_exp = 1400,
		anim_stand = 		{SPR_ENM1, M, 10},
		anim_stand_hurt =	{SPR_ENM1, M, 1},
		anim_move =			{SPR_ENM1, M, 2},
		anim_run =			{SPR_ENM1, M, 2},
		anim_hurt =			{SPR_ENM1, M, 35},
		anim_getdown =		{SPR_ENM1, M, 1},
		anim_downloop =		{SPR_ENM1, M, 1},
		anim_getup =		{SPR_ENM1, M, 1},

		skills = {"torrent shot", "poison arrow", "mediarama", "marakukaja", "marin karin"}
	},

	["table_harabah"] = {
		name = "Angry Table",
		skillchance = 100,
		level = 52,
		hp = 280,
		sp = 175,
		strength = 14,
		magic = 48,
		endurance = 38,
		agility = 34,
		luck = 38,
		melee_natk = "strike_1",
		weak = ATK_SLASH|ATK_FIRE,
		block = ATK_ICE,

		thinker = generalEnemyThinker,

		r_exp = 806,
		anim_stand = 		{SPR_ENM1, Z, 10},
		anim_stand_hurt =	{SPR_ENM1, Z, 1},
		anim_move =			{SPR_ENM1, Z, 2},
		anim_run =			{SPR_ENM1, Z, 2},
		anim_hurt =			{SPR_ENM1, Z, 35},
		anim_getdown =		{SPR_ENM1, Z, 1},
		anim_downloop =		{SPR_ENM1, Z, 1},
		anim_getup =		{SPR_ENM1, Z, 1},

		skills = {"bufudyne", "mabufula", "tentarafoo", "tetrakarn"}
	},

	["dice_harabah"] = {
		name = "Curse Dice",
		skillchance = 100,
		level = 53,
		hp = 342,
		sp = 168,
		strength = 19,
		magic = 37,
		endurance = 32,
		agility = 36,
		luck = 36,
		melee_natk = "strike_1",
		weak = ATK_WIND,
		resist = ATK_SLASH|ATK_STRIKE|ATK_PIERCE,
		repel = ATK_CURSE,
		scale = FRACUNIT*3/2,

		thinker = generalEnemyThinker,

		r_exp = 1400,
		anim_stand = 		{SPR_ENM2, U, 10},
		anim_stand_hurt =	{SPR_ENM2, U, 1},
		anim_move =			{SPR_ENM2, U, 2},
		anim_run =			{SPR_ENM2, U, 2},
		anim_hurt =			{SPR_ENM2, U, 35},
		anim_getdown =		{SPR_ENM2, U, 1},
		anim_downloop =		{SPR_ENM2, U, 1},
		anim_getup =		{SPR_ENM2, U, 1},

		skills = {"mudoon", "infuriate", "torrent shot", "mafreila"}
	},

	["eagle_harabah"] = {
		name = "Pristine Eagle",
		skillchance = 100,
		level = 55,
		hp = 339,
		sp = 169,
		strength = 40,
		magic = 40,
		endurance = 37,
		agility = 35,
		luck = 31,
		melee_natk = "pierce_1",
		weak = ATK_ELEC,
		drain = ATK_WIND|ATK_ICE,

		thinker = generalEnemyThinker,

		r_exp = 1508,
		anim_stand = 		{SPR_ENM2, H, 10},
		anim_stand_hurt =	{SPR_ENM2, H, 1},
		anim_move =			{SPR_ENM2, H, 2},
		anim_run =			{SPR_ENM2, H, 2},
		anim_hurt =			{SPR_ENM2, H, 35},
		anim_getdown =		{SPR_ENM2, H, 1},
		anim_downloop =		{SPR_ENM2, H, 1},
		anim_getup =		{SPR_ENM2, H, 1},

		skills = {"bufudyne", "garudyne", "diarahan"}
	},

	["sword_harabah"] = {
		name = "Judgement Sword",
		skillchance = 100,
		level = 55,
		hp = 339,
		sp = 169,
		strength = 48,
		magic = 40,
		endurance = 38,
		agility = 27,
		luck = 34,
		melee_natk = "slash_1",
		weak = ATK_CURSE,
		drain = ATK_SLASH|ATK_STRIKE|ATK_PIERCE,

		thinker = generalEnemyThinker,

		r_exp = 1508,
		anim_stand = 		{SPR_ENM1, I, 10},
		anim_stand_hurt =	{SPR_ENM1, I, 1},
		anim_move =			{SPR_ENM1, I, 2},
		anim_run =			{SPR_ENM1, I, 2},
		anim_hurt =			{SPR_ENM1, I, 35},
		anim_getdown =		{SPR_ENM1, I, 1},
		anim_downloop =		{SPR_ENM1, I, 1},
		anim_getup =		{SPR_ENM1, I, 1},

		skills = {"ziodyne", "kill rush", "gale slash", "matarukaja", "marakunda"}
	},

	["cyclops_harabah"] = {
		name = "Mad Cyclops",
		skillchance = 100,
		level = 60,
		hp = 580,
		sp = 169,
		strength = 60,
		magic = 53,
		endurance = 50,
		agility = 24,
		luck = 25,
		melee_natk = "slash_1",
		weak = ATK_BLESS,
		block = ATK_ICE,

		scale = FRACUNIT*3/2,

		thinker = generalEnemyThinker,

		r_exp = 2887,
		anim_stand = 		{SPR_ENM3, I, 10},
		anim_stand_hurt =	{SPR_ENM3, I, 1},
		anim_move =			{SPR_ENM3, I, 2},
		anim_run =			{SPR_ENM3, I, 2},
		anim_hurt =			{SPR_ENM3, I, 35},
		anim_getdown =		{SPR_ENM3, I, 1},
		anim_downloop =		{SPR_ENM3, I, 1},
		anim_getup =		{SPR_ENM3, I, 1},

		skills = {"agidyne", "bufudyne", "fire boost", "ice boost"}
	},

	["dancer_harabah"] = {
		name = "Intrepid Dancer",
		skillchance = 100,
		level = 53,
		hp = 319,
		sp = 201,
		strength = 38,
		magic = 50,
		endurance = 41,
		agility = 38,
		luck = 34,
		melee_natk = "pierce_1",
		weak = ATK_PSY,
		block = ATK_WIND,

		thinker = generalEnemyThinker,

		r_exp = 1508,
		anim_stand = 		{SPR_ENM3, B, 10},
		anim_stand_hurt =	{SPR_ENM3, B, 1},
		anim_move =			{SPR_ENM3, B, 2},
		anim_run =			{SPR_ENM3, B, 2},
		anim_hurt =			{SPR_ENM3, B, 35},
		anim_getdown =		{SPR_ENM3, B, 1},
		anim_downloop =		{SPR_ENM3, B, 1},
		anim_getup =		{SPR_ENM3, B, 1},

		skills = {"garudyne", "magarudyne", "marin karin", "tetrakarn"}
	},

	["fuzz_harabah"] = {
		name = "Monomaniac Fuzz",
		skillchance = 100,
		level = 52,
		hp = 334,
		sp = 176,
		strength = 44,
		magic = 30,
		endurance = 42,
		agility = 35,
		luck = 30,
		melee_natk = "pierce_1",
		weak = ATK_ELEC,
		block = ATK_BLESS,

		thinker = generalEnemyThinker,

		r_exp = 1323,
		anim_stand = 		{SPR_ENM5, T, 10},
		anim_stand_hurt =	{SPR_ENM5, T, 1},
		anim_move =			{SPR_ENM5, T, 2},
		anim_run =			{SPR_ENM5, T, 2},
		anim_hurt =			{SPR_ENM5, T, 35},
		anim_getdown =		{SPR_ENM5, T, 1},
		anim_downloop =		{SPR_ENM5, T, 1},
		anim_getup =		{SPR_ENM5, T, 1},

		skills = {"heavy shot", "masukunda"}
	},

	["okina_harabah"] = {
		name = "Wandering Okina",
		skillchance = 100,
		level = 55,
		hp = 337,
		sp = 218,
		strength = 38,
		magic = 50,
		endurance = 41,
		agility = 38,
		luck = 34,
		melee_natk = "pierce_1",
		weak = ATK_ELEC,
		block = ATK_BLESS,

		thinker = generalEnemyThinker,

		r_exp = 1323,
		anim_stand = 		{SPR_ENM5, W, 10},
		anim_stand_hurt =	{SPR_ENM5, W, 1},
		anim_move =			{SPR_ENM5, W, 2},
		anim_run =			{SPR_ENM5, W, 2},
		anim_hurt =			{SPR_ENM5, W, 35},
		anim_getdown =		{SPR_ENM5, W, 1},
		anim_downloop =		{SPR_ENM5, W, 1},
		anim_getup =		{SPR_ENM5, W, 1},

		skills = {"mazionga", "ziodyne", "dormina", "elec boost", "diarahan"}
	},

	["machine_harabah"] = {
		name = "Dominating Machine",
		skillchance = 100,
		level = 64,
		hp = 721,
		sp = 176,
		strength = 60,
		magic = 60,
		endurance = 45,
		agility = 38,
		luck = 34,
		melee_natk = "pierce_1",
		weak = ATK_ELEC,
		block = ATK_BLESS,

		thinker = generalEnemyThinker,

		r_exp = 1323,
		anim_stand = 		{SPR_ENM5, L, 10},
		anim_stand_hurt =	{SPR_ENM5, L, 1},
		anim_move =			{SPR_ENM5, L, 2},
		anim_run =			{SPR_ENM5, L, 2},
		anim_hurt =			{SPR_ENM5, L, 35},
		anim_getdown =		{SPR_ENM5, L, 1},
		anim_downloop =		{SPR_ENM5, L, 1},
		anim_getup =		{SPR_ENM5, L, 1},

		skills = {"fatal end", "gale slash", "revolution"}
	},

	-- TZIAH ENEMIES

	["table_boss1_tziah"] = {
		name = "Sleeping Table",
		skillchance = 100,	-- /100, probability of using a skill
		level = 50,
		hp = 3600,
		sp = 1000,
		strength = 38,
		magic = 38,
		endurance = 32,
		luck = 22,
		agility = 27,
		melee_natk = "strike_1",
		resist = ATK_FIRE|ATK_STRIKE,
		thinker = generalEnemyThinker,

		boss = true,
		endboss = true,
		turns = 2,
		scale = FRACUNIT*5/2,

		r_drops = {
			{{"series", "reaver"}, 85},
			{{"series", "revoluzio"}, 55},
			{"emerald", 100},
			{"emerald", 100},
			{"diamond", 100},
			{"diamond", 100},
			{"ruby", 90},
			{"ruby", 90},
			{"ruby", 90},
		},

		r_exp = 5000,
		anim_stand = 		{SPR_ENM2, S, 10},
		anim_stand_hurt =	{SPR_ENM2, S, 1},
		anim_move =			{SPR_ENM2, S, 2},
		anim_run =			{SPR_ENM2, S, 2},
		anim_hurt =			{SPR_ENM2, S, 35},
		anim_getdown =		{SPR_ENM2, S, 1},
		anim_downloop =		{SPR_ENM2, S, 1},
		anim_getup =		{SPR_ENM2, S, 1},

		skills = {"maragidyne", "hamaon", "megidola", "evil smile", "ghastly wail", "fire boost", "dekaja", "dekunda"},
	},

	["giant_boss1_tziah"] = {
		name = "Oath Giant",
		skillchance = 100,	-- /100, probability of using a skill
		level = 44,
		hp = 1000,
		sp = 1000,
		strength = 32,
		magic = 29,
		endurance = 26,
		luck = 30,
		agility = 25,
		melee_natk = "slash_1",	-- enemies don't have crit anims for their attacks.

		block = ATK_SLASH,
		weak = ATK_FIRE,
		repel = ATK_ICE,
		thinker = generalEnemyThinker,

		boss = true,
		scale = FRACUNIT*133/100,

		r_drops = {
			{{"series", "reaver"}, 35},
			{{"series", "revoluzio"}, 5},
			{"emerald", 100},
			{"emerald", 100},
			{"diamond", 100},
			{"diamond", 100},
			{"ruby", 40},
			{"ruby", 40},
			{"ruby", 40},
		},

		r_exp = 5000,
		anim_stand = 		{SPR_ENM2, Z, 10},
		anim_stand_hurt =	{SPR_ENM2, Z, 1},
		anim_move =			{SPR_ENM2, Z, 2},
		anim_run =			{SPR_ENM2, Z, 2},
		anim_hurt =			{SPR_ENM2, Z, 35},
		anim_getdown =		{SPR_ENM2, Z, 1},
		anim_downloop =		{SPR_ENM2, Z, 1},
		anim_getup =		{SPR_ENM2, Z, 1},

		skills = {"bufudyne", "fatal end", "tarukaja", "rakunda", "pulinpa", "life leech", "dekaja", "dekunda"},
	},

	["dancer_boss1_tziah"] = {
		name = "Intrepid Dancer",
		skillchance = 100,	-- /100, probability of using a skill
		level = 46,
		hp = 1700,
		sp = 1000,
		strength = 34,
		magic = 34,
		endurance = 30,
		luck = 22,
		agility = 25,
		melee_natk = "pierce_1",	-- enemies don't have crit anims for their attacks.
		repel = ATK_WIND,
		weak = ATK_PSY|ATK_ELEC,
		thinker = generalEnemyThinker,

		boss = true,
		turns = 2,
		scale = FRACUNIT*2,

		r_drops = {
			{{"series", "reaver"}, 55},
			{{"series", "revoluzio"}, 35},
			{"emerald", 100},
			{"emerald", 100},
			{"diamond", 100},
			{"diamond", 100},
			{"ruby", 80},
			{"ruby", 80},
			{"ruby", 80},
		},

		r_exp = 5000,
		anim_stand = 		{SPR_ENM3, B, 10},
		anim_stand_hurt =	{SPR_ENM3, B, 1},
		anim_move =			{SPR_ENM3, B, 2},
		anim_run =			{SPR_ENM3, B, 2},
		anim_hurt =			{SPR_ENM3, B, 35},
		anim_getdown =		{SPR_ENM3, B, 1},
		anim_downloop =		{SPR_ENM3, B, 1},
		anim_getup =		{SPR_ENM3, B, 1},

		skills = {"magarudyne", "marin karin", "garudyne", "tetrakarn", "kougaon", "dekaja", "dekunda"},
	},

	["knight_boss1_tziah"] = {
		name = "Hell Knight",
		skillchance = 100,	-- /100, probability of using a skill
		level = 42,
		hp = 650,
		sp = 1000,
		strength = 30,
		magic = 16,
		endurance = 26,
		luck = 22,
		agility = 22,
		melee_natk = "pierce_1",	-- enemies don't have crit anims for their attacks.
		drain = ATK_ELEC,
		resist = ATK_FIRE|ATK_NUCLEAR,
		weak = ATK_ICE|ATK_BLESS,
		thinker = generalEnemyThinker,

		boss = true,
		scale = FRACUNIT*2,

		r_drops = {
			{{"series", "reaver"}, 35},
			{{"series", "revoluzio"}, 5},
			{"emerald", 100},
			{"emerald", 100},
			{"diamond", 100},
			{"diamond", 100},
			{"ruby", 40},
			{"ruby", 40},
			{"ruby", 40},
		},

		r_exp = 1500,
		anim_stand = 		{SPR_ENM2, Y, 10},
		anim_stand_hurt =	{SPR_ENM2, Y, 1},
		anim_move =			{SPR_ENM2, Y, 2},
		anim_run =			{SPR_ENM2, Y, 2},
		anim_hurt =			{SPR_ENM2, Y, 35},
		anim_getdown =		{SPR_ENM2, Y, 1},
		anim_downloop =		{SPR_ENM2, Y, 1},
		anim_getup =		{SPR_ENM2, Y, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"ziodyne", "mudoon", "heat wave", "gigantic fist", "mazionga", "rakukaja", "tetrakarn", "dekaja", "dekunda"},
	},

	["idol_tziah"] = {
		name = "Rattled Idol",
		skillchance = 100,
		level = 40,
		hp = 281,
		sp = 164,
		strength = 8,
		magic = 24,
		endurance = 22,
		agility = 22,
		luck = 22,
		melee_natk = "pierce_1",
		repel = ATK_WIND,
		block = ATK_FIRE,
		weak = ATK_BLESS|ATK_ELEC,
		thinker = generalEnemyThinker,

		r_exp = 310,

		anim_stand = 		{SPR_ENM3, A, 10},
		anim_stand_hurt =	{SPR_ENM3, A, 1},
		anim_move =			{SPR_ENM3, A, 2},
		anim_run =			{SPR_ENM3, A, 2},
		anim_hurt =			{SPR_ENM3, A, 35},
		anim_getdown =		{SPR_ENM3, A, 1},
		anim_downloop =		{SPR_ENM3, A, 1},
		anim_getup =		{SPR_ENM3, A, 1},

		skills = {"evil touch", "garudyne", "ghastly wail", "eiga"}
	},

	["snake_tziah"] = {
		name = "Holy Snake",
		skillchance = 100,
		level = 43,
		hp = 294,
		sp = 187,
		strength = 12,
		magic = 27,
		endurance = 23,
		agility = 20,
		luck = 24,
		melee_natk = "pierce_1",
		drain = ATK_BLESS,
		weak = ATK_CURSE|ATK_FIRE,
		thinker = generalEnemyThinker,

		r_exp = 310,

		anim_stand = 		{SPR_ENM3, C, 10},
		anim_stand_hurt =	{SPR_ENM3, C, 1},
		anim_move =			{SPR_ENM3, C, 2},
		anim_run =			{SPR_ENM3, C, 2},
		anim_hurt =			{SPR_ENM3, C, 35},
		anim_getdown =		{SPR_ENM3, C, 1},
		anim_downloop =		{SPR_ENM3, C, 1},
		anim_getup =		{SPR_ENM3, C, 1},

		skills = {"diarama", "hamaon", "survive death"}
	},

	["twins_tziah"] = {
		name = "Death Twins",
		skillchance = 85,
		level = 34,
		hp = 260,
		sp = 100,
		strength = 24,
		magic = 26,
		endurance = 22,
		agility = 22,
		luck = 20,
		melee_natk = "slash_1",
		weak = ATK_STRIKE|ATK_BLESS,
		drain = ATK_ELEC,
		resist = ATK_CURSE,
		thinker = generalEnemyThinker,

		r_exp = 350,

		anim_stand = 		{SPR_ENM2, R, 10},
		anim_stand_hurt =	{SPR_ENM2, R, 1},
		anim_move =			{SPR_ENM2, R, 2},
		anim_run =			{SPR_ENM2, R, 2},
		anim_hurt =			{SPR_ENM2, R, 35},
		anim_getdown =		{SPR_ENM2, R, 1},
		anim_downloop =		{SPR_ENM2, R, 1},
		anim_getup =		{SPR_ENM2, R, 1},

		skills = {"mind charge", "zionga", "rakunda"}
	},

	["maya_tziah"] = {
		name = "Fateful Maya",
		skillchance = 100,
		level = 36,
		hp = 279,
		sp = 133,
		strength = 30,
		magic = 18,
		endurance = 26,
		agility = 23,
		luck = 16,
		melee_natk = "slash_1",
		weak = ATK_ELEC|ATK_ICE,
		resist = ATK_STRIKE|ATK_SLASH|ATK_PIERCE,
		thinker = generalEnemyThinker,

		r_exp = 285,

		anim_stand = 		{SPR_ENM2, L, 10},
		anim_stand_hurt =	{SPR_ENM2, L, 1},
		anim_move =			{SPR_ENM2, L, 2},
		anim_run =			{SPR_ENM2, L, 2},
		anim_hurt =			{SPR_ENM2, L, 35},
		anim_getdown =		{SPR_ENM2, L, 1},
		anim_downloop =		{SPR_ENM2, L, 1},
		anim_getup =		{SPR_ENM2, L, 1},

		skills = {"assault dive", "kill rush", "tarukaja"}
	},

	["cyclops_tziah"] = {
		name = "Fierce Cyclops",
		skillchance = 100,
		level = 40,
		hp = 322,
		sp = 82,
		strength = 30,
		magic = 27,
		endurance = 27,
		agility = 20,
		luck = 15,
		melee_natk = "strike_1",
		weak = ATK_FIRE|ATK_PSY,
		block = ATK_ICE,
		thinker = generalEnemyThinker,
		scale = FRACUNIT*3/2,

		r_exp = 450,

		anim_stand = 		{SPR_ENM2, P, 10},
		anim_stand_hurt =	{SPR_ENM2, P, 1},
		anim_move =			{SPR_ENM2, P, 2},
		anim_run =			{SPR_ENM2, P, 2},
		anim_hurt =			{SPR_ENM2, P, 35},
		anim_getdown =		{SPR_ENM2, P, 1},
		anim_downloop =		{SPR_ENM2, P, 1},
		anim_getup =		{SPR_ENM2, P, 1},

		skills = {"mabufula", "ice boost", "makakaja"}
	},

	["minotaur_tziah"] = {
		name = "Minotaur I",
		skillchance = 100,
		level = 40,
		hp = 1400,
		sp = 300,
		strength = 35,
		magic = 33,
		endurance = 3,
		agility = 20,
		luck = 14,
		melee_natk = "strike_1",
		weak = ATK_ICE|ATK_NUCLEAR,
		resist = ATK_BLESS|ATK_CURSE|ATK_FIRE,
		thinker = generalEnemyThinker,
		scale = FRACUNIT*2,

		r_exp = 1500,

		anim_stand = 		{SPR_ENM2, O, 10},
		anim_stand_hurt =	{SPR_ENM2, O, 1},
		anim_move =			{SPR_ENM2, O, 2},
		anim_run =			{SPR_ENM2, O, 2},
		anim_hurt =			{SPR_ENM2, O, 35},
		anim_getdown =		{SPR_ENM2, O, 1},
		anim_downloop =		{SPR_ENM2, O, 1},
		anim_getup =		{SPR_ENM2, O, 1},

		skills = {"mapsio", "psiodyne", "regenerate 2"}
	},

	["turret_tziah"] = {
		name = "Hollow Turret",
		skillchance = 100,
		level = 39,
		hp = 280,
		sp = 128,
		strength = 32,
		magic = 32,
		endurance = 26,
		agility = 19,
		luck = 18,
		melee_natk = "strike_1",
		weak = ATK_BLESS|ATK_CURSE,
		resist = ATK_ICE,
		block = ATK_FIRE,
		thinker = generalEnemyThinker,

		r_exp = 560,

		anim_stand = 		{SPR_ENM1, X, 10},
		anim_stand_hurt =	{SPR_ENM1, X, 1},
		anim_move =			{SPR_ENM1, X, 2},
		anim_run =			{SPR_ENM1, X, 2},
		anim_hurt =			{SPR_ENM1, X, 35},
		anim_getdown =		{SPR_ENM1, X, 1},
		anim_downloop =		{SPR_ENM1, X, 1},
		anim_getup =		{SPR_ENM1, X, 1},

		skills = {"agidyne", "kill rush", "mind charge"}
	},

	["drive_tziah"] = {
		name = "Rampage Drive",
		skillchance = 100,
		level = 42,
		hp = 272,
		sp = 146,
		strength = 31,
		magic = 26,
		endurance = 25,
		agility = 21,
		luck = 18,
		melee_natk = "slash_1",
		weak = ATK_PSY,
		repel = ATK_STRIKE|ATK_ELEC,
		resist = ATK_PIERCE|ATK_SLASH|ATK_FIRE,
		thinker = generalEnemyThinker,

		r_exp = 460,

		anim_stand = 		{SPR_ENM1, G, 10},
		anim_stand_hurt =	{SPR_ENM1, G, 1},
		anim_move =			{SPR_ENM1, G, 2},
		anim_run =			{SPR_ENM1, G, 2},
		anim_hurt =			{SPR_ENM1, G, 35},
		anim_getdown =		{SPR_ENM1, G, 1},
		anim_downloop =		{SPR_ENM1, G, 1},
		anim_getup =		{SPR_ENM1, G, 1},

		skills = {"ziodyne", "heat wave", "freidyne", "provoke"}
	},

	["beetle_tziah"] = {
		name = "Gorgeous Beetle",
		skillchance = 75,
		level = 42,
		hp = 200,
		sp = 146,
		strength = 30,
		magic = 25,
		endurance = 48,
		agility = 20,
		luck = 20,
		melee_natk = "pierce_1",
		weak = ATK_FIRE|ATK_ICE,
		drain = ATK_CURSE|ATK_BLESS,
		thinker = generalEnemyThinker,
		r_exp = 380,

		anim_stand = 		{SPR_ENM1, C, 10},
		anim_stand_hurt =	{SPR_ENM1, C, 1},
		anim_move =			{SPR_ENM1, C, 2},
		anim_run =			{SPR_ENM1, C, 2},
		anim_hurt =			{SPR_ENM1, C, 35},
		anim_getdown =		{SPR_ENM1, C, 1},
		anim_downloop =		{SPR_ENM1, C, 1},
		anim_getup =		{SPR_ENM1, C, 1},

		skills = {"marin karin", "eigaon", "kougaon", "life drain"}
	},

	["magus_tziah"] = {
		name = "Magical Magus",
		skillchance = 85,
		level = 41,
		hp = 274,
		sp = 187,
		strength = 20,
		magic = 29,
		endurance = 24,
		agility = 27,
		luck = 24,
		melee_natk = "pierce_1",
		weak = ATK_FIRE,
		drain = ATK_ICE,
		thinker = generalEnemyThinker,
		r_exp = 360,

		anim_stand = 		{SPR_ENM2, W, 10},
		anim_stand_hurt =	{SPR_ENM2, W, 1},
		anim_move =			{SPR_ENM2, W, 2},
		anim_run =			{SPR_ENM2, W, 2},
		anim_hurt =			{SPR_ENM2, W, 35},
		anim_getdown =		{SPR_ENM2, W, 1},
		anim_downloop =		{SPR_ENM2, W, 1},
		anim_getup =		{SPR_ENM2, W, 1},

		skills = {"bufudyne", "mamakakaja", "terror voice"}
	},

	["relic_tziah"] = {
		name = "Unholy Relic",
		skillchance = 100,
		level = 41,
		hp = 223,
		sp = 187,
		strength = 10,
		magic = 27,
		endurance = 25,
		agility = 20,
		luck = 19,
		melee_natk = "pierce_1",
		weak = ATK_PIERCE|ATK_FIRE,
		drain = ATK_ICE|ATK_WIND,
		thinker = generalEnemyThinker,
		r_exp = 260,

		anim_stand = 		{SPR_ENM2, V, 10},
		anim_stand_hurt =	{SPR_ENM2, V, 1},
		anim_move =			{SPR_ENM2, V, 2},
		anim_run =			{SPR_ENM2, V, 2},
		anim_hurt =			{SPR_ENM2, V, 35},
		anim_getdown =		{SPR_ENM2, V, 1},
		anim_downloop =		{SPR_ENM2, V, 1},
		anim_getup =		{SPR_ENM2, V, 1},

		skills = {"garudyne", "media", "mudoon", "tetrakarn"}
	},

	["giant_tziah"] = {
		name = "Chaos Giant",
		skillchance = 100,
		level = 43,
		hp = 340,
		sp = 128,
		strength = 36,
		magic = 10,
		endurance = 29,
		agility = 10,
		luck = 14,
		melee_natk = "slash_1",
		weak = ATK_WIND,
		block = ATK_STRIKE,
		thinker = generalEnemyThinker,
		r_exp = 350,

		anim_stand = 		{SPR_ENM2, G, 10},
		anim_stand_hurt =	{SPR_ENM2, G, 1},
		anim_move =			{SPR_ENM2, G, 2},
		anim_run =			{SPR_ENM2, G, 2},
		anim_hurt =			{SPR_ENM2, G, 35},
		anim_getdown =		{SPR_ENM2, G, 1},
		anim_downloop =		{SPR_ENM2, G, 1},
		anim_getup =		{SPR_ENM2, G, 1},

		skills = {"heat wave", "giant slice", "marakunda", "regenerate 2"}
	},

	["gigas_tziah"] = {
		name = "Gigas of Anger",
		skillchance = 100,	-- /100, probability of using a skill
		level = 40,
		hp = 287,
		sp = 100,
		strength = 32,
		magic = 22,
		endurance = 23,
		luck = 20,
		agility = 20,
		melee_natk = "strike_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_WIND|ATK_PSY,
		resist = ATK_ELEC,
		block = ATK_FIRE,
		thinker = generalEnemyThinker,

		r_exp = 500,
		anim_stand = 		{SPR_ENM2, I, 10},
		anim_stand_hurt =	{SPR_ENM2, I, 1},
		anim_move =			{SPR_ENM2, I, 2},
		anim_run =			{SPR_ENM2, I, 2},
		anim_hurt =			{SPR_ENM2, I, 35},
		anim_getdown =		{SPR_ENM2, I, 1},
		anim_downloop =		{SPR_ENM2, I, 1},
		anim_getup =		{SPR_ENM2, I, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"sukukaja", "assault dive", "double fang", "freila"},
	},

	["beast_tziah"] = {
		name = "Lion of Truths",
		skillchance = 100,	-- /100, probability of using a skill
		level = 43,
		hp = 232,
		sp = 163,
		strength = 20,
		magic = 32,
		endurance = 25,
		luck = 20,
		agility = 20,
		melee_natk = "strike_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_CURSE|ATK_FIRE,
		resist = ATK_ICE|ATK_WIND,
		block = ATK_BLESS,
		thinker = generalEnemyThinker,

		r_exp = 500,
		anim_stand = 		{SPR_ENM2, X, 10},
		anim_stand_hurt =	{SPR_ENM2, X, 1},
		anim_move =			{SPR_ENM2, X, 2},
		anim_run =			{SPR_ENM2, X, 2},
		anim_hurt =			{SPR_ENM2, X, 35},
		anim_getdown =		{SPR_ENM2, X, 1},
		anim_downloop =		{SPR_ENM2, X, 1},
		anim_getup =		{SPR_ENM2, X, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"kougaon", "hamaon", "foolish whisper"},
	},

	["machine_tziah"] = {
		name = "Delicate Machine",
		skillchance = 100,	-- /100, probability of using a skill
		level = 49,
		hp = 445,
		sp = 92,
		strength = 35,
		magic = 27,
		endurance = 25,
		luck = 20,
		agility = 20,
		melee_natk = "strike_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_ELEC,
		resist = ATK_CURSE|ATK_BLESS|ATK_FIRE,
		thinker = generalEnemyThinker,

		r_exp = 812,
		anim_stand = 		{SPR_ENM5, N, 10},
		anim_stand_hurt =	{SPR_ENM5, N, 1},
		anim_move =			{SPR_ENM5, N, 2},
		anim_run =			{SPR_ENM5, N, 2},
		anim_hurt =			{SPR_ENM5, N, 35},
		anim_getdown =		{SPR_ENM5, N, 1},
		anim_downloop =		{SPR_ENM5, N, 1},
		anim_getup =		{SPR_ENM5, N, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"gigantic fist", "maragion", "rebellion"},
	},

	["pesce_tziah"] = {
		name = "Agitated Pesce",
		skillchance = 100,	-- /100, probability of using a skill
		level = 42,
		hp = 211,
		sp = 129,
		strength = 25,
		magic = 30,
		endurance = 24,
		luck = 21,
		agility = 18,
		melee_natk = "strike_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_PSY,
		repel = ATK_ICE,
		thinker = generalEnemyThinker,

		r_exp = 402,
		anim_stand = 		{SPR_ENM5, E, 10},
		anim_stand_hurt =	{SPR_ENM5, E, 1},
		anim_move =			{SPR_ENM5, E, 2},
		anim_run =			{SPR_ENM5, E, 2},
		anim_hurt =			{SPR_ENM5, E, 35},
		anim_getdown =		{SPR_ENM5, E, 1},
		anim_downloop =		{SPR_ENM5, E, 1},
		anim_getup =		{SPR_ENM5, E, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"bufula", "giant slice"},
	},

	["panzer_tziah"] = {
		name = "Reckless Panzer",
		skillchance = 100,	-- /100, probability of using a skill
		level = 45,
		hp = 251,
		sp = 129,
		strength = 30,
		magic = 30,
		endurance = 21,
		luck = 21,
		agility = 18,
		melee_natk = "strike_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_CURSE|ATK_NUCLEAR,
		drain = ATK_FIRE,
		thinker = generalEnemyThinker,

		r_exp = 402,
		anim_stand = 		{SPR_ENM5, J, 10},
		anim_stand_hurt =	{SPR_ENM5, J, 1},
		anim_move =			{SPR_ENM5, J, 2},
		anim_run =			{SPR_ENM5, J, 2},
		anim_hurt =			{SPR_ENM5, J, 35},
		anim_getdown =		{SPR_ENM5, J, 1},
		anim_downloop =		{SPR_ENM5, J, 1},
		anim_getup =		{SPR_ENM5, J, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"mafreila", "makakaja", "last resort"},
	},

	["mother_tziah"] = {
		name = "Caring Mother",
		skillchance = 100,	-- /100, probability of using a skill
		level = 45,
		hp = 208,
		sp = 200,
		strength = 10,
		magic = 33,
		endurance = 23,
		luck = 22,
		agility = 15,
		melee_natk = "strike_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_ICE,
		drain = ATK_ELEC,
		thinker = generalEnemyThinker,

		r_exp = 416,
		anim_stand = 		{SPR_ENM5, U, 10},
		anim_stand_hurt =	{SPR_ENM5, U, 1},
		anim_move =			{SPR_ENM5, U, 2},
		anim_run =			{SPR_ENM5, U, 2},
		anim_hurt =			{SPR_ENM5, U, 35},
		anim_getdown =		{SPR_ENM5, U, 1},
		anim_downloop =		{SPR_ENM5, U, 1},
		anim_getup =		{SPR_ENM5, U, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"mediarama", "mazionga", "zionga", "makarakarn"},
	},

	-- YABBASHAH ENEMIES

	["tower_boss1"] = {
		name = "Dogmatic Tower",
		skillchance = 100,	-- /100, probability of using a skill
		level = 38,
		hp = 2243,
		sp = 1000,
		strength = 30,
		magic = 35,
		endurance = 26,
		luck = 22,
		agility = 22,
		melee_natk = "strike_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_BLESS,
		repel = ATK_STRIKE|ATK_SLASH,
		block = ATK_CURSE,
		thinker = generalEnemyThinker,

		boss = true,
		endboss = true,
		turns = 2,
		scale = FRACUNIT*2,

		r_drops = {
			{{"series", "vitalis"}, 55},
			{{"series", "spirita"}, 55},
			{{"series", "v2-rekla"}, 33},
			{"emerald", 100},
			{"emerald", 100},
			{"emerald", 100},
			{"diamond", 100},
			{"diamond", 100},
			{"diamond", 100},
			{"ruby", 80},
			{"ruby", 80},
			{"ruby", 80},
		},

		r_exp = 1500,
		anim_stand = 		{SPR_ENM1, M, 10},
		anim_stand_hurt =	{SPR_ENM1, M, 1},
		anim_move =			{SPR_ENM1, M, 2},
		anim_run =			{SPR_ENM1, M, 2},
		anim_hurt =			{SPR_ENM1, M, 35},
		anim_getdown =		{SPR_ENM1, M, 1},
		anim_downloop =		{SPR_ENM1, M, 1},
		anim_getup =		{SPR_ENM1, M, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"provoke", "hama", "agidyne", "maragion", "makarakarn", "dekaja", "dekunda"},
	},

	["magus_boss1"] = {
		name = "Magical Magus",
		skillchance = 100,	-- /100, probability of using a skill
		level = 34,
		hp = 500,
		sp = 300,
		strength = 20,
		magic = 26,
		endurance = 24,
		luck = 16,
		agility = 17,
		melee_natk = "slash_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_FIRE,
		resist = ATK_ELEC,
		drain = ATK_ICE,
		thinker = generalEnemyThinker,

		boss = true,
		scale = FRACUNIT*3/2,

		r_drops = {
			{{"series", "vitalis"}, 25},
			{{"series", "spirita"}, 25},
			{{"series", "v2-rekla"}, 7},
			{"emerald", 100},
			{"emerald", 100},
			{"emerald", 50},
			{"ruby", 80},
			{"ruby", 80},
		},

		r_exp = 500,
		anim_stand = 		{SPR_ENM2, N, 10},
		anim_stand_hurt =	{SPR_ENM2, N, 1},
		anim_move =			{SPR_ENM2, N, 2},
		anim_run =			{SPR_ENM2, N, 2},
		anim_hurt =			{SPR_ENM2, N, 35},
		anim_getdown =		{SPR_ENM2, N, 1},
		anim_downloop =		{SPR_ENM2, N, 1},
		anim_getup =		{SPR_ENM2, N, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"mabufu", "bufula", "rakunda", "dekaja", "dekunda"},
	},

	["gigas_boss1"] = {
		name = "Gigas of Anger",
		skillchance = 100,	-- /100, probability of using a skill
		level = 29,
		hp = 550,
		sp = 200,
		strength = 30,
		magic = 22,
		endurance = 22,
		luck = 15,
		agility = 16,
		melee_natk = "strike_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_WIND|ATK_PSY,
		resist = ATK_ELEC,
		block = ATK_FIRE,
		thinker = generalEnemyThinker,

		boss = true,
		scale = FRACUNIT*3/2,

		r_drops = {
			{{"series", "vitalis"}, 25},
			{{"series", "spirita"}, 25},
			{{"series", "v2-rekla"}, 7},
			{"emerald", 100},
			{"emerald", 100},
			{"emerald", 50},
			{"ruby", 80},
			{"ruby", 80},
		},

		r_exp = 500,
		anim_stand = 		{SPR_ENM2, I, 10},
		anim_stand_hurt =	{SPR_ENM2, I, 1},
		anim_move =			{SPR_ENM2, I, 2},
		anim_run =			{SPR_ENM2, I, 2},
		anim_hurt =			{SPR_ENM2, I, 35},
		anim_getdown =		{SPR_ENM2, I, 1},
		anim_downloop =		{SPR_ENM2, I, 1},
		anim_getup =		{SPR_ENM2, I, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"masukukaja", "assault dive", "double fang", "freila", "dekaja", "dekunda"},
	},

	["relic_2"] = {
		name = "Stasis Relic",
		skillchance = 100,	-- /100, probability of using a skill
		level = 28,
		hp = 300,
		sp = 150,
		strength = 20,
		magic = 23,
		endurance = 18,
		luck = 10,
		agility = 14,
		melee_natk = "pierce_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_ELEC,
		repel = ATK_WIND,
		thinker = generalEnemyThinker,
		r_exp = 210,

		anim_stand = 		{SPR_ENM1, L, 10},
		anim_stand_hurt =	{SPR_ENM1, L, 1},
		anim_move =			{SPR_ENM1, L, 2},
		anim_run =			{SPR_ENM1, L, 2},
		anim_hurt =			{SPR_ENM1, L, 35},
		anim_getdown =		{SPR_ENM1, L, 1},
		anim_downloop =		{SPR_ENM1, L, 1},
		anim_getup =		{SPR_ENM1, L, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"masukunda", "magarula", "garula", "snap", "makakaja"},
	},

	["hand_2"] = {
		name = "Almighty Hand",
		skillchance = 90,	-- /100, probability of using a skill
		level = 29,
		hp = 217,
		sp = 134,
		strength = 17,
		magic = 20,
		endurance = 16,
		luck = 8,
		agility = 16,
		melee_natk = "strike_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_CURSE,
		repel = ATK_ICE,
		resist = ATK_BLESS,
		thinker = generalEnemyThinker,
		r_exp = 210,

		anim_stand = 		{SPR_ENM1, B, 10},
		anim_stand_hurt =	{SPR_ENM1, B, 1},
		anim_move =			{SPR_ENM1, B, 2},
		anim_run =			{SPR_ENM1, B, 2},
		anim_hurt =			{SPR_ENM1, B, 35},
		anim_getdown =		{SPR_ENM1, B, 1},
		anim_downloop =		{SPR_ENM1, B, 1},
		anim_getup =		{SPR_ENM1, B, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"mabufula", "bufula", "hama", "masukunda"},
	},

	["hablerie_2"] = {
		name = "Slipping Hablerie",
		skillchance = 90,	-- /100, probability of using a skill
		level = 27,
		hp = 206,
		sp = 109,
		strength = 14,
		magic = 20,
		endurance = 16,
		luck = 12,
		agility = 17,
		melee_natk = "strike_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_BLESS|ATK_ELEC,
		repel = ATK_CURSE,
		thinker = generalEnemyThinker,
		r_exp = 202,

		anim_stand = 		{SPR_ENM5, B, 10},
		anim_stand_hurt =	{SPR_ENM5, B, 1},
		anim_move =			{SPR_ENM5, B, 2},
		anim_run =			{SPR_ENM5, B, 2},
		anim_hurt =			{SPR_ENM5, B, 35},
		anim_getdown =		{SPR_ENM5, B, 1},
		anim_downloop =		{SPR_ENM5, B, 1},
		anim_getup =		{SPR_ENM5, B, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"eiga", "freila", "media"},
	},

	["gene_1"] = {
		name = "Miss Gene",
		skillchance = 90,	-- /100, probability of using a skill
		level = 29,
		hp = 229,
		sp = 300,
		strength = 20,
		magic = 5,
		endurance = 16,
		luck = 15,
		agility = 18,
		melee_natk = "strike_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_ICE|ATK_FIRE,
		block = ATK_SLASH,
		thinker = generalEnemyThinker,
		r_exp = 187,

		anim_stand = 		{SPR_ENM5, O, 10},
		anim_stand_hurt =	{SPR_ENM5, O, 1},
		anim_move =			{SPR_ENM5, O, 2},
		anim_run =			{SPR_ENM5, O, 2},
		anim_hurt =			{SPR_ENM5, O, 35},
		anim_getdown =		{SPR_ENM5, O, 1},
		anim_downloop =		{SPR_ENM5, O, 1},
		anim_getup =		{SPR_ENM5, O, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"mamakakaja"},
	},

	["cupid_2"] = {
		name = "Envious Cupid",
		skillchance = 90,	-- /100, probability of using a skill
		level = 24,
		hp = 195,
		sp = 85,
		strength = 20,
		magic = 5,
		endurance = 15,
		luck = 12,
		agility = 17,
		melee_natk = "pierce_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_CURSE,
		block = ATK_BLESS,
		thinker = generalEnemyThinker,
		r_exp = 201,

		anim_stand = 		{SPR_ENM5, R, 10},
		anim_stand_hurt =	{SPR_ENM5, R, 1},
		anim_move =			{SPR_ENM5, R, 2},
		anim_run =			{SPR_ENM5, R, 2},
		anim_hurt =			{SPR_ENM5, R, 35},
		anim_getdown =		{SPR_ENM5, R, 1},
		anim_downloop =		{SPR_ENM5, R, 1},
		anim_getup =		{SPR_ENM5, R, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"poison arrow", "diarama"},
	},

	["basalt_2"] = {
		name = "Indignated Basalt",
		skillchance = 90,	-- /100, probability of using a skill
		level = 29,
		hp = 251,
		sp = 15,
		strength = 24,
		magic = 1,
		endurance = 17,
		luck = 10,
		agility = 10,
		melee_natk = "strike_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_FIRE,
		block = ATK_STRIKE,
		thinker = generalEnemyThinker,
		r_exp = 251,

		anim_stand = 		{SPR_ENM5, H, 10},
		anim_stand_hurt =	{SPR_ENM5, H, 1},
		anim_move =			{SPR_ENM5, H, 2},
		anim_run =			{SPR_ENM5, H, 2},
		anim_hurt =			{SPR_ENM5, H, 35},
		anim_getdown =		{SPR_ENM5, H, 1},
		anim_downloop =		{SPR_ENM5, H, 1},
		anim_getup =		{SPR_ENM5, H, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"power charge", "lunge"},
	},

	["tiara_2"] = {
		name = "Screaming Tiara",
		skillchance = 90,
		level = 28,
		hp = 146,
		sp = 47,
		strength = 14,
		magic = 20,
		endurance = 17,
		agility = 16,
		luck = 10,
		melee_natk = "slash_1",
		weak = ATK_ICE,
		block = ATK_FIRE|ATK_PSY,
		thinker = generalEnemyThinker,

		anim_stand = 		{SPR_ENM2, J, 10},
		anim_stand_hurt =	{SPR_ENM2, J, 1},
		anim_move =			{SPR_ENM2, J, 2},
		anim_run =			{SPR_ENM2, J, 2},
		anim_hurt =			{SPR_ENM2, J, 35},
		anim_getdown =		{SPR_ENM2, J, 1},
		anim_downloop =		{SPR_ENM2, J, 1},
		anim_getup =		{SPR_ENM2, J, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"psio", "media", "mapsi"},
		r_exp = 210,
	},

	["maya_3"] = {
		name = "Indolent Maya",
		skillchance = 50,	-- /100, probability of using a skill
		level = 25,
		hp = 160,
		sp = 90,
		strength = 8,
		magic = 18,
		endurance = 12,
		luck = 8,
		agility = 12,
		melee_natk = "slash_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_PIERCE|ATK_WIND,
		resist = ATK_ELEC,
		thinker = generalEnemyThinker,
		r_exp = 200,

		anim_stand = 		{SPR_ENM2, L, 10},
		anim_stand_hurt =	{SPR_ENM2, L, 1},
		anim_move =			{SPR_ENM2, L, 2},
		anim_run =			{SPR_ENM2, L, 2},
		anim_hurt =			{SPR_ENM2, L, 35},
		anim_getdown =		{SPR_ENM2, L, 1},
		anim_downloop =		{SPR_ENM2, L, 1},
		anim_getup =		{SPR_ENM2, L, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"mazio", "double fang", "sukunda"},
	},

	["book_2"] = {
		name = "Constructive Book",
		skillchance = 75,
		level = 19,
		hp = 210,
		sp = 120,
		strength = 10,
		magic = 21,
		endurance = 13,
		agility = 12,
		luck = 10,
		melee_natk = "pierce_1",
		weak = ATK_BLESS|ATK_ICE,
		repel = ATK_CURSE,
		resist = ATK_WIND,
		thinker = generalEnemyThinker,

		anim_stand = 		{SPR_ENM2, M, 10},
		anim_stand_hurt =	{SPR_ENM2, M, 1},
		anim_move =			{SPR_ENM2, M, 2},
		anim_run =			{SPR_ENM2, M, 2},
		anim_hurt =			{SPR_ENM2, M, 35},
		anim_getdown =		{SPR_ENM2, M, 1},
		anim_downloop =		{SPR_ENM2, M, 1},
		anim_getup =		{SPR_ENM2, M, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"mudo", "eiga", "maeiha", "pulinpa"},
		r_exp = 240,
	},

	["turret_1"] = {
		name = "Arcane Turret",
		skillchance = 100,	-- /100, probability of using a skill
		level = 28,
		hp = 250,
		sp = 90,
		strength = 30,
		magic = 20,
		endurance = 18,
		luck = 8,
		agility = 14,
		melee_natk = "strike_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_ELEC|ATK_PSY,
		resist = ATK_WIND,
		drain = ATK_FIRE|ATK_NUCLEAR,
		thinker = generalEnemyThinker,
		r_exp = 230,

		anim_stand = 		{SPR_ENM1, J, 10},
		anim_stand_hurt =	{SPR_ENM1, J, 1},
		anim_move =			{SPR_ENM1, J, 2},
		anim_run =			{SPR_ENM1, J, 2},
		anim_hurt =			{SPR_ENM1, J, 35},
		anim_getdown =		{SPR_ENM1, J, 1},
		anim_downloop =		{SPR_ENM1, J, 1},
		anim_getup =		{SPR_ENM1, J, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"agilao", "freila", "marakunda", "poison arrow"},
	},

	["sword_2"] = {
		name = "Righteous Sword",
		skillchance = 80,
		level = 27,
		hp = 208,
		sp = 76,
		strength = 22,
		magic = 8,
		endurance = 17,
		agility = 14,
		luck = 10,
		melee_natk = "slash_1",
		weak = ATK_WIND|ATK_CURSE,
		repel = ATK_SLASH,
		block = ATK_STRIKE,
		resist = ATK_BLESS|ATK_FIRE,
		thinker = generalEnemyThinker,

		anim_stand = 		{SPR_ENM1, V, 10},
		anim_stand_hurt =	{SPR_ENM1, V, 1},
		anim_move =			{SPR_ENM1, V, 2},
		anim_run =			{SPR_ENM1, V, 2},
		anim_hurt =			{SPR_ENM1, V, 35},
		anim_getdown =		{SPR_ENM1, V, 1},
		anim_downloop =		{SPR_ENM1, V, 1},
		anim_getup =		{SPR_ENM1, V, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"matarukaja", "giant slice", "hama"},
		r_exp = 240,
	},

	["mage_3"] = {
		name = "Wounded Mage",
		skillchance = 80,
		level = 28,
		hp = 191,
		sp = 107,
		strength = 14,
		magic = 21,
		endurance = 14,
		agility = 17,
		luck = 14,
		melee_natk = "slash_1",
		drain = ATK_WIND|ATK_CURSE,
		weak = ATK_ICE|ATK_NUCLEAR,
		thinker = generalEnemyThinker,

		anim_stand = 		{SPR_ENM1, T, 10},
		anim_stand_hurt =	{SPR_ENM1, T, 1},
		anim_move =			{SPR_ENM1, T, 2},
		anim_run =			{SPR_ENM1, T, 2},
		anim_hurt =			{SPR_ENM1, T, 35},
		anim_getdown =		{SPR_ENM1, T, 1},
		anim_downloop =		{SPR_ENM1, T, 1},
		anim_getup =		{SPR_ENM1, T, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"media", "garula", "magaru", "foolish whisper"},
		r_exp = 220,
	},

	["knight_1"] = {
		name = "Careless Knight",
		skillchance = 80,
		level = 28,
		hp = 234,
		sp = 80,
		strength = 24,
		magic = 13,
		endurance = 19,
		agility = 15,
		luck = 14,
		melee_natk = "pierce_1",
		block = ATK_SLASH,
		weak = ATK_BLESS|ATK_NUCLEAR,
		resist = ATK_PSY,
		thinker = generalEnemyThinker,
		scale = FRACUNIT*2,

		anim_stand = 		{SPR_ENM1, K, 10},
		anim_stand_hurt =	{SPR_ENM1, K, 1},
		anim_move =			{SPR_ENM1, K, 2},
		anim_run =			{SPR_ENM1, K, 2},
		anim_hurt =			{SPR_ENM1, K, 35},
		anim_getdown =		{SPR_ENM1, K, 1},
		anim_downloop =		{SPR_ENM1, K, 1},
		anim_getup =		{SPR_ENM1, K, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"provoke", "tarukaja", "mapsi", "giant slice"},
		r_exp = 260,
	},

	["beetle_2"] = {
		name = "Golden Beetle",
		skillchance = 100,	-- /100, probability of using a skill
		level = 27,
		hp = 220,
		sp = 67,
		strength = 21,
		magic = 17,
		endurance = 16,
		luck = 12,
		agility = 15,
		melee_natk = "pierce_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_ELEC,
		resist = ATK_STRIKE|ATK_PIERCE,
		thinker = generalEnemyThinker,
		r_exp = 240,

		anim_stand = 		{SPR_ENM1, R, 10},
		anim_stand_hurt =	{SPR_ENM1, R, 1},
		anim_move =			{SPR_ENM1, R, 2},
		anim_run =			{SPR_ENM1, R, 2},
		anim_hurt =			{SPR_ENM1, R, 35},
		anim_getdown =		{SPR_ENM1, R, 1},
		anim_downloop =		{SPR_ENM1, R, 1},
		anim_getup =		{SPR_ENM1, R, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"masukunda", "sukukaja", "giant slice", "snap", "tarukaja"},
	},

	["drive_1"] = {
		name = "Slaughter Drive",
		skillchance = 100,	-- /100, probability of using a skill
		level = 27,
		hp = 417,
		sp = 67,
		strength = 21,
		magic = 17,
		endurance = 20,
		luck = 15,
		agility = 16,
		melee_natk = "slash_1",	-- enemies don't have crit anims for their attacks.
		resist = ATK_FIRE,
		thinker = generalEnemyThinker,
		r_exp = 650,
		scale = FRACUNIT*3/2,

		anim_stand = 		{SPR_ENM1, Y, 10},
		anim_stand_hurt =	{SPR_ENM1, Y, 1},
		anim_move =			{SPR_ENM1, Y, 2},
		anim_run =			{SPR_ENM1, Y, 2},
		anim_hurt =			{SPR_ENM1, Y, 35},
		anim_getdown =		{SPR_ENM1, Y, 1},
		anim_downloop =		{SPR_ENM1, Y, 1},
		anim_getup =		{SPR_ENM1, Y, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"marakunda", "assault dive", "maragion", "fire boost"},
	},

	-- ARQA ENEMIES

	-- SECTION 1

	["relic_boss1"] = {
		name = "Radioactive Relic",
		skillchance = 100,	-- /100, probability of using a skill
		level = 21,
		hp = 1384,
		sp = 3000,
		strength = 12,
		magic = 15,
		endurance = 10,
		luck = 5,
		agility = 10,
		melee_natk = "pierce_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_ELEC|ATK_PSY,
		repel = ATK_WIND|ATK_NUCLEAR,
		boss = true,
		endboss = true,
		turns = 2,
		thinker = generalEnemyThinker,
		r_exp = 712,
		r_macca = 600,
		scale = FRACUNIT*2,

		r_drops = {
			{{"series", "gliden"}, 100},
			{{"series", "maha"}, 50},
			{{"series", "strania"}, 50},
			{"emerald", 100},
			{"emerald", 100},
			{"emerald", 100},
			{"ruby", 80},
			{"ruby", 80},
		},

		anim_stand = 		{SPR_ENM1, L, 10},
		anim_stand_hurt =	{SPR_ENM1, L, 1},
		anim_move =			{SPR_ENM1, L, 2},
		anim_run =			{SPR_ENM1, L, 2},
		anim_hurt =			{SPR_ENM1, L, 35},
		anim_getdown =		{SPR_ENM1, L, 1},
		anim_downloop =		{SPR_ENM1, L, 1},
		anim_getup =		{SPR_ENM1, L, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"masukunda", "mafrei", "magaru", "feila", "garula", "snap", "makakaja", "dia", "dekaja", "dekunda"},
	},

	["beetle_boss1"] = {
		name = "Golden Beetle",
		skillchance = 100,	-- /100, probability of using a skill
		level = 14,
		hp = 492,
		sp = 300,
		strength = 10,
		magic = 1,
		endurance = 10,
		luck = 4,
		agility = 8,
		melee_natk = "pierce_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_ELEC|ATK_NUCLEAR,
		resist = ATK_STRIKE|ATK_PIERCE,
		boss = true,
		thinker = generalEnemyThinker,
		r_exp = 150,
		r_macca = 150,

		r_drops = {
			{{"series", "gliden"}, 30},
			{{"series", "maha"}, 7},
			{{"series", "strania"}, 7},
			{"emerald", 100},
			{"emerald", 100},
			{"emerald", 50},
			{"ruby", 50},
			{"ruby", 50},
		},

		anim_stand = 		{SPR_ENM1, R, 10},
		anim_stand_hurt =	{SPR_ENM1, R, 1},
		anim_move =			{SPR_ENM1, R, 2},
		anim_run =			{SPR_ENM1, R, 2},
		anim_hurt =			{SPR_ENM1, R, 35},
		anim_getdown =		{SPR_ENM1, R, 1},
		anim_downloop =		{SPR_ENM1, R, 1},
		anim_getup =		{SPR_ENM1, R, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"masukunda", "sukukaja", "giant slice", "snap", "matarukaja", "dekaja", "dekunda"},
	},

	["balance_3"] = {
		name = "Air Balance",
		skillchance = 75,
		level = 17,
		hp = 137,
		sp = 39,
		strength = 6,
		magic = 11,
		endurance = 6,
		agility = 5,
		luck = 4,
		melee_natk = "pierce_1",
		repel = ATK_ELEC|ATK_WIND,
		weak = ATK_FIRE|ATK_ICE,
		thinker = generalEnemyThinker,

		anim_stand = 		{SPR_ENM1, P, 10},
		anim_stand_hurt =	{SPR_ENM1, P, 1},
		anim_move =			{SPR_ENM1, P, 2},
		anim_run =			{SPR_ENM1, P, 2},
		anim_hurt =			{SPR_ENM1, P, 35},
		anim_getdown =		{SPR_ENM1, P, 1},
		anim_downloop =		{SPR_ENM1, P, 1},
		anim_getup =		{SPR_ENM1, P, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"zionga", "garula", "magaru", "mazio", "rakukaja"},
		r_exp = 94,
	},

	["twins_1"] = {
		name = "Alabama Twins",
		skillchance = 75,
		level = 16,
		hp = 129,
		sp = 18,
		strength = 9,
		magic = 9,
		endurance = 7,
		agility = 5,
		luck = 5,
		melee_natk = "pierce_1",
		weak = ATK_BLESS|ATK_ICE,
		block = ATK_CURSE|ATK_FIRE|ATK_NUCLEAR,
		thinker = generalEnemyThinker,

		anim_stand = 		{SPR_ENM2, C, 10},
		anim_stand_hurt =	{SPR_ENM2, C, 1},
		anim_move =			{SPR_ENM2, C, 2},
		anim_run =			{SPR_ENM2, C, 2},
		anim_hurt =			{SPR_ENM2, C, 35},
		anim_getdown =		{SPR_ENM2, C, 1},
		anim_downloop =		{SPR_ENM2, C, 1},
		anim_getup =		{SPR_ENM2, C, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"agilao", "eiga", "freila"},
		r_exp = 91,
	},

	["twins_1_postboss"] = {
		name = "Alabama Twins",
		skillchance = 75,
		level = 18,
		hp = 149,
		sp = 38,
		strength = 11,
		magic = 11,
		endurance = 7,
		agility = 5,
		luck = 6,
		melee_natk = "pierce_1",
		weak = ATK_BLESS|ATK_ICE,
		block = ATK_CURSE|ATK_FIRE|ATK_NUCLEAR,
		thinker = generalEnemyThinker,

		anim_stand = 		{SPR_ENM2, C, 10},
		anim_stand_hurt =	{SPR_ENM2, C, 1},
		anim_move =			{SPR_ENM2, C, 2},
		anim_run =			{SPR_ENM2, C, 2},
		anim_hurt =			{SPR_ENM2, C, 35},
		anim_getdown =		{SPR_ENM2, C, 1},
		anim_downloop =		{SPR_ENM2, C, 1},
		anim_getup =		{SPR_ENM2, C, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"agilao", "eiga", "freila"},
		r_exp = 141,
	},

	["book_1"] = {
		name = "Destructive Book",
		skillchance = 75,
		level = 17,
		hp = 118,
		sp = 70,
		strength = 10,
		magic = 10,
		endurance = 8,
		agility = 5,
		luck = 4,
		melee_natk = "pierce_1",
		weak = ATK_ELEC|ATK_CURSE|ATK_FIRE,
		drain = ATK_ICE,
		thinker = generalEnemyThinker,

		anim_stand = 		{SPR_ENM2, F, 10},
		anim_stand_hurt =	{SPR_ENM2, F, 1},
		anim_move =			{SPR_ENM2, F, 2},
		anim_run =			{SPR_ENM2, F, 2},
		anim_hurt =			{SPR_ENM2, F, 35},
		anim_getdown =		{SPR_ENM2, F, 1},
		anim_downloop =		{SPR_ENM2, F, 1},
		anim_getup =		{SPR_ENM2, F, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"bufula", "psio"},
		r_exp = 86,
	},

	["beast_1"] = {
		name = "Lion of Lies",
		level = 13,
		hp = 108,
		sp = 13,
		strength = 6,
		magic = 2,
		endurance = 5,
		luck = 2,
		agility = 4,
		skillchance = 75,

		melee_natk = "strike_1",
		weak = ATK_PSY|ATK_WIND,
		resist = ATK_FIRE|ATK_PIERCE,

		thinker = generalEnemyThinker,
		r_exp = 65,

		anim_stand = 		{SPR_ENM2, E, 10},
		anim_stand_hurt =	{SPR_ENM2, E, 1},
		anim_move =			{SPR_ENM2, E, 2},
		anim_run =			{SPR_ENM2, E, 2},
		anim_hurt =			{SPR_ENM2, E, 35},
		anim_getdown =		{SPR_ENM2, E, 1},
		anim_downloop =		{SPR_ENM2, E, 1},
		anim_getup =		{SPR_ENM2, E, 1},

		skills = {"cleave"}
	},

	["beast_1_postboss"] = {
		name = "Lion of Lies",
		level = 16,
		hp = 137,
		sp = 13,
		strength = 8,
		magic = 4,
		endurance = 6,
		luck = 3,
		agility = 5,
		skillchance = 75,

		melee_natk = "strike_1",
		weak = ATK_PSY|ATK_WIND,
		resist = ATK_FIRE|ATK_PIERCE,

		thinker = generalEnemyThinker,
		r_exp = 108,

		anim_stand = 		{SPR_ENM2, E, 10},
		anim_stand_hurt =	{SPR_ENM2, E, 1},
		anim_move =			{SPR_ENM2, E, 2},
		anim_run =			{SPR_ENM2, E, 2},
		anim_hurt =			{SPR_ENM2, E, 35},
		anim_getdown =		{SPR_ENM2, E, 1},
		anim_downloop =		{SPR_ENM2, E, 1},
		anim_getup =		{SPR_ENM2, E, 1},

		skills = {"giant slice"}
	},

	["humptihiko"] = {
		name = "Humptihiko",
		skillchance = 100,	-- /100, probability of using a skill
		level = 99,
		hp = 9999,
		sp = 9999,
		strength = 80,
		magic = 80,
		endurance = 30,
		luck = 50,
		agility = 60,
		melee_natk = "strike_1",	-- enemies don't have crit anims for their attacks.
		thinker = generalEnemyThinker,
		boss = true,
		endboss = true,
		turns = 2,
		block = ATK_ELEC,
		weak = ATK_ICE,

		persona = "polydeuces",
		personascale = FRACUNIT*2,

		vfx_skill = {"sfx_huskl", "sfx_huwar1"},
		vfx_hurt = {"sfx_huwar2"},
		vfx_1more = {"sfx_huwar3", "sfx_huwar4"},
		vfx_kill = {"sfx_huwar3", "sfx_huwar4"},
		vfx_miss = {"sfx_huwar5"},
		vfx_die = {"sfx_hudie1"},

		r_exp = 1,
		anim_stand = 		{SPR_HUMP, A, 4},
		anim_stand_hurt = 	{SPR_HUMP, A, 4},
		anim_move =			{SPR_HUMP, A, 4},
		anim_run =			{SPR_HUMP, A, 4},
		anim_hurt =			{SPR_HUMP, B, 10},
		anim_getdown =		{SPR_HUMP, A, 1},
		anim_downloop =		{SPR_HUMP, A, 1},
		anim_getup =		{SPR_HUMP, A, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {
						"megagarula", "eggion", "megidolaon", "tetrakarn", "makarakarn", "dekaja", "dekunda",
						"panty raid", "gigantic fish", "vicious strike", "mind charge", "power charge",
						"heat riser", "debilitate",
						"megagarula", "megagarula", "eggion", "eggion",
						"trisagion",
				},
	},

	["batkan"] = {
		name = "BATKAN!!!",
		skillchance = 100,	-- /100, probability of using a skill
		level = 999,
		hp = 80000,
		sp = 9999,
		strength = 80,
		magic = 80,
		endurance = 1,
		luck = 50,
		agility = 80,
		melee_natk = "strike_1",	-- enemies don't have crit anims for their attacks.
		thinker = generalEnemyThinker,
		scale = FRACUNIT*2,
		boss = true,
		endboss = true,
		turns = 2,
		nopvp = true,

		vfx_skill = {"sfx_batk1"},
		vfx_hurt = {"sfx_batk3"},
		vfx_1more = {"sfx_batk6"},
		vfx_kill = {"sfx_batk6"},
		vfx_die = {"sfx_batk8"},

		thinker = 	function(mo)
						-- KANTHINK!!!!!!!

						local enemies = mo.enemies
						local btl = server.P_BattleStatus[mo.battlen]

						if mo.hp < mo.maxhp*3/4
						and not mo.bean_summon
							mo.bean_summon = true
							if btl.turnorder[2] == mo
								table.remove(btl.turnorder, 2)	-- don't attack again
							end

							return attackDefs["summon bean"], {mo}
						end

						if mo.guaranteedevasion

							if btl.turnorder[2] == mo
								table.remove(btl.turnorder, 2)	-- don't attack again
							end
							return attackDefs["batkan buster"], mo.enemies
						end

						return generalEnemyThinker(mo)
					end,

		r_exp = 1999990,
		anim_stand = 		{SPR_BATK, A, 4},
		anim_stand_hurt = 	{SPR_BATK, A, 4},
		anim_move =			{SPR_BATK, A, 4},
		anim_run =			{SPR_BATK, A, 4},
		anim_hurt =			{SPR_BATK, B, 10},
		anim_getdown =		{SPR_BATK, A, 1},
		anim_downloop =		{SPR_BATK, A, 1},
		anim_getup =		{SPR_BATK, A, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {
						"kannon", "kannon", "fitness", "fitness", "megidolaon", "mind charge", "heat riser", "debilitate", "dekaja", "dekunda",
				},

		--skills = {"summon bean"},
	},

	["batkan_pvp"] = {
		name = "BATKAN!!!",
		skillchance = 100,	-- /100, probability of using a skill
		level = 200,
		hp = 20000,
		sp = 9999,
		strength = 85,
		magic = 85,
		endurance = 1,
		luck = 70,
		agility = 90,
		melee_natk = "strike_1",	-- enemies don't have crit anims for their attacks.
		thinker = generalEnemyThinker,
		scale = FRACUNIT*2,
		boss = true,
		endboss = true,
		turns = 2,

		vfx_skill = {"sfx_batk1"},
		vfx_hurt = {"sfx_batk3"},
		vfx_1more = {"sfx_batk6"},
		vfx_kill = {"sfx_batk6"},
		vfx_die = {"sfx_batk8"},

		r_exp = 1999990,
		anim_stand = 		{SPR_BATK, A, 4},
		anim_stand_hurt = 	{SPR_BATK, A, 4},
		anim_move =			{SPR_BATK, A, 4},
		anim_run =			{SPR_BATK, A, 4},
		anim_hurt =			{SPR_BATK, B, 10},
		anim_getdown =		{SPR_BATK, A, 1},
		anim_downloop =		{SPR_BATK, A, 1},
		anim_getup =		{SPR_BATK, A, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {
						"kannon", "fitness", "megidolaon", "heat riser", "debilitate", "dekaja", "dekunda",
						"trisagion", "niflheim", "panta rhei", "thunder reign",
				},

	},

	["bean"] = {
		name = "Master of Teddehs",
		skillchance = 100,	-- /100, probability of using a skill
		level = 100,
		hp = 18749,
		sp = 9999,
		strength = 75,
		magic = 75,
		endurance = 1,
		luck = 75,
		agility = 75,
		melee_natk = "strike_1",	-- enemies don't have crit anims for their attacks.
		thinker = generalEnemyThinker,
		boss = true,
		endboss = true,
		turns = 1,

		vfx_skill = {"sfx_bean2"},
		vfx_hurt = {"sfx_bean7", "sfx_bean8"},
		vfx_1more = {"sfx_bean5"},
		vfx_kill = {"sfx_bean5"},
		vfx_die = {"sfx_bean1"},

		r_exp = 19999,
		anim_stand = 		{SPR_BATK, C, 4},
		anim_stand_hurt = 	{SPR_BATK, C, 4},
		anim_move =			{SPR_BATK, C, 4},
		anim_run =			{SPR_BATK, C, 4},
		anim_hurt =			{SPR_BATK, D, 10},
		anim_getdown =		{SPR_BATK, C, 1},
		anim_downloop =		{SPR_BATK, C, 1},
		anim_getup =		{SPR_BATK, C, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {
						"trigonometry",
						"trigonometry",
						"teddeh",
						"teddeh",
						"debilitate",
						"heat riser",
						"dekaja",
						"dekunda",
				},
	},

	["mage_2"] = {
		name = "Exorcist Mage",
		level = 11,
		hp = 118,
		sp = 50,
		strength = 2,
		magic = 7,
		endurance = 5,
		luck = 4,
		agility = 5,
		skillchance = 75,

		melee_natk = "slash_1",
		weak = ATK_CURSE|ATK_NUCLEAR|ATK_ICE,
		resist = ATK_WIND,
		block = ATK_BLESS,

		thinker = generalEnemyThinker,
		r_exp = 62,

		anim_stand = 		{SPR_ENM2, A, 10},
		anim_stand_hurt =	{SPR_ENM2, A, 1},
		anim_move =			{SPR_ENM2, A, 2},
		anim_run =			{SPR_ENM2, A, 2},
		anim_hurt =			{SPR_ENM2, A, 35},
		anim_getdown =		{SPR_ENM2, A, 1},
		anim_downloop =		{SPR_ENM2, A, 1},
		anim_getup =		{SPR_ENM2, A, 1},

		skills = {"kouha", "garu", "dia"}
	},

	["mage_2_postboss"] = {
		name = "Exorcist Mage",
		level = 17,
		hp = 148,
		sp = 50,
		strength = 2,
		magic = 9,
		endurance = 6,
		luck = 5,
		agility = 6,
		skillchance = 75,

		melee_natk = "slash_1",
		weak = ATK_CURSE|ATK_NUCLEAR|ATK_ICE,
		resist = ATK_WIND,
		block = ATK_BLESS,

		thinker = generalEnemyThinker,
		r_exp = 62,

		anim_stand = 		{SPR_ENM2, A, 10},
		anim_stand_hurt =	{SPR_ENM2, A, 1},
		anim_move =			{SPR_ENM2, A, 2},
		anim_run =			{SPR_ENM2, A, 2},
		anim_hurt =			{SPR_ENM2, A, 35},
		anim_getdown =		{SPR_ENM2, A, 1},
		anim_downloop =		{SPR_ENM2, A, 1},
		anim_getup =		{SPR_ENM2, A, 1},

		skills = {"kouha", "garula", "dia"}
	},

	["balance_2"] = {
		name = "Thermal Balance",
		skillchance = 75,
		level = 13,
		hp = 122,
		sp = 33,
		strength = 5,
		magic = 5,
		endurance = 4,
		agility = 3,
		luck = 5,
		melee_natk = "pierce_1",
		weak = ATK_ELEC|ATK_WIND,
		drain = ATK_FIRE|ATK_ICE,
		thinker = generalEnemyThinker,

		anim_stand = 		{SPR_ENM1, F, 10},
		anim_stand_hurt =	{SPR_ENM1, F, 1},
		anim_move =			{SPR_ENM1, F, 2},
		anim_run =			{SPR_ENM1, F, 2},
		anim_hurt =			{SPR_ENM1, F, 35},
		anim_getdown =		{SPR_ENM1, F, 1},
		anim_downloop =		{SPR_ENM1, F, 1},
		anim_getup =		{SPR_ENM1, F, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"agi", "bufu", "maragi", "mabufu", "rakunda"},
		r_exp = 81,
	},

	["tiara_1"] = {
		name = "Grieving Tiara",
		skillchance = 75,
		level = 10,
		hp = 112,
		sp = 47,
		strength = 2,
		magic = 6,
		endurance = 5,
		agility = 3,
		luck = 1,
		melee_natk = "slash_1",
		weak = ATK_PSY|ATK_CURSE,
		block = ATK_ELEC,
		thinker = generalEnemyThinker,

		anim_stand = 		{SPR_ENM2, B, 10},
		anim_stand_hurt =	{SPR_ENM2, B, 1},
		anim_move =			{SPR_ENM2, B, 2},
		anim_run =			{SPR_ENM2, B, 2},
		anim_hurt =			{SPR_ENM2, B, 35},
		anim_getdown =		{SPR_ENM2, B, 1},
		anim_downloop =		{SPR_ENM2, B, 1},
		anim_getup =		{SPR_ENM2, B, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"zio", "kouha", "sukunda"},
		r_exp = 64,
	},

	["tiara_1_postboss"] = {
		name = "Grieving Tiara",
		skillchance = 75,
		level = 15,
		hp = 138,
		sp = 47,
		strength = 2,
		magic = 8,
		endurance = 8,
		agility = 5,
		luck = 4,
		melee_natk = "slash_1",
		weak = ATK_PSY|ATK_CURSE,
		block = ATK_ELEC,
		thinker = generalEnemyThinker,

		anim_stand = 		{SPR_ENM2, B, 10},
		anim_stand_hurt =	{SPR_ENM2, B, 1},
		anim_move =			{SPR_ENM2, B, 2},
		anim_run =			{SPR_ENM2, B, 2},
		anim_hurt =			{SPR_ENM2, B, 35},
		anim_getdown =		{SPR_ENM2, B, 1},
		anim_downloop =		{SPR_ENM2, B, 1},
		anim_getup =		{SPR_ENM2, B, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"zionga", "kouga", "sukunda"},
		r_exp = 94,
	},

	["maya_2"] = {
		name = "Depressive Maya",
		skillchance = 75,
		level = 13,
		hp = 108,
		sp = 62,
		strength = 6,
		magic = 6,
		endurance = 4,
		agility = 4,
		luck = 2,
		melee_natk = "slash_1",
		weak = ATK_ICE,
		block = ATK_FIRE,
		thinker = generalEnemyThinker,

		anim_stand = 		{SPR_ENM1, N, 10},
		anim_stand_hurt =	{SPR_ENM1, N, 1},
		anim_move =			{SPR_ENM1, N, 2},
		anim_run =			{SPR_ENM1, N, 2},
		anim_hurt =			{SPR_ENM1, N, 35},
		anim_getdown =		{SPR_ENM1, N, 1},
		anim_downloop =		{SPR_ENM1, N, 1},
		anim_getup =		{SPR_ENM1, N, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"agi", "sukunda"},
		r_exp = 72,
	},

	["maya_2_postboss"] = {
		name = "Depressive Maya",
		skillchance = 75,
		level = 17,
		hp = 131,
		sp = 62,
		strength = 7,
		magic = 8,
		endurance = 5,
		agility = 5,
		luck = 2,
		melee_natk = "slash_1",
		weak = ATK_ICE,
		block = ATK_FIRE,
		thinker = generalEnemyThinker,

		anim_stand = 		{SPR_ENM1, N, 10},
		anim_stand_hurt =	{SPR_ENM1, N, 1},
		anim_move =			{SPR_ENM1, N, 2},
		anim_run =			{SPR_ENM1, N, 2},
		anim_hurt =			{SPR_ENM1, N, 35},
		anim_getdown =		{SPR_ENM1, N, 1},
		anim_downloop =		{SPR_ENM1, N, 1},
		anim_getup =		{SPR_ENM1, N, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"agilao", "sukunda"},
		r_exp = 112,
	},

	["pesce_1"] = {
		name = "Calm Pesce",
		skillchance = 75,
		level = 13,
		hp = 114,
		sp = 57,
		strength = 6,
		magic = 6,
		endurance = 4,
		agility = 3,
		luck = 3,
		melee_natk = "strike_1",
		weak = ATK_ELEC,
		block = ATK_ICE,
		thinker = generalEnemyThinker,

		anim_stand = 		{SPR_ENM5, D, 10},
		anim_stand_hurt =	{SPR_ENM5, D, 1},
		anim_move =			{SPR_ENM5, D, 2},
		anim_run =			{SPR_ENM5, D, 2},
		anim_hurt =			{SPR_ENM5, D, 35},
		anim_getdown =		{SPR_ENM5, D, 1},
		anim_downloop =		{SPR_ENM5, D, 1},
		anim_getup =		{SPR_ENM5, D, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"bufu", "makakaja", "dia"},
		r_exp = 69,
	},

	["pesce_1_postboss"] = {
		name = "Calm Pesce",
		skillchance = 75,
		level = 18,
		hp = 159,
		sp = 57,
		strength = 7,
		magic = 8,
		endurance = 6,
		agility = 5,
		luck = 3,
		melee_natk = "strike_1",
		weak = ATK_ELEC,
		block = ATK_ICE,
		thinker = generalEnemyThinker,

		anim_stand = 		{SPR_ENM5, D, 10},
		anim_stand_hurt =	{SPR_ENM5, D, 1},
		anim_move =			{SPR_ENM5, D, 2},
		anim_run =			{SPR_ENM5, D, 2},
		anim_hurt =			{SPR_ENM5, D, 35},
		anim_getdown =		{SPR_ENM5, D, 1},
		anim_downloop =		{SPR_ENM5, D, 1},
		anim_getup =		{SPR_ENM5, D, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"bufula", "makakaja", "diarama"},
		r_exp = 127,
	},

	["fuzz_1"] = {
		name = "Bribed Fuzz",
		skillchance = 85,
		level = 13,
		hp = 134,
		sp = 34,
		strength = 6,
		magic = 3,
		endurance = 5,
		agility = 2,
		luck = 1,
		melee_natk = "pierce_1",
		weak = ATK_CURSE,
		thinker = generalEnemyThinker,

		anim_stand = 		{SPR_ENM5, S, 10},
		anim_stand_hurt =	{SPR_ENM5, S, 1},
		anim_move =			{SPR_ENM5, S, 2},
		anim_run =			{SPR_ENM5, S, 2},
		anim_hurt =			{SPR_ENM5, S, 35},
		anim_getdown =		{SPR_ENM5, S, 1},
		anim_downloop =		{SPR_ENM5, S, 1},
		anim_getup =		{SPR_ENM5, S, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"single shot"},
		r_exp = 89,
	},

	["fuzz_1_postboss"] = {
		name = "Bribed Fuzz",
		skillchance = 100,
		level = 19,
		hp = 174,
		sp = 55,
		strength = 8,
		magic = 3,
		endurance = 6,
		agility = 4,
		luck = 2,
		melee_natk = "pierce_1",
		weak = ATK_CURSE,
		thinker = generalEnemyThinker,

		anim_stand = 		{SPR_ENM5, S, 10},
		anim_stand_hurt =	{SPR_ENM5, S, 1},
		anim_move =			{SPR_ENM5, S, 2},
		anim_run =			{SPR_ENM5, S, 2},
		anim_hurt =			{SPR_ENM5, S, 35},
		anim_getdown =		{SPR_ENM5, S, 1},
		anim_downloop =		{SPR_ENM5, S, 1},
		anim_getup =		{SPR_ENM5, S, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"single shot"},
		r_exp = 136,
	},

	["basalt_1"] = {
		name = "Selfish Basalt",
		skillchance = 100,
		level = 18,
		hp = 134,
		sp = 34,
		strength = 9,
		magic = 1,
		endurance = 11,
		agility = 1,
		luck = 6,
		melee_natk = "pierce_1",
		weak = ATK_PSY|ATK_NUCLEAR,
		thinker = generalEnemyThinker,

		anim_stand = 		{SPR_ENM5, G, 10},
		anim_stand_hurt =	{SPR_ENM5, G, 1},
		anim_move =			{SPR_ENM5, G, 2},
		anim_run =			{SPR_ENM5, G, 2},
		anim_hurt =			{SPR_ENM5, G, 35},
		anim_getdown =		{SPR_ENM5, G, 1},
		anim_downloop =		{SPR_ENM5, G, 1},
		anim_getup =		{SPR_ENM5, G, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"lunge", "poison mist"},
		r_exp = 89,
	},

	["sword_1"] = {
		name = "Bashful Sword",
		skillchance = 75,
		level = 14,
		hp = 114,
		sp = 43,
		strength = 6,
		magic = 4,
		endurance = 4,
		agility = 3,
		luck = 1,
		melee_natk = "slash_1",
		weak = ATK_ICE|ATK_FIRE,
		repel = ATK_SLASH,
		thinker = generalEnemyThinker,

		anim_stand = 		{SPR_ENM1, I, 10},
		anim_stand_hurt =	{SPR_ENM1, I, 1},
		anim_move =			{SPR_ENM1, I, 2},
		anim_run =			{SPR_ENM1, I, 2},
		anim_hurt =			{SPR_ENM1, I, 35},
		anim_getdown =		{SPR_ENM1, I, 1},
		anim_downloop =		{SPR_ENM1, I, 1},
		anim_getup =		{SPR_ENM1, I, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"tarukaja", "cleave", "rakunda"},
		r_exp = 80,
	},

	["sword_1_postboss"] = {
		name = "Bashful Sword",
		skillchance = 75,
		level = 17,
		hp = 139,
		sp = 43,
		strength = 8,
		magic = 6,
		endurance = 6,
		agility = 4,
		luck = 3,
		melee_natk = "slash_1",
		weak = ATK_ICE|ATK_FIRE,
		repel = ATK_SLASH,
		thinker = generalEnemyThinker,

		anim_stand = 		{SPR_ENM1, I, 10},
		anim_stand_hurt =	{SPR_ENM1, I, 1},
		anim_move =			{SPR_ENM1, I, 2},
		anim_run =			{SPR_ENM1, I, 2},
		anim_hurt =			{SPR_ENM1, I, 35},
		anim_getdown =		{SPR_ENM1, I, 1},
		anim_downloop =		{SPR_ENM1, I, 1},
		anim_getup =		{SPR_ENM1, I, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"tarukaja", "giant slice", "rakunda"},
		r_exp = 131,
	},


	["wheel_1"] = {
		name = "Bestial Wheel",
		skillchance = 100,
		level = 18,
		hp = 178,
		sp = 50,
		strength = 12,
		magic = 1,
		endurance = 8,
		agility = 4,
		luck = 2,
		melee_natk = "slash_1",
		resist = ATK_BLESS|ATK_CURSE,
		weak = ATK_ELEC|ATK_FIRE,
		block = ATK_STRIKE|ATK_PIERCE|ATK_SLASH,
		thinker = generalEnemyThinker,
		scale = FRACUNIT*2,

		anim_stand = 		{SPR_ENM2, D, 10},
		anim_stand_hurt =	{SPR_ENM2, D, 1},
		anim_move =			{SPR_ENM2, D, 2},
		anim_run =			{SPR_ENM2, D, 2},
		anim_hurt =			{SPR_ENM2, D, 35},
		anim_getdown =		{SPR_ENM2, D, 1},
		anim_downloop =		{SPR_ENM2, D, 1},
		anim_getup =		{SPR_ENM2, D, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"tarukaja", "sonic punch"},
		r_exp = 231,
	},

	-- THEBEL ENEMIES

	["drive_boss1"] = {
		name = "Rampage Drive",
		skillchance = 100,	-- /100, probability of using a skill
		level = 12,
		hp = 617,
		sp = 852,
		strength = 5,
		magic = 5,
		endurance = 7,
		luck = 4,
		agility = 5,
		melee_natk = "strike_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_WIND,
		repel = ATK_ELEC,
		block = ATK_BLESS|ATK_CURSE,
		scale = FRACUNIT*2,
		/*thinker = 	function(mo)
					-- always follow the same tactics

						local enemies = mo.enemies
						mo.routine = $ and $+1 or 1

						if mo.routine == 1
							-- start by debuffing an enemy
							mo.routine_target = enemies[P_RandomRange(1, #enemies)]
							return attackDefs["makanda"], {mo.routine_target}
						elseif mo.routine == 2
							-- attack the target we chose
							mo.routine_target = enemies[P_RandomRange(1, #enemies)]
							return attackDefs["assault dive"], {mo.routine_target}
						elseif mo.routine == 3
							-- now buff ourselves!
							return attackDefs["makakaja"], {mo}
						elseif mo.routine == 4
							-- end it with mazio!
							mo.routine = 1
							return attackDefs["mazio"], enemies
						end

						return attackDefs["strike_1"], enemies[P_RandomRange(1, #enemies)]
					end,*/
		thinker = generalEnemyThinker,
		boss = true,
		endboss = true,	-- means it can't die and will get knocked down instead, it's a very specific behavior used for cinematic purposes
		r_exp = 350,
		r_macca = 800,
		turns = 2,

		r_drops = {
			{{"series", "qualz"}, 80},
			{{"series", "qualz"}, 80},
			{{"series", "vincir"}, 40},
			{{"series", "vincir"}, 40},
			{"emerald", 100},
			{"emerald", 100},
			{"emerald", 100},
			{"emerald", 100},
			{"ruby", 80},
			{"ruby", 80},
		},

		anim_stand = 		{SPR_ENM1, G, 10},
		anim_stand_hurt =	{SPR_ENM1, G, 1},
		anim_move =			{SPR_ENM1, G, 2},
		anim_run =			{SPR_ENM1, G, 2},
		anim_hurt =			{SPR_ENM1, G, 35},
		anim_getdown =		{SPR_ENM1, G, 1},
		anim_downloop =		{SPR_ENM1, G, 1},
		anim_getup =		{SPR_ENM1, G, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"makakaja", "makanda", "lunge", "zio"},
	},

	["table_boss1"] = {
		name = "Crying Table",
		skillchance = 65,	-- /100, probability of using a skill
		level = 7,
		hp = 182,
		sp = 56,
		atk = 20,
		strength = 3,
		magic = 2,
		endurance = 4,
		luck = 2,
		agility = 3,
		melee_natk = "strike_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_ICE|ATK_ELEC,
		repel = ATK_FIRE,
		block = 0,
		thinker = generalEnemyThinker,
		boss = true,
		scale = FRACUNIT*3/2,
		r_exp = 44,
		r_macca = 100,

		r_drops = {
			{{"series", "qualz"}, 40},
			{{"series", "vincir"}, 20},
			{"emerald", 90},
			{"ruby", 30},
		},

		anim_stand = 		{SPR_ENM1, O, 10},
		anim_stand_hurt =	{SPR_ENM1, O, 1},
		anim_move =			{SPR_ENM1, O, 2},
		anim_run =			{SPR_ENM1, O, 2},
		anim_hurt =			{SPR_ENM1, O, 35},
		anim_getdown =		{SPR_ENM1, O, 1},
		anim_downloop =		{SPR_ENM1, O, 1},
		anim_getup =		{SPR_ENM1, O, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"agi", "lunge", "rakunda", "dekaja", "dekunda"},
	},

	["hablerie_1"] = {
		name = "Lying Hablerie",
		skillchance = 25,	-- /100, probability of using a skill
		level = 1,
		atk = 10,
		hp = 73,
		sp = 8,
		strength = 2,
		magic = 1,
		endurance = 3,
		luck = 1,
		agility = 1,
		melee_natk = "slash_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_ICE|ATK_NUCLEAR|ATK_PSY,
		thinker = generalEnemyThinker,
		r_exp = 5,
		r_macca = 5,

		anim_stand = 		{SPR_ENM5, A, 10},
		anim_stand_hurt =	{SPR_ENM5, A, 1},
		anim_move =			{SPR_ENM5, A, 2},
		anim_run =			{SPR_ENM5, A, 2},
		anim_hurt =			{SPR_ENM5, A, 35},
		anim_getdown =		{SPR_ENM5, A, 1},
		anim_downloop =		{SPR_ENM5, A, 1},
		anim_getup =		{SPR_ENM5, A, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"dia", "garu"},
	},

	["hablerie_1_postboss"] = {
		name = "Lying Hablerie",
		skillchance = 50,	-- /100, probability of using a skill
		level = 5,
		atk = 10,
		hp = 93,
		sp = 12,
		strength = 3,
		magic = 2,
		endurance = 4,
		luck = 2,
		agility = 3,
		melee_natk = "strike_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_ICE|ATK_NUCLEAR|ATK_PSY,
		thinker = generalEnemyThinker,
		r_exp = 12,
		r_macca = 12,

		anim_stand = 		{SPR_ENM5, A, 10},
		anim_stand_hurt =	{SPR_ENM5, A, 1},
		anim_move =			{SPR_ENM5, A, 2},
		anim_run =			{SPR_ENM5, A, 2},
		anim_hurt =			{SPR_ENM5, A, 35},
		anim_getdown =		{SPR_ENM5, A, 1},
		anim_downloop =		{SPR_ENM5, A, 1},
		anim_getup =		{SPR_ENM5, A, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"dia", "garu"},
	},

	["cupid_1"] = {
		name = "Jealous Cupid",
		skillchance = 75,	-- /100, probability of using a skill
		level = 5,
		atk = 10,
		hp = 81,
		sp = 10,
		strength = 2,
		magic = 1,
		endurance = 3,
		luck = 1,
		agility = 1,
		melee_natk = "slash_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_ICE|ATK_NUCLEAR|ATK_PSY,
		thinker = generalEnemyThinker,
		r_exp = 9,
		r_macca = 5,

		anim_stand = 		{SPR_ENM5, Q, 10},
		anim_stand_hurt =	{SPR_ENM5, Q, 1},
		anim_move =			{SPR_ENM5, Q, 2},
		anim_run =			{SPR_ENM5, Q, 2},
		anim_hurt =			{SPR_ENM5, Q, 35},
		anim_getdown =		{SPR_ENM5, Q, 1},
		anim_downloop =		{SPR_ENM5, Q, 1},
		anim_getup =		{SPR_ENM5, Q, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"poisma"},
	},

	["maya_1"] = {
		name = "Cowardly Maya",
		skillchance = 25,	-- /100, probability of using a skill
		level = 1,
		atk = 10,
		hp = 65,
		sp = 4,
		strength = 2,
		magic = 1,
		endurance = 3,
		luck = 1,
		agility = 1,
		melee_natk = "slash_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_WIND|ATK_ELEC|ATK_BLESS|ATK_CURSE|ATK_FIRE|ATK_PSY|ATK_NUCLEAR,
		thinker = generalEnemyThinker,
		r_exp = 6,
		r_macca = 5,

		anim_stand = 		{SPR_ENM1, D, 10},
		anim_stand_hurt =	{SPR_ENM1, D, 1},
		anim_move =			{SPR_ENM1, D, 2},
		anim_run =			{SPR_ENM1, D, 2},
		anim_hurt =			{SPR_ENM1, D, 35},
		anim_getdown =		{SPR_ENM1, D, 1},
		anim_downloop =		{SPR_ENM1, D, 1},
		anim_getup =		{SPR_ENM1, D, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"bufu"},
	},

	-- Stronger variant of the cowardly maya
	["maya_1_postboss"] = {
		name = "Cowardly Maya",
		skillchance = 25,	-- /100, probability of using a skill
		level = 4,
		atk = 15,
		hp = 78,
		sp = 8,
		strength = 3,
		magic = 3,
		endurance = 4,
		luck = 2,
		agility = 2,
		melee_natk = "slash_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_WIND|ATK_ELEC|ATK_BLESS|ATK_CURSE|ATK_FIRE|ATK_PSY|ATK_NUCLEAR,
		thinker = generalEnemyThinker,
		r_exp = 11,
		r_macca = 7,

		anim_stand = 		{SPR_ENM1, D, 10},
		anim_stand_hurt =	{SPR_ENM1, D, 1},
		anim_move =			{SPR_ENM1, D, 2},
		anim_run =			{SPR_ENM1, D, 2},
		anim_hurt =			{SPR_ENM1, D, 35},
		anim_getdown =		{SPR_ENM1, D, 1},
		anim_downloop =		{SPR_ENM1, D, 1},
		anim_getup =		{SPR_ENM1, D, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"bufu"},
	},

	["maya_gold"] = {
		name = "Opulent Maya",
		skillchance = 0,	-- /100, probability of using a skill
		level = 1,
		hp = 99,
		sp = 1,
		strength = 1,
		magic = 1,
		endurance = 1,
		luck = 99,
		agility = 99,
		melee_natk = "slash_1",	-- enemies don't have crit anims for their attacks.
		thinker = 		function(mo)

							mo.waitturns = $ or 0
							if P_RandomRange(0, 100) < mo.waitturns
								return attackDefs["run"], {mo}
							end

							mo.waitturns = $+10

							return generalEnemyThinker(mo)
						end,

		thinkframe = 	function(mo)
							if mo and mo.valid and mo.hp
								goldShadowGlow(mo)
							end
						end,
		r_exp = 1,
		r_drops = {
			{"nihil frame", 30},
		},

		anim_stand = 		{SPR_ENM1, D, 10},
		anim_stand_hurt =	{SPR_ENM1, D, 1},
		anim_move =			{SPR_ENM1, D, 2},
		anim_run =			{SPR_ENM1, D, 2},
		anim_hurt =			{SPR_ENM1, D, 35},
		anim_getdown =		{SPR_ENM1, D, 1},
		anim_downloop =		{SPR_ENM1, D, 1},
		anim_getup =		{SPR_ENM1, D, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"opulence"},
	},

	["mage_1"] = {
		name = "Dizzy Mage",
		skillchance = 100,	-- /100, probability of using a skill
		level = 7,
		hp = 92,
		sp = 32,
		strength = 2,
		magic = 5,
		endurance = 4,
		luck = 3,
		agility = 4,
		melee_natk = "slash_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_CURSE,
		block = ATK_BLESS,
		resist = ATK_ICE,
		thinker = generalEnemyThinker,
		r_exp = 14,
		r_macca = 8,

		anim_stand = 		{SPR_ENM1, H, 10},
		anim_stand_hurt =	{SPR_ENM1, H, 1},
		anim_move =			{SPR_ENM1, H, 2},
		anim_run =			{SPR_ENM1, H, 2},
		anim_hurt =			{SPR_ENM1, H, 35},
		anim_getdown =		{SPR_ENM1, H, 1},
		anim_downloop =		{SPR_ENM1, H, 1},
		anim_getup =		{SPR_ENM1, H, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"rakunda", "makanda", "sukunda"},
	},

	["relic_1"] = {
		name = "Still Relic",
		skillchance = 80,	-- /100, probability of using a skill
		level = 8,
		hp = 92,
		sp = 27,
		strength = 3,
		magic = 5,
		endurance = 6,
		luck = 3,
		agility = 4,
		melee_natk = "pierce_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_ELEC|ATK_CURSE,
		block = ATK_WIND,
		repel = ATK_BLESS,
		thinker = generalEnemyThinker,
		r_exp = 16,
		r_macca = 10,

		anim_stand = 		{SPR_ENM1, L, 10},
		anim_stand_hurt =	{SPR_ENM1, L, 1},
		anim_move =			{SPR_ENM1, L, 2},
		anim_run =			{SPR_ENM1, L, 2},
		anim_hurt =			{SPR_ENM1, L, 35},
		anim_getdown =		{SPR_ENM1, L, 1},
		anim_downloop =		{SPR_ENM1, L, 1},
		anim_getup =		{SPR_ENM1, L, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"garu", "rakukaja"},
	},

	["hand_1"] = {
		name = "Magic Hand",
		skillchance = 50,	-- /100, probability of using a skill
		atk = 12,
		level = 3,
		hp = 75,
		sp = 10,
		strength = 1,
		magic = 1,
		endurance = 2,
		luck = 2,
		agility = 3,
		melee_natk = "strike_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_ICE|ATK_PSY,
		resist = ATK_FIRE|ATK_NUCLEAR,
		thinker = generalEnemyThinker,
		r_exp = 5,
		r_macca = 5,

		anim_stand = 		{SPR_ENM1, B, 10},
		anim_stand_hurt =	{SPR_ENM1, B, 1},
		anim_move =			{SPR_ENM1, B, 2},
		anim_run =			{SPR_ENM1, B, 2},
		anim_hurt =			{SPR_ENM1, B, 35},
		anim_getdown =		{SPR_ENM1, B, 1},
		anim_downloop =		{SPR_ENM1, B, 1},
		anim_getup =		{SPR_ENM1, B, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"agi", "frei"},
	},

	["hand_1_postboss"] = {
		name = "Magic Hand",
		skillchance = 50,	-- /100, probability of using a skill
		atk = 12,
		level = 6,
		hp = 78,
		sp = 10,
		strength = 2,
		magic = 3,
		endurance = 3,
		luck = 2,
		agility = 3,
		melee_natk = "strike_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_ICE|ATK_PSY,
		resist = ATK_FIRE|ATK_NUCLEAR,
		thinker = generalEnemyThinker,
		r_exp = 9,
		r_macca = 8,

		anim_stand = 		{SPR_ENM1, B, 10},
		anim_stand_hurt =	{SPR_ENM1, B, 1},
		anim_move =			{SPR_ENM1, B, 2},
		anim_run =			{SPR_ENM1, B, 2},
		anim_hurt =			{SPR_ENM1, B, 35},
		anim_getdown =		{SPR_ENM1, B, 1},
		anim_downloop =		{SPR_ENM1, B, 1},
		anim_getup =		{SPR_ENM1, B, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"agi", "frei"},
	},

	["table_1"] = {
		name = "Laughing Table",
		skillchance = 20,	-- /100, probability of using a skill
		level = 3,
		hp = 74,
		sp = 4,
		atk = 15,
		strength = 2,
		magic = 1,
		endurance = 3,
		luck = 1,
		agility = 2,
		melee_natk = "slash_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_NUCLEAR|ATK_PIERCE|ATK_FIRE,
		resist = ATK_ELEC,
		thinker = generalEnemyThinker,
		r_exp = 7,
		r_macca = 5,

		anim_stand = 		{SPR_ENM1, A, 10},
		anim_stand_hurt =	{SPR_ENM1, A, 1},
		anim_move =			{SPR_ENM1, A, 2},
		anim_run =			{SPR_ENM1, A, 2},
		anim_hurt =			{SPR_ENM1, A, 35},
		anim_getdown =		{SPR_ENM1, A, 1},
		anim_downloop =		{SPR_ENM1, A, 1},
		anim_getup =		{SPR_ENM1, A, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"zio", "psi"},
	},

	["table_1_postboss"] = {
		name = "Laughing Table",
		skillchance = 50,	-- /100, probability of using a skill
		level = 6,
		hp = 84,
		sp = 4,
		atk = 15,
		strength = 3,
		magic = 3,
		endurance = 4,
		luck = 1,
		agility = 3,
		melee_natk = "slash_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_NUCLEAR|ATK_PIERCE|ATK_FIRE,
		resist = ATK_ELEC,
		thinker = generalEnemyThinker,
		r_exp = 12,
		r_macca = 8,

		anim_stand = 		{SPR_ENM1, A, 10},
		anim_stand_hurt =	{SPR_ENM1, A, 1},
		anim_move =			{SPR_ENM1, A, 2},
		anim_run =			{SPR_ENM1, A, 2},
		anim_hurt =			{SPR_ENM1, A, 35},
		anim_getdown =		{SPR_ENM1, A, 1},
		anim_downloop =		{SPR_ENM1, A, 1},
		anim_getup =		{SPR_ENM1, A, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"zio", "psi"},
	},

	["beetle_1"] = {
		name = "Grave Beetle",
		skillchance = 55,	-- /100, probability of using a skill
		level = 8,
		hp = 171,
		sp = 12,
		strength = 6,
		magic = 1,
		endurance = 6,
		luck = 1,
		agility = 2,
		melee_natk = "slash_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_WIND|ATK_ICE,
		resist = ATK_ELEC|ATK_STRIKE,
		block = ATK_CURSE,
		thinker = generalEnemyThinker,
		r_exp = 52,
		r_macca = 50,

		anim_stand = 		{SPR_ENM1, Q, 10},
		anim_stand_hurt =	{SPR_ENM1, Q, 1},
		anim_move =			{SPR_ENM1, Q, 2},
		anim_run =			{SPR_ENM1, Q, 2},
		anim_hurt =			{SPR_ENM1, Q, 35},
		anim_getdown =		{SPR_ENM1, Q, 1},
		anim_downloop =		{SPR_ENM1, Q, 1},
		anim_getup =		{SPR_ENM1, Q, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"lunge", "mabufu"},
	},

	["balance_1"] = {
		name = "Heat Balance",
		skillchance = 35,
		level = 4,
		hp = 71,
		sp = 11,
		strength = 3,
		magic = 2,
		endurance = 2,
		agility = 2,
		luck = 1,
		melee_natk = "pierce_1",
		weak = ATK_ELEC|ATK_WIND,
		block = ATK_FIRE|ATK_ICE,
		thinker = generalEnemyThinker,

		anim_stand = 		{SPR_ENM1, F, 10},
		anim_stand_hurt =	{SPR_ENM1, F, 1},
		anim_move =			{SPR_ENM1, F, 2},
		anim_run =			{SPR_ENM1, F, 2},
		anim_hurt =			{SPR_ENM1, F, 35},
		anim_getdown =		{SPR_ENM1, F, 1},
		anim_downloop =		{SPR_ENM1, F, 1},
		anim_getup =		{SPR_ENM1, F, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"agi", "bufu"},
		r_exp = 9,
		r_macca = 7,
	},

	["balance_1_postboss"] = {
		name = "Heat Balance",
		skillchance = 55,
		level = 7,
		hp = 81,
		sp = 15,
		strength = 4,
		magic = 3,
		endurance = 4,
		agility = 3,
		luck = 2,
		melee_natk = "pierce_1",
		weak = ATK_ELEC|ATK_WIND,
		block = ATK_FIRE|ATK_ICE,
		thinker = generalEnemyThinker,

		anim_stand = 		{SPR_ENM1, F, 10},
		anim_stand_hurt =	{SPR_ENM1, F, 1},
		anim_move =			{SPR_ENM1, F, 2},
		anim_run =			{SPR_ENM1, F, 2},
		anim_hurt =			{SPR_ENM1, F, 35},
		anim_getdown =		{SPR_ENM1, F, 1},
		anim_downloop =		{SPR_ENM1, F, 1},
		anim_getup =		{SPR_ENM1, F, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"agi", "bufu"},
		r_exp = 14,
		r_macca = 9,
	},

	["angel"] = {
		name = "Angel Replica",
		skillchance = 100,
		level = 50,
		hp = 1000,
		sp = 1000,
		strength = 65,
		magic = 50,
		endurance = 40,
		agility = 40,
		luck = 25,
		melee_natk = "slash_1",
		boss = true,
		block = ATK_PIERCE,

		hudcutin = "REPL_A",

		--thinker = generalEnemyThinker,

		thinker = 	function(mo)
						-- Kanade thinker

						local enemies = mo.enemies
						local btl = server.P_BattleStatus[mo.battlen]

						if mo.status_condition == COND_SILENCE
							mo.use_howling = nil
							return generalEnemyThinker(mo)
						end

						if mo.use_howling
							mo.use_howling = nil	-- Don't forget to undo that.
							return attackDefs["howling"], mo.enemies
						end

						-- first 2 turns: always go for harmonics and then hand sonic.
						if btl.turn == 1
							return attackDefs["harmonics"], {mo}
						elseif btl.turn == 2
							return attackDefs["hand sonic"], {enemies[P_RandomRange(1, #enemies)]}
						end

						-- make a clone if we're severely outnumbered and that my health is low!!
						if mo.hp < mo.maxhp/2
						and #mo.allies < 3
							return attackDefs["harmonics"], {mo}
						end

						-- under other circumstances just use a random attack in our arsenal

						-- Random chance to use distortion: (1/8)
						if not P_RandomRange(0, 7)

							-- before we do, check if our allies aren't using it either, because it will lead to a guaranteed howling:
							for i = 1, #mo.allies
								if mo.allies[i] and mo.allies[i].valid
								and (mo.allies[i].guaranteedevasion or mo.allies[i].use_howling)

									return generalEnemyThinker(mo)	-- well too bad.
								end
							end

							mo.use_howling = true	-- next time we can act for real, use howling!
							return attackDefs["distortion"], {mo}
						end

						return generalEnemyThinker(mo)
					end,

		color = SKINCOLOR_AETHER,

		anim_stand = 		{SPR_KNDR, A, 10},
		anim_stand_hurt =	{SPR_KNDR, A, 10},
		anim_move =			{SPR_KNDR, B, C, D, E, F, G, 2},
		anim_run =			{SPR_KNDR, B, C, D, E, F, G, 2},
		anim_hurt =			{SPR_KNDR, L, 20},
		anim_getdown =		{SPR_KNDR, T, 1},
		anim_downloop =		{SPR_KNDR, T, 1},
		anim_getup =		{SPR_KNDR, A, 5},

		anim_special1 =		{SPR_KNDR, K, TICRATE*8},
		anim_special2 =		{SPR_KNDR, H, TICRATE*8},
		anim_special3 =		{SPR_KNDR, I, J, 2},
		anim_special4 = 	{SPR_KNDR, U, TICRATE},			-- guard
		anim_sepcial5 =		{SPR_KNDR, V, TICRATE},			-- howling prep
		anim_special6 =		{SPR_KNDR, W, X, 2},			-- howling

		skills = {"hand sonic", "gale slash", "cruel attack", "toxic slice", "delay", "dekaja", "dekunda"},
		r_exp = 0,
	},

	["tutorial_1"] = {
		name = "Static Maya",
		skillchance = 0,	-- /100, probability of using a skill
		level = 5,
		hp = 60,
		sp = 10,
		strength = 4,
		magic = 3,
		endurance = 6,
		luck = 1,
		agility = 1,
		melee_natk = "slash_1",	-- enemies don't have crit anims for their attacks.
		thinker = generalEnemyThinker,
		r_exp = 0,

		anim_stand = 		{SPR_ENM1, D, 10},
		anim_stand_hurt =	{SPR_ENM1, D, 1},
		anim_move =			{SPR_ENM1, D, 2},
		anim_run =			{SPR_ENM1, D, 2},
		anim_hurt =			{SPR_ENM1, D, 35},
		anim_getdown =		{SPR_ENM1, D, 1},
		anim_downloop =		{SPR_ENM1, D, 1},
		anim_getup =		{SPR_ENM1, D, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"kouha"},
	},

	["tutorial_2"] = {
		name = "Sobbing Table",
		skillchance = 0,	-- /100, probability of using a skill
		level = 5,
		hp = 80,
		sp = 10,
		strength = 1,
		magic = 1,
		endurance = 6,
		luck = 1,
		agility = 1,
		melee_natk = "strike_1",	-- enemies don't have crit anims for their attacks.
		thinker = generalEnemyThinker,
		weak = ATK_FIRE|ATK_WIND,
		r_exp = 0,

		anim_stand = 		{SPR_ENM1, A, 10},
		anim_stand_hurt =	{SPR_ENM1, A, 1},
		anim_move =			{SPR_ENM1, A, 2},
		anim_run =			{SPR_ENM1, A, 2},
		anim_hurt =			{SPR_ENM1, A, 35},
		anim_getdown =		{SPR_ENM1, A, 1},
		anim_downloop =		{SPR_ENM1, A, 1},
		anim_getup =		{SPR_ENM1, A, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"strike_1"},
	},

	["amy_tutorial"] = {
		name = "Amy",
		skillchance = 100,	-- /100, probability of using a skill
		level = 10,
		hp = 300,
		sp = 100,
		strength = 1,
		magic = 1,
		endurance = 4,
		luck = 3,
		agility = 1,
		melee_natk = "amy_atk1",	-- enemies don't have crit anims for their attacks.
		thinker = generalEnemyThinker,
		weak = ATK_ELEC,
		r_exp = 0,

		skin = "amy",			-- for "player" fights.
		color = SKINCOLOR_ROSY,	-- for colormapping
		hudcutin = "AMYR_A",
		persona = "io",

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
		anim_downloop =		{SPR_PLAY, A, 1, "SPR2_PAIN"},		-- is down
		anim_getup =		{SPR_PLAY, A, B, C, D, 1, "SPR2_ROLL"},		-- gets up from down
		anim_death =		{SPR_PLAY, A, 30, "SPR2_PAIN"},		-- dies
		anim_revive =		{SPR_PLAY, A, B, C, D, 1, "SPR2_ROLL"},		-- gets revived
		anim_evoker =		{SPR_CSMN, G, 2},	-- holding evoker to head
		anim_evoker_shoot =	{SPR_CSMN, H, 2},		-- shooting evoker

		anim_special1 = {SPR_PLAY, A, 2, "SPR2_MLEE"}, -- hammer prep
		anim_special2 = {SPR_PLAY, B, C, D, 2, "SPR2_MLEE"}, -- hammer swing
		anim_special3 = {SPR_PLAY, A, "SPR2_MLEE"},	-- hammer swung
		anim_special4 = {SPR_PLAY, A, B, C, D, E, "SPR2_TWIN"},	-- hammer spin

		vfx_summon = {"sfx_arsum1", "sfx_arsum2", "sfx_arsum3", "sfx_arsum4"},
		vfx_skill = {"sfx_arskl1", "sfx_arskl2", "sfx_arskl3"},
		vfx_item = {"sfx_aruse1"},
		vfx_hurt = {"sfx_arhrt1", "sfx_arhrt2", "sfx_arhrt3"},
		vfx_xhurt = {"sfx_arhrx1"},
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

		skills = {"eiha", "infinite endure"},
	},

	["maya_vr"] = {
		name = "Empty Maya",
		skillchance = 0,	-- /100, probability of using a skill
		atk = 10,
		level = 1,
		hp = 50,
		sp = 3,
		strength = 2,
		magic = 1,
		endurance = 3,
		luck = 1,
		agility = 2,
		melee_natk = "slash_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_WIND|ATK_ICE|ATK_ELEC|ATK_BLESS|ATK_CURSE|ATK_FIRE|ATK_PSY|ATK_NUCLEAR,
		thinker = generalEnemyThinker,
		r_exp = 10,

		anim_stand = 		{SPR_ENM1, D, 10},
		anim_stand_hurt =	{SPR_ENM1, D, 1},
		anim_move =			{SPR_ENM1, D, 2},
		anim_run =			{SPR_ENM1, D, 2},
		anim_hurt =			{SPR_ENM1, D, 35},
		anim_getdown =		{SPR_ENM1, D, 1},
		anim_downloop =		{SPR_ENM1, D, 1},
		anim_getup =		{SPR_ENM1, D, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"agi"},
	},

	["hand_vr"] = {
		name = "Empty Hand",
		skillchance = 75,	-- /100, probability of using a skill
		atk = 5,
		level = 1,
		hp = 40,
		sp = 4,
		strength = 1,
		magic = 1,
		endurance = 2,
		luck = 1,
		agility = 1,
		melee_natk = "strike_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_ICE|ATK_PSY,
		resist = ATK_FIRE|ATK_NUCLEAR,
		thinker = generalEnemyThinker,
		r_exp = 60,

		anim_stand = 		{SPR_ENM1, B, 10},
		anim_stand_hurt =	{SPR_ENM1, B, 1},
		anim_move =			{SPR_ENM1, B, 2},
		anim_run =			{SPR_ENM1, B, 2},
		anim_hurt =			{SPR_ENM1, B, 35},
		anim_getdown =		{SPR_ENM1, B, 1},
		anim_downloop =		{SPR_ENM1, B, 1},
		anim_getup =		{SPR_ENM1, B, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"agi", "frei"},
	},

	["table_vr"] = {
		name = "Empty Table",
		skillchance = 75,	-- /100, probability of using a skill
		atk = 5,
		level = 1,
		hp = 45,
		sp = 4,
		strength = 1,
		magic = 1,
		endurance = 2,
		luck = 3,
		agility = 1,
		melee_natk = "slash_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_NUCLEAR|ATK_PIERCE|ATK_FIRE,
		resist = ATK_ELEC,
		thinker = generalEnemyThinker,
		r_exp = 80,

		anim_stand = 		{SPR_ENM1, A, 10},
		anim_stand_hurt =	{SPR_ENM1, A, 1},
		anim_move =			{SPR_ENM1, A, 2},
		anim_run =			{SPR_ENM1, A, 2},
		anim_hurt =			{SPR_ENM1, A, 35},
		anim_getdown =		{SPR_ENM1, A, 1},
		anim_downloop =		{SPR_ENM1, A, 1},
		anim_getup =		{SPR_ENM1, A, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"zio", "psi"},
	},

	-- VR: BOSS 1
	["beetle_vr"] = {
		name = "Empty Beetle",
		skillchance = 65,	-- /100, probability of using a skill
		level = 10,
		hp = 255,
		sp = 24,
		strength = 6,
		magic = 1,
		endurance = 6,
		luck = 1,
		agility = 2,
		melee_natk = "slash_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_WIND|ATK_ICE,
		resist = ATK_ELEC|ATK_STRIKE,
		block = ATK_CURSE,
		thinker = generalEnemyThinker,
		r_exp = 255,
		r_macca = 50,
		nopvp = true,

		anim_stand = 		{SPR_ENM1, Q, 10},
		anim_stand_hurt =	{SPR_ENM1, Q, 1},
		anim_move =			{SPR_ENM1, Q, 2},
		anim_run =			{SPR_ENM1, Q, 2},
		anim_hurt =			{SPR_ENM1, Q, 35},
		anim_getdown =		{SPR_ENM1, Q, 1},
		anim_downloop =		{SPR_ENM1, Q, 1},
		anim_getup =		{SPR_ENM1, Q, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"mabufu"},

		r_drops = {
			{{"series", "dion"}, 100},
			{{"series", "dion"}, 100},
			{{"series", "alter"}, 100},
			{{"series", "red"}, 100},
			{{"ring", "ring-0"}, 100},
			{{"ring", "ring-0"}, 70},
			{{"ring", "ring-0"}, 40},
			{{"ring", "ring-0"}, 25},
			{"vessel 2", 100},
			{"vessel 2", 50},
			{"vessel 2", 20},
			{"vessel 2", 5},
			{"soul 2", 100},
			{"soul 2", 50},
			{"soul 2", 20},
			{"soul 2", 5},
			{"str catalyst 1", 70},
			{"mag catalyst 1", 70},
			{"end catalyst 1", 70},
			{"agi catalyst 1", 70},
			{"luk catalyst 1", 70},
			{"levelcap up", 100},
			{"levelcap up", 100},
			{"vr up", 100},
			{"vr up", 100},
		},
	},

	-- VR: BOSS 2
	["knight_vr"] = {
		name = "Empty Knight",
		skillchance = 80,
		level = 20,
		hp = 250,
		sp = 80,
		strength = 9,
		magic = 7,
		endurance = 4,
		agility = 4,
		luck = 6,
		melee_natk = "pierce_1",
		block = ATK_SLASH,
		weak = ATK_BLESS|ATK_NUCLEAR,
		resist = ATK_PSY,
		thinker = generalEnemyThinker,
		scale = FRACUNIT*2,
		nopvp = true,

		anim_stand = 		{SPR_ENM1, K, 10},
		anim_stand_hurt =	{SPR_ENM1, K, 1},
		anim_move =			{SPR_ENM1, K, 2},
		anim_run =			{SPR_ENM1, K, 2},
		anim_hurt =			{SPR_ENM1, K, 35},
		anim_getdown =		{SPR_ENM1, K, 1},
		anim_downloop =		{SPR_ENM1, K, 1},
		anim_getup =		{SPR_ENM1, K, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"provoke", "tarukaja", "mapsi", "giant slice"},

		r_drops = {
			{{"series", "foie"}, 30},
			{{"series", "barta"}, 30},
			{{"series", "zonde"}, 30},
			{{"series", "zan"}, 30},
			{{"ring", "ring-0"}, 100},
			{{"ring", "ring-0"}, 100},
			{{"ring", "ring-0"}, 100},
			{{"ring", "ring-0"}, 100},
			{"vessel 2", 100},
			{"vessel 2", 50},
			{"vessel 2", 20},
			{"vessel 2", 5},
			{"soul 2", 100},
			{"soul 2", 50},
			{"soul 2", 20},
			{"soul 2", 5},
			{"str catalyst 1", 70},
			{"mag catalyst 1", 70},
			{"end catalyst 1", 70},
			{"agi catalyst 1", 70},
			{"luk catalyst 1", 70},
			{"str catalyst 1", 50},
			{"mag catalyst 1", 50},
			{"end catalyst 1", 50},
			{"agi catalyst 1", 50},
			{"luk catalyst 1", 50},
			{"levelcap up", 100},
			{"levelcap up", 100},
			{"vr up", 100},
			{"vr up", 100},
		},

		r_exp = 450,
	},

	-- VR: BOSS 3 (2 possible bosses...)
	["gigas_vr"] = {
		name = "Gigas of Emptiness",
		skillchance = 100,	-- /100, probability of using a skill
		level = 30,
		hp = 550,
		sp = 200,
		strength = 16,
		magic = 16,
		endurance = 14,
		luck = 10,
		agility = 10,
		melee_natk = "strike_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_WIND|ATK_PSY,
		resist = ATK_ELEC,
		block = ATK_FIRE,
		thinker = generalEnemyThinker,

		boss = true,
		nopvp = true,
		scale = FRACUNIT*3/2,

		r_drops = {
			{{"series", "rafoie"}, 30},
			{{"series", "rabarta"}, 30},
			{{"series", "razonde"}, 30},
			{{"series", "razan"}, 30},
			{{"ring", "nox rings"}, 100},
			{{"ring", "nox rings"}, 50},
			{{"ring", "revoluzio rings"}, 50},
			{{"ring", "revoluzio rings"}, 10},
			{"agilao gem", 100},
			{"agilao gem", 100},
			{"agilao gem", 100},
			{"bufula gem", 100},
			{"bufula gem", 100},
			{"bufula gem", 100},
			{"garula gem", 100},
			{"garula gem", 100},
			{"garula gem", 100},
			{"zionga gem", 100},
			{"zionga gem", 100},
			{"zionga gem", 100},
			{"psio gem", 100},
			{"psio gem", 100},
			{"psio gem", 100},
			{"freila gem", 100},
			{"freila gem", 100},
			{"freila gem", 100},
			{"vessel 2", 100},
			{"vessel 2", 50},
			{"vessel 2", 20},
			{"vessel 2", 5},
			{"soul 2", 100},
			{"soul 2", 50},
			{"soul 2", 20},
			{"soul 2", 5},
			{"str catalyst 1", 70},
			{"mag catalyst 1", 70},
			{"end catalyst 1", 70},
			{"agi catalyst 1", 70},
			{"luk catalyst 1", 70},
			{"str catalyst 2", 50},
			{"mag catalyst 2", 50},
			{"end catalyst 2", 50},
			{"agi catalyst 2", 50},
			{"luk catalyst 2", 50},
			{"levelcap up", 100},
			{"levelcap up", 100},
			{"vr up", 100},
			{"vr up", 100},
		},

		r_exp = 890,
		anim_stand = 		{SPR_ENM2, I, 10},
		anim_stand_hurt =	{SPR_ENM2, I, 1},
		anim_move =			{SPR_ENM2, I, 2},
		anim_run =			{SPR_ENM2, I, 2},
		anim_hurt =			{SPR_ENM2, I, 35},
		anim_getdown =		{SPR_ENM2, I, 1},
		anim_downloop =		{SPR_ENM2, I, 1},
		anim_getup =		{SPR_ENM2, I, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"masukukaja", "assault dive", "double fang", "freila", "dekaja", "dekunda"},
	},

	["magus_vr"] = {
		name = "Empty Magus",
		skillchance = 100,	-- /100, probability of using a skill
		level = 30,
		hp = 550,
		sp = 300,
		strength = 16,
		magic = 16,
		endurance = 13,
		luck = 10,
		agility = 11,
		melee_natk = "slash_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_FIRE,
		resist = ATK_ELEC,
		drain = ATK_ICE,
		thinker = generalEnemyThinker,

		boss = true,
		nopvp = true,
		scale = FRACUNIT*3/2,

		r_drops = {
			{{"series", "rafoie"}, 30},
			{{"series", "rabarta"}, 30},
			{{"series", "razonde"}, 30},
			{{"series", "razan"}, 30},
			{{"ring", "nox rings"}, 100},
			{{"ring", "nox rings"}, 50},
			{{"ring", "revoluzio rings"}, 50},
			{{"ring", "revoluzio rings"}, 10},
			{"agilao gem", 100},
			{"agilao gem", 100},
			{"agilao gem", 100},
			{"bufula gem", 100},
			{"bufula gem", 100},
			{"bufula gem", 100},
			{"garula gem", 100},
			{"garula gem", 100},
			{"garula gem", 100},
			{"zionga gem", 100},
			{"zionga gem", 100},
			{"zionga gem", 100},
			{"psio gem", 100},
			{"psio gem", 100},
			{"psio gem", 100},
			{"freila gem", 100},
			{"freila gem", 100},
			{"freila gem", 100},
			{"vessel 2", 100},
			{"vessel 2", 50},
			{"vessel 2", 20},
			{"vessel 2", 5},
			{"soul 2", 100},
			{"soul 2", 50},
			{"soul 2", 20},
			{"soul 2", 5},
			{"levelcap up", 100},
			{"levelcap up", 100},
			{"void booster-s 1", 100},
			{"void booster-s 1", 100},
			{"void booster-s 1", 100},
			{"void booster-s 1", 100},
			{"str catalyst 1", 70},
			{"mag catalyst 1", 70},
			{"end catalyst 1", 70},
			{"agi catalyst 1", 70},
			{"luk catalyst 1", 70},
			{"str catalyst 2", 50},
			{"mag catalyst 2", 50},
			{"end catalyst 2", 50},
			{"agi catalyst 2", 50},
			{"luk catalyst 2", 50},
			{"vr up", 100},
			{"vr up", 100},
		},

		r_exp = 890,
		anim_stand = 		{SPR_ENM2, N, 10},
		anim_stand_hurt =	{SPR_ENM2, N, 1},
		anim_move =			{SPR_ENM2, N, 2},
		anim_run =			{SPR_ENM2, N, 2},
		anim_hurt =			{SPR_ENM2, N, 35},
		anim_getdown =		{SPR_ENM2, N, 1},
		anim_downloop =		{SPR_ENM2, N, 1},
		anim_getup =		{SPR_ENM2, N, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"mabufu", "bufula", "rakunda", "dekaja", "dekunda"},
	},

	-- VR BOSS 4:
	["giant_vr"] = {
		name = "Empty Giant",
		skillchance = 100,	-- /100, probability of using a skill
		level = 40,
		hp = 610,
		sp = 1000,
		strength = 24,
		magic = 24,
		endurance = 14,
		luck = 20,
		agility = 15,
		melee_natk = "slash_1",	-- enemies don't have crit anims for their attacks.

		block = ATK_SLASH,
		weak = ATK_FIRE,
		repel = ATK_ICE,
		thinker = generalEnemyThinker,

		boss = true,
		nopvp = true,
		scale = FRACUNIT*133/100,

		r_drops = {
			{{"series", "laser"}, 30},
			{{"series", "laser"}, 30},
			{{"series", "nox"}, 30},
			{{"series", "nox"}, 30},
			{{"ring", "vitalis rings"}, 100},
			{{"ring", "spirita rings"}, 100},
			{{"ring", "lambda rings"}, 50},
			{{"ring", "agil rings"}, 10},
			{{"ring", "agil rings"}, 10},
			{"agilao gem", 100},
			{"agilao gem", 100},
			{"agilao gem", 100},
			{"bufula gem", 100},
			{"bufula gem", 100},
			{"bufula gem", 100},
			{"garula gem", 100},
			{"garula gem", 100},
			{"garula gem", 100},
			{"zionga gem", 100},
			{"zionga gem", 100},
			{"zionga gem", 100},
			{"psio gem", 100},
			{"psio gem", 100},
			{"psio gem", 100},
			{"freila gem", 100},
			{"freila gem", 100},
			{"freila gem", 100},
			{"vessel 3", 100},
			{"vessel 2", 50},
			{"vessel 2", 20},
			{"vessel 2", 5},
			{"soul 3", 100},
			{"soul 2", 50},
			{"soul 2", 20},
			{"soul 2", 5},
			{"levelcap up", 100},
			{"levelcap up", 100},
			{"void booster-s 1", 100},
			{"void booster-s 1", 100},
			{"void booster-s 1", 100},
			{"void booster-s 1", 100},
			{"void booster-sr", 100},
			{"void booster-sw", 100},
			{"void booster-sr", 50},
			{"void booster-sw", 50},
			{"str catalyst 1", 70},
			{"mag catalyst 1", 70},
			{"end catalyst 1", 70},
			{"agi catalyst 1", 70},
			{"luk catalyst 1", 70},
			{"str catalyst 2", 50},
			{"mag catalyst 2", 50},
			{"end catalyst 2", 50},
			{"agi catalyst 2", 50},
			{"luk catalyst 2", 50},
			{"vr up", 100},
			{"vr up", 100},
		},

		r_exp = 2500,
		anim_stand = 		{SPR_ENM2, Z, 10},
		anim_stand_hurt =	{SPR_ENM2, Z, 1},
		anim_move =			{SPR_ENM2, Z, 2},
		anim_run =			{SPR_ENM2, Z, 2},
		anim_hurt =			{SPR_ENM2, Z, 35},
		anim_getdown =		{SPR_ENM2, Z, 1},
		anim_downloop =		{SPR_ENM2, Z, 1},
		anim_getup =		{SPR_ENM2, Z, 1},

		skills = {"bufula", "fatal end", "tarukaja", "rakunda", "pulinpa", "life leech", "dekaja", "dekunda"},
	},

	-- VR BOSS 5
	["angel_vr"] = {
		name = "Angel Replica-0",
		skillchance = 100,
		level = 50,
		hp = 1000,
		sp = 1000,
		strength = 30,
		magic = 30,
		endurance = 24,
		agility = 20,
		luck = 12,
		melee_natk = "slash_1",
		boss = true,
		nopvp = true,
		block = ATK_PIERCE,

		hudcutin = "REPL_A",

		--thinker = generalEnemyThinker,

		thinker = 	function(mo)
						-- Kanade thinker

						local enemies = mo.enemies
						local btl = server.P_BattleStatus[mo.battlen]

						if mo.status_condition == COND_SILENCE
							mo.use_howling = nil
							return generalEnemyThinker(mo)
						end

						if mo.use_howling
							mo.use_howling = nil	-- Don't forget to undo that.
							return attackDefs["howling-0"], mo.enemies
						end

						-- first 2 turns: always go for harmonics and then hand sonic.
						if btl.turn == 1
							return attackDefs["harmonic-0"], {mo}
						elseif btl.turn == 2
							return attackDefs["hand sonic"], {enemies[P_RandomRange(1, #enemies)]}
						end

						-- make a clone if we're severely outnumbered and that my health is low!!
						if mo.hp < mo.maxhp/2
						and #mo.allies < 3
							return attackDefs["harmonics-0"], {mo}
						end

						-- under other circumstances just use a random attack in our arsenal

						-- Random chance to use distortion: (1/8)
						if not P_RandomRange(0, 7)

							-- before we do, check if our allies aren't using it either, because it will lead to a guaranteed howling:
							for i = 1, #mo.allies
								if mo.allies[i] and mo.allies[i].valid
								and (mo.allies[i].guaranteedevasion or mo.allies[i].use_howling)

									return generalEnemyThinker(mo)	-- well too bad.
								end
							end

							mo.use_howling = true	-- next time we can act for real, use howling!
							return attackDefs["distortion"], {mo}
						end

						return generalEnemyThinker(mo)
					end,

		r_drops = {
			{{"series", "v2-dion"}, 60},
			{{"series", "v2-dion"}, 60},
			{{"series", "agil"}, 45},
			{{"series", "agil"}, 45},
			{{"ring", "lambda rings"}, 60},
			{{"ring", "lambda rings"}, 60},
			{{"ring", "agil rings"}, 30},
			{{"ring", "agil rings"}, 30},
			{"agilao gem", 100},
			{"agilao gem", 100},
			{"agilao gem", 100},
			{"bufula gem", 100},
			{"bufula gem", 100},
			{"bufula gem", 100},
			{"garula gem", 100},
			{"garula gem", 100},
			{"garula gem", 100},
			{"zionga gem", 100},
			{"zionga gem", 100},
			{"zionga gem", 100},
			{"psio gem", 100},
			{"psio gem", 100},
			{"psio gem", 100},
			{"freila gem", 100},
			{"freila gem", 100},
			{"freila gem", 100},
			{"vessel 3", 100},
			{"vessel 2", 50},
			{"vessel 2", 20},
			{"vessel 2", 5},
			{"soul 3", 100},
			{"soul 2", 50},
			{"soul 2", 20},
			{"soul 2", 5},
			{"levelcap up", 100},
			{"levelcap up", 100},
			{"levelcap up", 100},
			{"void booster-s 2", 100},
			{"void booster-s 2", 100},
			{"str catalyst 3", 70},
			{"mag catalyst 3", 70},
			{"end catalyst 3", 70},
			{"agi catalyst 3", 70},
			{"luk catalyst 3", 70},
			{"str catalyst 2", 50},
			{"mag catalyst 2", 50},
			{"end catalyst 2", 50},
			{"agi catalyst 2", 50},
			{"luk catalyst 2", 50},
			{"void booster-sr", 100},
			{"void booster-sw", 100},
			{"vr up", 100},
			{"vr up", 100},
		},

		color = SKINCOLOR_AETHER,

		anim_stand = 		{SPR_KNDR, A, 10},
		anim_stand_hurt =	{SPR_KNDR, A, 10},
		anim_move =			{SPR_KNDR, B, C, D, E, F, G, 2},
		anim_run =			{SPR_KNDR, B, C, D, E, F, G, 2},
		anim_hurt =			{SPR_KNDR, L, 20},
		anim_getdown =		{SPR_KNDR, T, 1},
		anim_downloop =		{SPR_KNDR, T, 1},
		anim_getup =		{SPR_KNDR, A, 5},

		anim_special1 =		{SPR_KNDR, K, TICRATE*8},
		anim_special2 =		{SPR_KNDR, H, TICRATE*8},
		anim_special3 =		{SPR_KNDR, I, J, 2},
		anim_special4 = 	{SPR_KNDR, U, TICRATE},			-- guard
		anim_sepcial5 =		{SPR_KNDR, V, TICRATE},			-- howling prep
		anim_special6 =		{SPR_KNDR, W, X, 2},			-- howling

		skills = {"hand sonic", "gale slash", "cruel attack", "toxic slice", "delay", "dekaja", "dekunda"},
		r_exp = 5500,
	},

	["angel_vr_2"] = {
		name = "Angel Replica-0C",
		skillchance = 100,
		level = 50,
		hp = 1000,
		sp = 1000,
		strength = 30,
		magic = 30,
		endurance = 24,
		agility = 20,
		luck = 12,
		melee_natk = "slash_1",
		boss = true,
		nopvp = true,
		block = ATK_PIERCE,

		hudcutin = "REPL_A",

		--thinker = generalEnemyThinker,

		thinker = 	function(mo)
						-- Kanade thinker

						local enemies = mo.enemies
						local btl = server.P_BattleStatus[mo.battlen]

						if mo.status_condition == COND_SILENCE
							mo.use_howling = nil
							return generalEnemyThinker(mo)
						end

						if mo.use_howling
							mo.use_howling = nil	-- Don't forget to undo that.
							return attackDefs["howling-0"], mo.enemies
						end

						-- first 2 turns: always go for harmonics and then hand sonic.
						if btl.turn == 1
							return attackDefs["harmonic-0"], {mo}
						elseif btl.turn == 2
							return attackDefs["hand sonic"], {enemies[P_RandomRange(1, #enemies)]}
						end

						-- make a clone if we're severely outnumbered and that my health is low!!
						if mo.hp < mo.maxhp/2
						and #mo.allies < 3
							return attackDefs["harmonics-0"], {mo}
						end

						-- under other circumstances just use a random attack in our arsenal

						-- Random chance to use distortion: (1/8)
						if not P_RandomRange(0, 7)

							-- before we do, check if our allies aren't using it either, because it will lead to a guaranteed howling:
							for i = 1, #mo.allies
								if mo.allies[i] and mo.allies[i].valid
								and (mo.allies[i].guaranteedevasion or mo.allies[i].use_howling)

									return generalEnemyThinker(mo)	-- well too bad.
								end
							end

							mo.use_howling = true	-- next time we can act for real, use howling!
							return attackDefs["distortion"], {mo}
						end

						return generalEnemyThinker(mo)
					end,

		color = SKINCOLOR_AETHER,

		anim_stand = 		{SPR_KNDR, A, 10},
		anim_stand_hurt =	{SPR_KNDR, A, 10},
		anim_move =			{SPR_KNDR, B, C, D, E, F, G, 2},
		anim_run =			{SPR_KNDR, B, C, D, E, F, G, 2},
		anim_hurt =			{SPR_KNDR, L, 20},
		anim_getdown =		{SPR_KNDR, T, 1},
		anim_downloop =		{SPR_KNDR, T, 1},
		anim_getup =		{SPR_KNDR, A, 5},

		anim_special1 =		{SPR_KNDR, K, TICRATE*8},
		anim_special2 =		{SPR_KNDR, H, TICRATE*8},
		anim_special3 =		{SPR_KNDR, I, J, 2},
		anim_special4 = 	{SPR_KNDR, U, TICRATE},			-- guard
		anim_sepcial5 =		{SPR_KNDR, V, TICRATE},			-- howling prep
		anim_special6 =		{SPR_KNDR, W, X, 2},			-- howling

		skills = {"hand sonic", "gale slash", "cruel attack", "toxic slice", "delay", "dekaja", "dekunda"},
		r_exp = 0,
	},

	["giant_vr_2"] = {
		name = "Emptier Giant",
		skillchance = 80,	-- /100, probability of using a skill
		level = 60,
		hp = 1000,
		sp = 500,
		strength = 40,
		magic = 40,
		endurance = 25,
		luck = 20,
		agility = 25,
		melee_natk = "slash_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_ICE|ATK_NUCLEAR,
		resist = ATK_STRIKE|ATK_FIRE|ATK_WIND|ATK_PIERCE,
		thinker = generalEnemyThinker,

		atk = 300,

		boss = true,
		nopvp = true,
		scale = FRACUNIT*133/100,

		r_drops = {
			{{"series", "nafoie"}, 40},
			{{"series", "nabarta"}, 40},
			{{"series", "nazan"}, 40},
			{{"series", "nazonde"}, 40},
			{{"series", "v2-dion"}, 60},
			{{"series", "v2-dion"}, 60},
			{{"series", "agil"}, 45},
			{{"series", "agil"}, 45},
			{{"ring", "lambda rings"}, 60},
			{{"ring", "lambda rings"}, 60},
			{{"ring", "agil rings"}, 30},
			{{"ring", "agil rings"}, 30},
			{"agidyne gem", 100},
			{"agidyne gem", 100},
			{"agidyne gem", 100},
			{"bufudyne gem", 100},
			{"bufudyne gem", 100},
			{"bufudyne gem", 100},
			{"garudyne gem", 100},
			{"garudyne gem", 100},
			{"garudyne gem", 100},
			{"ziodyne gem", 100},
			{"ziodyne gem", 100},
			{"ziodyne gem", 100},
			{"psiodyne gem", 100},
			{"psiodyne gem", 100},
			{"psiodyne gem", 100},
			{"freidyne gem", 100},
			{"freidyne gem", 100},
			{"freidyne gem", 100},
			{"vessel 3", 100},
			{"vessel 2", 50},
			{"vessel 2", 20},
			{"vessel 2", 5},
			{"soul 3", 100},
			{"soul 2", 50},
			{"soul 2", 20},
			{"soul 2", 5},
			{"levelcap up", 100},
			{"levelcap up", 100},
			{"levelcap up", 100},
			{"levelcap up", 100},
			{"levelcap up", 100},
			{"levelcap up", 100},
			{"void booster-s 1", 100},
			{"void booster-s 1", 100},
			{"void booster-s 1", 100},
			{"str catalyst 3", 70},
			{"mag catalyst 3", 70},
			{"end catalyst 3", 70},
			{"agi catalyst 3", 70},
			{"luk catalyst 3", 70},
			{"str catalyst 2", 50},
			{"mag catalyst 2", 50},
			{"end catalyst 2", 50},
			{"agi catalyst 2", 50},
			{"luk catalyst 2", 50},
			{"void booster-sr", 100},
			{"void booster-sw", 100},
			{"vr up", 100},
			{"vr up", 100},
		},

		r_exp = 6000,
		anim_stand = 		{SPR_ENM2, G, 10},
		anim_stand_hurt =	{SPR_ENM2, G, 1},
		anim_move =			{SPR_ENM2, G, 2},
		anim_run =			{SPR_ENM2, G, 2},
		anim_hurt =			{SPR_ENM2, G, 35},
		anim_getdown =		{SPR_ENM2, G, 1},
		anim_downloop =		{SPR_ENM2, G, 1},
		anim_getup =		{SPR_ENM2, G, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"fatal end", "gigantic fist", "gale slash", "power charge", "diarama", "tempest slash", "dekaja", "dekunda"},
	},

	["sword_vr_2"] = {
		name = "Emptier Sword",
		skillchance = 100,	-- /100, probability of using a skill
		level = 70,
		hp = 1300,
		sp = 1300,
		strength = 46,
		magic = 40,
		endurance = 28,
		luck = 32,
		agility = 35,
		melee_natk = "slash_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_CURSE,
		block = ATK_BLESS,
		drain = ATK_ELEC,
		resist = ATK_FIRE|ATK_SLASH|ATK_STRIKE|ATK_PIERCE,
		repel = ATK_NUCLEAR,
		thinker = generalEnemyThinker,

		atk = 300,

		boss = true,
		nopvp = true,
		scale = FRACUNIT*3/2,

		r_drops = {
			{{"series", "nafoie"}, 40},
			{{"series", "nabarta"}, 40},
			{{"series", "nazan"}, 40},
			{{"series", "nazonde"}, 40},
			{{"series", "v2-dion"}, 60},
			{{"series", "v2-dion"}, 60},
			{{"series", "agil"}, 45},
			{{"series", "agil"}, 45},
			{{"ring", "lambda rings"}, 60},
			{{"ring", "lambda rings"}, 60},
			{{"ring", "agil rings"}, 30},
			{{"ring", "agil rings"}, 30},
			{"agidyne gem", 100},
			{"agidyne gem", 100},
			{"agidyne gem", 100},
			{"bufudyne gem", 100},
			{"bufudyne gem", 100},
			{"bufudyne gem", 100},
			{"garudyne gem", 100},
			{"garudyne gem", 100},
			{"garudyne gem", 100},
			{"ziodyne gem", 100},
			{"ziodyne gem", 100},
			{"ziodyne gem", 100},
			{"psiodyne gem", 100},
			{"psiodyne gem", 100},
			{"psiodyne gem", 100},
			{"freidyne gem", 100},
			{"freidyne gem", 100},
			{"freidyne gem", 100},
			{"vessel 3", 100},
			{"vessel 2", 50},
			{"vessel 2", 20},
			{"vessel 2", 5},
			{"soul 3", 100},
			{"soul 2", 50},
			{"soul 2", 20},
			{"soul 2", 5},
			{"levelcap up", 100},
			{"levelcap up", 100},
			{"levelcap up", 100},
			{"void booster-s 1", 100},
			{"void booster-s 1", 100},
			{"void booster-s 1", 100},
			{"str catalyst 3", 70},
			{"mag catalyst 3", 70},
			{"end catalyst 3", 70},
			{"agi catalyst 3", 70},
			{"luk catalyst 3", 70},
			{"str catalyst 2", 50},
			{"mag catalyst 2", 50},
			{"end catalyst 2", 50},
			{"agi catalyst 2", 50},
			{"luk catalyst 2", 50},
			{"void booster-sr", 100},
			{"void booster-sw", 100},
			{"vr up", 100},
			{"vr up", 100},
		},

		r_exp = 8500,
		anim_stand = 		{SPR_ENM1, I, 10},
		anim_stand_hurt =	{SPR_ENM1, I, 1},
		anim_move =			{SPR_ENM1, I, 2},
		anim_run =			{SPR_ENM1, I, 2},
		anim_hurt =			{SPR_ENM1, I, 35},
		anim_getdown =		{SPR_ENM1, I, 1},
		anim_downloop =		{SPR_ENM1, I, 1},
		anim_getup =		{SPR_ENM1, I, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"tempest slash", "ziodyne", "marakunda", "tarukaja", "kill rush", "dekaja", "dekunda"},
	},

	["eagle_vr_2"] = {
		name = "Emptier Eagle",
		skillchance = 100,	-- /100, probability of using a skill
		level = 80,
		hp = 1712,
		sp = 439,
		strength = 50,
		magic = 50,
		endurance = 42,
		luck = 42,
		agility = 42,
		melee_natk = "pierce_1",	-- enemies don't have crit anims for their attacks.
		weak = ATK_ELEC|ATK_PIERCE,
		block = ATK_WIND,
		resist = ATK_ICE,
		thinker = generalEnemyThinker,

		boss = true,
		nopvp = true,
		scale = FRACUNIT*3/2,

		r_drops = {
			{{"series", "nafoie"}, 40},
			{{"series", "nabarta"}, 40},
			{{"series", "nazan"}, 40},
			{{"series", "nazonde"}, 40},
			{{"series", "awake"}, 60},
			{{"series", "awake"}, 60},
			{{"ring", "lambda rings"}, 60},
			{{"ring", "lambda rings"}, 60},
			{{"ring", "awake rings"}, 30},
			{{"ring", "awake rings"}, 30},
			{"agidyne gem", 100},
			{"agidyne gem", 100},
			{"agidyne gem", 100},
			{"bufudyne gem", 100},
			{"bufudyne gem", 100},
			{"bufudyne gem", 100},
			{"garudyne gem", 100},
			{"garudyne gem", 100},
			{"garudyne gem", 100},
			{"ziodyne gem", 100},
			{"ziodyne gem", 100},
			{"ziodyne gem", 100},
			{"psiodyne gem", 100},
			{"psiodyne gem", 100},
			{"psiodyne gem", 100},
			{"freidyne gem", 100},
			{"freidyne gem", 100},
			{"freidyne gem", 100},
			{"vessel 3", 100},
			{"vessel 2", 50},
			{"vessel 2", 20},
			{"vessel 2", 5},
			{"soul 3", 100},
			{"soul 2", 50},
			{"soul 2", 20},
			{"soul 2", 5},
			{"levelcap up", 100},
			{"levelcap up", 100},
			{"levelcap up", 100},
			{"void booster-s 1", 100},
			{"void booster-s 1", 100},
			{"void booster-s 1", 100},
			{"str catalyst 3", 70},
			{"mag catalyst 3", 70},
			{"end catalyst 3", 70},
			{"agi catalyst 3", 70},
			{"luk catalyst 3", 70},
			{"str catalyst 2", 50},
			{"mag catalyst 2", 50},
			{"end catalyst 2", 50},
			{"agi catalyst 2", 50},
			{"luk catalyst 2", 50},
			{"void booster-sr", 100},
			{"void booster-sw", 100},
			{"vr up", 100},
			{"vr up", 100},
		},

		r_exp = 10000,
		anim_stand = 		{SPR_ENM3, S, 10},
		anim_stand_hurt =	{SPR_ENM3, S, 1},
		anim_move =			{SPR_ENM3, S, 2},
		anim_run =			{SPR_ENM3, S, 2},
		anim_hurt =			{SPR_ENM3, S, 35},
		anim_getdown =		{SPR_ENM3, S, 1},
		anim_downloop =		{SPR_ENM3, S, 1},
		anim_getup =		{SPR_ENM3, S, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"garudyne", "wind amp", "magarula", "mamakakaja", "media", "tentarafoo", "dekaja", "dekunda"},
	},

	["knight_vr_2"] = {
		name = "Emptiest Knight",
		skillchance = 100,	-- /100, probability of using a skill
		level = 90,
		hp = 2021,
		sp = 471,
		strength = 65,
		magic = 57,
		endurance = 45,
		luck = 45,
		agility = 44,
		melee_natk = "pierce_1",	-- enemies don't have crit anims for their attacks.
		repel = ATK_PIERCE,
		drain = ATK_ICE,
		weak = ATK_FIRE,
		thinker = generalEnemyThinker,

		boss = true,
		nopvp = true,
		scale = FRACUNIT*2,

		r_drops = {
			{{"series", "nafoie"}, 40},
			{{"series", "nabarta"}, 40},
			{{"series", "nazan"}, 40},
			{{"series", "nazonde"}, 40},
			{{"series", "freifi"}, 100},
			{{"series", "awake"}, 60},
			{{"series", "awake"}, 60},
			{{"ring", "freifi rings"}, 100},
			{{"ring", "lambda rings"}, 60},
			{{"ring", "lambda rings"}, 60},
			{{"ring", "awake rings"}, 30},
			{{"ring", "awake rings"}, 30},
			{"agidyne gem", 100},
			{"agidyne gem", 100},
			{"agidyne gem", 100},
			{"bufudyne gem", 100},
			{"bufudyne gem", 100},
			{"bufudyne gem", 100},
			{"garudyne gem", 100},
			{"garudyne gem", 100},
			{"garudyne gem", 100},
			{"ziodyne gem", 100},
			{"ziodyne gem", 100},
			{"ziodyne gem", 100},
			{"psiodyne gem", 100},
			{"psiodyne gem", 100},
			{"psiodyne gem", 100},
			{"freidyne gem", 100},
			{"freidyne gem", 100},
			{"freidyne gem", 100},
			{"vessel 3", 100},
			{"vessel 2", 50},
			{"vessel 2", 20},
			{"vessel 2", 5},
			{"soul 3", 100},
			{"soul 2", 50},
			{"soul 2", 20},
			{"soul 2", 5},
			{"levelcap up", 100},
			{"levelcap up", 100},
			{"levelcap up", 100},
			{"void booster-s 1", 100},
			{"void booster-s 1", 100},
			{"void booster-s 1", 100},
			{"void booster-s 1", 100},
			{"str catalyst 3", 70},
			{"mag catalyst 3", 70},
			{"end catalyst 3", 70},
			{"agi catalyst 3", 70},
			{"luk catalyst 3", 70},
			{"str catalyst 2", 50},
			{"mag catalyst 2", 50},
			{"end catalyst 2", 50},
			{"agi catalyst 2", 50},
			{"luk catalyst 2", 50},
			{"void booster-sr", 100},
			{"void booster-sw", 100},
			{"vr up", 100},
			{"vr up", 100},
		},

		r_exp = 15000,
		anim_stand = 		{SPR_ENM1, K, 10},
		anim_stand_hurt =	{SPR_ENM1, K, 1},
		anim_move =			{SPR_ENM1, K, 2},
		anim_run =			{SPR_ENM1, K, 2},
		anim_hurt =			{SPR_ENM1, K, 35},
		anim_getdown =		{SPR_ENM1, K, 1},
		anim_downloop =		{SPR_ENM1, K, 1},
		anim_getup =		{SPR_ENM1, K, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {"torrent shot", "bufudyne", "mabufula", "vile assault", "ice amp", "matarukaja", "dekaja", "dekunda"},
	},

	["reaper_vr"] = {
		name = "Void Reaper",
		skillchance = 100,	-- /100, probability of using a skill
		level = 100,
		hp = 2222,
		sp = 4444,
		strength = 66,
		magic = 66,
		endurance = 66,
		luck = 66,
		agility = 66,
		melee_natk = "strike_1",	-- enemies don't have crit anims for their attacks.
		thinker = generalEnemyThinker,
		boss = true,
		endboss = true,
		nopvp = true,
		scale = FRACUNIT*3/2,

		r_exp = 0,
		anim_stand = 		{SPR_REAP, A, B, C, D, E, F, G, H, I, J, 4},
		anim_stand_hurt = 	{SPR_REAP, A, B, C, D, E, F, G, H, I, J, 4},
		anim_move =			{SPR_REAP, A, B, C, D, E, F, G, H, I, J, 4},
		anim_run =			{SPR_REAP, A, B, C, D, E, F, G, H, I, J, 4},
		anim_hurt =			{SPR_REAP, A, 10},
		anim_getdown =		{SPR_REAP, A, 1},
		anim_downloop =		{SPR_REAP, A, 1},
		anim_getup =		{SPR_REAP, A, 1},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {	"megidola", "megidolaon", "power charge", "mind charge",
					"megaton raid", "vicious strike", "marakunda", "heat riser",
					"marakunda", "masukunda", "matarunda", "maragidyne", "mabufudyne",
					"fire boost", "ice boost", "elec boost", "wind boost", "psy boost", "nuke boost", "bless boost", "curse boost",
					"magarudyne", "maziodyne", "mafreidyne", "mapsiodyne", "tetrakarn", "makarakarn",
					"dekaja", "dekunda"},
	},

	["mnemesis_1"] = {
		name = "Metal Sonic?",
		skillchance = 100,	-- /100, probability of using a skill
		atk = 280,
		level = 91,
		hp = 4500,
		sp = 9999,
		strength = 75,
		magic = 75,
		endurance = 47,
		luck = 45,
		agility = 60,
		melee_natk = "slash_1",	-- enemies don't have crit anims for their attacks.
		weak = 0,
		resist = 0,
		thinker = generalEnemyThinker,
		r_exp = 100000,
		scale = FRACUNIT,
		noroguerandom = true,	-- Don't randomize affinities with rogue mode
		noroguebuff = true,		-- Don't buff with rogue mode
		nopvp = true,

		--target_zoffs = 80,	-- offset for targetting reticle...

		turns = 2,
		boss = true,
		endboss = true,
		finalboss = true,
		--personascale = FRACUNIT*2,

		anim_stand = 		{SPR_MNMS, C, C, C, D, D, D, C, C, C, D, D, D, C, C, C, D, D, D, C, C, C, D, D, D, C, C, C, D, D, D, C, C, C, D, D, D, C, C, C, E, C, E, C, D, D, D, 3},
		anim_move =			{SPR_MNMS, C, C, D, D, 2},
		anim_run =			{SPR_MNMS, C, C, D, D, 2},
		anim_hurt =			{SPR_MNMS, F, 35},
		anim_getdown =		{SPR_MNMS, F, 10},
		anim_downloop =		{SPR_MNMS, F, 10},
		anim_getup =		{SPR_MNMS, F, 10},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {
				"heat riser",
				"debilitate",
				"maragidyne",
				"magarudyne",
				"maziodyne",
				"mabufudyne",
				"mafreidyne",
				"mapsiodyne",
				"maeigaon",
				"makougaon",
				"megidola",
				"debilitate",
				"dekunda",
				"dekaja",
				"mind charge",
				"power charge",
				"pralaya",
				"infinite endure",
			},
	},

	["mnemesis_2"] = {
		name = "???",
		skillchance = 85,	-- /100, probability of using a skill
		atk = 500,
		level = 91,
		hp = 6500,
		sp = 9999,
		strength = 85,
		magic = 85,
		endurance = 55,
		luck = 55,
		agility = 60,
		melee_natk = "mnemesis_patk",	-- enemies don't have crit anims for their attacks.
		atk = 400,
		weak = 0,
		resist = 0,
		r_exp = 100000,
		scale = FRACUNIT*2,
		noroguerandom = true,	-- Don't randomize affinities with rogue mode
		noroguebuff = true,		-- Don't buff with rogue mode

		target_zoffs = 80,	-- offset for targetting reticle...

		turns = 2,
		boss = true,
		endboss = true,
		finalbboss = true,
		nopvp = true,
		--personascale = FRACUNIT*2,

		anim_stand = 		{SPR_MNMS, A, B, 8},
		anim_move =			{SPR_MNMS, A, B, 8},
		anim_run =			{SPR_MNMS, A, B, 8},
		anim_hurt =			{SPR_MNMS, A, 35},
		anim_getdown =		{SPR_MNMS, A, 10},
		anim_downloop =		{SPR_MNMS, A, 10},
		anim_getup =		{SPR_MNMS, A, 10},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {
				"heat riser",
				"debilitate",
				"maragidyne",
				"magarudyne",
				"maziodyne",
				"mabufudyne",
				"mafreidyne",
				"mapsiodyne",
				"maeigaon",
				"makougaon",
				"mahamaon",
				"mamudoon",
				"debilitate",
				"dekunda",
				"dekaja",
				"mind charge",
				"power charge",
				"pralaya",
				"god hand",
				"brave blade",
				"infinite endure",
			},


		thinker =	function(mo)

						mo.thinkturns = $ and $+1 or 1

						if mo.thinkturns == 1
							return attackDefs["dekaja"], mo.enemies
						elseif mo.thinkturns == 2
						or mo.thinkturns%6 == 0
							return attackDefs["overdrive boost"], {mo}
						end

						return generalEnemyThinker(mo)
					end,

	},

	["mnemesis_3"] = {
		name = "???",
		skillchance = 100,	-- /100, probability of using a skill
		atk = 500,
		level = 91,
		hp = 5500,
		sp = 9999,
		strength = 85,
		magic = 85,
		endurance = 55,
		luck = 55,
		agility = 60,
		melee_natk = "mnemesis_patk",	-- enemies don't have crit anims for their attacks.
		weak = 0,
		resist = 0,
		r_exp = 100000,
		scale = FRACUNIT*2,
		noroguerandom = true,	-- Don't randomize affinities with rogue mode
		noroguebuff = true,		-- Don't buff with rogue mode

		target_zoffs = 80,	-- offset for targetting reticle...

		turns = 1,
		boss = true,
		endboss = true,
		finalboss = true,
		nopvp = true,
		--personascale = FRACUNIT*2,

		anim_stand = 		{SPR_MNMS, G, H, I, H, 8},
		anim_move =			{SPR_MNMS, G, H, I, H, 8},
		anim_run =			{SPR_MNMS, G, H, I, H, 8},
		anim_hurt =			{SPR_MNMS, G, 35},
		anim_getdown =		{SPR_MNMS, G, 10},
		anim_downloop =		{SPR_MNMS, G, 10},
		anim_getup =		{SPR_MNMS, G, 10},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.
		skills = {
				"matarukaja",
				"marakukaja",
				"masukukaja",
				"mamakakaja",
			},

	},

	["mnemesis_arm1"] = {
		name = "Arm - A",
		skillchance = 100,	-- /100, probability of using a skill
		atk = 350,
		level = 85,
		hp = 2150,
		sp = 9999,
		strength = 75,
		magic = 75,
		endurance = 50,
		luck = 50,
		agility = 55,
		melee_natk = "mnemesis_patk",	-- enemies don't have crit anims for their attacks.
		weak = 0,
		block = ATK_FIRE|ATK_ICE|ATK_ELEC|ATK_WIND,
		r_exp = 0,
		scale = FRACUNIT*2,
		--noroguerandom = true,	-- Don't randomize affinities with rogue mode
		noroguebuff = true,		-- Don't buff with rogue mode

		target_zoffs = 60,	-- offset for targetting reticle...

		turns = 1,
		boss = true,
		nopvp = true,

		anim_stand = 		{SPR_MNMS, K, L, M, L, 8},
		anim_move =			{SPR_MNMS, K, L, M, L, 8},
		anim_run =			{SPR_MNMS, K, L, M, L, 8},
		anim_hurt =			{SPR_MNMS, K, 35},
		anim_getdown =		{SPR_MNMS, K, 10},
		anim_downloop =		{SPR_MNMS, K, 10},
		anim_getup =		{SPR_MNMS, K, 10},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
												-- unless it's specified like for players.
		skills = {
				"agidyne",
				"bufudyne",
				"ziodyne",
				"garudyne",
				"fire amp",
				"ice amp",
				"elec amp",
				"wind amp",
			},

		deathanim = function(mo)

						mo.deathtimer = $ and $+1 or 1

						local x = P_RandomRange(-64, 64)*FRACUNIT + mo.x
						local y = P_RandomRange(-64, 64)*FRACUNIT + mo.y
						local z = P_RandomRange(96, 256)*FRACUNIT + mo.z

						local a = P_SpawnMobj(x, y, z, MT_DUMMY)
						a.state = S_QUICKBOOM1

						if mo.deathtimer & 1
							S_StartSound(mo, sfx_pop)
						end

						if mo.deathtimer >= 30
							mo.deathanim = nil
							mo.flags2 = $|MF2_DONTDRAW
							return	-- deref function
						end
					end,

	},

	["mnemesis_arm2"] = {
		name = "Arm - B",
		skillchance = 100,	-- /100, probability of using a skill
		atk = 350,
		level = 85,
		hp = 2150,
		sp = 9999,
		strength = 75,
		magic = 75,
		endurance = 50,
		luck = 50,
		agility = 55,
		melee_natk = "mnemesis_patk",	-- enemies don't have crit anims for their attacks.
		weak = 0,
		block = ATK_PSY|ATK_NUCLEAR|ATK_BLESS|ATK_CURSE,
		r_exp = 0,
		scale = FRACUNIT*2,
		--noroguerandom = true,	-- Don't randomize affinities with rogue mode
		noroguebuff = true,		-- Don't buff with rogue mode

		target_zoffs = 60,	-- offset for targetting reticle...

		turns = 1,
		boss = true,
		nopvp = true,

		anim_stand = 		{SPR_MNMS, N, O, P, O, 8},
		anim_move =			{SPR_MNMS, N, O, P, O, 8},
		anim_run =			{SPR_MNMS, N, O, P, O, 8},
		anim_hurt =			{SPR_MNMS, N, 35},
		anim_getdown =		{SPR_MNMS, N, 10},
		anim_downloop =		{SPR_MNMS, N, 10},
		anim_getup =		{SPR_MNMS, N, 10},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
												-- unless it's specified like for players.
		skills = {
				"psiodyne",
				"freidyne",
				"kougaon",
				"eigaon",
				"psy amp",
				"nuke amp",
				"bless amp",
				"curse amp",
			},

		deathanim = function(mo)

						mo.deathtimer = $ and $+1 or 1

						local x = P_RandomRange(-64, 64)*FRACUNIT + mo.x
						local y = P_RandomRange(-64, 64)*FRACUNIT + mo.y
						local z = P_RandomRange(96, 256)*FRACUNIT + mo.z

						local a = P_SpawnMobj(x, y, z, MT_DUMMY)
						a.state = S_QUICKBOOM1

						if mo.deathtimer & 1
							S_StartSound(mo, sfx_pop)
						end

						if mo.deathtimer >= 30
							mo.deathanim = nil
							mo.flags2 = $|MF2_DONTDRAW
							return	-- deref function
						end
					end,

	},

	["alt"] = {
		name = "Alt",
		skillchance = 100,	-- /100, probability of using a skill
		atk = 400,
		level = 99,
		hp = 10000,
		sp = 99999,
		strength = 99,
		magic = 99,
		endurance = 99,
		luck = 99,
		agility = 99,
		melee_natk = "megido",	-- enemies don't have crit anims for their attacks.
		weak = 0,
		resist = 0,
		thinker = generalEnemyThinker,
		r_exp = 1000000,
		noroguerandom = true,	-- Don't randomize affinities with rogue mode
		noroguebuff = true,		-- Don't buff with rogue mode

		target_zoffs = 40,	-- offset for targetting reticle...

		persona = "pixie_alt",
		turns = 2,
		boss = true,
		nopvp = true,
		--endboss = true,
		--personascale = FRACUNIT*2,

		anim_stand = 		{SPR_VALT, A, B, 10},
		anim_stand_hurt =	{SPR_VALT, A, B, 10},
		anim_move =			{SPR_VALT, A, 2},
		anim_run =			{SPR_VALT, A, 2},
		anim_hurt =			{SPR_VALT, C, 35},
		anim_evoker =		{SPR_VALT, D, E, F, 2},		-- holding evoker to head
		anim_evoker_shoot =	{SPR_VALT, D, E, F, 2},		-- shooting evoker
		anim_getdown =		{SPR_VALT, C, 10},
		anim_downloop =		{SPR_VALT, C, 10},
		anim_getup =		{SPR_VALT, C, 10},		-- enemies don't need special standing, death or revive anims.
													-- they explode on death, and cannot be revived.
													-- unless it's specified like for players.

		anim_special1 = 	{SPR_VALT, G, H, 10},
		anim_special2 =		{SPR_VALT, I, 9999},

		skills = {"heat riser", "eigaon", "psiodyne"},

		deathanim = function(mo)

						mo.deathtimer = $ and $+1 or 1

						if mo.deathtimer == 1

							for p in players.iterate do
								if p and p.control and p.control.valid and p.control.battlen == mo.battlen
									S_FadeOutStopMusic(200, p)
								end
							end

							mo.basecoords = {mo.x, mo.y, mo.z}
							mo.flags = $|MF_NOCLIPHEIGHT|MF_NOGRAVITY
							ANIM_set(mo, mo.anim_hurt)

							local cam = server.P_BattleStatus[mo.battlen].cam
							local destx = mo.x + 192*cos(mo.angle)
							local desty = mo.y + 192*sin(mo.angle)
							CAM_goto(cam, destx, desty, mo.z + FRACUNIT*8)
							CAM_angle(cam, R_PointToAngle2(destx, desty, mo.x, mo.y))

						elseif mo.deathtimer < TICRATE*2

							P_TeleportMove(mo, mo.basecoords[1] + P_RandomRange(-4, 4)*FRACUNIT, mo.basecoords[2] + P_RandomRange(-4, 4)*FRACUNIT, mo.basecoords[3] + P_RandomRange(-4, 4)*FRACUNIT)
							mo.anim_time = 0

						elseif mo.deathtimer == TICRATE*2
							P_TeleportMove(mo, mo.basecoords[1], mo.basecoords[2], mo.basecoords[3])
							ANIM_set(mo, mo.anim_special2)
							mo.flags = $ & ~(MF_NOCLIPHEIGHT|MF_NOGRAVITY)

						elseif mo.deathtimer == TICRATE*3
							mo.hp = 1	-- hack
							mo.deathanim = nil
							return	-- deref

						end

					end,

		thinker = 	function(mo)

					-- Alt thinker
					-- This thinker kinda sucks and could maybe use some optimization, but it does its job, I suppose...

					mo.deathanim = true	-- hack since there are isolated cases of this not working?

					local function alt_changePersona(alt, persona, pinch)
						alt.persona = personaList[persona]
						local p = alt.persona
						alt.weak = p.weak or 0
						alt.resist = p.resist or 0
						alt.drain = p.drain or 0
						alt.block = p.block or 0

						-- set skill lists:
						local pskills

						if not pinch
							pskills = {

								["pixie_alt"] = {
									"panta rhei",
									"thunder reign",
									"magarudyne",
									"maziodyne",
									"mind charge",
									"elec boost",
									"wind boost",
									"dekaja",
									"dekunda",
									"patra",
								},

								["alice_alt"] = {
									"evil smile",
									"maeigaon",
									"mudoon",
									"megidolaon",
									"mapsiodyne",
									"trisagion",
									"curse boost",
									"fire boost",
									"psy boost",
									"psiodyne",
									"eigaon",
								},

								["kfrost_alt"] = {

									"ice boost",
									"nuke boost",
									"niflheim",
									"mabufudyne",
									"marakunda",
									"mafreidyne",
									"atomic flare",
								},

								["metatron_alt"] = {

									"hamaon",
									"megaton raid",
									"brave blade",
									"vicious strike",
									"makougaon",
									"kougaon",
									"bless boost",
								},
							}
						else	-- harder moves

							pskills = {

								["pixie_alt"] = {
									"panta rhei",
									"thunder reign",
									"megidolaon",
									"magarudyne",
									"maziodyne",
									"megidolaon",
									"mind charge",
									"elec amp",
									"wind amp",
									"dekaja",
									"dekunda",
									"patra",
								},

								["alice_alt"] = {
									"evil smile",
									"maeigaon",
									"mamudoon",
									"megidolaon",
									"mapsiodyne",
									"trisagion",
									"curse amp",
									"fire amp",
									"psy amp",
									"psiodyne",
									"eigaon",
									"die for me",
									"die for me",
								},

								["kfrost_alt"] = {

									"ice amp",
									"nuke amp",
									"niflheim",
									"mabufudyne",
									"marakunda",
									"mamakanda",
									"masukunda",
									"matarunda",
									"atomic flare",
									"mafreidyne",
								},

								["metatron_alt"] = {

									"mahamaon",
									"megaton raid",
									"brave blade",
									"vicious strike",
									"deathbound",
									"pralaya",
									"god hand",
									"makougaon",
									"bless amp",
								},

							}

						end

						if pskills[persona]
							alt.skills = pskills[persona]
							BTL_splitSkills(alt)
						end


					end

					local enemies = mo.enemies
					local unfortunate_victim = mo.enemies[P_RandomRange(1, #enemies)]

					local btl = server.P_BattleStatus[mo.battlen]
					local lastturn = btl.turnorder[2] ~= mo

					-- in case of 1mores, don't advance the AI, cast random skills with the currently equipped Persona
					if mo.batontouch
						return generalEnemyThinker(mo)
					end

					mo.thinkercalls = $ and $+1 or 1	-- calls for current phase
					mo.totalcalls = $ and $+1 or 1		-- calls for total fight

					mo.phase = $ or 1	-- phase is determined by HP count


					local calls = mo.thinkercalls
					local totalcalls = mo.totalcalls

					-- open the battle with dekaja and heat riser
					if calls == 1
						alt_changePersona(mo, "pixie_alt")
						return attackDefs["dekaja"], enemies

					elseif calls == 2
						return attackDefs["heat riser"], {mo}

					end

					-- MODE 1: HP > 75%
					/*
						In this phase, go soft on the player, do highly telegraphed attacks and only go haywire after 6 turns.
					*/

					if mo.phase == 1

						-- phase shift
						if mo.hp < mo.maxhp*3/4	-- under 75% HP
							alt_changePersona(mo, "pixie_alt")
							mo.phase = 2
							mo.thinkercalls = 3
							if btl.turnorder[2] == mo
								table.remove(btl.turnorder, 2)	-- remove self from turn order if phase shift overlaps, otherwise we'll screw everything over
							end
							return attackDefs["heat riser"], {mo}
						end

						-- turn 1: Metatron phys attacks
						if calls == 3
							alt_changePersona(mo, "metatron_alt")
							return attackDefs["vicious strike"], enemies

						elseif calls == 4
							return attackDefs["megaton raid"], {unfortunate_victim}


						-- turn 2: King Frost ice attacks, marakunda
						elseif calls == 5
							alt_changePersona(mo, "kfrost_alt")
							return attackDefs["niflheim"], {unfortunate_victim}

						elseif calls == 6
							return attackDefs["marakunda"], enemies

						-- turn 3: Alice, Fire + Death

						elseif calls == 7
							alt_changePersona(mo, "alice_alt")
							return attackDefs["trisagion"], {unfortunate_victim}

						elseif calls == 8

							return attackDefs["mudoon"], {unfortunate_victim}

						-- turn 4: Pixie, dekunda, dekaja, prepare for megidolaon next turn.


						elseif calls == 9
							alt_changePersona(mo, "pixie_alt")
							return attackDefs["dekunda"], {mo}

						elseif calls == 10
							return attackDefs["dekaja"], enemies

						-- turn 5: Mind charge megidolaon

						elseif calls == 11
							return attackDefs["mind charge"], {mo}

						elseif calls == 12
							return attackDefs["megidolaon"], enemies

						-- turn 5+: random persona & attacks until 50% HP

						elseif calls > 12

							if (calls%2)
								local personas = {"pixie_alt", "alice_alt", "kfrost_alt", "metatron_alt"}
								alt_changePersona(mo, personas[P_RandomRange(1, #personas)])
							end
							return generalEnemyThinker(mo)
						end

					-- MODE 2: condition bitch
					/*
						In this phase, harass the player with skills that can potential inflict statuses and follow up with skills
						that can gain technical damage off of it, after opening with strong mind charged severe damaging spells
					*/

					elseif mo.phase == 2

						-- phase shift
						if mo.hp < mo.maxhp/2	-- under 50% HP
							alt_changePersona(mo, "pixie_alt")
							mo.phase = 3
							mo.thinkercalls = 3
							if btl.turnorder[2] == mo
								table.remove(btl.turnorder, 2)	-- remove self from turn order if phase shift overlaps, otherwise we'll screw everything over
							end
							return attackDefs["heat riser"], {mo}
						end

						-- Turn 1: Mind Chage -> Panta Rhei
						if calls == 3
							alt_changePersona(mo, "pixie_alt")
							return attackDefs["mind charge"], {mo}

						elseif calls == 4
							return attackDefs["panta rhei"], {unfortunate_victim}

						-- Turn 2: Mabufudyne -> Vicious Strike
						elseif calls == 5
							alt_changePersona(mo, "kfrost_alt")
							return attackDefs["mabufudyne"], enemies

						elseif calls == 6
							alt_changePersona(mo, "metatron_alt")
							return attackDefs["vicious strike"], enemies

						-- Turn 3: Metatron Mahama, Alice Mamudo... yikes!
						elseif calls == 7
							return attackDefs["mahama"], enemies

						elseif calls == 8
							alt_changePersona(mo, "alice_alt")
							return attackDefs["mamudo"], enemies

						-- Turn 4: Mind Charge -> Thunder Reign
						elseif calls == 9
							alt_changePersona(mo, "pixie_alt")
							return attackDefs["mind charge"], {mo}

						elseif calls == 10
							return attackDefs["thunder reign"], {unfortunate_victim}

						-- Turn 5: Maragidyne -> Magarudyne
						elseif calls == 11
							alt_changePersona(mo, "alice_alt")
							return attackDefs["maragidyne"], enemies

						elseif calls == 12
							alt_changePersona(mo, "pixie_alt")
							return attackDefs["magarudyne"], enemies

						-- Turn 6: Mind Charge -> Niflheim
						elseif calls == 13
							alt_changePersona(mo, "pixie_alt")
							return attackDefs["mind charge"], {mo}

						elseif calls == 14
							alt_changePersona(mo, "kfrost_alt")
							return attackDefs["niflheim"], {unfortunate_victim}

						-- Turn 7: Trisagion -> Panta Rhei'
						elseif calls == 15
							alt_changePersona(mo, "alice_alt")
							return attackDefs["trisagion"], {unfortunate_victim}

						elseif calls == 16
							alt_changePersona(mo, "pixie_alt")
							return attackDefs["panta rhei"], {unfortunate_victim}

						-- Turn 8: Dekaja, Dekunda
						elseif calls == 17
							return attackDefs["dekunda"], {mo}
						elseif calls == 18
							return attackDefs["dekaja"], enemies

						-- Turn 9: Mind Charge -> Megidolaon, and then repeat!
						elseif calls == 19
							return attackDefs["mind charge"], {mo}
						elseif calls == 20
							mo.thinkercalls = 3	-- repeat thinker
							return attackDefs["megidolaon"], enemies

						end

					-- Final phase: be ungodly
					elseif mo.phase == 3

						-- Turn 1: Virus Breath -> Blade of Fury
						if calls == 3
							alt_changePersona(mo, "alice_alt")
							return attackDefs["virus breath"], enemies

						elseif calls == 4
							alt_changePersona(mo, "metatron_alt")
							return attackDefs["blade of fury"], enemies

						-- Turn 2: Mahamaon, Mamudoon
						elseif calls == 5
							return attackDefs["mahamaon"], enemies

						elseif calls == 6
							alt_changePersona(mo, "alice_alt")
							return attackDefs["mamudoon"], enemies

						-- Turn 3+: Free wheeling. Change Personas every 2nd turn as usual
						-- Continue the fight like this
						elseif calls > 6

							if (calls%2)
								local personas = {"pixie_alt", "alice_alt", "kfrost_alt", "metatron_alt"}
								alt_changePersona(mo, personas[P_RandomRange(1, #personas)], true)	-- use pinch phase moves
							end
							return generalEnemyThinker(mo)

						end
					end





					alt_changePersona(mo, "alice_alt")
					return generalEnemyThinker(mo)	--attackDefs["mamudoon"], enemies
				end,
	},

}
)

for k, v in pairs(enemyList)
	VFX_freeslotE(k)
end