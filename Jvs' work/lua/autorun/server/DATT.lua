function playerforcerespawn( ply )
 
    if !IsValid(ply:GetRagdollEntity()) then             
		ply:Spawn()        
    else
		ply:SetPos(ply:GetRagdollEntity():GetPos())
		
	end
	
	
 
end
 
hook.Add( "PlayerDeathThink", "player_step_forcespawn", playerforcerespawn );
	

 
function OverrideDeathSound()
	return true
end
hook.Add("PlayerDeathSound", "OverrideDeathSound", OverrideDeathSound)