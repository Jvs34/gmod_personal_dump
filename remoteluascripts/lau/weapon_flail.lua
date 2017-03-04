local SWEP={}


SWEP.AutoSwitchTo        = true
SWEP.AutoSwitchFrom        = true
SWEP.Category                = "Jvs"
SWEP.Spawnable            = true
SWEP.AdminOnly        = true
SWEP.Base = "weapon_base"
SWEP.Author			= "Jvs"

SWEP.Spawnable			= true
SWEP.UseHands			= true

SWEP.ViewModel			= "models/weapons/c_crowbar.mdl"
SWEP.WorldModel			= "models/weapons/w_crowbar.mdl"

SWEP.ViewModelFOV		= 54
SWEP.Primary={}
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Automatic		= false
SWEP.Primary.Ammo			= "none"
SWEP.Secondary={}
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Automatic	= false
SWEP.Secondary.Ammo			= "none"

SWEP.Weight				= 5
SWEP.AutoSwitchTo		= false
SWEP.AutoSwitchFrom		= false

SWEP.PrintName			= "Flail"
SWEP.Slot				= 0
SWEP.SlotPos			= 5
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= true
SWEP.STATE_IDLE			= 1
SWEP.STATE_PULLBACK		= 2
SWEP.STATE_THROWING		= 3
SWEP.STATE_DRINKING		= 4





if CLIENT then


	multimodel.Register("wep_flail", {
		--[[
		{
					model = "models/weapons/w_slam.mdl",
					transform = {Vector(0,0,0), Angle(0,0,0), Vector(1,1,1)},
					color=Color(255,255,255,120),
		},
		]]
		{
		transform = {Vector(0,0,0), Angle(0,0,0), Vector(1,1,1)*0.8},
		children={
				{
					model = "models/hunter/tubes/tube1x1x4.mdl",
					transform = {Vector(0,0,0), Angle(-90,0,0), Vector(1,1,1)/20},
					material="models/shiny",
					color=Color(200,200,200)
				},
				{
					model = "models/props_phx/construct/metal_dome360.mdl",
					transform = {Vector(0,0,0), Angle(90,0,0), Vector(1,1,1)/40},
					material="models/shiny",
					color=Color(200,200,200)
				},
				
				{
					model = "models/props_wasteland/prison_lamp001c.mdl",
					transform = {Vector(-8,0,0), Angle(90,0,0), Vector(1,1,1)/10},
				},
				{
					model = "models/props_phx/construct/glass/glass_angle360.mdl",
					transform = {Vector(-9.3,0,0), Angle(-90,0,0), Vector(1,1,1)/42},
				},
				
				{
					model = "models/hunter/plates/plate1x1.mdl",
					transform = {Vector(-2,0,0), Angle(0,0,0), Vector(1.2,1.2,1.5)/20},
					material="models/shiny",
					color=Color(0,0,0)
				},
				{
					model = "models/hunter/plates/plate1x1.mdl",
					transform = {Vector(-2,0,0), Angle(0,0,90), Vector(1.2,1.2,1.5)/20},
					material="models/shiny",
					color=Color(0,0,0)
				},
				{
					model = "models/hunter/plates/plate1x1.mdl",
					transform = {Vector(-2,0,0), Angle(0,0,45), Vector(1.2,1.2,1.5)/20},
					material="models/shiny",
					color=Color(0,0,0)
				},
				{
					model = "models/hunter/plates/plate1x1.mdl",
					transform = {Vector(-2,0,0), Angle(0,0,-45), Vector(1.2,1.2,1.5)/20},
					material="models/shiny",
					color=Color(0,0,0)
				},
				{
					model = "models/Items/battery.mdl",
					transform = {Vector(-4,0,0.47), Angle(-90,0,0), Vector(1,1,1)/3},
				},
				{
					model = "models/Items/battery.mdl",
					transform = {Vector(-4,-0.47,0), Angle(0,-90,90), Vector(1,1,1)/3},
				},
				{
					model = "models/Items/battery.mdl",
					transform = {Vector(-4,0.47,0), Angle(180,-90,90), Vector(1,1,1)/3},
				},
				{
					model = "models/Items/battery.mdl",
					transform = {Vector(-4,0,-0.47), Angle(90,0,180), Vector(1,1,1)/3},
				},
				{
					outputname	= "lightpoint",
					transform = {Vector(-9.3,0,0),Angle(0,0,0),Vector(1,1,1)},
				}
			}
		}
	})

	SWEP.Offsets={
		view={
			bone="ValveBiped.Bip01_R_Hand",
			pos=Vector(2.7,-1.5,3),
			ang=Angle(-88,75,0),
		},
		world={
			bone="ValveBiped.Bip01_R_Hand",
			pos=Vector(2.6,-1.85,3),
			ang=Angle(-100,0,10),
		}
	}

	function SWEP:PreDrawViewModel( vm, wep, ply )
		if not IsValid(vm) then return end
		vm:SetMaterial( "engine/occlusionproxy" )

	end

	function SWEP:PostDrawViewModel( vm, wep, ply )
		if not IsValid(vm) then return end
		vm:SetMaterial()
		return true
	end
	
	function SWEP:ViewModelDrawn(vm)
        self:DrawEffects(true,vm)
    end
    

	
	function SWEP:DrawEffects(view_or_world,vm)
		if not IsValid(self.Owner) then return end
		local ent=(view_or_world) and vm or self.Owner
		if not self.Flail then 
			self.Flail=multimodel.CreateInstance("wep_flail")
		end
		local offsets=self.Offsets[(view_or_world) and "view" or "world"]
		
		if not ent:LookupBone(offsets.bone) then return end
		
		local bonematrix=ent:GetBoneMatrix(ent:LookupBone(offsets.bone))
		if not bonematrix then return end
		
		local pos,ang=LocalToWorld(offsets.pos,offsets.ang, bonematrix:GetTranslation(), bonematrix:GetAngles() )
		
		multimodel.Draw(self.Flail,self,{origin=pos,angles=ang})
		
	end
	
    function SWEP:DrawWorldModel()
        self:DrawEffects(false)
    end
end


function SWEP:Initialize()
	self:SetWeaponHoldType("melee")
end 

function SWEP:SetupDataTables()
	self:NetworkVar("Entity",0,"Flail")
end



function SWEP:Deploy()
	self:SendWeaponAnim(ACT_SLAM_TRIPMINE_DRAW)
	self:SetNextPrimaryFire(CurTime()+0.30)
	self:SetNextSecondaryFire(CurTime()+1)
	return true
end

function SWEP:Think()
	if not IsValid(self:GetFlail()) and SERVER then
		local flail=ents.Create("sent_flail")
		flail:SetOwner(self.Owner)
		flail:SetPos(self.Owner:GetShootPos())
		flail:Spawn()
		self:SetFlail(flail)
	end
	
	if IsValid(self:GetFlail()) then
		self:GetFlail():PhysWake()
		--constrain the ball to the imaginary chain
		local trace = {}
		trace.start = self.Owner:GetShootPos()
		trace.endpos = trace.start + (self.Owner:EyeAngles():Right() * 30)
		trace.filter = {self.Owner,self:GetFlail()}
		local tr=util.TraceLine( trace );
		
		debugoverlay.Line(self.Owner:GetShootPos(),tr.HitPos,0.1)
		debugoverlay.Line(tr.HitPos,self:GetFlail():GetPos(),0.1)
		
		local delta=FrameTime()
		local physobj=self:GetFlail():GetPhysicsObject()
		if IsValid(physobj) then
			
			if physobj:GetPos():Distance(tr.HitPos) > 300 then
				physobj:SetPos(tr.HitPos)
				physobj:SetVelocity(vector_origin)
			end
			
			local direction=(tr.HitPos-physobj:GetPos())
			
			if physobj:GetPos():Distance(tr.HitPos) > 50 then
				physobj:SetVelocityInstantaneous(direction*physobj:GetMass()*300*delta)
			end
		end
	end
end

function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime()+1)
	self:SetNextSecondaryFire(CurTime()+1)
end

function SWEP:SecondaryAttack()

end

function SWEP:OnRemove()
	if SERVER and IsValid(self:GetFlail()) then
		self:GetFlail():Remove()
	end
end




function SWEP:Holster()
    return true
end

function SWEP:OnDrop()

end

weapons.Register(SWEP,"weapon_flail",true)



local ClassName="sent_flail"
local ENT={}


ENT.Base             = "base_anim"

ENT.Editable			= false
ENT.Spawnable			= false
ENT.AdminOnly			= false
ENT.RenderGroup 		= RENDERGROUP_OPAQUE

function ENT:Initialize()
	if SERVER or (CLIENT and self:GetOwner()==LocalPlayer()) then 
		self:SetModel( "models/props_phx/misc/soccerball.mdl" )
		self:PhysicsInitSphere( 5 )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
	end
end

function ENT:PhysicsCollide( data, physobj )
	if ( data.Speed > 70 and data.DeltaTime > 0.1 ) then
		self:EmitSound("Grenade.StepRight")
	end
end


scripted_ents.Register(ENT,ClassName,true)
