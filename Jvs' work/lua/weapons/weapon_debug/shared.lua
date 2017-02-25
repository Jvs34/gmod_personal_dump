if (SERVER) then
	AddCSLuaFile( "shared.lua" )
	SWEP.Weight		= 5
	SWEP.AutoSwitchTo	= true
	SWEP.AutoSwitchFrom	= true
end

if ( CLIENT ) then
	SWEP.DrawAmmo			= false
	SWEP.PrintName			= "Debug Weapon"
	SWEP.Author				= "Jvs"
	SWEP.DrawCrosshair		= true
	
end

SWEP.Category = "Jvs" 

SWEP.Spawnable     			= true
SWEP.AdminSpawnable  		= true
 
SWEP.ViewModel				= "models/weapons/V_superphyscannon.mdl"
SWEP.WorldModel				= ""--models/weapons/w_physics.mdl

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Ammo = "none"
SWEP.Primary.Automatic		= true

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Ammo = false
SWEP.Secondary.Automatic = false

function SWEP:Initialize()
	if (CLIENT) then return end
	self:SetWeaponHoldType("normal")
end 

function SWEP:Holster()
	return true
end

function SWEP:PrimaryAttack()
	if (CLIENT) then return end
	
	local DMG=DamageInfo();
	
	DMG:SetDamage(25);
	DMG:SetDamageType(DMG_REMOVENORAGDOLL);
	DMG:SetAttacker(self.Owner);
	DMG:SetInflictor(self.Owner);
	tr = self.Owner:GetEyeTrace()
	if(IsValid(tr.Entity))then
	//tr.Entity:TakeDamageInfo(DMG);
	print(table.ToString(tr.Entity:GetKeyValues(),"This ent "..tr.Entity:GetClass().." has these keyvalues" , true))
	//self.Owner:PrintMessage( HUD_PRINTTALK, tr.Entity:GetPhysicsObject():GetVolume() )
		if(tr.Entity:GetClass()=="weapon_debug")then
			tr.Entity.Owner=self.Owner;
			tr.Entity:Reload();
		end
	tr.Entity:SetSkin(1);
	else	
	//self.Owner:TakeDamageInfo(DMG);
	print(table.ToString(self.Owner:GetEyeTrace(),"This ent "..tr.Entity:GetClass().." has these keyvalues" , true))
	/*self.Owner:SetAllowFullRotation( true )
	self.Owner:SprintDisable()
	self.Owner:SetCanZoom( false );
	*/
	end
	self.Weapon:SetNextPrimaryFire(CurTime() + 0.1)
end

function SWEP:Deploy()
	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	self:SetDeploySpeed( self.Weapon:SequenceDuration() )
	return true
end
function SWEP:Reload()
	//self:SetPos(self:GetPos()+Vector(0,0,50));
	self:EmitSound( "Weapon_SMG1.Single" )//
	local Attachment = self.Weapon:GetAttachment( 1 )
	
	// Get the shot angles and stuff.
	local shootOrigin = Attachment.Pos
	local shootAngles = self.Weapon:GetAngles()
	local shootDir = shootAngles:Forward()
	self.Owner:StopAllLuaAnimations()
	// Shoot a bullet
	local bullet = {}
		bullet.Num 			= 1
		bullet.Src 			= shootOrigin
		bullet.Dir 			= shootDir
		bullet.Spread 		= Vector( 0.04362, 0.04362, 0.04362 )
		bullet.Tracer		= 1
		bullet.TracerName 	= "Tracer"
		bullet.Force		= 1
		bullet.Damage		= 12
		bullet.Attacker 	= self.Owner
	self:FireBullets( bullet )
end
function SWEP:SecondaryAttack()
/*
	tr = self.Owner:GetEyeTrace()
	if(IsValid(tr.Entity))then
	//tr.Entity:SetLuaAnimation("stancetest");
	tr.Entity:AddEffects(EF_BRIGHTLIGHT)
	else
	//self.Owner:SetLuaAnimation("stancetest");
	self.Owner:AddEffects(EF_BRIGHTLIGHT)
	end
	*/
	//self.Owner:SetAnimation(ACT_HL2MP_GESTURE_RANGE_ATTACK_MELEE2);
	/*
	local dmg=DamageInfo()
	dmg:SetDamage(self.Owner:Health()-1)
	dmg:SetDamageType(DMG_POISON | DMG_CRUSH);
	dmg:SetAttacker(self)
	dmg:SetInflictor(self)
	self.Owner:TakeDamageInfo(dmg);
	*/
	
	trace={}
	trace.start=Vector(0,0,0)
	trace.endpos=Vector(0,0,20)
 
	traceRes=util.TraceEntity( trace, self.Owner )
	PrintTable(traceRes)
end

function SWEP:Think() //Remember if a lot of things are being checked in Think it could cause lag
 
    if not SERVER then return end //This makes the following code only run on the server, clients would get errors if it wasn't.
 
    if self.Owner:KeyDown( IN_JUMP )then //check if the player is jumping and on the ground
 
        //self.Owner:SetVelocity( self.Owner:GetForward() * 200) //set the velocity to launch the player forward and up.
		
    end
 
end 
