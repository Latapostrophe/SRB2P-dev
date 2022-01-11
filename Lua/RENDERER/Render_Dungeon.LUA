-- dungeon HUD rendering

local cv_showreapertimer = CV_RegisterVar({
  name = "d_showreapertimer",
  defaultvalue = "On",
  PossibleValue = CV_OnOff,
})

-- draws the tartarus block selection.
-- numblocks is how many blocks are to be displayed (min 1)

rawset(_G, "drawTartarusBlocks", function(v, x, y, numblocks)
	local dy = tonumber(y) or 150
	x = tonumber($) or 210
	numblocks = tonumber($)
	if not numblocks or numblocks < 0 return end

	for i = 1, 6 do
		-- due to the size of these graphics we will draw them at 1/2 * 8/10 = 8/20 size
		PDraw(v, x, dy, v.cachePatch("H_TART"..i), V_SNAPTORIGHT)
		if i > numblocks
			v.drawIndex(x*FRACUNIT, dy*FRACUNIT, FRACUNIT/2, v.cachePatch("H_TART"..i), V_SNAPTORIGHT|V_20TRANS, 31)
		end
		dy = $-32
	end
end)

-- reminder:
-- LUA.dungeon means that we are inside of a dungeon, the minimap is displayed in this case.

rawset(_G, "renderPartyBars", function(v, p)
	local team = server.plentities[p.P_party]	-- this table never changes. ever.

	local i = #team
	local x = 320
	while i	-- iterate backwards to draw bars



		x = $ - (i==#team and 35 or 30)
		drawPlayerBarSmall(v, x, 180, team[i])
		i = $-1
	end
end)

local menuopt_main = {
	"SKILL",
	"ITEM",
	"PERSONA",
	"PARTY",
	"SOCIAL LINKS",
	"SYSTEM"
}

-- draw the main pause menu
local function h(v, p)
	-- draw background glass
	local mo = p.mo
	local timers = p.mo.d_hudtimers


	local fade = V_50TRANS
	if timers.menuopen
		fade = V_90TRANS - ((8 - timers.menuopen)/2)*V_10TRANS
	end
	v.drawScaled(160<<FRACBITS, 100<<FRACBITS, t*FRACUNIT/2, v.cachePatch("H_1M_B"), fade)

	-- main
	local mx = 320
	if timers.menuopen
		mx = 320 + timers.menuopen*64
	end
	PDraw(v, mx, 200, v.cachePatch("M_BG1"), V_SNAPTORIGHT|V_SNAPTOBOTTOM)

	-- draw the commands for it:
	for i = 1, #menuopt_main do
		V_drawString(v, mx - (110 + i*6), 20 + (i*20), menuopt_main[i], "FPIMP", V_SNAPTORIGHT, nil, 0, 31, FRACUNIT*80/100)
	end
end

-- dungeon log
local DNG_log = {}
rawset(_G, "DNG_logMessage", function(msg)
	DNG_log[#DNG_log+1] = {msg, 6*TICRATE}
end)
local r_y = 0	-- y shift when messages get deleted

local function renderLog(v, by)

	local size = FRACUNIT/2
	local addy = 10
	if v.width() >= 1280 and v.height() >= 768
		size = FRACUNIT/3
		addy = 6
		by = $+4
	end

	for i = #DNG_log, 1, -1 do
		local m = DNG_log[i]
		V_drawString(v, 318, by - addy*(i-1) + r_y, m[1], "NFNT", V_SNAPTORIGHT, "right", 0, 31, size)
		if not server.entrytime
			m[2] = $-1
		end			-- don't remove time during entry cards
		if not m[2]
			r_y = $-addy
			table.remove(DNG_log, i)
			continue
		end
	end
	r_y = $/2
end

local n2color = {
	[T_EMPTY] = 1,			-- walkable
	[T_ITEM] = 65,			-- item
	[T_ENEMY] = 1,			-- enemy
	[T_START] = 1,			-- player spawn
	[T_EXIT] = 105,			-- stairs
	[T_PIT] = 31,			-- pit
	[T_SPIKES] = 31,		-- spike pit (monad)
	[T_FLOORSPIKES] = 10,	-- spikes
}

local gridsize = 2	-- grid size in map units
local size_x, size_y = 48, 48

local function R_table2coords(i)
	return i-1 - ((i-1) / size_x) * size_x, (i-1) / size_x
end

local function renderMiniMap(v, p)

	if DNG_isTartarusMap()
	and server.map and server.fastmap

		PDraw(v, 200, 70, v.cachePatch("H_MAPBG"), V_50TRANS|V_SNAPTOBOTTOM|V_SNAPTORIGHT)

		if server.cdungeon
			local str = server.cdungeon.name
			str = $..", "..server.P_DungeonStatus.floor.."F"
			V_drawString(v, 320-8, 160, str, "NFNT", V_SNAPTOBOTTOM|V_SNAPTORIGHT, "right", 0, 31)

		elseif mapheaderinfo[gamemap].tartarus
			local block = DNG_returnBlock(server.P_DungeonStatus.floor)
			local blockname = blocknames[block]
			local flr = server.P_DungeonStatus.floor
			local prefix = ""
			if flr > FRACUNIT-1
				flr = $-(FRACUNIT-1)
				prefix = "B"
			end

			V_drawString(v, 320-8, 160, "Tartarus, "..blockname.." "..prefix..flr.."F", "NFNT", V_SNAPTOBOTTOM|V_SNAPTORIGHT, "right", 0, 31)

		/*elseif server.gamemode == GM_VOIDRUN	-- special case, bit hacky but who caresss
			local flr = server.P_DungeonStatus.floor or 0
			V_drawString(v, 320-8, 160, "Velvet Complex, Challenge "..flr, "NFNT", V_SNAPTOBOTTOM|V_SNAPTORIGHT, "right", 0, 31)*/
		elseif server.gamemode == GM_VOIDRUN
			local ch = server.P_DungeonStatus.VR_challenge or 1
			local challenge = (ch /3) + 1
			local mission = ch%3 or 3
			local str = "Void Run - "

			if mission%3 == 0
				challenge = $-1
			end

			if server.P_DungeonStatus.VR_timer == nil
				str = $..(challenge == 1 and "Starting Area" or "Safe Zone")
			else
				str = $..("C "..challenge.."-"..mission)
			end

			V_drawString(v, 320-8, 160, str, "NFNT", V_SNAPTOBOTTOM|V_SNAPTORIGHT, "right", 0, 31)

		end


		-- cache player positions first:
		local playerpos = {}
		playerpos[1] = -1	-- just to be safe
		local index = 1

		if leveltime%10 < 5
			for p2 in players.iterate do
				local mo = p2.mo
				if not mo or not mo.valid continue end
				if p2.P_party ~= p.P_party continue end
				if p2 == p continue end

				playerpos[index] = #mo.subsector.sector+1
				index = $+1
			end
		end

		local mypos
		if p and p.mo and p.mo.valid
		and leveltime%10 < 5
			mypos = #p.mo.subsector.sector+1
		end

		local reaperpos
		if server.reaper and server.reaper.valid
		and leveltime%10 < 5
			reaperpos = #server.reaper.subsector.sector+1
		end

		-- now, sort positions from lowest to highest
		table.sort(playerpos, function(a, b) return a < b end)
		-- from now on, we can assume that playerpos[1][1] is the next position we need to draw everytime!

		for i = 1, #server.fastmap do
			local cur = server.fastmap[i]

			if server.rendermap[p.P_party][cur]
				local x, y = R_table2coords(cur)
				local color = n2color[server.map[cur]]

				if playerpos[1]
				and cur == playerpos[1]
					color = 135
					table.remove(playerpos, 1)
				end

				v.drawFill(218+(x*gridsize), 70+(y*gridsize), 2, 2, (color or 0)|V_SNAPTOBOTTOM|V_SNAPTORIGHT)
			end
		end

		if reaperpos
			local x, y = R_table2coords(reaperpos)
			v.drawFill(218+(x*gridsize), 70+(y*gridsize), 2, 2, (165)|V_SNAPTOBOTTOM|V_SNAPTORIGHT)
		end

		if mypos
			local x, y = R_table2coords(mypos)
			v.drawFill(218+(x*gridsize), 70+(y*gridsize), 2, 2, (35)|V_SNAPTOBOTTOM|V_SNAPTORIGHT)
		end

		renderLog(v, 60)	-- render log above the mmap
	else
		-- no minimap: story mode generally
		renderLog(v, 140)
	end
end


local floor_specialinfo = {
    [1] = "transition",
    -- Thebel Block
    [5] = "miniboss",
    [9] = "boss",
    [10] = "transition",
    -- Arqa Block
    [16] = "miniboss",
    [23] = "boss",
    [24] = "transition",
    -- Yabbashah Block
    [30] = "miniboss",
    [37] = "miniboss",
    [43] = "boss",
    [44] = "transition",
    -- Tziah Block
    [50] = "miniboss",
    [55] = "miniboss",
    [60] = "miniboss",
    [63] = "boss",
    [64] = "transition",
    -- Harabah Block
    [70] = "miniboss",
    [75] = "miniboss",
    [79] = "miniboss",
    [83] = "miniboss",
    [88] = "boss",
	--Adamah Block
	[89] = "transition",
	[94] = "miniboss",
	[98] = "miniboss",
	[103] = "miniboss",
	[109] = "miniboss",
	[111] = "boss",
	--Monad Block
	[65535] = "transition",
	[65535+6] = "miniboss",
	[65535+10] = "miniboss",
	[65535+15] = "miniboss",
	[65535+16] = "boss",

}

rawset(_G, "renderTitlecard", function(v)
	if not server.entrycard or not server.entrytime then return end

	local addfade = server.P_DungeonStatus.gameoverfade

	local transflag = 0

	if server.entrytime > TICRATE/2
		v.drawFill()
	else
		transflag = 9 - (server.entrytime)/2
		if transflag > 0
			drawScreenwidePatch(v, v.cachePatch("H_RIP4"), nil, transflag<<V_ALPHASHIFT)
		end
	end
	transflag = max(0, $)

	local y = 100 - 6*#server.entrycard
	for i = 1, #server.entrycard
		V_drawString(v, 160, y, server.entrycard[i], "NFNT", transflag<<V_ALPHASHIFT, "center", 0, 31, FRACUNIT*3/4)
		y = $+12
	end

	-- lives:
	if netgame
	and server.gamemode == GM_COOP
	and server.P_BattleStatus
	and server.P_BattleStatus.lives
	and server.P_BattleStatus.lives >= 0	-- -1 is infinite, so don't display it

		if consoleplayer and consoleplayer.maincontrol and consoleplayer.maincontrol.valid
			local patch = charStats[consoleplayer.maincontrol.stats].icon
			local addlife = 0
			local explosionframe
			local etime = server.P_DungeonStatus.lifeexplode

			if etime
				if etime > 14
					addlife = 1
				end

				if etime <= 20
					explosionframe = "RXPL"..(20 - etime)
				end
			end

			v.draw(160 - 24, y+4, v.cachePatch(patch), transflag << V_ALPHASHIFT, v.getColormap(TC_DEFAULT, consoleplayer.maincontrol.color))
			V_drawString(v, 160, y+4, "x"..(server.P_BattleStatus.lives +addlife), "NFNT", transflag<<V_ALPHASHIFT, nil, 0, 31, FRACUNIT*3/4)

			if explosionframe and v.patchExists(explosionframe)
				v.draw(160+20, y+10, v.cachePatch(explosionframe))
			end
		end
	end

	-- floors display
    -- store our floor here
    local f = server.P_DungeonStatus.floor

	if gamemap == srb2p.tartarus_play
	or server.gamemode == GM_VOIDRUN
		-- In voidrun, we're going cheat.
		local info = floor_specialinfo
		local startfloor = 1
		local maxfloor = 111

		if f >= 65535
			startfloor = 65535
			maxfloor = 65535 + 16
		end

		if server.gamemode == GM_VOIDRUN
			-- let's hack:
			f = (server.P_DungeonStatus.VR_floor or 0)+1
			maxfloor = server.P_DungeonStatus.VR_floors ~= nil and server.P_DungeonStatus.VR_floors+2 or 0
			local t = {"transition"}
			t[maxfloor] = "transition"
			info = t
		end

		local yoffs = max(0, 17 - server.entrytime)

		if (server.P_DungeonStatus.floor == 0) then f = 1 end -- some idiot made floor 1 defined as floor 0 internally
		-- hx and hy shifts
		local hx_shift = 20
		if (server.entrytime <= 50)
			hx_shift = max(0, (server.entrytime-40)*2)
		end

		local hy_shift = 0
		if (server.entrytime >= 23 and server.entrytime <= 30)
			local shifts = {1, 2, 3, 4, 4, 3, 2, 1}
			hy_shift = shifts[server.entrytime-22]
		end

		if (f == 1) then hx_shift, hy_shift = 0, 0 end  -- no shifting on the first floor
		-- starting hx position
		local hx = 160-(20*(f-startfloor))+hx_shift

		for i = startfloor, maxfloor
			local w, c, s = 4, 0, 0
			-- get special info if possible
			if (info[i])
				if (info[i] == "transition")
					w, c = 2, 16
				elseif (info[i] == "miniboss")
					-- grey out bosses that are beaten
					w, c, s = 6, (f > i) and 16 or 52, 2
				elseif (info[i] == "boss")
					w, c, s = 8, (f > i) and 16 or 35, 2
				end
			end
			-- draw floor
			if (s) then v.drawFill(hx-(w/2), 180-(w/2) + 5*yoffs, w, w, 0|V_SNAPTOBOTTOM) end

			local xpos = hx-((w-s)/2)
			if xpos < 0 or xpos > 320
				hx = $+20
				continue
			end

			v.drawFill(xpos, 180-((w-s)/2) + 5*yoffs, w-s, w-s, c|V_SNAPTOBOTTOM)
			hx = $+20
		end
		-- draw arrow (with drawFills I'm lazy)
		for i = 0, 2
			local w = 4+(4*i)
			v.drawFill(160-(w/2), 166-(2*i)+hy_shift + 5*yoffs, w, 2, 0|V_SNAPTOBOTTOM)
		end
		-- draw icon
		if P_IsValidSprite2(consoleplayer.mo, SPR2_LIFE)
			v.drawIndex(160<<FRACBITS, (154+hy_shift + 5*yoffs)<<FRACBITS, FRACUNIT, v.getSprite2Patch(consoleplayer.mo.skin, SPR2_LIFE, A), V_SNAPTOBOTTOM, 0)
		end
	end

	if addfade
		drawScreenwidePatch(v, v.cachePatch("H_RIP4"), nil, (9-addfade)<<V_ALPHASHIFT)
	end
end)



-- floor transition
local function renderFloorFadeMask(v, p)
	local mo = p.mo
	if not mo return end
	if not mo.spr_nfloor return end

	local trannyflag = 9
	if mo.spr_nfloor > TICRATE -9
		trannyflag = max(1, TICRATE - mo.spr_nfloor)
	end
	drawScreenwidePatch(v, v.cachePatch("H_RIP4"), nil, trannyflag<<V_ALPHASHIFT)
end

-- Voidrun info: (also used in battle renderer)
rawset(_G, "renderVRInfo", function(v, p, btl)

	if server.gamemode ~= GM_VOIDRUN return end	--what

	local dng = server.P_DungeonStatus

	local bx, by = 30, 16
	if btl	-- in battle, slide the thing in
		by = min(-100 + btl.battletime*8, 16)
	end

	local time = server.P_DungeonStatus.VR_timer
	drawTimeClock(v, bx, by, time, 60*TICRATE)

	-- VR progress bar:
	v.drawFill(71, by+3, 125, 2, 138|V_SNAPTOTOP|V_SNAPTOLEFT)
	if dng.VR_score and dng.VR_target
		local score = min(dng.VR_score, dng.VR_target)	-- don't exceed max length obv
		v.drawFill(71, by+3, score*125 / dng.VR_target, 2, V_SNAPTOTOP|V_SNAPTOLEFT)
	end

	PDraw(v, 0, by-16, v.cachePatch("H_VDBAR"), V_SNAPTOTOP|V_SNAPTOLEFT)

	-- Hint:

	if dng.VR_hint
		local str = ""
		if time == nil
			str = "\x82".."NEXT: ".."\x80"
		end

		str = $..dng.VR_hint

		V_drawString(v, 72, by-10, str, "NFNT", V_SNAPTOTOP|V_SNAPTOLEFT, nil, 0, 31)
	end

	-- lives:
	local patch = charStats[consoleplayer.maincontrol.stats].icon
	PDraw(v, 73, by + 8, v.cachePatch(patch), V_SNAPTOTOP|V_SNAPTOLEFT, v.getColormap(TC_DEFAULT, consoleplayer.maincontrol.color))
	if dng.VR_lives ~= nil
		V_drawString(v, 84, by+8, "x"..dng.VR_lives, "NFNT", V_SNAPTOTOP|V_SNAPTOLEFT, nil, 0, 31)
	end
end)

-- Renders transitions between blocks...

local function renderBlockTransition(v)
	local t = server.blocktrans
	v.drawFill()
	tilePatch(v, "SKY6000", 0, 0, 0)
	tilePatch(v, "TTL_SKY2", (leveltime/2)%256, -(leveltime/4)%256, V_70TRANS)

	local ypos = 60 + 32*(server.difficulty-1)
	if t > TICRATE
	and t < TICRATE*2
		local tt = t-TICRATE	-- aux timer
		ypos = $ + 32
		ypos = min($, $ - max(1, 12/tt))	-- somewhat smooth movement blah blah

	end

	-- Draw what block we're on
	local currblock = blocknames[server.difficulty]:upper()
	v.drawFill(70, 85, 999, 1, 135)
	v.drawFill(71, 86, 999, 1, 135)

	V_drawString(v, 160, 90, "BLOCK "..server.difficulty, "FPIMP", 0, "right", 0, 31)
	if t < TICRATE*2
		V_drawString(v, 160, 100, currblock, "FPIMP", 0, "right", 0, 31)
	elseif t > TICRATE*3
		local tt = (t-TICRATE*3)
		V_drawString(v, 160, 100, currblock:sub(1, tt/2), "FPIMP", 0, "right", 0, 31)
		V_drawString(v, 32, 50, ("Level cap increased to \x82"..(difficulty_cap[server.difficulty] or 99)):sub(1, tt), "NFNT", 0, nil, 0, 31)
		V_drawString(v, 32, 60, ("Max EP increased to \x82"..(server.difficulty)):sub(1, tt), "NFNT", 0, nil, 0, 31)
	end

	v.drawFill(70, 116, 999, 1, 135)
	v.drawFill(71, 115, 999, 1, 135)

	drawTartarusBlocks(v, 160, ypos, server.difficulty)
	if t > TICRATE*3/2 and t < TICRATE*2	-- flash next block bc why not
	and leveltime & 1
		drawTartarusBlocks(v, 160, ypos, server.difficulty+1)
	end

	-- have the "2" appear slowly
	local scale2 = 0
	if t > TICRATE*3/2
	and t < TICRATE*2
		local tt = t - (TICRATE*3/2)
		scale2 = max(FRACUNIT, FRACUNIT*51 - tt*FRACUNIT*3)
	end


	if scale2
		V_drawString(v, 160, 90, server.difficulty+1, "FPIMP", 0, "right", 0, 31, scale2)
	end

	-- black fade
	local fadestr = 32 - t

	if fadestr > 0
		v.fadeScreen(0xFF00, fadestr)
	end

	-- white fade
	fadestr = 0
	if t > TICRATE*2
		local tt = t-(TICRATE*2)
		fadestr = 10 - (tt/4)
	end
	if fadestr > 0
		v.fadeScreen(0, fadestr)
	end

	-- final black fade
	fadestr = 0
	if t > TICRATE*5
		fadestr = t - TICRATE*5
	end
	if fadestr > 0
		v.fadeScreen(0xFF00, min(31, fadestr))
	end
end

local buttonscales = {

	{FRACUNIT/2, FRACUNIT*2},
	{FRACUNIT*3/4, FRACUNIT*3/2},
	{FRACUNIT, FRACUNIT},
	{FRACUNIT*3/2, FRACUNIT*3/4},
	{FRACUNIT*2, FRACUNIT/2},
	{FRACUNIT*3/2, FRACUNIT*3/4}
}

local function renderSaveButton(v, p)
	local timer = p.mo.m_savebutton
	local xscale = FRACUNIT
	local yscale = FRACUNIT
	if buttonscales[timer]
		xscale = buttonscales[timer][1]
		yscale = buttonscales[timer][2]
	end

	v.drawStretched(220*FRACUNIT, 90*FRACUNIT, FixedMul(FRACUNIT/2, xscale), FixedMul(FRACUNIT/2, yscale), v.cachePatch("H_SAVE"))
	if timer > #buttonscales
		local tt = timer - #buttonscales

		local str = "SAVE"
		V_drawString(v, 220, 83, str:sub(1, tt), "FPIMP", 0, "center", 0, 31)

		if timer > #buttonscales+4
			tt = timer - #buttonscales - 4
			str = "GAME"
			V_drawString(v, 230, 93, str:sub(1, tt), "FPIMP", 0, "center", 0, 31)
		end
	end
end

local hu_ticker = 0

local cv_titlecard = CV_RegisterVar({
	name = "hu_titlecard",
	defaultvalue = "On",
	PossibleValue = CV_OnOff,
})

local cv_mmap = CV_RegisterVar({
	name = "hu_mmap",
	defaultvalue = "On",
	PossibleValue = CV_OnOff,
})

local cv_date = CV_RegisterVar({
	name = "hu_date",
	defaultvalue = "On",
	PossibleValue = CV_OnOff,
})

local cv_command = CV_RegisterVar({
	name = "hu_command",
	defaultvalue = "On",
	PossibleValue = CV_OnOff,
})

local cv_partybars = CV_RegisterVar({
	name = "hu_partybars",
	defaultvalue = "On",
	PossibleValue = CV_OnOff,
})

local cv_event = CV_RegisterVar({
	name = "hu_event",
	defaultvalue = "On",
	PossibleValue = CV_OnOff,
})

local function R_drawVRTimeOut(v)
	local t = server.P_DungeonStatus.VR_timeout
	local rt = (TICRATE+10) -t

	local scale = min(FRACUNIT/2, rt*FRACUNIT/8)
	local flag = 0

	if t < 15
		scale = FRACUNIT/2 + (rt-15)*FRACUNIT/2
	end

	if t < 10
		flag = (10 - t) << V_ALPHASHIFT
	end

	if t < 20
		local str = 20-t
		v.fadeScreen(31, min(str, 10))
	end
	v.drawScaled(160<<FRACBITS, 100<<FRACBITS, scale, v.cachePatch("H_TIMEUP"), flag)

end

hud.add(function(v, p, c)

	hu_ticker = $+1

	local btl = server.P_BattleStatus[p.P_party]
	if not mapheaderinfo[gamemap].dungeon
		renderTitlecard(v)
	return end

	if btl and btl.running then return end	-- do not draw if the battle is running.

	local mo = p.mo
	if not mo return end

	local cmd

	if renderMenus(v, mo) return true end	-- don't render the rest if we're in a menu
	if p.mo and p.mo.valid
		if R_drawShop(v, p.mo) return true end			-- Also don't render the rest if we're in a shop!!
		if R_drawEquipLab(v, p.mo) return true end		-- ditto in the equip lab
	end

	if gamemap == srb2p.tartarus_map
		local firstp
		for p in players.iterate do
			firstp = p
			break
		end

		if firstp == consoleplayer
			cmd = 	{
						{BUTT_B, "Open Menu"}
					}
			V_drawCommands(v, cmd)
			--V_drawString(v, 318, 189, "B: OPEN NETPLAY MENU", "NFNT", V_SNAPTOTOP|V_SNAPTORIGHT, "right", 0, 31)
		end
	end

	if gamemap == srb2p.tartarus_map
		renderTitlecard(v)
	end

	if not NET_isset() return end	-- don't draw anything past that if netplay isn't set

	--if cv_showreapertimer.value and server.P_DungeonStatus.reapertimer ~= nil
	--	V_drawString(v, 0, 0, "Reaper Timer: "..server.P_DungeonStatus.reapertimer, "NFNT", V_SNAPTOTOP|V_SNAPTOLEFT, nil, 0, 31)
	--end

	if not p.P_party return end

	cmd = 	{
				{BUTT_A, "Jump"},
				{BUTT_B, "Menu"},
			}

	if cv_partybars.value
		renderPartyBars(v, p)
	end
	if cv_mmap.value
		renderMiniMap(v, p)
	end
	if cv_date.value
		drawDate(v, 0)
	end
	if cv_event.value
		drawEvent(v, p)
	end
	if cv_command.value
		V_drawCommands(v, cmd)
	end

	-- timer
	renderVRInfo(v, p)

	if mo.d_f12text
		V_drawString(v, 160, 32, "Press F12 to watch other players", "NFNT", V_SNAPTOBOTTOM, "center")
	end

	if mo.m_savebutton
		renderSaveButton(v, p)
	end

	R_drawRareDrop(v, p)

	if cv_titlecard.value
		renderTitlecard(v)
		renderFloorFadeMask(v, p)
	end

	if server.P_DungeonStatus.VR_timeout
		R_drawVRTimeOut(v)
	end

	if server.blocktrans
		renderBlockTransition(v)
	end

end)