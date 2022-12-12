-- renders the skin selection menu for netgames
-- note: a lot of shit there is local, but it's really just visual quirks

rawset(_G, "net_stats", {0, 0, 0, 0, 0})
rawset(_G, "net_time", 0)

rawset(_G, "NET_draw_load", function(v,p,c)

	local h = server.netgamefile
	local teams = h.playerlist
	local net = server.P_netstat
	local plist = net.playerlist

	local nteams = 0
	for i = 1, #teams
		if #teams[i]
			nteams = $+1
		end
	end

	local x = 130
	local y = 50
	if nteams > 1
		local shift = {-5, 80, 110, 130}
		x = $ - (shift[nteams] or 110)
	end

	if p.mo.P_net_skinselect == nil return end	-- woops

	local hpos = (p.mo.P_net_skinselect / h.teamlen)+1
	local vpos = (p.mo.P_net_skinselect % h.teamlen)+1

	v.fadeScreen(31, 7)

	V_drawString(v, 160, 8, "\x82".."File succesfully loaded!", "NFNT", 0, "center", 0, 31)
	V_drawString(v, 160, 18, "Select what characters to play as", "NFNT", 0, "center", 0, 31)
	V_drawString(v, 160, 28, "Teams with no selections will be erased", "NFNT", 0, "center", 35, 31)

	for i = 1, #teams
		for j = 1, #teams[i]
			local p = (plist[i][j] and plist[i][j].valid) and plist[i][j] or nil
			local sk = teams[i][j].skin
			local dta = teams[i][j]
			local ico = charStats[sk].icon or "ICO_SONI"

			if i == hpos and j == vpos
				v.drawFill(x-2, y-2, 80, 32, 135)
			end

			PDraw(v, x, y, v.cachePatch(ico), 0, v.getColormap(TC_DEFAULT, skins[sk].prefcolor))
			local name = p and "\x82"..p.name.."\x80" or skins[sk].realname
			local nstr = "Lv"..dta.level.." "..name
			V_drawString(v, x+9, y, nstr, nstr:len() >= 15 and "TFNT" or "NFNT", 0, nil, 0, 31)
			-- draw HP/SP
			v.drawFill(x+9, y+14, 48, 2, 31)
			v.drawFill(x+9, y+14, dta.hp*47/dta.maxhp, 1, 131)
			V_drawString(v, x+9, y+10, "HP "..dta.hp.."/"..dta.maxhp, "NFNT", 0, nil, 135, 31, FRACUNIT/3)

			v.drawFill(x+9, y+21, 48, 2, 31)
			v.drawFill(x+9, y+21, dta.sp*47/dta.maxsp, 1, 181)
			V_drawString(v, x+9, y+17, "SP "..dta.sp.."/"..dta.maxsp, "NFNT", 0, nil, 183, 31, FRACUNIT/3)

			y = $ + 32

		end
		x = $ + (160 / nteams)*2
		y = 50
	end
end)

rawset(_G, "NET_displayteam", function(mo, t)
end)

rawset(_G, "NET_draw_bosschoice", function(v, p, c)

	local bosses = server.bosslist
	local selectboss = server.bosslist[p.bossselect]
	local bossinfo = enemyList[selectboss]
	local bossframeanim = bossinfo and bossinfo.anim_stand or nil
	local bosspatch

	if p ~= consoleplayer return end	-- don't let other players screen cheat

	V_drawString(v, min(100, t*64), 8, "SELECT YOUR BOSS!", "FPIMP", V_SNAPTOTOP|V_SNAPTOLEFT, nil, 0, 31)

	-- attempt to cache standing frame for the boss
	if type(bossframeanim[#bossframeanim]) ~= "string"
	and bossframeanim[1] == SPR_PLAY
	and bossinfo and bossframeanim
		bosspatch = v.getSprite2Patch(bossinfo.skin or 0, bossframeanim[#bossframeanim], bossframeanim[2], 2)
	else
		bosspatch = v.getSpritePatch(bossframeanim[1], bossframeanim[2], 2)
	end

	if bosspatch
		PDraw(v, 160, 170, bosspatch, 0, v.getColormap(TC_DEFAULT, bossinfo.color or 0))
	end
	local name = bossinfo and bossinfo.name or "Random"
	local begin = "\x82"..(leveltime%10 < 5 and "<" or "< ").."\x80"
	local ending = "\x82"..(leveltime%10 < 5 and ">" or " >")
	V_drawString(v, min(160, t*64), 180, begin..name.." (LV"..bossinfo.level..")"..ending, "NFNT", V_SNAPTOTOP|V_SNAPTOLEFT, "center", 0, 31)

	if p.mo.P_net_launchprompt
		local w = 100
		local h = 30
		v.drawFill(160 - (w/2), 100 - (h/2), w, h, 135)
		V_drawString(v, 160, 90, "All teams are ready!", "NFNT", 0, "center", 31, nil)
		V_drawString(v, 160, 100, "PRESS A TO BEGIN", "NFNT", 0, "center", 31, nil)
		return	-- disreguard the other prompts in that case
	end

	if p.confirmboss == 1
		local w = 100
		local h = 40
		v.drawFill(160 - (w/2), 100 - (h/2), w, h, 135)
		V_drawString(v, 160, 80, "This choice", "NFNT", 0, "center", 31, nil)
		V_drawString(v, 160, 88, "can't be undone", "NFNT", 0, "center", 31, nil)
		V_drawString(v, 160, 100, "A: Confirm", "NFNT", 0, "center", 31, nil)
		V_drawString(v, 160, 108, "B: Back out", "NFNT", 0, "center", 31, nil)
	elseif p.confirmboss == 2
		local w = 100
		local h = 20
		v.drawFill(160 - (w/2), 100 - (h/2), w, h, 135)
		V_drawString(v, 160, 80, "Waiting for other players", "NFNT", 0, "center", 31, nil)
		V_drawString(v, 160, 88, "to finish selecting...", "NFNT", 0, "center", 31, nil)
	end
end)

rawset(_G, "NET_draw_skinselect", function(v,p,c)

	local mo = p.mo
	if not mo return end

	-- alright let's do this then
	--drawScreenwidePatch(v, v.cachePatch("H_RIP4"), nil, V_30TRANS)
	--v.fadeScreen(31, 7)

	if p.tempboss
		NET_draw_bosschoice(v, p, c)
		return
	end

	--net_time = $+1
	local t = net_time

	-- from drawstats, but modified YET AGAIN

	-- draw Persona name
	V_drawString(v, min(100, t*64), 8, "SELECT YOUR CHARACTER", "FPIMP", V_SNAPTOTOP|V_SNAPTOLEFT, nil, 0, nil)

	if mo.P_net_skinselect == nil return end
	if not skins[mo.P_net_skinselect] return end	-- wait a bit, stuff isn't initialized yet
	local invalid

	if not charStats[skins[mo.P_net_skinselect].name]
		invalid = true
	end

	local skin = charStats[skins[mo.P_net_skinselect].name] and skins[mo.P_net_skinselect] or skins[0]
	local stats = charStats[skin.name]
	local persona = personaList[stats.persona]

	-- draw character portrait
	PDraw(v, min(200, t*64), 45, v.cachePatch(stats.hudaoa), V_SNAPTORIGHT, v.getColormap(TC_DEFAULT, skins[mo.P_net_skinselect].prefcolor))

	-- draw the persona over it
	/*local net_persona = mo.P_net_persona

	if not net_persona or not net_persona.valid return end

	-- TODO: replace w/ artwork
	local spr = sprnames[net_persona.sprite]
	-- check for validity of a2 or a2a8 and then draw it, otherwise attempt a1 and a0 in this order.
	-- get frame:
	local frame = string.char(65 + net_persona.frame)	-- 65 is "A", frame A is 0
	local attempts = {frame.."2"..frame.."8", frame.."2", frame.."8", frame.."1", frame.."0"}
	for i = 1, #attempts
		local cache = spr..attempts[i]
		if v.patchExists(cache)
			v.drawScaled(280<<FRACBITS, 160<<FRACBITS, FRACUNIT*2/3, v.cachePatch(cache), V_SNAPTORIGHT)
			break
		end
	end*/

	-- start by drawing two lines

	R_drawAngledLine(v, 0, 36, ANG1*3, min(t*64, 400), 135|V_SNAPTOTOP|V_SNAPTOLEFT, 32)
	R_drawAngledLine(v, 0, 160, ANG1*3, min(t*64, 400), 135|V_SNAPTOBOTTOM|V_SNAPTOLEFT, 64)
	R_drawAngledLine(v, 30, 0, ANG1*273, min(t*64, 300), 135|V_SNAPTOTOP|V_SNAPTOLEFT, 64)

	-- draw character name

	local invalidstr = "This skin has no stats data.\nSonic's stats will be used instead."
	local tip = invalid and invalidstr or stats.tip

	local tipt = STR_WordWrap(v, tip, 190, "NFNT", FRACUNIT/2)
	local tiptext = ""
	for i = 1, #tipt
		tiptext = $..(tipt[i] or "").."\n"
	end


	V_drawString(v, min(t*64, 310), 135, skins[mo.P_net_skinselect].realname:upper(), "FPIMP", V_SNAPTOBOTTOM, "right", 135, nil, FRACUNIT)	-- don't snap to right.
	V_drawString(v, min(t*64, 128), 152, tiptext or "", "NFNT", V_SNAPTOBOTTOM|V_SNAPTORIGHT, nil, 31, nil)

	-- draw party
	local net = server.P_netstat
	local party = net.playerlist[p.P_party]
	local slist = net.skinlist[p.P_party]

	V_drawString(v, min(t*64, 65), 150, "PARTY", "FPIMP", V_SNAPTOBOTTOM|V_SNAPTOLEFT, "center", 31, nil)
	for i = 1, net.teamlen
		local name = ""
		local ico, color
		if slist[i] or (party[i] and party[i].valid and party[i].mo and party[i].mo.P_net_skinselect ~= nil)

			local s = slist[i] or party[i].mo.P_net_skinselect
			if not charStats[skins[s].name]
				s = 0
			end

			local stat = charStats[skins[s].name]
			if stat.icon
				ico = v.cachePatch(stat.icon)
			end
			-- if a player's there, name this party member after them.
			if party[i] and party[i].valid
				name = party[i].name
				color = party[i].mo.color
			else	-- otherwise, give them the skin's real name
				name = skins[s].realname.." (BOT)"
				color = skins[s].prefcolor
			end
			color = $ or SKINCOLOR_NONE
		end
		if not party[i]
			name = "Waiting"..(string.rep(".", leveltime%30 /10 +1))
		end

		if not mo.P_net_ready
			if not mo.P_net_menu and mo.P_net_selectindex == (i)
				if leveltime%10 < 5
					name = "NOW SELECTING"
				else
					name = ""
				end
			elseif mo.P_net_menu == 1 and mo.P_net_selectindex == (i)
				if leveltime%10 < 5
					name = "CONFIRM AGAIN"
				else
					name = ""
				end
			end
		end

		if party[i] and party[i].valid and party[i].mo and party[i].mo.P_net_ready
			V_drawString(v, 2, 162 + (i-1)*10, "READY", "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 31, nil, FRACUNIT/4)
		end

		V_drawString(v, 30, 160 + (i-1)*10, name, "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 31, nil)
		if ico
			PDraw(v, 20, 160 + (i-1)*10, ico, V_SNAPTOBOTTOM|V_SNAPTOLEFT, v.getColormap(TC_DEFAULT, color))
		end
	end

	-- draw affinities:
	local aff_x = 98
	for i = 0, 10
		PDraw(v, min(t*64, aff_x), 36 - i, v.cachePatch("ATK_"..atk_constant_2_num[2^i]), V_SNAPTOLEFT|V_SNAPTOTOP)
		PDraw(v, min(t*64, aff_x), 36 - i, v.cachePatch("H_ELMF2"), V_SNAPTOLEFT|V_SNAPTOTOP)
		local aff = "/"
		if persona.weak and persona.weak & 2^i
			aff = "\x82".."WK"
		elseif persona.block and persona.block & 2^i
			aff = "NUL"
		elseif persona.resist and persona.resist & 2^i
			aff = "STR"
		elseif persona.drain and persona.drain & 2^i
			aff = "\x85".."DRN"
		elseif persona.repel and persona.repel & 2^i
			aff = "\x85".."RPL"
		end
		V_drawString(v, aff_x + 8, 54 - i, aff, "NFNT", V_SNAPTOTOP|V_SNAPTOLEFT, "center", 31, nil)
		aff_x = $+20
	end

	-- draw the stats above the sprite if it's gigantic
	local stats = {persona.strength, persona.magic, persona.endurance, persona.agility, persona.luck}
	local statnames = {"STR", "MAG", "END", "AGI", "LUK"}
	for i = 1, #stats do

		V_drawString(v, 48, 70 + (i-1)*16, statnames[i], "FPIMP", V_SNAPTOLEFT, nil, 31, nil)
		V_drawString(v, 90, 70 + (i-1)*16, stats[i], "FPNUM", V_SNAPTOLEFT, "right", 31, nil)

		-- draw the bar
		-- bg:
		R_drawAngledLine(v, 96 +i, 75 + (i-1)*16, ANG1*3, net_stats[i]*12/2 + 2, 135|V_SNAPTOLEFT, 6)
		-- stat
		R_drawAngledLine(v, 96 +i, 75 + (i-1)*16, ANG1*3, net_stats[i]*12/2, 138|V_SNAPTOLEFT, 3)

		if net_stats[i] < stats[i]
			net_stats[i] = $+1
		elseif net_stats[i] > stats[i]
			net_stats[i] = $-1
		end
	end

	-- well i'll be damned, if that ain't the final prompt
	if mo.P_net_launchprompt
		local w = 100
		local h = 30
		v.drawFill(160 - (w/2), 100 - (h/2), w, h, 135)
		V_drawString(v, 160, 90, "All teams are ready!", "NFNT", 0, "center", 31, nil)
		V_drawString(v, 160, 100, "PRESS A TO BEGIN", "NFNT", 0, "center", 31, nil)
	end
end)

-- drawer for team selection
-- this will just be a "communicating" screen otherwise.
-- late joiners get assigned to whatever team has the least players on

rawset(_G, "NET_draw_teamselect", function(v, p, c)
	--drawScreenwidePatch(v, v.cachePatch("H_RIP4"), nil, V_30TRANS)
	v.fadeScreen(31, 7)

	local netstat = server.P_netstat
	local mo = p.mo
	if not mo return end

	if mo.P_net_teamstate == nil return end

	net_time = $+1
	local t = net_time

	if mo.P_net_teamstate < 2

		-- header:
		v.drawFill(0, 24, net_time*64, 1, 135|V_SNAPTOTOP|V_SNAPTOLEFT)
		V_drawString(v, 12, 8, "JOIN A PARTY", "FPIMP", V_SNAPTOTOP|V_SNAPTOLEFT, nil, 135, nil, FRACUNIT)

		V_drawString(v, 12, 160, "IN THIS PARTY", "FPIMP", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 135, nil)
		v.drawFill(0, 170, net_time*64, 1, 135|V_SNAPTOBOTTOM|V_SNAPTOLEFT)

		-- list parties or smth
		for i = 1, #netstat.leaders +2
			local party = netstat.playerlist[i]

			--print(i.."|"..#netstat.leaders)

			if i <= #netstat.leaders
				if not party or not #party continue end
				if not party[1] or not party[1].valid continue end	-- woops!
			end

			if i == mo.P_net_teamchoice
				v.drawFill(0, 30 + (i-1)*12, 999, 14, 135|V_SNAPTOLEFT)
			end

			if i <= #netstat.leaders
				V_drawString(v, 32, 32 + (i-1)*12, party[1].name.."'s party ".."("..(#party).."/4)", "NFNT", V_SNAPTOLEFT, nil, 0, 31)

				-- list the members:
				if i == mo.P_net_teamchoice
					local str = ""
					for j = 1, #party
						str = $..party[j].name
						if j ~= #party
							str = $..", "
						end
					end

					V_drawString(v, 12, 180, str, "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 0, 31)
				end

			elseif i < 6	-- only 4 parties max!!
			and server.P_netstat.buffer
				--maxc = $+1

				if i == #netstat.leaders+1

					V_drawString(v, 32, 32 + (i-1)*12, "Create party...", "NFNT", V_SNAPTOLEFT, nil, 0, 31)
					if i == mo.P_net_teamchoice
						V_drawString(v, 12, 180, "Make your own party", "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 0, 31)
					end
				else
					V_drawString(v, 32, 32 + (i-1)*12, "Spectate...", "NFNT", V_SNAPTOLEFT, nil, 0, 31)
					if i == mo.P_net_teamchoice
						V_drawString(v, 12, 180, "Spectate the game. You can start playing mid-game.", "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 0, 31)
					end
				end
			end
		end

		if mo.P_net_teamstate
			local w = 100
			local h = 40
			if mo.P_net_spectate and mo.P_net_ready
				v.drawFill(160 - (w/2), 100 - (h/2), w, h, 135)
				V_drawString(v, 160, 90, "You will spawn as", "NFNT", 0, "center", 31, nil)
				V_drawString(v, 160, 100, "a spectator.", "NFNT", 0, "center", 31, nil)
			else
				v.drawFill(160 - (w/2), 100 - (h/2), w, h, 135)
				V_drawString(v, 160, 80, "This choice", "NFNT", 0, "center", 31, nil)
				V_drawString(v, 160, 88, "can't be undone", "NFNT", 0, "center", 31, nil)
				V_drawString(v, 160, 100, "A: Confirm", "NFNT", 0, "center", 31, nil)
				V_drawString(v, 160, 108, "B: Back out", "NFNT", 0, "center", 31, nil)
			end
		end
		-- well i'll be damned, if that ain't the final prompt
		if mo.P_net_launchprompt
			local w = 100
			local h = 30
			v.drawFill(160 - (w/2), 100 - (h/2), w, h, 135)
			V_drawString(v, 160, 90, "All teams are ready!", "NFNT", 0, "center", 31, nil)
			V_drawString(v, 160, 100, "PRESS A TO BEGIN", "NFNT", 0, "center", 31, nil)
		end
	else

		NET_draw_skinselect(v,p,c)

		/*V_drawString(v, 160, 100, "lol waiting", "NFNT", 0, "center", 0, 31)

		V_drawString(v, 12, 160, "IN YOUR PARTY", "FPIMP", V_SNAPTOTOP|V_SNAPTOLEFT, nil, 135, nil)
		v.drawFill(0, 170, net_time*64, 1, 135|V_SNAPTOTOP|V_SNAPTOLEFT)

		local party = netstat.playerlist[p.P_party]

		if not party return end	-- what

		-- list the members:
		local str = ""
		for j = 1, #party
			str = $..party[j].name
			if j ~= #party
				str = $..", "
			end
		end

		V_drawString(v, 12, 180, str, "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 0, 31)*/
	end
end)

rawset(_G, "hudnet_state_2_func", {
	[NET_TEAMSELECT] = NET_draw_teamselect,
	[NET_SKINSELECT] = NET_draw_skinselect,
	[NET_PVP_SKINSELECT] = NET_draw_skinselect,
	[NET_LOAD] = NET_draw_load,
})

rawset(_G, "HUDNetThinker", function(v, p, c)
	if not EnabledHuds["NET"] return end
	NET_draw_synch(v)

	if not NET_isset() and gamemap ~= srb2p.tartarus_map
		v.drawFill()
		return
	end

	if not NET_running()
		net_time = 0
	return end

	if hudnet_state_2_func[server.P_netstat.netstate]
		hudnet_state_2_func[server.P_netstat.netstate](v, p, c)
	end

end)
hud.add(HUDNetThinker)