-- All events for the tutorial

-- @TODO: Maybe optimize some of this shit one day, it's kinda bad...
-- it doesn't matter too much given these functions only run for 1 frame but that doesn't excuse it

-- reminder:
-- {type, name, text, choices, next_anim, flags, portrait data}

eventList["ev_tut1"] = {

	[1] = {"text", "Amy", "Alright Sonic, let's get started!\nYou can move around with \x95 and jump with \x90.", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[2] = {"text", "Amy", "If you have no idea what these buttons are, you can open the menu with ESC and set your controls from the options menu.", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[3] = {"function",
				function(evt, btl)
					btl.items = {}	-- nope.
					return true
				end
			},
}

eventList["ev_tut2"] = {

	[1] = {"text", "Amy", "You can turn using the mouse.\nThink of it a bit like a Third Person Shooter?", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
}

eventList["ev_tut3"] = {

	[1] = {"text", "Amy", "After jumping, you can press \x90 again to use your \x82".."ability\x80.", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[2] = {"text", "Sonic", "Right. Mine's the\x82 Jump Dash\x80.\nI can use it to cross that kind of gap!", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE}},
}

eventList["ev_tut4"] = {
	[1] = {"function",
		function(evt, battle)

			-- this is a bit hacky, this makes the next battle do what we want.
			-- usually we would call a battle directly from an event but this just won't work here,
			-- the goal being to let the player initiate the battle from themselves

			battle.event_buf = "ev_tut5"
			battle.eventcount = 0
			-- this will be played when that next battle ends.

			battle.func_buf = function(btl)
				-- load a function in the event function buffer.
				-- this will be passed to the next battle that runs (in the tutorial's case, the first regular enemy)

				btl.eventcount = $ or 0

				if btl.turn <= 1
				and not server.P_DialogueStatus[btl.n].running	-- don't keep resetting it.
				and btl.eventcount == 0
					D_startEvent(btl.n, "ev_tut_battle1")
					-- explain how to use skills, amy will set her thinker to always use garu with this.
					btl.eventcount = $+1
				end

				if btl.turn == 2	-- first turn over
				and not server.P_DialogueStatus[btl.n].running
				and btl.eventcount == 1
					D_startEvent(btl.n, "ev_tut_battle2")
					-- amy explains differences between physical and magic skills.
					-- then she says that you must be ressourceful and finish the enemies off with physical attacks
					btl.eventcount = $+1
				end
			end

			return true
		end},

	[2] = {"text", "Sonic", "...!\nOver there!", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE}},
	[3] = {"function",
		function(evt, battle)

			if evt.ftimer == 1

				evt.usecam = true
				for mt in mapthings.iterate do	-- fetch awayviewmobj

					local m = mt.mobj
					if not m or not m.valid continue end

					if m and m.valid and m.type == MT_ALTVIEWMAN
					and mt.extrainfo == 1

						local cam = battle.cam
						P_TeleportMove(cam, m.x, m.y, m.z)
						cam.angle = m.angle
						cam.aiming = -ANG1*2
						CAM_goto(cam, cam.x, cam.y, cam.z)
						CAM_angle(cam, cam.angle)
						CAM_aiming(cam, cam.aiming)
						break
					end
				end
			elseif evt.ftimer == TICRATE
				return true
			end
		end},

		[4] = {"text", "Sonic", "It's a\x85 Shadow\x80!", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE}},
		[5] = {"text", "Sonic", "Right, all we have to do to fight it is just \x82jumping on it!", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE}},
		[6] = {"text", "Sonic", "Let's get this party started!", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE}},

}

eventList["ev_tut_battle1"] = {
	[1] = {"text", "Amy", "They look fairly weak!\nWe should be able to use our \x82Personas\x80 to take care of them.", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[2] = {"text", "Amy", "Use up/down to select the \x82Skill\x80 option with the \x90 button.", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[3] = {"text", "Amy", "Then up/down to select which skill you want to use, and left/right to choose your target!", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[4] = {"text", "Amy", "The skill will be immediately used after you press \x90, and your turn will be over.", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[5] = {"text", "Amy", "Did you catch all of that?", {{"Yes", 6}, {"No", 2}}, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[6] = {"text", "Amy", "Alright then! Let's show them what we're made of!", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[7] = {"function",
				function(evt, battle)

					-- close the door outside of the battle
					P_LinedefExecute(1001)

					for i = 1, #server.plentities[1]
						server.plentities[1][i].commandflags = CDENY_ATTACK|CDENY_PERSONA|CDENY_TACTICS|CDENY_ITEM|CDENY_GUARD

						if i == 1
							server.plentities[1][i].skills = {"agi"}	-- no lunge.
						end

						if i == 2	-- make up a thinker for amy.

							server.plentities[1][i].thinker = function(mo)

								local skill = attackDefs["garu"]	-- always use garu.
								local targets = {mo.enemies[1]}
								-- always target the enemy with highest HP
								for j = 1, #mo.enemies
									if mo.enemies[j].hp > targets[1].hp
										targets = {mo.enemies[j]}
									end
								end

								return skill, targets
							end
						end
					end
					return true
				end,
		},

}


eventList["ev_tut_battle2"] = {
	[1] = {"text", "Amy", "Great moves!", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[2] = {"text", "Amy", "Skills are quite powerful, but they cost resources!", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[3] = {"text", "Amy", "Magic skills have elemental affinities as well as high accuracy. They cost a fixed amount of \x81SP\x80 to use.", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[4] = {"text", "Amy", "Physical skills, however, cost you a portion of your \x88HP\x80. They have lower accuracies, but hit harder!", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[5] = {"text", "Amy", "Our enemies are weak now.\nIt might be a bit... overkill to use \x82skills.\x80", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[6] = {"text", "Amy", "Let's use a regular \x82physical attack\x80 to finish the job!", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},

	[7] = {"function",
				function(evt, battle)

					for i = 1, #server.plentities[battle.n]
						server.plentities[battle.n][i].commandflags = CDENY_SKILL|CDENY_PERSONA|CDENY_TACTICS|CDENY_ITEM|CDENY_GUARD

						if i == 2	-- make up a thinker for amy.

							server.plentities[battle.n][i].thinker = function(mo)

								local skill = attackDefs["amy_atk1"]	-- always use garu.
								local targets = {mo.enemies[1]}
								-- always target the enemy with highest HP
								for j = 1, #mo.enemies
									if mo.enemies[j].hp > targets[1].hp
										targets = {mo.enemies[j]}
									end
								end

								return skill, targets
							end
						end
					end
					return true
				end,
		},

}

-- post battle event:
eventList["ev_tut5"] = {

	[1] = {"text", "Amy", "That went really well!", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[2] = {"text", "Amy", "Though, we took some hits.", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[3] = {"text", "Amy", "Good thing we can use \x82healing skills\x80 outside of battles!", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[4] = {"text", "Amy", "Just press \x91 to open the menu, and then select \x82skills\x80.", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[5] = {"text", "Amy", "Then, select who to use it on with left and right, and tap \x90 to use it!", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[6] = {"text", "Amy", "\x82I'm the only one here with a healing skill.\x80 So if you ask me to use it, it will consume some of \x82my SP\x80.", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[7] = {"text", "Amy", "We won't be able to proceed until ".."\x82".."both of us are fully healed. \x80So you know what to do!", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[8] = {"text", "Amy", "Need me to reexplain some stuff?", {{"I'm good!", 9}, {"...Actually, yeah", 4}}, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[9] = {"text", "Amy", "Alright, let's get going, then!", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},

	[10] = {"function",
				function(evt, btl)
					-- enable the hp check linedef
					SAVE_localtable.hpchecklinedef = true	-- this is a one-off flag.
					return true
					-- it will be purged on map load
				end
			},
}

addHook("MapLoad", function()
	if SAVE_localtable.hpchecklinedef
		SAVE_localtable.hpchecklinedef = nil
	end
end)

-- linedef executor for checking if we've healed
-- only ever used in tutorial if SAVE_localtable.hpchecklinedef is set

addHook("LinedefExecute", function(l, mo)
	if SAVE_localtable.hpchecklinedef
		-- execute specified tag:
		if mo and mo.player

			if mo.player.maincontrol and mo.player.maincontrol.allies
				for i = 1, #mo.player.maincontrol.allies
					local a = mo.player.maincontrol.allies[i]
					if a.hp < a.maxhp
						return	-- bad!
					end
				end

				P_LinedefExecute(l.tag)
				SAVE_localtable.hpchecklinedef = nil	-- kill that ld

			end
		end
	end
end, "P_TUTORIAL_HPCHECK")


eventList["ev_tut6"] = {

	[1] = {"function",
		function(evt, battle)

			if evt.ftimer == 1

				evt.usecam = true
				for mt in mapthings.iterate do	-- fetch awayviewmobj

					local m = mt.mobj
					if not m or not m.valid continue end

					if m and m.valid and m.type == MT_ALTVIEWMAN
					and mt.extrainfo == 2

						local cam = battle.cam
						P_TeleportMove(cam, m.x, m.y, m.z)
						cam.angle = m.angle
						cam.aiming = -ANG1*2
						CAM_goto(cam, cam.x, cam.y, cam.z)
						CAM_angle(cam, cam.angle)
						CAM_aiming(cam, cam.aiming)
						break
					end
				end
			elseif evt.ftimer == TICRATE
				return true
			end
		end},

	[2] = {"text", "Sonic", "Another one! \nLet's wreck it!", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE}},
	[3] = {"text", "Amy", "Hold on!", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[4] = {"text", "Amy", "Rushing headfirst into battle isn't always a good idea!", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[5] = {"text", "Amy", "We could get the \x82upper hand\x80 in battle if we can strike the enemy when they \x82".."don't expect it!", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[6] = {"text", "Sonic", "So... by".."\x82".." attacking it from the back?", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE}},
	[7] = {"text", "Amy", "That's right! Just jump on it with \x90 while it isn't looking at us!", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[8] = {"text", "Amy", "Unlike that first enemy we fought, this one can actually \x82see us.".."\x80", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[9] = {"text", "Amy", "It will \x82".."attack us on sight!", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[10] = {"text", "Amy", "If it attacks us while we aren't prepared, \x82it will get the upper hand instead!", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[11] = {"text", "Amy", "So think twice before you engage!", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[12] = {"text", "Amy", "Did you understand everything?", {{"All of it!", 13}, {"...Not quite", 4}}, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[13] = {"text", "Amy", "Alright!\nTry to get the upper hand for this fight!", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},

	[14] = {"function",
		function(evt, battle)

			-- this is a bit hacky, this makes the next battle do what we want.
			-- usually we would call a battle directly from an event but this just won't work here,
			-- the goal being to let the player initiate the battle from themselves

			server.P_DungeonStatus.section = $+1	-- arbitrarily skip to "section 2" for new waves
			DNG_updateWave()						-- update the wave accordingly

			battle.event_buf = "ev_tut7"
			battle.eventcount = 0
			-- this will be played when that next battle ends.

			battle.func_buf = function(btl)
				-- load a function in the event function buffer.
				-- this will be passed to the next battle that runs (in the tutorial's case, the first regular enemy)

				btl.eventcount = $ or 0

				if btl.turn <= 1
				and not server.P_DialogueStatus[btl.n].running	-- don't keep resetting it.
				and btl.eventcount == 0
					if btl.advantage == 1
						D_startEvent(btl.n, "ev_tut_battle_advgood")
					elseif btl.advantage == 2
						D_startEvent(btl.n, "ev_tut_battle_advbad")
					else
						D_startEvent(btl.n, "ev_tut_battle_advok")
					end

					-- explain how to use skills, amy will set her thinker to always use garu with this.
					btl.eventcount = $+1

				elseif btl.turnorder[1].enemy	-- enemies don't do nothing.
					return

				elseif btl.advantage == 2	-- disadvantage, trigger the first cutscene AFTERWARDS.
					D_startEvent(btl.n, "ev_tut_battle5")
					btl.advantage = 0	-- hack.

				elseif btl.eventcount == 1	-- after 1st 1more
				and not server.P_DialogueStatus[btl.n].running
					D_startEvent(btl.n, "ev_tut_battle6")
					btl.eventcount = $+1

				elseif btl.eventcount == 2	-- after 2nd 1more
				and not server.P_DialogueStatus[btl.n].running
					D_startEvent(btl.n, "ev_tut_battle7")
					btl.eventcount = $+1

				elseif btl.eventcount == 3	-- after baton pass
				and not server.P_DialogueStatus[btl.n].running
					D_startEvent(btl.n, "ev_tut_battle8")
					btl.eventcount = $+1
				end

				/*if btl.turn == 2	-- first turn over
				and not server.P_DialogueStatus.running
				and btl.eventcount == 1
					D_startEvent("ev_tut_battle4")
					-- amy explains differences between physical and magic skills.
					-- then she says that you must be ressourceful and finish the enemies off with physical attacks
					btl.eventcount = $+1
				end*/
			end

			return true
		end},
}

eventList["ev_tut_battle_advgood"] = {
	[1] = {"text", "Amy", "Great moves! We got the advantage!", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[2] = {"function",
			function(evt, btl)
				D_startEvent(btl.n, "ev_tut_battle5")
				--return true
			end
		},
}

eventList["ev_tut_battle_advbad"] = {
	[1] = {"text", "Amy", "Yikes...!\nBrace yourself, here they come!", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	/*[2] = {"function",
			function()
				D_startEvent("ev_tut_battle5")
				--return true
			end
		},*/
}

eventList["ev_tut_battle_advok"] = {
	[1] = {"text", "Amy", "I suppose this makes it an even playing ground!", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[2] = {"function",
			function(evt, btl)
				D_startEvent(btl.n, "ev_tut_battle5")
				--return true
			end
		},
}

eventList["ev_tut_battle5"] = {
	[1] = {"text", "Amy", "Anyway, we should talk about \x82".."attack affinities\x80, now.", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[2] = {"text", "Amy", "Each of our \x82skills\x80 have a \x82type\x80. For instance, you can use Agi, a \x82".."fire type\x80 skill.", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[3] = {"text", "Amy", "Every Shadow we fight has different \x82".."elemental affinities\x80.", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[4] = {"text", "Amy", "Some might be neutral to fire, others may be weak to it or resist it.", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[5] = {"text", "Amy", "I can tell you for sure all of these here are \x82weak to fire\x80. Give it a shot!", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},

	[6] = {"function",
			function(evt, battle)

				-- close the door outside of the battle
				P_LinedefExecute(2000)

				for i = 1, #server.plentities[1]
					server.plentities[1][i].commandflags = CDENY_ATTACK|CDENY_PERSONA|CDENY_TACTICS|CDENY_ITEM|CDENY_GUARD

					if i == 1
						server.plentities[1][i].skills = {"agi"}	-- no lunge.
					end


					if i == 2	-- make up a thinker for amy.

						server.plentities[1][i].thinker = function(mo)

							local skill = attackDefs["garu"]	-- always use garu.
							local targets = {mo.enemies[1]}
							-- always target the enemy with highest HP
							for j = 1, #mo.enemies
								if mo.enemies[j].hp > targets[1].hp
									targets = {mo.enemies[j]}
								end
							end

							return skill, targets
						end
					end
				end
				return true
			end,
		},

}

-- after 1more
eventList["ev_tut_battle6"] = {
	[1] = {"text", "Amy", "That was awesome!", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[2] = {"text", "Amy", "Everytime you hit an enemy's weakness, you will knock them down.", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[3] = {"text", "Amy", "If the enemy wasn't already down, this will earn you \x82".."another turn to attack!\x80 This is called a 1More.", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[4] = {"text", "Amy", "So go ahead! Use your extra turn to knock down another enemy!", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[5] = {"function",
			function(evt, battle)

				for i = 1, #server.plentities[battle.n]
					server.plentities[battle.n][i].commandflags = CDENY_ATTACK|CDENY_PERSONA|CDENY_TACTICS|CDENY_ITEM|CDENY_GUARD|CDISABLE_BATONPASS
				end
				return true
			end,
		},

}

-- after 2nd 1more
eventList["ev_tut_battle7"] = {
	[1] = {"text", "Amy", "So long as you can keep knocking enemies down, you can keep attacking!", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[2] = {"text", "Amy", "However, if you keep attacking on your own, you'll use up a lot of \x81SP\x80.", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[3] = {"text", "Amy", "Whenever you get a 1More, you can \x82pass your turn to someone who hasn't had theirs yet!\x80 This is a Baton Pass.", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[4] = {"text", "Amy", "Passing your turn to an ally will \x82increase their attack and healing power\x80.", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[5] = {"text", "Amy", "Since you're the fastest, you'll often attack first. Pass your extra turns to conserve your \x81SP\x80!", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},

	[6] = {"text", "Amy", "You can use Baton Pass by pressing \x91 after a 1More when you can act again. From there, just select which ally to pass to.", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[7] = {"text", "Amy", "Was I clear so far?", {{"Got it!", 8}, {"Nope...", 1}}, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[8] = {"text", "Amy", "Alright then! Pass me your turn!", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},

	[9] = {"function",
			function(evt, battle)

				for i = 1, #server.plentities[battle.n]
					server.plentities[battle.n][i].commandflags = CDENY_ATTACK|CDENY_PERSONA|CDENY_TACTICS|CDENY_ITEM|CDENY_GUARD|CDENY_SKILL
				end
				return true
			end,
		},

	--[2] = {"text", "Amy", "If we can get \x82".."every enemy down\x80, we can all attack together with a powerful \x82".."All-Out Attack!", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
}

eventList["ev_tut_battle8"] = {
	[1] = {"text", "Amy", "Thanks for that, I got it!", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[2] = {"text", "Amy", "Right, I should warn you. Everything we can do to enemies, \x82they can also do to us\x80.",  nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[3] = {"text", "Amy", "If they can hit our weaknesses, they can knock us down and get extra attacks too!", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[4] = {"text", "Amy", "This is why you should pay attention who you go along with in a team, avoid teams with samey weaknesses.", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[5] = {"text", "Amy", "You can always check your party's affinities as you're selecting characters, or through the party menu.", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[6] = {"text", "Amy", "...There is one thing only us can do to enemies however!", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[7] = {"text", "Amy", "If we can knock every enemy down, we can all launch a coordinated \x82".."All-Out Attack!", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[8] = {"text", "Amy", "Here, let me show you!", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
}

-- post battle event:
eventList["ev_tut7"] = {

	[1] = {"text", "Sonic", "That was tight!", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE}},
	[2] = {"text", "Amy", "Sure was!", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[3] = {"text", "Amy", "All-Out Attacks are generally strong enough to finish off enemies.", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[4] = {"text", "Amy", "...But don't take that for granted, some enemies are tough enough to whistand them.", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},

	[5] = {"text", "Amy", "Okay, for our next lesson, I'll be your opponent.", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},

	[6] = {"function",
			function(evt, battle)

				-- remove amy from current party
				PLYR_RemoveFromParty(battle.n, 2)	-- amy will always be at index 2 for this specific thing
				server.plentities[battle.n][1].hp = server.plentities[1][1].maxhp	-- heal sonic

				-- select wave:
				local wave = {"amy_tutorial"}

				-- start battle
				local team_1 = server.plentities[1]
				local team_2 = {}
				for i = 1,#wave
					local enm = P_SpawnMobj(0, 0, 0, MT_PFIGHTER)
					enm.state = S_PLAY_STND
					enm.tics = -1
					enm.enemy = wave[i]
					team_2[#team_2+1] = enm
				end

				battle.eventcount = 0

				local dummyfunc = function(btl)

					btl.eventcount = $ or 0

					if btl.turn <= 1
					and not server.P_DialogueStatus[btl.n].running	-- don't keep resetting it.
					and btl.eventcount == 0
						D_startEvent(btl.n, "ev_tut_battle9")
						btl.eventcount = $+1

					elseif btl.eventcount >= 1
					and btl.eventcount < 3	-- wait...
					and not server.P_DialogueStatus[btl.n].running
						btl.eventcount = $+1

					elseif btl.eventcount == 3
					and not server.P_DialogueStatus[btl.n].running	-- don't keep resetting it.
						D_startEvent(btl.n, "ev_tut_battle10")		-- amy prompts you to guard
						btl.eventcount = $+1

					elseif btl.eventcount == 4
					and not server.P_DialogueStatus[btl.n].running	-- don't keep resetting it.
						btl.eventcount = $+1

					elseif btl.eventcount == 5
					and not server.P_DialogueStatus[btl.n].running	-- don't keep resetting it.
						D_startEvent(btl.n, "ev_tut_battle11")		-- nice guard, introduction to subpersonas
						btl.eventcount = $+1

					elseif btl.eventcount == 6
					and not server.P_DialogueStatus[btl.n].running	-- don't keep resetting it.
						D_startEvent(btl.n, "ev_tut_battle12")		-- nice guard, introduction to subpersonas
						btl.eventcount = $+1

					elseif btl.eventcount == 7
					and not server.P_DialogueStatus[btl.n].running	-- don't keep resetting it.
						btl.eventcount = $+1

					elseif btl.eventcount == 8
					and not server.P_DialogueStatus[btl.n].running	-- don't keep resetting it.
						D_startEvent(btl.n, "ev_tut_battle13")		-- final event.
						btl.eventcount = $+1

					end
					--print(btl.eventcount)

				end

				server.diffculty = 0	-- make sure we get no emerald drive skill
				BTL_StartBattle(1, team_1, team_2, 0, dummyfunc, nil, "BATL1")
				battle.emeraldpow_max = 1	-- override the difficulty setting
				return true
			end,
		},
}

eventList["ev_tut_battle9"] = {
	[1] = {"text", "Amy", "Alright Sonic, show me your best shot!", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[2] = {"function",
			function(evt, battle)

				for i = 1, #server.plentities[1]
					server.plentities[battle.n][i].commandflags = CDENY_ATTACK|CDENY_PERSONA|CDENY_TACTICS|CDENY_ITEM|CDENY_GUARD

					if i == 1
						server.plentities[battle.n][i].skills = {"agi"}	-- no lunge.
					end
				end
				return true
			end,
		},
}

eventList["ev_tut_battle10"] = {
	[1] = {"text", "Amy", "Enemies can really do a number on you if they figure out your weakness!", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[2] = {"text", "Amy", "If you know an enemy can target your weakness, you should try \x82guarding\x80.", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[3] = {"function",
			function(evt, battle)

				for i = 1, #server.plentities[battle.n]
					server.plentities[battle.n][i].commandflags = CDENY_ATTACK|CDENY_PERSONA|CDENY_TACTICS|CDENY_ITEM|CDENY_SKILL
				end
				return true
			end,
		},
}

-- use a sub persona
eventList["ev_tut_battle11"] = {
	[1] = {"text", "Amy", "See? Barely even a scratch!", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[2] = {"text", "Amy", "Guarding reduces the damage and \x82prevents you from being knocked down.\x80", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[3] = {"text", "Amy", "Be careful though, guarding will only work against \x82one attack per turn.\x80", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},

	[4] = {"text", "Sonic", "Hold on a sec, I know you know my elemental weakness, but...", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE}},
	[5] = {"text", "Sonic", "Where did you learn to use Eiha? Don't you specialize in \x82wind type skills?\x80", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE}},

	[6] = {"text", "Amy", "I got that skill from a \x82Sub-Persona.", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[7] = {"text", "Amy", "They can \x82".."alter your skills and statistics.", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[8] = {"text", "Amy", "Here, I'll lend you one!", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[9] = {"text", "Amy", "Navigate to the \x82Sub-Persona menu\x80 and use its \x82Zio\x80 skill on me!", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},

	[10] = {"function",
			function(evt, btl)

				btl.tutorial_zio = true	-- special flag that prevents using Agi
				BTL_logMessage(1, "Got the Sub-Persona \x82Pixie\x80!")
				btl.subpersonas[#btl.subpersonas+1] = P_generateSubPersona("pixie")

				for i = 1, #server.plentities[btl.n]
					server.plentities[btl.n][i].commandflags = CDENY_ATTACK|CDENY_TACTICS|CDENY_ITEM|CDENY_GUARD
				end
				return true
			end,
		},
}

-- compliments
eventList["ev_tut_battle12"] = {
	[1] = {"text", "Amy", "Youch, that hurt...!", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[2] = {"text", "Amy", "Sub-Personas are a powerful tool, but \x82pay attention to the stat changes.\x80", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[3] = {"text", "Amy", "This isn't really a problem with weaker Sub-Personas, but...", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[4] = {"text", "Amy", "Stronger Sub-Personas yield bigger stat changes,\x82".." both positive and negative.", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},

	[5] = {"text", "Sonic", "How do you get one, though?", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE}},
	[6] = {"text", "Amy", "I got mine after \x82".."finishing a battle with an All-Out Attack!", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},

	[7] = {"text", "Sonic", "By the way... I can feel the \x82".."Chaos Emerald\x80 again!", nil, nil, nil, {"H_SONAOA", SKINCOLOR_BLUE}},
	[8] = {"text", "Amy", "That's good!", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[9] = {"text", "Amy", "The Emeralds have no power on their own during the Dark Hour.", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[10] = {"text", "Amy", "You can charge their power by \x82".."dealing damage or guarding.", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[11] = {"text", "Amy", "You'll get more energy by hitting \x82weaknesses or critical hits.", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},

	[12] = {"text", "Amy", "With at least 1 unit of Emerald Power, you can \x82".."activate Hyper Mode", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[13] = {"text", "Amy", "Try it out! Activate it with \x92 and use Zio on me again!", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},

	[14] = {"function",
			function(evt, battle)
				battle.tutorial_hyper = true
				battle.emeraldpow = 100	-- just in case
				return true
			end
	}
}

eventList["ev_tut_battle13"] = {
	[1] = {"text", "Amy", "Hyper Mode's stat increase isn't really as good as guarding.", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[2] = {"text", "Amy", "But it prevents you from being knocked down!", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[3] = {"text", "Amy", "This makes it really good if you want to keep attacking in spite of your weaknesses.", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[4] = {"text", "Amy", "Multiple people can use Hyper Mode at the same time so long as they can activate it.", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[5] = {"text", "Amy", "But charging the energy becomes harder for each simultaneous activation, so keep that in mind!", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[6] = {"text", "Amy", "You may also find that some skills require \x83".."Emerald Power\x80 instead of \x88HP\x80 or \x81SP\x80.", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[7] = {"text", "Amy", "So it's up to you to figure out how you want to use your \x83".."Emerald Power\x80!", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[8] = {"text", "Amy", "Lastly, because Emeralds only seem to respond to combat tension, \x82".."all of their power is lost once the battle ends.", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[9] = {"text", "Amy", "So don't be afraid to make use of what power you have available during fights!", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},

	[10] = {"text", "Amy", "There, this is about all that I could teach you!", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[11] = {"text", "Amy", "Of course, these are merely the basics, and there's a lot more for you to figure out.", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},
	[12] = {"text", "Amy", "But I'm sure you'll manage so long as you understood these basics!", nil, nil, nil, {"H_AMYAOA", SKINCOLOR_ROSY}},

	[13] = {"function",

				function(evt, battle)
					SAVE_localtable.tutorial = nil
					COM_ImmedExecute("exitgame")

					-- tutorial status cleared on a mapload in EventHandler.LUA
					-- battle tutorial status will be cleared regardless when a new battle status is created.
				end
			}
}


