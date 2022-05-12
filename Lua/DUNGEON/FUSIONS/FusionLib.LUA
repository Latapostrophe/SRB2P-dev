/*
	SUBPERSONA FUSIONS
	
	This is where we handle all the fusion related stuff.
	It's a mess so sit tight....
*/

-- This is a double entry table that contains the result between fusions.
-- Arcanas go in this order....

-- Fool, Magician, Priestess, Empress, Emperor, Hierophant, Lovers, Chariot, Justice, Hermit, Fortune, Strength, Hanged, Death, Temperance, Devil, Tower, Star, Moon, Sun, Judgement

-- nil means we mirror the table. Can't be assed to type it all out lol.

local fusion_arcanaResults = {
	
	[ARCANA_FOOL] = 		{ARCANA_FOOL, ARCANA_DEATH, ARCANA_MOON, ARCANA_HANGED, ARCANA_TEMPERANCE, ARCANA_HERMIT, ARCANA_CHARIOT, ARCANA_MOON, ARCANA_STAR, ARCANA_PRIESTESS, ARCANA_LOVERS, ARCANA_DEATH, ARCANA_TOWER, ARCANA_STRENGTH, ARCANA_HIEROPHANT, ARCANA_TEMPERANCE, ARCANA_EMPRESS, ARCANA_MAGICIAN, ARCANA_JUSTICE, ARCANA_JUSTICE, ARCANA_SUN},
	[ARCANA_MAGICIAN] = 	{nil, ARCANA_MAGICIAN, ARCANA_TEMPERANCE, ARCANA_JUSTICE, ARCANA_HANGED, ARCANA_DEATH, ARCANA_DEVIL, ARCANA_PRIESTESS, ARCANA_EMPEROR, ARCANA_LOVERS, ARCANA_JUSTICE, ARCANA_FOOL, ARCANA_EMPRESS, ARCANA_HERMIT, ARCANA_CHARIOT, ARCANA_HIEROPHANT, ARCANA_TEMPERANCE, ARCANA_PRIESTESS, ARCANA_LOVERS, ARCANA_HIEROPHANT, ARCANA_STRENGTH},
	[ARCANA_PRIESTESS] =	{nil, nil, ARCANA_PRIESTESS, ARCANA_EMPEROR, ARCANA_EMPRESS, ARCANA_MAGICIAN, ARCANA_FORTUNE, ARCANA_HIEROPHANT, ARCANA_DEATH, ARCANA_TEMPERANCE, ARCANA_MAGICIAN, ARCANA_DEVIL, ARCANA_DEATH, ARCANA_MAGICIAN, ARCANA_DEVIL, ARCANA_MOON, ARCANA_HANGED, ARCANA_HERMIT, ARCANA_HIEROPHANT, ARCANA_CHARIOT, ARCANA_JUSTICE},
	[ARCANA_EMPRESS] = 		{nil, nil, nil, ARCANA_EMPRESS, ARCANA_JUSTICE, ARCANA_FOOL, ARCANA_JUDGEMENT, ARCANA_STAR, ARCANA_LOVERS, ARCANA_STRENGTH, ARCANA_HERMIT, ARCANA_CHARIOT, ARCANA_PRIESTESS, ARCANA_FOOL, ARCANA_PRIESTESS, ARCANA_SUN, ARCANA_EMPEROR, ARCANA_LOVERS, ARCANA_FORTUNE, ARCANA_TOWER, ARCANA_EMPEROR},
	[ARCANA_EMPEROR] = 		{nil, nil, nil, nil, ARCANA_EMPEROR, ARCANA_FORTUNE, ARCANA_FOOL, ARCANA_STRENGTH, ARCANA_CHARIOT, ARCANA_HIEROPHANT, ARCANA_SUN, ARCANA_TOWER, ARCANA_DEVIL, ARCANA_HERMIT, ARCANA_DEVIL, ARCANA_JUSTICE, ARCANA_STAR, ARCANA_LOVERS, ARCANA_TOWER, ARCANA_JUDGEMENT, ARCANA_PRIESTESS},
	[ARCANA_HIEROPHANT] = 	{nil, nil, nil, nil, nil, ARCANA_HIEROPHANT, ARCANA_STRENGTH, ARCANA_STAR, ARCANA_HANGED, ARCANA_FORTUNE, ARCANA_JUSTICE, ARCANA_FOOL, ARCANA_SUN, ARCANA_CHARIOT, ARCANA_DEATH, ARCANA_HANGED, ARCANA_JUDGEMENT, ARCANA_TOWER, ARCANA_PRIESTESS, ARCANA_LOVERS, ARCANA_EMPRESS},
	[ARCANA_LOVERS] = 		{nil, nil, nil, nil, nil, nil, ARCANA_LOVERS, ARCANA_TEMPERANCE, ARCANA_JUDGEMENT, ARCANA_CHARIOT, ARCANA_STRENGTH, ARCANA_DEATH, ARCANA_SUN, ARCANA_TEMPERANCE, ARCANA_STRENGTH, ARCANA_MOON, ARCANA_EMPRESS, ARCANA_CHARIOT, ARCANA_MAGICIAN, ARCANA_EMPRESS, ARCANA_HANGED},
	[ARCANA_CHARIOT] =		{nil, nil, nil, nil, nil, nil, nil, ARCANA_CHARIOT, ARCANA_MOON, ARCANA_DEVIL, ARCANA_PRIESTESS, ARCANA_HERMIT, ARCANA_FOOL, ARCANA_DEVIL, ARCANA_STRENGTH, ARCANA_TEMPERANCE, ARCANA_FORTUNE, ARCANA_MOON, ARCANA_LOVERS, ARCANA_PRIESTESS, ARCANA_HIEROPHANT},
	[ARCANA_JUSTICE] =		{nil, nil, nil, nil, nil, nil, nil, nil, ARCANA_JUSTICE, ARCANA_MAGICIAN, ARCANA_EMPEROR, ARCANA_HIEROPHANT, ARCANA_LOVERS, ARCANA_FOOL, ARCANA_EMPEROR, ARCANA_FOOL, ARCANA_SUN, ARCANA_EMPRESS, ARCANA_DEVIL, ARCANA_HANGED, ARCANA_TOWER},
	[ARCANA_HERMIT] =		{nil, nil, nil, nil, nil, nil, nil, nil, nil, ARCANA_HERMIT, ARCANA_STAR, ARCANA_HIEROPHANT, ARCANA_STAR, ARCANA_STRENGTH, ARCANA_STRENGTH, ARCANA_PRIESTESS, ARCANA_JUDGEMENT, ARCANA_STRENGTH, ARCANA_PRIESTESS, ARCANA_DEVIL, ARCANA_EMPEROR},
	[ARCANA_FORTUNE] = 		{nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, ARCANA_FORTUNE, ARCANA_TEMPERANCE, ARCANA_EMPEROR, ARCANA_STAR, ARCANA_EMPRESS, ARCANA_HIEROPHANT, ARCANA_HANGED, ARCANA_DEVIL, ARCANA_SUN, ARCANA_STAR, ARCANA_TOWER},
	[ARCANA_STRENGTH] = 	{nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, ARCANA_STRENGTH, ARCANA_TEMPERANCE, ARCANA_HIEROPHANT, ARCANA_CHARIOT, ARCANA_DEATH, ARCANA_CHARIOT, ARCANA_MOON, ARCANA_MAGICIAN, ARCANA_MOON, ARCANA_FORTUNE},
	[ARCANA_HANGED] =		{nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, ARCANA_HANGED, ARCANA_MOON, ARCANA_DEATH, ARCANA_FORTUNE, ARCANA_HERMIT, ARCANA_JUSTICE, ARCANA_STRENGTH, ARCANA_HIEROPHANT, ARCANA_STAR},
	[ARCANA_DEATH] =		{nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, ARCANA_DEATH, ARCANA_HANGED, ARCANA_CHARIOT, ARCANA_SUN, ARCANA_DEVIL, ARCANA_HIEROPHANT, ARCANA_PRIESTESS, ARCANA_MAGICIAN},
	[ARCANA_TEMPERANCE] =	{nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, ARCANA_TEMPERANCE, ARCANA_FOOL, ARCANA_FORTUNE, ARCANA_SUN, ARCANA_FORTUNE, ARCANA_MAGICIAN, ARCANA_HERMIT},
	[ARCANA_DEVIL] =		{nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, ARCANA_DEVIL, ARCANA_MAGICIAN, ARCANA_STRENGTH, ARCANA_CHARIOT, ARCANA_HERMIT, ARCANA_LOVERS},
	[ARCANA_TOWER] =		{nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, ARCANA_TOWER, ARCANA_DEATH, ARCANA_HERMIT, ARCANA_EMPEROR, ARCANA_MOON},
	[ARCANA_STAR] =			{nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, ARCANA_STAR, ARCANA_TEMPERANCE, ARCANA_JUDGEMENT, ARCANA_FORTUNE},
	[ARCANA_MOON] =			{nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, ARCANA_MOON, ARCANA_EMPRESS, ARCANA_FOOL},
	[ARCANA_SUN] =			{nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, ARCANA_SUN, ARCANA_DEATH},
	[ARCANA_JUDGEMENT] =	{nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, nil, ARCANA_JUDGEMENT}
	
}

local arcana_names = {
	"Fool",
	"Magician",
	"Priestess",
	"Empress",
	"Emperor",
	"Hierophant",
	"Lovers",
	"Chariot",
	"Justice",
	"Hermit",
	"Fortune",
	"Strength",
	"Hanged Man",
	"Death",
	"Temperance",
	"Devil",
	"Tower",
	"Star",
	"Moon",
	"Sun",
	"Judgement"
}

-- Since I'm too lazy to type everything, we have to make SURE we use the "smallest" Arcana as first entry, then the second, this basically does the table mirroring automatically!
local function getFusionResult(a1, a2)
	return fusion_arcanaResults[min(a1, a2)][max(a1, a2)]
end

rawset(_G, "FUSION_inheritance", {

					--   Sl St Pi Fi Ic Wi El Ps Nk Li Da Am He Sp Ps
	[ATK_SLASH] = 		{1, 1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1},	-- Doesn't inherit magic or healing
	[ATK_STRIKE] = 		{1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1},	-- Doesn't inherit magic or healing 
	[ATK_PIERCE] = 		{1, 1, 1, 0, 0, 0, 0, 0, 0, 0, 0, 1, 0, 1, 1},  -- Doesn't inherit magic or healing
	[ATK_FIRE] = 		{1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},	-- Doesn't inherit ice
	[ATK_ICE] = 		{1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},	-- Doesn't inherit fire
	[ATK_WIND] = 		{1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1},	-- Doesn't inherit elec
	[ATK_ELEC] = 		{1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1, 1, 1},	-- Doesn't inherit wind
	[ATK_NUCLEAR] =		{1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1, 1},	-- Doesn't inherit psy
	[ATK_PSY] =			{1, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1, 1, 1},	-- Doesn't inherit nuke
	[ATK_BLESS] =		{0, 0, 0, 1, 1, 1, 1, 1, 1, 1, 0, 1, 1, 1, 1},	-- Doesn't inherit phys or dark
	[ATK_CURSE] =		{0, 0, 0, 1, 1, 1, 1, 1, 1, 0, 1, 1, 0, 1, 1},	-- Doesn't inherit phys, light or healing
	[ATK_ALMIGHTY] =	{1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},	-- Inherits anything
	
})

/*
	Here we're going to generate the actual fusion tables.
	...So, how do we do it? Simple!
	
	1: Pick the base 1st Persona
	2: Iterate through every other Persona, ignoring the one we picked.
	
		2.1: Check if the reverse pair already exists, if it does, skip.
		2.2: Check the resulting Arcana of these 2 Personas.
		2.3: Check Lvl = (Persona 1's BLv + Persona 2's BLv)/2 (where BLv is the Persona's BASE level)
		2.4: The resulting Persona is the Persona within that Arcana with the CLOSEST level to the average of these 2. 
			Worth noting that if the fusion results in either component of the fusion, we take the next thing BELOW and so on.	
*/

rawset(_G, "FUSION_table", {})

-- and now, build our fusion table...
rawset(_G, "FUSION_buildFusionTables", function()
	
	FUSION_table = {}
	
	-- Double iteration in subpersonaList
	for k, p in pairs(subpersonaList) do
		
		local s1 = p
		if not s1.lv continue end
		if not s1.arcana continue end
		
		FUSION_table[k] = $ or {}
		
		-- And now do it again for the fusion recipe!
		for kk, pp in pairs(subpersonaList) do
			
			local s2 = pp
			if p == pp continue end	-- don't try fusing myself lol.
			if not s2.lv continue end	-- nil level personas can exist... don't allow fusing them.
			if not s2.arcana continue end
			
			local avglevel = (s1.lv + s2.lv)/2
			local rarcana = getFusionResult(s1.arcana, s2.arcana)
			local closestdiff = 9999
			local result = nil
			local rkey = nil
			
			-- now find the persona from that arcana closest to the avglevel.
			for kkk, ppp in pairs(subpersonaList) do	-- this is getting stupidd
				
				local fs = ppp
				if fs.arcana ~= rarcana continue end	-- this isn't the arcana we want.
				if fs == s1 or fs == s2 continue end 	-- we can't have the materials be a result... 
				
				local lvdiff = abs(fs.lv - avglevel)
				if lvdiff < closestdiff
					result = fs
					rkey = kkk
					closestdiff = lvdiff
				end
			end
			
			-- Add the result! Or nil if there isn't any.
			FUSION_table[k][kk] = rkey
			
			if not result
				result = {
					name = "INVALID",
					lv = 0,
					arcana = 2,
				}
			end
			
			if result and s1 and s2
				/*print(s1.name)
				print(s1.lv)
				print(arcana_names[s1.arcana])
				
				print(s2.name)
				print(s2.lv)
				print(arcana_names[s2.arcana])

				print(result.name)
				print(result.lv)
				print(arcana_names[result.arcana])*/
				
				print(s1.name.." (Lv"..s1.lv.." / "..arcana_names[s1.arcana]..") + "..s2.name.." (Lv"..s2.lv.." / "..arcana_names[s2.arcana]..") = "..result.name.." (Lv"..result.lv.." / "..arcana_names[result.arcana]..")")
			end	
		end
	end
end)

rawset(_G, "getFusionResult", function(sub1, sub2)
	
	if FUSION_table[sub1]
		return FUSION_table[sub1][sub2]
	elseif FUSION_table[sub2]
		return FUSION_table[sub2][sub1]
	else
		return nil
	end
end)

FUSION_buildFusionTables()

