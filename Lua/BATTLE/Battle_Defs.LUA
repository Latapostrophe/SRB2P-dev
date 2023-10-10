-- Define stuff for battles

freeslot("sfx_battle", "sfx_turn", "sfx_select", "sfx_cancel", "sfx_hover", "sfx_confir")

-- pn: partynumber
-- s: sfx_
-- [mo], usedfor confirmation w/ consoleplayer

rawset(_G, "playSound", function(pn, s, mo)
	-- play the sound in front of the camera:

	if not s return end

	if mo
		S_StartSound(mo, s)
		return	-- Play from Mobj
	end

	if not pn return end
	local played = {}

	for i = 1, 4
		local p = server.playerlist[pn][i]
		if p and p.valid
		and not played[p]
			played[p] = true
			S_StartSound(nil, s, p)
		end
	end
end)

-- plays sound locally for all players this entity is in the team of
rawset(_G, "playLocalSound", function(mo, s)

	if not s return end
	if not mo return end

	local played = {}

	for i = 1, 4
		local p = server.playerlist[mo.battlen][i]
		if p and p.valid
		and not played[p]
			played[p] = true
			S_StartSound(nil, s, p)
		end
	end
end)

-- sort items by these criteria:

/*
	1: Is item usable in battle?
		a: is skill a healing skill?
		b: skill type
		c: not a passive
		d: "power" of the skill it gives
		e: targetting

	2: Is the item usable outside of battle?

	3: materials

	4: key
*/

-- this function then sets the values necessary to know when each item type starts (battle, menu, materials, key)

rawset(_G, "BTL_sortItems", function(btl)

	btl.it_section1 = 0	-- BATTLE ITEMS
	btl.it_section2 = 0	-- MENU ITEMS
	btl.it_section3 = 0	-- MATERIALS
	btl.it_section4 = 0	-- KEY

	table.sort(btl.items, function(a, b)

		local it1 = itemDefs[a[1]]
		local it2 = itemDefs[b[1]]

		if not it1 or not it2
			return false
		end	-- wtf

		-- battle-usable items go first, and those who can also be used in menus get higher priority too.
		if it1.key ~= it2.key
			return (not it1.key) and it2.key
		elseif it1.material ~= it2.material
			return (not it1.material) and it2.material
		elseif it1.menuonly ~= it2.menuonly
			return (not it1.menuonly) and it2.menuonly
		elseif it1.skillcard ~= it2.skillcard
			return (not it1.skillcard) and it2.skillcard
		elseif it1.skillcard and it2.skillcard and it1.skill and it2.skill and attackDefs[it1.skill] and attackDefs[it2.skill]
			return attackSortFunc(it1.skill, it2.skill)
		elseif it1.nouse ~= it2.nouse
			return (not it1.nouse) and it2.nouse
		elseif it1.rarity ~= it2.rarity
			return (it1.rarity or 1) < (it2.rarity or 1)
		end

		-- 2 battle usable item? check if they have attacks
		if it1.attack and it2.attack
		and attackDefs[it1.attack]
		and attackDefs[it2.attack]	-- make sure this doesn't explode...
			local atk1 = attackDefs[it1.attack]
			local atk2 = attackDefs[it2.attack]

			local t1 = atk1.type & ~ATK_PASSIVE
			local t2 = atk2.type & ~ATK_PASSIVE

			if t1 & ATK_HEAL ~= t2 & ATK_HEAL
				return t1 & ATK_HEAL
			elseif t1 & ATK_SUPPORT ~= t2 & ATK_SUPPORT
				return t1 & ATK_SUPPORT
			elseif atk1.showsp ~= atk2.showsp
				return not atk1.showsp
			elseif t1 ~= t2
				return t1 < t2
			elseif atk1.power ~= atk2.power
				return (atk1.power or 0) < (atk2.power or 0)
			elseif atk1.target ~= atk2.target
				return (atk1.target or 1) < (atk2.target or 0)
			end
		end

		return false
	end)

	-- iterate items to tell where every section is
	for i = 1, #btl.items do
		local it = btl.items[i][1]

		local def = itemDefs[it]
		if not def continue end

		if def.menuonly
		and not btl.it_section2
			btl.it_section2 = i
		elseif def.material
		and not btl.it_section3
			btl.it_section3 = i
		elseif def.key
		and not btl.it_section4
			btl.it_section4 = i
		end
	end

	btl.it_section4 = $ or #btl.items+1
	btl.it_section3 = $ or min(btl.it_section4, #btl.items+1)
	btl.it_section2 = $ or min(btl.it_section3, #btl.items+1)


	--print("Section 2 begins at "..btl.it_section2)
	--print("Section 3 begins at "..btl.it_section3)
	--print("Section 4 begins at "..btl.it_section4)
end)

-- get macca. ...This can also be used to spend it!
rawset(_G, "BTL_getMacca", function(btl, amount)
	if amount and amount > 0
		btl.netstats.maccaearned = $ + amount
	elseif amount and amount < 0
		btl.netstats.maccaspent = $ - amount
	end

	btl.macca = max(0, $ + (amount or 0))
end)

-- add item to the item list
rawset(_G, "BTL_addItem", function(btl, item, amount)
	-- scan btl.items to see if we already have some of those:

	if not itemDefs[item]
		print("\x82".."WARNING: ".."Attempt to add invalid item \'"..item.."\' into battle status "..btl.n)
		return
	end

	if btl.netstats
		btl.netstats.itemsfound = $+1
	end

	amount = $ or 1	-- just in case
	for i = 1, #btl.items do
		local iteml = btl.items[i]
		if iteml[1] == item	-- we do have some.
			iteml[2] = $+amount	-- add to amount
			return true	-- go away
		end
	end
	-- otherwise, create a new entry
	table.insert(btl.items, {item, amount})

	BTL_sortItems(btl)
end)

-- remove item from the list properly.
rawset(_G, "BTL_useItem", function(btl, itemn, use)

	if use
		btl.netstats.itemsused = $+1
	end

	btl.items[itemn][2] = $-1
	if not btl.items[itemn][2]
		table.remove(btl.items, itemn)
		BTL_sortItems(btl)
		return true
	end
end)

-- find an item in the specified btl
rawset(_G, "BTL_findItem", function(btl, itemn)
	for i = 1, #btl.items
		if btl.items[i][1] == itemn
			return i
		end
	end
end)

-- An item to battle results.
-- Works similarly to BTL_addItem but doesn't perform any sorting.
rawset(_G, "BTL_addResultItem", function(btl, item, amount)
	-- scan btl.items to see if we already have some of those:
	if not btl.r_item
		btl.r_item = {}
	end

	amount = $ or 1	-- just in case
	for i = 1, #btl.r_item do
		local iteml = btl.r_item[i]
		if iteml[1] == item	-- we do have some.
			iteml[2] = $+amount	-- add to amount
			return true	-- go away
		end
	end
	-- otherwise, create a new entry
	table.insert(btl.r_item, {item, amount})
end)

-- Use this to assign an attackdef to a variable.
-- this copies all of the attack's properties except the functions which must not be saved into userdata
rawset(_G, "BTL_copyAttackDefs", function(atk)
	local res = {}

	for k, p in pairs(atk)
		if type(p) ~= "function"
			res[k] = p
		end
	end
	return res
end)

-- sets mo's attack
rawset(_G, "BTL_setAttack", function(mo, atk)
	if not attackDefs[atk]
		atk = "dummy"
	end

	mo.attackref = atk	-- for attack synching
	mo.attack = BTL_copyAttackDefs(attackDefs[atk])
end)

-- check whether or not we can use super forms in any given battle for a given mo
rawset(_G, "BTL_canSuper", function(btl, mo)
	-- you *CAN* super if:
		-- You are currently under the effects of Hyper Mode
		-- at least 3 EP remains
		-- Max EP is 7 or higher


	if mo.status_condition == COND_HYPER	-- for now let's only consider this one
	and btl.emeraldpow >= 300
	and btl.emeraldpow_max >= 7
		return true
	end
end)

freeslot("MT_SUMMONFRAME")
for i = 1, 3
	freeslot("S_AURA"..i)
end

mobjinfo[MT_SUMMONFRAME] = {
	-1,
	S_AURA1,
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

	local transflag
	if mo.tics > 8
		transflag = 0
	end
	if mo.tics > 6
		transflag = TR_TRANS10
	end
	if mo.tics > 2
		transflag = TR_TRANS10
	end
	if mo.tics > 0
		transflag = TR_TRANS20
	end
	mo.frame = P_RandomRange(2, 4) | transflag | FF_FULLBRIGHT
end, MT_SUMMONFRAME)

states[S_AURA1] = {SPR_SUMN, A|FF_FULLBRIGHT|FF_TRANS30|FF_PAPERSPRITE, 5, nil, 0, 0, S_AURA2}
states[S_AURA2] = {SPR_SUMN, A|FF_FULLBRIGHT|FF_TRANS60|FF_PAPERSPRITE, 5, nil, 0, 0, S_AURA3}
states[S_AURA3] = {SPR_SUMN, A|FF_FULLBRIGHT|FF_TRANS80|FF_PAPERSPRITE, 5, nil, 0, 0, S_NULL}

freeslot("SPR_FRAG")
for i = 1, 5
	freeslot("S_FRAG"..i)
end
local trans = {TR_TRANS50, TR_TRANS60, TR_TRANS70, TR_TRANS80, TR_TRANS60}
for i = 0,4
	states[S_FRAG1+i]	= {SPR_SUMN, (i+1)|FF_FULLBRIGHT|trans[i+1], 3, nil, 0, 0, i<3 and S_FRAG2+i or S_NULL}
end

rawset(_G, "summonAura", function(mo, color)	-- spawn a summon aura around mo
	if leveltime%2 return end
	if not mo or not mo.valid return end
	color = $ or SKINCOLOR_TEAL
	local baseangle = P_RandomRange(1, 360)*ANG1
	local dist = 30
	for i = 0, 12
		local angle = baseangle + i*6*ANG1
		local x, y = mo.x + dist*cos(angle), mo.y + dist*sin(angle)

		local aura = P_SpawnMobj(x, y, mo.z + mo.height/4 + i*FRACUNIT*3, MT_DUMMY)
		aura.state = S_AURA1
		--if not aura or not aura.valid continue end
		aura.angle = angle - ANGLE_90
		aura.color = color
		aura.momz = P_RandomRange(2, 5)*FRACUNIT
		aura.scale = FRACUNIT/2
		aura.destscale = FRACUNIT
		P_InstaThrust(aura, angle, FRACUNIT*P_RandomRange(1, 3))
	end

	local zoffs = mo.eflags & MFE_VERTICALFLIP and -65*mo.scale or 0
	for i = 1, 8
		local wf = 32
		local hf = P_RandomRange(65, 1)*mo.scale*P_MobjFlip(mo)
		local x, y, z = mo.x + P_RandomRange(-wf, wf)*mo.scale, mo.y + P_RandomRange(-wf, wf)*mo.scale, mo.z + zoffs + hf
		local t = P_SpawnMobj(x, y, z, MT_DUMMY)
		t.color = color or SKINCOLOR_TEAL
		t.eflags = mo.eflags & MFE_VERTICALFLIP
		t.flags2 = mo.flags2 & MF2_OBJECTFLIP
		t.state = i==7 and S_FRAG5 or S_FRAG1
		P_SetObjectMomZ(t, P_RandomRange(4, 12)*FRACUNIT)
		t.scale = mo.scale*2
		t.destscale = 1
		t.scalespeed = mo.scale/24
	end

	/*for i = 1, 2
		local type = MT_SUMMONFRAME
		if i%2 then type = MT_DUMMY end
		local aura = P_SpawnMobj(mo.x + P_RandomRange(-64, 64)*FRACUNIT, mo.y + P_RandomRange(-64, 64)*FRACUNIT, mo.z + P_RandomRange(0, 64)*FRACUNIT, type)
		--if not aura or not aura.valid continue end
		aura.momz = P_RandomRange(4, 9)*FRACUNIT
		aura.tics = 35
		aura.color = color
		if i%2 then aura.sprite = SPR_SUMN; aura.frame = F|FF_TRANS40|FF_FULLBRIGHT; aura.tics = 35; aura.scale = FRACUNIT/4; aura.destscale = FRACUNIT; aura.momz = P_RandomRange(9, 18)*FRACUNIT end
	end*/
end)

-- non flags for players

local deny_commands = {
	"CDENY_ATTACK",
	"CDENY_SKILL",
	"CDENY_ITEM",
	"CDENY_PERSONA",
	"CDENY_TACTICS",	-- also prevents shortcuts to analysis
	"CDENY_GUARD",

	"CDENY_BATONPASS",

	-- disable: probably unused
	"CDISABLE_ATTACK",
	"CDISABLE_SKILL",
	"CDISABLE_ITEM",
	"CDISABLE_PERSONA",
	"CDISABLE_TACTICS",
	"CDISABLE_GUARD",

	"CDISABLE_BATONPASS",
}

for i = 0, #deny_commands-1
	rawset(_G, deny_commands[i+1], 2^i)
end

rawset(_G, "compareTables", function(t1, t2)	-- compare the entries of a table and returns true if they're all equal
	local equalscount = 0
	if not t1 or not t2 return end
	if #t1 ~= #t2 return end

	for i = 1, #t1 or 0
		local ind1 = t1[i]
		local ind2 = t2[i]
		if ind1 == ind2
			equalscount = $+1
		end
	end
	return equalscount == #t1
end)

rawset(_G, "updateUDtable", function(t, f)		-- remove invalid entries from an userdata table

	for i = 1, #t	-- we really need to cleanse

		for k,v in ipairs(t)
			if not v.valid
				table.remove(t, k)
			end
		end
	end
end)

rawset(_G, "updateUDtable_nohp", function(t, f)		-- remove dead entities from an userdata table

	for i = 1, #t	-- we really need to cleanse

		for k,v in ipairs(t)
			if v and v.valid and not v.hp
				table.remove(t, k)
			end
		end
	end
end)

rawset(_G, "copyTable", function(t1)
	local t = {}
	for k,v in pairs(t1)
		t[k] = v
	end
	return t
end)

-- add t2 at the end of t1
rawset(_G, "addTables", function(t1, t2)
	local t = copyTable(t1)
	local startlen = #t1+1
	local tprogress = 1

	for i = startlen, startlen+ #t2
		t[i] = t2[tprogress]
		tprogress = $+1
	end
	return t
end)

rawset(_G, "shuffleTable", function(t)
    if not (t) then return end
    if not (#t) then return t end

    local randomTable = {}    -- what we'll be returning
    for i = #t, 1, -1
        local index = P_RandomRange(1, i)

        table.insert(randomTable, t[index])
        table.remove(t, index)
    end

    return randomTable
end)

-- battlestate flags BS_ stands for battlestate, not bullshit

rawset(_G, "BS_START", 1)		-- Battle has just started, make enemies appear and get everyone into position.
								-- Also reset variables
rawset(_G, "BS_PRETURN", 2)		-- Check for status conditions, and stat (de)buffs before letting the object take its turn
rawset(_G, "BS_DOTURN", 3)		-- Object is selecting turn command. This is automatic for enemies and auto-mode bots.
rawset(_G, "BS_ACTION", 4)		-- Object is acting. (eg: attacking, using item, defending...)
rawset(_G, "BS_ENDTURN", 5)		-- Object just finished its turn. Transition into the next turn.
rawset(_G, "BS_END", 6)			-- Battle has ended. Give EXP and shit.
rawset(_G, "BS_EVENT", 7)		-- event is running at the end of a turn.
rawset(_G, "BS_HOLDUP", 8)		-- HOLD UP! All enemies knocked down. You can negociate or have an AOA here.
rawset(_G, "BS_SHUFFLE", 9)	-- SHUFFLE TIME! Time to mix up some cards
rawset(_G, "BS_LEVELUP", 10)	-- leveling up post battle
rawset(_G, "BS_FINISH", 11)		-- battle finished, fade back to normal gameplay
rawset(_G, "BS_MPFINISH", 12)	-- multiplayer session finished
rawset(_G, "BS_HYPERDIE", 13)	-- special battle state, handles the death of hyper mode shadows
rawset(_G, "BS_GAMEOVER", 14)	-- all players died
rawset(_G, "BS_PVPOVER", 15)	-- pvp mode over, fade to black and quit
rawset(_G, "BS_MOREENEMIES", 16)	-- spawn another wave of enemies (used in sp, coop and challenge)
rawset(_G, "BS_CHALLENGEEND", 17)	-- challenge has ended, eiter succeeded or failed, doesn't matter
rawset(_G, "BS_LINK", 18)			-- triggered when a Link skill is taking effect

-- action select flags (helps recognize menus with ease!)

rawset(_G, "ACT_NONE", 0)		-- selecting menu	-> this also lets us select a target for melee attack and analysis
rawset(_G, "ACT_TARGET", 1)		-- select target	-> this is for skills and items ONLY.
rawset(_G, "ACT_DEFEND", 2)		-- defend? prompt
rawset(_G, "ACT_SKILL", 3)		-- pop skill menu
rawset(_G, "ACT_ITEM", 4)		-- pop item menu
rawset(_G, "ACT_TACTICS", 5)	-- tactics menu
rawset(_G, "ACT_BATONTOUCH", 6)	-- baton pass
rawset(_G, "ACT_SUBPERSONAS", 7)	-- persona sub menu
rawset(_G, "ACT_TURNORDER", 8)		-- turn order

-- bots

mobjinfo[MT_PFIGHTER] = {
	-1,
	S_PLAY_STND,
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
	16 * FRACUNIT,
	32 * FRACUNIT,
	1000,
	0,
	0,
	sfx_None,
	MF_SLIDEME,
	S_NULL
}

mobjinfo[MT_PFIGHTER].dispoffset = -64	-- REEE
mobjinfo[MT_DUMMY].dispoffset = 32

-- cam

freeslot("MT_BATTLECAMERA")

mobjinfo[MT_BATTLECAMERA] = {
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
	MF_NOGRAVITY|MF_FLOAT|MF_NOCLIP|MF_NOCLIPHEIGHT,
	S_NULL
}

local cam_div = 8

addHook("MobjThinker", function(mo)

	if mo.goto ~= nil
	and mo.goto[1]~=nil
		if not mo.goto[4]
			-- no speed, move smoothly
			mo.momx = (mo.goto[1] - mo.x) / cam_div
			mo.momy = (mo.goto[2] - mo.y) / cam_div
			mo.momz = (mo.goto[3] - mo.z) / cam_div

			if R_PointToDist2(mo.x, mo.y, mo.goto[1], mo.goto[2]) < FRACUNIT	-- needs to stop eventually
				mo.goto[1] = nil
				mo.goto[2] = nil
				mo.goto[3] = nil
				CAM_stop(mo)
				return
			end
		else

			if not mo.target
				local wp = P_SpawnMobj(mo.goto[1], mo.goto[2], mo.goto[3], MT_TUBEWAYPOINT)
				mo.target = wp
			end

			if not mo.camspeed then mo.camspeed = 0 end

			mo.camspeed = mo.goto[4] or FRACUNIT*36	--min((mo.goto[4] or FRACUNIT*36), $ + (mo.goto[4] or FRACUNIT*36)/8)

			local dist = R_PointToDist2(mo.x, mo.y, mo.target.x, mo.target.y) or 1
			mo.momx = FixedMul(FixedDiv(mo.target.x - mo.x, dist), mo.camspeed)
			mo.momy = FixedMul(FixedDiv(mo.target.y - mo.y, dist), mo.camspeed)
			mo.momz = FixedMul(FixedDiv(mo.target.z - mo.z, dist), mo.camspeed)
			-- Poor man's A_HomingChase. don't modify the angle lol

			--A_HomingChase(mo, mo.goto[4], 0)

			if R_PointToDist2(mo.x, mo.y, mo.target.x, mo.target.y) < mo.goto[4]
				if mo.target and mo.target.valid
					P_RemoveMobj(mo.target)
				end
				mo.target = nil
				CAM_goto(mo, mo.goto[1], mo.goto[2], mo.goto[3])	-- Finish with a smooth animation.
				mo.camspeed = nil
			end
		end
	end

	if mo.gotoangle ~= nil
	and mo.gotoangle[1]~=nil

		--local m = mo.gotoangle[2] or 1

		local an = angtoint(mo.angle)
		local tangle = (mo.gotoangle[1] - an)*FRACUNIT / cam_div

		if abs(tangle*cam_div) > 180<<FRACBITS
			if mo.gotoangle[1] < an
				tangle = (mo.gotoangle[1] + 360 - an)*FRACUNIT / cam_div
			else
				tangle = -(an + 360 - mo.gotoangle[1])*FRACUNIT	/ cam_div -- trust me on that one
			end
		end

		mo.angle = $+FixedAngle(tangle)

		--print(tostring(angtoint(mo.angle)).." | "..tostring(mo.gotoangle[1]).." ("..tostring(tangle/FRACUNIT)..", "..tostring(m)..")")

		 if angtoint(mo.angle) == mo.gotoangle[1]
			mo.gotoangle = {}
		end
	end

	if mo.look ~= nil
	and mo.look[1]~=nil
		--print("hello???")
		local speed
		if mo.look[2]
			speed = mo.look[2]
		else
			speed = ANG1*3
		end

		mo.aiming = $ or 0

		if mo.aiming < mo.look[1]
			mo.aiming = $1 + min(mo.look[1] - mo.aiming, speed)
		end

		if mo.aiming > mo.look[1]
			mo.aiming = $1 - min(mo.aiming - mo.look[1], speed)
		end

		if mo.aiming == mo.look[1]
			mo.look = {}
		end
	end
end, MT_BATTLECAMERA)


-- cam stuff

-- Makes the player follow the camera
-- if setttics is on, also forces-set awayviewtics to the chosen value
rawset(_G, "CAM_linkPlayer", function(cam, p, settics)

	p.awayviewmobj = cam
	if settics
		p.awayviewtics = settics
	end

	p.awayviewaiming = cam.aiming
end)

rawset(_G, "CAM_defaultcoords", function(mo, noreset)	-- gets coordinate for default cam positionning. (for menus)
	local cam = server.P_BattleStatus[mo.battlen].cam
	if not noreset
		mo.targets = mo.enemies
		mo.t_target = 1
	end
	cam.lasttargetx = not cam.lasttargetx
	cam.lasttargety = not cam.lasttargety
	cam.goto = {}

	local x, y, z, angle, aiming = CAM_followtarget(mo, true)
	return x, y, z, angle, aiming
end)

rawset(_G, "CAM_followtarget", function(mo, force)	-- for players. makes the camera follow the target
	if not mo.targets return end
	if not mo.t_target return end
	local cam = server.P_BattleStatus[mo.battlen].cam
	local target = mo.targets[mo.t_target] or mo.targets[1]

	if not target return end	-- what
	if not target.valid return end

	if target and target.valid and cam.lasttargetx == target.x and cam.lasttargety == target.y and not force return end	-- no

	if mo.attack and (mo.attack.target == TGT_ALLY or mo.attack.target == TGT_DEAD or mo.attack.target == TGT_CASTER)
		P_InstaThrust(cam, 0, 0)
		local dist = 300
		local an = target.angle - ANG1*35

		local x = target.x + dist*cos(an)
		local y = target.y + dist*sin(an)
		local z = target.z + FRACUNIT*92
		local angle = R_PointToAngle2(x, y, target.x, target.y)
		P_TeleportMove(cam, x, y, z)
		cam.angle = angle
		cam.lasttargetx = target.x
		cam.lasttargety = target.y
		CAM_stop(cam)
		return
	elseif mo.attack and mo.attack.target == TGT_ALLALLIES
		CAM_stop(cam)
		local dist = 512
		local an = target.angle - ANG1*35

		local x = mo.x + dist*cos(an)
		local y = mo.y + dist*sin(an)
		local z = mo.z + FRACUNIT*92
		local angle = R_PointToAngle2(x, y, target.x, target.y)
		P_TeleportMove(cam, x, y, z)
		if not cam.alltargets_setangle
			cam.angle = angle
			cam.alltargets_setangle = true
		else
			CAM_angle(cam, angle, ANG1*2)
		end
		cam.lasttargetx = target.x
		cam.lasttargety = target.y
		return
	elseif mo.attack and mo.attack.target == TGT_EVERYONE
		local gox = server.P_BattleStatus[mo.battlen].arena_coords[1] + 800*cos(ANG1*30)
		local goy = server.P_BattleStatus[mo.battlen].arena_coords[2] + 800*sin(ANG1*30)
		P_TeleportMove(cam, gox, goy, mo.z + FRACUNIT*120)
		cam.angle = R_PointToAngle2(gox, goy, server.P_BattleStatus[mo.battlen].arena_coords[1], server.P_BattleStatus[mo.battlen].arena_coords[2])
		cam.aiming = ANG1*(-4)
		CAM_stop(cam)
		return
	end

	cam.alltargets_setangle = nil

	local dist = 300
	local basex, basey = mo.x, mo.y
	local an = R_PointToAngle2(mo.x, mo.y, target.x, target.y) - ANG1*165

	local x = basex + dist*cos(an)
	local y = basey + dist*sin(an)
	local z = mo.z + FRACUNIT*92
	local angle = R_PointToAngle2(x, y, target.x, target.y)

	if not mo.t_ctarget	or mo.t_ctarget < 8 or force -- only move when ready...
		CAM_goto(cam, x, y, z)
		CAM_angle(cam, angle, ANG1*2)
		cam.lasttargetx = target.x
		cam.lasttargety = target.y
	end

	if not cam.firstdefault
		cam.firstdefault = {x, y, z, angle}
	end

	return x, y, z, angle, ANG0

end)

local function compareangles(ang1, ang2)	-- returns 1 if we should add, -1 if we should subtstract to reach the angle

	local diff = ang2 - ang1

	if diff < 0
		diff = $+360
	end

	return diff > 180 and -1 or 1
end

rawset(_G, "CAM_aiming", function(cam, angle, speed)
	if not cam return end
	cam.look[1] = angle or 0
	cam.look[2] = speed or ANG1*4
end)

rawset(_G, "CAM_angle", function(cam, angle, speed)
	if not cam return end
	angle = angtoint($)
	speed = $ or ANG1*4
	cam.gotoangle[1] = angle
	-- compare the two angles to see in which direction it'd be better to turn the camera
	--cam.gotoangle[2] = compareangles(angtoint(cam.angle), angle)
end)

rawset(_G, "CAM_goto", function(cam, x, y, z, speed)
	if not cam return end
	cam.goto = {}
	cam.goto[1] = x or 0
	cam.goto[2] = y or 0
	cam.goto[3] = z or 0
	cam.goto[4] = speed
end)

rawset(_G, "CAM_stop", function(cam)
	cam.goto = {}
	if cam.target and cam.target.valid
		P_RemoveMobj(cam.target)
	end
	cam.target = nil
	cam.look = {}
	cam.gotoangle = {}
	P_InstaThrust(cam, 0, 0)
	cam.momz = 0
end)

-- emerald skills unlocked depending on emerald power.
-- these are added to the end of every player's skill list
rawset(_G, "BTL_EmeraldSkills", {
	nil,			-- 1st emerald has no skill, it grants the ability to use hyper mode however
	"analysis",		-- 2nd emerald: analysis
})

-- starts the battle EXP sequence on its own.
-- n: battle status #
-- exp: exp earned.
-- items, weapons, rings: set the apropriate tables.

rawset(_G, "BTL_getEXP", function(n, exp, items, weapons, rings, macca)
	local btl = server.P_BattleStatus[n]
	if not btl return end -- bruh

	BTL_softReset(n)
	btl.running = true

	btl.r_outofbattle = true	-- This disables the camera thinkers and shit.
	btl.r_exp = exp or 0
	btl.r_money = macca or 0
	btl.r_item = items or {}
	btl.r_weapons = weapons or {}
	btl.r_rings = rings or {}

	btl.battlestate = BS_END
	btl.hudtimer.endb = TICRATE*3/2
	btl.r_precalculates = {}

	-- make sure players can't move...
	for p in players.iterate do
		if p.P_party == n
			PLAY_nomove(p)
		end
	end

end)

COM_AddCommand("d_getexp", function(p, arg)
	BTL_getEXP(1, tonumber(arg))
end)

-- Normalize enemy positions to defaults
-- [flip]: Adds 180 to the angle
-- [dist]: Sets distance to spawn from center, default is 256
--	[tp]:	If true, instantly teleports the entities, otherwise only resets the default coords

rawset(_G, "BTL_normalizePositions", function(t, flip, dist, tp)

	assert(t, "No table")
	local a
	for i = 1, #t
		local mo = t[i]

		assert(mo, "mo invalid")
		local btl = server.P_BattleStatus[mo.battlen]
		assert(btl, "no ongoing battle")

		local cx = btl.arena_coords[1]
		local cy = btl.arena_coords[2]
		local cz = btl.arena_coords[3]
		local ca = btl.arena_coords[4]
		if a == nil
			a = ca
			if flip
				a = $+ ANG1*180
			end
		end

		dist = $ or 256	-- default
		local x = cx + dist*cos(a)
		local y = cy + dist*sin(a)
		local z = cz

		if tp
			P_TeleportMove(mo, x, y, z)
			mo.angle = a + ANG1*180
		end

		mo.defaultcoords = {x, y, z, a + ANG1*180}


		a = $ - ANG1*30
	end

end)

-- Spawns a new 't' enemy type on mobj_t source's team
-- returns the spawned enemy
-- [boolean prev]: (optional) if set, the entity will be added before the source in the table.
-- [fixed_t x, y, z]: (optional) set spawning coordinates
-- [INT addang]: (optional, ignored if x,y,z set): Angle to spawn from compared to the main target

-- /!\ Returns nil if 5 or more enemies are already present on the field!

rawset(_G, "BTL_spawnEnemy", function(source, t, prev, x, y, z, addang)

	assert(source, "No source")
	assert(t, "No enemy type")
	assert(enemyList[t], "Invalid enemy type")

	local btl = server.P_BattleStatus[source.battlen]
	assert(btl, "No battle in progress for source "..tostring(source))

	if #source.allies > 4	-- max # of enemies already!!
		return nil	-- Don't error, but return nil.
	end


	-- step 1: Get the coordinates at which we are meant to spawn it:
/*
		battleStatus.arena_coords[1] = battleStatus.arenacenter.x
		battleStatus.arena_coords[2] = battleStatus.arenacenter.y
		battleStatus.arena_coords[3] = battleStatus.arenacenter.z
		battleStatus.arena_coords[4] = battleStatus.arenacenter.angle
*/

	-- get ang and dist:
	local mo = source	-- cbf to change the copypasted code lol
	local ang

	if x == nil or y == nil or z == nil

		local cx = btl.arena_coords[1]
		local cy = btl.arena_coords[2]
		local cz = btl.arena_coords[3]
		local b_ang = btl.arena_coords[4]

		ang = R_PointToAngle2(cx, cy, mo.x, mo.y)
		local dist = R_PointToDist2(cx, cy, mo.x, mo.y)/FRACUNIT

		local cycle = 1

		if prev

			-- how many are BEFORE me?
			for i = 1, #mo.allies
				local mo2 = mo.allies[i]
				if mo2 == mo
					break
				end

				cycle = $+1
			end

			ang = $ + ANG1*(addang or 30)*cycle
		else
			-- find how many entities are after me:
			local found
			for i = 1, #mo.allies
				local mo2 = mo.allies[i]
				if mo2 == mo
					found = true
				elseif found
					cycle = $+1
				end
			end

			ang = $ - ANG1*(addang or 30)*cycle	-- that's how it works in enemy spawning code by default
		end

		x = cx + dist*cos(ang)
		y = cy + dist*sin(ang)
		z = mo.z
	end

	local enm = P_SpawnMobj(x, y, z, MT_PFIGHTER)
	-- enemy spawned, now we need to initialize it.
	enm.state = S_PLAY_STND
	enm.tics = -1
	enm.enemy = t

	enm.battlen = source.battlen	-- save which arena we're on

	BTL_initEnemy(enm)	-- this is likely to be the case unless we're in pvp.

	local allies = copyTable(mo.allies)	-- so that we don't fuck things up:

	if not prev

		--print(allies[1].allies[1].name)

		for i = 1, #allies
			local e = allies[i]
			if not e.allies
				break	-- shouldn't happen.
			end
			-- Update my entire team worth of allies
			e.allies[#e.allies+1] = enm
			e.allies_noupdate[#e.allies_noupdate+1] = enm
		end
	else
		-- things are slightly more annoying in that case...........
		for k, e in ipairs(allies)
			-- Update my entire team worth of allies
			local t = {enm}

			if not e.allies
				break	-- shouldn't happen.
			end

			for i = 1, #e.allies
				t[i+1] = e.allies[i]
			end

			e.allies = copyTable(t)

			t = {enm}
			for i = 1, #e.allies_noupdate
				t[i+1] = e.allies_noupdate[i]
			end

			e.allies_noupdate = copyTable(t)
		end
	end

	-- update our enemies..
	for i = 1, #mo.enemies_noupdate
		local e = mo.enemies_noupdate[i]

		e.enemies = copyTable(mo.allies)
		e.enemies_noupdate = copyTable(mo.allies_noupdate)
	end

	btl.fighters[#btl.fighters+1] = enm	-- add enemy to the fighters list

	enm.enemies = copyTable(mo.enemies)
	enm.enemies_noupdate = copyTable(mo.enemies_noupdate)	-- this table doesn't update, we use it for reviving
	enm.allies = copyTable(source.allies)
	enm.allies_noupdate = copyTable(source.allies_noupdate)

	enm.saveskills = copyTable(enm.skills)	-- you never know
	enm.savestats = {enm.strength, enm.magic, enm.endurance, enm.agility, enm.luck}	-- back up stats
	BTL_initAdditionalSkills(enm)
	BTL_splitSkills(enm)
	BTL_setupstats(enm)
	BTL_initEnemyAggro(enm)

	enm.scale = enm.escale
	enm.shadowscale = enm.escale
	if ang
		enm.angle = ang + ANG1*180
	else
		enm.angle = source.angle
	end
	ANIM_set(enm, enm.anim_stand, true)

	return enm

end)

-- Spawns a new 't' skin type in the player party #pa
-- returns the spawned player object
-- [fixed_t x, y, z]: (optional) set spawning coordinates
-- [INT addang]: (optional, ignored if x,y,z set): Angle to spawn from compared to the main target

-- /!\ Returns nil if 5 or more players are already present on the field!

rawset(_G, "BTL_spawnPlayer", function(source, pa, t, x, y, z, addang)
	assert(source, "No source")
	assert(t, "No skin")
	assert(server.plentities[pa], "Invalid party #")
	assert(charStats[t], "Invalid skin definition")

	local btl = server.P_BattleStatus[source.battlen]
	assert(btl, "No battle in progress for source "..tostring(source))

	if #source.allies > 4	-- max # of enemies already!!
		return nil	-- Don't error, but return nil.
	end

	local running = btl.running


	-- step 1: Get the coordinates at which we are meant to spawn it:
/*
		battleStatus.arena_coords[1] = battleStatus.arenacenter.x
		battleStatus.arena_coords[2] = battleStatus.arenacenter.y
		battleStatus.arena_coords[3] = battleStatus.arenacenter.z
		battleStatus.arena_coords[4] = battleStatus.arenacenter.angle
*/

	-- get ang and dist:
	local mo = source	-- cbf to change the copypasted code lol
	local ang

	if x == nil or y == nil or z == nil

		local cx = btl.arena_coords[1]
		local cy = btl.arena_coords[2]
		local cz = btl.arena_coords[3]
		local b_ang = btl.arena_coords[4]

		ang = R_PointToAngle2(cx, cy, mo.x, mo.y)
		local dist = R_PointToDist2(cx, cy, mo.x, mo.y)/FRACUNIT

		local cycle = 1

		-- find how many entities are after me:
		local found
		for i = 1, #mo.allies
			local mo2 = mo.allies[i]
			if mo2 == mo
				found = true
			elseif found
				cycle = $+1
			end
		end

		ang = $ - ANG1*(addang or 30)*cycle	-- that's how it works in enemy spawning code by default

		x = cx + dist*cos(ang)
		y = cy + dist*sin(ang)
		z = mo.z
	end

	local nmo = PLYR_makePlayer(t, pa, #server.plentities[pa] +1)
	P_TeleportMove(nmo, x, y, z)

	local allies = copyTable(mo.allies)	-- so that we don't fuck things up:

	for i = 1, #allies
		local e = allies[i]
		if not e.allies
			break	-- shouldn't happen.
		end
		-- Update my entire team worth of allies
		e.allies[#e.allies+1] = nmo
		e.allies_noupdate[#e.allies_noupdate+1] = nmo
	end

	-- update our enemies..
	for i = 1, #mo.enemies_noupdate
		local e = mo.enemies_noupdate[i]

		e.enemies = copyTable(mo.allies)
		e.enemies_noupdate = copyTable(mo.allies_noupdate)
	end

	btl.fighters[#btl.fighters+1] = nmo	-- add enemy to the fighters list

	nmo.enemies = copyTable(mo.enemies)
	nmo.enemies_noupdate = copyTable(mo.enemies_noupdate)	-- this table doesn't update, we use it for reviving
	nmo.allies = copyTable(source.allies)
	nmo.allies_noupdate = copyTable(source.allies_noupdate)

	nmo.saveskills = copyTable(nmo.skills)	-- you never know
	nmo.savestats = {nmo.strength, nmo.magic, nmo.endurance, nmo.agility, nmo.luck}	-- back up stats

	-- setup default coordinates
	nmo.defaultcoords = {nmo.x, nmo.y, nmo.z, nmo.angle}

	BTL_initAdditionalSkills(nmo)
	BTL_splitSkills(nmo)
	BTL_setupstats(nmo)

	if ang
		nmo.angle = ang + ANG1*180
	else
		nmo.angle = source.angle
	end
	ANIM_set(nmo, nmo.anim_stand, true)

	return nmo
end)

-- Change the current enemy to a new type of enemy, reseting all of its stats
rawset(_G, "BTL_changeEnemy", function(enm, new)

	assert(enemyList[new], "Enemy "..new.." does not exist.")

	enm.enemy = new
	BTL_initEnemy(enm)

	enm.saveskills = copyTable(enm.skills)	-- you never know
	enm.savestats = {enm.strength, enm.magic, enm.endurance, enm.agility, enm.luck}	-- back up stats
	BTL_initAdditionalSkills(enm)
	BTL_splitSkills(enm)
	BTL_setupstats(enm)

	enm.scale = enm.escale
	enm.shadowscale = enm.escale
	ANIM_set(enm, enm.anim_stand, true)

end)

-- returns true if mo has a status that would prevent all out attacks
rawset(_G, "BTL_noAOAStatus", function(mo)

	if mo.status_conditon == COND_SHOCK
	or mo.status_conditon == COND_SLEEP
	or mo.status_condition == COND_FREEZE
	or mo.status_condition == COND_BRAINWASH
	--or mo.status_condition == COND_HEX
	or mo.down
		return true
	else
		return false
	end
end)

/*
	BTL_start()

	Starts a battle.
	This spawns the necessary entities to prepare the battle and apropriatly sets their necessary properties.
	BTL_startBattle() is then called by using the entities.

	party: 		Party # to start the battle for
	wave: 		Enemy wave to spawn
	music: 		Music to use
	avd:		Advantage: (0 = none, 1 = player, 2 = enemy)
	func:		battle func (Only for singleplayer!!!!)
	allowboss:	If true, bosses that end the session can spawn
	norun:		If true, the battle cannot be run away from

*/
rawset(_G, "BTL_start", function(party, wave, adv, mus, func, allowboss, norun, boss)

	local fboss

	local team_1 = server.plentities[party]
	if not team_1[1]	-- SORRY NOTHING
		return
	end

	local team_2 = {}
	for i = 1,#wave
		local enm = P_SpawnMobj(0, 0, 0, MT_PFIGHTER)
		enm.state = S_PLAY_STND
		enm.tics = -1
		enm.enemy = wave[i]
		if enemyList[wave[i]].endboss
		and allowboss
			fboss = true
		end
		team_2[#team_2+1] = enm
	end

	if boss	--norun or adv == 2
		server.P_BattleStatus[party].boss = true	-- make sure we can't run away etc etc
	end

	--local mus = MUS_PlayRandomBattleMusic("mus_battle_mb")
	if fboss
	and gamemap == srb2p.tartarus_play
	--and netgame
	--and not mus
		if server.difficulty <= 2
			mus = "BOSS1"
		elseif server.difficulty <= 4
			mus = "BOSS2"
		else
			mus = "BOSS3"
		end

		if server.difficulty == 6
			mus = "MBOSSB"
		end

	end

	BTL_StartBattle(party, team_1, team_2, adv or 0, func, mus)
end)


-- Updates battle arena center in accordance to the section
rawset(_G, "BTL_updateArenaCenter", function()
	for mt in mapthings.iterate do
		local m = mt.mobj

		for s = 1, server.P_DungeonStatus.section	-- try and find whatever works with the section we have.

			if m and m.valid and m.type == MT_BOSS3WAYPOINT and mt.extrainfo == s

				for i = 1, 4
					local btl = server.P_BattleStatus[i]
					local shiftx = (mapheaderinfo[gamemap].arenashiftx or 0)*FRACUNIT *(i-1)
					local shifty = (mapheaderinfo[gamemap].arenashifty or 0)*FRACUNIT *(i-1)
					local t = P_SpawnMobj(m.x+shiftx, m.y+shifty, m.z, MT_THOK)
					t.state = S_INVISIBLE
					t.angle = m.angle

					-- free current center mobj
					if btl.arenacenter and btl.arenacenter.valid
						P_RemoveMobj(btl.arenacenter)
					end

					btl.arenacenter = t
				end
			end
		end
	end
end)

-- SHUFFLE TIME MULTIPLIERS:
freeslot("SPR_COIC", "SPR_WNDC", "SPR_SRDC", "SPR_CUPC")

-- % (100 = x 1.0)

rawset(_G, "BTL_shuffleMultiplier_EXP", {

	104,	-- 1: 104%
	108,
	112,
	116,
	120,
	124,
	128,
	135,
	142,
	150,
})

rawset(_G, "BTL_shuffleMultiplier_money", {

	110,	-- 1: 104%
	114,
	118,
	122,
	126,
	130,
	135,
	140,
	155,
	180,
})

-- Cup healing: Heals value% HP and value/3% SP
rawset(_G, "BTL_shuffleCupHeal", {
	5,
	7,
	9,
	11,
	13,
	15,
	17,
	19,
	22,
	25,
})

-- LINK_BREEZE healing: Heals value1% HP and value2%hp
rawset(_G, "BTL_victoryBreezeHeal", {
  {5, 5},
  {7, 6},
  {10, 7},
})
