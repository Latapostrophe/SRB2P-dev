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

	-- name
	if name
		V_drawString(v, 100, y+10, name, "NFNT", V_SNAPTOBOTTOM, nil, 31, nil)
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

rawset(_G, "drawEvent", function(v, p)

	if not server.plentities or not #server.plentities or not server.skinlist return end	-- wait until we're finished setting up our team in MP

	local evt = server.P_DialogueStatus[p.P_party]
	if not evt.running return end
	if not evt.event return end

	local cur = eventList[evt.event][evt.eventindex]

	-- even hud, back, behind text boxes portrait etc
	if eventList[evt.event]["hud_back"]
		eventList[evt.event]["hud_back"](v, evt)
	end

	if not cur	return end

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
	end

	-- event hud: front
	if eventList[evt.event]["hud_front"]
		eventList[evt.event]["hud_front"](v, evt)
	end

end)