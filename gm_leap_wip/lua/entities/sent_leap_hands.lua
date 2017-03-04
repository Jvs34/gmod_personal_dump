AddCSLuaFile()

ENT.Type             = "anim"
ENT.Base             = "base_anim"
ENT.RenderGroup     = RENDERGROUP_OPAQUE

--[[
ValveBiped.Bip01_Spine4
ValveBiped.Bip01_L_Clavicle
ValveBiped.Bip01_L_UpperArm
ValveBiped.Bip01_L_Forearm
ValveBiped.Bip01_L_Hand
ValveBiped.Bip01_L_Finger4
ValveBiped.Bip01_L_Finger41
ValveBiped.Bip01_L_Finger42
ValveBiped.Bip01_L_Finger3
ValveBiped.Bip01_L_Finger31
ValveBiped.Bip01_L_Finger32
ValveBiped.Bip01_L_Finger2
ValveBiped.Bip01_L_Finger21
ValveBiped.Bip01_L_Finger22
ValveBiped.Bip01_L_Finger1
ValveBiped.Bip01_L_Finger11
ValveBiped.Bip01_L_Finger12
ValveBiped.Bip01_L_Finger0
ValveBiped.Bip01_L_Finger01
ValveBiped.Bip01_L_Finger02
ValveBiped.Bip01_R_Clavicle
ValveBiped.Bip01_R_UpperArm
ValveBiped.Bip01_R_Forearm
ValveBiped.Bip01_R_Hand
ValveBiped.Bip01_R_Finger4
ValveBiped.Bip01_R_Finger41
ValveBiped.Bip01_R_Finger42
ValveBiped.Bip01_R_Finger3
ValveBiped.Bip01_R_Finger31
ValveBiped.Bip01_R_Finger32
ValveBiped.Bip01_R_Finger2
ValveBiped.Bip01_R_Finger21
ValveBiped.Bip01_R_Finger22
ValveBiped.Bip01_R_Finger1
ValveBiped.Bip01_R_Finger11
ValveBiped.Bip01_R_Finger12
ValveBiped.Bip01_R_Finger0
ValveBiped.Bip01_R_Finger01
ValveBiped.Bip01_R_Finger02
ValveBiped.Bip01_L_Ulna
ValveBiped.Bip01_R_Ulna
ValveBiped.Bip01_R_Wrist
ValveBiped.Bip01_L_Wrist


]]
function ENT:Initialize()
	if SERVER then
		--local plyhands = self:GetController():GetOwner():GetHands()
		local mdl = "models/weapons/c_arms_citizen.mdl"
		
		if IsValid( plyhands ) then
			mdl = plyhands:GetModel()
		end
		
		self:SetModel( mdl )
	else
		self:AddCallback("BuildBonePositions", 
		function( self , nbones )
			self:BuildHands( nbones )
		end)
	end
end

if CLIENT then
	function ENT:GetPlayerColor()
		if IsValid( self:GetController() ) then
			local ply = self:GetController():GetOwner()
			
			if IsValid( ply ) then
				return ply:GetPlayerColor()
			end
		end
	end
end

function ENT:SetupDataTables()
	self:NetworkVar( "Entity" , 0 , "Controller" )
end

function ENT:BuildHands( bonesnumber )
	local ctrl = self:GetController()
	
	for i = 0 , bonesnumber - 1 do
		local mybonename = self:GetBoneName( i )
		
		local mybm = self:GetBoneMatrix( i )
		if mybm then
			debugoverlay.Text( mybm:GetTranslation() , mybonename , 0.5 )
		end
	end
	
	if IsValid( ctrl ) then
		local ply = ctrl:GetOwner()
	
		for handid = HAND_LEFT , HAND_RIGHT do
			
			--let's hardcode this for now
			for i , v in pairs( self.SimplePhysicsTranslate ) do
				
				if v.IsHidden then
					local boneid = self:LookupBone( i )
				
					if boneid and boneid ~= -1 then
						local bm = self:GetBoneMatrix( boneid )
						if bm then
							bm:SetScale( Vector( 1 , 0.1 , 0.1 ) )
							self:SetBoneMatrix( boneid , bm )
						end
					end
				end
				
				local func = ctrl[ v.Getter ]
				
				if not func or handid ~= v.Arm then
					continue
				end
				
				local pos , ang = func( ctrl , handid )
				
				local arment = ctrl:GetArm( handid )
				
				--[[
				if not arment:GetIsHandValid() then
					continue
				end
				]]
				
				if not pos or not ang then
					continue
				end
				
				local boneid = self:LookupBone( i )
				
				if boneid and boneid ~= -1 then
					local bm = self:GetBoneMatrix( boneid )
					if bm then
	
							
						local originalpos = bm:GetTranslation()
						local originalang = bm:GetAngles()
						
						pos = originalpos
						ang = originalang
						
						--_ , ang = LocalToWorld( vector_origin , ang , originalpos , originalang )
						--[[
						if v.PosOffset and v.AngOffset then
							pos , ang = LocalToWorld( v.PosOffset, v.AngOffset , pos , ang )
						end
						]]
						
						
						bm:SetTranslation( pos )
						bm:SetAngles( ang )
						
						
						self:SetBoneMatrix( boneid , bm )
					end
				end
			end
			
			--[[
			local handent = ctrl:GetArm( i )
			
			if IsValid( handent ) then
				
				
			end
			]]
		
		end
	end
	
end

ENT.SimplePhysicsTranslate = {
--[[	
	["ValveBiped.Bip01_%s_Hand"] = {
	
	},
]]	
	["ValveBiped.Bip01_R_UpperArm"] = {
		IsHidden = true
	},
	
	["ValveBiped.Bip01_L_UpperArm"] = {
		IsHidden = true
	},
	["ValveBiped.Bip01_L_Forearm"] = {
		Arm = HAND_LEFT,
		Getter = "GetArmElbowPosAng",
		PosOffset = vector_origin,
		AngOffset = Angle( 0 , 0 , 0 ),
	},
	["ValveBiped.Bip01_L_Wrist"] = {
		Arm = HAND_LEFT,
		Getter = "GetArmWristPosAng",
		PosOffset = Vector( 0 , 0 , 0 ),
		AngOffset = Angle( 0 , 0 , 0 ),
	},
	["ValveBiped.Bip01_L_Hand"] = {
		Arm = HAND_LEFT,
		Getter = "GetArmWristPosAng",
	}
	
}

--[[
function ENT:SimplePhysicsBuild( bonesnumber )
	
	for i = 0 , 1 do
		
		local handent = self:GetController():GetSimpleEnt( i )
		
		if IsValid( handent ) then
			local forearm = string.format( "ValveBiped.Bip01_%s_Forearm" , SideTranslate[i] )
			
			local boneid = self:LookupBone( forearm )
			
			if boneid and boneid ~= -1 then
				local bm = self:GetBoneMatrix( boneid )
				if bm then
					bm:SetTranslation( bm:GetTranslation() + handent:GetArmPosition() )
					bm:SetAngles( handent:GetArmDirection():Angle() )
					self:SetBoneMatrix( boneid , bm )
				end
			end
			
			
		end
	
	end
	
end
]]

