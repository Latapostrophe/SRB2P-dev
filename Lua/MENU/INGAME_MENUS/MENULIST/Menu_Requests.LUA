
local function m_requests_draw(v, mo, choice, forcetimer)
	--local battle = server.P_BattleStatus
	local timers = mo.m_hudtimers
	local timer = timers.sclosemenu and (5 - timers.sclosemenu) or timers.smenuopen or 0
	local ypos = 25
	
	v.fadeScreen(31, 7)	-- optimize rendering
	
	PDraw(v, 2, 2, v.cachePatch("H_RQTI"), V_SNAPTOTOP|V_SNAPTOLEFT)
	v.drawFill(0, 21, 999, 1, 135|V_SNAPTOTOP|V_SNAPTORIGHT)
	
	for i = 1, #mo.m_requests_list
		
		local num = mo.m_requests_list[i]
		local r = requestsList[num]
		local status = REQ_checkStatus(num)
		local col = "\x80"
		local backtext = ""
		
		if status == QS_NEW
			col = "\x82"
			backtext = "NEW"
		
		elseif status == QS_ACCEPTED
			col = "\x83"
			backtext = "ACCEPTED"
		
		elseif status == QS_SUBMITTABLE
			col = (leveltime%10 < 5) and "\x82" or "\x83"
			backtext = "SUBMIT"
		
		elseif status == QS_CLEARED
			col = "\x86"
			backtext = "CLEAR"
		end
		
		if i == mo.m_requests_select
			v.drawFill(0, ypos-1, 999, 10, 135|V_SNAPTOTOP|V_SNAPTOLEFT)
			if (mo.m_requests_submit)
				v.drawFill(0, ypos-1, mo.m_requests_submit*8, 10, 138|V_SNAPTOTOP|V_SNAPTOLEFT)
			end
			if backtext
				V_drawString(v, 150, ypos, backtext, "FPIMP", V_SNAPTOTOP|V_SNAPTOLEFT, "right", 138, nil)
			end
		end
		
		V_drawString(v, 1, ypos, string.format("%03d", num), "FPNUM", V_SNAPTOTOP|V_SNAPTOLEFT, nil, 0, 31)
		
		if (mo.m_requests_submit and i == mo.m_requests_select)
			local str = "COMPLETED!"
			local slen = mo.m_requests_submit
			
			local fstr = str:sub(1, slen)
			
			if slen < #str or leveltime%4 < 2
				V_drawString(v, 27, ypos, "\x82"..fstr, "NFNT", V_SNAPTOTOP|V_SNAPTOLEFT, nil, 0, 31)
			end
			
		else	-- just draw quest title
			V_drawString(v, 27, ypos, col..r.title, "NFNT", V_SNAPTOTOP|V_SNAPTOLEFT, nil, 0, 31)
		end
		
		ypos = $+10
	end
	
	PDraw(v, 320, 0, v.cachePatch("H_RQBAR"), V_SNAPTOTOP|V_SNAPTORIGHT)
	
	-- selected request:
	local sr = requestsList[mo.m_requests_list[mo.m_requests_select]]
	local itlist = sr.rewards
	local itlist_y = 148
	
	if mo.m_requests_accept
		-- display confirmation screen and acceptance rewards:
		local status = REQ_checkStatus(mo.m_requests_select)
		
		itlist = sr.acceptance
		itlist_y = 88
		
		if REQ_numAccepted() >= MAXACCEPTREQUESTS
			V_drawString(v, 173, 8, "CANNOT ACCEPT", "FPIMP", V_SNAPTOTOP|V_SNAPTORIGHT, nil, 31, nil)
		
			V_drawString(v, 173, 18, "\x85".."You have accepted the maximum", "NFNT", V_SNAPTOTOP|V_SNAPTORIGHT, nil, 0, 31)
			V_drawString(v, 173, 28, "\x85".."amount of Requests already ("..MAXACCEPTREQUESTS..")", "NFNT", V_SNAPTOTOP|V_SNAPTORIGHT, nil, 0, 31)
			V_drawString(v, 173, 38, "\x91".."\x82 Back", "NFNT", V_SNAPTOTOP|V_SNAPTORIGHT, nil, 0, 31)
		
		elseif status == QS_ACCEPTED
			V_drawString(v, 173, 8, "CONFIRM CANCELLATION", "FPIMP", V_SNAPTOTOP|V_SNAPTORIGHT, nil, 31, nil)
			
			V_drawString(v, 173, 18, "Abandon this Request?", "NFNT", V_SNAPTOTOP|V_SNAPTORIGHT, nil, 0, 31)
			V_drawString(v, 173, 28, "\x85".."OBJECTIVE PROGRESS WILL BE LOST", "NFNT", V_SNAPTOTOP|V_SNAPTORIGHT, nil, 0, 31)
			V_drawString(v, 173, 38, "\x90".."\x82 Abandon", "NFNT", V_SNAPTOTOP|V_SNAPTORIGHT, nil, 0, 31)
			V_drawString(v, 173, 48, "\x91".."\x82 Relent", "NFNT", V_SNAPTOTOP|V_SNAPTORIGHT, nil, 0, 31)	
		else
			V_drawString(v, 173, 8, "CONFIRM ACCEPTANCE", "FPIMP", V_SNAPTOTOP|V_SNAPTORIGHT, nil, 31, nil)
			
			V_drawString(v, 173, 18, "Accept this Request?", "NFNT", V_SNAPTOTOP|V_SNAPTORIGHT, nil, 0, 31)
			V_drawString(v, 173, 28, "(Accepted: "..REQ_numAccepted().."/"..MAXACCEPTREQUESTS..")", "NFNT", V_SNAPTOTOP|V_SNAPTORIGHT, nil, 0, 31)
			V_drawString(v, 173, 38, "\x90".."\x82 Accept", "NFNT", V_SNAPTOTOP|V_SNAPTORIGHT, nil, 0, 31)
			V_drawString(v, 173, 48, "\x91".."\x82 Relent", "NFNT", V_SNAPTOTOP|V_SNAPTORIGHT, nil, 0, 31)		
		end

		
		if itlist
			
			if status >= QS_ACCEPTEDONCE
				V_drawString(v, 173, 68, "\x85".."The following items were", "NFNT", V_SNAPTOTOP|V_SNAPTORIGHT, nil, 0, 31)
				V_drawString(v, 173, 78, "\x85".."already claimed:", "NFNT", V_SNAPTOTOP|V_SNAPTORIGHT, nil, 0, 31)			
			else
				V_drawString(v, 173, 68, "\x82".."Items awarded for first", "NFNT", V_SNAPTOTOP|V_SNAPTORIGHT, nil, 0, 31)
				V_drawString(v, 173, 78, "\x82".."time Request acceptance:", "NFNT", V_SNAPTOTOP|V_SNAPTORIGHT, nil, 0, 31)
			end
		end	
	else
		-- display main quest info
		V_drawString(v, 173, 8, "SENDER", "FPIMP", V_SNAPTOTOP|V_SNAPTORIGHT, nil, 31, nil)
		
		V_drawString(v, 173, 18, "DETAILS", "FPIMP", V_SNAPTOTOP|V_SNAPTORIGHT, nil, 31, nil)
		local details = STR_WordWrap(v, sr.desc, 145, "NFNT")
		for i = 1, #details
			V_drawString(v, 173, 28+10*(i-1), details[i], "NFNT", V_SNAPTOTOP|V_SNAPTORIGHT, nil, 0, 31)
		end	
		
		V_drawString(v, 173, 78, "OBJECTIVES", "FPIMP", V_SNAPTOTOP|V_SNAPTORIGHT, nil, 31, nil)
		
		local trackers = REQ_getAcceptedTrackers(mo.m_requests_select)
		
		local o_ypos = 88
		for i = 1, #sr.objectives
			local o = sr.objectives[i]
			local trackstr = ""

			local check = "H_RQCHK1"
			local col = ""
			
			if trackers
				trackstr = "("..trackers[i][2].."/"..trackers[i][3]..")"
				
				if trackers[i][2] >= trackers[i][3]
					col = "\x82"
					check = "H_RQCHK2"
				end
				
			end
				
			local s = STR_WordWrap(v, col..REQ_buildObjectiveString(o).." "..trackstr, 145, "NFNT")
			
			v.drawIndex((160+1)<<FRACBITS, (o_ypos-4)<<FRACBITS, FRACUNIT/2, v.cachePatch(check), V_SNAPTOTOP|V_SNAPTORIGHT, 31)
			PDraw(v, 160, o_ypos-5, v.cachePatch(check), V_SNAPTOTOP|V_SNAPTORIGHT)
			
			for j = 1, #s
				V_drawString(v, 173, o_ypos, s[j], "NFNT", V_SNAPTOTOP|V_SNAPTORIGHT, nil, 0, 31)
				o_ypos = $+10
			end
		end
	
		V_drawString(v, 173, 138, "REWARDS", "FPIMP", V_SNAPTOTOP|V_SNAPTORIGHT, nil, 31, nil)
	end
	
	if itlist
		for i = 1, #itlist
			-- exp: \AC
			-- lexp: \AD
			
			local reward = itlist[i]
			local str = ""
			local rstr = ""
			
			if reward[1] == "item"
				local it = itemDefs[reward[2]]
				local quantity = ""
				if reward[3]
					quantity = "x"..reward[3]
				end	
				local rarity = min(it.rarity, 7)
				rarity = max(1, $)
				
				str = buildItemName(it).." "..quantity
				rstr = rarity_2_ico[rarity]
				
			elseif reward[1] == "weapon"
				local wp = makeWeapon(reward[2], reward[3])
				local rarity = min(wp.rarity, 7)
				rarity = max(1, $)			
				str = buildWeaponName(wp)
				rstr = rarity_2_ico[rarity]
				wp = nil
				
			elseif reward[1] == "wardring"
				local rn = makeRing(reward[2], reward[3])
				local rarity = min(rn.rarity, 7)
				rarity = max(1, $)			
				str = buildRingName(rn)
				rstr = rarity_2_ico[rarity]
				rn = nil
			
			elseif reward[1] == "macca"
				str = currency..reward[2]
			
			elseif reward[1] == "exp"
				str = "\xAC"..reward[2]
				
			elseif reward[1] == "lexp"
				str = "\xAD"..reward[2]
			
			end
			
			V_drawString(v, 165, itlist_y+10*(i-1), rstr, "NFNT", V_SNAPTOTOP|V_SNAPTORIGHT, nil, 0, 31)
			V_drawString(v, 173, itlist_y+10*(i-1), str, "NFNT", V_SNAPTOTOP|V_SNAPTORIGHT, nil, 0, 31)
		end
	end
	
	if timer
		local frame = 5+ (5 - timer)
		drawScreenwidePatch(v, v.cachePatch("H_ROPEN"..frame))
	end
	
	if mo.m_requests_closetimer
		local frame = 4+ (mo.m_requests_closetimer)
		drawScreenwidePatch(v, v.cachePatch("H_ROPEN"..frame))	
	end
end

local function m_requests_inputs(mo)
	
	if mo.m_requests_closetimer
		mo.m_requests_closetimer = $-1
		
		if not mo.m_requests_closetimer
			M_openMenu(mo, "sp_main")
			mo.m_requests_closetimer = 5	-- do it again.
		end
		return true
	end
	
	if mo.m_requests_submit
		
		mo.m_requests_submit = $+1
		
		if mo.m_requests_submit == TICRATE
			-- check rewards etc...
			local num = mo.m_requests_list[mo.m_requests_select]
			local r = requestsList[num]
			
			if r.rewards
				mo.m_requests_extras = REQ_giveRewards(r.rewards, true)	-- bundle items with exp /etc
				local extras = mo.m_requests_extras
				
				-- do LiNK EXP first.
				if extras[2]	-- LiNK EXP
					mo.m_requests_linkexp = true
					LiNK_getEXP(extras[2])
					return true
				end
				
				-- show the rest of the rewards on a battle screen.
				BTL_getEXP(1, extras[1], extras[3], extras[4], extras[5], extras[6])
				
				mo.m_requests_submit = nil
				REQ_clear(num)
			end
		end
		
		if mo.m_requests_linkexp
			if srb2p.storydata.dolinkexp
				LiNK_doEXP()
			else
				local extras = mo.m_requests_extras
				local num = mo.m_requests_list[mo.m_requests_select]
				local r = requestsList[num]
				
				BTL_getEXP(1, extras[1], extras[3], extras[4], extras[5], extras[6])
				
				mo.m_requests_submit = nil
				REQ_clear(num)	
			end
		end
		
		return true
	end
	
	if mo.P_inputs[BT_BTNB] == 1
		
		if mo.m_requests_accept
			S_StartSound(nil, sfx_cancel, mo.player)
			mo.m_requests_accept = nil
			return
		end
		
		S_StartSound(nil, sfx_cancel, mo.player)
		mo.m_requests_closetimer = 5
	
	elseif mo.P_inputs[BT_BTNA] == 1
		
		local status = REQ_checkStatus(mo.m_requests_select)
		
		if mo.m_requests_accept
			
			if status == QS_ACCEPTED
				local index = REQ_checkAccepted(mo.m_requests_select)
				-- cancel the request
				if index
					REQ_cancel(index)
				end
				mo.m_requests_accept = nil
			else
				
				-- accept the request if we don't already have too many.
				if REQ_numAccepted() < MAXACCEPTREQUESTS
					
					REQ_accept(mo.m_requests_select)
					mo.m_requests_accept = nil
				end
			end
			return
		end

		-- check if the request we're checking is new or something
		if status == QS_NEW
			REQ_setStatus(mo.m_requests_select, QS_CHECKED)
		elseif status == QS_SUBMITTABLE
			mo.m_requests_submit = 1	-- begin quest submit protocol!
			return
		end
		
		mo.m_requests_accept = true	-- open acceptance menu
		S_StartSound(nil, sfx_confir, mo.player)
		
	
	elseif mo.P_inputs["down"] == 1
	and not mo.m_requests_accept

		-- check if the request we're checking is new or something
		if REQ_checkStatus(mo.m_requests_select) == QS_NEW
			REQ_setStatus(mo.m_requests_select, QS_CHECKED)
		end
	
		mo.m_requests_select = $+1
		
		if mo.m_requests_select > #mo.m_requests_list
			mo.m_requests_select = 1
		end
		S_StartSound(nil, sfx_hover)
		
	elseif mo.P_inputs["up"] == 1
	and not mo.m_requests_accept

		-- check if the request we're checking is new or something
		if REQ_checkStatus(mo.m_requests_select) == QS_NEW
			REQ_setStatus(mo.m_requests_select, QS_CHECKED)
		end
	
		mo.m_requests_select = $-1
		
		if mo.m_requests_select < 1
			mo.m_requests_select = #mo.m_requests_list
		end
		S_StartSound(nil, sfx_hover)
		
		-- check if the request we're checking is new or something
		if REQ_checkStatus(mo.m_requests_select) == QS_NEW
			REQ_setStatus(mo.m_requests_select, QS_CHECKED)
		end
	end
	return true
end

-- initiate main pause menu:
M_menus["m_requests"] = {

	m_start_at = "m_main",	-- where the menu starts
	openfunc = function(mo)	-- play a sound when we open the menu:
	end,

	m_main = {
		opentimer = 5,
		closetimer = 5,
		openfunc = 	function(mo)
			
						-- get a list of available requests, then sort them by whether or not they've been completed.
						mo.m_requests_list = {}
						mo.m_requests_select = 1
						mo.m_requests_submit = nil
						mo.m_requests_accept = nil
						
						for i = 1, #requestsList
							table.insert(mo.m_requests_list, i)
							-- debug:
							if REQ_checkStatus(i) == nil
								REQ_setStatus(i, QS_NEW)
							end
						end
					end,

		prev = nil,

		drawer = m_requests_draw,
		runfunc = m_requests_inputs,
	},
}