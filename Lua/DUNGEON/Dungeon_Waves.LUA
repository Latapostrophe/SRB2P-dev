-- waves for other dungeons

-- each dungeon is separated in multiple sections.
-- each section can be useful to have stronger waves of enemies for instance

rawset(_G, "DNG_dungeonwaves", {})

rawset(_G, "DNG_getRandomWave", function()
	if mapheaderinfo[gamemap].tartarus	-- tartarus uses special kind of waves, it needs its own table since it's pretty long
		return server.waves[P_RandomRange(1, #server.waves)]
	else	-- for other dungeons
		local wave_sets = DNG_dungeonwaves[gamemap][server.P_DungeonStatus.section]
		return wave_sets[P_RandomRange(1, #wave_sets)]
	end
end)

-- Tutorial waves
DNG_dungeonwaves[srb2p.tutorial_map] = {

	[1] = 	{
				{"tutorial_1",
				"tutorial_1",}
			},

	[2] = 	{
				{"tutorial_2",
				"tutorial_2",
				"tutorial_2",
				},
			},

}