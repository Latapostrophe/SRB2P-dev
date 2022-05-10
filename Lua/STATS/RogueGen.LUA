-- This script contains function that's able to generate rogue enemies

local t, x, y, z, w

local function R_Random()
	t = x ^^ (x << 11)
	x, y, z, w = y, z, w, w ^^ (w >> 19) ^^ t ^^ (t >> 8)
	return w
end

local function R_RandomRange(a, b)
	return a + abs(R_Random() % (b - a + 1))
end

-- removes every enemy that has "__roguemode" in its name specifically.
-- don't name your enemies like that, dumbass.
rawset(_G, "ROGUE_reset", function()
	for k, p in pairs(enemyList)

		if k:find("__roguemode")
			enemyList[k] = nil
			continue
		end
	end
end)

-- takes an enemyList element, and creates a new enemy from it!
-- to be used when generating enemy waves when we set a floor!

-- In normal rogue mode, enemies get a fixed 10% HP buff.
-- In Marathon, the HP buff is variable depending on how far you've come so that enemies aren't complete pushovers due to your snowball effect.

local marathon_hp_multipliers = {
	100,	-- B1: No buff
	110,	-- B2: 110%
	115,	-- B3: 115%
	120,	-- B4: 120%
	125,	-- B5: 125%
	130,	-- B6: 130%
	130,	-- B7: 130%
}

rawset(_G, "ROGUE_initEnemyStats", function(ename)
	dprint("Attempting roguegen on "..ename)
	local e = enemyList[ename]

	if enemyList[ename] and enemyList[ename].original
		return ename
	end

	-- enemy was already generated for this session.
	if enemyList[ename.."__roguemode"]
		return ename.."__roguemode"
	end

	if not e return end	-- bruh.

	-- copy the table into a new one
	local cpy = {}
	for k,v in pairs(e)
		cpy[k] = e[k]
	end
	cpy.original = ename

	-- the important part now is shuffling affinities from the random seed
	-- First, build our unique enemy seed from the enemy's name:
	local enemyseed = server.rogueseed
	for i = 1, #cpy.name
		local c = cpy.name:sub(i, i)
		enemyseed = $ + c:byte()	-- get the ascii code of the given character
	end
	enemyseed = $ % FRACUNIT		-- make sure it stays between 0 and 65535

	-- ready RNG numbers:
	t, x, y, z, w = 0, enemyseed, enemyseed/2, enemyseed/3, enemyseed/4

	if not cpy.noroguerandom

		local affs = {}
		local aff_max = 10

		for i = 0, aff_max	-- the 11 affinities
			affs[i+1] = 2^i
		end
		-- shuffle that table of affinities

		local shuffled = {}
		while #affs
			local pos = R_RandomRange(1, #affs)
			shuffled[#shuffled+1] = affs[pos]
			table.remove(affs, pos)
		end
		affs = nil

		-- now we have shuffled which is a shuffled version of affs, we can then create a lookup table:
		local aff_lookup = {}
		for i = 0, 10
			aff_lookup[2^i] = shuffled[i+1]
		end


		-- now shuffle enemy affinities:
		local affs = {"weak", "resist", "block", "repel", "drain"}

		for i = 1, #affs do
			local aff = affs[i]
			local newaff = 0
			-- oh boy
			if e[aff]
				dprint("Setting new value for "..aff)
				for j = 0, 10 do

					if e[aff] & (2^j)	-- add the affinity from the
						newaff = $| (aff_lookup[e[aff] & (2^j)])
					end
				end

				cpy[aff] = newaff
			end
		end

		-- Using that same lookup table, change the skills to find the new required elemental skills!
		local newskills = {}
		for i = 1, #e.skills

			local a = attackDefs[e.skills[i]]
			if not a continue end	-- wtf
			dprint("Attempting to change skill "..a.name)

			local atktype = a.type & ~ATK_PASSIVE
			local psv = a.type & ATK_PASSIVE
			local passivetype = a.passive

			if atktype < ATK_FIRE	-- physical attack
			or atktype > ATK_CURSE	-- almighty, support etc
				newskills[#newskills+1] = e.skills[i]
				dprint("Skill type out of range")
				continue	-- ok goodbye asshole
			end

			-- attempt to find a skill with the same power to replace it with.
			-- this is basically intended for use with the basic elemental attacks!

			local targettype = aff_lookup[atktype]
			local found
			for k, p in pairs(attackDefs)	-- yepppppppppppppp

				if p.type and (p.type & ~ATK_PASSIVE) == targettype
				and p.power == a.power
				and p.passive == passivetype
				and a.target == p.target
				and (a.instakill == p.instakill and a.accuracy == p.accuracy)
				and (a.hits or 0) == (p.hits or 0)
				and not p.physical	-- LOL
				and not p.norogue
					newskills[#newskills+1] = k
					dprint("Found skill "..k)
					found = true
					break
				end
			end

			if not found
				newskills[#newskills+1] = e.skills[i]	-- keep the original skill
				continue
			end
		end

		cpy.skills = newskills
	end

	-- make em stronger!!
	cpy.level = $+5	-- (this is only visual)
	if not cpy.noroguebuff

		local mult = 110
		if server.marathon
			mult = marathon_hp_multipliers[server.difficulty]	-- fallback just in case
		end

		local prevhp = cpy.hp
		cpy.hp = $*mult/100
		cpy.sp = $*400/100
		cpy.strength = $*115/100
		cpy.magic = $*115/100
		cpy.agility = $*115/100
		cpy.endurance = $*115/100
		cpy.luck = $*115/100
	end


	-- and finally, add us to the enemy list... dear god that sucked.
	enemyList[ename.."__roguemode"] = cpy

	-- wow, we're done!
	return ename.."__roguemode"	-- yes this is stupid.
end)