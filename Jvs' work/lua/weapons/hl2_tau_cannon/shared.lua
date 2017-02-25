if (SERVER) then
	AddCSLuaFile( "shared.lua" )
	SWEP.Weight		= 5
	SWEP.AutoSwitchTo	= true
	SWEP.AutoSwitchFrom	= true
end

if ( CLIENT ) then
	SWEP.DrawAmmo			= true
	SWEP.PrintName			= "Tau cannon FAWPIFWB"
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
SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Ammo = "none"
SWEP.Primary.Automatic		= true

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Automatic = false;
SWEP.SUPERMODE=false;
SWEP.SUPFT=true;
function SWEP:Initialize()
	if (CLIENT) then return end
	self:SetWeaponHoldType("smg")
	self.LastBounce=Vector(0,0,0);
end 

function SWEP:Holster()
return true
end

function SWEP:PrimaryAttack()
if CLIENT then return end

	self.Owner:EmitSound( "Weapon_SMG1.Single" )
	local Attachment = self.Weapon:GetAttachment( 1 )
	local shootOrigin = self.Owner:GetShootPos()
	local shootAngles = self.Weapon:GetAngles()
	local shootDir = self.Owner:GetAimVector()
	local bullet = {}
		bullet.Num 			= 1
		bullet.Src 			= shootOrigin
		bullet.Dir 			= shootDir
		bullet.Spread 		= Vector( 0, 0,0)
		bullet.Tracer		= 0
		bullet.TracerName 	= "Tracer"
		bullet.Force		= 1
		bullet.Damage		= 12
		bullet.Attacker 	= self.Owner	
		bullet.ShootCallback = self.ShootCallback;
		bullet.Callback = function( attacker, tr, dmginfo )
					local effect = EffectData()
					effect:SetStart(attacker:GetShootPos())
					effect:SetOrigin(tr.HitPos)
					effect:SetScale(2000)
					effect:SetRadius(1);
					util.Effect("GaussTracer", effect)
				local trace = {}
				trace.start = tr.HitPos
				trace.endpos = trace.start + (tr.HitNormal * 16384)
					local trace = util.TraceLine(trace)
					local DotProduct = tr.HitNormal:Dot(tr.Normal * -1)
					self.LastBounce=tr.HitPos;
					local bullet2 = {}
					bullet2.Num 		= 1
					bullet2.Src 		= tr.HitPos + (tr.HitNormal * 5)
						bullet2.Dir 		= ((2 * tr.HitNormal * DotProduct) + tr.Normal)
						bullet2.Spread 	= Vector(0, 0, 0)
						bullet2.Tracer	= 0
						bullet2.TracerName 	= "Tracer"
						bullet2.Force		= dmginfo:GetDamage() * 0.25
						bullet2.Damage	= dmginfo:GetDamage()
						bullet2.CallBack = function( attacker, tr, dmginfo )
									local effect = EffectData()
									effect:SetStart(self.LastBounce)
									effect:SetOrigin(tr.HitPos)
									effect:SetScale(2000)
									effect:SetRadius(1);
									util.Effect("GaussTracer", effect)
						end
					attacker:FireBullets(bullet2)
		end
	self:FireBullets( bullet )
	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK );
	self.Owner:SetAnimation( PLAYER_ATTACK1 );
	self.Weapon:SetNextPrimaryFire(CurTime() + 0.075)
end

function SWEP:Bounce(attacker, tr, dmginfo)
	print("HAHA,DOUBLE TRACE!")
					local effect = EffectData()
					effect:SetStart(self.LastBounce)
					effect:SetOrigin(tr.HitPos)
					effect:SetScale(2000)
					effect:SetRadius(1);
					util.Effect("GaussTracer", effect)
end

function SWEP:Reload()
end

function SWEP:Think()
end	

function SWEP:Deploy()
	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	self:SetDeploySpeed( self.Weapon:SequenceDuration() )

	return true
end

function SWEP:SecondaryAttack()
end 
