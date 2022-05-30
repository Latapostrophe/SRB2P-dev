-- Mods that aim to edit any hud have to contend with the fact that for many huds, the original hud code is always
-- running and unable to be disabled, thats where this table comes in:
-- EnabledHuds["hud_functionname"] = true will allow the relevant hud function to render, setting the entry to false
-- will disable it from running. At that point we hold the hud editing mod liable for any wackiness.
rawset(_G, "EnabledHuds", {
	["NET"] = true, -- Net Huds have to be fully brought over for any hud edit, so we can group them all together
	["Battle"] = true, -- Battle Huds have to be fully brought over for any hud edit, so ditto to above
	["Dungeon"] = true,
	["Scoreboard"] = true,
	["Title"] = true, -- Erm...what the scallop
	["SystemMenu"] = true,
})