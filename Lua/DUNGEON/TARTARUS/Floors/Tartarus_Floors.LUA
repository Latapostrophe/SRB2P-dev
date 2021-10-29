-- This is where you can tell the game which presets are avaiable for which floor:

-- Floordata is only used by tartarus, naturally
rawset(_G, "DNG_floorData", {
	[1] = {0},		-- there's no such thing as floor 1, but define it in case somebody's feeling dumb

	-- THEBEL BLOCK
	[2] = {3},		-- all floors from f2 onwards are RANDOM	2F

	[5] = {0},		-- floor 5 has a boss preset				5F
	--[6] = {0},
	[6] = {3},		-- more random								6F
	[9] = {0},		-- boss floor again		(final)				9F

	-- FLOOR 10 = transition; should only show up in SP?

	-- ARQA BLOCK
	[blockfloor[BLOCK_ARQA]] = {4},		-- 	11F: random floor, arqa block
	[blockfloor[BLOCK_ARQA] +5] = {5},	-- 	16F: arqa boss 1
	[blockfloor[BLOCK_ARQA] +6] = {4},	--	17F: random floor, arqa block, section 2
	[blockfloor[BLOCK_ARQA] +12] = {5},	--	23F: arqa boss 2 (final)

	-- FLOOR 24 = transition

	-- YABBASHAH BLOCK
	[blockfloor[BLOCK_YABBASHAH]] = {6},		-- 25F: random floor, yabbashah block
	[blockfloor[BLOCK_YABBASHAH] +5] = {7},		-- 30F: yabbashah boss 1
	[blockfloor[BLOCK_YABBASHAH] +6] = {6},		-- 31F: random floor
	[blockfloor[BLOCK_YABBASHAH] +12] = {7},	-- 37F: yabbashah boss 2
	[blockfloor[BLOCK_YABBASHAH] +13] = {6},	-- 38F: random floor
	[blockfloor[BLOCK_YABBASHAH] +18] = {7},	-- 43F: yabbashah boss 3 (final)

	-- FLOOR 44 = transition

	-- TZIAH BLOCK
	[blockfloor[BLOCK_TZIAH]] = {8},		-- 45F: random floor, tziah block
	[blockfloor[BLOCK_TZIAH]+5] = {9},		-- 50F: Tziah boss 1
	[blockfloor[BLOCK_TZIAH]+6] = {8},		-- 51F: Tziah random floor
	[blockfloor[BLOCK_TZIAH]+10] = {9},		-- 55F: Tziah boss 2
	[blockfloor[BLOCK_TZIAH]+11] = {8},		-- 56F: Tziah random floor
	[blockfloor[BLOCK_TZIAH]+15] = {9},		-- 60F: Tziah boss 3
	[blockfloor[BLOCK_TZIAH]+16] = {8},		-- 61F: Tziah random floor
	[blockfloor[BLOCK_TZIAH]+18] = {9},		-- 63F: Tziah boss 4	(final)

	-- FLOOR 64 = transition

	-- HARABAH BLOCK
	[blockfloor[BLOCK_HARABAH]] = {10},		-- 65F: random floor, harabah block
	[blockfloor[BLOCK_HARABAH]+5] = {11},	-- 70F: Harabah boss 1
	[blockfloor[BLOCK_HARABAH]+6] = {10},	-- 71F: Harabah random floor
	[blockfloor[BLOCK_HARABAH]+10] = {11},	-- 75F: Harabah boss 2
	[blockfloor[BLOCK_HARABAH]+11] = {10},	-- 76F: Harabah random floor
	[blockfloor[BLOCK_HARABAH]+14] = {11},	-- 79F: Harabah boss 3
	[blockfloor[BLOCK_HARABAH]+15] = {10},	-- 80F: Harabah random floor
	[blockfloor[BLOCK_HARABAH]+18] = {11},	-- 83F: Harabah boss 4
	[blockfloor[BLOCK_HARABAH]+19] = {10},	-- 84F: Harabah random floor
	[blockfloor[BLOCK_HARABAH]+23] = {11},	-- 88F: Harabah boss 5 	(final)

	-- ADAMAH BLOCK
	[blockfloor[BLOCK_ADAMAH]] = {12},		-- 90F: Adamah random floor
	[blockfloor[BLOCK_ADAMAH]+4] = {13},	-- 94F: Adamah, boss 1
	[blockfloor[BLOCK_ADAMAH]+5] = {12},	-- 95F: Adamah random floor
	[blockfloor[BLOCK_ADAMAH]+8] = {13},	-- 98F: Adamah, boss 2
	[blockfloor[BLOCK_ADAMAH]+9] = {12},	-- 99F: Adamah random floor
	[blockfloor[BLOCK_ADAMAH]+13] = {13},	-- 103F: Adamah, boss 3
	[blockfloor[BLOCK_ADAMAH]+14] = {12},	-- 104F: Adamah random floor
	[blockfloor[BLOCK_ADAMAH]+19] = {13},	-- 109F: Adamah, boss 4
	[blockfloor[BLOCK_ADAMAH]+20] = {12},	-- 110F: Adamah random floor
	[blockfloor[BLOCK_ADAMAH]+21] = {13},	-- 111F: Adamah, boss 5	(final)
	[blockfloor[BLOCK_ADAMAH]+22] = {99},	-- 112F: Top

	-- MONAD DEPTHS
	[blockfloor[BLOCK_MONAD]] = {14},		-- B1F (65536) Monad Depths, random floor
	[blockfloor[BLOCK_MONAD]+5] = {15},		-- B6F (65536) Monad Depths, boss 1	

	[blockfloor[BLOCK_MONAD]+6] = {14},		-- B7F (65536) Monad Depths, random floor
	[blockfloor[BLOCK_MONAD]+9] = {15},		-- B10F (65536) Monad Depths, boss 2
	
	[blockfloor[BLOCK_MONAD]+10] = {14},		-- B11F (65536) Monad Depths, random floor
	[blockfloor[BLOCK_MONAD]+14] = {15},		-- B15F (65536) Monad Depths, boss 3
												-- B16F, Monad Depths, boss 4 (final)
	
})