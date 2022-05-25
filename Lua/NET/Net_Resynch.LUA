-- Lua script dedicated to synching mid-game joiners properly

local NET_JOINTIME = TICRATE*3

-- fix attacks not carrying in $$$.sav for joining players
rawset(_G, "NET_synchAttack", function(mo)
	if mo.attack
		if mo.attackref	-- get from attackref
			local prev = mo.attack.name
			mo.attack = attackDefs[mo.attackref]
			if prev == mo.attack.name
				return	-- we're good
			end
		end

		-- HACK IF attackref IS WRONG
		for _, v in pairs(attackDefs)
			if v.name == mo.attack.name
				mo.attack = v
				break
			end
		end
	end
end)

local netpausetimer = 0

-- Not proud of that one...
addHook("PrePreThinkFrameAndPause", do
	/*
		OKAY, THIS HERE IS A STUPID FUCKING HACK:
		RNG often desyncs if you join mid-game. So we'll force the player in a state the server doesn't like.
		That way the server will resync the player AND the RNG.

		Yes I fucking hate this game
	*/

	-- TLDR: RESYNCH RNG

	if consoleplayer and consoleplayer.valid

		if not SRB2P_synchMyFuckingShit
			if gamemap ~= 1
			and not consoleplayer.aneurysm
				P_DoPlayerPain(consoleplayer)
				-- clientsided pain should give the server an aneurysm and trigger a synch packet.
			end
			consoleplayer.aneurysm = true
		end

		if netpausetimer
			netpausetimer = $-1
			--print(netpausetimer)

			if netpausetimer == NET_JOINTIME - TICRATE
			and SRB2P_synchMyFuckingShit
			and consoleplayer == server
				SRB2P_synchMyFuckingShit()
			end

			if not netpausetimer and paused
			and consoleplayer == server
				COM_BufInsertText(server, "pause")
			end
		end
	end
end)

/*addHook("PlayerJoin", function(node)
	if netgame
	and gamemap ~= srb2p.tartarus_map
	and node
		netpausetimer = NET_JOINTIME
		if not paused
			COM_BufInsertText(server, "pause")
		end
		chatprint("\x82".."*Autopaused to synch new node...")
	end
end)*/

rawset(_G, "NET_draw_synch", function(v)

	if netpausetimer

		v.drawFill(100, 10, 120, 34, 135)
		local dot = string.rep(".", ((NET_JOINTIME-netpausetimer)%39)/10)
		V_drawString(v, 160, 12, "\x82".."COMMUNICATING "..dot, "NFNT", 0, "center", 0, 31)
		V_drawString(v, 160, 22, "Synchronizing data", "NFNT", 0, "center", 0, 31)
		V_drawString(v, 160, 32, "to a new joiner...", "NFNT", 0, "center", 0, 31)
	end
end)

-- for cheaters...
COM_AddCommand("__&cheat", function(p, arg)

	p.unlocks = $ or {}
	arg = tonumber(arg)
	srb2p.local_conds[arg] = nil
	p.unlocks[i] = nil
	print(p.name..", I bet you must really like yaoi. ("..arg..")")
end)

local CHEAT
-- send my unlocks to the server!
COM_AddCommand("__&sendunlocks", function(p, arg)
	if not arg return end
	p.unlocks = $ or {}
	arg = tonumber(arg)
	CHEAT = (not srb2p.local_conds[arg]) and arg or 0	-- I can see you there...
	if p ~= consoleplayer	-- If it's not me, I don't care!
		CHEAT = 0
	end

	--print(p.name..": UNLOCK "..arg.." "..tostring(CHEAT))
	p.unlocks[arg] = true
	dprint("Recived UCOND "..arg.." from "..p.name)
end)

local synchtimer = 0

addHook("NetVars", function(net)
	synchtimer = 0
end)

--addHook("ThinkFrame", do
rawset(_G, "NET_Synch", function()

	-- local checks:
	local dskin = CV_FindVar("defaultskin")
	if charStats[skins[dskin.value].name]
	and not P_unlockedCharacter(skins[dskin.value].name)
		COM_ImmedExecute("defaultskin 0")
		COM_ImmedExecute("skin 0")	-- fuck you
	end

	-- local checks (2)
	dskin = CV_FindVar("skin")
	if charStats[skins[dskin.value].name]
	and not P_unlockedCharacter(skins[dskin.value].name)
		COM_ImmedExecute("skin 0")	-- fuck you
	end

	-- local checks (3)
	if CHEAT
		COM_ImmedExecute("__&cheat "..CHEAT)
		CHEAT = 0
	end

	-- don't use characters we shouldn't be able to use!!

	if not server return end	-- titlemap
	if not netgame return end	-- No need for all that synching BS in singleplayer
	local proceed

	if consoleplayer and consoleplayer.valid
		if not consoleplayer.setunlocks
			for i = 1, 99
				if srb2p.local_conds[i]
					COM_ImmedExecute("__&sendunlocks "..i)	-- funny!
					dprint("Sending UCOND '"..i.."' to server...")
				end
			end
			consoleplayer.setunlocks = true	-- warning, clientside spaghetti.
		end
	end


	synchtimer = $ and $+1 or 1
	if synchtimer <= 10
		if SYS_systemmenu and SYS_systemmenu.menu == 1	-- wtf!
			SYS_closeMenu()	-- just to be sure as that seems to be a reoccuring issue
		end
		proceed = true
	end

	if not proceed return end

	if not server.P_BattleStatus return end	-- lol

	if server.curpreset
		DNG_setextradata(tartarus_floors[server.curpreset])	-- reset extra data for skybox
	end
	
	-- No longer required
	/*for f = 1, 4

		local btl = server.P_BattleStatus[f]
		if not btl return end	-- < true if server itself is joining lol

		for i = 1, #btl.fighters
			local mo = btl.fighters[i]
			if not mo or not mo.valid continue end
			NET_synchAttack(mo)
		end
	end*/
	
	for i = 1, 4
		local btl = server.P_BattleStatus[i]
		for j = 1, #btl.subpersonas
			local per = btl.subpersonas[j]
			per.ref = subpersonaList[per.int]
		end
	end
	
	for i=1, #enemiesrogued
		ROGUE_initEnemyStats(enemiesrogued[i])
	end

	-- fix waves in rogue mode if necessary
	if server.roguemode	-- hahahahaha....
	and server.waves
	and #server.waves
	and server.rogueseed
		for i = 1, #server.waves
			for j = 1, #server.waves[i]
				server.waves[i][j] = ROGUE_initEnemyStats($) or $	-- keep the original enemy if we failed to generate the new enemy
			end
		end
	end	
	
end)