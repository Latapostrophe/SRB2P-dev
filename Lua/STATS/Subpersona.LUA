-- subpersona definitions

/*
	subpersona_def, to not mistake with a held subpersona

	name, -full name of the sub-persona
	lv,	-the level the sub persona is at. This is important for fusions.
	arcana,	-useful in fusion
	st, ma, en, ag, lu,	-stat bonuses granted by the sub persona. Can be negative
	skills,	-list of skills the sub persona has. passives etc can be here too.

*/

-- generate a neutral subpersona that can then be accessed
-- subp: reference in subpersonaList
-- lv: set which level to generate the subpersona at. if nil, generates at the default subpersona level.
rawset(_G, "P_generateSubPersona", function(subp, lv)

	local subd = subpersonaList[subp]
	if not subd
		print("\x82".."WARNING:".."\x80".." Sub Persona could not be generated, check the validity of the field.")
		return
	end

	local uselv = lv or subd.lv

	local skillslist = {}
	if subd.skills
		for i = 1, #subd.skills

			local skd = subd.skills[i]
			if type(skd) == "table"

				if uselv >= skd[2]
					skillslist[#skillslist+1] = skd[1]
				end
			else
				skillslist[#skillslist+1] = skd
			end
		end
	end

	local subp_t = {
		ref = subd,	-- reference from list
		int = subp,	-- internal name
		name = subd.name,
		skills = skillslist,	-- during fusion, skill can be inherited
		st = subd.st or 0,
		ma = subd.ma or 0,
		en = subd.en or 0,
		ag = subd.ag or 0,
		lu = subd.lu or 0,
		level = uselv,
		exp = 0,
		equipped = nil,
		arcana = subd.arcana,
	}

	return subp_t
end)

-- register a SubPersona to the compendium...
-- overwrites existing entry if it exists.
-- does nothing outside of story mode or if subp is nil.

rawset(_G, "P_registerSubPersona", function(subp)
	if not srb2p.storymode return end
	if not subp return end

	-- check if the subpersona already has an entry in the compendium:
	local t = srb2p.storydata.compendium
	local index

	for i = 1, #t do
		-- if so and the new entry has a higher level or more skills, replace it.
		if t[i] and t[i].name == subp.name
		and (t[i].level < subp.level or (t[i].level == subp.level and t[i].exp < subp.exp) or #t[i].skills < #subp.skills)
			index = i
			break
		end
	end

	-- replace index with #t+1 if we don't have a value.
	index = $ or #t+1

	t[index] = subp
end)

-- Generate and THEN register a subpersona.
rawset(_G, "P_generateAndRegisterSubPersona", function(subn, lv)
	local subp = P_generateSubPersona(subn, lv)
	P_registerSubPersona(subp)
	return subp
end)


-- Get a subpersona from the compendium that's the same as subp
rawset(_G, "P_getSubpersonaFromCompendium", function(subp)
	if not srb2p.storymode return end
	
	local t = srb2p.storydata.compendium
	for i = 1, #t do
		local csubp = t[i]
		
		if subp.name == csubp.name
			return csubp
		end
	end	
end)

-- Checks if a SubPersona can be added in the compendium
rawset(_G, "P_canReplaceCompendium", function(subp)
	if not srb2p.storymode return end
	
	local csubp = P_getSubpersonaFromCompendium(subp)
		
	if csubp
		local r = false
		local diffskills
			
		for j = 1, #subp.skills
			if csubp.skills[j] ~= subp.skills[j]
				diffskills = true
				break
			end	
		end
		
		if subp.level > csubp.level
		or (subp.level == csubp.level and subp.exp > csubp.exp)
		or #subp.skills > #csubp.skills
		or diffskills
			return true
		else
			return false	
		end
	end
	
	return true 	-- couldn't find it? then sure, we can register
end)

local skilltiercost = {
	100,
	200,
	500,
	1000,
	2000,
	5000,
	10000,
}

-- Evaluates the cost of a subpersona...
rawset(_G, "P_subpersonaCost", function(subp)
	
	local price = 0
	price = $ + (10 + subp.level)^2 *10
	
	local stats = {"st", "ma", "en", "ag", "lu"}
	for i = 1, #stats do
		local st = subp[stats[i]]
		if st > 0
			price = $+ 16*st
		end	
	end
	
	for i = 1, #subp.skills do
		local atkd = attackDefs[subp.skills[i]]
		local r = atkd.rank or 1
		price = $ + skilltiercost[r]
	end
	
	return price
end)

freeslot("SPR_SBPR", "SPR_SBP2")

rawset(_G, "subpersonaList", {

	-- dummy subpersona for none, basically removes stuff!
	["none"] = {
		name = "Unequip",
		arcana = -1, -- We cannot have this be nil, otherwise Sonic will get a stat boost via LINK_AFFINITY.
		st = 0,
		ma = 0,
		en = 0,
		ag = 0,
		lu = 0,
		skills = {},
	},

	-- AMADAH SUBPERSONAS
	["trumpeter"] = {
		name = "Trumpeter",
		sprite = SPR_SBP2,
		frame = L,
		lv = 69,
		arcana = ARCANA_JUDGEMENT,
		weapontype = ATK_NUCLEAR,
		st = -5,
		ma = 2,
		en = 6,
		ag = 2,
		lu = -4,
		skills = {"megidola", "marakukaja", "freidyne", "heat riser"},
	},

	["lilith"] = {
		name = "Lilith",
		sprite = SPR_SBP2,
		frame = O,
		lv = 69,
		arcana = ARCANA_DEVIL,
		weapontype = ATK_ELEC,
		st = -2,
		ma = 5,
		en = -5,
		ag = 3,
		lu = 0,
		skills = {"ziodyne", "elec break", "sexy dance", "makarakarn"}
	},

	["archangel"] = {
		name = "Archangel",
		sprite = SPR_SBP2,
		frame = R,
		lv = 69,
		arcana = ARCANA_JUSTICE,
		weapontype = ATK_BLESS,
		st = 5,
		ma = -3,
		en = -4,
		ag = 0,
		lu = 5,
		skills = {"mahamaon", "fatal end", "survive death"}
	},

	["raphael"] = {
		name = "Raphael",
		sprite = SPR_SBP2,
		frame = S,
		lv = 69,
		arcana = ARCANA_LOVERS,
		weapontype = ATK_SLASH,
		st = 6,
		ma = -3,
		en = -3,
		ag = 0,
		lu = 3,
		skills = {"deathbound", "matarukaja", "high counter"}
	},

	["sati"] = {
		name = "Sati",
		sprite = SPR_SBP2,
		frame = J,
		lv = 69,
		arcana = ARCANA_MAGICIAN,
		weapontype = ATK_FIRE,
		st = -3,
		ma = 6,
		en = -3,
		ag = 2,
		lu = 0,
		skills = {"agiverse", "maragidyne", "me patra", "resist fire"}
	},

	["loki"] = {
		name = "Loki",
		sprite = SPR_SBP2,
		frame = P,
		lv = 69,
		arcana = ARCANA_JUSTICE,
		weapontype = ATK_ICE,
		st = 0,
		ma = 6,
		en = -4,
		ag = 3,
		lu = -5,
		skills = {"bufudyne", "mabufudyne", "ice amp", "null burn"}
	},

	["daisoujou"] = {
		name = "Daisoujou",
		sprite = SPR_SBP2,
		frame = U,
		lv = 69,
		arcana = ARCANA_HIEROPHANT,
		weapontype = ATK_BLESS,
		st = -5,
		ma = 6,
		en = -5,
		ag = 0,
		lu = 4,
		skills = {"samsara", "marakunda", "evade curse"}
	},

	["alice"] = {
		name = "Alice",
		sprite = SPR_SBP2,
		frame = Q,
		lv = 69,
		arcana = ARCANA_DEATH,
		weapontype = ATK_CURSE,
		st = -5,
		ma = 6,
		en = -5,
		ag = 0,
		lu = 4,
		skills = {"die for me", "marakunda", "evade bless"}
	},

	-- HARABAH SUBPERSONAS
	["mara"] = {
		name = "Mara",
		sprite = SPR_SBPR,
		frame = B,
		lv = 54,
		arcana = ARCANA_TOWER,
		weapontype = ATK_FIRE,
		st = 3,
		ma = 4,
		en = -4,
		ag = 0,
		lu = -4,
		skills = {"agidyne", "matarukaja", "fire amp", "torrent shot"}
	},

	["anubis"] = {
		name = "Anubis",
		sprite = SPR_SBP2,
		frame = D,
		lv = 57,
		arcana = ARCANA_JUDGEMENT,
		weapontype = ATK_BLESS,
		st = -4,
		ma = 5,
		en = -3,
		ag = -3,
		lu = 4,
		skills = {"hamaon", "expel boost", "makajamon", "survive death"}
	},

	["kinki"] = {
		name = "Kin Ki",
		sprite = SPR_SBPR,
		frame = X,
		lv = 53,
		arcana = ARCANA_CHARIOT,
		weapontype = ATK_WIND,
		st = 5,
		ma = -5,
		en = 3,
		ag = 2,
		lu = -2,
		skills = {"counterstrike", "gigantic fist", "heat wave", "marakunda"}
	},

	["byakko"] = {
		name = "Byakko",
		sprite = SPR_SBPR,
		frame = Y,
		lv = 56,
		arcana = ARCANA_TEMPERANCE,
		weapontype = ATK_NUCLEAR,
		st = 1,
		ma = 4,
		en = -4,
		ag = 1,
		lu = 0,
		skills = {"bufudyne", "evade fire", "makarakarn", "mafreila"}
	},

	["hell biker"] = {
		name = "Hell Biker",
		sprite = SPR_SBPR,
		frame = Z,
		lv = 54,
		arcana = ARCANA_DEVIL,
		weapontype = ATK_CURSE,
		st = -1,
		ma = 3,
		en = -5,
		ag = 3,
		lu = 3,
		skills = {"eigaon", "abysmal surge", "mudoon", "mamakakaja"}
	},

	["matador"] = {
		name = "Matador",
		sprite = SPR_SBP2,
		frame = A,
		lv = 58,
		arcana = ARCANA_DEATH,
		weapontype = ATK_PSY,
		st = 0,
		ma = 4,
		en = -4,
		ag = 2,
		lu = 0,
		skills = {"psiodyne", "ghastly wail", "danse macabre", "mazionga"}
	},

	["siegfried"] = {
		name = "Siegfried",
		sprite = SPR_SBP2,
		frame = B,
		lv = 58,
		arcana = ARCANA_STRENGTH,
		weapontype = ATK_FIRE,
		st = 5,
		ma = -3,
		en = 2,
		ag = 0,
		lu = -5,
		skills = {"blade of fury", "fatal end", "matarukaja", "matarunda"}
	},

	["quezacoatl"] = {
		name = "Quezacoatl",
		sprite = SPR_SBP2,
		frame = C,
		lv = 56,
		arcana = ARCANA_SUN,
		weapontype = ATK_ELEC,
		st = 0,
		ma = 0,
		en = -5,
		ag = 3,
		lu = 3,
		skills = {"sexy dance", "ziodyne", "serene grace", "mediarama"}
	},

	["belphegor"] = {
		name = "Belphegor",
		sprite = SPR_SBP2,
		frame = E,
		lv = 56,
		arcana = ARCANA_DEVIL,
		weapontype = ATK_ALMIGHTY,
		st = -2,
		ma = 1,
		en = 4,
		ag = -2,
		lu = 3,
		skills = {"virus breath", "marakukaja"}
	},

	["seiryuu"] = {
		name = "Seiryuu",
		sprite = SPR_SBPR,
		frame = W,
		lv = 52,
		arcana = ARCANA_TEMPERANCE,
		weapontype = ATK_WIND,
		st = 0,
		ma = 2,
		en = -2,
		ag = 6,
		lu = -2,
		skills = {"magarula", "wind amp", "matarunda", "dekaja"}
	},

	-- TZIAH SUBPERSONAS
	["black frost"] = {
		name = "Black Frost",
		sprite = SPR_SBPR,
		frame = N,
		lv = 38,
		arcana = ARCANA_MAGICIAN,
		weapontype = ATK_ICE,
		st = -4,
		ma = 3,
		en = -2,
		lu = 3,
		ag = 1,
		skills = {"agilao", "bufula", "resist fire", "ice boost"},
	},

	["chu chulainn"] = {
		name = "Chu Chulainn",
		sprite = SPR_SBPR,
		frame = O,
		lv = 40,
		arcana = ARCANA_TOWER,
		weapontype = ATK_ELEC,
		st = 4,
		ma = -4,
		en = 1,
		lu = 0,
		ag = 2,
		skills = {"zioverse", "survive death", "assault dive"},
	},

	["girimehkala"] = {
		name = "Girimehkala",
		sprite = SPR_SBPR,
		frame = P,
		lv = 37,
		arcana = ARCANA_MOON,
		weapontype = ATK_ALMIGHTY,
		st = 0,
		ma = -2,
		en = 5,
		lu = 2,
		ag = -3,
		skills = {"endure", "marakukaja", "foolish whisper", "marakunda"},
	},

	["kaiwan"] = {
		name = "Kaiwan",
		sprite = SPR_SBPR,
		frame = Q,
		lv = 39,
		arcana = ARCANA_STAR,
		weapontype = ATK_PSY,
		st = -3,
		ma = 3,
		en = 0,
		lu = 2,
		ag = 0,
		skills = {"mapsio", "provoke", "repel strike", "megido"},
	},

	["oumitsunu"] = {
		name = "Oumitsunu",
		sprite = SPR_SBPR,
		frame = R,
		lv = 41,
		arcana = ARCANA_CHARIOT,
		weapontype = ATK_NUCLEAR,
		st = 4,
		ma = -5,
		en = 2,
		lu = 0,
		ag = -1,
		skills = {"kill rush", "tarukaja", {"freila", 42}, {"gale slash", 43}},
	},

	["pale rider"] = {
		name = "Pale Rider",
		sprite = SPR_SBPR,
		frame = S,
		lv = 41,
		arcana = ARCANA_DEATH,
		weapontype = ATK_CURSE,
		st = -5,
		ma = 2,
		en = -2,
		lu = 5,
		ag = -2,
		skills = {"mudo", "evil touch", "ghastly wail", "resist bless"},
	},

	["succubus"] = {
		name = "Succubus",
		sprite = SPR_SBPR,
		frame = T,
		lv = 43,
		arcana = ARCANA_DEVIL,
		weapontype = ATK_FIRE,
		st = 0,
		ma = 3,
		en = -4,
		lu = 4,
		ag = -3,
		skills = {"life drain", "marin karin", "maragion", "fire boost"},
	},

	["titania"] = {
		name = "Titania",
		sprite = SPR_SBPR,
		frame = U,
		lv = 42,
		arcana = ARCANA_EMPRESS,
		weapontype = ATK_ICE,
		st = -5,
		ma = 5,
		en = -3,
		lu = 0,
		ag = 3,
		skills = {"serene grace", "mabufula", "recarm", "diarama"},
	},

	["virtue"] = {
		name = "Virtue",
		sprite = SPR_SBPR,
		frame = V,
		lv = 45,
		arcana = ARCANA_JUSTICE,
		weapontype = ATK_PSY,
		st = 1,
		ma = 1,
		en = 1,
		lu = 1,
		ag = 1,
		skills = {"hama", "psy boost", "psio", "recarm"},
	},

	-- YABBASHAH SUBPERSONAS
	["hua po"] = {
		name = "Hua Po",
		sprite = SPR_SBP2,
		frame = F,
		lv = 24,
		arcana = ARCANA_MAGICIAN,
		weapontype = ATK_FIRE,
		st = -2,
		ma = 3,
		lu = 0,
		ag = 2,
		en = -1,
		skills = {"agilao", "patra", "resist freeze"},
	},

	["orobas"] = {
		name = "Orobas",
		sprite = SPR_SBP2,
		frame = K,
		lv = 24,
		arcana = ARCANA_HIEROPHANT,
		weapontype = ATK_WIND,
		st = 2,
		ma = 1,
		lu = -4,
		ag = 3,
		en = -3,
		skills = {"assault dive", "garula", "wind break"},
	},

	["leanan sidhe"] = {
		name = "Leanan Sidhe",
		sprite = SPR_SBP2,
		frame = T,
		lv = 24,
		arcana = ARCANA_EMPRESS,
		weapontype = ATK_PSY,
		st = -4,
		ma = 3,
		lu = 5,
		ag = 0,
		en = -3,
		skills = {"diarama", "marin karin", "psio", "media"},
	},

	["king frost"] = {
		name = "King Frost",
		sprite = SPR_SBP2,
		frame = H,
		lv = 24,
		arcana = ARCANA_EMPEROR,
		weapontype = ATK_ICE,
		st = -1,
		ma = 2,
		lu = 3,
		ag = -4,
		en = 2,
		skills = {"bufula", "rakukaja", "resist burn"},
	},

	["queen mab"] = {
		name = "Queen Mab",
		sprite = SPR_SBP2,
		frame = M,
		lv = 24,
		arcana = ARCANA_LOVERS,
		weapontype = ATK_ELEC,
		st = -2,
		ma = 0,
		lu = 3,
		ag = 4,
		en = -5,
		skills = {"mazio", "resist poison", "media"},
	},

	["ares"] = {
		name = "Ares",
		sprite = SPR_SBP2,
		frame = G,
		lv = 24,
		arcana = ARCANA_CHARIOT,
		weapontype = ATK_SLASH,
		st = 4,
		ma = -4,
		lu = 0,
		ag = -3,
		en = 4,
		skills = {"giant slice", "rakunda", "counter"},
	},

	["mithra"] = {
		name = "Mithra",
		sprite = SPR_SBP2,
		frame = N,
		lv = 24,
		arcana = ARCANA_TEMPERANCE,
		weapontype = ATK_BLESS,
		st = -1,
		ma = 2,
		lu = 3,
		ag = -2,
		en = 1,
		skills = {"mahama", "terror voice", "kouga"},
	},

	["lilim"] = {
		name = "Lilim",
		sprite = SPR_SBP2,
		frame = I,
		lv = 24,
		arcana = ARCANA_DEVIL,
		weapontype = ATK_CURSE,
		st = -3,
		ma = 3,
		lu = -2,
		ag = 0,
		en = 0,
		skills = {"mamudo", "zio", "resist brainwash"},
	},

	-- ARQA SUBPERSONAS
	["fortuna"] = {
		name = "Fortuna",
		sprite = SPR_SBPR,
		frame = G,
		lv = 13,
		arcana = ARCANA_FORTUNE,
		weapontype = ATK_ICE,
		st = -3,
		ma = 2,
		lu = 4,
		ag = 0,
		en = 0,
		skills = {"bufula", "dia", "makakaja"},
	},


	["lamia"] = {
		name = "Lamia",
		sprite = SPR_SBPR,
		frame = H,
		lv = 12,
		arcana = ARCANA_DEVIL,
		weapontype = ATK_CURSE,
		st = 0,
		ma = 4,
		lu = -1,
		ag = 2,
		en = -2,
		skills = {"maeiha", "mudo", "rakunda"},
	},

	["naga"] = {
		name = "Naga",
		sprite = SPR_SBPR,
		frame = I,
		lv = 14,
		arcana = ARCANA_STRENGTH,
		weapontype = ATK_ICE,
		st = 4,
		ma = 0,
		lu = -2,
		ag = -1,
		en = 1,
		skills = {"snap", "zio", "bufu"},
	},

	["narcissus"] = {
		name = "Narcissus",
		sprite = SPR_SBPR,
		frame = J,
		lv = 13,
		arcana = ARCANA_LOVERS,
		weapontype = ATK_WIND,
		st = -2,
		ma = 3,
		lu = 1,
		ag = 0,
		en = 1,
		skills = {"media", "garu", "makanda"},
	},

	["oberon"] = {
		name = "Oberon",
		sprite = SPR_SBPR,
		frame = K,
		lv = 11,
		arcana = ARCANA_EMPEROR,
		weapontype = ATK_ELEC,
		st = 0,
		ma = 2,
		lu = -2,
		ag = -3,
		en = -2,
		skills = {"mazio", "zionga", "dekaja"},
	},

	["principality"] = {
		name = "Principality",
		sprite = SPR_SBPR,
		frame = L,
		lv = 14,
		arcana = ARCANA_EMPEROR,
		weapontype = ATK_BLESS,
		st = 0,
		ma = 2,
		lu = 3,
		ag = -1,
		en = -3,
		skills = {"mahama", "kouha", "dia"},
	},

	["pyro jack"] = {
		name = "Pyro Jack",
		sprite = SPR_SBPR,
		frame = M,
		lv = 12,
		arcana = ARCANA_MAGICIAN,
		weapontype = ATK_FIRE,
		st = 0,
		ma = 3,
		lu = 0,
		ag = 0,
		en = -1,
		skills = {"agilao", "rakukaja"},
	},

	-- THEBEL SUBPERSONAS
	["jack frost"] = {
		name = "Jack Frost",
		sprite = SPR_SBPR,
		frame = A,
		lv = 3,
		arcana = ARCANA_MAGICIAN,
		weapontype = ATK_ICE,
		st = -3,
		ma = 3,
		en = -1,
		ag = 0,
		lu = 0,
		skills = {"bufu", "rakunda"}
	},

	["pixie"] = {
		name = "Pixie",
		sprite = SPR_SBPR,
		frame = C,
		lv = 2,
		arcana = ARCANA_LOVERS,
		weapontype = ATK_ELEC,
		st = 0,
		ma = 2,
		en = -2,
		ag = 3,
		lu = 0,
		skills = {"zio", {"dia", 3}, {"patra", 4}, {"agi", 5}, {"garu", 6}, {"frei", 7}, {"kouha", 8}}
	},

	["nata taishi"] = {
		name = "Nata Taishi",
		sprite = SPR_SBPR,
		frame = D,
		lv = 9,
		arcana = ARCANA_CHARIOT,
		weapontype = ATK_STRIKE,
		st = 3,
		ma = -2,
		en = 1,
		ag = 1,
		lu = 0,
		skills = {"lunge", "dekunda"}
	},

	["angel"] = {
		name = "Angel",
		sprite = SPR_SBPR,
		frame = E,
		lv = 2,
		arcana = ARCANA_JUSTICE,
		weapontype = ATK_BLESS,
		st = -2,
		ma = 2,
		en = 0,
		ag = 3,
		lu = 2,
		skills = {"hama", "garu", "dia"}
	},

	["ghoul"] = {
		name = "Ghoul",
		sprite = SPR_SBPR,
		frame = F,
		lv = 3,
		arcana = ARCANA_DEATH,
		weapontype = ATK_CURSE,
		st = 1,
		ma = 2,
		en = -1,
		ag = 1,
		lu = 3,
		skills = {"mudo", "eiha", "dekaja"}
	},
})