freeslot("MT_SHEDEW", "S_SHEDEW", "SPR_XCLA", "MT_SHEDEWSPAWN", "SPR_SSPW", "S_SSPW", "sfx_shadow")

states[S_SHEDEW] = {SPR_ENM1, D, -1, nil, 0, 0, S_NULL}

mobjinfo[MT_SHEDEW] = {
	850,
	S_SHEDEW,
	1000,
	S_SHEDEW,
	sfx_None,
	0,
	sfx_None,
	S_SHEDEW,
	0,
	sfx_None,
	S_NULL,
	S_NULL,
	S_NULL,
	S_NULL,
	sfx_None,
	0,
	32 * FRACUNIT,
	32 * FRACUNIT,
	0,
	100,
	0,
	sfx_None,
	MF_PAIN|MF_SPECIAL|MF_ENEMY|MF_SLIDEME,	-- MF_ENEMY is useful to prevent it from falling on block enemy lines
	S_NULL
}

-- intializes a shadow's wave and its level
rawset(_G, "shadowWaveInit", function(mo, forcewave)

	if not forcewave and not (server.waves or #server.waves) return end
	local wave = forcewave or server.waves[P_RandomRange(1, #server.waves)]

	mo.wave = wave
	-- get the wave's highest level and assign that as the shadow's level
	local lvsum = 0
	for i = 1, #mo.wave
		local en = enemyList[mo.wave[i]]
		if en and en.level
			lvsum = $+en.level
		end
	end

	lvsum = $ / #mo.wave
	mo.level = lvsum
end)

-- gets the "level tier" between the player's level (level1) and the enemy's (level2)
-- returns a value between -2 and 2

-- -2: Enemy is 11+ levels below the player (no threat)
-- -1: Enemy is 6 to 10 levels below the player (easy)
-- 0: Enemy is 5 levels below to 5 levels above the player (even fight)
-- 1: Enemy is 6+ levels above the player (Warning)
-- 2: Enemy is 11+ levels above the player (Danger)

rawset(_G, "DNG_getLevelTier", function(level1, level2)
	return min(2, max(-2, (level2 - level1)/5))
end)

-- shadow collides with spikes: a hacky fix:
local function shadow_spike_collide(mo, sp)
	if sp and sp.valid and sp.type == MT_SPIKE
		return false	-- spoiler alert: they can go right through em!
	end
end

addHook("MobjCollide", shadow_spike_collide, MT_SHEDEW)
addHook("MobjMoveCollide", shadow_spike_collide, MT_SHEDEW)

addHook("MobjThinker", function(mo)

	mo.shadowflags = $ or 0

	if mo.needdespawn and mo.valid
		P_RemoveMobj(mo)
		return
	end

	if mo.notarget return end

	if mo.spawnpoint and mo.spawnpoint.valid and mo.spawnpoint.options & 4	-- special
		return	-- don't move!
	end

	if mo.shadowflags & SHF_STRONG	-- make strong shadows flash
		redShadowGlow(mo)
	end

	if mo.shadowflags & SHF_GOLD
		goldShadowGlow(mo)
	end

	-- scale:
	if not DNG_isTartarusMap()
	or mo.shadowflags & SHF_STRONG
		if mo.cusval == 0
			mo.scale = $*16/10
			mo.cusval = 1
		end
	end

	local frame_anims = {}
	if server.cdungeon
		frame_anims = {
			server.cdungeon.shadowframes_stop,
			server.cdungeon.shadowframes_move,
		}

	elseif DNG_shadowSprites and DNG_shadowSprites[gamemap]
		frame_anims = {
			DNG_shadowSprites[gamemap][1],
			DNG_shadowSprites[gamemap][2]
		}
	end

	if server.entrytime

		if frame_anims and frame_anims[1]
			ANIM_set(mo, frame_anims[1], true)
		end
		ANIM_handle(mo, true)
		return
	end

	if mo.fuse and mo.fuse > 1
		return
	end

	-- init shadow wave
	if not mo.wave
		shadowWaveInit(mo)
	end

	-- make shadows flee
	if mo.shadowflags & SHF_RUNAWAY

		if not mo.fleeangle
			mo.fleeangle = P_RandomRange(1, 359)*ANG1
			mo.fleetimer = TICRATE -10
		end

		mo.fleetimer = $-1
		P_InstaThrust(mo, mo.angle, FRACUNIT*12)

		if mo.fleetimer < 10
			local tflag = max(1, 10 - mo.fleetimer) <<FF_TRANSSHIFT
			mo.frame = ($ & ~FF_TRANSMASK) |tflag
		end

		if not mo.fleetimer
			P_RemoveMobj(mo)
		end
		return
	end

	if mo.fight
		P_InstaThrust(mo, 0, 0)
		return
	end

	if not mo.target
	and not mo.notarget

		local range = 496
		if not (mo.shadowflags & SHF_GOLD|SHF_STRONG)
		and server.gentype == GEN_DARK
			range = $/4
		end

		A_Look(mo, (range<<16)+0, 0)
		if mo.shadowflags & SHF_GOLD
			A_Look(mo, (256<<16)+1, 0)	-- gold shadows also look all around in a more limited fashion
		end

		-- don't target spectators.
		if mo.target and mo.target.player and mo.target.player.P_spectator
			mo.target = nil
		end

		mo.ttime = 0
	end

	if mo.target and mo.target.valid and mo.target.battlen
	and server.P_BattleStatus[mo.target.battlen] and server.P_BattleStatus[mo.target.battlen].running return end

	if mo.target
	and (not P_CheckSight(mo, mo.target))
	or mo.target and mo.target.spr_nfloor
	or mo.target and mo.target.player and mo.target.player.powers[pw_flashing]
		mo.target = nil
	end

	if P_IsObjectOnGround(mo)
	and not (mo.fuse and mo.fuse > 0)
		if not mo.target
			if not mo.notarget
				if not mo.movetimer

					mo.angle = P_RandomRange(0, 359)*ANG1
					mo.movetimer = P_RandomRange(3*TICRATE, 6*TICRATE)
					if frame_anims and frame_anims[2]
						ANIM_set(mo, frame_anims[2], true)
					end

				else
					if mo.movetimer > TICRATE*2/3
						P_InstaThrust(mo, mo.angle, 2*FRACUNIT)
					else
						P_InstaThrust(mo, 0, 0)
						if frame_anims and frame_anims[1]
							ANIM_set(mo, frame_anims[1], true)
						end
					end
					mo.movetimer = $ - 1
				end

				-- don't be suicidal:
				if mo.momx or mo.momy

					-- check where we're gonna end up...
					local ts = R_PointInSubsector(mo.x + mo.momx*4, mo.y + mo.momy*4)
					ts = #ts.sector +1

					if server.map and (server.map[ts] == T_PIT or server.map[ts] == T_SPIKES)
						P_InstaThrust(mo, 0, 0)
						mo.movetimer = 0
					end
				end
			end
		else

			mo.ttime = $ + 1

			if mo.ttime == 1
				S_StartSound(mo, sfx_shadow)
				emotionBubble(mo, mo.shadowflags & SHF_GOLD and EMOTE_SURPRISED or EMOTE_EXCLAMATION)
			end

			if mo.ttime > (mo.shadowflags & SHF_GOLD and 5 or 20)

				A_HomingChase(mo, 14*FRACUNIT, 0)

				if mo.shadowflags & SHF_GOLD	-- gold shadows run away!!
					mo.momx = $*(-1)
					mo.momy = $*(-1)
					mo.angle = R_PointToAngle2(0, 0, mo.momx, mo.momy)
				end

				mo.momz = 0

				if DNG_isTartarusMap()
					mo.z = max(-8*FRACUNIT, mo.floorz)
				end
			end
		end
	end

	-- big dumb dumb.......
	local s = #mo.subsector.sector +1

	if server.map and server.map[s] and server.map[s] == T_PIT	-- pit
	and mo.z <= -8*FRACUNIT
	and not mo.notarget

		S_StartSound(mo, sfx_s3k51)

		-- in voidrun, golden shadows that fall in pits from player influence increment the counter!
		if server.gamemode == GM_VOIDRUN
		and server.P_DungeonStatus
		and server.P_DungeonStatus.VR_type == VC_HUNT
			if mo.shadowflags & SHF_GOLD
			and mo.target and mo.target.valid
				server.P_DungeonStatus.VR_score = $+1
			end
		end

		-- fall to your death.
		mo.notarget = true
		mo.target = nil
		emotionBubble(mo, EMOTE_SURPRISED)

		mo.momx = $/2
		mo.momy = $/2
		mo.fuse = TICRATE
		mo.flags = $|MF_NOCLIPTHING
		mo.flags = $ & ~(MF_PAIN|MF_ENEMY)

	end

	ANIM_handle(mo, true)

	if server.map and server.map[s] and server.map[s] == T_SPIKES	-- spikes!
	and mo.z <= 0
	and not mo.notarget
		S_StartSound(mo, sfx_srip)
		explodeShadow(mo)		-- directed by micheal bay

		mo.flags = $|MF_NOCLIPTHING|MF_NOGRAVITY
		mo.flags = $ & ~(MF_PAIN|MF_ENEMY)
		mo.flags2 = $|MF2_DONTDRAW	-- make it invisible
		mo.notarget = true
		mo.target = nil
	end

end, MT_SHEDEW)

-- @TODO: NORMALIZE THIS!!

-- initiating battle with tartarus shadow...
-- This here is a bit hackier than usual
addHook("ShouldDamage", function(mo, s)
	if s and s.type ~= MT_SHEDEW return end
	if not s or not s.valid return end
	if not mo or not mo.player return end

	if s.scared or (s.fuse and s.fuse > 0)
	or (server.P_DialogueStatus and server.P_DialogueStatus[mo.player.P_party].running)
		return false
	end

	local special = s.spawnpoint and s.spawnpoint.valid and s.spawnpoint.options & 4	-- mtf_special

	if mo.player and mo.player.P_spectator
	or server.P_BattleStatus[mo.player.P_party].running
	or (server and server.entrytime)
	or mo.spr_nfloor
	or mo.startbattle
	or mo.d_battlebuf
	or mo.player and mo.player.powers[pw_flashing]
	or mo.player.SRB2PSTASIS
		return false
	end

	mo.readybattle = {}

	local wave = s.wave

	-- start battle
	local team_1 = server.plentities[mo.player.P_party]
	local team_2 = {}
	for i = 1,#wave
		local enm = P_SpawnMobj(0, 0, 0, MT_PFIGHTER)
		enm.state = S_PLAY_STND
		enm.tics = -1
		enm.enemy = wave[i]
		if s.shadowflags & SHF_STRONG
			if i == 1
			or P_RandomRange(0, 1)
				enm.extra = 1
			end
		end

		if s.shadowflags & SHF_GOLD
			-- guaranteed full gold wave!
			enm.gold = 1
		end

		team_2[#team_2+1] = enm
	end

	-- determine advantage:
	local adv = 0
	local mus = MUS_PlayRandomBattleMusic("mus_battle")		--"BATL1"

	s.ttime = $ or 0

	local lenience_time = 20
	if s.shadowflags & SHF_GOLD
		lenience_time = 7
	end

	-- case 1: we were juming
	if mo.player.pflags & PF_JUMPED
	or mo.player.dashmode > TICRATE*3	-- also works
		-- 1-1: the enemy had spotted us, don't do anything, this is a battle with no advantage
		-- 1-2: the enemy didn't spot us, so the player gets the advantage
		if s.ttime <= lenience_time
			adv = 1	-- 1: advantage player
			mus = MUS_PlayRandomBattleMusic("mus_battle_pa")
		end
	else	-- case 2: we weren't jumping.
		-- 2-1: the enemy hasn't spotted us, don't do anything, there's no advantage.
		-- 2-2: the enemy had spotted us, we're in a pinch now!
		if s.ttime > lenience_time
		and not special	-- don't care.
		and not (s.shadowflags & SHF_GOLD)	-- gold shadows run away, so who cares!!
			adv = 2
			mus = MUS_PlayRandomBattleMusic("mus_battle_ea")
		end
	end

	if s.shadowflags & SHF_STRONG
		mus = MUS_PlayRandomBattleMusic("mus_battle_s")
	end

	local applymomz = P_IsObjectOnGround(mo) or mo.momz > 0

	mo.momx = -mo.momx /5
	mo.momy = -mo.momy /5
	mo.momz = abs(mo.momz) > FRACUNIT*8 and abs($)/2 or FRACUNIT*4

	mo.state = S_PLAY_FALL

	if not adv or adv == 1	-- player advantage / normal
		s.momx = mo.momx/5
		s.momy = mo.momy/5
		if applymomz
			s.momz = mo.momz or FRACUNIT*4
		end

		if adv == 1	-- padvan
			emotionBubble(s, EMOTE_SURPRISED)
		end
		-- Make the player play appropriate encounter vfx(if they have it defined)
		if adv == 1
			VFX_Play(mo, VFX_TARTARUS_ADVANTAGE)
		else
			VFX_Play(mo, VFX_TARTARUS_ENCOUNTER)
		end

	elseif adv == 2
		local oldang = mo.angle
		P_DoPlayerPain(mo.player)	-- youch!
		mo.momx = s.momx/4
		mo.momy = s.momy/4
		mo.momz = $/4
		s.momx = -mo.momx
		s.momy = -mo.momy
		s.momz = -mo.momz

		emotionBubble(mo, EMOTE_SURPRISED)
		-- Make the player play appropriate encounter vfx(if they have it defined)
		VFX_Play(mo, VFX_TARTARUS_AMBUSHED)
	end

	S_StartSound(mo, sfx_phys)
	S_StartSound(mo, sfx_susp)

	for p in players.iterate do
		if p and p.mo and p.mo.valid and p.P_party and mo.player.P_party == p.P_party
			p.mo.p_battlebuf = true
		end
	end

	local h = P_SpawnMobj(mo.x, mo.y, mo.z - FRACUNIT*64, MT_DUMMY)
	h.state = S_HURTB1
	h.scale = FRACUNIT*4 + P_RandomRange(-FRACUNIT/4, FRACUNIT/2)
	h.eflags = $ | MFE_VERTICALFLIP*P_RandomRange(0, 1)

	s.fuse = TICRATE*2

	mo.readybattle = {
		pn = mo.player.P_party,
		t1 = team_1,
		t2 = shuffleTable(team_2),
		advantage = adv,
		func = nil,
		music = mus,
		mo1 = mo,
		mo2 = s,
		timer = netgame and TICRATE*3/2 or 5,
	}

	--BTL_StartBattle(mo.player.P_party, team_1, team_2, adv, nil, mus)

	-- you know what? remove the enemy!
	/*if s and s.valid
		P_RemoveMobj(s)
	end*/

	return false
end, MT_PLAYER)