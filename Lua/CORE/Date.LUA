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

local save = SAVE_localtable

save.date = {3, 4, 20, 2010, -1}
-- dayname, month, day, year, nextfull