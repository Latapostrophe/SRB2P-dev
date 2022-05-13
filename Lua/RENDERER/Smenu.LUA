-- Renders the system menu outside of the title screen.
-- Also runs the handlers and checks for it as this is more convenient

hud.add(function(v)
	if not EnabledHuds["SystemMenu"] return end
	SYS_drawMenu(v)
end)

local chat_buf = 0

-- lmao this hook name
addHook("PrePreThinkFrameAndPause", function()

	if server	-- otherwise the titlescreen menu is going to run twice / frame
		if chat_on
			chat_buf = 2	-- don't let the menu open if the chat has been opened recently so that we can close it with escape still
		end

		-- menus:
		local evts =  SYS_getEventQueue()
		local controls = SYS_getControls(gc_systemmenu)

		for i = 1, #evts
			local evt = evts[i]
			if (evt == KEY_ESCAPE or (controls[1] and evt == controls[1]) or (controls[2] and evt == controls[2]))	-- open menu
			and not SYS_systemmenu.running
			and not chat_buf
				SYS_OpenMenu(netgame and SM_PAUSE or SM_PAUSE_SP)
				-- don't return.
			end
		end
		chat_buf = max(0, $-1)
		SYS_handleMenu()
	end
end)