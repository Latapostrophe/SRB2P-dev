-- Save prompt "event"

eventList["ev_starpostprompt"] = {
		
	[1] = {"text", nil, "What will you do?", {{"Save Game", 2}, {"Fast Travel", 3}, {"Nothing", -1}}, nil, nil},
	
	-- open savegame menu:
	[2] = {"function",
				function(evt, battle)
					M_openMenu(players[0].mo, "m_ssave")
					D_endEvent(battle.n)
					return
				end
			},
			
	-- open fast travel menu:		
	[3] = {"function",
				function(evt, battle)
					D_endEvent(battle.n)
					return				
				end
			},
			
	[4] = {"text", nil, "Nowhere to fast travel to...", nil, nil, nil},	
}