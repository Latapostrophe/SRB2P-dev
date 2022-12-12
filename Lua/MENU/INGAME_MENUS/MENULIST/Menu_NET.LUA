
local files = {}
for i = 1, MAXQSAVEFILES do
	files[i] = {"FILE "..i}
end

-- draw the main command selection like battles
local cmd_names = {
	"SKILL",
	"ITEMS",
	"PERSONA",
	"PARTY",
	"SOCIAL LINK",
	"SYSTEM"
}

local cmd_hints = {
	"Use healing skills.",
	"Use healing items",
	"View or switch Sub-Personas",
	"View party status",
	"View Social Links",
	"Save, load or change game settings",
}

local cmd_gfx = {
	"H_CMD2",
	"H_CMD3",
	"H_CMD4",
	"M_PARTY",
	"M_SLINK",
	"M_OPT",
}

local addy = 0
-- ^ for smooth transition...

local function drawMenu_challenge(v, mo, choice, forcetimer)

	-- reminder that this whole menu is kind of a hack

	--drawScreenwidePatch(v, v.cachePatch("H_RIP4"), nil, V_30TRANS)
	v.fadeScreen(31, 7)

	-- draw the old menu going away at the back
	local timers = mo.m_hudtimers
	local oldtimer = TICRATE/3 - (timers.sclosemenu and (TICRATE/3 - timers.sclosemenu) or timers.smenuopen or 0)

	local mx = 320
	if oldtimer
		mx = 320 + oldtimer*64
	end

	-- draw menu string or smth:
	v.drawFill(mx - 97, 0, 200, 12, 135|V_SNAPTOTOP|V_SNAPTORIGHT)
	V_drawString(v, mx - 102, 0, "SELECT", "FPIMP", V_SNAPTORIGHT|V_SNAPTOTOP, nil, 31, nil, FRACUNIT*75/100)

	local m = M_menus["mpselect_main"].mpselect_mainmenu

	-- draw the command help first:
	v.drawFill(oldtimer*96, 180, 999, 12, 31|V_SNAPTOBOTTOM|V_SNAPTOLEFT)

	-- draw the commands for it:
	for i = 1, #m.choices do
		V_drawString(v, mx - (124 + i*6), 40 + (i*20), m.choices[i][1], "FPIMP", V_SNAPTORIGHT, nil, 0, 31, FRACUNIT*80/100)
	end

	-- now draw our new menu~

	local nchoices = mo.m_dynchoices

	local dy = 92 - 16*(choice-1) --164
	local y = dy-16

	addy = $/2

	if not nchoices return end	-- wait a bit

	-- set addy thru some hack
	local inpt = mo.P_inputs
	local tchoice = choice	-- temp choice used for calc

	if inpt["up"] == 1
		--tchoice = $+1
		if tchoice == 1
			--addy = blocks*16
		else
			tchoice = $+1
			--addy = (84 + 16*(choice-1)) - (84 + 16*(tchoice-1))
		end

	elseif inpt["down"] == 1
		if tchoice == blocks
			--addy = -blocks*32
		else
			tchoice = $-1
			--addy = (32*(choice-1)) - (32*(tchoice-1))
		end
	end


	local t = (timers.sclosemenu and (TICRATE/3 - timers.sclosemenu) or timers.smenuopen or 0)

	PDraw(v, 0, t*32, v.cachePatch("H_CHAL"), V_SNAPTOLEFT)
	v.drawFill(43, 0, 2, 300 - t*32, 135|V_SNAPTOLEFT)

	-- draw the difficulties first:
	for i = 1, nchoices

		if dy < 36
			dy = $+16	-- skip drawing
			continue
		end

		if not mo.challengebattles
			return
		end	-- wait for them to load rlqk...

		local header = mo.challengebattles[i][1]
		if not header break end

		local color = choice == i and 135 or 31
		v.drawFill(97 + t*64, dy+addy, 999, 1, color|V_SNAPTORIGHT)
		v.drawFill(96 + t*64, dy+1+addy, 999, 1, color|V_SNAPTORIGHT)

		v.drawFill(96 + t*64, dy+14+addy, 999, 1, color|V_SNAPTORIGHT)	-- borders
		v.drawFill(97 + t*64, dy+15+addy, 999, 1, color|V_SNAPTORIGHT)

		V_drawString(v, 100 + t*64, dy+4+addy, header.name:upper(), "FPIMP", V_SNAPTORIGHT, nil, 0, 31)

		if srb2p.challenge_bests[mo.challengebattles[i][2]]
			-- technically means the challenge was beaten already!
			PDraw(v, 300 + t*64, dy + 4 +addy, v.cachePatch("M_CROWN"), V_SNAPTORIGHT)
		end

		dy = $+16
	end

	-- info:
	local header = mo.challengebattles[choice][1]
	PDraw(v, t*32, 0, v.cachePatch("H_CINFO"), V_SNAPTORIGHT)
	V_drawString(v, 320 +t*32 - 8, 8, header.name:upper(), "FPIMP", V_SNAPTORIGHT, "right", 31, nil)

	local desc = {header.description}
	if type(header.description) == "table"
		desc = header.description
	end	-- this is to allow multiline descriptions easily without having to add horrible unoptimized shit on string rendering

	for i = 1, #desc
		V_drawString(v, 320 +t*32 - 8, 18 + (i-1)*8, desc[i], "NFNT", V_SNAPTORIGHT, "right", 31, nil)
	end

	V_drawString(v, 320 - 220 +t*32, 42, "LEVEL", "FPIMP", V_SNAPTORIGHT, nil, 31, nil)
	V_drawString(v, 320 - 180 +t*32, 43, header.level, "NFNT", V_SNAPTORIGHT, nil, 31, nil)

	V_drawString(v, 320 - 160 +t*32, 42, "TIME", "FPIMP", V_SNAPTORIGHT, nil, 31, nil)
	local time = header.time
	local str =  G_TicsToMinutes(time)..":"..string.format("%02d", G_TicsToSeconds(time))
	V_drawString(v, 320 - 128 +t*32, 43, str, "NFNT", V_SNAPTORIGHT, nil, 31, nil)

	V_drawString(v, 320 - 80 +t*32, 42, "BEST", "FPIMP", V_SNAPTORIGHT, nil, 31, nil)

	-- show best score
	if header.score

		local score = srb2p.challenge_bests[choice]
		local str

		if not score
			str = "------"
		else
			str = score
		end

		V_drawString(v, 320 - 46 +t*32, 43, str, "NFNT", V_SNAPTORIGHT, nil, 31, nil)

	-- show best time
	else
		local time = srb2p.challenge_bests[choice]
		local str

		if not time
			str = "--:--"
		else
			str =  G_TicsToMinutes(time)..":"..string.format("%02d", G_TicsToSeconds(time))
		end

		V_drawString(v, 320 - 46 +t*32, 43, str, "NFNT", V_SNAPTORIGHT, nil, 31, nil)

	end

	--V_drawString(v, 320 - 90 +t*32, 38, "SCORE", "FPIMP", V_SNAPTORIGHT, nil, 31, nil)
	--V_drawString(v, 320 - 93 +t*32, 46, "TARGET", "FPIMP", V_SNAPTORIGHT, nil, 31, nil)
	--V_drawString(v, 320 - 45 +t*32, 43, header.points, "NFNT", V_SNAPTORIGHT, nil, 31, nil)
end

-- similar menu to challenge menu
local function drawMenu_customDungeons(v, mo, choice, forcetimer)

	-- reminder that this whole menu is kind of a hack

	--drawScreenwidePatch(v, v.cachePatch("H_RIP4"), nil, V_30TRANS)
	v.fadeScreen(31, 7)

	-- draw the old menu going away at the back
	local timers = mo.m_hudtimers
	local oldtimer = TICRATE/3 - (timers.sclosemenu and (TICRATE/3 - timers.sclosemenu) or timers.smenuopen or 0)

	local mx = 320
	if oldtimer
		mx = 320 + oldtimer*64
	end

	-- draw menu string or smth:
	v.drawFill(mx - 97, 0, 200, 12, 135|V_SNAPTOTOP|V_SNAPTORIGHT)
	V_drawString(v, mx - 102, 0, "SELECT", "FPIMP", V_SNAPTORIGHT|V_SNAPTOTOP, nil, 31, nil, FRACUNIT*75/100)

	local m = M_menus["mpselect_main"].mpselect_mainmenu

	-- draw the command help first:
	v.drawFill(oldtimer*96, 180, 999, 12, 31|V_SNAPTOBOTTOM|V_SNAPTOLEFT)

	-- draw the commands for it:
	for i = 1, #m.choices do
		V_drawString(v, mx - (124 + i*6), 40 + (i*20), m.choices[i][1], "FPIMP", V_SNAPTORIGHT, nil, 0, 31, FRACUNIT*80/100)
	end

	-- now draw our new menu~

	local nchoices = mo.m_dynchoices

	local dy = 92 - 16*(choice-1) --164
	local y = dy-16

	addy = $/2

	if not nchoices return end	-- wait a bit

	-- set addy thru some hack
	local inpt = mo.P_inputs
	local tchoice = choice	-- temp choice used for calc

	if inpt["up"] == 1
		--tchoice = $+1
		if tchoice == 1
			--addy = blocks*16
		else
			tchoice = $+1
			--addy = (84 + 16*(choice-1)) - (84 + 16*(tchoice-1))
		end

	elseif inpt["down"] == 1
		if tchoice == blocks
			--addy = -blocks*32
		else
			tchoice = $-1
			--addy = (32*(choice-1)) - (32*(tchoice-1))
		end
	end


	local t = (timers.sclosemenu and (TICRATE/3 - timers.sclosemenu) or timers.smenuopen or 0)

	--PDraw(v, 0, t*32, v.cachePatch("H_CHAL"), V_SNAPTOLEFT)
	--v.drawFill(43, 0, 2, 300 - t*32, 135|V_SNAPTOLEFT)

	-- draw the difficulties first:
	for i = 1, nchoices

		if dy < 36
			dy = $+16	-- skip drawing
			continue
		end

		local header = P_getCustomDungeon(i)
		if not header break end

		local color = choice == i and 135 or 31
		v.drawFill(97 + t*64, dy+addy, 999, 1, color|V_SNAPTORIGHT)
		v.drawFill(96 + t*64, dy+1+addy, 999, 1, color|V_SNAPTORIGHT)

		v.drawFill(96 + t*64, dy+14+addy, 999, 1, color|V_SNAPTORIGHT)	-- borders
		v.drawFill(97 + t*64, dy+15+addy, 999, 1, color|V_SNAPTORIGHT)

		V_drawString(v, 100 + t*64, dy+4+addy, header.name:upper(), "FPIMP", V_SNAPTORIGHT, nil, 0, 31)

		dy = $+16
	end

	-- info:
	local header = P_getCustomDungeon(choice)
	PDraw(v, t*32, 0, v.cachePatch("H_CINFO"), V_SNAPTORIGHT)
	V_drawString(v, 320 +t*32 - 8, 8, header.name:upper(), "FPIMP", V_SNAPTORIGHT, "right", 31, nil)

	V_drawString(v, 320 +t*32 - 8, 18, header.description, "NFNT", V_SNAPTORIGHT, "right", 31, nil)

	V_drawString(v, 320 - 220 +t*32, 42, "LEVEL", "FPIMP", V_SNAPTORIGHT, nil, 31, nil)
	V_drawString(v, 320 - 180 +t*32, 43, header.level, "NFNT", V_SNAPTORIGHT, nil, 31, nil)

	V_drawString(v, 320 - 150 +t*32, 42, "FLOORS", "FPIMP", V_SNAPTORIGHT, nil, 31, nil)
	V_drawString(v, 320 - 100 +t*32, 43, header.floors, "NFNT", V_SNAPTORIGHT, nil, 31, nil)

	-- difficulty
	local difficulty = header.gensize
	local sx = 320 - 50 + t*32

	for i = 1, 6
		local pname = "RSTAR1"

		if i > difficulty
			pname = "RSTAR0"
		end

		v.drawIndex(sx<<FRACBITS, 42<<FRACBITS, FRACUNIT/2, v.cachePatch(pname), V_SNAPTORIGHT, 31)
		sx = $+8
	end

	--V_drawString(v, 320 - 90 +t*32, 38, "SCORE", "FPIMP", V_SNAPTORIGHT, nil, 31, nil)
	--V_drawString(v, 320 - 93 +t*32, 46, "TARGET", "FPIMP", V_SNAPTORIGHT, nil, 31, nil)
	--V_drawString(v, 320 - 45 +t*32, 43, header.points, "NFNT", V_SNAPTORIGHT, nil, 31, nil)
end

local function drawMenu_void(v, mo, choice, forcetimer)

	-- reminder that this whole menu is kind of a hack

	--drawScreenwidePatch(v, v.cachePatch("H_RIP4"), nil, V_30TRANS)
	v.fadeScreen(31, 7)

	-- draw the old menu going away at the back
	local timers = mo.m_hudtimers
	local oldtimer = TICRATE/3 - (timers.sclosemenu and (TICRATE/3 - timers.sclosemenu) or timers.smenuopen or 0)

	local mx = 320
	if oldtimer
		mx = 320 + oldtimer*64
	end

	-- draw menu string or smth:
	v.drawFill(mx - 97, 0, 200, 12, 135|V_SNAPTOTOP|V_SNAPTORIGHT)
	V_drawString(v, mx - 102, 0, "SELECT", "FPIMP", V_SNAPTORIGHT|V_SNAPTOTOP, nil, 31, nil, FRACUNIT*75/100)

	local m = M_menus["mpselect_main"].mpselect_mainmenu

	-- draw the command help first:
	v.drawFill(oldtimer*96, 180, 999, 12, 31|V_SNAPTOBOTTOM|V_SNAPTOLEFT)

	-- draw the commands for it:
	for i = 1, #m.choices do
		V_drawString(v, mx - (124 + i*6), 40 + (i*20), m.choices[i][1], "FPIMP", V_SNAPTORIGHT, nil, 0, 31, FRACUNIT*80/100)
	end

	local m = M_menus["mpselect_main"].mpselect_void

	-- draw the commands for it:
	local y = 48
	local tmr = TICRATE/3 - oldtimer

	for i = 1, #m.choices do
		-- draw cursor:
		local color = i == choice and 135 or 31

		v.drawFill(40 + tmr*96, y, 999, 1, color|V_SNAPTORIGHT)
		v.drawFill(41 + tmr*96, y+1, 999, 1, color|V_SNAPTORIGHT)

		v.drawFill(41 + tmr*96, y+30, 999, 1, color|V_SNAPTORIGHT)	-- borders
		v.drawFill(40 + tmr*96, y+31, 999, 1, color|V_SNAPTORIGHT)

		V_drawString(v, 45 + tmr*96, y + 5, m.choices[i][1]:upper(), "FPIMP", V_SNAPTORIGHT, nil, 0, 31)
		V_drawString(v, 45 + tmr*96, y + 15, m.choices[i][2], "NFNT", V_SNAPTORIGHT, nil, 0, 31)

		y = $ + 32
	end

	-- draw voidrun thing
	PDraw(v, 320 - tmr*128, 0, v.cachePatch("H_VOIDR"), V_SNAPTOTOP|V_SNAPTORIGHT)
	v.drawFill(0, 19, oldtimer*128, 1, 135|V_SNAPTOTOP)

	-- Pain
	local txt = "What kind of suffering are you feeling like enduring today, mh?"
	R_drawTextBox(v, "Alt", txt, "H_ALT02", SKINCOLOR_BLUE, tmr, mo.m_voidtexttimer - tmr)
end



local function drawMenu_terminal(v, mo, choice, forcetimer)

	-- reminder that this whole menu is kind of a hack

	--drawScreenwidePatch(v, v.cachePatch("H_RIP4"), nil, V_30TRANS)
	v.fadeScreen(31, 7)

	-- draw the old menu going away at the back
	local timers = mo.m_hudtimers
	local oldtimer = TICRATE/3 - (timers.sclosemenu and (TICRATE/3 - timers.sclosemenu) or timers.smenuopen or 0)

	local mx = 320
	if oldtimer
		mx = 320 + oldtimer*64
	end

	-- draw menu string or smth:
	v.drawFill(mx - 97, 0, 200, 12, 135|V_SNAPTOTOP|V_SNAPTORIGHT)
	V_drawString(v, mx - 102, 0, "MARATHON", "FPIMP", V_SNAPTORIGHT|V_SNAPTOTOP, nil, 31, nil, FRACUNIT*75/100)

	local m = M_menus["mpselect_main"].mpselect_tartarus

	-- draw the command help first:
	v.drawFill(oldtimer*96, 180, 999, 12, 31|V_SNAPTOBOTTOM|V_SNAPTOLEFT)

	-- draw the commands for it:
	for i = 1, #m.choices do
		V_drawString(v, mx - (124 + i*6), 60 + (i*20), m.choices[i][1], "FPIMP", V_SNAPTORIGHT, nil, 0, 31, FRACUNIT*80/100)
	end

	-- now draw our new menu~

	local blocks = mo.m_dynchoices

	-- draw headers behind
	local headers = {
		[0] = {"ABSOLUTE BULLSHIT",		"Death."},	-- requires unlock from the host's end
		{"EASY", 						"What's a \'JRPG\'?"},
		{"NORMAL",						"'I played Pokemon before.'"},
		{"HARD", 						"Hurt me plenty"},
		{"VERY HARD",					"DK."},
		{"SPICY",						"Like yuri thighs!"},
		{"BULLSHIT",					"Easier than SMT3 still."}
	}

	local monad = (mo.player.unlocks and mo.player.unlocks[UNLOCK_B7]) and server.roguemode	-- monad unlocked?
	local minblock = not monad and 1 or 0

	local dy = 84 + 32*(choice-1) --164
	local y = dy-16

	addy = $/2

	if not blocks return end	-- wait a bit

	if not monad
		mo.m_menuchoices[mo.m_submenu] = max(1, $)	-- can happen if you use rogue mode and then go back to normal mode.
	end

	-- set addy thru some hack
	local inpt = mo.P_inputs
	local tchoice = choice	-- temp choice used for calc

	if inpt["up"] == 1
		--tchoice = $+1
		if tchoice == minblock
			addy = blocks*32
		else
			tchoice = $+1
			addy = (84 + 32*(choice-1)) - (84 + 32*(tchoice-1))
		end

	elseif inpt["down"] == 1
		if tchoice == blocks
			addy = -blocks*32
		else
			tchoice = $-1
			addy = (32*(choice-1)) - (32*(tchoice-1))
		end
	end


	local t = (timers.sclosemenu and (TICRATE/3 - timers.sclosemenu) or timers.smenuopen or 0)

	PDraw(v, 0, t*32, v.cachePatch("H_TERM"), V_SNAPTOLEFT)
	v.drawFill(43, 0, 2, 300 - t*32, 135|V_SNAPTOLEFT)

	if not minblock
		dy = $+32
	end	-- compensate.

	-- draw the difficulties first:
	for i = minblock, blocks
		local color = choice == i and 135 or 31
		v.drawFill(97 + t*64, dy+addy, 999, 1, color|V_SNAPTORIGHT)
		v.drawFill(96 + t*64, dy+1+addy, 999, 1, color|V_SNAPTORIGHT)

		v.drawFill(96 + t*64, dy+30+addy, 999, 1, color|V_SNAPTORIGHT)	-- borders
		v.drawFill(97 + t*64, dy+31+addy, 999, 1, color|V_SNAPTORIGHT)

		if headers[i]
			V_drawString(v, 100 + t*64, dy+4+addy, headers[i][1], "FPIMP", V_SNAPTORIGHT, nil, 0, 31)
			V_drawString(v, 100 + t*64, dy+16+addy, headers[i][2], "NFNT", V_SNAPTORIGHT, nil, 0, 31)
		end
		dy = $-32
	end

	local tx = 210 + t*32

	drawTartarusBlocks(v, tx, y+addy, blocks)
end

local function drawMenu_main(v, mo, choice, forcetimer)
	local timers = mo.m_hudtimers
	local timer = timers.sclosemenu and (TICRATE/3 - timers.sclosemenu) or timers.smenuopen or 0

	--if timers.sclosemenu
	--	timers.sclosemenu = 0	-- nope~
	--end

	local fade = V_50TRANS
	if timer
		fade = V_90TRANS - ((8 - timer)/2)*V_10TRANS
	end
	--drawScreenwidePatch(v, v.cachePatch("H_RIP4"), nil, V_30TRANS)
	v.fadeScreen(31, 7)

	-- main
	local mx = 320
	if timer
		mx = 320 + timer*64
	end
	PDraw(v, mx, 200, v.cachePatch("M_BG1"), V_SNAPTORIGHT|V_SNAPTOBOTTOM)

	-- draw menu string or smth:
	v.drawFill(mx - 97, 0, 200, 12, 135|V_SNAPTOTOP|V_SNAPTORIGHT)
	V_drawString(v, mx - 102, 0, "SELECT", "FPIMP", V_SNAPTORIGHT|V_SNAPTOTOP, nil, 31, nil, FRACUNIT*75/100)

	local m = M_menus["mpselect_main"].mpselect_mainmenu

	-- draw the command help first:
	v.drawFill(0, 180, 999, 12, 31|V_SNAPTOBOTTOM|V_SNAPTOLEFT)
	V_drawString(v, 12, 182, m.choices[choice][2], "NFNT", V_SNAPTORIGHT|V_SNAPTOBOTTOM, nil, 0, nil)

	-- draw the commands for it:
	for i = 1, #m.choices do
		-- draw cursor:
		if i == choice
			PDraw(v, mx - (130 + i*6), 36 + (i*20), v.cachePatch("M_CURS1"), V_SNAPTORIGHT)
		end
		V_drawString(v, mx - (124 + i*6), 40 + (i*20), m.choices[i][1], "FPIMP", V_SNAPTORIGHT, nil, 0, 31, FRACUNIT*80/100)
	end
end

local function drawMenu_tartarus_marathonselect(v, mo, choice, forcetimer)
	local timers = mo.m_hudtimers
	local timer = timers.sclosemenu and (TICRATE/3 - timers.sclosemenu) or timers.smenuopen or 0

	local fade = V_50TRANS
	if timer
		fade = V_90TRANS - ((8 - timer)/2)*V_10TRANS
	end
	--drawScreenwidePatch(v, v.cachePatch("H_RIP4"), nil, V_30TRANS)
	v.fadeScreen(31, 7)

	-- OLD MENU DRAWER
	if 1	-- < i know this is stupid but at least it's more organized :)
		local oldtimer = TICRATE/3 - (timers.sclosemenu and (TICRATE/3 - timers.sclosemenu) or timers.smenuopen or 0)

		local mx = 320
		if oldtimer
			mx = 320 + oldtimer*64
		end

		-- draw menu string or smth:
		v.drawFill(mx - 97, 0, 200, 12, 135|V_SNAPTOTOP|V_SNAPTORIGHT)
		V_drawString(v, mx - 102, 0, "MARATHON", "FPIMP", V_SNAPTORIGHT|V_SNAPTOTOP, nil, 31, nil, FRACUNIT*75/100)

		local m = M_menus["mpselect_main"].mpselect_tartarus

		-- draw the command help first:
		v.drawFill(oldtimer*96, 180, 999, 12, 31|V_SNAPTOBOTTOM|V_SNAPTOLEFT)

		-- draw the commands for it:
		for i = 1, #m.choices do
			V_drawString(v, mx - (124 + i*6), 60 + (i*20), m.choices[i][1], "FPIMP", V_SNAPTORIGHT, nil, 0, 31, FRACUNIT*80/100)
		end
	end

	-- main
	local mx = 320
	if timer
		mx = 320 + timer*64
	end
	PDraw(v, mx, 200, v.cachePatch("M_BG1"), V_SNAPTORIGHT|V_SNAPTOBOTTOM)

	-- draw menu string or smth:
	v.drawFill(mx - 97, 0, 200, 12, 135|V_SNAPTOTOP|V_SNAPTORIGHT)
	V_drawString(v, mx - 102, 0, "TARTARUS", "FPIMP", V_SNAPTORIGHT|V_SNAPTOTOP, nil, 31, nil, FRACUNIT*75/100)

	local m = M_menus["mpselect_main"].mpselect_marathon

	-- draw the command help first:
	v.drawFill(0, 180, 999, 12, 31|V_SNAPTOBOTTOM|V_SNAPTOLEFT)
	V_drawString(v, 12, 182, m.choices[choice][2], "NFNT", V_SNAPTORIGHT|V_SNAPTOBOTTOM, nil, 0, nil)

	-- draw the commands for it:
	for i = 1, #m.choices do
		-- draw cursor:
		if i == choice
			PDraw(v, mx - (130 + i*6), 56 + (i*20), v.cachePatch("M_CURS1"), V_SNAPTORIGHT)
		end
		V_drawString(v, mx - (124 + i*6), 60 + (i*20), m.choices[i][1], "FPIMP", V_SNAPTORIGHT, nil, 0, 31, FRACUNIT*80/100)
	end
end

local function drawMenu_tartarus_modeselect(v, mo, choice, forcetimer)
	local timers = mo.m_hudtimers
	local timer = timers.sclosemenu and (TICRATE/3 - timers.sclosemenu) or timers.smenuopen or 0

	local fade = V_50TRANS
	if timer
		fade = V_90TRANS - ((8 - timer)/2)*V_10TRANS
	end
	--drawScreenwidePatch(v, v.cachePatch("H_RIP4"), nil, V_30TRANS)
	v.fadeScreen(31, 7)

	-- OLD MENU DRAWER
	if 1	-- < i know this is stupid but at least it's more organized :)
		local oldtimer = TICRATE/3 - (timers.sclosemenu and (TICRATE/3 - timers.sclosemenu) or timers.smenuopen or 0)

		local mx = 320
		if oldtimer
			mx = 320 + oldtimer*64
		end

		-- draw menu string or smth:
		v.drawFill(mx - 97, 0, 200, 12, 135|V_SNAPTOTOP|V_SNAPTORIGHT)
		V_drawString(v, mx - 102, 0, "SELECT", "FPIMP", V_SNAPTORIGHT|V_SNAPTOTOP, nil, 31, nil, FRACUNIT*75/100)

		local m = M_menus["mpselect_main"].mpselect_mainmenu

		-- draw the command help first:
		v.drawFill(oldtimer*96, 180, 999, 12, 31|V_SNAPTOBOTTOM|V_SNAPTOLEFT)

		-- draw the commands for it:
		for i = 1, #m.choices do
			V_drawString(v, mx - (124 + i*6), 40 + (i*20), m.choices[i][1], "FPIMP", V_SNAPTORIGHT, nil, 0, 31, FRACUNIT*80/100)
		end
	end

	-- main
	local mx = 320
	if timer
		mx = 320 + timer*64
	end
	PDraw(v, mx, 200, v.cachePatch("M_BG1"), V_SNAPTORIGHT|V_SNAPTOBOTTOM)

	-- draw menu string or smth:
	v.drawFill(mx - 97, 0, 200, 12, 135|V_SNAPTOTOP|V_SNAPTORIGHT)
	V_drawString(v, mx - 102, 0, "TARTARUS", "FPIMP", V_SNAPTORIGHT|V_SNAPTOTOP, nil, 31, nil, FRACUNIT*75/100)

	local m = M_menus["mpselect_main"].mpselect_tartarus

	-- draw the command help first:
	v.drawFill(0, 180, 999, 12, 31|V_SNAPTOBOTTOM|V_SNAPTOLEFT)
	V_drawString(v, 12, 182, m.choices[choice][2], "NFNT", V_SNAPTORIGHT|V_SNAPTOBOTTOM, nil, 0, nil)

	-- draw the commands for it:
	for i = 1, #m.choices do
		-- draw cursor:
		if i == choice
			PDraw(v, mx - (130 + i*6), 56 + (i*20), v.cachePatch("M_CURS1"), V_SNAPTORIGHT)
		end
		V_drawString(v, mx - (124 + i*6), 60 + (i*20), m.choices[i][1], "FPIMP", V_SNAPTORIGHT, nil, 0, 31, FRACUNIT*80/100)
	end
end

local function drawMenu_coloseo(v, mo, choice, forcetimer)
	local timers = mo.m_hudtimers
	local timer = timers.sclosemenu and (TICRATE/3 - timers.sclosemenu) or timers.smenuopen or 0

	local fade = V_50TRANS
	if timer
		fade = V_90TRANS - ((8 - timer)/2)*V_10TRANS
	end
	--drawScreenwidePatch(v, v.cachePatch("H_RIP4"), nil, V_30TRANS)
	v.fadeScreen(31, 7)

	-- OLD MENU DRAWER
	if 1	-- < i know this is stupid but at least it's more organized :)
		local oldtimer = TICRATE/3 - (timers.sclosemenu and (TICRATE/3 - timers.sclosemenu) or timers.smenuopen or 0)

		local mx = 320
		if oldtimer
			mx = 320 + oldtimer*64
		end

		-- draw menu string or smth:
		v.drawFill(mx - 97, 0, 200, 12, 135|V_SNAPTOTOP|V_SNAPTORIGHT)
		V_drawString(v, mx - 102, 0, "SELECT", "FPIMP", V_SNAPTORIGHT|V_SNAPTOTOP, nil, 31, nil, FRACUNIT*75/100)

		local m = M_menus["mpselect_main"].mpselect_mainmenu

		-- draw the command help first:
		v.drawFill(oldtimer*96, 180, 999, 12, 31|V_SNAPTOBOTTOM|V_SNAPTOLEFT)

		-- draw the commands for it:
		for i = 1, #m.choices do
			V_drawString(v, mx - (124 + i*6), 40 + (i*20), m.choices[i][1], "FPIMP", V_SNAPTORIGHT, nil, 0, 31, FRACUNIT*80/100)
		end
	end

	-- main
	local mx = 320
	if timer
		mx = 320 + timer*64
	end
	PDraw(v, mx, 200, v.cachePatch("M_BG1"), V_SNAPTORIGHT|V_SNAPTOBOTTOM)

	-- draw menu string or smth:
	v.drawFill(mx - 97, 0, 200, 12, 135|V_SNAPTOTOP|V_SNAPTORIGHT)
	V_drawString(v, mx - 102, 0, "COLOSEO", "FPIMP", V_SNAPTORIGHT|V_SNAPTOTOP, nil, 31, nil, FRACUNIT*75/100)

	local m = M_menus["mpselect_main"].mpselect_coloseo

	-- draw the command help first:
	v.drawFill(0, 180, 999, 12, 31|V_SNAPTOBOTTOM|V_SNAPTOLEFT)
	V_drawString(v, 12, 182, m.choices[choice][2], "NFNT", V_SNAPTORIGHT|V_SNAPTOBOTTOM, nil, 0, nil)

	-- draw the commands for it:
	for i = 1, #m.choices do
		-- draw cursor:
		if i == choice
			PDraw(v, mx - (130 + i*6), 56 + (i*20), v.cachePatch("M_CURS1"), V_SNAPTORIGHT)
		end
		V_drawString(v, mx - (124 + i*6), 60 + (i*20), m.choices[i][1], "FPIMP", V_SNAPTORIGHT, nil, 0, 31, FRACUNIT*80/100)
	end
end

local function drawqLoadFiles(v, mo, choice, forcetimer)

	local timers = mo.m_hudtimers
	local timer = timers.sclosemenu and ((TICRATE*2/3) - timers.sclosemenu) or timers.smenuopen or 0
	local fwtimer = (TICRATE*2/3) - timer

	v.fadeScreen(31, 7)

	-- OLD MENU DRAWER
	if 1	-- < i know this is stupid but at least it's more organized :)
		local oldtimer = (TICRATE*2/3) - (timers.sclosemenu and ((TICRATE*2/3) - timers.sclosemenu) or timers.smenuopen or 0)

		local mx = 320
		if oldtimer
			mx = 320 + oldtimer*64
		end

		-- draw menu string or smth:
		v.drawFill(mx - 97, 0, 200, 12, 135|V_SNAPTOTOP|V_SNAPTORIGHT)
		V_drawString(v, mx - 102, 0, "MARATHON", "FPIMP", V_SNAPTORIGHT|V_SNAPTOTOP, nil, 31, nil, FRACUNIT*75/100)

		local m = M_menus["mpselect_main"].mpselect_marathon

		-- draw the command help first:
		v.drawFill(oldtimer*96, 180, 999, 12, 31|V_SNAPTOBOTTOM|V_SNAPTOLEFT)

		-- draw the commands for it:
		for i = 1, #m.choices do
			V_drawString(v, mx - (124 + i*6), 60 + (i*20), m.choices[i][1], "FPIMP", V_SNAPTORIGHT, nil, 0, 31, FRACUNIT*80/100)
		end
	end

	-- kool visual!!!!
	PDraw(v, 0, timer*48, v.cachePatch("M_LOAD"), V_SNAPTOLEFT)
	v.drawFill(64, 0, 1, fwtimer*48, 135|V_SNAPTOLEFT|V_SNAPTOTOP)

	local y = 24

	for i = 1, MAXQSAVEFILES do
		local t = max(0, timer - (MAXQSAVEFILES-(i-1))*2)
		local startx = 80 + (64*t)
		local skinx = startx + 40	--120
		local h = srb2p.fileheaders[i]
		local invalid

		local headertext = "FILE"..i
		if mo.m_selectfile and choice == i
			headertext = "CONFIRM AGAIN TO LOAD"
		end

		V_drawString(v, startx, y, headertext, "FPIMP", 0, nil, 0, 31)
		local txt = h and h.text or "EMPTY"
		-- iterate skins first

		V_drawString(v, startx, y+12, txt, "NFNT", 0, nil, 0, 31)
		-- draw characters:
		if h and not (choice == i and mo.m_selectfile) and h.playerlist and #h.playerlist
			for i = 1, #h.playerlist
				for j = 1, #h.playerlist[i]
					local skin = h.playerlist[i][j].skin

					local stats = charStats[skin] or charStats["sonic"]	-- whatever lmfao
					local pp = v.cachePatch(stats.icon or "ICO_SONI")
					local color
					if skins[skin]
						color = skins[skin].prefcolor
					end

					PDraw(v, skinx, y+1, pp, 0, v.getColormap(TC_DEFAULT, color))
					skinx = $+10
				end
				skinx = $+6
			end
		end

		local colour = 31
		if choice == i and not (mo.m_selectfile and leveltime & 1)
			colour = 135
		end

		v.drawFill(startx-5, y-4, 999, 1, colour)
		v.drawFill(startx-4, y-3, 999, 1, colour)

		v.drawFill(startx-5, y+22, 999, 1, colour)
		v.drawFill(startx-4, y+21, 999, 1, colour)

		y = $+27
	end


	if (mo.m_invalidskins and #mo.m_invalidskins) or mo.m_invalidfile or mo.m_toomanyplayers
		v.fadeScreen(31, 7)
		v.drawFill(0, 80, 999, 40, 135|V_SNAPTOLEFT)
		V_drawString(v, 160, 85, "\x82".."Couldn't load the save file", "NFNT", 0, "center", 0, 31)

		if mo.m_invalidfile
			V_drawString(v, 160, 95, "Save version differs, or the file is corrupt or empty.", "NFNT", 0, "center", 0, 31)
		elseif mo.m_toomanyplayers
			V_drawString(v, 160, 95, "There are too many players.", "NFNT", 0, "center", 0, 31)
		elseif #mo.m_invalidskins
			local str = "Skins missing: "
			for i = 1, #mo.m_invalidskins do
				str = $..mo.m_invalidskins[i]
				if i < #mo.m_invalidskins
					str = $..", "
				end
			end
			V_drawString(v, 160, 95, str, "NFNT", 0, "center", 0, 31)
		end

		V_drawString(v, 160, 105, "(Press A to abort)", "NFNT", 0, "center", 0, 31)
	end
end

-- initiate main pause menu:
M_menus["mpselect_main"] = {

	m_start_at = "mpselect_mainmenu",	-- where the menu starts
	openfunc = function(mo)	-- play a sound when we open the menu:
		S_StartSound(nil, sfx_select, mo.player)
		server.marathon = nil
		server.roguemode = nil
		server.negociationmode = nil
		server.netgamefile = nil
		server.bossmode = nil
		server.cdungeon = nil

	end,

	mpselect_cdungeon = {
		opentimer = TICRATE/3,
		closetimer = TICRATE/3,
		hoversound = sfx_hover,
		confirmsound = sfx_confir,
		dynchoices = true,
		prev = "mpselect_mainmenu",
		drawer = drawMenu_customDungeons,

		confirmfunc = function(mo)
							mo.P_inputs[BT_JUMP] = 2	-- skip input
							server.cdungeon = P_getCustomDungeon(mo.m_menuchoices[mo.m_submenu])
							if not server.cdungeon
								return	-- ?????
							end

							NET_begin()
							server.P_netstat.buffer = {
								map = srb2p.customdungeon_map,
								gamemode = GM_COOP,
								extradata = 1,
								maxparties = 4,
							}
							M_closeMenu(mo)
		end,


	},

	mpselect_mainmenu = {
		opentimer = TICRATE/3,
		closetimer = TICRATE/3,
		hoversound = sfx_hover,
		confirmsound = sfx_confir,

		-- choices: mostly used for the input handler. The drawer might not need it.
		choices = {
			-- syntax: {name, description, nextmenu}
			{"TARTARUS", "Explore Tartarus with your team!",	"mpselect_tartarus"},
			{"VOID RUN", "Take on tough challenges, starting from nothing!",	"mpselect_void"},
			{"VISION QUEST", "Face off against strong bosses in a timed battle!", "mpselect_challenge"},
			{"COLISEUM", "Fight it out with your friends and see who's the best!", "mpselect_coloseo"},
			{"CUSTOM", "Explore custom-made dungeons by loading files!", "mpselect_cdungeon"},
		},
		-- drawer to run continuously whilst this menu is opened

		drawer = drawMenu_main,

		confirmfunc = 		function(mo)
								mo.m_voidtexttimer = 0
								--mo.m_voidtextboxtimer = TICRATE/2

								-- custom dungeons: check if we have any of those little shits loaded
								if mo.m_menuchoices[mo.m_submenu] == 5
									if not P_getCustomDungeon(1)	-- no dungeon
										S_StartSound(nil, sfx_not, mo.player)
										return true
									end
								end

								-- count custom battles:
								mo.m_dynchoices = 0
								local i = 1
								while P_getCustomDungeon(i)
									mo.m_dynchoices = i
									i = $+1
								end

							end,
	},

	mpselect_coloseo = {
		opentimer = TICRATE/3,
		closetimer = TICRATE/3,
		hoversound = sfx_hover,
		confirmsound = sfx_confir,
		prev = "mpselect_mainmenu",

		-- choices: mostly used for the input handler. The drawer might not need it.
		choices = {
			-- syntax: {name, description, nextmenu}
			{"PURGATORIO", "A 4V4 duke-out!", ""},
			{"BOSS MODE", "One versus all! The Boss player gets to control a boss shadow!", ""},
			{"RAND SKILLS", "You'll get a set of 8 random skills, and a random melee attack.", ""},
		},

		confirmfunc = 	function(mo)
			local count = 0
			for p in players.iterate do
				count = $+1
			end
			if count < 2
			or count > 8
			or (mo.m_menuchoices[mo.m_submenu] == 2 and count > 5)	-- boss mode is 5 players max
				S_StartSound(nil, sfx_not, mo.player)
				return true
			end

			mo.P_inputs[BT_JUMP] = 2	-- skip inpt

			server.bossmode = mo.m_menuchoices[mo.m_submenu] == 2

			NET_begin()
			server.P_netstat.buffer = {
				map = srb2p.colosseo_map,
				gamemode = GM_PVP,
				extradata = mo.m_menuchoices[mo.m_submenu],
				maxparties = 2,
				minparties = 2,
			}
			M_closeMenu(mo)

			--server.bossmode = nil
			return true
		end,

		-- drawer to run continuously whilst this menu is opened
		drawer = drawMenu_coloseo,

	},

	mpselect_void = {
		opentimer = TICRATE/3,
		closetimer = TICRATE/3,
		hoversound = sfx_hover,
		confirmsound = sfx_confir,
		prev = "mpselect_mainmenu",

		-- choices: mostly used for the input handler. The drawer might not need it.
		choices = {
			-- syntax: {name, description, nextmenu}
			{"Team Directives", "Take on a regular Void Run with up to 4 players.", "mpselect_terminal"},
			--{"Solo Directives", "Take on a special kind of Void Run by yourself.", "mpselect_terminal"},
		},

		confirmfunc = 	function(mo)
							-- check for rogue mode:
							server.negociationmode = (mo.m_menuchoices[mo.m_submenu] == 2)

							-- open net menu and close menu;
							mo.P_inputs[BT_JUMP] = 2	-- skip input
							NET_begin()
							server.P_netstat.buffer = {
								map = srb2p.challenge_map,
								gamemode = GM_VOIDRUN,
								extradata = server.negociationmode,
								maxparties = 1,
							}
							M_closeMenu(mo)

						end,

		-- drawer to run continuously whilst this menu is opened
		drawer = drawMenu_void,
		runfunc = 		function(mo)
							mo.m_voidtexttimer = $ and $+1 or 1
							--mo.m_voidtextboxtimer = $ and $-1 or 0
						end,
	},

	mpselect_tartarus = {
		opentimer = TICRATE/3,
		closetimer = TICRATE/3,
		hoversound = sfx_hover,
		confirmsound = sfx_confir,
		prev = "mpselect_mainmenu",

		-- choices: mostly used for the input handler. The drawer might not need it.
		choices = {
			-- syntax: {name, description, nextmenu}
			{"EXPLORATION", "Explore Tartarus with up to 4 teams of 4!", "mpselect_terminal"},
			{"ROGUE MODE", "Randomized enemies, and a less forgiving difficulty level!", "mpselect_terminal"},
			{"MARATHON", "Go through the entirety of Tartarus. Rogue only!", "mpselect_marathon"},
		},

		confirmfunc = 	function(mo)
							-- check for rogue mode:
							server.roguemode = mo.m_menuchoices[mo.m_submenu] >= 2
							server.marathon = mo.m_menuchoices[mo.m_submenu] == 3

							/*if server.marathon
								mo.P_inputs[BT_JUMP] = 2	-- skip input
								NET_begin()
								server.P_netstat.buffer = {
									map = srb2p.tartarus_play,
									gamemode = GM_COOP,
									extradata = 1,
									maxparties = 4,
								}
								M_closeMenu(mo)
							end*/
						end,

		-- drawer to run continuously whilst this menu is opened
		drawer = drawMenu_tartarus_modeselect,
	},

	mpselect_marathon = {
		opentimer = TICRATE/3,
		closetimer = TICRATE/3,
		hoversound = sfx_hover,
		confirmsound = sfx_confir,
		prev = "mpselect_tartarus",

		-- choices: mostly used for the input handler. The drawer might not need it.
		choices = {
			-- syntax: {name, description, nextmenu}
			{"NEW GAME", "Start a new Marathon run.", "mpselect_terminal"},
			{"LOAD FILE", "Load a saved Marathon run.", "qload_main"},
		},

		confirmfunc = 	function(mo)
							-- if you select the first option, instantly start the net status

							if mo.m_menuchoices[mo.m_submenu] == 1
								mo.P_inputs[BT_JUMP] = 2	-- skip input
								NET_begin()
								server.P_netstat.buffer = {
									map = srb2p.tartarus_play,
									gamemode = GM_COOP,
									extradata = 1,
									maxparties = 4,
								}
								M_closeMenu(mo)
							else	-- otherwise, we're checking save files
								-- ready the file headers
								srb2p.fileheaders = SAVE_GetQFilesHeaders()
							end
						end,

		-- drawer to run continuously whilst this menu is opened
		drawer = drawMenu_tartarus_marathonselect,
	},

	mpselect_challenge = {

		opentimer = TICRATE/3,
		closetimer = TICRATE/3,
		drawer = drawMenu_challenge,
		dynchoices = true,
		--invert = true,
		runfunc = 	function(mo)
						-- count # of dynchoices:

						mo.challengebattles = {}
						-- Dynamically check for challenge battles.

						local c = 0
						for i = 1, #BTL_challengebtllist
							if BTL_challengebtllist[i].unlock

								-- check if we have that unlock...
								if not mo.player.unlocks or not mo.player.unlocks[BTL_challengebtllist[i].unlock]
									continue	-- bye
								end
							end
							mo.challengebattles[#mo.challengebattles+1] = {BTL_challengebtllist[i], i}
							-- [challenge ref, challenge index]
						end
						mo.m_dynchoices = #mo.challengebattles
					end,

		hoversound = sfx_hover,
		confirmsound = sfx_confir,

		prev = "mpselect_mainmenu",

		confirmfunc = 	function(mo)
							-- open net menu and close menu;
							mo.P_inputs[BT_JUMP] = 2	-- skip input
							NET_begin()
							server.P_netstat.buffer = {
								map = srb2p.colosseo_map,
								gamemode = GM_CHALLENGE,
								extradata = mo.challengebattles[mo.m_menuchoices[mo.m_submenu]][2],	-- challenge index
								maxparties = 1,
								nostack = 1,	-- No stacking!!
							}
							M_closeMenu(mo)
						end,
	},

	mpselect_terminal = {

		opentimer = TICRATE/3,
		closetimer = TICRATE/3,
		drawer = drawMenu_terminal,
		dynchoices = true,
		invert = true,
		runfunc = 	function(mo)
						mo.m_dynchoices = 6	--cv_bean.value and 6 or 5	-- @TODO: maybe make this depend on some factors
						mo.m_minchoice = 1

						-- @TODO: Make Blocks 5~6 unlockables in the future?

						if mo.player.unlocks and mo.player.unlocks[UNLOCK_B7] and server.roguemode
							mo.m_minchoice = 0
						end
					end,
		hoversound = sfx_hover,
		confirmsound = sfx_confir,

		prev = "mpselect_tartarus",

		confirmfunc = 	function(mo)
							-- open net menu and close menu;
							mo.P_inputs[BT_JUMP] = 2	-- skip input
							NET_begin()
							server.P_netstat.buffer = {
								map = srb2p.tartarus_play,
								gamemode = GM_COOP,
								extradata = (mo.m_menuchoices[mo.m_submenu] or 7),	-- special case: monad is difficulty 7
								maxparties = 4,
							}
							M_closeMenu(mo)
						end,
	},

	qload_main = {
		opentimer = TICRATE*2/3,
		closetimer = TICRATE*2/3,
		hoversound = sfx_hover,
		confirmsound = sfx_confir,
		prev = "mpselect_marathon",

		-- choices: mostly used for the input handler. The drawer might not need it.
		choices = files,
		-- drawer to run continuously whilst this menu is opened

		drawer = drawqLoadFiles,

		openfunc =			function(mo)
								mo.m_waitforfile = nil	-- make sure we don't keep that somehow
							end,

		runfunc =			function(mo)

								local inpts = mo.P_inputs

								if server.netgamefile ~= nil
									mo.m_waitforfile = nil
									-- check netgame file:
									mo.m_invalidfile = (server.netgamefile == false)
									mo.m_invalidskins = {}
									-- count players
									local nump = 0
									for p in players.iterate do
										nump =$+1
									end
									local initialnump = nump


									-- check skins
									if not mo.m_invalidfile and server.netgamefile.playerlist
										for i = 1, #server.netgamefile.playerlist
											for j = 1, #server.netgamefile.playerlist[i]
												nump = $-1
												if not skins[server.netgamefile.playerlist[i][j].skin]
													mo.m_invalidskins[#mo.m_invalidskins+1] = server.netgamefile.playerlist[i][j].skin
												end
											end
										end
									end

									mo.m_toomanyplayers = nump > 0

									-- if nothing's wrong, move to next menu index!
									if not mo.m_invalidfile and not #mo.m_invalidskins and not mo.m_toomanyplayers
										mo.P_inputs[BT_JUMP] = 2	-- skip inpt
										NET_begin(NET_LOAD)
										server.P_netstat.buffer = {
											map = srb2p.tartarus_play,
											gamemode = GM_COOP,
											load = true,	-- tell the game we're gonna be loading skins
											extradata = 1,	-- by default, do normal difficulty
											maxparties = max(1, nump/4),
										}
										M_closeMenu(mo)
										return
									end

									if inpts[BT_BTNA] == 1
										server.netgamefile = nil
										mo.m_invalidfile = nil
										mo.m_invalidskins = nil
										mo.m_toomanyplayers = nil
									end


									return true
								end

								-- don't do anything while we wait for the file to load
								if mo.m_waitforfile
									return true
								end

								if mo.m_selectfile
									if inpts[BT_SPIN] == 1
										S_StartSound(nil, sfx_cancel, mo.player)
										mo.m_selectfile = nil
									elseif inpts[BT_JUMP] == 1
										mo.m_selectfile = nil

										-- make sure this only happens for the game client,
										-- we wouldn't want everyone's games to be saved...
										SAVE_getNetgameFileHeader(mo.m_menuchoices[mo.m_submenu])
										mo.m_waitforfile = true
									end
									-- don't allow normal menu operation
									return true
								end
							end,

		confirmfunc = 		function(mo)
								mo.m_selectfile = true
							end,
	},

}