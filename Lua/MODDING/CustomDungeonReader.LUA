-- Custom dungeon reader for SRB2P

local P_customDungeons = {}

local function addCustomDungeon(t)
	P_customDungeons[#P_customDungeons+1] = t
end

rawset(_G, "P_getCustomDungeon", function(n)
	return P_customDungeons[n]
end)

/*
	P_registerCustomDungeon(table_t t)
	Registers a new custom dungeon from the data supplied in t	
*/

local function validateAnimTable(t)
	
	if not t return true end	-- no table is fine too
	
	assert(type(t[1]) == "number", "Provided sprite is not a number or is nil.")
	
	for i = 2, #t-1
		assert(type(t[i]) == "number", "Animation frame key "..i.." is not a number.")
	end
	
	if t[1] == SPR_PLAY
		assert(type(t[#t-1]) == "number", "Provided duration is not a number.")
		assert(type(t[#t]) == "string", "Animation table uses SPR_PLAY but doesn't assign a proper SPR2_ sprite2.")
	else
		assert(type(t[#t]) == "number", "Provided duration is not a number.")
	end
	
	return true
end

rawset(_G, "P_registerCustomDungeon", function(t)
	
	assert(type(t) == "table", "P_registerCustomDungeon: Supplied parameter is not a table?")
	
	print("\x82".."Registering Custom Dungeon, please wait while we validate the supplied data...")
	
	-- validate the fields of the table
	local dungeon_index = #P_customDungeons
	
	-- Header info
	t.name = type(t.name) == "string" and $ or "Custom Dungeon #"..dungeon_index
	t.description = type(t.description) == "string" and $ or "No info"
	
	
	-- Starting level, generation difficulty, amount of floors
	t.level = type(t.level) == "number" and clamp($, 1, 99) or 1
	t.levelcap = type(t.levelcap) == "number" and clamp($, t.level, 99) or 1
	t.gensize = type(t.gensize) == "number" and clamp($, 1, 6) or 1	-- this also affects the odds of cursed cards appearing
	t.floors = type(t.floors) == "number" and max($, 1) or 1
	t.reapertimer = type(t.reapertimer) == "number" and clamp($, -1, 16) or 0
	t.allowinterference = type(t.allowinterference) == "boolean" and $ or false
	t.skynum = type(t.skynum) == "number" and $ or 1
	t.maxep = type(t.maxep) == "number" and clamp($, 0, 7) or 0
	
	t.ceilingheight = type(t.ceilingheight) == "number" and clamp($, 80, 32767) or 256
	t.wallheight = type(t.wallheight) == "number" and clamp($, 0, t.ceilingheight) or t.ceilingheight
	
	t.armour_adddef = type(t.armour_adddef) == "number" and max(1, $) or 0
	t.weapon_addpow = type(t.weapon_addpow) == "number" and max(1, $) or 0
	
	-- textures:
	t.floortextures = type(t.floortextures) == "string" and $ or "TART_F"
	t.pittexture = type(t.pittexture) == "string" and $ or "PIT"
	t.startwalltexture = type(t.startwalltexture) == "string" and $ or "TART_W1"
	t.ceilingtexture = type(t.ceilingtexture) == "string" and $ or "~PIT"
	t.texturerange = type(t.texturerange) == "number" and $ or 1
	t.brightness = type(t.brightness) == "number" and clamp($, 0, 255) or 224

	t.shadowframes_stop = type(t.shadowframes_stop) == "table" and $ or nil
	t.shadowframes_move = type(t.shadowframes_move) == "table" and $ or nil
	t.shadowframes_float = type(t.shadowframes_float) == "table" and $ or nil
	-- other cool dunegon stuff!
	t.dungeonmusic = type(t.dungeonmusic) == "string" and $ or 0	-- ???
	
	/*t.battlemusics = type(t.battlemusics) == "table" and $ or nil
	if t.battlemusics
		for i = 1, #t.battlemusics do
			assert(type(t.battlemusics[i]) == "string", "One or more battle music is not a string.")
		end
	end*/	

	-- validate shadow animations:
	validateAnimTable(t.shadowframes_stop)
	validateAnimTable(t.shadowframes_move)
	validateAnimTable(t.shadowframes_float)

	-- Shuffle time stuff...
	t.shufflelevel = type(t.shufflelevel) == "number" and clamp($, 1, 10) or 1	-- max level of numbered cards
	t.shufflepersonas = type(t.shufflepersonas) == "table" and $ or {}
	
	-- Check for the sub personas's existence...
	local i = #t.shufflepersonas
	while i
		
		local pp = t.shufflepersonas[i]
		if not subpersonaList[pp]
			print("\x82".."WARNING: ".."\x80".."The Sub-Persona '"..pp.."' doesn't exist and will be removed from dungeon '"..t.name.."'")
			table.remove(t.shufflepersonas, i)
			continue
		end
		i = $-1
	end
	
	-- Shop
	t.shop = type(t.shop) == "string" and $ or "velvet_shop_mp1"
	assert(shopList[t.shop], "Shop '"..t.shop.."' does not exist in shopList[]")
	
	-- Check for item drops!
	t.itemdrops = type(t.itemdrops) == "table" and $ or {}
	i = #t.itemdrops
	while i
		
		local it = t.itemdrops[i]
		-- verify item...
		if not it[2] or type(it[2]) ~= "number" or it[2] <= 0
			print("\x82".."WARNING: ".."\x80".."Item index '"..i.."' has no drop odds.")
			table.remove(t.itemdrops, i)
			continue
		end
		
		-- check what the item is and act on it!
		
		-- normal items
		if type(it[1]) == "string"
			-- it's a normal item
			if not itemDefs[it[1]]
				print("\x82".."WARNING: ".."\x80".."Item '"..it[1].."' does not exist.")
				table.remove(t.itemdrops, i)
				continue
			end
		
		elseif type(it[1]) == "table"	-- rings/weapons/series drop?
			
			local tt = it[1]
			if tt[1] ~= "ring"
			and tt[1] ~= "weapon"
			and tt[1] ~= "series"
				print("\x82".."WARNING: ".."\x80".."Item index '"..i.."' Unknown parameter. Use 'series', 'weapon' or 'ring'")
				table.remove(t.itemdrops, i)
				continue
			end
			
			-- check for ring...
			if tt[1] == "ring"
				if not ringsList[tt[2]]
					print("\x82".."WARNING: ".."\x80".."Ring '"..tostring(tt[2]).."' does not exist.")
					table.remove(t.itemdrops, i)
					continue					
				end
			
			-- check for weapons
			elseif tt[1] == "weapon"
				if not weaponsList[tt[2]]
					print("\x82".."WARNING: ".."\x80".."Weapon '"..tostring(tt[2]).."' does not exist.")
					table.remove(t.itemdrops, i)
					continue					
				end

			elseif tt[1] == "series"
				if not weaponSeries[tt[2]]
					print("\x82".."WARNING: ".."\x80".."Weapon Series '"..tostring(tt[2]).."' does not exist.")
					table.remove(t.itemdrops, i)
					continue					
				end
			end	
			
		end
		
		i = $-1
	end
	
	--... and now... enemies.....
	t.enemies = type(t.enemies) == "table" and $ or {}
	
	-- remmeber how enemies are set up:
	/*
	
	enemies = {	t.enemies
		
		[floornum] = {	t2	(t.enemies[floornum])
			
			-- enemy wave
			{					t3	t.enemies[floornum][x]
				"enemy 1",			e	t.enemies[floornum][x][y]
				"enemy 2",
				"enemy 3"
			},
			
			-- other enemy wave
			{
				"enemy_5",
				"enemy_1",
			},
		},
		
		[floornum-2] = {
			etc
		},
		
	}
	
	*/
	
	for i, t2 in pairs(t.enemies)	-- we have to use pairs to iterate this
		assert(type(t2) == "table" and #t2, "Floor "..i..", no enemy list")
		
		-- t2 = t.enemies[i]
		
		local j = #t2	-- waves
		while j
			local t3 = t2[j]	-- t.enemies[i][j]
			assert(type(t3) == "table" and #t3, "Enemy wave "..j.." in floor "..i.." is not a table or has no length.")
			local k = #t3
			while k
				
				local en = t3[k]	-- t.enemies[i][j][k]
				if not enemyList[en]
					print("\x82".."WARNING: ".."\x80".."Enemy '"..tostring(en).."' does not exist.")
					table.remove(t3, k)
					if not #t3
						table.remove(t2, j)	-- remove the whole wave if no enemies are valid
						-- some dumbasses will make that happen, i promise
						break
					end
					
					continue
					
				end
				k = $-1
			end	
			j = $-1
		end
	end
	
	-- and finally, the floors....
	/*
	[3] = {
		map = nil,
		blockdata={
		},
		default={
			floorpic = "TART_",
			walltexture = "TART_W1",	-- TART_W1
			texturerange = 1,	-- how far away from walltexture can we randomize? (only increments)
			colormapindex = 1,	-- shift down the colormap layer by 2048 n times
			brightness = 145,	-- brightness in tartarus
			skyboxindex = 0, -- skybox p #
			arenaindex = 0,	-- arena p #
		}
	},	
	
	this is the format followed internally, but we'll dumb it down:
	[floornum] = {
		
		map = mapdata or nil
		
		
	}	
	
	*/
	
	t.floordata = type(t.floordata) == "table" and $ or nil
	if not t.floordata
		print("No floor data was supplied. Defaults will be used.")
		-- Let's make one ourselves
		t.floordata = {
			-- we'll supply a default first and last floor.
			
			[1] = {
				map = nil,
				noreaper = nil,
			},
			
			[t.floors] = {
				map = BOSSFLOOR,
				eventdir = 270,
				spawndir = 90,
				noreaper = true,
			}
			
		}
	end
	-- we also need to use pairs to iterate this table...
	for k, p in pairs(t.floordata)
		
		assert(type(k) == "number", "Invalid non-numerical key in floordata table")
		assert(k <= t.floors and k > 0, "Floordata contains data at index "..k..", outside of the dungeon's floor range (1 - "..t.floors..")")
		
		-- iterate all the values from our floor:
		if p.map
			p.eventdir = $ or 0
			p.spawndir = $ or 0
			p.shopdir = $ or 0
		else
			p.eventdir = nil
			p.spawndir = nil
			p.shopdir = nil	-- don't need it.
		end
		
	end
	
	
	-- last minute check:
	if not t.enemies[t.floors]
		print("\x81".."SUGGESTION:".."\x80".." You don't have a specific enemy wave to use as final boss in your last floor, the game will not end unless an enemy with an 'endboss' field is defeated.")
	
	elseif t.enemies[t.floors][1][1]
		local en = enemyList[t.enemies[t.floors][1][1]]
		if not en.endboss
			print("\x81".."SUGGESTION:".."\x80".." Your final boss enemy does not have a valid 'endboss' field and the game will not end upon its defeat.")
		end
		
		if #t.enemies[t.floors][1] > 1
			print("\x81".."SUGGESTION:".."\x80".." Your final boss wave has more than one enemy, behaviour is unknown.")
		end
	end
	
	-- remove unecessary variables...
	local whitelistvars = {
		"name",
		"description",
		"level",
		"levelcap",
		"shop",
		"gensize",
		"dungeonmusic",
		--"battlemusics",
		"floors",
		"shufflelevel",
		"shufflepersonas",
		"itemdrops",
		"enemies",
		"floordata",
		"floortextures",
		"ceilingtexture",
		"brightness",
		"useautotile",
		"startwalltexture",
		"texturerange",
		"weapon_addpow",
		"armour_adddef",
		"skynum",
		"reapertimer",
		"allowinterference",
		"pittexture",
		"ceilingheight",
		"wallheight",
		"walltoptexture",
		"maxep",
		"shadowframes_float",
		"shadowframes_move",
		"shadowframes_stop",
	}
	
	for k, p in pairs(t)
		local found
		for i = 1, #whitelistvars
			if k == whitelistvars[i]
				found = true
				break
			end	
		end
		
		if not found
			print("\x82".."WARNING: ".."\x80".."Unknown variable '"..k.."'")
			t[k] = nil
		end
	end
	
	
	-- aaand we should be good...
	print("\x82".."Dungeon '"..t.name.."' has been succesfully registered.")
	addCustomDungeon(t)
	
end)