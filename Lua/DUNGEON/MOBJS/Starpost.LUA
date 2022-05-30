-- Starpost save point handler

freeslot("MT_SRB2P_SAVESTARPOST")

mobjinfo[MT_SRB2P_SAVESTARPOST] = {
	doomednum = 897,
	spawnstate = S_STARPOST_IDLE,
	spawnhealth = 1000,
	flags = 0,
	height = 128<<FRACBITS,
	radius = 128<<FRACBITS,
}


addHook("MobjThinker", function(post)
	
	local mo = players[0].mo
	if not mo or not mo.valid return end
	if not server.P_DialogueStatus return end
	local d = server.P_DialogueStatus[mo.player.P_party]
	
	local dist = 128*post.scale
	if R_PointToDist2(mo.x, mo.y, post.x, post.y) > dist or (d and d.running)
		if mo.m_savetarget == post
			mo.m_savebutton = nil
			mo.m_savetarget = nil
		end	
		return
	end
	
	local id = (post.spawnpoint.angle / 360) + 1
	
	-- register starpost
	if not SAVE_checkCheckpoint(id)
		S_StartSound(post, sfx_strpst)
		post.state = S_STARPOST_STARTSPIN
		post.extravalue2 = 1
		SAVE_registerCheckpoint(post)
	elseif not post.extravalue2
		-- starpost was hit but not initialized, make it flash by default
		post.extravalue2 = 1
		post.state = S_STARPOST_FLASH
	end
	
	mo.m_savetarget = post
	mo.m_savebutton = $ and $+1 or 1
	
	if mo.P_inputs[BT_BTNC] == 1
		D_startEvent(mo.player.P_party, "ev_starpostprompt")		
	end
end, MT_SRB2P_SAVESTARPOST)