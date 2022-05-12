-- Story script for MAP21
-- Contains associated events and item drop tables

local mapnum = 21	-- change this if the mapnum changes for w/e reason

-- enemy waves
DNG_dungeonwaves[mapnum] = {
	
	[1] = 	{
				{"crawla_commander"},
			},
			
	-- section 2
	[2] =	{
				
				{
					"crawla_b",
					"crawla_b",
				},
			},

	[3] =	{
				
				{
					"brak_01",
				},
			},
	
}

-- make shadows look like crawlas.
DNG_shadowSprites[mapnum] = {
	{SPR_POSS, A, F, 3},
	{SPR_POSS, A, B, C, D, E, F, 4},
}

-- item boxes:
DNG_itemBoxes[mapnum] = {

	[1] = {
		{"superring", 1},
		--{{"weapon", "shoes_01"}, 1},
	},

	[2] = {
		{"superring", 2},
	},

	[3] = {
		{"1up", 1},
	},

	[4] = {
		{"superring", 2},
	},

}


-- NPCs
D_NPCData[mapnum] = {
	
	-- Crawla Commander
	[1] = {
		angle = 0,
		thinker = 	function(mo)
						
						mo.sprite = SPR_CCOM
						mo.frame = leveltime%10 /5
						mo.flags = $|MF_NOGRAVITY
						mo.scale = FRACUNIT*2
						
						mo.z = mo.floorz + mo.scale*16 + FixedMul(mo.scale*4, sin(leveltime*ANG1*16))
					end,
	},
	
}

-- Event #1: 
local function hud_back(v, evt)

	local t = evt.eventindex
	evt.fadetmr = $ or 0
	
	local tflag = max(0, (evt.fadetmr))
	
	if t >= 4
		evt.fadetmr = $+1
	else
		tflag = 0
	end
	
	if tflag < 10
		drawScreenwidePatch(v, v.cachePatch("H_RIP4"), nil, tflag<<V_ALPHASHIFT)
	end	
end

eventList["ev_m21_ev1"] = {

	["hud_back"] = hud_back,

	[1] = {"text", "Tails", "Alright, this path should be free of dangerous Badniks.", nil, nil, nil, {"H_TALAOA", SKINCOLOR_ORANGE}},
	[2] = {"text", "Tails", "I'll find you a way to the generator, but Knuckles won't be able to distract Eggman's main force for long, so be quick!", nil, nil, nil, {"H_TALAOA", SKINCOLOR_ORANGE}},
	[3] = {"text", "Sonic", "You guys hold on just a bit longer, I got this!", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE}},

	[4] = {"function",
		function(evt, battle)

			local cam = battle.cam
			local mo = players[0].mo
			mo.angle = 0

			if evt.ftimer == 1
				evt.usecam = true
				EVT_SetCamByAngle(battle, 0)
				
				cam.angle = R_PointToAngle2(cam.x, cam.y, mo.x, mo.y)
				CAM_aiming(cam, ANG1*5)
				
				P_TeleportMove(mo, mo.x, mo.y, mo.z + mo.scale*500)
				mo.state = S_PLAY_FALL
			
			elseif evt.ftimer == TICRATE
				return true
			end
		end},
}


eventList["ev_m21_ev2"] = {
	
	[1] = {"function",
			function(evt, battle)
				
				local cam = battle.cam
				local mo = players[0].mo
				local npc = EVT_FindNPC(1)
				local t = EVT_FindTeleportPoint(1)
				mo.angle = 0
				
				-- Use the extra camera
				evt.usecam = true				
				
				-- Teleport and move the player, setup the first camera.
				if evt.ftimer == 1
					
					-- set player
					
					
					P_TeleportMove(mo, t.x, t.y, t.z)
					
					-- set camera #1
					EVT_SetCamByAngle(battle, 2)
					
					cam.angle = R_PointToAngle2(cam.x, cam.y, mo.x, mo.y)				
					CAM_aiming(cam, 0)
				
				-- move the player. Them being on ground for 1 frame ensures we don't get undesirable slowdown effects from not hitting controls after jumping.
				elseif evt.ftimer == 2	
					mo.angle = 0
					mo.state = S_PLAY_RUN
					mo.player.frameangle = 0
					P_InstaThrust(mo, mo.angle, mo.scale*50)
					
				-- move camera in front of the npc
				elseif evt.ftimer == TICRATE*3/2
					
					local t = EVT_FindTeleportPoint(2)	-- that's where we're moving the cam.
					CAM_goto(cam, t.x, t.y, t.z)
					CAM_angle(cam, ANG1*180)
					
				-- make player jump and aim towards the badnik!
				elseif evt.ftimer == TICRATE*3
					
					mo.momz = mo.scale*12
					S_StartSound(mo, sfx_jump)
					mo.state = S_PLAY_JUMP
					P_InstaThrust(mo, mo.angle, mo.scale*20)
					
				-- thok!
				elseif evt.ftimer == TICRATE*3 + 12
					
					S_StartSound(mo, sfx_thok)
					local g = P_SpawnGhostMobj(mo)
					g.destscale = mo.scale*50
					
					mo.momx = (npc.x-mo.x)/20
					mo.momy = (npc.y-mo.y)/20
					mo.momz = ((npc.z + 24*FRACUNIT)-mo.z)/20
					mo.flags = $|MF_NOGRAVITY	-- lol.
					
					emotionBubble(npc, EMOTE_SURPRISED)
					
				elseif evt.ftimer > TICRATE*3 + 12
					
					local g = P_SpawnGhostMobj(mo)
					g.destscale = mo.scale*50

					local ang = (npc.angle/ANG1) + 180 %360
					if abs(ang) > 10
						npc.angle = $ + ANG1*10
					end	
					
					if R_PointToDist2(mo.x, mo.y, npc.x, npc.y) < mo.scale*80
						
						mo.flags = $ & ~MF_NOGRAVITY
						npc.fuse = 10
						
						-- Prep battle stuff
						local btl = server.P_BattleStatus[1]
						
						local center = EVT_FindTeleportPoint(3)
						local dummy = P_SpawnMobj(center.x, center.y, center.z, MT_DUMMY)
						dummy.state = S_INVISIBLE
						dummy.tics = -1
						dummy.angle = ANG1*90
						
						btl.arenacenter = dummy	-- this is in a copy of the same room for battle purposes.
						BTL_start(1, {"crawla_commander"}, 0, 0, nil, false, true)
						
						-- apply command flags before the battle begins:
						server.plentities[1][1].commandflags = CDENY_SKILL|CDENY_PERSONA|CDENY_TACTICS|CDENY_ITEM|CDENY_GUARD
						
						-- after this battle ends; load next event
						btl.event_buf = "ev_m21_ev3"
						
						-- remove this lol.
						mo.flags = $ & ~MF_NOGRAVITY
						
						return true 	-- start battle.
					end
					
				end
			end,
			
		},
	
}

-- After battle event, teleport out of the battle.
eventList["ev_m21_ev3"] = {
	
	[1] = {"function",
				function(evt, battle)
					local cam = battle.cam
					local mo = players[0].mo
					
					if evt.ftimer == 1
						mo.angle = 0
						
						-- undo some of the tactics deny since the next few battles can be deliberately triggered by the player lol
						server.plentities[1][1].commandflags = CDENY_SKILL|CDENY_PERSONA|CDENY_TACTICS
						
						-- change dungeon section for crawla waves and new battle arena center
						DNG_changeSection(2)
						
						return true
						
					end
				end,
		},		
		
}	


-- When entering vent, small tutorial on how to heal yourself.
eventList["ev_m21_ev4"] = {

	[1] = {"text", "Tails", "You're almost there, Sonic!", nil, nil, nil, {"H_TALAOA", SKINCOLOR_ORANGE}},
	[2] = {"text", "Tails", "I managed to fool the Badniks into going somewhere else and Knuckles got rid of the ones that were after us.", nil, nil, nil, {"H_TALAOA", SKINCOLOR_ORANGE}},
	[3] = {"text", "Tails", "We'll group up with you as soon as we can.", nil, nil, nil, {"H_TALAOA", SKINCOLOR_ORANGE}},
	
	[4] = {"text", "Tails", "Right, don't be afraid to use the items you found to patch yourself up if any Badnik got a jump on you.", nil, nil, nil, {"H_TALAOA", SKINCOLOR_ORANGE}},
	[5] = {"text", "Tails", "Just check your inventory with \x91 and use some items to heal yourself.", nil, nil, nil, {"H_TALAOA", SKINCOLOR_ORANGE}},
	
	[6] = {"text", "Tails", "See you soon!", nil, nil, nil, {"H_TALAOA", SKINCOLOR_ORANGE}},		
	
}

-- final battle event trigger
local function fbtl_evt(btl)
	
	local evt_running = server.P_DialogueStatus[btl.n].running
	btl.eventcount = $ or 0
	
	local mo = server.plentities[btl.n][1]	-- Sonic
	local egg = mo.enemies[1]
	
	
	if mo.hp < mo.maxhp	-- sonic is at half HP
	and btl.eventcount < 1	-- no event yet.
	and not evt_running
		-- Prompt Eggman to change his pattern;
		egg.melee = "brak_msl"		-- change normal
		egg.skills = {"brak_msl"}
		egg.atk = 180	-- change attack stat
		
		btl.eventcount = $+1
		
	elseif mo.hp == 1	-- only 1 HP left
	and btl.eventcount == 1
	and not evt_running
		D_startEvent(btl.n, "ev_m21_ev6")
		btl.eventcount = 2
	end
end

-- final vent
eventList["ev_m21_ev5"] = {
	
			[1] = {"function",
					function(evt, battle)
						local cam = battle.cam
						local mo = players[0].mo
						
						evt.usecam = true	
						
						if evt.ftimer == 1
							
							S_FadeOutStopMusic(500)
							
							mo.angle = ANG1*180
							EVT_SetCamByAngle(battle, 3)
							
							cam.angle = R_PointToAngle2(cam.x, cam.y, mo.x, mo.y)				
							CAM_aiming(cam, 0)
							
						
						elseif evt.ftimer == 20
							
							local t = EVT_FindTeleportPoint(4)
							
							P_TeleportMove(mo, t.x, t.y, t.z)
							mo.state = S_PLAY_FALL
							
						
						elseif evt.ftimer == TICRATE*7/2
							
							mo.angle = ANG1*90
							emotionBubble(mo, EMOTE_EXCLAMATION)
						
						elseif evt.ftimer == TICRATE*4
							
							-- go in front of container...
							local t = EVT_FindTeleportPoint(5)

							CAM_goto(cam, t.x, t.y, t.z)
							CAM_angle(cam, ANG1*90)
							
						elseif evt.ftimer == TICRATE*11/2	-- 5.5, look at emerald 1
							
							local t = EVT_FindTeleportPoint(6)
							CAM_angle(cam, R_PointToAngle2(cam.x, cam.y, t.x, t.y))

						elseif evt.ftimer == TICRATE*13/2	-- 7.5 look at emerald 2
							
							local t = EVT_FindTeleportPoint(7)
							CAM_angle(cam, R_PointToAngle2(cam.x, cam.y, t.x, t.y))
							
						elseif evt.ftimer == TICRATE*9		-- move towards back, tp sonic.
							local t = EVT_FindTeleportPoint(9)
							CAM_goto(cam, t.x, t.y, t.z)
							CAM_angle(cam, ANG1*90)
							
							-- tp sonic behind this
							t = EVT_FindTeleportPoint(8)
							P_TeleportMove(mo, t.x, t.y, t.z)
							mo.angle = ANG1*180
							
							-- spawn the fake brak...
							t = EVT_FindTeleportPoint(10)
							local b = P_SpawnMobj(t.x, t.y, t.z, MT_DUMMY)
							b.sprite = SPR_BRAK
							b.frame = A
							b.scale = FRACUNIT*3/2
							b.tics = -1
							b.flags = MF_SOLID
							b.angle = ANG1*270
							
							mo.brak = b
							
							P_LinedefExecute(2000)
							
							mo.state = S_PLAY_RUN
							--P_InstaThrust(mo, mo.angle, 32*mo.scale)
						
						elseif evt.ftimer > TICRATE*9 + TICRATE/2
							
							mo.angle = ANG1*90
							
							if R_PointToDist2(mo.x, mo.y, mo.brak.x, mo.brak.y) < 256*FRACUNIT
								if not mo.player.skidtime
									mo.player.skidtime = TICRATE/2
								end
							else
								P_InstaThrust(mo, mo.angle, 24*mo.scale)
								if mo.state ~= S_PLAY_WALK
									mo.state = S_PLAY_WALK
								end	
							end	
							
							if mo.player.skidtime
								mo.momx = $*75/100
								mo.momy = $*75/100
								
								mo.player.skidtime = max($, 2)
								
								-- came to a stop.
								if not FixedHypot(mo.momx, mo.momy)
									return true
								end
							end	
							
							
							
						end
					end,
				},
				
			[2] = {"text", "Eggman", "Hohohoho! Sonic, what an expected surprise!", nil, nil, nil, {"H_EGGAOA", SKINCOLOR_RED}},
			[3] = {"text", "Eggman", "Unfortunately, you're late to the party!", nil, nil, nil, {"H_EGGAOA", SKINCOLOR_RED}},	
			[4] = {"text", "Sonic", "Really? You rebuilt that thing?\nDidn't I trash it a couple weeks ago already?", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE}},
			[5] = {"text", "Eggman", "Why yes, you pesky hedgehog! However I knew this would have happened!", nil, nil, nil, {"H_EGGAOA", SKINCOLOR_RED}},
			[6] = {"text", "Eggman", "So I kept a part of the Black Rock tucked away here to build up energy...", nil, nil, nil, {"H_EGGAOA", SKINCOLOR_RED}},
			[7] = {"text", "Eggman", "And you only made it easier by dropping 2 of your precious Emeralds on the way out of my Egg Rock!", nil, nil, nil, {"H_EGGAOA", SKINCOLOR_RED}},
			[8] = {"text", "Sonic", "...And so your master plan was asset recycling?", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE}},
			[9] = {"text", "Eggman", "Of course! And soon the energy will be sufficient to power a whole army of them!", nil, nil, nil, {"H_EGGAOA", SKINCOLOR_RED}},
			[10] = {"text", "Eggman", "This unit here only serves to buy me some time! And so does our little chat, you overconfident fool!", nil, nil, nil, {"H_EGGAOA", SKINCOLOR_RED}},	
			[11] = {"text", "Sonic", "You...!", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE}},	
			[12] = {"text", "Sonic", "I won't even give you a chance, bring it on!", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE}},
			
			[13] = {"function",
					function(evt, battle)
						local cam = battle.cam
						local mo = players[0].mo
						
						if evt.ftimer == 1		
							-- change dungeon section for new arena center
							DNG_changeSection(3)
							
							-- make sure sonic has full HP for this scripted fight...
							mo.hp = mo.maxhp
							mo.skills = {"infinite endure"}
							
							BTL_start(1, {"brak_01"}, 0, "UBATL", fbtl_evt, false, true)
							battle.event_buf = "ev_m21_ev7"
							battle.norestoremusic = true
						end
					end,	
			}
}

-- in-battle event: tails & knux come help you finish brak off
eventList["ev_m21_ev6"] = {
	
			[1] = {"function",
					function(evt, battle)
						local cam = battle.cam
						local mo = server.plentities[battle.n][1]
						local egg = mo.enemies[1]
						
						ANIM_set(egg, egg.anim_special1, true)
						
						return true
					end
				},
			
			[2] = {"text", "Eggman", "Hohohoho! This went far better than I thought!", nil, nil, nil, {"H_EGGAOA", SKINCOLOR_RED}},
			[3] = {"text", "Eggman", "My arch nemesis down to his knees with just a few shots from so called \"asset recycling\"...", nil, nil, nil, {"H_EGGAOA", SKINCOLOR_RED}},
			[4] = {"text", "Eggman", "Victory is mine! And nothing could potentially conveniently save you now!", nil, nil, nil, {"H_EGGAOA", SKINCOLOR_RED}},
			[5] = {"text", "Eggman", "Farewell, Sonic!", nil, nil, nil, {"H_EGGAOA", SKINCOLOR_RED}},
			
			[6] = {"function",
					function(evt, battle)
						
						local cam = battle.cam
						local mo = server.plentities[battle.n][1]
						local egg = mo.enemies[1]

						local tails = server.plentities[battle.n][2]
						local knux = server.plentities[battle.n][3]
						
						local t = EVT_FindTeleportPoint(50)
						
						if evt.ftimer == 1
						
							BTL_spawnPlayer(mo, 1, "tails")
							BTL_spawnPlayer(mo, 1, "knuckles")
							
							-- re-ref because they've just spawned
							tails = server.plentities[battle.n][2]
							knux = server.plentities[battle.n][3]
							
							-- Knuckles throws Tails at brak.
							P_TeleportMove(knux, t.x, t.y, t.z)
							P_TeleportMove(tails, t.x, t.y, t.z + 20*tails.scale)
							
							tails.angle = R_PointToAngle2(tails.x, tails.y, egg.x, egg.y)
							P_InstaThrust(tails, tails.angle, 60*tails.scale)
							tails.momz = tails.scale*10
							knux.angle = ANG1*90
							ANIM_set(tails, tails.anim_atk, true)
							
							tails.extravalue1 = 1
							
						elseif tails.extravalue1 == 1
							local g = P_SpawnGhostMobj(tails)
							g.colorized = true
							g.destscale = tails.scale*4
							
							-- hit eggman when we're close enough!
							if R_PointToDist2(tails.x, tails.y, egg.x, egg.y) < tails.scale*60
								
								tails.extravalue1 = 2
								P_InstaThrust(tails, tails.angle, -10*tails.scale)
								tails.momz = tails.scale*8
								
								-- damage eggman and crit him
								damageObject(egg, egg.hp - 45, DMG_CRITICAL)
								localquake(mo.battlen, FRACUNIT*10, 10)
								playSound(mo.battlen, sfx_crit)
								
							end
						
						elseif tails.extravalue1 > 1
							
							
							-- tails has been there long enough, switch perspective to knuckles
							if P_IsObjectOnGround(tails)
								
								local ang = ANG1*90
								
								tails.extravalue1 = $+1
								
								ANIM_set(tails, tails.anim_stand, true)
								ANIM_set(knux, knux.anim_stand_bored, true)
								
								local cx = t.x + 256*cos(ang)
								local cy = t.y + 256*sin(ang)
								
								CAM_goto(cam, cx, cy, t.z + 32*FRACUNIT)
								CAM_angle(cam, R_PointToAngle2(cam.x, cam.y, t.x, t.y))
								
								if tails.extravalue1 > 20
									tails.extravalue1 = 0
									return true
								end	
							end
						end
					end
				},
				
			[7] = {"text", "Knuckles", "Hope you hadn't expected your tincans to keep us busy for too long.", nil, nil, nil, {"H_KTEAOA", SKINCOLOR_RED}},	
			[8] = {"text", "Knuckles", "We'll smash that thing of yours, take our Emeralds back and be on our way.", nil, nil, nil, {"H_KTEAOA", SKINCOLOR_RED}},	
			
			-- Finall, force battle state to BS_ENDTURN, this will force knockdown checks for AOA and reset entity positions.
			[9] = {"function",
						function(evt, battle)
							local mo = server.plentities[battle.n][1]
							BTL_initHoldup(battle, mo.allies)
							return true
						end,
					}
			
}
	

-- Final event, everything explodes!
eventList["ev_m21_ev7"] = {
	fadein = true,
	
	hud_front = function(v, evt)

		local t = evt.eventindex
		if t == 9

			local t = evt.ftimer - TICRATE*4
			local p = "H_ATR"..t/2
			
			if t/2 > 4
				v.drawFill(0, 0, 999, 999, V_SNAPTOTOP|V_SNAPTOLEFT)
			elseif v.patchExists(p)
				drawScreenwidePatch(v, v.cachePatch(p))
			end
		end
	end,
	
	[1] = {"function",
				function(evt, battle)
					local cam = battle.cam
					local mo = players[0].mo					
					local brak = mo.brak

					local sonic = server.plentities[battle.n][1]
					local tails = server.plentities[battle.n][2]
					local knux = server.plentities[battle.n][3]
					local mos = {sonic, tails, knux}
					
					evt.usecam = true	
					
					if evt.ftimer == 1
						
						local t = EVT_FindTeleportPoint(100)
						P_TeleportMove(brak, t.x, t.y, t.z)
						ANIM_set(brak, enemyList["brak_01"].anim_special3)
						
						local camx = brak.x + 512*cos(brak.angle)
						local camy = brak.y + 512*sin(brak.angle)
						P_TeleportMove(cam, camx, camy, brak.z + mo.scale*96)
						cam.angle = R_PointToAngle2(cam.x, cam.y, brak.x, brak.y)
						
						-- get the player out of here.
						t = EVT_FindTeleportPoint(50)
						P_TeleportMove(mo, t.x, t.y, t.z)
						
					else
						
						-- make brak explode
						local x = P_RandomRange(-64, 64)*FRACUNIT + brak.x
						local y = P_RandomRange(-64, 64)*FRACUNIT + brak.y
						local z = P_RandomRange(96, 256)*FRACUNIT + brak.z

						local a = P_SpawnMobj(x, y, z, MT_DUMMY)
						a.state = S_QUICKBOOM1
						
						if evt.ftimer & 1
							S_StartSound(brak, sfx_pop)
						end	
	
					end
					
					ANIM_handle(brak)
					
					-- Sonic, Knuckles & Tails charge a spindash to finish Brak off
					if evt.ftimer == TICRATE*2
						local camt = EVT_FindTeleportPoint(200)
						local t = EVT_FindTeleportPoint(9)
						
						CAM_goto(cam, camt.x, camt.y, camt.z)
						
						P_TeleportMove(sonic, t.x, t.y, brak.z)
						local kx = sonic.x + 128*cos(ANG1*180)
						local ky = sonic.y + 128*sin(ANG1*180)
						
						local tx = sonic.x + 128*cos(0)
						local ty = sonic.y + 128*sin(0)
						
						P_TeleportMove(tails, tx, ty, sonic.z)
						P_TeleportMove(knux, kx, ky, sonic.z)
						
						sonic.angle = R_PointToAngle2(sonic.x, sonic.y, brak.x, brak.y)
						tails.angle = R_PointToAngle2(tails.x, tails.y, brak.x, brak.y)
						knux.angle = R_PointToAngle2(knux.x, knux.y, brak.x, brak.y)
						
						sonic.flags2 = $ & ~MF2_DONTDRAW
						tails.flags2 = $ & ~MF2_DONTDRAW
						knux.flags2 = $ & ~MF2_DONTDRAW
						
						ANIM_set(sonic, sonic.anim_stand, true)
						ANIM_set(tails, tails.anim_stand, true)
						ANIM_set(knux, knux.anim_stand, true)
						
					elseif evt.ftimer >= TICRATE*3
					and evt.ftimer < TICRATE*6
						
						local anim = sonic.anim_special1	-- spindash anim
						local anim2 = sonic.anim_special2	-- spindash anim 2
						
						local tailsanim = {SPR_PLAY, A, B, C, 2, "SPR2_SPIN"}
						local tailsanim2 = {SPR_PLAY, A, B, C, 1, "SPR2_SPIN"}
						
						local animt = {anim, tailsanim, anim}
						local anim2t = {anim2, tailsanim2, anim2}
						
						
						
						for i = 1, #mos
							local m = mos[i]
							if evt.ftimer == TICRATE*3
								ANIM_set(m, animt[i], true)
							elseif evt.ftimer == TICRATE*4
								ANIM_set(m, anim2t[i], true)
							end	
							
							local dust = P_SpawnMobj(m.x, m.y, m.z, MT_DUMMY)
							dust.state = S_SPINDUST1
							dust.angle = m.angle + P_RandomRange(-50, 50)*ANG1
							P_InstaThrust(dust, dust.angle, -evt.ftimer*dust.scale /16)
							dust.momz = P_RandomRange(0, 4)*dust.scale
							
						end
						
						if evt.ftimer == TICRATE*3
						or evt.ftimer == TICRATE*3 + TICRATE/2
						or evt.ftimer == TICRATE*4
						or evt.ftimer == TICRATE*4 + 5
						or evt.ftimer == TICRATE*4 + 10
						or evt.ftimer == TICRATE*4 + 15
						or evt.ftimer == TICRATE*4 + 20	-- I can't be fucked to do maths
							playSound(sonic.battlen, sfx_spin)
						end	
					
					-- jump 'em
					elseif evt.ftimer == TICRATE*6
						
						playSound(sonic.battlen, sfx_jump)
						playSound(sonic.battlen, sfx_dash)
						
						for i = 1, #mos
							local m = mos[i]
							
							ANIM_set(m, m.anim_atk)
							P_InstaThrust(m, m.angle, FRACUNIT*45)
							m.momz = FRACUNIT*12
							
						end
						
					-- hitlag, send em flying
					elseif evt.ftimer > TICRATE*6
					and not sonic.punt_timer
						
						for i = 1, #mos
							local m = mos[i]
							
							local g = P_SpawnGhostMobj(m)
							g.colorized = true
							
							if R_PointToDist2(m.x, m.y, brak.x, brak.y) < 64*FRACUNIT
								m.momx = 0
								m.momy = 0
								m.momz = 0
								m.flags = $|MF_NOGRAVITY
								if not sonic.punt_timer
									-- hitlag...
									local s = P_SpawnMobj(sonic.x, sonic.y, sonic.z + FRACUNIT*16, MT_DUMMY)
									s.color = SKINCOLOR_WHITE
									s.state = S_MEGISTAR1
									s.scale = $*2 + P_RandomRange(0, 65535)
									playSound(sonic.battlen, sfx_hamas1)									
								end
								
								sonic.punt_timer = 1
							end	
							
						end
					end
					
					if sonic.punt_timer
						sonic.punt_timer = $+1
							
						-- restore gravity, + ground check.
						for i = 1, #mos
							local m = mos[i]							
							
							if sonic.punt_timer == TICRATE/2
							
								m.flags = $ & ~MF_NOGRAVITY
								P_InstaThrust(m, m.angle, -4*FRACUNIT)
								m.momz = FRACUNIT
							else	
								if P_IsObjectOnGround(m) and m.anim ~= m.anim_stand
									ANIM_set(m, m.anim_stand, true)
									P_InstaThrust(m, 0, 0)
								end
							end	
						end
						
						-- send brak flying
						if sonic.punt_timer == TICRATE/2
							P_InstaThrust(brak, brak.angle, -40*FRACUNIT)
							brak.momz = 12*FRACUNIT
							localquake(sonic.battlen, FRACUNIT*40, 10)
							local g = P_SpawnGhostMobj(brak)
							g.destscale = FRACUNIT*8
							
						elseif sonic.punt_timer > TICRATE/2
							
							
							if FixedHypot(brak.momx, brak.momy) < 10
								localquake(sonic.battlen, FRACUNIT*40, TICRATE)
								playSound(sonic.battlen, sfx_bgxpld)
								
								brak.momz = 0
								brak.flags = $ | MF_NOGRAVITY
								P_InstaThrust(brak, 0, 0)
								
								return true
								
							else
								brak.rollangle = $ + ANG1*2
							end	
							
							
						end
						
					end
					
				end	
			},
			
	[2] = {"text", "Eggman", "Y-you!", nil, nil, nil, {"H_EGGAOA", SKINCOLOR_RED}},		
	[3] = {"text", "Eggman", "You bumbling idiots! The energy tank was damaged from the impact!", nil, nil, nil, {"H_EGGAOA", SKINCOLOR_RED}},	
	[4] = {"text", "Eggman", "Even I don't know what would happen if that energy was let out uncontrolled--", nil, nil, nil, {"H_EGGAOA", SKINCOLOR_RED}},
	
	[5] = {"function", 
	
				function(evt, battle)
					
					local sonic = server.plentities[battle.n][1]
					
					if evt.ftimer == 1
						localquake(sonic.battlen, FRACUNIT*40, TICRATE*4)
						playSound(sonic.battlen, sfx_rumble)
						S_ChangeMusic("CALMTY", true)
						
					elseif evt.ftimer == TICRATE
						return true
					end
				end,
			},
			
	[6] = {"text", "Sonic", "...I think we messed up.", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE}},
	[7] = {"text", "Knuckles", "Yeah.", nil, nil, nil, {"H_KTEAOA", SKINCOLOR_RED}},	
	[8] = {"text", "Tails", "Yeah.", nil, nil, nil, {"H_TALAOA", SKINCOLOR_ORANGE}},	
	
	[9] = {"function",
				function(evt, battle)

					local cam = battle.cam
					local mo = players[0].mo					
					local brak = mo.brak

					local sonic = server.plentities[battle.n][1]
					local tails = server.plentities[battle.n][2]
					local knux = server.plentities[battle.n][3]
					local mos = {sonic, tails, knux}
					
					local t = EVT_FindTeleportPoint(5000)
					
					if evt.ftimer == 1
						local s = P_SpawnMobj(brak.x, brak.y, brak.z + FRACUNIT*16, MT_DUMMY)
						s.color = SKINCOLOR_WHITE
						s.state = S_MEGISTAR1
						s.scale = $*8 + P_RandomRange(0, 65535)				
						playSound(sonic.battlen, sfx_hamas1)									
					elseif evt.ftimer > TICRATE
						
						localquake(sonic.battlen, FRACUNIT*40, TICRATE*4)
						
						for i = 1, 3
							
							local sx = t.x + P_RandomRange(-512, 512)*FRACUNIT
							local sy = t.y + P_RandomRange(-512, 512)*FRACUNIT
							local sz = t.z + P_RandomRange(0, 768)*FRACUNIT
							
							local a = P_SpawnMobj(sx, sy, sz, MT_DUMMY)
							a.state = S_QUICKBOOM1
							a.scale = P_RandomRange(2, 8)*FRACUNIT
							a.tics = $ + P_RandomRange(0, 8)
						end
						
						if leveltime%4 == 0
							playSound(sonic.battlen, sfx_bgxpld)
							playSound(sonic.battlen, sfx_pop)
						end
					end	
					if evt.ftimer == TICRATE*5
						sonic.hp = sonic.maxhp
						DATE_setTime(-3)	-- Set to Night?
						DNG_loadNewMap(22)
					end
				end
			}	
}