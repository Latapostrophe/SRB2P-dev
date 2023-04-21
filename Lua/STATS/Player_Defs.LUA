
-- Generate EXP table:
local basexp = 25
local totalxp = basexp
rawset(_G, "needEXP", {})

for i = 1, 100
	needEXP[i] = totalxp
	--print("Lv: "..i..":"..needEXP[i])
	totalxp = ($1 + (basexp*i)*38/100)
end

-- voice stuff:
local vfx_const = {
	"VFX_SUMMON",		-- summoning persona skill list
	"VFX_SKILL",		-- using skill
	"VFX_ITEM",			-- using item
	"VFX_HURT",			-- taking damage
	"VFX_HURTX",		-- heavy damage (>= 50% of total hp)
	"VFX_DIE",			-- fatal damage
	"VFX_HEAL",			-- healed by someone else
	"VFX_HEALSELF",		-- self healed
	"VFX_KILL",			-- enemy killed
	"VFX_1MORE",		-- 1more!
	"VFX_CRIT",			-- cutin: generally used for persona callout
	"VFX_AOAASK",		-- aoa init
	"VFX_AOADO",		-- aoa do
	"VFX_AOARELENT",	-- aoa relent
	"VFX_MISS",			-- missed
	"VFX_DODGE",		-- dodged
	"VFX_WIN",			-- battle won
	"VFX_LEVELUP",		-- level up

	-- Tartarus specific stuff
	"VFX_TARTARUS_PIT",			-- pit
	"VFX_TARTARUS_ITEM",		-- item
	"VFX_TARTARUS_SPRING",		-- found spring
	"VFX_TARTARUS_SPIKE",		-- Spiked
	"VFX_TARTARUS_CRITSPIKE",	-- REALLY spiked
	"VFX_TARTARUS_ENCOUNTER",	-- Neutral Advantage
	"VFX_TARTARUS_ADVANTAGE",	-- Player Advantage
	"VFX_TARTARUS_AMBUSHED",	-- Enemy Advantage 
	"VFX_TARTARUS_SPIKEPIT",	-- pit with spikes
}

for i = 1, #vfx_const
	rawset(_G, vfx_const[i], i)
end

local vfx_const_2_t = {
	[VFX_SUMMON] = "vfx_summon",
	[VFX_SKILL] = "vfx_skill",
	[VFX_ITEM] = "vfx_item",
	[VFX_HURT] = "vfx_hurt",
	[VFX_HURTX] = "vfx_hurtx",
	[VFX_DIE] = "vfx_die",
	[VFX_HEAL] = "vfx_heal",
	[VFX_HEALSELF] = "vfx_healself",
	[VFX_KILL] = "vfx_kill",
	[VFX_1MORE] = "vfx_1more",
	[VFX_CRIT] = "vfx_crit",
	[VFX_AOAASK] = "vfx_aoaask",
	[VFX_AOADO] = "vfx_aoado",
	[VFX_AOARELENT] = "vfx_aoarelent",
	[VFX_MISS] = "vfx_miss",
	[VFX_DODGE] = "vfx_dodge",
	[VFX_WIN] = "vfx_win",
	[VFX_LEVELUP] = "vfx_levelup",

	[VFX_TARTARUS_PIT] = "vfx_tartarus_pit",
	[VFX_TARTARUS_ITEM] = "vfx_tartarus_item",
	[VFX_TARTARUS_SPRING] = "vfx_tartarus_spring",
	[VFX_TARTARUS_SPIKE] = "vfx_tartarus_spike",
	[VFX_TARTARUS_CRITSPIKE] = "vfx_tartarus_critspike",
	[VFX_TARTARUS_ENCOUNTER] = "vfx_tartarus_encounter",
	[VFX_TARTARUS_ADVANTAGE] = "vfx_tartarus_advantage",
	[VFX_TARTARUS_AMBUSHED] = "vfx_tartarus_ambushed",
	[VFX_TARTARUS_SPIKEPIT] = "vfx_tartarus_spikepit",
}

-- big dick privileges: these specific VFX_ don't care about the timer when used
local bigdickprivileges = {
	[VFX_HURTX] = true,
	[VFX_AOADO] = true,
	[VFX_DIE] = true,
	[VFX_TARTARUS_PIT] = true,
	[VFX_TARTARUS_SPIKE] = true,
	[VFX_TARTARUS_CRITSPIKE] = true,
	[VFX_TARTARUS_ENCOUNTER] = true,
	[VFX_TARTARUS_ADVANTAGE] = true,
	[VFX_TARTARUS_AMBUSHED] = true,
}

-- VFX_freeslotC: freeslots all the fields above for a character stat
rawset(_G, "VFX_freeslotC", function(s)
	local stats = charStats[s]
	if not stats
		dprint("VFX_freeslotC: No stats for \'"..tostring(s).."\'.")
		return
	end

	for k,v in pairs(stats)
		-- is this a constant?
		for i = 1, #vfx_const_2_t
			if vfx_const_2_t[i] == k	-- match!

				print("Auto freeslotting sounds in table \'"..k.."\'")
				for j = 1, #v do
					if v[j] and not _G[v[j]]
						freeslot(v[j])
					end
				end

				break
			end
		end
	end
end)

-- VFX_freeslotE: freeslots all the fields above for an enemy stat
rawset(_G, "VFX_freeslotE", function(s)
	local stats = enemyList[s]
	if not stats
		dprint("VFX_freeslotE: No stats for \'"..tostring(s).."\'.")
		return
	end

	for k,v in pairs(stats)
		-- is this a constant?
		for i = 1, #vfx_const_2_t
			if vfx_const_2_t[i] == k	-- match!

				print("Auto freeslotting sounds in table \'"..k.."\'")
				for j = 1, #v do
					if v[j] and not _G[v[j]]
						freeslot(v[j])
					end
				end

				break
			end
		end
	end
end)

-- cvar for voices:
rawset(_G, "cv_voices", CV_RegisterVar(
{
	name = "voices",
	defaultvalue = "Normal",
	flags = CV_SAVE,
	PossibleValue = {Off = 0, Normal = 1, Meme = 2},
}
)
)


-- THEY WILL NOT FUCKING SHUT UP HOLY SHIT
rawset(_G, "VFX_Play", function(mo, v, stats, p)
	if not mo
		dprint("VFX_Play: No \'mo\' field.")
		return
	elseif not mo.valid
		dprint("VFX_Play: ".."\x82".."WARNING:".."\x80".." \'mo\' field is invalid!")
		return
	elseif not v
		dprint("VFX_Play: No constant supplied")
		return
	end

	if not stats	-- if no stats are supplied, get the one from charstats / enemylist
		if mo.plyr and not mo.enemy
			stats = charStats[mo.stats]
		elseif mo.enemy
			stats = enemyList[mo.enemy]
		elseif mo.player	-- actually a real player, huh, just get stuff from their skin
			stats = charStats[mo.skin] and charStats[mo.skin] or charStats[mo.control.stats]
		end
	end

	local t = stats[vfx_const_2_t[v]]
	-- We need to fallback in certain cases, specifically anything related to tartarus specific vfx
	if v >= 19 and not t -- Make sure we are only doing this for tartarus specific vfx
		if v == VFX_TARTARUS_PIT
		or v == VFX_TARTARUS_SPIKEPIT
			t = stats[vfx_const_2_t[VFX_DIE]]
		elseif v == VFX_TARTARUS_SPIKE
			t = stats[vfx_const_2_t[VFX_HURT]]
		elseif v == VFX_TARTARUS_CRITSPIKE
			t = stats[vfx_const_2_t[VFX_HURTX]]
		--Do nothing for VFX_TARTARUS_ITEM
		--Do nothing for VFX_TARTARUS_SPRING
		--Do nothing for VFX_TARTARUS_ENCOUNTER
		--Do nothing for VFX_TARTARUS_ADVANTAGE
		--Do nothing for VFX_TARTARUS_AMBUSHED
		end
	end
	if not t or not #t return end	-- no table

	-- pick random sound
	local ind = P_RandomRange(1, #t)
	local s = t[ind]
	if not _G[s]
		local name = mo.player and mo.player.name or mo.skin and mo.skin or "WTF"
		dprint("VFX_Play: Invalid sound at index "..ind.." for "..name)
		return
	end

	-- don't play the voice if:
	-- cv_voice is off
	-- cv_voice is 1 and it's been less than a second since the last voice clip.

	mo.lastvoiceplayed = $ or -TICRATE

	if cv_voices.value == 0
	or cv_voices.value == 1 and (not bigdickprivileges[v] and leveltime - mo.lastvoiceplayed < TICRATE)
		return
	end

	mo.lastvoiceplayed = leveltime
	-- if p is specified, play for nil
	S_StartSoundAtVolume(not p and mo or nil, _G[s], 255, p)
	return true
end)


-- sonic phys attack spindash
freeslot("SPR_MRSP", "sfx_sncsd1", "sfx_sncsd2", "sfx_sncsd3")

-- character specific sprites / objects
-- shadow
freeslot("SPR_SHDW")


-- metal sonic
freeslot("SPR_MSOD", "sfx_msovd1")
for i = 1, 6
	freeslot("S_MSOVERDRIVE"..i)
end

states[S_MSOVERDRIVE1] = {SPR_MSOD, A|FF_FULLBRIGHT|TR_TRANS20, 2, nil, 0, 0, S_MSOVERDRIVE2}
states[S_MSOVERDRIVE2] = {SPR_MSOD, B|FF_FULLBRIGHT|TR_TRANS30, 2, nil, 0, 0, S_MSOVERDRIVE3}
states[S_MSOVERDRIVE3] = {SPR_MSOD, C|FF_FULLBRIGHT|TR_TRANS50, 2, nil, 0, 0, S_MSOVERDRIVE4}
states[S_MSOVERDRIVE4] = {SPR_MSOD, D|FF_FULLBRIGHT|TR_TRANS60, 2, nil, 0, 0, S_MSOVERDRIVE5}
states[S_MSOVERDRIVE5] = {SPR_MSOD, E|FF_FULLBRIGHT|TR_TRANS70, 2, nil, 0, 0, S_MSOVERDRIVE6}
states[S_MSOVERDRIVE6] = {SPR_MSOD, F|FF_FULLBRIGHT|TR_TRANS80, 2, nil, 0, 0, S_NULL}

rawset(_G, "spr2_dotails", function(mo)
	if not mo or not mo.valid return end

	local target = mo.target
	if not target or not target.valid
		P_RemoveMobj(mo)
	return end

	if target and target.dodgedummy and target.dodgedummy.valid
		target = target.dodgedummy
	end


	local onground = P_IsObjectOnGround(target)
	local angle = target.angle
	local zoffs = 0
	local backwards = -1*FRACUNIT
	local roll = target.anim == target.anim_atk or target.anim == target.anim_aoa_end or target.anim == target.anim_getup
	local rollangle
	local animchange
	local ticnum = 0
	local chosenstate = S_SRB2P_TAILSDUM

	if target.flags2 & MF2_DONTDRAW
	or target.anim == target.anim_evoker
	or target.anim == target.anim_evoker_shoot
	or target.state == S_INVISIBLE
	or not target.hp
		mo.flags2 = $|MF2_DONTDRAW
	else
		mo.flags2 = $ & ~MF2_DONTDRAW
	end

	local speed = R_PointToDist2(0, 0, target.momx, target.momy)

	if not mo.skin
		mo.skin = target.skin
		mo.state = S_SRB2P_TAILSDUM
		mo.anim = target.anim_stand
		-- ^ does not actually get used, we just compare pointers
	end

	animchange = (mo.anim ~= target.anim)

	if roll
		local testval, zdist
		if speed < FRACUNIT
			testval = FRACUNIT
		else
			testval = FixedMul(speed, sin(angle - R_PointToAngle2(0, 0, target.momx, target.momy)))
			testval = max($, FRACUNIT)
		end

		zdist = mo.momz
		rollangle = R_PointToAngle2(0, 0, testval, -P_MobjFlip(target)*zdist)

		zoffs = 3*FRACUNIT + 12*sin(rollangle)
		backwards = -12*cos(rollangle)

	elseif target.anim == target.anim_run
		backwards = -5*FRACUNIT
		chosenstate = S_TAILSOVERLAY_RUN

	elseif target.anim == target.anim_hurt
	or target.anim == target.anim_getdown
	or target.anim == target.anim_downloop
		backwards = $/16
		chosenstate = S_TAILSOVERLAY_PAIN
		ticnum = 2

	elseif target.anim == target.anim_special1	-- fly
		--zoffs = -7*FRACUNIT
		backwards = -5	*FRACUNIT
		chosenstate = S_TAILSOVERLAY_FLY
		ticnum = 1
	end

	-- sprite
	if roll
		local add = rollangle > ANG1*180 and 2 or 0
		if add
			rollangle = InvAngle(rollangle)
		end

		rollangle = $+ANG15

		if rollangle > ANG60
			chosenstate = (S_TAILSOVERLAY_PLUS60DEGREES + add)
		elseif rollangle > ANG30
			chosenstate = (S_TAILSOVERLAY_PLUS30DEGREES + add)
		else
			chosenstate = S_TAILSOVERLAY_0DEGREES
		end
	end

	if animchange
		mo.sprite2 = -1
		mo.state = chosenstate
	else
		if mo.state ~= chosenstate
			mo.state = chosenstate
			mo.sprite2 = states[mo.state].frame & FF_FRAMEMASK
		end
	end

	-- handling
	mo.color = target.color
	mo.threshold = target.z
	mo.anim = target.anim
	mo.angle = target.angle
	mo.scale = target.scale
	mo.destscale = target.destscale
	zoffs = FixedMul(zoffs, mo.scale)

	if ticnum and mo.tics > ticnum
		mo.tics = ticnum
	end

	if target.eflags & MFE_VERTICALFLIP
		mo.eflags = $|MFE_VERTICALFLIP
		mo.flags2 = $|MF2_OBJECTFLIP
		zoffs = -zoffs
	else
		mo.eflags = $ & ~MFE_VERTICALFLIP
		mo.flags2 = $ & ~MF2_OBJECTFLIP
	end

	local x = target.x + target.momx + FixedMul(target.scale, FixedMul(backwards, cos(angle)))
	local y = target.y + target.momy + FixedMul(target.scale, FixedMul(backwards, sin(angle)))
	local z = target.z + target.momz + zoffs
	P_TeleportMove(mo, x, y, z)


	-- this is actually despair, fuck it
	if chosenstate == S_SRB2P_TAILSDUM
		mo.sprite = SPR_PLAY
		mo.sprite2 = SPR2_TAL0
		mo.frame = (leveltime%30 / 5)
	end
end)

-- Some special SPR2 definitions: (Kanade/Alt maybe)
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

-- Hand Sonic (uses SPR2_MLEE)
freeslot("S_PLAY_HANDSONIC")
states[S_PLAY_HANDSONIC] = {SPR_PLAY, SPR2_MLEE, 4, nil, 0, 0, S_PLAY_HANDSONIC}