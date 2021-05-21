rawset(_G, "radius", 180*FRACUNIT)
rawset(_G, "doingTheSpecialStage", true)
rawset(_G, "limit", function(v, min, max)
	return (v < min and min) or (v > max and max) or v
end)

freeslot("MT_S2SSANCHOR")

mobjinfo[MT_S2SSANCHOR] = {
	spawnstate = S_INVISIBLE,
	flags = MF_NOBLOCKMAP|MF_NOSECTOR|MF_NOCLIP|MF_NOCLIPHEIGHT|MF_NOGRAVITY|MF_SCENERY
}

local function playerSpawn(player)
	local mo = player.mo

	player.s2ss_angle = FixedAngle(270*FRACUNIT) // Angle in the half-pipe.
	player.s2ss_anglemom = FixedAngle(0) // How fast you are going angularly on the half-pipe.

	local anchor = P_SpawnMobj(mo.x, mo.y, mo.z + radius*4/5, MT_S2SSANCHOR) // The anchor point; you follow this.
	anchor.angle = FixedAngle(90*FRACUNIT) // The angle relative to the map. Rotate it to rotate everything!
	anchor.resultangle = anchor.angle

	player.s2ss_x = 0 // X position relative to the anchor point, only when off ground.
	player.s2ss_y = 0 // Y position relative to the anchor point, only when off ground.

	player.s2ss_momx = 0 // X momentum for X position
	player.s2ss_momy = 0 // Y momentum for Y position

	local camera = P_SpawnMobj(mo.x, mo.y, mo.z, MT_THOK) // The camera; you see with this.
	camera.state = S_INVISIBLE

	P_TeleportMove(camera, anchor.x - 128*FRACUNIT, anchor.y, anchor.z)

	player.onGround = true
	
	player.s2ss_anchor = anchor
	player.awayviewmobj = camera

	player.awayviewtics = -1
end

addHook("PlayerSpawn", playerSpawn)