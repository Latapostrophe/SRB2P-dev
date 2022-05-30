-- Here we define Hooks for modding. Trust me, you're going to love this.

/*
	"sus is a bad meme"
		- Spectra
						*/


rawset(_G,"hookslist", {
	"DungeonStart", -- Runs at the start of Tartarus
	-- function(btl)
	
	"DungeonThinker",	-- Runs during dungeons
	-- function()
	
	"DungeonNextFloor",	-- Runs the frame the dungeon floor changes
	-- function()

	"BattleThinker", -- Runs during battle, using the battlestatus of each team
	-- function(btl)

	"BattleStart", -- Runs at the start of the battle
	-- function(team1, team2)

	"BuildTurnOrder",	-- Runs when the turn order needs to be built
	-- function(btl)

	"FighterDamage", -- Runs when a fighter mobj takes damage.
	-- function(mo, attacker)

	"ModifyDamage", -- Runs when a fighter mobj is about to deal damage
	-- function(mo, targ)

	"NextTurn", -- runs when it's the next player's turn
	-- function(mo)
	
	"GetOneMore",	-- runs when a 1MORE has been obtained 
	-- function(mo, target)
	
	

	"EnemyInit",	-- When enemies are initialized
	-- function(mo)

	
	
})

-- List of hooks that can overwrite default behaviours
rawset(_G, "overwritingHooks", {
	["ModifyDamage"] = 1,
	["GetOneMore"] = 1,
	["BuildTurnOrder"] = 1,
})

rawset(_G, "SRB2P_hooks", {})
for i = 1, #hookslist
	SRB2P_hooks[hookslist[i]] = {}	-- table set
end

-- Format of hooks table:
-- SRB2P_hooks[hookname] = {function1, function2, function3, [...], functionn}
-- A table of functions essentially

/********************************************
	Functions - SRB2P_addHook, SRB2P_runHook
********************************************/

-- This function adds a hook to be ran by SRB2P_runHook
-- For your safety, keep this outside of other hooks, SRB2P based or Vanilla
-- Make sure "hookname" is one of the hooks in "hookslist" above.
-- Example Usage:

/*SRB2P_addHook("BattleThinker", function(btl)
	if (leveltime%35) then return end
	
	print("A")
end)*/
-- When used by SRB2P_runHook (explained below), all hooks of this type will be ran,
-- in order of addition

-- Enjoy :)
rawset(_G, "SRB2P_addHook", function(hookname, func)
	-- check if hookname is valid.
	local ishookvalid
	for i = 1, #hookslist do
		if hookslist[i] == hookname
			ishookvalid = 1
			break
		end
	end

	assert(ishookvalid, "SRB2P_addHook: Invalid hook name '"..hookname.."'.")

	-- make sure we have a function
	assert(func and type(func) == "function", "SRB2P_addHook: In hook '"..hookname.."': Invalid argument #2, expected function, got different type.")

	dprint("Added a hook type of '"..hookname.."' to SRB2P")

	-- Now we can proceed.
	table.insert(SRB2P_hooks[hookname], func)
end)

-- To run a certain part of the hook, put this function in a part of the code
-- If intended to be used as a thinker hook, make sure it is ran repetedly
-- Example usage:
-- SRB2P_runHook("BattleThinker", server.P_BattleStatus[1])
-- All BattleThinker hooks registered by SRB2P_addHook will be ran at once
rawset(_G, "SRB2P_runHook", function(hookname, ...)
	if SRB2P_hooks[hookname]
		local numhooks = #SRB2P_hooks[hookname]
		if not numhooks return end	-- Do nothing
		
--		local returnedValues = {}

		-- Iterate over all the functions and run them
		for i = 1, numhooks do
			local args = {...} -- help whats a "..."... uhh... a table?
			local run, res = pcall(SRB2P_hooks[hookname][i], unpack(args))
			
			if not run
				print("\x82".."WARNING: Hook '"..hookname.."' #"..i..": ".."\x80"..res)
				continue
			end
			
			if overwritingHooks[hookname] and res ~= nil
				return res	-- Returning non-nil CAN overwrite certain behaviours
			end
		end
	end
end)