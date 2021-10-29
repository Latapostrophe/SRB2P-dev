/*
	Main script to run the big core functions in.
	The order barely matters if at all, we just want to only use a single thinkframe to improve performance.
*/

addHook("ThinkFrame", do
	
	if cv_debugcheats.value
		if srb2p.allowunlocks
			print("\x82".."WARNING:".."\x80".." Cheats were enabled. You will not be able to unlock anything until you restart your game client.")
		end	
		srb2p.allowunlocks = nil
	end	-- prevent unlocks if you cheat	
	
	/*
		Run events, 'cutscenes'.
		Everything is located in CORE/Event_Handler.LUA

		@NOTE: Battles may run events on their own, in this case we do NOT use that function.
		Because of how events work, we also cannot support them in a multiplayer context where players may be within battles at different times.

		@TODO: Try to fix the above when we refactor the event code

	*/
	D_RunEvents()

	/*
		Dungeon thinker.
		Initialized in the DUNGEON/ folder.
	*/
	DNG_Thinker()


	/*
		Battle thinker,
		runs battles whenever they're started.
		Scripts in the BATTLE/ folder.

		@NOTE: Battle may run events within themselves.
		@TODO: Fix D_RunEvents to work with this

	*/
	BTL_Thinker()

	/*
		Multiplayer Net lobby, see NET/
		This is what allows us to create teams / join them and select our characters in quickplay.

		Additionally, a small corrective script that tries to help mid-game joiner to enter a game properly.
		@TODO: Mid-game joining still barely works at all, we need to fix this somehow... which means finding what goes wrong to begin with...
	*/
	NET_Lobby()
	NET_Synch()

	/*
		Title Screen thinker
	*/
	TTL_Thinker()
end)