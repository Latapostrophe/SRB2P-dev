
eventList["ev_vr1"] = {

	[1] = {"text", "Alt", "Fufufu...\nWelcome to my very own torture chamber!", nil, nil, nil, {"H_ALT03", SKINCOLOR_BLUE}},
	[2] = {"text", "Alt", "Joking aside, \x82Void Run\x80 is a special type of training I've prepared for you lot.", nil, nil, nil, {"H_ALT01", SKINCOLOR_BLUE}},
	[3] = {"text", "Alt", "It's a simple concept, all you have to do is complete some missions within a time limit.", nil, nil, nil, {"H_ALT01", SKINCOLOR_BLUE}},
	[4] = {"text", "Alt", "Depending on your performance, I'll give you some Macca and items after each mission.", nil, nil, nil, {"H_ALT01", SKINCOLOR_BLUE}},
	[5] = {"text", "Alt", "There's a little catch though...", nil, nil, nil, {"H_ALT03", SKINCOLOR_BLUE}},
	[6] = {"text", "Alt", "I'm restricting your level cap and Persona usage. And I expect you to adapt.", nil, nil, nil, {"H_ALT02", SKINCOLOR_BLUE}},
	[7] = {"text", "Alt", "You'll learn to appreciate every last stat point my inexpensive well crafted equipment can give you.", nil, nil, nil, {"H_ALT03", SKINCOLOR_BLUE}},

	[8] = {"text", "Alt", "Missions come in sets of 3.", nil, nil, nil, {"H_ALT01", SKINCOLOR_BLUE}},
	[9] = {"text", "Alt", "After each 3rd mission, you'll get additional rewards and the ability to use the shop.", nil, nil, nil, {"H_ALT01", SKINCOLOR_BLUE}},
	[10] = {"text", "Alt", "Needless to say, the difficulty will also bump up after each 3rd mission, so be prepared!", nil, nil, nil, {"H_ALT03", SKINCOLOR_BLUE}},

	[11] = {"text", "Alt", "Need me to repeat?", {{"No", 12}, {"Yes", 3}}, nil, nil, {"H_ALT01", SKINCOLOR_BLUE}},
	[12] = {"text", "Alt", "Well then, good luck!", nil, nil, nil, {"H_ALT01", SKINCOLOR_BLUE}},
	[13] = {"text", "Alt", "You're going to need it...", nil, nil, nil, {"H_ALT02", SKINCOLOR_BLUE}},
	[14] = {"function",
				function(evt, btl)
					btl.items = {}	-- nope.
					return true
				end
			},
}