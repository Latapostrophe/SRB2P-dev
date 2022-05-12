-- this script handles pretty much all the menus in the game.

--M_PSELCT.lmp

rawset(_G, "M_menus", {})	-- table of menus

-- menu hanler: inputs etc etc etc
rawset(_G, "M_handleMenu", function(mo)
	-- handle what menu we're on
	if not mo.m_menu return end			-- no menu, return

	PLAY_nomove(mo.player)
	-- mid-menu events.
	if D_runPlayerEvent(mo.player) return end	
	if mo.editmode return end

	-- menu timers:
	if mo.m_hudtimers
		for k,v in pairs(mo.m_hudtimers)
			if v
				mo.m_hudtimers[k] = $-1
				-- special case:
				if k == "sclosemenu"
					if mo.m_hudtimers[k] == 0
						if mo.m_prevmenu	-- we have a previous submenu
							M_openSubmenu(mo, mo.m_prevmenu, true)	-- open the menu but skip its animation
							mo.m_prevmenu = nil
							return	-- QUIT THIS
						else
							-- no menu. ...well then, we're closing this.
							M_closeMenu(mo)
							return	-- ALSO QUIT
						end
					end
				end
			end
		end
	end

	local menu = M_menus[mo.m_menu]
	if menu.runfunc
		if menu.runfunc(mo)
			return
		end
	end

	-- handle inputs in sub menus and whatnot
	local inputs = mo.P_inputs
	if not mo.m_submenu return end

	local smenu = menu[mo.m_submenu] -- no submenu, return
	if smenu.runfunc
		if smenu.runfunc(mo)
			return true
		end
	end

	local invert = smenu.invert
	if smenu.useinputcv
		if not invert and not mo.player.invertcommand
			invert = 1
		end
	end

	local dynchoices = smenu.dynchoices		-- variable number of choices
	local minchoice = 1	-- weird hack for monad on block selection
	if mo.m_minchoice ~= nil
		minchoice = mo.m_minchoice
	end

	-- handle inputs:
	if not smenu.choices and not dynchoices return end	-- probably handled alone
	local nchoices

	if dynchoices
		nchoices = mo.m_dynchoices or 32767
	else
		nchoices = #smenu.choices
	end

	-- for dynchoices, mo.m_dynchoices must be set manually. Otherwise this defaults to 32767
	--local choice = mo.m_menuchoices[mo.m_submenu]

	if (invert and inputs["up"] == 1) or (not invert and inputs["down"] == 1)
		mo.m_menuchoices[mo.m_submenu] = $+1
		if mo.m_menuchoices[mo.m_submenu] > nchoices
			mo.m_menuchoices[mo.m_submenu] = minchoice
		end
		if smenu.hoversound
			S_StartSound(nil, smenu.hoversound, mo.player)
		end

	elseif (invert and inputs["down"] == 1) or (not invert and inputs["up"] == 1)
		mo.m_menuchoices[mo.m_submenu] = $-1
		--if not mo.m_menuchoices[mo.m_submenu]
		if mo.m_menuchoices[mo.m_submenu] < minchoice
			mo.m_menuchoices[mo.m_submenu] = nchoices
		end
		if smenu.hoversound
			S_StartSound(nil, smenu.hoversound, mo.player)
		end

	elseif inputs[BT_USE]==1	-- used for return
	and not mo.m_hudtimers.sclosemenu	-- don't actually do that if we're mid-anim
		if smenu.returnfunc
			if smenu.returnfunc(mo, choice)
				return
			end
		end
		-- otherwise, perform as usual.
		mo.m_hudtimers.sclosemenu = smenu.closetimer or 1
		mo.m_prevmenu = smenu.prev
		return

	elseif inputs[BT_JUMP]==1	-- used to confirm

		if smenu.confirmsound
			S_StartSound(nil, smenu.confirmsound, mo.player)
		end

		if smenu.confirmfunc
			if smenu.confirmfunc(mo, mo.m_menuchoices[mo.m_submenu])
				return
			end
		end
		if mo.m_menuchoices and smenu.choices[mo.m_menuchoices[mo.m_submenu]] and smenu.choices[mo.m_menuchoices[mo.m_submenu]][3]
		-- first check is notably for dynchoices
			M_openSubmenu(mo, smenu.choices[mo.m_menuchoices[mo.m_submenu]][3])
			return
		end
	end
end)

rawset(_G, "M_openSubmenu", function(mo, smenu, skipopen)
	local menu = M_menus[mo.m_menu]	-- menu
	if mo.editmode return end

	if not menu[smenu]
		dprint("\x82".."WARNING: ".."\x80".."Submenu ".."\'"..smenu.."\' does not exist")
		return
	end
	mo.m_minchoice = nil	-- get rid of this weird ass var...
	mo.m_submenu = smenu
	local subm = menu[smenu]
	if not skipopen
		mo.m_hudtimers.smenuopen = subm.opentimer
	end

	if subm.openfunc and not skipopen
		subm.openfunc(mo)
	end

	-- create the choice table if it doesn't exist.
	if mo.m_menuchoices[smenu] == nil
		mo.m_menuchoices[smenu] = 1
	end
end)

-- menu handler: open a menu (specify which menu)
rawset(_G, "M_openMenu", function(mo, menu)
	if not M_menus[menu]	-- check if menu exists
		dprint("\x82".."WARNING: ".."\x80".."Menu "..menu.." does not exist in \'M_menus\'.")
		return
	end

	-- check if a starting submenu can be opened
	if not M_menus[menu] and M_menus[menu].m_start_at and M_menus[menu][M_menus[menu].m_start_at]
		dprint("\x82".."WARNING: ".."\x80".."Menu "..menu.." does not have a starting menu.")
		return
	end

	-- set menu and open submenu
	mo.m_hudtimers = {}	-- reset hud timers
	mo.m_menuchoices = {}	-- reset all menu choices
	mo.m_menu = menu

	if M_menus[menu].openfunc
		M_menus[menu].openfunc(mo)
	end
	M_openSubmenu(mo, M_menus[menu].m_start_at)
	mo.P_inputs[BT_JUMP] = 2
	mo.P_inputs[BT_USE] = 2	-- if menus are to be opened during mapload etc

	--mo.m_submenu = M_menus[menu][M_menus[menu].m_start_at]
end)

-- menu handler: close a menu that's already opened
rawset(_G, "M_closeMenu", function(mo)
	mo.m_submenu = nil
	mo.m_menu = nil
	mo.m_hudtimers = nil
	mo.m_menuchoices = nil
	mo.m_minchoice = nil
	PLAY_move(mo.player)	-- restore controls
end)