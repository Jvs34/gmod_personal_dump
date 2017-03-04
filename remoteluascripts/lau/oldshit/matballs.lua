concommand.Add("matball", function(ply, command, arguments)
	if !IsValid(ply) || !arguments[1] then return end
	local ty=arguments[1];
	local can;
	local tr=ply:GetEyeTrace()
    can = ents.Create( "item_material_ball" )
	if !IsValid(can) then return end
	can.__drop_param=arguments[1]
    can:SetPos( tr.HitPos + tr.HitNormal * 36 )
    
    can:Spawn( )
	
end)
