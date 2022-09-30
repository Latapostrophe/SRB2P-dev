-- Attack functions

-- damage type constants:
local dmg_type_consts = {
	"DMG_NORMAL",
	"DMG_WEAK",
	"DMG_CRITICAL",
	"DMG_TECHNICAL",
	"DMG_RESIST",
	"DMG_BLOCK",
	"DMG_REPEL",
	"DMG_DRAIN",
	"DMG_MISS",		-- do NOT set this in getDamage, only in damageObject, or it will mess with multi hit attacks
	"DMG_STATUS",	-- for status only attacks
}

for i = 1, #dmg_type_consts
	rawset(_G, dmg_type_consts[i], i-1)
end

rawset(_G, "ATK_getSkillCost", function(mo, skl)

	local cost = 0
	if skl.costtype == CST_HP
	or skl.costtype == CST_SP
		cost = skl.cost
	elseif skl.costtype == CST_HPPERCENT
		cost = mo.hp*skl.cost/100
	elseif skl.costtype == CST_SP
		cost = mo.sp*skl.cost/100
	elseif skl.costtype == CST_EP
		cost = skl.cost*100
	end

	-- outside of battle, passiveskills don't exist.
	if mo.passiveskills
		for i = 1, #mo.passiveskills
			local skl = mo.passiveskills[i]
			if attackDefs[skl]
			and attackDefs[skl].passive == PSV_SKILLCOST
				cost = attackDefs[skl].anim(mo, skl, cost) or $
			end
		end
	else
		local skls = copyTable(mo.skills)
		if mo.skillcard
			skls[#skls+1] = mo.skillcard
		end

		for i = 1, #skls
			local skl = skls[i]
			if attackDefs[skl]
			and attackDefs[skl].passive == PSV_SKILLCOST
				cost = attackDefs[skl].anim(mo, skl, cost) or $
			end
		end
	end

	return max(0, cost)
end)

-- get random drops from enemies
rawset(_G, "getRandomDrops", function(mo)
	--print("get random drops...")
	local btl = server.P_BattleStatus[mo.battlen]
	if server.gamemode == GM_CHALLENGE return end	-- nope

	local tbl = server.items
	local newtable = {}

	local maxrarity = 0

	if tbl
		for k,v in ipairs(tbl)
			for j = 1, v[2]
				newtable[#newtable+1] = v[1]
			end
		end

		-- 25% chance to obtain random drop item 3 times

		for i = 1, 3
			if P_RandomRange(0, 100) <= 40
				--print("Get drop")
				local rng = P_RandomRange(1, #newtable)	-- rng seed
				local it = newtable[rng]
				local rare

				-- check if item is a weapon / ring / weapon series
				if type(it) == "table"
					if it[1] == "series"
						local wpn = dropWeaponFromSeries(it[2], server.plentities[mo.battlen])
						wpn = makeWeapon(wpn, P_RandomRange(0, 3))

						maxrarity = max($, wpn.rarity)
						btl.r_weapons = $ or {}

						btl.r_weapons[#btl.r_weapons+1] = wpn
						spawnWeaponDrop(wpn, mo.x, mo.y, mo.z)

					elseif it[1] == "ring"
						local ring = it[2]

						if ring
							btl.r_rings = $ or {}
							btl.r_rings[#btl.r_rings+1] = makeRing(ring, P_RandomRange(0, 3))
							maxrarity = max($, btl.r_rings[#btl.r_rings].rarity)
							spawnRingDrop(btl.r_rings[#btl.r_rings], mo.x, mo.y, mo.z)
						end

					elseif it[1] == "weapon"
						local wpn = it[2]
						wpn = makeWeapon(wpn)

						if wpn
							btl.r_weapons = $ or {}
							btl.r_weapons[#btl.r_weapons+1] = makeWeapon(wpn, P_RandomRange(0, 3))
							maxrarity = max($, btl.r_weapons[#btl.r_weapons].rarity)
							spawnWeaponDrop(btl.r_weapons[#btl.r_weapons], mo.x, mo.y, mo.z)
						end
					end

					--[[if rare
						for p in players.iterate
							if p and p.control and p.control.valid and p.control.battlen == mo.battlen
								IT_startRareDropAnim(p)
							end
						end
					end--]]

					continue
				end

				if itemDefs[it] and itemDefs[it].rarity
					maxrarity = max($, itemDefs[it].rarity)
					--[[for p in players.iterate
						if p and p.control and p.control.valid and p.control.battlen == mo.battlen
							IT_startRareDropAnim(p)
						end
					end--]]
				end

				spawnItemDrop(itemDefs[it], mo.x, mo.y, mo.z)
				BTL_addResultItem(btl, it, 1)
			end
		end
	end

	-- enemy specific drops all have their own odds rolled.
	local enemy = enemyList[mo.enemy]
	if enemy.r_drops and #enemy.r_drops

		for i = 1, #enemy.r_drops

			if P_RandomRange(0, 100) < enemy.r_drops[i][2]
				local it = enemy.r_drops[i][1]
				local rare
				-- check if item is a weapon / ring / weapon series
				if type(it) == "table"
					if it[1] == "series"
						local wpn = dropWeaponFromSeries(it[2], server.plentities[mo.battlen])
						wpn = makeWeapon(wpn, P_RandomRange(0, 3))

						maxrarity = max($, wpn.rarity)
						btl.r_weapons = $ or {}

						btl.r_weapons[#btl.r_weapons+1] = wpn
						spawnWeaponDrop(wpn, mo.x, mo.y, mo.z)

					elseif it[1] == "ring"
						local ring = it[2]

						if ring
							btl.r_rings = $ or {}
							btl.r_rings[#btl.r_rings+1] = makeRing(ring, P_RandomRange(0, 3))
							maxrarity = max($, btl.r_rings[#btl.r_rings].rarity)
							spawnRingDrop(btl.r_rings[#btl.r_rings], mo.x, mo.y, mo.z)
						end

					elseif it[1] == "weapon"
						local wpn = it[2]
						wpn = makeWeapon(wpn)

						if wpn
							btl.r_weapons = $ or {}
							btl.r_weapons[#btl.r_weapons+1] = makeWeapon(wpn, P_RandomRange(0, 3))
							maxrarity = max($, btl.r_weapons[#btl.r_weapons].rarity)
							spawnWeaponDrop(btl.r_weapons[#btl.r_weapons], mo.x, mo.y, mo.z)
						end
					end

					--[[if rare
						for p in players.iterate
							if p and p.control and p.control.valid and p.control.battlen == mo.battlen
								IT_startRareDropAnim(p)
							end
						end
					end--]]

					continue
				end

				if itemDefs[it] and itemDefs[it].rarity
					maxrarity = max($, itemDefs[it].rarity)
					--[[for p in players.iterate
						if p and p.control and p.control.valid and p.control.battlen == mo.battlen
							IT_startRareDropAnim(p)
						end
					end--]]
				end

				spawnItemDrop(itemDefs[it], mo.x, mo.y, mo.z)
				BTL_addResultItem(btl, it, 1)
			end
		end
	end

	if maxrarity >= 5
		for p in players.iterate
			if p and p.control and p.control.valid and p.control.battlen == mo.battlen
				IT_startRareDropAnim(p, maxrarity)
			end
		end
	end
end)

-- Random Skills
rawset(_G, "getRandMove", function(mo, restrict, passives)
	local skills = {}
	for k,v in pairs(attackDefs)
		if passives
			if restrict

				if not v.norandom
				-- Validation
				and v.type
				and v.target
				and v.costtype
				and not v.nometronome
					table.insert(skills, k)
				end
			else
				table.insert(skills, k)
			end
		else
			if restrict
				if not v.norandom
				-- Validation
				and v.type
				and v.target
				and v.costtype
				and not v.passive
				and not v.nometronome
					table.insert(skills, k)
				end
			else
				if not v.passive
				and not v.nometronome
				and v.anim

				-- attack specific softlocks
				and not v.physical
				and k ~= "nosp"
				and k ~= "analysis"
				and k ~= "full analysis"
					table.insert(skills, k)
				end
			end
		end
	end

	return skills[P_RandomRange(1, #skills)]
end)

-- damage flags mostly used for display
rawset(_G, "DF_HP", 1)
rawset(_G, "DF_SP", 2)

-- returns the real type of an attack
rawset(_G, "getAttackType", function(mo, attack)
	local t = attack.type
	if attack.physical and mo and mo.weapon and mo.weapon.element
		return mo.weapon.element
	end
	return t
end)

-- returns true if the attack is physical, false if magic
rawset(_G, "isAttackPhysical", function(atk)
	return atk.costtype == CST_HP or atk.costtype == CST_HPPERCENT or atk.physical
end)

-- returns true if the attack should be technical on mo
rawset(_G, "isAttackTechnical", function(mo, atk, t)
	local cond = mo.status_condition
	if not atk return 0 end	-- bruh!
	t = $ or atk.type

	if not cond return 0 end

	if atk.luckbased return 0 end	-- no!

	-- I really wish we had switch cases right about now

	if cond == COND_BURN	-- Technical: wind / Nuke
		return (t == ATK_WIND or t == ATK_NUCLEAR)

	elseif cond == COND_FREEZE	-- Technical: Fire / Nuke
		return (t == ATK_FIRE or t == ATK_NUCLEAR or isAttackPhysical(atk))

	elseif cond == COND_SHOCK	-- Technical: Nuke / Phys
		return (t == ATK_NUCLEAR or isAttackPhysical(atk))

	elseif cond == COND_BRAINWASH	-- Technical: Psy / Bless
		return (t == ATK_PSY or t == ATK_BLESS)

	elseif cond == COND_SLEEP		-- Technical: All
		return 1

	elseif cond == COND_DIZZY		-- Dizzy: Psy / Nuke / Elec
		return (t == ATK_PSY or t == ATK_NUCLEAR or t == ATK_ELEC)

	elseif cond == COND_HEX		-- Technical: Psy / Ice
		return (t == ATK_PSY or t == ATK_CURSE)

	elseif cond == COND_SILENCE		-- Technical: Psy
		return (t == ATK_PSY)

	elseif cond == COND_DESPAIR		-- Technical: Psy / Curse
		return (t == ATK_PSY or t == ATK_CURSE)

	elseif cond == COND_RAGE		-- Technical: Psy / Nuke
		return (t == ATK_PSY or t == ATK_NUCLEAR)

	elseif cond == COND_HUNGER		-- Technical: Nuke
		return (t == ATK_NUCLEAR)

	elseif cond == COND_POISON		-- Technical: Nuke / Pierce / Slash
		return (t == ATK_NUCLEAR or t == ATK_PIERCE or t == ATK_SLASH)
	end
end)

-- isWeak(e, a) returns the attack affinity of 'mo' towards the attack 'atk'
rawset(_G, "getAttackAff", function(mo, atk, attacker)

	if not atk return end
	local atktype = getAttackType(attacker, atk)

	-- element resist/weakness buffs/debuffs
	local buff = mo.buffs[atktype] and mo.buffs[atktype][1] and mo.buffs[atktype][1] > 0
	local debuff = mo.buffs[atktype] and mo.buffs[atktype][1] and mo.buffs[atktype][1] < 0

	-- if mo is super, then blcok it unless it's almighty.
	if mo.status_condition == COND_SUPER and atk.type ~= ATK_ALMIGHTY
		return DMG_BLOCK
	end

	-- check for tetrakarns and whatnot...~
	if isAttackPhysical(atk) and mo.tetrakarn
	or not isAttackPhysical(atk) and mo.makarakarn

		if atk.target ~= TGT_ALLY and atk.target ~= TGT_ALLALLIES
		and atktype ~= ATK_ALMIGHTY	-- fuck repels
		and not atk.norepel	-- prevents repel altogether
			return DMG_REPEL
		end
	end

	if mo.tetraja and atk.instakill	-- tetraja blocks any instant kills
	and atktype ~= ATK_ALMIGHTY	-- (but not almighty)
		return DMG_BLOCK
	end

	-- Technical damage bypasses all affinities besides weak!
	local technical = isAttackTechnical(mo, atk, atktype)
	debuff = $ or technical	-- this counts, too


	-- check if our passive skills block the attack
	for i = 1, #mo.passiveskills
		local psv = mo.passiveskills[i]
		if attackDefs[psv]
			psv = attackDefs[$]
			if psv.type & atktype

				if psv.passive == PSV_BLOCK and not debuff
					return DMG_BLOCK
				elseif psv.passive == PSV_REPEL and not debuff and not (psv.accuracy and psv.accuracy < 100)	-- chance repels don't count!
					return DMG_REPEL
				elseif psv.passive == PSV_RESIST and not debuff
					return DMG_RESIST
				elseif psv.passive == PSV_DRAIN and not debuff
					return DMG_DRAIN
				end
			end
		end
	end

	-- very special case.
	if mo.guard
		--return DMG_RESIST
		buff = true	-- yes!
	end

	-- for technicals:
	if technical and not ((mo.weak & atktype) and not buff)
		return DMG_TECHNICAL
	end

	-- maybe check here for elemental barriers etc
	-- return DMG_RESIST for those

	-- now we check for real affinities
	if mo.drain & atktype and not debuff
		return DMG_DRAIN	-- drain, top priority
	elseif mo.repel & atktype and not debuff
		return DMG_REPEL	-- repel, 2nd priority
	elseif mo.block & atktype and not debuff
		return DMG_BLOCK
	elseif mo.resist & atktype and not debuff
		return DMG_RESIST
	elseif mo.weak & atktype and not buff
		return DMG_WEAK
	end

	return DMG_NORMAL	-- welp I guess there's nothing then :shrug: !
end)

-- fills the emerald gauge.
-- bypass allows to fill even when the buffer has been activated
rawset(_G, "fillEmeraldGauge", function(mo, amount, bypass)
	local btl = server.P_BattleStatus[mo.battlen]

	-- divide?
	local div = 1
	if not bypass
		for i = 1, #mo.allies
			if mo.allies[i] and mo.allies[i].status_condition == COND_HYPER
				div = $+1
			end
		end
	else
		for i = 1, #mo.allies
			if mo.allies[i] and mo.allies[i].status_condition == COND_SUPER	--!
				return	-- super prevents all fixed bypasses
			end
		end
	end

	amount = $/div

	if btl.emeraldpow_max
		amount = max(0, $)
		btl.emeraldpow = min(btl.emeraldpow_max*100, $+amount)
	end
end)

rawset(_G, "revivePlayer", function(mo)

	local btl = server.P_BattleStatus[mo.battlen]

	btl.netstats.timesrevived = $+1
	mo.down = nil
	mo.flags2 = $ & ~MF2_DONTDRAW

	local newparty = {}
	for k,v in ipairs(mo.allies_noupdate)
		if v.hp or v == mo	-- we're getting revived too.
			newparty[#newparty+1] = v
		end
	end

	-- apply newparty as our allies and as our enemies' enemies.
	for k,v in ipairs(mo.allies_noupdate)
		if not v or not v.valid continue end
		v.allies = copyTable(newparty)
	end
	for k,v in ipairs(mo.enemies_noupdate)
		if not v or not v.valid continue end
		v.enemies = copyTable(newparty)
	end

	-- add ourselves back to btl.fighters
	table.insert(btl.fighters, mo)
end)

local buffmsg = {
	[ATK_STRIKE] = "Strike resistance",
	[ATK_SLASH] = "Slash resistance",
	[ATK_PIERCE] = "Pierce resistance",

	[ATK_FIRE] = "Fire resistance",
	[ATK_ICE] = "Ice resistance",
	[ATK_ELEC] = "Elec resistance",
	[ATK_WIND] = "Wind resistance",
	[ATK_PSY] = "Psy resistance",
	[ATK_NUCLEAR] = "Nuke resistance",

	[ATK_CURSE] = "Curse resistance",
	[ATK_BLESS] = "Bless resistance",

	[ATK_ALMIGHTY] = "Almighty resistance",	-- !?

	["atk"] = "Physical Attack",
	["mag"] = "Magic Attack",
	["def"] = "Defence",
	["agi"] = "Agility",
	["crit"] = "Critical Rate",
}

rawset(_G, "buffStat", function(mo, stat, value, turn)

	if value == nil then value = BUFFSTEP end
	if type(stat) == "number" and turn == nil then turn = 3 end
	if not stat return end

	if value < 0
		VFX_Play(mo, VFX_MISS)
	elseif value > 0
		VFX_Play(mo, VFX_HEALSELF)
	end

	local name = buffmsg[stat]
	local msg = ""
	local msgend = ""
	if value > 0
		msg = " up"
		msgend = "!"
	else
		msg = " down"
		msgend = "!"
	end

	local resetstat = mo.buffs[stat][1] + value == 0
	if resetstat
		msg = " reverted"
	end	-- reset the stat if it was lowered before buff or increased before debuff

	mo.buffs[stat][1] = min(BUFFSTEP*MAXBUFFS, $+value)
	mo.buffs[stat][1] = max(-BUFFSTEP*MAXBUFFS, $)
	if mo.buffs[stat][1] >= BUFFSTEP*MAXBUFFS
		msg = " maxed out"	-- 75% is the max buff
	elseif mo.buffs[stat][1] <= -BUFFSTEP*MAXBUFFS
		msg = " minimized"	-- -75% is the max debuff
	end

	if turn
		if not resetstat
			if mo.buffs[stat][2] >= 9
				msg = "Limit reached!"
				name = ""
				msgend = ""
			elseif mo.buffs[stat][2]
				msgend = " extended!"
			end
			mo.buffs[stat][2] = min(9, $+turn)
		else
			mo.buffs[stat][2] = 0
		end
	end
	-- Still used by Break skills

	BTL_logMessage(mo.battlen, name..msg..msgend)
end)

local statusmessage = {
	[COND_BURN] = "burn",
	[COND_FREEZE] = "freeze",
	[COND_SHOCK] = "shock",
	[COND_BRAINWASH] = "brainwash",
	[COND_DIZZY] = "dizziness",
	[COND_SILENCE] = "silence",
	[COND_SLEEP] = "sleep",
	[COND_HEX] = "hex",
	[COND_DESPAIR] = "despair",
	[COND_RAGE] = "rage",
	[COND_POISON] = "poison",
	[COND_HUNGER] = "hunger"
}

rawset(_G, "ATK_statusfuncs", {

	[COND_HUNGER] = function(mo)
						mo.strength = $/2
						mo.magic = $/2
						mo.endurance = $/2
						mo.agility = $/2
						mo.luck = $/2
					end,

	[COND_SILENCE] = function(mo)
						mo.commandflags = $ or 0
						mo.commandflags = $|CDENY_SKILL|CDENY_PERSONA|CDENY_TACTICS
					end,

	[COND_FREEZE] = function(mo)

						local btl = server.P_BattleStatus[mo.battlen]
						local foundturn = 0
						local i = #btl.turnorder
						while i
							if i ~= 1	-- do NOT remove the turn if we're currently acting, this creates very weird things!
							and btl.turnorder[i] == mo
								foundturn = $+1
								table.remove(btl.turnorder, i)
							end

							i = $-1
						end

						for i = 1, foundturn
							table.insert(btl.turnorder, mo)	-- insert at the end
						end

					end,
}
)

-- boss resistance gained per status
-- 1 res = 2% substracted
-- res goes down by 2 each turn

rawset(_G, "ATK_res_per_status", {
	[COND_BURN] = 6,
	[COND_FREEZE] = 10,
	[COND_SHOCK] = 10,
	[COND_BRAINWASH] = 18,
	[COND_DIZZY] = 8,
	[COND_SILENCE] = 12,
	[COND_SLEEP] = 8,
	[COND_HEX] = 6,
	[COND_DESPAIR] = 6,
	[COND_RAGE] = 8,
	[COND_POISON] = 6,
	[COND_HUNGER] = 10,
})

rawset(_G, "inflictStatus", function(mo, status)
	--if 1 return end	-- DEBUG
	if not mo.status_condition	-- we can't be affected with a status if we already have one.
								-- this is checked beforehand, but JUST IN CASE.
		BTL_logMessage(mo.battlen, "Inflicted with "..statusmessage[status]..".")
		mo.status_condition = status
		mo.status_turns = 0		-- this counts up every turn when we have a status

		VFX_Play(mo, VFX_MISS)

		local btl = server.P_BattleStatus[mo.battlen]

		if mo.enemy
		and btl.dmg_actor
		and btl.dmg_actor.valid
			fillEmeraldGauge(btl.dmg_actor, (mo.fieldstate and mo.fieldstate.type == FLD_AGIVERSE) and 30 or 15)	-- 15%
		end

		if ATK_statusfuncs[status]
			ATK_statusfuncs[status](mo)
		end

		if mo.boss
			mo.status_res = $ and ($+ (ATK_res_per_status[status] or 1)) or 1
		end
	end
end)

rawset(_G, "ATK_curestatusfuncs", {
	[COND_SILENCE] = function(mo)
						mo.commandflags = $ or 0
						mo.commandflags = $ & ~(CDENY_SKILL|CDENY_PERSONA|CDENY_TACTICS)
					end,

	[COND_SHOCK] = 	function(mo)
						mo.flags2 = $ & ~MF2_DONTDRAW
					end,

	[COND_SUPER] =	function(mo)
						PLYR_resetColour(mo)
					end,
})

rawset(_G, "cureStatus", function(mo, msg)
	if not mo.status_condition return end
	if msg
		BTL_logMessage(mo.battlen, mo.name.."'s "..statusmessage[mo.status_condition].." wore off.")
	end
	if ATK_curestatusfuncs[mo.status_condition]
		ATK_curestatusfuncs[mo.status_condition](mo)
	end
	mo.status_condition = 0
	mo.status_turns = 0
end)

rawset(_G, "ATK_fieldStartFunc", {

	[FLD_GARUVERSE] = 	function(target)
							for i = 1, 4
								local g = P_SpawnMobj(target.x, target.y, target.z + P_RandomRange(0, 120)*FRACUNIT, MT_GARU)
								g.target = target
								g.angle = FixedAngle(P_RandomRange(1, 360)*FRACUNIT)
								if i%2
									g.invertrotation = true
								end
								g.dist = P_RandomRange(45, 140)
								--g.tics = 25
								g.lowquality = true

								g.battlen = target.battlen

								target.fieldstate.entities[#target.fieldstate.entities+1] = g
							end
						end,

})

rawset(_G, "startField", function(mo, field, turns)

	turns = $ or 3
	if not mo or not mo.valid return end
	if not field return end
	if not mo.hp return end	-- enemy died when trying to start the field

	local field_exist = mo.fieldstate ~= nil

	if field_exist
		clearField(mo)
	end

	mo.fieldstate = {
		type = field,
		turns = turns,
		entities = {},
	}

	if ATK_fieldStartFunc[field]
		ATK_fieldStartFunc[field](mo)
	end
end)

rawset(_G, "clearField", function(mo)
	if not mo or not mo.valid return end
	if not mo.fieldstate return end

	for i = 1, #mo.fieldstate.entities do
		mo.fieldstate.entities[i].fuse = 2
	end

	--print("Removed field state...")
	mo.fieldstate = nil
end)

rawset(_G, "createSplat", function(mo, size, sizespd, time)
	local splat = phud.create(mo.battlen, N_RandomRange(30, 300), N_RandomRange(0, 180), "SPLAT"..N_RandomRange(1, 2), time or N_RandomRange(30, 80))
	splat.scale = 1
	splat.flags = V_FLIP*(N_RandomRange(0, 1))
	splat.scalespeed = sizespd or FRACUNIT/3
	splat.destscale = size or FRACUNIT
	splat.splat = true
	splat.physics = false
end)

rawset(_G, "explodeShadow", function(target)
	if target.enemy
		local btl = server.P_BattleStatus[target.battlen]
		btl.saved_affs[target.enemy][3] = true	-- enemy was beaten, that means every subsequent type of this enemy can have its stats be displayed in analysis
	end

	for i=1,16
		local b = P_SpawnMobj(target.x, target.y, target.z+20*FRACUNIT, MT_DUMMY)
		b.momx = P_RandomRange(-15, 15)*FRACUNIT
		b.momy = P_RandomRange(-15, 15)*FRACUNIT
		b.momz = P_RandomRange(-15, 15)*FRACUNIT
		b.frame = A
		b.color = SKINCOLOR_RED
		b.scale = FRACUNIT/2
		b.destscale = FRACUNIT/12
	end

	for i=1,16
		local b = P_SpawnMobj(target.x, target.y, target.z+20*FRACUNIT, MT_DUMMY)
		b.momx = P_RandomRange(-15, 15)*FRACUNIT
		b.momy = P_RandomRange(-15, 15)*FRACUNIT
		b.momz = P_RandomRange(-15, 15)*FRACUNIT
		b.frame = A
		b.color = SKINCOLOR_BLACK
		b.scale = FRACUNIT/2
		b.destscale = FRACUNIT/12
	end
end)

local function explodeShadowBig(target)
	if target.enemy
		local btl = server.P_BattleStatus[target.battlen]
		btl.saved_affs[target.enemy][3] = true	-- enemy was beaten, that means every subsequent type of this enemy can have its stats be displayed in analysis
	end

	for i=1,64
		local b = P_SpawnMobj(target.x, target.y, target.z+20*FRACUNIT, MT_DUMMY)
		b.momx = P_RandomRange(-48, 48)*FRACUNIT
		b.momy = P_RandomRange(-48, 48)*FRACUNIT
		b.momz = P_RandomRange(-48, 48)*FRACUNIT
		b.frame = A
		b.color = SKINCOLOR_RED
		b.scale = FRACUNIT
		b.destscale = FRACUNIT/12
		b.tics = TICRATE*2
	end

	for i=1,64
		local b = P_SpawnMobj(target.x, target.y, target.z+20*FRACUNIT, MT_DUMMY)
		b.momx = P_RandomRange(-48, 48)*FRACUNIT
		b.momy = P_RandomRange(-48, 48)*FRACUNIT
		b.momz = P_RandomRange(-48, 48)*FRACUNIT
		b.frame = A
		b.color = SKINCOLOR_BLACK
		b.scale = FRACUNIT
		b.destscale = FRACUNIT/12
		b.tics = TICRATE*2
	end

	for i=1,512
		local b = P_SpawnMobj(target.x, target.y, target.z+20*FRACUNIT, MT_DUMMY)
		b.momx = P_RandomRange(-16, 16)*FRACUNIT
		b.momy = P_RandomRange(-16, 16)*FRACUNIT
		b.momz = P_RandomRange(0, 48)*FRACUNIT
		b.frame = A
		b.tics = -1
		b.color = i%2 and SKINCOLOR_RED or SKINCOLOR_BLACK
		b.scale = FRACUNIT/2
		b.scale = FRACUNIT*3/4
		b.destscale = 1
		b.tics = TICRATE*4
		b.flags = MF_NOCLIPHEIGHT
	end

	for i = 1, 8
		createSplat(target)
	end
end

-- resets all the necessary variables to make damage work properly
rawset(_G, "resetDamage", function(mo)

	mo.endure = $ or 0				-- endure timer
	mo.damagestate = DMG_NORMAL		-- damage state

	mo.crituptheass = 0				-- critical damage
	mo.crituptheass2 = 0			-- critcal damage timer 2
	mo.sicktech = 0					-- technical damage timer (unused for now)

	mo.damaged = 0
	mo.damagetaken = 0
	mo.spdamagetaken = 0
	mo.damage_wait = 0
	mo.damageflags = 0
	mo.damagetype = 0
	mo.repelto = 0
	mo.cachestatus = 0
	mo.humonculus = 0
	mo.endured = 0
	mo.hudpop = 0
	mo.passivedodge = nil
end)

-- Use the damage formula to check how much damage we've done to mo.
-- used to precalculate damage in BS_ACTION
rawset(_G, "getDamage", function(mo, attacker, forcedamage, accuracy)

	local btl = server.P_BattleStatus[mo.battlen]

	mo.damagestate = getAttackAff(mo, attacker.attack, attacker)	-- this does the work for us! woo!
	-- though we still have misses and other stuff to compute, so don't get too cocky

	mo.endure = $ or 0	-- ready endure skill counter

	mo.atk_attacker = attacker

	if mo.damagestate == DMG_BLOCK
		return 0, nil
	end

	local atk = attacker.attack
	local atktype = getAttackType(attacker, atk)

	-- luck based status attack:

	if mo.guaranteedevasion
		-- Not my problem
		return "miss", false
	end

	if accuracy	-- accuracy checks

		if atk.luckbased and atk.statuschance and atk.status

			local statusbuff = 0
			for i = 1, #attacker.passiveskills do
				if attackDefs[attacker.passiveskills[i]]
					local skl = attackDefs[attacker.passiveskills[i]]
					if skl.passive == PSV_COND_BOOST
					and (atk.status and (not skl.status) or skl.status & atk.status)
						statusbuff = max($, skl.power)
						--print("Status chance buff "..statusbuff)
					end
				end
			end

			local bossres = (mo.status_res or 0)*4
			local status_hitrate = atk.statuschance + statusbuff + (attacker.luck - mo.luck)*3/4 - bossres
			local status_resist_mult = 0

			-- Check for status resistances within the target
			for i = 1, #mo.passiveskills do
				if attackDefs[mo.passiveskills[i]]
					local skl = attackDefs[mo.passiveskills[i]]
					if skl.passive == PSV_COND_RESIST
					and (atk.status and (not skl.status) or skl.status & atk.status)
						status_resist_mult = max($, skl.power)
					end
				end
			end

			-- Final hitrate for statuses becomes: (BASE HITRATE + (ATTACKER AGILITY - RECEIVER AGILITY)*3/4 - BOSS RESISTANCE + STATUS BOOST)/RESISTANCE
			status_hitrate = $ - ($*status_resist_mult/100)

			if (P_RandomRange(0, 100) <= status_hitrate)
			and not mo.status_condition	-- can't status again if we already got that
			--and not mo.boss
				mo.cachestatus = atk.status
				mo.damagestate = DMG_STATUS
				return 0, nil
			else
				--mo.damagestate = DMG_MISS
				return "miss", false
			end
		end
	else	-- we can assume the attack landed
		if atk.luckbased and atk.statuschance and atk.status
			if not mo.status_condition
			--and not mo.boss
				mo.cachestatus = atk.status
				mo.damagestate = DMG_STATUS
			else
				--mo.damagestate = DMG_MISS
				return "miss", false
			end
		end
	end

	if forcedamage then return forcedamage,false end	-- yeah no

	if atktype == ATK_HEAL or atktype == ATK_SUPPORT	-- these are not meant to deal any damage.
		return 1
	end

	local rage_mult = attacker.status_condition == COND_RAGE and 2 or 1	-- mult atk by 2 if attacker has rage
	local rage_div = mo.status_condition == COND_RAGE and 2 or 1	-- divide def by 2 if mo has rage
	if mo.boss
		rage_div = 1	-- Bosses would be too cheesable with this.
	end

	local usestat = attacker.strength
	local boost = (attacker.powercharge and not atk.physical)

	if not isAttackPhysical(atk)
		usestat = attacker.magic
		boost = attacker.mindcharge
	end

	if atk.physical	-- Use the highest value between str/magic
	or (atk.costtype == CST_EP)
		usestat = max(attacker.magic, attacker.strength)
	end

	if accuracy -- check for accuracy

		local acc_div = attacker.status_condition == COND_DIZZY and 2 or 1
		-- dizzy: accuracy /2

		local attacker_agility = attacker.agility + attacker.agility*attacker.buffs["agi"][1] / 100
		local attacked_agility = mo.agility + mo.agility*mo.buffs["agi"][1] / 100

		local atk_accuracy = atk.accuracy or 0
		if atk.physical and atk.accuracy and atk.accuracy < 999
		and attacker.weapon
			atk_accuracy = attacker.weapon.acc
		end

		local hitrate = (atk.accuracy or 100) + (attacker_agility - attacked_agility)*3/4

		-- luck based stuff:
		if atk.luckbased then hitrate = (atk.accuracy or 999) + (attacker.luck - mo.luck)/2 end
		if atk.luckbased and atk.instakill and mo.damagestate == DMG_RESIST then hitrate = $/2			-- that's kinda important
		elseif atk.luckbased and atk.instakill and mo.damagestate == DMG_WEAK then hitrate = $*2 end

		-- Special stuff:
		if atk.accuracy and atk.accuracy >= 999
		or (mo.down and not atk.luckbased)	-- knocked down: guaranteed hit (unless attack is luck based)
			hitrate = 999
		end

		-- SPECIAL, in the case of a tutorial, always guarantee the hits:
		if SAVE_localtable.tutorial and not netgame
			hitrate = 999
		end

		local passive_dodge

		-- check for accuracy boosts on instant kills
		if atk.instakill
			for i = 1, #attacker.passiveskills
				local s = attacker.passiveskills[i]
				s = attackDefs[s]
				if not s continue end
				if s.passive == PSV_BOOST
				and s.type & atktype	-- check if we match types
					hitrate = $ + hitrate * s.power/100	-- increase hitrate by power%!
				end
			end
		else	-- check for evasion boosts on normal skills

			for i = 1, #mo.passiveskills
				local s = mo.passiveskills[i]

				s = attackDefs[s]
				if not s continue end
				if s.passive == PSV_DODGE
				and s.type & atktype	-- matching types
					passive_dodge = s.name
					hitrate = $ - s.power
				end
			end
		end

		if mo.damagestate == DMG_DRAIN
		or mo.damagestate == DMG_BLOCK	-- make sure to show off!
			hitrate = 100*acc_div
		end


		if P_RandomRange(0, 100) > hitrate / acc_div
		or (atk.instakill and mo.boss)	-- nope
			--mo.damagestate = DMG_MISS
			mo.passivedodge = passive_dodge

			-- eggman's plan B (lol)
			if atk.instakill
			and not mo.status_condition	-- can't work if the enemy is already status'd
				for i = 1, #mo.atk_attacker.passiveskills do
					local s = mo.atk_attacker.passiveskills[i]

					if attackDefs[s] and attackDefs[s].passive == PSV_PLANB
					and attackDefs[s].type & atktype
						s = attackDefs[s]
						-- this % chance is not affected by boosts:
						if P_RandomRange(0, 100) <= atk.accuracy + (attacker.luck - mo.luck)/2
							mo.cachestatus = s.status
							mo.damagestate = DMG_STATUS
						end
					end
				end
			end

			return "miss", false
		end
	end

	-- update enemy affintiies:
	if mo.enemy
		btl.saved_affs[mo.enemy][1] = $ | atktype
	end


	if atk.instakill	-- don't calculate damage

		if mo.tetraja	-- take priority
			mo.damagestate = DMG_BLOCK
			return 0, false

		elseif mo.damagestate == DMG_DRAIN
			return 0, false
		end

		if mo.plyr
			mo.homunculus = BTL_findItem(server.P_BattleStatus[mo.battlen], "homunculus")

			if mo.homunculus
				-- consume the homunculus
				BTL_useItem(server.P_BattleStatus[mo.battlen], mo.homunculus)
				mo.damagestate = DMG_BLOCK
				return 0, false
			end
		end

		local dmg = server.gamemode == GM_PVP and mo.hp/2 or mo.hp
		-- did we endure that instant kill?
		-- check for passive endure skills!
		if dmg >= mo.hp
			for i = 1, #mo.passiveskills do
				local s = mo.passiveskills[i]
				local a = attackDefs[s]
				if a

					-- reminder for endure:
					-- power is the amount of times this skill can be used (stacks with all other endure skills we might have!!)
					-- accuracy is the proability of it triggering (survive bless/curse for instance...)

					local at = a.type & ~ATK_PASSIVE
					if a.passive == PSV_ENDURE
					and (at == atktype or not at)			-- surviving instant kills requires either a general endure or a nil type endure.
															-- this avoids being able to survive Mudo with Survive Bless
					and (not a.power or mo.endure < a.power)
					and P_RandomRange(0, 100) < a.accuracy
						-- we survived this one.
						mo.endure = $+1		-- increment endure counter
						mo.endured = true	-- will show a message to say we survived
						return mo.hp -1, false
					end
				end
			end
		end

		if server.gamemode == GM_PVP
			mo.atk_hitby = atk
			return dmg, false
		end

		if mo.damagestate == DMG_WEAK
		and not mo.guard

			if not mo.down

				if not SRB2P_runHook("GetOneMore", attacker, mo)

					attacker.setonemore = true
					if server.gamemode == GM_VOIDRUN
					and server.P_DungeonStatus.VR_type == VC_EXPLOIT
					and mo.enemy
						server.P_DungeonStatus.VR_score = $+1
					end
				end
			end
		end
		mo.atk_hitby = atk
		return dmg, false
	end

	local dmg
	local scaledmg = 1
	local addsqrt = 0
	local batonbuff = attacker.batonpassbuff or 0

	local USER_ATK

	if isAttackPhysical(atk)
		USER_ATK = max(1, ((usestat*rage_mult) + usestat*(attacker.buffs["atk"][1] + batonbuff) / 100))	*FRACUNIT
	else
		USER_ATK = max(1, ((usestat*rage_mult) + usestat*(attacker.buffs["mag"][1] + batonbuff) / 100))	*FRACUNIT
	end

	local ENEMY_DEF = max(1, (((mo.endurance) + mo.endurance*mo.buffs["def"][1] / 100)/rage_div))	*FRACUNIT
	if mo.defence	-- wardrings
		ENEMY_DEF = $ + mo.defence
	end

	local atkstat = attacker.atk
	if attacker.weapon
		atkstat = (attacker.weapon.atk/10)
	end

	local POW = atk.physical and atkstat or atk.power	-- physical attacks use the player's weapon atk stat

	if POW < 0	-- POW < 0 is a special case for all out attacks. In this case, power is 250 + the party's overall strength or magic times 2
		local basepow = 250
		for i = 1, #attacker.allies
			local a = attacker.allies[i]

			if BTL_noAOAStatus(a)
				continue
			end
			-- use either the highest attacking stat for things that don't have weapons (how)
			-- or use the weapon atk and add them together
			local addstat = (max(attacker.allies[i].strength, attacker.allies[i].magic))*2
			if mo.weapon
				addstat = mo.weapon.atk/10
			end

			basepow = $+ addstat
		end
		POW = basepow
	end

	local ATK_POW = POW	*FRACUNIT
	local ATK_DEF = FixedDiv(USER_ATK, ENEMY_DEF)
	--print(ATK_POW.."|"..ATK_DEF.."|"..usestat.."|"..POW.."|"..attacker.atk)

	dmg = max(1, 5*FixedMul(FixedSqrt(ATK_DEF), FixedSqrt(ATK_POW))) /FRACUNIT
	-- 5* sqrt( (ATK/DEF)*POW)
	-- Because of integer overflow concerns within the square root itself,
	-- we change the formula to
	-- 5* sqrt(ATK/DEF)*sqrt(POW), Knowing that sqrt(a*b) = sqrt(a)*sqrt(b)


	if mo.down
	and atk.downboost	-- stuff like cruel attack / vile assault
		dmg = $ + dmg*atk.downboost/100
	end

	-- have we done a critical hit?
	local crit = false
	local critchance = (atk.physical and attacker.weapon) and attacker.weapon.crit or atk.critical
	-- search for PSV_CRITBOOST...
	for i = 1, #attacker.passiveskills
		local skl = attacker.passiveskills[i]
		if attackDefs[skl]
		and attackDefs[skl].passive == PSV_CRITBOOST
			local atk = attackDefs[skl]
			if atk.power
				critchance = $ or 0
				critchance = $ + critchance*atk.power / 100
			end
		end
	end

	local attacker_luck = attacker.luck + (attacker.luck*attacker.buffs["crit"][1] / 50)
	-- The receiving end can't resist a critical rate buff by having buffs of their own.
	-- That's just how it be on this bitch of an earth

	if critchance and P_RandomRange(0, 100) <= critchance + ((attacker_luck - mo.luck)/2)
	and mo.damagestate ~= DMG_DRAIN		-- can't crit in this case
	and mo.damagestate ~= DMG_BLOCK

	-- crit sleeping or frozen foes as well (not anymore as of 1.3, technical damage is enough...)
	--or ((mo.status_condition == COND_SLEEP or mo.status_condition == COND_FREEZE)
	--and (atktype == ATK_STRIKE or atktype == ATK_SLASH or atktype == ATK_PIERCE))
		if not (SAVE_localtable.tutorial)	-- no crits during the tutorial
			mo.damagestate = DMG_CRITICAL
			crit = true
		end
	end

	-- check for attack affinities?
	local tech_downchance = P_RandomRange(0, 1)
	local technical = mo.damagestate == DMG_TECHNICAL

	if not technical
		tech_downchance = 0
	end

	if mo.damagestate == DMG_WEAK
	or crit
	or technical
		dmg = $*125/100

		if crit
			mo.damagestate = DMG_CRITICAL
		end

		if not mo.down
		and not (mo.allies == attacker.allies)	-- don't onemore if we hit a teammate or ourselves
		and not mo.boss
		and mo.status_condition ~= COND_HYPER
		and not (technical and not tech_downchance)
		and not mo.guard
			attacker.setonemore = true
			-- voidrun vc_exploit
			if server.gamemode == GM_VOIDRUN
			and server.P_DungeonStatus.VR_type == VC_EXPLOIT
			and mo.enemy
				server.P_DungeonStatus.VR_score = $+1
			end
		end

	elseif mo.damagestate == DMG_DRAIN
		dmg = -dmg			-- let's heal instead.

	elseif mo.damagestate == DMG_RESIST
	and not crit	-- no damage drop on critical hits
	and not technical
		dmg = max(1, $/3)	-- Do less damage
	end

	if mo.guard	and not drain		-- guarding (stacks with resistances) (don't guard a drain)
		dmg = max(1, $/3)
	end

	-- damage variance, this is affected by equipment rarity
	local rarity_modifiers = {100, 100, 75, 75, 50, 25, 0}

	local weapon_rarity = 1
	if attacker.weapon
		weapon_rarity = max(1, attacker.weapon.rarity)
		weapon_rarity = min(7, $)
	end

	local armour_rarity = 1
	if mo.wardring
		armour_rarity = max(1, mo.wardring.rarity)
		armour_rarity = min(7, $)
	end

	local dmg_flr = -(rarity_modifiers[weapon_rarity]) or -100
	local dmg_cel = (rarity_modifiers[armour_rarity]) or 100

	dmg = $ + dmg*P_RandomRange(dmg_flr, dmg_cel)/1000
	if not mo.atk_hitby
		mo.atk_hitby = atk	-- save what attack we got hit by, that's useful for some hud stuff later on
	end
	if btl.dmg_downs == nil	-- that's important
		mo.crituptheass = crit
	end
	if not mo.crituptheass2
		mo.crituptheass2 = crit
	end
	mo.sicktech = technical

	local amp = 0
	local boosts = {}
	local slayerboost = 0	-- PSV_SLAYER boost
	local perfectboost = 0	-- PSV_PERFECTIONNIST boost
	-- for the 2 last types of boost, only keep the highest


	-- now apply the boosts to the attack!
	for i = 1, #attacker.passiveskills
		local psv = attacker.passiveskills[i]
		if attackDefs[psv]
			psv = attackDefs[$]

			-- slayer boosts
			if psv.passive == PSV_SLAYER
			and (mo.status_condition and (not psv.status or psv.status & mo.status_condition))
				-- keep highest
				slayerboost = max($, psv.power)

			elseif psv.passive == PSV_PERFECTIONNIST
				local minhp = psv.hits
				local maxdamage = psv.power
				local mindamage = psv.accuracy

				-- hack: revert skill cost to calculate how much HP we had before using this skill:
				local hp = attacker.hp
				if atk.costtype == CST_HP
					hp = $ + atk.cost
				elseif atk.costtype == CST_HPPERCENT
					hp = $ + attacker.maxhp*atk.costtype / 100
				end

				local hpdiff = 100 - minhp
				local myhp = max(minhp, hp*100 / attacker.maxhp)
				local dmgscale = maxdamage - mindamage

				local fsboost = mindamage
				if myhp > minhp
					local scale = 100 - myhp
					--print("scale: "..scale)
					local finaldamagescale = scale*100 / hpdiff
					--print("fsscale: "..finaldamagescale)

					fsboost = maxdamage - dmgscale*finaldamagescale / 100
				end

				-- keep highest
				perfectboost = max($, fsboost)
				--print("Perfect keeper boost: "..perfectboost)


			-- normal attacks
			elseif psv.passive == PSV_BOOST
			and psv.type & atktype
			and not psv.instakill	-- instakill fields boosts instakill hit rate!
			and not psv.status		-- status fields boosts status condition hit rate!

			-- link attacks
			or psv.passive == PSV_LINKHITS
			and atk.link
			and not psv.instakill
			and not psv.status

				-- add boost to the boosts table, then we'll sort it!
				boosts[#boosts+1] = psv.power
			end
		end
	end

	if slayerboost
		dmg = $ + dmg*slayerboost/100
	end
	if perfectboost
		dmg = $ + dmg*(perfectboost-100)/100
	end

	if boosts and #boosts
		-- sort it!
		table.sort(boosts, function(a, b)	return a > b end)
		-- now we have boosts from highest to lowest
		for i = 1, #boosts
			amp = $ + boosts[i]/i	-- divide by # boost
		end

		dmg = $ + dmg*amp/100
	end


	-- mindcharge / powercharge boost:
	if boost
		dmg = $* 30/12
	end

	-- block doesn't calculate damage and is handled before we attack.
	-- repel is also handled before we attack

	-- finally, do we have to inflict a status condition?
	-- status odds buffs:
	local statusbuff = 0
	if atk.status and atk.statuschance
		for i = 1, #attacker.passiveskills do
			if attackDefs[attacker.passiveskills[i]]
				local skl = attackDefs[attacker.passiveskills[i]]
				if skl.passive == PSV_COND_BOOST
				and (atk.status and (not skl.status) or skl.status & atk.status)
					statusbuff = max($, skl.power)
				end
			end
		end

		local status_hitrate = atk.statuschance + statusbuff + (attacker.luck - mo.luck)*3/4
		local status_resist_mult = 0

		-- Check for status resistances within the target
		for i = 1, #mo.passiveskills do
			if attackDefs[mo.passiveskills[i]]
				local skl = attackDefs[mo.passiveskills[i]]
				if skl.passive == PSV_COND_RESIST
				and (atk.status and (not skl.status) or skl.status & atk.status)
					status_resist_mult = max($, skl.power)
				end
			end
		end

		-- Final hitrate for statuses becomes: (BASE HITRATE + (ATTACKER AGILITY - RECEIVER AGILITY)*3/4 + STATUS BOOST)/RESISTANCE
		status_hitrate = $ - ($*status_resist_mult/100)

		if (P_RandomRange(0, 100) <= status_hitrate)
		and not (atk.target == TGT_ALLENEMIES and server.gamemode == GM_PVP)	-- do NOT inflict status on multi target moves
		and not mo.guard	-- guarding immunes against secondary statuses
			mo.cachestatus = atk.status
		end
	end

	if mo.endboss and not btl.holdupfinish	-- special case

	/*
		stacked with normal boss flag, the enemy can only get knocked down on their last HP.
		when that happens they will be finished off with an all out attack
	*/

		if dmg > (mo.hp-1)
			crit = true		-- yes, even if it's normally impossible
		end
	elseif btl.holdupfinish
		dmg = $*32	-- cinematic loads o' damage~
	end

	-- last thing:
	if atk.target == TGT_ALLENEMIES
	and server.gamemode == GM_PVP
		dmg = $/2
	end

	-- finally, process endure skills
	if dmg >= mo.hp	-- we are about to fucking die!
		for i = 1, #mo.passiveskills do
			local s = mo.passiveskills[i]
			local a = attackDefs[s]
			if a

				-- reminder for endure:
				-- power is the amount of times this skill can be used (stacks with all other endure skills we might have!!)
				-- accuracy is the proability of it triggering (survive bless/curse for instance...)

				local at = a.type & ~ATK_PASSIVE
				if a.passive == PSV_ENDURE
				and (at == 0) -- general endure
				and mo.endure < a.power
				and P_RandomRange(0, 100) < a.accuracy
					-- we survived this one.
					mo.endure = $+1		-- increment endure counter
					mo.endured = true	-- will show a message to say we survived
					return mo.hp -1, false
				end
			end
		end
	end

	-- check for swordbreaker passives in our party
	local breaker_passive = 100
	for i = 1, #mo.allies do
		local m = mo.allies[i]
		for j = 1, #m.passiveskills
			if m.passiveskills[j] and attackDefs[m.passiveskills[j]]
				local s = attackDefs[m.passiveskills[j]]
				if s.passive == PSV_SWORDBREAKER
				and s.type & atktype
				and (not s.accuracy or P_RandomRange(0, 100) <= (s.accuracy or 100))

					breaker_passive = min(100 - s.power, $)
					mo.swordbreaker = s.name
				end
			end
		end
	end

	dmg = $* breaker_passive/100
	if crit == nil	-- set crit to false, not nil, for passives if necessary
		crit = false
	end

	-- Condition damage modifiers;
	-- Attacker has poison: Multiply damage by 0.85
	if attacker.status_condition == COND_POISON
		dmg = $*85/100
	end

	-- Target has burn, multiply damage by 1.15
	if mo.status_condition == COND_BURN
		dmg = $*115/100
	end

	-- triggerdamage passives
	for i = 1, #attacker.passiveskills
		local psv = attacker.passiveskills[i]
		--print(psv)
		if attackDefs[psv] and attackDefs[psv].passive == PSV_TRIGGERDAMAGE
			local olddmg = dmg
			local oldcrit = crit
			dmg, crit = attackDefs[psv].anim(attacker, mo, dmg)
			if dmg == nil
				dmg = olddmg
			end
			if crit == nil
				crit = oldcrit
			end

			--print("New damage "..dmg.." (was "..olddmg..")")
		end
	end

	-- ditto, for received damage
	for i = 1, #mo.passiveskills
		local psv = mo.passiveskills[i]
		--print(psv)
		if attackDefs[psv] and attackDefs[psv].passive == PSV_TRIGGERDAMAGE_RECEIVED
			local olddmg = dmg
			local oldcrit = crit
			dmg, crit = attackDefs[psv].anim(mo, attacker, dmg)
			if dmg == nil
				dmg = olddmg
			end
			if crit == nil
				crit = oldcrit
			end

			--print("New damage "..dmg.." (was "..olddmg..")")
		end
	end

	-- Okay, we'll now modify the damage with hooks.
	--           - Spectra making her life easier
	local newdmg = SRB2P_runHook("ModifyDamage", attacker, mo, dmg)
	if newdmg
		dmg = newdmg
	end

	return dmg, crit or (technical and tech_downchance)
	-- return the damage number. We can use it for whatever purpose now :P
	-- Also return if we critted or not
	-- if the attack was Technical, there's a 1/2 chance of crit.
end)


rawset(_G, "run_ondamagepassives", function(mo)
	-- ondamage passives
	for i = 1, #mo.atk_attacker.passiveskills
		local psv = mo.atk_attacker.passiveskills[i]

		if attackDefs[psv] and attackDefs[psv].passive == PSV_ONDAMAGE
			attackDefs[psv].anim(mo.atk_attacker, mo)
		end
	end

	for i = 1, #mo.passiveskills
		local psv = mo.passiveskills[i]

		if attackDefs[psv] and attackDefs[psv].passive == PSV_ONDAMAGE_RECEIVED
			attackDefs[psv].anim(mo, mo.atk_attacker)
		end
	end
end)

rawset(_G, "damageObject", function(mo, damage, damagestate, reset)		-- damage an object
	-- set damage to nil to use the sevrer pre-calculated damage!
	local btl = server.P_BattleStatus[mo.battlen]

	if (mo.enemy and not mo.deathanim and enemyList[mo.enemy].deathanim)
		return
	end	-- Shouldn't be damaged, has technically died but is still here, perhaps due to a cutscene?

	-- fallbacks to prevent errors
	if mo.atk_hitby == nil
		mo.atk_hitby = BTL_copyAttackDefs(attackDefs["dummy"])	-- make do
	end
	if mo.atk_attacker == nil or not mo.atk_attacker.valid
		mo.atk_attacker = mo	-- we need SOMETHING
	end

	if reset
		resetDamage(mo)
	end

	if damagestate
		mo.damagestate = damagestate
	end

	-- status only attack, don't bother!
	if mo.damagestate == DMG_STATUS
	and mo.cachestatus
	--and not mo.boss
	and not SAVE_localtable.tutorial	-- no status condition on tutorials, they might break stuff
		inflictStatus(mo, mo.cachestatus)
		mo.cachestatus = nil
		mo.damaged = 1
		mo.damage_wait = 1
		return
	end

	if not mo.damageflags
		mo.damageflags = 0
	end

	mo.damageflags = $|DF_HP

	-- heals and baton pass:
	if damage and damage < 0	-- negative damage means heals!
		mo.damagestate = DMG_NORMAL
		local batonbuff = mo.atk_attacker.batonpassbuff or 0
		damage = $ + damage * batonbuff/100
		damage = $ + damage * mo.atk_attacker.buffs["mag"][1] /100

		-- while we're here, handle serene grace (and other heal boosts)
		-- heal boost must be checked from the attacker!
		for i = 1, #mo.atk_attacker.passiveskills

			local a = attackDefs[mo.atk_attacker.passiveskills[i]]
			if a and a.passive == PSV_BOOST and (a.type & ~ATK_PASSIVE) & ATK_HEAL	-- healing boost!
				damage = $ + damage*a.power/100	-- boost by power%.
												-- also stacks!
			end
		end

		-- in PVP; healing is reduced by half
		-- unless it's a revive (hp <= 0)
		if server.gamemode == GM_PVP
		and mo.hp > 0
			damage = $/2
		end

		damage = max($, -mo.maxhp)

		if mo.atk_attacker ~= mo
			VFX_Play(mo, VFX_HEAL)	-- say thanks to your healer, asshole!
		else
			VFX_Play(mo, VFX_HEALSELF)	-- don't thank yourself fucking idiot
		end
	end

	local atktype = mo.atk_hitby.type
	local nihilwep

	if mo.atk_hitby.physical and mo.atk_attacker and mo.atk_attacker.weapon and mo.atk_attacker.weapon.element
		atktype = mo.atk_attacker.weapon.element
		nihilwep = true	-- draw nihil weapon effects on-hit
	end

	-- Almighty *destroys* barriers.
	if mo.atk_hitby and atktype == ATK_ALMIGHTY
	and (mo.makarakarn or mo.tetrakarn or mo.tetraja)
		BTL_logMessage(mo.battlen, mo.name.."'s barrier couldn't\nwithstand the Almighty attack!")
		mo.makarakarn = nil
		mo.tetrakarn = nil
		mo.tetraja = nil

		playSound(mo.battlen, sfx_bufu6)
	end

	-- attack is to be repelled; show this:
	if mo.repelto
	and mo.atk_hitby.anim_norepel
		local t = mo.repelto
		local x, y = t.x + 32*cos(t.angle), t.y + 32*sin(t.angle)
		local s = P_SpawnMobj(x, y, t.z+mo.height/2, MT_DUMMY)
		s.scale = FRACUNIT/2
		s.destscale = FRACUNIT*3
		s.scalespeed = FRACUNIT/3
		s.fuse = TICRATE/2
		s.sprite = t.repelspr
		s.frame = $|FF_PAPERSPRITE
		s.angle = t.angle + ANG1*90
		playSound(mo.battlen, sfx_reflc)
		t.repelspr = nil
	end
	mo.repelto = nil

	-- mo already blocked the damage.
	if mo.damagestate == DMG_BLOCK
		playSound(mo.battlen, sfx_hamas2)
		mo.damaged = 1

		if mo.atk_attacker and mo.atk_attacker.valid
			VFX_Play(mo.atk_attacker, VFX_MISS)
		end

		if mo.tetraja
			BTL_logMessage(mo.battlen, "Tetraja blocked the attack!")
			mo.tetraja = nil
		end

		if mo.homunculus	-- homunculus sacrifice takes the form of a block with mo.homunculus being != nil
			BTL_logMessage(mo.battlen, "The Homunculus sacrificed itself!")
			mo.homunculus = nil
		end
		run_ondamagepassives(mo)
		return
	end
	local downsyndrome, dmgtable

	if damage == nil
		dmgtable = btl.dmg_hits
		if not dmgtable[mo.dmg_index]	-- something went wrong.
			mo.damaged = 1	-- ????
			mo.damagestate = DMG_MISS	-- just miss.
			-- Only case where we will directly set DMG_MISS here

			--dprint("ERROR: No damage value was here. Did something go wrong?")
		else
			damage = dmgtable[mo.dmg_index][1]
			table.remove(dmgtable[mo.dmg_index], 1)
		end
		local downtable = btl.dmg_downs	-- do we get adhd this turn
		if not downtable[mo.dmg_index]
			downsyndrome = nil
		else
			downsyndrome = downtable[mo.dmg_index][1]
			table.remove(downtable[mo.dmg_index], 1)
		end
	else
		mo.atk_hitby = $ or mo.attack	-- oh well!
	end

	if not mo.hitstaken
		mo.hitstaken = 1
	else
		mo.hitstaken = $+1
	end

	-- damage is a miss:
	if type(damage) == "string"
		-- before applying this damagestate, check if there are hits remaining
		if dmgtable and #dmgtable[mo.dmg_index]	-- < more damage left
		or mo.damaged	-- was already damaged
		or mo.damagetaken -- ditto
			return	-- don't do anything, only miss on the last hit if we weren't damaged already!
		end

		mo.damaged = 1
		mo.damagestate = DMG_MISS

		VFX_Play(mo, VFX_DODGE)
		if mo.atk_attacker and mo.atk_attacker.valid	-- might not exist?
			VFX_Play(mo.atk_attacker, VFX_MISS)
		end

		if mo.passivedodge
			BTL_logMessage(mo.battlen, mo.passivedodge)
		end

		if mo.guaranteedevasion
			BTL_logMessage(mo.battlen, "The attack won't connect!")
		end

		mo.dodgeanim = TICRATE/2
		run_ondamagepassives(mo)
		return
	end

	local canknockdown = mo.status_condition ~= COND_HYPER and ((not mo.boss) or (mo.endboss and damage >= (mo.hp-1)))

	if type(damage) == "number"
		if damage > 0	-- we got hurt
			mo.redhp = mo.hp
			mo.hp = max(0, $-damage)

			if btl.scoremode	-- implicit: GM_CHALLENGE
			and not mo.plyr	-- damaging an enemy in challenge score mode

				BTL_addScore(mo.battlen, damage*2*(downsyndrome and 2 or 1))
				-- pts + damage*2 or damage*4 if knockdown

				if mo.hp == 0	-- enemy defeated
					BTL_addScore(mo.battlen, 1000, "Enemy defeated!")
				end
			end

			if mo.state ~= S_INVISIBLE
				ANIM_set(mo, mo.anim_hurt)
			end

			if mo.plyr	-- we are a player, technically!
				S_StartSound(mo, sfx_s1c6)
				for i = 1, min(damage, 8)
					local ring = P_SpawnMobj(mo.x, mo.y, mo.z, MT_FLINGRING)
					ring.momx = P_RandomRange(-16, 16)*FRACUNIT
					ring.momy = P_RandomRange(-16, 16)*FRACUNIT
					ring.momz = P_RandomRange(0, 16)*FRACUNIT
					ring.flags = $ & ~MF_SPECIAL
					ring.fuse = TICRATE
				end
			end

			if nihilwep
				if atktype == ATK_FIRE
					playSound(mo.battlen, sfx_fire1)
					for i=1,20
						local b = P_SpawnMobj(mo.x, mo.y, mo.z+20*FRACUNIT, MT_DUMMY)
						b.momx = P_RandomRange(-8, 8)*FRACUNIT
						b.momy = P_RandomRange(-8, 8)*FRACUNIT
						b.momz = P_RandomRange(-8, 8)*FRACUNIT
						b.state = S_QUICKBOOM1
						b.scale = FRACUNIT*3
					end

				elseif atktype == ATK_ICE

					playSound(mo.battlen, sfx_bufu4)
					for i=1,20
						local b = P_SpawnMobj(mo.x, mo.y, mo.z+20*FRACUNIT, MT_BUFU_PARTICLE)
						b.momx = P_RandomRange(-8, 8)*FRACUNIT
						b.momy = P_RandomRange(-8, 8)*FRACUNIT
						b.momz = P_RandomRange(-8, 8)*FRACUNIT
						b.scale = FRACUNIT*3
					end

				elseif atktype == ATK_ELEC

					playSound(mo.battlen, sfx_zio1)
					for i=1,20
						local b = P_SpawnMobj(mo.x, mo.y, mo.z+20*FRACUNIT, MT_DUMMY)
						b.momx = P_RandomRange(-8, 8)*FRACUNIT
						b.momy = P_RandomRange(-8, 8)*FRACUNIT
						b.momz = P_RandomRange(-8, 8)*FRACUNIT
						b.scale = FRACUNIT*3
						b.state = S_SSPK1
					end

				elseif atktype == ATK_WIND
					playSound(mo.battlen, sfx_wind1)
					for i = 1, 2
						local s = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
						s.scale = FRACUNIT/4
						s.sprite = SPR_SLAS
						s.frame = I|TR_TRANS50 + P_RandomRange(0, 3)
						s.destscale = FRACUNIT*9
						s.scalespeed = FRACUNIT
						s.tics = TICRATE/3
					end

				elseif atktype == ATK_PSY
					playSound(mo.battlen, sfx_s3k83)
					local psiocolors = {SKINCOLOR_TEAL, SKINCOLOR_YELLOW, SKINCOLOR_PINK, SKINCOLOR_BLACK, SKINCOLOR_WHITE}
					for i=1,20
						local b = P_SpawnMobj(mo.x, mo.y, mo.z+20*FRACUNIT, MT_DUMMY)
						b.momx = P_RandomRange(-8, 8)*FRACUNIT
						b.momy = P_RandomRange(-8, 8)*FRACUNIT
						b.momz = P_RandomRange(-8, 8)*FRACUNIT
						b.color = psiocolors[P_RandomRange(1, #psiocolors)]
					end

				elseif atktype == ATK_NUCLEAR
					playSound(mo.battlen, sfx_megi6)
					for i=1,20
						local b = P_SpawnMobj(mo.x, mo.y, mo.z+20*FRACUNIT, MT_DUMMY)
						b.momx = P_RandomRange(-8, 8)*FRACUNIT
						b.momy = P_RandomRange(-8, 8)*FRACUNIT
						b.momz = P_RandomRange(-8, 8)*FRACUNIT
						b.state = S_QUICKBOOM1
						b.colorized = true
						b.color = SKINCOLOR_TEAL
						b.scale = FRACUNIT*3
					end

				elseif atktype == ATK_BLESS
					playSound(mo.battlen, sfx_hamas1)
					local speeds = {FRACUNIT/16, FRACUNIT/10, FRACUNIT/3, FRACUNIT/8}
					local fuses = {20, 16, 8, 16}

					for i = 1, 4
						local l = P_SpawnMobj(mo.x, mo.y, mo.z + FRACUNIT*32, MT_THOK)	-- mt_thok for auto fadeout
						l.tics = -1
						l.sprite = SPR_CARD
						l.color = SKINCOLOR_YELLOW
						l.frame = L|(i== 2 and TR_TRANS40 or TR_TRANS70)|FF_FULLBRIGHT
						l.scale = FRACUNIT/2
						l.destscale = FRACUNIT*6
						l.scalespeed = speeds[i]
						l.fuse = fuses[i]
					end

				elseif atktype == ATK_CURSE
					playSound(mo.battlen, sfx_eih4)
					local psiocolors = {SKINCOLOR_BLACK, SKINCOLOR_WHITE, SKINCOLOR_RED}
					for i=1,20
						local b = P_SpawnMobj(mo.x, mo.y, mo.z+20*FRACUNIT, MT_DUMMY)
						b.momx = P_RandomRange(-8, 8)*FRACUNIT
						b.momy = P_RandomRange(-8, 8)*FRACUNIT
						b.momz = P_RandomRange(-8, 8)*FRACUNIT
						b.color = psiocolors[P_RandomRange(1, #psiocolors)]
					end
				end
			end

			-- ready Link properties.
			if mo.atk_hitby
			and mo.atk_hitby.link
			and mo.atk_attacker.attackref
			and btl.battlestate ~= BS_LINK	-- don't reset links during links (lol)

				local numlinks = 1
				local linkdamage = 0
				-- check attacker passives (psv_linkhits, psv_linkboost)
				for i = 1, #mo.atk_attacker.passiveskills
					local s = attackDefs[mo.atk_attacker.passiveskills[i]]

					if not s continue end
					if s and s.passive and s.passive == PSV_LINKHITS
						numlinks = max($, s.accuracy)
					elseif s and s.passive and s.passive == PSV_LINKBOOST
						linkdamage = max($, s.power)
					end
				end

				if mo.atk_attacker.attackref
				and attackDefs[mo.atk_attacker.attackref]
				and not attackDefs[mo.atk_attacker.attackref].link
					return	-- !?
				end

				-- Link set
				mo.linkstate = {
					link = 0,
					maxlink = numlinks,
					linkboost = linkdamage,
					atkref = mo.atk_attacker.attackref,
					entref = mo.atk_attacker,
					dmg = damage,
				}
			end

			-- Hooks
			SRB2P_runHook("FighterDamage", mo, mo.atk_attacker)
		else			-- we got healed
			mo.redhp = min(mo.maxhp, mo.hp-damage)
		end
		if not mo.damagetaken then mo.damagetaken = 0 end

		if not mo.damagetype
			mo.damagetaken = $+damage
		else
			mo.damagetaken = damage
		end
		mo.damagetype = 0

		if mo.plyr and damage > 0	-- don't shake if we got healed lmao
			P_StartQuake(FRACUNIT*7, 4)
		end

		-- inflict status conition?
		-- / freeze gets broken out of if you get hit (not anymore as of 1.3)
		/*if mo.status_condition == COND_FREEZE
		and damage > 0
			mo.status_condition = 0
			BTL_logMessage(mo.battlen, mo.name.." was broken out of the ice!")*/

		-- / or wake up
		if mo.status_condition == COND_SLEEP
		and damage > 0
			mo.status_condition = 0
			BTL_logMessage(mo.battlen, mo.name.." was woken up!")

		elseif mo.atk_attacker ~= mo
		and mo.atk_attacker and mo.atk_attacker.valid
		and mo.atk_attacker and mo.atk_attacker.status_condition == COND_HEX
		and damage > 0
			-- ...they take damage!
			mo.atk_attacker.atk_attacker = mo
			mo.atk_hitby = attackDefs["dummy"]
			damageObject(mo.atk_attacker, min(mo.atk_attacker.hp-1, damage/2))

		elseif mo.cachestatus
		and not SAVE_localtable.tutorial
		and mo.damagestate ~= DMG_DRAIN
			inflictStatus(mo, mo.cachestatus)
			mo.cachestatus = nil
		end

		-- handle knock down?
		local gotdown
		if mo.atk_hitby and (downsyndrome or mo.damagestate == DMG_WEAK)
		and not mo.guard
		and canknockdown
			playSound(mo.battlen, sfx_crit)

			mo.downanim = 10	-- oof
			if not mo.down
				ANIM_set(mo, mo.anim_getdown)
			end

			if not mo.down
				btl.netstats.knockdowns = $ +1
			end

			mo.down = true	-- down is a separate status condition
			gotdown = true
			if mo.crituptheass2
				mo.crituptheass = true
				mo.hudpop = 1
			end
		end

		if mo.hp	-- play voices!
		and damage > 0
			VFX_Play(mo, (gotdown or damage > mo.maxhp/2) and VFX_HURTX or VFX_HURT)
		end

	else	-- if it's not a number, then that's a miss
		/*if not mo.damagetaken
			mo.damagetaken = "MISS"
		end*/
	end
	if mo.damaged
		mo.damaged = 5	-- don't pop the earth again
	else
		mo.damaged = 1
	end
	mo.damage_wait = 0

	if damage and damage > 0
		mo.guard = nil		-- we aren't guarding anymore. But only if we took damage that was POSITIVE. (negative damage = healing)
	end

	if not mo.coreentity	-- thing getting damaged is an unimportant enemy
	and damage and type(damage) == "number"	-- reminder that string damage is a miss.
	and btl.dmg_actor and btl.dmg_actor.plyr
		local fill = min(mo.hp, damage)/3
		fill = min($, 34)
		fill = max($, 5)
		if downsyndrome	-- enemy was knocked down this turn
		or mo.damagestate == DMG_TECHNICAL
		or mo.damagestate == DMG_WEAK
		or mo.damagestate == DMG_CRITICAL
			fill = $*3/2
		end

		-- lower this amount for multi target attacks:
		if btl.dmg_actor and btl.dmg_actor.plyr and btl.dmg_actor.targets and #btl.dmg_actor.targets
			fill = $ / #btl.dmg_actor.targets
		end

		-- lower this by the amount of hits the attack does
		if mo.atk_hitby and mo.atk_hitby.hits
			fill = $ / mo.atk_hitby.hits
		end

		if mo.fieldstate and mo.fieldstate.type == FLD_AGIVERSE
			fill = $*2
		end

		-- fill emerald gauge with the damage we've done!
		fillEmeraldGauge(btl.dmg_actor, fill)
	end

	-- drain sfx
	if mo.damagestate == DMG_DRAIN
		playSound(mo.battlen, sfx_absorb)
		if mo.atk_attacker and mo.atk_attacker.valid
			VFX_Play(mo.atk_attacker, VFX_MISS)
		end
	end

	-- endure!
	if mo.endured	-- print a message if we endured the skill
		BTL_logMessage(mo.battlen, mo.name.." endured the attack!")
		mo.endured = nil
	end

	-- endboss shit
	if mo.endboss and not btl.holdupfinish
		mo.hp = max($, 1)
	elseif btl.holdupfinish
		mo.hp = 0
	end

    if downsyndrome
        local popup = max(0, ((damage*100)/mo.maxhp)/5)
        P_SetObjectMomZ(mo, FRACUNIT*(min(11, 3+popup)))
    end

	if mo.swordbreaker	-- homunculus sacrifice takes the form of a block with mo.homunculus being != nil
		BTL_logMessage(mo.battlen, mo.swordbreaker.." activated!")
		mo.swordbreaker = nil
	end

	local dmgnum = type(damage) == "number"

	if mo.plyr and dmgnum
		if damage >= 0
			btl.netstats.damagetaken = $+ damage
		else
			btl.netstats.damagehealed = $- damage
		end
	elseif type(damage) == "number" and damage >= 0
		btl.netstats.damagedealt = $ +damage
	end

	-- handle some field shit:
	if (dmgnum and damage > 0) and mo.fieldstate
	and mo.atk_attacker
	and mo.atk_attacker ~= mo	-- not if you attacked yourself somehow
	and mo and mo.valid	--??
	and btl.turnorder[1] ~= mo	-- repels, counters...???
	and mo.hp
	and mo.damagestate ~= DMG_DRAIN


		if mo.fieldstate.type == FLD_GARUVERSE

			playSound(mo.battlen, sfx_heal)
			mo.atk_attacker.atk_attacker = mo.atk_attacker	--... yes, we need to set this manually and this looks horrible LOL
			mo.atk_attacker.atk_hitby = BTL_copyAttackDefs(attackDefs["dia"])	-- yeah this is horrible alright.

			local div = 4
			if mo.atk_hitby.target == TGT_ALLENEMIES
				div = #mo.allies +5
			end

			if btl.battlestate == BS_LINK
				div = $*6
			end	-- only restore 12.5% of damage dealt with link skills

			damageObject(mo.atk_attacker, -(abs(damage)*3/div))

		elseif mo.fieldstate.type == FLD_ZIOVERSE
		and not mo.zionverse_spread	-- flag to make sure we don't endlessly damage everything lol
		and mo.atk_hitby.target == TGT_ENEMY	-- only single target skills

			-- spread damage to everyone else inflicted with zionverse in my party!
			for i = 1, #mo.allies do
				local a = mo.allies[i]
				if a ~= mo
				and a.fieldstate
				and a.fieldstate.type == FLD_ZIOVERSE

					a.atk_attacker = mo.atk_attacker
					a.atk_hitby = mo.atk_hitby

					a.zionverse_spread = true	-- flag to not spread damage endlessly
					damageObject(a, damage/5)
					a.zionverse_spread = nil

					for j = 1, 16
						local b = P_SpawnMobj(a.x, a.y, a.z, MT_SUPERSPARK)
						b.momx = P_RandomRange(-32, 32)*b.scale
						b.momy = P_RandomRange(-32, 32)*b.scale
						b.momz = P_RandomRange(-32, 32)*b.scale
					end
				end
			end
		end
	end

	if not mo.hp and (dmgnum or damage > 0)	-- I can't believe we're fucking dead
	--and not (mo.flags2 & MF2_DONTDRAW)
	and mo.state ~= S_INVISIBLE

		if not mo.extra
			cureStatus(mo)
			mo.status_condition = nil
			mo.status_turns = 0	-- hyper mode
		end

		VFX_Play(mo.atk_attacker, VFX_KILL)
		VFX_Play(mo, VFX_DIE)
		mo.down = nil	-- Not down anymore

		if mo.enemy
		and not mo.plyr				-- no, enemy players don't explode as far as I recall

			local exp = mo.expval or enemyList[mo.enemy].r_exp or 1
			local money = mo.moneyval or enemyList[mo.enemy].r_macca or exp/4

			-- get item drops:
			/*if enemyList[mo.enemy].r_drops
				local t = enemyList[mo.enemy].r_drops
				for i = 1, #t do
					if P_RandomRange(0, 100) <= t[i][2]
						BTL_addResultItem(btl, t[i][1], 1)
					end
				end
			end*/
			getRandomDrops(mo)

			if mo.extra
				btl.r_exp = $+ exp*3/2
				btl.r_money = $+money*3/2
				return
			end	-- sequence handled in a separate battlestate

			playSound(mo.battlen, sfx_srip)		-- die monster
			clearField(mo)			-- clear Fields
			mo.state = S_INVISIBLE	-- turn invisible

			if not mo.deathanim

				mo.anim = nil			-- stop pain animation
				mo.flags2 = $|MF2_DONTDRAW
				explodeShadow(mo)		-- directed by micheal bay

				if btl.holdupfinish
					explodeShadowBig(mo)
				end
			else
				if mo.enemy
					local btl = server.P_BattleStatus[mo.battlen]
					btl.saved_affs[mo.enemy][3] = true	-- enemy was beaten, that means every subsequent type of this enemy can have its stats be displayed in analysis
				end
			end

			-- give us some exp?
			btl.r_exp = $+ (exp or 0)
			btl.r_money = $+ money

			btl.netstats.enemiesdefeated = $ +1
			if server.P_DungeonStatus.VR_type == VC_ERADICATION
			or server.P_DungeonStatus.VR_type == VC_REPEL
				server.P_DungeonStatus.VR_score = $+1
			end

		elseif mo.plyr
		and mo.state ~= S_INVISIBLE	-- not already dead
			-- player dies
			playSound(mo.battlen, sfx_s3k35)
			cureStatus(mo)
			mo.status_condition = nil
			mo.status_turns = 0
			BTL_readybuffs(mo)	-- reset buffs / debuffs
			mo.anim = nil
			mo.state = S_INVISIBLE
			mo.tics = -1
			-- spawn deathstate:
			local d = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
			d.skin = mo.skin
			d.color = mo.color
			d.state = S_PLAY_DEAD
			d.tics = -1
			d.flags = MF_NOCLIPHEIGHT
			d.fuse = TICRATE*6
			P_SetObjectMomZ(d, 10<<FRACBITS)
			btl.netstats.timesdied = $ +1

			if server.gamemode == GM_VOIDRUN
				server.P_DungeonStatus.VR_lives = max(0, $-1)
				BTL_logMessage(mo.battlen, "\x82".."You lost a life!")
			end

			-- put me back where I was!
			mo.momx = 0
			mo.momy = 0
			mo.momz = 0
			if mo.defaultcoords
				P_TeleportMove(mo, mo.defaultcoords[1], mo.defaultcoords[2], mo.z)
			end

		end
	end
	run_ondamagepassives(mo)
end)

rawset(_G, "damageSP", function(mo, damage, damagestate, reset)		-- damage an object's SP

	if damage == nil
		return
	end

	if not mo.damageflags
		mo.damageflags = 0
	end

	if reset
		resetDamage(mo)
	end

	if damagestate
		mo.damagestate = damagestate
	end

	mo.damageflags = $|DF_SP

	if not mo.hitstaken
		mo.hitstaken = 1
	else
		mo.hitstaken = $+1
	end

	if type(damage) == "number"
		if damage > 0	-- we got hurt
			mo.redsp = mo.sp
			mo.sp = max(0, $-damage)
		else			-- we got healed
			mo.redsp = min(mo.maxsp, mo.sp-damage)
		end
		if not mo.spdamagetaken then mo.spdamagetaken = 0 end
		if mo.damagetype
			mo.spdamagetaken = $+damage
		else
			mo.spdamagetaken = damage	-- don't stack it for SP.
		end
		mo.spdamagetype = 1

		if mo.plyr and damage > 0	-- don't shake if we got healed lmao
			P_StartQuake(FRACUNIT*7, 4)
		end
	end

	if mo.damaged
		mo.damaged = 5	-- don't pop the earth again
	else
		mo.damaged = 1
	end
	mo.damage_wait = 0
	mo.guard = nil		-- we aren't guarding anymore.
	-- SP damage can't kill us, so that's it.
end)

local function DMG_handleDamage(mo)
	if not mo.damaged then return end
	mo.damaged = $+1
	if mo.hudpop then mo.hudpop = $+1 end
	if mo.downanim then mo.downanim = $-1 end

	if mo.damagestate == DMG_BLOCK
	or mo.atk_hitby and mo.atk_hitby.instakill
		if mo.damaged > TICRATE*3/2
			resetDamage(mo)
			return
		end
	end

	if mo.damagestate == DMG_MISS
		if mo.damaged > TICRATE
			resetDamage(mo)
			return
		end
	end

	local hpcond = not mo.damagetaken or mo.hp == (mo.redhp or mo.hp)
	local spcond = not mo.spdamagetaken or mo.sp == (mo.redsp or mo.sp)

	if (hpcond) or (spcond)
	or mo.damaged > TICRATE*2+10	-- timeout failsafe
		mo.damage_wait = $ and $+1 or 1
		if mo.damage_wait > TICRATE-TICRATE/5
			resetDamage(mo)
		end
	end


	if not (mo.damagetaken or mo.spdamagetaken) then return end

	--print(tostring(mo.damagetaken).."|"..tostring(mo.redhp))

	if mo.damaged < TICRATE/2 then return end

	-- HP damage:
	if mo.damagetaken
		if mo.damagetaken > 0
			if mo.redhp ~= nil
				mo.redhp = max(mo.hp, $/2)
			end
		else
			if mo.redhp ~= nil
				mo.hp = min(mo.redhp, $+mo.maxhp/6)
			end
		end
	end

	-- SP damage:
	if mo.spdamagetaken
		if mo.spdamagetaken > 0
			if mo.redsp ~= nil
				mo.redsp = max(mo.sp, $/2)
			end
		else
			if mo.redsp ~= nil
				mo.sp = min(mo.redsp, $+mo.maxsp/6)
			end
		end
	end

end

addHook("MobjThinker", DMG_handleDamage, MT_PFIGHTER)

-- DEBUG COMMANDS

COM_AddCommand("d_sethp", function(p, target, num, arg)
	if not cv_debugcheats.value return end
	local btl = server.P_BattleStatus[p.P_party]

	if not btl.running
		CONS_Printf(p, "You must be in a Battle to use this.")
		return
	end
	if not target
	or not arg
	or not num
	or tonumber(arg) == nil
	or tonumber(num) == nil
		CONS_Printf(p, "d_sethp <\"players\"/\"enemies\"> <index> <amount>: Sets the HP of the entity of the given index. If index is 0, all entities are affected.")
		return
	end
	local base = p.maincontrol

	local t = base.enemies

	target = target:lower()

	if target == nil
	or target == "enemies"
		t = base.enemies
	elseif target == "players"
		t = base.allies
	end

	for i = 1, #t
		if tonumber(num) == 0
		or tostring(i) == num
			print("DEBUG: Set "..t[i].name.."'s HP to "..arg)
			t[i].hp = max(1, tonumber(arg))
			t[i].hp = min($, t[i].maxhp)
		end
	end
end)

COM_AddCommand("d_sethp%", function(p, target, num, arg)
	if not cv_debugcheats.value return end
	local btl = server.P_BattleStatus[p.P_party]

	if not btl.running
		CONS_Printf(p, "You must be in a Battle to use this.")
		return
	end
	if not target
	or not arg
	or not num
	or tonumber(arg) == nil
	or tonumber(num) == nil
		CONS_Printf(p, "d_sethp% <\"players\"/\"enemies\"> <index> <amount>: Sets the HP of the entity of the given index in %. If index is 0, all entities are affected.")
		return
	end
	local base = p.maincontrol

	local t = base.enemies

	target = target:lower()

	if target == nil
	or target == "enemies"
		t = base.enemies
	elseif target == "players"
		t = base.allies
	end

	for i = 1, #t
		if tonumber(num) == 0
		or tostring(i) == num
			print("DEBUG: Set "..t[i].name.."'s HP to "..arg.."%")
			t[i].hp = min(max(1, tonumber(arg)), 100)*t[i].maxhp / 100
		end
	end
end)

COM_AddCommand("d_setsp", function(p, target, num, arg)
	if not cv_debugcheats.value return end
	local btl = server.P_BattleStatus[p.P_party]

	if not btl.running
		CONS_Printf(p, "You must be in a Battle to use this.")
		return
	end
	if not target
	or not arg
	or not num
		CONS_Printf(p, "d_setsp <\"players\"/\"enemies\"> <index> <amount>: Sets the SP of the entity of the given index. If index is 0, all entities are affected.")
		return
	end
	local base = p.maincontrol

	local t = base.enemies

	target = target:lower()

	if target == nil
	or target == "enemies"
		t = base.enemies
	elseif target == "players"
		t = base.allies
	end

	for i = 1, #t
		if tonumber(num) == 0
		or tostring(i) == num
			print("DEBUG: Set "..t[i].name.."'s SP to "..arg)
			t[i].sp = max(1, tonumber(arg))
			t[i].sp = min($, t[i].maxsp)
		end
	end
end)

COM_AddCommand("d_setsp%", function(p, target, num, arg)
	if not cv_debugcheats.value return end
	local btl = server.P_BattleStatus[p.P_party]

	if not btl.running
		CONS_Printf(p, "You must be in a Battle to use this.")
		return
	end
	if not target
	or not arg
	or not num
	or tonumber(arg) == nil
	or tonumber(num) == nil
		CONS_Printf(p, "d_sethp% <\"players\"/\"enemies\"> <index> <amount>: Sets the SP of the entity of the given index in %. If index is 0, all entities are affected.")
		return
	end
	local base = p.maincontrol

	local t = base.enemies

	target = target:lower()

	if target == nil
	or target == "enemies"
		t = base.enemies
	elseif target == "players"
		t = base.allies
	end

	for i = 1, #t
		if tonumber(num) == 0
		or tostring(i) == num
			print("DEBUG: Set "..t[i].name.."'s SP to "..arg.."%")
			t[i].sp = min(max(1, tonumber(arg)), 100)*t[i].maxsp / 100
		end
	end
end)

local status_lookup = {
	["burn"] = COND_BURN,
	["dizzy"] = COND_DIZZY,
	["despair"] = COND_DESPAIR,
	["hunger"] = COND_HUNGER,
	["hyper"] = COND_HYPER,
	["super"] = COND_SUPER,
	["hex"] = COND_HEX,
	["freeze"] = COND_FREEZE,
	["shock"] = COND_SHOCK,
	["rage"] = COND_RAGE,
	["brainwash"] = COND_BRAINWASH,
	["silence"] = COND_SILENCE,
	["sleep"] = COND_SLEEP,
	["poison"] = COND_POISON,
	["down"] = "special",
}

COM_AddCommand("d_setstatus", function(p, target, num, arg)
	if not cv_debugcheats.value return end
	local btl = server.P_BattleStatus[p.P_party]

	if not btl.running
		CONS_Printf(p, "You must be in a Battle to use this.")
		return
	end

	if not target
	or not arg
	or not num
	or tonumber(num) == nil
		CONS_Printf(p, "d_setstatus <\"players\"/\"enemies\"> <index> <amount>: Sets the supplied status on the entity of the given index. If index is 0, all entities are affected.")
		CONS_Printf(p, "List of avilable statuses:")
		for k, v in pairs(status_lookup)
			CONS_Printf(p, k)
		end
		return
	end
	local base = p.maincontrol

	local t = base.enemies
	local arg = arg:lower()
	local target = target:lower()

	if target == nil
	or target == "enemies"
		t = base.enemies
	elseif target == "players"
		t = base.allies
	end

	for i = 1, #t
		if tonumber(num) == 0
		or tostring(i) == num
			if status_lookup[arg]

				print("DEBUG: Set "..t[i].name.."'s status to "..arg)

				if status_lookup[arg] == "special"
					playSound(t[i].battlen, sfx_crit)

					t[i].downanim = 10	-- oof
					if not t[i].down
						ANIM_set(t[i], t[i].anim_getdown)
					end

					t[i].down = true	-- down is a separate status condition
				else
					cureStatus(t[i])
					t[i].status_condition = 0
					inflictStatus(t[i], status_lookup[arg])
				end
			else
				print("DEBUG: Cured "..t[i].name.."'s status")
				if t[i].status_condition and t[i].status_condition < COND_HYPER
					cureStatus(t[i])
					t[i].status_condition = 0
				end
			end
		end
	end
end)

local field_lookup = {
	["agiverse"] = FLD_AGIVERSE,
	["zioverse"] = FLD_ZIOVERSE,
	["garuverse"] = FLD_GARUVERSE,
}

COM_AddCommand("d_setfield", function(p, target, num, arg)
	if not cv_debugcheats.value return end
	local btl = server.P_BattleStatus[p.P_party]

	if not btl.running
		CONS_Printf(p, "You must be in a Battle to use this.")
		return
	end

	if not target
	or not arg
	or not num
	or tonumber(num) == nil
		CONS_Printf(p, "d_setstatus <\"players\"/\"enemies\"> <index> <amount>: Sets the supplied field on the entity of the given index. If index is 0, all entities are affected.")
		CONS_Printf(p, "List of avilable fields:")
		for k, v in pairs(field_lookup)
			CONS_Printf(p, k)
		end
		return
	end
	local base = p.maincontrol

	local t = base.enemies
	local arg = arg:lower()
	local target = target:lower()

	if target == nil
	or target == "enemies"
		t = base.enemies
	elseif target == "players"
		t = base.allies
	end

	for i = 1, #t
		if tonumber(num) == 0
		or tostring(i) == num
			if field_lookup[arg]
				print("DEBUG: Set "..t[i].name.."'s field to "..arg)
				startField(t[i], field_lookup[arg])
			else
				print("DEBUG: Cleared "..t[i].name.."'s field")
				clearField(t[i])
			end
		end
	end
end)

local bufftypes = {
	["atk"] = true,
	["mag"] = true,
	["agi"] = true,
	["def"] = true,
	["crit"] = true,
}

COM_AddCommand("d_setbuff", function(p, target, num, typ, arg)
	if not cv_debugcheats.value return end
	local btl = server.P_BattleStatus[p.P_party]

	if not btl.running
		CONS_Printf(p, "You must be in a Battle to use this.")
		return
	end

	if not target
	or not arg
	or not num
	or not typ
	or tonumber(arg) == nil
	or tonumber(num) == nil
		CONS_Printf(p, "d_setstatus <\"players\"/\"enemies\"> <index> <\"str\"/\"mag\"/\"def\"/\"agi\"/\"crit\"> <amount>: Sets the buff to the supplied value (1-2-3). If index is 0, all entities are affected.")
		return
	end
	local base = p.maincontrol

	local t = base.enemies
	local arg = arg:lower()
	local typ = typ:lower()
	local target = target:lower()

	if not bufftypes[typ]
		CONS_Printf(p, "Invalid buff type")
		return
	end

	if target == nil
	or target == "enemies"
		t = base.enemies
	elseif target == "players"
		t = base.allies
	end

	for i = 1, #t
		if tonumber(num) == 0
		or tostring(i) == num
			local nbuffs = tonumber(arg)
			nbuffs = min(MAXBUFFS, $)
			nbuffs = max(-MAXBUFFS, $)	-- clamp it.

			t[i].buffs[typ][1] = BUFFSTEP*nbuffs
			print("DEBUG: Set "..t[i].name.."'s "..typ.." buff to "..arg)
		end
	end
end)

COM_AddCommand("d_setep", function(p, arg)
	if not cv_debugcheats.value return end
	local btl = server.P_BattleStatus[p.P_party]

	if not arg
		CONS_Printf(p, "d_setep <amount>: Sets Emerald Power. Values can go above current max.")
		return
	end

	if tonumber(arg) ~= nil
		btl.emeraldpow = max(0, min(7, tonumber(arg)))*100
		btl.emeraldpow_max = max(0, min(7, tonumber(arg)))
	end
end)

COM_AddCommand("d_setholdup", function(p)
	if not cv_debugcheats.value return end
	local btl = server.P_BattleStatus[p.P_party]
	local base = p.maincontrol

	if not btl.running
		CONS_Printf(p, "You must be in a Battle to use this.")
		return
	end

	if btl.battlestate ~= BS_DOTURN
		CONS_Printf(p, "Battle state must be neutral")
		return
	end

	BTL_initHoldup(btl, base.allies)
end)