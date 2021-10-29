-- Switch:
-- In tartarus: Lowers the sector index pointed by extravalue1 to the switch's angle value.
-- In normal dungeons: Executes the tag pointed by its angle

freeslot("MT_SHSWITCH", "S_SHSWITCH", "SPR_SHSW")

mobjinfo[MT_SHSWITCH] = {
	doomednum = 855,
	spawnstate = S_SHSWITCH,
	spawnhealth = 1000,
	radius = 48<<FRACBITS,
	height = 48<<FRACBITS,
	flags = MF_SPECIAL,
}
states[S_SHSWITCH] = {SPR_SHSW, A, -1, nil, 0, 0, S_SHSWITCH}

addHook("TouchSpecial", function(mo, toucher)

	if not mo.extravalue2
		mo.extravalue2 = 1	-- Switch activated
		S_StartSound(mo, sfx_menu1)
	end
	return true
end, MT_SHSWITCH)

addHook("MobjThinker", function(mo)

	if not mo.basecolour
		mo.basecolour = mo.color
	end

	if mo.extravalue2

		mo.color = SKINCOLOR_WHITE
		mo.frame = $|FF_FULLBRIGHT

		if DNG_isTartarusMap()
			local sec = sectors[mo.extravalue1]
			if not sec return end	-- wtf!?

			local destz = mo.angle/ANG1

			if destz < sec.floorheight
				sec.floorheight = max(destz, $-8*FRACUNIT)
			elseif destz > sec.floorheight
				sec.floorheight = min(destz, $+8*FRACUNIT)
			else
				-- We're done
				mo.flags = $|MF_NOTHINK	-- I don't think
			end
		else
			-- @TBA
		end

		return	-- don't flash normally
	end

	if leveltime%10 == 0
		mo.color = SKINCOLOR_WHITE
		mo.frame = $|FF_FULLBRIGHT
	else
		mo.color = mo.basecolour
		mo.frame = $ & ~FF_FULLBRIGHT
	end
end, MT_SHSWITCH)

