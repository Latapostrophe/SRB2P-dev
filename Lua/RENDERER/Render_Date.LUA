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

	local str = "NEXT 4"
	local pp = "H_MOON6"

	-- COSMETIC FOR MARATHON
	if server.marathon
	or not netgame
		str = "FULL"
		pp = "H_MOON7"
	end

	PDraw(v, 310 - V_stringWidth(v, str, "NFNT")>>FRACBITS +1, y + 25, v.cachePatch("H_MOONBG"), V_SNAPTOTOP|V_SNAPTORIGHT)
	PDraw(v, 310 - V_stringWidth(v, str, "NFNT")>>FRACBITS, y + 25, v.cachePatch(pp), V_SNAPTOTOP|V_SNAPTORIGHT)
	V_drawString(v, 310, y + 22, str, "NFNT", V_SNAPTOTOP|V_SNAPTORIGHT, "right", color, 31)

	V_drawString(v, 310, y + 4, save.datemonth.."/"..save.dateday.." "..days[save.daynum]:sub(1, 2), "NFNT", V_SNAPTOTOP|V_SNAPTORIGHT, "right", color, 31)

	-- draw time of day
	V_drawString(v, 310, y + 12, timeofday[save.datetime], "NFNT", V_SNAPTOTOP|V_SNAPTORIGHT, "right", color, 31)
end)