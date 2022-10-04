-- Various Player Bot functions

-- Get a Persona's stats at LV1. This is very rudimentary
-- NOTE: Stats cannot go below 2, so the minimum returned will be {2, 2, 2, 2, 2}

rawset(_G, "PLYR_getLv1Stats", function(persona)

	local stats = {persona.strength, persona.magic, persona.endurance, persona.agility, persona.luck}
	local lv1_stats = {}

	for i = 1, #stats
		lv1_stats[i] = max(2, (stats[i]-1)/3)
	end

	return lv1_stats
end)

-- Gives a Persona's stat growth rates based off its LV1 and LV10 counterparts
--
rawset(_G, "PLYR_getGrowthRates", function(persona)

	local stats = {persona.strength, persona.magic, persona.endurance, persona.agility, persona.luck}
	local lv1stats = PLYR_getLv1Stats(persona)
	local lvdiff = 9	-- 10 - 1, base stats are at lv10

	local rates = {}

	for i = 1, #stats do
		rates[i] = ((stats[i] - lv1stats[i])*1000) / lvdiff	-- *1000 to keep precision
	end

	return rates
end)

-- Get a Persona's stats at any given level using growth rates
-- NOTE: These are the base stats and do not take equipment into account

rawset(_G, "PLYR_getStatsAtLevel", function(persona, level)

	local stats = PLYR_getLv1Stats(persona)
	local lv1bst = stats[1] + stats[2] + stats[3] + stats[4] + stats[5]	-- Intended: 12 (3*lvl + 9)

	local rates = PLYR_getGrowthRates(persona)

	local lvstats = {}
	local extrapoints = 0

	for i = 1, #stats do
		lvstats[i] = ((stats[i]*1000) + (level-1)*rates[i])
		if lvstats[i]%1000 >= 500	-- round UP!
			lvstats[i] = $ + 1000
		end

		lvstats[i] = $/1000

		if lvstats[i] > 99	-- Stats can't normally exceed 99 before bonuses
			extrapoints = $ + (lvstats[i] - 99)
			lvstats[i] = 99
		end
	end

	-- Award excess points (> 99) to the lowest stat if this happens
	while extrapoints

		local loweststat = 99
		local lowestindex = 0

		for i = 1, #stats do

			if lvstats[i] < loweststat
				loweststat = lvstats[i]
				lowestindex = i
			end

		end

		-- give points to the lowest stat
		if lowestindex
			lvstats[lowestindex] = $+1
			extrapoints = $-1
		else		-- this means all our stats are already at 99, just break out
			extrapoints = 0
			break
		end

	end

	local bst = lvstats[1] + lvstats[2] + lvstats[3] + lvstats[4] + lvstats[5]

	--print(persona.name.." At Lv"..level..": "..lvstats[1]..", "..lvstats[2]..", "..lvstats[3]..", "..lvstats[4]..", "..lvstats[5].." (BST: "..bst..")")
	return lvstats
end)

-- Sets a player's Persona stats at a given level.
-- This takes equipment into account if 'doweapon' is true

rawset(_G, "PLYR_getStats", function(mo, level, doweapon, dobonus)

	local applyto = {"strength", "magic", "endurance", "agility", "luck"}
	local lvstats = PLYR_getStatsAtLevel(mo.persona, level)

	-- Set stats
	for i = 1, #lvstats
		mo["real"..applyto[i]] = lvstats[i]
		mo[applyto[i]] = lvstats[i]
	end

	-- Apply weapon bonus
	if mo.weapon and doweapon
		mo.strength = max(1, $ + mo.weapon.st)
		mo.magic = max(1, $ + mo.weapon.ma)
		mo.endurance = max(1, $ + mo.weapon.en)
		mo.agility = max(1, $ + mo.weapon.ag)
		mo.luck = max(1, $ + mo.weapon.lu)
	end

	-- Apply bonus stats	(bonusstrength, etc...)
	-- Mostly Void Run exclusive
	for i = 1, #lvstats
		if mo["bonus"..applyto[i]]
			mo[applyto[i]] = $ + mo["bonus"..applyto[i]]
			mo["real"..applyto[i]] = $ + mo["bonus"..applyto[i]]
		end
	end
end)

rawset(_G, "PLYR_initStats", function(mo, persona, skin)
	-- HP/SP
	--dprint("Generating Player entity...")

	mo.baselevel = mo.level
	if not skin then skin = mo.skin end

	local mhp = charStats[skin].basehp + (charStats[skin].basehp*(mo.level-1))/10
	local msp = charStats[skin].basesp + (charStats[skin].basesp*(mo.level-1))/10

	if server.gamemode == GM_VOIDRUN
		mhp = 60 + (mo.level-1)*5
		msp = 0
	end

	mo.maxhp = mhp
	mo.hp = mo.maxhp
	mo.realhp = mo.maxhp
	mo.maxsp = msp
	mo.sp = mo.maxsp
	mo.realsp = mo.maxsp	-- realhp/sp is used for equipment that would give you ""negative"" stats when used.

	mo.dechp = 0
	mo.decsp = 0	-- decimal HP/Sp for leveling up

	local basestats = {persona.strength, persona.magic, persona.endurance, persona.agility, persona.luck}
	local stats = {persona.strength, persona.magic, persona.endurance, persona.agility, persona.luck}
	local applyto = {"strength", "magic", "endurance", "agility", "luck"}
	local applyto2 = {"realstrength", "realmagic", "realendurance", "realagility", "realluck"}

	local bst = 0
	for k,v in ipairs(basestats)
		mo[applyto[k]] = v
		mo[applyto2[k]] = v
		bst = $ + v
	end

	-- Set the player's Persona stats
	PLYR_getStats(mo, mo.level)
end)

rawset(_G, "PLYR_initSkills", function(mo, persona)
	--dprint("Generating Player entity skills...")
	mo.skills = {}
	if server.gamemode == GM_VOIDRUN
		return
	end

	for k,v in ipairs(persona.skills or {})
		if v

			if mo.level >= v[2]
				-- but do we have the skill we need to remove, first?
				for rk, vv in ipairs(mo.skills)
					if vv == v[3]
						--dprint("Removed "..vv)
						table.remove(mo.skills, rk)
					end
				end
				if #mo.skills == 8	-- we have 8 skills, gotta remove one
					mo.toomanyskills = 1
					table.remove(mo.skills, 1)
				end
				-- add skill
				mo.skills[#mo.skills+1] = v[1]
			end
		end
	end

	if mo.toomanyskills and mo.skin
		print("Over 8 skills detected on "..mo.skin..", removing older skills.")
		mo.toomanyskills = nil
	end

	-- autosort skills
	table.sort(mo.skills, attackSortFunc)
end)

rawset(_G, "PLYR_initPersona", function(mo, persona, skin)	-- init stats and skills.
	--dprint("Initiating Player entity Persona...")

	if SAVE_localtable.tutorial and persona == "orpheus"	-- very specific check... kinda hacky
		persona = "orpheus_tutorial"
	end

	persona = personaList[$]

	mo.weak = persona.weak or 0
	mo.block = persona.block or 0
	mo.resist = persona.resist or 0
	mo.drain = persona.drain or 0
	mo.repel = persona.repel or 0

	mo.persona = persona

	PLYR_initStats(mo, persona, skin or mo.skin)
	PLYR_initSkills(mo, persona, skin or mo.skin)
end)

rawset(_G, "PLYR_initAnims", function(mo, skin)
	--dprint("Initiating Player entity animations...")
	local tbl = charStats[skin]
	mo.anim_stand = tbl.anim_stand
	mo.anim_stand_hurt = tbl.anim_stand_hurt
	mo.anim_stand_bored = tbl.anim_stand_bored
	mo.anim_guard = tbl.anim_guard
	mo.anim_move = tbl.anim_move
	mo.anim_run = tbl.anim_run
	mo.anim_atk = tbl.anim_atk
	mo.anim_aoa_end = tbl.anim_aoa_end
	mo.anim_hurt = tbl.anim_hurt
	mo.anim_getdown = tbl.anim_getdown
	mo.anim_downloop = tbl.anim_downloop
	mo.anim_getup = tbl.anim_getup
	mo.anim_death = tbl.anim_death
	mo.anim_revive = tbl.anim_revive
	mo.anim_evoker = tbl.anim_evoker
	mo.anim_evoker_shoot = tbl.anim_evoker_shoot
	mo.anim = 0

	mo.hudcutin = tbl.hudcutin
	mo.hudscutin = tbl.hudscutin
	mo.target_zoffs = tbl.target_zoffs or 0

	for i = 1, 32
		if tbl["anim_special"..i]
			mo["anim_special"..i] = tbl["anim_special"..i]
		else
			mo["anim_special"..i] = {SPR_PLAY, A, 1, "SPR2_STAND"}
		end
	end
end)

rawset(_G, "PLYR_setcontrol", function(mo, player, priority)		-- give bot control to player
	mo.control = player				-- this player is controlling us

	if not mo.control or not mo.control.valid
		return
	end			-- !?

	if priority or not mo.control.maincontrol or not mo.control.maincontrol.valid
		mo.control.maincontrol = mo		-- this is the main entity we're controlling, used for thinkers so we can't have our entire party be AI controlled
	end
	mo.thinker = nil				-- set if we become afk / wish to leave control of OTHER PMs to the computer
	mo.thinkern = 0					-- thinker #, sets the thinker for bots between all of the behaviors available
	mo.savecontrol = player.name	-- save the name of the last player who was controlling us
	player.control = mo				-- let the player know who it's controlling
	player.P_hasjoined = true		-- this is to avoid playerspawn making us take control of another bot somehow.
	player.P_party = mo.party
end)

rawset(_G, "PLYR_updatecontrol", function(mo)
	mo.savecontrol = mo.control.name
	mo.inputs = mo.control.mo.P_inputs

	--if (netgame)
		if mo.control.maincontrol == mo	-- not the best of checks
			mo.name = mo.savecontrol
			if mo.control.mo.skin ~= mo.skin
				R_SetPlayerSkin(mo.control, mo.skin)	-- make sure our real player looks like the character they chose.
				COM_BufInsertText(mo.control, "skin "..mo.skin) -- So the game doesn't try changing them back whenever they change name
			end	-- don't do it every frame
			mo.color = mo.control.mo.color
			mo.displaycontrolname = nil
		else
			mo.displaycontrolname = true
		end
	--end
end)

rawset(_G, "BTL_readybuffs", function(mo)
	mo.buffs = {
		["atk"] = {0, 0},
		["mag"] = {0, 0},
		["def"] = {0, 0},
		["agi"] = {0, 0},
		["crit"] = {0, 0},
		[ATK_SLASH] = {0, 0},
		[ATK_STRIKE] = {0, 0},
		[ATK_PIERCE] = {0, 0},
		[ATK_FIRE] = {0, 0},
		[ATK_ICE] = {0, 0},
		[ATK_WIND] = {0, 0},
		[ATK_ELEC] = {0, 0},
		[ATK_PSY] = {0, 0},
		[ATK_NUCLEAR] = {0, 0},
		[ATK_BLESS] = {0, 0},
		[ATK_CURSE] = {0, 0},
		[ATK_ALMIGHTY] = {0, 0},
	}
end)

-- player levels by difficulty
local difficulty_levels = {
	[1] = 1,	-- beginner
	[2] = 10,	-- easy
	[3] = 20,	-- normal
	[4] = 35,	-- hard
	[5] = 50,	-- spicy
	[6] = 65,	-- risky
	[7]	= 80,	-- nightmare
}

-- attack increase per difficulty:
rawset(_G, "difficulty_atk", {
	[1] = 0,
	[2] = 5,
	[3] = 15,
	[4] = 40,
	[5] = 60,
	[6] = 80,
	[7] = 128,
})

-- defence increase per difficulty:
rawset(_G, "difficulty_def", {

	[1] = 0,
	[2] = 5,
	[3] = 10,
	[4] = 20,
	[5] = 30,
	[6] = 50,
	[7] = 60,
})

-- level cap per difficulty
rawset(_G, "difficulty_cap", {
	[1] = 15,
	[2] = 25,
	[3] = 40,
	[4] = 55,
	[5] = 70,
	[6] = 85,
	[7] = 99,
})

rawset(_G, "PLYR_resetColour", function(mo)
	if mo.control and mo.control.valid and mo.control.mo
		mo.color = mo.control.mo.color
	else
		mo.color = skins[mo.skin].prefcolor
	end
end)

rawset(_G, "PLYR_spawn", function(team)

	server.plentities = {}
	local maxteam = server.P_netstat.teamlen
	for i = 1, 4
		server.plentities[i] = {}
	end

	server.skinlist = team

	for pa = 1, #team
		for i = 1, #team[pa]

			local mo = P_SpawnMobj(0, 0, 0, MT_PFIGHTER)
			mo.commandflags = 0
			mo.skin = team[pa][i] or "sonic"
			mo.state = S_PLAY_STND
			mo.color = skins[mo.skin].prefcolor

			local useskin = mo.skin
			local data

			if not charStats[mo.skin]
				print("\x82".."ERROR: ".."\x80".."Skin \'"..mo.skin.."\' has no charStats. Reverting back to Sonic's stats")
				useskin = "sonic"
			end
			data = charStats[useskin]

			mo.name = data.name or "ERRORNAME"
			mo.level = server.difficulty and difficulty_levels[server.difficulty] or 10	-- for now this is it.
			mo.levelcap = server.difficulty and difficulty_cap[server.difficulty] or 99	-- levelcap 99 by default

			if server.gamemode == GM_PVP
				mo.level = 50
				if server.bossmode
					mo.level = min(99, server.bosslevel-3)
				end
				mo.levelcap = mo.level
				-- eventually, allow this to be set dynamically or smth
			elseif server.gamemode == GM_VOIDRUN
				mo.level = 1
				mo.levelcap = 1
			elseif server.cdungeon	-- custom dungeons
				mo.level = server.cdungeon.level
				mo.levelcap = server.cdungeon.levelcap or mo.level	-- whatever exists
			end

			if server.gamemode == GM_CHALLENGE
				if BTL_challengebtllist[server.P_netstat.buffer.extradata].level
					mo.level = BTL_challengebtllist[server.P_netstat.buffer.extradata].level
				end

				if BTL_challengebtllist[server.P_netstat.buffer.extradata].levelcap
					mo.levelcap = BTL_challengebtllist[server.P_netstat.buffer.extradata].levelcap
				elseif not mo.levelcap
					mo.levelcap = 99
				end	-- default level cap @ 99
			end


			mo.exp = 0-- set EXP
			mo.melee = data.melee_natk

			/*mo.atk = data.atk or 30
			-- increase atk by difficulty factor in multiplayer:
			mo.atk = $+ (difficulty_atk[server.difficulty] or 0)
			mo.acc = data.acc or 85
			mo.crit = data.crit or 3*/

			mo.party = pa	-- keep track of our party #
			mo.battlen = pa	-- this can be initiated at the same time.

			local setpersona = data.persona or "orpheus"
			if server.gamemode == GM_VOIDRUN
				setpersona = "unequipped"
			elseif server.gamemode == GM_PVP -- Allow characters to use PVP-balanced personas
			and not server.bossmode --...only in PVP mode!
				setpersona = data.persona_pvp or $
			end

			PLYR_initPersona(mo, setpersona, useskin)
			PLYR_initAnims(mo, useskin)
			BTL_readybuffs(mo)

			if data.overlay
				local o = P_SpawnMobjFromMobj(mo, 0, 0, 0, data.overlay)
				o.target = mo
				mo.overlay = o
				--dprint("Spawned overlay for skin "..mo.skin)
			end

			local firstvalidp	-- fallback for bots
			local plist = server.playerlist[pa]

			--for k, p in ipairs(plist)
			for j = 1, server.P_netstat.teamlen
				local p = plist[j]
				if p and p.valid and p.mo and p.mo.valid
					firstvalidp = p
					break
				end
			end

			-- control player
			local controlp = (plist[i] and plist[i].valid) and plist[i] or firstvalidp

			dprint("PA #"..pa..": Assigning control of bot "..i.." to "..(controlp and controlp.name or "ERRORNAME"))
			/*if players[i-1]
				PLYR_setcontrol(mo, players[i-1])
			end*/
			PLYR_setcontrol(mo, controlp, plist[i] == controlp)	-- assign control to a player
			mo.plyr = true	-- we are players, not normal enemies.
							-- this is used for summon animation, and enables control by player.
							-- EVEN if the player is in an opposing team!
			mo.coreentity = true
							-- do not remove on battle end, if we happen to be enemies!

			-- uncomment this line and change the test entity to any enemy if you want some fun :P
			/*if i == 2
				mo.enemy = "test_entity"
			end*/
			table.insert(server.plentities[pa], mo)
			mo.flags2 = $|MF2_DONTDRAW
			mo.stats = useskin

			-- EQUIPMENT. Set it last because we need a bunch of stuff first
			-- get weapon name
			local wpn = data.wep
			if not weaponsList[wpn]
				wpn = "generic_01"
			end	-- you never know...

			equipWeapon(mo, makeWeapon(wpn))

			-- for wardring, use basic ring and don't ever enhance it.
			equipRing(mo, makeRing("ring_01"))

			-- buff weapon w/ difficulty
			if server.cdungeon
				-- custom dungeons can have their own buff values:
				mo.weapon.atk = $ + server.cdungeon.weapon_addpow
				mo.wardring.def = $ + server.cdungeon.armour_adddef

			elseif server.difficulty	-- exploration
			and server.gamemode == GM_COOP
				mo.weapon.atk = $ + (difficulty_atk[server.difficulty] or 0)*10
				mo.wardring.def = $ + (difficulty_def[server.difficulty] or 0)*10
			end

			mo.weapon.acc = $ or 95
			mo.weapon.crit = $ or 5


			if server.gamemode == GM_PVP
			and not server.bossmode	-- keep everything the same for boss mode
				mo.sp = $/3
				mo.maxsp = mo.sp
				mo.hp = $*13/10
				mo.maxhp = mo.hp
				-- more HP but less SP, for balance.
			end
		end
	end
end)

-- removes team pn
local function PLYR_removeTeam(pn)

	--if #server.playerlist[pn] -- Can be 0 with players still in the party
	local partysize = server.P_netstat.teamlen
	local pfound
	for j=1, partysize
		if server.playerlist[pn][j] and server.playerlist[pn][j].valid
			pfound = true
			break
		end
	end
	if pfound
		dprint("There are still players in team "..pn..", can't remove it!!")
		return
	end	-- uh are you dumb or something?		

	local i = #server.plentities[pn]
	while i
		local mo = server.plentities[pn][i]
		if mo and mo.valid
			if mo.control and mo.control.valid
				mo.control.control = nil
				mo.control.P_party = 0
			end
			P_RemoveMobj(server.plentities[pn][i])
		end
		i = $-1
	end

	server.plentities[pn] = {}
	server.playerlist[pn] = {}
	dprint("Removed team "..pn)

	local num = 0
	for i=1, 4
		local plist = server.playerlist[i]
		for j=1, partysize
			if plist[j] and plist[j].valid
				num = $+1
				break -- There's a player in this party, on to the next one
			end
		end
	end

	if num
		if partysize
			COM_BufInsertText(server, "maxplayers "..(num*partysize))
		else
			COM_BufInsertText(server, "maxplayers "..(num*4))
		end
	end

	if num == 0 or (num < 2 and server.gamemode == GM_PVP) -- Only one party left, back to the lobby
		SRB2P_killHUD()
		SYS_closeMenu()
		COM_ImmedExecute("map "..G_BuildMapName(srb2p.tartarus_map))
	end
end

-- removes entity k from team n
-- DO NOT USE THIS IN NETGAMES !!!!

rawset(_G, "PLYR_RemoveFromParty", function(n, k)

	local team = server.plentities[n]
	if not team or not #team return end	--!?

	local mo = team[k]
	if not mo or not mo.valid
		print("Trying to remove invalid entity "..k.." in team "..n)
		return
	end

	table.remove(team, k)	-- pop from table
	P_RemoveMobj(mo)

	-- iterate through the corresponding playerlist to fix missing stuff.
	for i = 1, #server.playerlist[n]
		local p = server.playerlist[n][i]
		if p and p.control and not p.control.valid
			p.control = team[k] or team[1]	-- fallback
		end
	end
end)

addHook("MapLoad", do

	-- spawn our party at mapload.
	-- @TODO: Maybe move this into its own dedicated function to have a bit more power on it, though the current behaviour is suitable.

	-- actual spawning code:

	-- setup parties:
	if not server return end
	server.plentities = {}
	for i = 1, 4
		server.plentities[i] = {}
	end

	-- initiate the singleplayer party.
	-- this only runs if netstat never ran prior to this.
	if not server.P_netstat
	and SAVE_localtable
	and SAVE_localtable.party
	and not netgame	-- don't even begin to try to load this in netgames
		NET_setteam(SAVE_localtable.party)
		dprint("Setting party from local data")
	end

	if server.skinlist and #server.skinlist
		PLYR_spawn(server.skinlist)
		for p in players.iterate do

			if not p.P_party or not p.maincontrol
			--or 1	-- test
				p.P_spectator = true	-- "spectator"
			end
		end
	end
end)

local function PLYR_checkforPlayer(mo)		-- check if whoever is controlling 'mo' is still in the game, update our controller / data accordingly.
	if not mo or not mo.valid return end	-- you never know.

	if not mo.plyr return end		-- we're not a player, so it doesn't matter lol
	if not mo.control return end	-- no one was controlling us to begin with.
	if not netgame return end		-- nobody cares, no one will be leaving there
	if not server.P_netstat return end
	if not server.P_netstat.teamlen return end
	local plist = server.playerlist[mo.party]
	local twopset

	local header = "PN "..mo.party..": "

	if mo.control and mo.control.valid
		PLYR_updatecontrol(mo)				-- update our info
	else	-- !!
		for i = 1, server.P_netstat.teamlen
			if plist[i]
			and not plist[i].valid
				plist[i] = nil
				dprint(header.."Removed index "..i.." from partytable")
			end
		end
	end

	-- scan for players that should be controlling us instead of whoever's in charge now
	local seek	-- seek our index in the party
	--for i = 1, #server.plentities[mo.party] do
	for i = 1, server.P_netstat.teamlen do
		if server.plentities[mo.party][i] == mo
			seek = i
			break
		end
	end

	if not seek return end

	-- okay, very, VERY special case...
	-- if we only have 2 players, then even bots should be controlled by p2 and not p1, make control split even~

	local count = 0
	local botcount = 0
	local firstp
	local lastp
	local evenbot
	local oddbot
	--for k,p in ipairs(plist) do
	for i = 1, server.P_netstat.teamlen do	-- always count with teamlen!!!
		local p = server.playerlist[mo.party][i]
		local pmo = server.plentities[mo.party][i]
		if p and p.valid and p.P_party == mo.party
			count = $+1
			firstp = $ or p
			lastp = p
		else
			if pmo
				botcount = $+1
				if mo == pmo
					if (botcount%2) == 0
						evenbot = true
					else
						oddbot = true
					end
				end
			end
		end
	end

	if count == 2
	and (evenbot or oddbot)
		twopset = true
	end

	if twopset	-- exactly 2 players;
		if evenbot	-- We're an even bot
		and mo.control ~= lastp and lastp.maincontrol -- Make sure player 2 has maincontrol first
			PLYR_setcontrol(mo, lastp)
		elseif oddbot	-- We're an odd bot
		and mo.control ~= firstp and firstp.maincontrol -- Make sure "player 1" has maincontrol first
			PLYR_setcontrol(mo, firstp)
		end
	end

	if plist[seek] and plist[seek].valid and (not mo.control or not mo.control.valid or mo.control.maincontrol ~= mo)
	and not twopset
		dprint(header.."Updated bot "..(seek).."'s controls to "..plist[seek].name)
		--mo.control = players[seek]
		PLYR_setcontrol(mo, plist[seek])
	end

	if not mo.control.valid					-- mysterious!
		mo.control = nil			-- go back to being a good bot

		if not (firstp and firstp.valid)	-- ....player 1 from our team left as well!?
			-- remove everyone from this team;
			dprint(header.."No one left in party "..mo.party..", removing this party.")
			PLYR_removeTeam(mo.party)
			return
		end

		PLYR_setcontrol(mo, firstp)
		dprint(header.."Reverted bot "..(seek).."'s controls to party leader")
	end
end
addHook("MobjThinker", PLYR_checkforPlayer, MT_PFIGHTER)

-- get players to take control of bots!
-- DEPRECATED, but keeping around in case it ever ends up being useful again...
local function PLYR_checkjoincontrol(p)
	if p.P_spectator return end	-- no.
	if not server.plentities return end
	if not (server.plentities[1]
	or server.plentities[2]
	or server.plentities[3]
	or server.plentities[4]) return end	-- no bots in the game. skip.
	if not (#server.plentities[1]
	or #server.plentities[2]
	or #server.plentities[3]
	or #server.plentities[4]) return end
	if p.P_party return end			-- player shouldn't have had respawned in the first goddamn place.

	-- check which party has the least players:
	local spacesfree = 0
	local partytojoin = 0
	local nameindex	-- if we find a bot with our exact name (rejoining?)

	for i = 1, 4
		local pa = server.playerlist[i]
		local plentities = server.plentities[i] -- Using server.P_netstat.teamlen breaks joins during boss mode
		local partysize = #plentities

		local count = 0
		for j = 1, partysize
			if pa[j] and pa[j].valid
				count = $+1
			else
				-- scan for the actual bot team, if they have a bot with YOUR player name, it means you're rejoining
				if server.plentities[i][j]
				and server.plentities[i][j].name == p.name
					-- it's impossible for 2 players to have the same name, so we don't need to check for that.
					partytojoin = i
					nameindex = j
					break -- No point checking the other players
				end
			end
		end
		if nameindex then break end -- No point checking the other parties
		if not count	-- this party has NO players.
		or count >= partysize	-- full
			continue	-- don't try
		end

		if (partysize - count) > spacesfree
			partytojoin = i
			spacesfree = partysize - count
		end
	end

	if partytojoin
		dprint("Affected "..p.name.." to party "..partytojoin)

		-- if anyone from that party is inside a battle's plist, add us to it as well...!
		local pa = server.playerlist[partytojoin]
		local plentities = server.plentities[partytojoin]
		local partysize = #plentities
		for i=1, partysize
			if pa[i] and pa[i].valid and pa[i].control and pa[i].control.valid and pa[i].control.battlen
			and server.P_BattleStatus[pa[i].control.battlen].running
				table.insert(server.P_BattleStatus[pa[i].control.battlen].plist, p)
				dprint("Affected "..p.name.." to running battle "..pa[i].control.battlen)
				break
			end
		end

		-- on the player list we just joined, check if the boss was cleared to give ourselevs that flag as well:
		-- (otherwise we'd be able to trigger the boss as well... oops?)
		for i=1, partysize
			if pa[i] and pa[i].valid and pa[i].mo and pa[i].mo.valid and pa[i].mo.eventclear
				p.mo.eventclear = true
				break
			end
		end

		p.P_party = partytojoin

		if nameindex	-- I got somewhere to be!
			-- it's impossible for 2 players to have the same name
			local pa = server.playerlist[partytojoin]
			pa[nameindex] = p

		else	-- take the first free spot

			for i = 1, partysize
				if not (server.playerlist[partytojoin][i] and server.playerlist[partytojoin][i].valid)
					server.playerlist[partytojoin][i] = p

					return true
				end
			end
		end
	end
end


local function any_valid_player(t)
	for i = 1, server.P_netstat.teamlen
		if t[i] and t[i].valid
			return t[i]
		end	
	end
	return nil
end

-- automatically assign players unaffiliated to a party as a spectator.
rawset(_G, "PLYR_assignSpectator", function(p)
	if p.P_spectator return end	-- no.
	if not server.plentities return end
	if not server.P_netstat.teamlen return end
	
	local allinvalid = true
	for i = 1, 4 do
		if any_valid_player(server.plentities[i])
			allinvalid = false
			break
		end	
	end
	
	if allinvalid return end

	if not p.P_party
		p.P_spectator = true
	end
end)

addHook("ThinkFrame", do
	for p in players.iterate do
		PLYR_assignSpectator(p)
	end
end)

-- spectator player is joining the game and is going to take control of entity
rawset(_G, "PLYR_spectatorJoinGame", function(player, partyn, slotn)

	if not partyn or not slotn return end
	if not player.P_spectator return end	-- player is not a spectator anymore.

	local entity = server.plentities[partyn][slotn]
	if not entity or not entity.valid
		print("Attempt to take control of invalid entity at "..partyn..", "..slotn)
		return
	end
	if entity.control and entity.control.maincontrol == entity
		print("Attempt to take control of entity "..partyn..", "..slotn.." already controlled by "..entity.control.name)
		return
	end

	player.P_spectator = nil
	player.P_party = partyn

	PLYR_setcontrol(entity, player, true)

	-- now add ourselves to the tables...
	server.playerlist[partyn][slotn] = player

	-- finally, dungeon stuff...
	-- teleport me to my party leader:
	local pslot = 1
	local anotherplayer = server.playerlist[partyn][pslot]
	-- it's impossible to have joined this party as the only player so we won't bother checking for bounds.
	while (anotherplayer == player or not anotherplayer)
		anotherplayer = server.playerlist[partyn][pslot]
		pslot = $+1
	end

	P_TeleportMove(player.mo, anotherplayer.mo.x, anotherplayer.mo.y, anotherplayer.mo.z)
	player.powers[pw_flashing] = TICRATE*3 -1
	player.mo.colorized = false			-- remove colorization
	player.mo.frame = $ & ~FF_TRANSMASK	-- remove translucency
	player.charability = skins[player.mo.skin].ability	-- give ability back.

	-- if we just joined mid battle, make sure to reflect that too...
	-- get battlen first...
	local battlen = server.plentities[partyn][1].battlen or partyn
	local btl = server.P_BattleStatus[battlen]
	if btl.running
		PLAY_nomove(player)
		btl.plist[#btl.plist+1] = player	-- affect ourselves to the battle plist (this will set the camera etc for us)
	end

	chatprint("\x82".."*"..player.name.." has joined party "..partyn)
end)

rawset(_G, "PLYR_reset", function(pn)	-- reset all battle related variables for all players

	if not server.plentities or not #server.plentities return end
	if not server.plentities[pn] or not #server.plentities[pn] return end

	for i = 1, #server.plentities[pn]
		local mo = server.plentities[pn][i]
		-- battles shouldn't end when such variables aren't unset to begin with.

		-- action
		mo.t_act = ACT_NONE
		mo.t_selectslide = 0
		mo.attack = BTL_setAttack(mo, attackDefs[charStats[mo.stats].melee_natk])
		mo.t_target = 1

		mo.hp = max($, 1)
		mo.redhp = mo.hp

		mo.guard = nil

		-- pre turn stuff
		mo.onemore = nil
		mo.setonemore = nil
		mo.batontouch = nil
		mo.down = nil

		-- endure skills:
		mo.endure = 0

		-- barriers:
		mo.makarakarn = nil
		mo.tetrakarn = nil
		mo.tetraja = nil

		-- buffs:
		mo.mindcharge = nil
		mo.powercharge = nil

		-- shuffle time penalty
		mo.penalty = nil
		BTL_readybuffs(mo)

		-- damage stuff
		mo.damageflags = 0
		mo.damaged = nil
		mo.damaged_wait = nil
		mo.damagetaken = nil

		-- position stuff
		mo.defaultcoords = nil

		-- linkstate stuff
		mo.linkstate = nil
	end
end)

COM_AddCommand("p_listplayers", function(p, arg)
	local arg = tonumber(arg)
	if not arg return end

	if not server.P_netstat
		CONS_Printf(p, "No net state initialized")
		return
	end

	if not server.playerlist or not #server.playerlist
		CONS_Printf(p, "Playerlist uninitialized")
		return
	end

	if not server.playerlist[arg]
		CONS_Printf(p, "Invalid team number")
		return
	end

	local party = server.playerlist[arg]

	CONS_Printf(p, "Dump for playerlist "..arg)

	for i = 1, server.P_netstat.teamlen
		local tp = server.playerlist[arg][i]

		local name = server.playerlist[arg][i] and server.playerlist[arg][i].name or "\x86".."--- EMPTY ---"
		CONS_Printf(p, i..": "..name)
	end

	CONS_Printf(p, "Dump for plentities "..arg)

	for i = 1, server.P_netstat.teamlen
		local mo = server.plentities[arg][i]

		if not mo
			CONS_Printf(p, "Empty")
			return
		end

		local name = mo.control and mo.control.name or "\x85".."ERROR!"
		if mo.control and mo.control.maincontrol == mo
			name = "\x82"..name
		end

		CONS_Printf(p, "BOT #"..i.." ("..mo.name.."): "..name)
	end
end)

