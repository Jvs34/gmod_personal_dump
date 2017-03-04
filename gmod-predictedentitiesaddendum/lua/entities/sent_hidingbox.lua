AddCSLuaFile()

DEFINE_BASECLASS( "base_predictedent" )

ENT.Spawnable = true
ENT.PrintName = "Hiding box"
ENT.AttachesToPlayer = true

if CLIENT then
	ENT.ClipPlane = {
		Pos = Vector( 0 , 0 , -18 ),
		Ang = Angle( -90 , 0 , 0 )
	}
	
	ENT.AttachmentInfoFirstPerson = {
		Pos = Vector( 0 , 0 , -10 ),
		Ang = angle_zero
	}
end

function ENT:SpawnFunction( ply, tr, ClassName )

	if not tr.Hit then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 36

	local ent = ents.Create( ClassName )
	ent:SetSlotName( ClassName )	--this is the best place to set the slot, don't modify it dynamically ingame
	ent:SetPos( SpawnPos )
	ent:SetAngles( angle_zero )
	ent:Spawn()
	return ent

end

function ENT:Initialize()
	BaseClass.Initialize( self )
	if SERVER then
		self:SetModel( "models/props_junk/wood_crate001a_damaged.mdl" )
		self:PrecacheGibs()
		self:SetSkin( 1 )
		self:SetMaxHealth( 40 )
		self:SetHealth( self:GetMaxHealth() )
		
		self:InitPhysics()
	end
	
end

function ENT:SetupDataTables()
	BaseClass.SetupDataTables( self )
	self:DefineNWVar( "Angle" , "CurrentAngle" )
end

function ENT:Think()
	
	return BaseClass.Think( self )
end

if SERVER then
	
	function ENT:OnAttach( ply )
		self:SetSolid( SOLID_BBOX )
	end
	
	function ENT:OnDrop( ply )

	end
	
	function ENT:OnTakeDamage( dmginfo )
		--we're already dead , might happen if multiple jetpacks explode at the same time
		if self:Health() <= 0 then
			return
		end
		
		self:TakePhysicsDamage( dmginfo )
		
		local oldhealth = self:Health()
		
		local newhealth = math.Clamp( self:Health() - dmginfo:GetDamage() , 0 , self:GetMaxHealth() )
		self:SetHealth( newhealth )
		
		if self:Health() <= 0 then
			--maybe something is relaying damage to the jetpack instead, an explosion maybe?
			if IsValid( self:GetControllingPlayer() ) then
				self:Drop( true )
			end
			self:BreakBox( dmginfo:GetDamageForce() )
			return
		end

	end
	
	function ENT:PhysicsCollide( data , physobj )
		--taken straight from valve's code, it's needed since garry overwrote VPhysicsCollision, friction sound is still there though
		--because he didn't override the VPhysicsFriction
		if data.DeltaTime >= 0.05 and data.Speed >= 70 then
			local volume = data.Speed * data.Speed * ( 1 / ( 320 * 320 ) )
			if volume > 1 then
				volume = 1
			end
			
			--TODO: find a better impact sound for this model
			self:EmitSound( "Wood_Crate.ImpactHard" , nil , nil , volume , CHAN_BODY )
		end		
		
	end
	
	function ENT:BreakBox( force )
		self:EmitSound( "Wood_Crate.Break" )
		self:GibBreakClient( force )
		self:Remove()
	end
else
	function ENT:DrawFirstPerson( ply )
		--we'll do manual alignment here, GetCustomParentOrigin is mainly for thirdperson stuff
		local pos = ply:EyePos()
		local ang = ply:EyeAngles()
		
		pos , _ = LocalToWorld( self.AttachmentInfoFirstPerson.Pos , self.AttachmentInfoFirstPerson.Ang , pos , angle_zero )
		
		ang.p = 0
		
		self:SetPos( pos )
		self:SetAngles( ang )
		self:SetupBones()
		render.SetBlend( 0.75 )
		self:DrawModel()
		render.SetBlend( 1 )
		
	end
	
	function ENT:Draw( flags )
		local pos , ang = self:GetCustomParentOrigin()
		
		--even though the calcabsoluteposition hook should already prevent this, it doesn't on other players
		--might as well not give it the benefit of the doubt in the first place
		if pos and ang then
			self:SetPos( pos )
			self:SetAngles( ang )
			self:SetupBones()	--seems to be needed since we're never technically drawing the model
		end
		
		--remove the bottom of the crate by using a clip plane
		pos, ang = LocalToWorld( self.ClipPlane.Pos, self.ClipPlane.Ang, self:GetPos(), self:GetAngles())
		local dir = ang:Forward()

		local oldclipping = render.EnableClipping( true )
		render.PushCustomClipPlane( dir, dir:Dot( pos ) )
			self:DrawModel()
		render.PopCustomClipPlane()
		render.EnableClipping( oldclipping )
	end
end

function ENT:PredictedSetupMove( owner , data )
	
	if SERVER and data:KeyPressed( IN_JUMP ) then
		self:Drop( true )
	end
	
	data:SetButtons( bit.band( data:GetButtons() , bit.bnot( IN_JUMP ) ) )
	
end

function ENT:HandleMainActivityOverride( ply , velocity )
	local idealact = ACT_INVALID

	if ply:Crouching() then
		idealact = ACT_HL2MP_WALK_CROUCH
	else	
		idealact = ACT_HL2MP_RUN
	end
	
	return idealact , ACT_INVALID
end

function ENT:HandleUpdateAnimationOverride( ply , velocity , maxseqgroundspeed )
	if not IsValid( ply:GetGroundEntity() ) then
		ply:SetPlaybackRate( 0 )
	end
end

--we override this function as we need to set our position a bit more dynamically

function ENT:GetCustomParentOrigin()
	local ply = self:GetControllingPlayer()
	
	if not self:IsCarriedBy( ply ) then
		return
	end
	
	if CLIENT and self:IsCarriedByLocalPlayer( true ) and not self:ShouldDrawLocalPlayer( true ) then
		return
	end
	
	
	return LocalToWorld( Vector( 10 , 0 , 0 ) , angle_zero , ply:EyePos() , ply:GetAngles() )
end

