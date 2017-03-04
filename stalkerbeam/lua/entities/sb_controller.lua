AddCSLuaFile()

ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.Type             = "anim"
ENT.Base             = "base_anim"
ENT.PrintName        = "Effect Controller"
ENT.Author            = "Jvs"
ENT.Information        = "You shouldn't even being able to spawn this"
ENT.Category        = "Other"
ENT.Spawnable            = false
ENT.AdminSpawnable        = false

if CLIENT then
	function ENT:Draw()
	
	end
end

function ENT:Initialize()
	self:SetModel( "models/Combine_Helicopter/helicopter_bomb01.mdl" )
	if CLIENT then
		self:SetRenderBounds(self:GetOwner():GetRenderBounds())
		self.WallSound = CreateSound( self, "NPC_Stalker.BurnWall" )
		self.FleshSound = CreateSound( self, "NPC_Stalker.BurnFlesh" )
	else
		self:SetActive( false )
	end
	
	self:DrawShadow( false )
	
end

function ENT:SetupDataTables()
	self:NetworkVar( "Bool", 0 , "Active" )
	self:NetworkVar( "Int" , 0 , "SoundMode" )
	self:NetworkVar( "Float" , 0 , "Pitch" )
end

function ENT:Think()
	if SERVER then
		if not IsValid( self:GetOwner() ) then
			self:Remove()
		end
	else
		if not self:GetActive() then
			if self.WallSound then
				self.WallSound:Stop()
			end
			
			if self.FleshSound then
				self.FleshSound:Stop()
			end
		else
			
			if self:GetSoundMode() == 2 then
				self.WallSound:Stop()
				self.FleshSound:Play()
				self.FleshSound:ChangePitch( self:GetPitch() )
			else
				self.FleshSound:Stop()
				self.WallSound:Play()
				self.WallSound:ChangePitch( self:GetPitch() )
			end
		end
		
	end
end

function ENT:OnRemove()
	if CLIENT then
		if self.WallSound then
			self.WallSound:Stop()
		end
		
		if self.FleshSound then
			self.FleshSound:Stop()
		end
	end
end