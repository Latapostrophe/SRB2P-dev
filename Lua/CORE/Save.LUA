/*

	THIS IS MOSTLY DEPRECATED, CHECK JSSAVE FOR NORMAL GAME SAVING
	This is still used for a few settings file

	Script for save data functions

	@NOTE: Save data is local and cannot be used in netgames under any circumstance.
	Yes, I know that 2.2.4 fixed this with its new I/O implementation but updating the game is just superflux to SRB2P's purposes.

	^ We'll see how well this comment ages.
	^ Edit: It didn't age well at all because we had to adopt this sytem. I hate it.

	@WARNING: *EVERYTHING* in save data makes the assumption that only the first Battle Status will only ever be used.
	So nothing ELSE will be saved.


	@WARNING: As of DEMO RELEASE 1.0.0: Story save does NOT work.
	Must be fixed alongside story mode framework whenever useful.

*/

rawset(_G, "NUMSAVES", 9)
rawset(_G, "saves", {})

for i = 1, NUMSAVES
	saves[i] = "srb2p_save"..i..".sav2"
end
rawset(_G, "extrafile", "client/srb2p_xdata.sav2")		-- general extra game data
rawset(_G, "musicsfile", "client/srb2p_musicdata.sav2")	-- local music data
rawset(_G, "settingsfile", "client/srb2p_settings.cfg")	-- settings	(todo: merge w/ general game data?)

/*
	local temporary save table.
	keeps track of stuff for the session.
	this is what is written to the save file whenever you save.
	and this is where we throw loaded stuff from
*/
rawset(_G, "SAVE_localtable", {})

-- maindata: this is where main data like date is saved.
SAVE_localtable.maindata = {}

-- characterdata: this is where exp, personas and the likes are saved.
SAVE_localtable.characterdata = {}

/*
	itemdata: this is where items get saved.
	Note: items in P_BattleStatus are items that are usable in battle, so on the first item pouch.
	these items are pushed everytime the item table gets updated
	Other items are gear items and key items which aren't accessible by normal means
*/
SAVE_localtable.itemdata = {}

-- dungeondata: this is where dungeon data like safe rooms and triggers are saved
SAVE_localtable.dungeondata = {}

local function ioerror()
	if not io
		srb2p.ioerror = true
		return true
	end
end

if ioerror() return end
local io_open = io.openlocal or io.open
-- use io.openlocal for 2.2.4+ builds

local tag_end = "ENDTAG"
local key_end = "ENDKEY"

-- save character data of all active party members... by clearing it and rewriting it from scratch. Wow...!
-- @TODO: Don't forget to create a function to save the reserve party whenever needed

rawset(_G, "SAVE_put_characterdata", function()
	SAVE_localtable.characterdata = {}

	dprint("Saving character data to local temporary table...")

	for i = 1, #server.plentities[1]
		local mo = server.plentities[1][i]
		dprint("Saving character data for "..mo.skin)

		SAVE_localtable.characterdata[mo.skin] = {
			hp = mo.hp,
			maxhp = mo.maxhp,
			sp = mo.sp,
			maxsp = mo.maxsp,
			level = mo.level,
			exp = mo.exp,
		}
		-- note: to save skills, instead of writing a table inside another table, we're just gonna write separate fields, it's easier for us.
		for j = 1, #mo.skills do
			SAVE_localtable.characterdata[mo.skin]["skill"..j] = mo.skills[j]
		end
		-- save stats:
		local stats = {"strength", "magic", "endurance", "agility", "luck"}
		for j = 1, #stats do
			SAVE_localtable.characterdata[mo.skin][stats[j]] = mo[stats[j]]
		end
		-- save gear
	end

	dprint("Character data succesfully updated")
end)

-- throw saved character data onto our actual characters
rawset(_G, "SAVE_pull_characterdata", function()

	dprint("Pulling character data...")
	for i = 1, #server.plentities[1]
		local mo = server.plentities[1][i]

		-- read from save
		if SAVE_localtable.characterdata[mo.skin]
			dprint("Reading data from local save for "..mo.skin)
			for k, v in pairs(SAVE_localtable.characterdata[mo.skin])
				mo[k] = v
			end
		end

		-- skills are saved in "skill1", "skill2", "skill3"...... etc
		-- put them back into the mo.skills table
		dprint("Processing skills into a table...")
		mo.skills = {}
		for i = 1, 32
			if mo["skill"..i]
				mo.skills[#mo.skills+1] = mo["skill"..i]
			end
		end
	end
end)

-- write character data to the file
local function sav_writecharacterdata(file)

	SAVE_put_characterdata()

	file:write("TAG=CHARACTERDATA\n")

	-- pairs: k is our skin.
	-- we will need to make another pair in there

	for k, v in pairs(SAVE_localtable.characterdata)
		dprint("Saving entry for "..k)
		file:write("KEY="..k.."\n")
		-- iterate through v:
		for _, g in pairs(v)
			dprint("Reading key ".._.." of value "..g)
			file:write(_.."="..g.."\n")	-- save values
		end
		file:write("ENDKEY\n")
	end

	file:write("ENDTAG\n")
end

-- save character data of all active party members... by clearing it and rewriting it from scratch. Wow...!
rawset(_G, "SAVE_put_itemdata", function()
	SAVE_localtable.itemdata = {}

	dprint("Saving item data to local save table...")

	-- start with battle items:
	local key = "battle"
	dprint("Saving Battle items")
	SAVE_localtable.itemdata[key] = {}

	for i = 1, #server.P_BattleStatus[1].items
		local item = server.P_BattleStatus[1].items[i]
		-- we'll save it as "item1name = item1amount"

		SAVE_localtable.itemdata[key][item[1]] = item[2]
	end

	-- continue with gear items:
	dprint("Saving gear items")
	key = "gear"
	SAVE_localtable.itemdata[key] = {}

	-- finish with key items:
	dprint("Saving key items")
	key = "key"
	SAVE_localtable.itemdata[key] = {}

	dprint("Item data succesfully updated")
end)

-- throw saved item data into our relevant item tables
rawset(_G, "SAVE_pull_itemdata", function()

	dprint("Pulling item data...")

	-- start with battle items:
	dprint("Pulling battle items:")
	server.P_BattleStatus.items = {}	-- flush table
	for k, v in pairs(SAVE_localtable.itemdata["battle"])
		server.P_BattleStatus[1].items[#server.P_BattleStatus.items+1] = {k, v}
	end

	dprint("Pulling gear items:")
	-- TODO: gear items

	dprint("Pulling key items:")
	-- TODO: key items

	-- note: all our items are now out of order because 'pairs' is a pretty meh function, we need to sort them
end)

-- write item data to the file
local function sav_writeitemdata(file)

	SAVE_put_itemdata()

	file:write("TAG=ITEMDATA\n")

	-- pairs: k is our item name.
	-- v is our item amount

	file:write("KEY=battle\n")	-- start by saving battle items

	for k, v in pairs(SAVE_localtable.itemdata["battle"])
		dprint("Saving battle item "..k.." ("..v..")")
		file:write(k.."="..v.."\n")
	end
	file:write("ENDKEY\n")



	file:write("KEY=gear\n")	-- now save gear items
	for k, v in pairs(SAVE_localtable.itemdata["gear"])
		dprint("Saving gear item "..k.." ("..v..")")
		file:write(k.."="..v.."\n")
	end
	file:write("ENDKEY\n")


	file:write("KEY=key\n")	-- finally, save key items
	for k, v in pairs(SAVE_localtable.itemdata["key"])
		dprint("Saving key item "..k.." ("..v..")")
		file:write(k.."="..v.."\n")
	end
	file:write("ENDKEY\n")

	file:write("ENDTAG\n")
end

-- save game to given slot.
rawset(_G, "SAVE_savegame", function(slot)
	if netgame
		print("\x82".."ERROR: ".."\x80".."Attempt to save game in netgame. Aborting.")
		return
	end
	local file = io_open(saves[slot], "w")
	if not file return end
	--io.output(file)
	-- also doesn't exist anymore?

	sav_writecharacterdata(file)
	sav_writeitemdata(file)

	io.close(file)
end)

if srb2p.debug
COM_AddCommand("d_savegame", function(player, arg)
	SAVE_savegame(tonumber(arg))
end)
end

-- return both the key and the value of a string made of "key=value"
-- if the value is a number, it's also automatically converted as such
local function sav_readvalue(s)
	local subkey = ""
	local subkeyat

	for i = 1, s:len()
		local ms = s:sub(i, i)
		if ms ~= "="		-- not "=", keep reading
			subkey = $..ms
		else
			subkeyat = i	-- this is where our subkey ends
			break
		end
	end

	-- get value STRING, convert to a number if possible
	local val = s:sub(subkeyat+1)
	if tonumber(subkey) ~= nil
		subkey = tonumber(subkey)
	end
	if tonumber(val) ~= nil
		val = tonumber(val)
	end

	return subkey,val

end

-- read character data and assign it to the local save table
local function sav_readcharacterdata(file)
	SAVE_localtable.characterdata = {}	-- empty this table from whatever it may have contained before

	local s = file:read()

	local key	-- key to write in

	while(s ~= tag_end)	-- read until we arrive at the end of the tag

		-- end of key:
		if s:find(key_end)
			key = nil
			dprint("finished writing on key")
		end

		-- key found, write everything we possibly can!
		if key
			-- here, everything is separated in 2: what is before the "=": the sub-key
			-- and what is after it, the value

			-- read key and value
			local subkey,val = sav_readvalue(s)
			dprint(subkey.."="..val)

			-- affect value:
			SAVE_localtable.characterdata[key][subkey] = val
		end

		-- search for key
		if s:find("KEY=")
			s = s:sub(5)
			key = s
			dprint("Starting to write on key "..key)
			SAVE_localtable.characterdata[key] = {}
		end

		-- keep reading...
		s = file:read()
	end
end

-- read item data and push it to the local save data
local function sav_readitemdata(file)
	SAVE_localtable.itemdata = {}	-- empty this table from whatever it may have contained before

	local s = file:read()

	--local keys = {"battle", "gear", "key"}	-- sub tables to write to
	local key	-- key to write in

	while(s ~= tag_end)	-- read until we arrive at the end of the tag

		-- end of key:
		if s:find(key_end)
			key = nil
			dprint("finished writing on key")
		end

		-- key found, write everything we possibly can!
		if key
			-- here, everything is separated in 2: what is before the "=": the sub-key
			-- and what is after it, the value

			-- read key and value
			local subkey,val = sav_readvalue(s)
			dprint(subkey.."="..val)

			-- affect value:
			SAVE_localtable.itemdata[key][subkey] = val
		end

		-- search for key
		if s:find("KEY=")
			s = s:sub(5)
			key = s:lower()
			dprint("Starting to write on key "..key)
			SAVE_localtable.itemdata[key] = {}
		end

		-- keep reading...
		s = file:read()
	end
end

-- load game from given slot.
rawset(_G, "SAVE_loadgame", function(slot)
	if netgame
		print("\x82".."ERROR: ".."\x80".."Attempt to load game in netgame. Aborting.")
		return
	end

	local file = io_open(saves[slot], "r")
	if not file return end
	io.input(file)

	local s = file:read()

	while(s and s ~= "")
		if s == "TAG=CHARACTERDATA"
			sav_readcharacterdata(file)	-- read all the character data
			SAVE_pull_characterdata()	-- throw it on our actual players
		elseif s == "TAG=ITEMDATA"
			sav_readitemdata(file)		-- read all the item data
			SAVE_pull_itemdata()		-- throw it in our relevant item tables
		end

		s = file:read()	-- keep reading [...]
	end

	io.close(file)
end)

rawset(_G, "SAVE_localmusictable", {

	mus_battle = {"BATL1", "BATL2", "BATL3", "BATL4"},
	mus_battle_pa = {"PADVN1", "PADVN2", "PADVN3", "PADVN4"},
	mus_battle_ea = {"EADVN1", "EADVN2", "EADVN3"},
	mus_battle_s = {"STRNG1", "STRNG2", "STRNG3"},

	mus_battle_mb = {"MBOSS1", "MBOSS2", "MBOSS3"},
	mus_battle_pvp = {"PVP"},

	mus_battle_results = {"RESLT1", "RESLT2", "RESLT3"}
})

-- saves SAVE_localmusictable in musicsfile
rawset(_G, "SAVE_put_musicdata", function()
	local file = io_open(musicsfile, "w")
	if not file
		return
	end

	-- format:
	-- KEY=LUMP1,LUMP2,LUMP3,LUMP4,LUMP5,[...]

	for k,v in pairs(SAVE_localmusictable)

		file:write(k.."=")
		for i = 1, #v
			file:write(v[i]..",")
		end
		file:write("\n")
	end
	file:write(tag_end)

	io.close(file)
end)

-- reads musicsfile and puts it in SAVE_localmusictable
rawset(_G, "SAVE_pull_musicdata", function()

	local t = SAVE_localmusictable
	local file = io_open(musicsfile, "r")
	if not file return end	-- file doesn't exist, so I take it it simply wasn't created! Do nothing

	--io.input(file)
	-- Lat: why was that removed from source!?
	local it = 0

	local s = file:read()
	while (s ~= tag_end)

		-- all lines in this file are formatted with
		local key = ""
		local head = 1
		local tail = 1

		-- read key:
		while s:sub(tail, tail) != "=" and s:sub(tail, tail)
			key = s:sub(head, tail)
			tail = $+1
		end
		-- we are now at '='
		tail = $+1	-- now we should be at the first lumpname!
		head = tail

		local list = t[key]
		local index = 1

		while s:sub(tail, tail) != ""	-- eoline
			it = $+1
			local val = ""

			while s:sub(tail, tail) != ","	-- eolump
				val = s:sub(head, tail)
				tail = $+1
				it = $+1
			end

			list[index] = val	-- add value
			dprint("Added "..val.." to "..key)

			index = $+1	-- table index
			tail = $+1	-- from , to nextlump
			head = tail	-- get head up to date
		end

		s = file:read()

	end
	io.close(file)
end)

rawset(_G, "MUS_PlayRandomBattleMusic", function(tab)
	local t = SAVE_localmusictable[tab]
	if not t or not #t
		print("\x82".."WARNING:".."\x80".." Music table \'"..tab.."\' doesn't exist. Check for typos, dummy!")
		return
	end

	local seed = N_RandomRange(1, #t)
	local mus = t[seed]:upper()

	if mus == "MBOSS3" and not N_RandomRange(0, 9)	-- nothing to see here btw kanade cute <3
		mus = "MBOSSB"
	end

	return mus
end)

SAVE_pull_musicdata()	-- load music data on boot

local XDATA_13_TAG = "XD_13"
-- Main Data (Unlocks & others)
rawset(_G, "SAVE_put_xdata", function()
	local file = io_open(extrafile, "w")
	if not file
		return
	end

	-- write new header
	file:write(XDATA_13_TAG.."\n")
	-- format: raw #

	for i = 1, 99
		if srb2p.local_conds[i]
			file:write(i.."\n")
		end
	end
	file:write(tag_end)


	file:write("\n")
	-- same for challenges
	-- format: challengenum=record
	for i = 1, 128
		if srb2p.challenge_bests[i]
			file:write(i.."="..srb2p.challenge_bests[i].."\n")
		end
	end
	file:write(tag_end)

	io.close(file)
	dprint("Saved xdata.")
end)

local function SAVE_pull_xdata()	-- only performed on game load
	local file = io_open(extrafile, "r")
	if not file
		return
	end

	local r = file:read()
	
	if r ~= XDATA_13_TAG
		io.close(file)
		srb2p.cleared_xdata = true	-- display a message on the title screen
		SAVE_put_xdata()	-- Save the new empty file instead.
		return
	end
	
	r = file:read()	-- keep reading as normal
	
	local n
	local s

	-- unlocks
	while (r ~= tag_end)
		n = tonumber(r)
		if n
			srb2p.local_conds[n] = true
		end
		r = file:read()	-- next line
	end

	-- challenges
	r = file:read()
	while (r ~= tag_end)
		local k, v = sav_readvalue(r)	-- read key,value

		srb2p.challenge_bests[k] = v

		r = file:read()
	end

	io.close(file)
	dprint("Loaded xdata.")
end

SAVE_pull_xdata()	-- read extra files right away

if srb2p.debug
COM_AddCommand("d_loadgame", function(player, arg)
	SAVE_loadgame(tonumber(arg))
end)
end