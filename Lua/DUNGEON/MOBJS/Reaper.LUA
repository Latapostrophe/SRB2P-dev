freeslot("sfx_chain")
sfxinfo[sfx_chain].flags = SF_X4AWAYSOUND|SF_X8AWAYSOUND|SF_NOINTERRUPT

mobjinfo[MT_REAPER] = {
	4022,
	S_REAPER,
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
	MF_PAIN|MF_NOCLIPHEIGHT|MF_NOCLIP|MF_NOGRAVITY,
	S_NULL
}
states[S_REAPER] = {SPR_ENM1, E, -1, nil, 0, 0, S_NULL}

addHook("MobjThinker", function(mo)

	if mo.needdespawn and mo.valid
		P_RemoveMobj(mo)
		return
	end

	if not mo.rt
		mo.rt = 0
	end
	mo.rt = $+1

	if not mo.target
		P_InstaThrust(mo, 0, 0)

		local bestdist = 32765*FRACUNIT
		local bestp

		for p in players.iterate do
			if not server.P_BattleStatus[p.P_party].gameover
			and not server.P_BattleStatus[p.P_party].running
			and p.mo and p.mo.valid
			and not p.mo.spr_nfloor

				if R_PointToDist2(mo.x, mo.y, p.mo.x, p.mo.y) < bestdist
					bestdist = R_PointToDist2(mo.x, mo.y, p.mo.x, p.mo.y)
					bestp = p.mo
				end
			end
		end

		mo.target = bestp
	end

	if not mo.target or not mo.target.valid return end

	if mo.rt < TICRATE*3
		mo.reaperspeed = 10*FRACUNIT
		mo.scale = min(FRACUNIT, $+625)

		if mo.rt == TICRATE*3 -1
		and server.gamemode ~= GM_VOIDRUN
			S_ChangeMusic("REAPER", true)
		end

		for i = 1,13
			local star = P_SpawnMobj(mo.x + P_RandomRange(-60, 60)*FRACUNIT, mo.y + P_RandomRange(-60, 60)*FRACUNIT, mo.z + P_RandomRange(-30, 70)*FRACUNIT, MT_DUMMY)
			star.momz = 20*FRACUNIT
			star.color = SKINCOLOR_RED
			if i%2 == 0
				star.color = SKINCOLOR_BLACK
			end
			star.frame = A|FF_FULLBRIGHT
			star.scale = FRACUNIT/2
		end

		if leveltime%5 == 0

			for i = 1,16

				local dust = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
				dust.angle = ANGLE_90 + ANG1* (22*(i-1))
				P_InstaThrust(dust, dust.angle, 30*FRACUNIT)
				dust.color = SKINCOLOR_RED
				if i%2 == 0
					dust.color = SKINCOLOR_BLACK
				end
				dust.frame = A|FF_FULLBRIGHT
				dust.scale = FRACUNIT/2

			end

			-- darken sectors
			if mapheaderinfo[gamemap].tartarus
			and server.savelights
				for i = 0, 2047
					if sectors[i].lightlevel > 142
						sectors[i].lightlevel = max(142, $-8)
					end
				end
			end
		end
	else

		mo.sprite = SPR_REAP
		mo.frame = (leveltime%60 / 6)

		local caman = R_PointToAngle(mo.x, mo.y)
		local o = P_SpawnMobj(mo.x + 2*cos(caman), mo.y + 2*sin(caman), mo.z, MT_DUMMY)
		o.scale = mo.scale + P_RandomRange(FRACUNIT/9, FRACUNIT/16)
		o.sprite = SPR_REAP
		o.frame = (mo.frame+10) | FF_FULLBRIGHT | FF_TRANS40
		o.tics = 2

		if mo.target

			if server.P_BattleStatus[mo.target.player.P_party].running
			or mo.target.spr_nfloor
				mo.target = nil
				return
			end

			A_HomingChase(mo, mo.reaperspeed, 0)
			if not S_SoundPlaying(mo, sfx_chain)
				S_StartSound(mo, sfx_chain)
			end

			mo.reaperspeed = $ or 10*FRACUNIT	--???
			
			if server.gamemode ~= GM_VOIDRUN
			
				mo.reaperspeed = $ + FRACUNIT /(TICRATE*10)
				if mo.reaperspeed > 25*FRACUNIT
					mo.reaperspeed = 25*FRACUNIT
				end
			end	
		end
	end

end, MT_REAPER)

-- initiating battle with the REAPER
addHook("ShouldDamage", function(mo, s)
	if s and s.type ~= MT_REAPER return end
	if (not s or not s.valid)
	and gamemap ~= srb2p.tartarus_map
		if gamemap == srb2p.tartarus_map
			return true
		end	-- this is for the funny.
		return false
	end

	if not s or not s.valid return end
	if not mo or not mo.valid return false end
	if mo.p_battlebuf return false end

	if server.P_BattleStatus and mo.player.P_party and server.P_BattleStatus[mo.player.P_party].running
	or server.entrytime
	or mo.spr_nfloor
	or mo.player and mo.player.powers[pw_flashing]
	or s and s.valid and s.rt and s.rt < TICRATE*3
		return false
	end

	mo.hit_reaper = s	-- save this so we can remove it if we (somehow) win

	-- select wave:
	local wave = {"reaper_noboss"}
	BTL_start(mo.player.P_party, wave, 2, "BOSS3")
	server.P_BattleStatus[mo.player.P_party].boss = nil	-- allow running away

	mo.p_battlebuf = nil
	mo.readybattle = nil
	D_AwayFromPit(mo.player.P_party)
	return false
end, MT_PLAYER)