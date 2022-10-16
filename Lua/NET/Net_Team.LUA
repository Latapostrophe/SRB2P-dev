-- NOW LOOK AT THIS NET THAT I JUST FOUND
-- WHEN I SAY GO, BE READY TO SYNCH
-- GO!
-- SYNCH IT IN, NOT OUT!
-- In memory of Robbie Rotten

local netstates = {
	"NET_TEAMSELECT",
	"NET_SKINSELECT",
	"NET_PVP_SKINSELECT",
	"NET_PVP_TEAMSELECT",
	"NET_LOAD",
}

for i = 1, #netstates
	rawset(_G, netstates[i], i-1)
end

-- In this script, we deal with the building of our party in multiplayer games

-- begin net selection

local function NET_exitready(n)
	G_SetCustomExitVars(n, 1)
end

rawset(_G, "NET_isset", function()
	return server and server.plentities and #server.plentities and server.skinlist and server.P_netstat and server.P_netstat.ready and not server.P_netstat.running or not netgame
end)

rawset(_G, "NET_begin", function(state)

	if not server return end
	COM_BufInsertText(server, "rejointimeout 0")

	server.P_netset = true	-- prevents other scripts from running
	server.plentities = {}
	server.playerlist = {}

	for p in players.iterate
		p.tempboss = nil
	end

	-- setup teams:
	for i = 1, 4
		server.plentities[i] = {}
		server.playerlist[i] = {}
	end

	--print("Beginning network status at state "..(state or 1))

	-- change to tartarus f1 music regardless
	--S_ChangeMusic(1)

	server.P_netstat = {
		running = true,
		netstate = state or NET_TEAMSELECT,
		spectators = {},	-- spectator players
		leaders = {},	-- players leading the teams, p1 will always lead one, everyone else will be chosen arbitrarily
		playerlist = {},
		teamlen = 4,
		skinlist = {},	-- keep track of what skins to use.
		ready = false,
		buffer = 	{
						-- buffer information relative to what we must do once characters have been set
						-- if this buffer is nil / not set, nothing will happen and netstat won't end
						gamemode = 1,
						extradata = 1,
						map = 1,
					}

	}

	for i = 1, 4
		server.P_netstat.skinlist[i] = {}
		server.P_netstat.playerlist[i] = {}
	end

	-- reset PLAYER stuff
	for p in players.iterate do
		local mo = p.mo
		if not mo or not mo.valid continue end

		p.P_party = 0				-- which team are we on?
		p.P_teamleader = nil		-- is team leader
		p.tempboss = nil			-- you never know
		p.bossselect = nil
		p.confirmboss = nil
		server.bosslevel = nil

		-- team related options
		mo.P_net_teamstate = 0
		mo.P_net_spectate = nil
		mo.P_net_teamchoice = 1
		mo.P_net_createparty = nil

		mo.P_net_skinselect = nil	-- skin selected. Set it to nil so that it's initialized to our current skin
		mo.P_net_menu = 0			-- menus are only either yes/no
		mo.P_net_menuanim = 0		-- used for short animations
		mo.P_net_selectindex = 1	-- ...who are we selecting?
		-- P_inputs already works by default so we're good
	end

	-- bossmode
	-- THERES PROBABLY A MUCH EASIER WAY OF DOING THIS
	-- IF ANYONE SEES THIS, PLEASE TRY TO CORRECT MY HALVED BRAINCELL
	--                                     - Spectra

	if (server.bossmode)
		local count = 0
		for p in players.iterate
			count = $+1
		end

		server.bosscount = 1
		-- prepare a list of bosses:
		server.bosslist = {}
		for k,v in pairs(enemyList)
			if (v.boss or v.endboss or v.finalboss)
			and k ~= "batkan" and k ~= "alt"	-- there are pvp exlcusive versions of these which work betetr
			and not v.nopvp
				server.bosslist[#server.bosslist+1] = k
			end
		end

		table.sort(server.bosslist, function(a, b)
			local enm1 = enemyList[a]
			local enm2 = enemyList[b]

			return enm1.level < enm2.level

		end)
		server.bosslist[#server.bosslist+1] = nil

		for i = 1, server.bosscount
			local boss = players[P_RandomRange(1, count)-1]
			boss.tempboss = true
		end

		local lead = false
		for p in players.iterate
			local mo = p.mo
			if not mo or not mo.valid continue end

			if p.tempboss
				table.insert(server.plentities[2], p)
				table.insert(server.playerlist[2], p)
				table.insert(server.P_netstat.skinlist[2], p.mo.skin)
				table.insert(server.P_netstat.playerlist[2], p)
				mo.P_net_selectindex = 1
				-- boss stuff is set in stone
			else
				--table.insert(server.plentities[1], p)
				--table.insert(server.playerlist[1], p)
				table.insert(server.P_netstat.skinlist[1], p.mo.skin)
				table.insert(server.P_netstat.playerlist[1], p)
				mo.P_net_selectindex = #server.P_netstat.skinlist[1]	-- skin selection index
			end
			mo.P_net_teamstate = 2	-- consider the party joined

			if p.tempboss
				p.P_party = 2
				p.P_teamleader = true
			else
				p.P_party = 1
				if lead == false
					p.P_teamleader = true
					lead = true
				end
			end
		end

		server.P_netstat.buffer.map = srb2p.colosseo_map
		server.P_netstat.buffer.gamemode = GM_PVP
		server.P_netstat.buffer.extradata = PVP_BOSSMODE
		server.P_netstat.buffer.maxparties = 2
		--NET_startgame()
	end
end)

-- reset net stat, used at the end of multiplayer sessions or when returning to the tartarus lobby:
rawset(_G, "NET_reset", function()
	server.P_netstat = {}
	server.plentities = {}
	server.playerlit = {}
	server.skinlist = {}
	for p in players.iterate
		if p.mo and p.mo.valid
			p.mo.P_net_ready = false
		end
	end
end)

-- end net selection, doesn't remove it however:
rawset(_G, "NET_end", function(cancel)
	if not cancel
		server.P_netstat.ready = true	-- should already be set but just in case...
	else
		NET_begin()	-- this resets a handful of player variables
		NET_reset()	-- this resets every server P_netstat variable
	end
	server.P_netstat.running = false
end)

-- sets a team for use in singleplayer.
-- technically yes, that means net functions need to run
-- this is only used once when loading a fresh new singleplayer game to load everything properly.

rawset(_G, "NET_setteam", function(tab)
	NET_begin()
	server.skinlist = {tab}
	server.plentities[1] = tab
	server.playerlist[1] = {server, server, server, server}
	NET_end()
	server.P_netstat.ready = true

	-- force the server to be the first skin here:
	R_SetPlayerSkin(server, tab[1])
	if not server.mo return end	-- !?
	server.color = skins[server.mo.skin].prefcolor
end)

-- check if net shit is running:
rawset(_G, "NET_running", function()
	return server and server.P_netstat and server.P_netstat.running
end)


rawset(_G, "NET_setstate", function(state)
	if NET_running()
		local net = server.P_netstat
		net.netstate = state
	end
end)

addHook("MapLoad", do
	if gamemap == srb2p.tartarus_map
		COM_BufInsertText(server, "maxplayers 16")
		
		for p in players.iterate do
			local mo = p.mo
			p.P_spectator = nil
			if p.mo
				p.mo.colorized = false	-- uh yeah specs do that...
				M_closeMenu(p.mo)
			end	
		end
	end
end)

rawset(_G, "NET_startgame", function()

	-- special case; LOADING.
	-- if we're loading a game, we can potentially have empty parties.
	-- ...remove them, and apply the changes to the loaded save file. (doesn't modify the actual file on-disk, only in memory)
	if server.P_netstat.buffer.load
		print("File loading corrections in progress....")
		local emptyparties = {}
		for i = 1, #server.P_netstat.playerlist
			local found
			for j = 1, server.P_netstat.teamlen do
				if server.P_netstat.playerlist[i][j]
				and server.P_netstat.playerlist[i][j].valid
					found = true
					break
				end
			end

			if not found
				emptyparties[#emptyparties+1] = i
			end
		end

		if #emptyparties
			-- act upon empty parties
			-- what we'll do is simply remove these parties from the list and the save file. that's about it.
			local i = #emptyparties
			local file = server.netgamefile

			while i
				local r = emptyparties[i]
				-- remove from netstat
				table.remove(server.P_netstat.playerlist, r)
				table.remove(server.P_netstat.skinlist, r)
				-- remove from file
				table.remove(file.playerlist, r)
				table.remove(file.battle, r)
				i = $-1
			end

			for i = 1, 4
				-- this table can't be empty.
				-- add empty tables on the last indexes after we performed the removal
				server.P_netstat.playerlist[i] = $ or {}
			end

		end
	end

	server.playerlist = server.P_netstat.playerlist
	-- ^ this is maintained each frame from now on

	-- ultimatum: Check skinlist:
	local num = 0
	for i = 1, 4

		local findp
		for j = 1, server.P_netstat.teamlen
			if server.playerlist[i][j] and server.playerlist[i][j].valid
				findp = server.playerlist[i][j]
				break
			end
		end


		if not findp or not findp.valid
			if #server.playerlist[i]
				print("\x82".."NET_startgame / FATAL: ".."\x80".."No player in team "..i..", P_netstat will be reset.")
				NET_end(true)
				return
			else
				continue
			end
		else
			num = $+1
		end
	end

	PLYR_spawn(server.P_netstat.skinlist)
	server.P_netstat.ready = true	-- ready to play

	local buf = server.P_netstat.buffer

	if not buf return end

	-- depending on buffer info, do some stuff
	server.gamemode = buf.gamemode	-- cool
	if num
		if server.bossmode	-- Always two teams, and one is the boss
			COM_BufInsertText(server, "maxplayers "..(server.P_netstat.teamlen+1))
		else
			COM_BufInsertText(server, "maxplayers "..(num*server.P_netstat.teamlen))
		end
	end

	server.difficulty = 1	-- default

	if server.gamemode == GM_COOP	-- extradata = difficulty
		server.difficulty = buf.extradata
	elseif server.gamemode == GM_PVP
		server.pvpmode = buf.extradata
	end

	if server.roguemode
		ROGUE_reset()
		if not server.rogueseed
			server.rogueseed = max(1, P_RandomFixed())
		end
		-- Initialize rogue mode seed, unless it's already set (file loading)
	end

	if buf.map
		NET_exitready(buf.map)
		G_ExitLevel()
	end

	NET_end()
end)


-- do net loading
local function NET_load()
	local net = server.P_netstat
	local plist = net.playerlist
	local h = server.netgamefile
	local skinlist = h.playerlist
	local nteams = 0

	for i = 1, #skinlist
		if skinlist[i] and #skinlist[i]
			nteams = $+1
			for j = 1, #skinlist[i]
				net.skinlist[i][j] = skinlist[i][j].skin
			end
		end
	end

	-- count how many players are ready
	local count = 0
	local ready = 0
	for p in players.iterate do
		if not p.mo continue end
		count = $+1
		if p.mo.P_net_ready
			ready = $+1
		end
	end

	local allready = ready >= count

	for p in players.iterate do

		PLAY_nomove(p)

		local mo = p.mo
		if not mo return end
		local inpt = mo.P_inputs

		mo.P_net_skinselect = $ or 0

		-- get our position on the fake """grid"""
		local hpos = (mo.P_net_skinselect / h.teamlen)+1
		local vpos = (mo.P_net_skinselect % h.teamlen)+1

		if inpt["down"] == 1
		and not mo.P_net_ready
			S_StartSound(nil, sfx_hover, p)
			if vpos < h.teamlen
				mo.P_net_skinselect = $+1
			else
				mo.P_net_skinselect = $ - (h.teamlen-1)
			end

		elseif inpt["up"] == 1
		and not mo.P_net_ready
			S_StartSound(nil, sfx_hover, p)
			if vpos > 1
				mo.P_net_skinselect = $-1
			else
				mo.P_net_skinselect = $ + (h.teamlen-1)
			end

		elseif inpt["left"] == 1
		and nteams > 1
		and not mo.P_net_ready
			S_StartSound(nil, sfx_hover, p)
			if hpos > 1
				mo.P_net_skinselect = $-(h.teamlen)
			else
				mo.P_net_skinselect = $ + (h.teamlen)*(nteams-1)
			end

		elseif inpt["right"] == 1
		and nteams > 1
		and not mo.P_net_ready
			S_StartSound(nil, sfx_hover, p)
			if hpos < nteams
				mo.P_net_skinselect = $+(h.teamlen)
			else
				mo.P_net_skinselect = $ - (h.teamlen)*(nteams-1)
			end
		elseif inpt[BT_BTNA] == 1
			if not mo.P_net_ready

				-- check if there's already someone in that spot
				if plist[hpos][vpos] and plist[hpos][vpos].valid	-- and they're valid...
					S_StartSound(nil, sfx_not, p)	-- nop
					continue
				end

				-- otherwise, apply!
				plist[hpos][vpos] = p
				mo.P_net_ready = true
				S_StartSound(nil, sfx_select, p)

			elseif p == server
			and allready
				NET_startgame()
			end

		elseif inpt[BT_BTNB] == 1

			if mo.P_net_ready	-- undo your selection
				plist[hpos][vpos] = nil
				mo.P_net_ready = nil
				S_StartSound(nil, sfx_cancel, p)
			elseif p == server	-- not cancelling ready status and server? you end the selection.
				NET_end(true)	-- cancel net selection
			end
		end
	end
end

local function NET_team_bossselect(p)
	local bosses = server.bosslist
	local mo = p.mo
	local inpt = mo.P_inputs

	p.bossselect = $ or #bosses

	-- the launch prompt:
	if mo.P_net_launchprompt
		if inpt[BT_JUMP] == 1	-- yeah let's go
			-- this is where we begin the game
			NET_startgame()
		end
		return
	end

	if not p.confirmboss

		if inpt["left"] == 1
			S_StartSound(nil, sfx_turn, p)
			p.bossselect = $-1
			if p.bossselect < 1
				p.bossselect = #bosses
			end

		elseif inpt["right"] == 1
			S_StartSound(nil, sfx_turn, p)
			p.bossselect = $+1
			if p.bossselect > #bosses
				p.bossselect = 1
			end

		elseif inpt[BT_BTNA] == 1
			S_StartSound(nil, sfx_confir, p)
			p.confirmboss = 1
		end
	elseif p.confirmboss == 1	-- prompt confirmation

		if inpt[BT_BTNA] == 1
			mo.P_net_ready = true	-- we good
			S_StartSound(nil, sfx_confir, p)
			server.bosslevel = enemyList[bosses[p.bossselect]].pvplevel or enemyList[bosses[p.bossselect]].level
			p.confirmboss = 2
		elseif inpt[BT_BTNB] == 1
			S_StartSound(nil, sfx_cancel, p)
			p.confirmboss = nil
		end
	end

end

local function NET_team_skinselect(p)
	local net = server.P_netstat
	local minskin = 0
	local maxskin = 0
	for i = 0, 31
		if skins[i] and skins[i].valid
			maxskin = i
		else
			break	-- skins are a normal list, so as soon as one is invalid, all the others are too
		end
	end

	if not net.buffer then return end	-- net.buffer can be nil
	local nostack = net.buffer.nostack	-- No stacking skins!
	--print(nostack)


	local mo = p.mo
	if not mo return end

	local inpt = mo.P_inputs
	if not net.playerlist then return end
	local party = net.playerlist[p.P_party]

	-- figure out where in the party i am
	local myindex
	for i = 1, #party
		if party[i] == p
			myindex = i
			break
		end
	end

	mo.P_net_selectindex = $ or myindex

	if mo.P_net_skinselect == nil
		for i = 0, 31 do
			if skins[i].name == mo.skin
				mo.P_net_skinselect = i
				break
			end
		end
	end
	mo.P_net_skinselect = $ or 0

	-- check if we're trying to select a skin a player is going to take:
	local ind = mo.P_net_selectindex
	if party[ind] and party[ind].valid and party[ind] ~= p	-- no we don't count lol
		-- try to find a skin to set, otherwise ready up
		for i = mo.P_net_selectindex+1, net.teamlen
			if i > net.teamlen
				break
			end

			if not party[i]
				mo.P_net_selectindex = i
				dprint("Now setting skin "..i)
				break
			end
		end

		if mo.P_net_selectindex == ind	-- yikes!
			mo.P_net_ready = true
		end
	end

	-- the launch prompt:
	if mo.P_net_launchprompt
		if inpt[BT_JUMP] == 1	-- yeah let's go
			-- this is where we begin the game
			NET_startgame()
			return
		end
		-- pressing BT_USE will undo our last skin selection as expected, handled in the code below :P
	end

	-- handle skin selection

	if inpt["left"] == 1
		mo.P_net_skinselect = $-1
		S_StartSound(nil, sfx_hover, p)

		if mo.P_net_skinselect < 0
			mo.P_net_skinselect = maxskin
		end

		while (not P_netUnlockedCharacter(mo.player, skins[mo.P_net_skinselect].name))
			mo.P_net_skinselect = $-1

			if mo.P_net_skinselect < 0
				mo.P_net_skinselect = maxskin
			end
		end

	elseif inpt["right"] == 1
		mo.P_net_skinselect = $+1
		S_StartSound(nil, sfx_hover, p)

		if mo.P_net_skinselect > maxskin
			mo.P_net_skinselect = 0
		end

		while (not P_netUnlockedCharacter(mo.player, skins[mo.P_net_skinselect].name))
			mo.P_net_skinselect = $+1

			if mo.P_net_skinselect > maxskin
				mo.P_net_skinselect = 0
			end
		end

	elseif inpt[BT_JUMP] == 1
	and not mo.P_net_ready

		-- check if this skin CAN be selected:
		local s = skins[mo.P_net_skinselect].name

		if nostack
			for i = 1, 4
				if net.skinlist[p.P_party][i] == s
					S_StartSound(nil, sfx_not, p)
					return
					-- No skin stacking if this is on!
				end
			end
		end

		-- lock on to this skin:

		if not p.P_teamleader or mo.P_net_selectindex >= net.teamlen
			mo.P_net_ready = true
		end

		net.skinlist[p.P_party][mo.P_net_selectindex] = s
		S_StartSound(nil, sfx_confir, p)

		if p.P_teamleader
			-- do we need to check another skin......??
			for i = mo.P_net_selectindex+1, net.teamlen+1
				if i > net.teamlen
					mo.P_net_ready = true	-- then there's nothing to set, huh!
					dprint("Partyleader ready")
					break
				end


				if not party[i]
					mo.P_net_selectindex = i
					dprint("Now setting skin "..i)
					break
				end
			end
		end

	elseif inpt[BT_USE] == 1
	and (p.P_teamleader or mo.P_net_ready)

		if mo.P_net_ready
			mo.P_net_ready = nil
			mo.P_net_launchprompt = nil
			S_StartSound(nil, sfx_cancel, p)
			net.skinlist[p.P_party][mo.P_net_selectindex] = nil
			return
		end

		-- can we go back?
		local goback = mo.P_net_selectindex
		if goback <= 1
			if p.P_teamleader and p.P_party == 1
				NET_end(true)
			end
			return
		end

		if p.P_teamleader
			goback = $-1
		end

		while goback

			if not party[goback]
			or party[goback] == p	-- yeah it's fine if it's moi~
				net.skinlist[p.P_party][mo.P_net_selectindex] = nil
				net.skinlist[p.P_party][goback] = nil
 				mo.P_net_selectindex = goback
				S_StartSound(nil, sfx_cancel, p)
				return
			end
			goback = $-1
		end
		S_StartSound(nil, sfx_not, p)
	end
end


local function NET_teamselect()
	local nump = 0
	local ready = 0
	local inparty_orready = 0
	local validpnums = {}
	local netstat = server.P_netstat
	local firstp
	local minparties = netstat.buffer.minparties or 1

	local count = 0

	for p in players.iterate do
		if p.mo and p.mo.valid

			count = $+1

			firstp = $ or p

			PLAY_nomove(p)	-- disable cmd
			nump = $+1

			if not p.P_party
				validpnums[#validpnums+1] = #p
			end

			if p.mo.P_net_ready
				ready = $+1
				inparty_orready = $+1
			elseif p.P_party
				inparty_orready = $+1
			end
		end
	end

	-- Cancel as well if we don't have enough players left to satisfy the party requirements somehow
	local unreadyplayers = nump - inparty_orready
	local neededparties = minparties - #netstat.leaders	-- <= 0 if all the needed parties are already made.

	-- in short, if unreadyplayers <= neededparties, we can't become a party member
	if unreadyplayers < neededparties
	and not server.bossmode
		chatprint("\x82".."*Not enough unready players to satisfy party count requirements!")
		NET_end(true)
		return
	end

	if ready >= nump	-- everyone is ready
		firstp.mo.P_net_launchprompt = true
	else	-- dynamically check for new joiners
		firstp.mo.P_net_launchprompt = nil
	end

	-- determine how many leaders we NEED (we COULD have more than that.)
	local numteams
	local gamemode = netstat.buffer.gamemode

	if gamemode == GM_PVP
		-- how many players per team do we allow...?
		server.P_netstat.teamlen = 4 -- nump/2 + (nump%2 and 1 or 0)	-- split players in half (add 1 for .5 player ofc)
		numteams = 2	-- always.

		if nump > 8	-- there is an issue (for now.)
			return
		end
	else
		numteams = nump/4 +((nump%4) and 1 or 0)
	end

	if server.bossmode
		numteams = 0	-- leaders are automatically assigned
	end

	/*while numteams
		if netstat.leaders[numteams]
		and netstat.leaders[numteams].valid
			-- avoid validity errors...
		else

			dprint("Assigning leader for team "..numteams)

			if numteams == 1	-- p1 takes the spot, always
				netstat.leaders[numteams] = players[validpnums[1]]
				-- we needn't worry about removing that one
			else
				local k = P_RandomRange(1, #validpnums)
				netstat.leaders[numteams] = players[validpnums[k]]
				table.remove(validpnums, k)	-- don't make this player the leader of 2 teams obv
			end
			server.P_netstat.leaders[numteams].P_teamleader = true	-- set as team leader (mostly used as reference for the game)
			server.P_netstat.leaders[numteams].P_party = numteams	-- assign to party
			server.P_netstat.playerlist[numteams][1] = server.P_netstat.leaders[numteams]
			server.P_netstat.leaders[numteams].mo.P_net_selectindex = 1
			chatprint("\x82*"..netstat.leaders[numteams].name.." was assigned leader of team "..numteams)
		end

		numteams = $-1
	end*/
	-- technically speaking, if there's only one team we don't need this screen at all!

	-- party cleansing etc:
	for i = 1, #server.P_netstat.playerlist
		local j = #server.P_netstat.playerlist[i]

		while j
			if not (server.P_netstat.playerlist[i][j] and server.P_netstat.playerlist[i][j].valid)
				table.remove(server.P_netstat.playerlist[i], j)
				-- if the leader is invalid for this team, cleanse the skin data from it as well.
				server.skinlist[i] = {}
				-- all players from this team should be made un-ready as well.
				for k = 1, #server.P_netstat.playerlist[i]
					server.P_netstat.playerlist[i][k].mo.P_net_ready = nil
					-- we must also reattribute a selectindex to EACH OF THEM
					server.P_netstat.playerlist[i][k].mo.P_net_selectindex = k -- luckily, it's 'k'
					dprint("Player left, reseting team status to ensure net-safety.")

					-- another issue...;
					if k > server.P_netstat.teamlen
						table.remove(server.P_netstat.playerlist[i], k)
						dprint("Removed player "..k.." from team "..i.." to ensure team balance.")
					end
				end
			end

			if j == 1
			and server.P_netstat.playerlist[i][j]
			and server.P_netstat.playerlist[i][j].valid

				if not server.P_netstat.playerlist[i][j].P_teamleader
					server.P_netstat.playerlist[i][j].P_teamleader = true
					server.P_netstat.leaders[i] = server.P_netstat.playerlist[i][j]
				end
			end
			j = $-1
		end
	end

	-- same shit for spectators
	local i = #netstat.spectators
	while i
		local sp = netstat.spectators[i]
		if not sp or not sp.valid
			table.remove(netstat.spectators, i)
		end
		i = $-1
	end

	-- leader cleansing:
	local i = 4
	while i
		-- if the leader doen't exist, make it nil
		if not (server.P_netstat.leaders[i] and server.P_netstat.leaders[i].valid)
			server.P_netstat.leaders[i] = nil
			--dprint("Removed leader data from team "..i)
		end
		i = $-1
	end

	-- now it's a per player case...
	for p in players.iterate do

		local mo = p.mo
		if not mo continue end

		if mo.P_net_teamstate == 2
			if p.tempboss
				NET_team_bossselect(p)
			else
				NET_team_skinselect(p)
			end
			continue
		end

		if mo.P_net_ready
			continue
		end

		local inpt = mo.P_inputs

		if p.P_teamleader
			mo.P_net_teamstate = 2	-- consider things as if we had selected.
			continue
		end

		mo.P_net_teamstate = $ or 0
		mo.P_net_teamchoice = $ or 1

		-- else, we aren't a team leader

		-- teamstate 0, select our team
		if not mo.P_net_teamstate
			local maxc = min(4, #netstat.leaders)

			if server.P_netstat.buffer
				maxc = $+2
			end		-- +2 choices for party creation and spectating

			-- in case players leave and teams need to be undone...
			mo.P_net_teamchoice = min($, maxc)

			if inpt["down"] == 1
				S_StartSound(nil, sfx_hover, p)
				-- make sure this team exists...
				mo.P_net_teamchoice = $+1
				if mo.P_net_teamchoice > maxc
					mo.P_net_teamchoice = 1
				end
				while not netstat.playerlist[mo.P_net_teamchoice]
					mo.P_net_teamchoice = $+1
					if mo.P_net_teamchoice > maxc
						mo.P_net_teamchoice = 1
						break
					end
				end
			elseif inpt["up"] == 1
				S_StartSound(nil, sfx_hover, p)
				mo.P_net_teamchoice = $-1
				if mo.P_net_teamchoice < 1
					mo.P_net_teamchoice = maxc
				end
				while not netstat.playerlist[mo.P_net_teamchoice]
					mo.P_net_teamchoice = $-1
					if mo.P_net_teamchoice < 0
						mo.P_net_teamchoice = maxc
						break
					end
				end

			elseif inpt[BT_JUMP] == 1

				local team = netstat.playerlist[mo.P_net_teamchoice]

				if team and #team >= netstat.teamlen	-- team valid, check how many people are in...
					S_StartSound(nil, sfx_not, p)
					continue
				end

				-- team invalid
				if not #team

					if mo.P_net_teamchoice == maxc-1	-- new party
						mo.P_net_createparty = true
						mo.P_net_spectate = nil
					else
						mo.P_net_spectate = true
						mo.P_net_createparty = nil
					end
				end

				S_StartSound(nil, sfx_confir, p)
				mo.P_net_teamstate = 1	-- confirm?
			end


		-- ask for confirmation
		elseif mo.P_net_teamstate == 1

			-- check if team exists each frame, if it doesn't anymore, yeet tf outta here

			if not mo.P_net_createparty
			and not mo.P_net_spectate
				if not netstat.leaders[mo.P_net_teamchoice]
					mo.P_net_teamchoice = 1
					mo.P_net_teamstate = 0
					mo.P_net_createparty = nil
					continue
				end

				local team = netstat.playerlist[mo.P_net_teamchoice]
				if #team >= 4
					S_StartSound(nil, sfx_not, p)
					mo.P_net_teamstate = 0
					continue
				end
			else
				-- check if we CAN create a party in that case...
				if #netstat.leaders >= 4
					S_StartSound(nil, sfx_not, p)
					mo.P_net_teamstate = 0
					continue
				end
			end

			if inpt[BT_JUMP] == 1
				-- yes mom i wanna be there
				S_StartSound(nil, sfx_confir, p)

				if mo.P_net_spectate

					-- we must check that assuming the current amount of people who are ready
					-- and the amount of parties, there are still enough left AFTER we've become a spec
					-- to make the REQUIRED amount of parties...

					-- in short, if unreadyplayers <= neededparties, we can't become a spectator.
					if unreadyplayers <= neededparties
						S_StartSound(nil, sfx_not, p)
						chatprintf(p, "\x82".."*Create a party. The gamemode requires "..minparties.." party/ies and there are not enough players left to allow joining an existing party or spectating.")
						mo.P_net_spectate = nil
						continue	-- don't ready us up duh
					end

					netstat.spectators[#netstat.spectators+1] = p
					mo.P_net_ready = true

					continue
				elseif mo.P_net_createparty
					-- tell you what i wanna make my OWN TEAM!!!
					local firstinvalid
					local maxparties = netstat.buffer.maxparties or 1

					for i = 1, maxparties
						if not netstat.leaders[i]
							firstinvalid = i
							break
						end
					end

					if not firstinvalid	-- soz
						S_StartSound(nil, sfx_not, p)
						chatprintf(p, "\x82*No more parties can be made, maximum reached ("..maxparties..")")
						mo.P_net_createparty = nil
						mo.P_net_teamstate = 0
						continue
					end

					-- otherwise, make my OWN team!
					netstat.leaders[firstinvalid] = p
					p.P_teamleader = true	-- set as team leader (mostly used as reference for the game)
					p.P_party = firstinvalid	-- assign to party
					netstat.playerlist[firstinvalid][1] = p
					chatprint("\x82*"..p.name.." created a party.")
					mo.P_net_createparty = nil
					continue
				end

				-- we must check that assuming the current amount of people who are ready
				-- and the amount of parties, there are still enough left AFTER we've become a member
				-- to make the REQUIRED amount of parties...

				-- in short, if unreadyplayers <= neededparties, we can't become a party member
				if unreadyplayers <= neededparties
					S_StartSound(nil, sfx_not, p)
					chatprintf(p, "\x82".."*Create a party. The gamemode requires "..minparties.." party/ies and there are not enough players left to allow joining an existing party or spectating.")
					mo.P_net_teamstate = 0
					continue	-- don't ready us up duh
				end

				chatprint("\x82*"..p.name.." joined team "..mo.P_net_teamchoice)
				p.P_party = mo.P_net_teamchoice
				table.insert(netstat.playerlist[mo.P_net_teamchoice], p)
				mo.P_net_teamstate = 2
				local myindex = 0
				for i = 1, netstat.teamlen
					if netstat.playerlist[mo.P_net_teamchoice][i] == p
						myindex = i
						break
					end
				end
				mo.P_net_selectindex = myindex

			elseif inpt[BT_USE] == 1
				S_StartSound(nil, sfx_confir, p)
				mo.P_net_teamstate = 0
				mo.P_net_createparty = nil
				mo.P_net_spectate = nil
			end
		end
	end

	local pready = 0
	for p in players.iterate
		if p.P_net_team
			pready = $+1
		end
	end
	
	-- the launch prompt(if our host is deciding to spectate):
	for p in players.iterate
		local inpt = p.mo.P_inputs
		if p.mo.P_net_launchprompt
			if inpt[BT_JUMP] == 1	-- yeah let's go
				-- this is where we begin the game
				NET_startgame()
				return
			end
			-- pressing BT_USE will undo our last skin selection as expected, handled in the code below :P
		end
	end

	--if pready >= nump
	--	dprint("thighs")
	--	NET_setstate(NET_SKINSELECT)
	--end
end

local state_2_func = {
	[NET_TEAMSELECT] = NET_teamselect,
	[NET_SKINSELECT] = NET_teamselect,
	[NET_PVP_SKINSELECT] = NET_skinselect,
	[NET_PVP_TEAMSELECT] = NET_pvpteam,
	[NET_LOAD] = NET_load
}

-- handle character selection
--addHook("ThinkFrame", do
rawset(_G, "NET_Lobby", function()
	if not netgame
	and server
	and not server.skinlist
		-- quick intialization
		--server.skinlist = {{"sonic"}}
	end

	if not NET_isset()
	and gamemap ~= srb2p.tartarus_map
	and leveltime == 3	-- oddly specific, I know, but this guarantees the mapchange only happens once.
	and netgame			-- Only pull this weird stunt in netgames!
		NET_exitready(srb2p.tartarus_map, true)
		G_ExitLevel()
		return
	end

	if not NET_running() return end

	if state_2_func[server.P_netstat.netstate]
		state_2_func[server.P_netstat.netstate]()
	end
end)


if not srb2p.debug return end

COM_AddCommand("net_start", function()
	NET_begin()
end)

COM_AddCommand("net_kill", function()
	NET_end(true)
end)

COM_AddCommand("net_rseed", function()
	print(server.rogueseed)
end)

COM_AddCommand("net_retst", function()
	print(P_RandomFixed())
end)
