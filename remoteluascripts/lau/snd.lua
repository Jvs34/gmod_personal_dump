concommand.Add("gaysound", function(ply,command,args)
	if !IsValid(ply) || !args[1] then return end
	local volume=(tonumber(args[2])) and math.Clamp(tonumber(args[2]),50,500) or 100
	local pitch=(tonumber(args[3])) and math.Clamp(tonumber(args[3]),1,255) or 100
	if IsValid(ply.Ragdoll) then
		ply.Ragdoll:EmitSound(args[1],volume,pitch)
	else
		ply:EmitSound(args[1],volume,pitch)
	end
end)
