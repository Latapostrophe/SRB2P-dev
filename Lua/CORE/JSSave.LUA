-- JSON saving test
local SAVEVER = "1"
local qsavefolder = "client/Quickplay/"
local fileprefix = "srb2p_qsave"
rawset(_G, "MAXQSAVEFILES", 6)

local keys = {
	"SAVEBLOCK_DUNGEON",	-- Tell file reading the next line needs to overwrite dungeon status
	"SAVEBLOCK_BATTLE",		-- Tell file reading the next lines need to overwrite battlestatus[n]
	"SAVEBLOCK_PLAYERS",	-- Tell file reading the next lines overwrite in plentities
	"SAVEBLOCK_ROGUESEED",	-- Tell file reading the next line needs to overwrite rogue seed

	"SAVEBLOCK_END",		-- Returns file reading to initial state (looking for saveblock)
	"SAVEBLOCK_ENDFILE",	-- Stop reading the file

	"SAVEBLOCK_TEAM",		-- for player reading, tell the parser to save the next players in the next team
}

for i = 1, #keys do
	rawset(_G, keys[i], keys[i])
end

/*
	################################
	NETGAME SAVING
	################################
*/

-- Archive server.P_DungeonStatus
local function SAVE_NetArchiveDungeon(f)

	if server.marathon
		server.P_DungeonStatus.difficulty = server.difficulty
	end

	local dng = json.encode(server.P_DungeonStatus)	-- this can be encoded directly.
	f:write(SAVEBLOCK_DUNGEON.."\n")
	f:write(dng.."\n")
	f:write(SAVEBLOCK_END.."\n")
end

-- Archives a single battle and returns the archived string.
rawset(_G, "SAVE_ArchiveBattle", function(btl)
	local save = {
		-- normal values
		n = btl.n,
		macca = btl.macca,

		--saved_affs = btl.saved_affs,
		emeraldpow_max = btl.emeraldpow_max,
		subpersonastock = btl.subpersonastock,

		-- Table entries:
		items = btl.items,
		skillcards = btl.skillcards,
		weapons = btl.weapons,
		armours = btl.armours,
		subpersonas = btl.subpersonas,

		-- NETGAME
		netstats = btl.netstats,
	}
	return json.encode(save)
end)

-- Archive server.P_BattleStatus.
-- This is archived as several tables on different lines.
local function SAVE_NetArchiveBattles(f)

	f:write(SAVEBLOCK_BATTLE.."\n")

	for i = 1, #server.P_BattleStatus

		local btl = server.P_BattleStatus[i]
		local s = SAVE_ArchiveBattle(btl)
		f:write(s.."\n")
	end

	f:write(SAVEBLOCK_END.."\n")
end


-- Encode a single player entity
rawset(_G, "SAVE_ArchivePlayer", function(mo)
	-- only save core important values of our player:
	local save = {
		skin = mo.skin,
		level = mo.level,
		exp = mo.exp,
		levelcap = mo.levelcap,

		maxhp = mo.maxhp,
		maxsp = mo.maxsp,
		realhp = mo.realhp,
		realsp = mo.realsp,
		hp = mo.hp,
		sp = mo.sp,

		strength = mo.strength,
		magic = mo.magic,
		endurance = mo.endurance,
		agility = mo.agility,
		luck = mo.luck,
		realstrength = mo.realstrength,
		realmagic = mo.realmagic,
		realendurance = mo.realendurance,
		realluck = mo.realluck,

		skills = mo.skills,
		skillcard = mo.skillcard,

		weapon = mo.weapon,
		wardring = mo.wardring,

		--persona = mo.persona
	}

	return json.encode(save)
end)

local function SAVE_NetArchivePlayers(f)

	f:write(SAVEBLOCK_PLAYERS.."\n")

	for i = 1, #server.plentities
		for j = 1, #server.plentities[i]
			local s = SAVE_ArchivePlayer(server.plentities[i][j])
			f:write(s.."\n")
		end
		f:write(SAVEBLOCK_TEAM.."\n")	-- For file parser
	end

	f:write(SAVEBLOCK_END.."\n")
end

local function SAVE_NetArchiveRogueSeed(f)
	if server.rogueseed
		f:write(SAVEBLOCK_ROGUESEED.."\n")
		f:write(tostring(server.rogueseed).."\n")
		f:write(SAVEBLOCK_END.."\n")
	end
end

-- Quick saves the game
rawset(_G, "SAVE_QSaveFile", function(filenum)
	-- save battle status
	local filename = qsavefolder..fileprefix..filenum..".sav2"
	local f = io.openlocal(filename, "w")
	-- write file headers
	f:write(SAVEVER.."\n")	-- save version, used for file compatibility

	-- Write relevant data
	SAVE_NetArchiveRogueSeed(f)
	SAVE_NetArchiveDungeon(f)
	SAVE_NetArchivePlayers(f)
	SAVE_NetArchiveBattles(f)

	-- SAVING COMPLETE
	f:write(SAVEBLOCK_ENDFILE)
	f:close()
end)

/*
	################################
	NETGAME LOADING
	################################
*/

-- Overwrite the object's values with that of the table's if applicable
rawset(_G, "SAVE_OverwriteObject", function(obj, t)

	if obj and (obj.valid or obj.valid == nil)
		for k,v in pairs(t)
			obj[k] = v
		end
	end
end)

-- Unarchives dungeon status and writes to the server
local function SAVE_NetUnArchiveDungeon(f)
	local dng = f:read()
	dng = json.decode(dng)
	server.P_DungeonStatus = dng
end

-- Unarchives a single battle status and returns the unarchived table
local function SAVE_NetUnArchiveBattle(s)
	return json.decode(s)
end

-- Unarchives all battle statuses and overwrite the server
local function SAVE_NetUnArchiveBattles(f)

	local r = f:read()
	local nbattle = 1

	while r ~= SAVEBLOCK_END
		local btl = SAVE_NetUnArchiveBattle(r)	-- Get decoded battle
		-- Overwrite battle statuses
		SAVE_OverwriteObject(server.P_BattleStatus[nbattle], btl)
		r = f:read()
	end
end

-- Unarchives a single player and returns the table:
local function SAVE_NetUnArchivePlayer(s)
	return json.decode(s)
end

-- Overwrite players from the plentities list by unarchiving save data
local function SAVE_NetUnArchivePlayers(f)

	local r = f:read()
	local nteam = 1
	local teamslot = 1

	while r ~= SAVEBLOCK_END

		if r == SAVEBLOCK_TEAM
			nteam = $+1
			teamslot = 1
			r = f:read()
			continue	-- switch teams to write into
		end

		local p = SAVE_NetUnArchivePlayer(r)	-- Get player table
		SAVE_OverwriteObject(server.plentities[nteam][teamslot], p)

		teamslot = $+1
		r = f:read()
	end
end

-- Fixes up various oddities such as Sub-Personas & linking them back to their respective player
rawset(_G, "SAVE_FixUps", function()

	for i = 1, 4

		local btl = server.P_BattleStatus[i]

		for j = 1, #btl.subpersonas
			local p = btl.subpersonas[j]

			p.ref = subpersonaList[p.int]

			if p.equipped
				local mo = server.plentities[i][p.equipped]

				if mo.subpersona	-- they... already have one???
					p.equipped = nil	-- then no, i'm free???
				else
					mo.subpersona = p	-- link it back
				end
			end
		end
	end
end)

-- Callback function for QLoad.
-- This is actually where the file is read
-- UNUSED
local function QLoadFile(f)

	local r = f:read()
	-- first line is SAVE VERSION
	if r ~= SAVEVER
		print("File "..qsavefolder..filename..": Save version differs from game client's, aborting.")
		return
	end

	r = f:read()
	while r ~= SAVEBLOCK_ENDFILE
		-- Check for save blocks
		if r == SAVEBLOCK_DUNGEON
			dprint("Read dungeon...")
			SAVE_NetUnArchiveDungeon(f)

		elseif r == SAVEBLOCK_BATTLE
			dprint("Read BattleStatuses...")
			SAVE_NetUnArchiveBattles(f)

		elseif r == SAVEBLOCK_PLAYERS
			dprint("Read Players...")
			SAVE_NetUnArchivePlayers(f)
		end
		r = f:read()
	end
	dprint("Final savefile corrections...")
	SAVE_FixUps()

	-- f:close() doesn't need to be called in a callback
end

-- Send save file to clients and execute the callback above
rawset(_G, "SAVE_QLoadFile", function(filenum)
	local filename = qsavefolder..fileprefix..filenum..".sav2"
	io.open(filename, "r", QLoadFile)
end)

-- reads and returns header from a given file (file must already be opened and ready to read)
local function SAVE_getHeader(f, load)
	-- leave header nil for inexistant files, makes it easier
	if not f
		return false
	end

	local h = {}
	h.usable = true

	local r = f:read()
	-- these types of files can exist if the host tried to load an empty file.
	if not r or r == "\n" or r == "EMPTY"
		return false
	end

	-- Get save version
	if r ~= SAVEVER
		h.text = "\x85".."OLD: SAVE VERSION DOES NOT MATCH"
		h.usable = nil	-- NO!
		return h
	end


	while r ~= SAVEBLOCK_ENDFILE

		if r == SAVEBLOCK_DUNGEON
			-- get floor
			local r = f:read()
			if r == nil or r == ""
				h.text = "\x85".."CORRUPTED: DUNGEON BLOCK INVALID"
				h.usable = nil	-- NO!
				return h
			end

			local dng = json.decode(r)
			h.dng = dng
			h.text = "Marathon, "..dng.floor.."F"

		-- get roguemode seed if necessary
		elseif r == SAVEBLOCK_ROGUESEED
			--print("seed set")
			h.rogueseed = tonumber(f:read())

		elseif r == SAVEBLOCK_BATTLE
			local nbattle = 1
			h.battle = {}

			r = f:read()
			if r == nil or r == ""
				h.text = "\x85".."CORRUPTED: BATTLE BLOCK INVALID"
				h.usable = nil	-- NO!
				return h
			end

			while r ~= SAVEBLOCK_END
				h.battle[nbattle] = SAVE_NetUnArchiveBattle(r)	-- Get decoded battle
				nbattle = $+1
				r = f:read()
			end

		elseif r == SAVEBLOCK_PLAYERS	-- get skin list
			local teamslot = 1
			local teamnum = 1
			h.playerlist = {}
			r = f:read()

			if r == nil or r == ""
				h.text = "\x85".."CORRUPTED: PLAYER BLOCK INVALID"
				h.usable = nil	-- NO!
				return h
			end

			while r ~= SAVEBLOCK_END
				h.playerlist[teamnum] = $ or {}

				if r == SAVEBLOCK_TEAM
					h.teamlen = $ or teamslot-1
					teamslot = 1
					teamnum = $+1
					r = f:read()
					continue
				end

				h.playerlist[teamnum][teamslot] = SAVE_NetUnArchivePlayer(r)

				teamslot = $+1
				r = f:read()
			end
			h.teamlen = $ or teamslot-1	-- just in case
		end

		r = f:read()
	end
	return h
end

-- LOCALLY get all headers for quicksave files.
rawset(_G, "SAVE_GetQFilesHeaders", function()

	local headers = {}
	for i = 1, MAXQSAVEFILES
		local filename = qsavefolder..fileprefix..i..".sav2"

		local f = io.openlocal(filename, "r")
		if not f
			continue
		end
		-- leave header nil for inexistant files, makes it easier
		--print(filename)
		headers[i] = SAVE_getHeader(f)
	end

	return headers
end)

-- Apply header to the game (this is how files are loaded in tartarus netgames)
rawset(_G, "SAVE_applyFileHeader", function(h)

	if not h return end	-- wtf

	-- apply dungeon status
	if h.dng
		server.P_DungeonStatus = h.dng
	end

	-- battle statuses
	if h.battle
		for i = 1, #h.battle
			SAVE_OverwriteObject(server.P_BattleStatus[i], h.battle[i])
		end
	end

	-- as of 1.3.4, try to read what was saved instead of relying on emeraldpow_max as a scapegoat...
	server.difficulty = h.dng.difficulty or server.P_BattleStatus[1].emeraldpow_max

	-- players
	if h.playerlist
		for i = 1, #h.playerlist
			for j = 1, #h.playerlist[i]
				SAVE_OverwriteObject(server.plentities[i][j], h.playerlist[i][j])
			end
		end
	end

	if h.rogueseed
		server.rogueseed = h.rogueseed
	end

	SAVE_FixUps()
end)


-- gets the header of the requested file
-- the callback function instantly saves the header in srb2p.netgamefile *for all clients*
-- srb2p.netgamefile in itself is only used if we explicitely state to use the header in extra data when starting the netgame,
-- so it doesn't NEED to be cleared
rawset(_G, "SAVE_getNetgameFileHeader", function(filenum)
	local filename = qsavefolder..fileprefix..filenum..".sav2"
	local f = io.openlocal(filename, "r")
	io.open(filename, "r", function(f)
		server.netgamefile = SAVE_getHeader(f)
	end)
end)