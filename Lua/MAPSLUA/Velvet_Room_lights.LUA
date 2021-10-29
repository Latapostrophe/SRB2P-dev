local velvetsecs = {}

addHook("MapLoad",do
	velvetsecs = {}
	if mapheaderinfo[gamemap].velvet
		for s in sectors.iterate do
			if s.tag == 69
				velvetsecs[#velvetsecs+1] = s
			end
		end
	end
end)

addHook("ThinkFrame",do
	if velvetsecs and #velvetsecs

		for i = 1, #velvetsecs
			local s = velvetsecs[i]

			s.floorheight = $-96*FRACUNIT
			s.ceilingheight = $-96*FRACUNIT

			if s.floorheight < -512*FRACUNIT
				s.floorheight = 6500*FRACUNIT
				s.ceilingheight = (6500+308)*FRACUNIT
			end
		end
	end
end)