-- render dumb shit like the calendar
-- right now this is purely cosmetic and forced, and does nothing

-- @TODO: set full moon dates etc...

rawset(_G, "drawDate", function(v, y)
	y = $ or 0

	local save = srb2p.storydata.date
	if server.gamemode == GM_VOIDRUN return end	-- nobody cares!

	-- render background:
	PDraw(v, 320, y, v.cachePatch("H_DATEOL"), V_SNAPTOTOP|V_SNAPTORIGHT|V_30TRANS)

	local color = 0
	if save.datetime < 0	-- this is the dark hour
		color = 103
	end

	-- draw lunar phase
	-- @TODO: do that for real.....
	
	local moonp = DATE_calendarDTA[save.datemonth][save.dateday] and DATE_calendarDTA[save.datemonth][save.dateday]["moonphase"] or 0
	local daystomoon = DATE_toNextFullMoon()
	
	local str = "NEXT "..daystomoon
	local pp = "H_MOON"..moonp

	-- COSMETIC FOR MARATHON
	if server.marathon
	--or not netgame
		str = "FULL"
		pp = "H_MOON7"
	end

	-- change text:
	if moonp == MOON_NEW
		str = "NEW"
		pp = nil	-- don't draw the new moon.
	elseif moonp == MOON_HALF1 or moonp == MOON_HALF2
		str = "HALF"
	elseif moonp == MOON_FULL
		str = "FULL"
	end	

	PDraw(v, 310 - V_stringWidth(v, str, "NFNT")>>FRACBITS +1, y + 25, v.cachePatch("H_MOONBG"), V_SNAPTOTOP|V_SNAPTORIGHT)
	if pp
		PDraw(v, 310 - V_stringWidth(v, str, "NFNT")>>FRACBITS, y + 25, v.cachePatch(pp), V_SNAPTOTOP|V_SNAPTORIGHT)
	end	
	V_drawString(v, 310, y + 22, str, "NFNT", V_SNAPTOTOP|V_SNAPTORIGHT, "right", color, 31)

	V_drawString(v, 310, y + 4, save.datemonth.."/"..save.dateday.." "..days[save.daynum]:sub(1, 2), "NFNT", V_SNAPTOTOP|V_SNAPTORIGHT, "right", color, 31)

	-- draw time of day
	V_drawString(v, 310, y + 12, timeofday[save.datetime], "NFNT", V_SNAPTOTOP|V_SNAPTORIGHT, "right", color, 31)
end)

rawset(_G, "drawDateChangeTime", function(v)
	
	local save = srb2p.storydata.date
	if not server.datetimechange return end
	-- draw old time
	v.drawFill()
	
	if server.datetimechange.timer <= 30
		local xpos = 160
		if server.datetimechange.timer > 20
			xpos = 160 + (server.datetimechange.timer-20)*20
		end	
		
		V_drawString(v, xpos, 95, timeofday[save.datetime], "NFNT", V_SNAPTOTOP|V_SNAPTORIGHT, "center", 0, 31, FRACUNIT)
	end
		
	if server.datetimechange.timer > 20
		local xpos = min(160, -30 + (server.datetimechange.timer-20)*20)
		V_drawString(v, xpos, 95, timeofday[server.datetimechange.time], "NFNT", V_SNAPTOTOP|V_SNAPTORIGHT, "center", 0, 31, FRACUNIT)
	end
	
end)

-- draws a single day at the given coordinates
local function drawday(v, x, y, month, day)
	
	local cal = DATE_calendarDTA[month][day]
	local pp = "H_MOON"..(cal.moonphase or 1)
	
	V_drawString(v, x, y, day, "FPIMP", 0, "center", 0, nil)
	V_drawString(v, x, y+10, days[cal.dayn]:upper():sub(1, 3), "FPIMP", 0, "center", 0, nil)
	
	-- draw moon phase
	PDraw(v, x, y + 28, v.cachePatch("H_MOONBG"))
	if pp
		PDraw(v, x, y + 28, v.cachePatch(pp))
	end		
end

rawset(_G, "drawDateChangeDate", function(v)
	local save = srb2p.storydata.date
	if not server.datechange return end
	
	local timer = server.datechange.timer
	local dday = server.datechange.cday
	local dmonth = server.datechange.cmonth
	
	v.drawFill()
	
	if timer > 10
		local t = timer-10
		PDraw(v, 0, max(200, 250 - timer*4), v.cachePatch("H_DTEBOT"), V_SNAPTOBOTTOM|V_SNAPTOLEFT) 
		PDraw(v, 320, min(0, -50 + timer*4), v.cachePatch("H_DTETOP"), V_SNAPTOTOP|V_SNAPTORIGHT)
		V_drawString(v, 0, max(184, 250 - timer*4), save.dateyear, "FPIMP", 0, nil, 31, nil, FRACUNIT)
		
		-- Draw month above the date
		V_drawString(v, 160, 55, dmonth, "FPIMP", 0, "center", 0, nil, FRACUNIT)
		V_drawString(v, 160, 75, months[dmonth]:upper(), "FPIMP", 0, "center", 0, nil)
		
		-- drawfill arrow cause i'm lazy
		for i = 0, 2
			local w = 4+(4*i)
			local yoffs = 0
			if server.datechange.finishtimer
				yoffs = max(0, 3 - (server.datechange.timer - server.datechange.finishtimer))
			elseif server.datechange.timer > TICRATE*2
				yoffs = min(3, server.datechange.timer-(TICRATE*2))
			end	
			
			v.drawFill(160-(w/2), 95-(2*i) - yoffs, w, 2, 0)
		end		
		
		-- Draw date
		
		local xpos = 160 - server.datechange.coffs
		local ypos = 100 - server.datechange.coffs /3
		-- start a few days prior
		for i = 1, 4
			local tmp = {DATE_calendarDTA[dmonth][dday].prevday, DATE_calendarDTA[dmonth][dday].prevmonth}
			dday = tmp[1]
			dmonth = tmp[2]
			
			xpos = $ - 45
			ypos = $ - 15
		end
		
		for i = 1, 10
			drawday(v, xpos, ypos, dmonth, dday)
			xpos = $ + 45
			ypos = $ + 15
			
			local tmp = {DATE_calendarDTA[dmonth][dday].nextday, DATE_calendarDTA[dmonth][dday].nextmonth}
			dday = tmp[1]
			dmonth = tmp[2]
		end
	end
end)