if SERVER then
	concommand.Add("nopestep", function(ply,command,args)
		if !IsValid(ply) then return end
		local nope=ply:GetNetworkedBool("nopestep",false)
		ply:SetNetworkedBool("nopestep",!nope)
	end)
end

hook.Add("PlayerFootstep","NopeStep",function(ply, pos, foot, sound, volume, rf )
	if ply:GetNetworkedBool("nopestep",false) then
		ply:EmitSound("vo/engineer_no01.wav",70,foot and 100 or 95)
		return true
	end
end)