

// Variables that are used on both client and server

SWEP.Author			= "Jvs"
SWEP.Contact		= ""
SWEP.Purpose		= ""
SWEP.Instructions	= "Jvs' weapon base."

SWEP.ViewModelFOV	= 62
SWEP.ViewModelFlip	= false
SWEP.ViewModel		= "models/weapons/v_pistol.mdl"
SWEP.WorldModel		= "models/weapons/w_pistol.mdl"
SWEP.AnimPrefix		= "python"

SWEP.Spawnable			= false
SWEP.AdminSpawnable		= true

//These ones are useless and are from the old weapon_base made by garry,don't use these.

SWEP.Primary.ClipSize		= -1				
SWEP.Primary.DefaultClip	= -1				
SWEP.Secondary.ClipSize		= -1				
SWEP.Secondary.DefaultClip	= -1				
SWEP.Primary.Ammo			= "none"
SWEP.Secondary.Ammo			= "none"

//Set instead these ones.

SWEP.Primary.NoAmmoClipSize = 8
SWEP.Secondary.NoAmmoClipSize = 8
SWEP.ReloadType=false; //set it to true to reload like the shotgun,otherwise you will reload the full clip.

SWEP.Primary.NoAmmoType = "Pistol"

SWEP.Secondary.NoAmmoType = "Pistol"

SWEP.Primary.ReloadSound="Weapon_Pistol.Reload"

//These are the clip the weapon is using.

SWEP.Primary.AmmoQt=SWEP.Primary.NoAmmoClipSize;
SWEP.Secondary.AmmoQt=SWEP.Secondary.NoAmmoClipSize;
SWEP.NextReload=0;
SWEP.Primary.Automatic		= false				// Automatic/Semi Auto

SWEP.Secondary.Automatic	= false				// Automatic/Semi Auto



/*---------------------------------------------------------
   Name: SWEP:Initialize( )
   Desc: Called when the weapon is first loaded
---------------------------------------------------------*/
function SWEP:Initialize()
	self.LastBoolet=0;
end


/*---------------------------------------------------------
   Name: SWEP:Precache( )
   Desc: Use this function to precache stuff
---------------------------------------------------------*/
function SWEP:Precache()
end


/*---------------------------------------------------------
   Name: SWEP:PrimaryAttack( )
   Desc: +attack1 has been pressed
---------------------------------------------------------*/
function SWEP:PrimaryAttack()

	// Make sure we can shoot first
	if ( !self:CanPrimaryAttack() ) then return end

	// Play shoot sound
	self.Weapon:EmitSound("Weapon_AR2.Single")
	
	// Shoot 9 bullets, 150 damage, 0.75 aimcone
	self:ShootBullet( 12, 1, 0.01,DMG_BLAST,false)
	
	// Remove 1 bullet from our clip
	self:TakePrimaryAmmo( 1 )
	
	// Punch the player's view
	self.Owner:ViewPunch( Angle( -1, 0, 0 ) )

end


/*---------------------------------------------------------
   Name: SWEP:SecondaryAttack( )
   Desc: +attack2 has been pressed
---------------------------------------------------------*/
function SWEP:SecondaryAttack()

	// Make sure we can shoot first
	if ( !self:CanPrimaryAttack() ) then return end

	// Play shoot sound
	self.Weapon:EmitSound("Weapon_AR2.Single")
	
	// Shoot 9 bullets, 150 damage, 0.75 aimcone
	self:ShootBullet( 150, 1, 0.01,DMG_BLAST,true)
	
	// Remove 1 bullet from our clip
	self:TakePrimaryAmmo( 1 )
	
	// Punch the player's view
	self.Owner:ViewPunch( Angle( -1, 0, 0 ) )

end

/*---------------------------------------------------------
   Name: SWEP:CheckReload( )
   Desc: CheckReload
---------------------------------------------------------*/
function SWEP:CheckReload()
	
end

/*---------------------------------------------------------
   Name: SWEP:Reload( )
   Desc: Reload is being pressed
---------------------------------------------------------*/
function SWEP:Reload()
	self:NoAmmoReload()
end


function SWEP:NoAmmoReload()
	if(self.NextReload<=CurTime() && self.Primary.AmmoQt != self.Primary.NoAmmoClipSize)then
			if self.ReloadType && (self.Primary.AmmoQt < self.Primary.NoAmmoClipSize )then
				if self.Owner:GetAmmoCount( self.Primary.NoAmmoType )>= 1 then
				self.Primary.AmmoQt=self.Primary.AmmoQt+1;
				self.Owner:RemoveAmmo( 1, self.Primary.NoAmmoType )
				self:CallReloadAnim()
				end
			elseif !self.ReloadType && (self.Primary.AmmoQt < self.Primary.NoAmmoClipSize ) then
				if self.Owner:GetAmmoCount( self.Primary.NoAmmoType ) == 0 then
				else
					if self.Owner:GetAmmoCount( self.Primary.NoAmmoType )>= self.Primary.NoAmmoClipSize-self.Primary.AmmoQt then
					self.Owner:RemoveAmmo( self.Primary.NoAmmoClipSize - self.Primary.AmmoQt , self.Primary.NoAmmoType )
					self.Primary.AmmoQt=self.Primary.NoAmmoClipSize;
						self:CallReloadAnim()
					elseif self.Owner:GetAmmoCount( self.Primary.NoAmmoType )< self.Primary.NoAmmoClipSize-self.Primary.AmmoQt then
						self.Primary.AmmoQt=self.Primary.AmmoQt+self.Owner:GetAmmoCount( self.Primary.NoAmmoType );
						self.Owner:RemoveAmmo( self.Owner:GetAmmoCount( self.Primary.NoAmmoType ) , self.Primary.NoAmmoType )
						self:CallReloadAnim()
					end
				end
			end
			
	end
end

function SWEP:CallReloadAnim()
			
			self.Weapon:SendWeaponAnim( ACT_VM_RELOAD )
			self.NextReload=CurTime()+self.Weapon:SequenceDuration();
			self.Owner:SetAnimation(PLAYER_RELOAD)
			self:SetNextPrimaryFire( self.NextReload )
			self:SetNextSecondaryFire( self.NextReload )
			if(self.Primary.ReloadSound)then
				self:EmitSound(self.Primary.ReloadSound)
			end
end

function SWEP:GetClip1Qt()
	return self.Primary.AmmoQt;
end

function SWEP:GetClip2Qt()
	return self.Secondary.AmmoQt;
end

/*---------------------------------------------------------
   Name: SWEP:Think( )
   Desc: Called every frame
---------------------------------------------------------*/
function SWEP:Think()
	if(self.LastBoolet != self.Primary.AmmoQt)then
	self.LastBoolet=self.Primary.AmmoQt;
	self:SetNWInt("ammo1",self.LastBoolet)
	end
end


/*---------------------------------------------------------
   Name: SWEP:Holster( weapon_to_swap_to )
   Desc: Weapon wants to holster
   RetV: Return true to allow the weapon to holster
---------------------------------------------------------*/
function SWEP:Holster( wep )
	return true
end

/*---------------------------------------------------------
   Name: SWEP:Deploy( )
   Desc: Whip it out
---------------------------------------------------------*/
function SWEP:Deploy()
	return true
end


/*---------------------------------------------------------
   Name: SWEP:ShootBullet( )
   Desc: A convenience function to shoot bullets
---------------------------------------------------------*/
function SWEP:ShootEffects()

	self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK ) 		// View model animation
	self.Owner:MuzzleFlash()								// Crappy muzzle light
	self.Owner:SetAnimation( PLAYER_ATTACK1 )				// 3rd Person Animation

end


/*---------------------------------------------------------
   Name: SWEP:ShootBullet( )
   Desc: A convenience function to shoot bullets
---------------------------------------------------------*/
function SWEP:ShootBullet( damage, num_bullets, aimcone,DMGTYPE,dummyboolet)
	local bullet = {}
	bullet.Num 		= num_bullets
	bullet.Src 		= self.Owner:GetShootPos()			// Source
	bullet.Dir 		= self.Owner:GetAimVector()			// Dir of bullet
	bullet.Spread 	= Vector( aimcone, aimcone, 0 )		// Aim Cone
	bullet.Tracer	= 1									// Show a tracer on every x bullets 
	bullet.Force	= 1									// Amount of force to give to phys objects
	bullet.Damage	= 0
	bullet.AmmoType = "Pistol"
	bullet.ShootCallback = self.ShootCallback;
	if(!dummyboolet)then
		bullet.Callback = function( attacker, trace, dmginfo )
			if(trace.Entity && IsValid(trace.Entity))then
			local callDMG=DamageInfo();
			callDMG:SetDamage(damage)
			callDMG:SetDamageType(DMGTYPE)
			callDMG:SetInflictor(self)
			callDMG:SetAttacker(self.Owner)
			callDMG:SetDamageForce(self.Owner:GetAimVector());
			callDMG:SetDamagePosition(trace.Entity:GetPos())
			trace.Entity:TakeDamageInfo(callDMG)
			end
		end
	end
	self.Owner:FireBullets( bullet )
	self:ShootEffects()
	
end


/*---------------------------------------------------------
   Name: SWEP:TakePrimaryAmmo(   )
   Desc: A convenience function to remove ammo
---------------------------------------------------------*/
function SWEP:TakePrimaryAmmo( num )
	
	// Doesn't use clips
	if ( self.Primary.NoAmmoClipSize <= 0 ) then 
	
		if ( self.Primary.AmmoQt <= 0 ) then return end
		
		self.Owner:RemoveAmmo( num, self.Primary.NoAmmoType )
	
	return end
	
	self.Primary.AmmoQt=self.Primary.AmmoQt- num 	
	
end


/*---------------------------------------------------------
   Name: SWEP:TakeSecondaryAmmo(   )
   Desc: A convenience function to remove ammo
---------------------------------------------------------*/
function SWEP:TakeSecondaryAmmo( num )
	
	// Doesn't use clips
	if ( self.Secondary.NoAmmoClipSize <= 0 ) then 
	
		if ( self.Secondary.AmmoQt <= 0 ) then return end
		
		self.Owner:RemoveAmmo( num, self.Secondary.NoAmmoType )
	
	return end
	
	self.Secondary.AmmoQt=self.Secondary.AmmoQt- num 	
	
end


/*---------------------------------------------------------
   Name: SWEP:CanPrimaryAttack( )
   Desc: Helper function for checking for no ammo
---------------------------------------------------------*/
function SWEP:CanPrimaryAttack()

	if ( self.Primary.AmmoQt <= 0 ) then
	
		self:EmitSound( "Weapon_Pistol.Empty" )
		self:SetNextPrimaryFire( CurTime() + 0.2 )
		self:Reload()
		return false
		
	end

	return true

end


/*---------------------------------------------------------
   Name: SWEP:CanSecondaryAttack( )
   Desc: Helper function for checking for no ammo
---------------------------------------------------------*/
function SWEP:CanSecondaryAttack()

	if ( self.Secondary.AmmoQt <= 0 ) then
	
		self.Weapon:EmitSound( "Weapon_Pistol.Empty" )
		self.Weapon:SetNextSecondaryFire( CurTime() + 0.2 )
		return false
		
	end

	return true

end


/*---------------------------------------------------------
   Name: ContextScreenClick(  aimvec, mousecode, pressed, ply )
---------------------------------------------------------*/
function SWEP:ContextScreenClick( aimvec, mousecode, pressed, ply )
end


/*---------------------------------------------------------
   Name: OnRemove
   Desc: Called just before entity is deleted
---------------------------------------------------------*/
function SWEP:OnRemove()
end


/*---------------------------------------------------------
   Name: OwnerChanged
   Desc: When weapon is dropped or picked up by a new player
---------------------------------------------------------*/
function SWEP:OwnerChanged()
end


/*---------------------------------------------------------
   Name: Ammo1
   Desc: Returns how much of ammo1 the player has
---------------------------------------------------------*/
function SWEP:Ammo1()
	return self.Owner:GetAmmoCount( self.Primary.NoAmmoType )
end


/*---------------------------------------------------------
   Name: Ammo2
   Desc: Returns how much of ammo2 the player has
---------------------------------------------------------*/
function SWEP:Ammo2()
	return self.Owner:GetAmmoCount( self.Secondary.NoAmmoType )
end

/*---------------------------------------------------------
   Name: SetDeploySpeed
   Desc: Sets the weapon deploy speed. 
		 This value needs to match on client and server.
---------------------------------------------------------*/
function SWEP:SetDeploySpeed( speed )
	self.m_WeaponDeploySpeed = tonumber( speed )
end

