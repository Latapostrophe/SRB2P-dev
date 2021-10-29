-- Constants for unlockables so that we don't use magic numbers
-- As of MP BETA 1.0.0: Only UNLOCK_TUTORIAL (1) is used, DO NOT ADD ANYTHING BEFORE IT!!!!

-- @NOTE: NEVER ADD ENTRIES INBETWEEN OTHERS, ONLY AT THE END, OTHERWISE THIS *WILL* FUCK UP SAVES LATER DOWN THE LINE WHEN WE USE THEM!!!!

local unlocks = {

	"UNLOCK_TUTORIAL",
	-- Technically a hack, this is "unlocked" when you start the game the first time
	-- And asks you if you'd like to play the tutorial.

	"UNLOCK_B5",	-- Block 5 unlock
	"UNLOCK_B6",	-- Block 6 unlock
	"UNLOCK_B7",	-- Block 7 unlock

	"UNLOCK_C1",	-- Extra 1
	"UNLOCK_C2",	-- Extra 2
	"UNLOCK_C3",	-- Extra 3
	
	"UNLOCK_B7_FINISHED",	-- Block 7 finished
	"UNLOCK_MR_FINISHED",	-- Marathon mode finished
	"UNLOCK_VR_FINISHED",	-- Void Run finished
	"UNLOCK_CH_FINISHED",	-- Challenge Mode finished
	"UNLOCK_ANGEL",
}

for i = 1, #unlocks
	rawset(_G, unlocks[i], i)
end


-- checks for unlock conds:
rawset(_G, "P_unlockedCharacter", function(charname)
	if not charStats[charname] or not charStats[charname].locked
		return true	-- good
	end
	return srb2p.local_conds[charStats[charname].locked]
end)

-- same as above but synched for use in netgames
rawset(_G, "P_netUnlockedCharacter", function(p, charname)
	p.unlocks = $ or {}	-- in case
	if not charStats[charname] or not charStats[charname].locked
		return true	-- good
	end
	if not p.unlocks and charStats[charname].locked
		return true	-- safety net until cmd is sent, let em do what they want.
	end
	return p.unlocks[charStats[charname].locked]
end)

-- unlock a condition
-- if p is supplied, also sends it
-- if msg is supplied, sends a message in the chat log too

rawset(_G, "P_unlock", function(u, p, msg)

	if not srb2p.allowunlocks return end	-- cheats were used this session
	local unlocked

	if p and p.valid
		--p.allowunlocks = true
		if p == consoleplayer	-- local player

			if not srb2p.local_conds[u]

				srb2p.local_conds[u] = true
				--COM_ImmedExecute("__&sendunlocks "..u)
				COM_BufInsertText(p, "__&sendunlocks "..u)
				dprint("Unlocked "..u)
				SAVE_put_xdata()	-- save this
				unlocked = true
			end
		end
	else	-- do local unlock
		if not srb2p.local_conds[u]
			srb2p.local_conds[u] = true
			SAVE_put_xdata()
			unlocked = true
		end
	end

	if msg
	and unlocked
	and (p == nil or consoleplayer == p)
		chatprint("\x82"..msg)
	end
end)

if srb2p.debug
	COM_AddCommand("d_unlock", function(a, u)
		if u
			for p in players.iterate
				P_unlock(tonumber(u), p)
				dprint("DBG: Forced unlock "..u.." for "..p.name)
			end
		end	
	end)
end