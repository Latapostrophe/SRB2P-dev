
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