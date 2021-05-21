hud.add(function(v, player)
	v.drawString(0, 0, AngleFixed(player.s2ss_angle)/FRACUNIT)
end)

COM_AddCommand("toggles2ss", function(player)
	doingTheSpecialStage = not $
	if not doingTheSpecialStage then
		player.awayviewtics = 0
		player.pflags = $ & ~PF_NOCLIP
		player.s2ss_angle = FixedAngle(270*FRACUNIT)
		if player.mo and player.mo.valid then
			player.mo.flags = $ & ~MF_NOCLIP & ~MF_NOCLIPHEIGHT
			player.mo.rollangle = 0
		end
	else
		player.awayviewtics = -1
		player.pflags = $ | PF_NOCLIP
		player.s2ss_angle = FixedAngle(270*FRACUNIT)
		if player.mo and player.mo.valid then
			player.mo.flags = $ | MF_NOCLIP | MF_NOCLIPHEIGHT
			player.mo.rollangle = 0
		end
	end
end)

COM_AddCommand("turnleft", function(player)
	player.s2ss_anchor.resultangle = $ + ANGLE_90
	player.s2ss_anchor.anglespeed = FixedAngle(3*FRACUNIT)
end)

COM_AddCommand("turnright", function(player)
	player.s2ss_anchor.resultangle = $ - ANGLE_90
	player.s2ss_anchor.anglespeed = FixedAngle(3*FRACUNIT)
end)

COM_AddCommand("radius", function(player, r)
	if tonumber(r) == nil then
		print("doofus")
	else
		radius = tonumber(r)*FRACUNIT
	end
end)