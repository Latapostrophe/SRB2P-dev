-- small lump that handles the loading of PVP battles.

-- by the time this is loaded, Dungeon_Handler.LUA has already spawned our player entities, we are then free to begin a battle!

-- @TODO: Probably make this into a rawset function and load it into a single ThinkFrame for optimization, though I doubt it will change much

addHook("ThinkFrame", do
	if not server return end
	if leveltime ~= TICRATE*3 return end
	if server.gamemode ~= GM_PVP return end	-- doesn't concern me

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
		server.P_BattleStatus[i].arena_coords[1] = center.x	-- + shiftx*(i-1)
		server.P_BattleStatus[i].arena_coords[2] = center.y	-- + shifty*(i-1)
		server.P_BattleStatus[i].arena_coords[3] = center.z
		server.P_BattleStatus[i].arena_coords[4] = center.angle
		--dprint("Succesfully set new arena coordinates!")
	end

	local team_1 = server.plentities[1]
	local team_2 = server.plentities[2]	-- use the second playerentities team as battle.

	--for i = 1, #server.playerlist[2]	-- add plist 2 into plist 1, to let em see and hear the battle~
	--	server.playerlist[1][#server.playerlist[1] +1] = server.playerlist[2][i]
	--end

	-- now initiate the battle between those two teams
	BTL_StartBattle(1, team_1, team_2, 0, nil, MUS_PlayRandomBattleMusic("mus_battle_pvp"))
	local btl = server.P_BattleStatus[1]
	btl.items = {{"chewing soul", 4}, {"hyperring", 2}, {"hypercombiring", 1}, {"me patra gem", 4}, {"1up", 1}}
	if server.pvpmode ~= PVP_BOSSMODE 
		btl.items2 = {{"chewing soul", 4}, {"hyperring", 2}, {"hypercombiring", 1}, {"me patra gem", 4}, {"1up", 1}}
	else
		btl.items = {{"soma", 1}, {"chewing soul", 4}, {"hyperring", 4}, {"hypercombiring", 2}, {"me patra gem", 4}, {"1up", 4}, {"homunculus", 1}}
		btl.items2 = {}
	end

	-- see BTL_mainHandler for this party trick~
	-- We'll basically be swapping these in and out depending on which party is taking their turn.

	-- treat the player as a boss AND a final boss
	-- thisll make for a dramatic finish, its cool
	if server.pvpmode == PVP_BOSSMODE
		for _,mo in ipairs(btl.fighters)
			if mo.control.tempboss				
				
				if mo.control.bossselect
					mo.enemy = server.bosslist[mo.control.bossselect]
				else
					mo.enemy = server.bosslist[P_RandomRange(1, #enemies)]
				end	
				mo.penemy = true
				mo.state = S_PLAY_STND
				mo.tics = -1

				local enemy = enemyList[mo.enemy]
				mo.level = enemy.level or 90
				mo.maxhp, mo.hp = enemy.hp, enemy.hp
				mo.maxsp, mo.sp = enemy.sp, enemy.sp
				mo.skills = enemy.skills or {"agidyne", "makakaja", "mind charge", "power charge", "makarakarn", "triple down"}
				mo.strength, mo.magic, mo.endurance, mo.agility, mo.luck = enemy.strength, enemy.magic, enemy.endurance, enemy.agility, enemy.luck
				mo.weak = enemy.weak or 0
				mo.repel = enemy.repel or 0
				mo.resist = enemy.resist or 0
				mo.block = enemy.block or 0
				mo.drain = enemy.drain or 0
				mo.boss = true
				mo.endboss = true
				mo.finalboss = true
				mo.melee = enemy.melee_natk or "strike_1"
				mo.atk = enemy.atk or mo.level*2
				mo.acc = enemy.acc or 95
				mo.crit = enemy.crit or 2
				mo.escale = enemy.scale or FRACUNIT

				BTL_initEnemyAnimsPlayer(mo)
				BTL_readybuffs(mo)
				BTL_splitSkills(mo)
						
				mo.enemy = nil				
				mo.control.tempboss = nil
					
				-- Buff Skills
				--BTL_balanceSkills(mo)
			end
		end
	end
	
	-- give all fighters 8 random skills and a random melee skill
	-- this is very funny i promise
	if server.pvpmode == PVP_RANDSKILLS
		for _,mo in ipairs(btl.fighters)
			mo.skills = {}
			for i = 1, 8
				mo.skills[i] = getRandMove(mo, true, true)
			end
				
			local melee_natk = getRandMove(mo)
			mo.attack = BTL_setAttack(mo, attackDefs[melee_natk])
			mo.melee = melee_natk
			
			-- Check Passives
			BTL_splitSkills(mo)
		end
	end
	
	-- We'll just save this into the btl incase we need to check this later
	if server.pvpmode
		server.P_BattleStatus[1].pvp_mode = server.pvpmode
		server.pvpmode = nil
	end

	btl.emeraldpow_max = 0
end)