-- General dungeon stuff:

-- Story mode: Deterministic item tables
/*
	DNG_itemBoxes[mapnum] = {

		-- item boxes with NO ANGLE use the AREA DROP TABLE

		[1] = {	-- ITEM BOX ANGLE.
			{"itemname", quantity},
			{{"weapon", "weaponname"}, quantity},
			[...] -- same as item odds, but odds are quantity instead.
		},
	}


	DNG_areaDropTables[mapnum] = {

		-- Generally 1, but dungeons can have multiple "areas"
		[areanum] = {
			-- works the same as tartarus drop tables
		},

	}
	
	DNG_shadowSprites[mapnum] = {
		
		{SPR_SPRITE, FRAME, FRAME, FRAME, dur},	-- stop
		{SPR_SPRITE, FRAME, FRAME, FRAME, dur},	-- move
	}
	
	DNG_interactiveObjects[mapnum] = {
		
		[id] = {
			
			type = IT_,			-- IT_CONSTANT
			
			-- any:
			text = txt,			-- text to display under the thingy thing.
			radius = rr,		-- radius the area travel point detects the player from.		
			usefade = boolean,	-- if true, func() will be run after a fade, if not, runs instantly when pressing C
			nostop = boolean,	-- if true, doesn't stop the player when interacting
			noangle = boolean,	-- if true, the player and the eventual npc don't face each other.
			
			func = function(obj, pmo),	-- < obj is the area object, pmo is the player.
			-- runs besides the normal generic function for the IT_CONSTANT
			
			tfunc = function(obj, pmo)
			-- runs as soon as we press C. Useful for IT_AREASWITCH, redundant otherwise.
			
			evt = eventindex,	-- event index to run. Starts the event after executing func() if possible.
			
			-- for map switching (IT_AREASWITCH)
			targetmap = nn,		-- switches map if targetmap ~= gamemap obv	
			targetid = id,		-- teleports you to the targetmap's designated area travel point.
			targetangle = ang,	-- sets the angle after teleport.

			
			
		}
		
	}
	
*/
freeslot("MT_SRB2P_INTERACTION")
mobjinfo[MT_SRB2P_INTERACTION] = {
	doomednum = 896,
	spawnstate = S_INVISIBLE,
	flags = MF_NOGRAVITY,
	radius = 16<<FRACBITS,
	height = 32<<FRACBITS,
}

-- IT flags for interaction objects
rawset(_G, "IT_INTERACTION", 1)		-- normal interaction object, runs func
rawset(_G, "IT_AREASWITCH", 2)		-- uses targetmap, targetid
rawset(_G, "IT_TALK", 3)			-- used for NPCs, works the same as IT_INTERACTION but displays "TALK"

rawset(_G, "DNG_itemBoxes", {})
rawset(_G, "DNG_areaDropTables", {})
rawset(_G, "DNG_shadowSprites", {})
rawset(_G, "DNG_interactiveObjects", {})


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

	if not mo.m_menu
	and not (server.P_DialogueStatus and server.P_DialogueStatus[mo.player.P_party] and server.P_DialogueStatus[mo.player.P_party].running)
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

-- starts a 20 tics fade that executes 'fn' at its peak (10)
-- Intended for use with area switches, events... etc.
rawset(_G, "DNG_fade", function(fn, col)
	local colour = 31
	if col != nil
		colour = col
	end	
	
	server.fadedta = {
		timer = 20,
		colour = colour,
		func = fn,
	}
	
	for p in players.iterate do
		if p and p.mo and p.mo.valid
			PLAY_nomove(p)	-- lock all players.
		end
	end
end)

-- In SRB2, loading a new map would normally cause us to lose all our data (that sucks!)
-- So let's not lose that data.
-- Load a new map while keeping all our status.
-- We'll do that by using JSON serialization

-- Data saved in srb2p. will be carried over as it is local and not tied to mobjs.

rawset(_G, "DNG_loadNewMap", function(mapnum, evt)

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
	
	-- if requested, we can buffer an event to run it as soon as the next map loads...
	-- see Event_Handler
	if evt
		server.evt_mapbuffer = evt
	end	
	
	--server.buf_dungeon = SAVE_ArchiveDungeon()
	--print("Map Load save point created")
	G_SetCustomExitVars(mapnum, 2)
	G_ExitLevel()
end)

-- change dungeon section.
rawset(_G, "DNG_changeSection", function(section)
	
	local dng = server.P_DungeonStatus
	
	dng.section = section
	BTL_updateArenaCenter()
	DNG_updateWave()
end)

-- areatravel
local text_by_type = {
	[IT_INTERACTION] = "CHECK",
	[IT_TALK] = "TALK",
	[IT_AREASWITCH] = "GO",
}

addHook("MobjThinker", function(mo)
	
	-- interaction point is from an NPC
	if not mo.dta
		if mo.tracer and mo.tracer.valid 
			local npc = mo.tracer
			-- build data from the npc's data
			mo.dta = {
				text = npc.dta.name or "",
				evt = npc.dta.event,
				type = npc.dta.interacttype or IT_TALK,
				targetmap = npc.dta.targetmap,
				targetid = npc.dta.targetid,
				func = npc.dta.ifunc,
				tfunc = npc.dta.tfunc,
			}
			
		else	-- interaction point is its own mapthing
			if not DNG_interactiveObjects[gamemap] return end
			if not DNG_interactiveObjects[gamemap][mo.spawnpoint.angle] return end		
			mo.dta = DNG_interactiveObjects[gamemap][mo.spawnpoint.angle]
		end	
	end
	
	local pmo = players[0].mo	-- don't do an iteration, it's slow.
	local dist = mo.dta.radius or 128
	local indist = false
	
	if mo.spawnpoint and mo.spawnpoint.valid and mo.spawnpoint.options & 8	-- check for same sector tag
		indist = mo.subsector.sector.tag == pmo.subsector.sector.tag 
	else							-- check for distance
		indist = R_PointToDist2(mo.x, mo.y, pmo.x, pmo.y) < dist*FRACUNIT and abs(mo.z - pmo.z) < dist*FRACUNIT and pmo.z >= mo.z
	end
	
	if pmo.valid and indist
	and not pmo.player.SRB2PSTASIS
		
		pmo.obj_interact_target = mo
		pmo.obj_interact = $ and $+1 or 1
		pmo.obj_interact_dta = {text_by_type[mo.dta.type] or "CHECK", mo.dta.text or ""}
		
		if pmo.P_inputs[BT_BTNC] == 1
			
			local usefade = mo.dta.usefade
			local rfunc
			
			if mo.dta.type == IT_AREASWITCH
				usefade = true
				
				if mo.dta.tfunc
					mo.dta.tfunc(mo, pmo)
				end	
				
				rfunc = 	function()
					
								if mo.dta.targetmap == gamemap or not mo.dta.targetmap
									local target = D_FindMobjByAngle(MT_SRB2P_INTERACTION, mo.dta.targetid)
									if not target
										target = D_FindMobjByAngle(MT_SRB2P_NPC, mo.dta.targetid)
										
										if not target
											print("Interaction object #"..mo.spawnpoint.angle..": invalid target #"..tostring(mo.dta.targetid))
											return
										end	
									end
									
									local distfrom = 192
									if mo.dta.targetangle ~= nil
										pmo.angle = mo.dta.targetangle
									end
									
									P_TeleportMove(pmo, target.x + distfrom*cos(pmo.angle), target.y + distfrom*sin(pmo.angle), target.z)
									
									if mo.dta.func
										mo.dta.func(mo, pmo)
									end
									
									
									pmo.obj_interact_target = nil
									pmo.obj_interact = nil
									pmo.obj_interact_dta = nil
									
									if mo.dta.evt
										D_startEvent(pmo.player.P_party, mo.dta.evt)
									end
									
								else
									
									local p = server
									
									-- will be handled on map load.
									p.obj_interact_map = {mo.dta.targetid or 0, mo.dta.targetangle or 0, mo.dta.func}
									-- @TODO: save which shadows have been interacted with to not respawn them on a param?
									
									DNG_loadNewMap(mo.dta.targetmap, mo.dta.evt)
								end
							end
				
				
			else	-- IT_INTERACTION / IT_TALK
			
				-- make the player stop
				if not mo.dta.nostop
					P_InstaThrust(pmo, 0, 0)
				end
				
				-- make the player face the object
				if not mo.dta.noangle
					--pmo.angle = R_PointToAngle2(pmo.x, pmo.y, mo.x, mo.y)
					if mo.tracer and mo.tracer.valid
						mo.tracer.angle = R_PointToAngle2(mo.tracer.x, mo.tracer.y, pmo.x, pmo.y)
					end
				end
				
				rfunc = 	function()
								mo.dta.func(mo, pmo)
								pmo.obj_interact_target = nil
								pmo.obj_interact = nil
								pmo.obj_interact_dta = nil

								if mo.dta.evt
									D_startEvent(pmo.player.P_party, mo.dta.evt)
								end
								
							end
			end

			if usefade
				DNG_fade( function() rfunc() end)
			else
				rfunc()
			end
		end
	-- remove data if we're out of range from this specific point.	
	elseif pmo.obj_interact_target == mo
		pmo.obj_interact_target = nil
		pmo.obj_interact = nil
		pmo.obj_interact_dta = nil
	end
	
end, MT_SRB2P_INTERACTION)

-- This table nets us a total of 308 skillpoints, 
-- total cost to max all skills is currently 294 so this needs tweaking
local LiNKPointTable = {
	[1] = 1,
	[10] = 2,
	[20] = 2,
	[30] = 3,
	[40] = 3,
	[50] = 3,
	[60] = 4,
	[70] = 4,
	[80] = 4,
	[90] = 5,
}

local function getLiNKPoint(level)
	local pts = 0
	for i = 1, level
		if LiNKPointTable[i]
			pts = LiNKPointTable[i]
		end
	end
	return pts
end

rawset(_G, "LiNK_getEXP", function(exp)
	-- FIXME: This should have an Episode level limit
	if srb2p.storydata.linklvl == 99 and srb2p.storydata.linkexp == 100 then return end
	srb2p.storydata.linkexp = $ + exp
	if srb2p.storydata.linkexp >= (100*(srb2p.storydata.linklvl)) and srb2p.storydata.linklvl < 99
		while srb2p.storydata.linkexp >= (100*(srb2p.storydata.linklvl))
			-- Increase our Level and Grant us LP!
			srb2p.storydata.linklvl = $ + 1
			srb2p.storydata.linkpts = $ + getLiNKPoint(srb2p.storydata.linklvl)
			srb2p.storydata.linkexp = $ - (100*(srb2p.storydata.linklvl))
			if srb2p.storydata.linklvl == 99 and srb2p.storydata.linkexp > (100*(srb2p.storydata.linklvl))
				srb2p.storydata.linkexp = 100*99
				break
			end
		end
	elseif srb2p.storydata.linkexp > (100*(srb2p.storydata.linklvl))
		-- We are at lvl 99, so just cap the bar and give us points
		srb2p.storydata.linkexp = 100*99
		srb2p.storydata.linkpts = $ + getLiNKPoint(srb2p.storydata.linklvl)
	end
end)

COM_AddCommand("d_getlinkxp", function(p, arg)
	local argn = tonumber(arg)
	if not argn return end
	
	LiNK_getEXP(argn)
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
	
	-- we changed map because of an interaction object
	-- try to locate that object...
	if server.obj_interact_map
		
		local dta = server.obj_interact_map
		
		if dta[1]
			
			local target = D_FindMobjByAngle(MT_SRB2P_INTERACTION, dta[1])
			if not target
				-- try with npc instead
				target = D_FindMobjByAngle(MT_SRB2P_NPC, dta[1])
				
				if not target -- uh shit
					print("Interaction object (MAP SWITCH): invalid target #"..tostring(dta[1]))
					return
				end	
			end
										
			local distfrom = 192
			if dta[2] ~= nil
				server.mo.angle = dta[2]
			end
										
			P_TeleportMove(server.mo, target.x + distfrom*cos(server.mo.angle), target.y + distfrom*sin(server.mo.angle), target.z)
		end	
									
		if dta[3]
			dta[3](nil, server.mo)
		end
	end
	
	server.obj_interact_map = nil
	server.buf_battles = nil
	server.buf_players = nil
	server.buf_dungeon = nil
end)

COM_AddCommand("pmap", function(p, arg)
	local argn = tonumber(arg)
	if not argn return end
	
	DNG_loadNewMap(argn)
end)