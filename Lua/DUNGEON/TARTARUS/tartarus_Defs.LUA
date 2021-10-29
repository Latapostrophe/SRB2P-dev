-- For general use tartarus functions

local gentypes = {
	"GEN_NORMAL",		-- Normal floors
	"GEN_PERFORATED",	-- Much more pits / spikes: All Shadows are Fog Shadows
	"GEN_STRONG",		-- All shadows are strong, more items spawn, reaper spawns faster
	"GEN_GOLD",			-- All shadows are gold, more rings spawn, reaper spawns faster
	"GEN_DREAD",		-- No Shadows, brightness darkened a little, many more items, reaper spawns within a minute
	"GEN_INTERFERENCE",	-- Everyone spawns on random tiles, minimap jammed, smaller in scale, reaper takes longer to spawn
	"GEN_DARK",			-- Floor is very dark, smaller in scale, shadows only display when nearing them, reaper takes longer to spawn
	"GEN_CLEAR",		-- Floor is instantly mapped and smaller in scale.
}

for i = 1, #gentypes do
	rawset(_G, gentypes[i], i)
end

local gentypes_odds = {
	[GEN_NORMAL] = 150,
	[GEN_PERFORATED] = 15,
	[GEN_STRONG] = 15,
	[GEN_GOLD] = 5,
	[GEN_DREAD] = 6,
	[GEN_INTERFERENCE] = 14,
	[GEN_DARK] = 12,
	[GEN_CLEAR] = 19,
}

rawset(_G, "DNG_getGenerationType", function()
	local spawnchance, totalspawnchance = {}, 0

	-- set odds table
	for gentype = 1, #gentypes
		local odds = gentypes_odds[gentype]

		totalspawnchance = $+odds
		spawnchance[gentype] = totalspawnchance
		dprint("spawnchance["..gentype.."]: "..spawnchance[gentype])
	end

	-- get the generation type!
	if (totalspawnchance <= 0)	-- we dont have any odds somehow? default to GEN_NORMAL (potential modding shenanigan foolproofing)
		return 1	-- GEN_NORMAL should always be 1
	end

	totalspawnchance = P_RandomKey($)
	dprint("totalspawnchance: "..totalspawnchance)

	local gentype
	for i = 1, #gentypes
		gentype = i
		if (spawnchance[i] > totalspawnchance) then break end
	end

	dprint("gentype: "..gentype)
	return gentype
end)

local gridtypes = {
	"T_WALL",
	"T_EMPTY",
	"T_ITEM",
	"T_ENEMY",
	"T_START",
	"T_EXIT",
	"T_CHECKPOINT",
	"T_BOSS",
	"T_PIT",
	"T_RINGS",
	"T_GOLDI",
	"T_SHOP",		-- self explanatory
	"T_SPIKES",
	"T_FLOORSPIKES",
	"T_GATE",		-- Limited to 3, will spawn a corresponding switch somewhere on the map
					-- gates are commonly used to block an item, gold shadow, or the spring off

	"T_GOLDENEMY",	-- Guranteed gold enemy

	"T_NOSWITCH",	-- special type of floor that's normal but doesn't allow for switches
}

for i = 1, #gridtypes
	rawset(_G, gridtypes[i], i-1)
end

rawset(_G, "DNG_ARENAPOINT", MT_BOSS3WAYPOINT)	-- defined in case constants change or w/e
rawset(_G, "DNG_SKYBOXPOINT", MT_TUBEWAYPOINT)	-- defined in case constants change or w/e

-- colormap stuff
local STARTSHIFT = 512	-- start cmap shift from tag 512
local ENDSHIFT = 768	-- end shift at tag 768
local CMAPSIZE = 4096	-- size of a colourmap block

rawset(_G, "DNG_setextradata", function(t)

	if not t return end
	local shift = (t.default and t.default.colormapindex) and t.default.colormapindex or 0

	-- fetch colormaps and shift by index
	for i = 0, #sectors-1 do
		local s = sectors[i]
		if s.tag >= STARTSHIFT and s.tag <= ENDSHIFT
			local tag = s.tag - STARTSHIFT - shift
			local newz = -512 + (tag)*CMAPSIZE
			local newceilz = -512 + (tag+1)*CMAPSIZE -1
			s.floorheight = newz*FRACUNIT
			s.ceilingheight = newceilz*FRACUNIT

		end
	end

	local skyboxn
	if t.default and t.default.skyboxindex ~= nil
		skyboxn = t.default.skyboxindex
	end

	if skyboxn ~= nil

		-- also set skybox and arena #
		local skyboxmobj
		for m in mobjs.iterate()
			if not m or not m.valid continue end

			if m.type == MT_SKYBOX
				skyboxmobj = m
				break
			end
		end

		--... now do that again to find where we have to go

		for m in mobjs.iterate()
			if not m or not m.valid continue end

			if m.type == DNG_SKYBOXPOINT and m.spawnpoint and m.spawnpoint.angle == skyboxn
				P_SetSkyboxMobj(skyboxmobj)
				P_TeleportMove(skyboxmobj, m.x, m.y, m.z)	-- for late joiners. Otherwise the skybox is going to be in a weird location
				break
			end
		end
	end

	-- now for battle coords
	local battlen
	if t.default and t.default.arenaindex ~= nil
		battlen = t.default.arenaindex
	end

	if battlen == nil return end

	local shiftx = (mapheaderinfo[gamemap].arenashiftx or 0) *FRACUNIT
	local shifty = (mapheaderinfo[gamemap].arenashifty or 0) *FRACUNIT	-- mp arena shift

	local center

	for m in mobjs.iterate()
		if not m or not m.valid continue end

		if m.type == DNG_ARENAPOINT and m.spawnpoint and m.spawnpoint.extrainfo == battlen
			center = m
			break
		end
	end

	if not center return end	-- youch

	for i = 1, 4
		server.P_BattleStatus[i].arenacenter = nil
		server.P_BattleStatus[i].arena_coords[1] = center.x + shiftx*(i-1)
		server.P_BattleStatus[i].arena_coords[2] = center.y + shifty*(i-1)
		server.P_BattleStatus[i].arena_coords[3] = center.z
		server.P_BattleStatus[i].arena_coords[4] = center.angle
	end
end)

rawset(_G, "gridsize", 256<<FRACBITS)	-- grid size in map units
local size_x, size_y = 48, 48

rawset(_G, "DNG_table2coord", function(i)
	return i-1 - ((i-1) / size_x) * size_x, (i-1) / size_x
end)

-- teleports mobj to the square of that one index
rawset(_G, "DNG_tpmobj", function(mo, i)
	if not DNG_isTartarusMap() return end
	local x,y = DNG_table2coord(i)
	P_TeleportMove(mo, x*gridsize + gridsize/2, -y*gridsize - gridsize/2, mo.z)
end)


-- teleports all of the players from party #n away from pits
rawset(_G, "D_AwayFromPit", function(pn)

	for p in players.iterate
		if p and p.P_party == pn and p.mo and p.mo.valid
		and server.map and #server.map
		and server.map[#p.mo.subsector.sector+1] == T_PIT	-- above a pit!
		and not p.mo.spr_pit	-- already fell, leave em at it

			local mo = p.mo

			local s = mo.dng_savesector
			while s == nil
				local tmp = P_RandomRange(1, #server.map)
				if map[tmp] == 1
					s = tmp
				end
			end
			mo.z = 0
			DNG_tpmobj(mo, s)
		end
	end
end)

local function D_CleanseBattle(mo)
	if mo.readybattle
		local t = mo.readybattle

		if t.t2
			for i = 1, #t.t2
				P_RemoveMobj(t.t2[i])
			end
		end


		mo.readybattle = nil
	end
end


rawset(_G, "D_ReadyBattle", function(p)
	local mo = p.mo
	if mo.readybattle

		local t = mo.readybattle
		PLAY_nomove(t.mo1.player)

		if not t.mo2 or not t.mo2.valid
			mo.readybattle = nil
			print("ERROR: Unexpected action occured during battle preparation?")
			return
		end

		if not P_IsObjectOnGround(t.mo1)
			P_SetObjectMomZ(t.mo1, -P_GetMobjGravity(t.mo1), true)
		end
		if leveltime % 2 == 0
			local g = P_SpawnGhostMobj(t.mo1)
			g.colorized = true
			g.tics = 5
		end

		if not t.mo2.strong
		and not P_IsObjectOnGround(t.mo2)
			P_SetObjectMomZ(t.mo2, -P_GetMobjGravity(t.mo2), true)
		end
		if leveltime % 2 == 0
			local g = P_SpawnGhostMobj(t.mo2)
			g.color = SKINCOLOR_RED
			g.colorized = true
			g.tics = 5
		end

		if t.timer == TICRATE
			for p2 in players.iterate do
				if p2 and p2.mo and p2.mo.valid and p2 ~= p and p2.P_party == p.P_party
					local mo2 = p2.mo
					local excl = P_SpawnMobj(mo2.x, mo2.y, mo2.z+48*FRACUNIT, MT_DUMMY)
					excl.flags = MF_NOCLIPHEIGHT|MF_NOGRAVITY|MF_NOBLOCKMAP
					excl.scale = 1
					excl.destscale = FRACUNIT*2
					excl.scalespeed = FRACUNIT/2
					excl.sprite = SPR_XCLA
					excl.frame = A|FF_FULLBRIGHT
					excl.fuse = 20
					excl.momx = P_RandomRange(-3, 3)*FRACUNIT
					excl.momy = P_RandomRange(-3, 3)*FRACUNIT
				end
			end
		end
		t.timer = $-1

		if not t.timer	-- start battle!
			BTL_StartBattle(t.pn, t.t1, t.t2, t.advantage, t.func, t.music)
			D_AwayFromPit(t.pn)
			mo.readybattle = nil
			t = nil

			for p in players.iterate do
				if p and p.mo and p.mo.valid and p.P_party and mo.player.P_party == p.P_party and p.mo ~= mo
					p.mo.p_battlebuf = nil
					p.mo.readybattle = nil
					D_CleanseBattle(mo)
				end
			end
		end

		return true
	end
end)

rawset(_G, "DNG_getTartarusMusic", function(block)

	local bnum = block or server.difficulty
	
	if bnum == 7
		return "BLOCK1"	-- special case
	end
	
	-- otherwise, do that
	return "BLOCK"..bnum	
end)

-- When a PLAYER JOINS, reset EVERY SHADOW ENTITY
addHook("PlayerJoin", function(node)
	-- dear godddddd
	if node
		server.mustresetentities = true
	end
end)

-- shop shit
freeslot("SPR_SDOR")