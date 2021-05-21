local function doOnPipe(mo)
	local player = mo.player
	local anchor = player.s2ss_anchor
	local lookAngle = R_PointToAngle(mo.x, mo.y) // Get the angle that we're looking from.

	// Manually advance animation every 3 frames to produce a faster jog.
	if leveltime % 3 == 0 or mo.state ~= S_PLAY_WALK then
		mo.state = S_PLAY_WALK
	end

	local anglemom = player.s2ss_anglemom

	if AngleFixed(player.s2ss_angle) > 180*FRACUNIT then
		if player.cmd.sidemove ~= 0 then
			player.s2ss_anglemom = $ + FixedAngle(FRACUNIT * -player.cmd.sidemove / 50)

			player.s2ss_anglemom = limit(player.s2ss_anglemom, FixedAngle(-15*FRACUNIT), FixedAngle(15*FRACUNIT))

			player.s2ss_sticktime = TICRATE
		end
	end

	if player.cmd.sidemove == 0 then
		player.s2ss_anglemom = FixedMul($, 3 * FRACUNIT / 4)
	end

	if AngleFixed(player.s2ss_angle) >= 180*FRACUNIT and player.cmd.sidemove == 0 and not player.s2ss_sticktime then
		local angle = AngleFixed(player.s2ss_angle) - 180*FRACUNIT - 90*FRACUNIT
		player.s2ss_anglemom = $ - FixedAngle(FixedMul(angle, FRACUNIT/90))
	elseif AngleFixed(player.s2ss_angle) < 180*FRACUNIT then
		local angle = AngleFixed(player.s2ss_angle) - 90*FRACUNIT
		player.s2ss_anglemom = $ + FixedAngle(FixedMul(angle, FRACUNIT/90))
	end

	if player.s2ss_sticktime then
		player.s2ss_sticktime = $ - 1
	end

	player.s2ss_angle = $ + player.s2ss_anglemom

	P_TeleportMove(
		mo,
		anchor.x + FixedMul(radius, FixedMul(cos(anchor.angle + ANGLE_90), cos(player.s2ss_angle))),
		anchor.y + FixedMul(radius, FixedMul(sin(anchor.angle + ANGLE_90), cos(player.s2ss_angle))),
		anchor.z + FixedMul(sin(player.s2ss_angle), radius)
	)
	mo.momx, mo.momy, mo.momz = 0, 0, 0

	// Use stuff that's kinda similar to the stuff I did in sloperollangle :^)
	mo.rollangle = -FixedMul(player.s2ss_angle + ANGLE_90, cos(mo.angle - lookAngle))
	mo.rollangle = $ + FixedAngle(15*FRACUNIT/2)

	if AngleFixed(player.s2ss_angle) < 180*FRACUNIT
	and abs(player.s2ss_anglemom) < FixedAngle(FRACUNIT) then
		player.onGround = false

		player.s2ss_x = FixedMul(cos(player.s2ss_angle), radius)
		player.s2ss_y = FixedMul(sin(player.s2ss_angle), radius)

		player.s2ss_momx, player.s2ss_momy = 0, 0

		player.s2ss_anglemom = FixedAngle(0)
	end
end

rawset(_G, "s2ss_doOnPipe", doOnPipe)