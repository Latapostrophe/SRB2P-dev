-- Dropped item
-- These are purely cosmetic and only exist to show you what item you've dropped

freeslot("MT_PDROP", "SPR_DROP")

mobjinfo[MT_PDROP] = {
	doomednum = -1,
	spawnstate = S_INVISIBLE,
	radius = 16<<FRACBITS,
	height = 16<<FRACBITS,
	spawnhealth = 1000,
	flags = MF_NOCLIPTHING,
}

local rarity_colour = {
	SKINCOLOR_WHITE,
	SKINCOLOR_WHITE,
	SKINCOLOR_BLUEBELL,
	SKINCOLOR_BLUEBELL,
	SKINCOLOR_YELLOW,
	SKINCOLOR_YELLOW,
	SKINCOLOR_NONE,
}

rawset(_G, "spawnItemDrop", function(it, x, y, z)
	local frame = A
	if not it return end	-- ???
	
	if it.material
		frame = R
	elseif it.attack
	and attackDefs[it.attack]
	and attackDefs[it.attack].type & ATK_HEAL
		frame = P
	elseif it.menufunc
		frame = Q
	end	
	
	local m = P_SpawnMobj(x, y, z, MT_PDROP)
	m.frame = frame
	m.color = rarity_colour[it.rarity or 1]
	return m
end)

local wpt_to_frame = {
	[WPT_SHOES] = C,
	[WPT_REMOTE] = D,
	[WPT_HAMMER] = E,
	[WPT_KNUCKLES] = F,
	[WPT_CLAWS] = G,
	[WPT_MONITOR] = H,
	[WPT_LIMITERS] = I,
	[WPT_PSYGLOVES] = J,
	[WPT_HEELS] = K,
	[WPT_HANDSONIC] = L,
	[WPT_GENERICMELEE] = N,
	[WPT_GENERICRANGED] = O,
}

rawset(_G, "spawnWeaponDrop", function(wep, x, y, z)
	
	local frame = C
	if wpt_to_frame[weaponsList[wep.ref].type]
		frame = wpt_to_frame[weaponsList[wep.ref].type]
	end
	
	local m = P_SpawnMobj(x, y, z, MT_PDROP)
	m.frame = frame
	m.color = rarity_colour[wep.rarity or 1]
	return m	
end)

rawset(_G, "spawnRingDrop", function(ring, x, y, z)
	
	local frame = B
	
	local m = P_SpawnMobj(x, y, z, MT_PDROP)
	m.frame = frame
	m.color = rarity_colour[ring.rarity or 1]
	return m	
end)

addHook("MobjThinker", function(mo)
	
	-- fling myself upwards
	if not mo.cusval
		mo.angle = P_RandomRange(0, 360)*ANG1
		P_InstaThrust(mo, mo.angle, 12*mo.scale)
		mo.momz = P_RandomRange(14, 20) << FRACBITS
		mo.z = $ + FRACUNIT/2
		mo.cusval = 1
		mo.flags2 = $|MF2_DONTDRAW
	end
	
	if not mo.color
		mo.rainbowcolor = true
	elseif mo.rainbowcolor
		local rainbow = {SKINCOLOR_GREEN, SKINCOLOR_YELLOW, SKINCOLOR_ORANGE, SKINCOLOR_RED, SKINCOLOR_PURPLE, SKINCOLOR_BLUE, SKINCOLOR_CYAN}
		mo.color = rainbow[leveltime%(#rainbow) +1]
	end
	
	if not mo.extravalue2
		local g = P_GetMobjGravity(mo)
		mo.momz = $ + g*3
		local spark = P_SpawnMobj(mo.x, mo.y, mo.z, MT_SUPERSPARK)
		
		if P_IsObjectOnGround(mo)
			mo.extravalue2 = 1
			mo.flags2 = $ & ~MF2_DONTDRAW
			mo.sprite = SPR_DROP
			mo.frame = $|FF_FULLBRIGHT|FF_PAPERSPRITE
			mo.scale = 1
			mo.destscale = FRACUNIT*3
			mo.scalespeed = FRACUNIT/8
			mo.fuse = TICRATE*3/2
			mo.momx = 0
			mo.momy = 0
			S_StartSound(mo, sfx_drop)
		end
	else
		mo.angle = $ + ANG1*5
	end
	
	if mo.fuse == 2
		for i = 1, 16
				
			local s = P_SpawnMobj(mo.x, mo.y, mo.z, MT_SUPERSPARK)
			s.scale = FRACUNIT/2
			s.momx = P_RandomRange(-8, 8)*mo.scale
			s.momy = P_RandomRange(-8, 8)*mo.scale
			s.momz = P_RandomRange(-8, 8)*mo.scale
		end
	end

end, MT_PDROP)