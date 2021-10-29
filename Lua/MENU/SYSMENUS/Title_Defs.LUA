-- definition for title screen stuff

-- OBJECTS:
freeslot("MT_TITLECHAR", "S_TITLECHAR", "SPR_TTCH")

mobjinfo[MT_TITLECHAR] = {
	doomednum = 3000,
	spawnhealth = 1000,
	spawnstate = S_TITLECHAR,
	flags = MF_RUNSPAWNFUNC,
	radius = 16*FRACUNIT,
	height = 1*FRACUNIT,
}

function A_TTLscreenchar(mo)
	-- if skin isn't unlocked, remove object
	-- @TODO ^

	mo.frame = mo.spawnpoint.angle |FF_FULLBRIGHT
	mo.scale = FRACUNIT*2/3
end
states[S_TITLECHAR] = {SPR_TTCH, A, 1, A_TTLscreenchar, 0, 0, S_TITLECHAR}