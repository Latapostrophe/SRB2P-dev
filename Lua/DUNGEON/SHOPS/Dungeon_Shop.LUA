-- Time to waste 8 mil Meseta to buy a very revealing outfit- wait, wrong game.
-- 31/05/2021: ^ this aged like fine milk, now it costs 100mil to see tiddie.

-- This handles shopping!

local shopstates = {
	"SS_MAIN",			-- Buy, Sell or Leave
	"SS_BUY",			-- Buying
	"SS_BUYCONFIRM",	-- confirm buying
	"SS_CANTBUY",		-- you're broke
	"SS_DUPLICATE",		-- You already have that!!!
	"SS_STOCKFULL",		-- too many subpersonas.
	"SS_BOUGHT",		-- Just bought something
	"SS_SELL",			-- Selling
	"SS_CANTSELL",		-- Important item
	"SS_SELLCONFIRM",	-- Sell confirm
	"SS_SOLDOUT",		-- someone sold what you wanted to sell!?
	"SS_SELLEQUIPPED",	-- we are trying to sell something that's equipped by someone
	"SS_SOLD",			-- Just sold something
	"SS_LEAVE",			-- Leaving
}

for i = 1, #shopstates do
	rawset(_G, shopstates[i], i)
end

-- A list of available shops
rawset(_G, "shopList", {})


local function validateShopLevel(source, dest, level)

	if not source or not dest return end
	if not level then level = 99 end

	for i = 1, #source do

		if (not source[i][3] or source[i][3] and level >= source[i][3]) and (not source[i][4] or source[i][4] and level <= source[i][4])
			--dprint("Validated "..tostring(source[i][1]))
			table.insert(dest, source[i])
		end
	end
end

rawset(_G, "DNG_stopShop", function(mo, nomenu)
	mo.shop = {}	-- empty the table
	if server.gamemode ~= GM_VOIDRUN
		S_ChangeMusic(mapmusname, true, mo.player, nil, nil, 400)
	end
	-- default music fades back.
	if not nomenu
		M_openMenu(mo, "m_selectfacility")
		return
	end

	PLAY_move(mo.player)	-- allow the player to move again
end)

local function SHOP_getSellInfo(mo)
	-- do the same for shit we can sell:
	local btl = server.P_BattleStatus[mo.player.P_party]

	local sellitems = btl.items
	local sellweapons = btl.weapons
	local sellarmour = btl.armours
	local sellskillcards = btl.skillcards
	local sellpersonas = btl.subpersonas

	if #sellpersonas < 2
		sellpersonas = {}	-- yeah no, fake it!
	end

	local tabssell = {
		sellitems,
		sellweapons,
		sellarmour,
		sellskillcards,
		sellpersonas,
	}

	local sellfirsttab = 1
	local rec = 0

	while not #tabssell[sellfirsttab]
	and sellfirsttab < #tabssell	-- wtf.
		sellfirsttab = $+1

		if rec >= 5
			sellfirsttab = -1
			break	-- wtf!
		end
		rec = $+1
	end

	return tabssell, sellfirsttab
end

local function SHOP_updateSellInfo(mo)
	local tabs, firsttab = SHOP_getSellInfo(mo)
	mo.shop.selltabs = tabs
	mo.shop.sellfirsttab = firsttab
end

local function SHOP_validateWeapons(mo, source, dest)
	local party = server.plentities[mo.player.P_party]

	for i = 1, #source
		for j = 1, #party do
			if canEquipWeapon(party[j], source[i][1])
				table.insert(dest, source[i])
				break
			end
		end
	end
end

rawset(_G, "DNG_startShop", function(mo, shop)
	dprint("Attempting to open shop "..shop)
	if mo.shop and mo.shop.shopping return end	-- what
	local btl = server.P_BattleStatus[mo.player.P_party]

	local data = shopList[shop]
	if not data return end	-- what

	M_closeMenu(mo)	-- close any open menu to avoid conflicts
	if server.gamemode ~= GM_VOIDRUN
		S_ChangeMusic("SHOP", true, mo.player, nil, nil, 400)
	end

	-- generate tabs for shit we can buy
	local items = {}
	local weapons = {}
	local weapons_sorted = {}
	local armour = {}
	local skillcards = {}
	local subpersonas = {}

	local diff = server.difficulty
	if server.gamemode == GM_VOIDRUN
		diff = server.P_DungeonStatus.VR_challenge
	end

	validateShopLevel(data.items, items, diff)
	validateShopLevel(data.weapons, weapons, diff)
	validateShopLevel(data.armour, armour, diff)
	validateShopLevel(data.skillcards, skillcards, diff)
	validateShopLevel(data.subpersonas, subpersonas, diff)

	SHOP_validateWeapons(mo, weapons, weapons_sorted)

	local shoptabs = {
		items,
		weapons_sorted,
		armour,
		skillcards,
		subpersonas,
	}

	local rec = 0
	local firsttab = 1
	while not #shoptabs[firsttab]
	and firsttab < #shoptabs	-- wtf.
		firsttab = $+1

		if rec >= 5
			firsttab = -1
			break	-- wtf!
		end
		rec = $+1
	end

	-- do the same for shit we can sell:
	local tabssell, sellfirsttab = SHOP_getSellInfo(mo)

	mo.shop = {
		shopping = true,
		shopname = shop,

		curtextdata = {},
		textchoice = 1,
		maxtestchoice = 1,	-- # of max text choices.
		texttimer = 0,
		hudtimers = {},

		shopstate = SS_MAIN,

		-- this is used buying:
		buytabs = shoptabs,	-- shit we can buy
		firsttabbuy = firsttab,	-- we start on the first tab
		tabs = {},		-- the actual shit to display
		tab = 1,		-- the shit to display from
		choice = 1,		-- on the 1st item
		maxchoice = 1,	-- max choice for selling
		quantity = 1,	-- and we're only buying one. duh.

		-- and for selling:
		-- choice & quantity are shared between buy/sell.
		selltabs = tabssell,
		firsttabsell = sellfirsttab,

		scroll = 0,		-- offset for item displaying.
	}

	mo.shop.hudtimers.inshop = TICRATE/3	-- start

	-- start the text box
	if data.textdata and data.textdata.welcome
		mo.shop.currtextdata = data.textdata.welcome[P_RandomRange(1, #data.textdata.welcome)]
	end
end)

local maxtestchoice_lookup = {

	[SS_MAIN] = 3,
	[SS_BUYCONFIRM] = 2,
	[SS_SELLCONFIRM] = 2,
}

local function handleTextChoices(mo)

	local inpt = mo.P_inputs
	--print(inpt)
	--print(inpt["up"])
	if inpt["up"] == 1
		mo.shop.textchoice = $-1
		if not mo.shop.textchoice
			mo.shop.textchoice = mo.shop.maxtextchoice
		end
		S_StartSound(nil, sfx_hover, mo.player)

	elseif inpt["down"] == 1
		mo.shop.textchoice = $+1
		if mo.shop.textchoice > mo.shop.maxtextchoice
			mo.shop.textchoice = 1
		end
		S_StartSound(nil, sfx_hover, mo.player)
	elseif inpt[BT_JUMP] == 1
		S_StartSound(nil, sfx_confir, mo.player)
		return mo.shop.textchoice
	end
end


local state_to_textdata = {
		[SS_MAIN] = "welcome",
		[SS_BUY] = "buying",
		[SS_BUYCONFIRM] = "buyconfirm",
		[SS_CANTBUY] = "broke",
		[SS_SELL] = "selling",
		[SS_CANTSELL] = "cantsell",
		[SS_BOUGHT] = "buy",
		[SS_SOLD] = "sell",
		[SS_SELLCONFIRM] = "sellconfirm",
		[SS_SOLDOUT] = "soldout",
		[SS_SELLEQUIPPED] = "sellequipped",
		[SS_LEAVE] = "leave",
		[SS_DUPLICATE] = "buydupe",
}

local function DNG_changeShopState(mo, state)
	if not mo.shop or not mo.shop.shopping return end
	if not state return end

	mo.shop.shopstate = state

	local data = shopList[mo.shop.shopname]
	local texttable = data.textdata[state_to_textdata[state]]

	if state == SS_BUYCONFIRM	-- special garbage...
		if mo.shop.tab == 4	-- skill cards
			texttable = data.textdata.buycard or $	-- !?
		elseif mo.shop.tab == 5	-- subp
			texttable = data.textdata.buypersona or $	-- !?
		end

	elseif state == SS_SELLCONFIRM
		if mo.shop.tab > 3	-- Skill cards & above
			texttable = data.textdata.sellother
		end
	end


	mo.shop.hudtimers.newstate = TICRATE/3
	mo.shop.textchoice = 1	-- reset this, always.
	if texttable and #texttable
	and (state == SS_BUYCONFIRM or state == SS_SELLCONFIRM or not mo.shop.hudtimers.textwait)	-- special hack

		mo.shop.hudtimers.textwait = 0	-- kill that
		mo.shop.texttimer = 0
		local currtextdata = texttable[P_RandomRange(1, #texttable)]
		-- COPY THAT
		mo.shop.currtextdata = {}
		for i = 1, #currtextdata
			mo.shop.currtextdata[i] = currtextdata[i]
		end

		-- SPECIAL CASE FOR BUYCONFIRM & SELLCONFIRM
		if state == SS_BUYCONFIRM
		or state == SS_SELLCONFIRM
			local t = mo.shop.currtextdata[2]
			local list = mo.shop.tabs[mo.shop.tab]
			local item = (state == SS_BUYCONFIRM or mo.shop.tab < 4) and list[mo.shop.choice][1] or list[mo.shop.choice]
			-- bit hacky as usual....

			if mo.shop.tab == 1	-- Items
				t = t:gsub("%%NAME%%", "\x82"..ICO_ITEM..itemDefs[item].name.."\x80")
				t = t:gsub("%%QUANTITY%%", "\x82"..mo.shop.quantity.."\x80")
				t = t:gsub("%%COST%%", "\x82"..(mo.shop.moneybuf)..currency.."\x80")

			elseif mo.shop.tab == 2	-- Weapons
				t = t:gsub("%%NAME%%", buildWeaponName(item))
				t = t:gsub("%%QUANTITY%%", "\x82"..mo.shop.quantity.."\x80")
				t = t:gsub("%%COST%%", "\x82"..(mo.shop.moneybuf)..currency.."\x80")

			elseif mo.shop.tab == 3	-- Rings
				t = t:gsub("%%NAME%%", buildRingName(item))
				t = t:gsub("%%QUANTITY%%", "\x82"..mo.shop.quantity.."\x80")
				t = t:gsub("%%COST%%", "\x82"..(mo.shop.moneybuf)..currency.."\x80")

			elseif mo.shop.tab == 4	-- Skillcards

				t = t:gsub("%%NAME%%", "\x82"..ICO_SKILLCARD..attackDefs[item].name.."\x80")
				t = t:gsub("%%COST%%", "\x82"..(mo.shop.moneybuf)..currency.."\x80")

			elseif mo.shop.tab == 5	-- Subpersonas...
				if state == SS_BUYCONFIRM
					t = t:gsub("%%NAME%%", "\x82"..ICO_PERSONA..subpersonaList[item].name.."\x80")
				else
					t = t:gsub("%%NAME%%", "\x82"..item.name.."\x80")	-- oh well (tm)
				end
				t = t:gsub("%%COST%%", "\x82"..(mo.shop.moneybuf)..currency.."\x80")
			end

			mo.shop.currtextdata[2] = t
		end
	end
end

local function SHOP_sellParanoia(mo, t)
	SHOP_updateSellInfo(mo)	-- continuously update shop info...
	local maxc = #t

	if mo.shop.choice > maxc
		mo.shop.choice = maxc
		if maxc > 6	-- fix the scrolling, potentially...
			mo.shop.scroll = maxc-6	-- first 3 items, 3 last items
		end
	end

	if not maxc
		-- !!
		-- attempt to find the next free tab

		mo.shop.choice = 1
		mo.shop.scroll = 0	-- reset these asap

		local rec = 0
		while not maxc
			mo.shop.tab = $+1
			if mo.shop.tab > 5
				mo.shop.tab = 1
			end

			maxc = #mo.shop.tabs[mo.shop.tab]
			rec = $+1

			if rec > 5
				return true
			end	-- something went horribly wrong
		end
	end
end

local function handleShopChoices(mo, table, sell)

	local inpt = mo.P_inputs
	local maxc = #table

	local maxqty = 99
	if sell
		if SHOP_sellParanoia(mo, table)	-- everything sold out??!
			return -1	-- force exit
		end

		-- change that to whatever we have!
		if mo.shop.tab == 1	-- items
		and maxc
			-- fine the item:
			local it = mo.shop.tabs[mo.shop.tab][mo.shop.choice][1]
			local itemlist = server.P_BattleStatus[mo.player.P_party].items

			for i = 1, #itemlist do
				if itemlist[i][1] == it
					maxqty = itemlist[i][2]
					break
				end	-- yep.
			end
		end
	end

	mo.shop.quantity = min($, maxqty)

	--print(inpt)
	--print(inpt["up"])
	if inpt["up"] == 1
	and maxc
		mo.shop.choice = $-1
		if sell
			mo.shop.quantity = 1
		end

		if mo.shop.choice < maxc-3	-- start scrolling
		and mo.shop.scroll		-- make sure we can still scroll lmao
			mo.shop.scroll = $-1
		end

		if not mo.shop.choice
			mo.shop.choice = maxc
			if maxc > 6
				mo.shop.scroll = maxc-6	-- first 3 items, 3 last items
			end
		end
		S_StartSound(nil, sfx_hover, mo.player)

	elseif inpt["down"] == 1
	and maxc
		mo.shop.choice = $+1
		if sell
			mo.shop.quantity = 1
		end

		if mo.shop.choice-mo.shop.scroll > 3	-- start scrolling
		and mo.shop.choice < maxc-2	-- stop scrolling past this point
		and maxc > 6
			mo.shop.scroll = $+1
		end

		if mo.shop.choice > maxc
			mo.shop.choice = 1
			mo.shop.scroll = 0		-- reset
		end
		S_StartSound(nil, sfx_hover, mo.player)

	elseif (inpt["right"] == 1 or inpt["right"] > TICRATE/2)
	and maxc

		if mo.shop.tab < 4	-- not skill cards/personas!!

			mo.shop.quantity = $+1
			if mo.shop.quantity > maxqty
				mo.shop.quantity = 1
			end
			S_StartSound(nil, sfx_hover, mo.player)
		end

	elseif (inpt["left"] == 1 or inpt["left"] > TICRATE/2)
	and maxc

		if mo.shop.tab < 4	-- not skill cards/personas!!

			mo.shop.quantity = $-1
			if mo.shop.quantity < 1
				mo.shop.quantity = maxqty
			end
			S_StartSound(nil, sfx_hover, mo.player)
		end

	elseif inpt[BT_WEAPONPREV] == 1	-- L
		mo.shop.quantity = 1
		mo.shop.choice = 1
		mo.shop.scroll = 0

		mo.shop.tab = $-1
		if mo.shop.tab < 1
			mo.shop.tab = #mo.shop.tabs
		end
		while (not mo.shop.tabs[mo.shop.tab] or not #mo.shop.tabs[mo.shop.tab])
			mo.shop.tab = $-1
			if mo.shop.tab < 1
				mo.shop.tab = #mo.shop.tabs
			end
		end
		S_StartSound(nil, sfx_hover, mo.player)


	elseif inpt[BT_WEAPONNEXT] == 1	-- R
		mo.shop.quantity = 1
		mo.shop.choice = 1
		mo.shop.scroll = 0

		mo.shop.tab = $+1
		if mo.shop.tab > #mo.shop.tabs
			mo.shop.tab = 1
		end
		while (not mo.shop.tabs[mo.shop.tab] or not #mo.shop.tabs[mo.shop.tab])
			mo.shop.tab = $+1
			if mo.shop.tab > #mo.shop.tabs
				mo.shop.tab = 1
			end
		end
		S_StartSound(nil, sfx_hover, mo.player)

	elseif inpt[BT_JUMP] == 1
	and maxc
		return mo.shop.choice
	end
end

rawset(_G, "DNG_handleShop", function(mo)

	if not mo.shop return end
	if not mo.shop.shopping return end

	local data = shopList[mo.shop.shopname]
	local inpt = mo.P_inputs
	local btl = server.P_BattleStatus[mo.player.P_party]

	PLAY_nomove(mo.player)

	-- handle hudtimers:
	for k,p in pairs(mo.shop.hudtimers)
		mo.shop.hudtimers[k] = max(0, $-1)
	end
	mo.shop.texttimer = $+1		-- always increment this

	-- little hack:
	if mo.shop.hudtimers and mo.shop.hudtimers.textwait
	and mo.shop.hudtimers.textwait == 1	-- switch that back!

		local texttable = shopList[mo.shop.shopname].textdata[state_to_textdata[mo.shop.shopstate]]

		if texttable and #texttable
			local currtextdata = texttable[P_RandomRange(1, #texttable)]
			-- COPY THAT
			mo.shop.currtextdata = {}
			for i = 1, #currtextdata
				mo.shop.currtextdata[i] = currtextdata[i]
			end
			mo.shop.texttimer = 0	-- and reset that!
			mo.shop.hudtimers.textwait = nil
		end
	end

	mo.shop.maxtextchoice = maxtestchoice_lookup[mo.shop.shopstate]

	if mo.shop.shopstate == SS_MAIN
		local choice = handleTextChoices(mo)

		local choice_to_shopstate = {
			SS_BUY,
			SS_SELL,
			SS_LEAVE,
		}

		local newstate = choice_to_shopstate[choice]

		if inpt[BT_SPIN] == 1
			S_StartSound(nil, sfx_cancel, mo.player)
			newstate = SS_LEAVE
		end	-- hack hack hack lmaooo

		if newstate
			-- set the proper item tables for buying/selling, duh!

			mo.shop.choice = 1
			mo.shop.scroll = 0	-- reset these!

			if newstate == SS_BUY
				mo.shop.tabs = mo.shop.buytabs
				mo.shop.tab = mo.shop.firsttabbuy
			elseif newstate == SS_SELL
				SHOP_updateSellInfo(mo)

				-- count available tabs...
				if mo.shop.sellfirsttab < 0
					-- Nothing to sell!!
					S_StartSound(nil, sfx_not, p)
					return
				end

				mo.shop.tabs = mo.shop.selltabs
				mo.shop.tab = mo.shop.firsttabsell
			end
			DNG_changeShopState(mo, newstate)
		end

	elseif mo.shop.shopstate == SS_LEAVE	-- Goodbye!
		if not mo.shop.hudtimers.leave
		and mo.shop.currtextdata	-- base off the timer from the length of the text to be displayed:
			mo.shop.hudtimers.leave = mo.shop.currtextdata[2]:len() + TICRATE/2
		end

		if mo.shop.hudtimers.leave == 1
			DNG_stopShop(mo)
			return
		end

	elseif mo.shop.shopstate == SS_SELL
		local choice = handleShopChoices(mo, mo.shop.tabs[mo.shop.tab], true)

		local price = 0
		local it = mo.shop.tabs[mo.shop.tab][mo.shop.choice]
		local selected

		if mo.shop.tab == 5	-- special case for personas... dear god..
			mo.shop.choice = max($, 2)
			mo.shop.scroll = max($, 1)	-- yes this is a horrible hack but we need to hide the first entry. LOL.
		end

		if choice and choice ~= -1

			if mo.shop.tab == 1	-- ITEMS

				selected = it[1]

				if itemDefs[selected] and itemDefs[selected].cost
					price = itemDefs[selected].cost/8
				end
				price = $*mo.shop.quantity

				mo.shop.moneybuf = price
				mo.shop.choicebuf = it

				if not price
					S_StartSound(nil, sfx_not, mo.player)
					DNG_changeShopState(mo, SS_CANTSELL)
				else
					S_StartSound(nil, sfx_confir, mo.player)
					DNG_changeShopState(mo, SS_SELLCONFIRM)
				end

			elseif mo.shop.tab == 2	-- Weapons
				selected = it

				local price = evaluateWeaponPrice(it)/8
				mo.shop.choicebuf = it
				mo.shop.moneybuf = price

				if not price
					S_StartSound(nil, sfx_not, mo.player)
					DNG_changeShopState(mo, SS_CANTSELL)
				else
					S_StartSound(nil, sfx_confir, mo.player)
					DNG_changeShopState(mo, SS_SELLCONFIRM)
				end

			elseif mo.shop.tab == 3	-- Rings
				selected = it

				local price = evaluateRingPrice(it)/8
				mo.shop.choicebuf = it
				mo.shop.moneybuf = price

				if not price
					S_StartSound(nil, sfx_not, mo.player)
					DNG_changeShopState(mo, SS_CANTSELL)
				else
					S_StartSound(nil, sfx_confir, mo.player)
					DNG_changeShopState(mo, SS_SELLCONFIRM)
				end

			elseif mo.shop.tab == 4	-- SKILL CARD

				selected = it

				local atk = attackDefs[selected]
				-- check if we can work something out from the card's attack power!
				if atk.power
					price = 3*atk.power
				else
					price = 250
				end

				mo.shop.moneybuf = price/8
				mo.shop.choicebuf = it

				if not price
					S_StartSound(nil, sfx_not, mo.player)
					DNG_changeShopState(mo, SS_CANTSELL)
				else
					S_StartSound(nil, sfx_confir, mo.player)
					DNG_changeShopState(mo, SS_SELLCONFIRM)
				end

			elseif mo.shop.tab == 5	-- SubP

				selected = it
				price = selected.level*15

				mo.shop.moneybuf = price
				mo.shop.choicebuf = selected.int	-- make sure we do that...

				-- check if its equipped yada yada
				if selected.equipped
					S_StartSound(nil, sfx_not, mo.player)
					DNG_changeShopState(mo, SS_SELLEQUIPPED)
					return	-- yikes!!
				end

				if not price
					S_StartSound(nil, sfx_not, mo.player)
					DNG_changeShopState(mo, SS_CANTSELL)
				else
					S_StartSound(nil, sfx_confir, mo.player)
					DNG_changeShopState(mo, SS_SELLCONFIRM)
				end
			end

		elseif inpt[BT_USE] == 1
		or choice == -1	-- this only happens if everything somehow sold out
			S_StartSound(nil, sfx_cancel, mo.player)
			DNG_changeShopState(mo, SS_MAIN)
		end

	elseif mo.shop.shopstate == SS_BUY
		local choice = handleShopChoices(mo, mo.shop.tabs[mo.shop.tab])
		-- :osht:

		if choice
			-- Get the item price, and check if we have enough money or are broke ass mfs.
			local it = mo.shop.tabs[mo.shop.tab][mo.shop.choice]
			local selected = it[1]
			local price = 0
			local duplicate = 0

			if mo.shop.tab == 1	-- ITEM.
				if it[2]
					price = it[2]*mo.shop.quantity	-- predefined price
				else
					price = (itemDefs[selected].cost or 0)*mo.shop.quantity	-- normal item price
				end

			elseif mo.shop.tab == 2 	-- WEAPON
				if it[2]
					price = it[2]*mo.shop.quantity
				else
					price = evaluateWeaponPrice(selected)*mo.shop.quantity
				end

			elseif mo.shop.tab == 3		-- RINGS
				if it[2]
					price = it[2]*mo.shop.quantity
				else
					price = evaluateRingPrice(selected)*mo.shop.quantity
				end

			elseif mo.shop.tab == 4	-- SKILL CARD

				-- check for duplicates:
				for i = 1, #btl.skillcards do
					if btl.skillcards[i] == selected
						DNG_changeShopState(mo, SS_DUPLICATE)
						S_StartSound(nil, sfx_not, mo.player)
						return
					end
				end

				price = it[2]	-- no other option.

			elseif mo.shop.tab == 5	-- SUB-PERSONA

				-- check for duplicates:

				if #btl.subpersonas >= btl.subpersonastock
					DNG_changeShopState(mo, SS_STOCKFULL)
					S_StartSound(nil, sfx_not, mo.player)
					return
				end

				for i = 1, #btl.subpersonas do
					if btl.subpersonas[i].int == selected
						DNG_changeShopState(mo, SS_DUPLICATE)
						S_StartSound(nil, sfx_not, mo.player)
						return
					end
				end

				price = it[2]	-- no other option.
			end

			local money = server.P_BattleStatus[mo.player.P_party].macca
			mo.shop.moneybuf = price	-- keep this in memory for the other stuff, it's much easyer.

			S_StartSound(nil, money >= price and sfx_confir or sfx_not, mo.player)
			DNG_changeShopState(mo, money >= price and SS_BUYCONFIRM or SS_CANTBUY)
		elseif inpt[BT_USE] == 1
			S_StartSound(nil, sfx_cancel, mo.player)
			DNG_changeShopState(mo, SS_MAIN)
		end

	-- some wait timers for buying
	elseif mo.shop.shopstate == SS_CANTBUY	-- you're broke, my dude...
	or mo.shop.shopstate == SS_DUPLICATE	-- this works here just as well tbh
	or mo.shop.shopstate == SS_STOCKFULL
	or mo.shop.shopstate == SS_BOUGHT

		if not mo.shop.hudtimers.textwait	-- hacky special timer
		and mo.shop.currtextdata	-- base off the timer from the length of the text to be displayed:
			mo.shop.hudtimers.textwait = mo.shop.currtextdata[2]:len() + TICRATE/2
		end

		DNG_changeShopState(mo, SS_BUY)
		mo.shop.hudtimers.newstate = 0	-- A bit of a hack, but since we aren't transitionning here, don't do that.

	-- same as above, but for selling
	elseif mo.shop.shopstate == SS_CANTSELL
	or mo.shop.shopstate == SS_SOLD
	or mo.shop.shopstate == SS_SOLDOUT	-- lmfao
	or mo.shop.shopstate == SS_SELLEQUIPPED	-- :a:

		if not mo.shop.hudtimers.textwait
		and mo.shop.currtextdata	-- base off the timer from the length of the text to be displayed:
			mo.shop.hudtimers.textwait = mo.shop.currtextdata[2]:len() + TICRATE/2
		end

		DNG_changeShopState(mo, SS_SELL)
		mo.shop.hudtimers.newstate = 0	-- A bit of a hack, but since we aren't transitionning here, don't do that.

	-- Sell confirmation
	elseif mo.shop.shopstate == SS_SELLCONFIRM	-- WHERE ARE MY SWITCH CASES PLEASSSSEEEE
		-- Again, a stupid hack...
		-- make sure we can still sell the shit:

		-- if the item we have selected suddenly disappeared, it's been equipped or sold, so "error" out!

		if mo.shop.tab == 1	-- normal items...
			if not mo.shop.choicebuf
			or mo.shop.choicebuf[2] < mo.shop.quantity
				-- oops!
				S_StartSound(nil, sfx_not, mo.player)
				DNG_changeShopState(mo, SS_SOLDOUT)
				return
			end

		elseif mo.shop.tab == 2	-- Weapons
			local found
			for i = 1, #btl.weapons do
				--print(tostring(btl.weapons[i]).."|"..tostring(mo.shop.choicebuf))
				if btl.weapons[i] == mo.shop.choicebuf
					found = 1
					break
				end
			end

			if not found	-- yikes!
				S_StartSound(nil, sfx_not, mo.player)
				DNG_changeShopState(mo, SS_SOLDOUT)
				return
			end

		elseif mo.shop.tab == 3	-- Rings
			local found
			for i = 1, #btl.armours do
				if btl.armours[i] == mo.shop.choicebuf
					found = 1
					break
				end
			end

			if not found	-- yikes!
				S_StartSound(nil, sfx_not, mo.player)
				DNG_changeShopState(mo, SS_SOLDOUT)
				return
			end

		elseif mo.shop.tab == 4	-- skillcards
			local found
			for i = 1, #btl.skillcards do
				if btl.skillcards[i] == mo.shop.choicebuf
					found = 1
					break
				end
			end

			if not found	-- yikes!
				S_StartSound(nil, sfx_not, mo.player)
				DNG_changeShopState(mo, SS_SOLDOUT)
				return
			end
		elseif mo.shop.tab == 5	-- Subpersonas
			local found
			for i = 2, #btl.subpersonas do
				if btl.subpersonas[i].int == mo.shop.choicebuf
					found = 1
					break
				end
			end

			if not found
				S_StartSound(nil, sfx_not, mo.player)
				DNG_changeShopState(mo, SS_SOLDOUT)
				return
			end
		end

		local choice = handleTextChoices(mo)

		if choice == 1	-- Sell
			BTL_getMacca(server.P_BattleStatus[mo.player.P_party], mo.shop.moneybuf)
			server.P_BattleStatus[mo.player.P_party].netstats.itemssold = $+1

			if mo.shop.tab == 1	-- Items
				-- Use it.
				for i = 1, #btl.items do
					if btl.items[i] == mo.shop.choicebuf
						for j = 1, mo.shop.quantity
							BTL_useItem(btl, i)
						end	-- get rid of quantity of em
						break
					end
				end

			elseif mo.shop.tab == 2	-- Weapons
				removeWeapon(mo, mo.shop.choicebuf)

			elseif mo.shop.tab == 3	-- Rings
				removeRing(mo, mo.shop.choicebuf)

			elseif mo.shop.tab == 4	-- Skill cards
				for i = 1, #btl.skillcards do
					if btl.skillcards[i] == mo.shop.choicebuf
						table.remove(btl.skillcards, i)
					end
				end


			elseif mo.shop.tab == 5	-- Sub-Personas
				for i = 1, #btl.subpersonas do
					if btl.subpersonas[i] and btl.subpersonas[i].int == mo.shop.choicebuf
						table.remove(btl.subpersonas, i)
					end
				end
			end

			S_StartSound(nil, sfx_chchng, mo.player)
			DNG_changeShopState(mo, SS_SOLD)
			mo.shop.hudtimers.newstate = 0

		elseif choice == 2
		or inpt[BT_USE] == 1	-- return
			DNG_changeShopState(mo, SS_SELL)
			mo.shop.hudtimers.newstate = 0	-- A bit of a hack, but since we aren't transitionning here, don't do that.
		end

	-- Buy confirmation
	elseif mo.shop.shopstate == SS_BUYCONFIRM	-- WHERE ARE MY SWITCH CASES!!!!!
		-- Again, a stupid hack...
		local choice = handleTextChoices(mo)

		if choice == 1		-- Buy

			-- Check Macca to see if we still have enough (another player may have spent the macca while we were confirming...)
			if server.P_BattleStatus[mo.player.P_party].macca < mo.shop.moneybuf
				S_StartSound(nil, sfx_not, mo.player)
				DNG_changeShopState(mo, SS_CANTBUY)
				return
			end

			BTL_getMacca(server.P_BattleStatus[mo.player.P_party], -mo.shop.moneybuf)
			server.P_BattleStatus[mo.player.P_party].netstats.itemsbought = $+1

			-- Case by case: What are we buying?
			local list = mo.shop.tabs[mo.shop.tab]
			local elt = list[mo.shop.choice][1]

			if mo.shop.tab == 1	-- Items!
				BTL_addItem(server.P_BattleStatus[mo.player.P_party], elt, mo.shop.quantity)

			elseif mo.shop.tab == 2	-- Weapons
				for i = 1, mo.shop.quantity
					addWeapon(mo, copyTable(elt))
				end

			elseif mo.shop.tab == 3	-- Rings
				for i = 1, mo.shop.quantity
					addRing(mo, copyTable(elt))
				end

			elseif mo.shop.tab == 4	-- Skill Crd!
				table.insert(server.P_BattleStatus[mo.player.P_party].skillcards, elt)

			elseif mo.shop.tab == 5	-- Sub-Personas
				table.insert(server.P_BattleStatus[mo.player.P_party].subpersonas, P_generateSubPersona(elt))

			end

			S_StartSound(nil, sfx_chchng, mo.player)
			DNG_changeShopState(mo, SS_BOUGHT)	-- You got it!

		elseif choice == 2	-- Nope
			DNG_changeShopState(mo, SS_BUY)
			mo.shop.hudtimers.newstate = 0	-- A bit of a hack, but since we aren't transitionning here, don't do that.
		end
	end
	return true
end)

if srb2p.debug
COM_AddCommand("d_shop", function(p, shopname)
	local mo = p.mo
	if not mo return end

	if not shopname
		shopname = "velvet_shop_mp1"
	end

	DNG_startShop(mo, shopname)
end)
end