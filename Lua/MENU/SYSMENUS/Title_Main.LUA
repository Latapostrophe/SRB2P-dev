-- title screen Lua for SRB2P
local displaytime = 0

hud.add(function(v)

	displaytime = $+1

	if displaytime < TICRATE*10
		v.drawFill()	-- black background
	elseif displaytime < TICRATE*12	-- fade out over 2 seconds

		local tflag = (displaytime - 10*TICRATE) /5
		local oldt = tflag
		if oldt < 10
			v.fadeScreen(31, 10 - tflag)
		end
	else
		-- SRB2P logo:
		local tflag = 9 -(displaytime - 12*TICRATE)
		if tflag > 0 and tflag < 10
			tflag = $ << V_ALPHASHIFT
		else
			tflag = 0
		end
		v.drawScaled(10*FRACUNIT, 40*FRACUNIT, FRACUNIT*2/3, v.cachePatch("TTLLOGO"), tflag|V_SNAPTOLEFT)
	end

	-- clock graphic is 256x256, rescale to 2/3 so that it's 192x192 and so the game can display it

	if displaytime < TICRATE*5	-- first 5 seconds, display the normal full clock
		v.drawScaled(160*FRACUNIT, 100*FRACUNIT, 2*FRACUNIT /3, v.cachePatch("TTLCLOC"..displaytime/TICRATE +1))

		if leveltime%TICRATE == 0
			S_StartSound(nil, sfx_ctic)
		end

	elseif displaytime < TICRATE*7

		-- draw the clock fading to green
		v.drawScaled(160*FRACUNIT, 100*FRACUNIT, 2*FRACUNIT /3, v.cachePatch("TTLCLOC"..min(8, (5 + (displaytime - TICRATE*5))) ))
	elseif displaytime == TICRATE*7	-- here comes the fun part
		-- we have 36 debris to spawn.

		for i = 1, 36 do
			local debris = phud.create(0, 160, 100, "TTLFRA"..i, -1, nil, "title")
			debris.momx = N_RandomRange(2, 6)*(N_RandomRange(0, 1) and 1 or -1)
			debris.momy = N_RandomRange(2, 6)*(N_RandomRange(0, 1) and 1 or -1)
			debris.physflags = $|PF_NOGRAVITY
			debris.scale = FRACUNIT*2/3
			debris.destscale = debris.scale
			debris.deleteoffscreen = nil
			debris.fuse = TICRATE*8
		end
		S_StartSound(nil, sfx_cboom)
	end
	DisplayPhysHUD(v, "title")

	SYS_drawMenu(v)
end, "title")

addHook("MapChange", do
	SYS_closeMenu()
end)

addHook("MapLoad", do
	displaytime = 0
	if gamemap == 40
		S_ChangeMusic(0)
	end
end)

--addHook("ThinkFrame", do
rawset(_G, "TTL_Thinker", function()
	if gamemap ~= 40 return end	-- not titlemap

	local evt = SYS_getEvent()

	if (evt == KEY_ENTER or evt == KEY_JOY1)
	and displaytime < TICRATE*11
		displaytime = TICRATE*11
	end

	if displaytime == 2
		S_ChangeMusic(0)
	elseif displaytime == TICRATE*11+1
		S_ChangeMusic("_TITLE", true)
		SYS_OpenMenu(SM_TITLE)
	end

	SYS_handleMenu()

	for mo in mobjs.iterate()
		if mo.type == MT_ALTVIEWMAN
			mo.cusval = ANG1*20
			mo.z = mo.floorz + FRACUNIT*64
		end
	end
end)