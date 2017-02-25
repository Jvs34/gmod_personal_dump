
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

ENT.Maxbounce=5;
ENT.BounceT=CurTime()+1;
ENT.BallLife=CurTime()+5;
ENT.Scale=1;
function ENT:SpawnFunction( ply, tr )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 32
	
	local ent = ents.Create( "sent_combine_ball" )
		ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	ent:SetOwner(ply);
	return ent
	
end


function ENT:Initialize()

	self.Entity:SetModel( "models/roller.mdl" )//"models/Effects/combineball.mdl"
	
	self.Entity:PhysicsInitSphere( 10*self.Scale, "metal_bouncy" )//Bounce,bounce,bounce,bounce,mushrooms,mushrooms!Oh wait...
	
	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake() //Hey,it's morning,wake up.
		phys:EnableGravity( false )//Disable gravy
		phys:AddGameFlag( FVPHYSICS_DMG_DISSOLVE );//Oh shit... [Barney quote]
		phys:SetMass(250)
	end
	self.HoldSound=false;
	self.BallLife=CurTime()+5;//Our ball is gonna die fast...
	self.NextFlyBy=CurTime()+2;//We don't want players to always listen to that flyby sound
	self.Entity:SetCollisionBounds( Vector( -10*self.Scale, -10*self.Scale, -10*self.Scale ), Vector( 10*self.Scale, 10*self.Scale, 10*self.Scale ) )
	util.SpriteTrail( self.Entity,0,Color( 215, 244, 23, 244 ),true,25.0,0,0.1,1,"sprites/combineball_trail_black_1.vmt")
	
end

function ENT:Think( )
	
	if(self.BallLife<=CurTime())then//You are dead,not big surprise
	self:Remove();
	end
	
		local entz=ents.FindInSphere(self:GetPos(), 100)
		for _,ent in pairs(entz) do
			if(ent:IsPlayer() && self.NextFlyBy<=CurTime() && self.HoldSound==false)then
			self:EmitSound("NPC_CombineBall.WhizFlyby");//Zing!The player just evitated the ball,woah.
			self.NextFlyBy=CurTime()+2
			end
		end
		
	if self:IsPlayerHolding() then
		if(self.HoldSound==false)then//the holding sound is not playing,do it!
		self:EmitSound("NPC_CombineBall.HoldingInPhysCannon")
		self.HoldSound=true;
		self:SetNWBool("pickedup",true);
		self.BallLife=CurTime()+5;//Reset the timer if someone picked it up,but only one time
		end
		self.Maxbounce=5;//always reset the bounce count if held.
		self:SetCollisionGroup(COLLISION_GROUP_WEAPON)//Don't kill anything beside props if you got picked up.
	else
		if(self.HoldSound==true)then
		self.BallLife=CurTime()+5 //the player released the ball,no matter what,reset the ball life and bounces.
		self.Maxbounce=5
		self:SetNWBool("pickedup",false);
		self:StopSound("NPC_CombineBall.HoldingInPhysCannon")
		self:SetCollisionGroup(COLLISION_GROUP_NONE) 
		self.HoldSound=false;//Ok,the holding sound stopped.
		end
		self:SetNWFloat("scale",self.Scale)
	end
				//Some addons Enables the gravity on some objects,we don't want gravity!
				local phys = self:GetPhysicsObject()
				if (phys:IsValid()) then
					phys:EnableGravity( false )
				end
self:NextThink(CurTime())//Our combine ball thinks fast chucklenut
return true
end

function ENT:PhysicsCollide( data, physobj )
	if (IsValid(data.HitEntity) && data.HitEntity:GetClass()=="phys_bone_follower") then
		local entz=ents.FindInSphere(self:GetPos(), 200)
		for _,ent in pairs(entz) do
			if(IsValid(ent) && ent:GetClass()=="npc_strider")then
				util.BlastDamage( self:GetOwner(), self:GetOwner(), ent:GetPos(), 5, 125)
				self:Remove();
			end
		end

	end
	
	if(self.Maxbounce == 0)then //we are out of bounces...
	self:Remove();				
	end
	if(self.HoldSound==false)then
		local effectdata = EffectData()
		effectdata:SetStart( self:GetPos() ) 
		effectdata:SetOrigin( self:GetPos())
		effectdata:SetScale(1)
		util.Effect( "cball_bounce", effectdata )
		
		self:EmitSound("NPC_CombineBall.Impact");
		if(self.BounceT<=CurTime())then //Ehi,calm down,you can't decrement the bounces too fast.
		self.Maxbounce = self.Maxbounce-1;
		self.BounceT=CurTime()+1;
		end
	util.ScreenShake( self:GetPos(), 20, 150, 1, 200 )//The combine ball it's.. heavy?
	physobj:SetVelocity( physobj:GetVelocity():Normalize() * 1782 * 0.9 )//Go faaast!
	end
	
end

function ENT:OnRemove()
			local effect = EffectData()
			effect:SetStart(self:GetPos())
			effect:SetOrigin(self:GetPos())
			effect:SetScale(1)
			util.Effect("cball_explode", effect)
			util.ScreenShake( self:GetPos(), 20, 150, 1, 1250 )
			self:EmitSound( "NPC_CombineBall.Explosion" )
			self:StopSound("NPC_CombineBall.HoldingInPhysCannon")//Stop the goddamn looping sound yet
end


