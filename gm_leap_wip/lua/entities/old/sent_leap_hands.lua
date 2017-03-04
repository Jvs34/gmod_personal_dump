AddCSLuaFile()

ENT.Type             = "anim"
ENT.Base             = "base_anim"
ENT.RenderGroup     = RENDERGROUP_OPAQUE

function ENT:Initialize()
	if SERVER then
		local plyhands = self:GetOwner():GetHands()
		local mdl = "models/weapons/c_arms_citizen.mdl"
		
		if self:GetController():GetLeapPhysics() then
			self:SetModelScale( 25 * self:GetController():GetScale() , 0 )
		else
			self:SetModelScale( self:GetController():GetScale() , 0 )
		end
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

function ENT:BuildHands( bonesnumber )
	local ctrl = self:GetController()
	local ply = self:GetParent()
	
	if IsValid( ctrl ) and not ctrl:GetLeapPhysics() then
		self:SimplePhysicsBuild( bonesnumber )
		return
	end
	
	for i = 0 , bonesnumber - 1 do
		local mybonename = self:GetBoneName( i )
		
		local mybm = self:GetBoneMatrix( i )
		if mybm then
			debugoverlay.Text( mybm:GetTranslation() , mybonename , 0.5 )
		end
		
		--[[
		if not mybonename then
			continue
		end
		
		ply:SetupBones()
		
		local hisbone = ply:LookupBone( mybonename )
		
		if not hisbone then
			continue
		end
		
		local hisbm = ply:GetBoneMatrix( hisbone )
		
		self:SetBoneMatrix( i , hisbm )
		]]
	end
	
end

ENT.SimplePhysicsTranslate = {
	["ValveBiped.Bip01_%s_Hand"] = {
	
	},
	
	["ValveBiped.Bip01_%s_Forearm"] = {
	
	}
}

local SideTranslate = {
	[0] = "L",
	[1] = "R"	
}


function ENT:SimplePhysicsBuild( bonesnumber )
	
	for i = 0 , 1 do
		
		local handent = self:GetController():GetSimpleEnt( i )
		
		if IsValid( handent ) then
			local forearm = string.format( "ValveBiped.Bip01_%s_Forearm" , SideTranslate[i] )
			
			local boneid = self:LookupBone( forearm )
			
			if boneid and boneid ~= -1 then
				local bm = self:GetBoneMatrix( boneid )
				if bm then
					self:ManipulateBonePosition( boneid, handent:GetArmPosition() * 0.1 )
					self:ManipulateBoneAngles( boneid , handent:GetArmDirection():Angle() )
					--[[
					bm:SetTranslation( bm:GetTranslation() + handent:GetArmPosition() )
					bm:SetAngles( handent:GetArmDirection():Angle() )
					self:SetBoneMatrix( boneid , bm )
					]]
				end
			end
			
			
		end
	
	end
	
end

function ENT:SetupDataTables()
	self:NetworkVar( "Entity" , 0 , "Controller" )
end