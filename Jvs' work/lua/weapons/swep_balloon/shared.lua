if (SERVER) then
	AddCSLuaFile( "shared.lua" )
	SWEP.Weight		= 5
	SWEP.AutoSwitchTo	= true
	SWEP.AutoSwitchFrom	= true
end

if ( CLIENT ) then
	SWEP.DrawAmmo			= false
	SWEP.PrintName			= "Balloon swep"
	SWEP.Author				= "Jvs"
	SWEP.DrawCrosshair		= false
	
end

SWEP.Category = "Jvs" 

SWEP.Spawnable     			= true
SWEP.AdminSpawnable  		= true
 
SWEP.ViewModel				= "models/weapons/V_hands.mdl"
SWEP.WorldModel				= ""

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
	self:SetWeaponHoldType("melee")
	self.Balloon=nil;
end 

function SWEP:Holster()
	return true
end

function SWEP:PrimaryAttack()

end

function SWEP:Deploy()
	self.Weapon:SendWeaponAnim( ACT_VM_DRAW )
	self:SetDeploySpeed( 1 )
	if(self.Balloon && IsValid(self.Balloon))then
		return true
	end
	
	local bonPos,a=self.Owner:GetBonePosition(self.Owner:LookupBone("ValveBiped.Bip01_R_Hand"));
	//SetMaterial("Models/props_combine/stasisshield_sheet")

	//self.Balloon=MakePlBalloon( self.Owner, 255, 255, 0, 2000, "models/balloon/balloon_hl2", { Pos = self.Owner:GetPos()+Vector(0,0,40) } )
	self.Balloon=MakePlBalloon( self.Owner, 255, 255, 0, 2000, "models/balloon/balloon_hl2", { Pos = self.Owner:GetPos() } )
	self.Balloon:SetOwner(self.Owner);
	
	local attachpoint = self.Balloon:GetPos() + Vector( 0, 0, -10 )
	local LPos1 = self.Balloon:WorldToLocal( attachpoint )
	local LPos2 = self.Owner:WorldToLocal( bonPos )
			local constraint, rope = constraint.Rope( self.Balloon, self.Owner, 
												0, "", 
												LPos1, LPos2, 
												0,40,
												0, 
												1.5, 
												material, 
												nil )
	return true
end
function SWEP:Reload()
end
function SWEP:SecondaryAttack()
end

function SWEP:Think()

end

function MakePlBalloon( pl, r, g, b, force, skin, Data )

	if ( !pl:CheckLimit( "balloons" ) ) then return nil end

	local balloon = ents.Create( "gmod_balloonpl" )
	
		if (!balloon:IsValid()) then return end
		duplicator.DoGeneric( balloon, Data )
		
	balloon:Spawn()

	duplicator.DoGenericPhysics( balloon, pl, Data )

	balloon:SetRenderMode( RENDERMODE_TRANSALPHA )
	balloon:SetColor( r, g, b, 255 )
	balloon:SetForce( force )
	balloon:SetPlayer( pl )

	balloon:SetMaterial( skin )
	
	balloon.Player = pl
	balloon.r = r
	balloon.g = g
	balloon.b = b
	balloon.skin = skin
	balloon.force = force
	
	pl:AddCount( "balloons", balloon )
	
	return balloon

end

duplicator.RegisterEntityClass( "gmod_balloonpl", MakePlBalloon, "r", "g", "b", "force", "skin", "Data" )