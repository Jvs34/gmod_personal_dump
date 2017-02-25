local enabled=false

if !enabled then return end





local meta = FindMetaTable( "Player" )
if (!meta) then return end

// In this file we're adding functions to the player meta table.
// This means you'll be able to call functions here straight from the player object
// You can even override already existing functions.

meta.g_CreateRagdoll		= meta.CreateRagdoll
meta.g_GetRagdollEntity		= meta.GetRagdollEntity
/*
function DoPlayerDeath(pl, attacker, dmgInfo)
	
	pl:Flashlight(false)
	pl:AddDeaths(1)
end
hook.Add("DoPlayerDeath","DoPlayerDeath",DoPlayerDeath)
*/
function meta:CreateRagdoll()
		local Data	= {}
		Data.Model	= self:GetModel()
		Data.Pos	= self:GetPos()
		Data.Angle	= self:GetAngles()
		Data.Skin	= self:GetSkin()

		local r,
			  g,
			  b,
			  a   = self:GetColor()
		local mat = self:GetMaterial()

		local ragdoll = ents.Create( "prop_ragdoll" )

		duplicator.DoGeneric( ragdoll, Data )
		ragdoll:SetColor( r, g, b, a )
		ragdoll:SetMaterial( mat )
		ragdoll:Spawn()
	
		local vel = self:GetVelocity()

		for i = 1, ragdoll:GetPhysicsObjectCount() do

			local phys = ragdoll:GetPhysicsObjectNum( i )

			if ( phys && phys:IsValid() ) then

				local pos, ang = self:GetBonePosition( ragdoll:TranslatePhysBoneToBone( i ) )

				phys:SetPos( pos )
				phys:SetAngle( ang )

				phys:AddVelocity( vel )

			end

		end

		self:SetNetworkedEntity( "GetRagdollEntity", ragdoll )
		self.m_hRagdollEntity = ragdoll
		if(!self:Alive())then
		self:SpectateEntity( ragdoll )
		self:Spectate( OBS_MODE_CHASE )
		end
		if ( self:IsOnFire() ) then

			ragdoll:Ignite( math.Rand( ( 15 - 5 ), ( 15 + 5 ) ) )

		end
		
		if(self:GetActiveWeapon()!= NULL)then
			local hand=ragdoll:LookupBone("ValveBiped.Bip01_R_Hand");
			local phys = ragdoll:GetPhysicsObjectNum( hand )

			local pos,ang=ragdoll:GetBonePosition(hand)
			
			local wep=ents.Create(self:GetActiveWeapon():GetClass())
			wep:SetPos(pos)
			wep:SetAngles(ang)
			wep:Spawn()
			constraint.Weld(wep,ragdoll,0,phys,0,true)
			/*local WeaponAP=self:GetActiveWeapon():LookupBone("ValveBiped.Bip01_R_Hand");
			local WeaponAPPos,WeaponAPAng=self:GetActiveWeapon():GetBonePosition(WeaponAP);
			local pp,aa=WeaponAPPos*1,WeaponAPAng*1;
			*/
		end
end

function meta:GetRagdollEntity()

		
		return self:GetNetworkedEntity( "GetRagdollEntity" )

end




local function PlayerDeathThink( Player )

	if ( Player:IsOnFire() ) then

		Player:Extinguish()

	end

end

hook.Add( "PlayerDeathThink", "PlayerDeathThink", PlayerDeathThink )
