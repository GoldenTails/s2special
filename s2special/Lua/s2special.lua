local function jumpSpecial(player) // Jumping in the half-pipe.
	if not doingTheSpecialStage then
		return
	end

	if not player.mo or not player.mo.valid then
		return
	end

	local mo = player.mo

	if player.pflags & PF_JUMPDOWN then
		return
	end

	if not (player.pflags & PF_JUMPED) and player.onGround then
		player.pflags = $ | PF_JUMPED
		S_StartSound(mo, sfx_jump)

		mo.state = S_PLAY_JUMP
		mo.rollangle = FixedAngle(0)
		
		player.onGround = false

		player.s2ss_x = FixedMul(cos(player.s2ss_angle), radius)
		player.s2ss_y = FixedMul(sin(player.s2ss_angle), radius)

		player.s2ss_momx = cos(player.s2ss_angle) * -12
		player.s2ss_momy = sin(player.s2ss_angle) * -12

		player.s2ss_sticktime = 0
	end
end

local function abilitySpecial(player) // Disable all abilities.
	if doingTheSpecialStage then
		return true
	end
end

local function resetRollAngle(rollangle) // Rotates you to a normal orientation, call once per frame.
	// The speed at which you are centered at.
	local speed = FixedAngle(6*FRACUNIT)

	if rollangle > FixedAngle(0) + speed then // rollangle more than centered + centering speed?
		rollangle = $ - speed // Subtract the speed!
	elseif rollangle < FixedAngle(0) - speed then // rollangle less than centered - centering speed?
		rollangle = $ + speed // Add the speed!
	else // rollangle between +centering speed and -centering speed?
		rollangle = FixedAngle(0) // Center!
	end

	return rollangle // Return the resulting rollangle.
end

local function mobjThinker(mo)
	if not doingTheSpecialStage then
		return
	end

	if not mo.player or not mo.player.valid then
		return
	end

	local player = mo.player
	local lookAngle = R_PointToAngle(mo.x, mo.y) // Get the angle that we're looking from.
	local anchor = player.s2ss_anchor
	local camera = player.awayviewmobj

	//anchor.angle = $ + FixedAngle(FRACUNIT/4)

	mo.flags = $ | MF_NOCLIPHEIGHT | MF_NOCLIP
	player.pflags = $ | PF_GODMODE

	mo.angle = anchor.angle
	camera.angle = anchor.angle
	player.drawangle = anchor.angle

	// Add momentum here to eliminate jitter.
	if R_PointToDist2(0, 0, player.s2ss_x + player.s2ss_momx, player.s2ss_y + player.s2ss_momy) > radius then
		player.pflags = $ & ~PF_JUMPED
		player.onGround = true
		player.s2ss_anglemom = FixedAngle(0)
		player.s2ss_angle = R_PointToAngle2(0, 0, player.s2ss_x + player.s2ss_momx, player.s2ss_y + player.s2ss_momy)
		mo.state = S_PLAY_WALK

		player.s2ss_x, player.s2ss_y = 0, 0
	end

	if player.onGround then
		s2ss_doOnPipe(mo)
	else
		// Attempts to create SRB2's off-ground environment but in 2D.
		
		player.s2ss_momx = $ - player.cmd.sidemove * ((player.thrustfactor * player.acceleration) + player.accelstart)
		player.s2ss_momy = $ + P_GetMobjGravity(mo) // Apply gravity

		player.s2ss_x = $ + player.s2ss_momx
		player.s2ss_y = $ + player.s2ss_momy

		// Apply to mobj momentum because Tails' tails are too complicated to recode
		// Also helps when you suddenly get ejected from special stage mode I guess
		mo.momx = FixedMul(player.s2ss_momx, cos(anchor.angle + ANGLE_90))
		mo.momy = FixedMul(player.s2ss_momx, sin(anchor.angle + ANGLE_90))
		mo.momz = player.s2ss_momy
		
		P_TeleportMove(
			mo,
			anchor.x + FixedMul(player.s2ss_x, cos(anchor.angle + ANGLE_90)),
			anchor.y + FixedMul(player.s2ss_x, sin(anchor.angle + ANGLE_90)),
			anchor.z + player.s2ss_y
		)

		mo.rollangle = resetRollAngle(mo.rollangle)
	end

	P_InstaThrust(anchor, anchor.angle, 24*FRACUNIT)

	local zoffset = anchor.z + FixedMul(radius/2, cos(player.s2ss_angle - ANGLE_90))

	if not player.onGround then
		zoffset = anchor.z + player.s2ss_y/2
	end

	P_TeleportMove(
		camera,
		anchor.x - FixedMul(radius*5/2, cos(anchor.angle)),
		anchor.y - FixedMul(radius*5/2, sin(anchor.angle)),
		zoffset
	)
end

local function thinkFrame()
	if not doingTheSpecialStage then
		return
	end

	for player in players.iterate do
		if not player.mo or not player.mo.valid then
			return
		end

		local mo = player.mo
		local anchor = player.s2ss_anchor

		mo.angle = anchor.angle
	end
end

// Tails overlay thinker, for Tails' tails.
local function tailsOverlay(tails)
	// Check if Tails exists.
	if not tails.tracer or not tails.tracer.valid
	or not tails.tracer.player or not tails.tracer.player.valid then
		return
	end

	local mo = tails.tracer // Get Tails's mobj.

	tails.rollangle = mo.rollangle // Set our rollangle to Tails's rollangle.

	// ~ Fin ~
end

addHook("JumpSpecial", jumpSpecial)
addHook("AbilitySpecial", abilitySpecial)
addHook("MobjThinker", mobjThinker, MT_PLAYER)
addHook("ThinkFrame", thinkFrame)
addHook("MobjThinker", tailsOverlay, MT_TAILSOVERLAY)