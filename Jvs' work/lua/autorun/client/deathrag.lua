function CalcViewFF(ply,pos,ang,fov)

	local rag = ply:GetRagdollEntity()
	if ValidEntity(rag) && !ply:Alive() then
		local att = rag:GetAttachment(rag:LookupAttachment("eyes"))
		return GAMEMODE:CalcView(ply,att.Pos,att.Ang,fov)
	end
	
	return GAMEMODE:CalcView(ply,pos,ang,fov)
end
hook.Add("CalcView","CalcViewFF",CalcViewFF);