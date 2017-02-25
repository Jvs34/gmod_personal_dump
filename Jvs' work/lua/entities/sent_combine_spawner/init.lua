
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )

/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()
	self.Entity:SetModel( "models/Items/combine_rifle_ammo01.mdl" )

	self.Entity:PhysicsInit( SOLID_VPHYSICS, "metal" )

	local phys = self.Entity:GetPhysicsObject()
	if (phys:IsValid()) then
		phys:Wake()
		phys:AddGameFlag( FVPHYSICS_NO_NPC_IMPACT_DMG );
		phys:AddGameFlag( FVPHYSICS_NO_IMPACT_DMG );
	end
	util.SpriteTrail( self.Entity,0,Color( 255, 0, 0, 255 ),true,4.0,0,2,1 / (4 * 0.5),"sprites/bluelaser1.vmt")//trails/laser.vmt
end


---------------------------------------------------------*/
function ENT:OnTakeDamage( dmginfo )

	
end

function ENT:Think( )
end

function ENT:OnRemove( )
end

function ENT:Use( Player )

end

function ENT:PhysicsCollide( data, physobj )
	self:SpawnCombine()
	self:Remove();
end

function ENT:SpawnCombine()
	local combine=ents.Create("npc_combine_s")
	combine:SetPos(self:GetPos()+Vector(0,0,10))
	if(self:GetOwner().CombineType==1)then
	combine:SetKeyValue("additionalequipment","ai_weapon_ar2") 
	combine:SetModel("models/combine_super_soldier.mdl")
	elseif(self:GetOwner().CombineType==2)then
		combine:SetKeyValue("additionalequipment","ai_weapon_smg1") 
		combine:SetModel("models/combine_soldier.mdl")
	elseif(self:GetOwner().CombineType==3)then
		combine:SetKeyValue("additionalequipment","ai_weapon_ar2") 
		combine:SetModel("models/combine_soldier_prisonguard.mdl")
	elseif(self:GetOwner().CombineType==4)then
		combine:SetKeyValue("additionalequipment","ai_weapon_shotgun") 
		combine:SetModel("models/combine_soldier.mdl")
		combine:SetSkin(1)
	end
	combine:Fire("setsquad","player_squad")
	combine:Spawn()
	combine:SetMaxHealth(combine:GetMaxHealth()*3)
	combine:SetHealth(combine:GetMaxHealth())
	combine:AddEntityRelationship(self:GetOwner(),D_LI,99)
	self:GetOwner().Combine=combine;
end