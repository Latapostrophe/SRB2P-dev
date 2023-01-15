-- Defines request specific functions

rawset(_G, "REQ_setStatus", function(reqn, status)
	srb2p.storydata.requeststatus = $ or {}
	srb2p.storydata.requeststatus[reqn] = status
end)

rawset(_G, "REQ_checkStatus", function(reqn)
	srb2p.storydata.requeststatus = $ or {}
	return srb2p.storydata.requeststatus[reqn] or REQ_UNAVAILABLE
end)

-- returns true if the quest can be unlocked (and unlocks it)
rawset(_G, "REQ_unlock", function(reqn)
	if not REQ_checkStatus(reqn)
		REQ_setStatus(reqn, QS_NEW)
		return true
	end	
	return false
end)

-- marks the quest as cleared or cleared once depending on its flags
-- returns true if the quest was sucesfully marked as completed.
rawset(_G, "REQ_clear", function(reqn)
	if REQ_checkStatus(reqn) == QS_SUBMITTABLE
		
		local n = REQ_checkAccepted(reqn)
		
		if not n
			return false
		end
		
		REQ_cancel(n)	-- cancel the request (removes it from our accepted quests list)
		REQ_setStatus(reqn, QS_CLEARED)	-- and then mark it as cleared!
		return true
	end
	return false
end)


-- builds the string for the objective from its data.
-- eg: {"maya_1", 2, 50} -> "Defeat 2 Lv50+ Cowardly Mayas"
rawset(_G, "REQ_buildObjectiveString", function(o)
	local str = ""
	local typ = o.type
	local data = o.data
	
	if typ == OBJ_ITEM
	
		-- data format:
		-- {{"type", "name"}, qty, acq_type, min rarity}
	
		local action = "Get "
		local action_suffix = ""
		
		local amount = ""
		local rarity = ""
		
		local item = "item "
		local item_suffix = ""
		
		local specific = false
		
		local itdta = data[1]
		if itdta and type(itdta) == "table"
			if itdta[1] == "item"
				item = buildItemName(itemDefs[itdta[2]]).." "
				specific = true
			elseif itdta[1] == "weapon"
				local twp = makeWeapon(itdta[2])
				item = buildWeaponName(twp).." "
				specific = true
				twp = nil	-- clear the data
				
			elseif itdta[1] == "wardring"
				local trn = makeRing(itdta[2])
				item = buildRingName(trn).." "
				specific = true
				trn = nil	-- clear the data
			end
		end

		if data[2]
			if not specific
				amount = "any "
			end
			
			if type(data[2]) == "number" and data[2] > 1
				amount = $..tostring(data[2]).." "
				if not specific
					item = "items "
				end
			end	
		end	
		
		if data[3] == ACQ_DROP
			action = "Drop "
			action_suffix = "from enemies/boxes "
		
		elseif data[3] == ACQ_BUY
			action = "Purchase "
			
		elseif data[3] == ACQ_TRADE
			action = "Exchange for "
			
		end
			
		if data[4]
			rarity = tostring(data[4]).."*+ "
		end	
		
		str = action..amount..rarity..item..item_suffix..action_suffix
	
	elseif typ == OBJ_ENEMY
		
		local action = "Defeat "
		local action_suffix = ""
		
		local amount = 1
		local level = ""
		
		local enemy = ""
		
		if data[2] and type(data[2]) == "number"
			amount = data[2]
		end
		
		if data[1]
			enemy = enemyList[data[1]].name..(amount > 1 and "s" or "").." "
		else
			enemy = amount > 1 and "enemies " or "enemy "
		end
		
		if data[3]
			level = "Lv"..data[3].."+ "
		end
		
		str = action.." "..amount.." "..level.." "..enemy.." "..action_suffix
	
	elseif typ == OBJ_ENHANCE
		
		local action = "Enhance "
		local action_suffix = ""
		
		local denot = ""
		local item = ""
		local level = ""
		local rarity = ""
		
		local itdta = data[1]
		
		if itdta
			denot = "a "
			if itdta[1] == "weapon"
				if itdta[2]
					local twp = makeWeapon(itdta[2])
					item = buildWeaponName(twp).." "
					twp = nil	-- free data
				else
					item = "Weapon "
				end	
				
			elseif itdta[1] == "wardring"
				if itdta[2]
					local trn = makeRing(itdta[2])
					item = buildRingName(trn).." "
					trn = nil	-- free data
				else
					item = "Wardring "
				end	
			end
		else
			item = "Equipment "
		end
		
		if data[2]
			level = "to +"..data[2].." "
		end
		
		if data[3]
			rarity = data[3].."*+ "
		end
		
		str = action..denot..rarity..item..level
	
	elseif typ == OBJ_FUSION
		
		local action = "Fuse a "
		local action_suffix = ""
		
		local subp = "Sub-Persona "
		local level = ""
		
		local skills = ""
		
		if data[1]
			subp = ICO_PERSONA..subpersonaList[data[1]].name.." "
		end
		
		if data[2]
			level = "Lv"..data[2].."+ "
		end

		if data[3]
			skills = "with "
			local nskills = #data[3]
			
			for i = 1, nskills
				
				if i == nskills and nskills > 1
					skills = $.."and "
				end
				
				skills = $..attackDefs[data[3][i]].name
				
				if i < nskills and i != nskills-1
					skills = $..", "
				end
			end
		end
		
		str = action..level..subp..skills
	end
	
	return str
end)

-- gives rewards from a table
-- returns {exp, link_exp} if there was any. (tallied up.)
-- if 'results' is true, also returns items in the 3rd, 4th and 5th slots (items, weapons, wardrings) of the table and doesn't give them immediately.
rawset(_G, "REQ_giveRewards", function(tabl, results)
	
	local btl = server.P_BattleStatus[1]
	local ret = {0, 0, {}, {}, {}, 0}	-- exp, l_exp, items, weapons, wardrings, macca
	
	if not tabl or not #tabl return end
	
	for i = 1, #tabl
		local t = tabl[i]
		
		-- give a normal item
		if t[1] == "item"
			
			local it = t[2]
			local qty = t[3] or 1
			
			if results
				table.insert(ret[3], {it, qty})
			else	-- give the item directly.
				BTL_addItem(btl, it, qty)
			end
		
		elseif t[1] == "weapon"
			
			local w = makeWeapon(t[2], t[3])	-- weapon t[2] at +t[3]
			if results
				table.insert(ret[4], w)
			else
				addWeapon(server.plentities[1][1], w)
			end
		
		elseif t[1] == "wardring"
			
			local r = makeRing(t[2], t[3])
			
			if results
				table.insert(ret[5], r)
			else
				addRing(server.plentities[1][1], r)
			end
		
		elseif t[1] == "exp"
			ret[1] = $ + t[2] or 0
		
		elseif t[1] == "lexp"
			ret[2] = $ + t[2] or 0
		
		elseif t[1] == "macca"
			ret[6] = $ + t[2] or 0
		end	
	end
	
	return ret
end)

rawset(_G, "REQ_numAccepted", function()
	srb2p.storydata.activerequests = $ or {}
	
	return #srb2p.storydata.activerequests
end)

-- returns true if the quest can be accepted and accepts it.
-- NOTE: we assume the request has a proper format
	-- @TODO: add checkers for that...
rawset(_G, "REQ_accept", function(reqn)
	
	local s = REQ_checkStatus(reqn)
	local btl = server.P_BattleStatus[1]
	
	srb2p.storydata.activerequests = $ or {}
	
	if s and s < QS_ACCEPTED
	and REQ_numAccepted() < MAXACCEPTREQUESTS
		
		local t = srb2p.storydata.activerequests
		local r = requestsList[reqn]
		
		t[#t+1] = {
			
			requestn = reqn,
			trackers = {}
		}
		
		-- reqdy the trackers...
		for i = 1, #r.objectives
			local o = r.objectives[i]
			local typ = o.type
			local current = 0
			local target = 1	-- by default, an action only needs to be done once.
			local extra = nil
			local extra2 = nil
			
			-- but some objective types can ask for more, so let's check...
			if typ == OBJ_ITEM
			or typ == OBJ_ENEMY				
				target = o.data[2]
				
				-- if it's an item, check if we already have it!
				if typ == OBJ_ITEM
				and o.data[1]		-- uh we need to specify the item
				and not o.data[3]	-- ACQ_ANY / nil
									-- item can be obtained in any way, as such, let's search for it in our inventory right now!!
					
					if type(o.data[1]) == "table" 
						local itdta = o.data[1]
						
						if itdta[1] == "item" and itdta[2] 
							local found = BTL_findItem(btl, itdta[2])
							if found
								current = min(target, $ + btl.items[found][1])
							end
						
						elseif itdta[1] == "weapon" and itdta[2]
							
							-- check if the item is in our inventory or is equipped.
							for i = 1, #btl.weapons
								local w = btl.weapons[i]
								
								if w and w.ref == itdta[2]
									current = min(target, $+1)
								end
							end
							
							-- check on equipment:
							for i = 1, #server.plentities[1]
								local mo = server.plentities[1][i]
								
								if mo.weapon and mo.weapon.ref == itdta[2]
									current = min(target, $+1)
								end	
							end
							
							-- check equipment on reserve...
							for i = 1, #server.plreserve
								local mo = server.plreserve[i]
								
								if mo.weapon and mo.weapon.ref == itdta[2]
									current = min(target, $+1)
								end									
							end
							
						elseif itdta[1] == "wardring" and itdta[2]
							
							-- check if the item is in our inventory or is equipped.
							for i = 1, #btl.armours
								local w = btl.armours[i]
								
								if w and w.ref == itdta[2]
									current = min(target, $+1)
								end
							end
							
							-- check on equipment:
							for i = 1, #server.plentities[1]
								local mo = server.plentities[1][i]
								
								if mo.wardring and mo.wardring.ref == itdta[2]
									current = min(target, $+1)
								end	
							end
							
							-- check equipment on reserve...
							for i = 1, #server.plreserve
								local mo = server.plreserve[i]
								
								if mo.wardring and mo.wardring.ref == itdta[2]
									current = min(target, $+1)
								end									
							end
						
						end					
					end	
				end
			end
			t[#t].trackers[i] = {o.type, current, target, copyTable(o.data), reqn}
		end
		
		if s < QS_ACCEPTEDONCE and r.acceptance
			REQ_giveRewards(r.acceptance)
		end
		
		REQ_setStatus(reqn, QS_ACCEPTED)
		
		return true
	end
end)

-- returns the index of the request in the accepted quest table if it has been accepted.
rawset(_G, "REQ_checkAccepted", function(reqn)
	srb2p.storydata.activerequests = $ or {}
	
	for i = 1, #srb2p.storydata.activerequests
		local t = srb2p.storydata.activerequests[i]
		
		if t.requestn == reqn
			return i
		end
	end
end)	

-- similar as above, but returns the trackers
rawset(_G, "REQ_getAcceptedTrackers", function(reqn)
	local i = REQ_checkAccepted(reqn)
	if i
		return srb2p.storydata.activerequests[i].trackers
	end
end)

-- returns all active conditions of a given type that have not been fufilled
-- returned array has points to the actual condition arrays so they can be modified directly.
rawset(_G, "REQ_findActiveTrackers", function(typ)
	
	srb2p.storydata.activerequests = $ or {}
	
	local ret = {}
	
	for i = 1, #srb2p.storydata.activerequests
		local r = srb2p.storydata.activerequests[i]
		
		for j = 1, #r.trackers
			local o = r.trackers[j]
			
			if o[1] == typ
			and o[2] < o[3]	-- don't need it if it's already done.
				ret[#ret+1] = o
			end
		end
	end
	
	return ret
end)

-- Increases the count on a condition tracker
rawset(_G, "REQ_increaseTrackerValue", function(tracker, value)
	print("REQ_increaseTrackerValue")
	tracker[2] = min($ + value, tracker[3] or 1)
	-- @TODO: handle completion (tracer[2] >= tracker[3])
	
	-- tracker complete, check if the request has all of its trackers completed
	if tracker[2] >= tracker[3]
		local trackers = REQ_getAcceptedTrackers(tracker[5])
		local num = 0	-- # total
		local numc = 0	-- # completed
		
		for i = 1, #trackers
			num = $+1
			
			if trackers[i][2] >= trackers[i][3]
				numc = $+1
			end
		end
		
		if numc >= num
			-- request is complete!
			REQ_setStatus(tracker[5], QS_SUBMITTABLE)
		end
	end
end)


-- checkers for every type of tracker, just call that with the thing it has to check and everything will be taken care of automatically!

-- checkItem, checks for items. acqt must be added for the obtention type.
-- if left nil, anything goes.
rawset(_G, "REQ_checkItem", function(item, acqt)
	local trackers = REQ_findActiveTrackers(OBJ_ITEM)
	local itemd = itemDefs[item]
	
	for i = 1, #trackers
		
		-- tracker: {type, current, target, data, data2, ...}
		local t = trackers[i]
		local dta = t[4]
		
		-- incorrect acqt
		if dta[3] and acqt and acqt ~= dta[3]
			continue
		end

		-- incorrect item
		if item and dta[1] and item ~= dta[1]
			continue
		end	
		
		-- incorrect rarity
		if dta[4] and itemd.rarity < dta[4]
			continue
		end
		
		REQ_increaseTrackerValue(t, 1)
	end
end)

-- checkEquip, call after the enhancement is done to check for the current equipment piece.
rawset(_G, "REQ_checkEquip", function(item)
	
	local trackers = REQ_findActiveTrackers(OBJ_ENHANCE)
	local itemr = item.ref
	
	for i = 1, #trackers
		
		local t = trackers[i]
		local dta = t[4]
		
		-- check for what item we must find...
		local itdta = dta[1]
		
		if type(itdta) == "table"
			
			if itdta[1] == "weapon"
			and itdta[2]
				if itemr ~= itdta[2] or not weaponsList[itemr]
					continue	-- incorrect item/
				end
			elseif itdta[1] == "weapon"
			and not itdta[2]
				if not weaponsList[itemr]
					continue	-- item is not a weapon
				end
			elseif itdta[1] == "wardring"
			and itdta[2]
				if itemr ~= itdta[2] or not ringsList[itemr]
					continue	-- incorrect item
				end
			elseif itdta[1] == "wardring"
			and not itdta[2]
				if not ringsList[itemr]
					continue	-- item is not a wardring
				end
			end
		else
			if not ringsList[itemr] and not weaponsList[itemr]
				continue	-- item is not equipment
			end	
		end
		
		if dta[2] and it.level < dta[2]
			continue		-- item is not high level enough
		end
		
		if dta[3] and it.rarity < dta[3]
			continue		-- item is not high rarity enough
		end	
		
		-- things check out
		REQ_increaseTrackerValue(t, 1)
	end
end)


-- call after enemy death to check if the enemy matches the conditions in active requests
rawset(_G, "REQ_checkEnemy", function(enemy)
	
	local trackers = REQ_findActiveTrackers(OBJ_ENEMY)
	local enemyr = enemy.enemy	
	
	for i = 1, #trackers

		local t = trackers[i]
		local dta = t[4]

		if dta[1] and enemyr ~= dta[1]
			continue	-- not the correct enemy
		end	
		
		if dta[3] and enemy.level < dta[3]
			continue	-- not high enough level
		end
		
		-- things check out!
		REQ_increaseTrackerValue(t, 1)
	end
end)

-- call after item obtention to check if the item matches criteria for active requests
-- make sure to specify the quantity of items obtained as well as the obtention type.
rawset(_G, "REQ_checkItem", function(item, qty, typ)

	local trackers = REQ_findActiveTrackers(OBJ_ITEM)

	for i = 1, #trackers
		local tracker = trackers[i]
		local t = tracker[4]
					
		if not t[3] or t[3] == typ	-- make sure the item must be acquired through the requested method (nil means any method)
			local dta = t[4]
						
			if not dta or not dta[1]
				REQ_increaseTrackerValue(tracker, qty or 1)	-- buy anything? Sure, increase it then!
			elseif dta[1] == "item"	-- regular item
							
				if not dta[2]		-- do we HAVE to check for the item?
				or item == dta[2]	-- otherwise, sure, let's have at it!
					REQ_increaseTrackerValue(tracker, qty or 1)
				end
						
			elseif dta[1] == "weapon"
			or dta[1] == "wardring"
							
				if not dta[2]
				or item.ref == dta[2]
					REQ_increaseTrackerValue(tracker, 1)	-- we can only ever buy 1 equipment at a time.
				end
			end
		end
	end
end)

-- call after enhancement to check if the equipment matches criteria
rawset(_G, "REQ_checkEnhancement", function(item)
	local trackers = REQ_findActiveTrackers(OBJ_ENHANCE)
	
	for i = 1, #trackers
		
		local tracker = trackers[i]
		local t = tracker[4]
		
		local itdta = t[1]
		
		if itdta
			if itdta[1] == "weapon" and weaponsList[item.ref]
			or itdta[1] == "wardring" and ringsList[item.ref]
			
				if itdta[2]
				and itdta[2] ~= item.ref	
					continue	-- nope.
				end
			else
				continue	-- nope.
			end
		end
		
		-- if we're here, there's either no item data or we've validated it.
		-- in either case now we check for the level:
		
		-- check item level
		if t[2] and item.level < t[2]
			continue
		end
		
		-- check item rarity
		if t[3] and item.rarity < t[3]
			continue
		end
		
		-- all good if we made it here.
		REQ_increaseTrackerValue(tracker, 1)
		
	end
end)

-- call after getting a Sub-Persona via Fusion to check if they match criterias
rawset(_G, "REQ_checkPersona", function(p)
	local trackers = REQ_findActiveTrackers(OBJ_FUSION)
	
	for i = 1, #trackers
		local tracker = trackers[i]
		local t = tracker[4]

		-- check if it's the right persona
		if t[1] and t[1] ~= p.int
			continue
		end
		
		-- check if it has a sufficient level
		if t[2] and t[2] > p.level
			continue
		end
		
		-- check if it has the skills we want...
		if t[3]
			local skillsvalid = true
			for i = 1, #t[3]
				local s = t[3][i]
				local valid
				
				for j = 1, #p.skills
					local s2 = p.skills[j]
					if s == s2
						valid = true
						continue
					end
				end
				
				if not valid
					skillsvalid = false
					break
				end
			end
			
			if not skillsvalid
				continue
			end
		end
		
		-- if we've made it here, skills are validated and the persona is good to go!
		REQ_increaseTrackerValue(tracker, 1)
	end
end)

-- returns true if the request could be cancelled.
rawset(_G, "REQ_cancel", function(n)
	
	if srb2p.storydata.activerequests and srb2p.storydata.activerequests[n]
		-- set status to prevent getting acceptance rewards again
		REQ_setStatus(srb2p.storydata.activerequests[n].requestn, QS_ACCEPTEDONCE)
		table.remove(srb2p.storydata.activerequests, n)
		return true
	end
	return false
end)