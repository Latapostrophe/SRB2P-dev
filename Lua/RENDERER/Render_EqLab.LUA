-- Rendering functions for shops.

local eqlab_choices = {

	[ELS_MAIN] = {
		"Enhance",
		"Desynthetize",
		"Equip. Fusion",
		"Leave"
	},

	[ELS_GRIND_CONFIRM] = {
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
	},
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

rawset(_G, "R_drawEquipLab", function(v, mo)
	if not mo.equiplab
	or not mo.equiplab.using return end	-- bruh!
	local e = mo.equiplab
	local s = e.state

	local pa = mo.player.P_party
	local party = server.plentities[pa]
	local btl = server.P_BattleStatus[pa]

	-- state specific drawing:

	if s == ELS_FUSION_SELECTPERSONA
	or s == ELS_FUSION_CONFIRM
	or s == ELS_FUSION_ASKUNEQUIP
	or s == ELS_FUSION_FAIL
	or s == ELS_FUSION_NOTYOURS
	or s == ELS_FUSION_SUCCESS
		
		local timer = 0
		PDraw(v, 0, -timer*96, v.cachePatch("M_EQUIW3"), V_FLIP|V_SNAPTOLEFT|V_SNAPTOTOP|TR_TRANS40)

		v.drawFill(0, 10, 140 - timer*32, 1, 135|V_SNAPTOTOP|V_SNAPTOLEFT)
		V_drawString(v, 2 - timer*32, 2, "SELECT PERSONA", "FPIMP", V_SNAPTOTOP|V_SNAPTOLEFT, nil, 135, nil)
		
		local y = 20 - 10*e.selectscroll
		for i = 2, #btl.subpersonas do
			local subp = btl.subpersonas[i]
			
			if y < 20
				y = $+10
				continue
			elseif i - e.selectscroll > 8
				break
			end
			
			if i == e.selectequip
				v.drawFill(0, y-1, 128, 12, 135|V_SNAPTOTOP|V_SNAPTORIGHT)
			end
			
			local equipped = subp.equipped
			local plyr = server.plentities[mo.player.P_party][equipped]
			
			local nequipped = equipped and plyr.control ~= mo.player	-- we aren't controlling that bot.
			
			-- grey out this text if a sub-persona is equipped and we don't control that bot
			V_drawString(v, 8, y, ICO_PERSONA..subp.ref.name.." Lv."..subp.level, "NFNT", V_SNAPTORIGHT|V_SNAPTOTOP, nil, nequipped and 16 or 0, 31)
			-- if it's equipped, show who has it equipped
			if equipped
				
				PDraw(v, 108 - timer*40, y+1, v.cachePatch(charStats[plyr.stats].icon), V_SNAPTORIGHT|V_SNAPTOTOP, v.getColormap(TC_DEFAULT, plyr.color))
			end
			
			y = $+10
		end
		
		-- Display info about the sacrifice Persona, the newly created weapon AND the materials / macca needed.
		local persona = btl.subpersonas[e.selectequip]
		y = 12
		
		if persona
			PDraw(v, 320 + timer*96, y-10, v.cachePatch("H_ENH2"), V_SNAPTORIGHT|V_30TRANS)
		
			v.drawFill(150 + timer*96, y-2, 999, 1, 135|V_SNAPTORIGHT)
			V_drawString(v, 150 + timer*96, y-10, "SACRIFICE INFO", "FPIMP", V_SNAPTORIGHT, nil, 135, nil)

			V_drawString(v, 150 +timer*96, y, ICO_PERSONA..(persona.ref.name).." Lv."..persona.level, "NFNT", V_SNAPTORIGHT, nil, 0, 31)
			local checkstats = {"St", "Ma", "En", "Ag", "Lu"}
			local stats = ""
			
			for i = 1, #checkstats do
				stats = $..checkstats[i]..": "..(persona[checkstats[i]:lower()] or 0).." "
			end
			
			V_drawString(v, 150 +timer*96, y+10, stats, "NFNT", V_SNAPTORIGHT, nil, 0, 31)			
			
			local skills = ""
			-- Append skill names'
			for i = 1, #persona.skills
				skills = $..(attackDefs[persona.skills[i]] and attackDefs[persona.skills[i]].name or "INVALID SKILL")..(i < #persona.skills and ", " or "")
			end
			local stlen = V_stringWidth(v, skills, "NFNT")
			local stringtype = "NFNT"
			
			if stlen > 160*FRACUNIT
				stringtype = "TFNT"
			end	
			
			V_drawString(v, 150 +timer*96, y+20, skills, stringtype, V_SNAPTORIGHT, nil, 0, 31)
			
			y = $+40
			
			-- Display info about the preview weapon:
			if e.weaponpreview
				local wpn = e.weaponpreview
				
				PDraw(v, 320 + timer*96, y-10, v.cachePatch("H_ENH2"), V_SNAPTORIGHT|V_30TRANS)
				
				v.drawFill(150 + timer*96, y-2, 999, 1, 135|V_SNAPTORIGHT)
				V_drawString(v, 150 + timer*96, y-10, "WEAPON PREVIEW", "FPIMP", V_SNAPTORIGHT, nil, 135, nil)

				local checkstats = {"ATK", "ACC", "CRIT"}
				local checkstats2 = {"St", "Ma", "En", "Ag", "Lu"}
				
				local arr1 = leveltime%30 < 15 and "\x82<\x80" or "\x82<\x80 "
				local arr2 = leveltime%30 < 15 and "\x82>\x80" or " \x82>\x80"
				
				V_drawString(v, 190 +timer*96, y, arr1..buildWeaponName(wpn)..arr2, "NFNT", V_SNAPTORIGHT, "center", 0, 31)
				renderRarity(v, 260 -timer*32, y, wpn.rarity, V_SNAPTORIGHT)
				-- draw wpn element (wow!)
				if wpn.element
					v.drawScaled(250<<FRACBITS, (y)<<FRACBITS, FRACUNIT/4, v.cachePatch("AT2_"..atk_constant_2_num[wpn.element]), V_SNAPTORIGHT)
				end
				
				-- and now the rest of the stats:
				local str = ""
				for i = 1, #checkstats do

					local mult = (i == 1) and 10 or 1
					str = $..checkstats[i]..": "..(wpn[checkstats[i]:lower()] / mult).." "
				end
				str = $.."\n"
				for i = 1, #checkstats2
					str = $..checkstats2[i]..": "..wpn[checkstats2[i]:lower()].." "
				end				
				
				V_drawString(v, 150 +timer*96, y+10, str, "NFNT", V_SNAPTORIGHT, nil, 0, 31)
				
				-- Draw requirements:
				
				y = $+40
				local t = equipGrindTiers[getEquipGrindTier(wpn)]
				-- draw background 2:
				PDraw(v, 320 + timer*96, y-10, v.cachePatch("H_ENH2"), V_SNAPTORIGHT|V_30TRANS)

				v.drawFill(150 + timer*96, y, 999, 1, 135|V_SNAPTORIGHT)

				V_drawString(v, 150 + timer*96, y-8, "YOU NEED", "FPIMP", V_SNAPTORIGHT, nil, 135, nil)
				V_drawString(v, 230 + timer*96, y-8, "YOU HAVE", "FPIMP", V_SNAPTORIGHT, nil, 135, nil)
				local fact = 10 + wpn.rarity

				-- YOU NEED:

				local s = ""

				for i = 1, #t +1 do
					if i == 1
						s = $..(t[i]*fact)..currency.."\n"
					elseif i == #t +1
						s = $..buildItemName(itemDefs["nihil frame"]).." x1\n"
					else
						s = $..buildItemName(itemDefs[t[i][1]]).." x"..(t[i][2]*fact).."\n"
					end
				end

				V_drawString(v, 150, y+4, s, "NFNT", V_SNAPTORIGHT, nil, 0, 31)

				-- YOU HAVE:
				-- first line is always macca:
				s = ""

				for i = 1, #t +1 do
					local colour = "\x80"
					local have
					local req = t[i]

					if i == 1	-- macca
						have = btl.macca
						req = t[i]*fact
						if have < req
							colour = "\x85"
						end

						s = $..colour..have..currency.."\n"
						
					else
						req = t[i]
						have = BTL_findItem(btl, i < #t+1 and t[i][1] or "nihil frame")
						if have
							have = btl.items[have]
						end

						local amount = have and have[2] or 0
						if amount < (i < #t+1 and t[i][2]*fact or 1)
							colour = "\x85"
						end

						s = $..colour..buildItemName(i < #t+1 and itemDefs[t[i][1]] or itemDefs["nihil frame"]).." x"..amount.."\n"
					end
				end

				V_drawString(v, 230, y+4, s, "NFNT", V_SNAPTORIGHT, nil, 0, 31)		
				
			end
		end
		
	elseif s == ELS_DESYNTH_SELECTWEP
	or s == ELS_DESYNTH_CONFIRM
	or s == ELS_DESYNTH_FAIL
	or s == ELS_DESYNTH_SUCCESS

		-- display list of items
		local t = e.selectequiptype == 1 and btl.weapons or btl.armours
		local buildnamefunc = e.selectequiptype == 1 and buildWeaponName or buildRingName
		local checkstats = {"ATK", "ACC", "CRIT"}
		local checkstats2 = {"St", "Ma", "En", "Ag", "Lu"}
		if e.selectequiptype == 2
			checkstats = {"DEF"}
			checkstats2 = {"HP", "SP"}
		end

		local timer = 0

		PDraw(v, 320, -timer*96, v.cachePatch("M_EQUIW3"), V_SNAPTORIGHT|V_SNAPTOTOP|TR_TRANS40)


		local categories = {"WEAPONS", "RINGS"}

		v.drawFill(185 + timer*32, 10, 999, 1, 135|V_SNAPTOTOP|V_SNAPTORIGHT)
		local x = 185
		for i = 1, #categories
			if i == e.selectequiptype
				v.drawFill(x-2, 1, V_stringWidth(v, categories[i], "FPIMP")/FRACUNIT +4, 10, 135|V_SNAPTOTOP|V_SNAPTORIGHT)
			end
			V_drawString(v, x + timer*96, 2, categories[i], "FPIMP", V_SNAPTOTOP|V_SNAPTORIGHT, nil, e.selectequiptype == i and 31 or 135, nil)

			x = $+ (V_stringWidth(v, categories[i], "FPIMP")/FRACUNIT) +10
		end

		local y = 16
		for i = e.selectscroll+1, e.selectscroll+11 do

			local w = t[i]

			if i == e.selectequip
				v.drawFill(183, y-1, 999, 12, 135|V_SNAPTOTOP|V_SNAPTORIGHT)
			end

			V_drawString(v, 185, y, buildnamefunc(w), "NFNT", V_SNAPTORIGHT|V_SNAPTOTOP, nil, 0, 31)
			y = $+10
		end

		if not #t
			V_drawString(v, 185, 32, "NO ITEMS", "NFNT", V_SNAPTOTOP|V_SNAPTORIGHT, nil, 0, 31)
		end

		local it = t[e.selectequip]
		if it	-- make sure item exists
			
			PDraw(v, -timer*32, 8, v.cachePatch("H_ENH3"), V_SNAPTOLEFT|V_30TRANS)
			
			v.drawFill(0, 16, 140 - timer*32, 1, 135|V_SNAPTOTOP|V_SNAPTOLEFT)
			V_drawString(v, 2 - timer*32, 8, "FODDER INFORMATION", "FPIMP", V_SNAPTOTOP|V_SNAPTOLEFT, nil, 135, nil)

			V_drawString(v, 2 - timer*32, 18, buildnamefunc(it), "NFNT", V_SNAPTOTOP|V_SNAPTOLEFT, nil, 0, 31)
			renderRarity(v, 118 -timer*32, 18, it.rarity, V_SNAPTOLEFT|V_SNAPTOTOP)
			if it.element
				v.drawScaled((108 - timer*32)<<FRACBITS, (18)<<FRACBITS, FRACUNIT/4, v.cachePatch("AT2_"..atk_constant_2_num[it.element]), V_SNAPTORIGHT)
			end		

			local str = ""
			for i = 1, #checkstats do

				local mult = (i == 1) and 10 or 1
				str = $..checkstats[i]..": "..(it[checkstats[i]:lower()] / mult).." "
			end
			str = $.."\n"
			for i = 1, #checkstats2
				str = $..checkstats2[i]..": "..it[checkstats2[i]:lower()].." "
			end

			if it.level >= 10
			and it.slot
				str = $.."\n"
				local atk = it.slot
				if attackDefs[atk]
					atk = attackDefs[atk].name
				end
				str = $..ICO_SKILLCARD..atk
			end

			V_drawString(v, 2 - timer*32, 28, str, "NFNT", V_SNAPTOLEFT|V_SNAPTOTOP, nil, 0, 31)

			-- draw what we'll ge
			PDraw(v, -timer*32, 56, v.cachePatch("H_ENH3"), V_SNAPTOLEFT|V_30TRANS)
			v.drawFill(0, 64, 140 - timer*32, 1, 135|V_SNAPTOTOP|V_SNAPTOLEFT)
			V_drawString(v, 2 - timer*32, 56, "DESYNTHESIS PRODUCT", "FPIMP", V_SNAPTOTOP|V_SNAPTOLEFT, nil, 135, nil)

			local g = equipGrindTiers[getEquipGrindTier(it)]
			-- g[1] is macca, and we won't get macca for desynthesis, duh.
			-- desynthesis gives you a base of 2 levels worth of materials and more for each level the weapon already had.

			str = ""

			local lv = it.level + 2
			for i = 2, #g
				local item = g[i][1]
				local amount = g[i][2] * lv

				str = $..buildItemName(itemDefs[item]).." x"..amount.."\n"
			end

			V_drawString(v, 2 - timer*32, 66, str, "NFNT", V_SNAPTOTOP|V_SNAPTOLEFT, nil, 0, 31)
		end

	elseif s == ELS_GRIND_SELECTWEP	-- weapon selection
	or s == ELS_GRIND_CONFIRM
	or s == ELS_GRIND_BROKE
	or s == ELS_GRIND_SUCCESS
	or s == ELS_GRIND_MAXLEVEL

		if e.lastsource	-- make sure this is valid.
			local timer = e.hudtimers.grindstart or 0

			local member = party[e.selectparty]
			local equip = e.lastsource
			local mybot = member.control == mo.player

			local wep = member.weapon
			local rng = member.wardring
			local namebuildfunc
			local ittype = 1

			-- player head icons above:
			-- first we need to find the starting player
			local start = e.selectparty-1
			if start == 0
				start = #party
			end

			local tflag = {TR_TRANS50, 0, TR_TRANS50}
			for i = 1, 3

				-- draw icon
				local skin = party[start].skin
				local stats = charStats[skin]
				local pp = v.cachePatch(stats.icon)

				local x = -timer*64 +32 + (i-1)*12

				PDraw(v, x, 8, pp, V_SNAPTOTOP|V_SNAPTOLEFT|tflag[i], v.getColormap(TC_DEFAULT, party[start].color))

				start = $+1
				if start > #party
					start = 1
				end
			end
			-- draw arrows to show we can cycle:
			local str = leveltime%10 < 5 and "<        >" or "<          >"
			V_drawString(v, -timer*32 +48, 8, "\x82"..str, "NFNT", V_SNAPTOTOP|V_SNAPTOLEFT, "center", 0, 31)
			
			-- Draw window
			PDraw(v, -timer*64, 0, v.cachePatch("M_EQUIW2"), V_SNAPTOLEFT|V_SNAPTOTOP|TR_TRANS40)
			PDraw(v, -timer*64, 0, v.cachePatch("M_EQUIW1"), V_SNAPTOLEFT|V_SNAPTOTOP)

			V_drawString(v, -timer*64 +8, 30, member.name.." LV"..member.level, "NFNT", V_SNAPTOTOP|V_SNAPTOLEFT, nil, 0, nil)

			v.drawFill(-timer*64+4, 75, 90, 1, 135|V_SNAPTOTOP|V_SNAPTOLEFT)

			-- draw my total stats:
			local totalstr = "ATK: "..(wep.atk/10).." DEF: "..(rng.def/10).."\n"
			local read = {wep, rng}
			local stats = {{"St", "Ma", "En", "Ag", "Lu"}, {"HP", "SP"}}
			for i = 1, #read
				for j = 1, #stats[i]
					local stat = stats[i][j]:lower()
					if read[i][stat]
						totalstr = $..stats[i][j]..": "..read[i][stat].." "
					end
				end
				totalstr = $.."\n"
			end

			V_drawString(v, -timer*64 +8, 80, "STATS TOTAL: \n", "NFNT", V_SNAPTOTOP|V_SNAPTOLEFT, nil, 0, 31)
			V_drawString(v, -timer*64 +8, 90, totalstr, "NFNT", V_SNAPTOTOP|V_SNAPTOLEFT, nil, 0, 31, FRACUNIT/3)

			if wep
				if e.selectequip == 1
					v.drawFill(-timer*64 + 4, 48, 128, 12, 135|V_SNAPTOTOP|V_SNAPTOLEFT)
					namebuildfunc = buildWeaponName
				end

				V_drawString(v, -timer*64 +8, 50, buildWeaponName(wep), "NFNT", V_SNAPTOTOP|V_SNAPTOLEFT, nil, (not mybot) and 16 or 0, 31)

				-- weapon power:
				V_drawString(v, -timer*64 +92, 52, "ATK", "FPIMP", V_SNAPTOTOP|V_SNAPTOLEFT, nil, (not mybot) and 16 or 0, 31, FRACUNIT/4)
				V_drawString(v, -timer*64 +108, 51, (wep.atk/10), "FPNUM", V_SNAPTOTOP|V_SNAPTOLEFT, nil, (not mybot) and 16 or 0, 31)
			end
			if rng
				-- this code sucks
				if e.selectequip == 2
					v.drawFill(-timer*64 + 4, 60, 128, 12, 135|V_SNAPTOTOP|V_SNAPTOLEFT)
					namebuildfunc = buildRingName
					ittype = 2
				end

				V_drawString(v, -timer*64 +8, 62, buildRingName(rng), "NFNT", V_SNAPTOTOP|V_SNAPTOLEFT, nil, (not mybot) and 16 or 0, 31)

				-- ring def:
				V_drawString(v, -timer*64 +92, 64, "DEF", "FPIMP", V_SNAPTOTOP|V_SNAPTOLEFT, nil, (not mybot) and 16 or 0, 31, FRACUNIT/4)
				V_drawString(v, -timer*64 +108, 63, (rng.def/10), "FPNUM", V_SNAPTOTOP|V_SNAPTOLEFT, nil, (not mybot) and 16 or 0, 31)
			end

			local it1 = e.lastsource
			local it2 = e.sourcecopy

			--V_drawString(v, 160, 100, namebuildfunc(it1).." -> "..namebuildfunc(it2), "NFNT", 0, nil, 0, 31)
			-- draw the weapon infos
			local curwep = it1
			local y = 16

			-- draw background 1:
			PDraw(v, 320 + timer*96, 0, v.cachePatch("H_ENH1"), V_SNAPTORIGHT|V_30TRANS)

			v.drawFill(150 + timer*96, y-2, 999, 1, 135|V_SNAPTORIGHT)
			V_drawString(v, 150 + timer*96, y-10, "PENDING ENHANCEMENT", "FPIMP", V_SNAPTORIGHT, nil, 135, nil)
			
			if not e.sourcecopy return end	-- what the fuck!
			
			V_drawString(v, 150 +timer*96, y, namebuildfunc(e.sourcecopy), "NFNT", V_SNAPTORIGHT, nil, 0, 31)
			renderRarity(v, 260 +timer*96, y, e.sourcecopy.rarity, V_SNAPTORIGHT)
			if e.sourcecopy.element
				v.drawScaled((250 + timer*96)<<FRACBITS, (y+1)<<FRACBITS, FRACUNIT/4, v.cachePatch("AT2_"..atk_constant_2_num[e.sourcecopy.element]), V_SNAPTORIGHT)
			end	

			local rstats = {}

			if ittype == 1	-- weapon
				rstats[1] = {"ATK", "ACC", "CRIT"}
				rstats[2] = {"St", "Ma", "En", "Ag", "Lu"}
			else			-- ring
				rstats[1] = {"DEF"}
				rstats[2] = {"HP", "SP"}
			end

			local x = 150
			local by = y+10
			local y = by

			for i = 1, 2
				for j = 1, #rstats[i]
					local fstat = rstats[i][j]
					local stat = fstat:lower()

					local newcolour = ""
					
					if it2[stat] == nil 
					or it1[stat] == nil
						continue
					end	--???	
					
					if it2[stat] > it1[stat]
						newcolour = "\x82"
					elseif it2[stat] < it1[stat]
						newcolour = "\x85"
					end

					local statmod = 1
					if j == 1
					and i == 1		-- ATK & DEF should be divided by 10.
						statmod = 10
					end

					V_drawString(v, x + timer*96, y, fstat..": "..(it1[stat]/statmod).."->"..newcolour..(it2[stat]/statmod), "NFNT", V_SNAPTORIGHT, nil, 0, 31)
					y = $+10
				end

				y = by
				x = $ + 110
			end

			-- draw slot
			if it2.level >= 10
			and it2.slot
				local colour = it1.level < 10 and "\x82" or ""
				local atk = colour..ICO_SKILLCARD..((it2.slot and attackDefs[it2.slot]) and attackDefs[it2.slot].name or tostring(it2.slot))
				V_drawString(v, 150 + timer*96, y + 30, atk, "NFNT", V_SNAPTORIGHT, nil, 0, 31)
			end

			y = by+70

			local t = equipGrindTiers[getEquipGrindTier(it1)]
			-- draw background 2:
			PDraw(v, 320 + timer*96, y-10, v.cachePatch("H_ENH2"), V_SNAPTORIGHT|V_30TRANS)

			v.drawFill(150 + timer*96, y, 999, 1, 135|V_SNAPTORIGHT)

			if it1.level >= 10
				V_drawString(v, 150 + timer*96, y+4, "\x82".."This item cannot be enhanced furhter", "NFNT", V_SNAPTORIGHT, nil, 0, 31)
			else

				V_drawString(v, 150 + timer*96, y-8, "YOU NEED", "FPIMP", V_SNAPTORIGHT, nil, 135, nil)
				V_drawString(v, 230 + timer*96, y-8, "YOU HAVE", "FPIMP", V_SNAPTORIGHT, nil, 135, nil)

				-- YOU NEED:

				local s = ""

				for i = 1, #t do
					if i == 1
						s = $..t[i]..currency.."\n"
					else
						s = $..buildItemName(itemDefs[t[i][1]]).." x"..t[i][2].."\n"
					end
				end

				V_drawString(v, 150, y+4, s, "NFNT", V_SNAPTORIGHT, nil, 0, 31)

				-- YOU HAVE:
				-- first line is always macca:
				s = ""

				for i = 1, #t
					local colour = "\x80"
					local have
					local req = t[i]

					if i == 1	-- macca
						have = btl.macca
						req = t[i]
						if have < req
							colour = "\x85"
						end

						s = $..colour..have..currency.."\n"

					else
						req = t[i]
						have = BTL_findItem(btl, t[i][1])
						if have
							have = btl.items[have]
						end

						local amount = have and have[2] or 0
						if amount < t[i][2]
							colour = "\x85"
						end

						s = $..colour..buildItemName(itemDefs[t[i][1]]).." x"..amount.."\n"
					end
				end

				V_drawString(v, 230, y+4, s, "NFNT", V_SNAPTORIGHT, nil, 0, 31)
			end
		end
	end

	-- when applicable, display choices:
	local choices = eqlab_choices[e.state]

	if choices and #choices

		if e.state == ELS_GRIND_CONFIRM
		or e.state == ELS_DESYNTH_CONFIRM
		or e.state == ELS_FUSION_CONFIRM
		or e.state == ELS_FUSION_ASKUNEQUIP
			v.fadeScreen(31, 7)
		end

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

	-- some hudtimer anims:
	if e.hudtimers.enhancesuccess
	or e.hudtimers.desynthsuccess
	or (e.hudtimers.fusionbroke and e.state == ELS_FUSION_SUCCESS)
		local t = TICRATE- (e.hudtimers.fusionbroke or e.hudtimers.enhancesuccess or e.hudtimers.desynthsuccess)
		local pp = "H_ATR"..t/2
		if v.patchExists(pp)
			drawScreenwidePatch(v, v.cachePatch(pp))
		end
	end

	return true	-- running
end)