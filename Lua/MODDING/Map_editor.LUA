-- SRB2PERSONA DUNGEON EDITOR
-- CREATE & EDIT 48X48 GRID BASED DUNGEONS

if srb2p.debug
COM_AddCommand("mapedit", function(p, arg)
	p.mo.editmode = tonumber(arg)
	PLAY_move(p)
end)
end

local size_x = 48
local size_y = 48

local map = {}
for i = 1, size_x*size_y
	map[i] = 0
end

local mapinfo = {}	-- map block special data
local cursor = 1	-- cursor pos
local infoedit = 0	-- are we editing info??

local function MAP_coord2table(x, y)
	return (y-1)*size_x+x
end

local function MAP_table2coord(i)
	return i-1 - ((i-1) / size_x) * size_x, (i-1) / size_x
end

local function btn(mo, b)
	return mo.P_inputs[b] == 1 or mo.P_inputs[b] > 19
end

local function MAP_setindex(index)
	map[index] = 1
end

local function MAP_removeindex(index)
	map[index] = 0
	mapinfo[index] = nil
end

addHook("ThinkFrame", do
	local p = server
	if not p return end
	if not p.mo return end
	if not p.mo.editmode return end
	PLAY_nomove(p)
	local mo = p.mo
	local cmd = p.cmd

	-- lazy to get my button library, let's do a quickie:


	if btn(mo, "right")
		cursor = not (cursor%size_x) and $-47 or $+1
		if mo.P_inputs[BT_JUMP]
			MAP_setindex(cursor)
		elseif mo.P_inputs[BT_SPIN]
			MAP_removeindex(cursor)
		end

		S_StartSound(nil, sfx_menu1)
	elseif btn(mo, "left")
		cursor = (cursor-1)%48 == 0 and $+47 or $-1
		if mo.P_inputs[BT_JUMP]
			MAP_setindex(cursor)
		elseif mo.P_inputs[BT_USE]
			MAP_removeindex(cursor)
		end
		S_StartSound(nil, sfx_menu1)
	elseif btn(mo, "down")
		cursor = $ + size_x
		if cursor > size_x*size_y
			cursor = $ - size_x*size_y
		end
		if mo.P_inputs[BT_JUMP]
			MAP_setindex(cursor)
		elseif mo.P_inputs[BT_USE]
			MAP_removeindex(cursor)
		end
		S_StartSound(nil, sfx_menu1)
	elseif btn(mo, "up")
		cursor = $ - size_x
		if cursor < 1
			cursor = $ + size_x*size_y
		end
		if mo.P_inputs[BT_JUMP]
			MAP_setindex(cursor)
		elseif mo.P_inputs[BT_USE]
			MAP_removeindex(cursor)
		end

		S_StartSound(nil, sfx_menu1)
	elseif mo.P_inputs[BT_JUMP] == 1
		MAP_setindex(cursor)
		S_StartSound(nil, sfx_menu1)
	elseif mo.P_inputs[BT_USE] == 1
		MAP_removeindex(cursor)
		S_StartSound(nil, sfx_menu1)
	elseif btn(mo, BT_WEAPONNEXT) and map[cursor]
		map[cursor] = map[cursor] == 5 and 1 or $+1
		S_StartSound(nil, sfx_menu1)
	elseif btn(mo, BT_WEAPONPREV) and map[cursor]
		map[cursor] = map[cursor] == 1 and 5 or $-1
		S_StartSound(nil, sfx_menu1)
	elseif btn(mo, 1) and map[cursor]
		map[cursor] = 1
		S_StartSound(nil, sfx_menu1)
	elseif btn(mo, 2) and map[cursor]
		map[cursor] = 2
		S_StartSound(nil, sfx_menu1)
	elseif btn(mo, 3) and map[cursor]
		map[cursor] = 3
		S_StartSound(nil, sfx_menu1)
	elseif btn(mo, 4) and map[cursor]
		map[cursor] = 4
		S_StartSound(nil, sfx_menu1)
	elseif btn(mo, 5) and map[cursor]
		map[cursor] = 5
		S_StartSound(nil, sfx_menu1)
	elseif btn(mo, BT_ATTACK) and map[cursor]
		mapinfo[cursor] = $ or {
			floor = 0,
			ceiling = 256,
			ftexture = "TART_F1",
			ctexture = "PIT",
			brightness = 160,
		}
		print("CREATED DATA FOR BLOCK "..cursor.."\nUSE COMMANDS \'floorz\', \'ceilz\', \'bright\' \'flrtxtr\' and \'celtxtr\' to edit properties,")
		S_StartSound(nil, sfx_menu1)
	elseif btn(mo, BT_FIRENORMAL) and map[cursor] and mapinfo[cursor]
		if mapinfo[cursor] then mapinfo[cursor] = nil end
		S_StartSound(nil, sfx_menu1)
	end
end)

COM_AddCommand("floorz", function(p, arg)
	if not mapinfo[cursor]
		print("ERROR: blockdata not set for this block. Set blockdata before using this command.")
		return
	end

	if tonumber(arg) == nil
		print("ERROR: Invalid data type.")
		return
	end
	mapinfo[cursor].floor = tonumber(arg)
end)

COM_AddCommand("ceilz", function(p, arg)
	if not mapinfo[cursor]
		print("ERROR: blockdata not set for this block. Set blockdata before using this command.")
		return
	end

	if tonumber(arg) == nil
		print("ERROR: Invalid data type.")
		return
	end
	mapinfo[cursor].ceiling = tonumber(arg)
end)

COM_AddCommand("bright", function(p, arg)
	if not mapinfo[cursor]
		print("ERROR: blockdata not set for this block. Set blockdata before using this command.")
		return
	end

	if tonumber(arg) == nil
		print("ERROR: Invalid data type.")
		return
	end

	arg = tonumber(arg)
	if arg < 0 or arg > 255
		print("ERROR: Out of range value. Value must be between 0 and 255")
		return
	end

	mapinfo[cursor].brightness = arg
end)

COM_AddCommand("flrtxtr", function(p, arg)
	if not mapinfo[cursor]
		print("ERROR: blockdata not set for this block. Set blockdata before using this command.")
		return
	end

	mapinfo[cursor].ftexture = arg
end)

COM_AddCommand("celtxtr", function(p, arg)
	if not mapinfo[cursor]
		print("ERROR: blockdata not set for this block. Set blockdata before using this command.")
		return
	end

	mapinfo[cursor].ctexture = arg
end)

COM_AddCommand("save", function()
	print("\x82".."SAVING MAP DATA...")

	-- save the entierety of the map data
	print("map={")
	for i = 1, size_y
		local str = ""
		for j = 1, size_x
			str = $..map[MAP_coord2table(j, i)]..","
		end
		print(str)
	end
	print("},")

	-- save blockdata 1 by 1, separatly.
	print("blockdata={")
	for i = 1, size_x*size_y
		if mapinfo[i]
			print("["..i.."]={floor="..mapinfo[i].floor..",ceiling="..mapinfo[i].ceiling..",bright="..mapinfo[i].brightness..",ftexture="..mapinfo[i].ftexture..",ctexture="..mapinfo[i].ctexture.."}")
		end
	end
	print("}")
	print("\x82".."SAVE COMPLETE!")
end)

COM_AddCommand("wipeblockdata", function()
	mapinfo = {}
end)

COM_AddCommand("wipemap", function()
	for i = 1, size_x*size_y
		map[i] = 0
	end
	mapinfo = {}
end)


local n2color = {
	[T_EMPTY] = 1,			-- walkable
	[T_ITEM] = 83,			-- item
	[T_ENEMY] = 35,		-- enemy
	[T_START] = 152,		-- player spawn
	[T_EXIT] = 115,			-- stairs
}

local n2type = {
	[0] = "(NULL)",
	[T_EMPTY] = "(WALKABLE)",
	[T_ITEM] = "(ITEM)",
	[T_ENEMY] = "(ENEMY)",
	[T_START] = "(SPAWN)",
	[T_EXIT] = "(STAIRS)"
}


hud.add(function(v, p, c)
	if not p.mo.editmode return end
	v.drawFill()
	v.drawFill(126, 4, 192, 192, 253)

	local px, py = MAP_table2coord(cursor)
	-- pos info
	v.drawString(2, 2, "POS: "..px..","..py, V_SNAPTOLEFT|V_SNAPTOTOP)
	v.drawString(2, 10, "RAW: "..cursor, V_SNAPTOLEFT|V_SNAPTOTOP)

	-- block type info
	v.drawString(2, 30, "\x82".."BLOCKTYPE:".."\x80"..map[cursor].."\n"..n2type[map[cursor]] or "(NULL)", V_SNAPTOTOP|V_SNAPTOLEFT|V_RETURN8)

	-- block info
	v.drawString(2, 60, "\x82".."BLOCKDATA:", V_SNAPTOLEFT|V_SNAPTOTOP)

	if not map[cursor]
		v.drawString(2, 68, "CANNOT SET INFO \nON NULL BLOCKS.", V_SNAPTOLEFT|V_SNAPTOTOP|V_RETURN8)
	elseif not mapinfo[cursor]
		v.drawString(2, 68, "NO DATA\nDEFAULT BEHAVIOR\n\x82".."FIRE".."\x80".."=CREATE DATA", V_SNAPTOLEFT|V_SNAPTOTOP|V_RETURN8)
	elseif mapinfo[cursor]
		v.drawString(2, 68, "FLOORZ:"..mapinfo[cursor].floor, V_SNAPTOLEFT|V_SNAPTOTOP)
		v.drawString(2, 76, "CEILZ:"..mapinfo[cursor].ceiling, V_SNAPTOLEFT|V_SNAPTOTOP)
		v.drawString(2, 84, "BRIGHT:"..mapinfo[cursor].brightness, V_SNAPTOLEFT|V_SNAPTOTOP)
		v.drawString(2, 92, "FLRTXTR:"..(mapinfo[cursor].ftexture or "DEFAULT"), V_SNAPTOLEFT|V_SNAPTOTOP)
		v.drawString(2, 100, "CELTXTR:"..(mapinfo[cursor].ctexture or "DEFAULT"), V_SNAPTOLEFT|V_SNAPTOTOP)

		if leveltime%10 < 5
			v.drawString(2, 116, "\x82".."USE CONSOLE", V_SNAPTOLEFT|V_SNAPTOTOP)
		end

		v.drawString(2, 132, "\x82".."FIRENORMAL=DEL", V_SNAPTOTOP|V_SNAPTOLEFT)
	end

	/*
	if not map[cursor]
		v.drawString(2, 28, "NO INFO \nCANNOT SET INFO \nON SOLID BLOCKS.", V_SNAPTOLEFT|V_SNAPTOTOP|V_RETURN8)
	elseif not mapinfo[cusor]
		v.drawString(2, 28, "NO INFO", V_SNAPTOLEFT|V_SNAPTOTOP)
		v.drawString(2, 36, "BLOCK WILL USE \nDEFAULT BEHAVIOR", V_SNAPTOLEFT|V_SNAPTOTOP|V_RETURN8)
	end*/

	local x, y = 0, 0

	for i = 1, size_x*size_y

		if map[i]
			v.drawFill(126 + 4*x, 4 + 4*y, 4, 4, (mapinfo[i] and leveltime%10 >= 5) and 214 or n2color[map[i]])
		end

		x = $+1
		if not (x%size_x)
			y = $+1
			x = 0
		end

	end

	x, y = 0, 0	-- cursor drawing
	for i = 1, size_x*size_y
		if i == cursor
		and leveltime%10 < 5
			-- draw cursor
			v.drawFill(126+(4*x) -1, 4+(4*y) -1, 6, 6, 128)
		end
		x = $+1
		if not (x%size_x)
			y = $+1
			x = 0
		end
	end

end)