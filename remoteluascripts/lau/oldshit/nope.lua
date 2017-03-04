concommand.Add("nop", function(ply)
	if !IsValid(ply) then return end
	ply:EmitSound("vo/engineer_no01.wav")
	
end)