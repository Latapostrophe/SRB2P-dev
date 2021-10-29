-- Rendering functions for shops.

local shop_choices = {

	[SS_MAIN] = {
		"Buy",
		"Sell",
		"Leave",
	},

	[SS_BUYCONFIRM] = {
		"Yes",
		"No",
	},

	[SS_SELLCONFIRM] = {
		"Yes",
		"No",
	},

}

-- Renders rarity stars for items

local starcolours = {0, 145, 82}
local starcolours7 = {209, 49, 82, 88, 145, 177}

rawset(_G, "renderRarity", function(v, x, y, rarity, flags)
	-- Weapon/Ring rarity:
	rarity = $ or 1
	local rarity = min(7, rarity)
	local iter = max(6, rarity)
	for i = 1, iter
		local pname = "RSTAR1"
		local col = starcolours[(i-1)/2 +1]
		
		if i > rarity
			pname = "RSTAR0"
			col = 0
		elseif i == 7
			col = starcolours7[leveltime % #starcolours7 +1]
			pname = "RSTAR2"	-- specific icon for max rarity items
		end

		v.drawIndex(x<<FRACBITS, y<<FRACBITS, FRACUNIT/2, v.cachePatch(pname), flags, col)
		--PDraw(v, x, y, v.cachePatch(pname), flags)
		x = $+8
	end
end)

local function drawMoney(v, mo, timer)

	local btl = server.P_BattleStatus[mo.player.P_party]
	if not btl return end

	-- draw backdrop:
	local x = 0 - 24*timer
	local y = 100
	PDraw(v, x, y, v.cachePatch("H_MACCA"), V_SNAPTOTOP|V_SNAPTOLEFT)
	V_drawString(v, x+55, y+9, btl.macca, "FPNUM", V_SNAPTOTOP|V_SNAPTOLEFT, "right", 31, nil)
end

rawset(_G, "R_drawShop", function(v, mo)
	if not mo.shop
	or not mo.shop.shopping return end	-- bruh!
	local data = shopList[mo.shop.shopname]
	if not data return end	-- bruh x2!

	local showmoney
	local moneytimer

	-- draw the shop menu when applicable:
	if mo.shop.shopstate >= SS_BUY
	and mo.shop.shopstate <= SS_SOLD
		local timer = 0

		if mo.shop.shopstate == SS_BUY
		or mo.shop.shopstate == SS_SELL
			timer = mo.shop.hudtimers.newstate	-- only have the state animation when opening the shop itself
		end

		local x = 50
		local y = 10 + timer*64

		local numtabs = 5	-- might change?
		local basetabx = 160 - (numtabs*17)/2
		local tabx = basetabx

		for i = 1, numtabs
			local offsy = 1
			local tabtype = 2
			if mo.shop.tab == i
				tabtype = 1
				offsy = 0
			elseif not mo.shop.tabs[i]
			or not #mo.shop.tabs[i]
				tabtype = 3
			end

			PDraw(v, tabx, y +offsy, v.cachePatch("H_TAB"..i..tabtype))
			tabx = $+17
		end

		-- display L & R
		V_drawString(v, basetabx - 11 - 4 - (leveltime%20 < 10 and 1 or 0), y, "\x93", "NFNT", 0, nil, 135, 31, FRACUNIT)	-- L
		V_drawString(v, tabx + 4 + (leveltime%20 < 10 and 1 or 0), y, "\x94", "NFNT", 0, nil, 135, 31, FRACUNIT)	-- R

		PDraw(v, x, y, v.cachePatch("H_SHOPBG"), V_30TRANS)
		PDraw(v, x, y, v.cachePatch("H_SHOPOL"))

		-- list the items we can buy / sell...

		-- SELL
		if mo.shop.shopstate >= SS_SELL
		and mo.shop.shopstate <= SS_SOLD
			local list = mo.shop.tabs[mo.shop.tab]
			local lowesty = y + 18
			local highesty = lowesty + 50	-- 6 items

			local ty = lowesty - 10*mo.shop.scroll	-- yep.
			
			if not #list
				V_drawString(v, x+125, lowesty, "NOTHING TO SELL", "NFNT", 0, "center", 16, 31)
			end
			
			for i = 1, #list do
				--print(i)

				if ty < lowesty
				or ty > highesty
					ty = $+10
					continue
				end

				local elt = list[i]
				local obj = elt[1]

				if i == mo.shop.choice
					v.drawFill(x+16, ty-2, 200, 12, 135)

					if mo.shop.tab == 1
						-- draw quantity.. (NOT FOR SKILLCARDS/PERSONAS
						local str = "<"..mo.shop.quantity..">"
						if leveltime%20 < 10
							str = "< "..mo.shop.quantity.." >"
						end

						V_drawString(v, x+125, ty, str, "NFNT", 0, "center", 0, 31)
					end
				end

				-- tab 1: Items
				if mo.shop.tab == 1
					-- Item name (quantity)
					local cost = itemDefs[obj].cost and itemDefs[obj].cost/8 or 0
					local colour = 0
					if not cost
						colour = 16
					end

					V_drawString(v, x+20, ty, buildItemName(itemDefs[obj]).." ("..elt[2]..")", "NFNT", 0, nil, colour, 31)
					V_drawString(v, x+170, ty, (i == mo.shop.choice and "x " or "")..(cost)..currency, "NFNT", 0, "right", colour, 31)

					if i == mo.shop.choice
						V_drawString(v, x+175, ty, "=\x82"..(cost*mo.shop.quantity)..currency, "NFNT", 0, nil, 0, 31)
						-- Also draw the item description...
						v.drawFill(x+16, lowesty + 61, 200, 1, 135)

						local wwdesc = STR_WordWrap(v, itemDefs[obj].desc, 128, "NFNT", FRACUNIT/2, true)

						if itemDefs[obj].desc
							local wwdesc = STR_WordWrap(v, itemDefs[obj].desc, 128, "NFNT", FRACUNIT/2, true)
							V_drawString(v, x+20, lowesty + 64, STR_WWToString(wwdesc), "NFNT", 0, nil, 0, 31)
						end
						renderRarity(v, x+16+150, lowesty+62, itemDefs[obj].rarity or 1)
					end

					ty = $+10

				elseif mo.shop.tab == 2	-- Weapons

					local itname = buildWeaponName(elt)

					V_drawString(v, x+20, ty, itname, "NFNT", 0, nil, colour, 31)
					local cost = evaluateWeaponPrice(elt)/8
					V_drawString(v, x+175, ty, (cost)..currency, "NFNT", 0, "right", 0, 31)
					if i == mo.shop.choice
						-- Also draw the item description...
						v.drawFill(x+16, lowesty + 61, 200, 1, 135)

						local desc = "ATK: "..(elt.atk/10).." ACC: "..elt.acc.." CRIT: "..elt.crit.."\n"
						local stats = {"St", "Ma", "En", "Ag", "Lu"}
						for i = 1, #stats do
							local st = stats[i]:lower()

							if elt[st]
								desc = $..stats[i]..": "..elt[st].." "
							end
						end
						if elt.level >= 10 and elt.slot
							local skname = ICO_SKILLCARD..(attackDefs[elt.slot] and attackDefs[elt.slot].name or "INVALID SKILL")
							desc = $.."\n"..skname
						end

						V_drawString(v, x+20, lowesty + 64, desc, "NFNT", 0, nil, 0, 31)
						-- rarity:
						renderRarity(v, x+16+150, lowesty+62, elt.rarity)
						-- draw wpn element (wow!)
						if elt.element
							v.drawScaled((x+6+150)<<FRACBITS, (lowesty+63)<<FRACBITS, FRACUNIT/4, v.cachePatch("AT2_"..atk_constant_2_num[elt.element]))
						end						

					end

					ty = $+10

				elseif mo.shop.tab == 3	-- Rings

					local itname = buildRingName(elt)

					V_drawString(v, x+20, ty, itname, "NFNT", 0, nil, colour, 31)
					local cost = evaluateRingPrice(elt)/8
					V_drawString(v, x+175, ty, (cost)..currency, "NFNT", 0, "right", 0, 31)
					if i == mo.shop.choice
						-- Also draw the item description...
						v.drawFill(x+16, lowesty + 61, 200, 1, 135)

						local desc = "DEF: "..(elt.def/10).."\n"
						local stats = {"HP", "SP"}
						for i = 1, #stats do
							local st = stats[i]:lower()

							if elt[st]
								desc = $..stats[i]..": "..elt[st].." "
							end
						end

						V_drawString(v, x+20, lowesty + 64, desc, "NFNT", 0, nil, 0, 31)
						-- rarity
						renderRarity(v, x+16+150, lowesty+62, elt.rarity)
					end

					ty = $+10

				elseif mo.shop.tab == 4	-- skill cards
					local atk = attackDefs[elt]
					if not atk continue end

					local colour = 0

					V_drawString(v, x+20, ty, ICO_SKILLCARD..atk.name, "NFNT", 0, nil, 0, 31)
					local cost = 250
					if atk.power then cost = atk.power*3 end

					V_drawString(v, x+170, ty, (cost/5)..currency, "NFNT", 0, "right", 0, 31)

					if i == mo.shop.choice
						-- Also draw the item description...
						v.drawFill(x+16, lowesty + 61, 200, 1, 135)
						V_drawString(v, x+20, lowesty + 64, atk.desc, "NFNT", 0, nil, 0, 31)
					end

					ty = $+10

				elseif mo.shop.tab == 5	-- sub personas

					local colour = 0
					if server.P_BattleStatus[mo.player.P_party].subpersonas[i].equipped
						colour = 16	-- we already have that skillcard, grey it out.
					end

					V_drawString(v, x+20, ty, ICO_PERSONA..elt.name, "NFNT", 0, nil, colour, 31)
					local cost = elt.level*15

					V_drawString(v, x+170, ty, (cost)..currency, "NFNT", 0, "right", colour, 31)

					if i == mo.shop.choice
						-- Also draw the item description...
						v.drawFill(x+16, lowesty + 61, 200, 1, 135)
						-- basic info
						local desc = elt.name..", Lv "..elt.level.."\n"

						-- stats
						local stats = {"st", "ma", "en", "ag", "lu"}
						for j = 1, #stats do
							desc = $..(stats[j]:upper())..":"..(elt[stats[j]])..(j < #stats and ", " or "")
						end
						desc = $.."\n"

						-- skills
						for j = 1, #elt.skills do
							local sk = attackDefs[elt.skills[j]]
							if not sk continue end

							desc = $..sk.name..(j < #elt.skills and ", " or "")
						end

						V_drawString(v, x+20, lowesty + 64, desc, "NFNT", 0, nil, 0, 31)
					end

					ty = $+10

				end
			end
		end

		-- BUY
		if mo.shop.shopstate >= SS_BUY
		and mo.shop.shopstate <= SS_BOUGHT	-- show buy inventory for all the states between buy and bought (buy, buyconfirm, cantbuy, bought)

			local list = mo.shop.tabs[mo.shop.tab]
			local lowesty = y + 18
			local highesty = lowesty + 50	-- 6 items

			local ty = lowesty - 10*mo.shop.scroll	-- yep.

			for i = 1, #list do
				--print(i)

				if ty < lowesty
				or ty > highesty
					ty = $+10
					continue
				end

				local elt = list[i]
				local obj = elt[1]

				if i == mo.shop.choice
					v.drawFill(x+16, ty-2, 200, 12, 135)

					if mo.shop.tab < 4
						-- draw quantity.. (NOT FOR SKILLCARDS/PERSONAS
						local str = "<"..mo.shop.quantity..">"
						if leveltime%20 < 10
							str = "< "..mo.shop.quantity.." >"
						end

						V_drawString(v, x+125, ty, str, "NFNT", 0, "center", 0, 31)
					end
				end

				-- tab 1: Items
				if mo.shop.tab == 1
					-- Item name:
					V_drawString(v, x+20, ty, buildItemName(itemDefs[obj]), "NFNT", 0, nil, 0, 31)
					local cost = elt[2] or itemDefs[obj].cost or 0
					V_drawString(v, x+170, ty, (i == mo.shop.choice and "x " or "")..(cost)..currency, "NFNT", 0, "right", 0, 31)

					if i == mo.shop.choice
						-- draw the total... (not for skillcards/pers
						V_drawString(v, x+175, ty, "=\x82"..(cost*mo.shop.quantity)..currency, "NFNT", 0, nil, 0, 31)
						-- Also draw the item description...
						v.drawFill(x+16, lowesty + 61, 200, 1, 135)

						if itemDefs[obj].desc
							local wwdesc = STR_WordWrap(v, itemDefs[obj].desc, 128, "NFNT", FRACUNIT/2, true)
							V_drawString(v, x+20, lowesty + 64, STR_WWToString(wwdesc), "NFNT", 0, nil, 0, 31)
						end
						renderRarity(v, x+16+150, lowesty+62, itemDefs[obj].rarity or 1)
					end

					ty = $+10

				-- tab 2: Weapons
				elseif mo.shop.tab == 2

					-- theoritically we don't *care* if you already have a weapon.
					-- since you could be running multiple of the same character.

					local itname = buildWeaponName(obj)

					V_drawString(v, x+20, ty, itname, "NFNT", 0, nil, colour, 31)
					local cost = elt[2] or evaluateWeaponPrice(obj)
					V_drawString(v, x+175, ty, (i == mo.shop.choice and "x " or "")..(cost)..currency, "NFNT", 0, "right", 0, 31)
					if i == mo.shop.choice
						-- draw the total... (not for skillcards/pers
						V_drawString(v, x+175, ty, "=\x82"..(cost*mo.shop.quantity)..currency, "NFNT", 0, nil, 0, 31)
						-- Also draw the item description...
						v.drawFill(x+16, lowesty + 61, 200, 1, 135)

						local desc = "ATK: "..(obj.atk/10).." ACC: "..obj.acc.." CRIT: "..obj.crit.."\n"
						local stats = {"St", "Ma", "En", "Ag", "Lu"}
						for i = 1, #stats do
							local st = stats[i]:lower()

							if obj[st]
								desc = $..stats[i]..": "..obj[st].." "
							end
						end
						if obj.level >= 10 and obj.slot
							local skname = ICO_SKILLCARD..(attackDefs[obj.slot] and attackDefs[obj.slot].name or "INVALID SKILL")
							desc = $.."\n"..skname
						end

						V_drawString(v, x+20, lowesty + 64, desc, "NFNT", 0, nil, 0, 31)
						renderRarity(v, x+16+150, lowesty+62, obj.rarity)
						-- draw wpn element (wow!)
						if obj.element
							v.drawScaled((x+6+150)<<FRACBITS, (lowesty+63)<<FRACBITS, FRACUNIT/4, v.cachePatch("AT2_"..atk_constant_2_num[obj.element]))
						end							
					end

					ty = $+10

				-- tab 3: Rings
				elseif mo.shop.tab == 3

					-- theoritically we don't *care* if you already have a ring

					V_drawString(v, x+20, ty, buildRingName(obj), "NFNT", 0, nil, colour, 31)
					local cost = elt[2] or evaluateRingPrice(obj)
					V_drawString(v, x+175, ty, (i == mo.shop.choice and "x " or "")..(cost)..currency, "NFNT", 0, "right", 0, 31)
					if i == mo.shop.choice
						-- draw the total... (not for skillcards/pers
						V_drawString(v, x+175, ty, "=\x82"..(cost*mo.shop.quantity)..currency, "NFNT", 0, nil, 0, 31)
						-- Also draw the item description...
						v.drawFill(x+16, lowesty + 61, 200, 1, 135)

						local desc = "DEF: "..(obj.def/10).."\n"
						local stats = {"HP", "SP"}
						for i = 1, #stats do
							local st = stats[i]:lower()

							if obj[st]
								desc = $..stats[i]..": "..obj[st].." "
							end
						end

						V_drawString(v, x+20, lowesty + 64, desc, "NFNT", 0, nil, 0, 31)
						renderRarity(v, x+16+150, lowesty+62, obj.rarity)
					end

					ty = $+10

				-- tab 4: Skill cards
				elseif mo.shop.tab == 4
					-- Item name:
					local colour = 0
					for j = 1, #server.P_BattleStatus[mo.player.P_party].skillcards do
						if server.P_BattleStatus[mo.player.P_party].skillcards[j] == obj
							colour = 16	-- we already have that skillcard, grey it out.
						end
					end

					V_drawString(v, x+20, ty, ICO_SKILLCARD..attackDefs[obj].name, "NFNT", 0, nil, colour, 31)
					local cost = elt[2] or 0
					V_drawString(v, x+170, ty, (cost)..currency, "NFNT", 0, "right", colour, 31)

					if i == mo.shop.choice
						-- Also draw the item description...
						v.drawFill(x+16, lowesty + 61, 200, 1, 135)
						V_drawString(v, x+20, lowesty + 64, attackDefs[obj].desc, "NFNT", 0, nil, 0, 31)
					end

					ty = $+10

				-- PLEASE GIVE ME SWITCH CASES :saddestcat:
				-- tab 5: Sub-Personas
				elseif mo.shop.tab == 5
					-- Item name:
					local colour = 0
					for j = 1, #server.P_BattleStatus[mo.player.P_party].subpersonas do
						if server.P_BattleStatus[mo.player.P_party].subpersonas[j].int == obj
							colour = 16	-- we already have that skillcard, grey it out.
						end
					end

					V_drawString(v, x+20, ty, ICO_PERSONA..subpersonaList[obj].name, "NFNT", 0, nil, colour, 31)
					local cost = elt[2] or 0
					V_drawString(v, x+170, ty, (cost)..currency, "NFNT", 0, "right", colour, 31)

					if i == mo.shop.choice
						-- Also draw the item description...
						v.drawFill(x+16, lowesty + 61, 200, 1, 135)
						--V_drawString(v, x+20, lowesty + 64, attackDefs[obj].desc, "NFNT", 0, nil, 0, 31)
						-- Create a description:
						local subp = subpersonaList[obj]

						-- basic info
						local desc = subp.name..", Lv "..subp.lv.."\n"

						-- stats
						local stats = {"st", "ma", "en", "ag", "lu"}
						for j = 1, #stats do
							desc = $..(stats[j]:upper())..":"..(subp[stats[j]])..(j < #stats and ", " or "")
						end
						desc = $.."\n"

						-- skills
						for j = 1, #subp.skills do
							local sk = attackDefs[subp.skills[j]]
							if not sk continue end

							desc = $..sk.name..(j < #subp.skills and ", " or "")
						end

						V_drawString(v, x+20, lowesty + 64, desc, "NFNT", 0, nil, 0, 31)
					end

					ty = $+10
				end

			end
		end
		showmoney = true
		moneytimer = timer
	end

	-- when applicable, display choices:
	local choices = shop_choices[mo.shop.shopstate]

	if choices and #choices
		local top = 130 + mo.shop.hudtimers.inshop*16 - 18 - (16*(#choices-1))
		local dx = 210
		for i = 1, #choices
			local c = choices[i]
			local dy = top + (i-1)*16 + (mo.shop.hudtimers.inshop*20 or 0)

			if mo.shop.textchoice == i
				PDraw(v, dx, dy, v.cachePatch("H_TBOXS2"), V_SNAPTOBOTTOM)
				V_drawString(v, 210 + 40, dy + 5, c, "NFNT", V_SNAPTOBOTTOM, "center", 31, 138)
			else
				PDraw(v, dx, dy, v.cachePatch("H_TBOXS1"), V_SNAPTOBOTTOM|V_30TRANS)
				V_drawString(v, dx + 40, dy + 5, c, "NFNT", V_SNAPTOBOTTOM, "center", 0, 31)
			end
		end
	end

	-- text box whenever applicable:
	local tdata = mo.shop.currtextdata
	if tdata
		local name = tdata[1]
		local text = tdata[2]
		local portrait = tdata[3]
		local colour = tdata[4]
		local timer = mo.shop.hudtimers.inshop
		local texttimer = mo.shop.texttimer

		R_drawTextBox(v, name, text, portrait, colour, timer, texttimer)
	end

	if showmoney	-- show that at the end to make sure it's not overlapped.
		drawMoney(v, mo, moneytimer)
	end

	return true	-- running
end)