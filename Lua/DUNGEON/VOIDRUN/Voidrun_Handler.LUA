-- some extra voidrun stuff that runs after tartarusHandler()

-- for the status bar
local challengehints = {
	[VC_ERADICATION] = "Kill as many Shadows as possible!",
	[VC_INFILTRATION] = "Collect items and escape The Reaper!",
	[VC_HUNT] = "Lure Golden Shadows in pits!",
	[VC_REPEL] = "Eliminate 3 enemy waves in a row!",
	[VC_EXPLOIT] = "Knock enemies down!",
	[VC_BOSS] = "Defeat the boss enemy!",
}

-- ran out of time!
rawset(_G, "D_VoidRunTimeOut", function()
	
	local dng = server.P_DungeonStatus
	if dng.VR_starttimeout
	and dng.VR_type ~= VC_REPEL	-- the battle will end and this will be handled automatically
		
		dng.VR_starttimeout = nil
		dng.VR_timeout = TICRATE+10
		
	elseif dng.VR_timeout
		dng.VR_timeout = $-1
		
		if dng.VR_timeout == 10
			server.P_DungeonStatus.floor = $+ (server.P_DungeonStatus.VR_floors - server.P_DungeonStatus.VR_floor)+1
			server.P_DungeonStatus.VR_floor = server.P_DungeonStatus.VR_floors+1
			server.P_DungeonStatus.stairsfound = nil
			DNG_setFloor(server.P_DungeonStatus.floor)
			server.reaper = nil		
		end
		
	end	
end)

rawset(_G, "D_voidRun", function()

	local dng = server.P_DungeonStatus
	if dng.VR_timer and not dng.VR_locktimer
		dng.VR_timer = $-1
		
		if not dng.VR_timer
		and dng.VR_type ~= VC_REPEL	-- the battle will end and this will be handled automatically
			dng.VR_starttimeout = true
			-- make shadows run away
			for m in mobjs.iterate()
				if m and m.valid and DNG_isShadow(m)
					m.shadowflags = $|SHF_RUNAWAY
					m.flags = MF_NOBLOCKMAP
				end
			end
		end
		
	elseif dng.VR_timer == nil
	and dng.VR_challenge
	and (dng.VR_challenge+1)%3 == 2
		
		for i = 1, #server.plentities[1] do
			local mo = server.plentities[1][i]
			if mo and mo.valid
				mo.hp = mo.maxhp
				mo.sp = mo.maxsp
			end	
		end
	end
	
	if not server.P_BattleStatus[1].running
		D_VoidRunTimeOut()
	end
end)

-- Sets a new Void Run challenge
-- this is used in tartarus_Gen.lua
rawset(_G, "D_setVoidChallenge", function(c, threshold, floors, clause)

	local dng = server.P_DungeonStatus
	dprint("New void challenge set: "..c)

	-- award previous challenge rewards...
	if dng.VR_challenge
		D_getVoidRunRewards()
	end

	dng.VR_type = c						-- type of the challenge
	dng.VR_score = 0					-- reset score
	dng.VR_target = threshold			-- max score for rwewards
	dng.VR_floors = floors				-- how many floors the challenge spans on
	dng.VR_floor = 0					-- reset the challenge floor we're on
	dng.VR_challenge = $ and $+1 or 1	-- challenge #. Used to know how to scale rewards / enemies
	dng.VR_hint = challengehints[c]
	dng.VR_lives = $ or 5
	dng.VR_clausebuf = clause			-- clause buffer, will only be applied on the next floor with a valid timer field
end)

rawset(_G, "D_getVoidRunRewards", function()
	local dng = server.P_DungeonStatus
	local btl = server.P_BattleStatus[1]

	local maxmacca = 100 + 200*(dng.VR_challenge-1)
	local macca = dng.VR_score * maxmacca / dng.VR_target
	local percent = dng.VR_score*100/dng.VR_target

	btl.macca = $ + macca

	if not percent
		DNG_logMessage("You didn't even try...")
	elseif percent < 25
		DNG_logMessage("You get an E for effort...")
	elseif percent < 50
		DNG_logMessage("Not quite there still...")
	elseif percent < 75
		DNG_logMessage("A commendable effort!")
	elseif percent < 90
		DNG_logMessage("That was a good show!")
	elseif percent < 100
		DNG_logMessage("So close!")
	else
		DNG_logMessage("Perfect performance!")
	end


	DNG_logMessage("Got \x82"..macca..currency)
	local challengenum = dng.VR_challenge%3 or 3
	DNG_logMessage("For Mission #"..(challengenum)..":")

	
	if dng.VR_challenge%3 == 0
		DNG_logMessage("\x82".."CONGRATULATIONS! Challenge #"..(dng.VR_challenge/3).." completed!")
		S_ChangeMusic("SHOP", true, nil, 0, 0, 200)	-- chill music
	end

	-- set possible rewards:
	local rewards = {}
	local last
	-- find rewards table
	for i = 1, dng.VR_challenge
		if VR_itemrewards[i]
			last = i
		end
	end

	if last
		for i = 1, #VR_itemrewards[last]
			local it = VR_itemrewards[last][i]

			if not it[3]
			or percent >= it[3]
				table.insert(rewards, {it[1], it[2]})
				--print("Add reward "..it[1])
			end
		end
		server.items = rewards	-- possible items to get :)
	end
end)

rawset(_G, "D_makeVoidChallenge", function()
	-- creates a random Void challenge
	local dng = server.P_DungeonStatus
	local ctype = dng.VR_type
	
	while ctype == dng.VR_type
		ctype = P_RandomRange(VC_ERADICATION, VC_EXPLOIT)
	end	
	local threshold = 10
 	local floors = 1
	local clause = 0

	local challenge = dng.VR_challenge or 0
	
	if challenge >= 15
	and P_RandomRange(0, 5) == 0
		clause = P_RandomRange(1, 4)
	end
	
	if (challenge+1)%3 == 0
		ctype = VC_BOSS	-- wether you want it or not!
		clause = 0		-- let's be kind and not inflict this upon players...
	end

	-- the first 3 challenges are always set in stone:
	if challenge == 0
		threshold = 5
		floors = 2
		ctype = VC_ERADICATION
	elseif challenge == 1
		floors = 1
		ctype = VC_HUNT
		threshold = 1
	elseif challenge == 2
		floors = 1
		ctype = VC_BOSS
		-- threshold will be dealing enough damage to kill the boss, duh.
	end
	
	-- and now for the ugly part where we determine settings depending on the type past challenge #3
	if challenge >= 3
		if ctype == VC_ERADICATION
			threshold = P_RandomRange(5, 10)
			floors = 2
			
		elseif ctype == VC_INFILTRATION
			floors = 1
			
		elseif ctype == VC_HUNT
			threshold = P_RandomRange(2, 5)
			floors = 1
			
		elseif ctype == VC_REPEL
		
		elseif ctype == VC_EXPLOIT
			threshold = P_RandomRange(6, 12)
		
		elseif ctype == VC_BOSS
			-- nothing!
			
		end
	end
	
	if challenge == 30	-- the last one
		dng.VR_locktimer = true	-- block the timer.
	end

	-- set values
	D_setVoidChallenge(ctype, threshold, floors, clause)
end)

COM_AddCommand("d_vrnotime", function(p)
	server.P_DungeonStatus.VR_timer = TICRATE
end)