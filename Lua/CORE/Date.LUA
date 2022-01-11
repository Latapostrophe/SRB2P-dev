-- Sadly this isn't the script where you can date people.
-- Besides, Kanade is mine you fuckhead.
-- However, here we handle dumb stuff like keeping track of the in game date.

-- ready a table for months and whatnot
rawset(_G, "days", {"Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"})
rawset(_G, "months", {"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"})
rawset(_G, "monthdays", {31, 28, 31, 30, 31, 30, 31, 30, 31, 30, 31, 30, 31})
rawset(_G, "timeofday", {
	[-1] = "Dark Hour",
	[0] = "Early Morning",
	[1] = "Morning",
	[2] = "Noon",
	[3] = "Afternoon",
	[4] = "Evening",
	[5] = "Night",
	[-2] = "Promised Day"
})


-- Set default values...
srb2p.storydata.date = {

	daynum = 3,
	datemonth = 4,
	dateday = 4,
	dateyear = 2010,
	datetime = -1,
}

local dat = srb2p.storydata.date

-- sets date in the same order.
rawset(_G, "DATE_setDate", function(dn, mo, da, ye, ti)
	dat.daynum = dn or $
	dat.datemonth = mo or $
	dat.dateday = da or $
	dat.dateyear = ye or $
	dat.datetime = ti or $

end)

-- increments the day:
rawset(_G, "DATE_nextDay", function()

	-- increments the day name
	dat.daynum = (($ + 1) % (#days)) or 1	-- x % 8 = x if x < 8, x % 8 = 0 -> 1 if x = 8

	-- increment the day date:
	dat.dateday = $+1
	-- Increment the month if it's over...
	if sdate.dateday > (monthdays[dat.daymonth] or 30)
		dat.dateday = 1
		dat.datemonth = $+1

		-- if the year is over, increment it...
		if dat.daymonth > #months
			dat.datemonth = 1
			dat.dateyear = $+1
		end
	end
end)



