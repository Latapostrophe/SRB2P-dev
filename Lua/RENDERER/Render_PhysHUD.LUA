-- PhysHUD script!
-- this renders elements with "physics".

rawset(_G, "physHUD", {})

rawset(_G, "phud", {})

rawset(_G, "PF_FLIPPHYSICS", 1)
rawset(_G, "PF_NOGRAVITY", 2)

function phud.clear(group)
	physHUD[group] = {}
end

function phud.create(pn, x, y, sprite, tics, c, group)

	if server and displayplayer.control and displayplayer.control.battlen and displayplayer.control.battlen ~= pn
		return {}
	elseif server and displayplayer.P_party ~= pn	-- allow title to create physhuds anyway
		return {}	-- return garbage still
	end

	group = $ or "main"

	local t = {
				pn = pn,
				x = x,
				y = y,
				p = sprite,
				anim = {},
				animtimer = 0,
				animloop = true,
				animprogress = 1,
				momx = 0,
				momy = 0,
				physics = true,
				waitphysics = 0,
				splat = false,
				flags = 0,
				fuse = 0,
				physflags = 0,
				scale = FRACUNIT,
				destscale = FRACUNIT,
				scalespeed = FRACUNIT/12,
				deleteoffscreen = true,
				colormap = c,
				tics = tics or -1,
			}
	if not paused	-- don't add the HUD if the game has been paused.

		if not physHUD[group]
			physHUD[group] = {}
		end
		table.insert(physHUD[group], t)
	end
	return t
end

-- flush physHUD on every map load
addHook("MapLoad", do
	physHUD = {}
end)

rawset(_G, "DisplayPhysHUD", function(v, group, p)
	local clearcount= 0
	group = $ or "main"
	if not physHUD[group]
		--print("physHUD: invalid group to display?")
		return
	end
	if physHUD[group][1]
		for k, i in ipairs(physHUD[group])

			--if p and i.pn ~= p.P_party
			--	i.clear = true
			--	continue
			--end

			if i.clear
				clearcount = $+1
				continue
			end

			local pp = v.cachePatch(i.p)

			-- splats
			local splatflag = 0
			if i.splat
			and i.tics < 9
			and i.tics > -1
				splatflag = V_90TRANS - V_10TRANS * i.tics
			end
			v.drawScaled(i.x*FRACUNIT, i.y*FRACUNIT, i.scale, pp, i.flags|splatflag, i.colormap)

			if paused continue end	-- do not go farther than rendering if the game is paused

			-- handle other stuff now

			-- momentum

			if i.waitphysics then i.waitphysics = $-1 end	-- wait x tics before applying physics

			if i.physics
			and not i.waitphysics
				if i.physflags & PF_FLIPPHYSICS
					i.x = $ + i.momx
					i.y = $ + i.momy
				else
					i.x = $ + i.momx
					i.y = $ - i.momy
				end

				if not (i.physflags & PF_NOGRAVITY)
					if i.momy > 0
						i.momy = $/2
					else
						i.momy = min(-1, $*2)
					end
				end
			end

			-- scale
			if i.scale < i.destscale
			and not i.waitphysics
				i.scale = min(i.destscale, $+i.scalespeed)
			end
			if i.scale > i.destscale
			and not i.waitphysics
				i.scale = max(i.destscale, $-i.scalespeed)
			end

			-- animation
			local anim_time = i.anim[#i.anim]
			if anim_time

				i.p = i.anim[i.animprogress]
				if i.animtimer >= anim_time
				and (i.animprogress < #i.anim-1 or i.animloop)
					i.animprogress = $+1
					i.animtimer = 0
					if i.animprogress >= #i.anim
						i.animprogress = 1
					end
				end
				i.animtimer = $+1
			end

			-- tics
			if i.tics and i.tics > 0
				i.tics = $-1
				if not i.tics
					--table.remove(physHUD, k)
					i.clear = true
				end
			end

			if i.fuse
				i.fuse = $-1
				if not i.fuse
					i.clear = true
				end
			end

			-- delete off screen?
			if i.deleteoffscreen
				if i.x > 320
				or i.y > 200
				or i.x + pp.width < 0
				or i.y + pp.height < 0
					i.clear = true
					--table.remove(physHUD, k)
				end
			end
		end

		if clearcount >= #physHUD[group]
			physHUD[group] = {}
		end
	end
end)
