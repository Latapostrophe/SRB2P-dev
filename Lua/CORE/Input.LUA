-- Input detection script

local chat_buf = 0
rawset(_G, "G_InputList", {})	-- store all inputs this frame for the local player

-- lmao this hook name
addHook("PrePreThinkFrameAndPause", function()
	G_InputList = {SRB2P_getEventList()}
end)

-- invert command and cursor memory commands
local function invertcommand()
	if consoleplayer
		COM_BufInsertText(consoleplayer, "com_invertcommand "..cv_invertcommand.value)
	end
end

local function cursormemory()
	if consoleplayer
		COM_BufInsertText(consoleplayer, "com_cursormemory "..cv_cursormemory.value)
	end
end

local function setskin()
	if consoleplayer
		COM_BufInsertText(consoleplayer, "skin "..CV_FindVar("skin").string)
	end
end

rawset(_G, "cv_cursormemory", CV_RegisterVar({
	name = "cursormemory",
	defaultvalue = 1,
	flags = CV_SAVE|CV_CALL,
	possiblevalue = CV_OnOff,
	func = cursormemory,
}
))

rawset(_G, "cv_invertcommand", CV_RegisterVar({
	name = "invertcommand",
	defaultvalue = "Off",
	flags = CV_SAVE|CV_CALL,
	possiblevalue = CV_OnOff,
	func = invertcommand,
}
))

COM_AddCommand("com_invertcommand", function(p, arg)	-- executed server-wide
	arg = tonumber($)
	p.invertcommand = arg
end)

COM_AddCommand("com_cursormemory", function(p, arg)	-- executed server-wide
	arg = tonumber($)
	p.cursormemory = arg
end)

addHook("MobjThinker", function(mo)
	if not mo.player return end
	local p = mo.player

	if p == consoleplayer
		if not p.commandinit	-- synch those ASAP
			cursormemory()
			invertcommand()
			setskin()
			p.commandinit = true
		end
	end

	if not mo.P_inputs then mo.P_inputs = {} end	--setup input

	local buttons = {
	BT_JUMP, BT_USE, BT_ATTACK, BT_TOSSFLAG, BT_FIRENORMAL, BT_CAMRIGHT, BT_CAMLEFT,
	BT_CUSTOM1, BT_CUSTOM2, BT_CUSTOM3, BT_WEAPONPREV, BT_WEAPONNEXT }

	-- handle these normal buttons

	for i = 1, #buttons
		if p.cmd.buttons & buttons[i]
			if not mo.P_inputs[buttons[i]] then mo.P_inputs[buttons[i]] = 0 end
			mo.P_inputs[buttons[i]] = $+1
		else
			mo.P_inputs[buttons[i]] = 0
		end
	end

	-- handle weaponmask?
	-- get those with buttons 1 through 7

	for i = 1,7
		if p.cmd.buttons & BT_WEAPONMASK == i
			if not mo.P_inputs[i] then mo.P_inputs[i] = 0 end
			mo.P_inputs[i] = $+1
		else
			mo.P_inputs[i] = 0
		end
	end

	-- handle directions
	-- normal directional taps

	local directionfunc = {
		function(p) return p.cmd.forwardmove > 16 end,
		function(p) return p.cmd.forwardmove < -16 end,
		function(p) return p.cmd.sidemove > 16 end,
		function(p) return p.cmd.sidemove < -16 end,
	}

	local dirs = {"up", "down", "right", "left"}

	for k,v in ipairs(dirs)
		if directionfunc[k](p)
			if not mo.P_inputs[v] then mo.P_inputs[v] = 0 end
			mo.P_inputs[v] = $+1
		else
			mo.P_inputs[v] = 0
		end
	end
end, MT_PLAYER)

-- kill movement for players or restore it
rawset(_G, "PLAY_nomove", function(p)
	p.normalspeed, p.jumpfactor = 0, 0
	p.pflags = $|PF_FORCESTRAFE
	p.drawangle = p.mo.angle
	p.noability = true

	p.SRB2PSTASIS = true
	if p.SRB2PAUTOBRAKE == nil
		p.SRB2PAUTOBRAKE = p.pflags & PF_AUTOBRAKE
		p.pflags = $ & ~PF_AUTOBRAKE
	end	
end)

rawset(_G, "PLAY_move", function(p)
	p.jumpfactor = FRACUNIT

	if p.SRB2PSTASIS
		P_ResetPlayer(p)
		p.SRB2PSTASIS = nil
	end

	if p.charability ~= CA_GLIDEANDCLIMB
	and p.charability ~= CA_TWINSPIN
		p.charability = 0
	end

	p.noability = nil
	p.normalspeed = 30*FRACUNIT
	p.runspeed = FRACUNIT*20
	p.thrustfactor = 5
	p.accelstart = 112
	p.acceleration = 42	-- gotta love magic numbers!!!!
	p.pflags = $ & ~PF_FORCESTRAFE
	p.pflags = $ | (p.SRB2PAUTOBRAKE or 0)
	p.SRB2PAUTOBRAKE = nil
end)


local chat_buf = 0

-- INPUT STANDARDIZATION
addHook("PlayerCmd", function(p, cmd)
	-- if we're in battle or in a menu, standardize inputs:

	if chat_on
		chat_buf = 4
	end
		
	if server and p and p.mo and ((p.P_party and server.P_BattleStatus and server.P_BattleStatus[p.P_party] and server.P_BattleStatus[p.P_party].running) or (p.mo.shop and p.mo.shop.shopping) or (p.mo.equiplab and p.mo.equiplab.using) or p.mo.m_menu or NET_running() or server.P_DialogueStatus and server.P_DialogueStatus.running)
	and not (SYS_systemmenu and SYS_systemmenu.running)
	and not chat_buf
	and cv_stdinput.value
		local inputs = G_InputList
		for i = 1, #inputs do
			local e = inputs[i]
			e = SYS_menuInput(e)	-- gamepad input -> keyboard input
			-- cmd is a pointer, we can modify it directly without passing by player

			-- i wish lua had switch case
			if e == KEY_ARROWU
				cmd.forwardmove = 30
			elseif e == KEY_ARROWD
				cmd.forwardmove = -30
			elseif e == KEY_ARROWR
				cmd.sidemove = 30
			elseif e == KEY_ARROWL
				cmd.sidemove = -30
			elseif e == KEY_ENTER
				cmd.buttons = $|BT_JUMP
			elseif e == KEY_BACKSPACE
				cmd.buttons = $|BT_USE
			end
		end
	end

	chat_buf = max(0, $-1)
end)
