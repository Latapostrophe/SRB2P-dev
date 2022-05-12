-- Used for Hub maps; 

local skyarray = {
	
	[0] = 1,		-- Early Morning
	[1] = 1,		-- Morning
	[2] = 1,		-- Noon
	[3] = 1,		-- Afternoon
	[4] = 4,		-- Evening
	[5] = 6,		-- Night
	[-1] = 6001,	-- dark hour
}

local brightness_drop = {
	[0] = 32,
	[1] = 0,
	[2] = 0,
	[3] = 0,
	[4] = 32,
	[5] = 56,
	[-1] = 48,
}

local cmap_index = {
	[0] = 2,
	[1] = 0,
	[2] = 0,
	[3] = 0,
	[4] = 2,
	[5] = 3,
	[-1] = 1,
}

addHook("MapLoad",do
	
	local dtime = srb2p.storydata.date
	if not dtime or not mapheaderinfo[gamemap].usetime return end
	dtime = dtime.datetime
	
	if skyarray[dtime]
		P_SetupLevelSky(skyarray[dtime])
	end
	
	if brightness_drop[dtime]
		if mapheaderinfo[gamemap].usetime
			for s in sectors.iterate do
				if s.special != 4096	-- starpost activator disables the light change (yeah it's dumb)
					s.lightlevel = $ - brightness_drop[dtime]
				end	
				
				if s.tag >= 512 and s.tag <= 515
					s.floorheight = $ - 2048*cmap_index[dtime]*FRACUNIT
					s.ceilingheight = $ - 2048*cmap_index[dtime]*FRACUNIT
				end
			end
		end
	end	
end)