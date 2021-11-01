-- this handles tartarus, both building and gameplay.

rawset(_G, "cv_reapertimer", CV_RegisterVar({
  name = "d_reapertimer",
  defaultvalue = 6,
  flags = CV_NETVAR,
  PossibleValue = {MIN = 1, MAX = 30},
})
)

rawset(_G, "cv_reaper", CV_RegisterVar({
  name = "d_reaper",
  defaultvalue = 1,
  flags = CV_NETVAR,
  PossibleValue = CV_OnOff,
})
)

-- thinker for dungeons
--addHook("ThinkFrame", do
rawset(_G, "DNG_Thinker", function()

	if not server return end

	if server.entrycard
		server.entrytime = $-1
		if server.P_DungeonStatus.gameoverfade
			server.P_DungeonStatus.gameoverfade = $-1
		end
		if server.P_DungeonStatus.lifeexplode
			if server.P_DungeonStatus.lifeexplode == 20
			and server.P_BattleStatus and server.P_BattleStatus.lives and server.P_BattleStatus.lives >= 0
				S_StartSound(nil, sfx_mchurt)
			end
			server.P_DungeonStatus.lifeexplode = $-1
		end

		if not server.entrytime
			server.entrycard = nil
			server.entrytime = nil
		end
	end

	if NET_running() return end	-- don't run anything during character selection

	if not server.P_BattleStatus return end

	if gamemap == srb2p.tartarus_play
	or server.gamemode == GM_VOIDRUN
		for i = 1, 4
			if server.P_BattleStatus[i].battlestate ~= BS_MPFINISH
				server.P_BattleStatus[i].netstats.time = $+1
			end
		end
	end

	-- menus & shops:
	for p in players.iterate do
		if p.maincontrol and p.maincontrol.valid
			if server.P_BattleStatus[p.maincontrol.battlen] and server.P_BattleStatus[p.maincontrol.battlen].running continue end	-- nope
		end
		local mo = p.mo
		if not mo continue end
		if DNG_handleShop(mo) continue end		-- in shop, don't open the menus in that case
		if DNG_handleEquipLab(mo) continue end	-- in equip lab, don't open menu either
		D_HandleMenu(mo)	-- let menus open even without net
	end

	for p in players.iterate do
		local btl = server.P_BattleStatus
		if btl and p.P_party
			btl = btl[p.P_party]
			if btl.running continue end
		end

		DNG_HandleAbilities(p, true)
	end

	if not NET_isset() return end	-- wait until we're finished setting up our team in MP

	SRB2P_runHook("DungeonThinker", battle)

	if server.entrytime

		-- voidrun hack
		if server.gamemode == GM_VOIDRUN
		and server.P_DungeonStatus.VR_type == VC_REPEL
		and server.entrytime == TICRATE/2
		and server.P_DungeonStatus.VR_timer ~= nil

			local bwaves = {}
			server.P_DungeonStatus.VR_target = 0

			for i = 1, 3 do
				bwaves[i] = server.waves[P_RandomRange(1, #server.waves)]
				server.P_DungeonStatus.VR_target = $ + #bwaves[i]
			end

			BTL_start(1, bwaves[1])
			server.P_BattleStatus[1].storedwaves = bwaves
		end
		D_voidRun()

		return
	else

		D_tartarusCrawler()
		if server.gamemode == GM_VOIDRUN
			D_voidRun()
			return
		end

		if not mapheaderinfo[gamemap].tartarus
		and not server.cdungeon
			for p in players.iterate do

				if not p.mo or not p.mo.valid continue end

				if D_ReadyBattle(p) continue end

			end
		end
	end
end)

-- for menus:
addHook("PlayerCmd", function(p, cmd)
	local menu = SYS_systemmenu
	if menu.running
		cmd.forwardmove = 0
		cmd.sidemove = 0
		cmd.buttons = 0
	end
end)

addHook("MobjSpawn", function(mo)
	if mapheaderinfo[gamemap].objectscale
	and mo and mo.valid
		mo.scale = mapheaderinfo[gamemap].objectscale*FRACUNIT /100
	end
end)

addHook("MapLoad", do

	if not server return end

	-- NET stuff isn't set??? don't even LOAD, send us back to tartarus!!
	if not NET_isset()
	and gamemap ~= srb2p.tartarus_map
		G_ExitLevel(srb2p.tartarus_map)
		return
	elseif gamemap == srb2p.tartarus_map
		if server.P_BattleStatus
			for i = 1, 4
				server.P_BattleStatus[i].kill = true
			end
			server.P_BattleStatus.kill = true
		end
		server.gamemode = nil
		server.rogueseed = nil
		ROGUE_reset()
		NET_reset()
	end

	-- set titlecard on mapload too
	local t = {}
	if mapheaderinfo[gamemap].entryname
		t[1] = mapheaderinfo[gamemap].entryname
	end
	if mapheaderinfo[gamemap].entryfloor
		t[2] = mapheaderinfo[gamemap].entryfloor
	end
	if #t
		DNG_entryCard(t)
	end

	-- init dungeon section (or floor, in a way)
	server.P_DungeonStatus = {
		savefloor = 0,		-- used to know where was the last starpost
		beatenboss = 0,		-- used to know which parties beat a boss in MP
		section = 1,		-- section (outside of tartarus)
		floor = 0,			-- floor (tartarus)
	}

	server.DNG_entities = {}

	if DNG_isTartarusMap()

		-- we just got into a dungeon, if we MUST load, do it. NOW.
		if server.P_netstat.buffer.load
			print("Loading file data...")
			SAVE_applyFileHeader(server.netgamefile)	-- load data
			server.netgamefile = nil
		end

		if not server.P_DungeonStatus.floor

			if server.gamemode == GM_VOIDRUN
				server.P_DungeonStatus.floor = 1
				D_startEvent(1, "ev_vr1")

			elseif server.cdungeon	-- custom dungeons
				server.P_DungeonStatus.floor = 1
				server.P_DungeonStatus.savefloor = 1

			else

				server.P_DungeonStatus.floor = 2
				-- ^ that's a default
				if server.difficulty
					server.P_DungeonStatus.floor = blockfloor[server.difficulty]
					server.P_DungeonStatus.savefloor = server.P_DungeonStatus.floor
				end
			end
		end

		DNG_setFloor(server.P_DungeonStatus.floor)

		-- 01/11/2021: Only drop save data now as we still need it there
		server.P_netstat.buffer.load = nil		-- drop data

	else
		-- ready waves and items
		-- separate here because DNG_setFloor will do it for tartarus
		DNG_updateWave()
	end

	for p in players.iterate do
		if not p.mo continue end
		local mo = p.mo

		--mo.scale = FRACUNIT*8/10
		if p.charability ~= CA_GLIDEANDCLIMB
		and p.charability ~= CA_TWINSPIN
			p.charability = 0
		end

		mo.pinit = true
		p.awayviewtics = 0	-- ?
		COM_BufInsertText(p, "resetcamera")
		--COM_BufInsertText(p, "cam_dist 256; cam_height 50")
		--P_TeleportMove(p.mo, p.mo.x, p.mo.y, p.mo.z)
	end
end)

-- no spinning
addHook("SpinSpecial", function(p)
	return true
end)

-- no dying
addHook("MobjDeath", function(mo)
	mo.player.lives = 99
	return true
end, MT_PLAYER)


COM_AddCommand("d_spawnreaper", function(p, arg)

	if not cv_debugcheats.value return end

	dprint("DEBUG: "..p.name.." spawned the Reaper")
	D_spawnReaper()
end, 1)

COM_AddCommand("d_skipfloor", function(p)

	if not cv_debugcheats.value return end

	if not p or not p.P_party return end
	if server.P_BattleStatus[p.P_party].running return end	-- cannot be used in battle

	dprint("DEBUG: "..p.name.." skipped the floor")

	for k,v in ipairs(server.DNG_entities)
		if v and v.valid and v.type == MT_REDSPRING
			for p in players.iterate do
				P_TeleportMove(p.mo, v.x, v.y, v.z)
			end
		end
	end
end, 1)

COM_AddCommand("d_revealmap", function(p)

	if not cv_debugcheats.value return end

	if not p.P_party return end
	for i = 1, 2048
		server.rendermap[p.P_party][i-1] = server.map[i-1]
	end
end, 1)

COM_AddCommand("d_allstrong", function(p)

	if not cv_debugcheats.value return end

	if not p.P_party return end
	dprint("oH GOD OH FUcK!!!!")
	for i = 1, #server.DNG_entities
		local s = server.DNG_entities[i]
		if s and s.valid and s.shadowflags ~= nil
			s.shadowflags = $|SHF_STRONG
		end
	end
end, 1)
