-- Stuff for dungeon abilities:

rawset(_G, "DNG_Abilities", {})

/*
	Syntax:

	DNG_Abilities["skin"] = {
		jfunc = function(p, intartarus)		/ Function that runs when you press jump once mid-air. Regardless of what happens, p.mo.p_abl is set to true here
		rfunc = function(p, intartarus)		/ Runs when you hit the floor after using your ability
		func = function(p, intaratarus)		/ Function that runs continuously for the player with that skin
	}

*/

-- execute abilities for dungeons
rawset(_G, "DNG_HandleAbilities", function(p, tartarus)
	local mo = p.mo
	if not mo return end
	if not DNG_Abilities[mo.skin] return end
	local abl = DNG_Abilities[mo.skin]

	local inputs = mo.P_inputs

	mo.a_jumptimer = $ or 0
	if p.pflags & PF_JUMPED
		mo.a_jumptimer = $+1
	else
		mo.a_jumptimer = 0
	end

	if inputs[BT_JUMP] == 1
	and mo.a_jumptimer > 2
	and p.pflags & PF_JUMPED
	and not mo.p_abl
	and abl.jfunc
	and not p.noability
		abl.jfunc(p, tartarus)		-- jump function
		mo.p_abl = true
	end

	if abl.func
		abl.func(p, tartarus)
	end

	if (P_IsObjectOnGround(mo) or P_PlayerInPain(p))
	and mo.p_abl
		if abl.rfunc
			abl.rfunc(p, tartarus)
		end
		mo.p_abl = false	-- reset ability on ground
	end
end)

-- Sonic: Jump Thok
-- A bit slower than a normal thok, but you gain a bit of height
-- Also keeps your current momentum

DNG_Abilities["sonic"] = {

	jfunc = 	function(p)
					local mo = p.mo

					p.drawangle = mo.angle
					local thokspeed = FixedHypot(mo.momx, mo.momy) > 20*mo.scale and FixedHypot(mo.momx, mo.momy) or 20*mo.scale
					P_InstaThrust(mo, p.mo.angle, thokspeed)
					P_SetObjectMomZ(mo, FRACUNIT*8)

					local t = P_SpawnMobjFromMobj(mo, 0, 0, 0, MT_THOK)
					t.color = mo.color
					S_StartSound(mo, sfx_thok)
				end,

	func =		function(p)
					local mo = p.mo

					if mo.p_abl
						if ((mo.eflags & MFE_VERTICALFLIP) and mo.momz < 0)
						or (not (mo.eflags & MFE_VERTICALFLIP) and mo.momz > 0)
							if (leveltime%2)
								local g = P_SpawnGhostMobj(mo)
								g.tics = 4
								g.colorized = true
							end
						else
							mo.state = S_PLAY_FALL
							p.pflags = $ & ~PF_JUMPED
							mo.p_abl = false
						end
					end
				end,
}

-- Metal Sonic: Dash Mode
-- This thinker exists to limit his speed somewhat

DNG_Abilities["metalsonic"] = {
	func =		function(p)
					if p.dashmode and p.dashmode > TICRATE*3
						p.normalspeed = min($, FRACUNIT*45)
					end
				end,
}

-- Tails: Tornado Takeoff
-- Fly upwards quickly.
-- You will then slowly fall back to the ground.

DNG_Abilities["tails"] = {

	jfunc = 	function(p)
					local mo = p.mo

					p.fly1 = 15 -- this is used to speed up the tails
					p.pflags = $ & ~PF_JUMPED
					mo.momx, mo.momy = $/2, $/2
					mo.state = S_PLAY_FLY
					P_SetObjectMomZ(mo, FRACUNIT*12)
					S_StartSound(mo, sfx_zoom)
				end,

	func =		function(p)
					local mo = p.mo

					if mo.p_abl
						-- lower timer for fast tail spinning and play sfx
						p.fly1 = $ and $-1
						if not (leveltime%10)
							S_StartSound(mo, sfx_putput)
						end

						p.pflags = $|PF_CANCARRY

						-- the ability: going up
						if ((mo.eflags & MFE_VERTICALFLIP) and mo.momz < 0)
						or (not (mo.eflags & MFE_VERTICALFLIP) and mo.momz > 0)
							-- reduce speed to 95%
							mo.momx, mo.momy = $*95/100, $*95/100

							-- spawn based advanced ghosts
							if (leveltime%2)
								local g = P_SpawnGhostMobj(mo)
								g.tics = 4
								g.colorized = true
							end
						else
							if (p.cmd.buttons & BT_JUMP) -- slowfall
								P_SetObjectMomZ(mo, gravity*2/3, true)
								--print(-P_GetMobjGravity(mo)*2/3 /FRACUNIT)

								if P_IsObjectOnGround(mo)
									mo.p_abl = false
								end
							else -- fall
								mo.state = S_PLAY_FALL
								mo.p_abl = false
								p.pflags = $ & ~PF_CANCARRY
							end
						end
					end
				end,

}

-- function to reset hammerjump vars
local function P_ResetHammerjumpVars(mo)
	mo.amy_hammerjump = nil
	mo.amy_hammerjump_timer = nil
	mo.amy_hammerjump_uncurl = nil
end

-- quick function to tell if the player is going up or not
local function P_IsGoingUp(mo)
	if ((mo.eflags & MFE_VERTICALFLIP) and mo.momz < 0)
	or (not (mo.eflags & MFE_VERTICALFLIP) and mo.momz > 0)
		return true
	end

	return false
end

addHook("MobjCollide", function(mo) return false end, MT_LHRT)
addHook("MobjMoveCollide", function(mo) return false end, MT_LHRT)

DNG_Abilities["amy"] = {
	jfunc = 	function(p)
					return true
				end,

	func =		function(p)
					p.charability = CA_TWINSPIN
					local mo = p.mo

					-- "it's just your code, but very heavily edited"
					--	-snu

					-- start hammerjump
					if (mo.state == S_PLAY_MELEE_LANDING)
					and FixedHypot(mo.momx, mo.momy) > ((mo.eflags & MFE_UNDERWATER) and 14 or 23)*mo.scale
					and ((p.cmd.buttons & BT_JUMP) or (p.cmd.buttons & BT_USE))
						local min_range, max_range = (mo.eflags & MFE_UNDERWATER) and 6 or 13, (mo.eflags & MFE_UNDERWATER) and 8 or 17
						local speed = (FixedHypot(mo.momx, mo.momy)>>FRACBITS)/2
						local hammerjump_height = min(max_range, max(min_range, speed))

						P_SetObjectMomZ(mo, hammerjump_height*FRACUNIT)
						mo.amy_hammerjump = true
						mo.amy_hammerjump_timer = 25 + (hammerjump_height-min_range)
						mo.state = S_PLAY_ROLL
					end

					-- handle animation
					if (mo.amy_hammerjump)
						-- interrupted?
						if not (mo.state == S_PLAY_ROLL)
							P_ResetHammerjumpVars(mo)
							return
						else
							if (leveltime%2)
								local g = P_SpawnGhostMobj(mo)
								g.tics = 4
								g.colorized = true
							end
						end

						mo.amy_hammerjump_timer = $ and $-1
						if not (mo.amy_hammerjump_timer)
							-- uncurl on a specific frame for better flow
							if (mo.amy_hammerjump_uncurl == (P_IsGoingUp(mo) and 2 or 1)) -- we check again here since you never know what might change in 1 frame LOL
								mo.state = P_IsGoingUp(mo) and S_PLAY_SPRING or S_PLAY_FALL
								P_ResetHammerjumpVars(mo)
							end

							-- use FF_FRAMEMASK since super frames get FF_FULLBRIGHT
							if ((mo.frame & FF_FRAMEMASK) == (P_IsGoingUp(mo) and 2 or 3))
								mo.amy_hammerjump_uncurl = P_IsGoingUp(mo) and 2 or 1
							end
						end
					end
				end,
}

-- Shadow: Chaos Snap
-- A quick chaos snap in the direction you're holding.
-- Gravity is NULL so good for traversal.

-- Numerous definitions boworred from shadow's lua...
local RUN_TICS = { // number of tics to display each running frame
	10,
	4,
	3,
	2,
	2,
	10,
	4,
	3,
	2,
	2,
}

local function GetCVar(var)
	return var and var.value or 1
end

local spr2numframes = {}
local function GetSprite2NumFrames(skin, spr2)
	local frame

	if not spr2numframes[skin]
		spr2numframes[skin] = {}
	else
		frame = spr2numframes[skin][spr2]
	end

	if frame ~= nil
		return frame
	end

	local statenum = S_UNKNOWN
	local state = states[statenum]
	local statedef = {
		state.sprite,
		state.frame,
		state.tics,
		state.action,
		state.var1,
		state.var2,
		state.nextstate
	}
	local thok = P_SpawnMobj(0, 0, 0, MT_THOK)
	state.sprite = SPR_PLAY
	state.frame = spr2
	state.action = nil
	thok.skin = skin
	thok.state = statenum
	frame = -1
	while thok.frame & FF_FRAMEMASK > frame
		frame = thok.frame & FF_FRAMEMASK
		thok.state = statenum
	end
	frame = $ + 1
	spr2numframes[skin][spr2] = frame
	states[statenum] = statedef
	P_RemoveMobj(thok)
	return frame
end

local SKATE_FLAME_ANIMS = {
	[SPR2_RUN] = SPR2_TAL0|FF_ANIMATE, // NOTE: FF_ANIMATE signifies that the flames should match their frame with the player's instead of animating independently
	[SPR2_RUN|FF_SPR2SUPER] = SPR2_TAL0|FF_SPR2SUPER,
	[SPR2_SKID] = SPR2_TAL1|FF_SPR2ENDSTATE // NOTE: FF_SPR2ENDSTATE signifies that the flames should animate only once until the player leaves the spr2
}


local function UpdateSkateFlame(player, flame)
	local mo = player.mo
	local data = mo and SKATE_FLAME_ANIMS[mo.sprite2]

	if not data
	or mo.sprite ~= SPR_PLAY
	or mo.eflags & MFE_UNDERWATER
		if flame and flame.valid
			flame.sprite2 = SPR2_STND
			P_SetMobjStateNF(flame, flame.info.spawnstate)
		end
		return
	end

	local frame = flame.frame & FF_FRAMEMASK
	local sprite2 = data & FF_FRAMEMASK
	local camangle
	if splitscreen
		camangle = player.cmd.angleturn << 16
	else
		camangle = R_PointToAngle(mo.x, mo.y)
	end

	flame.flags2 = $ & ~MF2_DONTDRAW | (mo.flags2 & MF2_DONTDRAW)
	flame.scale = mo.scale
	flame.color = SKINCOLOR_ORANGE

	if flame.sprite2 ~= sprite2
		flame.skin = "shadow"
		flame.sprite = SPR_PLAY
		flame.sprite2 = sprite2
		flame.flags2 = $ & ~(MF2_SLIDEPUSH|MF2_CLASSICPUSH|MF2_LINKDRAW)
		frame = -1
	end

	if data & FF_ANIMATE
		frame = mo.frame & FF_FRAMEMASK
		flame.flags2 = $ & ~(MF2_SLIDEPUSH|MF2_CLASSICPUSH)
	elseif not (flame.flags2 & MF2_CLASSICPUSH)
		flame.flags2 = $ ^^ MF2_SLIDEPUSH
		if flame.flags2 & MF2_SLIDEPUSH
			if data & FF_SPR2ENDSTATE
				frame = $ + 1
				if frame >= GetSprite2NumFrames("shadow", sprite2)
					flame.flags2 = $ | MF2_CLASSICPUSH
					P_SetMobjStateNF(flame, flame.info.spawnstate)
				end
			else
				frame = ($ + 1) % GetSprite2NumFrames("shadow", sprite2)
			end
		end
	end

	flame.frame = frame | FF_FULLBRIGHT | (leveltime & 1) * FF_TRANS40

	if GetCVar(cv_renderer) == 2
		P_TeleportMove(flame,
			mo.x + P_ReturnThrustX(flame, camangle, -mo.scale),
			mo.y + P_ReturnThrustY(flame, camangle, -mo.scale),
			flame.z)
	end
end

freeslot("sfx_shadsr", "sfx_shadsl")
DNG_Abilities["shadow"] = {

	jfunc = 	function(p)
					local mo = p.mo

					p.pflags = $ & ~PF_JUMPED
					mo.sh_snaptime = 6
					mo.momz, mo.state, mo.flags = 0, S_PLAY_FALL, $|MF_NOGRAVITY

					-- N, NE, E, SE, S, SW, W, NW
					local angles = {}
					for i = 1, 8
						angles[i] = mo.angle-(ANGLE_45*(i-1))
					end

					local angle = 1 -- default to forward with no input
					if (p.cmd.sidemove)
						if (p.cmd.sidemove < 0) -- left
							if (p.cmd.forwardmove) -- diagonal
								angle = (p.cmd.forwardmove) > 0 and 8 or 6
							else
								angle = 7
							end
						else -- right
							if (p.cmd.forwardmove) -- diagonal
								angle = (p.cmd.forwardmove) > 0 and 2 or 4
							else
								angle = 3
							end
						end
					else -- forward/back
						if (p.cmd.forwardmove)
							angle = (p.cmd.forwardmove) > 0 and 1 or 5
						end
					end

					p.drawangle = angles[angle]
					P_InstaThrust(mo, angles[angle], 50*mo.scale)

					mo.state = S_PLAY_FALL

					local s = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
					s.skin = mo.skin
					s.sprite = mo.sprite
					s.angle = p.drawangle
					s.frame = mo.frame & FF_FRAMEMASK | FF_TRANS60
					s.fuse = TICRATE/7
					s.scale = mo.scale
					s.destscale = mo.scale*6
					s.scalespeed = mo.scale/2
					s.sprite2 = mo.sprite2
					s.color = SKINCOLOR_CYAN
					s.colorized = true
					s.tics = -1


					S_StartSound(mo, sfx_csnap)

					mo.state = S_SHADOW_WARP1
				end,

	func =		function(p)
					local mo = p.mo

					if mo.p_abl
						if (mo.sh_snaptime)
							mo.sh_snaptime = $-1
							mo.flags2 = $|MF2_DONTDRAW
							if P_IsObjectOnGround(mo)
								mo.flags, mo.flags2 = $ & ~MF_NOGRAVITY, $ & ~MF2_DONTDRAW
								mo.p_abl = false
							end
						else
							mo.momx, mo.momy = $/2, $/2
							mo.flags, mo.flags2 = $ & ~MF_NOGRAVITY, $ & ~MF2_DONTDRAW
							mo.p_abl = false

							/*local s = P_SpawnMobj(mo.x, mo.y, mo.z+FRACUNIT*24, MT_DUMMY)
							s.state = S_CHAOSCONTROL1
							s.destscale = 3*FRACUNIT*/
							mo.state = S_SHADOW_WARP2
						end
					end

					if mo.sprite2 == SPR2_WALK
						mo.prevwalkframe = mo.frame & FF_FRAMEMASK
					end

					if mo.sprite2 == SPR2_RUN
						// lift a different foot depending on the previous walk frame
						// G H A B for left foot first
						// C D E F for right foot first
						if mo.prevrunframe == -1
							local maxframe = GetSprite2NumFrames("shadow", SPR2_WALK)
							if (mo.prevwalkframe + 2) % maxframe < maxframe/2
								for i = 1, GetSprite2NumFrames("shadow", SPR2_RUN)/2
									mo.state = $
								end
							end
						end

						// adjust timing and play sound effects
						local frame = mo.frame & FF_FRAMEMASK
						if frame ~= mo.prevrunframe
							mo.tics = RUN_TICS[frame + 1] or 0
							if FixedDiv(p.speed, mo.movefactor) > 52*mo.scale
								mo.tics = max(1, $ - 1)
							end

							if frame == 0
								S_StartSound(mo, sfx_shadsr)
							elseif frame == GetSprite2NumFrames("shadow", SPR2_RUN)/2
								S_StartSound(mo, sfx_shadsl)
							end

							mo.prevrunframe = frame
						end
					elseif mo.prevrunframes ~= nil and mo.prevrunframes >= 0
						mo.prevrunframe = -1
					end

					UpdateSkateFlame(p, p.followmobj)

				end,
}

DNG_Abilities["eggman"] = {

	jfunc = 	function(p)
					local mo = p.mo

					p.fly1 = 15 -- this is used to speed up the jetpack
					p.pflags = $ & ~PF_JUMPED
					mo.momx, mo.momy = $/2, $/2
					mo.state = S_PLAY_FLY
					P_SetObjectMomZ(mo, FRACUNIT*12)
					S_StartSound(mo, sfx_zoom)
				end,

	func =		function(p)
					local mo = p.mo

					if mo.p_abl
						-- lower timer for fast jetpack and play sfx
						p.fly1 = $ and $-1
						if not (leveltime%7)
							S_StartSound(mo, sfx_jet)
						end

						p.pflags = $|PF_CANCARRY

						-- the ability: going up
						if ((mo.eflags & MFE_VERTICALFLIP) and mo.momz < 0)
						or (not (mo.eflags & MFE_VERTICALFLIP) and mo.momz > 0)
							-- reduce speed to 95%
							mo.momx, mo.momy = $*95/100, $*95/100

							-- spawn based advanced ghosts
							if (leveltime%2)
								local g = P_SpawnGhostMobj(mo)
								g.tics = 4
								g.colorized = true
							end
						else
							if (p.cmd.buttons & BT_JUMP) -- slowfall
								P_SetObjectMomZ(mo, -P_GetMobjGravity(mo)*2/3, true)

								if P_IsObjectOnGround(mo)
									mo.p_abl = false
								end
							else -- fall
								mo.state = S_PLAY_FALL
								mo.p_abl = false
								p.pflags = $ & ~PF_CANCARRY
							end
						end
					end
				end,

}

DNG_Abilities["blaze"] = {

	jfunc = 	function(p)
					local mo = p.mo

					p.pflags = $ & ~PF_JUMPED
					mo.momz, mo.state = 0, S_PLAY_FALL
				end,

	rfunc =		function(p)
					local mo = p.mo

					if not P_IsObjectOnGround(mo)
						mo.state = S_PLAY_FALL
					end
					S_StopSoundByID(mo, sfx_blzhvr)
				end,

	func =		function(p)
					local mo = p.mo

					--some funny haha fire FX for runnin'
					local fuckunit = p.mo.scale
					if P_IsObjectOnGround(p.mo) and (p.speed > FixedMul(p.runspeed, fuckunit))
					and (p.panim == PA_RUN or p.panim == PA_ROLL) and not p.powers[pw_carry]
						if leveltime % 2 == 0
							local fire1 = P_SpawnMobjFromMobj(p.mo, P_ReturnThrustX(p.drawangle+FixedAngle(160*FRACUNIT), 20*FRACUNIT), P_ReturnThrustY(p.drawangle+FixedAngle(160*FRACUNIT), 20*FRACUNIT), 0, MT_BLAZE_RUNFIRE)
							if p.mo.eflags & MFE_UNDERWATER
								fire1.state = S_PARTICLE
								fire1.destscale = 7*p.mo.scale
							end
							fire1.color = SKINCOLOR_BLAZING
							fire1.fuse = 6
							P_SetObjectMomZ(fire1, 2*fuckunit+fuckunit/2, false)
							fire1.momx = p.mo.momx*3/4
							fire1.momy = p.mo.momy*3/4
							P_Thrust(fire1, R_PointToAngle2(p.mo.x, p.mo.y, fire1.x, fire1.y), 5*fuckunit)
							fire1.angle = R_PointToAngle2(p.mo.x, p.mo.y, fire1.x, fire1.y)
							fire1.scale = p.mo.scale - p.mo.scale/5
							local fire2 = P_SpawnMobjFromMobj(p.mo, P_ReturnThrustX(p.drawangle+FixedAngle(200*FRACUNIT), 20*FRACUNIT), P_ReturnThrustY(p.drawangle+FixedAngle(200*FRACUNIT), 20*FRACUNIT), 0, MT_BLAZE_RUNFIRE)
							if p.mo.eflags & MFE_UNDERWATER
								fire2.state = S_PARTICLE
								fire2.destscale = 7*p.mo.scale
							end
							fire2.color = SKINCOLOR_BLAZING
							fire2.fuse = 6
							P_SetObjectMomZ(fire2, 2*fuckunit+fuckunit/2, false)
							fire2.momx = p.mo.momx*3/4
							fire2.momy = p.mo.momy*3/4
							P_Thrust(fire2, R_PointToAngle2(p.mo.x, p.mo.y, fire2.x, fire2.y), 5*fuckunit)
							fire2.angle = R_PointToAngle2(p.mo.x, p.mo.y, fire2.x, fire2.y)
							fire2.scale = p.mo.scale - p.mo.scale/5
						end
					end

					if mo.p_abl
						P_SetObjectMomZ(mo, -P_GetMobjGravity(mo)*19/20, true)

						if mo.state ~= S_PLAY_BLAZE_HOVER
						and not P_IsObjectOnGround(mo)
							mo.state = S_PLAY_BLAZE_HOVER
							S_StartSound(mo, sfx_blzhvr)
						end

						-- spawn fire

						--flames
						local fuckunit = mo.scale
						local dist = 19
						local apart = 8
						local zheight = 4
						if not (p.flame1 and p.flame1.valid) and not (p.flame2 and p.flame2.valid)
							local flame1 = P_SpawnMobjFromMobj(p.mo, P_ReturnThrustX(flame1, p.drawangle+FixedAngle(180*FRACUNIT), dist*FRACUNIT)+
							P_ReturnThrustX(flame1, p.drawangle+FixedAngle(90*FRACUNIT), apart*fuckunit),
							P_ReturnThrustY(flame1, p.drawangle+FixedAngle(180*FRACUNIT), dist*fuckunit)+
							P_ReturnThrustX(flame1, p.drawangle+FixedAngle(90*FRACUNIT), apart*fuckunit),
							-zheight*fuckunit*P_MobjFlip(p.mo), MT_BLAZE_HOVERFIRE)
							flame1.invuln = 7
							flame1.color = SKINCOLOR_BLAZING
							flame1.target = p.mo
							flame1.flame1 = true
							flame1.scale = p.mo.scale --+ p.mo.scale/4
							p.flame1 = flame1
							local flame2 = P_SpawnMobjFromMobj(p.mo, P_ReturnThrustX(flame2, p.drawangle+FixedAngle(180*FRACUNIT), dist*FRACUNIT)+
							P_ReturnThrustX(flame1, p.drawangle+FixedAngle(-90*FRACUNIT), apart*fuckunit),
							P_ReturnThrustY(flame2, p.drawangle+FixedAngle(180*FRACUNIT), dist*fuckunit)+
							P_ReturnThrustY(flame1, p.drawangle+FixedAngle(-90*FRACUNIT), apart*fuckunit),
							-zheight*fuckunit*P_MobjFlip(p.mo), MT_BLAZE_HOVERFIRE)
							flame2.invuln = 7
							flame2.color = SKINCOLOR_BLAZING
							flame2.target = p.mo
							flame2.flame2 = true
							flame2.scale = p.mo.scale --+ p.mo.scale/4
							p.flame2 = flame2
						end

						if not (p.cmd.buttons & BT_JUMP)
							if not P_IsObjectOnGround(mo)
								mo.state = S_PLAY_FALL
							end
							S_StopSoundByID(mo, sfx_blzhvr)
							mo.p_abl = false
						end
					end
				end,
}

rawset(_G, "silv_spawnAura", function(p)
	local mo = p.mo
	if not mo return end
	if mo.silv_aurastate return end	-- aura already activated

	mo.silv_aurastate = 1
	mo.silv_aurafade = 10

	if not mo.silv_soundhelper
		mo.silv_soundhelper = P_SpawnMobj(mo.x, mo.y, mo.z, MT_THOK)
		mo.silv_soundhelper.state = S_INVISIBLE
	end
end)

rawset(_G, "silv_despawnAura", function(p)

	local mo = p.mo
	if not mo return end
	if not mo.silv_aurastate return end	-- aura already deactivated

	mo.silv_aurastate = 0
	mo.silv_aurafade = 20
	S_StartSound(mo, sfx_pcan)	-- cancel aura sound

	if mo.silv_soundhelper and mo.silv_soundhelper.valid
		P_RemoveMobj(mo.silv_soundhelper)
		mo.silv_soundhelper = nil	-- reset this so it can be spawned again
	end

end)

local function silv_handleAura(p)
	local mo = p.mo
	if not mo return end

	local tr = 0

	if mo.silv_aurastate == 1
		mo.silv_aurafade = max(0, $-1)
		tr = (not mo.silv_aurafade and 5 or 5+(mo.silv_aurafade)/2)
	elseif mo.silv_aurastate == 0
		mo.silv_aurafade = max(0, $-1)
		tr = 10-(mo.silv_aurafade)/4
	end

	-- transparency != null and < 10, draw a layer!
	if tr and tr < 10

		if tr == 5	-- special case for mid level transparency
			tr = ($*FRACUNIT + (2*sin(leveltime*ANG1*16)))/FRACUNIT
		end

		if mo.silv_soundhelper and mo.silv_soundhelper.valid
			if not S_SoundPlaying(mo.silv_soundhelper, sfx_levi)
				S_StartSound(mo.silv_soundhelper, sfx_levi)
			end
			P_TeleportMove(mo.silv_soundhelper, mo.x, mo.y, mo.z)
		end

		-- OVERLAY SPAWN

		local ref = mo
		local color = SKINCOLOR_AQUA

		while ref
			local a = R_PointToAngle(ref.x, ref.y)
			local o = P_SpawnMobjFromMobj(ref, -cos(a), -sin(a), 0, MT_DUMMY)
			o.target = mo
			if splitscreen	-- splitscreen doesn't support the above...
				P_TeleportMove(o, ref.x, ref.y, o.z)
			end

			o.height = ref.height
			o.radius = ref.radius
			o.z = mo.z	-- regardless of flag

			if ref.skin
				o.skin = ref.skin
			end
			o.state = ref.state
			o.tics = ref.tics	-- opengl model interp
			o.sprite = ref.sprite
			o.sprite2 = ref.sprite2
			o.frame = (ref.frame & ~FF_TRANSMASK) | (tr<<FF_TRANSSHIFT) | FF_FULLBRIGHT
			if ref.player
				o.angle = p.drawangle
			else
				o.angle = ref.angle
			end
			o.rollangle = ref.rollangle

			o.colorized = true
			o.color = color

			o.fuse = 1

			if ref.player
				ref = ref.player.followmobj
			else
				ref = nil
			end
		end

		if tr >= 3 and tr <= 7
			for i = 1, 6
				local x = FixedMul(mo.scale/2 + FRACUNIT/2, P_RandomRange(-24, 24)*FRACUNIT)
				local y = FixedMul(mo.scale/2 + FRACUNIT/2, P_RandomRange(-24, 24)*FRACUNIT)
				local z = P_RandomRange(0, (mo.height/2)>>FRACBITS)<<FRACBITS	-- already to scale

				local s = P_SpawnMobjFromMobj(mo, x, y, z, MT_THOK)
				s.state = S_FRAG1
				s.scale = mo.scale
				s.color = color

				s.momz = mo.momz + mo.pmomz + P_MobjFlip(s)*P_RandomRange(3, 6)*s.scale
				s.momx = mo.momx
				s.momy = mo.momy
			end
		end
	end
end

-- run handler; lowers 'runspeed' when you run fast enough.
local function silv_runHandle(p)
	-- that much is specific to SILVER only.
	local mo = p.mo
	if mo.skin ~= "silver" return end	-- so if you aren't playing as him, this should not take effect

	local topspeed = p.normalspeed
	if maptol & TOL_2D or mo.flags2 & MF2_TWOD
		topspeed = $*2/3	-- 2d levels make players slower
	end

	local speed = p.speed and FixedDiv(p.speed, mo.scale) or 0
	if speed > topspeed - 6*FRACUNIT
		p.runspeed = max(topspeed - FRACUNIT*6, $-FRACUNIT)
		if speed > p.runspeed	-- wow!
			p.runspeed = topspeed - FRACUNIT*6	-- don't even care
		end

	else
		p.runspeed = min(skins["silver"].runspeed, $+FRACUNIT/2)	-- don't make it too janky
	end

	if p.powers[pw_super]
		p.runspeed = mo.scale*28
		mo.silv_runghost = nil	-- just in case
		return
	end

	-- while running:
	if mo.state == S_PLAY_RUN
		if mo.silv_runghost == nil
			mo.silv_runghost = 6
		else
			mo.silv_runghost = $-1
		end
		silv_spawnAura(p)

		if mo.silv_runghost > 0
		and leveltime%2
			local g = P_SpawnGhostMobj(mo)
			g.colorized = true
			g.rollangle = mo.rollangle
			g.radius = mo.radius
			g.height = mo.height
			g.tics = 3
		end
	else
		if p.speed < p.runspeed
			mo.silv_runghost = nil
		end
	end
end

DNG_Abilities["silver"] = {

	jfunc = 	function(p)
					local mo = p.mo

					p.pflags = $ & ~PF_JUMPED
					mo.silv_floattime = 3*TICRATE
					mo.state = S_PLAY_FLOAT
					silv_spawnAura(p)
					S_StartSound(mo, sfx_float)
				end,

	func =		function(p)
					local mo = p.mo

					silv_runHandle(p)
					silv_handleAura(p)

					if mo.state ~= S_PLAY_RUN
					and not mo.p_abl
					and mo.state ~= S_PLAY_WAIT
						silv_despawnAura(p)
					end

					if mo.state == S_PLAY_WAIT
						silv_spawnAura(p)
					end

					if mo.p_abl
						mo.state = S_PLAY_FLOAT
						mo.momz = 0
						mo.silv_floattime = $-1

						if P_IsObjectOnGround(mo)
							mo.p_abl = false
						else
							if not (p.cmd.buttons & BT_JUMP)
							or not mo.silv_floattime
								mo.state = S_PLAY_FALL
								mo.p_abl = false
							end
						end
					end
				end,
}

local AP_MIDFALLTHRESHOLD = -2

local function AP_midFallFrame(p)
	local mo = p.mo
	if mo.state == S_PLAY_SPRING or mo.state == S_PLAY_FALL
	or mo.state == S_PLAY_FLOATEND	-- special to CA_ANGELWINGS
	or (mo.state == S_PLAY_ROLL and not p.powers[pw_carry] and p.pflags & PF_JUMPED and ((mo.frame & FF_FRAMEMASK) == C))

		local momz = mo.momz*P_MobjFlip(mo)

		if momz <= 0
		and momz >= AP_MIDFALLTHRESHOLD * mo.scale
		and mo.state ~= S_PLAY_FLOATEND	-- not applied for this state
			mo.state = S_PLAY_MIDFALL
		end

		if mo.state == S_PLAY_FALL
		and momz > 0
			mo.state = S_PLAY_SPRING
		end

	end

	if mo.state == S_PLAY_MIDFALL
	or mo.state == S_PLAY_FLOATEND	-- special to CA_ANGELWINGS
		local momz = mo.momz*P_MobjFlip(mo)

		local threshold = S_PLAY_MIDFALL and AP_MIDFALLTHRESHOLD or AP_MIDFALLTHRESHOLD*5/2
		-- bit of a specific case, I know...

		if momz > 0
			mo.state = S_PLAY_SPRING
		elseif momz < threshold * mo.scale
			mo.state = S_PLAY_FALL
		end
	end
end

-- AngelPlayer: Handler for CA_ANGELWINGS
-- Enables use of wings for a improved vertical mobility and slowfalling.
-- Also leaves a gust of wind behind usable by allies.

-- quick constants to recognize what the ability is doing:
local ws_cst = {
	"WS_NONE",
	"WS_PREP",
	"WS_UP",
	"WS_FREEFALL",
	"WS_FLOAT"
}
for i = 1, #ws_cst
	rawset(_G, ws_cst[i], i-1)
end

-- Functions to get the wings to ... do things!

-- Wing fancy dust stuff
rawset(_G, "AP_wingDust", function(mo, s)

	local comp = mo.floorz
	if mo.eflags & MFE_VERTICALFLIP
		comp = mo.ceilingz
	end

	if abs(mo.z - comp) < mo.scale*128

		for i = 1, 16

			local a = P_SpawnMobj(mo.x, mo.y, comp, MT_THOK)
			a.scale = mo.scale
			a.state = S_SPINDUST1
			a.eflags = $ | (mo.eflags & MFE_VERTICALFLIP)
			P_InstaThrust(a, (360/16)*i*ANG1, mo.scale*(inwater and s/2 or s))
		end
		return comp
	end
	return nil	-- not spawned
end)

-- Wing spawn effect for wings.
local function AP_wingSpawnEffect(w, s)
	local g = P_SpawnGhostMobj(w)
	g.destscale = w.scale*4
	g.scalespeed = w.scale/12
	g.colorized = true
	if w.target and w.target.valid
		g.color = w.target.color
	end

	if s and w.target and w.target.valid
		S_StartSound(w.target, sfx_wngapr)
	end
	-- spawn sparks:

	-- first, get some "reference" point in the "middle" of the wings
	local wingdist = 64
	local x, y = w.x + FixedMul(w.scale, wingdist*cos(w.angle)), w.y + FixedMul(w.scale, wingdist*sin(w.angle))

	for i = 1, 16
		local s = P_SpawnMobj(x + P_RandomRange(-wingdist, wingdist)*w.scale, y + P_RandomRange(-wingdist, wingdist)*w.scale, w.z + P_RandomRange(-wingdist/2, wingdist/2)*w.scale, MT_THOK)
		s.state = S_WINGSPARK1
		s.scale = w.scale
		if w.target and w.target.valid
			s.color = w.target.color
		end
		w.flags = $ & ~MF_NOGRAVITY
		w.momx = P_RandomRange(-3, 3)*w.scale
		w.momy = P_RandomRange(-3, 3)*w.scale
		w.momz = P_RandomRange(1, 4)*w.scale*P_MobjFlip(w)

		if w.eflags & MFE_VERTICALFLIP
			s.eflags = $ | MFE_VERTICALFLIP
		end
	end
end

-- have the wings follow us
local function AP_updateWings(p, g)
	local mo = p.mo
	if not mo.ap_wings or not #mo.ap_wings return end	-- no wings to update, we're good to go

	local ang = p.drawangle + mo.ap_wingangle	-- arbitrary angle
	local dist = 10

	local wingremoval

	for i = 1, 2 do
		local w = mo.ap_wings[i]
		if not w or not w.valid continue end

		-- get correct xy position:
		local x = mo.x + FixedMul(mo.scale, dist*cos(ang))
		local y = mo.y + FixedMul(mo.scale, dist*sin(ang))

		-- get correct z position: use P_SpawnMobjFromMobj for a hack:
		local dum = P_SpawnMobjFromMobj(mo, 0, 0, mo.ap_wingz*FRACUNIT, MT_KANADEWING)
		local z = dum.z
		if dum and dum.valid
			P_RemoveMobj(dum)	-- bye
		end

		P_TeleportMove(w, x, y, z)
		w.angle = ang
		w.scale = mo.scale

		if mo.flags2 & MF2_DONTDRAW
			w.flags2 = $|MF2_DONTDRAW
		else
			w.flags2 = $ & ~MF2_DONTDRAW
		end	-- match flashtics

		if mo.eflags & MFE_VERTICALFLIP
			w.eflags = $|MFE_VERTICALFLIP
		else
			w.flags = $ & ~MFE_VERTICALFLIP
		end	-- match mobjflip

		if g
			AP_wingSpawnEffect(w, i==1)
		end

		if w.fuse
			local translevel = 10 - w.fuse
			w.frame = ($ & ~FF_TRANSMASK) | (translevel << FF_TRANSSHIFT)

			if w.fuse == 1
				wingremoval = true
			end
		end

		ang = p.drawangle - mo.ap_wingangle	-- ready angle for 2nd wing
	end

	if wingremoval	-- fuse has expired
		for i = 1, 2
			P_RemoveMobj(mo.ap_wings[i])
		end
		mo.ap_wings = nil	-- remove wings & kill the table
	end
end

rawset(_G, "AP_spawnWings", function(p, ang, z)
	local mo = p.mo
	if mo.ap_wings and #mo.ap_wings
		mo.ap_wingangle = ang or ANG1*100
		mo.ap_wingz = z or 60	-- update this nevertheless
		return
	end	-- wings already spawned, do set the angle however

	mo.ap_wings = {}
	for i = 1, 2

		local w = P_SpawnMobj(0,0,0, MT_KANADEWING)
		w.target = mo
		w.color = mo.color
		mo.ap_wings[i] = w
	end
	mo.ap_wingangle = ang or ANG1*100	-- allow setting custom angle.
	mo.ap_wingz = z or 60

	AP_updateWings(p, true)	-- directly teleport the wings to their correct position!
end)

-- sets a frame for both wings
rawset(_G, "AP_setWingFrame", function(p, f)
	local mo = p.mo
	if not mo.ap_wings or not #mo.ap_wings return end	-- no wings to update, we're good to go

	for i = 1, 2 do
		local w = mo.ap_wings[i]
		if not w or not w.valid continue end
		w.frame = f|FF_PAPERSPRITE
		if w.fuse		-- if we set the frame of the wings, undo the fuse
			w.fuse = 0
			AP_wingSpawnEffect(w, i==1)	-- as if they had just respawned, it's fancier like this!~
		end
	end
end)

-- prepare wing despawning
rawset(_G, "AP_despawnWings", function(p, force)
	local mo = p.mo
	if not mo.ap_wings or not #mo.ap_wings return end	-- no wings to update, we're good to go

	for i = 1, 2 do
		if not mo.ap_wings[i] or not mo.ap_wings[i].valid
			continue
		end
		if mo.ap_wings[i].fuse continue end	-- already applied.
		mo.ap_wings[i].fuse = force or 10
	end
end)

local function AP_wresetStats(p)
	if not p.ap_savestats or not #p.ap_savestats return end

	p.normalspeed = p.ap_savestats[1] or skins[p.realmo.skin].normalspeed	-- in case of 0
	p.thrustfactor = p.ap_savestats[2] or skins[p.realmo.skin].thrustfactor
	p.jumpfactor = p.ap_savestats[3] or skins[p.realmo.skin].jumpfactor
	p.ap_savestats = nil
end

-- Make sure to reset everything on mapload:
addHook("MapLoad", do
	for p in players.iterate do
		AP_wresetStats(p)
	end
end)

-- Angel Wings handler:
rawset(_G, "AP_angelWings", function(p)
	local mo = p.mo

	AP_updateWings(p)	-- Update the wing positions

	if p.charability2 == CA2_HANDSONIC	-- special case to show wings during handsonic!
		-- either while diving or while using overdrive's dash
		if (mo.ap_handstate == HS_DIVE or mo.ap_handstate == HS_DASH and mo.ap_overdrive)

			mo.ap_wingstate = WS_NONE
			AP_spawnWings(p, ANG1*155, 40)	-- will set angle & zheight if wings are already spawned
			AP_setWingFrame(p, leveltime & 1)
			AP_updateWings(p)	-- Update the wing positions

			for i = 1, 2
				local w = mo.ap_wings[i]
				if not w or not w.valid continue end	--?
				--AP_advanceGhost(w)
				local g = P_SpawnGhostMobj(w)
				g.tics = 4
				g.colorized = true
			end
			return	-- don't let the rest of the script cancel the wings yet
		end
	end

	if mo.ap_wingstate and mo.ap_wingstate > WS_PREP
	and (P_IsObjectOnGround(mo) or not (p.pflags & PF_JUMPED))
	or p.powers[pw_carry]
		if p.ap_savestats
			AP_wresetStats(p)
		end
		mo.ap_wingstate = WS_NONE
		AP_despawnWings(p)
	end

	if not mo.ap_wingstate	-- wtf!
		if p.ap_savestats
			AP_wresetStats(p)
		end
		AP_despawnWings(p)
	end

	if mo.ap_wingstate == WS_PREP
		mo.momz = mo.ap_savemomz
		mo.state = S_PLAY_MIDFALL	-- kinda sus but we'll do with it lol
		AP_spawnWings(p)

		if not mo.ap_wingtimer		-- put here in case we somehow get set in this state without a timer set??
			AP_wresetStats(p)
			mo.ap_wingstate = WS_UP

			-- propel yourself:
			local waterfact = mo.eflags & MFE_UNDERWATER and 2 or 1
			P_SetObjectMomZ(mo, 10*FRACUNIT / waterfact)
			mo.state = S_PLAY_SPRING
			mo.ap_wingtimer = TICRATE/2

			local z = AP_wingDust(mo, 32)

			/*if z ~= nil		-- check if it spawned
				local updraft = P_SpawnMobj(mo.x, mo.y, z, MT_KANADEUPDRAFT)
				updraft.target = mo
				updraft.eflags = mo.eflags & (MFE_UNDERWATER|MFE_VERTICALFLIP)
				updraft.fuse = TICRATE*5/2
			end*/
		end

		if mo.ap_wingtimer < 4
			if mo.ap_wingtimer == 3
				S_StartSound(mo, sfx_beflap)	-- flap wings!
			end
			AP_setWingFrame(p, C)
		else
			AP_setWingFrame(p, A)
		end

		mo.ap_wingtimer = $-1

	elseif mo.ap_wingstate == WS_UP

		AP_setWingFrame(p, D)
		-- visual effect for damage box when using Angel Wings
		if mo.ap_wingtimer
			local g = P_SpawnGhostMobj(mo)
			g.tics = 4
			g.colorized = true

			if mo.ap_wings and #mo.ap_wings	-- little unclean but this will do:
				for i = 1, 2 do
					if mo.ap_wings[i] and mo.ap_wings[i].valid
						--AP_advanceGhost(mo.ap_wings[i])
						local g = P_SpawnGhostMobj(mo.ap_wings[i])
						g.tics = 4
						g.colorized = true
					end
				end
			end
			mo.ap_wingtimer = $-1
		end

		if P_MobjFlip(mo)*mo.momz <= mo.scale*4
			mo.ap_wingtimer = 0	-- instantly cancel if momentum gets too low somehow
			if not (p.cmd.buttons & BT_JUMP)	-- already holding for float
				AP_despawnWings(p)
			end
			-- also enable float state:
			mo.ap_wingstate = WS_FREEFALL
		end
	elseif mo.ap_wingstate == WS_FREEFALL


		-- enable float state:
		if p.cmd.buttons & BT_JUMP	-- holding jump

			-- in overdrive: Allow more upwards jumps to be performed so long as the button wasn't HELD:
			if mo.ap_overdrive
				if (mo.ap_wings and mo.ap_wings[1] and mo.ap_wings[1].valid and mo.ap_wings[1].fuse or not mo.ap_wings or not mo.ap_wings[1] or not mo.ap_wings[1].valid)	-- hacky check but functionnal
					mo.ap_wingstate = WS_PREP
					mo.ap_wingtimer = TICRATE/4

					if P_MobjFlip(mo)*mo.momz < 0
						mo.momz = $/2	-- divide downwards momentum
					end

					-- save some quick values:
					mo.ap_savemomz = mo.momz
					p.ap_savestats = {p.normalspeed, p.thrustfactor, p.jumpfactor}	-- AP_wresetStats
					p.pflags = $ & ~PF_STARTJUMP	-- kills the momentum cut thing when not holding jump
					return
				end
			end

			if mo.state == S_PLAY_FALL
				mo.state = S_PLAY_FLOATSTART
			else
				mo.state = S_PLAY_FLOAT
			end
			mo.ap_wingstate = WS_FLOAT
			AP_spawnWings(p)
			-- momentum cut handled below
		else
			AP_despawnWings(p)
		end
	end

	-- not elseif because we want this to run the same frame
	if mo.ap_wingstate == WS_FLOAT

		AP_setWingFrame(p, leveltime & 1)

		if leveltime % 5 == 0
			AP_wingDust(mo, 20)
		end

		if mo.state ~= S_PLAY_FLOAT or mo.state ~= S_PLAY_FLOATSTART
			mo.state = S_PLAY_FLOAT
		end

		local waterfact = mo.eflags & MFE_UNDERWATER and 2 or 1

		if mo.eflags & MFE_VERTICALFLIP
			mo.momz = min($, 4*mo.scale / waterfact)
		else
			mo.momz = max($, -4*mo.scale / waterfact)
		end

		if not (p.cmd.buttons & BT_JUMP)	-- let go off of jump
			mo.state = S_PLAY_FLOATEND
			mo.ap_wingstate = WS_FREEFALL	-- we can start floating again later
			AP_despawnWings(p)
		end
	end

	AP_updateWings(p)	-- Update the wing positions

end)

-- getting damaged/dying removes wings
local function AP_angelWingsDamage(mo)
	if not mo.player return end
	AP_despawnWings(mo.player, 2)
	mo.ap_wingstate = WS_NONE	-- cancel all wing stuff
	AP_wresetStats(mo.player)
end
addHook("MobjDamage", AP_angelWingsDamage, MT_PLAYER)
addHook("MobjDeath", AP_angelWingsDamage, MT_PLAYER)


-- Touching a spring ends the ability:
local function AP_angelWingsSpringCollide(mo, spring)
	-- yes we need to check for z height lmfao...

	if not (spring.flags & MF_SPRING) return end

	if mo.z + mo.height >= spring.z
	and mo.z <= spring.z + spring.height

		if mo and mo.ap_wingstate

			AP_despawnWings(mo.player, 2)
			mo.ap_wingstate = WS_NONE
		end
	end
end

addHook("MobjCollide", AP_angelWingsSpringCollide, MT_PLAYER)
addHook("MobjMoveCollide", AP_angelWingsSpringCollide, MT_PLAYER)

DNG_Abilities["kanade"] = {
	func =		function(p)
					AP_midFallFrame(p)
					AP_angelWings(p)
				end,

	jfunc = 	function(p)
					local mo = p.mo
					if p.powers[pw_carry] or P_PlayerInPain(p) return end

					-- if not using the wings: prepare the ability
					if not mo.ap_wingstate
					and mo.health
						AP_spawnWings(p)			-- get our wings ready! :PoppoSeesAll:

						mo.ap_wingstate = WS_PREP	-- ready the wings
						mo.ap_wingtimer = TICRATE/4

						mo.momx = $/2
						mo.momy = $/2
						if P_MobjFlip(mo)*mo.momz < 0
							mo.momz = $/2	-- divide downwards momentum
						end

						-- save some quick values:
						mo.ap_savemomz = mo.momz
						p.ap_savestats = {p.normalspeed, p.thrustfactor, p.jumpfactor}	-- AP_wresetStats
						p.pflags = $ & ~PF_STARTJUMP	-- kills the momentum cut thing when not holding jump
					end
				end,

}
