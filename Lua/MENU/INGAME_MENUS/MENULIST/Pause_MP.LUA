
-- main pause menu for multiplayer

-- draw the main command selection like battles
local cmd_names = {
	"SKILL",
	"ITEMS",
	"PERSONA",
	"PARTY",
	--"SOCIAL LINK",
	"EQUIPMENT"
}

local cmd_hints = {
	"Use healing skills or equip Skill Cards",
	"Use healing items",
	"View or switch Sub-Personas",
	"View party status",
	--"View Social Links",
	"Change your equipment",
}

local cmd_gfx = {
	"H_CMD2",
	"H_CMD3",
	"H_CMD4",
	"M_PARTY",
	--"M_SLINK",
	"M_EQUIP",
}

local function drawStatuses(v, mo, timer)

	local btl = server.P_BattleStatus[mo.player.P_party]
	if not btl return end

	-- draw backdrop:
	local x = 0 - 24*timer
	local y = 80
	PDraw(v, x, y, v.cachePatch("H_MACCA"), V_SNAPTOTOP|V_SNAPTOLEFT)
	V_drawString(v, x+55, y+9, btl.macca, "FPNUM", V_SNAPTOTOP|V_SNAPTOLEFT, "right", 31, nil)
end

local function drawMenu_main(v, mo, choice, forcetimer, drawbars)
	--local battle = server.P_BattleStatus
	local timers = mo.m_hudtimers
	local timer = timers.sclosemenu and (TICRATE/3 - timers.sclosemenu) or timers.smenuopen or 0
	if forcetimer ~= nil
		timer = forcetimer
	end
	-- center x y are of fixed position, don't bother:
	local cx, cy = 20<<FRACBITS, 135<<FRACBITS
	local s_ang = ANG1*72
	local b_ang = ANG1*65 + (choice-1)*s_ang - ANG1*24*(mo.m_main_renderangle or 0) -- base angle for drawing
	local radius = 48 + 32*timer

	-- fade
	--local fade = V_50TRANS
	--if timer
	--	fade = V_90TRANS - ((TICRATE/3 - timer)/3)*V_10TRANS
	--end
	--v.drawScaled(160<<FRACBITS, 100<<FRACBITS, t*FRACUNIT/2, v.cachePatch("H_1M_B"), fade)

	-- draw macca, time, etc...
	drawStatuses(v, mo, timer)

	-- render BG
	PDraw(v, 0 - 24*timer, 200 + 24*timer, v.cachePatch("H_CMDBC"), V_SNAPTOBOTTOM|V_SNAPTOLEFT)

	for i = 1, 5
		local angle = b_ang - (i-1)*s_ang - 16*timer*ANG1	-- start timer fancies
		local x = cx + radius*FixedMul(FRACUNIT*5/4, cos(angle)) - abs(16*cos(angle))	-- adjust to ease shape on X coord
		local y = cy + FixedMul(FRACUNIT*2/3, radius*sin(angle))	-- scale Y so that it looks more like an oval
		local scale = (FRACUNIT/4 + cos(angle-ANG1*65)/6 + timer*FRACUNIT/6)

		v.drawScaled(x, y, scale, v.cachePatch(cmd_gfx[i]), V_SNAPTOBOTTOM|V_SNAPTOLEFT)
	end

	-- hint text
	v.drawFill(0, 182, 450 - timer*80, 8, 135|V_SNAPTOBOTTOM|V_SNAPTOLEFT)
	V_drawString(v, 20, 182, cmd_hints[choice], "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 31, nil)

	-- command name
	V_drawString(v, 20 - timer*8, 190, cmd_names[choice]:upper(), "FPIMP", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 0, 31)

	-- little extra...
	if drawbars
		renderPartyBars(v, mo.player)
	end

	local cmd = {
					{BUTT_DPAD, "Select"},
					{BUTT_A, "Confirm"},
					{BUTT_B, "Exit"},
				}
	V_drawCommands(v, cmd)

end

-- draw the main command selection fading out when you get to a new menu.
local function drawPlayerCommands_Out(v, mo, choice)
	local timer = mo.m_hudtimers.smenuopen
	local bg_timer = timer-1

	-- center x y are of fixed position, don't bother:
	local cx, cy = 20<<FRACBITS, 135<<FRACBITS
	local b_ang = ANG1*65
	local radius = 48

	-- render BG
	PDraw(v, -144 + 24*bg_timer, 344 - 24*bg_timer, v.cachePatch("H_CMDBC"), V_SNAPTOBOTTOM|V_SNAPTOLEFT)
	local x = cx + radius*FixedMul(FRACUNIT*5/4, cos(b_ang)) - abs(16*cos(b_ang))	-- adjust to ease shape on X coord
	local y = cy + FixedMul(FRACUNIT*2/3, radius*sin(b_ang))	-- scale Y so that it looks more like an oval
	local scale = FRACUNIT/4 + cos(0)/6
	v.drawScaled(x, y, scale, v.cachePatch(cmd_gfx[choice]), V_SNAPTOBOTTOM|V_SNAPTOLEFT )
end

-- draw the main command selection fading back in when exiting from a submenu to the main menu
local function drawPlayerCommands_In(v, mo, choice)
	local timer = 7-mo.m_hudtimers.sclosemenu

	-- center x y are of fixed position, don't bother:
	local cx, cy = 20<<FRACBITS, 135<<FRACBITS
	local radius = 48 - 24*mo.m_hudtimers.sclosemenu
	local s_ang = ANG1*72
	local b_ang = ANG1*65 + (choice-1)*s_ang

	-- render BG
	PDraw(v, -144 + 24*timer, 344 - 24*timer, v.cachePatch("H_CMDBC"), V_SNAPTOBOTTOM|V_SNAPTOLEFT)
	for i = 1, 5
		local r_radius = i-1 == (choice-1) and 48 or radius
		local angle = b_ang - (i-1)*s_ang
		local x = cx + r_radius*FixedMul(FRACUNIT*5/4, cos(angle)) - abs(16*cos(angle))	-- adjust to ease shape on X coord
		local y = cy + FixedMul(FRACUNIT*2/3, r_radius*sin(angle))	-- scale Y so that it looks more like an oval
		local scale = max(1, FRACUNIT/4 + cos(angle-ANG1*65)/6 - mo.m_hudtimers.sclosemenu*(i-1 ~= (choice-1) and FRACUNIT/12 or 0))
		v.drawScaled(x, y, scale, v.cachePatch(cmd_gfx[choice]), V_SNAPTOBOTTOM|V_SNAPTOLEFT)
	end
end

-- draw party status + selection
local function M_drawPartyStatus(v, mo, choice)

	local team = server.plentities[mo.player.P_party]
	if not team return end	-- wtf where is our team

	-- draw shit from right to left according to the turn order. It makes our life easier.

	local x = 320	-- - (#team==1 and 65 or 35)
	local i = #team
	-- draw teammates
	while i
		if i == choice	-- selected teammate with a big bar:
			x = $ - (60)
			drawPlayerBar(v, x, 172, team[i])
		else			-- other teammates in smol
			x = $ - (30)
			drawPlayerBarSmall(v, x, 180, team[i])
		end
		i = $-1
	end
end

local function drawPlayerSkillList(v, mo, choice, choice_prev)

	local timer = mo.m_hudtimers.smenuopen
	local out_timer = mo.m_hudtimers.sclosemenu or 7
	local party_choice = mo.m_menuchoices["m_partychoice"]
	local jammed = server.P_DungeonStatus.VR_clause == VE_SKILLJAMMER

	choice_prev = mo.m_menuchoices["m_main"] or 1

	if mo.m_hudtimers.sclosemenu
		PDraw(v, -174 + out_timer*32, 173 - out_timer*4, v.cachePatch("H_BOX_D"), V_SNAPTOBOTTOM|V_SNAPTOLEFT|TR_TRANS30)
		drawPlayerCommands_In(v, mo, choice_prev)	-- for return
	else
		PDraw(v, 50 - timer*32, 145 + timer*4, v.cachePatch("H_BOX_D"), V_SNAPTOBOTTOM|V_SNAPTOLEFT|TR_TRANS30)
		drawPlayerCommands_Out(v, mo, choice_prev)	-- for entry
	end
	for i = 1, #mo.m_healingskills
		local intend_y = 60
		local y = 60 + 32*(i-1) - (choice-1)*32 - (mo.m_selectslide or 0)
		local diff = abs(intend_y - y)
		local skill = attackDefs[mo.m_healingskills[i]]

		if not skill
			dprint("Invalid skill: \'"..mo.m_healingskills[i].."\'")
		end

		local skillcard = (i > mo.m_skillcard_start)	-- draw "skill card" instead of cost
		local tgt = server.plentities[mo.player.P_party][mo.m_menuchoices["m_partychoice"]]
		local equip = tgt and tgt.valid and skillcard and tgt.skillcard == mo.m_healingskills[i]

		drawSkillCommand(v, 0 - timer^2 - (7-out_timer)*24 - (diff^2)/96, y, mo, skill, i == choice, nil, skillcard, equip, mo.m_belongsto[i])
		-- dear god
	end

	-- draw description
	local skill = attackDefs[mo.m_healingskills[choice]]
	local desc = skill and skill.desc or "Invalid skill: '"..mo.m_healingskills[choice].."'"
	if not jammed
		V_drawString(v, 60, 150, desc, "NFNT", V_SNAPTOLEFT|V_SNAPTOBOTTOM, nil, 0, 31)
	end

	-- draw hit rate and power
	v.drawFill(0, 182, 450, 8, 135|V_SNAPTOBOTTOM|V_SNAPTOLEFT)

	if choice <= mo.m_skillcard_start
		local power = not jammed and (skill.power) or "--"
		V_drawString(v, 60, 183, "HEAL "..power, "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 31, nil)
	end

	if skill.target == TGT_ALLALLIES
	and choice <= mo.m_skillcard_start	-- don't do that for skillcards
		party_choice = 0
	end
	M_drawPartyStatus(v, mo, party_choice)

	local cmd = {
					{BUTT_DPAD, "Select skill/target"},
					{BUTT_A, choice < mo.m_skillcard_start and "Use" or "Equip"},
					{BUTT_B, "Exit"},
				}
	V_drawCommands(v, cmd)
end

local function m_skill_inputs(mo)
	local inputs = mo.P_inputs

	if mo.m_selectslide
		mo.m_selectslide = $/2
	end

	local pa = mo.player.P_party

	local pc = "m_partychoice"
	local maxpc = #server.plentities[pa]

	if not mo.m_menuchoices[pc]
		mo.m_menuchoices[pc] = 1
	end

	-- return
	if inputs[BT_USE] == 1
	and not mo.m_exitmenu
		mo.m_hudtimers.sclosemenu = 8
		mo.m_prevmenu = "m_main"
		mo.m_exitmenu = true
		S_StartSound(nil, sfx_cancel, mo.player)
	end

	local maxc = #mo.m_healingskills
	if inputs["down"] == 1
		mo.m_selectslide = mo.m_menuchoices[mo.m_submenu] < #mo.m_healingskills and -32 or #mo.m_healingskills*32
		mo.m_menuchoices[mo.m_submenu] = $+1
		if mo.m_menuchoices[mo.m_submenu] > maxc
			mo.m_menuchoices[mo.m_submenu] = 1
		end
		S_StartSound(nil, sfx_turn, mo.player)

	elseif inputs["up"] == 1
		mo.m_selectslide = mo.m_menuchoices[mo.m_submenu] == 1 and #mo.m_healingskills*-32 or 32
		mo.m_menuchoices[mo.m_submenu] = $-1
		if mo.m_menuchoices[mo.m_submenu] < 1
			mo.m_menuchoices[mo.m_submenu] = maxc
		end
		S_StartSound(nil, sfx_turn, mo.player)
	elseif inputs["right"] == 1
		mo.m_menuchoices[pc] = $+1
		if mo.m_menuchoices[pc] > maxpc
			mo.m_menuchoices[pc] = 1
		end
		S_StartSound(nil, sfx_hover, mo.player)
	elseif inputs["left"] == 1
		mo.m_menuchoices[pc] = $-1
		if mo.m_menuchoices[pc] < 1
			mo.m_menuchoices[pc] = maxpc
		end
		S_StartSound(nil, sfx_hover, mo.player)
	end

	local choice = mo.m_menuchoices[mo.m_submenu]
	if inputs[BT_JUMP] == 1
		--mo.m_hudtimers.m_stats = TICRATE*2/3
		--mo.m_showstats = choice
		-- heal a player

		if choice > mo.m_skillcard_start
			-- we are past the point where everything is skillcards, not healing skills!
			-- instead of using skills, we can equip them, which is very simple.
			-- equip it on our player entity, but check if we don't already have that skill first anyway

			local bot = server.plentities[mo.player.P_party][mo.m_menuchoices[pc]]

			-- if this isn't me, I can't do it!
			if bot.control and bot.control ~= mo.player
				S_StartSound(nil, sfx_not, mo.player)
				return
			end

			-- check if we don't already have that skill
			for i = 1, #bot.skills
				if bot.skills[i] == mo.m_healingskills[choice]
					S_StartSound(nil, sfx_not, mo.player)
					return
				end	-- nope.
			end

			bot.skillcard = mo.m_healingskills[choice]
			S_StartSound(nil, sfx_qsumon, mo.player)
			-- keep it as a string because we'll check later on if it's possible to add it to the skill list.

			return
		end

		local skill = attackDefs[mo.m_healingskills[choice]]
		local tgt = server.plentities[pa][mo.m_menuchoices[pc]]

		local b = mo.m_belongsto[choice]	--mo.player.maincontrol
		-- check for the player the skill belongs to

		if b.sp < skill.cost	-- yikessss
			S_StartSound(nil, sfx_not, mo.player)
			return true
		end

		if not skill.power return end	-- what

		-- case 1: skill heals everyone
		if skill.target == TGT_ALLALLIES
			-- check if everyone is fully healed:
			for i = 1, #server.plentities[pa]
				local m = server.plentities[pa][i]
				if m.hp < m.maxhp
					break	-- SOMEONE needs healing
				end

				if i == #server.plentities[pa]	-- everyone is healed
					S_StartSound(nil, sfx_not, mo.player)
					return true
				end
			end

			-- then heal everyone
			for i = 1, #server.plentities[pa]
				local m = server.plentities[pa][i]
				--m.hp = min(m.maxhp, $ + skill.power)
				DNG_Damage(m, -skill.power)
				S_StartSound(nil, sfx_heal, m.control)
				VFX_Play(m.control.mo, m.control.mo == mo and VFX_HEALSELF or VFX_HEAL)
			end
			if consoleplayer.P_party == pa
				for i = 1, #server.plentities[pa] -- Is everyone fully healed? Let's only note down when someone heals the party to full health
					local m = server.plentities[pa][i]
					if m.hp+skill.power < m.maxhp
						break	-- SOMEONE still needs healing
					end

					if i == #server.plentities[pa]	-- everyone is healed
						DNG_logMessage("\x82"..b.name.."\x80".." healed the party!")
					end
				end
			end

			-- consume SP:
			b.sp = $ - skill.cost

			return true
		else
			-- heal single target

			if tgt.hp >= tgt.maxhp
				S_StartSound(nil, sfx_not, mo.player)
				return true
			end

			--tgt.hp = min(tgt.maxhp, $+skill.power)
			DNG_Damage(tgt, -skill.power)
			S_StartSound(nil, sfx_heal, mo.player)

			if tgt.control == consoleplayer
			and consoleplayer.mo ~= mo
				if tgt.hp + skill.power > tgt.maxhp -- Only log this message when you are fully healed
					DNG_logMessage("\x82"..b.name.."\x80".." healed you.")
				end
				S_StartSound(nil, sfx_heal, tgt.control)
			end
			VFX_Play(tgt.control.mo, tgt.control.mo == mo and VFX_HEALSELF or VFX_HEAL)

			-- consume SP:
			b.sp = $ - skill.cost
		end
	end
	return true

end

local function drawPlayerItemList_New(v, mo, choice, choice_prev)

	choice_prev = mo.m_menuchoices["m_main"] or 1

	local pa = mo.player.P_party
	local btl = server.P_BattleStatus[pa]

	local items = server.P_BattleStatus[pa].items
	local timer = mo.m_hudtimers.smenuopen
	local out_timer = mo.m_hudtimers.sclosemenu or 7
	local tmr = 7 -timer
	local jammed = server.P_DungeonStatus.VR_clause == VE_ITEMJAMMER

	if mo.m_hudtimers.sclosemenu
		tmr = 7 - mo.m_hudtimers.sclosemenu
		timer = tmr
	end

	/*local scale = tmr*FRACUNIT/3
	if scale < FRACUNIT*2
		v.drawScaled(160<<FRACBITS, 100<<FRACBITS, scale, v.cachePatch("H_1M_B"), V_30TRANS)
	else
		v.fadeScreen(135, 7)	-- optimize rendering
	end*/


	-- draw the players HP/SP:
	for i = server.P_netstat.teamlen, 1, -1

		local b = server.plentities[pa][i]
		if i == mo.m_itemtarget
			v.drawFill(0, (i-1)*37, 999, 35, 135|V_SNAPTOLEFT)
			V_drawString(v, 300, (i-1)*37, "USE ITEM", "FPIMP", V_SNAPTORIGHT, "right", 138, nil, FRACUNIT*2)
		end

		if b and b.valid
			drawPlayerBar(v, 50 - (i-1)*10 - timer*32, 15 + (i-1)*37, b, V_SNAPTOLEFT)
		end
	end

	PDraw(v, 300 + timer*64, 0, v.cachePatch("M_ITMS"), V_SNAPTOTOP|V_SNAPTORIGHT|TR_TRANS30)

	if mo.m_hudtimers.sclosemenu
		drawPlayerCommands_In(v, mo, choice_prev)	-- for return
	else
		drawPlayerCommands_Out(v, mo, choice_prev)	-- for entry
	end


	v.drawFill(145 + timer*64, 24, 999, 1, 135|V_SNAPTOTOP|V_SNAPTORIGHT)

	local categories = {
		"BTL",
		"CONSUM",
		"MATS",
		"KEY",
	}

	local categories_tip = {
		"Recovery & other battle items",
		"Items unusable in battle",
		"Equipment enhancement materials",
		"Unique key items"
	}

	if jammed
		local categories = {
			"ERR",
			"ERR",
			"ERR",
			"ERR",
		}

		categories_tip = {
			"Unknown",
			"Unknown",
			"Unknown",
			"Unknown",
		}

	end

	-- categories!
	local x = 155
	for i = 1, #categories

		local selected = mo.m_item_section == i
		local w = (V_stringWidth(v, categories[i], "FPIMP"))/FRACUNIT

		if selected
			for j = 1, 2
				v.drawFill(x-j + timer*64, 15+(j-1)*5, w+4, 5, 135|V_SNAPTOTOP|V_SNAPTORIGHT)
			end
			V_drawString(v, 155 + timer*64, 24, categories_tip[i], "NFNT", V_SNAPTOTOP|V_SNAPTORIGHT, nil, 135, 31)
		end

		V_drawString(v, x + timer*64, 16, categories[i], "FPIMP", V_SNAPTOTOP|V_SNAPTORIGHT, nil, selected and 31 or 135, 0)
		x = $ + w+10
	end


	-- item listing
	local maxitems = #btl.items
	local category_start = {
		0,
		btl.it_section2-1,
		btl.it_section3-1,
		btl.it_section4-1,
	}

	local scroll = mo.m_itemscroll
	local startdisplay = category_start[mo.m_item_section]+1 + scroll
	local enddisplay = (category_start[mo.m_item_section+1]) and (category_start[mo.m_item_section+1] + scroll) or maxitems


	local STARTY = 40
	local YSTEP = 10
	local drawn = 0

	--print(startdisplay.."|"..enddisplay)

	for i = startdisplay, enddisplay
		local y = STARTY + (i - (startdisplay))*YSTEP
		local it = btl.items[i]

		if category_start[mo.m_item_section+1] ~= nil
		and category_start[mo.m_item_section+1]+1 == startdisplay
			break
		end	-- fixes a dumb bug

		if not it continue end
		local itdef = itemDefs[it[1]]

		local itemname = itdef and buildItemName(itdef) or "INVALID ITEM ("..it[1]..")"

		if jammed
			itemname = "JAMMED"
		end

		if mo.m_menuchoices[mo.m_submenu] == i
			for j = 1, 12
				v.drawFill(155-(j-1) + timer*64, y-3+j, 999, 1, 135|V_SNAPTORIGHT|V_SNAPTOTOP)
			end

			local itemdesc = itdef and itdef.desc or "NO DESCRIPTION"
			local itemrarity = itdef and itdef.rarity or 1	-- whatevs lol

			if jammed
				itemdesc = ""
				itemrarity = 0
			end

			V_drawString(v, 130 + timer*64, 145, itemname, "NFNT", V_SNAPTOBOTTOM|V_SNAPTORIGHT, nil, 0, 31)
			renderRarity(v, 130 + timer*64, 155, itemrarity, V_SNAPTOBOTTOM|V_SNAPTORIGHT)
			V_drawString(v, 130 + timer*64, 165, itemdesc, "NFNT", V_SNAPTOBOTTOM|V_SNAPTORIGHT, nil, 0, 31)
		end

		V_drawString(v, 160 + timer*64, y, itemname, "NFNT", V_SNAPTOTOP|V_SNAPTORIGHT, nil, 0, 31)
		V_drawString(v, 300 + timer*64, y, "x"..it[2], "NFNT", V_SNAPTOTOP|V_SNAPTORIGHT, "right", 0, 31)

		drawn = $+1
		if drawn > 9
			break
		end
	end

	-- Blue line
	v.drawFill(130 + timer*64, 142, 999, 1, 135|V_SNAPTOBOTTOM|V_SNAPTORIGHT)

	if not drawn	-- nothing was drawn there?
		V_drawString(v, 160 + timer*64, STARTY, "NO ITEMS", "NFNT", V_SNAPTOTOP|V_SNAPTORIGHT, nil, 0, 31)
	end
end


-- function for using up items
local function m_item_use(mo, itemn)
	local btl = server.P_BattleStatus[mo.player.P_party]
	local t = btl.items

	-- remove item from list
	if BTL_useItem(btl, itemn, true)	-- the item has been used and completely depleted, so, removed.
		mo.m_useitem = nil
		mo.m_itemtarget = nil
	end
end

local function m_item_inputs_New(mo)
	local inputs = mo.P_inputs
	local pa = mo.player.P_party

	--print("input func")

	local btl = server.P_BattleStatus[pa]
	local t = btl.items
	mo.m_menuchoices[mo.m_submenu] = max($, 1)

	-- get max item by section:
	local maxitem = {
		btl.it_section2-1,
		btl.it_section3-1,
		btl.it_section4-1,
		#t
	}

	local minc = maxitem[mo.m_item_section-1] and maxitem[mo.m_item_section-1]+1 or 1
	local maxc = maxitem[mo.m_item_section]
	local maxsection = 4

	local scrolln = 10	-- we can display 10 items without scrolling

	-- er, oh god, items are disappearing!
	if not t[mo.m_menuchoices[mo.m_submenu]]
		mo.m_menuchoices[mo.m_submenu] = max(minc, $-1)	-- go to previous item
		mo.m_itemscroll = max(0, $-1)			-- undo scrolling
		mo.m_useitem = nil
		mo.m_itemtarget = nil
	end

	--if not maxc return end

	if not mo.m_itemtarget
		--print(maxc..", "..minc)
		if inputs["down"] == 1
		and abs(maxc - minc) > 0
			mo.m_menuchoices[mo.m_submenu] = $+1

			-- scrolling
			if mo.m_menuchoices[mo.m_submenu] - mo.m_itemscroll - (minc-1) > scrolln/2
			and maxc > scrolln
			and mo.m_itemscroll < maxc-(minc-1)-scrolln
				mo.m_itemscroll = $+1
			end

			if mo.m_menuchoices[mo.m_submenu] > maxc
				mo.m_menuchoices[mo.m_submenu] = minc
				mo.m_itemscroll = 0
			end
			S_StartSound(nil, sfx_hover, mo.player)

		elseif inputs["up"] == 1
		and abs(maxc - minc) > 0
			mo.m_menuchoices[mo.m_submenu] = $-1

			if mo.m_menuchoices[mo.m_submenu] < maxc - scrolln/2
			and mo.m_itemscroll	-- make sure we don't scroll into negatives rofl
				mo.m_itemscroll = $-1
			end

			if mo.m_menuchoices[mo.m_submenu] < minc
				mo.m_menuchoices[mo.m_submenu] = maxc
				if maxc-(minc-1) > scrolln	-- negative scroll would break horribly
					mo.m_itemscroll = maxc-(minc-1)-scrolln
				end
			end
			S_StartSound(nil, sfx_hover, mo.player)

		-- switching sections
		elseif inputs[BT_BTNL] == 1
		or inputs["left"] == 1
			S_StartSound(nil, sfx_turn, mo.player)
			mo.m_item_section = $-1
			if not mo.m_item_section
				mo.m_item_section = maxsection
			end

			-- set new cursor position
			mo.m_menuchoices[mo.m_submenu] = maxitem[mo.m_item_section-1] and maxitem[mo.m_item_section-1]+1 or 1
			mo.m_itemscroll = 0

		elseif inputs[BT_BTNR] == 1
		or inputs["right"] == 1
			S_StartSound(nil, sfx_turn, mo.player)
			mo.m_item_section = $+1
			if mo.m_item_section > maxsection
				mo.m_item_section = 1
			end

			-- set new cursor position
			mo.m_menuchoices[mo.m_submenu] = maxitem[mo.m_item_section-1] and maxitem[mo.m_item_section-1]+1 or 1
			mo.m_itemscroll = 0

		elseif inputs[BT_BTNA] == 1
		and abs(maxc - minc) >= 0
		and mo.m_menuchoices[mo.m_submenu] >= minc
		and mo.m_menuchoices[mo.m_submenu] <= maxc

			if mo.m_item_section >= 3	-- only the first 2 sections have consumable items
				S_StartSound(nil, sfx_not, mo.player)
			end

			-- check what item we're trying to select;
			local it = btl.items[mo.m_menuchoices[mo.m_submenu]]

			if not itemDefs[it[1]]
			or itemDefs[it[1]] and itemDefs[it[1]].nouse
			or (not itemDefs[it[1]].attack and not itemDefs[it[1]].menufunc)	-- item does nothing
				S_StartSound(nil, sfx_not, mo.player)
				return
			end

			mo.m_useitem = it[1]	-- Keep a pointer to the item name because we'll be searching for it if thinga go south
			mo.m_itemtarget = 1
			S_StartSound(nil, sfx_select, mo.player)
		-- return
		elseif inputs[BT_USE] == 1
		and not mo.m_exitmenu
			mo.m_hudtimers.sclosemenu = 8
			mo.m_prevmenu = "m_main"
			mo.m_exitmenu = true
			S_StartSound(nil, sfx_cancel, mo.player)
		end

	elseif mo.m_itemtarget	-- we're selecting an item target

		-- check for our item
		local selected = btl.items[mo.m_menuchoices[mo.m_submenu]]
		if selected[1] ~= mo.m_useitem	-- !?

			-- we will keep going back 1 item slot everytime until we can find it back.
			-- if we can't, cancel this mode.
			while mo.m_menuchoices[mo.m_submenu]
				mo.m_menuchoices[mo.m_submenu] = $-1
				if mo.m_itemscroll
					mo.m_itemscroll = $-1
				end

				if btl.items[mo.m_menuchoices[mo.m_submenu]] == selected[1]
					mo.m_useitem = btl.items[mo.m_menuchoices[mo.m_submenu]][1]
				end
			end

			if selected[1] ~= mo.m_useitem	-- uuuh
				mo.m_itemtarget = nil
				return	-- undo item use mode.
			end

		end

		local it = itemDefs[mo.m_useitem]
		local atk
		local alltargets
		if it.attack and attackDefs[it.attack]
			atk = attackDefs[it.attack]
			if atk
				alltargets = atk.target == TGT_ALLALLIES
			end
		end

		if inputs["up"] == 1
		and not alltargets
			mo.m_itemtarget = $-1
			if not mo.m_itemtarget
				mo.m_itemtarget = server.P_netstat.teamlen
			end
			S_StartSound(nil, sfx_hover, mo.player)

		elseif inputs["down"] == 1
		and not alltargets
			mo.m_itemtarget = $+1
			if mo.m_itemtarget > server.P_netstat.teamlen
				mo.m_itemtarget = 1
			end
			S_StartSound(nil, sfx_hover, mo.player)

		elseif inputs[BT_BTNA] == 1
			local tgt = server.plentities[pa][mo.m_itemtarget]

			-- for special items!

			-- manual checking
			if it.checkfunc and it.checkfunc(mo, tgt)
				S_StartSound(nil, sfx_not, mo.player)
				return
			end

			-- special functions
			if it.menufunc
				it.menufunc(mo, tgt)
				m_item_use(mo, mo.m_menuchoices[mo.m_submenu])	-- don't forget to consume the item.
				return
			end

			if atk
				-- heal HP
				local checks = {"redhp", "maxhp"}
				local otherchecks = {"sp", "maxsp"}
				if atk.showsp
					checks = {"sp", "maxsp"}
				end

				if tgt.redhp == nil
					tgt.redhp = tgt.hp	-- just in case.
				end

				-- check if we SHOULD use it
				if not alltargets
					-- check for our target's HP
					if tgt[checks[1]] >= tgt[checks[2]]
						S_StartSound(nil, sfx_not, mo.player)
						return
					end
				else
					-- check if everyone is full on HP
					local hpfull = 0
					for i = 1, server.P_netstat.teamlen
						local p = server.plentities[pa][i]
						if p.redhp == nil
							p.redhp = p.hp
						end
						if p[checks[1]] >= p[checks[2]]
						and not (atk.soma and p[otherchecks[1]] >= p[otherchecks[2]])	-- soma also checks for SP
							hpfull = $+1
						end
					end

					if hpfull >= server.P_netstat.teamlen
						S_StartSound(nil, sfx_not, mo.player)
						return
					end
				end
				-- now that we've checked if we should actually be using it... well, do actually use it.

				local tgts = alltargets and server.plentities[pa] or {tgt}

				for i = 1, #tgts
					if atk.showsp
						tgts[i].sp = min(tgts[i].maxsp, $ + atk.power)
					else
						if atk.soma
							tgts[i].sp = tgts[i].maxsp
							DNG_Damage(tgts[i], -9999)
						else
							DNG_Damage(tgts[i], -atk.power)
						end
					end

					VFX_Play(tgts[i].control.mo, tgts[i].control.mo == mo and VFX_HEALSELF or VFX_HEAL)
					S_StartSound(nil, sfx_heal, tgts[i].control)
				end
			end
			-- consume item:
			m_item_use(mo, mo.m_menuchoices[mo.m_submenu])
			--o.m_useitem = nil
			--mo.m_itemtarget = nil


		elseif inputs[BT_BTNB] == 1
			mo.m_itemtarget = nil
			mo.m_useitem = nil
			S_StartSound(nil, sfx_cancel, mo.player)
		end
	end
end

local function drawPlayerItemList(v, mo, choice, choice_prev)

	choice_prev = mo.m_menuchoices["m_main"] or 1

	local pa = mo.player.P_party

	local items = server.P_BattleStatus[pa].items
	local timer = mo.m_hudtimers.smenuopen
	local out_timer = mo.m_hudtimers.sclosemenu or 7
	if mo.m_hudtimers.sclosemenu
		PDraw(v, -174 + out_timer*32, 173 - out_timer*4, v.cachePatch("H_BOX_D"), V_SNAPTOBOTTOM|V_SNAPTOLEFT|TR_TRANS30)
		drawPlayerCommands_In(v, mo, choice_prev)	-- for return
	else
		PDraw(v, 50 - timer*32, 145 + timer*4, v.cachePatch("H_BOX_D"), V_SNAPTOBOTTOM|V_SNAPTOLEFT|TR_TRANS30)
		drawPlayerCommands_Out(v, mo, choice_prev)	-- for entry
	end
	-- iterate thru items
	for i = 1, #items
		local intend_y = 60
		local y = 60 + 32*(i-1) - (choice-1)*32 - (mo.m_selectslide or 0)
		local diff = abs(intend_y - y)
		local atk = itemDefs[items[i][1]].attack
		local skill = attackDefs[atk]
		drawSkillCommand(v, 0 - timer^2 - (7-out_timer)*24 - (diff^2)/96, y, mo, skill, i == choice, server.P_BattleStatus[pa].items[i])
	end

	-- draw description
	local skill
	if #items
		skill = itemDefs[items[choice][1]]
		V_drawString(v, 60, 150, skill.desc, "NFNT", V_SNAPTOLEFT|V_SNAPTOBOTTOM, nil, 0, 31)
	end

	local party_choice = mo.m_menuchoices["m_partychoice"]
	if skill and skill.target == TGT_ALLALLIES
		party_choice = 0
	end
	M_drawPartyStatus(v, mo, party_choice)

	local cmd = {
					{BUTT_DPAD, "Select"},
					{BUTT_A, "Use"},
					{BUTT_B, "Exit"},
				}
	V_drawCommands(v, cmd)

end


local function m_equip_handle(mo)
	local inputs = mo.P_inputs
	local btl = server.P_BattleStatus[mo.player.P_party]
	local party = server.plentities[mo.player.P_party]

	local inv = {btl.weapons, btl.armours}

	if not mo.m_equipinventory
		mo.m_equipscroll = 0	-- always have no scrolling
		-- we're selecting what piece of equipment to replace
		if (inputs["up"] == 1 or inputs["down"] == 1)
		and not mo.m_viewskillslot
			mo.m_equipslot = mo.m_equipslot == 1 and 2 or 1
			S_StartSound(nil, sfx_hover, mo.player)
		end	-- this is easy we just invert the slot

		-- for left/right, change the selected party member
		if inputs["right"] == 1
		and not mo.m_viewskillslot
			mo.m_equipparty = $+1

			if mo.m_equipparty > #party
				mo.m_equipparty = 1
			end
			S_StartSound(nil, sfx_turn, mo.player)
		elseif inputs["left"] == 1
		and not mo.m_viewskillslot
			mo.m_equipparty = $-1

			if mo.m_equipparty < 1
				mo.m_equipparty = #party
			end
			S_StartSound(nil, sfx_turn, mo.player)
		end

		if inputs[BT_JUMP] == 1
		and not mo.m_viewskillslot
			if #inv[mo.m_equipslot]	-- make sure there are items in the corresponding inventory
			and party[mo.m_equipparty].control == mo.player	-- this is something that *I* am controlling.
				mo.m_equipinventory = 1
				S_StartSound(nil, sfx_confir, mo.player)
			else
				S_StartSound(nil, sfx_not, mo.player)
			end
		end

		if inputs[BT_BTNC] == 1
			-- check what item we have to see if this button should work:
			if mo.m_equipslot == 1
				local pm = party[mo.m_equipparty]
				if pm.weapon and pm.weapon.slot

					S_StartSound(nil, sfx_select, mo.player)
					mo.m_viewskillslot = 1
				end
			end
		end

		if inputs[BT_USE] == 1
		and mo.m_viewskillslot
			S_StartSound(nil, sfx_cancel, mo.player)
			mo.m_viewskillslot = nil
			return true
		end

	else
		-- we're in the inventory now
		local t = inv[mo.m_equipslot]
		local maxc = #t
		local numdisplayitems = 8
		local maxscroll = maxc-numdisplayitems

		-- in case an item we're over gets equipped, sold, whatnot... etc etc
		if mo.m_equipinventory > maxc
			mo.m_equipinventory = maxc
			mo.m_equipscroll = maxscroll

			-- all weapons are just gone?
			if not maxc
				mo.m_equipinventory = 0
				return	-- undo those variables
			end

		end

		if inputs["up"] == 1
			mo.m_equipinventory = $-1

			if mo.m_equipinventory < maxc-(numdisplayitems/2)
			and mo.m_equipscroll
				mo.m_equipscroll = $-1
			end

			if not mo.m_equipinventory
				mo.m_equipinventory = maxc
				-- adapt scroll
				if maxc > numdisplayitems
					mo.m_equipscroll = maxscroll
				end
			end
			S_StartSound(nil, sfx_hover, mo.player)

		elseif inputs["down"] == 1
			mo.m_equipinventory = $+1

			if mo.m_equipinventory - mo.m_equipscroll > (numdisplayitems/2)
			and mo.m_equipinventory < maxc - (numdisplayitems/3)
			and maxc > numdisplayitems
				mo.m_equipscroll = $+1
			end

			if mo.m_equipinventory > maxc
				mo.m_equipinventory = 1
				mo.m_equipscroll = 0
			end
			S_StartSound(nil, sfx_hover, mo.player)

		elseif inputs[BT_JUMP] == 1

			-- if we're not equipping a weapon, go ahead.
			-- otherwise, check if we can equip the weapon
			if mo.m_equipslot ~= 1 or canEquipWeapon(party[mo.m_equipparty], t[mo.m_equipinventory])
				local fn = {equipWeapon, equipRing}
				S_StartSound(nil, sfx_equip, mo.player)
				fn[mo.m_equipslot](party[mo.m_equipparty], t[mo.m_equipinventory])
				-- equip the item on the selected party member

				mo.m_equipinventory = 0	-- get out of that menu
			else
				S_StartSound(nil, sfx_not, mo.player)
			end

		elseif inputs[BT_BTNC] == 1
			-- check what item we have to see if this button should work:
			if mo.m_equipslot == 1
				local pm = party[mo.m_equipparty]
				local wpn = t[mo.m_equipinventory]
				if wpn and wpn.slot

					S_StartSound(nil, sfx_select, mo.player)
					mo.m_viewskillslot = 1
				end
			end

		elseif inputs[BT_SPIN] == 1
			S_StartSound(nil, sfx_cancel, mo.player)
			-- skill slot view cancelling
			if mo.m_viewskillslot
				mo.m_viewskillslot = nil
				return true
			end
			-- normal cancelling
			mo.m_equipinventory = 0
			return true
		end
	end
end

local function m_equip_hud(v, mo, choice)
	local choice_prev = mo.m_menuchoices["m_main"] or 1

	local pa = mo.player.P_party
	local party = server.plentities[pa]

	local items = server.P_BattleStatus[pa].items
	local timer = mo.m_hudtimers.smenuopen
	local out_timer = mo.m_hudtimers.sclosemenu or 7

	local fn = drawPlayerCommands_In

	if mo.m_hudtimers.sclosemenu
		timer = 7 - out_timer
	else
		fn = drawPlayerCommands_Out
	end
	PDraw(v, 50 - timer*64, 145 + timer*12, v.cachePatch("H_BOX_DB"), V_SNAPTOBOTTOM|V_SNAPTOLEFT|TR_TRANS30)
	fn(v, mo, choice_prev)

	local cmd = {
					{BUTT_DPAD, "Select"},
					{BUTT_A, "Change"},
					{BUTT_B, "Exit"},
	}

	-- bar split:
	v.drawFill(180 - timer*64, 150 + timer*12, 1, 45, 135|V_SNAPTOBOTTOM|V_SNAPTOLEFT)


	-- now the actual hud...

	-- player head icons above:
	-- first we need to find the starting player
	local start = mo.m_equipparty-1
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


	PDraw(v, -timer*64, 0, v.cachePatch("M_EQUIW2"), V_SNAPTOLEFT|V_SNAPTOTOP|TR_TRANS40)
	PDraw(v, -timer*64, 0, v.cachePatch("M_EQUIW1"), V_SNAPTOLEFT|V_SNAPTOTOP)

	PDraw(v, 320, -timer*96, v.cachePatch("M_EQUIW3"), V_SNAPTORIGHT|V_SNAPTOTOP|TR_TRANS40)

	local member = party[mo.m_equipparty]
	local mybot = member.control == mo.player
	local btl = server.P_BattleStatus[mo.player.P_party]

	local wep = member.weapon
	local rng = member.wardring

	-- Write char info and their current equipment
	V_drawString(v, -timer*64 +8, 30, member.name.." LV"..member.level, "NFNT", V_SNAPTOTOP|V_SNAPTOLEFT, nil, 0, 31)

	-- Write equipment:
	local inventorylist

	if wep
		if mo.m_equipslot == 1
			inventorylist = btl.weapons
			v.drawFill(-timer*64 + 4, 48, 128, 12, 135|V_SNAPTOTOP|V_SNAPTOLEFT)
		end

		V_drawString(v, -timer*64 +8, 50, buildWeaponName(wep), "NFNT", V_SNAPTOTOP|V_SNAPTOLEFT, nil, (not mybot) and 16 or 0, 31)

		-- weapon power:
		V_drawString(v, -timer*64 +92, 52, "ATK", "FPIMP", V_SNAPTOTOP|V_SNAPTOLEFT, nil, (not mybot) and 16 or 0, 31, FRACUNIT/4)
		V_drawString(v, -timer*64 +108, 51, (wep.atk/10), "FPNUM", V_SNAPTOTOP|V_SNAPTOLEFT, nil, (not mybot) and 16 or 0, 31)
	end
	if rng
		-- this code sucks
		if mo.m_equipslot == 2
			inventorylist = btl.armours
			v.drawFill(-timer*64 + 4, 60, 128, 12, 135|V_SNAPTOTOP|V_SNAPTOLEFT)
		end

		V_drawString(v, -timer*64 +8, 62, buildRingName(rng), "NFNT", V_SNAPTOTOP|V_SNAPTOLEFT, nil, (not mybot) and 16 or 0, 31)

		-- ring def:
		V_drawString(v, -timer*64 +92, 64, "DEF", "FPIMP", V_SNAPTOTOP|V_SNAPTOLEFT, nil, (not mybot) and 16 or 0, 31, FRACUNIT/4)
		V_drawString(v, -timer*64 +108, 63, (rng.def/10), "FPNUM", V_SNAPTOTOP|V_SNAPTOLEFT, nil, (not mybot) and 16 or 0, 31)
	end

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

	-- show me my other inventory items...
	if inventorylist

		local scroll = mo.m_equipscroll or 0
		local y = 16 - 12*scroll
		for i = 1, #inventorylist
			local a = inventorylist[i]

			if mo.m_equipinventory == i
				v.drawFill(180, -timer*96 +10 +y -2, 320-173, 12, 135|V_SNAPTOTOP|V_SNAPTORIGHT)
			end

			if i > scroll
			and i < scroll+9
			-- only display things in scroll range, duh
				if mo.m_equipslot == 1
					local colour = (not canEquipWeapon(party[mo.m_equipparty], a)) and 16 or 0

					V_drawString(v, 185, -timer*96 + 10 +y, buildWeaponName(a), "NFNT", V_SNAPTOTOP|V_SNAPTORIGHT, nil, colour, 31)
					V_drawString(v, 280, -timer*95 + 12 +y, "ATK", "FPIMP", V_SNAPTOTOP|V_SNAPTORIGHT, nil, colour, 31, FRACUNIT/4)
					V_drawString(v, 295, -timer*95 + 10 +y, (a.atk/10), "FPNUM", V_SNAPTOTOP|V_SNAPTORIGHT, nil, colour, 31)

				else
					V_drawString(v, 185, -timer*96 + 10 +y, buildRingName(a), "NFNT", V_SNAPTOTOP|V_SNAPTORIGHT, nil, 0, 31)
					V_drawString(v, 280, -timer*95 + 12 +y, "DEF", "FPIMP", V_SNAPTOTOP|V_SNAPTORIGHT, nil, colour, 31, FRACUNIT/4)
					V_drawString(v, 295, -timer*95 + 10 +y, (a.def/10), "FPNUM", V_SNAPTOTOP|V_SNAPTORIGHT, nil, 0, 31)
				end
			end

			y = $+12
		end
	end

	-- show me the description of the item!

	local readstats = {}
	local readfrom
	local str = ""
	local str2 = ""
	local skillslot

	local desc = "DESCRIPTION MISSING"

	if mo.m_equipslot == 1	-- WEAPON
		readstats = {{"ATK", "ACC", "CRIT"}, {"St", "Ma", "En", "Ag", "Lu"}}
		if mo.m_equipinventory	-- read from inventory item instead
			readfrom = btl.weapons[mo.m_equipinventory]
			desc = weaponsList[readfrom.ref].desc or $
			str = buildWeaponName(readfrom)
		else	-- otherwise we're checking the one on our current equipment
			str = buildWeaponName(wep)
			desc = weaponsList[wep.ref].desc or $
			readfrom = wep
		end
		--if readfrom.level >= 10
		if readfrom.slot
			if attackDefs[readfrom.slot]
				local col = "\x82"
				if readfrom.level < 10
					col = "\x86"
				end

				skillslot = col..ICO_SKILLCARD..attackDefs[readfrom.slot].name
			else
				skillslot = ICO_SKILLCARD.."INVALID SKILL"
			end
		end
	else					-- by process of elimination, this is for the ring
		readstats = {{"DEF"}, {"HP", "SP"}}
		if mo.m_equipinventory
			readfrom = btl.armours[mo.m_equipinventory]
			desc = ringsList[readfrom.ref].desc or $
			str = buildRingName(readfrom)
		else		-- ditto, see how weapons do it
			str = buildRingName(rng)
			desc = ringsList[rng.ref].desc or $
			readfrom = rng
		end
	end

	-- Build the string
	str = $.."\n\n"	-- Leave 3 so we have enough space to put the rarity
	for i = 1, #readstats do
		local tt = readstats[i]
		for j = 1, #tt do
			local stat = tt[j]:lower()
			--print(stat..":"..tostring(readfrom[stat]))
			if readfrom[stat]

				if i == 1
					str = $..tt[j]..": "..(readfrom[stat]/(j==1 and 10 or 1)).."\n"
				else
					local stat = readfrom[stat]
					local plus = "+"
					if stat < 0
						plus = "\x84"
					end

					str2 = $..tt[j].." "..plus..stat.."\x80".."\n"
				end
			end
		end
	end

	if skillslot	-- skill card slot for weapons
		str = $..skillslot
		cmd = {
					{BUTT_DPAD, "Select"},
					{BUTT_A, "Change"},
					{BUTT_C, "\x82View Slot\x80"},
					{BUTT_B, "Exit"},
		}
	end

	-- Render the weapon/ring's rarity
	if readfrom.element
		v.drawScaled((65 - timer*96)<<FRACBITS, 159<<FRACBITS, FRACUNIT/4, v.cachePatch("AT2_"..atk_constant_2_num[readfrom.element]), V_SNAPTOLEFT|V_SNAPTOBOTTOM)
	end

	renderRarity(v, (readfrom.element and 75 or 65) -timer*96, 158, readfrom.rarity, V_SNAPTOBOTTOM|V_SNAPTOLEFT)
	-- string 1: weapon raw stats
	V_drawString(v, 65 - timer*96, 150, str, "NFNT", V_SNAPTOLEFT|V_SNAPTOBOTTOM, nil, 0, 31)
	-- string 2: weapon added stats
	if not mo.m_viewskillslot
		V_drawString(v, 138 - timer*96, 158, str2, "NFNT", V_SNAPTOLEFT|V_SNAPTOBOTTOM, nil, 0, 31)
	end
	-- Show the description
	V_drawString(v, 185 - timer*96, 158, desc, "TFNT", V_SNAPTOLEFT|V_SNAPTOBOTTOM, nil, 0, 31)

	if mo.m_viewskillslot

		cmd = {
					{BUTT_B, "Return"},
		}

		v.fadeScreen(31, 7)

		v.drawFill(63, 149 + 10*4, min(V_stringWidth(v, skillslot, "NFNT")/FRACUNIT +8, 192), 12, 135|V_SNAPTOLEFT|V_SNAPTOBOTTOM)
		v.drawFill(63, 148 + 10, 192, 30 +2, 135|V_SNAPTOLEFT|V_SNAPTOBOTTOM)

		V_drawString(v, 65 - timer*96, 150 + 10*4, skillslot, "NFNT", V_SNAPTOLEFT|V_SNAPTOBOTTOM, nil, 0, 31)

		if attackDefs[readfrom.slot]
			V_drawString(v, 65 - timer*96, 160, attackDefs[readfrom.slot].desc, "NFNT", V_SNAPTOLEFT|V_SNAPTOBOTTOM, nil, 0, 31)
		end

		if readfrom.level < 10
			local str = "\x82When "..buildWeaponName(readfrom).."\nreaches Enhancement Level +10:"
			V_drawString(v, 65 - timer*96, 138, str, "NFNT", V_SNAPTOLEFT|V_SNAPTOBOTTOM, nil, 0, 31)
		end
	end


	V_drawCommands(v, cmd)

end

-- initiate main pause menu:
M_menus["main"] = {
m_start_at = "m_main",	-- where the menu starts
openfunc = function(mo)	-- play a sound when we open the menu:
	S_StartSound(nil, sfx_select, mo.player)

	-- compute what healing skills we have.
end,

	m_item = {
		opentimer = 7,
		closetimer = 7,
		openfunc = 	function(mo)
						mo.m_item_section = 1
						mo.m_itemscroll = 0
						BTL_sortItems(server.P_BattleStatus[mo.player.P_party])
					end,

		prev = "m_main",

		drawer = drawPlayerItemList_New,
		runfunc = m_item_inputs_New,
	},

	m_skill = {
		opentimer = 7,
		closetimer = 7,
		prev = "m_main",
		drawer = drawPlayerSkillList,

		-- inputs here are also relatively special
		runfunc = m_skill_inputs,
	},

	m_party = {
		opentimer = 8,
		closetimer = 8,
		prev = "m_main",

		-- handle the inputs for this pretty special menu
		runfunc = function(mo)

			local inputs = mo.P_inputs

			-- return
			if inputs[BT_USE] == 1
			and not mo.m_exitmenu
				if mo.m_showskills
					S_StartSound(nil, sfx_cancel, mo.player)
					mo.m_showskills = nil
					return true
				elseif mo.m_showstats
					mo.m_hudtimers.m_stats_undo = TICRATE*2/3
					S_StartSound(nil, sfx_cancel, mo.player)
					mo.m_exitmenu = true
					return true	-- stop right there criminal scum
				else
					mo.m_hudtimers.sclosemenu = 8
					mo.m_prevmenu = "m_main"
					mo.m_exitmenu = true
					S_StartSound(nil, sfx_cancel, mo.player)
				end
			end

			if mo.m_hudtimers.m_stats_undo
			or mo.m_showstats	-- still no
				if mo.m_hudtimers.m_stats_undo == 1	-- last frame, cancel everything
					mo.m_showstats = nil
					mo.m_exitmenu = nil
				end

				if not mo.m_showskills
					if inputs[BT_JUMP] == 1	-- check moves
					and not mo.m_exitmenu
						mo.m_showskills = 1
						S_StartSound(nil, sfx_select, mo.player)
						return true
					end
				else
					-- checking skills
					-- we have 8 skills

					-- this kinda sucks but lol let's go with it
					if inputs["down"] == 1
						mo.m_showskills = $+1
						S_StartSound(nil, sfx_hover, mo.player)
						if (mo.m_showskills-1)%4 == 0
							mo.m_showskills = $-4
						end
					elseif inputs["up"] == 1
						mo.m_showskills = $-1
						S_StartSound(nil, sfx_hover, mo.player)
						if (mo.m_showskills%4) == 0
							mo.m_showskills = $+4
						end
					elseif inputs["left"] == 1
						mo.m_showskills = $-4
						S_StartSound(nil, sfx_hover, mo.player)
						if mo.m_showskills < 1
							mo.m_showskills = $+8
						end
					elseif inputs["right"] == 1
						mo.m_showskills = $+4
						S_StartSound(nil, sfx_hover, mo.player)
						if mo.m_showskills > 8
							mo.m_showskills = $-8
						end
					end
				end

				return true	-- timer on, don't proceed now...
			end

			local maxc = #server.plentities[mo.player.P_party]
			if inputs["down"] == 1
				mo.m_menuchoices[mo.m_submenu] = $+1
				if mo.m_menuchoices[mo.m_submenu] > maxc
					mo.m_menuchoices[mo.m_submenu] = 1
				end
				S_StartSound(nil, sfx_hover, mo.player)

			elseif inputs["up"] == 1
				mo.m_menuchoices[mo.m_submenu] = $-1
				if mo.m_menuchoices[mo.m_submenu] < 1
					mo.m_menuchoices[mo.m_submenu] = maxc
				end
				S_StartSound(nil, sfx_hover, mo.player)
			end

			local choice = mo.m_menuchoices[mo.m_submenu]
			if inputs[BT_JUMP] == 1
				mo.m_hudtimers.m_stats = TICRATE*2/3
				mo.m_showstats = choice
				S_StartSound(nil, sfx_select, mo.player)
			end
			return true
		end,

		drawer = function(v, mo, choice)
			drawMenu_main(v, mo, (mo.m_menuchoices["m_main"] or 1), 0)	-- draw the previous menu
			local timers = mo.m_hudtimers
			local timer = timers.sclosemenu and (TICRATE/3 - timers.sclosemenu) or timers.smenuopen or 0
			if forcetimer ~= nil
				timer = forcetimer
			end

			local ypos = 135 + timer*24
			PDraw(v, 130, ypos, v.cachePatch("M_PSELCT"), V_SNAPTOBOTTOM|V_SNAPTOLEFT)
			--V_drawString(v, 130, ypos, "Select party member", "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, 31, nil)
			-- draw names:
			for i = 1, #server.plentities[mo.player.P_party] do
				local p = server.plentities[mo.player.P_party][i]
				local ico = charStats[p.stats].icon

				-- get name
				local name = p.name

				PDraw(v, 130, ypos + (i-1)*10, v.cachePatch(ico), V_SNAPTOBOTTOM|V_SNAPTOLEFT, v.getColormap(TC_DEFAULT, p.color))
				V_drawString(v, 140, ypos + 10*(i-1), name, "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, ((choice == i and leveltime%10 < 5) and 31 or 0), nil)
			end

			-- stats:
			if mo.m_showstats
				local t = (mo.m_hudtimers.m_stats_undo) or (TICRATE*2/3 - (mo.m_hudtimers.m_stats))
				local scale = t*FRACUNIT/2
				if t < FRACUNIT*2
					v.drawScaled(160<<FRACBITS, 100<<FRACBITS, t*FRACUNIT/2, v.cachePatch("H_1M_B"), V_30TRANS)
				else
					v.fadeScreen(135, 7)	-- optimize rendering
				end
				drawStats(v, server.plentities[mo.player.P_party][mo.m_showstats], t, false, mo.m_showskills)
			else
				local cmd = {
					{BUTT_DPAD, "Select"},
					{BUTT_A, "Confirm"},
					{BUTT_B, "Exit"},
					}
				V_drawCommands(v, cmd)
			end
		end,
	},

	m_persona = {
		opentimer = TICRATE/3,
		closetimer = TICRATE/3,
		prev = "m_main",

		runfunc = 	function(mo)

						local p = mo.player
						local inputs = mo.P_inputs
						local maxc = #server.P_BattleStatus[p.P_party].subpersonas

						local pa = mo.player.P_party

						local pc = "m_partychoice"
						local maxpc = #server.plentities[pa]

						if not mo.m_menuchoices[pc]
							mo.m_menuchoices[pc] = 1
						end

						mo.m_main_subp = $ or 0
						mo.m_main_subp = $/2		-- hud anim

						-- 22/12: failsafe for shops
						if mo.m_menuchoices[mo.m_submenu] > maxc
							mo.m_menuchoices[mo.m_submenu] = maxc
						end

						if inputs["down"] == 1
							mo.m_menuchoices[mo.m_submenu] = $+1
							if mo.m_menuchoices[mo.m_submenu] > maxc
								mo.m_menuchoices[mo.m_submenu] = 1
							end
							mo.m_main_subp = 64
							S_StartSound(nil, sfx_hover, mo.player)

						elseif inputs["up"] == 1
							mo.m_menuchoices[mo.m_submenu] = $-1
							if mo.m_menuchoices[mo.m_submenu] < 1
								mo.m_menuchoices[mo.m_submenu] = maxc
							end
							mo.m_main_subp = -64
							S_StartSound(nil, sfx_hover, mo.player)
						elseif inputs["right"] == 1
							mo.m_menuchoices[pc] = $+1
							if mo.m_menuchoices[pc] > maxpc
								mo.m_menuchoices[pc] = 1
							end
							S_StartSound(nil, sfx_hover, mo.player)
						elseif inputs["left"] == 1
							mo.m_menuchoices[pc] = $-1
							if mo.m_menuchoices[pc] < 1
								mo.m_menuchoices[pc] = maxpc
							end
							S_StartSound(nil, sfx_hover, mo.player)

						elseif inputs[BT_JUMP] == 1

							-- check if this subpersona is already in use
							local bot = server.plentities[mo.player.P_party][mo.m_menuchoices[pc]]
							local subp = server.P_BattleStatus[p.P_party].subpersonas[mo.m_menuchoices[mo.m_submenu]]	-- dear GOD.
							if subp.equipped	-- yup.
							and mo.m_menuchoices[mo.m_submenu] > 1		-- 1 is always unequipped
							and server.plentities[mo.player.P_party][subp.equipped].control ~= p	-- Allow equipping anyway if this is my bot.
							and server.plentities[mo.player.P_party][subp.equipped] ~= bot			-- Still error if we're equipping the same persona on the same bot

							or bot.control ~= mo.player	-- This isn't my bot, I can't control it!
								S_StartSound(nil, sfx_not, mo.player)
								return
							end

							local prev = server.plentities[mo.player.P_party][subp.equipped]	-- Previous bot
							if prev and prev.valid
								prev.subpersona = nil
								prev.equipped = nil
							end

							if bot.subpersona
								-- make the previous subp forget about the bot
								bot.subpersona.equipped = 0
							end

							bot.subpersona = subp
							local mynum = 0
							for i = 1, #server.plentities[mo.player.P_party]
								if server.plentities[mo.player.P_party][i] == bot
									mynum = i
									break
								end
							end

							S_StartSound(nil, sfx_qsumon, mo.player)
							subp.equipped = mynum	-- we're done here!
						elseif inputs[BT_USE] == 1
						and not mo.m_exitmenu
							mo.m_hudtimers.sclosemenu = 8
							mo.m_prevmenu = "m_main"
							S_StartSound(nil, sfx_cancel, mo.player)
							mo.m_main_subp = 0
							mo.m_exitmenu = true
						end
					end,

		drawer = 	function(v, mo, choice)
						-- I literally cannot be assed so let's do it RIGHT HERE, RIGHT NOW
						drawMenu_main(v, mo, (mo.m_menuchoices["m_main"] or 1), 0, false)	-- draw the previous menu
						local battle = server.P_BattleStatus[mo.player.P_party]
						local timers = mo.m_hudtimers
						local timer = timers.sclosemenu and (TICRATE/3 - timers.sclosemenu) or timers.smenuopen or 0
						local y = 100 - (64 * (choice-1)) + (mo.m_main_subp or 0) +32

						for i = 1, #battle.subpersonas do
							local sp = battle.subpersonas[i]
							local finalxpos = 160 - abs(132 - y)

							PDraw(v, finalxpos - (timer*48), y, v.cachePatch("SHFLFL"))	-- draw card
							if i > 1	-- subp 1 is an empty card.

								local subp_c = sp.ref	-- current subpersona data
								local sprname = subp_c.sprite and sprnames[subp_c.sprite] or sprnames[SPR_SBPR]
								local sprframe = subp_c.frame and string.char((subp_c.frame & FF_FRAMEMASK) + 65) or "A"
								local patch = v.cachePatch(sprname..sprframe.."0")	-- eg: SUBPA0

								PDraw(v, finalxpos - (timer*48), y, patch)

								-- equipped icon
								if sp.equipped
									local who
									for j = 1, #server.plentities[mo.player.P_party]
										if j == sp.equipped
											who = server.plentities[mo.player.P_party][j]
											break
										end
									end

									v.draw(finalxpos - (timer*48) - 32, y - 81, v.cachePatch(charStats[who.stats].icon), 0, v.getColormap(TC_DEFAULT, who.color))
								end
							end
							y = $+64
						end

						-- stats
						local subp = battle.subpersonas[choice]
						local dx = 180 - timer*48
						PDraw(v, dx+20, 20, v.cachePatch("H_SUBP"), V_30TRANS)
						V_drawString(v, dx + 40, 20, subp.ref.name and subp.ref.name:upper() or "INVALID SUB", "FPIMP", 0, nil, 0, 31)

						-- now draw stat bonuses and disadvantages:
						local stats_subp = {"st", "ma", "en", "ag", "lu"}
						local bot = server.plentities[mo.player.P_party][mo.m_menuchoices["m_partychoice"]]

						local playerstats = {bot.strength, bot.magic, bot.endurance, bot.agility, bot.luck}
						-- we don't actually need savestats since we don't actually equip it for real
						local dy = 32
						for i = 1, #stats_subp
							V_drawString(v, dx + 40, dy, stats_subp[i]:upper(), "NFNT", 0, nil, 0, 31)

							-- draw a fake stat bar for funsies
							local checkstat = subp[stats_subp[i]]
							local str
							if checkstat and checkstat < 0
								v.drawFill(dx + 62, dy+6, 32, 4, 31)	-- black bg
								v.drawFill(dx + 60, dy+4, 32, 4, 35)	-- red bar
								v.drawFill(dx + 60, dy+4, 24, 4, 0)		-- white bar
								str = "\x85"..checkstat

							elseif checkstat and checkstat == 0
							or not checkstat

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
							V_drawString(v, dx + 100, dy, "("..max(1, (playerstats[i] + (checkstat and checkstat or 0)))..")", "NFNT", 0, nil, 0, 31)

							dy = $ + 10
						end

						-- skills:
						dy = $+5
						dx = $+40

						if subp.skills and #subp.skills
							for i = 1, #subp.skills
								local skillname = subp.skills[i]

								local name = "INVALID SKILL"
								local stype = 1

								if attackDefs[skillname]
									name = attackDefs[skillname].name
									if attackDefs[skillname].type & ATK_PASSIVE
										stype = 15
									else
										stype = atk_constant_2_num[attackDefs[skillname].type]
									end
								end

								-- draw the skill, now.
								v.drawFill(dx, dy, 128, 16, 31)
								PDraw(v, dx+2, dy, v.cachePatch("ATK_"..stype))

								V_drawString(v, dx+20, dy+4, name, "NFNT", 0, nil, 0, 31)
								dy = $+18
							end
						end


						M_drawPartyStatus(v, mo, mo.m_menuchoices["m_partychoice"])

						local cmd = {
							{BUTT_DPAD, "Select"},
							{BUTT_A, "Confirm"},
							{BUTT_B, "Exit"},
						}
						V_drawCommands(v, cmd)
					end,
	},

	m_equip = {
		opentimer = 7,
		closetimer = 7,
		prev = "m_main",
		-- choices: mostly used for the input handler. The drawer might not need it.
		choices = {},

		runfunc = m_equip_handle,
		drawer = m_equip_hud,
	},

	m_main = {
		opentimer = TICRATE/3,
		closetimer = TICRATE/3,
		inputdir = true,	-- menu goes the other way.
		useinputcv = true,	-- use cv_invertcommand
		prev = nil,	-- no previous means that the menu will close on return, when the close timer reaches 0
		-- choices: mostly used for the input handler. The drawer might not need it.
		choices = {
			-- syntax: {name, description, nextmenu}
			{"SKILL", "View & use your skills, or equip Skill Cards",	"m_skill"},
			{"ITEMS", "View & use your items", "m_item"},
			{"PERSONA", "View & switch your Sub-Personas", "m_persona"},
			{"PARTY", "Consult party status", "m_party"},
			--{"SOCIAL LINK", "Consult Social Link status", "m_slink"},
			{"EQUIPMENT", "View & change your equipment", "m_equip"},
		},
		-- function to run continuously whilst this menu is opened
		runfunc = function(mo)
			mo.m_exitmenu = nil
			if mo.m_main_renderangle
				if mo.m_main_renderangle > 0
					mo.m_main_renderangle = $-1
				elseif mo.m_main_renderangle < 0
					mo.m_main_renderangle = $+1
				end
				return true
			end

			local inputs = mo.P_inputs
			if inputs["up"]==1
				mo.m_main_renderangle = mo.player.invertcommand and -3 or 3
				S_StartSound(nil, sfx_turn, mo.player)
			elseif inputs["down"]==1
				mo.m_main_renderangle = mo.player.invertcommand and 3 or -3
				S_StartSound(nil, sfx_turn, mo.player)
			end
		end,

		-- when we confirm, run this
		confirmfunc = function(mo, choice)
			if choice == 1	-- skills
				mo.m_healingskills = {}
				mo.m_belongsto = {}
				-- build healing skills

				local pa = mo.player.P_party
				local party = server.plentities[pa]

				for j = 1, #party

					if party[j].control ~= mo.player continue end 	-- not mine

					local p = party[j]
					if not p return end	-- what
					for i = 1, #p.skills
						if attackDefs[p.skills[i]]
							local a = attackDefs[p.skills[i]]
							if a.type == ATK_HEAL
							and a.target ~= TGT_DEAD
							and a.power	-- this attack heals
								table.insert(mo.m_healingskills, p.skills[i])
								table.insert(mo.m_belongsto, p)
								--dprint("healing skill "..a.name)
							end
						end
					end
				end

				-- okay I guess "healingskills" is now misleading since skill cards are also here now
				mo.m_skillcard_start = #mo.m_healingskills
				-- past this point, in the table, we have skill cards.

				if #server.P_BattleStatus[pa].skillcards
					for i = 1, #server.P_BattleStatus[pa].skillcards
						mo.m_healingskills[#mo.m_healingskills+1] = server.P_BattleStatus[pa].skillcards[i]
						-- add the skillcards at the end of the list
					end
				end

				mo.m_menuchoices["m_skill"] = $ or 1

				-- if we don't have any skill for this, bail out!
				if not #mo.m_healingskills
				or server.P_DungeonStatus.VR_clause == VE_NOSKILLS
					S_StartSound(nil, sfx_not, mo.player)
					return true

				else
					for i = 1, 4
						if server.plentities[mo.player.P_party][i] == mo.player.maincontrol
							--print(i)
							mo.m_menuchoices["m_partychoice"] = i
							break	-- cool!
						end
					end
				end
				-- otherwise? we're good to go!
			elseif choice == 2	-- items
				mo.m_healingitems = {}

				local battle = server.P_BattleStatus[mo.player.P_party]
				if server.P_DungeonStatus.VR_clause == VE_NOITEMS
					S_StartSound(nil, sfx_not, mo.player)
					return true
				end

			elseif choice == 3	-- subpersonas
				local battle = server.P_BattleStatus[mo.player.P_party]

				if not #battle.subpersonas	-- no subp
				or #battle.subpersonas < 2	-- 1 subp is still no subp seeing as #1 is none
					S_StartSound(nil, sfx_not, mo.player)
					return true
				else	-- if we can enter, setup the cursor on our current party member
					for i = 1, 4
						if server.plentities[mo.player.P_party][i] == mo.player.maincontrol
							--print(i)
							mo.m_menuchoices["m_partychoice"] = i
							break	-- cool!
						end
					end
				end
			elseif choice == 5	-- equipment

				mo.m_equipslot = 1
				mo.m_equipinventory = 0	-- cursor on inventory. 0 when not on it.
				mo.m_equipscroll = 0	-- scrolling on inventory

				-- find my index in my party
				for i = 1, 4
					if server.plentities[mo.player.P_party][i] == mo.player.maincontrol
						mo.m_equipparty = i
						break	-- cool!
					end
				end

				-- now we're good to go!
			end
		end,

		-- drawer to run continuously whilst this menu is opened
		drawer = drawMenu_main,
	},
}