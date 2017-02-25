if (SERVER) then
	AddCSLuaFile( "shared.lua" )
	SWEP.AutoSwitchTo	= true
	SWEP.AutoSwitchFrom	= true
	
	local ActIndex = {}
	ActIndex[ "holster" ]		= ACT_HL2MP_IDLE_PASSIVE
	ActIndex[ "smg" ]		= ACT_HL2MP_IDLE_SMG1
	function SWEP:SetWeaponHoldType( t )

		local index 								= ActIndex[ t ]
			
		if (index == nil) then
			return
		end
		self.ActivityTranslate 							= {}
		self.ActivityTranslate [ ACT_HL2MP_IDLE ] 			= index
		self.ActivityTranslate [ ACT_HL2MP_WALK ] 			= index +1
		self.ActivityTranslate [ ACT_HL2MP_RUN ] 				= index +2
		self.ActivityTranslate [ ACT_HL2MP_IDLE_CROUCH ] 		= index +3
		self.ActivityTranslate [ ACT_HL2MP_WALK_CROUCH ] 		= index +4
		self.ActivityTranslate [ ACT_HL2MP_GESTURE_RANGE_ATTACK ] 	= index +5
		self.ActivityTranslate [ ACT_HL2MP_GESTURE_RELOAD ] 		= index +6
		self.ActivityTranslate [ ACT_HL2MP_JUMP ] 			= index +7
		self.ActivityTranslate [ ACT_RANGE_ATTACK1 ] 			= index +8
		
		self:SetupWeaponHoldTypeForAI( t )
	end
end


if ( CLIENT ) then
	SWEP.DrawAmmo			= true
	SWEP.PrintName			= "Pulse Machine Gun"
	SWEP.Author				= "Jvs"
	SWEP.DrawCrosshair		= true
	
	
	killicon.AddFont( "swep_pulsemg", "HL2MPTypeDeath", "2", Color( 255, 80, 0, 255 ) )
		local matLight 		= Material( "sprites/light_ignorez" )
	local matBeam		= Material( "effects/lamp_beam" )
	
	local ammo;
	local holstered;
	function SWEP:DrawHUD()
		ammo=self:GetNWInt("clip")
		holstered=self:GetNWBool("holstered")
	end

	function SWEP:CustomAmmoDisplay()
			self.AmmoDisplay = self.AmmoDisplay or {}
			self.AmmoDisplay.Draw = true
			self.AmmoDisplay.PrimaryClip 	= ammo
			self.AmmoDisplay.PrimaryAmmo 	= LocalPlayer():GetAmmoCount("AR2")
			self.AmmoDisplay.SecondaryAmmo 	= -1
			return self.AmmoDisplay
	end
	

	function SWEP:DrawWorldModel()
    self.Weapon:DrawModel()
		if holstered then return end
				local LightNrm 
				local ViewNormal
				local Distance
				local ViewDot
				local r, g, b, a
				local LightPos
			
			
			if self:GetOwner() != nil && IsValid(self:GetOwner()) && self:GetOwner():GetActiveWeapon()==self then
				local Owner=self:GetOwner()
				local pos1,ang1=Owner:GetBonePosition(Owner:LookupBone("ValveBiped.Bip01_L_Hand"))
				
				LightNrm = self:GetOwner():EyeAngles():Forward()*-1
				//ViewNormal = self:GetOwner():GetPos() - EyePos()
				ViewNormal = pos1 - EyePos()
				Distance = ViewNormal:Length()
				ViewNormal:Normalize()
				ViewDot = ViewNormal:Dot( LightNrm )
				r, g, b, a = self:GetColor()
				//LightPos = self:GetOwner():EyePos() + LightNrm * -6
				LightPos = pos1 + LightNrm * -6
			else
				LightNrm = self.Weapon:GetAngles():Right()*-1
				ViewNormal = self.Weapon:GetPos() - EyePos()
				Distance = ViewNormal:Length()
				ViewNormal:Normalize()
				ViewDot = ViewNormal:Dot( LightNrm )
				r, g, b, a = self:GetColor()
				LightPos = self.Weapon:GetPos() + LightNrm * -6
			end
			
			render.SetMaterial( matBeam )
			
			local BeamDot = 0.25
			
			render.StartBeam( 3 )
				render.AddBeam( LightPos + LightNrm * 1, 32, 0.0, Color( r, g, b, 255 * BeamDot) )
				render.AddBeam( LightPos - LightNrm * 100, 32, 0.5, Color( r, g, b, 64 * BeamDot) )
				render.AddBeam( LightPos - LightNrm * 200, 32, 1, Color( r, g, b, 0) )
			render.EndBeam()
	 
	end
end

SWEP.Category = "Jvs" 
SWEP.Slot				= 2
SWEP.SlotPos			= 5
SWEP.Weight				= 5
SWEP.Spawnable     			= true
SWEP.AdminSpawnable  		= true
 
SWEP.ViewModel 			= "models/weapons/v_pulsemg.mdl"
SWEP.WorldModel 			= "models/weapons/w_pulsemg.mdl"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Ammo = "none"
SWEP.Primary.Automatic		= true
SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Ammo = false
SWEP.Secondary.Automatic = false

SWEP.MaxAmmo=60;
SWEP.AmmoClip=SWEP.MaxAmmo;
SWEP.Ar2ClipBonus=30;//using a clip from the ar2,add this temporary bonus to our AmmoClip,but not to the MaxAmmo.
SWEP.DmgPerBullet=11
SWEP.HolsteredRecharge=0.2
SWEP.DeployedRecharge=0.2
function SWEP:Initialize()
	if (SERVER) then 
		self:SetWeaponHoldType("smg")
		self:SetNPCFireRate(0.1)
		self:SetNPCMaxBurst(3)
		self:SetNPCMinBurst(3)
	end
	self.NextRecharge=CurTime()
	self:SetNWInt("clip",self.AmmoClip)
	self.Weapon:EmitSound("Func_Tank.BeginUse")
	self.Holstered=false;
	self.NextHolster=CurTime();
end 

function SWEP:Holster()
	return true
end


function SWEP:Deploy()
	if !self.Holstered then
	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	self.Weapon:EmitSound("Func_Tank.BeginUse")
	else
	self.Weapon:SendWeaponAnim( ACT_VM_IDLE_LOWERED )
	end
	self:SetDeploySpeed( 1 )
				self:SetNextPrimaryFire( CurTime() +1 )
				self:SetNextSecondaryFire( CurTime() + 1 )
				
	return true
end


function SWEP:PrimaryAttack()
	if self.Holstered==true then return end
	if !(self.NextHolster < CurTime()) then return end
	if ( !self:CanPrimaryAttack() ) then return end
	self.Weapon:EmitSound("GenericNPC.GunSound")
	self:ShootBullet( self.DmgPerBullet )
	
	if(self.Owner:IsPlayer())then
		local viewPunch;
		viewPunch = Angle( 0, 0, 0 );
		viewPunch.x = math.Rand( .2, -.2 );
		viewPunch.y = math.Rand( -.2, .2 );
		viewPunch.z = 0.0;
		self.Owner:ViewPunch(viewPunch );
		self.AmmoClip=self.AmmoClip-1;
		self.NextRecharge=CurTime()+0.5
		self:SetNWInt("clip",self.AmmoClip)
	end
	self.Weapon:SetNextPrimaryFire(CurTime()+0.1)
end

function SWEP:CanPrimaryAttack()
	if self.Owner:IsNPC()then return true end
	if ( self.AmmoClip <= 0 ) then
	
		self:EmitSound( "Weapon_Pistol.Empty" )
		self:SetNextPrimaryFire( CurTime() + 0.5 )
		self.Weapon:SendWeaponAnim(ACT_VM_DRYFIRE)
		self.Owner:SetAnimation(PLAYER_ATTACK1)
		return false
	end
	return true
end

function SWEP:HolsterAnim()
	if self.NextHolster< CurTime() then
		if(self.Holstered)then
			if SERVER then //"since reload does not get called on the client"... what?
			self:SetWeaponHoldType("smg")
			end
			self.Holstered=false;
			self.Weapon:SendWeaponAnim(ACT_VM_IDLE_TO_LOWERED)
		else
			self.Weapon:SendWeaponAnim(ACT_VM_LOWERED_TO_IDLE)
			if SERVER then
			self:SetWeaponHoldType("holster")
			end
			self.Holstered=true;
		end
		self.NextHolster=CurTime()+self.Weapon:SequenceDuration()
		self:SetNWBool("holstered",self.Holstered)
	end
end


function SWEP:Reload()
	self:HolsterAnim()
end
	

function SWEP:CreateFlashLight()
	if ! self.flashlight || !IsValid(self.flashlight) then
		local angForward = self.Owner:EyeAngles() + Angle( 90, 0, 0 )
		self.flashlight = ents.Create( "env_projectedtexture" )
		self.flashlight:SetParent( self.Owner )
		self.flashlight:SetLocalPos( Vector( 0, 0, 0 ) )
		self.flashlight:SetLocalAngles(self.Owner:EyeAngles()/*+Angle( 0, 270, 0 )*/)
		self.flashlight:SetKeyValue( "enableshadows", 1 )
		self.flashlight:SetKeyValue( "farz", 2048 )
		self.flashlight:SetKeyValue( "nearz", 8 )
		self.flashlight:SetKeyValue( "lightfov", 80 )
		self.flashlight:SetKeyValue( "lightcolor", "255 255 255")
		self.flashlight:Spawn()
		self.flashlight:Input( "SpotlightTexture", NULL, NULL, "effects/flashlight001" )
		local ply=self.Owner
		    local BoneIndx = ply:LookupBone("ValveBiped.Bip01_Head1")
			local BonePos , BoneAng = ply:GetBonePosition( BoneIndx )
	end

end
		
function SWEP:DestroyFlashLight()	
	if self.flashlight && IsValid(self.flashlight) then
	self.flashlight:Remove();
	end
end	

function SWEP:Think()
	if( self.AmmoClip <self.MaxAmmo && !self.Owner:KeyDown(IN_ATTACK) && self.NextRecharge<CurTime()) then
		if(self.Holstered)then
		self.NextRecharge=CurTime()+self.HolsteredRecharge
		else
		self.NextRecharge=CurTime()+self.DeployedRecharge
		end
		self.AmmoClip=self.AmmoClip+1;
		self:SetNWInt("clip",self.AmmoClip)
	end
	if self.Holstered && self.NextHolster <CurTime() then
		self.Weapon:SendWeaponAnim(ACT_VM_IDLE_LOWERED)
	end
end


function SWEP:SecondaryAttack()
	if self.Holstered==true then return end
	if !(self.NextHolster < CurTime()) then return end
	//if(self.AmmoClip>=self.MaxAmmo && self.AmmoClip+self.Ar2ClipBonus <= self.MaxAmmo*4 && self.Owner:GetAmmoCount("AR2")>=self.Ar2ClipBonus)then
	if(self.AmmoClip<=self.MaxAmmo && self.Owner:GetAmmoCount("AR2")>=self.Ar2ClipBonus)then
		self.Weapon:SendWeaponAnim(ACT_VM_RELOAD)
		self.Weapon:EmitSound("weapons/ar2/npc_ar2_reload.wav")
		self.Owner:SetAnimation(PLAYER_RELOAD)
		self:SetNextPrimaryFire( CurTime() +55 )
		self:SetNextSecondaryFire( CurTime() + 55 )
		self.NextRecharge=CurTime()+55;
		timer.Simple(self.Weapon:SequenceDuration()-0.5, function()
			if(self.Owner:GetActiveWeapon()==self)then
				self.AmmoClip=self.MaxAmmo+self.Ar2ClipBonus;
				self:SetNWInt("clip",self.AmmoClip)
				self.Owner:RemoveAmmo(self.Ar2ClipBonus,"AR2")
				self:SetNextPrimaryFire( CurTime() +1 )
				self:SetNextSecondaryFire( CurTime() + 1 )
				self.NextRecharge=CurTime()+1;
				self.Weapon:EmitSound("Func_Tank.BeginUse")
			else
				self:SetNextPrimaryFire( CurTime() +1 )
				self:SetNextSecondaryFire( CurTime() + 1 )
				self.NextRecharge=CurTime()+1;
			end
		end)
	end
	
end

function SWEP:DoImpactEffect( tr )
	local data = EffectData();
	data:SetOrigin( tr.HitPos + ( tr.HitNormal * 1.0 ) );
	data:SetNormal( tr.HitNormal );
	util.Effect( "AR2Impact", data );
end
//Overriden because i need the tracer every boolet.
function SWEP:ShootBullet( damage )
	
	local bullet = {}
	bullet.Num 		= 1
	bullet.Src 		= self.Owner:GetShootPos()			// Source
	bullet.Dir 		= self.Owner:GetAimVector()			// Dir of bullet
	bullet.Spread 	= Vector( 0.020, 0.020, 0.020 )		// Aim Cone
	bullet.Tracer	= 1						
	bullet.TracerName 	= "AR2Tracer"
	bullet.Force	= damage*0.5									// Amount of force to give to phys objects
	bullet.Damage	= damage
	bullet.AmmoType = "AR2"
	bullet.DoImpactEffect = self.DoImpactEffect;
	bullet.Callback = function( attacker, trace, dmginfo )
		bullet:DoImpactEffect( trace );
	end
	self.Owner:FireBullets( bullet )
	self:ShootEffects()
end