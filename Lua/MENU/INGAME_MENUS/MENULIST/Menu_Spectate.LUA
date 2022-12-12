
local function m_teamselect_drawer(v, mo, choice)

	local timer = mo.m_hudtimers.sclosemenu and mo.m_hudtimers.sclosemenu or (7 - (mo.m_hudtimers.smenuopen or 0))

	if timer
		v.fadeScreen(31, timer)
	end

	local nteams = 0
	
	for i = 1, 4
		if #server.plentities[i]
			nteams = $+1	-- empty teams can exist if people leave (how)
		end
	end

	local w = 75
	local x = 160 - (w/2)*nteams
	local y = 50- (7-timer)*32

	local hpos = mo.m_teamselect
	local vpos = mo.m_slotselect

	V_drawString(v, 160, 20, "Select a party to join", "NFNT", 0, "center", 0, 31)

	for i = 1, 4
		local team = server.plentities[i]
		if #team

			-- find the first valid player in that party (server.playerlist[i])
			local firstplayer = server.playerlist[i][1]
			local k = 2
			-- only enter this loop if firstplayer somehow doesn't exist
			while not firstplayer and k < #team
				firstplayer = server.playerlist[i][k]
				k = $+1
			end

			V_drawString(v, x, y-10, "\x82"..firstplayer.name.."'s party", "TFNT", 0, nil, 0, 31)

			for j = 1, #team
				local dta = team[j]
				local sk = team[j].stats
				local ico = charStats[sk].icon or "ICO_SONI"

				-- only assign this player if it is our MAIN.
				-- and grey out the name display later so it shows we can't take over it.
				local p
				if dta.control.maincontrol == dta
					p = dta.control
				end

				if i == hpos and j == vpos
					v.drawFill(x-2, y-2, 80, 32, 135)
				end

				PDraw(v, x, y, v.cachePatch(ico), 0, v.getColormap(TC_DEFAULT, skins[sk].prefcolor))
				local name = p and "\x86"..p.name.."\x80" or skins[sk].realname
				local nstr = "Lv"..dta.level.." "..name
				V_drawString(v, x+9, y, nstr, nstr:len() >= 15 and "TFNT" or "NFNT", 0, nil, 0, 31)
				-- draw HP/SP
				v.drawFill(x+9, y+14, 48, 2, 31)
				v.drawFill(x+9, y+14, dta.hp*47/dta.maxhp, 1, 131)
				V_drawString(v, x+9, y+10, "HP "..dta.hp.."/"..dta.maxhp, "NFNT", 0, nil, 135, 31, FRACUNIT/3)

				v.drawFill(x+9, y+21, 48, 2, 31)
				v.drawFill(x+9, y+21, dta.sp*47/dta.maxsp, 1, 181)
				V_drawString(v, x+9, y+17, "SP "..dta.sp.."/"..dta.maxsp, "NFNT", 0, nil, 183, 31, FRACUNIT/3)

				y = $+32
			end

			x = $+w
			y = 50- (7-timer)*32
		end
	end
end


local function m_teamselect_inputs(mo)
	local inputs = mo.P_inputs


	local nteams = 0
	local minteam = 0
	local maxteam = 0
	
	for i = 1, 4
		if #server.plentities[i]
			nteams = i	-- empty teams can exist if people leave (how)
			
			if not minteam
				minteam = i
			end
			maxteam = i			
		end
	end
	
	mo.m_teamselect = max($, minteam)

	local currteam = server.plentities[mo.m_teamselect]
	local cteamlen = #currteam
	if cteamlen > 1
		if inputs["down"] == 1
			mo.m_slotselect = $+1
			if mo.m_slotselect > cteamlen
				mo.m_slotselect = 1
			end
			S_StartSound(nil, sfx_hover, mo.player)

		elseif inputs["up"] == 1
			mo.m_slotselect = $-1
			if mo.m_slotselect < 1
				mo.m_slotselect = cteamlen
			end
			S_StartSound(nil, sfx_hover, mo.player)
		end
	end

	if nteams > 1
		if inputs["right"] == 1

			mo.m_teamselect = $+1
			while (mo.m_teamselect > 4 or not #server.plentities[mo.m_teamselect])
				mo.m_teamselect = $+1	-- this can make us go out of bounds but it doesn't matter
				if mo.m_teamselect > nteams
					mo.m_teamselect = 1
				end
			end	

			-- just in case...
			local newteam = server.plentities[mo.m_teamselect]
			mo.m_slotselect = min($, #newteam)

			S_StartSound(nil, sfx_hover, mo.player)
		elseif inputs["left"] == 1
			mo.m_teamselect = $-1
			while (mo.m_teamselect < 1 or not #server.plentities[mo.m_teamselect])
				mo.m_teamselect = $-1	-- this can make us go out of bounds but it doesn't matter
				if mo.m_teamselect < 1
					mo.m_teamselect = nteams
				end
			end	

			-- just in case...
			local newteam = server.plentities[mo.m_teamselect]
			mo.m_slotselect = min($, #newteam)

			S_StartSound(nil, sfx_hover, mo.player)
		end
	end


	if inputs[BT_JUMP] == 1
		local pm = server.plentities[mo.m_teamselect][mo.m_slotselect]
		if not pm or not pm.valid	-- how
		or pm.control and pm.control.valid and pm.control.maincontrol == pm	-- this belongs to someone else

			S_StartSound(nil, sfx_not, mo.player)
			return
		end

		-- this guy is okay for the taking!
		PLYR_spectatorJoinGame(mo.player, mo.m_teamselect, mo.m_slotselect)
		M_closeMenu(mo)
	elseif inputs[BT_USE] == 1
		M_closeMenu(mo)
		S_StartSound(nil, sfx_cancel, mo.player)
	end
end

-- initiate main pause menu:
M_menus["spectate_jointeam"] = {
	m_start_at = "m_teamselect",	-- where the menu starts
	openfunc = function(mo)	-- play a sound when we open the menu:
		S_StartSound(nil, sfx_select, mo.player)

		-- compute what healing skills we have.
	end,

	m_teamselect = {
		opentimer = 7,
		closetimer = 7,

		openfunc =	function(mo)
						mo.m_teamselect = 1
						mo.m_slotselect = 1
					end,

		prev = nil,
		drawer = m_teamselect_drawer,
		runfunc = m_teamselect_inputs,
	}
}