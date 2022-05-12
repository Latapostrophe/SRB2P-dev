-- Velvet Room fusion stuff

local fusion_states = {
	
	"FS_MAIN",				-- Selecting fusion type
	
	"FS_NOTENOUGH",			-- Not enough subPs
	
	"FS_NORMAL",			-- Normal Spread	
	"FS_TRIANGLE",			-- Triangle Spread
	"FS_CROSS",				-- Cross Spread
	
	"FS_PREVIEW",			-- Previews the Sub-Persona
	"FS_SKILLVIEW",			-- Checking skills.
	
	"FS_SKILLCARD",			-- Ask to use a Skill Card
	"FS_INHERIT",			-- Choose inherited skills
	
	"FS_CONFIRM",			-- Ask if all this is fine
	
	"FS_FUSIONANIM",		-- Fusion animation event
	
	"FS_FUSED",				-- Persona has been fused...
	"FS_EXP",				-- Give the EXP to the persona, this may include levelling it up / replacing skills...
	"FS_REPLACESKILL",		-- prompt to replace skill.
	
	-- CPMPENDIUM
	"FS_COMPENDIUMMAIN",
	
	"FS_COMPENDIUM",			-- Select subP in compendium
	"FS_COMPENDIUMCONFIRM",		-- Asking for confirmation
	"FS_COMPENDIUMFULL",		-- Too many SubPersonas, can't summon from compendium.
	
	"FS_REGISTER",
	"FS_REGISTERCONFIRM",		-- Ask to make sure
	"FS_REGISTERCONFIRMALL",	-- Register all Personas.
	
	"FS_LEAVE",				-- Leaving	
}

for i = 1, #fusion_states
	rawset(_G, fusion_states[i], i)
end

local textdata = {

		welcome = {		-- On main shop page
			{"Alt", "What are we fusing today?", "H_ALT01", SKINCOLOR_BLUE},
			{"Alt", "Got a strong Persona in mind?", "H_ALT01", SKINCOLOR_BLUE},
			{"Alt", "Show me these cards...!", "H_ALT01", SKINCOLOR_BLUE},
		},

		bye = {
			{"Alt", "Catch ya later.", "H_ALT01", SKINCOLOR_BLUE},
		},

		-- Spread
		fusion_persona1 = {
			
			{"Alt", "Alright, pick your first Persona...", "H_ALT01", SKINCOLOR_BLUE},
			{"Alt", "Let's begin... Pick your first Persona.", "H_ALT01", SKINCOLOR_BLUE},
			
		},

		fusion_persona2 = {
			
			{"Alt", "Now the second one...", "H_ALT01", SKINCOLOR_BLUE},
			
		},

		fusion_persona3 = {
			
			{"Alt", "The third one...", "H_ALT01", SKINCOLOR_BLUE},
			
		},

		fusion_personalast = {
			
			{"Alt", "And the last one.", "H_ALT01", SKINCOLOR_BLUE},
			{"Alt", "And the final Persona...", "H_ALT01", SKINCOLOR_BLUE},
			
		},

		-- Attempting to fuse a Persona above the player's level
		fusion_highlevel = {
			
			{"Alt", "Take it from me, you wouldn't be able to handle that one.", "H_ALT01", SKINCOLOR_BLUE},
			{"Alt", "I'm afraid this is... too high level for you.", "H_ALT01", SKINCOLOR_BLUE},
			{"Alt", "Sorry, I can't allow you to get that one. It's for your own good...", "H_ALT01", SKINCOLOR_BLUE},
			
		},
		
		-- Result
		fusion_preview = {
			
			{"Alt", "Is this what you want?", "H_ALT01", SKINCOLOR_BLUE},
			{"Alt", "That looks like a good one... Settled on it?", "H_ALT01", SKINCOLOR_BLUE},
			
		},

		-- Low level Persona... (-10+ levels compared to player)
		fusion_previewlow = {
			
			{"Alt", "Are you sure you want... that one...?", "H_ALT05", SKINCOLOR_BLUE},
			{"Alt", "Is that really going to be of use to you...?", "H_ALT05", SKINCOLOR_BLUE},
			
		},
		
		fusion_skillview = {
			{nil, "Viewing Skills. Press \x91 to exit.", nil, nil}
		},

		fusion_skillcard = {
			
			{"Alt", "Wanna use a Skill Card? It'll cost you a bit.", "H_ALT01", SKINCOLOR_BLUE},
			{"Alt", "I can use a Skill Card on it for you... In exchange of some Macca, of course...", "H_ALT02", SKINCOLOR_BLUE},
		},

		fusion_broke = {
			
			{"Alt", "Er, you can't afford that...", "H_ALT05", SKINCOLOR_BLUE},
			{"Alt", "You're broke...", "H_ALT04", SKINCOLOR_BLUE},
		},

		fusion_inherit = {
			
			{"Alt", "What Skills should we inherit?", "H_ALT01", SKINCOLOR_BLUE},
			{"Alt", "Select the Skills to inherit.", "H_ALT01", SKINCOLOR_BLUE},
		},
		
		fusion_finalconfirm = {
			{"Alt", "I'm ready for the fusion. Is everything the way you wanted it to be?", "H_ALT01", SKINCOLOR_BLUE},
			{"Alt", "Is this the Persona you wanted?", "H_ALT01", SKINCOLOR_BLUE},		
		},
		
		fusion_done = {
			
			{"Alt", "And there you have it!", "H_ALT02", SKINCOLOR_BLUE},
			{"Alt", "I'm pretty good at this, aren't I?", "H_ALT02", SKINCOLOR_BLUE},
		},

		fusion_chooseforget = {
			
			{nil, "This Sub-Personas has too many skills. Select the Skill to replace with the new Skill, or press \x91 to give up learning the new Skill."},
		},

		fusion_replaceskill = {
			
			{nil, "The selected Skill will be permanently forgotten and replaced, is this OK?"},
		},

		fusion_relentskill = {
			
			{nil, "The skill will not be learnt. Is this OK?"},
		},
			
		-- Attempting to select a fusion type when you don't have enough Personas
		fusion_nopersona = {
			{"Alt", "You don't have enough Personas for this...", "H_ALT05", SKINCOLOR_BLUE},
		},
		
		-- COMPENDIUM
		
		compendium_main = {
			{"Alt", "Are you checking the Compendium or registering Personas?", "H_ALT01", SKINCOLOR_BLUE},
			{"Alt", "Registering Personas? Or perhaps you want to buy some?", "H_ALT01", SKINCOLOR_BLUE},
		},

		compendium_empty = {
			{"Alt", "Uhm... The compendium's empty... Maybe try to fill it up first...", "H_ALT04", SKINCOLOR_BLUE},
			{"Alt", "There's nothing in the compendium...", "H_ALT04", SKINCOLOR_BLUE},
		},

		compendium_nopersonas = {
			{"Alt", "Uhm... You don't have any Sub-Persona...", "H_ALT04", SKINCOLOR_BLUE},
			{"Alt", "Did you forget to bring your Sub-Personas or...?", "H_ALT04", SKINCOLOR_BLUE},
		},
			
		compendium_check = {
			
			{"Alt", "Pick whatever you'd like...", "H_ALT01", SKINCOLOR_BLUE},
			{"Alt", "I even brought this right book this time!", "H_ALT01", SKINCOLOR_BLUE},
		},
		
		
		compendium_register = {
			{"Alt", "Which Persona should we register?", "H_ALT01", SKINCOLOR_BLUE},
			{"Alt", "What are you registering?", "H_ALT01", SKINCOLOR_BLUE},
		},		
}

local state_2_textdata = {


	[FS_MAIN] = "welcome",
	[FS_LEAVE] = "bye",
	
	[FS_NORMAL] = "fusion_persona1",
	[FS_TRIANGLE] = "fusion_persona1",
	[FS_CROSS] = "fusion_persona1",
	
	[FS_NOTENOUGH] = "fusion_nopersona",
	
	[FS_PREVIEW] = "fusion_preview",
	[FS_SKILLVIEW] = "fusion_skillview",
	
	[FS_SKILLCARD] = "fusion_skillcard",
	[FS_INHERIT] = "fusion_inherit",
	
	[FS_CONFIRM] = "fusion_finalconfirm",
	
	[FS_EXP] = "fusion_done",
	
	[FS_COMPENDIUMMAIN] = "compendium_main",
}

local function changetextdta(mo, t)
	if not mo.fusion return end
	mo.fusion.currtextdata = t[P_RandomRange(1, #t)]
	mo.fusion.texttimer = 1
end

rawset(_G, "DNG_startFusion", function(mo)

	M_closeMenu(mo)


	mo.fusion = {
		using = true,

		state = FS_MAIN,
		prevstate = FS_MAIN,

		curtextdata = {},
		textchoice = 1,
		maxtextchoice = 1,
		texttimer = 1,
		hudtimers = {},
		
		-- main menu
		mainchoice = 1,
		maxmainchoice = 5,
		
		-- persona selection
		personachoice = 2,
		personascroll = 0,
		
		maxpersonas = 2,	-- changes depending on fusion type
		personas = {},		-- used to store selected personas
		
		previewn = 0,		-- persona # to preview
		skilln = 1,			-- skill to check.
		
		-- skill cards
		skillcards = {},
		useskillcard = nil,
		selectcard = 1,
		cardscroll = 0,
		
		
		-- inheritance
		maxinherit = 2,
		inheritable = {},
		inherited = {},
		inheritselect = 1,
		inheritscroll = 0,
		
		-- fusion event data:
		evttimer = 0,
		
		-- exp / levelup...
		pexp = 200000,	-- EXP left to give
	}

	mo.fusion.hudtimers.enter = TICRATE/3	-- start
	mo.fusion.hudtimers.cardsin = TICRATE/3

	-- start the text box
	if textdata and textdata.welcome
		changetextdta(mo, textdata.welcome)
	end
end)

rawset(_G, "DNG_stopFusion", function(mo, nomenu)
	mo.fusion = {}	-- empty the table
	PLAY_move(mo.player)	-- allow the player to move again
	
	if not nomenu
		M_openMenu(mo, "m_selectfacility")
		return
	end
end)

local function handleTextChoices(mo)

	local inpt = mo.P_inputs
	--print(inpt)
	--print(inpt["up"])
	if inpt["up"] == 1
		mo.fusion.textchoice = $-1
		if not mo.fusion.textchoice
			mo.fusion.textchoice = mo.fusion.maxtextchoice
		end
		S_StartSound(nil, sfx_hover, mo.player)

	elseif inpt["down"] == 1
		mo.fusion.textchoice = $+1
		if mo.fusion.textchoice > mo.fusion.maxtextchoice
			mo.fusion.textchoice = 1
		end
		S_StartSound(nil, sfx_hover, mo.player)
	elseif inpt[BT_JUMP] == 1
		S_StartSound(nil, sfx_confir, mo.player)
		return mo.fusion.textchoice
	end
end

local function DNG_changeFSState(mo, state)

	if not mo.fusion return end
	if not mo.fusion.using return end
	if not state return end
	
	mo.fusion.prevstate = mo.fusion.state
	mo.fusion.state = state

	local tdata = textdata[state_2_textdata[state]]
	if tdata
		changetextdta(mo, tdata)
	end

	mo.fusion.hudtimers.newstate = TICRATE/3
	mo.fusion.textchoice = 1	-- reset
end

local state_2_textchoices = {
	[FS_PREVIEW] = 3,			-- Yes, View Skills, No
	[FS_REPLACESKILL] = 2,		-- Yes, No
	[FS_COMPENDIUMMAIN] = 2,	-- View Compendium, Register
}

local function resetCutsceneDta(mo)
	
	local e = mo.fusion
	local btl = server.P_BattleStatus[mo.player.P_party]
	
	e.evttimer = 0
	
	EVT_SetCamByAngle(btl, 0)
	btl.cam.aiming = -10*ANG1
	
	P_TeleportMove(e.npc, e.npc.savereset[1], e.npc.savereset[2], e.npc.savereset[3])
	e.npc.frame = e.npc.savereset[4]
	
	if e.cards
		for i = 1, #e.cards
			P_RemoveMobj(e.cards[i])
		end
	end
	
	if e.book and e.book.valid
		P_RemoveMobj(e.book)
	end	
	
	phud.clear("fusion")
	e.animdone = true
	e.cards = nil
	e.book = nil
end

rawset(_G, "DNG_handleFusion", function(mo)

	if not mo.fusion return end
	if not mo.fusion.using return end
	local btl = server.P_BattleStatus[mo.player.P_party]
	local inputs = mo.P_inputs
	local p = mo.player

	PLAY_nomove(mo.player)

	local e = mo.fusion

	-- iterate hud timers
	for k,v in pairs(e.hudtimers)
		if e.hudtimers[k]
			e.hudtimers[k] = $-1
		end
	end

	e.texttimer = $+1

	if state_2_textchoices[e.state]
		e.maxtextchoice = state_2_textchoices[e.state]
	end

	-- state handling:
	if e.state == FS_MAIN
		
		if e.hudtimers.alttext == 1
			changetextdta(mo, textdata.welcome)
		end
		
		if inputs["right"] == 1
			S_StartSound(nil, sfx_hover, p)
			
			e.mainchoice = $+1
			if e.mainchoice > e.maxmainchoice
				e.mainchoice = 1
			end	
			
		elseif inputs["left"] == 1
			S_StartSound(nil, sfx_hover, p)
			e.mainchoice = $-1
			if not e.mainchoice
				e.mainchoice = e.maxmainchoice
			end
		
		elseif inputs[BT_JUMP] == 1
			
			S_StartSound(nil, sfx_confir, p)
			
			-- Check if we have enough personas.
			local need = e.mainchoice +1
			if #btl.subpersonas < need
				
				S_StartSound(nil, sfx_not, p)
				changetextdta(mo, textdata.fusion_nopersona)
				e.hudtimers.alttext = TICRATE*3
			end
			
			-- otherwise, go ahead and open the menu.
			local choice_2_state = {
				
				FS_NORMAL,
				FS_TRIANGLE,
				FS_CROSS,
				FS_COMPENDIUMMAIN,
				FS_LEAVE,
				
			}
			
			mo.fusion.hudtimers.cardsout = TICRATE/3
			mo.fusion.hudtimers.openfirstmenu = TICRATE/3
			
			local c = choice_2_state[e.mainchoice]
			DNG_changeFSState(mo, c)
		end
	
	elseif e.state == FS_COMPENDIUMMAIN
		local choice = handleTextChoices(mo)
		
		if e.hudtimers.nocompendium == 1
			changetextdta(mo, textdata.compendium_main)
		end	
		
		if choice == 1
			
			local t = srb2p.storydata.compendium
			if not #t
				S_StartSound(nil, sfx_not, p)
				changetextdta(mo, textdata.compendium_empty)
				e.hudtimers.nocompendium = TICRATE*2
				return true
			end
			
		elseif choice == 2
			
			local t = btl.subpersonas
			if #t < 2
				S_StartSound(nil, sfx_not, p)
				changetextdta(mo, textdata.compendium_nopersonas)
				e.hudtimers.nocompendium = TICRATE*2
				return true
			end
			
		end
	
	elseif e.state == FS_NORMAL
		
		-- 6 subp on the page.
		local maxitems = 6
		local maxscroll = max(0, #btl.subpersonas-1 - maxitems)
		
		if inputs["down"] == 1
			S_StartSound(nil, sfx_hover, p)
			
			e.personachoice = $+1
			
			if e.personachoice-1 > maxitems/2 and e.personascroll < maxscroll
				e.personascroll = $+1
			end	
			
			if e.personachoice > #btl.subpersonas
				e.personachoice = 2
				e.personascroll = 0
			end
			
			
		elseif inputs["up"] == 1
			S_StartSound(nil, sfx_hover, p)
			
			if e.personascroll
				e.personascroll = $-1
			end	
			
			e.personachoice = $-1
			if e.personachoice < 2
				e.personachoice = #btl.subpersonas
				e.personascroll = maxscroll
			end	
			
		elseif inputs[BT_JUMP] == 1
			
			S_StartSound(nil, sfx_confir, p)
			-- check if that persona isn't added already
			local s = btl.subpersonas[e.personachoice]
			
			for i = 1, #e.personas do
				if e.personas[i] == s
					S_StartSound(nil, sfx_not, p)
					return true
				end
			end
			
			e.personas[#e.personas+1] = s
			
			if #e.personas == e.maxpersonas-1
				e.hudtimers.showresults = 5
			end
			
			if #e.personas == e.maxpersonas
				
				-- Fusion result & inheritance:
				-- @TODO: TRIANGLE AND CROSS FUSIONS
				
				-- Generate the result sub-persona
				local res = getFusionResult(e.personas[1].int, e.personas[2].int)
				if not res
					--print("what")
					-- this fusion leads to nothing...
					S_StartSound(nil, sfx_not, p)
					table.remove(e.personas, #e.personas)
				else
					e.personas[#e.personas+1] = P_generateSubPersona(res)
					
					-- Check how many skills we can inherit and build inheritance table.
					
					local result = e.personas[#e.personas]	-- result persona.
					local skilln = 0
					
					for i = 1, #e.personas-1
						local subp = e.personas[i]
						skilln = $ + #subp.skills
						
						for j = 1, #subp.skills
							-- Can we inherit that skill?
							if result.ref.weapontype	-- if the persona has no weapon type, don't attempt to inherit skills.
								local sk = attackDefs[subp.skills[j]]
								if not sk continue end
								
								-- check if the subp already has that skill...
								local dupe = false
								for k = 1, #result.skills
									if result.skills[k] == subp.skills[j]
										--print("(1)Dupe: "..result.skills[k])
										dupe = true
										break
									end	
								end
								
								-- Also check if we haven't already added that skill to begin with...
								if not dupe	-- no need to check if we've established it's a duplicate already.
									for k = 1, #e.inheritable
										if e.inheritable[k] == subp.skills[j]
											--print("(2)Dupe: "..e.inheritable[k])
											dupe = true
											break
										end	
									end
								end	
								
								-- If the skill is a passive or is in the inheritance table, then we can get it.
								-- don't add duplicates.
								
								if sk.type & ATK_PASSIVE or FUSION_inheritance[result.ref.weapontype][atk_constant_2_num[sk.type & ~ATK_PASSIVE]]
									if not sk.unique and not dupe
										e.inheritable[#e.inheritable+1] = subp.skills[j]
										--print(subp.skills[j])
									end	
								end
							end
						end
					end
					
					-- set how many skills can be inherited depending on the parents' total # of skills:
					
					if skilln >= 18
						e.maxinherit = 6
					elseif skilln >= 16
						e.maxinherit = 5
					elseif skilln >= 14
						e.maxinherit = 4
					elseif skilln >= 9
						e.maxinherit = 3
					elseif skilln >= 5
						e.maxinherit = 2
					else
						e.maxinherit = 1
					end	
					
					e.previewn = #e.personas	-- ready the preview window on the last persona (the result)
					-- change state to preview.
					
					e.hudtimers.closefusion = TICRATE/3
					e.hudtimers.startpreview = TICRATE/3
					
					DNG_changeFSState(mo, FS_PREVIEW)
				end
				
			elseif #e.personas == e.maxpersonas-1
				changetextdta(mo, textdata.fusion_personalast)
			else	
				changetextdta(mo, textdata["fusion_persona"..(#e.personas+1)])
			end	
			
			
		elseif inputs[BT_USE] == 1
			
			S_StartSound(nil, sfx_cancel, p)
			
			if #e.personas
				table.remove(e.personas, #e.personas)
				changetextdta(mo, textdata["fusion_persona"..(#e.personas+1)])
				
				if #e.personas == e.maxpersonas-2
					e.hudtimers.removeresults = 5
					--print("A")
				end
			else
				DNG_changeFSState(mo, FS_MAIN)
				e.hudtimers.cardsin = TICRATE/3
				e.hudtimers.closefirstmenu = TICRATE/3
			end
		end
		
	elseif e.state == FS_PREVIEW
	or e.state == FS_CONFIRM
		
		if server.fadedta return true end	-- wait until the fade is over.
		
		local choice = handleTextChoices(mo)
		
		if inputs[BT_WEAPONNEXT] == 1
			S_StartSound(nil, sfx_turn, p)
			e.previewn = $+1
			
			if e.previewn > #e.personas
				e.previewn = 1
			end	
			
		elseif inputs[BT_WEAPONPREV] == 1
			S_StartSound(nil, sfx_turn, p)
			e.previewn = $-1
			
			if e.previewn < 1
				e.previewn = #e.personas
			end
		end
		
		if choice == 1	-- Yes
			
			if e.state == FS_PREVIEW
				-- Make a list of all the skill cards we have...
				e.skillcards = {{nil, nil}}
				for i = 1, #btl.items do
					
					local def = itemDefs[btl.items[i][1]]
					if not def continue end
					
					if def and def.skillcard
						-- check if the persona doesn't already have that skill...
						local subp = e.personas[#e.personas]
						local dupe
						
						for j = 1, #subp.skills
							if subp.skills[j] == def.skill
								dupe = true
								break
							end	
						end
						
						if not dupe
							e.skillcards[#e.skillcards+1] = {btl.items[i][1], i}
						end	
					end
				end
				
				if #e.skillcards > 1	-- 1 because the 1st option is always the "don't use skill cards" thing.
					e.previewn = #e.personas	-- Make sure to change that.
					e.cardscroll = 0
					e.hudtimers.skillcardsin = 7
					DNG_changeFSState(mo, FS_SKILLCARD)
				else
					-- We have no skill card, skip straight to skill inheritance.
					-- @TODO: later...
				end
			
			elseif e.state == FS_CONFIRM
				DNG_fade(
					function()
						-- setup the fusion anim.
						
						-- move that lazy bitch
						local alt = EVT_FindNPC(1)
						local t = EVT_FindTeleportPoint(1)
						
						e.npc = alt
						e.npc.savereset = {alt.x, alt.y, alt.z, alt.frame}
						
						alt.angle = ANG1*270
						alt.frame = D
						P_TeleportMove(alt, t.x, t.y, t.z)
						
						EVT_SetCamByAngle(btl, 1)
						
						e.cards = {}
						for i = 1, #e.personas-1
							local t = EVT_FindTeleportPoint(100 + (i-1))
							e.cards[#e.cards+1] = P_SpawnMobj(t.x, t.y, t.z + FRACUNIT, MT_DUMMY)
							local m = e.cards[#e.cards]
							
							m.tics = -1
							m.renderflags = $ | RF_FLOORSPRITE
							m.sprite = SPR_SHFL
							m.frame = J
							m.scale = $/8
						end
						
						e.currtextdata = nil
						e.evttimer = 0
						
						e.cardangle = 0
						e.carddist = 40
						
						DNG_changeFSState(mo, FS_FUSIONANIM)
					end	
					
				)
			end
			
		
		elseif choice == 2	-- View skills...
		or inputs[BT_BTNC] == 1
			S_StartSound(nil, sfx_select, p)
			DNG_changeFSState(mo, FS_SKILLVIEW)
		
		elseif inputs[BT_USE] == 1
		or choice == 3
			
			if e.state == FS_PREVIEW
				
				S_StartSound(nil, sfx_cancel, p)
				
				-- Remove the last subp (fusion result)
				-- and the last selected subp.
				for i = 1, 2
					table.remove(e.personas, #e.personas)
				end	
				
				if e.maxpersonas == 4
					DNG_changeFSState(mo, FS_CROSS)
				elseif e.maxpersonas == 3
					DNG_changeFSState(mo, FS_TRIANGLE)
				else
					DNG_changeFSState(mo, FS_NORMAL)
				end	
			
			elseif e.state == FS_CONFIRM
				
				local subp = e.personas[#e.personas]
				DNG_changeFSState(mo, e.prevstate)
				if e.state == FS_INHERIT
					-- remove the last inherited skill
					table.remove(subp.skills, #subp.skills)
					table.remove(e.inherited, #e.inherited)
					
					e.hudtimers.inheritin = 7
				
				elseif e.state == FS_SKILLCARD
					-- remove the skill card
					table.remove(subp.skills, #subp.skills)
					e.useskillcard = nil
					
					e.hudtimers.skillcardsin = 7
				end
				
			end
		end
	
	-- viewing skills
	elseif e.state == FS_SKILLVIEW

		if inputs[BT_WEAPONNEXT] == 1
			S_StartSound(nil, sfx_turn, p)
			e.previewn = $+1
			
			if e.previewn > #e.personas
				e.previewn = 1
			end	
			
		elseif inputs[BT_WEAPONPREV] == 1
			S_StartSound(nil, sfx_turn, p)
			e.previewn = $-1
			
			if e.previewn < 1
				e.previewn = #e.personas
			end
		end
	
		if inputs["down"] == 1
			S_StartSound(nil, sfx_hover, p)
			e.skilln = $+1
			
			if e.skilln > 6
				e.skilln = 1
			end
		
		elseif inputs["up"] == 1
			S_StartSound(nil, sfx_hover, p)
			e.skilln = $-1
			
			if e.skilln < 1
				e.skilln = 6
			end	
		elseif inputs[BT_USE] == 1
			
			S_StartSound(nil, sfx_cancel, p)
			DNG_changeFSState(mo, e.prevstate)
		end
		
		
	elseif e.state == FS_SKILLCARD

		local maxitems = 8
		local maxscroll = max(0, #e.skillcards - maxitems)
		
		if inputs["down"] == 1
			S_StartSound(nil, sfx_hover, p)
			
			e.selectcard = $+1
			
			if e.selectcard > maxitems/2
			and e.cardscroll < maxscroll
				e.cardscroll = $+1
			end	
			
			if e.selectcard > #e.skillcards
				e.selectcard = 1
				e.cardscroll = 0
			end
			
			
		elseif inputs["up"] == 1
			S_StartSound(nil, sfx_hover, p)
			
			e.selectcard = $-1
			
			if e.cardscroll
				e.cardscroll = $-1
			end	
			
			if e.selectcard < 1
				e.selectcard = #e.skillcards
				e.cardscroll = maxscroll
			end	
		
		elseif inputs[BT_USE] == 1
			
			S_StartSound(nil, sfx_cancel, p)
			DNG_changeFSState(mo, FS_PREVIEW)
			e.hudtimers.skillcardsout = 7
		
		elseif inputs[BT_JUMP] == 1
			
			-- Remember what card we used.
			e.useskillcard = e.skillcards[e.selectcard]
			
			if e.useskillcard[1] and itemDefs[e.useskillcard[1]]
				-- Add the skill to the pending fusion.
				table.insert(e.personas[#e.personas].skills, itemDefs[e.useskillcard[1]].skill)
			end
			
			e.inheritscroll = 0
			e.inheritselect = 1
			e.hudtimers.skillcardsout = 7
			e.hudtimers.inheritin = 7
			DNG_changeFSState(mo, FS_INHERIT)
		end
	
	-- choose the skills to inherit...
	elseif e.state == FS_INHERIT

		local maxitems = 8
		local maxscroll = max(0, #e.inheritable - maxitems)
		
		if inputs["down"] == 1
			S_StartSound(nil, sfx_hover, p)
			
			e.inheritselect = $+1
			
			if e.inheritselect > maxitems/2
			and e.inheritscroll < maxscroll
				e.inheritscroll = $+1
			end	
			
			if e.inheritselect > #e.inheritable
				e.inheritselect = 1
				e.inheritscroll = 0
			end

		elseif inputs["up"] == 1
			S_StartSound(nil, sfx_hover, p)
			
			e.inheritselect = $-1
			
			if e.inheritscroll
				e.inheritscroll = $-1
			end	
			
			if e.inheritselect < 1
				e.inheritselect = #e.inheritable
				e.inheritscroll = maxscroll
			end	
		
		elseif inputs[BT_USE] == 1
			
			S_StartSound(nil, sfx_cancel, p)
			
			-- go back
			if not #e.inherited
				DNG_changeFSState(mo, FS_SKILLCARD)
				e.hudtimers.inheritout = 7
				e.hudtimers.skillcardsin = 7
				if e.useskillcard and e.useskillcard[1]
					-- a skill card was used, remove it!
					e.useskillcard = nil
					table.remove(e.personas[#e.personas].skills, #e.personas[#e.personas].skills)
				end
			else
				-- Remove last inherit skill.
				table.remove(e.inherited, #e.inherited)
				table.remove(e.personas[#e.personas].skills, #e.personas[#e.personas].skills)
			end
		
		elseif inputs[BT_JUMP] == 1
			
			local subp = e.personas[#e.personas]
			-- Check if dupe...
			local dupe
			for i = 1, #subp.skills
				if subp.skills[i] == e.inheritable[e.inheritselect]
					dupe = true
					break
				end	
			end
			
			if not dupe
				
				S_StartSound(nil, sfx_confir, p)
				-- Now add the skills...
				
				
				e.inherited[#e.inherited+1] = e.inheritable[e.inheritselect]
				subp.skills[#subp.skills+1] = e.inheritable[e.inheritselect]
				
				if #subp.skills >= 6 or #e.inherited >= e.maxinherit
					e.hudtimers.inheritout = 7
					DNG_changeFSState(mo, FS_CONFIRM)
				end
			else
				S_StartSound(nil, sfx_not, p)
			end
		end
	
	elseif e.state == FS_FUSIONANIM
	and not e.animdone
		
		-- Fusion animation...
		e.evttimer = $+1
		
		local timer = e.evttimer
		local cam = btl.cam
		
		if timer < TICRATE/2
			e.npc.frame = D
			
		elseif timer == TICRATE
			e.npc.frame = K
			--S_StartSound(nil, sfx_hama3, p)
		elseif timer == TICRATE + 20
			e.npc.frame = L
			S_StartSound(nil, sfx_hamaca, p)
		elseif timer >= TICRATE + 23
		--and timer <= TICRATE*5
			
			--print(timer)
			
			local t = EVT_FindTeleportPoint(104)
			
			if inputs[BT_JUMP] == 1
			and not e.skipped
				e.skipped = true
				DNG_fade(
					function()
						
						resetCutsceneDta(mo)
						DNG_changeFSState(mo, FS_EXP)						
					end,
					0
				)				
			end
			
			if timer == TICRATE + 23
				e.npc.frame = M
				
				S_StartSound(nil, sfx_qsumon, p)
				
				local s = P_SpawnMobj(t.x, t.y, t.z + FRACUNIT*2, MT_DUMMY)
				s.flags = MF_NOGRAVITY
				s.sprite = SPR_NTHK
				s.frame = B|FF_TRANS40
				s.color = SKINCOLOR_CYAN
				s.renderflags = $ | RF_FLOORSPRITE
				s.scale = 1
				s.destscale = FRACUNIT*10
				s.scalespeed = FRACUNIT/6
				s.tics = -1
				s.fuse = TICRATE/2
			elseif timer == TICRATE*6
				e.npc.frame = N
				e.npc.momz = FRACUNIT/2
				e.npc.flags = $|MF_NOGRAVITY
				
				e.book = P_SpawnMobj(e.npc.x, e.npc.y - FRACUNIT*5, e.npc.z + 43*FRACUNIT, MT_DUMMY)
				e.book.tics = -1
				e.book.sprite = SPR_VBOK
				e.book.frame = A
				e.book.momz = FRACUNIT*5/2
				
			elseif timer == TICRATE*6 + 3
				e.npc.frame = O
			elseif timer == TICRATE*6 + 6
				e.npc.frame = P
			elseif timer >= TICRATE*6 + 9
				e.npc.frame = Q + (leveltime%4 /2)
				e.book.frame = A + (leveltime%6 /2)
				
				e.npc.momz = $*99/100
				e.book.momz = $*98/100
				summonAura(e.npc)
				
				if timer == TICRATE*6 + 9
					S_StartSound(nil, sfx_qsumon, p)
				end	
			end
			
			
			if timer == TICRATE*9 + TICRATE/4
				S_StartSound(nil, sfx_hama3, p)			
			
			
			elseif timer == TICRATE*12 +4
				EVT_SetCamByAngle(btl, 0)
				S_StartSound(nil, sfx_aoado, p)
			
			elseif timer == TICRATE*13
			
				S_StartSound(nil, sfx_debuff, p)
			
				e.fallingpersona = P_SpawnMobj(e.book.x, e.book.y, e.book.z + FRACUNIT*200, MT_DUMMY)
				e.fallingpersona.tics = -1
				e.fallingpersona.flags2 = $|MF2_DONTDRAW
				e.fallingpersona.momz = -FRACUNIT*16
				e.fallingpersona.flags = MF_NOGRAVITY
				
				
				btl.cam.aiming = 0
			elseif timer > TICRATE*13
			and e.fallingpersona
			and e.fallingpersona.valid
				
				local spark = P_SpawnMobj(e.fallingpersona.x, e.fallingpersona.y, e.fallingpersona.z, MT_SUPERSPARK)
				spark.scale = FRACUNIT
				P_InstaThrust(spark, P_RandomRange(0, 360), P_RandomRange(-2, 2)*FRACUNIT)
				spark.momz = P_RandomRange(0, 3)*FRACUNIT
				
				if e.fallingpersona.z < e.book.z
					
					S_StartSound(nil, sfx_lvup, p)
					
					for i = 1, 16
						local spark = P_SpawnMobj(e.book.x, e.book.y, e.book.z, MT_SUPERSPARK)
						spark.scale = FRACUNIT/4
						spark.momx = P_RandomRange(-16, 16)*FRACUNIT
						spark.momy = P_RandomRange(-16, 16)*FRACUNIT
						spark.momz = P_RandomRange(-16, 16)*FRACUNIT
					end
					
					P_RemoveMobj(e.fallingpersona)
					e.fallingpersona = nil
					
				end
				
			elseif timer == TICRATE*16
				DNG_fade(
					function()
						
						resetCutsceneDta(mo)
						DNG_changeFSState(mo, FS_EXP)
						e.animdone = true
					end,
					0
				)
			end
			
			
			
			-- card stuff.
			if timer > TICRATE*3
			and timer < TICRATE*5
				e.cardangle = $ - min(ANG1*10, (timer - TICRATE*3)*ANG1)
				e.carddist = $+2
				
				if leveltime%6 == 0
					S_StartSound(nil, sfx_hamaca, p)
				end	
				
			elseif timer >= TICRATE*5
				
				e.cardangle = $ - max(2, (10 - (timer-TICRATE*5)/7))*ANG1
				e.carddist = max(20, $-2)
			end
			
			local dist = e.carddist
			local bang = e.cardangle
			
			local adda = 0
			
			if timer > TICRATE*7/2
			and timer < TICRATE*6
				adda = min(90, (timer - TICRATE*7/2)*3)
			elseif timer >= TICRATE*6
				adda = max(0, 90 - (timer-TICRATE*6))
			end
			
			local angs = {	
					bang + ANG1*180,
					bang - (adda*4/3) *ANG1,
					bang - (adda*2) *ANG1 + ANG1*90,
					bang - (adda*2/3) *ANG1 + ANG1*270
			}
			
			for i = 1, #e.cards
				local c = e.cards[i]
				
				if timer == TICRATE + 23
					c.flags = $|MF_NOGRAVITY
					c.momz = FRACUNIT/6
				elseif timer == TICRATE*5
					
					c.renderflags = 0
					c.frame = F | FF_PAPERSPRITE
					c.angle = ANG1*180
					c.momz = 0
				
				elseif timer >= TICRATE*9 + (i-1)*4
					if timer == TICRATE*9 + (i-1)*4
						c.momz = FRACUNIT*18
						S_StartSound(nil, sfx_rflc, p)
					else
						local s = P_SpawnMobj(c.x, c.y, c.z, MT_SUPERSPARK)
						s.scale = $/10
					end
				end

				
				local a = angs[i]
				local tx = t.x + dist*cos(a)
				local ty = t.y + dist*sin(a)
				
				P_TeleportMove(c, tx, ty, c.z)
				
				if timer > TICRATE*5
					local persona = e.personas[i]
					if persona and i < #e.personas
						
						local spr = persona.ref.sprite
						local frame = persona.ref.frame
						
						local subv = P_SpawnMobj(c.x, c.y - FRACUNIT/2, c.z, MT_DUMMY)
						subv.tics = 1
						subv.sprite = spr
						subv.frame = frame | FF_PAPERSPRITE
						subv.angle = c.angle
						subv.scale = c.scale
					end
				end
				
			end
		end	
		
	-- give exp to the persona / learn skills etc.	
	elseif e.state == FS_EXP
		
		local subp = e.personas[#e.personas]
		
		if server.fadedta
			return true
		end	
		
		if e.animdone
			e.animdone = nil	-- Make sure to get rid of that.
			e.skillwait = TICRATE/2
			e.skilln = 1
		end
		
		-- {skill, level, learn timer}
		e.learnskills = $ or {}
		e.expdelay = $ and $+1 or 1
		
		-- give exp to the persona!
		if e.expdelay >= TICRATE*3/2
			if e.pexp
				S_StartSound(nil, sfx_menu1, mo.player)
				e.maxexp = $ or e.pexp	-- used for speed scaling.
				
				local giveexp = max(1, min(e.pexp, e.maxexp/(TICRATE*2)))
				local expt = getEXPTable()
				
				subp.exp = $ + giveexp
				e.pexp = $ - giveexp
				
				-- in case we get SO MUCH exp that we get MULTIPLE level ups
				while subp.exp > expt[subp.level]
					S_StartSound(nil, sfx_lvup, p)
					subp.exp = $ - expt[subp.level]
					subp.level = $+1
					P_FlashPal(mo.player, 1, 2)
					
					-- do we need to learn a skill?
					for i = 1, #subp.ref.skills do
						
						local sk = subp.ref.skills[i]
						if sk and type(sk) == "table"
							if subp.level == sk[2]
								e.learnskills[#e.learnskills+1] = {sk[1], sk[2], TICRATE/2}
								--print("Add "..sk[1].." to learnset...")
							end
						end
					end
				end
			elseif e.skillwait
				e.skillwait = max(0, $-1)
			end
		end	
		
		if not e.skillwait
			if #e.learnskills
				local curr = e.learnskills[1]
				
				if #subp.skills >= 6
				and not e.learnslot
					--print("too many skills, forget one")
					if not e.replaceskill
						e.replaceskill = true
						changetextdta(mo, textdata.fusion_chooseforget)
					end
					
					if inputs["down"] == 1
						S_StartSound(nil, sfx_hover, p)
						e.skilln = $+1
						
						if e.skilln > 7
							e.skilln = 1
						end	
					
					elseif inputs["up"] == 1
						S_StartSound(nil, sfx_hover, p)
						e.skilln = $-1
						
						if e.skilln <= 0
							e.skilln = 7
						end	
					
					elseif inputs[BT_USE] == 1
						S_StartSound(nil, sfx_cancel, p)
						DNG_changeFSState(mo, FS_REPLACESKILL)
						e.skilln = 7
						
						changetextdta(mo, textdata.fusion_relentskill)
						
					elseif inputs[BT_JUMP] == 1
						S_StartSound(nil, sfx_confir, p)
						DNG_changeFSState(mo, FS_REPLACESKILL)
						
						changetextdta(mo, e.skilln == 7 and textdata.fusion_relentskill or textdata.fusion_replaceskill)
					end
					
					return true
				end
				
				--print("adding skill...")
				if curr[3] == TICRATE/2
					S_StartSound(nil, sfx_nskill, mo.player)
				end
				
				curr[3] = $-1
				
				if not curr[3]
					if e.learnslot
						subp.skills[e.learnslot] = curr[1]
					else	
						subp.skills[#subp.skills+1] = curr[1]
					end
					e.replaceskill = nil
					e.skilln = 1
					e.learnslot = nil
					table.remove(e.learnskills, 1)
					e.skillwait = TICRATE
				end
			else
				
				e.fusionend = $ and $+1 or 1
				if e.fusionend == TICRATE/2
					-- quickly hack the string ourselves...
					e.currtextdata = {nil, "The Sub-Persona ".."\x82"..(e.personas[#e.personas].ref.name).."\x80".." has emerged from the sea of your soul..."}
					e.texttimer = 1
				
				elseif e.fusionend == TICRATE*5
					DNG_fade(	function()
									
									DNG_changeFSState(mo, FS_MAIN)
									
									e.learnslot = nil
									e.replaceskill = nil
									e.skillwait = nil
									e.evttimer = 0
									e.animdone = nil
									e.learnskills = {}
									e.inherited = {}
									e.inheritable = {}
									e.expdelay = 0
									e.fusionend = nil
									
									-- Remove material personas...
									for i = 1, #e.personas-1
										for j = 1, #btl.subpersonas
											
											if e.personas[i] == btl.subpersonas[j]
												table.remove(btl.subpersonas, j)
												break
											end	
										end
									end
									
									-- Add newly fused persona
									btl.subpersonas[#btl.subpersonas+1] = e.personas[#e.personas]
									
									-- If we used a skill card, remove it.
									if e.useskillcard and e.useskillcard[1]
										BTL_useItem(btl, e.useskillcard[2])
										
										-- consume the macca
										local itdef = itemDefs[e.useskillcard[1]]
										btl.macca = $ - (itdef.cost/4)
									end
									
									e.personas = {}
									e.useskillcard = nil
									
								end,
						0)
				end
			end
		end
	
	elseif e.state == FS_REPLACESKILL
		
		local choice = handleTextChoices(mo)
		
		if choice == 1
			S_StartSound(nil, sfx_confir, p)
			
			if e.skilln == 7
				table.remove(e.learnskills, 1)
				e.skillwait = TICRATE
			else	
				e.learnslot = e.skilln
			end	
				
			e.skilln = 1
			e.replaceskill = nil
			DNG_changeFSState(mo, FS_EXP)	-- go back to exp state.
			e.currtextdata = nil	-- remove text data.
			
		elseif choice == 2
			S_StartSound(nil, sfx_cancel, p)
			DNG_changeFSState(mo, FS_EXP)	-- go back to exp state.
			e.currtextdata = nil	-- remove text data.
		
		end
		
	end
	-- make sure to prevent opening the normal menu.
	return true
end)
	