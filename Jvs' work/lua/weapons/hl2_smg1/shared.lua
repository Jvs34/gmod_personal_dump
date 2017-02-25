if (SERVER) then
	AddCSLuaFile( "shared.lua" )
	SWEP.Weight		= 5
	SWEP.AutoSwitchTo	= true
	SWEP.AutoSwitchFrom	= true
end

if ( CLIENT ) then
	killicon.AddFont( "hl2_smg1", "HL2MPTypeDeath", "/", Color( 255, 80, 0, 255 ) )

	SWEP.DrawAmmo			= true
	SWEP.PrintName			= "Super Smg"
	SWEP.Author				= "Jvs"
	SWEP.DrawCrosshair		= true
	function SWEP:DrawWeaponSelection( x, y, wide, tall, alpha )
	surface.SetDrawColor( color_transparent )
	surface.SetTextColor( 255, 220, 0, alpha )
	surface.SetFont( "TitleFont" )
	local w, h = surface.GetTextSize( "a" )
	surface.SetTextPos( x + ( wide / 2 ) - ( w / 2 ),y + ( tall / 2 ) - ( h / 2 ) )
	surface.DrawText( "a" )
	end
end

SWEP.Category = "Jvs" 

SWEP.Spawnable     			= true
SWEP.AdminSpawnable  		= true
 
SWEP.ViewModel				= "models/weapons/v_smg1.mdl"
SWEP.WorldModel				= "models/weapons/w_smg1.mdl"
SWEP.Primary.ClipSize		= 45
SWEP.Primary.DefaultClip	= 45
SWEP.Primary.Ammo = "SMG1"
SWEP.Primary.Automatic		= true

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Ammo = "SMG1_Grenade"
SWEP.Secondary.Automatic = true
SWEP.SUPERMODE=false;
SWEP.SUPFT=true;
function SWEP:Initialize()
	if (CLIENT) then return end
	self:SetWeaponHoldType("smg")
end 

function SWEP:Holster()
return true
end

function SWEP:PrimaryAttack()
if CLIENT then return end
	if ( self.Weapon:Clip1() <= 0 && self.Primary.ClipSize > -1 && !self.SUPERMODE) then
			self.Owner:EmitSound( "Weapon_SMG1.Empty" );
			self.Weapon:SetNextPrimaryFire( CurTime() + 0.075 );
		return;
	end
	self.Owner:EmitSound( "Weapon_SMG1.Single" )
	local Attachment = self.Weapon:GetAttachment( 1 )
	local shootOrigin = self.Owner:GetShootPos()
	local shootAngles = self.Weapon:GetAngles()
	local shootDir = self.Owner:GetAimVector()
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
		bullet.ShootCallback = self.ShootCallback;
		bullet.Callback = function( attacker, trace, dmginfo )
			local tr=trace;
			if( (IsValid(tr.Entity) && attacker:GetActiveWeapon().SUPERMODE )&& ( tr.Entity:IsNPC() or tr.Entity:IsPlayer() ) )then
			local dissolver = ents.Create("env_entity_dissolver")
			dissolver:SetKeyValue("dissolvetype",3)
			dissolver:SetKeyValue("magnitude",50)
			dissolver:SetPos(self:GetPos() )
			dissolver:Spawn()
			local targname = "dissolveme"..tr.Entity:EntIndex()
			tr.Entity:SetKeyValue("targetname",targname)
			dissolver:SetKeyValue("target",targname)
			dissolver:Fire("Dissolve",targname,0)
			dissolver:Fire("kill","",0.1)
			end
		end
	self:FireBullets( bullet )
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK );
	self.Owner:SetAnimation( PLAYER_ATTACK1 );
	self.Weapon:SetNextPrimaryFire(CurTime() + 0.075)
	if(!self.SUPERMODE)then
		self:TakePrimaryAmmo( 1 );
	else
	self.Primary.Ammo = "none"
	self.Secondary.Ammo = "none"
	self:TakePrimaryAmmo( 45 );
	end
	self:DoMachineGunKick(self.Owner,0.5,1.0,0.0,2.0);
end

function SWEP:Reload()
if (CLIENT) then return end
	
	local fRet;
	local fCacheTime = 0.5;
	self.m_fFireDuration = 0.0;
	fRet = self.Weapon:DefaultReload( ACT_VM_RELOAD );
	if ( fRet ) then
		self.Weapon:SetNextSecondaryFire( CurTime() + fCacheTime );
		self.Owner:EmitSound( "Weapon_SMG1.Reload" );
	end
	return fRet;
end
function SWEP:Think()
if (CLIENT) then return end
	
	if(self.SUPERMODE ==true && self.SUPFT)then
	self.Owner:EmitSound("Weapon_MegaPhysCannon.Charge");
	self.SUPFT=false;
	end
end	

function SWEP:Deploy()
	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	self:SetDeploySpeed( self.Weapon:SequenceDuration() )

	return true
end

function SWEP:SecondaryAttack()
if (CLIENT) then return end
	
	if(self.Owner:GetAmmoCount( self.Secondary.Ammo ) <= 0  && !self.SUPERMODE) then
		self.Weapon:SendWeaponAnim( ACT_VM_DRYFIRE );
		self.Owner:EmitSound( "Weapon_SMG1.Empty");
		self.Weapon:SetNextSecondaryFire( CurTime() + 0.5 );
		return;
	end
self.Weapon:SetNextPrimaryFire( CurTime() + 0.5 );
self.Weapon:SetNextSecondaryFire(CurTime() + 1)
		local pOwner=self.Owner;
		local pos=pOwner:GetShootPos();
		local ang=pOwner:GetAimVector();
		local nade=ents.Create("grenade_ar2");
		if !nade:IsValid() then return false end
		nade:SetPos(pos);
		nade:SetVelocity(ang*1000);
		nade:SetOwner(pOwner);
		nade:Spawn();
		self.Owner:EmitSound("Weapon_SMG1.Double");
		self.Weapon:SendWeaponAnim( ACT_VM_SECONDARYATTACK );
		self.Owner:SetAnimation( PLAYER_ATTACK1 );
	self.Owner:RemoveAmmo( 1, self.Secondary.Ammo );
end 

function SWEP:DoMachineGunKick( pPlayer, dampEasy, maxVerticleKickAngle, fireDurationTime, slideLimitTime )
	local	KICK_MIN_X			= 0.2	//Degrees
	local	KICK_MIN_Y			= 0.2	//Degrees
	local	KICK_MIN_Z			= 0.1	//Degrees
	local vecScratch = Vector( 0, 0, 0 );
	local duration;
	if ( fireDurationTime > slideLimitTime ) then
		duration	= slideLimitTime
	else
		duration	= fireDurationTime;
	end
	local kickPerc = duration / slideLimitTime;
	pPlayer:ViewPunchReset( 10 );
	vecScratch.x = -( KICK_MIN_X + ( maxVerticleKickAngle * kickPerc ) );
	vecScratch.y = -( KICK_MIN_Y + ( maxVerticleKickAngle * kickPerc ) ) / 3;
	vecScratch.z = KICK_MIN_Z + ( maxVerticleKickAngle * kickPerc ) / 8;
	if ( math.random( -1, 1 ) >= 0 ) then
		vecScratch.y = vecScratch.y * -1;
	end
	if ( math.random( -1, 1 ) >= 0 ) then
		vecScratch.z = vecScratch.z * -1;
	end
	pPlayer:ViewPunch( vecScratch * 0.5 );
end
