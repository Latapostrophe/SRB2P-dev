freeslot("MT_FOGSHADOW", "S_FOGSHADOW", "SPR_FMAY")

mobjinfo[MT_FOGSHADOW] = {
	851,
	S_FOGSHADOW,
	1000,
	S_FOGSHADOW,
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
	MF_PAIN|MF_SPECIAL|MF_ENEMY|MF_NOGRAVITY|MF_SLIDEME,	-- MF_ENEMY is useful to prevent it from falling on block enemy lines
	S_NULL
}

states[S_FOGSHADOW] = {SPR_FMAY, A, -1, nil, 0, 0, S_FOGSHADOW}

-- shadow collides with spikes: a hacky fix:
local function shadow_spike_collide(mo, sp)
	if sp and sp.valid and sp.type == MT_SPIKE
		return false	-- spoiler alert: they can go right through em!
	end
end

addHook("MobjCollide", shadow_spike_collide, MT_FOGSHADOW)
addHook("MobjMoveCollide", shadow_spike_collide, MT_FOGSHADOW)

addHook("MobjThinker", function(mo)

	mo.shadowflags = $ or 0
	if not mo.sinit
		mo.sinit = true
		mo.z = $+ 64*FRACUNIT	-- they float!
		mo.spawnz = mo.z
	end

	if mo.needdespawn and mo.valid
		P_RemoveMobj(mo)
		return
	end

	if mo.notarget return end

	if mo.spawnpoint and mo.spawnpoint.valid and mo.spawnpoint.options & 4	-- special
		return	-- don't move!
	end

	if mo.shadowflags & SHF_STRONG	-- make strong shadows flash
		mo.scale = FRACUNIT*128/100
		redShadowGlow(mo)
	end

	if mo.shadowflags & SHF_GOLD
		goldShadowGlow(mo)
	end

	if server.entrytime

		if server.cdungeon and server.cdungeon.shadowframes_float
			ANIM_set(mo, server.cdungeon.shadowframes_float, true)
		end
		ANIM_handle(mo, true)
		return
	end

	if mo.fuse and mo.fuse > 1
		return
	end

	-- make shadows flee
	if mo.shadowflags & SHF_RUNAWAY

		if not mo.fleeangle
			mo.fleeangle = P_RandomRange(1, 359)*ANG1
			mo.fleetimer = TICRATE -10
		end

		mo.fleetimer = $-1
		P_InstaThrust(mo, mo.angle, FRACUNIT*12)
		mo.momz = 0

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
		mo.momz = 0
		return
	end

	if not mo.target
		if not mo.notarget

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

		if mo.z < mo.spawnz
			mo.momz = FRACUNIT*2
		else
			mo.momz = $/2
		end
	end

	if mo.target and mo.target.valid and mo.target.battlen
	and server.P_BattleStatus[mo.target.battlen] and server.P_BattleStatus[mo.target.battlen].running return end

	if mo.target
	and (not P_CheckSight(mo, mo.target))
	or mo.target and mo.target.spr_nfloor
	or mo.target and mo.target.player and mo.target.player.powers[pw_flashing]
		mo.target = nil
	end

	--if P_IsObjectOnGround(mo)
	if not (mo.fuse and mo.fuse > 0)

		if not mo.movetimer
			mo.momx = $/2
			mo.momy = $/2
		end	-- fake friction

		if not mo.target
			if not mo.notarget
				if not mo.movetimer

					mo.angle = P_RandomRange(0, 359)*ANG1
					mo.movetimer = P_RandomRange(3*TICRATE, 6*TICRATE)
				else
					if mo.movetimer > TICRATE*2/3
						P_InstaThrust(mo, mo.angle, 2*FRACUNIT)
					else
						P_InstaThrust(mo, 0, 0)
					end
					mo.movetimer = $ - 1
				end
			end
		else

			mo.ttime = $ + 1

			if mo.ttime == 1
				S_StartSound(mo, sfx_shadow)
				emotionBubble(mo, mo.shadowflags & SHF_GOLD and EMOTE_SURPRISED or EMOTE_EXCLAMATION)
			end

			if mo.ttime > (mo.shadowflags & SHF_GOLD and 5 or 20)

				A_HomingChase(mo, 12*FRACUNIT, 0)	-- slightly slower

				if mo.shadowflags & SHF_GOLD	-- gold shadows run away!!
					mo.momx = $*(-1)
					mo.momy = $*(-1)
					mo.momz = $*(-1)
					mo.angle = R_PointToAngle2(0, 0, mo.momx, mo.momy)
				end
				-- don't hug the floor
				if mo.z <= mo.floorz + FRACUNIT*32
				and mo.momz < 0
					mo.momz = 0
				end
				-- don't hug the ceiling either
				if mo.z >= mo.ceilingz - FRACUNIT*192
				and mo.momz > 0
					mo.momz = 0
				end
			end
		end
	end

	-- they're unaffected by tartarus' hazards!
	-- (Because they fly, AND they're fog)
	ANIM_handle(mo, true)

end, MT_FOGSHADOW)

-- @TODO: NORMALIZE THIS!!

-- initiating battle with tartarus shadow...
-- This here is a bit hackier than usual
addHook("ShouldDamage", function(mo, s)
	if s and s.type ~= MT_FOGSHADOW return end
	if not s or not s.valid return end

	if s.scared or (s.fuse and s.fuse > 0)
	or (server.P_DialogueStatus and server.P_DialogueStatus.running)
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
		return false
	end

	mo.readybattle = {}

	local wave
	--if mapheaderinfo[gamemap].tartarus	-- tartarus uses special kind of waves, it needs its own table since it's pretty long
		wave = server.waves[P_RandomRange(1, #server.waves)]
	/*else	-- for other dungeons
		local wave_sets = DNG_dungeonwaves[gamemap][server.P_DungeonStatus.section]
		wave = wave_sets[P_RandomRange(1, #wave_sets)]
	end*/

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