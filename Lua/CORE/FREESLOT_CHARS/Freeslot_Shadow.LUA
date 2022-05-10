-- Shadow Specific freeslots to avoid clogging the main file

// To prevent duplicate freeslots
local function SafeFreeslot(...)
	for _, item in ipairs({...})
		if rawget(_G, item) == nil
			freeslot(item)
		end
	end
end

function A_SetPAnim(mo, var1, var2)
	if not mo.player return end
	mo.player.panim = var2
end

function A_ModifyPFlags(mo, var1, var2) // var1 flags are added, var2 flags are removed
	local player = mo.player
	if not player return end
	player.pflags = $ & ~var2 | var1
end

SafeFreeslot("SPR2_SHIT",
	"SPR2_WARP", "SPR2_POSE", "S_SHADOW_WARP1", "S_SHADOW_WARP2",
	"S_SHADOW_WARP_EXIT", "S_SHADOW_WARP_EXIT2",
	"SPR2_BATB", "S_SHADOW_CHAOSBURST", "SPR2_BATN", "S_SHADOW_CHAOSNIGHTMARE")

spr2defaults[SPR2_SHIT] = SPR2_PAIN
spr2defaults[SPR2_POSE] = SPR2_SPNG

states[S_SHADOW_WARP1] = {
	sprite = SPR_NULL,
	tics = 8,
	action = A_SetPAnim,
	var2 = PA_ABILITY,
	nextstate = S_SHADOW_WARP2
}

states[S_SHADOW_WARP2] = {
	sprite = SPR_PLAY,
	frame = SPR2_WARP | FF_SPR2ENDSTATE | FF_FULLBRIGHT,
	action = A_SetPAnim,
	tics = 1,
	nextstate = S_SHADOW_WARP2,
	var1 = S_SHADOW_WARP_EXIT,
	var2 = PA_ABILITY,
}

states[S_SHADOW_WARP_EXIT] = {
	sprite = SPR_PLAY,
	frame = SPR2_FIRE,
	tics = 5,
	action = A_SetPAnim,
	var2 = PA_FALL,
	nextstate = S_SHADOW_WARP_EXIT2,
}

states[S_SHADOW_WARP_EXIT2] = {
	sprite = SPR_PLAY,
	frame = SPR2_FIRE,
	tics = 0,
	action = A_ModifyPFlags,
	var2 = PF_NOJUMPDAMAGE,
	nextstate = S_PLAY_JUMP,
}

SafeFreeslot("SPR2_SNAP", "S_CHAOSSNAP")

states[S_CHAOSSNAP] = {
	sprite = SPR_PLAY,
	frame = SPR2_SNAP | FF_SPR2ENDSTATE | FF_FULLBRIGHT,
	tics = 1,
	nextstate = S_CHAOSSNAP,
	var1 = S_NULL,
}

SafeFreeslot("MT_SHADOW_SKATEFLAME")

mobjinfo[MT_SHADOW_SKATEFLAME] = {
	spawnstate = S_INVISIBLE,
	height = mobjinfo[MT_PLAYER].height,
	radius = mobjinfo[MT_PLAYER].radius,
	flags = MF_NOBLOCKMAP|MF_NOCLIP|MF_NOCLIPHEIGHT|MF_NOCLIPTHING|MF_NOGRAVITY|MF_SCENERY
}