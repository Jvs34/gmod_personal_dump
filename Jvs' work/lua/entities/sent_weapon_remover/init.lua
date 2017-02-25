AddCSLuaFile("cl_init.lua")
AddCSLuaFile("shared.lua")
include("shared.lua")
ENT.Abs=0;
function ENT:Initialize()
	util.PrecacheModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
	self.Entity:SetModel("models/Combine_Helicopter/helicopter_bomb01.mdl")
	self.Entity:PhysicsInit(SOLID_VPHYSICS)
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:SetCollisionGroup( COLLISION_GROUP_NONE );
	self.NextUse=CurTime();
end

function ENT:SpawnFunction( ply, tr )
if ( !tr.Hit ) then return end
	local SpawnPos = tr.HitPos + tr.HitNormal * 16
	SpawnPos.z = SpawnPos.z + 10
	local ent = ents.Create( "sent_weapon_remover" )
		ent:SetPos( SpawnPos )
		ent:Spawn()
		ent:Activate()
	return ent
end

function ENT:Use(ply)
	if(IsValid(ply) && self.NextUse <= CurTime())then
		self.NextUse = CurTime() + 1;
		if(self.Abs!=0)then
		ply:SetArmor(ply:Armor()+ (self.Abs));
		self:EmitSound("items/battery_pickup.wav")
		else
		self:EmitSound("NPC_AttackHelicopter.DropMine");
		end
		self:SetNetworkedInt("sb",0);
		self.Abs=0;
	end
end
function ENT:Think()
		local entz=ents.FindInSphere(self.Entity:GetPos(), 1000)
			for _,ent in pairs(entz) do
				if ent:IsWeapon() && self.Abs<=99 then
					local physobj=ent:GetPhysicsObject()
						if physobj:IsValid() then
							physobj:SetVelocity( (self.Entity:GetPos()-ent:GetPos()):Normalize()*600 )
						end
				end
			end
end
function ENT:PhysicsCollide( data, physobj )

	if(IsValid(data.HitEntity) and  data.HitEntity:IsWeapon()  )then
		if(self.Abs<= 99)then
			self:EmitSound("items/ammo_pickup.wav")
				if(data.HitEntity:Clip1()>0)then
					if(data.HitEntity:Clip1()+self.Abs >= 99)then
					self.Abs=100;
					else
					self.Abs=self.Abs+data.HitEntity:Clip1();
					end
				else
				self.Abs=self.Abs+1;
				end
			data.HitEntity:Remove();
			self:SetNetworkedInt("sb",self.Abs);
		else
			self:EmitSound("items/suitchargeno1.wav");
		end
	end
				
end