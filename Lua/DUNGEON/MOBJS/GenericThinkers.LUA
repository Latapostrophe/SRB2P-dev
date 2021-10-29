-- Some generic thinkers for Shadows:
-- ie: Red shadow glow, golden shadow glow etc

-- some constants?
local emotions = {
	"EMOTE_EXCLAMATION",
	"EMOTE_SURPRISED",
}

for i = 1, #emotions do
	rawset(_G, emotions[i], i-1)
end

rawset(_G, "emotionBubble", function(mo, frame, zoffs)

	if zoffs == nil
		zoffs = mo.scale*48
	end

	local excl = P_SpawnMobj(mo.x, mo.y, mo.z+zoffs, MT_DUMMY)
	excl.flags = MF_NOCLIPHEIGHT|MF_NOGRAVITY|MF_NOBLOCKMAP
	excl.scale = 1
	excl.destscale = FRACUNIT*2
	excl.scalespeed = FRACUNIT/2
	excl.sprite = SPR_XCLA
	excl.frame = frame|FF_FULLBRIGHT
	excl.fuse = 20
	excl.momx = P_RandomRange(-3, 3)*FRACUNIT
	excl.momy = P_RandomRange(-3, 3)*FRACUNIT
end)

-- Can actually be any colour
rawset(_G, "redShadowGlow", function(mo, colour)
	local tflag = (5+  (4*cos(leveltime*ANG1*6))/FRACUNIT)<<FF_TRANSSHIFT
	local camx = mo.x+mo.momx - 2*cos(R_PointToAngle(mo.x, mo.y))
	local camy = mo.y+mo.momy - 2*sin(R_PointToAngle(mo.x, mo.y))

	local s = P_SpawnMobj(camx, camy, mo.z, MT_DUMMY)
	s.sprite = mo.sprite
	s.frame = (mo.frame & FF_FRAMEMASK)|tflag|FF_FULLBRIGHT
	s.tics = 2
	s.angle = mo.angle
	s.scale = mo.scale
	s.colorized = true
	s.color = colour or SKINCOLOR_RED
end)

rawset(_G, "goldShadowGlow", function(mo)
	mo.colorized = true
	mo.color = SKINCOLOR_YELLOW
	mo.frame = $|FF_FULLBRIGHT
	-- sparkles

	if leveltime%5 == 0
		local s = P_SpawnMobj(mo.x + P_RandomRange(-64, 64)*FRACUNIT, mo.y + P_RandomRange(-64, 64)*FRACUNIT, mo.z, MT_DUMMY)
		s.state = S_BOXSPARKLE1
		s.scale = $*2
		s.momz = P_RandomRange(1, 4)*FRACUNIT
	end
end)