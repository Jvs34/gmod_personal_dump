SWEP = {}

DEFINE_BASECLASS( "weapon_base" )
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/c_shotgun.mdl"
SWEP.WorldModel = "models/weapons/w_shotgun.mdl"
SWEP.ViewModelFOV = 54
SWEP.PrintName = "Shotgun"
SWEP.Slot = 3
SWEP.SlotPos = 0

SWEP.Primary = {}
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = 0
SWEP.Primary.Ammo = "Buckshot"
SWEP.Primary.Automatic = true
SWEP.Primary.Spread = Vector( 0.08716, 0.08716, 0.08716 )
SWEP.Primary.AmmoTaken = 1
SWEP.Primary.KnockbackForce = 5

SWEP.Secondary = {}
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = 0
SWEP.Secondary.Ammo = -1
SWEP.Secondary.Automatic = false

SWEP.Spawnable = true

function SWEP:SetupDataTables()
	--create the accessors for this dt var
	self:NetworkVar( "Bool" , 0 , "ShotgunCocked" )
	self:NetworkVar( "Bool" , 1 , "ShotgunKnockback" )
	self:NetworkVar( "Bool" , 2 , "ShotgunAutoCock" )
	
	self:NetworkVar( "Float", 0 , "NextIdle" )
	self:NetworkVar( "Float" , 1 , "NextAttack" )
	
	self:NetworkVar( "Int" , 0 , "KnockbackMultiplier" )
end

function SWEP:Initialize()
	--the weapon has just spawned, set the DT var to false
	self:SetShotgunCocked( true )
	self:SetShotgunKnockback( false )
	self:SetShotgunAutoCock( true )
	self:SetHoldType( "shotgun" )
	
	hook.Add( "SetupMove" , self , self.HandleKnockback )
end

function SWEP:Deploy()
	self:SendWeaponAnim( ACT_VM_DRAW )
	self:SetNextAttack( CurTime() + self:SequenceDuration() )
	self:SetNextIdle( self:GetNextAttack() )
	return true
end

function SWEP:Think()
	--this checks whenever we should actually do a pump animation or not
	if self:GetShotgunAutoCock() and self:GetNextAttack() <= CurTime() and not self:GetShotgunCocked() then
		self:CockShotgun()
	end
	
	if self:GetNextIdle() ~= -1 and self:GetNextIdle() <= CurTime() then
		self:SendWeaponAnim( ACT_VM_IDLE )
		self:SetNextIdle( -1 )
	end
end

function SWEP:PrimaryAttack()
	self:FireShotgun( 1 )
end

function SWEP:SecondaryAttack()
	self:FireShotgun( 4 )
end

function SWEP:FireShotgun( shotsn )
	local requirement = self.Primary.AmmoTaken * shotsn
	if not self:CanAttack( requirement , true ) then
		return
	end
	
	self:SendWeaponAnim( ( shotsn > 1 ) and ACT_VM_SECONDARYATTACK or ACT_VM_PRIMARYATTACK )
	self:EmitSound( ( shotsn > 1 ) and "Weapon_Shotgun.Double" or "Weapon_Shotgun.Single" )
	self:GetOwner():DoAttackEvent()
	self:GetOwner():MuzzleFlash()
	self:GetOwner():RemoveAmmo( requirement , self:GetPrimaryAmmoType() )
	self:GetOwner():ViewPunch( Angle( -2.5 * shotsn , 0 , 0 ) )
	
	self:GetOwner():FireBullets( {
		Force = self.Primary.KnockbackForce,
		Attacker = self:GetOwner(),
		Damage = 8,
		Num = 7 * shotsn,
		AmmoType = self.Primary.Ammo,
		Spread = self.Primary.Spread * shotsn, --also multiply the spread by the number of shots done
		Src = self:GetOwner():GetShootPos(),
		Dir = self:GetOwner():GetAimVector(),
	})
	
	self:SetShotgunCocked( false )
	
	self:SetKnockbackMultiplier( shotsn )
	self:SetShotgunKnockback( true )
	
	self:SetNextAttack( CurTime() + self:SequenceDuration() )
end

function SWEP:CockShotgun( wasteammo )
	
	local requirement = self.Primary.AmmoTaken
	
	if wasteammo and not self:CanAttack( requirement , false ) then
		return false
	end

	self:EmitSound( "Weapon_Shotgun.Special1" )
	self:SendWeaponAnim( ACT_SHOTGUN_PUMP )
	self:SetNextAttack( CurTime() + self:SequenceDuration() )
	self:SetNextIdle( self:GetNextAttack() )
	
	if wasteammo and self:GetShotgunCocked() then
		self:GetOwner():RemoveAmmo( requirement , self:GetPrimaryAmmoType() )
	end
	--TODO: do a third person animation as well
	self:SetShotgunCocked( true )
end

function SWEP:Reload()
	--cock the shotgun again if you want, but you'll lose 1 ammo because you're a dumbass and you just ejected something that didn't need to?
	if not self:GetShotgunAutoCock() then
		self:CockShotgun( true )
	end
end

function SWEP:CanAttack( requirement , checkcocked )
	requirement = requirement or self.Primary.AmmoTaken
	
	if self:GetNextAttack() > CurTime() then
		return false
	end
	
	--the owner doesn't have enough ammo
	if self:GetOwner():GetAmmoCount( self:GetPrimaryAmmoType() ) < requirement or ( checkcocked and not self:GetShotgunCocked() ) then
		self:EmitSound( "Weapon_Shotgun.Empty" )
		self:SetNextAttack( CurTime() + 0.25 )
		return false
	end
	
	return true
end

function SWEP:HandleKnockback( ply , movedata , usercmd )
	if IsValid( ply ) and ply:GetActiveWeapon() == self and self:GetShotgunKnockback() then
		ply:SetGroundEntity( NULL )
		local vel = movedata:GetVelocity()
		vel:Add( ply:GetAimVector() * -1 * self.Primary.KnockbackForce * 15 * self:GetKnockbackMultiplier() )
		movedata:SetVelocity( vel )
		self:SetShotgunKnockback( false )
		self:SetKnockbackMultiplier( 0 )
	end
end

weapons.Register(SWEP,"weapon_boringshotgun",true)
SWEP = nil