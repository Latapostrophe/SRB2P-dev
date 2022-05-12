-- Simple menu to select between the facilities at the Velvet Room door

local choices = {"LEAVE", "VELVET\n   SHOP", "VELVET\n    LAB", "SUB PERSONA\n          FUSION"}

local function drawFacilitySelect(v, mo)

	local timers = mo.m_hudtimers
	local timer = timers.sclosemenu and ((TICRATE*1/3) - timers.sclosemenu) or timers.smenuopen or 0
	
	local fwtimer = (TICRATE*1/3) - timer

	-- kool visual!!!!
	if timers.fclose
		local opaque = 7 - (TICRATE*1/3 - timers.fclose)
		if opaque > 0
			v.fadeScreen(31, opaque)
		end	
	else
		v.fadeScreen(31, min(7, fwtimer))
	end	
	
	for i = 0, #choices-1
		
		local x, y
		local tx, ty
		local tflag
		local scale = FRACUNIT/2
		local opacity = max(0, 9 - (fwtimer)) << V_ALPHASHIFT
		
		-- Multiplayer doesn't have fusion
		if i > 2 and not srb2p.storymode
			continue
		end	
		
		if timers.fclose
			if i == mo.m_fchoice
				scale = FRACUNIT/2 + (TICRATE*1/3 - timers.fclose)*(FRACUNIT)
			else
				scale = max(1, FRACUNIT/2 - (TICRATE*1/3 - timers.fclose)*(FRACUNIT/4))
			end
			
			opacity = min(9, (TICRATE*1/3 - timers.fclose)) << V_ALPHASHIFT
		end
		

		if i == 0
			x = 160
			y = 120 + fwtimer*5
			
			tx, ty = x, (y-10)
			tflag = "center"
			
		elseif i == 1
			x = 160 - 30 - fwtimer*6
			y = 110
			
			tx = x - 45
			ty = y - 10
			tflag = nil
			
		elseif i == 2
			x = 160 + 30 + fwtimer*6
			y = 110
			
			tx = x - 30
			ty = y - 10
			tflag = nil

		elseif i == 3
			x = 160
			y = 100 - fwtimer*5
			
			tx = x - 75
			ty = y - 10
			tflag = nil
			
		end
		
		v.drawScaled(x*FRACUNIT, y*FRACUNIT, scale, v.cachePatch("H_SLS"..(i)), opacity)
		
		V_drawString(v, tx, ty, choices[i+1], "FPIMP", opacity, tflag, 0, 31, FixedMul(scale, 2*FRACUNIT*3/4)) 
		
	end
end

M_menus["m_selectfacility"] = {

	m_start_at = "m_selectfacility",	-- where the menu starts
	openfunc = function(mo)	-- play a sound when we open the menu:
		S_StartSound(nil, sfx_select, mo.player)
	end,

	m_selectfacility = {
		opentimer = TICRATE*1/3,
		closetimer = TICRATE*1/3,
		hoversound = sfx_hover,
		confirmsound = sfx_confir,

		drawer = drawFacilitySelect,
		
		openfunc =			function(mo)
								mo.m_fchoice = nil
							end,
		
		runfunc =			function(mo)

								local inpts = mo.P_inputs
								
								local choices = {"down", "left", "right"}
								-- in story moe, allow fusions
								if srb2p.storymode
									choices = {"down", "left", "right", "up"}
								end
								
								if mo.player.awayviewtics
									mo.player.awayviewtics = TICRATE*60*60*60
								end	
								
								if mo.m_hudtimers.fclose == 1
									M_closeMenu(mo)	
									
									-- leave
									if mo.m_fchoice == 0
										if srb2p.storymode
										and server.obj_velvet_map
											D_startEvent(1, "ev_velvetroom_leave1")
										end
										
									-- shop
									elseif mo.m_fchoice == 1
										local shoptype = "velvet_shop_mp1"

										if server.gamemode == GM_VOIDRUN
											shoptype = "void_shop"
										elseif server.cdungeon
											shoptype = server.cdungeon.shop	-- dios mio
										end	

										DNG_startShop(mo, shoptype)	
									
									-- eq lab
									elseif mo.m_fchoice == 2
										DNG_startEquipLab(mo)
										
									elseif mo.m_fchoice == 3
										DNG_startFusion(mo)
									end
								end
								
								if mo.m_fchoice ~= nil return end
								
								for i = 1, #choices do
									if inpts[choices[i]] == 1
									or i == 1 and inpts[BT_BTNB] == 1	-- closing the menu with B works too
										
										mo.m_fchoice = i-1
										mo.m_hudtimers.fclose = TICRATE*1/3
										
									end
								end
								
							end,
	},

}