concommand.Add("sprayshit", function(ply,command,args)
	if !IsValid(ply) then return end
	ply:AllowImmediateDecalPainting( true )
	ply:SprayDecal( Vector(1023.968750 -710.492676 -82.758057), Vector(1,0,0) )
end)
