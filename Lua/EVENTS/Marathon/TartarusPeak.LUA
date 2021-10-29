local function hud_sparkscreen(v, evt)
	
	local i = evt.eventindex
	if i == 7	-- Index 7 is where we want this overlay to appear
		
		local t = evt.camtimer	-- timer goes up by 1 each frame
		if not t return end
		local ff = t/2
		if ff < 5
			drawScreenwidePatch(v, v.cachePatch("H_ATR"..max(1, ff)))
		else
			local str = min(10, 10 - (ff-TICRATE-5))
			if str > 0
				v.fadeScreen(0, str)
			end
		end
	end
end

local function hud_front(v, evt)

	local t = evt.eventindex
	local tflag = max(0, (11 - t))<<V_ALPHASHIFT
	if tflag < V_10TRANS
		tflag = 0
	end

	drawScreenwidePatch(v, v.cachePatch("H_RIP4"), nil, tflag)
end

local function peakBattleCutsceneTrigger(btl)
	
	local ps = server.plentities[btl.n]
	local en = ps[1].enemies[1]	-- yep, crude assumption!
	
	if en.hp < en.maxhp/2
	and not server.P_DialogueStatus[btl.n].running
	and en.enemy == "mnemesis_1"
		D_startEvent(btl.n, "ev_mpeak_phase2")
	
	elseif en.hp < en.maxhp/2
	and not server.P_DialogueStatus[btl.n].running
	and en.enemy == "mnemesis_2"
		D_startEvent(btl.n, "ev_mpeak_phase3")
	end
	
	if en.enemy == "mnemesis_3"
	and #ps[1].enemies == 1	-- only one enemy left
	and en.guaranteedevasion
		en.guaranteedevasion = nil
		en.turns = 2
		-- copy data from phase 2
		en.skills = enemyList["mnemesis_2"].skills
		BTL_splitSkills(en)
		for i = 1, #en.passiveskills
			if en.passiveskills[i] == "infinite endure"
				table.remove(en.passiveskills, i)
				break
			end	
		end
		
		en.thinker = enemyList["mnemesis_2"].thinker
	end
	return true
end


-- Event to shift to phase 3
eventList["ev_mpeak_phase3"] = {
		
	[1] = {"function", 	function(evt, btl)
							
							local cam = btl.cam
							local ps = server.plentities[btl.n]
							local en = ps[1].enemies[2] or ps[1].enemies[1]	-- yep, crude assumption!	

							evt.camtimer = $ and $+1 or 1
							
							if evt.camtimer == TICRATE*14
								evt.camtimer = nil
								return true
							end		
							
							if evt.camtimer < TICRATE*5
							
								if evt.camtimer & 1
									S_StartSound(en, sfx_pop)
								end	
								
								local x = en.x + P_RandomRange(-128, 128)*FRACUNIT
								local y = en.y + P_RandomRange(-128, 128)*FRACUNIT
								local z = en.z + P_RandomRange(0, 192)*FRACUNIT
								
								local e = P_SpawnMobj(x, y, z, MT_DUMMY)
								e.state = S_QUICKBOOM1
								e.scale = FRACUNIT*3
							end
							
							
							if evt.camtimer == TICRATE*4
								
								for i = 1, #server.plentities[btl.n]
									local mo = server.plentities[btl.n][i]
									if mo and mo.valid and mo.control and mo.control.valid
										P_FlashPal(mo.control, 1, 5)
									end	
								end
								
								BTL_spawnEnemy(en, "mnemesis_arm1", true)
								BTL_spawnEnemy(en, "mnemesis_arm2")
								
								BTL_changeEnemy(en, "mnemesis_3")
								en.guaranteedevasion = true
								
											
							elseif evt.camtimer == TICRATE*6
								return true
							end	
						end	
		},
}

-- Event to shift to phase 2
eventList["ev_mpeak_phase2"] = {
	
	[1] = {"function", 	function(evt, btl)
							
							local cam = btl.cam
							local ps = server.plentities[btl.n]
							local en = ps[1].enemies[1]	-- yep, crude assumption!								
							
							evt.camtimer = $ and $+1 or 1
							
							if evt.camtimer == TICRATE*14
								evt.camtimer = nil
								return true
							end								
							
							-- make cam face metal 
							if evt.camtimer == 1
								
								local x = en.x + 255*cos(en.angle)
								local y = en.y + 255*sin(en.angle)
								CAM_goto(cam, x, y, en.z + 32*FRACUNIT)
								CAM_angle(cam, R_PointToAngle2(x, y, en.x, en.y))
								
								ANIM_set(en, {SPR_MNMS, F, 1})
								
								for i = 1, #ps do
									local pmo = ps[i]
									if pmo and pmo.control and pmo.control.valid
										S_ChangeMusic("CTWR", true, pmo.control, 0, 0, 300)
									end
								end
								
							
							elseif evt.camtimer > TICRATE/2
							and evt.camtimer < TICRATE*10
								
								for i = 1, 2
									
									local x = en.x + P_RandomRange(-80, 80)*FRACUNIT
									local y = en.y + P_RandomRange(-80, 80)*FRACUNIT
									local z = en.z - FRACUNIT*40 + P_RandomRange(0, 100)*FRACUNIT
									
									local t = P_SpawnMobj(x, y, z, MT_THOK)
									t.color = SKINCOLOR_BLACK
									t.frame = A
									t.tics = TICRATE
									t.fuse = TICRATE
									t.scale = FRACUNIT*2
									t.destscale = 0
									t.momz = P_RandomRange(1, 3)*P_RandomRange(-1, 1)*FRACUNIT
								end
								
								for i = 1, 2
									
									local t = P_SpawnMobj(en.x, en.y, en.z + FRACUNIT*30, MT_THOK)
									t.color = SKINCOLOR_RED
									t.tics = TICRATE/2
									t.fuse = TICRATE/2
									t.destscale = 0
									t.frame = A
									t.scalespeed = FRACUNIT/17
									t.momx = P_RandomRange(-32, 32)*FRACUNIT
									t.momy = P_RandomRange(-32, 32)*FRACUNIT
									t.momz = P_RandomRange(-32, 32)*FRACUNIT
								end
								
								if evt.camtimer == TICRATE*2	-- dezoom
									local x = en.x + 512*cos(en.angle)
									local y = en.y + 512*sin(en.angle)
									CAM_goto(cam, x, y, en.z + 64*FRACUNIT)
									CAM_angle(cam, R_PointToAngle2(x, y, en.x, en.y))								
								end
								
								-- arm explosion 1
								if evt.camtimer == TICRATE*3
									
									playSound(en.battlen, sfx_srip)		-- die monster
									
									local dist = 64
									local an = en.angle + ANG1*90
									local x = en.x + dist*cos(an)
									local y = en.y + dist*sin(an)
									local z = en.z + P_RandomRange(32, 80)*FRACUNIT
									
									for i = 1, 32
										local t = P_SpawnMobj(x, y, z, MT_THOK)
										t.color = SKINCOLOR_BLACK
										t.frame = A
										t.tics = TICRATE
										t.fuse = TICRATE
										t.scale = FRACUNIT*2
										t.destscale = 0
										t.momz = P_RandomRange(4, 12)*(P_RandomRange(0, 1) and 1 or -1)*FRACUNIT
										t.color = i%2 and SKINCOLOR_BLACK or SKINCOLOR_RED
										t.angle = an
										P_InstaThrust(t, an, P_RandomRange(16, 64)*FRACUNIT)
									end
								end

								-- arm explosion 2
								if evt.camtimer == TICRATE*4
									
									playSound(en.battlen, sfx_srip)		-- die monster
									
									local dist = 64
									local an = en.angle - ANG1*90
									local x = en.x + dist*cos(an)
									local y = en.y + dist*sin(an)
									local z = en.z + P_RandomRange(32, 80)*FRACUNIT
									
									for i = 1, 32
										local t = P_SpawnMobj(x, y, z, MT_THOK)
										t.color = SKINCOLOR_BLACK
										t.frame = A
										t.tics = TICRATE
										t.fuse = TICRATE
										t.scale = FRACUNIT*2
										t.destscale = 0
										t.momz = P_RandomRange(0, 12)*(P_RandomRange(0, 1) and 1 or -1)*FRACUNIT
										t.color = i%2 and SKINCOLOR_BLACK or SKINCOLOR_RED
										t.angle = an
										P_InstaThrust(t, an, P_RandomRange(16, 64)*FRACUNIT)
									end
								end
								
								if evt.camtimer >= TICRATE*7
									for i = 1, 4
										
										local t = P_SpawnMobj(en.x, en.y, en.z + FRACUNIT*30, MT_THOK)
										t.color = SKINCOLOR_BLACK
										t.tics = TICRATE/2
										t.fuse = TICRATE/2
										t.scale = FRACUNIT/2
										t.destscale = 0
										t.frame = A
										t.scalespeed = FRACUNIT/TICRATE
										t.momx = P_RandomRange(-64, 64)*FRACUNIT
										t.momy = P_RandomRange(-64, 64)*FRACUNIT
										t.momz = P_RandomRange(-64, 64)*FRACUNIT
									end	
									
									for i = 1, 4
										
										local t = P_SpawnMobj(en.x + P_RandomRange(-32, 32)*FRACUNIT, en.y + P_RandomRange(-32, 32)*FRACUNIT, en.z + FRACUNIT*30, MT_THOK)
										t.color = SKINCOLOR_BLACK
										t.tics = TICRATE/2
										t.fuse = TICRATE/2
										t.scale = FRACUNIT*2
										t.frame = A
										t.scalespeed = FRACUNIT/TICRATE
										t.momz = 64*FRACUNIT
									end
									
									if evt.camtimer > TICRATE*8
									and leveltime%2 == 0
										createSplat(en, FRACUNIT*2)
									end
									
									-- swap the enemy.
									if evt.camtimer == TICRATE*9
										BTL_changeEnemy(en, "mnemesis_2")
									end	
								end
							end
						end}
	
}

-- Event to start the battle
eventList["ev_mpeak1"] = {

	["hud_front"] = hud_sparkscreen,

	-- move camera and players ontop of tartar sauce
	[1] = {"function",	function(evt,btl)
							
							local cam = btl.cam
							local c = btl.arenacenter
							local ps = server.plentities[btl.n]

							for i = 1, #ps do
								local pmo = ps[i]
								if pmo and pmo.control and pmo.control.valid
									S_FadeOutStopMusic(500, p)
								end
							end
							
							/*if true
								local wave = {"mnemesis_1"}
								BTL_start(btl.n, wave, 0, "O_BATL1", peakBattleCutsceneTrigger, true, true)					
								return
							end*/	
							
							for p in players.iterate do
								if p.P_party == btl.n
									CAM_linkPlayer(cam, p, 99999)
								end
							end
							
							evt.camtimer = $ and $+1 or 1
							
							if evt.camtimer == TICRATE
								evt.camtimer = nil
								return true
							end	
							
							if evt.camtimer == 1
								
								local coords_offset = {{0, 0}, {-128, -128}, {-128, 0}, {-128, 128}}
								for i = 1, #server.plentities[btl.n]
									
									local offx = coords_offset[i][1]*FRACUNIT
									local offy = coords_offset[i][2]*FRACUNIT
									P_TeleportMove(server.plentities[btl.n][i], c.x + offx, c.y + offy, c.z)
									ANIM_set(server.plentities[btl.n][i], server.plentities[btl.n][i].anim_stand_bored, true)
									server.plentities[btl.n][i].flags2 = $ & ~MF2_DONTDRAW
									server.plentities[btl.n][i].angle = 0
									
								end
								
								-- move cam
								P_TeleportMove(cam, c.x - 768*FRACUNIT, c.y, c.z + FRACUNIT*128)
								cam.angle = 0
							
							/*if evt.camtimer == 1
	
								P_TeleportMove(cam, c.x - FRACUNIT*768, c.y - FRACUNIT*768, c.z + FRACUNIT*768)
								cam.angle = R_PointToAngle2(cam.x, cam.y, c.x, c.y)
								cam.aiming = ANG1*5*/
	
							/*elseif evt.camtimer == 1
								
								P_TeleportMove(cam, c.x - FRACUNIT*512, c.y, c.z + FRACUNIT*512)
								cam.angle = 0
								cam.aiming = ANG1*5*/
								
							end
						end},
						
	[2] = {"text", nil, "You've reached the top of Tartarus..."},					
	[3] = {"text", nil, "There doesn't seem to be anything there..."},
	
	-- Move camera upwards
	[4] = {"function", function(evt, btl)
							
							local cam = btl.cam

							evt.camtimer = $ and $+1 or 1

							for p in players.iterate do
								if p.P_party == btl.n
									CAM_linkPlayer(cam, p)
								end
							end
							
							if evt.camtimer == TICRATE*2
								evt.camtimer = nil
								return true
							end	
							
							CAM_aiming(cam, ANG1*25, ANG1/2)
							
						end},

	[5] = {"text", nil, "...?"},	
	-- Have a spark appear and grow in illusion to go forward
	[6] = {"function", function(evt, btl)
							
							local cam = btl.cam

							evt.camtimer = $ and $+1 or 1

							if evt.camtimer == 1
								
								local an = cam.angle
								local x = cam.x + 512*cos(an)
								local y = cam.y + 512*sin(an)
								
								evt.sparkmobj = P_SpawnMobj(x, y, cam.z + 256*FRACUNIT, MT_DUMMY)
								evt.sparkmobj.sprite = SPR_SSPK
								evt.sparkmobj.tics = -1
								evt.sparkmobj.scale = FRACUNIT/32
								evt.sparkmobj.destscale = FRACUNIT*16
								evt.sparkmobj.momz = -FRACUNIT/2
								evt.sparkmobj.renderflags = $|RF_NOCOLORMAPS
							else
								
								evt.sparkmobj.frame = ((leveltime/2)%2)|FF_FULLBRIGHT
								
							end
							
							
							if evt.sparkmobj.scale == evt.sparkmobj.destscale
								
								evt.sparkmobj.momz = 0
								evt.sparkmobj.fuse = TICRATE/2
								evt.sparkmobj = nil	-- clear
								evt.camtimer = nil
								return true
							end
						end},
	
	-- screen flash in conjunction with hud display
	[7] = {"function", function(evt, btl)

							local cam = btl.cam
							local c = btl.arenacenter
							
							evt.camtimer = $ and $+1 or 1

							for p in players.iterate do
								if p.P_party == btl.n
									CAM_linkPlayer(cam, p)
								end
							end
							
							if evt.camtimer == 10
								-- spawn the fake metal sonic
								local mtl = P_SpawnMobj(c.x + 512*FRACUNIT, c.y, c.z, MT_DUMMY)
								mtl.sprite = SPR_MNMS
								mtl.frame = F
								mtl.tics = -1
								
								evt.mtl = mtl
								
								-- Move camera in front of it
								P_TeleportMove(cam, c.x + 400*FRACUNIT, c.y, c.z + FRACUNIT*20)
								cam.aiming = 0
								
							elseif evt.camtimer == 150
								
								evt.mtl.frame = C
								
							elseif evt.camtimer > 150
							and evt.camtimer < 160
								evt.mtl.frame = C
								if evt.camtimer%3 == 0
									evt.mtl.frame = E
								end
							
							elseif evt.camtimer == 160
								evt.mtl.frame = C
							
							elseif evt.camtimer == 220
								
								local spark = P_SpawnMobj(evt.mtl.x - FRACUNIT*2, evt.mtl.y - FRACUNIT*8, evt.mtl.z + FRACUNIT*24, MT_SUPERSPARK)
								spark.colorized = true
								spark.color = SKINCOLOR_RED
								spark.renderflags = $|RF_NOCOLORMAPS
								
							elseif evt.camtimer == 240
								
								-- Zoom camera out
								CAM_goto(cam, cam.x - 2048*FRACUNIT, cam.y, cam.z + 128*FRACUNIT)

							elseif evt.camtimer == 255
								-- Start the battle! fufu
								local wave = {"mnemesis_1"}
								
								evt.mtl.fuse = 5
								BTL_start(btl.n, wave, 0, "UBATL", peakBattleCutsceneTrigger, true, true)
								
							end
						end}
						
}