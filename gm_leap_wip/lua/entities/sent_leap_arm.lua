--[[
	This represents an arm, along with a hand and fingers
]]
AddCSLuaFile()

ENT.Type             = "anim"
ENT.Base             = "base_anim"
ENT.RenderGroup     = RENDERGROUP_OPAQUE

function ENT:Initialize()
	if SERVER then
		self:SetSolid( SOLID_NONE )
		self:SetMoveType( MOVETYPE_NONE )
		self:DrawShadow( false )
	else
		--self:SetRenderBounds( self:GetMinSize() , self:GetMaxSize() )
	end
	self:SetCustomCollisionCheck( true )
end

function ENT:SetupDataTables()
	self:NetworkVar( "Entity" , 0 , "Controller" )
	self:NetworkVar( "Bool" , 0 , "IsLeft" )
	self:NetworkVar( "Bool" , 1 , "IsHandValid" )
	
	self:NetworkVar( "Float" , 0 , "Scale" )	
	self:NetworkVar( "Float" , 1 , "ArmWidth" )
	
	self:NetworkVar( "Vector" , 0 , "ArmPosition" )
	self:NetworkVar( "Angle" , 0 , "ArmDirection" )
	
	self:NetworkVar( "Vector" , 1 , "PalmPosition" )
	self:NetworkVar( "Angle" , 1 , "PalmDirection" )
	
	local dtvarinc = 2
	
	for i , v in pairs( leap.FingerToString ) do
		
		for j , k in pairs( leap.FingerBoneToString ) do
			--thumb has no metacarpal
			--[[
			if i == FINGER_TYPE_THUMB and j == BONE_TYPE_METACARPAL then
				continue
			end
			]]
			
			local posaccessor = "FingerBone"..v..k.."Position"
			local diraccessor = "FingerBone"..v..k.."Direction"
			local lenaccessor = "FingerBone"..v..k.."Length"
			--create the accessor
			
			self:NetworkVar( "Vector" , dtvarinc , posaccessor )
			self:NetworkVar( "Angle" , dtvarinc , diraccessor )
			self:NetworkVar( "Float" , dtvarinc , lenaccessor )

			dtvarinc = dtvarinc + 1
		end
		
	end
	
	self:NetworkVar( "Float" , dtvarinc , "GrabStrength" )
	self:NetworkVar( "Float" , dtvarinc + 1	, "PinchStrength" )
	
	self:NetworkVar( "Vector" , dtvarinc , "WristPosition" )
	self:NetworkVar( "Vector" , dtvarinc + 1 , "ElbowPosition" )
	
end

function ENT:SetFingerBonePosition( fingerindex , boneindex , pos )
	local fingername = leap.FingerToString[fingerindex]
	local bonename = leap.FingerBoneToString[boneindex]
	
	if not fingername or not bonename then
		return
	end
	
	local posaccessor = "FingerBone"..fingername..bonename.."Position"
	
	if self["Set"..posaccessor] then
		self["Set"..posaccessor]( self , pos )
	end
end

function ENT:GetFingerBonePosition( fingerindex , boneindex )
	local fingername = leap.FingerToString[fingerindex]
	local bonename = leap.FingerBoneToString[boneindex]
	
	if not fingername or not bonename then
		return
	end
	
	local posaccessor = "FingerBone"..fingername..bonename.."Position"
	
	if self["Get"..posaccessor] then
		return self["Get"..posaccessor]( self )
	end
end

function ENT:SetFingerBoneDirection( fingerindex , boneindex , ang )
	local fingername = leap.FingerToString[fingerindex]
	local bonename = leap.FingerBoneToString[boneindex]
	
	if not fingername or not bonename then
		return
	end
	
	local diraccessor = "FingerBone"..fingername..bonename.."Direction"
	
	if self["Set"..diraccessor] then
		self["Set"..diraccessor]( self , ang )
	end

end

function ENT:GetFingerBoneDirection( fingerindex , boneindex )
	local fingername = leap.FingerToString[fingerindex]
	local bonename = leap.FingerBoneToString[boneindex]
	
	if not fingername or not bonename then
		return
	end
	
	local diraccessor = "FingerBone"..fingername..bonename.."Direction"
	
	if self["Get"..diraccessor] then
		return self["Get"..diraccessor]( self )
	end
end

function ENT:SetFingerBoneLength( fingerindex , boneindex , length )
	local fingername = leap.FingerToString[fingerindex]
	local bonename = leap.FingerBoneToString[boneindex]
	
	if not fingername or not bonename then
		return
	end
	
	local lenaccessor = "FingerBone"..fingername..bonename.."Length"
	
	if self["Set"..lenaccessor] then
		self["Set"..lenaccessor]( self , length )
	end

end

function ENT:GetFingerBoneLength( fingerindex , boneindex )
	local fingername = leap.FingerToString[fingerindex]
	local bonename = leap.FingerBoneToString[boneindex]
	
	if not fingername or not bonename then
		return
	end
	
	local lenaccessor = "FingerBone"..fingername..bonename.."Length"
	
	if self["Get"..lenaccessor] then
		return self["Get"..lenaccessor]( self )
	end
end


function ENT:IsLeft()
	return self:GetIsLeft()
end

function ENT:IsRight()
	return not self:GetIsLeft()
end


if CLIENT then
	ENT.Mat = Material( "models/wireframe" )

	function ENT:Draw()
		if not self:GetIsHandValid() then
			return
		end
		
		render.SetMaterial( self.Mat )
	
		self:DrawArm()
		
		for i , v in pairs( leap.FingerToString ) do
			for j , k in pairs( leap.FingerBoneToString ) do
				self:DrawFinger( i , j )
			end
		end
		
	end
	
	function ENT:DrawArm()
		local armlength = ( self:GetElbowPosition() - self:GetWristPosition() ):Length()
		local armmin = Vector( armlength * 0.5 , self:GetArmWidth() * 0.5 , self:GetArmWidth() * 0.5 )
		local armmax = armmin * -1
		local armpos = self:GetArmPosition()
		local armang = self:GetArmDirection()
		
		armpos , armang = self:GetController():TranslateToPlayerPos( armpos * self:GetScale() , armang )
		
		render.DrawBox( armpos, armang, armmin * self:GetScale(), armmax * self:GetScale(), color_white, true )
	end
	
	function ENT:DrawFinger( fingerid , boneid )
		
		local bonepos = self:GetFingerBonePosition( fingerid , boneid )
		if not bonepos then
			return
		end
		
		local boneang = self:GetFingerBoneDirection( fingerid , boneid )
		local bonelen = self:GetFingerBoneLength( fingerid , boneid )
		
		local bonewidth = 10
		local bonemin = Vector( bonelen * 0.5 , bonewidth * 0.5 , bonewidth * 0.5 )
		local bonemax = bonemin * -1
		
		bonepos , boneang = self:GetController():TranslateToPlayerPos( bonepos * self:GetScale() , boneang )
		
		render.DrawBox( bonepos , boneang, bonemin * self:GetScale(), bonemax * self:GetScale(), color_white, true )
		--debugoverlay.BoxAngles( bone.BonePosition , Vector(bone.BoneLength * .5, bone.BoneWidth *.5, bone.BoneWidth*.5), Vector(-bone.BoneLength*.5, -bone.BoneWidth*.5, -bone.BoneWidth*.5), bone.BoneDirection:Angle() , 0.05 )

	end
end











