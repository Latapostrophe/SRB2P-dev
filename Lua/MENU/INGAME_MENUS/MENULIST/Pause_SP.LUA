
----M_PSELCT.lmp

-- draw the main command selection like battles
local cmd_names = {
	"SKILL",
	"ITEMS",
	"PERSONA",
	"PARTY",
	"SOCIAL LINK",
	"SYSTEM"
}

local cmd_hints = {
	"Use healing skills.",
	"Use healing items",
	"View or switch Sub-Personas",
	"View party status",
	"View LiNK Skills",
	"Save, load or change game settings",
}

local cmd_gfx = {
	"H_CMD2",
	"H_CMD3",
	"H_CMD4",
	"M_PARTY",
	"M_SLINK",
	"M_OPT",
}

local function drawMenu_main(v, mo, choice, forcetimer)
	--local battle = server.P_BattleStatus
	local timers = mo.m_hudtimers
	local timer = timers.sclosemenu and (TICRATE/3 - timers.sclosemenu) or timers.smenuopen or 0
	if forcetimer ~= nil
		timer = forcetimer
	end
	-- center x y are of fixed position, don't bother:
	local cx, cy = 24<<FRACBITS, 125<<FRACBITS
	local s_ang = ANG1*60
	local b_ang = ANG1*65 + (choice-1)*s_ang - ANG1*20*(mo.m_main_renderangle or 0) -- base angle for drawing
	local radius = 48*125/100 + 32*timer

	-- fade
	--local fade = V_50TRANS
	--if timer
	--	fade = V_90TRANS - ((TICRATE/3 - timer)/3)*V_10TRANS
	--end
	--v.drawScaled(160<<FRACBITS, 100<<FRACBITS, t*FRACUNIT/2, v.cachePatch("H_1M_B"), fade)

	-- render BG
	v.drawScaled((0 - 24*timer)<<FRACBITS, (210 + 24*timer)<<FRACBITS, (FRACUNIT/2)*125/100, v.cachePatch("H_CMDBC"), V_SNAPTOBOTTOM|V_SNAPTOLEFT)

	for i = 1, 6
		local angle = b_ang - (i-1)*s_ang - 16*timer*ANG1	-- start timer fancies
		local x = cx + radius*FixedMul(FRACUNIT*5/4, cos(angle)) - abs(16*cos(angle))	-- adjust to ease shape on X coord
		local y = cy + FixedMul(FRACUNIT*2/3, radius*sin(angle))	-- scale Y so that it looks more like an oval
		local scale = (FRACUNIT/4 + cos(angle-ANG1*65)/6 + timer*FRACUNIT/6)*125/100

		v.drawScaled(x, y, scale, v.cachePatch(cmd_gfx[i]), V_SNAPTOBOTTOM|V_SNAPTOLEFT)
	end

	-- hint text
	v.drawFill(0, 182, 450 - timer*4, 8, 135|V_SNAPTOBOTTOM|V_SNAPTOLEFT)
	V_drawString(v, 20, 182, cmd_hints[choice], "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 31, nil)

	-- command name
	V_drawString(v, 20, 190, cmd_names[choice]:upper(), "FPIMP", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 0, 31)

	-- little extra...
	renderPartyBars(v)
end

local linkskill_name = {
	[1] = "Party Toughness",
	[2] = "Party Spirit",
	[3] = "Party Strength",
	[4] = "Party Casting",
	[5] = "Party Defence",
	[6] = "Party Quickstep",
	[7] = "Party Gamble",
	[8] = "Party Coordination",
	[9] = "Wild LiNK",
	[10] = "Wild Fusion",
	[11] = "Wild Affinity",
	[12] = "Victory Breeze",
	[13] = "Salvager",
	[14] = "Extortionist",
}

local linkskill_desc = {
	[1] = "Increase the party's Max HP.",
	[2] = "Increase the party's Max SP.",
	[3] = "Increase the party's Strength,\nboosting physical damage.",
	[4] = "Increase the party's Magic,\nboosting magic skill damage.",
	[5] = "Increase the party's Defense,\nboosting defense against enemy attacks.",
	[6] = "Increase the party's Agility,\nboosting hit and evasion rates.",
	[7] = "Increase the party's Luck\nboosting chances to land critical hits and\ninflict status effects.",
	[8] = "Increase damage dealt by All-Out Attacks.",
	[9] = "Increase LiNK EXP Earned.",
	[10] = "Increase gained EXP from\nSub-Persona Fusion.",
	[11] = "Gain stat bonuses from matching\nPersonas and Sub-Personas with\nthe same Arcana.",
	[12] = "Increase amount of recovered\nHP and SP after battles.",
	[13] = "Increase the odds of item drops\nfrom enemies.",
	[14] = "Increase the amount of macca\nearned from enemies.",
}

local linkskill_cost = { -- Lets implicit the max level for each skill from this table cause...you know what I mean?
	[1] = {1,2,3,4,5},
	[2] = {1,2,3,4,5},
	[3] = {1,2,3,4,5},
	[4] = {1,2,3,4,5},
	[5] = {1,2,3,4,5},
	[6] = {1,2,3,4,5},
	[7] = {1,2,3,4,5},
	[8] = {1,2,3,4,5},
	[9] = {2,4,6,8,10},
	[10] = {3,6,9,12,15},
	[11] = {5,10,15},
	[12] = {5,10,15},
	[13] = {3,6,9},
	[14] = {3,6,9},
}

local function drawMenu_link(v, mo, choice, forcetimer)
	local x = 5
	local y = 25 --160
	local k = 0
	for i = 1, 14
		--print("Drawing at x: "..x.." y: "..y)
		if choice == i
			-- Show highlighted LiNK Skill
			v.drawFill(x, y, 30, 26)
		end
		PDraw(v, x, y, v.cachePatch("H_LINK1"), V_SNAPTOBOTTOM|V_SNAPTOLEFT)
		if not linkskill_cost[srb2p.storydata.linkskills[i]+1]
			V_drawString(v, x+15, y+15, "\x82LvMAX", "NFNT", V_SNAPTORIGHT, nil, 0, 31, FRACUNIT*33/100)
		else
			V_drawString(v, x+15, y+15, "\x82Lv"..srb2p.storydata.linkskills[i], "NFNT", V_SNAPTORIGHT, nil, 0, 31, FRACUNIT*33/100)
		end
		k = $+1
		--y = $+10
		x = $+30
		if k >= 5
			y = $+25
			x = 5
			k = 0
		end
	end
	-- Draw LiNK Skill Name and Description
	V_drawString(v, 90, 130, linkskill_name[choice], "NFNT",  V_SNAPTORIGHT, nil, 0, 31, FRACUNIT*50/100)
	V_drawString(v, 90, 150, linkskill_desc[choice], "NFNT",  V_SNAPTORIGHT, nil, 0, 31, FRACUNIT*50/100)
	-- Draw Available Link Points
	V_drawString(v, 150, 10, "Available Points: "..srb2p.storydata.linkpts.."pt", "NFNT", V_SNAPTORIGHT, nil, 0, 31, FRACUNIT*50/100)
	-- Draw the Skill Cost
	if not linkskill_cost[choice][srb2p.storydata.linkskills[choice]+1]
		V_drawString(v, 150, 20, "\x82MAX", "NFNT", V_SNAPTORIGHT, nil, 0, 31, FRACUNIT*50/100)
	else
		V_drawString(v, 150, 20, "Cost: "..linkskill_cost[choice][srb2p.storydata.linkskills[choice]+1].."pt", "NFNT", V_SNAPTORIGHT, nil, 0, 31, FRACUNIT*50/100)
	end
	if mo.m_considerupgrade
		local w = 300
		local h = 30
		v.drawFill(160 - (w/2), 100 - (h/2), w, h, 135)
		V_drawString(v, 160, 90, "Spend "..linkskill_cost[choice][srb2p.storydata.linkskills[choice]+1].." points to upgrade this skill?", "NFNT", 0, "center", 31, nil)
		V_drawString(v, 160, 100, "PRESS A TO CONFIRM", "NFNT", 0, "center", 31, nil)
	end
end


-- initiate main pause menu:
M_menus["main_sp"] = {
m_start_at = "m_main",	-- where the menu starts
openfunc = function(mo)	-- play a sound when we open the menu:
	S_StartSound(nil, sfx_select, mo.player)

	-- compute what healing skills we have.
end,

	m_party = {
		opentimer = 8,
		closetimer = 8,
		prev = "m_main",

		-- handle the inputs for this pretty special menu
		runfunc = function(mo)

			local inputs = mo.P_inputs

			-- return
			if inputs[BT_USE] == 1
				if mo.m_showskills
					S_StartSound(nil, sfx_cancel, mo.player)
					mo.m_showskills = nil
					return true
				elseif mo.m_showstats
					mo.m_hudtimers.m_stats_undo = TICRATE*2/3
					S_StartSound(nil, sfx_cancel, mo.player)
					return true	-- stop right there criminal scum
				else
					mo.m_hudtimers.sclosemenu = 8
					mo.m_prevmenu = "m_main"
					S_StartSound(nil, sfx_cancel, mo.player)
				end
			end

			if mo.m_hudtimers.m_stats_undo
			or mo.m_showstats	-- still no
				if mo.m_hudtimers.m_stats_undo == 1	-- last frame, cancel everything
					mo.m_showstats = nil
				end

				if not mo.m_showskills
					if inputs[BT_JUMP] == 1	-- check moves
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
						if (mo.m_showskills-1 %4) == 0
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

			local maxc = #server.plentities
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
			for i = 1, #server.plentities do
				local p = server.plentities[i]
				local ico = charStats[p.skin].icon

				-- get name
				local name = p.name

				PDraw(v, 130, ypos + (i-1)*10, v.cachePatch(ico), V_SNAPTOBOTTOM|V_SNAPTOLEFT, v.getColormap(TC_DEFAULT, p.color))
				V_drawString(v, 140, ypos + 10*(i-1), name, "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, ((choice == i and leveltime%10 < 5) and 31 or 0), nil)
			end

			-- stats:
			if mo.m_showstats
				local t = (mo.m_hudtimers.m_stats_undo) or (TICRATE*2/3 - (mo.m_hudtimers.m_stats))
				v.drawScaled(160<<FRACBITS, 100<<FRACBITS, t*FRACUNIT/2, v.cachePatch("H_1M_B"), V_50TRANS)
				drawStats(v, server.plentities[mo.m_showstats], t, false, mo.m_showskills)
			end
		end,
	},

	m_main = {
		opentimer = TICRATE/3,
		closetimer = TICRATE/3,
		prev = nil,	-- no previous means that the menu will close on return, when the close timer reaches 0
		-- choices: mostly used for the input handler. The drawer might not need it.
		choices = {
			-- syntax: {name, description, nextmenu}
			{"SKILL", "View & use your skills",	"m_skill"},
			{"ITEMS", "View & use your items", "m_item"},
			{"PERSONA", "View & switch your Sub-Personas", "m_persona"},
			{"PARTY", "Consult party status", "m_party"},
			{"SOCIAL LINK", "Consult Social Link status", "m_slink"},
			{"SYSTEM", "Save, Load or change game options", "m_system"},
		},
		-- function to run continuously whilst this menu is opened
		runfunc = function(mo)

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
				mo.m_main_renderangle = -3
				S_StartSound(nil, sfx_turn, mo.player)
			elseif inputs["down"]==1
				mo.m_main_renderangle = 3
				S_StartSound(nil, sfx_turn, mo.player)
			end
		end,

		-- drawer to run continuously whilst this menu is opened

		drawer = drawMenu_main,
		/*drawer = function(v, mo, choice)
			local timers = mo.m_hudtimers
			local timer = timers.sclosemenu and (8 - timers.sclosemenu) or timers.smenuopen or 0

			local fade = V_50TRANS
			if timer
				fade = V_90TRANS - ((8 - timer)/2)*V_10TRANS
			end
			v.drawScaled(160<<FRACBITS, 100<<FRACBITS, t*FRACUNIT/2, v.cachePatch("H_1M_B"), fade)

			-- main
			local mx = 320
			if timer
				mx = 320 + timer*64
			end
			PDraw(v, mx, 200, v.cachePatch("M_BG1"), V_SNAPTORIGHT|V_SNAPTOBOTTOM)

			-- draw menu string or smth:
			v.drawFill(mx - 97, 0, 200, 12, 135|V_SNAPTOTOP|V_SNAPTORIGHT)
			V_drawString(v, mx - 102, 0, "MAIN MENU", "FPIMP", V_SNAPTORIGHT|V_SNAPTOTOP, nil, 31, nil, FRACUNIT*75/100)

			-- draw the commands for it:
			for i = 1, #M_menus["main"].m_main.choices do
				-- draw cursor:
				if i == choice
					PDraw(v, mx - (116 + i*6), 16 + (i*20), v.cachePatch("M_CURS1"), V_SNAPTORIGHT)
				end
				V_drawString(v, mx - (110 + i*6), 20 + (i*20), M_menus["main"].m_main.choices[i][1], "FPIMP", V_SNAPTORIGHT, nil, 0, 31, FRACUNIT*80/100)
			end
		end,*/
	},
	m_link = {
		opentimer = 8,
		closetimer = 8,
		prev = "m_main",

		-- handle the inputs for this pretty special menu
		runfunc = function(mo)

			local inputs = mo.P_inputs

			-- return
			if inputs[BT_USE] == 1
			and not mo.m_hudtimers.sclosemenu
			and not mo.m_considerupgrade
				mo.m_hudtimers.sclosemenu = 8
				mo.m_prevmenu = "m_main"
				S_StartSound(nil, sfx_cancel, mo.player)
			elseif inputs[BT_USE] == 1
			and not mo.m_hudtimers.sclosemenu
			and mo.m_considerupgrade
				mo.m_considerupgrade = nil
				S_StartSound(nil, sfx_cancel, mo.player)
			end
		
			local maxc = 14
			if inputs["down"] == 1
				mo.m_menuchoices[mo.m_submenu] = $+5
				if mo.m_menuchoices[mo.m_submenu] > maxc
					mo.m_menuchoices[mo.m_submenu] = maxc
				end
				S_StartSound(nil, sfx_hover, mo.player)
			elseif inputs["up"] == 1
				mo.m_menuchoices[mo.m_submenu] = $-5
				if mo.m_menuchoices[mo.m_submenu] < 1
					mo.m_menuchoices[mo.m_submenu] = 1
				end
				S_StartSound(nil, sfx_hover, mo.player)
			elseif inputs["left"] == 1
				mo.m_menuchoices[mo.m_submenu] = $-1
				if mo.m_menuchoices[mo.m_submenu] < 1
					mo.m_menuchoices[mo.m_submenu] = 1
				end
				S_StartSound(nil, sfx_hover, mo.player)
			elseif inputs["right"] == 1
				mo.m_menuchoices[mo.m_submenu] = $+1
				if mo.m_menuchoices[mo.m_submenu] > maxc
					mo.m_menuchoices[mo.m_submenu] = maxc
				end
				S_StartSound(nil, sfx_hover, mo.player)
			end

			local choice = mo.m_menuchoices[mo.m_submenu]
			if inputs[BT_JUMP] == 1
			and not mo.m_considerupgrade
				-- Check if we can upgrade this
				if linkskill_cost[choice][srb2p.storydata.linkskills[choice]+1]
				and srb2p.storydata.linkpts >= linkskill_cost[choice][srb2p.storydata.linkskills[choice]+1]
					S_StartSound(nil, sfx_select, mo.player)
					mo.m_considerupgrade = true
				else
					S_StartSound(nil, sfx_not, mo.player)
				end
			elseif inputs[BT_JUMP] == 1
			and mo.m_considerupgrade
				-- Upgrade our skill
				mo.m_considerupgrade = nil
				srb2p.storydata.linkpts = $ - linkskill_cost[choice][srb2p.storydata.linkskills[choice]+1]
				srb2p.storydata.linkskills[choice] = $ + 1
				S_StartSound(nil, sfx_lvup, mo.player)
			end
			return true
		end,
		drawer = drawMenu_link,
	}













}