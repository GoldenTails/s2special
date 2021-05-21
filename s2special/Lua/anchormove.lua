addHook("MobjThinker", function(mo)
	if mo.resultangle == nil then
		return
	end
	
	local difference = mo.angle - mo.resultangle
	
	if difference < 0 and mo.anglespeed then
		mo.angle = $ + mo.anglespeed
		
		local difference = mo.angle - mo.resultangle
		if difference > 0 then
			mo.angle = mo.resultangle
		end
	elseif difference > 0 and mo.anglespeed then
		mo.angle = $ - mo.anglespeed
		
		local difference = mo.angle - mo.resultangle
		if difference < 0 then
			mo.angle = mo.resultangle
		end
	else
		mo.angle = mo.resultangle
	end
end, MT_S2SSANCHOR)