-- Attack defs

-- does a quick forward dash for mo relative to start time and time.
rawset(_G, "forwardcharge", function(mo, start, time, sprite, frame)

	if time == start
		mo.fakeself = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
		mo.fakeself.angle = mo.angle
		mo.fakeself.scale = mo.scale
		mo.fakeself.color = mo.color
		mo.fakeself.fuse = 8
		if mo.skin
			mo.fakeself.skin = mo.skin
		end
		mo.fakeself.sprite = (sprite~=nil and sprite+1 or $+1)-1
		mo.fakeself.frame = (frame~=nil and frame+1 or $+1)-1
		mo.flags2 = $|MF2_DONTDRAW
		P_InstaThrust(mo.fakeself, mo.angle, 16<<FRACBITS)
	elseif time == start+4
		P_InstaThrust(mo.fakeself, mo.angle, -(16<<FRACBITS))
	elseif time == start+8
		if mo.hp
			mo.flags2 = $ & ~MF2_DONTDRAW
		end
		if mo.fakeself and mo.fakeself.valid
			P_RemoveMobj(mo.fakeself)
			mo.fakeself = nil
		end
	end

	if mo and mo.fakeself and mo.fakeself.valid and mo.thinkframe
		if mo.enemy
			enemyList[mo.enemy].thinkframe(mo.fakeself)
		end
	end
end)

rawset(_G, "localquake", function(n, intensity, duration)
	if consoleplayer.maincontrol and consoleplayer.maincontrol.valid
	and consoleplayer.maincontrol.battlen == n
		P_StartQuake(intensity, duration)
	end
end)

-- anims are executed each tic after the attack has been casted, and is passed with 4 arguments
	--^ mobj_t 				caster
	--^ table  [mobj_t] 	targets (contains all objects originally targetted by the attack)
	--^ table  [mobj_t]		hittargets (contains all objects supposed to be DAMAGED by the attack)
	--^ int					timer (a timer that increments by 1 every new frame. use it to make nicely timed animation)


-- anims do stuff and end when they return true.

rawset(_G, "attackDefs", {

	["fire break"] = {
		name = "Fire Break",
		type = ATK_SUPPORT,
		costtype = CST_SP,
		cost = 15,
		desc = "Lower all enemies's Fire \nresistanceto average \nfor 3 turns.",
		target = TGT_ALLENEMIES,
		debuff = true,

		anim = function(mo, targets, hittargets, timer)

			for i = 1, #hittargets
				local target = hittargets[i]

				local time = timer - (i-1)*6

				if time == 20
					playSound(mo.battlen, sfx_debuff)
					local orb = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					orb.sprite = SPR_DBUF
					orb.frame = A|TR_TRANS30
					orb.scale = FRACUNIT*2
					orb.scalespeed = FRACUNIT/32
					orb.destscale = FRACUNIT/6
					orb.tics = 2*TICRATE-15
					orb.color = SKINCOLOR_RED

				elseif time == 5+2*TICRATE
					buffStat(target, ATK_FIRE, -1)	-- negative values lower a stat
					playSound(mo.battlen, sfx_bufu6)
					for i = 1, 64
						local m = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
						m.sprite = SPR_THOK
						m.frame = A
						m.tics = TICRATE
						m.fuse = TICRATE
						m.destscale = 1
						m.color = SKINCOLOR_RED
						m.flags = MF_NOCLIPTHING|MF_NOCLIPHEIGHT
						m.momx = P_RandomRange(-64, 64)*FRACUNIT
						m.momy = P_RandomRange(-64, 64)*FRACUNIT
						m.momz = P_RandomRange(0, 64)*FRACUNIT
					end
				end
			end

			if timer == TICRATE*3 + (#hittargets-1)
				return true
			end
		end,
	},

	["ice break"] = {
		name = "Ice Break",
		type = ATK_SUPPORT,
		costtype = CST_SP,
		cost = 15,
		desc = "Lower all enemies's Ice \nresistanceto average \nfor 3 turns.",
		target = TGT_ALLENEMIES,
		debuff = true,

		anim = function(mo, targets, hittargets, timer)

			for i = 1, #hittargets
				local target = hittargets[i]

				local time = timer - (i-1)*6

				if time == 20
					playSound(mo.battlen, sfx_debuff)
					local orb = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					orb.sprite = SPR_DBUF
					orb.frame = A|TR_TRANS30
					orb.scale = FRACUNIT*2
					orb.scalespeed = FRACUNIT/32
					orb.destscale = FRACUNIT/6
					orb.tics = 2*TICRATE-15
					orb.color = SKINCOLOR_CYAN

				elseif time == 5+2*TICRATE
					buffStat(target, ATK_ICE, -1)	-- negative values lower a stat
					playSound(mo.battlen, sfx_bufu6)
					for i = 1, 64
						local m = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
						m.sprite = SPR_THOK
						m.frame = A
						m.tics = TICRATE
						m.fuse = TICRATE
						m.destscale = 1
						m.color = SKINCOLOR_CYAN
						m.flags = MF_NOCLIPTHING|MF_NOCLIPHEIGHT
						m.momx = P_RandomRange(-64, 64)*FRACUNIT
						m.momy = P_RandomRange(-64, 64)*FRACUNIT
						m.momz = P_RandomRange(0, 64)*FRACUNIT
					end
				end
			end

			if timer == TICRATE*3 + (#hittargets-1)
				return true
			end
		end,
	},

	["wind break"] = {
		name = "Wind Break",
		type = ATK_SUPPORT,
		costtype = CST_SP,
		cost = 15,
		desc = "Lower all enemies's Wind \nresistanceto average \nfor 3 turns.",
		target = TGT_ALLENEMIES,
		debuff = true,

		anim = function(mo, targets, hittargets, timer)

			for i = 1, #hittargets
				local target = hittargets[i]

				local time = timer - (i-1)*6

				if time == 20
					playSound(mo.battlen, sfx_debuff)
					local orb = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					orb.sprite = SPR_DBUF
					orb.frame = A|TR_TRANS30
					orb.scale = FRACUNIT*2
					orb.scalespeed = FRACUNIT/32
					orb.destscale = FRACUNIT/6
					orb.tics = 2*TICRATE-15
					orb.color = SKINCOLOR_EMERALD

				elseif time == 5+2*TICRATE
					buffStat(target, ATK_WIND, -1)	-- negative values lower a stat
					playSound(mo.battlen, sfx_bufu6)
					for i = 1, 64
						local m = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
						m.sprite = SPR_THOK
						m.frame = A
						m.tics = TICRATE
						m.fuse = TICRATE
						m.destscale = 1
						m.color = SKINCOLOR_EMERALD
						m.flags = MF_NOCLIPTHING|MF_NOCLIPHEIGHT
						m.momx = P_RandomRange(-64, 64)*FRACUNIT
						m.momy = P_RandomRange(-64, 64)*FRACUNIT
						m.momz = P_RandomRange(0, 64)*FRACUNIT
					end
				end
			end

			if timer == TICRATE*3 + (#hittargets-1)
				return true
			end
		end,
	},

	["elec break"] = {
		name = "Elec Break",
		type = ATK_SUPPORT,
		costtype = CST_SP,
		cost = 15,
		desc = "Lower all enemies's Elec \nresistanceto average \nfor 3 turns.",
		target = TGT_ALLENEMIES,
		debuff = true,

		anim = function(mo, targets, hittargets, timer)

			for i = 1, #hittargets
				local target = hittargets[i]

				local time = timer - (i-1)*6

				if time == 20
					playSound(mo.battlen, sfx_debuff)
					local orb = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					orb.sprite = SPR_DBUF
					orb.frame = A|TR_TRANS30
					orb.scale = FRACUNIT*2
					orb.scalespeed = FRACUNIT/32
					orb.destscale = FRACUNIT/6
					orb.tics = 2*TICRATE-15
					orb.color = SKINCOLOR_GOLD

				elseif time == 5+2*TICRATE
					buffStat(target, ATK_ELEC, -1)	-- negative values lower a stat
					playSound(mo.battlen, sfx_bufu6)
					for i = 1, 64
						local m = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
						m.sprite = SPR_THOK
						m.frame = A
						m.tics = TICRATE
						m.fuse = TICRATE
						m.destscale = 1
						m.color = SKINCOLOR_GOLD
						m.flags = MF_NOCLIPTHING|MF_NOCLIPHEIGHT
						m.momx = P_RandomRange(-64, 64)*FRACUNIT
						m.momy = P_RandomRange(-64, 64)*FRACUNIT
						m.momz = P_RandomRange(0, 64)*FRACUNIT
					end
				end
			end

			if timer == TICRATE*3 + (#hittargets-1)
				return true
			end
		end,
	},

	["psy break"] = {
		name = "Psy Break",
		type = ATK_SUPPORT,
		costtype = CST_SP,
		cost = 15,
		desc = "Lower all enemies's Psy \nresistanceto average \nfor 3 turns.",
		target = TGT_ALLENEMIES,
		debuff = true,

		anim = function(mo, targets, hittargets, timer)

			for i = 1, #hittargets
				local target = hittargets[i]

				local time = timer - (i-1)*6

				if time == 20
					playSound(mo.battlen, sfx_debuff)
					local orb = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					orb.sprite = SPR_DBUF
					orb.frame = A|TR_TRANS30
					orb.scale = FRACUNIT*2
					orb.scalespeed = FRACUNIT/32
					orb.destscale = FRACUNIT/6
					orb.tics = 2*TICRATE-15
					orb.color = SKINCOLOR_PURPLE

				elseif time == 5+2*TICRATE
					buffStat(target, ATK_PSY, -1)	-- negative values lower a stat
					playSound(mo.battlen, sfx_bufu6)
					for i = 1, 64
						local m = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
						m.sprite = SPR_THOK
						m.frame = A
						m.tics = TICRATE
						m.fuse = TICRATE
						m.destscale = 1
						m.color = SKINCOLOR_PURPLE
						m.flags = MF_NOCLIPTHING|MF_NOCLIPHEIGHT
						m.momx = P_RandomRange(-64, 64)*FRACUNIT
						m.momy = P_RandomRange(-64, 64)*FRACUNIT
						m.momz = P_RandomRange(0, 64)*FRACUNIT
					end
				end
			end

			if timer == TICRATE*3 + (#hittargets-1)
				return true
			end
		end,
	},

	["nuke break"] = {
		name = "Nuke Break",
		type = ATK_SUPPORT,
		costtype = CST_SP,
		cost = 15,
		desc = "Lower all enemies's Nuke \nresistanceto average \nfor 3 turns.",
		target = TGT_ALLENEMIES,
		debuff = true,

		anim = function(mo, targets, hittargets, timer)

			for i = 1, #hittargets
				local target = hittargets[i]

				local time = timer - (i-1)*6

				if time == 20
					playSound(mo.battlen, sfx_debuff)
					local orb = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					orb.sprite = SPR_DBUF
					orb.frame = A|TR_TRANS30
					orb.scale = FRACUNIT*2
					orb.scalespeed = FRACUNIT/32
					orb.destscale = FRACUNIT/6
					orb.tics = 2*TICRATE-15
					orb.color = SKINCOLOR_BLUE

				elseif time == 5+2*TICRATE
					buffStat(target, ATK_NUCLEAR, -1)	-- negative values lower a stat
					playSound(mo.battlen, sfx_bufu6)
					for i = 1, 64
						local m = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
						m.sprite = SPR_THOK
						m.frame = A
						m.tics = TICRATE
						m.fuse = TICRATE
						m.destscale = 1
						m.color = SKINCOLOR_BLUE
						m.flags = MF_NOCLIPTHING|MF_NOCLIPHEIGHT
						m.momx = P_RandomRange(-64, 64)*FRACUNIT
						m.momy = P_RandomRange(-64, 64)*FRACUNIT
						m.momz = P_RandomRange(0, 64)*FRACUNIT
					end
				end
			end

			if timer == TICRATE*3 + (#hittargets-1)
				return true
			end
		end,
	},

	["analysis"] = {
		name = "Analysis",
		type = ATK_SUPPORT,
		costtype = CST_EP,
		norandom = true,	-- Don't allow this move to be selected in random pvp skills
		cost = 1,
		desc = "Analyze 1 target, revealing\ntheir affinities.",
		target = TGT_ENEMY,
		norepel = true,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]
			local btl = server.P_BattleStatus[mo.battlen]

			if mo.enemy
			or not target.enemy
				return true	-- NO.
			end

			if timer == 15

				if not btl.saved_affs[target.enemy]
					btl.saved_affs[target.enemy] = {0, 0, false}	-- failsafe?
				end
				btl.saved_affs[target.enemy][1] = 2147483647	-- INT32_MAX
				btl.saved_affs[target.enemy][2] = 2147483647	-- INT32_MAX
				btl.saved_affs[target.enemy][3] = true	-- stats

				local t = P_SpawnMobj(target.x, target.y, target.z + target.height/2, MT_THOK)
				t.tics = -1
				t.sprite = SPR_ANLY
				t.frame = FF_FULLBRIGHT
				t.scale = FRACUNIT*5/2
				t.fuse = TICRATE*2


				local g = P_SpawnGhostMobj(t)
				t.destscale = $*4
				t.scalespeed = $*4
				t.momz = FRACUNIT*4
				t.fuse = TICRATE/2
			end

			if timer >= 30
				if mo.control.mo.P_inputs[BT_JUMP] == 1
				and not mo.anl_closetimer

					mo.anl_closetimer = TICRATE

				end

				if mo.anl_closetimer
					mo.anl_closetimer = $-1
					if not mo.anl_closetimer

						mo.anl_closetimer = nil
						-- give me another turn
						local i = #btl.turnorder+1
						while i > 1
							btl.turnorder[i] = btl.turnorder[i-1]
							i = $-1
						end
						return true
					end
				end
			end

		end,

		-- hudfunc2 is layered above the regular UI
		hudfunc2 = function(v, mo, timer)

			local target = mo.targets[1]
			if timer > TICRATE and target.enemy

					local cmd = {
						{BUTT_A, "Close"},
					}

				if mo.anl_closetimer
					local t = mo.anl_closetimer - TICRATE/2
					if t > 0
						v.drawScaled(160<<FRACBITS, 100<<FRACBITS, max(0, min(64, t))*FRACUNIT/2, v.cachePatch("H_1M_B"), V_50TRANS)
						drawStats(v, target, max(t, -8), 1, 0, cmd)
					end
				else
					local t = timer - TICRATE
					v.drawScaled(160<<FRACBITS, 100<<FRACBITS, max(0, min(64, t))*FRACUNIT/2, v.cachePatch("H_1M_B"), V_50TRANS)
					drawStats(v, target, max(t, -8), 1, 0, cmd)
				end
			end
		end,

	},

	["full analysis"] = {
		name = "Full Analysis",
		type = ATK_SUPPORT,
		costtype = CST_EP,
		norandom = true,	-- Don't allow this move to be selected in random pvp skills
		cost = 2,
		desc = "Analyze 1 target, revealing\ntheir affinities, skills and stats.",
		target = TGT_ENEMY,

	},

	["power charge"] = {
		name = "Power Charge",
		type = ATK_SUPPORT,
		costtype = CST_SP,
		cost = 15,
		desc = "Physical skill damage x2.5 next turn.",
		target = TGT_CASTER,
		superbuff = true,
		powercharge = true,				-- do not remove power charge status after using this skill.
		nocast = 	function(targets, n)	-- we can't cast this skill if this function returns true
						local target = targets[n]
						if target.powercharge
							BTL_logMessage(targets[1].battlen, "Already in effect")
							return true
						end
					end,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 20
				playSound(mo.battlen, sfx_buff2)
				target.powercharge = true
				BTL_logMessage(targets[1].battlen, target.name.." is building up Strength...")
				for i = 1,16
					local dust = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					dust.angle = ANGLE_90 + ANG1* (22*(i-1))
					dust.state = S_CDUST1
					P_InstaThrust(dust, dust.angle, 30*FRACUNIT)
					dust.color = SKINCOLOR_RED
					dust.scale = FRACUNIT*2
				end

			elseif timer > 20 and timer <= 50

				if leveltime%2 == 0
					for i = 1,16

						local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
						thok.state = S_CDUST1
						thok.momz = P_RandomRange(3, 10)*FRACUNIT
						thok.color = SKINCOLOR_RED
						thok.tics = P_RandomRange(10, 35)
						thok.scale = FRACUNIT*3/2
					end
				end

				for i = 1, 8
					local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
					thok.sprite = SPR_SUMN
					thok.frame = F|FF_FULLBRIGHT|TR_TRANS50
					thok.momz = P_RandomRange(6, 16)*FRACUNIT
					thok.color = SKINCOLOR_RED
					thok.tics = P_RandomRange(10, 35)
				end
			elseif timer == 60
				return true
			end
		end,
	},

	["mind charge"] = {
		name = "Mind Charge",
		type = ATK_SUPPORT,
		costtype = CST_SP,
		cost = 15,
		desc = "Magic damage x2.5 next turn.",
		target = TGT_CASTER,
		mindcharge = true,	-- used to know that we shouldn't remove mindcharge after using this skill.
		superbuff = true,	-- powerful buff
		nocast = 	function(targets, n)	-- we can't cast this skill if this function returns true
						local target = targets[n]
						if target.mindcharge
							BTL_logMessage(targets[1].battlen, "Already in effect")
							return true
						end
					end,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 20
				playSound(mo.battlen, sfx_buff2)
				target.mindcharge = true
				BTL_logMessage(targets[1].battlen, target.name.." is building up Magic power...")
				for i = 1,16
					local dust = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					dust.angle = ANGLE_90 + ANG1* (22*(i-1))
					dust.state = S_CDUST1
					P_InstaThrust(dust, dust.angle, 30*FRACUNIT)
					dust.color = SKINCOLOR_CYAN
					dust.scale = FRACUNIT*2
				end

			elseif timer > 20 and timer <= 50

				if leveltime%2 == 0
					for i = 1,16

						local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
						thok.state = S_CDUST1
						thok.momz = P_RandomRange(3, 10)*FRACUNIT
						thok.color = SKINCOLOR_CYAN
						thok.tics = P_RandomRange(10, 35)
						thok.scale = FRACUNIT*3/2
					end
				end

				for i = 1, 8
					local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
					thok.sprite = SPR_SUMN
					thok.frame = F|FF_FULLBRIGHT|TR_TRANS50
					thok.momz = P_RandomRange(6, 16)*FRACUNIT
					thok.color = SKINCOLOR_CYAN
					thok.tics = P_RandomRange(10, 35)
				end
			elseif timer == 60
				return true
			end
		end,
	},

	["marin karin2"] = {
		name = "Bruh",
		type = ATK_SUPPORT,
		power = 0,
		accuracy = 1000,
		statuschance = 1000,
		status = COND_BRAINWASH,
		costtype = CST_SP,
		luckbased = true,	-- use luck instead of agility
		cost = 5,
		desc = "High chance of inflicting \nBrainwash on 1 enemy.",
		target = TGT_ALLY,
		anim = function(mo, targets, hittargets, timer)
				local target = hittargets[1]

				if timer == 10
					playSound(mo.battlen, sfx_absorb)
				end

				if timer <= 30
					local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
					thok.state = S_CDUST1
					thok.momz = P_RandomRange(3, 10)*FRACUNIT
					thok.color = SKINCOLOR_PINK
					thok.tics = P_RandomRange(10, 35)
					thok.scale = FRACUNIT*3/2
				end

				if timer == 20
					damageObject(target)
				elseif timer == 42
					return true
				end
		end,
	},

	["marin karin"] = {
		name = "Marin Karin",
		type = ATK_SUPPORT,
		power = 0,
		accuracy = 35,
		statuschance = 35,
		status = COND_BRAINWASH,
		costtype = CST_SP,
		luckbased = true,	-- use luck instead of agility
		cost = 5,
		desc = "High chance of inflicting \nBrainwash on 1 enemy.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
				local target = hittargets[1]

				if timer == 10
					playSound(mo.battlen, sfx_absorb)
				end

				if timer <= 30
					local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
					thok.state = S_CDUST1
					thok.momz = P_RandomRange(3, 10)*FRACUNIT
					thok.color = SKINCOLOR_PINK
					thok.tics = P_RandomRange(10, 35)
					thok.scale = FRACUNIT*3/2
				end

				if timer == 20
					damageObject(target)
				elseif timer == 42
					return true
				end
		end,
	},

	["sexy dance"] = {
		name = "Sexy Dance",
		type = ATK_SUPPORT,
		power = 0,
		accuracy = 20,
		statuschance = 20,
		status = COND_BRAINWASH,
		costtype = CST_SP,
		luckbased = true,	-- use luck instead of agility
		cost = 12,
		desc = "Low chance of inflicting \nBrainwash on all enemies.",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)
				for i = 1, #hittargets
					local target = hittargets[i]

					local t = timer - (i-1)*6

					if t == 10
						playSound(mo.battlen, sfx_absorb)
					end

					if t <= 30
						local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
						thok.state = S_CDUST1
						thok.momz = P_RandomRange(3, 10)*FRACUNIT
						thok.color = SKINCOLOR_PINK
						thok.tics = P_RandomRange(10, 35)
						thok.scale = FRACUNIT*3/2
					end

					if t == 20
						damageObject(target)
					end
				end

				if timer == 42 + (#hittargets-1)*6
					return true
				end
		end,
	},

	["brain jack"] = {
		name = "Brain Jack",
		type = ATK_SUPPORT,
		power = 0,
		accuracy = 33,
		statuschance = 33,
		status = COND_BRAINWASH,
		costtype = CST_SP,
		luckbased = true,	-- use luck instead of agility
		cost = 12,
		desc = "Medium chance of inflicting \nBrainwash on all enemies.",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)
			for i = 1, #hittargets
				local target = hittargets[i]
				local t = timer - (i-1)*6

				if t == 10
					playSound(mo.battlen, sfx_absorb)
				end

				if t <= 30
					local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
					thok.state = S_CDUST1
					thok.momz = P_RandomRange(3, 10)*FRACUNIT
					thok.color = SKINCOLOR_PINK
					thok.tics = P_RandomRange(10, 35)
					thok.scale = FRACUNIT*3/2
				end

				if t == 20
					damageObject(target)
				end
			end

			if timer == 42 + (#hittargets-1)*6
				return true
			end
		end,
	},

	["evil touch"] = {
		name = "Evil Touch",
		type = ATK_SUPPORT,
		power = 0,
		accuracy = 60,
		statuschance = 60,
		status = COND_HEX,
		costtype = CST_SP,
		luckbased = true,	-- use luck instead of agility
		cost = 5,
		desc = "High chance of inflicting \nHex on 1 enemy.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
				local target = hittargets[1]

				if timer == 10
					playSound(mo.battlen, sfx_absorb)
				end

				if timer <= 30
					local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
					thok.state = S_CDUST1
					thok.momz = P_RandomRange(3, 10)*FRACUNIT
					thok.color = SKINCOLOR_PURPLE
					thok.tics = P_RandomRange(10, 35)
					thok.scale = FRACUNIT*3/2
				end

				if timer == 20
					damageObject(target)
				elseif timer == 42
					return true
				end
		end,
	},

	["evil smile"] = {
		name = "Evil Smile",
		type = ATK_SUPPORT,
		power = 0,
		accuracy = 45,
		statuschance = 45,
		status = COND_HEX,
		costtype = CST_SP,
		luckbased = true,	-- use luck instead of agility
		cost = 12,
		desc = "Low chance of inflicting \nHex on all enemies.",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)
				for i = 1, #hittargets
					local target = hittargets[i]

					local t = timer - (i-1)*6

					if t == 10
						playSound(mo.battlen, sfx_absorb)
					end

					if t <= 30
						local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
						thok.state = S_CDUST1
						thok.momz = P_RandomRange(3, 10)*FRACUNIT
						thok.color = SKINCOLOR_PURPLE
						thok.tics = P_RandomRange(10, 35)
						thok.scale = FRACUNIT*3/2
					end

					if t == 20
						damageObject(target)
					end
				end

				if timer == 42 + (#hittargets-1)*6
					return true
				end
		end,
	},

	["dormina"] = {
		name = "Dormina",
		type = ATK_SUPPORT,
		power = 0,
		accuracy = 40,
		statuschance = 40,
		status = COND_SLEEP,
		costtype = CST_SP,
		luckbased = true,	-- use luck instead of agility
		cost = 5,
		desc = "High chance of inflicting \nSleep on 1 enemy.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
				local target = hittargets[1]

				if timer == 10
					playSound(mo.battlen, sfx_absorb)
				end

				if timer <= 30
					local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
					thok.state = S_CDUST1
					thok.momz = P_RandomRange(3, 10)*FRACUNIT
					thok.color = SKINCOLOR_SILVER
					thok.tics = P_RandomRange(10, 35)
					thok.scale = FRACUNIT*3/2
				end

				if timer == 20
					damageObject(target)
				elseif timer == 42
					return true
				end
		end,
	},

	["famine breath"] = {
		name = "Famine Breath",
		type = ATK_SUPPORT,
		power = 0,
		accuracy = 40,
		statuschance = 40,
		status = COND_HUNGER,
		costtype = CST_SP,
		luckbased = true,	-- use luck instead of agility
		cost = 5,
		desc = "High chance of inflicting \nHunger on 1 enemy.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
				local target = hittargets[1]

				if timer == 10
					playSound(mo.battlen, sfx_absorb)
				end

				if timer <= 30
					local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
					thok.state = S_CDUST1
					thok.momz = P_RandomRange(3, 10)*FRACUNIT
					thok.color = SKINCOLOR_OLIVE
					thok.tics = P_RandomRange(10, 35)
					thok.scale = FRACUNIT*3/2
				end

				if timer == 20
					damageObject(target)
				elseif timer == 42
					return true
				end
		end,
	},

	["foolish whisper"] = {
		name = "Foolish Whisper",
		type = ATK_SUPPORT,
		power = 0,
		accuracy = 40,
		statuschance = 40,
		status = COND_SILENCE,
		costtype = CST_SP,
		luckbased = true,	-- use luck instead of agility
		cost = 5,
		desc = "High chance of inflicting \nSilence on 1 enemy.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
				local target = hittargets[1]

				if timer == 10
					playSound(mo.battlen, sfx_absorb)
				end

				if timer <= 30
					local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
					thok.state = S_CDUST1
					thok.momz = P_RandomRange(3, 10)*FRACUNIT
					thok.color = SKINCOLOR_GREEN
					thok.tics = P_RandomRange(10, 35)
					thok.scale = FRACUNIT*3/2
				end

				if timer == 20
					damageObject(target)
				elseif timer == 42
					return true
				end
		end,
	},

	["makajamon"] = {
		name = "Makajamon",
		type = ATK_SUPPORT,
		power = 0,
		accuracy = 25,
		statuschance = 25,
		status = COND_SILENCE,
		costtype = CST_SP,
		luckbased = true,	-- use luck instead of agility
		cost = 12,
		desc = "Low chance of inflicting \nSilence on all enemies.",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)
				for i = 1, #hittargets
					local target = hittargets[i]

					local t = timer - (i-1)*6

					if t == 10
						playSound(mo.battlen, sfx_absorb)
					end

					if t <= 30
						local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
						thok.state = S_CDUST1
						thok.momz = P_RandomRange(3, 10)*FRACUNIT
						thok.color = SKINCOLOR_GREEN
						thok.tics = P_RandomRange(10, 35)
						thok.scale = FRACUNIT*3/2
					end

					if t == 20
						damageObject(target)
					end
				end

				if timer == 42 + (#hittargets-1)*6
					return true
				end
		end,
	},

	["terror voice"] = {
		name = "Terror Voice",
		type = ATK_SUPPORT,
		power = 0,
		accuracy = 60,
		statuschance = 60,
		status = COND_DESPAIR,
		costtype = CST_SP,
		luckbased = true,	-- use luck instead of agility
		cost = 5,
		showsp = true,
		desc = "High chance of inflicting \nDespair on 1 enemy.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
				local target = hittargets[1]

				if timer == 10
					playSound(mo.battlen, sfx_absorb)
				end

				if timer <= 30
					local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
					thok.state = S_CDUST1
					thok.momz = P_RandomRange(3, 10)*FRACUNIT
					thok.color = SKINCOLOR_PURPLE
					thok.tics = P_RandomRange(10, 35)
					thok.scale = FRACUNIT*3/2
				end

				if timer == 20
					damageObject(target)
				elseif timer == 42
					return true
				end
		end,
	},

	["abysmal surge"] = {
		name = "Abysmal Surge",
		type = ATK_SUPPORT,
		power = 0,
		accuracy = 45,
		statuschance = 45,
		status = COND_DESPAIR,
		costtype = CST_SP,
		luckbased = true,	-- use luck instead of agility
		cost = 12,
		desc = "Low chance of inflicting \nDespair on all enemies.",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)
				for i = 1, #hittargets
					local target = hittargets[i]

					local t = timer - (i-1)*6

					if t == 10
						playSound(mo.battlen, sfx_absorb)
					end

					if t <= 30
						local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
						thok.state = S_CDUST1
						thok.momz = P_RandomRange(3, 10)*FRACUNIT
						thok.color = SKINCOLOR_PURPLE
						thok.tics = P_RandomRange(10, 35)
						thok.scale = FRACUNIT*3/2
					end

					if t == 20
						damageObject(target)
					end
				end

				if timer == 42 + (#hittargets-1)*6
					return true
				end
		end,
	},

	["pulinpa"] = {
		name = "Pulinpa",
		type = ATK_SUPPORT,
		power = 0,
		accuracy = 60,
		statuschance = 60,
		status = COND_DIZZY,
		costtype = CST_SP,
		luckbased = true,	-- use luck instead of agility
		cost = 5,
		desc = "High chance of inflicting \nDizziness on 1 enemy.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
				local target = hittargets[1]

				if timer == 10
					playSound(mo.battlen, sfx_absorb)
				end

				if timer <= 30
					local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
					thok.state = S_CDUST1
					thok.momz = P_RandomRange(3, 10)*FRACUNIT
					thok.color = SKINCOLOR_YELLOW
					thok.tics = P_RandomRange(10, 35)
					thok.scale = FRACUNIT*3/2
				end

				if timer == 20
					damageObject(target)
				elseif timer == 42
					return true
				end
		end,
	},

	["tentarafoo"] = {
		name = "Tentarafoo",
		type = ATK_SUPPORT,
		power = 0,
		accuracy = 50,
		statuschance = 50,
		status = COND_DIZZY,
		costtype = CST_SP,
		luckbased = true,	-- use luck instead of agility
		cost = 12,
		desc = "High chance of inflicting \nDizzy on all enemies.",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)
				for i = 1, #hittargets
					local target = hittargets[i]

					local t = timer - (i-1)*6

					if t == 10
						playSound(mo.battlen, sfx_absorb)
					end

					if t <= 30
						local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
						thok.state = S_CDUST1
						thok.momz = P_RandomRange(3, 10)*FRACUNIT
						thok.color = SKINCOLOR_YELLOW
						thok.tics = P_RandomRange(10, 35)
						thok.scale = FRACUNIT*3/2
					end

					if t == 20
						damageObject(target)
					end
				end

				if timer == 42 + (#hittargets-1)*6
					return true
				end
		end,
	},

	["provoke"] = {
		name = "Provoke",
		type = ATK_SUPPORT,
		power = 0,
		accuracy = 40,
		statuschance = 40,
		status = COND_RAGE,
		costtype = CST_SP,
		luckbased = true,	-- use luck instead of agility
		cost = 5,
		desc = "High chance of inflicting \nRage on 1 enemy.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
				local target = hittargets[1]

				if timer == 10
					playSound(mo.battlen, sfx_absorb)
				end

				if timer <= 30
					local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
					thok.state = S_CDUST1
					thok.momz = P_RandomRange(3, 10)*FRACUNIT
					thok.color = SKINCOLOR_RED
					thok.tics = P_RandomRange(10, 35)
					thok.scale = FRACUNIT*3/2
				end

				if timer == 20
					damageObject(target)
				elseif timer == 42
					return true
				end
		end,
	},

	["infuriate"] = {
		name = "Infuriate",
		type = ATK_SUPPORT,
		power = 0,
		accuracy = 25,
		statuschance = 25,
		status = COND_RAGE,
		costtype = CST_SP,
		luckbased = true,	-- use luck instead of agility
		cost = 12,
		desc = "Low chance of inflicting \nRage on all enemies.",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)
				for i = 1, #hittargets
					local target = hittargets[i]

					local t = timer - (i-1)*6

					if t == 10
						playSound(mo.battlen, sfx_absorb)
					end

					if t <= 30
						local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
						thok.state = S_CDUST1
						thok.momz = P_RandomRange(3, 10)*FRACUNIT
						thok.color = SKINCOLOR_RED
						thok.tics = P_RandomRange(10, 35)
						thok.scale = FRACUNIT*3/2
					end

					if t == 20
						damageObject(target)
					end
				end

				if timer == 42 + (#hittargets-1)*6
					return true
				end
		end,
	},

	["poisma"] = {
		name = "Poisma",
		type = ATK_SUPPORT,
		power = 0,
		accuracy = 50,
		statuschance = 50,
		status = COND_POISON,
		costtype = CST_SP,
		luckbased = true,	-- use luck instead of agility
		cost = 5,
		desc = "High chance of inflicting \nPoison on 1 enemy.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
				local target = hittargets[1]

				if timer == 10
					playSound(mo.battlen, sfx_absorb)
				end

				if timer <= 30
					local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
					thok.state = S_CDUST1
					thok.momz = P_RandomRange(3, 10)*FRACUNIT
					thok.color = SKINCOLOR_PURPLE
					thok.tics = P_RandomRange(10, 35)
					thok.scale = FRACUNIT*3/2
				end

				if timer == 20
					damageObject(target)
				elseif timer == 42
					return true
				end
		end,
	},

	["poison mist"] = {
		name = "Poison Mist",
		type = ATK_SUPPORT,
		power = 0,
		accuracy = 35,
		statuschance = 35,
		status = COND_POISON,
		costtype = CST_SP,
		luckbased = true,	-- use luck instead of agility
		cost = 12,
		desc = "Low chance of inflicting \nPoison on all enemies.",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)
				for i = 1, #hittargets
					local target = hittargets[i]

					local t = timer - (i-1)*6

					if t == 10
						playSound(mo.battlen, sfx_absorb)
					end

					if t <= 30
						local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
						thok.state = S_CDUST1
						thok.momz = P_RandomRange(3, 10)*FRACUNIT
						thok.color = SKINCOLOR_PURPLE
						thok.tics = P_RandomRange(10, 35)
						thok.scale = FRACUNIT*3/2
					end

					if t == 20
						damageObject(target)
					end
				end

				if timer == 42 + (#hittargets-1)*6
					return true
				end
		end,
	},

	["virus breath"] = {
		name = "Virus Breath",
		type = ATK_ALMIGHTY,
		power = 220,
		accuracy = 90,
		costtype = CST_SP,
		status = COND_POISON,
		statuschance = 50,
		cost = 30,
		desc = "Reduces all enemies' HP by 25%.\nVery high odds of Poison",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)

			if timer == 10
				mo.dbs = {}
				playSound(mo.battlen, sfx_cboom)
				-- ready smoke table
			end

			-- spawn said smoke:
			if timer >= 10 and timer <= TICRATE + TICRATE/2
			and mo.dbs

				for i = 1, 8
					local s = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
					s.state = S_CDUST1
					s.color = SKINCOLOR_GREEN
					s.angle = P_RandomRange(0, 359)*ANG1
					s.scale = FRACUNIT*3
					s.scalespeed = FRACUNIT/6
					s.destscale = FRACUNIT*12
					s.dist = 0
					s.tics = 18
					mo.dbs[#mo.dbs+1] = s
				end
			end

			-- rotate the smoke
			if mo.dbs and #mo.dbs
				for i = 1, #mo.dbs do
					local s = mo.dbs[i]
					if not s or not s.valid continue end	-- don't care

					s.angle = $+ ANG1*10
					s.dist = min(1024, $+32)

					P_TeleportMove(s, mo.x + s.dist *cos(s.angle), mo.y + s.dist*sin(s.angle), s.floorz)

					if not P_RandomRange(0, 30)
						local t = P_SpawnMobj(s.x, s.y, s.z, MT_THOK)
						t.color = SKINCOLOR_RED
						t.frame = $|FF_FULLBRIGHT
						t.momz = P_RandomRange(4, 8)*FRACUNIT
						t.destscale = 1
						t.tics = TICRATE
					end
				end
			end

			-- hit targets
			for i = 1, #hittargets
				local target = hittargets[i]
				local t = timer - 6*(i-1)

				if t == TICRATE - TICRATE/4
					local dmg = max(1, target.hp/4)
					if target.boss
						dmg = nil
					end

					damageObject(target, dmg)
				end
			end

			if timer == TICRATE*2 - TICRATE/4 + (#hittargets-1)*6
				return true
			end
		end,
	},

	["regenerate 1"] = {
		name = "Regenerate 1",
		type = ATK_PASSIVE,
		passive = PSV_STARTTURN,
		desc = "Regenerate 4% HP each turn",
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]
			if timer == 1
				P_SpawnMobj(target.x, target.y, target.z, MT_IVSP)
				local heals = max(1, target.maxhp*4 / 100)
				playSound(mo.battlen, sfx_heal)
				damageObject(target, -heals, DMG_NORMAL, true)
			elseif timer == 20
				return true
			end
		end,
	},

	["invigorate 1"] = {
		name = "Invigorate 1",
		type = ATK_PASSIVE,
		passive = PSV_STARTTURN,
		desc = "Regenerate 2 SP each turn",
		showsp = true,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]
			if timer == 1
				P_SpawnMobj(target.x, target.y, target.z, MT_IVSP)
				playSound(mo.battlen, sfx_heal)
				damageSP(target, -2, DMG_NORMAL, true)
			elseif timer == 20
				return true
			end
		end,
	},

	["invigorate 2"] = {
		name = "Invigorate 2",
		type = ATK_PASSIVE,
		passive = PSV_STARTTURN,
		desc = "Regenerate 4 SP each turn",
		showsp = true,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]
			if timer == 1
				P_SpawnMobj(target.x, target.y, target.z, MT_IVSP)
				playSound(mo.battlen, sfx_heal2)
				damageSP(target, -4, DMG_NORMAL, true)
			elseif timer == 20
				return true
			end
		end,
	},

	["invigorate 3"] = {
		name = "Invigorate 3",
		type = ATK_PASSIVE,
		passive = PSV_STARTTURN,
		desc = "Regenerate 6 SP each turn",
		showsp = true,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]
			if timer == 1
				P_SpawnMobj(target.x, target.y, target.z, MT_IVSP)
				playSound(mo.battlen, sfx_heal2)
				damageSP(target, -6, DMG_NORMAL, true)
			elseif timer == 20
				return true
			end
		end,
	},

	["regenerate 2"] = {
		name = "Regenerate 2",
		type = ATK_PASSIVE,
		passive = PSV_STARTTURN,
		desc = "Regenerate 6% HP each turn",
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]
			if timer == 1
				P_SpawnMobj(target.x, target.y, target.z, MT_IVSP)
				local heals = max(1, target.maxhp*6 / 100)
				playSound(mo.battlen, sfx_heal2)
				damageObject(target, -heals, DMG_NORMAL, true)
			elseif timer == 20
				return true
			end
		end,
	},

	["regenerate 3"] = {
		name = "Regenerate 3",
		type = ATK_PASSIVE,
		passive = PSV_STARTTURN,
		desc = "Regenerate 8% HP each turn",
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]
			if timer == 1
				P_SpawnMobj(target.x, target.y, target.z, MT_IVSP)
				local heals = max(1, target.maxhp*8 / 100)
				playSound(mo.battlen, sfx_heal3)
				damageObject(target, -heals, DMG_NORMAL, true)
			elseif timer == 20
				return true
			end
		end,
	},

	["perfect keeper 1"] = {
		name = "Perfect Keeper I",
		type = ATK_PASSIVE,
		desc = "Damage output scales with your HP.\n(From 90% at 1/3 HP \nto 125% at full HP)",
		--desc = "Damage scales from 90% when\nat or under 1/3 max HP to 115%\nat full HP.",
		passive = PSV_PERFECTIONNIST,
		accuracy = 90,	-- lowest damage %
		power = 120,	-- highest damage %
		hits = 33,		-- HP %
	},

	["perfect keeper 2"] = {
		name = "Perfect Keeper II",
		type = ATK_PASSIVE,
		desc = "Damage output scales with your HP.\n(From 90% at half HP \nto 135% at full HP)",
		--desc = "Damage scales from 90% when\nat or under 1/2 max HP to 145%\nat full HP.",
		passive = PSV_PERFECTIONNIST,
		accuracy = 90,	-- lowest damage %
		power = 145,	-- highest damage %
		hits = 50,		-- HP %
	},

	["swordbreaker"] = {
		name = "Swordbreaker",
		type = ATK_PASSIVE|ATK_STRIKE|ATK_PIERCE|ATK_SLASH,
		desc = "20% chance to reduce Physical\ndamage against the party by 50%",
		passive = PSV_SWORDBREAKER,
		power = 50,
		accuracy = 20,
	},

	["merciless slayer"] = {
		name = "Merciless Slayer",
		type = ATK_PASSIVE,
		desc = "Increase damage by 30% when\nattacking enemies with \nstatus conditions.",
		passive = PSV_SLAYER,
		power = 30,
	},

	["impure reach"] = {
		name = "Impure Reach",
		type = ATK_PASSIVE,
		desc = "Adds 10% success rate to\nall status conditions odds.\nEffect is additive.",
		passive = PSV_COND_BOOST,
		power = 10,
	},

	["double link"] = {
		name = "Double Link",
		type = ATK_PASSIVE,
		desc = "Increase Link damage by 25%.\nAllows up to 2 Link follow-ups.",
		passive = PSV_LINKHITS,
		accuracy = 2,
		power = 25,
	},

	["triple link"] = {
		name = "Triple Link",
		type = ATK_PASSIVE,
		desc = "Increase Link damage by 50%.\nAllows up to 3 Link follow-ups.",
		passive = PSV_LINKHITS,
		accuracy = 3,
		power = 50,
	},

	["quadruple link"] = {
		name = "Quadruple Link",
		type = ATK_PASSIVE,
		desc = "Increase Link damage by 75%.\nAllows up to 4 Link follow-ups.",
		passive = PSV_LINKHITS,
		accuracy = 4,
		power = 75,
	},

	["infinite link"] = {
		name = "Infinite Link",
		type = ATK_PASSIVE,
		desc = "Increase Link damage by 100%.\nAllows up to 8 Link follow-ups.",
		passive = PSV_LINKHITS,
		accuracy = 8,
		power = 100,
	},

	["golden link"] = {
		name = "Golden Link",
		type = ATK_PASSIVE,
		desc = "Increase Link follow-up damage\nby an additional 10% for each hit\nafter the first.",
		passive = PSV_LINKBOOST,
		power = 10,
	},

	["endure"] = {
		name = "Endure",
		type = ATK_PASSIVE,
		desc = "Survive one fatal attack\nwith 1 HP.",
		passive = PSV_ENDURE,
		accuracy = 100,
		power = 1,
	},

	["infinite endure"] = {
		name = "Infinite Endure",
		type = ATK_PASSIVE,
		desc = "Man, this game is hard...",
		passive = PSV_ENDURE,
		accuracy = 100,
		power = 999,
	},

	["survive expel"] = {
		name = "Survive Expel",
		type = ATK_PASSIVE|ATK_BLESS,
		desc = "50% chance to survive\nfatal Expel attacks\nwith 1 HP.",
		passive = PSV_ENDURE,
		accuracy = 50,
		power = 0,
	},

	["survive death"] = {
		name = "Survive Death",
		type = ATK_PASSIVE|ATK_CURSE,
		desc = "50% chance to survive\nfatal Death attacks\nwith 1 HP.",
		passive = PSV_ENDURE,
		accuracy = 50,
		power = 0,
	},

	["survival trick"] = {
		name = "Survival Trick",
		type = ATK_PASSIVE|ATK_CURSE|ATK_BLESS|ATK_ALMIGHTY|ATK_FIRE|ATK_ICE|ATK_ELEC|ATK_WIND|ATK_PSY|ATK_NUCLEAR,
		desc = "Survive one fatal\ninstant kill attack\nwith 1 HP.",
		passive = PSV_ENDURE,
		accuracy = 100,
		power = 1,
	},

	["burn boost"] = {
		name = "Burn Boost",
		type = ATK_PASSIVE,
		desc = "Adds 15% to odds of Burn.\nEffect is additive",
		passive = PSV_COND_BOOST,
		power = 15,
		status = COND_BURN,
	},

	["resist burn"] = {
		name = "Resist Burn",
		type = ATK_PASSIVE,
		desc = "Halves odds of being inflicted\nwith Burn.",
		passive = PSV_COND_RESIST,
		power = 50,
		status = COND_BURN,
	},

	["null burn"] = {
		name = "Null Burn",
		type = ATK_PASSIVE,
		desc = "Nullify odds of being inflicted\nwith Burn.",
		passive = PSV_COND_RESIST,
		power = 100,
		status = COND_BURN,
	},

	["silence boost"] = {
		name = "Silence Boost",
		type = ATK_PASSIVE,
		desc = "Adds 15% to odds of Silence.\nEffect is additive",
		passive = PSV_COND_BOOST,
		power = 15,
		status = COND_SILENCE,
	},

	["resist silence"] = {
		name = "Resist Silence",
		type = ATK_PASSIVE,
		desc = "Halves odds of being inflicted\nwith Silence.",
		passive = PSV_COND_RESIST,
		power = 50,
		status = COND_SILENCE,
	},

	["null silence"] = {
		name = "Null Silence",
		type = ATK_PASSIVE,
		desc = "Nullify odds of being inflicted\nwith Silence.",
		passive = PSV_COND_RESIST,
		power = 100,
		status = COND_SILENCE,
	},

	["dizzy boost"] = {
		name = "Dizzy Boost",
		type = ATK_PASSIVE,
		desc = "Adds 15% to odds of Dizzy.\nEffect is additive",
		passive = PSV_COND_BOOST,
		power = 15,
		status = COND_DIZZY,
	},

	["resist dizzy"] = {
		name = "Resist Dizzy",
		type = ATK_PASSIVE,
		desc = "Halves odds of being inflicted\nwith Dizzy.",
		passive = PSV_COND_RESIST,
		power = 50,
		status = COND_DIZZY,
	},

	["null dizzy"] = {
		name = "Null Dizzy",
		type = ATK_PASSIVE,
		desc = "Nullify odds of being inflicted\nwith Dizzy.",
		passive = PSV_COND_RESIST,
		power = 100,
		status = COND_DIZZY,
	},

	["freeze boost"] = {
		name = "Freeze Boost",
		type = ATK_PASSIVE,
		desc = "Adds 15% to odds of Freeze.\nEffect is additive",
		passive = PSV_COND_BOOST,
		power = 15,
		status = COND_FREEZE,
	},

	["resist freeze"] = {
		name = "Resist Freeze",
		type = ATK_PASSIVE,
		desc = "Halves odds of being inflicted\nwith Freeze.",
		passive = PSV_COND_RESIST,
		power = 50,
		status = COND_FREEZE,
	},

	["null freeze"] = {
		name = "Null Freeze",
		type = ATK_PASSIVE,
		desc = "Nullify odds of being inflicted\nwith Freeze.",
		passive = PSV_COND_RESIST,
		power = 100,
		status = COND_FREEZE,
	},

	["shock boost"] = {
		name = "Shock Boost",
		type = ATK_PASSIVE,
		desc = "Adds 15% to odds of Shock.\nEffect is additive",
		passive = PSV_COND_BOOST,
		power = 15,
		status = COND_SHOCK,
	},

	["resist shock"] = {
		name = "Resist Shock",
		type = ATK_PASSIVE,
		desc = "Halves odds of being inflicted\nwith Shock.",
		passive = PSV_COND_RESIST,
		power = 50,
		status = COND_SHOCK,
	},

	["null shock"] = {
		name = "Null Shock",
		type = ATK_PASSIVE,
		desc = "Nullify odds of being inflicted\nwith Shock.",
		passive = PSV_COND_RESIST,
		power = 100,
		status = COND_SHOCK,
	},

	["brainwash boost"] = {
		name = "Brainwash Boost",
		type = ATK_PASSIVE,
		desc = "Adds 15% to odds of Brainwash.\nEffect is additive",
		passive = PSV_COND_BOOST,
		power = 15,
		status = COND_BRAINWASH,
	},

	["resist brainwash"] = {
		name = "Resist Brainwash",
		type = ATK_PASSIVE,
		desc = "Halves odds of being inflicted\nwith Brainwash.",
		passive = PSV_COND_RESIST,
		power = 50,
		status = COND_BRAINWASH,
	},

	["null brainwash"] = {
		name = "Null Brainwash",
		type = ATK_PASSIVE,
		desc = "Nullify odds of being inflicted\nwith Brainwash.",
		passive = PSV_COND_RESIST,
		power = 100,
		status = COND_BRAINWASH,
	},

	["sleep boost"] = {
		name = "Sleep Boost",
		type = ATK_PASSIVE,
		desc = "Adds 15% to odds of Sleep.\nEffect is additive",
		passive = PSV_COND_BOOST,
		power = 15,
		status = COND_SLEEP,
	},

	["resist sleep"] = {
		name = "Resist Sleep",
		type = ATK_PASSIVE,
		desc = "Halves odds of being inflicted\nwith Sleep.",
		passive = PSV_COND_RESIST,
		power = 50,
		status = COND_SLEEP,
	},

	["null sleep"] = {
		name = "Null Sleep",
		type = ATK_PASSIVE,
		desc = "Nullify odds of being inflicted\nwith Sleep.",
		passive = PSV_COND_RESIST,
		power = 100,
		status = COND_SLEEP,
	},

	["hex boost"] = {
		name = "Hex Boost",
		type = ATK_PASSIVE,
		desc = "Adds 15% to odds of Hex.\nEffect is additive",
		passive = PSV_COND_BOOST,
		power = 15,
		status = COND_DIZZY,
	},

	["resist hex"] = {
		name = "Resist Hex",
		type = ATK_PASSIVE,
		desc = "Halves odds of being inflicted\nwith Hex.",
		passive = PSV_COND_RESIST,
		power = 50,
		status = COND_HEX,
	},

	["null hex"] = {
		name = "Null Hex",
		type = ATK_PASSIVE,
		desc = "Nullify odds of being inflicted\nwith Sleep.",
		passive = PSV_COND_RESIST,
		power = 100,
		status = COND_SLEEP,
	},

	["despair boost"] = {
		name = "Despair Boost",
		type = ATK_PASSIVE,
		desc = "Adds 15% to odds of Despair.\nEffect is additive",
		passive = PSV_COND_BOOST,
		power = 15,
		status = COND_DESPAIR,
	},

	["resist despair"] = {
		name = "Resist Despair",
		type = ATK_PASSIVE,
		desc = "Halves odds of being inflicted\nwith Despair.",
		passive = PSV_COND_RESIST,
		power = 50,
		status = COND_DESPAIR,
	},

	["null despair"] = {
		name = "Null Despair",
		type = ATK_PASSIVE,
		desc = "Nullify odds of being inflicted\nwith Despair.",
		passive = PSV_COND_RESIST,
		power = 100,
		status = COND_DESPAIR,
	},

	["poison boost"] = {
		name = "Poison Boost",
		type = ATK_PASSIVE,
		desc = "Adds 15% to odds of Poison.\nEffect is additive",
		passive = PSV_COND_BOOST,
		power = 15,
		status = COND_POISON,
	},

	["resist poison"] = {
		name = "Resist Poison",
		type = ATK_PASSIVE,
		desc = "Halves odds of being inflicted\nwith Poison.",
		passive = PSV_COND_RESIST,
		power = 50,
		status = COND_POISON,
	},

	["null poison"] = {
		name = "Null Poison",
		type = ATK_PASSIVE,
		desc = "Nullify odds of being inflicted\nwith Poison.",
		passive = PSV_COND_RESIST,
		power = 100,
		status = COND_POISON,
	},

	["hunger boost"] = {
		name = "Hunger Boost",
		type = ATK_PASSIVE,
		desc = "Adds 15% to odds of Hunger.\nEffect is additive",
		passive = PSV_COND_BOOST,
		power = 15,
		status = COND_HUNGER,
	},

	["resist hunger"] = {
		name = "Resist Hunger",
		type = ATK_PASSIVE,
		desc = "Halves odds of being inflicted\nwith Hunger.",
		passive = PSV_COND_RESIST,
		power = 50,
		status = COND_HUNGER,
	},

	["null hunger"] = {
		name = "Null Hunger",
		type = ATK_PASSIVE,
		desc = "Nullify odds of being inflicted\nwith Hunger.",
		passive = PSV_COND_RESIST,
		power = 100,
		status = COND_HUNGER,
	},

	["rage boost"] = {
		name = "Rage Boost",
		type = ATK_PASSIVE,
		desc = "Adds 15% to odds of Rage.\nEffect is additive",
		passive = PSV_COND_BOOST,
		power = 15,
		status = COND_RAGE,
	},

	["resist rage"] = {
		name = "Resist Rage",
		type = ATK_PASSIVE,
		desc = "Halves odds of being inflicted\nwith Rage.",
		passive = PSV_COND_RESIST,
		power = 50,
		status = COND_HEX,
	},

	["null rage"] = {
		name = "Null Rage",
		type = ATK_PASSIVE,
		desc = "Nullify odds of being inflicted\nwith Rage.",
		passive = PSV_COND_RESIST,
		power = 100,
		status = COND_RAGE,
	},

	["resist strike"] = {
		name = "Resist Strike",
		type = ATK_PASSIVE|ATK_STRIKE,
		desc = "Overwrite affinity to resist \nStrike skills.",
		passive = PSV_RESIST,
		},

	["resist slash"] = {
	name = "Resist Slash",
		type = ATK_PASSIVE|ATK_SLASH,
		desc = "Overwrite affinity to resist \nSlash skills.",
		passive = PSV_RESIST,
		},

	["resist pierce"] = {
		name = "Resist Pierce",
		type = ATK_PASSIVE|ATK_PIERCE,
		desc = "Overwrite affinity to resist \nPierce skills.",
		passive = PSV_RESIST,
		},

	["resist fire"] = {
		name = "Resist Fire",
		type = ATK_PASSIVE|ATK_FIRE,
		desc = "Overwrite affinity to resist \nFire skills.",
		passive = PSV_RESIST,
		},

	["resist ice"] = {
		name = "Resist Ice",
		type = ATK_PASSIVE|ATK_ICE,
		desc = "Overwrite affinity to resist \nIce skills.",
		passive = PSV_RESIST,
		},

	["resist wind"] = {
		name = "Resist Wind",
		type = ATK_PASSIVE|ATK_WIND,
		desc = "Overwrite affinity to resist \nWind skills.",
		passive = PSV_RESIST,
		},

	["resist elec"] = {
		name = "Resist Elec",
		type = ATK_PASSIVE|ATK_ELEC,
		desc = "Overwrite affinity to resist \nElectric skills.",
		passive = PSV_RESIST,
		},

	["resist psy"] = {
		name = "Resist Psy",
		type = ATK_PASSIVE|ATK_PSY,
		desc = "Overwrite affinity to resist \nPsychic skills.",
		passive = PSV_RESIST,
		},

	["resist nuke"] = {
		name = "Resist Nuke",
		type = ATK_PASSIVE|ATK_NUCLEAR,
		desc = "Overwrite affinity to resist \nNuclear skills.",
		passive = PSV_RESIST,
		},

	["resist bless"] = {
		name = "Resist Bless",
		type = ATK_PASSIVE|ATK_BLESS,
		desc = "Overwrite affinity to resist \nBless skills.",
		passive = PSV_RESIST,
		},

	["resist curse"] = {
		name = "Resist Curse",
		type = ATK_PASSIVE|ATK_CURSE,
		desc = "Overwrite affinity to resist \nCurse skills.",
		passive = PSV_RESIST,
		},

	["reseist strike"] = {
		name = "Void Strike",
		type = ATK_PASSIVE|ATK_STRIKE,
		desc = "Overwrite affinity to block \nStrike skills.",
		passive = PSV_BLOCK,
		},


	-- VOID SKILLS
	["void slash"] = {
		name = "Void Slash",
		type = ATK_PASSIVE|ATK_SLASH,
		desc = "Overwrite affinity to block \nSlash skills.",
		passive = PSV_BLOCK,
		},

	["void pierce"] = {
		name = "Void Pierce",
		type = ATK_PASSIVE|ATK_PIERCE,
		desc = "Overwrite affinity to block \nPierce skills.",
		passive = PSV_BLOCK,
		},

	["void fire"] = {
		name = "Void Fire",
		type = ATK_PASSIVE|ATK_FIRE,
		desc = "Overwrite affinity to block \nFire skills.",
		passive = PSV_BLOCK,
		},

	["void ice"] = {
		name = "Void Ice",
		type = ATK_PASSIVE|ATK_ICE,
		desc = "Overwrite affinity to block \nIce skills.",
		passive = PSV_BLOCK,
		},

	["void wind"] = {
		name = "Void Wind",
		type = ATK_PASSIVE|ATK_WIND,
		desc = "Overwrite affinity to block \nWind skills.",
		passive = PSV_BLOCK,
		},

	["void elec"] = {
		name = "Void Elec",
		type = ATK_PASSIVE|ATK_ELEC,
		desc = "Overwrite affinity to block \nElectric skills.",
		passive = PSV_BLOCK,
		},

	["void psy"] = {
		name = "Void Psy",
		type = ATK_PASSIVE|ATK_PSY,
		desc = "Overwrite affinity to block \nPsychic skills.",
		passive = PSV_BLOCK,
		},

	["void nuke"] = {
		name = "Void Nuke",
		type = ATK_PASSIVE|ATK_NUCLEAR,
		desc = "Overwrite affinity to block \nNuclear skills.",
		passive = PSV_BLOCK,
		},

	["void bless"] = {
		name = "Void Bless",
		type = ATK_PASSIVE|ATK_BLESS,
		desc = "Overwrite affinity to block \nBless skills.",
		passive = PSV_BLOCK,
		},

	["void curse"] = {
		name = "Void Curse",
		type = ATK_PASSIVE|ATK_CURSE,
		desc = "Overwrite affinity to block \nCurse skills.",
		passive = PSV_BLOCK,
		},

	-- DRAIN SKILLS
	["drain strike"] = {
		name = "Drain Strike",
		type = ATK_PASSIVE|ATK_STRIKE,
		desc = "Overwrite affinity to drain \nStrike skills.",
		passive = PSV_DRAIN,
		},

	["drain slash"] = {
		name = "Drain Slash",
		type = ATK_PASSIVE|ATK_SLASH,
		desc = "Overwrite affinity to drain \nSlash skills.",
		passive = PSV_DRAIN,
		},

	["drain pierce"] = {
		name = "Drain Pierce",
		type = ATK_PASSIVE|ATK_PIERCE,
		desc = "Overwrite affinity to drain \nPierce skills.",
		passive = PSV_DRAIN,
		},

	["drain fire"] = {
		name = "Drain Fire",
		type = ATK_PASSIVE|ATK_FIRE,
		desc = "Overwrite affinity to drain \nFire skills.",
		passive = PSV_DRAIN,
		},

	["drain ice"] = {
		name = "Drain Ice",
		type = ATK_PASSIVE|ATK_ICE,
		desc = "Overwrite affinity to drain \nIce skills.",
		passive = PSV_DRAIN,
		},

	["drain wind"] = {
		name = "Drain Wind",
		type = ATK_PASSIVE|ATK_WIND,
		desc = "Overwrite affinity to drain \nWind skills.",
		passive = PSV_DRAIN,
		},

	["drain elec"] = {
		name = "Drain Elec",
		type = ATK_PASSIVE|ATK_ELEC,
		desc = "Overwrite affinity to drain \nElectric skills.",
		passive = PSV_DRAIN,
		},

	["drain psy"] = {
		name = "Drain Psy",
		type = ATK_PASSIVE|ATK_PSY,
		desc = "Overwrite affinity to drain \nPsychic skills.",
		passive = PSV_DRAIN,
		},

	["drain nuke"] = {
		name = "Drain Nuke",
		type = ATK_PASSIVE|ATK_NUCLEAR,
		desc = "Overwrite affinity to drain \nNuclear skills.",
		passive = PSV_DRAIN,
		},

	["drain bless"] = {
		name = "Drain Bless",
		type = ATK_PASSIVE|ATK_BLESS,
		desc = "Overwrite affinity to drain \nBless skills.",
		passive = PSV_DRAIN,
		},

	["drain curse"] = {
		name = "Drain Curse",
		type = ATK_PASSIVE|ATK_CURSE,
		desc = "Overwrite affinity to drain \nCurse skills.",
		passive = PSV_DRAIN,
		},

	-- REPEL SKILLS

	["counter"] = {
		name = "Counter",
		type = ATK_PASSIVE|ATK_STRIKE|ATK_SLASH|ATK_PIERCE,
		desc = "Low chance of countering\nphysical attacks.",
		passive = PSV_REPEL,
		accuracy = 15,	-- % repel rate
	},

	["counterstrike"] = {
		name = "Counterstrike",
		type = ATK_PASSIVE|ATK_STRIKE|ATK_SLASH|ATK_PIERCE,
		desc = "Medium chance of countering\nphysical attacks.",
		passive = PSV_REPEL,
		accuracy = 30,	-- % repel rate
	},

	["high counter"] = {
		name = "High Counter",
		type = ATK_PASSIVE|ATK_STRIKE|ATK_SLASH|ATK_PIERCE,
		desc = "High chance of countering\nphysical attacks.",
		passive = PSV_REPEL,
		accuracy = 50,	-- % repel rate
	},

	-- ANGEL REPLICA UNIQUE SKILL (copy of High Counter)
	["delay"] = {
		name = "Delay",
		type = ATK_PASSIVE|ATK_STRIKE|ATK_SLASH|ATK_PIERCE,
		desc = "High chance of countering\nphysical attacks.",
		passive = PSV_REPEL,
		accuracy = 50,	-- % repel rate
	},

	["repel strike"] = {
		name = "Repel Strike",
		type = ATK_PASSIVE|ATK_STRIKE,
		desc = "Overwrite affinity to repel \nStrike skills.",
		passive = PSV_REPEL,
		},

	["repel slash"] = {
		name = "Repel Slash",
		type = ATK_PASSIVE|ATK_SLASH,
		desc = "Overwrite affinity to repel \nSlash skills.",
		passive = PSV_REPEL,
		},

	["repel pierce"] = {
		name = "Repel Pierce",
		type = ATK_PASSIVE|ATK_PIERCE,
		desc = "Overwrite affinity to repel \nPierce skills.",
		passive = PSV_REPEL,
		},

	["repel fire"] = {
		name = "Repel Fire",
		type = ATK_PASSIVE|ATK_FIRE,
		desc = "Overwrite affinity to repel \nFire skills.",
		passive = PSV_REPEL,
		},

	["repel ice"] = {
		name = "Repel Ice",
		type = ATK_PASSIVE|ATK_ICE,
		desc = "Overwrite affinity to repel \nIce skills.",
		passive = PSV_REPEL,
		},

	["repel wind"] = {
		name = "Repel Wind",
		type = ATK_PASSIVE|ATK_WIND,
		desc = "Overwrite affinity to repel \nWind skills.",
		passive = PSV_REPEL,
		},

	["repel elec"] = {
		name = "Repel Elec",
		type = ATK_PASSIVE|ATK_ELEC,
		desc = "Overwrite affinity to repel \nElectric skills.",
		passive = PSV_REPEL,
		},

	["repel psy"] = {
		name = "Repel Psy",
		type = ATK_PASSIVE|ATK_PSY,
		desc = "Overwrite affinity to repel \nPsychic skills.",
		passive = PSV_REPEL,
		},

	["repel nuke"] = {
		name = "Repel Nuke",
		type = ATK_PASSIVE|ATK_NUCLEAR,
		desc = "Overwrite affinity to repel \nNuclear skills.",
		passive = PSV_REPEL,
		},

	["repel bless"] = {
		name = "Repel Bless",
		type = ATK_PASSIVE|ATK_BLESS,
		desc = "Overwrite affinity to repel \nBless skills.",
		passive = PSV_REPEL,
		},

	["repel curse"] = {
		name = "Repel Curse",
		type = ATK_PASSIVE|ATK_CURSE,
		desc = "Overwrite affinity to repel \nCurse skills.",
		passive = PSV_REPEL,
		},

	-- EVASION SKILLS
	["dodge slash"] = {
		name = "Dodge Slash",
		type = ATK_PASSIVE|ATK_SLASH,
		desc = "Boost Evasion rate\nagainst Slash attacks\nby 15%",
		power = 15,
		passive = PSV_DODGE,
	},

	["dodge strike"] = {
		name = "Dodge Strike",
		type = ATK_PASSIVE|ATK_STRIKE,
		desc = "Boost Evasion rate\nagainst Strike attacks\nby 15%",
		power = 15,
		passive = PSV_DODGE,
	},

	["dodge pierce"] = {
		name = "Dodge Pierce",
		type = ATK_PASSIVE|ATK_PIERCE,
		desc = "Boost Evasion rate\nagainst Pierce attacks\nby 15%",
		power = 15,
		passive = PSV_DODGE,
	},

	["dodge fire"] = {
		name = "Dodge Fire",
		type = ATK_PASSIVE|ATK_FIRE,
		desc = "Boost Evasion rate\nagainst Fire attacks\nby 15%",
		power = 15,
		passive = PSV_DODGE,
	},

	["dodge ice"] = {
		name = "Dodge Ice",
		type = ATK_PASSIVE|ATK_ICE,
		desc = "Boost Evasion rate\nagainst Ice attacks\nby 15%",
		power = 15,
		passive = PSV_DODGE,
	},

	["dodge wind"] = {
		name = "Dodge Wind",
		type = ATK_PASSIVE|ATK_WIND,
		desc = "Boost Evasion rate\nagainst Wind attacks\nby 15%",
		power = 15,
		passive = PSV_DODGE,
	},

	["dodge elec"] = {
		name = "Dodge Elec",
		type = ATK_PASSIVE|ATK_ELEC,
		desc = "Boost Evasion rate\nagainst Electric attacks\nby 15%",
		power = 15,
		passive = PSV_DODGE,
	},

	["dodge psy"] = {
		name = "Dodge Psy",
		type = ATK_PASSIVE|ATK_PSY,
		desc = "Boost Evasion rate\nagainst Psychic attacks\nby 15%",
		power = 15,
		passive = PSV_DODGE,
	},

	["dodge nuke"] = {
		name = "Dodge Nuke",
		type = ATK_PASSIVE|ATK_NUCLEAR,
		desc = "Boost Evasion rate\nagainst Nuclear attacks\nby 15%",
		power = 15,
		passive = PSV_DODGE,
	},

	["dodge bless"] = {
		name = "Dodge Bless",
		type = ATK_PASSIVE|ATK_BLESS,
		desc = "Boost Evasion rate\nagainst Bless attacks\nby 15%",
		power = 15,
		passive = PSV_DODGE,
	},

	["dodge curse"] = {
		name = "Dodge Curse",
		type = ATK_PASSIVE|ATK_CURSE,
		desc = "Boost Evasion rate\nagainst Curse attacks\nby 15%",
		power = 15,
		passive = PSV_DODGE,
	},

	-- EVADE
	["evade slash"] = {
		name = "Evade Slash",
		type = ATK_PASSIVE|ATK_SLASH,
		desc = "Boost Evasion rate\nagainst Slash attacks\nby 30%",
		power = 30,
		passive = PSV_DODGE,
	},

	["evade strike"] = {
		name = "Evade Strike",
		type = ATK_PASSIVE|ATK_STRIKE,
		desc = "Boost Evasion rate\nagainst Strike attacks\nby 30%",
		power = 30,
		passive = PSV_DODGE,
	},

	["evade pierce"] = {
		name = "Evade Pierce",
		type = ATK_PASSIVE|ATK_PIERCE,
		desc = "Boost Evasion rate\nagainst Pierce attacks\nby 30%",
		power = 30,
		passive = PSV_DODGE,
	},

	["evade fire"] = {
		name = "Evade Fire",
		type = ATK_PASSIVE|ATK_FIRE,
		desc = "Boost Evasion rate\nagainst Fire attacks\nby 30%",
		power = 30,
		passive = PSV_DODGE,
	},

	["evade ice"] = {
		name = "Evade Ice",
		type = ATK_PASSIVE|ATK_ICE,
		desc = "Boost Evasion rate\nagainst Ice attacks\nby 30%",
		power = 30,
		passive = PSV_DODGE,
	},

	["evade wind"] = {
		name = "Evade Wind",
		type = ATK_PASSIVE|ATK_WIND,
		desc = "Boost Evasion rate\nagainst Wind attacks\nby 30%",
		power = 30,
		passive = PSV_DODGE,
	},

	["evade elec"] = {
		name = "Evade Elec",
		type = ATK_PASSIVE|ATK_ELEC,
		desc = "Boost Evasion rate\nagainst Electric attacks\nby 30%",
		power = 30,
		passive = PSV_DODGE,
	},

	["evade psy"] = {
		name = "Evade Psy",
		type = ATK_PASSIVE|ATK_PSY,
		desc = "Boost Evasion rate\nagainst Psychic attacks\nby 30%",
		power = 30,
		passive = PSV_DODGE,
	},

	["evade nuke"] = {
		name = "Evade Nuke",
		type = ATK_PASSIVE|ATK_NUCLEAR,
		desc = "Boost Evasion rate\nagainst Nuclear attacks\nby 30%",
		power = 30,
		passive = PSV_DODGE,
	},

	["evade bless"] = {
		name = "Evade Bless",
		type = ATK_PASSIVE|ATK_BLESS,
		desc = "Boost Evasion rate\nagainst Bless attacks\nby 30%",
		power = 30,
		passive = PSV_DODGE,
	},

	["evade curse"] = {
		name = "Evade Curse",
		type = ATK_PASSIVE|ATK_CURSE,
		desc = "Boost Evasion rate\nagainst Curse attacks\nby 30%",
		power = 30,
		passive = PSV_DODGE,
	},

	["opulence"] = {
		name = "Opulence",
		type = ATK_PASSIVE|ATK_SLASH|ATK_STRIKE|ATK_PIERCE|ATK_FIRE|ATK_ICE|ATK_WIND|ATK_ELEC|ATK_PSY|ATK_NUCLEAR|ATK_CURSE|ATK_BLESS,
		desc = "Boost evasion rate\nagainst all attacks by 15%",
		power = 15,
		passive = PSV_DODGE,
	},

	-- SPECIAL:

	-- firm stance: 0% dodge part
	["firm stance"] = {
		name = "Firm Stance",
		type = ATK_PASSIVE|ATK_SLASH|ATK_STRIKE|ATK_PIERCE|ATK_FIRE|ATK_ICE|ATK_WIND|ATK_ELEC|ATK_PSY|ATK_NUCLEAR|ATK_CURSE|ATK_BLESS,
		desc = "Halves all damage taken but\nprevents dodging any agility\nbased attack.",
		power = -999,
		implicit = "firm stance.part2",
		passive = PSV_DODGE,
	},

	-- firm stance: half damage part
	["firm stance.part2"] = {
		name = "Firm Stance 2",
		type = ATK_PASSIVE,
		desc = "Halves all damage taken but\nprevents dodging any Agility\nbased attack.",
		power = -999,
		passive = PSV_TRIGGERDAMAGE_RECEIVED,
		anim = 	function(mo, attacker, dmg, crit)
					dmg = $/2
					return dmg
				end,
	},

	-- BOOST & AMP SKILLS

	["mastery 1"] = {
		name = "Mastery I",
		type = ATK_PASSIVE,
		desc = "Boost weakness, critical\nand technical damage by 3%",
		passive = PSV_TRIGGERDAMAGE,
		anim = 	function(mo, target, dmg, crit)
					if target.damagestate == DMG_WEAK
					or target.damagestate == DMG_TECHNICAL
					or target.damagestate == DMG_CRITICAL
						dmg = $*103/100
					end
					return dmg
				end,
	},

	["mastery 2"] = {
		name = "Mastery II",
		type = ATK_PASSIVE,
		desc = "Boost weakness, critical\nand technical damage by 7%",
		passive = PSV_TRIGGERDAMAGE,
		anim = 	function(mo, target, dmg, crit)
					if target.damagestate == DMG_WEAK
					or target.damagestate == DMG_TECHNICAL
					or target.damagestate == DMG_CRITICAL
						dmg = $*107/100
					end
					return dmg
				end,
	},

	["mastery 3"] = {
		name = "Mastery III",
		type = ATK_PASSIVE,
		desc = "Boost weakness, critical\nand technical damage by 10%",
		passive = PSV_TRIGGERDAMAGE,
		anim = 	function(mo, target, dmg, crit)
					if target.damagestate == DMG_WEAK
					or target.damagestate == DMG_TECHNICAL
					or target.damagestate == DMG_CRITICAL
						dmg = $*110/100
					end
					return dmg
				end,
	},

	["guard 1"] = {
		name = "Guard I",
		type = ATK_PASSIVE,
		desc = "Reduce weakness, critical\nand technical damage received by 3%",
		passive = PSV_TRIGGERDAMAGE_RECEIVED,
		anim = 	function(mo, attacker, dmg, crit)
					if mo.damagestate == DMG_WEAK
					or mo.damagestate == DMG_CRITICAL
					or mo.damagestate == DMG_TECHNICAL
						dmg = $*97/100
					end
					return dmg
				end,
	},

	["guard 2"] = {
		name = "Guard II",
		type = ATK_PASSIVE,
		desc = "Reduce weakness, critical\nand technical damage received by 7%",
		passive = PSV_TRIGGERDAMAGE_RECEIVED,
		anim = 	function(mo, attacker, dmg, crit)
					if mo.damagestate == DMG_WEAK
					or mo.damagestate == DMG_CRITICAL
					or mo.damagestate == DMG_TECHNICAL
						dmg = $*93/100
					end
					return dmg
				end,
	},

	["guard 3"] = {
		name = "Guard III",
		type = ATK_PASSIVE,
		desc = "Reduce weakness, critical\nand technical damage received by 10%",
		passive = PSV_TRIGGERDAMAGE_RECEIVED,
		anim = 	function(mo, attacker, dmg, crit)
					if mo.damagestate == DMG_WEAK
					or mo.damagestate == DMG_CRITICAL
					or mo.damagestate == DMG_TECHNICAL
						dmg = $*90/100
					end
					return dmg
				end,
	},

	["last stand"] = {
		name = "Last Stand",
		type = ATK_PASSIVE,
		desc = "Boost damage by 20%\nwhen under 50% HP.",
		passive = PSV_TRIGGERDAMAGE,
		anim = 	function(mo, target, dmg, crit)
					if mo.hp < mo.maxhp/2
						dmg = $*120/100
					end
					return dmg
				end,
	},

	["spirit surge"] = {
		name = "Spirit Surge",
		type = ATK_PASSIVE,
		desc = "Boost damage by 20%\nwhen under 50% SP.",
		passive = PSV_TRIGGERDAMAGE,
		anim = 	function(mo, target, dmg, crit)
					if mo.sp < mo.maxsp/2
						dmg = $*120/100
					end
					return dmg
				end,
	},

	["challenger 1"] = {
		name = "Challenger I",
		type = ATK_PASSIVE,
		desc = "Boost damage by 10%\nagainst boss enemies.",
		passive = PSV_TRIGGERDAMAGE,
		anim = 	function(mo, target, dmg, crit)
					if target.boss
						dmg = $*110/100
					end
					return dmg
				end,
	},

	["challenger 2"] = {
		name = "Challenger II",
		type = ATK_PASSIVE,
		desc = "Boost damage by 20%\nagainst boss enemies.",
		passive = PSV_TRIGGERDAMAGE,
		anim = 	function(mo, target, dmg, crit)
					if target.boss
						dmg = $*120/100
					end
					return dmg
				end,
	},

	["equalizer"] = {
		name = "Equalizer",
		type = ATK_PASSIVE,
		desc = "Reduces weakness, critical and\ntechnical damage by 10%.\nIncreases all damage by 5%",
		passive = PSV_TRIGGERDAMAGE,
		anim = 	function(mo, target, dmg, crit)
					if target.damagestate == DMG_WEAK
					or target.damagestate == DMG_TECHNICAL
					or target.damagestate == DMG_CRITICAL
						dmg = $*90/100
					end


					dmg = $*105/100
					return dmg
				end,
	},

	["ignorance"] = {
		name = "Ignorance",
		type = ATK_PASSIVE,
		desc = "Ignore regular resistances from\nenemies. Block, Drain and Repel are\nnot ignored.",
		passive = PSV_TRIGGERDAMAGE,
		anim = 	function(mo, target, dmg, crit)
					if target.damagestate == DMG_RESIST
						target.damagestate = DMG_NORMAL
						dmg = $*2
					end
					return dmg
				end,
	},

	["freifi aura"] = {
		name = "Freifi Aura",
		type = ATK_PASSIVE,
		desc = "Increase all damage by 10%.\nWeak/Critical/Technical hits\ndeal an additional 15% damage.",
		passive = PSV_TRIGGERDAMAGE,
		anim = 	function(mo, target, dmg, crit)
					if target.damagestate == DMG_WEAK
					or target.damagestate == DMG_TECHNICAL
					or target.damagestate == DMG_CRITICAL
						dmg = $*115/100
					end

					dmg = $*110/100

					return dmg
				end,
	},

	["unfathomable darkness"] = {
		name = "Unfathomable Darkness",
		type = ATK_PASSIVE,
		desc = "Effects of 'Freifi Aura'.\nAdds a very low chance of instant kill\nagainst non-boss enemies.",
		passive = PSV_TRIGGERDAMAGE,
		anim = 	function(mo, target, dmg, crit)
					if target.damagestate == DMG_WEAK
					or target.damagestate == DMG_TECHNICAL
					or target.damagestate == DMG_CRITICAL
						dmg = $*115/100
					end

					dmg = $*110/100

					if not target.boss and P_RandomRange(0, 100) < 3
						dmg = 9999
					end

					return dmg
				end,
	},

	["precision 1"] = {
		name = "Precision I",
		type = ATK_PASSIVE,
		desc = "Boost weakness damage by 5%",
		passive = PSV_TRIGGERDAMAGE,
		anim = 	function(mo, target, dmg, crit)
					if target.damagestate == DMG_WEAK
						dmg = $*105/100
					end
					return dmg
				end,
	},

	["precision 2"] = {
		name = "Precision II",
		type = ATK_PASSIVE,
		desc = "Boost weakness damage by 10%",
		passive = PSV_TRIGGERDAMAGE,
		anim = 	function(mo, target, dmg, crit)
					if target.damagestate == DMG_WEAK
						dmg = $*110/100
					end
					return dmg
				end,
	},

	["precision 3"] = {
		name = "Precision III",
		type = ATK_PASSIVE,
		desc = "Boost weakness damage by 15%",
		passive = PSV_TRIGGERDAMAGE,
		anim = 	function(mo, target, dmg, crit)
					if target.damagestate == DMG_WEAK
						dmg = $*115/100
					end
					return dmg
				end,
	},

	["might 1"] = {
		name = "Might I",
		type = ATK_PASSIVE,
		desc = "Boost critical damage by 10%",
		passive = PSV_TRIGGERDAMAGE,
		anim = 	function(mo, target, dmg, crit)
					if target.damagestate == DMG_CRITICAL
						dmg = $*110/100
					end
					return dmg
				end,
	},

	["might 2"] = {
		name = "Might II",
		type = ATK_PASSIVE,
		desc = "Boost critical damage by 15%",
		passive = PSV_TRIGGERDAMAGE,
		anim = 	function(mo, target, dmg, crit)
					if target.damagestate == DMG_CRITICAL
						dmg = $*115/100
					end
					return dmg
				end,
	},

	["might 3"] = {
		name = "Might III",
		type = ATK_PASSIVE,
		desc = "Boost critical damage by 20%",
		passive = PSV_TRIGGERDAMAGE,
		anim = 	function(mo, target, dmg, crit)
					if target.damagestate == DMG_CRITICAL
						dmg = $*120/100
					end
					return dmg
				end,
	},

	["technique 1"] = {
		name = "Technique I",
		type = ATK_PASSIVE,
		desc = "Boost technical damage by 10%",
		passive = PSV_TRIGGERDAMAGE,
		anim = 	function(mo, target, dmg, crit)
					if target.damagestate == DMG_TECHNICAL
						dmg = $*110/100
					end
					return dmg
				end,
	},

	["technique 2"] = {
		name = "Technique II",
		type = ATK_PASSIVE,
		desc = "Boost technical damage by 15%",
		passive = PSV_TRIGGERDAMAGE,
		anim = 	function(mo, target, dmg, crit)
					if target.damagestate == DMG_TECHNICAL
						dmg = $*115/100
					end
					return dmg
				end,
	},

	["technique 3"] = {
		name = "Technique III",
		type = ATK_PASSIVE,
		desc = "Boost technical damage by 20%",
		passive = PSV_TRIGGERDAMAGE,
		anim = 	function(mo, target, dmg, crit)
					if target.damagestate == DMG_TECHNICAL
						dmg = $*120/100
					end
					return dmg
				end,
	},

	["toughness 1"] = {
		name = "Toughness I",
		type = ATK_PASSIVE,
		desc = "Reduce weakness damage\nreceived by 5%",
		passive = PSV_TRIGGERDAMAGE_RECEIVED,
		anim = 	function(mo, attacker, dmg, crit)
					if mo.damagestate == DMG_WEAK
						dmg = $*95/100
					end
					return dmg
				end,
	},

	["toughness 2"] = {
		name = "Toughness II",
		type = ATK_PASSIVE,
		desc = "Reduce weakness damage\nreceived by 10%",
		passive = PSV_TRIGGERDAMAGE_RECEIVED,
		anim = 	function(mo, attacker, dmg, crit)
					if mo.damagestate == DMG_WEAK
						dmg = $*90/100
					end
					return dmg
				end,
	},

	["toughness 3"] = {
		name = "Toughness III",
		type = ATK_PASSIVE,
		desc = "Reduce weakness damage\nreceived by 15%",
		passive = PSV_TRIGGERDAMAGE_RECEIVED,
		anim = 	function(mo, attacker, dmg, crit)
					if mo.damagestate == DMG_WEAK
						dmg = $*85/100
					end
					return dmg
				end,
	},

	["reflex 1"] = {
		name = "Reflex I",
		type = ATK_PASSIVE,
		desc = "Reduce critical damage\nreceived by 5%",
		passive = PSV_TRIGGERDAMAGE_RECEIVED,
		anim = 	function(mo, attacker, dmg, crit)
					if mo.damagestate == DMG_CRITICAL
						dmg = $*95/100
					end
					return dmg
				end,
	},

	["reflex 2"] = {
		name = "Reflex II",
		type = ATK_PASSIVE,
		desc = "Reduce critical damage\nreceived by 10%",
		passive = PSV_TRIGGERDAMAGE_RECEIVED,
		anim = 	function(mo, attacker, dmg, crit)
					if mo.damagestate == DMG_CRITICAL
						dmg = $*90/100
					end
					return dmg
				end,
	},

	["reflex 3"] = {
		name = "Reflex III",
		type = ATK_PASSIVE,
		desc = "Reduce critical damage\nreceived by 15%",
		passive = PSV_TRIGGERDAMAGE_RECEIVED,
		anim = 	function(mo, attacker, dmg, crit)
					if mo.damagestate == DMG_CRITICAL
						dmg = $*85/100
					end
					return dmg
				end,
	},


	["genius 1"] = {
		name = "Genius I",
		type = ATK_PASSIVE,
		desc = "Reduce technical damage\nreceived by 5%",
		passive = PSV_TRIGGERDAMAGE_RECEIVED,
		anim = 	function(mo, attacker, dmg, crit)
					if mo.damagestate == DMG_TECHNICAL
						dmg = $*95/100
					end
					return dmg
				end,
	},

	["genius 2"] = {
		name = "Genius II",
		type = ATK_PASSIVE,
		desc = "Reduce technical damage\nreceived by 10%",
		passive = PSV_TRIGGERDAMAGE_RECEIVED,
		anim = 	function(mo, attacker, dmg, crit)
					if mo.damagestate == DMG_TECHNICAL
						dmg = $*90/100
					end
					return dmg
				end,
	},

	["genius 3"] = {
		name = "Genius III",
		type = ATK_PASSIVE,
		desc = "Reduce technical damage\nreceived by 15%",
		passive = PSV_TRIGGERDAMAGE_RECEIVED,
		anim = 	function(mo, attacker, dmg, crit)
					if mo.damagestate == DMG_TECHNICAL
						dmg = $*85/100
					end
					return dmg
				end,
	},

	-- Nihil weapons skill slots:
	["void boost 1"] = {
		name = "Void Boost I",
		type = ATK_PASSIVE|ATK_FIRE|ATK_ICE|ATK_WIND|ATK_ELEC|ATK_PSY|ATK_NUCLEAR|ATK_BLESS|ATK_CURSE|ATK_STRIKE|ATK_SLASH|ATK_PIERCE,
		desc = "Boost damage by 5%",
		power = 5,
		passive = PSV_BOOST,
	},

	["void boost 2"] = {
		name = "Void Boost II",
		type = ATK_PASSIVE|ATK_FIRE|ATK_ICE|ATK_WIND|ATK_ELEC|ATK_PSY|ATK_NUCLEAR|ATK_BLESS|ATK_CURSE|ATK_STRIKE|ATK_SLASH|ATK_PIERCE,
		desc = "Boost damage by 7%",
		power = 7,
		passive = PSV_BOOST,
	},

	["void boost 3"] = {
		name = "Void Boost III",
		type = ATK_PASSIVE|ATK_FIRE|ATK_ICE|ATK_WIND|ATK_ELEC|ATK_PSY|ATK_NUCLEAR|ATK_BLESS|ATK_CURSE|ATK_STRIKE|ATK_SLASH|ATK_PIERCE,
		desc = "Boost damage by 9%",
		power = 9,
		passive = PSV_BOOST,
	},

	["void boost 4"] = {
		name = "Void Boost IV",
		type = ATK_PASSIVE|ATK_FIRE|ATK_ICE|ATK_WIND|ATK_ELEC|ATK_PSY|ATK_NUCLEAR|ATK_BLESS|ATK_CURSE|ATK_STRIKE|ATK_SLASH|ATK_PIERCE,
		desc = "Boost damage by 12%",
		power = 12,
		passive = PSV_BOOST,
	},

	["void boost 5"] = {
		name = "Void Boost V",
		type = ATK_PASSIVE|ATK_FIRE|ATK_ICE|ATK_WIND|ATK_ELEC|ATK_PSY|ATK_NUCLEAR|ATK_BLESS|ATK_CURSE|ATK_STRIKE|ATK_SLASH|ATK_PIERCE,
		desc = "Boost damage by 14%",
		power = 14,
		passive = PSV_BOOST,
	},

	["void boost 6"] = {
		name = "Void Boost VI",
		type = ATK_PASSIVE|ATK_FIRE|ATK_ICE|ATK_WIND|ATK_ELEC|ATK_PSY|ATK_NUCLEAR|ATK_BLESS|ATK_CURSE|ATK_STRIKE|ATK_SLASH|ATK_PIERCE,
		desc = "Boost damage by 16%",
		power = 16,
		passive = PSV_BOOST,
	},

	["void boost 7"] = {
		name = "Void Boost VII",
		type = ATK_PASSIVE|ATK_FIRE|ATK_ICE|ATK_WIND|ATK_ELEC|ATK_PSY|ATK_NUCLEAR|ATK_BLESS|ATK_CURSE|ATK_STRIKE|ATK_SLASH|ATK_PIERCE,
		desc = "Boost damage by 18%",
		power = 18,
		passive = PSV_BOOST,
	},

	["serene grace"] = {
		name = "Serene Grace",
		type = ATK_PASSIVE|ATK_HEAL,
		desc = "Increase healing done\nby 33%",
		power = 33,
		passive = PSV_BOOST,
	},

	["backup trick"] = {
		name = "Backup Trick",
		type = ATK_PASSIVE|ATK_CURSE,
		instakill = true,
		desc = "When missing a Death based\nattack, grants a chance to inflict\nHex on the target.",
		passive = PSV_PLANB,
		status = COND_HEX,
	},

	["death boost"] = {
		name = "Death Boost",
		type = ATK_PASSIVE|ATK_CURSE,
		instakill = true,
		desc = "Increase success rate of\nDeath based attack\nby 15%",
		power = 15,
		passive = PSV_BOOST,
		},

	["expel boost"] = {
		name = "Expel Boost",
		type = ATK_PASSIVE|ATK_BLESS,
		instakill = true,
		desc = "Increase success rate of\nExpel based attack\nby 15%",
		power = 15,
		passive = PSV_BOOST,
		},

	["fire boost"] = {
		name = "Fire Boost",
		type = ATK_PASSIVE|ATK_FIRE,
		desc = "Boost Fire damage by 15%",
		power = 15,
		passive = PSV_BOOST,
		},

	["fire amp"] = {
		name = "Fire Amp",
		type = ATK_PASSIVE|ATK_FIRE,
		desc = "Boost Fire damage by 30%",
		power = 30,
		passive = PSV_BOOST,
		},

	["ice boost"] = {
		name = "Ice Boost",
		type = ATK_PASSIVE|ATK_ICE,
		desc = "Boost Ice damage by 15%",
		power = 15,
		passive = PSV_BOOST,
		},

	["ice amp"] = {
		name = "Ice Amp",
		type = ATK_PASSIVE|ATK_ICE,
		desc = "Boost Ice damage by 30%",
		power = 30,
		passive = PSV_BOOST,
		},

	["elec boost"] = {
		name = "Elec Boost",
		type = ATK_PASSIVE|ATK_ELEC,
		desc = "Boost Elec damage by 15%",
		power = 15,
		passive = PSV_BOOST,
		},

	["elec amp"] = {
		name = "Elec Amp",
		type = ATK_PASSIVE|ATK_ELEC,
		desc = "Boost Elec damage by 30%",
		power = 30,
		passive = PSV_BOOST,
		},

	["wind boost"] = {
		name = "Wind Boost",
		type = ATK_PASSIVE|ATK_WIND,
		desc = "Boost Wind damage by 15%",
		power = 15,
		passive = PSV_BOOST,
		},

	["wind amp"] = {
		name = "Wind Amp",
		type = ATK_PASSIVE|ATK_WIND,
		desc = "Boost Wind damage by 30%",
		power = 30,
		passive = PSV_BOOST,
		},

	["nuke boost"] = {
		name = "Nuke Boost",
		type = ATK_PASSIVE|ATK_NUCLEAR,
		desc = "Boost Nuke damage by 15%",
		power = 15,
		passive = PSV_BOOST,
		},

	["nuke amp"] = {
		name = "Nuke Amp",
		type = ATK_PASSIVE|ATK_NUCLEAR,
		desc = "Boost Nuke damage by 30%",
		power = 30,
		passive = PSV_BOOST,
		},

	["psy boost"] = {
		name = "Psy Boost",
		type = ATK_PASSIVE|ATK_PSY,
		desc = "Boost Psychic damage by 15%",
		power = 15,
		passive = PSV_BOOST,
		},

	["psy amp"] = {
		name = "Psy Amp",
		type = ATK_PASSIVE|ATK_PSY,
		desc = "Boost Psychic damage by 30%",
		power = 30,
		passive = PSV_BOOST,
		},

	["bless boost"] = {
		name = "Bless Boost",
		type = ATK_PASSIVE|ATK_BLESS,
		desc = "Boost Bless damage by 15%",
		power = 15,
		passive = PSV_BOOST,
		},

	["bless amp"] = {
		name = "Bless Amp",
		type = ATK_PASSIVE|ATK_BLESS,
		desc = "Boost Bless damage by 30%",
		power = 30,
		passive = PSV_BOOST,
		},

	["curse boost"] = {
		name = "Curse Boost",
		type = ATK_PASSIVE|ATK_CURSE,
		desc = "Boost Curse damage by 15%",
		power = 15,
		passive = PSV_BOOST,
		},

	["curse amp"] = {
		name = "Curse Amp",
		type = ATK_PASSIVE|ATK_CURSE,
		desc = "Boost Curse damage by 30%",
		power = 30,
		passive = PSV_BOOST,
		},

	["hard knuckle"] = {
		name = "Hard Knuckle",
		type = ATK_PASSIVE|ATK_STRIKE,
		desc = "Boost Strike damage by 15%",
		power = 15,
		passive = PSV_BOOST,
	},

	["iron fist"] = {
		name = "Iron Fist",
		type = ATK_PASSIVE|ATK_STRIKE,
		desc = "Boost Strike damage by 30%",
		power = 30,
		passive = PSV_BOOST,
		},

	["sharp edge"] = {
		name = "Sharp Edge",
		type = ATK_PASSIVE|ATK_SLASH,
		desc = "Boost Slash damage by 15%",
		power = 15,
		passive = PSV_BOOST,
	},

	["diamondcutter"] = {
		name = "Diamondcutter",
		type = ATK_PASSIVE|ATK_SLASH,
		desc = "Boost Slash damage by 30%",
		power = 30,
		passive = PSV_BOOST,
	},

	["hard stab"] = {
		name = "Hard Stab",
		type = ATK_PASSIVE|ATK_PIERCE,
		desc = "Boost Pierce damage by 15%",
		power = 15,
		passive = PSV_BOOST,
	},

	["pinpoint pierce"] = {
		name = "Pinpoint Pierce",
		type = ATK_PASSIVE|ATK_PIERCE,
		desc = "Boost Pierce damage by 30%",
		power = 30,
		passive = PSV_BOOST,
	},

	["homunculus"] = {
		name = "Homunculus",
		type = ATK_CURSE,
		target = TGT_CASTER,
		costtype = CST_SP,
		norandom = true,	-- Don't allow this move to be selected in random pvp skills
		cost = 0,
		power = 0,
		desc = "You'll be sad to learn that\nthis skill does nothing",
		nocast = 	function(targets, n)	-- we can't cast this skill if this function returns true
						BTL_logMessage(targets[1].battlen, "No, this isn't how you're supposed to play the game!")
						return true
					end,
		anim = 	function(mo, targets, hittargets, timer)
					return true
				end,
	},

	["chaos_drive_1"] = {
		name = "Chaos Drive",
		type = ATK_ALMIGHTY,
		target = TGT_CASTER,
		costtype = CST_SP,
		norandom = true,	-- Don't allow this move to be selected in random pvp skills
		cost = 0,
		power = 50,
		desc = "Fill 50% of the Emerald Drive",
		anim = 	function(mo, targets, hittargets, timer)

					if timer == 20
						fillEmeraldGauge(mo, 50, true)
						playSound(mo.battlen, sfx_buff2)
					elseif timer == 60
						return true
					end
				end,
	},

	["chaos_drive_2"] = {
		name = "Chaos Drive II",
		type = ATK_ALMIGHTY,
		target = TGT_CASTER,
		costtype = CST_SP,
		norandom = true,	-- Don't allow this move to be selected in random pvp skills
		cost = 0,
		power = 50,
		desc = "Fill 50% of the Emerald Drive",
		anim = 	function(mo, targets, hittargets, timer)

					if timer == 20
						fillEmeraldGauge(mo, 150, true)
						playSound(mo.battlen, sfx_buff2)
					elseif timer == 60
						return true
					end
				end,
	},

	["chaos_drive_3"] = {
		name = "Chaos Drive III",
		type = ATK_ALMIGHTY,
		target = TGT_CASTER,
		costtype = CST_SP,
		norandom = true,	-- Don't allow this move to be selected in random pvp skills
		cost = 0,
		power = 50,
		desc = "Fill 300% of the Emerald Drive",
		anim = 	function(mo, targets, hittargets, timer)

					if timer == 20
						fillEmeraldGauge(mo, 300, true)
						playSound(mo.battlen, sfx_buff2)
					elseif timer == 60
						return true
					end
				end,
	},

	["chaos_drive_x"] = {
		name = "Chaos Drive X",
		type = ATK_ALMIGHTY,
		target = TGT_CASTER,
		costtype = CST_SP,
		norandom = true,	-- Don't allow this move to be selected in random pvp skills
		cost = 0,
		power = 50,
		desc = "Fill 300% of the Emerald Drive",
		anim = 	function(mo, targets, hittargets, timer)

					if timer == 20
						fillEmeraldGauge(mo, 700, true)
						playSound(mo.battlen, sfx_buff2)
					elseif timer == 60
						return true
					end
				end,
	},

	["heal_sp_0"] = {
		name = "Heal SP 0",
		type = ATK_HEAL,
		target = TGT_ALLY,
		costtype = CST_SP,
		cost = 0,
		norandom = true,	-- Don't allow this move to be selected in random pvp skills
		power = 20,
		showsp = true,	-- tell the game to display sp bars
		desc = "20 SP recovery to 1 ally.",
		nocast = 	function(targets, n)	-- we can't cast this skill if this function returns true
						local target = targets[n]
						if target.sp >= target.maxsp
							BTL_logMessage(targets[1].battlen, "No further effects.")
							return true
						end
					end,
		anim = 	function(mo, targets, hittargets, timer)
					local target = hittargets[1]
					if timer == 20
						damageSP(target, -20)
						playSound(mo.battlen, sfx_heal)
					elseif timer == 60
						return true
					end
				end,
		},

	["heal_sp_1"] = {
		name = "Heal SP 1",
		type = ATK_HEAL,
		target = TGT_ALLY,
		costtype = CST_SP,
		cost = 0,
		norandom = true,	-- Don't allow this move to be selected in random pvp skills
		power = 50,
		showsp = true,	-- tell the game to display sp bars
		desc = "50 SP recovery to 1 ally.",
		nocast = 	function(targets, n)	-- we can't cast this skill if this function returns true
						local target = targets[n]
						if target.sp >= target.maxsp
							BTL_logMessage(targets[1].battlen, "No further effects.")
							return true
						end
					end,
		anim = 	function(mo, targets, hittargets, timer)
					local target = hittargets[1]
					if timer == 20
						damageSP(target, -50)
						playSound(mo.battlen, sfx_heal)
					elseif timer == 60
						return true
					end
				end,
		},

	["heal_sp_2"] = {
		name = "Heal SP 2",
		type = ATK_HEAL,
		target = TGT_ALLY,
		costtype = CST_SP,
		cost = 0,
		norandom = true,	-- Don't allow this move to be selected in random pvp skills
		power = 100,
		showsp = true,	-- tell the game to display sp bars
		desc = "100 SP recovery to 1 ally.",
		nocast = 	function(targets, n)	-- we can't cast this skill if this function returns true
						local target = targets[n]
						if target.sp >= target.maxsp
							BTL_logMessage(targets[1].battlen, "No further effects.")
							return true
						end
					end,
		anim = 	function(mo, targets, hittargets, timer)
					local target = hittargets[1]
					if timer == 20
						damageSP(target, -100)
						playSound(mo.battlen, sfx_heal)
					elseif timer == 60
						return true
					end
				end,
		},

	["heal_sp_3"] = {
		name = "Heal SP 3",
		type = ATK_HEAL,
		target = TGT_ALLY,
		costtype = CST_SP,
		cost = 0,
		norandom = true,	-- Don't allow this move to be selected in random pvp skills
		power = 999,
		showsp = true,	-- tell the game to display sp bars
		desc = "Full SP recovery to 1 ally.",
		nocast = 	function(targets, n)	-- we can't cast this skill if this function returns true
						local target = targets[n]
						if target.sp >= target.maxsp
							BTL_logMessage(targets[1].battlen, "No further effects.")
							return true
						end
					end,
		anim = 	function(mo, targets, hittargets, timer)
					local target = hittargets[1]
					if timer == 20
						damageSP(target, -999)
						playSound(mo.battlen, sfx_heal)
					elseif timer == 60
						return true
					end
				end,
		},

		["nosp"] = {
		name = "Insufficient SP",
		type = ATK_SUPPORT,
		costtype = CST_SP,
		cost = 0,
		norandom = true,	-- Don't allow this move to be selected in random pvp skills
		target = TGT_ALLY,
		desc = "Why did you bother hacking this skill in?",
		anim = 	function(mo, targets, hittargets, timer)
					if timer == 1
						return true
					end
				end,
		},

		["tetrakarn"] = {
		name = "Tetrakarn",
		type = ATK_SUPPORT,
		costtype = CST_SP,
		cost = 16,
		target = TGT_ALLY,
		tetrakarn = true,
		desc = "Give a barrier that\nrepels physical attacks\nto 1 ally",
		superbuff = true,
		anim = 	function(mo, targets, hittargets, timer)
					local target = hittargets[1]
					if timer >= 10 and timer <= 40
						if leveltime%2 == 0
							local s = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
							s.sprite = SPR_FORC
							s.tics = 1
						end
					elseif timer == 41
						local thok = P_SpawnMobj(target.x, target.y, target.z+5*FRACUNIT, MT_DUMMY)
						thok.state = S_INVISIBLE
						thok.tics = 1
						A_OldRingExplode(thok, MT_SUPERSPARK)
						playSound(mo.battlen, sfx_mirror)

						BTL_logMessage(targets[1].battlen, target.name.." has\na physical barrier")

						target.tetrakarn = true
					end

					if timer == 60
						return true
					end

				end,

	},

		["makarakarn"] = {
		name = "Makarakarn",
		type = ATK_SUPPORT,
		costtype = CST_SP,
		cost = 16,
		target = TGT_ALLY,
		superbuff = true,
		makarakarn = true,
		desc = "Give a barrier that\nrepels magic attacks\nto 1 ally",
		anim = 	function(mo, targets, hittargets, timer)
					local target = hittargets[1]
					if timer >= 10 and timer <= 40
						if leveltime%2 == 0
							local s = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
							s.sprite = SPR_ARMA
							s.tics = 1
						end
					elseif timer == 41
						local thok = P_SpawnMobj(target.x, target.y, target.z+5*FRACUNIT, MT_DUMMY)
						thok.state = S_INVISIBLE
						thok.tics = 1
						A_OldRingExplode(thok, MT_SUPERSPARK)
						playSound(mo.battlen, sfx_mirror)

						BTL_logMessage(targets[1].battlen, target.name.." has\na magic barrier")

						target.makarakarn = true
					end

					if timer == 60
						return true
					end

				end,

	},

	["tetraja"] = {
		name = "Tetraja",
		type = ATK_SUPPORT,
		costtype = CST_SP,
		cost = 24,
		target = TGT_ALLALLIES,
		desc = "Give a barrier that blocks \ninstant kills to\nall allies",
		superbuff = true,
		anim = 	function(mo, targets, hittargets, timer)

					for i = 1, #targets
						local target = hittargets[i]
						local t = timer - (i-1)*6

						if t >= 10 and t <= 40
							if leveltime%2 == 0
								local s = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
								s.sprite = SPR_ELEM
								s.tics = 1
							end
						elseif t == 41
							local thok = P_SpawnMobj(target.x, target.y, target.z+5*FRACUNIT, MT_DUMMY)
							thok.state = S_INVISIBLE
							thok.tics = 1
							A_OldRingExplode(thok, MT_SUPERSPARK)
							playSound(mo.battlen, sfx_mirror)

							BTL_logMessage(targets[1].battlen, target.name.." is protected\nagainst Instant Kills!")

							target.tetraja = true
						end
					end

					if timer == 60 + (#hittargets-1)*6
						return true
					end

				end,

	},

	["road roller"] = {
		name = "Road Roller",
		type = ATK_STRIKE,
		costtype = CST_HPPERCENT,
		cost = 25,
		hits = 1,
		target = TGT_ENEMY,
		critical = 100,
		accuracy = 100,
		power = 1000,
		desc = "Colossal Strike dmg to 1 foe",
		anim = 	function(mo, targets, hittargets, timer)
					local target = hittargets[1]
					if timer == 10
						S_StartSound(target, sfx_roll)
						S_StartSound(target, sfx_becrsh)

						for i = 1,6
							local atk = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
							atk.momz = -1*FRACUNIT
							atk.state = S_AOADUST1
							atk.scale = FRACUNIT*1
							atk.destscale = FRACUNIT*2
							atk.angle = ANG60*(i-1)
							P_InstaThrust(atk, atk.angle, 10*FRACUNIT)
						end
					end

					if timer == 85
						mo.roadroller = P_SpawnMobj(target.x, target.y, target.z+FRACUNIT*1024, MT_DUMMY)
						mo.roadroller.sprite = SPR_CHSP
						mo.roadroller.flags = MF_SCENERY
						mo.roadroller.frame = A
						mo.roadroller.tics = 70
						mo.roadroller.momz = -50*FRACUNIT
					end

					if timer == 97
						damageObject(hittargets[1])
						localquake(mo.battlen, 40*FRACUNIT, TICRATE)
						for i = 1,6
							local atk = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
							atk.momz = -1*FRACUNIT
							atk.state = S_AOADUST1
							atk.scale = FRACUNIT*1
							atk.destscale = FRACUNIT*2
							atk.angle = ANG60*(i-1)
							P_InstaThrust(atk, atk.angle, 10*FRACUNIT)
							createSplat(mo)
						end
					end

					if timer == 140
						return true
					end

				end,

	},

	["gry"] = {
		name = "Gry",
		type = ATK_ALMIGHTY,
		power = 60,
		accuracy = 95,
		costtype = CST_SP,
		cost = 4,
		desc = "Light Almighty dmg to one enemy.\nDestroys barriers.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 20
				playSound(mo.battlen, sfx_absorb)
				--local x, y = target.x + 20*cos(target.angle), target.y + 20*sin(target.angle)
				local x,y = target.x, target.y
				local frei = P_SpawnMobj(x, y, target.z+FRACUNIT*10, MT_DUMMY)
				frei.state = S_PLAY_STND
				frei.dispoffset = 5
				frei.tics = -1
				frei.fuse = 60
				frei.sprite = SPR_FREI
				frei.frame = G|TR_TRANS20|FF_FULLBRIGHT
				frei.scale = FRACUNIT*2
				frei.basescale = frei.scale
				frei.color = SKINCOLOR_WHITE
				mo.frei = frei

			elseif timer > 20 and timer <= 50
				mo.frei.basescale = max(1, $ - FRACUNIT/12)
				if timer%2 == 0
					mo.frei.flags2 = $|MF2_DONTDRAW
					if timer%4 == 0
						mo.frei.scale = mo.frei.basescale*10/8
					else
						mo.frei.scale = mo.frei.basescale
					end
				else
					mo.frei.flags2 = $ & ~ MF2_DONTDRAW
				end

				local x = target.x + P_RandomRange(-120, 120)*target.scale
				local y = target.y + P_RandomRange(-120, 120)*target.scale
				local a = P_SpawnMobj(x, y, target.z + 180*target.scale, MT_DUMMY)
				a.state = S_CQUICKBOOM1
				a.color = SKINCOLOR_WHITE
				a.flags = $|MF_NOCLIPHEIGHT
				a.scale = FRACUNIT*3/2
				a.momz = -target.scale*20

				local h_angle = P_RandomRange(1, 359)*ANG1
				local v_angle = P_RandomRange(1, 359)*ANG1
				local dist = 256
				local spd = P_RandomRange(40, 50)

				local s_x = target.x+ dist*FixedMul(cos(h_angle), cos(v_angle))
				local s_y = target.y+ dist*FixedMul(sin(h_angle), cos(v_angle))
				local s_z = (target.z+target.height/2)+ dist* sin(v_angle)

				local s = P_SpawnMobj(s_x, s_y, s_z, MT_DUMMY)

				s.frame = A
				s.color = SKINCOLOR_WHITE
				s.scale = FRACUNIT/2
				s.destscale = 1
				s.target = mo
				s.tics = 10
				s.momx = (target.x - s.x)/10
				s.momy = (target.y - s.y)/10
				s.momz = (target.z - s.z)/10

			elseif timer == 51

				damageObject(target)
				mo.frei.fuse = 1
				for i = 1, 16
					local boom = P_SpawnMobj(target.x + P_RandomRange(-20, 20)*FRACUNIT, target.y + P_RandomRange(-20, 20)*FRACUNIT, target.z + 10*FRACUNIT, MT_DUMMY)
					boom.state = S_CQUICKBOOM1
					boom.color = SKINCOLOR_WHITE
					boom.momx = P_RandomRange(-20, 20)*FRACUNIT
					boom.momy = P_RandomRange(-20, 20)*FRACUNIT
					boom.momz = P_RandomRange(-20, 20)*FRACUNIT
					boom.scale = FRACUNIT*3/2
				end
				playSound(mo.battlen, sfx_megi6)
				localquake(mo.battlen, FRACUNIT*16, 10)
				mo.frei = nil
			elseif timer == 90
				return true
			end
		end,
	},

	["magry"] = {
		name = "Magry",
		type = ATK_ALMIGHTY,
		power = 60,
		accuracy = 90,
		costtype = CST_SP,
		cost = 8,
		desc = "Light Almighty dmg to all enemies.\nDestroys barriers.",
		target = TGT_ENEMIES,
		anim = function(mo, targets, hittargets, timer)

			for k,e in ipairs(hittargets)
				local time = timer - 10*(k-1)
				local target = e

				if time == 20
					playSound(mo.battlen, sfx_absorb)
					--local x, y = target.x + 20*cos(target.angle), target.y + 20*sin(target.angle)
					local x,y = target.x, target.y
					local frei = P_SpawnMobj(x, y, target.z+FRACUNIT*10, MT_DUMMY)
					frei.state = S_PLAY_STND
					frei.dispoffset = 5
					frei.tics = -1
					frei.fuse = 60
					frei.sprite = SPR_FREI
					frei.frame = G|TR_TRANS20|FF_FULLBRIGHT
					frei.scale = FRACUNIT*2
					frei.basescale = frei.scale
					frei.color = SKINCOLOR_WHITE
					target.frei = frei

				elseif time > 20 and time <= 50
					target.frei.basescale = max(1, $ - FRACUNIT/12)
					if time%2 == 0
						target.frei.flags2 = $|MF2_DONTDRAW
						if time%4 == 0
							target.frei.scale = target.frei.basescale*10/8
						else
							target.frei.scale = target.frei.basescale
						end
					else
						target.frei.flags2 = $ & ~ MF2_DONTDRAW
					end

					local x = target.x + P_RandomRange(-120, 120)*target.scale
					local y = target.y + P_RandomRange(-120, 120)*target.scale
					local a = P_SpawnMobj(x, y, target.z + 180*target.scale, MT_DUMMY)
					a.state = S_CQUICKBOOM1
					a.color = SKINCOLOR_WHITE
					a.flags = $|MF_NOCLIPHEIGHT
					a.scale = FRACUNIT*3/2
					a.momz = -target.scale*20

					local h_angle = P_RandomRange(1, 359)*ANG1
					local v_angle = P_RandomRange(1, 359)*ANG1
					local dist = 256
					local spd = P_RandomRange(40, 50)

					local s_x = target.x+ dist*FixedMul(cos(h_angle), cos(v_angle))
					local s_y = target.y+ dist*FixedMul(sin(h_angle), cos(v_angle))
					local s_z = (target.z+target.height/2)+ dist* sin(v_angle)

					local s = P_SpawnMobj(s_x, s_y, s_z, MT_DUMMY)

					s.frame = A
					s.color = SKINCOLOR_WHITE
					s.scale = FRACUNIT/2
					s.destscale = 1
					s.target = mo
					s.tics = 10
					s.momx = (target.x - s.x)/10
					s.momy = (target.y - s.y)/10
					s.momz = (target.z - s.z)/10

				elseif time == 51

					damageObject(target)
					target.frei.fuse = 1
					for i = 1, 16
						local boom = P_SpawnMobj(target.x + P_RandomRange(-20, 20)*FRACUNIT, target.y + P_RandomRange(-20, 20)*FRACUNIT, target.z + 10*FRACUNIT, MT_DUMMY)
						boom.state = S_CQUICKBOOM1
						boom.color = SKINCOLOR_WHITE
						boom.momx = P_RandomRange(-20, 20)*FRACUNIT
						boom.momy = P_RandomRange(-20, 20)*FRACUNIT
						boom.momz = P_RandomRange(-20, 20)*FRACUNIT
						boom.scale = FRACUNIT*3/2
					end
					playSound(mo.battlen, sfx_megi6)
					localquake(mo.battlen, FRACUNIT*16, 10)
					mo.frei = nil
				end
			end
			if timer == 90 + (#hittargets-1)*10
				return true
			end
		end,
	},

	["gryla"] = {
		name = "Gryla",
		type = ATK_ALMIGHTY,
		power = 140,
		accuracy = 95,
		costtype = CST_SP,
		cost = 8,
		desc = "Medium Almighty dmg to one enemy.\nDestroys barriers.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 20
				playSound(mo.battlen, sfx_absorb)
				--local x, y = target.x + 20*cos(target.angle), target.y + 20*sin(target.angle)
				local x,y = target.x, target.y
				local frei = P_SpawnMobj(x, y, target.z+FRACUNIT*10, MT_DUMMY)
				frei.state = S_PLAY_STND
				frei.dispoffset = 5
				frei.tics = -1
				frei.fuse = 60
				frei.sprite = SPR_FREI
				frei.frame = G|TR_TRANS20|FF_FULLBRIGHT
				frei.scale = FRACUNIT*2
				frei.basescale = frei.scale
				frei.color = SKINCOLOR_WHITE
				target.frei = frei

			elseif timer > 20 and timer <= 50
				target.frei.basescale = max(1, $ - FRACUNIT/12)
				if timer%2 == 0
					target.frei.flags2 = $|MF2_DONTDRAW
					if timer%4 == 0
						target.frei.scale = target.frei.basescale*10/8
					else
						target.frei.scale = target.frei.basescale
					end
				else
					target.frei.flags2 = $ & ~ MF2_DONTDRAW
				end

				if not (timer%4)

					local ol = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					ol.sprite = SPR_NTHK
					ol.scale = FRACUNIT*8
					ol.destscale = 1
					ol.scalespeed = FRACUNIT
					ol.frame = B|FF_FULLBRIGHT
					ol.color = SKINCOLOR_WHITE
					ol.tics = 8
				end

				if leveltime & 1
					local x = target.x + P_RandomRange(-120, 120)*target.scale
					local y = target.y + P_RandomRange(-120, 120)*target.scale
					local a = P_SpawnMobj(x, y, target.z + 180*target.scale, MT_DUMMY)
					a.state = S_CQUICKBOOM1
					a.color = SKINCOLOR_WHITE
					a.flags = $|MF_NOCLIPHEIGHT
					a.scale = FRACUNIT*3/2
					a.momz = -target.scale*20

					local h_angle = P_RandomRange(1, 359)*ANG1
					local v_angle = P_RandomRange(1, 359)*ANG1
					local dist = 256
					local spd = P_RandomRange(40, 50)

					local s_x = target.x+ dist*FixedMul(cos(h_angle), cos(v_angle))
					local s_y = target.y+ dist*FixedMul(sin(h_angle), cos(v_angle))
					local s_z = (target.z+target.height/2)+ dist* sin(v_angle)

					local s = P_SpawnMobj(s_x, s_y, s_z, MT_DUMMY)

					s.frame = A
					s.color = SKINCOLOR_WHITE
					s.scale = FRACUNIT/2
					s.destscale = 1
					s.target = mo
					s.tics = 10
					s.momx = (target.x - s.x)/10
					s.momy = (target.y - s.y)/10
					s.momz = (target.z - s.z)/10
				end

			elseif timer == 51

				damageObject(target)
				target.frei.fuse = 1
				for i = 1, 16
					local boom = P_SpawnMobj(target.x + P_RandomRange(-20, 20)*FRACUNIT, target.y + P_RandomRange(-20, 20)*FRACUNIT, target.z + 10*FRACUNIT, MT_DUMMY)
					boom.state = S_CQUICKBOOM1
					boom.color = SKINCOLOR_WHITE
					boom.momx = P_RandomRange(-20, 20)*FRACUNIT
					boom.momy = P_RandomRange(-20, 20)*FRACUNIT
					boom.momz = P_RandomRange(-20, 20)*FRACUNIT
					boom.scale = FRACUNIT*3/2
				end
				playSound(mo.battlen, sfx_megi6)
				localquake(mo.battlen, FRACUNIT*16, 10)
				mo.frei = nil
			elseif timer == 90
				return true
			end
		end,
	},

	["megido"] = {
		name = "Megido",
		type = ATK_ALMIGHTY,
		costtype = CST_SP,
		cost = 16,
		desc = "Medium Almighty damage to\nall enemies. Will break\nany barrier",
		target = TGT_ALLENEMIES,
		accuracy = 100,
		power = 280,
		anim = 			function(mo, targets, hittargets, timer)

							local avgx = 0
							local avgy = 0

							for i = 1, #hittargets
								local t = hittargets[i]

								avgx = $+ t.x/FRACUNIT
								avgy = $+ t.y/FRACUNIT

								local time = timer - 10*(i-1)

								if time >= 20 and time <= 30
								and (time%5) == 0

									local s = P_SpawnMobj(t.x + P_RandomRange(-128, 128)<<FRACBITS, t.y + P_RandomRange(-128, 128)<<FRACBITS, t.z + P_RandomRange(0, 192)<<FRACBITS, MT_DUMMY)
									s.color = SKINCOLOR_WHITE
									s.state = S_MEGISTAR1
									s.scale = $*2 + P_RandomRange(0, 65535)
									playSound(mo.battlen, sfx_hamas1)
								end
							end

							if timer == 40 + 10*(#hittargets-1)
								-- get average coords from what we had before
								avgx = ($/ #hittargets)*FRACUNIT
								avgy = ($/ #hittargets)*FRACUNIT

								local s = P_SpawnMobj(avgx, avgy, mo.z + FRACUNIT*128, MT_DUMMY)
								s.color = SKINCOLOR_WHITE
								s.state = S_MEGISTAR1
								s.scale = FRACUNIT*4
								playSound(mo.battlen, sfx_hamas2)
							elseif timer == 50 + 10*(#hittargets-1)
								-- explode lol
								playSound(mo.battlen, sfx_megi6)
								avgx = ($/ #hittargets)*FRACUNIT
								avgy = ($/ #hittargets)*FRACUNIT
								local an = 0
								for i = 1, 32

									local s = P_SpawnMobj(avgx, avgy, mo.z + FRACUNIT*32, MT_DUMMY)
									s.color = SKINCOLOR_WHITE
									s.state = S_MEGITHOK
									s.scale = $/2
									s.fuse = TICRATE*2
									P_InstaThrust(s, an*ANG1, 50<<FRACBITS)

									s = P_SpawnMobj(avgx, avgy, mo.z + FRACUNIT*32, MT_DUMMY)
									s.color = SKINCOLOR_WHITE
									s.state = S_MEGITHOK
									s.scale = $/4
									s.fuse = TICRATE*2
									P_InstaThrust(s, an*ANG1, 30<<FRACBITS)

									an = $ + (360/32)
								end

								for i = 1, #hittargets do
									damageObject(hittargets[i])
								end
							elseif timer == 100 + 10*(#hittargets-1)
								return true
							end
						end

	},


	["megidola"] = {
		name = "Megidola",
		type = ATK_ALMIGHTY,
		costtype = CST_SP,
		cost = 24,
		desc = "Heavy Almighty damage to\nall enemies. Will break\nany barrier.",
		target = TGT_ALLENEMIES,
		accuracy = 100,
		power = 500,

		anim = 			function(mo, targets, hittargets, timer)
							if timer == 1
								mo.megido = {}
								playSound(mo.battlen, sfx_debuff)
							elseif timer == TICRATE*8
								mo.megido = nil
								return true
							end

							local avgx, avgy = 0, 0
							for i = 1, #hittargets
								avgx = $ + hittargets[i].x/FRACUNIT
								avgy = $ + hittargets[i].y/FRACUNIT
							end
							avgx = ($/#hittargets)	*FRACUNIT
							avgy = ($/#hittargets)	*FRACUNIT

							if timer < 60

								-- get average position

								local ran = P_RandomRange(0, 359)*ANG1
								local dist = 256

								mo.megido[#mo.megido+1] = P_SpawnMobj(avgx + dist*cos(ran), avgy + dist*sin(ran), mo.z, MT_DUMMY)
								local s = mo.megido[#mo.megido]
								s.angle = ran
								s.state = S_MEGITHOK
								s.scale = $/2
								s.extravalue1 = dist
								s.color = SKINCOLOR_WHITE
							end

							for i = 1, #mo.megido

								local s = mo.megido[i]

								if not s or not s.valid continue end

								if not s.extravalue1
									s.scale = min(FRACUNIT*3/2, $+ FRACUNIT/16)

									if i == #mo.megido	-- last ball
										if s.scale >= FRACUNIT*3/2

											if s.z > s.floorz

												-- then fall slooowly~
												s.momz = max(-FRACUNIT*10, $ - FRACUNIT/8)

												if timer%5 == 0
													local st = P_SpawnMobj(s.x + P_RandomRange(-128, 128)<<FRACBITS, s.y + P_RandomRange(-128, 128)<<FRACBITS, s.z + P_RandomRange(-192, 192)<<FRACBITS, MT_DUMMY)
													st.color = SKINCOLOR_WHITE
													st.state = S_MEGISTAR1
													st.scale = $*2 + P_RandomRange(0, 65535)
													playSound(mo.battlen, sfx_hamas1)
												end
												mo.reachedtarget = timer
											else
												local time = timer-mo.reachedtarget
												s.momz = 0
												if time < 20
													s.scale = $ - FRACUNIT/20
													if time%2
														local st = P_SpawnMobj(s.x + P_RandomRange(-256, 256)<<FRACBITS, s.y + P_RandomRange(-256, 256)<<FRACBITS, s.z + P_RandomRange(-192, 192)<<FRACBITS, MT_DUMMY)
														st.color = SKINCOLOR_WHITE
														st.state = S_MEGISTAR1
														st.scale = $*2 + P_RandomRange(0, 65535)
														playSound(mo.battlen, sfx_hamas1)
													end
												elseif time == 20
													playSound(mo.battlen, sfx_megi5)
													for j = 1, 96
														local st = P_SpawnMobj(s.x, s.y, s.z + FRACUNIT*32, MT_DUMMY)
														st.state = S_MEGITHOK
														st.flags = $ & ~MF_NOGRAVITY
														st.momx = P_RandomRange(-128, 128)*FRACUNIT
														st.momy = P_RandomRange(-128, 128)*FRACUNIT
														st.momz = P_RandomRange(0, 128)*FRACUNIT
														st.fuse = TICRATE*4
														st.scale = FRACUNIT*2/3
													end

													for i = 1, #hittargets
														damageObject(hittargets[i])
													end
													P_RemoveMobj(s)
													break
												end
											end
										end

									elseif not s.extravalue2
										s.fuse = TICRATE
										s.extravalue2 = 1
									end
									continue
								end

								s.angle = $ + ANG1*12
								s.extravalue1 = max(0, $ - 6)

								local x = avgx + s.extravalue1*cos(s.angle)
								local y = avgy + s.extravalue1*sin(s.angle)
								s.z = $ + FRACUNIT*12
								P_TeleportMove(s, x, y, s.z)
							end
						end



	},

	["megidolaon"] = {
		name = "Megidolaon",
		type = ATK_ALMIGHTY,
		costtype = CST_SP,
		cost = 54,
		desc = "Severe Almighty damage to \nall enemies. Will break\nany barrier",
		target = TGT_ALLENEMIES,
		accuracy = 100,
		power = 900,
		anim =		function(mo, targets, hittargets, timer)

							local avgx, avgy = 0, 0
							for i = 1, #hittargets
								avgx = $ + hittargets[i].x/FRACUNIT
								avgy = $ + hittargets[i].y/FRACUNIT
							end
							avgx = ($/#hittargets)*FRACUNIT
							avgy = ($/#hittargets)*FRACUNIT

							if timer == 1
								mo.megido = {}
								mo.megiz = mo.z

							elseif timer >= 20 and timer <= 80

								if timer % 8 == 0
									local m = P_SpawnMobj(avgx + P_RandomRange(-512, 512)*FRACUNIT, avgy + P_RandomRange(-512, 512)*FRACUNIT, mo.z + FRACUNIT*512, MT_DUMMY)
									mo.megido[#mo.megido+1] = m
								end
							elseif timer >= 80 and timer <= 120

								mo.megiz = $+ FRACUNIT*8
								local m = P_SpawnMobj(avgx + P_RandomRange(-512, 512)*FRACUNIT, avgy + P_RandomRange(-512, 512)*FRACUNIT, mo.megiz, MT_DUMMY)
								m.state = S_MEGISTAR1

								if timer%3 == 0
									playSound(mo.battlen, sfx_hamas1)
								end

							elseif timer >= 130 and timer <= 228
								if timer == 130
									mo.megido2 = {}
								end

								local m
								-- column going up
								for i = 1, 2
									m = P_SpawnMobj(avgx + P_RandomRange(-64, 64)*FRACUNIT, avgy + P_RandomRange(-64, 64)*FRACUNIT, mo.z, MT_DUMMY)
									m.tics = -1
									m.color = SKINCOLOR_WHITE
									m.frame = FF_FULLBRIGHT
									m.scale = FRACUNIT*2
									m.momz = FRACUNIT*64
									m.fuse = TICRATE
								end

								local an = leveltime*ANG1*2
									if leveltime%2
									for i = 1, 3
										m = P_SpawnMobj(avgx, avgy, mo.z, MT_DUMMY)
										m.state = S_MEGITHOK
										m.scale = FRACUNIT*3/2
										m.fuse = TICRATE
										mo.megido2[#mo.megido2+1] = m
										m.extravalue = an + i*(360/8)*ANG1
										m.extravalue2 = 128 + (timer-130)*8
										m.momz = FRACUNIT*56
									end
								end


								m = P_SpawnMobj(avgx + P_RandomRange(-512, 512)*FRACUNIT, avgy + P_RandomRange(-512, 512)*FRACUNIT, mo.z + P_RandomRange(0, 512)*FRACUNIT, MT_DUMMY)
								m.state = S_MEGISTAR1
								m.scale = FRACUNIT*2

								if timer%3 == 0
									playSound(mo.battlen, sfx_hamas1)
								end

								if timer == 228
									for k,v in ipairs(hittargets)
										damageObject(v)
									end
								end

							end

							local i
							if mo.megido2
								i = #mo.megido2

								while i
									local h = mo.megido2[i]
									if not h or not h.valid
										table.remove(mo.megido2, i)
										i = $-1
										continue
									end

									P_TeleportMove(h, avgx + h.extravalue2*cos(h.extravalue), avgy + h.extravalue2*sin(h.extravalue), h.z)
									h.extravalue = $+ ANG1*64
									h.extravalue2 = $+8

									i = $-1

								end
							end

							i = mo.megido and #mo.megido or 0
							while i
								local m = mo.megido[i]
								m.momz = -FRACUNIT*64
								m.scale = FRACUNIT/2
								m.state = S_MEGITHOK

								if m.z <= mo.z
									playSound(mo.battlen, sfx_megi5)
									for j = 1, 32
										local st = P_SpawnMobj(m.x, m.y, m.z + FRACUNIT*32, MT_DUMMY)
										st.state = S_MEGITHOK
										st.flags = $ & ~MF_NOGRAVITY
										st.momx = P_RandomRange(-128, 128)*FRACUNIT
										st.momy = P_RandomRange(-128, 128)*FRACUNIT
										st.momz = P_RandomRange(0, 128)*FRACUNIT
										st.fuse = TICRATE*4
										st.scale = FRACUNIT/2
									end
									P_RemoveMobj(m)
									table.remove(mo.megido, i)
									i = $-1
									continue
								end
								i = $-1
							end

							if timer == 280
								return true
							end

					end,

	},

	["last resort"] = {
		name = "Last Resort",
		type = ATK_ALMIGHTY,
		power = 500,
		accuracy = 100,
		costtype = CST_SP,
		cost = 1,
		desc = "Heavy Almighty damage to\neveryone, but kills the caster.",
		target = TGT_EVERYONE,
		lastresort = true,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 1
				playSound(mo.battlen, sfx_debuff)
				mo.cloumns = {}

			elseif timer < TICRATE*3/2
				local h_angle = P_RandomRange(1, 359)*ANG1
				local v_angle = P_RandomRange(1, 359)*ANG1
				local dist = 256
				local spd = P_RandomRange(40, 50)

				local s_x = mo.x+ dist*FixedMul(cos(h_angle), cos(v_angle))
				local s_y = mo.y+ dist*FixedMul(sin(h_angle), cos(v_angle))
				local s_z = (mo.z+mo.height/2)+ dist* sin(v_angle)

				local s = P_SpawnMobj(s_x, s_y, s_z, MT_DUMMY)

				s.frame = A
				s.color = SKINCOLOR_WHITE
				s.scale = FRACUNIT*3/2
				s.destscale = FRACUNIT/5
				s.target = mo
				s.tics = 10
				s.momx = (mo.x - s.x)/10
				s.momy = (mo.y - s.y)/10
				s.momz = (mo.z - s.z)/10
			end

			local j = mo.columns and #mo.columns or 0
			while j
				local m = mo.columns[j]
				if not m or not m.valid
					j = $-1
					continue
				end

				for i = 1, 5
					local boom = P_SpawnMobj(m.x + P_RandomRange(-48, 48)*FRACUNIT, m.y + P_RandomRange(-48, 48)*FRACUNIT, m.z, MT_DUMMY)
					boom.state = S_QUICKBOOM1
					boom.momz = P_RandomRange(0, 48)*FRACUNIT
					boom.scale = FRACUNIT*3/2
				end
				localquake(mo.battlen, FRACUNIT*8, 1)
				j = $-1
			end


			if timer == TICRATE*3/2
				-- delet old shit:
				mo.fangle = (R_PointToAngle(target.x, target.y)) + ANG1*180
				mo.columns = {}
				playSound(mo.battlen, sfx_megi5)

				local a = mo.fangle - ANG1*80

				for i = 1, 16
					local m = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					P_InstaThrust(m, a, FRACUNIT*48)
					mo.columns[#mo.columns+1] = m
					m.state = S_INVISIBLE
					m.tics = TICRATE
					a = $+ ANG1*10
				end


				for i = 1, #hittargets
					if hittargets[i] ~= mo
						damageObject(hittargets[i])
					end
				end

				damageObject(mo, mo.maxhp, DMG_NORMAL, true)

				localquake(mo.battlen, FRACUNIT*50, 10)
				for i = 1, 4
					createSplat(mo)
				end
			end

			if timer == TICRATE*3
				mo.columns = nil
				mo.fangle = nil
				return true
			end
		end,
	},

	["cookie jar"] = {
		name = "Cookie Jar",
		type = ATK_ALMIGHTY,
		power = 500,
		accuracy = 100,
		costtype = CST_SP,
		cost = 1,
		desc = "Uses a Salon Free Pass to acquire cookie jars",
		target = TGT_EVERYONE,
		lastresort = true,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 1
				playSound(mo.battlen, sfx_debuff)
				mo.cloumns = {}

			elseif timer < TICRATE*3/2
				local h_angle = P_RandomRange(1, 359)*ANG1
				local v_angle = P_RandomRange(1, 359)*ANG1
				local dist = 256
				local spd = P_RandomRange(40, 50)

				local s_x = mo.x+ dist*FixedMul(cos(h_angle), cos(v_angle))
				local s_y = mo.y+ dist*FixedMul(sin(h_angle), cos(v_angle))
				local s_z = (mo.z+mo.height/2)+ dist* sin(v_angle)

				local s = P_SpawnMobj(s_x, s_y, s_z, MT_DUMMY)

				s.frame = A
				s.color = SKINCOLOR_WHITE
				s.scale = FRACUNIT*3/2
				s.destscale = FRACUNIT/5
				s.target = mo
				s.tics = 10
				s.momx = (mo.x - s.x)/10
				s.momy = (mo.y - s.y)/10
				s.momz = (mo.z - s.z)/10
			end

			local j = mo.columns and #mo.columns or 0
			while j
				local m = mo.columns[j]
				if not m or not m.valid
					j = $-1
					continue
				end

				for i = 1, 5
					local boom = P_SpawnMobj(m.x + P_RandomRange(-48, 48)*FRACUNIT, m.y + P_RandomRange(-48, 48)*FRACUNIT, m.z, MT_DUMMY)
					boom.state = S_QUICKBOOM1
					boom.momz = P_RandomRange(0, 48)*FRACUNIT
					boom.scale = FRACUNIT*3/2
				end
				localquake(mo.battlen, FRACUNIT*8, 1)
				j = $-1
			end


			if timer == TICRATE*3/2
				-- delet old shit:
				mo.fangle = (R_PointToAngle(target.x, target.y)) + ANG1*180
				mo.columns = {}
				playSound(mo.battlen, sfx_megi5)

				local a = mo.fangle - ANG1*80

				for i = 1, 16
					local m = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					P_InstaThrust(m, a, FRACUNIT*48)
					mo.columns[#mo.columns+1] = m
					m.state = S_INVISIBLE
					m.tics = TICRATE
					a = $+ ANG1*10
				end


				for i = 1, #hittargets
					if hittargets[i] ~= mo
						damageObject(hittargets[i])
					end
				end

				damageObject(mo, mo.maxhp, DMG_NORMAL, true)

				localquake(mo.battlen, FRACUNIT*50, 10)
				for i = 1, 4
					createSplat(mo)
				end
			end

			if timer == TICRATE*3
				mo.columns = nil
				mo.fangle = nil
				return true
			end
		end,
	},

	["sukunda"] = {
		name = "Sukunda",
		type = ATK_SUPPORT,
		costtype = CST_SP,
		cost = 6,
		desc = "Lower an enemy's agility \nby 1 stage.",
		target = TGT_ENEMY,
		debuff = true,
		norepel = true,
		nocast = 	function(targets, n)	-- we can't cast this skill if this function returns true
						local target = targets[n]
						if target.buffs["agi"][1] <= -75
							BTL_logMessage(targets[1].battlen, "Limit reached!")
							return true
						end
					end,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 20
				playSound(mo.battlen, sfx_debuff)
				local orb = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
				orb.sprite = SPR_DBUF
				orb.frame = A|TR_TRANS30
				orb.scale = FRACUNIT*2
				orb.scalespeed = FRACUNIT/32
				orb.destscale = FRACUNIT/6
				orb.tics = 2*TICRATE-15
				orb.color = SKINCOLOR_EMERALD

			elseif timer == 5+2*TICRATE
				buffStat(target, "agi", -BUFFSTEP)	-- negative values lower a stat
				playSound(mo.battlen, sfx_s3k8c)
				local dbuff = P_SpawnMobj(target.x, target.y, target.z+target.height, MT_DUMMY)
				dbuff.state = S_DBUFF1
				dbuff.color = SKINCOLOR_EMERALD
				dbuff.scale = FRACUNIT*5/2

			elseif timer == TICRATE*3
				return true
			end
		end,
	},

	["masukunda"] = {
		name = "Masukunda",
		type = ATK_SUPPORT,
		costtype = CST_SP,
		cost = 12,
		desc = "Lower enemies' agility \nby 1 stage.",
		target = TGT_ALLENEMIES,
		debuff = true,
		norepel = true,
		anim = function(mo, targets, hittargets, timer)

			for i = 1, #targets do

				local target = targets[i]

				if timer == 20 + 8*(i-1)
					playSound(mo.battlen, sfx_debuff)
					local orb = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					orb.sprite = SPR_DBUF
					orb.frame = A|TR_TRANS30
					orb.scale = FRACUNIT*2
					orb.scalespeed = FRACUNIT/32
					orb.destscale = FRACUNIT/6
					orb.tics = 2*TICRATE-15
					orb.color = SKINCOLOR_EMERALD

				elseif timer == 5+2*TICRATE + 8*(i-1)
					buffStat(target, "agi", -BUFFSTEP)	-- negative values lower a stat
					playSound(mo.battlen, sfx_s3k8c)
					local dbuff = P_SpawnMobj(target.x, target.y, target.z+target.height, MT_DUMMY)
					dbuff.state = S_DBUFF1
					dbuff.color = SKINCOLOR_EMERALD
					dbuff.scale = FRACUNIT*5/2
				end
			end

			if timer == TICRATE*3 + 8*(#targets-1)
				return true
			end
		end,
	},

	["tarunda"] = {
		name = "Tarunda",
		type = ATK_SUPPORT,
		costtype = CST_SP,
		cost = 6,
		desc = "Lower an enemy's physical\nattack by 1 stage.",
		target = TGT_ENEMY,
		debuff = true,
		norepel = true,
		nocast = 	function(targets, n)	-- we can't cast this skill if this function returns true
						local target = targets[n]
						if target.buffs["atk"][1] <= -75
							BTL_logMessage(targets[1].battlen, "Limit reached!")
							return true
						end
					end,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 20
				playSound(mo.battlen, sfx_debuff)
				local orb = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
				orb.sprite = SPR_DBUF
				orb.frame = A|TR_TRANS30
				orb.scale = FRACUNIT*2
				orb.scalespeed = FRACUNIT/32
				orb.destscale = FRACUNIT/6
				orb.tics = 2*TICRATE-15
				orb.color = SKINCOLOR_ORANGE

			elseif timer == 5+2*TICRATE
				buffStat(target, "atk", -BUFFSTEP)	-- negative values lower a stat
				playSound(mo.battlen, sfx_s3k8c)
				local dbuff = P_SpawnMobj(target.x, target.y, target.z+target.height, MT_DUMMY)
				dbuff.state = S_DBUFF1
				dbuff.color = SKINCOLOR_ORANGE
				dbuff.scale = FRACUNIT*5/2

			elseif timer == TICRATE*3
				return true
			end
		end,
	},

	["matarunda"] = {
		name = "Matarunda",
		type = ATK_SUPPORT,
		costtype = CST_SP,
		cost = 12,
		desc = "Lower enemies' physical\nattack by 1 stage.",
		target = TGT_ALLENEMIES,
		debuff = true,
		norepel = true,
		anim = function(mo, targets, hittargets, timer)

			for i = 1, #targets do

				local target = targets[i]

				if timer == 20 + 8*(i-1)
					playSound(mo.battlen, sfx_debuff)
					local orb = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					orb.sprite = SPR_DBUF
					orb.frame = A|TR_TRANS30
					orb.scale = FRACUNIT*2
					orb.scalespeed = FRACUNIT/32
					orb.destscale = FRACUNIT/6
					orb.tics = 2*TICRATE-15
					orb.color = SKINCOLOR_ORANGE

				elseif timer == 5+2*TICRATE + 8*(i-1)
					buffStat(target, "atk", -BUFFSTEP)	-- negative values lower a stat
					playSound(mo.battlen, sfx_s3k8c)
					local dbuff = P_SpawnMobj(target.x, target.y, target.z+target.height, MT_DUMMY)
					dbuff.state = S_DBUFF1
					dbuff.color = SKINCOLOR_ORANGE
					dbuff.scale = FRACUNIT*5/2
				end
			end

			if timer == TICRATE*3 + 8*(#targets-1)
				return true
			end
		end,
	},

	["makanda"] = {
		name = "Makanda",
		type = ATK_SUPPORT,
		costtype = CST_SP,
		cost = 6,
		desc = "Lower an enemy's magic\nattack by 1 stage.",
		target = TGT_ENEMY,
		debuff = true,
		norepel = true,
		nocast = 	function(targets, n)	-- we can't cast this skill if this function returns true
						local target = targets[n]
						if target.buffs["mag"][1] <= -75
							BTL_logMessage(targets[1].battlen, "Limit reached!")
							return true
						end
					end,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 20
				playSound(mo.battlen, sfx_debuff)
				local orb = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
				orb.sprite = SPR_DBUF
				orb.frame = A|TR_TRANS30
				orb.scale = FRACUNIT*2
				orb.scalespeed = FRACUNIT/32
				orb.destscale = FRACUNIT/6
				orb.tics = 2*TICRATE-15
				orb.color = SKINCOLOR_TEAL

			elseif timer == 5+2*TICRATE
				buffStat(target, "mag", -BUFFSTEP)	-- negative values lower a stat
				playSound(mo.battlen, sfx_s3k8c)
				local dbuff = P_SpawnMobj(target.x, target.y, target.z+target.height, MT_DUMMY)
				dbuff.state = S_DBUFF1
				dbuff.color = SKINCOLOR_TEAL
				dbuff.scale = FRACUNIT*5/2

			elseif timer == TICRATE*3
				return true
			end
		end,
	},

	["mamakanda"] = {
		name = "Mamakanda",
		type = ATK_SUPPORT,
		costtype = CST_SP,
		cost = 12,
		desc = "Lower enemies' magic\nattack by 1 stage.",
		target = TGT_ALLENEMIES,
		debuff = true,
		norepel = true,
		anim = function(mo, targets, hittargets, timer)

			for i = 1, #targets do

				local target = targets[i]

				if timer == 20 + 8*(i-1)
					playSound(mo.battlen, sfx_debuff)
					local orb = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					orb.sprite = SPR_DBUF
					orb.frame = A|TR_TRANS30
					orb.scale = FRACUNIT*2
					orb.scalespeed = FRACUNIT/32
					orb.destscale = FRACUNIT/6
					orb.tics = 2*TICRATE-15
					orb.color = SKINCOLOR_TEAL

				elseif timer == 5+2*TICRATE + 8*(i-1)
					buffStat(target, "mag", -BUFFSTEP)	-- negative values lower a stat
					playSound(mo.battlen, sfx_s3k8c)
					local dbuff = P_SpawnMobj(target.x, target.y, target.z+target.height, MT_DUMMY)
					dbuff.state = S_DBUFF1
					dbuff.color = SKINCOLOR_TEAL
					dbuff.scale = FRACUNIT*5/2
				end
			end

			if timer == TICRATE*3 + 8*(#targets-1)
				return true
			end
		end,
	},

	["rakunda"] = {
		name = "Rakunda",
		type = ATK_SUPPORT,
		costtype = CST_SP,
		cost = 6,
		desc = "Lower an enemy's defence \nby 1 stage.",
		target = TGT_ENEMY,
		debuff = true,
		norepel = true,
		nocast = 	function(targets, n)	-- we can't cast this skill if this function returns true
						local target = targets[n]
						if target.buffs["def"][1] <= -75
							BTL_logMessage(targets[1].battlen, "Limit reached!")
							return true
						end
					end,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 20
				playSound(mo.battlen, sfx_debuff)
				local orb = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
				orb.sprite = SPR_DBUF
				orb.frame = A|TR_TRANS30
				orb.scale = FRACUNIT*2
				orb.scalespeed = FRACUNIT/32
				orb.destscale = FRACUNIT/6
				orb.tics = 2*TICRATE-15
				orb.color = SKINCOLOR_LAVENDER

			elseif timer == 5+2*TICRATE
				buffStat(target, "def", -BUFFSTEP)	-- negative values lower a stat
				playSound(mo.battlen, sfx_s3k8c)
				local dbuff = P_SpawnMobj(target.x, target.y, target.z+target.height, MT_DUMMY)
				dbuff.state = S_DBUFF1
				dbuff.color = SKINCOLOR_LAVENDER
				dbuff.scale = FRACUNIT*5/2

			elseif timer == TICRATE*3
				return true
			end
		end,
	},

	["marakunda"] = {
		name = "Marakunda",
		type = ATK_SUPPORT,
		costtype = CST_SP,
		cost = 12,
		desc = "Lower enemies' defence \nby 1 stage.",
		target = TGT_ALLENEMIES,
		debuff = true,
		norepel = true,
		anim = function(mo, targets, hittargets, timer)

			for i = 1, #targets do

				local target = targets[i]

				if timer == 20 + 8*(i-1)
					playSound(mo.battlen, sfx_debuff)
					local orb = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					orb.sprite = SPR_DBUF
					orb.frame = A|TR_TRANS30
					orb.scale = FRACUNIT*2
					orb.scalespeed = FRACUNIT/32
					orb.destscale = FRACUNIT/6
					orb.tics = 2*TICRATE-15
					orb.color = SKINCOLOR_LAVENDER

				elseif timer == 5+2*TICRATE + 8*(i-1)
					buffStat(target, "def", -BUFFSTEP)	-- negative values lower a stat
					playSound(mo.battlen, sfx_s3k8c)
					local dbuff = P_SpawnMobj(target.x, target.y, target.z+target.height, MT_DUMMY)
					dbuff.state = S_DBUFF1
					dbuff.color = SKINCOLOR_LAVENDER
					dbuff.scale = FRACUNIT*5/2
				end
			end

			if timer == TICRATE*3 + 8*(#targets-1)
				return true
			end
		end,
	},

	["sukukaja"] = {
		name = "Sukukaja",
		type = ATK_SUPPORT,
		costtype = CST_SP,
		cost = 6,
		desc = "Raise one ally's agility \nby 1 stage.",
		target = TGT_ALLY,
		buff = true,
		norepel = true,
		nocast = 	function(targets, n)	-- we can't cast this skill if this function returns true
						local target = targets[n]
						if target.buffs["agi"][2] >= 9
							BTL_logMessage(targets[1].battlen, "Limit reached!")
							return true
						end
					end,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 20
				playSound(mo.battlen, sfx_buff)
				buffStat(target, "agi")
				for i = 1,16
					local dust = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					dust.angle = ANGLE_90 + ANG1* (22*(i-1))
					dust.state = S_CDUST1
					P_InstaThrust(dust, dust.angle, 30*FRACUNIT)
					dust.color = SKINCOLOR_GREEN
					dust.scale = FRACUNIT*2
				end

			elseif timer > 20 and timer <= 50

				if leveltime%2 == 0
					for i = 1,16

						local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
						thok.state = S_CDUST1
						thok.momz = P_RandomRange(3, 10)*FRACUNIT
						thok.color = SKINCOLOR_GREEN
						thok.tics = P_RandomRange(10, 35)
						thok.scale = FRACUNIT*3/2
					end
				end

				local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
				thok.sprite = SPR_SUMN
				thok.frame = F|FF_FULLBRIGHT|TR_TRANS50
				thok.momz = P_RandomRange(6, 16)*FRACUNIT
				thok.color = SKINCOLOR_GREEN
				thok.tics = P_RandomRange(10, 35)
			elseif timer == 60
				return true
			end
		end,
	},

	["debilitate"] = {
		name = "Debilitate",
		type = ATK_SUPPORT,
		costtype = CST_SP,
		cost = 24,
		desc = "Lower all of an enemy's stats \nby 1 stage.",
		target = TGT_ENEMY,
		norepel = true,
		superdebuff = true,	-- powerful debuff
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]
			local colors = {SKINCOLOR_ORANGE, SKINCOLOR_TEAL, SKINCOLOR_LAVENDER, SKINCOLOR_EMERALD}
			local strs = {"atk", "mag", "def", "agi"}

			for i = 1, 4 do

				if timer == 20 + (i-1)*12
					playSound(mo.battlen, sfx_debuff)
					local orb = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					orb.sprite = SPR_DBUF
					orb.frame = A|TR_TRANS30
					orb.scale = FRACUNIT*2
					orb.scalespeed = FRACUNIT/32
					orb.destscale = FRACUNIT/6
					orb.tics = 2*TICRATE-15
					orb.color = colors[i]

				elseif timer == 5+2*TICRATE + (i-1)*12
					buffStat(target, strs[i], -25)	-- negative values lower a stat
					playSound(mo.battlen, sfx_s3k8c)
					local dbuff = P_SpawnMobj(target.x, target.y, target.z+target.height, MT_DUMMY)
					dbuff.state = S_DBUFF1
					dbuff.color = colors[i]
					dbuff.scale = FRACUNIT*5/2
				end
			end

			if timer == TICRATE*4
				return true
			end
		end,
	},

	["me patra"] = {
		name = "Me Patra",
		type = ATK_HEAL,
		costtype = CST_SP,
		cost = 12,
		desc = "Remove status conditions \nfrom the party",
		target = TGT_ALLALLIES,
		anim = function(mo, targets, hittargets, timer)
			local colors = {SKINCOLOR_ORANGE, SKINCOLOR_LAVENDER, SKINCOLOR_EMERALD}

			for i = 1, #targets
				local target = targets[i]
				if timer == 20 + (i-1)*10
					playSound(mo.battlen, sfx_status)
					for j = 1, 16
						local orb = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
						orb.momx = P_RandomRange(-16, 16)<<FRACBITS
						orb.momy = P_RandomRange(-16, 16)<<FRACBITS
						orb.momz = P_RandomRange(-16, 16)<<FRACBITS
						orb.destscale = 0
						orb.frame = A
						orb.color = colors[P_RandomRange(1, #colors)]
					end
					if target.status_condition and target.status_condition < COND_HYPER
						cureStatus(target)
					end
					BTL_logMessage(targets[1].battlen, "Status nullified")
				end
			end
			if timer == TICRATE*3/2 + (#targets-1)*10
				return true
			end
		end,
	},

	["patra"] = {
		name = "Patra",
		type = ATK_HEAL,
		costtype = CST_SP,
		cost = 5,
		desc = "Remove status conditions \nfrom 1 ally",
		target = TGT_ALLY,
		anim = function(mo, targets, hittargets, timer)
			local colors = {SKINCOLOR_ORANGE, SKINCOLOR_LAVENDER, SKINCOLOR_EMERALD}

			local target = hittargets[1]
			if timer == 20
				playSound(mo.battlen, sfx_status)
				for j = 1, 16
					local orb = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					orb.momx = P_RandomRange(-16, 16)<<FRACBITS
					orb.momy = P_RandomRange(-16, 16)<<FRACBITS
					orb.momz = P_RandomRange(-16, 16)<<FRACBITS
					orb.destscale = 0
					orb.frame = A
					orb.color = colors[P_RandomRange(1, #colors)]
				end
				if target.status_condition and target.status_condition < COND_HYPER
					cureStatus(target)
				end
				BTL_logMessage(targets[1].battlen, "Status nullified")
			end
			if timer == TICRATE*3/2
				return true
			end
		end,
	},

	["dekaja"] = {
		name = "Dekaja",
		dekaja = true,	-- acts as dekaja. Used for enemy skill recognition. Add to your custom attack if you want it to be recognized as such
		type = ATK_SUPPORT,
		costtype = CST_SP,
		cost = 10,
		desc = "Remove enemy buffs",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)
			local colors = {SKINCOLOR_ORANGE, SKINCOLOR_LAVENDER, SKINCOLOR_EMERALD, SKINCOLOR_YELLOW}
			local strs = {"atk", "mag", "def", "agi", "crit"}

			for i = 1, #targets
				local target = targets[i]
				if timer == 20 + (i-1)*10
					playSound(mo.battlen, sfx_status)
					for j = 1, 16
						local orb = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
						orb.momx = P_RandomRange(-16, 16)<<FRACBITS
						orb.momy = P_RandomRange(-16, 16)<<FRACBITS
						orb.momz = P_RandomRange(-16, 16)<<FRACBITS
						orb.destscale = 0
						orb.frame = A
						orb.color = colors[P_RandomRange(1, #colors)]
					end
					for j = 1, #strs
						local t = targets[i]
						local s = strs[j]
						if t.buffs[s][1] > 0
							t.buffs[s][1] = 0
							t.buffs[s][2] = 0
						end
					end
					BTL_logMessage(targets[1].battlen, "Stat increases nullified")
				end
			end
			if timer == TICRATE*3/2 + (#targets-1)*10
				return true
			end
		end,
	},

	["dekunda"] = {
		name = "Dekunda",
		dekunda = true,	-- see above w/ dekaja
		type = ATK_SUPPORT,
		costtype = CST_SP,
		cost = 10,
		desc = "Remove party debuffs",
		target = TGT_ALLALLIES,
		anim = function(mo, targets, hittargets, timer)
			local colors = {SKINCOLOR_ORANGE, SKINCOLOR_LAVENDER, SKINCOLOR_EMERALD, SKINCOLOR_YELLOW}
			local strs = {"atk", "mag", "def", "agi", "crit"}

			for i = 1, #targets
				local target = targets[i]
				if timer == 20 + (i-1)*10
					playSound(mo.battlen, sfx_status)
					for j = 1, 16
						local orb = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
						orb.momx = P_RandomRange(-16, 16)<<FRACBITS
						orb.momy = P_RandomRange(-16, 16)<<FRACBITS
						orb.momz = P_RandomRange(-16, 16)<<FRACBITS
						orb.destscale = 0
						orb.frame = A
						orb.color = colors[P_RandomRange(1, #colors)]
					end
					for j = 1, #strs
						local t = targets[i]
						local s = strs[j]
						if t.buffs[s][1] < 0
							t.buffs[s][1] = 0
							t.buffs[s][2] = 0
						end
					end
					BTL_logMessage(targets[1].battlen, "Stat decreases nullified")
				end
			end
			if timer == TICRATE*3/2 + (#targets-1)*10
				return true
			end
		end,
	},

	["masukukaja"] = {
		name = "Masukukaja",
		type = ATK_SUPPORT,
		costtype = CST_SP,
		cost = 12,
		desc = "Raise allies's agility \nby 1 stage.",
		target = TGT_ALLALLIES,
		buff = true,	-- is a buff
		anim = function(mo, targets, hittargets, timer)

			for i = 1, #targets do

				local target = targets[i]

				if timer == 20 + (i-1)*16
					playSound(mo.battlen, sfx_buff)
					buffStat(target, "agi")
					for i = 1,16
						local dust = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
						dust.angle = ANGLE_90 + ANG1* (22*(i-1))
						dust.state = S_CDUST1
						P_InstaThrust(dust, dust.angle, 30*FRACUNIT)
						dust.color = SKINCOLOR_EMERALD
						dust.scale = FRACUNIT*2
					end

				elseif timer > 20 + (i-1)*16 and timer <= 50 + (i-1)*16

					if leveltime%2 == 0
						for i = 1,16

							local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
							thok.state = S_CDUST1
							thok.momz = P_RandomRange(3, 10)*FRACUNIT
							thok.color = SKINCOLOR_EMERALD
							thok.tics = P_RandomRange(10, 35)
							thok.scale = FRACUNIT*3/2
						end
					end

					for i = 1, 8
						local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
						thok.sprite = SPR_SUMN
						thok.frame = F|FF_FULLBRIGHT|TR_TRANS50
						thok.momz = P_RandomRange(6, 16)*FRACUNIT
						thok.color = SKINCOLOR_EMERALD
						thok.tics = P_RandomRange(10, 35)
					end
				end
			end
			if timer == 60 + (#targets-1)*16
				return true
			end
		end,
	},

	["rakukaja"] = {
		name = "Rakukaja",
		type = ATK_SUPPORT,
		costtype = CST_SP,
		cost = 6,
		desc = "Raise one ally's defence \nby 1 stage.",
		target = TGT_ALLY,
		buff = true,
		nocast = 	function(targets, n)	-- we can't cast this skill if this function returns true
						local target = targets[n]
						if target.buffs["def"][1] >= 75
							BTL_logMessage(targets[1].battlen, "Limit reached!")
							return true
						end
					end,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 20
				playSound(mo.battlen, sfx_buff)
				buffStat(target, "def")
				for i = 1,16
					local dust = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					dust.angle = ANGLE_90 + ANG1* (22*(i-1))
					dust.state = S_CDUST1
					P_InstaThrust(dust, dust.angle, 30*FRACUNIT)
					dust.color = SKINCOLOR_LAVENDER
					dust.scale = FRACUNIT*2
				end

			elseif timer > 20 and timer <= 50

				if leveltime%2 == 0
					for i = 1,16

						local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
						thok.state = S_CDUST1
						thok.momz = P_RandomRange(3, 10)*FRACUNIT
						thok.color = SKINCOLOR_LAVENDER
						thok.tics = P_RandomRange(10, 35)
						thok.scale = FRACUNIT*3/2
					end
				end

				for i = 1, 8
					local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
					thok.sprite = SPR_SUMN
					thok.frame = F|FF_FULLBRIGHT|TR_TRANS50
					thok.momz = P_RandomRange(6, 16)*FRACUNIT
					thok.color = SKINCOLOR_LAVENDER
					thok.tics = P_RandomRange(10, 35)
				end
			elseif timer == 60
				return true
			end
		end,
	},

	["marakukaja"] = {
		name = "Marakukaja",
		type = ATK_SUPPORT,
		costtype = CST_SP,
		cost = 12,
		desc = "Raise allies's defence \nby 1 stage.",
		target = TGT_ALLALLIES,
		buff = true,
		anim = function(mo, targets, hittargets, timer)

			for i = 1, #targets do

				local target = targets[i]

				if timer == 20 + (i-1)*16
					playSound(mo.battlen, sfx_buff)
					buffStat(target, "def")
					for i = 1,16
						local dust = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
						dust.angle = ANGLE_90 + ANG1* (22*(i-1))
						dust.state = S_CDUST1
						P_InstaThrust(dust, dust.angle, 30*FRACUNIT)
						dust.color = SKINCOLOR_LAVENDER
						dust.scale = FRACUNIT*2
					end

				elseif timer > 20 + (i-1)*16 and timer <= 50 + (i-1)*16

					if leveltime%2 == 0
						for i = 1,16

							local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
							thok.state = S_CDUST1
							thok.momz = P_RandomRange(3, 10)*FRACUNIT
							thok.color = SKINCOLOR_LAVENDER
							thok.tics = P_RandomRange(10, 35)
							thok.scale = FRACUNIT*3/2
						end
					end

					for i = 1, 8
						local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
						thok.sprite = SPR_SUMN
						thok.frame = F|FF_FULLBRIGHT|TR_TRANS50
						thok.momz = P_RandomRange(6, 16)*FRACUNIT
						thok.color = SKINCOLOR_LAVENDER
						thok.tics = P_RandomRange(10, 35)
					end
				end
			end
			if timer == 60 + (#targets-1)*16
				return true
			end
		end,
	},

	["heat riser"] = {
		name = "Heat Riser",
		type = ATK_SUPPORT,
		costtype = CST_SP,
		cost = 24,
		desc = "Raise all of an ally's stats \nby 1 stage.",
		target = TGT_ALLY,
		superbuff = true,
		nocast = 	function(targets, n)	-- we can't cast this skill if this function returns true
						local target = targets[n]
						if target.buffs["atk"][1] >= 75
						and target.buffs["mag"][1] >= 75
						and target.buffs["agi"][1] >= 75
						and target.buffs["def"][1] >= 75
							BTL_logMessage(targets[1].battlen, "Limit reached!")
							return true
						end
					end,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			local colors = {SKINCOLOR_ORANGE, SKINCOLOR_TEAL, SKINCOLOR_LAVENDER, SKINCOLOR_EMERALD}

			if timer == 20
				playSound(mo.battlen, sfx_buff)
				buffStat(target, "atk")
				buffStat(target, "mag")
				buffStat(target, "def")
				buffStat(target, "agi")

				BTL_logMessage(targets[1].battlen, "All stats increased!")

				for i = 1,16
					local dust = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					dust.angle = ANGLE_90 + ANG1* (22*(i-1))
					dust.state = S_CDUST1
					P_InstaThrust(dust, dust.angle, 30*FRACUNIT)
					dust.color = SKINCOLOR_WHITE
					dust.scale = FRACUNIT*2
				end

			elseif timer > 20 and timer <= 50

				if leveltime%2 == 0
					for i = 1,16

						local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
						thok.state = S_CDUST1
						thok.momz = P_RandomRange(3, 10)*FRACUNIT
						thok.color = SKINCOLOR_WHITE
						thok.tics = P_RandomRange(10, 35)
						thok.scale = FRACUNIT*3/2
					end
				end

				for i = 1, 8
					local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
					thok.sprite = SPR_SUMN
					thok.frame = F|FF_FULLBRIGHT|TR_TRANS50
					thok.momz = P_RandomRange(6, 16)*FRACUNIT
					thok.color = colors[P_RandomRange(1, #colors)]
					thok.tics = P_RandomRange(10, 35)
				end
			elseif timer == 60
				return true
			end
		end,
	},

	["overdrive boost"] = {
		name = "Overdrive Boost",
		type = ATK_SUPPORT,
		costtype = CST_SP,
		cost = 20,
		desc = "Raise a random stat by 3 stages,\nbut lowers another stat.",
		target = TGT_CASTER,
		superbuff = true,
		nocast = 	function(targets, n)	-- we can't cast this skill if this function returns true
						local target = targets[n]
						if target.buffs["atk"][1] >= 75
						and target.buffs["mag"][1] >= 75
						and target.buffs["agi"][1] >= 75
						and target.buffs["def"][1] >= 75
							BTL_logMessage(targets[1].battlen, "Limit reached!")
							return true
						end
					end,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			local colors = {SKINCOLOR_ORANGE, SKINCOLOR_TEAL, SKINCOLOR_LAVENDER, SKINCOLOR_EMERALD}

			if timer == 20

				local stats = {"atk", "mag", "def", "agi"}
				local stat_names = {"Physical Attack", "Magic Attack", "Defence", "Agility"}

				local buffstat = P_RandomRange(1, #stats)
				local debuffstat = buffstat
				while debuffstat == buffstat
					debuffstat = P_RandomRange(1, #stats)
				end

				local str = stat_names[buffstat].." way up!\n"..stat_names[debuffstat].." down!"

				buffstat = stats[$]
				debuffstat = stats[$]

				buffStat(target, buffstat, 75)
				buffStat(target, debuffstat, -25)

				BTL_logMessage(target.battlen, str)

				playSound(mo.battlen, sfx_buff)

				for i = 1,16
					local dust = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					dust.angle = ANGLE_90 + ANG1* (22*(i-1))
					dust.state = S_CDUST1
					P_InstaThrust(dust, dust.angle, 30*FRACUNIT)
					dust.color = SKINCOLOR_RED
					dust.scale = FRACUNIT*2
				end

			elseif timer > 20 and timer <= 50

				if leveltime%2 == 0
					for i = 1,16

						local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
						thok.state = S_CDUST1
						thok.momz = P_RandomRange(3, 10)*FRACUNIT
						thok.color = SKINCOLOR_RED
						thok.tics = P_RandomRange(10, 35)
						thok.scale = FRACUNIT*3/2
					end
				end

				for i = 1, 8
					local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
					thok.sprite = SPR_SUMN
					thok.frame = F|FF_FULLBRIGHT|TR_TRANS50
					thok.momz = P_RandomRange(6, 16)*FRACUNIT
					thok.color = SKINCOLOR_RED
					thok.tics = P_RandomRange(10, 35)
				end
			elseif timer == 60
				return true
			end
		end,
	},

	["rebellion"] = {
		name = "Rebellion",
		type = ATK_SUPPORT,
		costtype = CST_SP,
		cost = 6,
		desc = "Raise one ally's Critical \nhit rate by 1 stage.",
		target = TGT_ALLY,
		buff = true,
		nocast = 	function(targets, n)	-- we can't cast this skill if this function returns true
						local target = targets[n]
						if target.buffs["crit"][1] >= 75
							BTL_logMessage(targets[1].battlen, "Limit reached!")
							return true
						end
					end,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 20
				playSound(mo.battlen, sfx_buff)
				playSound(mo.battlen, sfx_hamas1)
				buffStat(target, "crit")
				for i = 1,16
					local dust = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					dust.angle = ANGLE_90 + ANG1* (22*(i-1))
					dust.state = S_CDUST1
					P_InstaThrust(dust, dust.angle, 30*FRACUNIT)
					dust.color = SKINCOLOR_YELLOW
					dust.scale = FRACUNIT*2
				end

			elseif timer > 20 and timer <= 50

				if leveltime%2 == 0
					for i = 1,16

						local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
						thok.state = S_CDUST1
						thok.momz = P_RandomRange(3, 10)*FRACUNIT
						thok.color = SKINCOLOR_YELLOW
						thok.tics = P_RandomRange(10, 35)
						thok.scale = FRACUNIT*3/2
					end
				end

				for i = 1, 8
					local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
					thok.sprite = SPR_SUMN
					thok.frame = F|FF_FULLBRIGHT|TR_TRANS50
					thok.momz = P_RandomRange(6, 16)*FRACUNIT
					thok.color = SKINCOLOR_YELLOW
					thok.tics = P_RandomRange(10, 35)
				end
			elseif timer == 60
				return true
			end
		end,
	},

	["revolution"] = {
		name = "Revolution",
		type = ATK_SUPPORT,
		costtype = CST_SP,
		cost = 10,
		desc = "Raise everyone's Critical\nhit rate by 1 stage.",
		target = TGT_EVERYONE,
		buff = true,
		anim = function(mo, targets, hittargets, timer)

			for i = 1, #targets do

				local target = targets[i]

				if timer == 20 + (i-1)*8
					playSound(mo.battlen, sfx_buff)
					playSound(mo.battlen, sfx_hamas1)
					buffStat(target, "crit")
					for i = 1,16
						local dust = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
						dust.angle = ANGLE_90 + ANG1* (22*(i-1))
						dust.state = S_CDUST1
						P_InstaThrust(dust, dust.angle, 30*FRACUNIT)
						dust.color = SKINCOLOR_YELLOW
						dust.scale = FRACUNIT*2
					end

				elseif timer > 20 + (i-1)*8 and timer <= 50 + (i-1)*8

					if leveltime%2 == 0
						for i = 1,16

							local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
							thok.state = S_CDUST1
							thok.momz = P_RandomRange(3, 10)*FRACUNIT
							thok.color = SKINCOLOR_YELLOW
							thok.tics = P_RandomRange(10, 35)
							thok.scale = FRACUNIT*3/2
						end
					end

					for i = 1, 8
						local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
						thok.sprite = SPR_SUMN
						thok.frame = F|FF_FULLBRIGHT|TR_TRANS50
						thok.momz = P_RandomRange(6, 16)*FRACUNIT
						thok.color = SKINCOLOR_YELLOW
						thok.tics = P_RandomRange(10, 35)
					end
				end
			end
			if timer == 60 + (#targets-1)*16
				return true
			end
		end,
	},

	["tarukaja"] = {
		name = "Tarukaja",
		type = ATK_SUPPORT,
		costtype = CST_SP,
		cost = 6,
		desc = "Raise one ally's physical \nattack by 1 stage.",
		target = TGT_ALLY,
		buff = true,
		nocast = 	function(targets, n)	-- we can't cast this skill if this function returns true
						local target = targets[n]
						if target.buffs["atk"][1] >= 75
							BTL_logMessage(targets[1].battlen, "Limit reached!")
							return true
						end
					end,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 20
				playSound(mo.battlen, sfx_buff)
				buffStat(target, "atk")
				for i = 1,16
					local dust = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					dust.angle = ANGLE_90 + ANG1* (22*(i-1))
					dust.state = S_CDUST1
					P_InstaThrust(dust, dust.angle, 30*FRACUNIT)
					dust.color = SKINCOLOR_ORANGE
					dust.scale = FRACUNIT*2
				end

			elseif timer > 20 and timer <= 50

				if leveltime%2 == 0
					for i = 1,16

						local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
						thok.state = S_CDUST1
						thok.momz = P_RandomRange(3, 10)*FRACUNIT
						thok.color = SKINCOLOR_ORANGE
						thok.tics = P_RandomRange(10, 35)
						thok.scale = FRACUNIT*3/2
					end
				end

				for i = 1, 8
					local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
					thok.sprite = SPR_SUMN
					thok.frame = F|FF_FULLBRIGHT|TR_TRANS50
					thok.momz = P_RandomRange(6, 16)*FRACUNIT
					thok.color = SKINCOLOR_ORANGE
					thok.tics = P_RandomRange(10, 35)
				end
			elseif timer == 60
				return true
			end
		end,
	},

	["matarukaja"] = {
		name = "Matarukaja",
		type = ATK_SUPPORT,
		costtype = CST_SP,
		cost = 12,
		desc = "Raise allies's physical \nattack by 1 stage.",
		target = TGT_ALLALLIES,
		buff = true,
		anim = function(mo, targets, hittargets, timer)

			for i = 1, #targets do

				local target = targets[i]

				if timer == 20 + (i-1)*16
					playSound(mo.battlen, sfx_buff)
					buffStat(target, "atk")
					for i = 1,16
						local dust = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
						dust.angle = ANGLE_90 + ANG1* (22*(i-1))
						dust.state = S_CDUST1
						P_InstaThrust(dust, dust.angle, 30*FRACUNIT)
						dust.color = SKINCOLOR_ORANGE
						dust.scale = FRACUNIT*2
					end

				elseif timer > 20 + (i-1)*16 and timer <= 50 + (i-1)*16

					if leveltime%2 == 0
						for i = 1,16

							local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
							thok.state = S_CDUST1
							thok.momz = P_RandomRange(3, 10)*FRACUNIT
							thok.color = SKINCOLOR_ORANGE
							thok.tics = P_RandomRange(10, 35)
							thok.scale = FRACUNIT*3/2
						end
					end

					for i = 1, 8
						local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
						thok.sprite = SPR_SUMN
						thok.frame = F|FF_FULLBRIGHT|TR_TRANS50
						thok.momz = P_RandomRange(6, 16)*FRACUNIT
						thok.color = SKINCOLOR_ORANGE
						thok.tics = P_RandomRange(10, 35)
					end
				end
			end
			if timer == 60 + (#targets-1)*16
				return true
			end
		end,
	},

	["makakaja"] = {
		name = "Makakaja",
		type = ATK_SUPPORT,
		costtype = CST_SP,
		cost = 6,
		desc = "Raise one ally's magic \nattack by 1 stage.",
		target = TGT_ALLY,
		buff = true,
		nocast = 	function(targets, n)	-- we can't cast this skill if this function returns true
						local target = targets[n]
						if target.buffs["mag"][1] >= 75
							BTL_logMessage(targets[1].battlen, "Limit reached!")
							return true
						end
					end,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 20
				playSound(mo.battlen, sfx_buff)
				buffStat(target, "mag")
				for i = 1,16
					local dust = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					dust.angle = ANGLE_90 + ANG1* (22*(i-1))
					dust.state = S_CDUST1
					P_InstaThrust(dust, dust.angle, 30*FRACUNIT)
					dust.color = SKINCOLOR_TEAL
					dust.scale = FRACUNIT*2
				end

			elseif timer > 20 and timer <= 50

				if leveltime%2 == 0
					for i = 1,16

						local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
						thok.state = S_CDUST1
						thok.momz = P_RandomRange(3, 10)*FRACUNIT
						thok.color = SKINCOLOR_TEAL
						thok.tics = P_RandomRange(10, 35)
						thok.scale = FRACUNIT*3/2
					end
				end

				for i = 1, 8
					local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
					thok.sprite = SPR_SUMN
					thok.frame = F|FF_FULLBRIGHT|TR_TRANS50
					thok.momz = P_RandomRange(6, 16)*FRACUNIT
					thok.color = SKINCOLOR_TEAL
					thok.tics = P_RandomRange(10, 35)
				end
			elseif timer == 60
				return true
			end
		end,
	},

	["mamakakaja"] = {
		name = "Mamakakaja",
		type = ATK_SUPPORT,
		costtype = CST_SP,
		cost = 12,
		desc = "Raise allies's magic \nattack by 1 stage.",
		target = TGT_ALLALLIES,
		buff = true,
		anim = function(mo, targets, hittargets, timer)

			for i = 1, #targets do

				local target = targets[i]

				if timer == 20 + (i-1)*16
					playSound(mo.battlen, sfx_buff)
					buffStat(target, "mag")
					for i = 1,16
						local dust = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
						dust.angle = ANGLE_90 + ANG1* (22*(i-1))
						dust.state = S_CDUST1
						P_InstaThrust(dust, dust.angle, 30*FRACUNIT)
						dust.color = SKINCOLOR_TEAL
						dust.scale = FRACUNIT*2
					end

				elseif timer > 20 + (i-1)*16 and timer <= 50 + (i-1)*16

					if leveltime%2 == 0
						for i = 1,16

							local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
							thok.state = S_CDUST1
							thok.momz = P_RandomRange(3, 10)*FRACUNIT
							thok.color = SKINCOLOR_TEAL
							thok.tics = P_RandomRange(10, 35)
							thok.scale = FRACUNIT*3/2
						end
					end

					for i = 1, 8
						local thok = P_SpawnMobj(target.x+P_RandomRange(-70, 70)*FRACUNIT, target.y+P_RandomRange(-70, 70)*FRACUNIT, target.z+P_RandomRange(0, 50)*FRACUNIT, MT_DUMMY)
						thok.sprite = SPR_SUMN
						thok.frame = F|FF_FULLBRIGHT|TR_TRANS50
						thok.momz = P_RandomRange(6, 16)*FRACUNIT
						thok.color = SKINCOLOR_TEAL
						thok.tics = P_RandomRange(10, 35)
					end
				end
			end
			if timer == 60 + (#targets-1)*16
				return true
			end
		end,
	},

	["strike_1"] = {
		name = "Strike Attack",
		type = ATK_STRIKE,
		power = 40,
		accuracy = 90,
		costtype = CST_HP,
		cost = 0,
		norandom = true,	-- Don't allow this move to be selected in random pvp skills
		physical = true,	-- not a skill
		anim_norepel = true,	-- do not bounce back our ANIMATION
		desc = "Regular attack using the \nstrike attribute.",
		target = TGT_ENEMY,
		anim = 	function(mo, targets, hittargets, timer)
					local target = targets[1]
					local atarget = hittargets[1]
					if timer == 1
						ANIM_set(mo, mo.anim_walk, true)
						mo.reachedtarget = 0	-- yeah we can use variables here that you like it or not :^)
						mo.reachedat = 0
					end

					--if mo.reachedtarget < TICRATE/2
						mo.angle = R_PointToAngle2(mo.x, mo.y, target.x, target.y)
						P_InstaThrust(mo, mo.angle, FRACUNIT*30)
						if R_PointToDist2(mo.x, mo.y, target.x, target.y) < FRACUNIT*100
						or FixedHypot(mo.momx, mo.momy) < FRACUNIT*10	-- in case of bugs
							if not mo.reachedat
								mo.reachedat = timer
							end

							P_InstaThrust(mo, 0, 0)
							mo.reachedtarget = $+1

							if timer >= mo.reachedat + TICRATE*2
								return true
							elseif timer >= mo.reachedat+5
								forwardcharge(mo, mo.reachedat+5, timer, mo.sprite, mo.frame)
								if timer == mo.reachedat+10
									playSound(mo.battlen, sfx_phys)
									for i = 1, 2
										createSplat(mo)
									end
									damageObject(atarget)

									-- spawn slash and blood
									local s = P_SpawnMobj(target.x, target.y, target.z+20*FRACUNIT, MT_DUMMY)
									s.sprite = SPR_SLAS
									s.color = SKINCOLOR_RED
									s.frame = TR_TRANS50
									s.destscale = FRACUNIT*10
									s.scalespeed = FRACUNIT
									s.fuse = 4
									for i=1,10
										local b = P_SpawnMobj(target.x, target.y, target.z+20*FRACUNIT, MT_DUMMY)
										b.momx = P_RandomRange(-35, 35)*FRACUNIT
										b.momy = P_RandomRange(-35, 35)*FRACUNIT
										b.momz = P_RandomRange(-35, 35)*FRACUNIT
										b.color = SKINCOLOR_RED
										b.frame = A|FF_FULLBRIGHT
										b.scale = FRACUNIT/2
										b.destscale = FRACUNIT/12
										b.tics = 35
									end
								end
							end
						--end
					end
				end,
	},

	["pierce_1"] = {
		name = "Pierce Attack",
		type = ATK_PIERCE,
		power = 40,
		accuracy = 90,
		costtype = CST_HP,
		cost = 0,
		norandom = true,	-- Don't allow this move to be selected in random pvp skills
		physical = true,	-- not a skill
		anim_norepel = true,	-- do not bounce back our ANIMATION
		desc = "Regular attack using the \npierce attribute.",
		target = TGT_ENEMY,
		anim = 	function(mo, targets, hittargets, timer)
					local target = targets[1]
					local atarget = hittargets[1]
					if timer == 1
						ANIM_set(mo, mo.anim_walk, true)
						mo.reachedtarget = 0	-- yeah we can use variables here that you like it or not :^)
						mo.reachedat = 0
					end

					--if mo.reachedtarget < TICRATE/2
						mo.angle = R_PointToAngle2(mo.x, mo.y, target.x, target.y)
						P_InstaThrust(mo, mo.angle, FRACUNIT*44)
						if R_PointToDist2(mo.x, mo.y, target.x, target.y) < FRACUNIT*100
						or FixedHypot(mo.momx, mo.momy) < FRACUNIT*10	-- in case of bugs
							if not mo.reachedat
								mo.reachedat = timer
							end

							P_InstaThrust(mo, 0, 0)
							mo.reachedtarget = $+1

							if timer >= mo.reachedat + TICRATE*2
								return true
							elseif timer >= mo.reachedat+5
								forwardcharge(mo, mo.reachedat+5, timer, mo.sprite, mo.frame)
								if timer == mo.reachedat+10
									playSound(mo.battlen, sfx_phys)
									for i = 1, 2
										createSplat(mo)
									end
									damageObject(atarget)

									-- spawn slash and blood
									local s = P_SpawnMobj(target.x, target.y, target.z+20*FRACUNIT, MT_DUMMY)
									s.sprite = SPR_SLAS
									s.color = SKINCOLOR_RED
									s.frame = TR_TRANS50
									s.destscale = FRACUNIT*10
									s.scalespeed = FRACUNIT
									s.fuse = 4
									for i=1,10
										local b = P_SpawnMobj(target.x, target.y, target.z+20*FRACUNIT, MT_DUMMY)
										b.momx = P_RandomRange(-35, 35)*FRACUNIT
										b.momy = P_RandomRange(-35, 35)*FRACUNIT
										b.momz = P_RandomRange(-35, 35)*FRACUNIT
										b.color = SKINCOLOR_RED
										b.frame = A|FF_FULLBRIGHT
										b.scale = FRACUNIT/2
										b.destscale = FRACUNIT/12
										b.tics = 35
									end
								end
							end
						--end
					end
				end,
	},

	["mnemesis_patk"] = {
		name = "Almighty Attack",
		type = ATK_ALMIGHTY,
		power = 400,
		accuracy = 90,
		costtype = CST_HPPERCENT,
		cost = 12,
		critical = 2,
		physical = true,
		anim_norepel = true,
		desc = "Medium slash damage to \nall enemies up to\n2 times",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)

			if timer == 10
				mo.dbs = {}
				playSound(mo.battlen, sfx_cboom)
				-- ready smoke table
			end

			-- spawn said smoke:
			if timer >= 10 and timer <= TICRATE + TICRATE/2
			and mo.dbs

				for i = 1, 8
					local s = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
					s.state = S_CDUST1
					s.color = SKINCOLOR_BLACK
					s.angle = P_RandomRange(0, 359)*ANG1
					s.scale = FRACUNIT*3
					s.scalespeed = FRACUNIT/6
					s.destscale = FRACUNIT*12
					s.dist = 0
					s.tics = 18
					mo.dbs[#mo.dbs+1] = s
				end
			end

			-- rotate the smoke
			if mo.dbs and #mo.dbs
				for i = 1, #mo.dbs do
					local s = mo.dbs[i]
					if not s or not s.valid continue end	-- don't care

					s.angle = $+ ANG1*10
					s.dist = min(1024, $+32)

					P_TeleportMove(s, mo.x + s.dist *cos(s.angle), mo.y + s.dist*sin(s.angle), s.floorz)

					if not P_RandomRange(0, 30)
						local t = P_SpawnMobj(s.x, s.y, s.z, MT_THOK)
						t.color = SKINCOLOR_RED
						t.frame = $|FF_FULLBRIGHT
						t.momz = P_RandomRange(4, 8)*FRACUNIT
						t.destscale = 1
						t.tics = TICRATE
						if P_RandomRange(0, 10) == 0
							S_StartSound(t, sfx_slash)
						end
					end
				end
			end

			-- hit targets
			for i = 1, #hittargets
				local target = hittargets[i]
				local t = timer - 6*(i-1)

				if t == TICRATE
					damageObject(target)
				end
			end

			if timer == TICRATE*2 + (#hittargets-1)*6
				return true
			end
		end,
	},

	["slash_1"] = {
		name = "Slash Attack",
		type = ATK_SLASH,
		power = 40,
		accuracy = 90,
		costtype = CST_HP,
		cost = 0,
		norandom = true,	-- Don't allow this move to be selected in random pvp skills
		physical = true,	-- not a skill
		anim_norepel = true,	-- do not bounce back our ANIMATION
		desc = "Regular attack using the \nslash attribute.",
		target = TGT_ENEMY,
		anim = 	function(mo, targets, hittargets, timer)
					local target = targets[1]
					local atarget = hittargets[1]
					if timer == 1
						ANIM_set(mo, mo.anim_walk, true)
						mo.reachedtarget = 0	-- yeah we can use variables here that you like it or not :^)
						mo.reachedat = 0
						local dist = R_PointToDist2(mo.x, mo.y, target.x, target.y)
						mo.angle = R_PointToAngle2(mo.x, mo.y, target.x, target.y)
						P_InstaThrust(mo, mo.angle, dist/16)
					end

					if R_PointToDist2(mo.x, mo.y, target.x, target.y) < FRACUNIT*100
					or FixedHypot(mo.momx, mo.momy) < FRACUNIT*10	-- in case of bugs
						if not mo.reachedat
							mo.reachedat = timer
						end

						P_InstaThrust(mo, 0, 0)
						mo.reachedtarget = $+1

						if timer >= mo.reachedat + TICRATE*2
							return true
						elseif timer >= mo.reachedat+5
							forwardcharge(mo, mo.reachedat+5, timer, mo.sprite, mo.frame)
							if timer == mo.reachedat+10
								playSound(mo.battlen, sfx_phys)
								for i = 1, 2
									createSplat(mo)
								end
								damageObject(atarget)

								-- spawn slash and blood
								local s = P_SpawnMobj(target.x, target.y, target.z+20*FRACUNIT, MT_DUMMY)
								s.sprite = SPR_SLAS
								s.color = SKINCOLOR_RED
								s.frame = TR_TRANS50
								s.destscale = FRACUNIT*10
								s.scalespeed = FRACUNIT
								s.fuse = 4
								for i=1,10
									local b = P_SpawnMobj(target.x, target.y, target.z+20*FRACUNIT, MT_DUMMY)
									b.momx = P_RandomRange(-35, 35)*FRACUNIT
									b.momy = P_RandomRange(-35, 35)*FRACUNIT
									b.momz = P_RandomRange(-35, 35)*FRACUNIT
									b.color = SKINCOLOR_RED
									b.frame = A|FF_FULLBRIGHT
									b.scale = FRACUNIT/2
									b.destscale = FRACUNIT/12
									b.tics = 35
								end
							end
						end
					end
				end,
	},

	["skewer"] = {

		name = "Skewer",				-- Name of the skill
		type = ATK_PIERCE,				-- Type of the skill (does not stack like affinities)
		power = 90,						-- Power of the skill
		accuracy = 90,					-- Accuracy (%) of the skill
		costtype = CST_HPPERCENT,		-- Cost type
		cost = 8,						-- Cost
		critical = 5,					-- Critical chance (%)
		desc = "Light Pierce damage to \none enemy.",	-- Description
		target = TGT_ENEMY,				-- Target type

		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 15
				local shot = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
				shot.state = S_STAB_1_1
				shot.color = SKINCOLOR_ORANGE
				shot.scale = FRACUNIT*3
				playSound(mo.battlen, sfx_hit)

				local d = P_SpawnMobj(target.x, target.y, target.z+128*FRACUNIT, MT_THOK)
				d.sprite = SPR_THMP
				d.frame = A|FF_FULLBRIGHT
				d.scale = FRACUNIT/4
				d.destscale = FRACUNIT*4
				d.scalespeed = FRACUNIT/8
				d.fuse = TICRATE-10
				d.tics = d.fuse
				d.momz = FRACUNIT*2
				d.momx = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
				d.momy = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
				d.color = SKINCOLOR_ORANGE

			elseif timer == 21
				playSound(mo.battlen, sfx_rail1)
				createSplat(mo)
				createSplat(mo)
				localquake(mo.battlen, FRACUNIT*10, 10)
				damageObject(target)	-- Damage our target

			elseif timer == 55
				return true
			end
		end,
	},

	["snap"] = {
		name = "Snap",
		type = ATK_PIERCE,
		power = 90,
		accuracy = 90,
		costtype = CST_HPPERCENT,
		technical = COND_FREEZE,
		cost = 6,
		critical = 5,
		desc = "Light Pierce damage to \none enemy.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 15
				local shot = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
				shot.state = S_STAB_1_1
				shot.color = SKINCOLOR_ORANGE
				shot.scale = FRACUNIT*3
				playSound(mo.battlen, sfx_hit)

				local d = P_SpawnMobj(target.x, target.y, target.z+128*FRACUNIT, MT_THOK)
				d.sprite = SPR_THMP
				d.frame = A|FF_FULLBRIGHT
				d.scale = FRACUNIT/4
				d.destscale = FRACUNIT*4
				d.scalespeed = FRACUNIT/8
				d.fuse = TICRATE-10
				d.tics = d.fuse
				d.momz = FRACUNIT*2
				d.momx = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
				d.momy = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
				d.color = SKINCOLOR_ORANGE

			elseif timer == 21
				playSound(mo.battlen, sfx_rail1)
				createSplat(mo)
				createSplat(mo)
				localquake(mo.battlen, FRACUNIT*10, 10)
				damageObject(target)

			elseif timer == 55
				return true
			end
		end,
	},

	["assault shot"] = {
		name = "Assault Shot",
		type = ATK_PIERCE,
		power = 180,
		accuracy = 90,
		costtype = CST_HPPERCENT,
		cost = 10,
		critical = 5,
		desc = "Medium Pierce damage to \none enemy.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 15
				local shot = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
				shot.state = S_STAB_1_1
				shot.color = SKINCOLOR_ORANGE
				shot.scale = FRACUNIT*3

				playSound(mo.battlen, sfx_hit)

				local d = P_SpawnMobj(target.x, target.y, target.z+128*FRACUNIT, MT_THOK)
				d.sprite = SPR_THMP
				d.frame = A|FF_FULLBRIGHT
				d.scale = FRACUNIT/4
				d.destscale = FRACUNIT*4
				d.scalespeed = FRACUNIT/8
				d.fuse = TICRATE-10
				d.tics = d.fuse
				d.momz = FRACUNIT*2
				d.momx = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
				d.momy = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
				d.color = SKINCOLOR_ORANGE

			elseif timer == 21
				playSound(mo.battlen, sfx_rail1)
				createSplat(mo)
				createSplat(mo)
				localquake(mo.battlen, FRACUNIT*10, 10)
				damageObject(target)

				for i = 1, 32 do
					local p = P_SpawnMobj(target.x, target.y, target.z+FRACUNIT*20, MT_DUMMY)
					p.flags = MF_NOCLIP|MF_NOCLIPHEIGHT|MF_NOGRAVITY
					p.state = S_SSPK1
					p.scale = mo.scale*2
					p.colorized = true
					p.color = SKINCOLOR_ORANGE
					p.angle = target.angle + P_RandomRange(-30, 30)*ANG1
					p.momz = P_RandomRange(-24, 24)*mo.scale
					P_InstaThrust(p, p.angle, mo.scale*64)
				end

			elseif timer == 55
				return true
			end
		end,
	},

	["heavy shot"] = {
		name = "Heavy Shot",
		type = ATK_PIERCE,
		power = 410,
		accuracy = 90,
		costtype = CST_HPPERCENT,
		cost = 13,
		critical = 5,
		desc = "Heavy Pierce damage to \none enemy.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer >= 15 and timer < 25
			and leveltime%6 == 0

				local shot = P_SpawnMobj(target.x + P_RandomRange(-60, 60)*mo.scale, target.y + P_RandomRange(-60, 60)*mo.scale, target.z + P_RandomRange(0, 80)*mo.scale, MT_DUMMY)
				shot.state = S_STAB_1_1
				shot.color = SKINCOLOR_ORANGE
				shot.scale = FRACUNIT/2
				playSound(mo.battlen, sfx_hit)

			elseif timer == 25
				local shot = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
				shot.state = S_STAB_1_1
				shot.color = SKINCOLOR_ORANGE
				shot.scale = FRACUNIT*5

				playSound(mo.battlen, sfx_hit)

				local d = P_SpawnMobj(target.x, target.y, target.z+128*FRACUNIT, MT_THOK)
				d.sprite = SPR_THMP
				d.frame = A|FF_FULLBRIGHT
				d.scale = FRACUNIT/4
				d.destscale = FRACUNIT*6
				d.scalespeed = FRACUNIT/8
				d.fuse = TICRATE-10
				d.tics = d.fuse
				d.momz = FRACUNIT*2
				d.momx = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
				d.momy = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
				d.color = SKINCOLOR_ORANGE

			elseif timer == 31
				playSound(mo.battlen, sfx_rail1)
				createSplat(mo)
				createSplat(mo)
				localquake(mo.battlen, FRACUNIT*10, 10)
				damageObject(target)

				for i = 1, 32 do
					local p = P_SpawnMobj(target.x, target.y, target.z+FRACUNIT*20, MT_DUMMY)
					p.flags = MF_NOCLIP|MF_NOCLIPHEIGHT|MF_NOGRAVITY
					p.state = S_SSPK1
					p.scale = mo.scale*4
					p.colorized = true
					p.color = SKINCOLOR_ORANGE
					p.angle = target.angle + P_RandomRange(-30, 30)*ANG1
					p.momz = P_RandomRange(-24, 24)*mo.scale
					P_InstaThrust(p, p.angle, mo.scale*64)
				end

			elseif timer == 55
				return true
			end
		end,
	},

	["pralaya"] = {
		name = "Pralaya",
		type = ATK_PIERCE,
		power = 680,
		accuracy = 100,
		costtype = CST_HPPERCENT,
		cost = 18,
		critical = 15,
		desc = "Severe Pierce damage to \none enemy.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 15	-- sound
				playSound(mo.battlen, sfx_bufu5)
			elseif timer >= 15 and timer <= 40

				for i = 1, 4
					local angle = target.angle + P_RandomRange(-30, 30)*ANG1
					local x = target.x + FixedMul(mo.scale, 256*cos(angle))
					local y = target.y + FixedMul(mo.scale, 256*sin(angle))
					local z = target.z + P_RandomRange(0, 256)*mo.scale

					local p = P_SpawnMobj(x, y, z, MT_DUMMY)
					p.flags = MF_NOCLIP|MF_NOCLIPHEIGHT|MF_NOGRAVITY
					p.state = S_SSPK1
					p.scale = mo.scale
					p.colorized = true
					p.color = SKINCOLOR_ORANGE
					p.angle = target.angle + P_RandomRange(-30, 30)*ANG1
					p.fuse = 10

					p.momx = (target.x - p.x)/10
					p.momy = (target.y - p.y)/10
					p.momz = (target.z - p.z)/10

				end

			elseif timer == 41
				playSound(mo.battlen, sfx_bufu6)
				createSplat(mo)
				createSplat(mo)
				localquake(mo.battlen, FRACUNIT*32, 10)
				damageObject(target)
				for i = 1, 32 do
					local p = P_SpawnMobj(target.x, target.y, target.z+FRACUNIT*20, MT_DUMMY)
					p.flags = MF_NOCLIP|MF_NOCLIPHEIGHT|MF_NOGRAVITY
					p.state = S_SSPK1
					p.scale = mo.scale
					p.colorized = true
					p.color = SKINCOLOR_ORANGE
					p.angle = target.angle + P_RandomRange(-30, 30)*ANG1
					p.momz = P_RandomRange(-24, 24)*mo.scale
					P_InstaThrust(p, p.angle, mo.scale*64)
				end

				local d = P_SpawnMobj(target.x, target.y, target.z+128*FRACUNIT, MT_THOK)
				d.sprite = SPR_THMP
				d.frame = A|FF_FULLBRIGHT
				d.scale = FRACUNIT/4
				d.destscale = FRACUNIT*6
				d.scalespeed = FRACUNIT/8
				d.fuse = TICRATE-10
				d.tics = d.fuse
				d.momz = FRACUNIT*2
				d.momx = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
				d.momy = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
				d.color = SKINCOLOR_ORANGE

			elseif timer >= 41 and timer < 80

				for i = 1, 8 do
					local p = P_SpawnMobj(target.x, target.y, target.z+FRACUNIT*20, MT_DUMMY)
					p.flags = MF_NOCLIP|MF_NOCLIPHEIGHT|MF_NOGRAVITY
					p.state = S_SSPK1
					p.scale = mo.scale
					p.colorized = true
					p.color = SKINCOLOR_ORANGE
					p.angle = target.angle + P_RandomRange(-30, 30)*ANG1
					p.momz = P_RandomRange(-12, 12)*mo.scale
					P_InstaThrust(p, p.angle, mo.scale*32)
				end

				local p = P_SpawnMobj(target.x + P_RandomRange(-12, 12)*mo.scale, target.y + P_RandomRange(-12, 12)*mo.scale, target.z + P_RandomRange(0, 12)*mo.scale, MT_DUMMY)
				p.flags = MF_NOCLIP|MF_NOCLIPHEIGHT|MF_NOGRAVITY
				p.state = S_SSPK1
				p.scale = mo.scale*2
				p.colorized = true
				p.color = SKINCOLOR_ORANGE
				P_InstaThrust(p, target.angle, -mo.scale*64)

			elseif timer == 80
				return true
			end
		end,
	},

	["double fang"] = {
		name = "Double Fang",
		type = ATK_PIERCE,
		power = 80,
		accuracy = 80,
		costtype = CST_HPPERCENT,
		technical = COND_FREEZE,
		cost = 11,
		critical = 2,
		hits = 2,
		desc = "Light Pierce damage to \none enemy 2x",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 15
			or timer == 25
				local shot = P_SpawnMobj(target.x + P_RandomRange(-170, 170)*FRACUNIT, target.y + P_RandomRange(-170, 170)*FRACUNIT, target.z + P_RandomRange(0, 180)*FRACUNIT, MT_DUMMY)
				shot.state = S_STAB_1_1
				shot.color = SKINCOLOR_ORANGE
				shot.scale = FRACUNIT*3
				playSound(mo.battlen, sfx_hit)

				if timer == 25
					local d = P_SpawnMobj(target.x, target.y, target.z+128*FRACUNIT, MT_THOK)
					d.sprite = SPR_THMP
					d.frame = A|FF_FULLBRIGHT
					d.scale = FRACUNIT/4
					d.destscale = FRACUNIT*4
					d.scalespeed = FRACUNIT/8
					d.fuse = TICRATE-10
					d.tics = d.fuse
					d.momz = FRACUNIT*2
					d.momx = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
					d.momy = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
					d.color = SKINCOLOR_ORANGE
				end

			elseif timer == 21
			or timer == 31
				playSound(mo.battlen, sfx_rail1)
				createSplat(mo)
				createSplat(mo)
				localquake(mo.battlen, FRACUNIT*10, 10)
				damageObject(target)

			elseif timer == 65
				return true
			end
		end,
	},

	["poison arrow"] = {
		name = "Poison Arrow",
		type = ATK_PIERCE,
		power = 180,
		accuracy = 90,
		status = COND_POISON,
		statuschance = 30,
		costtype = CST_HPPERCENT,
		technical = COND_FREEZE,
		cost = 8,
		critical = 5,
		desc = "Light Pierce damage to \none enemy. Medium chance of poison",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 15
				local shot = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
				shot.state = S_STAB_1_1
				shot.color = SKINCOLOR_PURPLE
				shot.scale = FRACUNIT*3
				playSound(mo.battlen, sfx_hit)

				local d = P_SpawnMobj(target.x, target.y, target.z+128*FRACUNIT, MT_THOK)
				d.sprite = SPR_THMP
				d.frame = A|FF_FULLBRIGHT
				d.scale = FRACUNIT/4
				d.destscale = FRACUNIT*4
				d.scalespeed = FRACUNIT/8
				d.fuse = TICRATE-10
				d.tics = d.fuse
				d.momz = FRACUNIT*2
				d.momx = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
				d.momy = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
				d.color = SKINCOLOR_PURPLE

			elseif timer == 21
				playSound(mo.battlen, sfx_rail1)
				createSplat(mo)
				createSplat(mo)
				localquake(mo.battlen, FRACUNIT*10, 10)
				damageObject(target)

			elseif timer == 55
				return true
			end
		end,
	},

	["cruel attack"] = {
		name = "Cruel Attack",
		type = ATK_PIERCE,
		power = 200,
		accuracy = 90,
		costtype = CST_HPPERCENT,
		downboost = 50,	-- +50% on fallen enemies
		cost = 10,
		critical = 5,
		desc = "Medium Pierce damage to \none enemy. 1.5x damage\non downed foes.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 15
				local shot = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
				shot.state = S_STAB_1_1
				shot.color = SKINCOLOR_RED
				shot.scale = FRACUNIT*3
				playSound(mo.battlen, sfx_hit)

				local d = P_SpawnMobj(target.x, target.y, target.z+128*FRACUNIT, MT_THOK)
				d.sprite = SPR_THMP
				d.frame = A|FF_FULLBRIGHT
				d.scale = FRACUNIT/4
				d.destscale = FRACUNIT*4
				d.scalespeed = FRACUNIT/8
				d.fuse = TICRATE-10
				d.tics = d.fuse
				d.momz = FRACUNIT*2
				d.momx = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
				d.momy = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
				d.color = SKINCOLOR_RED

			elseif timer == 21
				playSound(mo.battlen, sfx_rail1)
				createSplat(mo)
				createSplat(mo)
				localquake(mo.battlen, FRACUNIT*10, 10)
				damageObject(target)

			elseif timer == 55
				return true
			end
		end,
	},

	["vile assault"] = {
		name = "Vile Assault",
		type = ATK_PIERCE,
		power = 380,
		accuracy = 90,
		costtype = CST_HPPERCENT,
		downboost = 50,	-- +50% on fallen enemies
		cost = 14,
		critical = 5,
		desc = "Heavy Pierce damage to \none enemy. 1.5x damage\non downed foes.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 15
				local shot = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
				shot.state = S_STAB_1_1
				shot.color = SKINCOLOR_RED
				shot.scale = FRACUNIT*3
				playSound(mo.battlen, sfx_hit)

				local d = P_SpawnMobj(target.x, target.y, target.z+128*FRACUNIT, MT_THOK)
				d.sprite = SPR_THMP
				d.frame = A|FF_FULLBRIGHT
				d.scale = FRACUNIT/4
				d.destscale = FRACUNIT*4
				d.scalespeed = FRACUNIT/8
				d.fuse = TICRATE-10
				d.tics = d.fuse
				d.momz = FRACUNIT*2
				d.momx = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
				d.momy = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
				d.color = SKINCOLOR_RED

			elseif timer == 21
				playSound(mo.battlen, sfx_rail1)
				createSplat(mo)
				createSplat(mo)
				localquake(mo.battlen, FRACUNIT*10, 10)
				damageObject(target)

			elseif timer == 55
				return true
			end
		end,
	},

	["torrent shot"] = {
		name = "Torrent Shot",
		type = ATK_PIERCE,
		power = 55,
		accuracy = 80,
		costtype = CST_HPPERCENT,
		technical = COND_FREEZE,
		cost = 15,
		critical = 2,
		hits = 3,
		desc = "Light Pierce damage to \none enemy 3x",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer >= 15 and timer <= 45
			and not (timer%2)

				local shot = P_SpawnMobj(target.x + P_RandomRange(-150, 150)*FRACUNIT, target.y + P_RandomRange(-150, 150)*FRACUNIT, target.z + P_RandomRange(0, 150)*FRACUNIT, MT_DUMMY)
				if not (timer%4)
					playSound(mo.battlen, sfx_rail1)
				end
				shot.state = S_STAB_1_1
				shot.color = SKINCOLOR_ORANGE
				shot.scale = $ + P_RandomRange(0, 65535)*3

				if not (timer%8)
					createSplat(mo)
					localquake(mo.battlen, FRACUNIT*4, 4)
				end

			end
			if timer == 30
			or timer == 40
			or timer == 50
				damageObject(target)
			elseif timer == 85
				return true
			end
		end,
	},

	["god hand"] = {
		name = "God's hand",
		type = ATK_STRIKE,
		power = 780,
		accuracy = 100,
		costtype = CST_HPPERCENT,
		cost = 25,
		critical = 33,
		desc = "Severe Strike damage to \none enemy. Very high critical rate.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 16

				playSound(mo.battlen, sfx_becrsh)
				for i = 1, 16 do
					local atk = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					atk.momz = -1*FRACUNIT
					atk.state = S_AOADUST1
					atk.scale = FRACUNIT*1
					atk.destscale = FRACUNIT*2
					atk.angle = ANG1*360 / 16	* (i-1)
					P_InstaThrust(atk, atk.angle, 10*FRACUNIT)
				end

				target.hand = P_SpawnMobj(target.x, target.y, target.z + 500*FRACUNIT, MT_DUMMY)
				target.hand.momz = -25*FRACUNIT
				target.hand.tics = -1
				target.hand.sprite = SPR_HAND
				target.hand.frame = A
				target.hand.scale = FRACUNIT*4
				target.hand.fuse = TICRATE*8
			end

			local j = mo.columns and #mo.columns or 0
			while j
				local m = mo.columns[j]
				if not m or not m.valid
					j = $-1
					continue
				end

				for i = 1, 5
					local boom = P_SpawnMobj(m.x + P_RandomRange(-48, 48)*FRACUNIT, m.y + P_RandomRange(-48, 48)*FRACUNIT, m.z, MT_DUMMY)
					boom.state = S_QUICKBOOM1
					boom.momz = P_RandomRange(0, 48)*FRACUNIT
					boom.scale = FRACUNIT*3/2
				end
				localquake(mo.battlen, FRACUNIT*8, 1)
				j = $-1
			end

			if target.hand and target.hand.valid
				local h = target.hand

				if leveltime%4 == 0
					for i = 1, 16 do
						local atk = P_SpawnMobj(h.x, h.y, h.z, MT_DUMMY)
						atk.momz = -1*FRACUNIT
						atk.state = S_AOADUST1
						atk.scale = FRACUNIT*2
						atk.destscale = FRACUNIT*4
						atk.angle = ANG1*360 / 16	* (i-1)
						P_InstaThrust(atk, atk.angle, 30*FRACUNIT)
					end
				end

				for i = 1, 2
					local f = P_SpawnMobj(h.x + P_RandomRange(-32, 32)*FRACUNIT, h.y + P_RandomRange(-32, 32)*FRACUNIT, h.z + FRACUNIT*60, MT_DUMMY)
					f.state = S_QUICKBOOM1
					f.color = SKINCOLOR_RED
					f.scale = FRACUNIT*3
				end

				if timer == 16 + 20
					-- delet old shit:
					mo.fangle = (R_PointToAngle(target.x, target.y)) + ANG1*180
					mo.columns = {}

					local a = mo.fangle - ANG1*80

					for i = 1, 16
						local m = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
						P_InstaThrust(m, a, FRACUNIT*48)
						mo.columns[#mo.columns+1] = m
						m.state = S_INVISIBLE
						m.tics = TICRATE
						a = $+ ANG1*10
					end

					damageObject(target)

					localquake(mo.battlen, FRACUNIT*50, 10)
					for i = 1, 4
						createSplat(mo)
					end
				end

				if timer == 16 + 20 + TICRATE
					mo.columns = nil
					mo.fangle = nil
					return true
				end
			end
		end,
	},

	["gigantic fish"] = {
		name = "Gigantic Fish",
		type = ATK_STRIKE,
		power = 650,
		accuracy = 100,
		costtype = CST_HPPERCENT,
		cost = 25,
		critical = 10,
		desc = "fish",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 16

				playSound(mo.battlen, sfx_becrsh)
				for i = 1, 16 do
					local atk = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					atk.momz = -1*FRACUNIT
					atk.state = S_AOADUST1
					atk.scale = FRACUNIT*1
					atk.destscale = FRACUNIT*2
					atk.angle = ANG1*360 / 16	* (i-1)
					P_InstaThrust(atk, atk.angle, 10*FRACUNIT)
				end

				target.hand = P_SpawnMobj(target.x, target.y, target.z + 500*FRACUNIT, MT_DUMMY)
				target.hand.momz = -25*FRACUNIT
				target.hand.tics = -1
				target.hand.sprite = SPR_HAND
				target.hand.frame = B
				target.hand.scale = FRACUNIT*2
				target.hand.fuse = TICRATE*8
			end

			local j = mo.columns and #mo.columns or 0
			while j
				local m = mo.columns[j]
				if not m or not m.valid
					j = $-1
					continue
				end

				for i = 1, 5
					local boom = P_SpawnMobj(m.x + P_RandomRange(-48, 48)*FRACUNIT, m.y + P_RandomRange(-48, 48)*FRACUNIT, m.z, MT_DUMMY)
					boom.state = S_QUICKBOOM1
					boom.momz = P_RandomRange(0, 48)*FRACUNIT
					boom.scale = FRACUNIT*3/2
				end
				localquake(mo.battlen, FRACUNIT*8, 1)
				j = $-1
			end

			if target.hand and target.hand.valid
				local h = target.hand

				if leveltime%4 == 0
					for i = 1, 16 do
						local atk = P_SpawnMobj(h.x, h.y, h.z, MT_DUMMY)
						atk.momz = -1*FRACUNIT
						atk.state = S_AOADUST1
						atk.scale = FRACUNIT*2
						atk.destscale = FRACUNIT*4
						atk.angle = ANG1*360 / 16	* (i-1)
						P_InstaThrust(atk, atk.angle, 30*FRACUNIT)
					end
				end

				for i = 1, 2
					local f = P_SpawnMobj(h.x + P_RandomRange(-32, 32)*FRACUNIT, h.y + P_RandomRange(-32, 32)*FRACUNIT, h.z + FRACUNIT*60, MT_DUMMY)
					f.state = S_QUICKBOOM1
					f.color = SKINCOLOR_RED
					f.scale = FRACUNIT*3
				end

				if timer == 16 + 20
					-- delet old shit:
					mo.fangle = (R_PointToAngle(target.x, target.y)) + ANG1*180
					mo.columns = {}

					local a = mo.fangle - ANG1*80

					for i = 1, 16
						local m = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
						P_InstaThrust(m, a, FRACUNIT*48)
						mo.columns[#mo.columns+1] = m
						m.state = S_INVISIBLE
						m.tics = TICRATE
						a = $+ ANG1*10
					end

					damageObject(target)
					--S_StartSound(nil, sfx_fish)

					localquake(mo.battlen, FRACUNIT*50, 10)
					for i = 1, 4
						createSplat(mo)
					end
				end

				if timer == 16 + 20 + TICRATE
					mo.columns = nil
					mo.fangle = nil
					return true
				end
			end
		end,
	},

	["buchikamashi"] = {
		name = "Buchikamashi",
		type = ATK_STRIKE,
		power = 1420,
		accuracy = 95,
		costtype = CST_HPPERCENT,
		technical = COND_FREEZE,
		cost = 31,
		critical = 15,
		desc = "Severe Strike damage to \none enemy.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 20
				damageObject(target)
				playSound(mo.battlen, sfx_pstop)
				if not target.plyr
					createSplat(mo)
					createSplat(mo)
					localquake(mo.battlen, 14*FRACUNIT, 10)
				end
				for i=1,16
					local b = P_SpawnMobj(target.x, target.y, target.z+2*FRACUNIT, MT_DUMMY)
					b.momx = P_RandomRange(-3, 3)*FRACUNIT
					b.momy = P_RandomRange(-3, 3)*FRACUNIT
					b.momz = P_RandomRange(4, 16)*FRACUNIT
					b.state = S_AOADUST1
					b.frame = A|FF_FULLBRIGHT
					b.scale = FRACUNIT*3
					b.destscale = FRACUNIT/12
				end
				for i = 1,32
					local dust = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					dust.angle = ANGLE_90 + ANG1* (11*(i-1))
					dust.destscale = FRACUNIT*10
					dust.state = S_AOADUST1
					dust.frame = A|FF_FULLBRIGHT
					P_InstaThrust(dust, dust.angle, 20*FRACUNIT)
				end
			elseif timer == 45
				return true
			end
		end,
	},

	["megaton raid"] = {
		name = "Megaton Raid",
		type = ATK_STRIKE,
		power = 680,
		accuracy = 95,
		costtype = CST_HPPERCENT,
		technical = COND_FREEZE,
		cost = 18,
		critical = 5,
		desc = "Severe Strike damage to \none enemy.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 20
				damageObject(target)
				playSound(mo.battlen, sfx_pstop)
				if not target.plyr
					createSplat(mo)
					createSplat(mo)
					localquake(mo.battlen, 14*FRACUNIT, 10)
				end
				for i=1,16
					local b = P_SpawnMobj(target.x, target.y, target.z+2*FRACUNIT, MT_DUMMY)
					b.momx = P_RandomRange(-3, 3)*FRACUNIT
					b.momy = P_RandomRange(-3, 3)*FRACUNIT
					b.momz = P_RandomRange(4, 16)*FRACUNIT
					b.state = S_AOADUST1
					b.frame = A|FF_FULLBRIGHT
					b.scale = FRACUNIT*3
					b.destscale = FRACUNIT/12
				end
				for i = 1,32
					local dust = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					dust.angle = ANGLE_90 + ANG1* (11*(i-1))
					dust.destscale = FRACUNIT*10
					dust.state = S_AOADUST1
					dust.frame = A|FF_FULLBRIGHT
					P_InstaThrust(dust, dust.angle, 20*FRACUNIT)
				end
			elseif timer == 45
				return true
			end
		end,
	},

	["myriad slashes"] = {
		name = "Myriad Slashes",
		type = ATK_SLASH,
		power = 165,
		accuracy = 70,
		costtype = CST_HPPERCENT,
		cost = 20,
		critical = 5,
		technical = COND_FREEZE,
		hits = 3,
		desc = "Medium slash damage to \none enemy up to 3 times.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)

					local color = SKINCOLOR_TEAL
					local target = hittargets[1]

					if timer == 1
						target.rolls = {}

					elseif timer == 15
					or timer == 20
					or timer == 25	-- lazy
						local s = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
						s.state = S_SLASHING_2_1
						s.color = color
						s.scale = FRACUNIT*3
						playSound(mo.battlen, sfx_slash)
						s.rollangle = P_RandomRange(0, 359)*ANG1
						target.rolls[#target.rolls+1] = s.rollangle

					elseif timer == 17
					or timer == 22
					or timer == 27

						if (timer == 22)

							local d = P_SpawnMobj(target.x, target.y, target.z+128*FRACUNIT, MT_THOK)
							d.sprite = SPR_THMP
							d.frame = C|FF_FULLBRIGHT
							d.scale = FRACUNIT/4
							d.destscale = FRACUNIT*3
							d.scalespeed = FRACUNIT/8
							d.fuse = TICRATE-10
							d.tics = d.fuse
							d.momz = FRACUNIT*2
							d.momx = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
							d.momy = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
							d.color = color
						end


					elseif timer == 19
					or timer == 24
					or timer == 29

						if timer == 19
						or timer == 24
						or timer == 29
							damageObject(target)
							playSound(mo.battlen, sfx_bexpld)
							if not target.plyr
								createSplat(mo)
								createSplat(mo)
							end
							localquake(mo.battlen, FRACUNIT*10, 10)
						end

						local s = P_SpawnMobj(target.x, target.y, target.z+40*FRACUNIT, MT_THOK)
						s.sprite = SPR_SLSH
						s.frame = I|FF_FULLBRIGHT
						s.scale = FRACUNIT/2
						s.destscale = FRACUNIT*4
						s.scalespeed = FRACUNIT/3
						s.color = color

						s = P_SpawnMobj(target.x, target.y, target.z+40*FRACUNIT, MT_THOK)
						s.sprite = SPR_SLSH
						s.frame = G|FF_FULLBRIGHT
						s.scale = FRACUNIT/2
						s.tics = TICRATE/2
						s.fuse = s.tics
						s.destscale = FRACUNIT*10
						s.scalespeed = FRACUNIT/4
						s.color = color
						s.rollangle = target.rolls[#target.rolls]
					end
					if timer == 55
						return true
					end
				end,
	},

	["agneyastra"] = {
		name = "Agneyastra",
		type = ATK_STRIKE,
		power = 120,
		accuracy = 80,
		costtype = CST_HPPERCENT,
		cost = 20,
		critical = 1,
		hits = 3,
		desc = "Medium strike damage to \nall enemies up to 3 times.",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)

					if timer == TICRATE
					or timer == TICRATE*2 - 10
					or timer == TICRATE*3 - 20
						for i = 1, #hittargets
							damageObject(hittargets[i])
						end
					end

					if timer == 1
						mo.meteors = {}
					elseif timer >= 20 and timer <= TICRATE*3

						-- get an average of the enemy coords:
						local avgx, avgy = 0, 0
						for i = 1, #hittargets
							avgx = $ + hittargets[i].x/FRACUNIT
							avgy = $ + hittargets[i].y/FRACUNIT
						end

						avgx = ($/#hittargets)*FRACUNIT
						avgy = ($/#hittargets)*FRACUNIT

						local navgx = avgx - 128*cos(mo.angle - ANG1*90)
						local navgy = avgy - 128*sin(mo.angle - ANG1*90)

						-- spawn meteors
						mo.meteors[#mo.meteors+1] = P_SpawnMobj(navgx + P_RandomRange(-256, 256)*FRACUNIT, navgy + P_RandomRange(-256, 256)*FRACUNIT, mo.z + FRACUNIT*512, MT_DUMMY)
						local m = mo.meteors[#mo.meteors]
						m.momz = -FRACUNIT*64
						m.state = S_ROCKCRUMBLEA
						P_InstaThrust(m, mo.angle - ANG1*90, 32*FRACUNIT)

						if timer >= TICRATE and leveltime%13 == 0
							local t = P_SpawnMobj(avgx + P_RandomRange(-256, 256)*FRACUNIT, avgy + P_RandomRange(-256, 256)*FRACUNIT, mo.z, MT_DUMMY)
							t.flags2 = $|MF2_DONTDRAW
							DoExplosion(t)
						end
					elseif timer == TICRATE*5 + 10
						mo.meteors = nil
						return true
					end

					-- iterate thru meteors:
					local i = #mo.meteors
					while i
						local m = mo.meteors[i]
						if not m or not m.valid
							table.remove(mo.meteors, i)
							i = $-1
							continue
						end

						-- fire trail:
						local t = P_SpawnMobj(m.x + P_RandomRange(-32, 32)*FRACUNIT, m.y + P_RandomRange(-32, 32)*FRACUNIT, m.z + P_RandomRange(-32, 32)*FRACUNIT, MT_DUMMY)
						t.state = S_QUICKBOOM1
						t.color = SKINCOLOR_RED

						if m.z <= m.floorz

							P_RemoveMobj(m)
							i = $-1
							continue
						end


						i = $-1
					end

				end,
	},

	["kill rush"] = {
		name = "Kill Rush",
		type = ATK_STRIKE,
		power = 110,
		accuracy = 85,
		costtype = CST_HPPERCENT,
		cost = 13,
		critical = 2,
		hits = 2,
		desc = "Medium strike damage to \none enemy up to 2 times.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer >= 10
			and timer <= 40
			and leveltime%5 == 0

				local x = target.x + P_RandomRange(-40, 40)*FRACUNIT
				local y = target.y + P_RandomRange(-40, 40)*FRACUNIT
				local z = target.z + P_RandomRange(0, 30)*FRACUNIT
				playSound(mo.battlen, sfx_hit2)
				for i=1,16
					local b = P_SpawnMobj(x, y, z+2*FRACUNIT, MT_DUMMY)
					b.momx = P_RandomRange(-3, 3)*FRACUNIT
					b.momy = P_RandomRange(-3, 3)*FRACUNIT
					b.momz = P_RandomRange(4, 16)*FRACUNIT
					b.state = S_AOADUST1
					b.frame = A|FF_FULLBRIGHT
					b.scale = FRACUNIT*3
					b.destscale = FRACUNIT/12
				end
				for i=1,16
					local b = P_SpawnMobj(x, y, z+20*FRACUNIT, MT_DUMMY)
					b.momx = P_RandomRange(-8, 8)*FRACUNIT
					b.momy = P_RandomRange(-8, 8)*FRACUNIT
					b.momz = P_RandomRange(-8, 8)*FRACUNIT
					b.state = S_AOADUST1
					b.frame = A|FF_FULLBRIGHT
					b.scale = FRACUNIT*3
					b.destscale = FRACUNIT/12
				end
			end

			for i = 1, 2
				if timer == 25 + (i-1)*10
					damageObject(target)
				end
			end

			if timer == 67
				return true
			end
		end,
	},

	["swift strike"] = {
		name = "Swift Strike",
		type = ATK_STRIKE,
		power = 110,
		accuracy = 70,
		costtype = CST_HPPERCENT,
		cost = 20,
		critical = 2,
		hits = 2,
		desc = "Medium strike damage to \nall enemies up to 3 times.",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)

			for k, v in ipairs(hittargets)

				local target = hittargets[k]

				if timer >= 10 + (k-1)*10
				and timer <= 40 + (k-1)*10
				and leveltime%5 == 0

					local x = target.x + P_RandomRange(-40, 40)*FRACUNIT
					local y = target.y + P_RandomRange(-40, 40)*FRACUNIT
					local z = target.z + P_RandomRange(0, 30)*FRACUNIT
					playSound(mo.battlen, sfx_hit2)
					for i=1,16
						local b = P_SpawnMobj(x, y, z+2*FRACUNIT, MT_DUMMY)
						b.momx = P_RandomRange(-3, 3)*FRACUNIT
						b.momy = P_RandomRange(-3, 3)*FRACUNIT
						b.momz = P_RandomRange(4, 16)*FRACUNIT
						b.state = S_AOADUST1
						b.frame = A|FF_FULLBRIGHT
						b.scale = FRACUNIT*3
						b.destscale = FRACUNIT/12
					end
					for i=1,16
						local b = P_SpawnMobj(x, y, z+20*FRACUNIT, MT_DUMMY)
						b.momx = P_RandomRange(-8, 8)*FRACUNIT
						b.momy = P_RandomRange(-8, 8)*FRACUNIT
						b.momz = P_RandomRange(-8, 8)*FRACUNIT
						b.state = S_AOADUST1
						b.frame = A|FF_FULLBRIGHT
						b.scale = FRACUNIT*3
						b.destscale = FRACUNIT/12
					end
				end

				for i = 1, 2
					if timer == 25 + (i-1)*10 + (k-1)*10
						damageObject(target)
					end
				end
			end

			if timer == 67 + (#hittargets-1)*10
				return true
			end
		end,
	},

	["gigantic fist"] = {
		name = "Gigantic Fist",
		type = ATK_STRIKE,
		power = 410,
		accuracy = 95,
		costtype = CST_HPPERCENT,
		technical = COND_FREEZE,
		cost = 13,
		critical = 5,
		desc = "Heavy Strike damage to \none enemy.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 20
				damageObject(target)
				playSound(mo.battlen, sfx_pstop)
				if not target.plyr
					createSplat(mo)
					createSplat(mo)
					localquake(mo.battlen, 7*FRACUNIT, 5)
				end
				for i=1,16
					local b = P_SpawnMobj(target.x, target.y, target.z+2*FRACUNIT, MT_DUMMY)
					b.momx = P_RandomRange(-3, 3)*FRACUNIT
					b.momy = P_RandomRange(-3, 3)*FRACUNIT
					b.momz = P_RandomRange(4, 16)*FRACUNIT
					b.state = S_AOADUST1
					b.frame = A|FF_FULLBRIGHT
					b.scale = FRACUNIT*3
					b.destscale = FRACUNIT/12
				end
				for i=1,16
					local b = P_SpawnMobj(target.x, target.y, target.z+20*FRACUNIT, MT_DUMMY)
					b.momx = P_RandomRange(-8, 8)*FRACUNIT
					b.momy = P_RandomRange(-8, 8)*FRACUNIT
					b.momz = P_RandomRange(-8, 8)*FRACUNIT
					b.state = S_AOADUST1
					b.frame = A|FF_FULLBRIGHT
					b.scale = FRACUNIT*3
					b.destscale = FRACUNIT/12
				end
			elseif timer == 45
				return true
			end
		end,
	},

	["heat wave"] = {
		name = "Heat Wave",
		type = ATK_STRIKE,
		power = 280,
		accuracy = 85,
		costtype = CST_HPPERCENT,
		cost = 18,
		critical = 4,
		desc = "Medium Strike damage to \nall enemies.",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)

			if timer == TICRATE/2
			or timer == TICRATE/2 + 8

				if timer == TICRATE/2
					playSound(mo.battlen, sfx_fire2)
				end
				local ang = 0
				for i = 1, 24 do

					local f = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
					f.state = S_FLAME
					f.scale = FRACUNIT/2
					f.fuse = TICRATE
					f.destscale = FRACUNIT*4
					f.friction = FRACUNIT
					f.angle = ang
					P_InstaThrust(f, f.angle, 50*FRACUNIT)

					f = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
					f.state = S_QUICKBOOM1
					f.scale = FRACUNIT
					f.fuse = TICRATE
					f.friction = FRACUNIT
					f.destscale = FRACUNIT*4
					f.angle = ang
					f.color = SKINCOLOR_RED
					P_InstaThrust(f, f.angle, 60*FRACUNIT)

					for i = 1, 8
						f = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
						f.state = S_SPINFIRE1
						f.fuse = TICRATE
						f.friction = FRACUNIT
						f.scale = FRACUNIT/2
						f.destscale = FRACUNIT*4
						f.angle = ang + P_RandomRange(-15, 15)*ANG1
						P_InstaThrust(f, f.angle, 50*FRACUNIT + P_RandomRange(-16, 16)*FRACUNIT)
					end
					ang = $ + (360/24)*ANG1
				end
			end

			if timer == TICRATE/2 + 10
				for k,v in ipairs(hittargets)
					damageObject(v)
				end
			end

			if timer == TICRATE*5/2
				return true
			end
		end,
	},

	["vicious strike"] = {
		name = "Vicious Strike",
		type = ATK_STRIKE,
		power = 500,
		accuracy = 92,
		costtype = CST_HPPERCENT,
		cost = 22,
		critical = 1,
		desc = "Heavy Strike damage to \nall enemies.\nLow critical rate.",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)

			if timer == TICRATE/2
			or timer == TICRATE/2 + 8

				if timer == TICRATE/2
					playSound(mo.battlen, sfx_fire2)
				end
				local ang = 0
				for i = 1, 24 do

					local f = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
					f.state = S_FLAME
					f.scale = FRACUNIT/2
					f.fuse = TICRATE
					f.destscale = FRACUNIT*4
					f.friction = FRACUNIT
					f.angle = ang
					P_InstaThrust(f, f.angle, 50*FRACUNIT)

					f = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
					f.state = S_QUICKBOOM1
					f.scale = FRACUNIT
					f.fuse = TICRATE
					f.friction = FRACUNIT
					f.destscale = FRACUNIT*4
					f.angle = ang
					f.color = SKINCOLOR_RED
					P_InstaThrust(f, f.angle, 60*FRACUNIT)

					for i = 1, 8
						f = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
						f.state = S_SPINFIRE1
						f.fuse = TICRATE
						f.friction = FRACUNIT
						f.scale = FRACUNIT/2
						f.destscale = FRACUNIT*4
						f.angle = ang + P_RandomRange(-15, 15)*ANG1
						P_InstaThrust(f, f.angle, 50*FRACUNIT + P_RandomRange(-16, 16)*FRACUNIT)
					end
					ang = $ + (360/24)*ANG1
				end
			end

			if timer == TICRATE/2 + 10
				for k,v in ipairs(hittargets)
					damageObject(v)
				end
			end

			if timer == TICRATE*5/2
				return true
			end
		end,
	},

	["akasha arts"] = {
		name = "Akasha Arts",
		type = ATK_STRIKE,
		power = 280,
		accuracy = 85,
		costtype = CST_HPPERCENT,
		cost = 26,
		hits = 2,
		critical = 4,
		desc = "Heavy Strike damage to \nall enemies up to 2 times.",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)

			if timer == TICRATE/2
			or timer == TICRATE/2 + 8
			or timer == TICRATE/2 + 4
			or timer == TICRATE/2 + 16

				if timer == TICRATE/2
					playSound(mo.battlen, sfx_fire2)
				end
				local ang = 0
				for i = 1, 24 do

					local f = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
					f.state = S_FLAME
					f.scale = FRACUNIT/2
					f.fuse = TICRATE
					f.destscale = FRACUNIT*4
					f.friction = FRACUNIT
					f.angle = ang
					P_InstaThrust(f, f.angle, 50*FRACUNIT)

					f = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
					f.state = S_QUICKBOOM1
					f.scale = FRACUNIT
					f.fuse = TICRATE
					f.friction = FRACUNIT
					f.destscale = FRACUNIT*4
					f.angle = ang
					f.color = SKINCOLOR_RED
					P_InstaThrust(f, f.angle, 60*FRACUNIT)

					for i = 1, 8
						f = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
						f.state = S_SPINFIRE1
						f.fuse = TICRATE
						f.friction = FRACUNIT
						f.scale = FRACUNIT/2
						f.destscale = FRACUNIT*4
						f.angle = ang + P_RandomRange(-15, 15)*ANG1
						P_InstaThrust(f, f.angle, 50*FRACUNIT + P_RandomRange(-16, 16)*FRACUNIT)
					end
					ang = $ + (360/24)*ANG1
				end
			end

			if timer == TICRATE/2 + 10
			or timer == TICRATE/2 + 20
				for k,v in ipairs(hittargets)
					damageObject(v)
				end
			end

			if timer == TICRATE*3
				return true
			end
		end,
	},

	["assault dive"] = {
		name = "Assault Dive",
		type = ATK_STRIKE,
		power = 180,
		accuracy = 90,
		costtype = CST_HPPERCENT,
		technical = COND_FREEZE,
		cost = 9,
		critical = 5,
		desc = "Medium Strike damage to \none enemy.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 20
				damageObject(target)
				playSound(mo.battlen, sfx_pstop)
				if not target.plyr
					createSplat(mo)
					createSplat(mo)
					localquake(mo.battlen, 7*FRACUNIT, 5)
				end
				for i=1,16
					local b = P_SpawnMobj(target.x, target.y, target.z+2*FRACUNIT, MT_DUMMY)
					b.momx = P_RandomRange(-3, 3)*FRACUNIT
					b.momy = P_RandomRange(-3, 3)*FRACUNIT
					b.momz = P_RandomRange(4, 16)*FRACUNIT
					b.state = S_AOADUST1
					b.frame = A|FF_FULLBRIGHT
					b.scale = FRACUNIT*3
					b.destscale = FRACUNIT/12
				end
				for i=1,16
					local b = P_SpawnMobj(target.x, target.y, target.z+20*FRACUNIT, MT_DUMMY)
					b.momx = P_RandomRange(-8, 8)*FRACUNIT
					b.momy = P_RandomRange(-8, 8)*FRACUNIT
					b.momz = P_RandomRange(-8, 8)*FRACUNIT
					b.state = S_AOADUST1
					b.frame = A|FF_FULLBRIGHT
					b.scale = FRACUNIT*3
					b.destscale = FRACUNIT/12
				end
			elseif timer == 45
				return true
			end
		end,
	},

	["sonic punch"] = {
		name = "Sonic Punch",
		type = ATK_STRIKE,
		power = 120,
		accuracy = 90,
		costtype = CST_HPPERCENT,
		technical = COND_FREEZE,
		cost = 7,
		critical = 5,
		desc = "Light Strike damage to \none enemy.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 20
				damageObject(target)
				playSound(mo.battlen, sfx_pstop)
				if not target.plyr
					createSplat(mo)
					createSplat(mo)
					localquake(mo.battlen, 7*FRACUNIT, 5)
				end
				for i=1,16
					local b = P_SpawnMobj(target.x, target.y, target.z+20*FRACUNIT, MT_DUMMY)
					b.momx = P_RandomRange(-8, 8)*FRACUNIT
					b.momy = P_RandomRange(-8, 8)*FRACUNIT
					b.momz = P_RandomRange(-8, 8)*FRACUNIT
					b.state = S_AOADUST1
					b.frame = A|FF_FULLBRIGHT
					b.scale = FRACUNIT*3
					b.destscale = FRACUNIT/12
				end
			elseif timer == 45
				return true
			end
		end,
	},

	["teardrop"] = {
		name = "Teardrop",
		type = ATK_STRIKE,
		power = 65,
		accuracy = 100,
		costtype = CST_HPPERCENT,
		cost = 7,
		critical = 5,
		desc = "Light Strike damage to \none enemy and lowers\ndefence by 2 stages.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer >= 20
			and timer <= 30

				local zdiff = ((30-20) - (timer - 20))*mo.scale*16
				local b = P_SpawnMobj(target.x, target.y, target.z+20*FRACUNIT + zdiff, MT_DUMMY)
				b.momx = P_RandomRange(-4, 4)*FRACUNIT
				b.momy = P_RandomRange(-4, 4)*FRACUNIT
				b.momz = P_RandomRange(2, 4)*FRACUNIT
				b.state = S_AOADUST1
				b.frame = A|FF_FULLBRIGHT
				b.scale = FRACUNIT*3
				b.destscale = FRACUNIT/12

			end

			if timer == 30
				damageObject(target)
				playSound(mo.battlen, sfx_pstop)

				local d = P_SpawnMobj(target.x, target.y, target.z+128*FRACUNIT, MT_THOK)
				d.sprite = SPR_THMP
				d.frame = B|FF_FULLBRIGHT
				d.scale = FRACUNIT/4
				d.destscale = FRACUNIT*3
				d.scalespeed = FRACUNIT/8
				d.fuse = TICRATE-10
				d.tics = d.fuse
				d.momz = FRACUNIT*2
				d.momx = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
				d.momy = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
				d.color = SKINCOLOR_ORANGE

				if not target.plyr
					createSplat(mo)
					createSplat(mo)
				end
				localquake(mo.battlen, FRACUNIT*10, 10)
				for i=1,16
					local b = P_SpawnMobj(target.x, target.y, target.z+20*FRACUNIT, MT_DUMMY)
					b.momx = P_RandomRange(-8, 8)*FRACUNIT
					b.momy = P_RandomRange(-8, 8)*FRACUNIT
					b.momz = P_RandomRange(-8, 8)*FRACUNIT
					b.state = S_AOADUST1
					b.frame = A|FF_FULLBRIGHT
					b.scale = FRACUNIT*3
					b.destscale = FRACUNIT/12
				end

			elseif timer == 45
			and target.damagestate ~= DMG_MISS		-- make sure we landed the attack
			and target.damagestate ~= DMG_BLOCK
			and target.damagestate ~= DMG_DRAIN
				buffStat(target, "def", -BUFFSTEP*2)	-- negative values lower a stat
				playSound(mo.battlen, sfx_s3k8c)
				local dbuff = P_SpawnMobj(target.x, target.y, target.z+target.height, MT_DUMMY)
				dbuff.state = S_DBUFF1
				dbuff.color = SKINCOLOR_LAVENDER
				dbuff.scale = FRACUNIT*5/2

			elseif timer == 75
				return true
			end
		end,
	},

	["moondrop"] = {
		name = "Moondrop",
		type = ATK_STRIKE,
		power = 120,
		accuracy = 100,
		costtype = CST_HPPERCENT,
		cost = 10,
		critical = 5,
		desc = "Medium Strike damage to \none enemy and lowers\ndefence by 2 stages.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer >= 20
			and timer <= 30

				local zdiff = ((30-20) - (timer - 20))*mo.scale*16
				local b = P_SpawnMobj(target.x, target.y, target.z+20*FRACUNIT + zdiff, MT_DUMMY)
				b.momx = P_RandomRange(-4, 4)*FRACUNIT
				b.momy = P_RandomRange(-4, 4)*FRACUNIT
				b.momz = P_RandomRange(2, 4)*FRACUNIT
				b.state = S_SSPK1
				b.frame = A|FF_FULLBRIGHT
				b.scale = FRACUNIT/3
				b.destscale = FRACUNIT*12
			end

			if timer == 30
				damageObject(target)
				playSound(mo.battlen, sfx_pstop)

				local d = P_SpawnMobj(target.x, target.y, target.z+128*FRACUNIT, MT_THOK)
				d.sprite = SPR_THMP
				d.frame = B|FF_FULLBRIGHT
				d.scale = FRACUNIT/4
				d.destscale = FRACUNIT*3
				d.scalespeed = FRACUNIT/8
				d.fuse = TICRATE-10
				d.tics = d.fuse
				d.momz = FRACUNIT*2
				d.momx = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
				d.momy = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
				d.color = SKINCOLOR_ORANGE

				if not target.plyr
					createSplat(mo)
					createSplat(mo)
				end
				localquake(mo.battlen, FRACUNIT*10, 10)
				for i=1,16
					local b = P_SpawnMobj(target.x, target.y, target.z+20*FRACUNIT, MT_DUMMY)
					b.momx = P_RandomRange(-8, 8)*FRACUNIT
					b.momy = P_RandomRange(-8, 8)*FRACUNIT
					b.momz = P_RandomRange(-8, 8)*FRACUNIT
					b.state = S_AOADUST1
					b.frame = A|FF_FULLBRIGHT
					b.scale = FRACUNIT*3
					b.destscale = FRACUNIT/12
				end

			elseif timer == 45
			and target.damagestate ~= DMG_MISS		-- make sure we landed the attack
			and target.damagestate ~= DMG_BLOCK
			and target.damagestate ~= DMG_DRAIN
				buffStat(target, "def", -BUFFSTEP*2)	-- negative values lower a stat
				playSound(mo.battlen, sfx_s3k8c)
				local dbuff = P_SpawnMobj(target.x, target.y, target.z+target.height, MT_DUMMY)
				dbuff.state = S_DBUFF1
				dbuff.color = SKINCOLOR_LAVENDER
				dbuff.scale = FRACUNIT*5/2

			elseif timer == 75
				return true
			end
		end,
	},

	["stardrop"] = {
		name = "Stardrop",
		type = ATK_STRIKE,
		power = 270,
		accuracy = 100,
		costtype = CST_HPPERCENT,
		cost = 14,
		critical = 5,
		desc = "Heavy Strike damage to \none enemy and lowers\ndefence by 2 stages.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer >= 20
			and timer <= 30

				local zdiff = ((30-20) - (timer - 20))*mo.scale*16
				local b = P_SpawnMobj(target.x, target.y, target.z+20*FRACUNIT + zdiff, MT_DUMMY)
				b.momx = P_RandomRange(-4, 4)*FRACUNIT
				b.momy = P_RandomRange(-4, 4)*FRACUNIT
				b.momz = P_RandomRange(2, 4)*FRACUNIT
				b.state = S_SSPK1
				b.frame = A|FF_FULLBRIGHT
				b.scale = FRACUNIT/3
				b.destscale = FRACUNIT*12
			end

			if timer == 30
				damageObject(target)
				playSound(mo.battlen, sfx_pstop)

				local d = P_SpawnMobj(target.x, target.y, target.z+128*FRACUNIT, MT_THOK)
				d.sprite = SPR_THMP
				d.frame = B|FF_FULLBRIGHT
				d.scale = FRACUNIT/4
				d.destscale = FRACUNIT*3
				d.scalespeed = FRACUNIT/8
				d.fuse = TICRATE-10
				d.tics = d.fuse
				d.momz = FRACUNIT*2
				d.momx = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
				d.momy = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
				d.color = SKINCOLOR_ORANGE

				if not target.plyr
					createSplat(mo)
					createSplat(mo)
				end
				localquake(mo.battlen, FRACUNIT*10, 10)
				for i=1,16
					local b = P_SpawnMobj(target.x, target.y, target.z+20*FRACUNIT, MT_DUMMY)
					b.momx = P_RandomRange(-8, 8)*FRACUNIT
					b.momy = P_RandomRange(-8, 8)*FRACUNIT
					b.momz = P_RandomRange(-8, 8)*FRACUNIT
					b.state = S_SSPK1
					b.frame = A|FF_FULLBRIGHT
					b.scale = FRACUNIT*3
					b.destscale = FRACUNIT/12
				end

			elseif timer == 45
			and target.damagestate ~= DMG_MISS		-- make sure we landed the attack
			and target.damagestate ~= DMG_BLOCK
			and target.damagestate ~= DMG_DRAIN
				buffStat(target, "def", -BUFFSTEP*2)	-- negative values lower a stat
				playSound(mo.battlen, sfx_s3k8c)
				local dbuff = P_SpawnMobj(target.x, target.y, target.z+target.height, MT_DUMMY)
				dbuff.state = S_DBUFF1
				dbuff.color = SKINCOLOR_LAVENDER
				dbuff.scale = FRACUNIT*5/2

			elseif timer == 75
				return true
			end
		end,
	},

	["lunge"] = {
		name = "Lunge",
		type = ATK_STRIKE,
		power = 80,
		accuracy = 90,
		costtype = CST_HPPERCENT,
		technical = COND_FREEZE,
		cost = 5,
		critical = 5,
		desc = "Light Strike damage to \none enemy.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 20
				damageObject(target)
				playSound(mo.battlen, sfx_pstop)

				local d = P_SpawnMobj(target.x, target.y, target.z+128*FRACUNIT, MT_THOK)
				d.sprite = SPR_THMP
				d.frame = B|FF_FULLBRIGHT
				d.scale = FRACUNIT/4
				d.destscale = FRACUNIT*3
				d.scalespeed = FRACUNIT/8
				d.fuse = TICRATE-10
				d.tics = d.fuse
				d.momz = FRACUNIT*2
				d.momx = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
				d.momy = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
				d.color = SKINCOLOR_ORANGE

				if not target.plyr
					createSplat(mo)
					createSplat(mo)
				end
				localquake(mo.battlen, FRACUNIT*10, 10)
				for i=1,16
					local b = P_SpawnMobj(target.x, target.y, target.z+20*FRACUNIT, MT_DUMMY)
					b.momx = P_RandomRange(-8, 8)*FRACUNIT
					b.momy = P_RandomRange(-8, 8)*FRACUNIT
					b.momz = P_RandomRange(-8, 8)*FRACUNIT
					b.state = S_AOADUST1
					b.frame = A|FF_FULLBRIGHT
					b.scale = FRACUNIT*3
					b.destscale = FRACUNIT/12
				end
			elseif timer == 45
				return true
			end
		end,
	},

	["cleave"] = {
		name = "Cleave",
		type = ATK_SLASH,
		power = 80,
		accuracy = 98,
		costtype = CST_HPPERCENT,
		technical = COND_FREEZE,
		cost = 6,
		critical = 3,
		desc = "Light Slash damage to \none enemy.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 15
				local s = P_SpawnMobj(target.x, target.y, target.z+1*FRACUNIT, MT_DUMMY)
				s.state = S_SLASHING_1_1
				s.color = SKINCOLOR_ORANGE
				s.scale = FRACUNIT*3/2
				playSound(mo.battlen, sfx_slash)

			elseif timer == 17
				local d = P_SpawnMobj(target.x, target.y, target.z+128*FRACUNIT, MT_THOK)
				d.sprite = SPR_THMP
				d.frame = C|FF_FULLBRIGHT
				d.scale = FRACUNIT/4
				d.destscale = FRACUNIT*3
				d.scalespeed = FRACUNIT/8
				d.fuse = TICRATE-10
				d.tics = d.fuse
				d.momz = FRACUNIT*2
				d.momx = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
				d.momy = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
				d.color = SKINCOLOR_ORANGE

			elseif timer == 19

				damageObject(target)
				playSound(mo.battlen, sfx_bexpld)
				if not target.plyr
					createSplat(mo)
					createSplat(mo)
				end
				localquake(mo.battlen, FRACUNIT*10, 10)
				for i=1,10
					local b = P_SpawnMobj(target.x, target.y, target.z+20*FRACUNIT, MT_DUMMY)
					b.momx = P_RandomRange(-35, 35)*FRACUNIT
					b.momy = P_RandomRange(-35, 35)*FRACUNIT
					b.momz = P_RandomRange(-35, 35)*FRACUNIT
					b.color = SKINCOLOR_RED
					b.frame = A|FF_FULLBRIGHT
					b.scale = FRACUNIT/2
					b.destscale = FRACUNIT/12
					b.tics = 35
				end

				local s = P_SpawnMobj(target.x, target.y, target.z+40*FRACUNIT, MT_THOK)
				s.sprite = SPR_SLSH
				s.frame = I|FF_FULLBRIGHT
				s.scale = FRACUNIT/2
				s.destscale = FRACUNIT*4
				s.scalespeed = FRACUNIT/3
				s.color = SKINCOLOR_ORANGE

			elseif timer == 45
				target.slashsprite = nil
				return true
			end
		end,
	},

	["giant slice"] = {
		name = "Giant Slice",
		type = ATK_SLASH,
		power = 180,
		accuracy = 97,
		costtype = CST_HPPERCENT,
		technical = COND_FREEZE,
		cost = 9,
		critical = 3,
		desc = "Medium Slash damage to \none enemy.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 15
				local s = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
				s.state = S_SLASHING_2_1
				s.color = SKINCOLOR_ORANGE
				s.scale = FRACUNIT*3
				playSound(mo.battlen, sfx_slash)

			elseif timer == 17
				local d = P_SpawnMobj(target.x, target.y, target.z+128*FRACUNIT, MT_THOK)
				d.sprite = SPR_THMP
				d.frame = C|FF_FULLBRIGHT
				d.scale = FRACUNIT/4
				d.destscale = FRACUNIT*3
				d.scalespeed = FRACUNIT/8
				d.fuse = TICRATE-10
				d.tics = d.fuse
				d.momz = FRACUNIT*2
				d.momx = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
				d.momy = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
				d.color = SKINCOLOR_ORANGE

			elseif timer == 19

				damageObject(target)
				playSound(mo.battlen, sfx_bexpld)
				if not target.plyr
					createSplat(mo)
					createSplat(mo)
				end
				localquake(mo.battlen, FRACUNIT*10, 10)
				for i=1,10
					local b = P_SpawnMobj(target.x, target.y, target.z+20*FRACUNIT, MT_DUMMY)
					b.momx = P_RandomRange(-35, 35)*FRACUNIT
					b.momy = P_RandomRange(-35, 35)*FRACUNIT
					b.momz = P_RandomRange(-35, 35)*FRACUNIT
					b.color = SKINCOLOR_RED
					b.frame = A|FF_FULLBRIGHT
					b.scale = FRACUNIT/2
					b.destscale = FRACUNIT/12
					b.tics = 35
				end

				local s = P_SpawnMobj(target.x, target.y, target.z+40*FRACUNIT, MT_THOK)
				s.sprite = SPR_SLSH
				s.frame = I|FF_FULLBRIGHT
				s.scale = FRACUNIT/2
				s.destscale = FRACUNIT*4
				s.scalespeed = FRACUNIT/3
				s.color = SKINCOLOR_ORANGE

				s = P_SpawnMobj(target.x, target.y, target.z+40*FRACUNIT, MT_THOK)
				s.sprite = SPR_SLSH
				s.frame = G|FF_FULLBRIGHT
				s.scale = FRACUNIT/2
				s.tics = TICRATE/2
				s.fuse = s.tics
				s.destscale = FRACUNIT*10
				s.scalespeed = FRACUNIT/4
				s.color = SKINCOLOR_ORANGE

			elseif timer == 45
				target.slashsprite = nil
				return true
			end
		end,
	},

	["fatal end"] = {
		name = "Fatal End",
		type = ATK_SLASH,
		power = 410,
		accuracy = 97,
		costtype = CST_HPPERCENT,
		technical = COND_FREEZE,
		cost = 14,
		critical = 3,
		desc = "Heavy Slash damage to \none enemy.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 15
				local s = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
				s.state = S_SLASHING_2_1
				s.color = SKINCOLOR_ORANGE
				s.scale = FRACUNIT*3
				playSound(mo.battlen, sfx_slash)
				s = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
				s.state = S_SLASHING_1_1
				s.color = SKINCOLOR_ORANGE
				s.scale = FRACUNIT*3
				playSound(mo.battlen, sfx_slash)

			elseif timer == 17
				local d = P_SpawnMobj(target.x, target.y, target.z+128*FRACUNIT, MT_THOK)
				d.sprite = SPR_THMP
				d.frame = C|FF_FULLBRIGHT
				d.scale = FRACUNIT/4
				d.destscale = FRACUNIT*3
				d.scalespeed = FRACUNIT/8
				d.fuse = TICRATE-10
				d.tics = d.fuse
				d.momz = FRACUNIT*2
				d.momx = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
				d.momy = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
				d.color = SKINCOLOR_ORANGE

			elseif timer == 19

				damageObject(target)
				playSound(mo.battlen, sfx_bexpld)
				if not target.plyr
					createSplat(mo)
					createSplat(mo)
				end
				localquake(mo.battlen, FRACUNIT*10, 10)
				for i=1,10
					local b = P_SpawnMobj(target.x, target.y, target.z+20*FRACUNIT, MT_DUMMY)
					b.momx = P_RandomRange(-35, 35)*FRACUNIT
					b.momy = P_RandomRange(-35, 35)*FRACUNIT
					b.momz = P_RandomRange(-35, 35)*FRACUNIT
					b.color = SKINCOLOR_RED
					b.frame = A|FF_FULLBRIGHT
					b.scale = FRACUNIT/2
					b.destscale = FRACUNIT/12
					b.tics = 35
				end

				local s = P_SpawnMobj(target.x, target.y, target.z+40*FRACUNIT, MT_THOK)
				s.sprite = SPR_SLSH
				s.frame = I|FF_FULLBRIGHT
				s.scale = FRACUNIT/2
				s.destscale = FRACUNIT*4
				s.scalespeed = FRACUNIT/3
				s.color = SKINCOLOR_ORANGE

				s = P_SpawnMobj(target.x, target.y, target.z+40*FRACUNIT, MT_THOK)
				s.sprite = SPR_SLSH
				s.frame = I|FF_FULLBRIGHT
				s.scale = FRACUNIT/2
				s.destscale = FRACUNIT*8
				s.scalespeed = FRACUNIT/2
				s.color = SKINCOLOR_ORANGE

				s = P_SpawnMobj(target.x, target.y, target.z+40*FRACUNIT, MT_THOK)
				s.sprite = SPR_SLSH
				s.frame = G|FF_FULLBRIGHT
				s.scale = FRACUNIT/2
				s.tics = TICRATE/2
				s.fuse = s.tics
				s.destscale = FRACUNIT*10
				s.scalespeed = FRACUNIT/4
				s.color = SKINCOLOR_ORANGE

			elseif timer == 45
				target.slashsprite = nil
				return true
			end
		end,
	},

	["brave blade"] = {
		name = "Brave Blade",
		type = ATK_SLASH,
		power = 600,
		accuracy = 97,
		costtype = CST_HPPERCENT,
		technical = COND_FREEZE,
		cost = 17,
		critical = 7,
		desc = "Severe Slash damage to \none enemy. \nHigh critical rate",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 15
				local s = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
				s.state = S_SLASHING_2_1
				s.color = SKINCOLOR_ORANGE
				s.scale = FRACUNIT*3
				playSound(mo.battlen, sfx_slash)
				s = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
				s.state = S_SLASHING_1_1
				s.color = SKINCOLOR_ORANGE
				s.scale = FRACUNIT*3
				playSound(mo.battlen, sfx_slash)

			elseif timer == 17
				local d = P_SpawnMobj(target.x, target.y, target.z+128*FRACUNIT, MT_THOK)
				d.sprite = SPR_THMP
				d.frame = C|FF_FULLBRIGHT
				d.scale = FRACUNIT/4
				d.destscale = FRACUNIT*3
				d.scalespeed = FRACUNIT/8
				d.fuse = TICRATE-10
				d.tics = d.fuse
				d.momz = FRACUNIT*2
				d.momx = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
				d.momy = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
				d.color = SKINCOLOR_ORANGE
				playSound(mo.battlen, sfx_slash)

			elseif timer == 19

				damageObject(target)
				playSound(mo.battlen, sfx_bexpld)
				if not target.plyr
					createSplat(mo)
					createSplat(mo)
				end
				localquake(mo.battlen, FRACUNIT*10, 10)
				for i=1,10
					local b = P_SpawnMobj(target.x, target.y, target.z+20*FRACUNIT, MT_DUMMY)
					b.momx = P_RandomRange(-35, 35)*FRACUNIT
					b.momy = P_RandomRange(-35, 35)*FRACUNIT
					b.momz = P_RandomRange(-35, 35)*FRACUNIT
					b.color = SKINCOLOR_RED
					b.frame = A|FF_FULLBRIGHT
					b.scale = FRACUNIT/2
					b.destscale = FRACUNIT/12
					b.tics = 35
				end

				local s = P_SpawnMobj(target.x, target.y, target.z+40*FRACUNIT, MT_THOK)
				s.sprite = SPR_SLSH
				s.frame = I|FF_FULLBRIGHT
				s.scale = FRACUNIT/2
				s.destscale = FRACUNIT*4
				s.scalespeed = FRACUNIT/3
				s.color = SKINCOLOR_ORANGE

				s = P_SpawnMobj(target.x, target.y, target.z+40*FRACUNIT, MT_THOK)
				s.sprite = SPR_SLSH
				s.frame = I|FF_FULLBRIGHT
				s.scale = FRACUNIT/2
				s.destscale = FRACUNIT*8
				s.scalespeed = FRACUNIT/2
				s.color = SKINCOLOR_ORANGE

				s = P_SpawnMobj(target.x, target.y, target.z+40*FRACUNIT, MT_THOK)
				s.sprite = SPR_SLSH
				s.frame = G|FF_FULLBRIGHT
				s.scale = FRACUNIT/2
				s.tics = TICRATE/2
				s.fuse = s.tics
				s.destscale = FRACUNIT*10
				s.scalespeed = FRACUNIT/4
				s.color = SKINCOLOR_ORANGE

			elseif timer == 45
				target.slashsprite = nil
				return true
			end
		end,
	},

	["tempest slash"] = {
		name = "Tempest Slash",
		type = ATK_SLASH,
		power = 300,
		accuracy = 91,
		costtype = CST_HPPERCENT,
		technical = COND_FREEZE,
		cost = 18,
		critical = 2,
		hits = 2,
		desc = "Heavy Slash damage to \none enemy up to 2 times",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)

					local color = SKINCOLOR_BLUE
					local target = hittargets[1]

					if timer == 1
						target.rolls = {}

					elseif timer == 15
					or timer == 20
					or timer == 25	-- lazy
						local s = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
						s.state = S_SLASHING_2_1
						s.color = color
						s.scale = FRACUNIT*3
						playSound(mo.battlen, sfx_slash)
						s.rollangle = P_RandomRange(0, 359)*ANG1
						target.rolls[#target.rolls+1] = s.rollangle

					elseif timer == 17
					or timer == 22
					or timer == 27

						if (timer == 22)

							local d = P_SpawnMobj(target.x, target.y, target.z+128*FRACUNIT, MT_THOK)
							d.sprite = SPR_THMP
							d.frame = C|FF_FULLBRIGHT
							d.scale = FRACUNIT/4
							d.destscale = FRACUNIT*3
							d.scalespeed = FRACUNIT/8
							d.fuse = TICRATE-10
							d.tics = d.fuse
							d.momz = FRACUNIT*2
							d.momx = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
							d.momy = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
							d.color = color
						end


					elseif timer == 19
					or timer == 24
					or timer == 29

						if timer == 19
						or timer == 29
							damageObject(target)
							playSound(mo.battlen, sfx_bexpld)
							if not target.plyr
								createSplat(mo)
								createSplat(mo)
							end
							localquake(mo.battlen, FRACUNIT*10, 10)
						end

						local s = P_SpawnMobj(target.x, target.y, target.z+40*FRACUNIT, MT_THOK)
						s.sprite = SPR_SLSH
						s.frame = I|FF_FULLBRIGHT
						s.scale = FRACUNIT/2
						s.destscale = FRACUNIT*4
						s.scalespeed = FRACUNIT/3
						s.color = color

						s = P_SpawnMobj(target.x, target.y, target.z+40*FRACUNIT, MT_THOK)
						s.sprite = SPR_SLSH
						s.frame = G|FF_FULLBRIGHT
						s.scale = FRACUNIT/2
						s.tics = TICRATE/2
						s.fuse = s.tics
						s.destscale = FRACUNIT*10
						s.scalespeed = FRACUNIT/4
						s.color = color
						s.rollangle = target.rolls[#target.rolls]
					end
					if timer == 55
						return true
					end
				end,
	},

	["toxic slice"] = {
		name = "Toxic Slice",
		type = ATK_SLASH,
		power = 120,
		accuracy = 90,
		costtype = CST_HPPERCENT,
		technical = COND_FREEZE,
		cost = 10,
		critical = 3,
		status = COND_POISON,
		statuschance = 25,
		desc = "Light Slash damage to \none enemy.\nSmall chance of Poison.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 15
				local s = P_SpawnMobj(target.x, target.y, target.z+1*FRACUNIT, MT_DUMMY)
				s.state = S_SLASHING_1_1
				s.color = SKINCOLOR_PURPLE
				s.scale = FRACUNIT*3/2
				playSound(mo.battlen, sfx_slash)

			elseif timer == 17
				local d = P_SpawnMobj(target.x, target.y, target.z+128*FRACUNIT, MT_THOK)
				d.sprite = SPR_THMP
				d.frame = C|FF_FULLBRIGHT
				d.scale = FRACUNIT/4
				d.destscale = FRACUNIT*3
				d.scalespeed = FRACUNIT/8
				d.fuse = TICRATE-10
				d.tics = d.fuse
				d.momz = FRACUNIT*2
				d.momx = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
				d.momy = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
				d.color = SKINCOLOR_ORANGE

			elseif timer == 19

				damageObject(target)
				playSound(mo.battlen, sfx_bexpld)
				if not target.plyr
					createSplat(mo)
					createSplat(mo)
				end
				localquake(mo.battlen, FRACUNIT*10, 10)
				for i=1,10
					local b = P_SpawnMobj(target.x, target.y, target.z+20*FRACUNIT, MT_DUMMY)
					b.momx = P_RandomRange(-35, 35)*FRACUNIT
					b.momy = P_RandomRange(-35, 35)*FRACUNIT
					b.momz = P_RandomRange(-35, 35)*FRACUNIT
					b.color = SKINCOLOR_PURPLE
					b.frame = A|FF_FULLBRIGHT
					b.scale = FRACUNIT/2
					b.destscale = FRACUNIT/12
					b.tics = 35
				end

				local s = P_SpawnMobj(target.x, target.y, target.z+40*FRACUNIT, MT_THOK)
				s.sprite = SPR_SLSH
				s.frame = I|FF_FULLBRIGHT
				s.scale = FRACUNIT/2
				s.destscale = FRACUNIT*4
				s.scalespeed = FRACUNIT/3
				s.color = SKINCOLOR_BLACK

			elseif timer == 45
				target.slashsprite = nil
				return true
			end
		end,
	},

	["virus cutter"] = {
		name = "Virus Cutter",
		type = ATK_SLASH,
		power = 300,
		accuracy = 94,
		costtype = CST_HPPERCENT,
		cost = 13,
		critical = 3,
		status = COND_POISON,
		statuschance = 35,
		desc = "Medium Slash damage to \none enemy.\nMedium chance of Poison.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 15
				local s = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
				s.state = S_SLASHING_2_1
				s.color = SKINCOLOR_PURPLE
				s.scale = FRACUNIT*3
				playSound(mo.battlen, sfx_slash)

			elseif timer == 17
				local d = P_SpawnMobj(target.x, target.y, target.z+128*FRACUNIT, MT_THOK)
				d.sprite = SPR_THMP
				d.frame = C|FF_FULLBRIGHT
				d.scale = FRACUNIT/4
				d.destscale = FRACUNIT*3
				d.scalespeed = FRACUNIT/8
				d.fuse = TICRATE-10
				d.tics = d.fuse
				d.momz = FRACUNIT*2
				d.momx = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
				d.momy = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
				d.color = SKINCOLOR_PURPLE

			elseif timer == 19

				damageObject(target)
				playSound(mo.battlen, sfx_bexpld)
				if not target.plyr
					createSplat(mo)
					createSplat(mo)
				end
				localquake(mo.battlen, FRACUNIT*10, 10)
				for i=1,10
					local b = P_SpawnMobj(target.x, target.y, target.z+20*FRACUNIT, MT_DUMMY)
					b.momx = P_RandomRange(-35, 35)*FRACUNIT
					b.momy = P_RandomRange(-35, 35)*FRACUNIT
					b.momz = P_RandomRange(-35, 35)*FRACUNIT
					b.color = SKINCOLOR_PURPLE
					b.frame = A|FF_FULLBRIGHT
					b.scale = FRACUNIT/2
					b.destscale = FRACUNIT/12
					b.tics = 35
				end

				local s = P_SpawnMobj(target.x, target.y, target.z+40*FRACUNIT, MT_THOK)
				s.sprite = SPR_SLSH
				s.frame = I|FF_FULLBRIGHT
				s.scale = FRACUNIT/2
				s.destscale = FRACUNIT*4
				s.scalespeed = FRACUNIT/3
				s.color = SKINCOLOR_PURPLE

				s = P_SpawnMobj(target.x, target.y, target.z+40*FRACUNIT, MT_THOK)
				s.sprite = SPR_SLSH
				s.frame = G|FF_FULLBRIGHT
				s.scale = FRACUNIT/2
				s.tics = TICRATE/2
				s.fuse = s.tics
				s.destscale = FRACUNIT*10
				s.scalespeed = FRACUNIT/4
				s.color = SKINCOLOR_PURPLE

			elseif timer == 45
				target.slashsprite = nil
				return true
			end
		end,
	},

	["twin slash"] = {
		name = "Twin Slash",
		type = ATK_SLASH,
		power = 60,
		accuracy = 90,
		costtype = CST_HPPERCENT,
		cost = 8,
		critical = 2,
		hits = 2,
		desc = "Light slash damage to \none enemy up to 2 times.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 15
			or timer == 25
				local s = P_SpawnMobj(target.x, target.y, target.z+1*FRACUNIT, MT_DUMMY)
				s.state = S_SLASHING_1_1
				s.color = SKINCOLOR_ORANGE
				s.scale = FRACUNIT*3/2
				playSound(mo.battlen, sfx_slash)

			elseif timer == 17
			or timer == 27
				local d = P_SpawnMobj(target.x, target.y, target.z+128*FRACUNIT, MT_THOK)
				d.sprite = SPR_THMP
				d.frame = C|FF_FULLBRIGHT
				d.scale = FRACUNIT/4
				d.destscale = FRACUNIT*3
				d.scalespeed = FRACUNIT/8
				d.fuse = TICRATE-10
				d.tics = d.fuse
				d.momz = FRACUNIT*2
				d.momx = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
				d.momy = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
				d.color = SKINCOLOR_ORANGE

			elseif timer == 19
			or timer == 29

				damageObject(target)
				playSound(mo.battlen, sfx_bexpld)
				if not target.plyr
					createSplat(mo)
					createSplat(mo)
				end
				localquake(mo.battlen, FRACUNIT*10, 10)
				for i=1,10
					local b = P_SpawnMobj(target.x, target.y, target.z+20*FRACUNIT, MT_DUMMY)
					b.momx = P_RandomRange(-35, 35)*FRACUNIT
					b.momy = P_RandomRange(-35, 35)*FRACUNIT
					b.momz = P_RandomRange(-35, 35)*FRACUNIT
					b.color = SKINCOLOR_RED
					b.frame = A|FF_FULLBRIGHT
					b.scale = FRACUNIT/2
					b.destscale = FRACUNIT/12
					b.tics = 35
				end

				local s = P_SpawnMobj(target.x, target.y, target.z+40*FRACUNIT, MT_THOK)
				s.sprite = SPR_SLSH
				s.frame = I|FF_FULLBRIGHT
				s.scale = FRACUNIT/2
				s.destscale = FRACUNIT*4
				s.scalespeed = FRACUNIT/3
				s.color = SKINCOLOR_ORANGE

			elseif timer == 55
				target.slashsprite = nil
				return true
			end
		end,
	},

	["gale slash"] = {
		name = "Gale Slash",
		type = ATK_SLASH,
		power = 200,
		accuracy = 90,
		costtype = CST_HPPERCENT,
		cost = 12,
		critical = 2,
		technical = COND_FREEZE,
		desc = "Light slash damage to \nall enemies",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)

			for i = 1, #hittargets
				local color = SKINCOLOR_EMERALD
				local target = hittargets[i]
				local time = timer - (i-1)*6

				if time == 1
					target.rolls = {}

				elseif time == 15
				or time == 20
				or time == 25	-- lazy
					local s = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					s.state = S_SLASHING_2_1
					s.color = color
					s.scale = FRACUNIT*3
					playSound(mo.battlen, sfx_slash)
					s.rollangle = P_RandomRange(0, 359)*ANG1
					target.rolls[#target.rolls+1] = s.rollangle

				elseif time == 17
				or time == 22
				or time == 27

					if time == 22
					and not (i%2)

						local d = P_SpawnMobj(target.x, target.y, target.z+128*FRACUNIT, MT_THOK)
						d.sprite = SPR_THMP
						d.frame = C|FF_FULLBRIGHT
						d.scale = FRACUNIT/4
						d.destscale = FRACUNIT*3
						d.scalespeed = FRACUNIT/8
						d.fuse = TICRATE-10
						d.tics = d.fuse
						d.momz = FRACUNIT*2
						d.momx = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
						d.momy = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
						d.color = color
					end

					local s = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					s.scale = FRACUNIT/4
					s.sprite = SPR_SLAS
					s.frame = I|TR_TRANS50 + P_RandomRange(0, 3)
					s.destscale = FRACUNIT*9
					s.scalespeed = FRACUNIT
					s.tics = TICRATE/3


				elseif time == 19
				or time == 24
				or time == 29

					if time == 24
						damageObject(target)
						playSound(mo.battlen, sfx_bexpld)
						if not target.plyr
							createSplat(mo)
							createSplat(mo)
						end
						localquake(mo.battlen, FRACUNIT*10, 10)
					end

					local s = P_SpawnMobj(target.x, target.y, target.z+40*FRACUNIT, MT_THOK)
					s.sprite = SPR_SLSH
					s.frame = I|FF_FULLBRIGHT
					s.scale = FRACUNIT/2
					s.destscale = FRACUNIT*4
					s.scalespeed = FRACUNIT/3
					s.color = color

					s = P_SpawnMobj(target.x, target.y, target.z+40*FRACUNIT, MT_THOK)
					s.sprite = SPR_SLSH
					s.frame = G|FF_FULLBRIGHT
					s.scale = FRACUNIT/2
					s.tics = TICRATE/2
					s.fuse = s.tics
					s.destscale = FRACUNIT*10
					s.scalespeed = FRACUNIT/4
					s.color = color
					s.rollangle = target.rolls[#target.rolls]
				end
			end

			if timer == 55 + (#hittargets-1)*6
				return true
			end
		end,
	},

	["blade of fury"] = {
		name = "Blade of Fury",
		type = ATK_SLASH,
		power = 260,
		accuracy = 90,
		costtype = CST_HPPERCENT,
		cost = 16,
		critical = 3,
		technical = COND_FREEZE,
		desc = "Medium slash damage to \nall enemies",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)

			for i = 1, #hittargets
				local color = SKINCOLOR_RED
				local target = hittargets[i]
				local time = timer - (i-1)*6

				if time == 1
					target.rolls = {}

				elseif time == 15
				or time == 20
				or time == 25	-- lazy
					local s = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					s.state = S_SLASHING_2_1
					s.color = color
					s.scale = FRACUNIT*3
					playSound(mo.battlen, sfx_slash)
					s.rollangle = P_RandomRange(0, 359)*ANG1
					target.rolls[#target.rolls+1] = s.rollangle

				elseif time == 17
				or time == 22
				or time == 27

					if time == 22
					and not (i%2)

						local d = P_SpawnMobj(target.x, target.y, target.z+128*FRACUNIT, MT_THOK)
						d.sprite = SPR_THMP
						d.frame = C|FF_FULLBRIGHT
						d.scale = FRACUNIT/4
						d.destscale = FRACUNIT*3
						d.scalespeed = FRACUNIT/8
						d.fuse = TICRATE-10
						d.tics = d.fuse
						d.momz = FRACUNIT*2
						d.momx = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
						d.momy = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
						d.color = color
					end

				elseif time == 19
				or time == 24
				or time == 29

					if time == 24
						damageObject(target)
						playSound(mo.battlen, sfx_bexpld)
						if not target.plyr
							createSplat(mo)
							createSplat(mo)
						end
						localquake(mo.battlen, FRACUNIT*10, 10)
					end

					local s = P_SpawnMobj(target.x, target.y, target.z+40*FRACUNIT, MT_THOK)
					s.sprite = SPR_SLSH
					s.frame = I|FF_FULLBRIGHT
					s.scale = FRACUNIT/2
					s.destscale = FRACUNIT*4
					s.scalespeed = FRACUNIT/3
					s.color = color

					s = P_SpawnMobj(target.x, target.y, target.z+40*FRACUNIT, MT_THOK)
					s.sprite = SPR_SLSH
					s.frame = G|FF_FULLBRIGHT
					s.scale = FRACUNIT/2
					s.tics = TICRATE/2
					s.fuse = s.tics
					s.destscale = FRACUNIT*10
					s.scalespeed = FRACUNIT/4
					s.color = color
					s.rollangle = target.rolls[#target.rolls]
				end
			end

			if timer == 55 + (#hittargets-1)*6
				return true
			end
		end,
	},

	["danse macabre"] = {
		name = "Danse Macabre",
		type = ATK_SLASH,
		power = 230,
		accuracy = 95,
		costtype = CST_HPPERCENT,
		cost = 20,
		critical = 2,
		status = COND_HEX,
		statuschance = 33,
		technical = COND_FREEZE,
		desc = "Medium slash damage to \nall enemies. Medium\nchance of Hex",
		target = TGT_ALLENEMIES,

		anim = function(mo, targets, hittargets, timer)

			for i = 1, #hittargets
				local color = SKINCOLOR_CRIMSON
				local target = hittargets[i]
				local time = timer - (i-1)*6

				local atk = P_SpawnMobj(target.x + P_RandomRange(-90, 90)*FRACUNIT, target.y + P_RandomRange(-90, 90)*FRACUNIT, target.z + P_RandomRange(0, 90)*FRACUNIT, MT_DUMMY)
				atk.state = S_CDUST1
				atk.color = SKINCOLOR_BLACK
				atk.momz = FRACUNIT*8
				atk.destscale = FRACUNIT*10
				atk.tics = 10

				if time == 1
					target.rolls = {}

				elseif time == 15
				or time == 20
				or time == 25	-- lazy
					local s = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					s.state = S_SLASHING_2_1
					s.color = color
					s.scale = FRACUNIT*3
					playSound(mo.battlen, sfx_slash)
					s.rollangle = P_RandomRange(0, 359)*ANG1
					target.rolls[#target.rolls+1] = s.rollangle

				elseif time == 17
				or time == 22
				or time == 27

					if time == 22
					and not (i%2)

						local d = P_SpawnMobj(target.x, target.y, target.z+128*FRACUNIT, MT_THOK)
						d.sprite = SPR_THMP
						d.frame = C|FF_FULLBRIGHT
						d.scale = FRACUNIT/4
						d.destscale = FRACUNIT*3
						d.scalespeed = FRACUNIT/8
						d.fuse = TICRATE-10
						d.tics = d.fuse
						d.momz = FRACUNIT*2
						d.momx = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
						d.momy = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
						d.color = color
					end


				elseif time == 19
				or time == 24
				or time == 29

					if time == 24
						damageObject(target)
						playSound(mo.battlen, sfx_bexpld)
						if not target.plyr
							createSplat(mo)
							createSplat(mo)
						end
						localquake(mo.battlen, FRACUNIT*10, 10)
					end

					local s = P_SpawnMobj(target.x, target.y, target.z+40*FRACUNIT, MT_THOK)
					s.sprite = SPR_SLSH
					s.frame = I|FF_FULLBRIGHT
					s.scale = FRACUNIT/2
					s.destscale = FRACUNIT*4
					s.scalespeed = FRACUNIT/3
					s.color = color

					s = P_SpawnMobj(target.x, target.y, target.z+40*FRACUNIT, MT_THOK)
					s.sprite = SPR_SLSH
					s.frame = G|FF_FULLBRIGHT
					s.scale = FRACUNIT/2
					s.tics = TICRATE/2
					s.fuse = s.tics
					s.destscale = FRACUNIT*10
					s.scalespeed = FRACUNIT/4
					s.color = color
					s.rollangle = target.rolls[#target.rolls]
				end
			end

			if timer == 55 + (#hittargets-1)*6
				return true
			end
		end,
	},

	["deathbound"] = {
		name = "Deathbound",
		type = ATK_SLASH,
		power = 200,
		accuracy = 70,
		costtype = CST_HPPERCENT,
		cost = 19,
		critical = 1,
		hits = 2,
		technical = COND_FREEZE,
		desc = "Medium slash damage to \nall enemies up to\n2 times",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)

			if timer == 10
				mo.dbs = {}
				playSound(mo.battlen, sfx_cboom)
				-- ready smoke table
			end

			-- spawn said smoke:
			if timer >= 10 and timer <= TICRATE + TICRATE/2
			and mo.dbs

				for i = 1, 8
					local s = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
					s.state = S_CDUST1
					s.color = SKINCOLOR_BLACK
					s.angle = P_RandomRange(0, 359)*ANG1
					s.scale = FRACUNIT*3
					s.scalespeed = FRACUNIT/6
					s.destscale = FRACUNIT*12
					s.dist = 0
					s.tics = 18
					mo.dbs[#mo.dbs+1] = s
				end
			end

			-- rotate the smoke
			if mo.dbs and #mo.dbs
				for i = 1, #mo.dbs do
					local s = mo.dbs[i]
					if not s or not s.valid continue end	-- don't care

					s.angle = $+ ANG1*10
					s.dist = min(1024, $+32)

					P_TeleportMove(s, mo.x + s.dist *cos(s.angle), mo.y + s.dist*sin(s.angle), s.floorz)

					if not P_RandomRange(0, 30)
						local t = P_SpawnMobj(s.x, s.y, s.z, MT_THOK)
						t.color = SKINCOLOR_RED
						t.frame = $|FF_FULLBRIGHT
						t.momz = P_RandomRange(4, 8)*FRACUNIT
						t.destscale = 1
						t.tics = TICRATE
						if P_RandomRange(0, 10) == 0
							S_StartSound(t, sfx_slash)
						end
					end
				end
			end

			-- hit targets
			for i = 1, #hittargets
				local target = hittargets[i]
				local t = timer - 6*(i-1)

				if t == TICRATE - TICRATE/4
				or t == TICRATE
					damageObject(target)
				end
			end

			if timer == TICRATE*2 + (#hittargets-1)*6
				return true
			end
		end,
	},

	["triple down"] = {
		name = "Triple Down",
		type = ATK_PIERCE,
		power = 45,
		accuracy = 75,
		costtype = CST_HPPERCENT,
		technical = COND_FREEZE,
		cost = 12,
		desc = "Light Pierce damage to \nall enemies up to 3 times.",
		critical = 1,
		hits = 3,	-- remember this attack hits 3 times!
		target = TGT_ALLENEMIES,
		anim = 	function(mo, targets, hittargets, timer)
					for k,v in ipairs(hittargets)
						local time = timer - 5*(k-1)

						if time == 25
						or time == 45
						or time == 65
							local x, y, z = P_RandomRange(-32, 32)*FRACUNIT, P_RandomRange(-32, 32)*FRACUNIT, P_RandomRange(-32, 32)*FRACUNIT
							local shot = P_SpawnMobj(v.x+x, v.y+y, v.z+z, MT_DUMMY)
							shot.scale = FRACUNIT*3
							shot.state = S_STAB_1_1
							playSound(mo.battlen, sfx_hit)
							damageObject(v)
						end
					end

					if timer == 90 + 5*(#hittargets-1)
						return true
					end
				end,
	},

	["psi"] = {
		name = "Psi",
		type = ATK_PSY,
		power = 60,
		accuracy = 95,
		costtype = CST_SP,
		cost = 4,
		desc = "Light Psy dmg to one enemy.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]
			local psiocolors = {SKINCOLOR_TEAL, SKINCOLOR_YELLOW, SKINCOLOR_PINK, SKINCOLOR_BLACK, SKINCOLOR_WHITE}

			if timer >= 20 and timer <= 50
				if timer == 20
					damageObject(target)
					playSound(mo.battlen, sfx_s3k74)
				end
				if not (timer%4)

					local ol = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					ol.sprite = SPR_NTHK
					ol.color = psiocolors[P_RandomRange(1, #psiocolors)]
					ol.scale = 1
					ol.destscale = FRACUNIT*32
					ol.scalespeed = FRACUNIT/5
					ol.frame = B|FF_FULLBRIGHT
					ol.tics = 20

					ol = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					ol.sprite = SPR_NTHK
					ol.color = psiocolors[P_RandomRange(1, #psiocolors)]
					ol.scale = 1
					ol.destscale = FRACUNIT*32
					ol.scalespeed = FRACUNIT
					ol.frame = B|FF_FULLBRIGHT|TR_TRANS50
					ol.tics = 8


				end
			elseif timer == 75
				return true
			end
		end,
	},

	["mapsi"] = {
		name = "Mapsi",
		type = ATK_PSY,
		power = 60,
		accuracy = 90,
		costtype = CST_SP,
		cost = 8,
		desc = "Light Psy dmg to all enemies.",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)

			for k,v in ipairs(hittargets)

				local target = v
				local time = timer - 6*(k-1)
				local psiocolors = {SKINCOLOR_TEAL, SKINCOLOR_YELLOW, SKINCOLOR_PINK, SKINCOLOR_BLACK, SKINCOLOR_WHITE}

				if time >= 20 and time <= 50
					if time == 20
						damageObject(target)
						playSound(mo.battlen, sfx_s3k74)
					end
					if not (time%4)
						local ol = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
						ol.sprite = SPR_NTHK
						ol.color = psiocolors[P_RandomRange(1, #psiocolors)]
						ol.scale = 1
						ol.destscale = FRACUNIT*32
						ol.scalespeed = FRACUNIT/5
						ol.frame = B|FF_FULLBRIGHT
						ol.tics = 20

						ol = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
						ol.sprite = SPR_NTHK
						ol.color = psiocolors[P_RandomRange(1, #psiocolors)]
						ol.scale = 1
						ol.destscale = FRACUNIT*32
						ol.scalespeed = FRACUNIT
						ol.frame = B|FF_FULLBRIGHT|TR_TRANS50
						ol.tics = 8

					end
				end
			end
			if timer == 75 + (#hittargets-1)*6
				return true
			end
		end,
	},

	["psio"] = {
		name = "Psio",
		type = ATK_PSY,
		power = 140,
		accuracy = 95,
		costtype = CST_SP,
		cost = 8,
		desc = "Medium Psy dmg to one enemy.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			local psiocolors = {SKINCOLOR_TEAL, SKINCOLOR_YELLOW, SKINCOLOR_PINK, SKINCOLOR_BLACK, SKINCOLOR_WHITE}

			if target.psio and target.psio[1]
				for k,v in ipairs(target.psio)
					if leveltime%2
						v.color = psiocolors[P_RandomRange(1, #psiocolors)]
						if FixedHypot(v.momx, v.momy)
							local g = P_SpawnGhostMobj(v)
							g.fuse = 4
						end
					end
				end
			end

			if timer >= 10 and timer <= 26
				if timer == 10
					target.psio = {}
				end

				if not (timer%2)
					local x, y, z = target.x + P_RandomRange(-96, 96)*FRACUNIT, target.y + P_RandomRange(-96, 96)*FRACUNIT, target.z + P_RandomRange(0, 128)*FRACUNIT

					local ol = P_SpawnMobj(x, y, z, MT_DUMMY)
					ol.sprite = SPR_NTHK
					ol.scale = FRACUNIT/2
					ol.destscale = FRACUNIT*10
					ol.frame = B|FF_FULLBRIGHT
					ol.color = SKINCOLOR_BLACK
					ol.scalespeed = FRACUNIT/5
					ol.tics = 15

					ol = P_SpawnMobj(x, y, z, MT_DUMMY)
					ol.sprite = SPR_NTHK
					ol.color = psiocolors[P_RandomRange(1, #psiocolors)]
					ol.scale = 1
					ol.destscale = FRACUNIT*32
					ol.scalespeed = FRACUNIT
					ol.frame = B|FF_FULLBRIGHT|TR_TRANS50
					ol.tics = 8

					if not (timer%4) then ol.color = SKINCOLOR_WHITE; playSound(mo.battlen, sfx_s3k74) end

					local psi = P_SpawnMobj(x, y, z, MT_DUMMY)
					psi.sprite = SPR_NTHK
					psi.scale = 1
					psi.destscale = FRACUNIT*2/3
					psi.color = psiocolors[P_RandomRange(1, #psiocolors)]
					psi.frame = A|FF_FULLBRIGHT
					psi.tics = -1
					target.psio[#target.psio+1] = psi
				end

			elseif timer == 45
				playSound(mo.battlen, sfx_s3k83)
				for k,v in ipairs(target.psio)
					v.momx = -(v.x - target.x) / 4
					v.momy = -(v.y - target.y) / 4
					v.momz = -(v.z - target.z) / 4
				end

			elseif timer == 49
				damageObject(target)
				for k,v in ipairs(target.psio)
					P_RemoveMobj(v)
				end
				target.psio = nil
			elseif timer >= 50 and timer <= 80
				if not (timer%4)

					--playSound(target.battlen, sfx_s3k77)

					local ol = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					ol.sprite = SPR_NTHK
					ol.color = psiocolors[P_RandomRange(1, #psiocolors)]
					ol.scale = 1
					ol.destscale = FRACUNIT*32
					ol.scalespeed = FRACUNIT/5
					ol.frame = B|FF_FULLBRIGHT
					ol.tics = 20
				end

			elseif timer == 95
				return true
			end
		end,
	},

	["mapsio"] = {
		name = "Mapsio",
		type = ATK_PSY,
		power = 140,
		accuracy = 90,
		costtype = CST_SP,
		cost = 16,
		desc = "Medium Psy dmg to all enemies.",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)

			for k,v in ipairs(hittargets)

				local target = v
				local time = timer - 6*(k-1)

				local psiocolors = {SKINCOLOR_TEAL, SKINCOLOR_YELLOW, SKINCOLOR_PINK, SKINCOLOR_BLACK, SKINCOLOR_WHITE}

				if target.psio and target.psio[1]
					for k,v in ipairs(target.psio)
						if leveltime%2
							v.color = psiocolors[P_RandomRange(1, #psiocolors)]
						end
					end
				end

				if time >= 10 and time <= 26
					if time == 10
						target.psio = {}
					end

					if not (time%2)
						local x, y, z = target.x + P_RandomRange(-96, 96)*FRACUNIT, target.y + P_RandomRange(-96, 96)*FRACUNIT, target.z + P_RandomRange(0, 128)*FRACUNIT

						local ol = P_SpawnMobj(x, y, z, MT_DUMMY)
						ol.sprite = SPR_NTHK
						ol.scale = FRACUNIT/2
						ol.destscale = FRACUNIT*10
						ol.frame = B|FF_FULLBRIGHT
						ol.color = SKINCOLOR_BLACK
						ol.scalespeed = FRACUNIT/5
						ol.tics = 15

						if not (timer%4) then ol.color = SKINCOLOR_WHITE; playSound(mo.battlen, sfx_s3k74) end

						local psi = P_SpawnMobj(x, y, z, MT_DUMMY)
						psi.sprite = SPR_NTHK
						psi.scale = 1
						psi.destscale = FRACUNIT*2/3
						psi.color = psiocolors[P_RandomRange(1, #psiocolors)]
						psi.frame = A|FF_FULLBRIGHT
						psi.tics = -1
						target.psio[#target.psio+1] = psi
					end

				elseif time == 45
					playSound(mo.battlen, sfx_s3k83)
					for k,v in ipairs(target.psio)
						v.momx = -(v.x - target.x) / 4
						v.momy = -(v.y - target.y) / 4
						v.momz = -(v.z - target.z) / 4
					end

				elseif time == 49
					damageObject(target)
					for k,v in ipairs(target.psio)
						P_RemoveMobj(v)
					end
					target.psio = nil
				elseif time >= 50 and time <= 80
					if not (timer%4)

						local ol = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
						ol.sprite = SPR_NTHK
						ol.color = psiocolors[P_RandomRange(1, #psiocolors)]
						ol.scale = 1
						ol.destscale = FRACUNIT*32
						ol.scalespeed = FRACUNIT/5
						ol.frame = B|FF_FULLBRIGHT
						ol.tics = 20

					end
				end
			end

			if timer == 95 + (#hittargets-1)*6
				return true
			end
		end,
	},

	["psiodyne"] = {
		name = "Psiodyne",
		type = ATK_PSY,
		power = 350,
		accuracy = 95,
		costtype = CST_SP,
		cost = 12,
		desc = "Heavy Psy dmg to one enemy.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			local psiocolors = {SKINCOLOR_TEAL, SKINCOLOR_YELLOW, SKINCOLOR_PINK, SKINCOLOR_BLACK, SKINCOLOR_WHITE}

			if target.psiodyne and #target.psiodyne
				-- slow all of these down
				for i = 1, #target.psiodyne do
					local f = target.psiodyne[i]
					if not f or not f.valid continue end
					local g = P_SpawnGhostMobj(f)
					g.destscale = 1
				end
			end

			if timer == 20
				target.psiodyne = {}
				playSound(mo.battlen, sfx_s3k74)

				local ol = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
				ol.sprite = SPR_NTHK
				ol.color = psiocolors[P_RandomRange(1, #psiocolors)]
				ol.scale = 1
				ol.destscale = FRACUNIT*32
				ol.scalespeed = FRACUNIT/3
				ol.frame = B|FF_FULLBRIGHT
				ol.tics = 20

				-- spawn all the particles
				for i = 1, 32 do
					local ol = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					ol.sprite = SPR_NTHK
					ol.color = psiocolors[P_RandomRange(1, #psiocolors)]
					ol.scale = 1
					ol.destscale = FRACUNIT/2
					ol.frame = A|FF_FULLBRIGHT
					ol.tics = -1
					ol.angle = P_RandomRange(0, 359)*ANG1

					local hthrust = P_RandomRange(0, 128)
					local vthrust = 128-hthrust
					P_InstaThrust(ol, ol.angle, hthrust*FRACUNIT)
					ol.momz = vthrust*FRACUNIT
					ol.savemoms = {ol.momx, ol.momy, ol.momz}
					target.psiodyne[#target.psiodyne+1] = ol
				end

			elseif timer >= 20
			and timer <= 60
				-- slow all of these down
				for i = 1, #target.psiodyne do
					local f = target.psiodyne[i]
					f.momx = $*80/100
					f.momy = $*80/100
					f.momz = $*80/100
				end

			elseif timer > 60 and timer < 128
				local t = timer-60
				local f = target.psiodyne[t]
				if f and f.valid
					f.momx = -f.savemoms[1]
					f.momy = -f.savemoms[2]
					f.momz = -f.savemoms[3]
					f.fuse = 8
				end

				if timer > 60 + TICRATE/3
					-- make impacts
					if not (leveltime%4)

						local x = target.x + P_RandomRange(-256, 256)*FRACUNIT
						local y = target.y + P_RandomRange(-256, 256)*FRACUNIT
						local z = target.z + P_RandomRange(0, 256)*FRACUNIT

						playSound(mo.battlen, sfx_s3k77)
						localquake(mo.battlen, FRACUNIT*64, 10)

						local ol = P_SpawnMobj(x, y, z, MT_DUMMY)
						ol.sprite = SPR_NTHK
						ol.color = psiocolors[P_RandomRange(1, #psiocolors)]
						ol.scale = 1
						ol.destscale = FRACUNIT*32
						ol.scalespeed = FRACUNIT/3
						ol.frame = B|FF_FULLBRIGHT
						ol.tics = 20
						localquake(mo.battlen, 7*FRACUNIT, 2)

						ol = P_SpawnMobj(x, y, z, MT_DUMMY)
						ol.sprite = SPR_NTHK
						ol.color = psiocolors[P_RandomRange(1, #psiocolors)]
						ol.scale = 1
						ol.destscale = FRACUNIT*32
						ol.scalespeed = FRACUNIT
						ol.frame = B|FF_FULLBRIGHT|TR_TRANS50
						ol.tics = 8

					end
				end

				if timer == 120
					damageObject(target)
				end

			elseif timer == 160
				return true
			end
		end,
	},

	["mapsiodyne"] = {
		name = "Mapsiodyne",
		type = ATK_PSY,
		power = 350,
		accuracy = 90,
		costtype = CST_SP,
		cost = 24,
		desc = "Heavy Psy dmg to all enemies.",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)

			for k,v in ipairs(hittargets)

				local target = v
				local time = timer- 6*(k-1)

				local psiocolors = {SKINCOLOR_TEAL, SKINCOLOR_YELLOW, SKINCOLOR_PINK, SKINCOLOR_BLACK, SKINCOLOR_WHITE}

				if target.psiodyne and #target.psiodyne
					-- slow all of these down
					for i = 1, #target.psiodyne do
						local f = target.psiodyne[i]
						if not f or not f.valid continue end
						local g = P_SpawnGhostMobj(f)
						g.destscale = 1
					end
				end

				if time == 20
					target.psiodyne = {}
					playSound(mo.battlen, sfx_s3k74)

					local ol = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					ol.sprite = SPR_NTHK
					ol.color = psiocolors[P_RandomRange(1, #psiocolors)]
					ol.scale = 1
					ol.destscale = FRACUNIT*32
					ol.scalespeed = FRACUNIT/3
					ol.frame = B|FF_FULLBRIGHT
					ol.tics = 20

					-- spawn all the particles
					for i = 1, 32 do
						local ol = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
						ol.sprite = SPR_NTHK
						ol.color = psiocolors[P_RandomRange(1, #psiocolors)]
						ol.scale = 1
						ol.destscale = FRACUNIT/2
						ol.frame = A|FF_FULLBRIGHT
						ol.tics = -1
						ol.angle = P_RandomRange(0, 359)*ANG1

						local hthrust = P_RandomRange(0, 128)
						local vthrust = 128-hthrust
						P_InstaThrust(ol, ol.angle, hthrust*FRACUNIT)
						ol.momz = vthrust*FRACUNIT
						ol.savemoms = {ol.momx, ol.momy, ol.momz}
						target.psiodyne[#target.psiodyne+1] = ol
					end

				elseif time >= 20
				and time <= 60
					-- slow all of these down
					for i = 1, #target.psiodyne do
						local f = target.psiodyne[i]
						f.momx = $*80/100
						f.momy = $*80/100
						f.momz = $*80/100
					end

				elseif time > 60 and time < 128
					local t = time-60
					local f = target.psiodyne[t]
					if f and f.valid
						f.momx = -f.savemoms[1]
						f.momy = -f.savemoms[2]
						f.momz = -f.savemoms[3]
						f.fuse = 8
					end

					if time > 60 + TICRATE/3
						-- make impacts
						if not (leveltime%4)

							local x = target.x + P_RandomRange(-256, 256)*FRACUNIT
							local y = target.y + P_RandomRange(-256, 256)*FRACUNIT
							local z = target.z + P_RandomRange(0, 256)*FRACUNIT

							playSound(mo.battlen, sfx_s3k77)
							localquake(mo.battlen, FRACUNIT*64, 10)

							local ol = P_SpawnMobj(x, y, z, MT_DUMMY)
							ol.sprite = SPR_NTHK
							ol.color = psiocolors[P_RandomRange(1, #psiocolors)]
							ol.scale = 1
							ol.destscale = FRACUNIT*32
							ol.scalespeed = FRACUNIT/3
							ol.frame = B|FF_FULLBRIGHT
							ol.tics = 20
							localquake(mo.battlen, 7*FRACUNIT, 2)

							ol = P_SpawnMobj(x, y, z, MT_DUMMY)
							ol.sprite = SPR_NTHK
							ol.color = psiocolors[P_RandomRange(1, #psiocolors)]
							ol.scale = 1
							ol.destscale = FRACUNIT*32
							ol.scalespeed = FRACUNIT
							ol.frame = B|FF_FULLBRIGHT|TR_TRANS50
							ol.tics = 8
						end
					end

					if time == 120
						damageObject(target)
					end
				end
			end

			if timer == 160 + (#hittargets-1) *6
				return true
			end
		end,
	},

	["psycho force"] = {
		name = "Psycho Force",
		type = ATK_PSY,
		power = 650,
		accuracy = 95,
		costtype = CST_SP,
		cost = 24,
		desc = "Severe Psy dmg to one enemy.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			local psiocolors = {SKINCOLOR_TEAL, SKINCOLOR_YELLOW, SKINCOLOR_PINK, SKINCOLOR_BLACK, SKINCOLOR_WHITE}

			if target.psiodyne and #target.psiodyne
				-- slow all of these down
				for i = 1, #target.psiodyne do
					local f = target.psiodyne[i]
					if not f or not f.valid continue end
					local g = P_SpawnGhostMobj(f)
					g.destscale = 1
				end
			end


			-- Lift the target

			if timer <= 130
			and timer > 20
				target.momz = (target.floorz + FRACUNIT*192 - target.z)/8
				P_SpawnGhostMobj(target)

			elseif timer > 130
				target.momz = -32*target.scale

				if P_IsObjectOnGround(target)
				and not target.tkdamage
					damageObject(hittargets[1])
					target.tkdamage = true
					for i = 1, 3
						createSplat(mo)
					end
					for i = 1,32
						local dust = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
						dust.angle = ANGLE_90 + ANG1* (11*(i-1))
						dust.destscale = FRACUNIT*10
						dust.state = S_AOADUST1
						dust.frame = A|FF_FULLBRIGHT
						P_InstaThrust(dust, dust.angle, 20*FRACUNIT)

						local a = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
						a.sprite = SPR_NTHK
						a.frame = A|FF_FULLBRIGHT
						a.tics = TICRATE*2
						a.color = psiocolors[P_RandomRange(1, #psiocolors)]
						a.flags = $ & ~MF_NOGRAVITY
						a.momx = P_RandomRange(-16, 16)*target.scale
						a.momy = P_RandomRange(-16, 16)*target.scale
						a.momz = P_RandomRange(8, 32)*target.scale

					end
					playSound(mo.battlen, sfx_pstop)
					localquake(mo.battlen, FRACUNIT*32, TICRATE/2)

					target.tkdamage = true
				end
			end

			if timer == 20
				target.psiodyne = {}
				playSound(mo.battlen, sfx_s3k74)

				local ol = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
				ol.sprite = SPR_NTHK
				ol.color = psiocolors[P_RandomRange(1, #psiocolors)]
				ol.scale = 1
				ol.destscale = FRACUNIT*32
				ol.scalespeed = FRACUNIT/3
				ol.frame = B|FF_FULLBRIGHT
				ol.tics = 20

				-- spawn all the particles
				for i = 1, 64 do
					local ol = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					ol.sprite = SPR_NTHK
					ol.color = psiocolors[P_RandomRange(1, #psiocolors)]
					ol.scale = 1
					ol.destscale = FRACUNIT*2/3
					ol.frame = A|FF_FULLBRIGHT
					ol.tics = -1
					ol.angle = P_RandomRange(0, 359)*ANG1

					local hthrust = P_RandomRange(0, 128)
					local vthrust = 128-hthrust
					P_InstaThrust(ol, ol.angle, hthrust*FRACUNIT)
					ol.momz = vthrust*FRACUNIT
					ol.savemoms = {ol.momx, ol.momy, ol.momz}
					target.psiodyne[#target.psiodyne+1] = ol
				end

			elseif timer >= 20
			and timer <= 60
				-- slow all of these down
				for i = 1, #target.psiodyne do
					local f = target.psiodyne[i]
					f.momx = $*80/100
					f.momy = $*80/100
					f.momz = $*80/100
				end

			elseif timer > 60 and timer < 128
				local t = timer-60
				local f = target.psiodyne[t]
				if f and f.valid
					f.momx = -f.savemoms[1]*2
					f.momy = -f.savemoms[2]*2

					local hspd = FixedHypot(abs(f.savemoms[1]), abs(f.savemoms[2]))

					f.momz = FixedDiv((target.z - f.z), max(1, hspd))
					f.fuse = 8
				end

				if timer > 60 + TICRATE/3
					-- make impacts
					if not (leveltime%4)

						local x = target.x + P_RandomRange(-256, 256)*FRACUNIT
						local y = target.y + P_RandomRange(-256, 256)*FRACUNIT
						local z = target.z + P_RandomRange(0, 256)*FRACUNIT

						playSound(mo.battlen, sfx_s3k77)
						localquake(mo.battlen, FRACUNIT*64, 10)

						local ol = P_SpawnMobj(x, y, z, MT_DUMMY)
						ol.sprite = SPR_NTHK
						ol.color = psiocolors[P_RandomRange(1, #psiocolors)]
						ol.scale = 1
						ol.destscale = FRACUNIT*32
						ol.scalespeed = FRACUNIT/3
						ol.frame = B|FF_FULLBRIGHT
						ol.tics = 20
						localquake(mo.battlen, 7*FRACUNIT, 2)

						ol = P_SpawnMobj(x, y, z, MT_DUMMY)
						ol.sprite = SPR_NTHK
						ol.color = psiocolors[P_RandomRange(1, #psiocolors)]
						ol.scale = 1
						ol.destscale = FRACUNIT*32
						ol.scalespeed = FRACUNIT
						ol.frame = B|FF_FULLBRIGHT|TR_TRANS50
						ol.tics = 8

					end
				end

			elseif timer == 190
				target.tkdamage = nil	-- reset this
				return true
			end
		end,
	},

	["ghastly wail"] = {
		name = "Ghastly Wail",
		type = ATK_ALMIGHTY,
		power = 100,
		accuracy = 999,
		costtype = CST_SP,
		ghastlywail = true,
		instakill = true,	-- the enemy is instantly killed without its health being displayed
		cost = 1,
		desc = "Instantly kills a foe inflicted\nwith Hex.",
		target = TGT_ENEMY,

		nocast = 	function(targets, n)	-- we can't cast this skill if this function returns true
						local target = targets[n]
						if target.status_condition ~= COND_HEX
							BTL_logMessage(target.battlen, "This won't have any effect")
							return true
						end
					end,

		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 10
				playSound(mo.battlen, sfx_eih2)

				local x = target.x + 48*cos(target.angle)
				local y = target.y + 48*sin(target.angle)

				local m = P_SpawnMobj(x, y, target.z + FRACUNIT*32, MT_DUMMY)
				m.sprite = SPR_MUDO
				m.frame = A|FF_TRANS20|FF_FULLBRIGHT|FF_PAPERSPRITE
				m.angle = mo.angle + ANG1*90
				m.tics = -1
				m.scale = FRACUNIT*3/2
				target.mudo = m

				m = P_SpawnMobj(x, y, target.z + FRACUNIT*32, MT_DUMMY)
				m.sprite = SPR_MUDO
				m.frame = A|FF_TRANS60|FF_FULLBRIGHT|FF_PAPERSPRITE
				m.angle = mo.angle + ANG1*90
				m.destscale = FRACUNIT*8
				m.scalespeed = FRACUNIT/6
				m.tics = 8
			elseif timer == 30
				target.mudo.destscale = 1
				target.mudo.tics = 12
			elseif timer == 40
				if target.status_condition == COND_HEX	-- Last doublecheck just in case this slipped by!
					damageObject(target)
				else
					BTL_logMessage(mo.battlen, "But it failed!")
				end
				target.mudo = nil
			elseif timer == 60
				return true
			end
		end,
	},

	["mudo"] = {
		name = "Mudo",
		type = ATK_CURSE,
		power = 100,
		accuracy = 25,
		costtype = CST_SP,
		instakill = true,	-- the enemy is instantly killed without its health being displayed
		luckbased = true,	-- use luck instead of agility
		cost = 8,
		desc = "Death based attack. \nSlim chance of instant kill to \none enemy.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 10
				playSound(mo.battlen, sfx_eih1)

				local x = target.x + 48*cos(target.angle)
				local y = target.y + 48*sin(target.angle)

				local m = P_SpawnMobj(x, y, target.z + FRACUNIT*32, MT_DUMMY)
				m.sprite = SPR_MUDO
				m.scale = FRACUNIT*2
				m.frame = B|FF_TRANS20|FF_FULLBRIGHT|FF_PAPERSPRITE
				m.angle = target.angle + ANG1*90
				m.tics = -1
				target.mudo = m

				m = P_SpawnMobj(x, y, target.z + FRACUNIT*32, MT_DUMMY)
				m.sprite = SPR_MUDO
				m.frame = B|FF_TRANS60|FF_FULLBRIGHT|FF_PAPERSPRITE
				m.angle = target.angle + ANG1*90
				m.destscale = FRACUNIT*8
				m.scalespeed = FRACUNIT/6
				m.tics = 8
			elseif timer == 30
				target.mudo.destscale = 1
				target.mudo.scalespeed = FRACUNIT/6
				target.mudo.tics = 12
			elseif timer == 40
				damageObject(target)
				target.mudo = nil
			elseif timer == 60
				return true
			end
		end,
	},

	["mudoon"] = {
		name = "Mudoon",
		type = ATK_CURSE,
		power = 100,
		accuracy = 40,
		costtype = CST_SP,
		instakill = true,	-- the enemy is instantly killed without its health being displayed
		luckbased = true,	-- use luck instead of agility
		cost = 16,
		desc = "Death based attack. \nMedium chance of instant kill to \none enemy.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			local function spawnFlame(m, dist, z)
				local x = m.x + dist*cos(m.angle + ANG1*90) + 24*cos(m.angle)
				local y = m.y + dist*sin(m.angle + ANG1*90) + 24*sin(m.angle)
				local f = P_SpawnMobj(x, y, z, MT_THOK)
				f.state = S_FLAME
				f.scale = 1
				f.destscale = FRACUNIT
				f.colorized = true
				f.color = SKINCOLOR_PURPLE
				f.flags = MF_NOGRAVITY|MF_NOCLIPHEIGHT
				return f
			end

			if timer == 10
				local x = target.x + 48*cos(target.angle)
				local y = target.y + 48*sin(target.angle)
				playSound(mo.battlen, sfx_eih2)
				target.mudo_dum = P_SpawnMobj(x, y, target.z + FRACUNIT*32, MT_DUMMY)
				target.mudo_dum.state = S_INVISIBLE
				target.mudo_dum.tics = -1
				target.mudo_dum.angle = target.angle

				local f = spawnFlame(target.mudo_dum, 0, target.mudo_dum.z + FRACUNIT*48)
				f.fuse = TICRATE*2
			elseif timer == 15
				local f = spawnFlame(target.mudo_dum, 48, target.mudo_dum.z)
				f.fuse = TICRATE*2 -5
			elseif timer == 20
				local f = spawnFlame(target.mudo_dum, 0, target.mudo_dum.z - FRACUNIT*48)
				f.fuse = TICRATE*2 -10
			elseif timer == 25
				local f = spawnFlame(target.mudo_dum, -49, target.mudo_dum.z)
				f.fuse = TICRATE*2 -15


				local m = P_SpawnMobj(target.mudo_dum.x, target.mudo_dum.y, target.z + FRACUNIT*32, MT_DUMMY)
				m.sprite = SPR_MUDO
				m.frame = A|FF_TRANS20|FF_FULLBRIGHT|FF_PAPERSPRITE
				m.angle = target.angle + ANG1*90
				m.tics = -1
				m.scale = FRACUNIT*3/2
				target.mudo = m

				m = P_SpawnMobj(target.mudo_dum.x, target.mudo_dum.y, target.z + FRACUNIT*32, MT_DUMMY)
				m.sprite = SPR_MUDO
				m.frame = A|FF_TRANS60|FF_FULLBRIGHT|FF_PAPERSPRITE
				m.angle = mo.angle + ANG1*90
				m.destscale = FRACUNIT*8
				m.scalespeed = FRACUNIT/6
				m.tics = 8

				m = P_SpawnMobj(target.mudo_dum.x, target.mudo_dum.y, target.z + FRACUNIT*32, MT_DUMMY)
				m.sprite = SPR_MUDO
				m.frame = B|FF_TRANS60|FF_FULLBRIGHT|FF_PAPERSPRITE
				m.angle = mo.angle + ANG1*90
				m.destscale = FRACUNIT*8
				m.scalespeed = FRACUNIT/6
				m.tics = 8

			elseif timer == 50
				target.mudo.destscale = 1
				target.mudo.tics = 20
			elseif timer == 70
				damageObject(target)
				target.mudo = nil
				P_RemoveMobj(target.mudo_dum)
				target.mudo_dum = nil
			elseif timer == 110
				return true
			end
		end,
	},

	["mamudo"] = {
		name = "Mamudo",
		type = ATK_CURSE,
		power = 100,
		accuracy = 20,
		costtype = CST_SP,
		instakill = true,	-- the enemy is instantly killed without its health being displayed
		luckbased = true,	-- use luck instead of agility
		cost = 20,
		desc = "Death based attack. \nSlim chance of instant kill to \nall enemies.",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)

			for k,v in ipairs(hittargets)
				local target = v
				local t = timer - 6*(k-1)

				if t == 10
					playSound(mo.battlen, sfx_eih1)

					local x = target.x + 48*cos(target.angle)
					local y = target.y + 48*sin(target.angle)

					local m = P_SpawnMobj(x, y, target.z + FRACUNIT*32, MT_DUMMY)
					m.sprite = SPR_MUDO
					m.frame = B|FF_TRANS20|FF_FULLBRIGHT|FF_PAPERSPRITE
					m.angle = target.angle + ANG1*90
					m.scale = FRACUNIT*2
					m.tics = -1
					target.mudo = m

					m = P_SpawnMobj(x, y, target.z + FRACUNIT*32, MT_DUMMY)
					m.sprite = SPR_MUDO
					m.frame = B|FF_TRANS60|FF_FULLBRIGHT|FF_PAPERSPRITE
					m.angle = target.angle + ANG1*90
					m.destscale = FRACUNIT*8
					m.scalespeed = FRACUNIT/6
					m.tics = 8
				elseif t == 30
					if target.mudo and target.mudo.valid
						target.mudo.scalespeed = FRACUNIT/6
						target.mudo.destscale = 1
						target.mudo.tics = 12
					end
				elseif t == 40
					damageObject(target)
					target.mudo = nil
				end
			end
			if timer == 60 + 6*(#hittargets-1)
				return true
			end
		end,
	},

	["mamudoon"] = {
		name = "Mamudoon",
		type = ATK_CURSE,
		power = 100,
		accuracy = 33,
		costtype = CST_SP,
		instakill = true,	-- the enemy is instantly killed without its health being displayed
		luckbased = true,	-- use luck instead of agility
		cost = 40,
		desc = "Death based attack. \nMedium chance of instant kill to \none enemy.",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)

			local function spawnFlame(m, dist, z)
				local x = m.x + dist*cos(m.angle + ANG1*90) + 24*cos(m.angle)
				local y = m.y + dist*sin(m.angle + ANG1*90) + 24*sin(m.angle)
				local f = P_SpawnMobj(x, y, z, MT_THOK)
				f.state = S_FLAME
				f.scale = 1
				f.destscale = FRACUNIT
				f.colorized = true
				f.color = SKINCOLOR_PURPLE
				f.flags = MF_NOGRAVITY|MF_NOCLIPHEIGHT
				return f
			end

			for i = 1, #hittargets
				local target = hittargets[i]
				local time = timer - 6*(i-1)

				if time == 10
					local x = target.x + 48*cos(target.angle)
					local y = target.y + 48*sin(target.angle)
					playSound(mo.battlen, sfx_eih2)
					target.mudo_dum = P_SpawnMobj(x, y, target.z + FRACUNIT*32, MT_DUMMY)
					target.mudo_dum.state = S_INVISIBLE
					target.mudo_dum.tics = -1
					target.mudo_dum.angle = target.angle

					local f = spawnFlame(target.mudo_dum, 0, target.mudo_dum.z + FRACUNIT*48)
					f.fuse = TICRATE*2
				elseif time == 15
					local f = spawnFlame(target.mudo_dum, 48, target.mudo_dum.z)
					f.fuse = TICRATE*2 -5
				elseif time == 20
					local f = spawnFlame(target.mudo_dum, 0, target.mudo_dum.z - FRACUNIT*48)
					f.fuse = TICRATE*2 -10
				elseif time == 25
					local f = spawnFlame(target.mudo_dum, -49, target.mudo_dum.z)
					f.fuse = TICRATE*2 -15


					local m = P_SpawnMobj(target.mudo_dum.x, target.mudo_dum.y, target.z + FRACUNIT*32, MT_DUMMY)
					m.sprite = SPR_MUDO
					m.frame = A|FF_TRANS20|FF_FULLBRIGHT|FF_PAPERSPRITE
					m.angle = target.angle + ANG1*90
					m.tics = -1
					m.scale = FRACUNIT*3/2
					target.mudo = m

					m = P_SpawnMobj(target.mudo_dum.x, target.mudo_dum.y, target.z + FRACUNIT*32, MT_DUMMY)
					m.sprite = SPR_MUDO
					m.frame = A|FF_TRANS60|FF_FULLBRIGHT|FF_PAPERSPRITE
					m.angle = mo.angle + ANG1*90
					m.destscale = FRACUNIT*8
					m.scalespeed = FRACUNIT/6
					m.tics = 8

					m = P_SpawnMobj(target.mudo_dum.x, target.mudo_dum.y, target.z + FRACUNIT*32, MT_DUMMY)
					m.sprite = SPR_MUDO
					m.frame = B|FF_TRANS60|FF_FULLBRIGHT|FF_PAPERSPRITE
					m.angle = mo.angle + ANG1*90
					m.destscale = FRACUNIT*8
					m.scalespeed = FRACUNIT/6
					m.tics = 8

				elseif time == 50
					target.mudo.destscale = 1
					target.mudo.tics = 20
				elseif time == 70
					damageObject(target)
					target.mudo = nil
					P_RemoveMobj(target.mudo_dum)
					target.mudo_dum = nil
				end
			end

			if timer == 110 + (#hittargets-1) *6
				return true
			end
		end,
	},

	-- Original animation courtesy of @Helius Universe
	-- Modified slightly to improve quality
	["die for me"] = {
		name = "Die For Me!",
		type = ATK_CURSE,
		power = 100,
		accuracy = 55,
		costtype = CST_SP,
		instakill = true,	-- the enemy is instantly killed without its health being displayed
		luckbased = true,	-- use luck instead of agility
		cost = 60,
		desc = "Death based attack. \nVery high chance of instant \nkill to all enemies.",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)

			-- yes we can do that...
			local teddythinker = function(mo)
				if R_PointToDist2(mo.x,mo.y,mo.targetx,mo.targety)<(FRACUNIT*128)
					--destroy teddy
					for i=1,5
						local s = P_SpawnMobj(mo.x+P_RandomRange(-8,8)*FRACUNIT,mo.y+P_RandomRange(-8,8)*FRACUNIT,mo.z+P_RandomRange(-8,8)*FRACUNIT, MT_DUMMY)
						s.sprite = SPR_TEDL
						s.tics = TICRATE
						s.flags = $ & ~MF_NOGRAVITY
						s.frame = P_RandomRange(0,4)
						s.momx = P_RandomRange(-8,8)*FRACUNIT
						s.momy = P_RandomRange(-8,8)*FRACUNIT
						s.momz = P_RandomRange(0,16)*FRACUNIT
						s.angle = FixedAngle(P_RandomRange(0,360)*FRACUNIT)
					end

					for i=1,15
						local s = P_SpawnMobj(mo.x+P_RandomRange(-16,16)*FRACUNIT,mo.y+P_RandomRange(-16,16)*FRACUNIT,mo.z+P_RandomRange(-16,16)*FRACUNIT, MT_DUMMY)
						s.sprite = SPR_TEDB
						s.frame = A
						s.tics = 15
						s.flags = $ & ~MF_NOGRAVITY
						s.momx = P_RandomRange(-16,16)*FRACUNIT
						s.momy = P_RandomRange(-16,16)*FRACUNIT
						s.momz = P_RandomRange(0,32)*FRACUNIT
					end
					P_RemoveMobj(mo)
					return true
				end
			end

			mo.teddybears = $ or {}
			local teddys = 15
			if timer == 1
				playSound(mo.battlen, sfx_dfms)
				local avgx, avgy, avgz = 0, 0, 0
				for i = 1, #hittargets
					avgx = $ + hittargets[i].x/FRACUNIT
					avgy = $ + hittargets[i].y/FRACUNIT
					avgz = $ + hittargets[i].z/FRACUNIT
				end

				avgx = ($/#hittargets)*FRACUNIT
				avgy = ($/#hittargets)*FRACUNIT
				avgz = ($/#hittargets)*FRACUNIT

				for i=1,teddys
					local speed = FRACUNIT*20
					local radius = P_RandomRange(512,2048)*FRACUNIT
					local angle = FixedAngle(P_RandomRange(0,259)*FRACUNIT)
					local xOffset = cos(angle)
					local yOffset = sin(angle)
					local x = avgx+FixedMul(xOffset,radius)
					local y = avgy+FixedMul(yOffset,radius)
					local s = P_SpawnMobj(x,y,avgz, MT_DUMMY)
					s.state = S_TEDDYRUN
					s.momx = FixedMul(-xOffset,speed)
					s.momy = FixedMul(-yOffset,speed)
					s.targetx = avgx
					s.targety = avgy
					s.angle = R_PointToAngle2(s.x, s.y, avgx, avgy) --InvAngle(angle)
					table.insert(mo.teddybears,s)
				end
			end


			for i=1,#hittargets
				if timer == (60 + (i-1)*5)
					damageObject(hittargets[i])
				end
			end

			if mo.teddybears and #mo.teddybears

				local i = #mo.teddybears
				while i~=0
					if teddythinker(mo.teddybears[i])
						table.remove(mo.teddybears,i)
					end
					i=$-1
				end

			end

			if timer == 110

				return true
			end
		end,
		hudfunc2 = function(v,mo,timer)
			local background = v.cachePatch("DFMBG")
			local backgroundFlags = {V_90TRANS,V_80TRANS,V_70TRANS,V_60TRANS}
			local curtains = {"CURTAI0","CURTAI1","CURTAI2","CURTAI3","CURTAI4","CURTAI5"}
			if timer<=15
				local curtainDuration = 15
				local progress = FixedDiv(timer<<FRACBITS,curtainDuration<<FRACBITS)
				drawScreenwidePatch(v, background, nil, backgroundFlags[FixedMul(progress,(#backgroundFlags-1)<<FRACBITS)>>FRACBITS+1])
				--timer divided by the duration times the number of frames and then converted to integer scale

				local curtain = v.cachePatch(curtains[(FixedMul(progress,(#curtains-1)<<FRACBITS)>>FRACBITS)+1])
				drawScreenwidePatch(v, curtain)
			else
				local curtain = v.cachePatch(curtains[#curtains])
				local tm = 10
				if timer > 80
					tm = max(0, 90 - timer)
				end

				drawScreenwidePatch(v, background, nil, backgroundFlags[#backgroundFlags] + ((5-(tm/2)) << V_ALPHASHIFT))
				drawScreenwidePatch(v, curtain, nil, (10-tm) << V_ALPHASHIFT)
			end
		end
	},

	["hama"] = {
		name = "Hama",
		type = ATK_BLESS,
		power = 100,
		accuracy = 25,
		costtype = CST_SP,
		instakill = true,	-- the enemy is instantly killed without its health being displayed
		luckbased = true,	-- use luck instead of agility
		cost = 8,
		desc = "Expel based attack. \nSlim chance of instant kill to \none enemy.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if target.cards
				local cam = server.P_BattleStatus[mo.battlen].cam
				for kk, vv in ipairs(target.cards)

					if not target continue end
					if not vv continue end

					if timer <= 70

						local target_x = target.x + 80*(cos(vv.angle - ANG1*80))
						local target_y = target.y + 80*(sin(vv.angle - ANG1*80))
						vv.frame = A|FF_PAPERSPRITE
						vv.scale = FRACUNIT + FRACUNIT/3
						vv.angle = $-ANG1*35

						P_TeleportMove(vv, target_x, target_y, vv.z)
					else
						if vv and vv.valid
							vv.momz = 0
						end
					end

					if timer == 80
					and vv.valid
						P_RemoveMobj(vv)
					end
				end
			end

			if timer == 90
				target.cards = nil
			end

			if timer == 80
				playSound(mo.battlen, sfx_hamas1)
				damageObject(target)

				local thok = P_SpawnMobj(target.x, target.y, target.z+5*FRACUNIT, MT_DUMMY)
				thok.state = S_INVISIBLE
				thok.tics = 1
				thok.scale = FRACUNIT*4
				A_OldRingExplode(thok, MT_SUPERSPARK)
			end

			if timer == 100
				return true
			end

			if timer >= 15
			and timer <= 75
				if not (timer%4)
					if not target.cards then target.cards = {} end
					for i = 1,4
						local angle = P_RandomRange(1, 359)*ANG1
						local x = target.x + 64*(cos(angle))
						local y = target.y + 64*(sin(angle))
						local item = P_SpawnMobj(x, y, target.z, MT_DUMMY)
						playSound(mo.battlen, sfx_hamaca)
						item.tics = -1
						item.sprite = SPR_CARD
						item.frame = A|FF_PAPERSPRITE
						item.angle = angle - ANG1*80
						item.momz = 5*FRACUNIT
						table.insert(target.cards, item)
					end
				end
			end
		end,
	},

	["mahama"] = {
		name = "Mahama",
		type = ATK_BLESS,
		power = 100,
		accuracy = 20,
		costtype = CST_SP,
		instakill = true,	-- the enemy is instantly killed without its health being displayed
		luckbased = true,	-- use luck instead of agility
		cost = 20,
		desc = "Expel based attack. \nSlim chance of instant kill to \nall enemies",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)
			for k,v in ipairs(hittargets)

				local target = v
				local time = timer - 6*(k-1)

				if target.cards
					local cam = server.P_BattleStatus[mo.battlen].cam
					for kk, vv in ipairs(target.cards)

						if not target continue end
						if not vv continue end

						if time <= 70

							local target_x = target.x + 80*(cos(vv.angle - ANG1*80))
							local target_y = target.y + 80*(sin(vv.angle - ANG1*80))
							vv.frame = A|FF_PAPERSPRITE
							vv.scale = FRACUNIT + FRACUNIT/3
							vv.angle = $-ANG1*35

							P_TeleportMove(vv, target_x, target_y, vv.z)
						else
							if vv and vv.valid
								vv.momz = 0
							end
						end

						if time == 80
						and vv.valid
							P_RemoveMobj(vv)
						end
					end
				end

				if time == 90
					target.cards = nil
				end

				if time == 80
					playSound(mo.battlen, sfx_hamas1)
					damageObject(target)

					local thok = P_SpawnMobj(target.x, target.y, target.z+5*FRACUNIT, MT_DUMMY)
					thok.state = S_INVISIBLE
					thok.tics = 1
					thok.scale = FRACUNIT*4
					A_OldRingExplode(thok, MT_SUPERSPARK)
				end

				if timer == 100 + (#hittargets-1)*6
					return true
				end

				if time >= 15
				and time <= 75
					if not (timer%4)
						if not target.cards then target.cards = {} end
						for i = 1,4
							local angle = P_RandomRange(1, 359)*ANG1
							local x = target.x + 64*(cos(angle))
							local y = target.y + 64*(sin(angle))
							local item = P_SpawnMobj(x, y, target.z, MT_DUMMY)
							playSound(mo.battlen, sfx_hamaca)
							item.tics = -1
							item.sprite = SPR_CARD
							item.frame = A|FF_PAPERSPRITE
							item.angle = angle - ANG1*80
							item.momz = 5*FRACUNIT
							table.insert(target.cards, item)
						end
					end
				end
			end
		end,
	},

	["hamaon"] = {
		name = "Hamaon",
		type = ATK_BLESS,
		power = 100,
		accuracy = 40,
		costtype = CST_SP,
		instakill = true,	-- the enemy is instantly killed without its health being displayed
		luckbased = true,	-- use luck instead of agility
		cost = 16,
		desc = "Expel based attack. \nModerate chance of instant kill to \none enemy.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if target.cards
				local cam = server.P_BattleStatus[mo.battlen].cam
				for kk, vv in ipairs(target.cards)

					if not target continue end
					if not vv continue end

					if timer <= 70
						local target_x = target.x + 80*(cos(vv.angle - ANG1*80))
						local target_y = target.y + 80*(sin(vv.angle - ANG1*80))
						if kk%2
							vv.sprite = SPR_CARD
							vv.frame = A|FF_PAPERSPRITE
						else
							vv.sprite = SPR_SPRK
							vv.frame = A
						end
						vv.scale = FRACUNIT + FRACUNIT/3
						vv.angle = $-ANG1*35

						P_TeleportMove(vv, target_x, target_y, vv.z)
					else
						if vv and vv.valid
							vv.momz = 0
						end
					end

					if timer == 80
					and vv.valid
						P_RemoveMobj(vv)
					end
				end
			end

			if timer == 90
				target.cards = nil
			end

			if timer == 80
				playSound(mo.battlen, sfx_hamas1)
				damageObject(target)

				local thok = P_SpawnMobj(target.x, target.y, target.z+5*FRACUNIT, MT_DUMMY)
				thok.state = S_INVISIBLE
				thok.tics = 1
				thok.scale = FRACUNIT*4
				A_OldRingExplode(thok, MT_SUPERSPARK)
			end

			if timer == 100
				return true
			end

			if timer >= 15
			and timer <= 75
				if not (timer%4)
					if not target.cards then target.cards = {} end
					for i = 1,8
						local angle = P_RandomRange(1, 359)*ANG1
						local x = target.x + 64*(cos(angle))
						local y = target.y + 64*(sin(angle))
						local item = P_SpawnMobj(x, y, target.z, MT_DUMMY)
						playSound(mo.battlen, sfx_hamaca)
						item.tics = -1
						if i%2
							item.sprite = SPR_CARD
							item.frame = A|FF_PAPERSPRITE
						else
							item.sprite = SPR_SPRK
							item.frame = A
						end
						item.angle = angle - ANG1*80
						item.momz = 5*FRACUNIT
						table.insert(target.cards, item)
					end
				end
			end
		end,
	},

	["mahamaon"] = {
		name = "Mahamaon",
		type = ATK_BLESS,
		power = 100,
		accuracy = 33,
		costtype = CST_SP,
		instakill = true,	-- the enemy is instantly killed without its health being displayed
		luckbased = true,	-- use luck instead of agility
		cost = 42,
		desc = "Expel based attack. \nModerate chance of instant kill to \nall enemies.",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)

			for i = 1, #hittargets
				local target = hittargets[i]
				local time = timer - (i-1)*6

				if target.cards
					local cam = server.P_BattleStatus[mo.battlen].cam
					for kk, vv in ipairs(target.cards)

						if not target continue end
						if not vv continue end

						if time <= 70
							local target_x = target.x + 80*(cos(vv.angle - ANG1*80))
							local target_y = target.y + 80*(sin(vv.angle - ANG1*80))
							if kk%2
								vv.sprite = SPR_CARD
								vv.frame = A|FF_PAPERSPRITE
							else
								vv.sprite = SPR_SPRK
								vv.frame = A
							end
							vv.scale = FRACUNIT + FRACUNIT/3
							vv.angle = $-ANG1*35

							P_TeleportMove(vv, target_x, target_y, vv.z)
						else
							if vv and vv.valid
								vv.momz = 0
							end
						end

						if time == 80
						and vv.valid
							P_RemoveMobj(vv)
						end
					end
				end

				if time == 90
					target.cards = nil
				end

				if time == 80
					playSound(mo.battlen, sfx_hamas1)
					damageObject(target)

					local thok = P_SpawnMobj(target.x, target.y, target.z+5*FRACUNIT, MT_DUMMY)
					thok.state = S_INVISIBLE
					thok.tics = 1
					thok.scale = FRACUNIT*4
					A_OldRingExplode(thok, MT_SUPERSPARK)
				end

				if time >= 15
				and time <= 75
					if not (timer%4)
						if not target.cards then target.cards = {} end
						for i = 1,8
							local angle = P_RandomRange(1, 359)*ANG1
							local x = target.x + 64*(cos(angle))
							local y = target.y + 64*(sin(angle))
							local item = P_SpawnMobj(x, y, target.z, MT_DUMMY)
							playSound(mo.battlen, sfx_hamaca)
							item.tics = -1
							if i%2
								item.sprite = SPR_CARD
								item.frame = A|FF_PAPERSPRITE
							else
								item.sprite = SPR_SPRK
								item.frame = A
							end
							item.angle = angle - ANG1*80
							item.momz = 5*FRACUNIT
							table.insert(target.cards, item)
						end
					end
				end
			end
			if timer == 100 + 6*(#hittargets-1)
				return true
			end
		end,
	},

	["samsara"] = {
		name = "Samsara",
		type = ATK_BLESS,
		power = 100,
		accuracy = 55,
		costtype = CST_SP,
		instakill = true,	-- the enemy is instantly killed without its health being displayed
		luckbased = true,	-- use luck instead of agility
		cost = 64,
		desc = "Expel based attack. Very\nhigh chance of instant\nkill to all enemies.",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)

				local avgx = 0
				local avgy = 0
				for i = 1, #hittargets do
					avgx = $ + hittargets[i].x/FRACUNIT
					avgy = $ + hittargets[i].y/FRACUNIT
				end
				avgx = $ / #hittargets *FRACUNIT
				avgy = $ / #hittargets *FRACUNIT
				-- average position of the enemies

				if timer == 10
					playSound(mo.battlen, sfx_hama3)

					-- get them cards ready

					-- first row
					mo.hcard = {}
					for i = 1, 6
						local ang = (360/6 *i)*ANG1
						local c = P_SpawnMobj(avgx + 256*cos(ang), avgy + 256*sin(ang), mo.z, MT_DUMMY)
						c.sprite = SPR_CARD
						c.frame = J|FF_FULLBRIGHT|FF_PAPERSPRITE
						c.angle = ang+ANG1*90
						c.tics = -1
						mo.hcard[#mo.hcard+1] = c
					end
				elseif timer == 20
					-- get them cards ready

					-- first row
					mo.hcard2 = {}
					for i = 1, 10
						local ang = (360/10 *i)*ANG1
						local c = P_SpawnMobj(avgx + 320*cos(ang), avgy + 320*sin(ang), mo.z, MT_DUMMY)
						c.sprite = SPR_CARD
						c.frame = J|FF_FULLBRIGHT|FF_PAPERSPRITE
						c.angle = ang+ANG1*90
						c.tics = -1
						c.scale = FRACUNIT/2
						mo.hcard2[#mo.hcard2+1] = c
					end
				end

				local ct = mo.hcard
				while ct

					for i = 1, #ct
						local c = ct[i]

						if c.appeartimer == nil
							c.appeartimer = 9
						end
						c.frame = J|FF_FULLBRIGHT|FF_PAPERSPRITE | (c.appeartimer<<FF_TRANSSHIFT)
						c.appeartimer = max(4, $-1)

						if timer >= TICRATE*3/2
						and leveltime & 1
							c.frame = K|FF_FULLBRIGHT|FF_PAPERSPRITE
						end

						if c.appeartimer <= 4

							c.rspeed = $ or 1
							if leveltime%4 == 0
								c.rspeed = min(25, $+1)
							end

							if ct == mo.hcard2
								c.angle = $ + c.rspeed*ANG1
							else
								c.angle = $ - c.rspeed*ANG1
							end	-- rotate

							--update pos

							if leveltime & 1
								local g = P_SpawnGhostMobj(c)
								g.fuse = 2
							end

							local dist = ct == mo.hcard2 and 320 or 256
							P_TeleportMove(c, avgx + dist*cos(c.angle - ANG1*90), avgy + dist*sin(c.angle - ANG1*90), c.z)
						end

						if timer == TICRATE*5/2
							P_InstaThrust(c, c.angle - ANG1*90, 48*FRACUNIT)
							c.fuse = TICRATE
						end
					end


					-- fuck you
					if ct == mo.hcard2
						break
					else
						ct = mo.hcard2
					end
				end

				if timer >= 20

					if timer == TICRATE
						playSound(mo.battlen, sfx_zio5)
					end

					local baseangle = P_RandomRange(1, 360)*ANG1
					local dist = 256
					for i = 0, 24
						local angle = baseangle + i*6*ANG1
						local x, y = avgx + dist*cos(angle), avgy + dist*sin(angle)

						local aura = P_SpawnMobj(x, y, mo.z + mo.height/4 + i*FRACUNIT*3, MT_DUMMY)
						aura.state = S_AURA1
						--if not aura or not aura.valid continue end
						aura.angle = angle - ANGLE_90
						aura.color = SKINCOLOR_WHITE
						aura.momz = P_RandomRange(4, 16)*FRACUNIT
						aura.scale = FRACUNIT*2
						aura.destscale = FRACUNIT*5
						P_InstaThrust(aura, angle, FRACUNIT*P_RandomRange(3, 9))
					end
				end

				if timer == TICRATE*5/2
					mo.hcard = nil
					mo.hcard2 = nil

					playSound(mo.battlen, sfx_hamas2)

					for k,v in ipairs(hittargets)
						damageObject(v)
					end
				end

				if timer >= TICRATE*5/2
				and timer <= TICRATE*4

					for i = 1, 16
						local boom = P_SpawnMobj(avgx + P_RandomRange(-48, 48)*FRACUNIT, avgy + P_RandomRange(-48, 48)*FRACUNIT, mo.z, MT_SUPERSPARK)
						boom.momz = P_RandomRange(16, 64)*FRACUNIT
						boom.scale = FRACUNIT*2
					end
				end

				if timer == TICRATE*4
					return true
				end
		end,
	},

	["kouha"] = {
		name = "Kouha",
		type = ATK_BLESS,
		power = 75,
		accuracy = 95,
		costtype = CST_SP,
		cost = 4,
		desc = "Light Bless dmg to one enemy.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer >= 20 and timer <= 40
				if timer == 21
					damageObject(target)
					playSound(mo.battlen, sfx_hamas1)
					for i = 1,16
						local thok = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
						thok.state = S_SSPK1
						thok.angle = ANGLE_22h*(i-1)
						P_InstaThrust(thok, thok.angle, 69*FRACUNIT)
					end

					-- now spawn some actual light

					local speeds = {FRACUNIT/16, FRACUNIT/10, FRACUNIT/3, FRACUNIT/8}
					local fuses = {20, 16, 8, 16}

					for i = 1, 4
						local l = P_SpawnMobj(target.x, target.y, target.z + FRACUNIT*32, MT_THOK)	-- mt_thok for auto fadeout
						l.tics = -1
						l.sprite = SPR_CARD
						l.color = SKINCOLOR_YELLOW
						l.frame = L|(i== 2 and TR_TRANS40 or TR_TRANS70)|FF_FULLBRIGHT
						l.scale = FRACUNIT/2
						l.destscale = FRACUNIT*6
						l.scalespeed = speeds[i]
						l.fuse = fuses[i]
					end
				end

			elseif timer == 60
				return true
			end
		end,
	},

	["makouha"] = {
		name = "Makouha",
		type = ATK_BLESS,
		power = 75,
		accuracy = 90,
		costtype = CST_SP,
		cost = 8,
		desc = "Light Bless dmg to \nall enemies",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)

			for k,v in ipairs(hittargets)
				local time = timer - 6*(k-1)
				local target = v

				if time >= 20 and time <= 40
					if time == 21
						damageObject(target)
						playSound(mo.battlen, sfx_hamas1)
						for i = 1,16
							local thok = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
							thok.state = S_SSPK1
							thok.angle = ANGLE_22h*(i-1)
							P_InstaThrust(thok, thok.angle, 69*FRACUNIT)
						end
						-- now spawn some actual light

						local speeds = {FRACUNIT/16, FRACUNIT/10, FRACUNIT/3, FRACUNIT/8}
						local fuses = {20, 16, 8, 16}

						for i = 1, 4
							local l = P_SpawnMobj(target.x, target.y, target.z + FRACUNIT*32, MT_THOK)	-- mt_thok for auto fadeout
							l.tics = -1
							l.sprite = SPR_CARD
							l.color = SKINCOLOR_YELLOW
							l.frame = L|(i== 2 and TR_TRANS40 or TR_TRANS70)|FF_FULLBRIGHT
							l.scale = FRACUNIT/2
							l.destscale = FRACUNIT*6
							l.scalespeed = speeds[i]
							l.fuse = fuses[i]
						end
					end
				end
			end

			if timer == 60 + (#hittargets-1)*6
				return true
			end
		end,
	},

	["kouga"] = {
		name = "Kouga",
		type = ATK_BLESS,
		power = 170,
		accuracy = 95,
		costtype = CST_SP,
		cost = 8,
		desc = "Medium Bless dmg to one enemy.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer >= 20 and timer <= 40

				if leveltime%5 == 0
					local thok = P_SpawnMobj(target.x + P_RandomRange(-200, 200)*FRACUNIT, target.y + P_RandomRange(-200, 200)*FRACUNIT, target.z + P_RandomRange(0, 200)<<FRACBITS, MT_DUMMY)
					A_OldRingExplode(thok, MT_SUPERSPARK)
					thok.flags2 = $|MF2_DONTDRAW
					playSound(mo.battlen, sfx_hamas1)

					local speeds = {FRACUNIT/16, FRACUNIT/10, FRACUNIT/3, FRACUNIT/8}
					local fuses = {20, 16, 8, 16}

					for i = 1, 2
						local l = P_SpawnMobj(thok.x, thok.y, thok.z + FRACUNIT*32, MT_THOK)	-- mt_thok for auto fadeout
						l.tics = -1
						l.sprite = SPR_CARD
						l.color = SKINCOLOR_YELLOW
						l.frame = L|(i== 2 and TR_TRANS40 or TR_TRANS70)|FF_FULLBRIGHT
						l.scale = FRACUNIT/2
						l.destscale = FRACUNIT*6
						l.scalespeed = speeds[i]
						l.fuse = fuses[i]
					end
				end

				if timer == 35
					damageObject(target)
				end
				for i = 1,8
					local thok = P_SpawnMobj(target.x + P_RandomRange(-40, 40)*FRACUNIT, target.y + P_RandomRange(-40, 40)*FRACUNIT, target.z, MT_DUMMY)
					thok.state = S_SSPK1
					thok.momz = P_RandomRange(15, 30)*FRACUNIT
					thok.momx = P_RandomRange(-6, 6)*FRACUNIT
					thok.momy = P_RandomRange(-6, 6)*FRACUNIT
				end

			elseif timer == 60
				return true
			end
		end,
	},

	["makouga"] = {
		name = "Makouga",
		type = ATK_BLESS,
		power = 170,
		accuracy = 90,
		costtype = CST_SP,
		cost = 16,
		desc = "Medium Bless dmg to all enemies",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)

			local myears

			for k,v in ipairs(hittargets)
				local target = v
				local time = timer - 6*(k-1)

				if time >= 20 and time <= 40

					if leveltime%5 == 0
						local thok = P_SpawnMobj(target.x + P_RandomRange(-200, 200)*FRACUNIT, target.y + P_RandomRange(-200, 200)*FRACUNIT, target.z + P_RandomRange(0, 200)<<FRACBITS, MT_DUMMY)
						A_OldRingExplode(thok, MT_SUPERSPARK)
						thok.flags2 = $|MF2_DONTDRAW
						if not myears
							playSound(mo.battlen, sfx_hamas1)
						end
						myears = true

						local speeds = {FRACUNIT/16, FRACUNIT/10, FRACUNIT/3, FRACUNIT/8}
						local fuses = {20, 16, 8, 16}

						for i = 1, 2
							local l = P_SpawnMobj(thok.x, thok.y, thok.z + FRACUNIT*32, MT_THOK)	-- mt_thok for auto fadeout
							l.tics = -1
							l.sprite = SPR_CARD
							l.color = SKINCOLOR_YELLOW
							l.frame = L|(i== 2 and TR_TRANS40 or TR_TRANS70)|FF_FULLBRIGHT
							l.scale = FRACUNIT/2
							l.destscale = FRACUNIT*6
							l.scalespeed = speeds[i]
							l.fuse = fuses[i]
						end

					end

					if time == 35
						damageObject(target)
					end
					for i = 1,8
						local thok = P_SpawnMobj(target.x + P_RandomRange(-40, 40)*FRACUNIT, target.y + P_RandomRange(-40, 40)*FRACUNIT, target.z, MT_DUMMY)
						thok.state = S_SSPK1
						thok.momz = P_RandomRange(15, 30)*FRACUNIT
						thok.momx = P_RandomRange(-6, 6)*FRACUNIT
						thok.momy = P_RandomRange(-6, 6)*FRACUNIT
					end
				end
			end

			if timer == 60 + 6*(#hittargets-1)
				return true
			end
		end,
	},

	["kougaon"] = {
		name = "Kougaon",
		type = ATK_BLESS,
		power = 400,
		accuracy = 95,
		costtype = CST_SP,
		cost = 12,
		desc = "Heavy Bless dmg to one enemy.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer >= 20 and timer <= 40

				if leveltime%3 == 0
					local thok = P_SpawnMobj(target.x + P_RandomRange(-200, 200)*FRACUNIT, target.y + P_RandomRange(-200, 200)*FRACUNIT, target.z + P_RandomRange(0, 200)<<FRACBITS, MT_DUMMY)
					thok.scale = FRACUNIT*3/2
					A_OldRingExplode(thok, MT_SUPERSPARK)
					thok.flags2 = $|MF2_DONTDRAW
					playSound(mo.battlen, sfx_hamas2)

					local speeds = {FRACUNIT/16, FRACUNIT/10, FRACUNIT/3, FRACUNIT/8}
					local fuses = {20, 16, 8, 16}

					for i = 1, 2
						local l = P_SpawnMobj(thok.x, thok.y, thok.z + FRACUNIT*32, MT_THOK)	-- mt_thok for auto fadeout
						l.tics = -1
						l.sprite = SPR_CARD
						l.color = SKINCOLOR_YELLOW
						l.frame = L|(i== 2 and TR_TRANS40 or TR_TRANS70)|FF_FULLBRIGHT
						l.scale = FRACUNIT/2
						l.destscale = FRACUNIT*6
						l.scalespeed = speeds[i]
						l.fuse = fuses[i]
					end

				end

				if timer == 35
					damageObject(target)
				end
				for i = 1,8
					local thok = P_SpawnMobj(target.x + P_RandomRange(-40, 40)*FRACUNIT, target.y + P_RandomRange(-40, 40)*FRACUNIT, target.z, MT_DUMMY)
					thok.state = S_SSPK1
					thok.momz = P_RandomRange(15, 30)*FRACUNIT
					thok.momx = P_RandomRange(-6, 6)*FRACUNIT
					thok.momy = P_RandomRange(-6, 6)*FRACUNIT
				end

			elseif timer == 60
				return true
			end
		end,
	},

	["makougaon"] = {
		name = "Makougaon",
		type = ATK_BLESS,
		power = 400,
		accuracy = 90,
		costtype = CST_SP,
		cost = 24,
		desc = "Heavy Bless dmg to all enemies.",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)

			local MYFUCKINGEARS

			for k,v in ipairs(hittargets)

				local target = v
				local time = timer - 6*(k-1)

				if time >= 20 and time <= 40

					if leveltime%3 == 0
						local thok = P_SpawnMobj(target.x + P_RandomRange(-200, 200)*FRACUNIT, target.y + P_RandomRange(-200, 200)*FRACUNIT, target.z + P_RandomRange(0, 200)<<FRACBITS, MT_DUMMY)
						thok.scale = FRACUNIT*3/2
						A_OldRingExplode(thok, MT_SUPERSPARK)
						thok.flags2 = $|MF2_DONTDRAW
						if not MYFUCKINGEARS
							playSound(mo.battlen, sfx_hamas2)
						end
						MYFUCKINGEARS = true

						local speeds = {FRACUNIT/16, FRACUNIT/10, FRACUNIT/3, FRACUNIT/8}
						local fuses = {20, 16, 8, 16}

						for i = 1, 2
							local l = P_SpawnMobj(thok.x, thok.y, thok.z + FRACUNIT*32, MT_THOK)	-- mt_thok for auto fadeout
							l.tics = -1
							l.sprite = SPR_CARD
							l.color = SKINCOLOR_YELLOW
							l.frame = L|(i== 2 and TR_TRANS40 or TR_TRANS70)|FF_FULLBRIGHT
							l.scale = FRACUNIT/2
							l.destscale = FRACUNIT*6
							l.scalespeed = speeds[i]
							l.fuse = fuses[i]
						end

					end

					if time == 35
						damageObject(target)
					end
					for i = 1,8
						local thok = P_SpawnMobj(target.x + P_RandomRange(-40, 40)*FRACUNIT, target.y + P_RandomRange(-40, 40)*FRACUNIT, target.z, MT_DUMMY)
						thok.state = S_SSPK1
						thok.momz = P_RandomRange(15, 30)*FRACUNIT
						thok.momx = P_RandomRange(-6, 6)*FRACUNIT
						thok.momy = P_RandomRange(-6, 6)*FRACUNIT
					end
				end
			end

			if timer == 60 + 6*(#hittargets-1)
				return true
			end
		end,
	},

	["eiha"] = {
		name = "Eiha",
		type = ATK_CURSE,
		power = 75,
		accuracy = 95,
		costtype = CST_SP,
		cost = 4,
		desc = "Light Curse dmg to one enemy.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 25
				playSound(mo.battlen, sfx_eih4)
			end

			if timer >= 20 and timer <= 50
				for i = 1,3
					local thok = P_SpawnMobj(target.x + P_RandomRange(-40, 40)*FRACUNIT, target.y + P_RandomRange(-40, 40)*FRACUNIT, target.z, MT_DUMMY)
					thok.flags = MF_NOBLOCKMAP
					thok.color = SKINCOLOR_RED
					if timer%2 then thok.color = SKINCOLOR_BLACK end
					thok.frame = A
					thok.tics = 35
					thok.scale = FRACUNIT/2
					thok.scalespeed = FRACUNIT/32
					thok.destscale = 1
					thok.momz = P_RandomRange(5, 10)*FRACUNIT
					thok.momx = P_RandomRange(-6, 6)*FRACUNIT
					thok.momy = P_RandomRange(-6, 6)*FRACUNIT
				end
			elseif timer >= 51 and timer <= 60
				if timer == 52
					damageObject(target)
					for i = 1,16
						local thok = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
						if i%2 then thok.color = SKINCOLOR_RED else thok.color = SKINCOLOR_BLACK end
						thok.frame = A
						thok.destscale = 1
						thok.tics = 30
						thok.scalespeed = FRACUNIT/6
						thok.angle = ANGLE_22h*(i-1)
						P_InstaThrust(thok, thok.angle, 69*FRACUNIT)
					end
				end
				for i = 1,8
					local thok = P_SpawnMobj(target.x + P_RandomRange(-40, 40)*FRACUNIT, target.y + P_RandomRange(-40, 40)*FRACUNIT, target.z, MT_DUMMY)
					thok.color = SKINCOLOR_RED
					if timer%2 then thok.color = SKINCOLOR_BLACK end
					if i == 1
						thok.color = SKINCOLOR_WHITE
					end
					thok.frame = A
					thok.tics = 35
					thok.scalespeed = FRACUNIT/32
					thok.destscale = 1
					thok.momz = P_RandomRange(15, 30)*FRACUNIT
					thok.momx = P_RandomRange(-6, 6)*FRACUNIT
					thok.momy = P_RandomRange(-6, 6)*FRACUNIT
				end

			elseif timer == 90
				return true
			end
		end,
	},

	["maeiha"] = {
		name = "Maeiha",
		type = ATK_CURSE,
		power = 75,
		accuracy = 90,
		costtype = CST_SP,
		cost = 8,
		desc = "Light Curse dmg to\nall enemies",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)

			for k,v in ipairs(hittargets)
				local target = v

				local time = timer - 6*(k-1)

				if time == 25
					playSound(mo.battlen, sfx_eih4)
				end

				if time >= 20 and time <= 50
					for i = 1,3
						local thok = P_SpawnMobj(target.x + P_RandomRange(-40, 40)*FRACUNIT, target.y + P_RandomRange(-40, 40)*FRACUNIT, target.z, MT_DUMMY)
						thok.flags = MF_NOBLOCKMAP
						thok.color = SKINCOLOR_RED
						if timer%2 then thok.color = SKINCOLOR_BLACK end
						thok.frame = A
						thok.tics = 35
						thok.scale = FRACUNIT/2
						thok.scalespeed = FRACUNIT/32
						thok.destscale = 1
						thok.momz = P_RandomRange(5, 10)*FRACUNIT
						thok.momx = P_RandomRange(-6, 6)*FRACUNIT
						thok.momy = P_RandomRange(-6, 6)*FRACUNIT
					end
				elseif time >= 51 and time <= 60
					if time == 52
						damageObject(target)
						for i = 1,16
							local thok = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
							if i%2 then thok.color = SKINCOLOR_RED else thok.color = SKINCOLOR_BLACK end
							thok.frame = A
							thok.destscale = 1
							thok.tics = 30
							thok.scalespeed = FRACUNIT/6
							thok.angle = ANGLE_22h*(i-1)
							P_InstaThrust(thok, thok.angle, 69*FRACUNIT)
						end
					end
					for i = 1,8
						local thok = P_SpawnMobj(target.x + P_RandomRange(-40, 40)*FRACUNIT, target.y + P_RandomRange(-40, 40)*FRACUNIT, target.z, MT_DUMMY)
						thok.color = SKINCOLOR_RED
						if timer%2 then thok.color = SKINCOLOR_BLACK end
						if i == 1
							thok.color = SKINCOLOR_WHITE
						end
						thok.frame = A
						thok.tics = 35
						thok.scalespeed = FRACUNIT/32
						thok.destscale = 1
						thok.momz = P_RandomRange(15, 30)*FRACUNIT
						thok.momx = P_RandomRange(-6, 6)*FRACUNIT
						thok.momy = P_RandomRange(-6, 6)*FRACUNIT
					end
				end
			end

			if timer == 90 + 6*(#hittargets-1)
				return true
			end
		end,
	},

	["eiga"] = {
		name = "Eiga",
		type = ATK_CURSE,
		power = 170,
		accuracy = 95,
		costtype = CST_SP,
		cost = 8,
		desc = "Medium Curse dmg to one enemy.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 25
				playSound(mo.battlen, sfx_eih4)
			end

			if timer >= 20 and timer <= 50

				-- ghosts be coming in
				if leveltime%2
					local cam = server.P_BattleStatus[mo.battlen].cam
					local hang = cam.angle + ANG1*90
					local vang = P_RandomRange(0, 359)*ANG1

					local x = target.x + 192*FixedMul(cos(hang), cos(vang))
					local y = target.y + 192*FixedMul(sin(hang), cos(vang))
					local z = target.z + 192*FixedMul(sin(hang), sin(vang))

					local r = P_SpawnMobj(x, y, z, MT_THOK)
					r.sprite = SPR_MUDO
					r.frame = E
					r.fuse = 24
					r.tics = r.fuse
					r.rollangle = vang
					r.scale = 1
					r.destscale = FRACUNIT*2

					r.momx = (target.x - r.x)/24
					r.momy = (target.y - r.y)/24
					r.momz = (target.z+FRACUNIT*48 - r.z)/24
				end
			end

			if timer >= 30 and timer <= 70
				-- big glowing... ball !?!??

				for i = 1, 8

					local spread = (timer-30)
					local x = P_RandomRange(-spread, spread)*FRACUNIT +target.x
					local y = P_RandomRange(-spread, spread)*FRACUNIT +target.y
					local z = P_RandomRange(-spread, spread)*FRACUNIT +target.z + target.height/2

					local t = P_SpawnMobj(x, y, z, MT_THOK)
					t.fuse = t.tics
					t.color = P_RandomRange(0, 1) and SKINCOLOR_BLACK or SKINCOLOR_RED
					t.frame = A
					t.scale = FRACUNIT/4 + (spread*FRACUNIT/32)
					t.momz = -FRACUNIT/12
				end
			end

			if timer == 75
				for i = 1, 64
					local t = P_SpawnMobj(target.x, target.y, target.z, MT_THOK)
					t.tics = TICRATE
					t.fuse = TICRATE
					t.frame = A
					t.momx = P_RandomRange(-32, 32)*FRACUNIT
					t.momy = P_RandomRange(-32, 32)*FRACUNIT
					t.momz = P_RandomRange(-32, 32)*FRACUNIT
					t.color = P_RandomRange(0, 1) and SKINCOLOR_BLACK or SKINCOLOR_RED
					t.scale = FRACUNIT*3/2
				end

				damageObject(target)
			end

			if timer == 90
				return true
			end
		end,
	},

	["maeiga"] = {
		name = "Maeiga",
		type = ATK_CURSE,
		power = 170,
		accuracy = 90,
		costtype = CST_SP,
		cost = 16,
		desc = "Medium Curse dmg to all enemies.",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)

			for k,v in ipairs(hittargets)

				local target = v
				local time = timer - 6*(k-1)

				if time == 25
					playSound(mo.battlen, sfx_eih4)
				end

				if time >= 20 and time <= 50

					-- ghosts be coming in
					if leveltime%2
						local cam = server.P_BattleStatus[mo.battlen].cam
						local hang = cam.angle + ANG1*90
						local vang = P_RandomRange(0, 359)*ANG1

						local x = target.x + 192*FixedMul(cos(hang), cos(vang))
						local y = target.y + 192*FixedMul(sin(hang), cos(vang))
						local z = target.z + 192*FixedMul(sin(hang), sin(vang))

						local r = P_SpawnMobj(x, y, z, MT_THOK)
						r.sprite = SPR_MUDO
						r.frame = E
						r.fuse = 24
						r.tics = r.fuse
						r.rollangle = vang
						r.scale = 1
						r.destscale = FRACUNIT*2

						r.momx = (target.x - r.x)/24
						r.momy = (target.y - r.y)/24
						r.momz = (target.z+FRACUNIT*48 - r.z)/24
					end
				end

				if time >= 30 and time <= 70
					-- big glowing... ball !?!??

					for i = 1, 8

						local spread = (time-30)
						local x = P_RandomRange(-spread, spread)*FRACUNIT +target.x
						local y = P_RandomRange(-spread, spread)*FRACUNIT +target.y
						local z = P_RandomRange(-spread, spread)*FRACUNIT +target.z + target.height/2

						local t = P_SpawnMobj(x, y, z, MT_THOK)
						t.fuse = t.tics
						t.color = P_RandomRange(0, 1) and SKINCOLOR_BLACK or SKINCOLOR_RED
						t.frame = A
						t.scale = FRACUNIT/4 + (spread*FRACUNIT/32)
						t.momz = -FRACUNIT/12
					end
				end

				if time == 75
					for i = 1, 64
						local t = P_SpawnMobj(target.x, target.y, target.z, MT_THOK)
						t.tics = TICRATE
						t.fuse = TICRATE
						t.frame = A
						t.momx = P_RandomRange(-32, 32)*FRACUNIT
						t.momy = P_RandomRange(-32, 32)*FRACUNIT
						t.momz = P_RandomRange(-32, 32)*FRACUNIT
						t.color = P_RandomRange(0, 1) and SKINCOLOR_BLACK or SKINCOLOR_RED
						t.scale = FRACUNIT*3/2
					end

					damageObject(target)
				end
			end

			if timer == 90 + 6*(#hittargets-1)
				return true
			end
		end,
	},

	["eigaon"] = {
		name = "Eigaon",
		type = ATK_CURSE,
		power = 400,
		accuracy = 95,
		costtype = CST_SP,
		cost = 12,
		desc = "Heavy Curse dmg to one enemy.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 25
				playSound(mo.battlen, sfx_eih3)
			end

			if timer >= 20 and timer <= 50
				for i = 1,6
					local thok = P_SpawnMobj(target.x + P_RandomRange(-40, 40)*FRACUNIT, target.y + P_RandomRange(-40, 40)*FRACUNIT, target.z + P_RandomRange(30, 60)<<FRACBITS, MT_DUMMY)
					thok.flags = MF_NOBLOCKMAP
					thok.color = SKINCOLOR_RED
					if timer%2 then thok.color = SKINCOLOR_BLACK end
					thok.tics = 35
					thok.scalespeed = FRACUNIT/32
					thok.destscale = 1
					thok.momz = P_RandomRange(-3, -1)*FRACUNIT
				end
			elseif timer >= 51 and timer <= 60
				if timer == 52
					damageObject(target)
					for i = 1,16
						local thok = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
						if i%2 then thok.color = SKINCOLOR_RED else thok.color = SKINCOLOR_BLACK end
						thok.frame = A
						thok.scale = FRACUNIT*2
						thok.destscale = 1
						thok.tics = 30
						thok.scalespeed = FRACUNIT/6
						thok.angle = ANGLE_22h*(i-1)
						P_InstaThrust(thok, thok.angle, 69*FRACUNIT)
					end
				end

				if leveltime%4 == 0
					local t = P_SpawnMobj(target.x, target.y, target.z, MT_THOK)
					t.fuse = TICRATE/2
					t.sprite = SPR_MUDO
					t.tics = -1
					t.frame = C|TR_TRANS10
					t.color = leveltime%8 == 0 and SKINCOLOR_WHITE or SKINCOLOR_BLACK
					t.scale = FRACUNIT/3
					t.destscale = FRACUNIT*3
					t.scalespeed = FRACUNIT/6
				end

				if leveltime%5 == 0
					local caman = R_PointToAngle(target.x, target.y)

					local t = P_SpawnMobj(target.x + 2*cos(caman), target.y + 2*cos(caman), target.z, MT_THOK)
					t.fuse = TICRATE/2
					t.sprite = SPR_MUDO
					t.tics = -1
					t.frame = D|TR_TRANS10
					t.color = SKINCOLOR_CRIMSON
					t.scale = FRACUNIT/3
					t.destscale = FRACUNIT*3
					t.scalespeed = FRACUNIT/4
				end


				for i = 1,8
					local thok = P_SpawnMobj(target.x + P_RandomRange(-40, 40)*FRACUNIT, target.y + P_RandomRange(-40, 40)*FRACUNIT, target.z, MT_DUMMY)
					thok.color = SKINCOLOR_RED
					if timer%2 then thok.color = SKINCOLOR_BLACK end
					if i == 1
						thok.color = SKINCOLOR_WHITE
					end
					thok.scale = FRACUNIT*2
					thok.frame = A
					thok.tics = 35
					thok.scalespeed = FRACUNIT/32
					thok.destscale = 1
					thok.momz = P_RandomRange(20, 35)*FRACUNIT
				end

			elseif timer == 90
				return true
			end
		end,
	},

	["eggion"] = {
		name = "Eggion",
		type = ATK_CURSE,
		power = 500,
		accuracy = 95,
		costtype = CST_SP,
		cost = 12,
		desc = "Mega Curse dmg to one sammt",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 25
				playSound(mo.battlen, sfx_eih3)
			end

			if timer >= 20 and timer <= 50
				for i = 1,6
					local thok = P_SpawnMobj(target.x + P_RandomRange(-40, 40)*FRACUNIT, target.y + P_RandomRange(-40, 40)*FRACUNIT, target.z + P_RandomRange(30, 60)<<FRACBITS, MT_DUMMY)
					thok.flags = MF_NOBLOCKMAP
					thok.color = SKINCOLOR_RED
					if timer%2 then thok.color = SKINCOLOR_BLACK end
					thok.tics = 35
					thok.scalespeed = FRACUNIT/32
					thok.destscale = 1
					thok.momz = P_RandomRange(-3, -1)*FRACUNIT
				end
			elseif timer >= 51 and timer <= 60
				if timer == 52
					damageObject(target)
					for i = 1,16
						local thok = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
						if i%2 then thok.color = SKINCOLOR_RED else thok.color = SKINCOLOR_BLACK end
						thok.frame = A
						thok.scale = FRACUNIT*2
						thok.destscale = 1
						thok.tics = 30
						thok.scalespeed = FRACUNIT/6
						thok.angle = ANGLE_22h*(i-1)
						P_InstaThrust(thok, thok.angle, 69*FRACUNIT)
					end
				end
				for i = 1,8
					local thok = P_SpawnMobj(target.x + P_RandomRange(-40, 40)*FRACUNIT, target.y + P_RandomRange(-40, 40)*FRACUNIT, target.z, MT_DUMMY)
					thok.color = SKINCOLOR_RED
					if timer%2 then thok.color = SKINCOLOR_BLACK end
					if i == 1
						thok.color = SKINCOLOR_WHITE
					end
					thok.scale = FRACUNIT*2
					thok.frame = A
					thok.tics = 35
					thok.scalespeed = FRACUNIT/32
					thok.destscale = 1
					thok.momz = P_RandomRange(20, 35)*FRACUNIT
				end

			elseif timer == 90
				return true
			end
		end,
	},

	["maeigaon"] = {
		name = "Maeigaon",
		type = ATK_CURSE,
		power = 400,
		accuracy = 90,
		costtype = CST_SP,
		cost = 24,
		desc = "Heavy Curse dmg to all enemies",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)

			for k,v in ipairs(hittargets)

				local target = v
				local time = timer - 6*(k-1)

				if time == 25
					playSound(mo.battlen, sfx_eih3)
				end

				if time >= 20 and time <= 50
					for i = 1,6
						local thok = P_SpawnMobj(target.x + P_RandomRange(-40, 40)*FRACUNIT, target.y + P_RandomRange(-40, 40)*FRACUNIT, target.z + P_RandomRange(30, 60)<<FRACBITS, MT_DUMMY)
						thok.flags = MF_NOBLOCKMAP
						thok.color = SKINCOLOR_RED
						if timer%2 then thok.color = SKINCOLOR_BLACK end
						thok.tics = 35
						thok.scalespeed = FRACUNIT/32
						thok.destscale = 1
						thok.momz = P_RandomRange(-3, -1)*FRACUNIT
					end
				elseif time >= 51 and time <= 60
					if time == 52
						damageObject(target)
						for i = 1,16
							local thok = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
							if i%2 then thok.color = SKINCOLOR_RED else thok.color = SKINCOLOR_BLACK end
							thok.frame = A
							thok.scale = FRACUNIT*2
							thok.destscale = 1
							thok.tics = 30
							thok.scalespeed = FRACUNIT/6
							thok.angle = ANGLE_22h*(i-1)
							P_InstaThrust(thok, thok.angle, 69*FRACUNIT)
						end
					end

					if leveltime%4 == 0
						local t = P_SpawnMobj(target.x, target.y, target.z, MT_THOK)
						t.fuse = TICRATE/2
						t.sprite = SPR_MUDO
						t.tics = -1
						t.frame = C|TR_TRANS10
						t.color = leveltime%8 == 0 and SKINCOLOR_WHITE or SKINCOLOR_BLACK
						t.scale = FRACUNIT/3
						t.destscale = FRACUNIT*3
						t.scalespeed = FRACUNIT/6
					end

					if leveltime%5 == 0
						local caman = R_PointToAngle(target.x, target.y)

						local t = P_SpawnMobj(target.x + 2*cos(caman), target.y + 2*cos(caman), target.z, MT_THOK)
						t.fuse = TICRATE/2
						t.sprite = SPR_MUDO
						t.tics = -1
						t.frame = D|TR_TRANS10
						t.color = SKINCOLOR_CRIMSON
						t.scale = FRACUNIT/3
						t.destscale = FRACUNIT*3
						t.scalespeed = FRACUNIT/4
					end


					for i = 1,8
						local thok = P_SpawnMobj(target.x + P_RandomRange(-40, 40)*FRACUNIT, target.y + P_RandomRange(-40, 40)*FRACUNIT, target.z, MT_DUMMY)
						thok.color = SKINCOLOR_RED
						if timer%2 then thok.color = SKINCOLOR_BLACK end
						if i == 1
							thok.color = SKINCOLOR_WHITE
						end
						thok.scale = FRACUNIT*2
						thok.frame = A
						thok.tics = 35
						thok.scalespeed = FRACUNIT/32
						thok.destscale = 1
						thok.momz = P_RandomRange(20, 35)*FRACUNIT
					end
				end
			end

			if timer == 90 + 6*(#hittargets-1)
				return true
			end
		end,
	},

	["atomic flare"] = {
		name = "Atomic Flare",
		type = ATK_NUCLEAR,
		power = 650,
		accuracy = 95,
		costtype = CST_SP,
		cost = 24,
		technical = COND_BURN|COND_FREEZE|COND_SHOCK,
		desc = "Severe Nuke dmg to one enemy.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 20

				local s = P_SpawnMobj(target.x, target.y, target.z + mo.scale*64, MT_DUMMY)
				s.color = SKINCOLOR_WHITE
				s.state = S_MEGISTAR1
				s.scale = FRACUNIT*4
				playSound(mo.battlen, sfx_hamas2)

			elseif timer == 40
				localquake(mo.battlen, FRACUNIT*32, 100)
				playSound(mo.battlen, sfx_frei1)

			elseif timer > 40
			and timer < 130

				if leveltime & 1
					for i = 1, 2

						local s = P_SpawnMobj(target.x, target.y, target.z + mo.scale*64, MT_DUMMY)
						if i == 1
							s.z = $ - mo.scale*64
						else
							s.z = $ + mo.scale*128
						end

						s.sprite = SPR_SLAS
						s.frame = K+(i-1) | FF_FULLBRIGHT | TR_TRANS30
						s.color = SKINCOLOR_TEAL
						s.scale = FRACUNIT/8
						s.destscale = FRACUNIT*9
						s.scalespeed = FRACUNIT/2
						s.tics = TICRATE/2

						s.momx = P_RandomRange(-2, 2)*FRACUNIT
						s.momy = P_RandomRange(-2, 2)*FRACUNIT
						s.momz = P_RandomRange(-2, 2)*FRACUNIT

					end
				end

				local ang = R_PointToAngle(target.x, target.y)
				local angs = {ang + ANG1*120, ang - ANG1*60}
				local momzs = {-1, 1}

				for i = 1, 2
					for j = 1, 16

						local boom = P_SpawnMobj(target.x, target.y, target.z + 64*mo.scale, MT_DUMMY)
						boom.state = S_CQUICKBOOM1
						boom.color = SKINCOLOR_TEAL
						boom.angle = angs[i]
						P_InstaThrust(boom, boom.angle, P_RandomRange(16, 64)*FRACUNIT)
						boom.momz = P_RandomRange(6, 16)*momzs[i]*FRACUNIT
						boom.scale = FRACUNIT*3/2
					end
				end
			end

			if timer == 110
				damageObject(target)
			elseif timer == 140
				return true
			end
		end,
	},

	["freidyne"] = {
		name = "Freidyne",
		type = ATK_NUCLEAR,
		power = 350,
		accuracy = 95,
		costtype = CST_SP,
		cost = 12,
		technical = COND_BURN|COND_FREEZE|COND_SHOCK,
		desc = "Heavy Nuke dmg to one enemy.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 15
			or timer == 25
			or timer == 35
				local bx = target.x + P_RandomRange(-192, 192)*FRACUNIT
				local by = target.y + P_RandomRange(-129, 192)*FRACUNIT
				local bz = target.z + P_RandomRange(0, 256)*FRACUNIT

				for i = 1, 32
					local boom = P_SpawnMobj(bx + P_RandomRange(-20, 20)*FRACUNIT, by + P_RandomRange(-20, 20)*FRACUNIT, bz + 10*FRACUNIT, MT_DUMMY)
					boom.state = S_CQUICKBOOM1
					boom.color = SKINCOLOR_TEAL
					boom.momx = P_RandomRange(-20, 20)*FRACUNIT
					boom.momy = P_RandomRange(-20, 20)*FRACUNIT
					boom.momz = P_RandomRange(-20, 20)*FRACUNIT
					boom.scale = FRACUNIT*3/2
				end
				local sm = P_SpawnMobj(bx, by, bz, MT_SMOLDERING)
				sm.fuse = TICRATE

				playSound(mo.battlen, sfx_megi6)
				localquake(mo.battlen, FRACUNIT*32, 10)

			elseif timer >= 50
			and timer <= 90

				if timer == 50
					target.nukethrust = {}
					playSound(mo.battlen, sfx_megi4)
				end

				local an = leveltime%360*2
				if not (leveltime%2) and timer < 122
					for i = 1, 32
						local x = target.x + 192*cos(an*ANG1)
						local y = target.y + 192*sin(an*ANG1)
						local nuke = P_SpawnMobj(x, y, target.z, MT_DUMMY)
						nuke.flags = MF_NOGRAVITY|MF_NOCLIP
						target.nukethrust[#target.nukethrust+1] = nuke
						nuke.state = S_CQUICKBOOM1
						nuke.color = SKINCOLOR_TEAL
						nuke.angle = an*ANG1
						nuke.momz = P_RandomRange(4, 6)*FRACUNIT
						P_InstaThrust(nuke, nuke.angle, 40*FRACUNIT)
						an = $ + 360/32
					end
				end

				for i = 1, #target.nukethrust
					local nuke = target.nukethrust[i]
					if not nuke or not nuke.valid continue end
					P_Thrust(nuke, nuke.angle, -FRACUNIT*8)
				end

			elseif timer >= 92
			and timer <= 150

				target.nukethrust = nil

				if timer == 95
					damageObject(target)
					localquake(mo.battlen, FRACUNIT*64, TICRATE)
					playSound(mo.battlen, sfx_megi5)

					local sm = P_SpawnMobj(target.x, target.y, target.z, MT_SMOLDERING)
					sm.fuse = TICRATE*3
					sm.scale = FRACUNIT*3

				elseif timer == 150
					return true
				end

				for i = 1, 12
					local boom = P_SpawnMobj(target.x + P_RandomRange(-96, 96)*FRACUNIT, target.y + P_RandomRange(-96, 96)*FRACUNIT, target.z, MT_DUMMY)
					boom.state = S_CQUICKBOOM1
					boom.color = SKINCOLOR_TEAL
					boom.momz = P_RandomRange(0, 48)*FRACUNIT
					boom.scale = FRACUNIT*3/2
				end
			end
		end,
	},

	["mafreidyne"] = {
		name = "Mafreidyne",
		type = ATK_NUCLEAR,
		power = 350,
		accuracy = 90,
		costtype = CST_SP,
		cost = 24,
		technical = COND_BURN|COND_FREEZE|COND_SHOCK,
		desc = "Heavy Nuke dmg to all enemies.",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)

			for k,v in ipairs(hittargets)

				local target = v
				local time = timer - 6*(k-1)

				if time == 15
				or time == 25
				or time == 35
					local bx = target.x + P_RandomRange(-192, 192)*FRACUNIT
					local by = target.y + P_RandomRange(-129, 192)*FRACUNIT
					local bz = target.z + P_RandomRange(0, 256)*FRACUNIT

					for i = 1, 32
						local boom = P_SpawnMobj(bx + P_RandomRange(-20, 20)*FRACUNIT, by + P_RandomRange(-20, 20)*FRACUNIT, bz + 10*FRACUNIT, MT_DUMMY)
						boom.state = S_CQUICKBOOM1
						boom.color = SKINCOLOR_TEAL
						boom.momx = P_RandomRange(-20, 20)*FRACUNIT
						boom.momy = P_RandomRange(-20, 20)*FRACUNIT
						boom.momz = P_RandomRange(-20, 20)*FRACUNIT
						boom.scale = FRACUNIT*3/2
					end
					playSound(mo.battlen, sfx_megi6)
					localquake(mo.battlen, FRACUNIT*32, 10)

				elseif time >= 50
				and time <= 90

					if time == 50
						target.nukethrust = {}
						playSound(mo.battlen, sfx_megi4)
					end

					local an = leveltime%360*2
					if not (leveltime%2) and time < 122
						for i = 1, 32
							local x = target.x + 192*cos(an*ANG1)
							local y = target.y + 192*sin(an*ANG1)
							local nuke = P_SpawnMobj(x, y, target.z, MT_DUMMY)
							nuke.flags = MF_NOGRAVITY|MF_NOCLIP
							target.nukethrust[#target.nukethrust+1] = nuke
							nuke.state = S_CQUICKBOOM1
							nuke.color = SKINCOLOR_TEAL
							nuke.angle = an*ANG1
							nuke.momz = P_RandomRange(4, 6)*FRACUNIT
							P_InstaThrust(nuke, nuke.angle, 40*FRACUNIT)
							an = $ + 360/32
						end
					end

					for i = 1, #target.nukethrust
						local nuke = target.nukethrust[i]
						if not nuke or not nuke.valid continue end
						P_Thrust(nuke, nuke.angle, -FRACUNIT*8)
					end

				elseif time >= 92
				and time <= 150

					target.nukethrust = nil

					if time == 95
						damageObject(target)
						localquake(mo.battlen, FRACUNIT*64, 10)
						playSound(mo.battlen, sfx_megi5)

						local sm = P_SpawnMobj(target.x, target.y, target.z, MT_SMOLDERING)
						sm.fuse = TICRATE*3
						sm.scale = FRACUNIT*3

					elseif timer == 150 + (#hittargets-1)*6
						return true
					end

					for i = 1, 12
						local boom = P_SpawnMobj(target.x + P_RandomRange(-96, 96)*FRACUNIT, target.y + P_RandomRange(-96, 96)*FRACUNIT, target.z, MT_DUMMY)
						boom.state = S_CQUICKBOOM1
						boom.color = SKINCOLOR_TEAL
						boom.momz = P_RandomRange(0, 48)*FRACUNIT
						boom.scale = FRACUNIT*3/2
					end
				end
			end
		end,
	},

	["freila"] = {
		name = "Freila",
		type = ATK_NUCLEAR,
		power = 140,
		accuracy = 95,
		costtype = CST_SP,
		cost = 8,
		technical = COND_BURN|COND_FREEZE|COND_SHOCK,
		desc = "Medium Nuke dmg to one enemy.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 20
				playSound(mo.battlen, sfx_debuff)
				--local x, y = target.x + 20*cos(target.angle), target.y + 20*sin(target.angle)
				local x,y = target.x + P_RandomRange(-128, 128)<<FRACBITS, target.y + P_RandomRange(-128, 128)<<FRACBITS
				target.frei = P_SpawnMobj(x, y, target.z+FRACUNIT*256, MT_DUMMY)
				target.frei.state = S_PLAY_STND
				target.frei.dispoffset = 5
				target.frei.tics = -1
				target.frei.fuse = 60
				target.frei.sprite = SPR_FREI
				target.frei.frame = G|TR_TRANS20|FF_FULLBRIGHT
				target.frei.scale = FRACUNIT/20
				target.frei.color = SKINCOLOR_TEAL
				target.frei.target = target
				target.frei.flags = MF_NOGRAVITY

			elseif timer > 20 and timer <= 50
				target.frei.scale = min(2*FRACUNIT, $+ FRACUNIT/12)
				local f = target.frei

				f.momx = (target.x-f.x)/20
				f.momy = (target.y-f.y)/20
				f.momz = (target.z-f.z)/20

				--A_HomingChase(target.frei, 6*FRACUNIT)

					-- spawn cool explosions on the way down
				local boom = P_SpawnMobj(target.frei.x + P_RandomRange(-20, 20)*FRACUNIT, target.frei.y + P_RandomRange(-20, 20)*FRACUNIT, target.frei.z + 10*FRACUNIT, MT_DUMMY)
				boom.state = S_CQUICKBOOM1
				boom.color = SKINCOLOR_TEAL
				boom.momx = P_RandomRange(-8, 8)*FRACUNIT
				boom.momy = P_RandomRange(-8, 8)*FRACUNIT
				boom.momz = P_RandomRange(-8, 8)*FRACUNIT
				boom.scale = FRACUNIT

				P_SpawnMobj(target.frei.x + P_RandomRange(-20, 20)*FRACUNIT, target.frei.y + P_RandomRange(-20, 20)*FRACUNIT, target.frei.z + 10*FRACUNIT, MT_SMOKE)
				boom.momx = P_RandomRange(-8, 8)*FRACUNIT
				boom.momy = P_RandomRange(-8, 8)*FRACUNIT
				boom.momz = P_RandomRange(-8, 8)*FRACUNIT
				boom.scale = FRACUNIT

				if timer%2
					target.frei.flags2 = $|MF2_DONTDRAW
				else
					target.frei.flags2 = $ & ~ MF2_DONTDRAW
				end



			elseif timer == 51
			or timer == 61
			or timer == 71
				target.frei.flags2 = $|MF2_DONTDRAW
				if timer == 71
					damageObject(target)
					target.frei.fuse = 1
					target.frei = nil
					local sm = P_SpawnMobj(target.x, target.y, target.z, MT_SMOLDERING)
					sm.fuse = TICRATE*2
					sm.scale = FRACUNIT*3/2
				end

				local bx = target.x + P_RandomRange(-192, 192)*FRACUNIT
				local by = target.y + P_RandomRange(-129, 192)*FRACUNIT
				local bz = target.z + P_RandomRange(0, 256)*FRACUNIT

				for i = 1, 32
					local boom = P_SpawnMobj(bx + P_RandomRange(-20, 20)*FRACUNIT, by + P_RandomRange(-20, 20)*FRACUNIT, bz + 10*FRACUNIT, MT_DUMMY)
					boom.state = S_CQUICKBOOM1
					boom.color = SKINCOLOR_TEAL
					boom.momx = P_RandomRange(-20, 20)*FRACUNIT
					boom.momy = P_RandomRange(-20, 20)*FRACUNIT
					boom.momz = P_RandomRange(-20, 20)*FRACUNIT
					boom.scale = FRACUNIT*3/2
				end

				local sm = P_SpawnMobj(bx, by, bz, MT_SMOLDERING)
				sm.fuse = TICRATE

				playSound(mo.battlen, sfx_megi6)
				localquake(mo.battlen, FRACUNIT*24, 10)

			elseif timer == 110
				return true
			end
		end,
	},

	["mafreila"] = {
		name = "Mafreila",
		type = ATK_NUCLEAR,
		power = 140,
		accuracy = 90,
		costtype = CST_SP,
		cost = 16,
		technical = COND_BURN|COND_FREEZE|COND_SHOCK,
		desc = "Medium Nuke dmg to all enemies.",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)

			for k,v in ipairs(hittargets)

				local target = v
				local time = timer - (k-1)*6

				if time == 20
					playSound(mo.battlen, sfx_debuff)
					--local x, y = target.x + 20*cos(target.angle), target.y + 20*sin(target.angle)
					local x,y = target.x + P_RandomRange(-128, 128)<<FRACBITS, target.y + P_RandomRange(-128, 128)<<FRACBITS
					target.frei = P_SpawnMobj(x, y, target.z+FRACUNIT*256, MT_DUMMY)
					target.frei.tics = -1
					target.frei.dispoffset = 5
					target.frei.tics = -1
					target.frei.fuse = 60
					target.frei.sprite = SPR_FREI
					target.frei.frame = G|TR_TRANS20|FF_FULLBRIGHT
					target.frei.scale = FRACUNIT/20
					target.frei.color = SKINCOLOR_TEAL
					target.frei.target = target
					target.frei.flags = MF_NOGRAVITY

				elseif time > 20 and time <= 50
					target.frei.scale = min(2*FRACUNIT, $+ FRACUNIT/12)
					local f = target.frei

					f.momx = (target.x-f.x)/20
					f.momy = (target.y-f.y)/20
					f.momz = (target.z-f.z)/20

					--A_HomingChase(target.frei, 6*FRACUNIT)

						-- spawn cool explosions on the way down
					local boom = P_SpawnMobj(target.frei.x + P_RandomRange(-20, 20)*FRACUNIT, target.frei.y + P_RandomRange(-20, 20)*FRACUNIT, target.frei.z + 10*FRACUNIT, MT_DUMMY)
					boom.state = S_CQUICKBOOM1
					boom.color = SKINCOLOR_TEAL
					boom.momx = P_RandomRange(-8, 8)*FRACUNIT
					boom.momy = P_RandomRange(-8, 8)*FRACUNIT
					boom.momz = P_RandomRange(-8, 8)*FRACUNIT
					boom.scale = FRACUNIT

					local boom = P_SpawnMobj(target.frei.x + P_RandomRange(-20, 20)*FRACUNIT, target.frei.y + P_RandomRange(-20, 20)*FRACUNIT, target.frei.z + 10*FRACUNIT, MT_SMOKE)
					boom.momx = P_RandomRange(-8, 8)*FRACUNIT
					boom.momy = P_RandomRange(-8, 8)*FRACUNIT
					boom.momz = P_RandomRange(-8, 8)*FRACUNIT
					boom.scale = FRACUNIT

					if time%2
						target.frei.flags2 = $|MF2_DONTDRAW
					else
						target.frei.flags2 = $ & ~ MF2_DONTDRAW
					end



				elseif time == 51
				or time == 61
				or time == 71
					target.frei.flags2 = $|MF2_DONTDRAW
					if time == 71

						local sm = P_SpawnMobj(target.x, target.y, target.z, MT_SMOLDERING)
						sm.fuse = TICRATE*2
						sm.scale = FRACUNIT*3/2

						damageObject(target)
						target.frei.fuse = 1
						target.frei = nil
					end

					local bx = target.x + P_RandomRange(-192, 192)*FRACUNIT
					local by = target.y + P_RandomRange(-129, 192)*FRACUNIT
					local bz = target.z + P_RandomRange(0, 256)*FRACUNIT

					for i = 1, 32
						local boom = P_SpawnMobj(bx + P_RandomRange(-20, 20)*FRACUNIT, by + P_RandomRange(-20, 20)*FRACUNIT, bz + 10*FRACUNIT, MT_DUMMY)
						boom.state = S_CQUICKBOOM1
						boom.color = SKINCOLOR_TEAL
						boom.momx = P_RandomRange(-20, 20)*FRACUNIT
						boom.momy = P_RandomRange(-20, 20)*FRACUNIT
						boom.momz = P_RandomRange(-20, 20)*FRACUNIT
						boom.scale = FRACUNIT*3/2
					end
					playSound(mo.battlen, sfx_megi6)
					localquake(mo.battlen, FRACUNIT*24, 10)
				end
			end

			if timer == 110 + (#hittargets-1)*6
				return true
			end
		end,
	},

	["frei"] = {
		name = "Frei",
		type = ATK_NUCLEAR,
		power = 60,
		accuracy = 95,
		costtype = CST_SP,
		cost = 4,
		technical = COND_BURN|COND_FREEZE|COND_SHOCK,
		desc = "Light Nuke dmg to one enemy.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 20
				playSound(mo.battlen, sfx_debuff)
				--local x, y = target.x + 20*cos(target.angle), target.y + 20*sin(target.angle)
				local x,y = target.x, target.y
				local frei = P_SpawnMobj(x, y, target.z+FRACUNIT*10, MT_DUMMY)
				frei.state = S_PLAY_STND
				frei.dispoffset = 5
				frei.tics = -1
				frei.fuse = 60
				frei.sprite = SPR_FREI
				frei.frame = G|TR_TRANS20|FF_FULLBRIGHT
				frei.scale = FRACUNIT/20
				frei.color = SKINCOLOR_TEAL
				mo.frei = frei

			elseif timer > 20 and timer <= 50
				mo.frei.scale = min(2*FRACUNIT, $+ FRACUNIT/12)
				if timer%2
					mo.frei.flags2 = $|MF2_DONTDRAW
				else
					mo.frei.flags2 = $ & ~ MF2_DONTDRAW
				end
				if not (timer%4)
					local x, y = target.x + 20*cos(target.angle), target.y + 20*sin(target.angle)
					x, y = target.x, target.y
					local frei = P_SpawnMobj(x, y, target.z+FRACUNIT*10, MT_DUMMY)
					frei.dispoffset = 5
					frei.state = S_FREI1
					frei.scale = FRACUNIT*5/2
					if not (timer%8) then frei.state = S_FREI4 end
				end
			elseif timer == 51

				local sm = P_SpawnMobj(target.x, target.y, target.z, MT_SMOLDERING)
				sm.fuse = TICRATE*2
				sm.scale = FRACUNIT*3/2

				damageObject(target)
				mo.frei.fuse = 1
				for i = 1, 16
					local boom = P_SpawnMobj(target.x + P_RandomRange(-20, 20)*FRACUNIT, target.y + P_RandomRange(-20, 20)*FRACUNIT, target.z + 10*FRACUNIT, MT_DUMMY)
					boom.state = S_CQUICKBOOM1
					boom.color = SKINCOLOR_TEAL
					boom.momx = P_RandomRange(-20, 20)*FRACUNIT
					boom.momy = P_RandomRange(-20, 20)*FRACUNIT
					boom.momz = P_RandomRange(-20, 20)*FRACUNIT
					boom.scale = FRACUNIT*3/2
				end
				playSound(mo.battlen, sfx_megi6)
				localquake(mo.battlen, FRACUNIT*16, 10)
				mo.frei = nil
			elseif timer == 90
				return true
			end
		end,
	},

	["mafrei"] = {
		name = "Mafrei",
		type = ATK_NUCLEAR,
		power = 60,
		accuracy = 90,
		costtype = CST_SP,
		cost = 8,
		technical = COND_BURN|COND_FREEZE|COND_SHOCK,
		desc = "Light Nuke dmg all enemies",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)

			for k,v in ipairs(hittargets)
				local target = v
				local time = timer - (k-1)*6

				if time == 20
					playSound(mo.battlen, sfx_debuff)
					--local x, y = target.x + 20*cos(target.angle), target.y + 20*sin(target.angle)
					local x,y = target.x, target.y
					local frei = P_SpawnMobj(x, y, target.z+FRACUNIT*10, MT_DUMMY)
					frei.state = S_PLAY_STND
					frei.dispoffset = 5
					frei.tics = -1
					frei.fuse = 60
					frei.sprite = SPR_FREI
					frei.frame = G|TR_TRANS20|FF_FULLBRIGHT
					frei.scale = FRACUNIT/20
					frei.color = SKINCOLOR_TEAL
					v.frei = frei

				elseif time > 20 and time <= 50
					v.frei.scale = min(2*FRACUNIT, $+ FRACUNIT/12)
					if time%2
						v.frei.flags2 = $|MF2_DONTDRAW
					else
						v.frei.flags2 = $ & ~ MF2_DONTDRAW
					end
					if not (time%4)
						local x, y = target.x + 20*cos(target.angle), target.y + 20*sin(target.angle)
						x, y = target.x, target.y
						local frei = P_SpawnMobj(x, y, target.z+FRACUNIT*10, MT_DUMMY)
						frei.dispoffset = 5
						frei.state = S_FREI1
						frei.scale = FRACUNIT*5/2
						if not (timer%8) then frei.state = S_FREI4 end
					end
				elseif time == 51

					local sm = P_SpawnMobj(target.x, target.y, target.z, MT_SMOLDERING)
					sm.fuse = TICRATE*2
					sm.scale = FRACUNIT*3/2

					damageObject(target)
					v.frei.fuse = 1
					for i = 1, 16
						local boom = P_SpawnMobj(target.x + P_RandomRange(-20, 20)*FRACUNIT, target.y + P_RandomRange(-20, 20)*FRACUNIT, target.z + 10*FRACUNIT, MT_DUMMY)
						boom.state = S_CQUICKBOOM1
						boom.color = SKINCOLOR_TEAL
						boom.momx = P_RandomRange(-20, 20)*FRACUNIT
						boom.momy = P_RandomRange(-20, 20)*FRACUNIT
						boom.momz = P_RandomRange(-20, 20)*FRACUNIT
						boom.scale = FRACUNIT*3/2
					end
					playSound(mo.battlen, sfx_megi6)
					localquake(mo.battlen, FRACUNIT*16, 10)
					v.frei = nil
				end
			end

			if timer == 90 + (#hittargets-1)*6
				return true
			end
		end,
	},

	["garuverse"] = {
		name = "Garuverse",
		type = ATK_WIND,
		power = 100,
		accuracy = 999,
		costtype = CST_SP,
		cost = 12,
		desc = "Light Wind dmg to all enemies.\nDeploys a field that heals 50%\nof damage dealt for 3 turns.",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)

			for k,e in ipairs(hittargets)
			local target = e
			local time = timer - 5*(k-1)

				if time == 20
					playSound(mo.battlen, sfx_wind2)
					for i = 1, 10
						local g = P_SpawnMobj(target.x, target.y, target.z + P_RandomRange(0, 120)*FRACUNIT, MT_GARU)
						g.target = target
						g.angle = FixedAngle(P_RandomRange(1, 360)*FRACUNIT)
						if i == 1 or i == 8
							g.jizzcolor = true
						end
						if i%2
							g.invertrotation = true
						end
						g.dist = P_RandomRange(45, 140)
						g.tics = 25
						g.lowquality = true
					end

				elseif time == 30
				or time == 33
				or time == 36
				or time == 39
					local s = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					s.scale = FRACUNIT/4
					s.sprite = SPR_SLAS
					s.frame = I|TR_TRANS50 + P_RandomRange(0, 3)
					s.destscale = FRACUNIT*9
					s.scalespeed = FRACUNIT
					s.tics = TICRATE/3

				elseif time == 40
					damageObject(target)
					if target.damagestate ~= DMG_MISS
					and target.damagestate ~= DMG_BLOCK
					and target.damagestate ~= DMG_DRAIN
						startField(target, FLD_GARUVERSE, 4)
					end
				end
			end
			if timer == 75 + 5*(#hittargets-1)
				return true
			end
		end,
	},

	["garudyne"] = {
		name = "Garudyne",
		type = ATK_WIND,
		power = 350,
		accuracy = 95,
		costtype = CST_SP,
		cost = 9,
		desc = "Heavy Wind dmg to one enemy.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer > 20
			and timer < 50
			and leveltime%5 == 0
				local s = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
				s.scale = FRACUNIT/4
				s.sprite = SPR_SLAS
				s.frame = I|TR_TRANS50 + P_RandomRange(0, 3)
				s.destscale = FRACUNIT*9
				s.scalespeed = FRACUNIT
				s.tics = TICRATE/3
			end

			if timer == 20
				playSound(mo.battlen, sfx_wind3)
				local barrier = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
				target.elec = barrier
				barrier.scale = FRACUNIT*2
				barrier.state = S_PLAY_STND
				barrier.tics = -1
				barrier.sprite = SPR_ELEC
				barrier.fuse = 40
				local g = P_SpawnGhostMobj(barrier)
				g.destscale = FRACUNIT*4

				for i = 1, 12
					local g = P_SpawnMobj(target.x, target.y, target.z + P_RandomRange(0, 120)*FRACUNIT, MT_GARU)
					g.target = target
					g.angle = FixedAngle(P_RandomRange(1, 360)*FRACUNIT)
					if i == 1 or i == 8
						g.jizzcolor = true
					end
					if i%2
						g.invertrotation = true
					end
					g.dist = P_RandomRange(45, 140)
					g.tics = 35
				end
			elseif timer == 55
				damageObject(target)
				localquake(mo.battlen, FRACUNIT*8, 8)
				for i = 1, 32
					local g = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					g.scale = FRACUNIT/2
					g.destscale = 1
					g.color = SKINCOLOR_EMERALD
					g.frame = A
					if i%2 then g.color = SKINCOLOR_WHITE end
					g.momx = P_RandomRange(-15, 15)*FRACUNIT
					g.momy = P_RandomRange(-15, 15)*FRACUNIT
					g.momz = P_RandomRange(-15, 15)*FRACUNIT
				end
			elseif timer == 85
				target.elec = nil
				return true
			end

			if target.elec
			and target.elec.valid
			and not (leveltime%2)
				target.elec.frame = P_RandomRange(A, L)
			end
		end,
	},

	["garula"] = {
		name = "Garula",
		type = ATK_WIND,
		power = 140,
		accuracy = 95,
		costtype = CST_SP,
		cost = 6,
		desc = "Medium Wind dmg to one enemy.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 20
				playSound(mo.battlen, sfx_wind2)
				for i = 1, 12
					local g = P_SpawnMobj(target.x, target.y, target.z + P_RandomRange(0, 120)*FRACUNIT, MT_GARU)
					g.target = target
					g.angle = FixedAngle(P_RandomRange(1, 360)*FRACUNIT)
					if i == 1 or i == 8
						g.jizzcolor = true
					end
					if i%2
						g.invertrotation = true
					end
					g.dist = P_RandomRange(45, 140)
					g.tics = 25
				end

			elseif timer == 30
			or timer == 33
			or timer == 36
			or timer == 39
				local s = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
				s.scale = FRACUNIT/4
				s.sprite = SPR_SLAS
				s.frame = I|TR_TRANS50 + P_RandomRange(0, 3)
				s.destscale = FRACUNIT*9
				s.scalespeed = FRACUNIT
				s.tics = TICRATE/3

			elseif timer == 40
				damageObject(target)
				for i = 1, 32
					local g = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					g.scale = FRACUNIT/2
					g.destscale = 1
					g.color = SKINCOLOR_EMERALD
					g.frame = A
					if i%2 then g.color = SKINCOLOR_WHITE end
					g.momx = P_RandomRange(-15, 15)*FRACUNIT
					g.momy = P_RandomRange(-15, 15)*FRACUNIT
					g.momz = P_RandomRange(-15, 15)*FRACUNIT
				end
			elseif timer == 75
				return true
			end
		end,
	},

	["megagarula"] = {
		name = "Megagarula",
		type = ATK_WIND,
		power = 500,
		accuracy = 90,
		costtype = CST_SP,
		cost = 32,
		desc = "Mega Wind dmg to all sammts.",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)

			for k,e in ipairs(hittargets)
			local target = e
			local time = timer - 5*(k-1)

				if time == 20
					playSound(mo.battlen, sfx_wind3)
					local barrier = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					target.elec = barrier
					barrier.scale = FRACUNIT*2
					barrier.state = S_PLAY_STND
					barrier.tics = -1
					barrier.sprite = SPR_ELEC
					barrier.fuse = 40
					for i = 1, 10
						local g = P_SpawnMobj(target.x, target.y, target.z + P_RandomRange(0, 120)*FRACUNIT, MT_GARU)
						g.target = target
						g.angle = FixedAngle(P_RandomRange(1, 360)*FRACUNIT)
						if i == 1 or i == 8
							g.jizzcolor = true
						end
						if i%2
							g.invertrotation = true
						end
						g.dist = P_RandomRange(45, 140)
						g.tics = 35
						g.lowquality = true
					end
				elseif time == 50
					target.elec = nil
					damageObject(target)
					localquake(mo.battlen, FRACUNIT*8, 8)
				end

				if target.elec
				and target.elec.valid
				and not (leveltime%2)
					target.elec.frame = P_RandomRange(A, L)
				end

			end
			if timer == 85 + 5*(#hittargets-1)
				return true
			end
		end,
	},

	["magarudyne"] = {
		name = "Magarudyne",
		type = ATK_WIND,
		power = 350,
		accuracy = 90,
		costtype = CST_SP,
		cost = 18,
		desc = "Heavy Wind dmg to all enemies.",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)

			for k,e in ipairs(hittargets)
			local target = e
			local time = timer - 5*(k-1)

				if time == 20
					playSound(mo.battlen, sfx_wind3)
					local barrier = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					target.elec = barrier
					barrier.scale = FRACUNIT*2
					barrier.state = S_PLAY_STND
					barrier.tics = -1
					barrier.sprite = SPR_ELEC
					barrier.fuse = 40
					for i = 1, 10
						local g = P_SpawnMobj(target.x, target.y, target.z + P_RandomRange(0, 120)*FRACUNIT, MT_GARU)
						g.target = target
						g.angle = FixedAngle(P_RandomRange(1, 360)*FRACUNIT)
						if i == 1 or i == 8
							g.jizzcolor = true
						end
						if i%2
							g.invertrotation = true
						end
						g.dist = P_RandomRange(45, 140)
						g.tics = 35
						g.lowquality = true
					end
				elseif time == 50
					target.elec = nil
					damageObject(target)
					localquake(mo.battlen, FRACUNIT*8, 8)
				end

				if target.elec
				and target.elec.valid
				and not (leveltime%2)
					target.elec.frame = P_RandomRange(A, L)
				end

			end
			if timer == 85 + 5*(#hittargets-1)
				return true
			end
		end,
	},

	["magarula"] = {
		name = "Magarula",
		type = ATK_WIND,
		power = 140,
		accuracy = 90,
		costtype = CST_SP,
		cost = 12,
		desc = "Medium Wind dmg to all enemies.",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)

			for k,e in ipairs(hittargets)
			local target = e
			local time = timer - 5*(k-1)

				if time == 20
					playSound(mo.battlen, sfx_wind2)
					for i = 1, 10
						local g = P_SpawnMobj(target.x, target.y, target.z + P_RandomRange(0, 120)*FRACUNIT, MT_GARU)
						g.target = target
						g.angle = FixedAngle(P_RandomRange(1, 360)*FRACUNIT)
						if i == 1 or i == 8
							g.jizzcolor = true
						end
						if i%2
							g.invertrotation = true
						end
						g.dist = P_RandomRange(45, 140)
						g.tics = 25
						g.lowquality = true
					end

				elseif time == 30
				or time == 33
				or time == 36
				or time == 39
					local s = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					s.scale = FRACUNIT/4
					s.sprite = SPR_SLAS
					s.frame = I|TR_TRANS50 + P_RandomRange(0, 3)
					s.destscale = FRACUNIT*9
					s.scalespeed = FRACUNIT
					s.tics = TICRATE/3

				elseif time == 40
					damageObject(target)
				end
			end
			if timer == 75 + 5*(#hittargets-1)
				return true
			end
		end,
	},

	["magaru"] = {
		name = "Magaru",
		type = ATK_WIND,
		power = 60,
		accuracy = 90,
		costtype = CST_SP,
		cost = 6,
		desc = "Light Wind dmg to all enemies.",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)

			for k,e in ipairs(hittargets)
			local target = e
			local time = timer - 5*(k-1)

				if time == 20

					for i = 1, 8
						local g = P_SpawnMobj(target.x, target.y, target.z + P_RandomRange(0, 60)*FRACUNIT, MT_GARU)
						g.target = target
						g.angle = FixedAngle(P_RandomRange(1, 360)*FRACUNIT)
						if i == 1 or i == 8
							g.jizzcolor = true
						end
						if i%2
							g.invertrotation = true
						end
						g.dist = P_RandomRange(45, 90)
						g.tics = 25
						g.lowquality = true
					end

				elseif time == 30
					playSound(mo.battlen, sfx_wind1)

				elseif time == 33
				or time == 36
				or time == 39
					local s = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					s.scale = FRACUNIT/4
					s.sprite = SPR_SLAS
					s.frame = I|TR_TRANS50 + P_RandomRange(0, 3)
					s.destscale = FRACUNIT*9
					s.scalespeed = FRACUNIT
					s.tics = TICRATE/3

				elseif time == 40
					damageObject(target)
				end
			end
			if timer == 75 + 5*(#hittargets-1)
				return true
			end
		end,
	},

	["garu"] = {
		name = "Garu",
		type = ATK_WIND,
		power = 60,
		accuracy = 95,
		costtype = CST_SP,
		technical = COND_BURN,
		cost = 3,
		desc = "Light Wind dmg to one enemy.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 20

				for i = 1, 8
					local g = P_SpawnMobj(target.x, target.y, target.z + P_RandomRange(0, 60)*FRACUNIT, MT_GARU)
					g.target = target
					g.angle = FixedAngle(P_RandomRange(1, 360)*FRACUNIT)
					if i == 1 or i == 8
						g.jizzcolor = true
					end
					if i%2
						g.invertrotation = true
					end
					g.dist = P_RandomRange(45, 90)
					g.tics = 25
				end

			elseif timer == 30
				playSound(mo.battlen, sfx_wind1)

			elseif timer == 33
			or timer == 36
			or timer == 39
				local s = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
				s.scale = FRACUNIT/4
				s.sprite = SPR_SLAS
				s.frame = I|TR_TRANS50 + P_RandomRange(0, 3)
				s.destscale = FRACUNIT*9
				s.scalespeed = FRACUNIT
				s.tics = TICRATE/3

			elseif timer == 40
				damageObject(target)
				for i = 1, 32
					local g = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					g.scale = FRACUNIT/2
					g.destscale = 1
					g.color = SKINCOLOR_EMERALD
					g.frame = A
					if i%2 then g.color = SKINCOLOR_WHITE end
					g.momx = P_RandomRange(-15, 15)*FRACUNIT
					g.momy = P_RandomRange(-15, 15)*FRACUNIT
					g.momz = P_RandomRange(-15, 15)*FRACUNIT
				end

			elseif timer == 75
				return true
			end
		end,
	},

	["guard"] = {
		name = "Guard",
		type = ATK_SUPPORT,
		target = TGT_CASTER,
		physical = true,
		norandom = true,	-- Don't allow this move to be selected in random pvp skills
		anim = 	function(mo, targets, htargets, timer)
					if timer == 1
						ANIM_set(mo, mo.anim_guard, true)
					elseif timer == 25
						mo.guard = true
						return true
					end
				end,
		},

	["dummy"] = {	-- dummy attack for single selection
		name = "dummy",
		type = ATK_ALMIGHTY,
		power = 1,
		accuracy = 100,
		target = TGT_ENEMY,
		desc = "",
		norandom = true,	-- Don't allow this move to be selected in random pvp skills
		anim = function()
					return true
				end,
	},

	["shadow_atk1"] = {
		name = "Chaos Spear",
		type = ATK_PIERCE,
		power = 35,
		accuracy = 95,
		critical = 7,
		target = TGT_ENEMY,
		cost = CST_HP,
		cost = 0,
		norandom = true,	-- Don't allow this move to be selected in random pvp skills
		desc = "A surprise attack from behind\nthat hits with Chaos Spears.",
		anim_norepel = true,
		physical = true,
		anim = function(mo, targets, hittargets, timer)

					local target = targets[1]
					local atarget = hittargets[1]

					local tpdestx = target.x - 128*cos(target.angle)
					local tpdesty = target.y - 128*sin(target.angle)

					if timer == 1
						local cx = target.x + 168*cos(target.angle + ANG1*20)
						local cy = target.y + 168*sin(target.angle + ANG1*20)
						CAM_goto(server.P_BattleStatus[mo.battlen].cam, cx, cy, target.z + FRACUNIT*30, 70*FRACUNIT)
						CAM_angle(server.P_BattleStatus[mo.battlen].cam, R_PointToAngle2(cx, cy, target.x, target.y))
						mo.shadow_savemom = nil
					elseif timer == 30	-- *teleports behind u* (for real)

						playSound(mo.battlen, sfx_csnap)

						-- teleport ourselves as well
						P_TeleportMove(mo, tpdestx, tpdesty, target.z + FRACUNIT*64)
						P_InstaThrust(mo, target.angle - ANG1*90, 1*FRACUNIT)
						mo.savemom = {mo.momx, mo.momy, FRACUNIT/2}
						ANIM_set(mo, mo.anim_special2, true)

					elseif timer == 40
						ANIM_set(mo, mo.anim_special1, true)

					elseif timer >= 50 and timer <= 80
						if mo.anim ~= mo.anim_special1
							ANIM_set(mo, mo.anim_special1, true)
						end
						if timer == 60
							damageObject(atarget)
						end

						if leveltime%5 == 0

							local x = target.x + P_RandomRange(-96, 96)<<FRACBITS
							local y = target.y + P_RandomRange(-96, 96)<<FRACBITS
							local z = target.z + P_RandomRange(0, 96)<<FRACBITS

							local s = P_SpawnMobj(x, y, z, MT_DUMMY)
							s.state = S_CHAOSSPEAREXPLOSION1

							if leveltime%10 == 0
								local shot = P_SpawnMobj(x, y, z, MT_DUMMY)
								shot.state = S_STAB_1_1
								shot.color = SKINCOLOR_CYAN

								local d = P_SpawnMobj(x, y, z+128*FRACUNIT, MT_THOK)
								d.sprite = SPR_THMP
								d.frame = A|FF_FULLBRIGHT
								d.scale = FRACUNIT/4
								d.destscale = FRACUNIT*4
								d.scalespeed = FRACUNIT/8
								d.fuse = TICRATE-10
								d.tics = d.fuse
								d.momz = FRACUNIT*2
								d.momx = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
								d.momy = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
								d.color = SKINCOLOR_CYAN
							end

							localquake(mo.battlen, FRACUNIT*20, 10)
							playSound(mo.battlen, sfx_hit)
							createSplat(mo)
						end
					elseif timer > 100

						mo.savemom = nil
						return true
					end

					if mo.savemom
						mo.momx, mo.momy, mo.momz = mo.savemom[1], mo.savemom[2], mo.savemom[3]
					end

		end,


	},

	["knuckles_atk1"] = {
		name = "Dive Press",
		type = ATK_STRIKE,
		power = 35,
		accuracy = 95,
		critical = 7,
		target = TGT_ENEMY,
		cost = CST_HP,
		cost = 0,
		desc = "Unavoidable grab attack\nthat slams the target on the floor.",
		anim_norepel = true,
		physical = true,
		anim = function(mo, targets, hittargets, timer)

					local target = targets[1]
					local atarget = hittargets[1]


					if timer == 1
						ANIM_set(mo, mo.anim_run, true)
						mo.reachedtarget = false	-- yeah we can use variables here that you like it or not :^)
						mo.slammed = false

						local cx = target.x + 168*cos(target.angle + ANG1*20)
						local cy = target.y + 168*sin(target.angle + ANG1*20)
						CAM_goto(server.P_BattleStatus[mo.battlen].cam, cx, cy, target.z + FRACUNIT*30, 70*FRACUNIT)
						CAM_angle(server.P_BattleStatus[mo.battlen].cam, R_PointToAngle2(cx, cy, target.x, target.y))
						S_StartSound(mo, sfx_zoom)
					end

					if not mo.reachedtarget
						mo.angle = R_PointToAngle2(mo.x, mo.y, target.x, target.y)
						P_InstaThrust(mo, mo.angle, FRACUNIT*36)
						if R_PointToDist2(mo.x, mo.y, target.x, target.y) < FRACUNIT*36
							mo.reachedtarget = timer
							ANIM_set(mo, mo.anim_special1, true)	-- knux spring state
							mo.momz = FRACUNIT*12
							P_InstaThrust(mo, 0, 0)
							playSound(mo.battlen, sfx_beflap)
						end
					else
						if mo.momz < FRACUNIT and not mo.slammed	-- now we SLAM
							if mo.anim ~= mo.anim_atk
								ANIM_set(mo, mo.anim_atk, true)
							end
							mo.momz = $ - FRACUNIT
						end

						if P_IsObjectOnGround(mo) and not mo.slammed
							P_InstaThrust(mo, mo.angle, -5*FRACUNIT)
							mo.momz = 5*FRACUNIT
							ANIM_set(mo, mo.anim_special2, true)
							target.momz = 5*FRACUNIT

							damageObject(atarget)
							playSound(mo.battlen, sfx_pstop)
							if not target.plyr
								createSplat(mo)
								createSplat(mo)
								localquake(mo.battlen, 14*FRACUNIT, 10)
							end
							for i=1,16
								local b = P_SpawnMobj(target.x, target.y, target.z+2*FRACUNIT, MT_DUMMY)
								b.momx = P_RandomRange(-3, 3)*FRACUNIT
								b.momy = P_RandomRange(-3, 3)*FRACUNIT
								b.momz = P_RandomRange(4, 16)*FRACUNIT
								b.state = S_AOADUST1
								b.frame = A|FF_FULLBRIGHT
								b.scale = FRACUNIT*3
								b.destscale = FRACUNIT/12
							end
							for i = 1,32
								local dust = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
								dust.angle = ANGLE_90 + ANG1* (11*(i-1))
								dust.destscale = FRACUNIT*10
								dust.state = S_AOADUST1
								dust.frame = A|FF_FULLBRIGHT
								P_InstaThrust(dust, dust.angle, 20*FRACUNIT)
							end
							mo.slammed = true
						else
							P_TeleportMove(target, target.x, target.y, mo.z)
						end
					end

					if mo.reachedtarget and timer - mo.reachedtarget > 65
						return true
					end
				end,
		critanim = function(mo, targets, hittargets, timer)

					local target = targets[1]
					local atarget = hittargets[1]


					if timer == 1
						ANIM_set(mo, mo.anim_run, true)
						mo.reachedtarget = false	-- yeah we can use variables here that you like it or not :^)
						mo.slammed = false
						mo.critslam = false

						local cx = target.x + 168*cos(target.angle + ANG1*20)
						local cy = target.y + 168*sin(target.angle + ANG1*20)
						CAM_goto(server.P_BattleStatus[mo.battlen].cam, cx, cy, target.z + FRACUNIT*30, 70*FRACUNIT)
						CAM_angle(server.P_BattleStatus[mo.battlen].cam, R_PointToAngle2(cx, cy, target.x, target.y))
						S_StartSound(mo, sfx_zoom)
					end

					if not mo.reachedtarget
						mo.angle = R_PointToAngle2(mo.x, mo.y, target.x, target.y)
						P_InstaThrust(mo, mo.angle, FRACUNIT*36)
						if R_PointToDist2(mo.x, mo.y, target.x, target.y) < FRACUNIT*36
							mo.reachedtarget = timer
							ANIM_set(mo, mo.anim_special1, true)	-- knux spring state
							mo.momz = FRACUNIT*12
							P_InstaThrust(mo, 0, 0)
							playSound(mo.battlen, sfx_beflap)
						end
					else
						if mo.momz < FRACUNIT	-- now we SLAM
						and not mo.critslam
							if mo.anim ~= mo.anim_atk
								ANIM_set(mo, mo.anim_atk, true)
							end
							mo.momz = $ - FRACUNIT
							if mo.momz < -15*FRACUNIT
								target.momz = mo.momz*3/2
								mo.momz = 0
								ANIM_set(mo, mo.anim_special2, true)

								mo.critslam = true
							end
						end

						if P_IsObjectOnGround(mo)
							ANIM_set(mo, mo.anim_stand, true)
						end

						if P_IsObjectOnGround(target) and mo.critslam and not mo.slammed
							target.momz = 7*FRACUNIT

							damageObject(atarget)
							playSound(mo.battlen, sfx_pstop)
							if not target.plyr
								createSplat(mo)
								createSplat(mo)
								localquake(mo.battlen, 14*FRACUNIT, 10)
							end
							for i=1,16
								local b = P_SpawnMobj(target.x, target.y, target.z+2*FRACUNIT, MT_DUMMY)
								b.momx = P_RandomRange(-3, 3)*FRACUNIT
								b.momy = P_RandomRange(-3, 3)*FRACUNIT
								b.momz = P_RandomRange(4, 16)*FRACUNIT
								b.state = S_AOADUST1
								b.frame = A|FF_FULLBRIGHT
								b.scale = FRACUNIT*3
								b.destscale = FRACUNIT/12
							end
							for i = 1,32
								local dust = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
								dust.angle = ANGLE_90 + ANG1* (11*(i-1))
								dust.destscale = FRACUNIT*10
								dust.state = S_AOADUST1
								dust.frame = A|FF_FULLBRIGHT
								P_InstaThrust(dust, dust.angle, 20*FRACUNIT)
							end
							mo.slammed = true
						else
							if not mo.critslam then P_TeleportMove(target, target.x, target.y, mo.z) end
						end
					end

					if mo.reachedtarget and timer - mo.reachedtarget > 85
						return true
					end
				end,

	},

	["tails_atk1"] = {
		name = "Tails Bomber",
		type = ATK_STRIKE,
		power = 35,
		accuracy = 85,
		critical = 7, -- 7
		target = TGT_ENEMY,
		cost = CST_HP,
		cost = 0,
		desc = "An attack using\nan explosive monitor.",
		anim_norepel = true,
		physical = true,
		anim = function(mo, targets, hittargets, timer)

					local target = targets[1]
					local atarget = hittargets[1]

					-- we will always be flying, play tails flight sound all the way through
					if not (leveltime%10)
						S_StartSound(mo, sfx_putput)
					end

					if timer == 1	-- take flight!
						mo.savez = mo.z
						ANIM_set(mo, mo.anim_special1, true)	-- tails' flying frames

						mo.target = P_SpawnMobj(target.x, target.y, target.z + 256*FRACUNIT, MT_DUMMY)
						mo.target.state = S_INVISIBLE

						-- move cam:
						local cx = target.x + 384*cos(target.angle)
						local cy = target.y + 384*sin(target.angle)
						local cz = target.z + 224*FRACUNIT
						CAM_goto(server.P_BattleStatus[mo.battlen].cam, cx, cy, cz, 70*FRACUNIT)
						CAM_angle(server.P_BattleStatus[mo.battlen].cam, R_PointToAngle2(cx, cy, target.x, target.y), ANG1*4)
						CAM_aiming(server.P_BattleStatus[mo.battlen].cam, -ANG1*10, ANG1)
					end

					-- fly towards target
					if timer <= 16

						-- use basic interpolation:
						mo.momx = (mo.target.x - mo.x)/10
						mo.momy = (mo.target.y - mo.y)/10
						mo.momz = (mo.target.z - mo.z)/10
					else
						mo.momx, mo.momy, mo.momz = 0, 0, 0
					end

					if timer == 20
						-- drop the bomb
						playSound(mo.battlen, sfx_s3k51)
						local monitor = P_RandomRange(MT_RING_BOX, MT_THUNDERCOIN_BOX)
						mo.target = P_SpawnMobj(mo.x, mo.y, mo.z, monitor)	-- yeah sure
						mo.target.flags = MF_NOCLIPHEIGHT
					elseif timer > 20 and mo.target and mo.target.valid
						if mo.target.z <= target.z+(target.height/2)	-- bomb fell on target
							damageObject(atarget)
							playSound(mo.battlen, sfx_pop)
							playSound(mo.battlen, sfx_s3kb9)

							-- spawn 10 fake rings
							for i = 1, 10
								local b = P_SpawnMobj(target.x, target.y, target.z + FRACUNIT*32, MT_BOOMPARTICLE)
								b.momx = P_RandomRange(-32, 32)<<FRACBITS
								b.momy = P_RandomRange(-32, 32)<<FRACBITS
								b.momz = P_RandomRange(0, 16)<<FRACBITS
								b.fuse = TICRATE*6
							end

							P_RemoveMobj(mo.target)
							mo.target = nil

						end
					end
					if timer > 80
						mo.z = mo.savez
						return true
					end
		end,
		critanim = function(mo, targets, hittargets, timer)

					local target = targets[1]
					local atarget = hittargets[1]

					-- we will always be flying, play tails flight sound all the way through
					if not (leveltime%10)
						S_StartSound(mo, sfx_putput)
					end

					if timer == 1	-- take flight!
						mo.savez = mo.z
						ANIM_set(mo, mo.anim_special1, true)	-- tails' flying frames

						mo.target = P_SpawnMobj(target.x, target.y, target.z + 256*FRACUNIT, MT_DUMMY)
						mo.target.state = S_INVISIBLE

						-- move cam:
						local cx = target.x + 384*cos(target.angle)
						local cy = target.y + 384*sin(target.angle)
						local cz = target.z + 224*FRACUNIT
						CAM_goto(server.P_BattleStatus[mo.battlen].cam, cx, cy, cz, 70*FRACUNIT)
						CAM_angle(server.P_BattleStatus[mo.battlen].cam, R_PointToAngle2(cx, cy, target.x, target.y), ANG1*4)
						CAM_aiming(server.P_BattleStatus[mo.battlen].cam, -ANG1*10, ANG1)
					end

					-- fly towards target
					if timer <= 16

						-- use basic interpolation:
						mo.momx = (mo.target.x - mo.x)/10
						mo.momy = (mo.target.y - mo.y)/10
						mo.momz = (mo.target.z - mo.z)/10
					else
						mo.momx, mo.momy, mo.momz = 0, 0, 0
					end

					if timer == 20
						-- drop the bomb
						playSound(mo.battlen, sfx_s3k51)
						local goldmonitor = P_RandomRange(MT_PITY_GOLDBOX, MT_THUNDERCOIN_GOLDBOX)
						mo.target = P_SpawnMobj(mo.x, mo.y, mo.z, goldmonitor)	-- yeah sure
						mo.target.flags = MF_NOCLIPHEIGHT
					elseif timer > 20 and mo.target and mo.target.valid
						if mo.target.z <= target.z+(target.height/2)	-- bomb fell on target
							damageObject(atarget)
							playSound(mo.battlen, sfx_pop)
							playSound(mo.battlen, sfx_s3kb9)

							-- spawn 10 fake rings
							for i = 1, 10
								local b = P_SpawnMobj(target.x, target.y, target.z + FRACUNIT*32, MT_BOOMPARTICLE)
								b.momx = P_RandomRange(-32, 32)<<FRACBITS
								b.momy = P_RandomRange(-32, 32)<<FRACBITS
								b.momz = P_RandomRange(0, 16)<<FRACBITS
								b.fuse = TICRATE*6
							end

							P_RemoveMobj(mo.target)
							mo.target = nil

						end
					end
					if timer > 80
						mo.z = mo.savez
						return true
					end
		end,
	},

	["metal_atk1"] = {
		name = "Overdrive Dash",
		type = ATK_STRIKE,
		power = 60,
		accuracy = 90,
		critical = 2,
		target = TGT_ENEMY,
		cost = CST_HP,
		cost = 0,
		desc = "A rapid overdrive attack. \nMore powerful than the average \nMelee hit, but low critical rate.",
		anim_norepel = true,	-- do not bounce back our ANIMATION
		physical = true,	-- don't play the summoning anim for phys attacks, duh
		anim = 	function(mo, targets, hittargets, timer)
					local target = targets[1]
					local atarget = hittargets[1]
					if timer == 1
						ANIM_set(mo, mo.anim_special2, true)
						mo.reachedtarget = false	-- yeah we can use variables here that you like it or not :^)

						local cx = target.x + 168*cos(target.angle + ANG1*20)
						local cy = target.y + 168*sin(target.angle + ANG1*20)
						CAM_goto(server.P_BattleStatus[mo.battlen].cam, cx, cy, target.z + FRACUNIT*30, 70*FRACUNIT)
						CAM_angle(server.P_BattleStatus[mo.battlen].cam, R_PointToAngle2(cx, cy, target.x, target.y))
						S_StartSound(mo, sfx_msovd1)
					end

					local s = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
					s.state = S_MSOVERDRIVE1
					P_InstaThrust(mo, mo.angle, FRACUNIT*60)

					if not mo.reachedtarget

						if mo.anim ~= mo.anim_special2
							ANIM_set(mo, mo.anim_special2, true)
						end

						mo.angle = R_PointToAngle2(mo.x, mo.y, target.x, target.y)

						if R_PointToDist2(mo.x, mo.y, target.x, target.y) <= FRACUNIT*60

							damageObject(atarget)
							playSound(mo.battlen, sfx_bkpoof)
							mo.reachedtarget = timer

							for i=1,24
								local b = P_SpawnMobj(target.x, target.y, target.z+2*FRACUNIT, MT_DUMMY)
								b.momx = P_RandomRange(-32, 32)*FRACUNIT
								b.momy = P_RandomRange(-32, 32)*FRACUNIT
								b.momz = P_RandomRange(4, 16)*FRACUNIT
								b.state = S_AOADUST1
								b.frame = A|FF_FULLBRIGHT
								b.scale = FRACUNIT*3
								b.destscale = FRACUNIT/12
							end
							for i = 1, 4
								createSplat(mo)
							end
						end
					else

						if timer - mo.reachedtarget > 40
							return true
						end
					end
				end,
	},

	["amy_atk1"] = {
		name = "Hammer Hit",
		type = ATK_STRIKE,
		power = 45,
		accuracy = 85,
		critical = 7, -- was 7
		target = TGT_ENEMY,
		cost = CST_HP,
		cost = 0,
		desc = "A strong Hammer Hit.",
		anim_norepel = true,	-- do not bounce back our ANIMATION
		physical = true,	-- don't play the summoning anim for phys attacks, duh
		anim = 	function(mo, targets, hittargets, timer)
					local target = targets[1]
					if timer == 1
						ANIM_set(mo, mo.anim_special1, true)
						playSound(mo.battlen, sfx_s220)

						-- fake A_LobShot:
						mo.angle = R_PointToAngle2(mo.x, mo.y, target.x, target.y)

						local z = mo.z
						local hit = P_SpawnMobj(target.x & (64*FRACUNIT -1), target.y & (64*FRACUNIT -1), target.subsector.sector.floorheight, MT_NULL)
						hit.tics = TICRATE

						local dist = P_AproxDistance(target.x - mo.x, target.y - mo.y)
						local horizontal = dist / TICRATE
						local vertical = FixedMul((gravity*TICRATE)/2, mo.scale)

						mo.momx = FixedMul(horizontal, cos(mo.angle))
						mo.momy = FixedMul(horizontal, sin(mo.angle))
						mo.momz = vertical


						-- move camera to an interresting spot

						local an = target.angle + 45*ANG1

						local cx = target.x + 384*cos(an)
						local cy = target.y + 384*sin(an)

						CAM_goto(server.P_BattleStatus[mo.battlen].cam, cx, cy, server.P_BattleStatus[mo.battlen].cam.z, 70*FRACUNIT)
						CAM_angle(server.P_BattleStatus[mo.battlen].cam, R_PointToAngle2(cx, cy, target.x, target.y), ANG1*4)
						--CAM_aiming(server.P_BattleStatus[mo.battlen].cam, -ANG1*10, ANG1)

					elseif timer == TICRATE - 7
						ANIM_set(mo, mo.anim_special2)	-- hammer hit prep

					elseif timer == TICRATE
						damageObject(hittargets[1])
						P_InstaThrust(mo, 0, 0)

						-- explode hearts all over!
						-- heart ring:
						for i = 1, 8
							local h = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
							h.state = S_LHRT
							h.fuse = TICRATE
							P_InstaThrust(h, (360/8 *i)*ANG1, FRACUNIT*32)

							if i%2
								createSplat(mo)
							end
						end

						localquake(mo.battlen, FRACUNIT*30, 8)
						playSound(mo.battlen, sfx_pstop)

						for i = 1, 16
							local h = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
							h.state = S_LHRT
							h.fuse = TICRATE
							h.momx = P_RandomRange(-24, 24)*FRACUNIT
							h.momy = P_RandomRange(-24, 24)*FRACUNIT
							h.momz = P_RandomRange(2, 24)*FRACUNIT
						end
					elseif timer == TICRATE*2
						return true
					end
				end,
	},

	["silver_atk1"] = {
		name = "Kinetic Bash",
		type = ATK_STRIKE,
		power = 35,
		accuracy = 85,
		critical = 4, -- was 7
		target = TGT_ENEMY,
		cost = CST_HP,
		cost = 0,
		desc = "Lifts the target up with Levikinesis\nand finishes off with a powerful\nTelekinetic cutter",
		anim_norepel = true,	-- do not bounce back our ANIMATION
		physical = true,	-- don't play the summoning anim for phys attacks, duh
		anim = 	function(mo, targets, hittargets, timer)
					local target = targets[1]
					local btl = server.P_BattleStatus[mo.battlen]
					local cam = btl.cam

					ANIM_set(mo, mo.anim_stand_bored)

					local function spawnaura(t)
						local overlay = P_SpawnMobjFromMobj(t, 0, 0, 0, MT_DUMMY)
						overlay.sprite = t.sprite
						if t.sprite2 and t.skin
							overlay.skin = t.skin
							overlay.sprite2 = t.sprite2
						end
						overlay.frame = (t.frame & FF_FRAMEMASK)|FF_FULLBRIGHT|TR_TRANS50
						overlay.colorized = true
						overlay.color = SKINCOLOR_AQUA
						overlay.height = t.height
						overlay.angle = t.angle
						overlay.rollangle = t.rollangle
						overlay.tics = 2
					end

					spawnaura(mo)

					if timer == 1
						playSound(mo.battlen, sfx_s3k74)
					end

					if timer < TICRATE
						--target.rollangle = $+ANG1*4
						-- Potentially too laggy.
						target.momz = (target.floorz + FRACUNIT*192 - target.z)/8
						spawnaura(target)
					elseif timer == TICRATE
						target.momz = -FRACUNIT*32
					end

					if timer >= TICRATE
					and not target.tkdamage
						if leveltime & 1
							local g = P_SpawnGhostMobj(target)
							g.rollangle = target.rollangle
							g.destscale = target.scale*4
						end

						if P_IsObjectOnGround(target)
							target.rollangle = 0
							damageObject(hittargets[1])
							target.tkdamage = true
							for i = 1, 3
								createSplat(mo)
							end
							for i = 1,32
								local dust = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
								dust.angle = ANGLE_90 + ANG1* (11*(i-1))
								dust.destscale = FRACUNIT*10
								dust.state = S_AOADUST1
								dust.frame = A|FF_FULLBRIGHT
								P_InstaThrust(dust, dust.angle, 20*FRACUNIT)
							end
							playSound(mo.battlen, sfx_pstop)
							localquake(mo.battlen, FRACUNIT*32, TICRATE/2)
						end
					end

					if target.tkdamage and timer >= TICRATE + TICRATE/2
						target.tkdamage = nil
						return true
					end
				end,

		critanim = 	function(mo, targets, hittargets, timer)
					local target = targets[1]
					local btl = server.P_BattleStatus[mo.battlen]
					local cam = btl.cam

					ANIM_set(mo, mo.anim_stand_bored)

					local function spawnaura(t)
						local overlay = P_SpawnMobjFromMobj(t, 0, 0, 0, MT_DUMMY)
						overlay.sprite = t.sprite
						if t.sprite2 and t.skin
							overlay.skin = t.skin
							overlay.sprite2 = t.sprite2
						end
						overlay.frame = (t.frame & FF_FRAMEMASK)|FF_FULLBRIGHT|TR_TRANS50
						overlay.colorized = true
						overlay.color = SKINCOLOR_AQUA
						overlay.height = t.height
						overlay.angle = t.angle
						overlay.rollangle = t.rollangle
						overlay.tics = 2
					end

					spawnaura(mo)

					if timer == 1
						playSound(mo.battlen, sfx_s3k74)

						mo.lifttimer = TICRATE/2
						mo.liftnum = 1
					end

					local ltimer = mo.lifttimer
					mo.lifttimer = $+1

					if ltimer < TICRATE
						--target.rollangle = $+ANG1*4
						-- Potentially too laggy.
						target.momz = (target.floorz + FRACUNIT*192 - target.z)/8
						spawnaura(target)
					elseif ltimer == TICRATE
						target.momz = -FRACUNIT*32
					end

					if ltimer >= TICRATE
					and not target.tkdamage
						if leveltime & 1
							local g = P_SpawnGhostMobj(target)
							g.rollangle = target.rollangle
							g.destscale = target.scale*4
						end

						if P_IsObjectOnGround(target)
							target.rollangle = 0
							createSplat(mo)
							for i = 1,32
								local dust = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
								dust.angle = ANGLE_90 + ANG1* (11*(i-1))
								dust.destscale = FRACUNIT*10
								dust.state = S_AOADUST1
								dust.frame = A|FF_FULLBRIGHT
								P_InstaThrust(dust, dust.angle, 20*FRACUNIT)
							end
							playSound(mo.battlen, sfx_pstop)
							localquake(mo.battlen, FRACUNIT*32, TICRATE/2)

							if mo.liftnum < 6

								-- restart the cycle xd
								mo.liftnum = $ + 1
								mo.lifttimer = min(TICRATE-8, TICRATE/2 + (5*mo.liftnum))
							else
								target.tkdamage = 1
								damageObject(hittargets[1])
								P_InstaThrust(target, target.angle, -8*FRACUNIT)
								P_SetObjectMomZ(target, FRACUNIT*8)
							end
						end
					end

					if target.tkdamage
						target.tkdamage = $+1

						local s = P_SpawnMobj(target.x + P_RandomRange(-64, 64)*FRACUNIT, target.y + P_RandomRange(-32, 32)*FRACUNIT, target.z + P_RandomRange(0, 64)*FRACUNIT, MT_THOK)
						s.state = S_AOADUST1
						s.scale = $*3/2

						if target.tkdamage >= TICRATE*3/2
							target.tkdamage = nil
							return true
						end
					end
				end,

	},

	["blaze_atk1"] = {
		name = "Blazing Drill",
		type = ATK_PIERCE,
		power = 35,
		accuracy = 95,
		critical = 4, -- was 7
		target = TGT_ENEMY,
		cost = CST_HP,
		cost = 0,
		desc = "Drill through the target\nwith sharp heels!",
		anim_norepel = true,	-- do not bounce back our ANIMATION
		physical = true,	-- don't play the summoning anim for phys attacks, duh
		anim = 	function(mo, targets, hittargets, timer)
					local target = targets[1]
					local btl = server.P_BattleStatus[mo.battlen]
					local cam = btl.cam

					if timer == 1
						local cx = target.x + 168*cos(target.angle + ANG1*20)
						local cy = target.y + 168*sin(target.angle + ANG1*20)
						CAM_goto(server.P_BattleStatus[mo.battlen].cam, cx, cy, target.z + FRACUNIT*30, 70*FRACUNIT)
						CAM_angle(server.P_BattleStatus[mo.battlen].cam, R_PointToAngle2(cx, cy, target.x, target.y))
					elseif timer == 10
						ANIM_set(mo, mo.anim_atk)
						P_TeleportMove(mo, target.x + 4*cos(target.angle), target.y + 4*sin(target.angle), target.z + FRACUNIT*256)
						mo.momz = -FRACUNIT*24
					elseif timer >=  10
					and timer < TICRATE + TICRATE/2
						if leveltime & 1
							local g = P_SpawnGhostMobj(mo)
							g.destscale = mo.scale*4
						end

						if mo.z <= target.z + FRACUNIT*32
							mo.z = target.z + FRACUNIT*32
							mo.momz = 0

							if leveltime%5 == 0
								createSplat(mo)
								local shot = P_SpawnMobj(target.x + P_RandomRange(-15, 15)*FRACUNIT, target.y + P_RandomRange(-15, 15)*FRACUNIT, target.z + P_RandomRange(16, 48)*FRACUNIT, MT_DUMMY)
								playSound(mo.battlen, sfx_rail1)
								shot.state = S_SHOT1
								shot.scale = $ + P_RandomRange(0, 65535)*3
								localquake(mo.battlen, FRACUNIT*10, 5)
							end
						end

					elseif timer == TICRATE + TICRATE/2
						damageObject(hittargets[1])
						P_InstaThrust(mo, target.angle, FRACUNIT*10)
						mo.momz = 10*FRACUNIT

					elseif timer == TICRATE*5/2
						mo.z = mo.floorz
						return true
					end
				end,
	},

	["eggman_atk1"] = {
		name = "Badnik Orders",
		type = ATK_STRIKE,
		power = 35,
		accuracy = 95,
		critical = 4, -- was 7
		target = TGT_ENEMY,
		cost = CST_HP,
		cost = 0,
		desc = "Use Badniks to attack\nthe target",
		anim_norepel = true,	-- do not bounce back our ANIMATION
		physical = true,	-- don't play the summoning anim for phys attacks, duh
		anim = 	function(mo, targets, hittargets, timer)
					local target = targets[1]
					local btl = server.P_BattleStatus[mo.battlen]
					local cam = btl.cam

					if timer == 1
						mo.crawlas = {}
						CAM_stop(cam)
						mo.oldangle = mo.angle
						mo.angle = R_PointToAngle2(mo.x, mo.y, target.x, target.y)
						local tgtx = mo.x + 256*cos(mo.angle)
						local tgty = mo.y + 256*sin(mo.angle)

						P_TeleportMove(cam, tgtx, tgty, mo.z + FRACUNIT*16)
						cam.angle = R_PointToAngle2(cam.x, cam.y, mo.x, mo.y)	-- face me!
						ANIM_set(mo, mo.anim_stand_bored)
					elseif timer == TICRATE
						local thean = R_PointToAngle2(target.x, target.y, mo.x, mo.y)
						local tgtx = target.x - 192*cos(thean)
						local tgty = target.y - 192*sin(thean)

						CAM_goto(cam, tgtx, tgty, target.z + FRACUNIT*64, FRACUNIT*20)
						CAM_angle(cam, thean)
					end

					-- spawn badniks:
					if timer >= TICRATE*2/3
					and timer <= TICRATE*5/2
						if leveltime%5 == 0
							local ban = R_PointToAngle2(mo.x, mo.y, target.x, target.y)
							local an = ban + ANG1*180 + P_RandomRange(-35, 35)*ANG1
							local m = P_SpawnMobj(mo.x + 128*cos(an), mo.y + 128*sin(an), mo.z+2, MT_BLUECRAWLA)
							m.flags = MF_NOGRAVITY
							m.angle = ban
							m.fuse = TICRATE*3/2
							P_InstaThrust(m, ban, 30*FRACUNIT)
							mo.crawlas[#mo.crawlas+1] = m
						end
					end

					if timer >= TICRATE and timer <= TICRATE*2
					and leveltime%5 == 0
						localquake(mo.battlen, FRACUNIT*10, TICRATE)
						createSplat(mo)

						local x = target.x + P_RandomRange(-40, 40)*FRACUNIT
						local y = target.y + P_RandomRange(-40, 40)*FRACUNIT
						local z = target.z + P_RandomRange(0, 30)*FRACUNIT
						playSound(mo.battlen, sfx_hit2)
						for i=1,16
							local b = P_SpawnMobj(x, y, z+2*FRACUNIT, MT_DUMMY)
							b.momx = P_RandomRange(-3, 3)*FRACUNIT
							b.momy = P_RandomRange(-3, 3)*FRACUNIT
							b.momz = P_RandomRange(4, 16)*FRACUNIT
							b.state = S_AOADUST1
							b.frame = A|FF_FULLBRIGHT
							b.scale = FRACUNIT*3
							b.destscale = FRACUNIT/12
						end
						for i=1,16
							local b = P_SpawnMobj(x, y, z+20*FRACUNIT, MT_DUMMY)
							b.momx = P_RandomRange(-8, 8)*FRACUNIT
							b.momy = P_RandomRange(-8, 8)*FRACUNIT
							b.momz = P_RandomRange(-8, 8)*FRACUNIT
							b.state = S_AOADUST1
							b.frame = A|FF_FULLBRIGHT
							b.scale = FRACUNIT*3
							b.destscale = FRACUNIT/12
						end
					end

					if timer == TICRATE*3/2
						damageObject(hittargets[1])
					elseif timer == TICRATE*3
						for i = 1, #mo.crawlas
							if mo.crawlas[i] and mo.crawlas[i].valid
								P_RemoveMobj(mo.crawlas[i])
							end
						end
						mo.crawlas = nil
						return true
					end
				end,
	},

	["ssonic_atk1"] = {
		name = "Chaos Dash",
		type = ATK_ALMIGHTY,
		power = 35,
		accuracy = 85,
		critical = 7, -- was 7
		target = TGT_ALLENEMIES,
		cost = CST_HP,
		cost = 0,
		desc = "A fierce spin kick\nfollowed by a Drop Dash.",
		anim_norepel = true,	-- do not bounce back our ANIMATION
		physical = true,	-- don't play the summoning anim for phys attacks, duh
		anim = 	function(mo, targets, hittargets, timer)
					local target = targets[1]
					local atarget = hittargets[1]
					if timer == 1
						ANIM_set(mo, mo.anim_run, true)
						mo.reachedtarget = false	-- yeah we can use variables here that you like it or not :^)

						local cx = target.x + 168*cos(target.angle + ANG1*20)
						local cy = target.y + 168*sin(target.angle + ANG1*20)
						CAM_goto(server.P_BattleStatus[mo.battlen].cam, cx, cy, target.z + FRACUNIT*30, 70*FRACUNIT)
						CAM_angle(server.P_BattleStatus[mo.battlen].cam, R_PointToAngle2(cx, cy, target.x, target.y))
						S_StartSound(mo, sfx_zoom)
					end

					if not mo.reachedtarget
						mo.angle = R_PointToAngle2(mo.x, mo.y, target.x, target.y)
						P_InstaThrust(mo, mo.angle, FRACUNIT*36)
						if R_PointToDist2(mo.x, mo.y, target.x, target.y) < FRACUNIT*36
							ANIM_set(mo, mo.anim_atk, true)
							localquake(mo.battlen, FRACUNIT*8, 4)
							mo.reachedtarget = true
							P_InstaThrust(mo, mo.angle, -FRACUNIT*6)
							mo.momz = 7*FRACUNIT
							playSound(mo.battlen, sfx_phys)
							for i = 1, 2
								createSplat(mo)
							end
						end
					else

						if P_IsObjectOnGround(mo)
						and not mo.momz
						and not mo.damagetime
							mo.damagetime = 1
							mo.momz = FRACUNIT
							P_InstaThrust(mo, mo.angle, FRACUNIT*90)
							S_StartSound(mo, sfx_spin)

						elseif mo.damagetime
							local trail = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
							trail.color = mo.color
							mo.damagetime = $+1
							if mo.damagetime == 2
								damageObject(atarget)
								localquake(mo.battlen, FRACUNIT*7, 4)
								playSound(mo.battlen, sfx_phys)
								for i = 1, 2
									createSplat(mo)
								end
							elseif mo.damagetime == 50
								mo.reachedtarget = nil
								mo.damagetime = nil
								return true
							end
						end
					end
				end,
	critanim = 	function(mo, targets, hittargets, timer)
					local target = targets[1]
					local atarget = hittargets[1]
					if timer == 1
						ANIM_set(mo, mo.anim_run, true)
						mo.reachedtarget = false	-- yeah we can use variables here that you like it or not :^)

						local cx = target.x + 168*cos(target.angle + ANG1*20)
						local cy = target.y + 168*sin(target.angle + ANG1*20)
						CAM_goto(server.P_BattleStatus[mo.battlen].cam, cx, cy, target.z + FRACUNIT*30, 70*FRACUNIT)
						CAM_angle(server.P_BattleStatus[mo.battlen].cam, R_PointToAngle2(cx, cy, target.x, target.y))
						S_StartSound(mo, sfx_zoom)
					end

					if not mo.reachedtarget
						mo.angle = R_PointToAngle2(mo.x, mo.y, target.x, target.y)
						P_InstaThrust(mo, mo.angle, FRACUNIT*36)
						if R_PointToDist2(mo.x, mo.y, target.x, target.y) < FRACUNIT*36
							ANIM_set(mo, mo.anim_atk, true)
							localquake(mo.battlen, FRACUNIT*8, 4)
							mo.reachedtarget = true
							P_InstaThrust(mo, mo.angle, -FRACUNIT*7)
							mo.momz = 8*FRACUNIT
							playSound(mo.battlen, sfx_phys)
							for i = 1, 2
								createSplat(mo)
							end
						end
					else
						if P_IsObjectOnGround(mo)
						and not mo.momz
						and not mo.damagetime
							-- move camera instantly
							local cam = server.P_BattleStatus[mo.battlen].cam

							local cx = mo.x + 128*cos(mo.angle - ANG1*25)
							local cy = mo.y + 128*sin(mo.angle - ANG1*25)
							P_TeleportMove(cam, cx, cy, mo.z + FRACUNIT*16)
							server.P_BattleStatus[mo.battlen].cam.angle = R_PointToAngle2(cam.x, cam.y, mo.x, mo.y)

							-- now make it zoom out a little
							CAM_goto(cam, cam.x-24*cos(cam.angle), cam.y-24*sin(cam.angle), cam.z+FRACUNIT*5, 1*FRACUNIT)

							-- setup sonic
							mo.damagetime = 1
							mo.momx, mo.momy, mo.momz = 0, 0, 0 -- stop momentum, start spindash
							ANIM_set(mo, mo.anim_special1, true)
							S_StartSound(mo, sfx_spndsh)
						elseif mo.damagetime
							mo.damagetime = $+1
							-- rev animation
							if mo.damagetime == 13 or mo.damagetime == 21 or mo.damagetime == 28
								--local revSounds = {sfx_sncsd1, sfx_sncsd2, sfx_sncsd3}

								mo.rev = $ and $+1 or 1
								S_StartSound(mo, sfx_spndsh)
								-- at 3rd rev speed up use the faster spindash anim
								ANIM_set(mo, mo.rev == 3 and mo.anim_special2 or mo.anim_special1, true)
							end
							-- start spindash
							if mo.damagetime >= 35
								if mo.damagetime == 35 -- nyoom
									-- camera
									local cx = target.x + 512*cos(target.angle + ANG1*20)
									local cy = target.y + 512*sin(target.angle + ANG1*20)
									CAM_goto(server.P_BattleStatus[mo.battlen].cam, cx, cy, target.z + FRACUNIT*30, 128*FRACUNIT)
									CAM_angle(server.P_BattleStatus[mo.battlen].cam, R_PointToAngle2(cx, cy, target.x, target.y), ANG1*16)

									-- sonic
									S_StartSound(mo, sfx_zoom)
									P_InstaThrust(mo, mo.angle, FRACUNIT*120)
									ANIM_set(mo, mo.anim_atk, true)
								else
									local trail = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
									trail.color = mo.color
									if mo.damagetime == 36
										damageObject(atarget)
										P_SetObjectMomZ(atarget, 5*FRACUNIT)
										localquake(mo.battlen, FRACUNIT*12, 7)
										playSound(mo.battlen, sfx_phys)
										for i = 1, 4
											createSplat(mo)
										end
									elseif mo.damagetime == 85
										mo.rev = nil
										mo.reachedtarget = nil
										mo.damagetime = nil
										return true
									end
								end
							end
						end
					end
				end,
	},

	["sonic_atk1"] = {
		name = "Spin Strike",
		type = ATK_STRIKE,
		power = 35,
		accuracy = 85,
		critical = 7, -- was 7
		target = TGT_ENEMY,
		cost = CST_HP,
		cost = 0,
		desc = "A fierce spin kick\nfollowed by a Drop Dash.",
		anim_norepel = true,	-- do not bounce back our ANIMATION
		physical = true,	-- don't play the summoning anim for phys attacks, duh
		anim = 	function(mo, targets, hittargets, timer)
					local target = targets[1]
					local atarget = hittargets[1]
					if timer == 1
						ANIM_set(mo, mo.anim_run, true)
						mo.reachedtarget = false	-- yeah we can use variables here that you like it or not :^)

						local cx = target.x + 168*cos(target.angle + ANG1*20)
						local cy = target.y + 168*sin(target.angle + ANG1*20)
						CAM_goto(server.P_BattleStatus[mo.battlen].cam, cx, cy, target.z + FRACUNIT*30, 70*FRACUNIT)
						CAM_angle(server.P_BattleStatus[mo.battlen].cam, R_PointToAngle2(cx, cy, target.x, target.y))
						S_StartSound(mo, sfx_zoom)
					end

					if not mo.reachedtarget
						mo.angle = R_PointToAngle2(mo.x, mo.y, target.x, target.y)
						P_InstaThrust(mo, mo.angle, FRACUNIT*36)
						if R_PointToDist2(mo.x, mo.y, target.x, target.y) < FRACUNIT*36
							ANIM_set(mo, mo.anim_atk, true)
							localquake(mo.battlen, FRACUNIT*8, 4)
							mo.reachedtarget = true
							P_InstaThrust(mo, mo.angle, -FRACUNIT*6)
							mo.momz = 7*FRACUNIT
							playSound(mo.battlen, sfx_phys)
							for i = 1, 2
								createSplat(mo)
							end
						end
					else

						if P_IsObjectOnGround(mo)
						and not mo.momz
						and not mo.damagetime
							mo.damagetime = 1
							mo.momz = FRACUNIT
							P_InstaThrust(mo, mo.angle, FRACUNIT*90)
							S_StartSound(mo, sfx_spin)

						elseif mo.damagetime
							local trail = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
							trail.color = mo.color
							mo.damagetime = $+1
							if mo.damagetime == 2
								damageObject(atarget)
								localquake(mo.battlen, FRACUNIT*7, 4)
								playSound(mo.battlen, sfx_phys)
								for i = 1, 2
									createSplat(mo)
								end
							elseif mo.damagetime == 50
								mo.reachedtarget = nil
								mo.damagetime = nil
								return true
							end
						end
					end
				end,
	critanim = 	function(mo, targets, hittargets, timer)
					local target = targets[1]
					local atarget = hittargets[1]
					if timer == 1
						ANIM_set(mo, mo.anim_run, true)
						mo.reachedtarget = false	-- yeah we can use variables here that you like it or not :^)

						local cx = target.x + 168*cos(target.angle + ANG1*20)
						local cy = target.y + 168*sin(target.angle + ANG1*20)
						CAM_goto(server.P_BattleStatus[mo.battlen].cam, cx, cy, target.z + FRACUNIT*30, 70*FRACUNIT)
						CAM_angle(server.P_BattleStatus[mo.battlen].cam, R_PointToAngle2(cx, cy, target.x, target.y))
						S_StartSound(mo, sfx_zoom)
					end

					if not mo.reachedtarget
						mo.angle = R_PointToAngle2(mo.x, mo.y, target.x, target.y)
						P_InstaThrust(mo, mo.angle, FRACUNIT*36)
						if R_PointToDist2(mo.x, mo.y, target.x, target.y) < FRACUNIT*36
							ANIM_set(mo, mo.anim_atk, true)
							localquake(mo.battlen, FRACUNIT*8, 4)
							mo.reachedtarget = true
							P_InstaThrust(mo, mo.angle, -FRACUNIT*7)
							mo.momz = 8*FRACUNIT
							playSound(mo.battlen, sfx_phys)
							for i = 1, 2
								createSplat(mo)
							end
						end
					else
						if P_IsObjectOnGround(mo)
						and not mo.momz
						and not mo.damagetime
							-- move camera instantly
							local cam = server.P_BattleStatus[mo.battlen].cam

							local cx = mo.x + 128*cos(mo.angle - ANG1*25)
							local cy = mo.y + 128*sin(mo.angle - ANG1*25)
							P_TeleportMove(cam, cx, cy, mo.z + FRACUNIT*16)
							server.P_BattleStatus[mo.battlen].cam.angle = R_PointToAngle2(cam.x, cam.y, mo.x, mo.y)

							-- now make it zoom out a little
							CAM_goto(cam, cam.x-24*cos(cam.angle), cam.y-24*sin(cam.angle), cam.z+FRACUNIT*5, 1*FRACUNIT)

							-- setup sonic
							mo.damagetime = 1
							mo.momx, mo.momy, mo.momz = 0, 0, 0 -- stop momentum, start spindash
							ANIM_set(mo, mo.anim_special1, true)
							S_StartSound(mo, sfx_spndsh)
						elseif mo.damagetime
							mo.damagetime = $+1
							-- rev animation
							if mo.damagetime == 13 or mo.damagetime == 21 or mo.damagetime == 28
								--local revSounds = {sfx_sncsd1, sfx_sncsd2, sfx_sncsd3}

								mo.rev = $ and $+1 or 1
								S_StartSound(mo, sfx_spndsh)
								-- at 3rd rev speed up use the faster spindash anim
								ANIM_set(mo, mo.rev == 3 and mo.anim_special2 or mo.anim_special1, true)
							end
							-- start spindash
							if mo.damagetime >= 35
								if mo.damagetime == 35 -- nyoom
									-- camera
									local cx = target.x + 512*cos(target.angle + ANG1*20)
									local cy = target.y + 512*sin(target.angle + ANG1*20)
									CAM_goto(server.P_BattleStatus[mo.battlen].cam, cx, cy, target.z + FRACUNIT*30, 128*FRACUNIT)
									CAM_angle(server.P_BattleStatus[mo.battlen].cam, R_PointToAngle2(cx, cy, target.x, target.y), ANG1*16)

									-- sonic
									S_StartSound(mo, sfx_zoom)
									P_InstaThrust(mo, mo.angle, FRACUNIT*120)
									ANIM_set(mo, mo.anim_atk, true)
								else
									local trail = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
									trail.color = mo.color
									if mo.damagetime == 36
										damageObject(atarget)
										P_SetObjectMomZ(atarget, 5*FRACUNIT)
										localquake(mo.battlen, FRACUNIT*12, 7)
										playSound(mo.battlen, sfx_phys)
										for i = 1, 4
											createSplat(mo)
										end
									elseif mo.damagetime == 85
										mo.rev = nil
										mo.reachedtarget = nil
										mo.damagetime = nil
										return true
									end
								end
							end
						end
					end
				end,
	},

	["recarm"] = {
		name = "Recarm",
		type = ATK_HEAL,
		costtype = CST_SP,
		cost = 15,
		norandom = true,	-- Don't allow this move to be selected in random pvp skills
		desc = "Revive a fallen ally \nwith half HP",
		target = TGT_DEAD,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			-- first of all, get this boy back in our party
			if timer == 1
				revivePlayer(target)
			end

			if timer == 10
				-- spawn 1up monitor
				local b = P_SpawnMobj(target.x, target.y, target.z+300*FRACUNIT, MT_DUMMY)
				b.state = S_AOADUST1
				b.frame = A|FF_FULLBRIGHT
				b.scale = FRACUNIT*3
				b.destscale = FRACUNIT/12

				mo.recarmtv = P_SpawnMobj(target.x, target.y, target.z + FRACUNIT*300, MT_DUMMY)
				mo.recarmtv.momz = -FRACUNIT*10
				mo.recarmtv.flags = MF_NOBLOCKMAP
				mo.recarmtv.tics = -1
				mo.recarmtv.sprite = SPR_TV1P
				mo.recarmtv.frame = A

			elseif timer >= 10 and timer < 80
				-- tv anim
				if leveltime%3 == 0
					mo.recarmtv.sprite = SPR_MSTV
					mo.recarmtv.frame = A
				else
					mo.recarmtv.sprite = SPR_TV1P
					mo.recarmtv.frame = A
					local ol = P_SpawnMobj(mo.recarmtv.x, mo.recarmtv.y, mo.recarmtv.z, MT_OVERLAY)
					ol.state = S_PLAY_BOX1
					mo.recarmtv.target = ol
					ol.target = mo.recarmtv
					ol.sprite = SPR_PLAY
					ol.sprite2 = target.sprite2
					ol.skin = target.skin
					ol.state = S_PLAY_BOX1
					ol.color = target.color
					ol.fuse = 1
				end
			elseif timer == 80
				-- explode the box and revive us!

				playSound(mo.battlen, sfx_pop)
				for i=1,16
					local b = P_SpawnMobj(target.x, target.y, target.z+20*FRACUNIT, MT_DUMMY)
					b.momx = P_RandomRange(-8, 8)*FRACUNIT
					b.momy = P_RandomRange(-8, 8)*FRACUNIT
					b.momz = P_RandomRange(-8, 8)*FRACUNIT
					b.state = S_AOADUST1
					b.frame = A|FF_FULLBRIGHT
					b.scale = FRACUNIT*3
					b.destscale = FRACUNIT/12
				end
				local heals = target.maxhp/2
				damageObject(target, -heals)
				playSound(mo.battlen, sfx_heal2)

				ANIM_set(target, target.anim_revive, true)
				target.momz = 10*FRACUNIT

				P_RemoveMobj(mo.recarmtv.target)
				P_RemoveMobj(mo.recarmtv)
				mo.recarmtv = nil

			elseif timer == 128
				return true

			elseif timer > 80 and P_IsObjectOnGround(target)
				ANIM_set(target, target.anim_stand, true)
			end
		end,
	},

	["samarecarm"] = {
		name = "Samarecarm",
		type = ATK_HEAL,
		costtype = CST_SP,
		cost = 30,
		norandom = true,	-- Don't allow this move to be selected in random pvp skills
		desc = "Revive a fallen ally \nwith full HP",
		target = TGT_DEAD,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			-- first of all, get this boy back in our party
			if timer == 1
				revivePlayer(target)
			end

			if timer == 10
				-- spawn 1up monitor
				local b = P_SpawnMobj(target.x, target.y, target.z+300*FRACUNIT, MT_DUMMY)
				b.state = S_AOADUST1
				b.frame = A|FF_FULLBRIGHT
				b.scale = FRACUNIT*3
				b.destscale = FRACUNIT/12

				mo.recarmtv = P_SpawnMobj(target.x, target.y, target.z + FRACUNIT*300, MT_DUMMY)
				mo.recarmtv.momz = -FRACUNIT*10
				mo.recarmtv.flags = MF_NOBLOCKMAP
				mo.recarmtv.tics = -1
				mo.recarmtv.sprite = SPR_TV1P
				mo.recarmtv.frame = A

			elseif timer >= 10 and timer < 80
				-- tv anim
				if leveltime%3 == 0
					mo.recarmtv.sprite = SPR_MSTV
					mo.recarmtv.frame = A
				else
					mo.recarmtv.sprite = SPR_TV1P
					mo.recarmtv.frame = A
					local ol = P_SpawnMobj(mo.recarmtv.x, mo.recarmtv.y, mo.recarmtv.z, MT_OVERLAY)
					ol.state = S_PLAY_BOX1
					mo.recarmtv.target = ol
					ol.target = mo.recarmtv
					ol.sprite = SPR_PLAY
					ol.sprite2 = target.sprite2
					ol.skin = target.skin
					ol.state = S_PLAY_BOX1
					ol.color = target.color
					ol.fuse = 1
				end
			elseif timer == 80
				-- explode the box and revive us!

				playSound(mo.battlen, sfx_pop)
				for i=1,16
					local b = P_SpawnMobj(target.x, target.y, target.z+20*FRACUNIT, MT_DUMMY)
					b.momx = P_RandomRange(-8, 8)*FRACUNIT
					b.momy = P_RandomRange(-8, 8)*FRACUNIT
					b.momz = P_RandomRange(-8, 8)*FRACUNIT
					b.state = S_AOADUST1
					b.frame = A|FF_FULLBRIGHT
					b.scale = FRACUNIT*3
					b.destscale = FRACUNIT/12
				end
				local heals = target.maxhp
				damageObject(target, -heals)
				playSound(mo.battlen, sfx_heal2)

				ANIM_set(target, target.anim_revive, true)
				target.momz = 10*FRACUNIT

				P_RemoveMobj(mo.recarmtv.target)
				P_RemoveMobj(mo.recarmtv)
				mo.recarmtv = nil

			elseif timer == 128
				return true

			elseif timer > 80 and P_IsObjectOnGround(target)
				ANIM_set(target, target.anim_stand, true)
			end
		end,
	},

	["baton pass"] = {
		name = "Baton pass",
		type = ATK_SUPPORT,
		costtype = CST_SP,
		cost = 0,
		norandom = true,	-- Don't allow this move to be selected in random pvp skills
		desc = "Give your 1more to an ally, \nincreasing their attack and healing.",

		hudfunc = function(v, mo, timer)

			local target = mo.targets[1]

			local firstt = TICRATE - timer
			local t = (TICRATE - (firstt*2))
			local t2 = (t<<FRACBITS) /3
			local t3 = t2

			-- circles, or something!
			local scale = t*FRACUNIT/6
			local trflag = V_70TRANS
			if firstt < 15
				trflag = V_90TRANS - (V_10TRANS*(mo.onemore/5))
			end
			if scale > 0	-- lol negative scales
			and timer < TICRATE
				v.drawScaled(160<<FRACBITS, 100<<FRACBITS, scale, v.cachePatch("H_1M_B"), trflag)
				v.drawScaled(160<<FRACBITS, 100<<FRACBITS, scale, v.cachePatch("H_1M_C"))
			end

			t3 = FixedMul(t3, t3)
			t3 = $+ FixedMul(t3, t2)

			-- draw chars:
			local pp = v.cachePatch(charStats[mo.stats] and charStats[mo.stats].hudaoa or "")
			if mo.status_condition == COND_SUPER
			and charStats[mo.stats] and charStats[mo.stats].hudsaoa
				pp = v.cachePatch(charStats[mo.skin].hudsaoa)	-- super players
			end

			v.drawScaled((150)<<FRACBITS + t3/3, (80)<<FRACBITS +t3/8, FRACUNIT/2, pp, V_SNAPTOLEFT, v.getColormap(TC_DEFAULT, mo.color))
			pp = v.cachePatch(charStats[target.stats] and charStats[target.stats].hudaoa or "")
			if target.status_condition == COND_SUPER
				pp = v.cachePatch(charStats[target.stats] and charStats[target.stats].hudsaoa or "")
			end

			v.drawScaled((150)<<FRACBITS - t3/3, (80)<<FRACBITS -t3/7, FRACUNIT/2, pp, V_SNAPTOLEFT, v.getColormap(TC_DEFAULT, target.color))

			v.drawScaled((130)<<FRACBITS +t3/3, (80)<<FRACBITS +t3/8, FRACUNIT/2, v.cachePatch("H_BPASS1"), V_SNAPTOLEFT)
			v.drawScaled((123)<<FRACBITS -t3/3, (93)<<FRACBITS -t3/7, FRACUNIT/2, v.cachePatch("H_BPASS2"), V_SNAPTOLEFT)
		end,

		nocast = 	function(targets, n)	-- we can't cast this skill if this function returns true
						local target = targets[n]
						if target.acted
							BTL_logMessage(targets[1].battlen, target.name.." has already acted this turn.")
							return true
						elseif target.down
							BTL_logMessage(targets[1].battlen, target.name.." is down.")
							return true
						end
					end,

		target = TGT_ALLY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == TICRATE/2
				playSound(mo.battlen, sfx_1more)
			end

			if timer >= 40
			and timer < 60
				if timer == 40
					playSound(mo.battlen, sfx_buff)

					local buff = mo.batonpassbuff or 0

					target.batonpassbuff = buff + 33

					if target.batonpassbuff <= 50
						BTL_logMessage(targets[1].battlen, "Attack and recovery up!")
					elseif target.batonpassbuff <= 70
						BTL_logMessage(targets[1].battlen, "Attack and recovery way up!")
					else
						BTL_logMessage(targets[1].battlen, "Attack and recovery maxed out!")
					end
				end
				summonAura(target, SKINCOLOR_ORANGE)
			end
			if timer == 80
				mo.batonpassto = target
				fillEmeraldGauge(mo, 35)	-- baton passes are great at filling the meter!
				return true	-- that'll do
			end
		end,
	},

	["bronzering"] = {
		name = "Bronze Ring",
		type = ATK_HEAL,
		costtype = CST_SP,
		cost = 2,
		power = 20,
		desc = "Low HP recovery to one ally",
		nocast = 	function(targets, n)	-- we can't cast this skill if this function returns true
						local target = targets[n]
						if target.hp >= target.maxhp
							BTL_logMessage(targets[1].battlen, "No further effects.")
							return true
						end
					end,

		target = TGT_ALLY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 20
				target.heal_rings = {}
			elseif timer >= 21
			and timer < 70
				if timer < 40
					--for i = 1, 2
						local x, y, z = mo.x + P_RandomRange(-400,400)<<FRACBITS, mo.y + P_RandomRange(-400,400)<<FRACBITS, mo.z + P_RandomRange(0, 400)<<FRACBITS
						local r = P_SpawnMobj(x, y, z, MT_DUMMY)
						r.flags = MF_NOGRAVITY|MF_NOCLIPHEIGHT
						r.state = S_RING
						r.target = target
						r.tracer = target

						local dist = P_AproxDistance(P_AproxDistance(target.x - r.x, target.y - r.y), target.z - r.z)
						r.momx = FixedMul(FixedDiv(target.x - r.x, dist), 32<<FRACBITS)
						r.momy = FixedMul(FixedDiv(target.y - r.y, dist), 32<<FRACBITS)
						r.momz = FixedMul(FixedDiv(target.z - r.z, dist), 32<<FRACBITS)
						r.fuse = 20

						--A_HomingChase(r, FRACUNIT*32)
						r.scale = 1
						r.color = SKINCOLOR_BROWN
						r.colorized = true
						r.destscale = FRACUNIT
						r.scalespeed = FRACUNIT/4
						target.heal_rings[#target.heal_rings+1] = r
					--end
				end
				for i = 1, #target.heal_rings
					local r = target.heal_rings[i]
					if not r or not r.valid continue end
					if R_PointToDist2(target.x, target.y, r.x, r.y) < 40<<FRACBITS
					and abs(r.z - mo.z) < 40<<FRACBITS
						playSound(mo.battlen, sfx_itemup)
						r.state = S_SPRK1
						table.remove(target.heal_rings, i)
						i = $-1
					end
				end

			elseif timer == 70
				P_SpawnMobj(target.x, target.y, target.z, MT_IVSP)
				playSound(mo.battlen, sfx_heal)
				damageObject(target, -20)
			elseif timer == 120
				return true
			end
		end,
	},

	["dia"] = {
		name = "Dia",
		type = ATK_HEAL,
		costtype = CST_SP,
		cost = 4,
		power = 50,
		desc = "Slight HP recovery to one ally",
		nocast = 	function(targets, n)	-- we can't cast this skill if this function returns true
						local target = targets[n]
						if target.hp >= target.maxhp
							BTL_logMessage(targets[1].battlen, "No further effects.")
							return true
						end

						-- very specific for the turorial
						local btl = server.P_BattleStatus[1]
						if btl.tutorial_zio
							BTL_logMessage(1, "Amy told you to use \x82Zio\x80.")
							return true
						end
					end,

		target = TGT_ALLY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 20
				target.heal_rings = {}
			elseif timer >= 21
			and timer < 70
				if timer < 40
					--for i = 1, 2
						local x, y, z = mo.x + P_RandomRange(-400,400)<<FRACBITS, mo.y + P_RandomRange(-400,400)<<FRACBITS, mo.z + P_RandomRange(0, 400)<<FRACBITS
						local r = P_SpawnMobj(x, y, z, MT_DUMMY)
						r.flags = MF_NOGRAVITY|MF_NOCLIPHEIGHT
						r.state = S_RING
						r.target = target
						r.tracer = target

						local dist = P_AproxDistance(P_AproxDistance(target.x - r.x, target.y - r.y), target.z - r.z)
						r.momx = FixedMul(FixedDiv(target.x - r.x, dist), 32<<FRACBITS)
						r.momy = FixedMul(FixedDiv(target.y - r.y, dist), 32<<FRACBITS)
						r.momz = FixedMul(FixedDiv(target.z - r.z, dist), 32<<FRACBITS)
						r.fuse = 20

						--A_HomingChase(r, FRACUNIT*32)
						r.scale = 1
						r.destscale = FRACUNIT
						r.scalespeed = FRACUNIT/4
						target.heal_rings[#target.heal_rings+1] = r
					--end
				end
				for i = 1, #target.heal_rings
					local r = target.heal_rings[i]
					if not r or not r.valid continue end
					if R_PointToDist2(target.x, target.y, r.x, r.y) < 40<<FRACBITS
					and abs(r.z - mo.z) < 40<<FRACBITS
						playSound(mo.battlen, sfx_itemup)
						r.state = S_SPRK1
						table.remove(target.heal_rings, i)
						i = $-1
					end
				end

			elseif timer == 70
				P_SpawnMobj(target.x, target.y, target.z, MT_IVSP)
				local heals = P_RandomRange(50, 60)
				playSound(mo.battlen, sfx_heal)
				damageObject(target, -heals)
			elseif timer == 120
				return true
			end
		end,
	},

	["media"] = {
		name = "Media",
		type = ATK_HEAL,
		costtype = CST_SP,
		cost = 8,
		power = 50,
		desc = "Slight HP recovery to all allies",
		nocast = 	function(targets, n)	-- we can't cast this skill if this function returns true
						local noheal = 0
						for i = 1, #targets
							if targets[i].hp >= targets[i].maxhp
								noheal = $+1
							end
						end
						if noheal >= #targets
							BTL_logMessage(targets[1].battlen, "No further effects.")
							return true
						end
					end,

		target = TGT_ALLALLIES,
		anim = function(mo, targets, hittargets, timer)

			for e = 1, #targets

				local time = timer - 10*(e-1)

				local target = targets[e]

				if time == 20
					target.heal_rings = {}
				elseif time >= 21
				and time < 70
					if time < 40
						if leveltime%2
							local x, y, z = mo.x + P_RandomRange(-400,400)<<FRACBITS, mo.y + P_RandomRange(-400,400)<<FRACBITS, mo.z + P_RandomRange(0, 400)<<FRACBITS
							local r = P_SpawnMobj(x, y, z, MT_DUMMY)
							r.flags = MF_NOGRAVITY|MF_NOCLIPHEIGHT
							r.state = S_RING
							r.target = target
							r.tracer = target

							local dist = P_AproxDistance(P_AproxDistance(target.x - r.x, target.y - r.y), target.z - r.z)
							r.momx = FixedMul(FixedDiv(target.x - r.x, dist), 32<<FRACBITS)
							r.momy = FixedMul(FixedDiv(target.y - r.y, dist), 32<<FRACBITS)
							r.momz = FixedMul(FixedDiv(target.z - r.z, dist), 32<<FRACBITS)
							r.fuse = 20

							--A_HomingChase(r, FRACUNIT*32)
							r.scale = 1
							r.destscale = FRACUNIT
							r.scalespeed = FRACUNIT/4
							target.heal_rings[#target.heal_rings+1] = r
						end
					end
					for i = 1, #target.heal_rings
						local r = target.heal_rings[i]
						if not r or not r.valid continue end
						if R_PointToDist2(target.x, target.y, r.x, r.y) < 40<<FRACBITS
						and abs(r.z - mo.z) < 40<<FRACBITS
							playSound(mo.battlen, sfx_itemup)
							r.state = S_SPRK1
							table.remove(target.heal_rings, i)
							i = $-1
						end
					end

				elseif time == 70
					P_SpawnMobj(target.x, target.y, target.z, MT_IVSP)
					local heals = P_RandomRange(50, 60)
					playSound(mo.battlen, sfx_heal)
					damageObject(target, -heals)
				end
			end

			if timer == 110 + (#targets-1)*10
				return true
			end
		end,
	},

	["diarama"] = {
		name = "Diarama",
		type = ATK_HEAL,
		costtype = CST_SP,
		cost = 8,
		power = 150,
		desc = "Moderate HP recovery to one ally",
		nocast = 	function(targets, n)	-- we can't cast this skill if this function returns true
						local target = targets[n]
						if target.hp >= target.maxhp
							BTL_logMessage(targets[1].battlen, "No further effects.")
							return true
						end
					end,

		target = TGT_ALLY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 20
				target.heal_rings = {}
			elseif timer >= 21
			and timer < 70
				if timer < 40
					for i = 1, 2
						local x, y, z = mo.x + P_RandomRange(-400,400)<<FRACBITS, mo.y + P_RandomRange(-400,400)<<FRACBITS, mo.z + P_RandomRange(0, 400)<<FRACBITS
						local r = P_SpawnMobj(x, y, z, MT_DUMMY)
						r.flags = MF_NOGRAVITY|MF_NOCLIPHEIGHT
						r.state = S_RING
						r.target = target
						r.tracer = target

						local dist = P_AproxDistance(P_AproxDistance(target.x - r.x, target.y - r.y), target.z - r.z)
						r.momx = FixedMul(FixedDiv(target.x - r.x, dist), 32<<FRACBITS)
						r.momy = FixedMul(FixedDiv(target.y - r.y, dist), 32<<FRACBITS)
						r.momz = FixedMul(FixedDiv(target.z - r.z, dist), 32<<FRACBITS)
						r.fuse = 20

						--A_HomingChase(r, FRACUNIT*32)
						r.scale = 1
						r.destscale = FRACUNIT
						r.scalespeed = FRACUNIT/4
						target.heal_rings[#target.heal_rings+1] = r
					end
				end
				for i = 1, #target.heal_rings
					local r = target.heal_rings[i]
					if not r or not r.valid continue end
					if R_PointToDist2(target.x, target.y, r.x, r.y) < 40<<FRACBITS
					and abs(r.z - mo.z) < 40<<FRACBITS
						playSound(mo.battlen, sfx_itemup)
						r.state = S_SPRK1
						table.remove(target.heal_rings, i)
						i = $-1
					end
				end

			elseif timer == 70
				P_SpawnMobj(target.x, target.y, target.z, MT_IVSP)
				local heals = P_RandomRange(150, 160)
				playSound(mo.battlen, sfx_heal2)
				damageObject(target, -heals)
			elseif timer == 120
				return true
			end
		end,
	},

	["mediarama"] = {
		name = "Mediarama",
		type = ATK_HEAL,
		costtype = CST_SP,
		cost = 16,
		power = 150,
		desc = "Moderate HP recovery to all allies",
		nocast = 	function(targets, n)	-- we can't cast this skill if this function returns true
						local noheal = 0
						for i = 1, #targets
							if targets[i].hp >= targets[i].maxhp
								noheal = $+1
							end
						end
						if noheal >= #targets
							BTL_logMessage(targets[1].battlen, "No further effects.")
							return true
						end
					end,

		target = TGT_ALLALLIES,
		anim = function(mo, targets, hittargets, timer)

			for e = 1, #targets

				local time = timer - 10*(e-1)

				local target = targets[e]

				if time == 20
					target.heal_rings = {}
				elseif time >= 21
				and time < 70
					if time < 40
							local x, y, z = mo.x + P_RandomRange(-400,400)<<FRACBITS, mo.y + P_RandomRange(-400,400)<<FRACBITS, mo.z + P_RandomRange(0, 400)<<FRACBITS
							local r = P_SpawnMobj(x, y, z, MT_DUMMY)
							r.flags = MF_NOGRAVITY|MF_NOCLIPHEIGHT
							r.state = S_RING
							r.target = target
							r.tracer = target

							local dist = P_AproxDistance(P_AproxDistance(target.x - r.x, target.y - r.y), target.z - r.z)
							r.momx = FixedMul(FixedDiv(target.x - r.x, dist), 32<<FRACBITS)
							r.momy = FixedMul(FixedDiv(target.y - r.y, dist), 32<<FRACBITS)
							r.momz = FixedMul(FixedDiv(target.z - r.z, dist), 32<<FRACBITS)
							r.fuse = 20

							--A_HomingChase(r, FRACUNIT*32)
							r.scale = 1
							r.destscale = FRACUNIT
							r.scalespeed = FRACUNIT/4
							target.heal_rings[#target.heal_rings+1] = r
					end
					for i = 1, #target.heal_rings
						local r = target.heal_rings[i]
						if not r or not r.valid continue end
						if R_PointToDist2(target.x, target.y, r.x, r.y) < 40<<FRACBITS
						and abs(r.z - mo.z) < 40<<FRACBITS
							playSound(mo.battlen, sfx_itemup)
							r.state = S_SPRK1
							table.remove(target.heal_rings, i)
							i = $-1
						end
					end

				elseif time == 70
					P_SpawnMobj(target.x, target.y, target.z, MT_IVSP)
					local heals = P_RandomRange(150, 160)
					playSound(mo.battlen, sfx_heal2)
					damageObject(target, -heals)
				end
			end

			if timer == 110 + (#targets-1)*10
				return true
			end
		end,
	},

	["diarahan"] = {
		name = "Diarahan",
		type = ATK_HEAL,
		costtype = CST_SP,
		cost = 16,
		power = 999,
		desc = "Full HP recovery to one ally",
		nocast = 	function(targets, n)	-- we can't cast this skill if this function returns true
						local target = targets[n]
						if target.hp >= target.maxhp
							BTL_logMessage(targets[1].battlen, "No further effects.")
							return true
						end
					end,

		target = TGT_ALLY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 20
				target.heal_rings = {}
			elseif timer >= 21
			and timer < 70
				if timer < 40
					for i = 1, 3
						local x, y, z = mo.x + P_RandomRange(-400,400)<<FRACBITS, mo.y + P_RandomRange(-400,400)<<FRACBITS, mo.z + P_RandomRange(0, 400)<<FRACBITS
						local r = P_SpawnMobj(x, y, z, MT_DUMMY)
						r.flags = MF_NOGRAVITY|MF_NOCLIPHEIGHT
						r.state = S_RING
						r.target = target
						r.tracer = target

						local dist = P_AproxDistance(P_AproxDistance(target.x - r.x, target.y - r.y), target.z - r.z)
						r.momx = FixedMul(FixedDiv(target.x - r.x, dist), 32<<FRACBITS)
						r.momy = FixedMul(FixedDiv(target.y - r.y, dist), 32<<FRACBITS)
						r.momz = FixedMul(FixedDiv(target.z - r.z, dist), 32<<FRACBITS)
						r.fuse = 20

						--A_HomingChase(r, FRACUNIT*32)
						r.scale = 1
						r.destscale = FRACUNIT
						r.scalespeed = FRACUNIT/4
						target.heal_rings[#target.heal_rings+1] = r
					end
				end
				for i = 1, #target.heal_rings
					local r = target.heal_rings[i]
					if not r or not r.valid continue end
					if R_PointToDist2(target.x, target.y, r.x, r.y) < 40<<FRACBITS
					and abs(r.z - mo.z) < 40<<FRACBITS
						playSound(mo.battlen, sfx_itemup)
						r.state = S_SPRK1
						table.remove(target.heal_rings, i)
						i = $-1
					end
				end

			elseif timer == 70
				P_SpawnMobj(target.x, target.y, target.z, MT_IVSP)
				local heals = target.maxhp
				playSound(mo.battlen, sfx_heal3)
				damageObject(target, -heals)
			elseif timer == 120
				return true
			end
		end,
	},

	["mediarahan"] = {
		name = "Mediarahan",
		type = ATK_HEAL,
		costtype = CST_SP,
		cost = 32,
		power = 999,
		desc = "Full HP recovery to all allies",
		nocast = 	function(targets, n)	-- we can't cast this skill if this function returns true
						local noheal = 0
						for i = 1, #targets
							if targets[i].hp >= targets[i].maxhp
								noheal = $+1
							end
						end
						if noheal >= #targets
							BTL_logMessage(targets[1].battlen, "No further effects.")
							return true
						end
					end,

		target = TGT_ALLALLIES,
		anim = function(mo, targets, hittargets, timer)

			for e = 1, #targets

				local time = timer - 10*(e-1)

				local target = targets[e]

				if time == 20
					target.heal_rings = {}
				elseif time >= 21
				and time < 70
					if time < 40
						for i = 1,2
							local x, y, z = mo.x + P_RandomRange(-400,400)<<FRACBITS, mo.y + P_RandomRange(-400,400)<<FRACBITS, mo.z + P_RandomRange(0, 400)<<FRACBITS
							local r = P_SpawnMobj(x, y, z, MT_DUMMY)
							r.flags = MF_NOGRAVITY|MF_NOCLIPHEIGHT
							r.state = S_RING
							r.target = target
							r.tracer = target

							local dist = P_AproxDistance(P_AproxDistance(target.x - r.x, target.y - r.y), target.z - r.z)
							r.momx = FixedMul(FixedDiv(target.x - r.x, dist), 32<<FRACBITS)
							r.momy = FixedMul(FixedDiv(target.y - r.y, dist), 32<<FRACBITS)
							r.momz = FixedMul(FixedDiv(target.z - r.z, dist), 32<<FRACBITS)
							r.fuse = 20

							--A_HomingChase(r, FRACUNIT*32)
							r.scale = 1
							r.destscale = FRACUNIT
							r.scalespeed = FRACUNIT/4
							target.heal_rings[#target.heal_rings+1] = r
						end
					end
					for i = 1, #target.heal_rings
						local r = target.heal_rings[i]
						if not r or not r.valid continue end
						if R_PointToDist2(target.x, target.y, r.x, r.y) < 40<<FRACBITS
						and abs(r.z - mo.z) < 40<<FRACBITS
							playSound(mo.battlen, sfx_itemup)
							r.state = S_SPRK1
							table.remove(target.heal_rings, i)
							i = $-1
						end
					end

				elseif time == 70
					P_SpawnMobj(target.x, target.y, target.z, MT_IVSP)
					local heals = target.maxhp
					playSound(mo.battlen, sfx_heal3)
					damageObject(target, -heals)
				end
			end

			if timer == 110 + (#targets-1)*10
				return true
			end
		end,
	},

	["soma"] = {
		name = "Soma",
		type = ATK_HEAL,
		costtype = CST_SP,
		cost = 32767,
		power = 999999,
		norandom = true,	-- Don't allow this move to be selected in random pvp skills
		soma = true,	-- for menus
		desc = "Stop hacking skills in, \nyou prick!",
		nocast = 	function(targets, n)	-- we can't cast this skill if this function returns true
						local noheal = 0
						for i = 1, #targets
							if targets[i].hp >= targets[i].maxhp
							and targets[i].sp >= targets[i].maxsp
							and not targets[i].status_condition
								noheal = $+1
							end
						end
						if noheal >= #targets
							BTL_logMessage(targets[1].battlen, "No further effects.")
							return true
						end
					end,

		target = TGT_ALLALLIES,
		anim = function(mo, targets, hittargets, timer)

			for e = 1, #targets

				local time = timer - 10*(e-1)

				local target = targets[e]

				if time == 20
					target.heal_rings = {}
				elseif time >= 21
				and time < 70
					if time < 40
						for i = 1,2
							local x, y, z = mo.x + P_RandomRange(-400,400)<<FRACBITS, mo.y + P_RandomRange(-400,400)<<FRACBITS, mo.z + P_RandomRange(0, 400)<<FRACBITS
							local r = P_SpawnMobj(x, y, z, MT_DUMMY)
							r.flags = MF_NOGRAVITY|MF_NOCLIPHEIGHT
							r.state = S_RING
							r.target = target
							r.tracer = target

							local dist = P_AproxDistance(P_AproxDistance(target.x - r.x, target.y - r.y), target.z - r.z)
							r.momx = FixedMul(FixedDiv(target.x - r.x, dist), 32<<FRACBITS)
							r.momy = FixedMul(FixedDiv(target.y - r.y, dist), 32<<FRACBITS)
							r.momz = FixedMul(FixedDiv(target.z - r.z, dist), 32<<FRACBITS)
							r.fuse = 20

							--A_HomingChase(r, FRACUNIT*32)
							r.scale = 1
							r.destscale = FRACUNIT
							r.scalespeed = FRACUNIT/4
							target.heal_rings[#target.heal_rings+1] = r
						end
					end
					for i = 1, #target.heal_rings
						local r = target.heal_rings[i]
						if not r or not r.valid continue end
						if R_PointToDist2(target.x, target.y, r.x, r.y) < 40<<FRACBITS
						and abs(r.z - mo.z) < 40<<FRACBITS
							playSound(mo.battlen, sfx_itemup)
							r.state = S_SPRK1
							table.remove(target.heal_rings, i)
							i = $-1
						end
					end

				elseif time == 70
					P_SpawnMobj(target.x, target.y, target.z, MT_IVSP)
					playSound(mo.battlen, sfx_heal4)
					damageObject(target, -99999)
					damageSP(target, -target.maxsp)
					if mo.status_condition and mo.status_condition < COND_HYPER
						cureStatus(target, true)
					end
				end
			end

			if timer == 110 + (#targets-1)*10
				return true
			end
		end,
	},

	["zioverse"] = {
		name = "Zioverse",
		type = ATK_ELEC,
		power = 100,
		accuracy = 999,
		costtype = CST_SP,
		cost = 12,
		desc = "Deploys a field that echoes 20%\nof single target damage\nto other enemies.",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)

			for k, e in ipairs(hittargets)
				local time = timer - 10*(k-1)
				local target = e
				if (time == 20)
					-- first one, the one behind
					local z1 = P_SpawnMobj(target.x, target.y, target.floorz, MT_DUMMY)
					z1.state, z1.scale, z1.color = S_LZIO11, target.scale*9/4, SKINCOLOR_TEAL
					z1.destscale = target.scale    -- this probably looks retarded at smaller scales from afar lmao
					-- second, the dominant in front
					local z2 = P_SpawnMobj(target.x, target.y, target.floorz, MT_DUMMY)
					z2.state, z2.scale, z2.color = S_LZIO21, target.scale*9/4, SKINCOLOR_GOLD
					z2.destscale = target.scale

					playSound(mo.battlen, sfx_zio1)
					damageObject(target)

					if target.damagestate ~= DMG_MISS
					and target.damagestate ~= DMG_BLOCK
					and target.damagestate ~= DMG_DRAIN
						startField(target, FLD_ZIOVERSE, 4)
					end

				end
			end
			if (timer == 60 + (#targets-1)*10)
				return true
			end
		end,
	},

	["zio"] = {
		name = "Zio",
		type = ATK_ELEC,
		power = 60,
		accuracy = 95,
		costtype = CST_SP,
		status = COND_SHOCK,
		statuschance = 5,
		cost = 4,
		desc = "Light Elec dmg to one enemy. \nMay inflict shock.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]
            if (timer == 20)
				-- first one, the one behind
				local z1 = P_SpawnMobj(target.x, target.y, target.floorz, MT_DUMMY)
                z1.state, z1.scale, z1.color = S_LZIO11, target.scale*9/4, SKINCOLOR_TEAL
                z1.destscale = target.scale    -- this probably looks retarded at smaller scales from afar lmao
				-- second, the dominant in front
				local z2 = P_SpawnMobj(target.x, target.y, target.floorz, MT_DUMMY)
				z2.state, z2.scale, z2.color = S_LZIO21, target.scale*9/4, SKINCOLOR_GOLD
				z2.destscale = target.scale

				playSound(mo.battlen, sfx_zio1)
				damageObject(target)
			elseif (timer == 60)
				return true
			end
		end,
	},

	["mazio"] = {
		name = "Mazio",
		type = ATK_ELEC,
		power = 60,
		accuracy = 90,
		costtype = CST_SP,
		status = COND_SHOCK,
		statuschance = 2,
		cost = 8,
		desc = "Light Elec dmg to all enemies. \nMay inflict shock.",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)
			for k, e in ipairs(hittargets)
				local time = timer - 10*(k-1)
				local target = e
				if (time == 20)
					-- first one, the one behind
					local z1 = P_SpawnMobj(target.x, target.y, target.floorz, MT_DUMMY)
					z1.state, z1.scale, z1.color = S_LZIO11, target.scale*9/4, SKINCOLOR_TEAL
					z1.destscale = target.scale    -- this probably looks retarded at smaller scales from afar lmao
					-- second, the dominant in front
					local z2 = P_SpawnMobj(target.x, target.y, target.floorz, MT_DUMMY)
					z2.state, z2.scale, z2.color = S_LZIO21, target.scale*9/4, SKINCOLOR_GOLD
					z2.destscale = target.scale

					playSound(mo.battlen, sfx_zio1)
					damageObject(target)
				end
			end
			if (timer == 60 + (#targets-1)*10)
				return true
			end
		end,
	},

	["zionga"] = {
		name = "Zionga",
		type = ATK_ELEC,
		power = 140,
		accuracy = 95,
		costtype = CST_SP,
		status = COND_SHOCK,
		statuschance = 5,
		cost = 8,
		desc = "Medium Elec dmg to one enemy. \nMay inflict shock.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]
			if (timer == 20)
				target.z_dangle = P_RandomRange(1, 359)*ANG1 -- default angle we'll base the second zio on
				local dist = 36+P_RandomRange(-6, 6)

				local z1 = P_SpawnMobj(target.x+(dist*cos(target.z_dangle)), target.y+(dist*sin(target.z_dangle)), target.floorz, MT_DUMMY)
				z1.state, z1.scale, z1.color = S_LZIO11, target.scale*9/4, SKINCOLOR_TEAL
				z1.destscale = target.scale
				local z2 = P_SpawnMobj(target.x+(dist*cos(target.z_dangle)), target.y+(dist*sin(target.z_dangle)), target.floorz, MT_DUMMY)
				z2.state, z2.scale, z2.color = S_LZIO21, target.scale*9/4, SKINCOLOR_GOLD
				z2.destscale = target.scale

				playSound(mo.battlen, sfx_zio1)
			elseif (timer == 27)
				local dist = 25+P_RandomRange(-6, 6)
				local angle = target.z_dangle+ANGLE_180+(P_RandomRange(-22, 22)*ANG1)

				local z1 = P_SpawnMobj(target.x+(dist*cos(angle)), target.y+(dist*sin(angle)), target.floorz, MT_DUMMY)
				z1.state, z1.scale, z1.color = S_LZIO11, target.scale*11/4, SKINCOLOR_TEAL
				z1.destscale = target.scale*5/4
				local z2 = P_SpawnMobj(target.x+(dist*cos(angle)), target.y+(dist*sin(angle)), target.floorz, MT_DUMMY)
				z2.state, z2.scale, z2.color = S_LZIO21, target.scale*11/4, SKINCOLOR_GOLD
				z2.destscale = target.scale*5/4

				playSound(mo.battlen, sfx_zio1)
			elseif (timer >= 42 and timer <= 56)
				if (timer == 42)
					local z1 = P_SpawnMobj(target.x, target.y, target.floorz, MT_DUMMY)
					z1.state, z1.scale, z1.color = S_LZIO11, target.scale*15/4, SKINCOLOR_TEAL
					z1.destscale = target.scale*3/2
					local z2 = P_SpawnMobj(target.x, target.y, target.floorz, MT_DUMMY)
					z2.state, z2.scale, z2.color = S_LZIO21, target.scale*15/4, SKINCOLOR_GOLD
					z2.destscale = target.scale*3/2

					playSound(mo.battlen, sfx_zio2)
					damageObject(target)
				end
				for i = 1, 2
					if not (timer%3)
						local angle = P_RandomRange(1, 359)*ANG1
						local dist = P_RandomRange(30, 36)

						local s = P_SpawnMobj(target.x+(dist*cos(angle)), target.y+(dist*sin(angle)), target.floorz, MT_DUMMY)
						s.state, s.color, s.scale = S_SSPK1, SKINCOLOR_WHITE, target.scale*2
						s.momz, s.destscale = P_RandomRange(5, 24)*FRACUNIT, FRACUNIT/6
						P_InstaThrust(s, angle, P_RandomRange(6, 8)*FRACUNIT)
					end
				end
			elseif (timer == 76)
				target.z_dangle = nil
				return true
			end
		end,
	},

	["mazionga"] = {
		name = "Mazionga",
		type = ATK_ELEC,
		power = 140,
		accuracy = 90,
		costtype = CST_SP,
		status = COND_SHOCK,
		statuschance = 2,
		cost = 16,
		desc = "Medium Elec dmg to all enemies. \nMay inflict shock.",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)
			for k, e in ipairs(hittargets)
				local time = timer - 14*(k-1)
				local target = e
				if (time == 20)
					target.z_dangle = P_RandomRange(1, 359)*ANG1 -- default angle we'll base the second zio on
					local dist = 36+P_RandomRange(-6, 6)

					local z1 = P_SpawnMobj(target.x+(dist*cos(target.z_dangle)), target.y+(dist*sin(target.z_dangle)), target.floorz, MT_DUMMY)
					z1.state, z1.scale, z1.color = S_LZIO11, target.scale*9/4, SKINCOLOR_TEAL
					z1.destscale = target.scale
					local z2 = P_SpawnMobj(target.x+(dist*cos(target.z_dangle)), target.y+(dist*sin(target.z_dangle)), target.floorz, MT_DUMMY)
					z2.state, z2.scale, z2.color = S_LZIO21, target.scale*9/4, SKINCOLOR_GOLD
					z2.destscale = target.scale

					playSound(mo.battlen, sfx_zio1)
				elseif (time == 27)
					local dist = 25+P_RandomRange(-6, 6)
					local angle = target.z_dangle+ANGLE_180+(P_RandomRange(-22, 22)*ANG1)

					local z1 = P_SpawnMobj(target.x+(dist*cos(angle)), target.y+(dist*sin(angle)), target.floorz, MT_DUMMY)
					z1.state, z1.scale, z1.color = S_LZIO11, target.scale*11/4, SKINCOLOR_TEAL
					z1.destscale = target.scale*5/4
					local z2 = P_SpawnMobj(target.x+(dist*cos(angle)), target.y+(dist*sin(angle)), target.floorz, MT_DUMMY)
					z2.state, z2.scale, z2.color = S_LZIO21, target.scale*11/4, SKINCOLOR_GOLD
					z2.destscale = target.scale*5/4

					playSound(mo.battlen, sfx_zio1)
				elseif (time >= 42 and time <= 56)
					if (time == 42)
						local z1 = P_SpawnMobj(target.x, target.y, target.floorz, MT_DUMMY)
						z1.state, z1.scale, z1.color = S_LZIO11, target.scale*15/4, SKINCOLOR_TEAL
						z1.destscale = target.scale*3/2
						local z2 = P_SpawnMobj(target.x, target.y, target.floorz, MT_DUMMY)
						z2.state, z2.scale, z2.color = S_LZIO21, target.scale*15/4, SKINCOLOR_GOLD
						z2.destscale = target.scale*3/2

						playSound(mo.battlen, sfx_zio2)
						damageObject(target)
					end
					for i = 1, 2
						if not (time%3)
							local angle = P_RandomRange(1, 359)*ANG1
							local dist = P_RandomRange(30, 36)

							local s = P_SpawnMobj(target.x+(dist*cos(angle)), target.y+(dist*sin(angle)), target.floorz, MT_DUMMY)
							s.state, s.color, s.scale = S_SSPK1, SKINCOLOR_WHITE, target.scale*2
							s.momz, s.destscale = P_RandomRange(5, 24)*FRACUNIT, FRACUNIT/6
							P_InstaThrust(s, angle, P_RandomRange(6, 8)*FRACUNIT)
						end
					end
				elseif (timer == 76 + (#targets-1)*14)
					target.z_dangle = nil
					return true
				end
			end
		end,
	},

	["ziodyne"] = {
		name = "Ziodyne",
		type = ATK_ELEC,
		power = 350,
		accuracy = 95,
		costtype = CST_SP,
		status = COND_SHOCK,
		statuschance = 5,
		cost = 12,
		desc = "Heavy Elec dmg to one enemy. \nMay inflict shock.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]
			if timer == 20
				lightningblast(target, SKINCOLOR_GOLD, FRACUNIT*3/2)
				localquake(mo.battlen, FRACUNIT*8, 8)
				damageObject(target)
			elseif timer == 60
				return true
			end
		end,
	},

	["maziodyne"] = {
		name = "Maziodyne",
		type = ATK_ELEC,
		power = 350,
		accuracy = 90,
		costtype = CST_SP,
		status = COND_SHOCK,
		statuschance = 2,
		cost = 24,
		desc = "Heavy Elec dmg to all enemies. \nMay inflict shock.",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)
			for i = 1, #hittargets
				local target = hittargets[i]
				if timer == 20 + 10*(i-1)
					lightningblast(target, SKINCOLOR_GOLD, FRACUNIT*3/2)
					localquake(mo.battlen, FRACUNIT*8, 8)
					damageObject(target)
				end
			end
			if timer == 60 + (10*(#hittargets-1))
				return true
			end
		end,
	},

	["thunder reign"] = {
		name = "Thunder Reign",
		type = ATK_ELEC,
		power = 650,
		accuracy = 100,
		costtype = CST_SP,
		status = COND_SHOCK,
		statuschance = 10,
		cost = 32,
		desc = "Severe Elec dmg to one enemy. \nHigh chance of shock.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 15
				playSound(mo.battlen, sfx_zio5)
			end

			if timer >= 16
			and timer <= 20
				local s = P_SpawnMobj(target.x, target.y, target.z + target.height/2, MT_THOK)
				s.tics = -1
				s.sprite = SPR_LZI1
				s.frame = F|FF_FULLBRIGHT|FF_TRANS70
				s.scale = mo.scale/2
				s.destscale = mo.scale*16
				s.scalespeed = mo.scale/(12-((timer-16)*2))
				s.blendmode = AST_ADD
				s.fuse = 70 - timer
			end

			if timer >= 16
			and timer <= 70
			and leveltime%3 == 0


				local range = 60
				if timer >= 50
					range = 100
				end

				local s = P_SpawnMobj(target.x + P_RandomRange(-range, range)*mo.scale, target.y + P_RandomRange(-range, range)*mo.scale, target.z + P_RandomRange(0, 100)*mo.scale, MT_SUPERSPARK)
			end

			if timer == 50
			or timer == 70
				for i = 1, #server.playerlist[mo.battlen]
					if server.playerlist[mo.battlen][i]
						P_FlashPal(server.playerlist[mo.battlen][i], 1, 2)
					end
				end
				localquake(mo.battlen, FRACUNIT*(timer == 50 and 16 or 32), 10)
			end

			if timer == 70
				lightningblast(target, SKINCOLOR_GOLD, FRACUNIT*3)
				damageObject(target)

				for i = 1, 10
					local range = 1024
					local z1 = P_SpawnMobj(target.x + P_RandomRange(-range, range)*mo.scale, target.y + P_RandomRange(-range, range)*mo.scale, target.z, MT_DUMMY)
					z1.state, z1.scale, z1.color = S_LZIO11, target.scale*9/4, SKINCOLOR_GOLD
					z1.destscale = target.scale
					z1.tics = $ + P_RandomRange(-1, 12)
				end

			elseif timer == 120
				return true
			end

		end,
	},

	["panta rhei"] = {
		name = "Panta Rhei",
		type = ATK_WIND,
		power = 650,
		accuracy = 95,
		costtype = CST_SP,
		cost = 24,
		desc = "Severe Wind dmg to one enemy.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)

				local target = hittargets[1]

				if timer == 1
					mo.blades = {}
					-- blades have an addtional vangle property.
					-- extravalue1 determines whether they spin forward or backwards

				elseif timer == 20

					-- spawn blades:

					local an = target.angle + ANG1*90
					playSound(mo.battlen, sfx_wind4)

					local b = P_SpawnMobj(target.x + 1024*cos(an), target.y + 1024*sin(an), target.z + 512*FRACUNIT, MT_DUMMY)
					b.vangle = ANG1*60
					b.state = S_INVISIBLE
					b.extravalue1 = 1
					b.extravalue2 = 16
					mo.blades[#mo.blades+1] = b
					b.momx = -(b.x - target.x)/b.extravalue2
					b.momy = -(b.y - target.y)/b.extravalue2
					b.momz = -(b.z - (target.z + 96*FRACUNIT))/b.extravalue2
					b.fuse = TICRATE*3

					b = P_SpawnMobj(target.x - 1024*cos(an), target.y - 1024*sin(an), target.z + 320*FRACUNIT, MT_DUMMY)
					b.vangle = -ANG1*30
					b.state = S_INVISIBLE
					b.extravalue1 = -1
					b.extravalue2 = 16
					mo.blades[#mo.blades+1] = b
					b.momx = -(b.x - target.x)/b.extravalue2
					b.momy = -(b.y - target.y)/b.extravalue2
					b.momz = -(b.z - (target.z + 96*FRACUNIT))/b.extravalue2
					b.fuse = TICRATE*3

				elseif timer == TICRATE*3 + 20
					damageObject(target)

				elseif timer == TICRATE*5
					return true
				end

				local i = #mo.blades
				while i
					local b = mo.blades[i]
					if not b or not b.valid
						table.remove(mo.blades, i)
						i = $-1
						continue
					end

					if R_PointToDist2(b.x, b.y, target.x, target.y) < 192*FRACUNIT
						b.momx = 0
						b.momy = 0
						b.momz = 0

						localquake(mo.battlen, FRACUNIT*10, 2)

						if leveltime%2 and i == 1

							for i=1,10
								local b = P_SpawnMobj(target.x, target.y, target.z+20*FRACUNIT, MT_DUMMY)
								b.momx = P_RandomRange(-35, 35)*FRACUNIT
								b.momy = P_RandomRange(-35, 35)*FRACUNIT
								b.momz = P_RandomRange(-35, 35)*FRACUNIT
								b.color = SKINCOLOR_RED
								b.frame = A|FF_FULLBRIGHT
								b.scale = FRACUNIT/2
								b.destscale = FRACUNIT/12
								b.tics = TICRATE/4
							end

							local s = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
							s.scale = FRACUNIT/4
							s.sprite = SPR_SLAS
							s.frame = I|TR_TRANS50 + P_RandomRange(0, 3)
							s.destscale = FRACUNIT*9
							s.scalespeed = FRACUNIT
							s.tics = TICRATE/3

						end
						if leveltime%8 == 0
							playSound(target.battlen, sfx_hit2)
							localquake(mo.battlen, FRACUNIT*32, 8)
						end
					end
					b.angle = $ + ANG1*24*b.extravalue1
					local addang = 360/6
						for j = 1, 6
							local sang = b.angle
							for k = 1, 4

								local sx = b.x + (k-1)*8*cos(sang + (j-1)*addang*ANG1)
								local sy = b.y + (k-1)*8*sin(sang + (j-1)*addang*ANG1)
								local sz = b.z + (k-1)*8*FixedMul(cos(sang + (j-1)*addang*ANG1), sin(b.vangle))

								local p = P_SpawnMobj(sx, sy, sz, MT_DUMMY)
								p.tics = TICRATE
								p.scale = FRACUNIT*3/4
								p.destscale = 1
								p.frame = FF_FULLBRIGHT
								p.color = j%2 and SKINCOLOR_EMERALD or SKINCOLOR_WHITE

								p.angle = sang + (j-1)*addang*ANG1
								P_InstaThrust(p, p.angle, 32*FRACUNIT)
								p.momz = 32*FixedMul(cos(p.angle), sin(b.vangle))

								sang = $-(ANG1*6)

							end
						end
					i = $-1
				end

		end,
	},

	["panty raid"] = {
		name = "Panty Raid",
		type = ATK_WIND,
		power = 650,
		accuracy = 95,
		costtype = CST_SP,
		cost = 24,
		desc = "Severe Wind dmg to one sammt",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)

				local target = hittargets[1]

				if timer == 1
					mo.blades = {}
					-- blades have an addtional vangle property.
					-- extravalue1 determines whether they spin forward or backwards

				elseif timer == 20

					-- spawn blades:

					local an = target.angle + ANG1*90
					playSound(mo.battlen, sfx_wind4)

					local b = P_SpawnMobj(target.x + 1024*cos(an), target.y + 1024*sin(an), target.z + 512*FRACUNIT, MT_DUMMY)
					b.vangle = -ANG1*60
					b.state = S_INVISIBLE
					b.extravalue1 = 1
					b.extravalue2 = 16
					mo.blades[#mo.blades+1] = b
					b.momx = -(b.x - target.x)/b.extravalue2
					b.momy = -(b.y - target.y)/b.extravalue2
					b.momz = -(b.z - (target.z + 96*FRACUNIT))/b.extravalue2
					b.fuse = TICRATE*3

					b = P_SpawnMobj(target.x - 1024*cos(an), target.y - 1024*sin(an), target.z + 320*FRACUNIT, MT_DUMMY)
					b.vangle = ANG1*30
					b.state = S_INVISIBLE
					b.extravalue1 = -1
					b.extravalue2 = 16
					mo.blades[#mo.blades+1] = b
					b.momx = -(b.x - target.x)/b.extravalue2
					b.momy = -(b.y - target.y)/b.extravalue2
					b.momz = -(b.z - (target.z + 96*FRACUNIT))/b.extravalue2
					b.fuse = TICRATE*3

				elseif timer == TICRATE*3 + 20
					damageObject(target)

				elseif timer == TICRATE*5
					return true
				end

				local i = #mo.blades
				while i
					local b = mo.blades[i]
					if not b or not b.valid
						table.remove(mo.blades, i)
						i = $-1
						continue
					end

					if R_PointToDist2(b.x, b.y, target.x, target.y) < 192*FRACUNIT
						b.momx = 0
						b.momy = 0
						b.momz = 0

						localquake(mo.battlen, FRACUNIT*10, 2)

						if leveltime%2 and i == 1

							for i=1,10
								local b = P_SpawnMobj(target.x, target.y, target.z+20*FRACUNIT, MT_DUMMY)
								b.momx = P_RandomRange(-35, 35)*FRACUNIT
								b.momy = P_RandomRange(-35, 35)*FRACUNIT
								b.momz = P_RandomRange(-35, 35)*FRACUNIT
								b.color = SKINCOLOR_RED
								b.frame = A|FF_FULLBRIGHT
								b.scale = FRACUNIT/2
								b.destscale = FRACUNIT/12
								b.tics = TICRATE/4
							end
						end
						if leveltime%4 == 0
							playSound(target.battlen, sfx_hit2)
						end
					end
					b.angle = $ + ANG1*24*b.extravalue1
					local addang = 360/6
						for j = 1, 6
							local sang = b.angle
							for k = 1, 4

								local sx = b.x + (k-1)*8*cos(sang + (j-1)*addang*ANG1)
								local sy = b.y + (k-1)*8*sin(sang + (j-1)*addang*ANG1)
								local sz = b.z + (k-1)*8*FixedMul(cos(sang + (j-1)*addang*ANG1), sin(b.vangle))

								local p = P_SpawnMobj(sx, sy, sz, MT_DUMMY)
								p.tics = TICRATE
								p.scale = FRACUNIT*3/4
								p.destscale = 1
								p.frame = FF_FULLBRIGHT
								p.color = j%2 and SKINCOLOR_EMERALD or SKINCOLOR_WHITE

								p.angle = sang + (j-1)*addang*ANG1
								P_InstaThrust(p, p.angle, 32*FRACUNIT)
								p.momz = 32*FixedMul(cos(p.angle), sin(b.vangle))

								sang = $-(ANG1*6)

							end
						end
					i = $-1
				end

		end,
	},

	["spirit drain"] = {
		name = "Spirit Drain",
		type = ATK_ALMIGHTY,
		power = 100,
		accuracy = 999,
		costtype = CST_SP,
		cost = 3,
		showsp = true,
		desc = "Drain 15 SP from 1 enemy",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
					local target = hittargets[1]

					if timer >= 20 and timer <= 40

						if timer == 20
							playSound(mo.battlen, sfx_absorb)
						elseif timer == 30
							damageSP(target, 15)
						end

						for i = 1,2
							local thok = P_SpawnMobj(target.x, target.y, target.z+mo.height/2, MT_DUMMY)
							thok.color = SKINCOLOR_BLUE
							thok.momx = P_RandomRange(-10, 10)*FRACUNIT
							thok.momy = P_RandomRange(-10, 10)*FRACUNIT
							thok.momz = P_RandomRange(-10, 10)*FRACUNIT
							thok.scale = FRACUNIT/10
							thok.destscale = FRACUNIT*2
						end

					elseif timer >= 50 and timer <= 70

						if timer == 60
						and target ~= mo
							mo.atk_attacker = mo
							playSound(mo.battlen, sfx_heal)
							damageSP(mo, -15)
						end

						local h_angle = P_RandomRange(1, 359)*ANG1
						local v_angle = P_RandomRange(1, 359)*ANG1
						local dist = 256
						local spd = P_RandomRange(40, 50)

						local s_x = mo.x+ dist*FixedMul(cos(h_angle), cos(v_angle))
						local s_y = mo.y+ dist*FixedMul(sin(h_angle), cos(v_angle))
						local s_z = (mo.z+mo.height/2)+ dist* sin(v_angle)

						local s = P_SpawnMobj(s_x, s_y, s_z, MT_DUMMY)

						s.frame = A
						s.color = SKINCOLOR_PURPLE
						s.scale = FRACUNIT*3/2
						s.destscale = FRACUNIT/5
						s.target = target
						s.tics = 10
						s.momx = (mo.x - s.x)/10
						s.momy = (mo.y - s.y)/10
						s.momz = (mo.z - s.z)/10

					elseif timer == 110
						return true
					end
				end,
	},

	["spirit leech"] = {
		name = "Spirit Leech",
		type = ATK_ALMIGHTY,
		power = 270,
		accuracy = 999,
		costtype = CST_SP,
		cost = 6,
		showsp = true,
		desc = "Drain 30 SP from 1 enemy",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
					local target = hittargets[1]

					if timer >= 20 and timer <= 40

						if timer == 20
							playSound(mo.battlen, sfx_absorb)
						elseif timer == 30
							damageSP(target, 30)
						end

						for i = 1,2
							local thok = P_SpawnMobj(target.x, target.y, target.z+mo.height/2, MT_DUMMY)
							thok.color = SKINCOLOR_BLUE
							thok.momx = P_RandomRange(-10, 10)*FRACUNIT
							thok.momy = P_RandomRange(-10, 10)*FRACUNIT
							thok.momz = P_RandomRange(-10, 10)*FRACUNIT
							thok.scale = FRACUNIT/10
							thok.destscale = FRACUNIT*2
						end

					elseif timer >= 50 and timer <= 70

						if timer == 60
						and target ~= mo
							mo.atk_attacker = mo
							playSound(mo.battlen, sfx_heal)
							damageSP(mo, -30)
						end

						local h_angle = P_RandomRange(1, 359)*ANG1
						local v_angle = P_RandomRange(1, 359)*ANG1
						local dist = 256
						local spd = P_RandomRange(40, 50)

						local s_x = mo.x+ dist*FixedMul(cos(h_angle), cos(v_angle))
						local s_y = mo.y+ dist*FixedMul(sin(h_angle), cos(v_angle))
						local s_z = (mo.z+mo.height/2)+ dist* sin(v_angle)

						local s = P_SpawnMobj(s_x, s_y, s_z, MT_DUMMY)

						s.frame = A
						s.color = SKINCOLOR_PURPLE
						s.scale = FRACUNIT*3/2
						s.destscale = FRACUNIT/5
						s.target = target
						s.tics = 10
						s.momx = (mo.x - s.x)/10
						s.momy = (mo.y - s.y)/10
						s.momz = (mo.z - s.z)/10

					elseif timer == 110
						return true
					end
				end,
	},

	["life drain"] = {
		name = "Life Drain",
		type = ATK_ALMIGHTY,
		power = 100,
		accuracy = 999,
		costtype = CST_SP,
		cost = 8,
		desc = "Drain a bit of HP from 1 enemy",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
					local target = hittargets[1]

					if timer >= 20 and timer <= 40

						if timer == 20
							playSound(mo.battlen, sfx_absorb)
						elseif timer == 30
							damageObject(target)
							mo.buf_damage = target.damagetaken
						end

						for i = 1,2
							local thok = P_SpawnMobj(target.x, target.y, target.z+mo.height/2, MT_DUMMY)
							thok.color = SKINCOLOR_ORANGE
							thok.momx = P_RandomRange(-10, 10)*FRACUNIT
							thok.momy = P_RandomRange(-10, 10)*FRACUNIT
							thok.momz = P_RandomRange(-10, 10)*FRACUNIT
							thok.scale = FRACUNIT/10
							thok.destscale = FRACUNIT*2
						end

					elseif timer >= 50 and timer <= 70

						if timer == 60
						and target ~= mo
							mo.atk_attacker = mo
							playSound(mo.battlen, sfx_heal2)
							damageObject(mo, -mo.buf_damage, DMG_NORMAL)
						end

						local h_angle = P_RandomRange(1, 359)*ANG1
						local v_angle = P_RandomRange(1, 359)*ANG1
						local dist = 256
						local spd = P_RandomRange(40, 50)

						local s_x = mo.x+ dist*FixedMul(cos(h_angle), cos(v_angle))
						local s_y = mo.y+ dist*FixedMul(sin(h_angle), cos(v_angle))
						local s_z = (mo.z+mo.height/2)+ dist* sin(v_angle)

						local s = P_SpawnMobj(s_x, s_y, s_z, MT_DUMMY)

						s.frame = A
						s.color = SKINCOLOR_CYAN
						s.scale = FRACUNIT*3/2
						s.destscale = FRACUNIT/5
						s.target = target
						s.tics = 10
						s.momx = (mo.x - s.x)/10
						s.momy = (mo.y - s.y)/10
						s.momz = (mo.z - s.z)/10

					elseif timer == 110
						return true
					end
				end,
	},

	["life leech"] = {
		name = "Life Leech",
		type = ATK_ALMIGHTY,
		power = 270,
		accuracy = 999,
		costtype = CST_SP,
		cost = 16,
		desc = "Drain a considerable amount \nof HP from 1 enemy",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
					local target = hittargets[1]

					if timer >= 20 and timer <= 40

						if timer == 20
							playSound(mo.battlen, sfx_absorb)
						elseif timer == 30
							damageObject(target)
							mo.buf_damage = target.damagetaken
						end

						for i = 1,2
							local thok = P_SpawnMobj(target.x, target.y, target.z+mo.height/2, MT_DUMMY)
							thok.color = SKINCOLOR_ORANGE
							thok.momx = P_RandomRange(-10, 10)*FRACUNIT
							thok.momy = P_RandomRange(-10, 10)*FRACUNIT
							thok.momz = P_RandomRange(-10, 10)*FRACUNIT
							thok.scale = FRACUNIT/10
							thok.destscale = FRACUNIT*2
						end

					elseif timer >= 50 and timer <= 70

						if timer == 60
						and target ~= mo
							mo.atk_attacker = mo
							playSound(mo.battlen, sfx_heal3)
							damageObject(mo, -mo.buf_damage, DMG_NORMAL)
						end

						local h_angle = P_RandomRange(1, 359)*ANG1
						local v_angle = P_RandomRange(1, 359)*ANG1
						local dist = 256
						local spd = P_RandomRange(40, 50)

						local s_x = mo.x+ dist*FixedMul(cos(h_angle), cos(v_angle))
						local s_y = mo.y+ dist*FixedMul(sin(h_angle), cos(v_angle))
						local s_z = (mo.z+mo.height/2)+ dist* sin(v_angle)

						local s = P_SpawnMobj(s_x, s_y, s_z, MT_DUMMY)

						s.frame = A
						s.color = SKINCOLOR_CYAN
						s.scale = FRACUNIT*3/2
						s.destscale = FRACUNIT/5
						s.target = target
						s.tics = 10
						s.momx = (mo.x - s.x)/10
						s.momy = (mo.y - s.y)/10
						s.momz = (mo.z - s.z)/10

					elseif timer == 110
						return true
					end
				end,
	},

	["life siphon"] = {
		name = "Life Siphon",
		type = ATK_ALMIGHTY,
		power = 400,
		accuracy = 999,
		costtype = CST_SP,
		cost = 24,
		desc = "Drain a high amount \nof HP from 1 enemy",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
					local target = hittargets[1]

					if timer >= 20 and timer <= 40

						if timer == 20
							playSound(mo.battlen, sfx_absorb)
						elseif timer == 30
							damageObject(target)
							mo.buf_damage = target.damagetaken
						end

						for i = 1,2
							local thok = P_SpawnMobj(target.x, target.y, target.z+mo.height/2, MT_DUMMY)
							thok.color = SKINCOLOR_ORANGE
							thok.momx = P_RandomRange(-10, 10)*FRACUNIT
							thok.momy = P_RandomRange(-10, 10)*FRACUNIT
							thok.momz = P_RandomRange(-10, 10)*FRACUNIT
							thok.scale = FRACUNIT/10
							thok.destscale = FRACUNIT*2
						end

					elseif timer >= 50 and timer <= 70

						if timer == 60
						and target ~= mo
							mo.atk_attacker = mo
							playSound(mo.battlen, sfx_heal3)
							damageObject(mo, -mo.buf_damage, DMG_NORMAL)
						end

						local h_angle = P_RandomRange(1, 359)*ANG1
						local v_angle = P_RandomRange(1, 359)*ANG1
						local dist = 256
						local spd = P_RandomRange(40, 50)

						local s_x = mo.x+ dist*FixedMul(cos(h_angle), cos(v_angle))
						local s_y = mo.y+ dist*FixedMul(sin(h_angle), cos(v_angle))
						local s_z = (mo.z+mo.height/2)+ dist* sin(v_angle)

						local s = P_SpawnMobj(s_x, s_y, s_z, MT_DUMMY)

						s.frame = A
						s.color = SKINCOLOR_CYAN
						s.scale = FRACUNIT*3/2
						s.destscale = FRACUNIT/5
						s.target = target
						s.tics = 10
						s.momx = (mo.x - s.x)/10
						s.momy = (mo.y - s.y)/10
						s.momz = (mo.z - s.z)/10

					elseif timer == 110
						return true
					end
				end,
	},

	["trisagion"] = {
		name = "Trisagion",
		type = ATK_FIRE,
		power = 650,
		accuracy = 95,
		costtype = CST_SP,
		status = COND_BURN,
		statuschance = 10,
		cost = 32,
		desc = "Severe Fire dmg to one enemy. \nHigh chance of burn.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 1
				mo.fangle = 0
				mo.fdist = 400
				mo.columns = {}

			elseif timer >= 15
			and timer <= 30
				for i = 1, 12
					local boom = P_SpawnMobj(target.x + P_RandomRange(-48, 48)*FRACUNIT, target.y + P_RandomRange(-48, 48)*FRACUNIT, target.z, MT_DUMMY)
					boom.state = S_QUICKBOOM1
					boom.flags = $ & ~MF_NOGRAVITY
					boom.momz = 8*FRACUNIT

				end

			elseif timer == 31

				for i = 1, 3 do
					local an = (mo.fangle + (i-1)*120)*ANG1
					local h = P_SpawnMobj(target.x + mo.fdist*cos(an), target.y + mo.fdist*sin(an), target.z, MT_DUMMY)
					DoExplosion(h)
					h.state = S_INVISIBLE
					h.tics = -1
					mo.columns[#mo.columns+1] = h
				end
			end

			--if timer%2 == 0
			--	playSound(mo.battlen, sfx_fire1)
			--end

			local j = #mo.columns
			while j

				local m = mo.columns[j]
				if not m or not m.valid
					j = $-1
					continue
				end

				for i = 1, 5
					local boom = P_SpawnMobj(m.x + P_RandomRange(-48, 48)*FRACUNIT, m.y + P_RandomRange(-48, 48)*FRACUNIT, m.z, MT_DUMMY)
					boom.state = S_QUICKBOOM1
					boom.momz = P_RandomRange(0, 48)*FRACUNIT
					boom.scale = FRACUNIT*3/2
				end
				localquake(mo.battlen, FRACUNIT*8, 1)

				if timer <= 240
					local an = (mo.fangle + (j-1)*120)*ANG1
					P_TeleportMove(m, target.x + mo.fdist*cos(an), target.y + mo.fdist*sin(an), target.z)
				end

				j = $-1

			end

			if timer >= 31
				mo.fangle = $ + min(14, ((timer-31)/10))
				mo.fdist = max(96, $- 2)
			end

			if timer == 220
				DoExplosion(target)
			elseif timer >= 220 and timer < 240
				for i = 1, 12
					local boom = P_SpawnMobj(target.x + P_RandomRange(-64, 64)*FRACUNIT, target.y + P_RandomRange(-64, 64)*FRACUNIT, target.z, MT_DUMMY)
					boom.state = S_QUICKBOOM1
					boom.momz = P_RandomRange(0, 80)*FRACUNIT
					boom.scale = FRACUNIT*5
				end
			elseif timer == 240
				-- delet old shit:
				mo.fangle = (R_PointToAngle(target.x, target.y)) + ANG1*180
				mo.columns = {}

				local a = mo.fangle - ANG1*80

				for i = 1, 16
					local m = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					P_InstaThrust(m, a, FRACUNIT*48)
					mo.columns[#mo.columns+1] = m
					m.state = S_INVISIBLE
					m.tics = TICRATE
					a = $+ ANG1*10
				end

				damageObject(target)
			elseif timer == 280
				mo.fangle = nil
				mo.columns = nil
				return true
			end
		end,
	},

	["agidyne"] = {
		name = "Agidyne",
		type = ATK_FIRE,
		power = 350,
		accuracy = 95,
		costtype = CST_SP,
		status = COND_BURN,
		statuschance = 5,
		cost = 12,
		desc = "Heavy Fire dmg to one enemy. \nMay inflict burn.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]
			if timer >= 15
			and timer < 60

				if timer == 15
					DoExplosion(target)
					localquake(mo.battlen, FRACUNIT*64, 10)
				end

				for i = 1, 12
					local boom = P_SpawnMobj(target.x + P_RandomRange(-48, 48)*FRACUNIT, target.y + P_RandomRange(-48, 48)*FRACUNIT, target.z, MT_DUMMY)
					boom.state = S_QUICKBOOM1
					boom.momz = P_RandomRange(0, 48)*FRACUNIT
					boom.scale = FRACUNIT*3/2
				end
				localquake(mo.battlen, FRACUNIT*8, 1)

				if timer%4 == 0
					playSound(mo.battlen, sfx_fire1)
				end

			elseif timer == 60

				for i = 1, 32
					local smoke = P_SpawnMobj(target.x + P_RandomRange(-48, 48)*FRACUNIT, target.y + P_RandomRange(-48, 48)*FRACUNIT, target.z + P_RandomRange(0, 128)*FRACUNIT, MT_SMOKE)
					smoke.scale = FRACUNIT*4
					smoke.momz = P_RandomRange(3, 10)*FRACUNIT
				end

				damageObject(target)
				localquake(mo.battlen, FRACUNIT*17, 20)
				local smol = P_SpawnMobj(target.x, target.y, target.z, MT_SMOLDERING)
				smol.fuse = TICRATE*2
				smol.scale = FRACUNIT*3

			elseif timer == 90
				return true
			end
		end,
	},

	["agilao"] = {
		name = "Agilao",
		type = ATK_FIRE,
		power = 140,
		accuracy = 95,
		costtype = CST_SP,
		status = COND_BURN,
		statuschance = 5,
		cost = 8,
		desc = "Medium Fire dmg to one enemy. \nMay inflict burn.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]
			if timer == 10
			or timer == 14
				local boom = P_SpawnMobj(target.x+P_RandomRange(-20, 20)*FRACUNIT, target.y+P_RandomRange(-20, 20)*FRACUNIT, target.z+P_RandomRange(-20, 20)*FRACUNIT, MT_BOSSEXPLODE)
				boom.scale = FRACUNIT*3
				boom.state = S_QUICKBOOM1
				playSound(mo.battlen, sfx_fire1)
			elseif timer == 30
				local boom = P_SpawnMobj(target.x, target.y, target.z+20*FRACUNIT, MT_BOSSEXPLODE)
				boom.scale = FRACUNIT*4
				boom.state = S_PFIRE1
				playSound(mo.battlen, sfx_fire2)
				playSound(mo.battlen, sfx_fire1)
				damageObject(target)

				localquake(mo.battlen, FRACUNIT*32, 8)

				for i = 1, 8
					local smoke = P_SpawnMobj(boom.x, boom.y, boom.z, MT_SMOKE)
					smoke.scale = FRACUNIT*6
					smoke.momx = P_RandomRange(-5, 5)*FRACUNIT
					smoke.momy = P_RandomRange(-5, 5)*FRACUNIT
					smoke.momz = P_RandomRange(3, 6)*FRACUNIT
				end

				local sm = P_SpawnMobj(target.x, target.y, target.z, MT_SMOLDERING)
				sm.fuse = TICRATE/2
				sm.scale = target.scale*3/2

			elseif timer == 70
				return true
			end
		end,
	},

	["flame link"] = {
		name = "Flame Link",
		type = ATK_FIRE,
		power = 50,
		accuracy = 95,
		costtype = CST_HPPERCENT,
		cost = 10,
		critical = 3,
		link = true,
		desc = "Light Fire damage to\none enemy. Following allied attacks\ngain Link follow-ups.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 15
				local s = P_SpawnMobj(target.x, target.y, target.z+1*FRACUNIT, MT_DUMMY)
				s.state = S_SLASHING_1_1
				s.color = SKINCOLOR_RED
				s.scale = FRACUNIT*3/2
				playSound(mo.battlen, sfx_slash)

			elseif timer == 17
				local d = P_SpawnMobj(target.x, target.y, target.z+128*FRACUNIT, MT_THOK)
				d.sprite = SPR_THMP
				d.frame = C|FF_FULLBRIGHT
				d.scale = FRACUNIT/4
				d.destscale = FRACUNIT*3
				d.scalespeed = FRACUNIT/8
				d.fuse = TICRATE-10
				d.tics = d.fuse
				d.momz = FRACUNIT*2
				d.momx = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
				d.momy = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
				d.color = SKINCOLOR_RED

			elseif timer == 19

				damageObject(target)
				--playSound(mo.battlen, sfx_bexpld)
				playSound(mo.battlen, sfx_fire1)
				if not target.plyr
					createSplat(mo)
					createSplat(mo)
				end
				localquake(mo.battlen, FRACUNIT*10, 10)
				for i=1,20
					local b = P_SpawnMobj(target.x, target.y, target.z+20*FRACUNIT, MT_DUMMY)
					b.momx = P_RandomRange(-8, 8)*FRACUNIT
					b.momy = P_RandomRange(-8, 8)*FRACUNIT
					b.momz = P_RandomRange(-8, 8)*FRACUNIT
					b.state = S_QUICKBOOM1
					b.scale = FRACUNIT*3
				end

				local s = P_SpawnMobj(target.x, target.y, target.z+40*FRACUNIT, MT_THOK)
				s.sprite = SPR_SLSH
				s.frame = I|FF_FULLBRIGHT
				s.scale = FRACUNIT/2
				s.destscale = FRACUNIT*4
				s.scalespeed = FRACUNIT/3
				s.color = SKINCOLOR_RED

			elseif timer == 45
				target.slashsprite = nil
				return true
			end
		end,
	},

	["gale link"] = {
		name = "Gale Link",
		type = ATK_WIND,
		power = 50,
		accuracy = 95,
		costtype = CST_HPPERCENT,
		cost = 10,
		critical = 3,
		link = true,
		desc = "Light Wind damage to\none enemy. Following allied attacks\ngain Link follow-ups.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 15
				local s = P_SpawnMobj(target.x, target.y, target.z+1*FRACUNIT, MT_DUMMY)
				s.state = S_SLASHING_1_1
				s.color = SKINCOLOR_EMERALD
				s.scale = FRACUNIT*3/2
				playSound(mo.battlen, sfx_slash)
				playSound(mo.battlen, sfx_wind1)

			elseif timer == 17
				local d = P_SpawnMobj(target.x, target.y, target.z+128*FRACUNIT, MT_THOK)
				d.sprite = SPR_THMP
				d.frame = C|FF_FULLBRIGHT
				d.scale = FRACUNIT/4
				d.destscale = FRACUNIT*3
				d.scalespeed = FRACUNIT/8
				d.fuse = TICRATE-10
				d.tics = d.fuse
				d.momz = FRACUNIT*2
				d.momx = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
				d.momy = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
				d.color = SKINCOLOR_EMERALD
			end

			if timer == 16
			or timer == 18
			or timer == 20
				local s = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
				s.scale = FRACUNIT/4
				s.sprite = SPR_SLAS
				s.frame = I|TR_TRANS50 + P_RandomRange(0, 3)
				s.destscale = FRACUNIT*9
				s.scalespeed = FRACUNIT
				s.tics = TICRATE/3
			end

			if timer == 19

				damageObject(target)
				--playSound(mo.battlen, sfx_bexpld)
				playSound(mo.battlen, sfx_fire1)
				if not target.plyr
					createSplat(mo)
					createSplat(mo)
				end
				localquake(mo.battlen, FRACUNIT*10, 10)

				local s = P_SpawnMobj(target.x, target.y, target.z+40*FRACUNIT, MT_THOK)
				s.sprite = SPR_SLSH
				s.frame = I|FF_FULLBRIGHT
				s.scale = FRACUNIT/2
				s.destscale = FRACUNIT*4
				s.scalespeed = FRACUNIT/3
				s.color = SKINCOLOR_EMERALD

			elseif timer == 45
				target.slashsprite = nil
				return true
			end
		end,
	},

	["frost link"] = {
		name = "Frost Link",
		type = ATK_ICE,
		power = 50,
		accuracy = 95,
		costtype = CST_HPPERCENT,
		cost = 10,
		critical = 3,
		link = true,
		desc = "Light Ice damage to\none enemy. Following allied attacks\ngain Link follow-ups.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 15
				local s = P_SpawnMobj(target.x, target.y, target.z+1*FRACUNIT, MT_DUMMY)
				s.state = S_SLASHING_1_1
				s.color = SKINCOLOR_CYAN
				s.scale = FRACUNIT*3/2
				playSound(mo.battlen, sfx_slash)

			elseif timer == 17
				local d = P_SpawnMobj(target.x, target.y, target.z+128*FRACUNIT, MT_THOK)
				d.sprite = SPR_THMP
				d.frame = C|FF_FULLBRIGHT
				d.scale = FRACUNIT/4
				d.destscale = FRACUNIT*3
				d.scalespeed = FRACUNIT/8
				d.fuse = TICRATE-10
				d.tics = d.fuse
				d.momz = FRACUNIT*2
				d.momx = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
				d.momy = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
				d.color = SKINCOLOR_CYAN
			end

			if timer == 19

				damageObject(target)
				--playSound(mo.battlen, sfx_bexpld)
				playSound(mo.battlen, sfx_bufu4)
				if not target.plyr
					createSplat(mo)
					createSplat(mo)
				end
				localquake(mo.battlen, FRACUNIT*10, 10)

				for i=1,20
				local bb = P_SpawnMobj(target.x, target.y, target.z + FRACUNIT*20, MT_BUFU_PARTICLE)
					bb.state, bb.scale = i%2 and S_BUFU_PARTICLE_B or S_BUFU_PARTICLE_A, mo.scale
					bb.momx, bb.momy, bb.momz = P_RandomRange(-3, 3)*FRACUNIT, P_RandomRange(-3, 3)*FRACUNIT, P_RandomRange(7, 14)*FRACUNIT
				end


				local s = P_SpawnMobj(target.x, target.y, target.z+40*FRACUNIT, MT_THOK)
				s.sprite = SPR_SLSH
				s.frame = I|FF_FULLBRIGHT
				s.scale = FRACUNIT/2
				s.destscale = FRACUNIT*4
				s.scalespeed = FRACUNIT/3
				s.color = SKINCOLOR_CYAN

			elseif timer == 45
				target.slashsprite = nil
				return true
			end
		end,
	},

	["bolt link"] = {
		name = "Bolt Link",
		type = ATK_ELEC,
		power = 50,
		accuracy = 95,
		costtype = CST_HPPERCENT,
		cost = 10,
		critical = 3,
		link = true,
		desc = "Light Electric damage to\none enemy. Following allied attacks\ngain Link follow-ups.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 15
				local s = P_SpawnMobj(target.x, target.y, target.z+1*FRACUNIT, MT_DUMMY)
				s.state = S_SLASHING_1_1
				s.color = SKINCOLOR_YELLOW
				s.scale = FRACUNIT*3/2
				playSound(mo.battlen, sfx_slash)

			elseif timer == 17
				local d = P_SpawnMobj(target.x, target.y, target.z+128*FRACUNIT, MT_THOK)
				d.sprite = SPR_THMP
				d.frame = C|FF_FULLBRIGHT
				d.scale = FRACUNIT/4
				d.destscale = FRACUNIT*3
				d.scalespeed = FRACUNIT/8
				d.fuse = TICRATE-10
				d.tics = d.fuse
				d.momz = FRACUNIT*2
				d.momx = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
				d.momy = P_RandomRange(0, FRACUNIT-1)*P_RandomRange(-8, 8)
				d.color = SKINCOLOR_YELLOW
			end

			if timer == 19

				damageObject(target)
				--playSound(mo.battlen, sfx_bexpld)
				playSound(mo.battlen, sfx_zio3)
				if not target.plyr
					createSplat(mo)
					createSplat(mo)
				end
				localquake(mo.battlen, FRACUNIT*10, 10)

				for i=1,20
					local b = P_SpawnMobj(target.x, target.y, target.z+20*FRACUNIT, MT_DUMMY)
					b.momx = P_RandomRange(-8, 8)*FRACUNIT
					b.momy = P_RandomRange(-8, 8)*FRACUNIT
					b.momz = P_RandomRange(-8, 8)*FRACUNIT
					b.state = S_SSPK1
				end


				local s = P_SpawnMobj(target.x, target.y, target.z+40*FRACUNIT, MT_THOK)
				s.sprite = SPR_SLSH
				s.frame = I|FF_FULLBRIGHT
				s.scale = FRACUNIT/2
				s.destscale = FRACUNIT*4
				s.scalespeed = FRACUNIT/3
				s.color = SKINCOLOR_YELLOW

			elseif timer == 45
				target.slashsprite = nil
				return true
			end
		end,
	},

	["agi2"] = {
		name = "Lmao",
		type = ATK_FIRE,
		power = 32000,
		accuracy = 95,
		costtype = CST_SP,
		cost = 4,
		norandom = true,	-- Don't allow this move to be selected in random pvp skills
		status = COND_BURN,
		statuschance = 5,
		desc = "Light Fire dmg to one enemy. \nMay inflict burn.",
		target = TGT_ENEMY,

		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer >= 20 and timer <= 40
				if not (timer%10)
					playSound(mo.battlen, sfx_fire1)
				end
				if not (leveltime%3)
					local boom = P_SpawnMobj(target.x+P_RandomRange(-20, 20)*FRACUNIT, target.y+P_RandomRange(-20, 20)*FRACUNIT, target.z+P_RandomRange(-20, 20)*FRACUNIT, MT_DUMMY)
					boom.scale = FRACUNIT*3/2
					boom.state = S_QUICKBOOM1

					for	 i = 1, 4
						local smoke = P_SpawnMobj(boom.x, boom.y, boom.z, MT_SMOKE)
						smoke.momx = P_RandomRange(-4, 4)*FRACUNIT
						smoke.momy = P_RandomRange(-4, 4)*FRACUNIT
						smoke.momz = P_RandomRange(2, 5)*FRACUNIT
					end

				end
				if timer == 30
					local sm = P_SpawnMobj(target.x, target.y, target.z, MT_SMOLDERING)
					sm.fuse = TICRATE
					damageObject(target, target.hp*64)
				end
			elseif timer == 70
				return true
			end
		end,
	},

	["agi"] = {
		name = "Agi",
		type = ATK_FIRE,
		power = 60,
		accuracy = 95,
		costtype = CST_SP,
		cost = 4,
		status = COND_BURN,
		statuschance = 5,
		desc = "Light Fire dmg to one enemy. \nMay inflict burn.",
		target = TGT_ENEMY,

		nocast = 	function(targets, n)
						-- very specific for the turorial

						-- sub persona tutorial
						local btl = server.P_BattleStatus[1]
						if btl.tutorial_zio
							BTL_logMessage(1, "Amy told you to use \x82Zio\x80.")
							return true
						end

						-- this is used for the knockdown tutorial
						if SAVE_localtable.tutorial
						and targets[n].down
							BTL_logMessage(targets[n].battlen, "This enemy is already down!")
							return true
						end

					end,

		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer >= 20 and timer <= 40
				if not (timer%10)
					playSound(mo.battlen, sfx_fire1)
				end
				if not (leveltime%3)
					local boom = P_SpawnMobj(target.x+P_RandomRange(-20, 20)*FRACUNIT, target.y+P_RandomRange(-20, 20)*FRACUNIT, target.z+P_RandomRange(-20, 20)*FRACUNIT, MT_DUMMY)
					boom.scale = FRACUNIT*3/2
					boom.state = S_QUICKBOOM1

					for	 i = 1, 4
						local smoke = P_SpawnMobj(boom.x, boom.y, boom.z, MT_SMOKE)
						smoke.momx = P_RandomRange(-4, 4)*FRACUNIT
						smoke.momy = P_RandomRange(-4, 4)*FRACUNIT
						smoke.momz = P_RandomRange(2, 5)*FRACUNIT
					end

				end
				if timer == 30
					local sm = P_SpawnMobj(target.x, target.y, target.z, MT_SMOLDERING)
					sm.fuse = TICRATE
					damageObject(target)
				end
			elseif timer == 70
				return true
			end
		end,
	},

	["maragidyne"] = {
		name = "Maragidyne",
		type = ATK_FIRE,
		power = 350,
		accuracy = 90,
		costtype = CST_SP,
		cost = 24,
		status = COND_BURN,
		statuschance = 2,
		desc = "Heavy Fire dmg to all enemies. \nMay inflict burn.",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)

			for i = 1, #hittargets
				local target = hittargets[i]
				local time = timer - 6*(i-1)

				if time >= 15
				and time < 60

					if time == 15
						localquake(mo.battlen, FRACUNIT*64, 10)
					end

					for i = 1, 12
						local boom = P_SpawnMobj(target.x + P_RandomRange(-48, 48)*FRACUNIT, target.y + P_RandomRange(-48, 48)*FRACUNIT, target.z, MT_DUMMY)
						boom.state = S_QUICKBOOM1
						boom.momz = P_RandomRange(0, 48)*FRACUNIT
						boom.scale = FRACUNIT*3/2
					end
					localquake(mo.battlen, FRACUNIT*8, 1)

					if time%4 == 0
						playSound(mo.battlen, sfx_fire1)
					end

				elseif time == 60

					for i = 1, 32
						local smoke = P_SpawnMobj(target.x + P_RandomRange(-48, 48)*FRACUNIT, target.y + P_RandomRange(-48, 48)*FRACUNIT, target.z + P_RandomRange(0, 128)*FRACUNIT, MT_SMOKE)
						smoke.scale = FRACUNIT*4
						smoke.momz = P_RandomRange(3, 10)*FRACUNIT
					end

					damageObject(target)
					localquake(mo.battlen, FRACUNIT*17, 20)
					local smol = P_SpawnMobj(target.x, target.y, target.z, MT_SMOLDERING)
					smol.fuse = TICRATE*2
					smol.scale = FRACUNIT*3
				end
			end

			if timer == 90 + 6*(#hittargets-1)
				return true
			end
		end,
	},

	["maragion"] = {
		name = "Maragion",
		type = ATK_FIRE,
		power = 140,
		accuracy = 90,
		costtype = CST_SP,
		cost = 16,
		status = COND_BURN,
		statuschance = 2,
		desc = "Medium Fire dmg to all enemies. \nMay inflict burn.",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)

			for k,e in ipairs(hittargets)
				local target = e
				local time = timer - 10*(k-1)
				if time == 10
				or time == 14
					local boom = P_SpawnMobj(target.x+P_RandomRange(-20, 20)*FRACUNIT, target.y+P_RandomRange(-20, 20)*FRACUNIT, target.z+P_RandomRange(-20, 20)*FRACUNIT, MT_BOSSEXPLODE)
					boom.scale = FRACUNIT*3
					boom.state = S_QUICKBOOM1
					playSound(mo.battlen, sfx_fire1)
				elseif time == 30
					local boom = P_SpawnMobj(target.x, target.y, target.z+20*FRACUNIT, MT_BOSSEXPLODE)
					boom.scale = FRACUNIT*4
					boom.state = S_PFIRE1
					playSound(mo.battlen, sfx_fire2)
					playSound(mo.battlen, sfx_fire1)
					damageObject(target)

					localquake(mo.battlen, FRACUNIT*32, 8)

					for i = 1, 8
						local smoke = P_SpawnMobj(boom.x, boom.y, boom.z, MT_SMOKE)
						smoke.scale = FRACUNIT*6
						smoke.momx = P_RandomRange(-5, 5)*FRACUNIT
						smoke.momy = P_RandomRange(-5, 5)*FRACUNIT
						smoke.momz = P_RandomRange(3, 6)*FRACUNIT
					end

					local sm = P_SpawnMobj(target.x, target.y, target.z, MT_SMOLDERING)
					sm.fuse = TICRATE/2
					sm.scale = target.scale*3/2
				end
			end

			if timer == 71 + (#targets-1)*10
				return true
			end
		end,
	},

	["maragi"] = {
		name = "Maragi",
		type = ATK_FIRE,
		power = 60,
		accuracy = 90,
		costtype = CST_SP,
		cost = 8,
		status = COND_BURN,
		statuschance = 2,
		desc = "Light Fire dmg to all enemies. \nMay inflict burn.",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)

				for k,e in ipairs(hittargets)
					local time = timer - 10*(k-1)
					local target = e

					if time >= 20 and time <= 40
						if timer == 20
						or timer == 30
						or timer == 40
							playSound(mo.battlen, sfx_fire1)
						end
						if not (leveltime%3)
							local boom = P_SpawnMobj(target.x+P_RandomRange(-20, 20)*FRACUNIT, target.y+P_RandomRange(-20, 20)*FRACUNIT, target.z+P_RandomRange(-20, 20)*FRACUNIT, MT_BOSSEXPLODE)
							boom.scale = FRACUNIT*3/2
							boom.state = S_QUICKBOOM1

							for	 i = 1, 4
								local smoke = P_SpawnMobj(boom.x, boom.y, boom.z, MT_SMOKE)
								smoke.momx = P_RandomRange(-4, 4)*FRACUNIT
								smoke.momy = P_RandomRange(-4, 4)*FRACUNIT
								smoke.momz = P_RandomRange(2, 5)*FRACUNIT
							end

						end
						if time == 30
							local sm = P_SpawnMobj(target.x, target.y, target.z, MT_SMOLDERING)
							sm.fuse = TICRATE
							damageObject(target)
						end
					end
				end
				if timer == 70 + (#targets-1)*10
					return true
				end
			end,
	},

	["agiverse"] = {
		name = "Agiverse",
		type = ATK_FIRE,
		power = 100,
		accuracy = 999,
		costtype = CST_SP,
		cost = 12,
		desc = "Light fire dmg to all enemies.\nDeploys a field that doubles EP\ngain from attacks.",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)

				for k,e in ipairs(hittargets)
					local time = timer - 10*(k-1)
					local target = e

					if time >= 20 and time <= 40
						if timer == 20
						or timer == 30
						or timer == 40
							playSound(mo.battlen, sfx_fire1)
						end
						if not (leveltime%3)
							local boom = P_SpawnMobj(target.x+P_RandomRange(-20, 20)*FRACUNIT, target.y+P_RandomRange(-20, 20)*FRACUNIT, target.z+P_RandomRange(-20, 20)*FRACUNIT, MT_BOSSEXPLODE)
							boom.scale = FRACUNIT*3/2
							boom.state = S_QUICKBOOM1

							for	 i = 1, 4
								local smoke = P_SpawnMobj(boom.x, boom.y, boom.z, MT_SMOKE)
								smoke.momx = P_RandomRange(-4, 4)*FRACUNIT
								smoke.momy = P_RandomRange(-4, 4)*FRACUNIT
								smoke.momz = P_RandomRange(2, 5)*FRACUNIT
							end

						end
						if time == 30
							local sm = P_SpawnMobj(target.x, target.y, target.z, MT_SMOLDERING)
							sm.fuse = TICRATE
							damageObject(target)

							if target.damagestate ~= DMG_MISS
							and target.damagestate ~= DMG_BLOCK
							and target.damagestate ~= DMG_DRAIN
								startField(target, FLD_AGIVERSE, 4)
							end

						end
					end
				end
				if timer == 70 + (#targets-1)*10
					return true
				end
		end,
	},

	["bufu"] = {
		name = "Bufu",
		type = ATK_ICE,
		power = 60,
		accuracy = 95,
		costtype = CST_SP,
		cost = 4,
		status = COND_FREEZE,
		statuschance = 5,
		desc = "Light Ice dmg to one enemy. \nMay inflict freeze.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]

			if timer == 25
				playSound(mo.battlen, sfx_bufu3)
			end

			if (timer >= 21 and timer <= 54) and (target.bufus and #target.bufus)
				if not (leveltime%2)
					for i = 1, 2
						local bs_target = target.bufus[P_RandomRange(1, #target.bufus)]
						local bs_scales = {FRACUNIT/2, FRACUNIT*3/4, FRACUNIT}

						local d = 30 -- i got lazy
						local bs = P_SpawnMobj(bs_target.x+(P_RandomRange(-(d), d)*bs_target.scale), bs_target.y+(P_RandomRange(-(d), d)*bs_target.scale), bs_target.z+(P_RandomRange(0, d*3/2)*bs_target.scale), MT_BUFU)
						bs.state, bs.scale, bs.color = S_BUFU_PARTICLE_D, bs_scales[P_RandomRange(1, #bs_scales)], SKINCOLOR_CYAN
						bs.momz = P_RandomRange(-1, 1)*FRACUNIT
					end
				end
			end
			if (timer == 5) -- setup table to store bufu stuff
				target.bufus = {}
			elseif (timer >= 21 and timer <= 27)
				if not (timer%3)
					for i = 1, P_RandomRange(2, 3)
						local bufu_destscales = {FRACUNIT*11/10, FRACUNIT*5/4, FRACUNIT*13/10} -- 1.20, 1.25, 1.30
						local b = P_SpawnMobj(target.x+P_RandomRange(-25, 25)*FRACUNIT, target.y+P_RandomRange(-25, 25)*FRACUNIT, target.z, MT_BUFU)
						b.state, b.scale = S_BUFU, FRACUNIT/3
						b.destscale = bufu_destscales[P_RandomRange(1, #bufu_destscales)]
						b.momz, b.risetime = P_RandomRange(3, 7)*FRACUNIT, P_RandomRange(4, 6)
						target.bufus[#target.bufus+1] = b
					end
				end
			elseif (timer >= 47 and timer <= 54)
				for k, v in ipairs(target.bufus)
					v.sx, v.sy, v.sz = $ or v.x, $ or v.y, $ or v.z
					P_TeleportMove(v, v.sx+P_RandomRange(-2, 2)*v.scale, v.sy+P_RandomRange(-2, 2)*v.scale, v.sz+P_RandomRange(-2, 2)*v.scale)
					if (timer == 53) then v.state = S_BUFU_FLASH end
				end
			elseif (timer == 55)
				for k, v in ipairs(target.bufus)
					local ba = P_SpawnMobj(v.x, v.y, v.z, MT_BUFU_PARTICLE)
					ba.state, ba.scale = S_BUFU_PARTICLE_A, v.scale
					ba.momx, ba.momy, ba.momz = P_RandomRange(-5, 5)*FRACUNIT, P_RandomRange(-5, 5)*FRACUNIT, P_RandomRange(5, 11)*FRACUNIT

					local bb = P_SpawnMobj(v.x, v.y, v.z, MT_BUFU_PARTICLE)
					bb.state, bb.scale = S_BUFU_PARTICLE_B, v.scale
					bb.momx, bb.momy, bb.momz = P_RandomRange(-3, 3)*FRACUNIT, P_RandomRange(-3, 3)*FRACUNIT, P_RandomRange(7, 14)*FRACUNIT
					for i = 1, 9
						local curangle = ANG1*40*i

						local dust = P_SpawnMobj(target.x+(12*cos(curangle)), target.y+(12*sin(curangle)), target.z+(12*FRACUNIT), MT_DUMMY)
						dust.flags = $|MF_NOGRAVITY|MF_NOCLIPHEIGHT
						dust.state, dust.scale, dust.angle = S_BUFUDYNE_DUST1, FRACUNIT*3/4, curangle
						dust.destscale = FRACUNIT*2
						dust.scalespeed = FRACUNIT/18
						P_InstaThrust(dust, dust.angle, 6*FRACUNIT)
						dust.momz = 3*FRACUNIT/2
					end
					P_RemoveMobj(v)
				end
				playSound(mo.battlen, sfx_bufu2)
				damageObject(target)
			elseif (timer == 90)
				target.bufus = nil
				return true
			end
		end,
	},

	["mabufu"] = {
		name = "Mabufu",
		type = ATK_ICE,
		power = 60,
		accuracy = 90,
		costtype = CST_SP,
		cost = 8,
		status = COND_FREEZE,
		statuschance = 2,
		desc = "Light Ice dmg to all enemies. \nMay inflict freeze.",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)
			for k, e in ipairs(hittargets)
				local time = timer - 10*(k-1)
				local target = e

				if time == 25
					playSound(mo.battlen, sfx_bufu3)
				end

				if (time >= 21 and time <= 54) and (target.bufus and #target.bufus)
					if not (leveltime%2)
						for i = 1, 2
							local bs_target = target.bufus[P_RandomRange(1, #target.bufus)]
							local bs_scales = {FRACUNIT/2, FRACUNIT*3/4, FRACUNIT}

							local d = 30 -- i got lazy
							local bs = P_SpawnMobj(bs_target.x+(P_RandomRange(-(d), d)*bs_target.scale), bs_target.y+(P_RandomRange(-(d), d)*bs_target.scale), bs_target.z+(P_RandomRange(0, d*3/2)*bs_target.scale), MT_BUFU)
							bs.state, bs.scale, bs.color = S_BUFU_PARTICLE_D, bs_scales[P_RandomRange(1, #bs_scales)], SKINCOLOR_CYAN
							bs.momz = P_RandomRange(-1, 1)*FRACUNIT
							bs.fuse = TICRATE*5
						end
					end
				end
				if (time == 5) -- setup table to store bufu stuff
					target.bufus = {}
				elseif (time >= 21 and time <= 27)
					if not (time%3)
						for i = 1, P_RandomRange(2, 3)
							local bufu_destscales = {FRACUNIT*11/10, FRACUNIT*5/4, FRACUNIT*13/10} -- 1.20, 1.25, 1.30
							local b = P_SpawnMobj(target.x+P_RandomRange(-25, 25)*FRACUNIT, target.y+P_RandomRange(-25, 25)*FRACUNIT, target.z, MT_BUFU)
							b.state, b.scale = S_BUFU, FRACUNIT/3
							b.destscale = bufu_destscales[P_RandomRange(1, #bufu_destscales)]
							b.momz, b.risetime = P_RandomRange(3, 7)*FRACUNIT, P_RandomRange(4, 6)
							target.bufus[#target.bufus+1] = b
							b.fuse = TICRATE*5
						end
					end
				elseif (time >= 47 and time <= 54)
					for k, v in ipairs(target.bufus)
						v.sx, v.sy, v.sz = $ or v.x, $ or v.y, $ or v.z
						P_TeleportMove(v, v.sx+P_RandomRange(-2, 2)*v.scale, v.sy+P_RandomRange(-2, 2)*v.scale, v.sz+P_RandomRange(-2, 2)*v.scale)
						if (timer == 53) then v.state = S_BUFU_FLASH end
					end
				elseif (time == 55)
					for k, v in ipairs(target.bufus)
						local ba = P_SpawnMobj(v.x, v.y, v.z, MT_BUFU_PARTICLE)
						ba.state, ba.scale = S_BUFU_PARTICLE_A, v.scale
						ba.momx, ba.momy, ba.momz = P_RandomRange(-5, 5)*FRACUNIT, P_RandomRange(-5, 5)*FRACUNIT, P_RandomRange(5, 11)*FRACUNIT

						local bb = P_SpawnMobj(v.x, v.y, v.z, MT_BUFU_PARTICLE)
						bb.state, bb.scale = S_BUFU_PARTICLE_B, v.scale
						bb.momx, bb.momy, bb.momz = P_RandomRange(-3, 3)*FRACUNIT, P_RandomRange(-3, 3)*FRACUNIT, P_RandomRange(7, 14)*FRACUNIT
						for i = 1, 9
							local curangle = ANG1*40*i

							local dust = P_SpawnMobj(target.x+(12*cos(curangle)), target.y+(12*sin(curangle)), target.z+(12*FRACUNIT), MT_DUMMY)
							dust.flags = $|MF_NOGRAVITY|MF_NOCLIPHEIGHT
							dust.state, dust.scale, dust.angle = S_BUFUDYNE_DUST1, FRACUNIT*3/4, curangle
							dust.destscale = FRACUNIT*2
							dust.scalespeed = FRACUNIT/18
							P_InstaThrust(dust, dust.angle, 6*FRACUNIT)
							dust.momz = 3*FRACUNIT/2
						end
						P_RemoveMobj(v)
					end
					playSound(mo.battlen, sfx_bufu2)
					damageObject(target)
				elseif (timer == 90 + (#targets-1)*10)
					target.bufus = nil
					return true
				end
			end
		end,
	},

	["bufula"] = {
		name = "Bufula",
		type = ATK_ICE,
		power = 140,
		accuracy = 95,
		costtype = CST_SP,
		cost = 8,
		status = COND_FREEZE,
		statuschance = 5,
		desc = "Medium Ice dmg to one enemy. \nMay inflict freeze.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]
			if (timer >= 20 and timer <= 58) and (target.bufulas and #target.bufulas)
				if not (leveltime%2)
					for i = 1, 2
						local bs_target = target.bufulas[P_RandomRange(1, #target.bufulas)]
						local bs_scales = {FRACUNIT*3/4, FRACUNIT, FRACUNIT*5/4}

						local d = 30
						local bs = P_SpawnMobj(bs_target.x+(P_RandomRange(-(d), d)*bs_target.scale), bs_target.y+(P_RandomRange(-(d), d)*bs_target.scale), bs_target.z+(P_RandomRange(0, d*3/2)*bs_target.scale), MT_BUFU)
						bs.state, bs.scale, bs.color = S_BUFU_PARTICLE_D, bs_scales[P_RandomRange(1, #bs_scales)], SKINCOLOR_CYAN
						bs.momz = P_RandomRange(-1, 1)*FRACUNIT
					end
				end
			end
			if (timer == 5) -- setup table to store bufu stuff
				target.bufulas = {}
			elseif (timer >= 21 and timer <= 30)
				if not (timer%3)

					playSound(mo.battlen, sfx_bufu3)

					target.bs = $ and $+1 or 1
					local b = P_SpawnMobj(target.x+P_RandomRange(-30, 30)*FRACUNIT, target.y+P_RandomRange(-30, 30)*FRACUNIT, target.z+P_RandomRange(5, 20)*FRACUNIT, MT_BUFU)
					b.state, b.scale = S_BUFULA_LR, FRACUNIT/3
					b.destscale, b.scalespeed = FRACUNIT*165/100+(FRACUNIT/4*(target.bs-1)), FRACUNIT/6
					target.bufulas[#target.bufulas+1] = b
				end
			elseif (timer >= 51 and timer <= 58) -- 7 frames shaking
				for k, v in ipairs(target.bufulas)
					v.sx, v.sy, v.sz = $ or v.x, $ or v.y, $ or v.z
					P_TeleportMove(v, v.sx+P_RandomRange(-2, 2)*v.scale, v.sy+P_RandomRange(-2, 2)*v.scale, v.sz+P_RandomRange(-2, 2)*v.scale)
					if (timer == 57) then v.state = (v.frame == 5 and S_BUFULA_FLASH_A or S_BUFULA_FLASH_B) end
				end
			elseif (timer == 59)
				for k, v in ipairs(target.bufulas)
					for i = 1, 2
						local bp = P_SpawnMobj(v.x, v.y, v.z, MT_BUFU_PARTICLE)
						bp.state, bp.scale = S_BUFULA_PARTICLE, FRACUNIT*3/2
						bp.momx, bp.momy, bp.momz = P_RandomRange(-6, 6)*FRACUNIT, P_RandomRange(-6, 6)*FRACUNIT, P_RandomRange(13, 18)*FRACUNIT
					end
					for i = 1, 2
						local ba = P_SpawnMobj(v.x, v.y, v.z, MT_BUFU_PARTICLE)
						ba.state, ba.scale = S_BUFU_PARTICLE_A, FRACUNIT*3/2
						ba.momx, ba.momy, ba.momz = P_RandomRange(-7, 7)*FRACUNIT, P_RandomRange(-7, 7)*FRACUNIT, P_RandomRange(5, 11)*FRACUNIT
					end
					local bb = P_SpawnMobj(v.x, v.y, v.z, MT_BUFU_PARTICLE)
					bb.state, bb.scale = S_BUFU_PARTICLE_B, FRACUNIT*3/2
					bb.momx, bb.momy, bb.momz = P_RandomRange(-4, 4)*FRACUNIT, P_RandomRange(-4, 4)*FRACUNIT, P_RandomRange(7, 14)*FRACUNIT
					for i = 1, 9
						local curangle = ANG1*40*i

						local dust = P_SpawnMobj(target.x+(18*cos(curangle)), target.y+(18*sin(curangle)), target.z+(5*FRACUNIT), MT_DUMMY)
						dust.flags = $|MF_NOGRAVITY|MF_NOCLIPHEIGHT
						dust.state, dust.scale, dust.angle = S_BUFUDYNE_DUST1, FRACUNIT, curangle
						dust.destscale = FRACUNIT*9/4
						dust.scalespeed = FRACUNIT/18
						P_InstaThrust(dust, dust.angle, 9*FRACUNIT)
						dust.momz = 5*FRACUNIT/2
					end
					P_RemoveMobj(v)
				end
				playSound(mo.battlen, sfx_bufu4)
				damageObject(target)
			elseif (timer == 95)
				target.bufulas, target.bs = nil, nil
				return true
			end
		end,
	},

	["mabufula"] = {
		name = "Mabufula",
		type = ATK_ICE,
		power = 140,
		accuracy = 90,
		costtype = CST_SP,
		cost = 16,
		status = COND_FREEZE,
		statuschance = 2,
		desc = "Medium Ice dmg to all enemies. \nMay inflict freeze.",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)
			for k, e in ipairs(hittargets)
				local time = timer - 10*(k-1)
				local target = e
				if (time >= 20 and time <= 58) and (target.bufulas and #target.bufulas)
					if not (leveltime%2)
						for i = 1, 2
							local bs_target = target.bufulas[P_RandomRange(1, #target.bufulas)]
							local bs_scales = {FRACUNIT*3/4, FRACUNIT, FRACUNIT*5/4}

							local d = 30
							local bs = P_SpawnMobj(bs_target.x+(P_RandomRange(-(d), d)*bs_target.scale), bs_target.y+(P_RandomRange(-(d), d)*bs_target.scale), bs_target.z+(P_RandomRange(0, d*3/2)*bs_target.scale), MT_BUFU)
							bs.state, bs.scale, bs.color = S_BUFU_PARTICLE_D, bs_scales[P_RandomRange(1, #bs_scales)], SKINCOLOR_CYAN
							bs.momz = P_RandomRange(-1, 1)*FRACUNIT
						end
					end
				end
				if (time == 5) -- setup table to store bufu stuff
					target.bufulas = {}
				elseif (time >= 21 and time <= 30)
					if not (timer%3)

						playSound(mo.battlen, sfx_bufu3)

						target.bs = $ and $+1 or 1
						local b = P_SpawnMobj(target.x+P_RandomRange(-30, 30)*FRACUNIT, target.y+P_RandomRange(-30, 30)*FRACUNIT, target.z+P_RandomRange(5, 20)*FRACUNIT, MT_BUFU)
						b.state, b.scale = S_BUFULA_LR, FRACUNIT/3
						b.destscale, b.scalespeed = FRACUNIT*165/100+(FRACUNIT/4*(target.bs-1)), FRACUNIT/6
						target.bufulas[#target.bufulas+1] = b
					end
				elseif (time >= 51 and time <= 58) -- 7 frames shaking
					for k, v in ipairs(target.bufulas)
						v.sx, v.sy, v.sz = $ or v.x, $ or v.y, $ or v.z
						P_TeleportMove(v, v.sx+P_RandomRange(-2, 2)*v.scale, v.sy+P_RandomRange(-2, 2)*v.scale, v.sz+P_RandomRange(-2, 2)*v.scale)
						if (time == 57) then v.state = (v.frame == 5 and S_BUFULA_FLASH_A or S_BUFULA_FLASH_B) end
					end
				elseif (time == 59)
					for k, v in ipairs(target.bufulas)
						for i = 1, 2
							local bp = P_SpawnMobj(v.x, v.y, v.z, MT_BUFU_PARTICLE)
							bp.state, bp.scale = S_BUFULA_PARTICLE, FRACUNIT*3/2
							bp.momx, bp.momy, bp.momz = P_RandomRange(-6, 6)*FRACUNIT, P_RandomRange(-6, 6)*FRACUNIT, P_RandomRange(13, 18)*FRACUNIT
						end
						for i = 1, 2
							local ba = P_SpawnMobj(v.x, v.y, v.z, MT_BUFU_PARTICLE)
							ba.state, ba.scale = S_BUFU_PARTICLE_A, FRACUNIT*3/2
							ba.momx, ba.momy, ba.momz = P_RandomRange(-7, 7)*FRACUNIT, P_RandomRange(-7, 7)*FRACUNIT, P_RandomRange(5, 11)*FRACUNIT
						end
						local bb = P_SpawnMobj(v.x, v.y, v.z, MT_BUFU_PARTICLE)
						bb.state, bb.scale = S_BUFU_PARTICLE_B, FRACUNIT*3/2
						bb.momx, bb.momy, bb.momz = P_RandomRange(-4, 4)*FRACUNIT, P_RandomRange(-4, 4)*FRACUNIT, P_RandomRange(7, 14)*FRACUNIT
						for i = 1, 9
							local curangle = ANG1*40*i

							local dust = P_SpawnMobj(target.x+(18*cos(curangle)), target.y+(18*sin(curangle)), target.z+(5*FRACUNIT), MT_DUMMY)
							dust.flags = $|MF_NOGRAVITY|MF_NOCLIPHEIGHT
							dust.state, dust.scale, dust.angle = S_BUFUDYNE_DUST1, FRACUNIT, curangle
							dust.destscale = FRACUNIT*9/4
							dust.scalespeed = FRACUNIT/18
							P_InstaThrust(dust, dust.angle, 9*FRACUNIT)
							dust.momz = 5*FRACUNIT/2
						end
						P_RemoveMobj(v)
					end
					playSound(mo.battlen, sfx_bufu4)
					damageObject(target)
				elseif (timer == 95 + (#targets-1)*10)
					target.bufulas, target.bs = nil, nil
					return true
				end
			end
		end,
	},

	["bufudyne"] = {
		name = "Bufudyne",
		type = ATK_ICE,
		power = 350,
		accuracy = 95,
		costtype = CST_SP,
		cost = 12,
		status = COND_FREEZE,
		statuschance = 5,
		desc = "Heavy Ice dmg to one enemy. \nMay inflict freeze.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]
			if (timer >= 20 and timer <= 79) and (target.bd and target.bd.valid)
				local bs_scales = {FRACUNIT, FRACUNIT*5/4, FRACUNIT*3/2}
				-- this doesnt even WORK as intended but it's so fast nobody will notice
				if (target.bd.frame & 0)
					target.bd.sparkheight = 50
				elseif (target.bd.frame & 1)
					target.bd.sparkheight = 86
				elseif (target.bd.frame & 2)
					target.bd.sparkheight = 128
				else
					target.bd.sparkheight = 190
				end

				local bs = P_SpawnMobj(target.bd.x+(P_RandomRange(-60, 60)*target.bd.scale), target.bd.y+(P_RandomRange(-60, 60)*target.bd.scale), target.bd.z+(P_RandomRange(0, target.bd.sparkheight)*target.bd.scale), MT_BUFU)
				bs.state, bs.scale, bs.color = S_BUFU_PARTICLE_D, bs_scales[P_RandomRange(1, #bs_scales)], SKINCOLOR_CYAN
				bs.momz = P_RandomRange(-1, 1)*FRACUNIT

				if (timer <= 51)
					local baseangle = P_RandomRange(1, 360)*ANG1
					local dist = 48
					for i = 0, 12
						local angle = baseangle + i*6*ANG1
						local x, y = target.bd.x + dist*cos(angle), target.bd.y + dist*sin(angle)

						local aura = P_SpawnMobj(x, y, target.bd.z+i*FRACUNIT*3, MT_DUMMY)
						aura.state = S_BUFUDYNE_AURA1
						aura.angle = angle - ANGLE_90
						aura.color = SKINCOLOR_WHITE
						aura.momz = P_RandomRange(2, 9)*FRACUNIT
						aura.scale = FRACUNIT/2
						aura.destscale = FRACUNIT*3/2
						P_InstaThrust(aura, angle, FRACUNIT*P_RandomRange(3, 5))
					end
				end
			end
			if (timer == 20)
				playSound(mo.battlen, sfx_bufu5)
				target.bd = P_SpawnMobj(target.x, target.y, target.z, MT_BUFU)
				target.bd.state, target.bd.scale = S_BUFUDYNE_A1, FRACUNIT*3/2
			elseif (timer >= 72 and timer <= 79)
				local bd = target.bd -- I'm lazy
				P_TeleportMove(bd, target.x+(P_RandomRange(-2, 2)*bd.scale), target.y+(P_RandomRange(-2, 2)*bd.scale), target.z)
				if (timer == 78)
					bd.state = S_BUFUDYNE_BF
				end
			elseif (timer == 80)
				for i = 1, P_RandomRange(17, 20)
					local ba = P_SpawnMobj(target.bd.x+(P_RandomRange(-20, 20)*target.bd.scale), target.bd.y+(P_RandomRange(-20, 20)*target.bd.scale), target.bd.z+(P_RandomRange(0, 128)*target.bd.scale), MT_BUFU_PARTICLE)
					ba.state, ba.scale = S_BUFU_PARTICLE_A, FRACUNIT*7/4
					ba.momx, ba.momy, ba.momz = P_RandomRange(-13, 13)*FRACUNIT, P_RandomRange(-13, 13)*FRACUNIT, P_RandomRange(6, 19)*FRACUNIT
				end
				for i = 1, P_RandomRange(11, 13)
					local bb = P_SpawnMobj(target.bd.x+(P_RandomRange(-20, 20)*target.bd.scale), target.bd.y+(P_RandomRange(-20, 20)*target.bd.scale), target.bd.z+(P_RandomRange(0, 128)*target.bd.scale), MT_BUFU_PARTICLE)
					bb.state, bb.scale = S_BUFU_PARTICLE_B, FRACUNIT*7/4
					bb.momx, bb.momy, bb.momz = P_RandomRange(-9, 9)*FRACUNIT, P_RandomRange(-9, 9)*FRACUNIT, P_RandomRange(9, 23)*FRACUNIT
				end
				for i = 1, 9
					local curangle = ANG1*40*i

					local dust = P_SpawnMobj(target.bd.x+(24*cos(curangle)), target.bd.y+(24*sin(curangle)), target.bd.z, MT_DUMMY)
					dust.flags = $|MF_NOGRAVITY|MF_NOCLIPHEIGHT
					dust.state, dust.scale, dust.angle = S_BUFUDYNE_DUST1, FRACUNIT*5/4, curangle
					dust.destscale = FRACUNIT*5/2
					dust.scalespeed = FRACUNIT/18
					P_InstaThrust(dust, dust.angle, 12*FRACUNIT)
					dust.momz = 4*FRACUNIT
				end
				P_RemoveMobj(target.bd)
				playSound(mo.battlen, sfx_bufu6)
				damageObject(target)
				localquake(mo.battlen, FRACUNIT*20, 10)
			elseif (timer == 110)
				target.bd = nil
				return true
			end
		end,
	},

	["mabufudyne"] = {
		name = "Mabufudyne",
		type = ATK_ICE,
		power = 350,
		accuracy = 90,
		costtype = CST_SP,
		cost = 24,
		status = COND_FREEZE,
		statuschance = 2,
		desc = "Heavy Ice dmg to all enemies. \nMay inflict freeze.",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)
			for k, e in ipairs(hittargets)
				local time = timer - 10*(k-1)
				local target = e
				if (time >= 20 and time <= 79) and (target.bd and target.bd.valid)
					local bs_scales = {FRACUNIT, FRACUNIT*5/4, FRACUNIT*3/2}
					-- this doesnt even WORK as intended but it's so fast nobody will notice
					if (target.bd.frame & 0)
						target.bd.sparkheight = 50
					elseif (target.bd.frame & 1)
						target.bd.sparkheight = 86
					elseif (target.bd.frame & 2)
						target.bd.sparkheight = 128
					else
						target.bd.sparkheight = 190
					end

					local bs = P_SpawnMobj(target.bd.x+(P_RandomRange(-60, 60)*target.bd.scale), target.bd.y+(P_RandomRange(-60, 60)*target.bd.scale), target.bd.z+(P_RandomRange(0, target.bd.sparkheight)*target.bd.scale), MT_BUFU)
					bs.state, bs.scale, bs.color = S_BUFU_PARTICLE_D, bs_scales[P_RandomRange(1, #bs_scales)], SKINCOLOR_CYAN
					bs.momz = P_RandomRange(-1, 1)*FRACUNIT

					if (time <= 51)
						local baseangle = P_RandomRange(1, 360)*ANG1
						local dist = 48
						for i = 0, 12
							local angle = baseangle + i*6*ANG1
							local x, y = target.bd.x + dist*cos(angle), target.bd.y + dist*sin(angle)

							local aura = P_SpawnMobj(x, y, target.bd.z+i*FRACUNIT*3, MT_DUMMY)
							aura.state = S_BUFUDYNE_AURA1
							aura.angle = angle - ANGLE_90
							aura.color = SKINCOLOR_WHITE
							aura.momz = P_RandomRange(2, 9)*FRACUNIT
							aura.scale = FRACUNIT/2
							aura.destscale = FRACUNIT*3/2
							P_InstaThrust(aura, angle, FRACUNIT*P_RandomRange(3, 5))
						end
					end
				end
				if (time == 20)
					playSound(mo.battlen, sfx_bufu5)
					target.bd = P_SpawnMobj(target.x, target.y, target.z, MT_BUFU)
					target.bd.state, target.bd.scale = S_BUFUDYNE_A1, FRACUNIT*3/2
				elseif (time >= 72 and time <= 79)
					local bd = target.bd -- I'm lazy
					P_TeleportMove(bd, target.x+(P_RandomRange(-2, 2)*bd.scale), target.y+(P_RandomRange(-2, 2)*bd.scale), target.z)
					if (time == 78)
						bd.state = S_BUFUDYNE_BF
					end
				elseif (time == 80)
					for i = 1, P_RandomRange(17, 20)
						local ba = P_SpawnMobj(target.bd.x+(P_RandomRange(-20, 20)*target.bd.scale), target.bd.y+(P_RandomRange(-20, 20)*target.bd.scale), target.bd.z+(P_RandomRange(0, 128)*target.bd.scale), MT_BUFU_PARTICLE)
						ba.state, ba.scale = S_BUFU_PARTICLE_A, FRACUNIT*7/4
						ba.momx, ba.momy, ba.momz = P_RandomRange(-13, 13)*FRACUNIT, P_RandomRange(-13, 13)*FRACUNIT, P_RandomRange(6, 19)*FRACUNIT
					end
					for i = 1, P_RandomRange(11, 13)
						local bb = P_SpawnMobj(target.bd.x+(P_RandomRange(-20, 20)*target.bd.scale), target.bd.y+(P_RandomRange(-20, 20)*target.bd.scale), target.bd.z+(P_RandomRange(0, 128)*target.bd.scale), MT_BUFU_PARTICLE)
						bb.state, bb.scale = S_BUFU_PARTICLE_B, FRACUNIT*7/4
						bb.momx, bb.momy, bb.momz = P_RandomRange(-9, 9)*FRACUNIT, P_RandomRange(-9, 9)*FRACUNIT, P_RandomRange(9, 23)*FRACUNIT
					end
					for i = 1, 9
						local curangle = ANG1*40*i

						local dust = P_SpawnMobj(target.bd.x+(24*cos(curangle)), target.bd.y+(24*sin(curangle)), target.bd.z, MT_DUMMY)
						dust.flags = $|MF_NOGRAVITY|MF_NOCLIPHEIGHT
						dust.state, dust.scale, dust.angle = S_BUFUDYNE_DUST1, FRACUNIT*5/4, curangle
						dust.destscale = FRACUNIT*5/2
						dust.scalespeed = FRACUNIT/18
						P_InstaThrust(dust, dust.angle, 12*FRACUNIT)
						dust.momz = 4*FRACUNIT
					end
					P_RemoveMobj(target.bd)
					playSound(mo.battlen, sfx_bufu6)
					damageObject(target)
					localquake(mo.battlen, FRACUNIT*20, 10)
				elseif (timer == 110 + (#targets-1)*10)
					target.bd = nil
					return true
				end
			end
		end,
	},

	["niflheim"] = {
		name = "Niflheim",
		type = ATK_ICE,
		power = 650,
		accuracy = 100,
		costtype = CST_SP,
		cost = 32,
		status = COND_FREEZE,
		statuschance = 10,
		desc = "Severe Ice dmg to one enemy. \nHigh chance of freeze.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)
			local target = hittargets[1]
			if (timer >= 20 and timer <= 150) and (target.bd and target.bd.valid)

				local bs = P_SpawnMobj(target.bd.x+(P_RandomRange(-512, 512)*mo.scale), target.bd.y+(P_RandomRange(-512, 512)*mo.scale), target.bd.z+(P_RandomRange(0, 512)*mo.scale), MT_BUFU)
				bs.state, bs.color = S_BUFU_PARTICLE_D, SKINCOLOR_CYAN
				bs.momz = P_RandomRange(-1, 1)*FRACUNIT

				if (timer <= 150)
					local baseangle = P_RandomRange(1, 360)*ANG1
					local dist = 48
					for i = 0, 12
						local angle = baseangle + i*6*ANG1
						local x, y = target.bd.x + dist*cos(angle), target.bd.y + dist*sin(angle)

						local aura = P_SpawnMobj(x, y, target.z+i*FRACUNIT*3, MT_DUMMY)
						aura.state = S_BUFUDYNE_AURA1
						aura.angle = angle - ANGLE_90
						aura.color = SKINCOLOR_WHITE
						aura.momz = P_RandomRange(2, 9)*FRACUNIT
						aura.scale = FRACUNIT*3/4
						aura.destscale = FRACUNIT*2
						P_InstaThrust(aura, angle, FRACUNIT*P_RandomRange(5, 8))
					end
				end
			end
			if (timer == 40)
				playSound(mo.battlen, sfx_bufu5)
				target.bd = P_SpawnMobj(target.x, target.y, target.z + mo.scale*128, MT_DUMMY)
				target.bd.tics = -1
				target.bd.scale = FRACUNIT/6
				target.bd.destscale = FRACUNIT*2
				target.bd.scalespeed = FRACUNIT/48
				target.bd.sprite = SPR_BFDA
				target.bd.frame = J|FF_FULLBRIGHT

			elseif (timer == 65)
				playSound(mo.battlen, sfx_bufu2)
				target.bd.scale = FRACUNIT*2 + FRACUNIT/16
				target.bd.destscale = target.bd.scale
				target.bd.frame = K|FF_FULLBRIGHT

				local g = P_SpawnGhostMobj(target.bd)
				g.destscale = FRACUNIT*4
				g.scalespeed = FRACUNIT/6

			elseif (timer == 67)
				target.bd.scale = FRACUNIT*2
				target.bd.frame = J|FF_FULLBRIGHT

			elseif (timer >= 80 and timer < 90)
				P_TeleportMove(target.bd, target.x + P_RandomRange(-8, 8)*mo.scale, target.y + P_RandomRange(-8, 8), target.z + 128*mo.scale + P_RandomRange(-8, 8)*mo.scale)


			elseif (timer == 90)

				local g = P_SpawnGhostMobj(target.bd)
				g.destscale = FRACUNIT*4
				g.scalespeed = FRACUNIT/4
				localquake(mo.battlen, FRACUNIT*32, 16)

				for i = 1, P_RandomRange(17, 32)
					local ba = P_SpawnMobj(target.bd.x+(P_RandomRange(-50, 50)*target.bd.scale), target.bd.y+(P_RandomRange(-50, 50)*target.bd.scale), target.bd.z+(P_RandomRange(0, 128)*target.bd.scale), MT_BUFU_PARTICLE)
					ba.state, ba.scale = S_BUFU_PARTICLE_A, FRACUNIT*7/4
					ba.momx, ba.momy, ba.momz = P_RandomRange(-13, 13)*FRACUNIT, P_RandomRange(-13, 13)*FRACUNIT, P_RandomRange(6, 19)*FRACUNIT
				end
				for i = 1, P_RandomRange(11, 32)
					local bb = P_SpawnMobj(target.bd.x+(P_RandomRange(-50, 50)*target.bd.scale), target.bd.y+(P_RandomRange(-50, 50)*target.bd.scale), target.bd.z+(P_RandomRange(0, 128)*target.bd.scale), MT_BUFU_PARTICLE)
					bb.state, bb.scale = S_BUFU_PARTICLE_B, FRACUNIT*7/4
					bb.momx, bb.momy, bb.momz = P_RandomRange(-9, 9)*FRACUNIT, P_RandomRange(-9, 9)*FRACUNIT, P_RandomRange(9, 23)*FRACUNIT
				end
				for i = 1, 9
					local curangle = ANG1*40*i

					local dust = P_SpawnMobj(target.bd.x+(24*cos(curangle)), target.bd.y+(24*sin(curangle)), target.bd.z, MT_DUMMY)
					dust.flags = $|MF_NOGRAVITY|MF_NOCLIPHEIGHT
					dust.state, dust.scale, dust.angle = S_BUFUDYNE_DUST1, FRACUNIT*5/4, curangle
					dust.destscale = FRACUNIT*5/2
					dust.scalespeed = FRACUNIT/18
					P_InstaThrust(dust, dust.angle, 12*FRACUNIT)
					dust.momz = 4*FRACUNIT
				end
				P_RemoveMobj(target.bd)
				playSound(mo.battlen, sfx_bufu6)
				damageObject(target)
				localquake(mo.battlen, FRACUNIT*20, 10)
			elseif (timer == 160)
				target.bd = nil
				return true
			end
		end,
	},

	["super"] = {	-- skill used to activate super form
		name = "Super Form",
		type = ATK_ALMIGHTY,
		power = 0,
		accuracy = 0,
		costtype = CST_SP,
		norandom = true,	-- Don't allow this move to be selected in random pvp skills
		cost = 0,
		desc = "Kanade best waifu.\nThat is factual.",
		target = TGT_CASTER,
		anim =	function(mo, targets, hittargets, timer)

					if timer >= TICRATE*2/3
						mo.momz = $*90/100
					elseif timer >= 1
						mo.momz = FRACUNIT
						mo.flags = $|MF_NOGRAVITY	-- lol
					end

					if timer == 1

						local cx = mo.x + 256*cos(mo.angle + ANG1*20)
						local cy = mo.y + 256*sin(mo.angle + ANG1*20)
						CAM_goto(server.P_BattleStatus[mo.battlen].cam, cx, cy, mo.z + FRACUNIT*30, 70*FRACUNIT)
						CAM_angle(server.P_BattleStatus[mo.battlen].cam, R_PointToAngle2(cx, cy, mo.x, mo.y))

						mo.anim = nil	-- kind of a hack
						mo.state = S_PLAY_FALL
					end

					-- spawn the emeralds:
					if timer == TICRATE/2
						mo.emeralds = {}
						mo.em_rotspeed = 1
						mo.em_ang = 0
						mo.em_dist = 1024

						for i = 1, 7
							mo.emeralds[i] = P_SpawnMobj(0, 0, 0, MT_EMERALD1+(i-1))
							mo.emeralds[i].scale = $*3/2
						end
					end

					if timer >= TICRATE/2
					and mo.emeralds and mo.emeralds[1] and mo.emeralds[1].valid


						local ang = mo.em_ang
						for i = 1, 7
							local x = mo.x + mo.em_dist*cos(ang)
							local y = mo.y + mo.em_dist*sin(ang)
							local z = mo.z + 32*cos(leveltime*ANG1*2 + (360/7)*ANG1*i)	-- funny z axis variation

							P_TeleportMove(mo.emeralds[i], x, y, z)
							ang = $ + (360/7)*ANG1
						end

						mo.em_ang = $+ mo.em_rotspeed*ANG1
						mo.em_rotspeed = min(32, $+1)
						mo.em_dist = max(64, $-24)
					end

					if timer == TICRATE*2
						for i = 1, 7 do
							P_RemoveMobj(mo.emeralds[i])
						end
						mo.emeralds = nil

						mo.state = S_PLAY_SUPER_TRANS1
						for k,v in ipairs(mo.allies)
							if v and v.control and v.control.valid
								P_FlashPal(v.control, 1, 8)
							end
						end
						S_StartSound(mo, sfx_s3k9f)
						mo.status_condition = COND_SUPER	-- direct affectation
					end

					if timer >= TICRATE*2
						if mo.state == S_PLAY_SUPER_TRANS6
							mo.tics = -1
						end
					end

					if timer == TICRATE*3 + TICRATE/2
						mo.z = mo.floorz
						mo.flags = $ & ~MF_NOGRAVITY
						return true	-- actually fuck that
					end
					/*
					if mo.waitforground and P_IsObjectOnGround(mo)
						ANIM_set(mo, mo.anim_stand)
						mo.waitforground = nil
					end

					if timer == TICRATE*4 + TICRATE/2
						return true
					end*/
				end,
	},

	["run"] = {	-- skill used to run away, ends battle instantly
		name = "Run",
		type = ATK_ALMIGHTY,
		power = 0,
		accuracy = 0,
		costtype = CST_SP,
		cost = 0,
		norandom = true,	-- Don't allow this move to be selected in random pvp skills
		desc = "",
		target = TGT_CASTER,
		physical = true,
		anim = function(mo, targets, hittargets, timer)

				if not mo.plyr
					--BTL_logMessage(targets[1].battlen, "UNSUPPORTED\nuse 'enemy_run' instead.")

					if timer >= TICRATE

						if timer == TICRATE
							mo.angle = $+ANG1*180
							mo.tflag = 0
							ANIM_set(mo, mo.anim_run, true)
						end
						P_InstaThrust(mo, mo.angle, FRACUNIT*18)

						if leveltime%2 == 0
							if mo.tflag < 9
								mo.tflag = $+1
							else
								mo.flags2 = $|MF2_DONTDRAW
							end
						end
						mo.frame = (mo.frame & ~FF_TRANSMASK)|(mo.tflag << FF_TRANSSHIFT)

						if timer == TICRATE*2 + TICRATE/2
							mo.hp = 0		-- this will auto remove it
							return true
						end
					end

					return
				end

				if timer >= TICRATE/2
					for i = 1, #mo.allies do
						local m = mo.allies[i]
						if timer == TICRATE/2
							m.angle = $+ANG1*180
							ANIM_set(m, m.anim_run, true)
						end
						P_InstaThrust(m, m.angle, FRACUNIT*18)
					end

					if timer == TICRATE/2
						for i = 1, #mo.enemies do
							local m = mo.enemies[i]
							local excl = P_SpawnMobj(m.x, m.y, m.z+90*FRACUNIT, MT_DUMMY)
							excl.flags = MF_NOCLIPHEIGHT|MF_NOGRAVITY|MF_NOBLOCKMAP
							excl.scale = 1
							excl.destscale = FRACUNIT*2
							excl.scalespeed = FRACUNIT/2
							excl.sprite = SPR_XCLA
							excl.frame = A|FF_FULLBRIGHT
							excl.fuse = 20
							excl.momx = P_RandomRange(-3, 3)*FRACUNIT
							excl.momy = P_RandomRange(-3, 3)*FRACUNIT
						end
					end

					if timer == TICRATE*2
						-- remove enemies from the table and end the battle
						local j = #mo.enemies
						while j
							local e = mo.enemies[j]
							e.hp = 0
							e.extra = nil
							e.fuse = 10
							table.remove(mo.enemies, j)
							j = $-1
						end

						server.P_BattleStatus[mo.battlen].netstats.runaways = $ +1
						server.P_BattleStatus[mo.battlen].runaway = true

						return true
					end
				end
			end,
	},


	-- KAN

	["fitness"] = {
		name = "Physical Fitness",
		type = ATK_ALMIGHTY,
		power = 2,
		hits = 25,
		accuracy = 80,
		critical = 1,
		costtype = CST_HPPERCENT,
		cost = 20,
		desc = "BECAUSE YOUR FITNESS\nIS MY BUSINESS",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)

				local t = hittargets[1]

				if timer == 20
					playSound(mo.battlen, sfx_batk7)
					t.hits = 0
				end

				if timer >= TICRATE
				and timer <= TICRATE*5

					if timer%2
						local ang = P_RandomRange(0, 359)*ANG1
						local x = t.x + 256*cos(ang)
						local y = t.y + 256*sin(ang)

						local maso = P_SpawnMobj(x, y, t.z + P_RandomRange(32, 64)*FRACUNIT, MT_DUMMY)
						maso.sprite = SPR_MASO
						maso.tics = -1
						maso.frame = A
						maso.momx = (t.x - maso.x)/4
						maso.momy = (t.y - maso.y)/4
						maso.momz = (t.z - maso.z)/4
					end

					if timer%10 == 0
						local shot = P_SpawnMobj(t.x + P_RandomRange(-256, 256)*FRACUNIT, t.y + P_RandomRange(-256, 256)*FRACUNIT, t.z + P_RandomRange(0, 128)*FRACUNIT, MT_DUMMY)
						shot.state = S_STAB_1_1
						shot.color = SKINCOLOR_ORANGE
						playSound(mo.battlen, sfx_hit)
					end
				end

				if timer >= TICRATE*3/2
				and t.hits < 25
				and timer%6 == 0
					damageObject(t)
					t.hits = $+1
				end

				if timer == TICRATE*6
					--print(t.hits)
					t.hits = 0
					return true
				end

		end,
	},

	["kannon"] = {
		name = "KANNON!!!",
		type = ATK_ALMIGHTY,
		power = 1800,
		accuracy = 999,
		costtype = CST_SP,
		cost = 32,
		critical = 3,
		desc = "I WILL FIRE A HUGE LASER\nMY TEDDIES!",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)

			local target = hittargets[1]

			if timer == 1
				mo.columns = {}
				playSound(mo.battlen, sfx_batk5)
			end

			if timer >= 10 and timer <= 30
			and (timer%5) == 0

				local s = P_SpawnMobj(mo.x + P_RandomRange(-128, 128)<<FRACBITS, mo.y + P_RandomRange(-128, 128)<<FRACBITS, mo.z + P_RandomRange(0, 256)<<FRACBITS, MT_DUMMY)
				s.color = SKINCOLOR_WHITE
				s.state = S_MEGISTAR1
				s.scale = $*2 + P_RandomRange(0, 65535)
				playSound(mo.battlen, sfx_hamas1)
			end

			if timer == 30
				mo.bod = P_SpawnMobj(mo.x, mo.y, mo.z + FRACUNIT*192, MT_DUMMY)
				mo.bod.state = S_THOK
				mo.bod.tics = -1
				mo.bod.fuse = TICRATE
				mo.bod.color = SKINCOLOR_PURPLE

				mo.bod.momx = (target.x - mo.x)/TICRATE
				mo.bod.momy = (target.y - mo.y)/TICRATE
				mo.bod.momz = (target.z - mo.bod.z)/TICRATE
			end

			if mo.bod and mo.bod.valid
				mo.bod.frame = FF_FULLBRIGHT
				mo.bod.scale = FRACUNIT*2 + P_RandomRange(-FRACUNIT/2 +1, FRACUNIT/2 -1)
				if timer%2
					local g = P_SpawnGhostMobj(mo.bod)
					g.fuse = TICRATE/3
					g.scalespeed = FRACUNIT/2
					g.detscale = FRACUNIT*8
				end
			end

			local j = mo.columns and #mo.columns or 0
			while j
				local m = mo.columns[j]
				if not m or not m.valid
					j = $-1
					continue
				end

				for i = 1, 5
					local boom = P_SpawnMobj(m.x + P_RandomRange(-48, 48)*FRACUNIT, m.y + P_RandomRange(-48, 48)*FRACUNIT, m.z, MT_DUMMY)
					boom.state = S_QUICKBOOM1
					boom.colorized = true
					boom.color = SKINCOLOR_PURPLE
					boom.momz = P_RandomRange(0, 48)*FRACUNIT
					boom.scale = FRACUNIT*3/2
				end
				localquake(mo.battlen, FRACUNIT*8, 1)
				j = $-1
			end

			if timer == 30 + TICRATE

				local cam = server.P_BattleStatus[mo.battlen].cam

				local x = cam.x - 380*cos(cam.angle)
				local y = cam.y - 380*sin(cam.angle)
				CAM_goto(cam, x, y, cam.z + FRACUNIT*24)
			end

			if timer >= 30 + TICRATE
			and timer <= 30 + TICRATE*2
			and timer%4 == 0

				local s = P_SpawnMobj(target.x + P_RandomRange(-128, 128)<<FRACBITS, target.y + P_RandomRange(-128, 128)<<FRACBITS, target.z + P_RandomRange(0, 256)<<FRACBITS, MT_DUMMY)
				s.color = SKINCOLOR_WHITE
				s.state = S_MEGISTAR1
				s.scale = $*2 + P_RandomRange(0, 65535)
				playSound(mo.battlen, sfx_hamas1)

			end

			if timer == 30 + TICRATE*2
				-- delet old shit:
				mo.fangle = (R_PointToAngle(target.x, target.y)) + ANG1*180
				mo.columns = {}
				playSound(mo.battlen, sfx_megi5)

				local a = mo.fangle - ANG1*80

				for i = 1, 16
					local m = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
					P_InstaThrust(m, a, FRACUNIT*48)
					mo.columns[#mo.columns+1] = m
					m.state = S_INVISIBLE
					m.tics = TICRATE
					a = $+ ANG1*10
				end


				for i = 1, #hittargets
					if hittargets[i] ~= mo
						damageObject(hittargets[i])
					end
				end

				localquake(mo.battlen, FRACUNIT*50, 10)
				for i = 1, 4
					createSplat(mo)
				end
			end

			if timer == 30 + TICRATE*4
				return true
			end
		end,
	},

	["trigonometry"] = {
		name = "Concentrated Trigonometry",
		type = ATK_ALMIGHTY,
		power = 1550,
		accuracy = 999,
		costtype = CST_SP,
		cost = 32,
		desc = "You have sin'd.",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)

			if timer == 2
				playSound(mo.battlen, sfx_bean4)
			elseif timer == TICRATE*6
				return true
			end

			for i = 1, #hittargets
				local t = hittargets[i]
				if timer >= 10

					if timer < TICRATE*4
						t.rollangle = $+ANG1*10
					end

					if timer >= TICRATE
					and timer <= TICRATE*4
					and t.defaultcoords

						local radius = (timer-TICRATE)*8
						radius = min($, 256)
						local a = (leveltime+(i*3))*ANG1*10

						local x = t.defaultcoords[1] + radius*cos(a)
						local y = t.defaultcoords[2] + radius*sin(a)
						local z
						if i & 1
							z = t.defaultcoords[3] + radius*sin(a)
						else
							z = t.defaultcoords[3] + radius*cos(a)
						end

						P_TeleportMove(t, x, y, z)
					end

					if timer == TICRATE*4
						damageObject(t)
						t.rollangle = 0
					end
				end
			end
		end,
	},

	["teddeh"] = {
		name = "Oaawh Teddeh",
		type = ATK_ALMIGHTY,
		costtype = CST_HPPERCENT,
		cost = 5,
		target = TGT_ENEMY,
		critical = 40,
		accuracy = 100,
		power = 3000,
		desc = "Colossal Almighty dmg to 1 foe",
		anim = 	function(mo, targets, hittargets, timer)
					local target = hittargets[1]
					if timer == 10
						playSound(mo.battlen, sfx_bean3)
						playSound(mo.battlen, sfx_becrsh)

						for i = 1,6
							local atk = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
							atk.momz = -1*FRACUNIT
							atk.state = S_AOADUST1
							atk.scale = FRACUNIT*2/3
							atk.destscale = FRACUNIT*2
							atk.angle = ANG60*(i-1)
							P_InstaThrust(atk, atk.angle, 10*FRACUNIT)
						end
					end

					if timer == 85
						mo.roadroller = P_SpawnMobj(target.x, target.y, target.z+FRACUNIT*1024, MT_DUMMY)
						mo.roadroller.sprite = SPR_BATK
						mo.roadroller.flags = MF_SCENERY
						mo.roadroller.frame = E
						mo.roadroller.tics = 70
						mo.roadroller.momz = -50*FRACUNIT
					end

					if timer == 97
						damageObject(hittargets[1])
						localquake(mo.battlen, 40*FRACUNIT, TICRATE)
						for i = 1,6
							local atk = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
							atk.momz = -1*FRACUNIT
							atk.state = S_AOADUST1
							atk.scale = FRACUNIT*1
							atk.destscale = FRACUNIT*2
							atk.angle = ANG60*(i-1)
							P_InstaThrust(atk, atk.angle, 10*FRACUNIT)
							createSplat(mo)
						end
					end

					if timer == 140
						return true
					end

				end,

	},

	["batkan buster"] = {
		name = "HYPER BATKAN BUSTER!!!",
		type = ATK_ALMIGHTY,
		power = 1,
		accuracy = 999,
		costtype = CST_HPPERCENT,
		cost = 100,
		norandom = true,	-- Don't allow this move to be selected in random pvp skills
		desc = "Use 3 times in a row to end the fight",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)

			if timer == 1
				BTL_logMessage(mo.battlen, mo.name.." is charging a powerful attack...")
				mo.kanbuster = $ and $+1 or 1
			end


			local j = mo.columns and #mo.columns or 0
			while j
				local m = mo.columns[j]
				if not m or not m.valid
					j = $-1
					continue
				end

				for i = 1, 5
					local boom = P_SpawnMobj(m.x + P_RandomRange(-48, 48)*FRACUNIT, m.y + P_RandomRange(-48, 48)*FRACUNIT, m.z, MT_DUMMY)
					boom.state = S_QUICKBOOM1
					boom.colorized = true
					boom.color = SKINCOLOR_PURPLE
					boom.momz = P_RandomRange(0, 48)*FRACUNIT
					boom.scale = FRACUNIT*3/2
				end
				localquake(mo.battlen, FRACUNIT*8, 1)
				j = $-1
			end

			if #mo.allies == 1	-- bean defeated

				if timer == 1
					BTL_logMessage(mo.battlen, mo.name.." is no longer sustained by the Master of Teddehs!")
					local btl = server.P_BattleStatus[mo.battlen]
				end

				if timer >= 10
				and timer <= TICRATE*2
				and leveltime%5 == 0

					local bx = mo.x + P_RandomRange(-192, 192)*FRACUNIT
					local by = mo.y + P_RandomRange(-129, 192)*FRACUNIT
					local bz = mo.z + P_RandomRange(0, 256)*FRACUNIT

					for i = 1, 32
						local boom = P_SpawnMobj(bx + P_RandomRange(-20, 20)*FRACUNIT, by + P_RandomRange(-20, 20)*FRACUNIT, bz + 10*FRACUNIT, MT_DUMMY)
						boom.state = S_CQUICKBOOM1
						boom.color = SKINCOLOR_PURPLE
						boom.momx = P_RandomRange(-20, 20)*FRACUNIT
						boom.momy = P_RandomRange(-20, 20)*FRACUNIT
						boom.momz = P_RandomRange(-20, 20)*FRACUNIT
						boom.scale = FRACUNIT*3/2
					end
					local sm = P_SpawnMobj(bx, by, bz, MT_SMOLDERING)
					sm.fuse = TICRATE

					playSound(mo.battlen, sfx_megi6)
					localquake(mo.battlen, FRACUNIT*32, 10)
				end

				if timer == TICRATE*3
					-- delet old shit:
					mo.fangle = (R_PointToAngle(mo.x, mo.y)) + ANG1*180
					mo.columns = {}
					playSound(mo.battlen, sfx_megi5)

					local a = mo.fangle - ANG1*80

					for i = 1, 16
						local m = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
						P_InstaThrust(m, a, FRACUNIT*48)
						mo.columns[#mo.columns+1] = m
						m.state = S_INVISIBLE
						m.tics = TICRATE
						a = $+ ANG1*10
					end


					for i = 1, #hittargets
						if hittargets[i] ~= mo
							damageObject(hittargets[i], hittargets[i].hp-1)
							cureStatus(hittargets[i])

							hittargets[i].strength = $-25
							hittargets[i].magic = $-25
							hittargets[i].endurance = $-25
							hittargets[i].agility = $-25
							hittargets[i].luck = $-25

						end
					end

					-- target: mo.maxhp/4
					-- diff: mo.hp - mo.maxhp/4
					mo.guaranteedevasion = nil	-- remove guaranteed evasion
					damageObject(mo, (mo.hp - mo.maxhp/5))
					mo.strength = 65
					mo.endurance = 8
					mo.magic = 65			-- slightly lower stats.
					mo.agility = 55			-- to make things a bit more fair

					-- change my skills:
					mo.skills = {
						"trisagion",
						"panta rhei",
						"niflheim",
						"thunder reign",
						"kannon",
						"kannon",
						"kannon",
						"fitness",
						"fitness",
						"fitness",
						"trigonometry",
						"trigonometry",
						"maragidyne",
						"mabufudyne",
						"maziodyne",
						"magarudyne",
						"mapsiodyne",
						"mafreidyne",
						"makougaon",
						"maeigaon",
						"megidolaon",
						"fire boost",
						"ice boost",
						"elec boost",
						"wind boost",
						"nuke boost",
						"psi boost",
						"bless boost",
						"curse boost",
						"god hand",
						"god hand",
						"god hand",
						"deathbound",
						"deathbound",
						"heat riser",
						"dekaja",
						"dekunda",
					}	-- that's a lot a skills.
					BTL_splitSkills(mo)	-- split skills between physical and passive.
					-- yes, it's kind of a hack to call this function r/n but w/e

					localquake(mo.battlen, FRACUNIT*50, 10)
					for i = 1, 4
						createSplat(mo)
					end
				end

				if timer == TICRATE*6
					return true
				end

				return
			end


			if timer == TICRATE/2
				local cam = server.P_BattleStatus[mo.battlen].cam

				local x = cam.x - 380*cos(cam.angle)
				local y = cam.y - 380*sin(cam.angle)
				CAM_goto(cam, x, y, cam.z + FRACUNIT*24)
			end

			if timer == TICRATE

				for i = 1, #mo.allies

					local target = mo.allies[i]
					if not target or not target.valid continue end

					playSound(mo.battlen, sfx_buff)
					buffStat(target, "atk")
					buffStat(target, "mag")
					buffStat(target, "def")
					buffStat(target, "agi")

					BTL_logMessage(targets[1].battlen, "All stats increased!")

					for i = 1,16
						local dust = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
						dust.angle = ANGLE_90 + ANG1* (22*(i-1))
						dust.state = S_CDUST1
						P_InstaThrust(dust, dust.angle, 30*FRACUNIT)
						dust.color = SKINCOLOR_WHITE
						dust.scale = FRACUNIT*2
					end
				end
			end

			if timer == TICRATE*3

				return true
			end
		end,
	},

	["summon bean"] = {
		name = "Summon Bean",
		type = ATK_ALMIGHTY,
		power = 0,
		accuracy = 999,
		costtype = CST_HPPERCENT,
		cost = 100,
		norandom = true,	-- Don't allow this move to be selected in random pvp skills
		desc = "Summons the Master of Teddehs",
		target = TGT_CASTER,
		anim = function(mo, targets, hittargets, timer)

			if mo.plyr
				BTL_logMessage(mo.battlen, "No seriously don't use this on players you absolute idiot!!")
				return true	-- JUST IN CASE /!\
			end
			local cam = server.P_BattleStatus[mo.battlen].cam

			if timer == 1
				mo.replica = BTL_spawnEnemy(mo, "bean", false, nil, nil, nil, 60)

				if mo.replica == nil	-- failure?
					return true
				end

				local target = mo.replica
				mo.replica.flags2 = $|MF2_DONTDRAW

				local an = ANG1* P_RandomRange(10, 35)
				local gox,goy

				gox = target.x + 300*cos(target.angle+an)
				goy = target.y + 300*sin(target.angle+an)

				--P_TeleportMove(cam, gox, goy, target.z + FRACUNIT*40)	-- teleport the camera to a nice spot
				CAM_goto(cam, gox, goy, target.z + FRACUNIT*40)
				CAM_angle(cam, R_PointToAngle2(gox, goy, target.x, target.y))
				CAM_aiming(cam, 0)
			end
			-- spawns a new angel in the fight.

			/*if timer >= 1
			and timer <= TICRATE/2
			and leveltime & 1

				mo.replica.flags2 = $ & ~MF2_DONTDRAW
				local g = P_SpawnGhostMobj(mo.replica)
				mo.replica.flags2 = $|MF2_DONTDRAW
				g.colorized = true
				g.fuse = 2
			end*/

			if timer == TICRATE/2

				mo.replica.flags2 = $ & ~MF2_DONTDRAW
				local g = P_SpawnGhostMobj(mo.replica)
				g.colorized = true
				g.destscale = FRACUNIT*4
				S_StartSound(replica, sfx_bean5)

				BTL_logMessage(mo.battlen, mo.name.." has summoned "..mo.replica.name)
			end

			if timer == TICRATE*5/2
				BTL_logMessage(mo.battlen, mo.name.." has begun charging an attack...")
				mo.guaranteedevasion = true

				local an = ANG1* P_RandomRange(10, 35)
				local gox,goy

				gox = mo.x + 500*cos(mo.angle+an)
				goy = mo.y + 500*sin(mo.angle+an)

				--P_TeleportMove(cam, gox, goy, target.z + FRACUNIT*40)	-- teleport the camera to a nice spot
				CAM_goto(cam, gox, goy, mo.z + FRACUNIT*40)
				CAM_angle(cam, R_PointToAngle2(gox, goy, mo.x, mo.y))
				CAM_aiming(cam, ANG1*3)
			end

			if timer == TICRATE*5
				mo.replica = nil
				return true
			end
		end,
	},


	-- ANGEL REPLICA SKILLS

	["distortion"] = {
		name = "Distortion",
		type = ATK_SUPPORT,
		power = 0,
		accuracy = 999,
		costtype = CST_SP,
		cost = 32,
		desc = "Evade every attack for 1 turn.\nClear stat penalties and\nraises Physical Attack",
		target = TGT_CASTER,
		evasionskill = 1,		-- # of turns before this skill is automatically casted again. NOTHING can be done until autocast happens again.
		evasionwait = "",		-- this is usually printed in the console if the autocast isn't happening again.
		anim = function(mo, targets, hittargets, timer)

				if timer == 1
					local g = P_SpawnGhostMobj(mo)
					g.colorized = true
					g.fuse = 2

					S_StartSound(mo, sfx_kdist)

					if mo.guaranteedevasion
						mo.guaranteedevasion = nil
						BTL_logMessage(mo.battlen, "Stat penalties reverted,\nPhysical Attack up.")

						local strs = {"atk", "mag", "def", "agi"}

						for j = 1, #strs
							local s = strs[j]
							if mo.buffs[s][1] < 0
								mo.buffs[s][1] = 0
								mo.buffs[s][2] = 0
							end
						end

						mo.buffs["atk"][1] = min(75, $ + 25)	-- make sure to keep it within bounds.
					else
						mo.guaranteedevasion = true
						BTL_logMessage(mo.battlen, mo.name.." has become blurry...")
					end

				elseif timer == TICRATE*3/2
					return true
				end
		end,
	},

	["harmonics"] = {
		name = "Harmonics",
		type = ATK_ALMIGHTY,
		power = 0,
		accuracy = 999,
		costtype = CST_HPPERCENT,
		cost = 0,
		norandom = true,	-- Don't allow this move to be selected in random pvp skills
		desc = "Creates an Angel Replica.",
		target = TGT_CASTER,
		anim = function(mo, targets, hittargets, timer)

			/*if mo.plyr
				BTL_logMessage(mo.battlen, "No seriously don't use this on players you absolute idiot!!")
				return true	-- JUST IN CASE /!\
				-- Let's be chaotic evil, let players do this at their own expense :)
			end*/
			local cam = server.P_BattleStatus[mo.battlen].cam

			if timer == 1
				mo.replica = BTL_spawnEnemy(mo, "angel")

				if mo.replica == nil	-- failure?
					return true
				end

				local target = mo.replica
				mo.replica.flags2 = $|MF2_DONTDRAW

				mo.replica.hp = mo.hp

				local an = ANG1* P_RandomRange(10, 35)
				local gox,goy

				gox = target.x + 300*cos(target.angle+an)
				goy = target.y + 300*sin(target.angle+an)

				--P_TeleportMove(cam, gox, goy, target.z + FRACUNIT*40)	-- teleport the camera to a nice spot
				CAM_goto(cam, gox, goy, target.z + FRACUNIT*40)
				CAM_angle(cam, R_PointToAngle2(gox, goy, target.x, target.y))
				CAM_aiming(cam, 0)
			end
			-- spawns a new angel in the fight.

			if timer >= 1
			and timer <= TICRATE/2
			and leveltime & 1

				mo.replica.flags2 = $ & ~MF2_DONTDRAW
				local g = P_SpawnGhostMobj(mo.replica)
				mo.replica.flags2 = $|MF2_DONTDRAW
				g.colorized = true
				g.fuse = 2
			end

			if timer == TICRATE/2

				mo.replica.flags2 = $ & ~MF2_DONTDRAW
				local g = P_SpawnGhostMobj(mo.replica)
				g.colorized = true
				g.destscale = FRACUNIT*4
				S_StartSound(replica, sfx_kdist)

			end

			if timer == TICRATE
				mo.replica = nil
				BTL_normalizePositions(mo.allies_noupdate, true)
				return true
			end
		end,
	},

	["harmonics-0"] = {
		name = "Harmonics",
		type = ATK_ALMIGHTY,
		power = 0,
		accuracy = 999,
		costtype = CST_HPPERCENT,
		cost = 0,
		norandom = true,	-- Don't allow this move to be selected in random pvp skills
		desc = "Creates an Angel Replica.",
		target = TGT_CASTER,
		anim = function(mo, targets, hittargets, timer)

			/*if mo.plyr
				BTL_logMessage(mo.battlen, "No seriously don't use this on players you absolute idiot!!")
				return true	-- JUST IN CASE /!\
				-- Let's be chaotic evil, let players do this at their own expense :)
			end*/
			local cam = server.P_BattleStatus[mo.battlen].cam

			if timer == 1
				mo.replica = BTL_spawnEnemy(mo, "angel_vr_2")

				if mo.replica == nil	-- failure?
					return true
				end

				local target = mo.replica
				mo.replica.flags2 = $|MF2_DONTDRAW

				mo.replica.hp = mo.hp

				local an = ANG1* P_RandomRange(10, 35)
				local gox,goy

				gox = target.x + 300*cos(target.angle+an)
				goy = target.y + 300*sin(target.angle+an)

				--P_TeleportMove(cam, gox, goy, target.z + FRACUNIT*40)	-- teleport the camera to a nice spot
				CAM_goto(cam, gox, goy, target.z + FRACUNIT*40)
				CAM_angle(cam, R_PointToAngle2(gox, goy, target.x, target.y))
				CAM_aiming(cam, 0)
			end
			-- spawns a new angel in the fight.

			if timer >= 1
			and timer <= TICRATE/2
			and leveltime & 1

				mo.replica.flags2 = $ & ~MF2_DONTDRAW
				local g = P_SpawnGhostMobj(mo.replica)
				mo.replica.flags2 = $|MF2_DONTDRAW
				g.colorized = true
				g.fuse = 2
			end

			if timer == TICRATE/2

				mo.replica.flags2 = $ & ~MF2_DONTDRAW
				local g = P_SpawnGhostMobj(mo.replica)
				g.colorized = true
				g.destscale = FRACUNIT*4
				S_StartSound(replica, sfx_kdist)

			end

			if timer == TICRATE
				mo.replica = nil
				BTL_normalizePositions(mo.allies_noupdate, true)
				return true
			end
		end,
	},

	["howling"] = {
		name = "Howling",
		type = ATK_ALMIGHTY,
		power = 400,
		accuracy = 999,
		costtype = CST_HPPERCENT,
		statuschance = 20,
		status = COND_DIZZY,
		cost = 20,
		critical = 1,
		desc = "Heavy Almighty damage to\nall enemies. May inflict Dizzy.",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)

			local avgx, avgy = 0, 0
			for i = 1, #targets
				avgx = $ + targets[i].x/FRACUNIT
				avgy = $ + targets[i].y/FRACUNIT
			end
			avgx = ($/#targets)	*FRACUNIT
			avgy = ($/#targets)	*FRACUNIT

			local cam = server.P_BattleStatus[mo.battlen].cam

			if timer == 1
				mo.oldangle = mo.angle

				-- get average of our targets

				mo.angle = R_PointToAngle2(mo.x, mo.y, avgx, avgy)
				local tgtx = mo.x + 256*cos(mo.angle)
				local tgty = mo.y + 256*sin(mo.angle)

				P_TeleportMove(cam, tgtx, tgty, mo.z + FRACUNIT*16)
				cam.angle = R_PointToAngle2(cam.x, cam.y, mo.x, mo.y)	-- face me!
				CAM_stop(cam)
				ANIM_set(mo, mo.anim_special4)	-- Guard

			elseif timer == 5
				ANIM_set(mo, mo.anim_special5)	-- HS 2

			elseif timer == TICRATE*3/2
				ANIM_set(mo, mo.anim_special6)	-- HS loop
				local thean = mo.angle
				local tgtx = avgx + 512*cos(thean)
				local tgty = avgy + 512*sin(thean)

				playSound(mo.battlen, sfx_howl1)
				localquake(mo.battlen, FRACUNIT*64, 10)

				CAM_goto(cam, tgtx, tgty, mo.z + FRACUNIT*128, FRACUNIT*20)

				--CAM_angle(cam, thean)

			elseif timer >= TICRATE*3/2
			and timer <= TICRATE*3

				if leveltime%5 == 0
					local d = P_SpawnMobj(mo.x, mo.y, mo.z + FRACUNIT*64, MT_THOK)
					d.state = S_HOWL1
					d.color = SKINCOLOR_AETHER
					d.angle = mo.angle + ANG1*90
					d.scale = mo.scale*2
					d.destscale = mo.scale*7
					d.scalespeed = FRACUNIT/4
					P_InstaThrust(d, mo.angle, FRACUNIT*32)
				end

			elseif timer == TICRATE*3 + 1
				for i = 1, #hittargets
					damageObject(hittargets[i])
				end
			elseif timer == TICRATE*4
				return true
			end
		end,
	},

	["howling-0"] = {
		name = "Howling",
		type = ATK_ALMIGHTY,
		power = 250,
		accuracy = 999,
		costtype = CST_HPPERCENT,
		statuschance = 20,
		status = COND_DIZZY,
		cost = 20,
		critical = 1,
		desc = "Medium Almighty damage to\nall enemies. May inflict Dizzy.",
		target = TGT_ALLENEMIES,
		anim = function(mo, targets, hittargets, timer)

			local avgx, avgy = 0, 0
			for i = 1, #targets
				avgx = $ + targets[i].x/FRACUNIT
				avgy = $ + targets[i].y/FRACUNIT
			end
			avgx = ($/#targets)	*FRACUNIT
			avgy = ($/#targets)	*FRACUNIT

			local cam = server.P_BattleStatus[mo.battlen].cam

			if timer == 1
				mo.oldangle = mo.angle

				-- get average of our targets

				mo.angle = R_PointToAngle2(mo.x, mo.y, avgx, avgy)
				local tgtx = mo.x + 256*cos(mo.angle)
				local tgty = mo.y + 256*sin(mo.angle)

				P_TeleportMove(cam, tgtx, tgty, mo.z + FRACUNIT*16)
				cam.angle = R_PointToAngle2(cam.x, cam.y, mo.x, mo.y)	-- face me!
				CAM_stop(cam)
				ANIM_set(mo, mo.anim_special4)	-- Guard

			elseif timer == 5
				ANIM_set(mo, mo.anim_special5)	-- HS 2

			elseif timer == TICRATE*3/2
				ANIM_set(mo, mo.anim_special6)	-- HS loop
				local thean = mo.angle
				local tgtx = avgx + 512*cos(thean)
				local tgty = avgy + 512*sin(thean)

				playSound(mo.battlen, sfx_howl1)
				localquake(mo.battlen, FRACUNIT*64, 10)

				CAM_goto(cam, tgtx, tgty, mo.z + FRACUNIT*128, FRACUNIT*20)

				--CAM_angle(cam, thean)

			elseif timer >= TICRATE*3/2
			and timer <= TICRATE*3

				if leveltime%5 == 0
					local d = P_SpawnMobj(mo.x, mo.y, mo.z + FRACUNIT*64, MT_THOK)
					d.state = S_HOWL1
					d.color = SKINCOLOR_AETHER
					d.angle = mo.angle + ANG1*90
					d.scale = mo.scale*2
					d.destscale = mo.scale*7
					d.scalespeed = FRACUNIT/4
					P_InstaThrust(d, mo.angle, FRACUNIT*32)
				end

			elseif timer == TICRATE*3 + 1
				for i = 1, #hittargets
					damageObject(hittargets[i])
				end
			elseif timer == TICRATE*4
				return true
			end
		end,
	},

	["handsonic_melee"] = {
		name = "Hand Sonic Ver. I",
		type = ATK_SLASH,
		power = 35,
		accuracy = 95,
		costtype = CST_HPPERCENT,
		technical = COND_FREEZE,
		cost = 4,
		critical = 5,
		physical = true,	-- Checking this uses the character atk/acc/crit stat instead of the attack's
		desc = "Light Slash damage to \none enemy.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)

			local target = hittargets[1]

			if timer == 1
				ANIM_set(mo, mo.anim_run)
				local g = P_SpawnGhostMobj(mo)
				g.colorized = true

				local cx = target.x + 168*cos(target.angle + ANG1*20)
				local cy = target.y + 168*sin(target.angle + ANG1*20)
				CAM_goto(server.P_BattleStatus[mo.battlen].cam, cx, cy, target.z + FRACUNIT*30, 70*FRACUNIT)
				CAM_angle(server.P_BattleStatus[mo.battlen].cam, R_PointToAngle2(cx, cy, target.x, target.y))
				S_StartSound(mo, sfx_zoom)

			elseif R_PointToDist2(mo.x, mo.y, target.x, target.y) > FRACUNIT*64
			and mo.k_savetime == nil
				local ang = R_PointToAngle2(mo.x, mo.y, target.x, target.y)
				mo.angle = ang
				if R_PointToDist2(mo.x, mo.y, target.x, target.y) < FRACUNIT*192
					ANIM_set(mo, mo.anim_special1)
					P_InstaThrust(mo, ang, FRACUNIT*64)
					if leveltime & 1
						local g = P_SpawnGhostMobj(mo)
						g.colorized = true
					end
				else
					P_InstaThrust(mo, ang, FRACUNIT*32)
				end
			elseif mo.k_savetime == nil	-- attack connects

				mo.k_savetime = timer

				local s = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
				s.state = S_SLASHING_2_1
				s.color = SKINCOLOR_AETHER
				s.scale = FRACUNIT*3
				playSound(mo.battlen, sfx_slash)
				s = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
				s.state = S_SLASHING_1_1
				s.color = SKINCOLOR_AETHER
				s.scale = FRACUNIT*3
				playSound(mo.battlen, sfx_slash)

			elseif timer == mo.k_savetime + 2

				damageObject(target)
				playSound(mo.battlen, sfx_bexpld)
				if not target.plyr
					createSplat(mo)
					createSplat(mo)
				end
				localquake(mo.battlen, FRACUNIT*10, 10)
				for i=1,10
					local b = P_SpawnMobj(target.x, target.y, target.z+20*FRACUNIT, MT_DUMMY)
					b.momx = P_RandomRange(-35, 35)*FRACUNIT
					b.momy = P_RandomRange(-35, 35)*FRACUNIT
					b.momz = P_RandomRange(-35, 35)*FRACUNIT
					b.color = SKINCOLOR_RED
					b.frame = A|FF_FULLBRIGHT
					b.scale = FRACUNIT/2
					b.destscale = FRACUNIT/12
					b.tics = 35
				end

				local s = P_SpawnMobj(target.x, target.y, target.z+40*FRACUNIT, MT_THOK)
				s.sprite = SPR_SLSH
				s.frame = I|FF_FULLBRIGHT
				s.scale = FRACUNIT/2
				s.destscale = FRACUNIT*4
				s.scalespeed = FRACUNIT/3
				s.color = SKINCOLOR_AETHER

				s = P_SpawnMobj(target.x, target.y, target.z+40*FRACUNIT, MT_THOK)
				s.sprite = SPR_SLSH
				s.frame = I|FF_FULLBRIGHT
				s.scale = FRACUNIT/2
				s.destscale = FRACUNIT*8
				s.scalespeed = FRACUNIT/2
				s.color = SKINCOLOR_AETHER

				s = P_SpawnMobj(target.x, target.y, target.z+40*FRACUNIT, MT_THOK)
				s.sprite = SPR_SLSH
				s.frame = G|FF_FULLBRIGHT
				s.scale = FRACUNIT/2
				s.tics = TICRATE/2
				s.fuse = s.tics
				s.destscale = FRACUNIT*10
				s.scalespeed = FRACUNIT/4
				s.color = SKINCOLOR_AETHER
			elseif timer == mo.k_savetime + TICRATE

				mo.k_savetime = nil
				return true
			end
		end,
	},

	["hand sonic"] = {
		name = "Hand Sonic",
		type = ATK_SLASH,
		power = 300,
		accuracy = 999,
		costtype = CST_HPPERCENT,
		technical = COND_FREEZE,
		cost = 13,
		critical = 5,
		desc = "Heavy Slash damage to \none enemy.",
		target = TGT_ENEMY,
		anim = function(mo, targets, hittargets, timer)

			local target = hittargets[1]

			if timer == 1
				ANIM_set(mo, mo.anim_run)
				local g = P_SpawnGhostMobj(mo)
				g.colorized = true
			elseif R_PointToDist2(mo.x, mo.y, target.x, target.y) > FRACUNIT*64
			and mo.k_savetime == nil
				local ang = R_PointToAngle2(mo.x, mo.y, target.x, target.y)
				mo.angle = ang
				if R_PointToDist2(mo.x, mo.y, target.x, target.y) < FRACUNIT*192
					ANIM_set(mo, mo.anim_special1)
					P_InstaThrust(mo, ang, FRACUNIT*64)
					if leveltime & 1
						local g = P_SpawnGhostMobj(mo)
						g.colorized = true
					end
				else
					P_InstaThrust(mo, ang, FRACUNIT*32)
				end
			elseif mo.k_savetime == nil	-- attack connects

				mo.k_savetime = timer

				local s = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
				s.state = S_SLASHING_2_1
				s.color = SKINCOLOR_AETHER
				s.scale = FRACUNIT*3
				playSound(mo.battlen, sfx_slash)
				s = P_SpawnMobj(target.x, target.y, target.z, MT_DUMMY)
				s.state = S_SLASHING_1_1
				s.color = SKINCOLOR_AETHER
				s.scale = FRACUNIT*3
				playSound(mo.battlen, sfx_slash)

			elseif timer == mo.k_savetime + 2

				damageObject(target)
				playSound(mo.battlen, sfx_bexpld)
				if not target.plyr
					createSplat(mo)
					createSplat(mo)
				end
				localquake(mo.battlen, FRACUNIT*10, 10)
				for i=1,10
					local b = P_SpawnMobj(target.x, target.y, target.z+20*FRACUNIT, MT_DUMMY)
					b.momx = P_RandomRange(-35, 35)*FRACUNIT
					b.momy = P_RandomRange(-35, 35)*FRACUNIT
					b.momz = P_RandomRange(-35, 35)*FRACUNIT
					b.color = SKINCOLOR_RED
					b.frame = A|FF_FULLBRIGHT
					b.scale = FRACUNIT/2
					b.destscale = FRACUNIT/12
					b.tics = 35
				end

				local s = P_SpawnMobj(target.x, target.y, target.z+40*FRACUNIT, MT_THOK)
				s.sprite = SPR_SLSH
				s.frame = I|FF_FULLBRIGHT
				s.scale = FRACUNIT/2
				s.destscale = FRACUNIT*4
				s.scalespeed = FRACUNIT/3
				s.color = SKINCOLOR_ORANGE

				s = P_SpawnMobj(target.x, target.y, target.z+40*FRACUNIT, MT_THOK)
				s.sprite = SPR_SLSH
				s.frame = I|FF_FULLBRIGHT
				s.scale = FRACUNIT/2
				s.destscale = FRACUNIT*8
				s.scalespeed = FRACUNIT/2
				s.color = SKINCOLOR_ORANGE

				s = P_SpawnMobj(target.x, target.y, target.z+40*FRACUNIT, MT_THOK)
				s.sprite = SPR_SLSH
				s.frame = G|FF_FULLBRIGHT
				s.scale = FRACUNIT/2
				s.tics = TICRATE/2
				s.fuse = s.tics
				s.destscale = FRACUNIT*10
				s.scalespeed = FRACUNIT/4
				s.color = SKINCOLOR_ORANGE
			elseif timer == mo.k_savetime + TICRATE

				mo.k_savetime = nil
				return true
			end
		end,
	},

	["all_out"] = {
		name = "All-Out Attack",
		type = ATK_ALMIGHTY,
		power = -1,	-- negative power is a special case for all out attacks
		accuracy = 999,
		costtype = CST_HPPERCENT,
		norandom = true,	-- Don't allow this move to be selected in random pvp skills
		cost = 100,
		desc = "Stop hacking your skills!!",
		target = TGT_ALLENEMIES,

		hudfunc = 	function(v, mo, timer)	// hud function, drawn at the same time as the attack. Use it for cool effects!

						-- transition around 280 tics
						if timer > 275
						and timer < 290
							local t = timer-275
							local p = "H_ATR"..t/2
							if v.patchExists(p)
								drawScreenwidePatch(v, v.cachePatch(p))
							end
						end

						-- the attack has just started: draw a fake AOA overlay like we just confirmed or w/e...
						-- draw prompter portrait...
						if timer < 70

							-- draw prompter portrait...

							drawScreenwidePatch(v, v.cachePatch("H_AOA3"))
							local btl = server.P_BattleStatus[mo.battlen]

							-- draw "AOA or RELENT" prompt
							v.drawIndex((190 +2)<<FRACBITS, 52<<FRACBITS, FRACUNIT/2, v.cachePatch("H_AOAT"..((btl.holdupfinish or SAVE_localtable.tutorial) and "2" or "")), 0, 31)
							PDraw(v,  190, 50, v.cachePatch("H_AOAT"..((btl.holdupfinish or SAVE_localtable.tutorial) and "2" or "")))

							local pp = v.cachePatch(charStats[mo.stats] and charStats[mo.stats].hudaoa or "")
							if mo.status_condition == COND_SUPER
							and charStats[mo.stats] and charStats[mo.stats].hudsaoa
								pp = v.cachePatch(charStats[mo.stats].hudsaoa)
							end
							v.drawScaled((-25)<<FRACBITS, (20)<<FRACBITS, FRACUNIT*2/3, pp, V_SNAPTOLEFT|V_SNAPTOBOTTOM, v.getColormap(TC_DEFAULT, mo.color))	-- draw @ full scale

							-- slide text box in your DMs:
							pp = v.cachePatch("H_AOATX")
							PDraw(v, 0, 200, pp, V_SNAPTOBOTTOM|V_SNAPTOLEFT)
							-- get text:
							local txt = charStats[mo.skin] and charStats[mo.skin].aoa_quote or "Here's our chance!"
							V_drawString(v, 10, 158, txt, "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 0, 31, FRACUNIT*2/3)


							-- new shit
							local aoat = v.cachePatch("H_AOAB")
							v.drawScaled(190<<FRACBITS, 50<<FRACBITS, max(FRACUNIT/2, FRACUNIT*12 - timer*FRACUNIT*3/2), aoat)

							-- glowing text
							if timer > 10
								v.drawScaled(190<<FRACBITS, 50<<FRACBITS, max(1, 3*sin((timer-10)*6*ANG1)), aoat, V_TRANSLUCENT)
							end

							-- big fill circle
							if timer > 50
								v.drawScaled(190<<FRACBITS, 50<<FRACBITS, (timer-50)*FRACUNIT/2, v.cachePatch("H_1M_B"))
							end
						elseif timer < 180
							v.drawFill(0, 0, 999, 999, 135|V_SNAPTOTOP|V_SNAPTOLEFT)

							if timer == 51
								phud.clear("allout", displayplayer)
							end

							if timer == 75 or timer == 76
								v.drawFill(0, 0, 999, 999, 0|V_SNAPTOTOP|V_SNAPTOLEFT)
								for i = 1, 10
									local part = phud.create(mo.battlen, N_RandomRange(0, 320), N_RandomRange(30, 170), "AOAPART"..N_RandomRange(1, 7), -1, nil, "allout")
									part.momx = N_RandomRange(10, 25)
									part.momy = 2
									part.physflags = PF_NOGRAVITY
									part.scale = N_RandomRange(FRACUNIT/2 - FRACUNIT/8, FRACUNIT/2 + FRACUNIT/8)
									part.deleteoffscreen = nil
									part.fuse = TICRATE*5
								end
								if timer == 75
									--S_StartSound(nil, sfx_aoasli)
								end
							end

							if timer > 76
								-- black background:
								drawScreenwidePatch(v, v.cachePatch("H_ABG1"))

								if leveltime%2 == 0
									local part = phud.create(mo.battlen, -20, N_RandomRange(30, 170), "AOAPART"..N_RandomRange(1, 7), -1, nil, "allout")
									part.momx = N_RandomRange(23, 30)
									part.momy = 2
									part.flags = V_50TRANS
									part.physflags = PF_NOGRAVITY
									part.scale = N_RandomRange(FRACUNIT/8 - FRACUNIT/15, FRACUNIT/8 + FRACUNIT/15)
									part.deleteoffscreen = nil
									part.fuse = TICRATE*5
								end

								DisplayPhysHUD(v, "allout", displayplayer)	-- displayed behind the characters

								-- particles in FRONT of the characters, there's less of them...
								if leveltime%3 == 0
									local part = phud.create(mo.battlen, -30, N_RandomRange(30, 170), "AOAPART"..N_RandomRange(1, 7), -1, nil, "main")
									part.momx = N_RandomRange(26, 32)
									part.momy = 2
									part.physflags = PF_NOGRAVITY
									part.scale = N_RandomRange(FRACUNIT/6 - FRACUNIT/10, FRACUNIT/6 + FRACUNIT/10)
									part.deleteoffscreen = nil
									part.fuse = TICRATE*5
								end

								-- when leveltime is big enough to start transitionning, spanw a metric fuckton of those particles to start the transition
								if timer > 160
									for i = 1, 5
										local part = phud.create(mo.battlen, N_RandomRange(-200, -100), N_RandomRange(-50, 250), "AOAPART"..N_RandomRange(1, 7), -1, nil, "main")
										part.momx = N_RandomRange(26, 32)
										part.momy = 2
										part.physflags = PF_NOGRAVITY
										part.scale = N_RandomRange(FRACUNIT/6 - FRACUNIT/10, FRACUNIT/6 + FRACUNIT/10)
										part.deleteoffscreen = nil
										part.fuse = TICRATE*5
									end
								end

								-- draw our player
								local i = #mo.allies
								local t = timer - 76
								while i

									local xcoord = min(52*(i-1), (i-1)*t*8) + t/8*i
									if timer > 130 + (i*2)
										xcoord = $ + (timer-(130+i*2))^2
									end

									local m = mo.allies[i]

									if BTL_noAOAStatus(m)
										i = $-1
										continue		-- Not me, I can't act!
									end

									local pp = v.cachePatch(charStats[mo.allies[i].stats] and charStats[mo.allies[i].stats].hudaoa or "")
									if mo.allies[i].status_condition == COND_SUPER
									and charStats[mo.allies[i].stats] and charStats[mo.allies[i].stats].hudsaoa
										pp = v.cachePatch(charStats[mo.allies[i].stats].hudsaoa)
									end
									PDraw(v, xcoord, 30 - 4*i, pp, 0, v.getColormap(TC_DEFAULT, mo.allies[i].color))
									i = $-1
								end
							end
						end
					end,


		anim = function(mo, targets, hittargets, timer)

				local function noaoa(mo)
					return BTL_noAOAStatus(mo)
				end

				server.P_BattleStatus[mo.battlen].aoa = true

				-- damage enemies:
				local stoptimer = 280
				if timer == stoptimer + 50
					for i = 1, #targets	-- er, even if there's a weird repel, damage targets instead of hittargets
						damageObject(targets[i])
						targets[i].down = false
					end
				elseif timer == stoptimer + 100
					return true
				end

				local fatal
				local fatalcount = 0
				for i = 1, #targets
					if targets[i].atk_hpremaining <= 0
						fatalcount = $+1
					end
				end

				fatal = fatalcount >= #targets


				local cam = server.P_BattleStatus[mo.battlen].cam
				if timer == 1
					-- save camera coords, expected to be still from target select
					cam.aoa_savecoords = {cam.x, cam.y, cam.z, cam.angle, cam.aiming}
					playSound(mo.battlen, sfx_aoado)
				elseif timer == 75
					playSound(mo.battlen, sfx_aoasli)
				end


				-- average the coordinates of the targets...
				local avx, avy = 0, 0
				for i = 1, #targets
					avx = $+ targets[i].x/FRACUNIT
					avy = $+ targets[i].y/FRACUNIT
				end
				avx = ($ /#targets)*FRACUNIT
				avy = ($ /#targets)*FRACUNIT

				if timer > stoptimer

					-- teleport all our players somewhere close enough to the center
					for i = 1, #mo.allies do
						local m = mo.allies[i]

						if noaoa(m)
							continue	-- Not me! I can't act!
						end

						if timer == stoptimer+1
							local newx = avx + 32*cos(m.aoa_savecoords[4])
							local newy = avy + 32*sin(m.aoa_savecoords[4])
							P_TeleportMove(m, newx, newy, m.floorz)
							m.angle = m.aoa_savecoords[4]
							ANIM_set(m, m.anim_aoa_end, true)

							-- reset the camera
							if cam.aoa_savecoords
								P_TeleportMove(cam, cam.aoa_savecoords[1], cam.aoa_savecoords[2], cam.aoa_savecoords[3])
								cam.angle = cam.aoa_savecoords[4]
								cam.aiming = cam.aoa_savecoords[5]
								cam.aoa_savecoords = nil
							end

						elseif timer == stoptimer+10	-- send the players back where they came from (ROUGHLY)
							local dist = P_AproxDistance(m.aoa_savecoords[1] - m.x, m.aoa_savecoords[2] - m.y)
							local airtime = TICRATE*3/2
							local horizontal = dist / airtime
							local vertical = FixedMul((gravity*airtime)/2, m.scale)

							m.momx = FixedMul(-horizontal, cos(m.angle))
							m.momy = FixedMul(-horizontal, sin(m.angle))
							m.momz = vertical

							-- spawn the explosion for the first player (this avoids having to make ANOTHER check or w/e)
							-- it's different depending on whether or not all the enemies were killed or not
							if i == 1
								local all_wiped = 0
								for j = 1, #targets
									if targets[j].atk_hpremaining <= 0
										all_wiped = $+1
									end
									if all_wiped >= #targets	-- we killed all the enemies
										-- spawn this cool ass skull explosion
										-- column:
										for i = 1,16
											local dust = P_SpawnMobj(avx+P_RandomRange(-40, 40)*FRACUNIT, avy+P_RandomRange(-40, 40)*FRACUNIT, targets[1].z+P_RandomRange(0, 450)*FRACUNIT, MT_DUMMY)
											dust.state = S_AOADUST0
											dust.scale = FRACUNIT*5
											dust.destscale = FRACUNIT*15
											dust.tics = (dust.z - dust.floorz)/FRACUNIT	/ 30
										end
										-- skull:
										for j = 1,64
											local dust = P_SpawnMobj(avx+P_RandomRange(-150, 150)*FRACUNIT, avy+P_RandomRange(-150, 150)*FRACUNIT, targets[1].z+P_RandomRange(350, 600)*FRACUNIT, MT_DUMMY)
											dust.state = S_AOADUST0
											dust.scale = FRACUNIT*5
											dust.destscale = FRACUNIT*15
											dust.tics = (dust.z - dust.floorz)/FRACUNIT	/ 30
										end
										-- skull eyes
										local caman = R_PointToAngle(avx, avy) + 180*ANG1
										local coords = {	-- these coords are added to avx, avy and targets 1 z
											{avx + 70*cos(ANG1*90 + caman), avy + 70*sin(ANG1*90 + caman), 650*FRACUNIT},		-- eye 1
											{avx + 70*cos(-ANG1*90 + caman), avy + 70*sin(-ANG1*90 + caman), 650*FRACUNIT},	-- eye 2
											{avx + 8*cos(-ANG1*90 + caman), avy + 8*sin(-ANG1*90 + caman), 550*FRACUNIT},	-- nose 1
											{avx + 8*cos(ANG1*90 + caman), avy + 8*sin(ANG1*90 + caman), 550*FRACUNIT},	-- nose 2
										}
										for j = 1, #coords
											for f = 1, 5
												local d = P_SpawnMobj(coords[j][1] + P_RandomRange(-8, 8)*FRACUNIT, coords[j][2] + P_RandomRange(-8, 8)*FRACUNIT, coords[j][3] + P_RandomRange(-16, 16)*FRACUNIT, MT_DUMMY)
												d.state = S_CDUST0
												d.tics = (d.z - 530*FRACUNIT)/FRACUNIT / 5 + P_RandomRange(0, 8)
												d.color = SKINCOLOR_BLACK
												d.scale = (j < 3 and FRACUNIT*5 or FRACUNIT*2) + P_RandomRange(-FRACUNIT/4, FRACUNIT/4)
												-- move towards cam:
												local newx = d.x + 200*cos(caman)
												local newy = d.y + 200*sin(caman)
												P_TeleportMove(d, newx, newy, d.z)
											end
										end

									else						-- nvm

									end
								end
									-- spawn a ring of dust regardless
								for j = 1,16
									local dust = P_SpawnMobj(avx, avy, targets[1].z, MT_DUMMY)
									dust.angle = ANGLE_90 + ANG1* (22*(j-1))
									dust.state = S_AOADUST1
									dust.scale = FRACUNIT*5
									dust.destscale = FRACUNIT*10
									P_InstaThrust(dust, dust.angle, 36*FRACUNIT)
								end
							end
						elseif timer > stoptimer+15
							if P_IsObjectOnGround(m)
							and m.aoa_savecoords
								P_InstaThrust(m, 0, 0)
								ANIM_set(m, m.anim_stand, true)
								m.aoa_savecoords = nil
							end
						end
					end

				elseif timer > 150

					if timer == 180	-- the camera will be moving so playing the sound from nil seems like a better idea
						S_StartSound(server.P_BattleStatus[mo.battlen].cam, sfx_aoa_1)
					end

					-- by the time the timer hits 180 we will be showing the attack
					local gox = avx + 900*cos((leveltime)*ANG1)
					local goy = avy + 900*sin((leveltime)*ANG1)
					-- simply teleport the camera, we don't need it to transition with CAM_goto

					P_TeleportMove(cam, gox, goy, targets[1].z + 350<<FRACBITS)
					cam.aiming = -ANG1*3
					cam.angle = R_PointToAngle2(gox, goy, avx, avy)

					local caman = R_PointToAngle(avx, avy) + ANG1*180

					if (leveltime%10) == 0
						local h = P_SpawnMobj(avx + P_RandomRange(-100, 100)<<FRACBITS, avy + P_RandomRange(-100, 100)<<FRACBITS, targets[1].z + P_RandomRange(0, 40)<<FRACBITS, MT_DUMMY)
						h.state = S_HURTB1
						h.scale = FRACUNIT*4 + P_RandomRange(-FRACUNIT/4, FRACUNIT/2)
						h.eflags = $ | MFE_VERTICALFLIP*P_RandomRange(0, 1)
						-- pull towards cam
						P_TeleportMove(h, h.x + 100*cos(caman), h.y + 100*sin(caman), h.z)
					end

					if leveltime%2 == 0
						for i=1,6
							local smoke = P_SpawnMobj(avx + P_RandomRange(-150, 150)*FRACUNIT, avy + P_RandomRange(-150, 150)*FRACUNIT, targets[1].z + P_RandomRange(0, 250)*FRACUNIT, MT_DUMMY)
							smoke.state = S_AOADUST1
							smoke.scale = FRACUNIT*5
							smoke.destscale = FRACUNIT*9
							smoke.momz = P_RandomRange(3, 8)*FRACUNIT
						end
					end

					local ring_rate = max(5, 15 -(timer-180)/7)

					if leveltime%ring_rate == 0
					and not fatal
						for i=1,2
							local ring = P_SpawnMobj(avx, avy, targets[1].z + 70*FRACUNIT, MT_FLINGRING)
							ring.momz = P_RandomRange(4, 10)*FRACUNIT
							P_InstaThrust(ring, P_RandomRange(1, 359)*ANG1, P_RandomRange(4, 10)*FRACUNIT)
							ring.fuse = TICRATE*5
							ring.flags = $1 & ~MF_SPECIAL
							if i == 1
								S_StartSound(ring, sfx_s3kb9)
							end
						end
					end

					for i = 1, #mo.allies

						local m = mo.allies[i]

						if noaoa(m)
							continue	-- Not me! I can't act either!
						end

						if timer == 151
							ANIM_set(m, m.anim_atk, true)
							-- save our default coordinates and our angle towards the average coord
							m.aoa_savecoords = {m.x, m.y, m.z, R_PointToAngle2(m.x, m.y, avx, avy)}
						end

						-- our "axis" is a roating point around the average coord of the targets

						local an1 = leveltime * 24*ANG1 + i*ANG1*90
						local bx = avx + 200*cos(an1)
						local by = avy + 200*sin(an1)

						-- now we have what to circle around of
						local an2 = leveltime/i + 25*ANG1 + i*45*ANG1
						local x = bx + 200*cos(an2)
						local y = by + 200*sin(an2)
						local z = targets[1].z + R_PointToDist2(x, y, avx, avy)/3 + i*3/2*18*FRACUNIT + 128*sin(i*3*leveltime*ANG1)

						P_TeleportMove(m, x, y, z)
						m.angle = an2 + ANG1*90
						P_SpawnGhostMobj(m)

						/*
						local opq = P_SpawnMobj(x, y, z, MT_DUMMY)
						opq.frame = $ & ~FF_TRANSMASK
						opq.frame = $|FF_FULLBRIGHT
						opq.color = m.color
						opq.fuse = 2*/
						-- spawn trail
						local trail = P_SpawnMobj(x, y, z, MT_DUMMY)
						trail.frame = $|FF_FULLBRIGHT
						trail.color = m.color
						trail.destscale = 1
						trail.fuse = TICRATE
					end
				end

			end,
	},

}
)



rawset(_G, "sorted_attackDefs", {})
for k,v in pairs(attackDefs)
	sorted_attackDefs[#sorted_attackDefs+1] = k
end

-- now sort it
table.sort(sorted_attackDefs,	function(a, b)

									local t = attackDefs
									-- sort by type:

									if t[a].type & ~ATK_PASSIVE ~= t[b].type & ~ATK_PASSIVE
									and t[a].type & ~ATK_PASSIVE and t[b].type & ~ATK_PASSIVE
										return (t[a].type & ~ATK_PASSIVE or 1) < (t[b].type & ~ATK_PASSIVE or 1)


									elseif (t[a].passive and t[b].passive) 	--and t[a].passive ~= t[b].passive

										if t[a].type == ATK_PASSIVE and t[b].type == ATK_PASSIVE
											return a < b

										elseif t[a].passive ~= t[b].passive
											return t[a].passive < t[b].passive

										elseif t[a].power and t[b].power and t[a].power ~= t[b].power
											return t[a].power < t[b].power

										elseif t[a].accuracy and t[b].accuracy
											return t[a].accuracy < t[b].accuracy

										else
											return a < b

										end

									elseif t[a].passive ~= t[b].passive
										return (not t[a].passive) and t[b].passive


									elseif t[a].instakill ~= t[b].instakill
										return (not t[a].instakill) and t[b].instakill

									elseif t[a].status ~= t[b].status
										return (not t[a].status) and t[b].status

									elseif t[a].power ~= t[b].power	-- or by power
										return (t[a].power or 1) < (t[b].power or 1)
									elseif t[a].cost ~= t[b].cost	-- or by cost...
										return (t[a].cost or 1) < (t[b].cost or 1)

									elseif t[a].status and t[b].status
										if t[a].status ~= t[b].status
											return t[a].status < t[b].status
										else
											return t[a].target < t[b].target
										end

									elseif t[a].target ~= t[b].target	-- or by target.
										return (t[a].target or 1) < (t[b].target or 1)

									else
										return a < b
									end
								end)

/*for i = 1, #sorted_attackDefs
	print(sorted_attackDefs[i])
end*/