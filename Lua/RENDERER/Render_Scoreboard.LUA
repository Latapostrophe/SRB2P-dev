hud.disable("rankings")

rawset(_G, "drawPlayerInfo", function(v, p, showhp, ypos)
	if not (p.valid and p.mo) return end
	local ico = charStats[p.mo.skin] and charStats[p.mo.skin].icon or charStats["sonic"].icon

	-- get ping
	local ping = SRB2P_getPing(#p)
	if not #p
		V_drawString(v, 4, ypos, "\x82".."HOST", "NFNT", V_SNAPTOLEFT, nil, 0, 31)
	else
		if ping > 127
			if ping < 255
				ping = "\x82"..$
			else
				ping = "\x85"..$
			end
		end
		V_drawString(v, 4, ypos, ping.."ms", "NFNT", V_SNAPTOLEFT, nil, 0, 31)
	end


	PDraw(v, 38, ypos, v.cachePatch(ico), V_SNAPTOLEFT, v.getColormap(TC_DEFAULT, p.mo.color))
	V_drawString(v, 50, ypos, p.name, "NFNT",V_SNAPTOLEFT, nil, 0, 31)

	if showhp

		if server.gamemode == GM_PVP and p.P_party ~= consoleplayer.P_party return end	-- don't cheat :)

		local control = p.maincontrol
		if not control or not control.valid return end

		local str = "HP: "..control.hp.."/"..control.maxhp
		V_drawString(v, 128, ypos, str, "NFNT", V_SNAPTOLEFT, nil, 135, 31)
		local str2 = "SP: "..control.sp.."/"..control.maxsp
		V_drawString(v, 192, ypos, str2, "NFNT", V_SNAPTOLEFT, nil, 181, 31)

	end
end)

rawset(_G, "HUDScoreboardThinker", function(v, lp, c)
	if not EnabledHuds["Scoreboard"] return end
	if not netgame return end	-- Not in singleplayer.

	v.fadeScreen(31, 7)

	local ypos = 24

	if not NET_isset()
		for p in players.iterate do

			drawPlayerInfo(v, p, false, ypos)

			ypos = $+10
		end
	else
		for i = 1, 4 do
			local drawn
			if server.playerlist[i]
				for j = 1, server.P_netstat.teamlen do

					if server.playerlist[i][j]
						drawPlayerInfo(v, server.playerlist[i][j], true, ypos)
						ypos = $+10
						drawn = true
					end
				end
			end

			if drawn
				v.drawFill(0, ypos, 999, 1, 135)
			end
			ypos = $+10
		end
	end
end)
hud.add(HUDScoreboardThinker, "scores")