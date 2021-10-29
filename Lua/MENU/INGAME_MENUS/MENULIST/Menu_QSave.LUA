-- Quick menu for saving files in tartarus

local files = {}
for i = 1, MAXQSAVEFILES do
	files[i] = {"FILE "..i}
end

local function drawqSaveFiles(v, mo, choice, forcetimer)

	local timers = mo.m_hudtimers
	local timer = timers.sclosemenu and ((TICRATE*2/3) - timers.sclosemenu) or timers.smenuopen or 0
	local fwtimer = (TICRATE*2/3) - timer

	-- kool visual!!!!
	v.fadeScreen(31, min(7, fwtimer/2))
	PDraw(v, 0, timer*48, v.cachePatch("M_SAVE"), V_SNAPTOLEFT)
	v.drawFill(64, 0, 1, fwtimer*48, 135|V_SNAPTOLEFT|V_SNAPTOTOP)

	local y = 24

	for i = 1, MAXQSAVEFILES do
		local t = max(0, timer - (MAXQSAVEFILES-(i-1))*2)
		local startx = 80 + (64*t)
		local skinx = startx + 40	--120
		local h = srb2p.fileheaders[i]
		local invalid

		local headertext = "FILE"..i
		if mo.m_selectfile and choice == i
			headertext = "CONFIRM AGAIN TO OVERWRITE"
		end

		V_drawString(v, startx, y, headertext, "FPIMP", 0, nil, 0, 31)
		local txt = h and h.text or "EMPTY"
		-- iterate skins first

		V_drawString(v, startx, y+12, txt, "NFNT", 0, nil, 0, 31)
		-- draw characters:
		if h and not (choice == i and mo.m_selectfile)
			for i = 1, #h.playerlist
				for j = 1, #h.playerlist[i]
					local skin = h.playerlist[i][j].skin

					local stats = charStats[skin] or charStats["sonic"]	-- whatever lmfao
					local pp = v.cachePatch(stats.icon or "ICO_SONI")
					local color = skins[skin] and skins[skin].prefcolor or SKINCOLOR_GREEN

					PDraw(v, skinx, y+1, pp, 0, v.getColormap(TC_DEFAULT, color))
					skinx = $+10
				end
				skinx = $+6
			end
		end

		local colour = 31
		if choice == i and not (mo.m_selectfile and leveltime & 1)
			colour = 135
		end

		v.drawFill(startx-5, y-4, 999, 1, colour)
		v.drawFill(startx-4, y-3, 999, 1, colour)

		v.drawFill(startx-5, y+22, 999, 1, colour)
		v.drawFill(startx-4, y+21, 999, 1, colour)

		y = $+27
	end
end

M_menus["mp_qsave"] = {

	m_start_at = "qsave_main",	-- where the menu starts
	openfunc = function(mo)	-- play a sound when we open the menu:
		S_StartSound(nil, sfx_select, mo.player)
		mo.m_selectfile = nil
		srb2p.fileheaders = SAVE_GetQFilesHeaders()	-- reset file header display
	end,

	qsave_main = {
		opentimer = TICRATE*2/3,
		closetimer = TICRATE*2/3,
		hoversound = sfx_hover,
		confirmsound = sfx_confir,

		-- choices: mostly used for the input handler. The drawer might not need it.
		choices = files,
		-- drawer to run continuously whilst this menu is opened

		drawer = drawqSaveFiles,

		runfunc =			function(mo)

								local inpts = mo.P_inputs
								if mo.m_selectfile
									if inpts[BT_SPIN] == 1
										S_StartSound(nil, sfx_cancel, mo.player)
										mo.m_selectfile = nil
									elseif inpts[BT_JUMP] == 1
										S_StartSound(nil, sfx_lvup, mo.player)
										mo.m_selectfile = nil

										-- make sure this only happens for the game client,
										-- we wouldn't want everyone's games to be saved...
										if mo.player == consoleplayer
											SAVE_QSaveFile(mo.m_menuchoices[mo.m_submenu])
											srb2p.fileheaders = SAVE_GetQFilesHeaders()	-- update headers
										end
									end
									-- don't allow normal menu operation
									return true
								end
							end,

		confirmfunc = 		function(mo)
								mo.m_selectfile = true
							end,
	},

}

