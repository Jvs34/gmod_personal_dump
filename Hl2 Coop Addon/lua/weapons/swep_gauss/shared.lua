if (SERVER) then
	AddCSLuaFile( "shared.lua" )

	SWEP.AutoSwitchTo	= true
	SWEP.AutoSwitchFrom	= true
end

if ( CLIENT ) then
	SWEP.DrawAmmo			= true
	SWEP.PrintName			= "Tau cannon"
	SWEP.Author				= "Jvs"
	SWEP.DrawCrosshair		= false
	SWEP.ViewModelFOV		= 65
	//"sprites/hud/v_crosshair1.vmt"
	local crosshair=surface.GetTextureID("sprites/hud/v_crosshair1")
	function SWEP:DrawHUD()
		local BoxSize = 32;
		local Offset = BoxSize / 2;
		surface.SetDrawColor(255, 220, 0, 255);
		surface.SetTexture( crosshair);
		surface.DrawTexturedRect( ( ScrW() / 2 ) - Offset, ( ScrH() / 2 ) - Offset, BoxSize, BoxSize );
	end
	
end

/*Swep animations
ACT_VM_IDLE
ACT_VM_FIDGET
ACT_VM_PULLBACK_LOW
ACT_VM_PULLBACK
ACT_VM_PRIMARYATTACK
ACT_VM_SECONDARYATTACK
ACT_VM_HOLSTER
ACT_VM_DRAW
ACT_VM_RELOAD
*/

SWEP.Category = "Jvs" 
SWEP.Slot				= 1
SWEP.SlotPos			= 5
SWEP.Weight				= 5
SWEP.Spawnable     			= true
SWEP.AdminSpawnable  		= true
 
SWEP.ViewModel 			= "models/weapons/v_gauss.mdl"
SWEP.WorldModel 			= "models/weapons/w_gauss.mdl"

SWEP.Primary.ClipSize		= -1
SWEP.Primary.DefaultClip	= -1
SWEP.Primary.Ammo = "Pistol"
SWEP.Primary.Automatic		= true

SWEP.Secondary.ClipSize		= -1
SWEP.Secondary.DefaultClip	= -1
SWEP.Secondary.Ammo = false
SWEP.Secondary.Automatic = false

function SWEP:Initialize()
	if (CLIENT) then return end
	self:SetWeaponHoldType("physgun")
	self.LoopSound = CreateSound( self, "Jeep.GaussCharge" )
	self.Charging=false;
	self.LastPos=Vector(0,0,0);
end 

function SWEP:Holster()
	return true
end


function SWEP:Deploy()
	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	self:SetDeploySpeed( 1 )
	return true
end

function SWEP:Think()
	if CLIENT then return end
	
	
	
	
end

function SWEP:PrimaryAttack()
	if(self.Charging==false)then
	self.Weapon:EmitSound("PropJeep.FireChargedCannon")
	self:FireGaussBullet()
	self.Owner:ViewPunch(Angle( -1, 0, 0 ) );
	self.Weapon:SetNextPrimaryFire(CurTime()+0.25)
	end
end

function SWEP:Reload()
	self.LoopSound:ChangePitch(200);
end

//Overriden because we don't want a shotgun!
function SWEP:SecondaryAttack()
	self.LoopSound:Play();
		
end

function SWEP:FireGaussBullet()
	
	local bullet = {}
	bullet.Num 		= 1
	bullet.Src 		= self.Owner:GetShootPos()			// Source
	bullet.Dir 		= self.Owner:GetAimVector()			// Dir of bullet
	bullet.Spread 	= Vector( 0,0,0 )		// Aim Cone
	bullet.Tracer	= 0	// Show a tracer on every x bullets 
	bullet.Force	= 15*0.5									// Amount of force to give to phys objects
	bullet.Damage	= 15
	bullet.AmmoType = "GaussEnergy"
	bullet.Callback = function( attacker, tr, dmginfo )
					local ply = attacker
					local pos = ply:EyePos() + ply:EyeAngles():Right() *50
					local effect = EffectData()
					effect:SetStart(pos)
					effect:SetOrigin(tr.HitPos)
					effect:SetScale(9000)
					effect:SetRadius(1);
					util.Effect("GaussTracer", effect)
					
					attacker:GetActiveWeapon().LastPos=tr.HitPos;
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
						bullet2.Force		= dmginfo:GetDamage()
						bullet2.Damage	= dmginfo:GetDamage()
						bullet2.CallBack = function( attacker, tr, dmginfo )
									local effect = EffectData()
									effect:SetStart(attacker:GetActiveWeapon().LastPos)
									effect:SetOrigin(tr.HitPos)
									effect:SetScale(9000)
									effect:SetRadius(1);
									util.Effect("GaussTracer", effect)
						end
					attacker:FireBullets(bullet2)
	end
	self.Owner:FireBullets( bullet )
	self:ShootEffects()

end