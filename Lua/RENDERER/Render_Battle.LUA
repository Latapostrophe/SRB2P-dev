-- Most of the rendering goes here

rawset(_G, "PDraw", function(v, x, y, pp, flags, colormap)
	if not pp return end	--?
	v.drawScaled(x<<FRACBITS, y<<FRACBITS, FRACUNIT/2, pp, flags, colormap)
end)

local consumesp = 32
local consumesp_target = 32

local consumehp = 32
local consumehp_target = 32

local barlen = 31


local cv_bplayerbars = CV_RegisterVar({
	name = "hu_battlebars",
	defaultvalue = "On",
	PossibleValue = CV_OnOff,
})

-- draw player status at full scale.
-- used for the player currently taking their turn.
rawset(_G, "drawPlayerBar", function(v, x, y, mo, flags)

	if not cv_bplayerbars.value return end
	flags = $ or V_SNAPTOBOTTOM|V_SNAPTORIGHT

	local btlstate = mo.battlen and server.P_BattleStatus[mo.battlen].battlestate or 0
	local mhp = mo.maxhp
	local hp = mo.hp
	local spu = server.P_BattleStatus.spu
	local sp = mo.sp
	local msp = mo.maxsp

	local nosp = (not msp) and true or false

	msp = max($, 1)	-- avoids a few errors later.

	if mo.damaged and mo.damagetaken
		if mo.damagetaken > 0
			x = $ + N_RandomRange(-2, 2)
			y = $ + N_RandomRange(-2, 2)
		else
			local part = phud.create(mo.party, x + N_RandomRange(0, 50), y - N_RandomRange(0, 10), "SUBP1", TICRATE*5, v.getColormap(TC_DEFAULT, SKINCOLOR_CYAN), "heal")

			part.scale = (FRACUNIT + N_RandomRange(0, 65534))/2
			part.momy = 1
			part.physflags = PF_NOGRAVITY
			part.destscale = 1
			part.fuse = TICRATE
			part.scalespeed = FRACUNIT/23
			part.flags = flags
		end
	end

	-- draw player icons here:
	if charStats[mo.stats] and charStats[mo.stats].hudbust and not mo.enemy
		local p = v.cachePatch(charStats[mo.stats].hudbust)

		if mo.status_condition == COND_SUPER
		and charStats[mo.stats].hudsbust
			p = v.cachePatch(charStats[mo.stats].hudsbust)
		end

		PDraw(v, x-8, y-20, p, flags, v.getColormap(TC_DEFAULT, mo.color))

		-- if we have a status condition that has a color, draw it here!
		local s = mo.status_condition
		if cond2color[s] ~= nil

			local tflag = (9 - ((cos(leveltime*10*ANG1) + FRACUNIT)*4)/FRACUNIT) << V_ALPHASHIFT
			-- cos between -FU and FU; cos + FU between 0 and FU*2
			-- *4, /FU to get smth between 0 and 8, then alphashift

			v.drawIndex((x-8)<<FRACBITS, (y-20)<<FRACBITS, FRACUNIT/2, p, flags|tflag, cond2color[s])
		end
	end

	-- is this our player?
	if mo.control == consoleplayer
		V_drawString(v, x+8, y, "YOU", "NFNT", flags, nil, 0, 31, FRACUNIT/4)
	end

	local hpoff = 137
	local hpon = 131
	local hptemp = 135

	if mo.hp < mo.maxhp/4
	and leveltime%6 < 3
		hpon = 35
	end

	-- fill both bars:
	-- HP:

	if consumehp > consumehp_target
		consumehp = $-1
	elseif consumehp < consumehp_target
		consumehp = $+1
	end

	-- get cost
	local atkcost = 0
	local atk = attackDefs[mo.skills[mo.t_skillselect]]

	if atk and mo.status_condition ~= COND_SUPER	-- super has no cost
		if atk.costtype == CST_HP
			atkcost = atk.cost
		elseif atk.costtype == CST_HPPERCENT
			atkcost = atk.cost * mo.maxhp / 100
		end
	end

	consumehp_target = max(0, barlen*(hp-atkcost)/mhp)

	-- if we're not using skills then reset the consume things
	if mo.t_act ~= ACT_SKILL or btlstate ~= BS_DOTURN
	and not (nosp)
		consumehp = barlen*hp/mhp
		consumesp = barlen*sp/msp
		consumehp_target = consumehp
		consumesp_target = consumesp
	end

	local curhp = barlen*hp/mhp
	local maxstep = 6

	--print(consumehp)
	local i = 0
	while i < barlen

		local hpcolor = hpon
		local step = maxstep - (i%maxstep)

		if i >= curhp
			hpcolor = hpoff

		elseif i >= consumehp
			hpcolor = leveltime%10 < 5 and hptemp or hpoff
			if hp - atkcost <= 0 and leveltime%10 < 5
				hpcolor = 35
			end
		end

		if i+step >= consumehp
		and i < consumehp
			step = consumehp - i

		elseif i+step >= curhp
		and i < curhp
			step = curhp - i
		end

		if i+step > barlen
			step = barlen - i
		end

		v.drawFill(x+22+i, y+7-(i/6), min(step, barlen-i), 5, (hpcolor)|flags)

		i = $+step
	end
	--local spulookup = {8, 16, 23, 32}	-- this is only because approximations can cause to be troublesome for higher resolutions

	local spoff = 185
	local spon = 181
	local sptemp = 183

	if mo.sp < mo.maxsp/4
	and leveltime%6 < 3
		spon = 150
	end

	if consumesp > consumesp_target
		consumesp = $-1
	elseif consumesp < consumesp_target
		consumesp = $+1
	end

	-- get cost
	local atkcost = 0
	local atk = attackDefs[mo.skills[mo.t_skillselect]]

	if atk and mo.status_condition ~= COND_SUPER	-- super has no cost
		if atk.costtype == CST_SP
			atkcost = atk.cost
		elseif atk.costtype == CST_SPU
			atkcost = atk.cost *250
		end
	end

	consumesp_target = max(0, barlen*(sp-atkcost)/msp)

	local cursp = barlen*sp/msp
	local maxstep = 6

	-- SP BAR
	local i = 0
	while i < barlen

		local spcolor = spon
		local step = maxstep - (i%maxstep)

		if i >= cursp
			spcolor = spoff

		elseif i >= consumesp
			spcolor = leveltime%10 < 5 and sptemp or spoff
			if sp - atkcost <= 0 and leveltime%10 < 5
				spcolor = 35
			end
		end


		if i+step >= consumesp
		and i < consumesp
			step = consumesp - i

		elseif i+step >= cursp
		and i < cursp
			step = cursp - i
		end


		if i+step > barlen
			step = barlen - i
		end

		v.drawFill(x+20+i, y+12-(i/6), min(step, barlen-i), 5, (nosp and 31 or spcolor)|flags)
		i = $+step
	end

	-- draw the bar overlay:
	PDraw(v, x, y, v.cachePatch("H_HPBGB"), flags)

	-- status cond?
	/*if mo.status_condition
		for i = 0, 12
			if mo.status_condition == 2^i
				PDraw(v, x, y, v.cachePatch("H_CND"..(i+1)), V_SNAPTOBOTTOM|V_SNAPTORIGHT)
			end
		end
	end*/

	-- draw numbers here:
	local flashtype
	if mo.t_act and mo.t_act == ACT_SKILL and btlstate == BS_DOTURN
		-- get skill:
		if mo.attack.costtype == CST_HP or mo.attack.costtype == CST_HPPERCENT
			flashtype = 1
		elseif mo.attack.costtype == CST_SP or mo.attack.costtype == CST_SPU
			flashtype = 2
		end
	end

	if flashtype ~= 1 or (leveltime%10 < 5)
		V_drawString(v, x+19, y+04, tostring(mo.hp), "FPNUM", flags, "right", hpon, 31)
	end
	if not nosp and (flashtype ~= 2 or (leveltime%10 < 5))
		V_drawString(v, x+19, y+12, tostring(mo.sp), "FPNUM", flags, "right", spon, 31)
	end

	-- finally, draw physhud sparkles
	DisplayPhysHUD(v, "heal", displayplayer)
end)

-- draw player status at smaller scale.
-- used for players not taking their turn.
rawset(_G, "drawPlayerBarSmall", function(v, x, y, mo, trans, flags)

	if not cv_bplayerbars.value return end
	flags = $ or V_SNAPTOBOTTOM|V_SNAPTORIGHT

	local mhp = mo.maxhp
	local hp = mo.hp
	--local spu = server.P_BattleStatus.spu
	local sp = mo.sp
	local msp = mo.maxsp

	local hpon = 131
	if mo.hp < mo.maxhp/4
	and leveltime%6 < 3
		hpon = 35
	end

	local hpoff = 137

	local spon = 181
	local spoff = 185

	if mo.sp < mo.maxsp/4
	and leveltime%6 < 3
		spon = 150
	end

	local color = mo.color

	if not mo.hp	-- dead
		hpon = 16
		hpoff = 24
		spon = 18
		spoff = 26
		color = SKINCOLOR_BLACK
	end

	-- we are being damaged. oh.
	if mo.damaged and mo.damagetaken
		if mo.damagetaken > 0
			x = $ + N_RandomRange(-2, 2)
			y = $ + N_RandomRange(-2, 2)
		else

			local part = phud.create(mo.party, x + N_RandomRange(0, 32), y - N_RandomRange(0, 10), "SUBP1", TICRATE*5, v.getColormap(TC_DEFAULT, SKINCOLOR_CYAN), "heal")

			part.scale = (FRACUNIT + N_RandomRange(0, 65534))/3
			part.momy = 1
			part.fuse = TICRATE
			part.physflags = PF_NOGRAVITY
			part.destscale = 1
			part.scalespeed = FRACUNIT/23
			part.flags = flags
		end
	end

	local nosp = (not msp) and true or false

	-- draw player icons here:
	if charStats[mo.stats] and charStats[mo.stats].hudbust and not mo.boss
		local p = v.cachePatch(charStats[mo.stats].hudbust)

		if mo.status_condition == COND_SUPER
		and charStats[mo.stats].hudsbust
			p = v.cachePatch(charStats[mo.stats].hudsbust)
		end

		v.drawScaled((x+8)<<FRACBITS, (y-13)<<FRACBITS, FRACUNIT/4, p, flags, v.getColormap(TC_DEFAULT, color))

		-- if we have a status condition that has a color, draw it here!
		local s = mo.status_condition
		if cond2color[s] ~= nil

			local tflag = (9 - ((cos(leveltime*10*ANG1) + FRACUNIT)*4)/FRACUNIT) << V_ALPHASHIFT
			-- cos between -FU and FU; cos + FU between 0 and FU*2
			-- *4, /FU to get smth between 0 and 8, then alphashift

			v.drawIndex((x+8)<<FRACBITS, (y-13)<<FRACBITS, FRACUNIT/4, p, flags|tflag, cond2color[s])
		end
	end

	-- is this our player?
	if mo.control == consoleplayer
		V_drawString(v, x+4, y-8, "YOU", "NFNT", flags, nil, 0, 31, FRACUNIT/4)
	end

	-- fill both bars:
	-- HP:

	-- Fast bar draw via graphics:
	v.drawIndex((x)<<FRACBITS, (y)<<FRACBITS, FRACUNIT/2, v.cachePatch("H_FBAR25"), flags, hpoff)	-- back
	if hp
		v.drawIndex((x)<<FRACBITS, (y)<<FRACBITS, FRACUNIT/2, v.cachePatch("H_FBAR"..max(1, (25*hp/mhp))), flags, hpon)
	end


	/*local minbarlen = 26
	local curhp = minbarlen*hp/mhp
	local maxstep = 6

	local i = 0
	while i < minbarlen
		local hpcolor = hpon
		local step = maxstep - (i%maxstep)

		if i >= curhp
			hpcolor = hpoff
		end

		if i+step > curhp
		and i < curhp
			step = curhp - i
			--print("New step is "..step.." compare: "..i.."|"..curhp)
		end
		if i+step > minbarlen
			step = minbarlen - i
		end

		--print("i: "..i..", curhp: "..curhp..", step: "..step..", colour: "..hpcolor)

		v.drawFill(x+2+i, y+4-(i/6), min(step, minbarlen-i), 3, (hpcolor)|V_SNAPTOBOTTOM|V_SNAPTORIGHT)

		i = $+step
	end*/


	/*for i = 0, 26
		v.drawFill(x+2+i, y+4-(i/6), 1, 3, (i > 26*hp/mhp and hpoff or hpon)|V_SNAPTOBOTTOM|V_SNAPTORIGHT)
	end*/

	-- Fast bar draw via graphics:
	v.drawIndex((x-1)<<FRACBITS, (y+3)<<FRACBITS, FRACUNIT/2, v.cachePatch("H_FBAR25"), flags, msp and spoff or 31)	-- back
	if sp and msp
		v.drawIndex((x-1)<<FRACBITS, (y+3)<<FRACBITS, FRACUNIT/2, v.cachePatch("H_FBAR"..max(1, (25*sp/msp))), flags, spon)
	end

	/*i = 0
	local cursp = minbarlen*sp/(msp or 1)	-- !

	while i < minbarlen
		local spcolor = spon
		local step = maxstep - (i%maxstep)

		if i >= cursp
			spcolor = spoff
		end
		if i+step > cursp
		and i < cursp
			step = cursp - i
		end

		if i+step > minbarlen
			step = minbarlen - i
		end

		v.drawFill(x+1+i, y+7-(i/6), min(step, minbarlen-i), 3, (nosp and 31 or spcolor)|V_SNAPTOBOTTOM|V_SNAPTORIGHT)

		i = $+step
	end*/

	-- SP
/*	for i = 0, 26
		v.drawFill(x+1+i, y+7-(i/6), 1, 3, nosp and 31|V_SNAPTOBOTTOM|V_SNAPTORIGHT or (i <= 26*sp/msp and spon or spoff)|V_SNAPTOBOTTOM|V_SNAPTORIGHT)
	end*/

	-- draw the bar overlay:
	PDraw(v, x, y, v.cachePatch("H_HPBGS"), flags|(trans and V_30TRANS or 0))

	-- draw the numbers:
	-- HP:
	local s = tostring(min(999, mo.hp))
	local nx = x
	local ny = (y+2)<<FRACBITS

	for i = 1, s:len()
		local n = s:sub(i,i)
		local getbyte = n:byte()
		V_drawLetter(v, (nx)<<FRACBITS - FRACUNIT/2, ny - FRACUNIT/2, string.char(getbyte+10), "FSNUM", flags, 31)
		V_drawLetter(v, (nx)<<FRACBITS, ny, n, "FSNUM", flags, hpon)
		nx = $+4
		ny = $-FRACUNIT/2
	end

	-- SP:
	s = msp and tostring(min(999, mo.sp)) or ""
	nx = x-1
	ny = (y+7)<<FRACBITS

	for i = 1, s:len()
		local n = s:sub(i,i)
		local getbyte = n:byte()
		V_drawLetter(v, (nx)<<FRACBITS - FRACUNIT/2, ny - FRACUNIT/2, string.char(getbyte+10), "FSNUM", flags, 31)
		V_drawLetter(v, (nx)<<FRACBITS, ny, n, "FSNUM", flags, spon)
		nx = $+4
		ny = $-FRACUNIT/2
	end

	-- finally, draw physhud sparkles
	DisplayPhysHUD(v, "heal", displayplayer)
end)

-- draw the main command selection for a player
local cmd_names = {
	"Attack",
	"Skill",
	"Items",
	"Personas",
	"Tactics",
	"Defend"
}

local cmd_hints = {
	"Use a physical attack",
	"Attack with your Persona",
	"Use an item",
	"Switch Sub-Personas",
	"Use battle tactics",
	"Protect from next attack",
}

local cmd_patches = {}
local cmd_patches_grey = {}
local cmd_patches_atk = {}
local cmd_patches_atk_grey = {}

local cv_command = CV_RegisterVar({
	name = "hu_bcommandwheel",
	defaultvalue = "On",
	PossibleValue = CV_OnOff,
})


local function drawPlayerCommands(v, mo)

	if mo.t_hidehud return end

	-- cache patches in memory
	if not cmd_patches[1]	-- not cached
		cmd_patches[0] = v.cachePatch("H_CMDBC")	-- background
		for i = 1, 6
			cmd_patches[i] = v.cachePatch("H_CMD"..i)
			cmd_patches_grey[i] = v.cachePatch("H_CMD"..i.."G")
		end

		cmd_patches_atk[1] = v.cachePatch("H_CMDB")		-- slash
		cmd_patches_atk_grey[1] = v.cachePatch("H_CMDBG")	-- slash grey

		cmd_patches_atk[2] = v.cachePatch("H_CMD1")		-- strike
		cmd_patches_atk_grey[2] = v.cachePatch("H_CMD1G")	-- strike grey

		cmd_patches_atk[3] = v.cachePatch("H_CMDA")		-- pierce
		cmd_patches_atk_grey[3] = v.cachePatch("H_CMDAG")	-- pierce grey

		cmd_patches_atk[4] = v.cachePatch("H_CMDC")		-- almighty (super exclusive)
		cmd_patches_atk_grey[4] = v.cachePatch("H_CMDCG")	-- almighty grey
	end

	local battle = server.P_BattleStatus[mo.battlen]
	local timer = battle.hudtimer.start or battle.hudtimer.newturn
	-- center x y are of fixed position, don't bother:
	local cx, cy = 20<<FRACBITS, 135<<FRACBITS
	local s_ang = ANG1*60
	local b_ang = ANG1*65 + mo.t_command*s_ang + ANG1*20*mo.t_renderangle-- base angle for drawing
	local radius = 48 + 32*timer

	-- render BG
	PDraw(v, 0 - 24*timer, 200 + 24*timer, v.cachePatch("H_CMDBC"), V_SNAPTOBOTTOM|V_SNAPTOLEFT)

	local angle, x, y, scale = 0, 0, 0, 0

	for i = 1, 6

		if cv_command.value
			angle = b_ang - (i-1)*s_ang - 16*timer*ANG1	-- start timer fancies
			local cosang = cos(angle)

			x = cx + radius*(cosang*5/4) - abs(16*cosang)	-- adjust to ease shape on X coord
			y = cy + radius*(sin(angle)*2/3)	-- scale Y so that it looks more like an oval
			scale = FRACUNIT/4 + cos(angle-ANG1*65)/6 + timer*FRACUNIT/6
		end

		local pp = "H_CMD"..i
		local index = i

		if i == 1

			local atktype = mo.attack.type
			if mo.weapon and mo.weapon.element
				atktype = mo.weapon.element
			end

			local lookup = "H_CMD"..string.char(65 + atk_constant_2_num[atktype]-1)

			if v.patchExists(lookup)
				pp = lookup
			else
				pp = "H_CMD1"
			end
		end
		if (mo.commandflags & 2^(i-1))
			pp = $.."G"
		end

		if x > -32*FRACUNIT and scale > 1
			v.drawScaled(x, y, scale, v.cachePatch(pp), V_SNAPTOBOTTOM|V_SNAPTOLEFT)
		end
	end

	-- hint text
	v.drawFill(0, 182, 450 - timer*4, 8, 135|V_SNAPTOBOTTOM|V_SNAPTOLEFT)
	V_drawString(v, 34, 182, cmd_hints[mo.t_command+1], "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 31, nil)

	-- command name
	V_drawString(v, 40, 172, cmd_names[mo.t_command+1]:upper(), "FPIMP", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 0, 31)
	--drawCusString(v, 20, 190, "PersonaImpact", cmd_names[mo.t_command+1]:upper(), 0|V_SNAPTOBOTTOM|V_SNAPTOLEFT, 31|V_SNAPTOBOTTOM|V_SNAPTOLEFT)

	-- if possible, draw baton touch indicator
	if mo.batontouch
		local patchn = "H_BATON1"

		if #server.plentities[mo.battlen] < 2 return end	-- don't draw if we don't have at least 2 members

		if mo.commandflags
			if mo.commandflags & CDISABLE_BATONPASS	-- don't draw it, then
				return
			end
		end

		local x = 151 + (timer/2)*40
		PDraw(v, x, 116, v.cachePatch(patchn))
		V_drawString(v, x + 27, 119, "BATON", "FPIMP", nil, 0, 0, 31)
		V_drawString(v, x + 32, 129, "PASS", "FPIMP", nil, 0, 0, 31)
	end
end

-- draw the main command selection fading out when you get to a new menu.
local function drawPlayerCommands_Out(v, mo)
	local battle = server.P_BattleStatus[mo.battlen]
	local timer = battle.hudtimer.to
	local bg_timer = timer-1

	if not cv_command.value return end

	-- center x y are of fixed position, don't bother:
	local cx, cy = 20<<FRACBITS, 135<<FRACBITS
	local b_ang = ANG1*65
	local radius = 48

	-- render BG
	PDraw(v, -144 + 24*bg_timer, 344 - 24*bg_timer, cmd_patches[0], V_SNAPTOBOTTOM|V_SNAPTOLEFT)
	local x = cx + radius*FixedMul(FRACUNIT*5/4, cos(b_ang)) - abs(16*cos(b_ang))	-- adjust to ease shape on X coord
	local y = cy + FixedMul(FRACUNIT*2/3, radius*sin(b_ang))	-- scale Y so that it looks more like an oval
	local scale = FRACUNIT/4 + cos(0)/6

	local index = mo.t_command+1
	local pp = "H_CMD"..index

	if mo.t_command == 0
		local atktype = mo.attack.type
		if mo.weapon and mo.weapon.element
			atktype = mo.weapon.element
		end

		local lookup = "H_CMD"..string.char(65 + atk_constant_2_num[atktype]-1)

		if v.patchExists(lookup)
			pp = lookup
		else
			pp = "H_CMD1"
		end
	end

	if (mo.commandflags & 2^(index-1))
		pp = $.."G"
	end

	if x > -32*FRACUNIT and scale > 1
		v.drawScaled(x, y, scale, v.cachePatch(pp), V_SNAPTOBOTTOM|V_SNAPTOLEFT)
	end

	V_drawString(v, 40, 172, cmd_names[mo.t_command+1]:upper(), "FPIMP", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 0, 31)

end

-- draw the main command selection fading back in when exiting from a submenu to the main menu
local function drawPlayerCommands_In(v, mo)
	local battle = server.P_BattleStatus[mo.battlen]
	local timer = 7-battle.hudtimer.out

	if not cv_command.value return end

	-- center x y are of fixed position, don't bother:
	local cx, cy = 20<<FRACBITS, 135<<FRACBITS
	local radius = 48 - 24*battle.hudtimer.out
	local s_ang = ANG1*60
	local b_ang = ANG1*65 + mo.t_command*s_ang

	-- render BG
	PDraw(v, -144 + 24*timer, 344 - 24*timer, cmd_patches[0], V_SNAPTOBOTTOM|V_SNAPTOLEFT)
	for i = 1, 6
		local r_radius = i-1 == mo.t_command and 48 or radius
		local angle = b_ang - (i-1)*s_ang
		local x = cx + r_radius*FixedMul(FRACUNIT*5/4, cos(angle)) - abs(16*cos(angle))	-- adjust to ease shape on X coord
		local y = cy + FixedMul(FRACUNIT*2/3, r_radius*sin(angle))	-- scale Y so that it looks more like an oval
		local scale = max(1, FRACUNIT/4 + cos(angle-ANG1*65)/6 - battle.hudtimer.out*(i-1 ~= mo.t_command and FRACUNIT/12 or 0))

		local pp = "H_CMD"..i
		local index = i

		if i == 1

			local atktype = mo.attack.type
			if mo.weapon and mo.weapon.element
				atktype = mo.weapon.element
			end

			local lookup = "H_CMD"..string.char(65 + atk_constant_2_num[atktype]-1)

			if v.patchExists(lookup)
				pp = lookup
			else
				pp = "H_CMD1"
			end
		end
		if (mo.commandflags & 2^(i-1))
			pp = $.."G"
		end

		if x > -32*FRACUNIT and scale > 1
			v.drawScaled(x, y, scale, v.cachePatch(pp), V_SNAPTOBOTTOM|V_SNAPTOLEFT)
		end
	end

	V_drawString(v, 40, 172, cmd_names[mo.t_command+1]:upper(), "FPIMP", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 0, 31)
end

local skill_color = {
	[1] = SKINCOLOR_ORANGE,
	[2] = SKINCOLOR_ORANGE,
	[4] = SKINCOLOR_ORANGE,
	[8] = SKINCOLOR_RED,
	[16] = SKINCOLOR_CYAN,
	[32] = SKINCOLOR_EMERALD,
	[64] = SKINCOLOR_YELLOW,
	[128] = SKINCOLOR_PURPLE,
	[256] = SKINCOLOR_TEAL,
	[512] = SKINCOLOR_GOLD,
	[1024] = SKINCOLOR_CRIMSON,
	[2048] = SKINCOLOR_WHITE,
	[4096] = SKINCOLOR_GREEN,
	[8192] = SKINCOLOR_BLUE,
	[16384] = SKINCOLOR_WHITE,
}

local ep_colors = {
	[0] = SKINCOLOR_BLACK,
	[1] = SKINCOLOR_EMERALD,
	[2] = SKINCOLOR_PURPLE,
	[3] = SKINCOLOR_GOLD,
	[4] = SKINCOLOR_CYAN,
	[5] = SKINCOLOR_RED,
	[6] = SKINCOLOR_ORANGE,
	[7] = SKINCOLOR_GREY,
}

-- also used in menus
rawset(_G, "drawSkillCommand", function(v, x, y, mo, skill, active, have_item, skillcard, equip, owner)	-- draw skill command (also applies for items)
	if not skill
		-- Generate our own skill in that case...
		skill = {
			name = "INVALID SKILL",
			type = ATK_SLASH,
			power = 0,
			accuracy = 0,
		}
	end
	-- type icon

	-- note: passives stack with other types.
	local atk_type
	local atk_color
	if skill.type & ATK_PASSIVE	-- rather special case, heh!
		atk_type = 15
		atk_color = SKINCOLOR_ORANGE
	else
		atk_type = atk_constant_2_num[skill.type]
	end

	local unknown
	if server.gamemode == GM_VOIDRUN
		if server.P_DungeonStatus.VR_clause == VE_SKILLJAMMER
		and not have_item

		or have_item
		and server.P_DungeonStatus.VR_clause == VE_ITEMJAMMER
			unknown = true
		end
	end

	if unknown
		atk_color = SKINCOLOR_GREY
		atk_type = 0

		skill = {
			name = "JAMMED",
			type = 0,
			power = 0,
			accuracy = 0,
		}

	end

	PDraw(v, x+3, y+3, v.cachePatch("ATK_"..atk_type), V_SNAPTOLEFT)
	-- background
	PDraw(v, x, y, v.cachePatch("H_ATKBG"), V_SNAPTOLEFT, v.getColormap(TC_DEFAULT, atk_color or skill_color[skill.type]))

	if have_item	-- Skill is from item list, proceed differently.
		-- name
		V_drawString(v, x+20, y+2, unknown and "JAMMED" or itemDefs[have_item[1]].name:upper(), "FPIMP", V_SNAPTOLEFT, nil, (not active and 16 or 0), 31)
		v.drawIndex((x+22)<<FRACBITS, (y+15)<<FRACBITS, FRACUNIT/2, v.cachePatch("H_HAVE"), V_SNAPTOLEFT, 31)
		v.drawIndex((x+21)<<FRACBITS, (y+14)<<FRACBITS, FRACUNIT/2, v.cachePatch("H_HAVE"), V_SNAPTOLEFT, not active and 16 or 0)
		V_drawString(v, x+42, y+12, unknown and "" or have_item[2], "FPNUM", V_SNAPTOLEFT, nil, not active and 16 or 0, 31)
		return
	end

	-- name
	V_drawString(v, x+20, y+2, skill.name:upper(), "FPIMP", V_SNAPTOLEFT, nil, (not active and 16 or 0), 31)
	--drawCusString(v, x+20, y+4, "PersonaImpact", skill.name:upper(), 0|V_SNAPTOLEFT, 31|V_SNAPTOLEFT)

	if equip
		V_drawString(v, x+21, y+14, "\x82".."EQUIPPED", "FPIMP", V_SNAPTOLEFT, nil, (not active and 16 or 0), 31, FRACUNIT/4)
		return
	end
	if skillcard
		V_drawString(v, x+21, y+14, "SKILL CARD", "FPIMP", V_SNAPTOLEFT, nil, (not active and 16 or 0), 31, FRACUNIT/4)
		return
	end

	-- is this skill a weakness?
	-- check if we got a battle going before checking this however
	if mo.battlen and server.P_BattleStatus[mo.battlen] and server.P_BattleStatus[mo.battlen].running
	and not (skill.type & ATK_PASSIVE)	-- yeah no lol

		local drawn

		for i = 1, #mo.enemies
			local t = mo.enemies[i]
			if t.enemy and server.P_BattleStatus[mo.battlen].saved_affs[t.enemy][1] & getAttackType(mo, skill)	-- make sure we unlocked the affinity ...
			--and t.weak & skill.type	-- TODO: finish the thingy to check affinities reliably
			and getAttackAff(t, skill, mo) == DMG_WEAK	-- lol did it

				local scale = leveltime%10 < 5 and FRACUNIT/2 or FRACUNIT/2 + FRACUNIT/10
				v.drawScaled((x+60)<<FRACBITS, (y+20)<<FRACBITS, scale, v.cachePatch("H_AWEAK"), V_SNAPTOLEFT)
				drawn = true

			-- technical damage doesn't require knowledge of the affinity
			elseif getAttackAff(t, skill, mo) == DMG_TECHNICAL
			and not drawn
				local scale = leveltime%10 < 5 and FRACUNIT/2 or FRACUNIT/2 + FRACUNIT/10
				v.drawScaled((x+60)<<FRACBITS, (y+20)<<FRACBITS, scale, v.cachePatch("H_ATECH"), V_SNAPTOLEFT)
				drawn = true
			end
		end
	end

	-- draw the cost:
	-- get cost amount
	local cost
	local pp = {"H_HP", 131}

	if not skill.cost or unknown return end	-- nothing to draw here

	if skill.costtype ~= CST_SPU
		if skill.costtype == CST_HPPERCENT
			cost = skill.cost*mo.maxhp/100

		elseif skill.costtype == CST_EP	-- emerald power
			cost = skill.cost
			pp = {"C_EP"}
		else
			cost = skill.cost
			if skill.costtype == CST_SP
				pp = {"H_SP", 181}
			end
		end

		if mo.status_condition == COND_SUPER
			cost = 0	-- hack
		end

		V_drawString(v, x+32, y+12, cost, "FPNUM", V_SNAPTOLEFT, "right", ((skill.costtype == CST_EP and 112 or skill.costtype == CST_SP and 181 or 131) + (not active and 3 or 0)), 31)
		v.drawIndex((x+35)<<FRACBITS, (y+15)<<FRACBITS, FRACUNIT/2, v.cachePatch(pp[1]), V_SNAPTOLEFT, 31)

		if pp[2]	-- palette index: SP, or HP
			v.drawIndex((x+34)<<FRACBITS, (y+14)<<FRACBITS, FRACUNIT/2, v.cachePatch(pp[1]), V_SNAPTOLEFT, pp[2] + (not active and 3 or 0))
		else	-- for emerald power, use normal colours and draw
			v.drawScaled((x+34)<<FRACBITS, (y+14)<<FRACBITS, FRACUNIT/2, v.cachePatch(pp[1]), V_SNAPTOLEFT, v.getColormap(TC_DEFAULT, ep_colors[cost]))
		end
	else
		cost = min(4, skill.cost)
		v.drawIndex((x+20)<<FRACBITS, (y+15)<<FRACBITS, FRACUNIT/2, v.cachePatch("H_SPU"), V_SNAPTOLEFT, 31)
		v.drawIndex((x+19)<<FRACBITS, (y+14)<<FRACBITS, FRACUNIT/2, v.cachePatch("H_SPU"), V_SNAPTOLEFT, 194 + (not active and 3 or 0))
		PDraw(v, x+36, y+12, v.cachePatch("H_SPU_"..cost), V_SNAPTOLEFT)
	end

	if owner
		local patch = charStats[owner.stats].icon
		PDraw(v, x + 48, y+12, v.cachePatch(patch), V_SNAPTOLEFT, v.getColormap(TC_DEFAULT, owner.color))
	end
end)

-- hud only, local vars
local emeraldframe = 0
local nextemeraldframe = 1
local emeraldtimer = 0
local sparkframe = 65
local h_emeraldpow = 0
local prevlv = 0

local cv_partystatus = CV_RegisterVar({
	name = "hu_partystatus",
	defaultvalue = "On",
	PossibleValue = CV_OnOff,
})

-- draw party status
local function drawPartyStatus(v, p, battle)

	if not cv_partystatus.value return end

	local mo = p.control
	if not mo return end --wtf where is our bot

	local team = mo.allies_noupdate
	if not team return end	-- wtf where is our team

	-- draw shit from right to left according to the turn order. It makes our life easier.

	local x = 320	-- - (#team==1 and 65 or 35)

	local i = #team
	local act_index
	-- draw teammate status that aren't acting:
	while i
		if team[i] == battle.turnorder[1]
			act_index = i
			i = $-1
			continue
		end

		x = $ - (i==#team and 35 or 30)
		drawPlayerBarSmall(v, x, 180 + max(0, (battle.hudtimer.start or 0)-(i*4))*12, team[i])
		i = $-1
	end

	-- draw the acting teammate's bar
	if act_index
		x = $ - (act_index==#team and 65 or 60)
		drawPlayerBar(v, x, 172 + max(0, (battle.hudtimer.start or 0)-(act_index*4))*12, team[act_index])
	end


	if not battle.emeraldpow_max return end

	-- draw emerald power gauge

	if h_emeraldpow < battle.emeraldpow
		h_emeraldpow = min(battle.emeraldpow, $+3)
	elseif h_emeraldpow > battle.emeraldpow
		h_emeraldpow = max(battle.emeraldpow, $-3)
	end

	local bx = 270 + (battle.hudtimer.start or 0)*8

	-- actual gauge behind:
	local lvl = battle.emeraldpow/100
	local textcolor = leveltime & 1 and 112 or 0
	if not lvl
		textcolor = leveltime%20 and 112 or 0
	end

	v.drawFill(bx + 28, 64, 8, 64, 118|V_SNAPTORIGHT)

	local fill = (h_emeraldpow%100)*68/100
	-- special case for an entierely filled gauge
	if h_emeraldpow and not (h_emeraldpow%100)
		fill = 68
	end

	for i = 0, 3
		v.drawFill(bx + 28+ i*2, 63+70 - fill - i, 2, fill, textcolor|V_SNAPTORIGHT)
	end

	-- overlay
	PDraw(v, bx, 32, v.cachePatch("H_ED_GAU"), V_SNAPTORIGHT)

	-- cycle through emeralds

	-- make sure next emerald frame isn't too high for our power level;
	if nextemeraldframe == emeraldframe
	and lvl > 1
		nextemeraldframe = $+1
	end

	if nextemeraldframe > lvl
		nextemeraldframe = 1
	end

	if emeraldframe > lvl
		emeraldframe = 1
	end

	local hypermodebuffer = battle.emeraldpow_buffer
	if not lvl and not hypermodebuffer
		emeraldframe = 0
		nextemeraldframe = 0
	end

	if lvl
		nextemeraldframe = max($, 1)
	end

	PDraw(v, bx, 32, v.cachePatch("H_ED_EMR"), V_SNAPTORIGHT, v.getColormap(0, ep_colors[emeraldframe]))

	-- if we have enough of a level, start drawing the flashing overlay
	if lvl
		emeraldtimer = $+1

		local tflag = (10 - emeraldtimer/10)<<V_ALPHASHIFT

		PDraw(v, bx, 32, v.cachePatch("H_ED_EMR"), V_SNAPTORIGHT|tflag, v.getColormap(0, ep_colors[nextemeraldframe]))

		if emeraldtimer > 99
			emeraldframe = $+1
			nextemeraldframe = emeraldframe+1
			--print(emeraldframe.."|"..nextemeraldframe)
			emeraldtimer = 0
		end
	else
		emeraldtimer = 0
	end

	-- hyper mode aura:
	if hypermodebuffer and leveltime & 1

		PDraw(v, bx, 32, v.cachePatch("H_ED_EMR"), V_SNAPTORIGHT|V_50TRANS, v.getColormap(0, SKINCOLOR_WHITE))

		local pp = v.cachePatch("DELK"..string.char(sparkframe).."0")

		sparkframe = N_RandomRange(65, 65+11)

		PDraw(v, bx+23, 140, pp, V_SNAPTORIGHT, v.getColormap(0, ep_colors[emeraldframe]))

		-- if we have enough of a level, start drawing the flashing overlay
		if lvl
			local tflag = (10 - emeraldtimer/10)<<V_ALPHASHIFT

			PDraw(v, bx+23, 140, pp, V_SNAPTORIGHT|tflag, v.getColormap(0, ep_colors[nextemeraldframe]))
		end
	end

	-- level #
	--if not battle.emeraldpow
	local flash
	local turn = battle.turnorder[1]

	-- flash the number if we use an EP skill.
	if turn and turn.valid and turn.t_act and turn.t_act == ACT_SKILL and battle.battlestate == BS_DOTURN
		-- get skill:
		if turn.attack.costtype == CST_EP
			flash = 2
		end
	end

	if (not flash) or leveltime%10 < 5
		V_drawString(v, bx + 26, 32+18, lvl, "FPNUM", V_SNAPTORIGHT, nil, textcolor, 31, FRACUNIT*2/3)
	end

	-- finally, draw physhud sparkles
	DisplayPhysHUD(v, "emeraldpow", displayplayer)
	if battle.hudtimer.hypermode == TICRATE-1
	or battle.hudtimer.emeraldlvup == TICRATE-1

		for i = 1, 32
			local part = phud.create(mo.battlen, 290, 140, "SUBP1", TICRATE*5, v.getColormap(TC_DEFAULT, ep_colors[emeraldframe]), "emeraldpow")

			local ang = N_RandomRange(0, 359)*ANG1
			local spd = N_RandomRange(1, 10)

			part.scale = FRACUNIT + N_RandomRange(0, 65534)
			part.momx = (spd*cos(ang))/FRACUNIT
			part.momy = (spd*sin(ang))/FRACUNIT
			part.physflags = PF_NOGRAVITY
			part.destscale = 1
			part.flags = V_SNAPTORIGHT
		end

	end

	if battle.hudtimer.hypermode
		local pp = v.cachePatch("H_HYPRON")
		local rt = TICRATE - battle.hudtimer.hypermode

		local initscale = min(FRACUNIT/2, rt*FRACUNIT/8)
		local scale2 = rt*FRACUNIT/8

		local tflag = 0
		if rt > 25
			tflag = (rt-25)<<V_ALPHASHIFT
		end

		v.drawIndex(292<<FRACBITS, 142<<FRACBITS, initscale, pp, V_SNAPTORIGHT|tflag, 31)
		v.drawIndex(290<<FRACBITS, 140<<FRACBITS, initscale, pp, V_SNAPTORIGHT|tflag, textcolor)

		local tflag2 = (rt/3)<<V_ALPHASHIFT
		if rt >= 30
			return
		end

		-- the ghost thingy:
		v.drawIndex(290<<FRACBITS, 140<<FRACBITS, scale2, pp, V_SNAPTORIGHT|tflag2, textcolor)


	end
end

local function drawPlayerSkillList(v, p, mo)

	local timer = server.P_BattleStatus[mo.battlen].hudtimer.to
	local out_timer = server.P_BattleStatus[mo.battlen].hudtimer.out or 7
	local unknown = server.P_DungeonStatus.VR_clause == VE_SKILLJAMMER

	-- if player can switch sub personas, by all means, let em do it!

	/*if #server.P_BattleStatus.subpersonas > 1
		local x = 151 + (timer/2)*40
		PDraw(v, x, 116, v.cachePatch("H_SWITCHP"))
	end*/

	if server.P_BattleStatus[mo.battlen].hudtimer.out
		PDraw(v, -174 + out_timer*32, 173 - out_timer*4, v.cachePatch("H_BOX_D"), V_SNAPTOBOTTOM|V_SNAPTOLEFT|TR_TRANS30)
		drawPlayerCommands_In(v, mo)	-- for return
	else
		PDraw(v, 50 - timer*32, 145 + timer*4, v.cachePatch("H_BOX_D"), V_SNAPTOBOTTOM|V_SNAPTOLEFT|TR_TRANS30)
		drawPlayerCommands_Out(v, mo)	-- for entry
	end

	for i = 1, #mo.skills
		local intend_y = 60
		local y = 60 + 32*(i-1) - (mo.t_skillselect-1)*32 - mo.t_selectslide
		local diff = abs(intend_y - y)
		local skill = attackDefs[mo.skills[i]]
		drawSkillCommand(v, 0 - timer^2 - (7-out_timer)*24 - (diff^2)/96, y, mo, skill, i == mo.t_skillselect)
	end

	-- draw hit rate and power
	v.drawFill(0, 182, 450, 8, 135|V_SNAPTOBOTTOM|V_SNAPTOLEFT)

	local skill = attackDefs[mo.skills[mo.t_skillselect]]
	if not skill
		-- Invalid skill
		skill = {
			power = 999999,
			accuracy = 999,
			desc = "This is an invalid skill.\nYou may want to get this fixed!\nInternal: \'"..mo.skills[mo.t_skillselect].."\'"
		}
	end

	local power = (skill.power) or "--"
	local accuracy = skill.accuracy or "--"

	if type(power) == "number"
	and power > 99999
	or unknown
		power = "--"
	end
	if type(accuracy) == "number"
	and accuracy >= 999
	or unknown
		accuracy = "--"
	end

	V_drawString(v, 60, 183, "POW "..power, "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 31, nil)
	V_drawString(v, 110, 183, "HIT "..accuracy, "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 31, nil)

	-- draw description
	drawPartyStatus(v, p, server.P_BattleStatus[mo.battlen])
	V_drawString(v, 60, 150, unknown and "" or skill.desc, "NFNT", V_SNAPTOLEFT|V_SNAPTOBOTTOM, nil, 0, 31)

end

local function drawPlayerItemList(v, p, mo)
	local items = server.P_BattleStatus[mo.battlen].items
	local timer = server.P_BattleStatus[mo.battlen].hudtimer.to
	local out_timer = server.P_BattleStatus[mo.battlen].hudtimer.out or 7
	if server.P_BattleStatus[mo.battlen].hudtimer.out
		PDraw(v, -174 + out_timer*32, 173 - out_timer*4, v.cachePatch("H_BOX_D"), V_SNAPTOBOTTOM|V_SNAPTOLEFT|TR_TRANS30)
		drawPlayerCommands_In(v, mo)	-- for return
	else
		PDraw(v, 50 - timer*32, 145 + timer*4, v.cachePatch("H_BOX_D"), V_SNAPTOBOTTOM|V_SNAPTOLEFT|TR_TRANS30)
		drawPlayerCommands_Out(v, mo)	-- for entry
	end
	-- for dbg purposes we'll assume we always have 8 skills or so to test or smthin
	for i = 1, server.P_BattleStatus[mo.battlen].it_section2-1 --or #server.P_BattleStatus[mo.battlen].items
		local intend_y = 60
		local y = 60 + 32*(i-1) - (mo.t_itemselect-1)*32 - mo.t_selectslide
		local diff = abs(intend_y - y)
		local atk = itemDefs[items[i][1]].attack
		local skill = attackDefs[atk]
		drawSkillCommand(v, 0 - timer^2 - (7-out_timer)*24 - (diff^2)/96, y, mo, skill, i == mo.t_itemselect, server.P_BattleStatus[mo.battlen].items[i])
	end

	-- draw description
	drawPartyStatus(v, p, server.P_BattleStatus[mo.battlen])
	local skill = items[mo.t_itemselect] and itemDefs[items[mo.t_itemselect][1]] or nil
	V_drawString(v, 60, 150, skill.desc or "Description missing", "NFNT", V_SNAPTOLEFT|V_SNAPTOBOTTOM, nil, 0, 31)
end

local function drawTargetHP(v, x, y, mo, tgt, aff)
	local btl = server.P_BattleStatus[mo.battlen]
	if mo.t_ctarget <= 6

		-- prefix....
		local prefix = "H_THP"
		local cur = tgt.hp
		local maxb = tgt.maxhp
		local color1 = 131
		local color2 = 137

		if mo.attack and mo.attack.showsp
			prefix = "H_TSP"
			cur = tgt.sp
			maxb = tgt.maxsp or 1
			color1 = 181
			color2 = 185
		end

		if mo.t_ctarget	-- bar popping up anim
			local pp = prefix.."_A"..max(1, (6-mo.t_ctarget)/2)
			PDraw(v, x>>FRACBITS, y>>FRACBITS - 8, v.cachePatch(pp))
			return
		end

		local atktype = 0
		if mo.attack
			atktype = getAttackType(mo, mo.attack)
		end

		-- target is weak to attack we've used before?
		if tgt.enemy and (btl.saved_affs[tgt.enemy][1] & (atktype))
		and mo.attack and aff == DMG_WEAK
			PDraw(v, (x-3)>>FRACBITS, (y-1)>>FRACBITS - 8, v.cachePatch("H_THPW"))

		elseif aff == DMG_TECHNICAL
			PDraw(v, (x-3)>>FRACBITS, (y-1)>>FRACBITS - 8, v.cachePatch("H_THPT"))
		end

		local i = 0
		local blen = 21
		local curhp = cur*21/maxb
		local maxstep = 3

		while i < blen
			local hpcolor = color1
			local step = maxstep - (i%maxstep)

			if i >= curhp
				hpcolor = color2
			end

			if i+step > curhp
			and i < curhp
				step = curhp - i
			end

			if i+step > blen
				step = blen - i
			end
			v.drawFill(x>>FRACBITS-3+i, y>>FRACBITS-25-(i/3), min(step, blen-i), 6, hpcolor)
			i = $+step
		end

		/*for i = 0, 21
			v.drawFill(x>>FRACBITS-3+i, y>>FRACBITS-25 - i/3, 1, 6, i >= (cur*21/maxb) and color2 or color1)
		end*/
		PDraw(v, x>>FRACBITS, y>>FRACBITS - 8, v.cachePatch(prefix..1+(leveltime%20/10)))
	end
end

local function drawPlayerTarget(v, p, c, mo)
	local ret_anim = {4, 3, 2, 1}

	if not mo.t_target return end
	if not mo.targets return end

	local btl = server.P_BattleStatus[mo.battlen]

	PDraw(v, 320 + mo.t_ctarget*24, 0, v.cachePatch("H_BOX_I"), V_SNAPTOTOP|V_SNAPTORIGHT|V_30TRANS)

	if mo.attack and (#mo.targets == 1 or mo.attack.target == TGT_ENEMY or mo.attack.target == TGT_ALLY or mo.attack.target == TGT_DEAD or mo.attack.target == TGT_CASTER)
		local tgt = mo.targets[mo.t_target] or mo.targets[1]
		if not tgt or not tgt.valid return end
		local x,y = R_GetScreenCoords(v, p, c, tgt.x, tgt.y, tgt.z + tgt.target_zoffs*tgt.scale)

		local aff = getAttackAff(tgt, mo.attack, mo)

		if mo.t_ctarget <= 8
			PDraw(v, x>>FRACBITS, y>>FRACBITS, v.cachePatch(mo.t_ctarget and "TGT_"..ret_anim[max(1, mo.t_ctarget/2)] or "TGT_"..5+(leveltime%20/10)))
			-- block / repel warning

			local atktype = 0
			if mo.attack
				atktype = getAttackType(mo, mo.attack)
			end

			-- target is weak to attack we've used before?
			if tgt.enemy and btl.saved_affs[tgt.enemy][1] & atktype
				if (mo.attack and (aff == DMG_BLOCK or aff == DMG_DRAIN))
					PDraw(v, x>>FRACBITS, y>>FRACBITS, v.cachePatch("TGT_NO"))
				elseif (mo.attack and aff == DMG_REPEL)
					PDraw(v, x>>FRACBITS, y>>FRACBITS, v.cachePatch("TGT_NOR"))
				end
			end
		end

		-- draw bar
		drawTargetHP(v, x, y, mo, tgt, aff)

		V_drawString(v, 310 + mo.t_ctarget*24, 5, tgt.name, "NFNT", V_SNAPTORIGHT|V_SNAPTOTOP, "right", 0, 31)
		V_drawString(v, 240 + mo.t_ctarget*24, 5, "\nLV"..tgt.level, "NFNT", V_SNAPTORIGHT|V_SNAPTOTOP, nil, 0, 31)

		-- draw buffs and debuffs
		local stats = {"atk", "mag", "def", "agi", "crit"}
		local drawx = 310 + mo.t_ctarget*24
		for i = 1, #stats do
			local s = stats[i]

			if tgt.buffs[s] and tgt.buffs[s][1]
				-- draw the arrow pointing up or down.
				local pp = tgt.buffs[s][1] < 0 and "H_STATDW" or "H_STATUP"
				local patch = v.cachePatch(pp)

				V_drawString(v, drawx, 25, s:upper(), "NFNT", V_SNAPTORIGHT|V_SNAPTOTOP, "right", 0, 31)

				for i = 1, abs(tgt.buffs[s][1]/BUFFSTEP)
					v.drawIndex((drawx-3 - (i-1)*5)*FRACUNIT, 30*FRACUNIT, FRACUNIT/2, patch, V_SNAPTORIGHT|V_SNAPTOTOP, 31)
					PDraw(v, drawx-4 - (i-1)*5, 29, patch, V_SNAPTORIGHT|V_SNAPTOTOP)
				end

				-- draw for how long this is in effect:
				--V_drawString(v, drawx-12, 40, "("..(tgt.buffs[s][1]/25)..")", "NFNT", V_SNAPTORIGHT|V_SNAPTOTOP, "center", 0, 31)

				drawx = $- 28
			end
		end
	else	-- draw for all targets
		if not mo.targets return end
		for i = 1, #mo.targets
			local tgt = mo.targets[i]
			if not tgt or not tgt.valid continue end
			local x,y = R_GetScreenCoords(v, p, c, tgt.x, tgt.y, tgt.z + tgt.target_zoffs*tgt.scale)

			local aff = getAttackAff(tgt, mo.attack, mo)

			if mo.t_ctarget <= 8
				PDraw(v, x>>FRACBITS, y>>FRACBITS, v.cachePatch(mo.t_ctarget and "TGT_"..ret_anim[max(1, mo.t_ctarget/2)] or "TGT_"..5+(leveltime%20/10)))

				local atktype = 0
				if mo.attack
					atktype = getAttackType(mo, mo.attack)
				end

				-- target is weak to attack we've used before?
				if tgt.enemy and btl.saved_affs[tgt.enemy][1] & atktype
					if (mo.attack and (aff == DMG_BLOCK or aff == DMG_DRAIN))
						PDraw(v, x>>FRACBITS, y>>FRACBITS, v.cachePatch("TGT_NO"))
					elseif (mo.attack and aff == DMG_REPEL)
						PDraw(v, x>>FRACBITS, y>>FRACBITS, v.cachePatch("TGT_NOR"))
					end
				end
			end
			-- draw bar
			drawTargetHP(v, x, y, mo, tgt, aff)
		end

		local str = "Swarm of Shadows"
		if compareTables(mo.allies, mo.targets)
			str = "Party"
		end

		V_drawString(v, 300 + mo.t_ctarget*24, 10, str, "NFNT", V_SNAPTORIGHT|V_SNAPTOTOP, "right", 0, 31)
	end
end


local function drawGuardPrompt(v, p, mo)
	local timer = server.P_BattleStatus[mo.battlen].hudtimer.to
	local out_timer = server.P_BattleStatus[mo.battlen].hudtimer.out or 7
	if server.P_BattleStatus[mo.battlen].hudtimer.out
		PDraw(v, -174 + out_timer*32, 173 - out_timer*4, v.cachePatch("H_BOX_D"), V_SNAPTOBOTTOM|V_SNAPTOLEFT|TR_TRANS30)
		drawPlayerCommands_In(v, mo)	-- for return
	else
		PDraw(v, 50 - timer*32, 145 + timer*4, v.cachePatch("H_BOX_D"), V_SNAPTOBOTTOM|V_SNAPTOLEFT|TR_TRANS30)
		drawPlayerCommands_Out(v, mo)	-- for entry
	end
	V_drawString(v, 60, 150, "Confirm again \nto guard.", "NFNT", V_SNAPTOLEFT|V_SNAPTOBOTTOM, nil, 0, 31)
end

local function drawTransition(v, battle)
	local timer = battle.hudtimer.transition
	if not timer return end

	local x = (6-timer)-25
	local y = 450 - (6-timer)*85
	v.draw(x, y, v.cachePatch("TRANSI"))
end

-- draw something's stats
-- v is the drawer, mo the object to draw stats from, and timer is used for the animation
-- enemy = 1 tells the game not to draw certain things if they've been found
-- if that same enemy also happens to be a boss, then some of its stats will remain hidden

-- note: because of how different level up is from a simple stat display, this function is pasted down there and handled differently to keep this one clean.

local drawstat_targety = 140
local drawstat_y = 140

rawset(_G, "drawStats", function(v, mo, timer, enemy, skilln, cmd)	-- display the skill #

	local btl = server.P_BattleStatus[mo.battlen]

	if not cmd

		cmd = {
						{BUTT_A, "Skill details"},
						{BUTT_B, "Back"},
					}
		if skilln
			cmd = 	{
						{BUTT_DPAD, "Select"},
						{BUTT_B, "Back"},
					}
		end
	end

	-- start by drawing two lines

	R_drawAngledLine(v, 0, 36, ANG1*3, min(400, (timer-2)*32), 31|V_SNAPTOTOP|V_SNAPTOLEFT, 32)
	R_drawAngledLine(v, 30, 0, ANG1*273, min(300, (timer-2)*32), 31|V_SNAPTOTOP|V_SNAPTOLEFT, 64)

	-- enemy name:
	V_drawString(v, min(32, timer*16), 8, mo.name.."\nLV "..mo.level, "NFNT", V_SNAPTOLEFT|V_SNAPTOTOP, nil, 0, 31)

	-- if we are drawing a defeated enemy, show its max HP/SP
	if enemy and btl.saved_affs[mo.enemy][3]
		V_drawString(v, min(10, timer*16), 40, "MAX HP "..mo.maxhp, "NFNT", V_SNAPTOTOP|V_SNAPTOLEFT, nil, 131, nil)
		V_drawString(v, min(10, timer*16), 50, "MAX SP "..mo.maxsp, "NFNT", V_SNAPTOTOP|V_SNAPTOLEFT, nil, 181, nil)
	elseif enemy and not btl.saved_affs[mo.enemy][3]
		V_drawString(v, min(10, timer*16), 40, "MAX HP ???", "NFNT", V_SNAPTOTOP|V_SNAPTOLEFT, nil, 131, nil)
		V_drawString(v, min(10, timer*16), 50, "MAX SP ???", "NFNT", V_SNAPTOTOP|V_SNAPTOLEFT, nil, 181, nil)

	else	-- we are drawing a player, draw HP/SP gauges
		--hp
		for i = 0, 3
			v.drawFill(min(24, timer*16)-i, 45+i, 65, 1, 137|V_SNAPTOTOP|V_SNAPTOLEFT)
			v.drawFill(min(24, timer*16)-i, 45+i, mo.hp*65/mo.maxhp, 1, 131|V_SNAPTOTOP|V_SNAPTOLEFT)
		end
		V_drawString(v, min(10, timer*16), 40, "HP    "..mo.hp.."/"..mo.maxhp, "NFNT", V_SNAPTOTOP|V_SNAPTOLEFT, nil, 135, 31)
		--sp

		for i = 0, 3
			v.drawFill(min(24, timer*16)-i, 55+i, 65, 1, 185|V_SNAPTOTOP|V_SNAPTOLEFT)
			v.drawFill(min(24, timer*16)-i, 55+i, mo.sp*65/(mo.maxsp or 1), 1, 181|V_SNAPTOTOP|V_SNAPTOLEFT)
		end
		V_drawString(v, min(10, timer*16), 50, "SP    "..mo.sp.."/"..mo.maxsp, "NFNT", V_SNAPTOTOP|V_SNAPTOLEFT, nil, 183, 31)
	end

	-- affinities:
	local aff_x = 98
	for i = 0, 10
		PDraw(v, min(aff_x, timer*24), 36 - i, v.cachePatch("ATK_"..atk_constant_2_num[2^i]), V_SNAPTOLEFT|V_SNAPTOTOP)
		PDraw(v, min(aff_x, timer*24), 36 - i, v.cachePatch("H_ELMF"), V_SNAPTOLEFT|V_SNAPTOTOP)
		-- account for buffs!
		local buff
		local debuff

		if mo.buffs[2^i][2]
			buff = mo.buffs[2^i][1] > 0
			debuff = mo.buffs[2^i][1] < 0
		end

		local aff = "/"
		if mo.weak & 2^i and not buff
			aff = "\x82".."WK"
		elseif mo.block & 2^i and not debuff
			aff = "\x86".."NUL"
		elseif mo.resist & 2^i and not debuff
			aff = "\x86".."STR"
		elseif mo.drain & 2^i and not debuff
			aff = "\x85".."DRN"
		elseif mo.repel & 2^i and not debuff
			aff = "\x85".."RPL"
		end

		if enemy
			if not (btl.saved_affs[mo.enemy][1] & (2^i))
				aff = "?"
			end
		end
		V_drawString(v, min(aff_x + 8, timer*24), 54 - i, aff, "NFNT", V_SNAPTOTOP|V_SNAPTOLEFT, "center", 0, nil)
		aff_x = $+20
	end

	-- draw mo's sprite
	local cache
	if mo.sprite == SPR_PLAY
		cache = v.getSprite2Patch(mo.skin, mo.sprite2, false, mo.frame, 2)
	else
		cache = v.getSpritePatch(mo.sprite, mo.frame, 2)
	end

	-- 2.2 was gentle and gave us everything we need <3
	drawstat_y = ($ + drawstat_targety)/2

	PDraw(v, min(280, timer*64), drawstat_y, cache, V_SNAPTORIGHT, v.getColormap(TC_DEFAULT, mo.color))
	drawstat_targety = 140

	-- draw the stats above the sprite if it's gigantic
	local stats = {mo.strength, mo.magic, mo.endurance, mo.agility, mo.luck}
	local statnames = {"STR", "MAG", "END", "AGI", "LUK"}
	for i = 1, #stats do

		if enemy and not btl.saved_affs[mo.enemy][3] break end	-- we haven't beaten the enemy, we don't know its stats!

		V_drawString(v, min(40 + i, -20 + timer*24), 72 + (i-1)*16, statnames[i], "FPIMP", V_SNAPTOLEFT, nil, 0, nil)
		V_drawString(v, min(88 + i, -20 + timer*24), 72 + (i-1)*16, stats[i], "FPNUM", V_SNAPTOLEFT, "right", 0, nil)

		-- draw the bar
		-- bg:
		R_drawAngledLine(v, 96 +i, 75 + (i-1)*16, ANG1*3, min(stats[i]*12/10 + 2, (timer-2)*16), 31|V_SNAPTOLEFT, 6)
		-- stat
		R_drawAngledLine(v, 96 +i, 75 + (i-1)*16, ANG1*3, min(stats[i]*12/10, (timer-2)*16), 135|V_SNAPTOLEFT, 3)
	end

	-- draw the enemy's known skills
	-- Note: their passive skills aren't displayed there.
	-- this is intentional!

	local x, y = 110, 144
	local candesc = true

	local dx = 160
	local dy = 95

	for i = 1, 8 do
		candesc = true
		v.drawFill(min(t*32 - 8*(i-1), x), y, 64, 10, 31|V_SNAPTOBOTTOM|V_SNAPTOLEFT)
		local skname = (mo.skills[i] or "/")
		local aname = skname
		local atype = 0

		if attackDefs[skname]
			aname = attackDefs[$].name
		end

		if enemy and not (btl.saved_affs[mo.enemy][2] & (2^(i-1))) and mo.skills[i]
			local len = skname:len()
			aname = ("?"):rep(len)
			skname = "?"
			candesc = false	-- we don't know what this skill is, so don't even try to draw its scription...
		end
		if candesc
		and attackDefs[skname]
			if attackDefs[skname].type & ATK_PASSIVE
				atype = 15
			else
				atype = atk_constant_2_num[attackDefs[skname].type]
			end
		end

		if atype
			v.drawScaled(min(t*32 - 8*(i-1), x)*FRACUNIT, (y+1)*FRACUNIT, FRACUNIT/4, v.cachePatch("ATK_"..atype), V_SNAPTOBOTTOM|V_SNAPTOLEFT)
			v.drawIndex(min(t*32 - 8*(i-1), x)*FRACUNIT, (y+1)*FRACUNIT, FRACUNIT/4, v.cachePatch("H_ELMF3"), V_SNAPTOBOTTOM|V_SNAPTOLEFT, 31)
		end
		V_drawString(v, min(t*32 - 8*(i-1) +32, x+32), y + 2, aname, aname:len() <= 10 and "NFNT" or "TFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, "center", 0)

		-- if applicable, draw the description...

		if skilln == i	-- and candesc
			drawstat_targety = 100
			v.drawFill(dx, dy, 155, 38, 31|V_SNAPTOLEFT|V_SNAPTOBOTTOM)
			if leveltime % 10 < 5
				v.drawFill(min(t*32 - 8*(i-1), x), y, 64, 10, V_SNAPTOBOTTOM|V_SNAPTOLEFT)
				V_drawString(v, min(t*32 - 8*(i-1) +32, x+32), y + 2, aname, aname:len() <= 10 and "NFNT" or "TFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, "center", 31, nil)
				if atype
					v.drawScaled(min(t*32 - 8*(i-1), x)*FRACUNIT, (y+1)*FRACUNIT, FRACUNIT/4, v.cachePatch("ATK_"..atype), V_SNAPTOBOTTOM|V_SNAPTOLEFT)
					v.drawIndex(min(t*32 - 8*(i-1), x)*FRACUNIT, (y+1)*FRACUNIT, FRACUNIT/4, v.cachePatch("H_ELMF3"), V_SNAPTOBOTTOM|V_SNAPTOLEFT, 0)
				end
			end

			local desc = attackDefs[skname] and attackDefs[skname].desc or "No Skill data"
			if not candesc	-- can't get the description? replace it with ???s
				desc = "???"
			end

			if attackDefs[skname]
				local s = attackDefs[skname]
				V_drawString(v, dx+4, dy-4, s.name, "NFNT", V_SNAPTOLEFT|V_SNAPTOBOTTOM, nil, 0, 31)
			end
			V_drawString(v, dx+4, dy+10, desc, "NFNT", V_SNAPTOLEFT|V_SNAPTOBOTTOM, nil, 0, nil)
		end

		if i%4 == 0
			x = $ + 68
			y = 144
		else
			y = $ + 12
		end
	end

	if not enemy	-- draw NEXT skill for players and SKILL CARD skill, too
		local s = charStats[mo.stats]
		if not s return end
		local persona = s.persona
		if not persona return end	-- what
		persona = personaList[persona]	-- go inside statlist

		local newskill
		local ypos = 170

		for i = 1, #persona.skills
			if persona.skills[i][2] > mo.level	-- next new skill
				newskill = persona.skills[i]
				ypos = 146
				break
			end
		end

		-- display skill card...
		if mo.skillcard

			local sctype
			local scname

			if attackDefs[mo.skillcard]
				if attackDefs[mo.skillcard].type & ATK_PASSIVE
					sctype = 15
				else
					sctype = atk_constant_2_num[attackDefs[mo.skillcard].type]
				end

				scname = ICO_SKILLCARD..attackDefs[mo.skillcard].name
			end

			V_drawString(v, 246, ypos, "SKILL CARD:", "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 0, 31)

			v.drawFill(246, ypos+10, 64, 10, 31|V_SNAPTOBOTTOM|V_SNAPTOLEFT)	-- we need a box o coc riiiiight here

			if sctype
				v.drawScaled(246*FRACUNIT, (ypos+11)*FRACUNIT, FRACUNIT/4, v.cachePatch("ATK_"..sctype), V_SNAPTOBOTTOM|V_SNAPTOLEFT)
				v.drawIndex(246*FRACUNIT, (ypos+11)*FRACUNIT, FRACUNIT/4, v.cachePatch("H_ELMF3"), V_SNAPTOBOTTOM|V_SNAPTOLEFT, 31)
			end

			V_drawString(v, 278, ypos+12, scname, scname:len() <= 10 and "NFNT" or "TFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, "center", 0)	-- skill name

		end

		if not newskill return end

		ypos = 170

		local atype
		local nskname = newskill[1]
		if attackDefs[nskname]
			if attackDefs[nskname].type & ATK_PASSIVE
				atype = 15
			else
				atype = atk_constant_2_num[attackDefs[nskname].type]
			end

			nskname = attackDefs[$].name
		end

		V_drawString(v, 246, ypos, "NEXT: LV"..newskill[2], "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 0, 31)

		v.drawFill(246, ypos+10, 64, 10, 31|V_SNAPTOBOTTOM|V_SNAPTOLEFT)	-- we need a box o coc riiiiight here

		if atype
			v.drawScaled(246*FRACUNIT, (ypos+11)*FRACUNIT, FRACUNIT/4, v.cachePatch("ATK_"..atype), V_SNAPTOBOTTOM|V_SNAPTOLEFT)
			v.drawIndex(246*FRACUNIT, (ypos+11)*FRACUNIT, FRACUNIT/4, v.cachePatch("H_ELMF3"), V_SNAPTOBOTTOM|V_SNAPTOLEFT, 31)
		end

		V_drawString(v, 278, ypos+12, nskname, nskname:len() <= 10 and "NFNT" or "TFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, "center", 0)	-- skill name
	end

	V_drawCommands(v, cmd)
end)

-- Tactics menu
local tactic_names = {
	"ANALYSIS",
	"PARTY",
	"ESCAPE"
}

local tactic_descs = {
	"Check enemy details",
	"Change party command between \nAI and players",
	"Attempt to flee"
}

local thinker_names = {
	[0] = "Manual",
	[1] = "Act Freely",
	[2] = "Knock Down",
	[3] = "Full Assault",
	[4] = "Same Target",
	[5] = "Heal/Support"
}

local thinker_descs = {
	[0] = "Manually control this\nparty member",
	[1] = "Act according to the situation\nof the battle",
	[2] = "Try to knock down every\nenemy to initiate All-Out\nAttacks",
	[3] = "Disregard the party's condition\nand attack enemies with\nthe strongest skills available",
	[4] = "Attacks the same target\nas yours",
	[5] = "Focus on healing and buffing\nother party members with skills\nor items"
}

local function drawTactics(v, p, mo)
	local btl = server.P_BattleStatus[mo.battlen]
	local timer = btl.hudtimer.to
	local out_timer = btl.hudtimer.out or 7

	-- party sub menu goes below the other tactic overlay.
	-- I know, this sounds retarded
	if mo.t_tacticsubmenu and mo.t_tacticsubmenu == 2

		-- below that still, let's throw the thinker selection itself... <ASCII ART OF THROWN TABLE>
		if mo.t_tacticsubmenu2 == 1
			local t = (btl.hudtimer.tactic_out2) or (TICRATE*2/3 - (btl.hudtimer.tactic_in2 or 0))	-- just play animations in reverse if we exit
			for i = 0, 5
				local x = min(200 + (i-1)*6, (t-(i-1)*2)*70)
				v.drawFill(x, 30 + 16*(i-1), 90, 16, (mo.t_subtacticselect2 == i and 135 or 31)|V_SNAPTOLEFT)
				V_drawString(v, x+10 + 30, 32 + 16*(i-1), thinker_names[i], "NFNT", V_SNAPTOLEFT, "center", 0, nil)
			end
		end

		local t = (btl.hudtimer.tactic_out) or (TICRATE*2/3 - (btl.hudtimer.tactic_in or 0))	-- just play animations in reverse if we exit
		local pp = v.cachePatch("H_TACP")
		for i = 1, #mo.allies
			local m = mo.allies[i]
			-- display our party and their control state
			local x = min(110 + (i-1)*8, (t-(i-1)*2)*64)
			PDraw(v, x, 30 + 35*(i-1), pp, V_SNAPTOLEFT)

			local controlname = ""
			if m.control and m.control.name
				controlname = " ("..m.control.name..")"
			end
			local supp = ""
			if m == mo.control.maincontrol
				supp = "*"
			end

			local flag = ((m.control ~= mo.control) or (m == mo) or (m == mo.control.maincontrol)) and true or false
			local color = (mo.t_subtacticselect == i and leveltime%16 < 8) and 135 or flag and 20 or 0	-- selection
			V_drawString(v, x + (i-1)*3, 20 + 35*(i-1), charStats[mo.allies[i].stats].name..controlname..supp.."\n"..thinker_names[mo.allies[i].thinkern], "NFNT", V_SNAPTOLEFT, nil, color, nil)
		end
	elseif mo.t_tacticsubmenu and mo.t_tacticsubmenu == 3 -- well guess that, so does the run away vote hud

		-- draw the overlay box:
		local t = (btl.hudtimer.tactic_out) or (TICRATE*2/3 - (btl.hudtimer.tactic_in or 0))	-- just play animations in reverse if we exit
		local x = min(190, t*64)
		PDraw(v, x, 105, v.cachePatch("H_TARUN"), V_SNAPTOLEFT)

		-- display votes:
		local hasvoted	-- have *we* voted?
		local votesuccess	-- has the vote succeeded?

		for i = 1, #mo.allies do

			local vx = 160 + i*20
			local vy = 135 - i*8

			-- check if we've voted...
			if mo.allies[i] == mo and mo.t_runvotes[i] ~= nil
				hasvoted = true
			end

			if mo.t_runvotes[i]	-- voted yes, thumbs up!
				PDraw(v, vx, vy + ((leveltime%8)/4)*2, v.cachePatch("H_RUNYES"), V_SNAPTOLEFT)
			elseif mo.t_runvotes[i] == false	-- false is voted AGAINST, nil is no vote, so don't just do an else check
				PDraw(v, vx, vy + ((leveltime%8)/4)*2, v.cachePatch("H_RUNNO"), V_SNAPTOLEFT)
			end
		end

		-- draw the text:
		V_drawString(v, x, 70, "Run away? Y/N", "NFNT", V_SNAPTOLEFT, nil, 0, nil)
		if t >= TICRATE*2/3
			local timer = max(0, mo.t_runvotetime-TICRATE)
			local seconds = timer/TICRATE
			local cs = tostring(G_TicsToCentiseconds(timer))
			V_drawString(v, x, 80, seconds.."."..string.format("%02d", cs), "NFNT", V_SNAPTOLEFT, nil, 0, nil)
		end
		-- we haven't voted, display the commands
		if not hasvoted
			V_drawString(v, x-40, 100, "A: Yes\nB: No", "NFNT", V_SNAPTOLEFT, nil, 0, nil)
		else
			V_drawString(v, x-40, 100, "VOTED", "NFNT", V_SNAPTOLEFT, nil, 24, nil)
		end
	end

	if server.P_BattleStatus[mo.battlen].hudtimer.out
		local pp = "H_TACS"..((out_timer)/2)+1
		if v.patchExists(pp)
			drawScreenwidePatch(v, v.cachePatch(pp))
		end
	else
		local pp = "H_TACS"..((7-timer)/2)+1
		if not v.patchExists(pp)
			pp = "H_TACS4"
		end
		drawScreenwidePatch(v, v.cachePatch(pp))
	end

	-- display tactics...
	for i = 1, #tactic_names
		if i == mo.t_tacticselect
			v.drawFill(32 + (i-1)*5, 47 + (i-1)*20 + (leveltime%16 /8), 78, 18 - (leveltime%16 /8)*2, 135|V_SNAPTOLEFT)
		end
		-- @TODO: Make this work in singleplayer sometime
		local colour = 0
		if i == 2	-- PARTY (grey it out)
			colour = 16
		elseif i == 3

			if server.P_BattleStatus[mo.battlen].boss
			or (server.P_BattleStatus[mo.battlen].storedwaves and #server.P_BattleStatus[mo.battlen].storedwaves)	-- voidrun multi-waves
				colour = 16
			end
		end

		V_drawString(v, 70 + (i-1)*5, 50 + (i-1)*20, tactic_names[i], "FPIMP" , V_SNAPTOLEFT, "center", colour, 31, FRACUNIT*2/3)
	end

	if server.P_BattleStatus[mo.battlen].hudtimer.out
		PDraw(v, -174 + out_timer*32, 173 - out_timer*4, v.cachePatch("H_BOX_D"), V_SNAPTOBOTTOM|V_SNAPTOLEFT)
		drawPlayerCommands_In(v, mo)	-- for return
	else
		PDraw(v, 50 - timer*32, 145 + timer*4, v.cachePatch("H_BOX_D"), V_SNAPTOBOTTOM|V_SNAPTOLEFT)
		drawPlayerCommands_Out(v, mo)	-- for entry
	end
	local txt = tactic_descs[mo.t_tacticselect]
	if mo.t_tacticsubmenu == 2 and mo.t_tacticsubmenu2 == 1	-- special hacky case...
		txt = thinker_descs[mo.t_subtacticselect2]
	end
	V_drawString(v, 60, 150, txt, "NFNT", V_SNAPTOLEFT|V_SNAPTOBOTTOM, nil, 0, 31)

	-- if we're in a submenu, draw it ABOVE... unless this is the party sub menu.
	if not mo.t_tacticsubmenu return end
	local t = (btl.hudtimer.tactic_out) or (TICRATE*2/3 - (btl.hudtimer.tactic_in or 0))	-- just play animations in reverse if we exit
	if mo.t_tacticsubmenu == 1	-- KOWALSKI, ANALYSIS
		-- draw a background:
		local scale = max(1, t*FRACUNIT /2)
		if scale/FRACUNIT < 2
			v.drawScaled(160<<FRACBITS, 100<<FRACBITS, scale, v.cachePatch("H_1M_B"), V_40TRANS)
		else
			v.fadeScreen(135, 6)
		end
		--v.drawScaled(160<<FRACBITS, 100<<FRACBITS, t*FRACUNIT/2, v.cachePatch("H_1M_B"), V_50TRANS)
		drawStats(v, mo.targets[mo.t_target], t, true, mo.t_skillview)
	end
end

local prevskilllist = {}	-- used to slide old skills away

-- test function
local function drawSubPersonaSelection(v, p, mo)

	local btl = server.P_BattleStatus[mo.battlen]

	-- draw command on bottom left
	local timer = server.P_BattleStatus[mo.battlen].hudtimer.to
	local out_timer = server.P_BattleStatus[mo.battlen].hudtimer.out or 7
	if server.P_BattleStatus[mo.battlen].hudtimer.out
		prevskilllist = {}
		PDraw(v, -174 + out_timer*32, 173 - out_timer*4, v.cachePatch("H_BOX_D"), V_SNAPTOBOTTOM|V_SNAPTOLEFT|TR_TRANS30)
		drawPlayerCommands_In(v, mo)	-- for return
	else
		prevskilllist = {}
		PDraw(v, 50 - timer*32, 145 + timer*4, v.cachePatch("H_BOX_D"), V_SNAPTOBOTTOM|V_SNAPTOLEFT|TR_TRANS30)
		drawPlayerCommands_Out(v, mo)	-- for entry
	end

	V_drawString(v, 60, 150, "Select a Sub-Persona", "NFNT", V_SNAPTOLEFT|V_SNAPTOBOTTOM, nil, 0, 31)

	timer = 0
	if btl.hudtimer.to
		timer = btl.hudtimer.to
	elseif btl.hudtimer.out
		timer = 7 - btl.hudtimer.out
	end

	-- draw info about the subp we selected
	local subp = btl.subpersonas[mo.t_subpselect]	-- only for the one we got selected
	local dx = 122 - timer*48

	PDraw(v, dx, 52, v.cachePatch("H_SUBP"), V_30TRANS)

	V_drawString(v, dx + 40, 52, subp.ref.name and subp.ref.name:upper() or "INVALID SUB", "FPIMP", 0, nil, 0, 31)

	-- now draw stat bonuses and disadvantages:
	local stats_subp = {"st", "ma", "en", "ag", "lu"}
	-- player's stats are in mo.savestats in that same order
	local dy = 64
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
		V_drawString(v, dx + 100, dy, "("..max(1, (mo.savestats[i] + (checkstat and checkstat or 0)))..")", "NFNT", 0, nil, 0, 31)

		dy = $ + 10
	end


	local numsubp = #btl.subpersonas
	local cardpatch = v.cachePatch("SHFLFL")

	-- rendering angle
	local slidean = (360/numsubp)/3 * (mo.t_subpslide or 0)	-- for transitions
	local drawangle = ((-360/numsubp)*(mo.t_subpselect-1) + timer*50 - slidean)*ANG1

	local cur_an = 0

	local centerx, centery = 100<<FRACBITS, 120<<FRACBITS	-- base coordinates for the menu selection
	for i = 1, numsubp

		local an = cur_an + drawangle
		-- x is squished compared to y
		local x = centerx + 32*cos(an)
		local y = centery + 80*sin(an)
		local scale = max(FRACUNIT/12, (cos(InvAngle(an)) + FRACUNIT)/5)

		v.drawScaled(x, y, scale, cardpatch)

		if i > 1	-- unequip is just a blank card, it's a waste to keep going
			local subp_c = btl.subpersonas[i].ref	-- current subpersona data
			local sprname = subp_c.sprite and sprnames[subp_c.sprite] or sprnames[SPR_SBPR]
			local sprframe = subp_c.frame and string.char((subp_c.frame & FF_FRAMEMASK) + 65) or "A"
			local patch = v.cachePatch(sprname..sprframe.."0")	-- eg: SUBPA0
			v.drawScaled(x, y, scale, patch)

			-- if equipped, have a field day and draw a player head ontop
			if btl.subpersonas[i].equipped
				local who = mo.allies_noupdate[btl.subpersonas[i].equipped]
				local ico = v.cachePatch(charStats[who.stats].icon)
				if ico
					local offx = 64*scale
					local offy = 160*scale
					v.drawScaled(x - offx, y - offy, scale*2, ico, 0, v.getColormap(TC_DEFAULT, who.color))
				end
			end
		end

		cur_an = $ + (360/numsubp)*ANG1
	end

	-- draw subpersona skills etc
	local skills = subp.skills
	if not skills or not #skills return end	-- no reason to continue

	local y = 50

	local x_slidetimer = btl.hudtimer.to or abs(mo.t_subpslide)	-- timer to slide x coord (subpslide can sometimes be negative, hence the abs)
	if btl.hudtimer.out
		x_slidetimer = 7-btl.hudtimer.out
	end

	local x = 0 - x_slidetimer*32	-- make commands slide in, woo
	local x_out = min(0, -128 + 32*x_slidetimer)

	-- copy skill list;
	-- this is used to slide the old skills out when cycling through subp!
	if (not prevskilllist or not #prevskilllist) and not x_slidetimer	-- only do it when the timer's out tho
		prevskilllist = copyTable(skills)
	else
		-- slide these skills out!
		for i = 1, #prevskilllist do
			local skl = attackDefs[prevskilllist[i]]
			drawSkillCommand(v, x_out, y+4, mo, skl, false)
			y = $ + 25
		end
	end

	y = 50	-- reset this

	for i = 1, #skills do
		local skl
		if skills[i] and attackDefs[skills[i]]
			skl = attackDefs[skills[i]]

			drawSkillCommand(v, x, y, mo, skl, true)
			y = $ + 25
		end
	end

	--"drawSkillCommand", function(v, x, y, mo, skill, active, have_item, skillcard, equip)
end

-- subpersona switch
local function drawsubPswitch(v, p, mo)
	local btl = server.P_BattleStatus[mo.battlen]
	if not btl.hudtimer.equipsubp return end

	local t = 14-btl.hudtimer.equipsubp
	local p = "H_SUBT"..t/2
	if v.patchExists(p)
		drawScreenwidePatch(v, v.cachePatch(p))
	end
end

local function drawPlayerTurn(v, p, c, mo)
	if p.P_party ~= mo.party return end

	local cmd = {}
	local btl = server.P_BattleStatus[mo.battlen]

	if mo.t_act == ACT_NONE
		drawPlayerCommands(v, mo)
		drawPartyStatus(v, p, server.P_BattleStatus[mo.battlen])	-- small hack
		cmd = 	{
					{BUTT_DPAD, "Target/Command"},
					{BUTT_A, "Confirm"},
					{BUTT_L, "Analysis"},
				}
		if mo.commandflags and mo.commandflags & (CDENY_TACTICS|CDISABLE_TACTICS)
			cmd[3] = nil	-- remove the "Analysis" button
		end

		if btl and btl.emeraldpow_max and btl.emeraldpow >= 100	-- show hyper mode
			cmd = 	{
						{BUTT_DPAD, "Target/Command"},
						{BUTT_A, "Confirm"},
						{BUTT_C, BTL_canSuper(btl, mo) and "Super Form" or "Hyper Mode"},
						{BUTT_L, "Analysis"},
					}
			if mo.commandflags and mo.commandflags & (CDENY_TACTICS|CDISABLE_TACTICS)
				cmd[4] = nil	-- remove the "Analysis" button
			end
		end

		drawPlayerTarget(v, p, c, mo)

	elseif mo.t_act == ACT_BATONTOUCH
		cmd = 	{
					{BUTT_DPAD, "Target"},
					{BUTT_A, "Baton Pass"},
					{BUTT_B, "Back Out"},
				}
		drawPlayerTarget(v, p, c, mo)

	elseif mo.t_act == ACT_SKILL
		drawPlayerTarget(v, p, c, mo)
		drawPlayerSkillList(v, p, mo)

		if btl.subpersonas and #btl.subpersonas > 1

			cmd = 	{
						{BUTT_DPAD, "Target/Skill"},
						{BUTT_A, "Confirm"},
						{BUTT_B, "Back"},
						{BUTT_L|BUTT_R, "Sub Personas"},
					}
		else

			cmd = 	{
						{BUTT_DPAD, "Target/Skill"},
						{BUTT_A, "Confirm"},
						{BUTT_B, "Back"},
					}
		end

		--drawPartyStatus(v, p, server.P_BattleStatus[mo.battlen])	-- small hack
	elseif mo.t_act == ACT_ITEM
		drawPlayerTarget(v, p, c, mo)
		drawPlayerItemList(v, p, mo)
		cmd = 	{
					{BUTT_DPAD, "Target/Item"},
					{BUTT_A, "Confirm"},
					{BUTT_B, "Back"},
				}
		--drawPartyStatus(v, p, server.P_BattleStatus[mo.battlen])	-- small hack
	elseif mo.t_act == ACT_SUBPERSONAS
		drawPlayerTarget(v, p, c, mo)
		drawSubPersonaSelection(v, p, mo)
		drawPartyStatus(v, p, server.P_BattleStatus[mo.battlen])	-- small hack
		cmd = 	{
					{BUTT_DPAD, "Select"},
					{BUTT_A, "Equip"},
					{BUTT_B, "Back"},
				}
	elseif mo.t_act == ACT_DEFEND
		drawGuardPrompt(v, p, mo)
		drawPartyStatus(v, p, server.P_BattleStatus[mo.battlen])	-- small hack
		cmd = 	{
					{BUTT_A, "Defend"},
					{BUTT_B, "Back"},
				}
		drawPlayerTarget(v, p, c, mo)
	elseif mo.t_act == ACT_TACTICS
		drawPlayerTarget(v, p, c, mo)
		drawPartyStatus(v, p, server.P_BattleStatus[mo.battlen])	-- small hack
		drawTactics(v, p, mo)
		cmd = 	{
					{BUTT_DPAD, "Select"},
					{BUTT_A, "Confirm"},
					{BUTT_B, "Back"},
				}
	end

	-- draw the timer:
	if netgame
	and mo.t_acttimer
		V_drawString(v, 4, 177, "\x82".."TIME", "FPIMP", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 0, 31)
		V_drawString(v, 8, 187, (mo.t_acttimer/TICRATE +1), "FPNUM", V_SNAPTOLEFT|V_SNAPTOBOTTOM, nil, (mo.t_acttimer < TICRATE*10 and leveltime%10 < 5) and 35 or 0, 31)
	end

	if not mo.t_endtactics
		V_drawCommands(v, cmd)
	end

	drawsubPswitch(v, p, mo)
end



local function drawDamagedEnemies(v, p, c, mo)
	if not mo or not mo.valid return end	-- no!
	local btl = server.P_BattleStatus[mo.battlen]

	if not #btl.turnorder return end
	local basemo = mo

	-- use pairs in case we get holes in our table
	for k,e in pairs(btl.fighters)

		if not e.valid continue end

		if not basemo.plyr
			mo = e	-- saddening.
		end
		local x,y = R_GetScreenCoords(v, p, c, e.x, e.y, e.z + e.target_zoffs*e.scale)
		if e.damaged	-- enemy is being damaged and is losing HP

			if e.damagestate == DMG_STATUS continue end

			local atk = e.atk_hitby or e.attack
			local repel = e.damagestate == DMG_REPEL
			local isweak = e.damagestate == DMG_WEAK
			local blocked = e.damagestate == DMG_BLOCK
			local missed = e.damagestate == DMG_MISS
			local drained = e.damagestate == DMG_DRAIN
			local technical = e.damagestate == DMG_TECHNICAL
			local resists = e.damagestate == DMG_RESIST

			local bx, by = x + (e.damaged < 8 and N_RandomRange(-3, 3)<<FRACBITS or 0), y + (e.damaged < 8 and N_RandomRange(-3, 3)<<FRACBITS or 0)

			if repel	-- we repelled the attack

				local scale = (e.damaged-5)*FRACUNIT/3
				if scale > 0
					v.drawScaled(bx, by - (20<<FRACBITS), scale, v.cachePatch("H_1M_C"))
					PDraw(v, bx>>FRACBITS, by >> FRACBITS - 20, v.cachePatch("D_REPEL"))
				end
				continue
			elseif blocked	-- attack was blocked

				local patches = {"H_MIS1", "H_BLOCK"}

				for i = 1, 2
					local t2 = e.damaged - (i-1)*9
					local scale = (FRACUNIT*3 - t2*FRACUNIT/2)

					if t2 > 0
						v.drawScaled(x, y, max(scale, FRACUNIT*2/3), v.cachePatch(patches[i]))
					end
				end
				continue	-- don't draw the rest, we'll spawn errors otherwise... shh

			elseif missed	-- woopsie doopsie we missed
				v.drawScaled(x, y, min(e.damaged*FRACUNIT/8, FRACUNIT*2/3), v.cachePatch("H_MIS1"))
				local t2 = e.damaged - 4
				if t2 > 0
					v.drawScaled(x, y, min(t2*FRACUNIT/8, FRACUNIT*2/3), v.cachePatch("H_MIS2"))
				end
				continue	-- don't draw the rest, we'll spawn errors otherwise... shh
			end

			local bg = "D_BG1"
			if e.damaged > 3
				bg = "D_BG"..( ( ((e.damaged-3)%6)/3) + 2)
			end

			if e.crituptheass
				PDraw(v, bx>>FRACBITS - 38, by>>FRACBITS - 54, v.cachePatch(bg))
			end

			-- critical hit / weakness:
			if drained

				local scale = max(1, FRACUNIT*4 - (e.damaged)*FRACUNIT/4)
				v.drawScaled(bx, by - (50<<FRACBITS), scale, v.cachePatch("H_1M_C"))
				PDraw(v, bx>>FRACBITS, by >> FRACBITS - 50, v.cachePatch("D_DRAIN"))

			elseif isweak or e.damagestate == DMG_CRITICAL
				PDraw(v, bx>>FRACBITS +2, by >> FRACBITS - 50, v.cachePatch(isweak and "D_WEAK" or "D_CRIT"))

			elseif technical
				PDraw(v, bx>>FRACBITS +2, by >> FRACBITS - 50, v.cachePatch("D_TECH"))

			elseif resists

				local shiftx = 0
				if e.damaged < 16
					shiftx = (leveltime%5 < 3 and -2 or 2)
				end
				PDraw(v, bx>>FRACBITS +shiftx, by >> FRACBITS - 50, v.cachePatch("D_REST"))
			end

			if e.hu_deadanim
				local pp = "H_THPB"..max(1, (e.hu_deadanim/2))
				if v.patchExists(pp)
				and not (atk and atk.instakill)
					PDraw(v, bx>>FRACBITS, by>>FRACBITS - 8, v.cachePatch(pp))
				end
				continue
			end

			-- the attack was an instant kill.
			-- don't draw the damage (9999)
			-- unless we're in pvp as the damage will always be half the remaining HP
			if atk and atk.instakill
			and server.gamemode ~= GM_PVP
				continue
			end

			local color1 = 131
			local color2 = 137
			local prefix = "H_THP"
			local cur = e.hp or 0
			local maxb = e.maxhp or 0
			local red = e.redhp or 0
			local damage1 = e.damagetaken
			local forcecolor
			if e.damageflags == DF_SP	-- do NOT do this if we're also taking HP damage.
				color1 = 181
				color2 = 185
				prefix = "H_TSP"
				cur = e.sp
				maxb = e.maxsp or 1
				red = e.redsp or e.sp
				forcecolor = 181
				damage1 = e.spdamagetaken
			end

			-- draw the entity's HP bar
			-- draw bar
			for i = 0, 21	-- drawn twice since redhp also exists
				v.drawFill(bx>>FRACBITS-3+i, by>>FRACBITS-25 - i/3, 1, 6, i >= (red*20/maxb) and color2 or 35)
			end
			for i = 0, 21
				if i >= (cur*20/maxb) continue end
				v.drawFill(bx>>FRACBITS-3+i, by>>FRACBITS-25 - i/3, 1, 6, color1)
			end

			PDraw(v, bx>>FRACBITS, by>>FRACBITS - 8, v.cachePatch(prefix..1+(leveltime%20/10)))

			if not (e.damagestate == DMG_DRAIN and not e.damagetaken)
			-- don't draw damage if we healed nothing from a drain
				R_DisplayDamage(v, x, y, e, damage1, forcecolor, nil, e.crituptheass)	-- shake damage numbers on knockdown!
			end

			if e.damageflags ~= DF_SP and e.damageflags & DF_SP	-- HP and SP, display SP damage above
				R_DisplayDamage(v, x, y-(20<<FRACBITS), e, e.spdamagetaken, 181)
			end

			if e.downanim and e.downanim > 2
			and atk
				local patch = "KDOWN"..((10 - e.downanim)/2)+1
				drawScreenwidePatch(v, v.cachePatch(patch), v.getColormap(TC_DEFAULT, skill_color[atk.type] or SKINCOLOR_ORANGE))
			end
		/*elseif e.down and btl.battlestate == BS_DOTURN	-- while the enemy isn't damaged, draw an indicator saying that they've been knocked down if they are

			-- draw an arrow:
			local sx, sy = x>>FRACBITS, y>>FRACBITS
			local basey = (sy+5) + (((leveltime%8) < 4) and 1 or 0)

			-- yes it's a dumb way to draw an arrow:
			for i = 0, 5 do
				v.drawFill(sx-2 +i, basey+5-i, 11 - (i*2), 1, 135)
			end
			V_drawString(v, sx+2, sy+15, "DOWN", "NFNT", 0, "center", 135, nil)*/
		end
	end
end

local function drawOneMore(v, p, c, mo)
	local t = (TICRATE - (mo.onemore*2))
	local t2 = (t<<FRACBITS) /3
	local t3 = t2

	-- circles, or something!
	local scale = t*FRACUNIT/6
	local trflag = V_70TRANS
	if mo.onemore < 15
		trflag = V_90TRANS - (V_10TRANS*(mo.onemore/5))
	end
	if scale > 0	-- lol negative scales
		local pp = "H_1M_B"
		if mo.enemy
			pp = "H_1M_E"
		end
		v.drawScaled(160<<FRACBITS, 100<<FRACBITS, scale, v.cachePatch(pp), trflag)
		v.drawScaled(160<<FRACBITS, 100<<FRACBITS, scale, v.cachePatch("H_1M_C"))
	end

	/*if mo.onemore == TICRATE-1
		S_StartSound(nil, sfx_1more, p)
	end*/

	t3 = FixedMul(t3, t3)
	t3 = $+ FixedMul(t3, t2)

	v.drawIndex((133)<<FRACBITS +t3/3, (83)<<FRACBITS +t3/8, FRACUNIT/2, v.cachePatch("H_1M_1"), 0, 31)
	v.drawIndex((130)<<FRACBITS +t3/3, (80)<<FRACBITS +t3/8, FRACUNIT/2, v.cachePatch("H_1M_1"), 0, 0)
	v.drawIndex((123)<<FRACBITS -t3/3, (93)<<FRACBITS -t3/7, FRACUNIT/2, v.cachePatch("H_1M_2"), 0, 31)
	v.drawIndex((120)<<FRACBITS -t3/3, (90)<<FRACBITS -t3/7, FRACUNIT/2, v.cachePatch("H_1M_2"), 0, 0)
end

local cons_cache	-- used so that we don't need to cache something new everytime
					-- it must be cleared if btl.console_time == TICRATE*2	(new message)

local function drawBattleLog(v, mo)

	if not mo or not mo.valid return end
	-- this can be drawn very early on, but there's no turnorder as of yet when that happens

	local y = server.gamemode == GM_VOIDRUN and 40 or 20

	local btl = server.P_BattleStatus[mo.battlen]
	if btl.console_time and btl.console
		local transflag = 0
		local transflag2 = 0

		/*if btl.console_time == TICRATE*2
			cons_cache = nil	-- cache new msg
			--print("Cleared cache...")
		end*/

		if btl.console_time < 10
			transflag = V_90TRANS - (V_10TRANS*btl.console_time)
			if btl.console_time < 7
				transflag2 = V_90TRANS - (V_10TRANS*btl.console_time)
			end
		end

		local pp = "CONS"
		if btl.console_time > TICRATE*2 - 2
			pp = "CONSL"
		end
		PDraw(v, 160, y, v.cachePatch("H_BOX_L"), V_SNAPTOTOP|(transflag2 or TR_TRANS30))
		--if not cons_cache
		local length = 160
		cons_cache = STR_WordWrap(v, btl.console, length, "NFNT")
			--print("Built cache ("..#cons_cache..")")
		--end

		local ypos = (y-4) - (#cons_cache-1)*5

		for i = 1, #cons_cache
			--print("\'"..cons_cache[i].."\'")
			V_drawString(v, 160, ypos, cons_cache[i], "NFNT", V_SNAPTOTOP|transflag, "center", 0, 31)
			ypos = $+10
		end
	end
end


-- used for hold up and short negociation.
-- all out attack is handled elsewhere.
local function drawHoldUp(v, p, c, mo)

	local btl = server.P_BattleStatus[mo.battlen]
	local mo = btl.turnorder[1]

	-- hud "ALL DOWN" at the start of the effect:
	local t = (TICRATE - ((btl.hudtimer.holdupstart-TICRATE)*2))
	local t2 = (t<<FRACBITS) /3
	local t3 = t2
	t3 = FixedMul(t3, t3)
	t3 = $+ FixedMul(t3, t2)

	v.drawIndex((83)<<FRACBITS +t3/3, (83)<<FRACBITS +t3/8, FRACUNIT/2, v.cachePatch("H_HOLD1"), 0, 31)
	v.drawIndex((80)<<FRACBITS +t3/3, (80)<<FRACBITS +t3/8, FRACUNIT/2, v.cachePatch("H_HOLD1"), 0, 0)
	v.drawIndex((133)<<FRACBITS -t3/3, (93)<<FRACBITS -t3/7, FRACUNIT/2, v.cachePatch("H_HOLD2"), 0, 31)
	v.drawIndex((130)<<FRACBITS -t3/3, (90)<<FRACBITS -t3/7, FRACUNIT/2, v.cachePatch("H_HOLD2"), 0, 0)

	-- second half, draw the prompts
	if btl.hudtimer.holdupstart > TICRATE return end

	local t = TICRATE - btl.hudtimer.holdupstart
	local t2 = max(0, TICRATE-(t+20))
	if btl.hudtimer.aoarelent
		t = 35-(btl.hudtimer.aoarelent*5)
		t2 = 64 - btl.hudtimer.aoarelent*8
	end

	-- draw prompter portrait...

	local patch = "H_AOA"..min(3, (t/2)+1)
	if v.patchExists(patch)
		drawScreenwidePatch(v, v.cachePatch(patch))
	end

	local pp = v.cachePatch(charStats[mo.stats].hudaoa)
	if mo.status_condition == COND_SUPER
	and charStats[mo.stats].hudsaoa
		pp = v.cachePatch(charStats[mo.stats].hudsaoa)
	end

	v.drawScaled((-25 - t2*32)<<FRACBITS, (20)<<FRACBITS, FRACUNIT*2/3, pp, V_SNAPTOLEFT|V_SNAPTOBOTTOM, v.getColormap(TC_DEFAULT, mo.color))	-- draw @ full scale

	-- draw "AOA or RELENT" prompt

	local gfx = (btl.holdupfinish or SAVE_localtable.tutorial) and "2" or ""

	PDraw(v, 190 - t2*32, 50, v.cachePatch("H_AOABT"..gfx))
	v.drawIndex((190 -t2*32 +2)<<FRACBITS, 52<<FRACBITS, FRACUNIT/2, v.cachePatch("H_AOAT"..gfx), 0, 31)
	PDraw(v,  190- t2*32, 50, v.cachePatch("H_AOAT"..gfx))

	-- slide text box in your DMs:
	pp = v.cachePatch("H_AOATX")
	PDraw(v, min(0, -250 + t*32), 200, pp, V_SNAPTOLEFT|V_SNAPTOBOTTOM)
	-- get text:
	local txt = charStats[mo.stats] and charStats[mo.stats].aoa_quote or "Here's our chance!"
	V_drawString(v, 10, 158, txt, "NFNT", V_SNAPTOLEFT|V_SNAPTOBOTTOM, nil, 0, 31, FRACUNIT*2/3)
end

-- transition from field to btl
local function drawBattleStart(v, btl)
	if btl.hudtimer.start else return end
	local t = (btl.advantage and TICRATE*3 or TICRATE) - btl.hudtimer.start +2

	if t <= 8
		drawScreenwidePatch(v, v.cachePatch("H_RIP"..t/2))

		if server.gamemode == GM_PVP
		or server.gamemode == GM_CHALLENGE
			v.drawFill()
		end

	elseif t <= 40
		local flag = t > 25 and V_10TRANS*(t-25) or 0
		drawScreenwidePatch(v, v.cachePatch("H_RIP4"), nil, flag)
	end

	-- draw advantages and the likes:
	if btl.advantage
		local prefixes = {"H_PADV", "H_EADV"}
		local circles = {"H_1M_B", "H_EA_R"}
		local prefix = prefixes[btl.advantage]

		if not prefix return end

		if t > 20
			local newt = max(1, (t-20)/2)
			if v.patchExists(prefix..newt)

				-- special case for boss:
				if newt == 11 and btl.boss
					drawScreenwidePatch(v, v.cachePatch("H_EADVB"))
					return
				end

				drawScreenwidePatch(v, v.cachePatch(prefix..newt))
			elseif newt < 11
				v.drawFill(0, 0, 600, 600, 31|V_SNAPTOTOP|V_SNAPTOLEFT)
			else
				local newt2 = (t - 60)

				local tflag = (newt2-20)/2
				if newt2-20 <= 0
					tflag = 0
				end

				local scale = FRACUNIT*12 - ((newt2+20)*FRACUNIT/3)

				if scale > 0
					v.drawScaled(160<<FRACBITS, 100<<FRACBITS, scale, v.cachePatch(circles[btl.advantage]))
				end
				if (newt2 - 20)/2 <= 9
				and tflag >= 0 and tflag <= 9
					if btl.boss
						drawScreenwidePatch(v, v.cachePatch("H_EADVBT"), nil, tflag<<V_ALPHASHIFT)
					else
						drawScreenwidePatch(v, v.cachePatch(prefix.."T"), nil, tflag<<V_ALPHASHIFT)
					end
				end
			end
		end
	end
end

local loc_trns = 0

-- battle end: exp + lvup + newskill
local function drawBattleEnd(v, btl)
	local t = btl.hudtimer.endb or 0
	local it = TICRATE*3/2 - btl.hudtimer.endb	-- invert t
	-- transition from battle to EXP screen:

	if it >= TICRATE*3/2
		loc_trns = $+1
		local tflag = min(3, (loc_trns/3)+1)	--<<V_ALPHASHIFT
		v.fadeScreen(31, 10-tflag)
		--drawScreenwidePatch(v, v.cachePatch("H_RIP4"), nil, tflag)
	elseif it > 7
		v.drawFill()
		loc_trns = 0
	end

	if it and it <= 11
		drawScreenwidePatch(v, v.cachePatch("H_END"..it/2 + 1))
	end

	if it <= 15 return end
	local postt = it - 15

	-- exp
	v.drawFill(0, 20, postt*64, 14, 135|V_SNAPTOLEFT|V_SNAPTOTOP)
	V_drawString(v, min(postt*64, 178), 21, "EXP", "FPIMP", V_SNAPTOLEFT|V_SNAPTOTOP, nil, 31, 137)
	V_drawString(v, min(postt*64, 225), 21, tostring(btl.r_baseexp), "FPNUM", V_SNAPTOLEFT|V_SNAPTOTOP, nil, 31, 137)
	PDraw(v, min(postt*64, 168), 21, v.cachePatch("H_R_EXP"), V_SNAPTOLEFT|V_SNAPTOTOP)

	if btl.r_expmultiplier
		-- display arrow and multiplier:
		v.drawIndex((min(postt*64, 216)+2)*FRACUNIT, ((21 + (leveltime%10 < 5 and 1 or 0))+2)*FRACUNIT, FRACUNIT/2, v.cachePatch("FPARROW"), V_SNAPTOLEFT|V_SNAPTOTOP, 137)
		v.drawIndex(min(postt*64, 216)*FRACUNIT, (21 + (leveltime%10 < 5 and 1 or 0))*FRACUNIT, FRACUNIT/2, v.cachePatch("FPARROW"), V_SNAPTOLEFT|V_SNAPTOTOP, 31)
		V_drawString(v, min(postt*64, 265), 21, "+"..tostring(btl.r_expmultiplier).."%", "FPNUM", V_SNAPTOLEFT|V_SNAPTOTOP, nil, 31, 137)
	end

	-- macca:
	v.drawFill(0, 45, postt*64, 14, 135|V_SNAPTOLEFT|V_SNAPTOTOP)
	V_drawString(v, min(postt*64, 149), 46, "MACCA", "FPIMP", V_SNAPTOLEFT|V_SNAPTOTOP, nil, 31, 137)
	V_drawString(v, min(postt*64, 210), 46, tostring(btl.r_basemoney), "FPNUM", V_SNAPTOLEFT|V_SNAPTOTOP, nil, 31, 137)
	PDraw(v, min(postt*64, 139), 46, v.cachePatch("H_R_RING"), V_SNAPTOLEFT|V_SNAPTOTOP)

	if btl.r_moneymultiplier
		-- display arrow and multiplier:
		v.drawIndex((min(postt*64, 199)+2)*FRACUNIT, ((46 + (leveltime%10 < 5 and 1 or 0))+2)*FRACUNIT, FRACUNIT/2, v.cachePatch("FPARROW"), V_SNAPTOLEFT|V_SNAPTOTOP, 138)
		v.drawIndex(min(postt*64, 199)*FRACUNIT, (46 + (leveltime%10 < 5 and 1 or 0))*FRACUNIT, FRACUNIT/2, v.cachePatch("FPARROW"), V_SNAPTOLEFT|V_SNAPTOTOP, 31)
		V_drawString(v, min(postt*64, 245), 46, "+"..tostring(btl.r_moneymultiplier).."%", "FPNUM", V_SNAPTOLEFT|V_SNAPTOTOP, nil, 31, 137)
	end

	-- items:
	for i = 1, 14
		local maxlen = postt*64
		if i > 1
			maxlen = 236 - i
		end

		v.drawFill(0, 70+(i-1), maxlen, 1, 135|V_SNAPTOLEFT|V_SNAPTOTOP)
	end

	V_drawString(v, min(postt*64, 124), 71, "ITEMS", "FPIMP", V_SNAPTOLEFT|V_SNAPTOTOP, nil, 31, 137)
	local ix = min(postt*58, 238)
	local iy = 74

	if btl.r_item or btl.r_weapons or btl.r_rings

		if btl.r_item
			for i = 1, #btl.r_item
				local itemname = btl.r_item[i][1]
				local col = ""

				if itemDefs[itemname]
					if itemDefs[itemname].rarity and itemDefs[itemname].rarity >= 5
						col = "\x82"
					end
					itemname = buildItemName(itemDefs[itemname])
				end

				V_drawString(v, ix, iy, col..itemname.." x"..btl.r_item[i][2], "NFNT", V_SNAPTORIGHT|V_SNAPTOTOP, nil, 0, 31)
				ix = $-5
				iy = $+10
			end
		end

		if btl.r_weapons
			for i = 1, #btl.r_weapons
				local itemname = buildWeaponName(btl.r_weapons[i])
				local col = ""
				if btl.r_weapons[i].rarity >= 5
					col = "\x82"
				end

				V_drawString(v, ix, iy, col..itemname, "NFNT", V_SNAPTORIGHT|V_SNAPTOTOP, nil, 0, 31)
				ix = $-5
				iy = $+10
			end
		end

		if btl.r_rings
			for i = 1, #btl.r_rings
				local itemname = buildRingName(btl.r_rings[i])
				local col = ""
				if btl.r_rings[i].rarity >= 5
					col = "\x82"
				end

				V_drawString(v, ix, iy, col..itemname, "NFNT", V_SNAPTORIGHT|V_SNAPTOTOP, nil, 0, 31)
				ix = $-5
				iy = $+10
			end
		end

	else
		V_drawString(v, ix, iy, "None", "NFNT", V_SNAPTOLEFT|V_SNAPTOTOP, nil, 0, 31)
	end


	PDraw(v, min(postt*64, 114), 71, v.cachePatch("H_R_ITEM"), V_SNAPTOLEFT|V_SNAPTOTOP)

	-- party member EXP
	local party = server.plentities[btl.n]
	for i = 0, #party-1

		local mo = party[i+1]

		-- draw PM portraits:
		if charStats[mo.stats] and charStats[mo.stats].hudbust
			local p = v.cachePatch(charStats[mo.stats].hudbust)

			local x = min(62 - i*20, -256 + ((postt-4)*32))
			local y = 92 + 20*i
			local color = mo.color

			v.drawScaled((x)<<FRACBITS, (y)<<FRACBITS, FRACUNIT/4, p, V_SNAPTOTOP, v.getColormap(TC_DEFAULT, color))
		end

		-- draw EXP gauge:
		v.drawFill(min(113 - i*20, -256 + ((postt-4)*32)), 102 + 20*i, 79, 5, (mo.level == mo.levelcap and 54 or 31)|V_SNAPTOTOP)

		if mo.level < btl.r_precalculates[i+1][2]
			v.drawFill(min(113 - i*20, -256 + ((postt-4)*32)), 102 + 20*i, 79, 5, 62|V_SNAPTOTOP)
		else
			v.drawFill(min(113 - i*20, -256 + ((postt-4)*32)), 102 + 20*i, btl.r_precalculates[i+1][1]*79/needEXP[mo.level], 5, 62|V_SNAPTOTOP)
		end

		v.drawFill(min(113 - i*20, -256 + ((postt-4)*32)), 102 + 20*i, mo.exp*79/needEXP[mo.level], 5, 54|V_SNAPTOTOP)

		PDraw(v, min(62 - i*20, -256 + ((postt-4)*32)), 100 + 20*i, v.cachePatch("H_EXP"), V_SNAPTOTOP)

		-- draw level:
		V_drawString(v, min(95 -i*20, -100 + (postt-4)*32), 100 + 20*i, party[i+1].level, "FPNUM", V_SNAPTOTOP, nil, 31, nil)

		-- draw exp #:
		V_drawString(v, min(148 -i*20, -100 + (postt-4)*32), 107 + 20*i, mo.level >= mo.levelcap and "" or tostring(party[i+1].exp), "NFNT", V_SNAPTOTOP|V_MONOSPACE, "right", 0, nil)	-- curr exp
		V_drawString(v, min(165 -i*20, -100 + (postt-4)*32), 107 + 20*i, mo.level < mo.levelcap and needEXP[party[i+1].level] or "MAX", "NFNT", V_SNAPTOTOP|V_MONOSPACE, nil, 0, nil)

		-- draw the shuffle time card collected if possible
		if mo.shuffletypes
			local ctype = mo.shuffletypes[mo.shuffle_choice]
			local frame = "SHFL"..string.char(65+(ctype & 1023)).."L"
			-- 65 = A, ctype 1 is frame B

			local x = min(205 - i*20, -64 + ((postt-4)*32))<<FRACBITS
			v.drawScaled(x, (112 + 20*i)<<FRACBITS, FRACUNIT/10, v.cachePatch(frame), V_SNAPTOTOP)
		end
	end

	-- RESULT
	PDraw(v, min(-320 + postt*64, 0), 0, v.cachePatch("H_RSLT"), V_SNAPTOTOP|V_SNAPTOLEFT)

	if btl.hudtimer.levelup	--transition from EXP screen to level up status...
		loc_trns = 0
		local tt = TICRATE/2 - btl.hudtimer.levelup
		if tt <= 7
			drawScreenwidePatch(v, v.cachePatch("H_RIP"..tt/2 +1))
		else
			v.drawFill()
		end
	end
end

-- draws a "TAKE YOUR TIME" loading screen with a "msg" reason
-- is net is true, this will draw a "communicating..." message as well.
rawset(_G, "drawWaitScreen", function(v, net, msg)
	v.drawFill()
	if net
		local dot = string.rep(".", (leveltime%39)/10)
		V_drawString(v, 24, 24, "COMMUNICATING "..dot, "NFNT", V_SNAPTOTOP|V_SNAPTOLEFT, nil, 0, nil)
	end
	if msg
		V_drawString(v, 24, 48, msg, "NFNT", V_SNAPTOTOP|V_SNAPTOLEFT, nil, 0, nil)
	end
end)

local LEVELWAITSTRING = "Waiting for remaining \nplayers to finish \nleveling up."
local ERRORWAITSTRING = "Non fatal error has occured. \nYou may be required to mash A \nuntil things magically sort out?"

rawset(_G, "drawLevelUp", function(v, p, battle)

	local pnum
	for i = 1, server.P_netstat.teamlen
		if server.playerlist[p.P_party][i] == p
			pnum = i
			break
		end
	end

	if not pnum return end	-- ??/!?

	if not battle.r_levelupqueue[pnum]
		-- Should realistically only happen in Marathon mode if you load in with holes in the party. This is only a visual bug.

		-- Search for the player with our own 'control' on it
		for i = 1, server.P_netstat.teamlen
			if #battle.r_levelupqueue[i]
			and battle.r_levelupqueue[i][1].control == p
				pnum = i
				break
			end
		end

		-- if despite that we didn't find it...
		if not battle.r_levelupqueue[pnum]
			drawWaitScreen(v, 1, ERRORWAITSCREEN)
			return	-- uh this shouldn't happen
		end
	end

	local mo = battle.r_levelupqueue[pnum][1]

	if not mo
		drawWaitScreen(v, 1, LEVELWAITSTRING)
		return
	end

	local mynum
	for i = 1, #server.plentities[mo.battlen]
		if server.plentities[mo.battlen][i] == mo then mynum = i end
	end

	local timer = TICRATE*2/3 - mo.r_levelupenter

	if timer >= TICRATE*2/3
		loc_trns = $+1
		local tflag = min(3, (loc_trns/3)+1)	--<<V_ALPHASHIFT
		v.fadeScreen(31, 10-tflag)
		--drawScreenwidePatch(v, v.cachePatch("H_RIP4"), nil, tflag)
	else
		v.drawFill()
		loc_trns = 0
	end

	if battle.r_precalculates[mynum][3]	-- I have leveled up, please show me my skills!
	and mo and mo.valid
		local t = timer

		R_drawAngledLine(v, 0, 36, ANG1*3, min(400, (timer-2)*32), 135|V_SNAPTOTOP|V_SNAPTOLEFT, 32)
		R_drawAngledLine(v, 30, 0, ANG1*273, min(300, (timer-2)*32), 135|V_SNAPTOTOP|V_SNAPTOLEFT, 64)

		--V_drawString(v, 24, 48, "LEVEL UP", "FPIMP", V_SNAPTOTOP|V_SNAPTOLEFT, nil, 31, nil)
		-- draw Persona name
		V_drawString(v, min(100, t*64), 8, "LEVEL UP", "FPIMP", V_SNAPTOTOP|V_SNAPTOLEFT, nil, 0, 31)

		local str = (mo.persona.name):upper().." LV"..mo.level
		local strw = V_stringWidth(v, str, "FPIMP")/FRACUNIT +2

		V_drawString(v, min(100, t*64), 20, str, "FPIMP", V_SNAPTOTOP|V_SNAPTOLEFT, nil, 0, 31)
		--V_drawString(v, min(100, t*64) +strw, 21, mo.level, "FPNUM", V_SNAPTOLEFT, nil, 0, 31)

		-- draw affinities:
		local aff_x = 98
		for i = 0, 10
			PDraw(v, min(aff_x, timer*24), 36 - i, v.cachePatch("ATK_"..atk_constant_2_num[2^i]), V_SNAPTOLEFT|V_SNAPTOTOP)
			PDraw(v, min(aff_x, timer*24), 36 - i, v.cachePatch("H_ELMF2"), V_SNAPTOLEFT|V_SNAPTOTOP)
			local aff = "/"
			if mo.weak & 2^i
				aff = "\x82".."WK"
			elseif mo.block & 2^i
				aff = "\x86".."NUL"
			elseif mo.resist & 2^i
				aff = "\x86".."STR"
			elseif mo.drain & 2^i
				aff = "\x85".."DRN"
			elseif mo.repel & 2^i
				aff = "\x85".."RPL"
			end
			V_drawString(v, min(aff_x + 8, timer*24), 54 - i, aff, "NFNT", V_SNAPTOTOP|V_SNAPTOLEFT, "center", 31, nil)
			aff_x = $+20
		end

		-- draw the stats above the sprite if it's gigantic
		local stats = {mo.strength, mo.magic, mo.endurance, mo.agility, mo.luck}
		local statnames = {"STR", "MAG", "END", "AGI", "LUK"}
		for i = 1, #stats do

			V_drawString(v, min(48 + i, -20 + timer*24), 70 + (i-1)*16, statnames[i], "FPIMP", V_SNAPTOLEFT, nil, 31, nil)
			V_drawString(v, min(90 + i, -20 + timer*24), 70 + (i-1)*16, mo.savestats[i], "FPNUM", V_SNAPTOLEFT, "right", 31, nil)

			-- draw the bar
			-- bg:
			R_drawAngledLine(v, 96 +i, 75 + (i-1)*16, ANG1*3, min(stats[i]*12/10 + 2, (timer-2)*16), 135|V_SNAPTOLEFT, 6)
			-- stat
			R_drawAngledLine(v, 96 +i, 75 + (i-1)*16, ANG1*3, min(stats[i]*12/10, (timer-2)*16), (leveltime%10 < 5 and 64 or 66)|V_SNAPTOLEFT, 3)
			-- stat
			R_drawAngledLine(v, 96 +i, 75 + (i-1)*16, ANG1*3, min(mo.savestats[i]*12/10, (timer-2)*16), 137|V_SNAPTOLEFT, 3)
		end

		-- draw skills
		local x, y = 110, 148
		for i = 1, 8 do
			v.drawFill(min(t*32 - 8*(i-1), x), y, 64, 10, (not ((i == mo.newskillnum or i == mo.r_forgetselect) and leveltime%4 < 2) and 135 or 0)|V_SNAPTOBOTTOM|V_SNAPTOLEFT)
			local skname = (mo.skills[i] or "/")
			local atype = 0
			local sk

			if attackDefs[skname]
				sk = attackDefs[skname]
				if sk.type & ATK_PASSIVE
					atype = 15
				else
					atype = atk_constant_2_num[attackDefs[skname].type]
				end
				skname = attackDefs[skname].name
			end

			-- we have to forget a skill? Draw the properties of this skill here.
			if i == mo.r_forgetselect
			and sk
			and not mo.r_askconfirm

				v.drawFill(160, 70, 160, 30, 135|V_SNAPTORIGHT)
				local str = sk.name
				local str2 = sk.desc

				V_drawString(v, 161, 65, str, "NFNT", V_SNAPTORIGHT, nil, 0, 31)
				V_drawString(v, 161, 75, str2, "NFNT", V_SNAPTORIGHT, nil, 0, 31)
			end

			if atype
				v.drawScaled(min(t*32, x)*FRACUNIT, (y+1)*FRACUNIT, FRACUNIT/4, v.cachePatch("ATK_"..atype), V_SNAPTOBOTTOM|V_SNAPTOLEFT)
				v.drawIndex(min(t*32, x)*FRACUNIT, (y+1)*FRACUNIT, FRACUNIT/4, v.cachePatch("H_ELMF3"), V_SNAPTOBOTTOM|V_SNAPTOLEFT, (not ((i == mo.newskillnum or i == mo.r_forgetselect) and leveltime%4 < 2) and 135 or 0))
			end
			V_drawString(v, min(t*32 - 8*(i-1) +32, x+32), y + 2, skname, skname:len() <= 10 and "NFNT" or "TFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, "center", 31)
			if i%4 == 0
				x = $ + 68
				y = 148
			else
				y = $ + 12
			end
		end

		-- draw NEXT skill if we have one.
		local nextskill
		local persona = mo.persona	-- easier access to skillist
		-- search for skills we can't learn with our current level progression FIRST, then we look in the skillqueue table to overwrite info
		for i = 1, #persona.skills
			local s = persona.skills[i]
			if s and s[2] and s[2] > mo.level
				nextskill = s
				break
			end
		end

		if battle.r_newskillsqueue[mynum] and battle.r_newskillsqueue[mynum][1]	-- if we LEARNT new skills then we need to show them;
			nextskill = battle.r_newskillsqueue[mynum][1]	-- they will go away as they are learnt, so always pick [1]
		end

		if nextskill-- do not draw if no nextskill
			-- display NEXT skill:
			V_drawString(v, 246, 174, "NEXT: LV"..nextskill[2], "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 0)
			v.drawFill(246, 184, 64, 10, 135|V_SNAPTOBOTTOM|V_SNAPTOLEFT)	-- we need a box o coc riiiiight here
			local nskname = nextskill[1]
			local sk
			local atype

			if attackDefs[nskname]
				sk = attackDefs[nskname]

				if sk.type & ATK_PASSIVE
					atype = 15
				else
					atype = atk_constant_2_num[attackDefs[nskname].type]
				end

				nskname = attackDefs[$].name
			end

			if atype
				v.drawScaled(246*FRACUNIT, 185*FRACUNIT, FRACUNIT/4, v.cachePatch("ATK_"..atype), V_SNAPTOBOTTOM|V_SNAPTOLEFT)
				v.drawIndex(246*FRACUNIT, 185*FRACUNIT, FRACUNIT/4, v.cachePatch("H_ELMF3"), V_SNAPTOBOTTOM|V_SNAPTOLEFT, 135)
			end

			if not ((mo.newskillnum or mo.r_forgetselect) and leveltime%4 < 2)
				V_drawString(v, 278, 186, nskname, nskname:len() <= 10 and "NFNT" or "TFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, "center", 31)	-- skill name
			end

			if mo.r_forgetselect	-- must forget skill, tell player
				V_drawString(v, 40, 150, "Too many \nskills!\nSelect skill \nto forget. \n".."\x90".."Forget\n".."\x91".."Relent", "NFNT", V_SNAPTOBOTTOM|V_SNAPTOLEFT, nil, 31)

				-- we have to forget a skill? Draw the properties of our new skill

				if mo.r_askconfirm
					v.drawFill(160, 90, 160, 30, 135|V_SNAPTORIGHT)
					local prompts = {
						"Are you sure you want\nto replace this skill?\nThis cannot be undone",
						"Are you sure you don't\nwant to learn this skill?\nThis cannot be undone",
					}

					V_drawString(v, 161, 90, "\x82"..prompts[mo.r_askconfirm] or "", "NFNT", V_SNAPTORIGHT, nil, 0, 31)
					V_drawString(v, 280, 95, "\x90"..": OK\n".."\x91"..": NO", "NFNT", V_SNAPTORIGHT, nil, 0, 31)

				elseif sk

					v.drawFill(160, 110, 160, 30, 135|V_SNAPTORIGHT)
					local str = sk.name
					local str2 = sk.desc

					V_drawString(v, 161, 105, "\x82".."(NEW) ".."\x80"..str, "NFNT", V_SNAPTORIGHT, nil, 0, 31)
					V_drawString(v, 161, 115, str2, "NFNT", V_SNAPTORIGHT, nil, 0, 31)
				end
			end
		end

		-- draw transitions...
		if mo.r_transition
			local it = (TICRATE/2) -mo.r_transition
			if it < 12
				drawScreenwidePatch(v, v.cachePatch("H_END"..it/2 + 1))
			else
				v.drawFill()
				loc_trns = 0
			end
		end

	else	-- I haven't leveled up, so let's just have a waiting screen.
		drawWaitScreen(v, 1, LEVELWAITSTRING)
	end
end)

-- draw battle finish wipe
local function drawFinish(v, battle)
	local timer = battle.r_wipe
	v.drawFill(0, 0, 20*timer, 500, 31|V_SNAPTOTOP|V_SNAPTOLEFT)
end

local cutinStart = TICRATE*3/2
local cutinframetime = {0, -3, -5, -18, -20, -22, -24}

local function drawPlayerCutin(v, mo)
	local timer = mo.cutintimer
	if not timer return end

	local cutin_face_prefix = mo.hudcutin or "CUTIN_D"
	if mo.status_condition == COND_SUPER
		cutin_face_prefix = mo.hudscutin or $
	end

	for k, i in ipairs(cutinframetime)
		local checkframe = cutinStart + i
		local checkframe2 = cutinStart + (cutinframetime[k+1] or TICRATE*3/2)
		if timer <= checkframe
		and timer >= checkframe2
			drawScreenwidePatch(v, v.cachePatch((mo.plyr and "CUTIN" or "CUTNE")..k))
			if k >= 3 and (k-2) <= 3 
				if v.patchExists(cutin_face_prefix..k-2)
					drawScreenwidePatch(v, v.cachePatch(cutin_face_prefix..k-2), v.getColormap(TC_DEFAULT, mo.color))
				else
					drawScreenwidePatch(v, v.cachePatch("CUTIN_D"..k-2), v.getColormap(TC_DEFAULT, mo.color))
				end
			end
		end
	end
end

-- Attack HUD animations for BS_ACTION and cut ins
local function drawAttackAnim(v, p, c, mo)
	local mo = server.P_BattleStatus[mo.battlen].turnorder[1]

	if mo.cutin
		drawPlayerCutin(v, mo)
	end

	if not mo or not server.P_BattleStatus[mo.battlen].atktimer
		return
	end	-- what

	if mo.attack and attackDefs[mo.attackref].hudfunc
		attackDefs[mo.attackref].hudfunc(v, mo, server.P_BattleStatus[mo.battlen].atktimer)
	end
end

-- Attack HUD animations layered above the regular UI:
local function drawAttackAnim2(v, p, c, mo)
	if not mo or not server.P_BattleStatus[mo.battlen].atktimer
		return
	end	-- what

	if mo.attack and mo.attack.hudfunc2
		mo.attack.hudfunc2(v, mo, server.P_BattleStatus[mo.battlen].atktimer)
	end
end

local card_names = {
	"Suit of Swords",
	"Suit of Cups",
	"Suit of Coins",
	"Suit of Wands",
	"Persona Card",
	"Blank Card",
	"Penalty Card",
}

local function drawShuffleTime(v, p, c)
	local mo = p.maincontrol
	local btl = server.P_BattleStatus[mo.battlen]

	-- shuffle time intro:
	if btl.hudtimer.shufflestart

		local t = (TICRATE - (btl.hudtimer.shufflestart*2))
		local t2 = (t<<FRACBITS) /3
		local t3 = t2

		-- circles, or something!
		local scale = t*FRACUNIT/6
		local trflag = V_70TRANS
		if btl.hudtimer.shufflestart < 15
			trflag = V_90TRANS - (V_10TRANS*(btl.hudtimer.shufflestart/5))
		end
		if scale > 0	-- lol negative scales
		local pp = "H_1M_B"
		if mo.enemy
			pp = "H_1M_E"
		end
			v.drawScaled(160<<FRACBITS, 100<<FRACBITS, scale, v.cachePatch(pp), trflag)
			v.drawScaled(160<<FRACBITS, 100<<FRACBITS, scale, v.cachePatch("H_1M_C"))
		end

		/*if btl.hudtimer.shufflestart == TICRATE
			S_StartSound(nil, sfx_1more)
		end*/

		t3 = FixedMul(t3, t3)
		t3 = $+ FixedMul(t3, t2)

		v.drawScaled((130)<<FRACBITS +t3/3, (80)<<FRACBITS +t3/8, FRACUNIT/2, v.cachePatch("H_SHFL2"), V_SNAPTOLEFT)
		v.drawScaled((123)<<FRACBITS -t3/3, (93)<<FRACBITS -t3/7, FRACUNIT/2, v.cachePatch("H_SHFL1"), V_SNAPTOLEFT)
	end


	if btl.shufflestatus == 2
		-- draw text to show to pick a card
		V_drawString(v, 160, 128, "Draw a card", "NFNT", V_SNAPTOBOTTOM, "center", 0, 31)
		V_drawString(v, 160, 138, ((TICRATE*5) - btl.shuffletimer)/TICRATE +1, "NFNT", V_SNAPTOBOTTOM, "center", 0, 31)
	elseif btl.shufflestatus == 3
	and btl.shuffletimer > TICRATE/2 + 9
		-- draw what card we drew (yeah ok that sounds dumb)

		local death = mo.shuffletypes[mo.shuffle_choice] & 1024
		local deathfact = death and 2 or 1	-- multiplier for death cards

		local cardtype = mo.shuffletypes[mo.shuffle_choice] & 1023
		local lvl = mo.shufflelevels[mo.shuffle_choice]

		local cup_heals = BTL_shuffleCupHeal[lvl]
		local dosh = BTL_shuffleMultiplier_money[lvl] - 100
		local exp = BTL_shuffleMultiplier_EXP[lvl] - 100

		local card_desc = {
			"You've obtained the Skill Card",
			"Your party recovers "..cup_heals.."% HP and "..(cup_heals/2).."% SP",
			"You party gains "..dosh.."% more Macca from this battle",
			"Your party gains "..exp.."% more EXP from this battle",
			"Obtained the Sub-Persona",
			"Nothing happened...",
			"You won't gain any EXP from this battle...",
		}

		local card_desc_death = {
			"You've obtained the Skill Card",
			"Your party recovers \x85"..(cup_heals*2).."%\x80 HP and \x85"..(cup_heals/3*2).."%\x80 SP",
			"You party gains \x85"..(dosh*2).."%\x80 more Macca from this battle",
			"Your party gains \x85"..(exp*2).."%\x80 more EXP from this battle",
			"Obtained the Sub-Persona",
			"Nothing happened...",
			"You won't gain any EXP from this battle...",
		}

		V_drawString(v, 160, 128, "You have drawn a ".."\x82"..card_names[cardtype], "NFNT", V_SNAPTOBOTTOM, "center", 0, 31)
		V_drawString(v, 160, 138, death and card_desc_death[cardtype] or card_desc[cardtype], "NFNT", V_SNAPTOBOTTOM, "center", 0, 31)
		if cardtype == 1	-- very special case, display the skill card name
			local name = "\x82"..mo.shuffle_skillcard
			if attackDefs[mo.shuffle_skillcard] and attackDefs[mo.shuffle_skillcard].name
				name = "\x82"..attackDefs[mo.shuffle_skillcard].name
			end
			V_drawString(v, 160, 148, ICO_SKILLCARD..name, "NFNT", V_SNAPTOBOTTOM, "center", 0, 31)
			if death
				V_drawString(v, 160, 158, "The curse of Death looms on you...", "NFNT", V_SNAPTOBOTTOM, "center", 35, 31)
			end

		elseif cardtype == 5	-- other special case
			local name = "\x82"..mo.shuffle_persona
			if subpersonaList[mo.shuffle_persona] and subpersonaList[mo.shuffle_persona].name
				name = "\x82"..subpersonaList[mo.shuffle_persona].name
			end
			V_drawString(v, 160, 148, ICO_PERSONA..name, "NFNT", V_SNAPTOBOTTOM, "center", 0, 31)
			if death
				V_drawString(v, 160, 158, "The curse of Death looms on you...", "NFNT", V_SNAPTOBOTTOM, "center", 35, 31)
			end

		elseif death
			V_drawString(v, 160, 148, "The curse of Death looms on you...", "NFNT", V_SNAPTOBOTTOM, "center", 35, 31)
		end
	end
end

-- multiplayer tally

local loc_scroll = 0	-- local scrolling on the result, legit cba to handle this per player

local mpfinish_headerlines = {
	"DUNGEON STATS",
	"BATTLE STATS",
	"ITEM STATS",
}

-- {displayname, _Gstatename}
local mpfinish_stats = {
	[1] = {	-- for DUNGEON STATS
		{"Time", "time", true},	-- special case for the n display
		{"Floors played", "floors"},
		{"Times spotted by The Reaper", "reaperspotted"},
	},

	[2] = {	-- for BATTLE STATS
		{"Encounters fought", "encounters"},
		{"Total damage dealt", "damagedealt"},
		{"Total damage taken", "damagetaken"},
		{"Total healing done", "damagehealed"},
		{"Enemies defeated", "enemiesdefeated"},
		{"Knockdowns", "knockdowns"},
		{"Times KO'd", "timesdied"},
		{"Hold Ups", "holdups"},
		{"All-Out Attacks", "alloutattacks"},
	},

	[3] = { -- for ITEM STATS

		{"Total Macca earned", "maccaearned"},
		{"Total Macca spent", "maccaspent"},
		{"Items Found",	"itemsfound"},
		{"Items Bought", "itemsbought"},
		{"Items Sold", "itemssold"},
		{"Items Used", "itemsused"},
		{"Weapons Enhanced", "weaponsenhanced"},
		{"Rings Enhanced", "ringsenhanced"},

	},
}

local mpfinish_startdrawat = 48
local mpfinish_startfadetimer = 70

local function drawMPFinish(v, p, btl)

	-- start with a fade screen
	local timer = btl.hudtimer.mpfinish
	local rtimer = TICRATE/2 - timer

	if rtimer < 0 return end

	local tflag = 0
	if rtimer < TICRATE/2
		tflag = V_90TRANS - rtimer*V_10TRANS
		if tflag < V_10TRANS
			tflag = 0
		end

		loc_trns = 7
		mpfinish_startfadetimer = 70
	else
		phud.clear("main")

		mpfinish_startfadetimer = max(0, $-1)

		if not mpfinish_startfadetimer
			loc_trns = $+1
			tflag = min(3, (loc_trns/16))<<V_ALPHASHIFT
		end
	end

	--drawScreenwidePatch(v, v.cachePatch("H_RIP4"), nil, tflag)
	v.fadeScreen(31, 10-((tflag)>>V_ALPHASHIFT))

	-- from here, only render after the screen has fully faded:
	if rtimer < TICRATE/2 return end

	local linen = mpfinish_startdrawat		-- how many lines we've drawn (used to know the max possible scrolling value)
	local dy = mpfinish_startdrawat - loc_scroll

	for i = 1, #mpfinish_headerlines do
		-- draw header line
		v.drawFill(0, dy, 400, 8, 135|V_SNAPTOLEFT)
		V_drawString(v, 8, dy, mpfinish_headerlines[i]:upper(), "FPIMP", V_SNAPTOLEFT, nil, 31, nil)
		dy = $+16
		linen = $+16

		-- now draw each individual value:
		for j = 1, #mpfinish_stats[i] do
			local t = mpfinish_stats[i][j]
			if btl.netstats[t[2]] ~= nil	-- make sure variable exists
				V_drawString(v, 8, dy, t[1], "NFNT", V_SNAPTOLEFT, nil, 0, nil)

				if t[3]	-- special case for timers
					local time = btl.netstats[t[2]]
					local t =  G_TicsToHours(time)..":"..string.format("%02d:%02d.%02d", G_TicsToMinutes(time), G_TicsToSeconds(time), G_TicsToCentiseconds(time))
					V_drawString(v, 200, dy, t, "NFNT", V_SNAPTOLEFT, "right", 0, nil)
				else
					V_drawString(v, 200, dy, tostring(btl.netstats[t[2]]), "NFNT", V_SNAPTOLEFT, "right", 0, nil)	-- draw its value
				end
				dy = $+10
				linen = $+10

				if j == #mpfinish_stats[i]
					dy = $+10
					linen = $+10
				end
			end
		end
	end

	local str = "PRESS A TO CONFIRM"
	if btl.kill
		str = "PRESS F12 TO SPECTATE OTHER PLAYERS"
	end

	V_drawString(v, 160, dy, "\x82"..str, "NFNT", V_SNAPTOLEFT, "center", 0, nil)
	dy = $+10
	linen = $+10

	-- translucent mask over the values to make them fade in smoothly~
	local tflag2 = 1 + (loc_trns-7)/2
	if mpfinish_startfadetimer
		tflag2 = 0
	end

	if tflag2 <= 9
		--drawScreenwidePatch(v, v.cachePatch("H_RIP4"), nil, tflag2<<V_ALPHASHIFT)
		v.fadeScreen(31, 10-tflag2)
	end

	local inpt = p.cmd.forwardmove
	if inpt > 0
		loc_scroll = max(0, $-2)
	elseif inpt < 0
		local maxscroll = linen - 200	-- 200 = screen h
		loc_scroll = min(maxscroll, $+2)
	end
end

local function drawGameOver(v, btl)
	local t = btl.hudtimer.gameover

	if not t
		v.drawFill()
	end

	if t < TICRATE/3
		local scale = FRACUNIT /2 + FRACUNIT*t/2
		v.drawScaled(160<<FRACBITS, 100<<FRACBITS, scale, v.cachePatch("H_GMOVR"))
	end

	if not t

		local nbkill = 0
		for i = 1, 4
			local tb = server.P_BattleStatus[i]

			if tb.gameover or not (server.plentities[i][1])
				nbkill = $+1
			end
		end

		if nbkill >= 4
		and btl.n == 1	-- first battle status gets to choose what we do
			if server.gamemode ~= GM_VOIDRUN
				V_drawString(v, 160, 10, "\x82".."Press A to retry from last checkpoint", "NFNT", V_SNAPTOTOP, "center", 0, nil)
			end
			V_drawString(v, 160, 20, "\x82".."Press B to give up", "NFNT", V_SNAPTOTOP, "center", 0, nil)
		end

		V_drawString(v, 160, 160, "Your party was wiped out.", "NFNT", V_SNAPTOBOTTOM, "center", 0, nil)
		if server.P_netstat and server.P_netstat.leaders and #server.P_netstat.leaders > 1
			V_drawString(v, 160, 170, "You will respawn next floor", "NFNT", V_SNAPTOBOTTOM, "center", 0, nil)
			V_drawString(v, 160, 180, "(PRESS F12 TO WATCH OTHER PLAYERS)", "NFNT", V_SNAPTOBOTTOM, "center", 0, nil)
		end
	end

	local newt = btl.hudtimer.gameoverremove

	if newt and newt > 1
		local ript = 8- newt
		drawScreenwidePatch(v, v.cachePatch("H_RIP"..min(4, (ript/2)+1)))
	end
end

-- just a fade lol
local function drawPVPOver(v, btl)

	local t = btl.hudtimer.pvpend
	if t < TICRATE
		local flag = (t/4) << V_ALPHASHIFT
		drawScreenwidePatch(v, v.cachePatch("H_RIP4"), nil, flag)
	end
end

-- clock / score

-- bx: x position (int)
-- by: y position (int)
-- time: time (tic_t), also allows nil
-- low: flashes clock red if time < low (can be left nil)
rawset(_G, "drawTimeClock", function(v, bx, by, time, low)
	PDraw(v, bx, by, v.cachePatch("H_CHCL"), V_SNAPTOTOP|V_SNAPTOLEFT)
	local displaytime = time or 0

	-- do yalls like trig? no? cool fuck you
	local tx = bx<<FRACBITS
	local ty = (by)<<FRACBITS
	local secs = G_TicsToSeconds(displaytime)

	-- 0 seconds is north (ANGLE_90), then we do -6 to ang for every second
	local a = ANGLE_90 - secs*6*ANG1	-- ok cool

	local dx = tx + 6*cos(a)
	local dy = ty + 6*sin(a)

	R_drawAngledLine(v, dx/FRACUNIT, dy/FRACUNIT, InvAngle(a) + 180*ANG1, 22, 31|V_SNAPTOTOP|V_SNAPTOLEFT, 2)

	-- draw time:
	local minu = G_TicsToMinutes(displaytime)
	local clr = 0
	if low and time and time < low
	and leveltime%10 < 5
		clr = 35
	end

	if time == nil or server.P_DungeonStatus.VR_locktimer
		V_drawString(v, bx, by-4, string.format("--:--", minu, secs), "NFNT", V_SNAPTOTOP|V_SNAPTOLEFT, "center", clr, 31)
	else
		V_drawString(v, bx, by-4, string.format("%02d:%02d", minu, secs), "NFNT", V_SNAPTOTOP|V_SNAPTOLEFT, "center", clr, 31)
	end
end)

local function drawChallengeStatus(v, mo, btl)

	local bx, by = 30, min(-100 + btl.battletime*8, 16)
	local time = btl.timer
	drawTimeClock(v, bx, by, time, 60*TICRATE)

	-- draw score:
	if btl.score ~= nil	-- only set for challenge battles w/ score
		V_drawString(v, bx, by+8, string.format("%06d", btl.score), "FPNUM", V_SNAPTOTOP|V_SNAPTOLEFT, "center", 0, 31)

		if btl.addscore
			V_drawString(v, bx, by+16, "\x82".."+"..btl.addscore, "NFNT", V_SNAPTOTOP|V_SNAPTOLEFT, "center", clr, 31)
		end
	end
end

local function drawMoreEnemies(v, btl)
	local ht = btl.hudtimer.moreenemies

	local t = (TICRATE*5/2 - (ht))

	-- circles, or something!
	local scale = t*FRACUNIT/6
	local trflag = V_70TRANS

	if t > TICRATE
		local newt = t - TICRATE
		trflag = max(0, V_70TRANS - (newt/4)*V_10TRANS)
	end

	if scale > 0	-- lol negative scales
		if t < TICRATE*3/2
			local pp = "H_1M_E"
			v.drawScaled(160<<FRACBITS, 100<<FRACBITS, scale, v.cachePatch(pp), trflag)
			v.drawScaled(160<<FRACBITS, 100<<FRACBITS, scale, v.cachePatch("H_1M_C"))
		else
			local newt = t - (TICRATE*3/2)
			local pp = "H_MORE"..(newt/2)+1

			if v.patchExists(pp)
				drawScreenwidePatch(v, v.cachePatch(pp))
			end
		end
	end

	local tscale = max(FRACUNIT/2, (btl.hudtimer.moreenemies - TICRATE*2 - TICRATE*1/4)*FRACUNIT/2)

	if t == 6
		for i = 1, #server.plentities[btl.n]
			S_StartSound(nil, sfx_1more, server.plentities[btl.n][i].control)
		end
	end

	local tx1 = (100 + N_RandomRange(-6, 6))<<FRACBITS
	if t > TICRATE
		tx1 = (100 + (t-TICRATE)*32)*FRACUNIT
	end

	local ty1 = (75 + N_RandomRange(-6, 6))<<FRACBITS

	v.drawIndex(tx1 + 4<<FRACBITS, ty1 + 4<<FRACBITS, tscale, v.cachePatch("H_MOREN1"), 0, 31)
	v.drawIndex(tx1, ty1, tscale, v.cachePatch("H_MOREN1"), 0, 0)

	local tx2 = (200 + N_RandomRange(-6, 6))<<FRACBITS
	if t > TICRATE
		tx2 = (200 - (t-TICRATE)*32)*FRACUNIT
	end
	local ty2 = (125 + N_RandomRange(-6, 6))<<FRACBITS

	v.drawIndex(tx2 + 4<<FRACBITS, ty2 + 4<<FRACBITS, tscale, v.cachePatch("H_MOREN2"), 0, 31)
	v.drawIndex(tx2, ty2, tscale, v.cachePatch("H_MOREN2"), 0, 0)
end

local function drawChallengeEnd(v, btl)

	-- timer: btl.hudtimer.challengeend
	-- win?: btl.challengewon

	if btl.hudtimer.challengeend == nil return end

	local t = TICRATE*5 - btl.hudtimer.challengeend

	-- fade screen: the big text should mask its entire appeaance, so draw it straight away
	--drawScreenwidePatch(v, v.cachePatch("H_RIP4"), nil, 3<<V_ALPHASHIFT)
	v.fadeScreen(31, 7)

	local scaletime = btl.hudtimer.challengeend - TICRATE*4
	local scale = max(FRACUNIT/2, scaletime*FRACUNIT/3)

	-- draw win or loss:
	local pname = btl.challengewon and "H_CWIN" or "H_CLOSE"
	v.drawScaled(160<<FRACBITS, 100<<FRACBITS, scale, v.cachePatch(pname))

	if t > TICRATE

		if btl.challengewon and btl.newrecord
			V_drawString(v, 160, 140, "\x82".."New record!", "NFNT", V_SNAPTOBTTOM, "center", 0, 31)
		end

		local allfinished = true	-- assume everyone is done @ first
		-- but search:
		for i = 1, 4
			if server.plentities[i] and server.plentities[i][1]	-- player in this team!
			and server.P_BattleStatus[i] and server.P_BattleStatus[i].battlestate ~= BS_CHALLENGEEND	-- but their battle isn't finished
				allfinished = false
				break	-- useless to continue
			end
		end

		if not allfinished
			V_drawString(v, 160, 150, "Press F12 to spectate other Players.", "NFNT", V_SNAPTOBTTOM, "center", 0, 31)
		end
	end
end

local frametotransframe = {"TRANS_E3", "TRANS_E2", "TRANS_E1", "TRANS_E2", "TRANS_E1", "TRANS_E3"}
local function drawEnemyTransition(v, mo)
	local ind = mo.enemy_trans/2
	if ind
		drawScreenwidePatch(v, v.cachePatch(frametotransframe[ind]), v.getColormap(TC_DEFAULT, SKINCOLOR_RED))
	end
end

local cv_physhud = CV_RegisterVar({
	name = "hu_physhud",
	defaultvalue = "On",
	PossibleValue = CV_OnOff,
})

local raredrop_frame = A
local possible_frames = {A, B, C, D, E, F, G, H, I, J, K, P, Q}

local basex = 160
local basey = 80

local rx = basex
local tgtx = 65


rawset(_G, "R_drawRareDrop", function(v, p)
	if p.mo and p.mo.valid and p.mo.r_raredrop

		local t = p.mo.r_raredrop
		local timetrheshold = 17

		-- display test:
		local stretch_scales = {
			{FRACUNIT/4, FRACUNIT*4},
			{FRACUNIT/2, FRACUNIT*2},
		}

		local stretch
		local firsletterpatch
		local midpatch

		if t < 3
			raredrop_frame = A
			stretch = stretch_scales[t]
			midpatch = "DROP"..(string.char(raredrop_frame+65)).."0"

		elseif t >= timetrheshold

			stretch = {FRACUNIT, FRACUNIT}
			firsletterpatch = "RDRP_1"
			rx = $ - ($-tgtx)/3

		else
			rx = basex
			stretch = {-cos((t-3)*ANG1*40), FRACUNIT}

			if FixedMul(cos((t-4)*ANG1*40), stretch[1]) < 0	-- different sign, we finished a spin or smth
				raredrop_frame = possible_frames[N_RandomRange(1, #possible_frames)]
			end
			midpatch = "DROP"..(string.char(raredrop_frame+65)).."0"

			if t > timetrheshold-2
				midpatch = "RDRP_1"	-- prepare to display the "R"
			end

		end




		if stretch and t < timetrheshold	-- magic number gogo!
			v.drawStretched(basex << FRACBITS, basey << FRACBITS, abs(stretch[1]*2), stretch[2]*2, v.cachePatch(midpatch), (stretch[1] < 0 and V_FLIP or 0), v.getColormap(TC_DEFAULT, SKINCOLOR_YELLOW))

		else
			local dt = t-timetrheshold

			local col = SKINCOLOR_YELLOW

			for i = 1, 2
				if dt >= 28 + (10*(i-1))
				and dt <= 28 + (10*(i-1))
					col = SKINCOLOR_WHITE
				end
			end

			if t >= timetrheshold+53
				stretch[1] = max(0, FRACUNIT - (t-(timetrheshold+53))*FRACUNIT/4)
			end


			if stretch[1]
				v.drawStretched(rx << FRACBITS, basey << FRACBITS, abs(stretch[1]*2), stretch[2]*2, v.cachePatch(firsletterpatch), (stretch[1] < 0 and V_FLIP or 0), v.getColormap(TC_DEFAULT, col))
			end

			local lets = {2, 1, 3, nil, 4, 1, 5, 6}
			local lx = rx + 25
			for i = 1, #lets do

				if lets[i] and (dt-(i*2)) >= i

					local tx = (dt-(i*2))
					col = SKINCOLOR_YELLOW

					for j = 1, 2
						if dt >= 28 + i + (10*(j-1))
						and dt <= 28 + i + (10*(j-1))
							col = SKINCOLOR_WHITE
						end
					end

					local xstretch = min(FRACUNIT, abs(FRACUNIT-(tx*FRACUNIT/4)))

					if t >= timetrheshold+53 +i
						xstretch = max(0, FRACUNIT - (t-(timetrheshold+53)-i)*FRACUNIT/3)
					end

					if xstretch
						v.drawStretched(lx << FRACBITS, basey << FRACBITS, abs(xstretch)*3/2, FRACUNIT*3/2, v.cachePatch("RDRP_"..lets[i]), 0, v.getColormap(TC_DEFAULT, col))
					end
					lx = $ + 24
				else
					lx = $ + 12
				end
			end
		end
	end
end)

hud.add(function(v, p, c)
	if not EnabledHuds["Battle"] return end
	hud.disable("score")
	hud.disable("time")
	hud.disable("rings")
	hud.disable("lives")
	hud.disable("stagetitle")

	if not server.plentities or not #server.plentities or not server.skinlist return end	-- wait until we're finished setting up our team in MP
	local mo = p.mo
	if not mo return end

	local b = p.control
	if not b or not b.valid or not b.battlen return end

	if (server.gamemode == GM_PVP or server.gamemode == GM_CHALLENGE)
	and not (server.P_BattleStatus[b.battlen] and server.P_BattleStatus[b.battlen].running)
		v.drawFill()
	end

	if server.P_BattleStatus[b.battlen]
	and server.P_BattleStatus[b.battlen].running
		local battle = server.P_BattleStatus[b.battlen]

		local cturn = battle.turnorder[1]
		local drawnparty

		if battle.battlestate == BS_SHUFFLE
			drawShuffleTime(v, p, c, cturn)
			return	-- nope
		end

		renderTitlecard(v)	-- good to have

		if battle.battlestate == BS_HOLDUP
			drawHoldUp(v, p, c, cturn)
		-- now is a good time to draw attack hud functions:
		elseif battle.battlestate == BS_ACTION
			drawAttackAnim(v, p, c, cturn)
			local cturn = battle.turnorder[1]
			if not cturn.plyr
			and cturn.enemy_trans
				drawEnemyTransition(v, cturn)	-- enemy attack transitions (for camera)
			end
		end

		if cv_physhud.value
			DisplayPhysHUD(v, "main", p)
		end

		-- draw damaged enemies above that, OBVIOUSLY
		if battle.battlestate ~= BS_START
		--and battle.battlestate ~= BS_PRETURN
			drawDamagedEnemies(v, p, c, cturn)
		end

		if battle.battlestate == BS_DOTURN
			if cturn.onemore
				drawOneMore(v, p, c, cturn)
				drawPartyStatus(v, p, battle)	-- small hack
				if server.gamemode == GM_CHALLENGE
					drawChallengeStatus(v, cturn, battle)
				elseif server.gamemode == GM_VOIDRUN
					renderVRInfo(v, p, battle)
				end
				drawTransition(v, battle)	-- make sure to draw this too
				R_drawRareDrop(v, p)
				return
			end

			if cturn.plyr
			and cturn.control
				drawPlayerTurn(v, p, c, cturn)
			end

			if p.P_party ~= cturn.party
				drawPartyStatus(v, p, battle)	-- small hack
				drawnparty = true
			end
		end

		if not (battle.battlestate == BS_END and battle.hudtimer.endb == 0)
		and not (battle.battlestate == BS_LEVELUP)
		and not (battle.battlestate == BS_MPFINISH and not battle.hudtimer.mpfinish)
		and not (battle.battlestate == BS_DOTURN)
			if not drawnparty
				drawPartyStatus(v, p, battle, ctur)	-- rendered at all times, unless the VERY SPECIFIC cases specified above
			end
		end

		drawBattleStart(v,battle)
		drawBattleLog(v, cturn)				-- drawn above most things

		if server.gamemode == GM_CHALLENGE
			drawChallengeStatus(v, cturn, battle)
		elseif server.gamemode == GM_VOIDRUN
			renderVRInfo(v, p, battle)
		end

		if battle.battlestate == BS_END
			drawBattleEnd(v, battle)
		elseif battle.battlestate == BS_LEVELUP
			drawLevelUp(v, p, battle)
		elseif battle.battlestate == BS_FINISH
			drawFinish(v, battle)
		elseif battle.battlestate == BS_MPFINISH
			drawMPFinish(v, p, battle)
		elseif battle.battlestate == BS_GAMEOVER
			drawGameOver(v, battle)
		elseif battle.battlestate == BS_PVPOVER
			drawPVPOver(v, battle)
		elseif battle.battlestate == BS_CHALLENGEEND
			drawChallengeEnd(v, battle)
		end

		if battle.battlestate == BS_ACTION	-- for analysis and attacks that need their huds to overlay the existing hud
			drawAttackAnim2(v, p, c, cturn)
		end

		if battle.hudtimer.moreenemies
			drawMoreEnemies(v, battle)
		end

		drawTransition(v, battle)
		R_drawRareDrop(v, p)
		drawEvent(v, p)	-- draw the events
	else
		-- reset all local battle vars outside of battle
		loc_scroll = 0
	end
end)
