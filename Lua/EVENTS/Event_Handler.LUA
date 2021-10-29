-- events
-- this is where we can do events like in game cutscenes and dialogues and whatnot.
-- it's pretty exhaustive honestly.
-- do note that events can't run unless battlestatus has been initiated since we do rely on player inputs

local evt_flags = {
	"EV_AUTO"
}

for i = 1, #evt_flags
	rawset(_G, evt_flags[i], 2^(i-1))
end

rawset(_G, "eventList", {})	-- ready event list for further definitions

local evt_buffer = {}

local function D_resetDialogueStatus(pn)
	--evt_buffer = {}
	dprint("Reseting dialogue status")
	
	if type(server.P_DialogueStatus) ~= "table"
		server.P_DialogueStatus = {}
	end	
	
	server.P_DialogueStatus[pn] = {
		running = nil,
		event = nil,		-- name of the event to fetch from. we consider an event to be running if it isn't nil.
		time = 0,			-- time the event has been running for if that's of any use
		eventindex = 0,		-- # of the event scene being processed
		texttime = 0,		-- text time. increments everytime. used to display the text letter by letter
		textdelay = 0,		-- text delay, prevents texttime from progressing depending on the character
		choice = 1,			-- choice for texts
		eventext = {},		-- store the current event text, name
		timers = {},
		ftimer,		-- special timer when running function for ease on timed events
		cam = nil,
		usecam = nil,	-- set to true to use the event cam.
	}
	if not server or not server.P_BattleStatus return end
	local btl = server.P_BattleStatus[pn]
	for p in players.iterate do
		if btl and not btl.running
		and p.P_party == pn
			p.awayviewtics = 0
			p.awayviewmobj = nil
			p.awayviewaiming = 0
			p.mo.flags2 = $ & ~MF2_DONTDRAW
			PLAY_move(p)
		end
		--if p.savestats
		--	p.normalspeed, p.jumpfactor = p.savestats[1], p.savestats[2]
		--end
	end
end

local function D_resetAllDialogueStatus()
	for i = 1, 4 do
		D_resetDialogueStatus(i)
	end
end	

-- hacks:

local camx, camy, camz, caman

hud.add(function(v, p, c)
	if not c
		camx = 0
		camy = 0
		camz = 0
		caman = 0	-- wtf
		return
	end	
	
	camx = c.x
	camy = c.y
	camz = c.z
	caman = c.angle
end)

addHook("MapLoad", do

	if gamemap ~= srb2p.tutorial_map
		SAVE_localtable.tutorial = nil
	end

	if not server return end
	-- on map load, always clea the dialogue data
	server.P_DialogueStatus = nil	-- hack to make sure the next loading map functions properly.
	D_resetAllDialogueStatus()
	for p in players.iterate do
		PLAY_move(p)
	end
end)

-- start an event
rawset(_G, "D_startEvent", function(pn, event, camstuff)
	if not server return end	-- title

	if not server.P_DialogueStatus
		D_resetDialogueStatus(pn)
	end	
	
	local evt = server.P_DialogueStatus[pn]

	if not eventList[event]
		print("Event \'"..event.."\' does not exist.")
		D_endEvent()
		return
	end
	
	if not evt 
	or (server.entrytime and server.entrytime > TICRATE/2 + 10)
	or not server.skinlist	-- players not initiated, map is subject to change at any time... yikes!
		-- buffer:
		evt_buffer[pn] = {event, camstuff}
		
		for p in players.iterate do
			if p.P_party == pn
				PLAY_nomove(p)
			end	
		end
		return
	end

	evt.event = event
	evt.eventindex = 1
	evt.timers.start = TICRATE/3

	-- initiate camera if not done already:
	if not server.P_BattleStatus[pn].cam or not server.P_BattleStatus[pn].cam.valid
		server.P_BattleStatus[pn].cam = spawnbattlecam()
	end
	if camstuff
		local cam = server.P_BattleStatus[pn].cam
		P_TeleportMove(cam, camx or 0, camy or 0, camz or 0)
		cam.angle = caman or 0
	end
end)

addHook("MapChange",function()
	server.P_DialogueStatus = nil	-- hack to make sure the next loading map functions properly.
	evt_buffer = {}	-- make sure we don't accidentally buffer events on map change
end)

-- linedef executor to start events:
addHook("LinedefExecute", function(l, mo)
	-- start an event from a linedef, useful in maps, yknow...!
	if not l.backside return end	-- no backside = no event to read.
	local event = l.backside.text:lower()
	dprint("Beginning event \'"..event.."\'")
	D_startEvent(mo.player.P_party or 1, event, true)	-- < cam: we *need* to do this, always for linedefs since the camera isn't here otherwise
end, "PEVENT")


-- readies the next index for events.
rawset(_G, "D_requestIndex", function(pn, indx)
	local evt = server.P_DialogueStatus[pn]
	if not evt.event return end	-- nonsense!!!
	--dprint("Requesting next index for event")
	evt.save_event = indx	-- where do we go once the timer is elapsed?
	evt.timers.to = TICRATE/3

	if evt.curtype == "text"	-- current event is text
		-- check for next index........
		local nextindx = eventList[evt.event][indx]
		if not nextindx or nextindx[1] ~= "text"	-- end or not text
			evt.timers.textboxanim_out = TICRATE/3
		end
	end
end)

rawset(_G, "D_endEvent", function(pn)
	dprint("Terminating event")
	D_resetDialogueStatus(pn)
end)

-- always make this run in places where events should be able to happen.
-- returns true if an event is undergoing.
rawset(_G, "D_eventHandler", function(pn)
	if not server.P_BattleStatus return end
	if not server.P_BattleStatus[pn] return end
	local battle = server.P_BattleStatus[pn]
	if not server.plentities or not #server.plentities or not server.skinlist return end
	if not server.plentities[pn] or not #server.plentities[pn] return end
	
	local firstp
	for i = 1, server.P_netstat.teamlen or 4 
		if server.plentities[pn][i]
		and server.plentities[pn][i].valid
		and server.plentities[pn][i].control
			firstp = server.plentities[pn][i]
			break
		end
	end
	
	if not firstp return end	--??
	if not firstp.control or not firstp.control.mo return end
	local inputs = firstp.control.mo.P_inputs
	if not inputs return end	-- errors

	local evt = server.P_DialogueStatus[pn]

	if evt and evt.event

		evt.running = true
		evt.time = $+1

		for p in players.iterate do
			if p.P_party == pn
				p.awayviewmobj = battle.cam
				if evt.usecam
					p.awayviewtics = 2
					p.awayviewaiming = battle.cam.aiming or 0
				end
				--p.mo.flags2 = $|MF2_DONTDRAW
				PLAY_nomove(p)
			end	
		end

		-- handle timers and special cases
		for k, v in pairs(evt.timers)
			if evt.timers[k]
				evt.timers[k] = $-1
				if k == "to" and evt.timers[k] == 0 and evt.save_event
					--dprint("Switching to next index after animation.")
					evt.eventindex = evt.save_event
					evt.save_event = nil
					evt.texttime = 0
				elseif k == "quit" and evt.timers[k] == 0	-- quit timer elapsed, cleanse event
					D_endEvent(pn)
					return
				end
			end
		end

		-- these timers are special and cut our handlers from doing anything:
		if evt.timers.start or evt.timers.to or evt.timers.quit
			return true	-- still technically running, but on time out
		end

		local cur = eventList[evt.event][evt.eventindex]

		if not cur	-- index doesn't exist. We'll assume it ended!
		and not evt.timers.quit
			evt.timers.quit = TICRATE/3
			--dprint("Requesting for end of event")
			return true
		end

		local evflags = cur[6] or 0
		if cur[1] == "text"	-- regular shit handling

			if evt.curtype ~= "text"	-- we started with a text box, ready the animation, quick, quick!
				evt.timers.textboxanim_in = TICRATE/3
				evt.curtype = cur[1]
			end

			local txt = cur[3]

			if evt.timers.textboxanim_in or evt.timers.textboxanim_out then return true end	-- cannot proceed yet
			if evt.timers.choices then return true end	-- yoinks...


			-- quick hack to skip control characters:
			local curchar = txt:sub(evt.texttime, evt.texttime)
			local nextchar = txt:sub(evt.texttime+1, evt.texttime+1)

			-- set delay if the current character is one of these and if the last character is a space
			/*if (curchar == "," or curchar == "." or curchar == "?" or curchar == "!")
			and (nextchar == " " or nextchar == "\n")
			and not evt.textdelay
				evt.textdelay = 8
			end*/

			if evt.textdelay
				evt.textdelay = $-1
			end
			if not evt.textdelay
				evt.texttime = $+1
			end

			-- skip control characters.
			while txt:sub(evt.texttime, evt.texttime) and V_isControlChar(txt:sub(evt.texttime, evt.texttime))
				evt.texttime = $+1
			end

			if evt.texttime == txt:len()
			and cur[4]	-- there are choices
				evt.timers.choices = 8
				return true
			end

			if cur[4]	-- handle choice selection:
				if inputs["down"] == 1
					evt.choice = $+1
					S_StartSound(nil, sfx_hover)
					if evt.choice > #cur[4]
						evt.choice = 1
					end
				elseif inputs["up"] == 1
					evt.choice = $-1
					S_StartSound(nil, sfx_hover)
					if evt.choice < 1
						evt.choice = #cur[4]
					end
				end
			end

			if evflags & EV_AUTO	-- wait for text box
				if evt.texttime < txt:len() + 20
					inputs[BT_JUMP] = 0
				else
					inputs[BT_JUMP] = 1
				end
			end

			if inputs[BT_JUMP] == 1
				if evt.texttime < txt:len()
					evt.texttime = txt:len()
					if cur[4]
						evt.timers.choices = 8	-- bring up the choices.
					end
				else

					if cur[4]	-- in case of dialogue choices:
						S_StartSound(nil, sfx_confir)
						local newe = cur[4][evt.choice][2] or 0
						if cur[5]
							D_requestIndex(pn, newe)
						else
							evt.eventindex = newe
							evt.texttime = 0
						end
					else
						S_StartSound(nil, sfx_hover)
						-- in the case of text, 4 is for potential choices;
						-- 5 is whether or not we want a transition for the next box
						if cur[5]
							D_requestIndex(pn, evt.eventindex+1)
						else
							evt.eventindex = $+1	-- next
							evt.texttime = 0
						end
					end
				end
			end
		elseif cur[1] == "function"	-- execute a function.
			evt.ftimer = $ and $+1 or 1	-- function timer
			if cur[2](evt, battle)	-- makes acting on the tables easier.
				evt.eventindex = $+1
				evt.ftimer = 0
			end
		end

		-- event has been running
		return true
	end
end)

-- event buffer + event progression
--addHook("ThinkFrame", do

rawset(_G, "D_RunEvents", function()
	if not server return end

	-- loading an event frame 1 of any map would actually crash, so buffer it and start it whenever we can!
	-- besides, we need to wait for the end of the potential title card before we do anything
	if evt_buffer
	and server.P_DialogueStatus
	and server.entrytime
	and (server.entrytime < TICRATE/2 + 10)
		for i = 1, 4
			if evt_buffer[i]
				D_startEvent(i, evt_buffer[i][1], evt_buffer[i][2])
			end	
		end	
		evt_buffer = nil
	end

	if not server.P_BattleStatus return end
	for i = 1, 4
		local btl = server.P_BattleStatus[i]	-- Assumption: No multiplayer cutscenes
		-- always run events, unless we're in battle in which case we let the battle handler take care of it.
		if btl and btl.running return end
		D_eventHandler(i)
	end
end)