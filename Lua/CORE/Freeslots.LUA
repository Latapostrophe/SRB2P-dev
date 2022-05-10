-- This file is human rights violation.
-- It's so poorly organized it makes me want to kill myself

-- @TODO: ...Organize this file, one day...

-- Psycho Force
freeslot("SPR_PSID", "sfx_psi")

-- DFM
freeslot("SPR_TEDD", "SPR_TEDB", "SPR_TEDL", "S_TEDDYRUN","MT_TEDDY")
freeslot("sfx_dfms")

states[S_TEDDYRUN] = {SPR_TEDD, FF_ANIMATE, -1, nil, 5, 3, S_TEDDYRUN}


freeslot("sfx_not", "sfx_bton", "sfx_rflc", "sfx_hit2", "sfx_status")
freeslot("SPR_ENMA", "SPR_NTHK", "SPR_TSUN", "SPR_STUN", "SPR_LOVE", "SPR_DESP", "SPR_STFU", "SPR_SLEP", "SPR_FEAR")

freeslot("sfx_float", "sfx_pcan", "sfx_levi")	-- float
freeslot("sfx_psybst") -- psyboost

freeslot("SPR_HAND")
freeslot("sfx_zio5")

freeslot("sfx_susp", "sfx_jet")

-- titlesceen:
freeslot("sfx_ctic", "sfx_cboom", "sfx_mchurt")

-- dummy object to replace MT_THOK:
freeslot("MT_DUMMY")
mobjinfo[MT_DUMMY] = {
	spawnstate = S_THOK,
	spawnhealth = 1000,
	radius = 16*FRACUNIT,
	height = 32*FRACUNIT,
	flags = MF_NOGRAVITY|MF_NOCLIPTHING|MF_NOBLOCKMAP|MF_NOCLIPHEIGHT|MF_NOCLIP,
}


-- some visual fx
freeslot("SPR_DBZD", "SPR_DBZF")
for i = 1, 5
	freeslot("S_PAPERDUST"..i)
end

states[S_PAPERDUST1] = {SPR_DBZD, A|FF_PAPERSPRITE, 3, nil, 0, 0, S_PAPERDUST2}
states[S_PAPERDUST2] = {SPR_DBZD, B|FF_PAPERSPRITE|TR_TRANS20, 3, nil, 0, 0, S_PAPERDUST3}
states[S_PAPERDUST3] = {SPR_DBZD, C|FF_PAPERSPRITE|TR_TRANS30, 3, nil, 0, 0, S_PAPERDUST4}
states[S_PAPERDUST4] = {SPR_DBZD, D|FF_PAPERSPRITE|TR_TRANS50, 3, nil, 0, 0, S_PAPERDUST5}
states[S_PAPERDUST5] = {SPR_DBZD, E|FF_PAPERSPRITE|TR_TRANS70, 3, nil, 0, 0, S_NULL}

for i = 1, 6
	freeslot("S_PFIRE"..i)
end

states[S_PFIRE1] = {SPR_DBZF, A|FF_FULLBRIGHT, 3, A_PFire, 0, 0, S_PFIRE2}
states[S_PFIRE2] = {SPR_DBZF, B|FF_FULLBRIGHT, 3, nil, 0, 0, S_PFIRE3}
states[S_PFIRE3] = {SPR_DBZF, C|FF_FULLBRIGHT, 3, nil, 0, 0, S_PFIRE4}
states[S_PFIRE4] = {SPR_DBZF, D|FF_FULLBRIGHT, 3, nil, 0, 0, S_PFIRE5}
states[S_PFIRE5] = {SPR_DBZF, E|FF_FULLBRIGHT, 3, nil, 0, 0, S_PFIRE6}
states[S_PFIRE6] = {SPR_DBZF, F|FF_FULLBRIGHT, 3, nil, 0, 0, S_NULL}



-- followitems:
freeslot("MT_SRB2P_TAILSOVERLAY")
freeslot("MT_SRB2P_METALJETFUME")

freeslot("S_SRB2P_TAILSDUM", "SPR_TTLS")
states[S_SRB2P_TAILSDUM] = {SPR_PLAY, A, -1, nil, 0, 0, S_SRB2P_TAILSDUM}

mobjinfo[MT_SRB2P_TAILSOVERLAY] = {
	doomednum = -1,
	spawnstate = S_SRB2P_TAILSDUM,
	health = 1000,
	radius = FRACUNIT,
	height = FRACUNIT,
	flags = MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT,
}

mobjinfo[MT_SRB2P_METALJETFUME] = {
	doomednum = -1,
	spawnstate = S_INVISIBLE,
	health = 1000,
	radius = 1,
	height = 1,
	flags = MF_NOGRAVITY|MF_NOCLIP|MF_NOCLIPHEIGHT,
}

freeslot("SPR_MUDO")

freeslot("MT_REAPER", "S_REAPER", "SPR_REAP")

freeslot("sfx_hyprc")

-- stuff for megido
freeslot("SPR_MEGI")
for i = 1, 10 do
	freeslot("S_MEGISTAR"..i)
end

function A_KLKSpark(mo, var1)
	local g = P_SpawnGhostMobj(mo)
	g.color = P_RandomRange(0, MAXSKINCOLORS-1)
	g.fuse = $*3/2
	g.scale = mo.scale + FRACUNIT/2
	g.frame = $|FF_FULLBRIGHT
	if var1
		g.destscale = 1
		g = P_SpawnGhostMobj(mo)
		g.color = SKINCOLOR_WHITE
		g.scale = mo.scale + FRACUNIT/2
		g.frame = $|FF_FULLBRIGHT
		g.destscale = 1
	end
end

for i = 1, 10 do
	states[S_MEGISTAR1+(i-1)] = {SPR_MEGI, (i-1)|FF_FULLBRIGHT, 2, A_KLKSpark, 0, 0, i < 4 and S_MEGISTAR1+i or S_NULL}
end

freeslot("S_MEGITHOK")
states[S_MEGITHOK] = {SPR_NTHK, C|FF_FULLBRIGHT, 1, A_KLKSPark, 1, 0, S_MEGITHOK}

-- shadow's freeslots

freeslot("SPR_SHCC", "SPR_CSPE")
for i = 1, 16
	freeslot("S_CHAOSCONTROL"..i)
end

states[S_CHAOSCONTROL1] = {SPR_SHCC, A|TR_TRANS50, 2, nil, 0, 0, S_CHAOSCONTROL2}
states[S_CHAOSCONTROL2] = {SPR_SHCC, B|TR_TRANS50, 2, nil, 0, 0, S_CHAOSCONTROL3}
states[S_CHAOSCONTROL3] = {SPR_SHCC, C|TR_TRANS50, 2, nil, 0, 0, S_CHAOSCONTROL4}
states[S_CHAOSCONTROL4] = {SPR_SHCC, D|TR_TRANS50, 2, nil, 0, 0, S_CHAOSCONTROL5}
states[S_CHAOSCONTROL5] = {SPR_SHCC, E|TR_TRANS50, 2, nil, 0, 0, S_CHAOSCONTROL6}
states[S_CHAOSCONTROL6] = {SPR_SHCC, F|TR_TRANS60, 2, nil, 0, 0, S_CHAOSCONTROL7}
states[S_CHAOSCONTROL7] = {SPR_SHCC, G|TR_TRANS60, 2, nil, 0, 0, S_CHAOSCONTROL8}
states[S_CHAOSCONTROL8] = {SPR_SHCC, H|TR_TRANS60, 2, nil, 0, 0, S_CHAOSCONTROL9}
states[S_CHAOSCONTROL9] = {SPR_SHCC, I|TR_TRANS60, 2, nil, 0, 0, S_CHAOSCONTROL10}
states[S_CHAOSCONTROL10] = {SPR_SHCC, J|TR_TRANS70, 2, nil, 0, 0, S_CHAOSCONTROL11}
states[S_CHAOSCONTROL11] = {SPR_SHCC, K|TR_TRANS70, 2, nil, 0, 0, S_CHAOSCONTROL12}
states[S_CHAOSCONTROL12] = {SPR_SHCC, L|TR_TRANS70, 2, nil, 0, 0, S_CHAOSCONTROL13}
states[S_CHAOSCONTROL13] = {SPR_SHCC, M|TR_TRANS80, 2, nil, 0, 0, S_CHAOSCONTROL14}
states[S_CHAOSCONTROL14] = {SPR_SHCC, N|TR_TRANS80, 2, nil, 0, 0, S_CHAOSCONTROL15}
states[S_CHAOSCONTROL15] = {SPR_SHCC, O|TR_TRANS90, 2, nil, 0, 0, S_CHAOSCONTROL16}
states[S_CHAOSCONTROL16] = {SPR_SHCC, P|TR_TRANS90, 2, nil, 0, 0, S_NULL}

-- chaos spear explosion
for i = 1, 6
	freeslot("S_CHAOSSPEAREXPLOSION"..i)
end

for i = 1, 6
	states[S_CHAOSSPEAREXPLOSION1+(i-1)] = {SPR_CSPE, (i-1)|FF_FULLBRIGHT, 2, nil, 0, 0, i < 6 and S_CHAOSSPEAREXPLOSION1+i or S_NULL}
end

freeslot("SPR_DELK", "SPR_HYPR")

-- bufu stuff
for i = 1, 6
	freeslot("sfx_bufu"..i)
end

freeslot("sfx_arm", "sfx_summon", "sfx_qsumon")

-- LIGHTNING BLAST FOR ZIODYNE: FROM KART
local radius = FRACUNIT*320	-- you guys change that to anything idgaf!

freeslot("SPR_KSPK")
for i = 1, 14
	freeslot("S_KSPARK"..i)
end

local ltrans = {}
ltrans[5] = TR_TRANS30
ltrans[6] = TR_TRANS60
ltrans[7] = TR_TRANS80

for i = 0, 13
	states[S_KSPARK1+i] = {i%2==0 and SPR_KSPK or SPR_NULL,
			i%2 == 0 and i/2|FF_FULLBRIGHT|(ltrans[i/2] or 0) or A,
			i%2 and 1 or 2,
			nil,
			0,
			0,
			i<13 and S_KSPARK2+i or S_NULL
		}
end

-- stole this from some unreleased shit of mine because cba...
for i = 1,2
	freeslot("SPR_LZI"..i)
end
for i = 1,9
	freeslot("S_LZIO1"..i)
end
for i = 1,9
	freeslot("S_LZIO2"..i)
end

states[S_LZIO11] = {SPR_LZI1, A|FF_FULLBRIGHT, 2, nil, 0, 0, S_LZIO12}
states[S_LZIO12] = {SPR_LZI1, B|FF_FULLBRIGHT, 2, nil, 0, 0, S_LZIO13}
states[S_LZIO13] = {SPR_LZI1, A|FF_FULLBRIGHT, 2, nil, 0, 0, S_LZIO14}
states[S_LZIO14] = {SPR_LZI1, B|FF_FULLBRIGHT, 2, nil, 0, 0, S_LZIO15}
states[S_LZIO15] = {SPR_LZI1, A|FF_FULLBRIGHT, 2, nil, 0, 0, S_LZIO16}
states[S_LZIO16] = {SPR_LZI1, B|FF_FULLBRIGHT, 2, nil, 0, 0, S_LZIO17}
states[S_LZIO17] = {SPR_LZI1, C|FF_FULLBRIGHT|TR_TRANS30, 2, nil, 0, 0, S_LZIO18}
states[S_LZIO18] = {SPR_LZI1, D|FF_FULLBRIGHT|TR_TRANS50, 2, nil, 0, 0, S_LZIO19}
states[S_LZIO19] = {SPR_LZI1, E|FF_FULLBRIGHT|TR_TRANS70, 2, nil, 0, 0, S_NULL}

states[S_LZIO21] = {SPR_LZI2, A|FF_FULLBRIGHT, 2, nil, 0, 0, S_LZIO22}
states[S_LZIO22] = {SPR_LZI2, B|FF_FULLBRIGHT, 2, nil, 0, 0, S_LZIO23}
states[S_LZIO23] = {SPR_LZI2, A|FF_FULLBRIGHT, 2, nil, 0, 0, S_LZIO24}
states[S_LZIO24] = {SPR_LZI2, B|FF_FULLBRIGHT, 2, nil, 0, 0, S_LZIO25}
states[S_LZIO25] = {SPR_LZI2, A|FF_FULLBRIGHT, 2, nil, 0, 0, S_LZIO26}
states[S_LZIO26] = {SPR_LZI2, B|FF_FULLBRIGHT, 2, nil, 0, 0, S_LZIO27}
states[S_LZIO27] = {SPR_LZI2, C|FF_FULLBRIGHT|TR_TRANS30, 2, nil, 0, 0, S_LZIO28}
states[S_LZIO28] = {SPR_LZI2, D|FF_FULLBRIGHT|TR_TRANS50, 2, nil, 0, 0, S_LZIO29}
states[S_LZIO29] = {SPR_LZI2, E|FF_FULLBRIGHT|TR_TRANS70, 2, nil, 0, 0, S_NULL}

-- funnily enough you can't use those on normal builds...

freeslot("SPR_KLIT")
for i = 1, 12
	freeslot("S_KLIT"..i)
end

for i = 0, 11
	states[S_KLIT1+i] = {i%2 == 0 and SPR_KLIT or SPR_NULL, i%2==0 and (i/2)|FF_FULLBRIGHT|FF_PAPERSPRITE or A, 2, nil, 0, 0, i==1 and S_KLIT1 or S_KLIT2+i}
end

-- and the super sonic sparks........
for i = 1, 6
	freeslot("S_KSPK"..i)
end

function A_LSpark(mo)
	mo.fuse = P_RandomRange(20, 50)
	mo.momx = P_RandomRange(-10, 10)*mo.scale
	mo.momy = P_RandomRange(-10, 10)*mo.scale
	mo.momz = P_RandomRange(0, 10)*mo.scale
end

-- fuck off im lazy k
local sparkstate = {A, B, C, B}

for i = 0, 5
	states[S_KSPK1+i] = {	i>0 and SPR_SSPK or SPR_NULL,
							i==0 and A or (sparkstate[i] or A),
							2,
							i==1 and A_LSpark or nil,
							0,
							0,
							i == 5 and S_KSPK3 or S_KSPK2+i
						}
end

--freeslot("sfx_zio3")	-- i like me some persona so it retains the name from the mod :D
-- ziodyne blast
rawset(_G, "lightningblast", function(mo, color, scale)
	S_StartSound(mo, sfx_zio3)
	color = $ or SKINCOLOR_GOLD
	scale = $ or mo.scale
	-- spawn lightning:
	for i = 1,3 do
		local spark = P_SpawnMobj(mo.x, mo.y, mo.floorz, MT_THOK)
		spark.state = S_SSPK1
		spark.color = color
		spark.scale = scale
		spark.destscale = FRACUNIT/6
		spark.momz = P_RandomRange(2, 10)*FRACUNIT
		P_InstaThrust(spark, P_RandomRange(1, 359)*ANG1, P_RandomRange(1, 6)*FRACUNIT)
	end

	local zio1 = P_SpawnMobj(mo.x, mo.y, mo.floorz, MT_THOK)
	zio1.state = S_LZIO11
	zio1.scale = scale*2+(scale/2)
	zio1.destscale = scale	-- this probably looks retarded at smaller scales from afar lmao
	zio1.color = color

	local zio2 = P_SpawnMobj(mo.x, mo.y, mo.floorz, MT_THOK)
	zio2.state = S_LZIO21
	zio2.scale = scale*2+(scale/2)
	zio2.destscale = scale
	zio2.color = color	-- add some variation, variation's nice my dudes

	local size = FixedMul(mo.scale, radius)	-- let's give ourselves 16 tics to do stuff with.

	-- first spawn fixed particles in a fixed radius, then we'll add some randomness:
	for i = 0, 15 do
		local a = ((360/16)*i)*ANG1
		local part = P_SpawnMobj(mo.x + size>>FRACBITS*cos(a), mo.y + size>>FRACBITS*sin(a), mo.z, MT_THOK)
		part.state = S_KSPARK1
		part.scale = scale
		part.color = color
	end

	-- let's fuck around with papersprites i guess
	for i = 1, 16
		local l = P_SpawnMobj(mo.x, mo.y, mo.z, MT_THOK)
		l.state = S_KLIT1 + P_RandomRange(0, 5)
		l.angle = P_RandomRange(0, 359)*ANG1
		l.fuse = P_RandomRange(10, 40)
		l.scale = mo.scale
		l.color = color

		-- alsos spawn a spark...
		l = P_SpawnMobj(mo.x, mo.y, mo.z, MT_THOK)
		l.state = S_KSPK1
		l.tics = P_RandomRange(2, 10)
		l.flags = MF_NOCLIPHEIGHT|MF_NOCLIPTHING
		l.destscale = 1
		l.scale = scale
		l.scalespeed = l.scale/24
		l.color = color
	end
end)


freeslot("sfx_reflc")
freeslot("SPR_SCRN")
for i = 1, 3
	freeslot("S_PROTECTION"..i)
end
states[S_PROTECTION1] = {SPR_SCRN, B|FF_PAPERSPRITE, 2,nil,0,0,S_PROTECTION2}
states[S_PROTECTION2] = {SPR_SCRN, C|FF_PAPERSPRITE, 2,nil,0,0,S_PROTECTION3}
states[S_PROTECTION3] = {SPR_SCRN, D|FF_PAPERSPRITE, 2,nil,0,0,S_NULL}

freeslot("SPR_CSMN")
freeslot("SPR_CHSP")

freeslot("SPR_DBUF")
for i = 1, 6
	freeslot("S_DBUFF"..i)
end
states[S_DBUFF1] = {SPR_DBUF, B|TR_TRANS20, 3,nil,0,0,S_DBUFF2}
states[S_DBUFF2] = {SPR_DBUF, C|TR_TRANS20, 3,nil,0,0,S_DBUFF3}
states[S_DBUFF3] = {SPR_DBUF, D|TR_TRANS20, 3,nil,0,0,S_DBUFF4}
states[S_DBUFF4] = {SPR_DBUF, E|TR_TRANS20, 3,nil,0,0,S_DBUFF5}
states[S_DBUFF5] = {SPR_DBUF, F|TR_TRANS20, 3,nil,0,0,S_DBUFF6}
states[S_DBUFF6] = {SPR_DBUF, G|TR_TRANS20, 3,nil,0,0,S_NULL}

freeslot("SPR_DUST")
for i = 0, 4
	freeslot("S_AOADUST"..i)
end

states[S_AOADUST0] = {SPR_NULL,0,7,nil,0,0,S_AOADUST1}	-- dummy invis state to add delays I guess
states[S_AOADUST1] = {SPR_DUST,0,7,nil,0,0,S_AOADUST2}
states[S_AOADUST2] = {SPR_DUST,1,6,nil,0,0,S_AOADUST3}
states[S_AOADUST3] = {SPR_DUST,2|TR_TRANS30,4,nil,0,0,S_AOADUST4}
states[S_AOADUST4] = {SPR_DUST,3|TR_TRANS60,3,nil,0,0,S_NULL}

for i = 0, 4
	freeslot("S_CDUST"..i)
end

states[S_CDUST0] = {SPR_NULL,0,7,nil,0,0,S_CDUST1}	-- dummy invis state to add delays I guess
states[S_CDUST1] = {SPR_DUST,E|FF_FULLBRIGHT|TR_TRANS30,7,nil,0,0,S_CDUST2}
states[S_CDUST2] = {SPR_DUST,F|FF_FULLBRIGHT|TR_TRANS50,6,nil,0,0,S_CDUST3}
states[S_CDUST3] = {SPR_DUST,G|TR_TRANS70|FF_FULLBRIGHT,4,nil,0,0,S_CDUST4}
states[S_CDUST4] = {SPR_DUST,H|TR_TRANS80|FF_FULLBRIGHT,3,nil,0,0,S_NULL}

for i = 0, 4
	freeslot("S_ODUST"..i)
end

states[S_ODUST0] = {SPR_NULL,0,7,nil,0,0,S_ODUST1}	-- dummy invis state to add delays I guess
states[S_ODUST1] = {SPR_DUST,E|FF_FULLBRIGHT,7,nil,0,0,S_ODUST2}
states[S_ODUST2] = {SPR_DUST,F|FF_FULLBRIGHT,6,nil,0,0,S_ODUST3}
states[S_ODUST3] = {SPR_DUST,G|FF_FULLBRIGHT,4,nil,0,0,S_ODUST4}
states[S_ODUST4] = {SPR_DUST,H|FF_FULLBRIGHT,3,nil,0,0,S_NULL}

freeslot("SPR_SHOT", "SPR_SLASH",
"S_SHOT1",
"S_SHOT2",
"S_SHOT3",
"S_SHOT4",
"S_BSHOT1",
"S_BSHOT2",
"S_BSHOT3")

states[S_SHOT1] = {SPR_SHOT, A, 3,nil,0,0,S_SHOT2}
states[S_SHOT2] = {SPR_SHOT, B, 3,nil,0,0,S_SHOT3}
states[S_SHOT3] = {SPR_SHOT, C, 3,nil,0,0,S_SHOT4}
states[S_SHOT4] = {SPR_SHOT, D, 3,nil,0,0,S_NULL}

states[S_BSHOT1] = {SPR_SHOT, E, 3,nil,0,0,S_BSHOT2}
states[S_BSHOT2] = {SPR_SHOT, F, 3,nil,0,0,S_BSHOT3}
states[S_BSHOT3] = {SPR_SHOT, G, 3,nil,0,0,S_NULL}

freeslot("SPR_HURT", "S_HURTB1", "S_HURTB2", "S_HURTB3", "S_HURTB4")
states[S_HURTB1] = {SPR_HURT, A, 3,nil,0,0,S_HURTB2}
states[S_HURTB2] = {SPR_HURT, B, 3,nil,0,0,S_HURTB3}
states[S_HURTB3] = {SPR_HURT, C, 3,nil,0,0,S_HURTB4}
states[S_HURTB4] = {SPR_HURT, D, 3,nil,0,0,S_NULL}

-- Explosion states

freeslot("SPR_KRBM", "SPR_CEXP", "SPR_CARD", "SPR_PSNA")
for i = 1,10
	freeslot("S_QUICKBOOM"..i)
	freeslot("S_LESS_QUICKBOOM"..i)
	freeslot("S_CQUICKBOOM"..i)
end

states[S_CQUICKBOOM1] = {SPR_CEXP, A|FF_FULLBRIGHT, 1, nil, 0, 0, S_CQUICKBOOM2}
states[S_CQUICKBOOM2] = {SPR_CEXP, B|FF_FULLBRIGHT, 1, nil, 0, 0, S_CQUICKBOOM3}
states[S_CQUICKBOOM3] = {SPR_CEXP, C|FF_FULLBRIGHT, 1, nil, 0, 0, S_CQUICKBOOM4}
states[S_CQUICKBOOM4] = {SPR_CEXP, D|FF_FULLBRIGHT, 1, nil, 0, 0, S_CQUICKBOOM5}
states[S_CQUICKBOOM5] = {SPR_CEXP, E|FF_FULLBRIGHT, 1, nil, 0, 0, S_CQUICKBOOM6}
states[S_CQUICKBOOM6] = {SPR_CEXP, F|FF_FULLBRIGHT, 1, nil, 0, 0, S_CQUICKBOOM7}
states[S_CQUICKBOOM7] = {SPR_CEXP, G|FF_FULLBRIGHT, 1, nil, 0, 0, S_CQUICKBOOM8}
states[S_CQUICKBOOM8] = {SPR_CEXP, H|FF_FULLBRIGHT, 2, nil, 0, 0, S_CQUICKBOOM9}
states[S_CQUICKBOOM9] = {SPR_CEXP, I|FF_FULLBRIGHT, 2, nil, 0, 0, S_CQUICKBOOM10}
states[S_CQUICKBOOM10] = {SPR_CEXP, J|FF_FULLBRIGHT, 2, nil, 0, 0, 0}

states[S_QUICKBOOM1] = {SPR_KRBM, A|FF_FULLBRIGHT, 1, nil, 0, 0, S_QUICKBOOM2}
states[S_QUICKBOOM2] = {SPR_KRBM, B|FF_FULLBRIGHT, 1, nil, 0, 0, S_QUICKBOOM3}
states[S_QUICKBOOM3] = {SPR_KRBM, C|FF_FULLBRIGHT, 1, nil, 0, 0, S_QUICKBOOM4}
states[S_QUICKBOOM4] = {SPR_KRBM, D|FF_FULLBRIGHT, 1, nil, 0, 0, S_QUICKBOOM5}
states[S_QUICKBOOM5] = {SPR_KRBM, E|FF_FULLBRIGHT, 1, nil, 0, 0, S_QUICKBOOM6}
states[S_QUICKBOOM6] = {SPR_KRBM, F|FF_FULLBRIGHT, 1, nil, 0, 0, S_QUICKBOOM7}
states[S_QUICKBOOM7] = {SPR_KRBM, G|FF_FULLBRIGHT, 1, nil, 0, 0, S_QUICKBOOM8}
states[S_QUICKBOOM8] = {SPR_KRBM, H|FF_FULLBRIGHT, 2, nil, 0, 0, S_QUICKBOOM9}
states[S_QUICKBOOM9] = {SPR_KRBM, I|FF_FULLBRIGHT, 2, nil, 0, 0, S_QUICKBOOM10}
states[S_QUICKBOOM10] = {SPR_KRBM, J|FF_FULLBRIGHT, 2, nil, 0, 0, 0}

states[S_LESS_QUICKBOOM1] = {SPR_KRBM, A|FF_FULLBRIGHT, 3, nil, 0, 0, S_LESS_QUICKBOOM2}
states[S_LESS_QUICKBOOM2] = {SPR_KRBM, B|FF_FULLBRIGHT, 3, nil, 0, 0, S_LESS_QUICKBOOM3}
states[S_LESS_QUICKBOOM3] = {SPR_KRBM, C|FF_FULLBRIGHT, 3, nil, 0, 0, S_LESS_QUICKBOOM4}
states[S_LESS_QUICKBOOM4] = {SPR_KRBM, D|FF_FULLBRIGHT, 3, nil, 0, 0, S_LESS_QUICKBOOM5}
states[S_LESS_QUICKBOOM5] = {SPR_KRBM, E|FF_FULLBRIGHT, 3, nil, 0, 0, S_LESS_QUICKBOOM6}
states[S_LESS_QUICKBOOM6] = {SPR_KRBM, F|FF_FULLBRIGHT, 3, nil, 0, 0, S_LESS_QUICKBOOM7}
states[S_LESS_QUICKBOOM7] = {SPR_KRBM, G|FF_FULLBRIGHT, 3, nil, 0, 0, S_LESS_QUICKBOOM8}
states[S_LESS_QUICKBOOM8] = {SPR_KRBM, H|FF_FULLBRIGHT, 5, nil, 0, 0, S_LESS_QUICKBOOM9}
states[S_LESS_QUICKBOOM9] = {SPR_KRBM, I|FF_FULLBRIGHT, 5, nil, 0, 0, S_LESS_QUICKBOOM10}
states[S_LESS_QUICKBOOM10] = {SPR_KRBM, J|FF_FULLBRIGHT, 5, nil, 0, 0, 0}

rawset(_G, "cv_bean", CV_RegisterVar({
	name = "__&bean",
	PossibleValue = CV_OnOff,
	flags = CV_NETVAR,
	defaultvalue = "Off",
}))
freeslot("SPR_HUMP", "sfx_fish")

freeslot("SPR_FREI")
for i = 1, 6
	freeslot("S_FREI"..i)
end

states[S_FREI1] = {SPR_FREI, A|FF_FULLBRIGHT, 2, nil, 0, 0, S_FREI2}
states[S_FREI2] = {SPR_FREI, B|FF_FULLBRIGHT, 2, nil, 0, 0, S_FREI3}
states[S_FREI3] = {SPR_FREI, C|FF_FULLBRIGHT, 2, nil, 0, 0, S_NULL}

states[S_FREI4] = {SPR_FREI, D|FF_FULLBRIGHT, 2, nil, 0, 0, S_FREI5}
states[S_FREI5] = {SPR_FREI, E|FF_FULLBRIGHT, 2, nil, 0, 0, S_FREI6}
states[S_FREI6] = {SPR_FREI, F|FF_FULLBRIGHT, 2, nil, 0, 0, S_NULL}

-- sspk doesn't have ff_fullbright????
states[S_SSPK1].frame = $|FF_FULLBRIGHT
states[S_SSPK2].frame = $|FF_FULLBRIGHT
states[S_SSPK3].frame = $|FF_FULLBRIGHT
states[S_SSPK4].frame = $|FF_FULLBRIGHT

-- Garu

freeslot("MT_GARU")

mobjinfo[MT_GARU] = {
	-1,
	S_INVISIBLE,
	0,
	S_NULL,
	sfx_None,
	0,
	sfx_None,
	S_NULL,
	0,
	sfx_None,
	S_NULL,
	S_NULL,
	S_NULL,
	S_NULL,
	sfx_None,
	0,
	32 * FRACUNIT,
	32 * FRACUNIT,
	0,
	0,
	0,
	sfx_None,
	MF_NOBLOCKMAP|MF_NOGRAVITY,
	S_NULL
}

addHook("MobjThinker", function(mo)

	local target = mo.target
	if not target or not target.valid
		P_RemoveMobj(mo)
		return
	end

	-- failsafe for garuverse sometimes being very stubborn and not despawning.......
	if mo.battlen and not server.P_BattleStatus[mo.battlen]
		P_RemoveMobj(mo)
		return
	end

	if not mo.alivefor then mo.alivefor = 1 else mo.alivefor = min(16, $+2) end

	local sx = mo.x + mo.dist*cos(mo.angle)
	local sy = mo.y + mo.dist*sin(mo.angle)

	if mo.invertrotation
		mo.angle = $+ ANG1*40
		if not mo.momz then mo.momz = -8*FRACUNIT end
	else
		mo.angle = $ - ANG1*40
		if not mo.momz then mo.momz = 8*FRACUNIT end
	end

	if not (leveltime%4)
		mo.momz = -mo.momz
	end

	local qualityfactor = 1
	if mo.lowquality then qualityfactor = 2 end

	if not mo.fakeangle
		mo.fakeangle = P_RandomRange(0, 359)*ANG1
	end

	for i = 1, mo.alivefor / qualityfactor
		local ref = ANG1*2 * qualityfactor
		if not mo.invertrotation then ref = -ref end

		local sx = target.x + mo.dist*cos(mo.angle - (ref)*i)
		local sy = target.y + mo.dist*sin(mo.angle - (ref)*i)
		local sz = target.z + 16*sin(mo.angle - (ref)*i - mo.fakeangle)

		local trail = P_SpawnMobj(sx, sy, sz, MT_THOK)
		trail.frame = A|FF_FULLBRIGHT
		trail.scale = FRACUNIT/3 - (FRACUNIT/12)*(i-1) / (mo.alivefor / qualityfactor)
		trail.scalespeed = $
		trail.destscale = 1

		if mo.tics == 1
			trail.angle = mo.angle - (ref)*i + ANGLE_90
			P_InstaThrust(trail, trail.angle, FRACUNIT*70)
			trail.tics = 7
		end

		if mo.jizzcolor
			trail.color = SKINCOLOR_WHITE
		else
			trail.color = SKINCOLOR_EMERALD
		end
	end
end, MT_GARU)

-- Explosions

freeslot("MT_SMOLDERING")	--Iceman, I'm not German damnit!

mobjinfo[MT_SMOLDERING] = {
	-1,
	S_INVISIBLE,
	0,
	S_NULL,
	sfx_None,
	0,
	sfx_None,
	S_NULL,
	0,
	sfx_None,
	S_NULL,
	S_NULL,
	S_NULL,
	S_NULL,
	sfx_None,
	0,
	32 * FRACUNIT,
	32 * FRACUNIT,
	0,
	0,
	0,
	sfx_None,
	MF_NOBLOCKMAP|MF_NOGRAVITY,
	S_NULL
}

freeslot("MT_BOOMPARTICLE")

mobjinfo[MT_BOOMPARTICLE] = {
	-1,
	S_INVISIBLE,
	0,
	S_NULL,
	sfx_None,
	0,
	sfx_None,
	S_NULL,
	0,
	sfx_None,
	S_NULL,
	S_NULL,
	S_NULL,
	S_NULL,
	sfx_None,
	0,
	32 * FRACUNIT,
	32 * FRACUNIT,
	0,
	0,
	0,
	sfx_None,
	MF_NOBLOCKMAP,
	S_NULL
}

addHook("MobjThinker", function(mo)
	if leveltime%2
		local x,y,z = P_RandomRange(-20, 20)*mo.scale, P_RandomRange(-20, 20)*mo.scale, P_RandomRange(-20, 20)*mo.scale
		local smoke = P_SpawnMobj(mo.x+x, mo.y+y, mo.z+z, MT_SMOKE)
		smoke.scale = mo.scale*2
		smoke.destscale = mo.scale*6
		smoke.momz = P_RandomRange(4, 9)*FRACUNIT
	end
end, MT_SMOLDERING)

addHook("MobjThinker", function(mo)		-- these leave some nice destructive trail.

	local x,y,z = P_RandomRange(-20, 20)*mo.scale, P_RandomRange(-20, 20)*mo.scale, P_RandomRange(-20, 20)*mo.scale
	if leveltime%2
		local smoke = P_SpawnMobj(mo.x+x, mo.y+y, mo.z+z, MT_BOSSEXPLODE)
		smoke.state = S_QUICKBOOM1
		smoke.scale = mo.scale/2
		smoke.destscale = mo.scale
	else
		local smoke = P_SpawnMobj(mo.x+x, mo.y+y, mo.z+z, MT_SMOKE)
		smoke.scale = mo.scale
		smoke.destscale = mo.scale*2
	end
	if P_IsObjectOnGround(mo) and mo.valid then P_RemoveMobj(mo) end
end, MT_BOOMPARTICLE)

-- causes a huge explosion at mo (it's purely cosmetic and doesn't hurt anything)
-- it's terribly unoptimized too but who cares
rawset(_G, "DoExplosion", function(mo)

	local smoldering = P_SpawnMobj(mo.x, mo.y, mo.z, MT_SMOLDERING)
	smoldering.tics = TICRATE*3

	-- start eathquake for nearby players
	for p in players.iterate do
		if p.mo and p.mo.valid and R_PointToDist2(mo.x, mo.y, p.mo.x, p.mo.y) < 1024*FRACUNIT
			P_StartQuake(FRACUNIT*20, 5)
		end
	end

	-- spawn a ring of dust because thats cool
	for i = 1,32
		local dust = P_SpawnMobj(mo.x, mo.y, mo.z+mo.height/5, MT_SMOKE)
		dust.angle = ANGLE_90 + ANG1* (11*(i-1))
		dust.destscale = FRACUNIT*10
		P_InstaThrust(dust, dust.angle, 20*FRACUNIT)
	end

	-- spawn some smoke as remanents of the explosion because thats cool too
	for i = 1,16

		local dust = P_SpawnMobj(mo.x+P_RandomRange(-30, 30)*FRACUNIT, mo.y+P_RandomRange(-30, 30)*FRACUNIT, mo.z+P_RandomRange(0, 30)*FRACUNIT, MT_SMOKE)
		dust.destscale = FRACUNIT*10
		dust.tics = 30
		dust.momz = P_RandomRange(3, 7)*FRACUNIT
	end

	-- explosion particles...?
	for i = 1, 16
		local truc = P_SpawnMobj(mo.x+P_RandomRange(-20, 20)*FRACUNIT, mo.y+P_RandomRange(-20, 20)*FRACUNIT, mo.z+P_RandomRange(0, 60)*FRACUNIT, MT_BOOMPARTICLE)
		truc.scale = FRACUNIT
		truc.destscale = FRACUNIT*5
		truc.momx = P_RandomRange(-20, 20)*FRACUNIT
		truc.momy = P_RandomRange(-20, 20)*FRACUNIT
		truc.momz = P_RandomRange(10, 30)*FRACUNIT
		truc.tics = TICRATE*5
	end

	-- spawn the actual explosion
	for i =1,32
		local truc = P_SpawnMobj(mo.x+P_RandomRange(-20, 20)*FRACUNIT, mo.y+P_RandomRange(-20, 20)*FRACUNIT, mo.z+P_RandomRange(0, 40)*FRACUNIT, MT_BOSSEXPLODE)
		truc.scale = FRACUNIT*2
		truc.destscale = FRACUNIT*6
		truc.state = S_LESS_QUICKBOOM1
		truc.momx = P_RandomRange(-10, 10)*FRACUNIT
		truc.momy = P_RandomRange(-10, 10)*FRACUNIT
		truc.momz = P_RandomRange(0, 20)*FRACUNIT
		if i < 2	-- cool sound effect
			local mobj = P_SpawnMobj(mo.x, mo.y, mo.z, MT_THOK)
			mobj.state = S_INVISIBLE
			mobj.tics = TICRATE*10
			S_StartSound(mobj, sfx_bgxpld)
		end
	end
end)

-- Bufu
freeslot("MT_BUFU", "MT_BUFU_PARTICLE",
"S_BUFU", "S_BUFU_FLASH", "S_BUFU_PARTICLE_A", "S_BUFU_PARTICLE_B", "S_BUFU_PARTICLE_C", "S_BUFU_PARTICLE_D",
"SPR_BFUA", "SPR_BFUB", "SPR_BFUC", "SPR_BFUD", "SPR_BFUE")
states[S_BUFU] = {SPR_BFUA, A|FF_FULLBRIGHT, -1, nil, 0, 0, S_BUFU}
states[S_BUFU_FLASH] = {SPR_BFUA, B|FF_FULLBRIGHT, -1, nil, 0, 0, S_BUFU_FLASH}
states[S_BUFU_PARTICLE_A] = {SPR_BFUB, A|FF_ANIMATE|FF_FULLBRIGHT, -1, nil, 7, 1, S_BUFU_PARTICLE_A}
states[S_BUFU_PARTICLE_B] = {SPR_BFUC, A|FF_ANIMATE|FF_FULLBRIGHT, -1, nil, 3, 1, S_BUFU_PARTICLE_B}
states[S_BUFU_PARTICLE_C] = {SPR_BFUD, A|FF_ANIMATE|FF_FULLBRIGHT, 16, nil, 2, 2, S_NULL}
states[S_BUFU_PARTICLE_D] = {SPR_BFUE, A|FF_ANIMATE|FF_FULLBRIGHT, 9, nil, 8, 1, S_NULL}
addHook("MobjThinker", function(mo)
	mo.risetime = $ and $-1
	if not mo.risetime then mo.momz = max(0, mo.momz-(1*FRACUNIT)) end
end, MT_BUFU)
addHook("MobjThinker", function(mo)
	if not (leveltime%9)
		local x, y, z = P_RandomRange(-20, 20)*mo.scale, P_RandomRange(-20, 20)*mo.scale, P_RandomRange(-20, 20)*mo.scale

		local f = P_SpawnMobj(mo.x+x, mo.y+y, mo.z+z, MT_BOSSEXPLODE)
		f.state, f.scale = S_BUFU_PARTICLE_C, mo.scale/3
		f.destscale = mo.scale

		local s = P_SpawnMobj(mo.x+x, mo.y+y, mo.z+z, MT_SNOWFLAKE)
		s.momz, s.scale, s.flags = -3*FRACUNIT, mo.scale/2, MF_NOGRAVITY
		s.destscale = mo.scale/4
		s.scalespeed = FRACUNIT/20
		s.fuse = TICRATE*5/4
		s.frame = $|FF_FULLBRIGHT
	end
	if P_IsObjectOnGround(mo) then P_RemoveMobj(mo) end
end, MT_BUFU_PARTICLE)

-- Bufula
freeslot("S_BUFULA_LR", "S_BUFULA_L1", "S_BUFULA_R1", "S_BUFULA_PARTICLE", "S_BUFULA_FLASH_A", "S_BUFULA_FLASH_B",
"SPR_BFLA", "SPR_BFLB", "SPR_BFLC")
states[S_BUFULA_LR] = {SPR_BFLA, A|FF_FULLBRIGHT, 1, A_RandomState, S_BUFULA_L1, S_BUFULA_R1, 0}
-- Why cant FF_ANIMATE GO BACKWARDS
for i = 2, 11 do freeslot("S_BUFULA_L"..i) end -- freeslot 2 to 11
for i = 1, 6 do states[S_BUFULA_L1+(i-1)] = {SPR_BFLA, 7-(i-1)|FF_FULLBRIGHT, 1, nil, 0, 0, S_BUFULA_L1+(i)} end -- 1 to 6
for i = 1, 3 do states[S_BUFULA_L7+(i-1)] = {SPR_BLFA, i<3 and 1-(i-1) or 7|FF_FULLBRIGHT, 2, nil, 0, 0, S_BUFULA_L7+(i)} end -- 7 to 9
for i = 1, 2 do states[S_BUFULA_L10+(i-1)] = {SPR_BFLA, 6-(i-1)|FF_FULLBRIGHT, i<2 and 3 or -1, nil, 0, 0, S_BUFULA_L11} end -- 10 to 11
-- Now the more sane, right rotating states
for i = 2, 5 do freeslot("S_BUFULA_R"..i) end -- freeslot 2 to 5
states[S_BUFULA_R1] = {SPR_BFLA, B|FF_ANIMATE|FF_FULLBRIGHT, 6, nil, 5, 1, S_BUFULA_R2}
states[S_BUFULA_R2] = {SPR_BFLA, H|FF_FULLBRIGHT, 2, nil, 0, 0, S_BUFULA_R3}
states[S_BUFULA_R3] = {SPR_BFLA, A|FF_ANIMATE|FF_FULLBRIGHT, 4, nil, 1, 2, S_BUFULA_R4}
for i = 1, 2 do states[S_BUFULA_R4+(i-1)] = {SPR_BFLA, 2+(i-1)|FF_FULLBRIGHT, i<2 and 3 or -1, nil, 0, 0, S_BUFULA_R5} end -- 4 to 5
-- Now just the particle, bless FF_ANIMATE
states[S_BUFULA_PARTICLE] = {SPR_BFLB, A|FF_ANIMATE|FF_FULLBRIGHT, -1, nil, 7, 1, S_BUFULA_PARTICLE}
-- Actually I lied we need the flash frames
states[S_BUFULA_FLASH_A] = {SPR_BFLC, A|FF_FULLBRIGHT, -1, nil, 0, 0, S_BUFULA_FLASH_A}
states[S_BUFULA_FLASH_B] = {SPR_BFLC, B|FF_FULLBRIGHT, -1, nil, 0, 0, S_BUFULA_FLASH_B}

-- Bufudyne
freeslot("S_BUFUDYNE_A1", "S_BUFUDYNE_A2", "S_BUFUDYNE_AF", "S_BUFUDYNE_B1", "S_BUFUDYNE_B2", "S_BUFUDYNE_B3", "S_BUFUDYNE_BF", "S_BUFUDYNE_DUST1", "S_BUFUDYNE_DUST2", "S_BUFUDYNE_DUST3", "S_BUFUDYNE_DUST4",
"S_BUFUDYNE_AURA1", "S_BUFUDYNE_AURA2", "S_BUFUDYNE_AURA3",
"SPR_BFDA", "SPR_BFDB", "SPR_SUMN") -- redefined SPR_SUMN here instead so it would actually show up
states[S_BUFUDYNE_A1] = {SPR_BFDA, A|FF_ANIMATE|FF_FULLBRIGHT, 6, nil, 1, 3, S_BUFUDYNE_A2} -- Stage A: Rising
states[S_BUFUDYNE_A2] = {SPR_BFDA, C|FF_FULLBRIGHT, 11, nil, 0, 0, S_BUFUDYNE_AF} -- Stage A: Stationary
states[S_BUFUDYNE_AF] = {SPR_BFDA, D|FF_FULLBRIGHT, 2, nil, 0, 0, S_BUFUDYNE_B1} -- Stage A: Flash into B
states[S_BUFUDYNE_B1] = {SPR_BFDA, E|FF_FULLBRIGHT, 11, nil, 0, 0, S_BUFUDYNE_B2} -- Stage B: Before reflect
states[S_BUFUDYNE_B2] = {SPR_BFDA, F|FF_ANIMATE|FF_FULLBRIGHT, 9, nil, 2, 3, S_BUFUDYNE_B3} -- Stage B: Reflect
states[S_BUFUDYNE_B3] = {SPR_BFDA, E|FF_FULLBRIGHT, -1, nil, 0, 0, S_BUFUDYNE_B3} -- Stage B: Stationary
states[S_BUFUDYNE_BF] = {SPR_BFDA, H|FF_FULLBRIGHT, -1, nil, 0, 0, S_BUFUDYNE_BF} -- Stage B: Flash
-- Bufudyne Aura
states[S_BUFUDYNE_AURA1] = {SPR_SUMN, A|FF_FULLBRIGHT|FF_PAPERSPRITE, 12, nil, 0, 0, S_BUFUDYNE_AURA2}
states[S_BUFUDYNE_AURA2] = {SPR_SUMN, A|FF_FULLBRIGHT|TR_TRANS50|FF_PAPERSPRITE, 3, nil, 0, 0, S_BUFUDYNE_AURA3}
states[S_BUFUDYNE_AURA3] = {SPR_SUMN, A|FF_FULLBRIGHT|TR_TRANS80|FF_PAPERSPRITE, 3, nil, 0, 0, S_NULL}
-- Bufudyne burst dust
states[S_BUFUDYNE_DUST1] = {SPR_BFDB, A|FF_FULLBRIGHT, 4, nil, 0, 0, S_BUFUDYNE_DUST2}
states[S_BUFUDYNE_DUST2] = {SPR_BFDB, B|FF_FULLBRIGHT, 4, nil, 0, 0, S_BUFUDYNE_DUST3}
states[S_BUFUDYNE_DUST3] = {SPR_BFDB, C|FF_FULLBRIGHT|TR_TRANS50, 4, nil, 0, 0, S_BUFUDYNE_DUST4}
states[S_BUFUDYNE_DUST4] = {SPR_BFDB, D|FF_FULLBRIGHT|TR_TRANS80, 4, nil, 0, 0, S_NULL}

-- Howling
freeslot("sfx_howl1", "sfx_howl2")
freeslot("SPR_HOWL", "S_HOWL1", "S_HOWL2", "S_HOWL3")
local tlookup = {TR_TRANS40, TR_TRANS60, TR_TRANS70}
for i = 0, 2 do
	states[S_HOWL1+i] = {SPR_HOWL, i|tlookup[i+1]|FF_PAPERSPRITE, 10, nil, 0, 0, i < 2 and S_HOWL2+i or S_NULL}
end

freeslot("SPR_ENM1",
"SPR_FPRT",
"sfx_csnap",
"sfx_ice1",
"sfx_ice2",
"sfx_ice3",
"sfx_ice4",
"sfx_frei1",
"sfx_wind1",
"sfx_wind2",
"sfx_wind3",
"sfx_wind4",
"sfx_fire1",
"sfx_fire2",
"sfx_zio1",
"sfx_zio2",
"sfx_zio3",
"sfx_zio4",
"sfx_eih1",
"sfx_eih2",
"sfx_eih3",
"sfx_eih4",
"sfx_hama1",
"sfx_hama2",
"sfx_hama3",
"sfx_hama4",
"sfx_hamaca",
"sfx_hamas1",
"sfx_hamas2",
"sfx_buff",
"sfx_buff2",
"sfx_debuff",
"sfx_karin",
"sfx_mirror",
"sfx_megi1",
"sfx_megi2",
"sfx_megi3",
"sfx_megi4",
"sfx_megi5",
"sfx_megi6",
"sfx_heal",
"sfx_heal2",
"sfx_heal3",
"sfx_heal4",
"sfx_slash",
"sfx_phys",
"sfx_absorb",
"sfx_crit",
"sfx_ora",
"sfx_meboom",
"sfx_aoado",
"sfx_aoaask",
"sfx_aoa_1",
"sfx_aoasli",
"sfx_confir",
"sfx_hover",
"sfx_cancel",
"sfx_hit",
"sfx_not",
"sfx_cutin",
"sfx_srip",
"sfx_1more",
"sfx_lvup",
"sfx_nskill",
"sfx_csnap",
"sfx_sprxpl",
"sfx_drop",
"sfx_susp","sfx_roll")