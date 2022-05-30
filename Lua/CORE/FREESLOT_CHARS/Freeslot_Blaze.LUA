-- Blaze specific freeslots to avoid clogging the main file.

-- Blaze's stuff... Oh mama...
-- Original code credits go to Lach, Katsy & Frostiikin
-- Sorry for dropping all this here with no cleanliness!!

freeslot(
"SKINCOLOR_BLAZING",
"MT_BLAZETAIL",
"MT_SRB2P_BLAZETAIL",
"MT_BLAZE_RUNFIRE",
"S_BLAZERUNFIRE",
"MT_BLAZE_JUMPFIRE",
"S_BLAZEJUMPFIRE",
"SPR_BLZF",
"SPR_BLZH",
"SPR_BSPF",
"SPR_BFPT",
"SPR_BJFR",
"SPR_INAE",
"SPR_BBCR",
"SPR_BWNE",
"S_BLAZETAIL_STAND",
"S_BLAZETAIL_SPRING",
"S_BLAZETAIL_FALL",
"S_BLAZETAIL_RUN",
"S_BLAZETAIL_INVIS",
"SFX_CATRL",
"SFX_BLZBST",
"SFX_BLZBTR",
"SFX_SECIR",
"S_PLAY_BLAZE_HOVER",
"S_PLAY_BLAZE_SPINDASH",
"S_PLAY_BLAZE_SPIN",
"S_BPARTICLE",
"MT_BLAZE_SPINFIRE",
"S_BLAZESPINFIRE",
"MT_BLAZE_HOVERFIRE",
"S_BLAZEHOVERFIRE",
"MT_BLAZEJUMPFLAME",
"S_BLAZEJUMPFLAME",
"MT_BLAZE_FLING",
"MT_BLAZE_DEADFLING",
"SPR_SEM1",
"SPR_SEM2",
"SPR_SEM3",
"SPR_SEM4",
"SPR_SEM5",
"SPR_SEM6",
"SPR_SEM7",
"SPR_BBFD",
"sfx_blzhvr"
)

-- STILL MY HEART IS BLAZING
skincolors[SKINCOLOR_BLAZING] = {
    name = "Blazing",
    ramp = {1,1,83,83,84,51,52,53,36,37,39,184,185,167,167,168},
    invcolor = SKINCOLOR_SAPPHIRE,
    invshade = 9,
    chatcolor = V_ORANGEMAP,
    accessible = true
}


local TWIRLSTATE = S_PLAY_ROLL

mobjinfo[MT_BLAZETAIL] = {
	doomednum = -1,
	spawnstate = S_NULL,
	flags = MF_NOCLIPHEIGHT,
	dispoffset = 2,
	radius = 5*FRACUNIT,
	height = 5*FRACUNIT
}

mobjinfo[MT_SRB2P_BLAZETAIL] = {
	doomednum = -1,
	spawnstate = S_INVISIBLE,
	flags = MF_NOCLIPHEIGHT|MF_NOGRAVITY|MF_NOCLIP,
	dispoffset = 2,
	radius = 5*FRACUNIT,
	height = 5*FRACUNIT
}

mobjinfo[MT_BLAZEJUMPFLAME] = {
	doomednum = -1,
	spawnstate = S_INVISIBLE,
	flags = MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT,
	radius = 5*FRACUNIT,
	height = 30*FRACUNIT,
	deathsound = sfx_ncspec
}
mobjinfo[MT_BLAZE_RUNFIRE] = {
	doomednum = -1,
	spawnstate = S_BLAZERUNFIRE,
	flags = MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT,
	radius = 5*FRACUNIT,
	height = 30*FRACUNIT,
	deathsound = sfx_ncspec
}
states[S_BLAZERUNFIRE] = {
	sprite = SPR_BLZF,
	frame = FF_FULLBRIGHT|FF_ANIMATE|TR_TRANS30,
	var1 = 5,
	var2 = 1
}
mobjinfo[MT_BLAZE_JUMPFIRE] = {
	doomednum = -1,
	spawnstate = S_BLAZEJUMPFIRE,
	flags = MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT,
	radius = 5*FRACUNIT,
	height = 30*FRACUNIT,
	deathsound = sfx_ncspec
}
states[S_BLAZEJUMPFIRE] = {
	sprite = SPR_BJFR,
	frame = FF_FULLBRIGHT|FF_ANIMATE|TR_TRANS40,
	var1 = 5,
	var2 = 2
}
states[S_BPARTICLE] = {
	sprite = SPR_BFPT,
	frame = FF_FULLBRIGHT|A|TR_TRANS30,
}
mobjinfo[MT_BLAZE_SPINFIRE] = {
	doomednum = -1,
	spawnstate = S_BLAZESPINFIRE,
	flags = MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT,
	radius = 1*FRACUNIT,
	height = 1*FRACUNIT,
	deathsound = sfx_ncspec
}
states[S_BLAZESPINFIRE] = {
	sprite = SPR_BSPF,
	frame = FF_FULLBRIGHT|FF_ANIMATE|FF_PAPERSPRITE|TR_TRANS30,
	var1 = 5,
	var2 = 1
}
mobjinfo[MT_BLAZE_HOVERFIRE] = {
	doomednum = 3445,
	spawnstate = S_BLAZEHOVERFIRE,
	flags = MF_NOGRAVITY|MF_NOCLIPHEIGHT,
	spawnhealth = 50,
	radius = 17*FRACUNIT,
	height = 34*FRACUNIT,
	deathsound = sfx_ncspec
}
mobjinfo[MT_BLAZE_FLING] = {
	doomednum = -1,
	spawnstate = S_PLAY_STND,
	flags = MF_NOCLIPHEIGHT,
	radius = 5*FRACUNIT,
	deathstate = S_XPLD1,
	height = 5*FRACUNIT
}
mobjinfo[MT_BLAZE_DEADFLING] = {
	doomednum = -1,
	spawnstate = S_PLAY_STND,
	flags = MF_NOCLIPHEIGHT,
	radius = 5*FRACUNIT,
	deathstate = S_NULL,
	height = 5*FRACUNIT
}
states[S_BLAZEHOVERFIRE] = {
	sprite = SPR_BLZH,
	frame = FF_FULLBRIGHT|FF_ANIMATE|TR_TRANS30,
	var1 = 5,
	var2 = 1
}

states[S_PLAY_BLAZE_HOVER] = {SPR_PLAY, SPR2_GLID|FF_ANIMATE, -1, nil, 0, 2, S_PLAY_STND}
states[S_BLAZETAIL_STAND] = {SPR_PLAY, SPR2_TAL0|FF_ANIMATE, -1, nil, 0, 4, S_BLAZETAIL_STAND}
states[S_BLAZETAIL_SPRING] = {SPR_PLAY, SPR2_TAL1, 2, nil, 0, 0, S_BLAZETAIL_SPRING}
states[S_BLAZETAIL_FALL] = {SPR_PLAY, SPR2_TAL2, 2, nil, 0, 2, S_BLAZETAIL_FALL}
states[S_BLAZETAIL_RUN] = {SPR_PLAY, SPR2_TAL3, 2, nil, 0, 2, S_BLAZETAIL_RUN}
states[S_BLAZETAIL_INVIS] = {SPR_PLAY, SPR2_TAL4|FF_ANIMATE, -1, nil, 0, 2, S_PLAY_STND}

--tail thinker

--by Lach
-- teleports the tail followmobj to be in front of Blaze's sprite for A5/A4A6 views, behind for all others
-- of course, because the camera moves after all mobj logic, there will sometimes be 1 frame of delay where it is layered incorrectly :(
-- (also Frostiikin is RUDE, followmobjs are absolute darlings and I will love and protect them)]

local TAIL_DIST = -3*FRACUNIT

local invertsLUT = { // fill out an entry here to invert whether the tail displays in front or behind Blaze
	{ // WALKA4
		sprite2 = SPR2_WALK,
		frame = A,
		rotation = 4
	},
	{ // WALKF4
		sprite2 = SPR2_WALK,
		frame = F,
		rotation = 4
	},
	{ // WALKG4
		sprite2 = SPR2_WALK,
		frame = G,
		rotation = 4
	},
	{ // WALKH4
		sprite2 = SPR2_WALK,
		frame = H,
		rotation = 4
	},
	{ // WALKE6
		sprite2 = SPR2_WALK,
		frame = E,
		rotation = 6
	},
	{ // WALKB6
		sprite2 = SPR2_WALK,
		frame = B,
		rotation = 6
	},
	{ // WALKC6
		sprite2 = SPR2_WALK,
		frame = C,
		rotation = 6
	},
	{ // WALKD6
		sprite2 = SPR2_WALK,
		frame = D,
		rotation = 6
	},
	{ // RUN_C4
		sprite2 = SPR2_RUN,
		frame = C,
		rotation = 4
	},
	{ // RUN_D4
		sprite2 = SPR2_RUN,
		frame = D,
		rotation = 4
	},
	{ // RUN_A6
		sprite2 = SPR2_RUN,
		frame = A,
		rotation = 6
	},
	{ // RUN_B6
		sprite2 = SPR2_RUN,
		frame = B,
		rotation = 6
	},
	{ // RIDEA4
		sprite2 = SPR2_RIDE,
		frame = A,
		rotation = 4
	},
	{ // RIDEA6
		sprite2 = SPR2_RIDE,
		frame = A,
		rotation = 6
	}
}

local function MakeBitfield(sprite2, frame, rotation)
	return (sprite2) | (frame << 8) | (rotation << 16)
end

-- convert the inverts table into an actual look-up table
invertsLUT = (function()
	local result = {}
	for i, entry in ipairs(invertsLUT)
		result[MakeBitfield(entry.sprite2, entry.frame, entry.rotation)] = true
	end
	return result
end)()

-- the main tail mover! called from somewhere in Frostiikin's script
rawset(_G, "Blaze_MoveTail", function(mo, tail)
	--local mo = player.mo
	local scale = mo.scale
	local dist = FixedMul(TAIL_DIST, scale)
	local playerAngle 	--= player.drawangle

	local bx = mo.x
	local by = mo.y
	local bz = mo.z

	if mo.player
		playerAngle = mo.player.drawangle
	else
		playerAngle = mo.angle
		dist = $*5/2
	end

	local z = mo.z

	tail.angle = playerAngle

	// reverse gravity
	if mo.eflags & MFE_VERTICALFLIP
		z = $ + mo.height - tail.height
	end

	// sprite offsets
	local sprite2 = mo.sprite2 & ~FF_SPR2SUPER
	local frame = mo.frame & FF_FRAMEMASK
	local unit = scale * P_MobjFlip(mo)
	if sprite2 == SPR2_WALK
		if frame & 1
			z = $ + 2*unit
		elseif (frame/2) & 1
			z = $ + 3*unit
		end
	elseif sprite2 == SPR2_RUN
		if mo.sprite2 & FF_SPR2SUPER
			z = $ - 8*unit
		elseif not (frame & 1)
			z = $ - unit
		end
	elseif sprite2 == SPR2_RIDE
		z = $ - 2*unit
	elseif sprite2 == SPR2_EDGE
		z = $ - 3*unit
	elseif sprite2 == SPR2_SKID
		z = $ - unit
		if not (frame & 1)
			z = $ - unit
		end
	end

	local xpos = bx + FixedMul(dist, cos(playerAngle))
	local ypos = by + FixedMul(dist, sin(playerAngle))
	local zpos = bz

	if not mo.player
		xpos = $ + mo.momx
		ypos = $ + mo.momy
		zpos = $ + mo.momz	-- delayed
	end

	P_TeleportMove(tail, xpos, ypos, zpos)
end)

--Blaze's Tail
--Fuck followmobjs btw, they are dumb and bad
local standframe = {
  [SPR2_STND] = true,
  [SPR2_WALK] = true,
  [SPR2_WAIT] = true,
  [SPR2_SKID] = true,
  [SPR2_RIDE] = true,
}
local runframe = {
  [SPR2_RUN_] = true,
  [SPR2_GLID] = true,
  [SPR2_TWIN] = true,
  [SPR2_EDGE] = true,
}
local fallframe = {
  [SPR2_FALL] = true,
  [SPR2_SPIN] = true
}
local springframe = {
  [SPR2_SPNG] = true,
  [SPR2_GASP] = true
}

local rollframe = {
	[SPR2_ROLL] = true
}

local function blaze_followmobj(mo, mobj)
	if not (mo and mo.valid and mo.health and mo.skin == "blaze") return end

	local bot
	if not mo.player bot = true end

	local sprite2 = mo.sprite2 & ~FF_SPR2SUPER
	mobj.skin = "blaze"
	if mo.flags2 & MF2_OBJECTFLIP
		mobj.flags2 = $ | MF2_OBJECTFLIP
	else
		mobj.flags2 = $ & ~ MF2_OBJECTFLIP
	end
	if (sprite2 == SPR2_ROLL)

		local x = mo.x
		local y = mo.y
		local z = mo.z

		-- bot thinker is delayed...
		if bot
			x = $ + mo.momx
			y = $ + mo.momy
			z = $ + mo.momz
		end

		if P_MobjFlip(mo) == 1
			P_TeleportMove(mobj, x, y, z)
		else
			P_TeleportMove(mobj, x, y, z+mo.height-mobj.height)
		end
	else
		Blaze_MoveTail(mo, mobj)
	end

	if not bot
		mobj.flags2 = $|MF2_LINKDRAW
	end

	mobj.color = mo.color

	if standframe[sprite2]
		if mobj.state != S_BLAZETAIL_STAND
		or mobj.sprite2 == SPR2_FIRE
			mobj.state = S_BLAZETAIL_STAND
		end
	elseif runframe[sprite2]
		if mobj.state != S_BLAZETAIL_RUN
		or mobj.sprite2 == SPR2_FIRE
			mobj.state = S_BLAZETAIL_RUN
		end
	elseif fallframe[sprite2]
		if mobj.state != S_BLAZETAIL_FALL
		or mobj.sprite2 == SPR2_FIRE
			mobj.state = S_BLAZETAIL_FALL
		end
	elseif springframe[sprite2]
		if mobj.state != S_BLAZETAIL_SPRING
		or mobj.sprite2 == SPR2_FIRE
			mobj.state = S_BLAZETAIL_SPRING
		end
	elseif rollframe[sprite2] --and not (p.powers[pw_underwater])
		if not bot and mobj.state != S_PLAY_ROLL
			mobj.state = S_PLAY_ROLL
		else
			mobj.state = S_BLAZETAIL_STAND
		end

		mobj.sprite2 = SPR2_FIRE
		mobj.frame = mo.frame
		mobj.flags2 = $&~MF2_LINKDRAW
		mobj.color = SKINCOLOR_BLAZING

	elseif mobj.state != S_BLAZETAIL_INVIS
		mobj.state = S_BLAZETAIL_INVIS
	end

	if (mo.flags2 & MF2_DONTDRAW)
		mobj.flags2 = $|MF2_DONTDRAW
	else
		mobj.flags2 = $&~MF2_DONTDRAW
	end

	if mobj.sprite2 == SPR2_STND
	--if mo.state == S_PLAY_JUMP or mo.state == TWIRLSTATE
		if sprite2 == SPR2_ROLL
			if mobj.anim_duration > 1
				mobj.anim_duration = 1
			end
		else
			if mobj.anim_duration > 4
				mobj.anim_duration = 4
			end
		end
	end
	mobj.spritexscale = mo.spritexscale
	mobj.spriteyscale = mo.spriteyscale
	mobj.rollangle = mo.rollangle
	mobj.scale = mo.scale

	// Lach: also copy render & frame flags
	mobj.frame = ($ & (FF_FRAMEMASK|FF_ANIMATE)) | (mo.frame & ~(FF_FRAMEMASK|FF_ANIMATE))
	if rollframe[sprite2]
		mobj.frame = $|FF_FULLBRIGHT
	end
	mobj.renderflags = mo.renderflags

	return true
end

rawset(_G, "spr2_doblazetail", function(mo)
	local pmo = mo.target
	if pmo.dodgedummy
		pmo = pmo.dodgedummy
	end

	return blaze_followmobj(pmo, mo)
end)

addHook("FollowMobj", function(p, mobj)
	return blaze_followmobj(p.mo, mobj)
end, MT_BLAZETAIL)

--hover fire thinker
addHook("MobjThinker", function(mo)
	if mo and mo.valid and mo.health and mo.target and mo.target.health and mo.target.valid
		if mo.target.flags2 & MF2_OBJECTFLIP
			mo.flags2 = $ | MF2_OBJECTFLIP
			mo.eflags = $ | MFE_VERTICALFLIP
		else
			mo.flags2 = $ & ~ MF2_OBJECTFLIP
			mo.eflags = $ & ~ MFE_VERTICALFLIP
		end
		mo.scale = mo.target.scale

		local fuckunit = mo.scale
		local dist = 19
		local apart = 8
		local zheight = 4
		if not (mo.flags2 & MF2_OBJECTFLIP)
			if mo.flame1
				P_TeleportMove(mo, mo.target.x+P_ReturnThrustX(mo, mo.target.player.drawangle+FixedAngle(180*FRACUNIT), dist*fuckunit)+
				P_ReturnThrustX(mo, mo.target.player.drawangle+FixedAngle(-90*FRACUNIT), apart*fuckunit),
				mo.target.y+P_ReturnThrustY(mo, mo.target.player.drawangle+FixedAngle(180*FRACUNIT), dist*fuckunit)+
				P_ReturnThrustY(mo, mo.target.player.drawangle+FixedAngle(-90*FRACUNIT), apart*fuckunit),
				mo.target.z-zheight*fuckunit)
			elseif mo.flame2
				P_TeleportMove(mo, mo.target.x+P_ReturnThrustX(mo, mo.target.player.drawangle+FixedAngle(180*FRACUNIT), dist*fuckunit)+
				P_ReturnThrustX(mo, mo.target.player.drawangle+FixedAngle(90*FRACUNIT), apart*fuckunit),
				mo.target.y+P_ReturnThrustY(mo, mo.target.player.drawangle+FixedAngle(180*FRACUNIT), dist*fuckunit)+
				P_ReturnThrustY(mo, mo.target.player.drawangle+FixedAngle(90*FRACUNIT), apart*fuckunit),
				mo.target.z-zheight*fuckunit)
			end
		else--eaeaeaea
			if mo.flame1
				P_TeleportMove(mo, mo.target.x+P_ReturnThrustX(mo, mo.target.player.drawangle+FixedAngle(180*FRACUNIT), dist*fuckunit)+
				P_ReturnThrustX(mo, mo.target.player.drawangle+FixedAngle(-90*FRACUNIT), apart*fuckunit),
				mo.target.y+P_ReturnThrustY(mo, mo.target.player.drawangle+FixedAngle(180*FRACUNIT), dist*fuckunit)+
				P_ReturnThrustY(mo, mo.target.player.drawangle+FixedAngle(-90*FRACUNIT), apart*fuckunit),
				mo.target.z+zheight*fuckunit + mo.target.height - mo.height)
			elseif mo.flame2
				P_TeleportMove(mo, mo.target.x+P_ReturnThrustX(mo, mo.target.player.drawangle+FixedAngle(180*FRACUNIT), dist*fuckunit)+
				P_ReturnThrustX(mo, mo.target.player.drawangle+FixedAngle(90*FRACUNIT), apart*fuckunit),
				mo.target.y+P_ReturnThrustY(mo, mo.target.player.drawangle+FixedAngle(180*FRACUNIT), dist*fuckunit)+
				P_ReturnThrustY(mo, mo.target.player.drawangle+FixedAngle(90*FRACUNIT), apart*fuckunit),
				mo.target.z+zheight*fuckunit + mo.target.height - mo.height)
			end
		end

		if mo.invuln > 0
			mo.invuln = $ - 1
		end

		if mo.invuln == 0 and mo.frame & FF_FRAMEMASK == A
			mo.frame = B | ($ & ~FF_FRAMEMASK)
		end

		if mo.target.eflags & MFE_UNDERWATER
			local fuk = P_SpawnMobjFromMobj(mo, 0, 0, 0, MT_PARTICLE)
			fuk.tics = 35
			fuk.scale = 1
			fuk.destscale = mo.scale*5
			fuk.scalespeed = mo.scale/12
			fuk.fuse = 18
			fuk.momz = FixedMul(mo.target.scale, 2*FRACUNIT)
			P_RemoveMobj(mo)
		end

		if mo and mo.valid and not (mo.target.p_abl)
			P_RemoveMobj(mo)
		end

		if mo and mo.valid and P_PlayerInPain(mo.target.player)
			P_RemoveMobj(mo)
		end
	else
		P_RemoveMobj(mo)
	end
end, MT_BLAZE_HOVERFIRE)