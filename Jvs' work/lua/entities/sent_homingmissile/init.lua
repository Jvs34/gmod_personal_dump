
AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include('shared.lua')

ENT.Target = NULL
ENT.EntAngs = NULL
ENT.ArmDel = CurTime()
ENT.MissileSound = NULL
ENT.ExplosionDel = CurTime() + 1
ENT.ExplodeOnce = 0

	ENT.speed		= 2000
	ENT.damage		= 100
	ENT.radius		= 500
	ENT.physeffect	= 1000
	ENT.armtime		= 2
	ENT.homing		= 1
	ENT.angchange	= 20
	
ENT.MissileTime = CurTime() + 5	
ENT.UpdateLaserPosDel = CurTime()
ENT.LaserPos = NULL

function ENT:SpawnFunction( ply, tr )
--------Spawning the entity and getting some sounds i use.   
 	if ( !tr.Hit ) then return end 
 	 
 	local SpawnPos = tr.HitPos + tr.HitNormal * 10 
 	 
 	local ent = ents.Create( "sent_homingmissile" )
	ent:SetPos( SpawnPos ) 
 	ent:Spawn()
 	ent:Activate() 
 	ent.Owner = ply
	return ent 
 	 
end

function ENT:Initialize()

	self.Entity:SetModel("models/weapons/w_missile_launch.mdl")
	self.Entity:SetColor(255, 255, 255, 255)
	self.Entity:SetOwner(self.Owner)
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)

	self.Entity:SetSolid(SOLID_VPHYSICS)	
	self.Owner=nil;
	self.WasGrabbed=false;
    local phys = self.Entity:GetPhysicsObject()
	if(phys:IsValid()) then phys:Wake() end
	
	 	self.EntAngs = self.Entity:GetAngles()
		
		self.ArmDel = CurTime() + self.armtime
	util.SpriteTrail(self.Entity, 0, Color(200,200,200,255), false, 4, 0, 3, 1/(15+1)*0.5, "trails/smoke.vmt")
	
	self.MissileSound = CreateSound(self.Entity,"weapons/rpg/rocket1.wav")
	self.MissileSound:Play()
	self.Entity:SetCollisionGroup( 1 )	
	
	self.MissileTime = CurTime() + 5
end

-------------------------------------------PHYS COLLIDE
function ENT:PhysicsCollide( data, phys ) 
	ent = data.HitEntity
	
	if self.ExplodeOnce == 0 then
	self:Detonate();
	end
end

function ENT:OnTakeDamage(dmgi)
	if(self.WasGrabbed==false)then
	self.WasGrabbed=true;
	self:EmitSound("weapons/rpg/shotdown.wav")
	end
end

function ENT:Detonate()
		self.ExplodeOnce = 1
		local expl = ents.Create("env_explosion")
		expl:SetKeyValue("spawnflags",128)
		expl:SetPos(self.Entity:GetPos())
		expl:Spawn()
		expl:Fire("explode","",0)
		
			local FireExp = ents.Create("env_physexplosion")
			FireExp:SetPos(self.Entity:GetPos())
			FireExp:SetParent(self.Entity)
			FireExp:SetKeyValue("magnitude", 500)
			FireExp:SetKeyValue("radius", 200)
			FireExp:SetKeyValue("spawnflags", "1")
			FireExp:Spawn()
			FireExp:Fire("Explode", "", 0)
			FireExp:Fire("kill", "", 5)
			if(self.Owner && IsValid(self.Owner))then
			util.BlastDamage( self.Owner, self.Owner, self.Entity:GetPos(), 200, 200)
			else
			util.BlastDamage( self, self, self.Entity:GetPos(), 200, 200)
			end
			if(self.Owner:IsPlayer() && self.Owner:Alive() && self.Owner:GetActiveWeapon() != NULL)then
				if(self.Owner:GetWeapon("weapon_homingrpg")==self.Owner:GetActiveWeapon())then
				self.Owner:GetActiveWeapon():RocketDied();
				end
			end
			self.Entity:Remove()
end
-------------------------------------------PHYS UPDATE
function ENT:PhysicsUpdate( physics )
if self.WasGrabbed==false then
	if(self:IsPlayerHolding())then
	self.WasGrabbed=true;
	self:EmitSound("weapons/rpg/shotdown.wav")
	end
	
		local effectdata = EffectData()
		effectdata:SetOrigin( self.Entity:GetPos() )
		effectdata:SetAngle( self:GetAngles()*-1 )
		effectdata:SetScale( 1 )
		util.Effect( "MuzzleEffect", effectdata )
	
	if(IsValid(self.Laser))then
	phys = self.Entity:GetPhysicsObject()
	local veloc = phys:GetVelocity()
	

		if self.UpdateLaserPosDel < CurTime() then
			if(self.Laser:IsPlayer())then
			self.LaserPos = self.Laser:GetPos()+Vector(0,0,32);
			else
			self.LaserPos = self.Laser:GetPos();
			end
		self.UpdateLaserPosDel = CurTime() + 0.2
		end


					local AimVec = ( self.LaserPos - self.Entity:GetPos() ):Angle()
					local Dist = math.min(self.Entity:GetPos():Distance(self.LaserPos), 5000)
					local Dist = Dist / 5000
					local Mod = (1 - Dist) * self.angchange
					
					
					self.EntAngs.p = math.ApproachAngle( self.EntAngs.p, AimVec.p, 0.5 + Mod )
					self.EntAngs.r = math.ApproachAngle( self.EntAngs.r, AimVec.r, 0.5 + Mod )
					self.EntAngs.y = math.ApproachAngle( self.EntAngs.y, AimVec.y, 0.5 + Mod )
					self.Entity:SetAngles( self.EntAngs )

		phys:SetVelocity(veloc)
		phys:ApplyForceCenter(self.Entity:GetForward() * 40000 )
		end		
	end
end
-------------------------------------------THINK
function ENT:Think()

	if self.ExplosionDel < CurTime() then
		self.Entity:SetCollisionGroup( 3 )
	end
	
	
phys = self.Entity:GetPhysicsObject()
phys:Wake()
	
end

-------------------------------------------REMOVE

function ENT:OnRemove()

self.MissileSound:Stop()
end