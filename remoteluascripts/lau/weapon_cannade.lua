local SWEP={}



SWEP.AutoSwitchTo        = true
SWEP.AutoSwitchFrom        = true
SWEP.Category                = "Jvs"
SWEP.Spawnable            = true
SWEP.AdminOnly        = true
SWEP.Base = "weapon_base"


if ( CLIENT ) then

    
    local EFFECT={}
    
    function EFFECT:Init( data )
        self.Position = data:GetOrigin()    
        self.Speed = data:GetStart()
        self.Size = data:GetScale()
        local emitter = ParticleEmitter( self.Position )
            for i=1, 200 do    
                local particle = emitter:Add( "particle/particle_noisesphere", self.Position )
                    particle:SetVelocity( Vector(math.Rand(-100,100),math.Rand(-100,100),math.Rand(-100,100))+(self.Speed*self.Size*4) )
                    particle:SetDieTime(1)
                    particle:SetStartAlpha(200)
                    particle:SetEndAlpha(0)
                    particle:SetStartSize(math.random(self.Size,10+self.Size))
                    particle:SetEndSize( 0 )
                    particle:SetRoll( math.Rand( -10,10  ) )
                    particle:SetRollDelta(math.Rand( -0.2, 0.2 ))
					local cola=196	--/3
					local colb=255	--/3
					local colr=255	--/3
					particle:SetColor( cola, colb, colr)            
                    particle:SetGravity( Vector( 0, 0, -15*i ) )
                    particle:SetCollide( true )
                    particle:SetBounce( 0.2 )
            end            
        emitter:Finish()
    end
    function EFFECT:Think()return false end
    function EFFECT:Render() end
    effects.Register(EFFECT,"SodaCan_Explode")


end


local ENT={}
ENT.RenderGroup = RENDERGROUP_TRANSLUCENT
ENT.Type             = "anim"
ENT.Base             = "base_anim"
ENT.PrintName        = "Cannade"
ENT.Author            = "Jvs"
ENT.Information        = ""
ENT.Category        = "Other"
ENT.IsCan=true
ENT.Spawnable            = false
ENT.AdminOnly        = false
ENT.Pressure=0
ENT.Detonated=false
ENT.HarmlessMode=false
function ENT:Initialize()
    if(SERVER)then
    self:SetModel( "models/props_junk/PopCan01a.mdl" )
    self:SetMoveType( MOVETYPE_VPHYSICS )
    self:PhysicsInit( SOLID_VPHYSICS )
    self:GetPhysicsObject():AddGameFlag( FVPHYSICS_NO_NPC_IMPACT_DMG )
    self:GetPhysicsObject():AddGameFlag( FVPHYSICS_NO_IMPACT_DMG )
    self:GetPhysicsObject():SetMaterial("popcan")
    self:PhysWake()
    self.GrenadeTimer=CurTime()+3
    end
end

function SWEP:FireAnimationEvent(pos, ang, event, options)
	print(event,options)
end

function ENT:Draw()
    self:DrawModel()
end

function ENT:Think()
    if CLIENT then return end
    if self.GrenadeTimer < CurTime() and not self.Detonated then
        self:Detonate()
    end
end

function ENT:SetPressure(val)
    self.Pressure=val
end

function ENT:OnTakeDamage(dmgfo)
    if not self.Detonated then
        self:Detonate()
    end
end

function ENT:Detonate(data)
    if self.Detonated then return end
    self.Detonated=true
    if not self.HarmlessMode then
	self:EmitSound("Weapon_AR2.NPC_Double")
    end
	self:EmitSound("ambient/water/water_splash1.wav",75,100)
    local dmg=Lerp(self.Pressure/100,10,150)
    local shake=Lerp(self.Pressure/100,1,25)
    
	if not self.HarmlessMode then
		util.BlastDamage( self,self:GetOwner(),self:GetPos(),150,dmg )
	end
	
	local speed = self:GetPhysicsObject():GetVelocity()
	if not self.HarmlessMode then
		util.ScreenShake( self:GetPos(), shake, 150.0, 1.0, 350 )
    end
	local effectdata = EffectData()
    effectdata:SetScale(self.Pressure/10)
    effectdata:SetOrigin( self:GetPos()+(self:GetUp())*7 )
    if data then
    effectdata:SetStart(data.HitNormal*-1 )
    else
    effectdata:SetStart(speed:GetNormal() )
    end
    util.Effect( "SodaCan_Explode", effectdata )
    if data then
        local Pos1 = data.HitPos + data.HitNormal
        local Pos2 = data.HitPos - data.HitNormal
        util.Decal("beersplash",Pos1,Pos2)
    end    
    self:Remove()
end

function ENT:PhysicsCollide( data, physobj )
    local speedrequired=Lerp(self.Pressure/100,1000,200)
    if data.OurOldVelocity:Length()>speedrequired and not self.Detonated then
        self:Detonate(data)
    end
end
scripted_ents.Register(ENT,"can_nade_nade",true)

 
SWEP.Author			= "Jvs"

SWEP.Spawnable			= true
SWEP.UseHands			= true

SWEP.ViewModel			= "models/weapons/c_grenade.mdl"
SWEP.WorldModel			= "models/props_junk/PopCan01a.mdl"

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

SWEP.PrintName			= "Can-nade"
SWEP.Slot				= 0
SWEP.SlotPos			= 5
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= false
SWEP.STATE_IDLE			= 1
SWEP.STATE_PULLBACK		= 2
SWEP.STATE_THROWING		= 3
SWEP.STATE_DRINKING		= 4





if CLIENT then

	SWEP.Offsets={
		view={
			bone="ValveBiped.Grenade_body",
			pos=Vector(-0.2,-0.2,-0.5),--Vector(3.5,-2.8,0),
			ang=Angle(0,0,185),
		},
		world={
			bone="ValveBiped.Bip01_R_Hand",
			pos=Vector(3,-2,0),
			ang=Angle(0,0,185),
		}
	}
	
	killicon.AddFont( "weapon_cannade" ,"HL2MPTypeDeath","4", Color( 255, 12, 255, 255 ) )
	killicon.AddFont( "can_nade_nade", "HL2MPTypeDeath","4", Color( 255, 12, 255, 255 ) )
	
	function SWEP:PreDrawViewModel( vm, wep, ply )
		if not IsValid(vm) then return end
		vm:SetMaterial( "engine/occlusionproxy" )

	end

	function SWEP:PostDrawViewModel( vm, wep, ply )
		if not IsValid(vm) then return end
		vm:SetMaterial()

	end
	
	function SWEP:ViewModelDrawn(vm)
        self:DrawEffects(true,vm)
    end
    
	function SWEP:CreateCan()
		if IsValid(self.Can) then return end
		timer.Simple(0,function()
			if not IsValid(self) or IsValid(self.Can) then return end
			self.Can=ClientsideModel(self.WorldModel)
			self.Can:SetNoDraw(true)
			self.Can:Spawn()
		end)
	end
	
	function SWEP:DrawEffects(view_or_world,vm)
		self:CreateCan()
		if not IsValid(self.Owner) then return end
		local ent=(view_or_world) and vm or self.Owner
		if not IsValid(self.Can) then return end
		local offsets=self.Offsets[(view_or_world) and "view" or "world"]
		local bonematrix=ent:GetBoneMatrix(ent:LookupBone(offsets.bone))
		if not bonematrix then return end
		
		local pos,ang=LocalToWorld(offsets.pos,offsets.ang, bonematrix:GetTranslation(), bonematrix:GetAngles() )
		self.Can:SetRenderOrigin(pos)
		self.Can:SetRenderAngles(ang)
		self.Can:DrawModel()
	end
	
    function SWEP:DrawWorldModel()
        self:DrawEffects(false)
		
		if self.dt.State==self.STATE_PULLBACK then
			self:SetWeaponHoldType("grenade")
		elseif self.dt.State==self.STATE_IDLE then
			self:SetWeaponHoldType("slam")
		end
		
    end
end


function SWEP:Initialize()
	self:SetWeaponHoldType("slam")
	self.dt.NextFire=CurTime()+1
end 

function SWEP:SetupDataTables()
	self:DTVar( "Int", 0, "Pressure" )
	self:DTVar( "Int", 1, "State" )
	self:DTVar( "Float", 0, "NextFire" )
	self.dt.Pressure=0
	self.dt.State=self.STATE_IDLE
	self.dt.NextFire=CurTime()+1
end



function SWEP:Deploy()
	self:SetWeaponHoldType("slam")
	self.dt.State=self.STATE_IDLE
	self:SendWeaponAnim(ACT_VM_DRAW)
	self.dt.NextFire=CurTime()+1
return true
end

--[[
ACT_VM_PULLBACK_HIGH
ACT_VM_PULLBACK_LOW
ACT_VM_THROW
ACT_VM_SECONDARYATTACK
ACT_VM_HAULBACK
ACT_VM_DRAW
ACT_VM_HOLSTER
]]

function SWEP:Think()
	if self.dt.State==self.STATE_PULLBACK and self.dt.NextFire<CurTime() then
		if self.Owner:KeyDown(IN_ATTACK) then
			--charge up the pressure
		else
			--throw the nade
			self.dt.Pressure=75
			self:ThrowCan()
			self:EmitSound("Weapon_Crowbar.Single")
			self.dt.State=self.STATE_THROWING
			self:SendWeaponAnim(ACT_VM_THROW)
			self.Owner:DoAttackEvent()
			self.dt.NextFire=CurTime()+0.7
		end
	end
	if (self.dt.State==self.STATE_THROWING or self.dt.State==self.STATE_DRINKING) and self.dt.NextFire<CurTime() then
		self:SetWeaponHoldType("slam")
		self.dt.State=self.STATE_IDLE
		self:SendWeaponAnim(ACT_VM_DRAW)
		self.dt.NextFire=CurTime()+1
	end
end


function SWEP:PrimaryAttack()
	if self.dt.State~=self.STATE_IDLE or self.dt.NextFire > CurTime() then return end
	self:SetWeaponHoldType("grenade")
	self.dt.State=self.STATE_PULLBACK
	self:SendWeaponAnim(ACT_VM_PULLBACK_HIGH)
	
	self.dt.NextFire=CurTime()+0.25
end

function SWEP:SecondaryAttack()
	if self.dt.State~=self.STATE_IDLE or self.dt.NextFire > CurTime() then return end
	self.dt.State=self.STATE_DRINKING
	self:SendWeaponAnim(ACT_VM_PULLBACK_LOW)
	if SERVER then
		self:HealByCan()
	end
	self:EmitSound("HealthVial.Touch")
	self.dt.NextFire=CurTime()+1
end




function SWEP:ThrowCan()
    if CLIENT then return end

    local    vecEye = self.Owner:EyePos()
    local    vForward, vRight
    vForward = self.Owner:GetForward()
    vRight = self.Owner:GetRight()
    local vecSrc = vecEye + vForward * 18.0 + vRight * 8.0
    vecSrc = self:CheckThrowPosition( self.Owner, vecEye, vecSrc )
    local vecThrow
    vecThrow =self.Owner:GetVelocity()/2
    
    local throwspeeddamnit=1200 
    vecThrow = vecThrow + vForward * throwspeeddamnit
    local can = ents.Create("can_nade_nade")
    if not can or not IsValid(can) then return end
    can:SetPos( vecSrc )
    can:SetAngles( Angle(0,0,0) )
    can:SetOwner( self.Owner )
    can:Spawn()
    can:Activate()
    can:SetPressure(self.dt.Pressure)
    can:GetPhysicsObject():SetVelocity( vecThrow )
    can:GetPhysicsObject():AddAngleVelocity( Vector(600,math.random(-1200,1200),0) )
    self.dt.Pressure=0
end

function SWEP:Holster()
    return true
end

function SWEP:OnDrop()

end

function SWEP:OnRemove()

end


function SWEP:HealByCan()
    local maxhealth=self.Owner:GetMaxHealth()
    local twentyfiveperc=(25*maxhealth)/100
    if(self.Owner:Health()+twentyfiveperc<maxhealth)then
        self.Owner:SetHealth(self.Owner:Health()+twentyfiveperc)
    else
        self.Owner:SetHealth(maxhealth)
    end
end



function SWEP:CheckThrowPosition( pPlayer, vecEye, vecSrc )

    local tr

    tr = {}
    tr.start = vecEye
    tr.endpos = vecSrc
    tr.mins = Vector(6,6,6)*-1
    tr.maxs = Vector(6,6,6)
    tr.mask = MASK_PLAYERSOLID
    tr.filter = pPlayer
    tr.collision = pPlayer:GetCollisionGroup()
    local trace = util.TraceHull( tr )

    if ( trace.Hit ) then
        vecSrc = tr.endpos
    end

    return vecSrc

end


weapons.Register(SWEP,"weapon_cannade",true)