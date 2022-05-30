-- Rendering functions for shops.

local fusion_choices = {

	[FS_PREVIEW] = {
		"Yes",
		"View Skills",
		"No",
	},

	[FS_CONFIRM] = {
		"Yes",
		"View Skills",
		"No",
	},

	[FS_REPLACESKILL] = {
		"Yes",
		"No",
	},
	
	[FS_COMPENDIUMMAIN] = {
		"Compendium",
		"Register",
		"Nevermind",
	},
	
	[FS_REGISTERCONFIRM] = {
		"Yes",
		"View Skills",
		"No",
	},

	[FS_REGISTERCONFIRMALL] = {
		"Yes",
		"No",
	},

	/*[ELS_GRIND_CONFIRM] = {
		"Enhance it!",
		"Back",
	},

	[ELS_DESYNTH_CONFIRM] = {
		"Obliterate it!",
		"Back"
	},
	
	[ELS_FUSION_CONFIRM] = {
		"Sure!",
		"Back",
	},
	
	[ELS_FUSION_ASKUNEQUIP] = {
		"Do it",
		"Back",
	},*/
}

local function drawMoney(v, mo, timer)

	local btl = server.P_BattleStatus[mo.player.P_party]
	if not btl return end

	-- draw backdrop:
	local x = 0 - 24*timer
	local y = 100
	PDraw(v, x, y, v.cachePatch("H_MACCA"), V_SNAPTOTOP|V_SNAPTOLEFT)
	V_drawString(v, x+55, y+9, btl.macca, "FPNUM", V_SNAPTOTOP|V_SNAPTOLEFT, "right", 31, nil)
end

rawset(_G, "R_drawFusions", function(v, mo)
	if not mo.fusion
	or not mo.fusion.using return end	-- bruh!
	local e = mo.fusion
	local s = e.state

	local pa = mo.player.P_party
	local party = server.plentities[pa]
	local btl = server.P_BattleStatus[pa]

	-- state specific drawing:
	if s == FS_MAIN
	or e.hudtimers.cardsin
	or e.hudtimers.cardsout
		-- Draw the cards...
		
		local xp = 160 - ((40*(e.maxmainchoice-1))/2 + (10*(e.maxmainchoice-1))/2)
		if e.hudtimers.cardsin
			xp = $ - 48*e.hudtimers.cardsin
		elseif e.hudtimers.cardsout
			xp = $ - (TICRATE/3 - e.hudtimers.cardsout)*48
		end	
		
		local yp = 90
		for i = 1, e.maxmainchoice
			
			local pp = "FUSION_"
			if i == e.mainchoice
				pp = "FUSION_2"
			end	
			
			PDraw(v, xp, yp, v.cachePatch(pp..i))
			
			xp = $ + 40 + 10
			if i == 1
				yp = $ - 12
			elseif i == e.maxmainchoice-1
				yp = $ + 12
			end	
		end
	end
	
	-- Draw persona / fusion list.
	local numnames = {"1ST", "2ND", "3RD", "4TH"}
	
	if s == FS_NORMAL
	or s == FS_REGISTER
	or s == FS_COMPENDIUM
	or e.hudtimers.closefirstmenu
	or e.hudtimers.closefusion
		
		local x = 24 - (e.hudtimers.openfirstmenu or 0)*32 - (TICRATE/3 - (e.hudtimers.closefirstmenu or TICRATE/3))*32 + (TICRATE/3 - (e.hudtimers.closefusion or TICRATE/3))*64
		if s == FS_REGISTER
			x = $+72
		elseif s == FS_COMPENDIUM	
			x = $+48
		end	
		
		local y = 24
		local w = 132
		local shft = w + 12
		local t = btl.subpersonas
		
		local showresults = #e.personas >= e.maxpersonas-1
		
		--v.drawFill(x-2, y-2, w, 70)
		
		local add = 2
		local registration 
		local compendium
		
		if s == FS_REGISTER
		or s == FS_REGISTERCONFIRM
		or s == FS_REGISTERCONFIRMALL
			add = 1
			V_drawString(v, x+ w/2, y-16, "REGISTRATION", "FPIMP", 0, "center", 135, 31)
			t = e.registrable
			registration = true	-- this is for display...
		
		elseif s == FS_COMPENDIUM
			add = 1
			compendium = true
			V_drawString(v, 160, y-16, "COMPENDIUM", "FPIMP", 0, "center", 135, 31)
			t = srb2p.storydata.compendium
			
			local sortings = {"ARCANA", "NAME", "LEVEL"}
			local sortx = x-32
			
			V_drawString(v, sortx, y, "SORT BY", "FPIMP", 0, nil, 135, nil)
			v.drawFill(sortx, y+8, 220, 1, 135)
			
			sortx = $ + 64
			
			V_drawString(v, sortx - 2 - (leveltime%20 < 10 and 1 or 0), y-1, "\x93", "NFNT", 0, nil, 135, nil, FRACUNIT)	-- L
			
			sortx = $ + 16
			
			for i = 1, #sortings do
				
				local sw = V_stringWidth(v, sortings[i], "FPIMP")/FRACUNIT
				if i == e.sortfunc
					v.drawFill(sortx-2, y-1, sw +4, 10, 135)
				end
				
				V_drawString(v, sortx, y, sortings[i], "FPIMP", 0, nil, i == e.sortfunc and 31 or 135, nil)
				
				sortx = $ + sw+6
			end
			
			V_drawString(v, sortx + (leveltime%20 < 10 and 1 or 0), y-1, "\x94", "NFNT", 0, nil, 135, nil, FRACUNIT)	-- R
			
			y = $+24	-- this will allow us to display the "SORT BY" things...
		
		else
			V_drawString(v, x+ w/2, y-16, "MATERIALS", "FPIMP", 0, "center", 135, 31)
		end
			
		PDraw(v, x-2, y-2, v.cachePatch("FUSIONW"), V_TRANS40)
		if showresults
		or e.hudtimers.removeresults
			--v.drawFill(x-2 + shft, y-2, w, 70)
			
			local addx = (e.hudtimers.showresults or 0)*48 + (5 - (e.hudtimers.removeresults or 5))*48
			
			V_drawString(v, x + addx + shft + w/2, y-16, "RESULTS", "FPIMP", 0, "center", 135, 31)
			PDraw(v, 160 + addx  + (TICRATE/3 - (e.hudtimers.closefusion or TICRATE/3))*64, 10, v.cachePatch("FUSIONA"))
			PDraw(v, x-2 + addx + shft, y-2, v.cachePatch("FUSIONW"), V_TRANS40)
		end

		for i = e.personascroll + add, min(e.personascroll + add + 5, #t)
			local subp = t[i]
			local sref = subp.ref
			
			if i == e.personachoice
				v.drawFill(x, y-1, compendium and w+64 or showresults and 999 or w, 1, 135)
				v.drawFill(x, y+7, compendium and w+64 or showresults and 999 or w, 1, 135)
			end
			
			-- for registration...
			if i == 1
			and registration
				V_drawString(v, x + 34, y, "REGISTER ALL", "NFNT", 0, nil, col, 31)
				y = $+10
				continue
			end
			
			local col = 0
			-- check if that subp is already selected...
			if #e.personas
				for j = 1, #e.personas
					if subp == e.personas[j]
						
						V_drawString(v, x-4, y, numnames[j]..">", "NFNT", 0, "right", 73, 31)
						
						col = 16
						break
					end
				end
			end
			
			
			PDraw(v, x, y-1, v.cachePatch("ARCANA"..(sref.arcana or 1)))
			V_drawString(v, x + 34, y, subp.name, "NFNT", 0, nil, col, 31)
			
			
			-- level
			V_drawString(v, x + 120, y, "Lv"..subp.level, "TFNT", 0, nil, col, 31)
			-- Element
			if sref.weapontype
				v.drawScaled((x + 110)<<FRACBITS, (y)<<FRACBITS, FRACUNIT/4, v.cachePatch("AT2_"..atk_constant_2_num[sref.weapontype]))
			end	
			
			if s == FS_COMPENDIUM
				V_drawString(v, x + 148, y, P_subpersonaCost(subp)..currency, "NFNT", 0, nil, col, 31)
			end
			
			if showresults
				if e.maxpersonas == 2	-- normal fusion
					-- do the processing directly!
					
					local iresult = getFusionResult(e.personas[1].int, subp.int)
					local xpos = x + shft + (e.hudtimers.showresults or 0)*48
					
					if not iresult
						V_drawString(v, xpos + 34, y, "N/A", "NFNT", 0, nil, 0, 31)
					else
						local result = subpersonaList[iresult]
						
						PDraw(v, xpos, y-1, v.cachePatch("ARCANA"..(result.arcana or 1)))
						V_drawString(v, xpos + 34, y, result.name, "NFNT", 0, nil, 0, 31)
						V_drawString(v, xpos + 120, y, "Lv"..result.lv, "TFNT", 0, nil, 0, 31)
						
						if result.weapontype
							v.drawScaled((xpos + 110)<<FRACBITS, (y)<<FRACBITS, FRACUNIT/4, v.cachePatch("AT2_"..atk_constant_2_num[result.weapontype]))
						end
						
					end
				end
			end
			
			y = $+10
		end
		
	end
	
	
	-- Previews:
	if s == FS_PREVIEW
	or s == FS_SKILLVIEW
	or s == FS_SKILLCARD
	or s == FS_INHERIT
	or s == FS_CONFIRM
	or s == FS_EXP
	or s == FS_REPLACESKILL
	or s == FS_REGISTERCONFIRM
	or e.checkpersona
		
		local cardpatch = v.cachePatch("SHFLFL")
		local subp
		
		if e.checkpersona
			if s == FS_REGISTER
			or s == FS_REGISTERCONFIRM
			--or s == FS_REGISTERCONFIRMALL
				subp = e.registrable[e.personachoice]
			else
				subp = btl.subpersonas[e.personachoice]
			end	
		else	
			subp = e.personas[e.previewn]
		end	

		local subp_c = subp.ref	-- current subpersona data
		local sprname = sprnames[subp_c.sprite]
		local sprframe = string.char((subp_c.frame & FF_FRAMEMASK) + 65)
		local patch = v.cachePatch(sprname..sprframe.."0")	-- eg: SUBPA0
		
		if e.checkpersona
			v.fadeScreen(31, 7)
		end	
	
		if (s == FS_PREVIEW or s == FS_SKILLVIEW or s == FS_CONFIRM or s == FS_REGISTERCONFIRM) and #e.personas > 1

			-- show which persona we're previewing:		
			local px = 284 + (e.hudtimers.startpreview or 0)*64

			-- display L & R
			V_drawString(v, px + 20 + 1 + (leveltime%20 < 10 and 1 or 0), 3, "\x94", "NFNT", 0, nil, 135, 31, FRACUNIT)	-- R
		
			local i = #e.personas
			while i
				local pname = s == FS_REGISTERCONFIRM and "FUSP3_" or "FUSP_"
				if i == e.previewn
					pname = s == FS_REGISTERCONFIRM and "FUSP4_" or "FUSP2_"
				end
				
				if i == #e.personas
					pname = $.."R"
				else
					pname = $..i
				end	
				
				PDraw(v, px, 3, v.cachePatch(pname))
				
				i = $-1
				px = $ - 20
			end
			
			V_drawString(v, px + 6 - (leveltime%20 < 10 and 1 or 0), 3, "\x93", "NFNT", 0, nil, 135, 31, FRACUNIT)	-- L
		end	
		
		local dx = 30 - (e.hudtimers.startpreview or 0)*64
		
		PDraw(v, dx+20, 4, v.cachePatch("H_SUBP"), V_30TRANS)
		
		PDraw(v, dx, 84, cardpatch)
		PDraw(v, dx, 84, patch)

		V_drawString(v, dx + 40, 4, subp.ref.name:upper().." LV"..subp.level, "FPIMP", 0, nil, 0, 31)
		
		PDraw(v, dx + 40, 16, v.cachePatch("ARCANA"..subp_c.arcana))
		
		-- now draw stat bonuses and disadvantages:
		local stats_subp = {"st", "ma", "en", "ag", "lu"}
		
		local dy = 28
		for i = 1, #stats_subp
			V_drawString(v, dx + 40, dy, stats_subp[i]:upper(), "NFNT", 0, nil, 0, 31)

			-- draw a fake stat bar for funsies
			local checkstat = subp[stats_subp[i]]
			local str
			if checkstat < 0
				v.drawFill(dx + 62, dy+6, 32, 4, 31)	-- black bg
				v.drawFill(dx + 60, dy+4, 32, 4, 35)	-- red bar
				v.drawFill(dx + 60, dy+4, 24, 4, 0)		-- white bar
				str = "\x85"..checkstat

			elseif checkstat == 0

				v.drawFill(dx + 62, dy+6, 32, 4, 31)	-- black bg
				v.drawFill(dx + 60, dy+4, 32, 4, 0)		-- white bar
				str = "+0"

			else	-- stat > 0
				v.drawFill(dx + 62, dy+6, 40, 4, 31)	-- black bg
				v.drawFill(dx + 60, dy+4, 40, 4, 112)	-- green bar
				v.drawFill(dx + 60, dy+4, 32, 4, 0)		-- white bar
				str = "\x83".."+"..checkstat
			end

			V_drawString(v, dx + 60, dy, str, "NFNT", 0, nil, 0, 31)
			dy = $ + 10
		end
		
		-- EXP
		if srb2p.storymode
			local expt = getEXPTable()
			v.drawFill(dx + 40, dy+9, 64, 2, 31)
			v.drawFill(dx + 40, dy+9, subp.exp*63 / expt[subp.level], 1, 54)
			V_drawString(v, dx + 40, dy, "NEXT LV:"..(expt[subp.level]-subp.exp), "NFNT", 0, nil, 0, 31)
		end
		
		-- And now the skills!
		
		local sx = dx + 120
		local sy = 16 + 12*7
		
		-- show next skill
		local ndata
		
		if e.learnskills and e.learnskills[1]
			ndata = {e.learnskills[1][1], e.learnskills[1][2]}
		else	
			for i = 1, #subp_c.skills
				local sk = subp_c.skills[i]
				if type(sk) == "table"
				and subp.level < sk[2]
					ndata = {sk[1], sk[2]}
					break
				end
			end
		end	
		
		if ndata
			V_drawString(v, sx, dy+12, "NEXT (LV"..ndata[2]..")", "NFNT", 0, nil, 0, 31)
		end
		
		local i = 7
		while i
			local w = 64
			local h = 10
			local c = 31
			local c2 = 0
			local candesc
			local desc
			local inherit
			
			if (s == FS_SKILLVIEW or e.replaceskill or e.checkpersona == 2)
			and e.skilln == i
				w = 200
				h = 40
				c = 0
				c2 = 31
				candesc = true
			end
			
			local a = subp.skills[i]
			if i == 7
				if ndata
					a = ndata[1]
				else
					sy = $ - 24
					i = $-1
					continue
				end
			end
			
			-- flash white while learning....
			if e.learnskills and e.learnskills[1]
			and e.learnskills[1][3] < TICRATE/2
			
				if i == 7
				or i == e.learnslot
				or (not e.learnslot and i == #subp.skills+1)
					if leveltime%4 < 2
						c = 0
						c2 = 31
					end
				end	
			end
			
			v.drawFill(sx, sy, w, h, c)

			
			local aname = a
			
			if a
				local atk = attackDefs[a]
				local atype
				
				
				if atk
					aname = atk.name
					if atk.type & ATK_PASSIVE
						atype = 15
					else	
						atype = atk_constant_2_num[atk.type]
					end
					
					if candesc
						desc = atk.desc
					end	
				end	
				
				if atype
					v.drawScaled(sx*FRACUNIT, (sy+1)*FRACUNIT, FRACUNIT/4, v.cachePatch("ATK_"..atype))
					v.drawIndex(sx*FRACUNIT, (sy+1)*FRACUNIT, FRACUNIT/4, v.cachePatch("H_ELMF3"), 0, c)
				end
								
			else
				aname = "/"
				if i <= #subp.skills + (e.maxinherit - #e.inherited)
				and e.previewn == #e.personas	-- don't show that on other personas besides the result obv.
				and not e.checkpersona			-- don't display this when we check...
				and not e.checkcompendiun
					
					local col = "\x85"
					
					if s == FS_INHERIT
					and i == #subp.skills+1
					and leveltime%4 < 2
						col = "\x82"
					end	
					
					aname = col.."INHERIT"
					inherit = true
				end
			end	
			
			V_drawString(v, sx+32, sy + 2, aname, aname:len() <= 10 and "NFNT" or "TFNT", 0, "center", c2)

			if desc
				V_drawString(v, sx+2, sy + 12, desc, "NFNT", 0, nil, c2)
			elseif inherit and s == FS_SKILLVIEW and i == e.skilln
				V_drawString(v, sx+2, sy + 12, "This Skill Slot can be\ninherited from another Sub-Persona.", "NFNT", 0, nil, c2)
			end

			
			if i == 7
				sy = $-12
				
				-- While ineriting skills, only display info about our Persona's skills, don't overwhelm the player w too much.
				if s == FS_INHERIT
					local fade = 7-e.hudtimers.inheritin or 0
					if e.hudtimers.inheritout
						fade = e.hudtimers.inheritout
					end	
					v.fadeScreen(31, fade)
				end
			end	
			
			i = $-1
			sy = $ - 12

			
		end
		
	end
	
	-- Skill card selection:
	if s == FS_SKILLCARD
	or e.hudtimers.skillcardsout
		local tmr = e.hudtimers.skillcardsin or 0
		if e.hudtimers.skillcardsout
			tmr = 7-e.hudtimers.skillcardsout
		end	
		
		v.fadeScreen(31, 7-tmr)
		
		PDraw(v, 320 + 32*tmr, 0, v.cachePatch("FUSIONC"), V_SNAPTOTOP|V_SNAPTORIGHT|TR_TRANS30)	
		V_drawString(v, 200 + 32*tmr, 4, "SELECT SKILL CARD", "FPIMP", V_SNAPTOTOP|V_SNAPTORIGHT, nil, 135, 31)
		
		local x = 220 + 32*tmr
		local y = 22
		for i = e.cardscroll+1, min(e.cardscroll+1 +8, #e.skillcards) do
			local it = e.skillcards[i][1]
			
			if i == e.selectcard
				for j = 1, 12
					v.drawFill((x-4)-(j-1), y-3+j, 999, 1, 135|V_SNAPTORIGHT|V_SNAPTOTOP)
				end
				
				if itemDefs[it]
				and attackDefs[itemDefs[it].skill]
				and not e.hudtimers.skillcardsout
					V_drawString(v, 70, 90, "\x82".."INFO / "..attackDefs[itemDefs[it].skill].name, "NFNT", 0, nil, 0, 31)
					V_drawString(v, 70, 100, attackDefs[itemDefs[it].skill].desc, "NFNT", 0, nil, 0, 31)
				end
			end
			
			if itemDefs[it]
				V_drawString(v, x, y, buildItemName(itemDefs[it]), "NFNT", V_SNAPTORIGHT|V_SNAPTOTOP, nil, 0, 31)
				V_drawString(v, x + 70, y, (itemDefs[it].cost/4)..currency, "NFNT", V_SNAPTORIGHT|V_SNAPTOTOP, nil, 0, 31)
			else
				V_drawString(v, x, y, "Don't use", "NFNT", V_SNAPTORIGHT|V_SNAPTOTOP, nil, 0, 31)
			end

			y = $+10
		end
		
		drawMoney(v, mo, tmr)
	end
	
	-- Skill Inheritance Selection:
	if s == FS_INHERIT
	or e.hudtimers.inheritout
		local tmr = e.hudtimers.inheritin or 0
		if e.hudtimers.inheritout
			tmr = 7-e.hudtimers.inheritout
		end			
		PDraw(v, 320 + 32*tmr, 0, v.cachePatch("FUSIONC"), V_SNAPTOTOP|V_SNAPTORIGHT|TR_TRANS30)	
		V_drawString(v, 180 + 32*tmr, 4, "SELECT INHERITANCE", "FPIMP", V_SNAPTOTOP|V_SNAPTORIGHT, nil, 135, 31)
		
		local x = 220 + 32*tmr
		local y = 22
		for i = e.inheritscroll+1, min(e.inheritscroll+1 +8, #e.inheritable) do
			local it = e.inheritable[i]
			local col = 0
			local subp = e.personas[#e.personas]
			
			-- grey out duplicates
			for j = 1, #subp.skills
				if subp.skills[j] == it
					col = 16
					break
				end	
			end
			
			if i == e.inheritselect
				for j = 1, 12
					v.drawFill((x-4)-(j-1), y-3+j, 999, 1, 135|V_SNAPTORIGHT|V_SNAPTOTOP)
				end
				
				if attackDefs[it]
				and not e.hudtimers.inheritout
					V_drawString(v, 70, 90, "\x82".."INFO / "..attackDefs[it].name, "NFNT", 0, nil, 0, 31)
					V_drawString(v, 70, 100, attackDefs[it].desc, "NFNT", 0, nil, 0, 31)
				end
			end
			
			if attackDefs[it]
				V_drawString(v, x, y, attackDefs[it].name, "NFNT", V_SNAPTORIGHT|V_SNAPTOTOP, nil, col, 31)
			else
				V_drawString(v, x, y, "INVALID SKILL", "NFNT", V_SNAPTORIGHT|V_SNAPTOTOP, nil, 0, 31)
			end

			y = $+10
		end
	end
	
	-- fusion animation: HUD part...
	if s == FS_FUSIONANIM
		local timer = e.evttimer
		
		if timer > TICRATE*9 + TICRATE/2
		and timer < TICRATE*12 +5
			
			local t = timer - (TICRATE*9 + TICRATE/2)
			
			v.fadeScreen(31, min(10, t))
			
			DisplayPhysHUD(v, "fusion", consoleplayer)
			
			if t > 10
				local fadein = max(0, (10 - t)/3)
				
				PDraw(v, 160, 100, v.cachePatch("FUSIONB"), fadein << V_ALPHASHIFT)
				
				if t > TICRATE
					local newt = t-TICRATE
					v.drawScaled(160*FRACUNIT, 100*FRACUNIT, FRACUNIT/2 + newt*FRACUNIT/12, v.cachePatch("FUSIONB"), min(9, 2 + newt/3)<<V_ALPHASHIFT)
					PDraw(v, 160, 100, v.cachePatch("FUSIONB"), fadein << V_ALPHASHIFT)
				end
				
				-- Draw the personas...
				
				local cardpatch = v.cachePatch("SHFLFL")
				local init_coords = {
					
					{160-70, 130},
					{160+70, 130},
					{160, 100-20},
					{160, 100+90},
				}
						
				for i = 1, #e.personas-1
					local subp = e.personas[i]
					local subp_c = subp.ref	-- current subpersona data
					local sprname = sprnames[subp_c.sprite]
					local sprframe = string.char((subp_c.frame & FF_FRAMEMASK) + 65)
					local patch = v.cachePatch(sprname..sprframe.."0")	-- eg: SUBPA0					
					
					PDraw(v, init_coords[i][1], init_coords[i][2], cardpatch, fadein << V_ALPHASHIFT)
					PDraw(v, init_coords[i][1], init_coords[i][2], patch, fadein << V_ALPHASHIFT)
					
				end			

				local part = phud.create(mo.player.P_party, N_RandomRange(0, 360), 210, "SUBP1", TICRATE*5, nil, "fusion")

				part.anim = {"SSPKA0", "SSPKB0", "SSPKC0", "SSPKB0", 3}
				part.momy = N_RandomRange(3, 8)
				part.deleteoffscreen = false
				part.physflags = PF_NOGRAVITY
				part.fuse = TICRATE*10
				part.scale = (FRACUNIT/2)*(N_RandomRange(8, 12)/10)
				part.flags = V_SNAPTOBOTTOM
							
			end
			
			if timer == TICRATE*12 + 4
				phud.clear("fusion")
			end	
		end
			
		if timer >= TICRATE*12
			local t = (timer) - TICRATE*12
			local pp = "H_ATR"..t/2
			if v.patchExists(pp)
				drawScreenwidePatch(v, v.cachePatch(pp))
			end
		end
		
		if timer > TICRATE*14
			local t = timer - TICRATE*14
			local fadein = max(0, (9 - t/3))
			
			local cardpatch = v.cachePatch("SHFLFL")
			local subp = e.personas[#e.personas]
			local subp_c = subp.ref	-- current subpersona data
			local sprname = sprnames[subp_c.sprite]
			local sprframe = string.char((subp_c.frame & FF_FRAMEMASK) + 65)
			local patch = v.cachePatch(sprname..sprframe.."0")	-- eg: SUBPA0					
			
			v.fadeScreen(31, min(5, t/3))
			
			DisplayPhysHUD(v, "fusion", consoleplayer)
			
			PDraw(v, 160, 130, cardpatch, fadein << V_ALPHASHIFT)
			PDraw(v, 160, 130, patch, fadein << V_ALPHASHIFT)			

			local part = phud.create(mo.player.P_party, 160, 100, "SUBP1", TICRATE*5, nil, "fusion")

			part.anim = {"SSPKA0", "SSPKB0", "SSPKC0", "SSPKB0", 3}
			part.momy = N_RandomRange(-5, 5)
			part.momx = N_RandomRange(-5, 5)
			part.deleteoffscreen = false
			part.physflags = PF_NOGRAVITY
			part.fuse = TICRATE*3
			part.destscale = 1
			part.scalespeed = FRACUNIT/24
			
		end
	end
	
	-- when applicable, display choices:
	local choices = fusion_choices[e.state]

	if choices and #choices

		local top = 130 + e.hudtimers.enter*16 - 18 - (16*(#choices-1))
		local dx = 210
		for i = 1, #choices
			local c = choices[i]
			local dy = top + (i-1)*16 + (e.hudtimers.enter*20 or 0)

			if e.textchoice == i
				PDraw(v, dx, dy, v.cachePatch("H_TBOXS2"), V_SNAPTOBOTTOM)
				V_drawString(v, 210 + 40, dy + 5, c, "NFNT", V_SNAPTOBOTTOM, "center", 31, 138)
			else
				PDraw(v, dx, dy, v.cachePatch("H_TBOXS1"), V_SNAPTOBOTTOM|V_30TRANS)
				V_drawString(v, dx + 40, dy + 5, c, "NFNT", V_SNAPTOBOTTOM, "center", 0, 31)
			end
		end
	end
	
	-- text box whenever applicable:
	local tdata = e.currtextdata
	if tdata
		local name = tdata[1]
		local text = tdata[2]
		local portrait = tdata[3]
		local colour = tdata[4]
		local timer = e.hudtimers.enter
		local texttimer = e.texttimer

		R_drawTextBox(v, name, text, portrait, colour, timer, texttimer)
	end

	if showmoney	-- show that at the end to make sure it's not overlapped.
		drawMoney(v, mo, moneytimer)
	end
	return true	-- running
end)