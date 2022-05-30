-- Story script for MAP22
-- Contains associated events and item drop tables

freeslot("SPR_SHND")	-- spriteset for cutscenes
local mapnum = 22	-- change this if the mapnum changes for w/e reason

-- NPCs
D_NPCData[mapnum] = {
	
	-- Eggman
	[1] = {
		angle = 90*ANG1,
		sprite = SPR_PLAY,
		skin = "eggman",
		color = SKINCOLOR_RED,
		thinker = 	function(mo)
						
						mo.state = S_PLAY_STND
					end,
		
	},
	
}

-- enemy waves
DNG_dungeonwaves[mapnum] = {
			
	[1] = 	{
				{	"maya_1",
					"maya_1",
				},
			},

	-- 2: rooftops
	[2] = 	{
				{	"maya_1",
					"maya_1",
				},
			},
			
	-- 3: streets
	[3] = 	{
				{	"hand_1",
					"maya_1",
				},

				{	"table_1",
					"maya_1",
				},

				{	"table_1"},
			},
	
}
-- item boxes:
DNG_itemBoxes[mapnum] = {

	[1] = {
		{"amethyst", 1},
	},

	[2] = {
		{"supercombiring", 1},
	},

	[3] = {
		{"amethyst", 1},
	},

	[4] = {
		{"superring", 2},
	},
	
	[5] = {{25, 1}},	-- 25h
	
	[6] = {
		{"superring", 2},
	},

	[7] = {
		{"superring", 2},
	},	
}

-- travel points
DNG_interactiveObjects[mapnum] = {
	
	[0] = {
		type = IT_AREASWITCH,
		targetmap = mapnum,
		targetid = 1,
		targetangle = ANG1*90,
		
		text = "Streets",
		
		func = 	function()
					print("Changed section")
					DNG_changeSection(3)
				end,
	},

	[1] = {
		type = IT_AREASWITCH,
		targetmap = mapnum,
		targetid = 0,
		targetangle = ANG1*90,
		
		text = "Rooftops",

		func = 	function()
					print("Changed section")
					DNG_changeSection(2)
				end,		
		
	},
	
}

-- First "mini"boss"" (it's very easy...)
eventList["ev_m22_ev6"] = {
		flag = "m22_ev6",	-- set this flag to prevent the event from ever triggering again.
		hideplayers = true,
		
		
		[1] = {"function", 
			function(evt, battle)
				
				local cam = battle.cam
				local mo = players[0].mo
				local bot1 = server.plentities[1][1]
				local bot2 = server.plentities[1][2]
				local t = EVT_FindTeleportPoint(200)	

				evt.usecam = true
				
				if evt.ftimer == 1
					S_ChangeMusic("TRBLD", true, nil, 0, 0, 250, 250)
				
					EVT_SetCamByAngle(battle, 200)
					
					local tx = t.x + 64*cos(ANG1*90)
					local ty = t.y + 64*sin(ANG1*90)
					P_TeleportMove(bot1, tx, ty, t.z)
					bot1.angle = 0
					bot1.flags2 = $ & ~MF2_DONTDRAW
					ANIM_set(bot1, bot1.anim_stand)

					
					local tx = t.x + 64*cos(ANG1*270)
					local ty = t.y + 64*sin(ANG1*270)
					P_TeleportMove(bot2, tx, ty, t.z)
					bot2.angle = 0
					bot2.flags2 = $ & ~MF2_DONTDRAW
					ANIM_set(bot2, bot1.anim_stand)
					
					cam.angle = R_PointToAngle2(cam.x, cam.y, t.x, t.y)
					
				elseif evt.ftimer == TICRATE/2
					return true
				end
			end	
		},
		
	[2] = {"text", "Sonic", "As I thought, this is the old Central City...", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE}},		
	[3] = {"text", "Eggman", "Right, the entire district we took a few fights of ours ago...", nil, nil, nil, {"H_EGGAOA", SKINCOLOR_RED}},	
	[4] = {"text", "Eggman", "But that means...", nil, nil, nil, {"H_EGGAOA", SKINCOLOR_RED}},	
	[5] = {"text", "Sonic", "These blobby things may already be in Central City proper attacking civilians, we need to get there and quick!", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE}},		

		[6] = {"function", 
			function(evt, battle)
				
				local cam = battle.cam
				local mo = players[0].mo
				local bot1 = server.plentities[1][1]
				local bot2 = server.plentities[1][2]
				local t = EVT_FindTeleportPoint(201)	

				evt.usecam = true
				
				CAM_angle(cam, R_PointToAngle2(cam.x, cam.y, t.x, t.y))
					
				if evt.ftimer == TICRATE
					--return true
					mo.enm = {}
					for i = 1, 8 do
						local s = P_SpawnMobj(t.x + P_RandomRange(-128, 128)*FRACUNIT, t.y + P_RandomRange(-128, 128)*FRACUNIT, t.z, MT_DUMMY)
						if i == 1
							P_TeleportMove(s, t.x, t.y, t.z)	-- always put the 1st one at the dead center
						end	
							
						s.tics = -1
						s.fuse = -1
						s.sprite = SPR_ENM1
						s.frame = D
						s.angle = ANG1*180
						s.flags = MF_NOCLIPTHING
						
						mo.enm[#mo.enm+1] = s
					end
				elseif evt.ftimer > TICRATE
				and evt.ftimer < TICRATE*3
					for i = 1, 8 do
						local s = mo.enm[i]
						P_InstaThrust(s, s.angle, 7*FRACUNIT)
					end
				elseif evt.ftimer == TICRATE*3 + TICRATE/2
					return true
				end
			end	
		},

	[7] = {"text", "Eggman", "It's like these things always show up when we stop to assess our situation...", nil, nil, nil, {"H_EGGAOA", SKINCOLOR_RED}},	

		[8] = {"function", 
			function(evt, battle)
				
				local cam = battle.cam
				local mo = players[0].mo
				local bot1 = server.plentities[1][1]
				local bot2 = server.plentities[1][2]
				local t = EVT_FindTeleportPoint(201)	
				
				if evt.ftimer > TICRATE/2
				and evt.ftimer < TICRATE/2 + 30
				
					local tgt = mo.enm[1]
					for i = 2, 8
						local s = mo.enm[i]
						if not tgt or not tgt.valid continue end
						
						s.angle = R_PointToAngle2(s.x, s.y, tgt.x, tgt.y)
						s.momx = (tgt.x - s.x)/6
						s.momy = (tgt.y - s.y)/6
						s.fuse = 2
						
						local p = P_SpawnMobj(tgt.x + P_RandomRange(-128, 128)*FRACUNIT, tgt.y + P_RandomRange(-128, 128)*FRACUNIT, tgt.z, MT_DUMMY)
						p.sprite = SPR_THOK
						p.frame = A
						p.color = P_RandomRange(0, 1) and SKINCOLOR_BLACK or SKINCOLOR_RED
						p.momz = P_RandomRange(2, 4)*FRACUNIT
						p.destscale = 1
					end
				
				elseif evt.ftimer == TICRATE/2 + 30
					
					mo.enm = mo.enm[1]	-- deref the rest of the table.
					
					mo.enm.destscale = FRACUNIT*2
					
					for i = 1, 32
						local p = P_SpawnMobj(mo.enm.x, mo.enm.y, mo.enm.z, MT_DUMMY)
						p.sprite = SPR_THOK
						p.frame = A
						p.color = P_RandomRange(0, 1) and SKINCOLOR_BLACK or SKINCOLOR_RED
						p.momz = P_RandomRange(0, 16)*FRACUNIT
						p.momx = P_RandomRange(-32, 32)*FRACUNIT
						p.momy = P_RandomRange(-32, 32)*FRACUNIT
						p.destscale = 1						
					end
				
				elseif evt.ftimer == TICRATE*4
					return true
				end
			end
		},
		
	[9] = {"text", "Sonic", "Oh come on... Fine, I guess we don't have a choice...", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE}},	

	[10] = {"function",
			function(evt, battle)
				
				local mo = players[0].mo
				mo.enm.fuse = 10
				mo.enm = nil
				
				BTL_start(1, {"miniboss_fuzz_1"}, 0, "BOSS1", nil, false, true)
				--battle.event_buf = "ev_m22_ev7"
				battle.norestoremusic = true			
						
				return true 	-- start battle.
			end,
		},
}

-- waking up, get first party member!
eventList["ev_m22_ev5"] = {
	
	fadein = true,
	
	[1] = {"function",
				function(evt, battle)

					local cam = battle.cam
					local mo = players[0].mo
					local bot = server.plentities[1][1]
					local t = EVT_FindTeleportPoint(100)
					
					evt.usecam = true
					
					if evt.ftimer == 1
						P_TeleportMove(mo, t.x, t.y, t.z)
						mo.angle = ANG1*90
						mo.state = S_PLAY_FAINTED
						
						EVT_SetCamByAngle(battle, 5)
						cam.angle = R_PointToAngle2(cam.x, cam.y, mo.x, mo.y)
						
						mo.egg = P_SpawnMobj(mo.x + 128*cos(mo.angle - ANG1*90), mo.y + 128*sin(mo.angle - ANG1*90), mo.z, MT_DUMMY)
						mo.egg.skin = "eggman"
						mo.egg.color = SKINCOLOR_RED
						mo.egg.state = S_PLAY_STND
						mo.egg.angle = ANG1*180
					
					elseif evt.ftimer == TICRATE*2
						mo.state = S_PLAY_STND
						
					elseif evt.ftimer == TICRATE*2 + TICRATE/2	
						mo.angle = R_PointToAngle2(mo.x, mo.y, mo.egg.x, mo.egg.y)
						emotionBubble(mo, EMOTE_EXCLAMATION)
					
					elseif evt.ftimer == TICRATE*3
						return true
					end
				end,
				
		},
		
	[2] = {"text", "Eggman", "Finally done taking a nap?", nil, nil, nil, {"H_EGGAOA", SKINCOLOR_RED}},			
	[3] = {"text", "Sonic", "What are you doing here!?", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE}},
	[4] = {"text", "Eggman", "Is that the thanks I get for dragging you out of this mess? Ungrateful fool.", nil, nil, nil, {"H_EGGAOA", SKINCOLOR_RED}},	
	[5] = {"text", "Sonic", "You... what?", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE}},
	[6] = {"text", "Eggman", "I couldn't just leave you out there by yourself after you passed out...", nil, nil, nil, {"H_EGGAOA", SKINCOLOR_RED}},	
	[7] = {"text", "Eggman", "We may be mortal enemies but there's no point in anyone else defeating you besides myself.", nil, nil, nil, {"H_EGGAOA", SKINCOLOR_RED}},
	[8] = {"text", "Sonic", "Passed out... Right, that happened...", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE}},
	[9] = {"text", "Sonic", "(And what was that dream I just had... Something about honing this power...)", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE}},

	[10] = {"text", "Eggman", "I'm not sure how you had the... bright idea to use that gun thing on yourself, but it worked out.", nil, nil, nil, {"H_EGGAOA", SKINCOLOR_RED}},
	[11] = {"text", "Sonic", "Persona.", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE}},

	[12] = {"text", "Sonic", "That's what this power is called. It just came instinctively when I picked it up.", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE}},

	[13] = {"text", "Eggman", "I know. I figured that on my own as well when I tried using it for myself too.", nil, nil, nil, {"H_EGGAOA", SKINCOLOR_RED}},
	[14] = {"text", "Eggman", "It seems that just pulling the trigger while pointing it at yourself manifests this power.", nil, nil, nil, {"H_EGGAOA", SKINCOLOR_RED}},
	[15] = {"text", "Eggman", "I'm sure there's some deep meaning behind it that I just don't care about given our circumstances....", nil, nil, nil, {"H_EGGAOA", SKINCOLOR_RED}},

	[16] = {"text", "Sonic", "Wait. So you can use that power too then?", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE}},

	[17] = {"text", "Eggman", "That I can.", nil, nil, nil, {"H_EGGAOA", SKINCOLOR_RED}},
	[18] = {"text", "Eggman", "Another thing I figured out however...", nil, nil, nil, {"H_EGGAOA", SKINCOLOR_RED}},
	[19] = {"text", "Eggman", "No electronics seem to be functionning whatsoever. I can't call my army or anything of the sort.", nil, nil, nil, {"H_EGGAOA", SKINCOLOR_RED}},

	[20] = {"text", "Sonic", "Under normal circumstances this would be good news, heh...", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE}},
	[21] = {"text", "Sonic", "Alright, let's not waste any more time here.", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE}},
	[22] = {"text", "Sonic", "We need to find Tails & Knuckles. And quick...", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE}},

	[23] = {"text", "Sonic", "You can fight too now, right? Let's call this a temporary truce.", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE}},
	[24] = {"text", "Eggman", "It's not like we have much of a choice...", nil, nil, nil, {"H_EGGAOA", SKINCOLOR_RED}},
	
	[25] = {"function",
				function(evt, battle)
					
					local mo = players[0].mo
					P_FlashPal(mo.player, PAL_WHITE, 2)
					
					local nmo = PLYR_makePlayer("eggman", 1, #server.plentities[1] +1, 3)
					P_RemoveMobj(mo.egg)
					mo.egg = nil
					
					DNG_changeSection(2)
					return true
				end
			},
			
	[26] = {"text", nil, "\x82".."Eggman".."\x80".." joined your party."},
}

-- passing out, -> velvet room
eventList["ev_m22_ev4"] = {
	
	fadein = true,
	
	["hud_front"] = function(v, evt)
		
		if evt.eventindex == 4
			local opacity = min(10, evt.ftimer / 5)
			v.fadeScreen(31, opacity)
		end
		
	end,
	
	[1] = {"function",
			function(evt, battle)
				local cam = battle.cam
				local mo = players[0].mo
				local bot = server.plentities[1][1]
				local npc = EVT_FindNPC(1)
				local t = EVT_FindTeleportPoint(6)
				
				evt.usecam = true
				
				if evt.ftimer == 1
					
					-- init entity coords...
					P_TeleportMove(bot, t.x, t.y, t.z)
					bot.flags2 = $ & ~MF2_DONTDRAW
					ANIM_set(bot, bot.anim_evoker, false)
					bot.angle = ANG1*180
					
					P_TeleportMove(npc, bot.x + 128*cos(bot.angle + ANG1*125), bot.y + 128*sin(bot.angle + ANG1*125), bot.z)
					npc.angle = R_PointToAngle2(npc.x, npc.y, bot.x, bot.y)
					
					P_TeleportMove(cam, bot.x + 256*cos(bot.angle), bot.y + 256*sin(bot.angle), bot.z + 64*FRACUNIT)
					cam.angle = R_PointToDist2(cam.x, cam.y, bot.x, bot.y)	


					local px = bot.x - 64*cos(bot.angle)
					local py = bot.y - 64*sin(bot.angle)
					bot.fakepersona = P_SpawnMobj(px, py, bot.z + 60*FRACUNIT, MT_DUMMY)
					bot.fakepersona.tics = -1
					bot.fakepersona.angle = R_PointToAngle2(bot.fakepersona.x, bot.fakepersona.y, bot.x, bot.y)
					bot.fakepersona.scale = bot.scale*2
					
					ANIM_set(bot.fakepersona, personaList["story_01"].anim_idle, true)
				
				elseif evt.ftimer == TICRATE
					P_FlashPal(mo.player, PAL_WHITE, 2)
					ANIM_set(bot.fakepersona, personaList["orpheus"].anim_idle)
				
				elseif evt.ftimer >= TICRATE*2
				and evt.ftimer < TICRATE*2 + 10
					local flag = min(9, evt.ftimer - TICRATE*2)
					bot.fakepersona.frame = ($ & ~FF_TRANSMASK) | evt.ftimer<<FF_TRANSSHIFT
				elseif evt.ftimer == TICRATE*2 + 10
					bot.fakepersona.fuse = 2
					bot.fakepersona = nil
				
				elseif evt.ftimer == TICRATE*3
					return true
				end	
				
				if bot.fakepersona and bot.fakepersona.valid
					ANIM_handle(bot.fakepersona)
				end
			end
		},

	[2] = {"text", "Sonic", "I...", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE}},			
	[3] = {"text", "Sonic", "Eh......", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE}},	
	
	[4] = {"function",
				function(evt, battle)
					
					local bot = server.plentities[1][1]
					
					if evt.ftimer == 1
						playSound(1, sfx_s1c4)
						ANIM_set(bot, {SPR_PLAY, A, 1, "SPR2_SHIT"}, true)
						
						for i = 1, 4
							local d = P_SpawnMobj(bot.x, bot.y, bot.z, MT_SPINDUST)
							d.momz = P_RandomRange(2, 4)*FRACUNIT
							d.momx = P_RandomRange(-4, 4)*FRACUNIT
							d.momy = P_RandomRange(-4, 4)*FRACUNIT
						end
						
					end
					
					if evt.ftimer == TICRATE*3
						-- get isekai'd into the velvet room and run the first event there.
						DNG_loadNewMap(6, "ev_m06_ev1")
						return true
					end
				end,
		},		
	
}

local function magician_triggers(btl)

	
	local mo = server.plentities[btl.n][1]	-- Sonic
	local enm = mo.enemies[1]	
	local evt_running = server.P_DialogueStatus[btl.n].running
	
	enm.eventcount = $ or 0
	
	-- swap skills for cleave after sonic is at 1/2 hp
	if mo.hp < mo.maxhp*3/5
	and enm.eventcount == 0
		enm.skills = {"cleave"}
		enm.eventcount = 1	
	
	elseif mo.hp == 1	-- only 1 HP left
	and enm.eventcount == 1
	and not evt_running
		D_startEvent(btl.n, "ev_m22_ev3")
		enm.eventcount = 1
	end	
end

eventList["ev_m22_ev3"] = {

	[1] = {"text", "Sonic", "This one's much tougher... at this rate I won't...", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE}},	
	[2] = {"function",
			function(evt, btl)
				local p = players[0]
				local bot = server.plentities[1][1]
				
				if evt.ftimer == 1
					P_FlashPal(p, PAL_WHITE, 10)
				elseif evt.ftimer == 15
					return true
				end
			end
		},

	[3] = {"text", "Sonic", "What is that... feeling...", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE}},			
	[4] = {"function",
			function(evt, btl)
				local cam = btl.cam
				local p = players[0]
				local bot = server.plentities[1][1]
				
				if evt.ftimer == 1
					
					S_FadeOutStopMusic(500)
					
					local tx = bot.x + 256*cos(bot.angle)
					local ty = bot.y + 256*sin(bot.angle)
					P_TeleportMove(cam, tx, ty, bot.z + 60*FRACUNIT)
					cam.angle = R_PointToAngle2(cam.x, cam.y, bot.x, bot.y)
					
					local px = bot.x - 64*cos(bot.angle)
					local py = bot.y - 64*sin(bot.angle)
					bot.fakepersona = P_SpawnMobj(px, py, bot.z + 60*FRACUNIT, MT_DUMMY)
					bot.fakepersona.tics = -1
					bot.fakepersona.angle = R_PointToAngle2(bot.fakepersona.x, bot.fakepersona.y, bot.x, bot.y)
					bot.fakepersona.scale = bot.scale*2
					
					ANIM_set(bot.fakepersona, personaList["orpheus"].anim_idle, true)
					
					P_FlashPal(p, PAL_WHITE, 10)

				elseif evt.ftimer == TICRATE*2
					return true
				
				elseif evt.ftimer > TICRATE*3/2
					for i = 1, 4
						local pa = P_SpawnMobj(bot.fakepersona.x, bot.fakepersona.y, bot.fakepersona.z + FRACUNIT*32, MT_DUMMY)
						pa.tics = 20
						pa.fuse = pa.tics
						pa.sprite = SPR_THOK
						pa.frame = A
						pa.destscale = 1
						pa.color = i%2 and SKINCOLOR_RED or SKINCOLOR_BLACK
						pa.momx = P_RandomRange(-14, 14)*FRACUNIT
						pa.momy = P_RandomRange(-14, 14)*FRACUNIT
						pa.momz = P_RandomRange(-14, 14)*FRACUNIT
					end
				end
					
				
				if bot.fakepersona
					ANIM_handle(bot.fakepersona)
				end	
				
			end
		},

	[5] = {"text", "Sonic", "NNnggh!", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE},
		function(evt, btl)
			local cam = btl.cam
			local p = players[0]
			local bot = server.plentities[1][1]
			
			for i = 1, 4
				local pa = P_SpawnMobj(bot.fakepersona.x, bot.fakepersona.y, bot.fakepersona.z + FRACUNIT*32, MT_DUMMY)
				pa.tics = 20
				pa.fuse = pa.tics
				pa.sprite = SPR_THOK
				pa.frame = A
				pa.destscale = 1
				pa.color = i%2 and SKINCOLOR_RED or SKINCOLOR_BLACK
				pa.momx = P_RandomRange(-14, 14)*FRACUNIT
				pa.momy = P_RandomRange(-14, 14)*FRACUNIT
				pa.momz = P_RandomRange(-14, 14)*FRACUNIT
			end	
			if bot.fakepersona
				ANIM_handle(bot.fakepersona)
			end				
		end
	},	

	[6] = {"function",
			function(evt, btl)
				local p = players[0]
				local bot = server.plentities[1][1]
				
				if evt.ftimer == 1
					P_FlashPal(p, PAL_WHITE, 10)
					
					S_ChangeMusic("THANA", true)
					
					bot.hp = bot.maxhp
					bot.sp = bot.maxsp
					PLYR_initPersona(bot, "story_01", bot.skin)	-- switch persona to thanatos
					BTL_splitSkills(bot)						-- we need to do this otherwise we'd end up with passives on our main list lol...
					
					ANIM_set(bot.fakepersona, personaList["story_01"].anim_idle, true)
					bot.status_condition = nil	-- clear eventual burns from agi lol
					bot.commandflags = CDENY_PERSONA|CDENY_TACTICS|CDENY_ITEM|CDENY_GUARD
					
				elseif evt.ftimer == 15
					ANIM_set(bot.fakepersona, personaList["story_01"].anim_atk, false)
				
				elseif evt.ftimer == TICRATE*4
					return true
				end
				
				if evt.ftimer > 25
				and leveltime & 1
					local g = P_SpawnGhostMobj(bot.fakepersona)
					g.destscale = bot.fakepersona.scale*8
				end
				
				ANIM_handle(bot.fakepersona)
			end
		},	

	[7] = {"text", "Eggman", "This is getting ridiculous...", nil, nil, nil, {"H_EGGAOA", SKINCOLOR_RED}},	

	[8] = {"function",
			function(evt, btl)
				local p = players[0]
				local bot = server.plentities[1][1]
				
				bot.fakepersona.fuse = 4
				bot.fakepersona = nil
				return true
			end}	
}

eventList["ev_m22_ev2"] = {
	
	fadein = true,
	
	[1] = {"function",
			function(evt, battle)
				local cam = battle.cam
				local mo = players[0].mo
				local bot = server.plentities[1][1]
				local npc = EVT_FindNPC(1)
				local t = EVT_FindTeleportPoint(6)
				local t2 = EVT_FindTeleportPoint(40)
				
				evt.usecam = true
				
				if evt.ftimer == 1
					if mo.enm1 and mo.enm1.valid
						P_RemoveMobj(mo.enm1)
						P_RemoveMobj(mo.enm2)
						P_RemoveMobj(mo.fakepersona)
						mo.enm1 = nil
						mo.enm2 = nil
						mo.fakepersona = nil
					end
					
					-- init entity coords...
					P_TeleportMove(bot, t.x, t.y, t.z)
					bot.flags2 = $ & ~MF2_DONTDRAW
					ANIM_set(bot, bot.anim_evoker, false)
					bot.angle = ANG1*180
					
					P_TeleportMove(npc, bot.x + 128*cos(bot.angle + ANG1*125), bot.y + 128*sin(bot.angle + ANG1*125), bot.z)
					npc.angle = R_PointToAngle2(npc.x, npc.y, bot.x, bot.y)
					
					P_TeleportMove(cam, bot.x + 256*cos(bot.angle), bot.y + 256*sin(bot.angle), bot.z + 64*FRACUNIT)
					cam.angle = R_PointToDist2(cam.x, cam.y, bot.x, bot.y)	
					
					-- get rid of the actual player object.
					P_TeleportMove(mo, t2.x, t2.y, t2.z)
				
				elseif evt.ftimer == TICRATE
					ANIM_set(bot, bot.anim_stand, true)
				
				elseif evt.ftimer == TICRATE + 10
					return true
				end
			end
		},

	[2] = {"text", "Eggman", "...................", nil, nil, nil, {"H_EGGAOA", SKINCOLOR_RED}},
	[3] = {"text", "Sonic", "....................", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE}},	

	[4] = {"text", "Eggman", "Tell you what, Sonic, I'm not even going to ask what hap-", nil, nil, EV_AUTO, {"H_EGGAOA", SKINCOLOR_RED}},

	[5] = {"function",
			function(evt, battle)
				local cam = battle.cam
				local mo = players[0].mo
				local bot = server.plentities[1][1]
				local t = EVT_FindTeleportPoint(6)
				
				evt.usecam = true

				if evt.ftimer == 1
					localquake(bot.battlen, FRACUNIT*20, TICRATE*4)
					playSound(bot.battlen, sfx_rumble)						
				
				elseif evt.ftimer == 12
					return true
				end
			end
		},


	[6] = {"text", "Eggman", "What is it now...", nil, nil, nil, {"H_EGGAOA", SKINCOLOR_RED}},

	[7] = {"function",
			function(evt, battle)
				local cam = battle.cam
				local mo = players[0].mo
				local bot = server.plentities[1][1]
				local t = EVT_FindTeleportPoint(20)
				local t2 = EVT_FindTeleportPoint(21)
				
				evt.usecam = true

				if evt.ftimer <= 10
					CAM_angle(cam, ANG1*180)
				end
				
				if evt.ftimer == 1
					S_ChangeMusic("SHDW", true)
				elseif evt.ftimer == TICRATE
					mo.shand = P_SpawnMobj(t.x, t.y, t.z, MT_DUMMY)
					mo.shand.tics = -1
					mo.shand.sprite = SPR_SHND
					mo.shand.frame = A
					mo.shand.momz = FRACUNIT*5
				elseif evt.ftimer > TICRATE
				and evt.ftimer < TICRATE*5/2
					mo.shand.momz = $*95/100
				
				elseif evt.ftimer == TICRATE*5/2
					mo.shand.momz = 0
					mo.shand.frame = B
				elseif evt.ftimer == TICRATE*5/2 + 3
					mo.shand.frame = C
					P_TeleportMove(mo.shand, t2.x, t2.y, t2.z)
				elseif evt.ftimer == TICRATE*4
					return true
				end	
			end
		},

	[8] = {"text", "Sonic", "Oh no.", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE}},	

	[9] = {"function",
			function(evt, battle)
				local cam = battle.cam
				local mo = players[0].mo
				local bot = server.plentities[1][1]
				local t = EVT_FindTeleportPoint(22)
				
				evt.usecam = true

				if evt.ftimer <= 10
					CAM_angle(cam, ANG1*180)
				end
				
				if evt.ftimer == TICRATE
					mo.shand2 = P_SpawnMobj(t.x, t.y, t.z, MT_DUMMY)
					mo.shand2.tics = -1
					mo.shand2.sprite = SPR_SHND
					mo.shand2.frame = D
					mo.shand2.momz = FRACUNIT*6
				elseif evt.ftimer > TICRATE
					mo.shand2.momz = $*95/100
				end
				
				if evt.ftimer == TICRATE*4
					mo.shand2.momz = 0
					return true
				end	
			end
		},

	[10] = {"text", "Eggman", "Oh no.", nil, nil, nil, {"H_EGGAOA", SKINCOLOR_RED}},
	[11] = {"text", "Sonic", "UUuuuh...", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE}},	
	[12] = {"text", "Sonic", "I'm sorry for hurting your children...?", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE}},	

	[13] = {"function",
			function(evt, battle)
				local cam = battle.cam
				local mo = players[0].mo
				local bot = server.plentities[1][1]
				local t = EVT_FindTeleportPoint(22)
				
				evt.usecam = true

				if evt.ftimer <= 10
					CAM_angle(cam, ANG1*180)
				end
				
				if evt.ftimer == TICRATE
					mo.shand3 = P_SpawnMobj(t.x, t.y, t.z, MT_DUMMY)
					mo.shand3.tics = -1
					mo.shand3.sprite = SPR_SHND
					mo.shand3.frame = E
					mo.shand3.momz = FRACUNIT*10
				elseif evt.ftimer > TICRATE
					mo.shand3.momz = $*85/100
				end
				
				if evt.ftimer == TICRATE*4
					return true
				end	
			end
		},

	[14] = {"text", "Eggman", "Whatever you just did a few seconds ago, now's the time to do it again...", nil, nil, nil, {"H_EGGAOA", SKINCOLOR_RED}},
	[15] = {"text", "Sonic", "Not that I've got a choice... Let's rock!", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE}},
	
	[16] = {"function",
			function(evt, battle)
				
				local cam = battle.cam
				local mo = players[0].mo
				local bot = server.plentities[1][1]
				
				mo.shand.fuse = 2
				mo.shand2.fuse = 2
				mo.shand3.fuse = 2
				mo.shand = nil
				mo.shand2 = nil
				mo.shand3 = nil
				
				DNG_changeSection(1)
				SAVE_setEventFlag("storyinit")					-- re-set for testing purposes...
				PLYR_initPersona(bot, "orpheus", bot.skin)
				bot.hp = bot.maxhp
				bot.sp = bot.maxsp
				
				bot.commandflags = CDENY_ATTACK|CDENY_PERSONA|CDENY_TACTICS|CDENY_ITEM|CDENY_GUARD
				
				BTL_start(1, {"boss_magician"}, 0, "MSHDW", magician_triggers, false, true)
				battle.event_buf = "ev_m22_ev4"
				battle.norestoremusic = true
				bot.passiveskills[#bot.passiveskills+1] = "infinite endure"	-- cheat a little...				
						
				return true 	-- start battle.
			end,	
		},
		
		
}

local rframe = 1
eventList["ev_m22_ev1"] = {
	
	flag = "m22_ev1",	-- set this flag to prevent the event from ever triggering again.
	
	["hud_front"] = function(v, evt)
		
		if evt.eventindex == 36
			if leveltime & 1
				rframe = N_RandomRange(1, 3)
			end	
			
			drawScreenwidePatch(v, v.cachePatch("H_PADV"..rframe))
		end
		
	end,
	
	[1] = {"function",
			function(evt, battle)
				
				local cam = battle.cam
				local mo = players[0].mo
				local npc = EVT_FindNPC(1)
				
				evt.usecam = true
				
				if evt.ftimer == 1
					P_InstaThrust(mo, 0, 0)
					EVT_SetCamByAngle(battle, 0)
					cam.angle = R_PointToAngle2(cam.x, cam.y, npc.x, npc.y)
					S_FadeOutStopMusic(500)
				end
				
				return true				
				
			end,	
		},
		
	[2] = {"text", "Sonic", "That's Eggman over there!", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE}},	

	[3] = {"function",
			function(evt, battle)
				
				local cam = battle.cam
				local mo = players[0].mo
				local t = EVT_FindTeleportPoint(0)
				local npc = EVT_FindNPC(1)
				
				evt.usecam = true
				
				if evt.ftimer == 1
					P_TeleportMove(mo, t.x, t.y, t.z)
					mo.angle = ANG1*90
					P_InstaThrust(mo, mo.angle, FRACUNIT*60)
					mo.state = S_PLAY_WALK
					
					EVT_SetCamByAngle(battle, 1)
					cam.angle = R_PointToAngle2(cam.x, cam.y, npc.x, npc.y)
					
				elseif evt.ftimer == TICRATE/2
				
					return true
				end	
				
			end,	
		},
		
	[4] = {"text", "Sonic", "Eggman! What the thok did you do?! Where are we!?", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE}},			

	[5] = {"function",
			function(evt, battle)
				
				local cam = battle.cam
				local mo = players[0].mo
				local t = EVT_FindTeleportPoint(1)
				local npc = EVT_FindNPC(1)
				
				evt.usecam = true
				
				if evt.ftimer == 1
					CAM_goto(cam, t.x, t.y, t.z)
					CAM_angle(cam, 0)
					CAM_aiming(cam, ANG1*10)
				elseif evt.ftimer == TICRATE
					return true
				end
			end,	
		},

	[6] = {"text", "Eggman", "I could ask you the same...", nil, nil, nil, {"H_EGGAOA", SKINCOLOR_RED}},

	[7] = {"function",
			function(evt, battle)
				
				local cam = battle.cam
				local mo = players[0].mo
				local t1 = EVT_FindTeleportPoint(5)
				local t2 = EVT_FindTeleportPoint(6)
				local npc = EVT_FindNPC(1)
				
				evt.usecam = true
				
				if evt.ftimer == 1
					EVT_SetCamByAngle(battle, 2)
					cam.angle = 0
					
					P_TeleportMove(mo, t1.x, t1.y, t1.z)
					mo.angle = 0
					
					P_TeleportMove(npc, t2.x, t2.y, t2.z)
					npc.angle = 0
					
					return true
				end
			end,	
		},
		
	[8] = {"text", "Eggman", "Just what were you thinking blowing up a Chaos Emerald powered machine!", nil, nil, nil, {"H_EGGAOA", SKINCOLOR_RED}},	

	[9] = {"function",
			function(evt, battle)
				
				local cam = battle.cam
				local mo = players[0].mo
				local npc = EVT_FindNPC(1)
				
				evt.usecam = true
				
				if evt.ftimer == 1
					emotionBubble(mo, EMOTE_SURPRISED)
					mo.angle = R_PointToAngle2(mo.x, mo.y, npc.x, npc.y)
				
				elseif evt.ftimer == TICRATE/2
					return true
				end	
			end,	
		},
		
	[10] = {"text", "Sonic", "Huh!?", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE}},				
	[11] = {"text", "Sonic", "That's rich coming from the \"300 IQ Doctor\" who built such dangerous crap in the first place!", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE}},		

	[12] = {"function",
			function(evt, battle)
				
				local cam = battle.cam
				local mo = players[0].mo
				local npc = EVT_FindNPC(1)
				
				evt.usecam = true
				
				if evt.ftimer == 1
					emotionBubble(npc, EMOTE_SURPRISED)
					npc.angle = R_PointToAngle2(npc.x, npc.y, mo.x, mo.y)
					return true
				end
			end,	
		},
	
	[13] = {"text", "Eggman", "You insolent little...!", nil, nil, nil, {"H_EGGAOA", SKINCOLOR_RED}},	

	[14] = {"function",
			function(evt, battle)
				
				local cam = battle.cam
				local mo = players[0].mo
				local npc = EVT_FindNPC(1)
				
				local t1 = EVT_FindTeleportPoint(10)
				local t2 = EVT_FindTeleportPoint(11)
				
				evt.usecam = true
				
				if evt.ftimer == TICRATE/2
					playSound(1, sfx_shadow)
					
					mo.enm1 = P_SpawnMobj(t1.x, t1.y, t1.z, MT_DUMMY)
					mo.enm1.tics = -1
					mo.enm1.sprite = SPR_ENM1
					mo.enm1.frame = D
					mo.enm1.angle = 0

					mo.enm2 = P_SpawnMobj(t2.x, t2.y, t2.z, MT_DUMMY)
					mo.enm2.tics = -1
					mo.enm2.sprite = SPR_ENM1
					mo.enm2.frame = D
					mo.enm2.angle = 0
					
				elseif evt.ftimer == TICRATE
					return true
				end
			end,	
		},
		
	[15] = {"text", "Sonic", "That's...", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE}},	
	
	[16] = {"function",
			function(evt, battle)
				
				local cam = battle.cam
				local mo = players[0].mo
				local npc = EVT_FindNPC(1)
				
				CAM_angle(cam, ANG1*180)
				
				if evt.ftimer == 1
					S_ChangeMusic("CALMTY", true)
				elseif evt.ftimer == TICRATE*3/2
					return true
				end	
			end,
		},	

	[17] = {"text", "Eggman", "What are those...!", nil, nil, nil, {"H_EGGAOA", SKINCOLOR_RED}},
	
	
	[18] = {"function",
			function(evt, battle)
				
				local cam = battle.cam
				local mo = players[0].mo
				local npc = EVT_FindNPC(1)
				
				CAM_angle(cam, ANG1*180)
				if evt.ftimer == 1
					playSound(1, sfx_dash)
					mo.angle = R_PointToAngle2(mo.x, mo.y, mo.enm1.x, mo.enm1.y)
					mo.player.pflags = $|PF_SPINNING
					mo.state = S_PLAY_ROLL
					P_InstaThrust(mo, mo.angle, FRACUNIT*50)
				end
				
				if R_PointToDist2(mo.x, mo.y, mo.enm1.x, mo.enm1.y) < FRACUNIT*50
				and not mo.hit_enm1
					mo.hit_enm1 = 1
					playSound(1, sfx_hit)
					
					mo.player.pflags = $ & ~PF_SPINNING
					P_InstaThrust(mo, mo.angle, -20*FRACUNIT)
					mo.momz = FRACUNIT*8
					
				elseif mo.hit_enm1
					
					mo.hit_enm1 = $+1
					
					if mo.hit_enm1 > TICRATE/2
						CAM_angle(cam, R_PointToAngle2(cam.x, cam.y, mo.x, mo.y))
						npc.angle = R_PointToAngle2(npc.x, npc.y, mo.x, mo.y)
					end

					if P_IsObjectOnGround(mo)
						if FixedHypot(mo.momx, mo.momy)
							mo.state = S_PLAY_WALK
							mo.frame = A
							
							local dust = P_SpawnMobj(mo.x, mo.y, mo.z, MT_DUMMY)
							dust.state = S_SPINDUST1
							dust.momx = P_RandomRange(-4, 4)*FRACUNIT
							dust.momy = P_RandomRange(-4, 4)*FRACUNIT
							dust.momz = P_RandomRange(0, 5)*FRACUNIT
							
							if leveltime % 8 ==0
								playSound(1, sfx_skid)
							end	
						else
							mo.state = S_PLAY_STND
							mo.hit_enm1 = nil
							return true
						end	
					end
					
				end
			end,
		},		

	[19] = {"text", "Sonic", "No effect!?", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE}},	
	[20] = {"text", "Sonic", "Whatever these are... They're sturdier than your cardboard badniks...! Let's get outta here!", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE}},	

	[21] = {"function",
			function(evt, battle)
				
				local cam = battle.cam
				local mo = players[0].mo
				local npc = EVT_FindNPC(1)
				
				evt.usecam = true
				
				if evt.ftimer == 1
					emotionBubble(mo, EMOTE_EXCLAMATION)
					return true
				end
			end,	
		},

	[22] = {"text", "Sonic", "Huh...? What's that...?", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE}},			
	[23] = {"text", "Sonic", "Some kind of... gun?", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE}},	

	[24] = {"function",
			function(evt, battle)
				
				local cam = battle.cam
				local mo = players[0].mo
				local npc = EVT_FindNPC(1)
				
				evt.usecam = true
				
				if evt.ftimer == 1
					P_FlashPal(mo.player, PAL_WHITE, 10)
					mo.state = S_PLAY_STND
					mo.tics = -1
					mo.sprite2 = SPR2_PAIN
					mo.frame = A
					
					local cx = mo.x + 320*cos(mo.angle)
					local cy = mo.y + 320*sin(mo.angle)
					P_TeleportMove(cam, cx, cy, cam.z)
					CAM_angle(cam, R_PointToAngle2(cam.x, cam.y, mo.x, mo.y))
					
					S_FadeOutStopMusic(500)
					
				elseif evt.ftimer == 20
					return true
				end	
			end,	
		},
		
	[25] = {"text", "???", "I am thou...", nil, nil, nil, nil},			
	[26] = {"text", "???", "Thou art I...", nil, nil, nil, nil},
	[27] = {"text", "???", "The strings of fate seem to slow thou down, will thou just turn thy back and give up?", nil, nil, nil, nil},
	[28] = {"text", "???", "Or will thou struggle to get free in spite of thy weakness?", nil, nil, nil, nil},

	[29] = {"text", "Sonic", "...", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE}},

	[30] = {"function",
			function(evt, battle)
				
				local cam = battle.cam
				local mo = players[0].mo
				local bot = server.plentities[1][1]
				
				local npc = EVT_FindNPC(1)
				
				evt.usecam = true
				
				if evt.ftimer == 1
					P_TeleportMove(bot, mo.x, mo.y, mo.z)
					bot.angle = mo.angle
					bot.flags2 = $ & ~MF2_DONTDRAW
					ANIM_set(bot, bot.anim_evoker, false)
					playSound(1, sfx_arm)
					
					mo.sprite = SPR_NULL
					
					S_ChangeMusic("INVOC", true, nil, 0, 0, 50, 50)					
					
				elseif evt.ftimer == 20
					return true
				end	
			end,
		},
		
	[31] = {"text", "Sonic", "Per...", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE}},
	[32] = {"text", "Eggman", "Hey hey hey! What are you doing!?", nil, nil, nil, {"H_EGGAOA", SKINCOLOR_RED}},

	[33] = {"text", "Sonic", "So...", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE},
				function(evt, battle)
					local mo = players[0].mo
					local bot = server.plentities[1][1]
					summonAura(bot)
				end
			},
			
	[34] = {"text", "Eggman", "A-at least make sure there's one left for me!!", nil, nil, nil, {"H_EGGAOA", SKINCOLOR_RED},
				function(evt, battle)
					local mo = players[0].mo
					local bot = server.plentities[1][1]
					summonAura(bot)
				end	
			},	
	
	[35] = {"text", "Sonic", "Na...!", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE},
				function(evt, battle)
					local mo = players[0].mo
					local bot = server.plentities[1][1]
					summonAura(bot)
				end
			},
			
	[36] = {"function",
			function(evt, battle)
				
				local cam = battle.cam
				local mo = players[0].mo
				local bot = server.plentities[1][1]
				
				local npc = EVT_FindNPC(1)
				
				evt.usecam = true
				
				if evt.ftimer == 1
					P_TeleportMove(bot, mo.x, mo.y, mo.z)
					bot.angle = mo.angle
					bot.flags2 = $ & ~MF2_DONTDRAW
					ANIM_set(bot, bot.anim_evoker, false)
					
					mo.sprite = SPR_NULL
					playSound(1, sfx_summon)
					
					local tx = bot.x - 64*cos(bot.angle)
					local ty = bot.y - 64*sin(bot.angle)
					
					mo.fakepersona = P_SpawnMobj(tx, ty, mo.z, MT_DUMMY)
					ANIM_set(mo.fakepersona, personaList["orpheus"].anim_idle, true)
					mo.fakepersona.flags2 = $|MF2_DONTDRAW
				elseif evt.ftimer == 20
					return true
				end	
			end,
		},	

	[37] = {"function",
			function(evt, battle)
				
				local cam = battle.cam
				local mo = players[0].mo
				local bot = server.plentities[1][1]
				
				local npc = EVT_FindNPC(1)
				
				evt.usecam = true
					
				-- run anim handler on persona
				ANIM_handle(mo.fakepersona)
				summonAura(bot)
				
				if evt.ftimer == 1
					mo.fakepersona.momz = FRACUNIT*4
					mo.fakepersona.flags2 = $ & ~MF2_DONTDRAW
				else
					mo.fakepersona.momz = $*90/100
				end	
				
				local tflag = max(0, 10 - evt.ftimer)
				mo.fakepersona.frame = ($ & ~FF_TRANSMASK) | (tflag << FF_TRANSSHIFT)
				mo.fakepersona.angle = bot.angle
				mo.fakepersona.scale = bot.scale*2
				
				if evt.ftimer == TICRATE*2
					return true
				end	
			end,
		},	

	[38] = {"text", "???", "From the sea of thy heart I cometh...", nil, nil, nil, nil,
				function(evt, battle)
					local mo = players[0].mo
					local bot = server.plentities[1][1]
					summonAura(bot)
					ANIM_handle(mo.fakepersona)
				end
			},

	[39] = {"text", "???", "I am the master of strings...", nil, nil, nil, nil,
				function(evt, battle)
					local mo = players[0].mo
					local bot = server.plentities[1][1]
					summonAura(bot)
					ANIM_handle(mo.fakepersona)
				end
			},		

	[40] = {"text", "Orpheus", "I, Orpheus, will lend thou my strength... Let us fight against fate!", nil, nil, nil, nil,
				function(evt, battle)
					local mo = players[0].mo
					local bot = server.plentities[1][1]
					summonAura(bot)
					ANIM_handle(mo.fakepersona)
				end
			},	
			
	[41] = {"function",
			function(evt, battle)
				
				local cam = battle.cam
				local mo = players[0].mo
				local bot = server.plentities[1][1]
				local t = EVT_FindTeleportPoint(15)
				local btl = server.P_BattleStatus[1]
				
				local npc = EVT_FindNPC(1)
				
				evt.usecam = true
				
				ANIM_handle(mo.fakepersona)
				summonAura(bot)
				
				if evt.ftimer == 1
					CAM_goto(cam, t.x, t.y, t.z)
				
				elseif evt.ftimer == 20
					
					-- this flag is used to force Sonic's SP to be 0 and his persona to be "story_00"
					-- setting it removes those behaviours and allow us to give him his real stats!
					SAVE_setEventFlag("storyinit")
					PLYR_initPersona(bot, "orpheus", bot.skin)
					
					DNG_changeSection(1)
					BTL_start(1, {"maya_tut", "maya_tut"}, 0, 0, nil, false, true)
					btl.event_buf = "ev_m22_ev2"
					bot.passiveskills[#bot.passiveskills+1] = "infinite endure"	-- cheat a little...
					btl.norestoremusic = true
					
					bot.commandflags = CDENY_PERSONA|CDENY_TACTICS|CDENY_ITEM|CDENY_GUARD
					
					return true
				end
			end,
		},	
}