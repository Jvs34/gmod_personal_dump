if not CLIENT then return end
hook.Add("UpdateAnimation","eyebrows",function( ply, velocity, maxseqgroundspeed )
	if ply:GetNWBool("EyeBrowsRaising",false) then
	
		local FlexNum = ply:GetFlexNum() - 1
		if ( FlexNum <= 0 ) then return end
		
		for i=0, FlexNum-1 do
		
			local Name = ply:GetFlexName( i )
			
			if Name == "left_outer_raiser" || Name == "left_inner_raiser" then
				ply:SetFlexWeight( i, math.Clamp( math.sin(CurTime()*30), 0, 4 ) )
			elseif Name == "right_outer_raiser"  || Name == "right_inner_raiser" then
				ply:SetFlexWeight( i, math.Clamp( math.cos(CurTime()*30), 0, 4 ) )
			end
			
			
			--[[
			if ( Name == "left_outer_raiser" || Name == "right_outer_raiser" || Name == "left_inner_raiser" || Name == "right_inner_raiser"  ) then
				ply:SetFlexWeight( i, math.Clamp( math.sin(CurTime()*30), 0, 3 ) )
			end
			]]
			
		end
	end
end)