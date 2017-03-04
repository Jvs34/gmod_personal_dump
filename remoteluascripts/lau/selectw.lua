hook.Add( "StartCommand" , "GAY" , function( ply, cmd )
	if IsValid( ply.SelectW ) and ply:GetActiveWeapon() ~= ply.SelectW then
		print( "SELECTING, IS PREDICTED "..tostring( IsFirstTimePredicted() ) )
		cmd:SelectWeapon( ply.SelectW )
	--	ply.SelectW = nil
	elseif IsValid( ply.SelectW ) and ply:GetActiveWeapon() == ply.SelectW then
		ply.SelectW = nil
	end
	
end)