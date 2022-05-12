-- Sadly this isn't the script where you can date people.
-- Besides, Kanade is mine you fuckhead.
-- However, here we handle dumb stuff like keeping track of the in game date.

-- ready a table for months and whatnot
rawset(_G, "days", {"Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"})
rawset(_G, "months", {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"})
rawset(_G, "monthdays", {31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31})
rawset(_G, "timeofday", {
	[-1] = "Dark Hour",
	[0] = "Early Morning",
	[1] = "Morning",
	[2] = "Noon",
	[3] = "Afternoon",
	[4] = "Evening",
	[5] = "Night",
	[-2] = "Promised Day",
	[-3] = "Night?"
})

-- generate moon phases etc for every single day. Yeah this kind of blows.
-- We know Apr 1st needs to be a full moon.

-- 0 = New
-- 4 = Half
-- 7 = Full
rawset(_G, "MOON_NEW", 0)
rawset(_G, "MOON_HALF1", 4)
rawset(_G, "MOON_FULL", 7)
rawset(_G, "MOON_HALF2", 10)

-- only has 1 year, loops back around.
rawset(_G, "DATE_calendarDTA", {})

-- Set default values...
srb2p.storydata.date = {

	daynum = 3,
	datemonth = 4,
	dateday = 4,
	dateyear = 2010,
	datetime = -1,
}

local dat = srb2p.storydata.date


local dayn = 1
local day = 26
local month = 3
local moon = 5
local inc = 0	-- used to increase moon phase

local prevday = 27
local prevmonth = 3

for i = 1, 364

	
	DATE_calendarDTA[month] = $ or {}
	DATE_calendarDTA[month][day] = $ or {}
	DATE_calendarDTA[month][day]["moonphase"] = moon
	DATE_calendarDTA[month][day]["dayn"] = dayn
	
	-- prev day
	DATE_calendarDTA[month][day]["prevday"] = prevday
	DATE_calendarDTA[month][day]["prevmonth"] = prevmonth
	
	prevday = day
	prevmonth = month
	
	inc = $+1
	if inc > 2
	or moon == MOON_NEW+2
	or moon == MOON_FULL+2
	or moon == MOON_NEW	-- new
	or moon == MOON_HALF1	-- half
	or moon == MOON_FULL	-- full
	or moon == MOON_HALF2	-- half
		moon = $+1
		if moon > 13
			moon = MOON_NEW	-- new
		end
		
		inc = 0
	end
	
	--print("DATE: "..day.."/"..month.." -> "..moon)
	
	-- day name
	dayn = $+1
	if dayn > #days
		dayn = 1
	end	
	
	day = $+1
	if day > monthdays[month]
		day = 1
		month = $+1
		if month > #monthdays
			month = 1
		end
	end
	
	-- next day
	DATE_calendarDTA[prevmonth][prevday]["nextday"] = day
	DATE_calendarDTA[prevmonth][prevday]["nextmonth"] = month	
end

rawset(_G, "DATE_toNextFullMoon", function()
	local cday = dat.dateday
	local cmonth = dat.datemonth
	local days = 0
	
	-- check if we have a cached result
	if DATE_calendarDTA[dat.datemonth][dat.dateday]["tomoon"] ~= nil
		return DATE_calendarDTA[dat.datemonth][dat.dateday]["tomoon"]
	end	
	
	while DATE_calendarDTA[cmonth][cday] and DATE_calendarDTA[cmonth][cday]["moonphase"] != MOON_FULL
		days = $+1
		cday = $+1
		if cday > monthdays[cmonth]
			cday = 1
			cmonth = $+1
			if cmonth > #monthdays
				cmonth = 1
			end
		end
	end
	
	-- cache result
	DATE_calendarDTA[dat.datemonth][dat.dateday]["tomoon"] = days
	
	return days
end)

rawset(_G, "DATE_Until", function(tday, tmonth)
	local cday = dat.dateday
	local cmonth = dat.datemonth
	local days = 0
	local limit = 365
	
	while (cday ~= tday or cmonth ~= tmonth) and limit
		limit = $-1	-- be careful not to get stuck in an endless loop
		days = $+1
		cday = $+1
		if cday > monthdays[cmonth]
			cday = 1
			cmonth = $+1
			if cmonth > #monthdays
				cmonth = 1
			end
		end
	end
	
	return days
end)

-- sets date in the same order.
rawset(_G, "DATE_setDate", function(dn, mo, da, ye, ti)
	dat.daynum = dn or $
	dat.datemonth = mo or $
	dat.dateday = da or $
	dat.dateyear = ye or $
	dat.datetime = ti or $
end)

rawset(_G, "DATE_setTime", function(ti)
	dat.datetime = ti
end)

-- increments the day:
rawset(_G, "DATE_nextDay", function()

	-- increments the day name
	dat.daynum = (($ + 1) % (#days +1)) or 1	-- x % 8 = x if x < 8, x % 8 = 0 -> 1 if x = 8

	-- increment the day date:
	dat.dateday = $+1
	-- Increment the month if it's over...
	if dat.dateday > (monthdays[dat.daymonth] or 30)
		dat.dateday = 1
		dat.datemonth = $+1

		-- if the year is over, increment it...
		if dat.datemonth > #months
			dat.datemonth = 1
			dat.dateyear = $+1
		end
	end
end)


-- changes the time of the day and then loads a new map.
-- The reload occurs even if you set the same map.
rawset(_G, "DATE_changeTime", function(newtime, newmap, skip)
	DNG_fade(	function()
					
					server.datetimechange = {
						time = newtime,
						map = newmap,
						timer = 1,
					}
					server.skiptitlecard = skip
				end
	)
	end
)

-- function to call in the dungeon handler, takes care of the above:
rawset(_G, "DNG_changeDateTimeHandler", function()
	if server.datetimechange
		server.datetimechange.timer = $+1
			
		if server.datetimechange.timer == 50
			DATE_setTime(server.datetimechange.time)
			DNG_loadNewMap(server.datetimechange.map)
			--server.datetimechange = nil
		end
		
		return true
	end
	return false
end)


-- starts the date change routine
-- year is automatically incremented as the calendar only lasts about 1 year anyway
rawset(_G, "DATE_changeDate", function(newmonth, newday, newtime, newmap, skip)
	DNG_fade(	function()
					
					server.datechange = {
						tmonth = newmonth,
						tday = newday,
						time = newtime,
						map = newmap,
						
						daystogo = DATE_Until(newday, newmonth),
						
						cmonth = dat.datemonth,
						cday = dat.dateday,
						cyear = dat.dateyear,
						coffs = 0,	-- offset
									-- there are 45px between dates horizontally,
									-- 15px vertically.
						
						timer = 1,
					}
					server.skiptitlecard = skip
				end
	)
	end
)

-- function to call on the handler to take care of the above.
rawset(_G, "DNG_changeDateHandler", function()
	if server.datechange
		local dc = server.datechange
		dc.timer = $+1
		
		-- let us begin...
		if dc.timer > TICRATE*2
			
			local tt = dc.timer - (TICRATE*2)
			local scrollspeed = min(45, 3 + dc.daystogo)
			
			-- it's over:
			if dc.finishtimer
				if dc.timer > dc.finishtimer+TICRATE
					local c = DATE_calendarDTA[dc.cmonth][dc.cday]
					DATE_setDate(c.dayn, dc.cmonth, dc.cday, dat.dateyear, dc.time)
					DNG_loadNewMap(dc.map)
				end	
			else	-- it's still going
				dc.coffs = $ + scrollspeed
				if dc.coffs >= 45	-- max scroll
					
					local cday = dc.cday
					local cmonth = dc.cmonth
					
					dc.cday = DATE_calendarDTA[cmonth][cday].nextday
					dc.cmonth = DATE_calendarDTA[cmonth][cday].nextmonth
					
					-- every monday, reset shop stocks.
					if DATE_calendarDTA[dc.cmonth][dc.cday].dayn == 1
						print("shop has been reset")
						srb2p.storydata.shopstocks = {}
					end
					
					-- hack
					if dc.cmonth == 1
					and dc.cday == 1	-- 1/1
						dat.dateyear = $+1
					end	
					
					dc.coffs = 0
					dc.daystogo = $-1
					
					if not dc.daystogo
						dc.finishtimer = dc.timer
					end
				end
			end	
			
		end
		
		return true
	end
	return false
end)


-- resets all the stuff on mapload
-- we reset them ON mapload because otherwise the huds are cleared before the map fade, and we don't want that.

addHook("MapLoad", do
	if server and server.valid
		server.datetimechange = nil
		server.datechange = nil
	end
end)

COM_AddCommand("d_changedatetime", function(p, arg1, arg2)
	DATE_changeTime(tonumber(arg1) or dat.datetime, tonumber(arg2) or gamemap, true)
end)

-- month/day/time
COM_AddCommand("d_changedate", function(p, arg1, arg2, arg3)
	DATE_changeDate(tonumber(arg1), tonumber(arg2), tonumber(arg3), gamemap, true)
end)


COM_AddCommand("d_nextday", function(p)
	DATE_nextDay()
end)