-- NPC handler code.

rawset(_G, "D_NPCData", {})

/*
	NPCs are a bit of a mess so bear with me:
	
	D_NPCData[mapnum] = {
		
		[npcnum] = {
		
			angle_t angle,					-- spawning angle, 0 by default
			int color,						-- colour of the npc, can be left nil
			int state,						-- state of the npc, can be left nil
			string skin,					-- skin for player-npcs
			
			func thinker(mobj_t npc),		-- thinker for the npc, can be left nil
			
			IT_ interacttype,				-- IT_ constant (Changes what to display...)
			string name,					-- name to display when interacting
			evtindex event,					-- when interacting with the npc, play this event. Can be left nil. 
			func ifunc(obj, pmo)			-- interaction function, can be left nil. obj is the interaction object (obj.tracer is the npc), pmo is the player who interacted.
		},
	}
	
	The mobj's angle is the NPC's id.
	
*/

freeslot("MT_SRB2P_NPC")

mobjinfo[MT_SRB2P_NPC] = {
	doomednum = 895,
	spawnstate = S_PLAY_STND,
	spawnhealth = 1000,
	flags = MF_SOLID,
	radius = 16<<FRACBITS,
	height = 32<<FRACBITS,
}

addHook("MobjThinker", function(mo)
	
	if not mo.extravalue1
	
		local s = mo.spawnpoint
		if not s
			print("No spawnpoint for this NPC?")
			mo.extravalue1 = 1
			return
		end	
		
		local mapdta = D_NPCData[gamemap]
		if not mapdta
			print("No NPC mapdata in map "..gamemap)
			mo.extravalue1 = 1
			return		
		end
		
		local dta = mapdta[s.angle]
		if not dta
			print("No NPC data for npc "..s.angle)
			mo.extravalue1 = 1
			return	
		end		
		mo.dta = dta
		if dta.angle ~= nil
			mo.angle = dta.angle
		end
		
		mo.color = dta.color or $
		mo.state = dta.state or $
		mo.sprite = dta.sprite or $
		mo.frame = dta.frame or $
		
		if dta.skin
			mo.skin = dta.skin or $
		end	
		mo.npcthinker = dta.thinker
		
		if dta.event or dta.ifunc
			local it = P_SpawnMobj(mo.x, mo.y, mo.z, MT_SRB2P_INTERACTION)
			it.tracer = mo
			mo.tracer = it
		end
		
		
		--print("NPC initialized")
		
		mo.extravalue1 = 1
	end	
	
	if mo.npcthinker
		mo.npcthinker(mo)
	end
	
end, MT_SRB2P_NPC)



rawset(_G, "EVT_FindNPC", function(e)
	return D_FindMobjByAngle(MT_SRB2P_NPC, e)
end)

/*
	Initialize the Velvet Room NPC
	NPC slot will always be 1999
	
	Angle sets the door's angle.
*/

rawset(_G, "D_initVelvetRoomNPC", function(mapnum, ang)
	
	local slot = 1999
	
	-- Make sure to intialize NPC data if it hasn't already been.
	D_NPCData[mapnum] = $ or {}	
	
	D_NPCData[mapnum][slot] = {
			
		name = "Velvet Room",
		angle = ang,
			
		thinker = function(mo)
			mo.sprite = SPR_SDOR
			mo.frame = FF_PAPERSPRITE
			mo.radius = 64<<FRACBITS
			mo.height = 256<<FRACBITS
			mo.flags = $|MF_SOLID
			mo.angle = ang + ANG1*90
		end,
			
		interacttype = IT_AREASWITCH,
		targetmap = 6,
		targetid = 0,
		
		tfunc = function(p, pmo)
					pmo.player.obj_velvet_map = gamemap	-- remember what map we were in
				end,
		
		ifunc = function(o, pmo)
					
					D_startEvent(1, "ev_velvetroom_entry1")
					--M_openMenu(pmo, "m_selectfacility")
				end,
	}			
end)



/*
	Initialize party NPCs and the associated events to get them in and out of the party.
	NPC slots are reserved as follow:
	
	2000: Tails
	2001: Knuckles
	2002: Amy
	2003: Metal Sonic
	2004: Shadow
	2005: Blaze
	2006: Silver
	2007: Dr. Eggman
	
	dta is under the following format:
	{
		
		string flag2,	-- Event flag after which characters use their second line.
		
		npcdta = {
			
			[1] = {				-- Tails
				angle_t ang;
				string text1	-- SINGLE LINE of text to say by default
				string text2	-- SINGLE LINE of text to say if flag2 is set
			},
			
			[2] = {				-- Knuckles...
				.....
			},
			
		}
		
		
	}
	
*/

rawset(_G, "D_initPartyNPCs", function(mapnum, dta)
	
	local start = 2000
	local dskins = {
		"tails",
		"knuckles",
		"amy",
		"metalsonic",
		"shadow",
		"blaze",
		"silver",
		"eggman"
	}
	
	local names = {
		"Tails",
		"Knuckles",
		"Amy",
		"Metal Sonic",
		"Shadow",
		"Blaze",
		"Silver",
		"Eggman"
	}
	
	local colours = {
		SKINCOLOR_ORANGE,
		SKINCOLOR_RED,
		SKINCOLOR_ROSY,
		SKINCOLOR_COBALT,
		SKINCOLOR_BLACK,
		SKINCOLOR_LILAC,
		SKINCOLOR_AETHER,
		SKINCOLOR_RED,
	}
	
	D_NPCData[mapnum] = $ or {}	-- Make sure to initialise the data if it hasn't already been.
	
	for i = 1, #dskins do
		local index = start + (i-1)
		print("For i = "..i)
		local skindta = skins[dskins[i]]
		local npcdta = dta.npcdta[i]

		-- ready the events...
		local evti = {}	-- in
		local evto = {}	-- out
		for j = 1, 2
			evti[j] = "party_m"..mapnum.."_"..dskins[i].."in"..j
			evto[j] = "party_m"..mapnum.."_"..dskins[i].."out"..j
			
			-- Invite to party.
			eventList[evti[j]] = {
				[1] = {"text", names[i], j == 1 and npcdta.text1 or npcdta.text2, {{"Add to party", 2}, {"Cancel", -1}}, nil, nil, {charStats[dskins[i]].hudaoa, colours[i]}},
				
				[2] = {"function", 	function(evt, btl)
										
										-- Check if we CAN add the party member...
										local party = server.plentities[btl.n]
										if #party > server.P_netstat.teamlen
											S_StartSound(nil, sfx_not)
											D_setIndex(btl.n, 500)
											return
										end
										
										for k = 1, #server.plreserve
											local mo = server.plreserve[k]
											if mo.name == names[i]
												D_setIndex(btl.n, 520)
												return
											end
										end					
										
										S_StartSound(nil, sfx_not)
										D_setIndex(btl.n, 510)
									end,
				},
				
				[500] = {"text", nil, "Your party is full..."},
				[510] = {"text", nil, "510: Party member does not exist"},
				
				[520] = {"function", 	function(evt, btl)
											
											for k = 1, #server.plreserve
												local mo = server.plreserve[k]
												if mo.name == names[i]
													PLYR_AddFromReserve(k)
													break
												end
											end
											return true
										end,
				}
			}
			
			-- Remove from party
			eventList[evto[j]] = {
				[1] = {"text", names[i], j == 1 and npcdta.text1 or npcdta.text2, {{"Remove from party", 2}, {"Cancel", -1}}, nil, nil, {charStats[dskins[i]].hudaoa, colours[i]}},
				
				[2] = {"function", 	function(evt, btl)
										
										-- Check if we CAN add the party member...
										local party = server.plentities[btl.n]
										if #party < 2
											S_StartSound(nil, sfx_not)
											D_setIndex(btl.n, 500)
											return
										end
										
										D_setIndex(btl.n, 520)
									end,
				},
				
				[500] = {"text", nil, "500: Attempting to remove entity to create empty party?"},
				[510] = {"text", nil, "510: Party member does not exist"},
				
				[520] = {"function", 	function(evt, btl)
											
											for k = 1, #server.plentities[btl.n]
												local mo = server.plentities[btl.n][k]
												if mo.name == names[i]
													PLYR_AddToReserve(mo)
													break
												end
											end
											return true
										end,
				
				}
			}
			
		end
		
		D_NPCData[mapnum][index] = {
			
			skin = dskins[i],
			color = colours[i],
			name = names[i],
			angle = npcdta.angle,
			
			thinker = function(mo)
				mo.state = S_PLAY_STND
				
				if not mo.cusval and server.plreserve
					local exists
					
					for j = 1, #server.plreserve do
						local r = server.plreserve[j]
						
						if r.skin == dskins[i]
							exists = true
							break
						end
					end				

					for j = 1, #server.plentities[1] do
						local r = server.plentities[1][j]
						
						if r and r.valid and r.skin == dskins[i]
							exists = true
							break
						end
					end
					mo.cusval = 1
					
					-- we haven't unlocked this character yet, remove the npc.
					if not exists
						P_RemoveMobj(mo.tracer)
						P_RemoveMobj(mo)
					end
				end
				
			end,
			
			interacttype = IT_TALK,
			ifunc = function(o, pmo)
				
				-- is party member in party or reserve?
				
				local reserve = false
				for i = 1, #server.plreserve do
					local r = server.plreserve[i]
					
					if r.name == o.dta.text
						reserve = true
						break
					end
				end
				
				if reserve	-- in reserve, ask to take in.
					D_startEvent(pmo.player.P_party, evti[1])
				else		-- in party, ask to take out.
					D_startEvent(pmo.player.P_party, evto[1])
				end
			end,
		}
	
	end
end)