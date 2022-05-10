-- handles how animations work
-- they're really straightforward, much like states.
-- but we don't need freeslots for those so hooray.

rawset(_G, "ANIM_done", function(mo, anim)	-- returns true if anim has finished playing for mo
											-- always returns false if anim is on loop.
	return mo.anim_done and mo.anim == anim and not mo.anim_loop
end)

rawset(_G, "ANIM_set", function(mo, anim, loop)	-- sets anim for mo. loop it?

	if mo.status_condition == COND_SUPER	-- we are super
		local n
		-- find out if we have a super variant of an animation
		for k,v in pairs(charStats[mo.skin])
			if v == anim
				n = k
				break
			end
		end

		if n
			if charStats[mo.skin][n.."_super"]
				anim = charStats[mo.skin][n.."_super"]	-- set the anim to "_super" if possible
			end
		end
	end

	mo.anim = anim
	mo.anim_time = 0
	mo.anim_loop = loop
	mo.anim_loops = 0
	mo.anim_done = false

	ANIM_handle(mo)	-- Call this once to set the frame immediately.
end)


local function ANIM_battle(mo)	-- handle animations in battle
	if not mo.battlen return end	-- oops.
	local btl = server.P_BattleStatus[mo.battlen]
	if not btl.running return end	-- nope lol

	-- for standing
	if mo.plyr
		if not mo.ANIM_boredloop
			mo.ANIM_boredloop = P_RandomRange(10, 20)
		end

		if mo.anim == mo.anim_stand
		and mo.anim_loops >= mo.ANIM_boredloop
			ANIM_set(mo, mo.anim_stand_bored)
		end
		if ANIM_done(mo, mo.anim_stand_bored)
			ANIM_set(mo, mo.anim_stand, true)
		end
	end

	-- knockdown:
	if mo.anim == mo.anim_getdown
	and P_IsObjectOnGround(mo)
	and not mo.downanim
		ANIM_set(mo, mo.anim_downloop, true)
	end

	-- getting hurt
	if ANIM_done(mo, mo.anim_hurt)
		ANIM_set(mo, mo.down and mo.anim_downloop or mo.anim_stand, true)
	end

	-- standing while hurt
	if mo.anim == mo.anim_stand
	and mo.hp < mo.maxhp/5
	and mo.anim_stand_hurt
		ANIM_set(mo, mo.anim_stand_hurt, true)
	end

	if mo.hp ~= nil and mo.hp <= 0 and mo.deathanim
		if mo.enemy	-- for enemies
			enemyList[mo.enemy].deathanim(mo)
		end
	end
end

rawset(_G, "ANIM_handle", function(mo, nobtl)	-- do animation!

	if mo.overlay and mo.overlay.valid
	and charStats[mo.skin] and charStats[mo.skin].overlaythink
		charStats[mo.skin].overlaythink(mo.overlay)
	end

	if not mo.anim then return end
	mo.tics = -1

	if not nobtl
		ANIM_battle(mo)
	end

	if not mo.anim[1] return end

	mo.sprite = mo.anim[1]	-- first index is the sprite.
	local frametime = mo.anim[#mo.anim]
	local spr2
	local frame_back = 1	-- where from the end do we stop?

	if type(frametime) == "string"	-- detect spr2
		frametime = mo.anim[#mo.anim-1]
		spr2 = _G[mo.anim[#mo.anim]]
		frame_back = 2
	end

	if spr2 != nil	-- 0 counts! (SPR2_STND)
		local superflag = 0
		if mo.status_condition == COND_SUPER
			superflag = FF_SPR2SUPER	-- a bit of a hack
		end
		mo.sprite2 = spr2|superflag
	end

	local animframes = {}
	for i = 2, #mo.anim-frame_back
		animframes[#animframes+1] = mo.anim[i]
	end

	if mo.anim_time/frametime > #animframes
		if mo.anim_loop
			mo.anim_time = 0	-- loop animation back
			mo.anim_loops = $+1	-- you can use that to make cool stuff with loops
		else
			mo.anim_done = true
			return	-- boo, don't go any farther!
		end
	end

	mo.anim_time = max($, frametime)

	mo.frame = animframes[max(1, mo.anim_time/frametime)]
	mo.anim_time = $+1

end)

freeslot("MT_PFIGHTER")	-- shush
addHook("MobjThinker", ANIM_handle, MT_PFIGHTER)