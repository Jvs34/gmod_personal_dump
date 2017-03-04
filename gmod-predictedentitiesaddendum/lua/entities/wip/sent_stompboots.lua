AddCSLuaFile()

DEFINE_BASECLASS( "base_predictedent" )

ENT.Spawnable = true
ENT.PrintName = "Stomping boots"
ENT.AttachesToPlayer = true

ENT.AttachmentInfo = {
	BoneName = "ValveBiped.Bip01_Spine",
	OffsetVec = Vector( 0 , 0 , 0 ),
	OffsetAng = Angle( 0 , 0 , 0 ),
}

if CLIENT then
	ENT.BootsAttachmentInfo = {
		
	}
end

function ENT:SpawnFunction( ply, tr, ClassName )

	if not tr.Hit then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 36

	local ent = ents.Create( ClassName )
	ent:SetPos( SpawnPos )
	ent:SetSlotName( ClassName )
	ent:Spawn()

	return ent

end

function ENT:Initialize()
	BaseClass.Initialize( self )
	if SERVER then
		self:SetModel( "models/Items/item_item_crate.mdl" )
		self:DrawShadow( false )
		self:InitPhysics()
	else
		
	end
end

function ENT:SetupDataTables()
	BaseClass.SetupDataTables( self )
end

function ENT:Think()
	if CLIENT then
		self:HandleBoots()
	end
	
	return BaseClass.Think( self )
end

if SERVER then

	function ENT:OnAttach( ply )
		
	end
	
	function ENT:OnDrop( ply )

	end

else
	function ENT:HandleBoots()
		if not IsValid( self.BootsModel ) then
			self.BootsModel = ClientsideModel( "models/props_junk/Shoe001a.mdl" )
			self.BootsModel:SetNoDraw( true )
		end
	end
	
	function ENT:Draw( flags )
		self:DrawModel()
		
		if self:IsCarried() then

		end
	end
end
