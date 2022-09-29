-- some screen stuff?
-- like GetScreenCoords

-- these two funcs handle steep lines, we don't need them outside of here since R_drawLine will do this for us
local function R_LineLow(v, x0,y0, x1,y1, c, thicc)
	local dx = x1 - x0
	local dy = y1 - y0
	local yi = 1

	if dy < 0
		yi = -1
		dy = -dy
	end

	local D = 2*dy - dx
	local y = y0

	for x = x0, x1
	v.drawFill(x, y, thicc or 1, thicc or 1, c)
		if D > 0
			y = y + yi
			D = D - 2*dx
		end
		D = D + 2*dy
	end
end

local function R_LineHigh(v, x0,y0, x1,y1, c, thicc)
	local dx = x1 - x0
	local dy = y1 - y0
	local xi = 1

	if dx < 0
		xi = -1
		dx = -dx
	end

	local D = 2*dx - dy
	local x = x0

	for y = y0, y1
		v.drawFill(x, y, thicc or 1, thicc or 1, c)
		if D > 0
			x = x + xi
			D = D - 2*dy
		end
		D = D + 2*dx
	end
end

-- lazy line drawer
rawset(_G, "R_drawLine", function(v, x0, y0, x1, y1, c, thicc)
	if abs(y1 - y0) < abs(x1 - x0)
		if x0 > x1
			R_LineLow(v, x1, y1, x0, y0, c, thicc)
		else
			R_LineLow(v, x0, y0, x1, y1, c, thicc)
		end
	else
		if y0 > y1
			R_LineHigh(v, x1, y1, x0, y0, c, thicc)
		else
			R_LineHigh(v, x0, y0, x1, y1, c, thicc)
		end
	end
 end)

 -- line drawer with angle
 -- reminder that angle 0 is ---> and then counts counterclockwise. (think trigonometric circle)
 rawset(_G, "R_drawAngledLine", function(v, x, y, an, llen, c, thicc)
	-- shift all coords to be fixed:
	local newx = x<<FRACBITS + llen*cos(-an)	-- for some reason the angle is inverted here?
	local newy = y<<FRACBITS + llen*sin(-an)

	R_drawLine(v, x, y, newx/FRACUNIT, newy/FRACUNIT, c, thicc)
 end)

local cached_px

 -- 640x400 based line renderer: much slower, use carefully
 -- the big funny is that we have to use noscalestart.
 -- it makes me want to commit not live

-- adjust coords for flags
local function R_AdjustCoords(x, y, flags)

end

local dupx, dupy		-- dupx, dupy
local hdupx, hdupy		-- half dupx, half dupy, used for line optimization
local nfdupx, nfdupy	-- non fixed dupx and dupy

-- NoScaledCoord
local function R_NSC(c, d)
	return (c*d)>>FRACBITS
end

local function R_LineLow_640(v, x0,y0, x1,y1, c, flags, thicc, thicc2)
	local dx = x1 - x0
	local dy = y1 - y0
	local yi = 1

	if dy < 0
		yi = -1
		dy = -dy
	end

	local D = 2*dy - dx
	local y = y0

	for x = x0, x1
	v.drawFill(R_NSC(x, dupx), R_NSC(y, hdupy), thicc, thicc2, c)
		if D > 0
			y = y + yi
			D = D - 2*dx
		end
		D = D + 2*dy
	end
end

local function R_LineHigh_640(v, x0,y0, x1,y1, c, flags, thicc, thicc2)
	local dx = x1 - x0
	local dy = y1 - y0
	local xi = 1

	if dx < 0
		xi = -1
		dx = -dx
	end

	local D = 2*dx - dy
	local x = x0

	for y = y0, y1
		v.drawFill(R_NSC(x, hdupx), R_NSC(y, dupy), thicc, thicc2, c)
		if D > 0
			x = x + xi
			D = D - 2*dy
		end
		D = D + 2*dx
	end
end

-- lazy line drawer
rawset(_G, "R_drawLine_640", function(v, x0, y0, x1, y1, c, flags, thicc)
	c = $|V_NOSCALESTART

	nfdupx, dupx = v.dupx()
	nfdupy, dupy = v.dupy()	-- do not fetch these each pixel...

	-- precache sizes
	local sizex = R_NSC(thicc or 1, dupx)
	local sizey = R_NSC(thicc or 1, dupy)

	-- optimize line drawing
	hdupx, hdupy = dupx/2, dupy/2

	x0 = $*2
	x1 = $*2
	y0 = $*2
	y1 = $*2

	if abs(y1 - y0) < abs(x1 - x0)
		if x0 > x1
			R_LineLow_640(v, x1/2, y1, x0/2, y0, c, flags, sizex, sizey)
		else
			R_LineLow_640(v, x0/2, y0, x1/2, y1, c, flags, sizex, sizey)
		end
	else
		if y0 > y1
			R_LineHigh_640(v, x1, y1/2, x0, y0/2, c, flags, sizex, sizey)
		else
			R_LineHigh_640(v, x0, y0/2, x1, y1/2, c, flags, sizex, sizey)
		end
	end
 end)

 -- line drawer with angle
 -- reminder that angle 0 is ---> and then counts counterclockwise. (think trigonometric circle)
 rawset(_G, "R_drawAngledLine_640", function(v, x, y, an, llen, c, thicc)
	-- shift all coords to be fixed:
	local newx = x<<FRACBITS + llen*cos(-an)	-- for some reason the angle is inverted here?
	local newy = y<<FRACBITS + llen*sin(-an)

	R_drawLine_640(v, x, y, newx/FRACUNIT, newy/FRACUNIT, c, flags, thicc)
 end)

-- less lazy triangle drawer
rawset(_G, "R_drawTriangle", function(v, x1, y1, x2, y2, x3, y3, color)
	color = $ or 0
	local points = {
		{x=x1/FRACUNIT, y=y1/FRACUNIT},
		{x=x2/FRACUNIT, y=y2/FRACUNIT},
		{x=x3/FRACUNIT, y=y3/FRACUNIT}		-- << use fixed point to make it easier to deal with trig when we supply coords
	}
	table.sort(points, function(a, b) return a.y <= b.y end)
	-- sort points so that y1 <= y2 <= y3
	local A, B, C = points[1], points[2], points[3]
	local dx1 = (B.y-A.y > 0) and FixedDiv((B.x-A.x)<<FRACBITS, (B.y-A.y)<<FRACBITS) or 0
	local dx2 = (C.y-A.y > 0) and FixedDiv((C.x-A.x)<<FRACBITS ,(C.y-A.y)<<FRACBITS) or 0
	local dx3 = (C.y-B.y > 0) and FixedDiv((C.x-B.x)<<FRACBITS ,(C.y-B.y)<<FRACBITS) or 0

	local ix, iy = A.x<<FRACBITS, A.y<<FRACBITS	-- start coords
	local ex, ey = ix, iy	-- end coords
	if dx1 > dx2 then
		while iy <= B.y<<FRACBITS
			v.drawFill(ix>>FRACBITS, iy>>FRACBITS, (ex-ix)/FRACUNIT, 1, color)	-- << divide ex-ix because we will get errors if we bitshift
			iy = $+FRACUNIT
			ix = $+dx2
			ex = $+dx1
		end
		ex, ey = B.x<<FRACBITS, B.y<<FRACBITS
		while iy < C.y<<FRACBITS
			v.drawFill(ix>>FRACBITS, iy>>FRACBITS, (ex-ix)/FRACUNIT, 1, color)
			iy = $+FRACUNIT
			ix = $+dx2
			ex = $+dx3
		end

	else
		while iy <= B.y<<FRACBITS
			v.drawFill(ix>>FRACBITS, iy>>FRACBITS, (ex-ix)/FRACUNIT, 1, color)
			iy = $+FRACUNIT
			ix = $+dx1
			ex = $+dx2
		end
		ix, iy = B.x<<FRACBITS, B.y<<FRACBITS
		while iy < C.y<<FRACBITS
			v.drawFill(ix>>FRACBITS, iy>>FRACBITS, (ex-ix)/FRACUNIT, 1, color)
			iy = $+FRACUNIT
			ix = $+dx3
			ex = $+dx2
		end
	end
end)

local BASEVIDWIDTH = 320
local BASEVIDHEIGHT = 200	-- man this resolution is awful

rawset(_G, "drawScreenwidePatch", function(v, patch, colormap, flags, hack)

	-- for GL use the default because it scales with it anyway
	local patchScale = FixedDiv(BASEVIDWIDTH*FRACUNIT, ((patch.width + (hack or 0))*FRACUNIT))
	local xOffset = 0
	local yOffset = (BASEVIDHEIGHT*FRACUNIT - FixedMul(patch.height*FRACUNIT, patchScale)) / 2 -- centre it vertically

	-- Scale the patch so that it always fills the entire screen
	local sxf = FixedDiv(v.width()*FRACUNIT, BASEVIDWIDTH*FRACUNIT)
	local syf = FixedDiv(v.height()*FRACUNIT, BASEVIDHEIGHT*FRACUNIT)
	local oldPatchScale,newPatchScale
	if sxf > syf then
		oldPatchScale = (v.height() / BASEVIDHEIGHT)*FRACUNIT
	else
		oldPatchScale = (v.width() / BASEVIDWIDTH)*FRACUNIT
	end
	newPatchScale = sxf
	patchScale = FixedMul(patchScale, FixedDiv(newPatchScale, oldPatchScale))

	-- need to offset if scaled
	-- someone please end my suffering
	local patchRealHeight = FixedMul(FixedMul(patch.height*FRACUNIT, patchScale), oldPatchScale)
	yOffset = (v.height()*FRACUNIT - patchRealHeight) / 2
	yOffset = FixedDiv(yOffset, oldPatchScale)
	v.drawScaled(xOffset, yOffset, patchScale, patch, V_SNAPTOTOP|V_SNAPTOLEFT|(flags or 0), colormap)
end)

rawset(_G, "R_GetNoscaledCoords", function(v, x, y)	-- this is for software because hud rendering fucking sucks on software
	return FixedMul(x, select(2,v.dupx())) / FRACUNIT, FixedMul(y, select(2,v.dupy())) / FRACUNIT
end)

rawset(_G, "R_NoScaleX", function(v, x)
	return FixedMul(x, select(2,v.dupx()))
end)

rawset(_G, "R_NoScaleY", function(v, y)
	return FixedMul(y, select(2,v.dupy()))
end)

rawset(_G, "R_GetScreenCoords", function(v, p, c, mx, my, mz)
	local camx, camy, camz, camangle, camaiming
	if p.awayviewtics then
		camx = p.awayviewmobj.x
		camy = p.awayviewmobj.y
		camz = p.awayviewmobj.z
		camangle = p.awayviewmobj.angle
		camaiming = p.awayviewaiming
	elseif c.chase then
		camx = c.x
		camy = c.y
		camz = c.z
		camangle = c.angle
		camaiming = c.aiming
	else
		camx = p.mo.x
		camy = p.mo.y
		camz = p.viewz-20*FRACUNIT
		camangle = p.mo.angle
		camaiming = p.aiming
	end

	-- Lat: I'm actually very lazy so mx can also be a mobj!
	if type(mx) == "userdata" and mx.valid
		my = mx.y
		mz = mx.z
		mx = mx.x	-- life is easier
	end

	local x = camangle-R_PointToAngle2(camx, camy, mx, my)

	local distfact = cos(x)
	if not distfact then
		distfact = 1
	end -- MonsterIestyn, your bloody table fixing...

	if x > ANGLE_90 or x < ANGLE_270 then
		return -9, -9, 0
	else
		x = FixedMul(tan(x, true), 160<<FRACBITS)+160<<FRACBITS
	end

	local y = camz-mz
	--print(y/FRACUNIT)
	y = FixedDiv(y, FixedMul(distfact, R_PointToDist2(camx, camy, mx, my)))
	y = (y*160)+(100<<FRACBITS)
	y = y+tan(camaiming, true)*160

	local scale = FixedDiv(160*FRACUNIT, FixedMul(distfact, R_PointToDist2(camx, camy, mx, my)))
	--print(scale)

	return x, y, scale
end)

-- stretchy number scales
rawset(_G, "numberscales", {

	{FRACUNIT/2, FRACUNIT*2},
	{FRACUNIT*3/4, FRACUNIT*3/2},
	{FRACUNIT, FRACUNIT},
	{FRACUNIT*3/2, FRACUNIT*3/4},
	{FRACUNIT*2, FRACUNIT/2},
	{FRACUNIT*3/2, FRACUNIT*3/4}
})

rawset(_G, "R_DisplayDamage", function(v, x, y, e, damage, color, color2, shake)

	local prefix = "DMG_N"
	damage = $ or 0
	if damage < 0	-- we got the heals
		if not color then color = 135 end
	end
	color = $ or 0
	color2 = $ or 31
	damage = tostring($)
	damage = string.gsub(damage, "-", "")	-- get rid of the minus, boo

	x = $ - (FRACUNIT*3)*string.len(damage)
	y = $ - FRACUNIT*48 + (FRACUNIT*3)*string.len(damage)

	local timer = not e and 999999 or e.damaged

	for i = 1, string.len(damage)
		if timer >= i*2
			local addx = 0
			local addy = 0
			local time = timer-i*2

			if time <= 0 continue end

			--local scale = e and min(FRACUNIT, time*8192) or FRACUNIT
			local dx = x
			local dy = not e and y or (y+20*FRACUNIT) - time*FRACUNIT*6

			local scale1 = FRACUNIT
			local scale2 = FRACUNIT

			if time > 5 and e
				dy = y
				scale1 = FRACUNIT/2
				scale2 = FRACUNIT/2
				if shake	-- for added effects on critical hits!
					addx = N_RandomRange(-2, 2)*FRACUNIT
					addy = N_RandomRange(-2, 2)*FRACUNIT
				end
			end

			local p = v.cachePatch(prefix..string.sub(damage, i, i))
			if time < 6
				scale1 = numberscales[time][1]
				scale2 = numberscales[time][2]
			end

			v.drawStretchedIndex(dx + addx + FRACUNIT*2, dy + addy + FRACUNIT*2, scale1, scale2, p, nil, color2)
			v.drawStretchedIndex(dx + addx, dy + addy, scale1, scale2, p, nil, color)
			if e
				x = $ + p.width*FRACUNIT/2 - FRACUNIT*2
				y = $ - FRACUNIT*2
			else
				x = $ + p.width*(scale*2/3)
				y = $ - (scale*2/3) /2
			end

		end
	end
end)

-- tiles a patch to fit the entire screen and adds the possibility for offsets

local scrwidth = 400	-- make sure we go overboard to fit any resolutions.
local scrheight = 250

rawset(_G, "tilePatch", function(v, patch, offsx, offsy, flags)
	local pp = v.cachePatch(patch)

	local nx = -pp.width + (offsx or 0)
	local ny = -pp.height + (offsy or 0)

	local x, y = nx, ny

	while x < scrwidth
		while y < scrheight
			v.draw(x, y, pp, flags)
			y = $+pp.height
		end

		y = ny
		x = $+pp.width
	end
end)

/*local function drawHP(v)
    local animtime = 6
    local xoff,yoff=29,69
    local final = {
        {29,69}, {6,52}, {12,47}, {7,45}, {3,30},
        {78,2}, {72,21}, {24,39}, {30,43}, {19,52}
    }
    for i=1,#final
        local v1,v2,v3 = final[(i==1 and #final or i)],final[i],final[(i==#final and 1 or i)]
		if i == 1
			print("P1 :"..v1[1]..", "..v1[2])
			print("P2 :"..v2[1]..", "..v2[2])
			print("P3 :"..v3[1]..", "..v3[2])
		end
        R_drawTriangle(v,v1[1]<<FRACBITS,v1[2]<<FRACBITS,v2[1]<<FRACBITS,v2[2]<<FRACBITS,v3[1]<<FRACBITS,v3[2]<<FRACBITS,31)
    end

	R_drawTriangle(v, 19<<FRACBITS, 52<<FRACBITS, 29<<FRACBITS, 69<<FRACBITS, 29<<FRACBITS, 69<<FRACBITS, 31)

end

hud.add(function(v,p,cam)
    drawHP(v)
end, "game")*/