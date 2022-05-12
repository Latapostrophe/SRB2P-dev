-- Dialogue rendering

local textbuf	-- last text
local wwtext	-- word wrapped text

-- draws a regular text box
-- NOTE: ONLY ONE AT A TIME, THE BUFFER WILL BREAK IF YOU DRAW MULTIPLE ONES!

rawset(_G, "R_drawTextBox", function(v, name, text, portrait, colour, timer, texttimer)
	-- draw the portrait:

	local y = 130 + timer*16

	-- Text buffering:
	if text ~= textbuf
		textbuf = text
		wwtext = STR_WordWrap(v, textbuf, 160, "NFNT", FRACUNIT/2)
		-- ready a table of strings.
	end

	if portrait
		PDraw(v, 8, y-32, v.cachePatch(portrait), V_SNAPTOBOTTOM, v.getColormap(TC_DEFAULT, colour))
	end

	-- draw the text box:
	PDraw(v, 54, y, v.cachePatch("H_TBG"), V_SNAPTOBOTTOM|V_30TRANS)
	PDraw(v, 54, y, v.cachePatch("H_TBOX"), V_SNAPTOBOTTOM)
	
	-- if we have a portrait, draw the arrow.
	if portrait
		PDraw(v, 54, y, v.cachePatch("H_TARR"), V_SNAPTOBOTTOM)
	end			

	-- name
	if name
		PDraw(v, 54, y, v.cachePatch("H_TNAME"), V_SNAPTOBOTTOM)
		V_drawString(v, 54+70, y+10, name, "NFNT", V_SNAPTOBOTTOM, "center", 31, nil)
	end

	-- text:
	local time = texttimer
	local cury = y+25

	for i = 1, #wwtext do
		local s = wwtext[i]:sub(1, time)
		V_drawString(v, 90, cury, s, "NFNT", V_SNAPTOBOTTOM, nil, 0, 31)
		cury = $+8
		time = $ - s:len()
		if time < 1
			break
		end	-- no use continuing if we have nothing else to draw
	end
end)

local function drawevt(v, evt)
	if not evt.running return end
	if not evt.event and not evt.data return end
	
	local dta = evt.data or eventList[evt.event]
	local cur = dta[evt.eventindex]

	-- even hud, back, behind text boxes portrait etc
	if dta["hud_back"]
		dta["hud_back"](v, evt)
	end

	if not cur return end

	if cur[1] == "text"	-- regular shit handling
	and evt.curtype == "text"

		local y = 130
		local tboxtimer = 0

		if evt.timers.textboxanim_in
			y = $ + (evt.timers.textboxanim_in*16)
			tboxtimer = evt.timers.textboxanim_in
		elseif evt.timers.textboxanim_out
			y = $ + (TICRATE/3 - evt.timers.textboxanim_out)*16
			tboxtimer = TICRATE/3 - evt.timers.textboxanim_out
		end

		-- draw the choices sliding in whenever possible.
		-- Choices are specific to events so it's fine to only ever handle them here.
		if textbuf ~= nil and evt.texttime >= textbuf:len()
				if cur[4]
				local top = y - 18 - (16*(#cur[4]-1))
				local dx = 210
				for i = 1, #cur[4]
					local c = cur[4][i]
					local dy = top + (i-1)*16 + (evt.timers.choices*20 or 0)

					if evt.choice == i
						PDraw(v, dx, dy, v.cachePatch("H_TBOXS2"), V_SNAPTOBOTTOM)
						V_drawString(v, 210 + 40, dy + 5, c[1], "NFNT", V_SNAPTOBOTTOM, "center", 31, 138)
					else
						PDraw(v, dx, dy, v.cachePatch("H_TBOXS1"), V_SNAPTOBOTTOM|V_30TRANS)
						V_drawString(v, dx + 40, dy + 5, c[1], "NFNT", V_SNAPTOBOTTOM, "center", 0, 31)
					end
				end
			else
				-- otherwise, draw the continue arrow
				local xpos = leveltime%10 < 5 and 100 or 102
				PDraw(v, xpos, 190, v.cachePatch("H_TCONT"), V_SNAPTOBOTTOM)
			end
		end

		local portrait = cur[7] and cur[7][1] or nil
		local colour = cur[7] and cur[7][2] or nil

		R_drawTextBox(v, cur[2], cur[3], portrait, colour, tboxtimer, evt.texttime)
	
	elseif cur[1] == "item"
		
		local fadein = max(0, 5 - evt.ftimer) << V_ALPHASHIFT
		local scale = FRACUNIT/2 + max(0, 5-evt.ftimer)*(FRACUNIT/2)

		v.drawScaled(115*FRACUNIT, 64*FRACUNIT, scale, v.cachePatch("H_ITGET"), fadein)
		
		for i = 1, #cur[2]
			local t = (evt.ftimer-5) - 5*(i-1)
			
			if t >= 0
				local tbl = cur[2][i]
				local flag = max(3, 10 - t) << V_ALPHASHIFT
				local flag2 = max(0, 10-t) << V_ALPHASHIFT
				
				local xpos = 160 + (i-1)*5 - max(0, 10-t)*3
				
				PDraw(v, xpos, 115 + (i-1)*12, v.cachePatch("H_ITGBG"), flag)
				local str = "UNDEFINED"
				
				if tbl[1] == "item"
					str = buildItemName(itemDefs[tbl[2]])
					if tbl[3] and tbl[3] > 1
						str = $.." x"..tbl[3]
					end
					
				elseif tbl[1] == "weapon"
					str = buildWeaponName(tbl[2])
				elseif tbl[1] == "ring"
					str = buildRingName(tbl[2])
				elseif tbl[1] == "macca"
					str = tbl[2]..currency
				end
				
				V_drawString(v, xpos, 110 + (i-1)*12, str, "NFNT", flag2, "center", 0, 31)
			end
		end
	end

	-- event hud: front
	if dta["hud_front"]
		dta["hud_front"](v, evt)
	end
	
	-- event fade-in (used for post battle stuff etc...)
	if evt.timers.fadein
		v.fadeScreen(31, min(10, evt.timers.fadein))
	end
end

rawset(_G, "drawEvent", function(v, p)

	if not server.plentities or not #server.plentities or not server.skinlist return end	-- wait until we're finished setting up our team in MP

	-- For each player, draw party-wide and per-player events:
	drawevt(v, server.P_DialogueStatus[p.P_party])	-- party-wide
	
	if p.mo.d_event
		drawevt(v, p.mo.d_event)				-- per player
	end	
	
end)