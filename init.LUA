-- SRB2P Initialization file

local f = ""
local function df(file)
	dofile(f.."/"..file)
end

print("Starting SRB2P initialization ...")

print("Initializing core files...")
-- Keys library
	f = "CORE"
	df("Globalize.LUA")

	f = "CORE/KEYSINPUT"
		df("KeysLib.LUA")
		df("KeyNames.LUA")

-- Generic libraries
	f = "CORE/LIBS"
		df("Maths.LUA")
		df("Json.LUA")

-- CORE
f = "CORE"
	df("Main.LUA")
	df("Core.LUA")
	df("Unlocks.LUA")
	df("Input.LUA")
	df("Anim.LUA")
	df("RNG.LUA")
	df("Save.LUA")
	df("JSSave.LUA")
	df("Date.LUA")
	df("Freeslots.LUA")
	f = "CORE/FREESLOT_CHARS"
		df("Freeslot_Shadow.LUA")
		df("Freeslot_Kanade.LUA")
		df("Freeslot_Blaze.LUA")

-- EVENTS
print("Initializing Events library...")

f = "EVENTS"
	df("Event_Handler.LUA")
	--df("gameover.LUA")
	--df("E001.LUA")
	--df("E002.LUA")

	f = "EVENTS/Tutorial"
		df("Tutorial_1.LUA")

	f = "EVENTS/VoidRun"
		df("Intro.LUA")

	f = "EVENTS/Marathon"
		df("TartarusPeak.LUA")
		df("B7.LUA")



-- STATS
print("Initializing stats tables...")
f = "STATS"
	df("Persona_Stats.LUA")
	df("Subpersona.LUA")
	df("Player_Defs.LUA")
	df("Player_Stats.LUA")
	df("Enemy_Stats.LUA")
	df("RogueGen.LUA")

-- ITEM
print("Initializing item tables...")
f = "ITEM"
	df("Item_Defs.LUA")
	df("Weapon_Defs.LUA")
	df("Ring_Defs.LUA")

-- ATTACK
print("Initializing attack functions & tables...")
f = "ATTACK"
	df("Attack_Funcs.LUA")
	df("Attack_Defs.LUA")

--MENU
print("Initializing menu libraries...")
	f = "MENU/INGAME_MENUS"
		df("Menu_Handler.LUA")

f = $.."/MENULIST"
			df("Menu_NET.LUA")
			df("Menu_QSave.LUA")
			df("Pause_MP.LUA")
			df("Pause_SP.LUA")
			df("SelectShop.LUA")

f = "MENU/SYSMENUS"
		df("SysMenu_Lib.LUA")
		df("SystemMenus.LUA")
		df("Title_Defs.LUA")
		df("Title_Main.LUA")

-- BATTLE
print("Initializing Battle libraries...")
f = "BATTLE"
	df("Battle_Defs.LUA")
	df("Battle_Botdefs.LUA")
	df("Battle.LUA")
	df("Battle_PVPsetup.LUA")
	df("Challenge_Battle.LUA")

-- DUNGEON
print("Initializing Dungeon crawler librairies...")
f = "DUNGEON"
	df("Dungeon_Defs.LUA")
	df("Dungeon_Waves.LUA")
	df("Dungeon_Abilities.LUA")
	df("Dungeon_Handler.LUA")
	df("Dungeon_Cards.LUA")
	df("Dungeon_Personas.LUA")

	f = "DUNGEON/TARTARUS"
		df("Tartarus_Defs.LUA")
		df("Map_Generator.LUA")
		df("tartarus_Gen.LUA")
		df("tartarus_Crawler.LUA")

		f = $.."/FLOORS"
			df("Tartarus_Floordata.LUA")
			df("Tartarus_Floors.LUA")
			df("Tartarus_Wavedefs.LUA")
			df("Tartarus_ShuffleData.LUA")
			df("Tartarus_Personas.LUA")
			df("Tartarus_Item_List.LUA")

	f = "DUNGEON/MOBJS"
		df("ItemBoxes.LUA")
		df("RingClusters.LUA")
		df("Switch.LUA")
		df("GenericThinkers.LUA")
		df("Floor_Shadow.LUA")
		df("Fog_Shadow.LUA")
		df("Ambusher.LUA")
		df("Reaper.LUA")
		df("Drops.LUA")

	f = "DUNGEON/SHOPS"
		df("Dungeon_Shop.LUA")
		df("VelvetShop_MP.LUA")
		df("VoidShop.LUA")

	f = "DUNGEON/EQUIPLAB"
		df("EquipmentLab.LUA")

	f = "DUNGEON/VOIDRUN"
		df("Voidrun_Defs.LUA")
		df("Voidrun_Floordata.LUA")
		df("Voidrun_Floors.LUA")
		df("Voidrun_Wavedefs.LUA")
		df("Voidrun_Item_List.LUA")
		df("Voidrun_Handler.LUA")

-- NET
print("Initiating Netsetup librairies...")
f = "NET"
	df("Net_Team.LUA")
	df("Net_Resynch.LUA")

-- RENDERER
print("Initiating HUD rendering...")
f = "RENDERER"
	df("Render_Fonts.LUA")
	df("Render_Date.LUA")
	df("Render_Event.LUA")
	df("Render_Battle.LUA")
	df("Render_Menus.LUA")
	df("Render_Shop.LUA")
	df("Render_EqLab.LUA")
	df("Render_Dungeon.LUA")
	df("Render_SCR.LUA")
	df("Render_PhysHUD.LUA")
	df("Render_NET.LUA")
	df("Render_Scoreboard.LUA")
	df("Smenu.LUA")


-- MODDING
print("Initializing modding hooks library...")
f = "MODDING"
	df("Hooks.LUA")
	df("HudHooks.LUA")
	df("Map_editor.LUA")
	df("CustomDungeonReader.LUA")

print("SRB2P Script Initialization complete")