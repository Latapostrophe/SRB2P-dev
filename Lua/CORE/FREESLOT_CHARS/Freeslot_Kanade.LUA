-- Kanade freeslots to avoid clogging the main file

-- Angel
freeslot("sfx_wngapr")

-- some states for visual effects:
freeslot("SPR_WSRK")
for i = 1, 5
	freeslot("S_WINGSPARK"..i)
end

for i = 0, 4
	states[S_WINGSPARK1+i] = {SPR_WSRK, i|FF_FULLBRIGHT, 4, nil, 0, 0, i < 4 and S_WINGSPARK1+(i+1) or S_NULL}
end

/*
	WINGS OBJECT
*/
freeslot("MT_KANADEWING", "S_KANADEWING", "SPR_KWNG")
mobjinfo[MT_KANADEWING] = {

	doomnednum = -1,
	spawnstate = S_KANADEWING,
	spawnhealth = 1000,
	radius = 48<<FRACBITS,
	height = 48<<FRACBITS,
	flags = MF_NOCLIP|MF_NOCLIPHEIGHT|MF_NOGRAVITY
}
states[S_KANADEWING] = {SPR_KWNG, FF_PAPERSPRITE, -1, nil, 0, 0, S_KANADEWING}


-- Mid-Fall frame: mostly to smoothen hair from spring to fall
-- spr2 for spring midfall
freeslot("SPR2_MFAL", "S_PLAY_MIDFALL")
spr2defaults[SPR2_MFAL] = SPR2_FALL

states[S_PLAY_MIDFALL] = {SPR_PLAY, SPR2_MFAL, 4, nil, 0, 0, S_PLAY_MIDFALL}

-- spr2 for float start / end
freeslot("SPR2_FLTE", "S_PLAY_FLOATEND", "SPR2_FLTS", "S_PLAY_FLOATSTART")
spr2defaults[SPR2_FLTE] = SPR2_MFAL
spr2defaults[SPR2_FLTS] = SPR2_FLTE

states[S_PLAY_FLOATSTART] = {SPR_PLAY, SPR2_FLTS, 4, nil, 0, 0, S_PLAY_FLOAT}
states[S_PLAY_FLOATEND] = {SPR_PLAY, SPR2_FLTE, 4, nil, 0, 0, S_PLAY_FLOATEND}

-- spr2 for guard frame
freeslot("SPR2_GARD", "S_PLAY_GUARD")
states[S_PLAY_GUARD] = {SPR_PLAY, SPR2_GARD, 2, nil, 0, 0, S_PLAY_GUARD}

-- spr2 for hand sonic
freeslot("SPR2_HWLP", "SPR2_HOWL", "S_PLAY_HOWLING_PREP1", "S_PLAY_HOWLING_PREP2", "S_PLAY_HOWLING")
states[S_PLAY_HOWLING_PREP1] = {SPR_PLAY, SPR2_GARD, 10, nil, 0, 0, S_PLAY_HOWLING_PREP2}
states[S_PLAY_HOWLING_PREP2] = {SPR_PLAY, SPR2_HWLP, TICRATE, nil, 0, 0, S_PLAY_HOWLING}

states[S_PLAY_HOWLING] = {SPR_PLAY, SPR2_HOWL, 2, nil, 0, 0, S_PLAY_HOWLING}

-- Hand Sonic (uses SPR2_MLEE)
freeslot("S_PLAY_HANDSONIC")
states[S_PLAY_HANDSONIC] = {SPR_PLAY, SPR2_MLEE, 4, nil, 0, 0, S_PLAY_HANDSONIC}

for i = 1, 3
	freeslot("S_SLASHING_1_"..i)
end
states[S_SLASHING_1_1] = {SPR_SLSH, A|FF_FULLBRIGHT, 2, nil, 0, 0, S_SLASHING_1_2}
states[S_SLASHING_1_2] = {SPR_SLSH, B|FF_FULLBRIGHT, 2, nil, 0, 0, S_SLASHING_1_3}
states[S_SLASHING_1_3] = {SPR_SLSH, C|FF_FULLBRIGHT, 2, nil, 0, 0, S_NULL}

for i = 1, 4
	freeslot("S_SLASHING_2_"..i)
end
states[S_SLASHING_2_1] = {SPR_SLSH, D|FF_FULLBRIGHT, 2, nil, 0, 0, S_SLASHING_2_2}
states[S_SLASHING_2_2] = {SPR_SLSH, E|FF_FULLBRIGHT, 2, nil, 0, 0, S_SLASHING_2_3}
states[S_SLASHING_2_3] = {SPR_SLSH, F|FF_FULLBRIGHT, 2, nil, 0, 0, S_SLASHING_2_4}
states[S_SLASHING_2_4] = {SPR_SLSH, G|FF_FULLBRIGHT, 2, nil, 0, 0, S_NULL}

for i = 1, 4
	freeslot("S_STAB_1_"..i)
end

function A_StabEnd(a)
	if not a or not a.valid return end

	local mo = P_SpawnMobj(a.x, a.y, a.z, MT_THOK)
	mo.tics = TICRATE/4
	mo.color = a.color
	mo.scale = a.scale/8
	mo.destscale = a.scale*4
	mo.scalespeed = a.scale/4
	mo.sprite = SPR_STAB
	mo.frame = A|FF_FULLBRIGHT

	mo = P_SpawnMobj(a.x, a.y, a.z, MT_THOK)
	mo.tics = TICRATE/2
	mo.fuse = mo.tics
	mo.color = a.color
	mo.scale = a.scale/8
	mo.destscale = a.scale*4
	mo.scalespeed = a.scale/6
	mo.sprite = SPR_STAB
	mo.frame = A|FF_FULLBRIGHT
end

states[S_STAB_1_1] = {SPR_STAB, B|FF_FULLBRIGHT, 2, nil, 0, 0, S_STAB_1_2}
states[S_STAB_1_2] = {SPR_STAB, C|FF_FULLBRIGHT, 2, nil, 0, 0, S_STAB_1_3}
states[S_STAB_1_3] = {SPR_STAB, D|FF_FULLBRIGHT, 2, nil, 0, 0, S_STAB_1_4}
states[S_STAB_1_4] = {SPR_NULL, A|FF_FULLBRIGHT, 1, A_StabEnd, 0, 0, S_NULL}