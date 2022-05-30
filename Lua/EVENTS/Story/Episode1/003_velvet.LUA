-- Story script for MAP06
-- Contains associated events and item drop tables

local mapnum = 6	-- change this if the mapnum changes for w/e reason

-- NPCs
D_NPCData[mapnum] = {
	
	-- Alt (sitting)
	[1] = {
		angle = 270*ANG1,
		sprite = SPR_VALT,
		frame = J,
		thinker = function(mo)
					mo.flags = $|MF_NOGRAVITY
					mo.tics = -1
				end	
		
	},
	
}

-- Regular entry
eventList["ev_velvetroom_entry1"] = {

	[1] = {"function",
			function(evt, battle)
				local cam = battle.cam
				
				evt.usecam = true
				
				EVT_SetCamByAngle(battle, 0)
				cam.angle = ANG1*90
				cam.aiming = -ANG1*10
				
				if evt.ftimer == TICRATE*3/2
					return true
				end	
			end,
	},
	
	[2] = {"text", "Alt", "Welcome to the Velvet Room...", nil, nil, nil, {"H_ALT01", SKINCOLOR_BLUE}},	

	[3] = {"function",
			function(evt, battle)
				M_openMenu(server.mo, "m_selectfacility")
				server.awayviewtics = TICRATE*60*60*60	-- this should be long enough. maybe.
				return true
			end,
	},

}

-- Regular leave
eventList["ev_velvetroom_leave1"] = {
	
	[1] = {"text", "Alt", "Leaving already? See ya.", nil, nil, nil, {"H_ALT01", SKINCOLOR_BLUE}},	

	[2] = {"function",
			function(evt, battle)
				
				local fn = 	function(o, pmo)
								pmo.angle = $ + ANG1*180
							end
				
				server.obj_interact_map = {1999, D_NPCData[server.obj_velvet_map][1999].angle, fn}
				DNG_loadNewMap(server.obj_velvet_map)
				return true
			end,
	},

}

-- First time in the Velvet Room
eventList["ev_m06_ev1"] = {
	
	[1] = {"function",
			function(evt, battle)
				local cam = battle.cam
				
				evt.usecam = true
				
				EVT_SetCamByAngle(battle, 0)
				cam.angle = ANG1*90
				cam.aiming = -ANG1*10
				
				if evt.ftimer == TICRATE*2
					return true
				end	
			end,
	},
	
	[2] = {"text", "???", "Finally awake, mh?", nil, nil, nil, {"H_ALT01", SKINCOLOR_BLUE}},
	[3] = {"text", "???", "Welcome to the Velvet Room...", nil, nil, nil, {"H_ALT01", SKINCOLOR_BLUE}},
	[4] = {"text", "???", "This place exists between mind and matter, dream and reality.", nil, nil, nil, {"H_ALT01", SKINCOLOR_BLUE}},	
	[5] = {"text", "???", "...Or so says my master. However, he hasn't come here for quite some time.", nil, nil, nil, {"H_ALT01", SKINCOLOR_BLUE}},	
	[6] = {"text", "Alt", "I'm Alt, a resident of this place. Nice to meet ya.", nil, nil, nil, {"H_ALT01", SKINCOLOR_BLUE}},
	[7] = {"text", "Alt", "We rarely ever get guests here. In fact, you're the first I've ever seen...", nil, nil, nil, {"H_ALT01", SKINCOLOR_BLUE}},
	[8] = {"text", "Alt", "That power you awakened to that caused you to pass out just now. We call it Persona.", nil, nil, nil, {"H_ALT01", SKINCOLOR_BLUE}},
	[9] = {"text", "Alt", "It's a manifestation of one of your facades. Your will to stand against fate.", nil, nil, nil, {"H_ALT01", SKINCOLOR_BLUE}},
	[10] = {"text", "Alt", "Believe me or not however, but your power is weak.", nil, nil, nil, {"H_ALT01", SKINCOLOR_BLUE}},
	[11] = {"text", "Alt", "Pathetically so, may I add...", nil, nil, nil, {"H_ALT02", SKINCOLOR_BLUE}},
	[12] = {"text", "Alt", "My role as resident of this Velvet Room is to help you hone that power.", nil, nil, nil, {"H_ALT01", SKINCOLOR_BLUE}},
	[13] = {"text", "Alt", "However, there is one condition...", nil, nil, nil, {"H_ALT01", SKINCOLOR_BLUE}},
	[14] = {"text", "Alt", "That you bring me 1000 homemade cookies by tomorrow.", nil, nil, nil, {"H_ALT02", SKINCOLOR_BLUE}},
	[15] = {"text", "Alt", "Okay, that's a joke. Partly.", nil, nil, nil, {"H_ALT03", SKINCOLOR_BLUE}},
	[16] = {"text", "Alt", "You must understand that hence forth, your actions and their consequences are your responsibility.", nil, nil, nil, {"H_ALT01", SKINCOLOR_BLUE}},
	[17] = {"text", "Alt", "That's the condition.", nil, nil, nil, {"H_ALT01", SKINCOLOR_BLUE}},
	[18] = {"text", "Alt", "It's fine if you don't understand the circumstances right now.", nil, nil, nil, {"H_ALT01", SKINCOLOR_BLUE}},
	[19] = {"text", "Alt", "For the time being, please hold on to these.", nil, nil, nil, {"H_ALT01", SKINCOLOR_BLUE}},
	[20] = {"item", { {"item", "velvet_wallet", 1}, {"item", "velvet_key", 1} }},
	[21] = {"text", "Alt", "These coins you got from your foes. It's a currency called Macca.", nil, nil, nil, {"H_ALT01", SKINCOLOR_BLUE}},
	[22] = {"text", "Alt", "This wallet allows you to substitute any currency for it.", nil, nil, nil, {"H_ALT01", SKINCOLOR_BLUE}},
	[23] = {"text", "Alt", "And this key allows you to enter this place. So don't lose it, kay?", nil, nil, nil, {"H_ALT01", SKINCOLOR_BLUE}},
	[24] = {"text", "Alt", "...", nil, nil, nil, {"H_ALT03", SKINCOLOR_BLUE}},
	[25] = {"text", "Alt", "It is said that those who set foot in this place are destined to find their answer.", nil, nil, nil, {"H_ALT01", SKINCOLOR_BLUE}},
	[26] = {"text", "Alt", "What will yours be I wonder...", nil, nil, nil, {"H_ALT03", SKINCOLOR_BLUE}},
	[27] = {"text", "Alt", "Your tale begins now. I await its final chapter with interrest...", nil, nil, nil, {"H_ALT01", SKINCOLOR_BLUE}},	
	[28] = {"text", "Alt", "'Till we meet again...", nil, nil, nil, {"H_ALT03", SKINCOLOR_BLUE}},
	
	[29] = {"function", 
				function(evt, battle)
					DNG_loadNewMap(22, "ev_m22_ev5")
					return true
				end
			}
	
}		