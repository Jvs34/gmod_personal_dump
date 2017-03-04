AddCSLuaFile()

DEFINE_BASECLASS( "base_predictedent" )

ENT.Spawnable = true
ENT.PrintName = "Mech legs"
ENT.AttachesToPlayer = true

if SERVER then
	ENT.ScaledBones = {
		"ValveBiped.Bip01_R_Thigh",
		"ValveBiped.Bip01_R_Calf",
		"ValveBiped.Bip01_R_Foot",
		"ValveBiped.Bip01_R_Toe0",
		
		"ValveBiped.Bip01_L_Thigh",
		"ValveBiped.Bip01_L_Calf",
		"ValveBiped.Bip01_L_Foot",
		"ValveBiped.Bip01_L_Toe0",
	}
	
	ENT.BoneScale = Vector( 1 , 1 , 1 )
end

ENT.AttachmentInfo = {
	BoneName = "ValveBiped.Bip01_Spine",
	OffsetVec = Vector( 0 , 0 , 0 ),
	OffsetAng = Angle( 0 , 0 , 0 ),
}

if CLIENT then
	local mechlegsscale = 4
	multimodel.Register("mechlegs", {
		transform = {Vector( 0,0,0),Angle(0,0,0),Vector(1,1,1) },

		--tighs
		{
			bone = "ValveBiped.Bip01_R_Thigh",
			transform = {Vector(16,0,0),Angle(0,0,-85),Vector(0.8,1,1)/mechlegsscale},
			children={
				{
					transform = {Vector(0,0,0),Angle(0,0,0),Vector(1,1,1)},
					model = "models/Mechanics/roboticslarge/b1.mdl",
				},

				{
					transform = {Vector(-17,0,0),Angle(0,0,0),Vector(1,1,1)},
					model = "models/Mechanics/roboticslarge/a1.mdl",
				},
				{
					transform = {Vector(-30,0,0),Angle(0,180,0),Vector(1,1,1)},
					model = "models/Mechanics/roboticslarge/b1.mdl",
				},
				{
					transform = {Vector(-35,-2,0),Angle(0,0,0),Vector(1.2,1,1)*2},
					model = "models/hunter/misc/sphere025x025.mdl",
				},
				--
			}
		},
		{
			bone = "ValveBiped.Bip01_L_Thigh",
			transform = {Vector(16,0,0),Angle(0,0,-95),Vector(0.8,1,1)/mechlegsscale},
			children={
				{
					transform = {Vector(0,0,0),Angle(0,0,180),Vector(1,1,1)},
					model = "models/Mechanics/roboticslarge/b1.mdl",
				},

				{
					transform = {Vector(-17,0,0),Angle(0,0,0),Vector(1,1,1)},
					model = "models/Mechanics/roboticslarge/a1.mdl",
				},
				{
					transform = {Vector(-30,0,0),Angle(0,180,180),Vector(1,1,1)},
					model = "models/Mechanics/roboticslarge/b1.mdl",
				},
				{
					transform = {Vector(-35,2,0),Angle(0,0,0),Vector(1.2,1,1)*2},
					model = "models/hunter/misc/sphere025x025.mdl",
				},
			}
		},
		
		--calfs
		{
			bone = "ValveBiped.Bip01_R_Calf",
			transform = {Vector(14,-0.5,0),Angle(0,0,-85),Vector(0.8,1,1)/mechlegsscale},
			children={
				{
					transform = {Vector(0,0,0),Angle(0,0,0),Vector(1,1,1)},
					model = "models/Mechanics/roboticslarge/b1.mdl",
				},
				{
					transform = {Vector(0,0,0),Angle(0,0,180),Vector(1,1,1)},
					model = "models/Mechanics/roboticslarge/b1.mdl",
				},

				{
					transform = {Vector(-17,0,0),Angle(0,0,0),Vector(1,1,1)},
					model = "models/Mechanics/roboticslarge/a1.mdl",
				},
				{
					transform = {Vector(-30,0,0),Angle(0,180,0),Vector(1,1,1)},
					model = "models/Mechanics/roboticslarge/b1.mdl",
				},
			}
		},
		{
			bone = "ValveBiped.Bip01_L_Calf",
			transform = {Vector(14,-0.5,0),Angle(0,0,-95),Vector(0.8,1,1)/mechlegsscale},
			children={
				{
					transform = {Vector(0,0,0),Angle(0,0,0),Vector(1,1,1)},
					model = "models/Mechanics/roboticslarge/b1.mdl",
				},
				{
					transform = {Vector(0,0,0),Angle(0,0,180),Vector(1,1,1)},
					model = "models/Mechanics/roboticslarge/b1.mdl",
				},

				{
					transform = {Vector(-17,0,0),Angle(0,0,0),Vector(1,1,1)},
					model = "models/Mechanics/roboticslarge/a1.mdl",
				},
				{
					transform = {Vector(-30,0,0),Angle(0,180,180),Vector(1,1,1)},
					model = "models/Mechanics/roboticslarge/b1.mdl",
				},
			}
		},
		
		--feet
		{
			transform = {Vector(3,-2,0),Angle(0,-32,90),Vector(1,1,1)/mechlegsscale},
			model = "models/Mechanics/robotics/foot.mdl",
			bone = "ValveBiped.Bip01_R_Foot",
		},
		{
			transform = {Vector(3,-2,0),Angle(-5,-32,90),Vector(1,1,1)/mechlegsscale},
			model = "models/Mechanics/robotics/foot.mdl",
			bone = "ValveBiped.Bip01_L_Foot",
		},
	})
end


function ENT:SpawnFunction( ply, tr, ClassName )

	if not tr.Hit then return end

	local SpawnPos = tr.HitPos + tr.HitNormal * 36

	local ent = ents.Create( ClassName )
	ent:SetSlotName( ClassName )
	ent:Spawn()
	if not ent:Attach( ply , true ) then
		ent:Remove()
		return nil
	end
	return ent

end

function ENT:Initialize()
	BaseClass.Initialize( self )
	if SERVER then
		self:DrawShadow( false )
		self:InitPhysics()
	else
		self.MechLegs = multimodel.CreateInstance( "mechlegs" )
	end
end

function ENT:SetupDataTables()
	BaseClass.SetupDataTables( self )
end

function ENT:Think()
	return BaseClass.Think( self )
end

if SERVER then

	function ENT:OnAttach( ply )
		self:ScalePlayerBones( ply )
	end
	
	function ENT:OnDrop( ply )
		if IsValid( ply ) then
			self:RestorePlayerBones( ply )
		end
	end
	
	function ENT:DoInitPhysics()
	
	end
	
	function ENT:DoRemovePhysics()
	
	end
	
	
	function ENT:ScalePlayerBones( ply )
		for i ,v in pairs( self.ScaledBones ) do
			local bone = ply:LookupBone( v )
			if bone and bone ~= -1 then
				ply:ManipulateBoneScale( bone , self.BoneScale )
			end
		end
	end
	
	function ENT:RestorePlayerBones( ply )
		for i ,v in pairs( self.ScaledBones ) do
			local bone = ply:LookupBone( v )
			if bone and bone ~= -1 then
				ply:ManipulateBoneScale( bone , Vector( 1 , 1 , 1 ) )
			end
		end
	end
else
	
	function ENT:Draw( flags )
		if self:IsCarried() then
			if self.MechLegs then 
				--multimodel.SetOutputTarget(self.Atch)
				multimodel.Draw( self.MechLegs , self:GetControllingPlayer() )
				multimodel.DoFrameAdvance( self.MechLegs , CurTime() , self:GetControllingPlayer() )
				--multimodel.SetOutputTarget(nil)
			end
		end
	end
end
