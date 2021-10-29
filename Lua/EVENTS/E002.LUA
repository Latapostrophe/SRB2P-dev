eventList["ev_test"] = {
	[1] = {"function",
		function(evt, battle)

			if evt.ftimer == 1
				for p in players.iterate do
					if p.mo and p.mo.valid
						p.mo.flags2 = $|MF2_DONTDRAW
					end
				end

				local p = players[0]
				local mo = players[0].mo
				if not mo return end

				local x = mo.x + 384*cos(mo.angle)
				local y = mo.y + 384*sin(mo.angle)
				P_TeleportMove(battle.cam, x, y, battle.cam.z)
				battle.cam.angle = R_PointToAngle2(battle.cam.x, battle.cam.y, mo.x, mo.y)

				x = mo.x + 4128*cos(mo.angle)
				y = mo.y + 4128*sin(mo.angle)

				CAM_goto(x, y, battle.cam.z, FRACUNIT/4)

				-- make the bots happy:
				local ans = {0, 90, 270, 180}
				for i = 1, #server.plentities
					x = mo.x + 128*cos(mo.angle + ANG1*ans[i])
					y = mo.y + 128*sin(mo.angle + ANG1*ans[i])
					P_TeleportMove(server.plentities[i], x, y, mo.z)
					server.plentities[i].angle = mo.angle
					ANIM_set(server.plentities[i], server.plentities[i].anim_stand_bored, true)
				end

			elseif evt.ftimer == TICRATE
				return true
			end
		end},
	[2] = {"text", "Tails", "Looks like this is the place.", nil, true},
	[3] = {"text", "Knuckles", "Greenflower again, seriously...?", nil, true},
	[4] = {"text", "Sonic", "Look on the bright side,this\narea isn't very big so we'll\nfind our target in no time!", nil, true},
	[5] = {"text", "Knuckles", "Whatever.\nLet's hurry on then!", nil, true},

	[6] = {"function", function(evt, btl)

				local p = players[0]
				local mo = players[0].mo
				if not mo return end

				-- spawn some enemies because plot plot plot PLOT PLOT
				if evt.ftimer == 1
					btl.cam.goto = {}

					local nx, ny = mo.x - 384*cos(mo.angle), mo.y - 384*sin(mo.angle)
					P_TeleportMove(btl.cam, nx, ny, btl.cam.z)
					P_InstaThrust(btl.cam, 0, 0)
					btl.cam.angle = R_PointToAngle2(btl.cam.x, btl.cam.y, mo.x, mo.y)

					evt.tempentities = {}	-- set table

				elseif evt.ftimer == 20

					-- spawn 2 shadows:
					local an = 20
					for i = 1, 2
						local nx, ny = mo.x + 384*cos(mo.angle + an*ANG1), mo.y + 384*sin(mo.angle + an*ANG1)
						evt.tempentities[i] = P_SpawnMobj(nx, ny, mo.z, MT_THOK)
						evt.tempentities[i].sprite = SPR_ENM1
						evt.tempentities[i].frame = A
						evt.tempentities[i].tics = -1
						evt.tempentities[i].scale = 1
						evt.tempentities[i].destscale = FRACUNIT
						evt.tempentities[i].angle = R_PointToAngle2(evt.tempentities[i].x, evt.tempentities[i].y, mo.x, mo.y)

						for j = 1, 32
							local t = P_SpawnMobj(nx + P_RandomRange(-64, 64)<<FRACBITS, ny + P_RandomRange(-64, 64)<<FRACBITS, mo.z + P_RandomRange(0, 64)<<FRACBITS, MT_THOK)
							t.color = j%2 and SKINCOLOR_RED or SKINCOLOR_BLACK
							t.momz = P_RandomRange(0, 8)<<FRACBITS
							t.frame = A
							t.destscale = 1
						end

						an = $* -1
					end
				elseif evt.ftimer == 40
					return true
				end
			end},

	[7] = {"text", "Sonic", "Looks like we're being \ngiven a warm welcome \neither way!"},
	[8] = {"text", "Sonic", "Let's get this party started!", nil, true},
	[9] = {"function", function(evt, btl)

					-- select wave:
				local wave = {"test_entity", "test_entity"}

				-- start battle
				local team_1 = server.plentities
				local team_2 = {}
				for i = 1,#wave
					local enm = P_SpawnMobj(0, 0, 0, MT_PFIGHTER)
					enm.state = S_PLAY_STND
					enm.tics = -1
					enm.enemy = wave[i]
					team_2[#team_2+1] = enm
				end

				local dummyfunc = function(btl)
				if not btl.playedscene
					D_startEvent("ev_001")
					btl.playedscene = true
				end
			end

			BTL_StartBattle(team_1, team_2, 0, dummyfunc)
			return true
		end}
}