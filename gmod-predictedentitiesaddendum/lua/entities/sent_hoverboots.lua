AddCSLuaFile()

DEFINE_BASECLASS( "base_predictedent" )

ENT.Spawnable = true
ENT.PrintName = "Hover boots"
ENT.AttachesToPlayer = true

ENT.AttachmentInfo = {
	BoneName = "ValveBiped.Bip01_Spine",
	OffsetVec = Vector( 0 , 0 , 0 ),
	OffsetAng = Angle( 0 , 0 , 0 ),
}

if CLIENT then
	local leftboot = {	
		bone = "ValveBiped.Bip01_L_Foot",
		transform = { Vector( 3 , -3 , -1.9 ), Angle( 0 , -30 , 90 ), Vector( 1 , 1.25 , 1 ) * 1.15 },
		children = {
			{
				transform = { Vector(0,0,0), Angle(0,0,0), Vector(1,1,1) },
				model = "models/props_junk/shoe001a.mdl",
				clipplanes = {
					{
						Vector( 0 , 0 , 1 ) , Vector( 0 , 0 , 0 ),
					}
				},
				material = Material( "models/shiny" ),
				color = Color( 0 , 133 , 163 , 255 ),
				children = {
					{
						model = "models/maxofs2d/thruster_projector.mdl",
						transform = { Vector( -3 , 1 , -2.5 ), Angle( 180 , 0 , 0 ), Vector( 1 , 1 , 1 ) * 0.2 },
						clipplanes = {
							{
								Vector( 0 , 0 , 1 ) , Vector( 0 , 0 , 90 ),
							}
						}
					},
					{
						model = "models/maxofs2d/thruster_projector.mdl",
						transform = { Vector( 3 , 1 , -2.5 ), Angle( 180 , 0 , 0 ), Vector( 1 , 1 , 1 ) * 0.2 },
						clipplanes = {
							{
								Vector( 0 , 0 , 1 ) , Vector( 0 , 0 , 90 ),
							}
						}
					},
				}
			},
		}
	}

	rightboot = multimodel.Copy( leftboot )
	rightboot.bone = "ValveBiped.Bip01_R_Foot"
	rightboot.transform[1].z = rightboot.transform[1].z * -1
	rightboot.transform[3].y = rightboot.transform[3].y * -1

	function RecursiveSetReverseCullNiceMeme( tab )
		if tab.model and not tab.reversecull then
			tab.reversecull = true
		end
		
		for i , v in pairs( tab ) do
			if type( v ) == "table" then
				RecursiveSetReverseCullNiceMeme( v )
			end
		end
	end

	RecursiveSetReverseCullNiceMeme( rightboot )
	
	local mmtab = {
		leftboot,
		rightboot,
	}

	multimodel.Register( "mm_hoverboots" , mmtab )
	
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
		self.BootsMultiModels = nil
	end
end

function ENT:SetupDataTables()
	BaseClass.SetupDataTables( self )
	self:DefineNWVar( "Bool" , "WasOnGround" )
	self:DefineNWVar( "Bool" , "WasSliding" )
end

function ENT:Think()
	if CLIENT then
		self:HandleBoots()
	end
	
	return BaseClass.Think( self )
end

function ENT:PredictedMove( ply , mv )
	local force

	if bit.band( mv:GetButtons(), IN_JUMP ) ~= 0 then
	
		if not self:GetWasSliding() and self:GetWasOnGround() then
			mv:SetVelocity( mv:GetVelocity() + Vector( 0, 0, 200 ) )
		end
		
		if ply:IsOnGround() then
			ply:SetGroundEntity( NULL )
		end
	
		self:SetWasSliding( true )
		force = true
	
	elseif self:GetWasSliding() then
		if ply:IsOnGround() then
			mv:SetVelocity( mv:GetVelocity() + Vector( 0, 0, 200 ) )
			ply:SetGroundEntity( NULL )
		end
		
		self:SetWasSliding( false )
		self:SetWasOnGround( true )
	end

	self:SetWasOnGround( force or ply:IsOnGround() )
end

function ENT:HandleMainActivityOverride( ply , velocity )
	if self:GetWasSliding() then
		local vel2d = velocity:Length2D()
		local idealact = ACT_MP_JUMP
		
		--[[
		if IsValid( ply:GetActiveWeapon() ) then
			idealact = ACT_MP_SWIM
		else
			idealact = ACT_HL2MP_IDLE + 9
		end
		]]
		
		return idealact , ACT_INVALID
	end
end

function ENT:HandleUpdateAnimationOverride( ply , velocity , maxseqgroundspeed )
	if self:GetWasSliding() then
		ply:SetPlaybackRate( 0 )
		ply:SetCycle( 0.15 )
		return true
	end
end


if SERVER then

	function ENT:OnAttach( ply )
		self:SetWasSliding( false )
		self:SetWasOnGround( true )
	end
	
	function ENT:OnDrop( ply )
		self:SetWasSliding( false )
		self:SetWasOnGround( true )
	end

else
	function ENT:HandleLoopingSounds()
		if not self.HoveringSound then
			self.HoveringSound = CreateSound( self , "k_lab.ringsrotating" )
		end
		
		if self:GetWasSliding() then
			self.HoveringSound:PlayEx( 0.1  , 150 )
		else
			self.HoveringSound:FadeOut( 0.1 )
		end
		
	end
	
	function ENT:HandleBoots()
		if not self.BootsMultiModels then
			self.BootsMultiModels = multimodel.CreateInstance( "mm_hoverboots" )
		end
	end
	
	function ENT:Draw( flags )
		--self:DrawModel()
		
		if self.BootsMultiModels then
			local tab = {
				origin = self:GetPos(),
				angles = self:GetAngles()
			}
			local ply = nil
			
			if self:IsCarried() then
				ply = self:GetControllingPlayer()
				
			end

			multimodel.Draw( self.BootsMultiModels , ply , tab )
			
		end
	end
end
