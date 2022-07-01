-- item defs

rawset(_G, "buildItemName", function(it)
	if not it return end

	local ico = "\x97"

	if it.key
		ico = "\x9A"
	elseif it.skillcard
		ico = ICO_SKILLCARD
	elseif it.menuonly
		ico = "\xAA"
	elseif it.attack and attackDefs[it.attack]	-- can be used in battle
	and not it.nouse
		ico = "\xA9"
	elseif it.material
		ico = "\xAB"
	end
	return ico..it.name
end)

rawset(_G, "IT_startRareDropAnim", function(p, rarity)

	local mo = p.mo
	rarity = $ or 1
	-- don't overlap.
	if mo.r_raredrop and (rarity < 7 or mo.r_raredrop_rarity == 7) return end

	phud.clear("raredrop")

	mo.r_raredrop = 1
	mo.r_raredrop_rarity = rarity or 1

	S_StartSound(nil, sfx_rdrp1, p)
	if rarity >= 7
		S_StartSound(nil, sfx_rdrp2, p)
	end
end)

local function IT_handleRareDropAnim(p)

	local mo = p.mo
	mo.r_raredrop = $+1

	if mo.r_raredrop >= 100
		mo.r_raredrop_rarity = 0
		mo.r_raredrop = nil
	end
end

addHook("PlayerThink", function(p)

	if p and p.valid and p.mo and p.mo.valid
	and p.mo.r_raredrop
		IT_handleRareDropAnim(p)
	end
end)


rawset(_G, "itemDefs", {

	["homunculus"] = {
		name = "Homunculus",
		desc = "An old doll that is said to \nprotect from curses \nand exorcisms",
		attack = "homunculus",
		homunculus = true,	-- item will void instant death and get consumed.
		nouse = true,		-- cannot be used outside of battle
		rarity = 4,
		cost = 750,
	},

	-- Void Run items

	["vr up"] = {
		name = "Void UP",
		desc = "Some apple juice can.\nGrants 1 extra life in Void Runs.",
		attack = "dummy",
		menuonly = true,
		rarity = 6,
		useall = true,		-- force item to target all in the menu
		menufunc = 	function(user, mo)	-- function to run when using the item from dungeon menu specifically
						-- user: player mo in dungeon
						-- mo: actual entity it was used on (will be a table if it's multi target)

						local dng = server.P_DungeonStatus
						local lives = dng.VR_lives

						if not lives return end	--???????
						dng.VR_lives = $+1

						S_StartSound(nil, sfx_heal4, user.player)
						DNG_logMessage("\x82".."ONE UP! "..(lives).." -> "..lives+1)
					end,
		cost = 2000,
	},

	["levelcap up"] = {
		name = "Void Unlimiter",
		desc = "Some orange juice can.\nRaises party level cap by 1",
		attack = "dummy",
		menuonly = true,
		rarity = 6,
		useall = true,		-- force item to target all in the menu
		checkfunc = 	function(user, mo)	-- so the level cap can't go too high
			if mo.levelcap >= #needEXP-1
				return true
			end
		end,
		menufunc = 	function(user, mo)	-- function to run when using the item from dungeon menu specifically
						-- user: player mo in dungeon
						-- mo: actual entity it was used on (will be a table if it's multi target)

						local lcap = 0
						local pa = server.plentities[user.player.P_party]
						for i = 1, #pa do
							local m = pa[i]
							m.levelcap = $+1
							lcap = m.levelcap
						end
						S_StartSound(nil, sfx_heal4, user.player)
						DNG_logMessage("\x82".."Level cap increased! "..(lcap-1).." -> "..lcap)
					end,
		cost = 0,
	},

	["void booster-w"] = {
		name = "Void Booster-W",
		desc = "Instantly enhance the user's\nweapon to +10.",
		attack = "dummy",
		rarity = 5,
		menuonly = true,
		menufunc = 	function(user, mo)	-- function to run when using the item from dungeon menu specifically
						-- user: player mo in dungeon
						-- mo: actual entity it was used on (will be a table if it's multi target)

						local w = mo.weapon

						if w
							while w.level < 10
								enhanceWeapon(w)
							end
							equipWeapon(mo, w, true)
						end

						S_StartSound(nil, sfx_heal4, user.player)
					end,
		cost = 10,
	},

	["void booster-sw"] = {
		name = "Void Booster-SW",
		desc = "Increase all of the user's weapon\npassive stats by 1\n(+10 max)",
		attack = "dummy",
		rarity = 6,
		menuonly = true,

		checkfunc = function(user, mo)
			local w = mo.weapon

			if w.st >= 10
			and w.ma >= 10
			and w.ag >= 10
			and w.lu >= 10
			and w.en >= 10
				return true
			end
		end,

		menufunc = 	function(user, mo)	-- function to run when using the item from dungeon menu specifically
						-- user: player mo in dungeon
						-- mo: actual entity it was used on (will be a table if it's multi target)

						local w = mo.weapon

						if w
							w.st = min(10, $+1)
							w.ma = min(10, $+1)
							w.ag = min(10, $+1)
							w.lu = min(10, $+1)
							w.en = min(10, $+1)
						end

						equipWeapon(mo, w, true)

						S_StartSound(nil, sfx_heal4, user.player)
					end,
		cost = 10,
	},

	["void booster-r"] = {
		name = "Void Booster-R",
		desc = "Instantly enhance the user's\nwardring to +10.",
		attack = "dummy",
		rarity = 5,
		menuonly = true,
		menufunc = 	function(user, mo)	-- function to run when using the item from dungeon menu specifically
						-- user: player mo in dungeon
						-- mo: actual entity it was used on (will be a table if it's multi target)

						local r = mo.wardring

						if r
							local shp = mo.hp
							local ssp = mo.sp
							while r.level < 10
								enhanceRing(r)
							end
							equipRing(mo, r, true)

							mo.hp = shp
							mo.sp = ssp

						end

						S_StartSound(nil, sfx_heal4, user.player)
					end,
		cost = 10,
	},

	["void booster-sr"] = {
		name = "Void Booster-SR",
		desc = "Increase HP by 10 and SP by 5 on\nthe user's equipped Wardring\n(5 times max)",
		attack = "dummy",
		rarity = 6,
		menuonly = true,

		checkfunc = function(user, mo)

			local r = mo.wardring
			if r.boosted_sr and r.boosted_sr >= 5
				return true
			end
		end,

		menufunc = 	function(user, mo)	-- function to run when using the item from dungeon menu specifically
						-- user: player mo in dungeon
						-- mo: actual entity it was used on (will be a table if it's multi target)

						local r = mo.wardring

						r.boosted_sr = $ or 0
						r.boosted_sr = $+1

						if r
							r.hp = $+10
							r.sp = $+5
						end

						local shp = mo.hp
						local ssp = mo.sp
						equipRing(mo, r, true)
						mo.hp = shp+10
						mo.sp = ssp+5	-- :)

						S_StartSound(nil, sfx_heal4, user.player)
					end,
		cost = 10,
	},

	["str catalyst 1"] = {
		name = "STR Catalyst I",
		desc = "Permanently increases the user's\nStrength by 1. (To a max of +25)",
		attack = "dummy",
		menuonly = true,
		rarity = 3,

		checkfunc = function(user, mo)
			if mo.bonusstrength and mo.bonusstrength >= 25
				return true
			end
		end,

		menufunc = 	function(user, mo)	-- function to run when using the item from dungeon menu specifically
						-- user: player mo in dungeon
						-- mo: actual entity it was used on (will be a table if it's multi target)

						local st = {"strength"}

						for i = 1, #st do
							mo["bonus"..st[i]] = $ or 0
							mo["bonus"..st[i]] = min(25, $+1)
						end
						PLYR_getStats(mo, mo.level, true, true)
						S_StartSound(nil, sfx_heal4, user.player)

					end,
		cost = 100,
	},

	["str catalyst 2"] = {
		name = "STR Catalyst II",
		desc = "Permanently increases the user's\nStrength by 2. (To a max of +25)",
		attack = "dummy",
		menuonly = true,
		rarity = 4,

		checkfunc = function(user, mo)
			if mo.bonusstrength and mo.bonusstrength >= 25
				return true
			end
		end,

		menufunc = 	function(user, mo)	-- function to run when using the item from dungeon menu specifically
						-- user: player mo in dungeon
						-- mo: actual entity it was used on (will be a table if it's multi target)

						local st = {"strength"}

						for i = 1, #st do
							mo["bonus"..st[i]] = $ or 0
							mo["bonus"..st[i]] = min(25, $+2)
						end
						PLYR_getStats(mo, mo.level, true, true)
						S_StartSound(nil, sfx_heal4, user.player)

					end,
		cost = 100,
	},

	["str catalyst 3"] = {
		name = "STR Catalyst III",
		desc = "Permanently increases the user's\nStrength by 3. (To a max of +25)",
		attack = "dummy",
		menuonly = true,
		rarity = 5,

		checkfunc = function(user, mo)
			if mo.bonusstrength and mo.bonusstrength >= 25
				return true
			end
		end,

		menufunc = 	function(user, mo)	-- function to run when using the item from dungeon menu specifically
						-- user: player mo in dungeon
						-- mo: actual entity it was used on (will be a table if it's multi target)

						local st = {"strength"}

						for i = 1, #st do
							mo["bonus"..st[i]] = $ or 0
							mo["bonus"..st[i]] = min(25, $+3)
						end
						PLYR_getStats(mo, mo.level, true, true)
						S_StartSound(nil, sfx_heal4, user.player)

					end,
		cost = 100,
	},


	["mag catalyst 1"] = {
		name = "MAG Catalyst I",
		desc = "Permanently increases the user's\nMagic by 1. (To a max of +25)",
		attack = "dummy",
		menuonly = true,
		rarity = 3,

		checkfunc = function(user, mo)
			if mo.bonusmagic and mo.bonusmagic >= 25
				return true
			end
		end,

		menufunc = 	function(user, mo)	-- function to run when using the item from dungeon menu specifically
						-- user: player mo in dungeon
						-- mo: actual entity it was used on (will be a table if it's multi target)

						local st = {"magic"}

						for i = 1, #st do
							mo["bonus"..st[i]] = $ or 0
							mo["bonus"..st[i]] = min(25, $+1)
						end
						PLYR_getStats(mo, mo.level, true, true)
						S_StartSound(nil, sfx_heal4, user.player)

					end,
		cost = 100,
	},

	["mag catalyst 2"] = {
		name = "MAG Catalyst II",
		desc = "Permanently increases the user's\nMagic by 2. (To a max of +25)",
		attack = "dummy",
		menuonly = true,
		rarity = 4,

		checkfunc = function(user, mo)
			if mo.bonusmagic and mo.bonusmagic >= 25
				return true
			end
		end,

		menufunc = 	function(user, mo)	-- function to run when using the item from dungeon menu specifically
						-- user: player mo in dungeon
						-- mo: actual entity it was used on (will be a table if it's multi target)

						local st = {"magic"}

						for i = 1, #st do
							mo["bonus"..st[i]] = $ or 0
							mo["bonus"..st[i]] = min(25, $+2)
						end
						PLYR_getStats(mo, mo.level, true, true)
						S_StartSound(nil, sfx_heal4, user.player)

					end,
		cost = 100,
	},

	["mag catalyst 3"] = {
		name = "MAG Catalyst III",
		desc = "Permanently increases the user's\nMagic by 3. (To a max of +25)",
		attack = "dummy",
		menuonly = true,
		rarity = 5,

		checkfunc = function(user, mo)
			if mo.bonusmagic and mo.bonusmagic >= 25
				return true
			end
		end,

		menufunc = 	function(user, mo)	-- function to run when using the item from dungeon menu specifically
						-- user: player mo in dungeon
						-- mo: actual entity it was used on (will be a table if it's multi target)

						local st = {"magic"}

						for i = 1, #st do
							mo["bonus"..st[i]] = $ or 0
							mo["bonus"..st[i]] = min(25, $+3)
						end
						PLYR_getStats(mo, mo.level, true, true)
						S_StartSound(nil, sfx_heal4, user.player)

					end,
		cost = 100,
	},

	["end catalyst 1"] = {
		name = "END Catalyst I",
		desc = "Permanently increases the user's\nEndurance by 1. (To a max of +25)",
		attack = "dummy",
		menuonly = true,
		rarity = 3,

		checkfunc = function(user, mo)
			if mo.bonusendurance and mo.bonusendurance >= 25
				return true
			end
		end,

		menufunc = 	function(user, mo)	-- function to run when using the item from dungeon menu specifically
						-- user: player mo in dungeon
						-- mo: actual entity it was used on (will be a table if it's multi target)

						local st = {"endurance"}

						for i = 1, #st do
							mo["bonus"..st[i]] = $ or 0
							mo["bonus"..st[i]] = min(25, $+1)
						end
						PLYR_getStats(mo, mo.level, true, true)
						S_StartSound(nil, sfx_heal4, user.player)

					end,
		cost = 100,
	},

	["end catalyst 2"] = {
		name = "END Catalyst II",
		desc = "Permanently increases the user's\nEndurance by 2. (To a max of +25)",
		attack = "dummy",
		menuonly = true,
		rarity = 4,

		checkfunc = function(user, mo)
			if mo.bonusendurance and mo.bonusendurance >= 25
				return true
			end
		end,

		menufunc = 	function(user, mo)	-- function to run when using the item from dungeon menu specifically
						-- user: player mo in dungeon
						-- mo: actual entity it was used on (will be a table if it's multi target)

						local st = {"endurance"}

						for i = 1, #st do
							mo["bonus"..st[i]] = $ or 0
							mo["bonus"..st[i]] = min(25, $+2)
						end
						PLYR_getStats(mo, mo.level, true, true)
						S_StartSound(nil, sfx_heal4, user.player)

					end,
		cost = 100,
	},

	["end catalyst 3"] = {
		name = "END Catalyst III",
		desc = "Permanently increases the user's\nEndurance by 3. (To a max of +25)",
		attack = "dummy",
		menuonly = true,
		rarity = 5,

		checkfunc = function(user, mo)
			if mo.bonusendurance and mo.bonusendurance >= 25
				return true
			end
		end,

		menufunc = 	function(user, mo)	-- function to run when using the item from dungeon menu specifically
						-- user: player mo in dungeon
						-- mo: actual entity it was used on (will be a table if it's multi target)

						local st = {"endurance"}

						for i = 1, #st do
							mo["bonus"..st[i]] = $ or 0
							mo["bonus"..st[i]] = min(25, $+3)
						end
						PLYR_getStats(mo, mo.level, true, true)
						S_StartSound(nil, sfx_heal4, user.player)

					end,
		cost = 100,
	},

	["agi catalyst 1"] = {
		name = "AGI Catalyst I",
		desc = "Permanently increases the user's\nAgility by 1. (To a max of +25)",
		attack = "dummy",
		menuonly = true,
		rarity = 3,

		checkfunc = function(user, mo)
			if mo.bonusagility and mo.bonusagility >= 25
				return true
			end
		end,

		menufunc = 	function(user, mo)	-- function to run when using the item from dungeon menu specifically
						-- user: player mo in dungeon
						-- mo: actual entity it was used on (will be a table if it's multi target)

						local st = {"agility"}

						for i = 1, #st do
							mo["bonus"..st[i]] = $ or 0
							mo["bonus"..st[i]] = min(25, $+1)
						end
						PLYR_getStats(mo, mo.level, true, true)
						S_StartSound(nil, sfx_heal4, user.player)

					end,
		cost = 100,
	},

	["agi catalyst 2"] = {
		name = "AGI Catalyst II",
		desc = "Permanently increases the user's\nAgility by 2. (To a max of +25)",
		attack = "dummy",
		menuonly = true,
		rarity = 4,

		checkfunc = function(user, mo)
			if mo.bonusagility and mo.bonusagility >= 25
				return true
			end
		end,

		menufunc = 	function(user, mo)	-- function to run when using the item from dungeon menu specifically
						-- user: player mo in dungeon
						-- mo: actual entity it was used on (will be a table if it's multi target)

						local st = {"agility"}

						for i = 1, #st do
							mo["bonus"..st[i]] = $ or 0
							mo["bonus"..st[i]] = min(25, $+2)
						end
						PLYR_getStats(mo, mo.level, true, true)
						S_StartSound(nil, sfx_heal4, user.player)

					end,
		cost = 100,
	},

	["agi catalyst 3"] = {
		name = "AGI Catalyst III",
		desc = "Permanently increases the user's\nAgility by 3. (To a max of +25)",
		attack = "dummy",
		menuonly = true,
		rarity = 5,

		checkfunc = function(user, mo)
			if mo.bonusagility and mo.bonusagility >= 25
				return true
			end
		end,

		menufunc = 	function(user, mo)	-- function to run when using the item from dungeon menu specifically
						-- user: player mo in dungeon
						-- mo: actual entity it was used on (will be a table if it's multi target)

						local st = {"agility"}

						for i = 1, #st do
							mo["bonus"..st[i]] = $ or 0
							mo["bonus"..st[i]] = min(25, $+3)
						end
						PLYR_getStats(mo, mo.level, true, true)
						S_StartSound(nil, sfx_heal4, user.player)

					end,
		cost = 100,
	},

	["luk catalyst 1"] = {
		name = "LUK Catalyst I",
		desc = "Permanently increases the user's\nLuck by 1. (To a max of +25)",
		attack = "dummy",
		menuonly = true,
		rarity = 3,

		checkfunc = function(user, mo)
			if mo.bonusluck and mo.bonusluck >= 25
				return true
			end
		end,

		menufunc = 	function(user, mo)	-- function to run when using the item from dungeon menu specifically
						-- user: player mo in dungeon
						-- mo: actual entity it was used on (will be a table if it's multi target)

						local st = {"luck"}

						for i = 1, #st do
							mo["bonus"..st[i]] = $ or 0
							mo["bonus"..st[i]] = min(25, $+1)
						end
						PLYR_getStats(mo, mo.level, true, true)
						S_StartSound(nil, sfx_heal4, user.player)

					end,
		cost = 100,
	},

	["luk catalyst 2"] = {
		name = "LUK Catalyst II",
		desc = "Permanently increases the user's\nLuck by 2. (To a max of +25)",
		attack = "dummy",
		menuonly = true,
		rarity = 4,

		checkfunc = function(user, mo)
			if mo.bonusluck and mo.bonusluck >= 25
				return true
			end
		end,

		menufunc = 	function(user, mo)	-- function to run when using the item from dungeon menu specifically
						-- user: player mo in dungeon
						-- mo: actual entity it was used on (will be a table if it's multi target)

						local st = {"luck"}

						for i = 1, #st do
							mo["bonus"..st[i]] = $ or 0
							mo["bonus"..st[i]] = min(25, $+2)
						end
						PLYR_getStats(mo, mo.level, true, true)
						S_StartSound(nil, sfx_heal4, user.player)

					end,
		cost = 100,
	},

	["luk catalyst 3"] = {
		name = "LUK Catalyst III",
		desc = "Permanently increases the user's\nLuck by 3. (To a max of +25)",
		attack = "dummy",
		menuonly = true,
		rarity = 5,

		checkfunc = function(user, mo)
			if mo.bonusluck and mo.bonusluck >= 25
				return true
			end
		end,

		menufunc = 	function(user, mo)	-- function to run when using the item from dungeon menu specifically
						-- user: player mo in dungeon
						-- mo: actual entity it was used on (will be a table if it's multi target)

						local st = {"luck"}

						for i = 1, #st do
							mo["bonus"..st[i]] = $ or 0
							mo["bonus"..st[i]] = min(25, $+3)
						end
						PLYR_getStats(mo, mo.level, true, true)
						S_StartSound(nil, sfx_heal4, user.player)

					end,
		cost = 100,
	},

	["void booster-s 1"] = {
		name = "Void Booster-S I",
		desc = "Some lemonade can.\nPermanently increases all of the user's\nstats by 1. (To a max of +25)",
		attack = "dummy",
		menuonly = true,
		rarity = 4,

		checkfunc = function(user, mo)

			if mo.bonusmagic
			and mo.bonusstrength
			and mo.bonusagility
			and mo.bonusendurance
			and mo.bonusluck
			and mo.bonusmagic >= 25
			and mo.bonusstrength >= 25
			and mo.bonusagility >= 25
			and mo.bonusendurance >= 25
			and mo.bonusluck >= 25
				return true
			end

		end,

		menufunc = 	function(user, mo)	-- function to run when using the item from dungeon menu specifically
						-- user: player mo in dungeon
						-- mo: actual entity it was used on (will be a table if it's multi target)

						local st = {"strength", "magic", "endurance", "agility", "luck"}

						for i = 1, #st do
							mo["bonus"..st[i]] = $ or 0
							mo["bonus"..st[i]] = min(25, $+1)
						end
						PLYR_getStats(mo, mo.level, true, true)
						S_StartSound(nil, sfx_heal4, user.player)

					end,
		cost = 100,
	},

	["void booster-s 2"] = {
		name = "Void Booster-S II",
		desc = "Some lemonade can.\nPermanently increases all of the user's\nstats by 2. (To a max of +25)",
		attack = "dummy",
		menuonly = true,
		rarity = 5,

		checkfunc = function(user, mo)

			if mo.bonusmagic
			and mo.bonusstrength
			and mo.bonusagility
			and mo.bonusendurance
			and mo.bonusluck
			and mo.bonusmagic >= 25
			and mo.bonusstrength >= 25
			and mo.bonusagility >= 25
			and mo.bonusendurance >= 25
			and mo.bonusluck >= 25
				return true
			end

		end,

		menufunc = 	function(user, mo)	-- function to run when using the item from dungeon menu specifically
						-- user: player mo in dungeon
						-- mo: actual entity it was used on (will be a table if it's multi target)

						local st = {"strength", "magic", "endurance", "agility", "luck"}

						for i = 1, #st do
							mo["bonus"..st[i]] = $ or 0
							mo["bonus"..st[i]] = min(25, $+2)
						end
						PLYR_getStats(mo, mo.level, true, true)
						S_StartSound(nil, sfx_heal4, user.player)

					end,
		cost = 100,
	},

	["void booster-s 3"] = {
		name = "Void Booster-S III",
		desc = "Some lemonade can.\nPermanently increases all of the user's\nstats by 3. (To a max of +25)",
		attack = "dummy",
		menuonly = true,
		rarity = 6,

		checkfunc = function(user, mo)

			if mo.bonusmagic
			and mo.bonusstrength
			and mo.bonusagility
			and mo.bonusendurance
			and mo.bonusluck
			and mo.bonusmagic >= 25
			and mo.bonusstrength >= 25
			and mo.bonusagility >= 25
			and mo.bonusendurance >= 25
			and mo.bonusluck >= 25
				return true
			end

		end,

		menufunc = 	function(user, mo)	-- function to run when using the item from dungeon menu specifically
						-- user: player mo in dungeon
						-- mo: actual entity it was used on (will be a table if it's multi target)

						local st = {"strength", "magic", "endurance", "agility", "luck"}

						for i = 1, #st do
							mo["bonus"..st[i]] = $ or 0
							mo["bonus"..st[i]] = min(25, $+3)
						end
						PLYR_getStats(mo, mo.level, true, true)
						S_StartSound(nil, sfx_heal4, user.player)

					end,
		cost = 100,
	},

	["soul 1"] = {
		name = "Soul Catalyst I",
		desc = "Permanently raises the user's\nMax SP by 5",
		attack = "dummy",
		rarity = 3,
		menuonly = true,
		menufunc = 	function(user, mo)	-- function to run when using the item from dungeon menu specifically
						-- user: player mo in dungeon
						-- mo: actual entity it was used on (will be a table if it's multi target)
						
						if srb2p.storymode
							if mo.catalystsp + 5 >= episode_limits[1][BOOST_CATALYST]
								--FIXME: Could be more elegant
								mo.maxsp = ($ - mo.catalystsp) + episode_limits[1][BOOST_CATALYST]
								mo.sp = ($ - mo.catalystsp) + episode_limits[1][BOOST_CATALYST]
								mo.realsp = ($ - mo.catalystsp) + episode_limits[1][BOOST_CATALYST]
								mo.catalystsp = 100
								S_StartSound(nil, sfx_heal4, user.player)
							else
								mo.catalystsp = $ + 5
								mo.sp = $ + 5
								mo.maxsp = $ + 5
								mo.realsp = $ + 5
								S_StartSound(nil, sfx_heal4, user.player)
							end
						else
							mo.maxsp = $+5
							mo.sp = $+5
							mo.realsp = $+5
							S_StartSound(nil, sfx_heal4, user.player)
						end
					end,

		cost = 700,
	},

	["soul 2"] = {
		name = "Soul Catalyst II",
		desc = "Permanently raises the user's\nMax SP by 10",
		attack = "dummy",
		rarity = 4,
		menuonly = true,
		menufunc = 	function(user, mo)	-- function to run when using the item from dungeon menu specifically
						-- user: player mo in dungeon
						-- mo: actual entity it was used on (will be a table if it's multi target)

						if srb2p.storymode
							if mo.catalystsp + 10 >= episode_limits[1][BOOST_CATALYST]
								--FIXME: Could be more elegant
								mo.maxsp = ($ - mo.catalystsp) + episode_limits[1][BOOST_CATALYST]
								mo.sp = ($ - mo.catalystsp) + episode_limits[1][BOOST_CATALYST]
								mo.realsp = ($ - mo.catalystsp) + episode_limits[1][BOOST_CATALYST]
								mo.catalystsp = 100
								S_StartSound(nil, sfx_heal4, user.player)
							else
								mo.catalystsp = $ + 10
								mo.sp = $ + 10
								mo.maxsp = $ + 10
								mo.realsp = $ + 10
								S_StartSound(nil, sfx_heal4, user.player)
							end
						else
							mo.maxsp = $+10
							mo.sp = $+10
							mo.realsp = $+10
							S_StartSound(nil, sfx_heal4, user.player)
						end
					end,

		cost = 1200,
	},

	["soul 3"] = {
		name = "Soul Catalyst III",
		desc = "Permanently raises the user's\nMax SP by 20",
		attack = "dummy",
		rarity = 5,
		menuonly = true,
		menufunc = 	function(user, mo)	-- function to run when using the item from dungeon menu specifically
						-- user: player mo in dungeon
						-- mo: actual entity it was used on (will be a table if it's multi target)

						if srb2p.storymode
							if mo.catalystsp + 20 >= episode_limits[1][BOOST_CATALYST]
								--FIXME: Could be more elegant
								mo.maxsp = ($ - mo.catalystsp) + episode_limits[1][BOOST_CATALYST]
								mo.sp = ($ - mo.catalystsp) + episode_limits[1][BOOST_CATALYST]
								mo.realsp = ($ - mo.catalystsp) + episode_limits[1][BOOST_CATALYST]
								mo.catalystsp = 100
								S_StartSound(nil, sfx_heal4, user.player)
							else
								mo.catalystsp = $ + 20
								mo.sp = $ + 20
								mo.maxsp = $ + 20
								mo.realsp = $ + 20
								S_StartSound(nil, sfx_heal4, user.player)
							end
						else
							mo.maxsp = $+20
							mo.sp = $+20
							mo.realsp = $+20
							S_StartSound(nil, sfx_heal4, user.player)
						end
					end,

		cost = 2000,
	},

	["vessel 1"] = {
		name = "Vessel Catalyst I",
		desc = "Permanently raises the user's\nMax HP by 10",
		attack = "dummy",
		rarity = 3,
		menuonly = true,
		menufunc = 	function(user, mo)	-- function to run when using the item from dungeon menu specifically
						-- user: player mo in dungeon
						-- mo: actual entity it was used on (will be a table if it's multi target)

						if srb2p.storymode
							if mo.catalysthp + 10 >= episode_limits[1][BOOST_CATALYST]
								--FIXME: Could be more elegant
								mo.maxhp = ($ - mo.catalysthp) + episode_limits[1][BOOST_CATALYST]
								mo.hp = ($ - mo.catalysthp) + episode_limits[1][BOOST_CATALYST]
								mo.realhp = ($ - mo.catalysthp) + episode_limits[1][BOOST_CATALYST]
								mo.catalysthp = 100
								S_StartSound(nil, sfx_heal4, user.player)
							else
								mo.catalysthp = $ + 10
								mo.hp = $ + 10
								mo.maxhp = $ + 10
								mo.realhp = $ + 10
								S_StartSound(nil, sfx_heal4, user.player)
							end
						else
							mo.maxhp = $+10
							mo.hp = $+10
							mo.realhp = $+10
							S_StartSound(nil, sfx_heal4, user.player)
						end
					end,

		cost = 200,
	},

	["vessel 2"] = {
		name = "Vessel Catalyst II",
		desc = "Permanently raises the user's\nMax HP by 25",
		attack = "dummy",
		rarity = 4,
		menuonly = true,
		menufunc = 	function(user, mo)	-- function to run when using the item from dungeon menu specifically
						-- user: player mo in dungeon
						-- mo: actual entity it was used on (will be a table if it's multi target)

						if srb2p.storymode
							if mo.catalysthp + 25 >= episode_limits[1][BOOST_CATALYST]
								--FIXME: Could be more elegant
								mo.maxhp = ($ - mo.catalysthp) + episode_limits[1][BOOST_CATALYST]
								mo.hp = ($ - mo.catalysthp) + episode_limits[1][BOOST_CATALYST]
								mo.realhp = ($ - mo.catalysthp) + episode_limits[1][BOOST_CATALYST]
								mo.catalysthp = 100
								S_StartSound(nil, sfx_heal4, user.player)
							else
								mo.catalysthp = $ + 25
								mo.hp = $ + 25
								mo.maxhp = $ + 25
								mo.realhp = $ + 25
								S_StartSound(nil, sfx_heal4, user.player)
							end
						else
							mo.maxhp = $+25
							mo.hp = $+25
							mo.realhp = $+25
							S_StartSound(nil, sfx_heal4, user.player)
						end
					end,

		cost = 500,
	},

	["vessel 3"] = {
		name = "Vessel Catalyst III",
		desc = "Permanently raises the user's\nMax HP by 50",
		attack = "dummy",
		rarity = 5,
		menuonly = true,
		menufunc = 	function(user, mo)	-- function to run when using the item from dungeon menu specifically
						-- user: player mo in dungeon
						-- mo: actual entity it was used on (will be a table if it's multi target)

						if srb2p.storymode
							if mo.catalysthp + 50 >= episode_limits[1][BOOST_CATALYST]
								--FIXME: Could be more elegant
								mo.maxhp = ($ - mo.catalysthp) + episode_limits[1][BOOST_CATALYST]
								mo.hp = ($ - mo.catalysthp) + episode_limits[1][BOOST_CATALYST]
								mo.realhp = ($ - mo.catalysthp) + episode_limits[1][BOOST_CATALYST]
								mo.catalysthp = 100
								S_StartSound(nil, sfx_heal4, user.player)
							else
								mo.catalysthp = $ +50
								mo.hp = $ + 50
								mo.maxhp = $ + 50
								mo.realhp = $ + 50
								S_StartSound(nil, sfx_heal4, user.player)
							end
						else
							mo.maxhp = $+50
							mo.hp = $+50
							mo.realhp = $+50
							S_StartSound(nil, sfx_heal4, user.player)
						end
					end,

		cost = 2000,
	},

	-- Special items
	
	["velvet_wallet"] = {
		name = "Velvet Wallet",
		desc = "A wallet that allows you to substitute\nany currency for Macca. There's no \nway its insides are euclidean...",
		key = true,
		rarity = 6,
	},	

	["velvet_key"] = {
		name = "Velvet Key",
		desc = "A strange blue key that allows you \nto enter the Velvet Room.",
		key = true,
		rarity = 6,
	},	
	
	["medal_depths"] = {
		name = "Depths Medal",
		desc = "Gold plated medal awarded to those who\nhave challenged the depths.\nSomeone might be interrested in it.",
		key = true,
		rarity = 6,
	},

	["medal_endurance"] = {
		name = "Enduring Medal",
		desc = "A severely damaged platinum medal.\nIt's a token of its wielder's endurance.\nSomeone might be interrested in it.",
		key = true,
		rarity = 6,
	},

	["medal_hollow"] = {
		name = "Hollow Medal",
		desc = "A blue medal of a foreign material.\nSomehow, it's hollow.\nSomeone might be interrested in it.",
		key = true,
		rarity = 6,
	},

	["medal_challenger"] = {
		name = "Challenger Medal",
		desc = "A diamond medal awarded to those\nwho have vainquished the coliseum.\nSomeone might be interrested in it.",
		key = true,
		rarity = 6,
	},

	["overlimit token 1"] = {
		name = "Overlimit Token I",
		desc = "A token awarded to those who seek power.\nSomeone might be interrested in it.",
		material = true,
		rarity = 5,
	},

	-- Chaos Drives

	["chaos drive"] = {
		name = "Chaos Drive",
		desc = "Charges 50% of the Emerald Drive",
		attack = "chaos_drive_1",
		nouse = true,
		rarity = 2,
		cost = 100,
	},

	["chaos drive 2"] = {
		name = "Chaos Drive II",
		desc = "Charges 150% of the Emerald Drive",
		attack = "chaos_drive_2",
		nouse = true,
		rarity = 3,
		cost = 210,
	},

	["chaos drive 3"] = {
		name = "Chaos Drive III",
		desc = "Charges 300% of the Emerald Drive",
		attack = "chaos_drive_3",
		nouse = true,
		rarity = 4,
		cost = 580,
	},

	["chaos drive x"] = {
		name = "Chaos Drive X",
		desc = "Charges the Emerald Drive \nto its maximum capacity",
		attack = "chaos_drive_x",
		nouse = true,
		rarity = 5,
		cost = 1000,
	},

	-- Mirrors

	["magic mirror"] = {
		name = "Magic Mirror",
		desc = "Reflect 1 magic attack \n(1 ally)",
		attack = "makarakarn",
		nouse = true,
		rarity = 4,
		cost = 500,
	},

	["blow bouncer"] = {
		name = "Attack Mirror",
		desc = "Reflect 1 phys attack \n(1 ally)",
		attack = "tetrakarn",
		nouse = true,
		rarity = 4,
		cost = 500,
	},

	-- SP healing items

	["soulfragment"] = {
		name = "Soul Fragment",
		desc = "20 SP recovery to an ally",
		attack = "heal_sp_0",
		cost = 900,
		rarity = 3,
	},

	["snuffsoul"] = {
		name = "Snuff Soul",
		desc = "50 SP recovery to an ally",
		attack = "heal_sp_1",
		cost = 900,
		rarity = 3,
	},

	["chewing soul"] = {
		name = "Chewing Soul",
		desc = "100 SP recovery to an ally",
		attack = "heal_sp_2",
		cost = 1750,
		rarity = 4,
	},

	["soul food"] = {
		name = "Soul Food",
		desc = "Full SP recovery to an ally",
		attack = "heal_sp_3",
		cost = 4000,
		rarity = 5,
	},
	
	-- Food items (Healing items)
	["minute soubrette"] = {
		name = "Min. Soubrette",
		desc = "5 SP recovery to an ally.\nA popular apple juice brand.\nHigh in sugar.",
		attack = "heal_sp_item_5",
		cost = 20,
		rarity = 1,
	},	

	["nep bull"] = {
		name = "Nep Bull",
		desc = "5 SP recovery to an ally.\nThe can is made of\n100% recycled assets.",
		attack = "heal_sp_item_5",
		cost = 20,
		rarity = 1,
	},	

	["3up"] = {
		name = "3-UP",
		desc = "5 SP recovery to an ally.\n3 whole lives? That\nmoon's too good to be true...",
		attack = "heal_sp_item_5",
		cost = 20,
		rarity = 1,
	},

	["loh brew"] = {
		name = "Loh Brew",
		desc = "5 SP recovery to an ally.\nIt's sour, but it sure wakes you up.",
		attack = "heal_sp_item_5",
		cost = 20,
		rarity = 1,
	},

	["chaos cola"] = {
		name = "Chaos Cola",
		desc = "10 SP recovery to an ally.\nLimited 'Chao in Space 3' edition!",
		attack = "heal_sp_item_10",
		cost = 35,
		rarity = 1,
	},

	["spirite"] = {
		name = "Spirite",
		desc = "10 SP recovery to an ally.\nLemon Lime. Surprisingly\nrefreshing...",
		attack = "heal_sp_item_10",
		cost = 35,
		rarity = 1,
	},

	["peach rings"] = {
		name = "Peach Rings",
		desc = "10 SP recovery to an ally.\nIts flavour refuels\nthe spirit.",
		attack = "heal_sp_item_10",
		cost = 35,
		rarity = 1,
	},

	["soul cider"] = {
		name = "Soul Cider",
		desc = "15 SP recovery to an ally.\nIt's apple juice... mixed with alcohol?",
		attack = "heal_sp_item_15",
		cost = 50,
		rarity = 1,
	},

	["coffee thermos"] = {
		name = "Coffee Thermos",
		desc = "15 SP recovery to an ally.\nHomemade coffee.\nIt's still warm thanks to the thermos...",
		attack = "heal_sp_item_15",
		cost = 50,
		rarity = 1,
	},

	["cookie"] = {
		name = "Cookie",
		desc = "15 HP recovery to an ally.\nSomeone else might like it...\nBut you can always keep it to yourself...",
		cost = 10,
		attack = "heal_hp_item_15",
		rarity = 1,
	},

	["ham sandwich"] = {
		name = "Ham Sandwich",
		desc = "15 HP recovery to an ally.\nHam and butter, a timeless classic.",
		cost = 10,
		attack = "heal_hp_item_15",
		rarity = 1,
	},

	["chilli dog"] = {
		name = "Chilli Dog",
		desc = "15 HP recovery to an ally.\nVery spicy, just as I like it...",
		cost = 10,
		attack = "heal_hp_item_15",
		rarity = 1,
	},

	["onion rings"] = {
		name = "Onion Rings",
		desc = "15 HP recovery to an ally.\nNot recommended for a healthy diet.",
		cost = 10,
		attack = "heal_hp_item_15",
		rarity = 1,
	},

	["blue bnnui"] = {
		name = "Blue Bnnui",
		desc = "15 HP recovery to an ally.\nAn ice cream with a\npeculiar shape...",
		cost = 10,
		attack = "heal_hp_item_15",
		rarity = 1,
	},

	["chaos candy"] = {
		name = "Chaos Candy",
		desc = "15 HP recovery to an ally.\nSour candy shaped like\na Chaos Emerald.",
		cost = 10,
		attack = "heal_hp_item_15",
		rarity = 1,
	},

	["ham sandwich xl"] = {
		name = "Ham Sandwich XL",
		desc = "35 HP recovery to an ally.\nFor bigger cravings.",
		cost = 25,
		attack = "heal_hp_item_35",
		rarity = 1,
	},

	["chilli dog xl"] = {
		name = "Chilli Dog XL",
		desc = "35 HP recovery to an ally.\nThis is way too spicy...",
		cost = 25,
		attack = "heal_hp_item_35",
		rarity = 1,
	},

	["grilled fsteak"] = {
		name = "Grilled Fsteak",
		desc = "35 HP recovery to an ally.\nAppreciated by true warriors.",
		cost = 25,
		attack = "heal_hp_item_35",
		rarity = 1,
	},

	["donut"] = {
		name = "Donut",
		desc = "35 HP recovery to an ally.\nJelly-filled. Does not\nresemble a donut...",
		cost = 25,
		attack = "heal_hp_item_35",
		rarity = 1,
	},

	["aperispheres"] = {
		name = "Aperispheres",
		desc = "30 HP recovery to all allies.\nCheese with various flavours with\nsome trivia facts in each packaging.",
		cost = 50,
		attack = "heal_hp_item_30_all",
		rarity = 1,
	},

	["pepperoni pizza"] = {
		name = "Pepperoni Pizza",
		desc = "30 HP recovery to all allies.\nThe objective best kind of pizza.",
		cost = 50,
		attack = "heal_hp_item_30_all",
		rarity = 1,
	},

	["fullmoon pizza"] = {
		name = "Fullmoon Pizza",
		desc = "50 HP recovery to all allies.\nOnly purcheasable during full moons.\nHas extra pepperoni, too...",
		cost = 50,
		attack = "heal_hp_item_50_all",
		rarity = 1,
	},

	["lifesavers"] = {
		name = "Lifesavers",
		desc = "Revive 1 ally with half HP.\nYou want to scream\n'Oh yeah baby!' at their sight.",
		attack = "recarm",
		nouse = true,
		cost = 150,
		rarity = 1,
	},
	
	-- Revival items

	["1up"] = {
		name = "1Up",
		desc = "Revive 1 ally with \nhalf HP",
		attack = "recarm",
		nouse = true,
		cost = 500,
		rarity = 3,
	},

	["super1up"] = {
		name = "Super 1Up",
		desc = "Revive 1 ally with \nfull HP",
		attack = "samarecarm",
		nouse = true,
		cost = 1500,
		rarity = 5,
	},

	-- Healing items

	["soma"] = {
		name = "Soma",
		desc = "Full HP and SP recovery to party.",
		attack = "soma",
		rarity = 6,
	},

	["patra gem"] = {
		name = "Patra Gem",
		desc = "Cure status condition (1 ally)",
		attack = "patra",
		nouse = true,
		cost = 250,
		rarity = 2,
	},

	["me patra gem"] = {
		name = "Me Patra Gem",
		desc = "Cure status conditions (party)",
		attack = "me patra",
		nouse = true,
		cost = 600,
		rarity = 3,
	},


	["bronzering"] = {
		name = "Bronze Ring",
		desc = "Low HP recovery to one ally",
		cost = 30,
		attack = "bronzering",
		rarity = 1,
	},

	["superring"] = {
		name = "Super Ring",
		desc = "Slight HP recovery to one ally",
		cost = 60,
		attack = "dia",
		rarity = 1,
	},

	["supercombiring"] = {
		name = "Super Combiring",
		desc = "Slight HP recovery to all allies",
		attack = "media",
		cost = 160,
		rarity = 3,
	},

	["silverring"] = {
		name = "Silver Ring",
		desc = "Moderate HP recovery to one ally",
		attack = "diarama",
		cost = 200,
		rarity = 2,
	},

	["silvercombiring"] = {
		name = "Silver Combiring",
		desc = "Moderate HP recovery to all allies",
		attack = "mediarama",
		cost = 320,
		rarity = 4,
	},

	["hyperring"] = {
		name = "Hyper Ring",
		desc = "Full HP recovery to one ally",
		attack = "diarahan",
		cost = 450,
		rarity = 3,
	},

	["hypercombiring"] = {
		name = "Hyper Combiring",
		desc = "Full HP recovery to all allies",
		attack = "mediarahan",
		cost = 1100,
		rarity = 5,
	},


	-- attack casting items

	["assault signal"] = {
		name = "Assault Signal",
		desc = "Raises the party's Physical Attack\nby 1 stage",
		attack = "matarukaja",
		nouse = true,
		cost = 500,
		rarity = 4,
	},

	["casting signal"] = {
		name = "Casting Signal",
		desc = "Raises the party's Magic Attack\nby 1 stage",
		attack = "mamakakaja",
		nouse = true,
		cost = 500,
		rarity = 4,
	},

	["guarding signal"] = {
		name = "Guarding Signal",
		desc = "Raises the party's Defence\nby 1 stage",
		attack = "marakukaja",
		nouse = true,
		cost = 500,
		rarity = 4,
	},

	["speedup signal"] = {
		name = "Speedup Signal",
		desc = "Raises the party's Agility\nby 1 stage",
		attack = "masukukaja",
		nouse = true,
		cost = 500,
		rarity = 4,
	},

	["agi gem"] = {
		name = "Agi Gem",
		desc = "Cast Agi",
		attack = "agi",
		nouse = true,
		cost = 100,
		rarity = 2,
	},

		["bufu gem"] = {
		name = "Bufu Gem",
		desc = "Cast Bufu",
		attack = "bufu",
		nouse = true,
		cost = 100,
		rarity = 2,
	},

		["garu gem"] = {
		name = "Garu Gem",
		desc = "Cast Garu",
		attack = "garu",
		nouse = true,
		cost = 100,
		rarity = 2,
	},

		["zio gem"] = {
		name = "Zio Gem",
		desc = "Cast Zio",
		attack = "zio",
		nouse = true,
		cost = 100,
		rarity = 2,
	},

		["psi gem"] = {
		name = "Psi Gem",
		desc = "Cast Psi",
		attack = "psi",
		nouse = true,
		cost = 100,
		rarity = 2,
	},

		["frei gem"] = {
		name = "Frei Gem",
		desc = "Cast Frei",
		attack = "frei",
		nouse = true,
		cost = 100,
		rarity = 2,
	},

		["kouha gem"] = {
		name = "Kouha Gem",
		desc = "Cast Kouha",
		attack = "kouha",
		nouse = true,
		cost = 100,
		rarity = 2,
	},

		["eiha gem"] = {
		name = "Eiha Gem",
		desc = "Cast Eiha",
		attack = "eiha",
		nouse = true,
		cost = 100,
		rarity = 2,
	},

	-- attack casting items
	["agilao gem"] = {
		name = "Agilao Gem",
		desc = "Cast Agilao",
		attack = "agilao",
		nouse = true,
		cost = 210,
		rarity = 3,
	},

		["bufula gem"] = {
		name = "Bufula Gem",
		desc = "Cast Bufula",
		attack = "bufula",
		nouse = true,
		cost = 210,
		rarity = 3,
	},

		["garula gem"] = {
		name = "Garula Gem",
		desc = "Cast Garula",
		attack = "garula",
		nouse = true,
		cost = 210,
		rarity = 3,
	},

		["zionga gem"] = {
		name = "Zionga Gem",
		desc = "Cast Zionga",
		attack = "zionga",
		nouse = true,
		cost = 210,
		rarity = 3,
	},

		["psio gem"] = {
		name = "Psio Gem",
		desc = "Cast Psio",
		attack = "psio",
		nouse = true,
		cost = 210,
		rarity = 3,
	},

		["freila gem"] = {
		name = "Freila Gem",
		desc = "Cast Freila",
		attack = "freila",
		nouse = true,
		cost = 210,
		rarity = 3,
	},

		["kouga gem"] = {
		name = "Kouga Gem",
		desc = "Cast Kouga",
		attack = "kouga",
		nouse = true,
		cost = 210,
		rarity = 3,
	},

		["eiga gem"] = {
		name = "Eiga Gem",
		desc = "Cast Eiga",
		attack = "eiga",
		nouse = true,
		cost = 210,
		rarity = 3,
	},

	-- attack casting items
	["agidyne gem"] = {
		name = "Agidyne Gem",
		desc = "Cast Agidyne",
		attack = "agidyne",
		nouse = true,
		cost = 350,
		rarity = 4,
	},

		["bufudyne gem"] = {
		name = "Bufudyne Gem",
		desc = "Cast Bufudyne",
		attack = "bufudyne",
		nouse = true,
		cost = 350,
		rarity = 4,
	},

		["garudyne gem"] = {
		name = "Garudyne Gem",
		desc = "Cast Garudyne",
		attack = "garudyne",
		nouse = true,
		cost = 350,
		rarity = 4,
	},

		["ziodyne gem"] = {
		name = "Ziodyne Gem",
		desc = "Cast Ziodyne",
		attack = "ziodyne",
		nouse = true,
		cost = 350,
		rarity = 4,
	},

		["psiodyne gem"] = {
		name = "Psiodyne Gem",
		desc = "Cast Psiodyne",
		attack = "psiodyne",
		nouse = true,
		cost = 350,
		rarity = 4,
	},

		["freidyne gem"] = {
		name = "Freidyne Gem",
		desc = "Cast Freidyne",
		attack = "freidyne",
		nouse = true,
		cost = 350,
		rarity = 4,
	},

		["kougaon gem"] = {
		name = "Kougaon Gem",
		desc = "Cast Kougaon",
		attack = "kougaon",
		nouse = true,
		cost = 350,
		rarity = 4,
	},

		["eigaon gem"] = {
		name = "Eigaon Gem",
		desc = "Cast Eigaon",
		attack = "eigaon",
		nouse = true,
		cost = 350,
		rarity = 4,
	},

		["megido gem"] = {
		name = "Megido Gem",
		desc = "Cast Megido",
		attack = "megido",
		nouse = true,
		cost = 500,
		rarity = 4,
	},

		["megidola gem"] = {
		name = "Megidola Gem",
		desc = "Cast Megidola",
		attack = "megidola",
		nouse = true,
		cost = 1000,
		rarity = 5,
	},

		["megidolaon gem"] = {
		name = "Megidolaon Gem",
		desc = "Cast Megidolaon",
		attack = "megidolaon",
		nouse = true,
		cost = 2500,
		rarity = 6,
	},

	["dekaja gem"] = {
		name = "Dekaja Gem",
		desc = "Cast Dekaja",
		attack = "dekaja",
		nouse = true,
		cost = 150,
		rarity = 2,
	},

	["dekunda gem"] = {
		name = "Dekunda Gem",
		desc = "Cast Dekunda",
		attack = "dekunda",
		nouse = true,
		cost = 150,
		rarity = 2,
	},

	["curse paper"] = {
		name = "Curse Paper",
		desc = "Cast Mudoon",
		attack = "mudoon",
		nouse = true,
		cost = 500,
		rarity = 4,
	},

	["holy scroll"] = {
		name = "Holy Scroll",
		desc = "Cast Hamaon",
		attack = "hamaon",
		nouse = true,
		cost = 500,
		rarity = 4,
	},

	["hell magatama"] = {
		name = "Hell Magatama",
		desc = "Severe Fire damage\nto 1 enemy.",
		attack = "trisagion",
		nouse = true,
		cost = 1200,
		rarity = 6,
	},

	["frost magatama"] = {
		name = "Frost Magatama",
		desc = "Severe Ice damage\nto 1 enemy.",
		attack = "niflheim",
		nouse = true,
		cost = 1200,
		rarity = 6,
	},

	["storm magatama"] = {
		name = "Storm Magatama",
		desc = "Severe Elec damage\nto 1 enemy.",
		attack = "thunder reign",
		nouse = true,
		cost = 1200,
		rarity = 6,
	},

	["cyclone magatama"] = {
		name = "Cyclone Magatama",
		desc = "Severe Wind damage\nto 1 enemy.",
		attack = "panta rhei",
		nouse = true,
		cost = 1200,
		rarity = 6,
	},

	-- Materials

	["nihil frame"] = {
		name = "Nihil Frame",
		desc = "An empty, unusable weapon in its\ncurrent state. It seems to have\ninfinite potential however.",
		rarity = 6,
		material = true,
		cost = 1000,
	},

	["amethyst"] = {
		name = "Amethyst",
		desc = "Material for equipment enhancement.\nIt shinies a beautiful purple.",
		rarity = 1,
		material = true,
		cost = 35,
	},

	["onyx"] = {
		name = "Onyx",
		desc = "Material for equipment enhancement.\nDeep black coloured.",
		rarity = 2,
		material = true,
		cost = 40,
	},

	["sapphire"] = {
		name = "Sapphire",
		desc = "Material for equipment enhancement.\nIt's of a beautiful azure\ncolour.",
		rarity = 3,
		material = true,
		cost = 50,
	},

	["emerald"] = {
		name = "Emerald",
		desc = "Material for equipment enhancement.\nIt shines a bright green.",
		rarity = 4,
		material = true,
		cost = 60,
	},

	["diamond"] = {
		name = "Diamond",
		desc = "Material for equipment enhancement.\nIt's not exactly as rare\nas one might expect.",
		rarity = 5,
		material = true,
		cost = 80,
	},

	["ruby"] = {
		name = "Ruby",
		desc = "Material for equipment enhancement.\nIt's of the deepest reds.",
		rarity = 6,
		material = true,
		cost = 120,
	},

	["painite"] = {
		name = "Painite",
		desc = "Material for equipment enhancement.\nIts name lives up to the difficulty\nof obtaining it.",
		rarity = 7,
		material = true,
		cost = 200,
	},

}
)
