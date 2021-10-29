local function B7_cutscenetriggers(btl)
	
	local ps = server.plentities[btl.n]
	local en = ps[1].enemies[1]	-- yep, crude assumption!
	
	if en.enemy ~= "alt" return end
	if server.P_DialogueStatus[btl.n].running return end
	
	if not en.deathanim	-- dead
		D_startEvent(btl.n, "ev_b7_end")
		
	elseif en.hp < en.maxhp
	and not en.cutstate
		D_startEvent(btl.n, "ev_b7_opening")
		en.cutstate = 1
	
	elseif en.cutstate == 1
	and en.hp < en.maxhp*3/4
		D_startEvent(btl.n, "ev_b7_75")
		en.cutstate = 2
		
	elseif en.cutstate == 2
	and en.hp < en.maxhp/2
		D_startEvent(btl.n, "ev_b7_50")
		en.cutstate = 3	

	elseif en.cutstate == 3
	and en.hp < en.maxhp/4
		D_startEvent(btl.n, "ev_b7_25")
		en.cutstate = 4	
	end
end	

local function hud_front(v, evt)

	local t = evt.eventindex
	
	if t == 18
		
		local tflag = 0
		if evt.animtimer
			tflag = max(0, 9 - (evt.animtimer/4))<<V_ALPHASHIFT
		end	
		if tflag < V_10TRANS
		or tflag > V_90TRANS
			tflag = 0
		end

		drawScreenwidePatch(v, v.cachePatch("H_RIP4"), nil, tflag)
	end
end

eventList["ev_b7_end"] = {

		["hud_front"] = hud_front,

		[1] = {"text", "Alt", "...", nil, nil, nil, {"H_ALT03", SKINCOLOR_BLUE}},
		[2] = {"text", "Alt", "I lost...", nil, nil, nil, {"H_ALT03", SKINCOLOR_BLUE}},
		
		[3] = {"function", function(evt, btl)

								local t = server.plentities[btl.n][1].enemies[1]	-- hacky, but works....
								ANIM_set(t, t.anim_special1, true)
								return true
							end},
		
		[4] = {"text", "Alt", "Well, I suppose that's what I get for being such a slacker!", nil, nil, nil, {"H_ALT01", SKINCOLOR_BLUE}},

		[5] = {"function", function(evt, btl)

								local t = server.plentities[btl.n][1].enemies[1]	-- hacky, but works....
								ANIM_set(t, t.anim_stand, true)
								evt.animtimer = nil
								return true
							end},
		
		[6] = {"text", "Alt", "As for you lot...", nil, nil, nil, {"H_ALT01", SKINCOLOR_BLUE}},
		[7] = {"text", "Alt", "You have incredible strength, I'm sure you'll be able to overcome anything.", nil, nil, nil, {"H_ALT01", SKINCOLOR_BLUE}},
		[8] = {"text", "Alt", "Though it doesn't mean you get to be as lazy as I am from now on.", nil, nil, nil, {"H_ALT02", SKINCOLOR_BLUE}},
		[9] = {"text", "Alt", "Someday, you might just find yourselves facing an even greater power... ", nil, nil, nil, {"H_ALT03", SKINCOLOR_BLUE}},
		[10] = {"text", "Alt", "So don't stop honing your skills!", nil, nil, nil, {"H_ALT01", SKINCOLOR_BLUE}},
		[11] = {"text", "Alt", "...", nil, nil, nil, {"H_ALT03", SKINCOLOR_BLUE}},
		[12] = {"text", "Alt", "Now then.", nil, nil, nil, {"H_ALT03", SKINCOLOR_BLUE}},
		[13] = {"text", "Alt", "I've worked up quite an appetite with all that fighting...", nil, nil, nil, {"H_ALT01", SKINCOLOR_BLUE}},
		[14] = {"text", "Alt", "Remember the deal? 2 million cookies. Give em to me!", nil, nil, nil, {"H_ALT02", SKINCOLOR_BLUE}},
		[15] = {"text", "Alt", "What do you mean the deal was 1 million cookies if you lost?", nil, nil, nil, {"H_ALT05", SKINCOLOR_BLUE}},
		[16] = {"text", "Alt", "I kid, I kid...", nil, nil, nil, {"H_ALT03", SKINCOLOR_BLUE}},
		[17] = {"text", "Alt", "Let's just leave this dumpster already. I'm hungry.", nil, nil, nil, {"H_ALT01", SKINCOLOR_BLUE}},
		
		[18] = {"function", function(evt, btl)
								
								local t = server.plentities[btl.n][1].enemies[1]
								
								evt.animtimer = $ and $+1 or 1
								if evt.animtimer == TICRATE
									-- lol hack
									btl.battlestate = BS_MPFINISH
									btl.hudtimer.mpfinish = 1
									t.hp = 0
									t.fuse = 2
									
									return true
								end
							end},
		
}

eventList["ev_b7_start"] = {
		
	[1] = {"function", 	function(evt, btl)
							
							local t = server.plentities[btl.n][1].enemies[1]	-- hacky, but works....
							local cam = btl.cam
							
							evt.animtimer = $ and $+1 or 1
							if evt.animtimer == 1
								for p in players.iterate do
									if p and p.valid and p.control and p.control.valid and p.control.battlen == btl.n
										S_FadeOutStopMusic(250, p)
									end	
								end
								
								local destx = cam.x - 128*cos(cam.angle)
								local desty = cam.y - 128*sin(cam.angle)
								CAM_goto(cam, destx, desty, cam.z + FRACUNIT*32)
								
							end
							
							
							
							if evt.animtimer >= 20
							and evt.animtimer <= 60
							and evt.animtimer % 3 == 0


								local s = P_SpawnMobj(t.x + P_RandomRange(-128, 128)<<FRACBITS, t.y + P_RandomRange(-128, 128)<<FRACBITS, t.z + P_RandomRange(0, 192)<<FRACBITS, MT_DUMMY)
								s.color = SKINCOLOR_WHITE
								s.state = S_MEGISTAR1
								s.scale = $*2 + P_RandomRange(0, 65535)
								playSound(t.battlen, sfx_hamas1)
							end
							
							if evt.animtimer == 60
								evt.animtimer = nil
								return true
							end	
						end},

	[2] = {"text", "???", "Lame..."},	

	[3] = {"function", 	function(evt, btl)
							
							local t = server.plentities[btl.n][1].enemies[1]	-- hacky, but works....
							local cam = btl.cam
							
							evt.animtimer = $ and $+1 or 1
							
							if evt.animtimer == TICRATE/2
							
								-- !?
								local excl = P_SpawnMobj(t.x, t.y, t.z+90*FRACUNIT, MT_DUMMY)
								excl.flags = MF_NOCLIPHEIGHT|MF_NOGRAVITY|MF_NOBLOCKMAP
								excl.scale = 1
								excl.destscale = FRACUNIT*2
								excl.scalespeed = FRACUNIT/2
								excl.sprite = SPR_XCLA
								excl.frame = A|FF_FULLBRIGHT
								excl.fuse = 20
								excl.momx = P_RandomRange(-3, 3)*FRACUNIT
								excl.momy = P_RandomRange(-3, 3)*FRACUNIT
								
								t.passiveskills = {}	-- remove inf endure
								
								playSound(t.battlen, sfx_megi6)
								local an = 0
								for i = 1, 32

									local s = P_SpawnMobj(t.x, t.y, t.z + FRACUNIT*32, MT_DUMMY)
									s.color = SKINCOLOR_WHITE
									s.state = S_MEGITHOK
									s.scale = $/2
									s.fuse = TICRATE*2
									P_InstaThrust(s, an*ANG1, 50<<FRACBITS)

									s = P_SpawnMobj(t.x, t.y, t.z + FRACUNIT*32, MT_DUMMY)
									s.color = SKINCOLOR_WHITE
									s.state = S_MEGITHOK
									s.scale = $/4
									s.fuse = TICRATE*2
									P_InstaThrust(s, an*ANG1, 30<<FRACBITS)

									an = $ + (360/32)
								end

								local ne = BTL_spawnEnemy(t, "alt", false, t.x, t.y, t.z)
								ne.flags = $|MF_NOGRAVITY
								ANIM_set(ne, ne.anim_special1, true)
								
								ne.z = ne.floorz + 2048*FRACUNIT
								
								damageObject(t, 9999)
								
							end
							
							if evt.animtimer == 100
								return true
							end	
						end},
	
	
	[4] = {"text", "???", "Man, you made it all the way down there and this is the strongest thing this place has?"},	
	[5] = {"text", "???", "That sucks."},
	
	[6] = {"function", 	function(evt, btl)
							
							local t = server.plentities[btl.n][1].enemies[2]	-- hacky, but works....
							local cam = btl.cam
							
							evt.animtimer = $ and $+1 or 1	
							
							if evt.animtimer >= TICRATE/2
								t.momz = -(t.z - t.floorz)/4
							end
							
							if evt.animtimer == TICRATE*6
								evt.animtimer = nil
								t.flags = $ & ~MF_NOGRAVITY
								return true
							end
						end},

	[7] = {"text", "Alt", "We can't have things end this way now can we?", nil, nil, nil, {"H_ALT03", SKINCOLOR_BLUE}},
	[8] = {"text", "Alt", "I had the cookies ready to watch you lot have a nice fight, but it got boring instantly!", nil, nil, nil, {"H_ALT04", SKINCOLOR_BLUE}},
	[9] = {"text", "Alt", "...", nil, nil, nil, {"H_ALT03", SKINCOLOR_BLUE}},
	[10] = {"text", "Alt", "Long story short...", nil, nil, nil, {"H_ALT01", SKINCOLOR_BLUE}},
	[11] = {"text", "Alt", "Try not to bore me as much as that clown I just erased.", nil, nil, nil, {"H_ALT02", SKINCOLOR_BLUE}},
	
	[12] = {"function", 	function(evt, btl)
							
							local t = server.plentities[btl.n][1].enemies[2]	-- hacky, but works....
							local cam = btl.cam
							
							evt.animtimer = $ and $+1 or 1	
							
							if evt.animtimer == TICRATE/2
								ANIM_set(t, t.anim_stand, true)
								evt.animtimer = nil
								
								btl.turnorder = {}
								BTL_fullCleanse(btl)
								btl.func = B7_cutscenetriggers
								
								for p in players.iterate do
									if p and p.control and p.control.valid and p.control.battlen == btl.n
										S_ChangeMusic("CTWR", true, p)
									end	
								end	
								
								return true
							end
							
						end},		
	
}

eventList["ev_b7_opening"] = {
	[1] = {"text", "Alt", "I may not look like much, but you wouldn't live to regret showing any restraint against me.", nil, nil, nil, {"H_ALT01", SKINCOLOR_BLUE}},
}

eventList["ev_b7_75"] = {
	[1] = {"text", "Alt", "Still standing, I see?", nil, nil, nil, {"H_ALT02", SKINCOLOR_BLUE}},
	[2] = {"function", 	function(evt, btl)
							
							local t = server.plentities[btl.n][1].enemies[1]	-- hacky, but works....
							local cam = btl.cam
							ANIM_set(t, t.anim_special1)
							return true
							
			end},				
	[3] = {"text", "Alt", "I suppose that just means I can go all out myself!", nil, nil, nil, {"H_ALT03", SKINCOLOR_BLUE}},
}

eventList["ev_b7_50"] = {
	[1] = {"text", "Alt", "Alright, you have me interested...", nil, nil, nil, {"H_ALT01", SKINCOLOR_BLUE}},
	[2] = {"text", "Alt", "Very well, show me...", nil, nil, nil, {"H_ALT03", SKINCOLOR_BLUE}},
	[3] = {"text", "Alt", "Show me the extent of your power!", nil, nil, nil, {"H_ALT06", SKINCOLOR_BLUE}},
}

eventList["ev_b7_25"] = {
	[1] = {"text", "Alt", "Haha, man... \nHave I actually met my match?", nil, nil, nil, {"H_ALT03", SKINCOLOR_BLUE}},
	[2] = {"text", "Alt", "And here I was gonna force you to buy me a million cookies if you lost...", nil, nil, nil, {"H_ALT03", SKINCOLOR_BLUE}},
}