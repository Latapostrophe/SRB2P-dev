-- General dungeon stuff:

-- Default reaper timers by difficulty:
rawset(_G, "reapertimers", {

	0,	-- b1: off
	9,	-- b2: 9 minutes / floor
	8,	-- b3: 8 minutes / floor
	7, 	-- b4 and above: 7 minutes / floor
	7,
	7,
	7,
})

-- Dungeon shadow flags:
local shadow_flags = {
	"SHF_STRONG",		-- Red shadows
	"SHF_GOLD",			-- Gold shadows
	"SHF_DISTRESSED",	-- Distressed shadow (will run away from players it sees)
	"SHF_RUNAWAY",		-- Shadow scared away by the Reaper, intangible
}

for i = 1, #shadow_flags do
	rawset(_G, shadow_flags[i], 2^(i-1))
end

rawset(_G, "DNG_isTartarusMap", function()
	return (gamemap ~= srb2p.tartarus_map) and (gamemap == srb2p.tartarus_play or server.gamemode == GM_VOIDRUN or mapheaderinfo[gamemap].randomdungeon)
end)

rawset(_G, "DNG_isShadow", function(mo)
	return mo.shadowflags ~= nil	-- source: trust me
end)

-- Entry card display
rawset(_G, "DNG_entryCard", function(t, fade)
	--dprint("Starting entry card...")
	server.entrycard = t
	server.entrytime = TICRATE*2
end)

-- Handle menu opening within dungeons for a player
rawset(_G, "D_HandleMenu", function(mo)
	-- open menu:
	local inputs = mo.P_inputs
	local openmenu = "main"

	-- exception: tartarus lobby
	if gamemap == srb2p.tartarus_map
	and not mo.m_menu
		-- always consider p1's as server
		local thisp = mo.player
		for p in players.iterate do	-- < take first p that exists (aka not server in dedi)
			if p.mo and p.mo.valid
				thisp = p
				break
			end
		end

		if mo.player == thisp
			openmenu = "mpselect_main"
			--openmenu = "m_selectfacility"
			if inputs[BT_USE]==1
				M_openMenu(mo, openmenu)
				inputs[BT_USE] = 2	-- fixes a little bug
			end
		end
		M_handleMenu(mo)

		if not mo.m_menu
			PLAY_move(mo.player)
		end

		return
	end

	if mo.player.P_spectator
		openmenu = "spectate_jointeam"
	end

	if not mo.m_menu
	and (mo.player.P_spectator or not (server.P_DialogueStatus and server.P_DialogueStatus[mo.player.P_party] and server.P_DialogueStatus[mo.player.P_party].running))
		if inputs[BT_USE]==1
		and P_IsObjectOnGround(mo)
			M_openMenu(mo, openmenu)
			inputs[BT_USE] = 2	-- fixes a little bug
		end
	end
	M_handleMenu(mo)
end)

-- damage object (p entity object, not actual player)
rawset(_G, "DNG_Damage", function(mo, d)
	mo.damagetaken = $ and $+d or d
	mo.damaged = 1
	mo.damage_wait = 0
	mo.damagestate = DMG_NORMAL
	if d < 0
		mo.redhp = $ or mo.hp
		mo.redhp = max($, mo.hp)
		mo.redhp = min(mo.maxhp, $ - d)
	else
		mo.redhp = $ or mo.hp
		mo.redhp = max($, mo.hp)
		mo.hp = max(1, $-d)
	end
end)

-- In SRB2, loading a new map would normally cause us to lose all our data (that sucks!)
-- So let's not lose that data.
-- Load a new map while keeping all our status.
-- We'll do that by using JSON serialization

rawset(_G, "DNG_loadNewMap", function(mapnum)

	if not server or not server.valid return end
	if server.buf_battles or server.buf_players or server.buf_dungeon return end	-- already in progress

	server.buf_battles = {}
	server.buf_players = {}
	server.buf_dungeon = {}

	for i = 1, 4
		if server.P_BattleStatus[i]
			server.buf_battles[i] = SAVE_ArchiveBattle(server.P_BattleStatus[i])
		end

		if server.plentities[i]
			server.buf_players[i] = {}
			for j = 1, server.P_netstat.teamlen
				if server.plentities[i][j]
					server.buf_players[i][j] = SAVE_ArchivePlayer(server.plentities[i][j])
				end
			end
		end
	end

	--server.buf_dungeon = SAVE_ArchiveDungeon()
	--print("Map Load save point created")
	G_SetCustomExitVars(mapnum, 2)
	G_ExitLevel()
end)

-- Apply the stuff set here if possible
addHook("MapLoad", do

	if not server or not server.valid return end

	if server.buf_battles
		--print("Loading map load save point")
		for i = 1, 4

			if server.P_BattleStatus[i]
				SAVE_OverwriteObject(server.P_BattleStatus[i], json.decode(server.buf_battles[i]))
			end

			if server.plentities[i]
				for j = 1, server.P_netstat.teamlen do
					if server.plentities[i][j]
						SAVE_OverwriteObject(server.plentities[i][j], json.decode(server.buf_players[i][j]))
					end
				end
			end
		end

		SAVE_FixUps()	-- Fix subpersona linking
	end

	server.buf_battles = nil
	server.buf_players = nil
	server.buf_dungeon = nil
end)
