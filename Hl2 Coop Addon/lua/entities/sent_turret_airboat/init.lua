
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')
ENT.Owner=nil;
ENT.RedDotLaser=nil;
/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()

	self.Entity:SetModel( "models/airboatgun.mdl" )
	self.Entity:PhysicsInit( SOLID_VPHYSICS ) 
	self.Entity:SetMoveType( MOVETYPE_NONE )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self:SetUseType( SIMPLE_USE );
	
	self.Entity:DrawShadow( false )
	self.Entity:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
	end
	self.Loop=false;
	self.Firing 	= false
	self.NextShot 	= 0
						self.RedDotLaser = ents.Create("env_sprite");
						self.RedDotLaser:SetPos( self:GetPos() );
						self.RedDotLaser:SetKeyValue( "renderfx", "14" )
						self.RedDotLaser:SetKeyValue( "model", "sprites/hud/v_crosshair1.vmt")
						self.RedDotLaser:SetKeyValue( "scale","0.5")
						self.RedDotLaser:SetKeyValue( "spawnflags","1")
						self.RedDotLaser:SetKeyValue( "angles","0 0 0")
						self.RedDotLaser:SetKeyValue( "rendermode","9")
						self.RedDotLaser:SetKeyValue( "renderamt","255")
						self.RedDotLaser:SetKeyValue( "rendercolor", "255 220 0" )				
						self.RedDotLaser:Spawn()

end

function ENT:FireShot()
	
	if ( self.NextShot > CurTime() ) then return end
	
	self.NextShot = CurTime() + 0.08
	
		self.Entity:EmitSound( "Airboat.FireGunHeavy" )
		self.Entity:EmitSound( "Airboat.FireGunRevDown" )
	
	local Attachment = self.Entity:GetAttachment( 1 )
	
	local shootOrigin = Attachment.Pos
	local shootAngles = self.Entity:GetAngles()
	local shootDir = shootAngles:Forward()
	
	local bullet = {}
		bullet.Num 			= 3
		bullet.Src 			= shootOrigin
		bullet.Dir 			= shootDir
		bullet.Spread 		= Vector(0.03,0.03,0.03)
		bullet.Tracer		= 1
		bullet.TracerName 	= "AirboatGunTracer"
		bullet.AmmoType = "AirboatGun"
		bullet.Force		= 30
		bullet.Damage		= 5
		bullet.Attacker 	= self.Owner	
	self.Entity:FireBullets( bullet )
	

	local effectdata = EffectData()
		effectdata:SetOrigin( shootOrigin )
		effectdata:SetAngle( shootAngles )
		effectdata:SetScale( 1 )
	util.Effect( "MuzzleEffect", effectdata )
	
end

function ENT:OnTakeDamage( dmginfo )
end

function ENT:Use( Player )
		
end

function ENT:Think()
	if(self.Owner)then
	local Dir = self.Owner:GetAimVector()
				Pos1 = self.Entity:GetPos()
				local trace = {}
				trace.start = Pos1 
				trace.endpos = trace.start + (Dir * 200)
				trace.filter = { self.Entity, self.Entity }
				local tr = util.TraceLine( trace )
				local hitpos = tr.HitPos
				self.RedDotLaser:SetPos( hitpos );	
				
		self:SetAngles( self.Owner:EyeAngles() );
		if(self.Owner:KeyDown( IN_ATTACK ))then 
		self:FireShot();
		end
	end
	self.Entity:NextThink(CurTime())
	return true
end
function ENT:OnRemove( )

	self.RedDotLaser:Remove();
end