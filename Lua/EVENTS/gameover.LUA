local function hud_back(v, evt)

	local t = evt.time
	local tflag = max(0, (9 - t))<<V_ALPHASHIFT
	drawScreenwidePatch(v, v.cachePatch("H_RIP4"), nil, tflag)
end

local function hud_front(v, evt)

	local t = evt.eventindex
	local tflag = max(0, (11 - t))<<V_ALPHASHIFT
	if tflag < V_10TRANS
		tflag = 0
	end

	drawScreenwidePatch(v, v.cachePatch("H_RIP4"), nil, tflag)
end

eventList["ev_gameover"] = {

	["hud_back"] = hud_back,
	["hud_front"] = hud_front,

	[1] = {"text", "???", "Hey!", nil, true, EV_AUTO},
	[2] = {"text", "???", "What are you doing?\nGet up!", nil, nil, EV_AUTO},
	[3] = {"text", "???", "...", nil, nil, EV_AUTO},
	[4] = {"text", "???", "Hey...", nil, nil, EV_AUTO},
	[5] = {"text", "???", "Get up...!", nil, nil, EV_AUTO},
	[6] = {"text", "???", "...", nil, nil, EV_AUTO},
	[7] = {"text", "???", "Answer me!!", nil, nil, EV_AUTO},
	[8] = {"text", "???", "PLEASE!", nil, nil, EV_AUTO},
	[9] = {"text", "???", "I NEED YOU!", nil, nil, EV_AUTO},
	[10] = {"text", "???", "ANSWER ME!!!", nil, nil, EV_AUTO},

	[11] = {"function", function(evt, btl)

	end}
}