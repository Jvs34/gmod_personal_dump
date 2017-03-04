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

SWEP.ViewModel			= "models/weapons/cstrike/c_knife_t.mdl"
SWEP.WorldModel			= "models/weapons/w_knife_t.mdl"

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

SWEP.PrintName			= "Knoife"
SWEP.Slot				= 0
SWEP.SlotPos			= 5
SWEP.DrawAmmo			= false
SWEP.DrawCrosshair		= false




if CLIENT then
	multimodel.Register("weapon_knoife", {

		{
			transform = {Vector(0,0,0), Angle(0,0,0), Vector(1,1,1)*0.7},
			children =	{
						
					{
						model = "models/gibs/glass_shard04.mdl",
						material = "models/props_c17/frostedglass_01a",
						transform = {Vector(-10.256665,-0.425160,-0.648039), Angle(80.937866,-179.999939,90.000031), Vector(0.402607,0.594940,1.000000)},
						color = Color(127,234,255),
					},				
					{
						model = "models/props_combine/headcrabcannister01a.mdl",
						transform = {Vector(-1.511000,-0.191000,-1.144446), Angle(0.000000,0.000000,0.000000), Vector(0.086214,0.034228,0.055763)},
					},				
					{
						model = "models/props_c17/utilityconnecter006.mdl",
						transform = {Vector(4.035201,-0.178589,-1.282349), Angle(0.000000,90.000000,0.000000), Vector(0.100000,0.100000,0.100000)},
					},		
			
			}
		},
	})
	
	SWEP.Offsets={
		view={
			bone="v_weapon.Knife_Handle",
			pos=Vector(0,1,0),
			ang=Angle(90,90,0),
		},
		world={
			bone="ValveBiped.Bip01_R_Hand",
			pos=Vector(2,-1,0),
			ang=Angle(-90,0,0),
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
		local offsets=self.Offsets[(view_or_world) and "view" or "world"]
		
		if not ent:LookupBone(offsets.bone) then return end
		
		local bonematrix=ent:GetBoneMatrix(ent:LookupBone(offsets.bone))
		if not bonematrix then return end
		
		local pos,ang=LocalToWorld(offsets.pos,offsets.ang, bonematrix:GetTranslation(), bonematrix:GetAngles() )
		
		if not self.KnoifeMM then
			self.KnoifeMM=multimodel.CreateInstance("weapon_knoife")
		end
		
		multimodel.Draw(self.KnoifeMM,nil,{origin=pos,angles=ang})
	end
	
    function SWEP:DrawWorldModel()
		self:DrawEffects(false)
    end
	
	function SWEP:DrawWorldModelTranslucent()
		self:DrawEffects(false)
	end
end

--fuck everything else
local ActIndex = {
	[ "knife" ]			= ACT_HL2MP_IDLE_KNIFE,
}

function SWEP:SetWeaponHoldType( t )

	t = string.lower( t )
	local index = ActIndex[ t ]
	
	if ( index == nil ) then
		Msg( "SWEP:SetWeaponHoldType - ActIndex[ \""..t.."\" ] isn't set! (defaulting to normal)\n" )
		t = "normal"
		index = ActIndex[ t ]
	end

	self.ActivityTranslate = {}
	self.ActivityTranslate [ ACT_MP_STAND_IDLE ] 				= index
	self.ActivityTranslate [ ACT_MP_WALK ] 						= index+1
	self.ActivityTranslate [ ACT_MP_RUN ] 						= index+2
	self.ActivityTranslate [ ACT_MP_CROUCH_IDLE ] 				= index+3
	self.ActivityTranslate [ ACT_MP_CROUCHWALK ] 				= index+4
	self.ActivityTranslate [ ACT_MP_ATTACK_STAND_PRIMARYFIRE ] 	= ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE
	self.ActivityTranslate [ ACT_MP_ATTACK_CROUCH_PRIMARYFIRE ] = ACT_HL2MP_GESTURE_RANGE_ATTACK_KNIFE
	self.ActivityTranslate [ ACT_MP_RELOAD_STAND ]		 		= ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE
	self.ActivityTranslate [ ACT_MP_RELOAD_CROUCH ]		 		= ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE
	self.ActivityTranslate [ ACT_MP_JUMP ] 						= index+7
	self.ActivityTranslate [ ACT_RANGE_ATTACK1 ] 				= index+8
	self.ActivityTranslate [ ACT_MP_SWIM_IDLE ] 				= index+8
	self.ActivityTranslate [ ACT_MP_SWIM ] 						= index+9
	
	-- "normal" jump animation doesn't exist
	if t == "normal" then
		self.ActivityTranslate [ ACT_MP_JUMP ] = ACT_HL2MP_JUMP_SLAM
	end

	self:SetupWeaponHoldTypeForAI( t )

end

function SWEP:Initialize()
	self:SetWeaponHoldType("knife")
end 

function SWEP:SetupDataTables()
	self:NetworkVar("Float",0,"NextIdle")
end



function SWEP:Deploy()
	self:SendWeaponAnim(ACT_DEPLOY)
	self:EmitSound("Weapon_Knife.Deploy")
	self:SetNextPrimaryFire(CurTime()+0.30)
	self:SetNextIdle(CurTime()+1)
	return true
end

function SWEP:Think()
	if self:GetNextIdle()~=-1 and self:GetNextIdle() < CurTime() then
		self:SendWeaponAnim( ACT_VM_IDLE )
		self:SetNextIdle(-1)
	end
end

function SWEP:CheckBackstab(ent)
	if not ent:IsPlayer() or not IsValid(ent) then return false end
	
	local ang1 = ent:EyeAngles()
	ang1.p = 0
	
	local p1obb=LocalToWorld(self.Owner:OBBCenter(),angle_zero,self.Owner:GetPos(),angle_zero)
	local p2obb=LocalToWorld(ent:OBBCenter(),angle_zero,ent:GetPos(),angle_zero)
	
	local ang2 = (p1obb - p2obb):Angle()
	ang2.p = 0
	
	local ang2b = self.Owner:EyeAngles()
	ang2b.p = 0
	
	local d1 = ang1:Forward():Dot(ang2:Forward())
	local d2 = ang1:Forward():Dot(ang2b:Forward())
	
	return (d1 < -0.8 or d2 > 0.8) and true or false
end

local function ImpactEffects( tr,dmgtype )
	local e = EffectData()
	e:SetOrigin( tr.HitPos )
	e:SetStart( tr.StartPos )
	e:SetSurfaceProp( tr.SurfaceProps ) -- <3 garry :D
	e:SetDamageType( dmgtype or DMG_BULLET )
	e:SetHitBox( tr.HitBox )
	if CLIENT then
		e:SetEntity( tr.Entity )
	else
		e:SetEntIndex( tr.Entity:EntIndex() )
	end
	util.Effect( "Impact", e )
end

function SWEP:PrimaryAttack()
	

	self.Owner:LagCompensation( true )
	
	local tracedata = {}
	tracedata.start = self.Owner:GetShootPos()
	tracedata.endpos = self.Owner:GetShootPos() + ( self.Owner:GetAimVector() * 75 )
	tracedata.filter = self.Owner
	tracedata.mins =  Vector( -16, -16, -16 )
	tracedata.maxs =  Vector( 16, 16, 16 )
	local tr = util.TraceHull( tracedata )
	
	self.Owner:LagCompensation( false )
	
	if tr.Hit and not tr.HitSky then
	
		local dmg=DamageInfo()
		dmg:SetAttacker(self.Owner)
		dmg:SetInflictor(self)
		dmg:SetDamage(35)
		dmg:SetDamageForce(tracedata.endpos)
		dmg:SetDamagePosition(tr.HitPos)
		dmg:SetDamageType(DMG_SLASH + DMG_SHOCK)
		
		
		if self:CheckBackstab(tr.Entity) then
			dmg:SetDamage(300)
			self:SendWeaponAnim( ACT_VM_MISSCENTER )
			self:EmitSound("Weapon_Knife.Stab")			
		else
			self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
			self:EmitSound("Weapon_Knife.Hit")
		end
		
		if tr.Entity then
			tr.Entity:DispatchTraceAttack(dmg, tr)
		end
		
		ImpactEffects( tr,DMG_BULLET)
		self.Owner:DoAttackEvent()
	
    else
		self:EmitSound("Weapon_Crowbar.Single")
        self:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
		self.Owner:DoReloadEvent()
    end
	
	self:SetNextPrimaryFire(CurTime()+1)
	self:SetNextIdle(CurTime()+self:SequenceDuration())
end

function SWEP:SecondaryAttack()
end




function SWEP:Holster()
    return true
end

function SWEP:OnDrop()

end

function SWEP:OnRemove()

end



weapons.Register(SWEP,"weapon_knoife",true)