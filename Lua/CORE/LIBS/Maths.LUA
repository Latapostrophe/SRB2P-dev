
-- iSqrt(int)
-- Rough approximation of a number's square root
-- NO DECIMALS!

rawset(_G, "iSqrt", function(n)

	assert(n >= 0, "iSqrt: Square root domain error")

	local err = 1
	local s = n

	while ((s-n /s) > err)
		s = max(1, (s+n/s) /2)	-- careful because of divide by 0 errrors
	end

	return s
end)

-- clamp
-- clamps a v between a and b

rawset(_G, "clamp", function(v, a, b)
	if a < b
		return min(b, max(v, a))
	else
		return min(a, max(v, b))
	end
end)

-- spline garbage, returns a position along a path of points.
-- This takes a fixed_t between 0 and FRACUNIT
-- ...And gives us the point on a spline.
-- Basically, fixed math hell
rawset(_G, "pointOnSpline", function(path, frac)

	local p0, p1, p2, p3
	p1 = frac/FRACUNIT +1	-- +1 because lua is not 0-indexed

	-- out of bounds check
	if p1 == #path
		p2 = p1
	else
		p2 = p1 + 1
	end

	-- another out of bounds check
	if p2 == #path
		p3 = p2
	else
		p3 = p2 + 1
	end

	-- this one is safe
	p0 = max(1, p1 - 1)

	frac = $ - FixedFloor($)

	-- cache frac^2 and frac^3
	local fsq = FixedMul(frac, frac)
	local fcb = FixedMul(fsq, frac)

	-- equations:
	local q1 = -fcb + FixedMul(2<<FRACBITS, fsq) - frac
	local q2 = FixedMul(3<<FRACBITS, fcb) - FixedMul(5<<FRACBITS, fsq) + 2<<FRACBITS
	local q3 = -FixedMul(3<<FRACBITS, fcb) + FixedMul(4<<FRACBITS, fsq) + frac
	local q4 = fcb - fsq

	-- now get the points from the dark magic above:
	--print(p0, p1, p2, p3)

	local tx = FixedMul(FRACUNIT>>1, FixedMul(path[p0].x, q1) + FixedMul(path[p1].x, q2) + FixedMul(path[p2].x, q3) + FixedMul(path[p3].x, q4))
	local ty = FixedMul(FRACUNIT>>1, FixedMul(path[p0].y, q1) + FixedMul(path[p1].y, q2) + FixedMul(path[p2].y, q3) + FixedMul(path[p3].y, q4))
	local tz = FixedMul(FRACUNIT>>1, FixedMul(path[p0].z, q1) + FixedMul(path[p1].z, q2) + FixedMul(path[p2].z, q3) + FixedMul(path[p3].z, q4))

	return {x = tx, y = ty, z = tz}
end)

rawset(_G, "lerp", function(start, finish, percent)
	return start + FixedMul(finish-start, FRACUNIT-percent)
end)