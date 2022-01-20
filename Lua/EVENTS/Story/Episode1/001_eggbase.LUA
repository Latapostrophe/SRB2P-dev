-- Story script for MAP21
-- Contains associated events and item drop tables

local mapnum = 21	-- change this if the mapnum changes for w/e reason

-- item boxes:
DNG_itemBoxes[mapnum] = {

	[1] = {
		{"superring", 5},
		{{"weapon", "shoes_01"}, 1},
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