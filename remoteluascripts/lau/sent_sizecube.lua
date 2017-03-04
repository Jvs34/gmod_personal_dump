
AddCSLuaFile()

local ClassName="sent_sizecube"
local ENT={}

ENT.Base             = "base_anim"


ENT.PrintName		= "Variable Size Cube"
ENT.Author			= "Jvs"
ENT.Information		= "????"
ENT.Category		= "Jvs"

ENT.Editable			= true
ENT.Spawnable			= true
ENT.AdminOnly			= true
ENT.MaxSize	= 10
ENT.MinSize	= 0.25


function ENT:SpawnFunction( ply, tr, ClassName )

	if ( !tr.Hit ) then return end
	
	local SpawnPos = tr.HitPos + tr.HitNormal * 100
	
	local ent = ents.Create( ClassName )
	ent:SetPos( SpawnPos )
	ent:Spawn()
	ent:Activate()
	
	return ent
	
end





function ENT:SetupDataTables()

	--[[
	self:NetworkVar( "Vector", 0, "CubeSize")
	
	self:NetworkVarElement( "Vector", 0, 'x', "ScaleX", { KeyName = "scalex", Edit = { type = "Float", min = 0.5, max = self.MaxSize, category = "Scale", order = 1 } } )
	self:NetworkVarElement( "Vector", 0, 'y', "ScaleY", { KeyName = "scaley", Edit = { type = "Float", min = 0.5, max = self.MaxSize, category = "Scale", order = 2 } } )
	self:NetworkVarElement( "Vector", 0, 'z', "ScaleZ", { KeyName = "scalez", Edit = { type = "Float", min = 0.5, max = self.MaxSize, category = "Scale", order = 3 } } )
	]]
	
	self:NetworkVar( "Float", 0, "ScaleX", { KeyName = "scalex", Edit = { type = "Float", min = self.MinSize, max = self.MaxSize, category = "Scale", order = 1 } } )
	self:NetworkVar( "Float", 1, "ScaleY", { KeyName = "scaley", Edit = { type = "Float", min = self.MinSize, max = self.MaxSize, category = "Scale", order = 2 } } )
	self:NetworkVar( "Float", 2, "ScaleZ", { KeyName = "scalez", Edit = { type = "Float", min = self.MinSize, max = self.MaxSize, category = "Scale", order = 3 } } )
	
	self:NetworkVar( "Vector", 0, "Min")
	self:NetworkVar( "Vector", 1, "Max")
	
	self:NetworkVar( "String", 0, "BoxModel", { KeyName = "boxmodel", Edit = { type = "Generic", category = "Model", order = 4 } } )
	
end

function ENT:Initialize()

	if ( SERVER ) then
		
		--self:SetModel( "models/xqm/boxfull.mdl" )
		
		--self:SetModel( "models/props_junk/wood_crate002a.mdl" )
		
		self:SetUseType(SIMPLE_USE)
		self:NetworkVarNotify( "ScaleX", self.OnCubeSizeChanged )
		self:NetworkVarNotify( "ScaleY", self.OnCubeSizeChanged )
		self:NetworkVarNotify( "ScaleZ", self.OnCubeSizeChanged )
		self:NetworkVarNotify( "BoxModel", self.OnCubeModelChanged )
		
		
		self:SetBoxModel("models/xqm/boxfull.mdl")
		local mmin,mmax=self:GetModelBounds()
		self:SetMin(mmin)
		self:SetMax(mmax)
		--self:NetworkVarNotify( "CubeSize", self.OnCubeSizeChanged )

		
		self.SoundTime = CurTime()
		--self.SoftStrain = CreateSound( self, "Metal_Box.ScrapeSmooth" )
		--self.RoughStrain = CreateSound( self, "Metal_Box.ScrapeRough" )
		self.SoundWay = false
		
		self:SetCubeSize(Vector(1,1,1))
		self:EnableCustomCollisions()
		self:UpdateSize()
	
	else
		self:EnableCustomCollisions()
	end
	
end

function ENT:Draw()
	self:SetCollisionBounds(self:GetMin() * self:GetCubeSize() , self:GetMax() * self:GetCubeSize() )
	self:SetRenderBounds(self:GetMin() * self:GetCubeSize() , self:GetMax() * self:GetCubeSize())
	local mat = Matrix()
	mat:Scale( self:GetCubeSize() )
	
	
	self:EnableMatrix( "RenderMultiply",mat)
	self:DrawModel()
	
end

function ENT:SetCubeSize(vec)
	vec.x=math.Clamp(vec.x,self.MinSize,self.MaxSize)
	vec.y=math.Clamp(vec.y,self.MinSize,self.MaxSize)
	vec.z=math.Clamp(vec.z,self.MinSize,self.MaxSize)
	
	self:SetScaleX(vec.x)
	self:SetScaleY(vec.y)
	self:SetScaleZ(vec.z)
end

function ENT:GetCubeSize(vec)
	return Vector(self:GetScaleX(),self:GetScaleY(),self:GetScaleZ())
end

function ENT:OnCubeModelChanged( varname, oldvalue, newvalue )
	if oldvalue==newvalue then return end
	if not util.IsValidModel(newvalue) then 
		self:SetBoxModel("models/xqm/boxfull.mdl")
		return 
	end
	
	self:SetModel(newvalue)
	local mmin,mmax=self:GetModelBounds()
	self:SetMin(mmin)
	self:SetMax(mmax)
	self:UpdateSize()
end

function ENT:OnCubeSizeChanged( varname, oldvalue, newvalue )
	if newvalue == oldvalue then return end
	
	self:UpdateSize()
	
	self.SoundWay = newvalue > oldvalue
	self.SoundTime = CurTime() + 0.5
	--self:EmitSound("Metal_Box.Strain")
end

function ENT:UpdateSize()
	local velocity
	local ang
	local pos
	local motion
	local angvel
	local oldphysobj=false
	
	local phys = self:GetPhysicsObject()
	
	if IsValid(phys) then
		velocity=phys:GetVelocity()
		ang=phys:GetAngles()
		pos=phys:GetPos()
		oldphysobj=true
		motion = phys:IsMotionEnabled()
		angvel=phys:GetAngleVelocity()
	end
	
	self:EnableCustomCollisions(true)
	self:SetSolid( SOLID_BBOX )
	self:PhysicsInitBox( self:GetMin() * self:GetCubeSize() , self:GetMax() * self:GetCubeSize() )
	self:SetCollisionBounds( self:GetMin() * self:GetCubeSize() , self:GetMax() * self:GetCubeSize() )
	phys = self:GetPhysicsObject()
	if IsValid(phys) then
		local mass=(self:GetCubeSize().x + self:GetCubeSize().y + self:GetCubeSize().x)/3
		phys:SetMass(50*mass)
		phys:SetMaterial("metal")
		if oldphysobj then
			phys:SetPos(pos)
			phys:SetVelocity(velocity)
			phys:SetAngles(ang)
			phys:EnableMotion(motion)
			phys:AddAngleVelocity(angvel)
		end
	end
end

function ENT:OnTakeDamage(dmginfo)
	self:TakePhysicsDamage(dmginfo)
	--self:SetCubeSize(self:GetCubeSize()*0.99)
	
end
--[[
function ENT:TestCollision( startpos, delta, isbox, extents )
	--I'll make use of this, uh, eventually
	--this pretty much helps you filter traces that should supposedly hit you, but it doesn't give THAT much information from the arguments, so whatever
	local hit, norm, fraction = util.IntersectRayWithOBB( startpos, delta, self:GetPos(), self:GetAngles(), self:GetMin() * self:GetCubeSize() , self:GetMax() * self:GetCubeSize() )
	if ( !hit ) then return end
	
	debugoverlay.BoxAngles( self:GetPos(), self:GetMin() * self:GetCubeSize() , self:GetMax() * self:GetCubeSize(), self:GetAngles(), 0.5, Color( 255, 255, 0, 100 ) )
	
	return 
	{ 
		HitPos		= hit,
		Fraction	= fraction
	}
end
]]

function ENT:Think()
	if SERVER then
		--[[
		if self.SoundTime > CurTime() then
			if self.SoundWay then
				self.SoftStrain:PlayEx(1,200)
				
				self.RoughStrain:Stop()
			else
				self.SoftStrain:Stop()
				self.RoughStrain:PlayEx(1,80)
			end
		else
			self.SoftStrain:Stop()
			self.RoughStrain:Stop()
		
		end
		]]
	end
end

function ENT:OnRemove()
	if self.SoftStrain then
		self.SoftStrain:Stop()
	
	end
	if self.RoughStrain then
		self.RoughStrain:Stop()
	end
end


scripted_ents.Register(ENT,ClassName,true)
