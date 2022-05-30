freeslot("MT_P3CHEST")
mobjinfo[MT_P3CHEST] = {
	890,
	S_MYSTERY_BOX,
	0,
	S_NULL,
	sfx_None,
	0,
	sfx_None,
	S_NULL,
	0,
	sfx_None,
	S_NULL,
	S_NULL,
	S_NULL,
	S_NULL,
	sfx_None,
	0,
	16 * FRACUNIT,
	32 * FRACUNIT,
	1000,
	0,
	0,
	sfx_None,
	MF_SCENERY|MF_SOLID,
	S_NULL
}

freeslot("S_P3_GOLDRANDOM1", "S_P3_GOLDRANDOM2", "S_P3_GOLDRANDOMOFF")
states[S_P3_GOLDRANDOM1] = {SPR_TVMY, B, 2, nil, 0, 0, S_P3_GOLDRANDOM2}
states[S_P3_GOLDRANDOM2] = {SPR_XLTV, A, 1, nil, 0, 0, S_P3_GOLDRANDOM1}
states[S_P3_GOLDRANDOMOFF] = {SPR_XLTV, B, -1, nil, 0, 0, S_P3_GOLDRANDOMOFF}


addHook("MobjThinker", function(t)
	-- Story mode: Allow for pre-determined box contents.

	if (not t.content or not #t.content)
	and srb2p.storymode
	and not t.extravalue1

		t.extravalue1 = 1
		t.scale = $*2

		-- story mode shite
		print(gamemap)
		if DNG_itemBoxes[gamemap]
			t.extravalue2 = 1	-- initialized for story
			print("OK")
			local tt = DNG_itemBoxes[gamemap]
			local s = t.spawnpoint
			local ang = s.angle

			if tt[ang]
				print("OK2")
				local tabl = tt[ang]
				t.content = {}

				-- add the items.
				for i = 1, #tabl
					for j = 1, tabl[i][2]
						print("Added "..tostring(tabl[i][1]))
						t.content[#t.content+1] = tabl[i][1]
					end
				end
			end

		end
	end
end, MT_P3CHEST)

-- item collection
addHook("MobjCollide", function(t, mo)

	if not mo or not mo.valid return end
	if mo.type ~= MT_PLAYER then return end
	local p = mo.player
	if not (p.pflags & PF_JUMPED or p.dashmode > TICRATE*3) return end
	if (t.hitflags and t.hitflags & (2^(p.P_party-1))) return end	-- already popped that gold box

	local gold = t.hitflags ~= nil

	if server.gamemode == GM_VOIDRUN
		local dng = server.P_DungeonStatus
		if dng.VR_type == VC_INFILTRATION
		and dng.VR_timer ~= nil
			dng.VR_score = $+1	-- got item!
		end
	end

	local maxrarity = 0
	-- when you get multiple of the same items in a row.
	local batchqty = 0
	local dispname = srb2p.storymode and "You" or "\x82"..mo.player.name.."\x80"

	if t.content and t.content[1]
		for k,v in ipairs(t.content)


			-- check if item is a weapon / ring / weapon series
			local rare
			if type(v) == "table"
				--print("A")
				if v[1] == "series"
					--print(v[2])

					local wpn = dropWeaponFromSeries(v[2], server.plentities[mo.player.P_party])
					--print(wpn)
					wpn = makeWeapon(wpn, P_RandomRange(0, 3))
					if wpn

						addWeapon(mo, wpn)
						maxrarity = max($, wpn.rarity)

						if mo.player.P_party == consoleplayer.P_party
							DNG_logMessage(dispname.." found ".."\x82"..buildWeaponName(wpn))
						end
						spawnWeaponDrop(wpn, t.x, t.y, t.z)
					end

				elseif v[1] == "ring"
					local ring = v[2]
					ring = makeRing(ring, P_RandomRange(0, 3))

					if ring

						addRing(mo, ring)
						maxrarity = max($, ring.rarity)

						if mo.player.P_party == consoleplayer.P_party
							DNG_logMessage(dispname.." found ".."\x82"..buildRingName(ring))
						end
						spawnRingDrop(ring, t.x, t.y, t.z)
					end

				elseif v[1] == "weapon"
					local wpn = v[2]
					wpn = makeWeapon(wpn, P_RandomRange(0, 3))

					if wpn
						addWeapon(mo, wpn)
						maxrarity = max($, wpn.rarity)

						if mo.player.P_party == consoleplayer.P_party
							DNG_logMessage(dispname.." found ".."\x82"..buildWeaponName(wpn))
						end
						spawnWeaponDrop(wpn, t.x, t.y, t.z)
					end
				end


				--[[if rare
					IT_startRareDropAnim(mo.player)
				end--]]

				continue
			end

			-- get item name for display:
			local it = itemDefs[v]
			local name = it and buildItemName(it) or v
			local amount = 1

			if it and it.material and not it.extravalue2	-- this'd mean the box has fixed items, so don't do that.
				amount = P_RandomRange(1, 5 - (it.rarity/2))
			end
			local extrastr = ""

			if amount > 1
				extrastr = " x"..amount
			end

			batchqty = $+1

			if not t.content[k+1] or t.content[k+1] ~= v
				amount = max($, batchqty)
				if amount > 1
					extrastr = " x"..amount
				end

				if mo.player.P_party == consoleplayer.P_party
					DNG_logMessage(dispname.." found \x82"..name..extrastr)
				end

				batchqty = 0
			end


			BTL_addItem(server.P_BattleStatus[mo.player.P_party], v, amount)

			if mo.player.P_party == consoleplayer.P_party
				DNG_logMessage("\x82"..mo.player.name.."\x80".." found ".."\x82"..name..extrastr)
			end

			if it and it.rarity and (not it.material or it.rarity >= 7)
				--IT_startRareDropAnim(mo.player)
				maxrarity = max($, it.rarity)
			end

			spawnItemDrop(it, t.x, t.y, t.z)
		end

		if maxrarity >= 5
			IT_startRareDropAnim(mo.player, maxrarity)
		end

		VFX_Play(mo, VFX_TARTARUS_ITEM) -- after all that, play a sound effect if applicable
	else
		DNG_logMessage("\x82"..mo.player.name.."\x80".." found an empty box...")
	end

	-- set this item's space back as a white space in tartarus
	if DNG_isTartarusMap() and (not gold or consoleplayer.P_party == p.P_party)
		server.map[#t.subsector.sector+1] = 1	-- walkable.
	end

	if t and t.valid

		for i=1,16
			local b = P_SpawnMobj(t.x, t.y, t.z+20*FRACUNIT, MT_DUMMY)
			b.momx = P_RandomRange(-8, 8)*FRACUNIT
			b.momy = P_RandomRange(-8, 8)*FRACUNIT
			b.momz = P_RandomRange(-8, 8)*FRACUNIT
			b.state = S_AOADUST1
			b.frame = A|FF_FULLBRIGHT
			b.scale = FRACUNIT*3
			b.destscale = FRACUNIT/12
		end

		if gold
			t.hitflags = $| (2^(p.P_party-1))
			if p.P_party == consoleplayer.P_party
				t.state = S_P3_GOLDRANDOMOFF
			end
		else
			local boom = P_SpawnMobj(t.x, t.y, t.z, MT_DUMMY)
			boom.state = S_BOX_POP1
			S_StartSound(boom, sfx_pop)
			server.DNG_entities[#server.DNG_entities+1] = boom
			P_RemoveMobj(t)
		end

		if mo.momz < 0
			mo.momz = -$ /2
		end
	end
end, MT_P3CHEST)